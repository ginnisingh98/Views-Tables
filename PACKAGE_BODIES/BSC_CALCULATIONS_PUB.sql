--------------------------------------------------------
--  DDL for Package Body BSC_CALCULATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CALCULATIONS_PUB" AS
/* $Header: BSCPCLCB.pls 120.2.12000000.1 2007/07/17 07:43:45 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCLCB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      December 28, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Kishore Somesula                                        |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public Specs version.                                           |
 |      This package handles calculations                                               |
 | 10/04/2007  Bug#5968033 psomesul - CALCULATION IS NOT REFLECTING FOR THE SHARED      |
 |                                    OBJECTIVE/SCORECARD                               |
 +======================================================================================+
*/

PROCEDURE save_obj_calculations(
  p_obj_id         IN             NUMBER
, p_params         IN             VARCHAR2
, p_ytd_as_default IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
)
IS
l_calc_recs          BSC_UTILITY.varchar_tabletype;
l_rec_cnt            NUMBER;
l_calc_props         BSC_UTILITY.varchar_tabletype;
l_prop_cnt           NUMBER;
l_calc_id            NUMBER;
l_is_sel             VARCHAR2(3);
l_def_val            NUMBER;
l_cnt                NUMBER;
l_user_level0        NUMBER;

CURSOR c_def_val IS
  SELECT default_value
  FROM bsc_kpi_calculations
  WHERE indicator = p_obj_id
    AND calculation_id = l_calc_id;

CURSOR c_shared_objectives IS
   SELECT indicator
   FROM bsc_kpis_b
   WHERE source_indicator = p_obj_id
     AND share_flag  = 2
     AND prototype_flag <> 2;

BEGIN

   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_obj_id IS NULL OR p_params IS NULL) THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := x_msg_data || ' INSUFFICIENT DATA ';
     RETURN;
   ELSE
     BSC_UTILITY.Parse_String(
                 p_List         =>     p_params,
                 p_Separator    =>     ';',
                 p_List_Data    =>     l_calc_recs,
                 p_List_number  =>     l_rec_cnt
                   );
     SAVEPOINT BSCPCLCB_save_obj_calculations;

     FOR i IN 1..l_rec_cnt  LOOP
       BSC_UTILITY.Parse_String(
                 p_List         =>     l_calc_recs(i),
                 p_Separator    =>     ',',
                 p_List_Data    =>     l_calc_props,
                 p_List_number  =>     l_prop_cnt
                   );


       IF (l_prop_cnt = 2) THEN
         l_calc_id   := TO_NUMBER(l_calc_props(1));
         l_is_sel    := l_calc_props(2);



         l_def_val   := 0;
         l_cnt         := 0;
         l_user_level0 := 2;

         SELECT count(0) INTO l_cnt
         FROM bsc_kpi_calculations
         WHERE indicator = p_obj_id
           AND calculation_id = l_calc_id;


         IF (l_cnt = 1) THEN
           IF c_def_val%ISOPEN THEN
             CLOSE c_def_val;
           END IF;

           FOR cd IN c_def_val LOOP
             l_def_val := cd.default_value;
           END LOOP;


           IF (l_def_val = 1) THEN
             IF (l_is_sel = 'Y') THEN
                l_user_level0 := 1;
                l_def_val     := 1;
             ELSE
                l_user_level0 := 0;
                l_def_val     := 0;
             END IF;

           ELSE
             IF (l_is_sel = 'Y') THEN
                l_user_level0 := 2;
                l_def_val     := 0;
             ELSE
                l_user_level0 := 0;
                l_def_val     := 0;
             END IF;

           END IF;

           BSC_CALCULATIONS_PVT.delete_objective_calculation (
               p_indicator       =>   p_obj_id
              ,p_calculation_id  =>   l_calc_id
              ,x_return_status   =>   x_return_status
              ,x_msg_count       =>   x_msg_count
              ,x_msg_data        =>   x_msg_data
           );
           --DELETE bsc_kpi_calculations     WHERE indicator = p_obj_id    AND calculation_id = l_calc_id;

           BSC_CALCULATIONS_PVT.insert_objective_calculation (
                p_indicator            =>   p_obj_id
               ,p_calculation_id       =>   l_calc_id
               ,p_user_level0          =>   l_user_level0
               ,p_user_level1          =>   l_user_level0
               ,p_user_level1_default  =>   l_user_level0
               ,p_user_level2          =>   NULL
               ,p_user_level2_default  =>   NULL
               ,p_default_value        =>   l_def_val
               ,x_return_status        =>   x_return_status
               ,x_msg_count            =>   x_msg_count
               ,x_msg_data             =>   x_msg_data
               );
          -- INSERT INTO bsc_kpi_calculations(INDICATOR,CALCULATION_ID,USER_LEVEL0,USER_LEVEL1,USER_LEVEL1_DEFAULT,USER_LEVEL2,USER_LEVEL2_DEFAULT,DEFAULT_VALUE)
          -- VALUES(p_obj_id,l_calc_id, l_user_level0,l_user_level0,NULL,NULL,NULL,l_def_val);

            -- Cascade the changes to shared objectives also.
           FOR shared_ind_cd IN c_shared_objectives LOOP
             BSC_CALCULATIONS_PVT.delete_objective_calculation (
               p_indicator       =>   shared_ind_cd.indicator
              ,p_calculation_id  =>   l_calc_id
              ,x_return_status   =>   x_return_status
              ,x_msg_count       =>   x_msg_count
              ,x_msg_data        =>   x_msg_data
             );

             BSC_CALCULATIONS_PVT.insert_objective_calculation (
                p_indicator            =>   shared_ind_cd.indicator
               ,p_calculation_id       =>   l_calc_id
               ,p_user_level0          =>   l_user_level0
               ,p_user_level1          =>   l_user_level0
               ,p_user_level1_default  =>   l_user_level0
               ,p_user_level2          =>   NULL
               ,p_user_level2_default  =>   NULL
               ,p_default_value        =>   l_def_val
               ,x_return_status        =>   x_return_status
               ,x_msg_count            =>   x_msg_count
               ,x_msg_data             =>   x_msg_data
               );


           END LOOP;

         END IF;
       END IF;
     END LOOP;

     IF (p_ytd_as_default IS NOT NULL ) THEN
       save_ytd_as_default_calc(
             p_obj_id           =>    p_obj_id
            ,p_ytd_as_default   =>    p_ytd_as_default
            ,p_commit           =>    p_commit
            ,x_return_status    =>    x_return_status
            ,x_msg_count        =>    x_msg_count
            ,x_msg_data         =>    x_msg_data
       );

       IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
       END IF;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;

  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_obj_calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_obj_calculations ';
        END IF;
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_obj_calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_obj_calculations ';
        END IF;
        RAISE;

END save_obj_calculations;




PROCEDURE save_ytd_as_default_calc(
  p_obj_id         IN             NUMBER
, p_ytd_as_default IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
) IS

CURSOR c_shared_objectives IS
   SELECT indicator
   FROM bsc_kpis_b
   WHERE source_indicator = p_obj_id
     AND share_flag       = 2
     AND prototype_flag   <> 2;

l_user_level0        NUMBER;
l_user_level1        NUMBER;
l_def_value          NUMBER;

BEGIN

  IF (p_obj_id IS NOT NULL AND p_ytd_as_default IS NOT NULL) THEN
    IF (p_ytd_as_default = 'Y') THEN
      l_user_level0 := 1;
      l_user_level1 := 1;
      l_def_value   := 1;

      UPDATE bsc_kpi_calculations
      SET USER_LEVEL0   = l_user_level0,
          USER_LEVEL1   = l_user_level1,
          DEFAULT_VALUE = l_def_value
      WHERE indicator = p_obj_id AND calculation_id = 2;

    ELSE
      l_def_value := 0;
      UPDATE bsc_kpi_calculations
      SET DEFAULT_VALUE = l_def_value
      WHERE indicator = p_obj_id AND calculation_id = 2;

    END IF;
    BSC_DESIGNER_PVT.ActionFlag_change(
        x_indicator => p_obj_id,
        x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
        );

    FOR cd IN c_shared_objectives LOOP
      IF (cd.indicator IS NOT NULL) THEN
        IF (p_ytd_as_default = 'Y') THEN
          l_def_value := 1;

          UPDATE bsc_kpi_calculations
          SET DEFAULT_VALUE = l_def_value
          WHERE indicator = cd.indicator AND calculation_id = 2;

        ELSE
          l_def_value := 0;

          UPDATE bsc_kpi_calculations
          SET DEFAULT_VALUE = l_def_value
          WHERE indicator = cd.indicator AND calculation_id = 2;

        END IF;
      END IF;
    END LOOP;

  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_ytd_as_default_calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_ytd_as_default_calc ';
        END IF;
        RAISE;

    WHEN OTHERS THEN
        ROLLBACK TO BSCPCLCB_save_obj_calculations;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_ytd_as_default_calc ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_ytd_as_default_calc ';
        END IF;
        RAISE;

END save_ytd_as_default_calc;



PROCEDURE save_user_wizard_calculations
(p_tab_id                 IN                 NUMBER
,p_obj_id                 IN                 NUMBER
,p_calcs_list             IN                 VARCHAR2
,p_commit                 IN                 VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT     NOCOPY     VARCHAR2
,x_msg_count              OUT     NOCOPY     NUMBER
,x_msg_data               OUT     NOCOPY     VARCHAR2
) IS

  l_calc_recs              BSC_UTILITY.varchar_tabletype;
  l_calc_props             BSC_UTILITY.varchar_tabletype;
  l_calc_recs_cnt          NUMBER;
  l_calc_props_cnt         NUMBER;
  l_calc_rec               VARCHAR2(500);
  ulv0                     NUMBER;
  ulv1                     NUMBER;
  ulvd1                    NUMBER;
  ulvd2                    NUMBER;
  l_calc_id                NUMBER;
  l_calc_enabled           VARCHAR2(10);


CURSOR c_calcs (cp_calc_id NUMBER) IS
   SELECT * FROM bsc_kpi_calculations where indicator = p_obj_id AND calculation_id = cp_calc_id;

CURSOR c_all_calcs IS
   SELECT * FROM bsc_kpi_calculations where indicator = p_obj_id;


BEGIN

   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (p_obj_id is null OR p_tab_id IS NULL) THEN
      RETURN;
   END IF;


   SAVEPOINT bscpclcb_savepoint_save_calcs;

   BSC_UTILITY.Parse_String (
      p_List         =>   p_calcs_list,
      p_Separator    =>   ';',
      p_List_Data    =>   l_calc_recs,
      p_List_number  =>   l_calc_recs_cnt
    );

    FOR i IN 1..l_calc_recs_cnt LOOP
      IF (l_calc_recs(i) IS NOT NULL) THEN

        BSC_UTILITY.Parse_String (
          p_List         =>   l_calc_recs(i),
          p_Separator    =>   ',',
          p_List_Data    =>   l_calc_props,
          p_List_number  =>   l_calc_props_cnt
        );


        l_calc_id       := TO_NUMBER(RTRIM(LTRIM(l_calc_props(1))));
        l_calc_enabled  := l_calc_props(2);

        IF (l_calc_id IS NOT NULL) THEN
          FOR cd IN c_calcs (l_calc_id) LOOP

            IF (cd.user_level0 IS NOT NULL) THEN
              ulv0  := cd.user_level0;
            ELSE
              ulv0  := 2;
            END IF;
            IF (cd.user_level1_default IS NOT NULL) THEN
              ulvd1 := cd.user_level1_default;
            ELSE
              ulvd1 := ulv0;
            END IF;

            IF (ulvd1 > ulv0) THEN
              ulvd1 := ulv0;
            END IF;

            IF (l_calc_enabled IS NOT NULL AND l_calc_enabled = 'Y') THEN
              IF (cd.default_value = 1) THEN
                ulv1  := 1;
              ELSE
                ulv1  := 2;
              END IF;
            ELSE
              ulv1  := 0;
            END IF;

            ulvd2 := ulv1;

            UPDATE bsc_kpi_calculations
            SET
              user_level1 = ulv1,
              user_level1_default = ulvd1,
              user_level2_default = ulvd2
            WHERE
              indicator = p_obj_id
              AND calculation_id = l_calc_id;

            EXIT;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    FOR cd IN c_all_calcs LOOP
      IF (cd.user_level1 IS NULL OR cd.user_level1_default IS NULL OR cd.user_level2_default IS NULL) THEN

        ulv0 := cd.user_level0;
        IF (ulv0 IS NULL) THEN
          ulv0 := 2;
        END IF;

        IF (cd.user_level1_default IS NOT NULL) THEN
          ulvd1 := cd.user_level1_default;
        ELSE
          ulvd1 := ulv0;
        END IF;

        IF (ulvd1 > ulv0) THEN
          ulvd1 := ulv0;
        END IF;

        IF (cd.user_level1 IS NOT NULL) THEN
          ulv1  := cd.user_level1;
        ELSE
          ulv1  := 0;
        END IF;

        ulvd2 := ulv1;

        UPDATE bsc_kpi_calculations
        SET
           user_level1 = ulv1,
           user_level1_default = ulvd1,
           user_level2_default = ulvd2
        WHERE
           indicator = p_obj_id
           AND calculation_id = cd.calculation_id;
      END IF;
    END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bscpclcb_savepoint_save_calcs;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bscpclcb_savepoint_save_calcs;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO bscpclcb_savepoint_save_calcs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_user_wizard_calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_user_wizard_calculations ';
        END IF;

        RAISE;

    WHEN OTHERS THEN
        ROLLBACK TO bscpclcb_savepoint_save_calcs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_CALCULATIONS_PUB.save_user_wizard_calculations ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_CALCULATIONS_PUB.save_user_wizard_calculations ';
        END IF;
        RAISE;

END save_user_wizard_calculations;






FUNCTION is_calculation_default(
  p_obj_id           IN    NUMBER
 ,p_cal_id           IN    NUMBER
) RETURN VARCHAR2
IS
  l_default       NUMBER;
  l_result        VARCHAR2(1);
  CURSOR c_cal_def IS
    SELECT default_value INTO l_default
    FROM bsc_kpi_calculations
    WHERE indicator = p_obj_id
      AND calculation_id = p_cal_id;
BEGIN
l_result := 'N';
IF p_obj_id IS NOT NULL AND p_cal_id IS NOT NULL THEN
  FOR cd IN c_cal_def LOOP
    IF (cd.default_value = 1) THEN
      l_result := 'Y';
    END IF;
    EXIT;
  END LOOP;
END IF;
return l_result;
EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END is_calculation_default;






FUNCTION is_YTD_enabled_in_def_measure(
  p_obj_id           IN    NUMBER
) RETURN VARCHAR2
IS
  l_def_meas_id       NUMBER;
  l_result            VARCHAR2(1);
  l_cnt               NUMBER;
BEGIN

l_result := 'N';

IF p_obj_id IS NOT NULL THEN
  l_def_meas_id := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id (p_objective_id => p_obj_id);
  IF (l_def_meas_id IS NOT NULL) THEN
    SELECT count(0) INTO l_cnt
    FROM bsc_sys_dataset_calc
    WHERE dataset_id = l_def_meas_id
      AND disabled_calc_id = 2;
    IF (l_cnt = 0) THEN
      l_result := 'Y';
    END IF;

    IF (is_balance_measure(l_def_meas_id) = 'Y') THEN
      l_result := 'N';
    END IF;

  END IF;
END IF;
return l_result;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END is_YTD_enabled_in_def_measure;


FUNCTION is_balance_measure(
  p_kpi_measure_id           IN    NUMBER
) RETURN VARCHAR2
IS
  l_dataset_id bsc_sys_datasets_b.dataset_id%TYPE;
BEGIN
  IF p_kpi_measure_id IS NOT NULL THEN
    SELECT dataset_id
    INTO
      l_dataset_id
    FROM
      bsc_kpi_analysis_measures_b
    WHERE
      kpi_measure_id = p_kpi_measure_id;
    IF l_dataset_id IS NOT NULL THEN
      RETURN is_dataset_balance_type(l_dataset_id);
    END IF;
  END IF;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END is_balance_measure;

/************************************************************************************
--	API name 	: Is_Dataset_Balance_Type
--	Type		: Public
--      This API will check if any of the measure cols associated with a dataset
--      are of balance type. In that case it will return true else false
************************************************************************************/
FUNCTION Is_Dataset_Balance_Type(
  p_dataset_id           IN    NUMBER
) RETURN VARCHAR2
IS

CURSOR c_data_set IS
   SELECT measure_col FROM bsc_sys_measures
   WHERE measure_id IN (SELECT measure_id1 FROM bsc_sys_datasets_b
                        WHERE dataset_id = p_dataset_id
                        UNION
                        SELECT measure_id2 FROM bsc_sys_datasets_b
                        WHERE dataset_id = p_dataset_id);

CURSOR c_db_measure_cols (p_measure_col VARCHAR2) IS
   SELECT measure_type
   FROM bsc_db_measure_cols_vl
   WHERE measure_col = p_measure_col;

l_measure_col_formula      varchar2(1000);
l_measure_col              varchar2(100);

BEGIN
   IF (p_dataset_id IS NOT NULL) THEN
     FOR cd IN c_data_set LOOP
       IF (cd.measure_col IS NOT NULL) THEN
         l_measure_col_formula := REPLACE (cd.measure_col, ' ');
         l_measure_col_formula := REPLACE (l_measure_col_formula, '(',',');
         l_measure_col_formula := REPLACE (l_measure_col_formula, ')',',');
         l_measure_col_formula := REPLACE (l_measure_col_formula, '+',',');
         l_measure_col_formula := REPLACE (l_measure_col_formula, '-',',');
         l_measure_col_formula := REPLACE (l_measure_col_formula, '*',',');
         l_measure_col_formula := REPLACE (l_measure_col_formula, '/',',');


         WHILE (bsc_utility.Is_More(l_measure_col_formula, l_measure_col)) LOOP
           IF (NOT FALSE) THEN
             FOR cd1 IN c_db_measure_cols (l_measure_col) LOOP
               IF (cd1.measure_type = 2) THEN
                 RETURN 'Y';
               END IF;
               EXIT;
             END LOOP;
           END IF;
         END LOOP;
         RETURN 'N';
       END IF;
       EXIT;
     END LOOP;
   END IF;
   RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END Is_Dataset_Balance_Type;

/************************************************************************************
--	API name 	: Is_Calculation_Enabled
--	Type		: Public
--      Checks whether a calculation is enabled for a dataset or not
--      As of now it supports only Year to Date. Other calculation conditions
--      can be added per requirement
************************************************************************************/
FUNCTION Is_Calculation_Enabled(
  p_dataset_id     IN NUMBER
 ,p_calculation_id IN NUMBER
) RETURN VARCHAR2
IS
  l_Count NUMBER := 0;
BEGIN
  SELECT COUNT(1)
  INTO
    l_Count
  FROM
    bsc_sys_dataset_calc
  WHERE
    dataset_id = p_dataset_id AND
    disabled_calc_id = p_calculation_id;

  IF l_Count = 1 OR BSC_DATASETS_PUB.Get_DataSet_Source(p_dataset_id) = BSC_BIS_MEASURE_PUB.c_PMF OR
     (p_calculation_id = 2 AND Is_Dataset_Balance_Type(p_dataset_id) = 'Y')THEN
    RETURN 'N';
  END IF;

  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'Y';
END Is_Calculation_Enabled;




END BSC_CALCULATIONS_PUB;

/

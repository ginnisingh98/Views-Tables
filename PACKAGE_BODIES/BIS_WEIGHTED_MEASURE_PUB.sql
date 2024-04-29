--------------------------------------------------------
--  DDL for Package Body BIS_WEIGHTED_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_WEIGHTED_MEASURE_PUB" AS
/* $Header: BISPWMEB.pls 120.3.12000000.3 2007/02/01 11:09:34 akoduri ship $ */
/*======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BISPWMEB.pls                                                     |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      April 11, 2005                                                  |
 | Creator:                                                                             |
 |                      William Cano                                                    |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public version.                                                 |
 |          This package Handle Weighted Measures                                       |
 |                                                                                      |
 |  05/12/05  jxyu added  Set_Weights_Data API.                                         |
 |  07/12/05  sawu  Bug#4482736: added Get_Dep_KPI_Format_Mask                          |
 |  08-AUG-05 ashankar Bug#4517812 Modified the method Delete_WM_Dependency             |
 |  15-SEP-05 jxyu   Modified Set_Weights_Data API for bug#4427932                      |
 |  11-JAN-07 akoduri  Bug# 5594225: Performance issue in Mass Update UI                |
 +======================================================================================*/

-- Abbreviation Used"
--   WM -> Weighted Measure
--   SN -> Short Name

/************************************************************************************
--      API name        : Delete_Bulk_Weights_Scores
--      Type            : Private
--      Deletes the scores and weights data for given the parameter combinations
--      Restricts the criteria to one dependent measure if p_dependent_measure_id
--      is non - null value

--      Logic :
--         1. Fetch the weight ids corresponding to the p_Param_Ids
--         2. Delete the entries from weights and scores tables using the
--            entries in Step1
************************************************************************************/
PROCEDURE Delete_Bulk_Weights_Scores(
  p_commit         IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Param_Ids      IN FND_TABLE_OF_NUMBER
 ,p_dependent_measure_id  IN NUMBER := NULL
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count      OUT NOCOPY NUMBER
 ,x_msg_data       OUT NOCOPY VARCHAR2
) IS
  l_Weight_Ids  FND_TABLE_OF_NUMBER;
BEGIN
  SAVEPOINT BisDeleteBulkWeightsScores;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF p_Param_Ids.COUNT > 0 THEN
    IF p_dependent_measure_id IS NULL THEN
       SELECT
         weights.weight_id
       BULK COLLECT INTO
         l_Weight_Ids
       FROM
         bis_weighted_measure_weights weights
       WHERE
         weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(p_Param_Ids AS FND_TABLE_OF_NUMBER)));
    ELSE
       SELECT
         weights.weight_id
       BULK COLLECT INTO
         l_Weight_Ids
       FROM
         bis_weighted_measure_weights weights
       WHERE
         weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(p_Param_Ids AS FND_TABLE_OF_NUMBER))) AND
         dependent_measure_id = p_dependent_measure_id;
    END IF;

    FORALL i in 1..l_Weight_Ids.COUNT
      DELETE FROM
        bis_weighted_measure_scores
      WHERE
        weight_id = l_Weight_Ids(i);

    FORALL i in 1..l_Weight_Ids.COUNT
      DELETE FROM
        bis_weighted_measure_weights
      WHERE
        weight_id = l_Weight_Ids(i);
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BisDeleteBulkWeightsScores;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BisDeleteBulkWeightsScores;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO BisDeleteBulkWeightsScores;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_Bulk_Weights_Scores ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_Bulk_Weights_Scores ';
        END IF;
        raise;
END Delete_Bulk_Weights_Scores;

/************************************************************************************
--      API name        : Delete_Cascade_WM_Parameters
--      Type            : Private
--      Deletes the parameter combinations , weights and scores for a particular
--      definition
--      This API will be called in two scenarios
--      1. When a WAM KPI is deleted or the report corresponding to that is deleted
--      2. When the filter dimension object is changed

--      Logic :
--         1. Fetch all the parameter ids corresponding to the given definition id
--         2. Retrieve all the weight ids that are defined for the above parameter
--            ids
--         3. Delete the weights and scores corresponding to the above weight ids
--         4. Delete all the parameter combinations corresponding to that definition
************************************************************************************/
PROCEDURE Delete_Cascade_WM_Parameters(
  p_commit                 IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id IN NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
) IS
  l_Param_Ids   FND_TABLE_OF_NUMBER;
  l_Weight_Ids  FND_TABLE_OF_NUMBER;
BEGIN
   SAVEPOINT BisDeleteCascadeWMParameters;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  SELECT
    params.weighted_parameter_id
  BULK COLLECT INTO
    l_Param_Ids
  FROM
    bis_weighted_measure_params params
  WHERE
    params.weighted_definition_id = p_weighted_definition_id;

  IF l_Param_Ids.COUNT > 0 THEN
    SELECT
      weights.weight_id
    BULK COLLECT INTO
      l_Weight_Ids
    FROM
      bis_weighted_measure_weights weights
    WHERE
      weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER)));

    Delete_Bulk_Weights_Scores (
       p_commit         => FND_API.G_FALSE
      ,p_Param_Ids      => l_Param_Ids
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FORALL i in 1..l_Param_Ids.COUNT
      DELETE FROM
        bis_weighted_measure_params
      WHERE
        weighted_parameter_id = l_Param_Ids(i);

  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BisDeleteCascadeWMParameters;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BisDeleteCascadeWMParameters;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO BisDeleteCascadeWMParameters;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_Cascade_WM_Parameters ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_Cascade_WM_Parameters ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_Cascade_WM_Parameters;
/*******************************************************************
 *******************************************************************/
FUNCTION Is_More
(       p_names IN  OUT NOCOPY  VARCHAR2
    ,   p_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_names,   ',');
        IF (l_pos_ids > 0) THEN
            p_name    :=  TRIM(SUBSTR(p_names,    1,    l_pos_ids - 1));
            p_names   :=  TRIM(SUBSTR(p_names,    l_pos_ids + 1));
        ELSE
            p_name    :=  TRIM(p_names);
            p_names   :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;

 ------- APIs for tables BIS_WEIGHTED_MEASURE_DEPENDS
/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  SAVEPOINT CreateWMDependencyPUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec :=p_Bis_WM_Rec;

  --DBMS_OUTPUT.PUT_LINE(' *** Create_WM_Dependency ***');
  --DBMS_OUTPUT.PUT_LINE('p_Bis_WM_Rec.weighted_measure_id =  '|| p_Bis_WM_Rec.weighted_measure_id);
  --DBMS_OUTPUT.PUT_LINE('p_Bis_WM_Rec.dependent_measure_id =  '|| p_Bis_WM_Rec.dependent_measure_id);
  --DBMS_OUTPUT.PUT_LINE('p_Bis_WM_Rec.Created_By  =  '|| p_Bis_WM_Rec.Created_By );

-- METADATA COLUMNS:
--weighted_measure_id
  IF BIS_WEIGHTED_MEASURE_PVT.validate_measure_id(p_Bis_WM_Rec.weighted_measure_id) = FND_API.G_FALSE THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_W_MEASURE_ID');
      FND_MESSAGE.SET_TOKEN('MEASURE', p_Bis_WM_Rec.weighted_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;
--dependent_measure_id
  IF BIS_WEIGHTED_MEASURE_PVT.validate_measure_id(p_Bis_WM_Rec.dependent_measure_id) = FND_API.G_FALSE THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_D_MEASURE_ID');
      FND_MESSAGE.SET_TOKEN('MEASURE', p_Bis_WM_Rec.weighted_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;

-- WHO COLUMNS
  l_Bis_WM_Rec.Creation_Date := sysdate;
  l_Bis_WM_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  IF l_Bis_WM_Rec.Last_Update_Login IS NULL THEN
    l_Bis_WM_Rec.Last_Update_Login := 0;
  END IF;


  BIS_WEIGHTED_MEASURE_PVT.Create_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMDependencyPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMDependencyPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMDependencyPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;

END Create_WM_Dependency;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT Retrieve_WM_Dependency_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Dependency_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;

END Retrieve_WM_Dependency;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT bis_Update_WM_Dependency_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );
-- This Procedure really does not applied
--weighted_measure_id
--dependent_measure_id
  -- WHO COLUMNS
--  l_Bis_WM_Rec.Last_Update_Date := sysdate;
--  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;

  BIS_WEIGHTED_MEASURE_PVT.Update_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Dependency_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Dependency;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Dependency(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 l_measure_name    BIS_DISPLAY_MEASURES_V.name%TYPE;

 CURSOR c_measure_name IS
 SELECT V.name
 FROM   bis_display_measures_v V,
        bis_indicators         B
 WHERE  B.short_name =V.short_name
 AND    B.indicator_id = p_Bis_WM_Rec.dependent_measure_id;

BEGIN
   SAVEPOINT Delete_WM_Dependency_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Ckeck that Dependent_Measure_id has not Weights Defined

  IF get_Defined_Weights_Status( p_Bis_WM_Rec.weighted_measure_id
    ,p_Bis_WM_Rec.dependent_measure_id ) =   BIS_WEIGHTED_MEASURE_PUB.G_POSITIVE_WEIGHTS  THEN

      IF(c_measure_name%ISOPEN)THEN
       CLOSE c_measure_name;
      END IF;

      OPEN  c_measure_name;
      FETCH c_measure_name INTO l_measure_name;
      CLOSE c_measure_name;

      FND_MESSAGE.SET_NAME('BIS','BIS_REMOVE_VALID_WKPI');
      FND_MESSAGE.SET_TOKEN('MEASURE_NAME', l_measure_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Delete the Dependent Measure
  BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF(c_measure_name%ISOPEN)THEN
          CLOSE c_measure_name;
        END IF;

        ROLLBACK TO Delete_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF(c_measure_name%ISOPEN)THEN
          CLOSE c_measure_name;
        END IF;

        ROLLBACK TO Delete_WM_Dependency_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        IF(c_measure_name%ISOPEN)THEN
          CLOSE c_measure_name;
        END IF;

        ROLLBACK TO Delete_WM_Dependency_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Dependency;

 ------- APIs for table BIS_WEIGHTED_MEASURE_DEFNS

/*******************************************************************
 *******************************************************************/

PROCEDURE Create_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  SAVEPOINT CreateWMDefinitionPUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec :=p_Bis_WM_Rec;

--  l_Bis_WM_Rec.weighted_measure_id
  IF BIS_WEIGHTED_MEASURE_PVT.validate_measure_id(p_Bis_WM_Rec.weighted_measure_id) = FND_API.G_FALSE THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_W_MEASURE_ID');
      FND_MESSAGE.SET_TOKEN('MEASURE', p_Bis_WM_Rec.weighted_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;

--  l_Bis_WM_Rec.VIEWBY_dimension_SN
--  l_Bis_WM_Rec.VIEWBY_dim_level_SN
--  l_Bis_WM_Rec.FILTER_dimension_SN
--  l_Bis_WM_Rec.FILTER_dim_level_SN
--  l_Bis_WM_Rec.time_dimension_short_name
--  l_Bis_WM_Rec.time_dim_level_short_name

-- Set the weighted_definition_id
IF l_Bis_WM_Rec.weighted_definition_id IS NULL THEN
  SELECT BIS_WEIGHTED_MEASURE_DEFNS_S.NEXTVAL
  INTO l_Bis_WM_Rec.weighted_definition_id
  FROM DUAL;
END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Creation_Date := sysdate;
  l_Bis_WM_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  IF l_Bis_WM_Rec.Last_Update_Login IS NULL THEN
    l_Bis_WM_Rec.Last_Update_Login := 0;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.weighted_measure_id = ' || l_Bis_WM_Rec.weighted_measure_id);

-- Create Definition
  BIS_WEIGHTED_MEASURE_PVT.Create_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

-- Create tbe Default Paramerer for the definition
  l_Bis_WM_Rec.weighted_definition_id := x_Bis_WM_Rec.weighted_definition_id;
  l_Bis_WM_Rec.time_level_value_id := BIS_WEIGHTED_MEASURE_PUB.DEFAULT_TIME_LEVEL_VALUE;
  l_Bis_WM_Rec.filter_level_value_id := BIS_WEIGHTED_MEASURE_PUB.DEFAULT_FILTER_LEVEL_VALUE;
  BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter(
         p_commit         => p_commit
        ,p_Bis_WM_Rec     => l_Bis_WM_Rec
        ,x_Bis_WM_Rec     => x_Bis_WM_Rec
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMDefinitionPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMDefinitionPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMDefinitionPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT Retrieve_WM_Definition_pub;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Definition_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition ';
        END IF;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 l_cascade_delete_flag boolean ;

BEGIN
  SAVEPOINT bis_Update_WM_Definition_pub;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_cascade_delete_flag := FALSE;

--  l_Bis_WM_Rec.weighted_measure_id
  IF BIS_WEIGHTED_MEASURE_PVT.validate_measure_id(p_Bis_WM_Rec.weighted_measure_id) = FND_API.G_FALSE THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALIDE_WEIGHTED_MEASURE');
      FND_MESSAGE.SET_TOKEN('MEASURE_ID', p_Bis_WM_Rec.weighted_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

--  l_Bis_WM_Rec.VIEWBY_dimension_SN
--  l_Bis_WM_Rec.VIEWBY_dim_level_SN
--  l_Bis_WM_Rec.FILTER_dimension_SN
--  l_Bis_WM_Rec.FILTER_dim_level_SN
--  l_Bis_WM_Rec.time_dimension_short_name
--  l_Bis_WM_Rec.time_dim_level_short_name

 IF p_Bis_WM_Rec.VIEWBY_dimension_SN IS NOT NULL THEN
   l_Bis_WM_Rec.VIEWBY_dimension_SN := p_Bis_WM_Rec.VIEWBY_dimension_SN;
 END IF;
 IF p_Bis_WM_Rec.VIEWBY_dim_level_SN IS NOT NULL THEN
  l_Bis_WM_Rec.VIEWBY_dim_level_SN := p_Bis_WM_Rec.VIEWBY_dim_level_SN;
 END IF;
 IF p_Bis_WM_Rec.FILTER_dimension_SN IS NOT NULL THEN
  IF l_Bis_WM_Rec.FILTER_dimension_SN <> p_Bis_WM_Rec.FILTER_dimension_SN THEN
    l_cascade_delete_flag := TRUE;
    l_Bis_WM_Rec.FILTER_dimension_SN := p_Bis_WM_Rec.FILTER_dimension_SN;
  END IF;
 END IF;
 IF p_Bis_WM_Rec.FILTER_dim_level_SN IS NOT NULL THEN
  IF l_Bis_WM_Rec.FILTER_dim_level_SN <> p_Bis_WM_Rec.FILTER_dim_level_SN THEN
    l_cascade_delete_flag := TRUE;
    l_Bis_WM_Rec.FILTER_dim_level_SN := p_Bis_WM_Rec.FILTER_dim_level_SN;
   END IF;
 END IF;
 IF p_Bis_WM_Rec.time_dimension_short_name IS NOT NULL THEN
  IF l_Bis_WM_Rec.time_dimension_short_name <> p_Bis_WM_Rec.time_dimension_short_name THEN
    l_cascade_delete_flag := TRUE;
    l_Bis_WM_Rec.time_dimension_short_name := p_Bis_WM_Rec.time_dimension_short_name;
  END IF;
 END IF;
 IF p_Bis_WM_Rec.time_dim_level_short_name IS NOT NULL THEN
  IF l_Bis_WM_Rec.time_dim_level_short_name <>p_Bis_WM_Rec.time_dim_level_short_name THEN
    l_cascade_delete_flag := TRUE;
    l_Bis_WM_Rec.time_dim_level_short_name := p_Bis_WM_Rec.time_dim_level_short_name;
  END IF;
 END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;

-- execute Cascding Delete for  Weighted Measure Parameter
 IF l_cascade_delete_flag = TRUE THEN
    Delete_Cascade_WM_Parameters(
      p_commit                 => p_commit
     ,p_weighted_definition_id => l_Bis_WM_Rec.weighted_definition_id
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
    );
 END IF;

-- Delete the Weighted Measure Definition
 BIS_WEIGHTED_MEASURE_PVT.Update_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
 );

 IF l_cascade_delete_flag = TRUE THEN
-- Create tbe Default Parameter Again
     l_Bis_WM_Rec.time_level_value_id := BIS_WEIGHTED_MEASURE_PUB.DEFAULT_TIME_LEVEL_VALUE;
     l_Bis_WM_Rec.filter_level_value_id := BIS_WEIGHTED_MEASURE_PUB.DEFAULT_FILTER_LEVEL_VALUE;
     BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter(
         p_commit         => p_commit
        ,p_Bis_WM_Rec     => l_Bis_WM_Rec
        ,x_Bis_WM_Rec     => x_Bis_WM_Rec
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
      );
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Definition(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

BEGIN
   SAVEPOINT Delete_WM_Definition_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Weights Cascading delete when a Parameter is deleted
    Delete_Cascade_WM_Parameters(
      p_commit                 => p_commit
     ,p_weighted_definition_id => p_Bis_WM_Rec.weighted_definition_id
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
    );

-- Delete the Weighted Mesure Definition
  BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Definition;

 ------- APIs for table BIS_WEIGHTED_MEASURE_PARAMS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 l_count            NUMBER;
BEGIN
  SAVEPOINT CreateWMParameterPUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec := p_Bis_WM_Rec;

-- weighted_parameter_id
-- weighted_definition_id
-- time_level_value_id
-- filter_level_value_id

  SELECT COUNT(1)
  INTO l_count
  FROM BIS_WEIGHTED_MEASURE_DEFNS
  WHERE WEIGHTED_DEFINITION_ID = p_Bis_WM_Rec.weighted_definition_id;
  IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_DEF');
      FND_MESSAGE.SET_TOKEN('DEF', p_Bis_WM_Rec.weighted_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- Set the weighted_parameter_id
  IF p_Bis_WM_Rec.weighted_parameter_id IS NULL THEN
    SELECT BIS_WEIGHTED_MEASURE_PARAMS_S.NEXTVAL
    INTO l_Bis_WM_Rec.weighted_parameter_id
    FROM DUAL;
  END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Creation_Date := sysdate;
  l_Bis_WM_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  IF l_Bis_WM_Rec.Last_Update_Login IS NULL THEN
    l_Bis_WM_Rec.Last_Update_Login := 0;
  END IF;

 BIS_WEIGHTED_MEASURE_PVT.Create_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateWMParameterPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateWMParameterPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO CreateWMParameterPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT Retrieve_WM_Parameter_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Retrieve_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Retrieve_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO Retrieve_WM_Parameter_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Parameter ';
        END IF;
        raise;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT bis_Update_WM_Parameter_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec :=p_Bis_WM_Rec;

-- weighted_parameter_id
-- weighted_definition_id
-- time_level_value_id
-- filter_level_value_id

IF p_Bis_WM_Rec.weighted_definition_id IS NOT NULL THEN
 l_Bis_WM_Rec.weighted_definition_id := p_Bis_WM_Rec.weighted_definition_id;
END IF;
IF p_Bis_WM_Rec.time_level_value_id IS NOT NULL THEN
 l_Bis_WM_Rec.time_level_value_id := p_Bis_WM_Rec.time_level_value_id;
END IF;
IF p_Bis_WM_Rec.filter_level_value_id IS NOT NULL THEN
 l_Bis_WM_Rec.filter_level_value_id := p_Bis_WM_Rec.filter_level_value_id;
END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;

 BIS_WEIGHTED_MEASURE_PVT.Update_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Parameter_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Parameter(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS

 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

-- Cursor to get the Weights associated to the Parameter
 CURSOR c_Weights IS
    SELECT WEIGHT_ID
    FROM BIS_WEIGHTED_MEASURE_WEIGHTS
    WHERE WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id;
BEGIN
  SAVEPOINT Delete_WM_Parameter_pub;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Weights Cascading delete when a Parameter is deleted
  FOR CD IN c_Weights LOOP
     l_Bis_WM_Rec.weight_id := CD.WEIGHT_ID;
     BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight(
       p_commit         => p_commit
      ,p_Bis_WM_Rec     => l_Bis_WM_Rec
      ,x_Bis_WM_Rec     => x_Bis_WM_Rec
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
  END LOOP;

-- Delete the Parameter
  BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Parameter;

------- APIs for table BIS_WEIGHTED_MEASURE_WEIGHTS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 l_count           NUMBER;
BEGIN
  SAVEPOINT Create_WM_Weight_PUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec := p_Bis_WM_Rec;

--weight_id
--weighted_parameter_id
--dependent_measure_id
--weight


  SELECT COUNT(1)
  INTO l_count
  FROM BIS_WEIGHTED_MEASURE_PARAMS
  WHERE WEIGHTED_PARAMETER_ID = p_Bis_WM_Rec.weighted_parameter_id;
  IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_PARAM');
      FND_MESSAGE.SET_TOKEN('PARAM', p_Bis_WM_Rec.weighted_parameter_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;


-- Set the weighted_definition_id
  IF p_Bis_WM_Rec.weight_id IS NULL THEN
    SELECT BIS_WEIGHTED_MEASURE_WEIGHTS_S.NEXTVAL
    INTO l_Bis_WM_Rec.weight_id
    FROM DUAL;
  END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Creation_Date := sysdate;
  l_Bis_WM_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  IF l_Bis_WM_Rec.Last_Update_Login IS NULL THEN
    l_Bis_WM_Rec.Last_Update_Login := 0;
  END IF;


  BIS_WEIGHTED_MEASURE_PVT.Create_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_WM_Weight_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_WM_Weight_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Create_WM_Weight_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT bis_Retrieve_WM_Weight_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Retrieve_WM_Weight_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Retrieve_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN

  SAVEPOINT bis_Update_WM_Weight_pub;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

-- p_Bis_WM_Rec.weight_id
/* it is not posible to update this to coluns are really primary key
IF p_Bis_WM_Rec.weighted_parameter_id IS NOT NULL THEN
 l_Bis_WM_Rec.weighted_parameter_id := p_Bis_WM_Rec.weighted_parameter_id;
END IF;
IF p_Bis_WM_Rec.dependent_measure_id IS NOT NULL THEN
 l_Bis_WM_Rec.dependent_measure_id := p_Bis_WM_Rec.dependent_measure_id;
END IF;
*/
  IF p_Bis_WM_Rec.weight IS NOT NULL THEN
    l_Bis_WM_Rec.weight := p_Bis_WM_Rec.weight;
  END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;

  BIS_WEIGHTED_MEASURE_PVT.Update_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Weight(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
   SAVEPOINT Delete_WM_Weight_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Cascading delete when a Weight_id is deleted
  l_Bis_WM_Rec.weight_id := p_Bis_WM_Rec.weight_id;
  l_Bis_WM_Rec.low_range := null;
  l_Bis_WM_Rec.high_range := null;

  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

-- Delete the Weight
  BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Weight_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Weight;

------- APIs for table BIS_WEIGHTED_MEASURE_SCORES
/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 l_count           NUMBER;
BEGIN
  SAVEPOINT Create_WM_Score_PUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec :=p_Bis_WM_Rec;

  SELECT COUNT(1)
  INTO l_count
  FROM BIS_WEIGHTED_MEASURE_WEIGHTS
  WHERE WEIGHT_ID = p_Bis_WM_Rec.weight_id;
  IF l_count = 0 THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_WM_INVALIDE_WEIGHT_ID');
      FND_MESSAGE.SET_TOKEN('WEIGHT_ID', p_Bis_WM_Rec.weight_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

-- WHO COLUMNS
  l_Bis_WM_Rec.Creation_Date := sysdate;
  l_Bis_WM_Rec.Created_By := FND_GLOBAL.USER_ID;
  l_Bis_WM_Rec.Last_Update_Date := sysdate;
  l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;
  IF l_Bis_WM_Rec.Last_Update_Login IS NULL THEN
    l_Bis_WM_Rec.Last_Update_Login := 0;
  END IF;


  BIS_WEIGHTED_MEASURE_PVT.Create_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_WM_Score_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_WM_Score_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Create_WM_Score_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Create_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT bis_Retrieve_WM_Score_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BIS_WEIGHTED_MEASURE_PVT.Retrieve_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Retrieve_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Retrieve_WM_Score_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Retrieve_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT bis_Update_WM_Score_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec :=p_Bis_WM_Rec;

  BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

--weight_id
IF p_Bis_WM_Rec.low_range IS NOT NULL THEN
 l_Bis_WM_Rec.low_range := p_Bis_WM_Rec.low_range;
END IF;
IF p_Bis_WM_Rec.high_range IS NOT NULL THEN
 l_Bis_WM_Rec.high_range := p_Bis_WM_Rec.high_range;
END IF;
IF p_Bis_WM_Rec.score IS NOT NULL THEN
 l_Bis_WM_Rec.score := p_Bis_WM_Rec.score;
END IF;

-- WHO COLUMNS
 l_Bis_WM_Rec.Last_Update_Date := sysdate;
 l_Bis_WM_Rec.Last_Updated_By := FND_GLOBAL.USER_ID;

  BIS_WEIGHTED_MEASURE_PVT.Update_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Score_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Score(
  p_commit          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_Bis_WM_Rec      IN BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_Bis_WM_Rec      OUT NOCOPY BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
    SAVEPOINT Delete_WM_Score_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  BIS_WEIGHTED_MEASURE_PVT.Delete_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => p_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Score_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Score_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
    END Delete_WM_Score;
/* ------------------------------------------------------------------------

    *********  WRAPPER APIS FOR RECORD APIS **************************

--------------------------------------------------------------------------*/

PROCEDURE Create_WM_Definition(
 p_commit                      IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,p_weighted_measure_id        IN NUMBER
 ,p_viewby_dimension_sn        IN VARCHAR2
 ,p_viewby_dim_level_sn        IN VARCHAR2
 ,p_filter_dimension_sn        IN VARCHAR2
 ,p_filter_dim_level_sn        IN VARCHAR2
 ,p_time_dimension_sn          IN VARCHAR2
 ,p_time_dim_level_sn          IN VARCHAR2
 ,x_weighted_definition_id     OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

BEGIN
  -- THIS IS JUST A WRAPPER PLEASE DO NOT ADD ANY BUSINESS LOGIC TO THIS PROCEDURE
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weighted_definition_id := p_weighted_definition_id;
  l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
  l_Bis_WM_Rec.viewby_dimension_sn := p_viewby_dimension_sn;
  l_Bis_WM_Rec.viewby_dim_level_sn := p_viewby_dim_level_sn;
  l_Bis_WM_Rec.filter_dimension_sn := p_filter_dimension_sn;
  l_Bis_WM_Rec.filter_dim_level_sn := p_filter_dim_level_sn;
  l_Bis_WM_Rec.time_dimension_short_name := p_time_dimension_sn;
  l_Bis_WM_Rec.time_dim_level_short_name := p_time_dim_level_sn;

-- Create Definition
  BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );
  x_weighted_definition_id := x_Bis_WM_Rec.weighted_definition_id;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition ';
        END IF;
END Create_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Retrieve_WM_Definition(
 p_weighted_definition_id     IN NUMBER
 ,x_weighted_measure_id        OUT NOCOPY NUMBER
 ,x_viewby_dimension_sn        OUT NOCOPY VARCHAR2
 ,x_viewby_dim_level_sn        OUT NOCOPY VARCHAR2
 ,x_filter_dimension_sn        OUT NOCOPY VARCHAR2
 ,x_filter_dim_level_sn        OUT NOCOPY VARCHAR2
 ,x_time_dimension_sn          OUT NOCOPY VARCHAR2
 ,x_time_dim_level_sn          OUT NOCOPY VARCHAR2
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
 x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 l_Bis_WM_Rec.weighted_definition_id := p_weighted_definition_id;

 BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition(
     p_commit         => NULL
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

  x_weighted_measure_id := x_Bis_WM_Rec.weighted_measure_id;
  x_viewby_dimension_sn := x_Bis_WM_Rec.viewby_dimension_sn;
  x_viewby_dim_level_sn := x_Bis_WM_Rec.viewby_dim_level_sn;
  x_filter_dimension_sn := x_Bis_WM_Rec.filter_dimension_sn;
  x_filter_dim_level_sn := x_Bis_WM_Rec.filter_dim_level_sn;
  x_time_dimension_sn := x_Bis_WM_Rec.time_dimension_short_name  ;
  x_time_dim_level_sn := x_Bis_WM_Rec.time_dim_level_short_name;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Retrieve_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Retrieve_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Definition(
 p_commit                      IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,p_weighted_measure_id        IN NUMBER
 ,p_viewby_dimension_sn        IN VARCHAR2
 ,p_viewby_dim_level_sn        IN VARCHAR2
 ,p_filter_dimension_sn        IN VARCHAR2
 ,p_filter_dim_level_sn        IN VARCHAR2
 ,p_time_dimension_sn          IN VARCHAR2
 ,p_time_dim_level_sn          IN VARCHAR2
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2

) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weighted_definition_id := p_weighted_definition_id;
  l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
  l_Bis_WM_Rec.viewby_dimension_sn := p_viewby_dimension_sn;
  l_Bis_WM_Rec.viewby_dim_level_sn := p_viewby_dim_level_sn;
  l_Bis_WM_Rec.filter_dimension_sn := p_filter_dimension_sn;
  l_Bis_WM_Rec.filter_dim_level_sn := p_filter_dim_level_sn;
  l_Bis_WM_Rec.time_dimension_short_name := p_time_dimension_sn;
  l_Bis_WM_Rec.time_dim_level_short_name := p_time_dim_level_sn;

-- Update the Weighted Measure Definition
 BIS_WEIGHTED_MEASURE_PUB.Update_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
 );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Definition_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Definition;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Definition(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_definition_id     IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

BEGIN
  -- THIS IS JUST A WRAPPER PLEASE DO NOT ADD ANY BUSINESS LOGIC TO THIS PROCEDURE
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 l_Bis_WM_Rec.weighted_definition_id := p_weighted_definition_id;

  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_WM_Definition;

/*******************************************************************
 *******************************************************************/

PROCEDURE Create_WM_Dependency(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id        IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  -- THIS IS JUST A WRAPPER PLEASE DO NOT ADD ANY BUSINESS LOGIC TO THIS PROCEDURE

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weighted_measure_id :=  p_weighted_measure_id;
  l_Bis_WM_Rec.dependent_measure_id :=  p_dependent_measure_id;

  BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Create_WM_Dependency;

/*******************************************************************
 *******************************************************************/

PROCEDURE Delete_WM_Dependency(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id        IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  -- THIS IS JUST A WRAPPER PLEASE DO NOT ADD ANY BUSINESS LOGIC TO THIS PROCEDURE
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_Bis_WM_Rec.weighted_measure_id :=  p_weighted_measure_id;
  l_Bis_WM_Rec.dependent_measure_id :=  p_dependent_measure_id;

-- Delete the Dependent Measure
  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_WM_Dependency;

PROCEDURE Create_WM_Parameter(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_parameter_id      IN NUMBER
 ,p_weighted_definition_id     IN NUMBER
 ,p_time_level_value_id        IN VARCHAR2
 ,p_filter_level_value_id      IN VARCHAR2
 ,x_weighted_parameter_id      OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  SAVEPOINT CreateWMParameterPUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weighted_parameter_id := p_weighted_parameter_id;
  l_Bis_WM_Rec.weighted_definition_id := p_weighted_definition_id;
  l_Bis_WM_Rec.time_level_value_id := p_time_level_value_id;
  l_Bis_WM_Rec.filter_level_value_id := p_filter_level_value_id;

 BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

  x_weighted_parameter_id := x_Bis_WM_Rec.weighted_parameter_id;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_WM_Parameter;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Parameter(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_parameter_id      IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS

 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weighted_parameter_id := p_weighted_parameter_id;

-- Delete the Parameter
  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Parameter(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Parameter_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Parameter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Parameter ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Delete_WM_Parameter;

------- APIs for table BIS_WEIGHTED_MEASURE_WEIGHTS

/*******************************************************************
 *******************************************************************/
PROCEDURE Create_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,P_weight_id                  IN NUMBER
 ,p_weighted_parameter_id      IN NUMBER
 ,p_dependent_measure_id       IN NUMBER
 ,p_weight                     IN NUMBER
 ,x_weight_id                  OUT NOCOPY NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 l_Bis_WM_Rec.weight_id := p_weight_id;
 l_Bis_WM_Rec.weighted_parameter_id := p_weighted_parameter_id;
 l_Bis_WM_Rec.dependent_measure_id := p_dependent_measure_id;
 l_Bis_WM_Rec.weight := p_weight;

  BIS_WEIGHTED_MEASURE_PUB.Create_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

  x_weight_id :=  x_Bis_WM_Rec.weight_id ;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,p_weight                     IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 l_Bis_WM_Rec.weight_id := p_weight_id;
 l_Bis_WM_Rec.weight := p_weight;

  BIS_WEIGHTED_MEASURE_PUB.Update_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO bis_Update_WM_Weight_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Weight;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Weight(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
   SAVEPOINT Delete_WM_Weight_pub;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weight_id := p_weight_id;
-- Delete the Weight
  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Weight ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_WM_Weight;

PROCEDURE Create_WM_Score(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,p_low_range                  IN NUMBER
 ,p_high_range                 IN NUMBER
 ,p_score                      IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  SAVEPOINT Create_WM_Score_PUB;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

 l_Bis_WM_Rec.weight_id := p_weight_id;
 l_Bis_WM_Rec.low_range := p_low_range;
 l_Bis_WM_Rec.high_range := p_high_range;
 l_Bis_WM_Rec.score := p_score;

  BIS_WEIGHTED_MEASURE_PUB.Create_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_WM_Score;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_WM_Score(
  p_commit                     IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weight_id                  IN NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Bis_WM_Rec.weight_id := p_weight_id;

  BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score(
     p_commit         => p_commit
    ,p_Bis_WM_Rec     => l_Bis_WM_Rec
    ,x_Bis_WM_Rec     => x_Bis_WM_Rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
  );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Score ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
    END Delete_WM_Score;


/*******************************************************************
   Check_Defined_Weights
      Check if some weight hadbeen defined for the Weighted Measure
      or for a scpecific dependint Measure.

   Input Parameters:

      p_weighted_measure_id -> This is the Weighted Measure Id
      p_dependent_measure_Id -> if null is passed it check for the whole
                                 Weighted Measure
  Return
     P  -> Positive Weights Defined
     Z  -> Zero Wheioghts Defined
     N  -> No Weights Defined
     NULL ->  It is returned when and error happen or p_weighted_measure_id
              is passed as null

 *******************************************************************/
FUNCTION get_Defined_Weights_Status (
  p_weighted_measure_id     IN NUMBER
 ,p_dependent_measure_Id    IN NUMBER
) RETURN VARCHAR IS
-- Cursor to count Weights <> 0 associated to a Dependent Measure
 CURSOR c_weights_by_dep_measure IS
    SELECT COUNT(C.WEIGHT_ID) C1
    FROM BIS_WEIGHTED_MEASURE_DEFNS A
         ,BIS_WEIGHTED_MEASURE_PARAMS B
         ,BIS_WEIGHTED_MEASURE_WEIGHTS C
    WHERE A.weighted_measure_id = p_weighted_measure_id
      AND A.weighted_definition_id = B.weighted_definition_id
      AND B.weighted_parameter_id = C.weighted_parameter_id
      AND C.DEPENDENT_MEASURE_ID = p_dependent_measure_Id
      AND C.WEIGHT <> 0 ;

-- Cursor to count Weights associated to a Dependent Measure
 CURSOR c_weights0_by_dep_measure IS
    SELECT COUNT(WEIGHT_ID) C1
    FROM BIS_WEIGHTED_MEASURE_DEFNS A
         ,BIS_WEIGHTED_MEASURE_PARAMS B
         ,BIS_WEIGHTED_MEASURE_WEIGHTS C
    WHERE A.weighted_measure_id = p_weighted_measure_id
      AND A.weighted_definition_id = B.weighted_definition_id
      AND B.weighted_parameter_id = C.weighted_parameter_id
      AND C.DEPENDENT_MEASURE_ID = p_dependent_measure_Id
      AND C.WEIGHT = 0 ;

-- Cursor to count the Weights <> 0 associated to Weighted Measure
 CURSOR c_weights IS
    SELECT COUNT(WEIGHT_ID) C1
    FROM BIS_WEIGHTED_MEASURE_DEFNS A
         ,BIS_WEIGHTED_MEASURE_PARAMS B
         ,BIS_WEIGHTED_MEASURE_WEIGHTS C
    WHERE A.weighted_measure_id = p_weighted_measure_id
      AND A.weighted_definition_id = B.weighted_definition_id
      AND B.weighted_parameter_id = C.weighted_parameter_id
      AND C.WEIGHT <> 0 ;

-- Cursor to count the Weights <> 0 associated to Weighted Measure
 CURSOR c_weights0 IS
    SELECT COUNT(WEIGHT_ID) C1
    FROM BIS_WEIGHTED_MEASURE_DEFNS A
         ,BIS_WEIGHTED_MEASURE_PARAMS B
         ,BIS_WEIGHTED_MEASURE_WEIGHTS C
    WHERE A.weighted_measure_id = p_weighted_measure_id
      AND A.weighted_definition_id = B.weighted_definition_id
      AND B.weighted_parameter_id = C.weighted_parameter_id
      AND C.WEIGHT = 0 ;

 l_status  VARCHAR2(1);
 l_count   NUMBER;

BEGIN
 l_status := G_NO_WEIGHTS;

-- Query for Count the Weights Defined for the current dependent measure
  IF p_weighted_measure_id IS NOT NULL THEN

     IF p_dependent_Measure_Id IS NOT NULL THEN
     -- For the dependent Measure only
        FOR CD IN c_weights_by_dep_measure LOOP
          l_count := CD.C1;
        END LOOP;
        IF l_count > 0 THEN
           l_status := G_POSITIVE_WEIGHTS;
        ELSE
           FOR CD IN c_weights0_by_dep_measure LOOP
             l_count := CD.C1;
           END LOOP;
           IF l_count > 0 THEN
             l_status := G_ZERO_WEIGHTS;
           END IF;
        END IF;

     ELSE
    -- For the Weighted Measure
        FOR CD IN c_weights LOOP
          l_count := CD.C1;
        END LOOP;
        IF l_count > 0 THEN
           l_status := G_POSITIVE_WEIGHTS;
        ELSE
           FOR CD IN c_weights0 LOOP
             l_count := CD.C1;
           END LOOP;
           IF l_count > 0 THEN
             l_status := G_ZERO_WEIGHTS;
           END IF;
        END IF;
     END IF;

     RETURN l_status;

  ELSE
    RETURN NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

end get_Defined_Weights_Status;

/*******************************************************************
 *******************************************************************/
PROCEDURE Delete_Weighted_Measure_data(
  p_commit                 IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id    IN NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
) IS
 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

-- Cursor to get the Weighted Parameters associated to the Weighted Definition
 CURSOR c_WM_Definitions IS
    SELECT WEIGHTED_DEFINITION_ID
    FROM BIS_WEIGHTED_MEASURE_DEFNS
    WHERE WEIGHTED_MEASURE_ID = p_weighted_measure_id;

-- Cursor to get the Weighted Parameters associated to the Weighted Definition
 CURSOR c_WM_Dependent IS
    SELECT DEPENDENT_MEASURE_ID
    FROM BIS_WEIGHTED_MEASURE_DEPENDS
    WHERE WEIGHTED_MEASURE_ID = p_weighted_measure_id;

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Dependent Measures Cascading delete when the Weighted Measure is deleted
  FOR CD IN c_WM_Dependent LOOP
     l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
     l_Bis_WM_Rec.dependent_measure_id := CD.DEPENDENT_MEASURE_ID;
     BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Dependency(
       p_commit         => FND_API.G_FALSE
      ,p_Bis_WM_Rec     => l_Bis_WM_Rec
      ,x_Bis_WM_Rec     => x_Bis_WM_Rec
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
  END LOOP;

-- Definitions Cascading delete when the Weighted Measure is deleted
  FOR CD IN c_WM_Definitions LOOP
     l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
     l_Bis_WM_Rec.weighted_definition_id := CD.WEIGHTED_DEFINITION_ID;
     BIS_WEIGHTED_MEASURE_PUB.Delete_WM_Definition(
       p_commit         => FND_API.G_FALSE
      ,p_Bis_WM_Rec     => l_Bis_WM_Rec
      ,x_Bis_WM_Rec     => x_Bis_WM_Rec
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
  END LOOP;

 IF p_commit = FND_API.G_TRUE THEN
  COMMIT;
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
--        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
--        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_WM_Definition_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_Weighted_Measure_data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_Weighted_Measure_data ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
--        raise;
END Delete_Weighted_Measure_data;
/*******************************************************************
 *******************************************************************/

PROCEDURE Create_Weighted_Measure_data(
  p_commit                       IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id          IN NUMBER
 ,p_dependent_measure_ids        IN VARCHAR2
 ,p_viewby_dimension_short_name  IN VARCHAR2
 ,p_viewby_dim_level_short_name  IN VARCHAR2
 ,p_filter_dimension_short_name  IN VARCHAR2
 ,p_filter_dim_level_short_name  IN VARCHAR2
 ,p_time_dimension_short_name    IN VARCHAR2
 ,p_time_dim_level_short_names   IN VARCHAR2
 ,x_return_status                OUT NOCOPY VARCHAR2
 ,x_msg_count                    OUT NOCOPY NUMBER
 ,x_msg_data                     OUT NOCOPY VARCHAR2
) IS

 l_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;
 x_Bis_WM_Rec      BIS_WEIGHTED_MEASURE_PUB.Bis_WM_Rec;

 l_dependent_measure_ids       VARCHAR2(3000);
 l_dependent_measure_id        NUMBER;
 l_time_dim_level_short_names  VARCHAR2 (6000);
 l_time_dim_level_short_name   VARCHAR2 (300);
 l_count NUMBER;

BEGIN
 SAVEPOINT BisCreateWeightedMeasure;
 x_return_status :=  FND_API.G_RET_STS_SUCCESS;

-- Check if the Weighted Measure metada already exist
 SELECT COUNT(1)
   INTO l_count
 FROM BIS_WEIGHTED_MEASURE_DEFNS
 WHERE WEIGHTED_MEASURE_ID = p_weighted_measure_id;

 -- Pending to check if the Creation_By will be added to the API
 l_Bis_WM_Rec.Created_By           :=  1;

IF l_count = 0 THEN

-- Create the Definitions for each Time Dim Level
 l_time_dim_level_short_names := p_time_dim_level_short_names;
 WHILE (is_more(  p_names   =>  l_time_dim_level_short_names
                , p_name    =>  l_time_dim_level_short_name))
  LOOP

    l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
    l_Bis_WM_Rec.viewby_dimension_sn := p_viewby_dimension_short_name;
    l_Bis_WM_Rec.viewby_dim_level_sn  := p_viewby_dim_level_short_name;
    l_Bis_WM_Rec.filter_dimension_sn  := p_filter_dimension_short_name;
    l_Bis_WM_Rec.filter_dim_level_sn  := p_filter_dim_level_short_name;
    l_Bis_WM_Rec.time_dimension_short_name    := p_time_dimension_short_name;
    l_Bis_WM_Rec.time_dim_level_short_name   := l_time_dim_level_short_name;

  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.weighted_measure_id = ' || l_Bis_WM_Rec.weighted_measure_id);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.viewby_dimension_sn = ' || l_Bis_WM_Rec.viewby_dimension_sn);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.viewby_dim_level_sn = ' || l_Bis_WM_Rec.viewby_dim_level_sn);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.filter_dimension_sn = ' || l_Bis_WM_Rec.filter_dimension_sn);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.filter_dim_level_sn = ' || l_Bis_WM_Rec.filter_dim_level_sn);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.time_dimension_short_name = ' || l_Bis_WM_Rec.time_dimension_short_name);
  --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.time_dim_level_short_name = ' || l_Bis_WM_Rec.time_dim_level_short_name);

     BIS_WEIGHTED_MEASURE_PUB.Create_WM_Definition(
       p_commit         => FND_API.G_FALSE
      ,p_Bis_WM_Rec     => l_Bis_WM_Rec
      ,x_Bis_WM_Rec     => x_Bis_WM_Rec
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
  END LOOP;

-- Create the Dependencies of each dependent mesure
 l_dependent_measure_ids := p_dependent_measure_ids;
 WHILE (is_more(  p_names   =>  l_dependent_measure_ids
                , p_name    =>  l_dependent_measure_id))
  LOOP
     l_Bis_WM_Rec.weighted_measure_id := p_weighted_measure_id;
     l_Bis_WM_Rec.dependent_measure_id := l_dependent_measure_id;

   --DBMS_OUTPUT.PUT_LINE('l_Bis_WM_Rec.weighted_measure_id' || l_Bis_WM_Rec.weighted_measure_id);
   --DBMS_OUTPUT.PUT_LINE('l_dependent_measure_id = '||l_dependent_measure_id);

     BIS_WEIGHTED_MEASURE_PUB.Create_WM_Dependency(
       p_commit         => FND_API.G_FALSE
      ,p_Bis_WM_Rec     => l_Bis_WM_Rec
      ,x_Bis_WM_Rec     => x_Bis_WM_Rec
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );
  END LOOP;


ELSE
/*
  Update_Weighted_Measure_data(
      p_commit                       => p_commit
     ,p_weighted_measure_id          => p_weighted_measure_id
     ,p_dependent_measure_ids        => p_dependent_measure_ids
     ,p_viewby_dimension_short_name  => p_viewby_dimension_short_name
     ,p_viewby_dim_level_short_name  => p_viewby_dim_level_short_name
     ,p_filter_dimension_short_name  => p_filter_dimension_short_name
     ,p_filter_dim_level_short_name  => p_filter_dim_level_short_name
     ,p_time_dimension_short_name    => p_time_dimension_short_name
     ,p_time_dim_level_short_names   => p_time_dim_level_short_names
     ,x_return_status  => x_return_status
     ,x_msg_count      => x_msg_count
     ,x_msg_data       => x_msg_data
  );
*/
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END IF;

IF p_commit = FND_API.G_TRUE THEN
  COMMIT;
END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BisCreateWeightedMeasure;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
--        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BisCreateWeightedMeasure;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
--        raise;
    WHEN OTHERS THEN
        ROLLBACK TO BisCreateWeightedMeasure;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Create_Weighted_Measure_data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Create_Weighted_Measure_data ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
--        raise;
END Create_Weighted_Measure_data;

/************************************************************************************
--      API name        : Set_Weight_Data
--      Type            : Public
--      This API gets called we initially set weight for dependent measures.
--      This also gets called when we change the weights for dependent measures
--      Logic :
--         1. Get all the definition ids using the weighted_measure_id
--         2. Retrieve all the parameter ids corresponding to the definition ids
--            retrieved in step1
--         3. If the weight is non-null value update the old weight entries
--         4. If the weight is null remove the corresponding weights and score
--         5. Check if there are any parameter combinations that do not have weight
--            defined . If so create weight entries for these combinations
--            entries (Only if the weight is not null)
************************************************************************************/
PROCEDURE Set_Weight_Data(
  p_commit                  IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id     NUMBER
 ,p_dependent_measure_id    NUMBER
 ,p_weight                          NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
) IS
  l_Definition_Ids    FND_TABLE_OF_NUMBER;
  l_Param_Ids         FND_TABLE_OF_NUMBER;
  l_Insert_Param_Ids  FND_TABLE_OF_NUMBER;
  l_Update_Param_Ids  FND_TABLE_OF_NUMBER;
  l_count                   NUMBER;
  l_User_Id           NUMBER;
  l_Login_Id          NUMBER;

BEGIN
  SAVEPOINT BisSetWeightDataPUB1;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;


  -- Check that dependent measure exist
  SELECT COUNT(WEIGHTED_MEASURE_ID)
   INTO l_count
   FROM BIS_WEIGHTED_MEASURE_DEPENDS
   WHERE WEIGHTED_MEASURE_ID = p_weighted_measure_id
    AND DEPENDENT_MEASURE_ID = p_dependent_measure_id;

  IF l_count = 0 THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_WM_DEP_MEASURE_NO_FOUND');
       FND_MESSAGE.SET_TOKEN('DEP_MEASURE',p_dependent_measure_id);
       FND_MESSAGE.SET_TOKEN('MEASURE',p_weighted_measure_id);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_User_Id := FND_GLOBAL.user_id;
  l_Login_Id := FND_GLOBAL.login_id;
  -- Create the Weights for all the Definitions/Parameter

  SELECT
    defns.weighted_definition_id
  BULK COLLECT INTO
    l_Definition_Ids
  FROM
    bis_weighted_measure_defns defns
  WHERE
    defns.weighted_measure_id = p_weighted_measure_id;

  IF l_Definition_Ids.COUNT > 0 THEN
    SELECT
      params.weighted_parameter_id
    BULK COLLECT INTO
      l_Param_Ids
    FROM
      bis_weighted_measure_params params
    WHERE
      params.weighted_definition_id in (SELECT column_value FROM TABLE(CAST(l_Definition_Ids AS FND_TABLE_OF_NUMBER)));

    IF l_Param_Ids.COUNT > 0 THEN
      SELECT
        column_value
      BULK COLLECT INTO
        l_Insert_Param_Ids
      FROM
        (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER))
        MINUS
        SELECT
          weights.weighted_parameter_id
        FROM
          bis_weighted_measure_weights weights
        WHERE
          weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER))) AND
          weights.dependent_measure_id = p_dependent_measure_id);

       SELECT
         weights.weighted_parameter_id
       BULK COLLECT INTO
         l_Update_Param_Ids
       FROM
         bis_weighted_measure_weights weights
       WHERE
         weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER))) AND
         weights.dependent_measure_id = p_dependent_measure_id;

       IF l_Update_Param_Ids.COUNT > 0 THEN
         IF p_Weight IS NOT NULL THEN
           FORALL i in 1..l_Update_Param_Ids.COUNT
             UPDATE bis_weighted_measure_weights SET
               weight = p_weight
               ,last_update_date = SYSDATE
	       ,last_updated_by = l_User_Id
               ,last_update_login = l_Login_Id
             WHERE
               weighted_parameter_id = l_Update_Param_Ids(i) AND
               dependent_measure_id = p_dependent_measure_id;
          ELSE
            Delete_Bulk_Weights_Scores (
               p_commit         => FND_API.G_FALSE
              ,p_Param_Ids      => l_Update_Param_Ids
              ,p_dependent_measure_id => p_dependent_measure_id
              ,x_return_status  => x_return_status
              ,x_msg_count      => x_msg_count
              ,x_msg_data       => x_msg_data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
       END IF;

       IF p_Weight IS NOT NULL AND l_Insert_Param_Ids.COUNT > 0  THEN
         FORALL i in 1..l_Insert_Param_Ids.COUNT
           INSERT INTO bis_weighted_measure_weights(
	       weight_id
	      ,weighted_parameter_id
	      ,dependent_measure_id
	      ,weight
	      ,creation_date
	      ,created_by
	      ,last_update_date
	      ,last_updated_by
	      ,last_update_login
	  ) VALUES (
	     bis_weighted_measure_weights_s.nextval
	    ,l_Insert_Param_Ids(i)
	    ,p_dependent_measure_id
	    ,p_weight
	    ,SYSDATE
	    ,l_User_Id
	    ,SYSDATE
	    ,l_User_Id
	    ,l_Login_Id
           );
       END IF;
     END IF;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
   COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BisSetWeightDataPUB1;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
--        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BisSetWeightDataPUB1;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
--        raise;
    WHEN OTHERS THEN
        ROLLBACK TO BisSetWeightDataPUB1;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Set_Weight_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Set_Weight_Data ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
--        raise;
END Set_Weight_Data;

Procedure Set_Weights_Data(
  p_commit                          IN VARCHAR2 --:= FND_API.G_FALSE
 ,p_weighted_measure_id             IN NUMBER
 ,p_depend_measure_short_names      IN  FND_TABLE_OF_VARCHAR2_30
 ,p_weights                         IN  FND_TABLE_OF_NUMBER
 ,x_return_status                   OUT NOCOPY VARCHAR2
 ,x_msg_count                       OUT NOCOPY NUMBER
 ,x_msg_data                        OUT NOCOPY VARCHAR2
)is

l_measure_rec       BIS_Measure_PUB.Measure_Rec_Type;
l_measure_id        NUMBER;

begin

    fnd_msg_pub.initialize;

    FOR i in 1..p_depend_measure_short_names.COUNT LOOP

        l_measure_rec.measure_short_name := p_depend_measure_short_names(i);
        l_Measure_Id := BIS_Measure_PVT.Get_Measure_Id_From_Short_Name(l_measure_rec);

        Set_Weight_Data (
            p_commit => p_commit,
            p_weighted_measure_id => p_weighted_measure_id,
            p_dependent_measure_id => l_Measure_Id,
            p_weight => p_weights(i),
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

    END LOOP;

    BIS_WEIGHTED_MEASURE_PUB.Update_WM_Last_Update_Info(
       p_commit         => p_commit
      ,p_Weighted_Measure_Id     => p_weighted_measure_id
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

end Set_Weights_Data;

FUNCTION Get_Dep_KPI_Format_Mask (
  p_wkpi_id      IN          BIS_INDICATORS.INDICATOR_ID%TYPE,
  p_dep_kpi_id   IN          BIS_INDICATORS.INDICATOR_ID%TYPE
) RETURN AK_REGION_ITEMS_VL.ATTRIBUTE7%TYPE IS
  CURSOR format_mask_cur IS
    SELECT attribute7
    FROM bis_indicators wkpi, bis_indicators dkpi, ak_region_items_vl r
    WHERE wkpi.indicator_id = p_wkpi_id
    AND dkpi.indicator_id = p_dep_kpi_id
    AND BSC_BIS_MEASURE_PUB.Get_Primary_Data_Source(p_wkpi_id) = r.region_code
    AND dkpi.short_name = r.attribute2
    AND r.attribute1 IN ('MEASURE', 'MEASURE_NOTARGET');
  l_format_mask_cur format_mask_cur%ROWTYPE;

  l_format_mask AK_REGION_ITEMS_VL.ATTRIBUTE7%TYPE;
BEGIN
  OPEN format_mask_cur;
  FETCH format_mask_cur INTO l_format_mask_cur;
  IF format_mask_cur%FOUND THEN
    l_format_mask := l_format_mask_cur.attribute7;
  END IF;
  CLOSE format_mask_cur;
  RETURN l_format_mask;
EXCEPTION
  WHEN OTHERS THEN
    IF format_mask_cur%ISOPEN THEN
      CLOSE format_mask_cur;
    END IF;
    RETURN l_format_mask;
END Get_Dep_KPI_Format_Mask;


/*******************************************************************
 *******************************************************************/
PROCEDURE Update_WM_Last_Update_Info(
  p_commit          IN VARCHAR2 := FND_API.G_FALSE
 ,p_weighted_measure_id      IN NUMBER
 ,x_return_status   OUT NOCOPY VARCHAR2
 ,x_msg_count       OUT NOCOPY NUMBER
 ,x_msg_data        OUT NOCOPY VARCHAR2
) IS
BEGIN
    SAVEPOINT Update_WM_LU_Info_pub;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    BIS_WEIGHTED_MEASURE_PVT.Update_WM_Last_Update_Info(
       p_commit         => p_commit
      ,p_weighted_measure_id     => p_weighted_measure_id
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_WM_LU_Info_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_WM_LU_Info_pub;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        raise;
    WHEN OTHERS THEN
        ROLLBACK TO Update_WM_LU_Info_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Update_WM_Last_Update_Info ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Update_WM_Last_Update_Info ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        raise;
END Update_WM_Last_Update_Info;

/************************************************************************************
--	API name 	: Delete_Mass_Update_Data
--	Type		: Private
--      Deletes the old scores and the dependent information for the current
--      combinations
--      Logic :
--         1. Fetch parameter ids for all the combinations that were defined earlier
--         2. Fetch the corresponding weight ids for the current dependent measure
--         3. Delete all the weights and scores corresponding to the above weight ids
************************************************************************************/

PROCEDURE Delete_Mass_Update_Data(
  p_commit                 IN VARCHAR2 := FND_API.G_FALSE
 ,p_weighted_definition_id IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_Param_Ids     FND_TABLE_OF_NUMBER;
  l_Weight_Ids    FND_TABLE_OF_NUMBER;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT Bis_Delete_Mass_Update_Data;

  SELECT
    params.weighted_parameter_id
  BULK COLLECT INTO
    l_Param_Ids
  FROM
    bis_weighted_measure_params params,
    (SELECT
       a.column_value filter_level_value_id,
       b.column_value time_level_value_id
     FROM
       (SELECT column_value FROM TABLE(CAST(p_Selected_DimObj_Ids AS BIS_TABLE_OF_VARCHAR))) A,
       (SELECT column_value FROM TABLE(CAST(p_Selected_Period_Ids AS BIS_TABLE_OF_VARCHAR))) B) curParams
  WHERE
    params.weighted_definition_id = p_weighted_definition_id AND
    params.time_level_value_id    <>  'DEFAULT' AND
    params.filter_level_value_id  <> 'DEFAULT' AND
    params.time_level_value_id    = curParams.time_level_value_id AND
    params.filter_level_value_id  = curParams.filter_level_value_id;

  IF l_Param_Ids.COUNT > 0 THEN
    SELECT
      weights.weight_id
    BULK COLLECT INTO
      l_Weight_Ids
    FROM
      bis_weighted_measure_weights weights
    WHERE
      weights.dependent_measure_id = p_dependent_measure_id AND
      weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER)));

    IF l_Weight_Ids.COUNT > 0 THEN
      Delete_Bulk_Weights_Scores (
         p_commit         => FND_API.G_FALSE
        ,p_Param_Ids      => l_Param_Ids
        ,p_dependent_measure_id  => p_dependent_measure_id
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Bis_Delete_Mass_Update_Data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Delete_Mass_Update_Data ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Delete_Mass_Update_Data ';
    END IF;
END Delete_Mass_Update_Data;

/************************************************************************************
--	API name 	: Insert_Mass_Update_Data
--	Type		: Private
--      Saves the new scores and the dependent information
--      This API assumes that scores and weights corresponding to the parameter
--      combinations are completely deleted before calling this
--      Logic :
--         1. Finds the list of filter,time level combinations that are
--            defined for the first time.
--         2. Inserts the entries found in step1 into bis_weighted_measure_params
--         3. Fetch parameter ids for all the combinations(inserted + updated)
--         4. Fetch the default weights for the corresponding definition
--         5. For all the combinations found in Step3 insert weights
--         6. Fetch the weights ids that are defined in step5
--         7. For all those weight ids that are retrieved in step6 create scores.
************************************************************************************/

PROCEDURE Insert_Mass_Update_Data(
  p_commit                 IN VARCHAR2 := FND_API.G_FALSE
 ,p_weighted_measure_id    IN NUMBER
 ,p_weighted_definition_id IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Time_Level             IN VARCHAR2
 ,p_Filter_Level           IN VARCHAR2
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Score_Values           IN FND_TABLE_OF_NUMBER
 ,p_Lower_Ranges           IN FND_TABLE_OF_NUMBER
 ,p_Upper_Ranges           IN FND_TABLE_OF_NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_Create_Time_Values   BIS_TABLE_OF_VARCHAR;
  l_Create_Filter_Values BIS_TABLE_OF_VARCHAR;
  l_depend_Measure_Ids   FND_TABLE_OF_NUMBER;
  l_Param_Ids            FND_TABLE_OF_NUMBER;
  l_Weight_Ids           FND_TABLE_OF_NUMBER;
  l_Default_Weight       NUMBER;
  l_Count                NUMBER := 0;
  l_Is_Update            BOOLEAN;
  l_User_Id              NUMBER;
  l_Login_Id             NUMBER;
  l_Weighted_Definition_Id bis_weighted_measure_params.weighted_definition_id%type;

BEGIN

  SAVEPOINT SAVE_Insert_Mass_Update_Data;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_Count := 0;

  l_User_Id := FND_GLOBAL.user_id;
  l_Login_Id := FND_GLOBAL.login_id;


  SELECT
    *
  BULK COLLECT INTO
    l_Create_Filter_Values,
    l_Create_Time_Values
  FROM
    ( SELECT
        a.column_value filter_level_value_id,
        b.column_value time_level_value_id
      FROM
        (SELECT column_value FROM TABLE(CAST(p_Selected_DimObj_Ids AS BIS_TABLE_OF_VARCHAR))) A,
        (SELECT column_value FROM TABLE(CAST(p_Selected_Period_Ids AS BIS_TABLE_OF_VARCHAR))) B
      MINUS
      SELECT
        params.filter_level_value_id ,
        params.time_level_value_id
      FROM
        bis_weighted_measure_params params
      WHERE
        params.weighted_definition_id = p_weighted_definition_id AND
        params.time_level_value_id    <>  'DEFAULT' AND
        params.filter_level_value_id  <> 'DEFAULT') insertedParams;


  FORALL i IN 1..l_Create_Time_Values.COUNT
   INSERT INTO bis_weighted_measure_params(
        weighted_parameter_id
       ,weighted_definition_id
       ,time_level_value_id
       ,filter_level_value_id
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login
   ) VALUES (
      bis_weighted_measure_params_s.nextval
     ,p_weighted_definition_id
     ,l_Create_Time_Values(i)
     ,l_Create_Filter_Values(i)
     ,SYSDATE
     ,l_User_Id
     ,SYSDATE
     ,l_User_Id
     ,l_Login_Id
   );

  SELECT
    params.weighted_parameter_id
  BULK COLLECT INTO
    l_Param_Ids
  FROM
    bis_weighted_measure_params params,
    (SELECT
       a.column_value filter_level_value_id,
       b.column_value time_level_value_id
     FROM
       (SELECT column_value FROM TABLE(CAST(p_Selected_DimObj_Ids AS BIS_TABLE_OF_VARCHAR))) A,
       (SELECT column_value FROM TABLE(CAST(p_Selected_Period_Ids AS BIS_TABLE_OF_VARCHAR))) B) curParams
  WHERE
    params.weighted_definition_id = p_weighted_definition_id  AND
    params.time_level_value_id <>  'DEFAULT' AND
    params.filter_level_value_id <> 'DEFAULT' AND
    params.time_level_value_id    = curParams.time_level_value_id AND
    params.filter_level_value_id  = curParams.filter_level_value_id;

  SELECT
    w.weight
  INTO
    l_Default_Weight
  FROM
    bis_weighted_measure_params p,
    bis_weighted_measure_weights w
  WHERE
    p.weighted_parameter_id = w.weighted_parameter_id AND
    p.time_level_value_id = 'DEFAULT' AND
    p.filter_level_value_id = 'DEFAULT' AND
    p.weighted_definition_id = p_weighted_definition_id AND
    w.dependent_measure_id = p_dependent_measure_id;


  FORALL i IN 1..l_Param_Ids.COUNT
    INSERT INTO bis_weighted_measure_weights(
      weight_id
      , weighted_parameter_id
      , dependent_measure_id
      , weight
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
    ) VALUES (
      bis_weighted_measure_weights_s.nextval
      , l_Param_Ids(i)
      , p_dependent_measure_id
      , l_Default_Weight
      , SYSDATE
      , l_User_Id
      , SYSDATE
      , l_User_Id
      , l_Login_Id
    );

  SELECT
    weights.weight_id
  BULK COLLECT INTO
    l_Weight_Ids
  FROM
    bis_weighted_measure_weights weights
  WHERE
    weights.weighted_parameter_id IN (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER))) AND
    weights.dependent_measure_id = p_dependent_measure_id;


  FOR i in 1..p_Score_Values.COUNT LOOP
    IF (p_Lower_Ranges(i) IS NOT NULL OR p_Upper_Ranges(i) IS NOT NULL)  THEN
      FORALL j IN 1..l_Weight_Ids.COUNT
        INSERT INTO bis_weighted_measure_scores(
             weight_id
            ,low_range
            ,high_range
            ,score
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login
        ) VALUES (
           l_Weight_Ids(j)
          ,p_Lower_Ranges(i)
          ,p_Upper_Ranges(i)
          ,p_Score_Values(i)
          ,SYSDATE
          ,l_User_Id
          ,SYSDATE
          ,l_User_Id
          ,l_Login_Id
        );
   END IF;
 END LOOP;

 IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO SAVE_Insert_Mass_Update_Data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Insert_Mass_Update_Data ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Insert_Mass_Update_Data';
    END IF;
END Insert_Mass_Update_Data;

/************************************************************************************
--	API name 	: Save_Mass_Update_Values
--	Type		: Public
--      Saves the parameter combinations, corresponding weights and scores for the
--      current depdendent measure
--      Logic :
--         1. Delete the old weights,scores for the existing parameter combinations
--         2. Insert the new scores . Also inserts the weights by getting the
--            weights from the default parameter combination.
************************************************************************************/

PROCEDURE Save_Mass_Update_Values(
  p_commit                 IN VARCHAR2
 ,p_weighted_measure_id    IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Time_Level             IN VARCHAR2
 ,p_Filter_Level           IN VARCHAR2
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Score_Values           IN FND_TABLE_OF_NUMBER
 ,p_Lower_Ranges           IN FND_TABLE_OF_NUMBER
 ,p_Upper_Ranges           IN FND_TABLE_OF_NUMBER
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_Weighted_Definition_Id bis_weighted_measure_params.weighted_definition_id%type;
BEGIN

  SAVEPOINT BisSave_Mass_Update_Values_Pub;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  SELECT
    defns.weighted_definition_id
  INTO
    l_Weighted_Definition_Id
  FROM
    bis_weighted_measure_defns defns
  WHERE
    defns.weighted_measure_id = p_weighted_measure_id AND
    defns.time_dimension_short_name || '+' || defns.time_dim_level_short_name = p_Time_Level;

  Delete_Mass_Update_Data(
      p_commit                 =>  FND_API.G_FALSE
    , p_weighted_definition_id =>  l_Weighted_Definition_Id
    , p_dependent_measure_id   =>  p_dependent_measure_id
    , p_Selected_Period_Ids    =>  p_Selected_Period_Ids
    , p_Selected_DimObj_Ids    =>  p_Selected_DimObj_Ids
    , x_return_status          =>  x_return_status
    , x_msg_count              =>  x_msg_count
    , x_msg_data               =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Insert_Mass_Update_Data (
      p_commit                 =>  FND_API.G_FALSE
    , p_weighted_measure_id    =>  p_weighted_measure_id
    , p_dependent_measure_id   =>  p_dependent_measure_id
    , p_weighted_definition_id =>  l_Weighted_Definition_Id
    , p_Time_Level             =>  p_Time_Level
    , p_Filter_Level           =>  p_Filter_Level
    , p_Selected_Period_Ids    =>  p_Selected_Period_Ids
    , p_Selected_DimObj_Ids    =>  p_Selected_DimObj_Ids
    , p_Score_Values           =>  p_Score_Values
    , p_Lower_Ranges           =>  p_Lower_Ranges
    , p_Upper_Ranges           =>  p_Upper_Ranges
    , x_return_status          =>  x_return_status
    , x_msg_count              =>  x_msg_count
    , x_msg_data               =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT;
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO BisSave_Mass_Update_Values_Pub;
      IF (x_msg_data IS NULL) THEN
          FND_MSG_PUB.Count_And_Get
          (      p_encoded   =>  FND_API.G_FALSE
             ,   p_count     =>  x_msg_count
             ,   p_data      =>  x_msg_data
          );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
      ROLLBACK TO BisSave_Mass_Update_Values_Pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_msg_data IS NOT NULL) THEN
          x_msg_data      :=  x_msg_data||' -> BIS_WEIGHTED_MEASURE_PUB.Save_Mass_Update_Values ';
      ELSE
          x_msg_data      :=  SQLERRM||' at BIS_WEIGHTED_MEASURE_PUB.Save_Mass_Update_Values ';
      END IF;
END Save_Mass_Update_Values;

/************************************************************************************
--	API name 	: Validate_Overwrite_Scores
--	Type		: Public
--      Checks whether the current filter, time level combinations have scores defined
--      previously.
--      Logic :
--         1. Get all the parameter ids for filter-time combinations that were defined
--            previously
--         2. Using the parameter ids in step 1 retrieve the weight_ids
--         3. Using the weight_ids in step 2 retrieve the scores
************************************************************************************/
PROCEDURE Validate_Overwrite_Scores(
  p_weighted_measure_id    IN NUMBER
 ,p_dependent_measure_id   IN NUMBER
 ,p_Selected_Period_Ids    IN BIS_TABLE_OF_VARCHAR
 ,p_Selected_DimObj_Ids    IN BIS_TABLE_OF_VARCHAR
 ,x_Param_Count            OUT NOCOPY NUMBER
) IS

  l_Param_Ids FND_TABLE_OF_NUMBER;

BEGIN
  SELECT
    params.weighted_parameter_id
  BULK COLLECT INTO
    l_Param_Ids
  FROM
    bis_weighted_measure_params params,
    bis_weighted_measure_defns  defns,
    (SELECT
       a.column_value filter_level_value_id,
       b.column_value time_level_value_id
     FROM
       (SELECT column_value FROM TABLE(CAST(p_Selected_DimObj_Ids AS BIS_TABLE_OF_VARCHAR))) A,
       (SELECT column_value FROM TABLE(CAST(p_Selected_Period_Ids AS BIS_TABLE_OF_VARCHAR))) B) curParams
  WHERE
    defns.weighted_measure_id = p_weighted_measure_id AND
    params.weighted_definition_id = defns.weighted_definition_id  AND
    params.time_level_value_id <>  'DEFAULT' AND
    params.filter_level_value_id <> 'DEFAULT' AND
    params.time_level_value_id    = curParams.time_level_value_id AND
    params.filter_level_value_id  = curParams.filter_level_value_id;

  IF l_Param_Ids.COUNT > 0 THEN
   SELECT
     COUNT(1)
   INTO
     x_Param_Count
   FROM
     bis_weighted_measure_scores a,
     bis_weighted_measure_weights b
   WHERE
     a.weight_id = b.weight_id AND
     b.weighted_parameter_id in (SELECT column_value FROM TABLE(CAST(l_Param_Ids AS FND_TABLE_OF_NUMBER))) AND
     b.dependent_measure_id = p_dependent_measure_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_Param_Count := 0;
END Validate_Overwrite_Scores;

END BIS_WEIGHTED_MEASURE_PUB;

/

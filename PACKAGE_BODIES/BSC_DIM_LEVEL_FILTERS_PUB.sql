--------------------------------------------------------
--  DDL for Package Body BSC_DIM_LEVEL_FILTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIM_LEVEL_FILTERS_PUB" AS
/* $Header: BSCPFILB.pls 120.5 2007/12/21 09:14:40 psomesul noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPFILB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package handle Common Dimension Level for Scorecards |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION |
REM |                     FILTERS TO SCORECARD DESIGNER                     |
REM | 27-Mar-07 psomesul B#5901412-Open issues of enh no. 5678943           |
REM | 08-MAY-07 ashankar Bug#5954327 Fixed numeric or value error:          |
REM | 07-JUN-07 psomesul Bug#6116585 UNABLE TO ENABLE FILTER WITH KEY ITEM  |
REM |                              DEFINED FOR MORE THAN 1 DIM OBJ          |
REM | 05-JUN-07 ashankar Bug#5938321 Fixed the issues related to list button|
REM |                    security                                           |
REM | 07-NOV-07 psomesul Bug#6375565 Handling Filters for MxM dimension objects|
REM +=======================================================================+
*/


PROCEDURE Validate_List_Button_Security
(
  p_tab_id                 IN             NUMBER
 ,p_dim_level_id           IN             NUMBER
 ,p_level_vals_list        IN             VARCHAR2
 ,x_return_status          OUT   NOCOPY   VARCHAR2
 ,x_msg_count              OUT   NOCOPY   NUMBER
 ,x_msg_data               OUT   NOCOPY   VARCHAR2
)IS

 CURSOR c_security IS
 SELECT DISTINCT a.tab_id,
        a.dim_level_index,
        a.dim_level_value,
        b.dim_level_id,
        (SELECT level_view_name FROM bsc_sys_dim_levels_b WHERE dim_level_id =b.dim_level_id)level_view_name
  FROM  bsc_user_list_access a,
        bsc_sys_com_dim_levels b
  WHERE a.tab_id =b.tab_id
  AND   a.dim_level_index= b.dim_level_index
  AND   a.tab_id =p_tab_id
  AND   a.dim_level_value <>0
  AND   b.dim_level_id = p_dim_level_id
  ORDER BY A.dim_level_value;

  l_level_vals_list   VARCHAR2(30000);
  l_found             VARCHAR2(2);
  l_level_val         VARCHAR2(100);
  l_level_value       NUMBER;
  l_dim_val           VARCHAR2(1000);


BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF(p_level_vals_list IS NOT NULL AND p_tab_id IS NOT NULL
      AND p_dim_level_id IS NOT NULL) THEN
    FOR cd IN c_security LOOP
       l_found := FND_API.G_FALSE;
       l_level_vals_list := p_level_vals_list;

       IF(cd.dim_level_id =p_dim_level_id ) THEN
         WHILE (BSC_UTILITY.is_more
                (   p_comma_sep_values => l_level_vals_list
                  , x_value            => l_level_val
                )
               ) LOOP
            l_level_value := TO_NUMBER(RTRIM(LTRIM(l_level_val)));
            IF (l_level_value = cd.dim_level_value) THEN
              l_found := FND_API.G_TRUE;
            END IF;
          END LOOP;
          IF(l_found=FND_API.G_FALSE)THEN
            l_dim_val := BSC_DEFAULT_KEY_ITEM_PUB.get_table_column_value(cd.level_view_name, 'NAME', 'CODE=' || cd.dim_level_value);
            FND_MESSAGE.SET_NAME('BSC','BSC_LIST_SECURITY_ERROR');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_dim_val, TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    END LOOP;
  END IF;

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

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.Validate_List_Button_Security ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.Validate_List_Button_Security ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.Validate_List_Button_Security ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.Validate_List_Button_Security ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Validate_List_Button_Security;

-----------------------------------------------------------------------------
-- The following API saves the filter values for a dimension object
-- of a scorecard (tab).
-- Input :
--    p_tab_id
--    p_dim_level_id
--    p_level_vals_list        A comma seperated list of dim level value IDs.
-----------------------------------------------------------------------------

PROCEDURE save_filter
(p_tab_id                 IN                 NUMBER
,p_dim_level_id           IN                 NUMBER
,p_level_vals_list        IN  OUT NOCOPY     VARCHAR2
,p_mismatch_keyitems      OUT     NOCOPY     VARCHAR2
,p_commit                 IN                 VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT     NOCOPY     VARCHAR2
,x_msg_count              OUT     NOCOPY     NUMBER
,x_msg_data               OUT     NOCOPY     VARCHAR2
) IS

  l_filter_count           NUMBER;
  l_level_val              VARCHAR2(100);
  l_level_value            NUMBER;
  l_sql                    VARCHAR2(500);
  l_key_item_recs          BSC_UTILITY.varchar_tabletype;
  l_key_item_cnt           NUMBER;
  l_key_item_props_recs    BSC_UTILITY.varchar_tabletype;
  l_key_item_props_cnt     NUMBER;
  l_key_name               VARCHAR2(100);
  l_dim_level_view         VARCHAR2(100);
  l_key_item               NUMBER;

BEGIN
   SAVEPOINT bscpfdlb_savepoint_save_filter;
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF (p_dim_level_id is null OR p_tab_id IS NULL) THEN
      RETURN;
   END IF;

   p_mismatch_keyitems := NULL;

   -- we will check the filter values

     Validate_List_Button_Security
     (
       p_tab_id          => p_tab_id
      ,p_dim_level_id    => p_dim_level_id
      ,p_level_vals_list => p_level_vals_list
      ,x_return_status   => x_return_status
      ,x_msg_count       => x_msg_count
      ,x_msg_data        => x_msg_data
     );

     IF(x_return_status IS NOT NULL AND x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      RETURN;
     END IF;

   --      BSC_DIM_LEVEL_FILTERS_PUB.check_key_values(
   validate_key_items(
                        p_tab_id             => p_tab_id
                       ,p_dim_level_id       => p_dim_level_id
                       ,p_level_vals_list    => p_level_vals_list
                       ,p_mismatch_key_items => p_mismatch_keyitems
                       ,x_return_status      => x_return_status
                       ,x_msg_count          => x_msg_count
                       ,x_msg_data           => x_msg_data
                );
   IF (p_mismatch_keyitems IS NOT NULL) THEN
     RETURN;
   END IF;

   --Delete filter values already existing before inserting new values
   BSC_DIM_LEVEL_FILTERS_PVT.delete_filters(
                      p_tab_id         =>   p_tab_id
                     ,p_dim_level_id   =>   p_dim_level_id
                     ,p_commit         =>   FND_API.G_FALSE
                     ,x_return_status  =>   x_return_status
                     ,x_msg_count      =>   x_msg_count
                     ,x_msg_data       =>   x_msg_data
                     );
--   DELETE    FROM bsc_sys_filters    WHERE source_type = 1     AND source_code = p_tab_id     AND dim_level_id = p_dim_level_id;
   -- INSERT all filter values in bsc_sys_filters
   IF (p_level_vals_list IS NOT NULL) THEN   --p_level_vals_list contains a comma seperated values of dim level values
     WHILE (BSC_UTILITY.is_more(p_comma_sep_values => p_level_vals_list, x_value => l_level_val)) LOOP
       l_level_value := TO_NUMBER(RTRIM(LTRIM(l_level_val)));
       BSC_DIM_LEVEL_FILTERS_PVT.insert_filters(
                     p_source_type     =>   1
                    ,p_source_code     =>   p_tab_id
                    ,p_dim_level_id    =>   p_dim_level_id
                    ,p_dim_level_value =>   l_level_value
                    ,p_commit          =>   FND_API.G_FALSE
                    ,x_return_status   =>   x_return_status
                    ,x_msg_count       =>   x_msg_count
                    ,x_msg_data        =>   x_msg_data
                    );
--       INSERT INTO bsc_sys_filters(source_type,source_code, dim_level_id,dim_level_value) VALUES (1,p_tab_id ,p_dim_level_id, l_level_value );
     END LOOP;

     --INSERT 'ALL' value also.
     BSC_DIM_LEVEL_FILTERS_PVT.insert_filters(
                     p_source_type     =>   1
                    ,p_source_code     =>   p_tab_id
                    ,p_dim_level_id    =>   p_dim_level_id
                    ,p_dim_level_value =>   0
                    ,p_commit          =>   FND_API.G_FALSE
                    ,x_return_status   =>   x_return_status
                    ,x_msg_count       =>   x_msg_count
                    ,x_msg_data        =>   x_msg_data
                    );
     --INSERT INTO bsc_sys_filters(source_type, source_code, dim_level_id,dim_level_value) VALUES (1,p_tab_id , p_dim_level_id, 0);
   END IF;

   --Validate and rebuild level values VIEW definition and validate each child dimension object
   BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view(
                         p_tab_id        => p_tab_id
                        ,p_dim_level_id  => p_dim_level_id
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                         );
   BSC_DIM_FILTERS_PVT.Synch_Fiters_And_Kpi_Dim(
                         p_tab_id        =>  p_tab_id
                        ,x_return_status =>  x_return_status
                        ,x_msg_count     =>  x_msg_count
                        ,x_msg_data      =>  x_msg_data
                       );

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     BSC_DIM_LEVEL_FILTERS_PUB.update_tab_who_columns(
                         p_tab_id        =>   p_tab_id
                        ,x_return_status =>   x_return_status
                        ,x_msg_count     =>   x_msg_count
                        ,x_msg_data      =>   x_msg_data
                      );
   END IF;
--   BSC_DIM_FILTERS_PUB.validate_key_item_filter
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bscpfdlb_savepoint_save_filter;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bscpfdlb_savepoint_save_filter;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        RAISE;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO bscpfdlb_savepoint_save_filter;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_FILTERS_PUB.save_filter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_FILTERS_PUB.save_filter ';
        END IF;

        RAISE;

    WHEN OTHERS THEN
        ROLLBACK TO bscpfdlb_savepoint_save_filter;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_FILTERS_PUB.save_filter ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_FILTERS_PUB.save_filter ';
        END IF;
        RAISE;

END save_filter;



-- The following is a recrusive procedure that create/recreate filter views
-- For each child dimension object this api is called recrursively.


PROCEDURE process_filter_view
(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
) IS

 l_view               VARCHAR2(1000);
 l_filter_count       NUMBER;
 l_need_view          BOOLEAN;

 CURSOR c_parents IS
   SELECT a.dim_level_id, a.parent_dim_level_id,  a.relation_col,
     (SELECT b.name FROM bsc_sys_dim_levels_vl b WHERE b.dim_level_id = a.parent_dim_level_id) parent_name,
     (SELECT c.level_view_name FROM bsc_sys_filters_views c WHERE a.parent_dim_level_id = c.dim_level_id AND c.source_type= 1
             AND rownum <2 AND c.source_code=p_tab_id) parent_filter_view
   FROM bsc_sys_dim_level_rels a
   WHERE a.dim_level_id = p_dim_level_id
     AND a.relation_type=1
     AND a.dim_level_id IN
        (SELECT dim_level_id
         FROM bsc_kpi_dim_level_properties WHERE indicator IN
             (SELECT indicator FROM bsc_tab_indicators WHERE tab_id = p_tab_id));

 CURSOR c_childs IS
   SELECT a.dim_level_id child_dim_level_id
   FROM bsc_sys_dim_level_rels a
   WHERE a.parent_dim_level_id = p_dim_level_id
     AND a.relation_type=1
     AND a.dim_level_id IN
        (SELECT dim_level_id
         FROM bsc_kpi_dim_level_properties WHERE indicator IN
             (SELECT indicator FROM bsc_tab_indicators WHERE tab_id = p_tab_id));

 CURSOR c_fil_view IS
   SELECT level_view_name
   FROM bsc_sys_filters_views
   WHERE source_type = 1
       AND source_code = p_tab_id
       AND dim_level_id = p_dim_level_id;

 CURSOR c_tab_kpis IS
   SELECT DISTINCT kpi_measure_id, indicator
   FROM bsc_kpi_analysis_measures_b
   WHERE indicator IN (SELECT DISTINCT ti.indicator
                       FROM bsc_tab_indicators ti
                       WHERE ti.tab_id = p_tab_id);

BEGIN

   IF ( p_dim_level_id IS NULL OR p_tab_id IS NULL) THEN
     RETURN;
   END IF;

   SELECT COUNT(0) INTO  l_filter_count
   FROM bsc_sys_filters
   WHERE source_type = 1
     AND source_code=p_tab_id
     AND dim_level_id = p_dim_level_id;



   IF (l_filter_count > 0) THEN
     l_need_view := TRUE;
   ELSE
     FOR cd IN c_parents LOOP    -- Check for parent's filter view
       IF (cd.parent_filter_view IS NOT NULL) THEN
         l_need_view := TRUE;
       END IF;
     END LOOP;
   END IF;

   FOR cd IN c_fil_view LOOP
     l_view := cd.level_view_name;
     EXIT;
   END LOOP;

   IF (l_need_view) THEN
      BSC_DIM_LEVEL_FILTERS_PUB.create_filter_view(
                  p_tab_id           =>  p_tab_id
                , p_dim_level_id     =>  p_dim_level_id
                , p_commit           =>  p_commit
                , x_return_status    =>  x_return_status
                , x_msg_count        =>  x_msg_count
                , x_msg_data         =>  x_msg_data
              );
   ELSE  -- NO FILTERS SHOULD BE PRESENT
     IF (l_view IS NOT NULL) THEN

       EXECUTE IMMEDIATE ('DROP VIEW ' || l_view);  --DROP FILTER VIEW

       --DELETE entry from bsc_sys_filters_views
       BSC_DIM_LEVEL_FILTERS_PVT.delete_filters_view (
                      p_tab_id         =>   p_tab_id
                     ,p_dim_level_id   =>   p_dim_level_id
                     ,p_commit         =>   FND_API.G_FALSE
                     ,x_return_status  =>   x_return_status
                     ,x_msg_count      =>   x_msg_count
                     ,x_msg_data       =>   x_msg_data
                     );
       --DELETE FROM bsc_sys_filters_views WHERE source_type=1 AND source_code = p_tab_id AND dim_level_id = p_dim_level_id;

       --DELTER entry from bsc_sys_filters
       BSC_DIM_LEVEL_FILTERS_PVT.delete_filters (
                      p_tab_id         =>   p_tab_id
                     ,p_dim_level_id   =>   p_dim_level_id
                     ,p_commit         =>   FND_API.G_FALSE
                     ,x_return_status  =>   x_return_status
                     ,x_msg_count      =>   x_msg_count
                     ,x_msg_data       =>   x_msg_data
                     );
--       DELETE FROM bsc_sys_filters WHERE source_type=1 AND source_code = p_tab_id AND dim_level_id = p_dim_level_id;

     END IF;
   END IF;
   BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag(
                p_prototype_flag  =>   6,
                p_tab_id          =>   p_tab_id,
                p_dim_level_id    =>   p_dim_level_id,
                p_commit          =>   p_commit,
                x_return_status   =>   x_return_status,
                x_msg_count       =>   x_msg_count,
                x_msg_data        =>   x_msg_data
                 );
    FOR cd IN c_tab_kpis LOOP

       IF (cd.indicator IS NOT NULL AND cd.kpi_measure_id IS NOT NULL) THEN
                  BSC_KPI_COLOR_PROPERTIES_PUB.Change_Prototype_Flag
                  (  p_objective_id    =>  cd.indicator
                   , p_kpi_measure_id  =>  cd.kpi_measure_id
                   , p_prototype_flag  =>  7
                   , x_return_status   =>  x_return_status
                   , x_msg_count       =>  x_msg_count
                   , x_msg_data        =>  x_msg_data
                  );
       END IF;
    END LOOP;



   FOR cd  IN c_childs LOOP
     IF (l_need_view) THEN
       BSC_DIM_LEVEL_FILTERS_PUB.del_filters_not_applicable(
                p_tab_id          =>   p_tab_id,
                p_ch_level_id     =>   cd.child_dim_level_id,
                p_pa_level_id     =>   p_dim_level_id,
                p_commit          =>   p_commit,
                x_return_status   =>   x_return_status,
                x_msg_count       =>   x_msg_count,
                x_msg_data        =>   x_msg_data
              );
     END IF;

     --RECURSIVE CALL TO PROCESS THE CHILD
     BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view(
                    p_tab_id        =>  p_tab_id,
                    p_dim_level_id  =>  cd.child_dim_level_id,
                    x_return_status =>  x_return_status,
                    x_msg_count     =>  x_msg_count,
                    x_msg_data      =>  x_msg_data
                  );
   END LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view ';
        END IF;

        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.process_filter_view ';
        END IF;
        RAISE;
END process_filter_view;





-- The following API creates filter view and updates bsc_sys_filter_views

PROCEDURE create_filter_view
(
  p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
) IS

 l_sql                VARCHAR2(3000);
 l_table              VARCHAR2(100);
 l_filter_count       NUMBER;
 l_view               VARCHAR2(100);
 l_sql_tables         VARCHAR2(3000);
 l_sql_where_cond     VARCHAR2(3000);
 l_view_name          VARCHAR2(100);
 l_cnt                NUMBER;

 CURSOR c_parents IS
   SELECT a.dim_level_id, a.parent_dim_level_id,  a.relation_col,
     (SELECT b.name FROM bsc_sys_dim_levels_vl b WHERE b.dim_level_id = a.parent_dim_level_id) parent_name,
     (SELECT c.level_view_name FROM bsc_sys_filters_views c WHERE a.parent_dim_level_id = c.dim_level_id AND c.source_type= 1
             AND rownum <2 AND c.source_code=p_tab_id) parent_filter_view
   FROM bsc_sys_dim_level_rels a
   WHERE a.dim_level_id = p_dim_level_id
     AND a.relation_type=1;

 CURSOR c_fil_view IS
   SELECT level_view_name
   FROM bsc_sys_filters_views
   WHERE source_type = 1
     AND source_code = p_tab_id
     AND dim_level_id = p_dim_level_id;

 CURSOR c_dim_table IS
   SELECT level_table_name
   FROM bsc_sys_dim_levels_b
   WHERE dim_level_id = p_dim_level_id;

 CURSOR c_dim_view IS
   SELECT level_view_name
   FROM bsc_sys_dim_levels_b
   WHERE dim_level_id = p_dim_level_id;

BEGIN

  FOR cd IN c_fil_view LOOP
    l_view := cd.level_view_name;
    EXIT;
  END LOOP;

  IF (l_view is NULL) THEN   --CREATE NEW FILTER VIEW
    FOR cd IN c_dim_table LOOP
      l_table := cd.level_table_name;
      EXIT;
    END LOOP;

    IF (l_table is NULL) THEN
      RETURN;
    END IF;

    l_view := BSC_DIM_LEVEL_FILTERS_PUB.get_new_filter_view_name(
             p_dimension_table =>  l_table,
             x_return_status   =>  x_return_status,
             x_msg_count       =>  x_msg_count,
             x_msg_data        =>  x_msg_data
             );  --TODO :: USE PACKAGE_NAME.FUNCTION_NAME

    BSC_DIM_LEVEL_FILTERS_PVT.insert_filters_view(
        p_source_type        =>  1
       ,p_source_code        =>  p_tab_id
       ,p_dim_level_id       =>  p_dim_level_id
       ,p_level_table_name   =>  l_table
       ,p_level_view_name    =>  l_view
       ,p_commit             =>  FND_API.G_FALSE
       ,x_return_status      =>  x_return_status
       ,x_msg_count          =>  x_msg_count
       ,x_msg_data           =>  x_msg_data
       );
    ---INSERT INTO bsc_sys_filters_views(source_type, source_code, dim_level_id, level_table_name, level_view_name) VALUES (1, p_tab_id, p_dim_level_id, l_table,l_view);
  END IF;

  FOR cd IN c_dim_view LOOP
    l_view_name := cd.level_view_name;
    EXIT;
  END LOOP;


  SELECT COUNT(0) INTO l_filter_count
  FROM bsc_sys_filters
  WHERE source_type= 1
    AND source_code = p_tab_id
    AND dim_level_id = p_dim_level_id;


  IF (l_filter_count > 0) THEN
    l_sql_tables :=   'bsc_sys_filters f, ' ||  l_view_name || ' d ';
    l_sql_where_cond := ' f.source_type=1 AND f.source_code=' || p_tab_id || ' AND f.dim_level_id=' || p_dim_level_id || ' AND f.dim_level_value=d.code';

  ELSE
    l_cnt := 0;
    l_sql_tables := ' ' || l_view_name || ' d ';

    FOR cd IN c_parents LOOP
      l_cnt := l_cnt + 1;
      IF (cd.parent_filter_view IS NOT NULL AND CD.relation_col IS NOT NULL ) THEN
        l_sql_tables := l_sql_tables || ' , ' || cd.parent_filter_view  || ' p' || l_cnt;
        l_sql_where_cond := l_sql_where_cond || ' AND ' || ' d.' || cd.relation_col || '=p' || l_cnt || '.code';
      END IF;
    END LOOP;

    IF (l_sql_where_cond IS NOT NULL) THEN
      l_sql_where_cond := SUBSTR(l_sql_where_cond, 6);  --REMOVE extra AND at the beginning of the where clause
    END IF;
  END IF;


  l_cnt := 0;
  SELECT COUNT(0) INTO l_cnt
  FROM user_objects
  WHERE object_name = l_view;


  IF (l_cnt <> 0) THEN
    EXECUTE IMMEDIATE ('DROP VIEW ' || l_view);
  END IF;

  l_sql := 'CREATE VIEW ' || l_view || ' AS (SELECT d.* FROM ' || l_sql_tables || ' WHERE ' || l_sql_where_cond || ')';
  EXECUTE IMMEDIATE l_sql;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN


        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.create_filter_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.create_filter_view ';
        END IF;

        RAISE;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.create_filter_view ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.create_filter_view ';
        END IF;
        RAISE;

END create_filter_view;



-- The following API returns a unique view name that is not existing.
-- INPUT:
--     p_dimension_table     This is dimension object table name



FUNCTION get_new_filter_view_name(
  p_dimension_table        IN             VARCHAR2
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
)
RETURN VARCHAR2
IS

  l_result          VARCHAR2(100);
  l_view_count      NUMBER;
  l_v_count         NUMBER;
  l_where_condition VARCHAR2(100);

BEGIN
  IF (p_dimension_table IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT COUNT(DISTINCT object_name) INTO l_view_count
  FROM user_objects
  WHERE object_name like p_dimension_table || '_V%';


  l_view_count := l_view_count+1;
  l_result := p_dimension_table || '_V' || l_view_count;


  WHILE TRUE LOOP
    SELECT COUNT(0) INTO l_v_count
    FROM user_objects
    WHERE object_name = l_result;

    EXIT WHEN l_v_count = 0;

    l_view_count := l_view_count +1;
    l_result := p_dimension_table || '_V' || l_view_count;
  END LOOP;

  RETURN l_result;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_new_filter_view_name ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_new_filter_view_name ';
        END IF;

        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_new_filter_view_name ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_new_filter_view_name ';
        END IF;
        RAISE;
END get_new_filter_view_name;



--   The following api builds SQL to retrieve dim level values
--   that can be filtered.
--   This api is called from UI, to build filter values VO dynamically.


PROCEDURE get_filter_dimension_SQL
( p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, x_sql                    OUT NOCOPY     VARCHAR2
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
)
IS

CURSOR c_parents IS
   SELECT a.dim_level_id, a.parent_dim_level_id,  a.relation_col,
     (SELECT b.name FROM bsc_sys_dim_levels_vl b WHERE b.dim_level_id = a.parent_dim_level_id) parent_name,
     (SELECT c.level_view_name FROM bsc_sys_filters_views c WHERE a.parent_dim_level_id = c.dim_level_id AND c.source_type= 1
             AND rownum <2 AND c.source_code=p_tab_id) parent_filter_view
   FROM bsc_sys_dim_level_rels a
   WHERE a.dim_level_id = p_dim_level_id AND a.relation_type=1 ;

CURSOR c_dim_view IS
   SELECT level_view_name
   FROM bsc_sys_dim_levels_b
   WHERE dim_level_id = p_dim_level_id;

 l_rel_col         VARCHAR2(100);
 l_sql_tables      VARCHAR2(1000);
 l_sql_where_cond  VARCHAR2(3000);
 l_index           NUMBER;
 l_view_count      NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;


  IF (p_tab_id is NOT NULL AND p_dim_level_id IS NOT NULL) THEN

    FOR cd IN c_dim_view LOOP
       l_sql_tables := cd.level_view_name;
    END LOOP;

    IF (l_sql_tables IS NOT NULL) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_sql_tables := l_sql_tables || ' d ';
      l_sql_where_cond := ' d.code <> 0';
      l_index := 0;

      FOR cd IN c_parents LOOP
        IF (cd.relation_col IS NOT NULL AND cd.parent_filter_view IS NOT NULL) THEN

            BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views(
                           p_source          =>   p_tab_id,
                           p_level_view_name =>   cd.parent_filter_view,
                           p_dim_level_id    =>   cd.parent_dim_level_id,
                           x_return_status   =>   x_return_status,
                           x_msg_count       =>   x_msg_count,
                           x_msg_data        =>   x_msg_data
                           );

            l_index := l_index + 1;
            l_sql_tables := l_sql_tables || ' , ' || cd.parent_filter_view || ' p' || l_index ;
            l_sql_where_cond := l_sql_where_cond || ' AND d.' || cd.relation_col || ' = p' || l_index || '.code';

        END IF;
      END LOOP;

      x_sql := 'SELECT TO_CHAR(d.code) ID, d.name VALUE FROM ' || l_sql_tables || ' WHERE ' || l_sql_where_cond || ' ORDER BY VALUE ';

      EXECUTE IMMEDIATE x_sql;

    END IF;
  END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_sql := NULL;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sql := NULL;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_filter_dimension_SQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_filter_dimension_SQL ';
        END IF;
        x_sql := NULL;
        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_filter_dimension_SQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_filter_dimension_SQL ';
        END IF;
        x_sql := NULL;
        RAISE;

END get_filter_dimension_SQL;


-- The following API returns a SQL to retrieve filtered dim level values.
-- This api is called from UI to build VO dynamically.

PROCEDURE get_filtered_dim_values_SQL
( p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, x_sql                    OUT NOCOPY     VARCHAR2
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
)
IS

CURSOR c_filter_view IS
   SELECT level_view_name
   FROM bsc_sys_filters_views
   WHERE source_type=1
     AND source_code = p_tab_id
     AND dim_level_id = p_dim_level_id;

 l_rel_col         VARCHAR2(100);
 l_sql_view      VARCHAR2(1000);
 l_sql_where_cond  VARCHAR2(3000);
 l_index           NUMBER;
 l_view_count      NUMBER;
 l_dummy_sql       VARCHAR2(100);

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- The following is a dummy SQL that returns no rows.
  l_dummy_sql := 'SELECT NULL ID, NULL VALUE FROM DUAL WHERE ROWNUM<1';

  IF (p_tab_id is NOT NULL AND p_dim_level_id IS NOT NULL) THEN

    FOR cd IN c_filter_view LOOP
       l_sql_view := cd.level_view_name;
       EXIT;
    END LOOP;


    IF (l_sql_view IS NOT NULL) THEN
      BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views(
                           p_source          =>   p_tab_id,
                           p_level_view_name =>   l_sql_view,
                           p_dim_level_id    =>   p_dim_level_id,
                           x_return_status   =>   x_return_status,
                           x_msg_count       =>   x_msg_count,
                           x_msg_data        =>   x_msg_data
                           );


      x_sql := 'SELECT TO_CHAR(f.dim_level_value) ID, ';
      x_sql := x_sql || '(SELECT v.name FROM ' || l_sql_view || ' v ';
      x_sql := x_sql || ' WHERE v.code=f.dim_level_value and rownum < 2 ) VALUE ';
      x_sql := x_sql || ' FROM bsc_sys_filters f WHERE f.source_type=1 AND f.source_code=';
      x_sql := x_sql || p_tab_id ||  ' AND f.dim_level_id=' || p_dim_level_id || ' AND f.dim_level_value <> 0';
      x_sql := x_sql || ' ORDER BY VALUE ';

    ELSE
      x_sql := l_dummy_sql;
    END IF;
  ELSE
     x_sql := l_dummy_sql;
  END IF;

  EXECUTE IMMEDIATE x_sql;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_sql := l_dummy_sql;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_sql := l_dummy_sql;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_filtered_dim_values_SQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_filtered_dim_values_SQL ';
        END IF;
        x_sql := l_dummy_sql;
        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.get_filtered_dim_values_SQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.get_filtered_dim_values_SQL ';
        END IF;
        x_sql := l_dummy_sql;
        RAISE;

END get_filtered_dim_values_SQL;





-- The follwoing API deletes unmatched child dimension object filter values
-- that are not matching with the filter values defined for the parent.
-- INPUT :
--      p_ch_level_id    Dimension Object (dim level) id of child dimension object
--      p_pa_level_id    Dimension Object (dim level) id of parent dimension object


PROCEDURE del_filters_not_applicable(
 p_tab_id                 IN             NUMBER
,p_ch_level_id            IN             NUMBER
,p_pa_level_id            IN             NUMBER
,p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
) IS

l_ch_view                       VARCHAR2(100);
l_pa_view                       VARCHAR2(100);
l_filter_count                  NUMBER;
l_row_count                     NUMBER;
l_rel_col                       VARCHAR2(100);
l_cur_sql                       VARCHAR2(1000);
l_code                          NUMBER;
TYPE ref_cursor                 IS REF CURSOR;
ref_cur                         ref_cursor;

CURSOR c_ch_dim_view IS
  SELECT level_view_name
     FROM bsc_sys_filters_views
     WHERE source_type = 1
       AND source_code = p_tab_id
       AND dim_level_id = p_ch_level_id;

CURSOR c_pa_dim_view IS
  SELECT level_view_name
  FROM bsc_sys_filters_views
  WHERE source_type = 1
    AND source_code = p_tab_id
    AND dim_level_id = p_pa_level_id;

CURSOR c_rel_col is
  SELECT relation_col
  FROM bsc_sys_dim_level_rels
  WHERE dim_level_id = p_ch_level_id AND parent_dim_level_id = p_pa_level_id;

BEGIN

  FOR cd IN c_ch_dim_view LOOP
    l_ch_view:=cd.level_view_name;
    EXIT;
  END LOOP;

  FOR cd IN c_pa_dim_view LOOP
    l_pa_view:=cd.level_view_name;
    EXIT;
  END LOOP;

  IF (l_ch_view IS NOT NULL AND l_pa_view IS NOT NULL) THEN
     -- TODO : the following api should be replaced with existig Verify_Recreate_Filter_View() API in BSCRPMDB.pls
     -- Verify_Recreate_Filter_View() is present in BSCRPMDB.pls but not included in the spec.

     BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views(
                                p_source          =>     p_tab_id,
                                p_level_view_name =>     l_ch_view,
                                p_dim_level_id    =>     p_ch_level_id,
                                x_return_status   =>     x_return_status,
                                x_msg_count       =>     x_msg_count,
                                x_msg_data        =>     x_msg_data
                                  );
     BSC_BIS_DIM_REL_PUB.Verify_Recreate_Filter_Views(
                                p_source          =>     p_tab_id,
                                p_level_view_name =>     l_pa_view,
                                p_dim_level_id    =>     p_pa_level_id,
                                x_return_status   =>     x_return_status,
                                x_msg_count       =>     x_msg_count,
                                x_msg_data        =>     x_msg_data
                                  );
    FOR cd IN c_rel_col LOOP
      l_rel_col := cd.relation_col;
      EXIT;
    END LOOP;



    IF (l_rel_col IS NOT NULL) THEN
      l_cur_sql := 'SELECT d.code FROM ' || l_ch_view || ' d, ' || l_pa_view || ' p WHERE d.' || l_rel_col || '=p.code(+) AND p.code IS NULL';

      IF (ref_cur%ISOPEN) THEN
         CLOSE ref_cur;
      END IF;

      OPEN ref_cur FOR l_cur_sql;

      l_row_count := ref_cur%ROWCOUNT;

      SELECT COUNT(0) INTO l_filter_count
      FROM bsc_sys_filters
      WHERE source_type= 1
        AND source_code = p_tab_id
        AND dim_level_id = p_ch_level_id;

      IF (l_row_count >= l_filter_count - 1) THEN  -- Unmatched filter values present in the child
         DELETE
         FROM bsc_sys_filters
         WHERE source_type = 1
           AND source_code = p_tab_id
           AND dim_level_id = p_ch_level_id;

      ELSE
        LOOP

          FETCH ref_cur INTO l_code;
          EXIT WHEN ref_cur%NOTFOUND;

          IF (l_code IS NOT NULL) THEN

            DELETE
            FROM bsc_sys_filters
            WHERE source_type = 1
              AND source_code = p_tab_id
              AND dim_level_id = p_ch_level_id
              AND dim_level_value = l_code;

          END IF;
        END LOOP;
      END IF;

      IF (ref_cur%ISOPEN) THEN
         CLOSE ref_cur;
      END IF;

      SELECT COUNT(0) INTO l_filter_count
      FROM bsc_sys_filters
      WHERE source_type= 1
        AND source_code = p_tab_id
        AND dim_level_id = p_ch_level_id;

      IF (l_filter_count = 1) THEN

        DELETE
        FROM bsc_sys_filters
        WHERE source_type = 1
          AND source_code = p_tab_id
          AND dim_level_id = p_ch_level_id;
      END IF;
    END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;

        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.del_filters_not_applicable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.del_filters_not_applicable ';
        END IF;
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.del_filters_not_applicable ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.del_filters_not_applicable ';
        END IF;
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        RAISE;

END del_filters_not_applicable;


----------------------------------------------------------------------------

PROCEDURE update_tab_who_columns
(
 p_tab_id               IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT       NOCOPY VARCHAR2
,x_msg_count            OUT       NOCOPY NUMBER
,x_msg_data             OUT       NOCOPY VARCHAR2
)
IS

 l_user_id      VARCHAR2(100);
 l_login_id     VARCHAR2(100);
 l_row_cnt  NUMBER;

BEGIN

  IF (p_tab_id IS NOT NULL ) THEN

    SELECT COUNT(0)  INTO l_row_cnt
    FROM bsc_tabs_b
    WHERE tab_id = p_tab_id;

    IF (l_row_cnt = 1) THEN

      l_user_id := fnd_global.USER_ID;
      l_login_id := fnd_global.LOGIN_ID;

      UPDATE bsc_tabs_b
      SET last_updated_by = l_user_id,
          last_update_date = SYSDATE,
          last_update_login = l_login_id
      WHERE tab_id = p_tab_id;

    END IF;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.update_tab_who_columns ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.update_tab_who_columns ';
        END IF;

        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.update_tab_who_columns ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.update_tab_who_columns ';
        END IF;
        RAISE;

END update_tab_who_columns;


PROCEDURE validate_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_level_vals_list        IN  OUT NOCOPY VARCHAR2
,p_mismatch_key_items     IN  OUT NOCOPY VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
)

IS
l_filter_count   NUMBER;
l_key_value      NUMBER;
l_cnt            NUMBER;
l_key_count      NUMBER;
l_filter_view    VARCHAR2(100);
l_level_view     VARCHAR2(100);
l_level_vals_list VARCHAR2(30000);
l_mismatch       NUMBER;
l_level_value    NUMBER;
l_key_name       VARCHAR2(500);
l_level_val      VARCHAR2(100);

CURSOR c_key_items IS
  SELECT a.default_key_value,
         a.level_shortname,
         a.level_view_name
  FROM   bsc_kpi_dim_levels_vl a
  WHERE  a.indicator IN (SELECT b.indicator
                           FROM bsc_tab_indicators b
                          WHERE b.tab_id = p_tab_id)
    AND  a.level_shortname IN ( SELECT d.short_name
                                  FROM bsc_sys_dim_levels_b d
                                 WHERE d.dim_level_id = p_dim_level_id);

 CURSOR c_parents IS
   SELECT a.dim_level_id, a.parent_dim_level_id,  a.relation_col
   FROM bsc_sys_dim_level_rels a
   WHERE a.dim_level_id = p_dim_level_id
     AND a.relation_type=1
     AND EXISTS ( SELECT indicator
                    FROM bsc_kpi_dim_level_properties b
                   WHERE b.dim_level_id = a.parent_dim_level_id
                     AND indicator IN (SELECT indicator
                                         FROM bsc_tab_indicators WHERE tab_id = p_tab_id
                                      )
                    );

 CURSOR c_childs IS
   SELECT a.dim_level_id child_dim_level_id
   FROM bsc_sys_dim_level_rels a
   WHERE a.parent_dim_level_id = p_dim_level_id
     AND a.relation_type=1
     AND EXISTS (SELECT b.dim_level_id
                 FROM bsc_kpi_dim_level_properties b
                 WHERE b.indicator IN (SELECT indicator FROM bsc_tab_indicators WHERE tab_id = p_tab_id)
                   and b.dim_level_id = a.dim_level_id );

BEGIN



IF (p_tab_id IS NOT NULL AND p_dim_level_id IS NOT NULL AND p_dim_level_id IS NOT NULL AND p_level_vals_list IS NOT NULL) THEN

  FOR cd IN c_key_items LOOP

    IF (cd.default_key_value IS NOT NULL) THEN



      l_level_vals_list := p_level_vals_list;
      l_mismatch := 1;




      WHILE (BSC_UTILITY.is_more(p_comma_sep_values => l_level_vals_list, x_value => l_level_val)) LOOP

        l_level_value := TO_NUMBER(RTRIM(LTRIM(l_level_val)));

        IF (l_level_value = cd.default_key_value) THEN
          l_mismatch := 0;
          EXIT;
        END IF;
      END LOOP;



      IF (l_mismatch = 1) THEN

        l_key_name := BSC_DEFAULT_KEY_ITEM_PUB.get_table_column_value(cd.level_view_name, 'NAME', 'CODE=' || cd.default_key_value);


        IF (p_mismatch_key_items IS NULL) THEN
          p_mismatch_key_items := l_key_name;
        ELSE
          p_mismatch_key_items := p_mismatch_key_items || ',' || l_key_name;
        END IF;
      END IF;

    END IF;
  END LOOP;


  FOR cd IN c_parents LOOP
    IF (cd.parent_dim_level_id IS NOT NULL) THEN
      validate_parent_key_items (
         p_tab_id              =>  p_tab_id
        ,p_dim_level_id        =>  p_dim_level_id
        ,p_parent_level_id     =>  cd.parent_dim_level_id
        ,p_level_vals_list     =>  p_level_vals_list
        ,p_mismatch_key_items  =>  p_mismatch_key_items
        ,x_return_status       =>  x_return_status
        ,x_msg_count           =>  x_msg_count
        ,x_msg_data            =>  x_msg_data
      );
    END IF;
  END LOOP;

  FOR cd IN c_childs LOOP
    IF (cd.child_dim_level_id IS NOT NULL) THEN
       validate_child_key_items (
         p_tab_id              =>  p_tab_id
        ,p_dim_level_id        =>  p_dim_level_id
        ,p_child_level_id     =>   cd.child_dim_level_id
        ,p_level_vals_list     =>  p_level_vals_list
        ,p_mismatch_key_items  =>  p_mismatch_key_items
        ,x_return_status       =>  x_return_status
        ,x_msg_count           =>  x_msg_count
        ,x_msg_data            =>  x_msg_data
       );
    END IF;
  END LOOP;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_key_items ';
        END IF;

        RAISE;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_key_items ';
        END IF;
        RAISE;

END validate_key_items;


PROCEDURE validate_parent_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_parent_level_id        IN             NUMBER
,p_level_vals_list        IN             VARCHAR2
,p_mismatch_key_items     IN  OUT NOCOPY VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
)
IS

l_mismatch_found          BOOLEAN;
l_key_item                NUMBER;
l_ch_view                 NUMBER;
l_dim_short_name          VARCHAR2(100);
l_par_dim_short_name      VARCHAR2(100);
l_filter_values           VARCHAR2(32000);
l_sql                     VARCHAR2(1000);
l_key_name                VARCHAR2(1000);
l_level_value             NUMBER;
l_rel_col                 VARCHAR2(100);
l_ch_level_view           VARCHAR2(100);
l_pa_level_view           VARCHAR2(100);

CURSOR c_dim_details(cp_dim_level_id NUMBER) IS
  SELECT * FROM bsc_sys_dim_levels_vl WHERE dim_level_id = cp_dim_level_id;

CURSOR c_kpi_dim_level_details(cp_level_shortname VARCHAR2) IS
  SELECT *
  FROM  bsc_kpi_dim_levels_vl
  WHERE level_shortname = cp_level_shortname AND indicator IN (SELECT indicator
                                         FROM bsc_tab_indicators WHERE tab_id = p_tab_id
                                        );

CURSOR c_parents IS
   SELECT a.dim_level_id, a.parent_dim_level_id,  a.relation_col
   FROM bsc_sys_dim_level_rels a
   WHERE a.dim_level_id = p_parent_level_id
        AND a.relation_type=1
        AND EXISTS ( SELECT indicator
                     FROM bsc_kpi_dim_level_properties b
                     WHERE b.dim_level_id = a.parent_dim_level_id
                       AND indicator IN (SELECT indicator
                                         FROM bsc_tab_indicators WHERE tab_id = p_tab_id
                                        )
                    );

  TYPE ref_cursor IS REF CURSOR;
  ref_cur         ref_cursor;


BEGIN
  IF (p_tab_id IS NOT NULL AND p_dim_level_id is NOT NULL AND p_parent_level_id IS NOT NULL AND p_level_vals_list IS NOT NULL) THEN
    FOR cd IN c_dim_details(p_dim_level_id) LOOP
       l_dim_short_name := cd.short_name;
       l_ch_level_view  := cd.level_view_name;
       EXIT;
    END LOOP;

    FOR cd IN c_dim_details(p_parent_level_id) LOOP
       l_par_dim_short_name := cd.short_name;
       EXIT;
    END LOOP;

    IF (l_dim_short_name IS NOT NULL AND l_dim_short_name IS NOT NULL ) THEN

      FOR cd IN c_kpi_dim_level_details (l_dim_short_name) LOOP
         l_rel_col        := cd.parent_level_rel;
         EXIT;
      END LOOP;

      IF (l_rel_col IS NOT NULL AND l_ch_level_view IS NOT NULL) THEN
         FOR cd IN c_kpi_dim_level_details (l_par_dim_short_name) LOOP
           IF (cd.default_key_value IS NOT NULL) THEN
             l_pa_level_view  :=  cd.level_view_name;
             l_mismatch_found :=  TRUE;
             l_sql := 'SELECT  DISTINCT ' || l_rel_col || ' FROM ' || l_ch_level_view || ' WHERE CODE IN (' || p_level_vals_list || ' )';

             IF (ref_cur%ISOPEN) THEN
               CLOSE ref_cur;
             END IF;

             OPEN ref_cur for l_sql;


             LOOP
               FETCH ref_cur INTO l_level_value;
               EXIT WHEN ref_cur%NOTFOUND;
               IF (l_level_value IS NOT NULL AND l_level_value = cd.default_key_value) THEN
                 l_mismatch_found :=  FALSE;
                 EXIT;
               END IF;
             END LOOP;

             CLOSE ref_cur;


             IF (l_mismatch_found AND l_pa_level_view IS NOT NULL) THEN
               l_key_name := BSC_DEFAULT_KEY_ITEM_PUB.get_table_column_value(
                                p_table_name    => l_pa_level_view
                               ,p_column_name   => 'NAME'
                               ,p_where_cond    => ' CODE = ' || cd.default_key_value
                             );
                IF (l_key_name IS NOT NULL) THEN
                   IF (p_mismatch_key_items IS NULL) THEN
                      p_mismatch_key_items := l_key_name;
                   ELSE
                      p_mismatch_key_items := p_mismatch_key_items || ',' || l_key_name;
                   END IF;
                END IF;
             END IF;
           END IF;
         END LOOP;


         FOR cd IN c_parents LOOP
           IF (cd.parent_dim_level_id IS NOT NULL) THEN
             l_filter_values := NULL;
             l_sql := 'SELECT  DISTINCT ' || l_rel_col || ' FROM ' || l_ch_level_view || ' WHERE CODE IN (' || p_level_vals_list || ' )';
             IF (ref_cur%ISOPEN) THEN
               CLOSE ref_cur;
             END IF;

             OPEN ref_cur for l_sql;

             LOOP
               FETCH ref_cur INTO l_level_value;
               EXIT WHEN ref_cur%NOTFOUND;
               IF (l_level_value IS NOT NULL) THEN
                 IF (l_filter_values IS NULL) THEN
                    l_filter_values := l_level_value ;
                 ELSE
                    l_filter_values := l_filter_values || ',' || l_level_value ;
                 END IF;
               END IF;
             END LOOP;

             IF (l_filter_values IS NOT NULL) THEN
                     validate_parent_key_items (
                        p_tab_id              =>  p_tab_id
                       ,p_dim_level_id        =>  p_parent_level_id
                       ,p_parent_level_id     =>  cd.parent_dim_level_id
                       ,p_level_vals_list     =>  l_filter_values
                       ,p_mismatch_key_items  =>  p_mismatch_key_items
                       ,x_return_status       =>  x_return_status
                       ,x_msg_count           =>  x_msg_count
                       ,x_msg_data            =>  x_msg_data
                     );
             END IF;
           END IF;
         END LOOP;
       END IF;
    END IF;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_parent_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_parent_key_items ';
        END IF;

        RAISE;

    WHEN OTHERS THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_parent_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_parent_key_items ';
        END IF;
        RAISE;

END validate_parent_key_items;


PROCEDURE validate_child_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_child_level_id         IN             NUMBER
,p_level_vals_list        IN             VARCHAR2
,p_mismatch_key_items    IN OUT NOCOPY   VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
)
IS

l_mismatch_found          BOOLEAN;
l_key_item                NUMBER;
l_ch_view                 NUMBER;
l_dim_short_name          VARCHAR2(100);
l_ch_dim_short_name       VARCHAR2(100);
l_filter_values           VARCHAR2(32000);
l_sql                     VARCHAR2(1000);
l_key_name                VARCHAR2(1000);
l_level_value             VARCHAR2(1000);
l_rel_col                 VARCHAR2(100);
l_ch_level_view           VARCHAR2(100);
l_pa_level_view           VARCHAR2(100);

CURSOR c_dim_details(cp_dim_level_id NUMBER) IS
  SELECT short_name FROM bsc_sys_dim_levels_vl WHERE dim_level_id = cp_dim_level_id;

CURSOR c_kpi_dim_level_details(cp_level_shortname VARCHAR2) IS
  SELECT *
  FROM  bsc_kpi_dim_levels_vl
  WHERE level_shortname = cp_level_shortname AND indicator IN (SELECT indicator
                                         FROM bsc_tab_indicators WHERE tab_id = p_tab_id
                                        );

 CURSOR c_childs IS
   SELECT a.dim_level_id child_dim_level_id,
          (SELECT b.short_name FROM bsc_sys_dim_levels_vl b WHERE b.dim_level_id = a.dim_level_id and rownum < 2) child_short_name
   FROM bsc_sys_dim_level_rels a
   WHERE a.parent_dim_level_id = p_dim_level_id
     AND a.relation_type=1
     AND a.dim_level_id IN
        (SELECT dim_level_id
         FROM bsc_kpi_dim_level_properties WHERE indicator IN
             (SELECT indicator FROM bsc_tab_indicators WHERE tab_id = p_tab_id));

  TYPE ref_cursor IS REF CURSOR;
  ref_cur         ref_cursor;


BEGIN
  IF (p_tab_id IS NOT NULL AND p_dim_level_id is NOT NULL AND p_child_level_id IS NOT NULL AND p_level_vals_list IS NOT NULL) THEN
    FOR cd IN c_dim_details(p_dim_level_id) LOOP
       l_dim_short_name := cd.short_name;
       EXIT;
    END LOOP;

    FOR cd IN c_dim_details(p_child_level_id) LOOP
       l_ch_dim_short_name := cd.short_name;
       EXIT;
    END LOOP;

    FOR cd IN c_kpi_dim_level_details(l_dim_short_name) LOOP
       l_pa_level_view := cd.level_view_name;
       EXIT;
    END LOOP;


    IF (l_dim_short_name IS NOT NULL AND l_dim_short_name IS NOT NULL AND l_pa_level_view IS NOT NULL) THEN

       FOR cd IN c_kpi_dim_level_details (l_ch_dim_short_name) LOOP

         l_rel_col        := cd.parent_level_rel;
         l_ch_level_view  := cd.level_view_name ;


         IF (cd.default_key_value IS NOT NULL) THEN
           l_mismatch_found :=  TRUE;
           l_sql := 'SELECT  DISTINCT CODE FROM ' || l_ch_level_view || ' WHERE ' ||  l_rel_col || ' IN (' || p_level_vals_list || ' )';
           IF (ref_cur%ISOPEN) THEN
             CLOSE ref_cur;
           END IF;

           OPEN ref_cur for l_sql;

           LOOP
             FETCH ref_cur INTO l_level_value;
             EXIT WHEN ref_cur%NOTFOUND;
             IF (l_level_value IS NOT NULL AND l_level_value = cd.default_key_value) THEN
               l_mismatch_found :=  FALSE;
               EXIT;
             END IF;
           END LOOP;

           IF (l_mismatch_found ) THEN

             l_key_name := BSC_DEFAULT_KEY_ITEM_PUB.get_table_column_value(
                                p_table_name    => l_ch_level_view
                               ,p_column_name   => 'NAME'
                               ,p_where_cond    => ' CODE = ' || cd.default_key_value
                             );

             IF (l_key_name IS NOT NULL) THEN
               IF (p_mismatch_key_items IS NULL) THEN
                 p_mismatch_key_items := l_key_name;
               ELSE
                 p_mismatch_key_items := p_mismatch_key_items || ',' || l_key_name;
               END IF;
             END IF;

           END IF;
         END IF;
       END LOOP;


       FOR cd IN c_childs LOOP
         IF (cd.child_dim_level_id IS NOT NULL) THEN
           l_filter_values := NULL;
           FOR cdd IN c_kpi_dim_level_details (cd.child_short_name) LOOP
             l_rel_col        := cdd.parent_level_rel;
             l_ch_level_view  := cdd.level_view_name ;
             EXIT;
           END LOOP;




           IF (l_rel_col IS NOT NULL AND l_ch_level_view IS NOT NULL) THEN

             l_sql := 'SELECT  DISTINCT CODE FROM ' || l_ch_level_view || ' WHERE ' ||  l_rel_col || ' IN (' || p_level_vals_list || ' )';

             IF (ref_cur%ISOPEN) THEN
               CLOSE ref_cur;
             END IF;

             OPEN ref_cur for l_sql;



             LOOP
               FETCH ref_cur INTO l_level_value;
               EXIT WHEN ref_cur%NOTFOUND;
               IF (l_level_value IS NOT NULL) THEN
                 IF (l_filter_values IS NULL) THEN
                   l_filter_values := l_level_value ;
                 ELSE
                   l_filter_values := l_filter_values || ',' || l_level_value ;
                 END IF;
               END IF;
             END LOOP;



             IF (l_filter_values IS NOT NULL) THEN
               validate_child_key_items (
                        p_tab_id              =>  p_tab_id
                       ,p_dim_level_id        =>  p_child_level_id
                       ,p_child_level_id     =>   cd.child_dim_level_id
                       ,p_level_vals_list     =>  l_filter_values
                       ,p_mismatch_key_items  =>  p_mismatch_key_items
                       ,x_return_status       =>  x_return_status
                       ,x_msg_count           =>  x_msg_count
                       ,x_msg_data            =>  x_msg_data
                     );
             END IF;
           END IF;
         END IF;
       END LOOP;


     END IF;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE;

    WHEN NO_DATA_FOUND THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_child_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_child_key_items ';
        END IF;

        RAISE;

    WHEN OTHERS THEN
        IF (ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DIM_LEVEL_FILTERS_PUB.validate_child_key_items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DIM_LEVEL_FILTERS_PUB.validate_child_key_items ';
        END IF;
        RAISE;

END validate_child_key_items;


END BSC_DIM_LEVEL_FILTERS_PUB;

/

--------------------------------------------------------
--  DDL for Package Body BSC_DEFAULT_KEY_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DEFAULT_KEY_ITEM_PUB" AS
/* $Header: BSCPDKIB.pls 120.4.12000000.2 2007/10/15 06:41:06 psomesul noship $ */

PROCEDURE Validate_key_shared_obj
(
   p_kpi_id         IN             BSC_KPIS_B.indicator%TYPE
 , p_params         IN             VARCHAR2
 , x_return_status  OUT   NOCOPY   VARCHAR2
 , x_msg_count      OUT   NOCOPY   NUMBER
 , x_msg_data       OUT   NOCOPY   VARCHAR2
)IS

  l_dim_level_id       BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE;
  l_dim_level_val      BSC_SYS_FILTERS.dim_level_value%TYPE;
  l_score_list         VARCHAR2(30000);
  l_level_view_name    BSC_KPI_DIM_LEVELS_B.level_view_name%TYPE;
  l_dim_obj_recs       BSC_UTILITY.varchar_tabletype;
  l_dim_obj_rec        VARCHAR2(200);
  l_dim_obj_cnt        NUMBER;
  l_key_name           VARCHAR2(1000);
  l_dim_props          BSC_UTILITY.varchar_tabletype;
  l_dim_set_id         VARCHAR2(20);
  l_dim_level_index    VARCHAR2(20);
  l_def_key_id         VARCHAR2(20);
  l_cnt                NUMBER;

  CURSOR c_key IS
  SELECT a.INDICATOR,
         a.tab_id,
         b.name,
      DECODE (
        (SELECT COUNT(0)
         FROM bsc_sys_filters
         WHERE source_type =1
         AND source_code =a.tab_id
         AND dim_level_id =l_dim_level_id
        ),0,1,
        (SELECT COUNT(0)
         FROM bsc_sys_filters
         WHERE source_type =1
         AND source_code =a.tab_id
         AND dim_level_id =l_dim_level_id
         AND dim_level_value =l_def_key_id)) total
  FROM  bsc_tab_indicators a,
        bsc_tabs_vl b
  WHERE a.tab_id =b.tab_id
  AND   a.indicator IN
                    (SELECT INDICATOR
                     FROM   bsc_kpis_vl
                     WHERE  source_indicator =p_kpi_id
                     AND prototype_flag<>2);
BEGIN
   FND_MSG_PUB.Initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF(p_kpi_id IS NOT NULL AND p_params IS NOT NULL) THEN

       BSC_UTILITY.Parse_String
       (
            p_List         =>   p_params,
            p_Separator    =>   ';',
            p_List_Data    =>   l_dim_obj_recs,
            p_List_number  =>   l_dim_obj_cnt
        );
       FOR i IN 1..l_dim_obj_cnt LOOP
          l_dim_obj_rec := l_dim_obj_recs(i);
          BSC_UTILITY.Parse_String
          (
              p_List         =>   l_dim_obj_rec,
              p_Separator    =>   ',',
              p_List_Data    =>   l_dim_props,
              p_List_number  =>   l_cnt
          );

          l_dim_set_id       :=  l_dim_props(1);
          l_dim_level_id     :=  l_dim_props(2);
          l_dim_level_index  :=  l_dim_props(3);
          l_def_key_id       :=  l_dim_props(4);

         IF(l_dim_set_id IS NOT NULL AND l_dim_level_id IS NOT NULL
           AND l_dim_level_index IS NOT NULL AND l_def_key_id IS NOT NULL ) THEN

          FOR cd IN c_key LOOP
            IF(cd.total=0) THEN
             IF(l_score_list IS NULL) THEN
               l_score_list := cd.name;
             ELSE
               l_score_list := l_score_list || ',' || cd.name;
             END IF;
           END IF;
          END LOOP;

          IF(l_score_list IS NOT NULL) THEN

           SELECT level_view_name
           INTO   l_level_view_name
           FROM   bsc_kpi_dim_levels_vl
           WHERE  indicator =  p_kpi_id
           AND    dim_set_id = l_dim_set_id
           AND    dim_level_index = l_dim_level_index;

           l_key_name := BSC_DEFAULT_KEY_ITEM_PUB.get_table_column_value
                         (
                            p_table_name  => l_level_view_name
                          , p_column_name => 'NAME'
                          , p_where_cond  => 'CODE=' || l_def_key_id
                         );
           FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_OBJ_KEY_ERROR');
           FND_MESSAGE.SET_TOKEN('KEY_NAME',l_key_name, TRUE);
           FND_MESSAGE.SET_TOKEN('LIST',l_score_list, TRUE);
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
         x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Validate_key_shared_obj ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Validate_key_shared_obj ';
     END IF;
     --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
 WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Validate_key_shared_obj ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Validate_key_shared_obj ';
     END IF;
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END  Validate_key_shared_obj;


/* The following API updates default key items
*/

PROCEDURE Update_Default_Key_Items(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
) IS

l_count       NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_kpi_id IS NOT NULL AND p_params IS NOT NULL) THEN

    SAVEPOINT bsc_key_item_pub_upd_key_item;

    SELECT count(0) INTO l_count
    FROM bsc_kpis_b
    WHERE indicator = p_kpi_id
      AND source_indicator IS NULL
      AND (share_flag =1 OR share_flag = 0)  -- OBJECTIVE should be a master or new objective
      AND prototype_flag <> 2;

    IF (l_count = 1) THEN  -- If MASTER OBJECTIVE

      Update_Key_Item
        (
          p_kpi_id        =>  p_kpi_id
        , p_params        =>  p_params
        , p_commit        =>  p_commit
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
        );

       IF(x_return_status IS NOT NULL AND x_return_status<>FND_API.G_RET_STS_SUCCESS)THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

      Cascade_Key_Item_Changes  --CASCADE the changes to the shared objective also
        (
          p_kpi_id        =>  p_kpi_id
        , p_params        =>  p_params
        , p_commit        =>  p_commit
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
        );
      IF(x_return_status IS NOT NULL AND x_return_status<>FND_API.G_RET_STS_SUCCESS)THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO bsc_key_item_pub_upd_key_item;
        IF (x_msg_data IS NULL) THEN
         FND_MSG_PUB.Count_And_Get
         (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
         );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO bsc_key_item_pub_upd_key_item;
        IF (x_msg_data IS NULL) THEN
          FND_MSG_PUB.Count_And_Get
          (      p_encoded   =>  FND_API.G_FALSE
             ,   p_count     =>  x_msg_count
             ,   p_data      =>  x_msg_data
          );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        ROLLBACK TO bsc_key_item_pub_upd_key_item;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Update_Default_Key_Items ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Update_Default_Key_Items ';
        END IF;
END Update_Default_Key_Items;


-- The following API returns a particular column value from a table/view
-- satisfying a where condition.

FUNCTION get_table_column_value(
  p_table_name            IN    VARCHAR2
 ,p_column_name           IN    VARCHAR2
 ,p_where_cond            IN    VARCHAR2
) RETURN VARCHAR2
IS
  l_sql           VARCHAR2(1000);
  l_result        VARCHAR2(100);

  TYPE ref_cursor IS REF CURSOR;
  ref_cur         ref_cursor;

BEGIN

IF p_table_name IS NOT null AND p_column_name IS NOT null AND p_where_cond IS NOT null THEN
  l_sql := 'SELECT ' || p_column_name || ' FROM ' || p_table_name || ' WHERE ' || p_where_cond;

  OPEN ref_cur FOR l_sql;
  FETCH ref_cur INTO l_result;
  CLOSE ref_cur;
END IF;

return l_result;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END get_table_column_value;


PROCEDURE Set_Key_Item_Value
(
    p_indicator        IN           BSC_KPIS_B.indicator%TYPE
  , p_dim_id           IN           BSC_KPI_DIM_SETS_VL.dim_set_id%TYPE
  , p_dim_obj_sht_name IN           BSC_SYS_DIM_LEVELS_VL.short_name%TYPE
  , p_key_value        IN           BSC_KPI_DIM_LEVEL_PROPERTIES.default_key_value%TYPE
  , x_return_status    OUT  NOCOPY  VARCHAR2
  , x_msg_count        OUT  NOCOPY  NUMBER
  , x_msg_data         OUT  NOCOPY  VARCHAR2
)IS
  l_indicator       BSC_KPIS_B.indicator%TYPE;

  CURSOR c_dim_obj IS
  SELECT a.dim_set_id,
         a.dim_level_index,
         b.dim_level_id
  FROM   bsc_kpi_dim_levels_vl a,
         bsc_sys_dim_levels_b b
  WHERE  b.short_name =a.level_shortname
  AND    a.level_shortname =p_dim_obj_sht_name
  AND    a.indicator =p_indicator;

  l_params        VARCHAR2(32000);

BEGIN
    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(p_indicator IS NOT NULL) THEN
      l_indicator:=p_indicator;

      IF(l_indicator IS NOT NULL) THEN
       FOR cd1 IN c_dim_obj LOOP
         l_params := p_dim_id||',' || cd1.dim_level_id || ',' || cd1.dim_level_index || ',';
         IF(p_key_value IS NOT NULL) THEN
          l_params := l_params ||p_key_value || ',,';
         ELSE
          l_params := l_params || ',,,';
         END IF;
        END LOOP;
        --now call pradeep's update API

        BSC_DEFAULT_KEY_ITEM_PUB.Update_Key_Item
        (
          p_kpi_id        =>  l_indicator
        , p_params        =>  l_params
        , p_commit        =>  FND_API.G_FALSE
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
        );
        IF(x_return_status IS NOT NULL AND x_return_status<>FND_API.G_RET_STS_SUCCESS)THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
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
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
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
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END  Set_Key_Item_Value;



PROCEDURE Update_Key_Item(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
) IS

l_dim_obj_recs       BSC_UTILITY.varchar_tabletype;
l_dim_obj_rec        VARCHAR2(200);
l_dim_obj_cnt        NUMBER;
l_dim_props          BSC_UTILITY.varchar_tabletype;
l_dim_set_id         VARCHAR2(20);
l_dim_level_id       VARCHAR2(20);
l_dim_level_index    VARCHAR2(20);
l_def_key_id         VARCHAR2(20);
l_init_def_key_id    VARCHAR2(20);
l_parent_level_index VARCHAR2(20) ;
l_cnt                NUMBER;
l_user_id            VARCHAR2(100);
l_login_id           VARCHAR2(100);
l_count              NUMBER;
l_change_flag        NUMBER;
l_dim_set_ids        VARCHAR2(1000);
l_updated            NUMBER;
l_sql                VARCHAR2(1000);
l_kpi_measure_id     BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE;

TYPE ref_cursor IS   REF CURSOR;
ref_cur              ref_cursor;


BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_kpi_id IS NOT NULL AND p_params IS NOT NULL) THEN

   BSC_DEFAULT_KEY_ITEM_PUB.Validate_key_shared_obj
   (
      p_kpi_id         => p_kpi_id
    , p_params         => p_params
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
   );

   IF(x_return_status IS NOT NULL AND x_return_status<>FND_API.G_RET_STS_SUCCESS)THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    BSC_UTILITY.Parse_String (
      p_List         =>   p_params,
      p_Separator    =>   ';',
      p_List_Data    =>   l_dim_obj_recs,
      p_List_number  =>   l_dim_obj_cnt
    );

    l_user_id := fnd_global.USER_ID;
    l_login_id := fnd_global.LOGIN_ID;

    l_change_flag := 0;
    l_updated     := 0;

    FOR i IN 1..l_dim_obj_cnt LOOP
      l_dim_obj_rec := l_dim_obj_recs(i);

      BSC_UTILITY.Parse_String(
        p_List         =>   l_dim_obj_rec,
        p_Separator    =>   ',',
        p_List_Data    =>   l_dim_props,
        p_List_number  =>   l_cnt
      );

      l_dim_set_id       :=  l_dim_props(1);
      l_dim_level_id     :=  l_dim_props(2);
      l_dim_level_index  :=  l_dim_props(3);
      l_def_key_id       :=  l_dim_props(4);
      l_init_def_key_id  :=  l_dim_props(5);

      IF (l_cnt = 6) THEN
        l_parent_level_index :=  l_dim_props(6);
      ELSE
        l_parent_level_index :=  NULL;
      END IF;


      IF (l_init_def_key_id IS NULL) THEN
        l_init_def_key_id := -1;
      END IF;

      IF (l_def_key_id IS NULL) THEN
        l_def_key_id := -1;
      END IF;

      IF (l_dim_set_id IS NOT NULL AND l_dim_level_id IS NOT NULL AND l_dim_level_index IS NOT NULL AND l_def_key_id <> l_init_def_key_id) THEN

        SELECT count(0)
        INTO   l_count
        FROM   bsc_kpi_dim_level_properties
        WHERE  indicator  = p_kpi_id
        AND    dim_set_id = l_dim_set_id
        AND    dim_level_id= l_dim_level_id;

       IF (l_init_def_key_id = -1) THEN
         l_init_def_key_id := NULL;
       END IF;

       IF (l_def_key_id = -1) THEN
         l_def_key_id := NULL;
       END IF;


        IF (l_count > 0) THEN
          l_count := 0;
          l_updated := 1;


          IF (l_dim_set_id IS NOT NULL) THEN
            IF (l_dim_set_ids IS NOT NULL) THEN
              l_dim_set_ids := l_dim_set_ids || ',' || l_dim_set_id;
            ELSE
              l_dim_set_ids := l_dim_set_id;
            END IF;
          END IF;

          SELECT  count(0) INTO l_count
          FROM bsc_kpi_dim_levels_b
          WHERE indicator = p_kpi_id
            AND dim_set_id = l_dim_set_id
            AND dim_level_index = l_dim_level_index;

          IF (l_count > 0) THEN

            UPDATE bsc_kpi_dim_level_properties
            SET default_key_value = l_def_key_id
            WHERE indicator = p_kpi_id
            AND dim_set_id = l_dim_set_id
            AND dim_level_id = l_dim_level_id;

            UPDATE bsc_kpi_dim_levels_b
            SET default_key_value = l_def_key_id
            WHERE indicator = p_kpi_id
              AND dim_set_id = l_dim_set_id
              AND dim_level_index = l_dim_level_index;


           IF (LENGTH(TRIM(TRANSLATE(l_def_key_id,  ' +-0123456789',' '))) IS NOT NULL AND LENGTH(TRIM(TRANSLATE(l_init_def_key_id,  ' +-0123456789',' '))) IS NOT NULL) THEN
             IF (l_change_flag = 0) THEN
               l_change_flag := 7;
             END IF;
           ELSE
             l_change_flag := 5;
           END IF;

         END IF;
        END IF;
      END IF;
    END LOOP;

    IF (l_updated = 1) THEN
       IF (l_dim_set_ids IS NOT NULL) THEN

         l_sql := 'SELECT DISTINCT KPI_MEASURE_ID FROM BSC_DB_DATASET_DIM_SETS_V WHERE indicator  = ';
         l_sql := l_sql || p_kpi_id || ' AND dim_set_id  IN (' || l_dim_set_ids  || ')';


         IF(ref_cur%ISOPEN) THEN
           CLOSE ref_cur;
         END IF;

         OPEN ref_cur FOR l_sql;
         LOOP
           FETCH ref_cur INTO  l_kpi_measure_id ;
           EXIT WHEN ref_cur%NOTFOUND;
           IF (l_kpi_measure_id IS NOT NULL) THEN
             BSC_KPI_COLOR_PROPERTIES_PUB.Change_Prototype_Flag
                  (  p_objective_id    =>  p_kpi_id
                   , p_kpi_measure_id  =>  l_kpi_measure_id
                   , p_prototype_flag  =>  7
                   , x_return_status   =>  x_return_status
                   , x_msg_count       =>  x_msg_count
                   , x_msg_data        =>  x_msg_data
                  );
           END IF;
         END LOOP;
         CLOSE ref_cur;

       END IF;

       UPDATE bsc_tabs_b
       SET last_updated_by = l_user_id,
           last_update_date = SYSDATE,
           last_update_login = l_login_id
       WHERE tab_id IN (
          SELECT tab_id
          FROM bsc_tab_indicators
          WHERE indicator = p_kpi_id);

      UPDATE bsc_kpis_b
      SET last_updated_by = l_user_id,
          last_update_date = SYSDATE,
          last_update_login = l_login_id
      WHERE indicator = p_kpi_id;

    END IF;


    IF (l_change_flag <> 0) THEN

      BSC_DESIGNER_PVT.ActionFlag_change(
        x_indicator => p_kpi_id,
        x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
        );

      IF (l_change_flag = 5 ) THEN

        BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button(
           p_Kpi_Id          =>    p_kpi_id,
           p_Dim_Level_Id    =>    NULL,
           x_return_status   =>    x_return_status,
           x_msg_count       =>    x_msg_count,
           x_msg_data        =>    x_msg_data
        );


        IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
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
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      IF(ref_cur%ISOPEN) THEN
        CLOSE ref_cur;
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF(ref_cur%ISOPEN) THEN
        CLOSE ref_cur;
      END IF;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Update_Key_Item ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Update_Key_Item ';
        END IF;
        IF(ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;


END Update_Key_Item;


PROCEDURE Cascade_Key_Item_Changes(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
) IS

CURSOR c_shared_objectives IS
   SELECT indicator
   FROM bsc_kpis_b
   WHERE source_indicator = p_kpi_id
     AND share_flag  = 2
     AND prototype_flag <> 2;

BEGIN

  IF (p_kpi_id IS NOT NULL AND p_params IS NOT NULL) THEN

    FOR cd IN c_shared_objectives LOOP

      Update_Key_Item
      (
          p_kpi_id        =>  cd.indicator
        , p_params        =>  p_params
        , p_commit        =>  p_commit
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
      );

    END LOOP;

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

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_DEFAULT_KEY_ITEM_PUB.Cascade_Key_Item_Changes ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_DEFAULT_KEY_ITEM_PUB.Cascade_Key_Item_Changes ';
        END IF;
        RAISE;
END Cascade_Key_Item_Changes;

END BSC_DEFAULT_KEY_ITEM_PUB;


/

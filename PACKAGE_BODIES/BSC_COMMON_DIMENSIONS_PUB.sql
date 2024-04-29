--------------------------------------------------------
--  DDL for Package Body BSC_COMMON_DIMENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COMMON_DIMENSIONS_PUB" AS
/* $Header: BSCPLIBB.pls 120.3.12000000.1 2007/07/17 07:44:12 appldev noship $ */


-- The following API saves LIST BUTTON (Common Dimension) configuration
-- for a particular SCORECARD.
-- INPUT :
--      p_new_list_config     A semicolon(;) seperated values of common dimension objects
--                            that have to be saved.
--      p_old_list_config     A semicolon(;) seperated values of common dimension objects
--                            that were saved. When there are no common dimensions saved,
--                            this is empty.
-- NOTE:1.  Each common dimension object record contains a commma seperated list of the following
--          properties in order:
--          (dim_level_index, dim_level_id, parent_level_index, parent_level_id)
--          And then each such dimension object record is seperated by a semicolon.
--      2.  When we want to delete existing common dimension objects,
--          p_new_list_config should be an empty string.
--      3.  When there is no common dimension configuration, the p_old_list_config is empty

PROCEDURE save_list_button_config
(p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_old_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
) IS

BEGIN
  IF (p_tab_id IS NOT NULL) THEN

    BSC_COMMON_DIMENSIONS_PVT.reset_dim_default_value
    (
       p_Tab_Id         =>  p_tab_id
      ,x_return_status  =>  x_return_status
      ,x_msg_count      =>  x_msg_count
      ,x_msg_data       =>  x_msg_data
    );
    IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions(
        p_tab_id            =>   p_tab_id
       ,p_commit            =>   FND_API.G_FALSE
       ,x_return_status     =>   x_return_status
       ,x_msg_count         =>   x_msg_count
       ,x_msg_data          =>   x_msg_data
    );

    IF (p_new_list_config IS NOT NULL) THEN
      BSC_COMMON_DIMENSIONS_PVT.insert_common_dimensions(
         p_tab_id            =>   p_tab_id
        ,p_new_list_config   =>   p_new_list_config
        ,p_commit            =>   FND_API.G_FALSE
        ,x_return_status     =>   x_return_status
        ,x_msg_count         =>   x_msg_count
        ,x_msg_data          =>   x_msg_data
    );

    END IF;

    BSC_COMMON_DIMENSIONS_PUB.update_user_list_access(
         p_tab_id            =>   p_tab_id
        ,p_new_list_config   =>   p_new_list_config
        ,p_old_list_config   =>   p_old_list_config
        ,p_commit            =>   FND_API.G_FALSE
        ,x_return_status     =>   x_return_status
        ,x_msg_count         =>   x_msg_count
        ,x_msg_data          =>   x_msg_data
    );


    --VALIDATE common dimensions
    BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels(
         p_commit            =>   FND_API.G_FALSE
        ,p_Tab_Id            =>   p_tab_id
        ,x_return_status     =>   x_return_status
        ,x_msg_count         =>   x_msg_count
        ,x_msg_data          =>   x_msg_data
    );



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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.save_list_button_config ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.save_list_button_config ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.save_list_button_config ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.save_list_button_config ';
        END IF;

        RAISE;
END save_list_button_config;




-- The following API provides the access to common dimensions.
--
-- INPUT :
--      p_new_list_config     A semicolon(;) seperated values of common dimension objects
--                            that have to be saved.
--      p_old_list_config     A semicolon(;) seperated values of common dimension objects
--                            that were saved. When there are no common dimensions saved,
--                            this is empty.
-- NOTE:    Each common dimension object record contains a commma seperated list of the following
--          properties in order:
--          (dim_level_index, dim_level_id, parent_level_index, parent_level_id)


PROCEDURE update_user_list_access
(
 p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_old_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
) IS

CURSOR c_new_list_config IS
   SELECT *
   FROM bsc_sys_com_dim_levels
   WHERE tab_id = p_tab_id
   ORDER BY dim_level_index;

CURSOR c_tab_responsibilities IS
   SELECT responsibility_id
   FROM BSC_USER_TAB_ACCESS
   WHERE tab_id = p_tab_id
     AND (end_date IS NULL OR end_date >= SYSDATE);

CURSOR c_tab_kpis IS
   SELECT DISTINCT kpi_measure_id, indicator
   FROM bsc_kpi_analysis_measures_b
   WHERE indicator IN (SELECT DISTINCT ti.indicator
                       FROM bsc_tab_indicators ti
                       WHERE ti.tab_id = p_tab_id);

l_new_dim_obj_recs          BSC_UTILITY.varchar_tabletype;
l_new_dim_obj_cnt           NUMBER;
l_new_dim_props             BSC_UTILITY.varchar_tabletype;
l_new_cnt                   NUMBER;

l_old_dim_obj_recs          BSC_UTILITY.varchar_tabletype;
l_old_dim_obj_cnt           NUMBER;
l_old_dim_props             BSC_UTILITY.varchar_tabletype;
l_old_cnt                   NUMBER;

l_index                     NUMBER;
l_user_id                   NUMBER;
l_login_id                  NUMBER;
l_dim_level_index           NUMBER;

BEGIN
  IF (p_tab_id IS NOT NULL) THEN

    IF (p_old_list_config IS NULL) THEN
      l_old_dim_obj_cnt := 0;
    ELSE
      BSC_UTILITY.Parse_String(
                p_List         =>   p_old_list_config,
                p_Separator    =>   ';',
                p_List_Data    =>   l_old_dim_obj_recs,
                p_List_number  =>   l_old_dim_obj_cnt
                );
    END IF;

    IF (p_new_list_config IS NULL) THEN
      l_new_dim_obj_cnt := 0;
    ELSE
      BSC_UTILITY.Parse_String(
                 p_List         =>     p_new_list_config,
                 p_Separator    =>     ';',
                 p_List_Data    =>     l_new_dim_obj_recs,
                 p_List_number  =>     l_new_dim_obj_cnt
                   );
    END IF;

    IF (l_old_dim_obj_cnt = l_new_dim_obj_cnt) THEN
      RETURN;
    END IF;


    BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag(
               p_prototype_flag  =>  BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color,
               p_tab_id          =>  p_tab_id,
               p_dim_level_id    =>  NULL,
               p_commit          =>  p_commit,
               x_return_status   =>  x_return_status,
               x_msg_count       =>  x_msg_count,
               x_msg_data        =>  x_msg_data
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

    IF (l_old_dim_obj_cnt > l_new_dim_obj_cnt) THEN
        l_index := l_new_dim_obj_cnt;
    ELSE
        l_index := l_old_dim_obj_cnt;
    END IF;
    BSC_COMMON_DIMENSIONS_PVT.delete_user_list_access (
                  p_tab_id               => p_tab_id
                 ,p_dim_level_index      => l_index
                 ,p_commit               => FND_API.G_FALSE
                 ,x_return_status        => x_return_status
                 ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
    );

    --DELETE FROM BSC_USER_LIST_ACCESS WHERE tab_id = p_tab_id AND DIM_LEVEL_INDEX >= (l_index-1);

    l_user_id := fnd_global.USER_ID;
    l_login_id := fnd_global.LOGIN_ID;
    FOR cd IN c_tab_responsibilities LOOP
      FOR i IN 1..l_new_dim_obj_cnt LOOP
        l_new_cnt :=  0;
        BSC_UTILITY.Parse_String(
                 p_List         =>     l_new_dim_obj_recs(i),
                 p_Separator    =>     ',',
                 p_List_Data    =>     l_new_dim_props,
                 p_List_number  =>     l_new_cnt);

        IF (l_new_cnt > 0) THEN

          l_dim_level_index := TO_NUMBER(l_new_dim_props(1));

          IF (l_dim_level_index IS NOT NULL) THEN
            IF (l_dim_level_index > l_index-1) THEN
              BSC_COMMON_DIMENSIONS_PVT.insert_user_list_access(
               p_responsibility_id  =>  cd.responsibility_id
              ,p_tab_id             =>  p_tab_id
              ,p_dim_level_index    =>  l_dim_level_index
              ,p_dim_level_value    =>  0
              ,p_creation_date      =>  SYSDATE
              ,p_created_by         =>  l_user_id
              ,p_last_update_date   =>  SYSDATE
              ,p_last_updated_by    =>  l_login_id
              ,p_last_update_login  =>  NULL
              ,p_commit             =>  FND_API.G_FALSE
              ,x_return_status      =>  x_return_status
              ,x_msg_count          =>  x_msg_count
              ,x_msg_data           =>  x_msg_data
              );
            END IF;

            --INSERT INTO bsc_user_list_access(responsibility_id,tab_id,dim_level_index,dim_level_value,creation_date,created_by,last_update_date,last_updated_by,last_update_login)
            --VALUES (cd.responsibility_id, p_tab_id, l_dim_level_index, 0, SYSDATE, l_user_id,SYSDATE, l_login_id, null);

          END IF;
        END IF;
      END LOOP;
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.update_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.update_user_list_access ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.update_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.update_user_list_access ';
        END IF;

        RAISE;
END update_user_list_access;


--  The following API sets a particular prototype flag to all the
--  indicators under a scorecard, if the input parameter p_tab_id
--  is not null. If the input parameter p_dim_level_id is also not null,
--  then the prototype flag is set to all the indicators that contain
--  the dimension level in that scorecard.

PROCEDURE change_prototype_flag
(
  p_prototype_flag         IN               NUMBER
 ,p_tab_id                 IN               NUMBER
 ,p_dim_level_id           IN               NUMBER
 ,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
 ,x_return_status          OUT       NOCOPY VARCHAR2
 ,x_msg_count              OUT       NOCOPY NUMBER
 ,x_msg_data               OUT       NOCOPY VARCHAR2

) IS

--CURSOR for all indicators in a tab
CURSOR c_inds IS
  SELECT DISTINCT ti.indicator
  FROM bsc_tab_indicators ti
  WHERE ti.tab_id = p_tab_id;
--CURSOR for indicators that contain particular dim level
CURSOR c_inds_levels  IS
  SELECT DISTINCT ti.indicator
  FROM bsc_tab_indicators ti, bsc_sys_dim_levels_b sd, bsc_kpi_dim_levels_b kd
  WHERE ti.tab_id = p_tab_id AND sd.dim_level_id = p_dim_level_id AND
        kd.indicator = ti.indicator AND kd.level_table_name = sd.level_table_name;

BEGIN
  IF (p_tab_id IS NOT NULL) THEN

    IF (p_dim_level_id IS NOT NULL) THEN
      FOR cd IN c_inds_levels LOOP
        BSC_DESIGNER_PVT.ActionFlag_Change(
            x_indicator => cd.indicator,
            x_newflag   => p_prototype_flag
            );
      END LOOP;

    ELSE
      FOR cd IN c_inds LOOP
        BSC_DESIGNER_PVT.ActionFlag_Change(
             x_indicator => cd.indicator,
             x_newflag   => p_prototype_flag
             );
      END LOOP;
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PUB.change_prototype_flag ';
        END IF;

        RAISE;
END change_prototype_flag;

END BSC_COMMON_DIMENSIONS_PUB;

/

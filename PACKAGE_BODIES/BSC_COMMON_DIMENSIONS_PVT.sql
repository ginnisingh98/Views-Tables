--------------------------------------------------------
--  DDL for Package Body BSC_COMMON_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COMMON_DIMENSIONS_PVT" AS
/* $Header: BSCVLIBB.pls 120.2.12000000.1 2007/07/17 07:44:52 appldev noship $ */

PROCEDURE Get_Parent_level_properties
(
   p_tab_id               IN   BSC_TABS_B.tab_id%TYPE
  ,p_level_index          IN   BSC_KPI_DIM_LEVELS_B.dim_level_index%TYPE
  ,x_parent_level_id      OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
  ,x_parent_level_index   OUT NOCOPY  BSC_KPI_DIM_LEVELS_B.parent_level_index%TYPE
);

-- The following API saves LIST BUTTON (Common Dimension) configuration
-- for a particular SCORECARD.
-- INPUT :
--      p_new_list_config     A semicolon(;) seperated values of common dimension objects
--                            that have to be saved.
-- NOTE:    Each common dimension object record contains a commma seperated list of the following
--          properties in order:
--          (dim_level_index, dim_level_id, parent_level_index, parent_level_id)

PROCEDURE insert_common_dimensions
(
 p_tab_id                 IN               NUMBER
,p_new_list_config        IN               VARCHAR2
,p_commit                 IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT       NOCOPY VARCHAR2
,x_msg_count              OUT       NOCOPY NUMBER
,x_msg_data               OUT       NOCOPY VARCHAR2
) IS

l_row_cnt               NUMBER;
l_dim_level_id          NUMBER;
l_parent_level_id       NUMBER;
l_dim_level_index       NUMBER;
l_parent_level_index    NUMBER;
l_dim_obj_recs          BSC_UTILITY.varchar_tabletype;
l_dim_obj_cnt           NUMBER;
l_dim_props             BSC_UTILITY.varchar_tabletype;
l_cnt                   NUMBER;

BEGIN

  IF (p_tab_id IS NOT NULL AND p_new_list_config IS NOT NULL) THEN
    BSC_UTILITY.Parse_String(
           p_List         =>   p_new_list_config,
     p_Separator    =>   ';',
     p_List_Data    =>   l_dim_obj_recs,
     p_List_number  =>   l_dim_obj_cnt
    );

    FOR i IN 1..l_dim_obj_cnt LOOP

      BSC_UTILITY.Parse_String(
              p_List         =>    l_dim_obj_recs(i),
        p_Separator    =>    ',',
        p_List_Data    =>    l_dim_props,
        p_List_number  =>    l_cnt
        );

      l_dim_level_id       := TO_NUMBER(l_dim_props(2));
      l_dim_level_index    := TO_NUMBER(l_dim_props(1));
      l_parent_level_index := TO_NUMBER(l_dim_props(3));
      IF (l_cnt = 4) THEN
        l_parent_level_id    := TO_NUMBER(l_dim_props(4));
      ELSE
        l_parent_level_id    := NULL;
      END IF;



      IF (l_dim_level_id IS NOT NULL AND l_dim_level_index IS NOT NULL) THEN

        SELECT count(0)  INTO l_row_cnt
        FROM bsc_sys_com_dim_levels
        WHERE tab_id = p_tab_id
          AND dim_level_id = l_dim_level_id
          AND dim_level_index = l_dim_level_index;

        IF (l_row_cnt = 0) THEN
          -- before creating records we will update default_value in bsc_kpi_dim_levels_b.the same way as it was
          -- happening in VB
          BSC_COMMON_DIMENSIONS_PVT.set_dim_default_value
          (
             p_dim_level_id    => l_dim_level_id
            ,p_default_value   => 'D'||l_dim_level_index
            ,p_Tab_Id          => p_tab_id
            ,x_return_status   => x_return_status
            ,x_msg_count       => x_msg_count
            ,x_msg_data        => x_msg_data
          );
          IF(x_return_status IS NOT NULL AND x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          BSC_COMMON_DIMENSIONS_PVT.Get_Parent_level_properties
          (
            p_tab_id             =>  p_tab_id
           ,p_level_index        =>  l_dim_level_index
           ,x_parent_level_id    =>  l_parent_level_id
           ,x_parent_level_index =>  l_parent_level_index
          );

          INSERT
          INTO bsc_sys_com_dim_levels (tab_id, dim_level_index, dim_level_id, parent_level_index, parent_dim_level_id)
          VALUES(p_tab_id, l_dim_level_index, l_dim_level_id, l_parent_level_index, l_parent_level_id);
  END IF;
      END IF;
    END LOOP;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.insert_common_dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.insert_common_dimensions ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.insert_common_dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.insert_common_dimensions ';
        END IF;

        RAISE;
END insert_common_dimensions;



-- The following API removes common dimensions for a given scorecard.

PROCEDURE delete_common_dimensions
(
 p_tab_id               IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT     NOCOPY   VARCHAR2
,x_msg_count            OUT     NOCOPY   NUMBER
,x_msg_data             OUT     NOCOPY   VARCHAR2
) IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_tab_id IS NOT NULL ) THEN
    DELETE
    FROM bsc_sys_com_dim_levels
    WHERE tab_id = p_tab_id;

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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions ';
        END IF;

        RAISE;

END delete_common_dimensions;


PROCEDURE delete_common_dimensions_tabs (
  p_commit         IN  VARCHAR2 := FND_API.G_FALSE
, p_tab_ids        IN  VARCHAR2
, x_return_status  OUT NOCOPY VARCHAR2
, x_msg_count      OUT NOCOPY NUMBER
, x_msg_data       OUT NOCOPY VARCHAR2
)
IS
  l_tab_ids  VARCHAR2(1000);
  l_tab_id   VARCHAR2(10);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_tab_ids IS NOT NULL THEN
    l_tab_ids := p_tab_ids ;
    WHILE (BSC_BIS_KPI_MEAS_PUB.is_more ( p_dim_short_names => l_tab_ids
                                        , p_dim_short_name  => l_tab_id)) LOOP
      delete_common_dimensions (
        p_tab_id        => l_tab_id
      , p_commit        => p_commit
      , x_return_status => x_return_status
      , x_msg_count     => x_msg_count
      , x_msg_data      => x_msg_data
      );

      IF (x_return_status IS NULL OR x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get
    ( p_encoded   =>  FND_API.G_FALSE
    , p_count     =>  x_msg_count
    , p_data      =>  x_msg_data
    );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data :=  x_msg_data || ' -> BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions_tabs ';
    ELSE
      x_msg_data :=  SQLERRM || ' at BSC_COMMON_DIMENSIONS_PVT.delete_common_dimensions_tabs ';
    END IF;
    RAISE;
END delete_common_dimensions_tabs;


PROCEDURE delete_user_list_access
(
 p_tab_id               IN               NUMBER
,p_dim_level_index      IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT     NOCOPY   VARCHAR2
,x_msg_count            OUT     NOCOPY   NUMBER
,x_msg_data             OUT     NOCOPY   VARCHAR2
) IS
BEGIN

IF (p_tab_id IS NOT NULL AND p_dim_level_index IS NOT NULL) THEN

    DELETE
    FROM BSC_USER_LIST_ACCESS
    WHERE tab_id = p_tab_id
      AND DIM_LEVEL_INDEX >= p_dim_level_index;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.delete_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.delete_user_list_access ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.delete_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.delete_user_list_access ';
        END IF;

        RAISE;

END delete_user_list_access;



PROCEDURE insert_user_list_access
(
 p_responsibility_id     IN               bsc_user_list_access.responsibility_id%TYPE
,p_tab_id                IN               bsc_user_list_access.tab_id%TYPE
,p_dim_level_index       IN               bsc_user_list_access.dim_level_index%TYPE
,p_dim_level_value       IN               bsc_user_list_access.dim_level_value%TYPE
,p_creation_date         IN               bsc_user_list_access.creation_date%TYPE
,p_created_by            IN               bsc_user_list_access.created_by%TYPE
,p_last_update_date      IN               bsc_user_list_access.last_update_date%TYPE
,p_last_updated_by       IN               bsc_user_list_access.last_updated_by%TYPE
,p_last_update_login     IN               bsc_user_list_access.last_update_login%TYPE
,p_commit                IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status         OUT       NOCOPY VARCHAR2
,x_msg_count             OUT       NOCOPY NUMBER
,x_msg_data              OUT       NOCOPY VARCHAR2
)
IS

BEGIN

IF (p_responsibility_id IS NOT NULL AND p_tab_id IS NOT NULL AND p_dim_level_index IS NOT NULL AND p_dim_level_value IS NOT NULL ) THEN
  IF (p_creation_date IS NOT NULL AND p_created_by IS NOT NULL AND p_last_update_date IS NOT NULL AND p_last_updated_by IS NOT NULL) THEN
    INSERT
    INTO
    bsc_user_list_access(responsibility_id,
                       tab_id,
                       dim_level_index,
                       dim_level_value,
                       creation_date,
                       created_by,
                       last_update_date,
                       last_updated_by,
                       last_update_login)
    VALUES (  p_responsibility_id
           ,p_tab_id
           ,p_dim_level_index
           ,p_dim_level_value
           ,p_creation_date
           ,p_created_by
           ,p_last_update_date
           ,p_last_updated_by
           ,p_last_update_login
         );

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.insert_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.insert_user_list_access ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.insert_user_list_access ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.insert_user_list_access ';
        END IF;

        RAISE;

END insert_user_list_access;

/********************************************************
 Procedure  : reset_dim_default_value
              This procedure resets the default value
              to 'T' for all the common dimension objects
 Input      : Tab Id
 Created By : ashankar
/********************************************************/

PROCEDURE reset_dim_default_value
(
   p_Tab_Id           IN     BSC_TABS_B.tab_id%TYPE
  ,x_return_status    OUT    NOCOPY VARCHAR2
  ,x_msg_count        OUT    NOCOPY NUMBER
  ,x_msg_data         OUT    NOCOPY VARCHAR2
) IS
 l_sql              VARCHAR2(1000);
 l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE bsc_kpi_dim_levels_b
  SET DEFAULT_VALUE = BSC_COMMON_DIMENSIONS_PVT.C_ALL
  WHERE indicator IN (
  SELECT indicator FROM bsc_tab_indicators WHERE  tab_id = p_Tab_Id )
  AND default_value like BSC_COMMON_DIMENSIONS_PVT.C_COM_DIM_DEFAULT_VALUE;

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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.reset_dim_default_value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.reset_dim_default_value ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.reset_dim_default_value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.reset_dim_default_value ';
        END IF;

        RAISE;
END reset_dim_default_value;

/********************************************************
 Procedure  : reset_dim_default_value
              This procedure resets the default value
              to 'DX' for all the common dimension objects
 Input      : Tab Id
 Created By : ashankar
/********************************************************/
PROCEDURE set_dim_default_value
(
   p_dim_level_id     IN     BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
  ,p_default_value    IN     BSC_KPI_DIM_LEVELS_B.default_value%TYPE
  ,p_Tab_Id           IN     BSC_TABS_B.tab_id%TYPE
  ,x_return_status    OUT    NOCOPY VARCHAR2
  ,x_msg_count        OUT    NOCOPY NUMBER
  ,x_msg_data         OUT    NOCOPY VARCHAR2
) IS
   l_level_table_name BSC_KPI_DIM_LEVELS_B.level_table_name%TYPE;
   l_sql              VARCHAR2(1000);
   l_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF(p_dim_level_id IS NOT NULL  AND p_default_value IS NOT NULL) THEN
      SELECT level_table_name
      INTO   l_level_table_name
      FROM   bsc_sys_dim_levels_b
      WHERE  dim_level_id = p_dim_level_id;


      UPDATE bsc_kpi_dim_levels_b
      SET DEFAULT_VALUE = p_default_value
      WHERE indicator IN (
      SELECT indicator FROM bsc_tab_indicators WHERE  tab_id = p_Tab_Id )
      AND level_table_name = l_level_table_name;

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
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.set_dim_default_value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.set_dim_default_value ';
        END IF;

        RAISE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_COMMON_DIMENSIONS_PVT.set_dim_default_value ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_COMMON_DIMENSIONS_PVT.set_dim_default_value ';
        END IF;

        RAISE;
END set_dim_default_value;

PROCEDURE Get_Parent_level_properties
(
   p_tab_id               IN   BSC_TABS_B.tab_id%TYPE
  ,p_level_index          IN   BSC_KPI_DIM_LEVELS_B.dim_level_index%TYPE
  ,x_parent_level_id      OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
  ,x_parent_level_index   OUT NOCOPY  BSC_KPI_DIM_LEVELS_B.parent_level_index%TYPE
) IS
BEGIN
    x_parent_level_id :=NULL;
    x_parent_level_index :=NULL;

    IF(p_level_index >0) THEN
     x_parent_level_index := p_level_index -1;
     SELECT dim_level_id
     INTO   x_parent_level_id
     FROM   bsc_sys_com_dim_levels
     WHERE  tab_id = p_tab_id
     AND    dim_level_index = x_parent_level_index;
    END IF;

EXCEPTION
     WHEN OTHERS THEN
      x_parent_level_id :=NULL;
      x_parent_level_index :=NULL;

END  Get_Parent_level_properties;



END BSC_COMMON_DIMENSIONS_PVT;


/

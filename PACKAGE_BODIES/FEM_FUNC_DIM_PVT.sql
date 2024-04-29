--------------------------------------------------------
--  DDL for Package Body FEM_FUNC_DIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_FUNC_DIM_PVT" AS
/* $Header: FEMVFUNCDIMB.pls 120.0 2006/05/11 05:49:14 ahyanki noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_FUNC_DIM_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------




PROCEDURE CopyFuncDimRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
);


PROCEDURE DeleteFuncDimRec(
  p_obj_def_id          IN          NUMBER
);

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------
--
-- PROCEDURE
--       CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Functional Dimension Definition(target)
--   by copying the detail records of another Functional Dimension Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS

  g_api_name    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

BEGIN


  CopyFuncDimRec(
     p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id   => p_target_obj_def_id
    ,p_created_by          => p_created_by
    ,p_creation_date       => p_creation_date

  );


EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;


--
-- PROCEDURE
--       DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records related to a  FUnctional Dimension Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
)
--------------------------------------------------------------------------------
IS

  g_api_name    CONSTANT VARCHAR2(30)   := 'DeleteObjectDefinition';

BEGIN

  DeleteFuncDimRec(
    p_obj_def_id          => p_obj_def_id
  );

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;

--
-- PROCEDURE
--       GetDataColumnDimension
--
-- DESCRIPTION
--   Fetches dimension_id and functional dimension set name for a given
--   version id, table name and column name
--
-- IN
--   p_version_id    - given version id.
--   p_table_name    - given table name.
--   p_column_name   - given column name.
--   x_dimension_id  - out parameter for dimension id.
--   x_func_dim_set_name -  out parameter for functional dimension set name.

--------------------------------------------------------------------------------
PROCEDURE GetDataColumnDimension(
  p_version_id IN NUMBER
 ,p_table_name IN VARCHAR2
 ,p_column_name IN VARCHAR2
 ,x_dimension_id OUT NOCOPY NUMBER
 ,x_func_dim_set_name OUT NOCOPY VARCHAR2
 )
--------------------------------------------------------------------------------
 IS




 TYPE FuncDimRec IS RECORD (
      dimension_id  FEM_FUNC_DIM_SETS_B.DIMENSION_ID%TYPE,
      func_dim_set_name  FEM_FUNC_DIM_SETS_TL.FUNC_DIM_SET_NAME%TYPE);
 l_func_dim_rec FuncDimRec;

 g_api_name    CONSTANT VARCHAR2(30)   := 'GetDataColumnDimension';

 BEGIN

    Select DIMENSION_ID,FUNC_DIM_SET_NAME into l_func_dim_rec
    from FEM_FUNC_DIM_SETS_VL,FEM_FUNC_DIM_SET_MAPS
    where FEM_FUNC_DIM_SETS_VL.FUNC_DIM_SET_ID = FEM_FUNC_DIM_SET_MAPS.FUNC_DIM_SET_ID
    and FEM_FUNC_DIM_SETS_VL.FUNC_DIM_SET_OBJ_DEF_ID = p_version_id
    and FEM_FUNC_DIM_SET_MAPS.TABLE_NAME = p_table_name
    and FEM_FUNC_DIM_SET_MAPS.COLUMN_NAME = p_column_name;

    x_dimension_id := l_func_dim_rec.dimension_id ;
    x_func_dim_set_name := l_func_dim_rec.func_dim_set_name ;

  EXCEPTION

  --
  WHEN OTHERS THEN

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END GetDataColumnDimension;

--
-- PROCEDURE
--       UpdateColumnDisplayNames
--
-- DESCRIPTION
--   Updates display name for a column-table combination in FEM_TAB_COLUMNS_VL
--   depending upon given set_ids in a collection.
-- IN
--   p_sets    - given set ids.
--
--------------------------------------------------------------------------------
PROCEDURE UpdateColumnDisplayNames(
  p_api_version                IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_sets IN FEM_FUNC_DIM_SET_TYP
)
-------------------------------------------------------------------------------
IS
 --
  l_api_name    CONSTANT VARCHAR2(30) := 'UpdateColumnDisplayNames';
  l_api_version CONSTANT NUMBER := 1.0;
 --
l_set_id NUMBER;
l_set_name  VARCHAR2(30);
l_table_name VARCHAR2(30);
l_column_name VARCHAR2(30);

g_api_name    CONSTANT VARCHAR2(30)   := 'UpdateColumnDisplayNames';

  CURSOR cur_fetch_table_column_combo (cur_set_id NUMBER) IS
  Select TABLE_NAME,COLUMN_NAME from
  FEM_FUNC_DIM_SET_MAPS
  where FUNC_DIM_SET_ID =  cur_set_id;

BEGIN
  SAVEPOINT Update_Column_Display_Pvt ;

    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
     THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    IF FND_API.to_Boolean ( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize ;
    END IF;
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    --

  FOR i IN p_sets.FIRST..p_sets.LAST LOOP -- Fetching corresponding l_set_name for set_ids in the array p_set_id

   Select FUNC_DIM_SET_NAME INTO l_set_name from
   FEM_FUNC_DIM_SETS_VL
   where
   FUNC_DIM_SET_ID = p_sets(i);

   l_set_id := p_sets(i);

    OPEN cur_fetch_table_column_combo (l_set_id); -- fetching table column combo for given set_id
    LOOP

	   FETCH cur_fetch_table_column_combo INTO l_table_name,l_column_name;
       EXIT WHEN cur_fetch_table_column_combo%NOTFOUND ;

          UPDATE FEM_TAB_COLUMNS_VL SET DISPLAY_NAME = l_set_name WHERE
          TABLE_NAME = l_table_name AND
          COLUMN_NAME = l_column_name ;
     END LOOP ; -- Ending inner loop
     CLOSE cur_fetch_table_column_combo ;

   END LOOP ; -- Ending outer loop

 IF FND_API.To_Boolean(p_commit)
  THEN
    COMMIT WORK;
 END IF;

 EXCEPTION

  --
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Column_Display_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );


  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Column_Display_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  --
  WHEN DUP_VAL_ON_INDEX THEN

   ROLLBACK TO Update_Column_Display_Pvt ;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('FEM', 'FEM_FUNC_DIM_DUP_DISP_UPD_ERR');
   FND_MSG_PUB.ADD;


  --
  WHEN OTHERS THEN
    ROLLBACK TO Update_Column_Display_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

 END UpdateColumnDisplayNames ;

--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--       CopyFuncDimRec
--
-- DESCRIPTION
--   Creates a new Functional Dimension Definition by copying records in the
--   FEM_FUNC_DIM_SETS_VL and FEM_FUNC_DIM_SET_MAPS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyFuncDimRec(
   p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id   IN          NUMBER
  ,p_created_by          IN          NUMBER
  ,p_creation_date       IN          DATE
)
--------------------------------------------------------------------------------
IS
  l_row_id               VARCHAR2(500);
  l_last_updated_by      NUMBER;
  l_last_update_login    NUMBER;
  l_source_table_name    VARCHAR2(50);
  l_old_func_dim_set_id  NUMBER;
  l_old_func_dim_set_map_id NUMBER;
  l_new_func_dim_set_id  NUMBER;
  l_new_func_dim_set_map_id NUMBER;

  CURSOR cur_func_dim_set_id IS
  Select FUNC_DIM_SET_ID from
  FEM_FUNC_DIM_SETS_VL
  where
  FUNC_DIM_SET_OBJ_DEF_ID = p_source_obj_def_id;

  CURSOR cur_func_dim_set_map_id (p_old_func_dim_set_id NUMBER) IS
  Select FUNC_DIM_SET_MAP_ID from
  FEM_FUNC_DIM_SET_MAPS
  where FUNC_DIM_SET_ID =  p_old_func_dim_set_id;

BEGIN
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;

  OPEN cur_func_dim_set_id ;

  LOOP

  FETCH cur_func_dim_set_id INTO l_old_func_dim_set_id;
  EXIT WHEN cur_func_dim_set_id%NOTFOUND ;
      select FEM_FUNC_DIM_SET_S.NEXTVAL into l_new_func_dim_set_id from dual;
      INSERT INTO FEM_FUNC_DIM_SETS_VL(
      LAST_UPDATE_LOGIN
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,CREATION_DATE
     ,FUNC_DIM_SET_OBJ_DEF_ID
     ,FUNC_DIM_SET_ID
     ,DIMENSION_ID
     ,OBJECT_VERSION_NUMBER
     ,CREATED_BY
     ,FUNC_DIM_SET_NAME)
      SELECT
      FND_GLOBAL.LOGIN_ID
     ,FND_GLOBAL.USER_ID
     ,SYSDATE
     ,NVL(p_creation_date,creation_date)
     ,p_target_obj_def_id
     ,l_new_func_dim_set_id
     ,DIMENSION_ID
     ,OBJECT_VERSION_NUMBER
     ,NVL(p_created_by,created_by)
     ,FUNC_DIM_SET_NAME
     FROM FEM_FUNC_DIM_SETS_VL
     WHERE FUNC_DIM_SET_OBJ_DEF_ID = p_source_obj_def_id
     AND FUNC_DIM_SET_ID = l_old_func_dim_set_id ;

   OPEN cur_func_dim_set_map_id (l_old_func_dim_set_id);

   LOOP
   FETCH cur_func_dim_set_map_id INTO l_old_func_dim_set_map_id;
   EXIT WHEN cur_func_dim_set_map_id%NOTFOUND;
     select FEM_FUNC_DIM_SET_MAP_S.NEXTVAL into l_new_func_dim_set_map_id from dual;
     INSERT INTO FEM_FUNC_DIM_SET_MAPS(
     FUNC_DIM_SET_MAP_ID
    ,FUNC_DIM_SET_ID
    ,TABLE_NAME
    ,COLUMN_NAME
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN)
     SELECT
     l_new_func_dim_set_map_id
    ,l_new_func_dim_set_id
    ,TABLE_NAME
    ,COLUMN_NAME
    ,NVL(p_created_by,created_by)
    ,NVL(p_creation_date,creation_date)
    ,FND_GLOBAL.USER_ID
    ,SYSDATE
    ,FND_GLOBAL.LOGIN_ID
     FROM FEM_FUNC_DIM_SET_MAPS
     WHERE FUNC_DIM_SET_ID = l_old_func_dim_set_id
     AND FUNC_DIM_SET_MAP_ID = l_old_func_dim_set_map_id ;
  END LOOP; -- Ending inner loop
  CLOSE cur_func_dim_set_map_id ;

 END LOOP; -- Ending outer loop
 CLOSE cur_func_dim_set_id ;

END CopyFuncDimRec;


--
-- PROCEDURE
--       DeleteFuncDimRec
--
-- DESCRIPTION
--   Deletes records related to a Functional Dimension Definition by performing deletes on records
--   in the FEM_FUNC_DIM_SET_MAPS and FEM_FUNC_DIM_SETS_VL table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteFuncDimRec(
  p_obj_def_id   IN  NUMBER
)
--------------------------------------------------------------------------------
IS

l_func_dim_set_id  NUMBER;

CURSOR cur_func_dim_set_id IS
SELECT FUNC_DIM_SET_ID FROM FEM_FUNC_DIM_SETS_VL
WHERE FUNC_DIM_SET_OBJ_DEF_ID = p_obj_def_id ;

BEGIN
  OPEN cur_func_dim_set_id;
  LOOP
  FETCH cur_func_dim_set_id INTO l_func_dim_set_id;
  EXIT WHEN cur_func_dim_set_id%NOTFOUND ;

   DELETE FROM FEM_FUNC_DIM_SET_MAPS
   WHERE FUNC_DIM_SET_ID = l_func_dim_set_id ;

  END LOOP;
  CLOSE cur_func_dim_set_id;

   DELETE FROM FEM_FUNC_DIM_SETS_VL
   WHERE FUNC_DIM_SET_OBJ_DEF_ID = p_obj_def_id;


END DeleteFuncDimRec;

END FEM_FUNC_DIM_PVT;

/

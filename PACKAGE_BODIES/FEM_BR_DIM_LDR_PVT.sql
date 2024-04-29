--------------------------------------------------------
--  DDL for Package Body FEM_BR_DIM_LDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_DIM_LDR_PVT" AS
/* $Header: FEMDIMLDRB.pls 120.0 2006/05/18 01:40:43 ugoswami noship $ */


   g_pkg_name CONSTANT VARCHAR2(30) := 'FEM_BR_DIM_LDR_PVT';
   c_module_pkg CONSTANT VARCHAR2(80) := 'fem.plsql.FEM_BR_DIM_LDR_PVT';

--------------------------------------------------------------------------------
--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the version related data stored outside of the Catalog of Objects.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
  PROCEDURE DeleteObjectDefinition(
    p_obj_def_id          IN          NUMBER
  )
  IS
    l_api_name    CONSTANT VARCHAR2(30)   := 'DeleteObjectDefinition';
  BEGIN

    FEM_ENGINES_PKG.Tech_Message (
            p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Begining Procedure'
       );

    DELETE FROM fem_dim_load_dim_params WHERE loader_obj_def_id=p_obj_def_id;
    DELETE FROM fem_dim_load_hier_params  WHERE loader_obj_def_id=p_obj_def_id;
    FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Ending Procedure'
    );



  EXCEPTION
    WHEN others THEN
      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => fnd_log.level_unexpected
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => SQLERRM
          );
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      RAISE fnd_api.g_exc_unexpected_error;


  END DeleteObjectDefinition;




----------------------------------------------------------------------------------
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Duplicates the version related data stored outside
--    of the Catalog of Objects.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--------------------------------------------------------------------------------------

  PROCEDURE CopyObjectDefinition(
     p_source_obj_def_id   IN          NUMBER
    ,p_target_obj_def_id   IN          NUMBER
    ,p_created_by          IN          NUMBER
    ,p_creation_date       IN          DATE
  )

  IS

    l_api_name    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

  BEGIN

      FEM_ENGINES_PKG.Tech_Message (
          p_severity  => fnd_log.level_procedure
         ,p_module   => c_module_pkg||'.'||l_api_name
         ,p_msg_text => 'Begining Procedure'
      );

       INSERT INTO fem_dim_load_dim_params(
           loader_obj_def_id
          ,dimension_id
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login
          ,object_version_number
          )
         SELECT
           p_target_obj_def_id
          ,dimension_id
  	  ,nvl(p_created_by,fnd_global.user_id )
          ,nvl(p_creation_date,sysdate)
          ,nvl(p_created_by,fnd_global.user_id )
          ,nvl(p_creation_date,sysdate)
          ,fnd_global.login_id
          ,0
       FROM fem_dim_load_dim_params
       WHERE loader_obj_def_id = p_source_obj_def_id;

       INSERT INTO fem_dim_load_hier_params(
                loader_comp_id
               ,loader_obj_def_id
               ,dimension_id
               ,hier_obj_id
               ,hier_obj_def_id
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
               ,object_version_number
       ) SELECT
                fem_dim_loader_comp_id_seq.nextval
               ,p_target_obj_def_id
               ,dimension_id
               ,hier_obj_id
               ,hier_obj_def_id
               ,nvl(p_created_by,fnd_global.user_id )
               ,nvl(p_creation_date,sysdate)
               ,nvl(p_created_by,fnd_global.user_id )
               ,nvl(p_creation_date,sysdate)
               ,fnd_global.login_id
               ,0
       FROM    fem_dim_load_hier_params
       WHERE  LOADER_OBJ_DEF_ID = p_source_obj_def_id;

         FEM_ENGINES_PKG.Tech_Message (
              p_severity  => fnd_log.level_procedure
             ,p_module   => c_module_pkg||'.'||l_api_name
             ,p_msg_text => 'Ending Procedure'
          );
      EXCEPTION
        WHEN others THEN
              FEM_ENGINES_PKG.Tech_Message (
          p_severity  => fnd_log.level_unexpected
          ,p_module   => c_module_pkg||'.'||l_api_name
          ,p_msg_text => SQLERRM
          );

          fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          RAISE fnd_api.g_exc_unexpected_error;

  END CopyObjectDefinition;

----------------------------------------------------------------------------------
-- FUNCTION
--	 Definition_Details_Exist
--
-- DESCRIPTION
--   Checks if the detais for a definition exist in the tables.
--
--
-- IN
--   p_obj_def_id    -  Object Definition ID.

--------------------------------------------------------------------------------------

FUNCTION DefinitionDetailsExist(p_obj_def_id NUMBER) RETURN VARCHAR2
IS
  l_no_of_rows  NUMBER;
  l_exists      VARCHAR2(1) := 'N';
  l_api_name    CONSTANT VARCHAR2(30)   := 'DefinitionDetailsExist';
BEGIN
    FEM_ENGINES_PKG.Tech_Message (
            p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Begining Function'
     );

    SELECT SUM(no_of_rows) INTO l_no_of_rows FROM
    (SELECT COUNT(*) no_of_rows FROM fem_dim_load_hier_params WHERE loader_obj_def_id = p_obj_def_id
     UNION
    SELECT COUNT(*) no_of_rows FROM fem_dim_load_dim_params WHERE loader_obj_def_id = p_obj_def_id
    );

      IF l_no_of_rows > 0 THEN
      l_exists := 'Y';
      END IF;

      FEM_ENGINES_PKG.Tech_Message (
            p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Ending Function'
      );


      RETURN l_exists;


    EXCEPTION
      WHEN others THEN
        FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_unexpected
          ,p_module   => c_module_pkg||'.'||l_api_name
          ,p_msg_text => SQLERRM
          );
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        RAISE fnd_api.g_exc_unexpected_error;

    END   DefinitionDetailsExist;


END FEM_BR_DIM_LDR_PVT;


/

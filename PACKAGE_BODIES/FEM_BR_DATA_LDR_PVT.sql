--------------------------------------------------------
--  DDL for Package Body FEM_BR_DATA_LDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_DATA_LDR_PVT" AS
/* $Header: FEMDATALDRB.pls 120.0 2006/05/17 22:33:10 ugoswami noship $ */

g_pkg_name   CONSTANT VARCHAR2(30) := 'FEM_BR_DATA_LDR_PVT';
c_module_pkg CONSTANT VARCHAR2(80) := 'fem.plsql.FEM_BR_DATA_LDR_PVT';


--------------------------------------------------------------------------------
--
-- PROCEDURE
--   DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the detail records of a Data Loader Rule Definition(Version)
--  (source) into another empty Data Loader Rule Definition (target).
--   NOTE:  It does not delete the Data Loader Rule Definition record in
--          FEM_OBJECT_DEFINITION_VL.  That record must already exist.
--
-- IN
--   p_obj_def_id           - Object Definition ID
--
--------------------------------------------------------------------------------


PROCEDURE DeleteObjectDefinition (p_obj_def_id IN NUMBER) IS

  l_api_name    CONSTANT  VARCHAR2(30) := 'DeleteObjectDefinition';
  l_api_version CONSTANT  NUMBER       :=  1.0;

  l_ver_count NUMBER;
  l_obj_id NUMBER(9);

BEGIN

    FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Begining Function'
       );

  -- Get the Object Id for the version to be deleted and
  -- check if the object has multiple versions.

    SELECT object_id INTO l_obj_id FROM fem_object_definition_vl
    WHERE object_definition_id =  p_obj_def_id;

    SELECT COUNT(*) INTO l_ver_count FROM fem_object_definition_vl
    WHERE object_id =  l_obj_id;

    DELETE FROM fem_data_loader_params
    WHERE loader_obj_def_id = p_obj_def_id;

    DELETE FROM fem_object_definition_vl
    WHERE object_definition_id = p_obj_def_id;

    -- If the object had only 1 version, then delete the object also
    IF l_ver_count = 1 THEN

      DELETE FROM fem_object_catalog_vl WHERE object_id = l_obj_id;

      DELETE FROM fem_data_loader_rules WHERE loader_obj_id = l_obj_id;

    END IF;  -- l_ver_count = 1

    FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Ending Function'
       );


EXCEPTION

  when others then

    FEM_ENGINES_PKG.Tech_Message (
        p_severity  => fnd_log.level_unexpected
        ,p_module   => c_module_pkg||'.'||l_api_name
        ,p_msg_text => SQLERRM
          );
    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    RAISE fnd_api.g_exc_unexpected_error;

END DeleteObjectDefinition;


--------------------------------------------------------------------------------
--
-- PROCEDURE
--   CopyObjectDetails
--
-- DESCRIPTION
--   Duplicates all the detail records of a Data Loader Rule  versions (source)
--   into another empty Data Loader Rule (target).
--   NOTE:  It does not copy the Data Loader Rule record in
--          FEM_OBJECT_CATALOG_VL or its versions into FEM_OBJECT_DEFINITION_VL.
--   These records must already exist, this proceudre shall only duplicate the
--   rule  data in rule specific tables.
--
-- IN
--   p_copy_type_code       - Copy Type Code
--   p_source_obj_id        - Source Object Id
--   p_target_obj_id        - Target Object Id
--   p_created_by           - Created By
--   p_creation_date        - Creation Date
--
--------------------------------------------------------------------------------

PROCEDURE CopyObjectDetails (
  p_copy_type_code      IN          VARCHAR2
  ,p_source_obj_id      IN          NUMBER
  ,p_target_obj_id      IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
) IS

  l_api_name    CONSTANT  VARCHAR2(30) := 'CopyObjectDetails';
  l_api_version CONSTANT  NUMBER       :=  1.0;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );


  INSERT INTO fem_data_loader_rules
  (
    loader_obj_id,
    loader_type,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number
  )
  SELECT
    p_target_obj_id,
    loader_type,
    p_created_by,
    p_creation_date,
    p_created_by,
    p_creation_date,
    fnd_global.login_id,
    0
  FROM fem_data_loader_rules WHERE loader_obj_id = p_source_obj_id;

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Ending Function'
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

END CopyObjectDetails;


--------------------------------------------------------------------------------
--
-- PROCEDURE
--   CopyObjectDefintion
--
-- DESCRIPTION
--   Duplicates all the parameters associated with a Data Loader Version(source)
--   into the new Data Loader Version (target)
--   NOTE:  It does not copy the Data Loader Rule Version record into
--   FEM_OBJECT_DEFINITION_VL.
--   These records must already exist, this procedure shall only duplicate the
--   rule version data in rule specific tables.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID.
--   p_creation_date        - System Date.
--
--------------------------------------------------------------------------------

PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE

) IS

  l_api_name  CONSTANT  VARCHAR2(30) := 'CopyObjectDefinition';
  l_api_version CONSTANT NUMBER      :=  1.0;

  CURSOR params_cur IS
    SELECT
    load_param_set_id,
    loader_obj_def_id,
    table_name,
    source_system_code,
    dataset_code,
    ledger_id,
    cal_period_grp_id,
    load_option,
    created_by,
    creation_date,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id,
    sysdate,
    object_version_number

  FROM fem_data_loader_params WHERE loader_obj_def_id = p_source_obj_def_id;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );

  FOR params_cur_rec IN params_cur
   LOOP

     INSERT INTO fem_data_loader_params (
       load_param_set_id,
       loader_obj_def_id,
       table_name,
       source_system_code,
       dataset_code,
       ledger_id,
       cal_period_grp_id,
       load_option,
       created_by,
       creation_date,
       last_updated_by,
       last_update_login,
       last_update_date,
       object_version_number
     )
     VALUES (
       fem_load_param_set_id_seq.nextval,
       p_target_obj_def_id,
       params_cur_rec.table_name,
       params_cur_rec.source_system_code,
       params_cur_rec.dataset_code,
       params_cur_rec.ledger_id,
       params_cur_rec.cal_period_grp_id,
       params_cur_rec.load_option,
       p_created_by,
       p_creation_date,
       fnd_global.user_id,
       fnd_global.login_id,
       sysdate,
       0
     );
   END LOOP; --loop while params_cur_rec in params_cur

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Ending Function'
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


--------------------------------------------------------------------------------
--
-- FUNCTION
--   FindDefintion
--
-- DESCRIPTION
--   This function is to be called during the Rule Import process.
--   The function indicates whether the given version id has any
--   parameters associated with it.
--
-- IN
--   p_object_definition_id - Data Loader Version ID.
--
-- OUT
--   Returns a value indicating whether any parameters exist for the given
--   definition id.
--------------------------------------------------------------------------------

FUNCTION FindDefinition (
  p_object_definition_id NUMBER
)  RETURN VARCHAR2 IS

  l_api_name     CONSTANT  VARCHAR2(30) := 'FindDefinition';
  l_param_count  NUMBER :=0;
  l_param_exists VARCHAR2(1) := 'N';

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
           p_severity  => fnd_log.level_procedure
           ,p_module   => c_module_pkg||'.'||l_api_name
           ,p_msg_text => 'Begining Function'
       );


  SELECT COUNT(*) INTO l_param_count FROM fem_data_loader_params
  WHERE loader_obj_def_id = p_object_definition_id;

  IF l_param_count > 0 THEN

    l_param_exists := 'Y';

  END IF;

  FEM_ENGINES_PKG.Tech_Message (
             p_severity  => fnd_log.level_procedure
             ,p_module   => c_module_pkg||'.'||l_api_name
             ,p_msg_text => 'Ending Function'
         );


  RETURN l_param_exists;


EXCEPTION
  WHEN others THEN

    FEM_ENGINES_PKG.Tech_Message (
          p_severity  => fnd_log.level_unexpected
          ,p_module   => c_module_pkg||'.'||l_api_name
          ,p_msg_text => SQLERRM
          );

    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    RAISE fnd_api.g_exc_unexpected_error;

END FindDefinition;

--------------------------------------------------------------------------------
--
-- FUNCTION
--   GetLoaderType
--
-- DESCRIPTION
--   This function is to be called during the Rule Import process.
--   The function returns the loader type of the rule.
--
-- IN
--   p_object_id - The Rule's Object ID.
--
-- OUT
--   Returns a value containing the loader type of the rule.
--------------------------------------------------------------------------------

FUNCTION GetLoaderType (
  p_object_id   NUMBER
)RETURN VARCHAR2  IS

  l_api_name      CONSTANT  VARCHAR2(30) := 'GetLoaderType';
  l_loader_type   VARCHAR2(10);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Begining Function'
  );

  SELECT loader_type INTO l_loader_type FROM fem_data_loader_rules WHERE
  loader_obj_id = p_object_id;

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => fnd_log.level_procedure
     ,p_module   => c_module_pkg||'.'||l_api_name
     ,p_msg_text => 'Ending Function'
  );

  RETURN l_loader_type;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    l_loader_type := NULL;

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => fnd_log.level_exception
       ,p_module   => c_module_pkg||'.'||l_api_name
       ,p_msg_text => 'Data Loader Rule does not exist '
          );

    RETURN l_loader_type;

  WHEN others THEN

    FEM_ENGINES_PKG.Tech_Message (
          p_severity  => fnd_log.level_unexpected
          ,p_module   => c_module_pkg||'.'||l_api_name
          ,p_msg_text => SQLERRM
          );

    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
    RAISE fnd_api.g_exc_unexpected_error;


END GetLoaderType;


END FEM_BR_DATA_LDR_PVT;


/

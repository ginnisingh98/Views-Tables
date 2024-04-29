--------------------------------------------------------
--  DDL for Package Body HZ_EXTENSIBILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTENSIBILITY_PVT" AS
/* $Header: ARHEXTCB.pls 120.4.12010000.2 2010/03/24 08:44:36 rgokavar ship $ */


-- =============================================================================
--                         Package variables and cursors
-- =============================================================================

   G_FILE_NAME                    CONSTANT  VARCHAR2(12)  := 'ARHEXTCB.pls';
   G_PKG_NAME                     CONSTANT  VARCHAR2(30)  := 'HZ_EXTENSIBILITY_PVT';
   G_APP_NAME                     CONSTANT  VARCHAR2(3)   := 'AR';
   G_PKG_NAME_TOKEN               CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
   G_API_NAME_TOKEN               CONSTANT  VARCHAR2(8)   := 'API_NAME';
   G_PROC_NAME_TOKEN              CONSTANT  VARCHAR2(9)   := 'PROC_NAME';
   G_SQL_ERR_MSG_TOKEN            CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';
   G_PLSQL_ERR                    CONSTANT  VARCHAR2(17)  := 'HZ_PLSQL_ERR';
   G_INVALID_PARAMS_MSG           CONSTANT  VARCHAR2(30)  := 'HZ_API_INVALID_PARAMS';

   G_USER_ID                      NUMBER  :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID                     NUMBER  :=  FND_GLOBAL.Conc_Login_Id;

   G_EQ_VAL                       CONSTANT  VARCHAR2(2) := 'EQ';
   G_GT_VAL                       CONSTANT  VARCHAR2(2) := 'GT';
   G_GE_VAL                       CONSTANT  VARCHAR2(2) := 'GE';
   G_LT_VAL                       CONSTANT  VARCHAR2(2) := 'LT';
   G_LE_VAL                       CONSTANT  VARCHAR2(2) := 'LE';

   G_TRUE                         CONSTANT  VARCHAR2(1) := 'T'; -- FND_API.G_TRUE;
   G_FALSE                        CONSTANT  VARCHAR2(1) := 'F'; -- FND_API.G_FALSE;

   -- entity name used by conc programs.
   --
   C_ORG                          CONSTANT VARCHAR2(30) := 'ORGANIZATION';
   C_PER                          CONSTANT VARCHAR2(30) := 'PERSON';

-- =============================================================================
--                 Private Procedures
-- =============================================================================

-- ----------------------
--
-- Developer debugging
-- ----------------------
PROCEDURE code_debug (p_msg  IN  VARCHAR2) IS
BEGIN
--  sri_debug ('ITEM_PVT '||p_msg);
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END code_debug;


-- -----------------------------------------------------------------------------
--  API Name:       Process_User_Attrs_For_Item
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_owner_table_id                IN   NUMBER
       ,p_owner_table_name              IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Process_User_Attrs_For_Item';
    l_pk_column_NAME         VARCHAR2(30);
    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code_values      EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_item_catalog_group_id  NUMBER;
    l_related_class_codes_list VARCHAR2(150);
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_extension_id           NUMBER;
    l_mode                   VARCHAR2(10);
    l_object_type            VARCHAR2(10);
    l_operation              VARCHAR2(1);

  BEGIN

    -------------------------------------------------------------------------
    -- First we build tables of Primary Key and Classification Code values --
    -------------------------------------------------------------------------

    IF p_owner_table_name = 'HZ_PERSON_PROFILES' THEN
       l_pk_column_name := 'PERSON_PROFILE_ID';
       l_object_type := 'PERSON';
    ELSIF p_owner_table_name = 'HZ_ORGANIZATION_PROFILES' THEN
       l_pk_column_name := 'ORGANIZATION_PROFILE_ID';
       l_object_type := 'ORG';
    ELSIF p_owner_table_name = 'HZ_LOCATIONS' THEN
       l_pk_column_name := 'LOCATION_ID';
       l_object_type := 'LOCATION';
    ELSIF p_owner_table_name = 'HZ_PARTY_SITES' THEN
       l_pk_column_name := 'PARTY_SITE_ID';
       l_object_type := 'PARTY_SITE';
    END IF;

    -----------------------
    -- Get PKs organized --
    -----------------------
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
       EGO_COL_NAME_VALUE_PAIR_OBJ(l_pk_column_name, TO_CHAR(p_owner_table_id))
      );

    ---------------------------------------------------------------
    -- If all went well with retrieving privileges, we call PUAD --
    ---------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
      p_api_version                   => 1.0
     ,p_object_name                   => p_owner_table_name
     ,p_attributes_row_table          => p_attributes_row_table
     ,p_attributes_data_table         => p_attributes_data_table
     ,p_pk_column_name_value_pairs    => l_pk_column_values
     ,p_class_code_name_value_pairs   => l_class_code_values
     ,p_user_privileges_on_object     => l_user_privileges_on_object
     ,p_entity_id                     => p_entity_id
     ,p_entity_index                  => p_entity_index
     ,p_entity_code                   => p_entity_code
     ,p_debug_level                   => p_debug_level
     ,p_init_error_handler            => p_init_error_handler
     ,p_write_to_concurrent_log       => p_write_to_concurrent_log
     ,p_init_fnd_msg_list             => p_init_fnd_msg_list
     ,p_log_errors                    => p_log_errors
     ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
     ,p_commit                        => p_commit
     ,x_extension_id                  => l_extension_id
     ,x_mode                          => l_mode
     ,x_failed_row_id_list            => x_failed_row_id_list
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => x_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );

    IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
        IF(l_extension_id IS NOT NULL) THEN
          IF(l_mode = 'CREATE') THEN
            l_operation := 'I';
          ELSE
            l_operation := 'U';
          END IF;
          HZ_POPULATE_BOT_PKG.pop_hz_extensibility(
            p_operation    => l_operation,
            p_object_type  => l_object_type,
            p_extension_id => l_extension_id);
        END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN
        IF (FND_API.To_Boolean(p_log_errors)) THEN
          IF (FND_API.To_Boolean(p_write_to_concurrent_log)) THEN
            ERROR_HANDLER.Log_Error(
              p_write_err_to_inttable         => 'Y'
             ,p_write_err_to_conclog          => 'Y'
             ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
            );
          ELSE
            ERROR_HANDLER.Log_Error(
              p_write_err_to_inttable         => 'Y'
             ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
            );
          END IF;
        END IF;

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => 'Y'
          );
        ELSE
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
          );
        END IF;

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);

      END;

END Process_User_Attrs_For_Item;

-- -----------------------------------------------------------------------------
--  API Name:       Get_User_Attrs_For_Item
--
--  Description:
--    Fetch passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Get_User_Attrs_For_Item';

    l_pk_column_values       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_user_privileges_on_object EGO_VARCHAR_TBL_TYPE;

  BEGIN

    -----------------------
    -- Get PKs organized --
    -----------------------
    l_pk_column_values :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY(
       EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_PROFILE_ID', TO_CHAR(p_org_profile_id))
      );

    ---------------------------------------------------------------
    -- If all went well with retrieving privileges, we call GUAD --
    ---------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
      p_api_version                   => p_api_version
     ,p_object_name                   => 'EGO_ITEM'
     ,p_pk_column_name_value_pairs    => l_pk_column_values
     ,p_attr_group_request_table      => p_attr_group_request_table
     ,p_user_privileges_on_object     => l_user_privileges_on_object
     ,p_entity_id                     => p_entity_id
     ,p_entity_index                  => p_entity_index
     ,p_entity_code                   => p_entity_code
     ,p_debug_level                   => p_debug_level
     ,p_init_error_handler            => p_init_error_handler
     ,p_init_fnd_msg_list             => p_init_fnd_msg_list
     ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
     ,p_commit                        => p_commit
     ,x_attributes_row_table          => x_attributes_row_table
     ,x_attributes_data_table         => x_attributes_data_table
     ,x_return_status                 => x_return_status
     ,x_errorcode                     => x_errorcode
     ,x_msg_count                     => x_msg_count
     ,x_msg_data                      => x_msg_data
    );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      x_msg_count := ERROR_HANDLER.Get_Message_Count();

      IF (x_msg_count > 0) THEN
        ERROR_HANDLER.Log_Error(
          p_write_err_to_inttable         => 'Y'
         ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
        );

        IF (x_msg_count = 1) THEN
          DECLARE
            message_list  ERROR_HANDLER.Error_Tbl_Type;
          BEGIN
            ERROR_HANDLER.Get_Message_List(message_list);
            x_msg_data := message_list(message_list.FIRST).message_text;
          END;
        ELSE
          x_msg_data := NULL;
        END IF;
      END IF;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
        l_dummy_entity_index     NUMBER;
        l_dummy_entity_id        VARCHAR2(60);
        l_dummy_message_type     VARCHAR2(1);
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        IF (FND_API.To_Boolean(p_add_errors_to_fnd_stack)) THEN
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_addto_fnd_stack               => 'Y'
          );
        ELSE
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_PLSQL_ERR'
           ,p_application_id                => 'EGO'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
          );
        END IF;

        ERROR_HANDLER.Get_Message(x_message_text => x_msg_data
                                 ,x_entity_index => l_dummy_entity_index
                                 ,x_entity_id    => l_dummy_entity_id
                                 ,x_message_type => l_dummy_message_type);

      END;

END Get_User_Attrs_For_Item;

/**
 * PROCEDURE copy_person_extent_data
 *
 * DESCRIPTION
 *     Copy person extent data. This procedure will be called whenever
 *     a new person profile is created for maintain history reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_old_profile_id                Old profile Id.
 *     p_new_profile_id                New profile Id.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                 Return status after the call. The status can
 *                                     be FND_API.G_RET_STS_SUCCESS (success),
 *                                     FND_API.G_RET_STS_ERROR (error),
 *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-01-2004    Jianying Huang      o Created.
 *
 */

PROCEDURE copy_person_extent_data (
    p_old_profile_id              IN     NUMBER,
    p_new_profile_id              IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                VARCHAR2(30) := '';
    l_created_by                  NUMBER;
    l_last_update_login           NUMBER;
    l_last_updated_by             NUMBER;

BEGIN

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                  => l_debug_prefix,
        p_message                 => 'copy_person_extent_data (+)',
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    l_created_by := hz_utility_v2pub.created_by;
    l_last_update_login := hz_utility_v2pub.last_update_login;
    l_last_updated_by := hz_utility_v2pub.last_updated_by;

    -- This code will copy the existing profile extension records over
    -- to the new profile _id everytime the SST record id is changed.
    -- When the record is copied the original extension_id is stored
    -- in the old_extension_id column of the record, so that it can be
    -- used by the CPUI componenet.

    INSERT INTO HZ_PER_PROFILES_EXT_B (
      extension_id,
      person_profile_id,
      attr_group_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      old_extension_id )
    SELECT
      ego_extfwk_s.nextval,
      p_new_profile_id,
      attr_group_id,
      l_created_by,
      SYSDATE,
      l_last_updated_by,
      SYSDATE,
      l_last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      extension_id
    FROM HZ_PER_PROFILES_EXT_B
    WHERE person_profile_id = p_old_profile_id;

    IF (SQL%ROWCOUNT > 0) THEN
      INSERT INTO HZ_PER_PROFILES_EXT_TL (
        extension_id,
        person_profile_id,
        attr_group_id,
        source_lang,
        language,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        tl_ext_attr1,
        tl_ext_attr2,
        tl_ext_attr3,
        tl_ext_attr4,
        tl_ext_attr5,
        tl_ext_attr6,
        tl_ext_attr7,
        tl_ext_attr8,
        tl_ext_attr9,
        tl_ext_attr10,
        tl_ext_attr11,
        tl_ext_attr12,
        tl_ext_attr13,
        tl_ext_attr14,
        tl_ext_attr15,
        tl_ext_attr16,
        tl_ext_attr17,
        tl_ext_attr18,
        tl_ext_attr19,
        tl_ext_attr20
      )
      SELECT
        b.extension_id,
        p_new_profile_id,
        tl.attr_group_id,
        tl.source_lang,
        tl.language,
        l_created_by,
        SYSDATE,
        l_last_updated_by,
        SYSDATE,
        l_last_update_login,
        tl.tl_ext_attr1,
        tl.tl_ext_attr2,
        tl.tl_ext_attr3,
        tl.tl_ext_attr4,
        tl.tl_ext_attr5,
        tl.tl_ext_attr6,
        tl.tl_ext_attr7,
        tl.tl_ext_attr8,
        tl.tl_ext_attr9,
        tl.tl_ext_attr10,
        tl.tl_ext_attr11,
        tl.tl_ext_attr12,
        tl.tl_ext_attr13,
        tl.tl_ext_attr14,
        tl.tl_ext_attr15,
        tl.tl_ext_attr16,
        tl.tl_ext_attr17,
        tl.tl_ext_attr18,
        tl.tl_ext_attr19,
        tl.tl_ext_attr20
      FROM HZ_PER_PROFILES_EXT_B b,
           HZ_PER_PROFILES_EXT_TL tl
      WHERE b.person_profile_id = p_new_profile_id
      AND   tl.extension_id = b.old_extension_id;
    END IF;


    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                  => l_debug_prefix,
        p_message                 => 'copy_person_extent_data (-)',
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END copy_person_extent_data;


/**
 * PROCEDURE copy_org_extent_data
 *
 * DESCRIPTION
 *     Copy organization extent data. This procedure will be called whenever
 *     a new organization profile is created for maintain history reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_old_profile_id                Old profile Id.
 *     p_new_profile_id                New profile Id.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                 Return status after the call. The status can
 *                                     be FND_API.G_RET_STS_SUCCESS (success),
 *                                     FND_API.G_RET_STS_ERROR (error),
 *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-01-2004    Jianying Huang      o Created.
 *
 */

PROCEDURE copy_org_extent_data (
    p_old_profile_id              IN     NUMBER,
    p_new_profile_id              IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
) IS

    l_debug_prefix                VARCHAR2(30) := '';
    l_created_by                  NUMBER;
    l_last_update_login           NUMBER;
    l_last_updated_by             NUMBER;

BEGIN

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                  => l_debug_prefix,
        p_message                 => 'copy_org_extent_data (+)',
        p_msg_level               => fnd_log.level_procedure);
    END IF;

    l_created_by := hz_utility_v2pub.created_by;
    l_last_update_login := hz_utility_v2pub.last_update_login;
    l_last_updated_by := hz_utility_v2pub.last_updated_by;

    -- This code will copy the existing profile extension records over
    -- to the new profile _id everytime the SST record id is changed.
    -- When the record is copied the original extension_id is stored
    -- in the old_extension_id column of the record, so that it can be
    -- used by the CPUI componenet.

    INSERT INTO hz_org_profiles_ext_b (
      extension_id,
      organization_profile_id,
      attr_group_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      old_extension_id )
    SELECT
      ego_extfwk_s.nextval,
      p_new_profile_id,
      attr_group_id,
      l_created_by,
      SYSDATE,
      l_last_updated_by,
      SYSDATE,
      l_last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      extension_id
    FROM hz_org_profiles_ext_b
    WHERE organization_profile_id = p_old_profile_id;

    IF (SQL%ROWCOUNT > 0) THEN
      INSERT INTO hz_org_profiles_ext_tl (
        extension_id,
        organization_profile_id,
        attr_group_id,
        source_lang,
        language,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        tl_ext_attr1,
        tl_ext_attr2,
        tl_ext_attr3,
        tl_ext_attr4,
        tl_ext_attr5,
        tl_ext_attr6,
        tl_ext_attr7,
        tl_ext_attr8,
        tl_ext_attr9,
        tl_ext_attr10,
        tl_ext_attr11,
        tl_ext_attr12,
        tl_ext_attr13,
        tl_ext_attr14,
        tl_ext_attr15,
        tl_ext_attr16,
        tl_ext_attr17,
        tl_ext_attr18,
        tl_ext_attr19,
        tl_ext_attr20
      )
      SELECT
        b.extension_id,
        p_new_profile_id,
        tl.attr_group_id,
        tl.source_lang,
        tl.language,
        l_created_by,
        SYSDATE,
        l_last_updated_by,
        SYSDATE,
        l_last_update_login,
        tl.tl_ext_attr1,
        tl.tl_ext_attr2,
        tl.tl_ext_attr3,
        tl.tl_ext_attr4,
        tl.tl_ext_attr5,
        tl.tl_ext_attr6,
        tl.tl_ext_attr7,
        tl.tl_ext_attr8,
        tl.tl_ext_attr9,
        tl.tl_ext_attr10,
        tl.tl_ext_attr11,
        tl.tl_ext_attr12,
        tl.tl_ext_attr13,
        tl.tl_ext_attr14,
        tl.tl_ext_attr15,
        tl.tl_ext_attr16,
        tl.tl_ext_attr17,
        tl.tl_ext_attr18,
        tl.tl_ext_attr19,
        tl.tl_ext_attr20
      FROM hz_org_profiles_ext_b b,
           hz_org_profiles_ext_tl tl
      WHERE b.organization_profile_id = p_new_profile_id
      AND   tl.extension_id = b.old_extension_id;
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug(
        p_prefix                  => l_debug_prefix,
        p_message                 => 'copy_org_extent_data (-)',
        p_msg_level               => fnd_log.level_procedure);
    END IF;

END copy_org_extent_data;


/**
 * PRIVATE PROCEDURE Write_Log
 *
 * DESCRIPTION
 *   Write message into log file.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_str                        Message.
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE Write_Log (
    p_str                         IN     VARCHAR2
) IS
BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,TO_CHAR(SYSDATE, 'YYYY/MM/DD HH:MI:SS')||' -- '||p_str);
END Write_Log;


/**
 * PRIVATE PROCEDURE populate_staging_table
 *
 * DESCRIPTION
 *   Populate staging table.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_name                Entity Name
 *   p_batch_size                 Batch Size
 * OUT:
 *   x_total                      Number of records in staging table
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 *   03-15-2010  Sudhir Gokavarapu Added Content Source Security
 *                                 Disable and Enable statements to process other profiles
 *                                 Instead of only SST records.
 *                                 Considering only SST and USER_ENTERED profiles to avoid all other ACS types.
 */

PROCEDURE populate_staging_table (
    p_entity_name                 IN     VARCHAR2,
    p_batch_size                  IN     NUMBER,
    x_total                       OUT    NOCOPY NUMBER
) IS

BEGIN
hz_common_pub.disable_cont_source_security;
    IF p_entity_name = C_ORG THEN
      -- insert into org staging table
      --
      INSERT INTO hz_org_profiles_ext_sg (
          old_profile_id,
          new_profile_id,
          work_unit_number,
          status
      )
      SELECT old_profile_id,
             new_profile_id,
             round(ROWNUM/p_batch_size + 0.5) work_unit_number,
             'N' status
      FROM (
        SELECT /*+ parallel(p1) parallel(p2) */
               max(p2.organization_profile_id) old_profile_id, p1.organization_profile_id new_profile_id
        FROM   hz_organization_profiles p1,
               hz_organization_profiles p2
        WHERE  p1.effective_end_date is null
        AND    p1.actual_content_source IN ('SST','USER_ENTERED')
        AND    p2.actual_content_source IN ('SST','USER_ENTERED')
        AND    NOT EXISTS (
                 SELECT null
                 FROM   hz_org_profiles_ext_b ext
                 WHERE  p1.organization_profile_id = ext.organization_profile_id)
        AND    p2.party_id = p1.party_id
        AND    p2.organization_profile_id <> p1.organization_profile_id
        AND    EXISTS (
                 SELECT null
                 FROM   hz_org_profiles_ext_b ext
                 WHERE  p2.organization_profile_id = ext.organization_profile_id)
        GROUP BY p1.organization_profile_id);

    ELSIF p_entity_name = C_PER THEN
      -- insert into person staging table
      --
      INSERT INTO hz_per_profiles_ext_sg (
          old_profile_id,
          new_profile_id,
          work_unit_number,
          status
      )
      SELECT old_profile_id,
             new_profile_id,
             round(ROWNUM/p_batch_size + 0.5) work_unit_number,
             'N' status
      FROM (
        SELECT /*+ parallel(p1) parallel(p2) */
               max(p2.person_profile_id) old_profile_id, p1.person_profile_id new_profile_id
        FROM   hz_person_profiles p1,
               hz_person_profiles p2
        WHERE  p1.effective_end_date is null
        AND    p1.actual_content_source IN ('SST','USER_ENTERED')
        AND    p2.actual_content_source IN ('SST','USER_ENTERED')
        AND    NOT EXISTS (
                 SELECT null
                 FROM   hz_per_profiles_ext_b ext
                 WHERE  p1.person_profile_id = ext.person_profile_id)
        AND    p2.party_id = p1.party_id
        AND    p2.person_profile_id <> p1.person_profile_id
        AND    EXISTS (
                 SELECT null
                 FROM   hz_per_profiles_ext_b ext
                 WHERE  p2.person_profile_id = ext.person_profile_id)
        GROUP BY p1.person_profile_id);

    END IF;

    x_total := SQL%ROWCOUNT;

    COMMIT;
hz_common_pub.enable_cont_source_security;
END populate_staging_table;


/**
 * PRIVATE PROCEDURE update_staging_status
 *
 * DESCRIPTION
 *   Update staging table status column
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_name                Entity Name
 *   p_work_unit_number           Work Unit Number
 *   p_status                     Status
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE update_staging_status (
    p_entity_name                 IN     VARCHAR2,
    p_work_unit_number            IN     NUMBER,
    p_status                      IN     VARCHAR2
) IS
BEGIN

    IF p_entity_name = C_ORG THEN
      -- update org staging table
      --
      UPDATE hz_org_profiles_ext_sg
      SET    status = p_status
      WHERE  work_unit_number = p_work_unit_number;

    ELSIF p_entity_name = C_PER THEN
      -- update per staging table
      --
      UPDATE hz_per_profiles_ext_sg
      SET    status = p_status
      WHERE  work_unit_number = p_work_unit_number;

    END IF;

END update_staging_status;


/**
 * PRIVATE PROCEDURE copy_org_extension
 *
 * DESCRIPTION
 *   Copy organization extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *   p_work_unit_number           Work Unit Number
 *   p_created_by                 Created By
 *   p_last_updated_by            Last Updated By
 *   p_last_update_login          Last Update Login
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_org_extension (
    p_parent_request_id           IN     NUMBER,
    p_work_unit_number            IN     NUMBER,
    p_created_by                  IN     NUMBER,
    p_last_updated_by             IN     NUMBER,
    p_last_update_login           IN     NUMBER
) IS
BEGIN

    -- insert into _b table
    --
    INSERT INTO hz_org_profiles_ext_b ext (
      extension_id,
      organization_profile_id,
      attr_group_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      old_extension_id )
    SELECT
      ego_extfwk_s.nextval,
      sg.new_profile_id,
      attr_group_id,
      p_created_by,
      SYSDATE,
      p_last_updated_by,
      SYSDATE,
      p_last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      extension_id
    FROM hz_org_profiles_ext_b b,
         hz_org_profiles_ext_sg sg
    WHERE
         sg.work_unit_number = p_work_unit_number
    AND  b.organization_profile_id = sg.old_profile_id;

    Write_Log(SQL%ROWCOUNT||' records inserted into org base table.');

    IF (SQL%ROWCOUNT IS NULL) OR (SQL%ROWCOUNT = 0) THEN
      RETURN;
    END IF;

    -- gather table statistics
    --
    fnd_stats.gather_table_stats('AR', 'HZ_ORG_PROFILES_EXT_B');

    -- insert into _tl table
    --
    INSERT INTO hz_org_profiles_ext_tl ext (
      extension_id,
      organization_profile_id,
      attr_group_id,
      source_lang,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      tl_ext_attr1,
      tl_ext_attr2,
      tl_ext_attr3,
      tl_ext_attr4,
      tl_ext_attr5,
      tl_ext_attr6,
      tl_ext_attr7,
      tl_ext_attr8,
      tl_ext_attr9,
      tl_ext_attr10,
      tl_ext_attr11,
      tl_ext_attr12,
      tl_ext_attr13,
      tl_ext_attr14,
      tl_ext_attr15,
      tl_ext_attr16,
      tl_ext_attr17,
      tl_ext_attr18,
      tl_ext_attr19,
      tl_ext_attr20
    )
    SELECT
      b.extension_id,
      sg.new_profile_id,
      tl.attr_group_id,
      tl.source_lang,
      tl.language,
      p_created_by,
      SYSDATE,
      p_last_updated_by,
      SYSDATE,
      p_last_update_login,
      tl.tl_ext_attr1,
      tl.tl_ext_attr2,
      tl.tl_ext_attr3,
      tl.tl_ext_attr4,
      tl.tl_ext_attr5,
      tl.tl_ext_attr6,
      tl.tl_ext_attr7,
      tl.tl_ext_attr8,
      tl.tl_ext_attr9,
      tl.tl_ext_attr10,
      tl.tl_ext_attr11,
      tl.tl_ext_attr12,
      tl.tl_ext_attr13,
      tl.tl_ext_attr14,
      tl.tl_ext_attr15,
      tl.tl_ext_attr16,
      tl.tl_ext_attr17,
      tl.tl_ext_attr18,
      tl.tl_ext_attr19,
      tl.tl_ext_attr20
    FROM hz_org_profiles_ext_b b,
         hz_org_profiles_ext_tl tl,
         hz_org_profiles_ext_sg sg
    WHERE
         sg.work_unit_number = p_work_unit_number
    AND  b.organization_profile_id = sg.new_profile_id
    AND  tl.extension_id = b.old_extension_id;

    Write_Log(SQL%ROWCOUNT||' records inserted into org tl table.');

    -- gather table statistics
    --
    fnd_stats.gather_table_stats('AR', 'HZ_ORG_PROFILES_EXT_TL');

END copy_org_extension;


/**
 * PRIVATE PROCEDURE copy_per_extension
 *
 * DESCRIPTION
 *   Copy person extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *   p_work_unit_number           Work Unit Number
 *   p_created_by                 Created By
 *   p_last_updated_by            Last Updated By
 *   p_last_update_login          Last Update Login
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_per_extension (
    p_parent_request_id           IN     NUMBER,
    p_work_unit_number            IN     NUMBER,
    p_created_by                  IN     NUMBER,
    p_last_updated_by             IN     NUMBER,
    p_last_update_login           IN     NUMBER
) IS
BEGIN

    -- insert into _b table
    --
    INSERT INTO hz_per_profiles_ext_b ext (
      extension_id,
      person_profile_id,
      attr_group_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      old_extension_id )
    SELECT
      ego_extfwk_s.nextval,
      sg.new_profile_id,
      attr_group_id,
      p_created_by,
      SYSDATE,
      p_last_updated_by,
      SYSDATE,
      p_last_update_login,
      c_ext_attr1,
      c_ext_attr2,
      c_ext_attr3,
      c_ext_attr4,
      c_ext_attr5,
      c_ext_attr6,
      c_ext_attr7,
      c_ext_attr8,
      c_ext_attr9,
      c_ext_attr10,
      c_ext_attr11,
      c_ext_attr12,
      c_ext_attr13,
      c_ext_attr14,
      c_ext_attr15,
      c_ext_attr16,
      c_ext_attr17,
      c_ext_attr18,
      c_ext_attr19,
      c_ext_attr20,
      n_ext_attr1,
      n_ext_attr2,
      n_ext_attr3,
      n_ext_attr4,
      n_ext_attr5,
      n_ext_attr6,
      n_ext_attr7,
      n_ext_attr8,
      n_ext_attr9,
      n_ext_attr10,
      n_ext_attr11,
      n_ext_attr12,
      n_ext_attr13,
      n_ext_attr14,
      n_ext_attr15,
      n_ext_attr16,
      n_ext_attr17,
      n_ext_attr18,
      n_ext_attr19,
      n_ext_attr20,
      d_ext_attr1,
      d_ext_attr2,
      d_ext_attr3,
      d_ext_attr4,
      d_ext_attr5,
      d_ext_attr6,
      d_ext_attr7,
      d_ext_attr8,
      d_ext_attr9,
      d_ext_attr10,
      extension_id
    FROM hz_per_profiles_ext_b b,
         hz_per_profiles_ext_sg sg
    WHERE
         sg.work_unit_number = p_work_unit_number
    AND  b.person_profile_id = sg.old_profile_id;

    Write_Log(SQL%ROWCOUNT||' records inserted into per base table.');

    IF (SQL%ROWCOUNT IS NULL) OR (SQL%ROWCOUNT = 0) THEN
      RETURN;
    END IF;

    -- gather table statistics
    --
    fnd_stats.gather_table_stats('AR', 'HZ_PER_PROFILES_EXT_B');

    -- insert into _tl table
    --
    INSERT INTO hz_per_profiles_ext_tl ext (
      extension_id,
      person_profile_id,
      attr_group_id,
      source_lang,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      tl_ext_attr1,
      tl_ext_attr2,
      tl_ext_attr3,
      tl_ext_attr4,
      tl_ext_attr5,
      tl_ext_attr6,
      tl_ext_attr7,
      tl_ext_attr8,
      tl_ext_attr9,
      tl_ext_attr10,
      tl_ext_attr11,
      tl_ext_attr12,
      tl_ext_attr13,
      tl_ext_attr14,
      tl_ext_attr15,
      tl_ext_attr16,
      tl_ext_attr17,
      tl_ext_attr18,
      tl_ext_attr19,
      tl_ext_attr20
    )
    SELECT
      b.extension_id,
      sg.new_profile_id,
      tl.attr_group_id,
      tl.source_lang,
      tl.language,
      p_created_by,
      SYSDATE,
      p_last_updated_by,
      SYSDATE,
      p_last_update_login,
      tl.tl_ext_attr1,
      tl.tl_ext_attr2,
      tl.tl_ext_attr3,
      tl.tl_ext_attr4,
      tl.tl_ext_attr5,
      tl.tl_ext_attr6,
      tl.tl_ext_attr7,
      tl.tl_ext_attr8,
      tl.tl_ext_attr9,
      tl.tl_ext_attr10,
      tl.tl_ext_attr11,
      tl.tl_ext_attr12,
      tl.tl_ext_attr13,
      tl.tl_ext_attr14,
      tl.tl_ext_attr15,
      tl.tl_ext_attr16,
      tl.tl_ext_attr17,
      tl.tl_ext_attr18,
      tl.tl_ext_attr19,
      tl.tl_ext_attr20
    FROM hz_per_profiles_ext_b b,
         hz_per_profiles_ext_tl tl,
         hz_per_profiles_ext_sg sg
    WHERE
         sg.work_unit_number = p_work_unit_number
    AND  b.person_profile_id = sg.new_profile_id
    AND  tl.extension_id = b.old_extension_id;

    Write_Log(SQL%ROWCOUNT||' records inserted into per tl table.');

    -- gather table statistics
    --
    fnd_stats.gather_table_stats('AR', 'HZ_PER_PROFILES_EXT_TL');

END copy_per_extension;


/**
 * PUBLIC PROCEDURE copy_conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program to copy org extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_conc_sub (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_entity_name                 IN     VARCHAR2,
    p_parent_request_id           IN     NUMBER
) IS

    CURSOR c_org_work_unit IS
    SELECT work_unit_number
    FROM   hz_org_profiles_ext_sg
    WHERE  status = 'N'
    AND    ROWNUM =1;

    CURSOR c_per_work_unit IS
    SELECT work_unit_number
    FROM   hz_per_profiles_ext_sg
    WHERE  status = 'N'
    AND    ROWNUM =1;

    CURSOR c_lock_org_records (
      p_work_unit_number          NUMBER
    ) IS
    SELECT *
    FROM   hz_org_profiles_ext_sg
    WHERE  status = 'N'
    AND    work_unit_number = p_work_unit_number
    FOR UPDATE NOWAIT;

    CURSOR c_lock_per_records (
      p_work_unit_number          NUMBER
    ) IS
    SELECT *
    FROM   hz_per_profiles_ext_sg
    WHERE  status = 'N'
    AND    work_unit_number = p_work_unit_number
    FOR UPDATE NOWAIT;

    resource_busy                 EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy, -54);

    l_created_by                  NUMBER;
    l_last_updated_by             NUMBER;
    l_last_update_login           NUMBER;
    l_work_unit_number            NUMBER;

BEGIN

    retcode := 0;

    -- retrieve who information
    --
    l_created_by := hz_utility_v2pub.created_by;
    l_last_update_login := hz_utility_v2pub.last_update_login;
    l_last_updated_by := hz_utility_v2pub.last_updated_by;

    -- find out if there is any work units need to be processed
    --
    LOOP

      <<next_fetch>>

      -- get work unit number
      --
      IF p_entity_name = C_ORG THEN
        OPEN c_org_work_unit;
        FETCH c_org_work_unit INTO l_work_unit_number;
        IF c_org_work_unit%NOTFOUND THEN
          l_work_unit_number := 0;
        END IF;
        CLOSE c_org_work_unit;

      ELSIF p_entity_name = C_PER THEN
        OPEN c_per_work_unit;
        FETCH c_per_work_unit INTO l_work_unit_number;
        IF c_per_work_unit%NOTFOUND THEN
          l_work_unit_number := 0;
        END IF;
        CLOSE c_per_work_unit;

      END IF;

      IF l_work_unit_number = 0 THEN
        Write_Log('No more records need to be processed. Quit.');
        RETURN;
      END IF;

      Write_Log('l_work_unit_number = '||l_work_unit_number);

      -- lock records
      --
      BEGIN
        IF p_entity_name = C_ORG THEN
          OPEN c_lock_org_records(l_work_unit_number);
          CLOSE c_lock_org_records;

        ELSIF p_entity_name = C_PER THEN
          OPEN c_lock_per_records(l_work_unit_number);
          CLOSE c_lock_per_records;

        END IF;

      EXCEPTION
        WHEN resource_busy THEN
          GOTO next_fetch;
      END;

      -- update status to 'P' for processing
      --
      update_staging_status(p_entity_name, l_work_unit_number, 'P');
      Write_Log(SQL%ROWCOUNT||' records have been locked.');

      COMMIT;

      -- insert into extension tables
      --
      BEGIN
        IF p_entity_name = C_ORG THEN
          copy_org_extension(
            p_parent_request_id, l_work_unit_number,
            l_created_by, l_last_updated_by, l_last_update_login);

        ELSIF p_entity_name = C_PER THEN
          copy_per_extension(
            p_parent_request_id, l_work_unit_number,
            l_created_by, l_last_updated_by, l_last_update_login);

        END IF;

        -- set status to 'C' for complete
        --
        update_staging_status(p_entity_name, l_work_unit_number, 'C');

      EXCEPTION
        WHEN OTHERS THEN
          -- stop the processing
          --
          retcode := 2;
          RETURN;
      END;

      COMMIT;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;

END copy_conc_sub;


/**
 * PUBLIC PROCEDURE copy_conc_main
 *
 * DESCRIPTION
 *   Main program to copy extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_name                Entity Name
 *   p_batch_size                 Batch Size
 *   p_number_of_worker           Number of Worker
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_conc_main (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_entity_name                 IN     VARCHAR2,
    p_batch_size                  IN     NUMBER,
    p_number_of_worker            IN     NUMBER
) IS

    CURSOR c_org_extension_exists IS
      SELECT 'Y'
      FROM   hz_org_profiles_ext_b
      WHERE  rownum = 1;

    CURSOR c_per_extension_exists IS
      SELECT 'Y'
      FROM   hz_per_profiles_ext_b
      WHERE  rownum = 1;

    l_owner                       VARCHAR2(100);
    l_do_copy                     VARCHAR2(1);
    l_batch_size                  NUMBER;
    l_number_of_worker            NUMBER;
    l_total                       NUMBER;
    l_parent_request_id           NUMBER;
    l_sub_conc_program            VARCHAR2(30);
    l_sub_request_id              NUMBER;
    l_sql                         VARCHAR2(200);

BEGIN

    retcode := 0;

    -- return if no history tracking
    --
    IF fnd_profile.value('HZ_PROFILE_VERSION') = 'NO_VERSION' THEN
      Write_Log('Profile HZ_PROFILE_VERSION has NO_VERSION.');
      Write_Log('Quit. No records need to be processed.');
      RETURN;
    END IF;

    -- return if extension table is empty
    --
    IF p_entity_name = C_ORG THEN
      OPEN c_org_extension_exists;
      FETCH c_org_extension_exists INTO l_do_copy;
      IF c_org_extension_exists%NOTFOUND THEN
        l_do_copy := 'N';
      END IF;
      CLOSE c_org_extension_exists;

    ELSIF p_entity_name = C_PER THEN
      OPEN c_per_extension_exists;
      FETCH c_per_extension_exists INTO l_do_copy;
      IF c_per_extension_exists%NOTFOUND THEN
        l_do_copy := 'N';
      END IF;
      CLOSE c_per_extension_exists;

    END IF;

    IF l_do_copy = 'N' THEN
      Write_Log('No records in extension table. Quit.');
      RETURN;
    END IF;

    -- truncate staging table
    --
    Write_Log('Truncating staging table ...');
    l_owner := hz_utility_v2pub.Get_SchemaName('AR');
    Write_Log('l_owner = '||l_owner);

    l_sql := 'truncate table '||l_owner||'.';
    IF p_entity_name = C_ORG THEN
      l_sql := l_sql||'HZ_ORG_PROFILES_EXT_SG';
    ELSE
      l_sql := l_sql||'HZ_PER_PROFILES_EXT_SG';
    END IF;
    execute immediate l_sql;

    -- validate parameters
    --
    IF (p_batch_size IS NULL OR p_batch_size < 1000) THEN
      l_batch_size := 1000;
    ELSE
      l_batch_size := p_batch_size;
    END IF;
    Write_Log('p_batch_size = '||p_batch_size);
    Write_Log('l_batch_size = '||l_batch_size);

    IF (p_number_of_worker IS NULL OR p_number_of_worker < 1) THEN
      l_number_of_worker := 1;
    ELSE
      l_number_of_worker := p_number_of_worker;
    END IF;
    Write_Log('p_number_of_worker = '||p_number_of_worker);
    Write_Log('l_number_of_worker = '||l_number_of_worker);

    -- fetch records need to be processed into staging table and
    -- split the staging table into multiple segments based on batch size
    --
    Write_Log('Populate staging table ...');
    populate_staging_table(p_entity_name, l_batch_size, l_total);
    Write_Log('l_total = '||l_total);

    IF (l_total = 0) THEN
      Write_Log('No records in staging table. Quit.');
      RETURN;
    END IF;

    -- get parent request id
    --
    l_parent_request_id := hz_utility_v2pub.request_id;
    Write_Log('l_parent_request_id = '||l_parent_request_id);

    -- submit sub requests
    --
    IF (l_number_of_worker = 1) THEN
      copy_conc_sub(errbuf, retcode, p_entity_name, l_parent_request_id);
    ELSE
      FOR i IN 1..l_number_of_worker LOOP
        IF p_entity_name = C_ORG THEN
          l_sub_conc_program := 'ARHCOEXS';
        ELSIF p_entity_name = C_PER THEN
          l_sub_conc_program := 'ARHCPEXS';
        END IF;

        l_sub_request_id :=
          FND_REQUEST.SUBMIT_REQUEST(
            'AR', l_sub_conc_program, '',
            SYSDATE, FALSE,
            TO_CHAR(l_parent_request_id));

        IF l_sub_request_id = 0 THEN
          Write_Log('Failed to submit concurrent request.');
          retcode := 2;
          RETURN;
        ELSE
          Write_Log('l_sub_request_id = '||l_sub_request_id);
        END IF;
      END LOOP;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;

END copy_conc_main;


/**
 * PUBLIC PROCEDURE copy_org_conc_main
 *
 * DESCRIPTION
 *   Main concurrent program to copy organization extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_batch_size                 Batch Size
 *   p_number_of_worker           Number of Worker
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_org_conc_main (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_batch_size                  IN     NUMBER,
    p_number_of_worker            IN     NUMBER
) IS
BEGIN

    copy_conc_main (
      errbuf, retcode,
      C_ORG,
      p_batch_size,
      p_number_of_worker
    );

END copy_org_conc_main;


/**
 * PUBLIC PROCEDURE copy_per_conc_main
 *
 * DESCRIPTION
 *   Main concurrent program to copy person extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_batch_size                 Batch Size
 *   p_number_of_worker           Number of Worker
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_per_conc_main (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_batch_size                  IN     NUMBER,
    p_number_of_worker            IN     NUMBER
) IS
BEGIN

    copy_conc_main (
      errbuf, retcode,
      C_PER,
      p_batch_size,
      p_number_of_worker
    );

END copy_per_conc_main;


/**
 * PUBLIC PROCEDURE copy_org_conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program to copy organization extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_org_conc_sub (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_parent_request_id           IN     NUMBER
) IS
BEGIN

    copy_conc_sub (
      errbuf, retcode,
      C_ORG,
      p_parent_request_id
    );

END copy_org_conc_sub;


/**
 * PUBLIC PROCEDURE copy_per_conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program to copy person extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_per_conc_sub (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_parent_request_id           IN     NUMBER
) IS
BEGIN

    copy_conc_sub (
      errbuf, retcode,
      C_PER,
      p_parent_request_id
    );

END copy_per_conc_sub;

END HZ_EXTENSIBILITY_PVT;

/

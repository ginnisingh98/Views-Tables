--------------------------------------------------------
--  DDL for Package Body EGO_CHANGE_PEOPLE_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CHANGE_PEOPLE_IMPORT_PKG" AS
/* $Header: EGOCPIB.pls 120.1 2006/02/22 23:41:03 msarkhel noship $ */

  --------------------------------------------------------------------
  -- OPEN ISSUES:
  --
  --------------------------------------------------------------------

-- =================================================================
-- Global variables used in Concurrent Program.
-- =================================================================

  G_USER_ID         NUMBER  :=  -1;
  G_LOGIN_ID        NUMBER  :=  -1;
  G_PROG_APPID      NUMBER  :=  -1;
  G_PROG_ID         NUMBER  :=  -1;
  G_REQUEST_ID      NUMBER  :=  -1;

-- =================================================================
-- Global constants that need to be used.
-- =================================================================
  -- The user language (to display the error messages in appropriate language)
  G_SESSION_LANG           VARCHAR2(99) := USERENV('LANG');

  --Indicates the object name
  G_FND_OBJECT_NAME        VARCHAR2(99) := 'ENG_CHANGE';

  --Indicates the object id (set using g_Fnd_Object_Name)
  G_FND_OBJECT_ID          fnd_objects.object_id%TYPE;

  -- Seeded value for all_users (group available in hz_parties)
  G_ALL_USERS_PARTY_ID     PLS_INTEGER  := -1000;

  -- Batch size that needs to be processed
  G_BATCH_SIZE             PLS_INTEGER;

  -- Message array size
  G_MAX_MESSAGE_SIZE       PLS_INTEGER := 1000;

  G_ERROR_TABLE_NAME      VARCHAR2(99) := 'ENG_CHANGE_PEOPLE_INTF';
  G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'EGO_CHANGE_PEOPLE';
  G_ERROR_FILE_NAME       VARCHAR2(99);
  G_BO_IDENTIFIER         VARCHAR2(99) := 'EGO_CHANGE_PEOPLE';
  --
  -- return status from VALIDATE_UPDATE_GRANT
  -- used for status reference between
  -- validate_no_grant_overlap and validate_update_grant
  --
  G_UPDATE_REC_DONE         NUMBER   :=  1;
  G_UPDATE_OVERLAP_ERROR    NUMBER   := -1;
  G_UPDATE_REC_NOT_FOUND    NUMBER   := -2;
  --
  -- return status from VALIDATE_INSERT_GRANT
  -- used for status reference between
  -- validate_no_grant_overlap and validate_insert_grant
  --
  G_INSERT_REC_DONE         NUMBER   :=  1;
  G_INSERT_OVERLAP_ERROR    NUMBER   := -1;
  --
  -- variables that will be used across programs
  --
  G_DATA_SET_ID           ENG_CHANGE_PEOPLE_INTF.data_set_id%TYPE;
  G_FROM_LINE_NUMBER      NUMBER;
  G_TO_LINE_NUMBER        NUMBER;
  G_TRANSACTION_ID        NUMBER;
  G_DEBUG_MODE            PLS_INTEGER;

  G_TABLE_LOG             BOOLEAN;


  ----------------------------------------------------------------------
  -- Global variables used for Parsing process.
  ----------------------------------------------------------------------


---------------------------------------------
--    PRIVATE  PROCEDURES AND FUNCTIONS    --
---------------------------------------------

  line_no           PLS_INTEGER := 5000;
  debug_line_count  PLS_INTEGER := 0;

  PROCEDURE debug_function (p_message   VARCHAR2) IS
    -- Start OF comments
    -- API name  : debug function
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : log the error as per the debug mode chosen by the user
    --
    -- Parameters:
    --     IN    : message to be logged
  BEGIN
    IF G_DEBUG_MODE = DEBUG_MODE_FATAL THEN
      -- only fatal errors should be logged
      NULL;
    ELSIF G_DEBUG_MODE = DEBUG_MODE_ERROR THEN
      -- only errors needs to be logged
      NULL;
    ELSIF G_DEBUG_MODE = DEBUG_MODE_INFO THEN
      -- all errors and info needs to be logged
      NULL;
    ELSIF G_DEBUG_MODE = DEBUG_MODE_DEBUG THEN
      -- INSERT INTO idc_debug VALUES(line_no, p_message);
      -- COMMIT;
      line_no := line_no + 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END debug_function;


  PROCEDURE error_count_records IS
    -- Start OF comments
    -- API name  : Error Count Records
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : Get the number of errors encountered for each batch
    --
    -- Parameters:
    --     IN    : NONE
    --
    l_error_record_count  PLS_INTEGER;
  BEGIN
    IF G_DEBUG_MODE = DEBUG_MODE_DEBUG THEN
      SELECT COUNT(*)
      INTO   l_error_record_count
      FROM   ENG_CHANGE_PEOPLE_INTF
      WHERE  data_set_id = G_DATA_SET_ID
        AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND   process_status = G_PS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
  END error_count_records;


  PROCEDURE write_log_now  IS
    -- Start OF comments
    -- API name  : write_log_now
    -- TYPE      : PRIVATE
    -- Pre-reqs  : NONE
    --
    -- FUNCTION  : To check the size of error records and
    --             commit them as per the required standards
    --
    -- Parameters:
    --     IN    : NONE
    --
    --    OUT    : x_retcode    NUMBER
    --                return status of the program
    --

  BEGIN
    IF G_TABLE_LOG THEN
         ERROR_HANDLER.Log_Error(p_write_err_to_inttable   => 'Y'
                                ,p_write_err_to_conclog    => 'Y'
                                ,p_write_err_to_debugfile  => ERROR_HANDLER.Get_Debug());
    ELSE
         ERROR_HANDLER.Log_Error(p_write_err_to_inttable   => 'N'
                                ,p_write_err_to_conclog    => 'Y'
                                ,p_write_err_to_debugfile  => ERROR_HANDLER.Get_Debug());
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END write_log_now;


  PROCEDURE check_and_write_log (x_retcode  OUT NOCOPY NUMBER) IS
    -- Start OF comments
    -- API name  : check_and_write_log
    -- TYPE      : PRIVATE
    -- Pre-reqs  : NONE
    --
    -- FUNCTION  : To check the size of error records and
    --             commit them as per the required standards
    --
    -- Parameters:
    --     IN    : NONE
    --
    --    OUT    : x_retcode    NUMBER
    --                return status of the program
    --

  BEGIN
    IF Error_Handler.Get_Message_Count() > G_MAX_MESSAGE_SIZE THEN
      write_log_now();
      error_Handler.Initialize();
    END IF;
    x_retcode := RETCODE_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      ROLLBACK;
  END;


  PROCEDURE initialize_fnd_object_id(p_object_name IN VARCHAR2) IS
    -- Start OF comments
    -- API name  : Initialize_fnd_object_id
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : To obtain the object_id of the object
    --
    -- Parameters:
    --     IN    : object_name
    --
   CURSOR c_fnd_object_id(c_object_name  IN VARCHAR2) IS
     SELECT  object_id
     FROM    fnd_objects
     WHERE   obj_name = c_object_name;

  BEGIN
    OPEN c_fnd_object_id(p_object_name);
    FETCH c_fnd_object_id INTO G_FND_OBJECT_ID;
    IF c_fnd_object_id%NOTFOUND THEN
      G_FND_OBJECT_ID := NULL;
    END IF;
    CLOSE c_fnd_object_id;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF c_fnd_object_id%ISOPEN THEN
        CLOSE c_fnd_object_id;
      END IF;
  END initialize_fnd_object_id;


  PROCEDURE initialize_all_users IS
    -- Start OF comments
    -- API name  : Initialize_all_users
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : To obtain the party_id for all_users
    --
    -- Parameters:
    --     IN    : object_name
    --
   CURSOR c_all_users_party_id IS
     SELECT  party_id
     FROM    hz_parties
     WHERE   party_type = 'GLOBAL'
       AND   party_name = 'All Users';

  BEGIN
    OPEN c_all_users_party_id;
    FETCH c_all_users_party_id INTO G_ALL_USERS_PARTY_ID;
    IF c_all_users_party_id%NOTFOUND THEN
      G_ALL_USERS_PARTY_ID := NULL;
    END IF;
    CLOSE c_all_users_party_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_all_users_party_id%ISOPEN THEN
        CLOSE c_all_users_party_id;
      END IF;
  END initialize_all_users;


  PROCEDURE initialize_roles IS
    -- Start OF comments
    -- API name  : Initialize_roles
    -- TYPE      : PRIVATE
    -- Pre-reqs  : The Object_id is populated into G_FND_OBJECT_ID
    --             initialize_fnd_object_id must be called prior
    --             to call to this routine
    -- FUNCTION  : To populate temporary table ENG_CHANGE_ROLES_TEMP
    --             with the roles available for the specific object
    --
    -- Parameters:
    --     IN    : NONE
    --
  BEGIN
     --Execute Immediate 'TRUNCATE TABLE ENG_CHANGE_ROLES_TEMP';
     DELETE ENG_CHANGE_ROLES_TEMP;
     INSERT into eng_change_roles_temp
            (INTERNAL_ROLE_ID,INTERNAL_ROLE_NAME,DISPLAY_ROLE_NAME)
        SELECT DISTINCT role_tl.menu_id internal_role_id,
               role.menu_name internal_role_name,
               role_tl.user_menu_name display_role_name
	FROM fnd_menus_tl role_tl,
             fnd_menus role,
	     fnd_menu_entries role_privs,
	     fnd_form_functions privs
	WHERE  privs.object_id    = G_FND_OBJECT_ID
	  AND  privs.function_id  = role_privs.function_id
	  AND  role_privs.menu_id = role_tl.menu_id
	  AND  role_tl.menu_id    = role.menu_id
	  AND  role_tl.language   = G_SESSION_LANG;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END initialize_roles;


  PROCEDURE Initialize_Access_Changes
              (p_login_person_id   IN  NUMBER
	      ,x_retcode           OUT  NOCOPY NUMBER) IS
    -- Start OF comments
    -- API name  : Initialize_Access_Changes
    -- TYPE      : PRIVATE
    -- Pre-reqs  : Valid user has logged in
    --
    -- FUNCTION  : To populate temporary table ENG_LOGIN_ACCESS_CHANGES
    --             with the changes onto which the user can give access
    --
    -- Parameters:
    --     IN    : NONE
    --
    l_sec_predicate   VARCHAR2(10000);
    l_return_status   VARCHAR2(10);

    l_count			  NUMBER := 0;
    l_select_sql		  VARCHAR2(32767);
    l_insert_sql		  VARCHAR2(500);
    cursor_select                 INTEGER;
    cursor_insert                 INTEGER;
    cursor_execute                INTEGER;
    l_change_notice_table         DBMS_SQL.VARCHAR2_TABLE;
    l_org_id_table                DBMS_SQL.NUMBER_TABLE;
    l_change_mgmt_type_code_table DBMS_SQL.VARCHAR2_TABLE;
    indx                          NUMBER(10) := 1;

    l_program_name    VARCHAR2(99) := 'INITIALIZE_ACCESS_CHANGES';

  BEGIN

  --EXECUTE IMMEDIATE 'TRUNCATE TABLE ENG_LOGIN_ACCESS_CHANGES';
    DELETE ENG_LOGIN_ACCESS_CHANGES;

    l_select_sql := 'SELECT  OUT_ENG_CHANGES.CHANGE_NOTICE, OUT_ENG_CHANGES.CHANGE_MGMT_TYPE_CODE, OUT_ENG_CHANGES.ORGANIZATION_ID '
                    || 'FROM ENG_ENGINEERING_CHANGES OUT_ENG_CHANGES ';

    EGO_DATA_SECURITY.get_security_predicate(
            p_api_version      => 1.0,
            p_function         => 'ENG_EDIT_CHANGE',    -- fnd_form_function.function_name which specify that user has access
            p_object_name      => 'ENG_CHANGE',
            p_user_name        => 'HZ_PARTY:'||TO_CHAR(p_login_person_id),
            p_statement_type   => 'EXISTS',
            p_pk1_alias        => 'OUT_ENG_CHANGES.CHANGE_ID',
            p_pk2_alias        => NULL,
            p_pk3_alias        => NULL,
            p_pk4_alias        => NULL,
            p_pk5_alias        => NULL,
            x_predicate        => l_sec_predicate,
            x_return_status    => l_return_status );

    if (l_sec_predicate IS NOT NULL) then
      l_select_sql := l_select_sql || ' WHERE ' || l_sec_predicate ;
    end if;
    l_insert_sql := 'INSERT INTO ENG_LOGIN_ACCESS_CHANGES(CHANGE_NOTICE,CHANGE_MGMT_TYPE_CODE,ORGANIZATION_ID) VALUES (:l_change_notice_table, :l_change_mgmt_type_code_table,:l_org_id_table) ';

    cursor_select := DBMS_SQL.OPEN_CURSOR;
    cursor_insert := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(cursor_select,l_select_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.PARSE(cursor_insert,l_insert_sql,DBMS_SQL.NATIVE);

    DBMS_SQL.DEFINE_ARRAY(cursor_select, 1,l_change_notice_table,2500, indx);
    DBMS_SQL.DEFINE_ARRAY(cursor_select, 2,l_change_mgmt_type_code_table,2500, indx);
    DBMS_SQL.DEFINE_ARRAY(cursor_select, 3,l_org_id_table,2500, indx);

    cursor_execute := DBMS_SQL.EXECUTE(cursor_select);

    LOOP
      l_count := DBMS_SQL.FETCH_ROWS(cursor_select);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 1, l_change_notice_table);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 2, l_change_mgmt_type_code_table);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 3, l_org_id_table);


      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_change_notice_table',l_change_notice_table);
      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_change_mgmt_type_code_table',l_change_mgmt_type_code_table);
      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_org_id_table',l_org_id_table);
      cursor_execute := DBMS_SQL.EXECUTE(cursor_insert);
      l_change_notice_table.DELETE;
      l_org_id_table.DELETE;
      l_change_mgmt_type_code_table.DELETE;

      --Can put a parameter based on which we can commit
      --commit;

      --For the final batch of records, either it will be 0 or < 2500
      EXIT WHEN l_count <> 2500;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(cursor_select);
    DBMS_SQL.CLOSE_CURSOR(cursor_insert);

  EXCEPTION
     WHEN OTHERS THEN
        x_retcode := RETCODE_ERROR;
        IF DBMS_SQL.IS_OPEN(cursor_select) THEN
           DBMS_SQL.CLOSE_CURSOR(cursor_select);
        END IF;
        IF DBMS_SQL.IS_OPEN(cursor_insert) THEN
           DBMS_SQL.CLOSE_CURSOR(cursor_insert);
        END IF;
        RAISE;
  END Initialize_Access_Changes;


  PROCEDURE validate_update_grant
           (p_transaction_type      IN  VARCHAR2
           ,p_transaction_id        IN  NUMBER
           ,p_change_id             IN  NUMBER
           ,p_organization_id       IN  NUMBER
	   ,p_internal_role_id      IN  NUMBER
	   ,p_user_party_id_char    IN  VARCHAR2
 	   ,p_group_party_id_char   IN  VARCHAR2
	   ,p_global_party_id_char  IN  VARCHAR2
	   ,p_company_party_id_char IN  VARCHAR2
	   ,p_start_date            IN  DATE
	   ,p_end_date              IN  DATE
	   ,x_return_status         OUT NOCOPY NUMBER) IS
    -- Start OF comments
    -- API name  : validate_update_grant
    -- TYPE      : PRIVATE
    -- Pre-reqs  : NONE
    --
    -- FUNCTION  : To check if the required grant can be updated
    --             and updates fnd_grants if required
    --             NO ACTION IS PERFORMED ON eng_change_people_intf
    --
    -- Parameters:
    --     IN    : NONE
    --
    --    OUT    : x_return_status    NUMBER
    --                  Indicates the status of the record
    --               -1    Record not found for update
    --               -2    Record found for update but will cause overlap
    --                1    Record found and updated
    --

  CURSOR c_get_update_grantid
               (cp_change_id              IN  NUMBER
               ,cp_organization_id        IN  NUMBER
               ,cp_menu_id                IN  NUMBER
	       ,cp_object_id              IN  NUMBER
	       ,cp_user_party_id_char     IN  VARCHAR2
	       ,cp_group_party_id_char    IN  VARCHAR2
	       ,cp_global_party_id_char   IN  VARCHAR2
	       ,cp_company_party_id_char  IN  VARCHAR2
	       ,cp_start_date             IN  DATE
	       ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = G_FND_OBJECT_ID
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_change_id)
--   Commented as PK2_Value for ENG_CHANGE in fnd_objects is NULL
--    AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'   AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'  AND grants.grantee_key =  cp_group_party_id_char) OR
	     (grants.grantee_type =  'GLOBAL' AND grants.grantee_key =  cp_global_party_id_char) OR
	     (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char)
	    )
      AND   start_date = cp_start_date;

  CURSOR c_get_valid_update
            (cp_grant_guid             IN  RAW
            ,cp_change_id              IN  NUMBER
            ,cp_organization_id        IN  NUMBER
            ,cp_menu_id                IN  NUMBER
	    ,cp_object_id              IN  NUMBER
	    ,cp_user_party_id_char     IN  VARCHAR2
	    ,cp_group_party_id_char    IN  VARCHAR2
	    ,cp_global_party_id_char   IN  VARCHAR2
	    ,cp_company_party_id_char  IN  VARCHAR2
	    ,cp_start_date             IN  DATE
	    ,cp_end_date               IN  DATE
		       ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.grant_guid        <> cp_grant_guid
      AND   grants.object_id          = cp_object_id
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_change_id)
--   Commented as PK2_Value for ENG_CHANGE in fnd_objects is NULL
--    AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'   AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'  AND grants.grantee_key =  cp_group_party_id_char) OR
	     (grants.grantee_type =  'GLOBAL' AND grants.grantee_key =  cp_global_party_id_char) OR
	     (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char)
	    )
      AND   start_date <= NVL(cp_end_date, start_date)
      AND   NVL(end_date,cp_start_date) >= cp_start_date;

  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;
  l_grant_guid            fnd_grants.grant_guid%TYPE;
  l_temp_grant_guid       fnd_grants.grant_guid%TYPE;

  l_success               VARCHAR2(999);

  BEGIN
    OPEN c_get_update_grantid
                (cp_change_id              => p_change_id
                ,cp_organization_id        => p_organization_id
                ,cp_menu_id                => p_internal_role_id
		,cp_object_id              => G_FND_OBJECT_ID
		,cp_user_party_id_char     => p_user_party_id_char
		,cp_group_party_id_char    => p_group_party_id_char
		,cp_global_party_id_char   => p_global_party_id_char
		,cp_company_party_id_char  => p_company_party_id_char
		,cp_start_date             => p_start_date
		);
    FETCH c_get_update_grantid INTO l_grant_guid;
    IF c_get_update_grantid%FOUND THEN
      --
      -- there will be only one record with a given start date
      -- check if the update will cause any overlaps
      --
      OPEN c_get_valid_update
                  (cp_grant_guid             => l_grant_guid
                  ,cp_change_id              => p_change_id
                  ,cp_organization_id        => p_organization_id
                  ,cp_menu_id                => p_internal_role_id
		  ,cp_object_id              => G_FND_OBJECT_ID
		  ,cp_user_party_id_char     => p_user_party_id_char
		  ,cp_group_party_id_char    => p_group_party_id_char
		  ,cp_global_party_id_char   => p_global_party_id_char
		  ,cp_company_party_id_char  => p_company_party_id_char
		  ,cp_start_date             => p_start_date
		  ,cp_end_date               => p_end_date
		  );
      FETCH c_get_valid_update INTO l_temp_grant_guid;
      IF c_get_valid_update%FOUND THEN
        --
	-- overlap will occur after update
	--
	x_return_status := G_UPDATE_OVERLAP_ERROR;

	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  l_token_tbl_two(1).token_name  := 'START_DATE';
	  l_token_tbl_two(1).token_value := p_start_date;
	  l_token_tbl_two(2).token_name  := 'END_DATE';
	  l_token_tbl_two(2).token_value := p_end_date;
	  error_handler.Add_Error_Message
                ( p_message_name   => 'ENG_CPI_OVERLAP_GRANT'
	        , p_application_id => 'ENG'
	        , p_message_text   => NULL
	        , p_token_tbl      => l_token_tbl_two
	        , p_message_type   => 'E'
	        , p_row_identifier => p_transaction_id
	        , p_table_name     => G_ERROR_TABLE_NAME
	        , p_entity_id      => NULL
	        , p_entity_index   => NULL
	        , p_entity_code    => G_ERROR_ENTITY_CODE
	        );
	END IF;
      ELSE
        -- update the grants
        FND_GRANTS_PKG.Update_Grant
	              (p_api_version   => 1.0
		      ,p_grant_guid    => l_grant_guid
		      ,p_start_date    => p_start_date
		      ,p_end_date      => p_end_date
		      ,x_success       => l_success
		      );
	x_return_status := G_UPDATE_REC_DONE;
      END IF;  -- c_get_valid_update
      CLOSE c_get_valid_update;
    ELSE
      -- no records found for validation
      x_return_status := G_UPDATE_REC_NOT_FOUND;
      IF p_transaction_type = 'UPDATE' THEN
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  l_token_tbl_one(1).token_name  := 'TYPE';
	  l_token_tbl_one(1).token_value := p_transaction_type;
	  error_handler.Add_Error_Message
                ( p_message_name   => 'ENG_CPI_GRANT_NOT_FOUND'
	        , p_application_id => 'ENG'
	        , p_message_text   => NULL
	        , p_token_tbl      => l_token_tbl_one
	        , p_message_type   => 'E'
	        , p_row_identifier => p_transaction_id
	        , p_table_name     => G_ERROR_TABLE_NAME
	        , p_entity_id      => NULL
	        , p_entity_index   => NULL
	        , p_entity_code    => G_ERROR_ENTITY_CODE
	        );
        END IF;
      END IF; -- p_transaction_type  UPDATE
    END IF; -- c_get_update_grantid
    CLOSE c_get_update_grantid;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_update_grantid%ISOPEN THEN
        CLOSE c_get_update_grantid;
      END IF;
      IF c_get_valid_update%ISOPEN THEN
        CLOSE c_get_valid_update;
      END IF;
  END validate_update_grant;


  PROCEDURE validate_insert_grant
           (p_transaction_type      IN  VARCHAR2
           ,p_transaction_id        IN  NUMBER
           ,p_change_id             IN  NUMBER
           ,p_organization_id       IN  NUMBER
	   ,p_internal_role_id      IN  NUMBER
           ,p_internal_role_name    IN  VARCHAR2
           ,p_grantee_type          IN  VARCHAR2
           ,p_grantee_key           IN  VARCHAR2
           ,p_user_party_id_char    IN  VARCHAR2
 	   ,p_group_party_id_char   IN  VARCHAR2
	   ,p_global_party_id_char  IN  VARCHAR2
	   ,p_company_party_id_char IN  VARCHAR2
	   ,p_start_date            IN  DATE
	   ,p_end_date              IN  DATE
	   ,x_return_status         OUT NOCOPY NUMBER) IS
    -- Start OF comments
    -- API name  : validate_insert_grant
    -- TYPE      : PRIVATE
    -- Pre-reqs  : NONE
    --
    -- FUNCTION  : To check if the required grant is valid for insert
    --             and inserts the record into fnd_grants if valid
    --             NO ACTION IS PERFORMED ON eng_change_people_intf
    --
    -- Parameters:
    --     IN    : NONE
    --
    --    OUT    : x_return_status    NUMBER
    --                  Indicates the status of the record
    --               -1    Record not found for update
    --               -2    Record found for update but will cause overlap
    --                1    Record found and updated
    --

  CURSOR c_get_overlap_grantid
            (cp_change_id              IN  NUMBER
            ,cp_organization_id        IN  NUMBER
            ,cp_menu_id                IN  NUMBER
	    ,cp_object_id              IN  NUMBER
	    ,cp_user_party_id_char     IN  VARCHAR2
	    ,cp_group_party_id_char    IN  VARCHAR2
	    ,cp_global_party_id_char   IN  VARCHAR2
	    ,cp_company_party_id_char  IN  VARCHAR2
	    ,cp_start_date             IN  DATE
	    ,cp_end_date               IN  DATE
	    ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = cp_object_id
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_change_id)
--   Commented as PK2_Value for ENG_CHANGE in fnd_objects is NULL
--    AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'   AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'  AND grants.grantee_key =  cp_group_party_id_char) OR
	     (grants.grantee_type =  'GLOBAL' AND grants.grantee_key =  cp_global_party_id_char) OR
	     (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char)
	    )
      AND   start_date <= NVL(cp_end_date, start_date)
      AND   NVL(end_date,cp_start_date) >= cp_start_date;


  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_grant_guid            fnd_grants.grant_guid%TYPE;
  l_temp_grant_guid       fnd_grants.grant_guid%TYPE;

  l_success     VARCHAR2(999);
  l_errorcode   NUMBER;

  BEGIN
    OPEN c_get_overlap_grantid
               (cp_change_id              => p_change_id
               ,cp_organization_id        => p_organization_id
               ,cp_menu_id                => p_internal_role_id
	       ,cp_object_id              => G_FND_OBJECT_ID
	       ,cp_user_party_id_char     => p_user_party_id_char
	       ,cp_group_party_id_char    => p_group_party_id_char
	       ,cp_global_party_id_char   => p_global_party_id_char
	       ,cp_company_party_id_char  => p_company_party_id_char
	       ,cp_start_date             => p_start_date
	       ,cp_end_date               => p_end_date);

    FETCH c_get_overlap_grantid INTO l_grant_guid;
    IF c_get_overlap_grantid%FOUND THEN
      -- overlap will occur with the current data
      x_return_status := G_INSERT_OVERLAP_ERROR;
      IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	l_token_tbl_two(1).token_name  := 'START_DATE';
	l_token_tbl_two(1).token_value := p_start_date;
	l_token_tbl_two(2).token_name  := 'END_DATE';
	l_token_tbl_two(2).token_value := p_end_date;
	error_handler.Add_Error_Message
              ( p_message_name   => 'ENG_CPI_OVERLAP_GRANT'
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => p_transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
      END IF;
    ELSE
      --
      -- insert record into fnd_grants
      --
      FND_GRANTS_PKG.Grant_Function
	            (p_api_version         =>  1.0
                    ,p_menu_name           =>  p_internal_role_name
                    ,p_object_name         =>  G_FND_OBJECT_NAME
                    ,p_instance_type       =>  'INSTANCE'
                    ,p_instance_set_id     =>  NULL
                    ,p_instance_pk1_value  =>  TO_CHAR(p_change_id)
--   Passing NULL to as PK2_Value for ENG_CHANGE in fnd_objects is NULL
                    ,p_instance_pk2_value  =>  NULL
                    ,p_instance_pk3_value  =>  NULL
                    ,p_instance_pk4_value  =>  NULL
                    ,p_instance_pk5_value  =>  NULL
                    ,p_grantee_type        =>  p_grantee_type
                    ,p_grantee_key         =>  p_grantee_key
                    ,p_start_date          =>  p_start_date
                    ,p_end_date            =>  p_end_date
                    ,p_program_name        =>  G_PACKAGE_NAME
                    ,p_program_tag         =>  NULL
                    ,p_parameter1          =>  NULL
                    ,p_parameter2          =>  NULL
                    ,p_parameter3          =>  NULL
                    ,p_parameter4          =>  NULL
                    ,p_parameter5          =>  NULL
                    ,p_parameter6          =>  NULL
                    ,p_parameter7          =>  NULL
                    ,p_parameter8          =>  NULL
                    ,p_parameter9          =>  NULL
                    ,p_parameter10         =>  NULL
                    ,p_ctx_secgrp_id       => -1
                    ,p_ctx_resp_id         => -1
                    ,p_ctx_resp_appl_id    => -1
                    ,p_ctx_org_id          => -1
                    ,x_grant_guid          =>  l_temp_grant_guid
                    ,x_success             =>  l_success
                    ,x_errorcode           =>  l_errorcode
                    );
      x_return_status := G_INSERT_REC_DONE;
    END IF;  -- c_get_overlap_grantid
    CLOSE c_get_overlap_grantid;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_overlap_grantid%ISOPEN THEN
        CLOSE c_get_overlap_grantid;
      END IF;
  END validate_insert_grant;


  PROCEDURE Validate_No_Grant_Overlap ( x_retcode  OUT NOCOPY NUMBER) IS
    -- Start OF comments
    -- API name  : Validate No Grant Overlap
    -- TYPE      : Private (called by load_interface_lines)
    -- Pre-reqs  : Data validated for all possible scenarios (but for grants)
    -- FUNCTION  : Validate grant overlap.
    --             Take all records to be deleted and process them
    --             Take all the records to be updated and update grants
    --             Finally insert new grants
    --
  CURSOR c_get_cpi_records IS
    SELECT change_id, organization_id, grantee_party_id, grantee_type,
           start_date, end_date, transaction_id, internal_role_id, transaction_type,
	   internal_role_name,
    	   DECODE(grantee_type, 'USER', 'HZ_PARTY:'||TO_CHAR(grantee_party_id),
	                        'GROUP','HZ_GROUP:'||TO_CHAR(grantee_party_id),
-- bug: 3460466
-- All Users is now represented by grantee_key = 'GLOBAL' in fnd_grants
--				'GLOBAL','HZ_GLOBAL:'||TO_CHAR(grantee_party_id),
				'GLOBAL',grantee_type,
				'HZ_COMPANY:'||TO_CHAR(grantee_party_id)) grantee_key,
    	   DECODE(transaction_type, 'CREATE', ORDER_BY_CREATE,
	                            'UPDATE', ORDER_BY_UPDATE,
				    'SYNC',   ORDER_BY_SYNC,
	                            'DELETE', ORDER_BY_DELETE,
				    ORDER_BY_OTHERS)  trans_type
    FROM   eng_change_people_intf
    WHERE  data_set_id      = G_DATA_SET_ID
      AND  process_status   = G_PS_IN_PROCESS
      ORDER BY trans_type, transaction_id;

  CURSOR c_get_delete_grantid
               (cp_change_id              IN  NUMBER
               ,cp_organization_id        IN  NUMBER
               ,cp_menu_id                IN  NUMBER
	       ,cp_object_id              IN  NUMBER
	       ,cp_user_party_id_char     IN  VARCHAR2
	       ,cp_group_party_id_char    IN  VARCHAR2
	       ,cp_global_party_id_char   IN  VARCHAR2
	       ,cp_company_party_id_char  IN  VARCHAR2
	       ,cp_start_date             IN  DATE
	       ,cp_end_date               IN  DATE
		       ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = G_FND_OBJECT_ID
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_change_id)
--   Commented as PK2_Value for ENG_CHANGE in fnd_objects is NULL
--      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'   AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'  AND grants.grantee_key =  cp_group_party_id_char) OR
	     (grants.grantee_type =  'GLOBAL' AND grants.grantee_key =  cp_global_party_id_char) OR
	     (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char)
	    )
      AND   start_date = cp_start_date
      AND   ((end_date IS NULL AND cp_end_date is NULL)  OR (end_date = cp_end_date));

  l_token_tbl_none        Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;

  l_user_party_id_char     VARCHAR2(100);
  l_group_party_id_char    VARCHAR2(100);
  l_global_party_id_char   VARCHAR2(100);
  l_company_party_id_char  VARCHAR2(100);


  l_grant_guid             fnd_grants.grant_guid%TYPE;
  l_temp_grant_guid        fnd_grants.grant_guid%TYPE;
  l_grant_guid_count       NUMBER := 0;

  l_record_count           NUMBER := 0;
  l_return_status          NUMBER;
  l_success                VARCHAR2(999);

  l_program_name           VARCHAR2(99) := 'VALIDATE_NO_GRANT_OVERLAP';
  l_boolean_delete  boolean := TRUE;
  l_boolean_create  boolean := TRUE;
  l_boolean_update  boolean := TRUE;
  l_boolean_sync    boolean := TRUE;

  BEGIN

    FOR cr in c_get_cpi_records LOOP
      IF cr.grantee_type = 'USER' THEN
        l_user_party_id_char    := 'HZ_PARTY:'||TO_CHAR(cr.grantee_party_id);
	l_group_party_id_char   := NULL;
	l_global_party_id_char  := NULL;
	l_company_party_id_char := NULL;
      ELSIF cr.grantee_type = 'GROUP' THEN
        l_user_party_id_char   := NULL;
	l_group_party_id_char  := 'HZ_GROUP:'||TO_CHAR(cr.grantee_party_id);
	l_global_party_id_char := NULL;
	l_company_party_id_char := NULL;
      ELSIF cr.grantee_type = 'GLOBAL' THEN
        l_user_party_id_char   := NULL;
	l_group_party_id_char  := NULL;
-- bug: 3460466
-- All Users is now represented by grantee_key = 'GLOBAL' in fnd_grants
--	l_global_party_id_char := 'HZ_GLOBAL:'||TO_CHAR(cr.grantee_party_id);
	l_global_party_id_char := cr.grantee_type;
	l_company_party_id_char := NULL;
      ELSIF cr.grantee_type = 'COMPANY' THEN
        l_user_party_id_char   := NULL;
	l_group_party_id_char  := NULL;
	l_global_party_id_char := NULL;
	l_company_party_id_char := 'HZ_COMPANY:'||TO_CHAR(cr.grantee_party_id);
      ELSE
        l_user_party_id_char   := NULL;
	l_group_party_id_char  := NULL;
	l_global_party_id_char := NULL;
	l_company_party_id_char := NULL;
      END IF;
      IF cr.transaction_type = 'DELETE'  THEN
        ----------------------------
        --  delete records first  --
        ----------------------------
        OPEN c_get_delete_grantid
                (cp_change_id              => cr.change_id
                ,cp_organization_id        => cr.organization_id
                ,cp_menu_id                => cr.internal_role_id
		,cp_object_id              => G_FND_OBJECT_ID
		,cp_user_party_id_char     => l_user_party_id_char
		,cp_group_party_id_char    => l_group_party_id_char
		,cp_global_party_id_char   => l_global_party_id_char
		,cp_company_party_id_char   => l_company_party_id_char
		,cp_start_date             => cr.start_date
		,cp_end_date               => cr.end_date);
        FETCH c_get_delete_grantid INTO l_grant_guid;

        IF c_get_delete_grantid%FOUND THEN
          FND_GRANTS_PKG.Revoke_Grant
	            (p_api_version   =>  1.0
                    ,p_grant_guid    =>  l_grant_guid
                    ,x_success       =>  l_success
                    ,x_errorcode     =>  l_return_status
		     );
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_SUCCESS
	  WHERE transaction_id = cr.transaction_id;
        ELSE
	  IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	    l_token_tbl_one(1).token_name  := 'TYPE';
	    l_token_tbl_one(1).token_value := cr.transaction_type;
	    error_handler.Add_Error_Message
              ( p_message_name   => 'ENG_CPI_GRANT_NOT_FOUND'
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
          END IF;
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
        END IF;  -- c_get_delete_grantid
	CLOSE c_get_delete_grantid;

      ELSIF cr.transaction_type = 'UPDATE'  THEN
        ----------------------------
        --  check for update now  --
        ----------------------------
        validate_update_grant
           (p_transaction_type      => cr.transaction_type
           ,p_transaction_id        => cr.transaction_id
           ,p_change_id             => cr.change_id
	   ,p_organization_id       => cr.organization_id
	   ,p_internal_role_id      => cr.internal_role_id
	   ,p_user_party_id_char    => l_user_party_id_char
 	   ,p_group_party_id_char   => l_group_party_id_char
	   ,p_global_party_id_char  => l_global_party_id_char
	   ,p_company_party_id_char => l_company_party_id_char
	   ,p_start_date            => cr.start_date
	   ,p_end_date              => cr.end_date
	   ,x_return_status         => l_return_status
	   );
        IF l_return_status = G_UPDATE_REC_DONE THEN
	  -- record successfully updated
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_SUCCESS
	  WHERE transaction_id = cr.transaction_id;
	ELSIF l_return_status = G_UPDATE_REC_NOT_FOUND THEN
	  -- no record found for overlap
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	ELSIF l_return_status = G_UPDATE_OVERLAP_ERROR THEN
	  -- overlap will occur if update is done
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	END IF;

      ELSIF cr.transaction_type = 'SYNC'  THEN
        ------------------------------------
        --  check for SYNC opetaion       --
        --  (first UPDATE and then INSERT --
        ------------------------------------
        validate_update_grant
           (p_transaction_type      => cr.transaction_type
           ,p_transaction_id        => cr.transaction_id
           ,p_change_id             => cr.change_id
           ,p_organization_id       => cr.organization_id
	   ,p_internal_role_id      => cr.internal_role_id
	   ,p_user_party_id_char    => l_user_party_id_char
 	   ,p_group_party_id_char   => l_group_party_id_char
	   ,p_global_party_id_char  => l_global_party_id_char
           ,p_company_party_id_char => l_company_party_id_char
	   ,p_start_date            => cr.start_date
	   ,p_end_date              => cr.end_date
	   ,x_return_status         => l_return_status
	   );
        IF l_return_status = G_UPDATE_REC_DONE THEN
	  -- record successfully updated
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_SUCCESS
	  WHERE transaction_id = cr.transaction_id;
	ELSIF l_return_status = G_UPDATE_OVERLAP_ERROR THEN
	  -- overlap will occur if update is done
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	ELSIF l_return_status = G_UPDATE_REC_NOT_FOUND THEN
	  -- no record found for overlap
	  -- now insert the record.
          validate_insert_grant
             (p_transaction_type      => cr.transaction_type
             ,p_transaction_id        => cr.transaction_id
             ,p_change_id             => cr.change_id
             ,p_organization_id       => cr.organization_id
  	     ,p_internal_role_id      => cr.internal_role_id
             ,p_internal_role_name    => cr.internal_role_name
             ,p_grantee_type          => cr.grantee_type
             ,p_grantee_key           => cr.grantee_key
	     ,p_user_party_id_char    => l_user_party_id_char
 	     ,p_group_party_id_char   => l_group_party_id_char
	     ,p_global_party_id_char  => l_global_party_id_char
	     ,p_company_party_id_char => l_company_party_id_char
	     ,p_start_date            => cr.start_date
	     ,p_end_date              => cr.end_date
	     ,x_return_status         => l_return_status
	      );
	  IF l_return_status = G_INSERT_REC_DONE THEN
	    -- record successfully inserted
            UPDATE eng_change_people_intf
	    SET    process_status = G_PS_SUCCESS
	  WHERE transaction_id = cr.transaction_id;
	  ELSIF l_return_status = G_INSERT_OVERLAP_ERROR THEN
	    -- insert overlap error
            UPDATE eng_change_people_intf
	    SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	  END IF;
	END IF;

      ELSIF cr.transaction_type = 'CREATE'  THEN
        ----------------------------
        --  check for create now  --
        ----------------------------
        validate_insert_grant
             (p_transaction_type      => cr.transaction_type
             ,p_transaction_id        => cr.transaction_id
             ,p_change_id             => cr.change_id
             ,p_organization_id       => cr.organization_id
  	     ,p_internal_role_id      => cr.internal_role_id
             ,p_internal_role_name    => cr.internal_role_name
             ,p_grantee_type          => cr.grantee_type
             ,p_grantee_key           => cr.grantee_key
	     ,p_user_party_id_char    => l_user_party_id_char
 	     ,p_group_party_id_char   => l_group_party_id_char
	     ,p_global_party_id_char  => l_global_party_id_char
	     ,p_company_party_id_char => l_company_party_id_char
	     ,p_start_date            => cr.start_date
	     ,p_end_date              => cr.end_date
	     ,x_return_status         => l_return_status
	      );
	IF l_return_status = G_INSERT_REC_DONE THEN
	  -- record successfully inserted
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_SUCCESS
	  WHERE transaction_id = cr.transaction_id;
	ELSIF l_return_status = G_INSERT_OVERLAP_ERROR THEN
	  -- insert overlap error
          UPDATE eng_change_people_intf
	  SET    process_status = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	END IF;

      END IF;  -- cr.transaction_type
      l_record_count := l_record_count + 1;
      IF l_record_count > G_BATCH_SIZE THEN
        l_record_count := 1;
	COMMIT;
      END IF;
      check_and_write_log (x_retcode  => x_retcode);
      IF (x_retcode = RETCODE_ERROR) THEN
        RETURN;
      END IF;
    END LOOP; -- c_get_cpi_records
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_cpi_records%ISOPEN THEN
        CLOSE c_get_cpi_records;
      END IF;
      IF c_get_delete_grantid%ISOPEN THEN
        CLOSE c_get_delete_grantid;
      END IF;

  END Validate_No_Grant_Overlap;

---------------------------------------------
--        PROCEDURES AND FUNCTIONS         --
---------------------------------------------

  FUNCTION get_curr_dataset_id RETURN NUMBER IS
    -- Start OF comments
    -- API name  : Load Interfance Lines
    -- TYPE      : Public (called by SQL Loader)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load interfance lines into FND_GRANTS.
    --             Errors are populated in MTL_INTERFACE_ERRORS
  BEGIN
    IF G_CURR_DATASET_ID = -1 THEN
      SELECT ENG_CPI_DATASET_ID_S.NEXTVAL
      INTO   G_CURR_DATASET_ID
      FROM   DUAL;
    END IF;
    RETURN G_CURR_DATASET_ID;
  EXCEPTION
    WHEN OTHERS THEN
      G_CURR_DATASET_ID := -2;
  END get_curr_dataset_id;


  PROCEDURE load_interface_lines
                 (
                   x_retcode            IN OUT NOCOPY   VARCHAR2,
                   x_errbuff            IN OUT NOCOPY   VARCHAR2,
                   p_data_set_id        IN     	NUMBER,
                   p_bulk_batch_size    IN     	NUMBER   ,
                   p_delete_lines       IN     	NUMBER   ,
                   p_debug_mode         IN     	NUMBER   ,
                   p_log_mode           IN     	NUMBER
		  ) IS

    -- Start OF comments
    -- API name  : Load Interfance Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load interfance lines into FND_GRANTS.
    --             Errors are populated in MTL_INTERFACE_ERRORS


  --Currently, assume that the user who submits the 'Change People Import'
  --is always Internal user. So, can join with PER_ALL_PEOPLE_F to figure
  --out the party id.
  CURSOR c_user_party_id (cp_user_id IN NUMBER) IS
     SELECT employee.party_id, first_name ||' '|| last_name name
     FROM   per_all_people_f employee, fnd_user users
     WHERE  users.user_id      = cp_user_id
       AND  employee.person_id = users.employee_id;

  CURSOR c_count_cpi_lines (cp_data_set_id  IN  NUMBER) IS
     SELECT COUNT(*)
     FROM   eng_change_people_intf
     WHERE  data_set_id    = cp_data_set_id
       AND  process_status = G_PS_TO_BE_PROCESSED;

  CURSOR c_get_trans_id_limits (cp_data_set_id  IN  NUMBER) IS
     SELECT MIN(transaction_id), MAX(transaction_id)
     FROM   eng_change_people_intf
     WHERE  data_set_id    = cp_data_set_id
       AND  process_status = G_PS_TO_BE_PROCESSED;

  CURSOR c_err_dates IS
     SELECT transaction_id,start_date,end_date
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  start_date > NVL(end_date,(start_date + 1));

  --
  -- Select records to flag missing or invalid Transaction_Types
  --
  CURSOR c_err_transaction_type  IS
     SELECT transaction_id, transaction_type
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  transaction_type NOT IN ('CREATE', 'UPDATE', 'DELETE', 'SYNC');


  --
  -- Select records with missing/invalid grantee type
  --
  CURSOR c_err_grantee_type  IS
     SELECT transaction_id, grantee_type
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  (grantee_type IS NULL OR grantee_type NOT IN ('USER', 'GROUP', 'COMPANY', 'GLOBAL'));

  --
  -- Select records to flag missing or invalid grantee_party_id
  --
  CURSOR c_err_grantee_id  IS
     SELECT transaction_id, grantee_party_id, grantee_name, grantee_type
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  grantee_party_id IS NULL;

  --
  -- Select records to flag missing or invalid role_id
  --
  CURSOR c_err_role_id IS
     SELECT transaction_id, internal_role_id, display_role_name, internal_role_name
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status = G_PS_IN_PROCESS
       AND  internal_role_id IS NULL;

  --
  -- Select records to flag missing or invalid organization_id
  --
  CURSOR c_err_org_id  IS
     SELECT transaction_id, organization_id, organization_code
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status = G_PS_IN_PROCESS
       AND  organization_id  IS NULL;


  --
  -- Select records to flag missing or invalid Change_Mgmt_Types
  --
  -- Updated the cursor to get the valid change_mgmt_type_codes from
  -- the ENG_CHANGE_ORDER_TYPES_VL
  CURSOR c_err_chg_mgmt_type_code  IS
     SELECT transaction_id, change_mgmt_type_code
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  (change_mgmt_type_code IS NULL OR
                --commenting out the following lines as ENG_CHANGE_MGMT_TYPES is obsoleted
		--change_mgmt_type_code NOT IN (SELECT CHANGE_MGMT_TYPE_CODE FROM ENG_CHANGE_MGMT_TYPES));
                change_mgmt_type_code NOT IN (SELECT CHANGE_MGMT_TYPE_CODE FROM ENG_CHANGE_ORDER_TYPES_VL
                WHERE TYPE_CLASSIFICATION = 'CATEGORY'));

  --
  -- Select records for valid change numbers
  --
  CURSOR c_err_change_id IS
     SELECT transaction_id,organization_code,change_mgmt_type_code,change_notice
     FROM   eng_change_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status = G_PS_IN_PROCESS
       AND  change_id IS NULL;

  --
  -- Check whether the user can revoke/give grants
  --
  CURSOR c_get_grant_privileges (cp_change_notice      IN  NUMBER
                                ,cp_organization_id    IN  NUMBER) IS
     SELECT change_notice
     FROM   ENG_LOGIN_ACCESS_CHANGES
     WHERE  change_notice = cp_change_notice
       AND  organization_id   = cp_organization_id;

  --
  -- Check whether the user can revoke/give grants
  --
  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  l_token_tbl_none       Error_Handler.Token_Tbl_Type;
  l_token_tbl_one        Error_Handler.Token_Tbl_Type;
  l_token_tbl_two        Error_Handler.Token_Tbl_Type;
  l_token_tbl_three      Error_Handler.Token_Tbl_Type;

  l_login_party_id       hz_parties.party_id%TYPE;
  l_login_party_name     VARCHAR2(240);
  l_cpi_lines_count      PLS_INTEGER;
  l_loop_count           PLS_INTEGER;
  l_transaction_id_min   PLS_INTEGER;
  l_transaction_id_max   PLS_INTEGER;

  l_column_name          VARCHAR2(99);
  l_transaction_id       eng_change_people_intf.transaction_id%TYPE;
  l_msg_name             VARCHAR2(99);
  l_msg_text             VARCHAR2(999) := NULL;
  l_msg_type             VARCHAR2(10)  := 'E';
  l_sysdate              DATE;

  l_change_id            NUMBER;
  l_change_notice        VARCHAR2(10);
  l_retcode              VARCHAR2(10);
  l_errbuff              VARCHAR2(999);

  l_log_output_dir       VARCHAR2(200);
  l_log_return_status    VARCHAR2(99);
  l_log_mesg_token_tbl   ERROR_HANDLER.Mesg_Token_Tbl_Type;

  l_program_name         VARCHAR2(30)  := 'LOAD_INTERFACE_LINES';

  BEGIN
    IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
      g_concReq_valid_flag  := TRUE;
    END IF;

    IF (g_concReq_valid_flag ) THEN
      FND_FILE.put_line(FND_FILE.LOG, ' ******** New Log ******** ');
    END IF;
    ERROR_HANDLER.initialize();
    ERROR_HANDLER.set_bo_identifier(G_BO_IDENTIFIER);

    IF p_log_mode = LOG_INTO_FILE_ONLY THEN
      ERROR_HANDLER.Set_Debug('Y');
      G_TABLE_LOG := FALSE;
    ELSIF p_log_mode = LOG_INTO_FILE_AND_TABLE THEN
      ERROR_HANDLER.Set_Debug('Y');
      G_TABLE_LOG := TRUE;
    ELSIF p_log_mode = LOG_INTO_TABLE_ONLY THEN
      ERROR_HANDLER.Set_Debug('N');
      G_TABLE_LOG := TRUE;
    ELSE
      ERROR_HANDLER.Set_Debug('N');
      G_TABLE_LOG := FALSE;
    END IF;
-- Bug: 3324531
-- removed references to bom_globals
    IF p_debug_mode = DEBUG_MODE_DEBUG THEN
      G_DEBUG_MODE := DEBUG_MODE_DEBUG;
    ELSE
      -- default debug mode is set to log errors only in Phase I
      G_DEBUG_MODE := DEBUG_MODE_ERROR;
    END IF; -- p_debug_mode

    IF ERROR_HANDLER.Get_Debug = 'Y' THEN
      -- intialise the file names, etc
      OPEN c_get_utl_file_dir;
      FETCH c_get_utl_file_dir INTO l_log_output_dir;
      IF c_get_utl_file_dir%FOUND THEN
        ------------------------------------------------------
        -- Trim to get only the first directory in the list --
        ------------------------------------------------------
	IF INSTR(l_log_output_dir,',') <> 0 THEN
          l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
	END IF;
	G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'.'||fnd_profile.value('CONC_REQUEST_ID')||'.err';
        error_handler.Open_Debug_Session(
	  p_debug_filename   => G_ERROR_FILE_NAME
         ,p_output_dir       => l_log_output_dir
         ,x_return_status    => l_log_return_status
	 ,x_error_mesg       => l_errbuff
         );


        IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          -- unable to open error log file
	  ERROR_HANDLER.Add_Error_Message
	      (p_message_text   => l_errbuff
	      ,p_message_type   => 'E'
	      ,p_entity_code    => G_ERROR_ENTITY_CODE
              );

          x_retcode := RETCODE_ERROR;
	  x_errbuff := 'ENG_CPI_INVALID_LOG_FILE';
	  RETURN;
        END IF;
      ELSE
        x_retcode := RETCODE_ERROR;
	x_errbuff := 'ENG_CPI_INVALID_LOG_DIR';
	RETURN;
      END IF;
      CLOSE c_get_utl_file_dir;
    END IF; -- error_handler.get_debug.

    -- the values are chosen from the FND_GLOBALS
    G_USER_ID    := FND_GLOBAL.user_id         ;
    G_LOGIN_ID   := FND_GLOBAL.login_id        ;
    G_PROG_APPID := FND_GLOBAL.prog_appl_id    ;
    G_PROG_ID    := FND_GLOBAL.conc_program_id ;
    G_REQUEST_ID := FND_GLOBAL.conc_request_id ;

    -- check whether the logged in user is a valid user
    OPEN c_user_party_id(cp_user_id => G_USER_ID);
    FETCH c_user_party_id INTO l_login_party_id, l_login_party_name;
    IF c_user_party_id%NOTFOUND THEN
      error_handler.Add_Error_Message
        ( p_message_name   => 'ENG_CPI_INVALID_LOGIN'
	, p_application_id => 'ENG'
	, p_message_text   => NULL
	, p_token_tbl      => l_token_tbl_none
	, p_message_type   => 'E'
	, p_row_identifier => NULL
	, p_table_name     => G_ERROR_TABLE_NAME
	, p_entity_id      => NULL
	, p_entity_index   => NULL
	, p_entity_code    => G_ERROR_ENTITY_CODE
	);
      x_retcode := RETCODE_ERROR;
      x_errbuff := 'ENG_CPI_INVALID_LOGIN';

      RETURN;
     ELSE
       initialize_access_changes (p_login_person_id  => l_login_party_id
                                 ,x_retcode          => x_retcode);
       IF x_retcode = RETCODE_ERROR THEN
         x_errbuff := 'ENG_CPI_ERR_INIT_CHANGES';
         RETURN;
       END IF;

     END IF;
     CLOSE c_user_party_id;
-- END here

    initialize_fnd_object_id(p_object_name  => G_FND_OBJECT_NAME);
    initialize_roles();
    initialize_all_users();

    -------------------------------------------
    -- All required values are initialized
    -- Go ahead with validating the records
    -------------------------------------------

    G_DATA_SET_ID := p_data_set_id;

    OPEN c_count_cpi_lines(cp_data_set_id  => G_DATA_SET_ID);
    FETCH c_count_cpi_lines INTO l_cpi_lines_count;
    CLOSE c_count_cpi_lines;
    IF  l_cpi_lines_count=0 THEN
      IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
      error_handler.Add_Error_Message
        ( p_message_name   => 'ENG_CPI_NO_LINES'
	, p_application_id => 'ENG'
	, p_message_text   => NULL
	, p_token_tbl      => l_token_tbl_none
	, p_message_type   => 'E'
	, p_row_identifier => NULL
	, p_table_name     => G_ERROR_TABLE_NAME
	, p_entity_id      => NULL
	, p_entity_index   => NULL
	, p_entity_code    => G_ERROR_ENTITY_CODE
	);
      END IF;
      x_retcode := RETCODE_ERROR;
      x_errbuff := 'ENG_CPI_NO_LINES';
      RETURN;
    END IF;

    -- initialize the loop counter values
    OPEN c_get_trans_id_limits (cp_data_set_id => G_DATA_SET_ID);
    FETCH c_get_trans_id_limits INTO l_transaction_id_min, l_transaction_id_max;
    CLOSE c_get_trans_id_limits;
    G_BATCH_SIZE := NVL(p_bulk_batch_size, G_BATCH_SIZE);
    l_loop_count := CEIL( (l_transaction_id_max - l_transaction_id_min + 1)  / G_BATCH_SIZE );
    G_FROM_LINE_NUMBER := l_transaction_id_min;
    ---------------------------
    -- all variables set
    -- start the loop now
    ---------------------------

    FOR l_batch_loop_counter IN 1..l_loop_count LOOP
      IF (l_transaction_id_max > (G_FROM_LINE_NUMBER + G_BATCH_SIZE -1)) THEN
        G_TO_LINE_NUMBER := G_FROM_LINE_NUMBER + G_BATCH_SIZE - 1;
      ELSE
        G_TO_LINE_NUMBER := l_transaction_id_max;
      END IF;
      -- call various validation routines
      -- the sequence of the calling valiadations does matter
      -- as the first error is reported and the record is flagged as error
      --
      -- setting up the status for record processing
      l_sysdate := SYSDATE;
      UPDATE eng_change_people_intf
         SET
--           login_user_id    = G_USER_ID,
--	     login_party_id   = l_login_party_id,
             creation_date    = l_sysdate,
             start_date       = NVL(start_date, l_sysdate),
	     transaction_type = UPPER(transaction_type),
	     change_mgmt_type_code = UPPER(change_mgmt_type_code),
	     grantee_type     = UPPER(grantee_type),
	     process_status   = G_PS_IN_PROCESS
       WHERE data_set_id    = G_DATA_SET_ID
	 AND process_status = G_PS_TO_BE_PROCESSED
         AND transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER;

      -- check the correct start and dates in the records
      FOR cr IN c_err_dates LOOP
	UPDATE  eng_change_people_intf
	  SET   process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  l_msg_name := 'ENG_CPI_INVALID_DATES';
          l_token_tbl_two(1).token_name  := 'START_DATE';
	  l_token_tbl_two(1).token_value := cr.start_date;
	  l_token_tbl_two(2).token_name  := 'END_DATE';
	  l_token_tbl_two(2).token_value := cr.end_date;
	  error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Dates

      -- find the error records with invalid transaction_type
      -- valid transaction_types are CREATE, UPDATE, SYNC, DELETE
      FOR cr IN c_err_transaction_type LOOP
	UPDATE  eng_change_people_intf
	  SET   process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.transaction_type IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'TRANSACTION TYPE';

	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'TRANSACTION TYPE';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.transaction_type;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Transaction Types

      --
      -- validation for grantee_type and grantee_name combination
      --
      FOR cr IN c_err_grantee_type LOOP
	UPDATE  eng_change_people_intf
	  SET   process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.grantee_type IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'GRANTEE TYPE';
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	  -- cr.grantee_type NOT IN ('USER','GROUP','COMPANY','GLOBAL')
	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'GRANTEE TYPE';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.grantee_type;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Grantee Types


      --Update the grantee_party id column for the people
      -- Fix to 4925242. Replaced upper(user_name) = upper(ecpi.grantee_name)
      -- with user_name = upper(ecpi.grantee_name)
       UPDATE eng_change_people_intf  ecpi
--          SET (ecpi.grantee_party_id, ecpi.grantee_name) =
--	          ( SELECT  person_id, person_name
          SET (ecpi.grantee_party_id) =
	          ( SELECT  person_id
		    FROM    ego_people_v
--		    WHERE   user_name = ecpi.grantee_user_name
		    WHERE   user_name = upper(ecpi.grantee_name)
		  )
       WHERE   ecpi.data_set_id = G_DATA_SET_ID
          AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
	  AND  ecpi.process_status = G_PS_IN_PROCESS
          AND  ecpi.grantee_party_id IS NULL
	  AND  ecpi.grantee_type IS NOT NULL
	  AND  ecpi.grantee_type = 'USER';

      --Update the grantee_party id column for the groups
      UPDATE eng_change_people_intf  ecpi
         SET ecpi.grantee_party_id =
                 ( SELECT  group_id
		   FROM    ego_groups_v
		   WHERE   upper(group_name) = upper(ecpi.grantee_name)
		 )
       WHERE   ecpi.data_set_id = G_DATA_SET_ID
          AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
          AND  ecpi.process_status = G_PS_IN_PROCESS
          AND  ecpi.grantee_party_id IS NULL
	  AND  ecpi.grantee_type IS NOT NULL
	  AND  ecpi.grantee_type = 'GROUP';

      --Update the grantee_party id column for the Companies
      --Company can be Enterprise / External Customer / External Supplier
      UPDATE eng_change_people_intf  ecpi
         SET ecpi.grantee_party_id =
	         ( SELECT  company_id
		   FROM    ego_companies_v
		   WHERE   upper(company_name) = upper(ecpi.grantee_name)
		 )
      WHERE   ecpi.data_set_id = G_DATA_SET_ID
         AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
         AND  ecpi.process_status = G_PS_IN_PROCESS
         AND  ecpi.grantee_party_id IS NULL
	 AND  ecpi.grantee_type IS NOT NULL
	 AND  ecpi.grantee_type = 'COMPANY';

      --Update the grantee_party id column for the Companies
      --Company can be Enterprise / External Customer / External Supplier
      UPDATE eng_change_people_intf  ecpi
         SET ecpi.grantee_party_id = G_ALL_USERS_PARTY_ID
      WHERE   ecpi.data_set_id = G_DATA_SET_ID
         AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
         AND  ecpi.process_status = G_PS_IN_PROCESS
         AND  ecpi.grantee_party_id IS NULL
	 AND  ecpi.grantee_type IS NOT NULL
	 AND  ecpi.grantee_type = 'GLOBAL';

      -- For missing grantee_party_id, update process_status and log an error.
      -- Also, assign transaction_id, request_id
      FOR cr IN c_err_grantee_id LOOP
        UPDATE eng_change_people_intf
	SET    process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	  -- Grantee Name check
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.grantee_name IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'GRANTEE NAME';
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'GRANTEE NAME';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.grantee_name;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_grantee_id

      -- Retrieval of Role Ids is done in 2 steps :
      --1) Retrieve and store the Display and Internal Role Names and Role Ids
      --   and store in a temp table.  This is done by initialise_roles()
      --2) Verify the roles from the temporary table.
      --
      UPDATE eng_change_people_intf  ecpi
          SET (ecpi.internal_role_id, ecpi.internal_role_name ) =
	          ( SELECT  role.internal_role_id,
		            role.internal_role_name
		    FROM    eng_change_roles_temp  role
		    WHERE   role.display_role_name = ecpi.display_role_name
		  )
      WHERE   ecpi.data_set_id = G_DATA_SET_ID
         AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
         AND  ecpi.process_status = G_PS_IN_PROCESS
         AND  ecpi.internal_role_id IS NULL
         AND  ecpi.display_role_name IS NOT NULL
         AND EXISTS ( SELECT  role2.internal_role_id
	               FROM    eng_change_roles_temp  role2
		       WHERE   role2.display_role_name = ecpi.display_role_name
		     );

      -- For missing roles, update process_status and log an error.
      FOR cr IN c_err_role_id LOOP
	UPDATE eng_change_people_intf
	SET    process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          IF ( cr.display_role_name IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'DISPLAY ROLE NAME';
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'DISPLAY ROLE NAME';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.display_role_name;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_role_id

      --Update the organization id column
      UPDATE eng_change_people_intf  ecpi
         SET ecpi.organization_id =
	         ( SELECT  mp.organization_id
		   FROM    mtl_parameters  mp
		   WHERE   mp.organization_code = ecpi.organization_code
		 )
      WHERE  ecpi.data_set_id = G_DATA_SET_ID
        AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  ecpi.process_status = G_PS_IN_PROCESS
        AND  ecpi.organization_id IS NULL
        AND  ecpi.organization_code IS NOT NULL
        AND EXISTS ( SELECT  mp2.organization_id
	             FROM    mtl_parameters  mp2
		     WHERE  mp2.organization_code = ecpi.organization_code
		   );

      -- For missing organization_id, update process_status and log an error.
      -- Also, assign transaction_id, request_id

      FOR cr IN c_err_org_id LOOP
	UPDATE eng_change_people_intf
	SET    process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.organization_code IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'ORGANIZATION CODE';
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'ORGANIZATION CODE';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.organization_code;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_org_id


      --
      -- Organization id is obtained, Please check the change_mgmt_type_code now
      --

      -- find the error records with invalid change_mgmt_type_code
      --  --valid change_mgmt_type_code are in ENG_CHANGE_MGMT_TYPES Table
      -- valid change_mgmt_type_codes are available in the ENG_CHANGE_ORDER_TYPES table.
      -- Table ENG_CHANGE_MGMT_TYPES has been obsoleted.

      FOR cr IN c_err_chg_mgmt_type_code LOOP
	UPDATE  eng_change_people_intf
	  SET   process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.change_mgmt_type_code IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'CHANGE MGMT TYPE';

	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE

	    l_msg_name := 'ENG_CPI_INVALID_VALUE2';
	    l_token_tbl_two(1).token_name  := 'NAME';
	    l_token_tbl_two(1).token_value := 'CHANGE MGMT TYPE';
	    l_token_tbl_two(2).token_name  := 'VALUE';
	    l_token_tbl_two(2).token_value := cr.change_mgmt_type_code;
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_two
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Change Mgmt Type Codes


      UPDATE eng_change_people_intf  ecpi
         SET ecpi.change_id =
	         ( SELECT  change_id
		   FROM    eng_engineering_changes eec
		   WHERE   ecpi.change_notice = eec.change_notice
		   AND     ecpi.organization_id = eec.organization_id
		   AND     ecpi.change_mgmt_type_code = eec.change_mgmt_type_code
		 )
      WHERE  ecpi.data_set_id = G_DATA_SET_ID
        AND  ecpi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  ecpi.process_status = G_PS_IN_PROCESS
        AND  ecpi.change_id IS NULL
        AND EXISTS ( SELECT  change_id
		   FROM    eng_engineering_changes eec
		   WHERE   ecpi.change_notice = eec.change_notice
		   AND     ecpi.organization_id = eec.organization_id
		   AND     ecpi.change_mgmt_type_code = eec.change_mgmt_type_code
		   );

      -- For missing organization_id, update process_status and log an error.
      -- Also, assign transaction_id, request_id

      FOR cr IN c_err_change_id LOOP
	UPDATE eng_change_people_intf
	SET    process_status   = G_PS_ERROR
	  WHERE transaction_id = cr.transaction_id;
	IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
	  IF ( cr.change_notice IS NULL ) THEN
	    l_msg_name := 'ENG_CPI_MISSING_VALUE';
	    l_token_tbl_one(1).token_name  := 'VALUE';
	    l_token_tbl_one(1).token_value := 'CHANGE NOTICE';
	    error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_one
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  ELSE
	    l_msg_name := 'ENG_CPI_INVALID_VALUE3';
	      l_token_tbl_three(1).token_name  := 'CHANGE_NOTICE';
	      l_token_tbl_three(1).token_value := cr.change_notice;
	      l_token_tbl_three(2).token_name  := 'CHANGE_MGMT_TYPE_CODE';
	      l_token_tbl_three(2).token_value := cr.change_mgmt_type_code;
	      l_token_tbl_three(3).token_name  := 'ORGANIZATION';
	      l_token_tbl_three(3).token_value := cr.organization_code;
	      error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
	      , p_application_id => 'ENG'
	      , p_message_text   => NULL
	      , p_token_tbl      => l_token_tbl_three
	      , p_message_type   => 'E'
	      , p_row_identifier => cr.transaction_id
	      , p_table_name     => G_ERROR_TABLE_NAME
	      , p_entity_id      => NULL
	      , p_entity_index   => NULL
	      , p_entity_code    => G_ERROR_ENTITY_CODE
	      );
	  END IF;
	END IF;
        check_and_write_log (x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_change_notice

       --Retrieve the Change Id from Change Notice and Organization Id.

      /***********************************/
      -- commit the data after every batch
      --
      -- increment the loop values
      G_FROM_LINE_NUMBER := G_TO_LINE_NUMBER + 1;
    END LOOP; -- l_batch_loop_counter

    --
    -- upload the data into fnd_grants
    --
    validate_no_grant_overlap(x_retcode  => x_retcode);
    write_log_now();
    --
    -- call purge_interface_lines if required
    --

    IF p_delete_lines IN (DELETE_ALL, DELETE_ERROR, DELETE_SUCCESS) THEN
      purge_interface_lines
                  (p_data_set_id        => p_data_set_id
                  ,p_closed_date        => NULL
		  ,p_delete_line_type   => p_delete_lines
--		  ,p_delete_error_log   => NULL
                  ,x_retcode            => l_retcode
                  ,x_errbuff            => l_errbuff
                  );
    END IF;
    IF l_retcode = RETCODE_SUCCESS THEN
      x_retcode := RETCODE_SUCCESS;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      x_retcode := RETCODE_ERROR;
      x_errbuff := 'EGO_IPI_EXCEPTION';
      IF c_user_party_id%ISOPEN THEN
        CLOSE c_user_party_id;
      END IF;
      IF c_count_cpi_lines %ISOPEN THEN
        CLOSE c_count_cpi_lines;
      END IF;
      IF c_get_trans_id_limits %ISOPEN THEN
        CLOSE c_get_trans_id_limits;
      END IF;
      IF c_err_dates%ISOPEN THEN
        CLOSE c_err_dates;
      END IF;
      IF c_err_transaction_type%ISOPEN THEN
        CLOSE c_err_transaction_type;
      END IF;
      IF c_err_grantee_type%ISOPEN THEN
        CLOSE c_err_grantee_type;
      END IF;
      IF c_err_grantee_id%ISOPEN THEN
        CLOSE c_err_grantee_id;
      END IF;
      IF c_err_role_id%ISOPEN THEN
        CLOSE c_err_role_id;
      END IF;
      IF c_err_org_id%ISOPEN THEN
        CLOSE c_err_org_id;
      END IF;
      IF c_err_chg_mgmt_type_code%ISOPEN THEN
        CLOSE c_err_chg_mgmt_type_code;
      END IF;
      IF c_err_change_id%ISOPEN THEN
	CLOSE c_err_change_id;
      END IF;
      IF c_get_grant_privileges%ISOPEN THEN
        CLOSE c_get_grant_privileges;
      END IF;
      IF c_get_utl_file_dir%ISOPEN THEN
        CLOSE c_get_utl_file_dir;
      END IF;

  END load_interface_lines;


  PROCEDURE purge_interface_lines
                 ( p_data_set_id        IN     	NUMBER,
                   p_closed_date        IN     	DATE,
		   p_delete_line_type   IN      NUMBER,
--		   p_delete_error_log   IN      NUMBER,
                   x_retcode            OUT NOCOPY VARCHAR2,
                   x_errbuff            OUT NOCOPY VARCHAR2
                 ) IS
    -- Start OF comments
    -- API name  : Clean Interface Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Removes all the interface lines
    --
  BEGIN
    -- validate the given parameters
    IF (p_data_set_id IS NULL AND p_closed_date IS NULL)
       OR  NVL(p_delete_line_type,-1) NOT IN (DELETE_ALL, DELETE_ERROR, DELETE_SUCCESS) THEN
       -- invalid parameters
      x_retcode := RETCODE_ERROR;
      x_errbuff := 'ENG_CPI_INSUFFICIENT_PARAMS';
    ELSE
      IF p_delete_line_type = DELETE_ALL THEN
        --
        -- delete all lines
        --
        DELETE mtl_interface_errors
	WHERE table_name = G_ERROR_TABLE_NAME
	AND  transaction_id IN
	  ( SELECT transaction_id
	    FROM   eng_change_people_intf
	    WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
	      AND  creation_date <= NVL(p_closed_date, creation_date)
	  );
        DELETE eng_change_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date);
      ELSIF p_delete_line_type = DELETE_ERROR THEN
        --
        -- delete all error lines
        --
        DELETE mtl_interface_errors
	WHERE table_name = G_ERROR_TABLE_NAME
	AND  transaction_id IN
	  ( SELECT transaction_id
	    FROM   eng_change_people_intf
	    WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
	      AND  creation_date <= NVL(p_closed_date, creation_date)
	  );
        DELETE eng_change_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date)
	  AND  process_status = G_PS_ERROR;
      ELSIF p_delete_line_type = DELETE_SUCCESS THEN
        --
        -- delete all success lines
        --
        DELETE eng_change_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date)
	  AND  process_status = G_PS_SUCCESS;
      END IF;
      COMMIT;
      x_retcode := RETCODE_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      x_errbuff := 'ENG_CPI_EXCEPTION';
      ROLLBACK;

  END purge_interface_lines;

END EGO_CHANGE_PEOPLE_IMPORT_PKG;

/

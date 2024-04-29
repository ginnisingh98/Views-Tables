--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_PEOPLE_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_PEOPLE_IMPORT_PKG" AS
/* $Header: EGOCIPIB.pls 120.16.12010000.2 2009/06/16 11:41:15 kjonnala ship $ */

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
  G_FND_OBJECT_NAME        VARCHAR2(99) := 'EGO_ITEM';

  --Indicates the object id (set using g_Fnd_Object_Name)
  G_FND_OBJECT_ID          fnd_objects.object_id%TYPE;

  -- Seeded value for all_users (group available in hz_parties)
  G_ALL_USERS_PARTY_ID     PLS_INTEGER  := -1000;

  -- Batch size that needs to be processed
  G_BATCH_SIZE             NUMBER;

  -- Message array size
  G_MAX_MESSAGE_SIZE       PLS_INTEGER := 1000;

  G_ERROR_TABLE_NAME      VARCHAR2(99) := 'EGO_ITEM_PEOPLE_INTF';
  G_ERROR_ENTITY_CODE     VARCHAR2(99) := 'EGO_ITEM_PEOPLE';
  G_ERROR_FILE_NAME       VARCHAR2(99);
  G_BO_IDENTIFIER         VARCHAR2(99) := 'EGO_ITEM_PEOPLE';
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
  G_DATA_SET_ID           EGO_ITEM_PEOPLE_INTF.data_set_id%TYPE;
  G_FROM_LINE_NUMBER      NUMBER;
  G_TO_LINE_NUMBER        NUMBER;
  G_TRANSACTION_ID        NUMBER;
  G_DEBUG_MODE            PLS_INTEGER;

  -- intermediate statuses for errors
  G_INT_ITEM_VAL_ERROR    NUMBER    := 100;
  G_INT_ORG_VAL_ERROR     NUMBER    := 110;

  G_HAS_ERRORS            BOOLEAN;

  G_TABLE_LOG             BOOLEAN;
  G_FILE_LOG              BOOLEAN;
  --Indicates the person has Global access (full privileges) to access
  --all the Items.
  --Eg. This can happen when the profile is set to grant internal employees
  --an 'Item Owner' role. Then an employee gets Full access to all the items.
  --He can make grants to the items etc.,
  G_FULL_ACCESS_ITEMS     BOOLEAN := FALSE;

  -----------------------------------------------------------------------
  --  Debug Profile option used to write Error_Handler.Write_Debug     --
  --  Profile option name = INV_DEBUG_TRACE ;                          --
  --  User Profile Option Name = INV: Debug Trace                      --
  --  Values: 1 (True) ; 0 (False)                                     --
  --  NOTE: This better than MRP_DEBUG which is used at many places.   --
  -----------------------------------------------------------------------
  G_ERR_HANDLER_DEBUG CONSTANT VARCHAR2(10) := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

-- =================================================================
-- Global variables used for Bulk Processing
-- =================================================================
--  TYPE g_t_grant_guid_table           IS TABLE OF fnd_grants.grant_guid%TYPE                         INDEX BY BINARY_INTEGER;
--
--  TYPE g_t_transaction_id_table       IS TABLE OF ego_item_people_intf.transaction_id%TYPE      INDEX BY BINARY_INTEGER;
--  TYPE g_t_start_date_table           IS TABLE OF ego_item_people_intf.start_date%TYPE          INDEX BY BINARY_INTEGER;
--  TYPE g_t_end_date_table             IS TABLE OF ego_item_people_intf.end_date%TYPE            INDEX BY BINARY_INTEGER;
--  TYPE g_t_grantee_type_table         IS TABLE OF ego_item_people_intf.grantee_type%TYPE        INDEX BY BINARY_INTEGER;
--  TYPE g_t_grantee_name_table         IS TABLE OF ego_item_people_intf.grantee_name%TYPE        INDEX BY BINARY_INTEGER;
--  TYPE g_t_inventory_item_id_table    IS TABLE OF ego_item_people_intf.inventory_item_id%TYPE   INDEX BY BINARY_INTEGER;
--  TYPE g_t_internal_role_id_table     IS TABLE OF ego_item_people_intf.internal_role_id%TYPE    INDEX BY BINARY_INTEGER;
--  TYPE g_t_grantee_party_id_table     IS TABLE OF ego_item_people_intf.grantee_party_id%TYPE    INDEX BY BINARY_INTEGER;
--  TYPE g_t_grantee_key_table          IS TABLE OF VARCHAR2(50)                                       INDEX BY BINARY_INTEGER;

  ----------------------------------------------------------------------
  -- Global variables used for Parsing process.
  ----------------------------------------------------------------------

  /*----------------------------------------------------------------------
  -- TODO

  1. Didnot do a bulk call for Error writing, as Rahul said he has the
     Generic Error Handler API that can be used for the same.
     So referred Item Category Assignment API for coding call to Generic
     Error API.

  ----------------------------------------------------------------------*/

---------------------------------------------
--    PRIVATE  PROCEDURES AND FUNCTIONS    --
---------------------------------------------

  debug_line_count  PLS_INTEGER := 0;

----------------------------------------------------------
-- Writing given string to Concurrent Log File          --
----------------------------------------------------------

PROCEDURE Conc_Log (p_msg  IN  VARCHAR2) IS
BEGIN
  FND_FILE.put_line(which => fnd_file.log
                   ,buff  => p_msg);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Conc_Log;

----------------------------------------------------------
-- Writing given string to Concurrent Output            --
----------------------------------------------------------

PROCEDURE Conc_Output (p_msg  IN  VARCHAR2) IS
BEGIN
  FND_FILE.put_line (which => fnd_file.output
                    ,buff  => p_msg);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Conc_Output;

 ----------------------------------------------------------
 -- Writing given string to Error Handler Log File       --
 ----------------------------------------------------------

  PROCEDURE Write_Debug (p_message   VARCHAR2) IS
    -- Start OF comments
    -- API name  : debug function
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : log the error as per the debug mode chosen by the user
    --
    -- Parameters:
    --     IN    : message to be logged
  BEGIN
--  DEBUG_MODE_FATAL             NUMBER    := 1;
--  DEBUG_MODE_ERROR             NUMBER    := 2;
--  DEBUG_MODE_INFO              NUMBER    := 3;
--  DEBUG_MODE_DEBUG             NUMBER    := 4;

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
      -- developer debug mode
      Conc_log ('['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')|| ' => '||p_message);
    END IF;
-- sri_debug(p_message);
    -------------------------------------------------
    -- If Error Handler Profile set to TRUE        --
    -------------------------------------------------
    IF (G_ERR_HANDLER_DEBUG = 1) THEN
       Error_Handler.Write_Debug('['||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||'] '|| p_message);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END Write_Debug;

 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------

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
      FROM   ego_item_people_intf
      WHERE  data_set_id = G_DATA_SET_ID
        AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND   process_status = G_PS_ERROR;

      Write_Debug (' Total error records from ' || TO_CHAR(G_FROM_LINE_NUMBER) || ' to ' || TO_CHAR(G_TO_LINE_NUMBER)|| ' is ' ||to_char(l_error_record_count));
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END error_count_records;

 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------

  PROCEDURE purge_login_items_table IS
    -- Start of comments
    -- API name  : purge_login_items_table
    -- TYPE      : PRIVATE
    -- Pre-reqs  : None
    -- FUNCTION  : Delete the records from EGO_LOGIN_ITEMS_TEMP
    --
    -- Parameters:
    --     IN    : NONE
    --
  BEGIN
    DELETE EGO_LOGIN_ITEMS_TEMP WHERE CONC_REQUEST_ID = G_REQUEST_ID;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END purge_login_items_table;

----------------------------------------------------------
--  To flush the errors recorded in Error Handler into  --
--  appropriate destination                             --
----------------------------------------------------------
PROCEDURE write_log_now  IS
    -- Start OF comments
    -- API name  : write_log_now
    -- TYPE      : PRIVATE
    -- Pre-reqs  : NONE
    -- FUNCTION  : To write the error into appropriate log
    --
    -- Parameters:
    --     IN    : NONE
    --

  BEGIN
    G_HAS_ERRORS := TRUE;
    IF G_TABLE_LOG THEN
         ERROR_HANDLER.Log_Error(p_write_err_to_inttable   => 'Y'
                                ,p_write_err_to_conclog    => 'Y'
                                ,p_write_err_to_debugfile  => 'N');
    ELSE
         ERROR_HANDLER.Log_Error(p_write_err_to_inttable   => 'N'
                                ,p_write_err_to_conclog    => 'Y'
                                ,p_write_err_to_debugfile  => 'N');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END write_log_now;


 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------
  PROCEDURE check_and_write_log (p_msg_size IN NUMBER
                                ,x_retcode  OUT NOCOPY  VARCHAR2) IS
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
    --    OUT    : x_retcode    VARCHAR2
    --                return status of the program
    --

  BEGIN
    IF Error_Handler.Get_Message_Count() > p_msg_size THEN
      write_log_now();
      error_Handler.Initialize();
    END IF;
    x_retcode := RETCODE_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      purge_login_items_table();
      ROLLBACK;
      RAISE;
  END;

 ----------------------------------------------------------
 -- Get the object id for the object name passeed        --
 ----------------------------------------------------------
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
      IF c_fnd_object_id%ISOPEN THEN
        CLOSE c_fnd_object_id;
      END IF;
      RAISE;
  END initialize_fnd_object_id;


 ----------------------------------------------------------
 -- Get party id for all users.  If record not defined,  --
 -- take the value as -1000
 ----------------------------------------------------------
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
      G_ALL_USERS_PARTY_ID := -1000;
    END IF;
    CLOSE c_all_users_party_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_all_users_party_id%ISOPEN THEN
        CLOSE c_all_users_party_id;
      END IF;
      RAISE;
  END initialize_all_users;

 -----------------------------------------------------------
 -- Populate temporary table EGO_LOGIN_ITEMS_TEMP with    --
 -- the itmes on which the user has 'EGO_ADD_ITEM_PEOPLE' --
 -- privilege                                             --
 -----------------------------------------------------------
  PROCEDURE Initialize_Access_Items
              (p_login_person_id   IN         NUMBER,
               x_retcode           OUT NOCOPY VARCHAR2) IS
    -- Start OF comments
    -- API name  : Initialize_Access_Items
    -- TYPE      : PRIVATE
    -- Pre-reqs  : Valid user has logged in
    --
    -- FUNCTION  : To populate temporary table EGO_LOGIN_ITEMS_TEMP
    --             with the items onto which the user can give access
    --
    -- Parameters:
    --     IN    : NONE
    --
    l_sec_predicate   VARCHAR2(10000);
    l_return_status   VARCHAR2(10);

    l_count           NUMBER := 0;
    l_select_sql      VARCHAR2(32767);
    l_insert_sql      VARCHAR2(500);
    cursor_select     INTEGER;
    cursor_insert     INTEGER;
    cursor_execute    INTEGER;
    l_item_id_table        DBMS_SQL.NUMBER_TABLE;
    l_org_id_table         DBMS_SQL.NUMBER_TABLE;
    l_conc_req_id_table    DBMS_SQL.NUMBER_TABLE;
    indx              NUMBER(10) := 1;

    l_program_name    VARCHAR2(99) := 'INITIALIZE_ACCESS_ITEMS';

  BEGIN


    -----------------------------------------------------------------------
    -- Fix for Bug# 3603328.
    -- Deleting the entire table, is avoided.
    -- Now seeding Item rows striped with Concurrent Request ID.
    -- Rows will be deleted, per Conc Req ID, at the end of processing.
    -----------------------------------------------------------------------
    -- DELETE EGO_LOGIN_ITEMS_TEMP;

    EGO_DATA_SECURITY.get_security_predicate(
            p_api_version      => 1.0,
            p_function         => 'EGO_ADD_ITEM_PEOPLE',
            p_object_name      => G_FND_OBJECT_NAME,
            p_user_name        => 'HZ_PARTY:'||TO_CHAR(p_login_person_id),
            p_statement_type   => 'EXISTS',
            p_pk1_alias        => 'OUT_MSIB.INVENTORY_ITEM_ID',
            p_pk2_alias        => 'OUT_MSIB.ORGANIZATION_ID',
            p_pk3_alias        => NULL,
            p_pk4_alias        => NULL,
            p_pk5_alias        => NULL,
            x_predicate        => l_sec_predicate,
            x_return_status    => l_return_status );

    --Check for Full access to items, and RETURN if TRUE;
    IF ((l_sec_predicate IS NULL) OR (l_sec_predicate = '')) THEN
      G_FULL_ACCESS_ITEMS := TRUE ;
      x_retcode := RETCODE_SUCCESS;
      --If there user has Full access to items, then there is no need
      --to populate the temp table. Hence return;
      RETURN;
    END IF;

    ----------------------------------------------------------------------------------
    -- NOTE: Aliasing of the following Table needs to be done to OUT_MSIB as the
    -- Security predicate also has references to MTL_SYSTEM_ITEMS, and we need to
    -- to differentiate it in the eventual SQL generated.
    ----------------------------------------------------------------------------------
    l_select_sql :=
      ' SELECT  OUT_MSIB.INVENTORY_ITEM_ID, OUT_MSIB.ORGANIZATION_ID, ' || G_REQUEST_ID ||
      ' FROM MTL_SYSTEM_ITEMS OUT_MSIB ';

    l_select_sql := l_select_sql || 'WHERE ' || l_sec_predicate ;

    Write_Debug('Access Items SQL => '||l_select_sql);

    l_insert_sql := 'INSERT INTO EGO_LOGIN_ITEMS_TEMP (INVENTORY_ITEM_ID, ORGANIZATION_ID, CONC_REQUEST_ID) ';
    l_insert_sql := l_insert_sql || ' VALUES (:l_item_id_table, :l_org_id_table, :l_conc_req_id_table) ';

    cursor_select := DBMS_SQL.OPEN_CURSOR;
    cursor_insert := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(cursor_select,l_select_sql,DBMS_SQL.NATIVE);
    DBMS_SQL.PARSE(cursor_insert,l_insert_sql,DBMS_SQL.NATIVE);

    DBMS_SQL.DEFINE_ARRAY(cursor_select, 1,l_item_id_table,2500, indx);
    DBMS_SQL.DEFINE_ARRAY(cursor_select, 2,l_org_id_table,2500, indx);
    DBMS_SQL.DEFINE_ARRAY(cursor_select, 3,l_conc_req_id_table,2500, indx);

    Write_Debug('Select Access Items execute...');
    cursor_execute := DBMS_SQL.EXECUTE(cursor_select);

    LOOP
      l_count := DBMS_SQL.FETCH_ROWS(cursor_select);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 1, l_item_id_table);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 2, l_org_id_table);
      DBMS_SQL.COLUMN_VALUE(cursor_select, 3, l_conc_req_id_table);

      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_item_id_table',l_item_id_table);
      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_org_id_table',l_org_id_table);
      DBMS_SQL.BIND_ARRAY(cursor_insert,':l_conc_req_id_table',l_conc_req_id_table);

      Write_Debug('Inserting ''Access Items'' into table');
      cursor_execute := DBMS_SQL.EXECUTE(cursor_insert);
      l_item_id_table.DELETE;
      l_org_id_table.DELETE;
      l_conc_req_id_table.DELETE;

      --For the final batch of records, either it will be 0 or < 2500
      EXIT WHEN l_count <> 2500;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(cursor_select);
    DBMS_SQL.CLOSE_CURSOR(cursor_insert);

    Write_Debug('Cursors Insert Access Items and Select Access Items closed...');
  EXCEPTION
     WHEN OTHERS THEN
        Write_Debug(' EXCEPTION in Initialize_Access_items');
        x_retcode := RETCODE_ERROR;
        IF DBMS_SQL.IS_OPEN(cursor_select) THEN
           DBMS_SQL.CLOSE_CURSOR(cursor_select);
        END IF;
        IF DBMS_SQL.IS_OPEN(cursor_insert) THEN
           DBMS_SQL.CLOSE_CURSOR(cursor_insert);
        END IF;
        RAISE;
  END Initialize_Access_Items;

 ----------------------------------------------------------
 -- Delete lines from the interface and error table      --
 ----------------------------------------------------------
  PROCEDURE purge_lines
                 ( p_data_set_id        IN      NUMBER,
                   p_closed_date        IN      DATE,
                   p_delete_line_type   IN      NUMBER,
                   x_retcode            OUT NOCOPY VARCHAR2,
                   x_errbuff            OUT NOCOPY VARCHAR2
                 ) IS
    -- Start OF comments
    -- API name  : Clean Interface Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Removes all the interface lines
    --
    l_program_name  CONSTANT   VARCHAR2(30) := 'PURGE_LINES';
  BEGIN


    -------------------------------------------------------------------------------
    -- Validate the given parameters.
    -- Perform the DELETE operation accordingly.
    -------------------------------------------------------------------------------
    IF (p_data_set_id IS NULL AND p_closed_date IS NULL)
       OR  NVL(p_delete_line_type,EGO_ITEM_PUB.G_INTF_DELETE_NONE) NOT IN
          (EGO_ITEM_PUB.G_INTF_DELETE_ALL
          ,EGO_ITEM_PUB.G_INTF_DELETE_ERROR
          ,EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS
          ,EGO_ITEM_PUB.G_INTF_DELETE_NONE
          ) THEN
       -- invalid parameters
      x_retcode := RETCODE_ERROR;
      fnd_message.set_name('EGO','EGO_IPI_INSUFFICIENT_PARAMS');
      fnd_message.set_token('PROG_NAME',l_program_name);
      x_errbuff := fnd_message.get();
      Conc_Output (p_msg => x_errbuff);
    ELSE
      IF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_ALL THEN
        --
        -- delete all lines
        --
        DELETE mtl_interface_errors
         WHERE table_name = G_ERROR_TABLE_NAME
           AND transaction_id IN
               (SELECT transaction_id
                FROM   ego_item_people_intf
                WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
                  AND  creation_date <= NVL(p_closed_date, creation_date)
                );
        DELETE ego_item_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date);

      ELSIF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_ERROR THEN
        --
        -- delete all error lines
        --
        DELETE mtl_interface_errors
         WHERE table_name = G_ERROR_TABLE_NAME
           AND transaction_id IN
               (SELECT transaction_id
                FROM   ego_item_people_intf
                WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
                  AND  creation_date <= NVL(p_closed_date, creation_date)
                );
        DELETE ego_item_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date)
          AND  process_status = G_PS_ERROR;

      ELSIF p_delete_line_type = EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS THEN
        --
        -- delete all success lines
        --
        DELETE ego_item_people_intf
        WHERE  data_set_id = NVL(p_data_set_id, data_set_id)
          AND  creation_date <= NVL(p_closed_date, creation_date)
          AND  process_status = G_PS_SUCCESS;
      END IF;
      IF p_delete_line_type IN
                   (EGO_ITEM_PUB.G_INTF_DELETE_ALL
                   ,EGO_ITEM_PUB.G_INTF_DELETE_ERROR
                   ,EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS
                   ) THEN
        COMMIT WORK;
      END IF;
      x_retcode := RETCODE_SUCCESS;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      fnd_message.set_name('EGO','EGO_IPI_EXCEPTION');
      fnd_message.set_token('PROG_NAME',l_program_name);
      x_errbuff := fnd_message.get();
      Conc_Output (p_msg => x_errbuff);
      Write_Debug (x_errbuff);
--      ROLLBACK;
      RAISE;
  END purge_lines;


 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------
  PROCEDURE validate_update_grant
     (p_transaction_type      IN  VARCHAR2
     ,p_transaction_id        IN  NUMBER
     ,p_inventory_item_id     IN  NUMBER
     ,p_organization_id       IN  NUMBER
     ,p_internal_role_id      IN  NUMBER
     ,p_user_party_id_char    IN  VARCHAR2
     ,p_group_party_id_char   IN  VARCHAR2
     ,p_company_party_id_char IN  VARCHAR2
     ,p_global_party_id_char  IN  VARCHAR2
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
    --             NO ACTION IS PERFORMED ON ego_item_people_intf
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
               (cp_inv_item_id            IN  NUMBER
               ,cp_organization_id        IN  NUMBER
               ,cp_menu_id                IN  NUMBER
         ,cp_object_id              IN  NUMBER
         ,cp_user_party_id_char     IN  VARCHAR2
         ,cp_group_party_id_char    IN  VARCHAR2
         ,cp_company_party_id_char  IN  VARCHAR2
         ,cp_global_party_id_char   IN  VARCHAR2
         ,cp_start_date             IN  DATE
         ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = G_FND_OBJECT_ID
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_inv_item_id)
      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'    AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'   AND grants.grantee_key =  cp_group_party_id_char) OR
             (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char) OR
       (grants.grantee_type =  'GLOBAL'  AND grants.grantee_key =  cp_global_party_id_char)
      )
      AND   start_date = cp_start_date;

  CURSOR c_get_valid_update
      (cp_grant_guid             IN  RAW
      ,cp_inv_item_id            IN  NUMBER
      ,cp_organization_id        IN  NUMBER
      ,cp_menu_id                IN  NUMBER
      ,cp_object_id              IN  NUMBER
      ,cp_user_party_id_char     IN  VARCHAR2
      ,cp_group_party_id_char    IN  VARCHAR2
      ,cp_company_party_id_char  IN  VARCHAR2
      ,cp_global_party_id_char   IN  VARCHAR2
      ,cp_start_date             IN  DATE
      ,cp_end_date               IN  DATE
           ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.grant_guid        <> cp_grant_guid
      AND   grants.object_id          = cp_object_id
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_inv_item_id)
      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'    AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'   AND grants.grantee_key =  cp_group_party_id_char) OR
             (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char) OR
       (grants.grantee_type =  'GLOBAL'  AND grants.grantee_key =  cp_global_party_id_char)
      )
      AND   start_date <= NVL(cp_end_date, start_date)
      AND   NVL(end_date,cp_start_date) >= cp_start_date;

  l_token_tbl_two         Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;
  l_grant_guid            fnd_grants.grant_guid%TYPE;
  l_temp_grant_guid       fnd_grants.grant_guid%TYPE;

  l_success               VARCHAR2(999);
  l_item_number           VARCHAR2(100);

  BEGIN
    OPEN c_get_update_grantid
                (cp_inv_item_id            => p_inventory_item_id
                ,cp_organization_id        => p_organization_id
                ,cp_menu_id                => p_internal_role_id
                ,cp_object_id              => G_FND_OBJECT_ID
                ,cp_user_party_id_char     => p_user_party_id_char
                ,cp_group_party_id_char    => p_group_party_id_char
                ,cp_company_party_id_char  => p_company_party_id_char
                ,cp_global_party_id_char   => p_global_party_id_char
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
                  ,cp_inv_item_id            => p_inventory_item_id
                  ,cp_organization_id        => p_organization_id
                  ,cp_menu_id                => p_internal_role_id
                  ,cp_object_id              => G_FND_OBJECT_ID
                  ,cp_user_party_id_char     => p_user_party_id_char
                  ,cp_group_party_id_char    => p_group_party_id_char
                  ,cp_company_party_id_char  => p_company_party_id_char
                  ,cp_global_party_id_char   => p_global_party_id_char
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
                ( p_message_name   => 'EGO_IPI_OVERLAP_GRANT'
                , p_application_id => 'EGO'
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
          l_token_tbl_one(1).token_name  := 'ITEM';
          -- query the item number
          SELECT CONCATENATED_SEGMENTS
            INTO l_item_number
            FROM MTL_SYSTEM_ITEMS_KFV
           WHERE INVENTORY_ITEM_ID = p_inventory_item_id
             AND ORGANIZATION_ID = p_organization_id;
          l_token_tbl_one(1).token_value := l_item_number;
          error_handler.Add_Error_Message
                ( p_message_name   => 'EGO_IPI_GRANT_NOT_FOUND'
                , p_application_id => 'EGO'
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
      Write_Debug(' EXCEPTION in validate_update_grant ');
      IF c_get_update_grantid%ISOPEN THEN
        CLOSE c_get_update_grantid;
      END IF;
      IF c_get_valid_update%ISOPEN THEN
        CLOSE c_get_valid_update;
      END IF;
      RAISE;
  END validate_update_grant;


 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------
  PROCEDURE validate_insert_grant
           (p_transaction_type      IN  VARCHAR2
           ,p_transaction_id        IN  NUMBER
           ,p_inventory_item_id     IN  NUMBER
           ,p_organization_id       IN  NUMBER
           ,p_internal_role_id      IN  NUMBER
           ,p_internal_role_name    IN  VARCHAR2
           ,p_grantee_type          IN  VARCHAR2
           ,p_grantee_key           IN  VARCHAR2
           ,p_user_party_id_char    IN  VARCHAR2
           ,p_group_party_id_char   IN  VARCHAR2
           ,p_company_party_id_char IN  VARCHAR2
           ,p_global_party_id_char  IN  VARCHAR2
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
    --             NO ACTION IS PERFORMED ON ego_item_people_intf
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
      (cp_inv_item_id            IN  NUMBER
      ,cp_organization_id        IN  NUMBER
      ,cp_menu_id                IN  NUMBER
      ,cp_object_id              IN  NUMBER
      ,cp_user_party_id_char     IN  VARCHAR2
      ,cp_group_party_id_char    IN  VARCHAR2
      ,cp_company_party_id_char  IN  VARCHAR2
      ,cp_global_party_id_char   IN  VARCHAR2
      ,cp_start_date             IN  DATE
      ,cp_end_date               IN  DATE
      ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = cp_object_id
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_inv_item_id)
      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'    AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'   AND grants.grantee_key =  cp_group_party_id_char) OR
             (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char) OR
       (grants.grantee_type =  'GLOBAL'  AND grants.grantee_key =  cp_global_party_id_char)
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
         (cp_inv_item_id            => p_inventory_item_id
         ,cp_organization_id        => p_organization_id
         ,cp_menu_id                => p_internal_role_id
         ,cp_object_id              => G_FND_OBJECT_ID
         ,cp_user_party_id_char     => p_user_party_id_char
         ,cp_group_party_id_char    => p_group_party_id_char
         ,cp_company_party_id_char  => p_company_party_id_char
         ,cp_global_party_id_char   => p_global_party_id_char
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
              ( p_message_name   => 'EGO_IPI_OVERLAP_GRANT'
              , p_application_id => 'EGO'
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
              ,p_instance_pk1_value  =>  TO_CHAR(p_inventory_item_id)
              ,p_instance_pk2_value  =>  TO_CHAR(p_organization_id)
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
      Write_Debug(' EXCEPTION in validate_insert_grant ');
      IF c_get_overlap_grantid%ISOPEN THEN
        CLOSE c_get_overlap_grantid;
      END IF;
      RAISE;
  END validate_insert_grant;


 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------
  PROCEDURE Validate_No_Grant_Overlap ( x_retcode  OUT NOCOPY VARCHAR2) IS
    -- Start OF comments
    -- API name  : Validate No Grant Overlap
    -- TYPE      : Private (called by load_interface_lines)
    -- Pre-reqs  : Data validated for all possible scenarios (but for grants)
    -- FUNCTION  : Validate grant overlap.
    --             Take all records to be deleted and process them
    --             Take all the records to be updated and update grants
    --             Finally insert new grants
    --

  CURSOR c_get_ipi_records IS
    SELECT item_number, inventory_item_id, organization_id, grantee_party_id, grantee_type,
           start_date, end_date, transaction_id, internal_role_id, transaction_type,
     internal_role_name,
         DECODE(grantee_type, 'USER', 'HZ_PARTY:'||TO_CHAR(grantee_party_id),
                          'GROUP','HZ_GROUP:'||TO_CHAR(grantee_party_id),
        'COMPANY','HZ_COMPANY:'||TO_CHAR(grantee_party_id),
-- bug: 3460466
-- All Users is now represented by grantee_key = 'GLOBAL' in fnd_grants
--        'GLOBAL','HZ_GLOBAL:'||TO_CHAR(grantee_party_id),
        'GLOBAL',grantee_type,
        TO_CHAR(grantee_party_id)) grantee_key,
         DECODE(transaction_type, 'CREATE', ORDER_BY_CREATE,
                              'UPDATE', ORDER_BY_UPDATE,
                              'SYNC',   ORDER_BY_SYNC,
                              'DELETE', ORDER_BY_DELETE,
            ORDER_BY_OTHERS)  trans_type
    FROM   ego_item_people_intf
    WHERE  data_set_id      = G_DATA_SET_ID
      AND  process_status   = G_PS_IN_PROCESS
      ORDER BY trans_type, transaction_id
  FOR UPDATE OF transaction_id;

  CURSOR c_get_delete_grantid
         (cp_inv_item_id            IN  NUMBER
         ,cp_organization_id        IN  NUMBER
         ,cp_menu_id                IN  NUMBER
         ,cp_object_id              IN  NUMBER
         ,cp_user_party_id_char     IN  VARCHAR2
         ,cp_group_party_id_char    IN  VARCHAR2
         ,cp_company_party_id_char  IN  VARCHAR2
         ,cp_global_party_id_char   IN  VARCHAR2
         ,cp_start_date             IN  DATE
         ,cp_end_date               IN  DATE
           ) IS
    SELECT  grant_guid
    FROM    fnd_grants grants
    WHERE   grants.object_id          = G_FND_OBJECT_ID
      AND   grants.menu_id            = cp_menu_id
      AND   grants.instance_type      = 'INSTANCE'
      AND   grants.instance_pk1_value = TO_CHAR(cp_inv_item_id)
      AND   grants.instance_pk2_value = TO_CHAR(cp_organization_id)
      AND   ((grants.grantee_type =  'USER'    AND grants.grantee_key =  cp_user_party_id_char ) OR
             (grants.grantee_type =  'GROUP'   AND grants.grantee_key =  cp_group_party_id_char) OR
             (grants.grantee_type =  'COMPANY' AND grants.grantee_key =  cp_company_party_id_char) OR
             (grants.grantee_type =  'GLOBAL'  AND grants.grantee_key =  cp_global_party_id_char)
      )
      AND   start_date = cp_start_date
      AND   ((end_date IS NULL AND cp_end_date is NULL)  OR (end_date = cp_end_date));

  -- 3578536
  CURSOR c_count_ipi_lines (cp_data_set_id  IN  NUMBER) IS
     SELECT COUNT(*)
     FROM   ego_item_people_intf
     WHERE  data_set_id    = cp_data_set_id
       AND  process_status = G_PS_IN_PROCESS;

  l_token_tbl_none        Error_Handler.Token_Tbl_Type;
  l_token_tbl_one         Error_Handler.Token_Tbl_Type;

  l_user_party_id_char     VARCHAR2(100);
  l_group_party_id_char    VARCHAR2(100);
  l_company_party_id_char  VARCHAR2(100);
  l_global_party_id_char   VARCHAR2(100);

  l_grant_guid             fnd_grants.grant_guid%TYPE;
  l_temp_grant_guid        fnd_grants.grant_guid%TYPE;
  l_grant_guid_count       NUMBER := 0;

  l_ipi_lines_count        NUMBER := 0;
  l_record_count           NUMBER := 0;
  l_return_status          NUMBER;
  l_success                VARCHAR2(999);

  l_program_name           VARCHAR2(99) := 'VALIDATE_NO_GRANT_OVERLAP';
  l_boolean_delete  boolean := TRUE;
  l_boolean_create  boolean := TRUE;
  l_boolean_update  boolean := TRUE;
  l_boolean_sync    boolean := TRUE;

  BEGIN

    OPEN c_count_ipi_lines(cp_data_set_id  => G_DATA_SET_ID);
    FETCH c_count_ipi_lines INTO l_ipi_lines_count;
    CLOSE c_count_ipi_lines;
    IF l_ipi_lines_count = 0 THEN
      RETURN;
    END IF;
    WHILE (l_ipi_lines_count > 0 ) LOOP
     FOR cr in c_get_ipi_records LOOP
      IF cr.grantee_type = 'USER' THEN
        l_user_party_id_char   := 'HZ_PARTY:'||TO_CHAR(cr.grantee_party_id);
        l_group_party_id_char  := NULL;
        l_company_party_id_char:= NULL;
        l_global_party_id_char := NULL;
      ELSIF cr.grantee_type = 'GROUP' THEN
        l_user_party_id_char   := NULL;
        l_group_party_id_char  := 'HZ_GROUP:'||TO_CHAR(cr.grantee_party_id);
        l_company_party_id_char:= NULL;
        l_global_party_id_char := NULL;
      ELSIF cr.grantee_type = 'COMPANY' THEN
        l_user_party_id_char   := NULL;
        l_group_party_id_char  := NULL;
        l_company_party_id_char:= 'HZ_COMPANY:'||TO_CHAR(cr.grantee_party_id);
        l_global_party_id_char := NULL;
      ELSIF cr.grantee_type = 'GLOBAL' THEN
        l_user_party_id_char   := NULL;
        l_group_party_id_char  := NULL;
        l_company_party_id_char:= NULL;
-- bug: 3460466
-- All Users is now represented by grantee_key = 'GLOBAL' in fnd_grants
--  l_global_party_id_char := 'HZ_GLOBAL:'||TO_CHAR(cr.grantee_party_id);
        l_global_party_id_char := cr.grantee_type;
      ELSE
        l_user_party_id_char   := NULL;
        l_group_party_id_char  := NULL;
        l_company_party_id_char:= NULL;
        l_global_party_id_char := NULL;
      END IF;
      IF cr.transaction_type = 'DELETE'  THEN
        ----------------------------
        --  delete records first  --
        ----------------------------
        OPEN c_get_delete_grantid
                (cp_inv_item_id            => cr.inventory_item_id
                ,cp_organization_id        => cr.organization_id
                ,cp_menu_id                => cr.internal_role_id
                ,cp_object_id              => G_FND_OBJECT_ID
                ,cp_user_party_id_char     => l_user_party_id_char
                ,cp_group_party_id_char    => l_group_party_id_char
                ,cp_company_party_id_char  => l_company_party_id_char
                ,cp_global_party_id_char   => l_global_party_id_char
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
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_SUCCESS
          WHERE CURRENT OF c_get_ipi_records;
        ELSE
          IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
            l_token_tbl_one(1).token_name  := 'ITEM';
            l_token_tbl_one(1).token_value := cr.item_number;
            error_handler.Add_Error_Message
              ( p_message_name   => 'EGO_IPI_GRANT_NOT_FOUND'
              , p_application_id => 'EGO'
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
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_ERROR
          WHERE CURRENT OF c_get_ipi_records;
        END IF;  -- c_get_delete_grantid
        CLOSE c_get_delete_grantid;

      ELSIF cr.transaction_type = 'UPDATE'  THEN
        ----------------------------
        --  check for update now  --
        ----------------------------
        validate_update_grant
           (p_transaction_type      => cr.transaction_type
           ,p_transaction_id        => cr.transaction_id
           ,p_inventory_item_id     => cr.inventory_item_id
           ,p_organization_id       => cr.organization_id
           ,p_internal_role_id      => cr.internal_role_id
           ,p_user_party_id_char    => l_user_party_id_char
           ,p_group_party_id_char   => l_group_party_id_char
           ,p_company_party_id_char => l_company_party_id_char
           ,p_global_party_id_char  => l_global_party_id_char
           ,p_start_date            => cr.start_date
           ,p_end_date              => cr.end_date
           ,x_return_status         => l_return_status
           );
        IF l_return_status = G_UPDATE_REC_DONE THEN
          -- record successfully updated
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_SUCCESS
          WHERE CURRENT OF c_get_ipi_records;
        ELSIF l_return_status = G_UPDATE_REC_NOT_FOUND THEN
          -- no record found for overlap
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_ERROR
          WHERE CURRENT OF c_get_ipi_records;
        ELSIF l_return_status = G_UPDATE_OVERLAP_ERROR THEN
          -- overlap will occur if update is done
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_ERROR
          WHERE CURRENT OF c_get_ipi_records;
        END IF;

      ELSIF cr.transaction_type = 'SYNC'  THEN
        ------------------------------------
        --  check for SYNC opetaion       --
        --  (first UPDATE and then INSERT --
        ------------------------------------
        validate_update_grant
           (p_transaction_type      => cr.transaction_type
           ,p_transaction_id        => cr.transaction_id
           ,p_inventory_item_id     => cr.inventory_item_id
           ,p_organization_id       => cr.organization_id
           ,p_internal_role_id      => cr.internal_role_id
           ,p_user_party_id_char    => l_user_party_id_char
           ,p_group_party_id_char   => l_group_party_id_char
           ,p_company_party_id_char => l_company_party_id_char
           ,p_global_party_id_char  => l_global_party_id_char
           ,p_start_date            => cr.start_date
           ,p_end_date              => cr.end_date
           ,x_return_status         => l_return_status
           );
        IF l_return_status = G_UPDATE_REC_DONE THEN
          -- record successfully updated
          -- 4669015 setting successful status to 'UPDATE'/'CREATE'
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_SUCCESS,
                 transaction_type = 'UPDATE'
          WHERE CURRENT OF c_get_ipi_records;
        ELSIF l_return_status = G_UPDATE_OVERLAP_ERROR THEN
          -- overlap will occur if update is done
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_ERROR
          WHERE CURRENT OF c_get_ipi_records;
        ELSIF l_return_status = G_UPDATE_REC_NOT_FOUND THEN
          -- no record found for overlap
          -- now insert the record.
          validate_insert_grant
             (p_transaction_type      => cr.transaction_type
             ,p_transaction_id        => cr.transaction_id
             ,p_inventory_item_id     => cr.inventory_item_id
             ,p_organization_id       => cr.organization_id
             ,p_internal_role_id      => cr.internal_role_id
             ,p_internal_role_name    => cr.internal_role_name
             ,p_grantee_type          => cr.grantee_type
             ,p_grantee_key           => cr.grantee_key
             ,p_user_party_id_char    => l_user_party_id_char
             ,p_group_party_id_char   => l_group_party_id_char
             ,p_company_party_id_char => l_company_party_id_char
             ,p_global_party_id_char  => l_global_party_id_char
             ,p_start_date            => cr.start_date
             ,p_end_date              => cr.end_date
             ,x_return_status         => l_return_status
             );
          IF l_return_status = G_INSERT_REC_DONE THEN
            -- record successfully inserted
            -- 4669015 setting successful status to 'UPDATE'/'CREATE'
            UPDATE ego_item_people_intf
            SET    process_status = G_PS_SUCCESS,
                   transaction_type =  'CREATE'
            WHERE CURRENT OF c_get_ipi_records;
          ELSIF l_return_status = G_INSERT_OVERLAP_ERROR THEN
            -- insert overlap error
            UPDATE ego_item_people_intf
            SET    process_status = G_PS_ERROR
            WHERE CURRENT OF c_get_ipi_records;
          END IF;
        END IF;

      ELSIF cr.transaction_type = 'CREATE'  THEN
        ----------------------------
        --  check for create now  --
        ----------------------------
        validate_insert_grant
             (p_transaction_type      => cr.transaction_type
             ,p_transaction_id        => cr.transaction_id
             ,p_inventory_item_id     => cr.inventory_item_id
             ,p_organization_id       => cr.organization_id
             ,p_internal_role_id      => cr.internal_role_id
             ,p_internal_role_name    => cr.internal_role_name
             ,p_grantee_type          => cr.grantee_type
             ,p_grantee_key           => cr.grantee_key
             ,p_user_party_id_char    => l_user_party_id_char
             ,p_group_party_id_char   => l_group_party_id_char
             ,p_company_party_id_char => l_company_party_id_char
             ,p_global_party_id_char  => l_global_party_id_char
             ,p_start_date            => cr.start_date
             ,p_end_date              => cr.end_date
             ,x_return_status         => l_return_status
             );
        IF l_return_status = G_INSERT_REC_DONE THEN
          -- record successfully inserted
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_SUCCESS
          WHERE CURRENT OF c_get_ipi_records;
        ELSIF l_return_status = G_INSERT_OVERLAP_ERROR THEN
          -- insert overlap error
          UPDATE ego_item_people_intf
          SET    process_status = G_PS_ERROR
          WHERE CURRENT OF c_get_ipi_records;
        END IF;

      END IF;  -- cr.transaction_type
      check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                         ,x_retcode  => x_retcode);
      IF (x_retcode = RETCODE_ERROR) THEN
        RETURN;
      END IF;
      l_ipi_lines_count := l_ipi_lines_count - 1;
      l_record_count := l_record_count + 1;
      IF (l_record_count = G_BATCH_SIZE OR l_ipi_lines_count = 0) THEN
        l_record_count := 0;
        EXIT;
-- 3578536
--  COMMIT;
      END IF;
     END LOOP; -- c_get_ipi_records
     --
     -- committing the data as one loop is completed
     --
     COMMIT;
    END LOOP; -- l_batch_loop_counter
  EXCEPTION
    WHEN OTHERS THEN
      Write_Debug(' EXCEPTION in validate_No_Grant_Overlap ');
      IF c_get_ipi_records%ISOPEN THEN
        CLOSE c_get_ipi_records;
      END IF;
      IF c_count_ipi_lines%ISOPEN THEN
        CLOSE c_count_ipi_lines;
      END IF;
      IF c_get_delete_grantid%ISOPEN THEN
        CLOSE c_get_delete_grantid;
      END IF;
      RAISE;

  END Validate_No_Grant_Overlap;

 ----------------------------------------------------------
 -- To open the Debug Session for writing Debug Log      --
 ----------------------------------------------------------
PROCEDURE open_debug_session IS

  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
      WHERE NAME = 'utl_file_dir';

  --local variables
--EMTAPIA: modified length of varchar l_log_output_dir from 200 to 200 for bug: 7041983
  --l_log_output_dir       VARCHAR2(200);
  l_log_output_dir       VARCHAR2(2000);
  l_log_return_status    VARCHAR2(99);
  l_errbuff              VARCHAR2(999);
BEGIN

  OPEN c_get_utl_file_dir;
  FETCH c_get_utl_file_dir INTO l_log_output_dir;
  --Conc_Log('UTL_FILE_DIR : '||l_log_output_dir);
  IF c_get_utl_file_dir%FOUND THEN
    ------------------------------------------------------
    -- Trim to get only the first directory in the list --
    ------------------------------------------------------
    IF INSTR(l_log_output_dir,',') <> 0 THEN
      l_log_output_dir := SUBSTR(l_log_output_dir, 1, INSTR(l_log_output_dir, ',') - 1);
      --Conc_Log('Log Output Dir : '||l_log_output_dir);
    END IF;


    G_ERROR_FILE_NAME := G_ERROR_TABLE_NAME||'_'||to_char(sysdate, 'DDMONYYYY_HH24MISS')||'.err';
    --Conc_Log('Trying to open the Error File => '||G_ERROR_FILE_NAME);

    Error_Handler.Open_Debug_Session(
      p_debug_filename   => G_ERROR_FILE_NAME
     ,p_output_dir       => l_log_output_dir
     ,x_return_status    => l_log_return_status
     ,x_error_mesg       => l_errbuff
     );

    Conc_Log(' Log file location --> '||l_log_output_dir||'/'||G_ERROR_FILE_NAME ||' created with status '|| l_log_return_status);

    IF (l_log_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       Conc_Log('Unable to open error log file. Error => '||l_errbuff);
    END IF;

  END IF;--IF c_get_utl_file_dir%FOUND THEN

END open_debug_session;


---------------------------------------------
--  PUBLIC  PROCEDURES AND FUNCTIONS       --
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
      SELECT EGO_IPI_DATASET_ID_S.NEXTVAL
      INTO   G_CURR_DATASET_ID
      FROM   DUAL;
    END IF;
    RETURN G_CURR_DATASET_ID;
  EXCEPTION
    WHEN OTHERS THEN
      Write_Debug(' EXCEPTION in get_curr_dataset_id ');
      G_CURR_DATASET_ID := -2;
      RAISE;
  END get_curr_dataset_id;

  -------------------------------------------------------------------------------
  -- Main procedure called by the Item People Import Concurrent Program
  -------------------------------------------------------------------------------
  PROCEDURE load_interface_lines
    (
     x_errbuff            OUT NOCOPY VARCHAR2,
     x_retcode            OUT NOCOPY VARCHAR2,
     p_data_set_id        IN  NUMBER,
     p_bulk_batch_size    IN  NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.RECOMMENDED_BATCH_SIZE,
     p_delete_lines       IN  NUMBER   DEFAULT EGO_ITEM_PUB.G_INTF_DELETE_NONE,
     p_debug_mode         IN  NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.DEBUG_MODE_ERROR,
     p_log_mode           IN  NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.LOG_INTO_TABLE_ONLY
      ) IS

    -- Start OF comments
    -- API name  : Load Interfance Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load interfance lines into FND_GRANTS.
    --             Errors are populated in MTL_INTERFACE_ERRORS

  -- ======================================================================
  -- the record types used from other procedures
  -- noted down here for quick reference
  --  Error record type
  -- ======================================================================
  --  TYPE Error_Rec_Type IS RECORD
  --    (organization_id   NUMBER
  --    ,entity_id         VARCHAR2(3)
  --    ,message_text      VARCHAR2(2000)
  --    ,entity_index      NUMBER
  --    ,message_type      VARCHAR2(1)
  --    ,row_identifier    VARCHAR2(80)
  --    ,bo_identifier     VARCHAR2(3)     := 'ECO'
  --    );
  --
  --  TYPE Error_Tbl_Type IS TABLE OF Error_Rec_Type  INDEX BY BINARY_INTEGER;
  --
  --  TYPE Mesg_Token_Rec_Type IS RECORD
  --    (message_name      VARCHAR2(30)    := NULL
  --    ,application_id    VARCHAR2(3)     := NULL
  --    ,message_text      VARCHAR2(2000)  := NULL
  --    ,token_name        VARCHAR2(30)    := NULL
  --    ,token_value       VARCHAR2(100)   := NULL
  --    ,translate         BOOLEAN         := FALSE
  --    ,message_type      VARCHAR2(1)     := NULL
  --    );
  --
  --  TYPE Mesg_Token_Tbl_Type IS TABLE OF Mesg_Token_Rec_Type INDEX BY BINARY_INTEGER;
  --
  --  TYPE Token_Rec_Type IS RECORD
  --    (token_value       VARCHAR2(100)   := NULL
  --    ,token_name        VARCHAR2(30)    := NULL
  --    ,translate         BOOLEAN         := FALSE
  --  );
  --
  --  TYPE Token_Tbl_Type IS TABLE OF Token_Rec_Type INDEX BY BINARY_INTEGER;
  -- ======================================================================
  -- 5375467 modified query to validate user against ego_people_v
  CURSOR c_user_party_id (cp_user_id IN NUMBER) IS
     SELECT person_id, person_name
     FROM   ego_people_v
     WHERE  user_id      = cp_user_id;

  CURSOR c_count_ipi_lines (cp_data_set_id  IN  NUMBER) IS
     SELECT COUNT(*)
     FROM   ego_item_people_intf
     WHERE  data_set_id    = cp_data_set_id
       AND  process_status = G_PS_TO_BE_PROCESSED;

  CURSOR c_get_trans_id_limits (cp_data_set_id  IN  NUMBER) IS
     SELECT MIN(transaction_id), MAX(transaction_id)
     FROM   ego_item_people_intf
     WHERE  data_set_id    = cp_data_set_id
       AND  process_status = G_PS_IN_PROCESS;

  CURSOR c_err_mand_params IS
     SELECT transaction_id
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  (  (inventory_item_id IS NULL AND item_number IS NULL)
                OR
                (organization_id IS NULL AND organization_code IS NULL)
                OR
                (internal_role_id IS NULL AND internal_role_name IS NULL AND display_role_name IS NULL)
                OR
                (grantee_type IS NULL)
            )
     FOR UPDATE OF transaction_id;

  CURSOR c_err_dates IS
     SELECT transaction_id
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  start_date > NVL(end_date,(start_date + 1))
     FOR UPDATE OF transaction_id;

  --
  -- Select records to flag missing or invalid Transaction_Types
  --
  CURSOR c_err_transaction_type  IS
     SELECT transaction_id, transaction_type
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  transaction_type NOT IN ('CREATE', 'UPDATE', 'DELETE', 'SYNC')
     FOR UPDATE OF transaction_id;

  --
  -- Select records with missing/invalid grantee type
  --
  CURSOR c_err_grantee_type  IS
     SELECT transaction_id, grantee_type
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  (grantee_type IS NULL OR grantee_type NOT IN ('USER', 'GROUP', 'COMPANY', 'GLOBAL'))
      FOR UPDATE OF transaction_id;

  --
  -- Select records to flag missing or invalid grantee_party_id
  --
  CURSOR c_err_grantee_id  IS
     SELECT transaction_id, grantee_party_id, grantee_name, grantee_type
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  grantee_party_id IS NULL
      FOR UPDATE OF transaction_id;

  --
  -- Select records to flag missing or invalid role_id
  --
  CURSOR c_err_role_id IS
     SELECT transaction_id, internal_role_id, display_role_name, internal_role_name
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_IN_PROCESS
       AND  request_id       = G_REQUEST_ID
       AND  internal_role_id IS NULL
     FOR UPDATE OF transaction_id;

  --
  -- Select records to flag missing or invalid organization_id
  --

-- bug 4628705
--  CURSOR c_err_org_id  IS
--     SELECT transaction_id, organization_id, organization_code
--     FROM   ego_item_people_intf
--     WHERE  data_set_id = G_DATA_SET_ID
--       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
--       AND  process_status = G_PS_IN_PROCESS
--       AND  organization_id  IS NULL
--      FOR UPDATE OF transaction_id;

-- bug 3710151
--  --
--  -- Select records for valid item numbers
--  --
--  CURSOR c_get_item_number IS
--     SELECT transaction_id, inventory_item_id, item_number, organization_id, organization_code
--     FROM   ego_item_people_intf
--     WHERE  data_set_id = G_DATA_SET_ID
--       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
--       AND  process_status = G_PS_IN_PROCESS
--       AND  organization_id IS NOT NULL
--      FOR UPDATE OF transaction_id;
--
--  --
--  -- Check whether the user can revoke/give grants
--  --
--  CURSOR c_get_grant_privileges (cp_inventory_item_id  IN  NUMBER
--                                ,cp_organization_id    IN  NUMBER) IS
--     SELECT inventory_item_id
--     FROM   EGO_LOGIN_ITEMS_TEMP
--     WHERE  inventory_item_id = cp_inventory_item_id
--       AND  organization_id   = cp_organization_id
--       AND  conc_request_id   = G_REQUEST_ID;
  --
  -- Select records to flag missing or invalid item number
  --

-- bug 4628705
--  CURSOR c_err_item_id  IS
--     SELECT transaction_id, item_number, inventory_item_id, organization_code
--     FROM   ego_item_people_intf
--     WHERE  data_set_id = G_DATA_SET_ID
--       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
--       AND  process_status = G_INT_ITEM_VAL_ERROR
--       AND  process_status = G_PS_IN_PROCESS
--       AND  inventory_item_id  IS NULL
--      FOR UPDATE OF transaction_id;

-- bug 4628705
  CURSOR c_err_records  IS
     SELECT transaction_id, item_number, inventory_item_id,
            organization_code, organization_id
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  request_id  = G_REQUEST_ID
       AND  process_status IN (G_INT_ORG_VAL_ERROR, G_INT_ITEM_VAL_ERROR);

  --
  -- Select records to flag where user does not have privilege
  --
  CURSOR c_err_access_items  IS
     SELECT transaction_id, item_number, organization_code
     FROM   ego_item_people_intf
     WHERE  data_set_id = G_DATA_SET_ID
       AND  transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
       AND  process_status   = G_PS_ERROR
       AND  request_id       = G_REQUEST_ID
       AND  inventory_item_id  IS NOT NULL
      FOR UPDATE OF transaction_id;
-- bug 3710151 ends

  --
  -- Select the directory where the error log file needs to be saved
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
  l_ipi_lines_count      NUMBER;
  l_loop_count           NUMBER;
  l_transaction_id_min   NUMBER;
  l_transaction_id_max   NUMBER;

  l_column_name          VARCHAR2(99);
  l_transaction_id       ego_item_people_intf.transaction_id%TYPE;
  l_msg_name             VARCHAR2(99);
  l_msg_text             VARCHAR2(999) := NULL;
  l_msg_type             VARCHAR2(10)  := 'E';
  l_sysdate              DATE;

  l_inventory_item_id    NUMBER;

  l_log_output_dir       VARCHAR2(200);
  l_log_return_status    VARCHAR2(99);
  l_log_mesg_token_tbl   ERROR_HANDLER.Mesg_Token_Tbl_Type;

  l_program_name         VARCHAR2(30)  := 'LOAD_INTERFACE_LINES';
  l_err_msg_sql          VARCHAR2(4000);
  --
  l_return_status        VARCHAR2(10);
  l_msg_count            NUMBER ;
  l_msg_data             fnd_new_messages.message_text%TYPE;

  BEGIN
    G_HAS_ERRORS := FALSE;
    x_retcode := RETCODE_SUCCESS;
    IF (NVL(fnd_profile.value('CONC_REQUEST_ID'), 0) <> 0) THEN
      g_concReq_valid_flag  := TRUE;
    END IF;

    IF p_debug_mode = DEBUG_MODE_DEBUG THEN
      G_DEBUG_MODE := DEBUG_MODE_DEBUG;
    ELSE
      ------------------------------------------------------------
      -- Not yet classified, for the INFO level etc., conditions.
      ------------------------------------------------------------
      G_DEBUG_MODE := DEBUG_MODE_ERROR;
    END IF; -- IF p_debug_mode

    ERROR_HANDLER.initialize();
    ERROR_HANDLER.set_bo_identifier(G_BO_IDENTIFIER);

    --Opens Error_Handler debug session, only if Debug session is not already open.
    IF (Error_Handler.Get_Debug <> 'Y') THEN
      Open_Debug_Session;
    END IF;

    Write_Debug('Start of the Process');
    Write_Debug('Data_set_id ' || to_char(p_data_set_id));
    Write_Debug('Bulk batch size  '|| to_char(p_bulk_batch_size));
    Write_Debug('Delete Lines '||  to_char (p_delete_lines));
    Write_Debug('Log Mode ' || to_char (p_log_mode));

    IF p_log_mode = LOG_INTO_TABLE_AND_FILE THEN
      G_TABLE_LOG := TRUE;
    ELSIF p_log_mode = LOG_INTO_TABLE_ONLY THEN
      G_TABLE_LOG := TRUE;
    ELSIF p_log_mode = LOG_INTO_FILE_ONLY THEN
      G_TABLE_LOG := FALSE;
    ELSE
      G_TABLE_LOG := FALSE;
    END IF;

    Write_Debug('Debug Mode => '||G_DEBUG_MODE);

    -------------------------------------------------------------------------
    -- the values are chosen from the FND_GLOBALS
    -------------------------------------------------------------------------
    G_USER_ID    := FND_GLOBAL.user_id         ;
    G_LOGIN_ID   := FND_GLOBAL.login_id        ;
    G_PROG_APPID := FND_GLOBAL.prog_appl_id    ;
    G_PROG_ID    := FND_GLOBAL.conc_program_id ;
-- bug 3710151
    G_REQUEST_ID := NVL(FND_GLOBAL.conc_request_id, -1) ;

    Write_Debug('FND_GLOBAL.user_id : '||FND_GLOBAL.user_id);
    Write_Debug('FND_GLOBAL.conc_request_id : '||G_REQUEST_ID);

    G_DATA_SET_ID := p_data_set_id;
    -------------------------------------------------------------------------
    -- check whether the logged in user is a valid user
    -------------------------------------------------------------------------
    OPEN c_user_party_id(cp_user_id => G_USER_ID);
    FETCH c_user_party_id INTO l_login_party_id, l_login_party_name;
    Write_Debug('Login Party Id : '||l_login_party_id||' AND '||'Login Party Name : '||l_login_party_name);
    CLOSE c_user_party_id;

    Write_Debug('Counting total lines for curr data_set_id');
    OPEN c_count_ipi_lines(cp_data_set_id  => G_DATA_SET_ID);
    FETCH c_count_ipi_lines INTO l_ipi_lines_count;
    CLOSE c_count_ipi_lines;
    IF l_ipi_lines_count = 0 THEN
      IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
      error_handler.Add_Error_Message
        ( p_message_name   => 'EGO_IPI_NO_LINES'
        , p_application_id => 'EGO'
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
      x_retcode := RETCODE_SUCCESS;
      fnd_message.set_name('EGO', 'EGO_IPI_NO_LINES');
      l_msg_data := fnd_message.get();
      Write_Debug (l_msg_data);
--      conc_output (x_errbuff);
      RETURN;
    END IF;

    Write_Debug('Initalizing table Ego_Login_Items_Temp');
    initialize_access_items (p_login_person_id  => l_login_party_id
                            ,x_retcode          => x_retcode);
    IF x_retcode = RETCODE_ERROR THEN
      Write_Debug('Error Initalizing Ego_Login_Items_Temp');
      fnd_message.set_name('EGO', 'EGO_IPI_ERR_INIT_ITEMS');
      x_errbuff := fnd_message.get();
--      conc_output (x_errbuff);
      purge_login_items_table();
      RETURN;
    END IF;
    Write_Debug('Successfully Initalized Ego_Login_Items_Temp');

    Write_Debug('Initalizing FND Object Id');
    initialize_fnd_object_id(p_object_name  => G_FND_OBJECT_NAME);
    Write_Debug('Initalizing All Users global var : G_ALL_USERS_PARTY_ID');
    initialize_all_users();

    -----------------------------------------------------------------------
    -- setting up the records for processing
    -----------------------------------------------------------------------
    Write_Debug('Setting the Start Date to SysDate if NULL.');
    l_sysdate := SYSDATE;
    UPDATE ego_item_people_intf
       SET creation_date     = NVL(creation_date,l_sysdate),
           last_update_date  = l_sysdate,
           last_updated_by   = G_USER_ID,
           last_update_login = G_LOGIN_ID,
           request_id        = G_REQUEST_ID,
           program_application_id = G_PROG_APPID,
           program_id             = G_PROG_ID,
           program_update_date    = l_sysdate,
           start_date        = NVL(start_date, l_sysdate),
           transaction_type  = UPPER(transaction_type),
           grantee_type      = UPPER(grantee_type),
           process_status    = G_PS_IN_PROCESS,
           transaction_id    = NVL(transaction_id, EGO_IPI_TRANSACTION_ID_S.NEXTVAL)
     WHERE data_set_id    = G_DATA_SET_ID
       AND process_status = G_PS_TO_BE_PROCESSED;

    -------------------------------------------
    -- All required values are initialized
    -- Go ahead with validating the records
    -------------------------------------------

    Write_Debug('Getting Min and Max Transaction Ids');

    -------------------------------------------------------------------------
    -- initialize the loop counter values
    -------------------------------------------------------------------------
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
    Write_Debug ('Processing lines from Intf table according to batch size for '||l_loop_count||' times');
    FOR l_batch_loop_counter IN 1..l_loop_count LOOP
      Write_Debug (' Loop execution  '|| to_char (l_batch_loop_counter) || ' of ' || to_char(l_loop_count));
      IF (l_transaction_id_max > (G_FROM_LINE_NUMBER + G_BATCH_SIZE -1)) THEN
        G_TO_LINE_NUMBER := G_FROM_LINE_NUMBER + G_BATCH_SIZE - 1;
      ELSE
        G_TO_LINE_NUMBER := l_transaction_id_max;
      END IF;
      Write_Debug (' Loop execution  from '|| G_FROM_LINE_NUMBER || ' to ' || G_TO_LINE_NUMBER);
      -------------------------------------------------------------------------
      -- call various validation routines
      -- the sequence of the calling valiadations does matter
      -- as the first error is reported and the record is flagged as error
      -------------------------------------------------------------------------

      Write_Debug('Checking for Invalid records and flagging Error');
      -------------------------------------------------------------------------
      -- check for mandatory data to be present before flagging error
      -------------------------------------------------------------------------
      FOR cr IN c_err_mand_params LOOP
        UPDATE  ego_item_people_intf
          SET   process_status   = G_PS_ERROR
          WHERE CURRENT OF c_err_mand_params;
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          l_msg_name := 'EGO_INTF_MAND_PARAM_MISSING';
          error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
              , p_message_text   => NULL
              , p_token_tbl      => l_token_tbl_none
              , p_message_type   => 'E'
              , p_row_identifier => cr.transaction_id
              , p_table_name     => G_ERROR_TABLE_NAME
              , p_entity_id      => NULL
              , p_entity_index   => NULL
              , p_entity_code    => G_ERROR_ENTITY_CODE
              );
        END IF;
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error mandatory data in record

      Write_Debug('Checking for StartDate > EndDate and flagging Error');
      -------------------------------------------------------------------------
      -- check the correct start and end dates in the records
      -------------------------------------------------------------------------
      FOR cr IN c_err_dates LOOP
        UPDATE  ego_item_people_intf
          SET   process_status   = G_PS_ERROR
          WHERE CURRENT OF c_err_dates;
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          l_msg_name := 'EGO_IPI_INVALID_DATES';
          error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
              , p_message_text   => NULL
              , p_token_tbl      => l_token_tbl_none
              , p_message_type   => 'E'
              , p_row_identifier => cr.transaction_id
              , p_table_name     => G_ERROR_TABLE_NAME
              , p_entity_id      => NULL
              , p_entity_index   => NULL
              , p_entity_code    => G_ERROR_ENTITY_CODE
              );
        END IF;
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Dates

      Write_Debug('Erroring out Invalid Transaction Type records');
      -------------------------------------------------------------------------
      -- find the error records with invalid transaction_type
      -- valid transaction_types are CREATE, UPDATE, SYNC, DELETE
      -------------------------------------------------------------------------
      FOR cr IN c_err_transaction_type LOOP
        UPDATE  ego_item_people_intf
          SET   process_status   = G_PS_ERROR
          WHERE CURRENT OF c_err_transaction_type;
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          IF ( cr.transaction_type IS NULL ) THEN
            l_msg_name := 'EGO_IPI_MISSING_VALUE';
            l_token_tbl_one(1).token_name  := 'VALUE';
            l_token_tbl_one(1).token_value := 'TRANSACTION TYPE';

            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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

            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'TRANSACTION TYPE';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.transaction_type;
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Transaction Types

      --error_count_records();
      Write_Debug('Erroring out Invalid Grantee Type / Grantee Name records');

      -------------------------------------------------------------------------
      -- validation for grantee_type and grantee_name combination
      -------------------------------------------------------------------------
      FOR cr IN c_err_grantee_type LOOP
        UPDATE  ego_item_people_intf
          SET   process_status   = G_PS_ERROR
          WHERE CURRENT OF c_err_grantee_type;
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          IF ( cr.grantee_type IS NULL ) THEN

            Write_Debug (to_char(cr.transaction_id)||' Missing Grantee Type');
            l_msg_name := 'EGO_IPI_MISSING_VALUE';
            l_token_tbl_one(1).token_name  := 'VALUE';
            l_token_tbl_one(1).token_value := 'GRANTEE TYPE';
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
            -- cr.grantee_type NOT IN ('USER','GROUP','COMPANY')
            Write_Debug (to_char(cr.transaction_id)||' Invalid Grantee Type');
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'GRANTEE TYPE';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.grantee_type;
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- error Grantee Types

      --error_count_records();
      Write_Debug ('Grantee Type Completed ');

      ----------------------------------------------------------------------------
      -- Fix for bug# 3433718. Allowing to pass case-insensitive Username.      --
      -- Fnd_User.User_Name is unique, irrespective of the case.                --
      ----------------------------------------------------------------------------
      Write_Debug('Updating the grantee_party_id in Intf table for People');

      -------------------------------------------------------------------------
      -- Update the grantee_party id column for the people
      -------------------------------------------------------------------------
       UPDATE ego_item_people_intf  eipi
          SET (eipi.grantee_party_id) =
            ( SELECT  person_id
                FROM  ego_people_v
               WHERE  UPPER(user_name) = UPPER(eipi.grantee_name)
            )
        WHERE  eipi.data_set_id = G_DATA_SET_ID
          AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
          AND  eipi.process_status = G_PS_IN_PROCESS
          AND  eipi.grantee_party_id IS NULL
          AND  eipi.grantee_type IS NOT NULL
          AND  eipi.grantee_type = 'USER';

      Write_Debug('Updating the grantee_party_id in Intf table for Groups');

      -------------------------------------------------------------------------
      --Update the grantee_party id column for the groups
      -------------------------------------------------------------------------
      UPDATE ego_item_people_intf  eipi
         SET eipi.grantee_party_id =
                 ( SELECT  group_id
                     FROM  ego_groups_v
                    WHERE  group_name = eipi.grantee_name
                 )
       WHERE  eipi.data_set_id = G_DATA_SET_ID
         AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
         AND  eipi.process_status = G_PS_IN_PROCESS
         AND  eipi.grantee_party_id IS NULL
         AND  eipi.grantee_type IS NOT NULL
         AND  eipi.grantee_type = 'GROUP';

      Write_Debug('Updating the grantee_party_id in Intf table for Compnys');

      -------------------------------------------------------------------------
      --Update the grantee_party id column for the Companies
      --Company can be Enterprise / External Customer / External Supplier
      -------------------------------------------------------------------------
      UPDATE ego_item_people_intf  eipi
         SET eipi.grantee_party_id =
           ( SELECT  company_id
               FROM  ego_companies_v
              WHERE  company_name = eipi.grantee_name
           )
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.grantee_party_id IS NULL
        AND  eipi.grantee_type IS NOT NULL
        AND  eipi.grantee_type = 'COMPANY';

      Write_Debug('Updating the grantee_party_id in Intf table for AllUsrs');

      -------------------------------------------------------------------------
      --Update the grantee_party id column for the All Users
      -------------------------------------------------------------------------
      UPDATE ego_item_people_intf  eipi
         SET eipi.grantee_party_id = G_ALL_USERS_PARTY_ID
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.grantee_party_id IS NULL
        AND  eipi.grantee_type IS NOT NULL
        AND  eipi.grantee_type = 'GLOBAL';

      Write_Debug('Erroring out NULL Grantee_party_id records');

      -------------------------------------------------------------------------
      -- For missing grantee_party_id, update process_status and log an error.
      -- Also, assign transaction_id, request_id
      -------------------------------------------------------------------------
      FOR cr IN c_err_grantee_id LOOP
        UPDATE ego_item_people_intf
           SET process_status   = G_PS_ERROR
         WHERE CURRENT OF c_err_grantee_id;
      -------------------------------------------------------------------------
        -- Grantee Name check
      -------------------------------------------------------------------------
        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          IF ( cr.grantee_name IS NULL ) THEN
                  Write_Debug (to_char(cr.transaction_id) || ' Missing Grantee Name ');
            l_msg_name := 'EGO_IPI_MISSING_VALUE';
            l_token_tbl_one(1).token_name  := 'VALUE';
            l_token_tbl_one(1).token_value := 'GRANTEE NAME';
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
                  Write_Debug (to_char(cr.transaction_id) || ' Invalid Grantee Name ');
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'GRANTEE NAME';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.grantee_name;
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_grantee_id

      --error_count_records();
      Write_Debug (' Grantee Name Completed ');

      -------------------------------------------------------------------------
      -- Retrieval of Role Ids is done in 2 steps :
      --1) Retrieve and store the Display and Internal Role Names and Role Ids
      --   and store in a temp table.  This is done by initialise_roles()
      --2) Verify the roles from the temporary table.
      -------------------------------------------------------------------------

      Write_Debug('Updating the Role Id, Role Name columns in Intf table');
      -------------------------------------------------------------------------
      -- Fix for Bug# 3050477.
      -- Reference to EGO_OBJECT_ROLES is removed.
      -- bug 4930322 modified the query to avoid full table scans
      -------------------------------------------------------------------------
      UPDATE ego_item_people_intf  eipi
          SET (eipi.internal_role_id, eipi.internal_role_name ) =
            ( SELECT roles.menu_id internal_role_id,
                     roles.menu_name internal_role_name
              FROM   (
                       SELECT DISTINCT e.menu_id role_id
                       FROM   fnd_form_functions f, fnd_menu_entries e
                       WHERE  e.function_id = f.function_id
                         AND  f.object_id = G_FND_OBJECT_ID
                     ) obj_roles,
               fnd_menus roles,
               fnd_menus_tl roles_tl
        WHERE obj_roles.role_id = roles.menu_id
          AND obj_roles.role_id = roles_tl.menu_id
          AND roles_tl.language = G_SESSION_LANG
          AND roles_tl.user_menu_name = eipi.display_role_name
        )
      WHERE   eipi.data_set_id = G_DATA_SET_ID
         AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
         AND  eipi.process_status = G_PS_IN_PROCESS
         AND  eipi.internal_role_id IS NULL
         AND  eipi.display_role_name IS NOT NULL;

      Write_Debug('Erroring out NULL Role Id records');

      -------------------------------------------------------------------------
      -- For missing roles, update process_status and log an error.
      -------------------------------------------------------------------------
      FOR cr IN c_err_role_id LOOP
        UPDATE ego_item_people_intf
        SET    process_status   = G_PS_ERROR
        WHERE  CURRENT OF c_err_role_id;

        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
                IF ( cr.display_role_name IS NULL ) THEN
            l_msg_name := 'EGO_IPI_MISSING_VALUE';
            l_token_tbl_one(1).token_name  := 'VALUE';
            l_token_tbl_one(1).token_value := 'DISPLAY ROLE NAME';
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'DISPLAY ROLE NAME';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.display_role_name;
            error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
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
        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                           ,x_retcode  => x_retcode);
        IF x_retcode = RETCODE_ERROR THEN
          RETURN;
        END IF;
      END LOOP;  -- c_err_role_id

      --error_count_records();
      Write_Debug (' Roles Completed ');


      Write_Debug('Updating the Organization Id column in Intf table');
      --Update the organization id column

      UPDATE ego_item_people_intf  eipi
      SET    eipi.process_status = G_INT_ORG_VAL_ERROR
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND ( (organization_id IS NOT NULL
               AND
               NOT EXISTS
                   ( SELECT  mp.organization_id
                     FROM    mtl_parameters  mp
                     WHERE   mp.organization_id = eipi.organization_id
                   )
              )
              OR
              (organization_id IS NULL
               AND
               NOT EXISTS
                   ( SELECT  mp.organization_id
                     FROM    mtl_parameters  mp
                     WHERE   mp.organization_code = eipi.organization_code
                   )
              )
            );

      UPDATE ego_item_people_intf  eipi
      SET    organization_code =
                   ( SELECT  mp.organization_code
                     FROM    mtl_parameters  mp
                     WHERE   mp.organization_id = eipi.organization_id
                   )
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.organization_id IS NOT NULL;

      UPDATE ego_item_people_intf  eipi
      SET    organization_id =
                   ( SELECT  mp.organization_id
                     FROM    mtl_parameters  mp
                     WHERE   mp.organization_code = eipi.organization_code
                   )
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.organization_id IS NULL;

      Write_Debug (' Organization Id Completed ');

      -------------------------------------------------------------------
      --
      -- Organization id is obtained, Please check the item_id now
      --
      -------------------------------------------------------------------

      Write_Debug('Updating the Inv Item Id column in Intf table');
       --Retrieve the Item Id from Item Num and Organization Id.
      l_column_name := 'ITEM_NUMBER';
-- bug 3710151
--
--      FOR cr IN c_get_item_number LOOP
--
--      Write_Debug(' calling validate with params  item number ' || cr.item_number || ' org id ' || to_char(cr.organization_id) );
--
--        -------------------------------------------------------------------
--        -- Retrieval of Item id is through FLEX APIs.
--        -------------------------------------------------------------------
--  IF FND_FLEX_KEYVAL.Validate_Segs
--        (  operation         =>  'FIND_COMBINATION'
--        ,  appl_short_name   =>  'INV'
--        ,  key_flex_code     =>  'MSTK'
--        ,  structure_number  =>  101
--        ,  concat_segments   =>  cr.item_number
--        ,  data_set          =>  cr.organization_id
--        )
--  THEN
--    l_inventory_item_id := FND_FLEX_KEYVAL.combination_id;
--          UPDATE ego_item_people_intf
--      SET  inventory_item_id = l_inventory_item_id
--      WHERE CURRENT OF c_get_item_number;
--
--          --------------------------------------------------------------------
--    -- check whether the logged in user can give access to the items
--          --------------------------------------------------------------------
--      IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
--
--             --------------------------------------------------------------------
--       --If the person has Full access to items, there is no need
--       --to check for Grant privileges.
--             --------------------------------------------------------------------
--      IF (G_FULL_ACCESS_ITEMS = TRUE) THEN
--               Write_Debug('No need to check for Grant Privileges');
--               NULL; --Do nothing
--      ELSE
--
--               Write_Debug('Check for Grant Privileges on items in Intf');
--         OPEN c_get_grant_privileges (
--           cp_inventory_item_id => l_inventory_item_id,
--           cp_organization_id   => cr.organization_id
--              );
--        FETCH c_get_grant_privileges INTO l_inventory_item_id;
--        IF c_get_grant_privileges%NOTFOUND THEN
--    -- the user cannot grant privileges on this item
--    UPDATE ego_item_people_intf
--      SET  process_status = G_PS_ERROR
--      WHERE CURRENT OF c_get_item_number;
--    l_msg_name := 'EGO_IPI_CANNOT_GRANT';
--    l_token_tbl_three(1).token_name  := 'USER';
--    l_token_tbl_three(1).token_value := l_login_party_name;
--    l_token_tbl_three(2).token_name  := 'ITEM';
--    l_token_tbl_three(2).token_value := cr.item_number;
--    l_token_tbl_three(3).token_name  := 'ORGANIZATION';
--    l_token_tbl_three(3).token_value := cr.organization_code;
--    error_handler.Add_Error_Message
--      ( p_message_name   => l_msg_name
--      , p_application_id => 'EGO'
--      , p_message_text   => NULL
--      , p_token_tbl      => l_token_tbl_three
--      , p_message_type   => 'E'
--      , p_row_identifier => cr.transaction_id
--      , p_table_name     => G_ERROR_TABLE_NAME
--      , p_entity_id      => NULL
--      , p_entity_index   => NULL
--      , p_entity_code    => G_ERROR_ENTITY_CODE
--      );
--        END IF; --IF c_get_grant_privileges%NOTFOUND THEN
--        CLOSE c_get_grant_privileges;
--      END IF; --IF (G_FULL_ACCESS_ITEMS = TRUE) THEN
--    END IF; --IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
--  ELSE      -- valid item number (from fnd_flex_listval.validate_segs)
--
--        Write_Debug('Erroring out Invalid Item Number records');
--    --
--    -- invalid item number
--    --
--          UPDATE ego_item_people_intf
--      SET  process_status = G_PS_ERROR
--      WHERE CURRENT OF c_get_item_number;
--    IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
--      IF ( cr.inventory_item_id IS NULL ) THEN
--        IF ( cr.item_number IS NULL ) THEN
--          l_msg_name := 'EGO_IPI_MISSING_VALUE';
--          l_token_tbl_one(1).token_name  := 'VALUE';
--          l_token_tbl_one(1).token_value := 'ITEM NUMBER';
--          error_handler.Add_Error_Message
--                  ( p_message_name   => l_msg_name
--            , p_application_id => 'EGO'
--            , p_message_text   => NULL
--            , p_token_tbl      => l_token_tbl_one
--            , p_message_type   => 'E'
--            , p_row_identifier => cr.transaction_id
--            , p_table_name     => G_ERROR_TABLE_NAME
--            , p_entity_id      => NULL
--            , p_entity_index   => NULL
--            , p_entity_code    => G_ERROR_ENTITY_CODE
--            );
--        ELSE
--          l_msg_name := 'EGO_IPI_INVALID_ITEM';
--          l_token_tbl_two(1).token_name  := 'ITEM';
--          l_token_tbl_two(1).token_value := cr.item_number;
--          l_token_tbl_two(2).token_name  := 'ORGANIZATION';
--          l_token_tbl_two(2).token_value := cr.organization_code;
--          error_handler.Add_Error_Message
--                  ( p_message_name   => l_msg_name
--            , p_application_id => 'EGO'
--            , p_message_text   => NULL
--            , p_token_tbl      => l_token_tbl_two
--            , p_message_type   => 'E'
--            , p_row_identifier => cr.transaction_id
--            , p_table_name     => G_ERROR_TABLE_NAME
--            , p_entity_id      => NULL
--            , p_entity_index   => NULL
--            , p_entity_code    => G_ERROR_ENTITY_CODE
--            );
--        END IF;  -- item number is null
--      END IF;  -- inventory item id is null
--    END IF;  -- G_debug_mode
--  END IF;  -- valid item number (from fnd_flex_listval.validate_segs)
--        check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
--                           ,x_retcode  => x_retcode);
--        IF x_retcode = RETCODE_ERROR THEN
--          RETURN;
--        END IF;
--      END LOOP;  -- c_get_item_number

      --Update the inventory_item_id column
      UPDATE ego_item_people_intf  eipi
      SET    process_status = G_INT_ITEM_VAL_ERROR
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND ( (inventory_item_id IS NOT NULL
               AND
               NOT EXISTS
                   (SELECT 'x' FROM mtl_system_items_b_kfv item
                    WHERE item.organization_id = eipi.organization_id
                    AND   item.inventory_item_id = eipi.inventory_item_id)
              )
              OR
              (inventory_item_id IS NULL
               AND
               NOT EXISTS
                   (SELECT 'x' FROM mtl_system_items_b_kfv item
                    WHERE item.organization_id = eipi.organization_id
                    AND   item.concatenated_segments = eipi.item_number)
              )
            );

      UPDATE ego_item_people_intf  eipi
      SET    item_number =
                (Select concatenated_segments
                 from mtl_system_items_b_kfv item
                 where item.organization_id = eipi.organization_id
                   and item.inventory_item_id = eipi.inventory_item_id)
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.inventory_item_id IS NOT NULL;

      UPDATE ego_item_people_intf  eipi
      SET    inventory_item_id =
                (Select inventory_item_id
                 from mtl_system_items_b_kfv item
                 where item.organization_id = eipi.organization_id
                   and item.concatenated_segments = eipi.item_number)
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status = G_PS_IN_PROCESS
        AND  eipi.inventory_item_id IS NULL;

      --
      -- flash all invalid item numbers
      --
      Write_Debug('Flashing messages for all invalid item records');
      FOR cr IN c_err_records LOOP

--        UPDATE ego_item_people_intf
--        SET    process_status   = G_PS_ERROR
--        WHERE  CURRENT OF c_err_item_id;

        IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
          IF ( cr.organization_code IS NULL ) THEN
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'ORGANIZATION ID';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.organization_id;
          ELSIF (cr.organization_id IS NULL) THEN
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'ORGANIZATION CODE';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.organization_code;
          ELSIF ( cr.item_number IS NULL ) THEN
            l_msg_name := 'EGO_IPI_INVALID_VALUE';
            l_token_tbl_two(1).token_name  := 'NAME';
            l_token_tbl_two(1).token_value := 'ITEM ID';
            l_token_tbl_two(2).token_name  := 'VALUE';
            l_token_tbl_two(2).token_value := cr.inventory_item_id;
          ELSE
            l_msg_name := 'EGO_IPI_INVALID_ITEM';
            l_token_tbl_two(1).token_name  := 'ITEM';
            l_token_tbl_two(1).token_value := cr.item_number;
            l_token_tbl_two(2).token_name  := 'ORGANIZATION';
            l_token_tbl_two(2).token_value := cr.organization_code;
          END IF;
          error_handler.Add_Error_Message
              ( p_message_name   => l_msg_name
              , p_application_id => 'EGO'
              , p_message_text   => NULL
              , p_token_tbl      => l_token_tbl_two
              , p_message_type   => 'E'
              , p_row_identifier => cr.transaction_id
              , p_table_name     => G_ERROR_TABLE_NAME
              , p_entity_id      => NULL
              , p_entity_index   => NULL
              , p_entity_code    => G_ERROR_ENTITY_CODE
              );
          check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                             ,x_retcode  => x_retcode);
          IF x_retcode = RETCODE_ERROR THEN
            RETURN;
          END IF;
        END IF;  -- G_debug_mode

      END LOOP;  -- c_err_records

      IF (G_FULL_ACCESS_ITEMS = TRUE) THEN
        Write_Debug('No need to check for Grant Privileges');
        NULL; --Do nothing
      ELSE
        --
        -- mark all item numbers on which privilege is not available
        --

        Write_Debug('Checking for access privilege on items to be granted ');
        UPDATE ego_item_people_intf  eipi
          SET process_status   = G_PS_ERROR
        WHERE  eipi.data_set_id = G_DATA_SET_ID
          AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
          AND  eipi.process_status = G_PS_IN_PROCESS
          -- 6459864: ignoring privilege check when defaulting people from style-sku
          AND  eipi.created_by <> -99
          AND  eipi.inventory_item_id IS NOT NULL
          AND NOT EXISTS
               (SELECT 'X'
                FROM EGO_LOGIN_ITEMS_TEMP
                WHERE inventory_item_id = eipi.inventory_item_id
                AND organization_id = eipi.organization_id
                AND conc_request_id = G_REQUEST_ID
               );

        Write_Debug('Flashing messages for all items on which user does not have any privilege ');
        FOR cr IN c_err_access_items LOOP
          IF G_DEBUG_MODE >= DEBUG_MODE_ERROR THEN
            l_msg_name := 'EGO_IPI_CANNOT_GRANT';
            l_token_tbl_three(1).token_name  := 'USER';
            l_token_tbl_three(1).token_value := l_login_party_name;
            l_token_tbl_three(2).token_name  := 'ITEM';
            l_token_tbl_three(2).token_value := cr.item_number;
            l_token_tbl_three(3).token_name  := 'ORGANIZATION';
            l_token_tbl_three(3).token_value := cr.organization_code;
            error_handler.Add_Error_Message
               ( p_message_name   => l_msg_name
               , p_application_id => 'EGO'
               , p_message_text   => NULL
               , p_token_tbl      => l_token_tbl_three
               , p_message_type   => 'E'
               , p_row_identifier => cr.transaction_id
               , p_table_name     => G_ERROR_TABLE_NAME
               , p_entity_id      => NULL
               , p_entity_index   => NULL
               , p_entity_code    => G_ERROR_ENTITY_CODE
               );
          END IF;  -- G_debug_mode
          check_and_write_log(p_msg_size => G_MAX_MESSAGE_SIZE
                             ,x_retcode  => x_retcode);
          IF x_retcode = RETCODE_ERROR THEN
            RETURN;
          END IF;
        END LOOP;  -- c_err_access_items
      END IF; -- check for full access on items.
-- bug 3710151 ends

      -- setting all error records to status error
      UPDATE ego_item_people_intf eipi
      SET    eipi.process_status  = G_PS_ERROR
      WHERE  eipi.data_set_id = G_DATA_SET_ID
        AND  eipi.transaction_id BETWEEN G_FROM_LINE_NUMBER AND G_TO_LINE_NUMBER
        AND  eipi.process_status IN (G_INT_ITEM_VAL_ERROR
                                    ,G_INT_ORG_VAL_ERROR
                                    );

      error_count_records();
      Write_Debug (' Item Number Completed ');
      -- commit the data after every batch
      --
      -- increment the loop values
      G_FROM_LINE_NUMBER := G_TO_LINE_NUMBER + 1;
    END LOOP; -- l_count_ipi_records

    Write_Debug('Checking for Grant Overlap on the items');
    --
    -- upload the data into fnd_grants
    --
    validate_no_grant_overlap(x_retcode  => x_retcode);
    check_and_write_log(p_msg_size => 0
                       ,x_retcode  => x_retcode);

    ----------------------------------------------------------------
    /* Calling API: Write_Error_into_ConcurrentLog from EGOPOPIB.pls
     Writing Errors into Concurrent Log in case User chose to
     delete data from the interface tables OR Error Link page is not
     working.
     Bug# 4540712 (RSOUNDAR)
     */
    ----------------------------------------------------------------
    l_err_msg_sql := 'SELECT INTF.ITEM_NUMBER as ITEM_NUMBER, '||
                     ' INTF.ORGANIZATION_CODE as ORGANIZATION_CODE, '||
                     ' MIERR.ERROR_MESSAGE as ERROR_MESSAGE '||
                     ' FROM  EGO_ITEM_PEOPLE_INTF INTF,  MTL_INTERFACE_ERRORS MIERR '||
                     ' WHERE  MIERR.TRANSACTION_ID = INTF.TRANSACTION_ID '||
                     ' AND    MIERR.REQUEST_ID = INTF.REQUEST_ID '||
                     ' AND    MIERR.request_id = :1';

    EGO_ITEM_OPEN_INTERFACE_PVT.Write_Error_into_ConcurrentLog
      (p_entity_name   => 'EGO_ITEM_PEOPLE'
      ,p_table_name    => 'EGO_ITEM_PEOPLE_INTF'
      ,p_selectQuery   => l_err_msg_sql
      ,p_request_id    => G_REQUEST_ID
      ,x_return_status => l_return_status
      ,x_msg_count     => l_msg_count
      ,x_msg_data      => l_msg_data
      );
    Write_Debug('Returned from EGO_ITEM_OPEN_INTERFACE_PVT.Write_Error_into_concurrentlog with status '||l_return_status);
    IF NVL(l_return_status,FND_API.G_RET_STS_SUCCESS)
                        = FND_API.G_RET_STS_UNEXP_ERROR THEN
      Write_Debug ('Error Message from EGO_ITEM_OPEN_INTERFACE_PVT.Write_Error_into_concurrentlog: '|| l_msg_data);
    END IF;

    -------------------------------------------------------------------------------
    -- Fix for Bug# 3603328
    -- Deleting the entire table, is avoided.
    -- Now seeding Item rows striped with Concurrent Request ID.
    -- Rows will be deleted, per Conc Req ID, at the end of processing.
    --
    -- These lines are purged irrespective of the value for "p_delete_lines"
    -------------------------------------------------------------------------------
    purge_login_items_table();

    Write_Debug('based on p_delete_lines :'||To_char(p_delete_lines)||' purge the intf table');
    --
    -- call purge_interface_lines if required
    --
    IF p_delete_lines IN
          (EGO_ITEM_PUB.G_INTF_DELETE_ALL
          ,EGO_ITEM_PUB.G_INTF_DELETE_ERROR
          ,EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS
          ) THEN
      purge_lines
                  (p_data_set_id        => p_data_set_id
                  ,p_closed_date        => NULL
                  ,p_delete_line_type   => p_delete_lines
                  ,x_retcode            => x_retcode
                  ,x_errbuff            => x_errbuff
                  );
    END IF;

    IF x_retcode = RETCODE_SUCCESS AND G_HAS_ERRORS THEN
      x_retcode :=  RETCODE_WARNING;
    END IF;

    Write_Debug('Load_interface_lines completed!');

    Conc_Log('Loading of Item People Import Interface lines complete.');

    -----------------------------------------------------------------------------
    --Close Error_Handler debug session, only if Debug session is already open.
    -----------------------------------------------------------------------------
    IF (Error_Handler.Get_Debug = 'Y') THEN
      Error_Handler.Close_Debug_Session;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      purge_login_items_table();
      fnd_message.set_name ('EGO','EGO_IPI_EXCEPTION');
      fnd_message.set_token('PROG_NAME',l_program_name);
      x_errbuff := fnd_message.get();
      Conc_Output (p_msg => x_errbuff);
      Write_Debug (x_errbuff ||': Details => ' || SQLERRM(SQLCODE));

      IF c_user_party_id%ISOPEN THEN
        CLOSE c_user_party_id;
      END IF;

      IF c_count_ipi_lines %ISOPEN THEN
        CLOSE c_count_ipi_lines;
      END IF;
      IF c_get_trans_id_limits %ISOPEN THEN
        CLOSE c_get_trans_id_limits;
      END IF;
      IF c_err_mand_params%ISOPEN THEN
        CLOSE c_err_mand_params;
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
-- bug 4628705
--      IF c_err_org_id%ISOPEN THEN
--        CLOSE c_err_org_id;
--      END IF;
-- bug 3710151
--      IF c_get_item_number%ISOPEN THEN
--        CLOSE c_get_item_number;
--      END IF;
--      IF c_get_grant_privileges%ISOPEN THEN
--        CLOSE c_get_grant_privileges;
--      END IF;
-- bug 4628705
--      IF c_err_item_id%ISOPEN THEN
--        CLOSE c_err_item_id;
--      END IF;
      IF c_err_records%ISOPEN THEN
        CLOSE c_err_records;
      END IF;
      IF c_err_access_items%ISOPEN THEN
        CLOSE c_err_access_items;
      END IF;
-- bug 3710151 end
      IF c_get_utl_file_dir%ISOPEN THEN
        CLOSE c_get_utl_file_dir;
      END IF;
      -----------------------------------------------------
      -- Close Debug Session, as we cant proceed further.
      -----------------------------------------------------
      Error_Handler.Close_Debug_Session;

      -------------------------------------------------------------
      -- Rollback incomplete processing, and raise the exception
      -- to trace all the way up.
      -------------------------------------------------------------
      ROLLBACK;
      RAISE;

  END load_interface_lines;


 ----------------------------------------------------------
 --                                                      --
 ----------------------------------------------------------
  PROCEDURE purge_interface_lines
                 ( x_errbuff            OUT NOCOPY VARCHAR2,
                   x_retcode            OUT NOCOPY VARCHAR2,
                   p_data_set_id        IN  NUMBER,
                   p_closed_date        IN  VARCHAR2,
                   p_delete_line_type   IN  NUMBER
                 ) IS
    -- Start OF comments
    -- API name  : Clean Interface Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Removes all the interface lines
    --
    l_closed_date  DATE;
    l_program_name   CONSTANT  VARCHAR2(30) := 'PURGE_INTERFACE_LINES';
  BEGIN
    -- validate the given parameters
    G_DEBUG_MODE := DEBUG_MODE_DEBUG;
    IF (p_data_set_id IS NULL AND p_closed_date IS NULL)
       OR  NVL(p_delete_line_type,-1) NOT IN
          (EGO_ITEM_PUB.G_INTF_DELETE_ALL
          ,EGO_ITEM_PUB.G_INTF_DELETE_ERROR
          ,EGO_ITEM_PUB.G_INTF_DELETE_SUCCESS
          ,EGO_ITEM_PUB.G_INTF_DELETE_NONE
          ) THEN
       -- invalid parameters
      x_retcode := RETCODE_ERROR;
      fnd_message.set_name('EGO','EGO_IPI_INSUFFICIENT_PARAMS');
      x_errbuff := fnd_message.get();
      conc_output (x_errbuff);
    ELSE
      -- call purge lines program with sufficient parameters.
      IF p_closed_date IS NULL THEN
        l_closed_date := NULL;
      ELSE
        l_closed_date := fnd_date.canonical_to_date(p_closed_date);
      END IF;
      purge_lines
           (p_data_set_id        => p_data_set_id
           ,p_closed_date        => l_closed_date
           ,p_delete_line_type   => p_delete_line_type
           ,x_retcode            => x_retcode
           ,x_errbuff            => x_errbuff
     );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := RETCODE_ERROR;
      fnd_message.set_name('EGO','EGO_IPI_EXCEPTION');
      fnd_message.set_token('PROG_NAME',l_program_name);
      x_errbuff := fnd_message.get();
      conc_output (x_errbuff);
      Write_Debug (x_errbuff);
      ROLLBACK;
      RAISE;

  END purge_interface_lines;

END EGO_ITEM_PEOPLE_IMPORT_PKG;

/

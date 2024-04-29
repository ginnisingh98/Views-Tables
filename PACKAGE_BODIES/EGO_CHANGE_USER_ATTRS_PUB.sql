--------------------------------------------------------
--  DDL for Package Body EGO_CHANGE_USER_ATTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CHANGE_USER_ATTRS_PUB" AS
/* $Header: EGOCHUAB.pls 120.3 2007/04/09 17:07:09 prgopala ship $ */



                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------


    G_PKG_NAME                               CONSTANT VARCHAR2(30) := 'EGO_CHANGE_USER_ATTRS_PUB';
    G_API_VERSION                            NUMBER := 1.0;
    G_ITEM_NAME                              VARCHAR2(20);
    G_FUNCTION_NAME                          FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE := 'ENG_EDIT_CHANGE';

/*** The following two variables are for Error_Handler ***/
    G_ENTITY_ID                              NUMBER;
    G_ENTITY_CODE                            CONSTANT VARCHAR2(30) := 'CHANGE_USER_ATTRS_ENTITY_CODE';
    G_REQUEST_ID                             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    G_PROGAM_APPLICATION_ID                  NUMBER := FND_GLOBAL.PROG_APPL_ID;
    G_PROGAM_ID                              NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    G_USER_NAME                              FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
    G_USER_ID                                NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                               NUMBER := FND_GLOBAL.LOGIN_ID;
    G_HZ_PARTY_ID                            VARCHAR2(30);
    G_NO_CURRVAL_YET                         EXCEPTION;
    G_NO_USER_NAME_TO_VALIDATE               EXCEPTION;
    G_NO_CHANGE_TO_VALIDATE                  EXCEPTION;
    g_app_name                VARCHAR2(3)  := 'EGO'; --3070807
    g_plsql_err               VARCHAR2(17) := 'EGO_PLSQL_ERR';
    g_pkg_name_token          VARCHAR2(8)  := 'PKG_NAME';
    g_api_name_token          VARCHAR2(8)  := 'API_NAME';
    g_sql_err_msg_token       VARCHAR2(11) := 'SQL_ERR_MSG';

               -------------------------------------
               -- Pragma for Data Set ID function --
               -------------------------------------
    PRAGMA EXCEPTION_INIT (G_NO_CURRVAL_YET, -08002);



                          ----------------
                          -- Procedures --
                          ----------------

----------------------------------------------------------------------
PROCEDURE Process_Change_User_Attrs_Data
(
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_debug_level                   IN   NUMBER   DEFAULT 0
       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE
) IS

    l_error_message_name     VARCHAR2(30);
    l_entity_index_counter   NUMBER := 0;
    l_header_or_line_counter   NUMBER := 1;
    l_header_row_exists   BOOLEAN := FALSE;
    l_line_row_exists   BOOLEAN := FALSE;
    l_prev_loop_org_id       NUMBER;
    l_prev_loop_change_id  NUMBER;
    l_prev_loop_change_line_id NUMBER;
    l_prev_loop_row_identifier NUMBER;
    l_at_start_of_instance   BOOLEAN;
    l_can_edit_this_instance VARCHAR2(1);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_could_edit_prev_instance VARCHAR2(1);
    l_at_start_of_row        BOOLEAN;
    p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_line_pk_col_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_line_class_code_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
    p_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;
    l_failed_row_id_buffer   VARCHAR2(32767);
    l_failed_row_id_list     VARCHAR2(32767);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_dynamic_sql            VARCHAR2(32767);
    p_line_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
    p_line_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;

    -------------------------------------------------------------------------
    -- For finding ChangeID using Organization ID and Change Number --
    -------------------------------------------------------------------------
    CURSOR change_num_to_id_cursor (cp_data_set_id IN NUMBER)
    IS
    SELECT DISTINCT ORGANIZATION_ID
          ,CHANGE_NUMBER
      FROM ENG_CHG_USR_ATR_INTERFACE
     WHERE DATA_SET_ID = cp_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
       AND CHANGE_NUMBER IS NOT NULL
       AND CHANGE_ID IS NULL;

    ---------------------------------------------------------------
    -- For reporting errors for all of the four conversion steps --
    ---------------------------------------------------------------
    CURSOR error_case_cursor (cp_data_set_id IN NUMBER)
    IS
    SELECT DISTINCT ORGANIZATION_CODE
          ,ORGANIZATION_ID
          ,CHANGE_NUMBER
          ,CHANGE_ID
          ,CHANGE_MGMT_TYPE_CODE
          ,CHANGE_TYPE_ID
          ,ROW_IDENTIFIER
          ,CHANGE_LINE_ID
     FROM ENG_CHG_USR_ATR_INTERFACE
    WHERE DATA_SET_ID = cp_data_set_id
      AND PROCESS_STATUS = G_PS_ERROR;

    -------------------------------------------------------------------
    -- For processing all rows that passed the four conversion steps --
    -------------------------------------------------------------------
    CURSOR data_set_cursor_header (cp_data_set_id IN NUMBER)
    IS
    SELECT TRANSACTION_ID
          ,PROCESS_STATUS
          ,ORGANIZATION_CODE
          ,CHANGE_NUMBER
          ,CHANGE_MGMT_TYPE_CODE
          ,CHANGE_LINE_SEQUENCE_NUMBER
          ,ATTR_GROUP_INT_NAME
          ,ROW_IDENTIFIER
          ,ATTR_INT_NAME
          ,ATTR_VALUE_STR
          ,ATTR_VALUE_NUM
          ,ATTR_VALUE_DATE
          ,ATTR_DISP_VALUE
          ,TRANSACTION_TYPE
          ,ORGANIZATION_ID
          ,CHANGE_ID
          ,CHANGE_TYPE_ID
          ,ATTR_GROUP_ID
          ,CHANGE_LINE_ID
      FROM ENG_CHG_USR_ATR_INTERFACE
     WHERE DATA_SET_ID = cp_data_set_id
       AND CHANGE_LINE_ID is NULL
       AND PROCESS_STATUS = G_PS_IN_PROCESS
    ORDER BY ORGANIZATION_ID, CHANGE_ID,(DECODE (UPPER(TRANSACTION_TYPE),
                                                  'DELETE', 1,
                                                  'UPDATE', 2,
                                                  'SYNC', 3,
                                                  'CREATE', 4, 5)), ROW_IDENTIFIER;


    CURSOR data_set_cursor_line (cp_data_set_id IN NUMBER)
    IS
    SELECT TRANSACTION_ID
          ,PROCESS_STATUS
          ,ORGANIZATION_CODE
          ,CHANGE_NUMBER
          ,CHANGE_MGMT_TYPE_CODE
          ,CHANGE_LINE_SEQUENCE_NUMBER
          ,ATTR_GROUP_INT_NAME
          ,ROW_IDENTIFIER
          ,ATTR_INT_NAME
          ,ATTR_VALUE_STR
          ,ATTR_VALUE_NUM
          ,ATTR_VALUE_DATE
          ,ATTR_DISP_VALUE
          ,TRANSACTION_TYPE
          ,ORGANIZATION_ID
          ,CHANGE_ID
          ,CHANGE_TYPE_ID
          ,ATTR_GROUP_ID
          ,CHANGE_LINE_ID
      FROM ENG_CHG_USR_ATR_INTERFACE
     WHERE DATA_SET_ID = cp_data_set_id
       AND CHANGE_LINE_ID is NOT NULL
       AND PROCESS_STATUS = G_PS_IN_PROCESS
    ORDER BY ORGANIZATION_ID, CHANGE_LINE_ID,(DECODE (UPPER(TRANSACTION_TYPE),
                                                  'DELETE', 1,
                                                  'UPDATE', 2,
                                                  'SYNC', 3,
                                                  'CREATE', 4, 5)), ROW_IDENTIFIER;

        CURSOR c_CheckChange(l_change_id NUMBER) IS
        SELECT status_type,
               approval_status_type
          FROM eng_engineering_changes
         WHERE change_id = l_change_id;

        CURSOR c_CheckLine(l_change_line_id NUMBER) IS
        SELECT status_code
          FROM eng_change_lines
         WHERE change_line_id = l_change_line_id;
  BEGIN

    -----------------------------------------------
    -- Set this global variable once per session --
    -----------------------------------------------
    IF (G_HZ_PARTY_ID IS NULL) THEN
      IF (G_USER_NAME IS NOT NULL) THEN

      SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
        INTO G_HZ_PARTY_ID
        FROM EGO_PEOPLE_V
       WHERE USER_NAME = G_USER_NAME;

      ELSE

        RAISE G_NO_USER_NAME_TO_VALIDATE;

      END IF;
    END IF;



                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

    ERROR_HANDLER.Initialize();
    ERROR_HANDLER.Set_Bo_Identifier(EGO_USER_ATTRS_DATA_PVT.G_BO_IDENTIFIER);

    -----------------------------------------------------------
    -- If we're debugging, we have to set up a Debug session --
    -----------------------------------------------------------
    IF (p_debug_level > 0) THEN

      EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(G_ENTITY_ID, G_ENTITY_CODE,p_debug_level);

    END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Concurrent Program', 1);



              --===================================--
              -- GETTING THE INTERFACE TABLE READY --
              --===================================--

    ---------------------------------------------------------------------
    -- Mark all rows we'll be processing, and null out user input for  --
    -- the ORGANIZATION_ID column (so we can validate Organizations);  --
    -- also update Concurrent Request information for better tracking  --
    -- and update the "WHO" columns on the assumption that the current --
    -- user is also the person who loaded this data set into the table --
    ---------------------------------------------------------------------
    UPDATE ENG_CHG_USR_ATR_INTERFACE
       SET PROCESS_STATUS = G_PS_IN_PROCESS
          ,ORGANIZATION_ID = NULL
          ,CHANGE_TYPE_ID = NULL
          ,CHANGE_ID = NULL
          ,CHANGE_LINE_ID = NULL
          ,REQUEST_ID = G_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = G_PROGAM_APPLICATION_ID
          ,PROGRAM_ID = G_PROGAM_ID
          ,PROGRAM_UPDATE_DATE = SYSDATE
          ,CREATED_BY = G_USER_ID
          ,LAST_UPDATED_BY = G_USER_ID
          ,LAST_UPDATE_LOGIN = G_LOGIN_ID
     WHERE DATA_SET_ID = p_data_set_id;


               --==================================--
               -- THE THREE PRELIMINARY CONVERSIONS --
               --==================================--

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting conversions', 1);

    ------------------------------------------------------------------
    -- 1). Convert Organization Code to Organization ID
    ------------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Org Code conversion', 2);

    UPDATE ENG_CHG_USR_ATR_INTERFACE UAI
       SET UAI.ORGANIZATION_ID = (SELECT MP.ORGANIZATION_ID
                                    FROM MTL_PARAMETERS MP
                                   WHERE MP.ORGANIZATION_CODE = UAI.ORGANIZATION_CODE)
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND UAI.ORGANIZATION_CODE IS NOT NULL
       AND EXISTS(SELECT MP2.ORGANIZATION_ID
                    FROM MTL_PARAMETERS MP2
                   WHERE MP2.ORGANIZATION_CODE = UAI.ORGANIZATION_CODE);

    ---------------------------------------------------------------------
    -- Mark as errors all rows where we didn't get an Organization ID  --
    -- (marking errors as we go avoids further processing of bad rows) --
    ---------------------------------------------------------------------
    -- UPDATE ENG_CHG_USR_ATR_INTERFACE
    -- SET PROCESS_STATUS = G_PS_ERROR
    -- WHERE DATA_SET_ID = p_data_set_id
    -- AND PROCESS_STATUS = G_PS_IN_PROCESS
    -- AND ORGANIZATION_ID IS NULL;

     -- Joseph George : Bug Fix for Change Management Import Bulk Loading
     -- Bug No : 2873555, Base Bug

     UPDATE ENG_CHG_USR_ATR_INTERFACE
     SET PROCESS_STATUS = G_PS_ERROR
     WHERE ROW_IDENTIFIER IN (SELECT DISTINCT ROW_IDENTIFIER
                                FROM ENG_CHG_USR_ATR_INTERFACE
                                WHERE DATA_SET_ID = p_data_set_id
                                AND PROCESS_STATUS = G_PS_IN_PROCESS
                                AND ORGANIZATION_ID IS NULL)
     AND DATA_SET_ID = p_data_set_id;


    -------------------------------------------------------------------------
    -- 2). Convert Change Number to Change Id: this cursor selects   --
    -- distinct Organization ID and Change Number combinations (among those  --
    -- rows that are still valid, meaning we won't have any null Org IDs)  --
    -- and gets the Change ID for each combination also gets change Line Id
    -- from change_line_sequence_number
    -------------------------------------------------------------------------
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Number conversion', 2);

     UPDATE ENG_CHG_USR_ATR_INTERFACE UAI
       SET UAI.CHANGE_ID =
           (SELECT EEC.CHANGE_ID
              FROM ENG_ENGINEERING_CHANGES EEC
             WHERE EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
               AND EEC.CHANGE_NOTICE = UAI.CHANGE_NUMBER
               AND EEC.CHANGE_MGMT_TYPE_CODE = UAI.CHANGE_MGMT_TYPE_CODE
               AND UAI.CHANGE_LINE_SEQUENCE_NUMBER IS NULL)
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
       AND EXISTS(SELECT EEC.CHANGE_ID
                    FROM ENG_ENGINEERING_CHANGES EEC
                   WHERE EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                     AND EEC.CHANGE_NOTICE = UAI.CHANGE_NUMBER
                     AND EEC.CHANGE_MGMT_TYPE_CODE = UAI.CHANGE_MGMT_TYPE_CODE
                     AND UAI.CHANGE_LINE_SEQUENCE_NUMBER IS NULL);


UPDATE ENG_CHG_USR_ATR_INTERFACE UAI SET
  UAI.CHANGE_LINE_ID=
   (SELECT ELV.CHANGE_LINE_ID
    FROM ENG_CHANGE_LINES ELV,ENG_ENGINEERING_CHANGES EEC
    WHERE
      EEC.CHANGE_ID = ELV.CHANGE_ID
      AND EEC.CHANGE_NOTICE = UAI.CHANGE_NUMBER
      AND EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
      AND ELV.SEQUENCE_NUMBER = UAI.CHANGE_LINE_SEQUENCE_NUMBER
    ),
  UAI.CHANGE_ID=
   (SELECT ELV.CHANGE_ID
    FROM ENG_CHANGE_LINES ELV, ENG_ENGINEERING_CHANGES EEC
    WHERE
      EEC.CHANGE_ID = ELV.CHANGE_ID
      AND EEC.CHANGE_NOTICE = UAI.CHANGE_NUMBER
      AND EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
      AND ELV.SEQUENCE_NUMBER = UAI.CHANGE_LINE_SEQUENCE_NUMBER
   )
  WHERE
    UAI.DATA_SET_ID = p_data_set_id
    AND PROCESS_STATUS = G_PS_IN_PROCESS
    AND EXISTS
     (SELECT ELV.CHANGE_LINE_ID
      FROM ENG_CHANGE_LINES ELV,ENG_ENGINEERING_CHANGES EEC
      WHERE
        EEC.CHANGE_ID = ELV.CHANGE_ID
        AND EEC.CHANGE_NOTICE = UAI.CHANGE_NUMBER
        AND EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
        AND ELV.SEQUENCE_NUMBER = UAI.CHANGE_LINE_SEQUENCE_NUMBER
     );

 ---------------------------------------------------------------------------
    -- Mark as errors all rows where we didn't get Change_id  --
    -- (as always, ignoring rows that errored out earlier in our processing) --
    ---------------------------------------------------------------------------
    -- UPDATE ENG_CHG_USR_ATR_INTERFACE
    -- SET PROCESS_STATUS = G_PS_ERROR
    -- WHERE DATA_SET_ID = p_data_set_id
    -- AND PROCESS_STATUS = G_PS_IN_PROCESS
    -- AND CHANGE_ID IS NULL
    -- AND CHANGE_LINE_ID IS NULL;

     -- Joseph George : Bug Fix for Change Management Import Bulk Loading
     -- Bug No : 2873555, Base Bug

     UPDATE ENG_CHG_USR_ATR_INTERFACE
     SET PROCESS_STATUS = G_PS_ERROR
     WHERE ROW_IDENTIFIER IN (SELECT DISTINCT ROW_IDENTIFIER
                                FROM ENG_CHG_USR_ATR_INTERFACE
                                WHERE DATA_SET_ID = p_data_set_id
                                AND PROCESS_STATUS = G_PS_IN_PROCESS
                                AND CHANGE_ID IS NULL
                                AND CHANGE_LINE_SEQUENCE_NUMBER IS NULL)
     AND DATA_SET_ID = p_data_set_id;


     UPDATE ENG_CHG_USR_ATR_INTERFACE
     SET PROCESS_STATUS = G_PS_ERROR
     WHERE ROW_IDENTIFIER IN (SELECT DISTINCT ROW_IDENTIFIER
                                FROM ENG_CHG_USR_ATR_INTERFACE
                                WHERE DATA_SET_ID = p_data_set_id
                                AND PROCESS_STATUS = G_PS_IN_PROCESS
				AND CHANGE_LINE_ID IS NULL
                                AND CHANGE_LINE_SEQUENCE_NUMBER IS NOT NULL)
     AND DATA_SET_ID = p_data_set_id;

    ------------------------------------------------------
    -- 4). Find the Change Type Id for each Change and Change Line--
    ------------------------------------------------------
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Type Id conversion', 2);

    UPDATE ENG_CHG_USR_ATR_INTERFACE UAI
       SET UAI.CHANGE_TYPE_ID =
           (SELECT EEC.CHANGE_ORDER_TYPE_ID
              FROM ENG_ENGINEERING_CHANGES EEC
             WHERE EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
               AND EEC.CHANGE_ID = UAI.CHANGE_ID
               AND UAI.CHANGE_LINE_SEQUENCE_NUMBER IS NULL)
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
       AND EXISTS(SELECT EEC.CHANGE_ORDER_TYPE_ID
                    FROM ENG_ENGINEERING_CHANGES EEC
                   WHERE EEC.ORGANIZATION_ID = UAI.ORGANIZATION_ID
                     AND EEC.CHANGE_ID = UAI.CHANGE_ID
                     AND UAI.CHANGE_LINE_SEQUENCE_NUMBER IS NULL);


      UPDATE ENG_CHG_USR_ATR_INTERFACE UAI
       SET UAI.CHANGE_TYPE_ID =
           (SELECT EEC.CHANGE_TYPE_ID
              FROM ENG_CHANGE_LINES_VL EEC
             WHERE
               EEC.CHANGE_LINE_ID = UAI.CHANGE_LINE_ID
               )
     WHERE UAI.DATA_SET_ID = p_data_set_id
       AND PROCESS_STATUS = G_PS_IN_PROCESS
       AND UAI.CHANGE_LINE_SEQUENCE_NUMBER IS NOT NULL;

    ---------------------------------------------------------------------------
    -- Mark as errors all rows where we didn't get Change Type ID  --
    -- (as always, ignoring rows that errored out earlier in our processing) --
    ---------------------------------------------------------------------------
    -- UPDATE ENG_CHG_USR_ATR_INTERFACE
    -- SET PROCESS_STATUS = G_PS_ERROR
    -- WHERE DATA_SET_ID = p_data_set_id
    -- AND PROCESS_STATUS = G_PS_IN_PROCESS
    -- AND CHANGE_TYPE_ID IS NULL;

     -- Joseph George : Bug Fix for Change Management Import Bulk Loading
     -- Bug No : 2873555, Base Bug

     UPDATE ENG_CHG_USR_ATR_INTERFACE
     SET PROCESS_STATUS = G_PS_ERROR
     WHERE ROW_IDENTIFIER IN (SELECT DISTINCT ROW_IDENTIFIER
                                FROM ENG_CHG_USR_ATR_INTERFACE
                                WHERE DATA_SET_ID = p_data_set_id
                                AND PROCESS_STATUS = G_PS_IN_PROCESS
                                AND CHANGE_TYPE_ID IS NULL )
     AND DATA_SET_ID = p_data_set_id;

            --========================================--
            -- ERROR REPORTING FOR FAILED CONVERSIONS --
            --========================================--
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting conversion error-reporting', 1);

    --------------------------------------------------------------------------
    -- We fetch representative rows marked as errors and add error messages --
    -- explaining the point in our conversion process at which each failed; --
    -- note that to avoid multiple error messages for the same missing data --
    -- we use DISTINCT in our cursor query and thus should only get one row --
    -- for each ROW_IDENTIFIER (since Org Code, Item Number, Revision and   --
    -- Catalog Group Name should be the same for a given ROW_IDENTIFIER).   --
    --------------------------------------------------------------------------
    FOR error_rec IN error_case_cursor(p_data_set_id)
    LOOP

      -------------------------------------------------------
      -- 1). If Org ID is null we failed at the first step --
      -------------------------------------------------------
      IF (error_rec.ORGANIZATION_ID IS NULL) THEN

        l_token_table(1).TOKEN_NAME := 'ORG_CODE';
        l_token_table(1).TOKEN_VALUE := error_rec.ORGANIZATION_CODE;

-- Bug 2779881 Changed EGO_EF_BL_ORG_ID_ERR to ENG_EF_BL_ORG_ID_ERR

        l_error_message_name := 'ENG_EF_BL_ORG_ID_ERR';

      ----------------------------------------------------------------------------
      -- 2). If Org ID is not null but Change ID is, we failed at the second step --
      ----------------------------------------------------------------------------
      ELSIF (error_rec.CHANGE_ID IS NULL AND error_rec.CHANGE_LINE_ID IS NULL) THEN

        l_token_table(1).TOKEN_NAME := 'CHANGE_NUMBER';
        l_token_table(1).TOKEN_VALUE := error_rec.CHANGE_NUMBER;
        l_token_table(2).TOKEN_NAME := 'ORG_CODE';
        l_token_table(2).TOKEN_VALUE := error_rec.ORGANIZATION_CODE;

-- Bug 2779881 Changed EGO_EF_BL_CHANGE_ID_ERR to ENG_EF_BL_ORG_ID_ERR

        l_error_message_name := 'ENG_EF_BL_CHANGE_ID_ERR';

           ---------------------------------------------------------------------------------
      -- 3). If we got everything but Change Type Id, we failed at the fourth step --
      ---------------------------------------------------------------------------------
      ELSIF (error_rec.CHANGE_TYPE_ID IS NULL) THEN

        l_token_table(1).TOKEN_NAME := 'CHANGE_MGMT_CODE';
        l_token_table(1).TOKEN_VALUE := error_rec.CHANGE_MGMT_TYPE_CODE;
        l_token_table(2).TOKEN_NAME := 'CHANGE_NUMBER';
        l_token_table(2).TOKEN_VALUE := error_rec.CHANGE_NUMBER;
        l_token_table(3).TOKEN_NAME := 'ORG_CODE';
        l_token_table(3).TOKEN_VALUE := error_rec.ORGANIZATION_CODE;

-- Bug 2779881 Changed EGO_EF_BL_CHANGE_TYPE_ID_ERR to ENG_EF_BL_CHANGE_TYPE_ID_ERR

        l_error_message_name := 'ENG_EF_BL_CHANGE_TYPE_ID_ERR';

      END IF;

-- Bug 2779881 Changed Application EGO to ENG

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => l_error_message_name
       ,p_application_id                => 'ENG'
       ,p_token_tbl                     => l_token_table
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_row_identifier                => error_rec.ROW_IDENTIFIER
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
      );

    END LOOP;

             --=====================================--
             -- LOOP PROCESSING OF STILL-VALID ROWS --
             --=====================================--
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting loop processing of valid rows', 1);

    ------------------------------------------------------------------
    -- The interface table stores the Attribute data in a redundant --
    -- form; we loop through its rows flattening the data out and   --
    -- building appropriate objects so that every time we reach the --
    -- end of a row subset for a particular Item instance, we can   --
    -- call EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data() with  --
    -- the accumulated objects we've built in previous loops.       --
    ------------------------------------------------------------------


   EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before calling Header loop', 1);

    FOR attr_rec IN data_set_cursor_header(p_data_set_id)
    LOOP
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Header loop', 1);
      l_header_row_exists := TRUE;

      ------------------------------------------------------
      -- Figure out whether we're starting a new instance --
      ------------------------------------------------------
      l_at_start_of_instance :=  (l_prev_loop_org_id IS NULL OR
                                  l_prev_loop_org_id <> attr_rec.ORGANIZATION_ID OR
                                  l_prev_loop_change_id <> attr_rec.CHANGE_ID);

      IF (l_at_start_of_instance) THEN
      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Header loop start_of_instance', 1);

        l_entity_index_counter := l_entity_index_counter + 1;

        ------------------------------------------------------------------
        -- Determine whether the current user has sufficient privileges --
        -- to update User Attribute values for the current instance; if --
        -- not, we won't process any rows for the current instance, and --
        -- we'll move on to the next instance (because the user may or  --
        -- may not have sufficient privileges on the next instance)     --
        ------------------------------------------------------------------
        l_could_edit_prev_instance := l_can_edit_this_instance;
      --uncommenting the code for bug 5239327
        G_ITEM_NAME := 'ENG_CHANGE';
        l_can_edit_this_instance := EGO_DATA_SECURITY.Check_Function(
                                        p_api_version                   => G_API_VERSION
                                       ,p_function                      => G_FUNCTION_NAME
                                       ,p_object_name                   => G_ITEM_NAME
                                       ,p_instance_pk1_value            => attr_rec.CHANGE_ID
                              --       ,p_instance_pk2_value            => attr_rec.ORGANIZATION_ID
                                       ,p_user_name                     => G_HZ_PARTY_ID
                                    );
       --uncommenting the code for bug 5239327
     --  	l_can_edit_this_instance := 'T';

        FOR ECO IN c_CheckChange(attr_rec.CHANGE_ID)
	LOOP
		IF (ECO.status_type = 5 OR ECO.status_type = 6 OR ECO.status_type = 7  OR ECO.approval_status_type = 3 OR ECO.approval_status_type = 5) THEN
        		l_can_edit_this_instance := 'F';
		END IF;
        END LOOP;
        --------------------------------------------------------------------
        -- We do an inverted IF check so that we can catch the case where --
        -- l_can_edit_this_instance is NULL and report an error message   --
        --------------------------------------------------------------------
        IF (l_can_edit_this_instance = 'T') THEN

          NULL;

        ELSE

          -------------------------------------------------------------------------
          -- Update the status of all rows for this instance to reflect the fact --
          -- that the entire instance has a security error; we would prefer to   --
          -- do this update row-by-row rather than as a manual update, because   --
          -- updating a cursor means only doing a single update when the cursor  --
          -- is released, whereas doing our own update for each failed instance  --
          -- results in a DML per instance; however, we cannot do so because our --
          -- call to Process_User_Attrs_Data includes a commit, and FOR UPDATE   --
          -- cursors can't handle commits done in mid-looping.                   --
          -------------------------------------------------------------------------

          UPDATE ENG_CHG_USR_ATR_INTERFACE
             SET PROCESS_STATUS = G_PS_ERROR
           WHERE DATA_SET_ID = p_data_set_id
             AND ORGANIZATION_ID = attr_rec.ORGANIZATION_ID
             AND CHANGE_ID = attr_rec.CHANGE_ID;

          ------------------------------------------------
          -- We add the error message once per instance --
          ------------------------------------------------
          IF (l_can_edit_this_instance = 'F') THEN

-- Bug 2779881 Changed EGO_EF_BL_NO_PRIVS_ON_INSTANCE to ENG_EF_BL_NO_PRIVS_ON_INSTANCE

            l_error_message_name := 'ENG_EF_BL_NO_PRIVS_ON_INSTANCE';

          ELSE

-- Bug 2779881 Changed EGO_EF_BL_PRIV_CHECK_ERROR to ENG_EF_BL_PRIV_CHECK_ERROR

            l_error_message_name := 'ENG_EF_BL_PRIV_CHECK_ERROR';

          END IF;

          l_token_table(1).TOKEN_NAME := 'USER_NAME';
          l_token_table(1).TOKEN_VALUE := G_USER_NAME;
          l_token_table(2).TOKEN_NAME := 'CHANGE_NUMBER';
          l_token_table(2).TOKEN_VALUE := attr_rec.CHANGE_NUMBER;
          l_token_table(3).TOKEN_NAME := 'ORG_CODE';
          l_token_table(3).TOKEN_VALUE := attr_rec.ORGANIZATION_CODE;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => l_error_message_name
           ,p_application_id                => 'ENG'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_entity_id                     => G_ENTITY_ID
           ,p_entity_index                  => l_entity_index_counter
           ,p_entity_code                   => G_ENTITY_CODE
          );

        END IF;

        ------------------------------------------------------------------
        -- The VERY first loop through, we want to build arrays for the --
        -- Primary Key columns and the Classification Code columns; for --
        -- every subsequent instance, we just update the values.        --
        -- We also build Attr Row and Attr Data tables the first time   --
        -- through, which we then clear out (rather than re-allocating) --
        -- at the start of all subsequent instances.                    --
        ------------------------------------------------------------------
           G_ITEM_NAME := 'ENG_CHANGE';
        IF (l_prev_loop_org_id IS NULL) THEN
         EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Header loop l_prev_loop_org_id IS NULL', 1);

         p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_ID', attr_rec.CHANGE_ID)
);
          p_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                             EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_TYPE_ID', attr_rec.CHANGE_TYPE_ID));
          p_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
          p_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();

        ELSE

          IF (l_could_edit_prev_instance = 'T') THEN

            -------------------------------------------------------------------------
            -- Since this is the start of an instance other than the first, we are --
            -- ready to process the data we've collected for the previous instance --
            -- (note that since we're always calling for the previous instance, we --
            -- will need one final call after we're done looping through all rows; --
            -- note also that we make sure the user passed the security check)     --
            -------------------------------------------------------------------------
     EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Header loop previous instance processing ', 1);
            EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
            (
              p_api_version                   => G_API_VERSION
             ,p_object_name                   => G_ITEM_NAME
             ,p_attributes_row_table          => p_attributes_row_table
             ,p_attributes_data_table         => p_attributes_data_table
             ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
             ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
             ,p_entity_id                     => G_ENTITY_ID
             ,p_entity_index                  => l_entity_index_counter
             ,p_entity_code                   => G_ENTITY_CODE
             ,p_debug_level                   => p_debug_level
             ,p_commit                        => FND_API.G_TRUE
             ,x_failed_row_id_list            => l_failed_row_id_buffer
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data
            );

            ------------------------------------------------------------------------
            -- If any rows for this instance failed, we add their ROW_IDENTIFIERs --
            -- to a master list that we will eventually use to mark as errors all --
            -- rows whose ROW_IDENTIFIERs appear in the list                      --
            ------------------------------------------------------------------------
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

              l_failed_row_id_list := l_failed_row_id_list || l_failed_row_id_buffer || ',';

            END IF;
          END IF;

          ------------------------------------------------------------------
          -- Now we update the Primary Key and Classification Code column --
          -- values, and we clear out the Attr Row and Attr Data tables   --
          ------------------------------------------------------------------

          p_pk_column_name_value_pairs(1).VALUE := attr_rec.CHANGE_ID;
   --     p_pk_column_name_value_pairs(2).VALUE := attr_rec.ORGANIZATION_ID;
          p_class_code_name_value_pairs(1).VALUE := attr_rec.CHANGE_TYPE_ID;

          p_attributes_row_table.DELETE;
          p_attributes_data_table.DELETE;

        END IF;
      END IF;

      IF (l_can_edit_this_instance = 'T') THEN
        -----------------------------------------------------
        -- Figure out whether we're now starting a new row --
        -----------------------------------------------------
        l_at_start_of_row := (l_prev_loop_row_identifier IS NULL OR
                              (l_prev_loop_row_identifier <> attr_rec.ROW_IDENTIFIER) OR
                              (l_prev_loop_row_identifier = attr_rec.ROW_IDENTIFIER AND l_prev_loop_change_id <> attr_rec.CHANGE_ID));

        -------------------------------------------
        -- Build an Attr Row Object for each row --
        -------------------------------------------
        IF (l_at_start_of_row) THEN
       EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Header loop starting a new row ', 1);
          p_attributes_row_table.EXTEND();

           p_attributes_row_table(p_attributes_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(
                                                                   attr_rec.ROW_IDENTIFIER
                                                                  ,attr_rec.ATTR_GROUP_ID
                                                                  ,703
                                                                  ,'ENG_CHANGEMGMT_GROUP'
                                                                  ,attr_rec.ATTR_GROUP_INT_NAME
                                                                  ,null
                                                                  ,null
                                                                  ,null
								  ,null
                                                                  ,null
                                                                  ,null
					,attr_rec.TRANSACTION_TYPE
                                                                 );

        END IF;

        ---------------------------------------------------------------
        -- Add an Attr Data object to the Attr Data table every time --
        ---------------------------------------------------------------
        p_attributes_data_table.EXTEND();
        p_attributes_data_table(p_attributes_data_table.LAST) := EGO_USER_ATTR_DATA_OBJ(
                                                                   attr_rec.ROW_IDENTIFIER
                                                                  ,attr_rec.ATTR_INT_NAME
                                                                  ,attr_rec.ATTR_VALUE_STR
                                                                  ,attr_rec.ATTR_VALUE_NUM
                                                                  ,attr_rec.ATTR_VALUE_DATE
                                                                  ,attr_rec.ATTR_DISP_VALUE
								  ,null --Bug 2775504 Amanjit added parameter for argument ATTR_UNIT_OF_MEASURE
                                                                  ,attr_rec.TRANSACTION_ID
                                                                 );
      END IF;

      ------------------------------------------------------
      -- Update these variables for the next loop through --
      ------------------------------------------------------
      l_prev_loop_org_id := attr_rec.ORGANIZATION_ID;
      l_prev_loop_change_id := attr_rec.CHANGE_ID;
      l_prev_loop_row_identifier := attr_rec.ROW_IDENTIFIER;
    END LOOP;


    -----------------------------------------------------------
    -- We have to call this procedure one last time with the --
    -- data we collected in our loops for the last instance; --
    -- this time we pass p_log_errors as TRUE so we can log  --
    -- all errors accumulated through our previous loops     --
    -----------------------------------------------------------
    IF (l_can_edit_this_instance = 'T'and l_header_row_exists) THEN

      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
      (
        p_api_version                   => G_API_VERSION
       ,p_object_name                   => G_ITEM_NAME
       ,p_attributes_row_table          => p_attributes_row_table
       ,p_attributes_data_table         => p_attributes_data_table
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_index                  => l_entity_index_counter
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_debug_level                   => p_debug_level
       ,p_commit                        => FND_API.G_TRUE
       ,x_failed_row_id_list            => l_failed_row_id_buffer
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
      );


      l_header_row_exists := FALSE;
      l_prev_loop_org_id := NULL;
      l_prev_loop_change_id := NULL;
      l_prev_loop_row_identifier := NULL;

       EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Done with processing of final Change instance', 1);

      ------------------------------------------------------------------------
      -- If any rows for this instance failed, we add their ROW_IDENTIFIERs --
      -- to our master list, which we will then use to mark as errors all   --
      -- rows whose ROW_IDENTIFIERs appear in the list                      --
      ------------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        l_failed_row_id_list := l_failed_row_id_list || l_failed_row_id_buffer || ',';

      END IF;
    END IF;
     EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before calling Line loop', 1);

FOR attr_rec IN data_set_cursor_line(p_data_set_id)
    LOOP
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside Line loop', 1);
      l_line_row_exists := TRUE;

      ------------------------------------------------------
      -- Figure out whether we're starting a new instance --
      ------------------------------------------------------
      l_at_start_of_instance :=  (l_prev_loop_org_id IS NULL OR
                                  l_prev_loop_org_id <> attr_rec.ORGANIZATION_ID OR
                                  l_prev_loop_change_line_id <> attr_rec.CHANGE_LINE_ID);

      IF (l_at_start_of_instance) THEN
    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside  IF (l_at_start_of_instance) loop', 1);

        l_entity_index_counter := l_entity_index_counter + 1;

        ------------------------------------------------------------------
        -- Determine whether the current user has sufficient privileges --
        -- to update User Attribute values for the current instance; if --
        -- not, we won't process any rows for the current instance, and --
        -- we'll move on to the next instance (because the user may or  --
        -- may not have sufficient privileges on the next instance)     --
        ------------------------------------------------------------------
        l_could_edit_prev_instance := l_can_edit_this_instance;
      /*
        l_can_edit_this_instance := EGO_DATA_SECURITY.Check_Function(
                                        p_api_version                   => G_API_VERSION
                                       ,p_function                      => G_FUNCTION_NAME
                                       ,p_object_name                   => G_ITEM_NAME
                                       ,p_instance_pk1_value            => attr_rec.CHANGE_ID
                                       ,p_instance_pk2_value            => attr_rec.ORGANIZATION_ID
                                       ,p_user_name                     => G_HZ_PARTY_ID
                                    );
      */
        l_can_edit_this_instance := 'T';
        FOR ECO IN c_CheckChange(attr_rec.CHANGE_ID)
	LOOP
		IF (ECO.status_type = 5 OR ECO.status_type = 6 OR ECO.status_type = 7  OR ECO.approval_status_type = 3 OR ECO.approval_status_type = 5) THEN
        		l_can_edit_this_instance := 'F';
		END IF;
        END LOOP;

        FOR ECO IN c_CheckLine(attr_rec.CHANGE_LINE_ID)
	LOOP
		IF (ECO.status_code = 5 OR ECO.status_code = 11) THEN
        		l_can_edit_this_instance := 'F';
		END IF;
        END LOOP;
        --------------------------------------------------------------------
        -- We do an inverted IF check so that we can catch the case where --
        -- l_can_edit_this_instance is NULL and report an error message   --
        --------------------------------------------------------------------
        IF (l_can_edit_this_instance = 'T') THEN

          NULL;

        ELSE

          -------------------------------------------------------------------------
          -- Update the status of all rows for this instance to reflect the fact --
          -- that the entire instance has a security error; we would prefer to   --
          -- do this update row-by-row rather than as a manual update, because   --
          -- updating a cursor means only doing a single update when the cursor  --
          -- is released, whereas doing our own update for each failed instance  --
          -- results in a DML per instance; however, we cannot do so because our --
          -- call to Process_User_Attrs_Data includes a commit, and FOR UPDATE   --
          -- cursors can't handle commits done in mid-looping.                   --
          -------------------------------------------------------------------------

          UPDATE ENG_CHG_USR_ATR_INTERFACE
             SET PROCESS_STATUS = G_PS_ERROR
           WHERE DATA_SET_ID = p_data_set_id
             AND ORGANIZATION_ID = attr_rec.ORGANIZATION_ID
             AND CHANGE_LINE_ID = attr_rec.CHANGE_LINE_ID;

          ------------------------------------------------
          -- We add the error message once per instance --
          ------------------------------------------------
          IF (l_can_edit_this_instance = 'F') THEN

-- Bug 2779881 Changed EGO_EF_BL_NO_PRIVS_ON_INSTANCE to ENG_EF_BL_NO_PRIVS_ON_INSTANCE

            l_error_message_name := 'ENG_EF_BL_NO_PRIVS_ON_INSTANCE';

          ELSE

-- Bug 2779881 Changed EGO_EF_BL_PRIV_CHECK_ERROR to ENG_EF_BL_PRIV_CHECK_ERROR

            l_error_message_name := 'ENG_EF_BL_PRIV_CHECK_ERROR';

          END IF;

          l_token_table(1).TOKEN_NAME := 'USER_NAME';
          l_token_table(1).TOKEN_VALUE := G_USER_NAME;
          l_token_table(2).TOKEN_NAME := 'CHANGE_NUMBER';
          l_token_table(2).TOKEN_VALUE := attr_rec.CHANGE_NUMBER;
          l_token_table(3).TOKEN_NAME := 'ORG_CODE';
          l_token_table(3).TOKEN_VALUE := attr_rec.ORGANIZATION_CODE;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => l_error_message_name
           ,p_application_id                => 'ENG'
           ,p_token_tbl                     => l_token_table
           ,p_message_type                  => FND_API.G_RET_STS_ERROR
           ,p_entity_id                     => G_ENTITY_ID
           ,p_entity_index                  => l_entity_index_counter
           ,p_entity_code                   => G_ENTITY_CODE
          );

        END IF;

        ------------------------------------------------------------------
        -- The VERY first loop through, we want to build arrays for the --
        -- Primary Key columns and the Classification Code columns; for --
        -- every subsequent instance, we just update the values.        --
        -- We also build Attr Row and Attr Data tables the first time   --
        -- through, which we then clear out (rather than re-allocating) --
        -- at the start of all subsequent instances.                    --
        -----------------------------------------------------------------
           G_ITEM_NAME := 'ENG_CHANGE_LINE';
        IF (l_prev_loop_org_id IS NULL ) THEN

  EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside setting  p_line_pk_col_name_value_pairs', 1);

         p_line_pk_col_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_LINE_ID', attr_rec.CHANGE_LINE_ID)
                                          );

          p_line_class_code_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                             EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_TYPE_ID', attr_rec.CHANGE_TYPE_ID)

                                           );
EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside intilizing attribute and data table ', 1);
          p_line_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
          p_line_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();

        ELSE

          IF (l_could_edit_prev_instance = 'T') THEN

            -------------------------------------------------------------------------
            -- Since this is the start of an instance other than the first, we are --
            -- ready to process the data we've collected for the previous instance --
            -- (note that since we're always calling for the previous instance, we --
            -- will need one final call after we're done looping through all rows; --
            -- note also that we make sure the user passed the security check)     --
            -------------------------------------------------------------------------
EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside process the data  collected for the previous instance ', 1);
            EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
            (
              p_api_version                   => G_API_VERSION
             ,p_object_name                   => G_ITEM_NAME
             ,p_attributes_row_table          => p_line_attributes_row_table
             ,p_attributes_data_table         => p_line_attributes_data_table
             ,p_pk_column_name_value_pairs    => p_line_pk_col_name_value_pairs
             ,p_class_code_name_value_pairs   => p_line_class_code_value_pairs
             ,p_entity_id                     => G_ENTITY_ID
             ,p_entity_index                  => l_entity_index_counter
             ,p_entity_code                   => G_ENTITY_CODE
             ,p_debug_level                   => p_debug_level
             ,p_commit                        => FND_API.G_TRUE
             ,x_failed_row_id_list            => l_failed_row_id_buffer
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data
            );

            ------------------------------------------------------------------------
            -- If any rows for this instance failed, we add their ROW_IDENTIFIERs --
            -- to a master list that we will eventually use to mark as errors all --
            -- rows whose ROW_IDENTIFIERs appear in the list                      --
            ------------------------------------------------------------------------
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

              l_failed_row_id_list := l_failed_row_id_list || l_failed_row_id_buffer || ',';

            END IF;
          END IF;

          ------------------------------------------------------------------
          -- Now we update the Primary Key and Classification Code column --
          -- values, and we clear out the Attr Row and Attr Data tables   --
          ------------------------------------------------------------------
         EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside updating Primary key and classification ', 1);

          p_line_pk_col_name_value_pairs(1).VALUE := attr_rec.CHANGE_LINE_ID;

EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside updating value_pairs(1)iCHANGE_LINE_ID ', 1);
          -- p_line_pk_col_name_value_pairs(2).VALUE := attr_rec.ORGANIZATION_ID;

EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside updating value_pairs(2) ORGANIZATION_ID ', 1);
          p_line_class_code_value_pairs(1).VALUE := attr_rec.CHANGE_TYPE_ID;

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac inside deleting attribute and data tables ', 1);

          p_line_attributes_row_table.DELETE;
          p_line_attributes_data_table.DELETE;
        END IF;
      END IF;

      IF (l_can_edit_this_instance = 'T') THEN
        -----------------------------------------------------
        -- Figure out whether we're now starting a new row --
        -----------------------------------------------------
        l_at_start_of_row := (l_prev_loop_row_identifier IS NULL OR
                              l_prev_loop_row_identifier <> attr_rec.ROW_IDENTIFIER OR
                              l_prev_loop_change_line_id <> attr_rec.CHANGE_LINE_ID);

        -------------------------------------------
        -- Build an Attr Row Object for each row --
        -------------------------------------------
        IF (l_at_start_of_row) THEN
     EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac Before extending the attributes_row_table :',3);

          p_line_attributes_row_table.EXTEND();
 EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac after extending the attributes_row_table :',3);

           p_line_attributes_row_table(p_line_attributes_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(
                                                                   attr_rec.ROW_IDENTIFIER
                                                                  ,attr_rec.ATTR_GROUP_ID
                                                                  ,703
                                                                  ,'ENG_LINEMGMT_GROUP'
                                                                  ,attr_rec.ATTR_GROUP_INT_NAME
                                                                  ,null
                                                                  ,null
                                                                  ,null
								  ,null
                                                                  ,null
                                                                  ,null                                           ,attr_rec.TRANSACTION_TYPE
                                                                 );

        END IF;

        ---------------------------------------------------------------
        -- Add an Attr Data object to the Attr Data table every time --
        ---------------------------------------------------------------
          EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before extending attribute tabl ', 1);

        p_line_attributes_data_table.EXTEND();
EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before after attribute tabl ', 1);
        p_line_attributes_data_table(p_line_attributes_data_table.LAST) := EGO_USER_ATTR_DATA_OBJ(
                                                                   attr_rec.ROW_IDENTIFIER
                                                                  ,attr_rec.ATTR_INT_NAME
                                                                  ,attr_rec.ATTR_VALUE_STR
                                                                  ,attr_rec.ATTR_VALUE_NUM
                                                                  ,attr_rec.ATTR_VALUE_DATE
                                                                  ,attr_rec.ATTR_DISP_VALUE
								  ,null --Bug 2775504 Amanjit added parameter for argument ATTR_UNIT_OF_MEASURE
                                                                  ,attr_rec.TRANSACTION_ID
                                                                 );
      END IF;

      ------------------------------------------------------
      -- Update these variables for the next loop through --
      ------------------------------------------------------
      l_prev_loop_org_id := attr_rec.ORGANIZATION_ID;
      l_prev_loop_change_line_id := attr_rec.CHANGE_LINE_ID;
      l_prev_loop_row_identifier := attr_rec.ROW_IDENTIFIER;

EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before end  of line loop', 1);
    END LOOP;


    -----------------------------------------------------------
    -- We have to call this procedure one last time with the --
    -- data we collected in our loops for the last instance; --
    -- this time we pass p_log_errors as TRUE so we can log  --
    -- all errors accumulated through our previous loops     --
    -----------------------------------------------------------
    IF (l_can_edit_this_instance = 'T'AND l_line_row_exists ) THEN
       EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Sac before final calling :',3);


      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
      (
        p_api_version                   => G_API_VERSION
       ,p_object_name                   => G_ITEM_NAME
       ,p_attributes_row_table          => p_line_attributes_row_table
       ,p_attributes_data_table         => p_line_attributes_data_table
       ,p_pk_column_name_value_pairs    => p_line_pk_col_name_value_pairs
       ,p_class_code_name_value_pairs   => p_line_class_code_value_pairs
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_index                  => l_entity_index_counter
       ,p_entity_code                   => G_ENTITY_CODE
       ,p_debug_level                   => p_debug_level
       ,p_commit                        => FND_API.G_TRUE
       ,x_failed_row_id_list            => l_failed_row_id_buffer
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
      );

      l_line_row_exists := FALSE;
      l_prev_loop_org_id := NULL;
      l_prev_loop_change_line_id := NULL;
      l_prev_loop_row_identifier := NULL;



      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Done with processing of final line instance', 1);

      ------------------------------------------------------------------------
      -- If any rows for this instance failed, we add their ROW_IDENTIFIERs --
      -- to our master list, which we will then use to mark as errors all   --
      -- rows whose ROW_IDENTIFIERs appear in the list                      --
      ------------------------------------------------------------------------
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

        l_failed_row_id_list := l_failed_row_id_list || l_failed_row_id_buffer || ',';

      END IF;
    END IF;

    IF (LENGTH(l_failed_row_id_list) > 0) THEN

      -----------------------------------------------------------------------
      -- Strip off any trailing ',' from the failed ROW_IDENTIFIER list... --
      -----------------------------------------------------------------------
      l_failed_row_id_list := SUBSTR(l_failed_row_id_list, 1, LENGTH(l_failed_row_id_list) - LENGTH(','));

      EGO_USER_ATTRS_DATA_PVT.Debug_Msg('List of all ROW_IDENTIFIERs that failed: '||l_failed_row_id_list, 3);

      ---------------------------------------------------------------
      -- ...and then use it to mark as errors all rows in the list --
      -- (note that we have to use dynamic SQL because 1). static  --
      -- SQL treats the failed Row ID list as a string instead of  --
      -- a list of numbers, and 2). bulk-binding would cause us to --
      -- execute one SQL statement per failed Row ID.  Dynamic SQL --
      -- only executes one SQL statement for a given call to our   --
      -- concurrent program--so the fact that our failed Row IDs   --
      -- aren't passed as a bind variable doesn't matter, because  --
      -- the statement won't get parsed more than once anyway).    --
      ---------------------------------------------------------------
      l_dynamic_sql := 'UPDATE ENG_CHG_USR_ATR_INTERFACE'||
                         ' SET PROCESS_STATUS = '|| G_PS_ERROR ||
                       ' WHERE DATA_SET_ID = :1'||
                         ' AND ROW_IDENTIFIER IN ('|| l_failed_row_id_list || ')';

      EXECUTE IMMEDIATE l_dynamic_sql USING p_data_set_id;

    END IF;

    IF (FND_API.To_Boolean(p_purge_successful_lines)) THEN
      -----------------------------------------------
      -- Delete all successful rows from the table --
      -- (they're the only rows still in process)  --
      -----------------------------------------------
      DELETE FROM ENG_CHG_USR_ATR_INTERFACE
       WHERE DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS;
    ELSE
      ----------------------------------------------
      -- Mark all rows we've processed as success --
      -- if they weren't marked as failure above  --
      ----------------------------------------------
      UPDATE ENG_CHG_USR_ATR_INTERFACE
         SET PROCESS_STATUS = G_PS_SUCCESS
       WHERE DATA_SET_ID = p_data_set_id
         AND PROCESS_STATUS = G_PS_IN_PROCESS;
    END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Done with Change Concurrent Program', 1);

    -------------------------------------------------------------------
    -- Finally, we log any errors that we've accumulated throughout  --
    -- our conversions and looping (including all errors encountered --
    -- within our Business Object's processing)                      --
    -------------------------------------------------------------------
    ERROR_HANDLER.Log_Error(
      p_write_err_to_inttable         => 'Y'
     ,p_write_err_to_conclog          => 'Y'
     ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
    );

    COMMIT WORK;

  EXCEPTION
    WHEN G_NO_USER_NAME_TO_VALIDATE THEN

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_EF_NO_NAME_TO_VALIDATE'
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE
      );

      ---------------------------------------------------------------
      -- No matter what the error, we want to make sure everything --
      -- we've logged gets to the appropriate error locations      --
      ---------------------------------------------------------------
      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable         => 'Y'
       ,p_write_err_to_conclog          => 'Y'
       ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug()
      );

    WHEN OTHERS THEN

      ERROR_HANDLER.Add_Error_Message(
        p_message_text                  => 'Unexpected error in '||G_PKG_NAME||'.Process_Change_User_Attrs_Data: '||SQLERRM
       ,p_application_id                => 'EGO'
       ,p_message_type                  => FND_API.G_RET_STS_ERROR
       ,p_entity_id                     => G_ENTITY_ID
       ,p_entity_code                   => G_ENTITY_CODE);

      ---------------------------------------------------------------
      -- No matter what the error, we want to make sure everything --
      -- we've logged gets to the appropriate error locations      --
      ---------------------------------------------------------------
      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable         => 'Y'
       ,p_write_err_to_conclog          => 'Y'
       ,p_write_err_to_debugfile        => ERROR_HANDLER.Get_Debug());

END Process_Change_User_Attrs_Data;

----------------------------------------------------------------------
FUNCTION Get_Current_Data_Set_Id
RETURN NUMBER
IS

    l_curr_data_set_id       NUMBER;

  BEGIN

    --------------------------------------------------------------------------
    -- This function returns the current value of the Data Set ID sequence; --
    -- if the sequence doesn't yet have a value this session, we make one   --
    --------------------------------------------------------------------------
    SELECT EGO_IUA_DATA_SET_ID_S.CURRVAL INTO l_curr_data_set_id FROM DUAL;
    RETURN l_curr_data_set_id;

  EXCEPTION
    WHEN G_NO_CURRVAL_YET THEN

      SELECT ENG_CUA_DATA_SET_ID_S.NEXTVAL INTO l_curr_data_set_id FROM DUAL;
      RETURN l_curr_data_set_id;

END Get_Current_Data_Set_Id;
----------------------------------------------------------------------
PROCEDURE Process_Change_User_Attrs
      (
        p_api_version                   IN NUMBER := 1.0   --bug 2775504 Amanjit p_api_version  Defaulted to 1.0 earlier value was G_API_VERSION
        ,   p_init_msg_list             IN BOOLEAN := FALSE
        ,   x_return_status             OUT NOCOPY VARCHAR2
        ,   x_msg_count                 OUT NOCOPY NUMBER
        ,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
        ,   p_change_number                IN VARCHAR2
        ,   p_change_mgmt_type_code        IN VARCHAR2
        ,   p_Organization_Code            IN VARCHAR2
        ,   p_attributes_row_table         IN EGO_USER_ATTR_ROW_TABLE
        ,   p_attributes_data_table        IN EGO_USER_ATTR_DATA_TABLE
        ,   p_debug                     IN  VARCHAR2 := 'N'
        ,   p_output_dir                IN  VARCHAR2 := NULL
        ,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
      ) IS

    l_entity_index_counter   NUMBER := 1;
    l_change_id              NUMBER;
    l_change_type_id        NUMBER;
    l_can_edit_this_instance VARCHAR2(1);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_failed_row_id_buffer   VARCHAR2(32767);
    l_failed_row_id_list     VARCHAR2(32767);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_dynamic_sql            VARCHAR2(32767);
    p_debug_level            NUMBER := 3;
    l_attr_row_table   EGO_USER_ATTR_ROW_TABLE;

 cursor chg_csr is
         select EEC.CHANGE_ID,EEC.CHANGE_ORDER_TYPE_ID
         from ENG_ENGINEERING_CHANGES EEC,MTL_PARAMETERS MP
         where EEC.CHANGE_MGMT_TYPE_CODE = p_change_mgmt_type_code
         AND EEC.CHANGE_NOTICE = p_change_number
         AND MP.ORGANIZATION_CODE = p_Organization_Code
         AND EEC.ORGANIZATION_ID = MP.ORGANIZATION_ID;

BEGIN
 -----------------------------------------------
    -- Set this global variable once per session --
    -----------------------------------------------
    IF (G_HZ_PARTY_ID IS NULL) THEN
      IF (G_USER_NAME IS NOT NULL) THEN

      SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
        INTO G_HZ_PARTY_ID
        FROM EGO_PEOPLE_V
       WHERE USER_NAME = G_USER_NAME;

      ELSE

        RAISE G_NO_USER_NAME_TO_VALIDATE;

      END IF;
    END IF;
                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

    ERROR_HANDLER.Initialize();
    ERROR_HANDLER.Set_Bo_Identifier(p_bo_identifier);


 -----------------------------------------------------------
    -- If we're debugging, we have to set up a Debug session --
    -----------------------------------------------------------
    IF (p_debug_level > 0) THEN

      EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(G_ENTITY_ID, G_ENTITY_CODE);

    END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Instance Program', 1);


          OPEN chg_csr;
          FETCH chg_csr INTO l_change_id,l_change_type_id;

       if (chg_csr%NOTFOUND) then

          RAISE G_NO_CHANGE_TO_VALIDATE;
       else
          G_ITEM_NAME := 'ENG_CHANGE';

         p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_ID', l_change_id));

          p_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                             EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_TYPE_ID', l_change_type_id)
                                           );
	  -- customer needs to populate ROW_IDENTIFIER,ATTR_GROUP_NAME,TRANSACTION_TYPE
	  -- attributes.
	  IF (p_attributes_row_table IS NOT NULL) THEN
          l_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
	  FOR i IN 1..p_attributes_row_table.COUNT LOOP
		l_attr_row_table.EXTEND();
          	l_attr_row_table(i) := EGO_USER_ATTR_ROW_OBJ(
                                                                   p_attributes_row_table(i).ROW_IDENTIFIER
                                                                  ,p_attributes_row_table(i).ATTR_GROUP_ID
                                                                  ,703
                                                                  ,'ENG_CHANGEMGMT_GROUP'
                                                                  ,p_attributes_row_table(i).ATTR_GROUP_NAME
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null           ,p_attributes_row_table(i).TRANSACTION_TYPE
                                                                 );
	  END LOOP;
	  END IF;

 EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
            (
              p_api_version                   => p_api_version
             ,p_object_name                   => G_ITEM_NAME
             ,p_attributes_row_table          => l_attr_row_table
             ,p_attributes_data_table         => p_attributes_data_table
             ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
             ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
             ,p_entity_id                     => G_ENTITY_ID
             ,p_entity_index                  => l_entity_index_counter
             ,p_entity_code                   => G_ENTITY_CODE
             ,p_debug_level                   => p_debug_level
             ,p_commit                        => FND_API.G_TRUE
             ,x_failed_row_id_list            => l_failed_row_id_buffer
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data
            );
     END IF;

END Process_Change_User_Attrs;

PROCEDURE Process_Change_Line_User_Attrs
      (
        p_api_version                   IN NUMBER := 1.0 --bug 2775504 Amanjit p_api_version Defaulted to 1.0 earlier value was G_API_VERSION
        ,   p_init_msg_list             IN  BOOLEAN := FALSE
        ,   x_return_status             OUT NOCOPY VARCHAR2
        ,   x_msg_count                 OUT NOCOPY NUMBER
        ,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
        ,p_change_number                IN VARCHAR2
        ,p_change_mgmt_type_code        IN VARCHAR2
        ,p_Organization_Code            IN VARCHAR2
        ,p_change_line_sequence_number  IN NUMBER
        ,p_attributes_row_table         IN EGO_USER_ATTR_ROW_TABLE
        ,p_attributes_data_table        IN EGO_USER_ATTR_DATA_TABLE
        ,   p_debug                     IN  VARCHAR2 := 'N'
        ,   p_output_dir                IN  VARCHAR2 := NULL
        ,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
      ) IS

    l_entity_index_counter   NUMBER := 1;
    l_change_line_id        NUMBER;
    l_change_type_id        NUMBER;
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_can_edit_this_instance VARCHAR2(1);
    p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    p_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_failed_row_id_buffer   VARCHAR2(32767);
    l_failed_row_id_list     VARCHAR2(32767);
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(1000);
    l_dynamic_sql            VARCHAR2(32767);
    p_debug_level            NUMBER := 3;
    l_attr_row_table   EGO_USER_ATTR_ROW_TABLE;

 cursor chgline_csr is
         select EEV.CHANGE_LINE_ID,EEV.CHANGE_TYPE_ID
         from ENG_CHANGE_LINES EEV,ENG_ENGINEERING_CHANGES EEC,MTL_PARAMETERS MP
         where EEC.CHANGE_ID = EEV.CHANGE_ID
         AND EEC.CHANGE_NOTICE = p_change_number
         AND MP.ORGANIZATION_CODE = p_Organization_Code
         AND EEC.ORGANIZATION_ID = MP.ORGANIZATION_ID
         AND EEV.SEQUENCE_NUMBER = p_change_line_sequence_number;
BEGIN
 -----------------------------------------------
    -- Set this global variable once per session --
    -----------------------------------------------
    IF (G_HZ_PARTY_ID IS NULL) THEN
      IF (G_USER_NAME IS NOT NULL) THEN

      SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
        INTO G_HZ_PARTY_ID
        FROM EGO_PEOPLE_V
       WHERE USER_NAME = G_USER_NAME;

      ELSE

        RAISE G_NO_USER_NAME_TO_VALIDATE;

      END IF;
    END IF;
                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

    ERROR_HANDLER.Initialize();
    ERROR_HANDLER.Set_Bo_Identifier(p_bo_identifier);


 -----------------------------------------------------------
    -- If we're debugging, we have to set up a Debug session --
    -----------------------------------------------------------
    IF (p_debug_level > 0) THEN

      EGO_USER_ATTRS_DATA_PVT.Set_Up_Debug_Session(G_ENTITY_ID, G_ENTITY_CODE);

    END IF;

    EGO_USER_ATTRS_DATA_PVT.Debug_Msg('Starting Change Line Instance Program', 1);


          OPEN chgline_csr;
          FETCH chgline_csr INTO l_change_line_id,l_change_type_id;

       if (chgline_csr%NOTFOUND) then

          RAISE G_NO_CHANGE_TO_VALIDATE;
       else
          G_ITEM_NAME := 'ENG_CHANGE_LINE';

         p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                            EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_LINE_ID', l_change_line_id)
                                          );

          p_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                             EGO_COL_NAME_VALUE_PAIR_OBJ('CHANGE_TYPE_ID', l_change_type_id)
                                           );

	  -- customer needs to populate ROW_IDENTIFIER,ATTR_GROUP_NAME,TRANSACTION_TYPE
	  -- attributes.
	  IF (p_attributes_row_table IS NOT NULL) THEN
          l_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
	  FOR i IN 1..p_attributes_row_table.COUNT LOOP
		l_attr_row_table.EXTEND();
          	l_attr_row_table(i) := EGO_USER_ATTR_ROW_OBJ(
                                                                   p_attributes_row_table(i).ROW_IDENTIFIER
                                                                  ,p_attributes_row_table(i).ATTR_GROUP_ID
                                                                  ,703
                                                                  ,'ENG_LINEMGMT_GROUP'
                                                                  ,p_attributes_row_table(i).ATTR_GROUP_NAME
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null
                                                                  ,null           ,p_attributes_row_table(i).TRANSACTION_TYPE
                                                                 );
	  END LOOP;
	  END IF;
 EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
            (
              p_api_version                   => p_api_version
             ,p_object_name                   => G_ITEM_NAME
             ,p_attributes_row_table          => l_attr_row_table
             ,p_attributes_data_table         => p_attributes_data_table
             ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
             ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
             ,p_entity_id                     => G_ENTITY_ID
             ,p_entity_index                  => l_entity_index_counter
             ,p_entity_code                   => G_ENTITY_CODE
             ,p_debug_level                   => p_debug_level
             ,p_commit                        => FND_API.G_TRUE
             ,x_failed_row_id_list            => l_failed_row_id_buffer
             ,x_return_status                 => l_return_status
             ,x_errorcode                     => l_errorcode
             ,x_msg_count                     => l_msg_count
             ,x_msg_data                      => l_msg_data
            );
     END IF;

END Process_Change_Line_User_Attrs;
---------------------------------------------------------------
-- Check before deleting an attribute group assoc ----
---------------------------------------------------------------
--Begin of Bug:3070807
PROCEDURE Check_Delete_Associations
(
    p_api_version                   IN      NUMBER
   ,p_association_id                IN      NUMBER
	 ,p_classification_code           IN      VARCHAR2
	 ,p_data_level                    IN      VARCHAR2
	 ,p_attr_group_id                 IN      NUMBER
	 ,p_application_id                IN      NUMBER
	 ,p_attr_group_type               IN      VARCHAR2
	 ,p_attr_group_name               IN      VARCHAR2
	 ,p_enabled_code                  IN      VARCHAR2
	 ,p_init_msg_list				          IN      VARCHAR2   := fnd_api.g_FALSE
	 ,x_ok_to_delete                  OUT     NOCOPY VARCHAR2
	 ,x_return_status           			OUT     NOCOPY VARCHAR2
	 ,x_errorcode               			OUT     NOCOPY NUMBER
	 ,x_msg_count               			OUT     NOCOPY NUMBER
   ,x_msg_data 			                OUT     NOCOPY VARCHAR2
)
IS

   l_api_version  					CONSTANT NUMBER           := 1.0;
   l_count        					NUMBER;
   l_api_name     					CONSTANT VARCHAR2(30)     := 'Check_Delete';
   l_message      					VARCHAR2(4000);
   l_attr_group_id 				        VARCHAR2(40);
   l_dynamic_sql 					VARCHAR2(2000);
   l_attr_display_name	             		        VARCHAR2(250);



  BEGIN



    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT
    	attr_group_disp_name INTO l_attr_display_name
    FROM
    	ego_obj_attr_grp_assocs_v
    WHERE association_id =  p_association_id;

    --Check if there are any entries for in EGO_PAGE_ENTRIES_V
    SELECT
      COUNT(*) INTO l_count
    FROM
      EGO_PAGE_ENTRIES_V
    WHERE
      ASSOCIATION_ID = p_association_id;

		IF (l_count > 0)
    THEN
      x_ok_to_delete := FND_API.G_FALSE;
      l_message := 'EGO_ASSOCIATED_AG_IN_USE';
      FND_MESSAGE.Set_Name(g_app_name, l_message);
      FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
			FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

		IF (l_count = 0) THEN
		 l_attr_group_id := '''' || p_attr_group_id || '%''';
		 -- check if this ag is used to create any search criterias

		 l_dynamic_sql := ' SELECT COUNT(*) ' ||
		   							  ' FROM ' ||
										  ' AK_CRITERIA cols, ' ||
   									  ' EGO_CRITERIA_TEMPLATES_V criterions ' ||
										  ' WHERE cols.customization_code = criterions.customization_code ' ||
										  ' AND criterions.classification1 = :1 ' ||
										  ' AND   cols.attribute_code LIKE :2'  ;
		 -- BUG 5097794 Replaced LITERALS with BINDS
		 EXECUTE IMMEDIATE l_dynamic_sql INTO l_count USING p_classification_code , l_attr_group_id||'%'  ;
				 IF (l_count > 0)
		 THEN
		   x_ok_to_delete := FND_API.G_FALSE;
		   l_message := 'EGO_ASSOCIATED_AG_IN_USE';
		   FND_MESSAGE.Set_Name(g_app_name, l_message);
		   FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
		   FND_MSG_PUB.Add;
		   x_return_status := FND_API.G_RET_STS_ERROR;
		 END IF;
    	         IF (l_count = 0) THEN
		   -- check if this ag is used to create any result formats
		   l_dynamic_sql := ' SELECT COUNT(*) ' ||
		   								  ' FROM ' ||
										    ' EGO_RESULTS_FORMAT_COLUMNS_V cols, ' ||
   									    ' EGO_RESULTS_FORMAT_V resultFormat ' ||
										    ' WHERE cols.customization_code = resultFormat.customization_code ' ||
										    ' AND   resultFormat.classification1 = :1' ||
										    ' AND   cols.attribute_code LIKE :2' ;

		   -- BUG 5097794 Replaced LITERALS with BINDS
       EXECUTE IMMEDIATE l_dynamic_sql INTO l_count USING p_classification_code , l_attr_group_id||'%'  ;

		   IF (l_count > 0)
		   THEN
		     x_ok_to_delete := FND_API.G_FALSE;
		     l_message := 'EGO_ASSOCIATED_AG_IN_USE';
		   	 FND_MESSAGE.Set_Name(g_app_name, l_message);
		   	 FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
		     FND_MSG_PUB.Add;
		     x_return_status := FND_API.G_RET_STS_ERROR;
		   END IF;
		 END IF; --if no search criteria exist
	 END IF; -- no page entry exist
		FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
    );

    IF (l_message IS NULL) THEN
        	  x_return_status := FND_API.G_RET_STS_SUCCESS;
		  x_ok_to_delete := FND_API.G_TRUE;
		END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_ok_to_delete := FND_API.G_FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;


END Check_Delete_Associations;
--End  of Bug:3070807


END EGO_CHANGE_USER_ATTRS_PUB;


/

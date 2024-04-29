--------------------------------------------------------
--  DDL for Package Body EGO_FUNCTIONS_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_FUNCTIONS_BULKLOAD_PVT" AS
/* $Header: EGOVFNBB.pls 120.0.12010000.7 2010/05/17 12:48:59 snandana noship $ */

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: write_debug                                                             --
  -- This procedure will log debug messages to the Concurrent Request log file.              --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- message: Debug message to be logged                                                     --
  ---------------------------------------------------------------------------------------------
  PROCEDURE write_debug(message VARCHAR2)
  IS
  BEGIN
    --Following commented statement is to print debug messages, while testing/debugging this package standalone.
    --dbms_output.Put_line('DEBUG: '
    --                     ||message);
    ego_metadata_bulkload_pvt.write_debug(message);

  END;

  --Following commented procedure is to print error messages, while testing/debugging this package standalone.
  --PROCEDURE Log_error(message VARCHAR2)
  --IS
  --BEGIN
    --dbms_output.Put_line('ERROR: '
    --                     ||message);
  --END;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: import_functions_intf                                                   --
  -- This is the main procedure that will be called while running Matadata Import Concurrent --
  -- Program, to process Functions and Function Parameters.                                  --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) to be      --
  --                   processed in a batch.                                                 --
  -- OUT                                                                                     --
  -- x_return_status:  Return status. Can be S or U (Unexpected Error).                      --
  -- x_return_msg:     Stores the error message, if unexpected error occurs.                 --
  ---------------------------------------------------------------------------------------------
  PROCEDURE import_functions_intf(p_set_process_id IN NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_return_msg   OUT  NOCOPY VARCHAR2) IS
  l_proc_name VARCHAR2(30) := 'import_functions_intf';
  BEGIN
   write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   --Following commented statement is to initialize global message list, while testing/debugging this package standalone.
   --ERROR_HANDLER.Initialize();
   process_functions_conc_flow(p_set_process_id);
   process_func_params_conc_flow(p_set_process_id);
   --Following commented procedure call is to write errors to mtl_interfce_errors table,
   --while testing/debugging this package standalone.
   --ERROR_HANDLER.Log_Error(
   --     p_write_err_to_inttable         => 'Y'
   --    ,p_write_err_to_conclog          => 'Y');
   write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  EXCEPTION
   WHEN OTHERS THEN
        x_return_msg := G_PCK_NAME||'.'||l_proc_name||'->'||' Unexpected error occurred: '||SQLERRM;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
  END import_functions_intf;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: delete_processed_functions                                              --
  -- This procedure will be called at end by Matadata Import Concurrent Program,             --
  -- to delete processed rows from Functions and Function Parameters interface tables.       --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) that       --
  --                   belongs to a particular batch.                                        --
  -- OUT                                                                                     --
  -- x_return_status:  Return status. Can be S or U (Unexpected Error).                      --
  -- x_return_msg:     Stores the error message, if unexpected error occurs.                 --
  ---------------------------------------------------------------------------------------------
  /* Bug 9653987. Update x_return_status and x_return_msg to send them back to the calling function. */
  PROCEDURE delete_processed_functions(p_set_process_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_return_msg   OUT  NOCOPY VARCHAR2) IS
  l_proc_name VARCHAR2(30) := 'delete_processed_functions';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    x_return_status := fnd_api.G_RET_STS_SUCCESS;
    DELETE FROM ego_functions_interface WHERE (p_set_process_id IS NULL OR set_process_id=p_set_process_id)
                                        AND process_status=G_SUCCESS_RECORD;
    DELETE FROM ego_func_params_interface WHERE (p_set_process_id IS NULL OR set_process_id=p_set_process_id)
                                        AND process_status=G_SUCCESS_RECORD;
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  EXCEPTION
   WHEN OTHERS THEN
        x_return_msg := G_PCK_NAME||'.'||l_proc_name||'->'||' Unexpected error occurred: '||SQLERRM;
        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
  END delete_processed_functions;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: construct_function                                                      --
  -- This procedure will validate transaction type and the key columns that can identify     --
  -- a function and also converts SYNC transaction to either CREATE or UPDATE,               --
  -- if the validation succeeds.                                                             --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE construct_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE) IS
  invalid_function_id     NUMBER(1);
  invalid_internal_name   NUMBER(1);
  l_proc_name VARCHAR2(30) := 'construct_function';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    IF (func_header_rec.transaction_type IS NULL
          OR (func_header_rec.transaction_type <> G_CREATE_TRANSACTION
          AND func_header_rec.transaction_type <> G_UPDATE_TRANSACTION
          AND func_header_rec.transaction_type <> G_DELETE_TRANSACTION
          AND func_header_rec.transaction_type <> G_SYNC_TRANSACTION)) THEN
	      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Invalid Transaction Type.');
              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_TRANS_TYPE'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );
          func_header_rec.process_status:=G_ERROR_RECORD;
    END IF;

    /* Convert SYNC to CREATE/UPDATE. Validate function_id and internal_name for SYNC, UPDATE and DELETE transaction types. */
        IF ( func_header_rec.transaction_type = G_UPDATE_TRANSACTION
              OR func_header_rec.transaction_type = G_SYNC_TRANSACTION
              OR func_header_rec.transaction_type = G_DELETE_TRANSACTION ) THEN
          IF ( func_header_rec.function_id IS NOT NULL ) THEN
            BEGIN
                invalid_function_id := 0;

                SELECT internal_name
                INTO   func_header_rec.internal_name
                FROM   ego_functions_b
                WHERE  ( function_id = func_header_rec.function_id );
            EXCEPTION
                WHEN no_data_found THEN
                  invalid_function_id := 1;
            END;
            IF (invalid_function_id=1) THEN
               IF (func_header_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                   func_header_rec.transaction_type:=G_CREATE_TRANSACTION;
               ELSE
                --Log_error('Invalid Function ID.');
		write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Invalid Function ID.');
                ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_EF_FUNC_ID_ERR'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );
               func_header_rec.process_status:=G_ERROR_RECORD;
               END IF;
            ELSE
               IF (func_header_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                 func_header_rec.transaction_type:=G_UPDATE_TRANSACTION;
               END IF;
            END IF;
          ELSIF ( func_header_rec.internal_name IS NOT NULL ) THEN
            BEGIN
                invalid_internal_name := 0;

                SELECT function_id
                INTO   func_header_rec.function_id
                FROM   ego_functions_b
                WHERE  ( internal_name = func_header_rec.internal_name );
            EXCEPTION
                WHEN no_data_found THEN
                  invalid_internal_name := 1;
            END;
            IF (invalid_internal_name=1) THEN
                IF (func_header_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                    func_header_rec.transaction_type:=G_CREATE_TRANSACTION;
                ELSE
                    --Log_error('Invalid Function Internal Name.');
		    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Invalid Function Internal Name.');
                    ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_INT_NAME_INVL'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_header_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN
                    ,p_table_name                    => G_FUNCTIONS_TAB
                    );
                    func_header_rec.process_status:=G_ERROR_RECORD;
                END IF;
            ELSE
                IF (func_header_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                    func_header_rec.transaction_type:=G_UPDATE_TRANSACTION;
                END IF;
            END IF;
          ELSE
            --Log_error('Either Function ID or Internal Name must be provided.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Either Function ID or Internal Name must be provided.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_ID_INT_NAME_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_header_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN
                    ,p_table_name                    => G_FUNCTIONS_TAB
                    );
            func_header_rec.process_status := G_ERROR_RECORD;
          END IF;
        END IF;
	write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END construct_function;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: validate_function                                                       --
  -- This procedure will perform the remaining validations (excluding the validations done   --
  -- on key columns in construct_function) based on the transaction type.                    --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE validate_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE) IS
  temporary_record        ego_functions_b%ROWTYPE;
  temporary_record_tl     ego_functions_tl%ROWTYPE;
  valid_function_type     NUMBER(1);
  duplicate_internal_name NUMBER(1);
  function_is_used        NUMBER(1);
  error_count NUMBER;
  l_proc_name VARCHAR2(30) := 'validate_function';

  l_token_table            ERROR_HANDLER.Token_Tbl_Type;
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    /* Validations for CREATE transaction type. */
        IF ( func_header_rec.transaction_type = G_CREATE_TRANSACTION
             AND func_header_rec.process_status <> G_ERROR_RECORD ) THEN
          /* 1. Validating Function Type. */
          IF ( func_header_rec.function_type IS NOT NULL ) THEN
            BEGIN
                SELECT 1
                INTO   valid_function_type
                FROM   fnd_lookup_values
                WHERE  ( lookup_type = 'EGO_EF_FUNCTION_TYPE'
                         AND language = Userenv('LANG')
                         AND lookup_code = func_header_rec.function_type );
            EXCEPTION
                WHEN no_data_found THEN
                  valid_function_type := 0;
            END;
            IF (valid_function_type=0) THEN
               --Log_error('Invalid Function Type.');
	       write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Invalid Function Type.');
               ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_TYPE_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_header_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN
                    ,p_table_name                    => G_FUNCTIONS_TAB
                    );
               func_header_rec.process_status:=G_ERROR_RECORD;
            END IF;
          END IF;

          /* 2. Validation of all mandatory columns. */
          IF ( func_header_rec.internal_name IS NULL
                OR func_header_rec.display_name IS NULL
                OR func_header_rec.function_info_1 IS NULL
                OR func_header_rec.function_type IS NULL
                OR ( ( func_header_rec.function_type = 'J'
                        OR func_header_rec.function_type = 'P' )
                     AND func_header_rec.function_info_2 IS NULL ) ) THEN
            --Log_error('One of the mandatory columns is missed.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): One of the mandatory columns is missed.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_REQ_COLS_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_header_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN
                    ,p_table_name                    => G_FUNCTIONS_TAB
                    );
            func_header_rec.process_status := G_ERROR_RECORD;
          END IF;

          /* 3. Make sure that Function Internal Name is unique. */
          BEGIN
              SELECT 1
              INTO   duplicate_internal_name
              FROM   ego_functions_b
              WHERE  ( internal_name = func_header_rec.internal_name );
          EXCEPTION
              WHEN no_data_found THEN
                duplicate_internal_name := 0;
          END;

          IF ( duplicate_internal_name = 1 ) THEN
            --Log_error('Duplicate Function Internal Name.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Duplicate Function Internal Name.');
            ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_EF_FUNC_INT_NAME_ERR'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );

            func_header_rec.process_status := G_ERROR_RECORD;
          END IF;

        /* Validations for UPDATE transaction type. */
        ELSIF ( func_header_rec.transaction_type = G_UPDATE_TRANSACTION
                AND func_header_rec.process_status <> G_ERROR_RECORD ) THEN
          /* Fetch the existing data from base tables and merge it with interface table row func_header_rec. */
          SELECT *
          INTO   temporary_record
          FROM   ego_functions_b
          WHERE  ( function_id = func_header_rec.function_id );

          SELECT *
          INTO   temporary_record_tl
          FROM   ego_functions_tl
          WHERE  ( function_id = func_header_rec.function_id )
                 AND language = Userenv('LANG');

          /* 1. Validating Function Type. */
          IF ( func_header_rec.function_type IS NULL ) THEN
            func_header_rec.function_type := temporary_record.function_type;
          ELSIF ( func_header_rec.function_type = G_NULL_CHAR ) THEN
            func_header_rec.function_type := NULL;
          ELSIF ( func_header_rec.function_type <> temporary_record.function_type ) THEN
            --Log_error('Function Type can not be modified.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Function Type can not be modified.');
            ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_EF_FUNC_TYPE_UPD'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );
            func_header_rec.process_status := G_ERROR_RECORD;
          END IF;

          IF ( func_header_rec.function_info_1 IS NULL ) THEN
            func_header_rec.function_info_1 := temporary_record.function_info_1;
          ELSIF ( func_header_rec.function_info_1 = G_NULL_CHAR ) THEN
            func_header_rec.function_info_1 := NULL;
          END IF;

          IF ( func_header_rec.function_info_2 IS NULL ) THEN
            func_header_rec.function_info_2 := temporary_record.function_info_2;
          ELSIF ( func_header_rec.function_info_2 = G_NULL_CHAR ) THEN
            func_header_rec.function_info_2 := NULL;
          END IF;

          IF ( func_header_rec.display_name IS NULL ) THEN
            func_header_rec.display_name := temporary_record_tl.display_name;
          ELSIF ( func_header_rec.display_name = G_NULL_CHAR ) THEN
            func_header_rec.display_name := NULL;
          END IF;

          IF ( func_header_rec.description IS NULL ) THEN
            func_header_rec.description := temporary_record_tl.description;
          ELSIF ( func_header_rec.description = G_NULL_CHAR ) THEN
            func_header_rec.description := NULL;
          END IF;

          /* 2. Validation of all mandatory columns. */
          IF ( func_header_rec.internal_name IS NULL
                OR func_header_rec.display_name IS NULL
                OR func_header_rec.function_info_1 IS NULL
                OR func_header_rec.function_type IS NULL
                OR ( ( func_header_rec.function_type = 'J'
                        OR func_header_rec.function_type = 'P' )
                     AND func_header_rec.function_info_2 IS NULL ) ) THEN
            --Log_error('One of the mandatory columns is missed.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): One of the mandatory columns is missed.');
            ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_EF_FUNC_REQ_COLS_ERR'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );
            func_header_rec.process_status := G_ERROR_RECORD;
          END IF;


        /* Validations for DELETE transaction type. */
        ELSIF ( func_header_rec.transaction_type = G_DELETE_TRANSACTION
                AND func_header_rec.process_status <> G_ERROR_RECORD ) THEN
          BEGIN
              /* 1. Check if the function is used for Item Number or Description generation of the ICC.  */
              SELECT 1
              INTO   function_is_used
              FROM   dual
              WHERE  EXISTS (SELECT *
                             FROM   ego_actions_b
                             WHERE  ( function_id = func_header_rec.function_id ));
          EXCEPTION
              WHEN no_data_found THEN
                function_is_used := 0;
          END;
        /* 2. Check if the function is used in the Actions on Attribute Groups associated with ICC. */
        IF (function_is_used=0) THEN
            BEGIN
              SELECT 1 INTO function_is_used
              FROM dual
              WHERE EXISTS (SELECT * FROM ego_action_displays_b WHERE (prompt_function_id=func_header_rec.function_id
                           AND visibility_func_id=func_header_rec.function_id));
            EXCEPTION
              WHEN no_data_found THEN
                function_is_used:=0;
            END;
         END IF;
         IF (function_is_used=1) THEN
             --Log_error('Function is in use.');
             l_token_table(1).token_name  := 'FUNC_NAME';
             l_token_table(1).token_value := func_header_rec.internal_name;
	     write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_header_rec.transaction_id ||
                          ': (FID, FNAME) = (' || func_header_rec.function_id ||
                          ', '|| func_header_rec.internal_name || '): Function is in use.');
             ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_EF_FUNC_IN_USE'
               ,p_application_id                => 'EGO'
               ,p_token_tbl                     => l_token_table
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_header_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN
               ,p_table_name                    => G_FUNCTIONS_TAB
               );
             func_header_rec.process_status:=G_ERROR_RECORD;
         END IF;
        END IF;
	write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END validate_function;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: transact_function                                                       --
  -- This procedure will update the base table, with the data in func_header_rec, only if    --
  -- there are no validation errors (process_status<>3), based on transaction type.          --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE transact_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE) IS
  l_proc_name VARCHAR2(30) := 'transact_function';
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
  /* Insert into base table, if a row does not have any errors. */
  IF ( func_header_rec.process_status <> G_ERROR_RECORD ) THEN
     IF (func_header_rec.transaction_type=G_CREATE_TRANSACTION) then
            SELECT ego_functions_s.nextval
            INTO   func_header_rec.function_id
            FROM   dual;

            INSERT INTO ego_functions_b
                        (function_id,
                         internal_name,
                         function_type,
                         function_info_1,
                         function_info_2,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login)
            VALUES      (func_header_rec.function_id,
                         func_header_rec.internal_name,
                         func_header_rec.function_type,
                         func_header_rec.function_info_1,
                         func_header_rec.function_info_2,
                         G_USER_ID,
                         SYSDATE,
                         G_USER_ID,
                         SYSDATE,
                         G_LOGIN_ID);

            INSERT INTO ego_functions_tl
                        (function_id,
                         display_name,
                         description,
                         language,
                         source_lang,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login)
            SELECT func_header_rec.function_id,
                   func_header_rec.display_name,
                   func_header_rec.description,
                   language_code,
                   Userenv('LANG'),
                   G_USER_ID,
                   SYSDATE,
                   G_USER_ID,
                   SYSDATE,
                   G_LOGIN_ID
            FROM   fnd_languages l
            WHERE  installed_flag IN ( 'I', 'B' );

      ELSIF ( func_header_rec.transaction_type = G_UPDATE_TRANSACTION ) THEN
            UPDATE ego_functions_b
            SET    function_type = func_header_rec.function_type,
                   function_info_1 = func_header_rec.function_info_1,
                   function_info_2 = func_header_rec.function_info_2,
                   last_updated_by = G_USER_ID,
                   last_update_date = SYSDATE,
                   last_update_login = G_LOGIN_ID
            WHERE  ( function_id = func_header_rec.function_id );

            UPDATE ego_functions_tl
            SET    display_name = func_header_rec.display_name,
                   description = func_header_rec.description,
                   last_updated_by = G_USER_ID,
                   last_update_date = SYSDATE,
                   last_update_login = G_LOGIN_ID
            WHERE  ( function_id = func_header_rec.function_id )
                   AND Userenv('LANG') IN ( language, source_lang );

      ELSIF (func_header_rec.transaction_type = G_DELETE_TRANSACTION) THEN
            DELETE ego_functions_b WHERE (function_id=func_header_rec.function_id);
            DELETE ego_functions_tl WHERE (function_id=func_header_rec.function_id);
	    /* Bug 9647937. Delete rows from ego_func_params_tl table, before deleting rows from
	       ego_func_params_b table. */
            DELETE ego_func_params_tl WHERE func_param_id IN (SELECT func_param_id FROM ego_func_params_b
                                   WHERE (function_id=func_header_rec.function_id));
            DELETE ego_func_params_b WHERE (function_id=func_header_rec.function_id);
      END IF;
  func_header_rec.process_status := G_SUCCESS_RECORD;
  END IF;
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END transact_function;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: update_intfc_functions                                                  --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will update the interface table back after processing the records.       --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_tbl_values - Represents a table of type ego_functions_interface%ROWTYPE.       --
  ---------------------------------------------------------------------------------------------
  /* Bug 9701271. Changing the implementation, as reference like table(bulk_index).field in FORALL statement
     are not supported, before 11g release.*/
  PROCEDURE update_intfc_functions(ego_func_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_function_tbl_type) IS
  l_proc_name VARCHAR2(30) := 'update_intfc_functions';
  transaction_id_table Dbms_Sql.number_table;
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');

    FOR i IN 1 .. ego_func_tbl_values.Count LOOP
        transaction_id_table(i) := ego_func_tbl_values(i).transaction_id;
        ego_func_tbl_values(i).last_update_date := SYSDATE;
        ego_func_tbl_values(i).program_update_date := SYSDATE;
    END LOOP;

    /* Update the interface table back. */
    FORALL i IN 1 .. ego_func_tbl_values.COUNT
      UPDATE ego_functions_interface
      SET    ROW = ego_func_tbl_values(i)
      WHERE  ( transaction_id = transaction_id_table(i) );
      /* Commit after updating the interface table back. */
      COMMIT;
      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END update_intfc_functions;


   ---------------------------------------------------------------------------------------------
  -- Procedure Name: process_functions                                                       --
  -- This procedure will process all the functions one by one. Technically, it will call the --
  -- previous three functions.                                                               --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_tbl_values - Represents a table of type ego_functions_interface%ROWTYPE.       --
  -- p_commit            - Indicates whether to commit the work or not. This parameter       --
  --                       has significance only in public API flow.                         --
  ---------------------------------------------------------------------------------------------
  PROCEDURE process_functions(ego_func_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_function_tbl_type,
                                p_commit            IN     VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
  l_proc_name VARCHAR2(30) := 'process_functions';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||'  Processing '
              || ego_func_tbl_values.COUNT
              || ' records');

    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);

    FOR i IN 1 .. ego_func_tbl_values.COUNT LOOP
        write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Processing (TID, TTYPE) = (' ||
                     Ego_func_tbl_values(i).transaction_id || ', ' || Ego_func_tbl_values(i).transaction_type ||
                     '): (FID, FNAME) = (' || Ego_func_tbl_values(i).function_id ||
                     ', '|| Ego_func_tbl_values(i).internal_name || ').');

        construct_function(ego_func_tbl_values(i));
        validate_function(ego_func_tbl_values(i));
        transact_function(ego_func_tbl_values(i));
        IF (p_commit = FND_API.G_TRUE) THEN
           COMMIT;
        END IF;
    END LOOP;

  END process_functions;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: initialize_functions                                                    --
  -- This procedure will intialize functions interface table with by updating the            --
  -- "WHO" columns, transaction_id and convering the transction_type to upper case.          --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) that       --
  --                   belongs to a particular batch.                                        --
  ---------------------------------------------------------------------------------------------
  PROCEDURE initialize_functions(p_set_process_id IN NUMBER)
  IS
  l_proc_name VARCHAR2(30) := 'initialize_functions';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    UPDATE ego_functions_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           last_update_date = sysdate,
           last_updated_by = G_USER_ID,
           request_id = G_REQUEST_ID,
           program_application_id = G_PROGRAM_APPLICATION_ID,
           program_id = G_PROGRAM_ID,
           program_update_date = SYSDATE
    WHERE  ( (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
             AND process_status = G_PROCESS_RECORD AND transaction_id IS NULL);
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END initialize_functions;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: process_functions_conc_flow                                             --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will read the data in chunks from ego_functions_interface table,         --
  -- processes them by calling process_functions() and then updates interface table          --
  -- back by calling update_intfc_functions().                                               --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) to be      --
  --                   processed in a batch.                                                 --
  ---------------------------------------------------------------------------------------------
  PROCEDURE process_functions_conc_flow(p_set_process_id IN NUMBER)
  IS
  ego_func_tbl_values ego_metadata_pub.ego_function_tbl_type;
  l_proc_name VARCHAR2(30) := 'process_functions_conc_flow';
  record_count NUMBER;
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');

    /* Bug 9671972. Return if there are no rows to process. */
    SELECT Count(*) INTO record_count
    FROM ego_functions_interface
    WHERE ( (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
          AND process_status = G_PROCESS_RECORD );

    IF (record_count=0) THEN
       write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Return as there are no Function records to process');
       RETURN;
    END IF;

    initialize_functions(p_set_process_id);
    bulk_validate_functions(p_set_process_id);

    OPEN ego_func_tbl(p_set_process_id);
    BEGIN
        LOOP
            FETCH ego_func_tbl BULK COLLECT INTO ego_func_tbl_values LIMIT 2000;
            process_functions(ego_func_tbl_values);
            update_intfc_functions(ego_func_tbl_values);
            EXIT WHEN ego_func_tbl_values.COUNT < 2000;
        END LOOP;
        CLOSE ego_func_tbl;
    EXCEPTION
        WHEN OTHERS THEN
          CLOSE ego_func_tbl;
          RAISE;
    END;
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END process_functions_conc_flow;

  ----------------------------------------------------------------------------------------------
  -- Procedure Name: process_functions_conc_flow                                              --
  -- This will be invoked in Concurrent Request flow.                                         --
  -- This procedure will do bulk validations.                                                 --
  -- Parameters:                                                                              --
  -- IN                                                                                       --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) to be       --
  --                   processed in a batch.                                                  --
  ----------------------------------------------------------------------------------------------
  PROCEDURE bulk_validate_functions(p_set_process_id IN NUMBER)
  IS
    message_name fnd_new_messages.message_name%TYPE;
    message_text fnd_new_messages.message_text%TYPE;
    l_proc_name VARCHAR2(30) := 'bulk_validate_functions';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');

    message_name := 'EGO_TRANS_TYPE';
    FND_MESSAGE.SET_NAME('EGO',message_name );
    message_text := FND_MESSAGE.GET;

    /* Error out the rows with Transaction Type null and other than CREATE, UPDATE, DELETE, SYNC */
    INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNCTIONS_TAB,
           message_name,
           message_text,
           G_BO_IDENTIFIER_ICC,
           G_ENTITY_ICC_FN,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_functions_interface
    WHERE  ( transaction_type NOT IN ( G_CREATE_TRANSACTION, G_UPDATE_TRANSACTION, G_SYNC_TRANSACTION, G_DELETE_TRANSACTION )
              OR transaction_type IS NULL )
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_functions_interface
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  ( transaction_type NOT IN ( G_CREATE_TRANSACTION, G_UPDATE_TRANSACTION, G_SYNC_TRANSACTION, G_DELETE_TRANSACTION )
              OR transaction_type IS NULL )
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    /* For UPDATE and DELETE transactions, validate function_id if it is not null. */
    message_name := 'EGO_EF_FUNC_ID_ERR';
    FND_MESSAGE.SET_NAME('EGO',message_name );
    message_text := FND_MESSAGE.GET;

    INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNCTIONS_TAB,
           message_name,
           message_text,
           G_BO_IDENTIFIER_ICC,
           G_ENTITY_ICC_FN,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_functions_interface i
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT function_id
                           FROM   ego_functions_b b
                           WHERE  ( b.function_id = i.function_id ))
           AND function_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_functions_interface i
    SET    process_status = G_ERROR_RECORD,last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT *
                           FROM   ego_functions_b b
                           WHERE  ( b.function_id = i.function_id ))
           AND function_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    /* For UPDATE and DELETE transactions, validate internal_name if it is not null and
       function_id is not provided. */
    message_name := 'EGO_EF_FUNC_INT_NAME_INVL';
    FND_MESSAGE.SET_NAME('EGO',message_name );
    message_text := FND_MESSAGE.GET;

    INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNCTIONS_TAB,
           message_name,
           message_text,
           G_BO_IDENTIFIER_ICC,
           G_ENTITY_ICC_FN,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_functions_interface i
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT internal_name
                           FROM   ego_functions_b b
                           WHERE  ( b.internal_name = i.internal_name )
                           UNION
                           SELECT internal_name
                           FROM   ego_functions_interface ii
                           WHERE  ( ii.internal_name = i.internal_name )
                                  AND transaction_type = G_CREATE_TRANSACTION
                                  AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
                                  AND process_status = G_PROCESS_RECORD)
           AND function_id IS NULL
           AND internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_functions_interface i
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT internal_name
                           FROM   ego_functions_b b
                           WHERE  ( b.internal_name = i.internal_name )
                           UNION
                           SELECT internal_name
                           FROM   ego_functions_interface ii
                           WHERE  ( ii.internal_name = i.internal_name )
                                  AND transaction_type = G_CREATE_TRANSACTION
                                  AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
                                  AND process_status = G_PROCESS_RECORD)
           AND function_id IS NULL
           AND internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    /* For UPDATE and DELETE transactions, error out rows that do not have both function_id and internal_name. */
    message_name := 'EGO_EF_FUNC_ID_INT_NAME_ERR';
    FND_MESSAGE.SET_NAME('EGO',message_name );
    message_text := FND_MESSAGE.GET;

    INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNCTIONS_TAB,
           message_name,
           message_text,
           G_BO_IDENTIFIER_ICC,
           G_ENTITY_ICC_FN,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_functions_interface
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND function_id IS NULL
           AND internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_functions_interface i
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND function_id IS NULL
           AND internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END bulk_validate_functions;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: construct_func_param                                                    --
  -- This procedure will validate transaction type and the key columns that can identify     --
  -- a function parameter and also converts SYNC transaction to either CREATE or UPDATE,     --
  -- if the validation succeeds.                                                             --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE construct_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE)
  IS
  invalid_function_id            NUMBER(1);
  invalid_func_param_id          NUMBER(1);
  invalid_function_internal_name NUMBER(1);
  invalid_internal_name          NUMBER(1);
  l_proc_name VARCHAR2(30) := 'construct_func_param';
  BEGIN
     write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
     IF (func_param_rec.transaction_type IS NULL
          OR (func_param_rec.transaction_type <> G_CREATE_TRANSACTION
          AND func_param_rec.transaction_type <> G_UPDATE_TRANSACTION
          AND func_param_rec.transaction_type <> G_DELETE_TRANSACTION
          AND func_param_rec.transaction_type <> G_SYNC_TRANSACTION)) THEN
	      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Transaction Type.');
              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_TRANS_TYPE'
               ,p_application_id                => 'EGO'
               ,p_message_type                  => FND_API.G_RET_STS_ERROR
               ,p_row_identifier                => func_param_rec.transaction_id
               ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
               ,p_table_name                    => G_FUNC_PARAMS_TAB
               );
          func_param_rec.process_status:=G_ERROR_RECORD;
    END IF;

     /* Validate that Function ID and Function Internal Name.*/
        IF ( func_param_rec.function_id IS NOT NULL ) THEN
          BEGIN
              invalid_function_id := 0;

              SELECT internal_name
              INTO   func_param_rec.function_internal_name
              FROM   ego_functions_b
              WHERE  ( function_id = func_param_rec.function_id );
          EXCEPTION
              WHEN no_data_found THEN
                invalid_function_id := 1;
          END;
          IF (invalid_function_id=1) THEN
              --Log_error('Invalid Function ID.');
	      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Function ID.');
              ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_ID_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
              func_param_rec.process_status:=G_ERROR_RECORD;
          END IF;
        ELSIF ( func_param_rec.function_internal_name IS NOT NULL ) THEN
           BEGIN
              invalid_function_internal_name := 0;

              SELECT function_id
              INTO   func_param_rec.function_id
              FROM   ego_functions_b
              WHERE  ( internal_name = func_param_rec.function_internal_name );
          EXCEPTION
              WHEN no_data_found THEN
                invalid_function_internal_name := 1;
          END;
          IF (invalid_function_internal_name=1) THEN
              --Log_error('Invalid Function Internal Name.');
	      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Function Internal Name.');
              ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_INT_NAME_INVL'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
              func_param_rec.process_status:=G_ERROR_RECORD;
          END IF;
        ELSE
          --Log_error('Either Function ID or Function Internal Name must be provided.');
	  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Either Function ID or Function Internal Name must be provided.');
          ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FUNC_ID_INT_NAME_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
          func_param_rec.process_status := G_ERROR_RECORD;
        END IF;

        /* Convert SYNC to CREATE/UPDATE. Validate func_parm_id and internal_name for SYNC, UPDATE and DELETE transaction types.
           We need to consider Function ID also to validate. */
        IF ( (func_param_rec.transaction_type = G_UPDATE_TRANSACTION
              OR func_param_rec.transaction_type = G_SYNC_TRANSACTION
              OR func_param_rec.transaction_type = G_DELETE_TRANSACTION)
                 AND func_param_rec.process_status <> G_ERROR_RECORD ) THEN
          IF ( func_param_rec.func_param_id IS NOT NULL ) THEN
            BEGIN
                invalid_func_param_id := 0;

                SELECT internal_name
                INTO   func_param_rec.internal_name
                FROM   ego_func_params_b
                WHERE  ( function_id = func_param_rec.function_id
                         AND func_param_id = func_param_rec.func_param_id );
            EXCEPTION
                WHEN no_data_found THEN
                  invalid_func_param_id := 1;
            END;
            IF (invalid_func_param_id=1) THEN
               IF (func_param_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                   func_param_rec.transaction_type:=G_CREATE_TRANSACTION;
               ELSE
                   --Log_error('Invalid Parameter ID for the given Function ID or Function Internal Name.');
		   write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Parameter ID for the given Function ID or Function Internal Name.');
                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_ID_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
                   func_param_rec.process_status:=G_ERROR_RECORD;
               END IF;
            ELSE
               IF (func_param_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                   func_param_rec.transaction_type:=G_UPDATE_TRANSACTION;
               END IF;
            END IF;
          ELSIF ( func_param_rec.internal_name IS NOT NULL ) THEN
            BEGIN
                invalid_internal_name := 0;

                SELECT func_param_id
                INTO   func_param_rec.func_param_id
                FROM   ego_func_params_b
                WHERE  ( function_id = func_param_rec.function_id
                         AND internal_name = func_param_rec.internal_name );
            EXCEPTION
                WHEN no_data_found THEN
                    invalid_internal_name := 1;
            END;
            IF (invalid_internal_name=1) THEN
              IF (func_param_rec.transaction_type=G_SYNC_TRANSACTION) THEN
                func_param_rec.transaction_type:=G_CREATE_TRANSACTION;
              ELSE
               --Log_error('Invalid Parameter Internal Name for the given Function ID or Function Internal Name.');
	       write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Parameter Internal Name for the given Function ID or Function Internal Name.');
               ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_INT_NAME_INVL'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
               func_param_rec.process_status:=G_ERROR_RECORD;
              END IF;
            ELSE
             IF (func_param_rec.transaction_type=G_SYNC_TRANSACTION) THEN
              func_param_rec.transaction_type:=G_UPDATE_TRANSACTION;
             END IF;
            END IF;
          ELSE
            --Log_error('Either Parameter ID or Parameter Internal Name must be provided.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Either Parameter ID or Parameter Internal Name must be provided.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_ID_INT_NAME_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;
        END IF;
	write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
END construct_func_param;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: validate_func_param                                                     --
  -- This procedure will perform the remaining validations (excluding the validations done   --
  -- on key columns in construct_func_param) based on the transaction type.                  --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE validate_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE)
  IS
  x_function_type                ego_functions_b.function_type%TYPE;
  x_lookup_code                  fnd_lookup_values.lookup_code%TYPE;
  valid_data_type                NUMBER(1);
  valid_param_type               NUMBER(1);
  duplicate_internal_name        NUMBER(1);
  duplicate_sequence             NUMBER(1);
  temporary_record               ego_func_params_b%ROWTYPE;
  temporary_record_tl            ego_func_params_tl%ROWTYPE;
  l_proc_name VARCHAR2(30) := 'validate_func_param';
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
  /* Validations for CREATE transaction type. */
        IF ( func_param_rec.transaction_type = G_CREATE_TRANSACTION
             AND func_param_rec.process_status <> G_ERROR_RECORD ) THEN
          /* 1. Validation for Data Type. */
          SELECT function_type
          INTO   x_function_type
          FROM   ego_functions_b
          WHERE  ( function_id = func_param_rec.function_id );

          IF ( func_param_rec.data_type IS NOT NULL ) THEN
            IF ( x_function_type = 'P' ) THEN
              x_lookup_code := 'EGO_EF_FUNC_PARAM_DATA_TYPE_P';
            ELSIF ( x_function_type = 'J' ) THEN
              x_lookup_code := 'EGO_EF_FUNC_PARAM_DATA_TYPE_J';
            ELSIF ( x_function_type = 'S' ) THEN
              x_lookup_code := 'EGO_EF_FUNC_PARAM_DATA_TYPE_S';
            END IF;

            BEGIN
                SELECT 1
                INTO   valid_data_type
                FROM   fnd_lookup_values
                WHERE  ( lookup_type = x_lookup_code
                         AND language = Userenv('LANG')
                         AND lookup_code = func_param_rec.data_type );
            EXCEPTION
                WHEN no_data_found THEN
                  valid_data_type := 0;
            END;

            IF ( valid_data_type = 0 ) THEN
              --Log_error('Invalid Data Type.');
	      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Data Type.');
              ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_PUB_INVALID_DATATYPE'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
              func_param_rec.process_status := G_ERROR_RECORD;
            END IF;
          END IF;
        /* 2. Validation for Parameter Type. If Function Type is URL, Parameter Type must be Input.
           If Data Type is Error Array, Parameter Type must be Output. The outer if is not required. */
          IF ( func_param_rec.param_type IS NOT NULL ) THEN
            valid_param_type := 1;
            IF ( x_function_type = 'S' ) THEN
              IF ( func_param_rec.param_type <> 'I' ) THEN
                valid_param_type := 0;
              END IF;
            ELSIF ( func_param_rec.data_type = 'E' ) THEN
              IF ( func_param_rec.param_type <> 'O' ) THEN
                valid_param_type := 0;
              END IF;
            ELSE
              BEGIN
                  SELECT 1
                  INTO   valid_param_type
                  FROM   fnd_lookup_values
                  WHERE  ( lookup_type = 'EGO_EF_FUNC_PARAM_TYPE'
                           AND language = Userenv('LANG')
                           AND lookup_code = func_param_rec.param_type );
              EXCEPTION
                  WHEN no_data_found THEN
                    valid_param_type := 0;
              END;
            END IF;
            IF (valid_param_type=0) THEN
                --Log_error('Invalid Parameter Type.');
		write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Invalid Parameter Type.');
                ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_PARAM_TYPE_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
                func_param_rec.process_status:=G_ERROR_RECORD;
            END IF;
          END IF;

          /* 3. Validation for Internal Name. */
          BEGIN
              SELECT 1
              INTO   duplicate_internal_name
              FROM   ego_func_params_b
              WHERE  ( function_id = func_param_rec.function_id
                       AND internal_name = func_param_rec.internal_name );
          EXCEPTION
              WHEN no_data_found THEN
                duplicate_internal_name := 0;
          END;

          IF ( duplicate_internal_name = 1 ) THEN
            --Log_error('Duplicate Parameter Internal Name.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Duplicate Parameter Internal Name.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_INT_NAME_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;

          /* 4. Validation for Sequence. */
          BEGIN
              SELECT 1
              INTO   duplicate_sequence
              FROM   ego_func_params_b
              WHERE  ( function_id = func_param_rec.function_id
                       AND SEQUENCE = func_param_rec.SEQUENCE );
          EXCEPTION
              WHEN no_data_found THEN
                duplicate_sequence := 0;
          END;

          IF ( duplicate_sequence = 1 ) THEN
            --Log_error('Duplicate Sequence.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Duplicate Sequence.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_DUPLICATE_SEQ_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;

          /* 5. Validation for Mandatory columns. */
          IF ( func_param_rec.internal_name IS NULL
                OR func_param_rec.display_name IS NULL
                OR func_param_rec.SEQUENCE IS NULL
                OR func_param_rec.data_type IS NULL
                OR func_param_rec.param_type IS NULL ) THEN
            --Log_error('Mandatory columns must be provided.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Mandatory columns must be provided.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_REQ_COLS_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;

        ELSIF ( func_param_rec.transaction_type = G_UPDATE_TRANSACTION
                AND func_param_rec.process_status <> G_ERROR_RECORD ) THEN
          SELECT *
          INTO   temporary_record
          FROM   ego_func_params_b
          WHERE  ( func_param_id = func_param_rec.func_param_id );

          SELECT *
          INTO   temporary_record_tl
          FROM   ego_func_params_tl
          WHERE  ( func_param_id = func_param_rec.func_param_id )
                 AND language = Userenv('LANG');

          /* 1. Validating Data Type. */
          IF ( func_param_rec.data_type IS NULL ) THEN
            func_param_rec.data_type := temporary_record.data_type;
          ELSIF ( func_param_rec.data_type = G_NULL_CHAR ) THEN
            func_param_rec.data_type := NULL;
          ELSIF ( func_param_rec.data_type <> temporary_record.data_type ) THEN
            --Log_error('Data Type can not be modified.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Data Type can not be modified.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_DATA_TYPE_UPD'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;

          /* 2. Validating Parameter Type. */
          IF ( func_param_rec.param_type IS NULL ) THEN
            func_param_rec.param_type := temporary_record.param_type;
          ELSIF ( func_param_rec.param_type = G_NULL_CHAR ) THEN
            func_param_rec.param_type := NULL;
          ELSIF ( func_param_rec.param_type <> temporary_record.param_type ) THEN
            --Log_error('Parameter Type can not be modified.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Parameter Type can not be modified.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_PARAM_TYPE_UPD'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;

          IF ( func_param_rec.display_name IS NULL ) THEN
            func_param_rec.display_name := temporary_record_tl.display_name;
          ELSIF ( func_param_rec.display_name = G_NULL_CHAR ) THEN
            func_param_rec.display_name := NULL;
          END IF;

          /* Bug 9653987. Validate the Sequence, only if it is changed. */
          IF ( func_param_rec.SEQUENCE IS NULL ) THEN
            func_param_rec.SEQUENCE := temporary_record.SEQUENCE;
          ELSIF ( func_param_rec.SEQUENCE = G_NULL_NUM ) THEN
            func_param_rec.SEQUENCE := NULL;
          ELSIF ( func_param_rec.SEQUENCE <> temporary_record.SEQUENCE) THEN
            BEGIN
                SELECT 1
                INTO   duplicate_sequence
                FROM   ego_func_params_b
                WHERE  ( function_id = func_param_rec.function_id
                         AND SEQUENCE = func_param_rec.SEQUENCE );
            EXCEPTION
                WHEN no_data_found THEN
                  duplicate_sequence := 0;
            END;
            IF (duplicate_sequence=1) THEN
               --Log_error('Duplicate Sequence.');
	       write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Duplicate Sequence.');
               ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_DUPLICATE_SEQ_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
               func_param_rec.process_status:=G_ERROR_RECORD;
            END IF;
          END IF;

          /* 3. Validation for Mandatory columns. */
          IF ( func_param_rec.internal_name IS NULL
                OR func_param_rec.display_name IS NULL
                OR func_param_rec.SEQUENCE IS NULL
                OR func_param_rec.data_type IS NULL
                OR func_param_rec.param_type IS NULL ) THEN
            --Log_error('Mandatory columns must be provided.');
	    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'|| ' err_msg: TID = ' || func_param_rec.transaction_id ||
                          ': (FID, FNAME, FPID, FPNAME) = (' || func_param_rec.function_id ||
                          ', '|| func_param_rec.function_internal_name || ', '|| func_param_rec.func_param_id ||
                          ', '||func_param_rec.internal_name||'): Mandatory columns must be provided.');
            ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_EF_FP_REQ_COLS_ERR'
                    ,p_application_id                => 'EGO'
                    ,p_message_type                  => FND_API.G_RET_STS_ERROR
                    ,p_row_identifier                => func_param_rec.transaction_id
                    ,p_entity_code                   => G_ENTITY_ICC_FN_PARAM
                    ,p_table_name                    => G_FUNC_PARAMS_TAB
                    );
            func_param_rec.process_status := G_ERROR_RECORD;
          END IF;
          /* No futher validations required for DELETE transaction. */
        END IF;
	write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END validate_func_param;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: transact_func_param                                                     --
  -- This procedure will update the base table, with the data in func_param_rec, only if     --
  -- there are no validation errors (process_status<>3), based on transaction type.          --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE transact_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE) IS
  l_proc_name VARCHAR2(30) := 'transact_func_param';
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
  IF ( func_param_rec.process_status <> G_ERROR_RECORD ) THEN
   IF (func_param_rec.transaction_type=G_CREATE_TRANSACTION) THEN
            SELECT ego_func_params_s.nextval
            INTO   func_param_rec.func_param_id
            FROM   dual;
            INSERT INTO ego_func_params_b
                        (function_id,
                         func_param_id,
                         SEQUENCE,
                         internal_name,
                         data_type,
                         param_type,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_login,
                         last_update_date)
            VALUES      (func_param_rec.function_id,
                         func_param_rec.func_param_id,
                         func_param_rec.SEQUENCE,
                         func_param_rec.internal_name,
                         func_param_rec.data_type,
                         func_param_rec.param_type,
                         G_USER_ID,
                         SYSDATE,
                         G_USER_ID,
                         G_LOGIN_ID,
                         SYSDATE);
            INSERT INTO ego_func_params_tl
                        (func_param_id,
                         display_name,
                         language,
                         source_lang,
                         created_by,
                         creation_date,
                         last_updated_by,
                         last_update_login,
                         last_update_date)
            SELECT func_param_rec.func_param_id,
                   func_param_rec.display_name,
                   language_code,
                   Userenv('LANG'),
                   G_USER_ID,
                   SYSDATE,
                   G_USER_ID,
                   G_LOGIN_ID,
                   SYSDATE
            FROM   fnd_languages l
            WHERE  installed_flag IN ( 'I', 'B' );

    ELSIF ( func_param_rec.transaction_type = G_UPDATE_TRANSACTION ) THEN
            UPDATE ego_func_params_b
            SET    SEQUENCE = func_param_rec.SEQUENCE,
                   data_type = func_param_rec.data_type,
                   param_type = func_param_rec.param_type,
                   last_updated_by = G_USER_ID,
                   last_update_login = G_LOGIN_ID,
                   last_update_date = SYSDATE
            WHERE  ( func_param_id = func_param_rec.func_param_id );

            UPDATE ego_func_params_tl
            SET    display_name = func_param_rec.display_name,
                   last_updated_by = G_USER_ID,
                   last_update_login = G_LOGIN_ID,
                   last_update_date = SYSDATE
            WHERE  ( func_param_id = func_param_rec.func_param_id )
                   AND Userenv('LANG') IN ( language, source_lang );

    ELSIF (func_param_rec.transaction_type = G_DELETE_TRANSACTION ) THEN
          /* No validations for DELETE transaction. */
          DELETE ego_func_params_b
          WHERE  ( func_param_id = func_param_rec.func_param_id );

          DELETE ego_func_params_tl
          WHERE  ( func_param_id = func_param_rec.func_param_id );

          DELETE ego_mappings_b
          WHERE  ( func_param_id = func_param_rec.func_param_id );
  END IF;
  func_param_rec.process_status := G_SUCCESS_RECORD;
  END IF;
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END transact_func_param;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: update_intfc_func_params                                                --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will update the interface table back after processing the records.       --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_param_tbl_values - Represents a table of type                                  --
  --                             ego_func_params_interface%ROWTYPE.                          --
  ---------------------------------------------------------------------------------------------
  /* Bug 9701271. Changing the implementation, as reference like table(bulk_index).field in FORALL statement
     are not supported, before 11g release.*/
  PROCEDURE update_intfc_func_params(ego_func_param_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_func_param_tbl_type)
  IS
  l_proc_name VARCHAR2(30) := 'update_intfc_func_params';
  transaction_id_table Dbms_Sql.number_table;
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');

  FOR i IN 1 .. ego_func_param_tbl_values.Count LOOP
        transaction_id_table(i) := ego_func_param_tbl_values(i).transaction_id;
        ego_func_param_tbl_values(i).last_update_date := SYSDATE;
        ego_func_param_tbl_values(i).program_update_date := SYSDATE;
  END LOOP;

  /* Update the interface table back */
    FORALL i IN 1 .. ego_func_param_tbl_values.COUNT
      UPDATE ego_func_params_interface
      SET    ROW = ego_func_param_tbl_values(i)
      WHERE  ( transaction_id = transaction_id_table(i) );
      /* Commit after updating the interface table back. */
      COMMIT;
      write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END update_intfc_func_params;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: process_func_params                                                     --
  -- This procedure will process all the function parameters one by one. Technically, it     --
  -- will call the previous three functions.                                                 --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_param_tbl_values - Represents a table of type                                  --
  --                             ego_func_params_interface%ROWTYPE.                          --
  -- p_commit            - Indicates whether to commit the work or not. This parameter       --
  --                       has significance only in public API flow.                         --
  ---------------------------------------------------------------------------------------------
  PROCEDURE process_func_params(ego_func_param_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_func_param_tbl_type,
                                p_commit                 IN     VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
  l_proc_name VARCHAR2(30) := 'process_func_params';
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);

    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Processing '
              || ego_func_param_tbl_values.COUNT
              || ' records');

    FOR i IN 1 .. ego_func_param_tbl_values.COUNT LOOP
        write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Processing (TID, TYPE) = (' ||
                     Ego_func_param_tbl_values(i).transaction_id || ', ' || Ego_func_param_tbl_values(i).transaction_type ||
                     '): (FID, FNAME, FPID, FPNAME) = (' || Ego_func_param_tbl_values(i).function_id ||', '|| Ego_func_param_tbl_values(i).function_internal_name ||
                     ', '||Ego_func_param_tbl_values(i).func_param_id ||', '|| Ego_func_param_tbl_values(i).internal_name ||').');

        construct_func_param(ego_func_param_tbl_values(i));
        validate_func_param(ego_func_param_tbl_values(i));
        transact_func_param(ego_func_param_tbl_values(i));

        IF (p_commit = FND_API.G_TRUE) THEN
           COMMIT;
        END IF;
    END LOOP;
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END process_func_params;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: initialize_func_params                                                  --
  -- This procedure will intialize function parameters interface table with by updating the  --
  -- "WHO" columns, transaction_id and convering the transction_type to upper case.          --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) that       --
  --                   belongs to a particular batch.                                        --
  ---------------------------------------------------------------------------------------------
  PROCEDURE initialize_func_params(p_set_process_id IN NUMBER)
  IS
  l_proc_name VARCHAR2(30) := 'initialize_func_params';
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
  UPDATE ego_func_params_interface
    SET    transaction_id = mtl_system_items_interface_s.nextval,
           transaction_type = Upper(transaction_type),
           last_update_date = SYSDATE,
           last_updated_by = G_USER_ID,
           request_id = G_REQUEST_ID,
           program_application_id = G_PROGRAM_APPLICATION_ID,
           program_id = G_PROGRAM_ID,
           program_update_date = SYSDATE
    WHERE  ( (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
             AND process_status = G_PROCESS_RECORD AND transaction_id IS NULL);
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END initialize_func_params;

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: process_func_params_conc_flow                                           --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will read the data in chunks from ego_func_params_interface table,       --
  -- processes them by calling process_func_params() and then updates interface table        --
  -- back by calling update_intfc_func_params().                                             --
  -- Parameters:                                                                             --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_func_params_interface table) to be    --
  --                   processed in a batch.                                                 --
  ---------------------------------------------------------------------------------------------
  PROCEDURE process_func_params_conc_flow(p_set_process_id IN NUMBER)
  IS
  ego_func_param_tbl_values ego_metadata_pub.ego_func_param_tbl_type;
  l_proc_name VARCHAR2(30) := 'process_func_params_conc_flow';
  record_count NUMBER;
  BEGIN
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');

    /* Bug 9671972. Return if there are no rows to process. */
    SELECT Count(*) INTO record_count
    FROM ego_func_params_interface
    WHERE ( (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
          AND process_status = G_PROCESS_RECORD );

    IF (record_count=0) THEN
       write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Return as there are no Function Parameter records to process');
       RETURN;
    END IF;

    initialize_func_params(p_set_process_id);
    bulk_validate_func_params(p_set_process_id);

    OPEN ego_func_param_tbl(p_set_process_id);
     BEGIN
        LOOP
            FETCH ego_func_param_tbl BULK COLLECT INTO ego_func_param_tbl_values LIMIT 2000;
            process_func_params(ego_func_param_tbl_values);
            update_intfc_func_params(ego_func_param_tbl_values);
            EXIT WHEN ego_func_param_tbl_values.COUNT < 2000;
        END LOOP;
       CLOSE ego_func_param_tbl;
    EXCEPTION
        WHEN OTHERS THEN
          CLOSE ego_func_param_tbl;
          RAISE;
    END;
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
  END process_func_params_conc_flow;

  ----------------------------------------------------------------------------------------------
  -- Procedure Name: bulk_validate_func_params                                                --
  -- This will be invoked in Concurrent Request flow.                                         --
  -- This procedure will do bulk validations.                                                 --
  -- Parameters:                                                                              --
  -- IN                                                                                       --
  -- p_set_process_id: ID to identify the rows (in ego_func_params_interface table) to be     --
  --                   processed in a batch.                                                  --
  ----------------------------------------------------------------------------------------------
  PROCEDURE bulk_validate_func_params(p_set_process_id IN NUMBER) IS
  message_name fnd_new_messages.message_name%TYPE;
  message_text fnd_new_messages.message_text%TYPE;
  l_proc_name VARCHAR2(30) := 'bulk_validate_func_params';
  BEGIN
  write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Entered into the procedure');
  /* Error out the rows with Transaction Type null and other than CREATE, UPDATE, DELETE, SYNC */
  message_name := 'EGO_TRANS_TYPE';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface
    WHERE  ( transaction_type NOT IN ( G_CREATE_TRANSACTION, G_UPDATE_TRANSACTION, G_SYNC_TRANSACTION, G_DELETE_TRANSACTION )
              OR transaction_type IS NULL )
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  UPDATE ego_func_params_interface
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  ( transaction_type NOT IN ( G_CREATE_TRANSACTION, G_UPDATE_TRANSACTION, G_SYNC_TRANSACTION, G_DELETE_TRANSACTION )
              OR transaction_type IS NULL )
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  /* Validate function_id, if it is not null. */
  message_name := 'EGO_EF_FUNC_ID_ERR';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface i
    WHERE  NOT EXISTS (SELECT *
                           FROM   ego_functions_b b
                           WHERE  ( b.function_id = i.function_id ))
           AND function_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  UPDATE ego_func_params_interface i
    SET    process_status = G_ERROR_RECORD,last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE NOT EXISTS (SELECT *
                           FROM   ego_functions_b b
                           WHERE  ( b.function_id = i.function_id ))
           AND function_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  /* Validate validate internal_name if it is not null and function_id is not provided.
     We do not need to look into ego_functions_interface table for Internal Name, as we call
     this function only after processing ego_functions_interface table */
  message_name := 'EGO_INVALID_FUNC_INT_NAME';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface i
    WHERE  NOT EXISTS (SELECT internal_name
                           FROM   ego_functions_b b
                           WHERE  ( b.internal_name = i.function_internal_name )
                      )
           AND function_id IS NULL
           AND function_internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  UPDATE ego_func_params_interface i
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  NOT EXISTS (SELECT internal_name
                           FROM   ego_functions_b b
                           WHERE  ( b.internal_name = i.function_internal_name )
                      )
           AND function_id IS NULL
           AND function_internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  /* Error out rows that do not have both function_id and internal_name. */
  message_name := 'EGO_EF_FUNC_ID_INT_NAME_ERR';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface
    WHERE  function_id IS NULL
           AND function_internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  UPDATE ego_func_params_interface i
    SET    process_status = G_ERROR_RECORD, last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  function_id IS NULL
           AND function_internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;


  /* For UPDATE and DELETE transactions, validate Parameter ID if it is not null. */
  message_name := 'EGO_EF_FP_ID_ERR';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface i
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT *
                           FROM   ego_func_params_b b
                           WHERE  ( b.func_param_id = i.func_param_id )
                           AND ((b.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (b.function_id IN (SELECT function_id FROM ego_functions_b
                                 WHERE (internal_name=i.function_internal_name))
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )   )
           AND func_param_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  UPDATE ego_func_params_interface i
    SET    process_status = G_ERROR_RECORD,last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT *
                           FROM   ego_func_params_b b
                           WHERE  ( b.func_param_id = i.func_param_id )
                           AND ((b.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (b.function_id IN (SELECT function_id FROM ego_functions_b
                                 WHERE (internal_name=i.function_internal_name))
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )   )
           AND func_param_id IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  /* For UPDATE and DELETE transactions, validate Parameter Name if it is not null
     and Parameter Id is null. */

  message_name := 'EGO_EF_FP_INT_NAME_INVL';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  /* Bug 9647937. Modified the condition to validate Parameter Internal Name if it is not null
     and Parameter Id is null. Also, added logic to validate Parameter Internal Name
     against ego_func_params_interface_table also. */

  /* Bug 9671972. Changing the Where clause to directly compare function_internal_name
     instead of function_id, while validating against ego_func_params_interface_table. */

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface i
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT internal_name
                           FROM   ego_func_params_b b
                           WHERE  ( b.internal_name = i.internal_name )
                           AND ((b.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (b.function_id IN (SELECT function_id FROM ego_functions_b
                                 WHERE (internal_name=i.function_internal_name))
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )
			   UNION
                           SELECT internal_name
                           FROM ego_func_params_interface ii
                           WHERE (ii.internal_name = i.internal_name)
                           AND ((ii.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (ii.function_internal_name = i.function_internal_name
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )
                           AND transaction_type = G_CREATE_TRANSACTION
                                  AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
                                  AND process_status = G_PROCESS_RECORD
	                   )
           AND func_param_id IS NULL
           AND internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_func_params_interface i
    SET    process_status = G_ERROR_RECORD,last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND NOT EXISTS (SELECT internal_name
                           FROM   ego_func_params_b b
                           WHERE  ( b.internal_name = i.internal_name )
                           AND ((b.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (b.function_id IN (SELECT function_id FROM ego_functions_b
                                 WHERE (internal_name=i.function_internal_name))
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )
			   UNION
                           SELECT internal_name
                           FROM ego_func_params_interface ii
                           WHERE (ii.internal_name = i.internal_name)
                           AND ((ii.function_id = i.function_id AND i.function_id IS NOT NULL) OR
                                (ii.function_internal_name = i.function_internal_name
                                 AND i.function_id IS NULL AND i.function_internal_name IS NOT NULL)
                           )
                           AND transaction_type = G_CREATE_TRANSACTION
                                  AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
                                  AND process_status = G_PROCESS_RECORD
	                   )
           AND func_param_id IS NULL
           AND internal_name IS NOT NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

  /* For UPDATE and DELETE transactions, error out rows that do not have both func_param_id and internal_name. */
  message_name := 'EGO_EF_FP_ID_INT_NAME_ERR';
  FND_MESSAGE.SET_NAME('EGO',message_name );
  message_text := FND_MESSAGE.GET;

  INSERT INTO mtl_interface_errors
                (unique_id,
                 transaction_id,
                 table_name,
                 message_name,
                 error_message,
                 bo_identifier,
                 entity_identifier,
                 message_type,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
    SELECT mtl_system_items_interface_s.nextval,
           transaction_id,
           G_FUNC_PARAMS_TAB,
           message_name,
           message_text,
           g_bo_identifier_icc,
           G_ENTITY_ICC_FN_PARAM,
           fnd_api.g_ret_sts_error,
           SYSDATE,
           G_USER_ID,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           G_REQUEST_ID,
           G_PROGRAM_APPLICATION_ID,
           G_PROGRAM_ID,
           SYSDATE
    FROM   ego_func_params_interface
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND func_param_id IS NULL
           AND internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;

    UPDATE ego_func_params_interface
    SET    process_status = G_ERROR_RECORD,last_update_date=sysdate, last_updated_by=G_USER_ID,program_update_date=SYSDATE
    WHERE  transaction_type IN ( G_UPDATE_TRANSACTION, G_DELETE_TRANSACTION )
           AND func_param_id IS NULL
           AND internal_name IS NULL
           AND (p_set_process_id IS NULL OR set_process_id = p_set_process_id)
           AND process_status = G_PROCESS_RECORD;
    write_debug(G_PCK_NAME||'.'||l_proc_name||'->'||' Exiting from the procedure');
END bulk_validate_func_params;
END EGO_FUNCTIONS_BULKLOAD_PVT;

/

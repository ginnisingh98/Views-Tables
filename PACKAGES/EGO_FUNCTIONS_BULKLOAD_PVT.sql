--------------------------------------------------------
--  DDL for Package EGO_FUNCTIONS_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_FUNCTIONS_BULKLOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOVFNBS.pls 120.0.12010000.4 2010/05/17 12:46:21 snandana noship $ */

  /* Constants for process statuses. */
  G_PROCESS_RECORD CONSTANT NUMBER := 1;
  G_ERROR_RECORD   CONSTANT NUMBER := 3;
  G_SUCCESS_RECORD CONSTANT NUMBER := 7;

  CURSOR ego_func_tbl(
    c_set_process_id NUMBER) IS
    SELECT *
    FROM   ego_functions_interface
    WHERE  ( (c_set_process_id IS NULL OR set_process_id = c_set_process_id)
             AND process_status = G_PROCESS_RECORD );

  CURSOR ego_func_param_tbl(
    c_set_process_id NUMBER) IS
    SELECT *
    FROM   ego_func_params_interface
    WHERE  ( (c_set_process_id IS NULL OR set_process_id = c_set_process_id)
             AND process_status = G_PROCESS_RECORD );

  /* Constants for transaction types. */
  G_CREATE_TRANSACTION CONSTANT VARCHAR2(30) := 'CREATE';
  G_UPDATE_TRANSACTION CONSTANT VARCHAR2(30) := 'UPDATE';
  G_DELETE_TRANSACTION CONSTANT VARCHAR2(30) := 'DELETE';
  G_SYNC_TRANSACTION   CONSTANT VARCHAR2(30) := 'SYNC';

  /* Constants for Who columns. Use the constants from ego_metadata_bulkload_pvt, as they will be
     initialized in ego_metadata_bulkload_pvt.SetGlobals() while running Meata Data Import Concurrent Program.  */
  -- Initialize G_USER_ID and G_LOGIN_ID to some value, as constants in ego_metadata_bulkload_pvt will not be initialized,
  -- while testing/debugging this package standalone.
  G_USER_ID                CONSTANT    NUMBER := ego_metadata_bulkload_pvt.G_USER_ID;
  G_LOGIN_ID               CONSTANT    NUMBER := ego_metadata_bulkload_pvt.G_LOGIN_ID;
  G_REQUEST_ID             CONSTANT    NUMBER := ego_metadata_bulkload_pvt.G_REQUEST_ID;
  G_PROGRAM_APPLICATION_ID CONSTANT    NUMBER := ego_metadata_bulkload_pvt.G_PROGRAM_APPLICATION_ID;
  G_PROGRAM_ID             CONSTANT    NUMBER := ego_metadata_bulkload_pvt.G_PROGRAM_ID;

  /* Constants to null out the column values in UPDATE transactions. */
  G_NULL_NUM     CONSTANT      NUMBER := fnd_api.G_NULL_NUM;
  G_NULL_CHAR    CONSTANT      VARCHAR2(1) := fnd_api.G_NULL_CHAR;

  /* Constants for error handling. */
  G_FUNCTIONS_TAB       CONSTANT VARCHAR2(50) := 'EGO_FUNCTIONS_INTERFACE';
  G_FUNC_PARAMS_TAB     CONSTANT VARCHAR2(50) := 'EGO_FUNC_PARAMS_INTERFACE';
  G_BO_IDENTIFIER_ICC   CONSTANT  VARCHAR2(30) := 'ICC';
  G_ENTITY_ICC_FN       CONSTANT  VARCHAR2(30) := 'ICC_FUNCTION';
  G_ENTITY_ICC_FN_PARAM CONSTANT  VARCHAR2(30) := 'ICC_FN_PARAM';

  /* Constant to disply Package Name while logging debug messages. */
  G_PCK_NAME            CONSTANT VARCHAR2(30)  := 'EGO_FUNCTIONS_BULKLOAD_PVT';

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
                                  x_return_msg   OUT  NOCOPY VARCHAR2);

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
  PROCEDURE delete_processed_functions(p_set_process_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_return_msg   OUT  NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: initialize_functions                                                    --
  -- This procedure will intialize functions interface table with by updating the            --
  -- "WHO" columns, transaction_id and convering the transction_type to upper case.          --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) that       --
  --                   belongs to a particular batch.                                        --
  ---------------------------------------------------------------------------------------------
  PROCEDURE initialize_functions(p_set_process_id IN NUMBER);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: construct_function                                                      --
  -- This procedure will validate transaction type and the key columns that can identify     --
  -- a function and also converts SYNC transaction to either CREATE or UPDATE,               --
  -- if the validation succeeds.                                                             --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE construct_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: validate_function                                                       --
  -- This procedure will perform the remaining validations (excluding the validations done   --
  -- on key columns in construct_function) based on the transaction type.                    --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE validate_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: transact_function                                                       --
  -- This procedure will update the base table, with the data in func_header_rec, only if    --
  -- there are no validation errors (process_status<>3), based on transaction type.          --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_header_rec - Represents a row of type ego_functions_interface%ROWTYPE.             --
  ---------------------------------------------------------------------------------------------
  PROCEDURE transact_function(func_header_rec IN OUT NOCOPY ego_functions_interface%ROWTYPE);

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
                              p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: update_intfc_functions                                                  --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will update the interface table back after processing the records.       --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_tbl_values - Represents a table of type ego_functions_interface%ROWTYPE.       --
  ---------------------------------------------------------------------------------------------
  PROCEDURE update_intfc_functions(ego_func_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_function_tbl_type); /* Bug 9701271. */

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
  PROCEDURE process_functions_conc_flow(p_set_process_id IN NUMBER);

  ----------------------------------------------------------------------------------------------
  -- Procedure Name: process_functions_conc_flow                                              --
  -- This will be invoked in Concurrent Request flow.                                         --
  -- This procedure will do bulk validations.                                                 --
  -- Parameters:                                                                              --
  -- IN                                                                                       --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) to be       --
  --                   processed in a batch.                                                  --
  ----------------------------------------------------------------------------------------------
  PROCEDURE bulk_validate_functions(p_set_process_id IN NUMBER);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: initialize_func_params                                                  --
  -- This procedure will intialize function parameters interface table with by updating the  --
  -- "WHO" columns, transaction_id and convering the transction_type to upper case.          --
  -- IN                                                                                      --
  -- p_set_process_id: ID to identify the rows (in ego_functions_interface table) that       --
  --                   belongs to a particular batch.                                        --
  ---------------------------------------------------------------------------------------------
  PROCEDURE initialize_func_params(p_set_process_id IN NUMBER);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: construct_func_param                                                    --
  -- This procedure will validate transaction type and the key columns that can identify     --
  -- a function parameter and also converts SYNC transaction to either CREATE or UPDATE,     --
  -- if the validation succeeds.                                                             --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE construct_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: validate_func_param                                                     --
  -- This procedure will perform the remaining validations (excluding the validations done   --
  -- on key columns in construct_func_param) based on the transaction type.                  --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE validate_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: transact_func_param                                                     --
  -- This procedure will update the base table, with the data in func_param_rec, only if     --
  -- there are no validation errors (process_status<>3), based on transaction type.          --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- func_param_rec - Represents a row of type ego_func_params_interface%ROWTYPE.            --
  ---------------------------------------------------------------------------------------------
  PROCEDURE transact_func_param(func_param_rec IN OUT NOCOPY ego_func_params_interface%ROWTYPE);

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
                                p_commit                  IN     VARCHAR2 DEFAULT FND_API.G_FALSE);

  ---------------------------------------------------------------------------------------------
  -- Procedure Name: update_intfc_func_params                                                --
  -- This will be invoked in Concurrent Request flow.                                        --
  -- This procedure will update the interface table back after processing the records.       --
  -- Parameters:                                                                             --
  -- IN OUT                                                                                  --
  -- ego_func_param_tbl_values - Represents a table of type                                  --
  --                             ego_func_params_interface%ROWTYPE.                          --
  ---------------------------------------------------------------------------------------------
  PROCEDURE update_intfc_func_params(ego_func_param_tbl_values IN OUT NOCOPY ego_metadata_pub.ego_func_param_tbl_type); /* Bug 9701271. */

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
  PROCEDURE process_func_params_conc_flow(p_set_process_id IN NUMBER);

  ----------------------------------------------------------------------------------------------
  -- Procedure Name: bulk_validate_func_params                                                --
  -- This will be invoked in Concurrent Request flow.                                         --
  -- This procedure will do bulk validations.                                                 --
  -- Parameters:                                                                              --
  -- IN                                                                                       --
  -- p_set_process_id: ID to identify the rows (in ego_func_params_interface table) to be     --
  --                   processed in a batch.                                                  --
  ----------------------------------------------------------------------------------------------
  PROCEDURE bulk_validate_func_params(p_set_process_id  IN NUMBER);
END EGO_FUNCTIONS_BULKLOAD_PVT;

/

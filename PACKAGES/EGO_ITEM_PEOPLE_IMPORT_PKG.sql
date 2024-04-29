--------------------------------------------------------
--  DDL for Package EGO_ITEM_PEOPLE_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_PEOPLE_IMPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOCIPIS.pls 120.2 2005/10/06 03:07:29 srajapar noship $ */
----------------------------------------------------------------------------
--                                                                        --
--  IMPORTANT:                                                            --
--                                                                        --
--    Please update the HLD whenever you update the specification         --
--    HLD Location :                                                      --
--       http://development.oracle.com/pa/ProjectAttachmentsList.jsp?projectId=45
--       Document Name:   Item People Import HLD                          --
--                                                                        --
--                                                       Thank You        --
----------------------------------------------------------------------------


  -- ===============================================
  -- CONSTANTS for concurrent program return values
  -- ===============================================
  --
  -- Value for getting the current dataset id for sql loader.
  --
  G_CURR_DATASET_ID            NUMBER := -1;
  --
  -- Package Name
  --
  G_PACKAGE_NAME               VARCHAR2(30) := 'EGO_ITEM_PEOPLE_IMPORT_PKG';
  --
  --  Batch Sizes for the job
  --
  SMALL_BATCH_SIZE             NUMBER    := 1000;
  RECOMMENDED_BATCH_SIZE       NUMBER    := 5000;
  LARGE_BATCH_SIZE             NUMBER    := 10000;
  --
  --  Return values for RETCODE parameter (standard for concurrent programs)
  --
  RETCODE_SUCCESS              VARCHAR2(1)    := '0';
  RETCODE_WARNING              VARCHAR2(1)    := '1';
  RETCODE_ERROR                VARCHAR2(1)    := '2';
  --
  --  Input values for DEBUG_MODE parameter
  --
  DEBUG_MODE_FATAL             NUMBER    := 1;
  DEBUG_MODE_ERROR             NUMBER    := 2;
  DEBUG_MODE_INFO              NUMBER    := 3;
  DEBUG_MODE_DEBUG             NUMBER    := 4;
  --
  --  Scope of logging errors  LOG_MODE
  --
  LOG_INTO_TABLE_ONLY          NUMBER    := 1;
  LOG_INTO_FILE_ONLY           NUMBER    := 2;
  LOG_INTO_TABLE_AND_FILE      NUMBER    := 3;
  --
  --  Variables for ORDER BY clause
  --
  ORDER_BY_DELETE              NUMBER    := 10;
  ORDER_BY_UPDATE              NUMBER    := 20;
  ORDER_BY_SYNC                NUMBER    := 30;
  ORDER_BY_CREATE              NUMBER    := 40;
  ORDER_BY_OTHERS              NUMBER    := 99;
  --
  --  List of PROCESS_STATUS
  --
  G_PS_TO_BE_PROCESSED         NUMBER    := 1;
        -- ProcessStatus : To Be Processed
        -- the status when the record is loaded into ego_item_people_intf
  G_PS_IN_PROCESS              NUMBER    := 2;
        --ProcessStatus : In Process
	-- the status when the record has valid data viz.,
	-- the user name, item name, organization code, role name,
	-- grantee_type and grantee_name combination, start_date <= end_date is found
  G_PS_ERROR                   NUMBER    := 3;
        --ProcessStatus : Error
	-- the given record is invalid
  G_PS_SUCCESS                 NUMBER    := 4;
        --ProcessStatus : Sucess
	-- after inserting the record into fnd_grants
  G_PS_WARNING                 NUMBER    := 5;
        --ProcessStatus : Warning
	-- to be implemented in Phase II
  G_PS_VALID_FND_GRANTS        NUMBER    := 6;
        -- ProcessStatus: Valid against FND_GRANTS
	-- used as the flag to check against the records validated against fnd_grants
	-- temporary status and will be immediately set to G_PS_TO_BE_PROCESSED or G_PS_ERROR
  G_PS_TO_BE_REPROCESSED       NUMBER    := 7;
        --ProcessStatus : To Be Re-Processed

-- =================================================================
-- Global variables to hold logging attributes
-- =================================================================

    g_fd utl_file.file_type;                 -- Log file descriptor
    G_TRACE_ON                NUMBER := 0;   -- Log ON state
    G_DBG_LVL                 NUMBER := 0;
    G_CONCREQ_VALID_FLAG      BOOLEAN := FALSE;
    G_FILE_INIT               BOOLEAN := FALSE;
    G_DBGPATH                 VARCHAR2(256) := '_';

-- =========================
-- PROCEDURES AND FUNCTIONS
-- =========================

  FUNCTION get_curr_dataset_id RETURN NUMBER;
    -- Start OF comments
    -- API name  : Load Interfance Lines
    -- TYPE      : Public (called by SQL Loader)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load interfance lines into FND_GRANTS.
    --             Errors are populated in MTL_INTERFACE_ERRORS


  PROCEDURE load_interface_lines
                 (
                   x_errbuff            OUT NOCOPY VARCHAR2,
                   x_retcode            OUT NOCOPY VARCHAR2,
                   p_data_set_id        IN     	NUMBER,
                   p_bulk_batch_size    IN     	NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.RECOMMENDED_BATCH_SIZE,
                   p_delete_lines       IN     	NUMBER   DEFAULT EGO_ITEM_PUB.G_INTF_DELETE_NONE,
                   p_debug_mode         IN     	NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.DEBUG_MODE_ERROR,
                   p_log_mode           IN     	NUMBER   DEFAULT EGO_ITEM_PEOPLE_IMPORT_PKG.LOG_INTO_TABLE_ONLY
                 );
    -- Start OF comments
    -- API name  : Load Interfance Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Process and Load interfance lines into FND_GRANTS.
    --             Errors are populated in MTL_INTERFACE_ERRORS
    --
    -- Parameters:
    --     IN    :
    --             p_data_set_id        IN      NUMBER
    --               The job number
    --
    --             p_bulk_batch_size 	IN      NUMBER default 1000
    --               Batch size used for Bulk Processing
    --
    --             p_delete_lines      IN      NUMBER
    --               How the lines are to be processed in the interface table:
    --                    DELETE_NONE          = 0  (Retain all lines)
    --                    DELETE_ALL           = 1  (delete all lines)
    --                    DELETE_ERROR         = 2  (delete all error lines)
    --                    DELETE_SUCCESS       = 3  (delete all successful lines)
    --
    --             p_debug_mode         IN      NUMBER
    --               To set the level of debugging to log to a file.
    --               valid values :
    --                    DEBUG_MODE_FATAL     = 1
    --                    DEBUG_MODE_ERROR     = 2  (for the end users)
    --                    DEBUG_MODE_INFO      = 3
    --                    DEBUG_MODE_DEBUG     = 4  (for developers)
    --
    --             p_log_mode           IN      NUMBER
    --               Where the LOG needs to be written
    --                    LOG_TABLE_ONLY        = 1 (log data to table only)
    --                    LOG_ERROR_FILE_ONLY   = 2 (log data to file only)
    --                    LOG_TABLE_AND_ERROR   = 3 (log data to table and file)
    --
    --     OUT    :
    --             x_retcode            OUT NOCOPY VARCHAR2,
    --             x_errbuff            OUT NOCOPY VARCHAR2

  PROCEDURE purge_interface_lines
                 ( x_errbuff            OUT NOCOPY VARCHAR2,
                   x_retcode            OUT NOCOPY VARCHAR2,
                   p_data_set_id        IN     	NUMBER,
                   p_closed_date        IN     	VARCHAR2,
		               p_delete_line_type   IN      NUMBER
                 );
    -- Start OF comments
    -- API name  : Clean Interface Lines
    -- TYPE      : Public (called by Concurrent Program)
    -- Pre-reqs  : None
    -- FUNCTION  : Removes all the interface lines
    --
    -- Parameters:
    --     IN    :
    --             p_data_set_id        IN      NUMBER
    --               The job number
    --
    --             p_closed_date        IN      VARCHAR2
    --               concurrent program does not let you pass date, only CHAR
    --               All records on or before the closed date will be deleted
    --
    --  Atleast one of the above two parameters should be given else
    --  the program will fail with insufficient parameters
    --
    --             p_delete_line_type   IN      NUMBER --  mandatory parameter
    --               How the lines are to be processed in the interface table:
    --                    DELETE_ALL      = 1  (delete all lines)
    --                    DELETE_ERROR    = 2  (delete all error lines)
    --                    DELETE_SUCCESS  = 3  (delete all successful lines)
    --
    --
    --     OUT    :
    --             x_retcode            OUT NOCOPY VARCHAR2,
    --             x_errbuff            OUT NOCOPY VARCHAR2


END EGO_ITEM_PEOPLE_IMPORT_PKG;

 

/

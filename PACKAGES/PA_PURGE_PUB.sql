--------------------------------------------------------
--  DDL for Package PA_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_PUB" AUTHID CURRENT_USER AS
-- $Header: PAXPURGS.pls 120.2 2007/10/20 12:16:02 bifernan noship $

--
--  PROCEDURE
--             START_PROCESS
--  PURPOSE
--	       This API is called from the executable of the concurrent program :
--	       ADM: Purge Obsolete Projects Data
--	       Based on the Purge Type Value selected in the Concurrent Program ,
--	       It calls respective APIs to do the purging.
--
--  Parameter Name	In/Out	Data Type	Null?	Default Value	Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_PURGE_TYPE	IN	VARCHAR2	NOT NULL     	      Indicates the purge option.
--  Valid values are:	ALL	DAILY_FCST_INFO	PROJECTS_WORKFLOWS	REPORTING_EXCEPTIONS
--
--  P_DEBUG_MODE	IN	VARCHAR2	NOT NULL 'N'	      Indicates the debug option.
--  Valid values are:	'Y'	'N'
--
--  P_COMMIT_SIZE	IN	NUMBER		NOT NULL  10000	      Indicates the commit size.
--  ERRBUF		OUT	VARCHAR2	N/A	  N/A	      Indicates the error buffer to the concurrent program.
--  RETCODE		OUT	VARCHAR2	N/A	  N/A         Indicates the return code to the concurrent program.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE START_PROCESS
(
errbuf        OUT NOCOPY VARCHAR2 ,
retcode       OUT NOCOPY VARCHAR2 ,
p_purge_type  IN  VARCHAR2 ,
p_debug_mode  IN  VARCHAR2 default 'N' ,
p_commit_size IN  NUMBER default  10000
);

--
--  PROCEDURE
--		PURGE_FORECAST_ITEMS
--  PURPOSE
--             This API purges unused forecast item data from the 3 tables pa_forecast_items ,pa_forecast_item_details
--	       and pa_fi_amount_details
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID 	IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS	OUT	VARCHAR2	N/A	  N/A	      Indicates the return status of the API.
--  Valid values are:	'S' for Success	'E' for Error	'U' for Unexpected Error
--
--  X_MSG_COUNT		OUT	NUMBER		N/A	  N/A	      Indicates the number of error messages
--								      in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--								      if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_FORECAST_ITEMS
(
p_debug_mode  IN  VARCHAR2 default  'N' ,
p_commit_size IN  NUMBER default  10000 ,
p_request_id  IN  NUMBER ,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count 	  OUT NOCOPY NUMBER,
x_msg_data 	  OUT NOCOPY VARCHAR2
);

--
--  PROCEDURE
--              PURGE_PROJ_WORKFLOW
--  PURPOSE
--             This API purges unused denormalized workflow data from 3 tables pa_wf_processes , pa_wf_process_details
--		and pa_wf_ntf_performers
--
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_PROJ_WORKFLOW
(
p_debug_mode  IN  VARCHAR2 default  'N' ,
p_commit_size IN  NUMBER default  10000 ,
p_request_id  IN  NUMBER ,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2
);

--
--  PROCEDURE
--              PURGE_REPORTING_EXCEPTIONS
--  PURPOSE
--		This API will purge unused reporting exception data from pa_reporting_exceptions
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PURGE_REPORTING_EXCEPTIONS
(
p_debug_mode  IN  VARCHAR2 default  'N' ,
p_commit_size IN  NUMBER default  10000 ,
p_request_id  IN  NUMBER ,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2
);

--
--  PROCEDURE
--              PURGE_ORG_AUTHORITY
--  PURPOSE
--             This API purges organization authority records of all terminated employees or contingent
--             workers whose termination date is earlier than system date
--
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  bifernan            16-October-2007            Created
--

PROCEDURE PURGE_ORG_AUTHORITY
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
);

--
--  PROCEDURE
--              PURGE_PJI_DEBUG
--  PURPOSE
--             This API purges the tables used by project performance summarization model to store
--             debug information.
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_DEBUG_MODE        IN      VARCHAR2        NOT NULL 'N'          Indicates the debug option.
--  P_COMMIT_SIZE       IN      NUMBER          NOT NULL  10000       Indicates the commit size.
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  bifernan            16-October-2007            Created
--

PROCEDURE PURGE_PJI_DEBUG
(
p_debug_mode    IN              VARCHAR2        DEFAULT  'N'    ,
p_commit_size   IN              NUMBER          DEFAULT  10000  ,
p_request_id    IN              NUMBER                          ,
x_return_status OUT     NOCOPY  VARCHAR2                        ,
x_msg_count     OUT     NOCOPY  NUMBER                          ,
x_msg_data      OUT     NOCOPY  VARCHAR2
);

--
--  PROCEDURE
--              PRINT_OUTPUT_REPORT
--  PURPOSE
--		This API will print the output report to concurrent log file.
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE PRINT_OUTPUT_REPORT
(
p_request_id  IN  NUMBER ,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2
);

--
--  PROCEDURE
--		INSERT_PURGE_LOG
--  PURPOSE
--		This API will populate the log table for deleted table information.
--
--  Parameter Name      In/Out  Data Type       Null?   Default Value   Description
--  -------------       ------  ----------      ------  -------------   ---------------------------------
--  P_REQUEST_ID        IN      NUMBER          NOT NULL              Indicates the concurrent request id.
--  P_TABLE_NAME        IN      VARCHAR2	NOT NULL              Indicates the table name deleted.
--  P_ROWS_DELETED      IN      NUMBER          NOT NULL              Indicates  the number of rows deleted.
--  X_RETURN_STATUS     OUT     VARCHAR2        N/A       N/A         Indicates the return status of the API.
--  Valid values are:   'S' for Success 'E' for Error   'U' for Unexpected Error
--
--  X_MSG_COUNT         OUT     NUMBER          N/A       N/A         Indicates the number of error messages
--                                                                    in the message stack.
--  X_MSG_DATA          OUT     VARCHAR2        N/A       N/A         Indicates the error message text
--                                                                    if only one error exists.

--  HISTORY
--  avaithia            01-March-2006            Created
--

PROCEDURE INSERT_PURGE_LOG
(
p_request_id IN  NUMBER ,
p_table_name IN  VARCHAR2 ,
p_rows_deleted   IN NUMBER ,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2
);

END PA_PURGE_PUB;

/

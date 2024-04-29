--------------------------------------------------------
--  DDL for Package FTE_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_BULKLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEBKLDS.pls 120.3 2005/08/24 06:33:35 pkaliyam ship $ */

  --
  -- Package FTE_BULKLOAD_PKG
  --   	     (Documentation in package body)
  --

  g_debug_on 	BOOLEAN := false;
  g_upload_dirname	   VARCHAR2(300) ;
  g_upload_dir_set	   BOOLEAN := false;

  TYPE var_arr4000 IS TABLE OF VARCHAR2(4000);
  TYPE var_arr100 IS TABLE OF VARCHAR2(100);

  TYPE array_tbl IS TABLE OF STRINGARRAY INDEX BY BINARY_INTEGER;
  TYPE data_values_tbl IS TABLE OF VARCHAR2(2000)  INDEX BY VARCHAR2(50);
  TYPE block_data_tbl IS TABLE OF data_values_tbl INDEX BY BINARY_INTEGER;
  TYPE block_header_index_tbl IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE block_header_tbl IS TABLE OF NUMBER INDEX BY VARCHAR2(50);

  g_block_header_index	block_header_index_tbl;
  g_load_id	NUMBER;

  G_DATE_FORMAT CONSTANT 	VARCHAR2(25) := 'MM-DD-YYYY hh24:mi:ss';
  G_TIME_FORMAT CONSTANT	VARCHAR2(15) := 'hh24:mi';
  G_DATE_FORMAT2 CONSTANT	VARCHAR2(25) := 'YYYY-MM-DD';
  G_DATE_FORMAT3 CONSTANT	VARCHAR2(30) := 'DD-MON-RRRR';

  ------------------------------------------------------------------
  -- Procedure: GET_PROCESS_ID
  -- Purpose: get the process id for qp interface tables
  -- Return: process_id for qp_interface tables, also known as load_id
  -------------------------------------------------------------------
  FUNCTION GET_PROCESS_ID RETURN NUMBER;

  ----------------------------------------------------------------------------------------------
  -- Procedure: SUBMIT_DATA
  -- Purpose: Create a new row in the database table 'FTE_BULKLOAD_DATA' with the
  --	      specified parameters when user uses the local file option. This represents a new
  --          bulkloading request to the concurrent manager.
  --
  -- IN parameters:
  --  	1. p_FileName: 	name of the file to submit
  --    2. p_LoadId: 	id of the load
  -- 	3. p_FileType: 	type of the file
  --    4. p_LoadType: 	type of load
  --    5. p_RequestId:	id to return to user.
  --
  -- RETURN: 0 ==> Operation succeeded.
  --  	     1 ==> File Not Found
  --         2 ==> Invalid File - No Template (For DTT Upload- Pack J [ABLUNDEL][2003/06/13])
  --         3 ==> Invalid File Length (For DTT Upload- Pack J [ABLUNDEL][2003/06/13])
  -- Propagate all other errors to the caller.
  -----------------------------------------------------------------------------------------------
  FUNCTION SUBMIT_DATA (
	 p_FileName     IN    VARCHAR2,
	 p_LoadId       IN    NUMBER,
	 p_FileType     IN    VARCHAR2,
	 p_LoadType     IN    VARCHAR2,
	 p_RequestId    IN    NUMBER  ) RETURN NUMBER;

  --------------------------------------------------------------------------------
  -- Procedure: UPDATE_RID
  --
  -- Purpose: Update the row specified by the parameters with the request ID of the.
  -- 	      concurrent request. The row should already exist in the database.
  --
  -- IN parameters:
  -- 	1. p_FileName: 	file name
  --	2. p_LoadId: 	loading id
  -- 	3. p_FileType:	type of file
  -- 	4. p_LoadType: 	loading type
  --	5. p_RequestId:	the Id that need to be updated.
  --------------------------------------------------------------------------------
  PROCEDURE UPDATE_RID (
	 p_FileName     IN    VARCHAR2,
	 p_LoadId       IN    NUMBER,
	 p_FileType     IN    VARCHAR2,
	 p_LoadType     IN    VARCHAR2,
	 p_RequestId    IN    NUMBER  );

  -------------------------------------------------------------------------------------------
  -- Procedure: UPLOAD_FILE
  --
  -- Purpose: Retrieve information on a load from the database with load id as the parameter
  --
  -- IN parameters:
  --	1. p_LoadId: 	loading id
  --
  -- OUT parameters:
  --	1. p_LoadType:  	type of load
  --	2. p_FileContents:	file
  --	3. p_FileName:		name of file
  -- 	4. p_DirName:		name of the file directory
  -- 	5. p_ExitStatus:	status
  --------------------------------------------------------------------------------------------
  PROCEDURE UPLOAD_FILE (
	p_LoadId	IN    NUMBER,
	p_LoadType	OUT   NOCOPY  VARCHAR2,
	p_FileContents	OUT   NOCOPY  BLOB,
	p_FileName	OUT   NOCOPY  VARCHAR2,
	p_DirName	OUT   NOCOPY  VARCHAR2,
	p_ExitStatus	OUT   NOCOPY  NUMBER);

  -----------------------------------------------------------------------------------
  -- Procedure: PROCESS_DATA
  --
  -- Purpose: Read the input file into blocks and call approriate loader packages
  --
  -- IN parameters:
  --    1. p_load_id: 		loading id
  --    2. p_src_filename: 	filename
  --	3. p_currency: 		currency for LTL loader
  --    4. p_uom_code: 		uom for LTL load
  --    5. p_orig_country: 	origin country for LTL load
  --    6. p_dest_country: 	destination country for LTL load
  --	7. p_service_code: 	service level code for LTL load
  -- 	8. p_action_code: 	LTL load action
  --  	9. p_tariff_name: 	LTL load tariff name
  --   10. p_user_debug: 	debug option
  -- OUT parameters:
  --    1. x_status:		-1 for no error
  --	2. x_error_msg: 	error message if status <> -1
  -----------------------------------------------------------------------------------
  PROCEDURE PROCESS_DATA (
	ERRBUF	    OUT NOCOPY VARCHAR2,
         RETCODE    OUT NOCOPY VARCHAR2,
	p_load_id	IN  		NUMBER,
	p_src_filename  IN  		VARCHAR2,
	p_currency    	IN  		VARCHAR2,
	p_uom_code      IN  		VARCHAR2,
	p_origin_country  IN  		VARCHAR2,
	p_dest_country	IN		VARCHAR2,
        p_service_code  IN          	VARCHAR2,
        p_action_code   IN          	VARCHAR2,
        p_tariff_name   IN          	VARCHAR2,
	p_user_debug    IN  		NUMBER);

  -----------------------------------------------------------------------------
  -- PROCEDURE LOAD_FILE
  --
  -- Purpose:  This is the starting point of the bulkloading process. Submits a
  --           request to a concurrent program, that starts the rate chart loading
  --           process.
  --
  -- IN Parameters
  --    1. p_load_id: 		The load id of the job
  --    2. p_src_filename: 	file name to be loaded
  --    3. p_currency: 		currency for LTL load
  --    4. p_uom_code: 		uom for LTL load
  --    5. p_orig_country: 	origin country for LTL load
  --    6. p_dest_country: 	destination country for LTL load
  --	7. p_service_code: 	service level code for LTL load
  -- 	8. p_action_code: 	LTL load action
  --  	9. p_tariff_name: 	LTL load tariff name
  --   10. p_resp_id:
  --   11. p_resp_appl_id:
  --   12. p_user_id:
  --   13. p_user_debug:	debug option

  -- Out Parameters
  --    1. x_request_id: The request id of the bulkload process
  --    2. x_error_msg:
  -----------------------------------------------------------------------------
  PROCEDURE LOAD_FILE (
	p_load_id       IN         NUMBER,
        p_src_filename  IN         VARCHAR2,
        p_currency      IN         VARCHAR2,
        p_uom_code      IN         VARCHAR2,
        p_origin_country  IN       VARCHAR2,
	p_dest_country	IN	   VARCHAR2,
        p_service_code  IN         VARCHAR2,
        p_action_code   IN         VARCHAR2,
        p_tariff_name   IN         VARCHAR2,
        p_resp_id       IN         NUMBER,
        p_resp_appl_id  IN         NUMBER,
        p_user_id       IN         NUMBER,
        p_user_debug    IN         NUMBER,
        x_request_id    OUT NOCOPY NUMBER,
        x_error_msg     OUT NOCOPY VARCHAR2);

  -----------------------------------------------------------------------------
  -- FUNCTION GET_UPLOAD_DIR
  -- Purpose: get the upload dir from the global variable
  -- return the directory
  -----------------------------------------------------------------------------
  FUNCTION GET_UPLOAD_DIR RETURN VARCHAR2;

END FTE_BULKLOAD_PKG;

 

/

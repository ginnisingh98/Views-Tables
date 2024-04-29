--------------------------------------------------------
--  DDL for Package Body FTE_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_BULKLOAD_PKG" AS
/* $Header: FTEBKLDB.pls 120.6 2005/08/19 00:12:46 pkaliyam noship $ */

  -- -----------------------------------------------------------------------------
  --                                                                           	--
  -- NAME:        FTE_BULKLOAD_PKG					       	--
  -- TYPE:        PACKAGE BODY                                                 	--
  -- DESCRIPTION: Contains procedures for storing bulkload request data in     	--
  --		 table FTE_BULKLOAD_DATA				       	--
  --                                                                           	--
  -- PROCEDURES and FUNCTIONS:						       	--
  --		 FUNCTION 	GET_PROCESS_ID					--
  --				SUBMIT_DATA				       	--
  --				GET_UPLOAD_DIR				       	--
  --				ADD_ROW					       	--
  --		 PROCEDURES 	LOAD_FILE				       	--
  --	 	 		PROCESS_DATA				       	--
  --		 		READ_BLOCK_FROM_TABLE			       	--
  -- 		 		READ_BLOCK_FROM_DIR			       	--
  --				PROCESS_BLOCK				       	--
  --		 		UPDATE_RID				       	--
  --			 	UPLOAD_FILE 				       	--
  --                                                                           	--
  ----------------------------------------------------------------------------- --

  G_PKG_NAME		VARCHAR2(50) := 'FTE_BULKLOAD_PKG';
  g_carriage_return    	VARCHAR2(1) := Fnd_Global.Local_Chr(13);
  g_linefeed           	VARCHAR2(1) := Fnd_Global.Local_Chr(10);
  g_tab			VARCHAR2(1) := Fnd_Global.Local_Chr(9);

  ------------------------------------------------------------------
  -- Procedure: GET_PROCESS_ID
  -- Purpose: get the process id for qp interface tables
  -- Return: process_id for qp_interface tables, also known as load_id
  -------------------------------------------------------------------
  FUNCTION GET_PROCESS_ID RETURN NUMBER IS
  l_id NUMBER;
  BEGIN
    SELECT  qp_process_id_s.nextval
      INTO l_id
      FROM dual;
    RETURN l_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      RETURN -2;
  END GET_PROCESS_ID;

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
  FUNCTION SUBMIT_DATA ( p_FileName     IN    VARCHAR2,
      			 p_LoadId       IN    NUMBER,
      			 p_FileType     IN    VARCHAR2,
      			 p_LoadType     IN    VARCHAR2,
      			 p_RequestId    IN    NUMBER   ) RETURN NUMBER IS

  v_FileContents       	BLOB;
  v_FileLocator	   	BFILE;
  v_sql_stmt           	VARCHAR2(200);
  v_LastUpdateDate	DATE;
  v_FileExists	   	NUMBER;
  v_DirName	 	VARCHAR2(500);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.SUBMIT_DATA';

  cursor c_check_dtt_file(ci_file_name VARCHAR2) IS
   select fmdf.template_id
   from   fte_mile_download_files fmdf
   where  fmdf.file_name = ci_file_name;

  l_dtt_file_check NUMBER;
  l_dtt_file_name  VARCHAR2(50);

  BEGIN

    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name ', p_FileName);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID   ', p_LoadId);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Type ', p_FileType);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load Type ', p_LoadType);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Request ID', p_RequestId);
    END IF;

    IF (p_LoadType NOT IN ('LTL_ASSOC', 'DTT_DWNLD')) THEN
      IF p_FileName IS NULL THEN
    	IF (g_debug_on) THEN
	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'No filename supplied', WSH_DEBUG_SV.c_proc_level);
	END IF;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
      	RETURN 1;
      END IF;
    END IF;

    v_DirName := get_upload_dir;
    BEGIN
      v_sql_stmt := 'CREATE OR REPLACE DIRECTORY UPLOAD_DIR AS ''' || v_DirName || '''';
      EXECUTE IMMEDIATE v_sql_stmt;

      IF (p_LoadType NOT IN ('LTL_ASSOC', 'DTT_DWNLD')) THEN
        -- initialize the BFILE locator for reading
	v_FileLocator := BFILENAME('UPLOAD_DIR', p_FileName);
       	v_FileExists := DBMS_LOB.FILEEXISTS(v_FileLocator);
	IF v_FileExists <> 1 THEN
    	  IF (g_debug_on) THEN
	    FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Not Found', WSH_DEBUG_SV.c_proc_level);
	  END IF;
	  FTE_UTIL_PKG.Exit_Debug(l_module_name);
	  RETURN 1;
        END IF;
      END IF;


      --+
      -- [ABLUNDEL][PACK J][DEV][2003/06/13]
      -- Added check if the file upload is a DTT, we need to check if the
      -- file is valid or not
      --+
      IF (p_LoadType = 'DTT_UPLOAD') THEN
        --+
        -- parse the file name to get the first 8 characters, the
        -- DTT file should be in the format of 'DLF'+5 numbers+'.'+file_extension
        -- e.g. 'DLF00001.OUT' - after parsing gives us 'DLF00001'
        --+
        l_dtt_file_name := substr(p_FileName,1,(instr(p_FileName,'.')-1));
        --+
        -- DTT Upload file should be 8 chars in length
        --+

        IF (length(l_dtt_file_name) <> 8) THEN
    	  IF (g_debug_on) THEN
            FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'DTT filename supplied is invalid - invalid length',
					WSH_DEBUG_SV.c_proc_level);
	  END IF;
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN 3;
        END IF;

        l_dtt_file_check := null;

        OPEN c_check_dtt_file(l_dtt_file_name);
        FETCH c_check_dtt_file INTO l_dtt_file_check;
        CLOSE c_check_dtt_file;

        IF (l_dtt_file_check is null) THEN
          --+
          -- Upload File is invalid
          --+
	  IF (g_debug_on) THEN
            FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'DTT filename supplied is invalid - not associated with a template',
					WSH_DEBUG_SV.c_proc_level);
	  END IF;
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN 2;
        END IF;
      END IF;
      --+
      -- End of Pack J addition for DTT file upload
      --+

      v_LastUpdateDate := sysdate;
      INSERT INTO FTE_BULKLOAD_DATA (LOAD_ID,
				     LOAD_TYPE,
				     FILE_TYPE,
				     FILE_NAME,
				     FILE_SIZE,
				     REQUEST_ID,
				     CONTENT,
				     CREATED_BY,
				     CREATION_DATE,
				     LAST_UPDATED_BY,
				     LAST_UPDATE_DATE,
				     LAST_UPDATE_LOGIN)

      VALUES (p_LoadId, p_LoadType, p_FileType, p_FileName,
	      0, p_RequestId, EMPTY_BLOB(), FND_GLOBAL.USER_ID,
	      v_LastUpdateDate, FND_GLOBAL.USER_ID, v_LastUpdateDate, FND_GLOBAL.USER_ID);

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN 0;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF (c_check_dtt_file%ISOPEN) THEN
	CLOSE c_check_dtt_file;
      END IF;

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN 4;
  END SUBMIT_DATA;

  -----------------------------------------------------------------------------
  -- FUNCTION GET_UPLOAD_DIR
  -- Purpose: get the upload dir from the global variable
  -- return the directory
  -----------------------------------------------------------------------------
  FUNCTION GET_UPLOAD_DIR RETURN VARCHAR2 IS
  l_db_name	   VARCHAR2(30);

  BEGIN
    fnd_profile.get('FTE_BULKLOAD_DIR',g_upload_dirname);
    return g_upload_dirname;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END GET_UPLOAD_DIR;

  ----------------------------------------------------------------------------------
  -- Function: ADD_ROW
  --
  -- Purpose: Adding a row to a table of STRINGARRAYs from values in p_tokens.
  --
  -- IN parameters:
  -- 	1. p_tokens:  array of values parsed from the file to be stored
  --	2. p_table:   a pl/sql table of STRINGARRAY
  --	3. p_col:     a boolean, true if this line is a column header line, false else
  --
  -- Returns a number: -1 for no error, 1 for too few items in p_tokens, 2 for too many
  ----------------------------------------------------------------------------------
  FUNCTION ADD_ROW(p_tokens		IN	STRINGARRAY,
		   p_block_header 	IN OUT NOCOPY	block_header_tbl,
		   p_block_data   	IN OUT NOCOPY	block_data_tbl,
		   p_col		IN 	BOOLEAN) RETURN NUMBER IS

  l_module_name   	 CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.ADD_ROW';
  l_count 	NUMBER;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    IF (g_debug_on) THEN
      FOR i in 1..p_tokens.COUNT LOOP
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_tokens i', p_tokens(i));
      END LOOP;
      IF (p_col) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_col', 'TRUE');
      ELSE
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_col', 'FALSE');
      END IF;
    END IF;

    IF (p_block_data IS NULL) THEN
      l_count := 1;
    ELSE
      l_count := p_block_data.COUNT + 1;
    END IF;

    IF (p_col) THEN
      FOR i in 1..p_tokens.COUNT LOOP
--	IF (TRIM(' ' FROM replace(replace(p_tokens(i), ' ', '_'), '*', '')) IS NOT NULL) THEN
	IF (TRIM(' ' FROM replace(p_tokens(i), '*', '')) IS NOT NULL) THEN
--	  g_block_header_index(i) := replace(replace(TRIM(p_tokens(i)), ' ', '_'), '*', '');
--	  p_block_header(replace(replace(TRIM(p_tokens(i)), ' ', '_'), '*', '')) := i;
	  g_block_header_index(i) := replace(TRIM(p_tokens(i)), '*', '');
	  p_block_header(replace(TRIM(p_tokens(i)), '*', '')) := i;
        END IF;
      END LOOP;
    ELSE
      FOR i in 1..g_block_header_index.COUNT LOOP  -- only copy till the size of the header column
	IF (p_tokens.COUNT >= i) THEN  -- if the items are less than the column counts, then copy null to rest
  	  p_block_data(l_count)(g_block_header_index(i)) := TRIM(' ' FROM p_tokens(i));
      	ELSE
	  p_block_data(l_count)(g_block_header_index(i)) := NULL;
 	END IF;
      END LOOP;
    END IF;

    IF (g_debug_on) THEN
      FOR i in 1..g_block_header_index.COUNT LOOP
        IF (p_block_data.COUNT > 0) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, g_block_header_index(i), p_block_data(l_count)(g_block_header_index(i)));
        ELSE
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, g_block_header_index(i));
        END IF;
      END LOOP;
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RETURN -1;

  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN 1;
  END ADD_ROW;

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
  PROCEDURE LOAD_FILE ( p_load_id         IN         NUMBER,
                        p_src_filename    IN         VARCHAR2,
                        p_currency        IN         VARCHAR2,
                        p_uom_code        IN         VARCHAR2,
                        p_origin_country  IN         VARCHAR2,
		       	p_dest_country	  IN	     VARCHAR2,
                        p_service_code    IN         VARCHAR2,
                        p_action_code     IN         VARCHAR2,
                        p_tariff_name     IN         VARCHAR2,
                        p_resp_id         IN         NUMBER,
                        p_resp_appl_id    IN         NUMBER,
                        p_user_id         IN         NUMBER,
                        p_user_debug      IN         NUMBER,
                        x_request_id      OUT NOCOPY NUMBER,
                        x_error_msg       OUT NOCOPY VARCHAR2) IS

  l_program       VARCHAR2(256);
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.LOAD_FILE';
  x_status 	  NUMBER := -1;

  BEGIN

    FTE_UTIL_PKG.INIT_DEBUG(p_user_debug);
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name   ', p_src_filename);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID     ', p_load_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency    ', p_currency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'UOM code    ', p_uom_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Origin Country', p_origin_country);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Dest Country ', p_dest_country);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service code ', p_service_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action code  ', p_action_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Tariff Name  ', p_tariff_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'User Debug   ', p_user_debug);
    END IF;

    fnd_global.apps_initialize(user_id      => p_user_id,
                               resp_id      => p_resp_id,
                               resp_appl_id => p_resp_appl_id);

    --+
    -- The non-null tariff name parameter indicates
    -- the load is of type LTL.
    --+
    IF (p_tariff_name IS NULL) THEN
       l_program := 'FTE_BULKLOADER';
    ELSE
       l_program := 'FTE_LTL_BULK_LOADER';
    END IF;

    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'FTE',
                                               program      => l_program,
                                               description  => null,
                                               start_time   => null,
                                               sub_request  => false,
                                               argument1    => p_load_id,
					       argument2    => p_src_filename,
                                               argument3    => p_currency,
                                               argument4    => p_uom_code,
                                               argument5    => p_origin_country,
					       argument6    => p_dest_country,
					       argument7    => p_service_code,
					       argument8    => p_action_code,
					       argument9    => p_tariff_name,
					       argument10   => p_user_debug);


    x_error_msg := fnd_message.get;
    COMMIT;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'x_error_msg ', x_error_msg);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'x_request_id', x_request_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_user_id   ', p_user_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_resp_id   ',p_resp_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'p_resp_appl_id', p_resp_appl_id);
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O');
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  END LOAD_FILE;

  ------------------------------------------------------------------------------------
  -- Procedure: PROCESS_BLOCK
  --
  -- Purpose: Call the approrite PROCESS_DATA procedure from different packages
  --
  -- IN parameters:
  -- 	1. p_block_type: 	the type of block
  -- 	2. p_table:		table
  --	3. p_line_number:	line number for the first line of the block
  --
  -- OUT parameters:
  --	1. x_status:		status of procedure, -1 is no error
  --	2. x_error_msg:		error message if any
  --
  -- According to different types of blocks, the number of columns vary and uses different table
  ------------------------------------------------------------------------------------
  PROCEDURE PROCESS_BLOCK(p_block_type	 IN	VARCHAR2,
			  p_block_header IN 	block_header_tbl,
			  p_block_data   IN	block_data_tbl,
 			  p_line_number	 IN	NUMBER,
			  x_status	OUT NOCOPY NUMBER,
			  x_error_msg	OUT NOCOPY VARCHAR2) IS

  l_module_name   	 CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_BLOCK';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (p_block_type IN ('RATE_CHART', 'RATE_LINE', 'RATE_BREAK','RATING_ATTRIBUTE',
                	 'CHARGES_DISCOUNTS', 'CHARGES_DISCOUNTS_LINE', 'ADJUSTED_RATE_CHART')) THEN

      FTE_RATE_CHART_LOADER.PROCESS_DATA(p_type		=> p_block_type,
				     	 p_block_header	=> p_block_header,
					 p_block_data	=> p_block_data,
					 p_line_number	=> p_line_number,
				     	 x_status	=> x_status,
				     	 x_error_msg 	=> x_error_msg);
    ELSIF (p_block_type IN ('REGION', 'ZONE')) THEN
      FTE_REGION_ZONE_LOADER.PROCESS_DATA(p_type		=> p_block_type,
				   p_block_header	=> p_block_header,
				   p_block_data		=> p_block_data,
				   p_line_number 	=> p_line_number,
				   x_status		=> x_status,
				   x_error_msg 		=> x_error_msg);
    ElSIF (p_block_type IN ('SCHEDULE', 'SERVICE', 'SERVICE_RATING_SETUP')) THEN
      FTE_LANE_LOADER.PROCESS_DATA(p_type 		=> p_block_type,
				   p_block_header	=> p_block_header,
				   p_block_data		=> p_block_data,
				   p_line_number 	=> p_line_number,
				   x_status		=> x_status,
				   x_error_msg 		=> x_error_msg);
    ELSIF (p_block_type IN ('RATING_ZONE_CHART', 'RATING_SETUP', 'ORIGIN', 'DESTINATION')) THEN
      FTE_PARCEL_LOADER.PROCESS_DATA(p_type		=> p_block_type,
				     p_block_header	=> p_block_header,
				     p_block_data	=> p_block_data,
				     p_line_number 	=> p_line_number,
				     x_status		=> x_status,
				     x_error_msg	=> x_error_msg);
    ELSIF (UPPER(p_block_type) IN ('TL_SERVICES', 'TL_SURCHARGES', 'FACILITY_CHARGES', 'TL_BASE_RATES')) THEN
      FTE_TL_LOADER.PROCESS_DATA(p_type		=> p_block_type,
                                 p_block_header	=> p_block_header,
                                 p_block_data	=> p_block_data,
                                 p_line_number 	=> p_line_number,
                                 x_status	=> x_status,
                                 x_error_msg	=> x_error_msg);
    ELSE
      x_status := 2;
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_TYPE_UNKNOWN',
                                          P_Tokens => STRINGARRAY('TYPE'),
					  P_values => STRINGARRAY(p_block_type));
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
				 p_msg 		=> x_error_msg,
				 p_category	=> 'D',
				 p_line_number	=> p_line_number);
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_status := 2;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number-1);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  END PROCESS_BLOCK;

  ---------------------------------------------------------------------------------------------------
  -- Procedure: READ_BLOCK_FROM_DIR
  --
  -- Purpose: Reading a file from the server directory, storing each block in the file in a
  --	      pl/sql table and call the specific loader packages.
  --
  -- IN parameters:
  --	1. p_file_name:	file name to be read
  --	2. p_load_id: 	loading id
  --
  -- OUT parameters:
  -- 	1. x_status:	status of the process, -1 is no errors
  -- 	2. x_error_msg:	error message when status <> -1
  ---------------------------------------------------------------------------------------------------
  PROCEDURE READ_BLOCK_FROM_DIR (p_file_name 	IN		VARCHAR2,
				 p_load_id 	IN		NUMBER,
			   	 x_status	OUT NOCOPY	NUMBER,
			   	 x_error_msg  	OUT NOCOPY	VARCHAR2) IS

  l_tokens		STRINGARRAY;
  l_debug_on	   	BOOLEAN;
  l_module_name   	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.READ_BLOCK_FROM_DIR';
  x_chart_file          UTL_FILE.file_type;
  l_src_file_dir        VARCHAR2(500);
  l_line		VARCHAR2(1000);
  l_block_type		VARCHAR2(100) := NULL;
  l_section_line	BOOLEAN := TRUE;
  l_body_block  	BOOLEAN := FALSE;
  l_column_line		BOOLEAN := FALSE;
  l_last_line_null	BOOLEAN := FALSE;
  l_processed_lines	NUMBER := 0;
  l_block_header 	block_header_tbl;
  l_block_data   	block_data_tbl;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);
    x_status := -1;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name', p_file_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID', p_load_id);
    END IF;

    l_src_file_dir := Fte_Bulkload_Pkg.Get_Upload_Dir;
    x_chart_file := utl_file.fopen(l_src_file_dir, p_file_name, 'R');

    LOOP
      utl_file.get_line(x_chart_file, l_line);
      l_line := replace(l_line, g_carriage_return, ''); --dos2unix conversion
      l_line := TRIM(' ' FROM l_line);

      IF l_section_line THEN

	IF ((replace(replace(l_line, g_tab, ''), ' ', '')) IS NOT NULL) THEN
  	  IF ((l_line IS NOT NULL) AND (l_line NOT IN ('%HEADER%'))) THEN
	    l_last_line_null := FALSE;
	    l_block_type := Trim(' ' FROM upper(replace(l_line, g_tab, '')));
	    l_section_line := FALSE;
	    l_body_block := TRUE;
	    l_column_line := TRUE;
	  END IF;
          l_processed_lines := l_processed_lines +1;
	END IF;

      ELSIF l_body_block THEN

	-- build the pl/sql table with the block
	IF ((replace(replace(l_line, g_tab, ''), ' ', '')) IS NOT NULL) THEN

	  l_last_line_null := FALSE;

	  l_tokens := FTE_UTIL_PKG.TOKENIZE_STRING(l_line, g_tab);

	  x_status := ADD_ROW(l_tokens, l_block_header, l_block_data, l_column_line);

	  IF (x_status = 1) THEN
	    -- too few values in p_tokens
    	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
	  ELSIF (x_status = 2) THEN
	    -- too many values in p_tokens
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          END IF;

	  IF (l_column_line) THEN -- if column line is this line, next line wont' be a column line
	    l_column_line := FALSE;
	  END IF;
	ELSE

	  IF (l_column_line) THEN
	    --throw error about no information
	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BLOCK_NO_LINE',
						p_tokens => STRINGARRAY('BLOCK'),
						p_values => STRINGARRAY(l_block_type));
	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
             			  	p_msg   	=> x_error_msg,
             			  	p_category    	=> 'A');

  	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    x_status := 1;
	    RETURN;
	  END IF;

	  l_last_line_null := TRUE;
	  l_section_line := TRUE;
	  l_body_block := FALSE;
	  --call packages to process block

          IF (g_debug_on) THEN
	    FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_block_type', l_block_type);
	  END IF;

	  PROCESS_BLOCK(p_block_type 	=> l_block_type,
			p_block_header 	=> l_block_header,
			p_block_data	=> l_block_data,
			p_line_number	=> l_processed_lines-l_block_data.COUNT-1,
			x_status	=> x_status,
			x_error_msg	=> x_error_msg);

	  IF (x_status <> -1) THEN
	    --use line number to report the error
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
	  END IF;

	  l_block_header.DELETE;
	  l_block_data.DELETE;
	  g_block_header_index.DELETE;

	END IF;
	l_processed_lines := l_processed_lines +1;

      END IF;
    END LOOP;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Finished Reading File.');
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of lines processed', l_processed_lines);
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      utl_file.fclose(x_chart_file);

      IF (NOT l_last_line_null) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_block_type', l_block_type);
	PROCESS_BLOCK(p_block_type 	=> l_block_type,
		      p_block_header 	=> l_block_header,
		      p_block_data	=> l_block_data,
		      p_line_number	=> l_processed_lines - l_block_data.COUNT-1,
		      x_status		=> x_status,
		      x_error_msg	=> x_error_msg);

	IF (x_status <> -1) THEN
	  --use line number to report the error
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
	END IF;

	l_block_header.DELETE;
	l_block_data.DELETE;
	g_block_header_index.DELETE;

      END IF;
      l_processed_lines := l_processed_lines +1;

      IF (g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Finished Reading File.');
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of lines processed', l_processed_lines);
      END IF;

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
    WHEN UTL_FILE.INVALID_PATH THEN
--      x_error_msg := 'File ' || l_src_file_dir || '/' || p_file_name || ' Not Accessible' ||
--                     fnd_global.newline || 'Please make sure that the directory is accessible to UTL_FILE.';

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> 'FTE_FILE_NOT_ACCESSIBLE',
             			  p_category    => 'E');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
    WHEN UTL_FILE.INVALID_OPERATION THEN
--      x_error_msg := 'ERROR: The file does not exist, or file or directory access was denied by the operating system.'
--                     || fnd_global.newline || 'Please verify file and directory access privileges on the file system.';

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> 'FTE_FILE_NOT_EXIST',
             			  p_category    => 'E');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
    WHEN OTHERS THEN
      x_error_msg := 'Unexpected error while reading file: [Row ' || l_processed_lines || '].'
                     || fnd_global.newline || l_line || fnd_global.newline || sqlerrm;

      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, x_error_msg);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O',
	        		  p_line_number	=> l_processed_lines);
      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END READ_BLOCK_FROM_DIR;

  ---------------------------------------------------------------------------------------------------
  -- Procedure: READ_BLOCK_FROM_TABLE
  --
  -- Purpose: Reading a file from the database temp table, storing each block in the file in a
  --	      pl/sql table and call the specific loader packages.
  --
  -- IN parameters:
  --	1. p_file_name:	file name to be read
  --	2. p_load_id: 	loading id
  --
  -- OUT parameters:
  -- 	1. x_status:	status of the process, -1 is no errors
  -- 	2. x_error_msg:	error message when status <> -1
  ---------------------------------------------------------------------------------------------------
  PROCEDURE READ_BLOCK_FROM_TABLE (p_file_name		IN		VARCHAR2,
			     	   p_load_id		IN		NUMBER,
			     	   x_status		OUT NOCOPY	NUMBER,
			     	   x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_size                NUMBER;
  l_language		VARCHAR2(40);
  l_content             BLOB;
  l_amount              BINARY_INTEGER := 12000;
  l_position            INTEGER := 1;
  data_buffer           VARCHAR2(32000);
  temp_buffer           VARCHAR2(32000);
  l_lines               STRINGARRAY;
  l_tokens		STRINGARRAY;
  l_debug_on	   	BOOLEAN;
  l_module_name   	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.READ_BLOCK_FROM_TABLE';
  l_block_type		VARCHAR2(100);
  l_section_line	BOOLEAN;
  l_body_block  	BOOLEAN;
  l_column_line		BOOLEAN;
  l_processed_lines	NUMBER := 0;
  l_block_header 	block_header_tbl;
  l_block_data   	block_data_tbl;
  l_last_block_processed BOOLEAN;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);
    x_status := -1;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name', p_file_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID', p_load_id);
    END IF;

    SELECT content, file_size INTO l_content, l_size
      FROM   fte_bulkload_data
      WHERE  file_name = p_file_name
      	AND  load_id = p_load_id;

    data_buffer := NULL;
    l_section_line := TRUE;
    l_column_line := FALSE;
    l_body_block := FALSE;
    l_block_type := NULL;
    l_last_block_processed := FALSE;

    WHILE l_size > 0 LOOP
      --read a big chunk at a time:
      dbms_lob.read (l_content, l_amount, l_position, temp_buffer);
      data_buffer := data_buffer || utl_raw.cast_to_varchar2(temp_buffer);
      data_buffer := replace(data_buffer, g_carriage_return, ''); --dos2unix conversion

      --Now tokenize by linefeed
      l_lines := FTE_UTIL_PKG.TOKENIZE_STRING(data_buffer, g_linefeed);

      FOR k IN 1..l_lines.COUNT-1 LOOP

        IF l_section_line THEN

	  IF ((replace(replace(l_lines(k), g_tab, ''), ' ', '')) IS NOT NULL) THEN
 	    IF (Trim(' ' FROM l_lines(k)) IS NOT NULL) AND (l_lines(k) NOT IN ('%HEADER%')) THEN
	      l_block_type := Trim(' ' FROM upper(replace(l_lines(k), g_tab, '')));
	      l_section_line := FALSE;
	      l_body_block := TRUE;
	      l_column_line := TRUE;
	      l_last_block_processed := FALSE;
	    END IF;
            l_processed_lines := l_processed_lines +1;
	  END IF;

        ELSIF l_body_block THEN

	  -- build the pl/sql table with the block
	  IF ((replace(replace(l_lines(k), g_tab, ''), ' ', '')) IS NOT NULL) THEN

	    l_tokens := FTE_UTIL_PKG.TOKENIZE_STRING(l_lines(k), g_tab);

	    x_status := ADD_ROW(l_tokens, l_block_header, l_block_data, l_column_line);

	    IF (x_status = 1) THEN
	      -- too few values in p_tokens
	      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_TOO_FEW_COLUMNS');
	      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
					  p_msg			=> x_error_msg,
					  p_category		=> 'D',
					  p_line_number		=> l_processed_lines+1);
    	      FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
	    ELSIF (x_status = 2) THEN
	      -- too many values in p_tokens
	      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_TOO_MANY_COLUMNS');
	      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
					  p_msg			=> x_error_msg,
					  p_category		=> 'D',
					  p_line_number		=> l_processed_lines+1);
	      FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
            END IF;

	    IF (l_column_line) THEN -- if column line is this line, next line wont' be a column line
	      l_column_line := FALSE;
	    END IF;
	  ELSE

	    l_section_line := TRUE;
	    l_body_block := FALSE;
	    l_last_block_processed := TRUE;
	    --call packages to process block

      	    IF (g_debug_on) THEN
      	      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_block_type', l_block_type);
 	    END IF;
	    PROCESS_BLOCK(p_block_type 	=> l_block_type,
		      	  p_block_header => l_block_header,
		      	  p_block_data	=> l_block_data,
			  p_line_number	=> l_processed_lines - l_block_data.COUNT-1,
			  x_status	=> x_status,
			  x_error_msg	=> x_error_msg);

	    IF (x_status <> -1) THEN
              FTE_UTIL_PKG.Exit_Debug(l_module_name);
              RETURN;
	    END IF;

	    l_block_header.DELETE;
	    l_block_data.DELETE;
	    g_block_header_index.DELETE;

	  END IF;
	  l_processed_lines := l_processed_lines +1;

        END IF;

      END LOOP; -- end for l_lines loop

      l_position := l_position + l_amount;
      l_size := l_size - l_amount;

      --Append the last remaining to the next chunk because it might not be complete
      data_buffer := l_lines(l_lines.COUNT);
    END LOOP;

    --process last line
    IF (NOT l_last_block_processed) THEN

      IF ((replace(data_buffer, ' ', '')) IS NOT NULL) THEN

   	l_tokens := FTE_UTIL_PKG.TOKENIZE_STRING(data_buffer, g_tab);

	x_status := ADD_ROW(l_tokens, l_block_header, l_block_data, l_column_line);

	IF (x_status = 1) THEN
	  -- too few values in p_tokens
    	  FTE_UTIL_PKG.Exit_Debug(l_module_name);
	  RETURN;
	ELSIF (x_status = 2) THEN
	  -- too many values in p_tokens
	  FTE_UTIL_PKG.Exit_Debug(l_module_name);
	  RETURN;
        END IF;

	IF (l_column_line) THEN -- if column line is this line, next line wont' be a column line
	  l_column_line := FALSE;
	END IF;
      END IF;

      l_section_line := TRUE;
      l_body_block := FALSE;
      --call packages to process block
      PROCESS_BLOCK(p_block_type 	=> l_block_type,
		    p_block_header 	=> l_block_header,
		    p_block_data	=> l_block_data,
		    p_line_number 	=> l_processed_lines - l_block_data.COUNT-1,
		    x_status		=> x_status,
		    x_error_msg		=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      l_block_header.DELETE;
      l_block_data.DELETE;
      g_block_header_index.DELETE;

      l_processed_lines := l_processed_lines +1;

    END IF;

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Finished Reading File.');
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of lines processed', l_processed_lines);
    END IF;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := 'Unexpected error while reading file: [Row ' || l_processed_lines || '].'
                     || fnd_global.newline || sqlerrm;

      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, x_error_msg);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O',
	        		  p_line_number	=> l_processed_lines);
      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END READ_BLOCK_FROM_TABLE;

  PROCEDURE PRINT_END_OF_REPORT IS

  l_msg VARCHAR2(2000);
  l_module_name         CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_DATA';

  BEGIN

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
                                 p_msg          => ' ',
                                 p_category     => NULL);

      l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_ROLLBACK'); -- Rolling back the above entities creation due to the error mentioned.

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
                                 p_msg          => ' ',
                                 p_category     => NULL);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
                                 p_msg          => l_msg,
                                 p_category     => NULL);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                 p_msg            => '+---------------------------------------------------------------------------+',
                                 p_category       => NULL);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
                                 p_msg          => ' ',
                                 p_category     => NULL);

      l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_END_REPORT');        --              *** End of BulkLoader Report ***

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                 p_msg            => l_msg,
                                 p_category       => NULL);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name  => l_module_name,
                                 p_msg          => ' ',
                                 p_category     => NULL);

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                 p_msg            => '+---------------------------------------------------------------------------+',
                                 p_category       => NULL);
  END PRINT_END_OF_REPORT;
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
  PROCEDURE PROCESS_DATA (ERRBUF	    OUT NOCOPY VARCHAR2,
			  RETCODE	    OUT NOCOPY VARCHAR2,
			  p_load_id	    IN  NUMBER,
			  p_src_filename    IN  VARCHAR2,
			  p_currency	    IN  VARCHAR2,
			  p_uom_code        IN  VARCHAR2,
			  p_origin_country  IN  VARCHAR2,
			  p_dest_country    IN	VARCHAR2,
                          p_service_code    IN  VARCHAR2,
                          p_action_code     IN  VARCHAR2,
                          p_tariff_name     IN  VARCHAR2,
			  p_user_debug      IN  NUMBER) IS

  l_blob 		BLOB;
  l_load_type 		VARCHAR2(20);
  l_file_name 		VARCHAR2(40);
  l_dir_name 		VARCHAR2(100);
  l_source		VARCHAR2(30);
  l_type		VARCHAR2(30);
  x_status              NUMBER;
  l_request_id          NUMBER;
  x_error_msg           VARCHAR2(1000);
  l_module_name   	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.PROCESS_DATA';
  l_msg 	        VARCHAR2(2000);

  BEGIN

    --+
    -- Start the DEBUGGER
    --+
    FTE_UTIL_PKG.INIT_DEBUG(p_user_debug);

    FTE_UTIL_PKG.ENTER_Debug(l_module_name);
    RETCODE := 0;

    g_load_id := p_load_id;

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name', p_src_filename);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID', p_load_id);
    END IF;

    UPLOAD_FILE(p_load_id, l_type, l_blob, l_file_name, l_dir_name, x_status);

    FND_PROFILE.GET('FTE_BULKLOAD_SOURCE_TYPE', l_source);

    IF (g_debug_on) THEN
       FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load type', l_type);
       FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Reading from ', l_source);
    END IF;

    --+
    -- Write the header for BulkLoader output file
    --+

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_START_REPORT');        --              *** Start of BulkLoader Report ***

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

     FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                p_msg            => ' ',
                                p_category       => NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_BULKLOAD_PROCESSING',    -- File Processed :
  			          p_tokens	=> STRINGARRAY('NAME'),
			          p_values	=> STRINGARRAY(p_src_filename));

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_BULKLOAD_TYPE',          -- Type of Load :
			          p_tokens	=> STRINGARRAY('TYPE'),
			          p_values	=> STRINGARRAY(l_type));

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_BULKLOAD_LOADID',        -- Load ID :
			          p_tokens	=> STRINGARRAY('ID'),
			          p_values	=> STRINGARRAY(p_load_id));

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_BULKLOAD_DEBUG',         -- Debug Enabled :
			          p_tokens	=> STRINGARRAY('DEBUG'),
			          p_values	=> STRINGARRAY(p_user_debug));

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '  ',
                               p_category       => NULL);

    IF (UPPER(l_source) = 'SERVER') THEN
        READ_BLOCK_FROM_DIR(p_file_name => p_src_filename,
	  		    p_load_id => p_load_id,
			    x_status => x_status,
			    x_error_msg => x_error_msg);
    ELSE
        READ_BLOCK_FROM_TABLE(p_file_name => p_src_filename,
			      p_load_id => p_load_id,
			      x_status => x_status,
			      x_error_msg => x_error_msg);
    END IF;

    IF (x_status <> -1) THEN
	ROLLBACK;
        RETCODE := 2;
	ERRBUF := x_error_msg;

        PRINT_END_OF_REPORT;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
    END IF;

    IF (l_type = 'LANE') THEN
      FTE_LANE_LOADER.SUBMIT_LANE(x_status 	=> x_status,
				  x_error_msg	=> x_error_msg);
    ELSIF (l_type = 'PRICELIST' OR l_type = 'MODLIST' OR l_type = 'LTL_MODLIST') THEN
      FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(x_status	=> x_status,
					      x_error_msg	=> x_error_msg);
    ELSIF (l_type = 'PRICE_ZONE_CHART') THEN
      FTE_PARCEL_LOADER.PROCESS_ZONES_AND_LANES(x_status	=> x_status,
			      			x_error_msg	=> x_error_msg);
    END IF;

    IF (x_status <> -1) THEN
      ROLLBACK;

      PRINT_END_OF_REPORT;

      RETCODE := 2;
      ERRBUF := x_error_msg;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_COMMIT'); -- Committing the above entities creation.    --

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                               p_msg		=> l_msg,
			       p_category	=> NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_END_REPORT');        --              *** End of BulkLoader Report ***

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
			       p_msg		=> l_msg,
			       p_category	=> NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE := 2;
      ERRBUF := sqlerrm;
      x_status := 2;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             		         p_msg         => sqlerrm,
             			 p_category    => 'O');
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END PROCESS_DATA;


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
  PROCEDURE UPDATE_RID( p_FileName     IN    VARCHAR2,
      		        p_LoadId       IN    NUMBER,
      			p_FileType     IN    VARCHAR2,
      			p_LoadType     IN    VARCHAR2,
      			p_RequestId    IN    NUMBER ) IS

  l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPDATE_RID';

  BEGIN
    --SETUP DEBUGGING
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Updating FTE_BUILLOAD_DATA', WSH_DEBUG_SV.c_proc_level);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name', p_filename);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID', p_loadid);
    END IF;

    IF (p_LoadType <> 'DTT_DWNLD') THEN
      UPDATE FTE_BULKLOAD_DATA
	 SET request_id = p_RequestId,
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
        WHERE load_id = p_LoadId AND
         load_type =  p_LoadType AND
         file_type =  p_FileType AND
         file_name =  p_FileName;

    ELSIF (p_LoadType = 'DTT_DWNLD') THEN
      UPDATE FTE_BULKLOAD_DATA
	 SET request_id = p_RequestId,
	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
        WHERE load_id = p_LoadId AND
         load_type =  p_LoadType;
    END IF;

    commit;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O');

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END UPDATE_RID;

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
  PROCEDURE UPLOAD_FILE (p_LoadId	IN   NUMBER,
			 p_LoadType	OUT  NOCOPY   VARCHAR2,
			 p_FileContents	OUT  NOCOPY   BLOB,
			 p_FileName	OUT  NOCOPY   VARCHAR2,
			 p_DirName	OUT  NOCOPY   VARCHAR2,
			 p_ExitStatus	OUT  NOCOPY   NUMBER) IS

  v_FileLocator	   BFILE;
  v_FileSize	   NUMBER;
  v_sql_stmt       VARCHAR2(200);
  v_LastUpdateDate DATE;
  l_source_type	   VARCHAR2(40);

  l_debug_on	   BOOLEAN;
  l_module_name    CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPLOAD_FILE';

  BEGIN

    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    IF (g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load ID', p_LoadId);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'File Name', p_FileName);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Load type', p_LoadType);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Directory name', p_DirName);
    END IF;

    BEGIN
      p_DirName  := get_upload_dir;
      v_sql_stmt := 'CREATE OR REPLACE DIRECTORY UPLOAD_DIR AS ''' || p_DirName || '''';
      EXECUTE IMMEDIATE v_sql_stmt;

      SELECT file_name, load_type
        INTO p_FileName, p_LoadType
	FROM fte_bulkload_data
	WHERE load_id = p_LoadId;

      --For LTL pricelists, we don't upload the file into the database, but rather
      --we read the contents of the file directly using UTL_FILE.
      IF (p_loadType <> 'LTL_PRICELIST') THEN
        fnd_profile.get('FTE_BULKLOAD_SOURCE_TYPE',l_source_type);

        IF (upper(l_source_type) = 'SERVER') THEN
       	  -- initialize the BFILE locator for reading
      	  v_FileLocator := BFILENAME('UPLOAD_DIR', p_FileName);
      	  DBMS_LOB.FILEOPEN(v_FileLocator, DBMS_LOB.FILE_READONLY);
      	  v_FileSize := DBMS_LOB.GETLENGTH(v_FileLocator);

	  -- select the column into which we are going to load
	  -- the file. There should be only one column returned by this
	  -- query. The Load ID should be unique.
          SELECT content
	    INTO p_FileContents
	    FROM fte_bulkload_data
  	    WHERE load_id = p_LoadId
	    FOR UPDATE;

	  -- load the entire file into the charactor LOB.
	  DBMS_LOB.LOADFROMFILE(p_FileContents, v_FileLocator, v_FileSize);
	  DBMS_LOB.FILECLOSE(v_FileLocator);

          v_LastUpdateDate := sysdate;

	  UPDATE FTE_BULKLOAD_DATA
	    SET  last_update_date = v_LastUpdateDate,
	  	 file_size = v_FileSize,
  	         LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     	 LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
	    WHERE load_id = p_LoadId;
        ELSE
          SELECT content
	    INTO p_FileContents
	    FROM fte_bulkload_data
	    WHERE load_id = p_LoadId;
	END IF;
      END IF;
      p_ExitStatus := 0;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	p_ExitStatus := 1;
      WHEN OTHERS THEN
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
              			    p_msg   		=> sqlerrm,
             			    p_category    	=> 'O');
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
              			  p_msg   		=> sqlerrm,
             			  p_category    	=> 'O');
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END UPLOAD_FILE;

END FTE_BULKLOAD_PKG;

/

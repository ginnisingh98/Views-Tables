--------------------------------------------------------
--  DDL for Package Body CE_BANK_STMT_SQL_LDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_STMT_SQL_LDR" AS
/* $Header: cesqldrb.pls 120.7 2006/06/06 00:33:19 bhchung ship $	*/
  l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  --l_DEBUG varchar2(1) := 'Y';

/* 2421690
Start of Code Fix */

  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.7 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

/* End of Code Fix */

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Print_Report							|
|									|
|  DESCRIPTION								|
|	This procedure submits a concurrent request to print the	|
|	Cash SQLLDR Report to print out NOCOPY the errors.			|
|									|
|  CALLED BY								|
|									|
|  HISTORY								|
|	10-JUN-1999	Created		Byung-Hyun Chung		|
 --------------------------------------------------------------------- */

PROCEDURE Print_Report(X_MAP_ID		NUMBER,
		       X_DATA_FILE	VARCHAR2) IS
  req_id		NUMBER;
  request_id		NUMBER;
  reqid			VARCHAR2(30);
  number_of_copies	NUMBER;
  printer		VARCHAR2(30);
  print_style		VARCHAR2(30);
  save_output_flag	VARCHAR2(30);
  save_output_bool	BOOLEAN;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STMT_SQL_LDR.Print_Report');
  END IF;
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);
  --
  -- Get print options
  --
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('Print_Report: ' || 'Request Id is ' || request_id);
  END IF;
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Print_Report: ' || 'Message: get print options failed');
    END IF;
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
                                           'CEBSLERR',
                                           printer,
                                           print_style,
                                           save_output_flag)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('Print_Report: ' || 'Message: get print options failed');
      END IF;
    END IF;

    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                          print_style,
                                          number_of_copies,
                                          save_output_bool)) THEN
      IF l_DEBUG in ('Y', 'C') THEN
      	cep_standard.debug('Print_Report: ' || 'Set print options failed');
      END IF;
    END IF;
  END IF;

  req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			          'CEBSLERR',
				  NULL,
				  to_date(to_char(sysdate,'YYYY/MM/DD'),'YYYY/MM/DD'),
			          FALSE,
				  'P_MAP_ID=' || to_char(X_MAP_ID),
				  'P_FILE_NAME=' || X_DATA_FILE);

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STMT_SQL_LDR.Print_Report');
  END IF;
END Print_Report;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
| 	Define_Conc_Program						|
|									|
|  DESCRIPTION								|
|	Create executable and concurrent program definition when new 	|
|	format is loaded for the first time.  This is necessary		|
|	since executable and concurrent program has to be created per	|
|	control file.							|
|  CALLED BY								|
|									|
|  HISTORY								|
|	10-JUN-1999	Created		Byung-Hyun Chung		|
 --------------------------------------------------------------------- */
FUNCTION Define_Conc_Program(X_ctl_file	IN	VARCHAR2) RETURN NUMBER IS
  l_err		NUMBER;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_BANK_STMT_SQL_LDR.Define_Conc_Program');
  END IF;

  --
  -- Create Executable for the given control file.
  --
  FND_PROGRAM.executable('CESLREXC' || X_ctl_file,			-- executable
			   'CE',			-- application
			   'CESLREXC' || X_ctl_file,			-- short name
			   'Executable for SQL*Loader ' || X_ctl_file, 	-- description
			   'SQL*Loader',			   	-- execution method
			   X_ctl_file);					-- execution file name


  --
  -- Create Concurrent Program Definition for the given control file.
  --
  FND_PROGRAM.register('Run SQL*Loader- ' || X_ctl_file,	-- Program
			 'CE',		-- application
			 'Y',					-- enabled
			 'CESLRPRO'|| X_ctl_file,		-- short name
			 'Program Definition for SQL*Loader ' || X_ctl_file,	-- description
			 'CESLREXC' || X_ctl_file,		-- executable name
			 'CE',		-- executable application
			 NULL,					-- execution option
			 NULL, 					-- priority
			 'Y',					-- save output
			 'Y',					-- print
			 NULL,					-- cols
			 NULL,					-- rows
			 NULL,					-- style
			 'N',					-- style required
			 NULL,					-- printer
			 NULL,					-- request type
			 NULL,					-- request type application
			 'N',					-- use in SRS
			 'N',					-- allow diabled value
			 'N');					-- run alone

  --
  -- Create Concurrent Program Parameter Definition for the givel control file.
  --
  FND_PROGRAM.parameter('CESLRPRO'|| X_ctl_file,		-- program short name
			  'CE',		-- application
			  10,					-- sequence
			  'Data File Name',			-- parameter
			  'Data File Name',			-- description
			  'Y',					-- enabled
			  '50 chars',				-- value set
			  NULL,					-- default type
			  NULL,					-- default value
			  'Y',					-- required
			  'N',					-- enable security
			  NULL,					-- range
			  'Y',					-- display
			  50,					-- display size
			  50,					-- description size
			  25,					-- concatenated desc dize
			  'Data File Name',			-- prompt
			  NULL);				-- token

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STMT_SQL_LDR.Define_Conc_Program');
  END IF;
  RETURN 1;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_BANK_STMT_SQL_LDR.Define_Conc_Program - '||
 			fnd_program.message() );
    END IF;
    --
    -- Concurrent program definition already exist.
    -- Still ok to run the program.
    --
    RETURN 1;
END Define_Conc_Program;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Call_Sql_Loader							|
|									|
|  DESCRIPTION								|
|	This procedure spwans SQL*Loader program and main loading	|
|	program.							|
|									|
|  CALLED BY								|
|									|
|  HISTORY								|
|	10-JUN-1999	Created		Byung-Hyun Chung		|
 --------------------------------------------------------------------- */
PROCEDURE Call_Sql_Loader(errbuf		OUT NOCOPY	VARCHAR2,
			  retcode		OUT NOCOPY 	NUMBER,
                          X_process_option      IN	VARCHAR2,
			  X_loading_id		IN	NUMBER,
			  X_input_file		IN	VARCHAR2,
			  X_directory_path  	IN	VARCHAR2,
			  X_bank_branch_id	IN	VARCHAR2,
			  X_bank_account_id	IN	VARCHAR2,
  			  X_gl_date             IN      VARCHAR2,
  			  X_org_id              IN      VARCHAR2,
			  X_receivables_trx_id	IN     	NUMBER,
			  X_payment_method_id	IN     	NUMBER,
			  X_nsf_handling        IN     	VARCHAR2,
                          X_display_debug	IN	VARCHAR2,
			  X_debug_path		IN     	VARCHAR2,
			  X_debug_file		IN     	VARCHAR2,
			  X_gl_date_source      IN      VARCHAR2 DEFAULT NULL,
                          X_intra_day_flag      IN      VARCHAR2 DEFAULT 'N') IS

  l_cnt			NUMBER;
  l_data_file		VARCHAR2(80);
  l_ctl_file		VARCHAR2(30);
  l_request_id		NUMBER;
  l_req_data		VARCHAR(30);
  G_conc_req_id		NUMBER;

  ldr_exception		EXCEPTION;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.enable_debug(X_debug_path,
			      X_debug_file || '-CSL');
  	cep_standard.debug('>>CE_BANK_STMT_SQL_LDR.Call_Sql_Loader');
  END IF;

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

  --
  -- Reformat the input file name
  --
  IF (INSTR(X_directory_path, '\') <> 0 ) THEN
    l_data_file :=  nvl(X_directory_path, '$CE_TOP\\bin') || '\\' || X_input_file;
  ELSE
    l_data_file :=  nvl(X_directory_path, '$CE_TOP/bin') || '/' || X_input_file;
  END IF;

  l_req_data := fnd_conc_global.request_data;

  if(l_req_data IS NOT NULL)THEN
    G_conc_req_id := to_number(l_req_data);
  END IF;

  --
  -- Delete existing data in CE_SQLLDR_ERRORS table.
  --
  CE_SQLLDR_ERRORS_PKG.Delete_Row;

  SELECT control_file_name
  INTO   l_ctl_file
  FROM   ce_bank_stmt_int_map
  WHERE  map_id = X_loading_id;

  --
  -- Reformat the control file name
  --
  l_ctl_file := replace(l_ctl_file, '.ctl');

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('Call_Sql_Loader: ' || 'Control file name: '|| l_ctl_file);
  END IF;

  --
  -- If there is no concurrent program setup for the given control file then create one.
  --
  SELECT count(*)
  INTO   l_cnt
  FROM   fnd_concurrent_programs
  WHERE  application_id = 260
  AND    concurrent_program_name = 'CESLRPRO' || l_ctl_file;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('l_cnt = ' || l_cnt ||
			   ', l_data_file = ' ||l_data_file );
  END IF;

  IF (l_cnt = 0 ) THEN
    IF (Define_Conc_Program(l_ctl_file) <> 1) THEN
      RAISE ldr_exception;
    END IF;
  END IF;

  --
  -- Submit request to execute SQL*Loader.
  --
  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE','CESLRPRO'|| l_ctl_file,'','',NULL,
                l_data_file, fnd_global.local_chr(0),
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','');

  IF l_request_id = 0 THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Call_Sql_Loader: ' || 'EXCEPTION: Fail to submit cuncurrent request for SQL*Loader');
    END IF;
    RAISE ldr_exception;
  END IF;

  --
  -- Submit request to execute actual loading program.
  -- This concurrent program will transfer data from temporart table to interface tables.
  --
  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE','CEBSLDR','','',NULL,
		X_loading_id,
		l_request_id,
 		l_data_file,
  		NVL(X_process_option, 'LOAD'),
  		X_gl_date,
		X_org_id,
 		X_receivables_trx_id,
  		X_payment_method_id,
  		X_nsf_handling,
  		X_display_debug,
  		X_debug_path,
  		X_debug_file,
  		X_bank_branch_id,
  		X_bank_account_id,
		X_intra_day_flag,
                X_gl_date_source,
		fnd_global.local_chr(0),
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','');

  IF l_request_id = 0 THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('Call_Sql_Loader: ' || 'EXCEPTION: Fail to submit cuncurrent request for '|| 'CEBSLDR');
    END IF;
    RAISE ldr_exception;
  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_BANK_STMT_SQL_LDR.Call_Sql_Loader');
        cep_standard.disable_debug(X_display_debug);
  END IF;

EXCEPTION
  WHEN ldr_exception THEN
    RAISE;
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_BANK_STMT_SQL_LDR.Call_Sql_Loader');
    END IF;
    RAISE;
END Call_Sql_Loader;

END CE_BANK_STMT_SQL_LDR;

/

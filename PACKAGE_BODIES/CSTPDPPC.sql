--------------------------------------------------------
--  DDL for Package Body CSTPDPPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPDPPC" AS
/* $Header: CSTDPPCB.pls 115.10 2002/11/08 03:19:45 awwang ship $ */

/*============================================================================+
| This function of this procedure is to run the requested procedure using     |
| Dynamic SQL. The input parameter i_proc_name is the name of the procedure   |
| to be run dynamically. The input parameters to the procedure to be run are  |
| populated in the l_parameters dynamic PL/SQL table, and then the procedure  |
| run_dyn_proc is called to execute the procedure.                            |
|============================================================================*/

PROCEDURE set_phase_status (
	i_cost_group_id		IN		NUMBER,
	i_period_id		IN		NUMBER,
	i_status		IN		NUMBER,
        i_user_id               IN		NUMBER,
        i_login_id              IN		NUMBER,
        i_prog_appl_id          IN		NUMBER,
        i_prog_id               IN		NUMBER,
	i_request_id		IN		NUMBER
)
IS
BEGIN
	UPDATE
	cst_pac_process_phases
	SET
	process_status = i_status,
        process_date = SYSDATE,
        process_upto_date = (select decode(i_status,4,process_upto_date,NULL)
                           from cst_pac_process_phases
                           where process_phase = 5
                           and cost_group_id = i_cost_group_id
                           and pac_period_id = i_period_id),
        last_update_date = SYSDATE,
        last_updated_by = nvl(i_user_id,-1),
        request_id = i_request_id,
        program_application_id = i_prog_appl_id,
        program_id = i_prog_id,
        program_update_date = SYSDATE,
        last_update_login = i_login_id
        WHERE pac_period_id = i_period_id
        AND cost_group_id = i_cost_group_id
        AND process_phase = 6;

	COMMIT;
END set_phase_status;


PROCEDURE dyn_proc_call (
	i_proc_name		IN		VARCHAR2,
	i_acct_lib_id		IN		NUMBER,
	i_legal_entity		IN		NUMBER,
	i_cost_type		IN		NUMBER,
	i_cost_group		IN		NUMBER,
	i_period_id		IN		NUMBER,
	i_mode			IN		NUMBER,
	o_err_num		OUT NOCOPY		NUMBER,
	o_err_code		OUT NOCOPY		VARCHAR2,
	o_err_msg		OUT NOCOPY		VARCHAR2
)
IS
--  l_parameters    	cst_ae_lib_par_tbl_type := cst_ae_lib_par_tbl_type();
  l_sql_to_run  	VARCHAR2(500);
  --l_num_params		NUMBER;
  l_err			NUMBER;
  l_stmt_num		NUMBER;
  CST_PKG_FAIL		EXCEPTION;
  CST_PKG_FAIL2		EXCEPTION;
BEGIN
  ---------------------------------------------------------------------------
  -- First set the number of parameters. Then populate the l_parameters array
  -- with the input parameters
  -- datatype codes are as follows :
  -- 1 = varchar2
  -- 2 = number
  -- inout variable is set to 0 for in, 1 for in out, and 2 for out
  --------------------------------------------------------------------------
/*-------------------------------------------------------------------------
  l_num_params 				:= 8;
  l_parameters.extend(l_num_params);

  l_parameters(1).i_name 		:= 'I_ACCT_LIB_ID';
  l_parameters(1).i_num_value 		:= I_ACCT_LIB_ID;
  l_parameters(1).i_datatype 		:= 2;
  l_parameters(1).i_inout 		:= 0;

  l_parameters(2).i_name 		:= 'I_LEGAL_ENTITY';
  l_parameters(2).i_num_value 		:= I_LEGAL_ENTITY;
  l_parameters(2).i_datatype 		:= 2;
  l_parameters(2).i_inout 		:= 0;

  l_parameters(3).i_name 		:= 'I_COST_TYPE_ID';
  l_parameters(3).i_num_value 		:= I_COST_TYPE;
  l_parameters(3).i_datatype 		:= 2;
  l_parameters(3).i_inout 		:= 0;

  l_parameters(4).i_name 		:= 'I_COST_GROUP_ID';
  l_parameters(4).i_num_value 		:= I_COST_GROUP;
  l_parameters(4).i_datatype 		:= 2;
  l_parameters(4).i_inout 		:= 0;

  l_parameters(5).i_name 		:= 'I_PERIOD_ID';
  l_parameters(5).i_num_value 		:= I_PERIOD_ID;
  l_parameters(5).i_datatype 		:= 2;
  l_parameters(5).i_inout 		:= 0;

  l_parameters(6).i_name 		:= 'O_ERR_NUM';
  l_parameters(6).i_datatype 		:= 2;
  l_parameters(6).i_inout 		:= 2;

  l_parameters(7).i_name 		:= 'O_ERR_CODE';
  l_parameters(7).i_datatype 		:= 1;
  l_parameters(7).i_inout 		:= 2;

  l_parameters(8).i_name 		:= 'O_ERR_MSG';
  l_parameters(8).i_datatype 		:= 1;
  l_parameters(8).i_inout 		:= 2;

  --------------------------------------------------------------------------
  -- call run_dyn_proc with the inpute parameters populated in l_parameters
  --------------------------------------------------------------------------

  run_dyn_proc(
	l_num_params,
	i_proc_name,
	l_parameters,
	l_err);
---------------------------------------------------------------------------*/

  l_sql_to_run := 'BEGIN ' || i_proc_name || '(';
  l_sql_to_run := l_sql_to_run || ':I_ACCT_LIB_ID';
  l_sql_to_run := l_sql_to_run || ', :I_LEGAL_ENTITY';
  l_sql_to_run := l_sql_to_run || ', :I_COST_TYPE_ID';
  l_sql_to_run := l_sql_to_run || ', :I_COST_GROUP_ID';
  l_sql_to_run := l_sql_to_run || ', :I_PERIOD_ID';
  l_sql_to_run := l_sql_to_run || ', :I_MODE';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_NUM';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_CODE';
  l_sql_to_run := l_sql_to_run || ', :O_ERR_MSG';
  l_sql_to_run := l_sql_to_run || '); END;';

  l_stmt_num := 10;

  EXECUTE IMMEDIATE l_sql_to_run USING
			I_ACCT_LIB_ID,
			I_LEGAL_ENTITY,
			I_COST_TYPE,
			I_COST_GROUP,
			I_PERIOD_ID,
			I_MODE,
			OUT O_ERR_NUM,
			OUT O_ERR_CODE,
			OUT O_ERR_MSG;
  -------------------------------------------------------------------------
  -- l_parameters(6) is l_err_num
  -------------------------------------------------------------------------

  IF (o_err_num <> 0 and o_err_num is not null) THEN
    RAISE CST_PKG_FAIL;
  END IF;

  IF (l_err <> 0) THEN
    RAISE CST_PKG_FAIL2;
  END IF;

EXCEPTION
  WHEN CST_PKG_FAIL THEN
  fnd_file.put_line(fnd_file.log,'CSTPDPPC.dyn_proc_call : Error Calling Package');
  WHEN CST_PKG_FAIL2 THEN
        o_err_num := l_err;
        o_err_code := SQLCODE;
        o_err_msg :=  'CSTPDPPC.dyn_proc_call : Error Calling Package';
  WHEN OTHERS THEN
        o_err_num := 30000;
        o_err_code := SQLCODE;
  	o_err_msg := 'CSTPDPPC.dyn_proc_call : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
END dyn_proc_call;

/*============================================================================+
| This function of this procedure is to actually execute the requested        |
| procedureQL. The input parameter i_proc_name is the name of the procedure   |
| to be run dynamically. The input parameters to the procedure to be run are  |
| populated in the l_parameters dynamic PL/SQL table, and then the procedure  |
| run_dyn_proc is called to execute the procedure.                            |
|============================================================================*/
/*------------------------------------------------------
PROCEDURE run_dyn_proc ( (
	i_num_params    	IN      	NUMBER,
	i_proc_name     	IN      	VARCHAR2,
	io_parameters   	IN OUT  	CST_AE_LIB_PAR_TBL_TYPE,
	o_err			OUT		NUMBER
) IS
  l_cursor      	NUMBER;
  l_err         	NUMBER 		:= 0;
  l_sql_to_run  	VARCHAR2(500);
  l_stmt_num		NUMBER;
  cst_invalid_type_error EXCEPTION;
BEGIN
  l_sql_to_run := 'BEGIN ' || i_proc_name || '(';

  FOR i IN 1..i_num_params LOOP
    IF ( i = 1) THEN
      l_sql_to_run := l_sql_to_run || ':' || io_parameters(i).i_name;
    ELSE
      l_sql_to_run := l_sql_to_run || ', :' || io_parameters(i).i_name;
    END IF;
  END LOOP;

  l_sql_to_run := l_sql_to_run || '); END;';

  l_stmt_num := 10;

  EXECUTE IMMEDIATE l_sql_to_run USING
			io_parameters(1).i_num_value,
			io_parameters(2).i_num_value,
			io_parameters(3).i_num_value,
			io_parameters(4).i_num_value,
			io_parameters(5).i_num_value,
			OUT io_parameters(6).i_num_value,
			OUT io_parameters(7).i_vchar_value,
			OUT io_parameters(8).i_vchar_value;

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor,l_sql_to_run,DBMS_SQL.V7);

  FOR i IN 1..i_num_params LOOP
      IF (io_parameters(i).i_datatype = 2) THEN
        dbms_sql.bind_variable(l_cursor,io_parameters(i).i_name,io_parameters(i).i_num_value);
      ELSIF (io_parameters(i).i_datatype = 1) THEN
        dbms_sql.bind_variable(l_cursor,io_parameters(i).i_name,io_parameters(i).i_vchar_value ,500);
      ELSIF (io_parameters(i).i_datatype = 12) THEN
        dbms_sql.bind_variable(l_cursor,io_parameters(i).i_name,io_parameters(i).i_date_value) ;
      ELSIF (io_parameters(i).i_datatype = 96) THEN
        dbms_sql.bind_variable(l_cursor,io_parameters(i).i_name,io_parameters(i).i_char_value) ;
      ELSE
       RAISE cst_invalid_type_error;
      END IF;
  END LOOP;
  l_stmt_num := 20;
  l_err := DBMS_SQL.EXECUTE(l_cursor);

  FOR i IN 1..i_num_params LOOP
    IF (io_parameters(i).i_inout in (1,2)) THEN
        IF (io_parameters(i).i_datatype = 2) THEN
          DBMS_SQL.VARIABLE_VALUE(l_cursor,':' || io_parameters(i).i_name,io_parameters(i).i_num_value);
        ELSIF (io_parameters(i).i_datatype = 1) THEN
          DBMS_SQL.VARIABLE_VALUE(l_cursor,':' || io_parameters(i).i_name,io_parameters(i).i_vchar_value);
        ELSIF (io_parameters(i).i_datatype = 12) THEN
          DBMS_SQL.VARIABLE_VALUE(l_cursor,':' || io_parameters(i).i_name,io_parameters(i).i_date_value);
        ELSIF (io_parameters(i).i_datatype = 96) THEN
          DBMS_SQL.VARIABLE_VALUE(l_cursor,':' || io_parameters(i).i_name,io_parameters(i).i_char_value);
        ELSE
          RAISE cst_invalid_type_error;
        END IF;
    END IF;
  END LOOP;

EXCEPTION
WHEN CST_INVALID_TYPE_ERROR THEN
	o_err := -1;
WHEN OTHERS THEN
	o_err := -2;

END run_dyn_proc;
-----------------------------------------------------*/

PROCEDURE dist_processor_main (
	errbuf     		OUT NOCOPY	VARCHAR2,
	retcode    		OUT NOCOPY	NUMBER,
	i_legal_entity		IN	NUMBER ,
	i_cost_type_id		IN	NUMBER ,
	i_cost_group_id		IN	NUMBER ,
	i_period_id		IN	NUMBER ,
	i_mode			IN	NUMBER DEFAULT 0
) IS
	l_le_exists     	NUMBER;
	l_ct_exists     	NUMBER;
	l_cg_exists     	NUMBER;
	l_per_exists    	NUMBER;
	l_acct_lib_exists    	NUMBER;
	l_acct_lib_id		NUMBER;
	l_lib_name		VARCHAR2(100);
	l_stmt_num		NUMBER;
	l_running_period	NUMBER;
	cst_no_acct_lib_error 	EXCEPTION;
	l_request_id		NUMBER;
	l_user_id		NUMBER;
	l_login_id		NUMBER;
	l_prog_appl_id		NUMBER;
	l_prog_id		NUMBER;
	l_err_num		NUMBER;
	l_err_code		VARCHAR2(240);
	l_err_msg		VARCHAR2(240);
	CONC_STATUS		BOOLEAN;
	CST_NO_LE      		EXCEPTION;
	CST_NO_CT      		EXCEPTION;
	CST_NO_CG      		EXCEPTION;
	CST_NO_PER     		EXCEPTION;
	CST_LIB_CALL_FAIL	EXCEPTION;
	CST_PURGE_FAIL     	EXCEPTION;
	CST_NO_DIST_PER		EXCEPTION;
	CST_ALREADY_RUNNING	EXCEPTION;
BEGIN

  l_request_id          := FND_GLOBAL.conc_request_id;
  l_user_id             := FND_GLOBAL.user_id;
  l_login_id            := FND_GLOBAL.login_id;
  l_prog_appl_id        := FND_GLOBAL.prog_appl_id;
  l_prog_id             := FND_GLOBAL.conc_program_id;

  fnd_file.put_line(fnd_file.log,'Legal Entity : '||to_char(i_legal_entity));
  fnd_file.put_line(fnd_file.log,'Cost Type : '||to_char(i_cost_type_id));
  fnd_file.put_line(fnd_file.log,'Cost Group : '||to_char(i_cost_group_id));
  fnd_file.put_line(fnd_file.log,'Period : '||to_char(i_period_id));

  SELECT
  count(*)
  INTO
  l_le_exists
  FROM
  cst_le_cost_types
  WHERE
  legal_entity = i_legal_entity AND
  create_acct_entries ='Y';

  IF (l_le_exists = 0) THEN
    RAISE CST_NO_LE;
  END IF;

  l_stmt_num := 20;

  SELECT
  count(*)
  INTO
  l_ct_exists
  FROM
  cst_le_cost_types clct, cst_cost_types cct
  WHERE
  clct.legal_entity = i_legal_entity AND
  clct.cost_type_id = i_cost_type_id AND
  clct.create_acct_entries = 'Y' AND
  clct.cost_type_id = cct.cost_type_id AND
  nvl(cct.disable_date, sysdate +1) > sysdate;

  IF (l_ct_exists = 0) THEN
    RAISE CST_NO_CT;
  END IF;

  l_stmt_num := 30;

  SELECT
  count(*)
  INTO
  l_cg_exists
  FROM
  cst_cost_groups ccg
  WHERE
  legal_entity = i_legal_entity AND
  cost_group_id = i_cost_group_id;

  IF (l_cg_exists = 0) THEN
    RAISE CST_NO_CG;
  END IF;

  l_stmt_num := 40;

  IF (i_mode = 0) THEN
    SELECT
    count(*)
    INTO
    l_per_exists
    FROM
    cst_pac_periods
    WHERE
    legal_entity = i_legal_entity AND
    cost_type_id = i_cost_type_id AND
    pac_period_id = i_period_id AND
    open_flag = 'Y' AND
    pac_period_id IN
        (SELECT
         DISTINCT pac_period_id
         FROM
         cst_pac_process_phases
         WHERE
         cost_group_id = i_cost_group_id AND
         process_phase = 5 AND
         process_status = 4);

    IF (l_per_exists = 0) THEN
      RAISE CST_NO_PER;
    END IF;

    SELECT
    count(*)
    INTO
    l_running_period
    FROM
    cst_pac_process_phases
    WHERE
    pac_period_id = i_period_id AND
    cost_group_id = i_cost_group_id AND
    process_phase = 6 AND
    process_status = 2;

    IF (l_running_period > 0) THEN
      RAISE CST_ALREADY_RUNNING;
    END IF;

    set_phase_status (
  	  i_cost_group_id,
          i_period_id,
          2,
          l_user_id,
          l_login_id,
          l_prog_appl_id,
          l_prog_id,
	  l_request_id);
  ELSE
    SELECT
    count(*)
    INTO
    l_per_exists
    FROM
    cst_pac_periods
    WHERE
    legal_entity = i_legal_entity AND
    cost_type_id = i_cost_type_id AND
    pac_period_id = i_period_id AND
    open_flag IN ('Y','P') AND
    pac_period_id IN
        (SELECT
         DISTINCT pac_period_id
         FROM
         cst_pac_process_phases
         WHERE
         cost_group_id = i_cost_group_id AND
         process_phase = 6 AND
         process_status = 4);

    IF (l_per_exists = 0) THEN
      RAISE CST_NO_DIST_PER;
    END IF;
  END IF;

  SELECT
  count(*)
  INTO
  l_acct_lib_exists
  FROM
  cst_le_cost_types clct1,
  cst_accounting_libraries cal
  WHERE
  clct1.legal_entity = i_legal_entity AND
  clct1.cost_type_id = i_cost_type_id AND
  clct1.accounting_library_id = cal.accounting_lib_id;

  IF (l_acct_lib_exists = 0) THEN
    RAISE CST_NO_ACCT_LIB_ERROR;
  END IF;



  IF (i_mode = 0) THEN
  fnd_file.put_line(fnd_file.log,'Purging Data  ...');
  CSTPPPUR.purge_distribution_data(
			i_period_id,
			i_legal_entity,
			i_cost_group_id,
			l_user_id,
			l_login_id,
			l_request_id,
                        l_prog_id,
                        l_prog_appl_id,
                        l_err_num,
                        l_err_code,
                        l_err_msg );

  IF (l_err_num <> 0 and l_err_num is not null) THEN
    RAISE CST_PURGE_FAIL;
  END IF;
  END IF;

  SELECT
  accounting_library_id,
  lib_pkg_name
  INTO
  l_acct_lib_id,
  l_lib_name
  FROM
  cst_le_cost_types clct,
  cst_accounting_libraries cal
  WHERE clct.accounting_library_id = cal.ACCOUNTING_LIB_ID AND
  clct.legal_entity = i_legal_entity AND
  clct.cost_type_id = i_cost_type_id;

  fnd_file.put_line(fnd_file.log,'Calling Accounting Library ...');

  dyn_proc_call(
	l_lib_name,
	l_acct_lib_id,
	i_legal_entity,
	i_cost_type_id   ,
	i_cost_group_id  ,
	i_period_id   ,
	i_mode,
	l_err_num     ,
	l_err_code    ,
	l_err_msg
);


  IF (l_err_num <> 0 and l_err_num is not null) THEN
    RAISE CST_LIB_CALL_FAIL;
  END IF;

  IF (i_mode = 0) THEN
  set_phase_status (
                i_cost_group_id,
                i_period_id,
                4,
                l_user_id,
                l_login_id,
                l_prog_appl_id,
                l_prog_id,
                l_request_id);
  else
    retcode := 0;
  END IF;



EXCEPTION
  WHEN CST_NO_ACCT_LIB_ERROR THEN
  	l_err_num := 30000;
  	l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_ACCT_LIB');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
        IF (i_mode = 0) THEN
	set_phase_status (
        	i_cost_group_id,
        	i_period_id,
        	3,
        	l_user_id,
        	l_login_id,
        	l_prog_appl_id,
        	l_prog_id,
		l_request_id);
        ELSE
          retcode := l_err_num;
        END IF;

  WHEN CST_NO_LE THEN
        l_err_num := 30001;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_LE');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
	if (i_mode <> 0) THEN
	  retcode := l_err_num;
    	end if;
  WHEN CST_ALREADY_RUNNING THEN
        l_err_num := 30007;
        l_err_code := SQLCODE;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):Processor already running for the Legal Entity, Cost Group, Cost Type and Period';
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
	if (i_mode <> 0) THEN
	  retcode := l_err_num;
    	end if;
  WHEN CST_NO_CT THEN
        l_err_num := 30002;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_CT');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
        if (i_mode <> 0) THEN
          retcode := l_err_num;
        end if;
  WHEN CST_NO_CG THEN
        l_err_num := 30003;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_CG_INVALID');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
	if (i_mode <> 0) THEN
	  retcode := l_err_num;
    	end if;
  WHEN CST_NO_PER THEN
        l_err_num := 30004;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_PER');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
	if (i_mode <> 0) THEN
	  retcode := l_err_num;
    	end if;
  WHEN CST_NO_DIST_PER THEN
        l_err_num := 30005;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_DIST_PER');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
	if (i_mode <> 0) THEN
	  retcode := l_err_num;
    	end if;
  WHEN CST_LIB_CALL_FAIL THEN
        l_err_num := l_err_num;
        l_err_code := l_err_code;
        l_err_msg :=  l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
        IF (i_mode = 0) THEN
	set_phase_status (
        	i_cost_group_id,
        	i_period_id,
        	3,
        	l_user_id,
        	l_login_id,
        	l_prog_appl_id,
        	l_prog_id,
		l_request_id);
	else
	  retcode := l_err_num;
        END IF;

  WHEN CST_PURGE_FAIL THEN
        l_err_num := l_err_num;
        l_err_code := l_err_code;
        l_err_msg :=  l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
        IF (i_mode = 0) THEN
	set_phase_status (
        	i_cost_group_id,
        	i_period_id,
        	3,
        	l_user_id,
        	l_login_id,
        	l_prog_appl_id,
        	l_prog_id,
		l_request_id);
	else
	  retcode := l_err_num;
        END IF;

  WHEN OTHERS THEN
        l_err_num := 30006;
        l_err_code := SQLCODE;
  	l_err_msg := 'CSTPDPPC.dist_processor_main : ' || to_char(l_stmt_num) || ':'|| substr(SQLERRM,1,180);
        IF (i_mode = 0) THEN
	set_phase_status (
        	i_cost_group_id,
        	i_period_id,
        	3,
        	l_user_id,
        	l_login_id,
        	l_prog_appl_id,
        	l_prog_id,
		l_request_id);
	else
	  retcode := l_err_num;
        END IF;


END dist_processor_main;



END CSTPDPPC;


/

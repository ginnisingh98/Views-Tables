--------------------------------------------------------
--  DDL for Package Body XTR_CASH_FCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CASH_FCST" AS
/* $Header: xtrcshfb.pls 120.4 2005/10/05 20:19:09 eaggarwa ship $	*/

  --
  -- Get Header Information
  --
  CURSOR f_header_cursor (p_forecast_header_id NUMBER) IS
	SELECT 	cfh.name, cfh.aging_type,
		cfh.overdue_transactions, cfh.transaction_calendar_id,
		cfh.start_project_id, cfh.end_project_id, cfh.treasury_template
	FROM 	CE_FORECAST_HEADERS cfh
	WHERE 	cfh.forecast_header_id = p_forecast_header_id;

  --
  -- Get row information
  --
  CURSOR f_row_cursor (p_forecast_header_id NUMBER, p_rownum_from NUMBER, p_rownum_to NUMBER) IS
	SELECT	rowid, forecast_row_id, row_number, trx_type, nvl(lead_time,0),
		NVL(forecast_method,'F'), discount_option, DECODE(trx_type, 'PAY', 'PAY', SUBSTR(trx_type, 1,2)),
		include_float_flag, NVL(order_status,'A'),
		order_date_type, code_combination_id, budget_name,
		encumbrance_type_id, chart_of_accounts_id,
		set_of_books_id, NVL(org_id,-99),
		roll_forward_type, roll_forward_period,
		NVL(include_dispute_flag,'N'), sales_stage_id,
		channel_code, NVL(win_probability,0), sales_forecast_status,
		customer_profile_class_id, bank_account_id,
		receipt_method_id, vendor_type, payment_method, pay_group,
		payment_priority, authorization_status, type, budget_type,
		budget_version, include_hold_flag, include_net_cash_flag, budget_version_id,
		payroll_id, org_payment_method_id,
		external_source_type, criteria_category,
		criteria1, criteria2, criteria3, criteria4, criteria5,
		criteria6, criteria7, criteria8, criteria9, criteria10,
		criteria11, criteria12, criteria13, criteria14, criteria15
	FROM 	ce_forecast_rows
	WHERE 	row_number BETWEEN NVL(p_rownum_from, row_number) AND
				   NVL(p_rownum_to, row_number)
	AND 	forecast_header_id = p_forecast_header_id
        AND     trx_type 	   <> 'GLC';

  CURSOR f_glc_cursor (p_forecast_header_id NUMBER, p_rownum_from NUMBER, p_rownum_to NUMBER) IS
        SELECT  rowid, forecast_row_id, row_number,
		set_of_books_id, code_combination_id, chart_of_accounts_id
	FROM    ce_forecast_rows
        WHERE   row_number BETWEEN NVL(p_rownum_from, row_number) AND
                                   NVL(p_rownum_to, row_number)
        AND 	forecast_header_id = p_forecast_header_id
	AND	trx_type 	   = 'GLC';

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	set_parameters							|
|									|
|  DESCRIPTION								|
|	This procedure sets the global parameters			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|	all runtime parameters						|
|  HISTORY								|
|	04-OCT-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION set_parameters (p_forecast_header_id		IN NUMBER,
			  p_forecast_runname		IN VARCHAR2,
			  p_forecast_start_date		IN VARCHAR2,
			  p_forecast_currency		IN VARCHAR2,
			  p_src_curr_type		IN VARCHAR2,
			  p_company_code		IN VARCHAR2,
			  p_rownum_from			IN NUMBER,
			  p_rownum_to			IN NUMBER,
			  p_sub_request			IN VARCHAR2) RETURN NUMBER IS

  l_is_fixed_rate	BOOLEAN;
  l_relationship 	VARCHAR2(30);
  error_msg		VARCHAR2(2000);
  CURSOR C IS SELECT CE_FORECASTS_S.nextval FROM sys.dual;
  CURSOR H IS SELECT CE_FORECAST_HEADERS_S.nextval FROM sys.dual;
BEGIN

  /* In the case where p_src_curr_type = 'Entered', ensure that there is no
     fixed rate between the forecast and source currencies (both EMU currencies.


     If so, then override the p_exchange_type to 'EMU FIXED'.  This is to
     handle the case where the user enters an exchange type of 'User' from
     the SRS (concurrent submission form) when there is a fixed rate.  This
     scenario can occur due to the inability of flex fields to handle
     conditional value sets the way CE needs it and will result in erroneous
     forecast amounts. */

  IF p_forecast_header_id IS NULL THEN
    BEGIN
      select forecast_header_id
      into   G_rp_forecast_header_id
      from   ce_forecast_headers
      where  treasury_template = 'Y';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OPEN C;
      FETCH C INTO G_forecast_id;
      CLOSE C;

      print_report;
      return (1);
    END;
  ELSE
    G_rp_forecast_header_id :=  p_forecast_header_id;
  END IF;

  SELECT legal_entity_id
  INTO   G_rp_legal_entity_id
  FROM   xtr_party_info
  WHERE  party_code = p_company_code
  AND    party_type = 'C';

  /* RV BUG # 1548223 */

DECLARE
	l_orgs varchar2(500);
	CURSOR C_ORG is
	SELECT DISTINCT(organization_id) organization_id
	FROM HR_OPERATING_UNITS hou
	WHERE hou.set_of_books_id = (SELECT glle.ledger_id FROM gl_ledger_le_v glle
          WHERE  glle.legal_entity_id = G_rp_legal_entity_id
          AND glle.ledger_category_code = 'PRIMARY');   -- bug 4654775


BEGIN
    FOR r in C_ORG LOOP
    	l_orgs := l_orgs||','||r.organization_id ;
    END LOOP;
    l_orgs := '('||nvl(substr(l_orgs,2),NULL)||')';
    G_rp_org_ids := l_orgs;
EXCEPTION
    WHEN OTHERS THEN
    -- G_rp_org_ids := NULL;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('XTR_CASH_FCST.set_parameters-->NO_ORGS');
    END IF;
    Raise;
END;

 /* RV END */


  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>CE_CASH_FCST.set_parameters');
  END IF;
  G_rp_forecast_runname 	:=	p_forecast_runname;
  G_rp_forecast_start_date	:=	to_date(p_forecast_start_date,'YYYY/MM/DD HH24:MI:SS');
  G_rp_forecast_currency 	:=	p_forecast_currency;
  G_rp_src_curr_type  		:=	p_src_curr_type;
  G_rp_rownum_from		:=	p_rownum_from;
  G_rp_rownum_to		:=	p_rownum_to;
  G_rp_sub_request		:=	p_sub_request;
  G_forecast_id			:=	NULL;
  G_party_code			:=      p_company_code;
  IF(p_sub_request = 'Y')THEN
    G_parent_process := TRUE;
  ELSE
    G_parent_process := FALSE;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_forecast_header_id	: '||G_rp_forecast_header_id);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_forecast_runname	: '||G_rp_forecast_runname);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_forecast_start_date	: '||G_rp_forecast_start_date);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_forecast_start_period	: '||G_rp_forecast_start_period);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_forecast_currency	: '||G_rp_forecast_currency);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_exchange_type 		: '||G_rp_exchange_type);
 --  xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_exchange_date 		: '||G_rp_exchange_date);
 --  xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_exchange_rate 		: '||G_rp_exchange_rate);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_src_curr_type		: '||G_rp_src_curr_type);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_src_currency		: '||G_rp_src_currency);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_rownum_from		: '||G_rp_rownum_from);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_rownum_to		: '||G_rp_rownum_to);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_rp_sub_request		: '||G_rp_sub_request);
     xtr_debug_pkg.debug('XTR_CASH_FCST.G_forecast_id		: '||G_forecast_id);
  END IF;
  --
  -- Set View constants
  --
  CEFC_VIEW_CONST.set_constants(G_rp_forecast_header_id,
  				G_rp_calendar_name,
  				G_rp_forecast_start_period,
  				G_rp_forecast_start_date);

  return (0);
END;



/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Print_Report							|
|									|
|  DESCRIPTION								|
|	This procedure submits a concurrent request to print the	|
|	Cash Forecast Report after a succesful run.			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|	p_forecast_header_id	forecast header id			|
|	p_forecast_start_date	forecast date				|
|  HISTORY								|
|	04-OCT-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Print_Report IS
  req_id		NUMBER;
  request_id		NUMBER;
  reqid			VARCHAR2(30);
  number_of_copies	NUMBER;
  printer		VARCHAR2(30);
  print_style		VARCHAR2(30);
  save_output_flag	VARCHAR2(30);
  save_output_bool	BOOLEAN;
BEGIN
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);
  --
  -- Get print options
  --
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Request Id is ' || request_id);
  END IF;
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Message: get print options failed');
    END IF;
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;
    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                          print_style,
                                          number_of_copies,
                                          save_output_bool)) THEN
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('Set print options failed');
      END IF;
    END IF;
  END IF;
  req_id := FND_REQUEST.SUBMIT_REQUEST('XTR',
			          'XTRFCERR',
				  NULL,
				  trunc(sysdate),
			          FALSE,
				  G_forecast_id);

END Print_Report;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	validate_transaction_calendar					|
|									|
|  DESCRIPTION								|
|	checks to make sure that the period set name for all set of	|
|	books are the same						|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	05-AUG-1997	Created		Wynne Chan			|
 ---------------------------------------------------------------------*/
PROCEDURE validate_transaction_calendar IS
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>validate_transaction_calendar');
  END IF;

  SELECT min(transaction_date), max(transaction_date)
  INTO	 XTR_CSH_FCST_POP.G_calendar_start, XTR_CSH_FCST_POP.G_calendar_end
  FROM	 gl_transaction_dates
  WHERE	 transaction_calendar_id = G_transaction_calendar_id;

  IF(XTR_CSH_FCST_POP.G_calendar_start IS NULL OR
     XTR_CSH_FCST_POP.G_calendar_end IS NULL)THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Cannot find transaction calendar');
    END IF;
    G_transaction_calendar_id := NULL;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<validate_transaction_calendar');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
        xtr_debug_pkg.debug('EXCEPTION - OTHERS: validate_transaction_calendar');
     END IF;

        RAISE;
END validate_transaction_calendar;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	valid_calendar_name						|
|									|
|  DESCRIPTION								|
|	checks to make sure that the period set name for all set of	|
|	books are the same						|
|  CALLED BY								|
|	valid_row_info							|
|  HISTORY								|
|	04-OCT-1996	Created		Bidemi Carrol			|
 ---------------------------------------------------------------------*/
FUNCTION valid_calendar_name RETURN BOOLEAN IS
  valid_period	BOOLEAN := TRUE;
  sob_id	GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  calendar	GL_PERIODS.period_set_name%TYPE;
  error_msg	fnd_new_messages.message_text%TYPE;
  sob_name	GL_SETS_OF_BOOKS.name%TYPE;

  CURSOR sob_c IS
	SELECT 	gsb.period_set_name, org.set_of_books_id, org.set_of_books_name
  	FROM   	ce_forecast_orgs_v org,
		gl_sets_of_books gsb
  	WHERE  	gsb.set_of_books_id 	= org.set_of_books_id
  	  AND	org.app_short_name 	= G_app_short_name
  	  AND  	org.set_of_books_id 	= NVL(G_set_of_books_id,org.set_of_books_id)
  	  AND 	(org.org_id 		= DECODE(G_org_id, -1, org.org_id,-99, org.org_id, G_org_id)
			 or org.org_id IS NULL);

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CASH_FCST.valid_calendar_name');
  END IF;

  IF(G_app_short_name = 'GL')THEN
    SELECT	period_set_name, set_of_books_id, name, currency_code
    INTO	calendar, sob_id, sob_name, G_sob_currency_code
    FROM	gl_sets_of_books	gsb
    WHERE	gsb.set_of_books_id 	= G_set_of_books_id;

    IF (calendar <> G_rp_calendar_name) THEN
      valid_period := FALSE;
      FND_MESSAGE.set_name('CE', 'CE_FC_INVALID_PERIOD_SET_NAME');
      FND_MESSAGE.set_token('SOB_NAME', sob_name);
      error_msg := fnd_message.get;
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug(error_msg);
      END IF;
      CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, G_forecast_row_id,
					'CE_FC_INVALID_PERIOD', error_msg);
    END IF;
  ELSE
    open sob_c;
    LOOP
      FETCH sob_c INTO calendar, sob_id, sob_name;
      EXIT WHEN sob_c%NOTFOUND or sob_c%NOTFOUND IS NULL;

      IF (calendar <> G_rp_calendar_name) THEN
        valid_period := FALSE;
        FND_MESSAGE.set_name('CE', 'CE_FC_INVALID_PERIOD_SET_NAME');
        FND_MESSAGE.set_token('SOB_NAME', sob_name);
        error_msg := fnd_message.get;
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
           xtr_debug_pkg.debug(error_msg);
        END IF;
        CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, G_forecast_row_id,
					'CE_FC_INVALID_PERIOD', error_msg);
      END IF;
    END LOOP;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CASH_FCST.valid_calendar_name');
  END IF;
  return (valid_period);
EXCEPTION
   WHEN OTHERS THEN
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION -OTHERS:valid_calendar_name');
	END IF;
	IF sob_c%ISOPEN THEN CLOSE sob_c; END IF;
	RAISE;
END valid_calendar_name;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                 	|
|       standalone_process                                              |
|	parent_process							|
|	child_process							|
|	wrap_up_process							|
|  DESCRIPTION                                                          |
|       Determine if the current process is a standalone process, 	|
|	parent process, child process, or wrap-up process (the 		|
|	finishing part to be called by parent process)			|
|  CALLED BY								|
|	create_forecast							|
|  HISTORY								|
|	21-AUG-1997	Created		Wynne Chan			|
 --------------------------------------------------------------------- */
FUNCTION standalone_process RETURN BOOLEAN IS
BEGIN
  return (G_rp_sub_request = 'N');
END;

FUNCTION parent_process(req_data VARCHAR2) RETURN BOOLEAN IS
BEGIN
  return (G_parent_process and req_data IS NULL);
END;

FUNCTION child_process RETURN BOOLEAN IS
BEGIN
  return (G_rp_sub_request = 'Y' AND NOT G_parent_process);
END;

FUNCTION wrap_up_process(req_data VARCHAR2) RETURN BOOLEAN IS
BEGIN
  return( req_data IS NOT NULL);
END;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       submit_child_requests						|
|  DESCRIPTION								|
|	Called by the parent process to submit forecast request for	|
|	each row requested by the user					|
|  CALLED BY								|
|	create_forecast							|
|  HISTORY                                                              |
|       21-AUG-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
PROCEDURE submit_child_requests IS
  request_id	NUMBER;
  CURSOR CRowNumber(p_forecast_header_id NUMBER, p_rownum_from NUMBER, p_rownum_to NUMBER) IS
        SELECT	row_number
	FROM    ce_forecast_rows
        WHERE   row_number BETWEEN NVL(p_rownum_from, row_number) AND
                                   NVL(p_rownum_to, row_number)
        AND     forecast_header_id = p_forecast_header_id
        AND     trx_type 	   <> 'GLC';

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>> XTR_CASH_FCST.submit_child_requests ');
  END IF;
  open CRowNumber(G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);
  LOOP
    FETCH CRowNumber INTO G_row_number;
    EXIT WHEN CRowNumber%NOTFOUND OR CRowNumber%NOTFOUND IS NULL;

    request_id := FND_REQUEST.SUBMIT_REQUEST(
                'XTR', 'XTRFCAST',to_char(G_row_number),'',TRUE,
                G_rp_forecast_header_id,
                G_rp_forecast_runname,
		G_party_code,
                to_char(G_rp_forecast_start_date,'YYYY/MM/DD HH24:MI:SS'),
                to_char(G_row_number),
                to_char(G_row_number),
		'Y',
                chr(0),'','','','','','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','');

  END LOOP;
  CLOSE CRowNumber;
EXCEPTION
  WHEN OTHERS THEN
    IF CRowNumber%ISOPEN THEN CLOSE CRowNumber; END IF;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION: XTR_CASH_FCST.submit_child_requests');
    END IF;
    RAISE;
END submit_child_requests;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       create_forecast_header						|
|  DESCRIPTION								|
|	Create forecast header for new forecast in ce_forecasts table	|
|  CALLED BY								|
|	create_forecast							|
|  HISTORY                                                              |
|       12-JAN-1999     Created         BHCHUNG                         |
 --------------------------------------------------------------------- */
PROCEDURE create_forecast_header IS
  l_forecast_rowid	VARCHAR2(30);
  fid			NUMBER;
  error_msg     	FND_NEW_MESSAGES.message_text%TYPE;
  duplicate_name	BOOLEAN DEFAULT FALSE;

  CURSOR C IS SELECT CE_FORECASTS_S.nextval FROM sys.dual;
BEGIN
  OPEN C;
  FETCH C INTO G_forecast_id;
  CLOSE C;

  IF (G_rp_forecast_runname IS NULL) THEN
    G_rp_forecast_runname:= G_forecast_name||'/'||to_char(sysdate,'DD-MON-RRRR HH:MI:SS');
  ELSE
    BEGIN
      SELECT 	forecast_id
      INTO	fid
      FROM	ce_forecasts
      WHERE	name = G_rp_forecast_runname;

      duplicate_name := TRUE;
      G_rp_forecast_runname := G_rp_forecast_runname||'/'||to_char(sysdate,'DD-MON-RRRR HH:MI:SS');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	null;
    END;
  END IF;

  /* AW 1378198
  DELETE FROM ce_forecasts
  WHERE  forecast_header_id = G_rp_forecast_header_id;

  DELETE FROM ce_forecast_errors
  WHERE  forecast_header_id = G_rp_forecast_header_id;
  */

  INSERT INTO ce_forecasts(
	FORECAST_ID,
        FORECAST_HEADER_ID,
	NAME,
	START_DATE,
	FORECAST_CURRENCY,
	CURRENCY_TYPE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	ERROR_STATUS)
  VALUES(G_forecast_id,
         G_rp_forecast_header_id,
	 G_rp_forecast_runname,
 	 G_rp_forecast_start_date,
 	 G_party_code,
	 'A',
	 nvl(fnd_global.user_id, -1),
	 sysdate,
	 nvl(fnd_global.user_id, -1),
	 sysdate,
	 'S');

	commit;
EXCEPTION
  WHEN OTHERS THEN
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION: XTR_CASH_FCST.create_forecast_header ');
	END IF;
	RAISE;
END create_forecast_header;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	create_forecast							|
|									|
|  DESCRIPTION								|
|	This is the main cash forecast procedure			|
|	Depending if the current run is a parent process, child process	|
|	standalone process, or the wrap-up process from parent, 	|
|	create_forecast performs perform different task			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|	p_forecast_header_id	forecast header id			|
|	p_forecast_start_date	forecast date				|
|  HISTORY								|
|	28-DEC-1998	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE create_forecast IS
  counter	NUMBER;
  req_data	VARCHAR2(30);
  l_status	VARCHAR2(1);
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CASH_FCST.create_xtr_forecast');
  END IF;
  counter := 0;
  --
  -- Get forecast header info
  --
  OPEN f_header_cursor(G_rp_forecast_header_id);
  FETCH f_header_cursor INTO G_forecast_name, G_aging_type,
    			     G_overdue_transactions, G_transaction_calendar_id,
			     G_start_project_id, G_end_project_id, G_treasury_template;
  CLOSE f_header_cursor;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Aging type: ' || G_aging_type);
     xtr_debug_pkg.debug('Name: '|| G_forecast_name);
  END IF;

  FND_CURRENCY.get_info(G_rp_forecast_currency, G_precision, G_ext_precision, G_min_acct_unit);

  IF(G_overdue_transactions = 'INCLUDE')THEN
    BEGIN
      SELECT 	forecast_period_id
      INTO	G_overdue_period_id
      FROM	xtr_forecast_periods
      WHERE	forecast_header_id = G_rp_forecast_header_id	AND
		level_of_summary = 'O';
    EXCEPTION
      WHEN OTHERS THEN
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('ERROR: cannot get overdue period id');
        END IF;
        RAISE;
    END;
  END IF;

  req_data := fnd_conc_global.request_data;
  if(req_data IS NOT NULL)THEN
    G_forecast_id := to_number(req_data);
  END IF;

  if( parent_process(req_data) OR standalone_process)THEN

    IF(G_transaction_calendar_id IS NOT NULL)THEN
      validate_transaction_calendar;
    END IF;
    create_forecast_header;
  end if;

  IF(parent_process(req_data))THEN
	submit_child_requests;
	fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
				    request_data => to_char(G_forecast_id));
  END IF;

  IF (standalone_process OR child_process) THEN
    OPEN f_row_cursor(G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);

    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Forecast defn valid');
    END IF;

-- RV
    BEGIN

    DELETE FROM  xtr_external_cashflows
           WHERE company_code = G_party_code;  -- AW Bug 1378198
    IF SQL%FOUND THEN
	COMMIT;
    END IF;
    EXCEPTION
	WHEN OTHERS THEN
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION: XTR_CASH_FCST.create_forecast-->delete');
    	END IF;
    	RAISE;
    END;

    XTR_CSH_FCST_POP.populate_aging_buckets;

    LOOP
      FETCH f_row_cursor INTO G_rowid, G_forecast_row_id,
			G_row_number, G_trx_type,
			G_lead_time, G_forecast_method,
			G_discount_option, G_app_short_name,G_include_float_flag,
			G_order_status, G_order_date_type,
			G_code_combination_id, G_budget_name,
			G_encumbrance_type_id, G_chart_of_accounts_id ,
			G_set_of_books_id, G_org_id,
			G_roll_forward_type, G_roll_forward_period,
			G_include_dispute_flag, G_sales_stage_id,G_channel_code,
			G_win_probability, G_sales_forecast_status, G_customer_profile_class_id,
			G_bank_account_id, G_receipt_method_id, G_vendor_type,
			G_payment_method,  G_pay_group,G_payment_priority,
			G_authorization_status, G_type, G_budget_type, G_budget_version,
			G_include_hold_flag, G_include_net_cash_flag, G_budget_version_id,
			G_payroll_id, G_org_payment_method_id,
			G_external_source_type, G_criteria_category,
			G_criteria1, G_criteria2, G_criteria3, G_criteria4, G_criteria5,
			G_criteria6, G_criteria7, G_criteria8, G_criteria9, G_criteria10,
			G_criteria11, G_criteria12, G_criteria13, G_criteria14, G_criteria15;
      EXIT WHEN f_row_cursor%NOTFOUND OR f_row_cursor%NOTFOUND IS NULL;

      --
      -- Set Changing View Constants
      --
      CEFC_VIEW_CONST.set_rowid(G_rowid);
      CEFC_VIEW_CONST.set_constants(G_rp_forecast_header_id,
      		G_rp_calendar_name, G_rp_forecast_start_period,
      		G_rp_forecast_start_date, G_min_col, G_max_col);
      G_invalid_overdue_row := G_invalid_overdue;
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('Calling Pop Cells...for trx : ' || G_trx_type||
			    ' and row_number :' || G_row_number);
      END IF;
      XTR_CSH_FCST_POP.Populate_Cells;
    END LOOP;
    CLOSE f_row_cursor;
  END IF;

  IF (wrap_up_process(req_data) OR standalone_process) THEN
    SELECT  error_status
    INTO    l_status
    FROM    ce_forecasts
    WHERE   forecast_id = G_forecast_id;

    IF l_status <> 'E' THEN
      print_report;
    END IF;
  END IF;

  return;

EXCEPTION
  WHEN OTHERS THEN
    IF f_row_cursor%ISOPEN THEN CLOSE f_row_cursor; END IF;
    IF f_header_cursor%ISOPEN THEN CLOSE f_header_cursor; END IF;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug('EXCEPTION: XTR_CASH_FCST.cash_xtr_forecast');
      END IF;
    RAISE;
END create_forecast;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Forecast							|
|									|
|  DESCRIPTION								|
|	The forecast program is divided into two parts just for easy	|
|	submission. This procedure only calls doesn't do much but calls	|
|	other procedures which do the work				|
|  CALLED BY								|
|									|
|  REQUIRES								|
|	p_forecast_header_id	template id				|
|	p_forecast_runname	forecast name				|
|	p_forecast_start_date	start forecast on this date		|
|	p_forecast_currency	amount currency				|
|	p_exchange_type		exchange type				|
|	p_exchange_date		exchange date				|
|	p_src_curr_type		functional/entered			|
|	p_src_currency		filter currency for transactions	|
|	p_rownum_from		which rows				|
|	p_rownum_to							|
|	p_project_id		project id				|
|									|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */


PROCEDURE Forecast(errbuf		OUT NOCOPY VARCHAR2,
		retcode			OUT NOCOPY NUMBER,
		p_forecast_header_id	IN NUMBER,
		p_forecast_runname	IN VARCHAR2,
                p_company_code		IN VARCHAR2,
		p_forecast_start_date	IN VARCHAR2,
		p_rownum_from		IN NUMBER,
		p_rownum_to		IN NUMBER,
		p_sub_request		IN VARCHAR2) IS

  l_error_code	   NUMBER;

  -- AW Bug 1378198
  l_company_code   XTR_PARTY_INFO.PARTY_CODE%TYPE;

  /* RV BUG 1548223
  CURSOR c_company IS
  SELECT party_code
  FROM   xtr_party_info
  WHERE  party_code = nvl(p_company_code, party_code)
  AND    party_type = 'C';
 */

  CURSOR c_company IS
  SELECT party_code
  FROM   xtr_parties_v
  WHERE  party_code = nvl(p_company_code, party_code)
  AND    party_type = 'C';


BEGIN
  -- xtr_debug_pkg.enable_debug;

  -- AW Bug 1378198 The following is taken from procedure CREATE_FORECAST_HEADER
  --
  BEGIN
	  DELETE FROM ce_forecasts
	  WHERE  forecast_header_id = G_rp_forecast_header_id;
	  IF SQL%FOUND THEN
		COMMIT;
	  END IF;

	  DELETE FROM ce_forecast_errors
	  WHERE  forecast_header_id = G_rp_forecast_header_id;
          IF SQL%FOUND THEN
	 	COMMIT;
	  END IF;
  EXCEPTION
	WHEN OTHERS THEN
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION: XTR_CASH_FCST.forecast-->delete');
	END IF;
    RAISE;
  END;
  --
  OPEN c_company;
  LOOP
      FETCH c_company INTO l_company_code;
      EXIT WHEN c_company%NOTFOUND or c_company%NOTFOUND IS NULL;
      l_error_code := set_parameters( p_forecast_header_id,
                                      p_forecast_runname,
                                      p_forecast_start_date,
                                      'SOURCE',
                                      'A',
                                      l_company_code,
                                      p_rownum_from,
                                      p_rownum_to,
                                      p_sub_request);
      IF l_error_code = 0 THEN
         create_forecast;
      END IF;
  END LOOP;
  CLOSE c_company;

END Forecast;

END XTR_CASH_FCST;

/

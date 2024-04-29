--------------------------------------------------------
--  DDL for Package Body CE_CASH_FCST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CASH_FCST" AS
/* $Header: cefcshfb.pls 120.22.12000000.2 2007/03/30 15:53:29 kbabu ship $	*/

  --
  -- Get Header Information
  --
  CURSOR f_header_cursor (p_forecast_header_id NUMBER) IS
	SELECT 	cfh.name, cfh.aging_type,
		cfh.overdue_transactions, cfh.transaction_calendar_id,
		cfh.start_project_id, cfh.end_project_id
	FROM 	CE_FORECAST_HEADERS cfh
	WHERE 	cfh.forecast_header_id = p_forecast_header_id;

  --
  -- Get row information
  --
  CURSOR f_row_cursor (p_forecast_header_id NUMBER, p_rownum_from NUMBER, p_rownum_to NUMBER) IS
	SELECT	rowid, forecast_row_id, row_number, trx_type, nvl(lead_time,0),
		NVL(forecast_method,'F'), discount_option, DECODE(trx_type, 'PAY', 'PAY', 'XTR', 'XTR', 'XTI', 'XTR', 'XTO', 'XTR', SUBSTR(trx_type, 1,2)),
		include_float_flag, NVL(order_status,'A'),
		order_date_type, code_combination_id, budget_name,
		encumbrance_type_id, chart_of_accounts_id,
		set_of_books_id, NVL(org_id,-99), legal_entity_id,
		roll_forward_type, roll_forward_period,
		NVL(include_dispute_flag,'N'), sales_stage_id,
		channel_code, NVL(win_probability,0), sales_forecast_status,
		customer_profile_class_id, bank_account_id,
		receipt_method_id, vendor_type, payment_method, pay_group,
		payment_priority, authorization_status, type, budget_type,
		budget_version, include_hold_flag, include_net_cash_flag, budget_version_id,
		payroll_id, xtr_bank_account, company_code, exclude_indic_exp, org_payment_method_id,
		external_source_type, criteria_category,
		criteria1, criteria2, criteria3, criteria4, criteria5,
		criteria6, criteria7, criteria8, criteria9, criteria10,
		criteria11, criteria12, criteria13, criteria14, criteria15,
		use_average_payment_days, period, order_type_id,
                use_payment_terms, include_temp_labor_flag
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

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.22.12000000.2 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

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
PROCEDURE set_parameters (p_forecast_header_id		IN NUMBER,
			  p_forecast_runname		IN VARCHAR2,
			  p_forecast_start_date		IN VARCHAR2,
			  p_calendar_name		IN VARCHAR2,
			  p_forecast_start_period	IN VARCHAR2,
			  p_forecast_currency		IN VARCHAR2,
			  p_exchange_type		IN VARCHAR2,
			  p_exchange_date		IN VARCHAR2,
			  p_exchange_rate		IN NUMBER,
			  p_src_curr_type		IN VARCHAR2,
			  p_src_currency		IN VARCHAR2,
			  p_amount_threshold		IN NUMBER,
			  p_project_id			IN NUMBER,
			  p_rownum_from			IN NUMBER,
			  p_rownum_to			IN NUMBER,
			  p_sub_request			IN VARCHAR2,
			  p_factor			IN NUMBER,
			  p_include_sub_account		IN VARCHAR2,
			  p_view_by			IN VARCHAR2,
			  p_bank_balance_type		IN VARCHAR2,
			  p_float_type			IN VARCHAR2,
			  p_forecast_id			IN NUMBER,
			  p_display_debug		IN VARCHAR2,
			  p_debug_path			IN VARCHAR2,
			  p_debug_file			IN VARCHAR2) IS

  x_exchange_type	GL_DAILY_RATES.conversion_type%TYPE;
  l_is_fixed_rate	BOOLEAN;
  l_relationship 	VARCHAR2(30);
BEGIN

  /* In the case where p_src_curr_type = 'Entered', ensure that there is no
     fixed rate between the forecast and source currencies (both EMU currencies.
     If so, then override the p_exchange_type to 'EMU FIXED'.  This is to
     handle the case where the user enters an exchange type of 'User' from
     the SRS (concurrent submission form) when there is a fixed rate.  This
     scenario can occur due to the inability of flex fields to handle
     conditional value sets the way CE needs it and will result in erroneous
     forecast amounts. */

  IF (p_src_curr_type = 'E') then
     	GL_CURRENCY_API.get_relation(p_forecast_currency,
				     p_src_currency,
				     to_char(to_date(p_exchange_date,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY'),
				     l_is_fixed_rate,
				     l_relationship);

  	IF (p_forecast_currency = p_src_currency OR
            l_relationship NOT IN ('EURO-EMU', 'EMU-EURO',
				'EMU-EMU', 'EURO-EURO')) THEN
       		x_exchange_type := p_exchange_type;
        ELSIF (l_is_fixed_rate = TRUE) THEN
		x_exchange_type := 'EMU FIXED';
        ELSE
      		x_exchange_type := p_exchange_type;
	END IF;
  ELSE
  	x_exchange_type := p_exchange_type;
  END IF;

  cep_standard.debug('>>CE_CASH_FCST.set_parameters');
  G_rp_forecast_header_id	:=	p_forecast_header_id;
  G_rp_forecast_runname 	:=	p_forecast_runname;
  G_rp_forecast_start_date	:=	to_date(p_forecast_start_date,'YYYY/MM/DD HH24:MI:SS');
  G_rp_calendar_name 		:= 	p_calendar_name ;
  G_rp_forecast_start_period	:= 	p_forecast_start_period;
  G_rp_forecast_currency 	:=	p_forecast_currency;
  G_rp_exchange_type  		:= 	x_exchange_type;
  G_rp_exchange_date  		:=	to_date(p_exchange_date,'YYYY/MM/DD HH24:MI:SS');
  G_rp_exchange_rate  		:=	p_exchange_rate;
  G_rp_src_curr_type  		:=	p_src_curr_type;
  G_rp_src_currency		:=	p_src_currency;
  G_rp_amount_threshold		:=	p_amount_threshold;
  G_rp_project_id		:= 	p_project_id;
  G_rp_rownum_from		:=	p_rownum_from;
  G_rp_rownum_to		:=	p_rownum_to;
  G_rp_sub_request		:=	p_sub_request;
  G_forecast_id			:=	p_forecast_id;
  G_display_debug		:=      p_display_debug;
  G_debug_path			:= 	p_debug_path;
  G_debug_file			:=	p_debug_file;

  G_rp_bank_balance_type	:=	p_bank_balance_type;
  G_rp_float_type		:=	p_float_type;
  G_rp_view_by			:=	p_view_by;
  G_rp_include_sub_account	:=	p_include_sub_account;
  G_rp_factor			:=	p_factor;

  IF (p_src_currency IS NULL) THEN
	CE_CASH_FCST.G_rp_src_curr_type := 'A';
  END IF;
  IF(p_sub_request = 'Y' AND p_forecast_id IS NULL)THEN
    G_parent_process := TRUE;
  ELSE
    G_parent_process := FALSE;
  END IF;

  cep_standard.debug('CE_CASH_FCST.G_rp_forecast_header_id	: '||G_rp_forecast_header_id);
  cep_standard.debug('CE_CASH_FCST.G_rp_forecast_runname	: '||G_rp_forecast_runname);
  cep_standard.debug('CE_CASH_FCST.G_rp_calendar_name	: '||G_rp_calendar_name);
  cep_standard.debug('CE_CASH_FCST.G_rp_forecast_start_date	: '||G_rp_forecast_start_date);
  cep_standard.debug('CE_CASH_FCST.G_rp_forecast_start_period	: '||G_rp_forecast_start_period);
  cep_standard.debug('CE_CASH_FCST.G_rp_forecast_currency	: '||G_rp_forecast_currency);
  cep_standard.debug('CE_CASH_FCST.G_rp_exchange_type 		: '||G_rp_exchange_type);
  cep_standard.debug('CE_CASH_FCST.G_rp_exchange_date 		: '||G_rp_exchange_date);
  cep_standard.debug('CE_CASH_FCST.G_rp_exchange_rate 		: '||G_rp_exchange_rate);
  cep_standard.debug('CE_CASH_FCST.G_rp_src_curr_type		: '||G_rp_src_curr_type);
  cep_standard.debug('CE_CASH_FCST.G_rp_src_currency		: '||G_rp_src_currency);
  cep_standard.debug('CE_CASH_FCST.G_rp_rownum_from		: '||G_rp_rownum_from);
  cep_standard.debug('CE_CASH_FCST.G_rp_rownum_to		: '||G_rp_rownum_to);
  cep_standard.debug('CE_CASH_FCST.G_rp_sub_request		: '||G_rp_sub_request);
  cep_standard.debug('CE_CASH_FCST.G_forecast_id		: '||G_forecast_id);
  cep_standard.debug('CE_CASH_FCST.G_display_debug		: '||G_display_debug);
  cep_standard.debug('CE_CASH_FCST.G_debug_path			: '||G_debug_path);
  cep_standard.debug('CE_CASH_FCST.G_debug_file			: '||G_debug_file);

  --
  -- Set View constants
  --
  CEFC_VIEW_CONST.set_constants(G_rp_forecast_header_id,
  				G_rp_calendar_name,
  				G_rp_forecast_start_period,
  				G_rp_forecast_start_date);

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
  cep_standard.debug('Request Id is ' || request_id);
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    cep_standard.debug('Message: get print options failed');
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
					   'CEFCERR',
					   printer,
					   print_style,
				           save_output_flag))THEN
      cep_standard.debug('Message: get print options failed');
    END IF;
    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                          print_style,
                                          number_of_copies,
                                          save_output_bool)) THEN
      cep_standard.debug('Set print options failed');
    END IF;
  END IF;
  req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			          'CEFCERR',
				  NULL,
				  trunc(sysdate),
			          FALSE,
				  G_forecast_id);
END Print_Report;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Print_Forecast_Report						|
|									|
|  DESCRIPTION								|
|	This procedure submits a concurrent request to print the	|
|	Cash Forecast Report after a succesful run.			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|	p_forecast_header_id	forecast header id			|
|       p_forecast_id           forecast_id				|
|	p_forecast_start_date	forecast date				|
|  HISTORY								|
|	06-24-1998	Created		BHCHUNG				|
 --------------------------------------------------------------------- */
PROCEDURE Print_Forecast_Report IS
  req_id		NUMBER;
  request_id		NUMBER;
  reqid			VARCHAR2(30);
  number_of_copies	NUMBER;
  printer		VARCHAR2(30);
  print_style		VARCHAR2(30);
  save_output_flag	VARCHAR2(30);
  save_output_bool	BOOLEAN;
  l_forecast_header_id	NUMBER;
BEGIN
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', reqid);
  request_id := to_number(reqid);
  --
  -- Get print options
  --
  cep_standard.debug('Request Id is ' || request_id);
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    cep_standard.debug('Message: get print options failed');

  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;

    IF( FND_CONCURRENT.GET_PROGRAM_ATTRIBUTES ('CE',
					   'CEFCAMTS',
					   printer,
					   print_style,
				           save_output_flag))THEN
      cep_standard.debug('Message: get print options failed');
    END IF;

    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options(printer,
                                          print_style,
                                          number_of_copies,
                                          save_output_bool)) THEN
      cep_standard.debug('Set print options failed');
    END IF;
  END IF;

  SELECT  forecast_header_id
  INTO    l_forecast_header_id
  FROM    ce_forecasts
  WHERE   forecast_id = G_forecast_id;

  req_id := FND_REQUEST.SUBMIT_REQUEST('CE',
			          'CEFCAMTS',
				  NULL,
				  trunc(sysdate),
			          FALSE,
				  l_forecast_header_id,
				  G_forecast_id);
END Print_Forecast_Report;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_base_xrate_table					|
|									|
|  DESCRIPTION								|
|	populate the exchange rate information from GL table to 	|
|	CE_CURRENCY_RATES_TEMP for base currency 			|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	21-JUL-1997	Created		Wynne Chan			|
 ---------------------------------------------------------------------*/
FUNCTION populate_base_xrate_table RETURN BOOLEAN IS
  CURSOR from_curr(orig_curr VARCHAR2) IS
	SELECT 	currency_code
	FROM	fnd_currencies
	WHERE	enabled_flag 	= 'Y'
	AND	currency_code <> CE_CASH_FCST.G_rp_forecast_currency
	AND	currency_code <> 'STAT'
	AND	CE_CASH_FCST.G_rp_exchange_date BETWEEN
		  NVL(start_date_active,CE_CASH_FCST.G_rp_exchange_date) and
		  NVL(end_date_active,CE_CASH_FCST.G_rp_exchange_date);

  CURSOR bad_curr IS
	SELECT 	currency_code
	FROM	fnd_currencies
	WHERE	enabled_flag 	= 'Y'
	AND	currency_code <> CE_CASH_FCST.G_rp_forecast_currency
	AND	currency_code <> 'STAT'
	AND	( CE_CASH_FCST.G_rp_exchange_date <
		  NVL(start_date_active,CE_CASH_FCST.G_rp_exchange_date) OR
		  CE_CASH_FCST.G_rp_exchange_date >
		  NVL(end_date_active,CE_CASH_FCST.G_rp_exchange_date));

  CURSOR base_curr IS
	SELECT	distinct(org.currency_code)
	FROM	ce_forecast_rows r,
		ce_forecast_oe_orgs_v org
	WHERE	r.row_number BETWEEN
		  NVL(CE_CASH_FCST.G_rp_rownum_from, row_number) and
		  NVL(CE_CASH_FCST.G_rp_rownum_to, row_number)
	AND	r.forecast_header_id = CE_CASH_FCST.G_rp_forecast_header_id
	AND	org.currency_code <> CE_CASH_FCST.G_rp_forecast_currency
	AND	r.trx_type = 'OEO'
	AND	org.org_id = NVL(r.org_id, org.org_id);

  curr			FND_CURRENCIES.currency_code%TYPE;
  to_curr		FND_CURRENCIES.currency_code%TYPE;
  error_msg		FND_NEW_MESSAGES.message_text%TYPE;
  xrate			NUMBER;
  all_exist_flag	BOOLEAN := TRUE;
BEGIN
  cep_standard.debug('>>CE_CASH_FCST.populate_base_xrate_table');

  --
  -- For each base currencies used by OE rows, determine it's xrate from
  -- valid currencies to the base currency.
  --
  OPEN base_curr;
  LOOP
    FETCH base_curr INTO to_curr;
    EXIT WHEN (base_curr%NOTFOUND OR base_curr%NOTFOUND IS NULL);

    IF( to_curr <> CE_CASH_FCST.G_rp_forecast_currency)THEN
      OPEN from_curr(to_curr);
      LOOP

        FETCH from_curr INTO curr;
        EXIT WHEN (from_curr%NOTFOUND OR from_curr%NOTFOUND IS NULL);
        BEGIN
          xrate := GL_CURRENCY_API.get_rate(curr, to_curr,
			CE_CASH_FCST.G_rp_exchange_date,
			CE_CASH_FCST.G_rp_exchange_type);
          insert into CE_CURRENCY_RATES_TEMP
		(forecast_request_id, currency_code, exchange_rate, to_currency)
	  values (CE_CASH_FCST.G_forecast_id, curr, xrate, to_curr);
          cep_standard.debug(' Exchange info - '||curr||'->'||to_curr||' has rate '||to_char(xrate));
        EXCEPTION
          WHEN OTHERS THEN
          -- WHEN NO_RATE THEN
	    -- bug 1200912
	    IF (curr = CE_CASH_FCST.G_rp_src_currency) THEN
	      all_exist_flag := FALSE;
	      FND_MESSAGE.set_name ('CE','CE_FC_MISSING_EXCHANGE_RATE');
	      FND_MESSAGE.set_token('FROM_CURR', curr);
	      FND_MESSAGE.set_token('TO_CURR',
	      CE_CASH_FCST.G_rp_forecast_currency);
	      error_msg := FND_MESSAGE.GET;
	      CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,
		G_rp_forecast_header_id, null,'CE_FC_MISSING_RATE', error_msg);
	    END IF;
        END;
      END LOOP;
      CLOSE from_curr;

      --
      -- Insert constant rate (1) for base_currency to base_currency
      --
      insert into CE_CURRENCY_RATES_TEMP (forecast_request_id, currency_code,
		exchange_rate, to_currency)
      values (CE_CASH_FCST.G_forecast_id, to_curr, 1, to_curr);

      OPEN bad_curr;
      LOOP
        FETCH bad_curr INTO curr;
        EXIT WHEN (bad_curr%NOTFOUND OR bad_curr%NOTFOUND IS NULL);
        BEGIN
	   all_exist_flag := FALSE;
	   FND_MESSAGE.set_name ('CE','CE_FC_BAD_CURRENCY');
	   FND_MESSAGE.set_token('BAD_CURR', curr);
	   error_msg := FND_MESSAGE.GET;
	   CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,
		G_rp_forecast_header_id, null,'CE_FC_BAD_CURRENCY', error_msg);
        END;
      END LOOP;
      CLOSE bad_curr;

    END IF;
  END LOOP;
  CLOSE base_curr;

  cep_standard.debug('<<CE_CASH_FCST.populate_base_xrate_table');
  return (all_exist_flag);

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS:populate_base_xrate_table');
	IF from_curr%ISOPEN THEN CLOSE from_curr; END IF;
	IF base_curr%ISOPEN THEN CLOSE base_curr; END IF;
	IF bad_curr%ISOPEN THEN CLOSE bad_curr; END IF;
	RAISE;
	return (FALSE);
END populate_base_xrate_table;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_xrate_table						|
|									|
|  DESCRIPTION								|
|	populate the exchange rate information from GL table to 	|
|	CE_CURRENCY_RATES_TEMP						|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	21-JUL-1997	Created		Wynne Chan			|
 ---------------------------------------------------------------------*/
FUNCTION populate_xrate_table RETURN BOOLEAN IS
  CURSOR C IS
	SELECT 	currency_code
	FROM	fnd_currencies
	WHERE	enabled_flag = 'Y'
	AND	currency_code <> CE_CASH_FCST.G_rp_forecast_currency
	AND	currency_code <> 'STAT'
	AND 	CE_CASH_FCST.G_rp_exchange_date BETWEEN
		  NVL(start_date_active,CE_CASH_FCST.G_rp_exchange_date)
		  and NVL(end_date_active,CE_CASH_FCST.G_rp_exchange_date);

  CURSOR bad_curr IS
	SELECT 	currency_code
	FROM	fnd_currencies
	WHERE	enabled_flag = 'Y'
	AND	currency_code <> CE_CASH_FCST.G_rp_forecast_currency
	AND	currency_code <> 'STAT'
	AND	( CE_CASH_FCST.G_rp_exchange_date <
		  NVL(start_date_active,CE_CASH_FCST.G_rp_exchange_date) OR
		  CE_CASH_FCST.G_rp_exchange_date >
		  NVL(end_date_active,CE_CASH_FCST.G_rp_exchange_date));

  curr 			FND_CURRENCIES.currency_code%TYPE;
  from_curr		FND_CURRENCIES.currency_code%TYPE;
  to_curr 		FND_CURRENCIES.currency_code%TYPE;
  euro_curr		FND_CURRENCIES.currency_code%TYPE;
  error_msg		FND_NEW_MESSAGES.message_text%TYPE;
  xrate			NUMBER;
  skip_err_log		BOOLEAN;
  all_exist_flag	BOOLEAN := TRUE;
  fcast_curr_is_emu	VARCHAR2(1);
  src_curr_is_emu	VARCHAR2(1);
  from_curr_is_emu	VARCHAR2(1);
  l_currency_type 	VARCHAR2(5);

BEGIN
  cep_standard.debug('>>CE_CASH_FCST.populate_xrate_table');

  --
  -- Insert constant rate (1) for forecast_currency to forecast_currency
  --
  insert into CE_CURRENCY_RATES_TEMP
	(forecast_request_id, currency_code, exchange_rate, to_currency)
  values (CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_currency, 1,
	CE_CASH_FCST.G_rp_forecast_currency);

  IF( G_rp_forecast_currency <> G_rp_src_currency OR
      G_rp_src_curr_type <> 'E')THEN

    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    fcast_curr_is_emu
    FROM    FND_CURRENCIES
    WHERE   currency_code = CE_CASH_FCST.G_rp_forecast_currency AND
            derive_type = 'EMU';

    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    src_curr_is_emu
    FROM    FND_CURRENCIES
    WHERE   currency_code = CE_CASH_FCST.G_rp_src_currency AND
            derive_type = 'EMU';

    IF ( (fcast_curr_is_emu = 'Y' OR src_curr_is_emu = 'Y') OR
         G_rp_src_curr_type = 'A' ) THEN
      BEGIN
        SELECT  currency_code
        INTO    euro_curr
        FROM    fnd_currencies
        WHERE   derive_type = 'EURO';
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.set_name ('CE','CE_FC_EURO_NOT_DEFINED');
	  error_msg := FND_MESSAGE.GET;
	  CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,
		G_rp_forecast_header_id, null,'CE_FC_EURO_NOT_DEFINED',
		error_msg);
      END;
    END IF;

    OPEN C;
    LOOP
      FETCH C INTO from_curr;

      SELECT  DECODE(COUNT(*),0,'N','Y')
      INTO    from_curr_is_emu
      FROM    FND_CURRENCIES
      WHERE   currency_code = from_curr AND
              derive_type IN ('EMU','EURO');

      EXIT WHEN (C%NOTFOUND OR C%NOTFOUND IS NULL);
      BEGIN
          xrate := GL_CURRENCY_API.get_rate(from_curr, G_rp_forecast_currency,
			CE_CASH_FCST.G_rp_exchange_date,
			CE_CASH_FCST.G_rp_exchange_type);
          insert into CE_CURRENCY_RATES_TEMP (forecast_request_id,
			currency_code, exchange_rate, to_currency)
	  values (CE_CASH_FCST.G_forecast_id, from_curr, xrate,
			G_rp_forecast_currency);
          cep_standard.debug(' Exchange info - '||from_curr||' has rate '||to_char(xrate));
      EXCEPTION
        WHEN OTHERS THEN
        -- WHEN NO_RATE THEN
            skip_err_log := FALSE;

	    -- bug 1200912
	    -- from_curr always <> CE_CASH_FCST.G_rp_src_currency
            IF (G_rp_src_curr_type <> 'A'
		AND from_curr <> CE_CASH_FCST.G_rp_src_currency) THEN
	      skip_err_log := TRUE;
            END IF;

            to_curr := CE_CASH_FCST.G_rp_forecast_currency;

            IF    (from_curr_is_emu = 'N' and fcast_curr_is_emu = 'Y') THEN
              SELECT decode( derive_type,
  	            'EURO', 'EURO',
	            'EMU', decode( sign( trunc(CE_CASH_FCST.G_rp_exchange_date)
				 -  trunc(derive_effective)),
	  	                 -1, 'OTHER',
			         'EMU'),
                    'OTHER' )
	      INTO l_currency_type
     	      FROM   FND_CURRENCIES
	      WHERE  currency_code = to_curr;
              IF (l_currency_type = 'EMU') THEN
                to_curr := euro_curr;
              END IF;
      	    ELSIF (from_curr_is_emu = 'Y' and fcast_curr_is_emu = 'N') THEN
 	      SELECT decode( derive_type,
  	            'EURO', 'EURO',
	            'EMU', decode( sign( trunc(CE_CASH_FCST.G_rp_exchange_date)
				 -  trunc(derive_effective)),
	  	                 -1, 'OTHER',
			         'EMU'),
                    'OTHER' )
	      INTO l_currency_type
     	      FROM   FND_CURRENCIES
	      WHERE  currency_code = from_curr;
              IF (l_currency_type = 'EMU') THEN
                from_curr := euro_curr;
              END IF;
      	    ELSIF (from_curr_is_emu = 'Y' and fcast_curr_is_emu = 'Y') THEN
              skip_err_log := TRUE;
            ELSIF (from_curr_is_emu = 'N' and fcast_curr_is_emu = 'N') THEN
              IF from_curr = to_curr  THEN
                skip_err_log := TRUE;
              END IF;
            END IF;

            IF skip_err_log = FALSE THEN
	      all_exist_flag := FALSE;
	      FND_MESSAGE.set_name ('CE','CE_FC_MISSING_EXCHANGE_RATE');
	      FND_MESSAGE.set_token('FROM_CURR', from_curr);
	      FND_MESSAGE.set_token('TO_CURR',to_curr);
	      error_msg := FND_MESSAGE.GET;
	      CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,
		  G_rp_forecast_header_id, null,'CE_FC_MISSING_RATE',
		  error_msg);
            END IF;
      END;
    END LOOP;
    CLOSE C;

    OPEN bad_curr;
    LOOP
      FETCH bad_curr INTO curr;
      EXIT WHEN (bad_curr%NOTFOUND OR bad_curr%NOTFOUND IS NULL);
      BEGIN
	all_exist_flag := FALSE;
	IF (G_rp_src_curr_type = 'A'
		OR curr = CE_CASH_FCST.G_rp_src_currency) THEN
	  FND_MESSAGE.set_name ('CE','CE_FC_BAD_CURRENCY');
	  FND_MESSAGE.set_token('BAD_CURR', curr);
	  error_msg := FND_MESSAGE.GET;
	  CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,
	     G_rp_forecast_header_id, null,'CE_FC_BAD_CURRENCY', error_msg);
	END IF;
      END;
    END LOOP;
    CLOSE bad_curr;

  END IF;

  cep_standard.debug('<<CE_CASH_FCST.populate_xrate_table');
  return (all_exist_flag);

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS:populate_xrate_table');
	IF C%ISOPEN THEN CLOSE C; END IF;
	IF bad_curr%ISOPEN THEN CLOSE bad_curr; END IF;
	RAISE;
	return (FALSE);
END populate_xrate_table;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	clear_xrate_table						|
|									|
|  DESCRIPTION								|
|	clear the exchange rate information in CE_CURRENCY_RATES_TEMP	|
|									|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	21-JUL-1997	Created		Wynne Chan			|
 ---------------------------------------------------------------------*/
PROCEDURE clear_xrate_table IS
BEGIN
  cep_standard.debug('Delete all xrate information');
  delete from CE_CURRENCY_RATES_TEMP
  	where forecast_request_id = CE_CASH_FCST.G_forecast_id;
EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS: clear_xrate_table');
	RAISE;
END clear_xrate_table;


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

  cep_standard.debug('>>validate_transaction_calendar');

  SELECT min(transaction_date), max(transaction_date)
  INTO	 CE_CSH_FCST_POP.G_calendar_start, CE_CSH_FCST_POP.G_calendar_end
  FROM	 gl_transaction_dates
  WHERE	 transaction_calendar_id = G_transaction_calendar_id;

  IF(CE_CSH_FCST_POP.G_calendar_start IS NULL OR
     CE_CSH_FCST_POP.G_calendar_end IS NULL)THEN
    cep_standard.debug('Cannot find transaction calendar');
    G_transaction_calendar_id := NULL;
  END IF;

  cep_standard.debug('<<validate_transaction_calendar');
EXCEPTION
  WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION - OTHERS: validate_transaction_calendar');
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
|	valid_row_info						|
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
  cep_standard.debug('>>CE_CASH_FCST.valid_calendar_name');

  IF(G_app_short_name = 'GL')THEN
    SELECT	period_set_name, set_of_books_id, name, currency_code
    INTO	calendar, sob_id, sob_name, G_sob_currency_code
    FROM	gl_sets_of_books	gsb
    WHERE	gsb.set_of_books_id 	= G_set_of_books_id;

    IF (calendar <> G_rp_calendar_name) THEN
      valid_period := FALSE;
      FND_MESSAGE.set_name('CE', 'CE_FC_INVALID_PERIOD_SET_NAME');
      FND_MESSAGE.set_token('SOB_NAME', sob_name);
      FND_MESSAGE.set_token('START_PERIOD', G_rp_calendar_name);
      error_msg := fnd_message.get;
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
        FND_MESSAGE.set_token('START_PERIOD', G_rp_calendar_name);
        error_msg := fnd_message.get;
        CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, G_forecast_row_id,
					'CE_FC_INVALID_PERIOD', error_msg);
      END IF;
    END LOOP;
  END IF;

  cep_standard.debug('<<CE_CASH_FCST.valid_calendar_name');
  return (valid_period);
EXCEPTION
   WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION -OTHERS:valid_calendar_name');
	IF sob_c%ISOPEN THEN CLOSE sob_c; END IF;
	RAISE;
END valid_calendar_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	valid_col_info							|
|  DESCRIPTION								|
|	Validate column information to ensure all information in a 	|
|	column is valid							|
|  CALLED BY								|
|       valid_forecast_run                                                 |
|  HISTORY                                                              |
|       21-AUG-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
FUNCTION valid_col_info RETURN BOOLEAN IS
  error_msg     FND_NEW_MESSAGES.message_text%TYPE;
  valid_col	BOOLEAN := TRUE;
  col_count	NUMBER;
BEGIN
  SELECT 	count(1)
  INTO		col_count
  FROM		ce_forecast_columns
  WHERE		forecast_header_id = G_rp_forecast_header_id;

  IF( col_count = 0)THEN
    SELECT 	count(1)
    INTO 	col_count
    FROM 	ce_forecast_periods
    WHERE 	forecast_header_id = G_rp_forecast_header_id;

    IF (col_count = 0) THEN
      valid_col := FALSE;
      FND_MESSAGE.set_name('CE', 'CE_FC_NO_COLUMN');
      error_msg := fnd_message.get;
      CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, null,
                                        'CE_FC_NO_COLUMN', error_msg);
    END IF;
  END IF;

  return valid_col;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_CASH_FCST.valid_col_info');
    RAISE;
END valid_col_info;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       valid_col_range                                                 |
|  DESCRIPTION                                                          |
|       Make sure columns are defined such that it is not exceeding	|
|       the database limit                                              |
|  CALLED BY                                                            |
|       create_forecast                                                 |
|  HISTORY                                                              |
|       21-AUG-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
FUNCTION valid_col_range RETURN BOOLEAN IS
  CURSOR cCol IS SELECT	forecast_column_id, column_number, days_from, days_to
  		 FROM	ce_forecast_columns
		 WHERE	forecast_header_id = G_rp_forecast_header_id;

  error_msg     FND_NEW_MESSAGES.message_text%TYPE;
  col_num	NUMBER;
  cid		NUMBER;
  days_from	NUMBER;
  days_to	NUMBER;
  all_valid	BOOLEAN DEFAULT TRUE;
BEGIN
  cep_standard.debug('>>CE_CASH_FCST.valid_col_range');

  G_min_col := CEFC_VIEW_CONST.get_min_col;
  G_max_col := CEFC_VIEW_CONST.get_max_col;
  G_invalid_overdue := FALSE;
  cep_standard.debug('G_min_col = '||to_char(G_min_col));
  cep_standard.debug('G_max_col = '||to_char(G_max_col));

  OPEN cCol;
  FETCH cCol INTO cid, col_num, days_from, days_to;
  LOOP
    EXIT WHEN cCol%NOTFOUND OR cCol%NOTFOUND IS NULL;

    IF( days_from < G_min_col OR
	days_from > G_max_col OR
	days_to < G_min_col OR
	days_to > G_max_col) THEN

      all_valid := FALSE;
      FND_MESSAGE.set_name ('CE','CE_FC_COLUMN_NOT_IN_RANGE');
      FND_MESSAGE.set_token('COLUMN', col_num);
      error_msg := FND_MESSAGE.GET;
      CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id,
                                          null,'CE_FC_COLUMN_NOT_IN_RANGE', error_msg);
    END IF;

    IF(col_num = 0 AND days_to < G_min_col )THEN
      G_invalid_overdue := TRUE;
    END IF;

    FETCH cCol INTO cid, col_num, days_from, days_to;
  END LOOP;

  cep_standard.debug('<<CE_CASH_FCST.valid_col_range');
  return(all_valid);

EXCEPTION
  WHEN OTHERS THEN
    	IF(cCol%ISOPEN)THEN CLOSE cCol; END IF;
	cep_standard.debug('EXCEPTION: CE_CASH_FCST.valid_col_range');
	RAISE;
END valid_col_range;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE							|
|	valid_row_info							|
|  DESCRIPTION								|
|	Validate row information to ensure all information in a row is	|
|	valid								|
|  CALLED BY								|
|       valid_forecast_run                                                 |
|  HISTORY                                                              |
|       21-AUG-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
FUNCTION valid_row_info RETURN BOOLEAN IS
  error_msg     FND_NEW_MESSAGES.message_text%TYPE;
  valid_row	BOOLEAN := TRUE;
  row_exists	BOOLEAN := FALSE;
BEGIN
  G_gl_cash_only := FALSE;

  OPEN f_row_cursor (G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);
  LOOP
    FETCH f_row_cursor INTO G_rowid, G_forecast_row_id,
			G_row_number,G_trx_type,
			G_lead_time, G_forecast_method,
			G_discount_option,G_app_short_name, G_include_float_flag,
			G_order_status, G_order_date_type,
			G_code_combination_id, G_budget_name,
			G_encumbrance_type_id, G_chart_of_accounts_id ,
			G_set_of_books_id, G_org_id, G_legal_entity_id,
			G_roll_forward_type, G_roll_forward_period,
			G_include_dispute_flag, G_sales_stage_id,G_channel_code,
			G_win_probability, G_sales_forecast_status, G_customer_profile_class_id,
			G_bank_account_id, G_receipt_method_id,G_vendor_type,
			G_payment_method, G_pay_group,G_payment_priority,
			G_authorization_status, G_type, G_budget_type, G_budget_version,
			G_include_hold_flag, G_include_net_cash_flag, G_budget_version_id,
			G_payroll_id, G_xtr_bank_account, G_company_code, G_exclude_indic_exp, G_org_payment_method_id,
			G_external_source_type, G_criteria_category,
			G_criteria1, G_criteria2, G_criteria3, G_criteria4, G_criteria5,
			G_criteria6, G_criteria7, G_criteria8, G_criteria9, G_criteria10,
			G_criteria11, G_criteria12, G_criteria13, G_criteria14, G_criteria15,
			G_use_average_payment_days, G_apd_period, G_order_type_id,
                        G_use_payment_terms, G_include_temp_labor_flag;

    EXIT WHEN f_row_cursor%NOTFOUND OR f_row_cursor%NOTFOUND IS NULL;
    row_exists := TRUE;

    IF (G_aging_type = 'A') THEN
      IF( NOT valid_calendar_name )THEN
	valid_row := FALSE;
      END IF;
    END IF;

  END LOOP;
  CLOSE f_row_cursor;

  IF( NOT row_exists )THEN
    -- If row does not exist, this implies either no rows or only gl cash position row.
    -- The following cursor retrieve any row in this case to confirm that there is at
    -- least one gl cash position before flagging an error.
    OPEN f_glc_cursor(G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);
    FETCH f_glc_cursor INTO G_rowid, G_forecast_row_id, G_row_number,
			      G_set_of_books_id, G_code_combination_id, G_chart_of_accounts_id;
    IF f_glc_cursor%found THEN
       G_gl_cash_only := TRUE;
    END IF;

    CLOSE f_glc_cursor;


    IF (NOT G_gl_cash_only) THEN

       valid_row := FALSE;
       FND_MESSAGE.set_name('CE', 'CE_FC_NO_ROW');
       error_msg := fnd_message.get;
       CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, null,
                                          'CE_FC_NO_ROW', error_msg);
    END IF;
  END IF;

  return valid_row;
EXCEPTION
  WHEN OTHERS THEN
    IF f_row_cursor%ISOPEN THEN CLOSE f_row_cursor; END IF;
    cep_standard.debug('EXCEPTION: CE_CASH_FCST.valid_row_info');
    RAISE;
END valid_row_info;


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
  cep_standard.debug('>> CE_CASH_FCST.submit_child_requests ');

  open CRowNumber(G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);
  LOOP
    FETCH CRowNumber INTO G_row_number;
    EXIT WHEN CRowNumber%NOTFOUND OR CRowNumber%NOTFOUND IS NULL;

    IF(G_rp_forecast_start_date IS NOT NULL)THEN
      request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE', 'CEFCSTBD',to_char(G_row_number),'',TRUE,
                G_rp_forecast_header_id,
                G_rp_forecast_runname,
		G_rp_factor,
		G_start_project_no,
		G_end_project_no,
		G_rp_calendar_name,
                to_char(G_rp_forecast_start_date,'YYYY/MM/DD HH24:MI:SS'),
                G_rp_forecast_currency,
                G_rp_src_curr_type,
                null,
                G_rp_src_currency,
                to_char(G_rp_exchange_date,'YYYY/MM/DD HH24:MI:SS'),
                G_rp_exchange_type,
                G_rp_exchange_rate,
                to_char(G_row_number),
                to_char(G_row_number),
                G_rp_amount_threshold,
		'Y',
		G_rp_view_by,
		null,
		G_rp_bank_balance_type,
		G_rp_float_type,
		G_rp_include_sub_account,
		to_char(G_forecast_id),
		G_display_debug,
		G_debug_path,
		G_debug_file,
		'N',
                fnd_global.local_chr(0),'',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','');
    ELSE
      request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE', 'CEFCSHAP',to_char(G_row_number),'',TRUE,
                G_rp_forecast_header_id,
                G_rp_forecast_runname,
		G_rp_factor,
		G_start_project_no,
		G_end_project_no,
                G_rp_calendar_name,
                G_rp_forecast_start_period,
                G_rp_forecast_currency,
                G_rp_src_curr_type,
                null,
                G_rp_src_currency,
                to_char(G_rp_exchange_date,'YYYY/MM/DD HH24:MI:SS'),
                G_rp_exchange_type,
                G_rp_exchange_rate,
                to_char(G_row_number),
                to_char(G_row_number),
                G_rp_amount_threshold,
		'Y',
		G_rp_view_by,
		null,
		G_rp_bank_balance_type,
		G_rp_float_type,
		G_rp_include_sub_account,
		to_char(G_forecast_id),
                null,
		G_display_debug,
		G_debug_path,
		G_debug_file,
		'N',
		fnd_global.local_chr(0),
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','');
    END IF;
  END LOOP;
  CLOSE CRowNumber;
EXCEPTION
  WHEN OTHERS THEN
    IF CRowNumber%ISOPEN THEN CLOSE CRowNumber; END IF;
    cep_standard.debug('EXCEPTION: CE_CASH_FCST.submit_child_requests');
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
|       12-JUL-1996     Created         Bidemi Carrol                   |
 --------------------------------------------------------------------- */
PROCEDURE create_forecast_header IS
  l_forecast_rowid	VARCHAR2(30);
  fid			NUMBER;
  error_msg     	FND_NEW_MESSAGES.message_text%TYPE;
  duplicate_name	BOOLEAN DEFAULT FALSE;
  l_fc_count		NUMBER;
  l_reqid		NUMBER;
  l_request_id 		NUMBER;
BEGIN
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', l_reqid);
  l_request_id := to_number(l_reqid);

  IF (G_rp_forecast_runname IS NULL) THEN
    G_rp_forecast_runname:= G_forecast_name||'/'||to_char(sysdate,'YYYY/MM/DD HH24:MI:SS');
  ELSE
    BEGIN
      IF G_forecast_id is null THEN
        SELECT 	forecast_id
        INTO	fid
        FROM	ce_forecasts
        WHERE	name = G_rp_forecast_runname;
      ELSE
        SELECT 	forecast_id
        INTO	fid
        FROM	ce_forecasts
        WHERE	name = G_rp_forecast_runname
        AND     forecast_id <> G_forecast_id;
      END IF;

      duplicate_name := TRUE;
      G_rp_forecast_runname := G_rp_forecast_runname||'/'||to_char(sysdate,'DD-MON-RRRR HH:MI:SS');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	null;
    END;
  END IF;

  SELECT count(1)
  INTO l_fc_count
  FROM ce_forecasts
  WHERE forecast_id = G_forecast_id;

  IF l_fc_count = 0 THEN
    CE_FORECASTS_TABLE_PKG.Insert_Row(
			X_Rowid			=> l_forecast_rowid,
			X_forecast_id		=> G_forecast_id,
			X_forecast_header_id	=> G_rp_forecast_header_id,
			X_name			=> G_rp_forecast_runname,
			X_description		=> null,
			X_start_date		=> G_rp_forecast_start_date,
			X_period_set_name	=> G_rp_calendar_name,
			X_start_period		=> G_rp_forecast_start_period,
			X_forecast_currency	=> G_rp_forecast_currency,
			X_currency_type		=> NVL(G_rp_src_curr_type,'F'),
			X_source_currency	=> G_rp_src_currency,
			X_exchange_rate_type	=> G_rp_exchange_type,
			X_exchange_date		=> G_rp_exchange_date,
			X_exchange_rate		=> G_rp_exchange_rate,
			X_error_status		=> 'R',
			X_amount_threshold	=> G_rp_amount_threshold,
			X_project_id		=> G_rp_project_id,
			X_drilldown_flag	=> 'Y',
			X_bank_balance_type	=> nvl(G_rp_bank_balance_type,'L'),
			X_float_type		=> nvl(G_rp_float_type,'NONE'),
			X_view_by		=> nvl(G_rp_view_by,'NONE'),
			X_include_sub_account	=> nvl(G_rp_include_sub_account,'N'),
			X_factor		=> nvl(G_rp_factor,0),
			X_request_id		=> l_request_id,
			X_created_by		=> nvl(fnd_global.user_id, -1),
			X_creation_date		=> sysdate,
			X_last_updated_by	=> nvl(fnd_global.user_id, -1),
			X_last_update_date	=> sysdate,
			X_last_update_login	=> nvl(fnd_global.user_id, -1),
			X_attribute_category	=> null,
			X_attribute1		=> null,
			X_attribute2		=> null,
			X_attribute3		=> null,
			X_attribute4		=> null,
			X_attribute5		=> null,
			X_attribute6		=> null,
			X_attribute7		=> null,
			X_attribute8		=> null,
			X_attribute9		=> null,
			X_attribute10		=> null,
			X_attribute11		=> null,
			X_attribute12		=> null,
			X_attribute13		=> null,
			X_attribute14		=> null,
			X_attribute15		=> null);
    commit;
  END IF;

  IF(duplicate_name)THEN
    FND_MESSAGE.set_name ('CE','CE_FC_DUPLICATE_FORECAST_NAME');
    error_msg := FND_MESSAGE.GET;
    CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id,
                                      null,'CE_FC_DUPLICATE_FORECAST_NAME', error_msg);
    UPDATE  ce_forecasts
      SET   error_status = 'X'
      WHERE forecast_id = G_forecast_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION: CE_CASH_FCST.create_forecast_header ');
	RAISE;
END create_forecast_header;

/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION                                                      |
|       valid_exchange_pmr                                            |
|                                                                       |
|  DESCRIPTION                                                          |
|       This is used to ensure all SRS parameters are correctly         |
|       entered.                                                        |
| CALLED BY                                                             |
|                                                                       |
|  REQUIRES                                                             |
|                                                                       |
|  HISTORY                                                              |
|       26-SEP-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
FUNCTION valid_exchange_pmr RETURN BOOLEAN IS
  error_msg     FND_NEW_MESSAGES.message_text%TYPE;
  valid_pmr     BOOLEAN := TRUE;
BEGIN
  IF((G_rp_src_curr_type = 'E' AND
      G_rp_forecast_currency <> G_rp_src_currency) OR
     G_rp_src_curr_type IN ('F', 'A'))THEN
    IF(G_rp_exchange_date IS NULL OR
       G_rp_exchange_type IS NULL )THEN
      valid_pmr := FALSE;
    END IF;
  END IF;

  IF (G_rp_exchange_type = 'User' AND
      G_rp_exchange_rate IS NULL)THEN
    valid_pmr := FALSE;
  END IF;

  IF(not valid_pmr)THEN
    FND_MESSAGE.set_name('CE', 'CE_FC_PMR_MISSING_XINFO');
    error_msg := fnd_message.get;
    CE_FORECAST_ERRORS_PKG.insert_row(G_forecast_id,G_rp_forecast_header_id, null,
					'CE_FC_PMR_MISSING_XINFO', error_msg);
  END IF;

  return valid_pmr;
END valid_exchange_pmr;


/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION                                                      |
|       valid_forecast_run                                            |
|                                                                       |
|  DESCRIPTION                                                          |
|       This is used to ensure all SRS parameters are correctly 	|
|	entered.							|
| CALLED BY                                                             |
|                                                                       |
|  REQUIRES                                                             |
|                                                                       |
|  HISTORY                                                              |
|       26-SEP-1997	Created		Wynne Chan			|
 --------------------------------------------------------------------- */
FUNCTION valid_forecast_run RETURN BOOLEAN IS
  valid_pmr	BOOLEAN := TRUE;
BEGIN
  IF( NOT valid_exchange_pmr )THEN
    valid_pmr := FALSE;
  END IF;

  IF( NOT valid_col_info )THEN
    valid_pmr := FALSE;
  END IF;

  IF( NOT valid_row_info )THEN
    valid_pmr := FALSE;
  END IF;

  IF(NOT valid_pmr)THEN
    UPDATE 	ce_forecasts
    SET 	error_status = 'E'
    WHERE 	forecast_id = G_forecast_id;

    cep_standard.debug('Forecast NOT run');
    commit;
    print_report;
  END IF;

  return valid_pmr;
EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION: CE_CASH_FCST.valid_forecast_run');
END valid_forecast_run;

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
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE create_forecast IS
  counter	NUMBER;
  req_data	VARCHAR2(30);
  l_status	VARCHAR2(1);
  col_setup 	VARCHAR2(1);
BEGIN
  cep_standard.debug('>>CE_CASH_FCST.create_forecast');

  counter := 0;
  --
  -- Get forecast header info
  --
  OPEN f_header_cursor(G_rp_forecast_header_id);
  FETCH f_header_cursor INTO G_forecast_name, G_aging_type,
    			     G_overdue_transactions, G_transaction_calendar_id,
			     G_start_project_id, G_end_project_id;
  CLOSE f_header_cursor;
  cep_standard.debug('Aging type: ' || G_aging_type);
  cep_Standard.debug('Name: '|| G_forecast_name);

  FND_CURRENCY.get_info(G_rp_forecast_currency, G_precision, G_ext_precision, G_min_acct_unit);

  IF(G_overdue_transactions = 'INCLUDE')THEN
    BEGIN
      SELECT 	forecast_column_id
      INTO	G_overdue_column_id
      FROM	ce_forecast_columns
      WHERE	forecast_header_id = G_rp_forecast_header_id	AND
		developer_column_num = 0;
    EXCEPTION
      WHEN OTHERS THEN
	cep_standard.debug('ERROR: cannot get overdue column id');
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

    IF( NOT valid_forecast_run )THEN
      return;
    END IF;

    --
    -- Populate exchange information from GL for forecast currency
    --
    IF( CE_CASH_FCST.G_rp_exchange_type <> 'User' OR
        CE_CASH_FCST.G_rp_exchange_type IS NULL )THEN
      IF( NOT populate_xrate_table ) THEN
        UPDATE 	ce_forecasts
	  SET 	error_status = 'X'
	  WHERE forecast_id = G_forecast_id;
      END IF;
    END IF;

    --
    -- Populate exchange information from GL for base currency.
    -- This is done specifically for the OE transactions since OE
    -- transaction stores the order amount in transaction currency
    -- only and not in functional currency.
    --

    IF (NOT G_gl_cash_only) THEN
	IF( CE_CASH_FCST.G_rp_src_curr_type = 'F' AND
		CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL )THEN
		IF( NOT populate_base_xrate_table )THEN
			UPDATE ce_forecasts
			set error_status = 'X'
			where forecast_id = G_forecast_id;
		END IF;
	END IF;
    END IF;

    IF( NOT valid_col_range )THEN
      UPDATE	ce_forecasts
      SET	error_status = 'X'
      WHERE	forecast_id = G_forecast_id;
    END IF;
  END IF;

  IF(parent_process(req_data))THEN
    IF (NOT G_gl_cash_only) THEN
	submit_child_requests;
	fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
				    request_data => to_char(G_forecast_id));
    END IF;
  END IF;

  -- Add validation here for bug 1346485.
  IF(standalone_process OR child_process)THEN
    if (not valid_row_info) then
        return;
    end if;
  END IF;

  IF ((standalone_process AND (NOT G_gl_cash_only)) OR child_process) THEN
    OPEN f_row_cursor(G_rp_forecast_header_id,G_rp_rownum_from, G_rp_rownum_to);
    cep_standard.debug('Forecast defn valid');

    -- If column setup is automatic populate CE_FORECAST_COLUMNS
    -- before populating cells.
    SELECT nvl(column_setup,'M')
    INTO col_setup
    FROM ce_forecast_headers
    WHERE forecast_header_id = G_rp_forecast_header_id;

/*
    IF (col_setup = 'A') THEN
      CE_FORECAST_UTILS.populate_temp_buckets(G_rp_forecast_header_id, G_rp_forecast_start_date);
    END IF;
*/

    LOOP
      FETCH f_row_cursor INTO G_rowid, G_forecast_row_id,
			G_row_number, G_trx_type,
			G_lead_time, G_forecast_method,
			G_discount_option, G_app_short_name,G_include_float_flag,
			G_order_status, G_order_date_type,
			G_code_combination_id, G_budget_name,
			G_encumbrance_type_id, G_chart_of_accounts_id ,
			G_set_of_books_id, G_org_id, G_legal_entity_id,
			G_roll_forward_type, G_roll_forward_period,
			G_include_dispute_flag, G_sales_stage_id,G_channel_code,
			G_win_probability, G_sales_forecast_status, G_customer_profile_class_id,
			G_bank_account_id, G_receipt_method_id, G_vendor_type,
			G_payment_method,  G_pay_group,G_payment_priority,
			G_authorization_status, G_type, G_budget_type, G_budget_version,
			G_include_hold_flag, G_include_net_cash_flag, G_budget_version_id,
			G_payroll_id, G_xtr_bank_account, G_company_code, G_exclude_indic_exp, G_org_payment_method_id,
			G_external_source_type, G_criteria_category,
			G_criteria1, G_criteria2, G_criteria3, G_criteria4, G_criteria5,
			G_criteria6, G_criteria7, G_criteria8, G_criteria9, G_criteria10,
			G_criteria11, G_criteria12, G_criteria13, G_criteria14, G_criteria15,
			G_use_average_payment_days, G_apd_period,
                        G_order_type_id, G_use_payment_terms, G_include_temp_labor_flag;
      EXIT WHEN f_row_cursor%NOTFOUND OR f_row_cursor%NOTFOUND IS NULL;

      --
      -- Set Changing View Constants
      --
      CEFC_VIEW_CONST.set_rowid(G_rowid);
      CEFC_VIEW_CONST.set_constants(G_rp_forecast_header_id,
      		G_rp_calendar_name, G_rp_forecast_start_period,
      		G_rp_forecast_start_date, G_min_col, G_max_col);
      G_invalid_overdue_row := G_invalid_overdue;

      cep_standard.debug('Calling Pop Cells...for trx : ' || G_trx_type||
			 ' and row_number :' || G_row_number);
      CE_CSH_FCST_POP.Populate_Cells;
    END LOOP;
    CLOSE f_row_cursor;
  END IF;

  SELECT  error_status
  INTO    l_status
  FROM    ce_forecasts
  WHERE   forecast_id = G_forecast_id;

  IF (wrap_up_process(req_data) OR standalone_process) THEN
    clear_xrate_table;
    commit;
    print_report;

    IF l_status <> 'E' THEN
      print_forecast_report;
    END IF;
  END IF;

  IF l_status = 'R' THEN
    UPDATE ce_forecasts
    SET error_status = 'S'
    WHERE forecast_id = G_forecast_id;
  ELSIF l_status = 'X' THEN
    UPDATE ce_forecasts
    SET error_status = 'W'
    WHERE forecast_id = G_forecast_id;
  END IF;

  return;

EXCEPTION
  WHEN OTHERS THEN
    IF f_row_cursor%ISOPEN THEN CLOSE f_row_cursor; END IF;
    IF f_header_cursor%ISOPEN THEN CLOSE f_header_cursor; END IF;
    cep_standard.debug('EXCEPTION: CE_CASH_FCST.cash_forecast');
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
|	p_forecast_start_period	start forecast at this period		|
|	p_forecast_currency	amount currency				|
|	p_exchange_type		exchange type				|
|	p_exchange_date		exchange date				|
|	p_src_curr_type		functional/entered			|
|	p_src_currency		filter currency for transactions	|
|	p_rownum_from		which rows				|
|	p_rownum_to							|
|	p_dummy			just to differentiate this procedure 	|
|	p_project_id		project_id				|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Forecast(errbuf		OUT NOCOPY VARCHAR2,
		retcode			OUT NOCOPY NUMBER,
		p_forecast_header_id	IN NUMBER,
		p_forecast_runname	IN VARCHAR2,
		p_factor		IN NUMBER,
		p_start_project_num	IN VARCHAR2,
                p_end_project_num	IN VARCHAR2,
		p_calendar_name		IN VARCHAR2,
		p_forecast_start_period	IN VARCHAR2,
		p_forecast_currency	IN VARCHAR2,
		p_src_curr_type		IN VARCHAR2,
		p_src_curr_dummy	in varchar2,
		p_src_currency		IN VARCHAR2,
		p_exchange_date		IN VARCHAR2,
		p_exchange_type		IN VARCHAR2,
		p_exchange_rate		IN NUMBER,
		p_rownum_from		IN NUMBER,
		p_rownum_to		IN NUMBER,
		p_amount_threshold_x	IN VARCHAR2,
		p_sub_request		IN VARCHAR2,
		p_view_by		IN VARCHAR2,
		p_view_dummy		IN VARCHAR2,
		p_bank_balance_type	IN VARCHAR2,
		p_float_type		IN VARCHAR2,
		p_include_sub_account	IN VARCHAR2,
		p_forecast_id		IN NUMBER,
		p_dummy			IN VARCHAR2,
		p_display_debug         IN VARCHAR2,
		p_debug_path		IN VARCHAR2,
		p_debug_file		IN VARCHAR2,
		p_fc_name_exists	IN VARCHAR2)IS
 CURSOR C_fpid IS
   SELECT 	project_id, segment1
   FROM		pa_projects_all
   WHERE	segment1 >= p_start_project_num
     AND	segment1 <= p_end_project_num;
  error_msg     	FND_NEW_MESSAGES.message_text%TYPE;
  p_amount_threshold	NUMBER;
BEGIN

 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security; --for bug 5702438

  -- Now the process is officially 'Running' and not 'Pending'
  --bug 4345353 convert amount threshold from canonical to number
  p_amount_threshold := fnd_number.canonical_to_number(p_amount_threshold_x);
  UPDATE ce_forecasts
  SET error_status = 'R'
  WHERE forecast_id = p_forecast_id
  AND error_status = 'P';
  commit;

  IF (p_fc_name_exists = 'Y') THEN
    FND_MESSAGE.set_name ('CE','CE_FC_DUPLICATE_FORECAST_NAME');
    error_msg := FND_MESSAGE.GET;
    CE_FORECAST_ERRORS_PKG.insert_row(p_forecast_id,p_forecast_header_id,
		null,'CE_FC_DUPLICATE_FORECAST_NAME', error_msg);
    UPDATE ce_forecasts
    SET error_status = 'X'
    WHERE forecast_id = p_forecast_id;
  END IF;

  If (p_display_debug = 'Y') then
  cep_standard.enable_debug(p_debug_path,
			    p_debug_file);
  end if;
  cep_standard.debug('>>CE_CASH_FCST.Forecast');

  IF (p_start_project_num IS NULL AND
      p_end_project_num IS NULL) THEN
    set_parameters(	p_forecast_header_id,
			p_forecast_runname,
			NULL,
			p_calendar_name,
			p_forecast_start_period,
			p_forecast_currency,
			p_exchange_type,
			p_exchange_date,
			p_exchange_rate,
			p_src_curr_type,
			p_src_currency,
			p_amount_threshold,
			NULL,
			p_rownum_from,
			p_rownum_to,
			p_sub_request,
			p_factor,
			p_include_sub_account,
			p_view_by,
			p_bank_balance_type,
			p_float_type,
			p_forecast_id,
			p_display_debug,
			p_debug_path,
			p_debug_file);
    create_forecast;
  ELSE
    FOR fpid_rec IN C_fpid LOOP
      set_parameters(	p_forecast_header_id,
			p_forecast_runname || '-' || fpid_rec.segment1,
			NULL,
			p_calendar_name,
			p_forecast_start_period,
			p_forecast_currency,
			p_exchange_type,
			p_exchange_date,
			p_exchange_rate,
			p_src_curr_type,
			p_src_currency,
			p_amount_threshold,
			fpid_rec.project_id,
			p_rownum_from,
			p_rownum_to,
			p_sub_request,
			p_factor,
			p_include_sub_account,
			p_view_by,
			p_bank_balance_type,
			p_float_type,
			p_forecast_id,
			p_display_debug,
			p_debug_path,
			p_debug_file);
      create_forecast;
    END LOOP;
  IF (p_display_debug = 'Y') THEN
    cep_standard.disable_debug(p_display_debug);
  END IF;
  END IF;

END Forecast;



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
		p_factor		IN NUMBER,
		p_start_project_num	IN VARCHAR2,
                p_end_project_num	IN VARCHAR2,
		p_calendar_name		IN VARCHAR2,
		p_forecast_start_date	IN VARCHAR2,
		p_forecast_currency	IN VARCHAR2,
		p_src_curr_type		IN VARCHAR2,
		p_src_curr_dummy	in varchar2,
		p_src_currency		IN VARCHAR2,
		p_exchange_date		IN VARCHAR2,
		p_exchange_type		IN VARCHAR2,
		p_exchange_rate		IN NUMBER,
		p_rownum_from		IN NUMBER,
		p_rownum_to		IN NUMBER,
		p_amount_threshold_x	IN VARCHAR2,
		p_sub_request		IN VARCHAR2,
		p_view_by		IN VARCHAR2,
		p_view_dummy		IN VARCHAR2,
		p_bank_balance_type	IN VARCHAR2,
		p_float_type		IN VARCHAR2,
		p_include_sub_account	IN VARCHAR2,
		p_forecast_id		IN NUMBER,
		p_display_debug		IN VARCHAR2,
		p_debug_path		IN VARCHAR2,
		p_debug_file 		IN VARCHAR2,
		p_fc_name_exists	IN VARCHAR2) IS
 CURSOR C_fpid IS
   SELECT 	project_id, segment1
   FROM		pa_projects_all
   WHERE	segment1 >= p_start_project_num
     AND	segment1 <= p_end_project_num;
  error_msg     	FND_NEW_MESSAGES.message_text%TYPE;
  p_amount_threshold	NUMBER;
BEGIN
 -- populate ce_security_profiles_gt table with ce_security_procfiles_v
 CEP_STANDARD.init_security;

  -- Now the process is officially 'Running' and not 'Pending'
  --  --bug 4345353 convert amount threshold from canonical to number
  p_amount_threshold := fnd_number.canonical_to_number(p_amount_threshold_x);

  UPDATE ce_forecasts
  SET error_status = 'R'
  WHERE forecast_id = p_forecast_id
  AND error_status = 'P';
  commit;

  IF (p_fc_name_exists = 'Y') THEN
    FND_MESSAGE.set_name ('CE','CE_FC_DUPLICATE_FORECAST_NAME');
    error_msg := FND_MESSAGE.GET;
    CE_FORECAST_ERRORS_PKG.insert_row(p_forecast_id,p_forecast_header_id,
		null,'CE_FC_DUPLICATE_FORECAST_NAME', error_msg);
    UPDATE ce_forecasts
    SET error_status = 'X'
    WHERE forecast_id = p_forecast_id;
  END IF;

  If (p_display_debug = 'Y') then
  	cep_standard.enable_debug(p_debug_path,
				  p_debug_file);
  end if;
  G_start_project_no := p_start_project_num;
  G_end_project_no   := p_end_project_num;

  IF (p_start_project_num IS NULL AND
      p_end_project_num IS NULL) THEN
    set_parameters(	p_forecast_header_id,
			p_forecast_runname,
			p_forecast_start_date,
			p_calendar_name,
			NULL,
			p_forecast_currency,
			p_exchange_type,
			p_exchange_date,
			p_exchange_rate,
			p_src_curr_type,
			p_src_currency,
			p_amount_threshold,
			NULL,
			p_rownum_from,
			p_rownum_to,
			p_sub_request,
			p_factor,
			p_include_sub_account,
			p_view_by,
			p_bank_balance_type,
			p_float_type,
			p_forecast_id,
			p_display_debug,
			p_debug_path,
			p_debug_file);
    create_forecast;
  ELSE
    FOR fpid_rec IN C_fpid LOOP
      set_parameters(	p_forecast_header_id,
			p_forecast_runname || '-' || fpid_rec.segment1,
			p_forecast_start_date,
			p_calendar_name,
			NULL,
			p_forecast_currency,
			p_exchange_type,
			p_exchange_date,
			p_exchange_rate,
			p_src_curr_type,
			p_src_currency,
			p_amount_threshold,
			fpid_rec.project_id,
			p_rownum_from,
			p_rownum_to,
			p_sub_request,
			p_factor,
			p_include_sub_account,
			p_view_by,
			p_bank_balance_type,
			p_float_type,
			p_forecast_id,
			p_display_debug,
			p_debug_path,
			p_debug_file);
      create_forecast;
    END LOOP;
  END IF;
  IF (p_display_debug = 'Y') THEN
    cep_standard.disable_debug(p_display_debug);
  END IF;
END Forecast;




END CE_CASH_FCST;

/

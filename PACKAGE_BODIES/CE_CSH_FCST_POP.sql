--------------------------------------------------------
--  DDL for Package Body CE_CSH_FCST_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CSH_FCST_POP" AS
/* $Header: cefpcelb.pls 120.69.12010000.5 2010/02/24 07:31:33 talapati ship $ 	*/

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.69.12010000.5 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Get Average Payment Days                                        |
|                                                                       |
|  DESCRIPTION                                                          |
|       Calculates average payment days                                 |
|  CALLED BY                                                            |
|       Build_XXX_Query                                                 |
|  REQUIRES                                                             |
|       customer_id, site_use_id, currency_code, period                 |
|  HISTORY                                                              |
|       01-FEB-2001     Created                                         |
 --------------------------------------------------------------------- */
FUNCTION Get_Average_Payment_Days (X_customer_id 	Number,
				   X_site_use_id	Number,
				   X_currency_code	VARCHAR2,
			 	   X_period		NUMBER ) RETURN NUMBER IS
   l_ave_pay_days	NUMBER;
BEGIN
    SELECT  	decode(count(ar_receivable_applications.apply_date), 0, 0,
                      	   round(sum(ar_receivable_applications.apply_date -
                      	   ar_payment_schedules.trx_date) /
                      	   count(ar_receivable_applications.apply_date)))
    INTO        l_ave_pay_days
    FROM    	ar_receivable_applications_all  	ar_receivable_applications,
		ar_payment_schedules_all 	ar_payment_schedules
    WHERE   	ar_receivable_applications.applied_payment_schedule_id =
						ar_payment_schedules.payment_schedule_id
    AND     	ar_payment_schedules.customer_id = X_customer_id
    AND     	ar_payment_schedules.customer_site_use_id = X_site_use_id
    AND     	ar_payment_schedules.invoice_currency_code = X_currency_code
    AND     	ar_receivable_applications.apply_date between
						add_months(sysdate, - X_period) and sysdate
    AND     	ar_receivable_applications.status = 'APP'
    AND     	ar_receivable_applications.display = 'Y'
    AND     	NVL(ar_payment_schedules.receipt_confirmed_flag,'Y') = 'Y';

    RETURN l_ave_pay_days;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
                cep_standard.debug('NO DATA FOUND FOR AVERAGE PAYMENT DAYS');
                return null;
    WHEN OTHERS THEN
                cep_standard.debug('EXCEPTION-OTHERS Get_Average_Payment_Days');
                raise;
END Get_Average_Payment_Days;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	 Set_History							|
|									|
|  DESCRIPTION								|
|	With AP payments and AR receipts if the forecast method is	|
|	'P'ast then we need to set the history date or period		|
|									|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Set_History IS
  CURSOR cCol IS SELECT forecast_column_id, column_number, days_from, days_to
                 FROM   ce_forecast_columns
                 WHERE  forecast_header_id = CE_CASH_FCST.G_rp_forecast_header_id;

  error_msg     FND_NEW_MESSAGES.message_text%TYPE;

  min_col		NUMBER;
  max_col		NUMBER;
  col_num      	 	NUMBER;
  cid          		NUMBER;
  days_from    	 	NUMBER;
  days_to      		NUMBER;
  history_date 		DATE;
  history_period 	VARCHAR2(30);
BEGIN
  cep_standard.debug('>>CE_CASH_FCST.Set_History');

  cep_standard.debug('G_roll_forward_type: '   	|| CE_CASH_FCST.G_roll_forward_type);
  cep_standard.debug('G_roll_forward_period : ' || CE_CASH_FCST.G_roll_forward_period);
  cep_standard.debug('G_start_period: ' 	|| CE_CASH_FCST.G_rp_forecast_start_period);
  cep_standard.debug('period_set_name: ' 	|| CEFC_VIEW_CONST.get_period_set_name);

  IF (CE_CASH_FCST.G_roll_forward_type = 'D') THEN
    CEFC_VIEW_CONST.set_start_date(CE_CASH_FCST.G_rp_forecast_start_date - CE_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_min_col(nvl(CE_CASH_FCST.G_min_col,0) + CE_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_max_col(nvl(CE_CASH_FCST.G_max_col,0) + CE_CASH_FCST.G_roll_forward_period);

  ELSIF (CE_CASH_FCST.G_roll_forward_type = 'M') THEN
    history_date:= ADD_MONTHS(CE_CASH_FCST.G_rp_forecast_start_date,- CE_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_start_date(history_date);
    CEFC_VIEW_CONST.set_min_col(nvl(CE_CASH_FCST.G_min_col,0) + CE_CASH_FCST.G_roll_forward_period*30);
    CEFC_VIEW_CONST.set_max_col(nvl(CE_CASH_FCST.G_max_col,0) + CE_CASH_FCST.G_roll_forward_period*30);

  ELSIF (CE_CASH_FCST.G_roll_forward_type = 'A') THEN
    BEGIN
      SELECT	gps.period_name
      INTO	history_period
      FROM	gl_periods gps,
		gl_periods gp,
		gl_period_types gpt
      WHERE	gps.period_num =DECODE(LEAST(gp.period_num-CE_CASH_FCST.G_roll_forward_period,1),
			1,gp.period_num - CE_CASH_FCST.G_roll_forward_period,
			gpt.number_per_fiscal_year +
			  mod(gp.period_num-CE_CASH_FCST.G_roll_forward_period,gpt.number_per_fiscal_year))
      AND	gps.period_year = gp.period_year +
			DECODE(LEAST(gp.period_num-CE_CASH_FCST.G_roll_forward_period,1),1,0,
		  DECODE(mod(gp.period_num-CE_CASH_FCST.G_roll_forward_period,gpt.number_per_fiscal_year),0,
			FLOOR((gp.period_num -CE_CASH_FCST.G_roll_forward_period)/gpt.number_per_fiscal_year)-1,
			FLOOR((gp.period_num -CE_CASH_FCST.G_roll_forward_period)/gpt.number_per_fiscal_year)))
      AND	gp.period_set_name 	= gps.period_set_name
      AND	gps.period_type 	= gp.period_type
      AND	gpt.period_type 	= gp.period_type
      AND	gp.period_name 		= CE_CASH_FCST.G_rp_forecast_start_period
      AND	gp.period_set_name 	= CEFC_VIEW_CONST.get_period_set_name;

      CEFC_VIEW_CONST.set_start_period_name(history_period);
      CEFC_VIEW_CONST.set_min_col(nvl(CE_CASH_FCST.G_min_col,0) + CE_CASH_FCST.G_roll_forward_period);
      CEFC_VIEW_CONST.set_max_col(nvl(CE_CASH_FCST.G_max_col,0) + CE_CASH_FCST.G_roll_forward_period);
    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
		cep_standard.debug('NO DATA FOUND FOR HISTORY PERIOD');
		RAISE;
    	WHEN OTHERS THEN
		cep_standard.debug('EXCEPTION-OTHERS Set_History');
		raise;
    END;
  END IF;

  min_col := CEFC_VIEW_CONST.get_min_col;
  max_col := CEFC_VIEW_CONST.get_max_col;
  CE_CASH_FCST.G_invalid_overdue_row := FALSE;

  OPEN cCol;
  FETCH cCol INTO cid, col_num, days_from, days_to;
  LOOP
    EXIT WHEN cCol%NOTFOUND OR cCol%NOTFOUND IS NULL;

    IF( days_from < min_col OR
        days_from > max_col  OR
        days_to   < min_col OR
        days_to   > max_col) THEN

      FND_MESSAGE.set_name ('CE','CE_FC_COLUMN_NOT_IN_RANGE');
      FND_MESSAGE.set_token('COLUMN', col_num);
      error_msg := FND_MESSAGE.GET;
      CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id,CE_CASH_FCST.G_rp_forecast_header_id,
                                          CE_CASH_FCST.G_forecast_row_id,'CE_FC_COLUMN_NOT_IN_RANGE', error_msg);
    END IF;

    IF( col_num = 0 AND days_to < min_col ) THEN
      CE_CASH_FCST.G_invalid_overdue_row := TRUE;
    END IF;

    FETCH cCol INTO cid, col_num, days_from, days_to;
  END LOOP;

  cep_standard.debug('<<CE_CASH_FCST.Set_History');
EXCEPTION
  WHEN OTHERS THEN
        IF(cCol%ISOPEN)THEN CLOSE cCol; END IF;
        RAISE;
END Set_History;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_aging_buckets						|
|									|
|  DESCRIPTION								|
|	Return real aging buckets by considering the transaction 	|
|	calendar into account			 			|
|  CALLED BY								|
|	execute_main_query						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	04-AUG-1997	Created		Wynne Chan			|
 --------------------------------------------------------------------- */
PROCEDURE populate_aging_buckets IS
  CURSOR C1 IS 	select 	forecast_column_id, to_date(start_date,'J'), to_date(end_date,'J')
		from 	ce_fc_aging_buckets_v;
  start_date		DATE;
  end_date		DATE;
  new_start_date	DATE;
  new_end_date		DATE;
  fid			NUMBER;
BEGIN
  cep_standard.debug('>>ce_csh_fcST_POP.populate_aging_buckets');

  OPEN C1;
  FETCH C1 INTO fid, start_date, end_date;
  LOOP
    EXIT WHEN C1%NOTFOUND OR C1%NOTFOUND IS NULL;

    new_start_date := NULL;
    new_end_date := NULL;

    IF(CE_CASH_FCST.G_transaction_calendar_id IS NOT NULL)THEN
      IF(start_date <= G_calendar_start OR
         start_date-1 > G_calendar_end) THEN
 	new_start_date := start_date;
      ELSE
 	BEGIN
          select 	max(transaction_date)+1
          into		new_start_date
          from		gl_transaction_dates
          where		transaction_calendar_id = CE_CASH_FCST.G_transaction_calendar_id
          and		transaction_date < start_date
          and 		business_day_flag = 'Y';

	  IF (new_start_date IS NULL) THEN
	    new_start_date := G_calendar_start;
	  END IF;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		-- case where all days between G_calendar_start and start_date are non-workdays.
		new_start_date := G_calendar_start;
	END;
      END IF;

      IF(end_date < G_calendar_start OR
         end_date > G_calendar_end) THEN
 	new_end_date := end_date;
      ELSE
	BEGIN
          select	max(transaction_date)
          into		new_end_date
          from		gl_transaction_dates
          where		transaction_calendar_id = CE_CASH_FCST.G_transaction_calendar_id
          and		transaction_date <= end_date
          and		business_day_flag = 'Y';

	  IF (new_end_date IS NULL) THEN
	    new_end_date := G_calendar_start -1;
	  END IF;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		-- case where all days between end_date and G_calendar_start and non-workdays.
		new_end_date := G_calendar_start -1;
	END;
      END IF;
    ELSE
      new_start_date := start_date;
      new_end_date := end_date;
    END IF;

-- Bug # 1927006
  new_start_date := trunc(new_start_date);
  new_end_date := to_date(to_char(new_end_date, 'DD-MM-RR') || ' 23:59:59', 'DD-MM-RR HH24:MI:SS');

    INSERT INTO CE_FORECAST_EXT_TEMP (context_value, forecast_request_id, start_date, end_date,
					forecast_column_id, conversion_rate)
          VALUES ('A', CE_CASH_FCST.G_forecast_id, new_start_date, new_end_date, fid, CE_CASH_FCST.G_forecast_row_id);

    FETCH C1 INTO fid, start_date, end_date;
  END LOOP;
  CLOSE C1;

  cep_standard.debug('<<ce_csh_fcST_POP.populate_aging_buckets');
EXCEPTION
  WHEN OTHERS THEN
	IF C1%ISOPEN THEN CLOSE C1; END IF;
	CEP_STANDARD.DEBUG('EXCEPTION:populate_aging_buckets');
	raise;
END populate_aging_buckets;

PROCEDURE clear_aging_buckets IS
BEGIN
  delete from ce_forecast_ext_temp
  where	 context_value = 'A' and
         forecast_request_id = CE_CASH_FCST.G_forecast_id and
	 conversion_rate = CE_CASH_FCST.G_forecast_row_id;
  cep_standard.debug('<<ce_csh_fcST_POP.clear_aging_buckets');
EXCEPTION
  WHEN OTHERS THEN
	CEP_STANDARD.DEBUG('EXCEPTION:clear_aging_buckets');
	raise;
END clear_aging_buckets;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Get Select Clause						|
|									|
|  DESCRIPTION								|
|	Builds Select clause and returns it to calling procedure	|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_Select_Clause RETURN VARCHAR2 IS
  select_clause VARCHAR2(1500);
  amount_string VARCHAR2(20);
  trx_amount_string VARCHAR2(20);
  clause_string VARCHAR2(200);
BEGIN
  amount_string := 'nvl(src.amount,0)*';
  trx_amount_string := 'src.amount';
  IF (CE_CASH_FCST.G_trx_type IN ('API','APP','APX','OIO','PAY','POP',
		'POR','PAT','PAO','UDO')) THEN
    amount_string := 'nvl(-src.amount,0)*';
  trx_amount_string := '-src.amount';
  END IF;

  IF (CE_CASH_FCST.G_trx_type IN ('APP','ARR','PAY','XTI','XTO')) THEN
    IF(CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
      clause_string := 'src.bank_account_id,
		ccid.asset_code_combination_id,
		round('||amount_string
			||CE_CASH_FCST.G_rp_exchange_rate
			||','
			||CE_CASH_FCST.G_precision||')';
    ELSE
      clause_string := 'src.bank_account_id,
		ccid.asset_code_combination_id,
  		round('||amount_string||'curr.exchange_rate,'
			||CE_CASH_FCST.G_precision||')';
    END IF;
  ELSE
    IF(CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
      clause_string := 'null,
		null,
		round('||amount_string
			||CE_CASH_FCST.G_rp_exchange_rate
			||','
			||CE_CASH_FCST.G_precision||')';
    ELSE
      clause_string := 'null,
		null,
  		round('||amount_string||'curr.exchange_rate,'
			||CE_CASH_FCST.G_precision||')';
    END IF;
  END IF;

-- 5609517: Remove ORDERED hint as suggested by apps perf team
-- select_clause := '
--	SELECT 	/*+ ORDERED USE_MERGE(src)*/
  select_clause := '
	SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.trx_date +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		'||clause_string||',
		'||trx_amount_string;

  return select_clause;
END Get_Select_Clause;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Get From Clause							|
|									|
|  DESCRIPTION								|
|	Builds From clause and returns it to calling procedure		|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|	trx view name							|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_From_Clause (view_name VARCHAR2) RETURN VARCHAR2 IS
  from_clause VARCHAR2(500);
BEGIN
  from_clause := '
	FROM	'||view_name ||' src,
		ce_forecast_ext_temp cab ';

  IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
      CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
    from_clause := from_clause || ' ,
		ce_currency_rates_temp curr ';
  END IF;

  IF (CE_CASH_FCST.G_trx_type IN ('APP','ARR','PAY','XTI','XTO','XTR')) THEN
    from_clause := from_clause || ' ,
    ce_gl_accounts_ccid ccid, ce_bank_acct_uses_all bau, ce_bank_accounts ba';
  END IF;

  IF (CE_CASH_FCST.G_trx_type not in ('XTI','XTO','XTR')) THEN
    from_clause := from_clause || ' ,
		hr_organization_information o3'||',
		hr_organization_information hr_ou';
  END IF;

  IF(CE_CASH_FCST.G_rp_src_curr_type = 'F')THEN
    IF(CE_CASH_FCST.G_app_short_name = 'AP')THEN
      from_clause := from_clause || ' ,
		ce_forecast_ap_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'AR')THEN
      from_clause := from_clause || ' ,
		ce_forecast_ar_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'AS')THEN
      from_clause := from_clause || ' ,
		ce_forecast_as_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'PAY')THEN
      from_clause := from_clause || ' ,
		ce_forecast_pay_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'PO')THEN
      from_clause := from_clause || ' ,
		ce_forecast_po_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'OE')THEN
      from_clause := from_clause || ' ,
		ce_forecast_oe_orgs_v org ';
    ELSIF(CE_CASH_FCST.G_app_short_name = 'XTR')THEN
      from_clause := from_clause || ' ,
		gl_sets_of_books org ';
    END IF;
  END IF;

  --
  -- Special case for OE, need to join to ce_currency_rates_temp to figure out
  -- the functional value of the transaction amount
  --
  IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL AND
     CE_CASH_FCST.G_rp_src_curr_type = 'F' AND
     CE_CASH_FCST.G_trx_type IN ('OEO','XTR'))THEN
    from_clause := from_clause || ' ,
		ce_currency_rates_temp curr2 ';
  END IF;

  cep_standard.debug(from_clause);
  return from_clause;
END Get_From_Clause;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Add_Where							|
|  DESCRIPTION								|
|	Builds additional where clause for criteria if criteria 	|
|	contains certain value						|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	31-JUL-1997	Created		Wynen Chan			|
 --------------------------------------------------------------------- */
FUNCTION Add_Where(criteria VARCHAR2) RETURN VARCHAR2 IS
l_pay_group VARCHAR2(25);
BEGIN
  IF(criteria = 'SRC_CURR_TYPE')THEN
    IF(CE_CASH_FCST.G_rp_src_curr_type = 'E')THEN
      return ('
	AND 	src.currency_code  = '''||CE_CASH_FCST.G_rp_src_currency||''' ');
    ELSIF(CE_CASH_FCST.G_rp_src_curr_type  = 'F')THEN
      IF(CE_CASH_FCST.G_app_short_name = 'PA')THEN
        return ('
	  AND 	src.functional_currency_code  = '''||CE_CASH_FCST.G_rp_src_currency||''' ');
      ELSIF(CE_CASH_FCST.G_app_short_name = 'XTR')THEN
        return ('
	  AND 	org.currency_code  = '''||CE_CASH_FCST.G_rp_src_currency||'''
	  AND	(org.set_of_books_id 	   = src.set_of_books_id or org.set_of_books_id IS NULL) ');
      ELSE
        return ('
	  AND 	org.currency_code  = '''||CE_CASH_FCST.G_rp_src_currency||'''
	  AND	(org.org_id 	   = src.org_id or org.org_id IS NULL) ');
      END IF;
    END IF;

  ELSIF(criteria = 'EXCHANGE_TYPE')THEN
    IF(CE_CASH_FCST.G_rp_exchange_type IS NULL OR
       CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
      return ('
	AND     curr.forecast_request_id 	= cab.forecast_request_id
	AND	curr.to_currency		= '''||CE_CASH_FCST.G_rp_forecast_currency||'''
       	AND     curr.currency_code      	= src.currency_code ');
    END IF;

  ELSIF(criteria = 'VENDOR_TYPE')THEN
    IF(CE_CASH_FCST.G_vendor_type IS NOT NULL)THEN
      return ('
	AND 	src.vendor_type = '''||CE_CASH_FCST.G_vendor_type||''' ');
    END IF;

  ELSIF(criteria = 'PAY_GROUP')THEN
    IF(CE_CASH_FCST.G_pay_group IS NOT NULL)THEN
      l_pay_group := replace(CE_CASH_FCST.G_pay_group, '''', '''''');
      return ('
	AND 	src.paygroup = '''||l_pay_group||''' ');
    END IF;

  ELSIF(criteria = 'PAYMENT_PRIORITY')THEN
    IF(CE_CASH_FCST.G_payment_priority IS NOT NULL)THEN
      return ('
	AND 	src.payment_priority <= '||to_char(CE_CASH_FCST.G_payment_priority));
    END IF;

  ELSIF(criteria = 'BANK_ACCOUNT_ID')THEN
    IF(CE_CASH_FCST.G_bank_account_id IS NOT NULL)THEN
      return ('
	AND 	src.bank_account_id = '||TO_CHAR(CE_CASH_FCST.G_bank_account_id));
    END IF;

  ELSIF(criteria = 'RECEIPT_METHOD_ID')THEN
    IF(CE_CASH_FCST.G_receipt_method_id IS NOT NULL)THEN
      return ('
	AND 	src.receipt_method_id = '||TO_CHAR(CE_CASH_FCST.G_receipt_method_id));
    END IF;

  ELSIF(criteria = 'CUSTOMER_PROFILE_CLASS_ID')THEN
    IF(CE_CASH_FCST.G_customer_profile_class_id IS NOT NULL)THEN
      return ('
	AND 	src.profile_class_id = '||to_char(CE_CASH_FCST.G_customer_profile_class_id));
    END IF;

  ELSIF(criteria = 'AUTHORIZATION_STATUS')THEN
    IF(CE_CASH_FCST.G_authorization_status IS NOT NULL)THEN
      return ('
	AND 	src.status = '''||CE_CASH_FCST.G_authorization_status ||''' ');
    END IF;

  ELSIF(criteria = 'PAYMENT_METHOD')THEN
    IF(CE_CASH_FCST.G_payment_method IS NOT NULL)THEN
      return ('
	AND     src.payment_method = '''||CE_CASH_FCST.G_payment_method||''' ');
    END IF;

  ELSIF(criteria = 'ORG_PAYMENT_METHOD_ID')THEN
    IF(CE_CASH_FCST.G_org_payment_method_id IS NOT NULL)THEN
      return ('
	AND 	src.org_payment_method_id = '||to_char(CE_CASH_FCST.G_org_payment_method_id));
    END IF;

  ELSIF(criteria = 'PAYROLL_ID')THEN
    IF( CE_CASH_FCST.G_payroll_id IS NOT NULL )THEN
      return ('
	AND 	src.payroll_id = '||to_char(CE_CASH_FCST.G_payroll_id));
    END IF;

  ELSIF(criteria = 'CHANNEL_CODE')THEN
    IF( CE_CASH_FCST.G_channel_code IS NOT NULL )THEN
      return ('
	AND 	src.channel_code = '''||CE_CASH_FCST.G_channel_code||''' ');
    END IF;

  ELSIF(criteria = 'SALES_STAGE_ID')THEN
    IF( CE_CASH_FCST.G_sales_stage_id IS NOT NULL )THEN
      return ('
	AND 	src.sales_stage_id = '||to_char(CE_CASH_FCST.G_sales_stage_id));
    END IF;

  ELSIF(criteria = 'SALES_FORECAST_STATUS')THEN
    IF( CE_CASH_FCST.G_sales_forecast_status IS NOT NULL )THEN
      return ('
	AND 	src.status_code = '''|| CE_CASH_FCST.G_sales_forecast_status ||''' ');
    END IF;

  ELSIF(criteria = 'PROJECT_ID')THEN
    IF( CE_CASH_FCST.G_rp_project_id IS NOT NULL )THEN
      return ('
	AND 	src.project_id = '||to_char(CE_CASH_FCST.G_rp_project_id));
    END IF;

  ELSIF(criteria = 'TYPE')THEN
    IF( CE_CASH_FCST.G_type IS NOT NULL )THEN
      return ('
	AND 	src.type = '''|| CE_CASH_FCST.G_type ||''' ');
    END IF;

  ELSIF(criteria = 'BUDGET_TYPE')THEN
    IF( CE_CASH_FCST.G_budget_type IS NOT NULL )THEN
      return ('
	AND 	src.budget_type = '''|| CE_CASH_FCST.G_budget_type ||''' ');
    END IF;

  ELSIF(criteria = 'BUDGET_VERSION')THEN
    IF( CE_CASH_FCST.G_budget_version IS NOT NULL )THEN
      return ('
	AND 	src.version = '''|| CE_CASH_FCST.G_budget_version ||''' ');
    END IF;

  ELSIF(criteria = 'INCLUDE_HOLD_FLAG')THEN
    IF( CE_CASH_FCST.G_include_hold_flag <> 'Y' ) THEN
      return ('
	AND 	src.on_hold = '''||CE_CASH_FCST.G_include_hold_flag ||''' ');
    END IF;
  ELSIF(criteria = 'EXCLUDE_INDIC_EXP')THEN
    IF( CE_CASH_FCST.G_exclude_indic_exp = 'Y' )THEN
      return ('
	AND 	src.dda_deal_subtype <> ''INDIC'' ');
    END IF;

  ELSIF(criteria = 'XTR_BANK_ACCOUNT')THEN
    IF( CE_CASH_FCST.G_xtr_bank_account IS NOT NULL )THEN
      return ('
	AND 	src.company_account = '''|| CE_CASH_FCST.G_xtr_bank_account ||''' ');
    END IF;

  ELSIF(criteria = 'XTR_TYPE')THEN
    IF( CE_CASH_FCST.G_type IS NOT NULL )THEN
      return ('
	AND 	src.category = '''|| CE_CASH_FCST.G_type ||''' ');
    END IF;

  ELSIF(criteria = 'ORDER_TYPE_ID')THEN
    IF(CE_CASH_FCST.G_order_type_id IS NOT NULL)THEN
      return ('
        AND     src.order_type_id = '||to_char(CE_CASH_FCST.G_order_type_id));
    END IF;

  ELSE
    cep_standard.debug('ERROR - Add_Where got invalid criteria!');
  END IF;

  return (NULL);
END Add_Where;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Get Where Clause						|
|									|
|  DESCRIPTION								|
|	Builds where clause and returns it to calling procedure		|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_Where_Clause RETURN VARCHAR2 IS
  where_clause VARCHAR2(1500);

BEGIN
  cep_standard.debug('>>CE_CASH_FCST.Get_Where_Clause');

  where_clause := '
	WHERE	cab.context_value = ''A''
	AND	cab.forecast_request_id = '||to_char(CE_CASH_FCST.G_forecast_id) ||'
	AND	cab.conversion_rate = '||to_char(CE_CASH_FCST.G_forecast_row_id) ||
	Add_Where('EXCHANGE_TYPE') || Add_Where('SRC_CURR_TYPE');

  IF (CE_CASH_FCST.G_trx_type IN ('APP','ARR','PAY','XTI','XTO')) THEN
  --bug5702686, Added line 'AND bau.org_id = src.org_id'
   where_clause := where_clause ||'
	AND ba.bank_account_id(+) = src.bank_account_id
        AND bau.bank_account_id(+) = ba.bank_account_id
	AND (bau.org_id = src.org_id or bau.LEGAL_ENTITY_ID = src.org_id)'||'
        AND ccid.bank_acct_use_id(+) = bau.bank_acct_use_id';
-- for bug 6343915  modified line ' AND (bau.org_id = src.org_id or bau.LEGAL_ENTITY_ID = src.org_id)'
--bug5358376
   IF (CE_CASH_FCST.G_trx_type = 'APP') THEN
	where_clause := where_clause ||'
		AND bau.ap_use_enable_flag = ''Y''';
   ELSIF (CE_CASH_FCST.G_trx_type = 'ARR') THEN
	where_clause := where_clause ||'
		AND bau.ar_use_enable_flag = ''Y''';
   ELSIF (CE_CASH_FCST.G_trx_type = 'PAY') THEN
	where_clause := where_clause ||'
		AND bau.pay_use_enable_flag = ''Y''';
   ELSE
	where_clause := where_clause ||'
		AND bau.xtr_use_enable_flag = ''Y''';
   END IF;
--bug5358376
  END IF;

  IF (CE_CASH_FCST.G_trx_type not in ('XTI','XTO','XTR')) THEN
    IF (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) THEN
      where_clause := where_clause ||'
	AND (hr_ou.organization_id = src.org_id)'||'
	AND hr_ou.ORG_INFORMATION_CONTEXT||'''' = ''CLASS'''||'
	AND hr_ou.ORG_INFORMATION1 = ''OPERATING_UNIT'''||'
	AND o3.organization_id = hr_ou.organization_id'||'
	AND o3.ORG_INFORMATION_CONTEXT = ''Operating Unit Information'''||'
	AND hr_ou.ORG_INFORMATION2 = ''Y''';
    ELSE
      where_clause := where_clause ||'
	AND ((hr_ou.organization_id = src.org_id) OR (src.org_id is null))'||'
        AND hr_ou.ORG_INFORMATION_CONTEXT||'''' = ''CLASS'''||'
        AND hr_ou.ORG_INFORMATION1 = ''OPERATING_UNIT'''||'
	AND o3.organization_id = hr_ou.organization_id'||'
	AND o3.ORG_INFORMATION_CONTEXT = ''Operating Unit Information'''||'
        AND hr_ou.ORG_INFORMATION2 = ''Y''';
    END IF;
  END IF;

  IF( CE_CASH_FCST.G_app_short_name = 'XTR' ) THEN
    IF( CE_CASH_FCST.G_company_code IS NOT NULL )THEN
      where_clause := where_clause ||'
	  AND 	(src.company_code = '''|| CE_CASH_FCST.G_company_code ||''') ';
    ELSIF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
          CE_CASH_FCST.G_set_of_books_id <> -1) THEN
      where_clause := where_clause ||'
	AND 	(src.set_of_books_id IN (SELECT DISTINCT(set_of_books_id)
				FROM GL_SETS_OF_BOOKS
				WHERE set_of_books_id = '||to_char(CE_CASH_FCST.G_set_of_books_id)||' )) ';
    END IF;
  ELSE
    IF( CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99 )THEN
      where_clause := where_clause ||'
	  AND 	(src.org_id = '||to_char( CE_CASH_FCST.G_org_id)||' OR src.org_id IS NULL) ';
    ELSIF ( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
          CE_CASH_FCST.G_set_of_books_id <> -1) THEN
      where_clause := where_clause ||'
	AND 	(src.org_id IS NULL OR src.org_id IN (SELECT DISTINCT(org_id)
				FROM CE_FORECAST_ORGS_V
				WHERE set_of_books_id = '||to_char(CE_CASH_FCST.G_set_of_books_id)||' )) ';
    END IF;
  END IF;

  IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
    IF(CE_CASH_FCST.G_rp_src_curr_type = 'E')THEN
      where_clause := where_clause || '
	AND	abs(nvl(src.amount,0)) > ' ||to_char(fnd_number.number_to_canonical(CE_CASH_FCST.G_rp_amount_threshold));
    ELSIF(CE_CASH_FCST.G_rp_src_curr_type = 'F')THEN
      --
      -- Special case for OE, need to join to ce_currency_rates_temp to figure out
      -- the functional value of the transaction amount
      --
	-- bug4345353 added the function fnd_number.number_to_canonical
      IF(CE_CASH_FCST.G_trx_type <> 'OEO')THEN
        IF(CE_CASH_FCST.G_trx_type = 'XTR')THEN
	  where_clause := where_clause || '
	    AND	  abs(nvl(src.amount,0)*curr2.exchange_rate) > ' ||to_char(fnd_number.number_to_canonical(CE_CASH_FCST.G_rp_amount_threshold)) ||'
	    AND	  curr2.currency_code = src.currency_code
	    AND	  curr2.to_currency = org.currency_code
	    AND	  org.set_of_books_id = src.set_of_books_id
	    AND	  curr2.forecast_request_id = '||to_char(CE_CASH_FCST.G_forecast_id);
        ELSE
	-- bug4345353 added the function fnd_number.number_to_canonical
          where_clause := where_clause || '
            AND   abs(src.base_amount) > ' ||to_char(fnd_number.number_to_canonical(CE_CASH_FCST.G_rp_amount_threshold));
	END IF;
      ELSE
	-- bug4345353 added the function fnd_number.number_to_canonical
	where_clause := where_clause || '
	  AND	abs(nvl(src.amount,0)*curr2.exchange_rate) > ' ||to_char(fnd_number.number_to_canonical(CE_CASH_FCST.G_rp_amount_threshold)) ||'
	  AND	curr2.currency_code = src.currency_code
	  AND	curr2.to_currency = org.currency_code
	  AND	org.org_id = src.org_id
	  AND	curr2.forecast_request_id = '||to_char(CE_CASH_FCST.G_forecast_id);
      END IF;
    END IF;
  END IF;

  cep_standard.debug('<<CE_CASH_FCST.Get_Where_Clause');
  return where_clause;
END Get_Where_Clause;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Insert_Fcast_Cell						|
|									|
|  DESCRIPTION								|
|	This procedure inserts a row into the CE_FORECAST_TRX_CELLS 	|
|  CALLED BY								|
|	Build_Remote_Query						|
|  REQUIRES								|
|	forecast_amount, column_id, reference_id, currency_code,	|
|	org_id, trx_date, bank_account_id				|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Insert_Fcast_Cell(	p_reference_id 		VARCHAR2,
				p_currency_code		VARCHAR2,
				p_org_id		NUMBER,
				p_trx_date		DATE,
				p_bank_account_id	NUMBER,
				p_forecast_amount	NUMBER,
				p_trx_amount		NUMBER,
			    	p_forecast_column_id 	NUMBER) IS
  forecast_rowid	 VARCHAR2(30):=NULL;
  forecast_cell_id NUMBER := NULL;
  l_code_combination_id NUMBER := NULL;
BEGIN
  IF (p_bank_account_id is not null) THEN
    SELECT ccid.asset_code_combination_id
    INTO l_code_combination_id
    FROM ce_gl_accounts_ccid ccid, ce_bank_acct_uses_all bau
    WHERE bau.bank_account_id = p_bank_account_id
    and   bau.org_id = p_org_id
    and   ccid.bank_acct_use_id = bau.bank_acct_use_id;
  END IF;

  CE_FORECAST_TRX_CELLS_PKG.insert_row(
		X_rowid			=>forecast_rowid,
		X_FORECAST_CELL_ID	=>forecast_cell_id,
		X_FORECAST_ID		=>CE_CASH_FCST.G_forecast_id,
		X_FORECAST_HEADER_ID	=>CE_CASH_FCST.G_rp_forecast_header_id,
		X_FORECAST_ROW_ID	=>CE_CASH_FCST.G_forecast_row_id,
		X_FORECAST_COLUMN_ID	=>p_forecast_column_id,
		X_AMOUNT		=>round(NVL(p_forecast_amount,0), CE_CASH_FCST.G_precision),
		X_TRX_AMOUNT		=>p_trx_amount,
		X_REFERENCE_ID 		=>p_reference_id,
		X_CURRENCY_CODE   	=>p_currency_code,
		X_ORG_ID		=>p_org_id,
		X_INCLUDE_FLAG		=>'Y',
		X_TRX_DATE		=>p_trx_date,
		X_BANK_ACCOUNT_ID	=>p_bank_account_id,
		X_CODE_COMBINATION_ID	=>l_code_combination_id,
		X_CREATED_BY		=>nvl(fnd_global.user_id,-1),
		X_CREATION_DATE		=>sysdate,
		X_LAST_UPDATED_BY	=>nvl(fnd_global.user_id,-1),
		X_LAST_UPDATE_DATE	=>sysdate,
		X_LAST_UPDATE_LOGIN	=>nvl(fnd_global.user_id,-1));
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS- Insert_Fcast_Cell');
    RAISE;
END Insert_Fcast_Cell;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Zero_Fill_Cells							|
|									|
|  DESCRIPTION								|
|  This procedure inserts a row into the CE_FORECAST_TRX_CELLS table	|
|  for those columns for which the view produces a null row		|
| CALLED BY								|
|	Execute_Main_Query,						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 ---------------------------------------------------------------------*/
PROCEDURE Zero_Fill_Cells IS
  column_id CE_FORECAST_COLUMNS.forecast_column_id%TYPE;

  CURSOR zero_fill_c IS SELECT cfc.forecast_column_id
  			FROM	ce_forecast_columns cfc
  			WHERE	cfc.forecast_header_id = CE_CASH_FCST.G_rp_forecast_header_id;

BEGIN
  cep_standard.debug('>>CE_CASH_FCST_POP.Zero_Fill_Cells');
  OPEN zero_fill_c;
  LOOP
    FETCH zero_fill_c into column_id;
    EXIT WHEN zero_fill_C%NOTFOUND OR zero_fill_C%NOTFOUND IS NULL;
    cep_standard.debug('column_id with zero amount: '|| to_char(column_id));
    Insert_Fcast_Cell(null, null, null, null, null, 0, to_number(null), column_id);
  END LOOP;

  CLOSE zero_fill_c;

  cep_standard.debug('<<CE_CASH_FCST_POP.Zero_Fill_Cells');
EXCEPTION
  WHEN OTHERS THEN
    IF zero_fill_C%ISOPEN THEN close zero_fill_C; END IF;
    cep_standard.debug('EXCEPTION-OTHERS: Zero_fill_Cells');
    RAISE;
END Zero_Fill_Cells;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Execute_Main_Query						|
|									|
|  DESCRIPTION								|
|	This procedure takes in the query string and executes it using	|
|	dynamic sql functionality. The query string is parsed and then	|
|	executed - directly inserts into ce_forecast_trx_cells		|
|	from select statement						|
|  CALLED BY								|
|	Build_XX_Query							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	29-APR-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Execute_Main_Query (main_query 	VARCHAR2) IS
  cursor_id		INTEGER;
  exec_id		INTEGER;
  forecast_cell_id	number;
  forecast_header_id	number;
  forecast_row_id	number;
  forecast_column_id	number;
  reference_id		varchar2(100);
  currency_code         varchar2(15);
  org_id		number;
  trx_date		date;
  bank_account_id 	number;
  forecast_amount	number;
  forecast_id		number;
  forecast_rowid	VARCHAR2(30);
  counter		number;
  final_query		VARCHAR2(5000);
BEGIN
  cep_standard.debug('>>CE_CSH_FCST_POP.Execute_Main_Query');

  populate_aging_buckets;

  cursor_id := DBMS_SQL.open_cursor;
  cep_standard.debug('Cursor opened sucessfully with cursor_id: '||
	to_char(cursor_id));

  cep_standard.debug('Parsing ....');
  final_query := 'INSERT INTO CE_FORECAST_TRX_CELLS(
			FORECAST_CELL_ID,
 			FORECAST_ID,
 			FORECAST_HEADER_ID,
 			FORECAST_ROW_ID,
			INCLUDE_FLAG,
 			CREATED_BY,
 			CREATION_DATE,
 			LAST_UPDATED_BY,
 			LAST_UPDATE_DATE,
 			LAST_UPDATE_LOGIN,
 			FORECAST_COLUMN_ID,
			REFERENCE_ID,
			CURRENCY_CODE,
			ORG_ID,
			TRX_DATE,
			BANK_ACCOUNT_ID,
			CODE_COMBINATION_ID,
 			AMOUNT,
			TRX_AMOUNT)
		' || main_query;
  DBMS_SQL.Parse(cursor_id,
		 final_query,
		 DBMS_SQL.v7);

  cep_standard.debug('Parsed sucessfully');

  exec_id := DBMS_SQL.execute(cursor_id);

  DBMS_SQL.CLOSE_CURSOR(cursor_id);

  IF(CE_CASH_FCST.G_trx_type IN ('GLB', 'GLE', 'GLA', 'PAY')) THEN
    DELETE from  ce_forecast_trx_cells
    WHERE forecast_id = CE_CASH_FCST.G_forecast_id
    AND forecast_row_id = CE_CASH_FCST.G_forecast_row_id
    AND forecast_column_id = CE_CASH_FCST.G_overdue_column_id;
  END IF;

  IF(CE_CASH_FCST.G_trx_type IN ('APP', 'ARR') AND
	CE_CASH_FCST.G_forecast_method = 'P') THEN
    DELETE from ce_forecast_trx_cells
    WHERE forecast_id = CE_CASH_FCST.G_forecast_id
    AND forecast_row_id = CE_CASH_FCST.G_forecast_row_id
    AND forecast_column_id = CE_CASH_FCST.G_overdue_column_id;
  END IF;

  IF(CE_CASH_FCST.G_invalid_overdue_row) THEN
    DELETE from ce_forecast_trx_cells
    WHERE forecast_id = CE_CASH_FCST.G_forecast_id
    AND forecast_row_id = CE_CASH_FCST.G_forecast_row_id
    AND forecast_column_id = CE_CASH_FCST.G_overdue_column_id;
  END IF;

  -- Populate CE_FORECAST_OPENING_BAL
  Populate_Opening_Bal;

  clear_aging_buckets;
  zero_fill_cells;
  EXCEPTION
   WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION - OTHERS: Execute_Main_Query');
	IF DBMS_SQL.IS_OPEN(cursor_id) THEN
	  DBMS_SQL.CLOSE_CURSOR(cursor_id);
	  cep_standard.debug('Cursor Closed');
	END IF;
	RAISE;
END Execute_Main_Query;




 /* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Use_avg_bal_pos							|
|									|
|  DESCRIPTION								|
|	Calculates the initial cash position for the forecast start	|
|	date using the average balance Processing			|
|  CALLED BY								|
|	CE_CASH_FCST_POP.Calc_Initial_Cash_Position		|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-MAR-1997	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Use_Avg_Bal_Pos(p_ccid NUMBER) RETURN NUMBER IS
  l_end_of_day NUMBER;
  l_ptd_range NUMBER;
  l_period_name GL_PERIODS.period_name%TYPE;
BEGIN
  cep_standard.debug('>>CE_CSH_FCST_POP.Use_Avg_Bal_Pos');
  --
  -- Get number of days from start of the period
  --
  BEGIN
	SELECT  period_name,
		(CE_CASH_FCST.G_rp_forecast_start_date - start_date +1)
	INTO	l_period_name,
		l_ptd_range
	FROM  	gl_periods
	WHERE 	CE_CASH_FCST.G_rp_forecast_start_date BETWEEN start_date and end_date
	AND	period_set_name = CE_CASH_FCST.G_rp_calendar_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	return 0;
	cep_standard.debug('Use_Avg_Bal_Pos.no data found');
    WHEN TOO_MANY_ROWS THEN
	return 0;
	cep_standard.debug('Use_Avg_Bal_Pos.TOO_MANY_ROWS');
    WHEN OTHERS THEN
	return 0;
	cep_standard.debug('Use_Avg_Bal_Pos.OTHERS');
  END;
  --
  -- Get the end of day balance
  --
  BEGIN
	SELECT SUM(DECODE(l_ptd_range, 1, NVL(PERIOD_AGGREGATE1,0),
			2, NVL(PERIOD_AGGREGATE2,0)- NVL(PERIOD_AGGREGATE1,0),
			3, NVL(PERIOD_AGGREGATE3,0)-NVL(PERIOD_AGGREGATE2,0),
			4, NVL(PERIOD_AGGREGATE4,0)-NVL(PERIOD_AGGREGATE3,0),
			5, NVL(PERIOD_AGGREGATE5,0)-NVL(PERIOD_AGGREGATE4,0),
			6, NVL(PERIOD_AGGREGATE6,0)-NVL(PERIOD_AGGREGATE5,0),
			7, NVL(PERIOD_AGGREGATE7,0)-NVL(PERIOD_AGGREGATE6,0),
			8, NVL(PERIOD_AGGREGATE8,0)-NVL(PERIOD_AGGREGATE7,0),
			9, NVL(PERIOD_AGGREGATE9,0)-NVL(PERIOD_AGGREGATE8,0),
			10, NVL(PERIOD_AGGREGATE10,0)-NVL(PERIOD_AGGREGATE9,0),
			11, NVL(PERIOD_AGGREGATE11,0)-NVL(PERIOD_AGGREGATE10,0),
			12, NVL(PERIOD_AGGREGATE12,0)-NVL(PERIOD_AGGREGATE11,0),
			13, NVL(PERIOD_AGGREGATE13,0)-NVL(PERIOD_AGGREGATE12,0),
			14, NVL(PERIOD_AGGREGATE14,0)-NVL(PERIOD_AGGREGATE13,0),
			15, NVL(PERIOD_AGGREGATE15,0)-NVL(PERIOD_AGGREGATE14,0),
			16, NVL(PERIOD_AGGREGATE16,0)-NVL(PERIOD_AGGREGATE15,0),
			17, NVL(PERIOD_AGGREGATE17,0)-NVL(PERIOD_AGGREGATE16,0),
			18, NVL(PERIOD_AGGREGATE18,0)-NVL(PERIOD_AGGREGATE17,0),
			19, NVL(PERIOD_AGGREGATE19,0)-NVL(PERIOD_AGGREGATE18,0),
			20, NVL(PERIOD_AGGREGATE20,0)-NVL(PERIOD_AGGREGATE19,0),
			21, NVL(PERIOD_AGGREGATE21,0)-NVL(PERIOD_AGGREGATE20,0),
			22, NVL(PERIOD_AGGREGATE22,0)-NVL(PERIOD_AGGREGATE21,0),
			23, NVL(PERIOD_AGGREGATE23,0)-NVL(PERIOD_AGGREGATE22,0),
			24, NVL(PERIOD_AGGREGATE24,0)-NVL(PERIOD_AGGREGATE23,0),
			25, NVL(PERIOD_AGGREGATE25,0)-NVL(PERIOD_AGGREGATE24,0),
			26, NVL(PERIOD_AGGREGATE26,0)-NVL(PERIOD_AGGREGATE25,0),
			27, NVL(PERIOD_AGGREGATE27,0)-NVL(PERIOD_AGGREGATE26,0),
			28, NVL(PERIOD_AGGREGATE28,0)-NVL(PERIOD_AGGREGATE27,0),
			29, NVL(PERIOD_AGGREGATE29,0)-NVL(PERIOD_AGGREGATE28,0),
			30, NVL(PERIOD_AGGREGATE30,0)-NVL(PERIOD_AGGREGATE29,0),
			31, NVL(PERIOD_AGGREGATE31,0)-NVL(PERIOD_AGGREGATE30,0),
			32, NVL(PERIOD_AGGREGATE32,0)-NVL(PERIOD_AGGREGATE31,0),
			33, NVL(PERIOD_AGGREGATE33,0)-NVL(PERIOD_AGGREGATE32,0),
			34, NVL(PERIOD_AGGREGATE34,0)-NVL(PERIOD_AGGREGATE33,0),
			35, NVL(PERIOD_AGGREGATE35,0)-NVL(PERIOD_AGGREGATE34,0),0)*
				DECODE(CE_CASH_FCST.G_rp_exchange_type,'User',CE_CASH_FCST.G_rp_exchange_rate,curr.exchange_rate))
	INTO	l_end_of_day
	FROM	gl_daily_balances 		gdb,
		gl_sets_of_books 		org,
		gl_code_combinations 		glcc,
		ce_currency_rates_temp 		curr
	WHERE	curr.forecast_request_id 	= CE_CASH_FCST.G_forecast_id
	AND	curr.currency_code 		= gdb.currency_code
	AND	gdb.period_name 		= l_period_name
	AND	gdb.currency_code 		= org.currency_code
	AND	gdb.currency_type 		= DECODE(CE_CASH_FCST.G_rp_src_curr_type, 'A', 'U',
									'E','C',
									'F','U')
	AND	gdb.code_combination_id 	= glcc.code_combination_id
	AND	gdb.actual_flag 		= 'A'
	AND	gdb.ledger_id 			= org.set_of_books_id
	AND	glcc.template_id 		IS NULL
	AND 	glcc.summary_flag 		= 'N'
	AND	glcc.code_combination_id 	= p_ccid
	AND	org.enable_average_balances_flag = 'Y';

    cep_standard.debug('<<CE_CSH_FCST_POP.Use_Avg_Bal_Pos');
    RETURN( nvl(l_end_of_day,0) );
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  RETURN(0);
	WHEN OTHERS THEN
	  CEP_STANDARD.DEBUG('EXCEPTION: OTHERS - Use_avg_bal_pos');
	  RAISE;
  END;
END Use_Avg_Bal_Pos;



/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Calc_Initial_Cash_Position					|
|	/l_ptd_range							|
|  DESCRIPTION								|
|	Calculates the initial cash position for the forecast start	|
|	date								|
|  CALLED BY								|
|	CE_CASH_FCST_POP.Cash_Forecast			|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Calc_Initial_Cash_Position(p_ccid NUMBER) RETURN NUMBER IS
  initial_cash_pos NUMBER;
  begin_cash_bal NUMBER;
  bal_to_date NUMBER;
  begin_period	VARCHAR2(30);
  avg_bal	VARCHAR2(1);
  avg_bal_init_cash_pos NUMBER;
BEGIN
  cep_standard.debug('>>Calc_Initial_Cash_Position ');
  IF (CE_CASH_FCST.G_aging_type = 'D') THEN
    --
    -- Check to see if average daily balances are used;
    --
      avg_bal_init_cash_pos := Use_Avg_Bal_Pos(p_ccid);

      -- Get Initial Balance
      cep_standard.debug('Get initial balance');
      cep_standard.debug('CCID: ' || p_ccid);
      cep_standard.debug('Avg bal init cash pos: ' || avg_bal_init_cash_pos);
      BEGIN
	SELECT  src.period_name,
		nvl(SUM((nvl(src.begin_balance_dr,0)-nvl(src.begin_balance_cr,0))*
			DECODE(CE_CASH_FCST.G_rp_exchange_type, 'User', CE_CASH_FCST.G_rp_exchange_rate, curr.exchange_rate)),0)
	INTO	begin_period,
		begin_cash_bal
	FROM	gl_balances 		src,
		gl_sets_of_books 	org,
		gl_periods 		gp,
		gl_code_combinations 	glcc,
		ce_currency_rates_temp 	curr
	WHERE	curr.forecast_request_id 	= CE_CASH_FCST.G_forecast_id
	AND	curr.currency_code 		= src.currency_code
	AND	src.period_name 		= gp.period_name
	AND	src.currency_code 		= DECODE(CE_CASH_FCST.G_rp_src_curr_type,
							'A',src.currency_code,
							'E',CE_CASH_FCST.G_rp_src_currency,
							org.currency_code)
	AND	NVL(src.translated_flag,'R') 	= 'R'
	AND	src.ledger_id 		= org.set_of_books_id
	AND	src.actual_flag 		= 'A'
	AND	glcc.template_id 		is NULL
	AND 	glcc.summary_flag 		= 'N'
	AND	src.code_combination_id 	= glcc.code_combination_id
	AND	glcc.code_combination_id 	= p_ccid
	AND	CE_CASH_FCST.G_rp_forecast_start_date BETWEEN gp.start_date AND gp.end_date
	AND	gp.period_set_name 		= org.period_set_name
	AND	gp.period_set_name 		= CE_CASH_FCST.G_rp_calendar_name
	AND	nvl(org.enable_average_balances_flag,'N') = 'N'
	GROUP BY src.period_name;
	cep_standard.debug('INITIAL BALANCE FOR: '|| begin_period || ' is : '|| begin_Cash_bal);
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
		cep_standard.debug('EXCEPTION: Calc Initial Cash pos:no data found');
		cep_standard.debug('Intial Cash position is 0');
		begin_cash_bal :=0;
	WHEN OTHERS THEN
		cep_standard.debug('EXCEPTION: Calc Initial Cash pos');
		cep_standard.debug('Exception: begin balance failed');
		RAISE;
      END;

      cep_standard.debug('INITIAL PERIOD BALANCE FOR: '|| begin_period || ' is : '|| begin_Cash_bal);
      BEGIN
	SELECT  nvl(SUM((nvl(jl.entered_dr,0) - nvl(jl.entered_cr,0))*
			DECODE(CE_CASH_FCST.G_rp_exchange_type, 'User', CE_CASH_FCST.G_rp_exchange_rate, curr.exchange_rate)),0)
	INTO	bal_to_date
	FROM	gl_je_lines 		jl,
		gl_je_headers 		jh,
		gl_sets_of_books 	org,
		gl_code_combinations 	glcc,
		ce_currency_rates_temp 	curr
	WHERE	curr.forecast_request_id 	= CE_CASH_FCST.G_forecast_id
	AND	curr.currency_code 		= jh.currency_code
	AND	jl.effective_date 		<= CE_CASH_FCST.G_rp_forecast_start_date
	AND	jl.status 			= 'P'
	AND	jl.period_name 			= begin_period
	AND	jh.currency_code 		= DECODE(CE_CASH_FCST.G_rp_src_curr_type,'E',CE_CASH_FCST.G_rp_src_currency,
								jh.currency_code)
	AND	jl.ledger_id 		= org.set_of_books_id
	AND	jl.je_header_id 		= jh.je_header_id
	AND	glcc.template_id 		is NULL
	AND 	glcc.summary_flag 		= 'N'
	AND	jl.code_combination_id 		= glcc.code_combination_id
	AND	glcc.code_combination_id 	= p_ccid
	AND	nvl(org.enable_average_balances_flag,'N') = 'N';

	cep_standard.debug('balance to date is: '|| bal_to_date);
	cep_standard.debug('1 return');

	RETURN(avg_bal_init_cash_pos + begin_cash_bal + bal_to_date);
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
		bal_to_date :=0;
		cep_standard.debug('exception:no data found balance_to_date is 0');
		cep_standard.debug('2 return');RETURN(begin_cash_bal + bal_to_date);
	  WHEN OTHERS THEN
		cep_standard.debug('EXCEPTION: Calc INitial Cash pos');
		cep_standard.debug('Exception: balance to date failed');
		RAISE;
      END;
  ELSE
	SELECT 	SUM((nvl(src.begin_balance_dr,0)-nvl(src.begin_balance_cr,0))*
			DECODE(CE_CASH_FCST.G_rp_exchange_type, 'User', CE_CASH_FCST.G_rp_exchange_rate, curr.exchange_rate))
	INTO	initial_cash_pos
	FROM	gl_balances 		src,
		gl_sets_of_books 	org,
		gl_code_combinations 	glcc,
		ce_currency_rates_temp 	curr
	WHERE	curr.forecast_request_id 	= CE_CASH_FCST.G_forecast_id
	AND	curr.currency_code 		= src.currency_code
	AND	src.period_name 		= CE_CASH_FCST.G_rp_forecast_start_period
	AND	org.period_set_name 		= CE_CASH_FCST.G_rp_calendar_name
	AND	src.actual_flag 		= 'A'
	AND	src.currency_code 		= DECODE(CE_CASH_FCST.G_rp_src_curr_type,
							'A',src.currency_code,
							'E',CE_CASH_FCST.G_rp_src_currency,
							org.currency_code)
    	AND 	NVL(src.translated_flag,'R') 	= 'R'
    	AND 	src.ledger_id 		= org.set_of_books_id
    	AND 	glcc.template_id 		IS NULL
    	AND 	glcc.code_combination_id 	= src.code_combination_id
    	AND 	glcc.code_combination_id 	= p_ccid;

    	cep_standard.debug('3 return');

	RETURN(initial_cash_pos);

  END IF;

  cep_standard.debug('4 return');
  RETURN initial_cash_pos;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	cep_standard.debug('5 return');
	return(0);
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION:OTHERS - Calc_Initial_Cash_Position');
	RAISE;
END Calc_Initial_Cash_Position;




/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Populate_Opening_Bal						|
|									|
|  DESCRIPTION								|
|	This procedure populates CE_FORECAST_OPENING_BAL with the	|
|	appropriate opening bank balance or opening GL cash account	|
|	balance if the balance isn't already populated.			|
|									|
|  CALLED BY								|
|	Execute_Main_Query						|
|  REQUIRES								|
|	bank_account_id							|
|  HISTORY								|
|	29-JAN-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Populate_Opening_Bal IS

  CURSOR C_bank is SELECT DISTINCT bank_account_id
			FROM ce_forecast_trx_cells
			WHERE bank_account_id is not null
			AND forecast_id = CE_CASH_FCST.G_forecast_id
			AND forecast_row_id = CE_CASH_FCST.G_forecast_row_id;

  CURSOR C_glcp is SELECT DISTINCT code_combination_id
			FROM ce_forecast_trx_cells
			WHERE code_combination_id is not null
			AND forecast_id = CE_CASH_FCST.G_forecast_id
			AND forecast_row_id = CE_CASH_FCST.G_forecast_row_id;

  CURSOR C_sub_acct(p_fc_start_date DATE,
			p_le_id NUMBER) is
		SELECT nvl(ledger_balance,0) ledger_balance,
	  		nvl(cashflow_balance,0) cashflow_balance,
			nvl(int_calc_balance,0) int_calc_balance,
			nvl(one_day_float,0) one_day_float,
			nvl(two_day_float,0) two_day_float,
			statement_date+1 balance_date,
			currency_code,
			account_number,
			legal_entity_id
		FROM	ce_cp_sub_open_bal_v
	  	WHERE 	trunc(statement_date) < p_fc_start_date
	  	AND	trunc(next_stmt_date) >= p_fc_start_date
		AND	legal_entity_id = nvl(p_le_id, legal_entity_id);


  counter		NUMBER;
  counter2		NUMBER;
  xtr_bank		NUMBER;
  l_opening_balance	NUMBER;
  l_stmt_balance	NUMBER;
  l_cflow_balance	NUMBER;
  l_int_calc_balance	NUMBER;
  l_one_day_float	NUMBER;
  l_two_day_float	NUMBER;
  l_legal_entity_id 	NUMBER;
  l_fc_start_date 	DATE;
  l_balance_date	DATE;
  l_bank_acc_name	VARCHAR2(80);
  l_bank_acc_curr	VARCHAR2(15);
  l_exchange_rate	NUMBER;
  l_app_cflow		NUMBER;
  l_arr_cflow		NUMBER;
  l_xtr_cflow		NUMBER;
  l_pay_cflow		NUMBER;
  l_prior_day_cflow	NUMBER;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  cep_standard.debug('>>CE_CSH_FCST_POP.Populate_Opening_Bal');

  IF (CE_CASH_FCST.G_rp_view_by in ('BANK','ALL')) THEN
    IF (CE_CASH_FCST.G_aging_type = 'D') THEN
      l_fc_start_date := trunc(CE_CASH_FCST.G_rp_forecast_start_date);
    ELSE
      select trunc(start_date)
      into l_fc_start_date
      from gl_periods
      where period_set_name = CE_CASH_FCST.G_rp_calendar_name
      and period_name = CE_CASH_FCST.G_rp_forecast_start_period;
    END IF;

    IF (CE_CASH_FCST.G_trx_type IN ('APP','ARR','PAY','XTI','XTO')) THEN
      FOR p_bank in C_bank LOOP
        SELECT count(1)
        INTO counter
        FROM ce_forecast_opening_bal
        WHERE forecast_id = CE_CASH_FCST.G_forecast_id
        AND bank_account_id = p_bank.bank_account_id;

        IF counter = 0 THEN
	  SELECT 	bank_account_name,
			account_owner_org_id
	    INTO 	l_bank_acc_name,
			l_legal_entity_id
	    FROM 	ce_bank_accounts ba
	    WHERE 	ba.bank_account_id = p_bank.bank_account_id;

	  SELECT count(1)
	  INTO counter2
	  FROM ce_cp_open_bal_v
	  WHERE bank_account_id = p_bank.bank_account_id
	  AND trunc(statement_date) < l_fc_start_date;

	  IF counter2 > 0 THEN
	    SELECT nvl(ledger_balance,0),
	  	nvl(cashflow_balance,0),
		nvl(int_calc_balance,0),
		nvl(one_day_float,0),
		nvl(two_day_float,0),
		statement_date+1,
		currency_code
	    INTO l_stmt_balance,
		l_cflow_balance,
		l_int_calc_balance,
		l_one_day_float,
		l_two_day_float,
		l_balance_date,
		l_bank_acc_curr
	    FROM ce_cp_open_bal_v
	    WHERE bank_account_id = p_bank.bank_account_id
	    AND trunc(statement_date) < l_fc_start_date
	    AND	trunc(next_stmt_date) >= l_fc_start_date;

	    IF CE_CASH_FCST.G_rp_bank_balance_type = 'L' THEN
	      l_opening_balance := l_stmt_balance;
	    ELSIF CE_CASH_FCST.G_rp_bank_balance_type = 'C' THEN
	      l_opening_balance := l_cflow_balance;
	    ELSE
	      l_opening_balance := l_int_calc_balance;
	    END IF;

	    IF CE_CASH_FCST.G_rp_float_type = 'ADD1' THEN
              l_opening_balance := l_opening_balance + l_one_day_float;
	    ELSIF CE_CASH_FCST.G_rp_float_type = 'ADD2' THEN
              l_opening_balance := l_opening_balance + l_two_day_float;
	    ELSIF CE_CASH_FCST.G_rp_float_type = 'SUB1' THEN
              l_opening_balance := l_opening_balance - l_one_day_float;
	    ELSIF CE_CASH_FCST.G_rp_float_type = 'SUB2' THEN
              l_opening_balance := l_opening_balance - l_two_day_float;
	    END IF;

	    IF (l_bank_acc_curr <> CE_CASH_FCST.G_rp_forecast_currency) THEN
	      IF (CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
	        l_opening_balance := l_opening_balance * CE_CASH_FCST.G_rp_exchange_rate;
	      ELSE
	        BEGIN
	          cep_standard.debug('>>Bank Account currency conversion');

	          select exchange_rate
	          into l_exchange_rate
	          from ce_currency_rates_temp
	          where currency_code = l_bank_acc_curr
 	          and to_currency = CE_CASH_FCST.G_rp_forecast_currency
		  and forecast_request_id = CE_CASH_FCST.G_forecast_id;

	          l_opening_balance := l_opening_balance * l_exchange_rate;

	          cep_standard.debug('<<Bank Account currency conversion');
                EXCEPTION
	          WHEN NO_DATA_FOUND THEN
		    UPDATE	ce_forecasts
		    SET		error_status = 'X'
		    WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

  		    FND_MESSAGE.set_name('CE', 'CE_FC_NO_BANK_EXCH_RATE');
		    FND_MESSAGE.set_token('FROM_CURR', l_bank_acc_curr);
		    FND_MESSAGE.set_token('TO_CURR', CE_CASH_FCST.G_rp_forecast_currency);
		    FND_MESSAGE.set_token('BANK_ACCOUNT_NAME', l_bank_acc_name);
		    error_msg := FND_MESSAGE.get;
		    CE_FORECAST_ERRORS_PKG.insert_row(
					CE_CASH_FCST.G_forecast_id,
					CE_CASH_FCST.G_rp_forecast_header_id,
					CE_CASH_FCST.G_forecast_row_id,
					'CE_FC_NO_BANK_EXCH_RATE',
					error_msg);
		    cep_standard.debug('EXCEPTION: Populate_Opening_Bal - No exchange rate found');

		    l_opening_balance := 0;
	          WHEN OTHERS Then
		    cep_standard.debug('EXCEPTION: Populate_Opening_Bal - Bank Account Currency exchange rate conversion');
		    raise;
    	        END;
	      END IF;
	    END IF;

  	    l_opening_balance := round(l_opening_balance,CE_CASH_FCST.G_precision);

	    -- If overdue and prior-day overlap, issue warning
	    IF (l_balance_date < l_fc_start_date AND
		CE_CASH_FCST.G_overdue_transactions = 'INCLUDE') THEN
  	      UPDATE	ce_forecasts
	      SET	error_status = 'X'
	      WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	      FND_MESSAGE.set_name('CE', 'CE_FC_PD_OD_OVERLAP');
	      FND_MESSAGE.set_token('BANK_ACCOUNT_NAME', l_bank_acc_name);
	      error_msg := FND_MESSAGE.get;
	      CE_FORECAST_ERRORS_PKG.insert_row(
			CE_CASH_FCST.G_forecast_id,
			CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id,
			'CE_FC_PD_OD_OVERLAP',
			error_msg);
	    END IF;

            -- Calculate Prior-day Cashflow
	    IF(CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
	      SELECT SUM(amount*CE_CASH_FCST.G_rp_exchange_rate)
	      INTO l_app_cflow
	      FROM ce_ap_fc_payments_v
	      WHERE bank_account_id = p_bank.bank_account_id
	      AND payment_date >= l_balance_date
	      AND payment_date < l_fc_start_date;

	      SELECT SUM(amount*CE_CASH_FCST.G_rp_exchange_rate)
	      INTO l_arr_cflow
	      FROM ce_ar_fc_receipts_v
	      WHERE bank_account_id = p_bank.bank_account_id
	      AND cash_activity_date >= l_balance_date
	      AND cash_activity_date < l_fc_start_date;

	      SELECT SUM(amount*CE_CASH_FCST.G_rp_exchange_rate)
	      INTO l_xtr_cflow
	      FROM ce_xtr_cashflows_v
	      WHERE bank_account_id = p_bank.bank_account_id
	      AND trx_date >= l_balance_date
	      AND trx_date < l_fc_start_date;

	      SELECT SUM(amount)
	      INTO l_pay_cflow
	      FROM ce_pay_fc_payroll_v
	      WHERE bank_account_id = p_bank.bank_account_id
	      AND trx_date >= l_balance_date
	      AND trx_date < l_fc_start_date;
            ELSE
	      SELECT SUM(src.amount*curr.exchange_rate)
	      INTO l_app_cflow
	      FROM ce_ap_fc_payments_v src,
		ce_currency_rates_temp curr
	      WHERE src.bank_account_id = p_bank.bank_account_id
	      AND src.payment_date >= l_balance_date
	      AND src.payment_date < l_fc_start_date
	      AND curr.forecast_request_id = CE_CASH_FCST.G_forecast_id
	      AND curr.to_currency = CE_CASH_FCST.G_rp_forecast_currency
  	      AND curr.currency_code = src.currency_code;

	      SELECT SUM(src.amount*curr.exchange_rate)
	      INTO l_arr_cflow
	      FROM ce_ar_fc_receipts_v src,
		ce_currency_rates_temp curr
	      WHERE src.bank_account_id = p_bank.bank_account_id
	      AND src.cash_activity_date >= l_balance_date
	      AND src.cash_activity_date < l_fc_start_date
	      AND curr.forecast_request_id = CE_CASH_FCST.G_forecast_id
	      AND curr.to_currency = CE_CASH_FCST.G_rp_forecast_currency
  	      AND curr.currency_code = src.currency_code;

	      SELECT SUM(src.amount*curr.exchange_rate)
	      INTO l_xtr_cflow
	      FROM ce_xtr_cashflows_v src,
		ce_currency_rates_temp curr
	      WHERE src.bank_account_id = p_bank.bank_account_id
	      AND src.trx_date >= l_balance_date
	      AND src.trx_date < l_fc_start_date
	      AND curr.forecast_request_id = CE_CASH_FCST.G_forecast_id
	      AND curr.to_currency = CE_CASH_FCST.G_rp_forecast_currency
  	      AND curr.currency_code = src.currency_code;

	      SELECT SUM(src.amount*curr.exchange_rate)
	      INTO l_pay_cflow
	      FROM ce_pay_fc_payroll_v src,
		ce_currency_rates_temp curr
	      WHERE src.bank_account_id = p_bank.bank_account_id
	      AND src.trx_date >= l_balance_date
	      AND src.trx_date < l_fc_start_date
	      AND curr.forecast_request_id = CE_CASH_FCST.G_forecast_id
	      AND curr.to_currency = CE_CASH_FCST.G_rp_forecast_currency
  	      AND curr.currency_code = src.currency_code;
	    END IF;

  	    l_prior_day_cflow := round(nvl(l_arr_cflow,0) - nvl(l_app_cflow,0)
		+ nvl(l_xtr_cflow,0) - nvl(l_pay_cflow,0),CE_CASH_FCST.G_precision);


          ELSE -- no bank balances available before forecast start date
	    l_opening_balance := 0;
	    l_prior_day_cflow := 0;
	    l_balance_date := null;

	    UPDATE	ce_forecasts
	    SET		error_status = 'X'
	    WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	    FND_MESSAGE.set_name('CE', 'CE_FC_NO_BANK_BALANCE');
	    FND_MESSAGE.set_token('BANK_ACCOUNT_NAME', l_bank_acc_name);
	    error_msg := FND_MESSAGE.get;
	    CE_FORECAST_ERRORS_PKG.insert_row(
			CE_CASH_FCST.G_forecast_id,
			CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id,
			'CE_FC_NO_BANK_BALANCE',
			error_msg);
          END IF;

          INSERT INTO ce_forecast_opening_bal
		(balance_id,
		forecast_id,
  	    	balance_type,
	    	bank_account_id,
	    	code_combination_id,
	  	opening_balance,
	  	balance_date,
		prior_day_cflow,
		legal_entity_id,
		created_by,
	  	creation_date,
		last_updated_by,
	  	last_update_date,
		last_update_login)
          VALUES
	  	(CE_FORECAST_OPENING_BAL_S.nextval,
		CE_CASH_FCST.G_forecast_id,
	  	'BANK',
	  	p_bank.bank_account_id,
	  	null,
	  	l_opening_balance,
	  	l_balance_date,
	  	l_prior_day_cflow,
	  	l_legal_entity_id,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1));

        END IF;
      END LOOP;
    END IF;

    l_opening_balance := 0;

    -- Insert subsidiary bank balances as well
    IF (nvl(CE_CASH_FCST.G_rp_include_sub_account,'N') = 'Y') THEN
      IF (nvl(G_sub_accounts_complete,'N') = 'N') THEN
        IF (CE_CASH_FCST.G_legal_entity_id is null) THEN
          G_sub_accounts_complete := 'Y';
        END IF;

        -- Check if we have already processed this legal entity
        SELECT count(1)
        INTO counter
        FROM ce_forecast_opening_bal
        WHERE forecast_id = CE_CASH_FCST.G_forecast_id
        AND bank_account_id = -2
        AND legal_entity_id = nvl(CE_CASH_FCST.G_legal_entity_id,-1);

        IF counter = 0 THEN
          FOR p_sub_acct in C_sub_acct(l_fc_start_date,CE_CASH_FCST.G_legal_entity_id) LOOP
            IF CE_CASH_FCST.G_rp_bank_balance_type = 'L' THEN
	      l_opening_balance := p_sub_acct.ledger_balance;
            ELSIF CE_CASH_FCST.G_rp_bank_balance_type = 'C' THEN
	      l_opening_balance := p_sub_acct.cashflow_balance;
            ELSE
	      l_opening_balance := p_sub_acct.int_calc_balance;
            END IF;

            IF CE_CASH_FCST.G_rp_float_type = 'ADD1' THEN
              l_opening_balance := l_opening_balance + p_sub_acct.one_day_float;
            ELSIF CE_CASH_FCST.G_rp_float_type = 'ADD2' THEN
              l_opening_balance := l_opening_balance + p_sub_acct.two_day_float;
            ELSIF CE_CASH_FCST.G_rp_float_type = 'SUB1' THEN
              l_opening_balance := l_opening_balance - p_sub_acct.one_day_float;
            ELSIF CE_CASH_FCST.G_rp_float_type = 'SUB2' THEN
              l_opening_balance := l_opening_balance - p_sub_acct.two_day_float;
            END IF;

            IF (p_sub_acct.currency_code <> CE_CASH_FCST.G_rp_forecast_currency) THEN
	      IF (CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
	        l_opening_balance := l_opening_balance * CE_CASH_FCST.G_rp_exchange_rate;
	      ELSE
	        BEGIN
	          cep_standard.debug('>>Subsidiary Bank Account currency conversion');

	          select exchange_rate
  	          into l_exchange_rate
	          from ce_currency_rates_temp
	          where currency_code = p_sub_acct.currency_code
	          and to_currency = CE_CASH_FCST.G_rp_forecast_currency
 		  and forecast_request_id = CE_CASH_FCST.G_forecast_id;

	          l_opening_balance := l_opening_balance * l_exchange_rate;

	          cep_standard.debug('<<Subsidiary Bank Account currency conversion');
                EXCEPTION
	          WHEN NO_DATA_FOUND THEN
	            UPDATE	ce_forecasts
 	            SET		error_status = 'X'
	            WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	            FND_MESSAGE.set_name('CE', 'CE_FC_NO_SUB_EXCH_RATE');
	            FND_MESSAGE.set_token('FROM_CURR', p_sub_acct.currency_code);
	            FND_MESSAGE.set_token('TO_CURR', CE_CASH_FCST.G_rp_forecast_currency);
	            FND_MESSAGE.set_token('ACCOUNT_NUMBER', p_sub_acct.account_number);
	            error_msg := FND_MESSAGE.get;
	            CE_FORECAST_ERRORS_PKG.insert_row(
				CE_CASH_FCST.G_forecast_id,
				CE_CASH_FCST.G_rp_forecast_header_id,
				CE_CASH_FCST.G_forecast_row_id,
				'CE_FC_NO_SUB_EXCH_RATE',
				error_msg);
	            cep_standard.debug('EXCEPTION: Populate_Opening_Bal - Subsidiary - No exchange rate found');

		    l_opening_balance := 0;
	          WHEN OTHERS Then
	            cep_standard.debug('EXCEPTION: Populate_Opening_Bal - Subsidiary Bank Account Currency exchange rate conversion');
	            raise;
    	        END;
	      END IF;
            END IF;

	    l_opening_balance := round(l_opening_balance,CE_CASH_FCST.G_precision);

            INSERT INTO ce_forecast_opening_bal
	  	(balance_id,
		forecast_id,
  	  	balance_type,
	  	bank_account_id,
	  	code_combination_id,
		opening_balance,
	  	balance_date,
	  	prior_day_cflow,
	  	legal_entity_id,
	  	created_by,
	  	creation_date,
	  	last_updated_by,
	  	last_update_date,
	  	last_update_login)
            VALUES
	  	(CE_FORECAST_OPENING_BAL_S.nextval,
		CE_CASH_FCST.G_forecast_id,
	  	'BANK',
	  	-2,
	  	null,
	  	l_opening_balance,
	  	p_sub_acct.balance_date,
	  	null,
	  	p_sub_acct.legal_entity_id,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1));

          END LOOP;

        END IF;
      END IF;
    END IF;
  END IF;
  IF (CE_CASH_FCST.G_rp_view_by in ('GLCP','ALL')) THEN
    IF (CE_CASH_FCST.G_trx_type IN ('APP','ARR','PAY','XTI','XTO')) THEN
      FOR p_glcp in C_glcp LOOP
        SELECT count(1)
        INTO counter
        FROM ce_forecast_opening_bal
        WHERE forecast_id = CE_CASH_FCST.G_forecast_id
        AND code_combination_id = p_glcp.code_combination_id;
        IF (counter = 0) THEN
          l_opening_balance := Calc_Initial_Cash_Position(p_glcp.code_combination_id);
	  l_opening_balance := round(l_opening_balance,CE_CASH_FCST.G_precision);

          INSERT INTO ce_forecast_opening_bal
		(balance_id,
		forecast_id,
	  	balance_type,
	  	bank_account_id,
	  	code_combination_id,
	  	opening_balance,
	  	legal_entity_id,
	  	created_by,
	  	creation_date,
	  	last_updated_by,
	  	last_update_date,
	  	last_update_login)
          VALUES
	  	(CE_FORECAST_OPENING_BAL_S.nextval,
		CE_CASH_FCST.G_forecast_id,
	  	'GLCP',
	  	null,
	  	p_glcp.code_combination_id,
	  	l_opening_balance,
	  	null,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1),
	  	sysdate,
	  	nvl(fnd_global.user_id,-1));

        END IF;
      END LOOP;
    END IF;
  END IF;

  cep_standard.debug('<<CE_CSH_FCST_POP.Populate_Opening_Bal');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Populate_Opening_Bal');
		raise;
END Populate_Opening_Bal;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_AP_Pay_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for AP payments that were made in the past.		|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_AP_Pay_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(2000);
  select_clause	varchar2(2000);
  main_query	varchar2(3500) := null;
  counter	number;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN

  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_AP_Pay_Query');

  from_clause := Get_From_Clause('ce_ap_fc_payments_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || Add_Where('PAYMENT_METHOD') || Add_Where('BANK_ACCOUNT_ID');

  IF (NVL(CE_CASH_FCST.G_forecast_method,'F') = 'P') THEN

    BEGIN
	Set_History;

    EXCEPTION
    	When NO_DATA_FOUND Then
		cep_standard.debug('row_id = ' || to_char(CE_CASH_FCST.G_forecast_row_id));

		UPDATE	ce_forecasts
		SET	error_status = 'E'
		WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

		FND_MESSAGE.set_name('CE', 'CE_NO_HIST_START_PERIOD');
		error_msg := FND_MESSAGE.get;
		CE_FORECAST_ERRORS_PKG.insert_row(
					CE_CASH_FCST.G_forecast_id,
					CE_CASH_FCST.G_rp_forecast_header_id,
					CE_CASH_FCST.G_forecast_row_id,
					'CE_NO_HIST_START_PERIOD',
					error_msg);
		zero_fill_cells;
		cep_standard.debug('EXCEPTION: No history data found for APP');
		return;
	When OTHERS Then
		cep_standard.debug('EXCEPTION: Build APP query - Set History');
		raise;
    END;
    IF (CE_CASH_FCST.G_order_date_type = 'V') THEN
      IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    	select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.reference_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			NVL(src.actual_value_date, src.cleared_date),
			src.bank_account_id,
			nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
			round(nvl(-src.amount,0)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
      ELSE
    	select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.reference_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			NVL(src.actual_value_date, src.cleared_date),
			src.bank_account_id,
			nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
			round(nvl(-src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
      END IF;
      cep_standard.debug('Built Select Clause');

      where_clause := where_clause || '
	AND	NVL(src.actual_value_date, src.cleared_date) BETWEEN cab.start_date and cab.end_date
	AND	src.status <> ''NEGOTIABLE'' ';
    ELSE
      IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    	select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.reference_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.cleared_date,
			src.bank_account_id,
			nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
			round(nvl(-src.amount,0)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
      ELSE
    	select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.reference_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.cleared_date,
			src.bank_account_id,
			nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
			round(nvl(-src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
      END IF;
      cep_standard.debug('Built Select Clause');

      where_clause := where_clause || '
	AND	src.cleared_date BETWEEN cab.start_date and cab.end_date
	AND	src.status <> ''NEGOTIABLE'' ';
    END IF;
  ELSE
    IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
      select_clause := '
	SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		NVL(src.actual_value_date,NVL(src.anticipated_value_date,NVL(src.maturity_date,src.payment_date))) +'
                ||to_char(CE_CASH_FCST.G_lead_time) || ',
		src.bank_account_id,
		nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
		round(nvl(-src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		-src.amount';
    ELSE
      select_clause := '
	SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		NVL(src.actual_value_date,NVL(src.anticipated_value_date,NVL(src.maturity_date,src.payment_date))) +'
                ||to_char(CE_CASH_FCST.G_lead_time) || ',
		src.bank_account_id,
		nvl(ccid.ap_asset_ccid, ccid.asset_code_combination_id),
		round(nvl(-src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		-src.amount';
    END IF;
    cep_standard.debug('Built Select Clause');

    where_clause := where_clause || '
	AND	NVL(src.actual_value_date,NVL(src.anticipated_value_date,NVL(src.maturity_date,src.payment_date))) BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	' AND	src.status in (''NEGOTIABLE'',''ISSUED'') ';
  END IF;
  cep_standard.debug('Built Where Clause');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);
  cep_standard.debug('<<ce_csh_fcST_POP.Build_AP_Pay_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_AP_Pay_Query');
		raise;
END Build_AP_Pay_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_AP_Project_Inv_Query					|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for AP invoice distributions that have not been paid,   |
|	but projected to be paid within the aging date ranges. 		|
|	It is assumed that payments will be made on one of the discount |
|	dates								|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_AP_Project_Inv_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
  view_name	VARCHAR2(50);

BEGIN
  cep_standard.debug('>>Build_AP_Project_Inv_Query');

  select_clause := Get_Select_Clause;
  cep_standard.debug('Built Select Clause');

  IF (NVL(CE_CASH_FCST.G_discount_option,'N') = 'N') THEN
    cep_standard.debug('Discount NOT taken');
    from_clause   := Get_From_Clause('ce_due_project_inv_v');
  ELSE    cep_standard.debug('Discount taken');
    from_clause   := Get_From_Clause('ce_disc_project_inv_v');
  END IF;
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID') ||
 	Add_Where('PAYMENT_PRIORITY') || Add_Where('PAY_GROUP') || Add_Where('VENDOR_TYPE') ||
        Add_Where('INCLUDE_HOLD_FLAG');

  cep_standard.debug('Built Where Clause');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_AP_Project_Inv_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_AP_Project_Inv_Query');
		raise;
END Build_AP_Project_Inv_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_AP_Invoice_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for AP invoices that have not been paid, but projected	|
|	to be paid within the aging date ranges	. It is assumed that 	|
|	payments will be made on one of the discount dates		|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol	                |
|       17-Feb-2010     Bug 9252881  Changed the value for select_clause|
|                       so that the value ccid.asset_code_combination_id|
|			is modified to					|
|        	nvl(ccid.ar_asset_ccid, ccid.asset_code_combination_id) |
 --------------------------------------------------------------------- */
PROCEDURE Build_AP_Invoice_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
  view_name	VARCHAR2(50);

BEGIN
  cep_standard.debug('>>Build_AP_Invoice_Query');

  select_clause := Get_Select_Clause;
  cep_standard.debug('Built Select Clause');

  IF (NVL(CE_CASH_FCST.G_discount_option,'N') = 'N') THEN
    cep_standard.debug('Discount NOT taken');
    from_clause   := Get_From_Clause('ce_ap_fc_due_invoices_v');
  ELSE
    cep_standard.debug('Discount taken');
    from_clause   := Get_From_Clause('ce_disc_invoices_v');
  END IF;
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID') ||
 	Add_Where('PAYMENT_PRIORITY') || Add_Where('PAY_GROUP') || Add_Where('VENDOR_TYPE') ||
        Add_Where('INCLUDE_HOLD_FLAG');

  IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
    where_clause := where_clause || '
        AND 	src.invoice_id NOT IN ( select	invoice_id
				   	from	ap_invoice_distributions_all
					where   project_id = ' || to_char(CE_CASH_FCST.G_rp_project_id) || ')';

  END IF;

  cep_standard.debug('Built Where Clause');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
    Build_AP_Project_Inv_Query;
  END IF;

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_AP_Invoice_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_AP_Invoice_Query');
		raise;
END Build_AP_Invoice_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Invoice_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for PA invoices which does not transferred to AR yet. 	|
|  CALLED BY								|
|	Build_AR_Invoice_Query						|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	20-NOV-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_PA_Invoice_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN
  CE_CASH_FCST.G_app_short_name := 'PA';

  IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			''PA'' || src.project_id || ''X'' || src.trx_number
				|| ''X'' || src.line_num,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(src.amount,0)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
			src.amount';
  ELSE
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			''PA'' || src.project_id || ''X'' || src.trx_number
				|| ''X'' || src.line_num,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
			src.amount';
  END IF;

  from_clause := Get_From_Clause ('pa_ce_invoices_v');
  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID') || Add_Where('CUSTOMER_PROFILE_CLASS_ID');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_PA_Invoices_Query');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_PA_Invoice_Query');
    RAISE;
END Build_PA_Invoice_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_AR_Invoice_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for AR invoices on which payments are due to be		|
|	received. Fully received invoices are exclude, but credit memos	|
|	debit memos and adjustments are included.			|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_AR_Invoice_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN
  cep_standard.debug('>>Build_AR_Invoice_Query');

  IF (CE_CASH_FCST.G_include_dispute_flag = 'N') THEN
      IF( CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
        select_clause := ' SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.trx_date +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round((nvl(src.amount,0)-nvl(src.dispute_amount,0))*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount-src.dispute_amount';
      ELSE
        select_clause := ' SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.trx_date +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round((nvl(src.amount,0)-nvl(src.dispute_amount,0))*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount-src.dispute_amount';
      END IF;
  ELSE
      select_clause := Get_Select_Clause;
  END IF;

  cep_standard.debug('Built Select Clause');

  from_clause := Get_From_Clause ('ce_ar_fc_invoices_v');
  cep_standard.debug('Built From Clause');

  IF (CE_CASH_FCST.G_use_average_payment_days = 'Y') THEN
    where_clause := Get_Where_Clause || ' AND
		 nvl(src.invoice_date, src.trx_date) + decode(src.invoice_date, null, '
		|| to_char(CE_CASH_FCST.G_lead_time)
		|| ', nvl( CE_CSH_FCST_POP.Get_Average_Payment_Days (src.customer_id, src.site_use_id, '
		|| ' src.currency_code, '
		|| to_char(CE_CASH_FCST.G_apd_period)
		|| '), (src.trx_date - src.invoice_date + '
		|| to_char(CE_CASH_FCST.G_lead_time)
		|| ') '
		|| ' ) ) BETWEEN cab.start_date and cab.end_date '||
		Add_Where('CUSTOMER_PROFILE_CLASS_ID');
  ELSE
     where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('CUSTOMER_PROFILE_CLASS_ID');
  END IF;

  IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
    where_clause := where_clause || '
        AND 	src.customer_trx_id IN (select 	ctl.customer_trx_id
					from 	ra_customer_trx_lines_all  ctl,
                                                pa_projects_all		   pa
					where 	ctl.interface_line_attribute1 = pa.segment1
                                        and     pa.project_id = ' || to_char(CE_CASH_FCST.G_rp_project_id) || ')';

  END IF;

  cep_standard.debug('Built Where Clause');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
    Build_PA_Invoice_Query;
  END IF;

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_AR_Invoices_Query');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_AR_Invoice_Query');
    RAISE;
END Build_AR_Invoice_Query;



/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_AR_Receipt_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for AP checks that have not cleared the bank.		|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol	                |
|       17-Feb-2010     Bug 9252881  Changed the value for select_clause|
|                 ,ccid.asset_code_combination_id value is replace with |
|                nvl(ccid.ar_asset_ccid, ccid.asset_code_combination_id)|
 --------------------------------------------------------------------- */
PROCEDURE Build_AR_Receipt_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  trx_date_clause varchar2(100);
  view_name	VARCHAR2(50);
  main_query	varchar2(3500) := null;
  counter	number;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  cep_standard.debug('>>Build_AR_Receipt_Query');

  from_clause := Get_From_Clause ('ce_ar_fc_receipts_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || Add_Where('BANK_ACCOUNT_ID') || Add_Where('RECEIPT_METHOD_ID');

  IF (NVL(CE_CASH_FCST.G_forecast_method,'F') = 'P') THEN
    BEGIN
	Set_History;

    EXCEPTION
    	When NO_DATA_FOUND Then
		cep_standard.debug('row_id = ' || to_char(CE_CASH_FCST.G_forecast_row_id));

		UPDATE	ce_forecasts
		SET	error_status = 'E'
		WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

		FND_MESSAGE.set_name('CE', 'CE_NO_HIST_START_PERIOD');
		error_msg := FND_MESSAGE.get;
		CE_FORECAST_ERRORS_PKG.insert_row(
					CE_CASH_FCST.G_forecast_id,
					CE_CASH_FCST.G_rp_forecast_header_id,
					CE_CASH_FCST.G_forecast_row_id,
					'CE_NO_HIST_START_PERIOD',
					error_msg);
		zero_fill_cells;
		cep_standard.debug('EXCEPTION: No history data found for ARR');
		return;
	When OTHERS Then
		cep_standard.debug('EXCEPTION: Build ARR query - Set History');
		raise;
    END;
    IF (CE_CASH_FCST.G_order_date_type = 'V') THEN
      where_clause := where_clause || '
	AND	NVL(src.actual_value_date,src.trx_date) BETWEEN cab.start_date and cab.end_date
	AND	src.status in (''CLEARED'',''RISK_ELIMINATED'') ';
      trx_date_clause := 'NVL(src.actual_value_date,src.trx_date)';
    ELSE
      where_clause := where_clause || '
	AND	src.trx_date BETWEEN cab.start_date and cab.end_date
	AND	src.status in (''CLEARED'',''RISK_ELIMINATED'') ';
      trx_date_clause := 'src.trx_date';
    END IF;
  ELSE  -- if Forecast Method is Future
    where_clause := where_clause || '
	AND	src.cash_activity_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	' AND	src.status not in (''CLEARED'',''RISK_ELIMINATED'') ';
    trx_date_clause := 'src.cash_activity_date';
  END IF;

  cep_standard.debug('Built Where Clause');

  IF(CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
    select_clause := 'SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		'||trx_date_clause||'+'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		src.bank_account_id,
		nvl(ccid.ar_asset_ccid, ccid.asset_code_combination_id),
		round(nvl(src.amount,0)*'
			||CE_CASH_FCST.G_rp_exchange_rate
			||','
			||CE_CASH_FCST.G_precision||'),
		src.amount';
  ELSE
    select_clause := 'SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		'||trx_date_clause||'+'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
      		src.bank_account_id,
		nvl(ccid.ar_asset_ccid, ccid.asset_code_combination_id),
  		round(nvl(src.amount,0)*curr.exchange_rate,'
			||CE_CASH_FCST.G_precision||'),
		src.amount';
  END IF;
  cep_standard.debug('Built Select Clause');

  main_query := select_clause || from_clause || where_clause;

  commit;

  Execute_Main_Query (main_query);
  cep_standard.debug('<<ce_csh_fcST_POP.Build_AR_Receipt_Query');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION-OTHERS:Build_AR_Receipt_Query');
    RAISE;
END Build_AR_Receipt_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Get_GL_General_Query						|
|                                                                       |
|  DESCRIPTION                                                          |
|                                                                       |
|  CALLED BY                                                            |
|       CE_CASH_FCST_POP.Build_GL_XXX_Query                 |
|  REQUIRES                                                             |
|                                                                       |
|  HISTORY                                                              |
|       19-AUG-1996     Created         Bidemi Carrol                   |
 --------------------------------------------------------------------- */
FUNCTION Get_GL_General_Query RETURN VARCHAR2 IS
  main_query	varchar2(2000) := null;
BEGIN
  cep_standard.debug('>>Get_GL_General_Query');
  IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    main_query := ' SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		null,
		src.currency_code,
		null,
		gp.start_date,
		null,
		null,
       	round((nvl(src.period_net_dr,0)-nvl(src.period_net_cr,0))*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		(nvl(src.period_net_dr,0)-nvl(src.period_net_cr,0))'; --bug4495616
  ELSE
    main_query := ' SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		null,
		src.currency_code,
		null,
		gp.start_date,
		null,
		null,
        round((nvl(src.period_net_dr,0)-nvl(src.period_net_cr,0))*curr.exchange_rate '
				||','||CE_CASH_FCST.G_precision||'),
		(nvl(src.period_net_dr,0)-nvl(src.period_net_cr,0))'; --bug4495616
  END IF;

  main_query := main_query || '
        FROM    gl_balances             src,
                gl_periods              gp,
                ce_forecast_ext_temp   cab ';

  IF( CE_CASH_FCST.G_rp_exchange_type <> 'User' OR
      CE_CASH_FCST.G_rp_exchange_type IS NULL)THEN
    main_query := main_query || ',
                ce_currency_rates_temp curr ';
  END IF;

  main_query := main_query || '
        WHERE   gp.start_date(+) 		= cab.start_date
        AND     gp.period_name                  = src.period_name
        AND     gp.period_type                  = src.period_type
        AND     gp.period_year                  = src.period_year
        AND     gp.period_set_name              = '''||CE_CASH_FCST.G_rp_calendar_name||'''
        AND     src.ledger_id             = '||CE_CASH_FCST.G_set_of_books_id||'
        AND     src.code_combination_id         = '||CE_CASH_FCST.G_code_combination_id ||
        Add_Where('EXCHANGE_TYPE');

  IF(CE_CASH_FCST.G_rp_src_curr_type = 'E')THEN
    main_query := main_query || '
        AND     src.currency_code               = '''||CE_CASH_FCST.G_rp_src_currency||''' ';
  ELSIF(CE_CASH_FCST.G_rp_src_curr_type = 'F')THEN
    main_query := main_query || '
        AND     src.currency_code               = DECODE('''||CE_CASH_FCST.G_sob_currency_code||''', '''||CE_CASH_FCST.G_rp_src_currency||''',src.currency_code, ''-1'')';
  END IF;

  return (main_query);
EXCEPTION
  WHEN OTHERS THEN
        cep_standard.debug('EXCEPTION-OTHERS: Get_GL_General_Query');
	RAISE;
END Get_GL_General_Query;



/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_GL_Budget_Query						|
|									|
|  DESCRIPTION								|
|									|
|  CALLED BY								|
|	CE_CASH_FCST_POP.Cash_Forecast					|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_GL_Budget_Query IS
  main_query    varchar2(2000) := null;

BEGIN
  cep_standard.debug('>>Build_GL_Budget_Query');
  main_query := Get_GL_General_Query || '
	AND	src.budget_version_id           = '||CE_CASH_FCST.G_budget_version_id||'
  	AND 	src.actual_flag 		= ''B'' ';

  Execute_Main_Query (main_query);

  cep_standard.debug('<<Build_GL_Budget_Query');

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION-OTHERS: Build_GL_Budget_Query');
	RAISE;
END Build_GL_Budget_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_GL_Encumb_Query						|
|  DESCRIPTION								|
|	Calculates the GL encumbrances over specified periods, for a	|
|	given code_combination_id					|
|  CALLED BY								|
|	CE_CASH_FCST_POP.Cash_Forecast					|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_GL_Encumb_Query IS
  main_query    varchar2(2000) := null;
BEGIN
  cep_standard.debug('>>Build_GL_Encumb_Query');
  main_query := Get_GL_General_Query || '
    	AND 	src.encumbrance_type_id 	= '||CE_CASH_FCST.G_encumbrance_type_id||'
    	AND 	src.actual_flag 		= ''E'' ';

  Execute_Main_Query (main_query);

  cep_standard.debug('<<Build_GL_Encumbrance_Query');

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION-OTHERS: Build_GL_Encumbrance_Query');
	RAISE;
END Build_GL_Encumb_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_GL_Actuals_Query						|
|									|
|  DESCRIPTION								|
|									|
|  CALLED BY								|
|	CE_CASH_FCST_POP.Cash_Forecast			|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_GL_Actuals_Query IS
  main_query    varchar2(2000) := null;

BEGIN
  cep_standard.debug('>>Build_GL_Actuals_Query');
  main_query := Get_GL_General_Query || '
    	AND 	src.actual_flag 		= ''A''
    	AND 	src.template_id 		is null  ';

  Execute_Main_Query (main_query);

  cep_standard.debug('<<Build_GL_Actuals_Query');

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION-OTHERS: Build_GL_Actuals_Query');
	RAISE;
END Build_GL_Actuals_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_Pay_Exp_Query						|
|									|
|  DESCRIPTION								|
|	Payroll amounts paid out.					|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	1-JUL-1997	Created		Wynne Chan			|
 --------------------------------------------------------------------- */
PROCEDURE Build_Pay_Exp_Query IS
  from_clause   VARCHAR2(500);
  where_clause  varchar2(1500);
  select_clause varchar2(1500);
  main_query    varchar2(3500) := null;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_PAY_Exp_Query');
  select_clause := Get_Select_Clause;
  cep_standard.debug('Built Select Clause');

  from_clause := Get_From_Clause('ce_pay_fc_payroll_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || '
        AND 	src.effective_date BETWEEN cab.start_date and cab.end_date ' ||
	Add_Where('ORG_PAYMENT_METHOD_ID') || Add_Where('BANK_ACCOUNT_ID') || Add_Where('PAYROLL_ID');

  IF(CE_CASH_FCST.G_rp_src_curr_type = 'F')THEN
    IF(CE_CASH_FCST.G_set_of_books_id IS NULL)THEN
      where_clause := where_clause || '
	AND	org.set_of_books_id IS NULL ';
    ELSE
      where_clause := where_clause || '
	AND	org.set_of_books_id = '||to_char(CE_CASH_FCST.G_set_of_books_id);
    END IF;
  END IF;


  BEGIN
	Set_History;

  EXCEPTION
    	When NO_DATA_FOUND Then
		cep_standard.debug('row_id = ' || to_char(CE_CASH_FCST.G_forecast_row_id));

		UPDATE	ce_forecasts
		SET	error_status = 'E'
		WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

		FND_MESSAGE.set_name('CE', 'CE_NO_HIST_START_PERIOD');
		error_msg := FND_MESSAGE.get;
		CE_FORECAST_ERRORS_PKG.insert_row(
					CE_CASH_FCST.G_forecast_id,
					CE_CASH_FCST.G_rp_forecast_header_id,
					CE_CASH_FCST.G_forecast_row_id,
					'CE_NO_HIST_START_PERIOD',
					error_msg);
		zero_fill_cells;
		cep_standard.debug('EXCEPTION: No Payroll historical data found');
		return;
	When OTHERS Then
		cep_standard.debug('EXCEPTION: Build Payroll query - Set History');
		raise;
  END;

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_PAY_Exp_Query');

END Build_Pay_Exp_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PO_Orders_Query						|
|									|
|  DESCRIPTION								|
|	Purchase orders that have not been fully invoiced or cancelled	|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_PO_Orders_Query IS
  from_clause_1		VARCHAR2(500);  -- Payment terms checkbox not checked
  from_clause_2 	VARCHAR2(500);  -- Checkbox checked and terms available
  from_clause_3         VARCHAR2(500);  -- Checkbox checked and terms are null
  where_clause		varchar2(1500);
  where_clause_1	varchar2(1500);
  where_clause_2	varchar2(1500);
  where_clause_3	varchar2(1500);
  select_clause_1	varchar2(2000);
  select_clause_2	varchar2(2000);
  select_clause_3	varchar2(2000);
  main_query_1	varchar2(3500) := null;
  main_query_2	varchar2(3500) := null;
  main_query_3	varchar2(3500) := null;

  l_amount		NUMBER;
  l_org_id		NUMBER;
  l_legal_entity_id	NUMBER;
  l_dummy		NUMBER;
  l_rate		NUMBER;
  remain_amount         NUMBER;

  l_start_date		DATE;
  l_end_date		DATE;
  l_max_end_date	DATE;
  error_flag            BOOLEAN := FALSE;
  error_msg	        FND_NEW_MESSAGES.message_text%TYPE;


  CURSOR C_period IS
    SELECT 	start_date,
           	end_date,
           	forecast_column_id
    FROM   	ce_forecast_ext_temp
    WHERE  	context_value 		= 	'A'
    AND	   	forecast_request_id 	=	CE_CASH_FCST.G_forecast_id
    AND	   	conversion_rate 	= 	CE_CASH_FCST.G_forecast_row_id;

  CURSOR C_sob(p_org_id NUMBER) IS
    SELECT 	1
    FROM 	CE_FORECAST_ORGS_V
    WHERE 	set_of_books_id 	= 	CE_CASH_FCST.G_set_of_books_id
    AND       	org_id 			= 	p_org_id;

  CURSOR C_rate(p_currency_code VARCHAR2) IS
    SELECT 	exchange_rate
    FROM   	ce_currency_rates_temp
    WHERE  	forecast_request_id 	= 	CE_CASH_FCST.G_forecast_id
    AND	   	to_currency	       	= 	CE_CASH_FCST.G_rp_forecast_currency
    AND    	currency_code       	= 	p_currency_code;

   -- CE_CASH_FCST.G_rp_project_id IS NULL
   -- CE_CASH_FCST.G_use_payment_terms = 'Y'
   CURSOR C_orders_terms(p_start_date DATE, p_end_date DATE) IS
      (SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
                amount,
                due_amount,
                term_id,
                decode(end_date,null,(trunc(l_max_end_date)-trunc(start_date)+1),
		 	 (trunc(end_date)-trunc(start_date)+1)) total_dates,
		decode(end_date, null, (nvl(decode(src.due_amount, 0,
                        0,
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))/(trunc(l_max_end_date)-trunc(start_date)+1),
                      (nvl(decode(src.due_amount, 0,
                        0,
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))/(trunc(end_date)-trunc(start_date)+1)) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_orders_terms_temp_v src
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL)
      UNION ALL
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
                null,
                null,
                null,
                null,
		decode(end_date, null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date)+1))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_no_terms_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL));

   -- CE_CASH_FCST.G_rp_project_id IS NULL
   -- CE_CASH_FCST.G_use_payment_terms = 'N'
    CURSOR C_orders(p_start_date DATE, p_end_date DATE) IS
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
		decode(end_date, null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date)+1))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_orders_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL);

   -- CE_CASH_FCST.G_rp_project_id IS NOT NULL
   -- CE_CASH_FCST.G_use_payment_terms = 'Y'
   CURSOR C_orders_terms_proj(p_start_date DATE, p_end_date DATE) IS
      (SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
                amount,
                due_amount,
                term_id,
                decode(end_date,null,(trunc(l_max_end_date)-trunc(start_date)+1),
		 	 (trunc(end_date)-trunc(start_date)+1)) total_dates,
		decode(end_date, null, (nvl(decode(src.due_amount, 0,
                        0,
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))/(trunc(l_max_end_date)-trunc(start_date)+1),
                      (nvl(decode(src.due_amount, 0,
                        0,
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))/(trunc(end_date)-trunc(start_date)+1)) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_orders_terms_temp_v src
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL)
      AND	project_id = CE_CASH_FCST.G_rp_project_id
      UNION ALL
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
                null,
                null,
                null,
                null,
		decode(end_date, null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date)+1))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_no_terms_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL)
      AND	project_id = CE_CASH_FCST.G_rp_project_id);


   -- CE_CASH_FCST.G_rp_project_id IS NOT NULL
   -- CE_CASH_FCST.G_use_payment_terms = 'Y'
   CURSOR C_orders_proj(p_start_date DATE, p_end_date DATE) IS
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
                payment_priority,
                paygroup,
                vendor_type,
		decode(end_date, null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date)+1))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_orders_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL)
      AND	project_id = CE_CASH_FCST.G_rp_project_id;

BEGIN

  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_PO_Orders_Query');

  where_clause := Get_Where_Clause||
	Add_Where('AUTHORIZATION_STATUS') || Add_Where('PAYMENT_PRIORITY') ||
	Add_Where('PAY_GROUP') || Add_Where('VENDOR_TYPE') || Add_Where('PROJECT_ID');

  IF (CE_CASH_FCST.G_use_payment_terms = 'Y') THEN
    IF (CE_CASH_FCST.G_rp_exchange_type = 'User') THEN
-- 5609517: Remove ORDERED hint as suggested by apps perf team
--	select_clause_2 := 'SELECT /*+ ORDERED USE_MERGE(src)*/ CE_FORECAST_TRX_CELLS_S.nextval,
	select_clause_2 := 'SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		decode(src.fixed_due_date, null,
		  decode(src.due_days, null,
	  	    decode(src.due_months_forward, null, src.trx_date,
	    	      (TRUNC(ADD_MONTHS(src.trx_date, src.due_months_forward),
				 ''MONTH'')
	      	        + src.due_day_of_month - 1)),
	  	    src.trx_date + src.due_days),
		  src.fixed_due_date) + '
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(-(nvl(decode(src.due_amount, 0,
                        (select nvl(src.amount,0) - sum(t.due_amount) from ap_terms_lines t where t.term_id = src.term_id),
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100)))) * ' || CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		-(nvl(decode(src.due_amount, 0,
                        (select nvl(src.amount,0) - sum(t.due_amount) from ap_terms_lines t where t.term_id = src.term_id),
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))';
    ELSE
-- 5609517: Remove ORDERED hint as suggested by apps perf team
--	select_clause_2 := 'SELECT /*+ ORDERED USE_MERGE(src)*/ CE_FORECAST_TRX_CELLS_S.nextval,
	select_clause_2 := 'SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		decode(src.fixed_due_date, null,
		  decode(src.due_days, null,
	  	    decode(src.due_months_forward, null, src.trx_date,
	    	      (TRUNC(ADD_MONTHS(src.trx_date, src.due_months_forward),
				 ''MONTH'')
	      	        + src.due_day_of_month - 1)),
	  	    src.trx_date + src.due_days),
		  src.fixed_due_date) + '
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(-(nvl(decode(src.due_amount, 0,
                        (select nvl(src.amount,0) - sum(t.due_amount) from ap_terms_lines t where t.term_id = src.term_id),
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))) * curr.exchange_rate)'
				||','||CE_CASH_FCST.G_precision||'),
		-(nvl(decode(src.due_amount, 0,
                        (select nvl(src.amount,0) - sum(t.due_amount) from ap_terms_lines t where t.term_id = src.term_id),
			src.due_amount),(nvl(src.amount,0) * (nvl(src.due_percent,100)/100))))';
    END IF;

    select_clause_3 := Get_Select_Clause;

    from_clause_2 := Get_From_Clause('ce_po_fc_orders_terms_v');
    from_clause_3 := Get_From_Clause('ce_po_fc_orders_no_terms_v');

    where_clause_2 := where_clause || ' AND
      decode(src.fixed_due_date, null,
	decode(src.due_days, null,
	  decode(src.due_months_forward, null, src.trx_date,
	    (TRUNC(ADD_MONTHS(src.trx_date, src.due_months_forward), ''MONTH'')
	      + src.due_day_of_month - 1)),
	  src.trx_date + src.due_days),
	src.fixed_due_date) BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
      ' AND nvl(src.amount,0) <> 0';

    where_clause_3 := where_clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);

    main_query_2 := select_clause_2 || from_clause_2 || where_clause_2;
    main_query_3 := select_clause_3 || from_clause_3 || where_clause_3;

    Execute_Main_Query (main_query_2);
    Execute_Main_Query (main_query_3);
  ELSE		-- G_use_payment_terms = 'N'
    select_clause_1 := Get_Select_Clause;

    from_clause_1 := Get_From_Clause('ce_po_fc_orders_v');

    where_clause_1 := where_clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);

    main_query_1 := select_clause_1 || from_clause_1 || where_clause_1;

    Execute_Main_Query (main_query_1);
  END IF;

  IF (CE_CASH_FCST.G_include_temp_labor_flag = 'Y') THEN

     populate_aging_buckets;

     SELECT 	max(end_date)
     INTO       l_max_end_date
     FROM   	ce_forecast_ext_temp
     WHERE  	context_value 		= 	'A'
     AND	forecast_request_id 	=	CE_CASH_FCST.G_forecast_id
     AND	conversion_rate 	= 	CE_CASH_FCST.G_forecast_row_id;
     cep_standard.debug('l_max_end_date = ' || to_char(l_max_end_date, 'DD-MON-YYYY'));

     IF (CE_CASH_FCST.G_rp_project_id IS NULL) THEN

       IF (CE_CASH_FCST.G_use_payment_terms = 'Y') THEN

       cep_standard.debug('PROJECT_ID IS NULL');
       cep_standard.debug('USE_PAYMENT_TERMS IS Y');

          FOR C_rec IN C_period LOOP
            FOR C_req_rec in C_orders_terms(C_rec.start_date, C_rec.end_date) LOOP
             IF (C_req_rec.start_date < C_rec.start_date) THEN
              IF (C_req_rec.end_date < C_rec.end_date) THEN
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_req_rec.end_date);
              ELSE
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_rec.end_date);
 	      END IF;
             ELSE
               IF (C_req_rec.end_date > C_rec.end_date) THEN
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_rec.end_date);
               ELSE
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_req_rec.end_date);
 	       END IF;
             END IF;
             cep_standard.debug('l_start_date = ' || to_char(l_start_date, 'DD-MON-YYYY'));
             cep_standard.debug('l_end_date = ' || to_char(l_end_date, 'DD-MON-YYYY'));

/* In the case where we use terms and due amount is 0,
   we want to sum the term amounts and subtract them from the original
   source amount. Since this is too complex to perform within the cursor
   we do it within the FOR loop */

             if C_req_rec.due_amount = 0 THEN
               select nvl(C_req_rec.amount,0) - sum(t.due_amount)
		INTO remain_amount
		from ap_terms_lines t
		where t.term_id = C_req_rec.term_id;

                cep_standard.debug('remain_amount = ' || to_char(remain_amount));

                l_amount := remain_amount/C_req_rec.total_dates * (l_end_date - l_start_date + 1);

            end if;

             l_amount := C_req_rec.per_day_amount * (l_end_date - l_start_date + 1);


             cep_standard.debug('per_day_amount = ' || to_char(C_req_rec.per_day_amount));
             cep_standard.debug('l_amount = ' || to_char(l_amount));

              IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
                 C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('currency_code');


              IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
                 C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('authorization_status');


              IF(CE_CASH_FCST.G_payment_priority IS NOT NULL AND
                 C_req_rec.payment_priority <> CE_CASH_FCST.G_payment_priority ) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('payment_priority ');


              IF(CE_CASH_FCST.G_pay_group IS NOT NULL AND
                 C_req_rec.paygroup <> CE_CASH_FCST.G_pay_group) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('paygroup');


              IF(CE_CASH_FCST.G_vendor_type IS NOT NULL AND
                 C_req_rec.vendor_type <> CE_CASH_FCST.G_vendor_type) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('vendor_type');

              SELECT to_number(ORGANIZATION_ID)
              INTO l_legal_entity_id
              FROM hr_operating_units
              WHERE organization_id = C_req_rec.org_id;
              cep_standard.debug('legal_entity_id');


              IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
                 (nvl(C_req_rec.org_id,CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
               l_amount := 0;
              END IF;
              cep_standard.debug('org_id');


              IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
                 CE_CASH_FCST.G_set_of_books_id <> -1) THEN
                OPEN C_sob(C_req_rec.org_id);
                FETCH C_sob INTO l_dummy;
                IF C_sob%NOTFOUND THEN
                 CLOSE C_sob;
                 l_amount := 0;
                END IF;
                CLOSE C_sob;
              END IF;
              cep_standard.debug('set_of_books_id');

             IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
                 CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
               OPEN C_rate(C_req_rec.currency_code);
               FETCH C_rate INTO l_rate;
               IF C_rate%NOTFOUND THEN
                 l_rate := 1;
               END IF;
               CLOSE C_rate;
             ELSIF (CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
               l_rate := CE_CASH_FCST.G_rp_exchange_rate;
             ELSE
               l_rate := 1;
             END IF;
             cep_standard.debug('exchange_rate');


             IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
                 IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	             l_amount := 0;
                 END IF;
             END IF;
             cep_standard.debug('amount_threshold');

             IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
                 CE_CASH_FCST.G_invalid_overdue_row)THEN
	           l_amount := 0;
             END IF;
             cep_standard.debug('OVERDUE_COLUMN');

             IF (l_amount <> 0) THEN
                IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

          	     UPDATE	ce_forecasts
	             SET        error_status = 'X'
	             WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	             FND_MESSAGE.set_name('CE', 'CE_FC_POP_NO_END_DATE');
	             error_msg := FND_MESSAGE.get;
	             CE_FORECAST_ERRORS_PKG.insert_row(
		              CE_CASH_FCST.G_forecast_id,
		              CE_CASH_FCST.G_rp_forecast_header_id,
		              CE_CASH_FCST.G_forecast_row_id,
		              'CE_FC_POP_NO_END_DATE',
		               error_msg);
                     error_flag := TRUE;
                END IF;
                cep_standard.debug('error_message');

               Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount), C_rec.forecast_column_id);
             END IF;
           END LOOP;
         END LOOP;

         clear_aging_buckets;
         zero_fill_cells;

        ELSE
         cep_standard.debug('PROJECT_ID IS NULL');
         cep_standard.debug('USE_PAYMENT_TERMS IS N');

          FOR C_rec IN C_period LOOP
            FOR C_req_rec in C_orders(C_rec.start_date, C_rec.end_date) LOOP
             IF (C_req_rec.start_date < C_rec.start_date) THEN
              IF (C_req_rec.end_date < C_rec.end_date) THEN
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_req_rec.end_date);
              ELSE
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_rec.end_date);
 	      END IF;
             ELSE
               IF (C_req_rec.end_date > C_rec.end_date) THEN
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_rec.end_date);
               ELSE
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_req_rec.end_date);
 	       END IF;
             END IF;
             cep_standard.debug('l_start_date = ' || to_char(l_start_date, 'DD-MON-YYYY'));
             cep_standard.debug('l_end_date = ' || to_char(l_end_date, 'DD-MON-YYYY'));

              l_amount := C_req_rec.per_day_amount * (l_end_date - l_start_date + 1);

              cep_standard.debug('per_day_amount = ' || to_char(C_req_rec.per_day_amount));
              cep_standard.debug('l_amount = ' || to_char(l_amount));

              IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
                 C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('currency_code');


              IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
                 C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('authorization_status');


              IF(CE_CASH_FCST.G_payment_priority IS NOT NULL AND
                 C_req_rec.payment_priority <> CE_CASH_FCST.G_payment_priority ) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('payment_priority ');


              IF(CE_CASH_FCST.G_pay_group IS NOT NULL AND
                 C_req_rec.paygroup <> CE_CASH_FCST.G_pay_group) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('paygroup');


              IF(CE_CASH_FCST.G_vendor_type IS NOT NULL AND
                 C_req_rec.vendor_type <> CE_CASH_FCST.G_vendor_type) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('vendor_type');

              SELECT to_number(ORGANIZATION_ID)
              INTO l_legal_entity_id
              FROM hr_operating_units
              WHERE organization_id = C_req_rec.org_id;
              cep_standard.debug('legal_entity_id');


              IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
                 (nvl(C_req_rec.org_id,CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
               l_amount := 0;
              END IF;
              cep_standard.debug('org_id');


              IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
                 CE_CASH_FCST.G_set_of_books_id <> -1) THEN
                OPEN C_sob(C_req_rec.org_id);
                FETCH C_sob INTO l_dummy;
                IF C_sob%NOTFOUND THEN
                 CLOSE C_sob;
                 l_amount := 0;
                END IF;
                CLOSE C_sob;
              END IF;
              cep_standard.debug('set_of_books_id');

              IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
                 CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
               OPEN C_rate(C_req_rec.currency_code);
               FETCH C_rate INTO l_rate;
               IF C_rate%NOTFOUND THEN
                 l_rate := 1;
               END IF;
               CLOSE C_rate;
              ELSIF (CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
                l_rate := CE_CASH_FCST.G_rp_exchange_rate;
              ELSE
                l_rate := 1;
              END IF;
              cep_standard.debug('exchange_rate');

              IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
                 IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	             l_amount := 0;
                 END IF;
              END IF;
              cep_standard.debug('amount_threshold');

              IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
                 CE_CASH_FCST.G_invalid_overdue_row)THEN
	           l_amount := 0;
              END IF;
              cep_standard.debug('OVERDUE_COLUMN');

              IF (l_amount <> 0) THEN
                 IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

          	     UPDATE	ce_forecasts
	             SET        error_status = 'X'
	             WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	             FND_MESSAGE.set_name('CE', 'CE_FC_POP_NO_END_DATE');
	             error_msg := FND_MESSAGE.get;
	             CE_FORECAST_ERRORS_PKG.insert_row(
		              CE_CASH_FCST.G_forecast_id,
		              CE_CASH_FCST.G_rp_forecast_header_id,
		              CE_CASH_FCST.G_forecast_row_id,
		              'CE_FC_POP_NO_END_DATE',
		               error_msg);
                     error_flag := TRUE;
                 END IF;
                 cep_standard.debug('error_message');

                Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount), C_rec.forecast_column_id);
             END IF;
           END LOOP;
          END LOOP;
          clear_aging_buckets;
          zero_fill_cells;
        END IF;
     ELSE
        IF (CE_CASH_FCST.G_use_payment_terms = 'Y') THEN

        cep_standard.debug('PROJECT_ID IS NOT NULL');
        cep_standard.debug('USE_PAYMENT_TERMS IS Y');

          FOR C_rec IN C_period LOOP
            FOR C_req_rec in C_orders_terms_proj(C_rec.start_date, C_rec.end_date) LOOP
             IF (C_req_rec.start_date < C_rec.start_date) THEN
              IF (C_req_rec.end_date < C_rec.end_date) THEN
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_req_rec.end_date);
              ELSE
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_rec.end_date);
 	      END IF;
             ELSE
               IF (C_req_rec.end_date > C_rec.end_date) THEN
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_rec.end_date);
               ELSE
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_req_rec.end_date);
 	       END IF;
             END IF;
             cep_standard.debug('l_start_date_proj = ' || to_char(l_start_date, 'DD-MON-YYYY'));
             cep_standard.debug('l_end_date_proj = ' || to_char(l_end_date, 'DD-MON-YYYY'));

/* In the case where we use terms and due amount is 0,
   we want to sum the term amounts and subtract them from the original
   source amount. Since this is too complex to perform within the cursor
   we do it within the FOR loop */

             if C_req_rec.due_amount = 0 THEN
               select nvl(C_req_rec.amount,0) - sum(t.due_amount)
		INTO remain_amount
		from ap_terms_lines t
		where t.term_id = C_req_rec.term_id;

                cep_standard.debug('remain_amount = ' || to_char(remain_amount));

                l_amount := remain_amount/C_req_rec.total_dates * (l_end_date - l_start_date + 1);

            end if;

             l_amount := C_req_rec.per_day_amount * (l_end_date - l_start_date + 1);

             cep_standard.debug('per_day_amount_proj = ' || to_char(C_req_rec.per_day_amount));
             cep_standard.debug('l_amount_proj = ' || to_char(l_amount));

              IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
                 C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('currency_code_proj');


              IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
                 C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('authorization_status_proj');


              IF(CE_CASH_FCST.G_payment_priority IS NOT NULL AND
                 C_req_rec.payment_priority <> CE_CASH_FCST.G_payment_priority ) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('payment_priority_proj');


              IF(CE_CASH_FCST.G_pay_group IS NOT NULL AND
                 C_req_rec.paygroup <> CE_CASH_FCST.G_pay_group) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('paygroup_proj');


              IF(CE_CASH_FCST.G_vendor_type IS NOT NULL AND
                 C_req_rec.vendor_type <> CE_CASH_FCST.G_vendor_type) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('vendor_type_proj');

              SELECT to_number(ORGANIZATION_ID)
              INTO l_legal_entity_id
              FROM hr_operating_units
              WHERE organization_id = C_req_rec.org_id;
              cep_standard.debug('legal_entity_id_proj');


              IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
                 (nvl(C_req_rec.org_id,CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
               l_amount := 0;
              END IF;
              cep_standard.debug('org_id_proj');

              IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
                 CE_CASH_FCST.G_set_of_books_id <> -1) THEN
                OPEN C_sob(C_req_rec.org_id);
                FETCH C_sob INTO l_dummy;
                IF C_sob%NOTFOUND THEN
                 CLOSE C_sob;
                 l_amount := 0;
                END IF;
                CLOSE C_sob;
              END IF;
              cep_standard.debug('set_of_books_id_proj');

              IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
                 CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
               OPEN C_rate(C_req_rec.currency_code);
               FETCH C_rate INTO l_rate;
               IF C_rate%NOTFOUND THEN
                 l_rate := 1;
               END IF;
               CLOSE C_rate;
              ELSIF (CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
                l_rate := CE_CASH_FCST.G_rp_exchange_rate;
              ELSE
                l_rate := 1;
              END IF;
              cep_standard.debug('exchange_rate_proj');

              IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
                 IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	             l_amount := 0;
                 END IF;
              END IF;
              cep_standard.debug('amount_threshold_proj');

              IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
                 CE_CASH_FCST.G_invalid_overdue_row)THEN
	           l_amount := 0;
              END IF;
              cep_standard.debug('OVERDUE_COLUMN_proj');

              IF (l_amount <> 0) THEN
                 IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

          	     UPDATE	ce_forecasts
	             SET        error_status = 'X'
	             WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	             FND_MESSAGE.set_name('CE', 'CE_FC_POP_NO_END_DATE');
	             error_msg := FND_MESSAGE.get;
	             CE_FORECAST_ERRORS_PKG.insert_row(
		              CE_CASH_FCST.G_forecast_id,
		              CE_CASH_FCST.G_rp_forecast_header_id,
		              CE_CASH_FCST.G_forecast_row_id,
		              'CE_FC_POP_NO_END_DATE',
		               error_msg);
                     error_flag := TRUE;
                 END IF;
                 cep_standard.debug('error_message_proj');

                Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount), C_rec.forecast_column_id);
              END IF;
            END LOOP;
          END LOOP;
          clear_aging_buckets;
          zero_fill_cells;
        ELSE

        cep_standard.debug('PROJECT_ID IS NOT NULL');
        cep_standard.debug('USE_PAYMENT_TERMS IS N');

           FOR C_rec IN C_period LOOP
            FOR C_req_rec in C_orders_proj(C_rec.start_date, C_rec.end_date) LOOP
             IF (C_req_rec.start_date < C_rec.start_date) THEN
              IF (C_req_rec.end_date < C_rec.end_date) THEN
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_req_rec.end_date);
              ELSE
                l_start_date := trunc(C_rec.start_date);
	        l_end_date := trunc(C_rec.end_date);
 	      END IF;
             ELSE
               IF (C_req_rec.end_date > C_rec.end_date) THEN
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_rec.end_date);
               ELSE
                 l_start_date := trunc(C_req_rec.start_date);
	         l_end_date := trunc(C_req_rec.end_date);
 	       END IF;
             END IF;
             cep_standard.debug('l_start_date_proj = ' || to_char(l_start_date, 'DD-MON-YYYY'));
             cep_standard.debug('l_end_date_proj = ' || to_char(l_end_date, 'DD-MON-YYYY'));

             l_amount := C_req_rec.per_day_amount * (l_end_date - l_start_date + 1);

             cep_standard.debug('per_day_amount_proj = ' || to_char(C_req_rec.per_day_amount));
             cep_standard.debug('l_amount_proj = ' || to_char(l_amount));

              IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
                 C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('currency_code_proj');


              IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
                 C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('authorization_status_proj');


              IF(CE_CASH_FCST.G_payment_priority IS NOT NULL AND
                 C_req_rec.payment_priority <> CE_CASH_FCST.G_payment_priority ) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('payment_priority_proj');


              IF(CE_CASH_FCST.G_pay_group IS NOT NULL AND
                 C_req_rec.paygroup <> CE_CASH_FCST.G_pay_group) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('paygroup_proj');


              IF(CE_CASH_FCST.G_vendor_type IS NOT NULL AND
                 C_req_rec.vendor_type <> CE_CASH_FCST.G_vendor_type) THEN
                l_amount := 0;
              END IF;
              cep_standard.debug('vendor_type_proj');

              SELECT to_number(ORGANIZATION_ID)
              INTO l_legal_entity_id
              FROM hr_operating_units
              WHERE organization_id = C_req_rec.org_id;
              cep_standard.debug('legal_entity_id_proj');

              IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
                 (nvl(C_req_rec.org_id,CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
               l_amount := 0;
              END IF;
              cep_standard.debug('org_id_proj');

              IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
                 CE_CASH_FCST.G_set_of_books_id <> -1) THEN
                OPEN C_sob(C_req_rec.org_id);
                FETCH C_sob INTO l_dummy;
                IF C_sob%NOTFOUND THEN
                 CLOSE C_sob;
                 l_amount := 0;
                END IF;
                CLOSE C_sob;
              END IF;
              cep_standard.debug('set_of_books_id_proj');

              IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
                 CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
               OPEN C_rate(C_req_rec.currency_code);
               FETCH C_rate INTO l_rate;
               IF C_rate%NOTFOUND THEN
                 l_rate := 1;
               END IF;
               CLOSE C_rate;
              ELSIF (CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
                l_rate := CE_CASH_FCST.G_rp_exchange_rate;
              ELSE
                l_rate := 1;
              END IF;
              cep_standard.debug('exchange_rate_proj');

              IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
                 IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	             l_amount := 0;
                 END IF;
              END IF;
              cep_standard.debug('amount_threshold_proj');

              IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
                 CE_CASH_FCST.G_invalid_overdue_row)THEN
	           l_amount := 0;
              END IF;
              cep_standard.debug('OVERDUE_COLUMN_proj');

              IF (l_amount <> 0) THEN
                IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

          	     UPDATE	ce_forecasts
	             SET        error_status = 'X'
	             WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	             FND_MESSAGE.set_name('CE', 'CE_FC_POP_NO_END_DATE');
	             error_msg := FND_MESSAGE.get;
	             CE_FORECAST_ERRORS_PKG.insert_row(
		              CE_CASH_FCST.G_forecast_id,
		              CE_CASH_FCST.G_rp_forecast_header_id,
		              CE_CASH_FCST.G_forecast_row_id,
		              'CE_FC_POP_NO_END_DATE',
		               error_msg);
                     error_flag := TRUE;
                 END IF;
                 cep_standard.debug('error_message_proj');

                Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount), C_rec.forecast_column_id);
              END IF;
           END LOOP;
          END LOOP;
          clear_aging_buckets;
          zero_fill_cells;
     END IF;
   END IF;
END IF;
  cep_standard.debug('<<ce_csh_fcST_POP.Build_PO_Orders_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_PO_Orders_Query');
		raise;
END Build_PO_Orders_Query;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PO_Req_Query						|
|									|
|  DESCRIPTION								|
|	Requisitions made but not fully ordered or cancelled		|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_PO_Req_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(2000) := null;

  l_amount		NUMBER;
  l_legal_entity_id	NUMBER;
  l_dummy		NUMBER;
  l_rate		NUMBER;

  l_start_date		DATE;
  l_end_date		DATE;
  l_max_end_date	DATE;

  error_flag            BOOLEAN := FALSE;
  error_msg	        FND_NEW_MESSAGES.message_text%TYPE;


  CURSOR C_period IS
    SELECT 	start_date,
           	end_date,
           	forecast_column_id
    FROM   	ce_forecast_ext_temp
    WHERE  	context_value 		= 	'A'
    AND	   	forecast_request_id 	=	CE_CASH_FCST.G_forecast_id
    AND	   	conversion_rate 	= 	CE_CASH_FCST.G_forecast_row_id;


  CURSOR C_sob(p_org_id NUMBER) IS
    SELECT 	1
    FROM 	CE_FORECAST_ORGS_V
    WHERE 	set_of_books_id 	= 	CE_CASH_FCST.G_set_of_books_id
    AND       	org_id 			= 	p_org_id;

  CURSOR C_rate(p_currency_code VARCHAR2) IS
    SELECT 	exchange_rate
    FROM   	ce_currency_rates_temp
    WHERE  	forecast_request_id 	= 	CE_CASH_FCST.G_forecast_id
    AND	   	to_currency	       	= 	CE_CASH_FCST.G_rp_forecast_currency
    AND    	currency_code       	= 	p_currency_code;

   CURSOR C_requisitions(p_start_date DATE, p_end_date DATE) IS
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
		decode(end_date, null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date)+1))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_requisitions_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL);


   CURSOR C_requisitions_proj(p_start_date DATE, p_end_date DATE) IS
      SELECT 	reference_id,
		currency_code,
                org_id,
                status,
		decode(trunc(end_date), null, (nvl(amount,0)/(trunc(l_max_end_date)-trunc(start_date)+1)),
                      (nvl(amount,0)/(trunc(end_date)-trunc(start_date+1)))) per_day_amount,
		start_date,
		nvl(end_date, l_max_end_date)end_date,
                end_date trx_end_date
      FROM	ce_po_fc_requisitions_temp_v
      WHERE       start_date <= p_end_date
      AND         (end_date >= p_start_date
                  OR end_date is NULL)
      AND       project_id = CE_CASH_FCST.G_rp_project_id;



BEGIN

  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_PO_Req_Query');

  select_clause := Get_Select_Clause;
  cep_standard.debug('Built Select Clause');

  from_clause := Get_From_Clause('ce_po_fc_requisitions_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause ||  '
	AND     src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('AUTHORIZATION_STATUS') || Add_Where('PROJECT_ID');


  cep_standard.debug('Built Where Clause');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  cep_standard.debug('Execute_Main_Query');

  IF (CE_CASH_FCST.G_include_temp_labor_flag = 'Y') THEN

      populate_aging_buckets;

      SELECT 	trunc(max(end_date))
      INTO      l_max_end_date
      FROM   	ce_forecast_ext_temp
      WHERE  	context_value 		= 	'A'
      AND	forecast_request_id 	=	CE_CASH_FCST.G_forecast_id
      AND	conversion_rate 	= 	CE_CASH_FCST.G_forecast_row_id;
      cep_standard.debug('l_max_end_date = ' || to_char(l_max_end_date, 'DD-MON-YYYY'));

    IF (CE_CASH_FCST.G_rp_project_id IS NULL) THEN
    cep_standard.debug('PROJECT_ID IS NULL');

      FOR C_rec IN C_period LOOP
        FOR C_req_rec in C_requisitions(C_rec.start_date, C_rec.end_date) LOOP
         IF (C_req_rec.start_date < C_rec.start_date) THEN
          IF (C_req_rec.end_date < C_rec.end_date) THEN
            l_start_date := trunc(C_rec.start_date);
	    l_end_date := trunc(C_req_rec.end_date);
          ELSE
            l_start_date := trunc(C_rec.start_date);
	    l_end_date := trunc(C_rec.end_date);
 	  END IF;
        ELSE
          IF (C_req_rec.end_date > C_rec.end_date) THEN
            l_start_date := trunc(C_req_rec.start_date);
	    l_end_date := trunc(C_rec.end_date);
          ELSE
            l_start_date := trunc(C_req_rec.start_date);
	    l_end_date := trunc(C_req_rec.end_date);
 	  END IF;
        END IF;
        cep_standard.debug('l_start_date = ' || to_char(l_start_date, 'DD-MON-YYYY'));
        cep_standard.debug('l_end_date = ' || to_char(l_end_date, 'DD-MON-YYYY'));

        l_amount := C_req_rec.per_day_amount * 	(l_end_date - l_start_date + 1);

        cep_standard.debug('per_day_amount = ' || to_char(C_req_rec.per_day_amount));
        cep_standard.debug('l_amount = ' || to_char(l_amount));

        IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
            C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('currency_code');

        IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
            C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('authorization_status');

        SELECT to_number(ORGANIZATION_ID)
        INTO l_legal_entity_id
        FROM hr_operating_units
        WHERE organization_id = C_req_rec.org_id;
        cep_standard.debug('legal_entity_id');

        IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
            (nvl(C_req_rec.org_id, CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('org_id');

        IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
            CE_CASH_FCST.G_set_of_books_id <> -1) THEN
          OPEN C_sob(C_req_rec.org_id);
          FETCH C_sob INTO l_dummy;
          IF C_sob%NOTFOUND THEN
            CLOSE C_sob;
            l_amount := 0;
          END IF;
          CLOSE C_sob;
        END IF;
        cep_standard.debug('set_of_books_id');

        IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
            CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
          OPEN C_rate(C_req_rec.currency_code);
          FETCH C_rate INTO l_rate;
          IF C_rate%NOTFOUND THEN
            l_rate := 1;
          END IF;
          CLOSE C_rate;
        ELSIF( CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
          l_rate := CE_CASH_FCST.G_rp_exchange_rate;
        ELSE
          l_rate := 1;
        END IF;
        cep_standard.debug('exchange_rate');

        IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
            IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	        l_amount := 0;
             END IF;
        END IF;
        cep_standard.debug('amount_threshold');

        IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
            CE_CASH_FCST.G_invalid_overdue_row)THEN
	      l_amount := 0;
        END IF;
        cep_standard.debug('OVERDUE_COLUMN');

        IF (l_amount <> 0) THEN
            IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

	       UPDATE	ce_forecasts
	       SET		error_status = 'X'
	       WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	       FND_MESSAGE.set_name('CE', 'CE_FC_POR_NO_END_DATE');
	       error_msg := FND_MESSAGE.get;
	       CE_FORECAST_ERRORS_PKG.insert_row(
		           CE_CASH_FCST.G_forecast_id,
		           CE_CASH_FCST.G_rp_forecast_header_id,
		           CE_CASH_FCST.G_forecast_row_id,
		           'CE_FC_POR_NO_END_DATE',
		           error_msg);
               error_flag := TRUE;
           END IF;
           cep_standard.debug('error_message');

           Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount),  C_rec.forecast_column_id);
        END IF;
        cep_standard.debug('INSERT_FCAST_CELL');

        END LOOP;
      END LOOP;

      clear_aging_buckets;
      zero_fill_cells;

  ELSE
      cep_standard.debug('PROJECT_ID NOT NULL');

      FOR C_rec IN C_period LOOP
        FOR C_req_rec in C_requisitions_proj(C_rec.start_date, C_rec.end_date) LOOP
         IF (C_req_rec.start_date < C_rec.start_date) THEN
          IF (C_req_rec.end_date < C_rec.end_date) THEN
            l_start_date := trunc(C_rec.start_date);
	    l_end_date := trunc(C_req_rec.end_date);
          ELSE
            l_start_date := trunc(C_rec.start_date);
	    l_end_date := trunc(C_rec.end_date);
 	  END IF;
        ELSE
          IF (C_req_rec.end_date > C_rec.end_date) THEN
            l_start_date := trunc(C_req_rec.start_date);
	    l_end_date := trunc(C_rec.end_date);
          ELSE
            l_start_date := trunc(C_req_rec.start_date);
	    l_end_date := trunc(C_req_rec.end_date);
 	  END IF;
        END IF;

        cep_standard.debug('l_start_date_proj = ' || to_char(l_start_date, 'DD-MON-YYYY'));
        cep_standard.debug('l_end_date_proj = ' || to_char(l_end_date, 'DD-MON-YYYY'));

        l_amount := C_req_rec.per_day_amount * 	(l_end_date - l_start_date + 1);

        cep_standard.debug('per_day_amount_proj = ' || to_char(C_req_rec.per_day_amount));
        cep_standard.debug('l_amount_proj = ' || to_char(l_amount));

        IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
            C_req_rec.currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('currency_code_proj');

        IF(CE_CASH_FCST.G_authorization_status IS NOT NULL AND
            C_req_rec.status <> CE_CASH_FCST.G_authorization_status) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('authorization_status_proj');

        SELECT to_number(ORGANIZATION_ID)
        INTO l_legal_entity_id
        FROM hr_operating_units
        WHERE organization_id = C_req_rec.org_id;
        cep_standard.debug('legal_entity_id_proj');

        IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
            (nvl(C_req_rec.org_id, CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
          l_amount := 0;
        END IF;
        cep_standard.debug('org_id_proj');

        IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
            CE_CASH_FCST.G_set_of_books_id <> -1) THEN
          OPEN C_sob(C_req_rec.org_id);
          FETCH C_sob INTO l_dummy;
          IF C_sob%NOTFOUND THEN
            CLOSE C_sob;
            l_amount := 0;
          END IF;
          CLOSE C_sob;
        END IF;
        cep_standard.debug('set_of_books_id_proj');

        IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
            CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
          OPEN C_rate(C_req_rec.currency_code);
          FETCH C_rate INTO l_rate;
          IF C_rate%NOTFOUND THEN
            l_rate := 1;
          END IF;
          CLOSE C_rate;
        ELSIF( CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
          l_rate := CE_CASH_FCST.G_rp_exchange_rate;
        ELSE
          l_rate := 1;
        END IF;
        cep_standard.debug('exchange_rate_proj');

        IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
            IF (abs(l_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	        l_amount := 0;
             END IF;
        END IF;
        cep_standard.debug('amount_threshold_proj');

        IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
            CE_CASH_FCST.G_invalid_overdue_row)THEN
	      l_amount := 0;
        END IF;
        cep_standard.debug('OVERDUE_COLUMN_proj');

        IF (l_amount <> 0) THEN
           IF (C_req_rec.trx_end_date IS NULL and error_flag = FALSE) THEN

	       UPDATE	ce_forecasts
	       SET		error_status = 'X'
	       WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;

	       FND_MESSAGE.set_name('CE', 'CE_FC_POR_NO_END_DATE');
	       error_msg := FND_MESSAGE.get;
	       CE_FORECAST_ERRORS_PKG.insert_row(
		           CE_CASH_FCST.G_forecast_id,
		           CE_CASH_FCST.G_rp_forecast_header_id,
		           CE_CASH_FCST.G_forecast_row_id,
		           'CE_FC_POR_NO_END_DATE',
		           error_msg);
               error_flag := TRUE;
           END IF;
           cep_standard.debug('error_message_proj');

          Insert_Fcast_Cell(C_req_rec.reference_id, C_req_rec.currency_code, l_legal_entity_id, null, null, -(l_amount*l_rate), -(l_amount),  C_rec.forecast_column_id);
        cep_standard.debug('INSERT_FCAST_CELL_proj');
        END IF;

        END LOOP;
      END LOOP;

      clear_aging_buckets;
      zero_fill_cells;

    END IF;
  END IF;

cep_standard.debug('<<ce_csh_fcST_POP.Build_PO_Req_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_PO_req_Query');
		raise;
END Build_PO_Req_Query ;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_Sales_Fcst_Query						|
|									|
|  DESCRIPTION								|
|	Sales forecasted to be made within a certain accounting period	|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		  Bidemi Carrol			|
|       21-MAY-1998     OSM Integration   Byung-Hyun Chung              |
 --------------------------------------------------------------------- */
PROCEDURE Build_Sales_Fcst_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  view_name	VARCHAR2(50);
  main_query	varchar2(3500) := null;
BEGIN
  cep_standard.debug('>>Build_Sales_Fcst_Query');
  select_clause := Get_Select_Clause;
  cep_standard.debug('Built Select Clause');

  from_clause := Get_From_Clause ('ce_as_fc_sales_fcst_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
        ' AND     NVL(src.win_probability, 0) >= ' ||to_char(CE_CASH_FCST.G_win_probability)||
                Add_Where('CHANNEL_CODE') || Add_Where('SALES_STAGE_ID') || Add_Where('SALES_FORECAST_STATUS');

  cep_standard.debug('Built Where Clause');


  main_query := select_clause || from_clause || where_clause;
  Execute_Main_Query (main_query);

  cep_standard.debug('<<ce_csh_fcST_POP.Build_Sales_Fcst_Query');
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_Sales_Fcst_Query');
    raise;
END Build_Sales_Fcst_Query ;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_Sales_Order_Query						|
|									|
|  DESCRIPTION								|
|	Sales orders that have not been fully invoiced and/or paid	|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_Sales_Order_Query IS
  from_clause_1         VARCHAR2(500);  -- Payment terms checkbox not checked
  from_clause_2         VARCHAR2(500);  -- Checkbox checked and terms available
  from_clause_3         VARCHAR2(500);  -- Checkbox checked and terms are null
  where_clause          varchar2(2000);
  where_clause_1        varchar2(2000);
  where_clause_2        varchar2(2000);
  where_clause_3        varchar2(2000);
  select_clause_1       varchar2(2000);
  select_clause_2       varchar2(2000);
  select_clause_3       varchar2(2000);
  main_query_1  varchar2(3500) := null;
  main_query_2  varchar2(3500) := null;
  main_query_3  varchar2(3500) := null;
BEGIN
  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_Sales_Order_Query');

  --select_clause := Get_Select_Clause;
  --cep_standard.debug('Built Select Clause');

  from_clause_1 := Get_From_Clause('ce_so_fc_orders_v');
  from_clause_2 := Get_From_Clause('ce_so_fc_orders_terms_v');
  from_clause_3 := Get_From_Clause('ce_so_fc_orders_no_terms_v');
  cep_standard.debug('Built From Clause');

  where_clause := Get_Where_Clause ||
                  Add_Where('CUSTOMER_PROFILE_CLASS_ID') || Add_Where('PROJECT_ID')
                  || Add_Where('ORDER_TYPE_ID');

  IF( nvl(CE_CASH_FCST.G_order_status,'A') = 'O') THEN
    where_clause := where_clause || '
	AND     NVL(src.booked_flag, ''N'') = ''N'' ';
  ELSIF( nvl(CE_CASH_FCST.G_order_status,'A') = 'B')THEN
    where_clause := where_clause || '
        AND     NVL(src.booked_flag, ''N'') = ''Y'' ';
  END IF;

  IF (CE_CASH_FCST.G_use_payment_terms = 'Y') THEN
     IF(CE_CASH_FCST.G_order_date_type = 'R')THEN
       IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
         select_clause_2 := '
	   SELECT /*+ USE_MERGE(o3,hr_ou) +*/ CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
           	decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_requested,
                                  (TRUNC(ADD_MONTHS(src.date_requested, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1)),
                           src.date_requested + src.term_due_days),
                   src.term_due_date) + '
          ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0) * (nvl(src.relative_amount,100)/100)
                        *'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		nvl(src.amount,0) * (nvl(src.relative_amount,100)/100)';
       ELSE
      	 select_clause_2 := '
	   SELECT /*+ USE_MERGE(o3,hr_ou) +*/ CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
           	decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_requested,
                                  (TRUNC(ADD_MONTHS(src.date_requested, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1)),
                           src.date_requested + src.term_due_days),
                   src.term_due_date) + '
          ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0) * (nvl(src.relative_amount,100)/100) * curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		nvl(src.amount,0) * (nvl(src.relative_amount,100)/100)';
       END IF;

       where_clause_2 := where_clause || ' AND
           decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_requested,
                                  (TRUNC(ADD_MONTHS(src.date_requested, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1)),
                           src.date_requested + src.term_due_days),
                   src.term_due_date) BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
    ELSE
       IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
       	 select_clause_2 := '
	   SELECT /*+ USE_MERGE(o3,hr_ou) +*/ CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
           	decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_ordered,
                                  TRUNC(ADD_MONTHS(src.date_ordered, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1),
                           src.date_ordered + src.term_due_days),
                   src.term_due_date) + '
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*(nvl(src.relative_amount,100)/100)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		nvl(src.amount,0) * (nvl(src.relative_amount,100)/100)';
       ELSE
      	 select_clause_2 := '
	   SELECT /*+ USE_MERGE(o3,hr_ou) +*/ CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
           	decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_ordered,
                                  TRUNC(ADD_MONTHS(src.date_ordered, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1),
                           src.date_ordered + src.term_due_days),
                   src.term_due_date) + '
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*(nvl(src.relative_amount,100)/100)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		nvl(src.amount,0) * (nvl(src.relative_amount,100)/100)';
       END IF;
       where_clause_2 := where_clause || ' AND
           decode(src.term_due_date, null,
                   decode(src.term_due_days, null,
                           decode(src.term_due_months_forward, null, src.date_ordered,
                                  TRUNC(ADD_MONTHS(src.date_ordered, src.term_due_months_forward),
                                        ''MONTH'')+ src.term_due_day_of_month - 1),
                           src.date_ordered + src.term_due_days),
                   src.term_due_date) BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
    END IF;
  ELSE   -- payment_term = 'N'
    IF(CE_CASH_FCST.G_order_date_type = 'R')THEN
       IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
       	 select_clause_1 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_requested +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
       ELSE
      	 select_clause_1 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_requested +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
       END IF;
       where_clause_1 := where_clause || '
                         AND     src.date_requested BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
    ELSE
       IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
       	 select_clause_1 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_ordered +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
       ELSE
      	 select_clause_1 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_ordered +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
       END IF;
       where_clause_1 := where_clause || '
                         AND     src.date_ordered BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
    END IF;
  END IF;

  IF(CE_CASH_FCST.G_order_date_type = 'R')THEN
     IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
       	 select_clause_3 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_requested +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
     ELSE
      	 select_clause_3 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_requested +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
     END IF;
     where_clause_3 := where_clause || '
	AND	src.date_requested BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
  ELSE
     IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
       	 select_clause_3 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_ordered +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
     ELSE
      	 select_clause_3 := '
	   SELECT CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		to_number(hr_ou.ORGANIZATION_ID),
		src.date_ordered +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		null,
		null,
		round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
     END IF;
     where_clause_3 := where_clause || '
	AND	src.date_ordered BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time);
  END IF;

  cep_standard.debug('Built Select Clause');
  cep_standard.debug('Built Where Clause');


  main_query_1 := select_clause_1 || from_clause_1 || where_clause_1;
  main_query_2 := select_clause_2 || from_clause_2 || where_clause_2;
  main_query_3 := select_clause_3 || from_clause_3 || where_clause_3;

  IF (CE_CASH_FCST.G_use_payment_terms = 'Y') THEN
    Execute_Main_Query (main_query_2);
    Execute_Main_Query (main_query_3);
  ELSE
    Execute_Main_Query (main_query_1);
  END IF;

  cep_standard.debug('<<ce_csh_fcST_POP.Build_Sales_Order_Query');
EXCEPTION
	WHEN OTHERS THEN
		CEP_STANDARD.DEBUG('EXCEPTION:Build_Sales_Order_Query');
		raise;
END Build_Sales_Order_Query ;



/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Exp_Report_Query					|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for released expense report from PA but not has been 	|
|	transferred to AP yet.						|
|  CALLED BY								|
|	Build_Exp_Report_Query						|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	20-NOV-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_PA_Exp_Report_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN
  CE_CASH_FCST.G_app_short_name := 'PA';

  IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.expenditure_item_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(-src.amount,0)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
  ELSE
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.expenditure_item_id,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(-src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
			-src.amount';
  END IF;

  from_clause 		:= 	Get_From_Clause ('pa_ce_exp_reports_v');
  where_clause 		:= 	Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_PA_Exp_Report_Query');
    RAISE;
END Build_PA_Exp_Report_Query;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_Exp_Report_Query						|
|									|
|  DESCRIPTION								|
|	forecast amounts for released expense report from PA  and  	|
|	transferred to AP.						|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	20-NOV-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_Exp_Report_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN
  select_clause 	:= 	Get_Select_Clause;
  from_clause 		:= 	Get_From_Clause ('ce_ap_fc_exp_reports_v');
  where_clause 		:= 	Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	' AND	src.source <> ''NonValidatedWebExpense'' '||
	Add_Where('PROJECT_ID') || Add_Where('INCLUDE_HOLD_FLAG');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

  IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
    Build_PA_Exp_Report_Query;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_Exp_Report_Query');
    RAISE;
END Build_Exp_Report_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Trx_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for Projects Transactions.				|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	23-NOV-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_PA_Trx_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN

  select_clause := Get_Select_Clause;
  from_clause := Get_From_Clause ('pa_ce_transactions_v');
  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID') || Add_Where('TYPE');

  main_query := select_clause || from_clause || where_clause;

  Execute_Main_Query (main_query);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_PA_Trx_Query');
    RAISE;
END Build_PA_Trx_Query;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Billing_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for unreleased billing events that have an invoicing    |
|	impact.								|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	02-DEC-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_PA_Billing_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN

  IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.project_id || ''X'' || src.event_num,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(src.amount,0)*'
				||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
			src.amount';
  ELSE
    select_clause := '
		SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
			'||CE_CASH_FCST.G_forecast_id||',
			'||CE_CASH_FCST.G_rp_forecast_header_id||',
			'||CE_CASH_FCST.G_forecast_row_id||',
			''Y'',
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			cab.forecast_column_id,
			src.project_id || ''X'' || src.event_num,
			src.currency_code,
			to_number(hr_ou.ORGANIZATION_ID),
			src.trx_date,
			null,
			null,
			round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
			src.amount';
  END IF;

  from_clause := Get_From_Clause ('pa_ce_billing_events_v');
  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
		' and cab.end_date - '
                ||to_char(CE_CASH_FCST.G_lead_time)||
	Add_Where('PROJECT_ID');

  main_query := select_clause || from_clause || where_clause;
  Execute_Main_Query (main_query);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_PA_Billing_Query');
    RAISE;
END Build_PA_Billing_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Budget_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for inflow/outflow budgets entered for project.		|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	09-JUN-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE Build_PA_Budget_Query IS
  l_cost_amount		NUMBER;
  l_revenue_amount 	NUMBER;
  l_org_id		NUMBER;
  l_legal_entity_id	NUMBER;
  l_dummy		NUMBER;
  l_rate		NUMBER;

  l_reference_id	NUMBER;
  l_start_date		DATE;
  l_end_date		DATE;

  CURSOR C_period IS
    SELECT 	start_date,
           	end_date,
           	forecast_column_id
    FROM   	ce_forecast_ext_temp
    WHERE  	context_value 		= 	'A'
    AND	   	forecast_request_id 	=	CE_CASH_FCST.G_forecast_id
    AND	   	conversion_rate 	= 	CE_CASH_FCST.G_forecast_row_id;

  CURSOR C_sob(p_org_id NUMBER) IS
    SELECT 	1
    FROM 	CE_FORECAST_ORGS_V
    WHERE 	set_of_books_id 	= 	CE_CASH_FCST.G_set_of_books_id
    AND       	org_id 			= 	p_org_id;

  CURSOR C_rate(p_currency_code VARCHAR2) IS
    SELECT 	exchange_rate
    FROM   	ce_currency_rates_temp
    WHERE  	forecast_request_id 	= 	CE_CASH_FCST.G_forecast_id
    AND	   	to_currency	       	= 	CE_CASH_FCST.G_rp_forecast_currency
    AND    	currency_code       	= 	p_currency_code;

  CURSOR C_budgets(p_start_date DATE, p_end_date DATE) IS
    SELECT 	trim(resource_assignment_id||'X'||to_char(start_date,'DD-MON-YY')) reference_id,  --bug 7345336
			--resource_assignment_id||'X'||trunc(start_date) reference_id,
		projfunc_currency_code,
		nvl(raw_cost,0)/(trunc(end_date)-trunc(start_date)+1) per_day_raw_cost,
		nvl(revenue,0)/(trunc(end_date)-trunc(start_date)+1) per_day_revenue,
		start_date,
		end_date
    FROM	pa_ce_integration_budgets_v
    WHERE	decode(CE_CASH_FCST.G_budget_version,'C',current_flag,
			'O',current_original_flag) = 'Y'
    AND		end_date >= p_start_date
    AND		start_date <= p_end_date
    AND		project_id = CE_CASH_FCST.G_rp_project_id
    AND		budget_type_code = CE_CASH_FCST.G_budget_type;

BEGIN
  populate_aging_buckets;

  SELECT org_id
  INTO l_org_id
  FROM pa_projects_all
  WHERE project_id = CE_CASH_FCST.G_rp_project_id;

  SELECT to_number(ORGANIZATION_ID)
  INTO l_legal_entity_id
  FROM hr_operating_units
  WHERE organization_id = l_org_id;

  FOR C_rec IN C_period LOOP
    FOR C_budget_rec in C_budgets(C_rec.start_date, C_rec.end_date) LOOP

      IF (C_budget_rec.start_date < C_rec.start_date) THEN
        IF (C_budget_rec.end_date < C_rec.end_date) THEN
          l_start_date := trunc(C_rec.start_date);
	  l_end_date := trunc(C_budget_rec.end_date);
        ELSE
          l_start_date := trunc(C_rec.start_date);
	  l_end_date := trunc(C_rec.end_date);
 	END IF;
      ELSE
        IF (C_budget_rec.end_date > C_rec.end_date) THEN
          l_start_date := trunc(C_budget_rec.start_date);
	  l_end_date := trunc(C_rec.end_date);
        ELSE
          l_start_date := trunc(C_budget_rec.start_date);
	  l_end_date := trunc(C_budget_rec.end_date);
 	END IF;
      END IF;

      l_cost_amount := C_budget_rec.per_day_raw_cost *
		(l_end_date - l_start_date + 1);
      l_revenue_amount := C_budget_rec.per_day_revenue *
		(l_end_date - l_start_date + 1);

      IF(CE_CASH_FCST.G_rp_src_curr_type in ('E','F') AND
          C_budget_rec.projfunc_currency_code <> CE_CASH_FCST.G_rp_src_currency) THEN
        l_revenue_amount := 0;
        l_cost_amount := 0;
      END IF;

      IF( (CE_CASH_FCST.G_org_id <> -1 AND CE_CASH_FCST.G_org_id <> -99) AND
          (nvl(l_org_id,CE_CASH_FCST.G_org_id) <> CE_CASH_FCST.G_org_id) ) THEN
        l_revenue_amount := 0;
        l_cost_amount := 0;
      END IF;

      IF( CE_CASH_FCST.G_set_of_books_id IS NOT NULL AND
          CE_CASH_FCST.G_set_of_books_id <> -1) THEN
        OPEN C_sob(l_org_id);
        FETCH C_sob INTO l_dummy;
        IF C_sob%NOTFOUND THEN
          CLOSE C_sob;
          l_revenue_amount := 0;
          l_cost_amount := 0;
        END IF;
        CLOSE C_sob;
      END IF;

      IF( CE_CASH_FCST.G_rp_exchange_type IS NULL OR
          CE_CASH_FCST.G_rp_exchange_type <> 'User')THEN
        OPEN C_rate(C_budget_rec.projfunc_currency_code);
        FETCH C_rate INTO l_rate;
        IF C_rate%NOTFOUND THEN
          l_rate := 1;
        END IF;
        CLOSE C_rate;
      ELSIF( CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
        l_rate := CE_CASH_FCST.G_rp_exchange_rate;
      ELSE
        l_rate := 1;
      END IF;

      IF(CE_CASH_FCST.G_rp_amount_threshold IS NOT NULL) THEN
        IF (CE_CASH_FCST.G_trx_type = 'PAI') THEN
          IF (abs(l_revenue_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
    	      l_revenue_amount := 0;
          END IF;
        ELSE
          IF (abs(l_cost_amount) <= CE_CASH_FCST.G_rp_amount_threshold) THEN
              l_cost_amount := 0;
          END IF;
        END IF;
      END IF;

      IF(C_rec.forecast_column_id = CE_CASH_FCST.G_overdue_column_id AND
          CE_CASH_FCST.G_invalid_overdue_row)THEN
	    l_revenue_amount := 0;
            l_cost_amount := 0;
      END IF;

      IF (CE_CASH_FCST.G_trx_type = 'PAI') THEN
         IF (l_revenue_amount <> 0) THEN
          Insert_Fcast_Cell(C_budget_rec.reference_id, C_budget_rec.projfunc_currency_code, l_legal_entity_id, null, null, l_revenue_amount*l_rate, l_revenue_amount, C_rec.forecast_column_id);
         END IF;
      ELSE
         IF (l_cost_amount <> 0) THEN
          Insert_Fcast_Cell(C_budget_rec.reference_id, C_budget_rec.projfunc_currency_code, l_legal_entity_id, null, null, -(l_cost_amount*l_rate), -l_cost_amount, C_rec.forecast_column_id);
         END IF;
      END IF;
    END LOOP;
  END LOOP;

  clear_aging_buckets;
  zero_fill_cells;
EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_PA_Budget_Query');
    RAISE;
END Build_PA_Budget_Query;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Build_PA_Billing_Query						|
|									|
|  DESCRIPTION								|
|	This procedure builds the query to calculate the forecast	|
|	amounts for unreleased billing events that have an invoicing    |
|	impact.								|
|  CALLED BY								|
|	Populate_Cells							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	02-DEC-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE Build_Treasury_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1500);
  select_clause	varchar2(1500);
  main_query	varchar2(3500) := null;
BEGIN
  IF(CE_CASH_FCST.G_rp_exchange_type = 'User')THEN
    select_clause := '
	SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		src.org_id,
		src.trx_date +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		src.bank_account_id,
		ccid.asset_code_combination_id,
		round(nvl(src.amount,0)*'||CE_CASH_FCST.G_rp_exchange_rate
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
  ELSE
    select_clause := '
	SELECT 	CE_FORECAST_TRX_CELLS_S.nextval,
		'||CE_CASH_FCST.G_forecast_id||',
		'||CE_CASH_FCST.G_rp_forecast_header_id||',
		'||CE_CASH_FCST.G_forecast_row_id||',
		''Y'',
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		sysdate,
		nvl(fnd_global.user_id,-1),
		cab.forecast_column_id,
		src.reference_id,
		src.currency_code,
		src.org_id,
		src.trx_date +'
                ||to_char(CE_CASH_FCST.G_lead_time)|| ',
		src.bank_account_id,
		ccid.asset_code_combination_id,
		round(nvl(src.amount,0)*curr.exchange_rate'
				||','||CE_CASH_FCST.G_precision||'),
		src.amount';
  END IF;
  from_clause := Get_From_Clause('ce_xtr_cashflows_v');
  where_clause := Get_Where_Clause || '
	AND	src.trx_date BETWEEN cab.start_date and cab.end_date '||
	Add_Where('XTR_TYPE') || Add_Where('XTR_BANK_ACCOUNT') || Add_Where('EXCLUDE_INDIC_EXP');

  IF (CE_CASH_FCST.G_trx_type = 'XTO') THEN
    where_clause := where_clause || ' AND src.amount < 0';
  ELSE
    where_clause := where_clause || ' AND src.amount > 0';
  END IF;

  IF CE_CASH_FCST.G_overdue_transactions = 'INCLUDE' THEN
    where_clause := where_clause ||
	' AND decode(cab.forecast_column_id,'||CE_CASH_FCST.G_overdue_column_id
	||',src.reconciled_reference,null) is null';
  END IF;
  main_query := select_clause || from_clause || where_clause;
  Execute_Main_Query (main_query);

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION:OTHERS-Build_Treasury_Query');
    RAISE;
END Build_Treasury_Query;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Build_Remote_Query                                              |
|                                                                       |
|  DESCRIPTION                                                          |
|       This procedure builds the query to calculate the forecast       |
|       amounts from the remote transactions                            |
|  CALLED BY                                                            |
|       Populate_Cells                                                  |
|  REQUIRES                                                             |
|       main_query                                                      |
|  HISTORY                                                              |
|       12-JUL-1996     Created         Bidemi Carrol                   |
 --------------------------------------------------------------------- */
PROCEDURE Build_Remote_Query IS
  db_link               varchar2(128);
  main_query            VARCHAR2(6000) := null;
  cursor_id		INTEGER;
  exec_id		INTEGER;
  error_msg		VARCHAR2(2000);
BEGIN
  cep_standard.debug('>>CE_CSH_FCAST_POP.Build_Remote_Query');
  --
  -- Get view and db information from the external source type
  --
  cep_standard.debug('Get database information for database: '||CE_CASH_FCST.G_external_source_type);
  BEGIN

    SELECT      external_source_view, db_link_name
    INTO        source_view, db_link
    FROM        ce_forecast_ext_views
    WHERE       external_source_type = CE_CASH_FCST.G_external_source_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	cep_standard.debug('EXCEPTION:Build_Remote_Query - View def not found');
        FND_MESSAGE.set_name('CE','CE_FC_EXT_SOURCE_UNDEFINED');
	FND_MESSAGE.set_token('EXT_TYPE', CE_CASH_FCST.G_external_source_type);
        error_msg := FND_MESSAGE.get;
        CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id, 'CE_FC_EXT_SOURCE_UNDEFINED', error_msg);
	RETURN;
  END;

  populate_aging_buckets;

  IF( db_link IS NOT NULL )THEN
    db_link := '@'||db_link;
  END IF;
  cep_standard.debug('  source_view = '||source_view||', db_link = '||db_link);

  main_query := '
      declare
	counter			NUMBER;
	error_code		NUMBER;
	error_msg		VARCHAR2(2000);
	aging_table		CE_FORECAST_REMOTE_SOURCES.AgingTab'||db_link||';
	conversion_table	CE_FORECAST_REMOTE_SOURCES.ConversionTab'||db_link||';
	amount_table		CE_FORECAST_REMOTE_SOURCES.AmountTab'||db_link||';

  	CURSOR conversion_cursor IS SELECT    	currency_code, exchange_rate
                              	    FROM      	ce_currency_rates_temp
			      	    WHERE	forecast_request_id 	= CE_CASH_FCST.G_forecast_id; ';

  IF( db_link IS NOT NULL )THEN
    main_query := main_query ||'
  	CURSOR aging_cursor IS  SELECT 	forecast_column_id, start_date, end_date
                         	FROM   	ce_forecast_ext_temp
				WHERE	context_value = ''A'' 	and
					forecast_request_id = CE_CASH_FCST.G_forecast_id and
					conversion_rate = CE_CASH_FCST.G_forecast_row_id; ';
  END IF;

  main_query := main_query ||'
      begin ';

  IF( db_link IS NOT NULL )THEN
    main_query := main_query ||'
  	--
  	-- Store aging bucket information into aging table
  	--
	counter := 1;
	open aging_cursor;
  	cep_standard.debug(''Building aging information'');
  	LOOP
     	  FETCH aging_cursor INTO aging_table(counter).column_id,
			    	  aging_table(counter).start_date,
			    	  aging_table(counter).end_date;
    	  EXIT WHEN aging_cursor%NOTFOUND or aging_cursor%NOTFOUND IS NULL;
	  counter := counter + 1;
  	END LOOP;
	cep_standard.debug(''counter for aging have '' || to_char(counter));
  	close aging_cursor;
	aging_table.delete(counter);
	cep_standard.debug(''Done building aging information''); ';
  END IF;

  main_query := main_query ||'

  	--
  	-- Store conversion rate information into conversion table
  	--
  	counter := 1;
  	open conversion_cursor;
  	cep_standard.debug(''Building conversion information'');
  	LOOP
    	  FETCH conversion_cursor INTO conversion_table(counter).from_currency_code,
                               	       conversion_table(counter).conversion_rate;
    	  EXIT WHEN conversion_cursor%NOTFOUND or conversion_cursor%NOTFOUND IS NULL;
	  counter := counter + 1;
  	END LOOP;
  	close conversion_cursor;
	conversion_table.delete(counter);
	cep_standard.debug(''Done building conversion information'');

  	--
  	-- Built query to be executed in the remote/local database
  	--
  	error_code := CE_FORECAST_REMOTE_SOURCES.populate_remote_amounts';

  --
  -- Append db_link if applicable
  --
  IF( db_link IS NOT NULL) THEN
    main_query := main_query||db_link;
  END IF;

  main_query := main_query ||'(
  		CE_CASH_FCST.G_forecast_id,
		'''||source_view||''',
		'''||db_link||''',
		CE_CASH_FCST.G_forecast_row_id,
		aging_table,
		conversion_table,
                CE_CASH_FCST.G_rp_forecast_currency,
		CE_CASH_FCST.G_rp_exchange_date,
		CE_CASH_FCST.G_rp_exchange_type,
		CE_CASH_FCST.G_rp_exchange_rate,
		CE_CASH_FCST.G_rp_src_curr_type,
		CE_CASH_FCST.G_rp_src_currency,
		CE_CASH_FCST.G_rp_amount_threshold,
		CE_CASH_FCST.G_lead_time,
                CE_CASH_FCST.G_criteria1,
		CE_CASH_FCST.G_criteria2,
		CE_CASH_FCST.G_criteria3,
                CE_CASH_FCST.G_criteria4,
		CE_CASH_FCST.G_criteria5,
		CE_CASH_FCST.G_criteria6,
                CE_CASH_FCST.G_criteria7,
		CE_CASH_FCST.G_criteria8,
		CE_CASH_FCST.G_criteria9,
                CE_CASH_FCST.G_criteria10,
		CE_CASH_FCST.G_criteria11,
		CE_CASH_FCST.G_criteria12,
                CE_CASH_FCST.G_criteria13,
		CE_CASH_FCST.G_criteria14,
		CE_CASH_FCST.G_criteria15,
                amount_table);
        IF( error_code = 0 )THEN
  	  --
  	  -- For the amount calculated from the remote database, insert it to
  	  -- the cell table
  	  --
  	  FOR i IN 1 .. amount_table.count LOOP
	    IF (CE_CASH_FCST.G_trx_type = ''OII'') THEN
    	      cep_standard.debug(''insert column_id = ''||to_char(amount_table(i).forecast_column_id)||'' with amount ''||
					      to_char(amount_table(i).forecast_amount));
    	      CE_CSH_FCST_POP.Insert_Fcast_Cell(null, amount_table(i).currency_code, null, amount_table(i).trx_date, amount_table(i).bank_account_id, amount_table(i).forecast_amount, amount_table(i).trx_amount, amount_table(i).forecast_column_id);
            ELSE
    	      cep_standard.debug(''insert column_id = ''||to_char(amount_table(i).forecast_column_id)||'' with amount ''||
					      to_char(-(amount_table(i).forecast_amount)));
    	      CE_CSH_FCST_POP.Insert_Fcast_Cell(null, amount_table(i).currency_code, null, amount_table(i).trx_date, amount_table(i).bank_account_id, -(amount_table(i).forecast_amount), -(amount_table(i).trx_amount), amount_table(i).forecast_column_id);
            END IF;
  	  END LOOP;
	  CE_CSH_FCST_POP.Zero_Fill_Cells;
	ELSIF( error_code = -1 )THEN
	  cep_standard.debug(''Remote error: missing view'');
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_MISSING_VIEW_EXPT'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_MISSING_VIEW_EXPT'', error_msg);
 	  return;
	ELSIF( error_code = -2 )THEN
	  cep_standard.debug(''Remote error: invalid view'');
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_INVALID_VIEW_EXPT'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_INVALID_VIEW_EXPT'', error_msg);
 	  return;
	ELSIF( error_code = -3 )THEN
	  cep_standard.debug(''Remote error: others'');
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_EXCEPTION'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_EXCEPTION'', error_msg);
 	  return;
	END IF;
      end; ';

  BEGIN
    cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(cursor_id, main_query, DBMS_SQL.v7);
    exec_id := DBMS_SQL.execute(cursor_id);
    DBMS_SQL.close_cursor(cursor_id);
  EXCEPTION
    WHEN OTHERS THEN
	clear_aging_buckets;
        IF DBMS_SQL.is_open(cursor_id) THEN
          DBMS_SQL.close_cursor(cursor_id);
        END IF;
        FND_MESSAGE.set_name('CE', 'CE_FC_RMT_DB_EXCEPTION');
        error_msg := FND_MESSAGE.get;
        CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
                        CE_CASH_FCST.G_forecast_row_id, 'CE_FC_RMT_DB_EXCEPTION', error_msg);
        return;
  END;

  clear_aging_buckets;

  cep_standard.debug('<<CE_CSH_FCST_POP.Build_Remote_Query');
EXCEPTION
  WHEN OTHERS THEN
	clear_aging_buckets;
        cep_standard.debug('EXCEPTION:Build_Remote_Query');
	FND_MESSAGE.set_name('CE', 'CE_FC_RMT_EXCEPTION');
        error_msg := FND_MESSAGE.get;
	CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id, CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id, 'CE_FC_RMT_EXCEPTION', error_msg);
END Build_Remote_Query;




/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Populate_Cells							|
|									|
|  DESCRIPTION								|
|	This procedure calls the appropriate build query procedure for	|
|  each transaction type.						|
|  CALLED BY								|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Populate_Cells IS
  error_msg		VARCHAR2(2000);

BEGIN
--
-- Based on the source_trx_type call the different procedures
-- to build the queries dynamically
--

  cep_standard.debug('>>CE_CSH_FCST_POP.Populate_Cells');
  IF    (CE_CASH_FCST.G_trx_type = 'API') THEN
	Build_AP_Invoice_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'APP' AND CE_CASH_FCST.G_rp_project_id IS NULL) THEN
	Build_AP_Pay_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'ARI') THEN
	Build_AR_Invoice_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'ARR' AND CE_CASH_FCST.G_rp_project_id IS NULL) THEN
	Build_AR_Receipt_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'GLB') THEN
	Build_GL_Budget_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'GLE') THEN
	Build_GL_Encumb_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'GLA') THEN
	Build_GL_Actuals_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'OII') THEN
	Build_Remote_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'OIO') THEN
	Build_Remote_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'PAY' AND CE_CASH_FCST.G_rp_project_id IS NULL) THEN
	Build_Pay_Exp_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'POP') THEN
	Build_PO_Orders_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'POR') THEN
	Build_PO_Req_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'ASF' AND CE_CASH_FCST.G_rp_project_id IS NULL) THEN
	Build_Sales_Fcst_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'APX') THEN
	Build_Exp_Report_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'PAT') THEN
    IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
	Build_PA_Trx_Query;
    ELSE
      UPDATE	ce_forecasts
      SET	error_status = 'X'
      WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;
      FND_MESSAGE.set_name ('CE','CE_FC_NO_PROJECT_RANGE');
      error_msg := FND_MESSAGE.GET;
      CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id,
			CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id,
			'CE_FC_NO_PROJECT_RANGE', error_msg);
    END IF;
  ELSIF (CE_CASH_FCST.G_trx_type in ('PAI', 'PAO')) THEN
    IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
	Build_PA_Budget_Query;
    ELSE
      UPDATE	ce_forecasts
      SET	error_status = 'X'
      WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;
      FND_MESSAGE.set_name ('CE','CE_FC_NO_PROJECT_RANGE');
      error_msg := FND_MESSAGE.GET;
      CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id,
			CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id,
			'CE_FC_NO_PROJECT_RANGE', error_msg);
    END IF;
  ELSIF (CE_CASH_FCST.G_trx_type = 'PAB') THEN
    IF (CE_CASH_FCST.G_rp_project_id IS NOT NULL) THEN
	Build_PA_Billing_Query;
    ELSE
      UPDATE	ce_forecasts
      SET	error_status = 'X'
      WHERE	forecast_id = CE_CASH_FCST.G_forecast_id;
      FND_MESSAGE.set_name ('CE','CE_FC_NO_PROJECT_RANGE');
      error_msg := FND_MESSAGE.GET;
      CE_FORECAST_ERRORS_PKG.insert_row(CE_CASH_FCST.G_forecast_id,
			CE_CASH_FCST.G_rp_forecast_header_id,
			CE_CASH_FCST.G_forecast_row_id,
			'CE_FC_NO_PROJECT_RANGE', error_msg);
    END IF;
  ELSIF (CE_CASH_FCST.G_trx_type = 'OEO') THEN
	Build_Sales_Order_Query;
  ELSIF (CE_CASH_FCST.G_trx_type in ('XTR','XTI','XTO') AND CE_CASH_FCST.G_rp_project_id IS NULL) THEN
	Build_Treasury_Query;
  ELSIF (CE_CASH_FCST.G_trx_type = 'UDI') THEN
  	Zero_Fill_Cells;
  ELSIF (CE_CASH_FCST.G_trx_type = 'UDO') THEN
  	Zero_Fill_Cells;
  END IF;

  cep_standard.debug('<<CE_CSH_FCST_POP.Populate_Cells');
END Populate_Cells;


END CE_CSH_FCST_POP;

/

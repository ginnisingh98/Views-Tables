--------------------------------------------------------
--  DDL for Package Body XTR_CSH_FCST_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CSH_FCST_POP" AS
/* $Header: xtrfpclb.pls 115.15 2003/05/12 16:58:55 rvallams ship $ */


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
                 WHERE  forecast_header_id = XTR_CASH_FCST.G_rp_forecast_header_id;
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
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CASH_FCST.Set_History');

     xtr_debug_pkg.debug('G_roll_forward_type: '|| XTR_CASH_FCST.G_roll_forward_type);

     xtr_debug_pkg.debug('G_roll_forward_period : ' || XTR_CASH_FCST.G_roll_forward_period);

     xtr_debug_pkg.debug('G_start_period: ' 	|| XTR_CASH_FCST.G_rp_forecast_start_period);

     xtr_debug_pkg.debug('period_set_name: ' 	|| CEFC_VIEW_CONST.get_period_set_name);

  END IF;

  IF (XTR_CASH_FCST.G_roll_forward_type = 'D') THEN
    CEFC_VIEW_CONST.set_start_date(XTR_CASH_FCST.G_rp_forecast_start_date - XTR_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_min_col(XTR_CASH_FCST.G_min_col + XTR_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_max_col(XTR_CASH_FCST.G_max_col + XTR_CASH_FCST.G_roll_forward_period);
  ELSIF (XTR_CASH_FCST.G_roll_forward_type = 'M') THEN
    history_date:= ADD_MONTHS(XTR_CASH_FCST.G_rp_forecast_start_date,- XTR_CASH_FCST.G_roll_forward_period);
    CEFC_VIEW_CONST.set_start_date(history_date);
    CEFC_VIEW_CONST.set_min_col(XTR_CASH_FCST.G_min_col + XTR_CASH_FCST.G_roll_forward_period*30);
    CEFC_VIEW_CONST.set_max_col(XTR_CASH_FCST.G_max_col + XTR_CASH_FCST.G_roll_forward_period*30);
  ELSIF (XTR_CASH_FCST.G_roll_forward_type = 'A') THEN
    BEGIN
      SELECT	gps.period_name
      INTO	history_period
      FROM	gl_periods gps,
		gl_periods gp,
		gl_period_types gpt
      WHERE	gps.period_num =DECODE(LEAST(gp.period_num-XTR_CASH_FCST.G_roll_forward_period,1),
			1,gp.period_num - XTR_CASH_FCST.G_roll_forward_period,
			gpt.number_per_fiscal_year +
			  mod(gp.period_num-XTR_CASH_FCST.G_roll_forward_period,gpt.number_per_fiscal_year))
      AND	gps.period_year = gp.period_year +
			DECODE(LEAST(gp.period_num-XTR_CASH_FCST.G_roll_forward_period,1),1,0,
		  DECODE(mod(gp.period_num-XTR_CASH_FCST.G_roll_forward_period,gpt.number_per_fiscal_year),0,
			FLOOR((gp.period_num -XTR_CASH_FCST.G_roll_forward_period)/gpt.number_per_fiscal_year)-1,
			FLOOR((gp.period_num -XTR_CASH_FCST.G_roll_forward_period)/gpt.number_per_fiscal_year)))
      AND	gp.period_set_name 	= gps.period_set_name
      AND	gps.period_type 	= gp.period_type
      AND	gpt.period_type 	= gp.period_type
      AND	gp.period_name 		= XTR_CASH_FCST.G_rp_forecast_start_period
      AND	gp.period_set_name 	= CEFC_VIEW_CONST.get_period_set_name;

      CEFC_VIEW_CONST.set_start_period_name(history_period);
      CEFC_VIEW_CONST.set_min_col(XTR_CASH_FCST.G_min_col + XTR_CASH_FCST.G_roll_forward_period);
      CEFC_VIEW_CONST.set_max_col(XTR_CASH_FCST.G_max_col + XTR_CASH_FCST.G_roll_forward_period);
    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('NO DATA FOUND FOR HISTORY PERIOD');
		END IF;
		RAISE;
    	WHEN OTHERS THEN
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION-OTHERS Set_History');
		END IF;
		raise;
    END;
  END IF;

  min_col := CEFC_VIEW_CONST.get_min_col;
  max_col := CEFC_VIEW_CONST.get_max_col;
  XTR_CASH_FCST.G_invalid_overdue_row := FALSE;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CASH_FCST.Set_History');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
        IF(cCol%ISOPEN)THEN CLOSE cCol; END IF;
        RAISE;
END Set_History;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_temp_buckets						|
|									|
|  DESCRIPTION								|
|  CALLED BY								|
|	populate_ging_buckets						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	30-DEC-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE populate_temp_buckets IS
  CURSOR C_periods IS
    SELECT 	period_number,
	   	level_of_summary,
	   	length_of_period,
           	length_type
    FROM   	xtr_forecast_periods_v
    ORDER BY	period_number;

    l_period_number	NUMBER;
    l_level_of_summary	VARCHAR2(1);
    l_length_of_period  NUMBER;
    l_length_type	VARCHAR2(1);

    l_start_date	DATE;
    l_end_date		DATE;
    l_start		DATE;
    l_end		DATE;

    l_od_start		DATE;
    l_od_end		DATE;

    l_period_id		NUMBER := 0;
    l_count		NUMBER;
BEGIN
  BEGIN
  DELETE FROM xtr_forecast_period_temp;
  IF SQL%FOUND THEN
	COMMIT;
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
	XTR_DEBUG_PKG.DEBUG('EXCEPTION:populate_temp_buckets-->delete');
 	RAISE;
  END;

  l_start_date := XTR_CASH_FCST.G_rp_forecast_start_date;

  FOR p_rec IN C_periods LOOP
    IF p_rec.length_type = 'D' THEN
      l_end_date := LAST_DAY(l_start_date + p_rec.length_of_period);
    ELSIF p_rec.length_type = 'W' THEN
      l_end_date := LAST_DAY(l_start_date + p_rec.length_of_period * 7);
    ELSIF p_rec.length_type = 'M' THEN
      l_end_date := LAST_DAY(ADD_MONTHS(l_start_date,p_rec.length_of_period) - 1);
    ELSE
      l_end_date := LAST_DAY(ADD_MONTHS(l_start_date,p_rec.length_of_period * 12) - 1);
    END IF;

    IF p_rec.level_of_summary = 'D' THEN
      l_count := l_end_date - l_start_date + 1;
      FOR i IN 1 .. l_count LOOP
        IF NEXT_DAY(l_start_date-1,to_char(to_date('07/03/1997','DD/MM/YYYY'),'DY')) = l_start_date THEN
          l_start := l_start_date + 2;
          IF LAST_DAY(l_start_date) < l_start THEN
            l_start := LAST_DAY(l_start_date);
          END IF;
        ELSE
          l_start := l_start_date;
        END IF;

        INSERT INTO xtr_forecast_period_temp(forecast_period_temp_id, start_date, end_date, level_of_summary)
        VALUES (l_period_id, l_start_date, l_start, 'D');

        IF l_start = l_end_date THEN
          l_period_id := l_period_id + 1;
          l_start_date := l_start + 1;
          EXIT;
        ELSE
          l_period_id := l_period_id + 1;
          l_start_date := l_start + 1;
        END IF;
      END LOOP;
    ELSIF p_rec.level_of_summary = 'O' THEN
      l_od_end := l_start_date - 1;
      l_od_start := l_start_date + p_rec.length_of_period - 1;

      -- start date can't be sunday or saturday.
      -- get previous friday in this case.
      IF NEXT_DAY(l_od_start-1,to_char(to_date('08/03/1997','DD/MM/YYYY'),'DY')) = l_od_start THEN
         l_od_start := l_od_start - 1;
      ELSIF NEXT_DAY(l_od_start-1,to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY')) = l_od_start THEN
         l_od_start := l_od_start - 2;
      END IF;

      WHILE l_od_start < l_start_date LOOP
        IF NEXT_DAY(l_od_start-1,to_char(to_date('07/03/1997','DD/MM/YYYY'),'DY')) = l_od_start THEN
          l_start := l_od_start + 2;
          IF LAST_DAY(l_od_start) < l_start THEN
            l_start := LAST_DAY(l_od_start);
          END IF;
          IF l_start > l_od_end THEN
            l_start := l_od_end;
          END IF;
        ELSE
          l_start := l_od_start;
        END IF;

        INSERT INTO xtr_forecast_period_temp(forecast_period_temp_id, start_date, end_date, level_of_summary)
        VALUES (l_period_id, l_od_start, l_start, 'D');

        l_period_id := l_period_id + 1;
        l_od_start := l_start + 1;
      END LOOP;
    ELSIF p_rec.level_of_summary = 'W' THEN
      l_end := NEXT_DAY(l_start_date,to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY') );
      WHILE l_end <= l_end_date AND l_start_date <= l_end_date LOOP

        IF l_end > LAST_DAY(l_start_date) THEN
          l_end := LAST_DAY(l_start_date);
        END IF;

        INSERT INTO xtr_forecast_period_temp(forecast_period_temp_id, start_date, end_date, level_of_summary)
        VALUES (l_period_id, l_start_date, l_end, 'W');

        l_period_id  := l_period_id + 1;
        l_start_date := l_end + 1;
        l_end := NEXT_DAY(l_start_date, to_char(to_date('09/03/1997','DD/MM/YYYY'),'DY'));
        IF l_end > l_end_date THEN
          l_end := l_end_date;
        END IF;
      END LOOP;
    ELSIF p_rec.level_of_summary = 'M' THEN
      l_end := LAST_DAY(l_start_date);
      WHILE l_end <= l_end_date LOOP

        INSERT INTO xtr_forecast_period_temp(forecast_period_temp_id, start_date, end_date, level_of_summary)
        VALUES (l_period_id, l_start_date, l_end, 'M');

        l_start_date := l_end + 1;
        l_end := LAST_DAY(l_start_date);
        l_period_id := l_period_id + 1;
      END LOOP;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
	IF C_periods%ISOPEN THEN CLOSE C_periods; END IF;
	XTR_DEBUG_PKG.DEBUG('EXCEPTION:populate_temp_buckets');
	raise;
END populate_temp_buckets;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_aging_buckets						|
|									|
|  DESCRIPTION								|
|	Return real aging buckets by considering the transaction 	|
|	calendar into account			 			|
|  CALLED BY								|
|	XTR_CASH_FCST.create_forecast					|
|  REQUIRES								|
|									|
|  HISTORY								|
|	30-DEC-1998	Created		BHChung				|
 --------------------------------------------------------------------- */
PROCEDURE populate_aging_buckets IS
  CURSOR C1 IS 	select 	forecast_period_temp_id, start_date, end_date
		from 	xtr_forecast_period_temp;
  start_date		DATE;
  end_date		DATE;
  new_start_date	DATE;
  new_end_date		DATE;
  fid			NUMBER;
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>ce_csh_fcst_pop.populate_aging_buckets');
  END IF;
  populate_temp_buckets;

  IF(XTR_CASH_FCST.G_transaction_calendar_id IS NOT NULL)THEN
    OPEN C1;
    FETCH C1 INTO fid, start_date, end_date;

    LOOP
      EXIT WHEN C1%NOTFOUND OR C1%NOTFOUND IS NULL;

      new_start_date := NULL;
      new_end_date := NULL;

      IF(XTR_CASH_FCST.G_transaction_calendar_id IS NOT NULL)THEN
        IF(start_date <= G_calendar_start OR
           start_date-1 > G_calendar_end) THEN
 	  new_start_date := start_date;
        ELSE
 	  BEGIN
            select 	max(transaction_date)+1
            into	new_start_date
            from	gl_transaction_dates
            where	transaction_calendar_id = XTR_CASH_FCST.G_transaction_calendar_id
            and		transaction_date < start_date
            and 	business_day_flag = 'Y';

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
            into	new_end_date
            from	gl_transaction_dates
            where	transaction_calendar_id = XTR_CASH_FCST.G_transaction_calendar_id
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

        UPDATE 	xtr_forecast_period_temp
        SET     start_date = new_start_date,
		end_date = new_end_date
        WHERE  	forecast_period_temp_id = fid;
      END IF;

      FETCH C1 INTO fid, start_date, end_date;
    END LOOP;
    CLOSE C1;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<xtr_csh_fcst_pop.populate_aging_buckets');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
	IF C1%ISOPEN THEN CLOSE C1; END IF;
	XTR_DEBUG_PKG.DEBUG('EXCEPTION:populate_aging_buckets');
	raise;
END populate_aging_buckets;

PROCEDURE clear_aging_buckets IS
BEGIN
  delete from xtr_forecast_period_temp;
  IF SQL%FOUND THEN
	COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
	XTR_DEBUG_PKG.DEBUG('EXCEPTION:clear_aging_buckets-->delete');
	raise;
END clear_aging_buckets;

/* ----------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Get Select Clause						|
|									|
|  DESCRIPTION								|
|	Builds Select clause and returns it to calling procedure        |
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_Select_Clause RETURN VARCHAR2 IS
  select_clause VARCHAR2(300);
BEGIN
   if XTR_CASH_FCST.G_trx_type in ('APP','ARR','PAY') then   -- AW Bug 2261452
      select_clause := '
        SELECT  cab.forecast_period_temp_id,
                src.currency_code,
	        SUM(src.amount),
	        src.bank_account_id  ';
   else
      select_clause := '
        SELECT  cab.forecast_period_temp_id,
                src.currency_code,
                SUM(src.amount)  ';
   end if;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug(select_clause);
  END IF;
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
|	19-AUG-1996	Created		Bidemi Carrol                   |
 --------------------------------------------------------------------- */


FUNCTION Get_From_Clause (view_name VARCHAR2) RETURN VARCHAR2 IS
  from_clause VARCHAR2(500);
BEGIN
  from_clause := '
	FROM	'||view_name ||' src,
		xtr_forecast_period_temp cab ';

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Get_From_Clause: ' || from_clause);
  END IF;
  return from_clause;
END Get_From_Clause;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Get Group Clause						|
|									|
|  DESCRIPTION								|
|	Builds group clause and returns it to calling procedure		|
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_Group_Clause RETURN VARCHAR2 IS
  group_clause VARCHAR2(100);
BEGIN
   if XTR_CASH_FCST.G_trx_type in ('APP','ARR','PAY') then   -- AW Bug 2261452
      group_clause :=  '
	    GROUP BY cab.forecast_period_temp_id, src.currency_code,
	    src.bank_account_id  ';
   else
      group_clause :=  '
            GROUP BY cab.forecast_period_temp_id, src.currency_code  ';
   end if;
   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug(group_clause);
   END IF;
  return group_clause;
END Get_Group_Clause;


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
BEGIN
  IF(criteria = 'SRC_CURR_TYPE')THEN
    IF(XTR_CASH_FCST.G_rp_src_curr_type = 'E')THEN
      return ('
	AND 	src.currency_code  = '''||XTR_CASH_FCST.G_rp_src_currency||''' ');
    ELSIF(XTR_CASH_FCST.G_rp_src_curr_type  = 'F')THEN
      return ('
	AND 	org.currency_code  = '''||XTR_CASH_FCST.G_rp_src_currency||'''
	AND	(org.org_id 	   = src.org_id or org.org_id IS NULL) ');
    END IF;

  ELSIF(criteria = 'EXCHANGE_TYPE')THEN
    IF(XTR_CASH_FCST.G_rp_exchange_type IS NULL OR
       XTR_CASH_FCST.G_rp_exchange_type <> 'User')THEN
      return ('
	AND     curr.forecast_request_id 	= '||XTR_CASH_FCST.G_forecast_id||'
	AND	curr.to_currency		= '''||XTR_CASH_FCST.G_rp_forecast_currency||'''
       	AND     curr.currency_code      	= src.currency_code ');
    END IF;

  ELSIF(criteria = 'VENDOR_TYPE')THEN
    IF(XTR_CASH_FCST.G_vendor_type IS NOT NULL)THEN
      return ('
	AND 	src.vendor_type = '''||replace(XTR_CASH_FCST.G_vendor_type,'''','''''')||''' ');
    END IF;

  ELSIF(criteria = 'PAY_GROUP')THEN
    IF(XTR_CASH_FCST.G_pay_group IS NOT NULL)THEN
      return ('
	AND 	src.paygroup = '''||replace(XTR_CASH_FCST.G_pay_group,'''','''''')||''' ');
    END IF;

  ELSIF(criteria = 'PAYMENT_PRIORITY')THEN
    IF(XTR_CASH_FCST.G_payment_priority IS NOT NULL)THEN
      return ('
	AND 	src.payment_priority <= '||to_char(XTR_CASH_FCST.G_payment_priority));
    END IF;

  ELSIF(criteria = 'BANK_ACCOUNT_ID')THEN
    IF(XTR_CASH_FCST.G_bank_account_id IS NOT NULL)THEN
      return ('
	AND 	src.bank_account_id = '||TO_CHAR(XTR_CASH_FCST.G_bank_account_id));
    END IF;

  ELSIF(criteria = 'RECEIPT_METHOD_ID')THEN
    IF(XTR_CASH_FCST.G_receipt_method_id IS NOT NULL)THEN
      return ('
	AND 	src.receipt_method_id = '||TO_CHAR(XTR_CASH_FCST.G_receipt_method_id));
    END IF;

  ELSIF(criteria = 'CUSTOMER_PROFILE_CLASS_ID')THEN
    IF(XTR_CASH_FCST.G_customer_profile_class_id IS NOT NULL)THEN
      return ('
	AND 	src.profile_class_id = '||to_char(XTR_CASH_FCST.G_customer_profile_class_id));
    END IF;

  ELSIF(criteria = 'AUTHORIZATION_STATUS')THEN
    IF(XTR_CASH_FCST.G_authorization_status IS NOT NULL)THEN
      return ('
	AND 	src.status = '''||replace(XTR_CASH_FCST.G_authorization_status,'''','''''')||''' ');
    END IF;

  ELSIF(criteria = 'PAYMENT_METHOD')THEN
    IF(XTR_CASH_FCST.G_payment_method IS NOT NULL)THEN
      return ('
	AND     src.payment_method = '''||replace(XTR_CASH_FCST.G_payment_method,'''','''''')||''' ');
    END IF;

  ELSIF(criteria = 'ORG_PAYMENT_METHOD_ID')THEN
    IF(XTR_CASH_FCST.G_org_payment_method_id IS NOT NULL)THEN
      return ('
	AND 	src.org_payment_method_id = '||to_char(XTR_CASH_FCST.G_org_payment_method_id));
    END IF;

  ELSIF(criteria = 'PAYROLL_ID')THEN
    IF( XTR_CASH_FCST.G_payroll_id IS NOT NULL )THEN
      return ('
	AND 	src.payroll_id = '||to_char(XTR_CASH_FCST.G_payroll_id));
    END IF;

  ELSIF(criteria = 'CHANNEL_CODE')THEN
    IF( XTR_CASH_FCST.G_channel_code IS NOT NULL )THEN
      return ('
	AND 	src.channel_code = '''||replace(XTR_CASH_FCST.G_channel_code,'''','''''')||''' ');
    END IF;

  ELSIF(criteria = 'SALES_STAGE_ID')THEN
    IF( XTR_CASH_FCST.G_sales_stage_id IS NOT NULL )THEN
      return ('
	AND 	src.sales_stage_id = '||to_char(XTR_CASH_FCST.G_sales_stage_id));
    END IF;

  ELSIF(criteria = 'SALES_FORECAST_STATUS')THEN
    IF( XTR_CASH_FCST.G_sales_forecast_status IS NOT NULL )THEN
      return ('
	AND 	src.status_code = '''||replace(XTR_CASH_FCST.G_sales_forecast_status,'''','''''')||''' ');
    END IF;

  ELSE
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('ERROR - Add_Where got invalid criteria!');
    END IF;
  END IF;

  return (NULL);
END Add_Where;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE			                                |
|	Get Where Clause						|
|									|
|  DESCRIPTION								|
|	Builds where clause and returns it to calling procedure	        |
|  CALLED BY								|
|	Build_XXX_Query							|
|  REQUIRES								|
|									|
|  HISTORY								|
|	19-AUG-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
FUNCTION Get_Where_Clause RETURN VARCHAR2 IS
  where_clause VARCHAR2(1000);

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CASH_FCST.Get_Where_Clause');
  END IF;

  where_clause := ' WHERE src.org_id  IN ' ||XTR_CASH_FCST.G_rp_org_ids;

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CASH_FCST.Get_Where_Clause');
  END IF;
  return where_clause;
END Get_Where_Clause;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	Execute_Main_Query						|
|									|
|  DESCRIPTION								|
|	This procedure takes in the query string and executes it using	|
|	dynamic sql functionality. The query string is parsed and then	|
|	executed							|
|  CALLED BY								|
|	Build_XX_Query							|
|  REQUIRES								|
|	main_query							|
|  HISTORY								|
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Execute_Main_Query (main_query VARCHAR2) IS
  CURSOR C_cur(p_cur VARCHAR2) IS
    SELECT nvl(derive_type, 'NONE')
    FROM   gl_currencies
    WHERE  currency_code(+) = p_cur;

  CURSOR C_period(p_pid NUMBER) IS
    SELECT end_date,
           level_of_summary
    FROM   xtr_forecast_period_temp
    WHERE  forecast_period_temp_id = p_pid;

  cursor_id		INTEGER;
  exec_id		INTEGER;
  counter		number;

  forecast_period_temp_id	NUMBER;
  amount_date			DATE;
  company_code			XTR_PARTY_INFO.party_code%TYPE;
  trx_type			CE_FORECAST_ROWS.trx_type%TYPE;
  level_of_summary		XTR_FORECAST_PERIODS.level_of_summary%TYPE;
  currency			GL_CURRENCIES.currency_code%TYPE;
  bank_account_id		NUMBER;
  forecast_amount		NUMBER;

  l_emu			GL_CURRENCIES.currency_code%TYPE;
  error_msg		fnd_new_messages.message_text%TYPE;
BEGIN

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCST_POP.Execute_Main_Query');
  END IF;

  cursor_id := DBMS_SQL.open_cursor;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Execute_Main_Query: Cursor opened sucessfully with cursor_id: '||
                          to_char(cursor_id));
     xtr_debug_pkg.debug('Execute_Main_Query: Parsing ....');
  END IF;

  DBMS_SQL.Parse(cursor_id,
		 main_query,
		 DBMS_SQL.v7);

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Execute_Main_Query: Parsed sucessfully');
  END IF;

  DBMS_SQL.Define_Column(cursor_id, 1, forecast_period_temp_id);
  DBMS_SQL.Define_Column(cursor_id, 2, currency, 15);
  DBMS_SQL.Define_Column(cursor_id, 3, forecast_amount);
  if XTR_CASH_FCST.G_trx_type in ('APP','ARR','PAY') then   -- AW Bug 2261452
     DBMS_SQL.Define_Column(cursor_id, 4, bank_account_id);
  end if;

  exec_id := DBMS_SQL.execute(cursor_id);
  LOOP
    IF (DBMS_SQL.FETCH_ROWS(cursor_id) >0 ) THEN
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('Execute_Main_Query: Getting column information');
      END IF;

      DBMS_SQL.Column_Value(cursor_id, 1, forecast_period_temp_id);
      DBMS_SQL.Column_Value(cursor_id, 2, currency);
      DBMS_SQL.Column_Value(cursor_id, 3, forecast_amount);
      if XTR_CASH_FCST.G_trx_type in ('APP','ARR','PAY') then   -- AW Bug 2261452
         DBMS_SQL.Column_Value(cursor_id, 4, bank_account_id);
      end if;

      IF(amount_date < XTR_CASH_FCST.G_rp_forecast_start_date)THEN  -- Overdue Periods
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('Execute_Main_Query: Overdue transaction period');
	   xtr_debug_pkg.debug('Execute_Main_Query: trx_type = '
		|| XTR_CASH_FCST.G_trx_type || ', forecast_method = ' || XTR_CASH_FCST.G_forecast_method);
	END IF;

        IF(XTR_CASH_FCST.G_trx_type = 'PAY')THEN
	  forecast_amount := 0;
        END IF;
        IF(XTR_CASH_FCST.G_trx_type IN ('APP', 'ARR') AND
	   XTR_CASH_FCST.G_forecast_method = 'P')THEN
	  forecast_amount := 0;
	END IF;
	IF(XTR_CASH_FCST.G_invalid_overdue_row)THEN
	  forecast_amount := 0;
	END IF;
      END IF;

      OPEN C_cur(currency);
      FETCH C_cur INTO l_emu;
      CLOSE C_cur;

      IF l_emu = 'EMU' THEN
        BEGIN
          forecast_amount := GL_CURRENCY_API.convert_amount(currency,
							  'EUR',
							  XTR_CASH_FCST.G_rp_forecast_start_date,
						          'EMU-FIXED',
					                  forecast_amount);

          currency := 'EUR';
        EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.set_name('GL', 'GL_JE_INVALID_CONVERSION_INFO');
	  error_msg := fnd_message.get;
          CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id,
					XTR_CASH_FCST.G_rp_forecast_header_id, XTR_CASH_FCST.G_forecast_row_id,
					'GL_JE_INVALID_CONVERSION_INFO', error_msg);
        END;
      END IF;

      OPEN C_period(forecast_period_temp_id);
      FETCH C_period INTO amount_date,
                          level_of_summary;
      CLOSE C_period;

      INSERT INTO xtr_external_cashflows(amount_date,
					 amount,
					 currency,
					 company_code,
					 trx_type,
					 ap_bank_account_id,
					 level_of_summary)
      VALUES (amount_date,
	      nvl(forecast_amount,0),
	      currency,
	      XTR_CASH_FCST.G_party_code,
	      XTR_CASH_FCST.G_trx_type,
	      bank_account_id,
              level_of_summary);
    ELSE
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('Execute_Main_Query: No More Rows');
      END IF;
      EXIT;
    END IF;
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(CURSOR_ID);

  EXCEPTION
   WHEN OTHERS THEN
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION - OTHERS: Execute_Main_Query');
	END IF;
	IF DBMS_SQL.IS_OPEN(cursor_id) THEN
	  DBMS_SQL.CLOSE_CURSOR(cursor_id);
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug('Execute_Main_Query: Cursor Closed');
	  END IF;
	END IF;
	RAISE;
END Execute_Main_Query;


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
  where_clause	varchar2(1000);
  GROUP_clause	varchar2(100);
  select_clause	varchar2(300);
  main_query	varchar2(2000) := null;
  counter	number;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_AP_Pay_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause('ce_ap_fc_payments_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause || Add_Where('PAYMENT_METHOD') || Add_Where('BANK_ACCOUNT_ID');

  IF (NVL(XTR_CASH_FCST.G_forecast_method,'F') = 'P') THEN
    BEGIN
	Set_History;

    EXCEPTION
    	When NO_DATA_FOUND Then
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('row_id = ' || to_char(XTR_CASH_FCST.G_forecast_row_id));
		END IF;
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
                IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: No history data found for APP');
		END IF;
		return;
	When OTHERS Then
	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: Build APP query - Set History');
		END IF;
		raise;
    END;

    where_clause := where_clause || '
	AND	src.cleared_date(+) BETWEEN cab.start_date and cab.end_date
	AND	src.status <> ''NEGOTIABLE'' ';

  ELSE
    where_clause := where_clause || '
	AND	NVL(src.maturity_date(+),src.payment_date(+)) +'
                ||to_char(XTR_CASH_FCST.G_lead_time)||
                ' BETWEEN cab.start_date and cab.end_date
	AND	src.status = ''NEGOTIABLE'' ';
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause :=  Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<ce_csh_fcst_pop.Build_AP_Pay_Query');
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		XTR_DEBUG_PKG.DEBUG('EXCEPTION:Build_AP_Pay_Query');
		raise;
END Build_AP_Pay_Query;


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
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_AP_Invoice_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(300);
  main_query	varchar2(2000) := null;
  view_name	VARCHAR2(50);

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>Build_AP_Invoice_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  IF (NVL(XTR_CASH_FCST.G_discount_option,'N') = 'N') THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Discount NOT taken');
    END IF;
    from_clause   := Get_From_Clause('ce_ap_fc_due_invoices_v');
  ELSE
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Discount taken');
    END IF;
    from_clause   := Get_From_Clause('ce_disc_invoices_v');
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause || '
	AND	src.trx_date(+) +'
                ||to_char(XTR_CASH_FCST.G_lead_time)||
                ' BETWEEN cab.start_date and cab.end_date ' ||
 	Add_Where('PAYMENT_PRIORITY') || Add_Where('PAY_GROUP') || Add_Where('VENDOR_TYPE');

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause  := Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CSH_FCST_POP.Build_AP_Invoice_Query');
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		XTR_DEBUG_PKG.DEBUG('EXCEPTION:Build_AP_Invoice_Query');
		raise;
END Build_AP_Invoice_Query;



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
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(500);
  main_query	varchar2(3000) := null;
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>Build_AR_Invoice_Query');
  END IF;
  IF (XTR_CASH_FCST.G_include_dispute_flag = 'N') THEN
      select_clause := ' SELECT cab.forecast_period_temp_id,
		src.currency_code,
		SUM(src.amount-src.dispute_amount) ';
  ELSE
    select_clause := Get_Select_Clause;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
     xtr_debug_pkg.debug(select_clause);
  END IF;

  from_clause := Get_From_Clause ('ce_ar_fc_invoices_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause || '
	AND	src.trx_date +'
                ||to_char(XTR_CASH_FCST.G_lead_time)||
                ' BETWEEN cab.start_date and cab.end_date '||
	Add_Where('CUSTOMER_PROFILE_CLASS_ID');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause := Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause ||group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CSH_FCST_POP.Build_AR_Invoices_Query');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION:OTHERS-Build_AR_Invoice_Query');
    END IF;
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
|	12-JUL-1996	Created		Bidemi Carrol			|
 --------------------------------------------------------------------- */
PROCEDURE Build_AR_Receipt_Query IS
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(300);
  view_name	VARCHAR2(50);
  main_query	varchar2(3000) := null;
  counter	number;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>Build_AR_Receipt_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause ('ce_ar_fc_receipts_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause || Add_Where('BANK_ACCOUNT_ID') || Add_Where('RECEIPT_METHOD_ID');

  IF (NVL(XTR_CASH_FCST.G_forecast_method,'F') = 'P') THEN
    BEGIN
	Set_History;

    EXCEPTION
    	When NO_DATA_FOUND Then
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('row_id = ' || to_char(XTR_CASH_FCST.G_forecast_row_id));
		END IF;

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
		IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: No history data found for ARR');
		END IF;
		return;
	When OTHERS Then
	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: Build ARR query - Set History');
		END IF;
		raise;
    END;

    where_clause := where_clause || '
	AND	src.trx_date(+) BETWEEN cab.start_date and cab.end_date
	AND	src.status = ''CLEARED'' ';
  ELSE
    where_clause := where_clause || '
	AND	nvl(src.effective_date(+),NVL(src.maturity_date(+),src.trx_date(+))) +'
                ||to_char(XTR_CASH_FCST.G_lead_time)||
                ' BETWEEN cab.start_date and cab.end_date
	AND	src.status <> ''CLEARED'' ';


  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause := Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause ||group_clause;

  commit;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<xtr_csh_fcst_pop.Build_AR_Receipt_Query');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('EXCEPTION-OTHERS:Build_AR_Receipt_Query');
    END IF;
    RAISE;
END Build_AR_Receipt_Query;

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
  where_clause  varchar2(1000);
  group_clause  varchar2(100);
  select_clause varchar2(300);
  main_query    varchar2(2000) := null;
  error_msg	FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_PAY_Exp_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause('ce_pay_fc_payroll_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause || '
        AND 	src.effective_date(+) BETWEEN cab.start_date and cab.end_date ' ||
	Add_Where('ORG_PAYMENT_METHOD_ID') || Add_Where('BANK_ACCOUNT_ID') || Add_Where('PAYROLL_ID');

  group_clause  := Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  BEGIN
	Set_History;
  EXCEPTION
    	When NO_DATA_FOUND Then
    	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('row_id = ' || to_char(XTR_CASH_FCST.G_forecast_row_id));
		END IF;
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
	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: No Payroll historical data found');
		END IF;
		return;
	When OTHERS Then
	        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
		   xtr_debug_pkg.debug('EXCEPTION: Build Payroll query - Set History');
	        END IF;
		raise;
  END;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CSH_FCST_POP.Build_PAY_Exp_Query');
  END IF;

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
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(300);
  main_query	varchar2(2000) := null;
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_PO_Orders_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause('ce_po_fc_orders_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause|| '
	AND	src.trx_date(+) +'||to_char(XTR_CASH_FCST.G_lead_time)||'
		BETWEEN cab.start_date and cab.end_date ' ||
	Add_Where('AUTHORIZATION_STATUS') || Add_Where('PAYMENT_PRIORITY') ||
	Add_Where('PAY_GROUP') || Add_Where('VENDOR_TYPE');

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause :=  Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<xtr_csh_fcst_pop.Build_PO_Orders_Query');
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		XTR_DEBUG_PKG.DEBUG('EXCEPTION:Build_PO_Orders_Query');
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
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(300);
  main_query	varchar2(2000) := null;
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_PO_Req_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause('ce_po_fc_requisitions_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause ||  '
	AND     src.trx_date(+) +'||to_char(XTR_CASH_FCST.G_lead_time)|| '
                BETWEEN cab.start_date and cab.end_date '||
	Add_Where('AUTHORIZATION_STATUS');

  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause :=  Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<xtr_csh_fcst_pop.Build_PO_Req_Query');
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		XTR_DEBUG_PKG.DEBUG('EXCEPTION:Build_PO_req_Query');
		raise;
END Build_PO_Req_Query ;

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
  from_clause	VARCHAR2(500);
  where_clause	varchar2(1000);
  group_clause	varchar2(100);
  select_clause	varchar2(300);
  main_query	varchar2(2000) := null;
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_Sales_Order_Query');
  END IF;

  select_clause := Get_Select_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Select Clause');
  END IF;

  from_clause := Get_From_Clause('ce_so_fc_orders_v');
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built From Clause');
  END IF;

  where_clause := Get_Where_Clause ||
                  Add_Where('CUSTOMER_PROFILE_CLASS_ID');

  IF( XTR_CASH_FCST.G_order_status = 'O') THEN
    where_clause := where_clause || '
	AND     src.booked_flag = ''N'' ';
  ELSIF( XTR_CASH_FCST.G_order_status = 'B')THEN
    where_clause := where_clause || '
        AND     src.booked_flag = ''Y'' ';
  END IF;

  IF(XTR_CASH_FCST.G_order_date_type = 'R')THEN
    where_clause := where_clause || '
	AND	src.date_requested(+) +'||to_char(XTR_CASH_FCST.G_lead_time)||'
		BETWEEN cab.start_date and cab.end_date ';
  ELSE
    where_clause := where_clause || '
	AND	src.date_ordered(+) +'||to_char(XTR_CASH_FCST.G_lead_time)||'
		BETWEEN cab.start_date and cab.end_date ';
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Where Clause');
  END IF;

  group_clause :=  Get_Group_Clause;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Built Group Clause');
  END IF;

  main_query := select_clause || from_clause || where_clause || group_clause;

  Execute_Main_Query (main_query);
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<xtr_csh_fcst_pop.Build_Sales_Order_Query');
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		XTR_DEBUG_PKG.DEBUG('EXCEPTION:Build_Sales_Order_Query');
		raise;
END Build_Sales_Order_Query ;


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
  main_query            VARCHAR2(5000) := null;
  cursor_id		INTEGER;
  exec_id		INTEGER;
  error_msg		VARCHAR2(2000);
BEGIN
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCAST_POP.Build_Remote_Query');
  END IF;
  --
  -- Get view and db information from the external source type
  --
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('Get database information for database: '||XTR_CASH_FCST.G_external_source_type);
  END IF;
  BEGIN

    SELECT      external_source_view, db_link_name
    INTO        source_view, db_link
    FROM        ce_forecast_ext_views
    WHERE       external_source_type = XTR_CASH_FCST.G_external_source_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('EXCEPTION:Build_Remote_Query - View def not found');
	END IF;
        FND_MESSAGE.set_name('CE','CE_FC_EXT_SOURCE_UNDEFINED');
	FND_MESSAGE.set_token('EXT_TYPE', XTR_CASH_FCST.G_external_source_type);
        error_msg := FND_MESSAGE.get;
        CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
			XTR_CASH_FCST.G_forecast_row_id, 'CE_FC_EXT_SOURCE_UNDEFINED', error_msg);
	RETURN;
  END;


  IF( db_link IS NOT NULL )THEN
    db_link := '@'||db_link;
  END IF;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('  source_view = '||source_view||', db_link = '||db_link);
  END IF;

  main_query := '
      declare
	counter			NUMBER;
	error_code		NUMBER;
	error_msg		VARCHAR2(2000); ';

  main_query := main_query ||'
      begin
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.enable_file_debug;
	END IF;
	   ';


  main_query := main_query ||'
  	--
  	-- Built query to be executed in the remote/local database
  	--
  	error_code := XTR_FORECAST_REMOTE_SOURCES.populate_remote_amounts';

  --
  -- Append db_link if applicable
  --
  IF( db_link IS NOT NULL) THEN
    source_view := source_view||db_link;
  END IF;

  main_query := main_query ||'(
		'''||source_view||''',
		'''||db_link||''',
                XTR_CASH_FCST.G_criteria1,
		XTR_CASH_FCST.G_criteria2,
		XTR_CASH_FCST.G_criteria3,
                XTR_CASH_FCST.G_criteria4,
		XTR_CASH_FCST.G_criteria5,
		XTR_CASH_FCST.G_criteria6,
                XTR_CASH_FCST.G_criteria7,
		XTR_CASH_FCST.G_criteria8,
		XTR_CASH_FCST.G_criteria9,
                XTR_CASH_FCST.G_criteria10,
		XTR_CASH_FCST.G_criteria11,
		XTR_CASH_FCST.G_criteria12,
                XTR_CASH_FCST.G_criteria13,
		XTR_CASH_FCST.G_criteria14,
		XTR_CASH_FCST.G_criteria15);

        IF( error_code = 0 )THEN
          null;
	ELSIF( error_code = -1 )THEN
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug(''Remote error: missing view'');
	  END IF;
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_MISSING_VIEW_EXPT'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
			XTR_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_MISSING_VIEW_EXPT'', error_msg);
 	  return;
	ELSIF( error_code = -2 )THEN
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug(''Remote error: invalid view'');
	  END IF;
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_INVALID_VIEW_EXPT'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
			XTR_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_INVALID_VIEW_EXPT'', error_msg);
 	  return;
	ELSE
	  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	     xtr_debug_pkg.debug(''Remote error: others'');
	  END IF;
	  FND_MESSAGE.set_name(''CE'', ''CE_FC_RMT_EXCEPTION'');
	  error_msg := FND_MESSAGE.get;
	  CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
			XTR_CASH_FCST.G_forecast_row_id, ''CE_FC_RMT_EXCEPTION'', error_msg);
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
        IF DBMS_SQL.is_open(cursor_id) THEN
          DBMS_SQL.close_cursor(cursor_id);
        END IF;
        FND_MESSAGE.set_name('CE', 'CE_FC_RMT_DB_EXCEPTION');
        error_msg := FND_MESSAGE.get;
        CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
                        XTR_CASH_FCST.G_forecast_row_id, 'CE_FC_RMT_DB_EXCEPTION', error_msg);
        return;
  END;
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('<<XTR_CSH_FCST_POP.Build_Remote_Query');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
        IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
           xtr_debug_pkg.debug('EXCEPTION:Build_Remote_Query');
        END IF;
	FND_MESSAGE.set_name('CE', 'CE_FC_RMT_EXCEPTION');
        error_msg := FND_MESSAGE.get;
	CE_FORECAST_ERRORS_PKG.insert_row(XTR_CASH_FCST.G_forecast_id, XTR_CASH_FCST.G_rp_forecast_header_id,
			XTR_CASH_FCST.G_forecast_row_id, 'CE_FC_RMT_EXCEPTION', error_msg);
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
BEGIN
--
-- Based on the source_trx_type call the different procedures
-- to build the queries dynamically
--
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('>>XTR_CSH_FCST_POP.Populate_Cells');
  END IF;

  IF    (XTR_CASH_FCST.G_trx_type = 'API') THEN
	Build_AP_Invoice_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'APP') THEN
	Build_AP_Pay_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'ARI') THEN
	Build_AR_Invoice_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'ARR') THEN
	Build_AR_Receipt_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'PAY') THEN
	Build_Pay_Exp_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'POP') THEN
	Build_PO_Orders_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'POR') THEN
	Build_PO_Req_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'OEO') THEN
	Build_Sales_Order_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'OII') THEN
	Build_Remote_Query;
  ELSIF (XTR_CASH_FCST.G_trx_type = 'OIO') THEN
	Build_Remote_Query;
  END IF;

END Populate_Cells;

END XTR_CSH_FCST_POP;


/

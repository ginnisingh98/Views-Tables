--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_UTILS" as
/* $Header: cefutilb.pls 120.2.12010000.2 2009/10/29 07:10:58 talapati ship $ */

FUNCTION get_xtr_user RETURN VARCHAR2 IS
BEGIN
  if (G_xtr_user is null) then
    if XTR_USER = 1 then
      G_xtr_user := 'Y';
    else
      G_xtr_user := 'N';
    end if;
  end if;
  return G_xtr_user;
END;

FUNCTION get_xtr_user_first RETURN VARCHAR2 IS
BEGIN
  if XTR_USER = 1 then
    G_xtr_user := 'Y';
  else
    G_xtr_user := 'N';
  end if;
  return G_xtr_user;
END;


/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	Aging_Buckets_String						|
|									|
|  DESCRIPTION								|
|	This function returns the aging buckets for a forecast as a	|
|  single string that will be parsed in Java by the appropriate OA	|
|  controller.								|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|	Forecast_Id							|
|  HISTORY								|
|	13-JAN-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

FUNCTION Aging_Buckets_String ( X_forecast_id NUMBER,
				X_forecast_header_id NUMBER DEFAULT NULL,
				X_start_date DATE DEFAULT NULL,
				X_start_period VARCHAR2 DEFAULT NULL,
				X_period_set_name VARCHAR2 DEFAULT NULL)
				RETURN VARCHAR2 IS
  l_all_buckets 	VARCHAR2(3000);
  l_current_bucket	VARCHAR2(15);
  l_forecast_header_id	NUMBER;
  l_period_set_name	VARCHAR2(15);
  l_start_period	VARCHAR2(15);
  l_start_date		DATE;
  l_aging_type 		VARCHAR2(1);
  l_count		NUMBER;

  cursor cDate is	SELECT  start_date,
				end_date
		   	FROM	ce_fc_aging_buckets_v
			WHERE	developer_column_num > 0
		   	ORDER BY developer_column_num;
  cursor cAcct is	SELECT 	forecast_column_id,
				period_from,
				period_to
			FROM 	ce_fc_aging_buckets_v
			WHERE	developer_column_num > 0
			ORDER BY developer_column_num;
  cursor cCol(phid NUMBER) is	SELECT	forecast_column_id
			FROM	ce_forecast_columns
			WHERE	forecast_header_id = phid
			AND	developer_column_num > 0
			ORDER BY developer_column_num;

BEGIN
  if X_forecast_header_id is null then
    select forecast_header_id,
	period_set_name,
	start_period,
	start_date
    into l_forecast_header_id,
	l_period_set_name,
	l_start_period,
	l_start_date
    from ce_forecasts
    where forecast_id  = X_forecast_id;
  else
    l_forecast_header_id := X_forecast_header_id;
    l_period_set_name := X_period_set_name;
    l_start_period := X_start_period;
    l_start_date := X_start_date;
  end if;

  select aging_type
  into l_aging_type
  from ce_forecast_headers
  where forecast_header_id = l_forecast_header_id;

  CEFC_VIEW_CONST.set_constants(l_forecast_header_id,
				  l_period_set_name,
				  l_start_period,
				  trunc(l_start_date),
				  NULL, NULL);
  if l_aging_type = 'D' then
    l_all_buckets := '';
    l_count := 0;
    for c_rec in cDate loop
      l_count := l_count + 1;
      if c_rec.start_date = c_rec.end_date then
        l_all_buckets := l_all_buckets || to_date(c_rec.start_date,'J') || '|';
      else
        l_all_buckets := l_all_buckets || to_date(c_rec.start_date,'J')
		|| ' - ' || to_date(c_rec.end_date,'J') || '|';
      end if;
    end loop;
  else
    l_all_buckets := '';
    l_count := 0;
    for c_rec in cAcct loop
      l_count := l_count + 1;
      if c_rec.period_from = c_rec.period_to then
        l_all_buckets := l_all_buckets || c_rec.period_from || '|';
      else
        l_all_buckets := l_all_buckets || c_rec.period_from || ' - '
		|| c_rec.period_to || '|';
      end if;
    end loop;
  end if;

  return l_all_buckets;

END Aging_Buckets_String;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Delete_Forecast_Children					|
|									|
|  DESCRIPTION								|
|	This procedure deletes all children of a particular forecast	|
|  from CE_FORECAST_CELLS, CE_FORECAST_TRX_CELLS and 			|
|  CE_FORECAST_OPENING_BAL tables.					|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|	Forecast_Id							|
|  HISTORY								|
|	04-FEB-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Delete_Forecast_Children (X_forecast_id NUMBER) IS
  l_count 	NUMBER;
BEGIN
  select count(1)
  into l_count
  from ce_forecast_cells
  where forecast_id = X_forecast_id;

  if l_count > 0 then
    delete from ce_forecast_cells where forecast_id = X_forecast_id;
  end if;

  select count(1)
  into l_count
  from ce_forecast_trx_cells
  where forecast_id = X_forecast_id;

  if l_count > 0 then
    delete from ce_forecast_trx_cells where forecast_id = X_forecast_id;
  end if;

  select count(1)
  into l_count
  from ce_forecast_opening_bal
  where forecast_id = X_forecast_id;

  if l_count > 0 then
    delete from ce_forecast_opening_bal where forecast_id = X_forecast_id;
  end if;

  select count(1)
  into l_count
  from ce_forecast_errors
  where forecast_id = X_forecast_id;

  if l_count > 0 then
    delete from ce_forecast_errors where forecast_id = X_forecast_id;
  end if;

END Delete_Forecast_Children;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Create_Dummy_Rows						|
|									|
|  DESCRIPTION								|
|	This procedure fills the new manually created rows of		|
|  User-defined Inflow or Outflow in a forecast	with zeroes		|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|	Forecast_Header_Id						|
|  HISTORY								|
|	26-FEB-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Create_Dummy_Rows (X_forecast_header_id NUMBER) IS
  CURSOR C_fc IS SELECT forecast_id
		FROM 	ce_forecasts
		WHERE	forecast_header_id = X_forecast_header_id;
  CURSOR C_frow(p_forecast_id NUMBER) IS SELECT forecast_row_id
		FROM 	ce_forecast_rows
		WHERE 	forecast_header_id = X_forecast_header_id
		AND	forecast_row_id not in
			(select forecast_row_id
			from ce_forecast_cells
			where forecast_header_id = X_forecast_header_id
			and forecast_id = p_forecast_id);
  CURSOR C_frow_trx(p_forecast_id NUMBER) IS SELECT forecast_row_id
		FROM 	ce_forecast_rows
		WHERE 	forecast_header_id = X_forecast_header_id
		AND	forecast_row_id not in
			(select forecast_row_id
			from ce_forecast_trx_cells
			where forecast_header_id = X_forecast_header_id
			and forecast_id = p_forecast_id);

  forecast_rowid VARCHAR2(30);
  forecast_cell_id NUMBER;
  l_forecast_column_id NUMBER;
  l_count NUMBER;
BEGIN
  SELECT forecast_column_id
  INTO l_forecast_column_id
  FROM ce_forecast_columns
  WHERE forecast_header_id = X_forecast_header_id
  AND developer_column_num = 1;

  FOR p_fc IN C_fc LOOP
    SELECT count(1)
    INTO l_count
    FROM ce_forecast_cells
    WHERE forecast_id = p_fc.forecast_id;
    IF l_count > 0 THEN
      FOR p_frow IN C_frow(p_fc.forecast_id) LOOP
	forecast_cell_id := NULL;
	forecast_rowid := NULL;
	CE_FORECAST_CELLS_PKG.insert_row(
		X_rowid			=>forecast_rowid,
		X_FORECAST_CELL_ID	=>forecast_cell_id,
		X_FORECAST_ID		=>p_fc.forecast_id,
		X_FORECAST_HEADER_ID	=>X_forecast_header_id,
		X_FORECAST_ROW_ID	=>p_frow.forecast_row_id,
		X_FORECAST_COLUMN_ID	=>l_forecast_column_id,
		X_AMOUNT		=>0,
		X_CREATED_BY		=>nvl(fnd_global.user_id,-1),
		X_CREATION_DATE		=>sysdate,
		X_LAST_UPDATED_BY	=>nvl(fnd_global.user_id,-1),
		X_LAST_UPDATE_DATE	=>sysdate,
		X_LAST_UPDATE_LOGIN	=>nvl(fnd_global.user_id,-1));
      END LOOP;
    END IF;

    SELECT count(1)
    INTO l_count
    FROM ce_forecast_trx_cells
    WHERE forecast_id = p_fc.forecast_id;
    IF l_count > 0 THEN
      FOR p_frow_trx IN C_frow_trx(p_fc.forecast_id) LOOP
	forecast_cell_id := NULL;
	forecast_rowid := NULL;
	CE_FORECAST_TRX_CELLS_PKG.insert_row(
		X_rowid			=>forecast_rowid,
		X_FORECAST_CELL_ID	=>forecast_cell_id,
		X_FORECAST_ID		=>p_fc.forecast_id,
		X_FORECAST_HEADER_ID	=>X_forecast_header_id,
		X_FORECAST_ROW_ID	=>p_frow_trx.forecast_row_id,
		X_FORECAST_COLUMN_ID	=>l_forecast_column_id,
		X_AMOUNT		=>0,
		X_TRX_AMOUNT		=>to_number(null),
		X_REFERENCE_ID 		=>null,
		X_CURRENCY_CODE   	=>null,
		X_ORG_ID		=>null,
		X_INCLUDE_FLAG		=>'Y',
		X_TRX_DATE		=>null,
		X_BANK_ACCOUNT_ID	=>null,
		X_CODE_COMBINATION_ID	=>null,
		X_CREATED_BY		=>nvl(fnd_global.user_id,-1),
		X_CREATION_DATE		=>sysdate,
		X_LAST_UPDATED_BY	=>nvl(fnd_global.user_id,-1),
		X_LAST_UPDATE_DATE	=>sysdate,
		X_LAST_UPDATE_LOGIN	=>nvl(fnd_global.user_id,-1));
      END LOOP;
    END IF;
  END LOOP;

END Create_Dummy_Rows;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Update_Column_Setup						|
|									|
|  DESCRIPTION								|
|	This procedure updates the column setup from Automatic		|
|	to Manual for the case where columns were manually added	|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|	Forecast Header Id						|
|  HISTORY								|
|	14-MAR-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Update_Column_Setup (X_forecast_header_id NUMBER) IS
  l_column_setup VARCHAR2(1);
BEGIN
  select column_setup
  into l_column_setup
  from ce_forecast_headers
  where forecast_header_id = X_forecast_header_id;

  if l_column_setup = 'A' then
    update ce_forecast_headers
    set column_setup = 'M'
    where forecast_header_id = X_forecast_header_id;
  end if;

END Update_Column_Setup;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Duplicate_Template						|
|									|
|  DESCRIPTION								|
|	This procedure duplicates a forecast template			|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|	Forecast Header Id, New Template Name				|
|  HISTORY								|
|	03-MAR-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Duplicate_Template (X_forecast_header_id NUMBER,
				X_new_name VARCHAR2,
				X_forecast_id NUMBER DEFAULT NULL) IS
  CURSOR C_frow IS SELECT forecast_row_id,
			forecast_header_id,
			row_number,
			trx_type,
			lead_time,
			forecast_method,
			discount_option,
			order_status,
			order_date_type,
			code_combination_id,
			set_of_books_id,
			org_id,
			chart_of_accounts_id,
			budget_name,
			budget_version_id,
			encumbrance_type_id,
			roll_forward_type,
			roll_forward_period,
			customer_profile_class_id,
			include_dispute_flag,
			sales_stage_id,
			channel_code,
			win_probability,
                        sales_forecast_status,
			receipt_method_id,
			bank_account_id,
			payment_method,
			pay_group,
			payment_priority,
			vendor_type,
			authorization_status,
			type,
			budget_type,
			budget_version,
			include_hold_flag,
                   	include_net_cash_flag,
			xtr_bank_account,
			exclude_indic_exp,
			company_code,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			org_payment_method_id,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			description,
			payroll_id,
			external_source_type,
			criteria_category,
			criteria1,
			criteria2,
			criteria3,
			criteria4,
			criteria5,
			criteria6,
			criteria7,
			criteria8,
			criteria9,
			criteria10,
			criteria11,
			criteria12,
			criteria13,
			criteria14,
			criteria15,
                        use_average_payment_days,
                        period,
                        order_type_id,
                        use_payment_terms
		  FROM ce_forecast_rows
		  WHERE forecast_header_id = X_forecast_header_id;

  CURSOR C_fcol IS SELECT forecast_column_id,
			forecast_header_id,
			column_number,
			days_from,
			days_to,
			developer_column_num,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		  FROM ce_forecast_columns
		  WHERE forecast_header_id = X_forecast_header_id;

  CURSOR C_fperiod IS SELECT forecast_period_id,
			forecast_header_id,
			level_of_summary,
			period_number,
			length_of_period,
			length_type,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
		  FROM ce_forecast_periods
		  WHERE forecast_header_id = X_forecast_header_id;

  l_forecast_header_id NUMBER;
  l_forecast_row_id NUMBER;
  l_forecast_column_id NUMBER;
  l_forecast_period_id NUMBER;
  l_drilldown_flag VARCHAR2(1);
BEGIN
  select ce_forecast_headers_s.nextval
  into l_forecast_header_id
  from dual;

  INSERT INTO ce_forecast_headers(
			forecast_header_id,
			name,
			description,
			aging_type,
			overdue_transactions,
			cutoff_period,
			transaction_calendar_id,
                        start_project_id,
                        end_project_id,
                        treasury_template,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		) SELECT l_forecast_header_id,
			X_new_name,
			description,
			aging_type,
			overdue_transactions,
			cutoff_period,
			transaction_calendar_id,
                	start_project_id,
                	end_project_id,
			treasury_template,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		  FROM ce_forecast_headers
		  WHERE forecast_header_id = X_forecast_header_id;

  if X_forecast_id is not null then
    select nvl(drilldown_flag,'N')
    into l_drilldown_flag
    from ce_forecasts
    where forecast_id = X_forecast_id;

    UPDATE ce_forecasts
    SET forecast_header_id = l_forecast_header_id
    WHERE forecast_id = X_forecast_id;

    if l_drilldown_flag = 'Y' then
      UPDATE ce_forecast_trx_cells
      SET forecast_header_id = l_forecast_header_id
      WHERE forecast_id = X_forecast_id;
    else
      UPDATE ce_forecast_cells
      SET forecast_header_id = l_forecast_header_id
      WHERE forecast_id = X_forecast_id;
    end if;
  end if;


  FOR p_frow in C_frow LOOP
    select ce_forecast_rows_s.nextval
    into l_forecast_row_id
    from dual;

    INSERT INTO ce_forecast_rows(
			forecast_row_id,
			forecast_header_id,
			row_number,
			trx_type,
			lead_time,
			forecast_method,
			discount_option,
			order_status,
			order_date_type,
			code_combination_id,
			set_of_books_id,
			org_id,
			chart_of_accounts_id,
			budget_name,
			budget_version_id,
			encumbrance_type_id,
			roll_forward_type,
			roll_forward_period,
			customer_profile_class_id,
			include_dispute_flag,
			sales_stage_id,
			channel_code,
			win_probability,
                        sales_forecast_status,
			receipt_method_id,
			bank_account_id,
			payment_method,
			pay_group,
			payment_priority,
			vendor_type,
			authorization_status,
			type,
			budget_type,
			budget_version,
			include_hold_flag,
                	include_net_cash_flag,
			xtr_bank_account,
			exclude_indic_exp,
			company_code,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			org_payment_method_id,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			description,
			payroll_id,
			external_source_type,
			criteria_category,
			criteria1,
			criteria2,
			criteria3,
			criteria4,
			criteria5,
			criteria6,
			criteria7,
			criteria8,
			criteria9,
			criteria10,
			criteria11,
			criteria12,
			criteria13,
			criteria14,
			criteria15,
                        use_average_payment_days,
                        period,
                        order_type_id,
                        use_payment_terms
		) VALUES (l_forecast_row_id,
			l_forecast_header_id,
			p_frow.row_number,
			p_frow.trx_type,
			p_frow.lead_time,
			p_frow.forecast_method,
			p_frow.discount_option,
			p_frow.order_status,
			p_frow.order_date_type,
			p_frow.code_combination_id,
			p_frow.set_of_books_id,
			p_frow.org_id,
			p_frow.chart_of_accounts_id,
			p_frow.budget_name,
			p_frow.budget_version_id,
			p_frow.encumbrance_type_id,
			p_frow.roll_forward_type,
			p_frow.roll_forward_period,
			p_frow.customer_profile_class_id,
			p_frow.include_dispute_flag,
			p_frow.sales_stage_id,
			p_frow.channel_code,
			p_frow.win_probability,
                        p_frow.sales_forecast_status,
			p_frow.receipt_method_id,
			p_frow.bank_account_id,
			p_frow.payment_method,
			p_frow.pay_group,
			p_frow.payment_priority,
			p_frow.vendor_type,
			p_frow.authorization_status,
			p_frow.type,
			p_frow.budget_type,
			p_frow.budget_version,
			p_frow.include_hold_flag,
                   	p_frow.include_net_cash_flag,
			p_frow.xtr_bank_account,
			p_frow.exclude_indic_exp,
			p_frow.company_code,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			p_frow.org_payment_method_id,
			p_frow.attribute_category,
			p_frow.attribute1,
			p_frow.attribute2,
			p_frow.attribute3,
			p_frow.attribute4,
			p_frow.attribute5,
			p_frow.attribute6,
			p_frow.attribute7,
			p_frow.attribute8,
			p_frow.attribute9,
			p_frow.attribute10,
			p_frow.attribute11,
			p_frow.attribute12,
			p_frow.attribute13,
			p_frow.attribute14,
			p_frow.attribute15,
			p_frow.description,
			p_frow.payroll_id,
			p_frow.external_source_type,
			p_frow.criteria_category,
			p_frow.criteria1,
			p_frow.criteria2,
			p_frow.criteria3,
			p_frow.criteria4,
			p_frow.criteria5,
			p_frow.criteria6,
			p_frow.criteria7,
			p_frow.criteria8,
			p_frow.criteria9,
			p_frow.criteria10,
			p_frow.criteria11,
			p_frow.criteria12,
			p_frow.criteria13,
			p_frow.criteria14,
			p_frow.criteria15,
                        p_frow.use_average_payment_days,
                        p_frow.period,
                        p_frow.order_type_id,
                        p_frow.use_payment_terms);

    if X_forecast_id is not null then
      if l_drilldown_flag = 'Y' then
        update ce_forecast_trx_cells
        set forecast_row_id = l_forecast_row_id
        where forecast_row_id = p_frow.forecast_row_id
        and forecast_id = X_forecast_id;
      else
        update ce_forecast_cells
        set forecast_row_id = l_forecast_row_id
        where forecast_row_id = p_frow.forecast_row_id
        and forecast_id = X_forecast_id;
      end if;
    end if;
  END LOOP;

  FOR p_fcol in C_fcol LOOP
    select ce_forecast_columns_s.nextval
    into l_forecast_column_id
    from dual;

    INSERT INTO ce_forecast_columns(
			forecast_column_id,
			forecast_header_id,
			column_number,
			days_from,
			days_to,
			developer_column_num,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15
		) VALUES (l_forecast_column_id,
			l_forecast_header_id,
			p_fcol.column_number,
			p_fcol.days_from,
			p_fcol.days_to,
			p_fcol.developer_column_num,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			p_fcol.attribute_category,
			p_fcol.attribute1,
			p_fcol.attribute2,
			p_fcol.attribute3,
			p_fcol.attribute4,
			p_fcol.attribute5,
			p_fcol.attribute6,
			p_fcol.attribute7,
			p_fcol.attribute8,
			p_fcol.attribute9,
			p_fcol.attribute10,
			p_fcol.attribute11,
			p_fcol.attribute12,
			p_fcol.attribute13,
			p_fcol.attribute14,
			p_fcol.attribute15);

    if X_forecast_id is not null then
      if l_drilldown_flag = 'Y' then
        update ce_forecast_trx_cells
        set forecast_column_id = l_forecast_column_id
        where forecast_column_id = p_fcol.forecast_column_id
        and forecast_id = X_forecast_id;
      else
        update ce_forecast_cells
        set forecast_column_id = l_forecast_column_id
        where forecast_column_id = p_fcol.forecast_column_id
        and forecast_id = X_forecast_id;
      end if;
    end if;
  END LOOP;

  FOR p_fperiod in C_fperiod LOOP
    select ce_forecast_periods_s.nextval
    into l_forecast_period_id
    from dual;

    INSERT INTO ce_forecast_periods(
			forecast_period_id,
			forecast_header_id,
			level_of_summary,
			period_number,
			length_of_period,
			length_type,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
		) VALUES (l_forecast_period_id,
			p_fperiod.forecast_header_id,
			p_fperiod.level_of_summary,
			p_fperiod.period_number,
			p_fperiod.length_of_period,
			p_fperiod.length_type,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1),
			sysdate,
			nvl(fnd_global.user_id,-1)
		);
  END LOOP;

END Duplicate_Template;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE							|
|	populate_temp_buckets						|
|									|
|  DESCRIPTION								|
|	Populates ce_forecast_columns based on the aging-bucket         |
|	information in ce_forecast_periods                              |
|  CALLED BY								|
|	populate_aging_buckets						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	29-OCT-2001	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */
PROCEDURE populate_temp_buckets ( p_forecast_header_id NUMBER,
				p_start_date DATE) IS
  CURSOR C_periods IS
    SELECT 	forecast_header_id,
		period_number,
	   	level_of_summary,
	   	length_of_period,
           	length_type,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login
    FROM   	ce_forecast_periods
    WHERE	forecast_header_id = p_forecast_header_id
    ORDER BY	period_number;


    l_period_number	NUMBER;
    l_level_of_summary	VARCHAR2(1);
    l_length_of_period  NUMBER;
    l_length_type	VARCHAR2(1);

    l_start_date	DATE;
    l_end_date		DATE;

    l_current_date 	DATE;
    l_new_current_date 	DATE;

    l_period_id		NUMBER := 0;
    l_count		NUMBER := 0;
    l_column_num        NUMBER := 0;

    l_days_from		NUMBER := 1;
    l_days_to		NUMBER := 0;

BEGIN

/*  BEGIN
  DELETE FROM ce_forecast_columns
  WHERE forecast_header_id = p_forecast_header_id
  AND developer_column_num > 0;
  IF SQL%FOUND THEN
	COMMIT;
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
	CEP_STANDARD.DEBUG('EXCEPTION:populate_temp_buckets-->delete');
 	RAISE;
  END;
*/

  l_start_date := p_start_date;
  l_start_date := TRUNC(l_start_date);
  FOR p_rec IN C_periods LOOP

    IF p_rec.length_type = 'D' THEN
      l_end_date := l_start_date + p_rec.length_of_period - 1;
    ELSIF p_rec.length_type = 'W' THEN
      l_end_date := (l_start_date-1 + (p_rec.length_of_period * 7));
    ELSIF p_rec.length_type = 'M' THEN
      l_end_date := LAST_DAY(ADD_MONTHS(l_start_date,(p_rec.length_of_period-1)));
    ELSE
      l_end_date := LAST_DAY(ADD_MONTHS(l_start_date,((p_rec.length_of_period*12)-1)));
    END IF;

    IF p_rec.level_of_summary = 'D' THEN
      l_count := l_end_date - l_start_date + 1;
      l_current_date := l_start_date;
      FOR i IN 1 .. l_count LOOP
  	l_column_num := l_column_num + 1;
	l_days_to := l_days_from;

	IF l_column_num <= 80 THEN
          INSERT INTO ce_forecast_columns(forecast_column_id, forecast_header_id, column_number, days_from, days_to, developer_column_num, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
          VALUES (ce_forecast_columns_s.nextval, p_rec.forecast_header_id, l_column_num, l_days_from, l_days_to, l_column_num, p_rec.created_by, p_rec.creation_date, p_rec.last_updated_by, p_rec.last_update_date, p_rec.last_update_login);
	ELSE
	  --More than 80 columns
	  EXIT;
	END IF;

	l_days_from := l_days_to + 1;
	l_current_date := l_current_date + 1;
      END LOOP;

    ELSIF p_rec.level_of_summary = 'W' THEN
      l_current_date := l_start_date;
      WHILE (l_current_date <  l_end_date) LOOP
        l_column_num := l_column_num + 1;
	l_days_to := l_days_from + 6;

	IF l_column_num <= 80 THEN
          INSERT INTO ce_forecast_columns(forecast_column_id, forecast_header_id, column_number, days_from, days_to, developer_column_num, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
          VALUES (ce_forecast_columns_s.nextval, p_rec.forecast_header_id, l_column_num, l_days_from, l_days_to, l_column_num, p_rec.created_by, p_rec.creation_date, p_rec.last_updated_by, p_rec.last_update_date, p_rec.last_update_login);
	ELSE
	  --More than 80 columns
	  EXIT;
	END IF;

	l_days_from := l_days_to + 1;
        l_current_date := l_current_date + 7;

      END LOOP;
    ELSIF p_rec.level_of_summary = 'M' THEN
      l_current_date := l_start_date;
      WHILE (l_current_date < l_end_date) LOOP
        l_column_num := l_column_num + 1;
	l_days_to := l_days_from + TRUNC(LAST_DAY(l_current_date)) - l_current_date;

	IF l_column_num <= 80 THEN
          INSERT INTO ce_forecast_columns(forecast_column_id, forecast_header_id, column_number, days_from, days_to, developer_column_num, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
          VALUES (ce_forecast_columns_s.nextval, p_rec.forecast_header_id, l_column_num, l_days_from, l_days_to, l_column_num, p_rec.created_by, p_rec.creation_date, p_rec.last_updated_by, p_rec.last_update_date, p_rec.last_update_login);
	ELSE
	  --More than 80 columns
	  EXIT;
	END IF;

	l_days_from := l_days_to + 1;
	l_current_date := TRUNC(ADD_MONTHS(l_current_date,1), 'MONTH');

      END LOOP;
    END IF;

    cep_standard.debug('Start Date: '||l_start_date);
    cep_standard.debug('End Date: '||l_end_date);
    l_start_date := l_current_date;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
	IF C_periods%ISOPEN THEN CLOSE C_periods; END IF;
	CEP_STANDARD.DEBUG('EXCEPTION:populate_temp_buckets');
	raise;
END populate_temp_buckets;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Submit_Forecast							|
|									|
|  DESCRIPTION								|
|	This procedure submits the forecast via a concurrent program	|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	20-MAY-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Submit_Forecast(p_forecast_header_id	IN NUMBER,
		p_forecast_name		IN VARCHAR2,
		p_start_project_num	IN VARCHAR2,
                p_end_project_num	IN VARCHAR2,
		p_calendar_name		IN VARCHAR2,
		p_forecast_start_date	IN VARCHAR2,
		p_forecast_start_period	IN VARCHAR2,
		p_forecast_currency	IN VARCHAR2,
		p_src_curr_type		IN VARCHAR2,
		p_src_currency		IN VARCHAR2,
		p_exchange_date		IN VARCHAR2,
		p_exchange_type		IN VARCHAR2,
		p_exchange_rate		IN NUMBER,
		p_amount_threshold	IN NUMBER,
		p_rownum_from		IN NUMBER,
		p_rownum_to		IN NUMBER,
		p_sub_request		IN VARCHAR2,
		p_factor		IN NUMBER,
		p_include_sub_account	IN VARCHAR2,
		p_view_by		IN VARCHAR2,
		p_bank_balance_type	IN VARCHAR2,
		p_float_type		IN VARCHAR2,
		p_fc_name_exists	IN VARCHAR2) IS
  l_forecast_rowid 	VARCHAR2(30);
  l_forecast_id 	NUMBER;
  l_aging_type 		VARCHAR2(1);
  l_request_id 		NUMBER;
BEGIN
  SELECT aging_type
  INTO l_aging_type
  FROM ce_forecast_headers
  WHERE forecast_header_id = p_forecast_header_id;

  IF (p_start_project_num is null AND p_end_project_num is null
	AND nvl(p_sub_request,'N') = 'N') THEN
    CE_FORECASTS_TABLE_PKG.Insert_Row(
			X_Rowid			=> l_forecast_rowid,
			X_forecast_id		=> l_forecast_id,
			X_forecast_header_id	=> p_forecast_header_id,
			X_name			=> p_forecast_name,
			X_description		=> null,
			X_start_date		=> to_date(p_forecast_start_date,'DD/MM/RRRR'),
			X_period_set_name	=> p_calendar_name,
			X_start_period		=> p_forecast_start_period,
			X_forecast_currency	=> p_forecast_currency,
			X_currency_type		=> p_src_curr_type,
			X_source_currency	=> p_src_currency,
			X_exchange_rate_type	=> p_exchange_type,
			X_exchange_date		=> to_date(p_exchange_date,'DD/MM/RRRR'),
			X_exchange_rate		=> p_exchange_rate,
			X_error_status		=> 'P',
			X_amount_threshold	=> p_amount_threshold,
			X_project_id		=> null,
			X_drilldown_flag	=> 'Y',
			X_bank_balance_type	=> p_bank_balance_type,
			X_float_type		=> p_float_type,
			X_view_by		=> p_view_by,
			X_include_sub_account	=> p_include_sub_account,
			X_factor		=> p_factor,
			X_request_id		=> null,
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
  END IF;

  IF l_aging_type = 'D' THEN
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE', 'CEFCSTBD','','',NULL,
                p_forecast_header_id,
                p_forecast_name,
		p_factor,
		p_start_project_num,
		p_end_project_num,
		p_calendar_name,
                to_char(to_date(p_forecast_start_date,'DD-MM-RRRR'),
			'YYYY/MM/DD HH24:MI:SS'),
                p_forecast_currency,
                p_src_curr_type,
                null,
                p_src_currency,
                to_char(to_date(p_exchange_date,'DD-MM-RRRR'),
			'YYYY/MM/DD HH24:MI:SS'),
                p_exchange_type,
                p_exchange_rate,
                p_rownum_from,
                p_rownum_to,
                p_amount_threshold,
		'N',
		p_view_by,
		null,
		p_bank_balance_type,
		p_float_type,
		p_include_sub_account,
		to_char(l_forecast_id),
		'N',
		null,
		null,
		p_fc_name_exists,
                fnd_global.local_chr(0),'',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','');
  ELSE
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                'CE', 'CEFCSHAP','','',NULL,
                p_forecast_header_id,
                p_forecast_name,
		p_factor,
		p_start_project_num,
		p_end_project_num,
                p_calendar_name,
                p_forecast_start_period,
                p_forecast_currency,
                p_src_curr_type,
                null,
                p_src_currency,
                to_char(to_date(p_exchange_date,'DD-MM-RRRR'),
			'YYYY/MM/DD HH24:MI:SS'),
                p_exchange_type,
                p_exchange_rate,
            	p_rownum_from,
                p_rownum_to,
                p_amount_threshold,
		'N',
		p_view_by,
		null,
		p_bank_balance_type,
		p_float_type,
		p_include_sub_account,
		to_char(l_forecast_id),
                null,
		'N',
		null,
		null,
		p_fc_name_exists,
		fnd_global.local_chr(0),
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','',
                '','','','','','','','','','');
  END IF;

  UPDATE ce_forecasts
  SET request_id = l_request_id
  WHERE forecast_id = l_forecast_id;

EXCEPTION
  WHEN OTHERS THEN
	cep_standard.debug('EXCEPTION: CE_FORECAST_UTILS.Submit_Forecast');
	RAISE;

END Submit_Forecast;


/* ---------------------------------------------------------------------
|  PUBLIC PROCEDRE							|
|	Refresh_Processing_Status					|
|									|
|  DESCRIPTION								|
|	This procedure refreshes the processing status of the forecast	|
|									|
|  CALLED BY								|
|	OA Controller Classes						|
|  REQUIRES								|
|									|
|  HISTORY								|
|	12-MAY-2003	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

PROCEDURE Refresh_Processing_Status IS
  CURSOR C_fc IS SELECT forecast_id,
			request_id
		FROM ce_forecasts
		WHERE error_status in ('P','R','X')
		AND request_id is not null;
  call_status 	BOOLEAN;
  rphase	VARCHAR2(80);
  rstatus	VARCHAR2(80);
  dphase	VARCHAR2(30);
  dstatus	VARCHAR2(30);
  message	VARCHAR2(240);
BEGIN
  FOR p_fc in C_fc LOOP
    call_status := FND_CONCURRENT.GET_REQUEST_STATUS(p_fc.request_id,'','',
		rphase, rstatus, dphase, dstatus, message);
    IF (dstatus in ('ERROR','CANCELLED','TERMINATED')) THEN
      UPDATE ce_forecasts
      SET error_status = 'F'
      WHERE forecast_id = p_fc.forecast_id;
    END IF;
    IF (dphase = 'RUNNING') THEN
      UPDATE ce_forecasts
      SET error_status = 'R'
      WHERE forecast_id = p_fc.forecast_id
      AND error_status = 'P';
    END IF;
 END LOOP;
END Refresh_Processing_Status;

/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	FUNCTION IS_INSTALLED						|
|									|
|  DESCRIPTION								|
|	This function checks the installation status 			|
| 									|
|  CALLED BY								|
|	OA Controller Classes				|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	24-MAY-2003 (2am)	Created		Helen Han		|
 --------------------------------------------------------------------- */

FUNCTION IS_INSTALLED(X_prod_id number) RETURN VARCHAR2 IS
  l_temp	BOOLEAN;
  l_status	VARCHAR2(1);
  l_dummy	VARCHAR2(100);
BEGIN
  l_temp := FND_INSTALLATION.get(X_prod_id, X_prod_id, l_status, l_dummy);
  if (l_status <> 'I') then
    return 'N';
  else
    return 'Y';
  end if;
END IS_INSTALLED;


/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	XTR_USER							|
|									|
|  DESCRIPTION								|
|	This function checks whether the current user 			|
|	is a Treasury User						|
| 									|
|  CALLED BY								|
|	CHECK_SECURITY							|
|									|
|  REQUIRES								|
|									|
|  HISTORY								|
|	27-FEB-2002	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

FUNCTION XTR_USER RETURN NUMBER IS
  l_cnt 	number;
BEGIN
  select count(1)
  into   l_cnt
  from   xtr_dealer_codes
  where  user_id = fnd_global.user_id;

  if l_cnt = 0 then
    return 0;
  else
    return 1;
  end if;
END XTR_USER;

/* ---------------------------------------------------------------------
|  PUBLIC FUNCTION							|
|	CHECK_SECURITY							|
|									|
|  DESCRIPTION								|
|	This function enforces Treasury's Legal Entity security		|
|  									|
|  CALLED BY								|
|	Forecasting Results views					|
|									|
|  REQUIRES								|
|	Legal Enitity ID						|
|  HISTORY								|
|	27-FEB-2002	Created		Sunil Poonen			|
 --------------------------------------------------------------------- */

FUNCTION CHECK_SECURITY (X_le_id NUMBER) RETURN NUMBER IS
  l_user_id	number;
  l_cnt     	number;
BEGIN
  if (XTR_USER = 0 OR X_le_id is null) then  -- not an XTR user
    return 1;
  end if;

  select count(1)
  into   l_cnt
  from   xtr_parties_v
  where  legal_entity_id = X_le_id;

  if l_cnt = 0 then
    return 0;
  else
    return 1;
  end if;
END CHECK_SECURITY;

PROCEDURE populate_dev_columns ( p_forecast_header_id NUMBER) IS

  cursor col_cur (hid number) is
    select rowid, forecast_column_id, forecast_header_id, column_number
    from   ce_forecast_columns
    where  forecast_header_id = hid
    and column_number <> 0                          -- Bug 8998714
    order by column_number
    for update nowait;

  TYPE  RowIDTab IS TABLE OF VARCHAR2(18) INDEX BY BINARY_INTEGER;
  TYPE  Num15Tab IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  l_rowid    RowIDTab;
  l_hid      Num15Tab;
  l_cid      Num15Tab;
  l_col_num  Num15Tab;
  l_dev_num  Num15Tab;
  ct         NUMBER;

BEGIN

  if p_forecast_header_id is not null then
    OPEN col_cur(p_forecast_header_id);
    l_rowid.delete;
    l_dev_num.delete;
    l_cid.delete;
    l_hid.delete;
    l_col_num.delete;
    ct := 0;

    FETCH col_cur BULK COLLECT INTO
	l_rowid, l_cid, l_hid, l_col_num;

    if (l_cid.count > 0) then

      for i in l_cid.first..l_cid.last
      loop
	ct := ct+1;
        l_dev_num(i) := ct;
      end loop;

      forall i in l_cid.first..l_cid.last
        update ce_forecast_columns
        set    developer_column_num = l_dev_num(i)
        where  forecast_column_id = l_cid(i);

    end if;

    CLOSE col_cur;

  end if;

END populate_dev_columns;


END CE_FORECAST_UTILS;

/

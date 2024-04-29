--------------------------------------------------------
--  DDL for Package Body CE_FORECASTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECASTS_PKG" AS
/* $Header: cefcastb.pls 120.4 2003/07/31 23:44:32 sspoonen ship $ */

FUNCTION body_revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.4 $';

END body_revision;

FUNCTION spec_revision RETURN VARCHAR2 IS
BEGIN

  RETURN G_spec_revision;

END spec_revision;

PROCEDURE set_factor(X_factor NUMBER) IS
BEGIN
  CE_FORECASTS_PKG.G_factor := X_factor;
END;

FUNCTION get_factor RETURN NUMBER IS
BEGIN
  return (CE_FORECASTS_PKG.G_factor);
END;

PROCEDURE create_empty_forecast(X_rowid			IN OUT NOCOPY VARCHAR2,
				X_forecast_id	        IN OUT NOCOPY NUMBER,
				X_forecast_header_id    NUMBER,
                                X_forecast_name         VARCHAR2,
				X_forecast_dsp		VARCHAR2,
                                X_start_date            DATE,
                                X_period_set_name	VARCHAR2,
				X_start_period          VARCHAR2,
				X_forecast_currency     VARCHAR2,
				X_currency_type	        VARCHAR2,
				X_source_currency	VARCHAR2,
				X_exchange_rate_type    VARCHAR2,
				X_exchange_date	        DATE,
				X_exchange_rate		NUMBER,
				X_amount_threshold	NUMBER,
				X_project_id		NUMBER,
				X_created_by            NUMBER,
				X_creation_date         DATE,
				X_last_updated_by       NUMBER,
				X_last_update_date      DATE,
				X_last_update_login     NUMBER) IS
  cursor cr is select 	forecast_row_id, trx_type
               from 	ce_forecast_rows
               where 	forecast_header_id = X_forecast_header_id
               order by row_number;
  cursor cc is select 	forecast_column_id
               from 	ce_forecast_columns
               where 	forecast_header_id = X_forecast_header_id
               order by column_number;
  cid           number;
  rid           number;
  cell_id	number;
  rcount        number;
  ccount        number;
  num_rows      number;
  num_cols      number;
  p_rowid	VARCHAR2(100);
  trx		ce_forecast_rows.trx_type%TYPE;
  glc_rowid	number default 0;

BEGIN
  --
  -- Insert new forecast into forecast table
  --
  CE_FORECASTS_TABLE_PKG.insert_row(
	X_rowid			=> X_rowid,
	X_forecast_id		=> X_forecast_id,
	X_forecast_header_id	=> X_forecast_header_id,
	X_name			=> X_forecast_name,
	X_description		=> X_forecast_dsp,
	X_start_date		=> X_start_date,
	X_period_set_name	=> X_period_set_name,
	X_start_period		=> X_start_period,
	X_forecast_currency	=> X_forecast_currency,
	X_currency_type		=> X_currency_type,
        X_source_currency	=> X_source_currency,
	X_exchange_rate_type	=> X_exchange_rate_type,
	X_exchange_date		=> X_exchange_date,
	X_exchange_rate		=> X_exchange_rate,
	X_error_status		=> 'S',
	X_amount_threshold	=> X_amount_threshold,
        X_project_id		=> X_project_id,
	X_drilldown_flag	=> null,
	X_bank_balance_type	=> null,
	X_float_type		=> null,
	X_view_by		=> null,
	X_include_sub_account	=> null,
	X_factor		=> 0,
	X_request_id		=> null,
	X_created_by		=> X_created_by,
	X_creation_date		=> X_creation_date,
        X_last_updated_by	=> X_last_updated_by,
        X_last_update_date	=> X_last_update_date,
        X_last_update_login	=> X_last_update_login,
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

  select count(r.forecast_row_id)
  into   num_rows
  from   ce_forecast_rows r
  where  r.forecast_header_id = X_forecast_header_id;

  select count(r.forecast_column_id)
  into   num_cols
  from   ce_forecast_columns r
  where  r.forecast_header_id = X_forecast_header_id;

  --
  -- Create cells for the forecast
  --
  open cr;
  for rcount in 1..num_rows loop
    fetch cr into rid, trx;
    if (trx = 'GLC') then
        glc_rowid := rid;
    else
        open cc;

        for ccount in 1..num_cols loop
            fetch cc into cid;
            cell_id := null;
            p_rowid := null;
            CE_FORECAST_CELLS_PKG.insert_row(
		X_Rowid             	=> p_rowid,
                X_forecast_cell_id      => cell_id,
                X_forecast_id           => X_forecast_id,
                X_forecast_header_id    => X_forecast_header_id,
                X_forecast_row_id       => rid,
                X_forecast_column_id    => cid,
                X_amount                => 0,
                X_Created_By            => X_created_by,
                X_Creation_Date         => X_creation_date,
                X_Last_Updated_By       => X_last_updated_by,
                X_Last_Update_Date      => X_last_update_date,
                X_Last_Update_Login     => X_last_update_login);
        end loop;
        close cc;
    end if;
  end loop;
  close cr;

	/* Create one single row for all GLC amounts, using last GLC row id #. */

	If (glc_rowid <> 0) then
		open cc;
		for ccount in 1..num_cols loop
			fetch cc into cid;
			cell_id := null;
			CE_FORECAST_CELLS_PKG.insert_row(
				X_Rowid             	=> p_rowid,
				X_forecast_cell_id      => cell_id,
				X_forecast_id           => X_forecast_id,
				X_forecast_header_id    => X_forecast_header_id,
				X_forecast_row_id       => glc_rowid,
				X_forecast_column_id    => cid,
				X_amount                => 0,
				X_Created_By            => X_created_by,
				X_Creation_Date         => X_creation_date,
				X_Last_Updated_By       => X_last_updated_by,
				X_Last_Update_Date      => X_last_update_date,
				X_Last_Update_Login     => X_last_update_login);
		end loop;
		close cc;
	end if;
EXCEPTION
  WHEN OTHERS THEN
    if (cc%ISOPEN) then close cc; end if;
    if (cr%ISOPEN) then close cr; end if;
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.create_empty_forecast');
    RAISE;
END;

PROCEDURE add_column(	X_new_forecast		VARCHAR2,
			X_forecast_column_id	IN OUT NOCOPY NUMBER,
			X_forecast_header_id	IN OUT NOCOPY NUMBER,
			X_column_number		NUMBER,
			X_days_from		NUMBER,
			X_days_to		NUMBER,
			X_created_by		NUMBER,
			X_creation_date		DATE,
			X_last_updated_by	NUMBER,
			X_last_update_date	DATE,
			X_last_update_login	NUMBER,
			X_forecast_id		NUMBER DEFAULT NULL,
			X_name			VARCHAR2 DEFAULT NULL) IS
  cursor cr is select 	row_number
               from 	ce_forecast_rows
               where 	forecast_header_id = X_forecast_header_id
                 and    trx_type = 'GLC';
  p_rowid			VARCHAR2(100);
  p_amount			NUMBER;
  p_line_number			NUMBER;
  p_forecast_row_id		NUMBER;
  p_forecast_cell_id		NUMBER;
  p_last_column_id		NUMBER;
  p_developer_column_num	NUMBER;
BEGIN
  cep_standard.debug('>> CE_FORECASTS_PKG.add_column');
  IF(X_new_forecast = 'Y')THEN
    CE_FORECASTS_PKG.duplicate_template_header(
			X_forecast_header_id	=> X_forecast_header_id,
			X_created_by		=> X_created_by,
			X_creation_date		=> X_creation_date,
			X_last_updated_by	=> X_last_updated_by,
			X_last_update_date	=> X_last_update_date,
			X_last_update_login	=> X_last_update_login,
			X_forecast_id		=> X_forecast_id,
			X_name			=> X_name);
  END IF;

  cep_standard.debug('   - insert new column');
  --
  -- Insert new column into column table
  --
  CE_FORECAST_COLUMNS_PKG.insert_row(
                X_rowid                 => p_rowid,
                X_forecast_column_id    => X_forecast_column_id,
                X_forecast_header_id    => X_forecast_header_id,
                X_column_number         => X_column_number,
                X_days_from             => X_days_from,
                X_days_to               => X_days_to,
		X_developer_column_num	=> to_number(null),
                X_created_by            => X_created_by,
                X_creation_date         => X_creation_date,
                X_last_updated_by       => X_last_updated_by,
                X_last_update_date      => X_last_update_date,
                X_last_update_login     => X_last_update_login,
                X_attribute_category    => null,
                X_attribute1            => null,
                X_attribute2            => null,
                X_attribute3            => null,
                X_attribute4            => null,
                X_attribute5            => null,
                X_attribute6            => null,
                X_attribute7            => null,
                X_attribute8            => null,
                X_attribute9            => null,
                X_attribute10           => null,
                X_attribute11           => null,
                X_attribute12           => null,
                X_attribute13           => null,
                X_attribute14           => null,
                X_attribute15           => null);

  cep_standard.debug('   - insert new cells');
  CE_FORECASTS_PKG.fill_cells(	X_forecast_header_id,
				'COLUMN',
				X_forecast_column_id,
				X_created_by,
				X_creation_date,
				X_last_updated_by,
				X_last_update_date,
				X_last_update_login );

  cep_standard.debug('   - rearrange column number');
  CE_FORECASTS_PKG.rearrange_column_number( X_forecast_header_id );

  cep_standard.debug('   - arrange GLC line');
  --
  -- If template contains GLC line, copy the GLC amount from the last
  -- column to the new column for GLC
  --
  select 	developer_column_num
  into	p_developer_column_num
  from	ce_forecast_columns
  where	forecast_column_id = X_forecast_column_id;

  select 	forecast_column_id
  into		p_last_column_id
  from		ce_forecast_columns
  where		forecast_header_id = X_forecast_header_id       and
        	developer_column_num = p_developer_column_num-1;

  OPEN cr;
  loop
    fetch cr into p_line_number;
    exit when cr%NOTFOUND;

    select	forecast_row_id
    into	p_forecast_row_id
    from	ce_forecast_rows
    where	forecast_header_id = X_forecast_header_id       and
		row_number = p_line_number;

    select	amount
    into	p_amount
    from	ce_forecast_cells
    where	forecast_header_id = X_forecast_header_id	and
		forecast_column_id = p_last_column_id	and
		forecast_row_id = p_forecast_row_id;

    select	forecast_cell_id
    into	p_forecast_cell_id
    from	ce_Forecast_cells
    where	forecast_header_id = X_forecast_header_id	and
		forecast_column_id = X_forecast_column_id	and
		forecast_row_id = p_forecast_row_id;

    CE_FORECAST_CELLS_PKG.update_row(
 		X_CELLID		=> p_forecast_cell_id,
 		X_AMOUNT		=> p_amount,
 		X_LAST_UPDATED_BY	=> X_last_updated_by,
 		X_LAST_UPDATE_DATE	=> X_last_update_date,
 		X_LAST_UPDATE_LOGIN	=> X_last_update_login );
  end loop;

  --
  -- Commit work
  --
  COMMIT;
  cep_standard.debug('<< CE_FORECASTS_PKG.add_column');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN OTHERS THEN
    IF SQLCODE <> -1422 THEN
         cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.add_column');
         RAISE;
    END IF;
END;

PROCEDURE add_row(	X_new_forecast		VARCHAR2,
			X_forecast_row_id	IN OUT NOCOPY NUMBER,
			X_forecast_header_id	IN OUT NOCOPY NUMBER,
			X_row_number		NUMBER,
			X_trx_type		VARCHAR2,
			X_created_by		NUMBER,
			X_creation_date		DATE,
			X_last_updated_by	NUMBER,
			X_last_update_date	DATE,
			X_last_update_login	NUMBER,
			X_forecast_id		NUMBER,
			X_name			VARCHAR2,
			X_description		VARCHAR2) IS
  p_rowid	varchar2(100);
BEGIN
  IF(X_new_forecast = 'Y')THEN
    CE_FORECASTS_PKG.duplicate_template_header(
			X_forecast_header_id	=> X_forecast_header_id,
			X_created_by		=> X_created_by,
			X_creation_date		=> X_creation_date,
			X_last_updated_by	=> X_last_updated_by,
			X_last_update_date	=> X_last_update_date,
			X_last_update_login	=> X_last_update_login,
			X_forecast_id		=> X_forecast_id,
			X_name			=> X_name);
    CE_FORECASTS_PKG.rearrange_column_number(X_forecast_header_id);
  END IF;

  CE_FORECAST_ROWS1_PKG.Insert_Row(
                X_rowid                 => p_rowid,
                X_forecast_row_id       => X_forecast_row_id,
                X_forecast_header_id    => X_forecast_header_id,
                X_row_number            => X_row_number,
                X_trx_type              => X_trx_type,
                X_lead_time             => to_number(null),
                X_forecast_method       => null,
                X_discount_option       => null,
                X_order_status          => null,
                X_order_date_type       => null,
                X_code_combination_id   => to_number(null),
                X_set_of_books_id       => to_number(null),
                X_org_id                => to_number(null),
                X_chart_of_accounts_id  => to_number(null),
                X_budget_name           => null,
		X_budget_version_id	=> to_number(null),
                X_encumbrance_type_id   => to_number(null),
		X_roll_forward_type	=> null,
		X_roll_forward_period	=> to_number(null),
		X_customer_profile_class_id => to_number(null),
		X_include_dispute_flag  => null,
		X_sales_stage_id	=> to_number(null),
		X_channel_code		=> null,
		X_win_probability	=> to_number(null),
                X_sales_forecast_status => null,
		X_receipt_method_id	=> to_number(null),
		X_bank_account_id	=> to_number(null),
		X_payment_method	=> null,
		X_pay_group		=> null,
		X_payment_priority	=> to_number(null),
		X_vendor_type		=> null,
		X_authorization_status	=> null,
		X_type			=> null,
		X_budget_type		=> null,
		X_budget_version	=> null,
		X_include_hold_flag	=> null,
		X_include_net_cash_flag	=> null,
                X_created_by            => X_created_by,
                X_creation_date         => X_creation_date,
                X_last_updated_by       => X_last_updated_by,
                X_last_update_date      => X_last_update_date,
                X_last_update_login     => X_last_update_login,
		X_org_payment_method_id	=> to_number(null),
		X_xtr_bank_account	=> null,
		X_exclude_indic_exp	=> null,
		X_company_code		=> null,
                X_attribute_category    => null,
                X_attribute1            => null,
                X_attribute2            => null,
                X_attribute3            => null,
                X_attribute4            => null,
                X_attribute5            => null,
                X_attribute6            => null,
                X_attribute7            => null,
                X_attribute8            => null,
                X_attribute9            => null,
                X_attribute10           => null,
                X_attribute11           => null,
                X_attribute12           => null,
                X_attribute13           => null,
                X_attribute14           => null,
                X_attribute15           => null,
		X_description		=> X_description,
		X_payroll_id		=> to_number(null),
		X_external_source_type	=> null,
		X_criteria_category	=> null,
		X_criteria1		=> null,
		X_criteria2		=> null,
		X_criteria3		=> null,
		X_criteria4		=> null,
		X_criteria5		=> null,
		X_criteria6		=> null,
		X_criteria7		=> null,
		X_criteria8		=> null,
		X_criteria9		=> null,
		X_criteria10		=> null,
		X_criteria11		=> null,
		X_criteria12		=> null,
		X_criteria13		=> null,
		X_criteria14		=> null,
		X_criteria15		=> null,
		X_use_average_payment_days
					=> null,
		X_period		=> to_number(null),
                X_order_type_id         => to_number(null),
                X_use_payment_terms     => null);

  CE_FORECASTS_PKG.fill_cells( X_forecast_header_id,
				'ROW',
				X_forecast_row_id,
				X_created_by,
				X_creation_date,
				X_last_updated_by,
				X_last_update_date,
				X_last_update_login );
  --
  -- Commit work
  --
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.add_row');
    RAISE;
END;

PROCEDURE fill_cells( 	X_header_id		NUMBER,
			X_col_or_row		VARCHAR2,
			X_new_id		NUMBER,
			X_created_by		NUMBER,
			X_creation_date		DATE,
			X_last_updated_by	NUMBER,
			X_last_update_date	DATE,
			X_last_update_login	NUMBER) IS
  cursor cf is select 	forecast_id
	       from 	ce_forecasts
	       where 	forecast_header_id = X_header_id;
  cursor cr(ffid number) is
	       select 	distinct(forecast_row_id)
               from 	ce_forecast_cells
               where 	forecast_id		= ffid;
  cursor cc is select 	forecast_column_id
               from 	ce_forecast_columns
               where 	forecast_header_id = X_header_id;
  p_rowid	varchar2(100);
  cid           number;
  rid           number;
  fid		number;
  cell_id	number;
  ccount        number;
  fcount	number;
BEGIN
  IF( X_col_or_row = 'COLUMN' )THEN
    cid := X_new_id;
  ELSE
    rid := X_new_id;
  END IF;

  open cf;
  loop
    fetch cf into fid;
    EXIT WHEN cf%NOTFOUND or cf%NOTFOUND IS NULL;
    if( X_col_or_row = 'COLUMN' ) THEN
      open cr(fid);
    else
      open cc;
    end if;
    loop
      if( X_col_or_row = 'COLUMN')THEN
        fetch cr into rid;
	EXIT WHEN cr%NOTFOUND or cr%NOTFOUND IS NULL;
      else
        fetch cc into cid;
	EXIT WHEN cc%NOTFOUND or cc%NOTFOUND IS NULL;
      end if;
      cell_id := null;
      CE_FORECAST_CELLS_PKG.insert_row(
                X_Rowid                 => p_rowid,
                X_forecast_cell_id      => cell_id,
                X_forecast_id           => fid,
                X_forecast_header_id    => X_header_id,
                X_forecast_row_id       => rid,
                X_forecast_column_id    => cid,
                X_amount                => 0,
                X_Created_By            => X_created_by,
                X_Creation_Date         => X_creation_date,
                X_Last_Updated_By       => X_last_updated_by,
                X_Last_Update_Date      => X_last_update_date,
                X_Last_Update_Login     => X_last_update_login);
    end loop;
    if( X_col_or_row = 'COLUMN')THEN
      close cr;
    else
      close cc;
    end if;
  end loop;
  close cf;

EXCEPTION
  WHEN OTHERS THEN
    if (cc%ISOPEN) then close cc; end if;
    if (cr%ISOPEN) then close cr; end if;
    if (cf%ISOPEN) then close cf; end if;
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.add_row');
    RAISE;
END;

PROCEDURE rearrange_column_number( X_forecast_header_id	NUMBER ) IS
  CURSOR cc IS 	select 	forecast_column_id
		from	ce_forecast_columns
		where	forecast_header_id = X_forecast_header_id
		and	column_number <> 0
		order by column_number;
  cid	NUMBER;
  n 	NUMBER;
begin
  n := 0;
  open cc;
  loop
    fetch cc into cid;
    n := n + 1;
    EXIT WHEN cc%NOTFOUND or cc%NOTFOUND IS NULL;
    UPDATE 	ce_forecast_columns
    	SET 	developer_column_num = n
    	WHERE 	forecast_column_id = cid;
  end loop;
  close cc;

  --
  -- Commit work
  --
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    if (cc%ISOPEN) then close cc; end if;
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.rearrage_column_number');
    RAISE;
END;

PROCEDURE duplicate_template_header(
			X_forecast_header_id	IN OUT NOCOPY NUMBER,
			X_created_by		NUMBER,
			X_creation_date		DATE,
			X_last_updated_by	NUMBER,
			X_last_update_date	DATE,
			X_last_update_login	NUMBER,
			X_forecast_id		NUMBER,
			X_name			VARCHAR2) IS
  p_rowid		VARCHAR2(100);
  cid			NUMBER;
  rid			NUMBER;
  p_forecast_header_id	NUMBER;
  CURSOR CH IS 	SELECT  *
		FROM	CE_FORECAST_HEADERS
		WHERE	forecast_header_id = X_forecast_header_id;
  HdrInfo CH%ROWTYPE;
  CURSOR CC IS 	SELECT  *
		FROM	CE_FORECAST_COLUMNS
		WHERE	forecast_header_id = X_forecast_header_id
		AND	developer_column_num <> 0;
  ColInfo CC%ROWTYPE;
  CURSOR CR IS 	SELECT  *
		FROM	CE_FORECAST_ROWS
		WHERE	forecast_header_id = X_forecast_header_id;
  RowInfo CR%ROWTYPE;

BEGIN
  cep_standard.debug('>> CE_FORECASTS_PKG.duplicate_forecast_header');
  --
  -- Create duplicate header
  --
  open CH;
  fetch CH into HdrInfo;
  IF (CH%NOTFOUND) THEN
    Raise NO_DATA_FOUND;
  END IF;

  cep_standard.debug('   - insert header');
  CE_FORECAST_HEADERS_PKG.insert_row(
		X_rowid			=> p_rowid,
                X_forecast_header_id	=> p_forecast_header_id,
                X_name			=> X_name,
                X_description		=> null,
                X_aging_type		=> HdrInfo.aging_type,
		X_overdue_transactions	=> HdrInfo.overdue_transactions,
		X_cutoff_period		=> HdrInfo.cutoff_period,
		X_transaction_calendar_id => HdrInfo.transaction_calendar_id,
                X_start_project_id	=> HdrInfo.start_project_id,
                X_end_project_id	=> HdrInfo.end_project_id,
                X_treasury_template  	=> HdrInfo.treasury_template,
                X_created_by		=> X_created_by,
                X_creation_date		=> X_creation_date,
                X_last_updated_by	=> X_last_updated_by,
                X_last_update_date	=> X_last_update_date,
                X_last_update_login	=> X_last_update_login,
                X_attribute_category	=> HdrInfo.attribute_category,
                X_attribute1		=> HdrInfo.attribute1,
                X_attribute2		=> HdrInfo.attribute2,
                X_attribute3		=> HdrInfo.attribute3,
                X_attribute4            => HdrInfo.attribute4,
                X_attribute5            => HdrInfo.attribute5,
                X_attribute6            => HdrInfo.attribute6,
                X_attribute7            => HdrInfo.attribute7,
                X_attribute8            => HdrInfo.attribute8,
                X_attribute9            => HdrInfo.attribute9,
                X_attribute10           => HdrInfo.attribute10,
                X_attribute11           => HdrInfo.attribute10,
                X_attribute12           => HdrInfo.attribute12,
                X_attribute13           => HdrInfo.attribute13,
                X_attribute14           => HdrInfo.attribute14,
                X_attribute15           => HdrInfo.attribute15);

  close CH;
  cep_standard.debug('   DONE inserted header with id = '||to_char(p_forecast_header_id));

  --
  -- Update forecast and forecast cells with new forecast_header_id
  --
  UPDATE 	CE_FORECAST_CELLS
  SET		forecast_header_id = p_forecast_header_id
  WHERE		forecast_id = X_forecast_id;

  UPDATE	CE_FORECASTS
  SET		forecast_header_id = p_forecast_header_id
  WHERE		forecast_id = X_forecast_id;

  --
  -- Create duplicate columns definition with new header id
  --
  open CC;
  fetch CC into ColInfo;
  WHILE (CC%FOUND) LOOP
    cep_standard.debug('   - insert column, hid = '||to_char(p_forecast_header_id)||', col num= '
				||to_char(ColInfo.column_number));
    cid := NULL;
    CE_FORECAST_COLUMNS_PKG.insert_row(
                X_rowid                 => p_rowid,
                X_forecast_column_id    => cid,
                X_forecast_header_id    => p_forecast_header_id,
                X_column_number         => ColInfo.column_number,
                X_days_from             => ColInfo.days_from,
                X_days_to               => ColInfo.days_to,
		X_developer_column_num	=> to_number(null),
                X_created_by            => X_created_by,
                X_creation_date         => X_creation_date,
                X_last_updated_by       => X_last_updated_by,
                X_last_update_date      => X_last_update_date,
                X_last_update_login     => X_last_update_login,
                X_attribute_category    => ColInfo.attribute_category,
                X_attribute1            => ColInfo.attribute1,
                X_attribute2            => ColInfo.attribute2,
                X_attribute3            => ColInfo.attribute3,
                X_attribute4            => ColInfo.attribute4,
                X_attribute5            => ColInfo.attribute5,
                X_attribute6            => ColInfo.attribute6,
                X_attribute7            => ColInfo.attribute7,
                X_attribute8            => ColInfo.attribute8,
                X_attribute9            => ColInfo.attribute9,
                X_attribute10           => ColInfo.attribute10,
                X_attribute11           => ColInfo.attribute11,
                X_attribute12           => ColInfo.attribute12,
                X_attribute13           => ColInfo.attribute13,
                X_attribute14           => ColInfo.attribute14,
                X_attribute15           => ColInfo.attribute15);

    UPDATE 	CE_FORECAST_CELLS
    SET		forecast_column_id = cid
    WHERE	forecast_id = X_forecast_id 			AND
		forecast_column_id = ColInfo.forecast_column_id;

    fetch CC into ColInfo;
  END LOOP;
  close CC;

  --
  -- Create duplicate rows definition with new header id
  --
  open CR;
  fetch CR into RowInfo;
  WHILE (CR%FOUND) LOOP
    cep_standard.debug('   - insert row');
    rid := NULL;
    CE_FORECAST_ROWS1_PKG.Insert_Row(
                X_rowid                 => p_rowid,
                X_forecast_row_id       => rid,
                X_forecast_header_id    => p_forecast_header_id,
                X_row_number            => RowInfo.row_number,
                X_trx_type              => RowInfo.trx_type,
                X_lead_time             => RowInfo.lead_time,
                X_forecast_method       => RowInfo.forecast_method,
                X_discount_option       => RowInfo.discount_option,
                X_order_status          => RowInfo.order_status,
                X_order_date_type       => RowInfo.order_date_type,
                X_code_combination_id   => RowInfo.code_combination_id,
                X_set_of_books_id       => RowInfo.set_of_books_id,
                X_org_id                => RowInfo.org_id,
                X_chart_of_accounts_id  => RowInfo.chart_of_accounts_id,
                X_budget_name           => RowInfo.budget_name,
		X_budget_version_id	=> RowInfo.budget_version_id,
                X_encumbrance_type_id   => RowInfo.encumbrance_type_id,
		X_roll_forward_type	=> RowInfo.roll_forward_type,
		X_roll_forward_period	=> RowInfo.roll_forward_period,
		X_customer_profile_class_id => RowInfo.customer_profile_class_id,
		X_include_dispute_flag  => RowInfo.include_dispute_flag,
		X_sales_stage_id	=> RowInfo.sales_stage_id,
		X_channel_code		=> RowInfo.channel_code,
		X_win_probability	=> RowInfo.win_probability,
 		X_sales_forecast_status => RowInfo.sales_forecast_status,
		X_receipt_method_id	=> RowInfo.receipt_method_id,
		X_bank_account_id	=> RowInfo.bank_account_id,
		X_payment_method	=> RowInfo.payment_method,
		X_pay_group		=> RowInfo.pay_group,
		X_payment_priority	=> RowInfo.payment_priority,
		X_vendor_type		=> RowInfo.vendor_type,
		X_authorization_status	=> RowInfo.authorization_status,
		X_type			=> RowInfo.type,
		X_budget_type		=> RowInfo.budget_type,
		X_budget_version	=> RowInfo.budget_version,
		X_include_hold_flag	=> RowInfo.include_hold_flag,
		X_include_net_cash_flag	=> RowInfo.include_net_cash_flag,
                X_created_by            => X_created_by,
                X_creation_date         => X_creation_date,
                X_last_updated_by       => X_last_updated_by,
                X_last_update_date      => X_last_update_date,
                X_last_update_login     => X_last_update_login,
		X_org_payment_method_id	=> RowInfo.org_payment_method_id,
		X_xtr_bank_account	=> RowInfo.xtr_bank_account,
		X_exclude_indic_exp	=> RowInfo.exclude_indic_exp,
		X_company_code		=> RowInfo.company_code,
                X_attribute_category    => RowInfo.attribute_category,
                X_attribute1            => RowInfo.attribute1,
                X_attribute2            => RowInfo.attribute2,
                X_attribute3            => RowInfo.attribute3,
                X_attribute4            => RowInfo.attribute4,
                X_attribute5            => RowInfo.attribute5,
                X_attribute6            => RowInfo.attribute6,
                X_attribute7            => RowInfo.attribute7,
                X_attribute8            => RowInfo.attribute8,
                X_attribute9            => RowInfo.attribute9,
                X_attribute10           => RowInfo.attribute10,
                X_attribute11           => RowInfo.attribute11,
                X_attribute12           => RowInfo.attribute12,
                X_attribute13           => RowInfo.attribute13,
                X_attribute14           => RowInfo.attribute14,
                X_attribute15           => RowInfo.attribute15,
		X_description		=> RowInfo.description,
		X_payroll_id		=> RowInfo.payroll_id,
		X_external_source_type	=> RowInfo.external_source_type,
		X_criteria_category	=> RowInfo.criteria_category,
		X_criteria1		=> RowInfo.criteria1,
		X_criteria2		=> RowInfo.criteria2,
		X_criteria3		=> RowInfo.criteria3,
		X_criteria4		=> RowInfo.criteria4,
		X_criteria5		=> RowInfo.criteria5,
		X_criteria6		=> RowInfo.criteria6,
		X_criteria7		=> RowInfo.criteria7,
		X_criteria8		=> RowInfo.criteria8,
		X_criteria9		=> RowInfo.criteria9,
		X_criteria10		=> RowInfo.criteria10,
		X_criteria11		=> RowInfo.criteria11,
		X_criteria12		=> RowInfo.criteria12,
		X_criteria13		=> RowInfo.criteria13,
		X_criteria14		=> RowInfo.criteria14,
		X_criteria15		=> RowInfo.criteria15,
		X_use_average_payment_days
					=> RowInfo.use_average_payment_days,
		X_period		=> RowInfo.period,
                X_order_type_id         => RowInfo.order_type_id,
                X_use_payment_terms     => RowInfo.use_payment_terms);

    UPDATE 	CE_FORECAST_CELLS
    SET		forecast_row_id = rid
    WHERE	forecast_id = X_forecast_id 			AND
		forecast_row_id = RowInfo.forecast_row_id;

    fetch CR into RowInfo;
  END LOOP;

  x_forecast_header_id := p_forecast_header_id;
  cep_standard.debug('<< CE_FORECASTS_PKG.duplicate_forecast_header');

EXCEPTION
  WHEN OTHERS THEN
    if (ch%ISOPEN) then close ch; end if;
    if (cc%ISOPEN) then close cc; end if;
    if (cr%ISOPEN) then close cr; end if;
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.duplicate_template_header');
    RAISE;
END;

PROCEDURE recalc_glc(X_hid	IN 	NUMBER) IS
    CURSOR C_fid (p_hid NUMBER) IS
      SELECT forecast_id
      FROM   ce_forecasts
      WHERE  forecast_header_id = p_hid;

    l_start_date	CE_FORECASTS.start_date%TYPE;
    l_calendar_name	CE_FORECASTS.period_set_name%TYPE;
    l_start_period 	CE_FORECASTS.start_period%TYPE;
    l_forecast_currency CE_FORECASTS.forecast_currency%TYPE;
    l_exchange_type	CE_FORECASTS.exchange_rate_type%TYPE;
    l_exchange_date	CE_FORECASTS.exchange_date%TYPE;
    l_exchange_rate	CE_FORECASTS.exchange_rate%TYPE;
    l_src_curr_type	CE_FORECASTS.currency_type%TYPE;
    l_source_currency	CE_FORECASTS.source_currency%TYPE;
    l_rownum_from	CE_FORECAST_ROWS.row_number%TYPE;
    l_rownum_to		CE_FORECAST_ROWS.row_number%TYPE;
    l_amount_threshold	CE_FORECASTS.amount_threshold%TYPE;
    l_project_id	CE_FORECASTS.project_id%TYPE;

    cnt_fc		NUMBER;
    fcount		NUMBER;
    fid_rec		C_fid%ROWTYPE;
BEGIN
      SELECT  count(*)
      INTO    cnt_fc
      FROM    ce_forecasts
      WHERE   forecast_header_id = X_hid;

      FOR fid_rec IN C_fid(X_hid) LOOP

        SELECT  aging_type
        INTO    CE_CASH_FCST.G_aging_type
        FROM    ce_forecast_headers
        WHERE   forecast_header_id = X_hid;

        SELECT 	start_date,
		period_set_name,
		start_period,
		forecast_currency,
                exchange_rate_type,
		exchange_date,
                exchange_rate,
		currency_type,
		source_currency,
                amount_threshold,
		project_id
        INTO    l_start_date,
		l_calendar_name,
		l_start_period,
		l_forecast_currency,
            	l_exchange_type,
		l_exchange_date,
                l_exchange_rate,
		l_src_curr_type,
		l_source_currency,
                l_amount_threshold,
		l_project_id
        FROM    ce_forecasts
        WHERE   forecast_id = fid_rec.forecast_id;

        SELECT  min(row_number),
		max(row_number)
        INTO    l_rownum_from,
		l_rownum_to
        FROM    ce_forecast_rows
        WHERE   forecast_header_id = X_hid;

        CE_CASH_FCST.set_parameters(X_hid,
       				    null,
       				    to_char(l_start_date, 'YYYY/MM/DD'),
       				    l_calendar_name,
       				    l_start_period,
       				    l_forecast_currency,
       				    l_exchange_type,
       				    to_char(l_exchange_date, 'YYYY/MM/DD'),
		                    l_exchange_rate,
       				    l_src_curr_type,
       				    l_source_currency,
                                    l_amount_threshold,
				    l_project_id,
       				    l_rownum_from,
       				    l_rownum_to,
				    null,
				    0,
				    'N',
				    'NONE',
				    null,
				    null,
				    fid_rec.forecast_id,
				    CE_CASH_FCST.G_display_debug,
				    CE_CASH_FCST.G_debug_path,
				    CE_CASH_FCST.G_debug_file);

      -- 	CE_CASH_FCST.G_forecast_id := fid_rec.forecast_id;

       	FND_CURRENCY.get_info(l_forecast_currency,
       			      CE_CASH_FCST.G_precision,
       			      CE_CASH_FCST.G_ext_precision,
       			      CE_CASH_FCST.G_min_acct_unit);

      END LOOP;

null;

EXCEPTION
  WHEN OTHERS THEN
    IF (C_fid%ISOPEN) THEN CLOSE C_fid; END IF;
    cep_standard.debug('EXCEPTION: CE_FORECASTS_PKG.recalc_glc');
    RAISE;
END recalc_glc;


END CE_FORECASTS_PKG;

/

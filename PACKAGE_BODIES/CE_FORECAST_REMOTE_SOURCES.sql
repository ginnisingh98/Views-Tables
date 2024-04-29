--------------------------------------------------------
--  DDL for Package Body CE_FORECAST_REMOTE_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FORECAST_REMOTE_SOURCES" AS
/* $Header: cefremtb.pls 120.5 2005/02/09 22:03:44 sspoonen ship $ */
/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Populate_Remote_Amounts                                         |
|                                                                       |
|  DESCRIPTION                                                          |
|       This procedure builds the query to calculate the forecast       |
|       amounts from remote source transactions.                        |
|  CALLED BY                                                            |
|       CE_CSH_FCST_POP.Build_Remote_Query                              |
|  REQUIRES                                                             |
|									|
|  RETURN VALUE								|
|	0 	No Error						|
|	-1	Other exceptions					|
|  HISTORY                                                              |
|       27-JUN-1997     Created         Wynne Chan                      |
 --------------------------------------------------------------------- */
FUNCTION Populate_Remote_Amounts (
		forecast_id		NUMBER,
		source_view		VARCHAR2,
		db_link			VARCHAR2,
		forecast_row_id		NUMBER,
		aging_table		AgingTab,
		conversion_table	ConversionTab,
		rp_forecast_currency	VARCHAR2,
		rp_exchange_date	DATE,
		rp_exchange_type	VARCHAR2,
		rp_exchange_rate	NUMBER,
		rp_src_curr_type	VARCHAR2,
		rp_src_currency		VARCHAR2,
		rp_amount_threshold	NUMBER,
		lead_time		NUMBER,
		criteria1		VARCHAR2,
		criteria2		VARCHAR2,
		criteria3		VARCHAR2,
		criteria4		VARCHAR2,
		criteria5		VARCHAR2,
		criteria6		VARCHAR2,
		criteria7		VARCHAR2,
		criteria8		VARCHAR2,
		criteria9		VARCHAR2,
		criteria10		VARCHAR2,
		criteria11		VARCHAR2,
		criteria12		VARCHAR2,
		criteria13		VARCHAR2,
		criteria14		VARCHAR2,
		criteria15		VARCHAR2,
		amount_table		IN OUT NOCOPY AmountTab) RETURN NUMBER IS
  from_where_clause   	VARCHAR2(2000) := null;
  main_query1		VARCHAR2(2500) := null;
  main_query2		VARCHAR2(2500) := null;
  cursor_id		INTEGER;
  exec_id		INTEGER;
  forecast_column_id	NUMBER;
  forecast_amount	NUMBER;
  trx_amount		NUMBER;
  currency_code		VARCHAR2(30);
  trx_date		DATE;
  bank_account_id	NUMBER;
  i			NUMBER;
  dummy			NUMBER;

BEGIN
  BEGIN
    main_query1 := 'SELECT count(*) from ' || source_view;
    cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.Parse(cursor_id, main_query1, DBMS_SQL.v7);
    DBMS_SQL.Define_Column(cursor_id, 1, dummy);
    exec_id := dbms_sql.execute(cursor_id);
    DBMS_SQL.CLOSE_CURSOR(CURSOR_ID);
  EXCEPTION
    WHEN OTHERS THEN
    	IF DBMS_SQL.is_open(cursor_id) THEN
	  DBMS_SQL.close_cursor(cursor_id);
	END IF;
        return (-1);
  END;

  --
  -- Insert aging bucket and conversion rate information to temporary table
  --
  IF(db_link IS NOT NULL)THEN
    FOR i IN 1 .. aging_table.count LOOP
      INSERT INTO CE_FORECAST_EXT_TEMP (context_value, forecast_request_id, start_date, end_date, forecast_column_id, conversion_rate)
	  VALUES ('A', forecast_id, aging_table(i).start_date, aging_table(i).end_date, aging_table(i).column_id, forecast_row_id);
    END LOOP;
  END IF;

  IF(rp_exchange_type <> 'User')THEN
    FOR i IN 1 .. conversion_table.count LOOP
      INSERT INTO CE_FORECAST_EXT_TEMP (context_value, forecast_request_id, from_currency_code, conversion_rate)
	VALUES ('C', forecast_id, conversion_table(i).from_currency_code, conversion_table(i).conversion_rate);
    END LOOP;
  END IF;

  --
  -- Build dynamic SQL statement using the user-defined view
  --
  IF(rp_exchange_type <> 'User')THEN
    main_query1 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount*curr.conversion_rate,
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||',
	src.bank_account_id ';
    main_query2 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount*curr.conversion_rate,
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||' ';
  ELSIF(rp_exchange_type IS NOT NULL) THEN
    main_query1 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount*'||to_char(rp_exchange_rate)||',
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||',
	src.bank_account_id ';
    main_query2 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount*'||to_char(rp_exchange_rate)||',
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||' ';
  ELSE
    -- cases where src_type = 'E' and forecast_currency = source currency
    main_query1 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount,
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||',
	src.bank_account_id ';
    main_query2 := 'SELECT 	cab.forecast_column_id,
        src.transaction_amount,
	src.transaction_amount,
	src.currency_code,
	src.cash_activity_date + '||to_char(lead_time)||' ';
  END IF;

  from_where_clause := '
	FROM 	'|| source_view ||' src,
               	CE_FORECAST_EXT_TEMP cab ';

  IF(rp_exchange_type <> 'User')THEN
    from_where_clause := from_where_clause || ',
		CE_FORECAST_EXT_TEMP curr ';
  END IF;

  from_where_clause := from_where_clause || '
	WHERE 	cab.context_value 	= ''A''
	AND 	cab.forecast_request_id = '||to_char(forecast_id)||'
	AND 	cab.conversion_rate	= '||to_char(forecast_row_id)||'
	AND 	src.cash_activity_date + '||to_char(lead_time)||' BETWEEN cab.start_date and cab.end_date ';

  IF( rp_src_curr_type = 'E' )THEN
    from_where_clause := from_where_clause || '
	AND 	src.currency_code	= '''||rp_src_currency||''' ';
  ELSIF( rp_src_curr_type = 'F' )THEN
    from_where_clause := from_where_clause || '
	AND 	src.functional_currency	= '''||rp_src_currency||''' ';
  END IF;

  IF(rp_exchange_type <> 'User')THEN
    from_where_clause := from_where_clause || '
	AND 	curr.forecast_request_id= '||to_char(forecast_id)||'
	AND 	curr.context_value 	= ''C''
	AND 	curr.from_currency_code = src.currency_code ';
  END IF;

  IF(rp_amount_threshold IS NOT NULL)THEN
    IF( rp_src_curr_type = 'E' )THEN
      from_where_clause := from_where_clause || '
        AND src.transaction_amount	>= '||to_char(rp_amount_threshold);
    ELSIF( rp_src_curr_type = 'F' )THEN
      from_where_clause := from_where_clause || '
        AND src.functional_amount	>= '||to_char(rp_amount_threshold);
    END IF;
  END IF;

  IF( criteria1  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria1  = '''||criteria1 ||''' '; END IF;
  IF( criteria2  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria2  = '''||criteria2 ||''' '; END IF;
  IF( criteria3  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria3  = '''||criteria3 ||''' '; END IF;
  IF( criteria4  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria4  = '''||criteria4 ||''' '; END IF;
  IF( criteria5  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria5  = '''||criteria5 ||''' '; END IF;
  IF( criteria6  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria6  = '''||criteria6 ||''' '; END IF;
  IF( criteria7  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria7  = '''||criteria7 ||''' '; END IF;
  IF( criteria8  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria8  = '''||criteria8 ||''' '; END IF;
  IF( criteria9  IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria9  = '''||criteria9 ||''' '; END IF;
  IF( criteria10 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria10 = '''||criteria10||''' '; END IF;
  IF( criteria11 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria11 = '''||criteria11||''' '; END IF;
  IF( criteria12 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria12 = '''||criteria12||''' '; END IF;
  IF( criteria13 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria13 = '''||criteria13||''' '; END IF;
  IF( criteria14 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria14 = '''||criteria14||''' '; END IF;
  IF( criteria15 IS NOT NULL )THEN from_where_clause := from_where_clause || ' AND src.criteria15 = '''||criteria15||''' '; END IF;

  main_query1 := main_query1 || from_where_clause;
  main_query2 := main_query2 || from_where_clause;

  BEGIN
    --
    -- Execute the dynamic SQL statement and prepare the forecast values into
    -- amount_table, which will be returned to the local database
    --
    cursor_id := DBMS_SQL.open_cursor;

    DBMS_SQL.Parse(cursor_id, main_query1, DBMS_SQL.v7);

    DBMS_SQL.Define_Column(cursor_id, 1, forecast_column_id);
    DBMS_SQL.Define_Column(cursor_id, 2, forecast_amount);
    DBMS_SQL.Define_Column(cursor_id, 3, trx_amount);
    DBMS_SQL.Define_Column(cursor_id, 4, currency_code,15);
    DBMS_SQL.Define_Column(cursor_id, 5, trx_date);
    DBMS_SQL.Define_Column(cursor_id, 6, bank_account_id);

    exec_id := dbms_sql.execute(cursor_id);
    i := 0;
    LOOP
      IF (DBMS_SQL.FETCH_ROWS(cursor_id) >0 ) THEN
        DBMS_SQL.COLUMN_VALUE(cursor_id, 1, forecast_column_id);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 2, forecast_amount);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 3, trx_amount);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 4, currency_code);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 5, trx_date);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 6, bank_account_id);

        i := i + 1;
        amount_table(i).forecast_column_id := forecast_column_id;
        amount_table(i).forecast_amount := forecast_amount;
        amount_table(i).trx_amount := trx_amount;
        amount_table(i).currency_code := currency_code;
        amount_table(i).trx_date := trx_date;
        amount_table(i).bank_account_id := bank_account_id;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    DBMS_SQL.close_cursor(cursor_id);
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.is_open(cursor_id) THEN
        DBMS_SQL.close_cursor(cursor_id);
      END IF;
      cursor_id := DBMS_SQL.open_cursor;

      DBMS_SQL.Parse(cursor_id, main_query2, DBMS_SQL.v7);

      DBMS_SQL.Define_Column(cursor_id, 1, forecast_column_id);
      DBMS_SQL.Define_Column(cursor_id, 2, forecast_amount);
      DBMS_SQL.Define_Column(cursor_id, 3, trx_amount);
      DBMS_SQL.Define_Column(cursor_id, 4, currency_code,15);
      DBMS_SQL.Define_Column(cursor_id, 5, trx_date);

      exec_id := dbms_sql.execute(cursor_id);
      i := 0;
      LOOP
        IF (DBMS_SQL.FETCH_ROWS(cursor_id) >0 ) THEN
          DBMS_SQL.COLUMN_VALUE(cursor_id, 1, forecast_column_id);
          DBMS_SQL.COLUMN_VALUE(cursor_id, 2, forecast_amount);
          DBMS_SQL.COLUMN_VALUE(cursor_id, 3, trx_amount);
          DBMS_SQL.COLUMN_VALUE(cursor_id, 4, currency_code);
          DBMS_SQL.COLUMN_VALUE(cursor_id, 5, trx_date);

          i := i + 1;
          amount_table(i).forecast_column_id := forecast_column_id;
          amount_table(i).forecast_amount := forecast_amount;
          amount_table(i).trx_amount := trx_amount;
          amount_table(i).currency_code := currency_code;
          amount_table(i).trx_date := trx_date;
	  amount_table(i).bank_account_id := null;
        ELSE
          EXIT;
        END IF;
      END LOOP;
      DBMS_SQL.close_cursor(cursor_id);

  END;

  --
  -- Delete records from temporary table
  --
  DELETE FROM CE_FORECAST_EXT_TEMP
	WHERE 	forecast_request_id = forecast_id
	AND	context_value = 'C';
  DELETE FROM CE_FORECAST_EXT_TEMP
	WHERE	forecast_request_id = forecast_id
	AND	conversion_rate = forecast_row_id
	AND	context_value = 'A';

  return (0);

EXCEPTION
  WHEN OTHERS THEN
    	IF DBMS_SQL.is_open(cursor_id) THEN
	  DBMS_SQL.close_cursor(cursor_id);
	END IF;
    	return (-3);
END Populate_Remote_Amounts;

END CE_FORECAST_REMOTE_SOURCES;

/

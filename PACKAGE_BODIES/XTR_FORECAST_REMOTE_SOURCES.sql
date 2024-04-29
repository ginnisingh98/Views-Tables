--------------------------------------------------------
--  DDL for Package Body XTR_FORECAST_REMOTE_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FORECAST_REMOTE_SOURCES" AS
/* $Header: xtrfrmtb.pls 115.0 99/07/17 00:31:38 porting ship $ */
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
		source_view		VARCHAR2,
		db_link			VARCHAR2,
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
		criteria15		VARCHAR2) RETURN NUMBER IS
  main_query   			varchar2(2000) := null;
  cursor_id			INTEGER;
  exec_id			INTEGER;
  forecast_period_temp_id	NUMBER;
  forecast_amount		NUMBER;
  i				NUMBER;
  dummy				NUMBER;
  currency			VARCHAR2(15);
  amount_date			DATE;
  level_of_summary		VARCHAR2(1);
  l_emu				VARCHAR2(15);

  CURSOR C_cur(p_cur VARCHAR2) IS
    SELECT nvl(derive_type, 'NONE')
    FROM   gl_currencies
    WHERE  currency_code = p_cur;

  CURSOR C_period(p_pid NUMBER) IS
    SELECT end_date,
           level_of_summary
    FROM   xtr_forecast_period_temp
    WHERE  forecast_period_temp_id = p_pid;

BEGIN
  BEGIN
    main_query := 'SELECT count(*) from ' || source_view;
    cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.Parse(cursor_id, main_query, DBMS_SQL.v7);
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
  -- Build dynamic SQL statement using the user-defined view
  --
  main_query :=   'SELECT 	cab.forecast_period_temp_id,
        src.currency_code,
        SUM(src.transaction_amount) ';

  main_query := main_query || '
	FROM 	'|| source_view ||' src,
               	XTR_FORECAST_PERIOD_TEMP cab ';

  main_query := main_query || '
	WHERE   src.cash_activity_date BETWEEN cab.start_date and cab.end_date ';

  IF( criteria1  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria1  = '''||criteria1 ||''' '; END IF;
  IF( criteria2  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria2  = '''||criteria2 ||''' '; END IF;
  IF( criteria3  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria3  = '''||criteria3 ||''' '; END IF;
  IF( criteria4  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria4  = '''||criteria4 ||''' '; END IF;
  IF( criteria5  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria5  = '''||criteria5 ||''' '; END IF;
  IF( criteria6  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria6  = '''||criteria6 ||''' '; END IF;
  IF( criteria7  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria7  = '''||criteria7 ||''' '; END IF;
  IF( criteria8  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria8  = '''||criteria8 ||''' '; END IF;
  IF( criteria9  IS NOT NULL )THEN main_query := main_query || ' AND src.criteria9  = '''||criteria9 ||''' '; END IF;
  IF( criteria10 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria10 = '''||criteria10||''' '; END IF;
  IF( criteria11 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria11 = '''||criteria11||''' '; END IF;
  IF( criteria12 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria12 = '''||criteria12||''' '; END IF;
  IF( criteria13 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria13 = '''||criteria13||''' '; END IF;
  IF( criteria14 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria14 = '''||criteria14||''' '; END IF;
  IF( criteria15 IS NOT NULL )THEN main_query := main_query || ' AND src.criteria15 = '''||criteria15||''' '; END IF;
  main_query := main_query || ' GROUP BY cab.forecast_period_temp_id, src.currency_code';
  BEGIN
    --
    -- Execute the dynamic SQL statement and prepare the forecast values into
    -- amount_table, which will be returned to the local database
    --
    cursor_id := DBMS_SQL.open_cursor;

    DBMS_SQL.Parse(cursor_id, main_query, DBMS_SQL.v7);

    DBMS_SQL.Define_Column(cursor_id, 1, forecast_period_temp_id);
    DBMS_SQL.Define_Column(cursor_id, 2, currency, 15);
    DBMS_SQL.Define_Column(cursor_id, 3, forecast_amount);

    exec_id := dbms_sql.execute(cursor_id);
    i := 0;
    LOOP
      IF (DBMS_SQL.FETCH_ROWS(cursor_id) >0 ) THEN
        DBMS_SQL.COLUMN_VALUE(cursor_id, 1, forecast_period_temp_id);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 2, currency);
        DBMS_SQL.COLUMN_VALUE(cursor_id, 3, forecast_amount);

        OPEN C_cur(currency);
        FETCH C_cur INTO l_emu;
        CLOSE C_cur;

        IF l_emu = 'EMU' THEN
          forecast_amount := GL_CURRENCY_API.convert_amount(currency,
							  'EUR',
							  XTR_CASH_FCST.G_rp_forecast_start_date,
						          'EMU-FIXED',
					                  forecast_amount);

          currency := 'EUR';
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
					   level_of_summary)
        VALUES (amount_date,
	        forecast_amount,
	        currency,
	        XTR_CASH_FCST.G_party_code,
	        XTR_CASH_FCST.G_trx_type,
                level_of_summary);
      ELSE
        EXIT;
      END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(CURSOR_ID);
  EXCEPTION
    WHEN OTHERS THEN
	IF DBMS_SQL.is_open(cursor_id) THEN
          DBMS_SQL.close_cursor(cursor_id);
        END IF;
        return (-2);
  END;

  return (0);

EXCEPTION
  WHEN OTHERS THEN
    	IF DBMS_SQL.is_open(cursor_id) THEN
	  DBMS_SQL.close_cursor(cursor_id);
	END IF;
    	return (-3);
END Populate_Remote_Amounts;

END XTR_FORECAST_REMOTE_SOURCES;

/

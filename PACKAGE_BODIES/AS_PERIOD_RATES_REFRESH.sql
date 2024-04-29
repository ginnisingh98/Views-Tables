--------------------------------------------------------
--  DDL for Package Body AS_PERIOD_RATES_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_PERIOD_RATES_REFRESH" as
/* $Header: asxrateb.pls 120.2 2005/06/14 01:32:14 appldev  $ */

--
-- HISTORY
--   03/20/2001       SOLIN       Created
--   05/20/2001       SOLIN       Change table name from AS_RATES to
--                                AS_PERIOD_RATES
--                                Decide to use N*N currencies
--
-- FLOW
--
-- NOTES
--  The main package for the concurrent program "Refresh Mult-Currency
--  Conversion Rate(AS_PERIOD_RATES)"
--


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME               CONSTANT VARCHAR2(30):= 'AS_PERIOD_RATES_REFRESH';
G_FILE_NAME              CONSTANT VARCHAR2(12):= 'asxrateb.pls';


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
g_debug_flag                      VARCHAR2(1);
g_request_id                      NUMBER;
g_user_id                         NUMBER;
g_prog_appl_id                    NUMBER;
g_prog_id                         NUMBER;
g_last_update_login               NUMBER;

g_period_set_name                 VARCHAR2(15);
g_mc_date_mapping_type            VARCHAR2(100);
g_max_roll_days                   NUMBER;

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES SPECIFICATION
 |
 *-------------------------------------------------------------------------*/
PROCEDURE fetch_profile_values;
PROCEDURE AS_DEBUG(p_module IN VARCHAR2, msg IN VARCHAR2);


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Refresh_AS_PERIOD_RATES
 |
 | PURPOSE
 |  The main program to refresh AS_PERIOD_RATES table.
 |  Concurrent program to populate multi-currency conversion rate.
 |
 | NOTES
 |
 | HISTORY
 |   03/20/2001  SOLIN    Created
 |   05/20/2001  SOLIN    Changed table name from AS_RATES to AS_PERIOD_RATES
 |   10/04/2001  SOLIN    Add exception handler in case reporting currency
 |                        is not defined in fnd_currencies.
 *-------------------------------------------------------------------------*/

PROCEDURE Refresh_AS_PERIOD_RATES(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_debug_mode       IN  VARCHAR2,
    p_trace_mode       IN  VARCHAR2)
IS
CURSOR c_get_dp_currency_s(c_period_set_name VARCHAR2) IS
    SELECT TYPEMAP.CONVERSION_TYPE,
           PERIOD.PERIOD_NAME, PERIOD.PERIOD_TYPE,
           PERIOD.START_DATE CONVERSION_DATE,
           LOOKUP1.LOOKUP_CODE FROM_CURRENCY,
           LOOKUP2.LOOKUP_CODE TO_CURRENCY
    FROM AS_MC_TYPE_MAPPINGS TYPEMAP,
         AS_PERIOD_DAYS PERIOD,
         FND_LOOKUP_VALUES LOOKUP1,
         FND_LOOKUP_VALUES LOOKUP2
    WHERE TYPEMAP.PERIOD_SET_NAME = c_period_set_name
    AND   TYPEMAP.PERIOD_TYPE = PERIOD.PERIOD_TYPE
    AND   PERIOD.PERIOD_SET_NAME = c_period_set_name
    AND   PERIOD.PERIOD_DAY = PERIOD.START_DATE
    AND   LOOKUP1.LOOKUP_TYPE = 'REPORTING_CURRENCY'
    AND   LOOKUP1.ENABLED_FLAG = 'Y'
    AND  (LOOKUP1.START_DATE_ACTIVE <= SYSDATE OR LOOKUP1.START_DATE_ACTIVE IS NULL)
    AND  (LOOKUP1.END_DATE_ACTIVE >= SYSDATE OR LOOKUP1.END_DATE_ACTIVE IS NULL)
    -- ffang 081303, bug 3096884, checking language
    AND   LOOKUP1.language = userenv('LANG')
    -- end ffang 081303, bug 3096884
    AND   LOOKUP2.LOOKUP_TYPE = 'REPORTING_CURRENCY'
    AND   LOOKUP2.ENABLED_FLAG = 'Y'
    AND  (LOOKUP2.START_DATE_ACTIVE <= SYSDATE OR LOOKUP2.START_DATE_ACTIVE IS NULL)
    AND  (LOOKUP2.END_DATE_ACTIVE >= SYSDATE OR LOOKUP2.END_DATE_ACTIVE IS NULL)
    -- ffang 081303, bug 3096884, checking language
    AND   LOOKUP2.language = userenv('LANG')
    -- end ffang 081303, bug 3096884
    ;

CURSOR c_get_dp_currency_e(c_period_set_name VARCHAR2) IS
    SELECT TYPEMAP.CONVERSION_TYPE,
           PERIOD.PERIOD_NAME, PERIOD.PERIOD_TYPE,
           PERIOD.END_DATE CONVERSION_DATE,
           LOOKUP1.LOOKUP_CODE FROM_CURRENCY,
           LOOKUP2.LOOKUP_CODE TO_CURRENCY
    FROM AS_MC_TYPE_MAPPINGS TYPEMAP,
         AS_PERIOD_DAYS PERIOD,
         FND_LOOKUP_VALUES LOOKUP1,
         FND_LOOKUP_VALUES LOOKUP2
    WHERE TYPEMAP.PERIOD_SET_NAME = c_period_set_name
    AND   TYPEMAP.PERIOD_TYPE = PERIOD.PERIOD_TYPE
    AND   PERIOD.PERIOD_SET_NAME = c_period_set_name
    AND   PERIOD.PERIOD_DAY = PERIOD.END_DATE
    AND   LOOKUP1.LOOKUP_TYPE = 'REPORTING_CURRENCY'
    AND   LOOKUP1.ENABLED_FLAG = 'Y'
    AND  (LOOKUP1.START_DATE_ACTIVE <= SYSDATE OR LOOKUP1.START_DATE_ACTIVE IS NULL)
    AND  (LOOKUP1.END_DATE_ACTIVE >= SYSDATE OR LOOKUP1.END_DATE_ACTIVE IS NULL)
    -- ffang 081303, bug 3096884, checking language
    AND   LOOKUP1.language = userenv('LANG')
    -- end ffang 081303, bug 3096884
    AND   LOOKUP2.LOOKUP_TYPE = 'REPORTING_CURRENCY'
    AND   LOOKUP2.ENABLED_FLAG = 'Y'
    AND  (LOOKUP2.START_DATE_ACTIVE <= SYSDATE OR LOOKUP2.START_DATE_ACTIVE IS NULL)
    AND  (LOOKUP2.END_DATE_ACTIVE >= SYSDATE OR LOOKUP2.END_DATE_ACTIVE IS NULL)
    -- ffang 081303, bug 3096884, checking language
    AND   LOOKUP2.language = userenv('LANG')
    -- end ffang 081303, bug 3096884
    ;

ddl_curs               INTEGER;
l_denominator          NUMBER;
l_numerator            NUMBER;
l_precision            NUMBER;
l_mau                  NUMBER;
l_rate                 NUMBER;
l_status_flag          NUMBER;
l_period_rate_id       NUMBER;
l_status               BOOLEAN;

l_conversion_type      VARCHAR2(10);
l_period_name          VARCHAR2(15);
l_period_type          VARCHAR2(15);
l_conversion_date      DATE;
l_from_currency        VARCHAR2(15);
l_to_currency          VARCHAR2(15);
l_fnd_status        VARCHAR2(2);
l_industry          VARCHAR2(2);
l_oracle_schema     VARCHAR2(32) := 'OSM';
l_schema_return     BOOLEAN;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.prate.Refresh_AS_PERIOD_RATES';
BEGIN
    l_schema_return := FND_INSTALLATION.get_app_info('AS', l_fnd_status, l_industry, l_oracle_schema);

    g_debug_flag := p_debug_mode;

    AS_DEBUG(l_module, '*** ASXRATES starts ***');

    fetch_profile_values;

    -- truncate AS_PERIOD_RATES
    ddl_curs := dbms_sql.open_cursor;
    dbms_sql.parse(ddl_curs,'TRUNCATE TABLE ' || l_oracle_schema || '.AS_PERIOD_RATES drop storage',
        dbms_sql.native);
    dbms_sql.close_cursor(ddl_curs);

    -- For period rate
    IF g_mc_date_mapping_type='S'
    THEN
        OPEN c_get_dp_currency_s(g_period_set_name);
    ELSE -- 'E'
        OPEN c_get_dp_currency_e(g_period_set_name);
    END IF;

    LOOP
        IF g_mc_date_mapping_type='S'
        THEN
            FETCH c_get_dp_currency_s INTO
                l_conversion_type, l_period_name, l_period_type,
                l_conversion_date, l_from_currency, l_to_currency;
            EXIT WHEN c_get_dp_currency_s%NOTFOUND;
        ELSE -- 'E'
            FETCH c_get_dp_currency_e INTO
                l_conversion_type, l_period_name, l_period_type,
                l_conversion_date, l_from_currency, l_to_currency;
            EXIT WHEN c_get_dp_currency_e%NOTFOUND;
        END IF;

        AS_DEBUG(l_module, l_conversion_type || ' ' || l_period_name
            || ' ' || l_period_type || ' ' || l_conversion_date
            || ' ' || l_from_currency || ' ' || l_to_currency);

        BEGIN
            l_status_flag := 0;
            gl_currency_api.get_closest_triangulation_rate(
                l_from_currency, l_to_currency,
                l_conversion_date, l_conversion_type,
                g_max_roll_days, l_denominator, l_numerator,
                l_rate);

        EXCEPTION
            WHEN others THEN
                IF SQLCODE=1
                THEN
                    AS_DEBUG(l_module, l_from_currency || ' to ' || l_to_currency
                        || ' rate not found.');
                    l_denominator := 1.0;
                    l_numerator := 0.0;
                    l_rate := 0.0;
                    l_status_flag := 1;
                END IF;
        END;
--        AS_DEBUG(l_from_currency || ' to ' || l_to_currency || ':' || l_rate);

        BEGIN
            SELECT precision,
                   NVL(minimum_accountable_unit, power(10,-1*precision))
            INTO l_precision, l_mau
            FROM fnd_currencies
            WHERE currency_code = l_to_currency;

--          AS_DEBUG('precision:' || l_precision || ' mau:' || l_mau);

            SELECT AS_PERIOD_RATES_S.NEXTVAL INTO l_period_rate_id FROM DUAL;

            -- Insertion for daily rate
            INSERT INTO AS_PERIOD_RATES(
                PERIOD_RATE_ID, FROM_CURRENCY, TO_CURRENCY,
                CONVERSION_TYPE, CONVERSION_DATE, CONVERSION_RATE,
                NUMERATOR_RATE, DENOMINATOR_RATE, PRECISION,
                MINIMUM_ACCOUNTABLE_UNIT,
                CONVERSION_STATUS_FLAG, PERIOD_TYPE, PERIOD_NAME,
                PERIOD_SET_NAME,
                LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
                CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID,
                PROGRAM_APPLICATION_ID, PROGRAM_ID,
                PROGRAM_UPDATE_DATE)
            VALUES( l_period_rate_id, l_from_currency, l_to_currency,
                l_conversion_type, l_conversion_date,
                l_rate, l_numerator, l_denominator, l_precision,
                l_mau, l_status_flag, l_period_type,
                l_period_name, g_period_set_name,
                SYSDATE, g_user_id, SYSDATE, g_user_id, g_last_update_login,
                g_request_id, g_prog_appl_id, g_prog_id, SYSDATE);

            COMMIT;

        EXCEPTION
            WHEN others THEN
                AS_DEBUG(l_module, 'Currency ' || l_to_currency || ' is not defined.');
        END;
    END LOOP;

    IF g_mc_date_mapping_type='S'
    THEN
        CLOSE c_get_dp_currency_s;
    ELSE -- 'E'
        CLOSE c_get_dp_currency_e;
    END IF;

    DBMS_STATS.GATHER_TABLE_STATS ('OSM','AS_PERIOD_RATES', degree=>4, estimate_percent => 99, granularity => 'GLOBAL', cascade=>TRUE);
    COMMIT;
EXCEPTION
WHEN others THEN
      AS_DEBUG(l_module, 'Exception: others in Refresh_AS_PERIOD_RATES');
      AS_DEBUG(l_module, 'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));

      errbuf := SQLERRM;
      retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Refresh_AS_PERIOD_RATES;

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE ROUTINES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  fetch_profile_values
 |
 | PURPOSE
 |  Fetch necessary profile values
 |
 | NOTES
 |
 |
 | HISTORY
 |   03/20/2001  SOLIN   Created
 *-------------------------------------------------------------------------*/
Procedure fetch_profile_values
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.prate.fetch_profile_values';
Begin
    IF FND_PROFILE.Value('AS_FORECAST_CALENDAR') IS NULL THEN
        as_debug(l_module, 'Value of AS_FORECAST_CALENDAR is not set');
    ELSE
        g_period_set_name := FND_PROFILE.Value('AS_FORECAST_CALENDAR') ;
    END IF;
    as_debug(l_module, 'Profile AS_FORECAST_CALENDAR: ' || g_period_set_name);

    IF FND_PROFILE.Value('AS_MC_DATE_MAPPING_TYPE') IS NULL THEN
        as_debug(l_module, 'Value of AS_MC_DATE_MAPPING_TYPE is not set');
    ELSE
        g_mc_date_mapping_type := FND_PROFILE.Value('AS_MC_DATE_MAPPING_TYPE') ;
    END IF;
    as_debug(l_module, 'Profile AS_MC_DATE_MAPPING_TYPE: ' || g_mc_date_mapping_type);

    IF FND_PROFILE.Value('AS_MC_MAX_ROLL_DAYS') IS NULL THEN
        as_debug(l_module, 'Value of AS_MC_MAX_ROLL_DAYS is not set');
    ELSE
        g_max_roll_days   := FND_PROFILE.Value('AS_MC_MAX_ROLL_DAYS') ;
    END IF;
    as_debug(l_module, 'Profile AS_MC_MAX_ROLL_DAYS: ' || g_max_roll_days);

--    IF FND_PROFILE.Value('AS_MC_DAILY_CONVERSION_TYPE') IS NULL THEN
--        as_debug('Value of AS_MC_DAILY_CONVERSION_TYPE is not set');
--    ELSE
--        g_daily_conversion_type := FND_PROFILE.Value('AS_MC_DAILY_CONVERSION_TYPE');
--    END IF;
--    as_debug('Profile AS_MC_DAILY_CONVERSION_TYPE: ' || g_daily_conversion_type);

--    IF FND_PROFILE.Value('AS_PREFERRED_CURRENCY') IS NULL THEN
--        as_debug('Value of AS_PREFERRED_CURRENCY is not set');
--    ELSE
--        g_preferred_currency := FND_PROFILE.Value('AS_PREFERRED_CURRENCY');
--    END IF;
--    as_debug('Profile AS_PREFERRED_CURRENCY: ' || g_preferred_currency);

    g_request_id := TO_NUMBER(fnd_profile.value('CONC_REQUEST_ID'));
    g_user_id := NVL(TO_NUMBER(fnd_profile.value('USER_ID')), -1);
    g_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
    g_prog_id := to_number(fnd_profile.value('CONC_PROGRAM_ID'));
    g_last_update_login := NVL(TO_NUMBER(fnd_profile.value('CONC_LOGIN_ID')), -1);

    as_debug(l_module, 'request_id: ' || g_request_id);
    as_debug(l_module, 'user_id: ' || g_user_id);
    as_debug(l_module, 'program_application_id: ' || g_prog_appl_id);
    as_debug(l_module, 'program_id: ' || g_prog_id);
    as_debug(l_module, 'last_update_login: ' || g_last_update_login);

End fetch_profile_values;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  As_Debug
 |
 | PURPOSE
 |  write debug message
 |
 | NOTES
 |
 |
 | HISTORY
 |   03/20/2001  SOLIN   Created
 *-------------------------------------------------------------------------*/

PROCEDURE AS_DEBUG(p_module in VARCHAR2, msg in VARCHAR2)
IS
l_length        NUMBER;
l_start         NUMBER := 1;
l_substring     VARCHAR2(255);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
BEGIN
    IF g_debug_flag = 'Y' THEN
         IF l_debug THEN
         	AS_UTILITY_PVT.Debug_Message(p_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, msg);
	 ELSE
			-- chop the message to 255 long
			l_length := length(msg);
			WHILE l_length > 255 LOOP
			    l_substring := substr(msg, l_start, 255);
			    FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
		--            dbms_output.put_line(l_substring);

			    l_start := l_start + 255;
			    l_length := l_length - 255;
			END LOOP;

			l_substring := substr(msg, l_start);
			FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
		--        dbms_output.put_line(l_substring);
	END IF;
    END IF;
EXCEPTION
WHEN others THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in AS_DEBUG');
      FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));
END As_Debug;

END AS_PERIOD_RATES_REFRESH;


/

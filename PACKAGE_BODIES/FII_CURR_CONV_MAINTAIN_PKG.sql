--------------------------------------------------------
--  DDL for Package Body FII_CURR_CONV_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CURR_CONV_MAINTAIN_PKG" AS
/* $Header: FIICRCVB.pls 120.0.12000000.1 2007/04/13 05:46:43 arcdixit noship $  */

    G_PHASE       VARCHAR2(120);
    g_schema_name VARCHAR2(120);
    g_retcode     VARCHAR2(20) := NULL;
    g_debug_mode  VARCHAR2(1)  := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

    g_global_start_date  DATE;
    g_prim_currency      VARCHAR2(15);
    g_sec_currency       VARCHAR2(15);
    g_prim_rate_type     VARCHAR2(30);
    g_sec_rate_type      VARCHAR2(30);
    g_current_start_date DATE;

-- *******************************************************************
--   Initialize
-- *******************************************************************

   PROCEDURE Initialize  IS

     l_dir VARCHAR2(160);

   BEGIN

     g_phase := 'Do set up for log file';

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in case if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL then
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
     -- the log files and output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_CURR_CONV_MAINTAIN_PKG.log',
                         'FII_CURR_CONV_MAINTAIN_PKG.out', l_dir,
                         'FII_CURR_CONV_MAINTAIN_PKG');

     g_phase := 'Check debug mode';

     -- Determine if process will be run in debug mode
     IF (NVL(G_Debug_Mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
       FII_UTIL.Write_Log ('Debug On');
     ELSE
       FIIDIM_Debug := FALSE;
       FII_UTIL.Write_Log ('Debug Off');
     END IF;

     g_phase := 'Obtain FII schema name and user info';

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     FII_USER_ID    := FND_GLOBAL.USER_ID;
     FII_LOGIN_ID   := FND_GLOBAL.LOGIN_ID;

     -- If some of the above values is not set, error out
     IF (FII_User_Id is NULL OR
         FII_Login_Id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization');
       RAISE EX_fatal_err;
     END IF;

     g_phase := 'Obtain global start date, currencies and rate types';

     g_global_start_date := bis_common_parameters.get_GLOBAL_START_DATE;
     g_prim_currency     := bis_common_parameters.get_currency_code;
     g_sec_currency      := bis_common_parameters.get_secondary_currency_code;
     g_prim_rate_type    := bis_common_parameters.get_rate_type;
     g_sec_rate_type     := bis_common_parameters.get_secondary_rate_type;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('g_global_start_date: '|| g_global_start_date);
       FII_UTIL.Write_Log ('g_prim_currency: '|| g_prim_currency);
       FII_UTIL.Write_Log ('g_sec_currency: '|| g_sec_currency);
       FII_UTIL.Write_Log ('g_prim_rate_type: '|| g_prim_rate_type);
       FII_UTIL.Write_Log ('g_sec_rate_type: '|| g_sec_rate_type);
     END IF;

     -- If some of the above values is not set, error out
     IF (g_global_start_date is NULL OR
         g_prim_currency is NULL OR
         g_prim_rate_type is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization');
       RAISE EX_fatal_err;
     END IF;

     g_phase := 'Get the start date of the current period';

     select start_date
     into g_current_start_date
     from FII_TIME_MONTH
     where end_date >= g_global_start_date
     and sysdate between start_date and end_date;

     g_phase := 'Turn on trace if in debug mode';

     -- Turn trace on if process is run in debug mode
     IF (FIIDIM_Debug) THEN
       -- Program running in debug mode, turning trace on
       EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
       FII_UTIL.Write_Log ('Initialize: Set Trace On');
     END IF;

   Exception

     When others then
       FII_UTIL.Write_Log ('Unexpected error when calling Initialize...');
       FII_UTIL.Write_Log ('G_PHASE: ' || G_PHASE);
       FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
       RAISE;

   END Initialize;

-- **************************************************************************
-- Detect missing rates
-- **************************************************************************

   PROCEDURE Detect_Missing_Rates( p_try_num number ) IS

     Cursor Dummy_Missing_Rates_Cur IS
         SELECT
            PERIOD_SET_NAME
          , PERIOD_ID
          , PERIOD_START_DATE
          , PERIOD_END_DATE
          , FROM_CURRENCY
          , TO_CURRENCY
          , CONVERSION_TYPE
          , CONVERSION_RATE
          , CURRENCY_TYPE
          , least(PERIOD_START_DATE, g_current_start_date) CONVERSION_DATE
         FROM FII_CURR_CONV_RATES
         WHERE 1=0;

     TYPE CursorRef IS ref cursor RETURN Dummy_Missing_Rates_Cur%ROWTYPE;
     Missing_Rates_Cur CursorRef;
     Missing_Rates_Rec Dummy_Missing_Rates_Cur%ROWTYPE;

     l_count NUMBER(15) := 0;
     l_bool_ret BOOLEAN;
     l_msg_name VARCHAR2(64);
     l_tab_name VARCHAR2(64);

   BEGIN

    IF (FIIDIM_Debug) THEN
        FII_MESSAGE.Func_Ent(
          'FII_ORCL_RCODE_MAINTAIN_PKG.Detect_Missing_Rates');
    END IF;

    l_msg_name := 'FII_MISSING_RATE_'     || p_try_num;
    l_tab_name := 'FII_MISSING_RATE_TAB_' || p_try_num;

    if (p_try_num = 1) then

       Open Missing_Rates_Cur For
         SELECT
            PERIOD_SET_NAME
          , PERIOD_ID
          , PERIOD_START_DATE
          , PERIOD_END_DATE
          , FROM_CURRENCY
          , TO_CURRENCY
          , CONVERSION_TYPE
          , CONVERSION_RATE
          , CURRENCY_TYPE
          , least(PERIOD_START_DATE, g_current_start_date) CONVERSION_DATE
         FROM FII_CURR_CONV_RATES_GT
         MINUS
         SELECT
            PERIOD_SET_NAME
          , PERIOD_ID
          , PERIOD_START_DATE
          , PERIOD_END_DATE
          , FROM_CURRENCY
          , TO_CURRENCY
          , CONVERSION_TYPE
          , CONVERSION_RATE
          , CURRENCY_TYPE
          , least(PERIOD_START_DATE, g_current_start_date) CONVERSION_DATE
         FROM FII_CURR_CONV_RATES
         WHERE CONVERSION_RATE < 0;

    elsif (p_try_num = 2) then

       Open Missing_Rates_Cur For
         SELECT
            PERIOD_SET_NAME
          , PERIOD_ID
          , PERIOD_START_DATE
          , PERIOD_END_DATE
          , FROM_CURRENCY
          , TO_CURRENCY
          , CONVERSION_TYPE
          , CONVERSION_RATE
          , CURRENCY_TYPE
          , least(PERIOD_START_DATE, g_current_start_date) CONVERSION_DATE
         FROM FII_CURR_CONV_RATES
         WHERE CONVERSION_RATE < 0;

    else

        RAISE EX_fatal_err;

    end if;

    LOOP

       Fetch Missing_Rates_Cur Into Missing_Rates_Rec;
       Exit When Missing_Rates_Cur%NOTFOUND;

       l_count := l_count + 1;

       if l_count = 1 then

         FII_MESSAGE.write_log(msg_name   => l_msg_name,
                   token_num  => 0);
         FII_MESSAGE.write_log(msg_name   => 'FII_REFER_TO_OUTPUT',
                   token_num  => 0);

         FII_MESSAGE.write_output(msg_name   => l_msg_name,
                   token_num  => 0);
         FII_MESSAGE.write_output(msg_name   => l_tab_name,
                   token_num  => 0);

       end if;

       FII_UTIL.Write_Output( rpad(' ', 4)
                   || rpad(Missing_Rates_Rec.PERIOD_ID, 14)
                   || rpad(Missing_Rates_Rec.CONVERSION_DATE, 20)
                   || rpad(Missing_Rates_Rec.FROM_CURRENCY, 18)
                   || rpad(Missing_Rates_Rec.TO_CURRENCY, 16)
                   || rpad(Missing_Rates_Rec.CONVERSION_TYPE, 19)
       );

    END LOOP;

    Close Missing_Rates_Cur;

    IF l_count > 0 THEN
        l_bool_ret := FND_CONCURRENT.Set_Completion_Status(
                status  => 'WARNING',
                message => 'Detected missing currency conversion rates.'
        );
    END IF;

    IF (FIIDIM_Debug) THEN
        FII_MESSAGE.Func_Succ (
          'FII_ORCL_RCODE_MAINTAIN_PKG.Detect_Missing_Rates');
    END IF;

   Exception

     When others then
       FII_UTIL.Write_Log(
         'Unexpected error when calling Detect_Missing_Rates.');
       FII_UTIL.Write_Log('G_PHASE: ' || G_PHASE);
       FII_UTIL.Write_Log('Error Message: '|| substr(sqlerrm,1,180));
       RAISE;

   END Detect_Missing_Rates;

-- **************************************************************************
-- This is the main procedure of the currency conversion program.
-- **************************************************************************

   PROCEDURE Init_Load (errbuf      OUT NOCOPY VARCHAR2,
                        retcode     OUT NOCOPY VARCHAR2) IS

    ret_val BOOLEAN := FALSE;

   BEGIN

    g_phase := 'Call Initialize';

    Initialize;

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name =>
                           'FII_CURR_CONV_MAINTAIN_PKG.Init_Load');
    END IF;

    g_phase := 'Truncate table FII_CURR_CONV_RATES';

    FII_UTIL.truncate_table ('FII_CURR_CONV_RATES', g_schema_name, g_retcode);

    g_phase := 'Insert into FII_CURR_CONV_RATES';

    insert into FII_CURR_CONV_RATES (
        PERIOD_SET_NAME
      , PERIOD_ID
      , PERIOD_START_DATE
      , PERIOD_END_DATE
      , FROM_CURRENCY
      , TO_CURRENCY
      , CONVERSION_TYPE
      , CONVERSION_RATE
      , CURRENCY_TYPE
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      )
    select
        'Gregorian'
      , prd.MONTH_ID
      , prd.START_DATE
      , prd.END_DATE
      , cfr.CURRENCY
      , cto.currency_code
      , cto.rate_type
      , decode( cfr.CURRENCY, 'NA_EDW', 1,
          GL_CURRENCY_API.get_rate_sql(
            nvl(cfr.CURRENCY, '')
          , cto.currency_code
          , least(prd.START_DATE, g_current_start_date)
          , cto.rate_type
          )
        )
      , decode(cto.currency_code, g_prim_currency, 'P', 'S')
      , SYSDATE
      , FII_USER_ID
      , SYSDATE
      , FII_USER_ID
      , FII_LOGIN_ID
    from FII_TIME_MONTH prd
       , HRI_CONVERT_FROM_CURRENCIES_V cfr
       , ( select g_prim_currency currency_code, g_prim_rate_type rate_type
           from dual
           union all
           select g_sec_currency  currency_code, g_sec_rate_type  rate_type
           from dual
           where g_sec_currency is not null
           and  g_sec_rate_type is not null
         ) cto
    where prd.end_date >= g_global_start_date;

    IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT ||
                           ' rows into FII_CURR_CONV_RATES');
    END IF;

    g_phase := 'Copy missing rates to FII_CURR_CONV_RATES_GT';

    insert into FII_CURR_CONV_RATES_GT (
        PERIOD_SET_NAME
      , PERIOD_ID
      , PERIOD_START_DATE
      , PERIOD_END_DATE
      , FROM_CURRENCY
      , TO_CURRENCY
      , CONVERSION_TYPE
      , CONVERSION_RATE
      , CURRENCY_TYPE
      )
    SELECT
        PERIOD_SET_NAME
      , PERIOD_ID
      , PERIOD_START_DATE
      , PERIOD_END_DATE
      , FROM_CURRENCY
      , TO_CURRENCY
      , CONVERSION_TYPE
      , CONVERSION_RATE
      , CURRENCY_TYPE
    FROM FII_CURR_CONV_RATES
    WHERE CONVERSION_RATE < 0;

    IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT ||
                           ' rows into FII_CURR_CONV_RATES_GT');
    END IF;

    g_phase := 'Update FII_CURR_CONV_RATES';

    update FII_CURR_CONV_RATES
    set CONVERSION_RATE =
        GL_CURRENCY_API.get_closest_rate_sql(
            nvl(FROM_CURRENCY, '')
          , TO_CURRENCY
          , least(PERIOD_START_DATE, g_current_start_date)
          , CONVERSION_TYPE
          , least(PERIOD_START_DATE, g_current_start_date) - g_global_start_date
        )
    where CONVERSION_RATE < 0
    and least(PERIOD_START_DATE, g_current_start_date) > g_global_start_date;

    IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT ||
                           ' rows in FII_CURR_CONV_RATES');
    END IF;

    g_phase := 'Detect missing rates in FII_CURR_CONV_RATES';

    Detect_Missing_Rates(1);
    Detect_Missing_Rates(2);

    g_phase := 'Gather_table_stats for FII_CURR_CONV_RATES';

    FND_STATS.gather_table_stats
       (ownname => g_schema_name,
        tabname => 'FII_CURR_CONV_RATES');

    g_phase := 'Commit the change';

    FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
        FII_MESSAGE.Func_Succ(func_name =>
                              'FII_CURR_CONV_MAINTAIN_PKG.Init_Load');
    END IF;

  EXCEPTION

    WHEN EX_fatal_err THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('FII_CURR_CONV_MAINTAIN_PKG.Init_Load: '||
                          'User defined error');
      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name =>
                            'FII_CURR_CONV_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
        (status  => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log (
        'Other error in FII_CURR_CONV_MAINTAIN_PKG.Init_Load: ' ||
        substr(sqlerrm,1,180));

      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name =>
                            'FII_CURR_CONV_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
        (status  => 'ERROR', message => substr(sqlerrm,1,180));

   END Init_Load;

END FII_CURR_CONV_MAINTAIN_PKG;

/

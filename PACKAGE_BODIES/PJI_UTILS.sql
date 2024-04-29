--------------------------------------------------------
--  DDL for Package Body PJI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_UTILS" AS
  /* $Header: PJIUT01B.pls 120.9.12010000.7 2010/03/10 05:19:32 dlella ship $ */

  -- Global variables -----------------------------------
  g_pji_settings           pji_system_settings%rowtype;
  g_settings_init_flag     boolean := FALSE;
  g_pji_enabled            varchar2(1);
  g_apps_schema            varchar2(30);
  g_pa_schema              varchar2(30);
  g_pji_schema             varchar2(30);
  g_pji_data_tspace        varchar2(30);
  g_pji_index_tspace       varchar2(30);
  g_session_sid            number;
  g_session_osuser         varchar2(30);
  g_session_user_id        number;
  g_module                 varchar2(60);
  g_output_dest            varchar2(60);
  g_debug_context          varchar2(60);
  g_pa_debug_mode          varchar2(1);

  -- Global variables for dangling rates report ---------
  g_space                  varchar2(30) := '                         ';
  g_line                   varchar2(30) := '-------------------------';
  g_indenting              varchar2(10) := '    ';
  g_length_rate_type       number       := 12;
  g_length_from_currency   number       := 17;
  g_length_to_currency     number       := 15;
  g_length_date            number       := 20;

    -- Private program units ------------------------------

  procedure init_settings_cache;
  procedure init_session_cache;

  -- ------------------------------------------------------
  -- function GET_PARAMETER
  -- ------------------------------------------------------
  function GET_PARAMETER (p_name varchar2) return varchar2 is

    l_result varchar2(240);

  begin

    select VALUE
    into   l_result
    from   PJI_SYSTEM_PARAMETERS
    where  NAME = p_name;

    return l_result;

  exception
    when no_data_found
    then return null;
    when others
    then raise;

  end GET_PARAMETER;


  -- ------------------------------------------------------
  -- procedure SET_PARAMETER
  -- ------------------------------------------------------
  procedure SET_PARAMETER(p_name varchar2, p_value varchar2) is

  begin

    update PJI_SYSTEM_PARAMETERS
    set    VALUE = p_value
    where  NAME  = p_name;

    if (sql%rowcount = 0) then
      insert
      into   PJI_SYSTEM_PARAMETERS (NAME, VALUE)
      values (p_name, p_value);
    end if;

  end SET_PARAMETER;


  -- ------------------------------------------------------
  -- function GET_APPS_SCHEMA_NAME
  -- ------------------------------------------------------
  function GET_APPS_SCHEMA_NAME return varchar2 is

  begin

    if (g_apps_schema is null) then

      select ORACLE_USERNAME
      into   g_apps_schema
      from   FND_ORACLE_USERID
      where  ORACLE_ID = 900;

    end if;

    return g_apps_schema;

  end GET_APPS_SCHEMA_NAME;


  -- ------------------------------------------------------
  -- function GET_PA_SCHEMA_NAME
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- ------------------------------------------------------
  function GET_PA_SCHEMA_NAME return varchar2 is

    l_status            varchar2(30);
    l_industry          varchar2(30);
    excp_get_app_info   exception;

  begin

    if (g_pa_schema is null) then

      if (not FND_INSTALLATION.GET_APP_INFO('PA', l_status, l_industry, g_pa_schema)) then
        raise excp_get_app_info;
      end if;

    end if;

    return g_pa_schema;

  end GET_Pa_SCHEMA_NAME;


  -- ------------------------------------------------------
  -- function GET_PJI_SCHEMA_NAME
  -- ------------------------------------------------------
  function GET_PJI_SCHEMA_NAME return varchar2 is

    l_status            varchar2(30);
    l_industry          varchar2(30);
    excp_get_app_info   exception;

  begin

    if (g_pji_schema is null) then

      if (not FND_INSTALLATION.GET_APP_INFO('PJI', l_status, l_industry, g_pji_schema)) then
        raise excp_get_app_info;
      end if;

    end if;

    return g_pji_schema;

  end GET_PJI_SCHEMA_NAME;


  -- ------------------------------------------------------
  -- procedure SET_CURR_FUNCTION
  -- ------------------------------------------------------
  procedure SET_CURR_FUNCTION( p_function varchar2 ) is
  begin
    g_module := p_function;
    pa_debug.set_curr_function( p_function );
  end;


  -- ------------------------------------------------------
  -- procedure RESET_CURR_FUNCTION
  -- ------------------------------------------------------
  procedure RESET_CURR_FUNCTION is
  begin
    pa_debug.reset_curr_function;
  end;


  -- ------------------------------------------------------
  -- function GET_EXTRACTION_START_DATE
  -- ------------------------------------------------------
  function GET_EXTRACTION_START_DATE return date is

    l_global_start_date date;
    l_override          varchar2(30);
    l_override_date     date;
    l_error_msg         varchar2(255):= 'Please ensure that the PJI_GLOBAL_START_DATE_OVERRIDE and BIS_GLOBAL_START_DATE profile options are entered in the following format: MM/DD/YYYY';

  begin

    l_global_start_date :=
      to_date(FND_PROFILE.VALUE('BIS_GLOBAL_START_DATE'),
              'MM/DD/YYYY');
    l_override := FND_PROFILE.VALUE('PJI_GLOBAL_START_DATE_OVERRIDE');

    if (l_override is not null) then

      begin

        l_override_date := to_date(l_override, 'MM/DD/YYYY');

        exception when others then
          dbms_standard.raise_application_error(-20050, l_error_msg);

      end;

      return greatest(l_global_start_date, l_override_date);

    end if;

    return l_global_start_date;

  end GET_EXTRACTION_START_DATE;


  -- ------------------------------------------------------
  -- procedure SET_OUTPUT_DEST
  -- ------------------------------------------------------
  procedure SET_OUTPUT_DEST
  (
    p_debug_dest    varchar2,
    p_debug_context varchar2 default NULL
  ) is
  begin
    g_output_dest   := p_debug_dest;
    g_debug_context := p_debug_context;
  end;


  -- ------------------------------------------------------
  -- procedure WRITE2LOG
  --
  --   A message can have MESSAGE_LEVEL in (1, 2, 3, 4, 5) where
  --   a level 1 message is a low level (detail) message and a
  --   level 5 message is a high level (overview) message.  High
  --   level messages will always be outputted to the output
  --   destination.  If the user wishes to see lower level messages
  --   the user must lower the value of the profile option
  --   PJI_DEBUG_LEVEL.
  --
  -- ------------------------------------------------------
  procedure WRITE2LOG
  (
    p_msg         in varchar2,
    p_timer_flag  in boolean  default null,
    p_debug_level in number   default 1
  ) is

    l_timestamp   varchar2(30);
    l_output_dest varchar2(15);
  begin

    if (g_session_sid is null) then
     init_session_cache;
    end if;

    if (g_pa_debug_mode = 'Y' or
        g_debug_level = 5) then

    l_output_dest := nvl(FND_PROFILE.VALUE('PJI_OUTPUT_DESTINATION'),
                         g_output_dest);

    if (p_timer_flag) then
      l_timestamp := ' ' || to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS');
    else
      l_timestamp := NULL;
    end if;

    if (l_output_dest is null or l_output_dest = 'TABLE') then

      if (p_debug_level >= g_debug_level) then

        insert into PJI_SYSTEM_DEBUG_MSG
        (
          MESSAGE_ID,
          MESSAGE_LEVEL,
          MESSAGE_CONTEXT,
          MESSAGE_TEXT,
          MESSAGE_TYPE,
          MODULE,
          CREATED_BY,
          CREATION_DATE
        )
        values
        (
          PJI_SYSTEM_DEBUG_MSG_S.NEXTVAL,
          p_debug_level,
          nvl(g_debug_context, g_session_osuser || '$' || g_session_sid),
          p_msg || l_timestamp,
          'LOG',
          g_module,
          g_session_user_id,
          sysdate
        );

      end if;

    elsif (l_output_dest = 'DBMS_OUTPUT') then
      null;
      -- for GSCC standards
      -- dbms_ output.put_ line(p_msg || l_timestamp);
    else
      -- in all other cases write the message into the log file
      pa_debug.log_message(p_message => p_msg || l_timestamp);
    end if;

    end if;

  end WRITE2LOG;


  -- ------------------------------------------------------
  -- procedure WRITE2OUT
  --
  --   In PJI_SYSTEM_DEBUG_MSG, output file lines have MESSAGE_LEVEL = 6 to
  --   distiguish from debugging messages.
  --
  -- ------------------------------------------------------
  procedure WRITE2OUT (p_msg in varchar2) is

    l_output_dest varchar2(15);

  begin

    l_output_dest := nvl(FND_PROFILE.VALUE('PJI_OUTPUT_DESTINATION'),
                         g_output_dest);

    if (l_output_dest = 'TABLE') then

      insert into PJI_SYSTEM_DEBUG_MSG
      (
        MESSAGE_ID,
        MESSAGE_LEVEL,
        MESSAGE_CONTEXT,
        MESSAGE_TEXT,
        MESSAGE_TYPE,
        MODULE,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (
        PJI_SYSTEM_DEBUG_MSG_S.NEXTVAL,
        6,
        nvl(g_debug_context, g_session_osuser || '$' || g_session_sid),
        p_msg,
        'OUT',
        g_module,
        g_session_user_id,
        sysdate
      );

    elsif (l_output_dest = 'DBMS_OUTPUT') then
      null;
      -- for GSCC standards
      -- dbms_ output.put_ line('OUT: ' || p_msg);
    else
      -- in all other cases write the message into the output file
      FND_FILE.PUT(FND_FILE.OUTPUT, p_msg);
    end if;

    exception

      when UTL_FILE.INVALID_PATH then
        raise_application_error(-20010,
                                'INVALID PATH exception from UTL_FILE');

      when UTL_FILE.INVALID_MODE then
        raise_application_error(-20010,
                                'INVALID MODE exception from UTL_FILE');

      when UTL_FILE.INVALID_FILEHANDLE then
        raise_application_error(-20010,
                                'INVALID FILEHANDLE exception from UTL_FILE');

      when UTL_FILE.INVALID_OPERATION then
        raise_application_error(-20010,
                                'INVALID OPERATION exception from UTL_FILE');

      when UTL_FILE.READ_ERROR then
        raise_application_error(-20010,
                                'READ ERROR exception from UTL_FILE');

      when UTL_FILE.WRITE_ERROR then
        raise_application_error(-20010,
                                'WRITE ERROR exception from UTL_FILE');

      when UTL_FILE.INTERNAL_ERROR then
        raise_application_error(-20010,
                                'INTERNAL ERROR exception from UTL_FILE');

      when others then raise;

  end WRITE2OUT;


  -- ------------------------------------------------------
  -- procedure WRITE2SSWALOG
  -- ------------------------------------------------------
  procedure WRITE2SSWALOG
  (
    p_msg          in varchar2,
    p_debug_level  in number  default 0,
    p_module       in varchar2 default NULL
  ) is
  begin

    if g_session_sid is null then
      init_session_cache;
    end if;

    if g_pa_debug_mode = 'Y' then

      insert into PJI_SYSTEM_DEBUG_MSG
      (
        MESSAGE_ID
      , MESSAGE_LEVEL
      , MESSAGE_CONTEXT
      , MESSAGE_TEXT
      , MESSAGE_TYPE
      , MODULE
      , CREATED_BY
      , CREATION_DATE
      )
      values
      (
        PJI_SYSTEM_DEBUG_MSG_S.NEXTVAL
      , p_debug_level
      , fnd_global.user_id || '$' || g_session_sid
      , p_msg
      , 'SSWA'
      , p_module
      , fnd_global.user_id
      , sysdate
      );

    end if;

  end;


  -- ------------------------------------------------------
  -- procedure RESET_SSWA_SESSION_CACHE
  -- ------------------------------------------------------
  procedure RESET_SSWA_SESSION_CACHE is
  begin
    init_session_cache;
  end;


  -- ------------------------------------------------------
  -- function GET_PJI_DATA_TSPACE
  -- ------------------------------------------------------
  function GET_PJI_DATA_TSPACE return varchar2 is

    l_pji_schema   varchar2(30);

  begin

    if (g_pji_data_tspace is null) then

      l_pji_schema := get_pji_schema_name;

      select TABLESPACE_NAME
      into   g_pji_data_tspace
      from   ALL_TABLES
      where  OWNER      = l_pji_schema and
             TABLE_NAME = 'PJI_SYSTEM_PARAMETERS';

    end if;

    return g_pji_data_tspace;

  end GET_PJI_DATA_TSPACE;


  -- ------------------------------------------------------
  -- function GET_PJI_IDX_TSPACE
  -- ------------------------------------------------------
  function GET_PJI_INDEX_TSPACE return varchar2 is

    l_pji_schema    varchar2(30);

  begin

    if (g_pji_index_tspace is null) then

      l_pji_schema := get_pji_schema_name;

      select TABLESPACE_NAME
      into   g_pji_index_tspace
      from   ALL_INDEXES
      where  OWNER      = l_pji_schema and
             INDEX_NAME = 'PJI_SYSTEM_PARAMETERS_U1';

    end if;

    return g_pji_index_tspace;

  end GET_PJI_INDEX_TSPACE;


  -- ------------------------------------------------------
  -- function GET_SETUP_PARAMETER
  -- ------------------------------------------------------
  function GET_SETUP_PARAMETER (p_name in varchar2) return varchar2 is
  begin

    if ( NOT g_settings_init_flag ) then
      init_settings_cache;
    end if;

    if    p_name = 'ORGANIZATION_STRUCTURE_ID' then
      return to_char(g_pji_settings.ORGANIZATION_STRUCTURE_ID);
    elsif p_name = 'ORG_STRUCTURE_VERSION_ID' then
      return to_char(g_pji_settings.ORG_STRUCTURE_VERSION_ID);
    elsif p_name = 'PA_PERIOD_FLAG' then
      return g_pji_settings.PA_PERIOD_FLAG;
    elsif p_name = 'GL_PERIOD_FLAG' then
      return g_pji_settings.GL_PERIOD_FLAG;
    elsif p_name = 'CONVERSION_RATIO_DAYS' then
      return to_char(g_pji_settings.CONVERSION_RATIO_DAYS);
    elsif p_name = 'BOOK_TO_BILL_DAYS' then
      return to_char(g_pji_settings.BOOK_TO_BILL_DAYS);
    elsif p_name = 'DSO_DAYS' then
      return to_char(g_pji_settings.DSO_DAYS);
    elsif p_name = 'DORMANT_BACKLOG_DAYS' then
      return to_char(g_pji_settings.DORMANT_BACKLOG_DAYS);
    elsif p_name = 'REPORT_COST_TYPE' then
      return g_pji_settings.REPORT_COST_TYPE;
    elsif p_name = 'COST_BUDGET_TYPE_CODE' then
      return g_pji_settings.COST_BUDGET_TYPE_CODE;
    elsif p_name = 'COST_BUDGET_CONV_RULE' then
      return g_pji_settings.COST_BUDGET_CONV_RULE;
    elsif p_name = 'REVENUE_BUDGET_TYPE_CODE' then
      return g_pji_settings.REVENUE_BUDGET_TYPE_CODE;
    elsif p_name = 'REVENUE_BUDGET_CONV_RULE' then
      return g_pji_settings.REVENUE_BUDGET_CONV_RULE;
    elsif p_name = 'COST_FORECAST_TYPE_CODE' then
      return g_pji_settings.COST_FORECAST_TYPE_CODE;
    elsif p_name = 'COST_FORECAST_CONV_RULE' then
      return g_pji_settings.COST_FORECAST_CONV_RULE;
    elsif p_name = 'REVENUE_FORECAST_TYPE_CODE' then
      return g_pji_settings.REVENUE_FORECAST_TYPE_CODE;
    elsif p_name = 'REVENUE_FORECAST_CONV_RULE' then
      return g_pji_settings.REVENUE_FORECAST_CONV_RULE;
    elsif p_name = 'COST_FP_TYPE_ID' then
      return g_pji_settings.COST_FP_TYPE_ID;
    elsif p_name = 'REVENUE_FP_TYPE_ID' then
      return g_pji_settings.REVENUE_FP_TYPE_ID;
    elsif p_name = 'COST_FORECAST_FP_TYPE_ID' then
      return g_pji_settings.COST_FORECAST_FP_TYPE_ID;
    elsif p_name = 'REVENUE_FORECAST_FP_TYPE_ID' then
      return g_pji_settings.REVENUE_FORECAST_FP_TYPE_ID;
    elsif p_name = 'REPORT_LABOR_UNITS' then
      return g_pji_settings.REPORT_LABOR_UNITS;
    elsif p_name = 'GLOBAL_START_DATE' then
      return to_char(GET_EXTRACTION_START_DATE, '1990/01/01');
    elsif p_name = 'GLOBAL_CURR2_FLAG' then
       return NVL(g_pji_settings.GLOBAL_CURR2_FLAG, 'N');
    elsif p_name = 'TXN_CURR_FLAG' then
       return NVL(g_pji_settings.TXN_CURR_FLAG,'N') ;
    /* Added for bug 8708651 */
    elsif p_name = 'GLOBAL_CURR1_FLAG' then
       return NVL(g_pji_settings.GLOBAL_CURR1_FLAG,'Y') ; /* Changed to Y for bug 9058579 */
    elsif p_name = 'TIME_PHASE_FLAG' then
       return NVL(g_pji_settings.TIME_PHASE_FLAG,'N') ;
    elsif p_name = 'PER_ANALYSIS_FLAG' then
       return NVL(g_pji_settings.PER_ANALYSIS_FLAG,'Y') ; /* Changed to Y for bug 8947586 */
    elsif p_name = 'UP_PROCESS_FLAG' then
       return NVL(g_pji_settings.UP_PROCESS_FLAG,'N') ;
    /* Added for bug 8708651 */
    else
      return NULL;
    end if;

  end GET_SETUP_PARAMETER;


  -- ******************************************************
  -- FUNCTION spread_amount
  -- ******************************************************

  FUNCTION spread_amount (
                        x_type_of_spread    IN VARCHAR2,
                        x_start_date        IN DATE,
                        x_end_date          IN DATE,
                        x_start_pa_date     IN DATE,
                        x_end_pa_date       IN DATE,
                        x_amount            IN NUMBER)
                    RETURN NUMBER
  IS
  BEGIN

    IF x_type_of_spread = 'L' THEN

        -- Linear Spread

        IF ( x_start_date <= x_start_pa_date ) AND
           ( x_end_date   >= x_End_pa_date ) THEN

           -- PA_PERIOD is within or identical to other period

           RETURN  (x_end_pa_date - x_start_pa_date + 1) * x_amount/
                     (x_end_date - x_start_date+ 1);

        ELSIF ( x_start_pa_date <= x_start_date) AND
              ( x_end_pa_date   <= x_End_date ) THEN

              RETURN   ( x_end_pa_date - x_start_date+ 1) * x_amount /
                     (x_end_date - x_start_date + 1) ;

        ELSIF ( x_start_pa_date >= x_start_date) AND
              ( x_end_pa_date   >= x_End_date ) THEN

              RETURN   ( x_end_date - x_start_pa_date + 1) * x_amount /
                     (x_end_date - x_start_date + 1) ;

        ELSIF ( x_start_pa_date <= x_start_date ) AND
              ( x_end_pa_date   >= x_End_date ) THEN

              -- PA_PERIOD bigger or identical to other period

              RETURN  x_amount;

        ELSIF ( x_end_pa_date   <= x_start_date ) OR
              ( x_start_pa_Date >= x_end_date )   OR
              ( x_start_pa_date  = x_end_pa_date )OR
              ( x_start_date = x_end_date ) THEN

              -- Non Overlapping PA period and amount periods
              -- OR Zero Days PA period

              RETURN 0;

        END IF;

      END IF;

      RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      RETURN NULL;
   END spread_amount;


  -- ------------------------------------------------------
  -- function GET_GLOBAL_RATE_PRIMARY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_GLOBAL_RATE_PRIMARY(p_from_currency_code varchar2,
                                   p_exchange_date date) return number is

    l_global_currency_code varchar2(30);
    l_global_rate_type     varchar2(15);
    l_max_roll_days        number;
    l_exchange_date        date;
    l_rate                 number;

  begin

    l_global_currency_code := FND_PROFILE.VALUE('BIS_PRIMARY_CURRENCY_CODE');
    l_global_rate_type := FND_PROFILE.VALUE('BIS_PRIMARY_RATE_TYPE');
    l_max_roll_days := NVL(PJI_UTILS.g_max_roll_days,32);
/* 5155692  Introduced the global variable g_max_roll_days, so that for plans we can
set it to 1500 and for actuals or default it will be 32 */

    l_exchange_date := p_exchange_date;

    if (p_from_currency_code = 'EUR' and
        l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    elsif (l_global_currency_code = 'EUR' and
           l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    end if;

    if (l_global_currency_code is null) then
      l_rate := 1;
    elsif (p_from_currency_code = l_global_currency_code) then
      l_rate := 1;
    else
      l_rate := GL_CURRENCY_API.GET_CLOSEST_RATE_SQL(p_from_currency_code,
                                                     l_global_currency_code,
                                                     l_exchange_date,
                                                     l_global_rate_type,
                                                     l_max_roll_days);
    end if;

    if (p_from_currency_code = 'EUR' and
        p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
        l_rate = -1 ) then
      l_rate := -3;
    elsif (l_global_currency_code = 'EUR' and
           p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
           l_rate = -1) then
      l_rate := -3;
    end if;

    return (l_rate);

    exception when others then return -4;

  end GET_GLOBAL_RATE_PRIMARY;


  -- ------------------------------------------------------
  -- function GET_MAU_PRIMARY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_MAU_PRIMARY return number is

    l_mau number;
    l_warehouse_currency_code varchar2(15);

  begin

    l_warehouse_currency_code := FND_PROFILE.VALUE('BIS_PRIMARY_CURRENCY_CODE');

    select nvl(curr.MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * curr.PRECISION)))
    into   l_mau
    from   FND_CURRENCIES curr
    where  curr.CURRENCY_CODE = l_warehouse_currency_code;

    if l_mau is null then
      l_mau := 0.01;  -- assign default value if null;
    elsif l_mau = 0 then
      l_mau := 1;
    end if;

    return l_mau;

    exception when others then return null;

  end GET_MAU_PRIMARY;


  -- ------------------------------------------------------
  -- function GET_GLOBAL_PRIMARY_CURRENCY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_GLOBAL_PRIMARY_CURRENCY
    return varchar2 is

    l_currency_code varchar2(30);

  begin

    l_currency_code := FND_PROFILE.VALUE('BIS_PRIMARY_CURRENCY_CODE');

    return l_currency_code;

  end GET_GLOBAL_PRIMARY_CURRENCY;


  -- ------------------------------------------------------
  -- function GET_GLOBAL_RATE_SECONDARY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_GLOBAL_RATE_SECONDARY(p_from_currency_code varchar2,
                                     p_exchange_date date) return number is

    l_global_currency_code varchar2(30);
    l_global_rate_type     varchar2(15);
    l_max_roll_days        number;
    l_exchange_date        date;
    l_rate                 number;

  begin

    l_global_currency_code := FND_PROFILE.VALUE('BIS_SECONDARY_CURRENCY_CODE');
    l_global_rate_type := FND_PROFILE.VALUE('BIS_SECONDARY_RATE_TYPE');
    l_max_roll_days := NVL(PJI_UTILS.g_max_roll_days,32);
/* 5155692  Introduced the global variable g_max_roll_days, so that for plans we can
set it to 1500 and for actuals or default it will be 32 */

    l_exchange_date := p_exchange_date;

    if (p_from_currency_code = 'EUR' and
        l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    elsif (l_global_currency_code = 'EUR' and
           l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    end if;

    if (l_global_currency_code IS NULL) then
      l_rate := 1;
    elsif (p_from_currency_code = l_global_currency_code) then
      l_rate := 1;
    else
      l_rate := GL_CURRENCY_API.GET_CLOSEST_RATE_SQL(p_from_currency_code,
                                                     l_global_currency_code,
                                                     l_exchange_date,
                                                     l_global_rate_type,
                                                     l_max_roll_days);

    end if;

    if (p_from_currency_code = 'EUR' and
        p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
        l_rate = -1) then
      l_rate := -3;
    elsif (l_global_currency_code = 'EUR' and
           p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
           l_rate = -1) then
      l_rate := -3;
    end if;

    return (l_rate);

    exception when others then return -4;

  end GET_GLOBAL_RATE_SECONDARY;


  -- ------------------------------------------------------
  -- function GET_MAU_SECONDARY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_MAU_SECONDARY return number is

    l_mau number;
    l_warehouse_currency_code varchar2(15);

  BEGIN

    l_warehouse_currency_code := FND_PROFILE.VALUE('BIS_SECONDARY_CURRENCY_CODE');

    select nvl(curr.MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * curr.PRECISION)))
    into   l_mau
    from   FND_CURRENCIES curr
    where  curr.CURRENCY_CODE = l_warehouse_currency_code;

    if l_mau is null then
      l_mau := 0.01;  -- assign default value if null;
    elsif l_mau = 0 then
      l_mau := 1;
    end if;

    return l_mau;

    exception when others then return null;

  end GET_MAU_SECONDARY;


  -- ------------------------------------------------------
  -- function GET_GLOBAL_SECONDARY_CURRENCY
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_GLOBAL_SECONDARY_CURRENCY
    return varchar2 is

    l_currency_code varchar2(30);

  begin

    l_currency_code := FND_PROFILE.VALUE('BIS_SECONDARY_CURRENCY_CODE');

    return l_currency_code;

  end GET_GLOBAL_SECONDARY_CURRENCY;


  -- ------------------------------------------------------
  -- function GET_RATE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_RATE(p_from_currency_code varchar2,
                    p_to_currency_code   varchar2,
                    p_exchange_date      date) return number is

    l_exchange_rate_type varchar2(255) := null;
    l_exchange_date      date;
    l_max_roll_days      number := 32;
    l_rate               number;

  begin

    l_exchange_date := p_exchange_date;

    if (p_from_currency_code = 'EUR' and
        l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    elsif (p_to_currency_code = 'EUR' and
           l_exchange_date < to_date('01/01/1999','DD/MM/RRRR')) then
      l_exchange_date := to_date('01/01/1999','DD/MM/RRRR');
    end if;

    if (p_from_currency_code = p_to_currency_code) then
      l_rate := 1;
    else
      l_rate :=  GL_CURRENCY_API.GET_CLOSEST_RATE_SQL(p_from_currency_code,
                                                      p_to_currency_code,
                                                      l_exchange_date,
                                                      l_exchange_rate_type,
                                                      l_max_roll_days);
    end if;

    if (p_from_currency_code = 'EUR' and
        p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
        l_rate = -1) then
      l_rate := -3;
    elsif (p_to_currency_code = 'EUR' and
           p_exchange_date < to_date('01/01/1999','DD/MM/RRRR') and
           l_rate = -1) then
      l_rate := -3;
    end if;

    return l_rate;

    exception when others then return -4;

  end GET_RATE;


  -- ------------------------------------------------------
  -- function GET_RATE_TYPE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_RATE_TYPE return varchar2 is

  begin

    return FND_PROFILE.VALUE('BIS_PRIMARY_RATE_TYPE');

  end GET_RATE_TYPE;


  -- ------------------------------------------------------
  -- function GET_MAU
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_MAU (p_currency_code varchar2) return number is

    l_mau number;

  begin

    select nvl(MINIMUM_ACCOUNTABLE_UNIT, power(10, (-1 * PRECISION)))
    into   l_mau
    from   FND_CURRENCIES
    where  CURRENCY_CODE = p_currency_code;

    if (l_mau is null) then
      l_mau := 0.01;
    elsif (l_mau = 0) then
      l_mau := 1;
    end if;

    return l_mau;

    exception when others then return null;

  end GET_MAU;


  -- ------------------------------------------------------
  -- function GET_DEGREE_OF_PARALLELISM
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal Summarization API.
  --
  -- ------------------------------------------------------
  function GET_DEGREE_OF_PARALLELISM return number is

    l_parallel number;

  begin

    l_parallel := null;
    l_parallel := floor(fnd_profile.value('EDW_PARALLEL_SRC')); -- gets value of profile option

    /* Set by the customer, return this value */

    IF (l_parallel IS NOT NULL and l_parallel > 0) THEN
      return l_parallel;
    END IF;

    /* Not set by customer, so query v$pq_sysstat */

    begin

      select value INTO l_parallel
      from v$pq_sysstat where trim(statistic) = 'Servers Idle';

    exception when no_data_found then
      l_parallel := 1;
    end;

    IF (l_parallel IS NULL) THEN
      l_parallel:=1;
    END IF;

    l_parallel := floor(l_parallel/2);
    IF (l_parallel = 0) THEN
      l_parallel := 1;
    END IF;

    return l_parallel;

  end GET_DEGREE_OF_PARALLELISM;


-----------------------------------------------------
-- function get_period_set_name
-- -----------------------------------------------------
FUNCTION get_period_set_name RETURN VARCHAR2 IS
  l_period_set_name VARCHAR2(15);
    --
    -- History
    -- 18-MAR-2004  VMANGULU  Created
    --
    -- return: NULL      = profile not defined
    -- return: rate type = value defined for the profile
    --                     option
    --
    -- *** This API returns value for BIS: Enterprise Calendar
    -- *** profile.
    --
BEGIN
   l_period_set_name:=Fnd_Profile.VALUE('BIS_ENTERPRISE_CALENDAR');
   RETURN l_period_set_name;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END;


-- -----------------------------------------------------
-- function get_START_DAY_OF_WEEK_ID
-- -----------------------------------------------------
FUNCTION get_START_DAY_OF_WEEK_ID  RETURN VARCHAR2 IS
    --
    -- History
    -- 18-MAR-2004  VMANGULU  Created
    --
    -- return: NULL      = profile not defined
    -- return: rate type = value defined for the profile
    --                     option
    --
    -- *** This API returns value for BIS: Start Day of Week
    -- *** profile.
    --
 l_start_dayofweek VARCHAR2(30);
BEGIN
     l_start_dayofweek:=Fnd_Profile.VALUE('BIS_START_DAY_OF_WEEK');
     RETURN l_start_dayofweek;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END;


-- -----------------------------------------------------
-- function get_period_type
-- -----------------------------------------------------
FUNCTION get_period_type  RETURN VARCHAR2 IS
    --
    -- History
    -- 18-MAR-2004  VMANGULU  Created
    --
    -- return: NULL      = profile not defined
    -- return: rate type = value defined for the profile
    --                     option
    --
    -- *** This API returns value for BIS: Period Type
    -- *** profile.
    --
 l_period_type  VARCHAR2(15);
BEGIN
    l_period_type:=Fnd_Profile.VALUE('BIS_PERIOD_TYPE');
    RETURN l_period_type;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END;


  -- -----------------------------------------------------
  -- function getMissingRateHeader
  --
  --   History
  --   19-MAR-2004  SVERMETT  From BIS_COLLECTION_UTILITIES
  --
  -- Internal Summarization API.
  --
  -- -----------------------------------------------------
FUNCTION  getMissingRateHeader return VARCHAR2 IS
l_msg varchar2(3000) := null;
l_newline varchar2(10) := '
';
l_temp varchar2(1000) := null;
BEGIN


fnd_message.set_name('PJI','PJI_SUM_DBI_CURR_OUTPUT_HDR');
l_msg := fnd_message.get || l_newline || l_newline;


fnd_message.set_name('PJI','PJI_SUM_DBI_COL_RATE_TYPE');
l_temp:=substr(fnd_message.get, 1,g_length_rate_type );
l_temp := l_temp|| substr(g_space, 1, g_length_rate_type - length(l_temp))||g_indenting;
l_msg := l_msg || l_temp;



fnd_message.set_name('PJI','PJI_SUM_DBI_COL_FROM_CURRENCY');
l_temp := substr(fnd_message.get, 1, g_length_from_currency);
l_temp := l_temp || substr(g_space, 1, g_length_from_currency - length(l_temp)) || g_indenting;
l_msg := l_msg || l_temp;

fnd_message.set_name('PJI','PJI_SUM_DBI_COL_TO_CURRENCY');
l_temp:=substr(fnd_message.get, 1,g_length_to_currency );
l_temp := l_temp || substr(g_space, 1, g_length_to_currency - length(l_temp)) || g_indenting;
l_msg := l_msg || l_temp;

fnd_message.set_name('PJI','PJI_SUM_DBI_COL_DATE');
l_temp:=substr(fnd_message.get, 1,g_length_date );
l_temp := l_temp || substr(g_space, 1, g_length_date - length(l_temp));
l_msg := l_msg || l_temp || l_newline;

l_temp :=  substr(g_line, 1, g_length_rate_type)||g_indenting||
	substr(g_line, 1, g_length_from_currency)||g_indenting||
	substr(g_line, 1, g_length_to_currency)||g_indenting||
	substr(g_line, 1, g_length_date);

/*'------------'||g_indenting ||'-----------------'||g_indenting||
'---------------'||g_indenting||'-------------';*/
l_msg := l_msg || l_temp||l_newline;

return l_msg;
END;


  -- -----------------------------------------------------
  -- function getMissingRateText
  --
  --   History
  --   19-MAR-2004  SVERMETT  From BIS_COLLECTION_UTILITIES
  --
  -- Internal Summarization API.
  --
  -- -----------------------------------------------------
FUNCTION getMissingRateText(
p_rate_type IN VARCHAR2,      /* Rate type */
p_from_currency IN VARCHAR2,  /* From Currency */
p_to_currency in VARCHAR2,    /* To Currency */
p_date IN DATE,               /* Date in default format */
p_date_override IN VARCHAR2) return VARCHAR2 /* Formatted date, will output this instead of p_date */
IS

l_msg varchar2(1000) := null;
l_temp varchar2(1000) := null;
l_user_rate_type varchar2(30):=null;

cursor c_user_rate_type is
SELECT user_conversion_type
FROM gl_daily_conversion_types
WHERE conversion_type = p_rate_type;

BEGIN

 open c_user_rate_type;
 fetch c_user_rate_type into l_user_rate_type;
 if c_user_rate_type%notfound then
   l_user_rate_type:=p_rate_type;
 end if;
 close c_user_rate_type;

---l_msg:=substr(p_rate_type, 1,g_length_rate_type );
l_msg:=substr(l_user_rate_type, 1,g_length_rate_type );

l_msg := l_msg || substr(g_space, 1, g_length_rate_type - length(l_msg))|| g_indenting;


l_temp:=substr(p_from_currency, 1, g_length_from_currency);
l_temp := l_temp || substr(g_space, 1, g_length_from_currency - length(l_temp)) || g_indenting;
l_msg := l_msg||l_temp;


l_temp:=substr(p_to_currency, 1,g_length_to_currency );
l_temp := l_temp || substr(g_space, 1, g_length_to_currency - length(l_temp)) || g_indenting;
l_msg := l_msg ||l_temp;


IF (p_date_override IS NULL) THEN
	l_temp:=substr(fnd_date.date_to_displayDT(p_date), 1,g_length_date );
ELSE
	l_temp := substr(p_date_override, 1,g_length_date );
END IF;

l_temp := l_temp || substr(g_space, 1, g_length_date - length(l_temp)) || g_indenting;
l_msg := l_msg||l_temp;

return l_msg;

END;


  -- -----------------------------------------------------
  -- function CHECK_PROGRAM_RBS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  --
  -- return:  0 = okay to remove project / RBS association
  -- return: -1 = RBS is pushed down from parent project
  --
  --
  -- -----------------------------------------------------
  function CHECK_PROGRAM_RBS (p_project_id     in number,
                              p_rbs_version_id in number)
           return number is

    l_count            number;

  begin

    select /*+ index(rel, PA_OBJECT_RELATIONSHIPS_N2) */
      count(*)
    into
      l_count
    from
      PA_OBJECT_RELATIONSHIPS rel,
      PA_RBS_PRJ_ASSIGNMENTS rbs
    where
      ROWNUM                  = 1                and
      rel.OBJECT_TYPE_TO      = 'PA_STRUCTURES'  and
      rel.OBJECT_ID_TO1       is not null        and
      rel.OBJECT_ID_TO2       = p_project_id     and
      rel.RELATIONSHIP_TYPE   in ('LW', 'LF')    and
      rbs.RBS_VERSION_ID      = p_rbs_version_id and
      rbs.PROG_REP_USAGE_FLAG = 'Y'              and
      rbs.PROJECT_ID          = rel.OBJECT_ID_FROM2;

    if (l_count > 0) then

      return -1;

    end if;

    return 0;

  end CHECK_PROGRAM_RBS;

 -- -----------------------------------------------------
  -- Funtion Derive_curr_rep_Info
  -- For project performance setups Audit report
  -- function used to get the current_rep_period
  --   History
  --   19-APR-2006  DEGUPTA Created
  -- -----------------------------------------------------
FUNCTION Derive_Curr_rep_Info(p_org_id NUMBER
                            , p_calendar_type VARCHAR2
  			    , p_active_rep VARCHAR2
                               )
return VARCHAR2
IS
l_specific_pa_period VARCHAR2(30);
l_specific_gl_period VARCHAR2(30);
l_specific_ent_period VARCHAR2(30);
l_report_date DATE;
l_period_name VARCHAR2(100);
l_application_id NUMBER;
l_gl_calendar_id NUMBER;
l_pa_calendar_id NUMBER;
l_specific_period VARCHAR2(30);
l_calendar_id NUMBER;
Begin
   IF p_active_rep = 'SPECIFIC' THEN
 	  BEGIN
		    SELECT
	    		info.pa_curr_rep_period,
				info.gl_curr_rep_period,
				params.value
			INTO l_specific_pa_period, l_specific_gl_period, l_specific_ent_period
			FROM pji_org_extr_info info,
			     pji_system_parameters params
			WHERE info.org_id = p_org_id
			AND params.name  = 'PJI_PJP_ENT_CURR_REP_PERIOD';
		EXCEPTION WHEN NO_DATA_FOUND THEN
		     NULL;
		END;
   END IF;

    IF p_calendar_type = 'E' THEN
	    IF p_active_rep IN ('CURRENT','PRIOR') THEN
		   SELECT start_date
		   INTO l_report_date
		   FROM pji_time_ent_period_v
		   WHERE TRUNC(SYSDATE) BETWEEN start_date AND end_date;
		END IF;

		IF p_active_rep = 'PRIOR' THEN
			  SELECT MAX(start_date)
			  INTO l_report_date
			  FROM pji_time_ent_period_v
			  WHERE end_date <l_report_date;
		END IF;
         IF p_active_rep = 'SPECIFIC' THEN
		    l_period_name := l_specific_ent_period;
		ELSE
	     	SELECT name
			INTO l_period_name
			FROM pji_time_ent_period_v
			WHERE l_report_date BETWEEN start_date AND end_date;
		END IF;

	ELSE
	   SELECT info.gl_calendar_id, info.pa_calendar_id
	   INTO l_gl_calendar_id, l_pa_calendar_id
	   FROM pji_org_extr_info info
	   WHERE info.org_id = p_org_id;

	   IF p_calendar_type = 'G' THEN
	      l_calendar_id := l_gl_calendar_id;
		  l_application_id := 101;
		  l_specific_period := l_specific_gl_period;
	   ELSE
	   	  l_calendar_id := l_pa_calendar_id;
		  l_application_id := 275;
  		  l_specific_period := l_specific_pa_period;
	   END IF;

	   IF p_active_rep ='FIRST_OPEN' THEN
			SELECT MIN(TIM.start_date) first_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations_all paimp
			WHERE 1=1
			AND TIM.calendar_id = l_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
                        AND paimp.org_id = p_org_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF p_active_rep = 'LAST_OPEN' THEN
			SELECT MAX(TIM.start_date) last_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations_all paimp
			WHERE 1=1
			AND TIM.calendar_id = l_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
                        AND paimp.org_id = p_org_id
			AND glps.application_id = 275
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF p_active_rep = 'LAST_CLOSED' THEN
			SELECT MAX(TIM.start_date) last_closed
			INTO  l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations_all paimp
			WHERE 1=1
			AND TIM.calendar_id = l_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
                        AND paimp.org_id = p_org_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'C';
		ELSIF p_active_rep IN ('CURRENT','PRIOR') THEN
			SELECT start_date
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE TRUNC(SYSDATE) BETWEEN start_date
			AND end_date
			AND calendar_id = l_calendar_id;
		END IF;

		IF p_active_rep = 'PRIOR' THEN
			SELECT MAX(start_date)
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE end_date < l_report_date
			AND calendar_id = l_calendar_id;
		END IF;

		IF p_active_rep = 'SPECIFIC' THEN
		    l_period_name := l_specific_period;
		ELSE
			SELECT name
			INTO l_period_name
			FROM pji_time_cal_period_v
			WHERE l_report_date BETWEEN start_date AND end_date
			AND calendar_id = l_calendar_id;
		END IF;


	END IF;
   return l_period_name;
Exception when others then
   return NULL;
END;

  -- -----------------------------------------------------
  -- Procedure REPORT_PJP_PARAM_SETUP
  -- For project performance setups Audit report
  --   History
  --   14-MAR-2006  DEGUPTA Created
  -- -----------------------------------------------------
PROCEDURE REPORT_PJP_PARAM_SETUP
	(errbuff        OUT NOCOPY VARCHAR2,
         retcode        OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(240);
l_prm_miss	number(10) := 0;
/* l_prm_miss = 1 For Error
                2 Only Mandatory Setup Options are missing
                3 Only Optional Setup options are missing
                4 Both Mandatory and Optional setup options are missing  */
l_newline       varchar2(10) := '
';
l_pji_report_msg	VARCHAR2(240);
l_pji_head1 VARCHAR2(240);
l_pji_head2 VARCHAR2(240);
l_pji_head3 VARCHAR2(240);
l_pji_head4 VARCHAR2(240);
l_pji_head5 VARCHAR2(240);
l_pji_line2 VARCHAR2(240) := '-';
l_pji_line3 VARCHAR2(240) := '-';
l_pji_line4 VARCHAR2(240) := '-';
l_pji_line5 VARCHAR2(240) := '-';
l_pji_tline VARCHAR2(240) := '-';
l_pji_foot1 VARCHAR2(240);
l_pji_foot2 VARCHAR2(240);
l_pji_foot3 VARCHAR2(240);
l_pji_foot4 VARCHAR2(240);
l_bis_note number(10) := 0;
l_pjp_note number(10) := 0;
l_sp_note number(10) := 0;
l_separator VARCHAR2(240) := '                              ';
prof_opt_tbl SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
prof_val_tbl SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
-- For BIS Report
l_bis_pri_curr_code VARCHAR2(240);
l_bis_pri_rate_type VARCHAR2(240);
l_bis_sec_curr_code VARCHAR2(240);
l_bis_sec_rate_type VARCHAR2(240);
l_bis_ent_calendar VARCHAR2(240);
l_bis_period_type VARCHAR2(240);
l_bis_global_start_date VARCHAR2(240);
l_pji_global_start_date VARCHAR2(240);
l_p_bis_pri_curr_code VARCHAR2(100);
l_p_bis_pri_rate_type VARCHAR2(100);
l_p_bis_sec_curr_code VARCHAR2(100);
l_p_bis_sec_rate_type VARCHAR2(100);
l_p_bis_ent_calendar VARCHAR2(100);
l_p_bis_period_type VARCHAR2(100);
l_p_bis_global_start_date VARCHAR2(100);
l_p_pji_global_start_date VARCHAR2(240);
--- For PJP Report
l_glb_curr_flag VARCHAR2(1);
l_txn_curr_flag VARCHAR2(1);
l_planamt_conv_date VARCHAR2 (30);
l_planamt_alloc_method VARCHAR2 (30);
l_curr_rep_pa_period VARCHAR2(30);
l_curr_rep_gl_period VARCHAR2(30);
l_curr_rep_ent_period VARCHAR2(30);
l_sp_curr_rep_org_tbl SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
l_sp_curr_rep_pa_period_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_sp_curr_rep_gl_period_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_sp_curr_rep_ent_period_tbl SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
l_p_glb_curr_flag VARCHAR2(100);
l_p_txn_curr_flag VARCHAR2(100);
l_p_planamt_conv_date VARCHAR2 (100);
l_p_planamt_alloc_method VARCHAR2 (100);
l_p_curr_rep_pa_period VARCHAR2(100);
l_p_curr_rep_gl_period VARCHAR2(100);
l_p_curr_rep_ent_period VARCHAR2(100);
l_p_curr_rep_not VARCHAR2(100);

/*Following code is added for bug 6802867 */
l_extraction_batch_size number(10);
l_def_rept_cal_type VARCHAR2(240);
l_def_rept_cur_type VARCHAR2(240);

l_p_extraction_batch_size VARCHAR2(100);
l_p_def_rept_cal_type VARCHAR2(100);
l_p_def_rept_cur_type VARCHAR2(100);

BEGIN
-- For Bis Setup Options
BEGIN
/* Modified the following select statement for bug 6802867 */

SELECT OP.PROFILE_OPTION_NAME,VAL.PROFILE_OPTION_VALUE BULK COLLECT
INTO prof_opt_tbl,prof_val_tbl
FROM   FND_PROFILE_OPTIONS OP ,  FND_PROFILE_OPTION_VALUES VAL
WHERE OP.PROFILE_OPTION_NAME
IN ('BIS_PRIMARY_CURRENCY_CODE','BIS_PRIMARY_RATE_TYPE','BIS_SECONDARY_CURRENCY_CODE',
'BIS_SECONDARY_RATE_TYPE','BIS_ENTERPRISE_CALENDAR','BIS_PERIOD_TYPE','BIS_GLOBAL_START_DATE',
'PJI_GLOBAL_START_DATE_OVERRIDE', 'PJI_EXTRACTION_BATCH_SIZE','PJI_DEF_RPT_CUR_TYPE','PJI_DEF_RPT_CAL_TYPE')
AND VAL.PROFILE_OPTION_ID = OP.PROFILE_OPTION_ID
AND    VAL.APPLICATION_ID    = OP.APPLICATION_ID
AND    LEVEL_ID          = 10001
AND    LEVEL_VALUE       = 0;

FOR I IN 1..prof_opt_tbl.COUNT LOOP
  if prof_opt_tbl(i) = 'BIS_PRIMARY_CURRENCY_CODE' then
  l_bis_pri_curr_code := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_PRIMARY_RATE_TYPE' then
  l_bis_pri_rate_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_SECONDARY_CURRENCY_CODE' then
  l_bis_sec_curr_code := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_SECONDARY_RATE_TYPE' then
  l_bis_sec_rate_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_ENTERPRISE_CALENDAR' then
  l_bis_ent_calendar := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_PERIOD_TYPE' then
   l_bis_period_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_GLOBAL_START_DATE' then
   l_bis_global_start_date := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_GLOBAL_START_DATE_OVERRIDE' then
   l_pji_global_start_date := prof_val_tbl(i);
  end if ;
/*Following code is added for bug 6802867 */
  if prof_opt_tbl(i) = 'PJI_EXTRACTION_BATCH_SIZE' then
   l_extraction_batch_size := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_DEF_RPT_CUR_TYPE' then
   l_def_rept_cur_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_DEF_RPT_CAL_TYPE' then
   l_def_rept_cal_type := prof_val_tbl(i);
  end if ;

end loop;
EXCEPTION WHEN NO_DATA_FOUND then
     l_err_msg := 'BIS Setup Options are not available';
     l_prm_miss := 1;
     raise;
END;
-- For Bis Setup Options Prompts or captions
BEGIN
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();

SELECT  lookup_code , RPAD(MEANING,45,' ')||': ' BULK COLLECT
INTO prof_opt_tbl,prof_val_tbl
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code in ( 'BIS_PR_CURR',
'BIS_PR_RATE',
'BIS_SE_CURR',
'BIS_SE_RATE',
'BIS_ENT_CAL',
'BIS_GLO_ST_DT',
'BIS_PD_TYPE',
'PJI_GLO_ST_DT');

FOR I IN 1..prof_opt_tbl.COUNT LOOP
  if prof_opt_tbl(i) = 'BIS_PR_CURR' then
  l_p_bis_pri_curr_code := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_PR_RATE' then
  l_p_bis_pri_rate_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_SE_CURR' then
  l_p_bis_sec_curr_code := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_SE_RATE' then
  l_p_bis_sec_rate_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_ENT_CAL' then
  l_p_bis_ent_calendar := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_PD_TYPE' then
   l_p_bis_period_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'BIS_GLO_ST_DT' then
   l_p_bis_global_start_date := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_GLO_ST_DT' then
   l_p_pji_global_start_date := prof_val_tbl(i);
  end if ;
end loop;
EXCEPTION WHEN NO_DATA_FOUND THEN
     l_err_msg := 'BIS Profile Options prompts are not available in lookup table';
     l_prm_miss := 1;
     raise;
END;
/*For new profile options added  (PJI: Default Reporting Calendar Type, PJI: Default Reporting Currency Type and PJI: Extraction Batch Size )*/
/*Following code is added for bug 6802867 */
BEGIN
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();

SELECT  lookup_code , RPAD(MEANING,45,' ')||': ' BULK COLLECT
INTO prof_opt_tbl,prof_val_tbl
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_PJP_SET_PARAMS'
	and lookup_code in ( 'PJI_EXTRACTION_BATCH_SIZE','PJI_DEF_RPT_CUR_TYPE','PJI_DEF_RPT_CAL_TYPE');

FOR I IN 1..prof_opt_tbl.COUNT LOOP
  if prof_opt_tbl(i) = 'PJI_EXTRACTION_BATCH_SIZE' then
  l_p_extraction_batch_size := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_DEF_RPT_CUR_TYPE' then
  l_p_def_rept_cur_type := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJI_DEF_RPT_CAL_TYPE' then
  l_p_def_rept_cal_type := prof_val_tbl(i);
  end if ;
end loop;
END;

--- For checking the missing mandatory or optional setup options
if l_bis_pri_curr_code is NULL or l_bis_pri_rate_type is NULL
or l_bis_ent_calendar is NULL or l_bis_period_type is NULL
or l_bis_global_start_date is NULL then
l_prm_miss := 2;
l_bis_note := 1;
end if;
if l_bis_sec_curr_code is NULL or l_bis_sec_rate_type is NULL
or l_pji_global_start_date is NULL then
if nvl(l_prm_miss,0) = 2 then
l_prm_miss := 4;
l_bis_note := 1;
else
l_prm_miss := 3;
l_bis_note := 1;
end if;
end if;

-- For Getting the headings of the Audit report
SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_TEXT'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_HEAD1'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_HEAD2'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_HEAD3'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_HEAD4'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_REPORT_HEAD5'),
FND_MESSAGE.GET_STRING('PJI','PJI_PJP_PERF_SETUP'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_BIS_SETUP'),
FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJP_SETUP'),
FND_MESSAGE.GET_STRING('PJI','PJI_PJP_CUR_PERIOD'),
FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_DEF')
INTO l_pji_report_msg,l_pji_head1,l_pji_head2,l_pji_head3,l_pji_head4,l_pji_head5,
l_pji_foot1,l_pji_foot2,l_pji_foot3,l_pji_foot4,l_p_curr_rep_not
FROM dual;

select
RPAD(l_separator,Length(l_separator)+Length(l_pji_report_msg),'*'),
RPAD(l_pji_line2,length(l_pji_head2),'-'),
RPAD(l_pji_line3,length(l_pji_head3),'-'),
RPAD(l_pji_line4,length(l_pji_head4),'-'),
RPAD(l_pji_line5,length(l_pji_head5),'-')
into
l_separator,l_pji_line2,l_pji_line3,l_pji_line4,l_pji_line5
from dual;

-- Audit Report printing starts
l_pji_report_msg := '                              '||l_pji_report_msg;


pji_utils.write2out(l_newline || l_pji_report_msg || l_newline || l_separator || l_newline
||l_pji_head1||l_newline||l_newline||l_pji_head2||l_newline||l_pji_line2||l_newline);

pji_utils.write2out(l_p_bis_pri_curr_code||l_bis_pri_curr_code||l_newline);
pji_utils.write2out(l_p_bis_pri_rate_type||l_bis_pri_rate_type||l_newline);
pji_utils.write2out(l_p_bis_sec_curr_code||l_bis_sec_curr_code||l_newline);
pji_utils.write2out(l_p_bis_sec_rate_type||l_bis_sec_rate_type||l_newline);
pji_utils.write2out(l_p_bis_ent_calendar||l_bis_ent_calendar||l_newline);
pji_utils.write2out(l_p_bis_period_type||l_bis_period_type||l_newline);
pji_utils.write2out(l_p_bis_global_start_date||l_bis_global_start_date||l_newline);
pji_utils.write2out(l_p_pji_global_start_date||l_pji_global_start_date||l_newline);
/*Following code is added for bug 6802867 */
pji_utils.write2out(l_p_extraction_batch_size||l_extraction_batch_size||l_newline);
pji_utils.write2out(l_p_def_rept_cal_type||PJI_LOOKUP_VALUE('PJI_REPORTING_CALENDARS',l_def_rept_cal_type)||l_newline);
pji_utils.write2out(l_p_def_rept_cur_type||PJI_LOOKUP_VALUE('PJI_REP_CURRENCY_TYPE',l_def_rept_cur_type)||l_newline);


-- For PJP Setup options
BEGIN
SELECT
GLOBAL_CURR2_FLAG GLB_CURR_FLAG,       -- Secondary global Currency (Optional)
TXN_CURR_FLAG TXN_CURR_FLAG,      -- Transaction Currency (Optional)
PLANAMT_CONV_DATE PLANAMT_CONV_DATE,       -- Planned amount conversion (Mandatory)
PLANAMT_ALLOC_METHOD PLANAMT_ALLOC_METHOD, -- Planning amount allocation (Mandatory)
CURR_REP_PA_PERIOD  CURR_REP_PA_PERIOD,    -- GL periods (Mandatory)-
CURR_REP_GL_PERIOD CURR_REP_GL_PERIOD,     -- PA periods (Mandatory)-
CURR_REP_ENT_PERIOD CURR_REP_ENT_PERIOD    -- Enterprise (global) periods (Mandatory)
INTO
l_glb_curr_flag,
l_txn_curr_flag,
l_planamt_conv_date,
l_planamt_alloc_method,
l_curr_rep_pa_period,
l_curr_rep_gl_period,
l_curr_rep_ent_period
FROM PJI_SYSTEM_SETTINGS;

--- IF Periods are specific then getting the specific values
/* If l_curr_rep_pa_period = 'SPECIFIC' or l_curr_rep_gl_period = 'SPECIFIC'
or l_curr_rep_ent_period = 'SPECIFIC' then  5207578 */
begin

/*SELECT INFO.PA_CURR_REP_PERIOD PROJECT_PERIOD_NAME,  -- PA periods (Mandatory)-
	   INFO.GL_CURR_REP_PERIOD FISCAL_PERIOD_NAME,     -- GL periods (Mandatory)-
	   PARAMS.VALUE GLOBAL_PERIOD_NAME 		      -- Enterprise (global) periods (Mandatory)
INTO
l_sp_curr_rep_pa_period,
l_sp_curr_rep_gl_period,
l_sp_curr_rep_ent_period
FROM   PJI_ORG_EXTR_INFO INFO,
       PJI_SYSTEM_PARAMETERS PARAMS
WHERE 1=1
       AND ORG_ID = NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
      '    ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)
       AND PARAMS.NAME = 'PJI_PJP_ENT_CURR_REP_PERIOD';   */
SELECT ORG.name,
       DECODE(l_curr_rep_pa_period,'SPECIFIC',INFO.PA_CURR_REP_PERIOD, Derive_curr_rep_Info(ORG_ID,'P',l_curr_rep_pa_period)) PROJECT_PERIOD_NAME,  -- PA periods (Mandatory)-
       DECODE(l_curr_rep_gl_period,'SPECIFIC',INFO.GL_CURR_REP_PERIOD, Derive_curr_rep_Info(ORG_ID,'G',l_curr_rep_gl_period)) FISCAL_PERIOD_NAME,     -- GL periods (Mandatory)
       DECODE(l_curr_rep_ent_period,'SPECIFIC',pji_utils.get_parameter('PJI_PJP_ENT_CURR_REP_PERIOD'), Derive_curr_rep_Info(ORG_ID,'E',l_curr_rep_ent_period)) GLOBAL_PERIOD_NAME 		      -- Enterprise (global) periods (Mandatory)
BULK COLLECT INTO
l_sp_curr_rep_org_tbl,
l_sp_curr_rep_pa_period_tbl,
l_sp_curr_rep_gl_period_tbl,
l_sp_curr_rep_ent_period_tbl
FROM   PJI_ORG_EXTR_INFO INFO,
       HR_ALL_ORGANIZATION_UNITS_VL ORG
WHERE  ORGANIZATION_ID = ORG_ID
  ORDER BY ORG.NAME;
EXCEPTION WHEN NO_DATA_FOUND then
Null;
END;
-- end if;  /*	5207578 */
EXCEPTION WHEN NO_DATA_FOUND then
     l_err_msg := 'PJP Setup Options are not available';
     l_prm_miss := 1;
     return;
END;

-- For PJP setup options prompt or caption
BEGIN
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();
prof_opt_tbl := SYSTEM.pa_varchar2_240_tbl_type();

SELECT  lookup_code , RPAD(MEANING,45,' ')||': ' BULK COLLECT
INTO prof_opt_tbl,prof_val_tbl
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_PJP_SET_PARAMS'
	and lookup_code in ( 'PJP_SE_GLO_CURR',
'PJP_TXN_CURR',
'PJP_PLN_AMT_ALC',
'PJP_PLN_AMT_CON',
'PJP_CURR_REP_PA_PD',
'PJP_CURR_REP_GL_PD',
'PJP_CURR_REP_EN_PD');



FOR I IN 1..prof_opt_tbl.COUNT LOOP
  if prof_opt_tbl(i) = 'PJP_SE_GLO_CURR' then
  l_p_glb_curr_flag := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_TXN_CURR' then
  l_p_txn_curr_flag := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_PLN_AMT_ALC' then
  l_p_planamt_alloc_method := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_PLN_AMT_CON' then
  l_p_planamt_conv_date  := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_CURR_REP_PA_PD' then
  l_p_curr_rep_pa_period := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_CURR_REP_GL_PD' then
   l_p_curr_rep_gl_period := prof_val_tbl(i);
  end if ;
  if prof_opt_tbl(i) = 'PJP_CURR_REP_EN_PD' then
   l_p_curr_rep_ent_period := prof_val_tbl(i);
  end if ;
end loop;
EXCEPTION WHEN NO_DATA_FOUND THEN
     l_err_msg := 'PJP Setup Options prompts are not available in lookup table';
     l_prm_miss := 1;
     return;
END;
-- For checking the missing options mandatory or optional
if (l_planamt_conv_date is null or l_planamt_alloc_method is null or
l_curr_rep_pa_period is null or l_curr_rep_gl_period is null or
l_curr_rep_ent_period is null)  then
if l_prm_miss < 2 then
l_prm_miss := 2;
end if;
l_pjp_note := 1;
end if;
if (l_glb_curr_flag is null or l_txn_curr_flag is null )  then
l_pjp_note := 1;
if  l_prm_miss < 3 then
if nvl(l_prm_miss,0) = 2 then
l_prm_miss := 4;
else
l_prm_miss := 3;
end if;
end if;
end if;
--- PJP Report printing
pji_utils.write2out(l_newline ||l_pji_head3||l_newline||l_pji_line3||l_newline);
 pji_utils.write2out(l_p_glb_curr_flag||PJI_LOOKUP_VALUE('PJI_YES_NO',l_glb_curr_flag)||l_newline);
 pji_utils.write2out(l_p_txn_curr_flag||PJI_LOOKUP_VALUE('PJI_YES_NO',l_txn_curr_flag)||l_newline);
 pji_utils.write2out(l_p_planamt_conv_date||PJI_LOOKUP_VALUE('PJI_PLN_AMT_CON',l_planamt_conv_date)||l_newline);
 pji_utils.write2out(l_p_planamt_alloc_method||PJI_LOOKUP_VALUE('PJI_PLN_AMT_ALC',l_planamt_alloc_method)||l_newline);
 pji_utils.write2out(l_newline||FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_PD')||l_newline);
 pji_utils.write2out(l_p_curr_rep_pa_period||PJI_LOOKUP_VALUE('PJI_CURR_REP_PD',l_curr_rep_pa_period)||l_newline);
 pji_utils.write2out(l_p_curr_rep_gl_period||PJI_LOOKUP_VALUE('PJI_CURR_REP_PD',l_curr_rep_gl_period)||l_newline);
 pji_utils.write2out(l_p_curr_rep_ent_period||PJI_LOOKUP_VALUE('PJI_CURR_REP_PD',l_curr_rep_ent_period)||l_newline||l_newline||l_newline);
--- Organization wise current reporting period table
/* If l_curr_rep_pa_period = 'SPECIFIC' or l_curr_rep_gl_period = 'SPECIFIC'
or l_curr_rep_ent_period = 'SPECIFIC' then  5207578 */
pji_utils.write2out(FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_TBL_H')||l_newline);
pji_utils.write2out(RPAD(l_pji_tline,81,'-')||l_newline);
pji_utils.write2out('|'||RPAD(FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_OU'),27,' ')||'|'||RPAD(l_p_curr_rep_pa_period,16,' ')||'|'||
RPAD(l_p_curr_rep_gl_period,16,' ')||'|'||RPAD(l_p_curr_rep_ent_period,17,' ')||'|'||l_newline);
pji_utils.write2out(RPAD(l_pji_tline,81,'-')||l_newline);
For i in 1..l_sp_curr_rep_org_tbl.count loop
pji_utils.write2out('|'||RPAD(l_sp_curr_rep_org_tbl(i),27,' ')||'|'||RPAD(nvl(l_sp_curr_rep_pa_period_tbl(i),l_p_curr_rep_not),16,' ')||'|'||
RPAD(nvl(l_sp_curr_rep_gl_period_tbl(i),l_p_curr_rep_not),16,' ')||'|'||RPAD(nvl(l_sp_curr_rep_ent_period_tbl(i),l_p_curr_rep_not),17,' ')||'|'||l_newline);
for j in 1..ceil(length(l_sp_curr_rep_org_tbl(i))/27)-1 loop
pji_utils.write2out('|'||RPAD(substr(l_sp_curr_rep_org_tbl(i),(j*27)+1,j+1*27),27,' ')||'|'||RPAD(' ',16,' ')||'|'||
RPAD(' ',16,' ')||'|'||RPAD(' ',17,' ')||'|'||l_newline);
end loop;

if l_sp_curr_rep_pa_period_tbl(i) is null or l_sp_curr_rep_gl_period_tbl(i) is null
or l_sp_curr_rep_ent_period_tbl(i) is null then
l_sp_note := 1;
if l_prm_miss < 2 then
l_prm_miss := 2;
end if;
end if;
end loop;
pji_utils.write2out(RPAD(l_pji_tline,81,'-')||l_newline);

-- end if;   /*	5207578 */


-- Exception reporting for all setup missing
-- Mandatory Setup
if l_prm_miss = 2 or l_prm_miss = 4 then
pji_utils.write2out(l_newline ||l_pji_head4||l_newline||l_pji_line4||l_newline);
if l_bis_pri_curr_code is NULL then
pji_utils.write2out(l_p_bis_pri_curr_code||l_newline);
end if;
if l_bis_pri_rate_type is NULL  then
pji_utils.write2out(l_p_bis_pri_rate_type||l_newline);
end if;
if l_bis_ent_calendar is NULL then
pji_utils.write2out(l_p_bis_ent_calendar||l_newline);
end if;
if l_bis_period_type is NULL then
pji_utils.write2out(l_p_bis_period_type||l_newline);
end if;
if l_bis_global_start_date is NULL then
pji_utils.write2out(l_p_bis_global_start_date||l_newline);
end if;
if l_planamt_conv_date is NULL then
pji_utils.write2out(l_p_planamt_conv_date||l_newline);
end if;
if l_planamt_alloc_method is NULL then
pji_utils.write2out(l_p_planamt_alloc_method||l_newline);
end if;
--- For Current reporting periods
if l_curr_rep_pa_period is NULL or l_curr_rep_gl_period is NULL or
l_curr_rep_ent_period is NULL then
pji_utils.write2out(l_newline||FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_PD')||l_newline);
end if;
if l_curr_rep_pa_period is NULL then
pji_utils.write2out(l_p_curr_rep_pa_period||l_newline);
end if;
if l_curr_rep_gl_period is NULL then
pji_utils.write2out(l_p_curr_rep_gl_period||l_newline);
end if;
if l_curr_rep_ent_period is NULL then
pji_utils.write2out(l_p_curr_rep_ent_period||l_newline);
end if;
--- For Current reporting period when SPECIFIC
if l_sp_note = 1 then
pji_utils.write2out(l_newline||FND_MESSAGE.GET_STRING('PJI','PJI_CURR_REP_MISS')||l_newline);
end if;

end if;
-- Optional Set up
if l_prm_miss = 3 or l_prm_miss = 4 then
pji_utils.write2out(l_newline ||l_pji_head5||l_newline||l_pji_line5||l_newline);
if l_bis_sec_curr_code is NULL then
pji_utils.write2out(l_p_bis_sec_curr_code||l_newline);
end if;
if l_bis_sec_rate_type is NULL then
pji_utils.write2out(l_p_bis_sec_rate_type||l_newline);
end if;
if l_pji_global_start_date is NULL then
pji_utils.write2out(l_p_pji_global_start_date||l_newline);
end if;
if l_glb_curr_flag is null then
pji_utils.write2out(l_p_glb_curr_flag||l_newline);
end if;
if l_txn_curr_flag is null then
pji_utils.write2out(l_p_txn_curr_flag||l_newline);
end if;
end if;
--- Notes at the end of the report if any thing missing
if l_prm_miss > 1 then
pji_utils.write2out(l_newline||l_pji_foot1||l_newline);
if l_bis_note > 0 then
pji_utils.write2out(l_pji_foot2||l_newline);
end if ;
if l_pjp_note > 0 then
pji_utils.write2out(l_pji_foot3||l_newline);
end if ;
if l_sp_note > 0 then
pji_utils.write2out(l_pji_foot4||l_newline);
end if ;
end if;
Exception when others then
pji_utils.write2out('Error: '||l_err_msg);
END;

 -- -----------------------------------------------------
 -- Function PJI_LOOKUP_VALUE
 -- For getting the lookup values in project performance setups Audit report
 --   History
 --   14-MAR-2006  DEGUPTA Created
 -- -----------------------------------------------------


FUNCTION PJI_LOOKUP_VALUE (p_lookup_type VARCHAR2,p_lookup_code VARCHAR2)
       return VARCHAR2
IS
l_meaning varchar2(100);
BEGIN
IF p_lookup_code is not null then
 SELECT meaning into l_meaning
 FROM pji_lookups
 WHERE lookup_type = p_lookup_type
 and lookup_code = p_lookup_code;
 return l_meaning;
else
  return NULL;
end if;
EXCEPTION WHEN OTHERS THEN
  return p_lookup_code;
end;

 -- -----------------------------------------------------
 -- Function Is_plantype_upgrade_pending
 -- For checkingif plantype upgrad epending for the program
 --   History
 --   07-APR-2006  AJDAS Created
 -- -----------------------------------------------------


  FUNCTION Is_plantype_upgrade_pending (p_project_id IN NUMBER)
        return VARCHAR2
IS
l_return varchar2(1):='N';
BEGIN
 if (PJI_UTILS.GET_PARAMETER('PJI_PTC_UPGRADE') = 'P') then

select 'Y'
into l_return
from dual
where  exists (SELECT 1
               FROM   pa_proj_element_versions pa
                     ,pa_proj_element_versions pap
                     ,pa_pji_proj_events_log log
               WHERE  pa.project_id=p_project_id
		 and  pa.prg_group=pap.prg_group
		 and pa.OBJECT_TYPE=pap.OBJECT_TYPE
		 and pa.OBJECT_TYPE='PA_STRUCTURES'
	         and log.event_object=to_char(pap.project_id)
		 and log.event_type='PLANTYPE_UPG'
                 );
 end if;
  return l_return;
 EXCEPTION WHEN NO_DATA_FOUND THEN
  return l_return;
   WHEN OTHERS THEN
  return l_return;

END;

 -- -----------------------------------------------------
 -- Function Fin_Summ_Upgrade_Status
 -- For checking the status of financial summary upgrade
 --   History
 --   23-JUL-2006  PSCHANDR Created
 -- -----------------------------------------------------

  FUNCTION Fin_Summ_Upgrade_Status
        return VARCHAR2
IS
l_status VARCHAR2(1);
l_count NUMBER(10);
begin
select PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE') into l_status from dual;
IF l_status = 'P' THEN
     select count(1) into l_count from PJI_SYSTEM_CONFIG_HIST
     where  PROCESS_NAME = 'STAGE3'
     and END_DATE is null and RUN_TYPE = 'CLEANALL';

     if l_count > 0 then
        return 'R';
     else
        return 'E';
     end if;
ELSIF l_status is null THEN
     return 'P';
ELSE
     return 'C';

END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return 'P';
   WHEN OTHERS THEN
      return 'P';

END;

  -- ******************************************************
  -- Private procedures and functions
  -- ******************************************************

  procedure init_settings_cache is
  begin

    select *
    into g_pji_settings
    from pji_system_settings;

    g_settings_init_flag := TRUE;

  end init_settings_cache;

  procedure init_session_cache is
  begin

    select sid, osuser
    into g_session_sid, g_session_osuser
    from v$session
    where audsid = userenv('SESSIONID');

    g_session_user_id := fnd_global.user_id;
    g_pa_debug_mode   := fnd_profile.value('PA_DEBUG_MODE');
    g_debug_level     := nvl(FND_PROFILE.VALUE('PJI_DEBUG_LEVEL'), 5);

  end;



end PJI_UTILS;

/

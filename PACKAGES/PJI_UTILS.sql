--------------------------------------------------------
--  DDL for Package PJI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_UTILS" AUTHID CURRENT_USER AS
/* $Header: PJIUT01S.pls 120.6 2006/07/28 12:13:51 pschandr noship $ */

  g_debug_level number(15);
  g_max_roll_days number(15);    /* 5155692  */
  -- ------------------------------------------------------
  -- function GET_PARAMETER
  --
  -- Function returns PJI parameter values stored in table
  -- PJI_SYSTEM_PARAMETERS. Function accepts parameter name
  -- as an argument
  -- ------------------------------------------------------
  function GET_PARAMETER (p_name in varchar2) return varchar2;

  -- ------------------------------------------------------
  -- procedure SET_PARAMETER
  --
  -- Procedure sets PJI system parameter value stored in
  -- PJI_SYSTEM_PARAMETERS. Procedure has two arguments:
  -- parameter name and parameter value.
  -- Note that procedure does not perform commit.
  -- ------------------------------------------------------
  procedure SET_PARAMETER
  (
    p_name  in varchar2,
    p_value in varchar2
  );

  -- ------------------------------------------------------
  -- function GET_SETUP_PARAMETER
  --
  -- Function returns PJI setup parameter values
  -- stored in PJI_SYSTEM_SETTINGS.
  -- Function accepts parameter name as an argument, currently
  -- parameter name is the same as table column name.
  -- Parameters that are stored as date columns are converted
  -- to format 'YYYY/MM/DD'
  -- ------------------------------------------------------
  function GET_SETUP_PARAMETER(p_name in varchar2) return varchar2;

  -- ------------------------------------------------------
  -- function GET_APPS_SCHEMA_NAME
  --
  -- Function returns Oracle schema name of APPS user
  -- ------------------------------------------------------
  function GET_APPS_SCHEMA_NAME return varchar2;

  -- ------------------------------------------------------
  -- function GET_PA_SCHEMA_NAME
  -- ------------------------------------------------------
  function GET_PA_SCHEMA_NAME return varchar2;

  -- ------------------------------------------------------
  -- function GET_PJI_SCHEMA_NAME
  --
  -- Function returns Oracle schema name of PJI user
  -- ------------------------------------------------------
  function GET_PJI_SCHEMA_NAME return varchar2;

  -- ------------------------------------------------------
  -- procedure SET_OUTPUT_DEST
  --
  -- This procedure is included for debugging purposes.
  -- Procedure enables to redirect message streams that normally
  -- go into concurrent program log and out files either to
  -- the screen (using DBMS_OUTPUT) or to PJI_SYSTEM_DEBUG_MSG
  -- table. P_DEBUG_DEST can have the following values:
  --
  --   'TABLE' - message goes into PJI_SYSTEM_DEBUG_MSG
  --   'DBMS_OUTPUT' - messsage is displayed using DBMS_OUTPUT;
  --
  -- Second parameter can be used when P_DEBUG_DEST is set to
  -- 'TABLE'. Parameter P_DEBUG_CONTEXT provides content of
  -- MESSAGE_CONTEXT column in PJI_SYSTEM_DEBUG_MSG.
  -- If multiple sessions are writing debug info to
  -- PJI_SYSTEM_DEBUG_MSG this column can be used to
  -- identify the message owner. By default it stores
  -- operating system user name concatenated with session id.
  -- Parameter P_DEBUG_CONTEXT enables to override it.
  --
  -- ------------------------------------------------------
  procedure SET_OUTPUT_DEST(
    p_debug_dest       varchar2,
    p_debug_context    varchar2 default NULL
  );

  -- ------------------------------------------------------
  -- procedure SET_CURR_FUNCTION
  --
  -- This procedure should be called in the beginning of
  -- any PJI program unit to put the program unit on
  -- top of PA debug stack. We should pass program unit
  -- name in the following format:
  --
  --   <package name>.<procedure/function name>
  --
  -- Example:
  --
  --  PJI_UTILS.SET_CURR_FUNCTION
  --
  -- ------------------------------------------------------
  procedure SET_CURR_FUNCTION( p_function varchar2 );

  -- ------------------------------------------------------
  -- procedure RESET_CURR_FUNCTION
  --
  -- This procedure removes top element from PA debug stack.
  -- This is the opposite of SET_CURR_FUNCTION
  -- ------------------------------------------------------
  procedure RESET_CURR_FUNCTION;

  -- ------------------------------------------------------
  -- function GET_EXTRACTION_START_DATE
  -- ------------------------------------------------------
  function GET_EXTRACTION_START_DATE return date;

  -- ------------------------------------------------------
  -- procedure WRITE2LOG
  --
  -- This procedure is used to write to the concurrent
  -- request log file. P_MSG is the message text,
  -- P_TIMER_FLAG indicates if output line contains
  -- a timestamp, value TRUE indicates that timestamp
  -- is displayed.
  -- P_DEBUG_FLAG indicates level of debug information
  -- ------------------------------------------------------
  procedure WRITE2LOG
  (
    p_msg         in varchar2,
    p_timer_flag  in boolean  default null,
    p_debug_level in number   default 1
  );


  -- ------------------------------------------------------
  -- procedure WRITE2OUT
  --
  -- Procedure writes to concurrent request output file
  -- ------------------------------------------------------
  procedure WRITE2OUT (p_msg in varchar2);

  -- ------------------------------------------------------
  -- procedure WRITE2SSWALOG
  --
  -- This procedure is used in PMV reports (and potentially
  -- other SSWA-based pages) to provide debug information.
  -- Since PMV does not support standard FWK debugging mechanism
  -- we put PMV log messages into PJI_SYSTEM_DEBUG_MSG table.
  -- P_MSG is the message text, P_DEBUG_FLAG indicates level of
  -- debug information, P_MODULE should be used to indicate
  -- what program unit is writing the message. Usually module is
  -- set to <package name>.<procedure/function name>.
  -- ------------------------------------------------------
  procedure WRITE2SSWALOG
  (
    p_msg          in varchar2,
    p_debug_level  in number  default 0,
    p_module       in varchar2 default NULL
  );

  -- ------------------------------------------------------
  -- procedure RESET_SSWA_SESSION_CACHE
  --
  -- This procedure should be executed one time
  -- before any calls to WRITE2SSWALOG.
  -- PJI_UTILS caches apps user context in a set of global
  -- variables. For example, we provide a variable that
  -- caches value of PA_DEBUG_MODE profile. Since SSWA
  -- session can be reused between multiple APPS users
  -- we need to be able to reset this cache when user
  -- changes.
  -- ------------------------------------------------------
  procedure RESET_SSWA_SESSION_CACHE;

  -- ------------------------------------------------------
  -- function GET_PJI_DATA_TSPACE
  --
  -- Function returns PJI data tablespace
  -- ------------------------------------------------------
  function GET_PJI_DATA_TSPACE return varchar2;

  -- ------------------------------------------------------
  -- function GET_PJI_IDX_TSPACE
  --
  -- Function returns PJI index tablespace
  -- ------------------------------------------------------
  function GET_PJI_INDEX_TSPACE return varchar2;

  -- ------------------------------------------------------
  -- function SPREAD_AMOUNT
  --
  -- Code of this function was copied from PA_MISC.SPREAD_AMOUNT
  -- The difference is that we do not round the result as
  -- we do not have a context of an operating unit.
  -- ------------------------------------------------------
  function SPREAD_AMOUNT (
                        x_type_of_spread    IN VARCHAR2,
                        x_start_date        IN DATE,
                        x_end_date          IN DATE,
                        x_start_pa_date     IN DATE,
                        x_end_pa_date       IN DATE,
                        x_amount            IN NUMBER)
                    RETURN NUMBER;

  pragma RESTRICT_REFERENCES ( spread_amount, WNDS, WNPS );

  -- ------------------------------------------------------
  -- function GET_GLOBAL_RATE_PRIMARY
  --
  -- This is a wrapper for FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY
  -- ------------------------------------------------------
  function get_global_rate_primary(
      p_from_currency_code  VARCHAR2,
      p_exchange_date       DATE
  ) return number;

  -- ------------------------------------------------------
  -- function GET_MAU_PRIMARY
  --
  -- This is a wrapper for FII_CURRENCY.GET_MAU_PRIMARY
  -- ------------------------------------------------------
  function get_mau_primary return number;

  -- ------------------------------------------------------
  -- function GET_GLOBAL_PRIMARY_CURRENCY
  -- ------------------------------------------------------
  function GET_GLOBAL_PRIMARY_CURRENCY
    return varchar2;

  -- ------------------------------------------------------
  -- function GET_GLOBAL_RATE_SECONDARY
  -- ------------------------------------------------------
  function GET_GLOBAL_RATE_SECONDARY(p_from_currency_code varchar2,
                                     p_exchange_date date) return number;

  -- ------------------------------------------------------
  -- function GET_MAU_SECONDARY
  -- ------------------------------------------------------
  function GET_MAU_SECONDARY return number;

  -- ------------------------------------------------------
  -- function GET_GLOBAL_SECONDARY_CURRENCY
  -- ------------------------------------------------------
  function GET_GLOBAL_SECONDARY_CURRENCY
    return varchar2;

  -- ------------------------------------------------------
  -- function GET_RATE
  -- ------------------------------------------------------
  function GET_RATE(p_from_currency_code varchar2,
                    p_to_currency_code   varchar2,
                    p_exchange_date      date) return number;

  -- ------------------------------------------------------
  -- function GET_RATE_TYPE
  -- ------------------------------------------------------
  function GET_RATE_TYPE return varchar2;

  -- ------------------------------------------------------
  -- function GET_MAU
  -- ------------------------------------------------------
  function GET_MAU (p_currency_code varchar2) return number;

  -- ------------------------------------------------------
  -- function GET_DEGREE_OF_PARALLELISM
  -- ------------------------------------------------------
  function GET_DEGREE_OF_PARALLELISM return number;

-----------------------------------------------------
-- function get_period_set_name
-- -----------------------------------------------------
FUNCTION get_period_set_name RETURN VARCHAR2;

-- -----------------------------------------------------
-- function get_START_DAY_OF_WEEK_ID
-- -----------------------------------------------------
FUNCTION get_START_DAY_OF_WEEK_ID  RETURN VARCHAR2;

-- -----------------------------------------------------
-- function get_period_type
-- -----------------------------------------------------
FUNCTION get_period_type  RETURN VARCHAR2;

-- -----------------------------------------------------
-- function getMissingRateHeader
-- -----------------------------------------------------
FUNCTION  getMissingRateHeader return VARCHAR2;

-- -----------------------------------------------------
-- function getMissingRateText
-- -----------------------------------------------------
FUNCTION getMissingRateText(
p_rate_type IN VARCHAR2,
p_from_currency IN VARCHAR2,
p_to_currency in VARCHAR2,
p_date IN DATE,
p_date_override IN VARCHAR2) return VARCHAR2;

  -- -----------------------------------------------------
  -- function CHECK_PROGRAM_RBS
  -- -----------------------------------------------------
  function CHECK_PROGRAM_RBS (p_project_id     in number,
                              p_rbs_version_id in number)
           return number;

 -- -----------------------------------------------------
 -- Function PJI_LOOKUP_VALUE
 -- For getting the lookup values in project performance setups Audit report
 -- -----------------------------------------------------
   FUNCTION PJI_LOOKUP_VALUE (p_lookup_type VARCHAR2,
                              p_lookup_code VARCHAR2)
       return VARCHAR2;

 -- -----------------------------------------------------
 -- Function Derive_Curr_rep_Info
 -- For getting Current Reporting period values in project performance setups Audit report
 -- -----------------------------------------------------

  FUNCTION Derive_Curr_rep_Info(p_org_id NUMBER
                              , p_calendar_type VARCHAR2
							  , p_active_rep VARCHAR2
                               )
        return VARCHAR2;
 -- -----------------------------------------------------
  -- Procedure REPORT_PJP_PARAM_SETUP
  -- For project performance setups Audit report
 -- -----------------------------------------------------
   PROCEDURE REPORT_PJP_PARAM_SETUP
	(errbuff        OUT NOCOPY VARCHAR2,
         retcode        OUT NOCOPY VARCHAR2);

	  -- -----------------------------------------------------
 -- Function Is_plantype_upgrade_pending
 -- Used in the UI pages to show the upgrade pending message
 -- -----------------------------------------------------
   FUNCTION Is_plantype_upgrade_pending (p_project_id IN NUMBER)
       return VARCHAR2;

 -- Function Fin_Summ_Upgrade_Status
 -- Used in the UI pages to show the financial summary upgrade status message
 -- -----------------------------------------------------
   FUNCTION Fin_Summ_Upgrade_Status
       return VARCHAR2;

end PJI_UTILS;

 

/

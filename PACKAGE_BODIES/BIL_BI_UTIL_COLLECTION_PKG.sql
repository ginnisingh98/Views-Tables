--------------------------------------------------------
--  DDL for Package Body BIL_BI_UTIL_COLLECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_UTIL_COLLECTION_PKG" AS
/*$Header: bilbutcb.pls 120.1 2006/03/27 22:04:23 jmahendr noship $*/

 -- Declare global variables
  g_debug  BOOLEAN;


FUNCTION get_global_rate_p (code IN varchar2, rate_Date IN date)
RETURN NUMBER
parallel_enable IS
BEGIN
return FII_CURRENCY.Get_Global_Rate_Primary(code,rate_date);
END get_global_rate_p ;


FUNCTION get_global_rate_s (code IN varchar2, rate_Date IN date)
RETURN NUMBER
parallel_enable IS
BEGIN
return FII_CURRENCY.Get_Global_Rate_secondary(code,rate_date);
END get_global_rate_s ;


-- **********************************************************************
--  FUNCTION get_schema_name
--
--  Purpose:
--  To retrieve the schema name for the given Application Short Name
--
-- **********************************************************************

FUNCTION get_schema_name(p_appl_name IN VARCHAR2)
RETURN VARCHAR2 IS
 l_status VARCHAR2(1000);
 l_industry VARCHAR2(1000);
 l_schema_name VARCHAR2(1000);
 l_return BOOLEAN;
 l_app_name VARCHAR2(100);
BEGIN

  -- Call the FND proc to return schema name
  l_return := FND_INSTALLATION.GET_APP_INFO(p_appl_name,l_status,l_industry,l_schema_name);
  RETURN l_schema_name;

EXCEPTION
 WHEN OTHERS THEN
  BEGIN
   SELECT u.oracle_username
     INTO l_schema_name
     FROM fnd_application a,
      fnd_product_installations i,
      fnd_oracle_userid u
    WHERE a.application_short_name = l_app_name
      AND a.application_id = i.application_id
      AND u.oracle_id = i.oracle_id;
   RETURN l_schema_name;
   EXCEPTION
    WHEN OTHERS THEN
  RETURN NULL;
  END;

END get_schema_name;

-- **********************************************************************
--  FUNCTION get_apps_schema_name
--
--  Purpose:
--  To retrieve the apps schema name
--
-- **********************************************************************

FUNCTION get_apps_schema_name
RETURN VARCHAR2 IS
  l_apps_schema_name VARCHAR2(200);
BEGIN
  SELECT u.oracle_username
    INTO l_apps_schema_name
    FROM fnd_oracle_userid u
   WHERE u.oracle_id = 900;
  RETURN l_apps_schema_name;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END get_apps_schema_name;


-- **********************************************************************
--  PROCEDURE analyze_table
--
--  Purpose:
--  To Analyze the input Sales Intelligence table from the BIL
--    schema
--
-- **********************************************************************

PROCEDURE analyze_table (p_tbl_name IN VARCHAR2,
         p_cascade IN BOOLEAN,
         p_est_pct IN NUMBER,
         p_granularity IN VARCHAR2) IS

   l_schema_name VARCHAR2(400);
BEGIN

  l_schema_name := get_schema_name(p_appl_name => 'BIL');

      FND_STATS.gather_table_stats(
      ownname=> l_schema_name,
      tabName=> p_tbl_name,
      cascade=> p_cascade,
      degree=> bis_common_parameters.get_degree_of_parallelism,
      percent=> p_est_pct,
      granularity=> p_granularity);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END analyze_table;


-- ********************************************************************
--  PROCEDURE drop_table
--
--  Purpose:
--   To drop the table specified.
--
-- ********************************************************************

    PROCEDURE drop_table (p_table_name IN varchar2) is
      l_stmt varchar2(400);
   l_schema_name VARCHAR2(400);
  l_error EXCEPTION;
  PRAGMA EXCEPTION_INIT (l_error, -942);

    BEGIN

  l_schema_name := get_schema_name(p_appl_name => 'BIL');
      l_stmt:='DROP TABLE '|| l_schema_name || '.' || p_table_name;

      EXECUTE IMMEDIATE l_stmt;

    EXCEPTION
      WHEN OTHERS THEN
   NULL;
  END drop_table;


-- ********************************************************************
--  PROCEDURE truncate_table
--
--  Purpose:
--   To remove all the records from the table specified.
--
-- ********************************************************************

    PROCEDURE truncate_table (p_table_name IN varchar2) is
      l_stmt varchar2(400);
   l_schema_name VARCHAR2(400);

    BEGIN
  l_schema_name := get_schema_name(p_appl_name => 'BIL');
      l_stmt:='TRUNCATE TABLE '|| l_schema_name || '.'|| p_table_name;

-- Since Fact table has a log
    IF (UPPER(p_table_name) IN ('BIL_BI_FST_DTL_F', 'BIL_BI_OPDTL_F', 'BIL_BI_PIPELINE_F')) THEN
      l_stmt := l_stmt || ' PURGE MATERIALIZED VIEW LOG ';
    END IF;

      EXECUTE IMMEDIATE l_stmt;

    EXCEPTION
      WHEN OTHERS THEN
   NULL;
  END truncate_table;

-- ********************************************************************
--  FUNCTION get_profile_value
--
--  Purpose:
--   To get the profile value of the specified parameter
--
-- ********************************************************************

FUNCTION get_profile_value (p_profile_parameter IN VARCHAR2)
RETURN VARCHAR2
IS
  l_profile_value VARCHAR2(400);
BEGIN
    l_profile_value := FND_PROFILE.VALUE(p_profile_parameter);
  RETURN l_profile_value;
EXCEPTION
  WHEN OTHERS THEN
   RETURN NULL;
END get_profile_value;


--  **********************************************************************
--  FUNCTION chkLogLevel
--
--  Purpose
--  To check if log is Enabled for Messages
--      This function is a wrapper on FND APIs for OA Common Error
--       logging framework
--
--        p_log_level = Severity; valid values are -
--      1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--      2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--      3. Event Level (FND_LOG.LEVEL_EVENT)
--      4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--      5. Error Level (FND_LOG.LEVEL_ERROR)
--      6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--
--  Output values:-
--                       = TRUE if FND Log is Enabled or BIS Log is Enabled
--             = FALSE if both are DISABLED
--
--
--  **********************************************************************

FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN IS
 BEGIN
g_debug := NVL(BIS_COLLECTION_UTILITIES.g_debug,FALSE);
   IF (p_log_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL) -- FND log is enabled
     OR NVL(BIS_COLLECTION_UTILITIES.g_debug,FALSE) -- BIS Log is enabled
    THEN
      RETURN TRUE;
   END IF;
  RETURN FALSE;

 EXCEPTION
  WHEN OTHERS THEN
    NULL;

END chkLogLevel;


--  **********************************************************************
--  PROCEDURE writeLog
--
--  Purpose:
--  To log Messages
--      This procedure is a wrapper on FND APIs for OA Common Error
--       logging framework for Severity = Statement(1), Procedure(2)
--       , Event(3), Expected (4) and Error (5)
--
--      Input Variables :-
--        p_log_level = Severity; valid values are -
--      1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--      2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--      3. Event Level (FND_LOG.LEVEL_EVENT)
--      4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--      5. Error Level (FND_LOG.LEVEL_ERROR)
--      6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--        p_module = Module Source Details
--        p_msg    = Message String
--        p_force_log = Force message in log file. Default False.
--
--  **********************************************************************

PROCEDURE writeLog
          (
            p_log_level IN NUMBER,
            p_module IN VARCHAR2,
            p_msg IN VARCHAR2,
            p_force_log IN BOOLEAN DEFAULT FALSE
          )
IS
 l_msg VARCHAR2(40);

 BEGIN

  -- Log errors in concurrent request output file and log file forcefully

  /*
    Log error/unexpected errors irrespective of the log level profile setup.
    TB checked up with weijun if this is the intended func.
  */

  l_msg := TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');
  IF (p_log_level IN (fnd_log.LEVEL_ERROR, fnd_log.LEVEL_UNEXPECTED))  THEN
    BIS_COLLECTION_UTILITIES.put_line_out(p_msg);

    --this line will put the gist of the error message in the log file
    BIS_COLLECTION_UTILITIES.put_line(l_msg || ' : ' || p_module || ' : ' || p_msg,p_log_level);


  ELSE  -- Log message in concurrent request log file
    BIS_COLLECTION_UTILITIES.put_line(l_msg || ' : ' || p_module || ' : ' || p_msg,p_log_level);
  END IF;  -- p_log_level

 EXCEPTION
  WHEN OTHERS THEN
   NULL;

END writeLog;


--  **********************************************************************
--  FUNCTION get_user_profile_name
--
--  Purpose
--  To return the User PRofile Name
--
--    Input value  = p_profile_name = Profile Name
--
--  Output values:-
--               = Profile Option Name for the User
--
--
--  **********************************************************************

FUNCTION get_user_profile_name (p_profile_name IN VARCHAR2) RETURN VARCHAR2 IS
   l_name varchar2(240) ;
   l_proc VARCHAR2(100) ;
BEGIN
l_proc := 'get_user_profile_name.';

  SELECT user_profile_option_name
    INTO l_name
    FROM fnd_profile_options_tl tl
   WHERE tl.profile_option_name = p_profile_name
     AND tl.LANGUAGE = userenv('LANG');

     RETURN l_name;

  EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
     RAISE;

END get_user_profile_name;


END bil_bi_util_collection_pkg;

/

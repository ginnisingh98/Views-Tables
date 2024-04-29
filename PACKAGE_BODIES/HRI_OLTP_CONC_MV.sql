--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_CONC_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_CONC_MV" AS
/* $Header: hriocmvr.pkb 120.1.12010000.2 2009/03/17 12:10:58 sudsahu ship $ */

--
g_conc_request_id         NUMBER := fnd_global.conc_request_id;
g_schema                VARCHAR2(50);
--
--Private Function
FUNCTION get_apps_schema_name RETURN VARCHAR2;

/*
**
*/
PROCEDURE refresh_mv_sql
        (p_mv_name         IN VARCHAR2
        ,p_mv_refresh_mode IN VARCHAR2)
IS

BEGIN

   IF (p_mv_name IS NOT NULL
      AND p_mv_refresh_mode IN ('C') ) THEN
        dbms_mview.refresh(p_mv_name, p_mv_refresh_mode);
   END IF;


   -- bug 4775190, disable query rewrite so view compiles on 8i database
   IF p_mv_name = 'HRI_MDP_SUP_WRKFC_JX_MV' THEN

       EXECUTE IMMEDIATE 'ALTER MATERIALIZED VIEW  HRI_MDP_SUP_WRKFC_JX_MV DISABLE QUERY REWRITE';

   END IF;

EXCEPTION WHEN OTHERS THEN
   RAISE;

END  refresh_mv_sql;

-- -----------------------------------------------------------------------------
-- Inserts row into concurrent program log
-- -----------------------------------------------------------------------------
--
PROCEDURE output(p_text  VARCHAR2) IS
  --
BEGIN
  --
  g_conc_request_id := fnd_global.conc_request_id;
  --
  IF g_conc_request_id IS NOT NULL THEN
    --
    -- Write to the concurrent request log
    --
    fnd_file.put_line(fnd_file.log, p_text);
    --
  ELSE
    --
    hr_utility.trace(p_text);
    --
  END IF;
  --
END output;



/*
** Procedure wrapper for concurrent process to call
** dbms_mview.refresh_mv() procedure
*/
PROCEDURE refresh_mv
        (errbuf          OUT NOCOPY  VARCHAR2
        ,retcode         OUT NOCOPY VARCHAR2
        ,p_mv_name         IN VARCHAR2
        ,p_mv_refresh_mode IN VARCHAR2)
IS

  -- Variables required for table truncation.
  --
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);

BEGIN

   output('Materialized View:  ' || p_mv_name);
   output('Refresh Mode     :  ' || p_mv_refresh_mode);

  -- Find the schema we are running in.
  --
  --IF NOT fnd_installation.get_app_info('APPS',l_dummy1, l_dummy2, g_schema) THEN
  -- the above statement was commented as part of the fix for the bug#6040715 as the function
  -- was not initializing g_schema
    --
    -- Could not find the schema raising exception.
    --
--    output('Could not find schema to run in.');
    --
    --RAISE NO_DATA_FOUND;
    --
  --END IF;

   g_schema := get_apps_schema_name;
   IF g_schema IS NULL then
     RAISE NO_DATA_FOUND;
   END IF;

   IF (p_mv_name IS NOT NULL
      AND p_mv_refresh_mode IN ('C') ) THEN

        output('Refreshing the Materialized View:  ' || p_mv_name);
        output('Start time: ' || to_char(sysdate, 'DD-MON-YYYY HH.MI.SS'));
        refresh_mv_sql(p_mv_name, p_mv_refresh_mode);
        output('Gathering table statstics, start: '|| to_char(sysdate, 'DD-MON-YYYY HH.MI.SS'));
        fnd_stats.gather_table_stats(g_schema, p_mv_name);
        output('Gathering table statstics, end: '|| to_char(sysdate, 'DD-MON-YYYY HH.MI.SS'));

        output('End time: ' || to_char(sysdate, 'DD-MON-YYYY HH.MI.SS'));

   ELSE
        output('Error: Invalid paramters');
       errbuf  := 'ERROR';
       retcode := '2';

   END IF;

EXCEPTION WHEN OTHERS THEN
  output('EXCEPTION: ' || substr(SQLERRM, 80) );
  errbuf  := 'ERROR';
  retcode := '2';

END refresh_mv;

--
--Following Function is used to fetch oracle schema name used to gather stats for MV's
--Added to address bug#6040715
--
  FUNCTION get_apps_schema_name RETURN VARCHAR2 IS

     l_apps_schema_name VARCHAR2(30);

     CURSOR c_apps_schema_name IS
	SELECT oracle_username
	  FROM fnd_oracle_userid WHERE oracle_id
	  BETWEEN 900 AND 999 AND read_only_flag = 'U';
  BEGIN

     OPEN c_apps_schema_name;
     FETCH c_apps_schema_name INTO l_apps_schema_name;
     CLOSE c_apps_schema_name;
     RETURN l_apps_schema_name;

  EXCEPTION
     WHEN OTHERS THEN
	output('Could not find schema to run in.');
        Return Null;
  END get_apps_schema_name;

END HRI_OLTP_CONC_MV;

/

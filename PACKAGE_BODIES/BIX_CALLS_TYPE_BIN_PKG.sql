--------------------------------------------------------
--  DDL for Package Body BIX_CALLS_TYPE_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CALLS_TYPE_BIN_PKG" AS
/*$Header: bixxbctb.pls 115.11 2003/01/10 00:14:48 achanda ship $*/

PROCEDURE populate(p_context IN VARCHAR2 DEFAULT NULL)
IS

  l_session_id      NUMBER;
  l_reporting_date  DATE;

BEGIN

  /* Get the ICX Session Id */
  SELECT icx_sec.g_session_id
  INTO   l_session_id
  FROM   dual;

  /* Delete the rows from the table bix_dm_bin for the current icx session and bin     */
  /* so that we donot display the leftover rows from the previous execution of the bin */
  DELETE bix_dm_bin
  WHERE  bin_code    = 'BIX_CALLS_TYPE_BIN'
  AND    session_id  = l_session_id;

  /* The bin will always display data for maximum date for which data has been collected */
  SELECT MAX(period_start_date)
  INTO   l_reporting_date
  FROM   bix_dm_agent_call_sum;

  /* Fetch all the records from the summary table for l_reporting_date grouped by classification */
  INSERT /*+ PARALLEL(tb,2) */ INTO bix_dm_bin tb (
		session_id
	   , bin_code
        , col1
        , col2
	   , col4
	   , col6
	   , col8 )
  ( SELECT /*+ PARALLEL(acs,2) */
		l_session_id
	   ,	'BIX_CALLS_TYPE_BIN'
        , to_char(acs.classification_id) || 'n'
	   , cct.classification
	   , bix_util_pkg.get_hrmiss_frmt(SUM(acs.abandon_time)
					/ DECODE(SUM(acs.calls_abandoned), 0, 1, SUM(acs.calls_abandoned)))
	   , bix_util_pkg.get_hrmiss_frmt(SUM(acs.queue_time)
					/ DECODE(SUM(acs.calls_in_queue), 0, 1, SUM(acs.calls_in_queue)))
	   , trunc((SUM(acs.calls_answrd_within_x_time)
					/ DECODE(SUM(acs.in_calls_handled), 0, 1, SUM(acs.in_calls_handled))) * 100, 2)
    FROM     bix_dm_agent_call_sum acs
	      , cct_classifications cct
    WHERE  acs.period_start_date = l_reporting_date
    AND    acs.classification_id = cct.classification_id
    GROUP BY acs.classification_id
	     ,  cct.classification );

  commit;

EXCEPTION
    WHEN OTHERS
    THEN RAISE;
END populate;

END BIX_CALLS_TYPE_BIN_PKG;

/

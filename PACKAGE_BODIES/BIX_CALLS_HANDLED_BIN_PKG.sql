--------------------------------------------------------
--  DDL for Package Body BIX_CALLS_HANDLED_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CALLS_HANDLED_BIN_PKG" AS
/*$Header: bixxbchb.pls 115.10 2003/01/10 00:14:53 achanda ship $*/

PROCEDURE populate(p_context IN VARCHAR2 DEFAULT NULL)
IS

 l_default_group_id   NUMBER;
 l_reporting_date     DATE;
 l_session_id      NUMBER;

BEGIN

  /* Get the ICX Session Id */
  SELECT icx_sec.g_session_id
  INTO   l_session_id
  FROM   dual;

  /* Delete the rows from table bix_dm_bin for the current icx session and bin */
  DELETE bix_dm_bin
  WHERE  bin_code    = 'BIX_CALLS_HANDLED_BIN'
  AND    session_id  = l_session_id;

  /* Get the default Agent Group of the Agent executing the report */
  SELECT fnd_profile.value('BIX_DM_DEFAULT_GROUP')
  INTO   l_default_group_id
  FROM   dual;

  /* If the user has not setup his/her default group fetch any one group  */
  /* to which the user belongs and report on that group; if the user does */
  /* not belong to any group then do not show any data in the bin         */
  IF l_default_group_id IS NULL THEN
    BEGIN
      SELECT  grp.group_id
      INTO    l_default_group_id
      FROM    jtf_rs_group_members grp
		  , jtf_rs_resource_extns rsc
      WHERE  grp.resource_id = rsc.resource_id
      AND    rsc.user_id = fnd_global.user_id()
      AND    ROWNUM <= 1;
    EXCEPTION
	 WHEN no_data_found THEN
	 RETURN;
    END;
  END IF;

  /* The bin will always display data for maximum date for which data has been collected */
  SELECT MAX(period_start_date)
  INTO   l_reporting_date
  FROM   bix_dm_agent_call_sum;

  /* Fetch the records of all the agents belonging to the group */
  /* l_default_group_id and insert them in the table bix_dm_bin */
  INSERT /*+ PARALLEL(tb,2) */ INTO bix_dm_bin tb (
		session_id
	   , bin_code
        , col1
        , col2
	   , col4
	   , col6
	   , col8 )
  ( SELECT  /*+ PARALLEL(bac,2) */
		l_session_id
	   , 'BIX_CALLS_HANDLED_BIN'
	   , 'p' || to_char(l_default_group_id)
	   , rsc.source_name
	   , SUM(bac.in_calls_handled)
	   , SUM(bac.out_calls_handled)
	   , bix_util_pkg.get_hrmiss_frmt(trunc(SUM(bac.in_talk_time + bac.out_talk_time + bac.in_wrap_time +
			 bac.out_wrap_time) / DECODE(SUM(bac.in_calls_handled + bac.out_calls_handled),
			            0, 1, SUM(bac.in_calls_handled + bac.out_calls_handled))))
    FROM    bix_dm_agent_call_sum bac
          , jtf_rs_group_members  mem
		, jtf_rs_resource_extns rsc
    WHERE  mem.group_id          = l_default_group_id
    AND    mem.resource_id       = rsc.resource_id
    AND    mem.resource_id       = bac.resource_id
    AND    bac.period_start_date = l_reporting_date
    GROUP BY rsc.source_name );

  /* Fetch the records of all the agent groups belonging to the group */
  /* l_default_group_id and insert them in the table bix_dm_bin       */
  INSERT /*+ PARALLEL(tb,2) */ INTO bix_dm_bin tb (
		session_id
	   , bin_code
        , col1
        , col2
	   , col4
	   , col6
	   , col8 )
  ( SELECT  /*+ PARALLEL(bgc,2) */
	   l_session_id
	 , 'BIX_CALLS_HANDLED_BIN'
      , 'p' || to_char(grp.group_id)
      , grp.group_name
	 , SUM(bgc.in_calls_handled)
      , SUM(bgc.out_calls_handled)
      , bix_util_pkg.get_hrmiss_frmt(trunc(SUM(bgc.in_talk_time + bgc.out_talk_time + bgc.in_wrap_time +
				    bgc.out_wrap_time) / DECODE(SUM(bgc.in_calls_handled + bgc.out_calls_handled), 0, 1,
					  SUM(bgc.in_calls_handled + bgc.out_calls_handled))))
    FROM
	   bix_dm_group_call_sum bgc
      , jtf_rs_groups_denorm dnm
      , jtf_rs_groups_vl grp
    WHERE dnm.parent_group_id       = l_default_group_id
    AND   dnm.immediate_parent_flag = 'Y'
    AND   dnm.group_id              = grp.group_id
    AND   dnm.group_id              = bgc.group_id
    AND   bgc.period_start_date     = l_reporting_date
    GROUP BY grp.group_name
		 , grp.group_id );

  commit;

EXCEPTION
    WHEN OTHERS
    THEN RAISE;
END populate;

END BIX_CALLS_HANDLED_BIN_PKG;

/

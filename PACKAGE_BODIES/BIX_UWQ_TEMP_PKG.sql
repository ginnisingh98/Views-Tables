--------------------------------------------------------
--  DDL for Package Body BIX_UWQ_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_UWQ_TEMP_PKG" AS
/*$Header: bixxuwtb.pls 115.15 2003/01/10 00:14:13 achanda ship $ */

v_date DATE;
v_default_group_id      INTEGER;
v_context VARCHAR2(1000);  -- this is used to store the value that is passed from bin or report drill down
v_session_id NUMBER ;      -- this is used to insert the session id

PROCEDURE get_param_values(p_context IN VARCHAR2)
--
--This procedure gets the parameter values.
--It also assigns v_context which is the value passed from id column in the drill down.
--It also assigns v_date, which will be equal to the parameter value when the parameter
--is keyed in, or will be equal to the value stored in the id column when drilling down,
--or will be null if neither paramter is keyed in nor is drill down been performed
--
IS

BEGIN

  --
  --Get the value of p_context passed in to the procedure. Store this in v_context.
  --If v_context is not null, it will have the group/agent id + date in v_context.
  --v_date stores the parameter that the user types in while running the report.
  --

  v_context := bix_util_pkg.get_parameter_value(p_context, 'pContext');

  --
  --Note, when using calendar picker from JTF, parameter is being passed in as
  --ICX_DATE_FORMAT_MASK.  This is being used directly in the to_date function
  --below to convert the string to a date
  --

  v_date    := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'STARTDATE'),
					FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK'));

  --
  --Due to a JTF bug, old pcontext is always being passed in.
  --This will cause problems when running from listing pages.
  --To avoid this, if pcontext is equal to the region code
  --then make this value null.
  --
  IF v_context = 'BIX_UWQ_LOGINS_RPT'
  OR v_context = 'BIX_UWQ_DURATIONS_RPT'
  THEN
	v_context := NULL;
  END IF;

  IF v_date IS NULL AND p_context IS NOT NULL
  --
  --This could be because the report is run by clicking on the UWQ bin OR
  --the user did not key in a date value in the parameter field while running the report.
  --If the report is run from the bin, we will pick this up from the p_context value as
  --passed from the bin. If the report was not run from the bin and v_date is still null, then
  --we will not return any data. The bin passes the date in DD-MON-YYYY format.
  --
  THEN

	/* to get rid of gscc error , v_date was assigned null as it is an obsoleted package */
     v_date := to_date(null);   /* (substr(v_context,2,11),'DD-MON-YYYY'); */

  END IF;

  IF v_context IS NULL
  --
  --Means it was not run from the bin
  --
  THEN
  BEGIN
   select fnd_profile.value('BIX_DM_DEFAULT_GROUP')
   into   v_default_group_id
   from dual;

   EXCEPTION
   WHEN OTHERS
   THEN
      --This means the default group id is null.
      --We will pick up the group to which the resource was most
      --recently associated with.

      BEGIN

      select grp.group_id
      into   v_default_group_id
      from   jtf_rs_group_members grp, jtf_rs_resource_extns res
      where  res.resource_id = grp.resource_id
      and    res.user_id = fnd_profile.value('USER_ID')
      and    grp.last_update_date = (select max(grp2.last_update_date)
                                     from jtf_rs_group_members grp2, jtf_rs_resource_extns res2
                                     where  res2.resource_id = grp2.resource_id
                                     and    res2.user_id = fnd_profile.value('USER_ID')
                                     );
      EXCEPTION
      WHEN OTHERS
      THEN
         v_default_group_id := NULL;

      END;

   END;

   END IF;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   NULL;
WHEN OTHERS THEN
   RAISE;

END get_param_values;

PROCEDURE POPULATE_BIN (p_context IN VARCHAR2 DEFAULT NULL)
--
--This procedure populates the BIX_DM_BIN table for the UWQ Activity bin.
--
IS

v_max_date              DATE;

--
--This cursor will fetch the immediate child groups of the agent's default group.
--These are the groups which will be displayed in the bin.  If the default value
--is null, it will pick up the most recent group.  If that also returns null, it is
--set to null.
--

CURSOR c_child_groups(p_group_id INTEGER)
IS
select denorm.group_id GID
from   jtf_rs_groups_denorm denorm
where  denorm.parent_group_id = p_group_id
and    denorm.immediate_parent_flag = 'Y';

--
--This cursor will fetch the agents directly associated with the agent's default group.
--These agents will be displayed directly in the bin.  We dont check for default group
--for these agents.
--

CURSOR c_child_agents(p_group_id INTEGER)
IS
SELECT DISTINCT res.resource_id RID, res.source_name RNAME
FROM   jtf_rs_group_members grp, jtf_rs_resource_extns res
WHERE  grp.group_id = p_group_id
AND    grp.resource_id = res.resource_id;

BEGIN

v_session_id := NULL;
v_session_id := icx_sec.g_session_id; -- this is used to insert the session id

delete from bix_dm_bin
where bin_code = 'BIX_UWQ_ACTIVITY_BIN'
and session_id = v_session_id;

commit;

select max(day)-1
into   v_max_date
from   bix_dm_uwq_agent_sum;

--
--Select the user who is logged in and the user's default group
--

   BEGIN

   select fnd_profile.value('BIX_DM_DEFAULT_GROUP')
   into   v_default_group_id
   from dual;

   EXCEPTION
   WHEN OTHERS
   THEN
      --This means the default group id is null.
      --We will pick up the group to which the resource was most
      --recently associated with.

      BEGIN

      select grp.group_id
      into   v_default_group_id
      from   jtf_rs_group_members grp, jtf_rs_resource_extns res
      where  res.resource_id = grp.resource_id
      and    res.user_id = fnd_profile.value('USER_ID')
      and    grp.last_update_date = (select max(grp2.last_update_date)
                                     from jtf_rs_group_members grp2, jtf_rs_resource_extns res2
                                     where  res.resource_id = grp.resource_id
                                     and    res.user_id = fnd_profile.value('USER_ID')
                                     );
      EXCEPTION
      WHEN OTHERS
      THEN
         v_default_group_id := NULL;

      END;

   END;

--
--Now we have the agent's default group. Open the child agents cursor
--loop through and calculate the measures.  Then insert these into the temp
--table.

FOR rec_child_agents IN c_child_agents(v_default_group_id)
LOOP

   --
   --Now we have one resource id.  Find the login and duration information for this agent.
   --

   INSERT INTO bix_dm_bin (bin_code, col2, col3, col4, col5, col6, session_id)
   SELECT 'BIX_UWQ_ACTIVITY_BIN',
           rec_child_agents.RNAME,
          'A'||to_char(v_max_date,'DD-MON-YYYY')||rec_child_agents.RID,
           DAY_LOGIN,
          'A'||to_char(v_max_date,'DD-MON-YYYY')||rec_child_agents.RID,
          bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN)) ),
		v_session_id
   FROM   bix_dm_uwq_agent_sum summ
   WHERE  summ.resource_id = rec_child_agents.RID
   AND    summ.DAY         = trunc(v_max_date);


END LOOP;

--
--Now open the child agents cursor.  Loop through every group.  Find all the sub groups
--for every group.  Find the agents at each of these sub-groups.  Add up the measures
--for all agents.  Then insert the measures into the temp table.
--

FOR rec_child_groups IN c_child_groups(v_default_group_id)
LOOP

   INSERT INTO bix_dm_bin (bin_code, col2, col3, col4, col5, col6, session_id)
   SELECT 'BIX_UWQ_ACTIVITY_BIN',
          vl.group_name,
          'G'||to_char(v_max_date,'DD-MON-YYYY')||rec_child_groups.GID,
          DAY_LOGIN,
          'G'||to_char(v_max_date,'DD-MON-YYYY')||rec_child_groups.GID,
          bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN)) ),
		v_session_id
   FROM   bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE  summ.group_id      = rec_child_groups.GID
   AND    summ.group_id      = vl.group_id
   AND    summ.day           = trunc(v_max_date);

END LOOP;

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   NULL;
WHEN OTHERS
THEN
   RAISE;

END POPULATE_BIN;

PROCEDURE POPULATE_LOGINS_REPORT(p_context IN VARCHAR2 DEFAULT NULL)
--
--This procedure populates the BIX_DM_REPORT table for the UWQ logins report.
--
IS

BEGIN

v_session_id := NULL;
v_session_id := icx_sec.g_session_id; -- this is used to insert the session id

--
--Delete the records from the previous run of the report.
--
delete from bix_dm_report
where report_code = 'BIX_UWQ_LOGINS_RPT'
and session_id = v_session_id;

commit;

get_param_values(p_context);

IF UPPER(substr(v_context,1,1)) = 'A'
THEN

   --
   --Display only that agent's information.  There will be no further drill downs.
   --

   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', res.source_name, '',
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id = substr(v_context,13)
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;

ELSIF UPPER(substr(v_context,1,1)) = 'G'
THEN

   --
   --Total row
   --
   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', vl.group_name, '',
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id = substr(v_context,13)
   AND     summ.group_id = vl.group_id
   AND     summ.day         = v_date;

   --
   --Sub group details for immediate child groups of the default group.
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', '', 'G'||to_char(v_date,'DD-MON-YYYY')||summ.group_id, vl.group_name,
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id IN
                           (select denorm.group_id GID
                            from   jtf_rs_groups_denorm denorm
                            where  denorm.parent_group_id = substr(v_context,13)
                            and    denorm.immediate_parent_flag = 'Y'
                            )
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Agents directly associated with the group
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', '', 'A'||to_char(v_date,'DD-MON-YYYY')||summ.resource_id, res.source_name,
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id  IN
						   (
                                 SELECT DISTINCT res.resource_id
                                 FROM   jtf_rs_group_members grp, jtf_rs_resource_extns res
                                 WHERE  grp.group_id = substr(v_context,13)
                                 AND    grp.resource_id = res.resource_id
						    )
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;

ELSIF v_context IS NULL
THEN

   --
   --This means the report is not being run from the bin.  It is being run directly
   --from the reports page.  In this case, check for the date parameter for the default group.
   --

   --
   --Total row
   --
   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', vl.group_name, '',
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id    = v_default_group_id
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Sub group details for immediate child groups of the default group.
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', '', 'G'||to_char(v_date,'DD-MON-YYYY')||summ.group_id, vl.group_name,
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id IN
                           (select denorm.group_id GID
                            from   jtf_rs_groups_denorm denorm
                            where  denorm.parent_group_id = v_default_group_id
                            and    denorm.immediate_parent_flag = 'Y'
                            )
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Agents directly associated with the default group
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_LOGINS_RPT', '', 'A'||to_char(v_date,'DD-MON-YYYY')||summ.resource_id, res.source_name,
           DAY6_LOGIN, DAY5_LOGIN, DAY4_LOGIN, DAY3_LOGIN, DAY2_LOGIN, DAY1_LOGIN,
           DAY_LOGIN, PRIOR_WEEK_LOGIN, CURRENT_WEEK_LOGIN, PRIOR_MONTH_LOGIN, CURRENT_MONTH_LOGIN,
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id  IN
						   (
                                 SELECT DISTINCT res.resource_id
                                 FROM   jtf_rs_group_members grp, jtf_rs_resource_extns res
                                 WHERE  grp.group_id = v_default_group_id
                                 AND    grp.resource_id = res.resource_id
						    )
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;

END IF;

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   NULL;
WHEN OTHERS
THEN
   RAISE;

END populate_logins_report;

PROCEDURE POPULATE_DURATIONS_REPORT(p_context IN VARCHAR2 DEFAULT NULL)
--
--This procedure populates the BIX_DM_REPORT table for the UWQ durations report.
--
IS

BEGIN

v_session_id := NULL;
v_session_id := icx_sec.g_session_id; -- this is used to insert the session id

--
--Delete old rows from the previous run of the report.
--
delete from bix_dm_report
where report_code = 'BIX_UWQ_DURATIONS_RPT'
and session_id = v_session_id;

commit;

get_param_values(p_context);

IF UPPER(substr(v_context,1,1)) = 'A'
THEN

   --
   --Display only that agent's information.  There will be no further drill downs.
   --
   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', res.source_name, '',
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id = substr(v_context,13)
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;


ELSIF UPPER(substr(v_context,1,1)) = 'G'
THEN

   --
   --Total row
   --
   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', vl.group_name, '',
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id    = substr(v_context,13)
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Sub groups
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', '', 'G'||to_char(v_date,'DD-MON-YYYY')||summ.group_id, vl.group_name,
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id IN
                           (select denorm.group_id GID
                            from   jtf_rs_groups_denorm denorm
                            where  denorm.parent_group_id = substr(v_context,13)
                            and    denorm.immediate_parent_flag = 'Y'
                            )
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Agents directly associated with the group
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', '', 'A'||to_char(v_date,'DD-MON-YYYY')||summ.resource_id, res.source_name,
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id  IN
						   (
                                 SELECT DISTINCT res.resource_id
                                 FROM   jtf_rs_group_members grp, jtf_rs_resource_extns res
                                 WHERE  grp.group_id = substr(v_context,13)
                                 AND    grp.resource_id = res.resource_id
						    )
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;


ELSIF v_context IS NULL
THEN
   --
   --This means the report is not being run from the bin.  It is being run directly
   --from the reports page.  In this case, check for the date parameter for the default group.
   --

   --
   --Total row
   --
   INSERT INTO bix_dm_report (report_code, col2, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', vl.group_name, '',
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id    = v_default_group_id
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Sub groups
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', '', 'G'||to_char(v_date,'DD-MON-YYYY')||summ.group_id, vl.group_name,
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_group_sum summ, jtf_rs_groups_vl vl
   WHERE   summ.group_id IN
                           (select denorm.group_id GID
                            from   jtf_rs_groups_denorm denorm
                            where  denorm.parent_group_id = v_default_group_id
                            and    denorm.immediate_parent_flag = 'Y'
                            )
   AND     summ.group_id    = vl.group_id
   AND     summ.day         = v_date;

   --
   --Agents directly associated with default group.
   --
   INSERT INTO bix_dm_report (report_code, col2, col3, col4,
                                 col6, col8, col10, col12, col14, col16,
                                 col18, col20, col22, col24, col26, session_id)
   SELECT 'BIX_UWQ_DURATIONS_RPT', '', 'A'||to_char(v_date,'DD-MON-YYYY')||summ.resource_id, res.source_name,
           bix_util_pkg.get_hrmi_frmt( decode(DAY6_LOGIN,0,0,round(DAY6_DURATION/DAY6_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY5_LOGIN,0,0,round(DAY5_DURATION/DAY5_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY4_LOGIN,0,0,round(DAY4_DURATION/DAY4_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY3_LOGIN,0,0,round(DAY3_DURATION/DAY3_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY2_LOGIN,0,0,round(DAY2_DURATION/DAY2_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY1_LOGIN,0,0,round(DAY1_DURATION/DAY1_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(DAY_LOGIN,0,0,round(DAY_DURATION/DAY_LOGIN))   ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_WEEK_LOGIN,0,0,round(PRIOR_WEEK_DURATION/PRIOR_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_WEEK_LOGIN,0,0,round(CURRENT_WEEK_DURATION/CURRENT_WEEK_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(PRIOR_MONTH_LOGIN,0,0,round(PRIOR_MONTH_DURATION/PRIOR_MONTH_LOGIN)) ),
           bix_util_pkg.get_hrmi_frmt( decode(CURRENT_MONTH_LOGIN,0,0,round(CURRENT_MONTH_DURATION/CURRENT_MONTH_LOGIN)) ),
		 v_session_id
   FROM    bix_dm_uwq_agent_sum summ, jtf_rs_resource_extns res
   WHERE   summ.resource_id  IN
						   (
                                 SELECT DISTINCT res.resource_id
                                 FROM   jtf_rs_group_members grp, jtf_rs_resource_extns res
                                 WHERE  grp.group_id = v_default_group_id
                                 AND    grp.resource_id = res.resource_id
						    )
   AND     summ.resource_id = res.resource_id
   AND     summ.day         = v_date;

END IF;

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   NULL;
WHEN OTHERS
THEN
   RAISE;

END populate_durations_report;


END BIX_UWQ_TEMP_PKG;

/

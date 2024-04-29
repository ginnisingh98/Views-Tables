--------------------------------------------------------
--  DDL for Package Body PJI_AUDIT_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_AUDIT_RPT" AS
  /* $Header: PJIUT05B.pls 115.6 2003/12/19 03:31:08 svermett noship $ */

g_cnt_set_up_err NUMBER := 0;

/*
This API checks for all the business intelligence
set up parameters that are needed for running
project intelligence application.
*/
PROCEDURE CHK_BIS_SET_UP
IS
l_period_set_name    	VARCHAR2(15) := NULL;
l_global_st_date    	DATE := NULL;
l_period_type    	VARCHAR2(15) := NULL;
l_currency_code    	VARCHAR2(15) := NULL;
l_rate_type	    	VARCHAR2(30) := NULL;
l_start_dt_of_week    	VARCHAR2(30) := NULL;

l_period_set_name_tkn 	VARCHAR2(50);
l_global_st_date_tkn  	VARCHAR2(50);
l_period_type_tkn    	VARCHAR2(50);
l_currency_code_tkn    	VARCHAR2(50);
l_rate_type_tkn	    	VARCHAR2(50);
l_start_dt_of_week_tkn 	VARCHAR2(50);

l_cnt_set_up_err	NUMBER	     := 0;
l_bis_param_name_tbl	V_TYPE_TAB;
l_no_of_bis_params	NUMBER	     := 6;

l_all_msg_text		VARCHAR2(200);
l_param_msg		VARCHAR2(30);
l_param_msg_text	VARCHAR2(400):='';
l_bis_msg_text		VARCHAR2(200);
l_newline       varchar2(10) := '
';

BEGIN

SELECT BIS_COMMON_PARAMETERS.GET_PERIOD_SET_NAME
INTO l_period_set_name
FROM dual;

SELECT PJI_UTILS.GET_EXTRACTION_START_DATE
INTO l_global_st_date
FROM dual;

SELECT BIS_COMMON_PARAMETERS.GET_PERIOD_TYPE
INTO l_period_type
FROM dual;

SELECT BIS_COMMON_PARAMETERS.GET_CURRENCY_CODE
INTO l_currency_code
FROM dual;

SELECT BIS_COMMON_PARAMETERS.GET_RATE_TYPE
INTO l_rate_type
FROM dual;

SELECT BIS_COMMON_PARAMETERS.GET_START_DAY_OF_WEEK_ID
INTO l_start_dt_of_week
FROM dual;

l_bis_param_name_tbl := V_TYPE_TAB();
l_bis_param_name_tbl.DELETE;

IF l_period_set_name IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_period_set_name_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_ENT_CAL';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_period_set_name_tkn;
END IF;

IF l_global_st_date IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_global_st_date_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_GLO_ST_DT';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_global_st_date_tkn;
END IF;

IF l_period_type IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_period_type_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_PD_TYPE';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_period_type_tkn;
END IF;

IF l_currency_code IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_currency_code_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_PR_CURR';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_currency_code_tkn;
END IF;

IF l_rate_type IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_rate_type_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_PR_RATE';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_rate_type_tkn;
END IF;

IF l_start_dt_of_week IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_start_dt_of_week_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_BIS_PARAMS'
	and lookup_code = 'BIS_ST_DT_WK';

	l_bis_param_name_tbl.EXTEND;
	l_bis_param_name_tbl(l_bis_param_name_tbl.COUNT) := l_start_dt_of_week_tkn;
END IF;

IF (l_cnt_set_up_err > 0) THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_ALL_PARAM_TEXT')
	INTO l_all_msg_text
	FROM dual;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PARAM_NAME')
	INTO l_param_msg
	FROM dual;

	FOR i in l_bis_param_name_tbl.FIRST.. l_bis_param_name_tbl.LAST
	LOOP
		l_param_msg_text := l_param_msg_text || l_param_msg || ' ' || l_bis_param_name_tbl(i) || l_newline;
	END LOOP;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_BIS_PARAM_TEXT')
	INTO l_bis_msg_text
	FROM dual;

	pji_utils.write2out(l_all_msg_text || l_newline || l_param_msg_text || l_bis_msg_text || l_newline);

END IF;

g_cnt_set_up_err := g_cnt_set_up_err + l_cnt_set_up_err;

END CHK_BIS_SET_UP;

/*
This API checks for all the project intelligence
set up parameters that are needed for running
project intelligence application.
*/
PROCEDURE CHK_PJI_SET_UP
IS
l_org_structure_id 	NUMBER:= NULL;
l_org_structure_ver_id 	NUMBER:= NULL;

l_org_structure_id_tkn 	VARCHAR2(50);
l_org_structure_ver_tkn VARCHAR2(50);

l_cnt_set_up_err	NUMBER	     := 0;
l_pji_param_name_tbl	V_TYPE_TAB;

l_all_msg_text		VARCHAR2(200);
l_param_msg		VARCHAR2(30);
l_param_msg_text	VARCHAR2(400):='';
l_pji_msg_text		VARCHAR2(200);
l_newline       varchar2(10) := '
';

BEGIN

SELECT  organization_structure_id,
	org_structure_version_id
INTO    l_org_structure_id,
	l_org_structure_ver_id
FROM    pji_system_settings;

l_pji_param_name_tbl := V_TYPE_TAB();
l_pji_param_name_tbl.DELETE;

IF l_org_structure_id IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_org_structure_id_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_PJI_SET_PARAMS'
	and lookup_code = 'ORG_STRUC';

	l_pji_param_name_tbl.EXTEND;
	l_pji_param_name_tbl(l_pji_param_name_tbl.COUNT) := l_org_structure_id_tkn;
END IF;

IF l_org_structure_ver_id IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_org_structure_ver_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_PJI_SET_PARAMS'
	and lookup_code = 'ORG_ST_VER';

	l_pji_param_name_tbl.EXTEND;
	l_pji_param_name_tbl(l_pji_param_name_tbl.COUNT) := l_org_structure_ver_tkn;
END IF;

IF (l_cnt_set_up_err > 0) THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_ALL_PARAM_TEXT')
	INTO l_all_msg_text
	FROM dual;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PARAM_NAME')
	INTO l_param_msg
	FROM dual;

	FOR i in l_pji_param_name_tbl.FIRST.. l_pji_param_name_tbl.LAST
	LOOP
		l_param_msg_text := l_param_msg_text || l_param_msg || ' ' || l_pji_param_name_tbl(i) || l_newline;
	END LOOP;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJI_PARAM_TEXT')
	INTO l_pji_msg_text
	FROM dual;

	pji_utils.write2out(l_newline || l_all_msg_text || l_newline || l_param_msg_text || l_pji_msg_text || l_newline);

END IF;

g_cnt_set_up_err := g_cnt_set_up_err + l_cnt_set_up_err;

END CHK_PJI_SET_UP;

/*
This API checks for all the organization and
time/calendar dimensions that are needed for
running project intelligence application.
*/
PROCEDURE CHK_ORG_TIME_CAL_DIM
IS
l_time_cal_dim 	NUMBER:= NULL;
l_org_dim 	NUMBER:= NULL;

l_cnt_set_up_err	NUMBER	     := 0;
l_time_cal_msg_text	VARCHAR2(200);
l_org_msg_text		VARCHAR2(200);
l_dim_msg_text		VARCHAR2(600):='';
l_newline       	varchar2(10) := '
';

BEGIN

BEGIN
SELECT 1
INTO l_time_cal_dim
FROM dual
WHERE EXISTS (
		SELECT 1
		FROM fii_time_day
	     );
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_time_cal_dim := null;
		l_cnt_set_up_err := l_cnt_set_up_err + 1;
END;

BEGIN
SELECT 1
INTO l_org_dim
FROM dual
WHERE EXISTS (
		SELECT 1
		FROM hri_org_hrchy_summary
	     );
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_org_dim := null;
		l_cnt_set_up_err := l_cnt_set_up_err + 1;
END;

IF l_time_cal_dim IS NULL THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_TIME_CAL_DIMENSION')
	INTO l_time_cal_msg_text
	FROM dual;

	l_dim_msg_text := l_dim_msg_text|| l_time_cal_msg_text || l_newline;
END IF;

IF l_org_dim IS NULL THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_ORG_DIMENSION')
	INTO l_org_msg_text
	FROM dual;

	l_dim_msg_text := l_dim_msg_text|| l_newline || l_org_msg_text || l_newline;
END IF;

pji_utils.write2out(l_newline || l_dim_msg_text || l_newline);

g_cnt_set_up_err := g_cnt_set_up_err + l_cnt_set_up_err;

END CHK_ORG_TIME_CAL_DIM;


/*
This API checks for organizations that have transactions but are not
reporesented in the PJI hierarchy.  Call these organizations "orphan"
organizations.

If PJI summarization has not been run, check against the source.  We get a
superset approximation of orphan organizations because getting the exact list
from the transaction tables would be too expensive.

If PJI summarization has been run, check against PJI facts.  This gives us
the exact list of orphan organizations.
*/
procedure CHK_PJI_ORG_HRCHY is

  cursor orphan_organizations
  (
    p_org_structure_version_id in number,
    p_settings_cost_flag       in varchar2,
    p_settings_profit_flag     in varchar2,
    p_settings_util_flag       in varchar2,
    p_params_cost_flag         in varchar2,
    p_params_profit_flag       in varchar2,
    p_params_util_flag         in varchar2
  ) is
  select /*+ full(org) parallel(org) use_hash(org)
             full(all_org) parallel(all_org) use_hash(all_org) */
    all_org.NAME ORGANIZATION_NAME
  from
    (
    select
      org.ORGANIZATION_ID
    from
      (
      select -- Resource Management
        org.ORGANIZATION_ID
      from
        (
        select /*+ index_ffs(org, PA_ALL_ORGANIZATIONS_U1)
                   parallel_index(org, PA_ALL_ORGANIZATIONS_U1) */
          distinct
          org.ORGANIZATION_ID
        from
          PA_ALL_ORGANIZATIONS org
        where
          p_settings_util_flag = 'Y' and
          p_params_util_flag = 'N'
        ) org
      where
        p_settings_util_flag = 'Y' and
        p_params_util_flag = 'N' and
        exists (select /*+ index_ffs(fid, PA_FORECAST_ITEM_DETAILS_N2)
                           parallel_index(fid, PA_FORECAST_ITEM_DETAILS_N2) */
                       1
                from   PA_FORECAST_ITEM_DETAILS fid
                where  fid.EXPENDITURE_ORGANIZATION_ID > 0 and
                       fid.EXPENDITURE_ORGANIZATION_ID = org.ORGANIZATION_ID)
      union -- Financial Management
      select /*+ ordered
                 use_hash(psc) swap_join_inputs(psc)
                 parallel(prj) use_hash(prj) */
        distinct
        prj.ORGANIZATION_ID
      from
        (
        select /*+ no_merge(prj) */
          prj.PROJECT_STATUS_CODE
        from
          (
          select /*+ index_ffs(prj, PA_PROJECTS_N4)
                     parallel_index(prj, PA_PROJECTS_N4) */
            distinct
            prj.PROJECT_STATUS_CODE
          from
            PA_PROJECTS_ALL prj
          where
            ((p_settings_cost_flag = 'Y' and
              p_params_cost_flag = 'N') or
             (p_settings_profit_flag = 'Y' and
              p_params_profit_flag = 'N'))
          ) prj
        where
          ((p_settings_cost_flag = 'Y' and
            p_params_cost_flag = 'N') or
           (p_settings_profit_flag = 'Y' and
            p_params_profit_flag = 'N')) and
          PA_PROJECT_UTILS.CHECK_PRJ_STUS_ACTION_ALLOWED
            (prj.PROJECT_STATUS_CODE, 'STATUS_REPORTING') = 'Y'
        ) psc,
        (
        select /*+ index_ffs(prj, PA_PROJECTS_N2)
                   parallel_index(prj, PA_PROJECTS_N2) */
          distinct
          prj.CARRYING_OUT_ORGANIZATION_ID ORGANIZATION_ID,
          prj.PROJECT_STATUS_CODE
        from
          PA_PROJECTS_ALL prj
        where
          ((p_settings_cost_flag = 'Y' and
            p_params_cost_flag = 'N') or
           (p_settings_profit_flag = 'Y' and
            p_params_profit_flag = 'N'))
        --  disregarding CLOSED_DATE massively improves performance
        --  nvl(closed_date,to_date('01-JAN-1997')) >= to_date('01-JAN-1997')
        ) prj
      where
        ((p_settings_cost_flag = 'Y' and
          p_params_cost_flag = 'N') or
         (p_settings_profit_flag = 'Y' and
          p_params_profit_flag = 'N')) and
        psc.project_status_code = prj.project_status_code
      ) org,
      (
      select /*+ index_ffs(hrchy, HRI_ORG_HRCHY_SUMMARY_N1)
                 parallel_index(hrchy, HRI_ORG_HRCHY_SUMMARY_N1) */
        distinct
        hrchy.ORGANIZATION_ID
      from
        HRI_ORG_HRCHY_SUMMARY hrchy
      where
        ((p_settings_cost_flag = 'Y' and
          p_params_cost_flag = 'N') or
         (p_settings_profit_flag = 'Y' and
          p_params_profit_flag = 'N') or
         (p_settings_util_flag = 'Y' and
          p_params_util_flag = 'N')) and
        hrchy.ORG_STRUCTURE_VERSION_ID = p_org_structure_version_id
      ) hrchy
    where
      ((p_settings_cost_flag = 'Y' and
        p_params_cost_flag = 'N') or
       (p_settings_profit_flag = 'Y' and
        p_params_profit_flag = 'N') or
       (p_settings_util_flag = 'Y' and
        p_params_util_flag = 'N')) and
      org.ORGANIZATION_ID = hrchy.ORGANIZATION_ID (+) and
      hrchy.ORGANIZATION_ID is null
    union
    select /*+ full(org) parallel(org) use_hash(org)
               full(denorm) parallel(denorm) use_hash(denorm) */
      org.ORGANIZATION_ID
    from
      (
      select /*+ parallel(org) */
        distinct
        org.ORGANIZATION_ID
      from
        (
        select /*+ index_ffs(rmr, PJI_RM_RES_WT_F_N1)
                   parallel_index(rmr, PJI_RM_RES_WT_F_N1) */
          rmr.EXPENDITURE_ORGANIZATION_ID ORGANIZATION_ID
        from
          PJI_RM_RES_WT_F rmr
        where
          p_params_util_flag = 'Y'
        union all
        select /*+ index_ffs(fpp, PJI_FP_PROJ_F_N1)
                   parallel_index(fpp, PJI_FP_PROJ_F_N1) */
          fpp.PROJECT_ORGANIZATION_ID ORGANIZATION_ID
        from
          PJI_FP_PROJ_F fpp
        where
          p_params_cost_flag = 'Y' and
          fpp.CALENDAR_TYPE = 'C'
        union all
        select /*+ index_ffs(acp, PJI_AC_PROJ_F_N1)
                   parallel_index(acp, PJI_AC_PROJ_F_N1) */
          acp.PROJECT_ORGANIZATION_ID ORGANIZATION_ID
        from
          PJI_AC_PROJ_F acp
        where
          p_params_profit_flag = 'Y' and
          acp.CALENDAR_TYPE = 'C'
        )org
      ) org,
      (
        select /*+ index_ffs(denorm, PJI_ORG_DENORM_N1)
                   parallel_index(denorm, PJI_ORG_DENORM_N1) */
          distinct
          denorm.ORGANIZATION_ID
        from
          PJI_ORG_DENORM denorm
        where
          (p_params_cost_flag = 'Y' or
           p_params_profit_flag = 'Y' or
           p_params_util_flag = 'Y')
      ) denorm
    where
      (p_params_cost_flag = 'Y' or
       p_params_profit_flag = 'Y' or
       p_params_util_flag = 'Y') and
      org.ORGANIZATION_ID = denorm.ORGANIZATION_ID (+) and
      denorm.ORGANIZATION_ID is null
    ) org,
    HR_ALL_ORGANIZATION_UNITS all_org
  where
    org.ORGANIZATION_ID = all_org.ORGANIZATION_ID
  order by all_org.NAME;

  l_cnt_set_up_err           number;
  l_org_structure_version_id number;

  l_settings_proj_perf_flag  varchar2(1);
  l_settings_cost_flag       varchar2(1);
  l_settings_profit_flag     varchar2(1);
  l_settings_util_flag       varchar2(1);

  l_params_proj_perf_flag    varchar2(1);
  l_params_cost_flag         varchar2(1);
  l_params_profit_flag       varchar2(1);
  l_params_util_flag         varchar2(1);

  l_header_flag              varchar2(1);
  l_newline                  varchar2(1) := '
';

begin

  select ORG_STRUCTURE_VERSION_ID
  into   l_org_structure_version_id
  from   PJI_SYSTEM_SETTINGS;

  select
    nvl(CONFIG_PROJ_PERF_FLAG, 'N'),
    nvl(CONFIG_COST_FLAG, 'N'),
    nvl(CONFIG_PROFIT_FLAG, 'N'),
    nvl(CONFIG_UTIL_FLAG, 'N')
  into
    l_settings_proj_perf_flag,
    l_settings_cost_flag,
    l_settings_profit_flag,
    l_settings_util_flag
  from
    PJI_SYSTEM_SETTINGS;

  l_params_proj_perf_flag :=
                  nvl(PJI_UTILS.GET_PARAMETER('CONFIG_PROJ_PERF_FLAG'), 'N');
  l_params_cost_flag :=
                  nvl(PJI_UTILS.GET_PARAMETER('CONFIG_COST_FLAG'), 'N');
  l_params_profit_flag :=
                  nvl(PJI_UTILS.GET_PARAMETER('CONFIG_PROFIT_FLAG'), 'N');
  l_params_util_flag :=
                  nvl(PJI_UTILS.GET_PARAMETER('CONFIG_UTIL_FLAG'), 'N');

  if (l_settings_cost_flag   = 'N' and
      l_settings_profit_flag = 'N' and
      l_settings_util_flag   = 'N' and
      l_params_cost_flag     = 'N' and
      l_params_profit_flag   = 'N' and
      l_params_util_flag     = 'N') then
    return;
  end if;

  l_header_flag := 'Y';
  l_cnt_set_up_err := 0;

  for c in orphan_organizations(l_org_structure_version_id,
                                l_settings_cost_flag,
                                l_settings_profit_flag,
                                l_settings_util_flag,
                                l_params_cost_flag,
                                l_params_profit_flag,
                                l_params_util_flag) loop

    if (l_header_flag = 'Y') then

      l_header_flag := 'N';

      fnd_message.set_name('PJI', 'PJI_ORPHAN_ORGANIZATIONS');
      pji_utils.write2out(fnd_message.get || l_newline);

      l_cnt_set_up_err := l_cnt_set_up_err + 1;

    end if;

    pji_utils.write2out(c.ORGANIZATION_NAME || l_newline);

  end loop;

  if (l_header_flag = 'N') then
    pji_utils.write2out(l_newline);
  end if;

  g_cnt_set_up_err := g_cnt_set_up_err + l_cnt_set_up_err;

end CHK_PJI_ORG_HRCHY;


/*
This API checks for all the project intelligence
security set up parameters that are needed for
running project intelligence application.
*/

PROCEDURE CHK_SECURITY_SET_UP
	(p_username	IN VARCHAR2)
IS
l_pji_security_prof 	NUMBER:= NULL;
l_mo_security_prof 	NUMBER:= NULL;

l_pji_security_prof_tkn VARCHAR2(50);
l_mo_security_prof_tkn  VARCHAR2(50);

l_org_view_all_flag	VARCHAR2(1);
l_org_view_all_org_flag	VARCHAR2(1);

l_ou_view_all_flag	VARCHAR2(1);
l_ou_view_all_org_flag	VARCHAR2(1);

l_org_all_access_msg_text VARCHAR2(200);
l_org_par_access_msg_text VARCHAR2(200);

l_ou_all_access_msg_text VARCHAR2(200);
l_ou_par_access_msg_text VARCHAR2(200);

l_cnt_set_up_err	NUMBER	     := 0;
l_sec_prof_param_name_tbl V_TYPE_TAB;

l_org_name_tbl		V_TYPE_TAB;
l_ou_name_tbl		V_TYPE_TAB;

l_prof_not_set_msg_text	VARCHAR2(200);
l_param_msg		VARCHAR2(100) :='';
l_prof_err_msg_text	VARCHAR2(400):='';
l_no_access_msg_text	VARCHAR2(200);
l_newline       varchar2(10) := '
';

BEGIN

SELECT fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL')
INTO l_pji_security_prof
FROM dual;

SELECT fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL')
INTO l_mo_security_prof
FROM dual;

l_sec_prof_param_name_tbl := V_TYPE_TAB();
l_sec_prof_param_name_tbl.DELETE;

IF l_pji_security_prof IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_pji_security_prof_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_SECURITY_PARAMS'
	and lookup_code = 'PJI_ORG_PROF';

	l_sec_prof_param_name_tbl.EXTEND;
	l_sec_prof_param_name_tbl(l_sec_prof_param_name_tbl.COUNT) := l_pji_security_prof_tkn;
END IF;

IF l_mo_security_prof IS NULL THEN
	l_cnt_set_up_err := l_cnt_set_up_err + 1;

	SELECT meaning
	INTO l_mo_security_prof_tkn
	FROM pji_lookups
	WHERE lookup_type = 'PJI_CHK_SECURITY_PARAMS'
	and lookup_code = 'PJI_MO_PROF';

	l_sec_prof_param_name_tbl.EXTEND;
	l_sec_prof_param_name_tbl(l_sec_prof_param_name_tbl.COUNT) := l_mo_security_prof_tkn;
END IF;

IF (l_cnt_set_up_err > 0) THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_NOT_SET')
	INTO l_prof_not_set_msg_text
	FROM dual;

	FOR i in l_sec_prof_param_name_tbl.FIRST.. l_sec_prof_param_name_tbl.LAST
	LOOP
		l_param_msg := l_param_msg || l_sec_prof_param_name_tbl(i) || l_newline;
	END LOOP;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_NO_ACCESS')
	INTO l_no_access_msg_text
	FROM dual;

	pji_utils.write2out(l_newline || l_prof_not_set_msg_text || l_newline || l_param_msg || l_no_access_msg_text || l_newline);

	RETURN;

END IF;

/*
If both the security profiles are set then the program
would come here. This part determines the organizations
and operating units to which the user has access
*/

/* For PJI Organization Security Profile */
SELECT 	view_all_flag,
	view_all_organizations_flag
INTO
	l_org_view_all_flag,
	l_org_view_all_org_flag
FROM PER_SECURITY_PROFILES
where security_profile_id = l_pji_security_prof;

IF (NVL(l_org_view_all_flag,'N') = 'Y' OR NVL(l_org_view_all_org_flag,'N') = 'Y') THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_ALL_ACCESS')
	INTO l_org_all_access_msg_text
	FROM dual;

	pji_utils.write2out(l_newline || l_org_all_access_msg_text || l_newline);
ELSE
	l_org_name_tbl := V_TYPE_TAB();
	l_org_name_tbl.DELETE;

	SELECT org.name
	BULK COLLECT INTO l_org_name_tbl
	FROM
	    hr_all_organization_units org
	   ,per_organization_list sec
	WHERE
		 org.organization_id = sec.organization_id
	AND  	 sec.security_profile_id = l_pji_security_prof;

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_PAR_ORG_ACCS')
	INTO l_org_par_access_msg_text
	FROM dual;

        pji_utils.write2out(l_newline || l_org_par_access_msg_text || l_newline || l_newline);

	FOR i in l_org_name_tbl.FIRST.. l_org_name_tbl.LAST
	LOOP
		pji_utils.write2out( l_org_name_tbl(i) || l_newline);
	END LOOP;

	pji_utils.write2out(l_newline);

END IF;

/* For MO Security Profile */
SELECT 	view_all_flag,
	view_all_organizations_flag
INTO
	l_ou_view_all_flag,
	l_ou_view_all_org_flag
FROM PER_SECURITY_PROFILES
where security_profile_id = l_mo_security_prof;

IF (NVL(l_ou_view_all_flag,'N') = 'Y' OR NVL(l_ou_view_all_org_flag,'N') = 'Y') THEN
	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_ALL_MO_ACCESS')
	INTO l_ou_all_access_msg_text
	FROM dual;

	pji_utils.write2out(l_newline || l_ou_all_access_msg_text || l_newline);
ELSE
	l_ou_name_tbl := V_TYPE_TAB();
	l_ou_name_tbl.DELETE;

	SELECT org.name
	BULK COLLECT INTO l_ou_name_tbl
	FROM
		hr_all_organization_units org
	       ,per_organization_list sec
	WHERE
		 org.organization_id = sec.organization_id
	AND  sec.security_profile_id = l_mo_security_prof
	AND  exists
		 (
		 	SELECT 1
			FROM hr_organization_information info
			WHERE info.organization_id = org.organization_id
			AND   info.org_information_context = 'Operating Unit Information'
	 	);

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SEC_PROF_PAR_MO_ACCS')
	INTO l_ou_par_access_msg_text
	FROM dual;

    pji_utils.write2out(l_newline || l_ou_par_access_msg_text || l_newline || l_newline);

	FOR i in l_ou_name_tbl.FIRST.. l_ou_name_tbl.LAST
	LOOP
		pji_utils.write2out( l_ou_name_tbl(i) || l_newline);
	END LOOP;

	pji_utils.write2out(l_newline);

END IF;

END CHK_SECURITY_SET_UP;

/*
This CONCURRENT PROGRAM prepares the report for
PJI/BIS/TIME Calendar Dimension set up parameters
that are needed for running project intelligence
application.
*/

PROCEDURE REPORT_PJI_PARAM_SETUP
	(errbuff        OUT NOCOPY VARCHAR2,
         retcode        OUT NOCOPY VARCHAR2)
IS
l_newline       varchar2(10) := '
';
l_pji_report_msg	VARCHAR2(100);
l_pji_no_err_msg	VARCHAR2(100);
l_separator		VARCHAR2(100);
BEGIN

SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_PJI_BIS_REPORT_TEXT')
INTO l_pji_report_msg
FROM dual;

l_separator 	 := '---------------------------------------';

pji_utils.write2out(l_newline || l_pji_report_msg || l_newline || l_separator || l_newline);

CHK_BIS_SET_UP;

CHK_PJI_SET_UP;

CHK_ORG_TIME_CAL_DIM;

CHK_PJI_ORG_HRCHY;

IF (g_cnt_set_up_err = 0) THEN

	SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SETUP_NOERR_TEXT')
	INTO l_pji_no_err_msg
	FROM dual;

	pji_utils.write2out(l_pji_no_err_msg || l_newline);
END IF;

END REPORT_PJI_PARAM_SETUP;

/*
This CONCURRENT PROGRAM prepares the report for
Security set up parameters that are needed for
running project intelligence application.
*/

PROCEDURE REPORT_PJI_SECURITY_SETUP
	(p_user_name    IN         VARCHAR2,
	 errbuff        OUT NOCOPY VARCHAR2,
         retcode        OUT NOCOPY VARCHAR2)
IS

l_newline       varchar2(10) := '
';
l_security_report_msg	VARCHAR2(100);
l_user_name_msg		VARCHAR2(30);
l_separator		VARCHAR2(100);
l_username		VARCHAR2(30);
l_userid        	NUMBER := FND_GLOBAL.USER_ID;

BEGIN

SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_SECURITY_REPORT_TEXT')
INTO l_security_report_msg
FROM dual;

l_separator 	 := '------------------------------------------';

pji_utils.write2out(l_newline || l_security_report_msg || l_newline || l_separator || l_newline);

IF p_user_name IS NULL THEN
	SELECT user_name
	INTO   l_username
	FROM   fnd_user
	WHERE  user_id = l_userid;
ELSE
	l_username := p_user_name;
END IF;

SELECT FND_MESSAGE.GET_STRING('PJI','PJI_CHK_USER_NAME')
INTO l_user_name_msg
FROM dual;

pji_utils.write2out(l_newline || l_user_name_msg || ' ' || l_username || l_newline );

CHK_SECURITY_SET_UP
	(p_username => l_username);

END REPORT_PJI_SECURITY_SETUP;

END PJI_AUDIT_RPT;

/

--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_UTIL_PKG" AS
/* $Header: hrioputl.pkb 120.5 2005/09/22 07:12 jrstewar noship $ */

g_rtn  VARCHAR2(30) := '
';

/* Returns SQL fragment for applying security to DBI reports */
FUNCTION get_security_clause(p_security_type    VARCHAR2)  -- [MGR, ORG]
   RETURN VARCHAR2 IS

  l_security_clause  VARCHAR2(2000);

BEGIN

  IF (p_security_type = 'MGR') THEN
    l_security_clause :=
'AND EXISTS
 (SELECT /*+ NO_UNNEST INDEX(sup hri_cs_suph_n4) */ null
  FROM  hri_cs_suph sup
  WHERE sup.sup_person_id IN (hri_bpl_security.get_apps_signin_person_id,&BIS_SELECTED_TOP_MANAGER)
  AND sup.sub_person_id = &HRI_PERSON+HRI_PER_USRDR_H
  AND sup.sub_invalid_flag_code = ''N''
  AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date
              AND sup.effective_end_date)';

  END IF;

  RETURN l_security_clause;

END get_security_clause;

/* Calculates the annualization factor */
FUNCTION calc_anl_factor(p_period_type  IN VARCHAR2)
     RETURN NUMBER IS

  l_anl_factor  NUMBER;

BEGIN

  IF (p_period_type = 'FII_ROLLING_YEAR') THEN
    l_anl_factor := 1;
  ELSIF (p_period_type = 'FII_ROLLING_QTR') THEN
    l_anl_factor := 365 / 90;
  ELSIF (p_period_type = 'FII_ROLLING_MONTH') THEN
    l_anl_factor := 365 / 30;
  ELSIF (p_period_type = 'FII_ROLLING_WEEK') THEN
    l_anl_factor := 365 / 7;
  ELSE
    l_anl_factor := (365/30);
  END IF;

  RETURN l_anl_factor;

END calc_anl_factor;

-- Sets default sort order
FUNCTION set_default_order_by(p_order_by_clause  IN VARCHAR2)
   RETURN VARCHAR2 IS

  l_return_value   VARCHAR2(1000);

BEGIN

  IF (p_order_by_clause IS NOT NULL) THEN
    l_return_value := REPLACE(p_order_by_clause, 'VIEWBY', 'HRI_P_ORDER_BY_1');
  ELSE
    l_return_value := 'order_by';
  END IF;

  RETURN l_return_value;

END set_default_order_by;

-- adds a filter on the viewby for "small" view bys
FUNCTION set_viewby_filter
  (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_view_by_alias  IN VARCHAR2)
      RETURN VARCHAR2 IS

  l_viewby_filter   VARCHAR2(1000);

BEGIN

/* Trap exceptions for no data found */
  BEGIN

    l_viewby_filter :=
'AND ' || p_view_by_alias || '.id IN (' ||
          p_bind_tab(p_parameter_rec.view_by).pmv_bind_string || ')' || g_rtn;

/* When no parameter value is set no filter is needed */
  EXCEPTION WHEN OTHERS THEN
    null;

  END;

/* Special case - filters correct set of LOW bands */
  IF (p_parameter_rec.view_by = 'HRI_LOW+HRI_LOW_BAND_X') THEN

  /* If person type filter is applied use it to filter the bands */
    IF (p_parameter_rec.wkth_wktyp_sk_fk IS NOT NULL) THEN

      l_viewby_filter := l_viewby_filter ||
'AND ' || p_view_by_alias || '.wkth_wktyp_sk_fk = ''' ||
          p_parameter_rec.wkth_wktyp_sk_fk || '''' || g_rtn;

    END IF;

  END IF;

  RETURN l_viewby_filter;

END set_viewby_filter;
--
-- -------------------------------------------------------------------------
-- This procedure sets the parameters taking into consideration whethere the
-- PMV is being generated in PMV mode or SQL mode. The SQL mode is used for
-- debugging.
-- -------------------------------------------------------------------------
--
PROCEDURE substitute_bind_values
  (p_bind_tab    IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_bind_format IN VARCHAR2,
   p_sql         IN OUT NOCOPY VARCHAR2)
IS
  --
  l_index      VARCHAR2(100);
  --
BEGIN
  --
  IF p_bind_format = 'SQL' THEN
    --
    -- Loop through all the parameters and set them
    --
    l_index := p_bind_tab.FIRST;
    --
    WHILE l_index IS NOT NULL LOOP
      --
      p_sql := replace(p_sql,
                       p_bind_tab(l_index).pmv_bind_string,
                       p_bind_tab(l_index).sql_bind_string);
      --
      l_index := p_bind_tab.NEXT(l_index);
      --
    END LOOP;
  --
  END IF;
  --
END substitute_bind_values;

--
-- -------------------------------------------------------------------------
-- This function checks Profile Option HRI:DBI Link To Transaction System
-- Link to HR Employee Directory
--
-- -------------------------------------------------------------------------
--
FUNCTION chk_emp_dir_lnk(p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE
                        ,p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE)

   RETURN NUMBER IS

  l_return_chk  NUMBER;
  l_hr_dir_chk  NUMBER;
  l_profile_vl  VARCHAR2(1000);

BEGIN
    /* Checks Employee Directory has been populated */
  	SELECT count(*) INTO l_hr_dir_chk
    FROM per_empdir_people
    WHERE orig_system = 'PER'
    AND rownum <= 1;

  fnd_profile.get('HRI_DBI_LNK_TRNS_SYS',l_profile_vl);

  /* Check the Profile HRI:DBI Link To Transaction System */
  IF (l_profile_vl = 'HR_EMP_DIR_ONLY') AND (l_hr_dir_chk = 1) THEN
    --
	  l_return_chk := 1;
    --
	ELSIF (l_profile_vl = 'NO_LNK' ) THEN
    --
	  l_return_chk := 0;
    ELSE
    --
	  l_return_chk := 0;
  --
  END IF;

 RETURN l_return_chk ;

END chk_emp_dir_lnk;

-- Gets sql fragment for change %
FUNCTION get_change_percent_sql(p_previous_col   IN VARCHAR2,
                                p_current_col    IN VARCHAR2)
     RETURN VARCHAR2 IS

BEGIN

--
-- --------------------------------------------------------------------
-- The change percent calculation is:
--
-- 100 * (CURRENT - PREVIOUS) / PREVIOUS
--
-- If PREVIOUS is 0 NULL is returned to avoid the divide by 0 error,
-- which is rendered as N/a.
-- --------------------------------------------------------------------
--
  RETURN
'DECODE(' || p_previous_col || ',
 0, to_number(null),
100 * (' || p_current_col || ' - ' || p_previous_col || ') / ' || p_previous_col || ')';

EXCEPTION WHEN OTHERS THEN

  RETURN 'to_number(NULL)';

END get_change_percent_sql;

END hri_oltp_pmv_util_pkg;

/

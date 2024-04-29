--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: hrioputl.pkh 120.1 2005/08/08 04:03 jtitmas noship $ */

-- returns the common AK_QUERY PLSQL clause for MGR security
FUNCTION get_security_clause(p_security_type   VARCHAR2)   -- [MGR, ORG]
   RETURN VARCHAR2;

-- returns the annualization factor for a period
FUNCTION calc_anl_factor(p_period_type  IN VARCHAR2)
     RETURN NUMBER;

-- sets the order by clause
FUNCTION set_default_order_by(p_order_by_clause  IN VARCHAR2)
    RETURN VARCHAR2;

-- adds a filter on the viewby for "small" view bys
FUNCTION set_viewby_filter
  (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_view_by_alias  IN VARCHAR2)
      RETURN VARCHAR2;

-- substitutes SQL values for PMV binds
PROCEDURE substitute_bind_values
  (p_bind_tab    IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_bind_format IN VARCHAR2,
   p_sql         IN OUT NOCOPY VARCHAR2);

-- Checks profile option Enable / Disable Link to HR Employee Directory
FUNCTION chk_emp_dir_lnk(p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE
                        ,p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE)

RETURN NUMBER;

-- Gets sql fragment for change %
FUNCTION get_change_percent_sql(p_previous_col   IN VARCHAR2,
                                p_current_col    IN VARCHAR2)
     RETURN VARCHAR2;

END hri_oltp_pmv_util_pkg;

 

/

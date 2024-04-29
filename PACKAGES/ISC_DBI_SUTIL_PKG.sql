--------------------------------------------------------
--  DDL for Package ISC_DBI_SUTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_SUTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: iscdbisutils.pls 120.0 2005/05/25 17:24:10 appldev noship $ */

-- Array for the MV aggregation level values
TYPE mv_agg_lvl_rec IS RECORD(VALUE NUMBER);
TYPE mv_agg_lvl_tbl IS TABLE OF mv_agg_lvl_rec;

/* Generic Process Parameter function.
*/
PROCEDURE process_parameters (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                              p_view_by OUT NOCOPY VARCHAR2,
                              p_view_by_col_name OUT NOCOPY VARCHAR2,
                              p_comparison_type OUT NOCOPY VARCHAR2,
                              p_xtd OUT NOCOPY VARCHAR2,
                              p_cur_suffix OUT NOCOPY VARCHAR2,
                              p_where_clause OUT NOCOPY VARCHAR2,
                              p_mv OUT NOCOPY VARCHAR2,
                              p_join_tbl OUT NOCOPY
                              poa_dbi_util_pkg.poa_dbi_join_tbl,
                              p_mv_level_flag OUT NOCOPY VARCHAR2,
                              p_trend IN VARCHAR2,
                              p_func_area IN VaRCHAR2,
                              p_version IN VARCHAR2,
                              p_role IN VARCHAR2,
                              p_mv_set IN VARCHAR2,
                              p_mv_flag_type IN VARCHAR2 DEFAULT 'NONE',
			      p_in_join_tbl OUT NOCOPY
			      poa_dbi_util_pkg.poa_dbi_in_join_tbl);


/*     For the status_sql, get the name of the viewby column. */
FUNCTION get_view_by_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2;

/* Get the VIEWBY and VIEWBYID columns */
FUNCTION get_view_by_select_clause (p_viewby IN VARCHAR2)
    RETURN VARCHAR2;

/* Build the fact view by columns string using the join table
   for queries using windowing.  */
FUNCTION get_fact_select_columns (p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

/* rate_str

    Gets the string for percentage/ratio change of two specified strings.
    Better than copying CASE statements everywhere */
FUNCTION rate_str (p_numerator IN VARCHAR2,
                      p_denominator IN VARCHAR2,
                      p_rate_type IN VARCHAR2,
                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* pos_denom_percent_str

    Gets the string for percentage change of two specified strings if
    the denominator is positive and greater than 0.
    Better than copying CASE statements everywhere. */
FUNCTION pos_denom_percent_str (p_numerator IN VARCHAR2,
                                p_denominator IN VARCHAR2,
                                p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* change_str
    Get the percentage change string. Better than writing out all the case
    statements */
FUNCTION change_str (p_new_numerator IN VARCHAR2,
                     p_old_numerator IN VARCHAR2,
                     p_denominator IN VARCHAR2,
                     p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;


/* change_rate_str
    Get the change in percentage/ratio string. Better than writing out all the case
    statements */
FUNCTION change_rate_str (p_new_numerator IN VARCHAR2,
                         p_new_denominator IN VARCHAR2,
                         p_old_numerator IN VARCHAR2,
                         p_old_denominator IN VARCHAR2,
                         p_rate_type IN VARCHAR2,
                         p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* get_global_weight_uom
    Gets the global weight unit of measure
 */
FUNCTION get_global_weight_uom RETURN VARCHAR2;

/* get_global_volume_uom
    Gets the global volume unit of measure
 */
FUNCTION get_global_volume_uom RETURN VARCHAR2;

/* get_global_distance_uom
    Gets the global distance unit of measure
 */
FUNCTION get_global_distance_uom RETURN VARCHAR2;

END ISC_DBI_SUTIL_PKG;

 

/

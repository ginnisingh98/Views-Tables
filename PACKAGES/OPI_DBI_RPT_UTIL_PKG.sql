--------------------------------------------------------
--  DDL for Package OPI_DBI_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_RPT_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRMFGUTS.pls 120.6 2006/02/24 03:23:00 achandak noship $ */

/*++++++++++++++++++++++++++++++++++++++++*/
/* Dimension bitmap values for OPI
/*++++++++++++++++++++++++++++++++++++++++*/
ORG_BMAP CONSTANT INTEGER := 1;
RES_BMAP CONSTANT INTEGER := 4;
RES_GRP_BMAP CONSTANT INTEGER := 8;
RES_DEPT_BMAP CONSTANT INTEGER := 16;
CATEGORY_BMAP CONSTANT INTEGER := 32;
CYCLE_COUNT_HEADER_BMAP CONSTANT INTEGER := 64;
CYCLE_COUNT_CLASS_BMAP CONSTANT INTEGER := 128;
ITEM_BMAP CONSTANT INTEGER := 256;
ORG_SUB_BMAP CONSTANT INTEGER := 512;
REASON_CODE_BMAP CONSTANT INTEGER := 1024;
OP_PLAN_BMAP CONSTANT INTEGER := 2048;
LOCATOR_BMAP CONSTANT INTEGER := 4096;
ITEM_GRADE_BMAP CONSTANT INTEGER := 8192;
ITEM_LOT_BMAP CONSTANT INTEGER := 16384;
TRX_REASON_BMAP CONSTANT INTEGER := 32768;

-- Identifiers for the various viewby's
C_VIEWBY_ORG CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION';
C_VIEWBY_SUB CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION_SUBINVENTORY';
C_VIEWBY_ITEM CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_ORG';
C_VIEWBY_INV_CAT CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_INV_CAT';
C_VIEWBY_ORG_LOC CONSTANT VARCHAR2(50) := 'ORGANIZATION+OPI_SUB_LOCATOR_LVL';
C_VIEWBY_ITEM_GRADE CONSTANT VARCHAR2(50) :=
            'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL';
C_VIEWBY_ITEM_LOT CONSTANT VARCHAR2(50) :=
            'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL';

-- Identifiers for the various dimensions
C_DIMNAME_ORG CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION';
C_DIMNAME_SUB CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION_SUBINVENTORY';
C_DIMNAME_ITEM CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_ORG';
C_DIMNAME_INV_CAT CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_INV_CAT';
C_DIMNAME_ORG_LOC CONSTANT VARCHAR2(50) := 'ORGANIZATION+OPI_SUB_LOCATOR_LVL';
C_DIMNAME_ITEM_GRADE CONSTANT VARCHAR2(50) :=
            'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL';
C_DIMNAME_ITEM_LOT CONSTANT VARCHAR2(50) :=
            'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL';


-- Identifier for value 'All' for any dimension
C_ALL CONSTANT VARCHAR2 (10) := 'All';

-- Associated Array for the dimension bitmaps.
TYPE opi_dbi_mv_bmap_rec is RECORD (mv_name VARCHAR2(32),
                                    mv_bmap NUMBER);
TYPE opi_dbi_mv_bmap_tbl is TABLE of opi_dbi_mv_bmap_rec;

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
                              p_mv_flag_type IN VARCHAR2 := 'NONE');


/*
    For the status_sql, get the name of the viewby column.
*/
FUNCTION get_view_by_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2;

/* Get the VIEWBY and VIEWBYID columns
*/
FUNCTION get_viewby_select_clause (p_viewby IN VARCHAR2)
    RETURN VARCHAR2;

/* Build the fact view by columns string using the join table
   for queries using windowing.
*/
FUNCTION get_fact_select_columns (p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2;

/* Return the viewby item columns, description and UOM
*/
PROCEDURE get_viewby_item_columns (p_dim_name VARCHAR2,
                                   p_description OUT NOCOPY VARCHAR2,
                                   p_uom OUT NOCOPY VARCHAR2);

/* API called by core team during migration to set R12 migration date
   into our log table
*/
PROCEDURE set_inv_convergence_date (x_return_status OUT NOCOPY VARCHAR2);

/* Procedure called by DBI ETL's to get the R12 migration date
*/
PROCEDURE get_inv_convergence_date (p_inv_migration_date OUT NOCOPY DATE);

/* Procedure to merge the convergence date into the DBI log table
*/
PROCEDURE merge_inv_convergence_date (p_migration_date IN DATE);

/* percent_str

    Gets the string for percentage change of two specified strings.
    Better than copying CASE statements everywhere
*/
FUNCTION percent_str (p_numerator IN VARCHAR2,
                      p_denominator IN VARCHAR2,
                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* percent_str_basic

    Gets the string for percentage change of two specified strings.
    Better than copying CASE statements everywhere.
    No NVLs on numerator.
*/
FUNCTION percent_str_basic (p_numerator IN VARCHAR2,
                            p_denominator IN VARCHAR2,
                            p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* pos_denom_percent_str

    Gets the string for percentage change of two specified strings if
    the denominator is positive and greater than 0.
    Better than copying CASE statements everywhere.
*/
FUNCTION pos_denom_percent_str (p_numerator IN VARCHAR2,
                                p_denominator IN VARCHAR2,
                                p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* pos_denom_percent_str_basic

    Gets the string for percentage change of two specified strings if
    the denominator is positive and greater than 0.
    Better than copying CASE statements everywhere.
    No NVLs on numerator.
*/
FUNCTION pos_denom_percent_str_basic (p_numerator IN VARCHAR2,
                                      p_denominator IN VARCHAR2,
                                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* change_str
    Get the percentage change string. Better than writing out all the case
    statements
*/
FUNCTION change_str (p_new_numerator IN VARCHAR2,
                     p_old_numerator IN VARCHAR2,
                     p_denominator IN VARCHAR2,
                     p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* change_str_basic
    Get the percentage change string. Better than writing out all the case
    statements. No NVLs on numerator.
*/
FUNCTION change_str_basic (p_new_numerator IN VARCHAR2,
                           p_old_numerator IN VARCHAR2,
                           p_denominator IN VARCHAR2,
                           p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* change_pct_str
    Get the change in percentage string. Better than writing out all the case
    statements
*/
FUNCTION change_pct_str (p_new_numerator IN VARCHAR2,
                         p_new_denominator IN VARCHAR2,
                         p_old_numerator IN VARCHAR2,
                         p_old_denominator IN VARCHAR2,
                         p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* change_pct_str_basic
    Get the change in percentage string. Better than writing out all the case
    statements.
    No NVLs on numerator.
*/
FUNCTION change_pct_str_basic (p_new_numerator IN VARCHAR2,
                               p_new_denominator IN VARCHAR2,
                               p_old_numerator IN VARCHAR2,
                               p_old_denominator IN VARCHAR2,
                               p_measure_name IN VARCHAR2)
    RETURN VARCHAR2;

/* nvl_str
    Convert a string into its NVL (str, val)
    The default NVL value is 0
*/
FUNCTION nvl_str (p_str IN VARCHAR2,
                  p_default_val IN NUMBER := 0)
    RETURN VARCHAR2;

/* raw_str
    If the string is NULL, return NULL.
    Else return itself.
*/
FUNCTION raw_str (p_str IN VARCHAR2)
    RETURN VARCHAR2;

/*
      If the value of the string is NEGATIVE, return NULL.
      Else return itself.
*/
FUNCTION neg_str(p_str IN VARCHAR2)
        RETURN VARCHAR2;

/* rate_str
    Calculates a rate given a numerator and denominator;
    p_rate_type = 'P' indicates percentage inputs
    p_rate_type = 'NP' indicates absolute inputs
*/
FUNCTION rate_str (p_numerator IN VARCHAR2,
                   p_denominator IN VARCHAR2,
                   p_rate_type IN VARCHAR2 := 'P')
    RETURN VARCHAR2;

/* Replace a substring only once */
FUNCTION replace_n (p_orig_str IN VARCHAR2,
                    p_match_str IN VARCHAR2,
                    p_replace_str IN VARCHAR2 := NULL,
                    p_start_pos IN NUMBER := 1,
                    p_num_times IN NUMBER := 1)
    RETURN VARCHAR2;


/* Security where clauses function
   Making public for use in specific detail reports
*/
FUNCTION get_security_where_clauses(p_org_value IN VARCHAR2, p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

--  OPI_UM_CONVERT will use in place INV_CONVERT.inv_um_convert
-- In inventory Intransit load
FUNCTION  OPI_UM_CONVERT (
     p_item_id           	number,
     p_item_qty               number,
     p_from_unit         	varchar2,
     p_to_unit           	varchar2 ) RETURN number ;

-- Variable will use in above package an will used in callin procedure too
g_pk_uom_conversion      number;


END OPI_DBI_RPT_UTIL_PKG;


 

/

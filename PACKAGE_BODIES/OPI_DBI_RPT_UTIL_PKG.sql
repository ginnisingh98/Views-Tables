--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RPT_UTIL_PKG" AS
/*$Header: OPIDRMFGUTB.pls 120.9 2006/02/24 03:23:27 achandak noship $ */

 s_pkg_name CONSTANT VARCHAR2 (50) := 'opi_dbi_rpt_util_pkg';

/*++++++++++++++++++++++++++++++++++++++++*/
/* Local Functions
/*++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE init_dim_map (p_dim_map out NOCOPY
                        poa_dbi_util_pkg.poa_dbi_dim_map,
                        p_mv_set IN VARCHAR2);

PROCEDURE reinit_dim_map (p_dim_map in out  NOCOPY
                            poa_dbi_util_pkg.poa_dbi_dim_map,
                        p_mv IN VARCHAR2,
                        p_mv_set IN VARCHAR2);

FUNCTION get_mv (p_mv_set IN VARCHAR2,
         p_mv_level_flag IN VARCHAR2,
         p_view_by IN VARCHAR2,
         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_table (p_dim_name VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_mv_flag_where_clause (p_mv_flag_type IN VARCHAR2,
                                   p_trend IN VARCHAR2 := 'N',
                                   p_mv IN VARCHAR2 := '',
                                   p_mv_where_clause IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_mv_specific_where_clause(p_mv_set IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_scrap_filter_clause
    RETURN VARCHAR2;

FUNCTION get_item_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_rsc_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_inv_val_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_rtx_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_rtp_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_wms_c_utz_item_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_wms_c_utz_sub_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_wms_stor_utz_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;


/* mochawla - declare functions for Pick and OP in DBI 7.1*/
FUNCTION get_pex_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_per_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_opp_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_oper_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

/* Current Inventory Status */
FUNCTION get_curr_inv_exp_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

/* Inventory Days Onhand */
FUNCTION get_prod_cons_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_cogs_ship_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION get_trx_reason_where_clause (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

PROCEDURE get_join_info (p_view_by IN varchar2,
                         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
                         x_join_tbl OUT NOCOPY
                         poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                         p_mv_set IN VARCHAR2);

FUNCTION get_mv_level_flag (p_mv_flag_type VARCHAR2,
                            p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;


FUNCTION get_item_flag_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_inv_val_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_rtx_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_rtp_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_resource_level_flag_val (p_dim_name IN VARCHAR2,
                                      p_dim_map IN
                                      poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_c_utz_item_aggr_flag (p_dim_name VARCHAR2,
                                     p_dim_map IN
                                        poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_c_utz_sub_aggr_flag (p_dim_name VARCHAR2,
                                      p_dim_map IN
                                       poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_stor_utz_aggr_flag (p_dim_name VARCHAR2,
                                     p_dim_map IN
                                       poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

/* mochawla - declare functions for Pick and OP in DBI 7.1*/
FUNCTION get_wms_pex_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_per_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_opp_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_wms_oper_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

/* Current Inventory Expiration Status */
FUNCTION get_rollup1_aggr_flag (p_dim_name VARCHAR2,
                                p_dim_map IN
                                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

/*Scrap By Reason */
FUNCTION get_trx_reason_aggr_flag (p_dim_name VARCHAR2,
                p_dim_map IN
                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

/* changes for Cycle Count in DBI 7.0 */
FUNCTION get_cca_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;


FUNCTION get_cca_level_flag_val (p_dim_name IN VARCHAR2,
                                 p_dim_map  IN
                                 poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_agg_level (p_mv_lvl_tbl IN opi_dbi_rpt_util_pkg.MV_AGG_LVL_TBL,
                        p_dim_bmap   IN NUMBER)
    RETURN NUMBER;

/*
Changes for Product Cost Management: Product Gross Margin in DBI 7.0
*/

FUNCTION get_prodcat_cust_flag_val(p_dim_name IN VARCHAR2,
                              p_dim_map IN
                              poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_prdcat_cust_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2;

FUNCTION select_mv (p_mv_set IN VARCHAR2, p_mv_level_flag IN VARCHAR2,
            p_view_by IN VARCHAR2, p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
   RETURN VARCHAR2;

FUNCTION get_mv_where_clause_flag (p_mv IN VARCHAR2)
    RETURN VARCHAR2;

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function Definitions
/*++++++++++++++++++++++++++++++++++++++++*/

/* process_parameters

    Generic routine to process the parameters passed in from the PMV
    page.

    Points of note:
    p_mv_level_flag - For DBI 6.0 all report queries using this
                      package will use a flag to decide which rows of
                      their MVs they which need to query.
                      For instance, for Scrap and Material Usage, this
                      amounts to the item_cat_flag.
                      For unrecognized cost variance, there is no such
                      flag.
    p_mv_flag_type - This determines what type of MV level flag is being
                     computed i.e. item_cat_flag, or nothing and
                     correspondingly what needs to be added to the
                     where clause.


    Date        Author              Action
    06/02/03    Dinkar Gupta        Wrote Function

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
                              p_mv_flag_type IN VARCHAR2 := 'NONE')
IS
    l_dim_map poa_dbi_util_pkg.poa_dbi_dim_map;
    l_dim_bmap NUMBER := 0;
    l_org_val VARCHAR2 (120) := NULL;

    l_as_of_date DATE;
    l_prev_as_of_date DATE;
    l_nested_pattern NUMBER;

    l_mv_where_clause VARCHAR2(1) := 'Y'; -- Determines if MV Flag Where Clause needs to be appended.

    l_stmt_id NUMBER := 0;

BEGIN

    -- initialize the dimension map with all the required dimensions.
    l_stmt_id := 10;
    init_dim_map (p_dim_map => l_dim_map,
              p_mv_set => p_mv_set);

    -- Get the various parameter values from the utility package.
    -- This package will also compute the l_dim_bmap
    l_stmt_id := 20;
    poa_dbi_util_pkg.get_parameter_values (p_param => p_param,
                                           p_dim_map => l_dim_map,
                                           p_view_by => p_view_by,
                                           p_comparison_type => p_comparison_type,
                                           p_xtd => p_xtd,
                                           p_as_of_date => l_as_of_date,
                                           p_prev_as_of_date => l_prev_as_of_date,
                                           p_cur_suffix => p_cur_suffix,
                                           p_nested_pattern => l_nested_pattern,
                                           p_dim_bmap => l_dim_bmap);

    -- Find out the view by column name
    l_stmt_id := 30;
    IF (l_dim_map.exists (p_view_by)) THEN
        p_view_by_col_name := l_dim_map(p_view_by).col_name;
    END IF;


    -- Get the org values
    IF (l_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := l_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    -- Finally get the join info based on the dimension level parameters
    -- passed in.
    l_stmt_id := 40;
    get_join_info (p_view_by => p_view_by,
               p_dim_map => l_dim_map,
               x_join_tbl => p_join_tbl,
               p_mv_set => p_mv_set);

    -- Get the item cat flag value for MV aggregation
    l_stmt_id := 50;
    p_mv_level_flag := get_mv_level_flag (p_mv_flag_type => p_mv_flag_type,
                          p_dim_name => p_view_by,
                                          p_dim_map => l_dim_map);

    -- Get the MV we need to join to.
    l_stmt_id := 60;
    p_mv := get_mv (p_mv_set => p_mv_set,
                p_mv_level_flag => p_mv_level_flag,
                p_view_by => p_view_by,
                p_dim_map => l_dim_map);

    reinit_dim_map (p_dim_map => l_dim_map,
            p_mv => p_mv,
            p_mv_set => p_mv_set);

    -- Determine if MV Flag Where Clause needs to be appended. By default the value is 'Y'
    l_stmt_id := 70;
    l_mv_where_clause := get_mv_where_clause_flag (p_mv => p_mv);

    -- Get the dimension level specific where clauses
    -- and the security where clause.

    l_stmt_id := 75;
    if(p_mv_set = 'CPD') then
      p_where_clause := '2=2';
    else
      p_where_clause := '';
    end if;

    l_stmt_id := 80;
    p_where_clause := p_where_clause || poa_dbi_util_pkg.get_where_clauses (p_dim_map => l_dim_map,
                                                          p_trend => p_trend);

    -- Attach the optional MV flag where clause
    l_stmt_id := 90;
    p_where_clause := p_where_clause ||
                       get_mv_flag_where_clause (
                                     p_mv_flag_type => p_mv_flag_type,
                                     p_trend => p_trend,
                                     p_mv => p_mv,
                                     p_mv_where_clause => l_mv_where_clause) ||
               get_mv_specific_where_clause(p_mv_set => p_mv_set);

    -- attach the security clause
    l_stmt_id := 100;
    p_where_clause := p_where_clause ||
                   get_security_where_clauses (p_org_value => l_org_val,
                               p_trend => p_trend);

END process_parameters;

/*++++++++++++++++++++++++++++++++++++++++*/
/* To determine if the MV where flag clause
   is required.
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_mv_where_clause_flag
    If the MV definition does not have a
    MV Level Flag or an aggregation
    level flag return 'N' else return 'Y'
*/
FUNCTION get_mv_where_clause_flag (p_mv IN VARCHAR2)
     RETURN VARCHAR2
IS
    l_mv_where_clause_flag VARCHAR2(1) := 'Y';
BEGIN
    l_mv_where_clause_flag :=
        (CASE p_mv
            WHEN 'OPI_PGM_CAT_MV' THEN
                 'N'
            ELSE
                 'Y'
        END);
    RETURN l_mv_where_clause_flag;
END get_mv_where_clause_flag;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Where clause building routine
/*++++++++++++++++++++++++++++++++++++++++*/

/*  get_mv_specific_where_clause

    Depending on which report we want to populate, tag on any specific
    conditions to the where clause.
*/

FUNCTION get_mv_specific_where_clause(p_mv_set IN VARCHAR2)
    RETURN VARCHAR2

IS

    l_mv_specific_where_clause VARCHAR2 (200) :='';

BEGIN

    IF (p_mv_set = 'SCR') THEN
    l_mv_specific_where_clause := get_scrap_filter_clause;
    ELSE
        l_mv_specific_where_clause := '';
    END IF;

    return l_mv_specific_where_clause;

END get_mv_specific_where_clause;


/*  get_mv_flag_where_clause

    Depending on which MV flag is being used, get a different
    where clause statement. The flag type is determined by p_mv_flag_type:
    'ITEM_CAT' - Scrap or material usage need item_cat_flag.

    'CCA_LEVEL' - 7.0 changes for cycle count Accuracy

    'PRD_CUST' - 7.0 changes for Product Cost Management: Product Gross Margin

    'WMS_PEX' : 7.1 - Pick Exceptions
    'WMS_PER' : 7.1 - Pick Exceptions by Reason
    'WMS_OPP' : 7.1 - OP Performance
    'WMS_OPER': 7.1 - OP Exception by Reason
*/
FUNCTION get_mv_flag_where_clause (p_mv_flag_type IN VARCHAR2,
                                   p_trend IN VARCHAR2 := 'N',
                                   p_mv IN VARCHAR2 := '',
                                   p_mv_where_clause IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_mv_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    IF (p_mv_where_clause = 'Y') THEN
        l_mv_flag_where_clause :=
             (CASE p_mv_flag_type
                WHEN 'ITEM_CAT' THEN
                    get_item_flag_where_clause (p_trend)
                WHEN 'RESOURCE_LEVEL' THEN
                    get_rsc_flag_where_clause (p_trend)
                WHEN 'INV_VAL_LEVEL' THEN
                    get_inv_val_flag_where_clause (p_trend)
		WHEN 'INV_VAL_UOM_LEVEL' THEN
                    -- Same as 'INV_VAL'
                    get_inv_val_flag_where_clause (p_trend)
                WHEN 'CCA_LEVEL' THEN
                    get_cca_flag_where_clause (p_trend)
                WHEN 'WMS_RTX' THEN
                    get_rtx_flag_where_clause (p_trend)
                WHEN 'WMS_RTP' THEN
                    get_rtp_flag_where_clause (p_trend)
                WHEN 'PRD_CUST' THEN
                    get_prdcat_cust_where_clause(p_trend)
                WHEN 'WMS_CURR_UTZ_ITEM_LEVEL' THEN
                    get_wms_c_utz_item_where_cl (p_trend)
                WHEN 'WMS_CURR_UTZ_SUB_LEVEL' THEN
                    get_wms_c_utz_sub_where_cl (p_trend)
                WHEN 'WMS_STOR_UTZ_LEVEL' THEN
                    get_wms_stor_utz_where_cl (p_trend)
                WHEN 'WMS_PEX' THEN
                            get_pex_flag_where_clause (p_trend)
                WHEN 'WMS_PER' THEN
                            get_per_flag_where_clause (p_trend)
                WHEN 'WMS_OPP' THEN
                    get_opp_flag_where_clause (p_trend)
                WHEN 'WMS_OPER' THEN
                    get_oper_flag_where_clause (p_trend)
		WHEN 'CURR_INV_EXP_LEVEL' THEN
                    get_curr_inv_exp_where_cl (p_trend)
                WHEN 'PROD_CONS_LEVEL' THEN
                    get_prod_cons_where_cl (p_trend)
                WHEN 'COGS_LEVEL' THEN
                    get_cogs_ship_where_cl (p_trend)
		WHEN 'TRX_REASON_LEVEL' THEN
		    get_trx_reason_where_clause (p_trend)
                ELSE
                    ''
              END);
    END IF;

    RETURN l_mv_flag_where_clause;

END get_mv_flag_where_clause;


/* get_scrap_filter_clause

   Return the 'source = 1' condition to filter out process data
   for scrap reports.

*/
FUNCTION get_scrap_filter_clause
    RETURN VARCHAR2
IS
    l_scrap_filter_clause VARCHAR2 (200) := '';

BEGIN

    l_scrap_filter_clause := ' AND fact.source = 1 ';

    RETURN l_scrap_filter_clause;
END get_scrap_filter_clause;



/* get_item_flag_where_clause

    Return the where clause for OPI specific Item cat flag
*/
FUNCTION get_item_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.item_cat_flag = :OPI_ITEM_CAT_FLAG ';

    RETURN l_flag_where_clause;

END get_item_flag_where_clause;



/* get_rsc_flag_where_clause

    Return the where clause for OPI specific Resource flag
*/
FUNCTION get_rsc_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.RESOURCE_LEVEL_FLAG = :OPI_RESOURCE_LEVEL_FLAG';


    RETURN l_flag_where_clause;

END get_rsc_flag_where_clause;

/* get_inv_val_flag_where_clause

    Return the where clause for Inventory Value specific aggregation
    level flag flag
*/
FUNCTION get_inv_val_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.aggregation_level_flag = :OPI_AGGREGATION_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_inv_val_flag_where_clause;

FUNCTION get_rtx_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_RTX_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_rtx_flag_where_clause;

FUNCTION get_rtp_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_RTP_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_rtp_flag_where_clause;

/* get_wms_c_utz_item_where_cl */
FUNCTION get_wms_c_utz_item_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_WMS_CURR_UTZ_ITEM_FLAG
';

    RETURN l_flag_where_clause;

END get_wms_c_utz_item_where_cl;

/* get_wms_c_utz_sub_where_cl */
FUNCTION get_wms_c_utz_sub_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_WMS_CURR_UTZ_SUB_FLAG
';

    RETURN l_flag_where_clause;

END get_wms_c_utz_sub_where_cl;

/* get_wms_stor_utz_where_cl */
FUNCTION get_wms_stor_utz_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_WMS_STOR_UTZ_FLAG
';

    RETURN l_flag_where_clause;

END get_wms_stor_utz_where_cl;

--
-- DBI 7.1 - Functions for Pick and OP Exceptions Region
--
/* Function:    get_pex_flag_where_clause
   Description: return bind variable for agg level in Pick Exception Report*/

FUNCTION get_pex_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_PEX_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_pex_flag_where_clause;

/* Function:    get_per_flag_where_clause
   Description: return bind variable for agg level in Pick Ex By Reason*/
FUNCTION get_per_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_PER_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_per_flag_where_clause;

/* Function:    get_opp_flag_where_clause
  Description: return bind variable for agg level in OP Performance */
FUNCTION get_opp_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_OPP_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_opp_flag_where_clause;

/* Function:    get_oper_flag_where_clause
  Description: return bind variable for agg level in OP Exc by Reason */
FUNCTION get_oper_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_OPER_AGG_LEVEL_FLAG ';

    RETURN l_flag_where_clause;

END get_oper_flag_where_clause;

/* get_curr_inv_exp_where_cl */
FUNCTION get_curr_inv_exp_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
-- {
    l_flag_where_clause VARCHAR2 (200) := '';
-- }
BEGIN
-- {
    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_CURR_INV_EXP_AGG_FLAG
';

    RETURN l_flag_where_clause;
-- }
END get_curr_inv_exp_where_cl;

/* get_prod_cons_where_cl */
FUNCTION get_prod_cons_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
-- {
    l_flag_where_clause VARCHAR2 (200) := '';
-- }
BEGIN
--{
    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_PROD_CONS_AGG_FLAG
';

    RETURN l_flag_where_clause;
-- }
END get_prod_cons_where_cl;

/* get_cogs_ship_where_cl */
FUNCTION get_cogs_ship_where_cl (p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
-- {
    l_flag_where_clause VARCHAR2 (200) := '';
-- }
BEGIN
-- {
    l_flag_where_clause :=
        ' AND fact.aggregation_level_flag = :OPI_COGS_SHIP_AGG_FLAG
';

    RETURN l_flag_where_clause;
-- }
END get_cogs_ship_where_cl;

/* Function:    get_trx_flag_where_clause
   Description: return bind variable for agg level in Scrap By Reason*/
FUNCTION get_trx_reason_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :OPI_TRX_REASON_FLAG ';

    RETURN l_flag_where_clause;

END get_trx_reason_where_clause;

/* DBI 7.0 changes for Cycle Count
   Function:    get_cca_flag_where_clause
   Description: return the where clause for OPI specific CCA flag
*/
FUNCTION get_cca_flag_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2(200) := ' ';
BEGIN
    l_flag_where_clause := 'AND fact.aggregation_level_flag = :OPI_CCA_LEVEL_FLAG';

    RETURN l_flag_where_clause;

END get_cca_flag_where_clause;

/*
   adwajan 26-JAN-2004
   DBI 7.0 changes for Product Cost Management: Product Gross Margin
   Function:    get_prdcat_cust_where_clause
   Description: return the where clause for PRD_CUST fag value
*/
FUNCTION get_prdcat_cust_where_clause(p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200) := '';
BEGIN
    l_flag_where_clause := 'AND fact.CUSTOMER_ITEM_CAT_FLAG = :OPI_PRDCAT_CUST_FLAG';
    RETURN l_flag_where_clause;
END get_prdcat_cust_where_clause;

/* get_security_where_clauses

    For OPI, this is quite simple.
*/

FUNCTION get_security_where_clauses(p_org_value IN VARCHAR2, p_trend IN VARCHAR2 := 'N')
    RETURN VARCHAR2
IS

    l_sec_where_clause VARCHAR2(1000):='';

BEGIN

  if(p_org_value is null or p_org_value = '' or p_org_value = 'All') then

          l_sec_where_clause :=
            ' AND (EXISTS
                (SELECT 1
                  FROM org_access o
                  WHERE o.responsibility_id = fnd_global.resp_id
                    AND o.resp_application_id = fnd_global.resp_appl_id
                    AND o.organization_id = fact.organization_id)
                OR EXISTS
                (SELECT 1
                  FROM mtl_parameters org
                  WHERE org.organization_id = fact.organization_id
                    AND NOT EXISTS
                        (SELECT 1
                          FROM org_access ora
                          WHERE org.organization_id = ora.organization_id))) ';

  end if;

  return l_sec_where_clause;

END get_security_where_clauses;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Functions to get the MV
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_mv

    Gets the MV for the rack concerned.


    For 6.0:
    For OPI, there is only one MV per rack.

    The p_mv_set parameter is used to determine which MV is being
    used i.e. when p_mv_set:
    'SCR' - Scrap rack, so use opi_scrap_sum_mv
    'MUV' - Material usage variance, so use opi_mtl_var_sum_mv
    'MCV' - Material cost variance, so use opi_mfg_var_sum_mv
    'CUV' - Current unrecognized variance, so use opi_dbi_curr_unrec_var_f
    'RSUT'- Resorce Utilization
    'RSVR'- Resource Variance
    'RSEF'- Resource Efficiency


    For 7.0:
    'INV_VAL' - Inventory value rack, so use opi_inv_val_sum_mv
    'ONH' - Onhand Inventory
    'INT' - Intransit Inventory
    Intoduce two levels for Cycle Count Reports
    'CCAC' - Reports that do not need UOM description
    'CCAD' - Report that need UOM description.
             In this case a join with UOM dimension is also added

    For 7.1:
    'RTX' - WMS - Receiving
    'RTP' - WMS - Putaways
    'WMS_CURR_UTZ_ITEM' - Current Utilization (Item)
    'WMS_CURR_UTZ_SUB' - Current Utilization (Subinventory)
    'WMS_STOR_UTZ' - Warehouse Storage utilization
    'PEX' - WMS - Pick Exceptions
    'PER' - WMS - Pick Exceptions By Reason
    'OPP' - WMS - OP Performance
    'OPER'- WMS - OP Exceptions By Reason
*/

FUNCTION get_mv (p_mv_set IN VARCHAR2,
         p_mv_level_flag IN VARCHAR2,
         p_view_by IN VARCHAR2,
         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2

IS

    l_mv_name VARCHAR2(2000) := '';

BEGIN

    -- For OPI, we only need to have one MV per rack. We do not use
    -- POAs bitmap capability for DBI 6.0 since we have different
    -- flags for hitting differently aggregated rows.


    -- Based on the program calling, use different MVs
    l_mv_name :=
        (CASE p_mv_set
            WHEN 'SCR' THEN 'opi_scrap_sum_mv'
            WHEN 'MUV' THEN 'opi_mtl_var_sum_mv'
            WHEN 'MCV' THEN 'opi_mfg_var_sum_mv'
            WHEN 'CUV' THEN 'opi_dbi_curr_unrec_var_f'
            WHEN 'RSUT' THEN 'opi_dbi_res_utl_mv'
            WHEN 'RSVR' THEN 'opi_dbi_res_var_mv'
            WHEN 'RSEF' THEN 'opi_dbi_res_var_mv'
            WHEN 'INV_VAL' THEN 'opi_inv_val_sum_mv'
	    WHEN 'INV_VAL_UOM' THEN 'opi_inv_val_sum_mv'
            WHEN 'ONH' THEN 'opi_inv_val_sum_mv'
            WHEN 'INT' THEN 'opi_inv_val_sum_mv'
            WHEN 'CCAC' THEN 'opi_inv_cca_sum_mv'
            WHEN 'RTX' THEN 'opi_wms_002_mv'
            WHEN 'RTP' THEN 'opi_wms_001_mv'
            WHEN 'CCAD' THEN 'opi_inv_cca_sum_mv'
            WHEN 'PGM' THEN select_mv(p_mv_set => p_mv_set,
                                  p_mv_level_flag => p_mv_level_flag,
                                  p_view_by => p_view_by,
                                  p_dim_map => p_dim_map)
            WHEN 'WMS_CURR_UTZ_ITEM' THEN 'opi_dbi_wms_curr_utz_item_f'
            WHEN 'WMS_CURR_UTZ_SUB' THEN 'opi_dbi_wms_curr_utz_sub_f'
            WHEN 'WMS_STOR_UTZ' THEN 'opi_wms_004_mv'
            WHEN 'PEX' THEN 'opi_wms_006_mv'
            WHEN 'PER' THEN 'opi_wms_007_mv'
            WHEN 'OPP' THEN 'opi_wms_008_mv'
            WHEN 'OPER' THEN 'opi_wms_009_mv'
	    WHEN 'OTP' THEN 'opi_ontime_prod_001_mv'
	    WHEN 'CPD' THEN 'opi_curr_prod_del_001_mv'
	    WHEN 'CURR_INV_EXP' THEN 'opi_dbi_curr_inv_exp_f'
            WHEN 'PROD_CONS' THEN 'opi_jobs_001_mv'
            WHEN 'COGS' THEN 'opi_cogs_001_mv'
            WHEN 'CURR_INV_STAT' THEN 'mtl_onhand_quantities'
	    WHEN 'SBR' THEN 'opi_scrap_reason_001_mv'
            ELSE ''
        END);

    RETURN l_mv_name;

END get_mv;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Setting up list of dimensions to track
/*++++++++++++++++++++++++++++++++++++++++*/
/*  init_dim_map

    Initialize the dimension map with all needed dimensions.

    This function needs to keep track of all possible dimensions
    the DBI 6.0 reports are interested in. The POA utility package
    get_parameter_values functions looks at the parameter table
    passed in by PMV. For parameters names for which it finds a
    matching key in this dimension map table, it records the value.
    In other words, if the dimension map does not have an entry for
    ORGANIZATION+ORGANIZATION, then PMV's organization parameter
    will never be recorded.

    For OPI's DBI 6.0, the needed dimensions levels are:
    Organization+Organization
    Item+Eni_item_inv_cat
    Item+Eni_item_org

    For 7.0, The following dimension levels are added:
    Organization+Organization_subinventory
    OPI_INV_CC+OPI_INV_CC_LVL
    OPI_INV_CC+OPI_INV_CC_CLS_LVL

    For Product Cost Management DBI 7.0 following dimensions are added
    ITEM+ENI_ITEM_VBH_CAT - Product Category
    CUSTOMER+FII_CUSTOMERS - Customers

    DBI 7.1 - For Warehouse Management add following dimensions
    OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL
    OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL

    DBI 12.0 - For Current Inventory Status report
    ORGANIZATION+OPI_SUB_LOCATOR_LVL

    DBI 8.0 - For Scrap By Reason Report
    OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL
*/
PROCEDURE init_dim_map (p_dim_map out NOCOPY
                            poa_dbi_util_pkg.poa_dbi_dim_map,
                        p_mv_set IN VARCHAR2)
IS

    l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

BEGIN

    -- Category dimension level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_INV_CAT');
    l_dim_rec.view_by_table := get_table ('ITEM+ENI_ITEM_INV_CAT');
    l_dim_rec.bmap := CATEGORY_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ITEM+ENI_ITEM_INV_CAT') := l_dim_rec;


    -- Item dimension level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_ORG');
    l_dim_rec.view_by_table := get_table ('ITEM+ENI_ITEM_ORG');
    l_dim_rec.bmap := ITEM_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ITEM+ENI_ITEM_ORG') := l_dim_rec;


    -- Organzation dimension level
    l_dim_rec.col_name := get_col_name ('ORGANIZATION+ORGANIZATION');
    l_dim_rec.view_by_table := get_table('ORGANIZATION+ORGANIZATION');
    l_dim_rec.bmap := ORG_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+ORGANIZATION') := l_dim_rec;

    -- Resource dimension level
    l_dim_rec.col_name := get_col_name ('RESOURCE+ENI_RESOURCE');
    l_dim_rec.view_by_table := get_table('RESOURCE+ENI_RESOURCE');
    l_dim_rec.bmap := RES_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('RESOURCE+ENI_RESOURCE') := l_dim_rec;

    -- Resource Group dimension level
    l_dim_rec.col_name := get_col_name ('RESOURCE+ENI_RESOURCE_GROUP');
    l_dim_rec.view_by_table := get_table('RESOURCE+ENI_RESOURCE_GROUP');
    l_dim_rec.bmap := RES_GRP_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('RESOURCE+ENI_RESOURCE_GROUP') := l_dim_rec;

    -- Resource Department dimension level
    l_dim_rec.col_name := get_col_name ('RESOURCE+ENI_RESOURCE_DEPARTMENT');
    l_dim_rec.view_by_table := get_table('RESOURCE+ENI_RESOURCE_DEPARTMENT');
    l_dim_rec.bmap := RES_DEPT_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('RESOURCE+ENI_RESOURCE_DEPARTMENT') := l_dim_rec;

    -- Subinventory Dimension level
    l_dim_rec.col_name :=
            get_col_name ('ORGANIZATION+ORGANIZATION_SUBINVENTORY');
    l_dim_rec.view_by_table :=
            get_table('ORGANIZATION+ORGANIZATION_SUBINVENTORY');
    l_dim_rec.bmap := ORG_SUB_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+ORGANIZATION_SUBINVENTORY') := l_dim_rec;

    -- Cycle Count Header dimension level
    l_dim_rec.col_name := get_col_name ('OPI_INV_CC+OPI_INV_CC_LVL');
    l_dim_rec.view_by_table := get_table('OPI_INV_CC+OPI_INV_CC_LVL');
    l_dim_rec.bmap := CYCLE_COUNT_HEADER_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_INV_CC+OPI_INV_CC_LVL') := l_dim_rec;

    -- Cycle Count Class dimension level
    l_dim_rec.col_name := get_col_name ('OPI_INV_CC+OPI_INV_CC_CLS_LVL');
    l_dim_rec.view_by_table := get_table('OPI_INV_CC+OPI_INV_CC_CLS_LVL');
    l_dim_rec.bmap := CYCLE_COUNT_CLASS_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_INV_CC+OPI_INV_CC_CLS_LVL') := l_dim_rec;

    -- Product Category Dimension Level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_VBH_CAT');
    l_dim_rec.view_by_table := get_table('ITEM+ENI_ITEM_VBH_CAT');
    --l_dim_rec.bmap := RES_DEPT_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ITEM+ENI_ITEM_VBH_CAT') := l_dim_rec;


    -- Customer dimension level
    l_dim_rec.col_name := get_col_name ('CUSTOMER+FII_CUSTOMERS');
    l_dim_rec.view_by_table := get_table('CUSTOMER+FII_CUSTOMERS');
    --l_dim_rec.bmap := RES_DEPT_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('CUSTOMER+FII_CUSTOMERS') := l_dim_rec;

    -- Reason Code Dimension Level
    l_dim_rec.col_name := get_col_name ('OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL');
    l_dim_rec.view_by_table := get_table('OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL');
    l_dim_rec.bmap := REASON_CODE_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL') := l_dim_rec;

     -- Operation Plan Name Dimension Level
    l_dim_rec.col_name := get_col_name ('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL');
    l_dim_rec.view_by_table := get_table('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL');
    l_dim_rec.bmap := OP_PLAN_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL') := l_dim_rec;

    -- Locator Dimension Level
    l_dim_rec.col_name := get_col_name ('ORGANIZATION+OPI_SUB_LOCATOR_LVL');
    l_dim_rec.view_by_table := get_table ('ORGANIZATION+OPI_SUB_LOCATOR_LVL');
    l_dim_rec.bmap := LOCATOR_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+OPI_SUB_LOCATOR_LVL') := l_dim_rec;

    -- Item Grade dimension level
    l_dim_rec.col_name := get_col_name ('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL');
    l_dim_rec.view_by_table := get_table ('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL');
    l_dim_rec.bmap := ITEM_GRADE_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL') := l_dim_rec;

    -- Item Lot dimension level
    l_dim_rec.col_name := get_col_name ('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL');
    l_dim_rec.view_by_table := get_table ('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL');
    l_dim_rec.bmap := ITEM_LOT_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL') := l_dim_rec;

    -- Transaction Reason Dimension Level
    l_dim_rec.col_name := get_col_name ('OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL');
    l_dim_rec.view_by_table := get_table('OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL');
    l_dim_rec.bmap := TRX_REASON_BMAP;
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL') := l_dim_rec;


    -- Exceptions

    -- For the WMS Current Capacity subinventory query, do not
    -- include the Item and Category as part of the where clause
    -- since those two dimensions are not part of the subinventory
    -- capacity table.
    IF (p_mv_set = 'WMS_CURR_UTZ_SUB') THEN
        p_dim_map(C_DIMNAME_ITEM).generate_where_clause := 'N';
        p_dim_map(C_DIMNAME_INV_CAT).generate_where_clause := 'N';
    END IF;

    -- For Current Inventory Status, do not include the Item Category
    -- and organization where clause as they are display only parameters.
    IF (p_mv_set = 'CURR_INV_STAT') THEN
        p_dim_map(C_DIMNAME_ORG).generate_where_clause := 'N';
        p_dim_map(C_DIMNAME_INV_CAT).generate_where_clause := 'N';
    END IF;

END init_dim_map;


/*++++++++++++++++++++++++++++++++++++++++++++*/
/* Reinitialize the column name in the dim_map
/*++++++++++++++++++++++++++++++++++++++++++++*/
/*
This Function is called from process_parameters if the p_mv_set is related to
Product Gross Margin. If the MV determined by select_mv is the Inline View the
column name is parent_id
*/
PROCEDURE reinit_dim_map (p_dim_map in out  NOCOPY
                            poa_dbi_util_pkg.poa_dbi_dim_map,
                        p_mv IN VARCHAR2,
                        p_mv_set IN VARCHAR2)
IS

    l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;
BEGIN
    IF (p_mv <> 'OPI_PGM_SUM_MV' AND p_mv <> 'OPI_PGM_CAT_MV' AND p_mv_set = 'PGM') THEN
        l_dim_rec := p_dim_map('ITEM+ENI_ITEM_VBH_CAT');
        l_dim_rec.col_name := 'parent_id';
        p_dim_map('ITEM+ENI_ITEM_VBH_CAT') := l_dim_rec;
    END IF;
END reinit_dim_map;

/*++++++++++++++++++++++++++++++++++++++++*/
/* Dimension level join tables and columns
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_col_name

    Get the column name of the viewby join tables that the query will
    have to join to.


  DBI 7.0 Changes for Cycle Count Reports
    Cycle Count - Added cycle_count_header_id
    Cycle Count Class - Added cycle_count_class_id

  DBI 7.0 Changes for Product Cost Management: Product Gross Margin Reports
    ITEM+ENI_ITEM_VBH_CAT - item_category_id
    CUSTOMER+FII_CUSTOMERS - customer_id

  DBI 7.1 - For Warehouse Management add following dimensions
    OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL
    OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL

  DBI 12.0 - For Current Inventory Status
    ORGANIZATION+OPI_SUB_LOCATOR_LVL
    OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL
    OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL

  DBI 8.0 - For Scrap By Reason Report
    OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL

*/
FUNCTION get_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2
IS

  l_col_name VARCHAR2(100);

BEGIN

  l_col_name :=
    (CASE p_dim_name
        WHEN 'ORGANIZATION+ORGANIZATION' THEN 'organization_id'
        WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN 'inv_category_id'
        WHEN 'ITEM+ENI_ITEM_ORG' THEN 'item_org_id'
        WHEN 'RESOURCE+ENI_RESOURCE' THEN 'resource_org_id'
        WHEN 'RESOURCE+ENI_RESOURCE_GROUP' THEN 'resource_group_id'
        WHEN 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN 'resource_department_id'
    WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN 'subinventory_code'
        WHEN 'OPI_INV_CC+OPI_INV_CC_LVL' THEN 'cycle_count_header_id'
        WHEN 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' THEN 'cycle_count_class_id'
        WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN 'item_category_id'
        WHEN 'CUSTOMER+FII_CUSTOMERS' THEN 'customer_id'
        WHEN 'OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL'
            THEN 'reason_id'
        WHEN 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL'
            THEN 'operation_plan_id'
	WHEN 'ORGANIZATION+OPI_SUB_LOCATOR_LVL' THEN 'locator_id'
        WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' THEN 'grade_code'
        WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' THEN 'lot_number'
	WHEN 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL'
            THEN 'scrap_reason_id'
        ELSE ''
    END);

  RETURN l_col_name;

END get_col_name;

/*  get_table

    Return the join table based on the dimension

    DBI 7.0 Changes for Cycle Count Reports
        Cycle Count - opi_inv_cc_lvl_v
        Cycle Count Class - opi_inv_cc_lvl_v

    DBI 7.0 Changes for Product Cost Management Reports
        Product Category - eni_item_vbh_cat_v
        Customer - fii_customers_v

    DBI 7.1 - For Warehouse Management add following
        Exception Reason Code - opi_wms_task_exc_reasons_lvl_v
        Operation Plan - opi_wms_op_plan_name_lvl_v

    DBI 12.0 - For Current Inventory Status add following:
        Locator - OPI_LOCATORS_V

    DBI 8.0 - For Scrap By Reason Report
        Transaction Reason - OPI_MFG_MTL_TRX_REASONS_LVL_V
*/
FUNCTION get_table (p_dim_name VARCHAR2)
    RETURN VARCHAR2
IS
    l_table VARCHAR2(4000);

BEGIN

    l_table :=
        (CASE p_dim_name
            WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN 'eni_item_inv_cat_v'
            WHEN 'ITEM+ENI_ITEM_ORG' THEN 'eni_item_org_v '
            WHEN 'ORGANIZATION+ORGANIZATION' THEN '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG''))'
            WHEN 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
                'eni_resource_department_v'
            WHEN 'RESOURCE+ENI_RESOURCE_GROUP' THEN 'eni_resource_group_v'
            WHEN 'RESOURCE+ENI_RESOURCE' THEN 'eni_resource_v'
        WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN 'opi_subinventories_v'
            WHEN 'OPI_INV_CC+OPI_INV_CC_LVL' THEN 'opi_inv_cc_lvl_v'
            WHEN 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' THEN 'opi_inv_cc_cls_v'
            --WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN 'eni_item_vbh_cat_v'
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN 'eni_item_vbh_nodes_v'
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN 'fii_customers_v'
            WHEN 'OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL' THEN
                'opi_wms_task_exc_reasons_lvl_v'
            WHEN 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' THEN
                'opi_wms_op_plan_name_lvl_v'
	    WHEN 'ORGANIZATION+OPI_SUB_LOCATOR_LVL' THEN
                'opi_locators_v'
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' THEN
                'opi_inv_item_grade_lvl_v'
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' THEN
                'opi_inv_item_lot_lvl_v'
	    WHEN 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL' THEN
                'opi_mfg_mtl_trx_reasons_lvl_v'
            ELSE ''
        END);

    RETURN l_table;

END get_table;

/*  Function: get_join_info
    DBI 7.0 Changes for Cycle Count Reports
    1.  Cycle Count and Cycle Count Class to l_join_rec.column_name
    2.  Add 'CCAD' to get join info for UOM

    DBI 7.0 Changes for Product Cost Management: Product Gross Margin Reports
    1.  Add Product Category and Customer dimension to l_join_rec.column_name
    2.  Add 'PGM' to get join info for UOM
*/
PROCEDURE get_join_info (p_view_by IN varchar2,
                         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
                         x_join_tbl OUT NOCOPY
                            poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                         p_mv_set IN VARCHAR2)
IS
    l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;

BEGIN

    -- reinitialize the join table
    x_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

    -- If the view by column is not in the bitmap, then
    -- there is nothing to join to. Can this ever be true?
    IF (NOT p_dim_map.exists(p_view_by)) THEN
        RETURN;
    END IF;

    -- Otherwise, join to a table
    -- The view by table
    l_join_rec.table_name := p_dim_map(p_view_by).view_by_table;
    l_join_rec.table_alias := 'v';
    -- the fact column to join to
    l_join_rec.fact_column := p_dim_map(p_view_by).col_name;

    -- depending on the dimension level, select the appropriate
    -- join table column name
    l_join_rec.column_name :=
    (CASE p_view_by
        WHEN 'ORGANIZATION+ORGANIZATION' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_ORG' THEN
             'id'
        WHEN 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
             'id'
        WHEN 'RESOURCE+ENI_RESOURCE_GROUP' THEN
             'id'
        WHEN 'RESOURCE+ENI_RESOURCE' THEN
             'id'
        WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
             'id'
        WHEN 'OPI_INV_CC+OPI_INV_CC_LVL' THEN
             'id'
        WHEN 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
             'id'
        WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
             'id'
        WHEN 'OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL' THEN
             'id'
        WHEN 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' THEN
             'id'
	WHEN 'ORGANIZATION+OPI_SUB_LOCATOR_LVL' THEN
             'id'
        WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' THEN
             'id'
        WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' THEN
             'id'
	WHEN 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL' THEN
	     'id'
        ELSE
             ''
    END);

    l_join_rec.dim_outer_join :=
    (CASE p_view_by

        WHEN 'ORGANIZATION+ORGANIZATION' THEN
             'N'
        WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
             'N'
        WHEN 'ITEM+ENI_ITEM_ORG' THEN
             'N'
        ELSE
             'N'
    END);

    IF ( (p_view_by = 'ITEM+ENI_ITEM_VBH_CAT')  AND p_mv_set = 'PGM') THEN
        l_join_rec.additional_where_clause := 'v.parent_id = v.child_id';
    END IF;
    -- Add the join table
    x_join_tbl.extend;
    x_join_tbl(x_join_tbl.count) := l_join_rec;

    -- Get the uom join
    IF ( (p_view_by = 'ITEM+ENI_ITEM_ORG') AND
         ((p_mv_set = 'SCR') OR (p_mv_set = 'CUV') OR (p_mv_set = 'ONH') OR
         (p_mv_set = 'INT') OR (p_mv_set = 'MCV') OR (p_mv_set = 'PGM') OR
         (p_mv_set = 'CCAD') OR (p_mv_set = 'RTX') OR
         (p_mv_set = 'RTP') OR (p_mv_set = 'WMS_CURR_UTZ_SUB') OR
         (p_mv_set = 'WMS_CURR_UTZ_ITEM') OR (p_mv_set = 'OTP') OR
         (p_mv_set = 'CPD') OR (p_mv_set = 'WMS_STOR_UTZ') OR
         (p_mv_set = 'CURR_INV_EXP') OR
         (p_mv_set = 'INV_VAL_UOM') OR
         (p_mv_set = 'PROD_CONS') OR
         (p_mv_set = 'COGS') ) ) THEN
        l_join_rec.table_name := 'mtl_units_of_measure_vl';
        l_join_rec.table_alias := 'v2';
        l_join_rec.fact_column :='uom_code';
        l_join_rec.column_name := 'uom_code';
        l_join_rec.dim_outer_join := 'N';

        x_join_tbl.extend;
        x_join_tbl(x_join_tbl.count) := l_join_rec;
    END IF;

    -- The UOM join for Current Inventory Status is special
    IF (p_mv_set = 'CURR_INV_STAT') THEN
    -- {
        l_join_rec.table_name := 'mtl_units_of_measure_vl';
        l_join_rec.table_alias := 'v2';
        l_join_rec.fact_column :='primary_uom_code';
        l_join_rec.column_name := 'uom_code';
        l_join_rec.dim_outer_join := 'N';

        x_join_tbl.extend;
        x_join_tbl(x_join_tbl.count) := l_join_rec;

        l_join_rec.table_name := 'mtl_units_of_measure_vl';
        l_join_rec.table_alias := 'v3';
        l_join_rec.fact_column :='secondary_uom_code';
        l_join_rec.column_name := 'uom_code';
        l_join_rec.dim_outer_join := 'Y';

        x_join_tbl.extend;
        x_join_tbl(x_join_tbl.count) := l_join_rec;

    -- }
    END IF;

END get_join_info;


/*++++++++++++++++++++++++++++++++++++++++*/
/* View by information for outer queries
/*++++++++++++++++++++++++++++++++++++++++*/
/*
    For the status_sql, get the name of the viewby column.
*/
FUNCTION get_view_by_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2
IS
  l_col_name VARCHAR2(60);
BEGIN

    l_col_name :=
        (CASE p_dim_name
            WHEN 'ORGANIZATION+ORGANIZATION' THEN
                ' v.value'
            WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
                ' v.value'
            WHEN 'ITEM+ENI_ITEM_ORG' THEN
                ' v.value'
            WHEN 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
                ' decode(v.value, NULL, ''Unassigned'', v.value)'
            WHEN 'RESOURCE+ENI_RESOURCE_GROUP' THEN
                ' decode(v.value, NULL, ''Unassigned'', v.value)'
            WHEN 'RESOURCE+ENI_RESOURCE' THEN
                ' decode(v.value, NULL, ''Unassigned'', v.value)'
            WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
                ' decode(v.value, NULL, ''Unassigned'', v.value)'
            WHEN 'OPI_INV_CC+OPI_INV_CC_LVL' THEN
                 'v.value'
            WHEN 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' THEN
                 'v.value'
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
                ' v.value'
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
                ' v.value'
            WHEN 'OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL' THEN
                 ' v.value'
            WHEN 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' THEN
                ' v.value'
	    WHEN 'ORGANIZATION+OPI_SUB_LOCATOR_LVL' THEN
                ' v.value'
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' THEN
                ' v.value'
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' THEN
                ' v.value'
	    WHEN 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL' THEN
	        'v.value'
            ELSE ' '
        END);

    RETURN l_col_name;
END get_view_by_col_name;

FUNCTION get_viewby_select_clause (p_viewby IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_viewby_sel VARCHAR2(200) := '';
    l_view_by_col VARCHAR2 (100) := '';
BEGIN

    l_view_by_col := get_view_by_col_name (p_viewby);

    l_viewby_sel :=
        (CASE p_viewby
            WHEN 'ORGANIZATION+ORGANIZATION' THEN
                 l_view_by_col || ' VIEWBY,
                 v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
                 l_view_by_col || ' VIEWBY,
                  v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_ORG' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'RESOURCE+ENI_RESOURCE_GROUP' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'RESOURCE+ENI_RESOURCE' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_INV_CC+OPI_INV_CC_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
             l_view_by_col || ' VIEWBY,
                  v.id VIEWBYID, '
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
             l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_WMS_TASK_EXC_REASONS+OPI_WMS_TASK_EXC_REASONS_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
	    WHEN 'ORGANIZATION+OPI_SUB_LOCATOR_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_GRADE_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'OPI_INV_ITEM_ATTRIB+OPI_INV_ITEM_LOT_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
	    WHEN 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            ELSE ''
        END);

    return l_viewby_sel;

END get_viewby_select_clause;

/*++++++++++++++++++++++++++++++++++++++++*/
/* MV level aggregation flag
/*++++++++++++++++++++++++++++++++++++++++*/

/*  get_mv_level_flag

    Return the MV level flag based on what is requested in p_mv_flag_type:
    'ITEM_CAT' - Scrap or material usage need item_cat_flag.

    DBI 7.0 Changes for Cycle Count Reports
        CCA_LEVEL - Cycle Count

    DBI 7.0 Changes for Product Cost Management: Product Gross Margin Reports
        PRD_CUST - Product Gross Margin Report: Product Category + Customer grouping

    DBI 7.1 Changes for Receipt to Putaway Cycle Time Rack for WMS

    mochawla - DBI 7.1 changes for Pick and OP Exceptions
        WMS_PEX - Pick Exceptions
        WMS_PER - Pick Exceptions by Reason
        WMS_OPP - OP Performance
        WMS_OPER- OP Exceptions by Reason
*/
FUNCTION get_mv_level_flag (p_mv_flag_type VARCHAR2,
                            p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_mv_level_flag VARCHAR2 (10) := '';

BEGIN

    l_mv_level_flag :=
        (CASE p_mv_flag_type
            WHEN  'ITEM_CAT' THEN
                get_item_flag_val (p_dim_name, p_dim_map)
            WHEN 'RESOURCE_LEVEL' THEN
                get_resource_level_flag_val (p_dim_name, p_dim_map)
            WHEN 'INV_VAL_LEVEL' THEN
                get_inv_val_aggr_flag (p_dim_name, p_dim_map)
	    WHEN 'INV_VAL_UOM_LEVEL' THEN
                -- Same as 'INV_VAL_LEVEL'
                get_inv_val_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'CCA_LEVEL' THEN
                get_cca_level_flag_val (p_dim_name, p_dim_map)
            WHEN 'PRD_CUST' THEN
                 get_prodcat_cust_flag_val(p_dim_name, p_dim_map)
            WHEN 'WMS_RTX' THEN
                 get_wms_rtx_aggr_flag(p_dim_name, p_dim_map)
            WHEN 'WMS_RTP' THEN
                 get_wms_rtp_aggr_flag(p_dim_name, p_dim_map)
            WHEN 'WMS_CURR_UTZ_ITEM_LEVEL' THEN
                get_wms_c_utz_item_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'WMS_CURR_UTZ_SUB_LEVEL' THEN
                get_wms_c_utz_sub_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'WMS_STOR_UTZ_LEVEL' THEN
                get_wms_stor_utz_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'WMS_PEX' THEN
                get_wms_pex_aggr_flag(p_dim_name, p_dim_map)
            WHEN 'WMS_PER' THEN
                 get_wms_per_aggr_flag(p_dim_name, p_dim_map)
            WHEN 'WMS_OPP' THEN
                 get_wms_opp_aggr_flag(p_dim_name, p_dim_map)
            WHEN 'WMS_OPER' THEN
                 get_wms_oper_aggr_flag(p_dim_name, p_dim_map)
	    WHEN 'CURR_INV_EXP_LEVEL' THEN
                get_rollup1_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'PROD_CONS_LEVEL' THEN
                get_rollup1_aggr_flag (p_dim_name, p_dim_map)
            WHEN 'COGS_LEVEL' THEN
                get_rollup1_aggr_flag (p_dim_name, p_dim_map)
	    WHEN 'TRX_REASON_LEVEL' THEN
                 get_trx_reason_aggr_flag(p_dim_name, p_dim_map)
            ELSE
                ''
        END);

    RETURN l_mv_level_flag;

END get_mv_level_flag;


/*  get_resource_level_flag_val

    Compute the item_cat_flag value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_resource_level_flag_val (p_dim_name IN VARCHAR2,
                                      p_dim_map IN
                                      poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_resource_level_flag varchar2(1) := '0';

    l_org_val VARCHAR2 (120) := NULL;
    l_res_val VARCHAR2 (120) := NULL;
    l_res_group_val VARCHAR2 (120) := NULL;
    l_dept_val VARCHAR2 (120) := NULL;

BEGIN

    -- Get the org, item and cat values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('RESOURCE+ENI_RESOURCE')) THEN
        l_res_val := p_dim_map ('RESOURCE+ENI_RESOURCE').value;
    END IF;

    IF (p_dim_map.exists ('RESOURCE+ENI_RESOURCE_GROUP')) THEN
        l_res_group_val := p_dim_map ('RESOURCE+ENI_RESOURCE_GROUP').value;
    END IF;

    IF (p_dim_map.exists ('RESOURCE+ENI_RESOURCE_DEPARTMENT')) THEN
        l_dept_val := p_dim_map ('RESOURCE+ENI_RESOURCE_DEPARTMENT').value;
    END IF;


    CASE
        WHEN p_dim_name = 'ORGANIZATION+ORGANIZATION' THEN
            BEGIN
                IF l_res_val IS NULL OR
                   l_res_val  = '' OR
                   l_res_val = 'All' THEN
                    IF l_dept_val IS NULL OR
                       l_dept_val = '' OR
                       l_dept_val = 'All' THEN
                        IF l_res_group_val IS NULL OR
                           l_res_group_val = '' OR
                           l_res_group_val = 'All' THEN
                           l_resource_level_flag := '7';
                        ELSE
                            l_resource_level_flag := '3';
                        END IF;
                    ELSIF l_res_group_val IS NULL OR
                          l_res_group_val = '' OR
                          l_res_group_val = 'All' THEN
                          l_resource_level_flag := '5';
                    END IF;
                END IF;
            END;

        WHEN p_dim_name = 'RESOURCE+ENI_RESOURCE_GROUP' THEN
            BEGIN
                IF l_res_val IS NULL OR
                   l_res_val  = '' OR
                   l_res_val = 'All' THEN
                    IF l_dept_val IS NULL OR
                       l_dept_val = '' OR
                       l_dept_val = 'All' THEN
                       l_resource_level_flag := '3';
                    END IF;
                END IF;
            END;

        WHEN p_dim_name = 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
            BEGIN
                IF l_res_val IS NULL OR
                   l_res_val  = '' OR
                   l_res_val = 'All' THEN
                    IF l_res_group_val IS NULL OR
                       l_res_group_val = '' OR
                       l_res_group_val = 'All' THEN
                       l_resource_level_flag := '5';
                   END IF;
                END IF;
            END;
        WHEN p_dim_name = 'RESOURCE+ENI_RESOURCE' THEN
            BEGIN
                l_resource_level_flag := '0';
            END;
        ELSE
            BEGIN
                IF l_res_val IS NULL OR
                   l_res_val  = '' OR
                   l_res_val = 'All' THEN
                    IF l_dept_val IS NULL OR
                       l_dept_val = '' OR
                       l_dept_val = 'All' THEN
                        IF l_res_group_val IS NULL OR
                           l_res_group_val = '' OR
                           l_res_group_val = 'All' THEN
                           l_resource_level_flag := '7';
                        ELSE
                            l_resource_level_flag := '3';
                        END IF;
                    ELSIF l_res_group_val IS NULL OR
                          l_res_group_val = '' OR
                          l_res_group_val = 'All' THEN
                          l_resource_level_flag := '5';
                    END IF;
                END IF;
            END;
    END CASE;

    RETURN l_resource_level_flag;

END get_resource_level_flag_val;


/* get_item_flag_val

    Compute the item_cat_flag value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_item_flag_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_item_flag varchar2(1);

    l_org_val VARCHAR2 (120) := NULL;
    l_cat_val VARCHAR2 (120) := NULL;
    l_item_val VARCHAR2 (120) := NULL;

BEGIN

    -- Get the org, item and cat values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;


    CASE
        WHEN p_dim_name = 'ORGANIZATION+ORGANIZATION' THEN
            BEGIN
                IF l_item_val IS NULL OR
                   l_item_val  = '' OR
                   l_item_val = 'All' THEN
                    IF l_cat_val IS NULL OR
                       l_cat_val = '' OR
                       l_cat_val = 'All' THEN

                        l_item_flag := '3';
                    ELSE
                        l_item_flag := '1';
                    END IF;
                ELSE
                    l_item_flag := '0';
                END IF;
            END;
        WHEN p_dim_name = 'ITEM+ENI_ITEM_INV_CAT' THEN
            BEGIN
                IF l_item_val IS NULL OR
                   l_item_val  = '' OR
                   l_item_val = 'All' THEN
                    l_item_flag := '1';
               ELSE
                  l_item_flag := '0';
               END IF;
            END;
        WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN l_item_flag := '0';
        ELSE
            BEGIN
                IF l_item_val is null or l_item_val  = '' or
                   l_item_val = 'All' THEN
                    IF l_cat_val is null or l_cat_val = '' or
                       l_cat_val = 'All'THEN
                        l_item_flag := '3';
                    ELSE
                        l_item_flag := '1';
                    END IF;
               ELSE
                     l_item_flag := '0';
               END IF;
            END;
    END CASE;

    RETURN l_item_flag;

END get_item_flag_val;


/* get_inv_val_aggr_flag

    Compute the item_cat_flag value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_inv_val_aggr_flag (p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_item_flag varchar2(1) := NULL;
    l_grouping_level NUMBER := 0;

    l_org_val VARCHAR2 (4000) := NULL;
    l_cat_val VARCHAR2 (4000) := NULL;
    l_item_val VARCHAR2 (4000) := NULL;
    l_sub_val VARCHAR2 (4000) := NULL;

    -- Grouping IDs for the various dimensions
    ITEM_GROUPING_ID CONSTANT INTEGER := 1;
    CAT_GROUPING_ID CONSTANT INTEGER := 2;
    SUB_GROUPING_ID CONSTANT INTEGER := 4;


BEGIN

    -- Get the org, item and cat values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
        l_sub_val :=
            p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;


    -- if the view by is item level, or specific item is specified, go to
    -- level 0
    IF p_dim_name = 'ITEM+ENI_ITEM_ORG' OR
       NOT (l_item_val IS NULL OR
            l_item_val = 'All' ) THEN
        l_grouping_level := 0;
    ELSE

        -- we can at least use rows grouped at the item level
        l_grouping_level := l_grouping_level + ITEM_GROUPING_ID;

        -- If the viewby is not subinventory and no specific sub is specified,
        -- we can use rows that roll up sub
        IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
           (l_sub_val IS NULL OR
                    l_sub_val = 'All') THEN
            l_grouping_level := l_grouping_level + SUB_GROUPING_ID;
        END IF;

        -- If the viewby is not category and no specific cat is specified,
        -- we can use rows that roll up sub
        IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
           (l_cat_val IS NULL OR
                    l_cat_val = 'All') THEN
            l_grouping_level := l_grouping_level + CAT_GROUPING_ID;
        END IF;

    END IF;

    RETURN to_char (l_grouping_level);

END get_inv_val_aggr_flag;

FUNCTION get_wms_rtx_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_item_flag varchar2(1) := NULL;
    l_grouping_level NUMBER := 0;
    l_org_val VARCHAR2 (4000) := NULL;
    l_cat_val VARCHAR2 (4000) := NULL;
    l_item_val VARCHAR2 (4000) := NULL;
    l_sub_val VARCHAR2 (4000) := NULL;

BEGIN
    -- Get the org, item, subinventory and category values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
        l_sub_val :=
            p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    /* if item, subinventory or category dimensions are needed, use level 0
     * otherwise use level 3 */
    if p_dim_name = 'ITEM+ENI_ITEM_ORG' or
       p_dim_name = 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' or
       p_dim_name = 'ITEM+ENI_ITEM_INV_CAT' or
       not ( l_cat_val is null or l_cat_val = 'All' ) or
       not ( l_item_val is null or l_item_val = 'All' ) or
       not ( l_sub_val is null or l_sub_val = 'All' ) then
         l_grouping_level := 0;
    else
        l_grouping_level := 3;
    end if;

    RETURN to_char (l_grouping_level);

END get_wms_rtx_aggr_flag;




FUNCTION get_wms_rtp_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_item_flag varchar2(1) := NULL;
    l_grouping_level NUMBER := 0;

    l_org_val VARCHAR2 (4000) := NULL;
    l_cat_val VARCHAR2 (4000) := NULL;
    l_item_val VARCHAR2 (4000) := NULL;
    l_sub_val VARCHAR2 (4000) := NULL;

    -- Grouping IDs for the various dimensions
    CAT_GROUPING_ID CONSTANT INTEGER := 3;
    SUB_GROUPING_ID CONSTANT INTEGER := 4;


BEGIN

    -- Get the org, item, subinventory and category values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
        l_sub_val :=
            p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;


    -- if the viewby is item or category, or specific item/category is selected,
    -- use level 0
    IF p_dim_name = 'ITEM+ENI_ITEM_ORG' OR
       NOT (l_item_val IS NULL OR l_item_val = 'All' )  OR
       p_dim_name='ITEM+ENI_ITEM_INV_CAT' OR
       NOT (l_cat_val IS NULL OR l_cat_val='All')
    THEN
        l_grouping_level := 0;
    -- If the viewby is subinventory or a specific subinventory is selected,
    -- use level 3
    ELSIF p_dim_name = 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' OR
          NOT (l_sub_val IS NULL OR l_sub_val = 'All')
    THEN
        l_grouping_level := 3;
    ELSE
    -- If we have come till here, the only dimension required is org
    -- so use level 7
        l_grouping_level := 7;
    END IF;

    RETURN to_char (l_grouping_level);

END get_wms_rtp_aggr_flag;


/*  DBI 7.0 Changes for Cycle Count
        Function:       get_cca_level_flag_val
        Description:    Calculates the best aggregation level for any combination
                        of user selected parameters
*/
FUNCTION get_cca_level_flag_val (p_dim_name IN VARCHAR2,
                                 p_dim_map  IN
                                 poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
    -- Aggregation Levels for the various dimensions
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 1;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 2;
    SUB_LEVEL_ID        CONSTANT   INTEGER := 4;
    CCS_LEVEL_ID        CONSTANT   INTEGER := 8;
    CC_LEVEL_ID         CONSTANT   INTEGER := 16;

    l_org_val           VARCHAR2 (120) := NULL;
    l_cch_val           VARCHAR2 (120) := NULL;
    l_cccs_val          VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_subinv_val        VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
            l_subinv_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('OPI_INV_CC+OPI_INV_CC_LVL')) THEN
            l_cch_val := p_dim_map ('OPI_INV_CC+OPI_INV_CC_LVL').value;
    END IF;

    IF (p_dim_map.exists ('OPI_INV_CC+OPI_INV_CC_CLS_LVL')) THEN
            l_cccs_val := p_dim_map ('OPI_INV_CC+OPI_INV_CC_CLS_LVL').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF p_dim_name <> 'OPI_INV_CC+OPI_INV_CC_LVL' AND
       (l_cch_val IS NULL OR
        l_cch_val = '' OR
        l_cch_val = 'All'
        )
    THEN
        l_in_bmap := l_in_bmap + CC_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_INV_CC+OPI_INV_CC_CLS_LVL' AND
       (l_cccs_val IS NULL OR
        l_cccs_val = '' OR
        l_cccs_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CCS_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
       (l_subinv_val IS NULL OR
        l_subinv_val = '' OR
        l_subinv_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + SUB_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 31;  /* org level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 29;  /* inv category */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 27;  /* subinv */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 15;  /* cycle count Header*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 7;   /* cycle count class */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;   /* item level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);
END get_cca_level_flag_val;


/*
     DBI 7.0 Changes for Product Cost Management: Product Gross Margin Reports
     Function:       get_prodcat_cust_flag_val
     Description:    Compute the prodcat_cust_flag value based on the parameters passed to
                 determine the aggregation level of the MV rows that the query will
                 have to run against.
*/
FUNCTION get_prodcat_cust_flag_val(p_dim_name IN VARCHAR2,
                              p_dim_map IN
                              poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_org_val VARCHAR2 (120) := NULL;
    l_cat_val VARCHAR2 (120) := NULL;
    l_item_val VARCHAR2 (120) := NULL;
    l_customer_val VARCHAR2 (120) := NULL;
    l_prodcat_cust_flag number := 0;

    l_agg_lvl_flag      NUMBER  := 0;
    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */

/*
C  P  I  Value
--------------
0  0  0  0
0  0  1  1
0  1  1  3
1  0  0  4
1  0  1  5
1  1  1  7
*/
    -- Aggregation Levels for the various dimensions
    ITEM_LEVEL_ID       CONSTANT   INTEGER :=   1;
    CAT_LEVEL_ID        CONSTANT   INTEGER :=   2;
    CUST_LEVEL_ID         CONSTANT   INTEGER := 4;


BEGIN
    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    -- Get the customer, cat and item values

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
        l_customer_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
    END IF;
--grouping_id(customer_id,nvl(item.vbh_category_id, -1),(item.inventory_item_id||''-''||item.organization_id))

    IF (p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND (l_item_val is NULL or l_item_val = 'All')) THEN
        l_prodcat_cust_flag := l_prodcat_cust_flag + ITEM_LEVEL_ID;
    END IF;

    IF (p_dim_name <> 'ITEM+ENI_ITEM_VBH_CAT' AND (l_cat_val is NULL or l_cat_val = 'All')) THEN
        l_prodcat_cust_flag := l_prodcat_cust_flag + CAT_LEVEL_ID;
    END IF;

    IF (p_dim_name <> 'CUSTOMER+FII_CUSTOMERS' AND (l_customer_val is NULL or l_customer_val = 'All')) THEN
        l_prodcat_cust_flag := l_prodcat_cust_flag + CUST_LEVEL_ID;
    END IF;


    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 7;  /* Customer, Category, Item */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 5;  /* Category */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 4;  /* Category, Item */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 3;  /* Customer */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 1;   /* Customer, Category */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;   /* Customer, Category, Item */

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_prodcat_cust_flag);
    RETURN to_char(l_agg_lvl_flag);

END get_prodcat_cust_flag_val;


/*  get_wms_c_utz_item_aggr_flag*/
FUNCTION get_wms_c_utz_item_aggr_flag (p_dim_name VARCHAR2,
                                       p_dim_map IN
                                        poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
    l_grouping_level NUMBER;

    l_org_val VARCHAR2 (4000);
    l_cat_val VARCHAR2 (4000);
    l_item_val VARCHAR2 (4000);
    l_sub_val VARCHAR2 (4000);

    -- The aggregation flag values
    L_ITEM_LEVEL CONSTANT NUMBER := 0;
    L_SUB_CAT_LEVEL CONSTANT NUMBER := 1;
    L_ORG_LEVEL CONSTANT NUMBER := 7;

BEGIN

    -- Initialization block
    l_grouping_level := NULL;
    l_org_val := NULL;
    l_cat_val := NULL;
    l_item_val := NULL;
    l_sub_val := NULL;

    -- Get the org, sub, item and cat values
    IF (p_dim_map.exists (C_DIMNAME_ORG)) THEN
        l_org_val := p_dim_map (C_DIMNAME_ORG).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_INV_CAT)) THEN
        l_cat_val := p_dim_map (C_DIMNAME_INV_CAT).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_ITEM)) THEN
        l_item_val := p_dim_map (C_DIMNAME_ITEM).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_SUB)) THEN
        l_sub_val :=
            p_dim_map (C_DIMNAME_SUB).value;
    END IF;

    -- Compute the correct flag value
    IF p_dim_name = C_VIEWBY_ITEM OR
       NOT (l_item_val IS NULL OR
            l_item_val = C_ALL) THEN

        -- if the view by is item level, or specific item is specified, go to
        -- level 0
        l_grouping_level := L_ITEM_LEVEL;

    ELSIF p_dim_name = C_VIEWBY_INV_CAT OR
          p_dim_name = C_VIEWBY_SUB OR
          NOT (l_cat_val IS NULL OR l_cat_val = C_ALL) OR
          NOT (l_sub_val IS NULL OR l_sub_val = C_ALL) THEN
        -- if the view by is sub/cat level, or specific sub/cat
        -- is specified, go to level 1
        l_grouping_level := L_SUB_CAT_LEVEL;

    ELSE
        -- The viewby is org, and at the most only org parameter values
        -- are specified.
        l_grouping_level := L_ORG_LEVEL;
    END IF;

    return to_char (l_grouping_level);

END get_wms_c_utz_item_aggr_flag;

/*  get_wms_c_utz_sub_aggr_flag*/
FUNCTION get_wms_c_utz_sub_aggr_flag (p_dim_name VARCHAR2,
                                      p_dim_map IN
                                       poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
    l_grouping_level NUMBER;

    l_org_val VARCHAR2 (4000);
    l_sub_val VARCHAR2 (4000);

    -- The aggregation flag values
    L_SUB_LEVEL CONSTANT NUMBER := 1;
    L_ORG_LEVEL CONSTANT NUMBER := 7;

BEGIN

    -- Initialization block
    l_grouping_level := NULL;
    l_org_val := NULL;
    l_sub_val := NULL;

    -- Get the org, sub, item and cat values
    IF (p_dim_map.exists (C_DIMNAME_ORG)) THEN
        l_org_val := p_dim_map (C_DIMNAME_ORG).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_SUB)) THEN
        l_sub_val :=
            p_dim_map (C_DIMNAME_SUB).value;
    END IF;

    -- Compute the correct flag value
    IF p_dim_name = C_VIEWBY_SUB OR
       NOT (l_sub_val IS NULL OR
            l_sub_val = C_ALL) THEN

        -- if the view by is item level, or specific item is specified, go to
        -- level 0
        l_grouping_level := L_SUB_LEVEL;

    ELSE
        -- The viewby is org, and at the most only org parameter values
        -- are specified.
        l_grouping_level := L_ORG_LEVEL;

    END IF;

    return to_char (l_grouping_level);

END get_wms_c_utz_sub_aggr_flag;

/*  get_wms_stor_utz_aggr_flag*/
FUNCTION get_wms_stor_utz_aggr_flag (p_dim_name VARCHAR2,
                                     p_dim_map IN
                                       poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
    l_grouping_level NUMBER;

    l_org_val VARCHAR2 (4000);
    l_cat_val VARCHAR2 (4000);
    l_item_val VARCHAR2 (4000);
    l_sub_val VARCHAR2 (4000);

    -- The aggregation flag values
    L_ITEM_LEVEL CONSTANT NUMBER := 0;
    L_SUB_CAT_LEVEL CONSTANT NUMBER := 1;
    L_ORG_LEVEL CONSTANT NUMBER := 7;

BEGIN

    -- Initialization block
    l_grouping_level := NULL;
    l_org_val := NULL;
    l_cat_val := NULL;
    l_item_val := NULL;
    l_sub_val := NULL;

    -- Get the org, sub, item and cat values
    IF (p_dim_map.exists (C_DIMNAME_ORG)) THEN
        l_org_val := p_dim_map (C_DIMNAME_ORG).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_INV_CAT)) THEN
        l_cat_val := p_dim_map (C_DIMNAME_INV_CAT).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_ITEM)) THEN
        l_item_val := p_dim_map (C_DIMNAME_ITEM).value;
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_SUB)) THEN
        l_sub_val :=
            p_dim_map (C_DIMNAME_SUB).value;
    END IF;

    -- Compute the correct flag value
    IF p_dim_name = C_VIEWBY_ITEM OR
       NOT (l_item_val IS NULL OR
            l_item_val = C_ALL) THEN

        -- if the view by is item level, or specific item is specified, go to
        -- level 0
        l_grouping_level := L_ITEM_LEVEL;

    ELSIF p_dim_name = C_VIEWBY_INV_CAT OR
          p_dim_name = C_VIEWBY_SUB OR
          NOT (l_cat_val IS NULL OR l_cat_val = C_ALL) OR
          NOT (l_sub_val IS NULL OR l_sub_val = C_ALL) THEN
        -- if the view by is sub/cat level, or specific sub/cat
        -- is specified, go to level 1
        l_grouping_level := L_SUB_CAT_LEVEL;

    ELSE
        -- The viewby is org, and at the most only org parameter values
        -- are specified.
        l_grouping_level := L_ORG_LEVEL;
    END IF;

    return to_char (l_grouping_level);

END get_wms_stor_utz_aggr_flag;

/* Function:    get_wms_pex_aggr_flag
   Description: Compute best aggregation level of MV rows that the query
                will run against for any combination of report parameters
*/
FUNCTION get_wms_pex_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
  -- Aggregation Levels for the various dimensions
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 1;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 2;
    SUB_LEVEL_ID        CONSTANT   INTEGER := 4;

    l_org_val           VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_subinv_val        VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
            l_subinv_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
       (l_subinv_val IS NULL OR
        l_subinv_val = '' OR
        l_subinv_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + SUB_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 7;  /* org level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 3;  /* org sub category */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 1;  /* org sub inv cat level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;  /* Most Granular Level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);
END get_wms_pex_aggr_flag;

/* Function:    get_wms_per_aggr_flag
   Description: Compute best aggregation level of MV rows that the query
                will run against for any combination of report parameters
*/
FUNCTION get_wms_per_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
  -- Aggregation Levels for the various dimensions
    REASON_LEVEL_ID     CONSTANT   INTEGER := 1;
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 2;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 4;
    SUB_LEVEL_ID        CONSTANT   INTEGER := 8;

    l_org_val           VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_subinv_val        VARCHAR2 (120) := NULL;
    l_reason_val        VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
            l_subinv_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL')) THEN
            l_item_val := p_dim_map ('OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL').value;
    END IF;

    IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
       (l_subinv_val IS NULL OR
        l_subinv_val = '' OR
        l_subinv_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + SUB_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + REASON_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 14;  /* org reason code level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 6;  /* org sub reason level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 2;  /* org sub inv cat reason level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;  /* Most Granular Level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);
END get_wms_per_aggr_flag;

/* Function:    get_wms_opp_aggr_flag
   Description: Compute best aggregation level of MV rows that the query
                will run against for any combination of report parameters
*/
FUNCTION get_wms_opp_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
   -- Aggregation Levels for the various dimensions
    OP_LEVEL_ID         CONSTANT   INTEGER := 0;
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 2;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 4;
    SUB_LEVEL_ID        CONSTANT   INTEGER := 8;

    l_org_val           VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_subinv_val        VARCHAR2 (120) := NULL;
    l_op_val            VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
            l_subinv_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL')) THEN
            l_op_val := p_dim_map ('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL').value;
    END IF;

    IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
       (l_subinv_val IS NULL OR
        l_subinv_val = '' OR
        l_subinv_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + SUB_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' AND
       (l_op_val IS NULL OR
        l_op_val = '' OR
        l_op_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + OP_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 14;  /* org op plan level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 6;  /* org sub plan category */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 2;  /* org sub inv cat plan level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;  /* Most Granular Level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);

END get_wms_opp_aggr_flag;

/* Function:    get_wms_oper_aggr_flag
   Description: Compute best aggregation level of MV rows that the query
                will run against for any combination of report parameters
*/
FUNCTION get_wms_oper_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
  -- Aggregation Levels for the various dimensions
    REASON_LEVEL_ID     CONSTANT   INTEGER := 0;
    OP_LEVEL_ID         CONSTANT   INTEGER := 2;
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 4;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 8;
    SUB_LEVEL_ID        CONSTANT   INTEGER := 16;

    l_org_val           VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_subinv_val        VARCHAR2 (120) := NULL;
    l_op_val            VARCHAR2 (120) := NULL;
    l_reason_val        VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
            l_subinv_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL')) THEN
            l_op_val := p_dim_map ('OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL').value;
    END IF;

    IF (p_dim_map.exists ('OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL')) THEN
            l_reason_val := p_dim_map ('OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL').value;
    END IF;

    IF p_dim_name <> 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' AND
       (l_subinv_val IS NULL OR
        l_subinv_val = '' OR
        l_subinv_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + SUB_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_WMS_OP_PLAN+OPI_WMS_OP_PLAN_NAME_LVL' AND
       (l_op_val IS NULL OR
        l_op_val = '' OR
        l_op_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + OP_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_WMS_TASK_EXC_REASONS + OPI_WMS_TASK_EXC_REASONS_LVL' AND
       (l_reason_val IS NULL OR
        l_reason_val = '' OR
        l_reason_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + REASON_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 28;  /* org reason code level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 12;  /* org sub reason level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 4;  /* org sub inv cat reason level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;  /* Most Granular Level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);
END get_wms_oper_aggr_flag;

/* Standardize the rollup flag computation */
/*
    There are a distinct number of possible rollups possible
    along dimensions. Since many MVs use the same rollup
    and aggregation scheme, we're trying to reuse the flag
    computation code.

    The idea is that we will have the flag computed based on the
    rollup #:

    Rollup1: Organization - Inventory Category - Item

*/

/*  get_rollup1_aggr_flag
    Returns aggregation for rollup on:
    Org - Inv Cat - Item

*/
FUNCTION get_rollup1_aggr_flag (p_dim_name VARCHAR2,
                                p_dim_map IN
                                    poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
-- {
    l_grouping_level NUMBER;

    l_org_val VARCHAR2 (4000);
    l_cat_val VARCHAR2 (4000);
    l_item_val VARCHAR2 (4000);

    -- The aggregation flag values
    L_ITEM_LEVEL CONSTANT NUMBER := 0;
    L_CAT_LEVEL CONSTANT NUMBER := 1;
    L_ORG_LEVEL CONSTANT NUMBER := 3;
-- }
BEGIN
-- {
    -- Initialization block
    l_grouping_level := NULL;
    l_org_val := NULL;
    l_cat_val := NULL;
    l_item_val := NULL;

    -- Get the org, sub, item and cat values
    IF (p_dim_map.exists (C_DIMNAME_ORG)) THEN
    -- {
        l_org_val := p_dim_map (C_DIMNAME_ORG).value;
    -- }
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_INV_CAT)) THEN
    -- {
        l_cat_val := p_dim_map (C_DIMNAME_INV_CAT).value;
    -- }
    END IF;

    IF (p_dim_map.exists (C_DIMNAME_ITEM)) THEN
    -- {
        l_item_val := p_dim_map (C_DIMNAME_ITEM).value;
    -- }
    END IF;

    -- Compute the correct flag value
    IF p_dim_name = C_VIEWBY_ITEM OR
       NOT (l_item_val IS NULL OR
            l_item_val = C_ALL) THEN
    -- {
        -- if the view by is item level, or specific item is specified, go to
        -- level 0
        l_grouping_level := L_ITEM_LEVEL;
    -- }

    ELSIF p_dim_name = C_VIEWBY_INV_CAT OR
          NOT (l_cat_val IS NULL OR l_cat_val = C_ALL) THEN
    -- {
        -- if the view by is sub/cat level, or specific sub/cat
        -- is specified, go to level 1
        l_grouping_level := L_CAT_LEVEL;
    -- }
    ELSE
    -- {
        -- The viewby is org, and at the most only org parameter values
        -- are specified.
        l_grouping_level := L_ORG_LEVEL;
    -- }
    END IF;

    return to_char (l_grouping_level);
-- }
END get_rollup1_aggr_flag;

/* Function:    get_trx_reason_aggr_flag
   Description: Compute best aggregation level of MV rows that the query
                will run against for any combination of report parameters
*/
FUNCTION get_trx_reason_aggr_flag(p_dim_name VARCHAR2,
                                p_dim_map IN
                                poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS
  -- Aggregation Levels for the various dimensions
    REASON_LEVEL_ID     CONSTANT   INTEGER := 1;
    ITEM_LEVEL_ID       CONSTANT   INTEGER := 2;
    CAT_LEVEL_ID        CONSTANT   INTEGER := 4;

    l_org_val           VARCHAR2 (120) := NULL;
    l_item_val          VARCHAR2 (120) := NULL;
    l_cat_val           VARCHAR2 (120) := NULL;
    l_reason_val        VARCHAR2 (120) := NULL;

    l_agg_lvl_flag      NUMBER  := 0;
    l_in_bmap           NUMBER  := 0;

    l_mv_agg_lvl_tbl    MV_AGG_LVL_TBL;  /* Table of Aggregation levels */
BEGIN

    l_mv_agg_lvl_tbl := MV_AGG_LVL_TBL ();      /* Initialize the table */

    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION')) THEN
            l_org_val := p_dim_map ('ORGANIZATION+ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL')) THEN
            l_reason_val := p_dim_map ('OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL').value;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_INV_CAT' AND
       (l_cat_val IS NULL OR
        l_cat_val = '' OR
        l_cat_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + CAT_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'ITEM+ENI_ITEM_ORG' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + ITEM_LEVEL_ID;
    END IF;

    IF p_dim_name <> 'OPI_MFG_TRX_REASON+OPI_MFG_MTL_TRX_REASON_LVL' AND
       (l_item_val IS NULL OR
        l_item_val = '' OR
        l_item_val = 'All'
       )
    THEN
        l_in_bmap := l_in_bmap + REASON_LEVEL_ID;
    END IF;

    --
    -- Populate the table with aggregation level values from MV
    -- Start with most preferred aggregation level
    --
    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 6 ;  /* org reason code level*/

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 2;  /* org inv cat reason level */

    l_mv_agg_lvl_tbl.extend;
    l_mv_agg_lvl_tbl(l_mv_agg_lvl_tbl.COUNT).value := 0;  /* Most Granular Level*/

    --
    -- calculate the most effecient level for the combination of parameters
    --
    l_agg_lvl_flag := get_agg_level(l_mv_agg_lvl_tbl, l_in_bmap);
    RETURN to_char(l_agg_lvl_flag);
END get_trx_reason_aggr_flag;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Selecting the MV for Product Gross Margin
/*++++++++++++++++++++++++++++++++++++++++*/
/*
This Function is called from process_parameters if the p_mv_set is related to
Product Gross Margin. The following are the various combinations for all the MVs selected
depending on the mv_level_flag and the Dimension Values.
-OPI_PGM_CAT_MV
-OPI_PGM_SUM_MV
-Inline View.
*/

FUNCTION select_mv (p_mv_set IN VARCHAR2, p_mv_level_flag IN VARCHAR2, p_view_by IN VARCHAR2,
        p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
   RETURN VARCHAR2
IS
    l_mv VARCHAR2(2000) := '';
    l_cat_val VARCHAR2 (120) := NULL;
    l_time_val VARCHAR2 (1) := NULL;
BEGIN
        IF (p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN
            l_cat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
        END IF;

        IF (p_view_by = ('TIME+FII_TIME_ENT_YEAR') OR p_view_by = ('TIME+FII_TIME_ENT_QTR')
            OR p_view_by = ('TIME+FII_TIME_ENT_PERIOD') OR p_view_by = ('TIME+FII_TIME_WEEK')) THEN
            l_time_val := '1';
        END IF;

        IF ((l_cat_val = 'All' OR l_cat_val IS NULL) AND l_time_val IS NULL AND
            (p_mv_level_flag = '5' OR p_mv_level_flag = '7'))
           THEN
            l_mv := 'OPI_PGM_CAT_MV';
        ELSIF (l_cat_val <> 'All' AND l_cat_val IS NOT NULL)
            THEN
        --
        -- Bug 3896892 : Add secondary global currency columns to inline query
        -- 1. fulfilled_val_sg
        -- 2. cogs_val_sg
        --
            l_mv := ' (select
            v.imm_child_id item_category_id,
            v.parent_id parent_id,
            f.fulfilled_val_b FULFILLED_VAL_B,
            f.fulfilled_val_g FULFILLED_VAL_G,
            f.cogs_val_b COGS_VAL_B,
            f.cogs_val_g COGS_VAL_G,
            f.fulfilled_qty FULFILLED_QTY,
            f.customer_item_cat_flag CUSTOMER_ITEM_CAT_FLAG,
            f.item_org_id ITEM_ORG_ID,
            f.uom_code UOM_CODE,
            f.time_id TIME_ID,
            f.organization_id ORGANIZATION_ID,
            f.top_model_org_id TOP_MODEL_ORG_ID,
            f.customer_ID CUSTOMER_ID,
            f.fulfilled_val_sg,
            f.cogs_val_sg
        from
            opi_pgm_sum_mv f,
            eni_denorm_hierarchies v,
            mtl_default_category_sets m
        where
            m.functional_area_id = 11
            and v.object_id = m.category_set_id
            and v.dbi_flag = ''Y''
            and v.object_type = ''CATEGORY_SET''
            and f.item_category_id = v.child_id
        )';
    ELSE
        l_mv := 'OPI_PGM_SUM_MV';
        END IF;
    RETURN l_mv;
END select_mv;

/* percent_str

    Gets the string for percentage change of two specified strings.
    Better than copying CASE statements everywhere
*/
FUNCTION percent_str (p_numerator IN VARCHAR2,
                      p_denominator IN VARCHAR2,
                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_percentage_calc VARCHAR2 (600) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);
    l_nvl_numerator VARCHAR2 (100) := nvl_str (p_numerator);

BEGIN

    l_percentage_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
        ' || ' ELSE (' || l_nvl_numerator || '/' || p_denominator || ') *100
        ' || 'END
        ' || p_measure_name || ' ';

    return l_percentage_calc;

END percent_str;

/* percent_str_basic

    Gets the string for percentage change of two specified strings.
    Better than copying CASE statements everywhere.
    No NVLs on numerator.
*/
FUNCTION percent_str_basic (p_numerator IN VARCHAR2,
                            p_denominator IN VARCHAR2,
                            p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_percentage_calc VARCHAR2 (600) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);

BEGIN

    l_percentage_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
        ' || ' WHEN ' || p_numerator || ' IS NULL THEN to_number (NULL)
        ' || ' ELSE (' || p_numerator || '/' || p_denominator || ') *100
        ' || 'END
        ' || p_measure_name || ' ';

    return l_percentage_calc;

END percent_str_basic;


/* pos_denom_percent_str

    Gets the string for percentage change of two specified strings if
    the denominator is positive and greater than 0.
    Better than copying CASE statements everywhere.
*/
FUNCTION pos_denom_percent_str (p_numerator IN VARCHAR2,
                                p_denominator IN VARCHAR2,
                                p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_percentage_calc VARCHAR2 (600) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);
    l_nvl_numerator VARCHAR2 (100) := nvl_str (p_numerator);

BEGIN

    l_percentage_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' <= 0 THEN to_number (NULL)
        ' || ' ELSE (' || l_nvl_numerator || '/' || p_denominator || ') *100
        ' || 'END
        ' || p_measure_name || ' ';

    return l_percentage_calc;

END pos_denom_percent_str;

/* pos_denom_percent_str_basic

    Gets the string for percentage change of two specified strings if
    the denominator is positive and greater than 0.
    Better than copying CASE statements everywhere.
    No NVLs on numerator.
*/
FUNCTION pos_denom_percent_str_basic (p_numerator IN VARCHAR2,
                                      p_denominator IN VARCHAR2,
                                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_percentage_calc VARCHAR2 (600) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);

BEGIN

    l_percentage_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' <= 0 THEN to_number (NULL)
        ' || ' WHEN ' || p_numerator || ' IS NULL THEN to_number (NULL)
        ' || ' ELSE (' || p_numerator || '/' || p_denominator || ') *100
        ' || 'END
        ' || p_measure_name || ' ';

    return l_percentage_calc;

END pos_denom_percent_str_basic;

/* change_str
    Get the percentage change string. Better than writing out all the case
    statements
*/
FUNCTION change_str (p_new_numerator IN VARCHAR2,
                     p_old_numerator IN VARCHAR2,
                     p_denominator IN VARCHAR2,
                     p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_change_calc VARCHAR2 (1000) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);
    l_nvl_new_numerator VARCHAR2 (100) := nvl_str (p_new_numerator);
    l_nvl_old_numerator VARCHAR2 (100) := nvl_str (p_old_numerator);

BEGIN

    l_change_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
        ' || ' ELSE ((' || l_nvl_new_numerator || ' - ' || l_nvl_old_numerator
          || ')/ abs (' || p_denominator || ')) * 100
        ' || 'END
        ' || p_measure_name || ' ';

    RETURN l_change_calc;
END change_str;

/* change_str_basic
    Get the percentage change string. Better than writing out all the case
    statements.
    No NVLs on numerator.
*/
FUNCTION change_str_basic (p_new_numerator IN VARCHAR2,
                           p_old_numerator IN VARCHAR2,
                           p_denominator IN VARCHAR2,
                           p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_change_calc VARCHAR2 (1000) := '';
    l_nvl_denominator VARCHAR2 (100) := nvl_str (p_denominator);

BEGIN

    l_change_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
        ' || ' WHEN ' || p_new_numerator || ' IS NULL THEN to_number (NULL)
        ' || ' WHEN ' || p_old_numerator || ' IS NULL THEN to_number (NULL)
        ' || ' ELSE ((' || p_new_numerator || ' - ' || p_old_numerator
          || ')/ abs (' || p_denominator || ')) * 100
        ' || 'END
        ' || p_measure_name || ' ';

    RETURN l_change_calc;
END change_str_basic;

/* change_pct_str
    Get the change in percentage string. Better than writing out all the case
    statements
*/
FUNCTION change_pct_str (p_new_numerator IN VARCHAR2,
                         p_new_denominator IN VARCHAR2,
                         p_old_numerator IN VARCHAR2,
                         p_old_denominator IN VARCHAR2,
                         p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_change_pct_calc VARCHAR2 (1000) := '';
    l_nvl_new_denominator VARCHAR2 (100) := nvl_str (p_new_denominator);
    l_nvl_old_denominator VARCHAR2 (100) := nvl_str (p_old_denominator);
    l_nvl_new_numerator VARCHAR2 (100) := nvl_str (p_new_numerator);
    l_nvl_old_numerator VARCHAR2 (100) := nvl_str (p_old_numerator);

BEGIN

    l_change_pct_calc :=
        'CASE WHEN ' || l_nvl_old_denominator || ' = 0 THEN to_number (NULL)
        ' || 'WHEN ' || l_nvl_new_denominator || ' = 0 THEN to_number (NULL)
        ' || ' ELSE ((' || l_nvl_new_numerator || '/'
                        || l_nvl_new_denominator ||
        ') -
        ' || '(' || l_nvl_old_numerator || '/'
                 || l_nvl_old_denominator || '))*100
        ' || 'END
        ' || p_measure_name || ' ';

    RETURN l_change_pct_calc;

END change_pct_str;

/* change_pct_str_basic
    Get the change in percentage string. Better than writing out all the case
    statements. No NVLs on numerator.
*/
FUNCTION change_pct_str_basic (p_new_numerator IN VARCHAR2,
                               p_new_denominator IN VARCHAR2,
                               p_old_numerator IN VARCHAR2,
                               p_old_denominator IN VARCHAR2,
                               p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_change_pct_calc VARCHAR2 (1000) := '';
    l_nvl_new_denominator VARCHAR2 (100) := nvl_str (p_new_denominator);
    l_nvl_old_denominator VARCHAR2 (100) := nvl_str (p_old_denominator);
    l_nvl_new_numerator VARCHAR2 (100) := nvl_str (p_new_numerator);
    l_nvl_old_numerator VARCHAR2 (100) := nvl_str (p_old_numerator);

BEGIN

    l_change_pct_calc :=
        'CASE WHEN ' || l_nvl_old_denominator || ' = 0 THEN to_number (NULL)
        ' || 'WHEN ' || l_nvl_new_denominator || ' = 0 THEN to_number (NULL)
        ' || 'WHEN ' || p_new_numerator || ' IS NULL THEN to_number (NULL)
        ' || 'WHEN ' || p_old_numerator || ' IS NULL THEN to_number (NULL)
        ' || ' ELSE ((' || p_new_numerator || '/'
                        || l_nvl_new_denominator ||
        ') -
        ' || '(' || p_old_numerator || '/'
                 || l_nvl_old_denominator || '))*100
        ' || 'END
        ' || p_measure_name || ' ';

    RETURN l_change_pct_calc;

END change_pct_str_basic;


/* rate_str
    Calculates a rate given a numerator and denominator;
    p_rate_type = 'P' indicates percentage inputs
    p_rate_type = 'NP' indicates absolute inputs
*/

FUNCTION rate_str (p_numerator IN VARCHAR2,
           p_denominator IN VARCHAR2,
           p_rate_type IN VARCHAR2 := 'P')
RETURN VARCHAR2
IS
BEGIN
        -- if rate is a ratio
        if(p_rate_type = 'NP') then
      return '(' || p_numerator || '/decode(' || p_denominator || ',0,null,'
             || p_denominator || '))';
        end if;

        -- if rate is a percent
        return '((nvl(' || p_numerator || ',0)/decode(' || p_denominator || ',0,null,'
        || p_denominator || '))*100)';
END rate_str;


/* nvl_str
    Convert a string into its NVL (str, val)
    The default NVL value is 0
*/
FUNCTION nvl_str (p_str IN VARCHAR2,
                  p_default_val IN NUMBER := 0)
    RETURN VARCHAR2
IS
BEGIN

    return ('nvl (' || p_str || ', ' || p_default_val || ')');

END nvl_str;

/*
    If the value of the string is NEGATIVE, return NULL.
    Else return itself.
*/
FUNCTION neg_str(p_str IN VARCHAR2)
        RETURN VARCHAR2
IS
BEGIN

  return ('decode (sign (' || p_str || '), -1, NULL, ' || p_str || ') ');

END neg_str;

/* raw_str
    If the string is NULL, return NULL.
    Else return itself.
*/
FUNCTION raw_str (p_str IN VARCHAR2)
    RETURN VARCHAR2
IS
BEGIN

    return (' CASE WHEN ' || p_str || ' IS NULL THEN
            to_number (NULL)
            ELSE ' || p_str || '
            END ');

END raw_str;


/*----------------------------------------------------------------------
  Function performs a bitand of p_dim_bmap with each vaue in p_mv_lvl_tbl
  If the result is same as the value return it
  If no record satisfies the check, return the most granular level

  If p_mv_lvl_tbl is not initialized return -1 to signal error
-----------------------------------------------------------------------*/
FUNCTION get_agg_level (p_mv_lvl_tbl IN opi_dbi_rpt_util_pkg.MV_AGG_LVL_TBL,
                        p_dim_bmap   IN NUMBER)
    RETURN NUMBER
IS
    NO_INITIALIZE   EXCEPTION;   /* raise exception when table is not initialized */

BEGIN
    IF nvl(p_mv_lvl_tbl.count, -1) > 0 THEN
        FOR cntr IN p_mv_lvl_tbl.FIRST .. p_mv_lvl_tbl.LAST LOOP
            IF bitand(p_mv_lvl_tbl(cntr).value, p_dim_bmap) = p_mv_lvl_tbl(cntr).value
            THEN
                RETURN p_mv_lvl_tbl(cntr).value;
            END IF;
        END LOOP;
        RETURN (p_mv_lvl_tbl(p_mv_lvl_tbl.LAST).value);
    ELSE
        RAISE NO_INITIALIZE;
    END IF;
EXCEPTION
    WHEN NO_INITIALIZE THEN
        RETURN (-1);
END get_agg_level;

/* Build the fact view by columns string using the join table
   for queries using windowing.
*/
FUNCTION get_fact_select_columns (p_join_tbl IN
                                  poa_dbi_util_pkg.POA_DBI_JOIN_TBL)
    RETURN VARCHAR2
IS
    l_fact_select_cols VARCHAR2(400);
BEGIN

    l_fact_select_cols := '';

    FOR l_num IN p_join_tbl.first .. p_join_tbl.last
    LOOP
        IF (p_join_tbl.exists(l_num)) THEN
            l_fact_select_cols := l_fact_select_cols ||
                                  p_join_tbl(l_num).fact_column || ',
                                  ';
        END IF;
    END LOOP;
    -- trim trailing comma and carriage returns, and add a space
    l_fact_select_cols := rtrim (l_fact_select_cols, ',
                                                       ') || ' ';

    return l_fact_select_cols;

END get_fact_select_columns;

/*
    For viewby = item_org, various reports have to display
    a description and unit of measure
*/
PROCEDURE get_viewby_item_columns (p_dim_name VARCHAR2,
                                   p_description OUT NOCOPY VARCHAR2,
                                   p_uom OUT NOCOPY VARCHAR2)

IS
    l_description varchar2(30);
    l_uom varchar2(30);

BEGIN
      CASE
      WHEN p_dim_name = 'ITEM+ENI_ITEM_ORG' THEN
              BEGIN
                  p_description := 'v.description';
                  p_uom := 'v2.unit_of_measure';
              END;
          ELSE
              BEGIN
                  p_description := 'null';
                  p_uom := 'null';
              END;
      END CASE;

END get_viewby_item_columns;

/* Replace_n

    Replace a substring of a given string with a different string n times.
    The substring is removed if the replacement string is NULL.

    Parameters:
    p_orig_str - Original string
    p_match_str - Pattern (substring) to be matched in p_orig_str
    p_replace_str - Pattern to replace p_match_str with. If NULL, then
                    p_match_str is removed from replace_once.
    p_start_pos - Starting position for replacements in original string.
    p_num_times - Number of times replacements is required

    Date        Author              Action
    07/11/05    Dinkar Gupta        Wrote Function

*/
FUNCTION replace_n (p_orig_str IN VARCHAR2,
                    p_match_str IN VARCHAR2,
                    p_replace_str IN VARCHAR2,
                    p_start_pos IN NUMBER,
                    p_num_times IN NUMBER)
    RETURN VARCHAR2
IS
-- {

    l_init_str VARCHAR2 (32767);

    l_new_str VARCHAR2 (32767);

    l_pos NUMBER;

-- }
BEGIN
-- {

    IF (p_num_times < 0 OR p_start_pos < 1) THEN
    -- {
        l_new_str := replace (p_orig_str, p_match_str, p_replace_str);
    -- }
    ELSE
    -- {
        -- pick the right starting position
        l_new_str := NULL;
        l_new_str := substr (p_orig_str, p_start_pos);

        -- don't lose the unreplaced part
        l_init_str := NULL;
        l_init_str := substr (p_orig_str, 1, p_start_pos - 1);

        FOR l_num_times IN 1 .. p_num_times
        LOOP
        -- {

            l_pos := instr (l_new_str, p_match_str);
            IF (l_pos > 0 AND l_pos < length (l_new_str)) THEN
            -- {
                l_init_str := l_init_str ||
                              substr (l_new_str, 1, l_pos - 1) ||
                              p_replace_str;
                l_new_str := substr (l_new_str, l_pos + length (p_match_str));
            -- }
            END IF;

        -- }
        END LOOP;

        -- add in any originally ignored bits
        l_new_str := l_init_str || l_new_str;

    -- }
    END IF;

    return l_new_str;
-- }
END replace_n;

/* -------------------------------------------------------------------------------------------
   Procedure Name: set_inv_convergence_date
   Parameters    : x_return_status (OUT parameter)
   Purpose       : This procedure is only called by OPM core team for a
                   customer that is migrating from some older release (11i's)
		   to Release 12. When this procedure is called we would
		   insert the trunc of the sysdate into one of our DBI log
		   table, which would be used by all ETL's as the R12
		   migration date.
----------------------------------------------------------------------------------------------
*/

PROCEDURE set_inv_convergence_date (x_return_status OUT NOCOPY VARCHAR2)
IS
l_stmt_id NUMBER;
l_inv_convergence_date DATE;
l_proc_name CONSTANT VARCHAR2 (60):= 'set_inv_convergence_date';

BEGIN
--{
   l_stmt_id := 0;
   --Initialization of variables
   x_return_status := 'N';

   l_stmt_id := 10;
   SELECT trunc(sysdate)
   INTO l_inv_convergence_date
   FROM dual;

   l_stmt_id := 20;
   merge_inv_convergence_date(p_migration_date=>
                                 l_inv_convergence_date);
   l_stmt_id := 30;
   --return success to the calling code
   x_return_status := 'Y';

   EXCEPTION
   --{
   WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);
	x_return_status := 'N';
   --}
   --}

  END set_inv_convergence_date;

  /* -------------------------------------------------------------------------------------------
   Procedure Name: get_inv_convergence_date
   Parameters    : p_inv_migration_date (OUT parameter)
   Purpose       : This procedure is called by DBI ETL's in the areas of
                   Manufacturing and Inventory to get the R12 migration date,
		   which was inserted by the 'set'procedure into one of DBI
		   log table viz. OPI_DBI_CONC_PROG_RUN_LOG.
		   If such date is not found in the log table, we look at
		   the max of the last update in the Inventory Balances Table
		   viz. IC_LOCT_INV.
		   For a new customer directly going into R12, the above 2
		   would not give any date, so in that case we simply use the
		   sysdate for the purpose.
		   The procedure insert_inv_convergence_date is used to insert
		   the date in the log table in case it was not earlier
		   present there.
----------------------------------------------------------------------------------------------
*/

  PROCEDURE get_inv_convergence_date (p_inv_migration_date OUT NOCOPY DATE)
  IS

  l_stmt_id NUMBER;
  l_inv_migration_date ic_loct_inv.last_update_date%type;
  l_rowcount NUMBER;
  l_proc_name CONSTANT VARCHAR2 (60):= 'get_inv_convergence_date';

  BEGIN
  --{
  l_stmt_id := 0;
  l_rowcount := 0;
  p_inv_migration_date := trunc(sysdate);

  l_stmt_id := 10;
   SELECT count (*)
   INTO l_rowcount
   FROM
      OPI_DBI_CONC_PROG_RUN_LOG
   WHERE
      ETL_TYPE = 'R12_MIGRATION';

  --get the R12 Convergence Date from the Log Table
  l_stmt_id := 20;
  IF l_rowcount <> 0 THEN
  --{
  SELECT
     last_run_date
  INTO
     l_inv_migration_date
  FROM
     opi_dbi_conc_prog_run_log
  WHERE
     etl_type = 'R12_MIGRATION';
     p_inv_migration_date := l_inv_migration_date;
  --}
  ELSE
  --{
  SELECT
    MAX(last_update_date)
  INTO
    l_inv_migration_date
  FROM
    ic_loct_inv
  WHERE
    migrated_ind = 1;
    l_stmt_id :=40;
    IF l_inv_migration_date IS NOT NULL THEN
    --{
     p_inv_migration_date := trunc (l_inv_migration_date);
     merge_inv_convergence_date (p_migration_date =>
                              p_inv_migration_date);
     BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || 'R12 migration date is not available in log. Using maximum of last
					   update date from Inventory Balances Table');
    --}
    ELSE
    --{
     p_inv_migration_date := trunc (sysdate);
     merge_inv_convergence_date(p_migration_date =>
                                p_inv_migration_date);
     BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || 'Using sysdate as R12 migration date i.e.
					   the date on which the respective Initial Load was run');
    --}
   END IF;
--}
END IF;

  EXCEPTION
  --{
     WHEN NO_DATA_FOUND THEN
        p_inv_migration_date := trunc (sysdate);
        merge_inv_convergence_date(p_migration_date =>
                                p_inv_migration_date);
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || 'Using sysdate as R12 migration date i.e.
					   the date on which the respective Initial Load was run');
     WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE (s_pkg_name || '.' ||
                                           l_proc_name || ' ' ||
                                           '#' || l_stmt_id ||
                                           ': ' || SQLERRM);
  --}
  --}

 END get_inv_convergence_date;

 /* -------------------------------------------------------------------------------------------
   Procedure Name: merge_inv_convergence_date
   Parameters    : p_migration_date (IN parameter)
   Purpose       : This is one centralized merge procedure to merge a row into
                   the log table with the R12 migration date with ETL_TYPE as
		   'R12_MIGRATION'.The commit to the log table after inserting
		   /upadting this row would be done in this procedure only.
----------------------------------------------------------------------------------------------
*/

PROCEDURE merge_inv_convergence_date (p_migration_date IN DATE)
IS
  l_user_id NUMBER;
  l_login_id NUMBER;
  l_program_id NUMBER;
  l_program_login_id NUMBER;
  l_program_application_id NUMBER;
  l_request_id NUMBER;
  l_stmt_id NUMBER;
BEGIN
--{
   l_stmt_id := 0;
   --Initialization of variables
   l_user_id := nvl(fnd_global.user_id, -1);
   l_login_id := nvl(fnd_global.login_id, -1);
   l_program_id := nvl (fnd_global.conc_program_id, -1);
   l_program_login_id := nvl (fnd_global.conc_login_id, -1);
   l_program_application_id := nvl (fnd_global.prog_appl_id,  -1);
   l_request_id := nvl (fnd_global.conc_request_id, -1);

   l_stmt_id := 10;
   MERGE INTO OPI_DBI_CONC_PROG_RUN_LOG log
   USING (
   SELECT
      'R12_MIGRATION'             ETL_TYPE,
       p_migration_date           LAST_RUN_DATE ,         -- R12 migration date
       sysdate                    CREATION_DATE,
       sysdate                    LAST_UPDATE_DATE,
       l_user_id                  CREATED_BY,
       l_user_id                  LAST_UPDATED_BY,
       l_login_id                 LAST_UPDATE_LOGIN,
       l_request_id               REQUEST_ID,
       l_program_application_id   PROGRAM_APPLICATION_ID,
       l_program_id               PROGRAM_ID,
       l_program_login_id         PROGRAM_LOGIN_ID,
       '-1'                       DRIVING_TABLE_CODE,
       '-1'                       LOAD_TYPE,
       '-1'                       BOUND_TYPE,
       NULL                       BOUND_LEVEL_ENTITY_CODE,
       NULL                       BOUND_LEVEL_ENTITY_ID,
       NULL                       FROM_BOUND_DATE,
       NULL                       TO_BOUND_DATE,
       NULL                       FROM_BOUND_ID,
       NULL                       TO_BOUND_ID,
       NULL                       COMPLETION_STATUS_CODE,
       NULL                       STOP_REASON_CODE
   FROM
       dual)  migration_data
   ON (log.etl_type      =   migration_data.etl_type
       )
   WHEN MATCHED THEN
     UPDATE SET
     log.last_run_date = migration_data.last_run_date
    ,log.last_update_date = migration_data.last_update_date
    ,log.last_updated_by = migration_data.last_updated_by
    ,log.last_update_login = migration_data.last_update_login
   WHEN NOT MATCHED THEN
     INSERT (ETL_TYPE, LAST_RUN_DATE, CREATION_DATE, LAST_UPDATE_DATE, CREATED_BY,
             LAST_UPDATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
	     PROGRAM_ID, PROGRAM_LOGIN_ID, DRIVING_TABLE_CODE, LOAD_TYPE, BOUND_TYPE,
	     BOUND_LEVEL_ENTITY_CODE, BOUND_LEVEL_ENTITY_ID, FROM_BOUND_DATE,
	     TO_BOUND_DATE, FROM_BOUND_ID, TO_BOUND_ID, COMPLETION_STATUS_CODE,
	     STOP_REASON_CODE)
     VALUES (migration_data.etl_type, migration_data.LAST_RUN_DATE, migration_data.CREATION_DATE,
             migration_data.LAST_UPDATE_DATE, migration_data.CREATED_BY, migration_data.LAST_UPDATED_BY,
	     migration_data.LAST_UPDATE_LOGIN, migration_data.REQUEST_ID, migration_data.PROGRAM_APPLICATION_ID,
	     migration_data.PROGRAM_ID, migration_data.PROGRAM_LOGIN_ID, migration_data.DRIVING_TABLE_CODE,
	     migration_data.LOAD_TYPE, migration_data.BOUND_TYPE, migration_data.BOUND_LEVEL_ENTITY_CODE,
	     migration_data.BOUND_LEVEL_ENTITY_ID, migration_data.FROM_BOUND_DATE, migration_data.TO_BOUND_DATE,
	     migration_data.FROM_BOUND_ID, migration_data.TO_BOUND_ID, migration_data.COMPLETION_STATUS_CODE,
	     migration_data.STOP_REASON_CODE);

    --Commit the above insertion
     l_stmt_id := 20;
     commit;
 --}
  END merge_inv_convergence_date;


FUNCTION  OPI_UM_CONVERT (
     p_item_id           	number,
     p_item_qty               number,
     p_from_unit         	varchar2,
     p_to_unit           	varchar2 ) RETURN number
IS
     l_stmt_num     NUMBER;
     l_debug_msg    VARCHAR2(1000);
     l_proc_name    VARCHAR2 (60);
     l_uom_rate    number;
     l_uom_qty     number;

BEGIN
     l_proc_name    :=  'OPI_UM_CONVERT';

     --l_uom_rate := NULL;
     if ( p_from_unit <> p_to_unit )then

      	inv_convert.inv_um_conversion(p_from_unit , p_to_unit , p_item_id, l_uom_rate);
          if ( l_uom_rate = -99999 ) then
                --RAISE UOM_CONV_ERROR;
                OPI_DBI_RPT_UTIL_PKG.g_pk_uom_conversion := 0;
                l_debug_msg := 'Conversion not found from unit '|| p_from_unit  || 'to unit'  || p_to_unit || 'for item id ' || p_item_id ;
                OPI_DBI_BOUNDS_PKG.write(s_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
      	end if;
     else
          l_uom_rate := 1;
     end if;
 	/** Default precision for inventory was 6 decimals
 	  Changed the default precision to 5 since INV supports a standard
 	  precision of 5 decimal places.
 	*/
 	l_uom_qty := l_uom_rate * p_item_qty;
     l_uom_qty := round(l_uom_qty, 5);

 	RETURN l_uom_qty;


EXCEPTION
     WHEN OTHERS THEN
     l_debug_msg := 'Conversion not found from unit '|| p_from_unit  || 'to unit'  || p_to_unit || 'for item id ' || p_item_id || SQLcode || ' - ' ||SQLERRM;
     OPI_DBI_BOUNDS_PKG.write(s_pkg_name,l_proc_name,l_stmt_num,l_debug_msg);
     RAISE;

END OPI_UM_CONVERT;

END OPI_DBI_RPT_UTIL_PKG;

/

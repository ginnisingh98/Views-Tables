--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SUTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SUTIL_PKG" AS
/*$Header: iscdbisutilb.pls 120.1 2005/06/14 11:25:38 appldev  $ */


/*++++++++++++++++++++++++++++++++++++++++*/
/* Local Functions
/*++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE init_dim_map (p_dim_map out NOCOPY
                        poa_dbi_util_pkg.poa_dbi_dim_map,
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

FUNCTION get_security_where_clause(p_org_value IN VARCHAR2, p_trend IN VARCHAR2 DEFAULT 'N', p_mv_set IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_additional_where_clause(p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map, p_mv_set IN VARCHAR2, p_view_by IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_mv_flag_where_clause (p_mv_flag_type IN VARCHAR2, p_trend IN VARCHAR2 DEFAULT 'N',
                   p_mv IN VARCHAR2 DEFAULT '', p_mv_where_clause IN VARCHAR2)
    RETURN VARCHAR2;

FUNCTION get_flag_where_clause(p_trend IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2;

FUNCTION get_flag_where_clause2(p_trend IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2;

PROCEDURE update_col_name (p_dim_map IN out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map,
                           p_mv_set IN VARCHAR2,
			   p_dim_name VARCHAR2);

PROCEDURE get_join_info (p_view_by IN varchar2,
                         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
                         x_join_tbl OUT NOCOPY
                         poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                         p_mv_set IN VARCHAR2);

PROCEDURE populate_in_join_tbl(p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
	                       p_view_by in VARCHAR2,
                               p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map);

FUNCTION get_mv_level_flag (p_mv_flag_type VARCHAR2,
                            p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_flag_one_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_flag_two_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_flag_three_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_flag_four_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2;

FUNCTION get_flag_five_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
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
    p_mv_level_flag - all report queries using this
                      package will use a flag to decide which rows of
                      their MVs they will need to query.

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
			      poa_dbi_util_pkg.poa_dbi_in_join_tbl)
IS
    l_dim_map poa_dbi_util_pkg.poa_dbi_dim_map;
    l_dim_bmap NUMBER;
    l_org_val VARCHAR2 (120);

    l_as_of_date DATE;
    l_prev_as_of_date DATE;
    l_nested_pattern NUMBER;

    l_mv_where_clause VARCHAR2(1); -- Determines if MV Flag Where Clause needs to be appended.

    l_stmt_id NUMBER;

BEGIN

    l_mv_where_clause := 'Y';
    l_stmt_id := 0;

    -- initialize the dimension map with all the required dimensions.
    l_dim_bmap := 0;
    l_org_val := NULL;
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

    l_stmt_id := 25;
    -- In certain cases, we may need to use different dimension cols from the MVs
    update_col_name(l_dim_map,p_mv_set,p_view_by);

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

    -- Get the flag value for MV aggregation
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

    -- Determine if MV Flag Where Clause needs to be appended. By default the value is 'Y'
    l_stmt_id := 70;
    l_mv_where_clause := get_mv_where_clause_flag (p_mv => p_mv);

    -- Get the dimension level specific where clauses
    -- and the security where clause.
    l_stmt_id := 80;
    p_where_clause := poa_dbi_util_pkg.get_where_clauses (p_dim_map => l_dim_map,
                                                          p_trend => p_trend);

    -- Attach the optional MV flag where clause
    l_stmt_id := 90;
    p_where_clause := p_where_clause ||
                       get_mv_flag_where_clause (p_mv_flag_type => p_mv_flag_type,
                                     p_trend => p_trend,
                                     p_mv => p_mv,
                                     p_mv_where_clause => l_mv_where_clause);

    -- Attach the security clause
    l_stmt_id := 100;
    p_where_clause := p_where_clause ||
                   get_security_where_clause (p_org_value => l_org_val,
                               p_trend => p_trend,
                               p_mv_set => p_mv_set);

    -- Attach the additional where clauses
    l_stmt_id := 110;
    p_where_clause := p_where_clause ||
                   get_additional_where_clause (p_dim_map => l_dim_map,
                               p_mv_set => p_mv_set,
                               p_view_by => p_view_by);

    l_stmt_id := 120;
    -- Add extra join conditions (if necessary)
    populate_in_join_tbl(p_in_join_tbl => p_in_join_tbl,
                         p_view_by => p_view_by,
                         p_dim_map => l_dim_map);


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
    l_mv_where_clause_flag VARCHAR2(1);
BEGIN
    l_mv_where_clause_flag :=
        (CASE p_mv
            WHEN 'ISC_DBI_CFM_003_MV' THEN
                 'N'
            ELSE
                 'Y'
        END);
    RETURN l_mv_where_clause_flag;
END get_mv_where_clause_flag;

/*++++++++++++++++++++++++++++++++++++++++*/
/* Where clause building routine
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_mv_flag_where_clause

    Depending on which MV flag is being used, get a different
    where clause statement. The flag type is determined by p_mv_flag_type:
    'FLAG1' - service_level, unsecured org, carrier
    'FLAG2' - service_level, carrier
    'FLAG3' - unsecured org,customer for isc_trn_005_mv; item_category & customer  for isc_dbi_fm_0000_mv
    'FLAG4' - subinventory, inventory category
    'FLAG5' - inventory category, item

*/
FUNCTION get_mv_flag_where_clause (p_mv_flag_type IN VARCHAR2,
                   p_trend IN VARCHAR2 DEFAULT 'N',
                   p_mv IN VARCHAR2 DEFAULT '',
                   p_mv_where_clause IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_mv_flag_where_clause VARCHAR2 (200);

BEGIN
    l_mv_flag_where_clause := '';

    IF (p_mv_where_clause = 'Y') THEN
        l_mv_flag_where_clause :=
             (CASE p_mv_flag_type
                WHEN 'FLAG1' THEN
		    get_flag_where_clause (p_trend)
                WHEN 'FLAG2' THEN
		    get_flag_where_clause (p_trend)
                WHEN 'FLAG3' THEN
                    get_flag_where_clause (p_trend)
                WHEN 'FLAG4' THEN
                    get_flag_where_clause (p_trend)
                WHEN 'FLAG5' THEN
                    get_flag_where_clause2 (p_trend)
                ELSE
                    ''
              END);
    END IF;

    RETURN l_mv_flag_where_clause;

END get_mv_flag_where_clause;


/* get_flag_where_clause
    Return the where clause for ISC specific agg_level flag.
    Can be used for flag1, flag2, flag3, flag4
*/
FUNCTION get_flag_where_clause(p_trend IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause VARCHAR2 (200);

BEGIN

    l_flag_where_clause := 'AND fact.agg_level = :ISC_AGG_FLAG ';
    RETURN l_flag_where_clause;

END get_flag_where_clause;

/* get_flag_where_clause2
    Return the where clause for ISC specific agg_level flag.
    Can be used for flag5
*/
FUNCTION get_flag_where_clause2(p_trend IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2
IS
    l_flag_where_clause2 VARCHAR2 (200);

BEGIN

    l_flag_where_clause2 := 'AND fact.agg_level = :ISC_AGG_FLAG2 ';
    RETURN l_flag_where_clause2;

END get_flag_where_clause2;

/* get_security_where_clause
    For ISC, this is quite simple.
*/

FUNCTION get_security_where_clause(p_org_value IN VARCHAR2, p_trend IN VARCHAR2 DEFAULT 'N', p_mv_set IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_sec_where_clause VARCHAR2(1000);

BEGIN

    l_sec_where_clause :='';

  if(p_org_value is null or p_org_value = '' or p_org_value = 'All')
    then l_sec_where_clause :=
        (CASE p_mv_set
            WHEN 'BQ1' THEN ' ' -- no organization security for TM reports
            WHEN 'BY1' THEN ' '
            WHEN 'BW1' THEN ' '
            WHEN 'BX1' THEN ' '
            WHEN 'BZ1' THEN ' '
            WHEN 'BP1' THEN ' '
            WHEN 'BP2' THEN ' '
            WHEN 'BT1' THEN ' '
            WHEN 'BU1' THEN ' '
            WHEN 'C01' THEN ' '
            WHEN 'C11' THEN ' '
            WHEN 'C21' THEN ' '
	    WHEN 'C31' THEN ' '
            WHEN 'C32' THEN ' '
            WHEN 'C41' THEN ' '
            WHEN 'C42' THEN ' '
            ELSE 'AND (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = fact.inv_org_id)
	OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = fact.inv_org_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))'
        END);
  end if;

  return l_sec_where_clause;

END get_security_where_clause;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Functions to get the MV
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_mv

    Gets the MV for the content group concerned.

    The p_mv_set parameter is used to determine which MV is being
    used i.e. when p_mv_set:
    'BQ1','BY1','BZ1','C01' - Rated Freight Cost per Unit Weight/Vol so use isc_trn_000_mv
    'C11','C21' - Rated Freight Cost per Dist so use isc_trn_006_mv
    'BW1','BX1' - On-Time Arrival Rate/Trend so use isc_trn_001_mv
    'BP1' - Trip Stop Arrival Performance Trend: use isc_trn_001_mv
    'BP2' - Trip Stop Arrival Performance Trend: use isc_trn_002_mv
    'BT1','BU1' - Freight Cost Recovery Rate: use isc_trn_005_mv or isc_dbi_fm_0000_mv
    'RS1' - WMS Release To Ship: use isc_wms_000_mv
    'RS2' - WMS Release To Ship: use isc_wms_001_mv

*/
FUNCTION get_mv (p_mv_set IN VARCHAR2,
         p_mv_level_flag IN VARCHAR2,
         p_view_by IN VARCHAR2,
         p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2

IS
    l_mv_name VARCHAR2(1000);
    l_bt1_mv  VARCHAR2(1000);
    l_item_val VARCHAR2 (120);
    l_cust_val VARCHAR2 (120);
    l_item_needed boolean;
    l_cust_needed boolean;

BEGIN
    l_mv_name := '';
    l_bt1_mv := '';
    l_item_val := NULL;
    l_cust_val := NULL;
    l_item_needed:=false;
    l_cust_needed:=false;


    -- For Freight Cost Recovery Rate Report/Trend, figure out which MV to hit
    IF (p_mv_set = 'BT1' OR p_mv_set = 'BU1' ) THEN

        IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
        END IF;

        IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
            l_cust_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
        END IF;

        -- If customer or item is needed, use isc_dbi_fm_0000_mv, else use isc_trn_005_mv
        IF ( (l_item_val IS NULL OR l_item_val = 'All')
                AND p_view_by <> 'ITEM+ENI_ITEM_ORG') THEN
            l_item_needed := false;
        ELSE l_item_needed := true;
        END IF;

        IF ( (l_cust_val IS NULL OR l_cust_val = 'All')
                    AND p_view_by <> 'CUSTOMER+FII_CUSTOMERS') THEN
            l_cust_needed := false;
        ELSE l_cust_needed := true;
        END IF;

        IF ( l_cust_needed OR l_item_needed ) THEN
            l_bt1_mv:='isc_dbi_fm_0000_mv';
        ELSE l_bt1_mv:= 'isc_trn_005_mv';
        END IF;
    END IF;

    -- Based on the program calling, use different MVs
    l_mv_name :=
        (CASE p_mv_set
            WHEN 'BQ1' THEN 'isc_trn_000_mv'
            WHEN 'BW1' THEN 'isc_trn_001_mv'
            WHEN 'BX1' THEN 'isc_trn_001_mv'
            WHEN 'BY1' THEN 'isc_trn_000_mv'
            WHEN 'BZ1' THEN 'isc_trn_000_mv'
            WHEN 'C01' THEN 'isc_trn_000_mv'
            WHEN 'C11' THEN 'isc_trn_006_mv'
            WHEN 'C21' THEN 'isc_trn_006_mv'
            WHEN 'BP1' THEN 'isc_trn_001_mv'
            WHEN 'BP2' THEN 'isc_trn_002_mv'
            WHEN 'C31' THEN 'isc_trn_003_mv'
	    WHEN 'C32' THEN 'isc_trn_004_mv'
	    WHEN 'C41' THEN 'isc_trn_003_mv'
	    WHEN 'C42' THEN 'isc_trn_004_mv'
            WHEN 'BT1' THEN l_bt1_mv
            WHEN 'BU1' THEN l_bt1_mv
            WHEN 'RS1' THEN 'isc_wms_000_mv'
            WHEN 'RS2' THEN 'isc_wms_001_mv'
            ELSE ''
        END);

    RETURN l_mv_name;

END get_mv;

/*++++++++++++++++++++++++++++++++++++++++*/
/* Function to add extra where clauses if needed
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_additional_where_clause

    This function adds additional filter conditions
    Used when p_mv_set:
    'BT1','BU1' - Freight Cost Recovery Rate -  filter on top_node_flag if it is needed and specifies the extra where
       clauses if hitting ISC_DBI_FM_0000_MV and prod cat has been specified.

*/
FUNCTION get_additional_where_clause (p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
         p_mv_set IN VARCHAR2,p_view_by IN VARCHAR2)
    RETURN VARCHAR2

IS
    l_item_val VARCHAR2 (120);
    l_cust_val VARCHAR2 (120);
    l_pcat_val VARCHAR2 (120);
    l_item_needed boolean;
    l_cust_needed boolean;
    l_where_clause VARCHAR2 (10000);

BEGIN

    l_where_clause := '';

    -- For Freight Cost Recovery Rate Report/Trend, figure out if top_node_flag where clause is needed
    IF (p_mv_set = 'BT1' OR p_mv_set = 'BU1' ) THEN
	l_where_clause := ' AND (fact.freight_charge_amt_g is not null OR fact.freight_cost_amt_g is not null)';
        IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
            l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
        END IF;

        IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
            l_cust_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
        END IF;

        IF (p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN
            l_pcat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
        END IF;

        -- Top node Where clause is only needed when isc_trn_005_mv is used and Product Category is 'All'
        IF ( (l_item_val IS NULL OR l_item_val = 'All')
                AND p_view_by <> 'ITEM+ENI_ITEM_ORG') THEN
            l_item_needed := false;
        ELSE l_item_needed := true;
        END IF;

        IF ( (l_cust_val IS NULL OR l_cust_val = 'All')
                    AND p_view_by <> 'CUSTOMER+FII_CUSTOMERS') THEN
            l_cust_needed := false;
        ELSE l_cust_needed := true;
        END IF;

        IF ( NOT l_cust_needed AND NOT l_item_needed ) THEN
            IF (l_pcat_val IS NULL OR l_pcat_val = 'All') THEN
                l_where_clause := l_where_clause || '
                   AND fact.top_node_flag = ''Y'' ';
            END IF;
        END IF;

        -- Only	add this where clause if the prod cat is specified
        IF NOT (l_pcat_val IS NULL OR l_pcat_val = 'All') THEN
          IF l_cust_needed OR l_item_needed THEN -- extra joins are needed if hitting ISC_DBI_FM_0000_MV
            l_where_clause := l_where_clause || ' AND fact.prod_category_id = eni_cat.child_id
	          AND eni_cat.parent_id IN &ITEM+ENI_ITEM_VBH_CAT
	          AND eni_cat.dbi_flag = ''Y''
	          AND eni_cat.object_type = ''CATEGORY_SET''
	          AND eni_cat.object_id = mdcs.category_set_id
	          AND mdcs.functional_area_id = 11 ';
          ELSE l_where_clause := l_where_clause || ' AND fact.prod_category_id in &ITEM+ENI_ITEM_VBH_CAT ';
          END IF;
        END IF;

    END IF;

    RETURN l_where_clause;

END get_additional_where_clause;


PROCEDURE populate_in_join_tbl(
	  p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
	  p_view_by in VARCHAR2,
          p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
 IS

    l_in_join_rec poa_dbi_util_pkg.POA_DBI_IN_JOIN_REC;
    l_pcat_val VARCHAR2 (120);
    l_cust_val VARCHAR2 (120);
    l_item_val VARCHAR2 (120);
    l_item_needed boolean;
    l_cust_needed boolean;

 BEGIN

     p_in_join_tbl := poa_dbi_util_pkg.poa_dbi_in_join_tbl();

     IF (p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN
         l_pcat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
     END IF;

     IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
         l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
     END IF;

     IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
         l_cust_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
     END IF;

     IF ( (l_item_val IS NULL OR l_item_val = 'All')
             AND p_view_by <> 'ITEM+ENI_ITEM_ORG') THEN
         l_item_needed := false;
     ELSE l_item_needed := true;
     END IF;

     IF ( (l_cust_val IS NULL OR l_cust_val = 'All')
                 AND p_view_by <> 'CUSTOMER+FII_CUSTOMERS') THEN
         l_cust_needed := false;
     ELSE l_cust_needed := true;
     END IF;

     -- If a product category has been specified and you're hitting ISC_DBI_FM_0000_MV
     IF (l_item_needed OR l_cust_needed) AND
        NOT (l_pcat_val IS NULL OR l_pcat_val = 'All') THEN
       l_in_join_rec.table_name := 'eni_denorm_hierarchies';
       l_in_join_rec.table_alias := 'eni_cat';
       p_in_join_tbl.extend;
       p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

       l_in_join_rec.table_name := 'mtl_default_category_sets';
       l_in_join_rec.table_alias := 'mdcs';
       p_in_join_tbl.extend;
       p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

    END IF;

 END populate_in_join_tbl;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Setting up list of dimensions to track
/*++++++++++++++++++++++++++++++++++++++++*/
/*  init_dim_map

    Initialize the dimension map with all needed dimensions.

    This function needs to keep track of all possible dimensions
    the DBI 7.1 reports are interested in. The POA utility package
    get_parameter_values functions looks at the parameter table
    passed in by PMV. For parameters names for which it finds a
    matching key in this dimension map table, it records the value.
    In other words, if the dimension map does not have an entry for
    ORGANIZATION+ORGANIZATION, then PMV's organization parameter
    will never be recorded.

    For ISC's DBI 7.1, the needed dimensions levels are:
    ORGANIZATION+ORGANIZATION - Organization
    ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE - Transportation Mode
    ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER - Freight Carrier
    ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL - Service Level
    CURRENCY+FII_CURRENCIES - Currency
    ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION - Shipment Direction
    ITEM+ENI_ITEM_INV_CAT - Inventory Category
    ITEM+ENI_ITEM_ORG - Item
    ITEM+ENI_ITEM_VBH_CAT - Product Category
    CUSTOMER+FII_CUSTOMERS - Customers
    ORGANIZATION+ORGANIZATION_SUBINVENTORY - Subinventory
    ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION - Unsecured Organization


*/
PROCEDURE init_dim_map (p_dim_map out NOCOPY
                            poa_dbi_util_pkg.poa_dbi_dim_map,
                        p_mv_set IN VARCHAR2)
IS

    l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

BEGIN

    -- Inventory Category dimension level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_INV_CAT');
    l_dim_rec.view_by_table := get_table ('ITEM+ENI_ITEM_INV_CAT');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ITEM+ENI_ITEM_INV_CAT') := l_dim_rec;

    -- Item dimension level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_ORG');
    l_dim_rec.view_by_table := get_table ('ITEM+ENI_ITEM_ORG');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ITEM+ENI_ITEM_ORG') := l_dim_rec;

    -- Organzation dimension level
    l_dim_rec.col_name := get_col_name ('ORGANIZATION+ORGANIZATION');
    l_dim_rec.view_by_table := get_table('ORGANIZATION+ORGANIZATION');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+ORGANIZATION') := l_dim_rec;

    -- Unsecured Organzation dimension level
    l_dim_rec.col_name := get_col_name ('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION');
    l_dim_rec.view_by_table := get_table('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION') := l_dim_rec;

    -- Mode dimension level
    l_dim_rec.col_name := get_col_name ('ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE');
    l_dim_rec.view_by_table := get_table('ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE') := l_dim_rec;

    -- Carrier Dimension Level
    l_dim_rec.col_name := get_col_name ('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER');
    l_dim_rec.view_by_table := get_table('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER') := l_dim_rec;

    -- Service Level Dimension Level
    l_dim_rec.col_name := get_col_name ('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL');
    l_dim_rec.view_by_table := get_table('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL') := l_dim_rec;

    -- Shipment Direction Dimension Level
    l_dim_rec.col_name := get_col_name ('ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION');
    l_dim_rec.view_by_table := get_table('ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION') := l_dim_rec;

    -- Product Category Dimension Level
    l_dim_rec.col_name := get_col_name ('ITEM+ENI_ITEM_VBH_CAT');
    l_dim_rec.view_by_table := get_table('ITEM+ENI_ITEM_VBH_CAT');
    l_dim_rec.generate_where_clause := 'N';
    p_dim_map('ITEM+ENI_ITEM_VBH_CAT') := l_dim_rec;

    -- Customer dimension level
    l_dim_rec.col_name := get_col_name ('CUSTOMER+FII_CUSTOMERS');
    l_dim_rec.view_by_table := get_table('CUSTOMER+FII_CUSTOMERS');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('CUSTOMER+FII_CUSTOMERS') := l_dim_rec;

    -- Subinventory dimension level
    l_dim_rec.col_name := get_col_name ('ORGANIZATION+ORGANIZATION_SUBINVENTORY');
    l_dim_rec.view_by_table := get_table('ORGANIZATION+ORGANIZATION_SUBINVENTORY');
    l_dim_rec.generate_where_clause := 'Y';
    p_dim_map('ORGANIZATION+ORGANIZATION_SUBINVENTORY') := l_dim_rec;

END init_dim_map;


/*++++++++++++++++++++++++++++++++++++++++*/
/* Dimension level join tables and columns
/*++++++++++++++++++++++++++++++++++++++++*/
/*  get_col_name

    Get the column name of the viewby join tables that the query will
    have to join to.
*/
FUNCTION get_col_name (p_dim_name VARCHAR2)
    RETURN VARCHAR2
IS

  l_col_name VARCHAR2(100);

BEGIN

  l_col_name :=
    (CASE p_dim_name
        WHEN 'ORGANIZATION+ORGANIZATION' THEN 'inv_org_id'
        WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN 'inv_org_id'
        WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN 'item_category_id'
        WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN 'prod_category_id'--product category
        WHEN 'ITEM+ENI_ITEM_ORG' THEN 'item_id'
        WHEN 'CUSTOMER+FII_CUSTOMERS' THEN 'customer_id'
        WHEN 'ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE' THEN 'mode_of_transport'
        WHEN 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER' THEN 'carrier_id'
        WHEN 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL' THEN 'service_level'
        WHEN 'ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION' THEN 'shipment_direction'
	WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN 'subinventory_code'
        ELSE ''
    END);

  RETURN l_col_name;

END get_col_name;

/*++++++++++++++++++++++++++++++++++++++++*/
/* Dimension level columns
/*++++++++++++++++++++++++++++++++++++++++*/
/*  update_col_name

    Update the name of the viewby dimension columns the report will
    hit in the MVs.
*/
PROCEDURE update_col_name (p_dim_map IN out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map, p_mv_set IN VARCHAR2, p_dim_name VARCHAR2)
IS

  l_pcat_val VARCHAR2 (120);
  l_item_val VARCHAR2 (120);
  l_cust_val VARCHAR2 (120);
  l_item_needed boolean;
  l_cust_needed boolean;

BEGIN

  -- For Freight Cost Recovery Rate Report, we will use prod_category_id or imm_child_id when viewby=prod cat
  IF ( p_mv_set = 'BT1' AND p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
        l_cust_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
    END IF;

    IF ( (l_item_val IS NULL OR l_item_val = 'All')
                AND p_dim_name <> 'ITEM+ENI_ITEM_ORG') THEN
        l_item_needed := false;
    ELSE l_item_needed := true;
    END IF;

    IF ( (l_cust_val IS NULL OR l_cust_val = 'All')
                AND p_dim_name <> 'CUSTOMER+FII_CUSTOMERS') THEN
        l_cust_needed := false;
    ELSE l_cust_needed := true;
    END IF;


    l_pcat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
    -- We want to use imm_child_id column when we are hitting ISC_TRN_005_MV (when neither item or customer are needed)
    IF ( NOT (l_pcat_val IS NULL OR l_pcat_val = 'All') AND
             NOT l_cust_needed AND
             NOT l_item_needed) THEN
        p_dim_map('ITEM+ENI_ITEM_VBH_CAT').col_name := 'imm_child_id';
    END IF;
  END IF;

END update_col_name;


/*  get_table

    Return the join table based on the dimension
        Product Category - eni_item_vbh_cat_v
        Customer - fii_customers_v
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
            WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN 'opi_inv_unsec_organizations_v'
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN 'fii_customers_v'
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN 'eni_item_vbh_nodes_v'
            WHEN 'ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE' THEN 'isc_transportation_mode_v'
            WHEN 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER' THEN 'isc_freight_carrier_v'
            WHEN 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL' THEN 'isc_carrier_service_level_v'
            WHEN 'ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION' THEN 'isc_shipment_direction_v'
	    WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN 'opi_subinventories_v'
            ELSE ''
        END);

    RETURN l_table;

END get_table;

/*  Function: get_join_info
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
        WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_ORG' THEN
             'id'
        WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
             'id'
        WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
             'id'
	WHEN 'ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE' THEN
             'id'
	WHEN 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER' THEN
             'id'
	WHEN 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL' THEN
             'id'
	WHEN 'ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION' THEN
             'id'
	WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
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

    l_join_rec.additional_where_clause :=
    (CASE p_view_by
        WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
             ' v.parent_id = v.child_id '
    END);

    -- Add the join table
    x_join_tbl.extend;
    x_join_tbl(x_join_tbl.count) := l_join_rec;

    -- Get the uom join
    IF (p_view_by = 'ITEM+ENI_ITEM_ORG') THEN
        l_join_rec.table_name := 'mtl_units_of_measure_vl';
        l_join_rec.table_alias := 'v2';
        l_join_rec.fact_column :='uom';
        l_join_rec.column_name := 'uom_code';
        l_join_rec.dim_outer_join := 'N';

        x_join_tbl.extend;
        x_join_tbl(x_join_tbl.count) := l_join_rec;
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
            WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN
                ' v.value'
            WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
                ' v.value'
            WHEN 'ITEM+ENI_ITEM_ORG' THEN
                ' v.value'
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
                ' v.value'
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
                ' v.value'
            WHEN 'ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE' THEN
                ' v.value'
            WHEN 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL' THEN
                ' v.value'
            WHEN 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER' THEN
                ' v.value'
            WHEN 'ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION' THEN
                ' v.value'
            WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
                ' v.value'
            ELSE ' '
        END);

    RETURN l_col_name;
END get_view_by_col_name;

FUNCTION get_view_by_select_clause (p_viewby IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_view_by_sel VARCHAR2(200);
    l_view_by_col VARCHAR2 (100);
BEGIN

    l_view_by_col := get_view_by_col_name (p_viewby);

    l_view_by_sel :=
        (CASE p_viewby
            WHEN 'ORGANIZATION+ORGANIZATION' THEN
                 l_view_by_col || ' VIEWBY,
                 v.id VIEWBYID, '
            WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN
                 l_view_by_col || ' VIEWBY,
                 v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_INV_CAT' THEN
                 l_view_by_col || ' VIEWBY,
                  v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_ORG' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ITEM+ENI_ITEM_VBH_CAT' THEN
                 l_view_by_col || ' VIEWBY,
                  v.id VIEWBYID, '
            WHEN 'CUSTOMER+FII_CUSTOMERS' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ISC_SHIPMENT_DIRECTION+ISC_SHIPMENT_DIRECTION' THEN
                 l_view_by_col || ' VIEWBY ,
                  v.id VIEWBYID, '
            WHEN 'ORGANIZATION+ORGANIZATION_SUBINVENTORY' THEN
                 l_view_by_col || ' VIEWBY,
                 v.id VIEWBYID, '
            ELSE ''
        END);

    return l_view_by_sel;

END get_view_by_select_clause;

/*++++++++++++++++++++++++++++++++++++++++*/
/* MV level aggregation flag
/*++++++++++++++++++++++++++++++++++++++++*/

/*  get_mv_level_flag

    Return the MV level flag based on what is requested in p_mv_flag_type:
    'FLAG1' -  flag for service_level, unsecured organization, carrier.
    'FLAG2' -  flag for service_level, carrier.
    'FLAG3' -  flag for unsecured org, item, prod cat, and customer
    'FLAG4' -  flag for subinventory, inventory category
    'FLAG5' -  flag for inventory category, item
*/
FUNCTION get_mv_level_flag (p_mv_flag_type VARCHAR2,
                            p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_mv_level_flag VARCHAR2 (10);

BEGIN

    l_mv_level_flag :=
        (CASE p_mv_flag_type
            WHEN  'FLAG1' THEN
                get_flag_one_val (p_dim_name, p_dim_map)
            WHEN  'FLAG2' THEN
                get_flag_two_val (p_dim_name, p_dim_map)
            WHEN  'FLAG3' THEN
                get_flag_three_val (p_dim_name, p_dim_map)
            WHEN  'FLAG4' THEN
                get_flag_four_val (p_dim_name, p_dim_map)
            WHEN  'FLAG5' THEN
                get_flag_five_val (p_dim_name, p_dim_map)
            ELSE
                ''
        END);

    RETURN l_mv_level_flag;

END get_mv_level_flag;



/* get_flag_one_val

    Compute the flag1 value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_flag_one_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_flag_one varchar2(1);

    l_org_val VARCHAR2 (120);
    l_mode_val VARCHAR2 (120);
    l_serv_val VARCHAR2 (120);
    l_carrier_val VARCHAR2 (120);

    l_org_needed boolean;
    l_serv_needed boolean;
    l_carrier_needed boolean;

BEGIN

    l_org_val := NULL;
    l_mode_val := NULL;
    l_serv_val := NULL;
    l_carrier_val := NULL;

    l_org_needed :=false;
    l_serv_needed :=false;
    l_carrier_needed :=false;

    -- Get the mode, service_level, unsecured org, and carrier values
    IF (p_dim_map.exists ('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE')) THEN
        l_mode_val := p_dim_map ('ISC_TRANSPORTATION_MODE+ISC_TRANSPORTATION_MODE').value;
    END IF;

    IF (p_dim_map.exists ('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL')) THEN
        l_serv_val := p_dim_map ('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL').value;
    END IF;

    IF (p_dim_map.exists ('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER')) THEN
        l_carrier_val := p_dim_map ('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER').value;
    END IF;

    -- Find out which dimensions are needed to hit the proper grouping sets in the MVs
    IF ( l_org_val IS NULL OR l_org_val = 'All' ) THEN
        l_org_needed := false;
    ELSE l_org_needed := true;
    END IF;

    IF ( (l_serv_val IS NULL OR l_serv_val = 'All')
                 AND p_dim_name <> 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL') THEN
        l_serv_needed := false;
    ELSE l_serv_needed := true;
    END IF;

    IF ( (l_carrier_val IS NULL OR l_carrier_val = 'All')
                 AND p_dim_name <> 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER') THEN
        l_carrier_needed := false;
    ELSE l_carrier_needed := true;
    END IF;

    -- Calculate the flag values depending on which dimensions are needed
    CASE
        WHEN (    l_serv_needed AND     l_org_needed AND     l_carrier_needed) THEN l_flag_one := 0;
        WHEN (    l_serv_needed AND     l_org_needed AND NOT l_carrier_needed) THEN l_flag_one := 1;
        WHEN (    l_serv_needed AND NOT l_org_needed AND     l_carrier_needed) THEN l_flag_one := 2;
        WHEN (    l_serv_needed AND NOT l_org_needed AND NOT l_carrier_needed) THEN l_flag_one := 3;
        WHEN (NOT l_serv_needed AND     l_org_needed AND     l_carrier_needed) THEN l_flag_one := 4;
        WHEN (NOT l_serv_needed AND     l_org_needed AND NOT l_carrier_needed) THEN l_flag_one := 5;
        WHEN (NOT l_serv_needed AND NOT l_org_needed AND     l_carrier_needed) THEN l_flag_one := 6;
        WHEN (NOT l_serv_needed AND NOT l_org_needed AND NOT l_carrier_needed) THEN l_flag_one := 7;
    END CASE;

    RETURN l_flag_one;

END get_flag_one_val;

/* get_flag_two_val

    Compute the flag2 value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_flag_two_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_flag_two varchar2(1);

    l_serv_val VARCHAR2 (120);
    l_carrier_val VARCHAR2 (120);

    l_serv_needed boolean;
    l_carrier_needed boolean;

BEGIN

    l_serv_val := NULL;
    l_carrier_val := NULL;

    l_serv_needed:=false;
    l_carrier_needed:=false;

    -- Get the service_level, and carrier values
    IF (p_dim_map.exists ('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL')) THEN
        l_serv_val := p_dim_map ('ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL').value;
    END IF;

    IF (p_dim_map.exists ('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER')) THEN
        l_carrier_val := p_dim_map ('ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER').value;
    END IF;

    -- Find out which dimensions are needed to hit the proper grouping sets in the MVs
    IF ( (l_serv_val IS NULL OR l_serv_val = 'All')
                 AND p_dim_name <> 'ISC_CARRIER_SERVICE_LEVEL+ISC_CARRIER_SERVICE_LEVEL') THEN
        l_serv_needed := false;
    ELSE l_serv_needed := true;
    END IF;

    IF ( (l_carrier_val IS NULL OR l_carrier_val = 'All')
                 AND p_dim_name <> 'ISC_FREIGHT_CARRIER+ISC_FREIGHT_CARRIER') THEN
        l_carrier_needed := false;
    ELSE l_carrier_needed := true;
    END IF;

    -- Calculate the flag values depending on which dimensions are needed
    CASE
        WHEN (    l_serv_needed  AND     l_carrier_needed) THEN l_flag_two := 0;
        WHEN (    l_serv_needed  AND NOT l_carrier_needed) THEN l_flag_two := 1;
        WHEN (NOT l_serv_needed  AND     l_carrier_needed) THEN l_flag_two := 2;
        WHEN (NOT l_serv_needed  AND NOT l_carrier_needed) THEN l_flag_two := 3;
    END CASE;

    RETURN l_flag_two;

END get_flag_two_val;

/* get_flag_three_val

    Compute the flag_three value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_flag_three_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_flag_three varchar2(1);

    l_org_val VARCHAR2 (120);
    l_pcat_val VARCHAR2 (120);
    l_item_val VARCHAR2 (120);
    l_cust_val VARCHAR2 (120);

    l_org_needed boolean;
    l_pcat_needed boolean;
    l_item_needed boolean;
    l_cust_needed boolean;

BEGIN

    l_org_val := NULL;
    l_pcat_val := NULL;
    l_item_val := NULL;
    l_cust_val := NULL;

    l_org_needed:=false;
    l_pcat_needed:=false;
    l_item_needed:=false;
    l_cust_needed:=false;

    -- Get the unsecured org, item, cat, and cust values
    IF (p_dim_map.exists ('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION')) THEN
        l_org_val := p_dim_map ('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_VBH_CAT')) THEN
        l_pcat_val := p_dim_map ('ITEM+ENI_ITEM_VBH_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF (p_dim_map.exists ('CUSTOMER+FII_CUSTOMERS')) THEN
        l_cust_val := p_dim_map ('CUSTOMER+FII_CUSTOMERS').value;
    END IF;

    -- Find out which dimensions are needed to hit the proper grouping sets in the MVs
    IF ( (l_org_val IS NULL OR l_org_val = 'All')
                AND p_dim_name <> 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION') THEN
        l_org_needed := false;
    ELSE l_org_needed := true;
    END IF;

    IF ( (l_pcat_val IS NULL OR l_pcat_val = 'All')
                AND p_dim_name <> 'ITEM+ENI_ITEM_VBH_CAT') THEN
        l_pcat_needed := false;
    ELSE l_pcat_needed := true;
    END IF;

    IF ( (l_item_val IS NULL OR l_item_val = 'All')
                AND p_dim_name <> 'ITEM+ENI_ITEM_ORG') THEN
        l_item_needed := false;
    ELSE l_item_needed := true;
    END IF;

    IF ( (l_cust_val IS NULL OR l_cust_val = 'All')
                AND p_dim_name <> 'CUSTOMER+FII_CUSTOMERS') THEN
        l_cust_needed := false;
    ELSE l_cust_needed := true;
    END IF;

    -- Calculate the flag values depending on which dimensions are needed
    CASE
        WHEN (    l_cust_needed AND     l_item_needed AND     l_pcat_needed AND     l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND     l_item_needed AND     l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND     l_item_needed AND NOT l_pcat_needed AND     l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND     l_item_needed AND NOT l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND NOT l_item_needed AND     l_pcat_needed AND     l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND NOT l_item_needed AND     l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 0;
        WHEN (    l_cust_needed AND NOT l_item_needed AND NOT l_pcat_needed AND     l_org_needed) THEN l_flag_three := 2;
        WHEN (    l_cust_needed AND NOT l_item_needed AND NOT l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 2;
        WHEN (NOT l_cust_needed AND     l_item_needed AND     l_pcat_needed AND     l_org_needed) THEN l_flag_three := 1;
        WHEN (NOT l_cust_needed AND     l_item_needed AND     l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 1;
        WHEN (NOT l_cust_needed AND     l_item_needed AND NOT l_pcat_needed AND     l_org_needed) THEN l_flag_three := 1;
        WHEN (NOT l_cust_needed AND     l_item_needed AND NOT l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 1;
        WHEN (NOT l_cust_needed AND NOT l_item_needed AND     l_pcat_needed AND     l_org_needed) THEN l_flag_three := 0;
        WHEN (NOT l_cust_needed AND NOT l_item_needed AND     l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 1;
        WHEN (NOT l_cust_needed AND NOT l_item_needed AND NOT l_pcat_needed AND     l_org_needed) THEN l_flag_three := 0;
        WHEN (NOT l_cust_needed AND NOT l_item_needed AND NOT l_pcat_needed AND NOT l_org_needed) THEN l_flag_three := 1;
    END CASE;

    RETURN l_flag_three;

END get_flag_three_val;

/* get_flag_four_val

    Compute the flag_four value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_flag_four_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_flag_four varchar2(1);

    l_sub_val VARCHAR2 (120);
    l_cat_val VARCHAR2 (120);
    l_item_val VARCHAR2 (120);

BEGIN

    l_sub_val := NULL;
    l_cat_val := NULL;
    l_item_val := NULL;

    -- Get the subinventory, category, and item values
    IF (p_dim_map.exists ('ORGANIZATION+ORGANIZATION_SUBINVENTORY')) THEN
        l_sub_val := p_dim_map ('ORGANIZATION+ORGANIZATION_SUBINVENTORY').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;

    IF ((l_item_val IS NULL OR l_item_val = 'All') AND (l_cat_val IS NULL OR l_cat_val = 'All'))
      THEN
        IF (p_dim_name = 'ITEM+ENI_ITEM_ORG' OR p_dim_name = 'ITEM+ENI_ITEM_INV_CAT')
  	  THEN l_flag_four := '0';
        ELSIF (p_dim_name = 'ORGANIZATION+ORGANIZATION_SUBINVENTORY')
          THEN l_flag_four := '3';
        ELSE
	  IF (l_sub_val IS NULL OR l_sub_val = 'All')
	    THEN l_flag_four := '7';
	  ELSE l_flag_four := '3';
	  END IF;
        END IF;
    ELSE
      l_flag_four := '0';
    END IF;

    RETURN l_flag_four;

END get_flag_four_val;

/* get_flag_five_val

    Compute the flag5 value based on the parameters passed to
    determine the aggregation level of the MV rows that the query will
    have to run against.
*/
FUNCTION get_flag_five_val (p_dim_name VARCHAR2,
                            p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map)
    RETURN VARCHAR2
IS

    l_flag_five varchar2(1);

    l_cat_val VARCHAR2 (120);
    l_item_val VARCHAR2 (120);

BEGIN

    l_cat_val := NULL;
    l_item_val := NULL;

    -- Get the category and item values
    IF (p_dim_map.exists ('ITEM+ENI_ITEM_INV_CAT')) THEN
        l_cat_val := p_dim_map ('ITEM+ENI_ITEM_INV_CAT').value;
    END IF;

    IF (p_dim_map.exists ('ITEM+ENI_ITEM_ORG')) THEN
        l_item_val := p_dim_map ('ITEM+ENI_ITEM_ORG').value;
    END IF;


    IF (l_item_val IS NULL OR l_item_val = 'All')
      THEN
        IF (p_dim_name = 'ITEM+ENI_ITEM_ORG')
  	  THEN l_flag_five := '0'; -- item
        ELSIF (p_dim_name = 'ITEM+ENI_ITEM_INV_CAT')
          THEN l_flag_five := '1'; -- inventory category
        ELSE
	  IF (l_cat_val IS NULL OR l_cat_val = 'All')
	    THEN l_flag_five := '3'; -- all
	  ELSE l_flag_five := '1'; -- inventory category
	  END IF;
        END IF;
    ELSE
      l_flag_five := '0'; -- item
    END IF;

    RETURN l_flag_five;

END get_flag_five_val;

/* rate_str

    Gets the string for percentage/ratio change of two specified strings.
    Better than copying CASE statements everywhere
*/
FUNCTION rate_str (p_numerator IN VARCHAR2,
                      p_denominator IN VARCHAR2,
                      p_rate_type IN VARCHAR2,
                      p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_nvl_denominator VARCHAR2 (100);
    l_nvl_numerator VARCHAR2 (100);

BEGIN

    l_nvl_denominator  := 'nvl('||p_denominator||',0)';
    l_nvl_numerator  := 'nvl('||p_numerator||',0)';

        -- if rate is a ratio
        if(p_rate_type = 'RATIO') then
          return 'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
           ' || ' ELSE (' || l_nvl_numerator || '/' || p_denominator || ')
           ' || 'END
           ' || p_measure_name || ' ';
        end if;

        -- if rate is a percent
        return 'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
         ' || ' ELSE (' || l_nvl_numerator || '/' || p_denominator || ') * 100
         ' || 'END
         ' || p_measure_name || ' ';

END rate_str;

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
    l_percentage_calc VARCHAR2 (600);
    l_nvl_denominator VARCHAR2 (100);
    l_nvl_numerator VARCHAR2 (100);

BEGIN

    l_nvl_denominator  := 'nvl('||p_denominator||',0)';
    l_nvl_numerator  := 'nvl('||p_numerator||',0)';

    l_percentage_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' <= 0 THEN to_number (NULL)
        ' || ' ELSE (' || l_nvl_numerator || '/' || p_denominator || ') *100
        ' || 'END
        ' || p_measure_name || ' ';

    return l_percentage_calc;

END pos_denom_percent_str;


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
    l_change_calc VARCHAR2 (1000);
    l_nvl_denominator VARCHAR2 (1000);
    l_nvl_new_numerator VARCHAR2 (1000);
    l_nvl_old_numerator VARCHAR2 (1000);

BEGIN

    l_nvl_denominator := 'nvl('||p_denominator||',0)';
    l_nvl_new_numerator := 'nvl('||p_new_numerator||',0)';
    l_nvl_old_numerator := 'nvl('||p_old_numerator||',0)';

    l_change_calc :=
        'CASE WHEN ' || l_nvl_denominator || ' = 0 THEN to_number (NULL)
        ' || '     ELSE ((' || l_nvl_new_numerator || ' - ' || l_nvl_old_numerator
          || ')/ abs (' || p_denominator || ')) * 100
        ' || '     END			' || p_measure_name || ' ';

    RETURN l_change_calc;
END change_str;


/* change_rate_str
    Get the change in percentage/ratio string. Better than writing out all the case
    statements
*/
FUNCTION change_rate_str (p_new_numerator IN VARCHAR2,
                         p_new_denominator IN VARCHAR2,
                         p_old_numerator IN VARCHAR2,
                         p_old_denominator IN VARCHAR2,
                         p_rate_type IN VARCHAR2,
                         p_measure_name IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_nvl_new_denominator VARCHAR2(1000);
    l_nvl_old_denominator VARCHAR2(1000);
    l_nvl_new_numerator VARCHAR2(1000);
    l_nvl_old_numerator VARCHAR2(1000);

BEGIN

    l_nvl_new_denominator := 'nvl('||p_new_denominator||',0)';
    l_nvl_old_denominator := 'nvl('||p_old_denominator||',0)';
    l_nvl_new_numerator := 'nvl('||p_new_numerator||',0)';
    l_nvl_old_numerator := 'nvl('||p_old_numerator||',0)';

        -- if rate is a ratio
        if(p_rate_type = 'RATIO') then
          return  'CASE WHEN ' || l_nvl_old_denominator || ' = 0 THEN to_number (NULL)
           ' || 'WHEN ' || l_nvl_new_denominator || ' = 0 THEN to_number (NULL)
           ' || ' ELSE ((' || l_nvl_new_numerator || '/'
                           || l_nvl_new_denominator ||
           ') -
           ' || '(' || l_nvl_old_numerator || '/'
                    || l_nvl_old_denominator || '))
           ' || 'END
           ' || p_measure_name || ' ';
        end if;

        -- if rate is a percent
        return  'CASE WHEN ' || l_nvl_old_denominator || ' = 0 THEN to_number (NULL)
         ' || 'WHEN ' || l_nvl_new_denominator || ' = 0 THEN to_number (NULL)
         ' || ' ELSE ((' || l_nvl_new_numerator || '/'
                         || l_nvl_new_denominator ||
         ') -
         ' || '(' || l_nvl_old_numerator || '/'
                  || l_nvl_old_denominator || '))*100
         ' || 'END
         ' || p_measure_name || ' ';

END change_rate_str;


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


/* get_global_weight_uom
    Gets the global weight unit of measure
 */
FUNCTION get_global_weight_uom RETURN VARCHAR2
IS
    l_weight_uom VARCHAR2(400);
BEGIN

    select gu_weight_uom into l_weight_uom from wsh_global_parameters;

    RETURN l_weight_uom;

END get_global_weight_uom;


/* get_global_volume_uom
    Gets the global volume unit of measure
 */
FUNCTION get_global_volume_uom RETURN VARCHAR2
IS
    l_volume_uom VARCHAR2(400);
BEGIN

    select gu_volume_uom into l_volume_uom from wsh_global_parameters;

    RETURN l_volume_uom;

END get_global_volume_uom;


/* get_global_distance_uom
    Gets the global distance unit of measure
 */
FUNCTION get_global_distance_uom RETURN VARCHAR2
IS
    l_distance_uom VARCHAR2(400);
BEGIN

    select gu_distance_uom into l_distance_uom from wsh_global_parameters;

    RETURN l_distance_uom;

END get_global_distance_uom;

END ISC_DBI_SUTIL_PKG;

/

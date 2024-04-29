--------------------------------------------------------
--  DDL for Package ISC_DEPOT_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_RPT_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotutils.pls 120.0 2005/05/25 17:23:35 appldev noship $
-- for use in get_agg_flag function
TYPE mv_agg_tbl_typ is TABLE of NUMBER INDEX BY BINARY_INTEGER ;
TYPE bucket_range_typ is TABLE of NUMBER INDEX BY BINARY_INTEGER;


-- Global Variables needed in report query.
g_query_typ		VARCHAR2(32767);
g_view_by_typ		VARCHAR2(120);
g_view_by_col_typ	VARCHAR2(120);
g_xtd_typ		VARCHAR2(10);
g_where_clause_typ	VARCHAR2(2000);
g_mv_typ		VARCHAR2(5000);
g_module_name_typ	VARCHAR2(100);

-- Bit Map for each dimension arranged in ascending order of their cost
--(associated with aggregation on them)Grouping id of the mv is calculated
--with the dimensions placed in the same bit position as this

--------------------------------------------------------------------------
--      Repair Type		  -> 00001 -> 1
--      Repair Order Organization -> 00010 -> 2
--      Product Category	  -> 00100 -> 4
--      Customer		  -> 01000 -> 8
--      Item			  -> 10000 -> 16
--------------------------------------------------------------------------

C_REPAIR_TYPE_BMAP CONSTANT INTEGER := 1;
C_ORG_BMAP         CONSTANT INTEGER := 2;
C_CATEGORY_BMAP    CONSTANT INTEGER := 4;
C_CUSTOMER_BMAP    CONSTANT INTEGER := 8;
C_ITEM_BMAP        CONSTANT INTEGER := 16;
C_DEBUG_LEVEL CONSTANT INTEGER := 3;

--    process_parameters
--    Generic routine to process the parameters passed in from the PMV
--    page.
--    Date        Author              Action
--   02-Aug-2004 Vijay Babu Gandhi     created.

PROCEDURE process_parameters (p_param              IN      BIS_PMV_PAGE_PARAMETER_TBL,
                              x_view_by            OUT     NOCOPY VARCHAR2,
                              x_view_by_col_name   OUT     NOCOPY VARCHAR2,
                              x_comparison_type    OUT     NOCOPY VARCHAR2,
                              x_xtd                OUT     NOCOPY VARCHAR2,
                              x_cur_suffix         OUT     NOCOPY VARCHAR2,
                              x_where_clause       OUT     NOCOPY VARCHAR2,
                              x_mv                 OUT     NOCOPY VARCHAR2,
                              x_join_tbl           OUT     NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl,
                              x_mv_type            OUT     NOCOPY VARCHAR2,
                              x_aggregation_flag   OUT     NOCOPY NUMBER,
                              p_mv_set             IN      VARCHAR2,
                              p_trend              IN      VARCHAR2,
                              x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_BUCKET_WHERE_CLAUSE (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				   p_dim_level IN VARCHAR2,
				   p_bucket_short_name IN BIS_BUCKET.SHORT_NAME%TYPE,
				   p_col_name IN VARCHAR2,
				   x_where_clause IN OUT NOCOPY VARCHAR2,
				   x_custom_output OUT NOCOPY bis_query_attributes_tbl);

--    get_agg_flag
--    Generic routine to get the appropriate aggregation_flag for the selected parameters
--    Points of note:
--    Date        Author              Action
--   02-Aug-2004 Vijay Babu Gandhi     created.

FUNCTION get_agg_flag (p_mv_set IN VARCHAR2
                       ,p_dim_bmap IN NUMBER
                 ,p_mv_type IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_VIEWBY_SELECT_CLAUSE (p_viewby IN VARCHAR2)
RETURN VARCHAR2;

--    write
--    Generic routine for debug purpose
--    Date        Author              Action
--    02-Aug-2004 Vijay Babu Gandhi     created.

PROCEDURE write ( p_module	IN VARCHAR2,
		  p_err_stage   IN VARCHAR2,
		  p_debug_level IN INTEGER);

--    get_repair_order_url
--    routine for getting the url for repair order drill down
--    Date        Author              Action
--    25-Oct-2004 Vijay Babu Gandhi     created.

FUNCTION get_repair_order_url
RETURN VARCHAR2;

--    get_service_request_url
--    routine for getting the url for Service Request drill down
--    Date        Author              Action
--    25-Oct-2004 Vijay Babu Gandhi     created.

FUNCTION get_service_request_url
RETURN VARCHAR2;

END ISC_DEPOT_RPT_UTIL_PKG ;

 

/

--------------------------------------------------------
--  DDL for Package Body ISC_DEPOT_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DEPOT_RPT_UTIL_PKG" AS
-- $Header: iscdepotutilb.pls 120.1 2006/01/26 19:22:21 kreardon noship $

-- List of mv sets and their corresponding reports.
-- 'BKLG'    - Repair Order Backlog,Repair Order Backlog Trend,Repair Order Completion,
--	       Repair Order Completion Trend
-- 'BKLDTL1' - Repair Order Backlog detail
-- 'BKLDTL2' - Repair Order Past Due Detail
-- 'BKLAGN1' - Repair Order Past Due Aging
-- 'CMPAGN1' - Repair Order Late Completion Aging
-- 'CMPDTL1' - Repair Order Completion Detail
-- 'CMPDTL2' - Repair Order Late Completion Detail
-- 'COSTS'   - Repair Order Cost Summary,Repair Order Cost Summary Trend
-- 'CHARGES' - Repair Order Charges Summary, Repair Order Charges Summary Trend
-- 'MARGIN'  - Repair Order Margin, Repair Order Margin Trend,Repair Order Margin Summary,
--	       Repair Order Margin Summary Trend
-- 'MTTR'    - Mean Time To Repair Status & Trend Reports
-- 'SRVC'    - Repair Order Service Code Summary Report
-- 'MRGDTL'  -
-- 'MDTL'    - Mean Time To Repair Detail Report

-- Local Functions
PROCEDURE init_dim_map ( p_mv_set  IN VARCHAR2,
                         x_dim_map out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map);

PROCEDURE get_join_info (p_view_by   IN varchar2,
                         p_dim_map   IN poa_dbi_util_pkg.poa_dbi_dim_map,
                         x_join_tbl  OUT NOCOPY poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                         p_mv_set    IN VARCHAR2,
			 p_category_flag IN VARCHAR2 );

PROCEDURE get_mv (p_mv_set         IN  VARCHAR2,
                  p_pcategory_flag IN  VARCHAR2, -- to know if product category  is selected or not.
                  p_rtype_flag     IN  VARCHAR2, -- to know if repair type  is selected or not.
                  p_view_by        IN  VARCHAR2,
                  p_dim_bmap       IN  NUMBER,
                  x_mv_type        OUT NOCOPY VARCHAR2,
                  x_mv             OUT NOCOPY VARCHAR2) ;
PROCEDURE bind_low_high
(
  p_range_id 	  IN NUMBER
, p_short_name    IN varchar2
, p_dim_level	  IN varchar2
, p_low           IN varchar2
, p_high          IN varchar2
, p_custom_output IN OUT nocopy bis_query_attributes_tbl);

PROCEDURE GET_BUCKET_RANGE_ID (p_parameter_id IN VARCHAR2 ,
                               x_bucket_range_ids_tbl OUT NOCOPY bucket_range_typ);

PROCEDURE get_additional_whereclause( p_mv_set          IN VARCHAR2
                                    ,p_param            IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,p_pcategory_flag   IN VARCHAR2
                                    ,p_rtype_flag       IN VARCHAR2
				    ,p_repair_type	IN VARCHAR2
                                    ,p_bucket_flag      IN VARCHAR2
                                    ,x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                                    ,x_where_clause     OUT NOCOPY VARCHAR2);

--    process_parameters
--    Generic routine to process the parameters passed in from the PMV
--    page.
--    Points of note:
--    Date            Author            Action
--    02-Aug-2004  Vijay Babu Gandhi     created.
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
                              x_custom_output      OUT	   NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

IS
        l_dim_map                 poa_dbi_util_pkg.poa_dbi_dim_map;
        l_dim_bmap                NUMBER := 0;
        l_as_of_date              DATE;
        l_prev_as_of_date         DATE;
        l_not_used                NUMBER;
        l_pcategory_flag	  VARCHAR2(1);
        l_rtype_flag              VARCHAR2(1);
        l_bucket_selected_flag    VARCHAR2(1);
        l_additional_where_clause VARCHAR2(10000);
        l_err_stage               VARCHAR2(32767);
	l_repair_type             VARCHAR2(100);
	l_debug_mode              VARCHAR2(1);
	l_module_name             ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN
	l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name             := FND_PROFILE.value('AFLOG_MODULE');
	l_pcategory_flag	  := 'N';
        l_rtype_flag              := 'N';
        l_bucket_selected_flag    := 'N';

        -- initialize the dimension map with all the required dimensions.
        init_dim_map ( p_mv_set  => p_mv_set,
                       x_dim_map => l_dim_map);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='Before Calling Get Parameter Values' ;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;

        -- To find out if Product Category is selected or not.
        FOR i in 1..p_param.COUNT LOOP
            IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT' AND
                p_param(i).parameter_id is NOT null)  THEN
                l_pcategory_flag := 'Y';
                l_dim_map('ITEM+ENI_ITEM_VBH_CAT').col_name:= 'imm_child_id';
            END IF;

            -- -1 and -2 represent top node repair type
            IF( p_param(i).parameter_name = 'BIV_REPAIR_TYPE+BIV_REPAIR_TYPE' AND
                p_param(i).parameter_id is not null) THEN
		      l_repair_type := replace(p_param(i).parameter_id,'''',null);

		      IF (instr(l_repair_type,'-1') <> 0 AND instr(l_repair_type,'-2') <> 0 ) THEN
				l_rtype_flag := 'N'; -- This value is used till get_mv
		      ELSIF (instr(l_repair_type,'-1') <> 0 OR instr(l_repair_type,'-2') <> 0 ) THEN
				l_rtype_flag := 'Y'; -- This value is used till get_mv
		      ELSE
				l_dim_map('BIV_REPAIR_TYPE+BIV_REPAIR_TYPE').generate_where_clause := 'Y';
		      END IF;
            END IF;

            -- To find out if the bucket parameter is selected or not.
            IF(p_param(i).parameter_name = 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET' and p_param(i).parameter_id is not null)  THEN
                     l_bucket_selected_flag := 'Y';
            END IF;
        END LOOP;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='Before Calling Get Parameter Values  1' ;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;
        -- Get the various parameter values from the utility package.
        -- This package will also compute the l_dim_bmap
        poa_dbi_util_pkg.get_parameter_values (p_param           => p_param,                    --IN
                                               p_dim_map         => l_dim_map,                  --IN
                                               p_view_by         => x_view_by,                  --OUT
                                               p_comparison_type => x_comparison_type,          --OUT
                                               p_xtd             => x_xtd,                      --OUT
                                               p_as_of_date      => l_as_of_date,               --OUT
                                               p_prev_as_of_date => l_prev_as_of_date,          --OUT
                                               p_cur_suffix      => x_cur_suffix,               --OUT
                                               p_nested_pattern  => l_not_used,                 --OUT
                                               p_dim_bmap        => l_dim_bmap);                --OUT

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='Before Calling Get Parameter Values 3' ;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;
        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:='After Calling Get Parameter Values' || ' l_dim_bmap -> ' || l_dim_bmap
                                || '; x_view_by -> ' || x_view_by ;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;

        -- Find out the view by column name

        IF ( l_dim_map.exists(x_view_by)) THEN
              x_view_by_col_name := l_dim_map(x_view_by).col_name;
        END IF;

        -- get the join info for the view by dimension.
        IF ( x_view_by_col_name IS NOT NULL) THEN
            get_join_info (p_view_by  => x_view_by,
                           p_dim_map  => l_dim_map,
                           x_join_tbl => x_join_tbl,
                           p_mv_set   => p_mv_set,
			   p_category_flag => l_pcategory_flag );
        END IF;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage := 'After Calling Get join info';
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;


        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage := 'After looping through p_params';
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;


        -- Get the MV we need to join to.
        get_mv (p_mv_set        => p_mv_set,
                p_pcategory_flag => l_pcategory_flag,
                p_rtype_flag    => l_rtype_flag,
                p_view_by       => x_view_by,
                p_dim_bmap      => l_dim_bmap,
                x_mv_type       => x_mv_type,
                x_mv            => x_mv);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
                l_err_stage := substr(x_mv,0,2900);
                l_err_stage:= 'MV -> ' || l_err_stage;
                write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
                l_err_stage := 'x_mv_type = ' || x_mv_type;
                write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;

        -- Get the aggregation flag
        IF(p_mv_set IN ('BKLG','COSTS','CHARGES','MARGIN','MTTR','SRVC','CMPAGN1','BKLDUP1','BKLDUP2','BKLAGN1')) THEN
               x_aggregation_flag := get_agg_flag(p_mv_set,l_dim_bmap, x_mv_type);
                IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
                        l_err_stage := 'x_aggregation_flag = '|| x_aggregation_flag;
                        write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
                END IF;
        END IF;

        -- Get the dimension level specific where clauses
        x_where_clause := poa_dbi_util_pkg.get_where_clauses (p_dim_map => l_dim_map,
                                                              p_trend   => p_trend);

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:= 'x_where_clause before ''additional where clause'' -> ' || x_where_clause;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;

        -- Attach the where clause for bucket parameter
        get_additional_whereclause(  p_mv_set        => p_mv_set
                                    ,p_param         => p_param
                                    ,p_pcategory_flag => l_pcategory_flag
                                    ,p_rtype_flag    => l_rtype_flag
				    ,p_repair_type   => l_repair_type
                                    ,p_bucket_flag   => l_bucket_selected_flag
                                    ,x_custom_output => x_custom_output
                                    ,x_where_clause  => l_additional_where_clause);

        x_where_clause :=  x_where_clause || l_additional_where_clause;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:= 'x_where_clause -> ' || x_where_clause;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;
EXCEPTION
        WHEN OTHERS THEN

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage:=  l_err_stage || ' --->' || SQLERRM;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;
        RAISE;
END process_parameters;

-- Setting up list of dimensions to track
-- init_dim_map
-- Initialize the dimension map with all needed dimensions.

-- This function needs to keep track of all possible dimensions
-- the DBI 7.1 reports are interested in. The POA utility package
-- get_parameter_values functions looks at the parameter table
-- passed in by PMV. For parameters names for which it finds a
-- matching key in this dimension map table, it records the value.
-- In other words, if the dimension map does not have an entry for
-- BIV_REPAIR_ORGANIZATION+BIV_REPAIR_ORGANIZATION, then PMV's organization parameter
-- will never be recorded.


PROCEDURE init_dim_map ( p_mv_set  IN  VARCHAR2,
                         x_dim_map out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map)
IS

        l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

BEGIN

        -- Organzation dimension level
        l_dim_rec.col_name                      := 'repair_organization_id';
        l_dim_rec.view_by_table                 := 'BIV_DBI_RO_ORG_V';
        l_dim_rec.bmap                          := C_ORG_BMAP;
        l_dim_rec.generate_where_clause         := 'Y';
        x_dim_map('BIV_REPAIR_ORGANIZATION+BIV_REPAIR_ORGANIZATION')  := l_dim_rec;

        -- Category dimension level
        l_dim_rec.col_name                      := 'product_category_id';
        l_dim_rec.view_by_table                 := 'eni_item_vbh_nodes_v';
        l_dim_rec.bmap                          := C_CATEGORY_BMAP;
        l_dim_rec.generate_where_clause         := 'N';
        x_dim_map('ITEM+ENI_ITEM_VBH_CAT')      := l_dim_rec;

        -- Item dimension level
        -- For detail reports facts are accessed. There item-org-id column is not there.
        l_dim_rec.col_name              := 'item_org_id';
        l_dim_rec.view_by_table         := 'eni_item_v';
        l_dim_rec.bmap                  := C_ITEM_BMAP;
        l_dim_rec.generate_where_clause := 'Y';
        x_dim_map('ITEM+ENI_ITEM')  := l_dim_rec;

        -- Customer dimension level
        l_dim_rec.col_name                  := 'customer_id';
        l_dim_rec.view_by_table             := 'aso_bi_prospect_v';
        l_dim_rec.bmap                      := C_CUSTOMER_BMAP;
        l_dim_rec.generate_where_clause     := 'Y';
        x_dim_map('CUSTOMER+PROSPECT')      := l_dim_rec;

        -- Repair Type dimension level
        l_dim_rec.col_name                      := 'repair_type_id';
        l_dim_rec.view_by_table                 := 'biv_dbi_repair_types_v';
        l_dim_rec.bmap                          := C_REPAIR_TYPE_BMAP;
        l_dim_rec.generate_where_clause         := 'N';
        x_dim_map('BIV_REPAIR_TYPE+BIV_REPAIR_TYPE')      := l_dim_rec;

        -- Service Code dimension level
        l_dim_rec.col_name                      := 'service_code_id';
        l_dim_rec.view_by_table                 := 'BIV_DBI_SERVICE_CODES_V';
        l_dim_rec.generate_where_clause         := 'Y';
        l_dim_rec.bmap                          := 0;
        x_dim_map('BIV_SERVICE_CODE+BIV_SERVICE_CODE') := l_dim_rec;

END init_dim_map;

/*  Function: get_join_info
*/
PROCEDURE get_join_info (p_view_by       IN varchar2,
                         p_dim_map       IN poa_dbi_util_pkg.poa_dbi_dim_map,
                         x_join_tbl      OUT NOCOPY poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
                         p_mv_set        IN VARCHAR2,
			 p_category_flag IN VARCHAR2)
IS
        l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
        l_stmt_id  NUMBER;
BEGIN

        -- reinitialize the join table
        x_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL ();

        -- The view by table
        l_join_rec.table_name   := p_dim_map(p_view_by).view_by_table;
        l_join_rec.table_alias  := 'v';
        l_join_rec.fact_column  := p_dim_map(p_view_by).col_name;
        l_join_rec.column_name := 'id';


        IF (p_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
        l_join_rec.additional_where_clause := ' v.parent_id = v.child_id ';
	IF(p_category_flag = 'Y') THEN
		l_join_rec.fact_column := 'imm_child_id ';
		l_join_rec.inner_alias := 'v';
	END IF;
        END IF;


        IF (p_view_by = 'BIV_REPAIR_ORGANIZATION+BIV_REPAIR_ORGANIZATION') THEN
             l_join_rec.dim_outer_join := 'Y';
        ELSE
             l_join_rec.dim_outer_join := 'N';
        END IF;

        -- Add the join table
        x_join_tbl.extend;
        x_join_tbl(x_join_tbl.count) := l_join_rec;

END get_join_info;

-- Functions to get the MV
-- Gets the MV for the rack concerned.

PROCEDURE get_mv (p_mv_set         IN  VARCHAR2,
                  p_pcategory_flag  IN  VARCHAR2,
                  p_rtype_flag     IN  VARCHAR2,
                  p_view_by        IN  VARCHAR2,
                  p_dim_bmap       IN  NUMBER,
                  x_mv_type        OUT NOCOPY  VARCHAR2,
                  x_mv             OUT NOCOPY  VARCHAR2)
IS
        l_where_clause VARCHAR2 (150);
        l_err_stage    VARCHAR2(3001);
	l_debug_mode   VARCHAR2(1);
	l_module_name  ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage := 'inside get_mv p_mv_set = ' || p_mv_set ;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;

        -- In case of Detail Report, CSD_REPAIR_TYPES_VL is always selected.
        IF (p_rtype_flag = 'Y' or p_mv_set in('MRGN_DTL','MDTL','BKLDTL1','BKLDTL2',
				                    'CMPDTL1','CMPDTL2' )) THEN
                x_mv := 'CSD_REPAIR_TYPES_VL CRT ,' || fnd_global.newline;
        END IF;

        IF ( p_pcategory_flag = 'Y' ) THEN -- to check if product category is selected
                x_mv_type := 'INLINE';
                x_mv := x_mv || 'ENI_DENORM_HIERARCHIES V, ' || fnd_global.newline ||
                                'MTL_DEFAULT_CATEGORY_SETS M , ' || fnd_global.newline;

                -- The following table and where condition would be for the Margin Detail report.
                -- Since the Detail reports refer to the fact tables and product category is not available in the
                -- fact, we join with the ENI_OLTP_ITEM_STAR.
                IF (p_mv_set = 'MRGN_DTL' or p_mv_set = 'MDTL'  OR p_mv_set = 'CMPDTL2' or p_mv_set = 'CMPDTL1') THEN
                        x_mv := x_mv || 'ENI_OLTP_ITEM_STAR ITEMS, ';
                END IF;
        END IF;

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' THEN
            l_err_stage := 'after rtype_flag and pcat_flag x_mv = ' || x_mv;
            write('BIS_ISC_DEPOT_UTIL : ',l_err_stage,C_DEBUG_LEVEL);
        END IF;


        IF (p_mv_set = 'BKLG') THEN
               IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv := x_mv || ' ISC_DR_BKLG_01_MV';
                        x_mv_type := 'BASE';
               ELSE
                        x_mv := x_mv || ' ISC_DR_BKLG_02_MV';
                        x_mv_type := 'ROOT';
               END IF;

	ELSIF (p_mv_set = 'BKLDUP1') THEN
                        x_mv_type := 'BASE';

	ELSIF (p_mv_set = 'BKLDUP2') THEN
               IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv_type := 'BASE';
               ELSE
                        x_mv_type := 'ROOT';
               END IF;

	ELSIF (p_mv_set = 'COSTS') THEN
              IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv := x_mv || ' ISC_DR_COSTS_01_MV';
                        x_mv_type := 'BASE';
               ELSE
                        x_mv := x_mv || 'ISC_DR_COSTS_02_MV';
                        x_mv_type := 'ROOT';
               END IF;
	ELSIF (p_mv_set = 'CHARGES') THEN
              IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv := x_mv || ' ISC_DR_CHARGES_01_MV';
                        x_mv_type := 'BASE';
               ELSE
                        x_mv := x_mv || 'ISC_DR_CHARGES_02_MV';
                        x_mv_type := 'ROOT';
               END IF;
	ELSIF (p_mv_set = 'MARGIN') THEN
              IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv := x_mv || ' ISC_DR_MRGN_01_V';
                        x_mv_type := 'BASE';
               ELSE
                        x_mv := x_mv || 'ISC_DR_MRGN_02_V';
                        x_mv_type := 'ROOT';
              END IF;

        -- Mean Time To Repair Status/ Trend Reports
        ELSIF (p_mv_set = 'MTTR') THEN
               IF (bitand(p_dim_bmap,16) = 16 OR p_pcategory_flag = 'Y' ) THEN -- for checking if item is selected or it is in view by
                        x_mv := x_mv || ' ISC_DR_MTTR_01_MV';
                        x_mv_type := 'BASE';
               ELSE
                        x_mv := x_mv || 'ISC_DR_MTTR_02_MV';
                        x_mv_type := 'ROOT';
               END IF;

        ELSIF (p_mv_set = 'SRVC') THEN
                        x_mv := x_mv || 'ISC_DR_SERVICE_CODE_MV';
        END IF;

END get_mv;

--    get_agg_flag
--    Generic routine to get the appropriate aggregation_flag for the selected parameters
--    Points of note:
--    Function performs a bitand of p_dim_bmap with each vaue in p_mv_lvl_tbl
--    If the result is same as the value return it
--    If no record satisfies the check, return the most granular level
--    Date        Author              Action
--    02-Aug-2004 Vijay Babu Gandhi     created.

FUNCTION get_agg_flag (p_mv_set IN VARCHAR2,p_dim_bmap IN NUMBER
                       ,p_mv_type IN VARCHAR2)
RETURN NUMBER
IS
        l_mv_agg_tbl ISC_DEPOT_RPT_UTIL_PKG.mv_agg_tbl_typ;
BEGIN

IF (p_mv_type = 'ROOT') THEN
        l_mv_agg_tbl(1) := 4;
        l_mv_agg_tbl(2) := 5;
        l_mv_agg_tbl(3) := 6;
        l_mv_agg_tbl(4) := 7;
        l_mv_agg_tbl(5) := 14;
        l_mv_agg_tbl(5) := 15;
ELSE
        l_mv_agg_tbl(1) := 3;
        l_mv_agg_tbl(2) := 7;
        l_mv_agg_tbl(3) := 11;
        l_mv_agg_tbl(4) := 15;
        l_mv_agg_tbl(5) := 23;
        l_mv_agg_tbl(6) := 31;
END IF;

        IF nvl(l_mv_agg_tbl.count, -1) > 0 THEN
            FOR cntr IN l_mv_agg_tbl.FIRST .. l_mv_agg_tbl.LAST LOOP
                IF bitand(l_mv_agg_tbl(cntr), p_dim_bmap) = p_dim_bmap
                THEN
                    RETURN l_mv_agg_tbl(cntr);
                END IF;
            END LOOP;
        END IF;
END get_agg_flag ;

PROCEDURE GET_ADDITIONAL_WHERECLAUSE( p_mv_set          IN VARCHAR2
                                     ,p_param           IN BIS_PMV_PAGE_PARAMETER_TBL
                                     ,p_pcategory_flag  IN VARCHAR2
                                     ,p_rtype_flag      IN VARCHAR2
				     ,p_repair_type     IN VARCHAR2
                                     ,p_bucket_flag     IN VARCHAR2
                                     ,x_custom_output   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                                     ,x_where_clause    OUT NOCOPY VARCHAR2)
IS
        l_parameter_id VARCHAR2(20);
        l_bucket_short_name BIS_BUCKET.SHORT_NAME%TYPE;

BEGIN
        IF (p_mv_set IN('BKLG','COSTS','CHARGES','MARGIN','MTTR','SRVC','CMPAGN1','BKLAGN1')) THEN
                x_where_clause  := x_where_clause  || ' and fact.aggregation_flag = :AGGREGATION_FLAG' ;
        END IF;

        IF p_pcategory_flag = 'Y' THEN
                -- For Margin Detail Report eni_oltp_item_star.vbh_category_id is used.
                IF (p_mv_set IN ('MRGN_DTL', 'MDTL', 'CMPDTL2', 'CMPDTL1')) THEN
                x_where_clause  := x_where_clause  || ' and m.functional_area_id = 11 ' || fnd_global.newline
                                                   || ' and v.object_id = m.category_set_id ' || fnd_global.newline
                                                   || ' and v.dbi_flag = ''Y''  ' || fnd_global.newline
                                                   || ' and v.object_type = ''CATEGORY_SET''  ' || fnd_global.newline
                                                   || ' and items.vbh_category_id = v.child_id  ' || fnd_global.newline
                                                   || ' and v.parent_id = &ITEM+ENI_ITEM_VBH_CAT  ' || fnd_global.newline
                                                   || ' and fact.item_org_id = items.id  ' ;
                ELSE
                x_where_clause  := x_where_clause  || ' and m.functional_area_id = 11 ' || fnd_global.newline
                                                   || ' and v.object_id = m.category_set_id ' || fnd_global.newline
                                                   || ' and v.dbi_flag = ''Y'' ' || fnd_global.newline
                                                   || ' and v.object_type = ''CATEGORY_SET'' ' || fnd_global.newline
                                                   || ' and fact.product_category_id = v.child_id ' || fnd_global.newline
                                                   || ' and v.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';
                END IF;
       END IF;

--	This condition needs to be there isf it is a detail report or if repair type is selected.
       IF (p_rtype_flag = 'Y' OR p_mv_set in('MDTL','MRGN_DTL','CMPDTL2','CMPDTL1','BKLDTL1','BKLDTL2')) THEN
                x_where_clause  := x_where_clause || ' and crt.repair_type_id = fact.repair_type_id' ;
       END IF;

       IF (p_rtype_flag = 'Y' ) THEN
       	     IF (instr(p_repair_type,',') <> 0) THEN
                    x_where_clause  := x_where_clause || ' and ( fact.repair_type_id IN (&BIV_REPAIR_TYPE+BIV_REPAIR_TYPE) ' ;
	     		IF (instr(p_repair_type,'-1') <> 0 ) THEN
	     		        x_where_clause  := x_where_clause || ' or crt.repair_type_ref <> ''RF'' ' ;
	     		END IF;
	     		IF (instr(p_repair_type,'-2') <> 0 ) THEN
	     		        x_where_clause  := x_where_clause || ' or crt.repair_type_ref = ''RF'' ' ;
	     		END IF;
	            x_where_clause  := x_where_clause || ' )' ;
	     ELSIF(instr(p_repair_type,'-1') <> 0) THEN
	    		x_where_clause  := x_where_clause || ' AND crt.repair_type_ref <> ''RF'' ' ;
	     ELSIF (instr(p_repair_type,'-2') <> 0) THEN
	     		 x_where_clause  := x_where_clause || ' AND crt.repair_type_ref = ''RF'' ' ;
	    END IF;
       END IF;

       IF (p_bucket_flag = 'Y') THEN
      	      IF(p_mv_set = 'BKLDTL1') THEN
	                FOR i in 1..p_param.COUNT LOOP
			        IF(p_param(i).parameter_name = 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET' )  THEN
				      l_parameter_id := replace(p_param(i).parameter_id,'''',null);
		                END IF;
		        END LOOP;

                        IF(l_parameter_id = '-1' ) THEN -- past due is selected
                                x_where_clause := x_where_clause || ' and fact.past_due_flag = ''Y'' ';
                        ELSIF(l_parameter_id = '9999' ) THEN -- Not promised is selected
                                x_where_clause := x_where_clause || ' and fact.promise_date is null ';
                        ELSE
               		x_where_clause := x_where_clause || ' AND ( ';
	       		GET_BUCKET_WHERE_CLAUSE (p_param => p_param,
	       					 p_dim_level => 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET',
	       					 p_bucket_short_name => 'ISC_DEPOT_DAYS_UNTIL_PROM',
	       					 p_col_name => 'fact.days_until_promised',
	       					 x_where_clause => x_where_clause ,
	       					 x_custom_output => x_custom_output);
                        END IF;
               ELSIF(p_mv_set = 'BKLDTL2') THEN
               		x_where_clause := x_where_clause || ' AND ( ';
	       		GET_BUCKET_WHERE_CLAUSE (p_param => p_param,
	       					 p_dim_level => 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET',
	       					 p_bucket_short_name => 'ISC_DEPOT_BKLG_CMP_AGING',
	       					 p_col_name => 'fact.past_due_days',
	       					 x_where_clause => x_where_clause ,
	       					 x_custom_output => x_custom_output);
               ELSIF(p_mv_set = 'CMPDTL2') THEN
               		x_where_clause := x_where_clause || ' AND ( ';
	       		GET_BUCKET_WHERE_CLAUSE (p_param => p_param,
	       					 p_dim_level => 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET',
	       					 p_bucket_short_name => 'ISC_DEPOT_BKLG_CMP_AGING',
	       					 p_col_name => '(dbi_date_closed - fact.promise_date)',
	       					 x_where_clause => x_where_clause ,
	       					 x_custom_output => x_custom_output);
               ELSIF (p_mv_set = 'MDTL') THEN
              		x_where_clause := x_where_clause || ' AND ( ';
              		GET_BUCKET_WHERE_CLAUSE (p_param => p_param,
              					 p_dim_level => 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET',
              					 p_bucket_short_name => 'ISC_DEPOT_MTTR' ,
              					 p_col_name => 'fact1.time_to_repair',
              					 x_where_clause => x_where_clause ,
              					 x_custom_output => x_custom_output);
       END IF;

END IF;

END GET_ADDITIONAL_WHERECLAUSE;

PROCEDURE GET_BUCKET_WHERE_CLAUSE (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
				   p_dim_level IN VARCHAR2,
				   p_bucket_short_name IN BIS_BUCKET.SHORT_NAME%TYPE,
				   p_col_name IN VARCHAR2,
				   x_where_clause IN OUT NOCOPY VARCHAR2,
				   x_custom_output OUT NOCOPY bis_query_attributes_tbl)
IS

l_parameter_id VARCHAR2(20);
l_length NUMBER;
l_position NUMBER;
l_range_id NUMBER;
p_bucket_range_ids_tbl bucket_range_typ;

BEGIN

	FOR i in 1..p_param.COUNT LOOP
		IF(p_param(i).parameter_name = p_dim_level )  THEN
			l_parameter_id := replace(p_param(i).parameter_id,'''',null);
                END IF;
        END LOOP;

	IF (l_parameter_id IS NOT NULL) THEN

        GET_BUCKET_RANGE_ID (p_parameter_id => l_parameter_id,
                             x_bucket_range_ids_tbl => p_bucket_range_ids_tbl);

	FOR i IN p_bucket_range_ids_tbl.FIRST .. p_bucket_range_ids_tbl.LAST LOOP

		x_where_clause := x_where_clause ||'((&RANGE'||p_bucket_range_ids_tbl(i)||'_LOW is null OR ' || p_col_name || ' >= &RANGE'||p_bucket_range_ids_tbl(i)||'_LOW)' || fnd_global.newline ||
	                    				    ' AND (&RANGE'||p_bucket_range_ids_tbl(i)||'_HIGH is null OR '|| p_col_name || ' < &RANGE'||p_bucket_range_ids_tbl(i)||'_HIGH))';
               	bind_low_high( p_range_id       => p_bucket_range_ids_tbl(i)
                       	      ,p_short_name     => p_bucket_short_name
		       	      ,p_dim_level      => 'BIV_DR_BACKLOG_BUCKET+BIV_DR_BACKLOG_BUCKET'
                              ,p_low            => '&RANGE'||p_bucket_range_ids_tbl(i)||'_LOW'
		              ,p_high           => '&RANGE'||p_bucket_range_ids_tbl(i)||'_HIGH'
		              ,p_custom_output  => x_custom_output);
		IF (i <> p_bucket_range_ids_tbl.LAST) THEN
	         	       x_where_clause := x_where_clause || ' OR ';
		END IF;

	END LOOP;

	x_where_clause := x_where_clause || ' ) ';

	END IF;

END GET_BUCKET_WHERE_CLAUSE;

PROCEDURE GET_BUCKET_RANGE_ID (p_parameter_id IN VARCHAR2 ,
                               x_bucket_range_ids_tbl OUT NOCOPY  bucket_range_typ)
IS
l_string VARCHAR2(20);
l_string1 VARCHAR2(20);
l_length NUMBER;
l_position NUMBER;
x_count NUMBER;

BEGIN

l_string := p_parameter_id;
x_count := 1;

	WHILE ( l_string IS NOT NULL ) LOOP
		l_length := LENGTH(l_string);
		l_position := INSTR(l_string,',');
		IF (l_position = 0) THEN
			x_bucket_range_ids_tbl(x_count) := l_string;
			l_string := NULL;
		ELSE
			l_string1 := SUBSTR(l_string, 1, l_position - 1);
			x_bucket_range_ids_tbl(x_count) := l_string1;
			l_string := SUBSTR(l_string,l_position+1,l_length);
		END IF;
		x_count := x_count + 1;
	END LOOP;

END GET_BUCKET_RANGE_ID;

PROCEDURE bind_low_high
(
  p_range_id 	  IN NUMBER
, p_short_name    IN varchar2
, p_dim_level	  IN varchar2
, p_low           IN varchar2
, p_high          IN varchar2
, p_custom_output IN OUT nocopy bis_query_attributes_tbl
)
IS
  l_range_low number;
  l_range_high number;

  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;

  l_custom_rec BIS_QUERY_ATTRIBUTES;

BEGIN

  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );

  if l_return_status = 'S' then

    if p_range_id = 1 then
      l_range_low := l_bucket_rec.range1_low;
      l_range_high := l_bucket_rec.range1_high;
    elsif p_range_id = 2 then
      l_range_low := l_bucket_rec.range2_low;
      l_range_high := l_bucket_rec.range2_high;
    elsif p_range_id = 3 then
      l_range_low := l_bucket_rec.range3_low;
      l_range_high := l_bucket_rec.range3_high;
    elsif p_range_id = 4 then
      l_range_low := l_bucket_rec.range4_low;
      l_range_high := l_bucket_rec.range4_high;
    elsif p_range_id = 5 then
      l_range_low := l_bucket_rec.range5_low;
      l_range_high := l_bucket_rec.range5_high;
    elsif p_range_id = 6 then
      l_range_low := l_bucket_rec.range6_low;
      l_range_high := l_bucket_rec.range6_high;
    elsif p_range_id = 7 then
      l_range_low := l_bucket_rec.range7_low;
      l_range_high := l_bucket_rec.range7_high;
    elsif p_range_id = 8 then
      l_range_low := l_bucket_rec.range8_low;
      l_range_high := l_bucket_rec.range8_high;
    elsif p_range_id = 9 then
      l_range_low := l_bucket_rec.range9_low;
      l_range_high := l_bucket_rec.range9_high;
    elsif p_range_id = 10 then
      l_range_low := l_bucket_rec.range10_low;
      l_range_high := l_bucket_rec.range10_high;
    end if;
  end if;

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

  l_custom_rec.attribute_name := p_low;
  l_custom_rec.attribute_value := l_range_low;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := p_high;
  l_custom_rec.attribute_value := l_range_high;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

END bind_low_high;

FUNCTION GET_VIEWBY_SELECT_CLAUSE (p_viewby IN VARCHAR2)
    RETURN VARCHAR2
IS
    l_viewby_sel VARCHAR2(200);
BEGIN
    if p_viewby = 'BIV_REPAIR_TYPE+BIV_REPAIR_TYPE' then
        l_viewby_sel :=  'v.value2 VIEWBY, ' || fnd_global.newline || 'v.id VIEWBYID, ';
    ELSE
        l_viewby_sel :=  'v.value  VIEWBY, ' || fnd_global.newline || 'v.id VIEWBYID, ';
    END IF;

    return l_viewby_sel;

END get_viewby_select_clause;

--    write
--    Generic routine for debug purpose
--    Date        Author              Action
--    02-Aug-2004 Vijay Babu Gandhi     created.

PROCEDURE write (p_module      IN VARCHAR2,
                 p_err_stage   IN VARCHAR2,
                 p_debug_level IN INTEGER)
IS
	l_stmt_id     VARCHAR2(3999);
	l_log_level   NUMBER;
	l_debug_mode  VARCHAR2(1);
	l_module_name ISC_DEPOT_RPT_UTIL_PKG.g_module_name_typ%type;

BEGIN

	l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
	l_module_name             := FND_PROFILE.value('AFLOG_MODULE');
	l_log_level               := FND_PROFILE.value('AFLOG_LEVEL');

        IF l_debug_mode = 'Y' and upper(l_module_name) like 'BIS%' and p_debug_level >= l_log_level THEN
                FND_LOG.STRING(p_debug_level,p_Module,p_err_stage);
        END IF;
END write;

FUNCTION get_repair_order_url
RETURN VARCHAR2
IS
	l_repair_order_url varchar2 (500);
BEGIN
	l_repair_order_url := '''pFunctionName=CSD_REPAIR_ORDER_SUMMARY&pParamIds=Y''';
	RETURN l_repair_order_url;
END get_repair_order_url ;

FUNCTION get_service_request_url
RETURN VARCHAR2
IS
	l_service_request_url varchar2 (500);
BEGIN
        l_service_request_url :='''pFunctionName=CSZ_SR_UP_RO_FN' ||
                           '&cszReadOnlySRPageMode=REGULARREADONLY' ||
                           -- the following 2 parameters are no longer required (R12)
                           -- '&cszReadOnlySRRetURL=null' ||
                           -- '&cszReadOnlySRRetLabel=.' ||
                           '&OAPB=BIV_DBI_SR_BRAND'||
                           '&cszIncidentId=''';
	RETURN l_service_request_url;
END get_service_request_url ;


END ISC_DEPOT_RPT_UTIL_PKG;

/

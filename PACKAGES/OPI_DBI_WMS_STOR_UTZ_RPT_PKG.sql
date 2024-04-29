--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_STOR_UTZ_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_STOR_UTZ_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRWSTORS.pls 120.0 2005/05/24 18:08:41 appldev noship $ */

/****************************************
 * Package Level Constants
 ****************************************/

-- Identifiers for the various viewby'S
C_VIEWBY_ORG CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION';
C_VIEWBY_SUB CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION_SUBINVENTORY';
C_VIEWBY_ITEM CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_ORG';
C_VIEWBY_INV_CAT CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_INV_CAT';

-- Identifiers for the various dimensions
C_DIM_ORG CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION';
C_DIM_SUB CONSTANT VARCHAR2(50) := 'ORGANIZATION+ORGANIZATION_SUBINVENTORY';
C_DIM_ITEM CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_ORG';
C_DIM_INV_CAT CONSTANT VARCHAR2(50) := 'ITEM+ENI_ITEM_INV_CAT';

-- Aggregation level flag values
C_ITEM_AGGR_LEVEL CONSTANT NUMBER := 0;
C_SUB_AGGR_LEVEL CONSTANT NUMBER := 1;
C_INV_CAT_AGGR_LEVEL CONSTANT NUMBER := 1;
C_ORG_AGGR_LEVEL CONSTANT NUMBER := 7;

-- ITD Bit pattern for the rolling period calendar
C_ROLLING_ITD_PATTERN CONSTANT NUMBER := 512;

/****************************************
 * Report Query Functions
 ****************************************/

-- Warehouse Storage Utilized (Table) report query function
PROCEDURE get_stor_tbl_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL);


-- Warehouse Storage Utilized Trend report query function
PROCEDURE get_stor_trd_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL);

-- Current Capacity Utilization report query function
PROCEDURE get_curr_utz_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                            x_custom_sql OUT NOCOPY VARCHAR2,
                            x_custom_output OUT NOCOPY
                                BIS_QUERY_ATTRIBUTES_TBL);

END opi_dbi_wms_stor_utz_rpt_pkg;

 

/

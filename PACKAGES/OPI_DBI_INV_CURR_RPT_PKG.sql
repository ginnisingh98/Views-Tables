--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_CURR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_CURR_RPT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDRIVDETS.pls 120.0 2005/08/18 01:57:04 srayadur noship $ */

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

-- SQL query for Current Inventory Status
PROCEDURE get_curr_inv_stat_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql OUT NOCOPY VARCHAR2,
                                 x_custom_output OUT NOCOPY
                                    BIS_QUERY_ATTRIBUTES_TBL);


-- SQL query for Current Inventory Expiration Status
PROCEDURE get_curr_inv_exp_stat_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_custom_sql OUT NOCOPY VARCHAR2,
                                     x_custom_output OUT NOCOPY
                                        BIS_QUERY_ATTRIBUTES_TBL);


-- SQL query for Inventory Days Onhand
PROCEDURE get_inv_days_onh_sql (p_param IN BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql OUT NOCOPY VARCHAR2,
                                x_custom_output OUT NOCOPY
                                    BIS_QUERY_ATTRIBUTES_TBL);


END OPI_DBI_INV_CURR_RPT_PKG;

 

/

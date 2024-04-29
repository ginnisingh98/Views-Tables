--------------------------------------------------------
--  DDL for Package BIS_PMV_METADATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_METADATA_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMDTS.pls 115.7 2002/08/16 01:34:52 gsanap noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
--
-- Nihar       29-MAY-2002   Bug Fix 2371922: Added node_display_flag to AK_REGION_ITEM_REC
-- ---------   ------  ---------------------------------------------------------------------
-- Enter package declarations as shown below

-- report info from ak_regions_vl
TYPE AK_REGION_REC IS RECORD(
disable_viewby AK_REGIONS_VL.attribute1%TYPE,
user_groupby   AK_REGIONS_VL.attribute6%TYPE,
user_orderby   AK_REGIONS_VL.attribute7%TYPE,
source_view    AK_REGIONS_VL.database_object_name%TYPE,
report_type    AK_REGIONS_VL.region_object_type%TYPE,
plsql_function AK_REGIONS_VL.attribute8%TYPE,
data_source    AK_REGIONS_VL.attribute10%TYPE,
where_clause    AK_REGIONS_VL.attribute11%TYPE);

TYPE AK_REGION_TBL IS TABLE OF AK_REGION_REC INDEX BY BINARY_INTEGER;

-- report info from ak_region_items_vl
TYPE AK_REGION_ITEM_REC IS RECORD(
attribute_type     AK_REGION_ITEMS_VL.attribute1%TYPE,
attribute_code     AK_REGION_ITEMS_VL.attribute_code%TYPE,
attribute2         AK_REGION_ITEMS_VL.attribute2%TYPE,
base_column        AK_REGION_ITEMS_VL.attribute3%TYPE,
where_clause       AK_REGION_ITEMS_VL.attribute4%TYPE,
lov_table          AK_REGION_ITEMS_VL.attribute15%TYPE,
aggregate_function AK_REGION_ITEMS_VL.attribute9%TYPE,
data_type          AK_REGION_ITEMS_VL.attribute14%TYPE,
data_format        AK_REGION_ITEMS_VL.attribute7%TYPE,
order_sequence     AK_REGION_ITEMS_VL.order_sequence%TYPE,
order_direction    AK_REGION_ITEMS_VL.order_direction%TYPE,
node_query_flag    AK_REGION_ITEMS_VL.node_query_flag%TYPE,
node_display_flag    AK_REGION_ITEMS_VL.node_display_flag%TYPE
);

TYPE AK_REGION_ITEM_TBL IS TABLE OF AK_REGION_ITEM_REC INDEX BY BINARY_INTEGER;

TYPE SAVE_REGION_ITEM_REC IS RECORD(
attribute2         AK_REGION_ITEMS_VL.attribute2%TYPE,
base_column        AK_REGION_ITEMS_VL.attribute3%TYPE,
where_clause       AK_REGION_ITEMS_VL.attribute4%TYPE,
data_type          AK_REGION_ITEMS_VL.attribute14%TYPE);

TYPE SAVE_REGION_ITEM_TBL IS TABLE OF SAVE_REGION_ITEM_REC INDEX BY BINARY_INTEGER;

-- report info from bis_ak_region_item_extension
TYPE AK_REGION_ITEM_EXT_REC IS RECORD(
extra_groupby  BIS_AK_REGION_ITEM_EXTENSION.attribute16%TYPE);

TYPE AK_REGION_ITEM_EXT_TBL IS TABLE OF AK_REGION_ITEM_EXT_REC INDEX BY BINARY_INTEGER;

END; -- Package Specification BIS_PMV_METADATA_PVT

 

/

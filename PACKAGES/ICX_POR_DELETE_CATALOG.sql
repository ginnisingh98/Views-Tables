--------------------------------------------------------
--  DDL for Package ICX_POR_DELETE_CATALOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_DELETE_CATALOG" AUTHID CURRENT_USER AS
/* $Header: ICXDELCS.pls 115.5 2004/03/31 18:45:38 vkartik ship $*/

ITEM_TABLE_LAST		PLS_INTEGER := 0;
CATITEM_TABLE_LAST	PLS_INTEGER := 1;

/**
 ** Proc : delete_items_in_category
 ** Procedure called when a category is deleted from ecmanager.
 ** Desc : Deletes the items and prices in the category id specified
 **        Deletes the category related info from icx_cat_browse_trees,
 **        icx_por_category_data_sources, icx_por_category_order_map
 **/
PROCEDURE delete_items_in_category (p_rt_category_id        IN  NUMBER,
                                    p_category_key          IN  VARCHAR2);

/**
 ** Proc : delete_items_in_category
 ** Procedure called when a category is deleted from ecmanager.
 ** Desc : Deletes the items and prices in the category id specified
 **        Deletes the category related info from icx_cat_browse_trees,
 **        icx_por_category_data_sources, icx_por_category_order_map
 **/
PROCEDURE delete_items_in_category (
                                    errbuf            OUT NOCOPY VARCHAR2,
                                    retcode           OUT NOCOPY VARCHAR2,
                                    p_rt_category_id   IN NUMBER,
                                    p_category_key     IN VARCHAR2);

/**
 ** Proc : delete_items_in_catalog
 ** Desc : Deletes the items and prices in the catalog name specified
 **/
PROCEDURE delete_items_in_catalog (p_catalog_name        IN VARCHAR2);

/**
 ** Proc : delete_supplier_catalog_opUnit
 ** Desc : Deletes the catalog for the supplier and Operating Unit specified.
 **/
PROCEDURE delete_supplier_catalog_opUnit (p_supplier 		IN VARCHAR2,
                                          p_operating_unit_id 	IN NUMBER DEFAULT -2);

/**
 ** Proc : deleteCommonTables
 ** Desc : Deletes the data from common tables used by Extractor and DeleteCatalog
 **/
PROCEDURE deleteCommonTables (pRtItemIds 	IN dbms_sql.number_table,
                              pDeleteOrder 	IN PLS_INTEGER DEFAULT ITEM_TABLE_LAST);

/**
 ** Proc : deleteCategoryRelatedInfo
 ** Desc : Deletes the data from ICX_CAT_BROWSE_TREES,
 **        ICX_POR_CATEGORY_ORDER_MAP, ICX_POR_CATEGORY_DATA_SOURCES
 **/
PROCEDURE deleteCategoryRelatedInfo(pRtCategoryId  IN NUMBER,
                                    pCategoryKey   IN VARCHAR2);

PROCEDURE setCommitSize(pCommitSize	IN PLS_INTEGER);

END ICX_POR_DELETE_CATALOG;

 

/

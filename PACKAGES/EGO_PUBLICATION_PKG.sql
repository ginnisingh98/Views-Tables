--------------------------------------------------------
--  DDL for Package EGO_PUBLICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_PUBLICATION_PKG" AUTHID CURRENT_USER AS
/* $Header: EGOPBLCS.pls 120.7 2007/10/11 12:53:28 bramnan noship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'EGO_PUBLICATION_PKG' ;

--	Global Constants  for data levels

G_ITM_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_LEVEL';
G_ITM_ORG_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_ORG';
G_ITM_SUP_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP';
G_ITM_SUP_SITE_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE';
G_ITM_SUP_SITE_ORG_DATA_LVL CONSTANT VARCHAR2(20) := 'ITEM_SUP_SITE_ORG';

PROCEDURE getUDAAttributes
          (
          extension_id    IN  NUMBER,
          p_language      IN  VARCHAR2,
          x_doc           OUT NOCOPY  xmltype,
          x_error_message OUT NOCOPY VARCHAR2
          );

PROCEDURE getItemIdentification
          (
          inventory_item_id IN NUMBER,
          organization_id   IN NUMBER,
          x_doc           OUT NOCOPY  xmltype,
          x_error_message OUT NOCOPY VARCHAR2
          );

PROCEDURE getItemBase
          (
          inventory_item_id IN NUMBER,
          organization_id   IN NUMBER,
          p_language          IN VARCHAR2,
          x_doc           OUT NOCOPY  xmltype,
          x_error_message OUT NOCOPY VARCHAR2
          );

PROCEDURE getItemAttributes
          (
          inventory_item_id  IN NUMBER,
          organization_id    IN NUMBER,
          extension_id       IN NUMBER,
          p_language         IN VARCHAR2,
          x_doc           OUT NOCOPY  xmltype,
          x_error_message OUT NOCOPY VARCHAR2
          );

PROCEDURE getCategoryAttributes
          (
           category_id           IN NUMBER,
           GetFlexAttributesFlag IN CHAR,
           x_doc           OUT NOCOPY  xmltype,
           x_error_message OUT NOCOPY VARCHAR2
           );

PROCEDURE getCatalogAttributes
          (
          catalogId        IN  NUMBER,
          parentCategoryId IN NUMBER,
          categoryId       IN NUMBER,
          p_language         IN VARCHAR2,
          x_doc           OUT NOCOPY  xmltype,
          x_error_message OUT NOCOPY VARCHAR2
          );

--------------------------------------
--	getDataLevelId
--------------------------------------
	FUNCTION getDataLevelId
		(p_data_level_internal_name IN VARCHAR2)
	RETURN NUMBER;

--------------------------------------
--	getSupplierAttributes
--------------------------------------
	PROCEDURE getSupplierAttributes
	(
	      p_api_version		IN NUMBER,
	      p_supplier_id		IN NUMBER,
	      p_language		IN VARCHAR2,  --	If none is passed all languages are returned back
	      x_doc		        OUT NOCOPY XMLTYPE,
	      x_error_message		OUT NOCOPY VARCHAR2
	);

---------------------------------------
--	Get Supplier Site Attributes
---------------------------------------
	PROCEDURE getSupplierSiteAttributes(
	      p_api_version		IN NUMBER,
	      p_supplier_id		IN NUMBER,
	      p_supplier_site_id        IN NUMBER,
	      p_language		IN VARCHAR2,	--	If none is passed all languages are returned back
	      x_doc		        OUT NOCOPY XMLTYPE,
	      x_error_message		OUT NOCOPY VARCHAR2
	);

---------------------------------------
--	getItemSupplierAttributes
---------------------------------------
	PROCEDURE getItemSupplierAttributes
	(
            p_api_version	  IN  NUMBER := 1.0,
            p_inventory_item_id	  IN NUMBER,		--	Item Identifier1
            p_organization_id	  IN NUMBER,		--	Item Identifier2
            p_supplierId	  IN NUMBER,		--	Supplier Identifier
            p_extension_id  	  IN NUMBER,	        --      pk for identifying the row in ext values table
            p_language		  IN VARCHAR2,
            x_doc		  OUT NOCOPY XMLTYPE,
            x_error_message	  OUT NOCOPY VARCHAR2
	);

---------------------------------------
--	getItemSupplierSiteAttributes
---------------------------------------
	PROCEDURE getItemSupplierSiteAttributes
	(
		p_api_version		IN  NUMBER,
		p_inventory_item_id	IN  NUMBER,
		p_organization_id	IN  NUMBER,
		p_supplierId		IN  NUMBER,
		p_site_id	        IN  NUMBER,
		p_extension_id          IN  NUMBER,
		p_language		IN  VARCHAR2,	--	If none is passed all languages are returned back
		x_doc			OUT NOCOPY xmltype,
		x_error_message		OUT NOCOPY varchar2
	);

------------------------------------------------------
--  getStructureAttributes
------------------------------------------------------
        PROCEDURE getStructureAttributes
        (
          p_api_version		        IN NUMBER,
          p_structure_id	        IN NUMBER,
          p_component_id	        IN NUMBER,
          p_language		        IN VARCHAR2,  --	If none is passed all languages are returned back
          p_get_first_level_comps       IN VARCHAR2,
          x_doc		                OUT NOCOPY XMLTYPE,
          x_error_message	        OUT NOCOPY VARCHAR2
        );

----------------------------------------------
--  getItemCategoryAttributes
----------------------------------------------
        PROCEDURE getItemCategoryAttributes
        (
          p_api_version		IN  NUMBER,
          p_inventory_item_id	IN NUMBER,
          p_organization_id	IN NUMBER,
          p_catalog_id		IN NUMBER,
          p_category_id		IN NUMBER,
          p_language		IN VARCHAR2,	--	If none is passed all languages are returned back
          x_doc			OUT NOCOPY xmltype,
          x_error_message	OUT NOCOPY varchar2
        );

 PROCEDURE getEventPayload
        (
          p_sequence_id   IN NUMBER,
          p_event         OUT NOCOPY WF_EVENT_T,
          x_error_message OUT NOCOPY varchar2
        );

FUNCTION getItemIdentification
          (
            p_inventory_item_id  IN NUMBER,
            p_organization_id    IN NUMBER
          )
        RETURN XMLTYPE;



END EGO_PUBLICATION_PKG;

/

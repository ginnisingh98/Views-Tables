--------------------------------------------------------
--  DDL for Package ICX_ENDECA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ENDECA_UTIL_PKG" AUTHID CURRENT_USER AS
  /* $Header: ICXEUTLS.pls 120.0.12010000.10 2014/04/24 14:35:27 mzhussai noship $ */
PROCEDURE populate_KVPs;
PROCEDURE populate_KVPs_for_punchout;
PROCEDURE populate_attribute_metadata;
PROCEDURE populate_managed_attr_metadata;
PROCEDURE populate_precedence_rules;
PROCEDURE get_applicable_zones(p_zone_ids  OUT NOCOPY ICX_TBL_VARCHAR240,
                               x_return_status OUT NOCOPY VARCHAR2);
PROCEDURE get_applicable_contents(p_content_ids  OUT NOCOPY ICX_TBL_VARCHAR240,
                                  x_return_status OUT NOCOPY VARCHAR2);

Function get_attachment (p_inventory_item_id number,p_organization_id number) RETURN CLOB;

procedure incrementalInsert;

procedure  incrementalDelete(gIHInventoryItemIdTbl   IN        DBMS_SQL.NUMBER_TABLE,
gIHPoLineIdTbl       IN           DBMS_SQL.NUMBER_TABLE,
gIHReqTemplateNameTbl  IN         DBMS_SQL.VARCHAR2_TABLE,
gIHReqTemplateLineNumTbl IN       DBMS_SQL.NUMBER_TABLE,
gIHOrgIdTbl                IN     DBMS_SQL.NUMBER_TABLE,
gIHLanguageTbl               IN   DBMS_SQL.VARCHAR2_TABLE
) ;

procedure insertIncrementalItem(gIHInventoryItemIdTbl   IN        DBMS_SQL.NUMBER_TABLE,
gIHPoLineIdTbl       IN           DBMS_SQL.NUMBER_TABLE,
gIHReqTemplateNameTbl  IN         DBMS_SQL.VARCHAR2_TABLE,
gIHReqTemplateLineNumTbl IN       DBMS_SQL.NUMBER_TABLE,
gIHOrgIdTbl                IN     DBMS_SQL.NUMBER_TABLE,
gIHLanguageTbl               IN   DBMS_SQL.VARCHAR2_TABLE) ;

Function makeNCName(p_attribute_name IN VARCHAR2) RETURN VARCHAR2;

procedure populate_metadata;

procedure populate_metadata_SRS(errbuff OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER);

FUNCTION  isContentValid(contentId IN NUMBER ) RETURN VARCHAR2 ;

PROCEDURE get_cart_desc(
	 p_last_updated_by IN NUMBER,
	 p_org_id          IN NUMBER,
	 x_req_header_id   OUT NOCOPY NUMBER,
         x_cart_desc       OUT NOCOPY VARCHAR2);

FUNCTION load_content(p_url  IN  VARCHAR2) RETURN CLOB;
PROCEDURE set_proxy ;


END ICX_ENDECA_UTIL_PKG;

/

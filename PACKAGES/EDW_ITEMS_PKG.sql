--------------------------------------------------------
--  DDL for Package EDW_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIITEMS.pls 115.2 2004/01/30 21:43:58 sbag noship $  */
-- ------------------------
-- Public Functions
-- ------------------------
Function Item_Org_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_item_description              in VARCHAR2 DEFAULT NULL,
        p_item_category                 in VARCHAR2 DEFAULT NULL,
        p_instance_code					in VARCHAR2 DEFAULT NULL)
        				return VARCHAR2;

Function Item_Org_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_item_description              in VARCHAR2 DEFAULT NULL,
        p_item_category_id              in NUMBER DEFAULT NULL,
        p_instance_code					in VARCHAR2 DEFAULT NULL)
        				return VARCHAR2;

Function Item_Rev_FK(
        p_inventory_item_id             in NUMBER,
        p_organization_id               in NUMBER,
        p_revision                      in VARCHAR2,
        p_instance_code                 in VARCHAR2 := null)
        				return VARCHAR2;
Function Category_FK(
        p_functional_area in NUMBER,
        p_control in  NUMBER,
        p_category_id in NUMBER,
        p_instance_code in VARCHAR2 DEFAULT NULL)
        				return VARCHAR2;

FUNCTION GET_PROD_GRP_FK(
    p_item_id         in  NUMBER,
    p_organization_id in  NUMBER,
    p_instance_code   in  VARCHAR2 )
RETURN VARCHAR2;

FUNCTION GET_ITEM_FK(
    p_item_id           in NUMBER,
    p_inv_org_id        in NUMBER,
    p_interest_type_id  in NUMBER,
    p_primary_code_id   in NUMBER,
    p_secondary_code_id in NUMBER,
    p_instance_code     in VARCHAR2 )
RETURN VARCHAR2;

Function GET_MASTER_PARENT(p_organization_id IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (Item_Org_FK,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (Item_Rev_FK,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (Category_FK,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (Get_Prod_Grp_FK,WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES (Get_Item_FK, WNDS, WNPS, RNPS);
--PRAGMA RESTRICT_REFERENCES (Get_Master_Parent, WNDS, WNPS, RNPS);

end;

 

/

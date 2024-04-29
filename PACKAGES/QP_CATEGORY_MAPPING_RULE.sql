--------------------------------------------------------
--  DDL for Package QP_CATEGORY_MAPPING_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CATEGORY_MAPPING_RULE" AUTHID CURRENT_USER AS
/* $Header: QPXPSICS.pls 120.1 2005/12/20 14:01:36 sfiresto noship $ */

FUNCTION Get_Item_Category (p_inventory_item_id IN NUMBER)
         		   RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

/*
 * Commented out for bug 4753707
 *
 * FUNCTION Validate_UOM (p_org_id IN NUMBER,
 *                        p_category_id IN NUMBER,
 *                        p_product_uom_code IN VARCHAR2) RETURN VARCHAR2;
 */

END QP_CATEGORY_MAPPING_RULE;

 

/

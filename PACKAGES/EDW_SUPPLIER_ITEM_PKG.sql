--------------------------------------------------------
--  DDL for Package EDW_SUPPLIER_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SUPPLIER_ITEM_PKG" AUTHID CURRENT_USER AS
/*$Header: poafksis.pls 120.0 2005/06/01 23:59:15 appldev noship $*/

-- ---------------------------------------------------------
-- Supplier Item API for SUPPLIER_ITEM DIMENSION
--
-- Function returns Supplier_Item level foreign key
--
-- Underlining View: EDW_POA_SPIM_SPLRITEM_FKV
-- ---------------------------------------------------------

-- Use Supplier Site ID as a parameter
--
  Function Supplier_Item_FK (
  	            p_supplier_name        in VARCHAR2,
  	            p_supplier_site_id     in NUMBER,
  	            p_supplier_product_num in VARCHAR2)
                                       return VARCHAR2;

-- Use Supplier Site Code as a parameter
--
  Function Supplier_Item_SC_FK (
  	            p_supplier_name        in VARCHAR2,
  	            p_supplier_site_code   in VARCHAR2,
  	            p_supplier_product_num in VARCHAR2)
                                       return VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (Supplier_Item_FK, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES (Supplier_Item_SC_FK, WNDS, WNPS, RNPS);

END EDW_SUPPLIER_ITEM_PKG;

 

/

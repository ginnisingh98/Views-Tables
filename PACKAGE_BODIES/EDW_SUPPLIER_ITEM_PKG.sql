--------------------------------------------------------
--  DDL for Package Body EDW_SUPPLIER_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SUPPLIER_ITEM_PKG" AS
/*$Header: poafksib.pls 120.0 2005/06/02 01:51:25 appldev noship $*/

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
                                       return VARCHAR2 IS
    l_fk  VARCHAR2(240) := 'NA_EDW';

    cursor supplier_item_num_cur is
        select  supplier_item_pk
          from  EDW_POA_SPIM_SPLRITEM_FKV
         where  vendor_name = p_supplier_name
           and  vendor_site_id = p_supplier_site_id
           and  vendor_product_num = p_supplier_product_num;
  BEGIN
         OPEN  supplier_item_num_cur;
        FETCH  supplier_item_num_cur into l_fk;
        CLOSE  supplier_item_num_cur;

        return nvl(l_fk, 'NA_EDW');

  EXCEPTION when others then
        if supplier_item_num_cur%ISOPEN then
          close supplier_item_num_cur;
        end if;

	return ('NA_EDW');

  END Supplier_Item_FK;


---------------------------------------------------
-- Use Supplier Site Code as a parameter
--
  Function Supplier_Item_SC_FK (
  	            p_supplier_name        in VARCHAR2,
  	            p_supplier_site_code   in VARCHAR2,
  	            p_supplier_product_num in VARCHAR2)
                                       return VARCHAR2 IS
    l_fk  VARCHAR2(240) := 'NA_EDW';

    cursor supplier_item_num_cur is
        select  supplier_item_pk
          from  EDW_POA_SPIM_SPLRITEM_FKV
         where  vendor_name = p_supplier_name
           and  vendor_site_code = p_supplier_site_code
           and  vendor_product_num = p_supplier_product_num;
  BEGIN
         OPEN  supplier_item_num_cur;
        FETCH  supplier_item_num_cur into l_fk;
        CLOSE  supplier_item_num_cur;

        return nvl(l_fk, 'NA_EDW');

  EXCEPTION when others then
        if supplier_item_num_cur%ISOPEN then
          close supplier_item_num_cur;
        end if;

	return ('NA_EDW');

  END Supplier_Item_SC_FK;

END EDW_SUPPLIER_ITEM_PKG;

/

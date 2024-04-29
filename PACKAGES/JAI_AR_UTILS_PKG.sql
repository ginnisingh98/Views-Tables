--------------------------------------------------------
--  DDL for Package JAI_AR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_UTILS_PKG" 
/* $Header: jai_ar_utils.pls 120.1 2005/07/20 12:57:01 avallabh ship $ */
AUTHID CURRENT_USER AS

PROCEDURE recalculate_tax(transaction_name VARCHAR2, P_tax_category_id NUMBER, p_header_id NUMBER, p_line_id NUMBER,
          p_assessable_value NUMBER default 0, p_tax_amount IN OUT NOCOPY NUMBER,
          p_currency_conv_factor NUMBER, p_inventory_item_id NUMBER, p_line_quantity NUMBER, p_uom_code VARCHAR2,
          p_vendor_id NUMBER, p_currency VARCHAR2,
          p_creation_date DATE, p_created_by NUMBER, p_last_update_date DATE, p_last_updated_by NUMBER, p_last_update_login NUMBER ,
          p_vat_assessable_Value NUMBER Default 0
          );

Procedure locator_handler(
   p_trx_id NUMBER,
   p_flag VARCHAR2  -- DEFAULT 'Y'  -- Use jai_constants.yes in the call of this procedure. rpokkula for for File.Sql.35
 );

/*FUNCTION get_register_type(i_item_id NUMBER)
RETURN VARCHAR2;
*/

PROCEDURE apps_rel_insert(p_org_id  IN NUMBER, p_loc_id IN NUMBER, p_rg_flag  IN Varchar2,
          p_reg_name IN Varchar2 ,p_complete_flag  IN Varchar2, p_cretaed_by IN Number,
    last_updated_by IN Number, p_last_update_login IN Number, p_creation_date IN Date, last_update_date IN Date);

END jai_ar_utils_pkg;
 

/

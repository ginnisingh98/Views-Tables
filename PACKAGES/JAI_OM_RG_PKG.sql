--------------------------------------------------------
--  DDL for Package JAI_OM_RG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OM_RG_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_om_rg.pls 120.6.12010000.4 2010/04/06 11:54:28 mbremkum ship $ */

   /* Bug 4562791. Added by Lakshmi Gopalsami */

   gl_accounting_date Date;

   /* Bug 4931887. Added by Lakshmi Gopalsami
      Added the following cursor as part of perf. fixes
      for sql id's
      14830451
      14830172
      14829872
   */
   CURSOR get_curr_code (p_org_id IN NUMBER , p_loc_id IN NUMBER ) IS
   SELECT fnd.currency_code
     FROM fnd_currencies fnd,
          gl_ledgers gl
    WHERE gl.currency_code = fnd.currency_code
      AND gl.ledger_id IN (SELECT  org.set_of_books_id
                             FROM  org_organization_definitions org ,
			            jai_cmn_rg_balances rg ,
				    jai_cmn_inventory_orgs invorg
			      WHERE  org.organization_id = rg.organization_id
			       AND rg.org_unit_id  = invorg.org_unit_id
  			       AND  nvl(invorg.trading,'N') <> 'Y'
			       AND  rg.organization_id = p_org_id
			       AND  rg.location_id  = p_loc_id
				)
   ;

   PROCEDURE ja_in_rg_I_entry
   (
     p_fin_year                 NUMBER                                          ,
     p_org_id                   NUMBER                                          ,
     p_location_id              NUMBER                                          ,
     p_inventory_item_id        NUMBER                                          ,
     p_transaction_id           NUMBER                                          ,
     p_transaction_date         DATE                                            ,
     p_transaction_type         VARCHAR2                                        ,
     p_header_id                NUMBER                                          ,
     p_excise_quantity          NUMBER                                          ,
     p_excise_amount            NUMBER                                          ,
     p_uom_code                 VARCHAR2                                        ,
     p_excise_invoice_no        VARCHAR2                                        ,
     p_excise_invoice_date      DATE                                            ,
     p_payment_register         VARCHAR2                                        ,
     p_basic_ed                 NUMBER                                          ,
     p_additional_ed            NUMBER                                          ,
     p_other_ed                 NUMBER                                          ,
     p_excise_duty_rate         NUMBER                                          ,
     p_customer_id              NUMBER                                          ,
     p_customer_site_id         NUMBER                                          ,
     p_register_code            VARCHAR2                                        ,
     p_creation_date            DATE                                            ,
     p_created_by               NUMBER                                          ,
     p_last_update_date         DATE                                            ,
     p_last_updated_by          NUMBER                                          ,
     p_last_update_login        NUMBER                                          ,
     p_assessable_value         NUMBER                                          ,
     p_cess_amt                 JAI_CMN_RG_I_TRXS.CESS_AMT%TYPE  DEFAULT NULL   ,
     				                p_sh_cess_amt        JAI_CMN_RG_I_TRXS.SH_CESS_AMT%TYPE  DEFAULT NULL  , /*Bug 5989740 bduvarag*/
     p_source                   JAI_CMN_RG_I_TRXS.SOURCE%TYPE    DEFAULT NULL     /*Parameters p_cess_amt and p_source added by aiyer for the bug 4566054 */
   );

   PROCEDURE ja_in_rg23_part_I_entry
   (
     p_register_type VARCHAR2,
     p_fin_year NUMBER,
     p_org_id NUMBER,
     p_location_id NUMBER,
     p_inventory_item_id NUMBER,
     p_transaction_id NUMBER,
     p_transaction_date DATE,
     p_transaction_type VARCHAR2,
     p_excise_quantity NUMBER,
     p_uom_code VARCHAR2,
     p_excise_invoice_id VARCHAR2,
     p_excise_invoice_date DATE,
     p_basic_ed NUMBER,
     p_additional_ed NUMBER,
     p_other_ed NUMBER,
     p_customer_id NUMBER,
     p_customer_site_id NUMBER,
     p_header_id VARCHAR2,
     p_sales_invoice_date DATE,
     p_register_code  VARCHAR2,
     p_creation_date DATE,
     p_created_by NUMBER,
     p_last_update_date DATE,
     p_last_updated_by NUMBER,
     p_last_update_login NUMBER
   );

   PROCEDURE ja_in_rg23_part_II_entry
   (
     p_register_code VARCHAR2,
     p_register_type VARCHAR2,
     p_fin_year NUMBER,
     p_org_id NUMBER,
     p_location_id NUMBER,
     p_inventory_item_id NUMBER,
     p_transaction_id NUMBER,
     p_transaction_date DATE,
     p_part_i_register_id NUMBER,
     p_excise_invoice_no VARCHAR2,
     p_excise_invoice_date DATE,
     p_dr_basic_ed NUMBER,
     p_dr_additional_ed NUMBER,
     p_dr_other_ed NUMBER,
     p_customer_id NUMBER,
     p_customer_site_id NUMBER,
     p_source_name VARCHAR2,
     p_category_name VARCHAR2,
     p_creation_date DATE,
     p_created_by NUMBER,
     p_last_update_date DATE,
     p_last_updated_by NUMBER,
     p_last_update_login NUMBER,
     p_picking_line_id NUMBER DEFAULT NULL,
     p_excise_exempt_type VARCHAR2 DEFAULT NULL,
     p_remarks VARCHAR2 DEFAULT NULL ,
     P_REF_10 VARCHAR2 DEFAULT NULL ,
     -- added by sriram -- bug # 2769440
     P_REF_23 VARCHAR2 DEFAULT NULL ,
     -- added by sriram -- bug # 2769440
     P_REF_24 VARCHAR2 DEFAULT NULL ,
     -- added by sriram -- bug # 2769440
     P_REF_25 VARCHAR2 DEFAULT NULL ,
     -- added by sriram --bug # 2769440
     P_REF_26 VARCHAR2 DEFAULT NULL  -- added by sriram -- bug # 2769440
   );

   PROCEDURE ja_in_pla_entry
   (
      p_org_id NUMBER,
      p_location_id NUMBER,
      p_inventory_item_id NUMBER,
      p_fin_year NUMBER,
      p_transaction_id NUMBER,
      p_header_id  NUMBER,
      p_ref_document_date  DATE,
      p_excise_invoice_no VARCHAR2,
      p_excise_invoice_date DATE,
      p_dr_basic_ed NUMBER,
      p_dr_additional_ed NUMBER,
      p_dr_other_ed NUMBER,
      p_customer_id NUMBER,
      p_customer_site_id NUMBER,
      p_source_name VARCHAR2,
      p_category_name VARCHAR2,
      p_creation_date DATE,
      p_created_by NUMBER,
      p_last_update_date DATE,
      p_last_updated_by NUMBER,
      p_last_update_login NUMBER ,
      P_REF_10 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_23 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_24 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_25 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_26 VARCHAR2 DEFAULT NULL  -- added by sriram - bug # 2769440
   );

   PROCEDURE ja_in_register_txn_entry
   (
      p_org_id NUMBER,
      p_location_id NUMBER,
      p_excise_invoice_no VARCHAR2,
      p_transaction_name VARCHAR2,
      p_order_flag  VARCHAR2,
      p_header_id  NUMBER,
      p_transaction_amount  NUMBER,
      p_register_code  VARCHAR2,
      p_creation_date DATE,
      p_created_by NUMBER,
      p_last_update_date DATE,
      p_last_updated_by NUMBER,
      p_last_update_login NUMBER,
      p_order_invoice_type_id IN Number DEFAULT NULL,
      p_currency_rate  IN NUMBER DEFAULT 1  /* added by CSahoo - bug#5390583  */
   );

   PROCEDURE Ja_In_Rg23d_Entry
   (
      p_register_id NUMBER,
      p_org_id NUMBER,
      p_location_id NUMBER,
      p_fin_year NUMBER,
      p_transaction_type VARCHAR2,
      p_inventory_item_id NUMBER,
      p_reference_line_id NUMBER,
      p_primary_uom_code VARCHAR2,
      p_transaction_uom_code VARCHAR2,
      p_customer_id NUMBER,
      p_bill_to_site_id NUMBER,
      p_ship_to_site_id NUMBER,
      p_quantity_issued NUMBER,
      p_register_code VARCHAR2,
      p_rate_per_unit NUMBER,
      p_excise_duty_rate NUMBER,
      p_duty_amount NUMBER,
      p_transaction_id NUMBER,
      p_source_name VARCHAR2,
      p_category_name VARCHAR2,
      p_receipt_id NUMBER,
      p_oth_receipt_id NUMBER,
      p_creation_date DATE,
      p_created_by NUMBER,
      p_last_update_date DATE,
      p_last_update_login NUMBER,
      p_last_updated_by NUMBER,
      p_dr_basic_ed NUMBER,
      p_dr_additional_ed NUMBER,
      p_dr_other_ed NUMBER,
      p_comm_invoice_no VARCHAR2,
      p_comm_invoice_date DATE,
      P_REF_10 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_23 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_24 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_25 VARCHAR2 DEFAULT NULL ,
      -- added by sriram - bug # 2769440
      P_REF_26 VARCHAR2 DEFAULT NULL  ,-- added by sriram - bug # 2769440
      p_dr_cvd_amt NUMBER DEFAULT NULL, --Added by nprashar for bug # 5735284 added for bug#6199766
      p_dr_additional_cvd_amt NUMBER DEFAULT NULL --Added by nprashar for bug # 5735284 added for bug#6199766
   );

   /*Bug 9550254 - Start*/
   FUNCTION ja_in_rgi_balance(
 	                 p_organization_id in number,
 	                 p_location_id in number,
 	                 p_inventory_item_id in number,
 	                 p_curr_finyear in number,
 	                 p_slno out NOCOPY number,
 	                 p_balance_packed out NOCOPY number) return number;

   FUNCTION ja_in_rg23i_balance(
 	                 p_organization_id in number,
 	                 p_location_id in number,
 	                 p_inventory_item_id in number,
 	                 p_curr_finyear in number,
 	                 p_register_type in varchar2,
 	                 p_slno out NOCOPY number) return number;

   /*Bug 9550254 - End*/

END jai_om_rg_pkg;

/

--------------------------------------------------------
--  DDL for Package Body JAI_JMCR_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_JMCR_TRIGGER_PKG" AS
/* $Header: jai_jcmr_t.plb 120.2 2007/08/21 10:45:48 vkaranam ship $ */

/*
  REM +======================================================================+
  REM NAME          ARIU_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_JCMR_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JCMR_ARIU_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARIU_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS

        v_quantity number; -- := pr_new.quantity_applied;  --rpokkula for File.Sql.35
        v_qty        number; -- := pr_new.quantity_applied;--rpokkula for File.Sql.35
        v_ref_line number; -- := pr_new.ref_line_id ;      --rpokkula for File.Sql.35
        v_receipt number; --  := pr_new.receipt_id;        --rpokkula for File.Sql.35
        v_line number;
        p_picking_header_id number;
        p_order_header_id number;
        p_org_id number;
        p_warehouse_id number;
        v_order_header_id number;
        v_converted_rate number;
        v_set_of_books_id  number;
        v_currency_code  varchar2(10);
        v_conv_date  date;
        v_conv_type_code varchar2(10);
        v_conv_rate number;
        v_picking_header_id number;
        v_org_id number;
        v_warehouse_id number;
        v_customer number;
        v_subinventory varchar2(30); -- := pr_new.subinventory;  --rpokkula for File.Sql.35
        v_order varchar2(1); --:=pr_new.ORDER_INVOICE;           --rpokkula for File.Sql.35
        v_link_to_cust_trx_line_id number;


        CURSOR so_picking_hdr_cur IS
                SELECT source_header_id, delivery_detail_id
                FROM wsh_delivery_details
                WHERE delivery_detail_id = pr_new.ref_line_id;

        CURSOR Org_warehouse_cur(p_picking_header_id NUMBER) IS
                SELECT NVL(org_id,0), ORGANIZATION_ID
                FROM wsh_delivery_details
                WHERE delivery_detail_id  = p_picking_header_id;

        -- Altered by Arun for 11i

        CURSOR get_conv_detail_cur(p_order_header_id Number) IS
                SELECT TRANSACTIONAL_CURR_CODE, conversion_type_code, conversion_rate,
                NVL(conversion_rate_date,ordered_date) conversion_date
                FROM oe_order_headers_all
                WHERE header_id = p_order_header_id;
        /* Bug 5243532. Added by Lakshmi Gopalsami
	 * Removed the cursor set_of_books_cur as this
	 * is not used anywhere.
	 */

        cursor line_id is
                select source_line_id
                from wsh_delivery_details
                where delivery_detail_id =pr_new.ref_line_id;

        cursor customer is
                select bill_to_customer_id
                from ra_customer_trx_all
                where customer_trx_id in (select customer_trx_id from ra_customer_trx_lines_all
                        where customer_trx_line_id =pr_new.ref_line_id);

        CURSOR Tax_Amount_Cur IS
                SELECT sum(a.tax_amount) tax_amount
                FROM JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
                WHERE a.tax_id = b.tax_id
                AND a.link_to_cust_trx_line_id = v_ref_line
                AND b.tax_type NOT IN (
          jai_constants.tax_type_tds ,
          jai_constants.tax_type_modvat_recovery);
    --AND b.tax_type NOT IN ('TDS','Modvat Recovery');
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*-------------------------------------------------------------------------------------------
Change History for FileName: ja_in_receipts_match_ar_trg.sql
S.No.  dd/mm/yyyy   Author and Details
---------------------------------------------------------------------------------------------
1      17/06/2003   Vijay Shankar for Bug# 3007159, FileVersion# 616.1
                     the trigger is getting fired for all the Sales and Invoice transactions. but actually this should get
                     fired only for AR Invoice transactions. inorder to make this trigger fire only for sales order transactions,
                     the when condition of the trigger is modified

2.    08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done
-------------------------------------------------------------------------------------------*/

    v_quantity := pr_new.quantity_applied;  --rpokkula for File.Sql.35
    v_qty      := pr_new.quantity_applied;  --rpokkula for File.Sql.35
    v_ref_line := pr_new.ref_line_id ;      --rpokkula for File.Sql.35
    v_receipt  := pr_new.receipt_id;        --rpokkula for File.Sql.35
    v_subinventory := pr_new.subinventory;  --rpokkula for File.Sql.35
    v_order        :=pr_new.ORDER_INVOICE;  --rpokkula for File.Sql.35

        /* commented by cbabu for Bug# 3007159, found to be redundant code
    open so_picking_hdr_cur;
    fetch so_picking_hdr_cur into v_order_header_id,v_picking_header_id;
    close so_picking_hdr_cur;

    open Org_warehouse_cur(v_picking_header_id);
    fetch Org_warehouse_cur into v_org_id,v_warehouse_id;
    close Org_warehouse_cur;

    open line_id;
    fetch line_id into v_link_to_cust_trx_line_id;
    close line_id;

    open get_conv_detail_cur(v_order_header_id);
    fetch get_conv_detail_cur into v_currency_code,v_conv_type_code,v_conv_rate,v_conv_date;
    close get_conv_detail_cur;

    open set_of_books_cur(v_org_id,v_warehouse_id);
    fetch set_of_books_cur into v_set_of_books_id;
    close set_of_books_cur;
    */

    open customer;
    fetch customer into v_customer;
    close customer;

        /*
        v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_set_of_books_id ,v_currency_code ,
                                 v_conv_date ,v_conv_type_code,v_conv_rate);

    IF nvl(v_quantity,0) = 0 THEN
       v_quantity := -nvl(pr_old.quantity_applied,0);
    END IF;

        UPDATE  JAI_AR_TRX_LINES
        SET   matched_quantity = nvl(matched_quantity,0) + v_quantity
        WHERE Customer_Trx_Line_Id = v_ref_line;
    */

    -- if v_order='I' then

    jai_cmn_rcv_matching_pkg.ar_default_taxes(v_ref_line, v_customer, v_ref_line, 1, v_receipt, v_qty);

    --end if;

    FOR rec IN tax_amount_cur LOOP
      UPDATE JAI_AR_TRX_LINES
      SET tax_amount = rec.tax_amount,
                  total_amount = line_amount + rec.tax_amount
      WHERE Customer_Trx_Line_Id = v_ref_line;

    END LOOP;

   /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JMCR_TRIGGER_PKG.ARIU_T1 '  || substr(sqlerrm,1,1900);

  END ARIU_T1 ;

  /*
  REM +======================================================================+
  REM NAME          ARIU_T2
  REM
  REM DESCRIPTION   Called from trigger JAI_JCMR_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_JCMR_ARIU_T3
  REM
  REM +======================================================================+
  */
PROCEDURE ARIU_T2 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
  v_quantity number; -- := pr_new.quantity_applied;  --Ramananda for File.Sql.35
v_ref_line number; -- := pr_new.ref_line_id ;     --Ramananda for File.Sql.35
v_receipt number;  -- := pr_new.receipt_id;       --Ramananda for File.Sql.35
v_line number;
p_picking_header_id number;
p_order_header_id number;
p_org_id number;
p_warehouse_id number;
v_order_header_id number;
v_converted_rate number;
v_set_of_books_id  number;
v_currency_code  varchar2(10);
v_conv_date  date;
v_conv_type_code varchar2(10);
v_conv_rate number;
v_picking_header_id number;
v_org_id number;
v_warehouse_id number;
v_customer number;
v_order varchar2(1); --:=pr_new.ORDER_INVOICE;  --Ramananda for File.Sql.35


  CURSOR so_picking_hdr_cur IS
    SELECT source_header_id, delivery_detail_id
    FROM   wsh_delivery_details
    WHERE  delivery_detail_id = pr_new.ref_line_id;

  -- Altered by Arun for 11i.
  CURSOR Org_warehouse_cur(p_picking_header_id NUMBER) IS
    SELECT NVL(org_id,0), ORGANIZATION_ID
    FROM wsh_delivery_details
    WHERE delivery_detail_id = p_picking_header_id;

  CURSOR get_conv_detail_cur(p_order_header_id Number) IS
    SELECT TRANSACTIONAL_CURR_CODE, conversion_type_code, conversion_rate,
    NVL(conversion_rate_date,ordered_date) conversion_date
    FROM oe_order_headers_all
    WHERE header_id = p_order_header_id;

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed the cursor set_of_books_cur as this
   * is not used anywhere.
   */

  -- Altered by Arun for 11i
  cursor line is select source_line_id
    from wsh_delivery_details
    where delivery_detail_id =pr_new.ref_line_id;

  -- Altered by Arun for 11i
  cursor customer is
  select SOLD_TO_ORG_ID
  from oe_order_headers_all
  where header_id in (select source_header_id
      from wsh_delivery_details
      where delivery_detail_id =pr_new.ref_line_id );


  BEGIN
    pv_return_code := jai_constants.successful ;

/*-------------------------------------------------------------------------------------------
Change History for FileName: ja_in_receipts_match_trigger.sql
S.No.  dd/mm/yyyy   Author and Details
---------------------------------------------------------------------------------------------
1      17/06/2003   Vijay Shankar for Bug# 3007159, FileVersion# 616.1
                     the trigger is getting fired for all the Sales and Invoice transactions. but actually this should get
                     fired only for Sales Order transactions. inorder to make this trigger fire only for sales order transactions,
                     the when condition of the trigger is modified

2     08-Jun-2005   This Object is Modified to refer to New DB Entity names in place of Old
                    DB Entity as required for CASE COMPLAINCE.  Version 116.1

3. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done
-------------------------------------------------------------------------------------------*/

v_quantity := pr_new.quantity_applied;  --Ramananda for File.Sql.35
v_ref_line := pr_new.ref_line_id ;     --Ramananda for File.Sql.35
v_receipt  := pr_new.receipt_id;       --Ramananda for File.Sql.35
v_order    :=pr_new.ORDER_INVOICE;  --Ramananda for File.Sql.35



/* commented by cbabu for Bug# 3007159, found to be redundant code
open so_picking_hdr_cur;
fetch so_picking_hdr_cur into v_order_header_id, v_picking_header_id;
close so_picking_hdr_cur;

open Org_warehouse_cur(v_picking_header_id);
fetch Org_warehouse_cur into v_org_id, v_warehouse_id;
close Org_warehouse_cur;

open get_conv_detail_cur(v_order_header_id);
fetch get_conv_detail_cur into v_currency_code, v_conv_type_code, v_conv_rate, v_conv_date;
close get_conv_detail_cur;

open set_of_books_cur(v_org_id,v_warehouse_id);
fetch set_of_books_cur into v_set_of_books_id;
close set_of_books_cur;
*/

open line;
fetch line into v_line;
close line;

open customer;
fetch customer into v_customer;
close customer;

-- if v_order='O' then
/*added teh below condition by vkaranma for bug#6030615(interorg)*/
IF v_order = 'X' THEN
      v_line:= v_ref_line;
END IF;


jai_cmn_rcv_matching_pkg.om_default_taxes(pr_new.subinventory, v_customer, v_ref_line,
    v_receipt, v_line, v_quantity, 1, v_order);

-- RAISE_APPLICATION_ERROR(-20120, 'Bonded Register Has AFTER -> ') ;

-- end if;
   /* Added an exception block by Ramananda for bug#4570303 */
 EXCEPTION
   WHEN OTHERS THEN
     Pv_return_code     :=  jai_constants.unexpected_error;
     Pv_return_message  := 'Encountered an error in JAI_JMCR_TRIGGER_PKG.ARIU_T2 '  || substr(sqlerrm,1,1900);

  END ARIU_T2 ;

END JAI_JMCR_TRIGGER_PKG ;

/

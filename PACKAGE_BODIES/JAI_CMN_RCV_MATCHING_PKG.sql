--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RCV_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RCV_MATCHING_PKG" AS
/* $Header: jai_cmn_rcv_mach.plb 120.18.12010000.8 2010/06/11 11:33:31 vkaranam ship $ */

PROCEDURE automatic_match_process(
        errbuf OUT NOCOPY VARCHAR2,
        p_created_by IN NUMBER,
        p_last_update_login IN NUMBER,
        p_organization_id IN NUMBER,
        p_customer_id IN NUMBER,
        p_order_type_id IN NUMBER,
        p_delivery_id IN NUMBER DEFAULT null,
        p_delivery_detail_id IN NUMBER DEFAULT null,
        p_order_header_id IN NUMBER DEFAULT null,
        p_line_id IN NUMBER DEFAULT null
    )
IS
/*------------------------------------------------------------------------------------------------------------------
Sl.No. dd/mm/yyyy   Author and Details
-----  ----------   ----------------
1      12/07/2002   Vijay Created this procedure for Bug#2083127
                    This procedure is used to match all the delivery details present in a delivery, with the corresponding receipts
                    present in the register. Receipts are matched based on the inventory_item_id, organization AND location combination.
                    The order of the matching the receipts is FIFO.
                    Parameter for this procedure are
                    errbuf, p_organization_id, p_customer_id, p_order_type_id, p_delivery_id,
                    p_delivery_detail_id, p_order_header_id, p_line_number

2      13/12/2002  cbabu for Bug# 2689425, FileVersion# 615.2
                    Quantity available is calculated as JAI_CMN_RG_23D_TRXS.quantity_received - quantity that is matched, but it not
                    including the RTV quantity, that is calculating wrongly. Changes made
                      Quantity  Available is modified to be calculated as
                            ( JAI_CMN_RG_23D_TRXS.qty_to_adjust - deliver quantity matched with receipt but not ship confirmed )

3. 08-Jun-2005  Version 116.2 jai_cmn_rcv_mach -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

4. 13-Jun-2005    File Version: 116.3
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

5. 26-FEB-2007   SSAWANT , File version 120.5
                 Forward porting the change in 11.5 bug 5068418 to R12 bug no 5091874.

     Issue :
                   Discount Tax is appearing as zero for order in Ship Confirm Localized screen
                 Cause :
                   An if condition is placed for restricting all tax precedance caluculations for
                   tax_rates <=0. This condition is restricting the calculation of precedance based 'Discount'
                   taxes ( which have tax_rate_tab (i) < 0 ). Thus the tax amount is calculated as zero.
                   The calculation should not be done for Adhoc / "Excise" and "CVD" taxes which have corresponding
                   tax rates defined in matched receipts.
                 Fix :
                   Old Condition      : IF tax_rate_tab( i ) > 0 AND End_Date_Tab(I) <> 0 THEN
                   Modified Condition : IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0 AND adhoc_flag_tab(i) = 'N' AND NOT ( tax_rate_tab(i) = -1 AND tax_type_tab(i) IN (1,3) ) THEN

                 Dependency Introduced due to this bug:
                  None
6.  13/04/2007    bduvarag for the Bug#5989740, file version 120.6
      Forward porting the changes done in 11i bug#5907436

7.  26/09/2007    rchandan for bug#6447097. File version 120.10
                  Issue : QA observations of Inter org
                    Fix ; Insert statement into Jai_cmn_match_Taxes did not included the PK
                          match_tax_id.
8.  23-apr-2009  vkaranam for bug#8445390,file version 120.18.12010000.2
                 Issue:
     In Interorg transfer for a trading org ,matching the transaction quantity against the multiple receipts
     is showing the wrong excise amount.
     Reason::
     UPDATE  Jai_cmn_document_Taxes
                SET  Tax_Amt = tax_amt_tab(i),
                  Func_Tax_Amt = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 )
            WHERE  source_doc_line_id = p_ref_line_id
           AND    source_doc_type = 'INTERORG_XFER'
           AND    Tax_Line_No = i;
         we are updating the tax amount of the last matched receipt line processed.

           Due to this the amount is not getting correctly.
Fix:
Modified the  update stmt as
 UPDATE  Jai_cmn_document_Taxes
     SET  Tax_Amt = nvl(tax_amt,0)+tax_amt_tab(i),   --added  nvl(tax_amt,0)
 for bug#8445390
 Func_Tax_Amt = nvl(Func_Tax_Amt,0)+tax_amt_tab(i) * NVL(
 p_curr_conv_factor, 1 ) --added  nvl(Func_Tax_Amt,0) for bug#8445390
   WHERE  source_doc_line_id = p_ref_line_id
   AND    source_doc_type = 'INTERORG_XFER'
   AND    Tax_Line_No = i;

9.  11-sep-2009   vkaranam for bug#8887871
                 issue:
                 VAT ASSESSABLE PRICE IS NOT CALCULATED AT SHIPCONFIRM(LOCALIZED) SCREEN
                 fix:
                 Changes are done to calculate the VAT tax based on the line amount.

10. 18-Jan-2010 CSahoo for bug#9288359, File Version 120.18.12010000.5
                Issue: NOT ABLE TO MATCH AND PASS ADDITIONAL CVD FROM TRADING ORGANIZATION TO OTHER ORG
                Fix: Modified the cursor Excise_Duty_Rate_Cur in the procedure om_default_taxes. Added the additional_cvd
                     in the cursor.

--------------------------------------------------------------------------------------------------------------------*/
-- fields in the view
--  organization_id, customer_id, inventory_item_id, picking_line_id,
--  subinventory, order_no, order_header_id, line_id, uom,
--  release_qty, delivery_id, order_type_id
--  ,org_id, location_id

    CURSOR c_match_details IS
        SELECT customer_id, inventory_item_id,
            picking_line_id delivery_detail_id,
            organization_id, subinventory sub_inventory_name, order_no order_number,
            order_header_id header_id, release_qty requested_quantity, delivery_id,
            order_type_id, location_id ship_from_location_id, uom requested_quantity_uom
        FROM JAI_OE_MATCH_LINES_V
        WHERE organization_id = p_organization_id
        AND order_type_id = p_order_type_id
        AND delivery_id = nvl(p_delivery_id, delivery_id)
        AND picking_line_id = nvl(p_delivery_detail_id, picking_line_id)
        AND customer_id = nvl(p_customer_id, customer_id)
        AND order_header_id = nvl(p_order_header_id, order_header_id)
        AND line_id= nvl(p_line_id, line_id);

    CURSOR c_qty_app_on_receipt( p_receipt_id IN NUMBER ) IS
        SELECT SUM(receipt_quantity_applied)
        FROM JAI_CMN_MATCH_RECEIPTS
        WHERE receipt_id = p_receipt_id
        AND ship_status IS NULL;        -- cbabu for Bug# 2689425

    CURSOR c_qty_matched(p_delivery_detail_id IN NUMBER) IS
        SELECT SUM(quantity_applied)
        FROM JAI_CMN_MATCH_RECEIPTS
        WHERE ref_line_id = p_delivery_detail_id
        and order_invoice = 'O';

-- this is commented in this cursor because, the subquery is taken care programmatically and if included in this cursor
--then it becomes a performance issue.
    CURSOR c_receipts_for_item( p_organization_id IN NUMBER,
             p_location_id IN NUMBER,
             p_inventory_item_id IN NUMBER) IS
        SELECT * FROM JAI_CMN_RG_23D_TRXS
        WHERE organization_id = p_organization_id
        AND location_id = p_location_id
        AND inventory_item_id = p_inventory_item_id
        AND qty_to_adjust > 0
        ORDER BY register_id;

    v_exist NUMBER;
    CURSOR c_duplicate_record(p_register_id IN NUMBER, p_delivery_detail_id IN NUMBER) IS
      SELECT count(receipt_id)
      FROM JAI_CMN_MATCH_RECEIPTS
      WHERE receipt_id = p_register_id
      AND ref_line_id = p_delivery_detail_id
      AND order_invoice = 'O';

    v_QtyToMatch NUMBER := 0;
    v_QtyToMatchInRctUOM NUMBER := 0;
    v_ReceiptQtyAvailable NUMBER := 0;
    v_RctQtyAvailableInIssueUOM NUMBER := 0;
    v_QtyAppliedOnReceipt NUMBER := 0;
    v_UomConversion NUMBER := 0;

    v_DetailsProcessed NUMBER := 0;
    v_DetailsFetched NUMBER := 0;
    v_MatchedRcptsForDetail NUMBER := 0;

    v_QtyMatched NUMBER;
    v_QtyApplied NUMBER;
    v_QtyAppliedInRcptUom NUMBER;

   lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rcv_matching_pkg.automatic_match_process'; /* Added by Ramananda for bug#4407165 */


BEGIN

    errbuf := null;

    FOR match_detail IN c_match_details LOOP

        OPEN c_qty_matched(match_detail.delivery_detail_id) ;
        FETCH c_qty_matched INTO v_QtyMatched;
        CLOSE c_qty_matched;

        v_QtyToMatch := match_detail.requested_quantity - nvl(v_QtyMatched,0);

    IF v_QtyToMatch > 0 THEN

        FOR rg23d_entry IN c_receipts_for_item( match_detail.organization_id,
            match_detail.ship_from_location_id, match_detail.inventory_item_id)
        LOOP

            OPEN c_qty_app_on_receipt(rg23d_entry.register_id) ;
            FETCH c_qty_app_on_receipt INTO v_QtyAppliedOnReceipt;
            CLOSE c_qty_app_on_receipt;

            -- v_ReceiptQtyAvailable := nvl(rg23d_entry.quantity_received,0) - nvl(v_QtyAppliedOnReceipt,0);    -- cbabu for Bug# 2689425
            v_ReceiptQtyAvailable := nvl(rg23d_entry.qty_to_adjust,0) - nvl(v_QtyAppliedOnReceipt,0);   -- cbabu for Bug# 2689425

            IF v_ReceiptQtyAvailable > 0 THEN  --xyz

                Inv_Convert.Inv_Um_Conversion( rg23d_entry.primary_uom_code,
                        match_detail.requested_quantity_uom, rg23d_entry.Inventory_item_id, v_UomConversion);
                Inv_Convert.Inv_Um_Conversion( rg23d_entry.primary_uom_code,
                        match_detail.requested_quantity_uom, rg23d_entry.Inventory_item_id, v_UomConversion);
                IF nvl(v_UomConversion, 0) <= 0 THEN
                    Inv_Convert.Inv_Um_Conversion( rg23d_entry.primary_uom_code,
                            match_detail.requested_quantity_uom, 0, v_UomConversion);
                END IF;
                IF nvl(v_UomConversion, 0) <= 0 THEN
                    v_UomConversion := 1;
                END IF;

                v_RctQtyAvailableInIssueUOM := v_ReceiptQtyAvailable * v_UomConversion;
                v_QtyToMatchInRctUOM := v_QtyToMatch / v_UomConversion;

                fnd_file.put_line(fnd_file.log, '2 v_QtyToMatch = '||v_QtyToMatch||', v_RctQtyAvailableInIssueUOM = '||v_RctQtyAvailableInIssueUOM);
                -- Receipt Qty is less than Delivery Detail Qty,
                -- then loop through Receipts for Matching entire Delivery Detail Qty

                IF v_QtyToMatch > v_RctQtyAvailableInIssueUOM
                THEN
                    v_QtyApplied := v_RctQtyAvailableInIssueUOM;
                    v_QtyAppliedInRcptUom := v_ReceiptQtyAvailable;

                    v_QtyToMatch := v_QtyToMatch - v_RctQtyAvailableInIssueUOM;
                    v_MatchedRcptsForDetail := v_MatchedRcptsForDetail + 1;

                -- Receipt Qty is more than Delivery Detail Qty,
                -- then match with the corresponding receipt AND come out receipts loop
                ELSIF v_QtyToMatch <= v_RctQtyAvailableInIssueUOM THEN
                    v_QtyApplied := v_QtyToMatch;
                    v_QtyAppliedInRcptUom := v_QtyToMatchInRctUOM;

                    v_QtyToMatch := 0;
                    v_MatchedRcptsForDetail := v_MatchedRcptsForDetail + 1;
                ELSE
                    errbuf := 'Dont know whats the error.  Quantity to match = '||v_QtyToMatch;
                    RAISE_APPLICATION_ERROR(-20120, 'Dont know whats the error.  Quantity to match = '||v_QtyToMatch );
                END IF; --aaa

                Open  c_duplicate_record(rg23d_entry.register_id, match_detail.delivery_detail_id);
                Fetch c_duplicate_record Into v_exist;
                Close c_duplicate_record;
                --fnd_file.put_line(fnd_file.log, '2 v_QtyToMatch = '||v_QtyToMatch||', v_RctQtyAvailableInIssueUOM = '||v_RctQtyAvailableInIssueUOM);
                IF NVL(v_exist,0) <> 1 Then
                    INSERT INTO JAI_CMN_MATCH_RECEIPTS (
                        receipt_id, ref_line_id,
                        subinventory, quantity_applied,
                        issue_uom, receipt_quantity_applied, receipt_quantity_uom,
                        order_invoice, ship_status,
                        creation_date, created_by, last_update_date, last_update_login, last_updated_by)
                    VALUES (
                        rg23d_entry.register_id, match_detail.delivery_detail_id,
                        match_detail.sub_inventory_name, v_QtyApplied,
                        match_detail.requested_quantity_uom, v_QtyAppliedInRcptUom, rg23d_entry.primary_uom_code
                        , 'O', null,
                        sysdate, p_created_by, sysdate, p_last_update_login, p_created_by);
                ELSE
                    UPDATE JAI_CMN_MATCH_RECEIPTS
                        SET quantity_applied = v_QtyApplied,
                            receipt_quantity_applied = v_QtyAppliedInRcptUom,
                            last_update_login = p_last_update_login,
                            last_update_date = sysdate
                        WHERE receipt_id = rg23d_entry.register_id
                        AND ref_line_id = match_detail.delivery_detail_id
                        AND order_invoice = 'O';
                END IF;

                IF v_QtyToMatch = 0 THEN
                    EXIT;
                END IF;
            END IF; --xyz
        END LOOP;

        fnd_file.put_line(fnd_file.log, match_detail.delivery_id ||', '||match_detail.delivery_detail_id ||', Matched receipts = '||v_MatchedRcptsForDetail);
        IF v_QtyToMatch > 0 THEN
            ROLLBACK;
            errbuf := 'Enough receipt quantity is not available for the Detail ' || match_detail.delivery_detail_id||', Delivery = '||match_detail.delivery_id;
            RAISE_APPLICATION_ERROR(-20120, '11 Enough Quantity is not available for the Delivery = '||match_detail.delivery_id||', and Delivery Line = ' || match_detail.delivery_detail_id);
        END IF;

        IF v_MatchedRcptsForDetail = 0 THEN
            ROLLBACK;
            errbuf := 'No Receipts found for the receipt with item id = '|| match_detail.inventory_item_id;
            RAISE_APPLICATION_ERROR(-20120, '2 No Receipts found for the receipt with item id = '
                || match_detail.inventory_item_id );
        END IF;

        v_UomConversion := 0;
        v_ReceiptQtyAvailable := 0;
        v_RctQtyAvailableInIssueUOM := 0;
        v_QtyToMatch := 0;
        v_QtyToMatchInRctUOM := 0;
        v_QtyAppliedOnReceipt := 0;

        v_MatchedRcptsForDetail := 0;
        v_DetailsProcessed := v_DetailsProcessed + 1;

    ELSE        -- for v_QtyToMatch <= 0
        null;
    END IF;

        v_QtyToMatch := null;
        v_DetailsFetched := v_DetailsFetched + 1;
    END LOOP;


    IF v_DetailsProcessed = 0 THEN
        ROLLBACK;
        IF v_DetailsFetched <> 0 THEN
            errbuf := 'Details already matched for the given inputs';
            RAISE_APPLICATION_ERROR(-20120, 'Details already matched for the given inputs');
        ELSE
            errbuf := 'No details found for the given inputs';
            RAISE_APPLICATION_ERROR(-20120, 'No details found for the given inputs');
        END IF;
    END IF;
    COMMIT;
    errbuf := 'Automatic matching is Successful. Total no of Delivery details processed = ' || v_DetailsProcessed;

    /* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    errbuf  := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END automatic_match_process;

/*
Commented during the removal of sql literals

PROCEDURE opm_default_taxes( p_subinventory IN VARCHAR2,
                                                  p_customer_id IN NUMBER,
                                                  p_ref_line_id IN NUMBER,
                                                  p_receipt_id IN NUMBER,
                                                  p_line_id NUMBER,  -- For OE it is Line ID, for AR it is Link to cust trx line id
                                                  p_line_quantity IN NUMBER,
                                                  p_curr_conv_factor IN NUMBER,
                                                  p_order_invoice IN VARCHAR2 ,
                                  p_line_no Number ) IS

------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: ja_in_gem_rg23_d_cal_tax_prc.sql
S.No  Date        Author and Details
------------------------------------------------------------------------------------------
1     20/05/2004  Aiyer for Bug#3433634 - 712.1
                  Changed the population of end_date_tab variable based on the JAI_OPM_TAXES.end date
                  column value.
                  Now the code is changed so that the tax amount would be set to zero only in case of records having end dates
                  falling prior to the current date.
                  The tax amount would be calculated for all open end dates (i.e null end dates)
                  and end dates equal to or greater than the current date (sysdate).
                  Dependency Due to this Bug: -
                  None

2.    01/11/2006 SACSETHI for bug 5228046, File version 120.4
                 1. Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
                    This bug has datamodel and spec changes.

     2. Forward porting of 11i bug 5219225 as part of removal of CVD and Additional CVD
------------------------------------------------------------------------------------------


  TYPE Num_Tab IS
  TABLE OF NUMBER(14,3)
  INDEX BY BINARY_INTEGER;
  TYPE Tax_Amt_Num_Tab IS
  TABLE OF NUMBER(14,4)
  INDEX BY BINARY_INTEGER;

  p1                    NUM_TAB                         ;
  p2                    NUM_TAB                         ;
  p3                    NUM_TAB                         ;
  p4                    NUM_TAB                         ;
  p5                    NUM_TAB                         ;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
  p6                    NUM_TAB                         ;
  p7                    NUM_TAB                         ;
  p8                    NUM_TAB                         ;
  p9                    NUM_TAB                         ;
  p10                   NUM_TAB                         ;
-- END BUG 5228046


  tax_rate_tab          NUM_TAB                         ;
  tax_type_tab          NUM_TAB                         ;
  end_date_tab          NUM_TAB                         ;
  tax_amt_tab           TAX_AMT_NUM_TAB                 ;
  tax_target_tab        TAX_AMT_NUM_TAB                 ;
  rounding_factor_tab   TAX_AMT_NUM_TAB                 ;

  v_exempt_flag         VARCHAR2(2); --     := 'N'          ; --Ramananda for File.Sql.35
  v_address_id          NUMBER                          ;
  i                     NUMBER                          ;
  excise_flag_set       BOOLEAN         := FALSE        ;
  v_inventory_item_id   NUMBER;
  v_unit_code           VARCHAR2(15)                    ;
  v_selling_price       NUMBER                          ;
  v_amt                 NUMBER                          ;
  v_cum_amount          NUMBER                          ;
  bsln_amt              NUMBER                          ;
  row_count             NUMBER          := 0            ;
  v_tax_amt             NUMBER(14,4)    := 0            ;
  vamt                  NUMBER(14,4)    := 0            ;
  v_conversion_rate     NUMBER                          ;
  counter               NUMBER                          ;
  max_iter              NUMBER          := 10           ;
  conv_rate             NUMBER                          ;
  v_count               NUMBER          := 0            ;
  v_original_quantity   NUMBER          := 0            ;
  v_matched_quantity    NUMBER          := 0            ;
  v_excise_duty_rate    NUMBER                          ;
  TT                    NUMBER                          ;
  div_fac               NUMBER                          ;
  v_order_um1           VARCHAR2(20)                    ;
  v_exchage_rate        NUMBER                          ;
  v_item_id             NUMBER                          ;
  v_primary_uom_code    VARCHAR2(4)                     ;
  v_item_um_f           NUMBER                          ;


  CURSOR oe_tax_cur IS        ---- OE Side
  SELECT
        a.tax_id                            ,
        a.tax_line_no  lno                  ,
        a.precedence_1 p_1                  ,
        a.precedence_2 p_2                  ,
        a.precedence_3 p_3                  ,
        a.precedence_4 p_4                  ,
        a.precedence_5 p_5                  ,
        a.precedence_6 p_6                  , -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        a.precedence_7 p_7                  ,
        a.precedence_8 p_8                  ,
        a.precedence_9 p_9                  ,
        a.precedence_10 p_10                ,
  a.qty_rate                          ,
        a.tax_rate                          ,
        a.tax_amount                        ,
        a.uom                               ,
        nvl( to_char(b.end_date,'DD-MON-YYYY'),
             to_char(sysdate,'DD-MON-YYYY')
           )           valid_date   ,        -- Changed by aiyer for the bug 3433634
        decode(
                 upper(b.tax_type)  ,
                 'EXCISE'           ,
                 1                  ,
                 'ADDL. EXCISE'     ,
                 1                  ,
                 'OTHER EXCISE'     ,
                 1                  ,
                 'CVD'              ,
                 1                  ,
                 'TDS'              ,
                 2                  ,
                 0
              )        tax_type_val ,
        b.mod_cr_Percentage         ,
        b.tax_type                  ,
        NVL( b.rounding_factor, 0 ) rnd
   FROM
        JAI_OPM_SO_PICK_TAXES  a,
        JAI_OPM_TAXES             b
  WHERE
        a.bol_id        = p_ref_line_id     AND
        a.bolline_no    = p_line_no         AND
        a.tax_id        = b.tax_id
 ORDER BY
        a.tax_line_no;


  CURSOR ar_tax_cur IS      ---- AR Side
  SELECT a.tax_id, a.tax_line_no lno,
       a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
       a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8, a.precedence_9 p_9, a.precedence_10 p_10,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       a.qty_rate,
       a.tax_rate, a.tax_amount, a.uom, b.end_date valid_date,
       decode(upper(b.tax_type),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, 'CVD',1, 'TDS', 2, 0) tax_type_val,
       b.mod_cr_Percentage, b.vendor_id, b.tax_type, NVL( b.rounding_factor, 0 ) rnd
   FROM  JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
  WHERE  a.link_to_cust_trx_line_id = p_line_id
    AND  a.tax_id = b.tax_id
 ORDER BY a.tax_line_no;

 CURSOR uom_class_cur( v_unit_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
 SELECT A.uom_class
   FROM mtl_units_of_measure A, mtl_units_of_measure B
  WHERE A.uom_code = v_unit_code
    AND B.uom_code = p_tax_line_uom_code
    AND A.uom_class = B.uom_class;

 CURSOR  Fetch_Dtls_Cur IS       -- OE Side
  SELECT QUANTITY,price
  FROM   JAI_OPM_SO_PICK_LINES -- JAI_AR_TRX_LINES
  WHERE  Order_id   = p_line_id;

 CURSOR  Fetch_Dtls1_Cur IS       -- AR Side
  SELECT Quantity, Unit_Selling_Price, Unit_Code, Inventory_Item_Id
  FROM   JAI_AR_TRX_LINES
  WHERE  Customer_Trx_Line_Id = p_line_id;

 CURSOR Fetch_Exempt_Cur( AddressId IN NUMBER ) IS      -- OE Side
   SELECT NVL( Exempt, 'N' )
   FROM   JAI_CMN_CUS_ADDRESSES
   WHERE  Customer_Id = p_customer_id
     AND  Address_Id = AddressId;

 CURSOR Fetch_OE_Address_Cur IS
   SELECT  address_id from ra_site_uses_all where site_use_id=
   (select  Ship_To_Site_Use_Id
   FROM    So_Picking_Lines_All
   WHERE   Picking_Line_Id = p_ref_line_id);

 CURSOR Fetch_AR_Address_Cur IS
 SELECT  Address_id
 FROM    Ra_site_uses_all where site_use_id in
 (select ship_to_site_use_id from RA_Customer_Trx_All
 WHERE   Customer_trx_Id in (select customer_trx_id from
 ra_customer_trx_lines_all where customer_trx_line_id = p_ref_line_id));


 CURSOR Chk_Rcd_Cur IS
   SELECT NVL( COUNT( * ), 0 )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Subinventory = p_subinventory
     AND  Receipt_Id = p_receipt_id
     AND  Order_Invoice = 'O';

 CURSOR Chk_Rcd_AR_Cur IS
   SELECT NVL( COUNT( * ), 0 )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Receipt_Id = p_receipt_id
     AND  Order_Invoice = 'I';

 CURSOR Fetch_Totals_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Subinventory = p_subinventory
     AND  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no;

 CURSOR Fetch_Totals_AR_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no;

 CURSOR Fetch_Total_AR_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) ) tax_amount, SUM( NVL( Base_Tax_Amount, 0 ) ) base_tax_amount,
          SUM( NVL( Func_Tax_Amount, 0 ) ) func_tax_amount
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no
     AND  Receipt_ID IS NOT NULL;

-- CURSOR Fetch_Matched_Qty_AR_Cur IS
--   SELECT matched_quantity
--   FROM   JAI_AR_TRX_LINES
--   WHERE  Customer_Trx_Line_Id = p_ref_line_id;

 CURSOR Excise_Duty_Rate_Cur IS
   SELECT rate_per_unit ,PRIMARY_UOM_CODE
   FROM JAI_CMN_RG_23D_TRXS
   WHERE register_id = p_receipt_id;

Cursor C_op_dtl is
  Select order_um1,exchange_rate,item_id
         From op_ordr_dtl
         WHERE  bol_id = p_ref_line_id
      and     bolline_no = p_line_no;


BEGIN

  v_exempt_flag         := jai_constants.no; --Ramananda for File.Sql.35

  IF p_ref_line_id IS NULL THEN
     RAISE_APPLICATION_ERROR( -20120, 'Ref Line Id cannot be NULL' );
  END IF;


  OPEN Excise_Duty_Rate_Cur;
  FETCH Excise_Duty_Rate_Cur into v_excise_duty_rate,v_primary_uom_code;
  CLOSE Excise_Duty_Rate_Cur;

  IF p_order_invoice = 'O' THEN
     Open c_op_dtl;
      Fetch c_op_dtl INTO v_order_um1,v_exchage_rate,v_item_id;
     Close c_op_dtl;
      if    v_order_um1 <> v_primary_uom_code then
            v_item_um_f :=  jai_cmn_utils_pkg.opm_uom_version(v_order_um1, v_primary_uom_code, v_item_id);
     Else
            v_item_um_f  := 1;
     End if;


     OPEN  Chk_Rcd_Cur;
     FETCH Chk_Rcd_Cur INTO v_count;
     CLOSE Chk_Rcd_Cur;

     OPEN  Fetch_Dtls_Cur;
     FETCH Fetch_Dtls_Cur INTO v_original_quantity,v_selling_price;
     CLOSE Fetch_Dtls_Cur;

     IF nvl(p_line_quantity,0) <> 0 THEN
       v_original_quantity := p_line_quantity;
     END IF;

--     v_excise_duty_rate := ((nvl(v_excise_duty_rate,0) * v_exchage_rate) * v_original_quantity/v_item_um_f);
     v_excise_duty_rate := ((nvl(v_excise_duty_rate,0) * 1) * v_original_quantity/v_item_um_f);


     OPEN  Fetch_OE_Address_Cur;
     FETCH Fetch_OE_Address_Cur INTO v_address_id;
     CLOSE Fetch_OE_Address_Cur;

     OPEN  Fetch_Exempt_Cur( v_address_id );
     FETCH Fetch_Exempt_Cur INTO v_exempt_flag;
     CLOSE Fetch_Exempt_Cur;

     FOR rec in oe_tax_cur  LOOP
       IF v_count = 0 THEN
          INSERT INTO JAI_CMN_MATCH_TAXES(MATCH_TAX_ID, REF_LINE_ID,
                                                   SUBINVENTORY,
                                                   TAX_LINE_NO,
                                                   PRECEDENCE_1,
                                                   PRECEDENCE_2,
                                                   PRECEDENCE_3,
                                                   PRECEDENCE_4,
                                                   PRECEDENCE_5,
                                                   PRECEDENCE_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                                   PRECEDENCE_7,
                                                   PRECEDENCE_8,
                                                   PRECEDENCE_9,
                                                   PRECEDENCE_10,
               TAX_ID,
                                                   TAX_RATE,
                                                   QTY_RATE,
                                                   UOM,
                                                   TAX_AMOUNT,
                                                   BASE_TAX_AMOUNT,
                                                   FUNC_TAX_AMOUNT,
                                                   TOTAL_TAX_AMOUNT,
                                                   CREATION_DATE,
                                                   CREATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   LAST_UPDATED_BY,
                                                   RECEIPT_ID,
                                                   ORDER_INVOICE  )


          VALUES ( JAI_CMN_MATCH_TAXES_S.nextval,  p_ref_line_id,
                   p_subinventory,
                   z.lno,
                   rec.p_1,
                   rec.p_2,
                   rec.p_3,
                   rec.p_4,
                   rec.p_5,
                   rec.p_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                   rec.p_7,
                   rec.p_8,
                   rec.p_9,
                   rec.p_10,
                   rec.tax_id,
                   rec.tax_rate,
                   rec.qty_rate,
                   rec.uom,
                   0,
                   0,
                   0,
                   0,
                   SYSDATE,
                   UID,
                   SYSDATE,
                   UID,
                   UID,
                   p_receipt_id,
                   p_order_invoice );
       END IF;
      Tax_Rate_Tab(rec.lno) := nvl(rec.Tax_Rate,0);
       IF ( excise_flag_set = FALSE AND rec.tax_type_val = 1 ) OR ( rec.tax_type_val <> 1 ) THEN -- OR rec.tax_type_val <> 1 THEN
          P1(rec.lno) := nvl(rec.p_1,-1);
          P2(rec.lno) := nvl(rec.p_2,-1);
          P3(rec.lno) := nvl(rec.p_3,-1);
          P4(rec.lno) := nvl(rec.p_4,-1);
          P5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    P6(rec.lno) := nvl(rec.p_6,-1);
          P7(rec.lno) := nvl(rec.p_7,-1);
          P8(rec.lno) := nvl(rec.p_8,-1);
          P9(rec.lno) := nvl(rec.p_9,-1);
          P10(rec.lno) := nvl(rec.p_10,-1);
-- END BUG 5228046


          IF rec.tax_type_val = 1 THEN
             tax_rate_tab(rec.lno) :=  -1;
             P1(rec.lno) := -1;
             P2(rec.lno) := -1;
             P3(rec.lno) := -1;
             P4(rec.lno) := -1;
             P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
       P6(rec.lno) := -1;
             P7(rec.lno) := -1;
             P8(rec.lno) := -1;
             P9(rec.lno) := -1;
             P10(rec.lno) := -1;
-- END BUG 5228046
       Tax_Amt_Tab(rec.lno)  := v_excise_duty_rate;
             tax_target_tab(rec.lno) := v_excise_duty_rate;
          END IF;
       ELSIF excise_flag_set AND rec.tax_type_val = 1 THEN
         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
   P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;
-- END BUG 5228046
         tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;
      END IF;

      IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

         P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;

-- END BUG 5228046

   tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;

      END IF;
      Rounding_factor_tab(rec.lno) := rec.rnd;
      Tax_Type_Tab(rec.lno) := rec.tax_type_val;
      IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 THEN
         tax_rate_tab(rec.lno) :=  -1;

         -- Start of addition by Srihari and Gaurav on 11-JUL-2000

         IF rec.tax_type_val = 1
         THEN
             Tax_Amt_Tab(rec.lno)  := v_excise_duty_rate;
             tax_target_tab(rec.lno) := v_excise_duty_rate;
         ELSE

         -- End of addition by Srihari and Gaurav on 11-JUL-2000

           Tax_Amt_Tab(rec.lno)  := rec.tax_amount;
           tax_target_tab(rec.lno) := rec.tax_amount;

         END IF;

      ELSE
         IF rec.tax_type_val <> 1 THEN
            Tax_Amt_Tab(rec.lno)  := 0;
         END IF;
      END IF;


         Code modified by aiyer for the bug 3433634 .
         Set the end_date_tab to 1 whenever valid_date is null or has an end date greater than or equal to
         sysdate.
         Only if the end date is not null and less than sysdate, set the end_date_tab variable to zero.

      IF rec.valid_date >= to_char(sysdate,'DD-MON-YYYY') THEN
        End_Date_Tab(rec.lno) := 1;
      ELSE
        End_Date_Tab(rec.lno) := 0;
      END IF;

      row_count := row_count + 1;

      IF tax_rate_tab(rec.lno) = 0 THEN
         FOR uom_cls IN uom_class_cur(v_unit_code, rec.uom) LOOP
          INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, v_inventory_item_id, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN
             INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, 0, v_conversion_rate);
             IF nvl(v_conversion_rate, 0) <= 0  THEN
                v_conversion_rate := 0;
             END IF;
          END IF;
            IF ( excise_flag_set ) AND ( rec.tax_type_val = 1 ) THEN
               tax_amt_tab(rec.lno) := 0;
            ELSE
              tax_amt_tab(rec.lno) := ROUND( nvl(rec.qty_rate * v_conversion_rate, 0) * v_original_quantity, rounding_factor_tab(rec.lno) );
            END IF;
            IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
              tax_amt_tab( rec.lno ) := 0;
            END IF;
            tax_rate_tab( rec.lno ) := -1;
            tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
         END LOOP;
      END IF;
      IF rec.tax_type_val = 1 THEN
         excise_flag_set := TRUE;
      END IF;
     END LOOP;

  END IF;

bsln_amt := v_selling_price * v_original_quantity;
--v_original_quantity;
--bsln_amt := 90;


  FOR I in 1..row_count
  LOOP
    IF p1(I) < I and p1(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
    ELSIF p1(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p2(I) < I and p2(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
    ELSIF p2(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p3(I) < I and p3(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
    ELSIF p3(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p4(I) < I and p4(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
    ELSIF p4(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p5(I) < I and p5(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
    ELSIF p5(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) < I and p6(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
    ELSIF p6(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p7(I) < I and p7(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
    ELSIF p7(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p8(I) < I and p8(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
    ELSIF p8(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p9(I) < I and p9(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
    ELSIF p9(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p10(I) < I and p10(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
    ELSIF p10(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;

    -- END BUG 5228046

     IF tax_rate_tab(I) <> -1 THEN
       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       IF END_date_tab(I) = 0 then
          tax_amt_tab(I) := 0;
       ELSIF END_date_tab(I) = 1 then
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
       END IF;
       -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
     END IF;
    vamt      := 0;
    v_tax_amt := 0;
   END LOOP;
  FOR I in 1..row_count
  LOOP
    IF p1(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
    END IF;
    IF p2(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
    END IF;
    IF p3(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
    END IF;
    IF p4(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
    END IF;
    IF p5(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
    END IF;
    IF p7(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
    END IF;
    IF p8(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
    END IF;
    IF p9(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
    END IF;
    IF p10(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
    END IF;

-- END BUG 5228046

     IF tax_rate_tab(I) <> -1 THEN
       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       IF END_date_tab(I) = 0 then
          tax_amt_tab(I) := 0;
       ELSIF END_date_tab(I) = 1 then
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
       END IF;
        -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
     END IF;
    vamt      := 0;
    v_tax_amt := 0;
  END LOOP;

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;
    FOR i IN 1 .. row_count LOOP
      IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0 AND tax_rate_tab( i ) <> -1 THEN
         v_amt := bsln_amt;

  IF p1( i ) <> -1 THEN
        IF p1( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p1( I ) );
        ELSIF p1(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
       END IF;
        IF p2( i ) <> -1 THEN
        IF p2( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p2( I ) );
        ELSIF p2(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
       END IF;
         IF p3( i ) <> -1 THEN
        IF p3( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p3( I ) );
        ELSIF p3(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;
         IF p4( i ) <> -1 THEN
        IF p4( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p4( i ) );
        ELSIF p4(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;
         IF p5( i ) <> -1 THEN
        IF p5( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p5( i ) );
        ELSIF p5(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  IF p6( i ) <> -1 THEN
        IF p6( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p6( I ) );
        ELSIF p6(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
       END IF;
        IF p7( i ) <> -1 THEN
        IF p7( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p7( I ) );
        ELSIF p7(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
       END IF;
         IF p8( i ) <> -1 THEN
        IF p8( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p8( I ) );
        ELSIF p8(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;
         IF p9( i ) <> -1 THEN
        IF p9( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p9( i ) );
        ELSIF p9(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;
         IF p10( i ) <> -1 THEN
        IF p10( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p10( i ) );
        ELSIF p10(i) = 0 THEN
           vamt := vamt + v_amt;
        END IF;
      END IF;

-- END BUG 5228046

       tax_target_tab(I) := vamt;
       IF counter = max_iter THEN
--         v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), rounding_factor_tab(I) );
           v_tax_amt := ( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)));


       ELSE

           v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));

       END IF;
     tax_amt_tab( I ) := NVL( v_tax_amt, 0 );

      ELSIF tax_rate_tab( i ) = -1 AND End_Date_Tab(I) <> 0  THEN
           NULL;
      ELSE
        tax_amt_tab(I) := 0;
        tax_target_tab(I) := 0;
      END IF;

      IF counter = max_iter THEN
       IF END_date_tab(I) = 0 THEN
           tax_amt_tab(I) := 0;
       END IF;
      END IF;

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
    END LOOP;
  END LOOP;

  FOR i IN 1 .. row_count LOOP
    IF p_order_invoice = 'O' THEN
      OPEN  Fetch_Totals_Cur( i );
      FETCH Fetch_Totals_Cur INTO v_cum_amount;
      CLOSE Fetch_Totals_Cur;
      IF p_line_quantity = 0 THEN
        DELETE JAI_CMN_MATCH_TAXES
         WHERE Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;
      ELSE
        UPDATE JAI_CMN_MATCH_TAXES
          SET  Tax_Amount = tax_amt_tab(i),
               Base_Tax_Amount = tax_target_tab(i),
               Func_Tax_Amount = tax_amt_tab(i) ,
--* NVL( p_curr_conv_factor, 1 ),
               Total_Tax_Amount = v_cum_amount
        WHERE  Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;


        update JAI_OPM_SO_PICK_TAXES
          Set  tax_amount = tax_amt_tab(i)
          Where bol_id = p_ref_line_id
          and  bolline_no = p_line_no
        AND  Tax_Line_No = i;


      END IF;
     -- END IF;
     -- OPEN  Fetch_Matched_Qty_AR_Cur;
     -- FETCH Fetch_Matched_Qty_AR_Cur Into v_matched_quantity;
     -- CLOSE Fetch_Matched_Qty_AR_Cur;

      IF p_line_quantity <> 0 THEN
        FOR Rec IN Fetch_Total_AR_Cur( i ) LOOP
          UPDATE  JAI_AR_TRX_TAX_LINES
             SET  Tax_Amount = rec.tax_amount,
                  Base_Tax_Amount = rec.base_tax_amount,
                  Func_Tax_Amount = rec.func_tax_amount
           WHERE  link_to_cust_trx_line_id = p_ref_line_id
             AND  Tax_Line_No = i;
        END LOOP;
      ELSE
        UPDATE  JAI_AR_TRX_TAX_LINES
           SET  Tax_Amount = tax_amt_tab(i),
                Base_Tax_Amount = tax_target_tab(i),
                Func_Tax_Amount = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 )
         WHERE  link_to_cust_trx_line_id = p_ref_line_id
           AND  Tax_Line_No = i;
      END IF;
    END IF;
  END LOOP;

END opm_default_taxes;
*/

PROCEDURE ar_default_taxes( p_ref_line_id IN NUMBER,
                                             p_customer_id IN NUMBER,
                                             p_link_to_cust_trx_line_id NUMBER,
                                             p_curr_conv_factor IN NUMBER,
                                             p_receipt_id  IN NUMBER,
                                             p_qty IN NUMBER )

IS

  v_qty             NUMBER; --  := p_qty; --Ramananda for File.Sql.35
  v_n_tax_line_no   NUMBER;
  v_tax_line_no     NUMBER := 0;
  v_matched_quantity  NUMBER   := 0;
  v_last_update_date    Date; --  := Sysdate; --Ramananda for File.Sql.35
  v_shipment_line_id   Number; --added by Vijay on 9-Oct-2001 for Tar# 9445972.700

/*  CURSOR Fetch_Matched_Qty_AR_Cur IS
   SELECT matched_quantity
   FROM   JAI_AR_TRX_LINES
   WHERE  Customer_Trx_Line_Id = p_ref_line_id;*/

  CURSOR Fetch_AR_Line_Info_Cur IS
   SELECT nvl(quantity * nvl(assessable_value, line_amount),0) assessable_value, line_amount, unit_code, inventory_item_id, quantity,
          tax_category_id, customer_trx_id, creation_date, created_by, last_updated_by, last_update_login
   FROM   JAI_AR_TRX_LINES
   WHERE  Customer_Trx_Line_Id = p_ref_line_id;

  CURSOR Chk_New_Added_Tax_Cur IS
    SELECT NVL( MAX( Tax_Line_No ), 0 )
    FROM   JAI_AR_TRX_TAX_LINES
    WHERE  Link_To_Cust_Trx_Line_Id = p_link_to_cust_trx_line_id;

  CURSOR Chk_Tax_Count_Cur IS
    SELECT NVL( MAX( Tax_Line_No ), 0 )
    FROM   JAI_CMN_MATCH_TAXES
    WHERE  Ref_Line_Id = p_ref_line_id;

  CURSOR Fetch_New_Taxes_Cur IS
    SELECT *
    FROM   JAI_AR_TRX_TAX_LINES
    WHERE  Link_To_Cust_Trx_Line_Id = p_link_to_cust_trx_line_id
      AND  Tax_Line_No > nvl(v_tax_line_no,0)
   ORDER BY Tax_Line_No;

--Start addition by Vijay on 09-Oct-2001 for TAR# 9445972.700
--Added Cursor to fetch taxes from Receipts

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

  CURSOR Get_Receipt_taxes IS  SELECT a.tax_id tax_id_po, a.tax_line_no tax_line_no_po, c.tax_id , c.tax_line_no,
       a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
       a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8, a.precedence_9 p_9, a.precedence_10 p_10,
       c.qty_rate, c.tax_rate, c.tax_amount, c.uom
    FROM JAI_PO_TAXES a, JAI_CMN_TAXES_ALL b, JAI_RCV_LINE_TAXES c
    WHERE   c.tax_line_no > nvl(v_tax_line_no,0)
    AND     a.tax_id = b.tax_id
    AND     c.tax_id = b.tax_id
    AND     (c.shipment_line_id,a.line_location_id) = (SELECT shipment_line_id,po_line_location_id
                                 FROM rcv_transactions
                                WHERE transaction_id = (select receipt_ref
                                                        from JAI_CMN_RG_23D_TRXS
                                                        where register_id = p_receipt_id))
   ORDER BY c.tax_line_no;
--End addition by Vijay on 09-Oct-2001 for TAR# 9445972.700

  BEGIN



/*------------------------------------------------------------------------------------------
 FILENAME: Ja_In_Rg23_D_AR_p.sql

 CHANGE HISTORY:
S.No      Date          Author and Details
1.        09/10/2001    A.Vijay Kumar Version#115.0
                        Added a cursor Get_Receipt_taxes to fetch taxes from Receipts
                        When Manual Invoice is matched against a Receipt

2.        10/01/2005    brathod for Bug#4111609 Version#115.1
                        Commented insert into JAI_CMN_MATCH_TAXES
                        since it is not required
                        base bug# 4146708 creates objects

--------------------------------------------------------------------------------------------*/
  v_qty               := p_qty; --Ramananda for File.Sql.35
  v_last_update_date  := Sysdate; --Ramananda for File.Sql.35

  OPEN  Chk_New_Added_Tax_Cur;
  FETCH Chk_New_Added_Tax_Cur INTO v_n_tax_line_no;
  CLOSE Chk_New_Added_Tax_Cur;

  OPEN  Chk_Tax_Count_Cur;
  FETCH Chk_Tax_Count_Cur INTO v_tax_line_no;
  CLOSE Chk_Tax_Count_Cur;

--Start addition by Vijay on 09-Oct-2001 for TAR# 9445972.700
/*  OPEN  Get_shipment_line_id;
  FETCH Get_shipment_line_id INTO v_shipment_line_id;
  CLOSE Get_Shipment_line_id;*/


  -- FOR rec IN Fetch_Rcpt_Dtls_Cur LOOP
--     IF nvl(v_tax_line_no,0) <> v_n_tax_line_no THEN
--        FOR rec1 IN Fetch_New_Taxes_Cur LOOP --commented by Vijay on 09-Oct-2001 for TAR# 9445972.700
        FOR rec1 IN Get_Receipt_taxes --Added by Vijay on 09-Oct-2001 for TAR# 9445972.700
        LOOP
         IF nvl(v_tax_line_no,0) <> rec1.tax_line_no THEN

         /* bug# 4111609 insertion not required. So code commented */

         /*
         INSERT INTO JAI_CMN_MATCH_TAXES(MATCH_TAX_ID, REF_LINE_ID,
                                                   SUBINVENTORY,
                                                   TAX_LINE_NO,
                                                   PRECEDENCE_1,
                                                   PRECEDENCE_2,
                                                   PRECEDENCE_3,
                                                   PRECEDENCE_4,
                                                   PRECEDENCE_5,
                                                   PRECEDENCE_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                                   PRECEDENCE_7,
                                                   PRECEDENCE_8,
                                                   PRECEDENCE_9,
                                                   PRECEDENCE_10,
               TAX_ID,
                                                   TAX_RATE,
                                                   QTY_RATE,
                                                   UOM,
                                                   TAX_AMOUNT,
                                                   BASE_TAX_AMOUNT,
                                                   FUNC_TAX_AMOUNT,
                                                   TOTAL_TAX_AMOUNT,
                                                   CREATION_DATE,
                                                   CREATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   LAST_UPDATED_BY,
                                                   RECEIPT_ID,
                                                   ORDER_INVOICE  )
          VALUES ( JAI_CMN_MATCH_TAXES_S.nextval,  p_ref_line_id,
                   NULL,
                   rec1.tax_line_no,
                   rec1.p_1,
                   rec1.p_2,
                   rec1.p_3,
                   rec1.p_4,
                   rec1.p_5,
                   rec1.p_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                   rec1.p_7,
                   rec1.p_8,
                   rec1.p_9,
                   rec1.p_10,
       rec1.tax_id,
                   rec1.tax_rate,
                   rec1.qty_rate,
                   rec1.uom,
                   0,
                   0,
                   0,
                   0,
                   SYSDATE,
                   UID,
                   SYSDATE,
                   UID,
                   UID,
                   p_receipt_id,
                   'I' );
      */

      /* end bug#4111609 */
         null;
         END IF;
        END LOOP;
--     END IF;
  /* OPEN  Fetch_Matched_Qty_AR_Cur;
     FETCH Fetch_Matched_Qty_AR_Cur Into v_matched_quantity;
     CLOSE Fetch_Matched_Qty_AR_Cur;
 */
  --   IF v_matched_quantity <> 0 THEN
       if p_qty <> 0 then
            jai_cmn_rcv_matching_pkg.om_default_taxes( NULL,
                           p_customer_id,
                           p_ref_line_id,
                           p_receipt_id,
                           p_link_to_cust_trx_line_id,
                           p_qty,
                           p_curr_conv_factor,
                           'I' );
    ELSE
      DELETE JAI_CMN_MATCH_TAXES
       WHERE Ref_Line_Id = p_ref_line_id
         AND  receipt_id = p_receipt_id;

      FOR Rec IN Fetch_AR_Line_Info_Cur LOOP
        jai_ar_utils_pkg.recalculate_tax('AR_LINES_UPDATE' , rec.tax_category_id , rec.customer_trx_id , p_ref_line_id,
        rec.assessable_value , rec.line_amount , 1, rec.inventory_item_id ,rec.quantity,
        rec.unit_code , NULL , NULL ,rec.creation_date , rec.created_by ,
        v_last_update_date , rec.last_updated_by , rec.last_update_login );
      END LOOP;
    END IF;
      --END LOOP;

END ar_default_taxes;

PROCEDURE om_default_taxes(
    p_subinventory IN VARCHAR2,
    p_customer_id IN NUMBER,
    p_ref_line_id IN NUMBER,
    p_receipt_id IN NUMBER,
    p_line_id NUMBER,  -- For OE it is Line ID, for AR it is Link to cust trx line id
    p_line_quantity IN NUMBER,
    p_curr_conv_factor IN NUMBER,
    p_order_invoice IN VARCHAR2
) IS

  TYPE Num_Tab IS TABLE OF NUMBER(25,3) INDEX BY BINARY_INTEGER;
  TYPE Tax_Amt_Num_Tab IS TABLE OF NUMBER(25,4) INDEX BY BINARY_INTEGER;
  TYPE Flag_Tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER; /* Added for bug 5091874 */

  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rcv_matching_pkg.om_default_taxes'; /* Added by Ramananda for bug#4407165 */

  --Add by Kevin Cheng for inclusive tax Dec 12, 2007
  ---------------------------------------------------
  TYPE CHAR_TAB IS TABLE OF VARCHAR2(10)
  INDEX BY BINARY_INTEGER;

  lt_adhoc_tax_tab             CHAR_TAB;
  lt_inclu_tax_tab             CHAR_TAB;
  lt_tax_rate_per_rupee        NUM_TAB;
  lt_cumul_tax_rate_per_rupee  NUM_TAB;
  lt_tax_rate_zero_tab         NUM_TAB;
  lt_tax_amt_rate_tax_tab      TAX_AMT_NUM_TAB;
  lt_tax_amt_non_rate_tab      TAX_AMT_NUM_TAB;
  lt_base_tax_amt_tab          TAX_AMT_NUM_TAB;
  base_tax_amount_nr_tab         tax_amt_num_tab;--bug#9794835
  lt_func_tax_amt_tab          TAX_AMT_NUM_TAB;
  lv_uom_code                  VARCHAR2(10) := 'EA';
  lv_register_code             VARCHAR2(20);
  ln_inventory_item_id         NUMBER;
  ln_exclusive_price           NUMBER;
  ln_total_non_rate_tax        NUMBER := 0;
  ln_total_inclusive_factor    NUMBER;
  ln_bsln_amt_nr               NUMBER :=0;
  ln_currency_conv_factor      NUMBER;
  ln_tax_amt_nr                NUMBER(38,10) := 0;
  ln_func_tax_amt              NUMBER(38,10) := 0;
  ln_vamt_nr                   NUMBER(38,10) := 0;
  ln_excise_jb                 NUMBER;
  ln_total_tax_per_rupee       NUMBER;
  ln_assessable_value_tmp      NUMBER;
  ln_vat_assessable_value_tmp  NUMBER;
  ln_assessable_value_tot      NUMBER;
  ln_vat_assessable_value_tot  NUMBER;
  ln_vat_reversal_value_tmp  NUMBER;   -- bug 8887871
  ln_vat_reversal_value_tot  NUMBER;     --bug 8887871
  ln_line_amount               NUMBER;
  ---------------------------------------------------

  -- added by Vijay Shankar for Bug# 3781299
  lv_excise_cess_code   VARCHAR2(25); -- := 'EXCISE_EDUCATION_CESS'; --Ramananda for File.Sql.35
  lv_sh_excise_cess_code VARCHAR2(25) := JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS;/*Bug 5989740 bduvarag*/
  lv_cvd_cess_code        VARCHAR2(25); --  := 'CVD_EDUCATION_CESS'; --Ramananda for File.Sql.35
  lv_sh_cvd_cess_code        VARCHAR2(25) := JAI_CONSTANTS.TAX_TYPE_SH_CVD_EDU_CESS;/*Bug 5989740 bduvarag*/
  ln_cess_check         NUMBER := -1;
  ln_sh_cess_check      NUMBER := -1;/*Bug 5989740 bduvarag*/
  ln_transaction_id     NUMBER(15);

  p1        num_tab;
  p2        num_tab;
  p3        num_tab;
  p4        num_tab;
  p5        num_tab;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6        num_tab;
  p7        num_tab;
  p8        num_tab;
  p9        num_tab;
  p10        num_tab;

-- END BUG 5228046

  tax_rate_tab      num_tab;
  tax_type_tab      num_tab;
  end_date_tab      num_tab;
  tax_amt_tab       tax_amt_num_tab;
  tax_target_tab    tax_amt_num_tab;
  rounding_factor_tab   tax_amt_num_tab;
  adhoc_flag_tab        Flag_tab ;  /* Added  bug 5091874 */

  v_exempt_flag         VARCHAR2(2); --:= 'N'; --Ramananda for File.Sql.35
  v_address_id          NUMBER;
  i                     NUMBER;
  excise_flag_set       BOOLEAN := FALSE;
  v_inventory_item_id   NUMBER;
  v_unit_code           VARCHAR2(15);
  v_selling_price       NUMBER;
  v_amt     NUMBER;
  v_cum_amount          NUMBER;
  bsln_amt      NUMBER;
  row_count     NUMBER    := 0;
  v_tax_amt     NUMBER(14,4)  := 0;
  vamt          NUMBER(14,4)  := 0;
  v_conversion_rate   NUMBER;
  counter     NUMBER;
  max_iter      NUMBER    := 10;
  conv_rate     NUMBER;
  v_count               NUMBER    := 0;
  v_original_quantity   NUMBER    := 0;
  v_matched_quantity    NUMBER    := 0;
  v_excise_duty_rate    NUMBER;
  ln_cess_duty_rate     NUMBER := 0;
  ln_sh_cess_duty_rate     NUMBER := 0;/*Bug 5989740 bduvarag*/
  v_e_s                 varchar2(10);
   ln_vat_assessable_value   NUMBER ;

  CURSOR oe_tax_cur(p_excise_cess_cnt IN NUMBER , p_sh_excise_cess_cnt IN number ) IS/*Bug 5989740 bduvarag*/        ---- OE Side
  SELECT
         a.tax_id       ,
     a.tax_line_no  lno   ,
     a.precedence_1 p_1   ,
     a.precedence_2 p_2   ,
     a.precedence_3 p_3   ,
     a.precedence_4 p_4   ,
     a.precedence_5 p_5   ,
     a.precedence_6 p_6   , -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
     a.precedence_7 p_7   ,
     a.precedence_8 p_8   ,
     a.precedence_9 p_9   ,
     a.precedence_10 p_10   ,
     a.qty_rate       ,
       -- Vijay Shankar for Bug# 3781299
     decode(b.tax_type, lv_excise_cess_code, decode(p_excise_cess_cnt, 0, 0, a.tax_rate),
                        lv_sh_excise_cess_code, decode(p_sh_excise_cess_cnt, 0, 0, a.tax_rate),   --Added by sacsethi for Bug no 5907436
           a.tax_rate) tax_rate,  -- a.tax_rate/*Bug 5989740 bduvarag*/
     decode(b.tax_type, lv_excise_cess_code, decode(p_excise_cess_cnt, 0, 0, a.tax_amount),
      lv_sh_excise_cess_code, decode(p_sh_excise_cess_cnt, 0, 0, a.tax_amount),  --Added by sacsethi for Bug no 5907436
     a.tax_amount) tax_amount,    -- a.tax_amount     ,/*Bug 5989740 bduvarag*/
     a.uom          ,
     b.end_date   valid_date  ,
     decode(upper(b.tax_type),'EXCISE',       1,
                              'ADDL. EXCISE', 1,
                              'OTHER EXCISE', 1,
                              'TDS', 2,
                              lv_excise_cess_code,3,   -- bug#4111609 excise cess
                              lv_cvd_cess_code,3,      -- bug#4111609 cvd    cess
                            lv_sh_excise_cess_code,4, --added by sacsethi for budget07 enhancement
            lv_sh_cvd_cess_code,4, --added by sacsethi for budget07 enhancement
                            /* Added  for bug#8887871 */
                              (SELECT jrttv.tax_type
                               FROM  jai_regime_tax_types_v jrttv
                               WHERE jrttv.tax_type    = upper(b.tax_type)
                               AND   jrttv.regime_code = jai_constants.vat_regime), 5,
                               'VAT REVERSAL', 6, 0) tax_type_val,
       b.mod_cr_Percentage  ,
     b.vendor_id      ,
     b.tax_type       ,
     NVL( b.rounding_factor, 0 ) rnd ,
     b.adhoc_flag /* Added  bug 5091874 */
     , b.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 12, 2007
   FROM
    JAI_OM_OE_SO_TAXES  a ,
    JAI_CMN_TAXES_ALL   b
  WHERE
    a.line_id = p_line_id AND
    a.tax_id  = b.tax_id
 ORDER BY
    a.tax_line_no;

-- the following cursor un-commented by sriram - bug 3179379 - 12/11/2003

CURSOR interorg_xfer_tax_cur IS        ---- Interorg XFER bug 6030615
 SELECT
        a.tax_id       ,
        a.tax_line_no  lno   ,
        a.precedence_1 p_1   ,
        a.precedence_2 p_2   ,
        a.precedence_3 p_3   ,
        a.precedence_4 p_4   ,
        a.precedence_5 p_5   ,
        a.precedence_6 p_6   ,
        a.precedence_7 p_7   ,
        a.precedence_8 p_8   ,
        a.precedence_9 p_9   ,
        a.precedence_10 p_10   ,
        a.qty_rate       ,
        a.tax_rate tax_rate,
        a.tax_amt  tax_amount   ,
        a.tax_amt  func_tax_amount,
        c.transaction_uom uom,
        b.end_date   valid_date  ,
        decode(upper(b.tax_type),'EXCISE',       1,
                                   'ADDL. EXCISE', 1,
                                   'OTHER EXCISE', 1,
                                   'TDS', 2,
                                   lv_excise_cess_code,3,
                                   lv_cvd_cess_code,3,
                                  lv_sh_excise_cess_code,4, --added by sacsethi for budget07 enhancement
                                   lv_sh_cvd_cess_code,4, --added by sacsethi for budget07 enhancement
                                     (SELECT jrttv.tax_type
                                 FROM  jai_regime_tax_types_v jrttv
                                 WHERE jrttv.tax_type    = upper(b.tax_type)
                                 AND   jrttv.regime_code = jai_constants.vat_regime), 5,
                                 'VAT REVERSAL', 6, 0) tax_type_val,
                                           b.mod_cr_Percentage  ,
        b.vendor_id      ,
        b.tax_type       ,
        NVL( b.rounding_factor, 0 ) rnd ,
        b.adhoc_flag
        , b.inclusive_tax_flag --Add by Kevin for inclusive tax Dec 12, 2007
      FROM
       jai_cmn_document_taxes  a ,
       jai_cmn_taxes_all       b ,
       jai_mtl_trxs            c       /* jai_mtl_trxs_temp is modified as jai_mtl_trxs by Vijay for ReArch. bug#2942973 */
     WHERE
       a.source_doc_line_id = p_line_id AND
       a.tax_id  = b.tax_id  AND
       a.source_doc_type = 'INTERORG_XFER' AND
       a.source_doc_line_id = c.transaction_temp_id
    ORDER BY
       a.tax_line_no;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  CURSOR ar_tax_cur(p_excise_cess_cnt IN NUMBER, p_sh_excise_cess_cnt IN NUMBER) IS /*Bug 5989740 bduvarag*/    ---- AR Side
  SELECT a.tax_id, a.tax_line_no lno,
     a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
     a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8, a.precedence_9 p_9, a.precedence_10 p_10,
     a.qty_rate,
     -- Vijay Shankar for Bug# 3781299
     decode(b.tax_type, lv_excise_cess_code, decode(p_excise_cess_cnt, 0, 0, a.tax_rate),
      lv_sh_excise_cess_code, decode(p_sh_excise_cess_cnt, 0, 0, a.tax_rate),
      a.tax_rate) tax_rate,  -- a.tax_rate
     decode(b.tax_type, lv_excise_cess_code, decode(p_excise_cess_cnt, 0, 0, a.tax_amount), /*Bug 5989740 bduvarag*/
      lv_sh_excise_cess_code, decode(p_sh_excise_cess_cnt, 0, 0, a.tax_amount), /*Bug 5989740 bduvarag*/
      a.tax_amount) tax_amount,    -- a.tax_amount     ,
      a.uom, b.end_date valid_date,
     decode(upper(b.tax_type),'EXCISE',       1,
                                'ADDL. EXCISE', 1,
                                'OTHER EXCISE', 1,
                                'TDS', 2,
                                lv_excise_cess_code,3,    -- bug#4111609 excise cess
                                lv_cvd_cess_code,3,       -- bug#4111609 cvd    cess
        lv_sh_excise_cess_code,4, /*Bug 5989740 bduvarag*/
        lv_sh_cvd_cess_code,4,
                             /* Added  for bug#8887871 */
                              (SELECT jrttv.tax_type
                               FROM  jai_regime_tax_types_v jrttv
                               WHERE jrttv.tax_type    = upper(b.tax_type)
                               AND   jrttv.regime_code = jai_constants.vat_regime), 5,
                               'VAT REVERSAL', 6, 0) tax_type_val,
     b.mod_cr_Percentage, b.vendor_id, b.tax_type, NVL( b.rounding_factor, 0 ) rnd, b.adhoc_flag /* Added for bug 5091874*/
     , b.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 12, 2007
   FROM  JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
  WHERE  a.link_to_cust_trx_line_id = p_line_id
    AND  a.tax_id = b.tax_id
 ORDER BY a.tax_line_no;

 CURSOR uom_class_cur( v_unit_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
 SELECT A.uom_class
   FROM mtl_units_of_measure A, mtl_units_of_measure B
  WHERE A.uom_code = v_unit_code
    AND B.uom_code = p_tax_line_uom_code
    AND A.uom_class = B.uom_class;

 CURSOR  Fetch_Dtls_Cur IS       -- OE Side
  SELECT
         decode(nvl(quantity,0),0,1,quantity) ,
     selling_Price                 ,
     unit_code                     ,
     inventory_item_id
     , nvl(line_amount, 0) line_amount --Add by Kevin Cheng for inclusive tax Dec 12, 2007
     , nvl(assessable_value,0)*nvl(quantity,0) assessable_value --Add by Kevin Cheng for inclusive tax Dec 12, 2007
     , nvl(vat_assessable_value,0) vat_assessable_vale --Add by Kevin Cheng for inclusive tax Dec 12, 2007
     , nvl(vat_reversal_price, 0) vat_reversal_price   --added for bug#8887871
  FROM
         JAI_OM_OE_SO_LINES
  WHERE  line_id = p_line_id;

 CURSOR  Fetch_Dtls1_Cur IS       -- AR Side
  SELECT Quantity, Unit_Selling_Price, Unit_Code, Inventory_Item_Id
  , nvl(line_amount, 0) line_amount --Add by Kevin Cheng for inclusive tax Dec 12, 2007
  , nvl(assessable_value,0)*nvl(quantity,0) assessable_value --Add by Kevin Cheng for inclusive tax Dec 12, 2007
  , nvl(vat_assessable_value,0) vat_assessable_vale --Add by Kevin Cheng for inclusive tax Dec 12, 2007
  ,  nvl(vat_reversal_price, 0) vat_reversal_price   --added for bug#8887871
  FROM   JAI_AR_TRX_LINES
  WHERE  Customer_Trx_Line_Id = p_line_id;

   CURSOR  Fetch_Dtls_xfer_Cur IS       -- Inter Org XFER Side 6030615
   /* SELECT transaction_Quantity quantity, Selling_Price unit_Selling_price , uom_code Unit_Code,  Inventory_Item_Id */
    SELECT decode(quantity,0,1,quantity), selling_price unit_Selling_price , transaction_uom Unit_Code, Inventory_Item_Id, vat_assessable_value
    , nvl(selling_price,0)*nvl(quantity,0) line_amount --Add by Kevin Cheng for inclusive tax Dec 12, 2007
    , nvl(assessable_value,0) assessable_value --Add by Kevin Cheng for inclusive tax Dec 12, 2007
    FROM   jai_mtl_trxs /* jai_mtl_trxs_temp is modified as jai_mtl_trxs by Vijay for ReArch. bug#2942973 */
    WHERE  transaction_temp_id = p_line_id;

 CURSOR Fetch_Exempt_Cur( AddressId IN NUMBER ) IS      -- OE Side
   SELECT NVL( Exempt, 'N' )
   FROM   JAI_CMN_CUS_ADDRESSES
   WHERE  Customer_Id = p_customer_id
     AND  Address_Id = AddressId;

  CURSOR Fetch_OE_Address_Cur IS
   SELECT  cust_acct_site_id address_id
   from hz_cust_site_uses_all where site_use_id=
   (select  SHIP_TO_LOCATION_ID
   FROM    wsh_delivery_details
   WHERE   delivery_detail_id = p_ref_line_id);

 CURSOR Fetch_AR_Address_Cur IS
 SELECT  cust_acct_site_id address_id
 FROM    hz_cust_site_uses_all where site_use_id in
 (select ship_to_site_use_id from RA_Customer_Trx_All
 WHERE   Customer_trx_Id in (select customer_trx_id from
 ra_customer_trx_lines_all where customer_trx_line_id = p_ref_line_id));


 CURSOR Chk_Rcd_Cur IS
   SELECT NVL( COUNT( * ), 0 )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Subinventory = p_subinventory
     AND  Receipt_Id = p_receipt_id
     AND  Order_Invoice = 'O';

 CURSOR Chk_Rcd_AR_Cur IS
   SELECT NVL( COUNT( * ), 0 )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Receipt_Id = p_receipt_id
     AND  Order_Invoice = 'I';

 CURSOR Fetch_Totals_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Subinventory = p_subinventory
     AND  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no;

 CURSOR Fetch_Totals_AR_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) )
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no;

 CURSOR Fetch_Total_AR_Cur( line_no IN NUMBER ) IS
   SELECT SUM( NVL( Tax_Amount, 0 ) ) tax_amount, SUM( NVL( Base_Tax_Amount, 0 ) ) base_tax_amount,
          SUM( NVL( Func_Tax_Amount, 0 ) ) func_tax_amount
   FROM   JAI_CMN_MATCH_TAXES
   WHERE  Ref_Line_Id = p_ref_line_id
     AND  Tax_Line_No = line_no
     AND  Receipt_ID IS NOT NULL;

 CURSOR Excise_Duty_Rate_Cur IS
    SELECT --rate_per_unit/*bduvarag for the bug#6038720*/
          /* Added the following and commented the above for bug#6022072 */
          --added  nvl(additional_cvd,0) for bug#9288359
          (nvl(duty_amount,0)  + nvl(additional_cvd,0)) / decode(DECODE( TRANSACTION_TYPE,
                                                                         'MCR', oth_receipt_quantity,quantity_received)
                                                                         ,0,1,DECODE( TRANSACTION_TYPE, 'MCR', oth_receipt_quantity,quantity_received)),
                                                                         -- added the decode transaction_type for bug8366387
          -- ssumaith - removed the + additional_cvd in the above line
          receipt_num ,
          decode(DECODE( TRANSACTION_TYPE, 'MCR', oth_receipt_quantity,quantity_received) ,0,1,DECODE( TRANSACTION_TYPE, 'MCR', oth_receipt_quantity,quantity_received)) quantity_received -- added the decode transaction_type for bug8366387 ,
          --other_tax_credit / decode(quantity_received ,0,1,quantity_received) -- bug#4111609
   FROM   JAI_CMN_RG_23D_TRXS
   WHERE register_id = p_receipt_id;

  CURSOR cur_cess_Duty_Rate_Cur IS/*Bug 5989740 bduvarag*/
   SELECT tax_type , credit
   FROM   JAI_CMN_RG_OTHERS
   WHERE source_register_id = p_receipt_id and
         source_type =3; --in (3,4)  ; commented 4 for bug#9406919

   ln_quantity_received  number  ;
   ln_cess_duty_amount     NUMBER ;/*bduvarag for the bug#6038720*/
   ln_sh_cess_duty_amount  NUMBER ;/*bduvarag for the bug#6038720*/

 -- Start, Vijay Shankar for Bug# 3781299
 -- Function added to enhance the product to take care of BUDGET2004 Changes of Match Receipts
FUNCTION excise_cess_check(p_transaction_id IN NUMBER , p_Cess_type_code IN VARCHAR2)/*Bug 5989740 bduvarag*/
  RETURN NUMBER IS

    CURSOR c_get_order_line_id(cp_delivery_detail_id IN NUMBER) IS
      SELECT source_line_id
      FROM wsh_delivery_details
      WHERE delivery_detail_id = cp_delivery_detail_id;

    CURSOR c_oe_excise_cess_cnt(cp_order_line_id IN NUMBER) IS
      SELECT count(1)
      FROM JAI_OM_OE_SO_TAXES a, JAI_CMN_TAXES_ALL b
      WHERE a.line_id = cp_order_line_id
      AND a.tax_id = b.tax_id
      AND b.tax_type = p_Cess_type_code;/*Bug 5989740 bduvarag*/

    CURSOR c_ar_excise_cess_cnt(cp_customer_trx_line_id IN NUMBER) IS
      SELECT count(1)
      FROM JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b
      WHERE a.link_to_cust_trx_line_id = cp_customer_trx_line_id
      AND a.tax_id = b.tax_id
      AND b.tax_type = p_Cess_type_code ;/*Bug 5989740 bduvarag*/

    CURSOR c_get_shp_line_id(cp_transaction_id IN NUMBER) IS
      SELECT shipment_line_id
      FROM rcv_transactions
      WHERE transaction_id = cp_transaction_id;


   CURSOR c_ed_cess_tax_check(cp_shipment_line_id IN NUMBER) IS
     SELECT 1
     FROM   JAI_CMN_RG_23D_TRXS
     WHERE  register_id =  p_transaction_id
     AND    nvl(other_tax_credit,0) <> 0;

    ln_order_line_id        NUMBER(15);
    lv_shipment_line_id     NUMBER(15);
    ln_trxn_check           NUMBER(5);
    ln_check                NUMBER(5);
  BEGIN



    IF p_order_invoice = 'O' THEN
      OPEN c_get_order_line_id(p_ref_line_id);
      FETCH c_get_order_line_id into ln_order_line_id;
      CLOSE c_get_order_line_id;

      OPEN c_oe_excise_cess_cnt(ln_order_line_id);
      FETCH c_oe_excise_cess_cnt into ln_trxn_check;
      CLOSE c_oe_excise_cess_cnt;

    ELSIF p_order_invoice = 'I' THEN
      OPEN c_ar_excise_cess_cnt(p_ref_line_id);
      FETCH c_ar_excise_cess_cnt into ln_trxn_check;
      CLOSE c_ar_excise_cess_cnt;

    ELSE
      NULL;
    END IF;

    IF ln_trxn_check > 0 AND p_transaction_id IS NOT NULL THEN

      OPEN c_get_shp_line_id(p_transaction_id);
      FETCH c_get_shp_line_id into lv_shipment_line_id;
      CLOSE c_get_shp_line_id;

      OPEN c_ed_cess_tax_check(lv_shipment_line_id);
      FETCH c_ed_cess_tax_check into ln_check;
      CLOSE c_ed_cess_tax_check;

    ELSE
      ln_check := -1;
    END IF;

    If ln_check > 0 THEN
      ln_check := 1;
    END IF;

    RETURN ln_check;
  END excise_cess_check;
  -- End, Vijay Shankar for Bug# 3781299

BEGIN

/*------------------------------------------------------------------------------------------
 FILENAME: JA_IN_RG23_D_CAL_TAX_P.sql

 CHANGE HISTORY:
S.No      Date          Author and Details

1.        10/10/2001    A.Vijay Kumar, Subbu
                        Cursor written to pick taxes from Receipts for Tar# 9445972.700

2.        12/11/2003    SSUMAITH - Bug # 3179379
                        In the case of a manual ar invoice which is matched against an iso receipt or
                        manual rg23d receipt, then excise taxes were not getting populated into the
                        ar invoice from the rg23 receipt.
                        The reason for this behaviour is that , ther ar_tax_cur was written to work based
                        on JAI_PO_TAXES and jai_rcv_tax_pkg.default_taxes_onto_line. The problem with cursor
                        is that , manual rg23d receipts and receipts created by iso transactions are not
                        picked by this cursor.

                        Hence, the cursor which was used earlier has been retained , which picks the taxes
                        from JAI_AR_TRX_TAX_LINES table and then calculate the excise tax bases on
                        the excise duty per unit and the same is updated back to the
                        localization AR table.

3.        05/05/2004    Aiyer - Bug # 3611625, FileVersion 619.1
                        Issue:-
                         For a trading organization when a delivery is split into two deliveries,
             such that the line contains adhoc type of non excise taxes then it is observed that
             the tax amounts do not get apportioned based on the quantity applied and the orginal line
             quantity.

            Reason:-
             This was happening because prior to this fix the tax amounts in case of Adhoc non excise
             type of tax used to be defaulted from JAI_OM_OE_SO_TAXES .
             Now when a delivery detail is split after pick release, then the delivery detail get splits
             but not the line.
             Hence the tax amount's, which were picked up from the JAI_OM_OE_SO_TAXES did not get apportioned
             properly.

            Fix:-
             In case of Adhoc non excise type of taxes, the tax amounts get apportioned based on the p_line_quantity
             and v_original_quantity.

                        Dependency Due To This Bug:-
            None

4   21/07/2004   Vijay Shankar for Budget2004 Bug# 3781299, Version: 115.1
                  Education Cess has been introduced in Budget 2004, which will be calculated on all excise taxes.
                  Code is modified to make Education Cess Tax_rate as 0 in MAIN Cursor itself if
                  JAI_CMN_TAXES_ALL.stform_type='EXCISE - CESS' and 'EXCISE-CESS'/'CVD-CESS' exist in Receipt
                  Separate function is written to check(1) whether Cess tax exist in sales order/AR Manual Invoice line,
                  if exists then check(2) for ExciseCess tax is receipts, If exists then return 1 else 0. If any of the
                  check (1),(2) fails then function returns -1.
                   Function excise_cess_check is added with this code change. Also Cursors oe_tax_cur and ar_tax_cur are modified
                  NO DEPENDANCY

5   17/09/2004   Bug#3896539, Version: 115.2
                  Modified the values assigned to Variables lv_excise_cess_code and lv_cvd_cess_code, so that they dont contain
                  empty spaces

6   10/01/2005   rallamse bug#4111609, Version 115.3

                 When Match receipts happens, in addition to excise , education cess also needs to be matched to the sales order / invoice
                 This has been done by makign code changes at various places in the procedure.

                 This fix does not introduce dependency on this object , but this patch cannot be sent alone to the CT
                 because it relies on the alter done and the new tables created as part of the education cess enhancement
                 bug# 4146708 creates the objects

7   06/08/2005   Aiyer bug#4539813, Version 120.3  (Forward porting fix done in the bug 4284335)
                 Issue:-
                  Excise Education cess taxes are not being recalculated correctly in some cases.

                 Reason:-
                  This is a enhancement to the existing education cess code
                  Here if the other_tax_credit in jai_cmn_rg_23d_trxs is <> 0 then the tax_rate and precedences can be assigned as null
                  and the tax rate need not be considered.
                  However if the other_tax_credit in jai_cmn_rg_23d_trxs is = 0 then the tax rate needs to be considered for recalculation.

                 Fix:-
                 Modified the code to set the tax rate and precedences according to the other_tax_rate column in jai_cmn_rg_23d_trxs based on a IF condition.

                 Dependency Introduced due to this bug:-
                 None
8   08/05/2007   Made changes for InterOrg bug 6030615

9   09/10/2007   CSahoo for bug#6487182, File Version 120.12
     R12RUP04-ST1: MATCHING RESULTS IN INCORRECT NEGATIVE TAX FOR ZERO RATE TAX CODE
     Modified the IF condition to "tax_rate_tab( i ) NOT IN (0,-1)"

10  12/19/2007   Kevin Cheng   Update the logic for inclusive tax calculation

11  18-feb-2008  ssumaith - bug#6817615
                 duty amount field in the jai_cmn_rg23d_trxs table qas already
including additional_cvd. Adding additional_cvd again is causing the problem.

12  03/26/2008   Kevin Cheng bug#6881225
                 Initialize pl/sql table Tax_Amt_Tab() to 0 in the begining of initialization loop,
                 in case there is no value for this table. Otherwise, a "no data found" exception will
                 be thrown out in later calculation loops.

13  03/26/2008   Kevin Cheng bug#6915049
                 Add statement ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i) in the ELSE branch for
                 adhoc and UOM related taxes, so lt_tax_amt_non_rate_tab(i) won't lose its value
                 in later assignment statement lt_tax_amt_non_rate_tab(i):=ln_tax_amt_nr.

14  04/04/2008   Kevin Cheng bug#6936009
                 Remove round function for those temporary variables, so the calculation result will
                 be more pricise, solving the decimal fraction issue.
11  25-feb-2010 vkaranam for bug#9406919
                 Issue:
                 Cess/SHE Cess amount is updated wrongly in the ship confirm localized
                 for trading organization.
                 Fix:
                 source_type condition in cur_cess_Duty_Rate_Cur has been changed from
                 source_type in (3,4) to source_type =3;

12  11-jun-2010  vkaranam for bug#9794835
                 Issue:
                TAX PRECEDENCE IGNORING BASE AMOUNT FOR TRADING SHIPMENT
                Analysis:
                issue is with the base tax amount calculated incorrectly.
                fix:
                addded the logic to calculate the base tax amount correctly.

--------------------------------------------------------------------------------------------*/

  lv_excise_cess_code   := 'EXCISE_EDUCATION_CESS'; --Ramananda for File.Sql.35
  lv_cvd_cess_code      := 'CVD_EDUCATION_CESS'; --Ramananda for File.Sql.35
  v_exempt_flag         := jai_constants.no; --Ramananda for File.Sql.35

  IF p_ref_line_id IS NULL THEN
     RAISE_APPLICATION_ERROR( -20120, 'Ref Line Id cannot be NULL' );
  END IF;
/*Bug 5989740 bduvarag*/
ln_quantity_received    :=0 ;
  OPEN Excise_Duty_Rate_Cur;
 FETCH Excise_Duty_Rate_Cur into v_excise_duty_rate, ln_transaction_id ,ln_quantity_received ;/*Bug 5989740 bduvarag*/
  CLOSE Excise_Duty_Rate_Cur;
/*Bug 5989740 bduvarag*/

  for rec in cur_cess_Duty_Rate_Cur
  loop /*bduvarag for the bug#6038720 start*/

       if rec.tax_type in( jai_constants.tax_type_exc_edu_cess,
                           jai_constants.tax_type_cvd_edu_cess)
       then
         ln_cess_duty_amount  := NVL(ln_cess_duty_amount,0) + rec.credit  ;
       elsif rec.tax_type in( jai_constants.tax_type_sh_exc_edu_cess,
                              jai_constants.tax_type_sh_cvd_edu_cess)
       then
         ln_sh_cess_duty_amount  := NVL(ln_sh_cess_duty_amount,0) + rec.credit  ;

   /*bduvarag for the bug#6038720 end*/
       end if ;
  end loop;

  ln_cess_duty_rate    := ln_cess_duty_amount/ln_quantity_received;   --Added for bug#6038720, bduvarag
  ln_sh_cess_duty_rate := ln_sh_cess_duty_amount/ln_quantity_received;--Added for bug#6038720, bduvarag


  ln_cess_duty_rate  := nvl(ln_cess_duty_rate ,0) * nvl(p_line_quantity,0); /*  bug#4111609   */
  ln_sh_cess_duty_rate  := nvl(ln_sh_cess_duty_rate ,0) * nvl(p_line_quantity,0);/*Bug 5989740 bduvarag*/


  -- Call to the internal function added to code for BUDGET2004 Changes realted to Match Receipts of Trading Orgn
  ln_cess_check := excise_cess_check(p_receipt_id,lv_excise_cess_code);/*Bug 5989740 bduvarag*/

  IF p_order_invoice = 'O' THEN

     OPEN  Chk_Rcd_Cur;
     FETCH Chk_Rcd_Cur INTO v_count;
     CLOSE Chk_Rcd_Cur;

     OPEN  Fetch_Dtls_Cur;
     FETCH Fetch_Dtls_Cur INTO v_original_quantity, v_selling_price, v_unit_code, v_inventory_item_id
     --Add by Kevin Cheng for inclusive tax Dec 19, 2007
     ---------------------------------------------------
     , ln_line_amount
     , ln_assessable_value_tot
     , ln_vat_assessable_value_tot
     , ln_vat_reversal_value_tot
     ---------------------------------------------------
     ;
     CLOSE Fetch_Dtls_Cur;

     v_excise_duty_rate := nvl(v_excise_duty_rate,0) * nvl(p_line_quantity,0);


     OPEN  Fetch_OE_Address_Cur;
     FETCH Fetch_OE_Address_Cur INTO v_address_id;
     CLOSE Fetch_OE_Address_Cur;

     OPEN  Fetch_Exempt_Cur( v_address_id );
     FETCH Fetch_Exempt_Cur INTO v_exempt_flag;
     CLOSE Fetch_Exempt_Cur;

     FOR rec in oe_tax_cur(ln_cess_check, ln_sh_cess_check)  LOOP/*Bug 5989740 bduvarag*/
       IF v_count = 0 THEN
          INSERT INTO JAI_CMN_MATCH_TAXES(MATCH_TAX_ID, REF_LINE_ID,
                                                   SUBINVENTORY,
                                                   TAX_LINE_NO,
                                                   PRECEDENCE_1,
                                                   PRECEDENCE_2,
                                                   PRECEDENCE_3,
                                                   PRECEDENCE_4,
                                                   PRECEDENCE_5,
                                                   PRECEDENCE_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                                   PRECEDENCE_7,
                                                   PRECEDENCE_8,
                                                   PRECEDENCE_9,
                                                   PRECEDENCE_10,
               TAX_ID,
                                                   TAX_RATE,
                                                   QTY_RATE,
                                                   UOM,
                                                   TAX_AMOUNT,
                                                   BASE_TAX_AMOUNT,
                                                   FUNC_TAX_AMOUNT,
                                                   TOTAL_TAX_AMOUNT,
                                                   CREATION_DATE,
                                                   CREATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   LAST_UPDATED_BY,
                                                   RECEIPT_ID,
                                                   ORDER_INVOICE  )
          VALUES ( JAI_CMN_MATCH_TAXES_S.nextval,  p_ref_line_id,
                   p_subinventory,
                   rec.lno,
                   rec.p_1,
                   rec.p_2,
                   rec.p_3,
                   rec.p_4,
                   rec.p_5,
                   rec.p_6,
                   rec.p_7,
                   rec.p_8,
                   rec.p_9,
                   rec.p_10,
       rec.tax_id,
                   rec.tax_rate,
                   rec.qty_rate,
                   rec.uom,
                   0,
                   0,
                   0,
                   0,
                   SYSDATE,
                   UID,
                   SYSDATE,
                   UID,
                   UID,
                   p_receipt_id,
                   p_order_invoice );
       END IF;
      Tax_Rate_Tab(rec.lno) := nvl(rec.Tax_Rate,0);
      Adhoc_Flag_Tab(rec.lno) := nvl(rec.adhoc_flag,'N'); /* Added for bug 5091874 */
      Tax_Amt_Tab(rec.lno)    := 0; --Add by Kevin Cheng for bug#6881225 Mar 26, 2008
       IF ( excise_flag_set = FALSE AND rec.tax_type_val = 1 ) OR ( rec.tax_type_val <> 1 ) THEN

          P1(rec.lno) := nvl(rec.p_1,-1);
          P2(rec.lno) := nvl(rec.p_2,-1);
          P3(rec.lno) := nvl(rec.p_3,-1);
          P4(rec.lno) := nvl(rec.p_4,-1);
          P5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    P6(rec.lno) := nvl(rec.p_6,-1);
          P7(rec.lno) := nvl(rec.p_7,-1);
          P8(rec.lno) := nvl(rec.p_8,-1);
          P9(rec.lno) := nvl(rec.p_9,-1);
          P10(rec.lno) := nvl(rec.p_10,-1);

-- END BUG 5228046


    IF rec.tax_type_val = 1 THEN
             tax_rate_tab(rec.lno) :=  -1;

       P1(rec.lno) := -1;
             P2(rec.lno) := -1;
             P3(rec.lno) := -1;
             P4(rec.lno) := -1;
             P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

       P6(rec.lno) := -1;
             P7(rec.lno) := -1;
             P8(rec.lno) := -1;
             P9(rec.lno) := -1;
             P10(rec.lno) := -1;

-- END BUG 5228046
       Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;
             tax_target_tab(rec.lno) := v_excise_duty_rate;
            /* Bug#4111609  added code for cess */
          ELSIF excise_flag_set AND rec.tax_type_val = 3 then
            /*
            || Start of bug 4539813
            || Code modified by aiyer for the bug 4539813
            */
            IF nvl(ln_cess_duty_rate,0) <> 0 THEN
            /*
            ||other_tax_credit in rg23_d is not null
            */
              tax_rate_tab(rec.lno) :=  -1;

        P1(rec.lno) := -1;
              P2(rec.lno) := -1;
              P3(rec.lno) := -1;
              P4(rec.lno) := -1;
              P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
        P6(rec.lno) := -1;
              P7(rec.lno) := -1;
              P8(rec.lno) := -1;
              P9(rec.lno) := -1;
              P10(rec.lno) := -1;
-- END BUG 5228046


      END IF;
            /*
            ||End of Bug 4539813
            */
            Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;
            tax_target_tab(rec.lno) := ln_cess_duty_rate;
             /* end bug#4111609 */   /*Bug 5989740 bduvarag start*/
        ELSIF excise_flag_set AND rec.tax_type_val = 4 then
            IF nvl(ln_sh_cess_duty_rate,0) <> 0 THEN
              tax_rate_tab(rec.lno) :=  -1;
              P1(rec.lno) := -1;
              P2(rec.lno) := -1;
              P3(rec.lno) := -1;
              P4(rec.lno) := -1;
              P5(rec.lno) := -1;
              P6(rec.lno) := -1;
              P7(rec.lno) := -1;
              P8(rec.lno) := -1;
              P9(rec.lno) := -1;
              P10(rec.lno) := -1;


          END IF;

                Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;
            tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;
/*Bug 5989740 bduvarag end*/
          END IF;

       ELSIF excise_flag_set AND rec.tax_type_val = 1 THEN
         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
   P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;

-- END BUG 5228046

   tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;
       END IF;

      IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

   P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;

-- END BUG 5228046

   tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;

      END IF;
      Rounding_factor_tab(rec.lno) := rec.rnd;
      Tax_Type_Tab(rec.lno) := rec.tax_type_val;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_amt_rate_tax_tab(rec.lno) :=0;
      lt_tax_amt_non_rate_tab(rec.lno) :=0; -- tax inclusive
      lt_base_tax_amt_tab(rec.lno)     := 0;
      base_tax_amount_nr_tab(rec.lno):=0;--bug#9794835
      ---------------------------------------------------

      IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 THEN
         tax_rate_tab(rec.lno) :=  -1;
         -- Start of addition by Srihari and Gaurav on 11-JUL-2000
         IF rec.tax_type_val = 1 THEN
             /*Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/14
             lt_tax_amt_non_rate_tab(rec.lno) := v_excise_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/14
             tax_target_tab(rec.lno) := v_excise_duty_rate;
         ELSIF rec.tax_type_val = 3 then
            /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/14
            lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/14
            tax_target_tab(rec.lno) := ln_cess_duty_rate;
      /*Bug 5989740 bduvarag*/
         ELSIF rec.tax_type_val = 4 then
            /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/14
            lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/14
            tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;

         ELSE
           /*tax_amt_tab(rec.lno)    := (p_line_quantity / v_original_quantity) * rec.tax_amount;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/14
           lt_tax_amt_non_rate_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount; --Add by Kevin Cheng for inclusive tax 2008/01/14
           tax_target_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount;
           -- End of bug 3611625
         END IF;
         lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax 2008/01/14
      ELSE
         IF rec.tax_type_val NOT IN  (1,3,4) THEN  /*Bug 5989740 bduvarag*/
            Tax_Amt_Tab(rec.lno)  := 0;
         END IF;
      END IF;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_rate_per_rupee(rec.lno) := NVL(rec.tax_rate,0)/100;
      ln_total_tax_per_rupee         := 0;
      lt_inclu_tax_tab(rec.lno)      := NVL(rec.inclusive_tax_flag,'N');

      IF rec.tax_rate is null THEN
        lt_tax_rate_zero_tab(rec.lno) := 0;
      ELSIF rec.tax_rate = 0 THEN
        lt_tax_rate_zero_tab(rec.lno) := -9999;
      ELSE
        lt_tax_rate_zero_tab(rec.lno) := rec.tax_rate;
      END IF;
      -----------------------------------------------------

      --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
      /*IF rec.Valid_Date is NULL Or rec.Valid_Date >= Sysdate THEN
         End_Date_Tab(rec.lno) := 1;
      ELSE
         End_Date_Tab(rec.lno) := 0;
         tax_amt_tab(row_count)  := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      END IF;*/

      row_count := row_count + 1;
      IF tax_rate_tab(rec.lno) = 0 THEN
         FOR uom_cls IN uom_class_cur(v_unit_code, rec.uom) LOOP
             INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, v_inventory_item_id, v_conversion_rate);
             IF nvl(v_conversion_rate, 0) <= 0 THEN
                INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, 0, v_conversion_rate);
                IF nvl(v_conversion_rate, 0) <= 0  THEN
                   v_conversion_rate := 0;
                END IF;
             END IF;
             IF ( excise_flag_set ) AND ( rec.tax_type_val = 1 ) THEN
               /*tax_amt_tab(rec.lno) := 0;*/--Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
             ELSIF rec.tax_type_val = 3 then
               /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
               tax_target_tab(rec.lno) := ln_cess_duty_rate;
         /*Bug 5989740 bduvarag*/
       ELSIF rec.tax_type_val = 4 then
               /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
               tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;

             ELSE
              --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
              /*tax_amt_tab(rec.lno) := ROUND( nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity, rounding_factor_tab(rec.lno) );*/
              --Add by Kevin Cheng for inclusive tax Dec 12, 2007
              lt_tax_amt_non_rate_tab(rec.lno) := /*ROUND( */nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity/*, rounding_factor_tab(rec.lno) )*/; --Modified by Kevin Cheng for bug#6936009 April 02, 2008
             END IF;
            IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
              /*tax_amt_tab( rec.lno ) := 0;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
              lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
            END IF;
            lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax Dec 12, 2007
            tax_rate_tab( rec.lno ) := -1;
            tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
         END LOOP;
      END IF;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      IF rec.Valid_Date is NULL Or rec.Valid_Date >= SYSDATE
      THEN
         End_Date_Tab(rec.lno) := 1;
      ELSE
         End_Date_Tab(rec.lno) := 0;
         tax_amt_tab(rec.lno)  := 0;
      END IF;
      ---------------------------------------------------

      IF rec.tax_type_val = 1 THEN
         excise_flag_set := TRUE;
      END IF;
     END LOOP;
-----------------------------------------------------------------------------------------------------
  ELSIF p_order_invoice = 'I' THEN
     OPEN  Chk_Rcd_AR_Cur;
     FETCH Chk_Rcd_AR_Cur INTO v_count;
     CLOSE Chk_Rcd_AR_Cur;

     OPEN  Fetch_Dtls1_Cur;
     FETCH Fetch_Dtls1_Cur INTO v_original_quantity, v_selling_price, v_unit_code, v_inventory_item_id
     , ln_line_amount, ln_assessable_value_tot, ln_vat_assessable_value_tot,ln_vat_reversal_value_tot --Add by Kevin Cheng for inclusive tax Dec 12, 2007
     ;
     CLOSE Fetch_Dtls1_Cur;

     v_excise_duty_rate := nvl(v_excise_duty_rate,0) * nvl(p_line_quantity,0);

     OPEN  Fetch_AR_Address_Cur;
     FETCH Fetch_AR_Address_Cur INTO v_address_id;
     CLOSE Fetch_AR_Address_Cur;

     OPEN  Fetch_Exempt_Cur( v_address_id );
     FETCH Fetch_Exempt_Cur INTO v_exempt_flag;
     CLOSE Fetch_Exempt_Cur;



     FOR rec in ar_tax_cur(ln_cess_check, ln_sh_cess_check)  LOOP/*Bug 5989740 bduvarag*/

       IF v_count = 0 THEN

          INSERT INTO JAI_CMN_MATCH_TAXES(MATCH_TAX_ID, REF_LINE_ID,
                                                   SUBINVENTORY,
                                                   TAX_LINE_NO,
                                                   PRECEDENCE_1,
                                                   PRECEDENCE_2,
                                                   PRECEDENCE_3,
                                                   PRECEDENCE_4,
                                                   PRECEDENCE_5,
                                                   PRECEDENCE_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                                   PRECEDENCE_7,
                                                   PRECEDENCE_8,
                                                   PRECEDENCE_9,
                                                   PRECEDENCE_10,
                                                   TAX_ID,
                                                   TAX_RATE,
                                                   QTY_RATE,
                                                   UOM,
                                                   TAX_AMOUNT,
                                                   BASE_TAX_AMOUNT,
                                                   FUNC_TAX_AMOUNT,
                                                   TOTAL_TAX_AMOUNT,
                                                   CREATION_DATE,
                                                   CREATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   LAST_UPDATED_BY,
                                                   RECEIPT_ID,
                                                   ORDER_INVOICE  )
          VALUES ( JAI_CMN_MATCH_TAXES_S.nextval,  p_ref_line_id,
                   p_subinventory,
                   rec.lno,
                   rec.p_1,
                   rec.p_2,
                   rec.p_3,
                   rec.p_4,
                   rec.p_5,
                   rec.p_6, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                   rec.p_7,
                   rec.p_8,
                   rec.p_9,
                   rec.p_10,
       rec.tax_id,
                   rec.tax_rate,
                   rec.qty_rate,
                   rec.uom,
                   0,
                   0,
                   0,
                   0,
                   SYSDATE,
                   UID,
                   SYSDATE,
                   UID,
                   UID,
                   p_receipt_id,
                   p_order_invoice );

       END IF;

     Tax_Rate_Tab(rec.lno) := nvl(rec.Tax_Rate,0);
     Adhoc_Flag_Tab(rec.lno) := nvl(rec.adhoc_flag,'N'); /* Added for bug 5091874 */
     Tax_Amt_Tab(rec.lno)    := 0; --Add by Kevin Cheng for bug#6881225 Mar 28, 2008
       if excise_flag_set  then
         v_e_s := 'Yes';
       else
        v_e_s := 'NO';
       end if;

       IF ( excise_flag_set = FALSE AND rec.tax_type_val = 1 ) OR ( rec.tax_type_val <> 1 ) THEN

          P1(rec.lno) := nvl(rec.p_1,-1);
          P2(rec.lno) := nvl(rec.p_2,-1);
          P3(rec.lno) := nvl(rec.p_3,-1);
          P4(rec.lno) := nvl(rec.p_4,-1);
          P5(rec.lno) := nvl(rec.p_5,-1);


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    P6(rec.lno) := nvl(rec.p_6,-1);
          P7(rec.lno) := nvl(rec.p_7,-1);
          P8(rec.lno) := nvl(rec.p_8,-1);
          P9(rec.lno) := nvl(rec.p_9,-1);
          P10(rec.lno) := nvl(rec.p_10,-1);
-- END BUG 5228046


    IF rec.tax_type_val = 1 THEN

             tax_rate_tab(rec.lno) :=  -1;
             P1(rec.lno) := -1;
             P2(rec.lno) := -1;
             P3(rec.lno) := -1;
             P4(rec.lno) := -1;
             P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
       P6(rec.lno) := -1;
             P7(rec.lno) := -1;
             P8(rec.lno) := -1;
             P9(rec.lno) := -1;
             P10(rec.lno) := -1;
-- END BUG 5228046

       Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;
             tax_target_tab(rec.lno) := v_excise_duty_rate;
             /* Bug#4111609  added code for cess */
          ELSIF excise_flag_set AND rec.tax_type_val = 3 then
            /*
            || Start of bug 4539813
            || Code modified by aiyer for the bug 4539813
            */
            IF nvl(ln_cess_duty_rate,0) <> 0 THEN
            /*
            ||other_tax_credit in jai_cmn_rg_23d_trxs is not null
            */
              tax_rate_tab(rec.lno) :=  -1;
              P1(rec.lno) := -1;
              P2(rec.lno) := -1;
              P3(rec.lno) := -1;
              P4(rec.lno) := -1;
              P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
        P6(rec.lno) := -1;
              P7(rec.lno) := -1;
              P8(rec.lno) := -1;
              P9(rec.lno) := -1;
              P10(rec.lno) := -1;

-- END BUG 5228046


            END IF;
            /*
            ||End of Bug 4539813
            */
             Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;
             tax_target_tab(rec.lno) := ln_cess_duty_rate;
       /*Bug 5989740 bduvarag start*/
  ELSIF excise_flag_set AND rec.tax_type_val = 4 then
            IF nvl(ln_sh_cess_duty_rate,0) <> 0 THEN
            /*
            ||other_tax_credit in ja_in_rg23_d is not null
            */
               tax_rate_tab(rec.lno) :=  -1;
               P1(rec.lno) := -1;
               P2(rec.lno) := -1;
               P3(rec.lno) := -1;
               P4(rec.lno) := -1;
               P5(rec.lno) := -1;
               P6(rec.lno) := -1;
               P7(rec.lno) := -1;
               P8(rec.lno) := -1;
               P9(rec.lno) := -1;
               P10(rec.lno) := -1;
             END IF;
             Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;
             tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;
       /*Bug 5989740 bduvarag end*/
          END IF;
       ELSIF excise_flag_set AND rec.tax_type_val = 1 THEN

         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

   P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;
-- END BUG 5228046


   tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;
       END IF;
        /* end Bug#4111609 */

      IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
         P1(rec.lno) := -1;
         P2(rec.lno) := -1;
         P3(rec.lno) := -1;
         P4(rec.lno) := -1;
         P5(rec.lno) := -1;


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
   P6(rec.lno) := -1;
         P7(rec.lno) := -1;
         P8(rec.lno) := -1;
         P9(rec.lno) := -1;
         P10(rec.lno) := -1;
-- END BUG 5228046


         tax_rate_tab(rec.lno) :=  -1;
         Tax_Amt_Tab(rec.lno)  := 0;
         tax_target_tab(rec.lno) := 0;
      END IF;
      Rounding_factor_tab(rec.lno) := rec.rnd;
      Tax_Type_Tab(rec.lno) := rec.tax_type_val;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_amt_rate_tax_tab(rec.lno) :=0;
      lt_tax_amt_non_rate_tab(rec.lno) :=0; -- tax inclusive
      lt_base_tax_amt_tab(rec.lno)     := 0;
      ---------------------------------------------------

      IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 THEN

         tax_rate_tab(rec.lno) :=  -1;
         -- Start of addition by Srihari and Gaurav on 11-JUL-2000
         IF rec.tax_type_val = 1 THEN
             /*Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/15
             lt_tax_amt_non_rate_tab(rec.lno) := v_excise_duty_rate;--Add by Kevin Cheng for inclusive tax 2008/01/15
             tax_target_tab(rec.lno) := v_excise_duty_rate;
         ELSIF rec.tax_type_val = 3 then
            /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/15
            lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate;--Add by Kevin Cheng for inclusive tax 2008/01/15
            tax_target_tab(rec.lno) := ln_cess_duty_rate;
/*Bug 5989740 bduvarag*/
     ELSIF rec.tax_type_val = 4 then
            /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/15
            lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate;--Add by Kevin Cheng for inclusive tax 2008/01/15
            tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;

         ELSE
           /*tax_amt_tab(rec.lno)    := (p_line_quantity / v_original_quantity) * rec.tax_amount;*/--Comment out by Kevin Cheng for inclusive tax 2008/01/15
           lt_tax_amt_non_rate_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount;--Add by Kevin Cheng for inclusive tax 2008/01/15
           tax_target_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount;
           -- End of bug 3611625
         END IF;
         lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax 2008/01/15
      ELSE
         IF rec.tax_type_val NOT IN (1,3,4) THEN/*Bug 5989740 bduvarag*/
            Tax_Amt_Tab(rec.lno)  := 0;
         END IF;
      END IF;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_rate_per_rupee(rec.lno) := NVL(rec.tax_rate,0)/100;
      ln_total_tax_per_rupee         := 0;
      lt_inclu_tax_tab(rec.lno)      := NVL(rec.inclusive_tax_flag,'N');

      IF rec.tax_rate is null THEN
        lt_tax_rate_zero_tab(rec.lno) := 0;
      ELSIF rec.tax_rate = 0 THEN
        lt_tax_rate_zero_tab(rec.lno) := -9999;
      ELSE
        lt_tax_rate_zero_tab(rec.lno) := rec.tax_rate;
      END IF;

      ---------------------------------------------------
      --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
      /*IF rec.Valid_Date is NULL Or rec.Valid_Date >= Sysdate THEN
     End_Date_Tab(rec.lno) := 1;
      ELSE
     End_Date_Tab(rec.lno) := 0;
      END IF;*/

      row_count := row_count + 1;

      IF tax_rate_tab(rec.lno) = 0 THEN

         FOR uom_cls IN uom_class_cur(v_unit_code, rec.uom) LOOP
            INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, v_inventory_item_id, v_conversion_rate);
            IF nvl(v_conversion_rate, 0) <= 0 THEN
               INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, 0, v_conversion_rate);
               IF nvl(v_conversion_rate, 0) <= 0  THEN
                  v_conversion_rate := 0;
               END IF;
            END IF;
            IF ( excise_flag_set ) AND ( rec.tax_type_val = 1 ) THEN
               /*tax_amt_tab(rec.lno) := 0;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
            ELSIF rec.tax_type_val = 3 then
               /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
               tax_target_tab(rec.lno) := ln_cess_duty_rate;
/*Bug 5989740 bduvarag*/
        ELSIF rec.tax_type_val = 4 then
               /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
               tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;

            ELSE
               --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
               /*tax_amt_tab(rec.lno) := ROUND( nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity, rounding_factor_tab(rec.lno) );*/
               --Add by Kevin Cheng for inclusive tax Dec 12, 2007
               lt_tax_amt_non_rate_tab(rec.lno) := /*ROUND( */nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity/*, rounding_factor_tab(rec.lno) )*/;  --Modified by Kevin Cheng for bug#6936009 April 02, 2008
            END IF;
            IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
                /*tax_amt_tab( rec.lno ) := 0;*/--Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
                lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
            END IF;
            lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax Dec 12, 2007
            tax_rate_tab( rec.lno ) := -1;
            tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );

         END LOOP;
      END IF;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      IF rec.Valid_Date is NULL Or rec.Valid_Date >= Sysdate THEN
         End_Date_Tab(rec.lno) := 1;
      ELSE
         End_Date_Tab(rec.lno) := 0;
         tax_amt_tab(rec.lno)  := 0;
      END IF;
      ---------------------------------------------------

      IF rec.tax_type_val = 1 THEN

         excise_flag_set := TRUE;
      END IF;
     END LOOP;

   ELSIF p_order_invoice = 'X' THEN --   'X' =  Inter org XFER bug 6030615


          OPEN  Fetch_Dtls_xfer_Cur;
          FETCH Fetch_Dtls_xfer_Cur INTO v_original_quantity, v_selling_price, v_unit_code, v_inventory_item_id , ln_vat_assessable_value
          , ln_line_amount, ln_assessable_value_tot --Add by Kevin Cheng for inclusive tax Dec 12, 2007
          ;
          CLOSE Fetch_Dtls_xfer_Cur;
         ln_vat_assessable_value_tot := ln_vat_assessable_value; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
    ln_vat_assessable_value := /*round(*/nvl(ln_vat_assessable_value,0) / v_original_quantity/*,2)*/ ; /* Added for bug#6374760 */--Modified by Kevin Cheng for bug#6936009 April 02, 2008


          v_excise_duty_rate := nvl(v_excise_duty_rate,0) * nvl(p_line_quantity,0);



          FOR rec in interorg_xfer_tax_cur  LOOP



            IF v_count = 0 THEN



               INSERT INTO Jai_cmn_match_Taxes( match_tax_id, --6447097
                                                REF_LINE_ID,
                                                        SUBINVENTORY,
                                                        TAX_LINE_NO,
                                                        PRECEDENCE_1,
                                                        PRECEDENCE_2,
                                                        PRECEDENCE_3,
                                                        PRECEDENCE_4,
                                                        PRECEDENCE_5,
                                                        TAX_ID,
                                                        TAX_RATE,
                                                        QTY_RATE,
                                                        UOM,
                                                        TAX_AMOUNT,
                                                        BASE_TAX_AMOUNT,
                                                        FUNC_TAX_AMOUNT,
                                                        TOTAL_TAX_AMOUNT,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATE_LOGIN,
                                                        LAST_UPDATED_BY,
                                                        RECEIPT_ID,
                                                        ORDER_INVOICE ,
                                                        PRECEDENCE_6,
                                                        PRECEDENCE_7,
                                                        PRECEDENCE_8,
                                                        PRECEDENCE_9,
                                                        PRECEDENCE_10
      )
               VALUES ( jai_cmn_match_taxes_s.nextval,--6447097
                        p_ref_line_id,
                        p_subinventory,
                        rec.lno,
                        rec.p_1,
                        rec.p_2,
                        rec.p_3,
                        rec.p_4,
                        rec.p_5,
                        rec.tax_id,
                        rec.tax_rate,
                        rec.qty_rate,
                        rec.uom,
                        0,
                        0,
                        0,
                        0,
                        SYSDATE,
                        FND_GLOBAl.USER_ID,
                        SYSDATE,
                        FND_GLOBAL.LOGIN_ID,
                        FND_GLOBAL.LOGIN_ID,
                        p_receipt_id,
                        p_order_invoice,
                        rec.p_6,
                        rec.p_7,
                        rec.p_8,
                        rec.p_9,
                        rec.p_10
     );
            END IF;
           Tax_Rate_Tab(rec.lno) := nvl(rec.Tax_Rate,0);
           Adhoc_Flag_Tab(rec.lno) := nvl(rec.adhoc_flag,'N'); /* Added rallamse bug#5068418 */
           Tax_Amt_Tab(rec.lno)    := 0; --Add by Kevin Cheng for bug#6881225 Mar 28, 2008
            IF ( excise_flag_set = FALSE AND rec.tax_type_val = 1 ) OR ( rec.tax_type_val <> 1 ) THEN

               P1(rec.lno) := nvl(rec.p_1,-1);
               P2(rec.lno) := nvl(rec.p_2,-1);
               P3(rec.lno) := nvl(rec.p_3,-1);
               P4(rec.lno) := nvl(rec.p_4,-1);
               P5(rec.lno) := nvl(rec.p_5,-1);
               P6(rec.lno) := nvl(rec.p_6,-1);
               P7(rec.lno) := nvl(rec.p_7,-1);
               P8(rec.lno) := nvl(rec.p_8,-1);
               P9(rec.lno) := nvl(rec.p_9,-1);
               P10(rec.lno) := nvl(rec.p_10,-1);


               IF rec.tax_type_val = 1 THEN
                  tax_rate_tab(rec.lno) :=  -1;
                  P1(rec.lno) := -1;
                  P2(rec.lno) := -1;
                  P3(rec.lno) := -1;
                  P4(rec.lno) := -1;
                  P5(rec.lno) := -1;
                  P6(rec.lno) := -1;
                  P7(rec.lno) := -1;
                  P8(rec.lno) := -1;
                  P9(rec.lno) := -1;
                  P10(rec.lno) := -1;
                  Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;
                  tax_target_tab(rec.lno) := v_excise_duty_rate;
                  /* Bug#4111609  added code for cess */



               ELSIF excise_flag_set AND rec.tax_type_val = 3 then
               /*
               || Start of bug 4284335
               || Code modified by aiyer for the bug 4284335
               */
                 IF nvl(ln_cess_duty_rate,0) <> 0 THEN
                 /*
                 ||other_tax_credit in rg23_d is not null
                 */
                   tax_rate_tab(rec.lno) :=  -1;
                   P1(rec.lno) := -1;
                   P2(rec.lno) := -1;
                   P3(rec.lno) := -1;
                   P4(rec.lno) := -1;
                   P5(rec.lno) := -1;
                   P6(rec.lno) := -1;
                   P7(rec.lno) := -1;
                   P8(rec.lno) := -1;
                   P9(rec.lno) := -1;
                   P10(rec.lno) := -1;

                 END IF;
                 /*
                 ||End of Bug 4284335
                 */

                 Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;
                 tax_target_tab(rec.lno) := ln_cess_duty_rate;
                  /* end bug#4111609 */

            -- bug  6470006
      ELSIF excise_flag_set AND rec.tax_type_val = 4 then
              IF nvl(ln_sh_cess_duty_rate,0) <> 0 THEN
              /*
              ||other_tax_credit in rg23_d is not null
              */
                tax_rate_tab(rec.lno) :=  -1;
                P1(rec.lno) := -1;
                P2(rec.lno) := -1;
                P3(rec.lno) := -1;
                P4(rec.lno) := -1;
                P5(rec.lno) := -1;
                P6(rec.lno) := -1;
                P7(rec.lno) := -1;
                P8(rec.lno) := -1;
                P9(rec.lno) := -1;
                P10(rec.lno) := -1;

              END IF;
              Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;
              tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;
          -- end  bug  6470006

               END IF;

            ELSIF excise_flag_set AND rec.tax_type_val = 1 THEN
              P1(rec.lno) := -1;
              P2(rec.lno) := -1;
              P3(rec.lno) := -1;
              P4(rec.lno) := -1;
              P5(rec.lno) := -1;
              P6(rec.lno) := -1;
              P7(rec.lno) := -1;
              P8(rec.lno) := -1;
              P9(rec.lno) := -1;
              P10(rec.lno) := -1;
              tax_rate_tab(rec.lno) :=  -1;
              Tax_Amt_Tab(rec.lno)  := 0;
              tax_target_tab(rec.lno) := 0;
            END IF;

           IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
              P1(rec.lno) := -1;
              P2(rec.lno) := -1;
              P3(rec.lno) := -1;
              P4(rec.lno) := -1;
              P5(rec.lno) := -1;
              P6(rec.lno) := -1;
              P7(rec.lno) := -1;
              P8(rec.lno) := -1;
              P9(rec.lno) := -1;
              P10(rec.lno) := -1;

              tax_rate_tab(rec.lno) :=  -1;
              Tax_Amt_Tab(rec.lno)  := 0;
              tax_target_tab(rec.lno) := 0;

           END IF;
           Rounding_factor_tab(rec.lno) := rec.rnd;
           Tax_Type_Tab(rec.lno) := rec.tax_type_val;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_amt_rate_tax_tab(rec.lno) :=0;
      lt_tax_amt_non_rate_tab(rec.lno) :=0; -- tax inclusive
      lt_base_tax_amt_tab(rec.lno)     := 0;
      ---------------------------------------------------

           IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 THEN
              tax_rate_tab(rec.lno) :=  -1;
              -- Start of addition by Srihari and Gaurav on 11-JUL-2000
              IF rec.tax_type_val = 1 THEN
                  /*Tax_Amt_Tab(rec.lno)    := v_excise_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax 2008/01/15
                  lt_tax_amt_non_rate_tab(rec.lno) := v_excise_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/15
                  tax_target_tab(rec.lno) := v_excise_duty_rate;
              ELSIF rec.tax_type_val = 3 then
                 /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax 2008/01/15
                 lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/15
                 tax_target_tab(rec.lno) := ln_cess_duty_rate;
        ELSIF rec.tax_type_val = 4 THEN                 --  bug 6470006
     /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax 2008/01/15
     lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate; --Add by Kevin Cheng for inclusive tax 2008/01/15
     tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;
              ELSE
                /*tax_amt_tab(rec.lno)    := (p_line_quantity / v_original_quantity) * rec.tax_amount;*/ --Comment out by Kevin Cheng for inclusive tax 2008/01/15
                lt_tax_amt_non_rate_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount; --Add by Kevin Cheng for inclusive tax 2008/01/15
                tax_target_tab(rec.lno) := (p_line_quantity / v_original_quantity) * rec.tax_amount;

                -- End of bug 3611625
              END IF;
              lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax 2008/01/15
           ELSE
              IF rec.tax_type_val NOT IN  (1,3,4) THEN  -- bug  6470006
                 Tax_Amt_Tab(rec.lno)  := 0;
              END IF;
           END IF;


      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      lt_tax_rate_per_rupee(rec.lno) := NVL(rec.tax_rate,0)/100;
      ln_total_tax_per_rupee         := 0;
      lt_inclu_tax_tab(rec.lno)      := NVL(rec.inclusive_tax_flag,'N');

      IF rec.tax_rate is null THEN
        lt_tax_rate_zero_tab(rec.lno) := 0;
      ELSIF rec.tax_rate = 0 THEN
        lt_tax_rate_zero_tab(rec.lno) := -9999;
      ELSE
        lt_tax_rate_zero_tab(rec.lno) := rec.tax_rate;
      END IF;
      ---------------------------------------------------
           --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
           /*IF rec.Valid_Date is NULL Or rec.Valid_Date >= Sysdate THEN
              End_Date_Tab(rec.lno) := 1;
           ELSE
              End_Date_Tab(rec.lno) := 0;
           END IF; */

           row_count := row_count + 1;
           IF tax_rate_tab(rec.lno) = 0 THEN
              FOR uom_cls IN uom_class_cur(v_unit_code, rec.uom) LOOP
                  INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, v_inventory_item_id, v_conversion_rate);
                  IF nvl(v_conversion_rate, 0) <= 0 THEN
                     INV_CONVERT.inv_um_conversion(v_unit_code, rec.uom, 0, v_conversion_rate);
                     IF nvl(v_conversion_rate, 0) <= 0  THEN
                        v_conversion_rate := 0;
                     END IF;
                  END IF;
                  IF ( excise_flag_set ) AND ( rec.tax_type_val = 1 ) THEN
                    /*tax_amt_tab(rec.lno) := 0;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
                    lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
                  ELSIF rec.tax_type_val = 3 then
                    /*Tax_Amt_Tab(rec.lno)    := ln_cess_duty_rate; */ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
                    lt_tax_amt_non_rate_tab(rec.lno) := ln_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
                    tax_target_tab(rec.lno) := ln_cess_duty_rate;
                  ELSIF rec.tax_type_val = 4 then
        /*Tax_Amt_Tab(rec.lno)    := ln_sh_cess_duty_rate;*/ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
        lt_tax_amt_non_rate_tab(rec.lno) := ln_sh_cess_duty_rate; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
              tax_target_tab(rec.lno) := ln_sh_cess_duty_rate;
      ELSE
                   --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
                   /*tax_amt_tab(rec.lno) := ROUND( nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity, rounding_factor_tab(rec.lno) ); */
                   --Add by Kevin Cheng for inclusive tax Dec 12, 2007
                   lt_tax_amt_non_rate_tab(rec.lno) := /*ROUND( */nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity/*, rounding_factor_tab(rec.lno) )*/; --Modified by Kevin Cheng for bug#6936009 April 02, 2008
                  END IF;

                 IF v_exempt_flag = 'Y' AND rec.tax_type_val = 1 THEN
                   /*tax_amt_tab( rec.lno ) := 0; */ --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
                   lt_tax_amt_non_rate_tab(rec.lno) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
                 END IF;
                 lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); --Add by Kevin Cheng for inclusive tax Dec 12, 2007
                 tax_rate_tab( rec.lno ) := -1;
                 tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
              END LOOP;
           END IF;

      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      ---------------------------------------------------
      IF rec.Valid_Date is NULL OR rec.Valid_Date >= SYSDATE
      THEN
         End_Date_Tab(rec.lno) := 1;
      ELSE
         End_Date_Tab(rec.lno) := 0;
         tax_amt_tab(rec.lno)  := 0;
      END IF;
      ---------------------------------------------------

           IF rec.tax_type_val = 1 THEN
              excise_flag_set := TRUE;
           END IF;
        END LOOP;
  -- ended lines bug 6030615


  END IF;
-----------------------------------------------------------------------------------------------------
  bsln_amt := v_selling_price* p_line_quantity;

  --Add by Kevin Cheng for inclusive tax Dec 12, 2007
  ----------------------------------------------------
  IF ln_vat_assessable_value_tot <> ln_line_amount
  THEN
    ln_vat_assessable_value_tmp := ln_vat_assessable_value_tot;
  ELSE
    ln_vat_assessable_value_tmp := 1;
  END IF;


  if ln_assessable_value_tot <> ln_line_amount
  THEN
    ln_assessable_value_tmp := ln_assessable_value_tot;
  ELSE
    ln_assessable_value_tmp := 1;
  END IF;
  --start additions for bug#8887871
  IF ln_vat_reversal_value_tot <> ln_line_amount
  THEN
    ln_vat_reversal_value_tmp := ln_vat_reversal_value_tot;
  ELSE
    ln_vat_reversal_value_tmp := 1;
  END IF;

  ----------------------------------------------------

  FOR I in 1..row_count
  LOOP
    --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
    /*IF p1(I) < I and p1(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
    ELSIF p1(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p2(I) < I and p2(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
    ELSIF p2(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p3(I) < I and p3(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
    ELSIF p3(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p4(I) < I and p4(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
    ELSIF p4(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p5(I) < I and p5(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
    ELSIF p5(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) < I and p6(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
    ELSIF p6(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p7(I) < I and p7(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
    ELSIF p7(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p8(I) < I and p8(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
    ELSIF p8(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p9(I) < I and p9(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
    ELSIF p9(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
    IF p10(I) < I and p10(I) not in (-1,0) then
       vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
    ELSIF p10(I) = 0 then
       vamt  := vamt + bsln_amt;
    END IF;
-- END BUG 5228046


     IF tax_rate_tab(I) <> -1 THEN
       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       IF END_date_tab(I) = 0 then
          tax_amt_tab(I) := 0;
       ELSIF END_date_tab(I) = 1 then
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
       END IF;
       -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
     END IF;
    vamt      := 0;
    v_tax_amt := 0;*/
    --Add by Kevin Cheng for inclusive tax Dec 12, 2007
    --------------------------------------------------------------------------------
    IF end_date_tab( I ) <> 0
    THEN
      IF tax_type_tab(I) = 1
      THEN
        IF ln_assessable_value_tmp = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_assessable_value_tmp;
        END IF;
      ELSIF tax_type_tab(I)=5  --IN (5, 6)   bug 8887871
      THEN --IF tax_type_tab(I) = 1   THEN
        IF ln_vat_assessable_value_tmp = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_assessable_value_tmp;
        END IF;
  -- start additions for  bug 8887871
   ELSIF tax_type_tab(I)=6
      THEN --IF tax_type_tab(I) = 1   THEN
        IF ln_vat_reversal_value_tmp = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_reversal_value_tmp;
        END IF;
      ELSIF tax_type_tab(I) IN (3, 4)
      THEN  --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 0;
        ln_bsln_amt_nr := 0;
      ELSE --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 1;
        ln_bsln_amt_nr := 0;
      END IF; --IF tax_type_tab(I) = 1   THEN

      IF tax_rate_tab(I) <> 0
      THEN
        IF p1(I) < I and p1(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
        ELSIF p1(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p2(I) < I and p2(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
        ELSIF p2(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p3(I) < I and p3(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
        ELSIF p3(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p4(I) < I and p4(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
        ELSIF p4(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p5(I) < I and p5(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
        ELSIF p5(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;

    -- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046

        IF p6(I) < I and p6(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
        ELSIF p6(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p7(I) < I and p7(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
        ELSIF p7(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p8(I) < I and p8(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
        ELSIF p8(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p9(I) < I and p9(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
        ELSIF p9(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
        IF p10(I) < I and p10(I) not in (-1,0) then
          vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
        ELSIF p10(I) = 0 then
          vamt  := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr;
        END IF;
    -- END BUG 5228046

        IF tax_rate_tab(I) <> -1 THEN
          v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
          IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
          ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
          END IF;
          -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        END IF;
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
        lt_base_tax_amt_tab(I) := vamt;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
        base_tax_amount_nr_tab(I):=ln_vamt_nr;---added for bug#9794835
        vamt := 0;
        v_tax_amt := 0;
        ln_tax_amt_nr := 0;
        ln_vamt_nr := 0;
      END IF;
    ELSE --IF end_date_tab(I) <> 0 THEN
      tax_amt_tab(I) := 0;
      lt_base_tax_amt_tab(I) := 0;
    END IF;
    --------------------------------------------------------------------------------
  END LOOP;
  FOR I in 1..row_count
  LOOP
    --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
    /*IF p1(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
    END IF;
    IF p2(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
    END IF;
    IF p3(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
    END IF;
    IF p4(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
    END IF;
    IF p5(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
    END IF;
-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
    END IF;
    IF p7(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
    END IF;
    IF p8(I) > I  then
       vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
    END IF;
    IF p9(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
    END IF;
    IF p10(I) > I then
       vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
    END IF;

-- END BUG 5228046


     IF tax_rate_tab(I) <> -1 THEN
       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       IF END_date_tab(I) = 0 then
          tax_amt_tab(I) := 0;
       ELSIF END_date_tab(I) = 1 then
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
       END IF;
        -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
     END IF;
    vamt      := 0;
    v_tax_amt := 0;*/
    --Add by Kevin Cheng for inclusive tax Dec 12, 2007
    ----------------------------------------------------------------------
    IF end_date_tab( I ) <> 0 THEN
      IF tax_rate_tab(I) <> 0 THEN
        IF p1(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p1(I)),0);
        END IF;
        IF p2(I) > I  then
          vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p2(I)),0);
        END IF;
        IF p3(I) > I  then
          vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p3(I)),0);
        END IF;
        IF p4(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p4(I)),0);
        END IF;
        IF p5(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p5(I)),0);
        END IF;
    -- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046

        IF p6(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p6(I)),0);
        END IF;
        IF p7(I) > I  then
          vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p7(I)),0);
        END IF;
        IF p8(I) > I  then
          vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p8(I)),0);
        END IF;
        IF p9(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p9(I)),0);
        END IF;
        IF p10(I) > I then
          vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p10(I)),0);
        END IF;

    -- END BUG 5228046

        IF tax_rate_tab(I) <> -1 THEN
          v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
          IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
          ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
          END IF;
          -- tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        END IF;
        lt_base_tax_amt_tab(I) := lt_base_tax_amt_tab(I) + vamt; --9794835
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100)); -- tax inclusive
        IF vamt <> 0 THEN
          lt_base_tax_amt_tab(I) := lt_base_tax_amt_tab(I) + vamt;
        END IF;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr ; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) :=  tax_amt_tab(I);
         base_tax_amount_nr_tab(I):=ln_vamt_nr;---added for bug#9794835
        vamt := 0;
        ln_vamt_nr := 0 ;
        v_tax_amt := 0;
        ln_tax_amt_nr := 0 ;
      END IF; --IF tax_rate_tab(I) <> 0 THEN
    ELSE --IF end_date_tab( I ) <> 0 THEN
      lt_base_tax_amt_tab(I) := vamt;
      tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab( I ) <> 0 THEN
    ----------------------------------------------------------------------
  END LOOP;

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;
    ln_vamt_nr := 0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    ln_tax_amt_nr:=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    FOR i IN 1 .. row_count LOOP
         /*
    || rallamse bug#5068418
    || The below if condition is for all taxes which comply as :
    || tax_rate_tab <> 0    =>   consider discounts also
    || adhoc_flag_tab = 'N' =>   for non-adhoc taxes only
    || tax_rate_tab(i) = -1 and tax_type_tab(i) IN (1,3)  => for Excise and CVD considering cess also
    */
    /*Modified condition "tax_rate_tab( i ) <> 0" to "tax_rate_tab( i ) NOT IN (0,-1)" for bug# 6487182*/
      --Comment out by Kevin Cheng for inclusive tax Dec 12, 2007
      /*IF tax_rate_tab( i ) NOT IN (0,-1) AND End_Date_Tab(I) <> 0 AND adhoc_flag_tab(i) = 'N' AND NOT ( tax_rate_tab(i) = -1 AND tax_type_tab(i) IN (1,3,4) ) THEN  \* Added for bug 5091874 *\\*Bug 5989740 bduvarag*\
         v_amt := bsln_amt;
         IF p1( i ) <> -1 THEN
            IF p1( i ) <> 0 THEN
               vamt := vamt + tax_amt_tab( p1( I ) );
            ELSIF p1(i) = 0 THEN
               vamt := vamt + v_amt;
            END IF;
         END IF;
         IF p2( i ) <> -1 THEN
           IF p2( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p2( I ) );
           ELSIF p2(i) = 0 THEN
             vamt := vamt + v_amt;
           END IF;
      END IF;
         IF p3( i ) <> -1 THEN
      IF p3( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p3( I ) );
      ELSIF p3(i) = 0 THEN
         vamt := vamt + v_amt;
      END IF;
    END IF;
         IF p4( i ) <> -1 THEN
      IF p4( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p4( i ) );
      ELSIF p4(i) = 0 THEN
         vamt := vamt + v_amt;
      END IF;
    END IF;
         IF p5( i ) <> -1 THEN
      IF p5( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p5( i ) );
      ELSIF p5(i) = 0 THEN
         vamt := vamt + v_amt;
      END IF;
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6( i ) <> -1 THEN
             IF p6( i ) <> 0 THEN
                vamt := vamt + tax_amt_tab( p6( I ) );
             ELSIF p6(i) = 0 THEN
               vamt := vamt + v_amt;
             END IF;
         END IF;
         IF p7( i ) <> -1 THEN
            IF p7( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p7( I ) );
            ELSIF p7(i) = 0 THEN
              vamt := vamt + v_amt;
            END IF;
         END IF;
         IF p8( i ) <> -1 THEN
            IF p8( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p8( I ) );
           ELSIF p8(i) = 0 THEN
              vamt := vamt + v_amt;
           END IF;
         END IF;
         IF p9( i ) <> -1 THEN
            IF p9( i ) <> 0 THEN
               vamt := vamt + tax_amt_tab( p9( i ) );
            ELSIF p9(i) = 0 THEN
               vamt := vamt + v_amt;
           END IF;
         END IF;
         IF p10( i ) <> -1 THEN
           IF p10( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p10( i ) );
           ELSIF p10(i) = 0 THEN
              vamt := vamt + v_amt;
           END IF;
        END IF;
-- END BUG 5228046



       tax_target_tab(I) := vamt;
       IF counter = max_iter THEN
           v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), rounding_factor_tab(I) );
       ELSE
           v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
       END IF;
       tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      ELSIF tax_rate_tab( i ) = -1 AND End_Date_Tab(I) <> 0  THEN
           NULL;
      ELSE
        tax_amt_tab(I) := 0;
        tax_target_tab(I) := 0;
      END IF;*/
      --Add by Kevin Cheng for inclusive tax Dec 12, 2007
      -----------------------------------------------------------------------
      IF ( tax_rate_tab( i ) <> 0  OR  lt_tax_rate_zero_tab(I) = -9999 ) AND
           end_date_tab( I ) <> 0
      THEN
        IF tax_type_tab( I ) = 1
        THEN -- tax inclusive
          IF ln_assessable_value_tmp = 1 THEN
            v_amt := 1;
            ln_bsln_amt_nr :=0;
          ELSE
            v_amt :=0;
            ln_bsln_amt_nr :=ln_assessable_value_tmp;
          END IF;
        ELSIF tax_type_tab(I)=5  --IN (5, 6)   bug 8887871
      THEN --IF tax_type_tab(I) = 1   THEN
        IF ln_vat_assessable_value_tmp = 1 THEN
        --  bsln_amt := 1; commented for bug#9794835
         v_amt := 1; --added for bug#9794835
          ln_bsln_amt_nr := 0;
        ELSE
          --bsln_amt := 0; commented for bug#9794835
           v_amt := 0; --added for bug#9794835
          ln_bsln_amt_nr := ln_vat_assessable_value_tmp;
        END IF;
  -- start additions for  bug 8887871
   ELSIF tax_type_tab(I)=6
      THEN --IF tax_type_tab(I) = 1   THEN
        IF ln_vat_reversal_value_tmp = 1 THEN
       --  bsln_amt := 1; commented for bug#9794835
         v_amt := 1; --added for bug#9794835
          ln_bsln_amt_nr := 0;
        ELSE
           --bsln_amt := 0; commented for bug#9794835
           v_amt := 0; --added for bug#9794835
          ln_bsln_amt_nr := ln_vat_reversal_value_tmp;
        END IF;
        ELSIF  tax_type_tab(I) IN (3, 4) THEN  --IF tax_type_tab( I ) = 1 THEN
           v_amt := 0;
           ln_bsln_amt_nr := 0;
        ELSE --IF tax_type_tab( I ) = 1 THEN
          v_amt := 1;
          ln_bsln_amt_nr := 0;
        END IF; --IF tax_type_tab( I ) = 1 THEN

        IF tax_rate_tab( i ) NOT IN (0,-1)
          AND End_Date_Tab(I) <> 0
          AND adhoc_flag_tab(i) = 'N'
          AND NOT ( tax_rate_tab(i) = -1 AND tax_type_tab(i) IN (1,3,4) )
        THEN  /* Added for bug 5091874 *//*Bug 5989740 bduvarag*/
          /*v_amt := bsln_amt;*/--Comment out by Kevin Cheng for inclusive tax Jan 15, 2008
          IF p1( i ) <> -1 THEN
            IF p1( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p1( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
            ELSIF p1(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p2( i ) <> -1 THEN
            IF p2( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p2( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
            ELSIF p2(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p3( i ) <> -1 THEN
            IF p3( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p3( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
            ELSIF p3(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p4( i ) <> -1 THEN
            IF p4( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p4( i ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
            ELSIF p4(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p5( i ) <> -1 THEN
            IF p5( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p5( i ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
            ELSIF p5(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;

  -- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  -- START BUG 5228046

          IF p6( i ) <> -1 THEN
            IF p6( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p6( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
            ELSIF p6(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p7( i ) <> -1 THEN
            IF p7( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p7( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
            ELSIF p7(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p8( i ) <> -1 THEN
            IF p8( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p8( I ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
            ELSIF p8(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p9( i ) <> -1 THEN
            IF p9( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p9( i ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
            ELSIF p9(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
          IF p10( i ) <> -1 THEN
            IF p10( i ) <> 0 THEN
              vamt := vamt + tax_amt_tab( p10( i ) );
              ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
            ELSIF p10(i) = 0 THEN
              vamt := vamt + v_amt;
              ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
            END IF;
          END IF;
  -- END BUG 5228046

          lt_base_tax_amt_tab(I) := vamt;
          tax_target_tab(I) := vamt;
          ln_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
          ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100)); --Add by Kevin Cheng for inclusive tax Jan 08, 2008
          --Comment out by Kevin Cheng for bug#6936009 April 02, 2008
          /*IF counter = max_iter THEN
            v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), rounding_factor_tab(I) );
          ELSE*/
            v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
          /*END IF;*/--Comment out by Kevin Cheng for bug#6936009 April 02, 2008
          tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
        ELSIF tax_rate_tab( i ) = -1 AND End_Date_Tab(I) <> 0  THEN
          --NULL; --Comment out by Kevin Cheng for bug#6915049 Mar 26, 2008
          ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i); --Add by Kevin Cheng for bug#6915049 Mar 26, 2008
        ELSE
          tax_amt_tab(I) := 0;
          tax_target_tab(I) := 0;
        END IF;
      ELSIF tax_rate_tab(I) = 0 THEN --IF ( tax_rate_tab( i ) <> 0 OR tax_rate_zero_tab(I) = -9999) AND end_date_tab( I ) <> 0 THEN
        lt_base_tax_amt_tab(I) := tax_amt_tab(i);
        v_tax_amt := tax_amt_tab( i );
        ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i);
        tax_target_tab(I) := v_tax_amt;
      ELSIF end_date_tab( I ) = 0 THEN --IF ( tax_rate_tab( i ) <> 0 OR tax_rate_zero_tab(I) = -9999) AND end_date_tab( I ) <> 0 THEN
        tax_amt_tab(I) := 0;
        lt_base_tax_amt_tab(I) := 0;
        tax_target_tab(I) := 0;
      END IF; --IF ( tax_rate_tab( i ) <> 0 OR tax_rate_zero_tab(I) = -9999) AND end_date_tab( I ) <> 0 THEN

      tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
      lt_tax_amt_non_rate_tab(I) := ln_tax_amt_nr;
      lt_func_tax_amt_tab(I) := NVL(ln_func_tax_amt,0);
       base_tax_amount_nr_tab(I):=ln_vamt_nr;---added for bug#9794835
      -----------------------------------------------------------------------
      IF counter = max_iter THEN
       IF END_date_tab(I) = 0 THEN
           tax_amt_tab(I) := 0;
           lt_func_tax_amt_tab(i) := 0; --Add by Kevin Cheng for inclusive tax Dec 12, 2007
       END IF;
      END IF;

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
      ln_func_tax_amt := 0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
      ln_vamt_nr :=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
      ln_tax_amt_nr:=0;-- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    END LOOP;
  END LOOP;

  --Added by Kevin Cheng for inclusive tax Dec 13, 2007
  ---------------------------------------------------------------------------------------
  FOR I IN 1 .. ROW_COUNT
  LOOP
    IF lt_inclu_tax_tab(I) = 'Y' THEN
      ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
      ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
    END IF;
  END LOOP; --FOR I IN 1 .. ROW_COUNT

  ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

  IF ln_total_tax_per_rupee <> 0
  THEN
     ln_exclusive_price := (NVL(ln_line_amount,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
  END IF;

  FOR i in 1 .. row_count
  LOOP
--  insert into jai_debug  values('base_tax_amount_nr_tab(I) ',base_tax_amount_nr_tab(I));9794835
    tax_amt_tab(i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
    tax_amt_tab(I) := round(tax_amt_tab(I)  ,rounding_factor_tab(I));
   lt_base_tax_amt_tab(I):= ln_exclusive_price * lt_base_tax_amt_tab(I)
                           + base_tax_amount_nr_tab(I);  --bug#9794853
  END LOOP; --FOR i in 1 .. row_count
  --------------------------------------------------------------------------------------------------------

  FOR i IN 1 .. row_count LOOP
    IF p_order_invoice = 'O' THEN
      OPEN  Fetch_Totals_Cur( i );
      FETCH Fetch_Totals_Cur INTO v_cum_amount;
      CLOSE Fetch_Totals_Cur;
      IF p_line_quantity = 0 THEN
        DELETE JAI_CMN_MATCH_TAXES
         WHERE Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;
      ELSE
    --   insert into jai_debug  values('before update base_tax_amount_nr_tab(I) ',base_tax_amount_nr_tab(I)); 9794835
        UPDATE JAI_CMN_MATCH_TAXES
          SET  Tax_Amount = tax_amt_tab(i),
               --  Base_Tax_Amount = tax_target_tab(i),
             Base_Tax_Amount = lt_base_tax_amt_tab(i) --bug#9794853
               ,Func_Tax_Amount = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 ),
               Total_Tax_Amount = v_cum_amount
        WHERE  Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;
      END IF;
    ELSIF p_order_invoice = 'I' THEN
      OPEN  Fetch_Totals_AR_Cur( i );
      FETCH Fetch_Totals_AR_Cur INTO v_cum_amount;
      CLOSE Fetch_Totals_AR_Cur;
      IF p_line_quantity = 0 THEN
        DELETE JAI_CMN_MATCH_TAXES
         WHERE Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;
      ELSE
        UPDATE JAI_CMN_MATCH_TAXES
          SET  Tax_Amount = tax_amt_tab(i),
             --  Base_Tax_Amount = tax_target_tab(i),
             Base_Tax_Amount = lt_base_tax_amt_tab(i) --bug#9794853
               ,Func_Tax_Amount = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 ),
               Total_Tax_Amount = v_cum_amount
        WHERE  Ref_Line_Id = p_ref_line_id
          AND  nvl(Subinventory,'###') = nvl(p_subinventory,'###')
          AND  receipt_id = p_receipt_id
          AND  Tax_Line_No = i;
      END IF;

      IF p_line_quantity <> 0 THEN
        FOR Rec IN Fetch_Total_AR_Cur( i ) LOOP
          UPDATE  JAI_AR_TRX_TAX_LINES
             SET  Tax_Amount = rec.tax_amount,
                  Base_Tax_Amount = rec.base_tax_amount,
                  Func_Tax_Amount = rec.func_tax_amount
           WHERE  link_to_cust_trx_line_id = p_ref_line_id
             AND  Tax_Line_No = i;
        END LOOP;
      ELSE
        UPDATE  JAI_AR_TRX_TAX_LINES
           SET  Tax_Amount = tax_amt_tab(i),
                 --  Base_Tax_Amount = tax_target_tab(i),
             Base_Tax_Amount = lt_base_tax_amt_tab(i) --bug#9794853
                ,Func_Tax_Amount = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 )
         WHERE  link_to_cust_trx_line_id = p_ref_line_id
           AND  Tax_Line_No = i;
      END IF;

    ELSIF p_order_invoice = 'X' THEN   -- Interorg bug 6030615

  UPDATE  Jai_cmn_document_Taxes
      SET  Tax_Amt = nvl(tax_amt,0)+tax_amt_tab(i),   --added  nvl(tax_amt,0) for bug#8445390
     Func_Tax_Amt = nvl(Func_Tax_Amt,0)+tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 ) --added  nvl(Func_Tax_Amt,0) for bug#8445390
    WHERE  source_doc_line_id = p_ref_line_id
    AND    source_doc_type = 'INTERORG_XFER'
    AND    Tax_Line_No = i;

    UPDATE Jai_cmn_match_Taxes
    SET    Tax_Amount = tax_amt_tab(i),
     --  Base_Tax_Amount = tax_target_tab(i),
             Base_Tax_Amount = lt_base_tax_amt_tab(i) --bug#9794853
     ,Func_Tax_Amount = tax_amt_tab(i) * NVL( p_curr_conv_factor, 1 )
    WHERE  Ref_Line_Id = p_ref_line_id
    AND  receipt_id = p_receipt_id
    AND  Tax_Line_No = i;
            -- Interorg bug ended 6030615
    END IF;
  END LOOP;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END om_default_taxes;


END jai_cmn_rcv_matching_pkg ;

/

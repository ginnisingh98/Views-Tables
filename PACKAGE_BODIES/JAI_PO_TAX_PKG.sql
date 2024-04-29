--------------------------------------------------------
--  DDL for Package Body JAI_PO_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_TAX_PKG" AS
/* $Header: jai_po_tax.plb 120.36.12010000.7 2010/02/05 10:35:19 srjayara ship $ */

 /* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_po_tax -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.3
               Ramananda for bug#4428980. Removal of SQL LITERALs is done

26-Jul-2005    Aiyer for the bug 4517919,File Version 120.2
                Removed the reference to dbms_support.start_trace and dbms_support.stop_trace and replaced it with
    execute immediate alter session SET EVENTS ''10046 trace name context forever, level 4''';

27-Jul-2005    Bug 4516508. Added by Lakshmi Gopalsami version 120.3
               Wrong calculation of tax amount when values added tax is included
               during tax defaultation in PO.
               Issue in Procedure Ja_In_Po_Case2.
               The calculation of vat assesseble value was wrong. The vat amount is
               now multiplied with the quantity if the function
               jai_general_pkg.ja_in_vat_assessable_value
               returns a not null value. Else the line amount is assigned as
               the VAT amount.
28-Jul-2005    Bug 4520049. Added by Lakshmi Gopalsami Version 120.4
               Added nvl for v_temp_price while calling
               jai_general_pkg.ja_in_vat_assessable_value
               in procedure copy_agreement_Taxes

         Dependency Due to this bug :-
         None

31/10/2006   SACSETHI for bug 5228046, File version 120.7
             1.  Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement , Tax Precedence , BOE ).
                 This bug has datamodel and spec changes.

             2.  Forward porting of bug 5219225

13-April-2007   ssawant for bug 5989740 ,File version 120.11
                Forward porting Budget07-08 changes of handling secondary and
	        Higher Secondary Education Cess from 11.5( bug no 5907436) to R12 (bug no 5989740).
		Changes were done for following files
		ja_in_po_default_taxes_pkg.sql ;
		ja_in_po_calc_tax_p.sql;

 18-jun-2007    sacsethi for bug 6134628 , file version 120.14

		TAXES ARE NOT DEFAULTING FROM BPO TO RELEASES

		Solution - Cursor Fetch_Taxes_Cur is changed
24-Aug-2007  iProcurement forward porting bug #6066485

 11-Sep-2007    For Bug 6137011
                 For UOM tax lines tax amount is recalculated when currency code
                 is changed.  --pramasub

18-Sep-2007  iProcurement : bug # 6066485
               issue : Currency conversion is not happening for Receipt taxes
               fix : Compare if the line currency and tax currency are different
                     then apply the conversion.

17-Dec-2007  Kevin Cheng   Update the logic for inclusive tax calculation

15-Jan-2008  Kevin Cheng   Update for Retroactive Price Enhancement
22-Jan-2008  Eric Ma   Update pv_called_from,lv_tax_type,lv_third_party_flag
23-Jan-2008   rchandan for bug#6766561 . File Version 120.31
 	               Issue : INCORRECT TAX CALCULATION ON BLANKET PO RELEASES
 	                 Fix : When VAT assessable value is not defined then line amount should be used
 	                       as VAt assessable during tax calculation for VAT type of taxes.
 	                       This was not happening. So added the code for this.
                              This change is made to merge the fix made in version 120.29 for bug#6685406
22-Jan-2008  Eric Ma    Update cursor of get_rcv_line_for_retro to fix a bug
15-Feb-2008  Kevin Cheng   Modify code for bug 6816062.
                           reset non rate tax amount for ad hoc tax in the third calculation loop.
26-Feb-2008  Kevin Cheng   Modify code for bug 6838743.
                           Change variable v_tax_amt and vamt definition.
                           Remove precision restriction for these temp
                           variable, so the final result precision will
                           not be affected by them.
29-Feb-2008  Kevin Cheng   Modify code for bug 6849952.
                           reset non rate tax amount for ad hoc tax in the third calculation loop.


10-Nov-2008  Bug 7436368  File version 120.36.12010000.3
             Issue : Taxes are not defaulted from catalog quotation to PO even after running
	     the concurrent "India - Concurrent request for defaulting taxes in PO when linked
	     with Quotation".
	     Reason: In procedure copy_quot_taxes, the where clause of cursor tax_cur was
	     changed from "nvl(a.line_location_id,-999)=v_quot_line_loc_id" to
	     "a.line_location_id=v_quot_line_loc_id" for removing SQL literals. But in
	     case of quotations with no price breaks, the line_location_id would be null
	     and this condtion would fail. Because of this taxes will not get copied.
	     Fix   : The condition was modified as follows, to handle the case:
	     ((a.line_location_id IS NULL AND v_quot_line_loc_id=-999) OR (a.line_location_id = v_quot_line_loc_id))

6-FEB-2009 Changes by nprashar for bug 7694945, changes in procedure Copy Agreement Taxes.

18-May-2009  Changes by nprashar, FP the changes from bug  8470991 for R12 bug 8478826. Change in procedure Copy_agreement_taxes.

5-Feb-2010  Bug 9307152 File version 120.36.12010000.7 / 120.42
            Issue - Tax amounts are null for the taxes defaulted on to requisition from Blanket PA and there is no applicable
            price break.
            Cause - Line location id is null for such cases, so no rows are fetched by c_po_line_location_taxes cursor of
            calc_tax procedure, and calculation is never done.
            Fix - Re-introduced the nvl() function for the line_location_id filter, which was wrongly removed when code
            was modified to eliminate SQL literals.

 --------------------------------------------------------------------------------------*/

PROCEDURE calculate_tax(
    p_type IN VARCHAR2,
    p_header_id NUMBER,
    P_line_id NUMBER,
    p_line_loc_id IN NUMBER,
    p_line_quantity IN NUMBER,
    p_price IN NUMBER,
    p_line_uom_code IN VARCHAR2,
    p_tax_amount IN OUT NOCOPY NUMBER,
    p_assessable_value IN NUMBER DEFAULT NULL,
    p_vat_assess_value IN NUMBER,  -- Ravi for VAT
    p_item_id IN NUMBER DEFAULT NULL,
    p_conv_rate IN NUMBER DEFAULT NULL
   ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/10
   ,pv_called_from         IN VARCHAR2 DEFAULT NULL--Added by Eric Ma for Retroactive Price 2008/01/11
  ) IS

  --  Line Location_Id is passed instead of p_header_id; Src_Ship_Id is passed in p_line_loc_id
  --  For Requisition from Blanket PO, Requisition Line Id is passed in place of p_header_id, Currency in place of UOM.


-- Date 02/11/2006 Bug 5228046 added by SACSETHI
   --TYPE Num_Tab IS TABLE OF NUMBER(25,4) INDEX BY BINARY_INTEGER;
   --TYPE Tax_Amt_Num_Tab IS TABLE OF NUMBER(25,4) INDEX BY BINARY_INTEGER;

    TYPE Num_Tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE Tax_Amt_Num_Tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE currency_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE adhoc_flag_tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER; -- added by subbu on 08-nov-01

    debug VARCHAR2(1); --File.Sql.35 Cbabu  := 'Y'; --debug statement added by cbabu
    p1        num_tab;
    p2        num_tab;
    p3        num_tab;
    p4        num_tab;
    p5        num_tab;
    -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    p6        num_tab;
    p7        num_tab;
    p8        num_tab;
    p9        num_tab;
    p10       num_tab;

    rnd_factor            NUM_TAB;
    p_inventory_item_id   NUMBER;
    tax_rate_tab          NUM_TAB;
    tax_type_tab          NUM_TAB;
    end_date_tab          NUM_TAB;
    tax_amt_tab           TAX_AMT_NUM_TAB;
    tax_target_tab        TAX_AMT_NUM_TAB;
    curr_tab              CURRENCY_TAB;
    adhoc_tab             ADHOC_FLAG_TAB; -- added by subbu on 08-nov-01
    v_amt                 NUMBER;
    bsln_amt              NUMBER; --File.Sql.35 Cbabu     := p_tax_amount;
    row_count             NUMBER; --File.Sql.35 Cbabu     := 0;


-- Date 01/11/2006 Bug 5228046 added by SACSETHI
    v_tax_amt     NUMBER  ;
    vamt          NUMBER  ;
    max_iter      NUMBER ; -- bug 5228046. Changed from 10 to 15
    v_conversion_rate   NUMBER;
    counter     NUMBER;
    conv_rate     NUMBER;
    v_rnd_factor          NUMBER;

    -- Only for Requisition_Blanket
    v_curr  VARCHAR2(30); --File.Sql.35 Cbabu   :=  p_line_uom_code;
    -- End.

    -- 6/05/02 cbabu bug2357371
    v_line_uom_code VARCHAR2(30); --File.Sql.35 Cbabu     := p_line_uom_code;

    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ----------------------------------------------------------
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
    lt_func_tax_amt_tab          TAX_AMT_NUM_TAB;
    ln_exclusive_price           NUMBER;
    ln_total_non_rate_tax        NUMBER := 0;
    ln_total_inclusive_factor    NUMBER;
    ln_bsln_amt_nr               NUMBER := 0;
    ln_currency_conv_factor      NUMBER;
    ln_tax_amt_nr                NUMBER(38,10) := 0;
    ln_func_tax_amt              NUMBER(38,10) := 0;
    ln_vamt_nr                   NUMBER(38,10) := 0;
    ln_excise_jb                 NUMBER;
    ln_total_tax_per_rupee       NUMBER;
    ln_assessable_value          NUMBER;
    ln_vat_assessable_value      NUMBER;
    ----------------------------------------------------------

    --Add by Eric Ma for Retro Active Pricing Update on Jan 11, 2008 ,Begin
    -----------------------------------------------------------------------
    CURSOR get_rcv_line_for_retro ( pn_tax_id in NUMBER)--changed by erif on Feb 1,2008
    IS
    SELECT
      tax_type
    , third_party_flag
    FROM
      jai_rcv_line_taxes
    WHERE  shipment_line_id = p_line_id  -- shipment line id
      AND  tax_id           = pn_tax_id ; --added by erif on Feb 1,2008

    lv_tax_type           jai_rcv_line_taxes.tax_type%TYPE;
    lv_third_party_flag   jai_rcv_line_taxes.third_party_flag%TYPE;
    -----------------------------------------------------------------------
    --Add by Eric Ma for Retro Active Pricing Update on Jan 11, 2008 ,End

    CURSOR Fetch_Item_Cur IS
      SELECT Item_Id
      FROM   Po_Lines_All
      WHERE  Po_Line_Id = p_line_id;

    -- 6/05/02 cbabu. added to fetch UOM_code in case if it is null. if this is null then we will get problems during quantity rate tax.
    -- 6/05/02 cbabu bug2357371
    CURSOR Fetch_line_uom_code IS
      SELECT Uom_Code
      FROM  po_lines_all plines, mtl_units_of_measure units
      WHERE plines.Po_Line_Id = p_line_id
      AND units.Unit_Of_Measure = plines.unit_meas_lookup_code;

    CURSOR fetch_rcv_line_currency is
    SELECT rt.currency_code
      FROM rcv_transactions     rt,
           rcv_shipment_lines   rcl
     WHERE rcl.shipment_header_id = p_header_id
       AND rcl.shipment_line_id = p_line_id
       AND rt.shipment_header_id = rcl.shipment_header_id
       AND rt.shipment_line_id = rcl.shipment_line_id
       AND rt.transaction_type = 'RECEIVE' ;

    lv_currency_code    rcv_transactions.currency_code%TYPE;

    -- in PR to PO / BPO to Brelease
    -- added B.adhoc_flag column in select statement
    /* Addded by LGOPALSA. Bug 4210102.
     * Added CVD and Excise education cess
     * */
  /* Bug 5094130. Added by Lakshmi Gopalsami
     Removed the PO_TAX_CUR cursor and added the record type
  */
  TYPE PO_TAX_CUR IS RECORD(
  LNo   JAI_PO_TAXES.TAX_LINE_NO%TYPE,
  P_1   JAI_PO_TAXES.PRECEDENCE_1%TYPE,
  P_2   JAI_PO_TAXES.PRECEDENCE_2%TYPE,
  P_3   JAI_PO_TAXES.PRECEDENCE_3%TYPE,
  P_4   JAI_PO_TAXES.PRECEDENCE_4%TYPE,
  P_5   JAI_PO_TAXES.PRECEDENCE_5%TYPE,
  /* bug 5094130. Added by Lakshmi Gopalsami
   * Included precedences 6 to 10
   */
  P_6   JAI_PO_TAXES.PRECEDENCE_6%TYPE,
  P_7   JAI_PO_TAXES.PRECEDENCE_7%TYPE,
  P_8   JAI_PO_TAXES.PRECEDENCE_8%TYPE,
  P_9   JAI_PO_TAXES.PRECEDENCE_9%TYPE,
  P_10    JAI_PO_TAXES.PRECEDENCE_10%TYPE,
  Tax_Id          JAI_PO_TAXES.TAX_ID%TYPE,
  Tax_type_val    NUMBER,
  Tax_rate        JAI_PO_TAXES.TAX_RATE%TYPE,
  Qty_Rate        JAI_PO_TAXES.QTY_RATE%TYPE,
  Uom_code        JAI_PO_TAXES.UOM%TYPE,
  Tax_Amount      JAI_PO_TAXES.TAX_AMOUNT%TYPE,
  Curr            JAI_PO_TAXES.CURRENCY%TYPE,
  Valid_Date      JAI_CMN_TAXES_ALL.END_DATE%TYPE,
  Rnd_factor      JAI_CMN_TAXES_ALL.ROUNDING_FACTOR%TYPE,
  Adhoc_flag      JAI_CMN_TAXES_ALL.ADHOC_FLAG%TYPE
  ,Inclusive_tax_flag    JAI_CMN_TAXES_ALL.Inclusive_Tax_Flag%TYPE --Add by Kevin Cheng for inclusive tax Dec 18, 2007
  );


    -- START, Vijay Shankar for Bug# 3190782
    TYPE tax_cur_type IS REF CURSOR RETURN PO_TAX_CUR;
    c_tax_cur TAX_CUR_TYPE;
    rec     c_tax_cur%ROWTYPE;
    -- END, Vijay Shankar for Bug# 3190782

--Added by Kevin Cheng for Retroactive Price 2008/01/11
--=====================================================
TYPE PO_TAX_RETRO_CUR IS RECORD(
  LNo   JAI_PO_TAXES.TAX_LINE_NO%TYPE,
  P_1   JAI_PO_TAXES.PRECEDENCE_1%TYPE,
  P_2   JAI_PO_TAXES.PRECEDENCE_2%TYPE,
  P_3   JAI_PO_TAXES.PRECEDENCE_3%TYPE,
  P_4   JAI_PO_TAXES.PRECEDENCE_4%TYPE,
  P_5   JAI_PO_TAXES.PRECEDENCE_5%TYPE,
  /* bug 5094130. Added by Lakshmi Gopalsami
   * Included precedences 6 to 10
   */
  P_6   JAI_PO_TAXES.PRECEDENCE_6%TYPE,
  P_7   JAI_PO_TAXES.PRECEDENCE_7%TYPE,
  P_8   JAI_PO_TAXES.PRECEDENCE_8%TYPE,
  P_9   JAI_PO_TAXES.PRECEDENCE_9%TYPE,
  P_10    JAI_PO_TAXES.PRECEDENCE_10%TYPE,
  Tax_Id          JAI_PO_TAXES.TAX_ID%TYPE,
  Tax_type_val    NUMBER,
  Tax_rate        JAI_PO_TAXES.TAX_RATE%TYPE,
  Qty_Rate        JAI_PO_TAXES.QTY_RATE%TYPE,
  Uom_code        JAI_PO_TAXES.UOM%TYPE,
  Tax_Amount      JAI_PO_TAXES.TAX_AMOUNT%TYPE,
  Curr            JAI_PO_TAXES.CURRENCY%TYPE,
  Valid_Date      JAI_CMN_TAXES_ALL.END_DATE%TYPE,
  Rnd_factor      JAI_CMN_TAXES_ALL.ROUNDING_FACTOR%TYPE,
  Adhoc_flag      JAI_CMN_TAXES_ALL.ADHOC_FLAG%TYPE,
  hdr_vendor_id   PO_HEADERS_ALL.Vendor_Id%TYPE,
  tax_vendor_id   JAI_PO_TAXES.Vendor_Id%TYPE
  );


    -- START, Vijay Shankar for Bug# 3190782
    TYPE tax_cur_retro_type IS REF CURSOR RETURN PO_TAX_RETRO_CUR;
    c_tax_retro_cur tax_cur_retro_type;
    rec_retro     c_tax_retro_cur%ROWTYPE;
    -- END, Vijay Shankar for Bug# 3190782

lv_tax_remain_flag        VARCHAR2(1);
lv_process_flag           VARCHAR2(10);
lv_process_message        VARCHAR2(2000);
--=====================================================

    Cursor req_adhoc_tax_amt(taxid number) is
      select A.tax_amount from JAI_PO_REQ_LINE_TAXES A, JAI_CMN_TAXES_ALL B
      where A.tax_id =  taxid
      AND requisition_line_id in(select requisition_line_id
        from po_req_distributions_all
        where distribution_id in (select req_distribution_id
          from po_distributions_all
          where po_header_id = p_header_id
          and po_line_id = p_line_id))
      and A.Tax_id = B.Tax_id
      and B.adhoc_flag = 'Y';

    v_adhoc_tax_amt number;
    v_adhoc_flag varchar2(1);
    v_qty_rate number;
    -- end of cursor added by subbu on 8-nov-01
    -- end of modifications by subbu on 7-nov-01 for considering adhoc taxes in PR to PO / BPO to Brelease

    CURSOR uom_class_cur(p_line_uom_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
      SELECT A.uom_class
      FROM mtl_units_of_measure A, mtl_units_of_measure B
      WHERE A.uom_code = p_line_uom_code
      AND B.uom_code = p_tax_line_uom_code
      AND A.uom_class = B.uom_class;

    CURSOR Fetch_Sum_Cur( linelocid IN NUMBER ) IS
      SELECT SUM( NVL( Tax_Amount, 0 ) )
      FROM   JAI_PO_TAXES
      WHERE  Line_Location_Id = linelocid      -- For Blanket Rel Line Loc Id is passed in place of header id.
      AND   Tax_Type <> jai_constants.tax_type_tds ; --'TDS'; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.calculate_tax';
  BEGIN

  /*------------------------------------------------------------------------------------------
   FILENAME: ja_in_cal_tax_p.sql

   CHANGE HISTORY:
  S.No      Date          Author and Details
  ------------------------------------------------------------------------------------------
  1.      23-Aug-02 Nagaraj.s for Bug2519359
                      The Adhoc Amounts were being picked up from requisitions earlier.
                      Hence, in case of an Standard PO created without an requisition
                      the adhoc amounts were populated as Zero which has been taken care
                      by, incorporating an if condition if p_type='REQUISITION' then
                      adhoc amounts are picked up from Requisition, else it will be picked
                      from the previous adhoc amounts entered in the Tax screen.

  2.      26-JUN-03 Vijay Shankar for Bug# 3026084, FileVersion: 616.1
                       Tax amount is getting calculated as 0 if tax_rate is -1. the reason is that
                       if tax_rate_tab contains -1, then it is treated as adhoc tax and will not calculate
                       tax amount. fixed the issue by treating the adhoc tax if tax_rate_tab contains -99999

  3       10-OCT-03 Vijay Shankar for Bug# 3190782, FileVersion: 616.2
                       Tax Calculation is not handled properly when P_TYPE='REQUISITION', which is made proper with this fix. Basically
                       assigning values to plsql tables is handled properly with common code by accessing JAI_PO_REQ_LINE_TAXES and
                       JAI_PO_TAXES through REF CURSOR. Code related to populating plsql tables during P_TYPE='REQUISITION'
                       is removed and aligned with PO code.

  4.      12-OCT-05 Bug4210102. Added by LGOPALSA
                      Added CVD and Excise education Cess

  5.     17/mar-2005  Rchandan for bug#4245365 Version 115.2
                     Changes made to calculate VAT taxes taking the VAT assessable value as base
                     New parameter is added for having vat assesable value.
  6.     20/03/2005  rchandan Version 115.3
                     Wrong template was used while checkin. So again checked out the file and now doing a check in with correct template
  7. 17/04/2007      kunkumar for 5989740
                    Forward porting file ja_in_cal_tax_p.sql; version  	115.8.6107.2
  8. 09/03/2007    rchandan for bug#4281841 , File Version 115.10
                   Issue :  NEW ENH: IL SUPPORT FOR IPROCUREMENT
                   Fix :  Added rounding to the tax amount wherever it is getting calculated.
                         Moreover if the rounding factor is NULL , then tax amount was getting populated as NULL. So added
                         a nvl condition with 0 as default. v_conversion_rate is initialised to zero for UOM based taxes.
  9.  06/02/2007  rchandan for bug#5852041 , File Version 115.8
                   Issue : TAX CALCULATED INCORRECTLY WHEN REQUISITION QUANTITY IS MODIFIED
                     Fix : The cursor c_reqn_curr is modified to query from po_requistion_headers_all instead of
                           po_requistion_lines_all as it was mutating when called from triggers on po_requistion_lines_all.

  10. 01/15/2008  Kevin Cheng   Add a branch to deal with taxes recalculate for retroactive price update.

  11. 02/29/2008  Kevin Cheng   Modify code for bug 6849952.
                                reset non rate tax amount for ad hoc tax in the third calculation loop.

  ===============================================================================
  Dependencies:

  Version   Author      Dependency        Comments

  115.1     LGOPALSA    IN60106 +         Implemented Cess tax code
                        4146708

  115.2     RCHANDAN    4245089              VAT implementation

  -------------------------------------------------------------------------------------------- */
  --Added by Kevin Cheng for Retroactive Price 2008/01/10
  --=====================================================
  IF pv_retroprice_changed = 'N'
  THEN
  --=====================================================
    debug           :=  'Y';
    bsln_amt        :=  p_tax_amount;
    row_count       :=  0;
    v_tax_amt       :=  0;
    vamt            :=  0;
    max_iter        :=  15; -- bug 5228046. Changed from 10 to 15
    v_curr          :=  p_line_uom_code;
    v_line_uom_code :=  p_line_uom_code;

  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN -- Vijay Shankar for Bug# 3190782

    IF p_item_id IS NULL THEN
       OPEN  Fetch_Item_Cur;
       FETCH Fetch_Item_Cur INTO p_inventory_item_id;
       CLOSE Fetch_Item_Cur;
    ELSE
       p_inventory_item_id := p_item_id;
    END IF;

  --start 6/05/02 cbabu bug2357371
    IF p_line_uom_code IS NULL THEN
       OPEN  Fetch_line_uom_code;
       FETCH Fetch_line_uom_code INTO v_line_uom_code;
       CLOSE Fetch_line_uom_code;
    END IF;
  --end 6/05/02 cbabu bug2357371

  END IF;   -- Vijay Shankar for Bug# 3190782

  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN

          /* Added by LGOPALSA. Bug 4210102.
     * Added CVD and Excise Education Cess
     * */
     OPEN c_tax_cur FOR
     SELECT A.Tax_Line_No LNo,
            A.Precedence_1 P_1,
      A.Precedence_2 P_2,
            A.Precedence_3 P_3,
      A.Precedence_4 P_4,
      A.precedence_5 P_5,
            A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      A.Precedence_7 P_7,
            A.Precedence_8 P_8,
      A.Precedence_9 P_9,
      A.precedence_10 P_10,
            A.Tax_Id,
            DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                               'EXCISE', 1,
                                                         'ADDL. EXCISE', 1,
                                                         'OTHER EXCISE', 1,
                                    --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
                                    /*jai_constants.tax_type_exc_edu_cess, 1,
                                    jai_constants.tax_type_sh_exc_edu_cess, 1,--Added by kunkumar for bugno5989740*/
                                    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
                                    ---------------------------------------------------
                                    jai_constants.tax_type_exc_edu_cess, 6,
                                    jai_constants.tax_type_cvd_edu_cess , 6,
                                    jai_constants.tax_type_sh_exc_edu_cess, 6,
                                    jai_constants.tax_type_sh_cvd_edu_cess, 6,
                                    ---------------------------------------------------
                                                                  'TDS', 2, 0)) tax_type_val,
            A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
            A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
            B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
            , B.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      FROM JAI_PO_TAXES A, JAI_CMN_TAXES_ALL B,jai_regime_tax_types_v aa
     WHERE Po_Line_Id = p_line_id
       AND Line_Location_Id = p_line_loc_id
       --AND NVL( Line_Location_Id, -999 ) = p_line_loc_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
       AND A.Tax_Id = B.Tax_Id
       AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;

     --- Cursor changed by ravi for getting the vat related taxes.


  ELSIF p_type = 'REQUISITION' THEN

          /* added by LGOPALSA. Bug 4210102.
     * Added Excise and CVD Education Cess */
    OPEN c_tax_cur FOR
    SELECT A.Tax_Line_No LNo,
           A.Precedence_1 P_1,
     A.Precedence_2 P_2,
           A.Precedence_3 P_3,
     A.Precedence_4 P_4,
     A.precedence_5 P_5,
           A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
     A.Precedence_7 P_7,
           A.Precedence_8 P_8,
     A.Precedence_9 P_9,
     A.precedence_10 P_10,
           A.Tax_Id,
           DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                              'EXCISE', 1,
                                                        'ADDL. EXCISE', 1,
                                                        'OTHER EXCISE', 1,
                                   --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
                                   /*jai_constants.tax_type_exc_edu_cess, 1,
                                   jai_constants.tax_type_sh_exc_edu_cess, 1,--Added by kunkumar for bugno 5989740*/
                                   --Add by Kevin Cheng for inclusive tax Dec 18, 2007
                                   ---------------------------------------------------
                                   jai_constants.tax_type_exc_edu_cess, 6,
                                   jai_constants.tax_type_cvd_edu_cess , 6,
                                   jai_constants.tax_type_sh_exc_edu_cess, 6,
                                   jai_constants.tax_type_sh_cvd_edu_cess, 6,
                                   ---------------------------------------------------
   'TDS', 2, 0)) tax_type_val,
           A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
           A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
           B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
           , B.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 18, 2007
     FROM JAI_PO_REQ_LINE_TAXES A,
          JAI_CMN_TAXES_ALL B,
          jai_regime_tax_types_v aa
    WHERE requisition_line_Id = p_line_id
      AND A.Tax_Id = B.Tax_Id
      AND aa.tax_type(+) = b.tax_type
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
   ORDER BY 1;

   /* added by ssumaith for receipts tax recalculation .*/
   ELSIF p_type = 'RECEIPTS' THEN

     OPEN c_tax_cur FOR
     SELECT A.Tax_Line_No LNo,  A.Precedence_1 P_1, A.Precedence_2 P_2,
              A.Precedence_3 P_3, A.Precedence_4 P_4, A.precedence_5 P_5,
              A.Precedence_6 P_6, A.Precedence_7 P_7,
              A.Precedence_8 P_8, A.Precedence_9 P_9, A.precedence_10 P_10,
              A.Tax_Id,
              DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                 'EXCISE', 1,
                                                           'ADDL. EXCISE', 1,
                                                           'OTHER EXCISE', 1,
                                                           --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
                                                           /*'Excise_Education_cess', 1,*/
                                                           --Add by Kevin Cheng for inclusive tax Dec 18, 2007
                                                           ---------------------------------------------------
                                                           jai_constants.tax_type_exc_edu_cess, 6,
                                                           jai_constants.tax_type_cvd_edu_cess , 6,
                                                           jai_constants.tax_type_sh_exc_edu_cess, 6,
                                                           jai_constants.tax_type_sh_cvd_edu_cess, 6,
                                                           ---------------------------------------------------
                                                           'TDS', 2, 0)) tax_type_val,
              A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
              A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
              B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
              , B.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        FROM jai_rcv_line_taxes A,
             JAI_CMN_TAXES_ALL B,
             jai_regime_tax_types_v aa
       WHERE shipment_line_id = p_line_id /* shipment line id */
         AND A.Tax_Id = B.Tax_Id
         AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;

     OPEN fetch_rcv_line_currency;
     FETCH fetch_rcv_line_currency INTO lv_currency_code;
     CLOSE fetch_rcv_line_currency;

   ELSIF p_type = 'ASBN' Then

     OPEN c_tax_cur FOR
     SELECT A.Tax_Line_No LNo,  A.Precedence_1 P_1, A.Precedence_2 P_2,
              A.Precedence_3 P_3, A.Precedence_4 P_4, A.precedence_5 P_5,
              A.Precedence_6 P_6, A.Precedence_7 P_7,
              A.Precedence_8 P_8, A.Precedence_9 P_9, A.precedence_10 P_10,
              A.Tax_Id,
              DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                 'EXCISE', 1,
                                                           'ADDL. EXCISE', 1,
                                                           'OTHER EXCISE', 1,
                                                           --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
                                                           /*'Excise_Education_cess', 1,*/
                                                           --Add by Kevin Cheng for inclusive tax Dec 18, 2007
                                                           ---------------------------------------------------
                                                           jai_constants.tax_type_exc_edu_cess, 6,
                                                           jai_constants.tax_type_cvd_edu_cess , 6,
                                                           jai_constants.tax_type_sh_exc_edu_cess, 6,
                                                           jai_constants.tax_type_sh_cvd_edu_cess, 6,
                                                           ---------------------------------------------------
                                                           'TDS', 2, 0)) tax_type_val,
              A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
              A.Tax_Amt tax_amount, A.currency_code curr, B.End_Date Valid_Date,
              B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
              , B.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        FROM Jai_cmn_document_Taxes A,
             JAI_CMN_TAXES_ALL B,
             jai_regime_tax_types_v aa
       WHERE source_doc_line_id = p_line_id /* source doc line id */
         AND A.Tax_Id = B.Tax_Id
         AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;

  END IF;
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO', 'REQUISITION', 'RECEIPTS' , 'ASBN'  ) THEN
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
  LOOP

    FETCH c_tax_cur INTO rec;
    EXIT WHEN c_tax_cur%NOTFOUND;

      P1(rec.lno) := nvl(rec.p_1,-1);
      P2(rec.lno) := nvl(rec.p_2,-1);
      P3(rec.lno) := nvl(rec.p_3,-1);
      P4(rec.lno) := nvl(rec.p_4,-1);
      P5(rec.lno) := nvl(rec.p_5,-1);
      -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      -- start bug#5228046
      P6(rec.lno) := nvl(rec.p_6,-1);
      P7(rec.lno) := nvl(rec.p_7,-1);
      P8(rec.lno) := nvl(rec.p_8,-1);
      P9(rec.lno) := nvl(rec.p_9,-1);
      P10(rec.lno) := nvl(rec.p_10,-1);
      -- end bug#5228046

      rnd_factor(rec.lno) := nvl(rec.rnd_factor,0);
      Tax_Rate_Tab(rec.lno) := nvl(rec.Tax_Rate,0);
      Tax_Type_Tab(rec.lno) := rec.tax_type_val;
      adhoc_tab(rec.lno) := nvl(rec.adhoc_flag,'N'); -- added by subbu on 08-nov-01

      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ----------------------------------------------------
      lt_tax_rate_per_rupee(rec.lno)   := NVL(rec.tax_rate,0)/100;
      ln_total_tax_per_rupee           := 0;
      lt_inclu_tax_tab(rec.lno)        := NVL(rec.inclusive_tax_flag,'N');

      IF rec.tax_rate is null THEN
        lt_tax_rate_zero_tab(rec.lno)  := 0;
      ELSIF rec.tax_rate = 0 THEN
        lt_tax_rate_zero_tab(rec.lno)  := -9999;
      ELSE
        lt_tax_rate_zero_tab(rec.lno)  := rec.tax_rate;
      END IF;

      tax_amt_tab(rec.lno)             := 0;
      lt_tax_amt_rate_tax_tab(rec.lno) := 0;
      lt_tax_amt_non_rate_tab(rec.lno) := 0;
      lt_base_tax_amt_tab(rec.lno)     := 0;
      ----------------------------------------------------
      IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 and nvl(rec.adhoc_flag,'N') = 'Y' THEN
      --Changed by Nagaraj.s for Bug2519359.

         /*
         IF p_type='REQUISITION' Then
      OPEN req_adhoc_tax_amt(rec.tax_id);
      FETCH req_adhoc_tax_amt into v_adhoc_tax_amt;
      CLOSE req_adhoc_tax_amt;
         ELSE
        v_adhoc_tax_amt := rec.tax_amount;
         END IF;
         */
      v_adhoc_tax_amt := rec.tax_amount;

       -- cbabu for Bug# 3026084
       -- tax_rate_tab(rec.lno) :=  -1;
       tax_rate_tab(rec.lno) :=  -99999;

         /*Tax_Amt_Tab(rec.lno)  := v_adhoc_tax_amt;*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
         tax_target_tab(rec.lno) := v_adhoc_tax_amt;
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_tax_amt_non_rate_tab(rec.lno) := nvl(v_adhoc_tax_amt, 0);   -- tax inclusive
        lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
        ---------------------------------------------------
      ELSIF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 THEN

       -- cbabu for Bug# 3026084
       -- tax_rate_tab(rec.lno) :=  -1;
       tax_rate_tab(rec.lno) :=  -99999;

         /*Tax_Amt_Tab(rec.lno)  := rec.tax_amount;*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
         tax_target_tab(rec.lno) := rec.tax_amount;
         --Add by Kevin Cheng for inclusive tax Dec 18, 2007
         ---------------------------------------------------
         lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.tax_amount, 0);   -- tax inclusive
         lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
         ---------------------------------------------------
      ELSE
         Tax_Amt_Tab(rec.lno)  := 0;
      END IF;

      Curr_Tab(rec.lno) := NVL( rec.curr, v_curr );
      IF rec.Valid_Date is NULL Or rec.Valid_Date >= Sysdate THEN
      End_Date_Tab(rec.lno) := 1;
      ELSE
      End_Date_Tab(rec.lno) := 0;
      tax_amt_tab(rec.lno)  := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      row_count := row_count + 1;

      IF tax_rate_tab(rec.lno) = 0 THEN

         FOR uom_cls IN uom_class_cur( nvl(p_line_uom_code, v_line_uom_code) , rec.uom_code) LOOP  -- -- 6/05/02 cbabu bug2357371, added nvl statement
        INV_CONVERT.inv_um_conversion(nvl(p_line_uom_code, v_line_uom_code), rec.uom_code, p_inventory_item_id, v_conversion_rate);  -- 15/03/2002 cbabu, added nvl statement
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(nvl(p_line_uom_code, v_line_uom_code), rec.uom_code, 0, v_conversion_rate); -- 6/05/02 cbabu bug2357371, added nvl statement
          IF nvl(v_conversion_rate, 0) <= 0  THEN
             v_conversion_rate := 0;
          END IF;
       END IF;
       --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
       --tax_amt_tab(rec.lno) := ROUND( nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity, rnd_factor(rec.lno) );

         -- cbabu for Bug# 3026084
         -- tax_rate_tab(rec.lno) :=  -1;
         tax_rate_tab(rec.lno) :=  -99999;

           --tax_target_tab(rec.lno) := tax_amt_tab( rec.lno ); --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
           -- tax_rate_tab(rec.lno) :=  TRUNC( nvl(rec.qty_rate * p_line_quantity, 0 ), 2 );
          --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ---------------------------------------------------
          lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
          lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
          tax_target_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
          ---------------------------------------------------
        END LOOP;
     END IF;
  END LOOP;

  CLOSE c_tax_cur;  -- Vijay Shankar for Bug# 3190782

  END IF;

  --Add by Kevin Cheng for inclusive tax Dec 18, 2007
  -----------------------------------------------------
  IF p_vat_assess_value <> p_price THEN
    ln_vat_assessable_value := p_vat_assess_value;
  ELSE
    ln_vat_assessable_value := 1;
  END IF;

  if p_assessable_value <> p_price THEN
    ln_assessable_value := p_assessable_value;
  ELSE
    ln_assessable_value := 1;
  END IF;
  -----------------------------------------------------
    bsln_amt := p_price;

   FOR I in 1..row_count
    LOOP
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      IF end_date_tab(I) <> 0
      THEN
      ---------------------------------------------------
      IF tax_type_tab(i) = 1 THEN
        --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
         --bsln_amt := NVL( p_assessable_value, p_price );
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        IF ln_assessable_value = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_assessable_value;
        END IF;
        ---------------------------------------------------
      ELSIF tax_type_tab(i) = 4 THEN             -- Ravi for VAT
        --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
         --bsln_amt := NVL( p_vat_assess_value, p_price );
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
        IF ln_vat_assessable_value = 1 THEN
          bsln_amt := 1;
		      ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 6 THEN  --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 0;
        ln_bsln_amt_nr := 0;
      ELSE --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 1;
        ln_bsln_amt_nr := 0;
      END IF; --IF tax_type_tab(I) = 1   THEN
      ---------------------------------------------------
      /*ELSE
         bsln_amt := p_price;
      END IF;*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007

      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      IF tax_rate_tab(I) <> 0
      THEN
      ---------------------------------------------------
      IF p1(I) < I and p1(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p1(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p2(I) < I and p2(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007

      ELSIF p2(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p3(I) < I and p3(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007

      ELSIF p3(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p4(I) < I and p4(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007

      ELSIF p4(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p5(I) < I and p5(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p5(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

      IF p6(I) < I and p6(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p6(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p7(I) < I and p7(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p7(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p8(I) < I and p8(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p8(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p9(I) < I and p9(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p9(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p10(I) < I and p10(I) not in (-1,0) then
         vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
        ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ELSIF p10(I) = 0 then
         vamt  := vamt + bsln_amt;
		     ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
-- END BUG 5228046

     -- cbabu for Bug# 3026084
       -- IF tax_rate_tab(I) <> -1 THEN
       IF tax_rate_tab(I) <> -99999 THEN
         v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
         IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
         ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
         END IF;
       ELSE --added by subbu on 7-nov-01
         tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
       END IF;
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
      lt_base_tax_amt_tab(I) := vamt;
      lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr; -- tax inclusive
      lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);

      ln_tax_amt_nr := 0;
      ln_vamt_nr := 0;
      ---------------------------------------------------

      vamt      := 0;
      v_tax_amt := 0;
    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ---------------------------------------------------
      END IF; --IF tax_rate_tab(I) <> 0 THEN
    ELSE --IF end_date_tab(I) <> 0 THEN
      tax_amt_tab(I) := 0;
      lt_base_tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab(I) <> 0 THEN
    ---------------------------------------------------
     END LOOP;

    FOR I in 1..row_count
    LOOP
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      IF end_date_tab( I ) <> 0 THEN
      IF tax_rate_tab(I) <> 0 THEN
      ---------------------------------------------------
      IF p1(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p2(I) > I  then
         vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p3(I) > I  then
         vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p4(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p5(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

      IF p6(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p7(I) > I  then
         vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p8(I) > I  then
         vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p9(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
      IF p10(I) > I then
         vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
		     ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;
-- END BUG 5228046

       -- cbabu for Bug# 3026084
       -- IF tax_rate_tab(I) <> -1 THEN
       IF tax_rate_tab(I) <> -99999 THEN
         v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
         IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
         ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
         END IF;
       ELSE -- added by subbu on 07-nov-01
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
       END IF;

      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      lt_base_tax_amt_tab(I) := vamt;
      ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100)); -- tax inclusive
      IF vamt <> 0 THEN
        lt_base_tax_amt_tab(I) := lt_base_tax_amt_tab(I) + vamt;
      END IF;
      lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr ; -- tax inclusive
      lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
      ln_vamt_nr := 0 ;
      ln_tax_amt_nr := 0 ;
      ---------------------------------------------------

      vamt      := 0;
      v_tax_amt := 0;
    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ---------------------------------------------------
      END IF; --IF tax_rate_tab(I) <> 0 THEN

    ELSE --IF end_date_tab( I ) <> 0 THEN
      lt_base_tax_amt_tab(I) := vamt;
      tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab( I ) <> 0 THEN
    ---------------------------------------------------
    END LOOP;

    FOR counter IN 1 .. max_iter LOOP
      vamt := 0;
      v_tax_amt := 0;
      ln_vamt_nr:= 0;   --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ln_tax_amt_nr:=0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007

      FOR i IN 1 .. row_count LOOP
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        IF ( tax_rate_tab( i ) <> 0 OR lt_tax_rate_zero_tab(I) = -9999) AND end_date_tab( I ) <> 0 THEN

  /*      IF tax_rate_tab( i ) > 0 AND End_Date_Tab(I) <> 0 THEN  Commented by Satya / Subbu on 09-Oct-01    */

  /*  Added by Satya / subbu on 09-Oct-01 for calculating the Negative Tax */

        IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0  AND adhoc_tab(i) <> 'Y' THEN
  -- added extra condition AND adhoc_tab(i) <> 'Y' by subbu on 8-nov-01 for adhoc taxes
            IF tax_type_tab( i ) = 1 THEN
               --v_amt := NVL( p_assessable_value, p_price );--Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
              --Add by Kevin Cheng for inclusive tax Dec 18, 2007
              ------------------------------------------------
              IF ln_assessable_value =1
              THEN
                v_amt:=1;
                ln_bsln_amt_nr :=0;
              ELSE
                v_amt :=0;
                ln_bsln_amt_nr :=ln_assessable_value;
              END IF;
              ------------------------------------------------
            ELSIF tax_type_tab(i) = 4 THEN     -- Ravi for VAT
               --v_amt := NVL( p_vat_assess_value, p_price );--Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
            --Add by Kevin Cheng for inclusive tax Dec 18, 2007
            ---------------------------------------------------
              IF ln_vat_assessable_value =1
              THEN
                v_amt:=1;
                ln_bsln_amt_nr :=0;
              ELSE
                v_amt :=0;
                ln_bsln_amt_nr :=ln_vat_assessable_value;
              END IF;
            ELSIF tax_type_tab(I) = 6 THEN
              v_amt:=0;
              ln_bsln_amt_nr :=0;
            ---------------------------------------------------
            ELSIF v_amt = 0 OR tax_type_tab(i) <> 1 THEN
               --v_amt := p_price;--Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
               --Add by Kevin Cheng for inclusive tax Dec 18, 2007
               ---------------------------------------------------
               vamt := 1;
               ln_bsln_amt_nr := 0;
               ---------------------------------------------------
            END IF;
     IF p1( i ) <> -1 THEN
        IF p1( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p1( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p1(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;
           IF p2( i ) <> -1 THEN
        IF p2( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p2( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p2(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;
           IF p3( i ) <> -1 THEN
        IF p3( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p3( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p3(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;
           IF p4( i ) <> -1 THEN
        IF p4( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p4( i ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p4(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;
           IF p5( i ) <> -1 THEN
        IF p5( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p5( i ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p5(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
       IF p6( i ) <> -1 THEN
        IF p6( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p6( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p6(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;

    IF p7( i ) <> -1 THEN
        IF p7( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p7( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p7(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;

     IF p8( i ) <> -1 THEN
        IF p8( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p8( I ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p8(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;

     IF p9( i ) <> -1 THEN
        IF p9( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p9( i ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p9(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;

     IF p10( i ) <> -1 THEN
        IF p10( i ) <> 0 THEN
             vamt := vamt + tax_amt_tab( p10( i ) );
		         ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ELSIF p10(i) = 0 THEN
           vamt := vamt + v_amt;
		       ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
     END IF;
-- END BUG 5228046

  tax_target_tab(I) := vamt;
  --Add by Kevin Cheng for inclusive tax Dec 18, 2007
  ---------------------------------------------------
  lt_base_tax_amt_tab(I) := vamt;
  ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100));
  lt_func_tax_amt_tab(I) := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
  ---------------------------------------------------
        IF counter = max_iter THEN --AND tax_type_tab( I ) IN ( 1, 2 ) THEN
            -- cbabu for Bug# 3026084
            -- IF tax_rate_tab(I) <> -1 THEN    -- 5/3/2002 cbabu
            IF tax_rate_tab(I) <> -99999 THEN
              --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
              /*v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), rnd_factor(I) );*/
              --Add by Kevin Cheng for inclusive tax Dec 18, 2007
              v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
            ELSE
              --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
              /*v_tax_amt := ROUND( tax_amt_tab( I ), rnd_factor(I) ); --  5/3/2002 cbabu*/
              --Add by Kevin Cheng for inclusive tax Dec 18, 2007
              v_tax_amt := tax_amt_tab( I ); --  5/3/2002 cbabu
            END IF;
          /*ELSIF counter = max_iter AND tax_type_tab( I ) NOT IN ( 1, 2 ) THEN
             v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), 2 );
            */
        ELSE
            -- cbabu for Bug# 3026084
            -- IF tax_rate_tab(I) <> -1 THEN -- 5/3/2002 cbabu
            IF tax_rate_tab(I) <> -99999 THEN
              v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
            ELSE
              v_tax_amt := tax_amt_tab( I ); -- 5/3/2002 cbabu
            END IF;
        END IF;
        tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
        --cbabu for Bug# 3026084
        ELSIF tax_rate_tab( i ) = -99999 AND End_Date_Tab(I) <> 0  THEN
          --NULL; --Comment out by Kevin Cheng for bug 6849952 Feb 29, 2008
          ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i);  --Add by Kevin Cheng for bug 6849952 Feb 29, 2008
        ELSE
          tax_amt_tab(I) := 0;
          tax_target_tab(I) := 0;
        END IF;

      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
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
      lt_tax_amt_non_rate_tab(I):=ln_tax_amt_nr;
      ---------------------------------------------------

        IF counter = max_iter THEN
          IF END_date_tab(I) = 0 THEN
            tax_amt_tab(I) := 0;
            lt_func_tax_amt_tab(i) := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        ln_func_tax_amt := 0;
        ln_vamt_nr :=0;
        ln_tax_amt_nr:=0;
        ---------------------------------------------------
        vamt := 0;
        v_amt := 0;
        v_tax_amt := 0;

      END LOOP;
    END LOOP;

    --Add by Kevin for inclusive tax Dec 18, 2007
    ---------------------------------------------------------------------------------------
    FOR I IN 1 .. ROW_COUNT --Compute Factor
    LOOP
      IF lt_inclu_tax_tab(I) = 'Y'
      THEN
        ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
	      ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
      END IF; --IF lt_inclu_tax_tab(I) = 'Y'
    END LOOP; --FOR I IN 1 .. ROW_COUNT --Compute Factor

    ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

    IF ln_total_tax_per_rupee <> 0
    THEN
      ln_exclusive_price := (NVL(p_price,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
    END IF; --IF ln_total_tax_per_rupee <> 0

    /*
     EXPLANATION :
     -------------
    this loop typically would have an insert /update in the tax tables to insert/update tax amounts
    */

    FOR i in 1 .. row_count  --Compute Tax Amount
    LOOP
       tax_amt_tab (i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
       tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,rnd_factor(I));
    END LOOP; --FOR i in 1 .. row_count
    --------------------------------------------------------------------------------------------------------
  --Added by Kevin Cheng for Retroactive Price 2008/01/10
--==========================================================================================================
  ELSIF pv_retroprice_changed = 'Y'
  THEN
    debug           :=  'Y';
    bsln_amt        :=  p_tax_amount;
    row_count       :=  0;
    v_tax_amt       :=  0;
    vamt            :=  0;
    max_iter        :=  15; -- bug 5228046. Changed from 10 to 15
    v_curr          :=  p_line_uom_code;
    v_line_uom_code :=  p_line_uom_code;

  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN -- Vijay Shankar for Bug# 3190782

    IF p_item_id IS NULL THEN
       OPEN  Fetch_Item_Cur;
       FETCH Fetch_Item_Cur INTO p_inventory_item_id;
       CLOSE Fetch_Item_Cur;
    ELSE
       p_inventory_item_id := p_item_id;
    END IF;

  --start 6/05/02 cbabu bug2357371
    IF p_line_uom_code IS NULL THEN
       OPEN  Fetch_line_uom_code;
       FETCH Fetch_line_uom_code INTO v_line_uom_code;
       CLOSE Fetch_line_uom_code;
    END IF;
  --end 6/05/02 cbabu bug2357371

  END IF;   -- Vijay Shankar for Bug# 3190782

  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN

          /* Added by LGOPALSA. Bug 4210102.
     * Added CVD and Excise Education Cess
     * */
     OPEN c_tax_retro_cur FOR
     SELECT A.Tax_Line_No LNo,
            A.Precedence_1 P_1,
      A.Precedence_2 P_2,
            A.Precedence_3 P_3,
      A.Precedence_4 P_4,
      A.precedence_5 P_5,
            A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      A.Precedence_7 P_7,
            A.Precedence_8 P_8,
      A.Precedence_9 P_9,
      A.precedence_10 P_10,
            A.Tax_Id,
            DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                               'EXCISE', 1,
                                                         'ADDL. EXCISE', 1,
                                                         'OTHER EXCISE', 1,
                                    jai_constants.tax_type_exc_edu_cess, 1,
                                    jai_constants.tax_type_sh_exc_edu_cess, 1,--Added by kunkumar for bugno5989740
                                                                  'TDS', 2, 0)) tax_type_val,
            A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
            A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
            B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
            , pha.vendor_id hdr_vendor_id, A.Vendor_Id tax_vendor_id --Added by Kevin Cheng
      FROM JAI_PO_TAXES A, JAI_CMN_TAXES_ALL B,jai_regime_tax_types_v aa
           , po_headers_all pha  --Added by Kevin Cheng
     WHERE Po_Line_Id = p_line_id
       AND Line_Location_Id = p_line_loc_id
       --AND NVL( Line_Location_Id, -999 ) = p_line_loc_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
       AND A.Tax_Id = B.Tax_Id
       AND pha.po_header_id = A.Po_Header_Id --Added by Kevin Cheng
       AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;

     --- Cursor changed by ravi for getting the vat related taxes.

--Comment by Kevin Cheng
  /*ELSIF p_type = 'REQUISITION' THEN

          \* added by LGOPALSA. Bug 4210102.
     * Added Excise and CVD Education Cess *\
    OPEN c_tax_retro_cur FOR
    SELECT A.Tax_Line_No LNo,
           A.Precedence_1 P_1,
     A.Precedence_2 P_2,
           A.Precedence_3 P_3,
     A.Precedence_4 P_4,
     A.precedence_5 P_5,
           A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
     A.Precedence_7 P_7,
           A.Precedence_8 P_8,
     A.Precedence_9 P_9,
     A.precedence_10 P_10,
           A.Tax_Id,
           DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                              'EXCISE', 1,
                                                        'ADDL. EXCISE', 1,
                                                        'OTHER EXCISE', 1,
                                   jai_constants.tax_type_exc_edu_cess, 1,
                                   jai_constants.tax_type_sh_exc_edu_cess, 1,--Added by kunkumar for bugno 5989740

   'TDS', 2, 0)) tax_type_val,
           A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
           A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
           B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
     FROM JAI_PO_REQ_LINE_TAXES A,
          JAI_CMN_TAXES_ALL B,
          jai_regime_tax_types_v aa
    WHERE requisition_line_Id = p_line_id
      AND A.Tax_Id = B.Tax_Id
      AND aa.tax_type(+) = b.tax_type
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
   ORDER BY 1;
*/
   /* added by ssumaith for receipts tax recalculation .*/
   ELSIF p_type = 'RECEIPTS' THEN

     OPEN c_tax_retro_cur FOR
     SELECT A.Tax_Line_No LNo,  A.Precedence_1 P_1, A.Precedence_2 P_2,
              A.Precedence_3 P_3, A.Precedence_4 P_4, A.precedence_5 P_5,
              A.Precedence_6 P_6, A.Precedence_7 P_7,
              A.Precedence_8 P_8, A.Precedence_9 P_9, A.precedence_10 P_10,
              A.Tax_Id,
              DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                 'EXCISE', 1,
                                                           'ADDL. EXCISE', 1,
                                                           'OTHER EXCISE', 1,
                                                           'Excise_Education_cess', 1,
                                                           'TDS', 2, 0)) tax_type_val,
              A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
              A.Tax_Amount, A.currency curr, B.End_Date Valid_Date,
              B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
              , rsh.vendor_id hdr_vendor_id, A.Vendor_Id tax_vendor_id --Added by Kevin Cheng
        FROM jai_rcv_line_taxes A,
             JAI_CMN_TAXES_ALL B,
             jai_regime_tax_types_v aa,
             RCV_SHIPMENT_HEADERS rsh --Added by Kevin Cheng
       WHERE shipment_line_id = p_line_id /* shipment line id */
         AND A.Tax_Id = B.Tax_Id
         AND rsh.shipment_header_id = A.SHIPMENT_HEADER_ID --Added by Kevin Cheng
         AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;

     OPEN fetch_rcv_line_currency;
     FETCH fetch_rcv_line_currency INTO lv_currency_code;
     CLOSE fetch_rcv_line_currency;
--Comment out by Kevin Cheng
   /*ELSIF p_type = 'ASBN' Then

     OPEN c_tax_retro_cur FOR
     SELECT A.Tax_Line_No LNo,  A.Precedence_1 P_1, A.Precedence_2 P_2,
              A.Precedence_3 P_3, A.Precedence_4 P_4, A.precedence_5 P_5,
              A.Precedence_6 P_6, A.Precedence_7 P_7,
              A.Precedence_8 P_8, A.Precedence_9 P_9, A.precedence_10 P_10,
              A.Tax_Id,
              DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                 'EXCISE', 1,
                                                           'ADDL. EXCISE', 1,
                                                           'OTHER EXCISE', 1,
                                                           'Excise_Education_cess', 1,
                                                           'TDS', 2, 0)) tax_type_val,
              A.Tax_Rate tax_rate, A.Qty_Rate Qty_Rate, A.uom uom_code,
              A.Tax_Amt tax_amount, A.currency_code curr, B.End_Date Valid_Date,
              B.rounding_factor rnd_factor, B.adhoc_flag adhoc_flag
        FROM Jai_cmn_document_Taxes A,
             JAI_CMN_TAXES_ALL B,
             jai_regime_tax_types_v aa
       WHERE source_doc_line_id = p_line_id \* source doc line id *\
         AND A.Tax_Id = B.Tax_Id
         AND aa.tax_type(+) = b.tax_type
     ORDER BY 1;
*/
  END IF;
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
  IF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO', 'REQUISITION', 'RECEIPTS' , 'ASBN'  ) THEN
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
  LOOP

    FETCH c_tax_retro_cur INTO rec_retro;
    EXIT WHEN c_tax_retro_cur%NOTFOUND;

      P1(rec_retro.lno) := nvl(rec_retro.p_1,-1);
      P2(rec_retro.lno) := nvl(rec_retro.p_2,-1);
      P3(rec_retro.lno) := nvl(rec_retro.p_3,-1);
      P4(rec_retro.lno) := nvl(rec_retro.p_4,-1);
      P5(rec_retro.lno) := nvl(rec_retro.p_5,-1);
      -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Prec_retroedence 6 to 10 )
      -- start bug#5228046
      P6(rec_retro.lno) := nvl(rec_retro.p_6,-1);
      P7(rec_retro.lno) := nvl(rec_retro.p_7,-1);
      P8(rec_retro.lno) := nvl(rec_retro.p_8,-1);
      P9(rec_retro.lno) := nvl(rec_retro.p_9,-1);
      P10(rec_retro.lno) := nvl(rec_retro.p_10,-1);
      -- end bug#5228046

      rnd_factor(rec_retro.lno) := nvl(rec_retro.rnd_factor,0);
      Tax_Rate_Tab(rec_retro.lno) := nvl(rec_retro.Tax_Rate,0);
      Tax_Type_Tab(rec_retro.lno) := rec_retro.tax_type_val;
      --Comment out by Kevin Cheng
      --adhoc_tab(rec_retro.lno) := nvl(rec_retro.adhoc_flag,'N'); -- added by subbu on 08-nov-01

      --Added by Kevin Cheng -- for remain unchanged taxes
  --1, Ad hoc taxes
  --2, UOM based taxes
  --3, Assessable value base taxes (Excise/VAT)
  --4, Third party taxes
  --=================================================================================
  IF NVL(rec_retro.adhoc_flag,'N') = 'Y' --Ad hoc
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF tax_rate_tab(rec_retro.lno) = 0 AND rec_retro.uom_code IS NOT NULL --UOM based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec_retro.tax_type_val = 1 AND p_assessable_value <> p_price --Excise assessable value based
  THEN
     lv_tax_remain_flag := 'Y';
  ELSIF rec_retro.tax_type_val = 4 AND p_vat_assess_value <> p_price --VAT assessable value based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec_retro.hdr_vendor_id <> rec_retro.tax_vendor_id --Third party
  THEN
    lv_tax_remain_flag := 'Y';
  ELSE
    lv_tax_remain_flag := 'N';
  END IF;

  IF lv_tax_remain_flag = 'Y'
  THEN
    IF pv_called_from = 'RETROACTIVE'
    THEN
      SELECT
        original_tax_amount
      INTO
        tax_amt_tab(rec_retro.lno)
      FROM
        Jai_Retro_Tax_Changes jrtc
      WHERE jrtc.tax_id = rec_retro.tax_id
        AND jrtc.line_change_id = (SELECT
                                     jrlc.line_change_id
                                   FROM
                                     Jai_Retro_Line_Changes jrlc
                                   WHERE jrlc.doc_header_id = p_header_id
                                     AND jrlc.doc_line_id = P_line_id
                                     AND jrlc.doc_type = 'RECEIPT'
                                     AND jrlc.doc_version_number = (SELECT
                                                                      MAX(jrlc1.doc_version_number)
                                                                    FROM
                                                                      Jai_Retro_Line_Changes jrlc1
                                                                    WHERE jrlc1.doc_header_id = p_header_id
                                                                      AND jrlc1.doc_line_id = P_line_id
                                                                      AND jrlc1.doc_type = 'RECEIPT'
                                                                   )
                                  );
    ELSE
      SELECT
        original_tax_amount
      INTO
        tax_amt_tab(rec_retro.lno)
      FROM
        Jai_Retro_Tax_Changes jrtc
      WHERE jrtc.tax_id = rec_retro.tax_id
        AND jrtc.line_change_id = (SELECT
                                     line_change_id
                                   FROM
                                     Jai_Retro_Line_Changes jrlc
                                   WHERE jrlc.line_location_id = p_line_loc_id
                                     AND jrlc.doc_line_id = p_line_id
                                     AND jrlc.doc_type IN ( 'RELEASE'
                                                          , 'STANDARD PO'
                                                          )
                                     AND jrlc.doc_version_number = (SELECT
                                                                      MAX(jrlc1.doc_version_number)
                                                                    FROM
                                                                      Jai_Retro_Line_Changes jrlc1
                                                                    WHERE jrlc1.line_location_id = p_line_loc_id
                                                                      AND jrlc1.doc_line_id = p_line_id
                                                                      AND jrlc1.doc_type IN ( 'RELEASE'
                                                                                            , 'STANDARD PO'
                                                                                            )
                                                                   )
                                  );
    END IF;

    tax_rate_tab(rec_retro.lno)      := -99999;
    tax_target_tab(rec_retro.lno)    := rec_retro.tax_amount;
    adhoc_tab(rec_retro.lno)    := 'Y';

  ELSIF lv_tax_remain_flag = 'N'
  THEN
    tax_amt_tab(rec_retro.lno)   := 0;
    adhoc_tab(rec_retro.lno):= nvl(rec_retro.adhoc_flag,'N'); -- added by subbu on 08-nov-01
  END IF;

  --Add by Eric Ma for Retro active Pricing Update Jan 11, 2008,Begin
  --------------------------------------------------------------------------
  IF (pv_called_from = 'RETROACTIVE' )
  THEN
    OPEN  get_rcv_line_for_retro ( pn_tax_id => rec_retro.tax_id);
    FETCH get_rcv_line_for_retro
    INTO
      lv_tax_type
    , lv_third_party_flag;
    CLOSE get_rcv_line_for_retro;

  	IF( lv_tax_type IN
        ( JAI_CONSTANTS.tax_type_customs
        , JAI_CONSTANTS.tax_type_customs_edu_cess
        , JAI_CONSTANTS.tax_type_sh_customs_edu_Cess
        , JAI_CONSTANTS.tax_type_cvd
        , JAI_CONSTANTS.tax_type_cvd_edu_cess
        , JAI_CONSTANTS.tax_type_sh_cvd_edu_cess
        )
       OR lv_third_party_flag = 'Y'
      )
    THEN
      tax_rate_tab(rec_retro.lno) :=  -99999;              --changed by eric on Feb 1,2008
      Tax_Amt_Tab(rec_retro.lno)  := rec_retro.tax_amount; --changed by eric on Feb 1,2008
      tax_target_tab(rec_retro.lno) := rec_retro.tax_amount; --changed by eric on Feb 1,2008
    END IF;
  END IF;--IF  (pv_called_from = 'RETROACTIVE' )
  --------------------------------------------------------------------------
  --Add by Eric Ma for Retro active Pricing Update Jan 11, 2008,End
  --=================================================================================

  --Comment out by Kevin Cheng
      /*IF nvl(rec_retro.tax_rate,0) = 0 AND nvl(rec_retro.qty_rate,0) = 0 and nvl(rec_retro.adhoc_flag,'N') = 'Y' THEN
      --Changed by Nagaraj.s for Bug2519359.

         \*
         IF p_type='REQUISITION' Then
      OPEN req_adhoc_tax_amt(rec_retro.tax_id);
      FETCH req_adhoc_tax_amt into v_adhoc_tax_amt;
      CLOSE req_adhoc_tax_amt;
         ELSE
        v_adhoc_tax_amt := rec_retro.tax_amount;
         END IF;
         *\
      v_adhoc_tax_amt := rec_retro.tax_amount;

       -- cbabu for Bug# 3026084
       -- tax_rate_tab(rec_retro.lno) :=  -1;
       tax_rate_tab(rec_retro.lno) :=  -99999;

         Tax_Amt_Tab(rec_retro.lno)  := v_adhoc_tax_amt;
         tax_target_tab(rec_retro.lno) := v_adhoc_tax_amt;

      ELSIF nvl(rec_retro.tax_rate,0) = 0 AND nvl(rec_retro.qty_rate,0) = 0 THEN

       -- cbabu for Bug# 3026084
       -- tax_rate_tab(rec_retro.lno) :=  -1;
       tax_rate_tab(rec_retro.lno) :=  -99999;

         Tax_Amt_Tab(rec_retro.lno)  := rec_retro.tax_amount;
         tax_target_tab(rec_retro.lno) := rec_retro.tax_amount;
      ELSE
         Tax_Amt_Tab(rec_retro.lno)  := 0;
      END IF;*/

      Curr_Tab(rec_retro.lno) := NVL( rec_retro.curr, v_curr );
      IF rec_retro.Valid_Date is NULL Or rec_retro.Valid_Date >= Sysdate THEN
      End_Date_Tab(rec_retro.lno) := 1;
      ELSE
      End_Date_Tab(rec_retro.lno) := 0;
      END IF;
      row_count := row_count + 1;
--Comment out by Kevin Cheng
      /*IF tax_rate_tab(rec_retro.lno) = 0 THEN

         FOR uom_cls IN uom_class_cur( nvl(p_line_uom_code, v_line_uom_code) , rec_retro.uom_code) LOOP  -- -- 6/05/02 cbabu bug2357371, added nvl statement
        INV_CONVERT.inv_um_conversion(nvl(p_line_uom_code, v_line_uom_code), rec_retro.uom_code, p_inventory_item_id, v_conversion_rate);  -- 15/03/2002 cbabu, added nvl statement
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(nvl(p_line_uom_code, v_line_uom_code), rec_retro.uom_code, 0, v_conversion_rate); -- 6/05/02 cbabu bug2357371, added nvl statement
          IF nvl(v_conversion_rate, 0) <= 0  THEN
             v_conversion_rate := 0;
          END IF;
       END IF;
       tax_amt_tab(rec_retro.lno) := ROUND( nvl(rec_retro.qty_rate * v_conversion_rate, 0) * p_line_quantity, rnd_factor(rec_retro.lno) );

         -- cbabu for Bug# 3026084
         -- tax_rate_tab(rec_retro.lno) :=  -1;
         tax_rate_tab(rec_retro.lno) :=  -99999;

           tax_target_tab(rec_retro.lno) := tax_amt_tab( rec_retro.lno );
           -- tax_rate_tab(rec_retro.lno) :=  TRUNC( nvl(rec_retro.qty_rate * p_line_quantity, 0 ), 2 );

        END LOOP;
     END IF;*/

  END LOOP;

  CLOSE c_tax_retro_cur;  -- Vijay Shankar for Bug# 3190782

  END IF;

    bsln_amt := p_price;

   FOR I in 1..row_count
    LOOP
      IF tax_type_tab(i) = 1 THEN
         bsln_amt := NVL( p_assessable_value, p_price );
      ELSIF tax_type_tab(i) = 4 THEN             -- Ravi for VAT
         bsln_amt := NVL( p_vat_assess_value, p_price );
      ELSE
         bsln_amt := p_price;
      END IF;
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

     -- cbabu for Bug# 3026084
       -- IF tax_rate_tab(I) <> -1 THEN
       IF tax_rate_tab(I) <> -99999 THEN
         v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
         IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
         ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
         END IF;
       ELSE --added by subbu on 7-nov-01
         tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
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

       -- cbabu for Bug# 3026084
       -- IF tax_rate_tab(I) <> -1 THEN
       IF tax_rate_tab(I) <> -99999 THEN
         v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
         IF END_date_tab(I) = 0 then
            tax_amt_tab(I) := 0;
         ELSIF END_date_tab(I) = 1 then
            tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
         END IF;
       ELSE -- added by subbu on 07-nov-01
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + nvl(v_tax_amt,0);
       END IF;
      vamt      := 0;
      v_tax_amt := 0;

    END LOOP;

    FOR counter IN 1 .. max_iter LOOP
      vamt := 0;
      v_tax_amt := 0;
      FOR i IN 1 .. row_count LOOP

  /*      IF tax_rate_tab( i ) > 0 AND End_Date_Tab(I) <> 0 THEN  Commented by Satya / Subbu on 09-Oct-01    */

  /*  Added by Satya / subbu on 09-Oct-01 for calculating the Negative Tax */

        IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0  AND adhoc_tab(i) <> 'Y' THEN
  -- added extra condition AND adhoc_tab(i) <> 'Y' by subbu on 8-nov-01 for adhoc taxes
            IF tax_type_tab( i ) = 1 THEN
               v_amt := NVL( p_assessable_value, p_price );
            ELSIF tax_type_tab(i) = 4 THEN     -- Ravi for VAT
               v_amt := NVL( p_vat_assess_value, p_price );
            ELSIF v_amt = 0 OR tax_type_tab(i) <> 1 THEN
               v_amt := p_price;
            END IF;
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
        IF counter = max_iter THEN --AND tax_type_tab( I ) IN ( 1, 2 ) THEN
            -- cbabu for Bug# 3026084
            -- IF tax_rate_tab(I) <> -1 THEN    -- 5/3/2002 cbabu
            IF tax_rate_tab(I) <> -99999 THEN
              v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), rnd_factor(I) );
            ELSE
              v_tax_amt := ROUND( tax_amt_tab( I ), rnd_factor(I) ); --  5/3/2002 cbabu
            END IF;
          /*ELSIF counter = max_iter AND tax_type_tab( I ) NOT IN ( 1, 2 ) THEN
             v_tax_amt := ROUND( v_tax_amt + ( vamt * ( tax_rate_tab( i )/100)), 2 );
            */
        ELSE
            -- cbabu for Bug# 3026084
            -- IF tax_rate_tab(I) <> -1 THEN -- 5/3/2002 cbabu
            IF tax_rate_tab(I) <> -99999 THEN
              v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
            ELSE
              v_tax_amt := tax_amt_tab( I ); -- 5/3/2002 cbabu
            END IF;
        END IF;
        tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
        --cbabu for Bug# 3026084
        ELSIF tax_rate_tab( i ) = -99999 AND End_Date_Tab(I) <> 0  THEN
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
  END IF;
--==========================================================================================================

    IF p_type = 'REQUISITION' THEN  /*********************************/
       FOR I in 1..row_count LOOP
         v_tax_amt := v_tax_amt + nvl(tax_amt_tab(I),0);
        IF tax_type_tab( i )  = 1 THEN
           bsln_amt := p_assessable_value;
        ELSIF tax_type_tab(i) = 4 THEN    -- Ravi for VAT
           bsln_amt := p_vat_assess_value;
        ELSE
           bsln_amt := p_price;
        END IF;
        UPDATE JAI_PO_REQ_LINE_TAXES
           SET Tax_Amount = nvl(tax_amt_tab(I),0),
               Tax_Target_Amount = NVL( tax_target_tab(I), 0 ) * ( 1/p_conv_rate )
         WHERE Requisition_Header_Id = p_header_id
            AND Requisition_Line_Id   = p_line_id
            AND Tax_Line_No    = I;
        END LOOP;
        P_TAX_AMOUNT := v_tax_amt;

-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
ELSIF p_type = 'RECEIPTS' THEN  /*********************************/
          FOR I in 1..row_count
          LOOP
             if lv_currency_code <> Curr_Tab(I) and  adhoc_tab(i) <> 'Y' then
                 tax_amt_tab(I) := nvl(tax_amt_tab(I),0) * (1/nvl(p_conv_rate,1));
             end if;

             v_tax_amt := v_tax_amt + nvl(tax_amt_tab(I),0);
             IF tax_type_tab( i )  = 1 THEN
                bsln_amt := p_assessable_value;
             ELSIF tax_type_tab(i) = 4 THEN
                bsln_amt := p_vat_assess_value;
             ELSE
                bsln_amt := p_price;
             END IF;

             UPDATE    jai_rcv_line_taxes
             SET       Tax_Amount             = nvl(tax_amt_tab(I),0),
                       Tax_Target_Amount      = NVL(tax_target_tab(I), 0 ) * ( 1/p_conv_rate )
             WHERE     shipment_Header_Id     = p_header_id
             AND       shipment_Line_Id       = p_line_id
             AND       Tax_Line_No            = I;
           END LOOP;
           P_TAX_AMOUNT := v_tax_amt;

       ELSIF p_type = 'ASBN' THEN  /*********************************/
            FOR I in 1..row_count
            LOOP
               v_tax_amt := v_tax_amt + nvl(tax_amt_tab(I),0);
               IF tax_type_tab( i )  = 1 THEN
                  bsln_amt := p_assessable_value;
               ELSIF tax_type_tab(i) = 4 THEN
                  bsln_amt := p_vat_assess_value;
               ELSE
                  bsln_amt := p_price;
               END IF;

               UPDATE    Jai_cmn_document_Taxes
               SET       Tax_Amt             = nvl(tax_amt_tab(I),0)
               WHERE     source_doc_id          = p_header_id
               AND       source_doc_Line_Id     = p_line_id
               AND       Tax_Line_No            = I;
             END LOOP;
           P_TAX_AMOUNT := v_tax_amt;
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

    ELSIF p_type = 'REQUISITION_BLANKET' THEN /*********************************/
       FOR I in 1..row_count LOOP
         IF v_curr = Curr_Tab(I) THEN
            conv_rate := 1;
         ELSE
            conv_rate := 1;
         END IF;
         IF tax_type_tab( i )  = 1 THEN
            bsln_amt := p_assessable_value;
         ELSIF tax_type_tab(i) = 4 THEN    -- Ravi for VAT
            bsln_amt := p_vat_assess_value;
         ELSE
            bsln_amt := p_price;
         END IF;
         v_tax_amt := v_tax_amt + nvl(tax_amt_tab(I),0);
         UPDATE JAI_PO_REQ_LINE_TAXES
            SET Tax_Amount = nvl(tax_amt_tab(I),0),
                Tax_Target_Amount = NVL( tax_target_tab(I), 0 ) * ( 1/p_conv_rate )
          WHERE Requisition_Line_Id = p_header_id
            AND Tax_Line_No    = I;
        END LOOP;
        P_TAX_AMOUNT := v_tax_amt;
    ELSIF p_type IN ( 'RELEASE', 'STANDARDPO' ) THEN /*********************************/
       FOR I IN 1 .. row_count LOOP
        IF tax_type_tab( i )  = 1 THEN
           bsln_amt := p_assessable_value;
        ELSIF tax_type_tab(i) = 4 THEN    -- Ravi for VAT
           bsln_amt := p_vat_assess_value;
        ELSE
           bsln_amt := p_price;
        END IF;
        IF p_type = 'RELEASE' THEN

           UPDATE JAI_PO_TAXES
              SET Tax_Amount = NVL( tax_amt_tab(I), 0 ),
                  Tax_Target_Amount = NVL( tax_target_tab(I), 0 ) * ( 1/p_conv_rate )
            WHERE Line_Location_Id = p_header_id
              AND Po_Line_Id = p_line_id
              AND Tax_Line_No = I;
          --Added by Kevin Cheng for Retroactive Price 2008/01/11
          --=====================================================
          IF pv_retroprice_changed = 'Y'
          THEN
            JAI_RETRO_PRC_PKG.Update_Price_Changes( pn_tax_amt         => NVL( tax_amt_tab(I), 0 )
                                                  , pn_line_no         => I
                                                  , pn_line_loc_id     => p_header_id
                                                  , pv_process_flag    => lv_process_flag
                                                  , pv_process_message => lv_process_message
                                                  );

            IF lv_process_flag IN ('EE', 'UE')
            THEN
              FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
              FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG','JAI_PO_TAX_PKG.CALCULATE_TAX.Err:'||lv_process_message);
              app_exception.raise_exception;
            END IF;
          END IF;
          --=====================================================
        ELSIF p_type = 'STANDARDPO' THEN
           UPDATE JAI_PO_TAXES
              SET Tax_Amount = NVL( tax_amt_tab(I), 0 ),
                  Tax_Target_Amount = NVL( tax_target_tab(I), 0 ) * ( 1/p_conv_rate )
            WHERE Line_Location_Id = p_line_loc_id
              AND Po_Line_Id = p_line_id
              AND Tax_Line_No = I;
          --Added by Kevin Cheng for Retroactive Price 2008/01/11
          --=====================================================
          IF pv_retroprice_changed = 'Y'
          THEN
            JAI_RETRO_PRC_PKG.Update_Price_Changes( pn_tax_amt         => NVL( tax_amt_tab(I), 0 )
                                                  , pn_line_no         => I
                                                  , pn_line_loc_id     => p_line_loc_id
                                                  , pv_process_flag    => lv_process_flag
                                                  , pv_process_message => lv_process_message
                                                  );

            IF lv_process_flag IN ('EE', 'UE')
            THEN
              FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
              FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG','JAI_PO_TAX_PKG.CALCULATE_TAX.Err:'||lv_process_message);
              app_exception.raise_exception;
            END IF;
          END IF;
          --=====================================================
        END IF;
       END LOOP;
       IF p_type = 'RELEASE' THEN
          OPEN  Fetch_Sum_Cur( p_header_id );
          FETCH Fetch_Sum_Cur INTO v_tax_amt;
          CLOSE Fetch_Sum_Cur;

          UPDATE JAI_PO_LINE_LOCATIONS
             SET Tax_Amount = NVL( v_tax_amt, 0 ),
                 Total_Amount = v_tax_amt + p_price
           WHERE Line_Location_Id = p_header_id
             AND Po_Line_Id = p_line_id;
      ELSIF p_type = 'STANDARDPO' THEN
          OPEN  Fetch_Sum_Cur( p_line_loc_id );
          FETCH Fetch_Sum_Cur INTO v_tax_amt;
          CLOSE Fetch_Sum_Cur;

          UPDATE  JAI_PO_LINE_LOCATIONS
          SET     Tax_Amount = NVL( v_tax_amt, 0 ),
              Total_Amount = v_tax_amt + p_price
          WHERE   Line_Location_Id = p_line_loc_id
           AND    Po_Line_Id = p_line_id;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    p_tax_amount := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;

  END calculate_tax;

/* ----------------------------------------------------------------------------------------*/


/* ----------------------------------------------------------------------------------------*/

  PROCEDURE batch_quot_taxes_copy
  (
    p_errbuf OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY VARCHAR2
  )
  IS
    v_errbuf                VARCHAR2(1996);
    v_retcode               VARCHAR2(1996);

    lv_app_name   fnd_application.application_short_name%type ;
    lv_conc_name  fnd_concurrent_programs.concurrent_program_name%type ;

    v_rowid                 ROWID;
    error_from_called_unit  EXCEPTION;
    v_error_mesg            VARCHAR2(1996);
    v_qty                   NUMBER;
    v_line_location_id      NUMBER;

    v_total NUMBER; --File.Sql.35 Cbabu  := 0;
    v_processed NUMBER; --File.Sql.35 Cbabu  := 0;

    CURSOR c_line_location_qty( p_line_location_id IN NUMBER) IS
      SELECT quantity
      FROM po_line_locations_all
      WHERE line_location_id = p_line_location_id;

    CURSOR c_enable_trace IS
      SELECT enable_trace
      FROM fnd_concurrent_programs a, fnd_application b
      WHERE b.application_short_name = lv_app_name --'PO'
      AND b.application_id = a.application_id
      AND a.concurrent_program_name = lv_conc_name;  --'JAINPOTD';/* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

    CURSOR get_audsid IS
      SELECT a.sid, a.serial#, b.spid FROM v$session a,v$process b
      WHERE audsid = userenv('SESSIONID')
      AND a.paddr = b.addr;

    CURSOR get_dbname IS
      SELECT name FROM v$database;

    v_enable_trace fnd_concurrent_programs.enable_trace%TYPE;
    audsid  NUMBER; --File.Sql.35 Cbabu  := userenv('SESSIONID');
    sid   V$SESSION.SID%TYPE;
    serial  V$SESSION.SERIAL#%TYPE;
    spid  V$PROCESS.SPID%TYPE;
    v_name1 V$DATABASE.NAME%TYPE;


   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.batch_quot_taxes_copy';
  BEGIN

  /*------------------------------------------------------------------------------------------------------------------------
  S.No      DATE                Author AND Details
  ---------------------------------------------------------------------------------------------------------------------------
  1 19-SEP-2002   Vijay Shankar, Created this procedure. Bug#2541354 (enhancement for KOEL)
            This trigger was created to move the processing of shipment lines while PO gets generated
            ja_in_bulk_po_quot_taxes_pfrom Quotation (used from MRP also). the concurrent was getting submitted for every shipment
            ja_in_bulk_po_quot_taxes_pline of the PO, to default the tax lines. With this procedure all such shipment lines
            will be processed as 1 concurrent. The temporary table used here is being populated from the
            trigger ja_in_po_tax_insert_trg on PO_LINE_LOCATIONS_ALL. The main concepts
            used here are,
              - if an error occurs while processing a particular record, the program will skip processing
              all other shipment lines of the error PO(Purchase Order).
              - the program will continue to process other PO's.
              - the program will update the temporary table for the error record, with error flag time and error
              - if a particular line has error flag set to 'Y', this program will not pick up that record and
              also all other lines pertaining to such an error PO.
             The concurrent which is referring this procedure needs to be trace enabled( useful when there is some problem
            with the concurrent). In order to get the trace the DBA should query for JAINPOTD concurrent and check the
            'Trace Enabled' flag which is used in this concurrent to create level 4 trace.
  ------------------------------------------------------------------------------------------------------------------------ */

    v_total  := 0;
    v_processed  := 0;
    audsid  := userenv('SESSIONID');

    FND_FILE.put_line(FND_FILE.LOG, 'Start procedure - Ja_In_Bulk_PO_Tax_Insert');
    -- this cursor picks up the PO Shipment lines from the temporary table but does not pick up such shipment lines
    -- which have error_flag set to 'Y' for any of it's Shipment lines.

/* Added by Ramananda for removal of SQL LITERALs */
    lv_app_name  :=  'PO';
    lv_conc_name := 'JAINPOTD';
    OPEN c_enable_trace;
    FETCH c_enable_trace INTO v_enable_trace;
    CLOSE c_enable_trace;

    IF nvl(v_enable_trace, 'N') = 'Y' THEN
      OPEN get_audsid;
      FETCH get_audsid INTO sid, serial, spid;
      CLOSE get_audsid;

      /* code commented by aiyer for the bug 4517919
      DBMS_SUPPORT.START_TRACE_IN_SESSION( sid, serial, waits => false, binds=>true);
      */
      /*
      ||Opened the existing cursor to get the database name
      || and called fnd_file.put_line to register the info
      || also changed the dbms_support.start and stop trace to execute immediate alter session code
      */
      OPEN get_dbname;
      FETCH get_dbname INTO v_name1;
      CLOSE get_dbname;

      FND_FILE.PUT_LINE( FND_FILE.log, 'TraceFile Name = '||lower(v_name1)||'_ora_'||spid||'.trc');
      EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
    END IF;

    FOR c_rec IN
    (
      SELECT
        ROWID,
        po_header_id,
        po_line_id,
        line_location_id,
        from_header_id,
        from_line_id,
        price_override,
        uom_code,
        assessable_value,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
      FROM JAI_PO_QUOT_LINES_T
      WHERE nvl(error_flag, 'N') <> 'Y'
      ORDER BY  po_header_id, po_line_id
    )
    LOOP
      v_line_location_id := c_rec.line_location_id;
      v_rowid := c_rec.ROWID;
      v_errbuf := NULL;
      v_retcode := NULL;
      v_error_mesg := NULL;

      BEGIN

        OPEN c_line_location_qty( v_line_location_id );
        FETCH c_line_location_qty INTO v_qty;
        CLOSE c_line_location_qty;

        -- Call the procedure which defaults the taxes from Quotation to PO and inserts shipment lines into
        -- JA tables
        jai_po_tax_pkg.copy_quot_taxes(
          errbuf      => v_errbuf,
          retcode     => v_retcode,
          p_line_loc_id   => v_line_location_id,
          p_po_hdr_id   => c_rec.po_header_id,
          p_po_line_id  => c_rec.po_line_id,
          p_qty       => v_qty,
          p_frm_hdr_id  => c_rec.from_header_id,
          p_frm_line_id => c_rec.from_line_id,
          p_price     => c_rec.price_override,
          p_unit_code   => c_rec.uom_code,
          p_assessable_value => c_rec.assessable_value,
          p_cre_dt    => nvl(c_rec.creation_date, SYSDATE),
          p_cre_by    => nvl(c_rec.created_by, FND_GLOBAL.USER_ID),
          p_last_upd_dt => nvl(c_rec.last_update_date, SYSDATE),
          p_last_upd_by => nvl(c_rec.last_updated_by, FND_GLOBAL.USER_ID),
          p_last_upd_login=> nvl(c_rec.last_update_login, FND_GLOBAL.LOGIN_ID)
        );

        -- check whether called procedure returned any error
        IF ( v_errbuf IS NOT NULL) THEN
          v_error_mesg := 'Error from called unit jai_po_tax_pkg.copy_quot_taxes -> '||v_errbuf;
          RAISE  error_from_called_unit;
        END IF;

        DELETE FROM JAI_PO_QUOT_LINES_T
          WHERE rowid = v_rowid;

        COMMIT;

        v_processed := v_processed + 1;
      EXCEPTION

        WHEN OTHERS THEN
          IF v_error_mesg IS NULL  THEN
            -- the exception condition is not because of returned error from jai_po_tax_pkg.copy_quot_taxes
            v_error_mesg := 'Error in main for loop. SQLERRM -> '|| SQLERRM;
          END IF;

          ROLLBACK;

        -- update the record for error
          UPDATE JAI_PO_QUOT_LINES_T
          SET error_flag = 'Y',
            processing_time = SYSDATE,
            error_message = v_error_mesg
          WHERE  ROWID = v_rowid;

          COMMIT;

        FND_FILE.put_line(FND_FILE.LOG, v_error_mesg || ' : FOR line_location_id = ' ||  v_line_location_id || ', Quantity = ' || v_qty);
      END;

      FND_FILE.put_line(FND_FILE.LOG, ' Processed line_location_id = ' || v_line_location_id);

      END LOOP;   -- CURSOR FOR

    FND_FILE.put_line(FND_FILE.LOG, 'Tax Defaultation is SUCCESSFUL. END PROCEDURE - JA_IN_BULK_PO_QUOT_TAXES - '||v_processed||'/'||v_total||' records processed.');

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END  batch_quot_taxes_copy;

/*------------------------------------------------------------------------------------------*/

  PROCEDURE copy_reqn_taxes
  (
    p_Vendor_Id number,
    p_Vendor_Site_Id number,
    p_Po_Header_Id number,
    p_Po_Line_Id number, --added by Sriram on 22-Nov-2001
    p_line_location_id number, --added by Sriram on 22-Nov-2001
    p_Type_Lookup_Code varchar2,
    p_Quotation_Class_Code varchar2,
    p_Ship_To_Location_Id number,
    p_Org_Id number,
    p_Creation_Date date,
    p_Created_By number,
    p_Last_Update_Date date,
    p_Last_Updated_By number,
    p_Last_Update_Login number
    /* Brathod, For Bug# 4242351 */
    ,p_rate         PO_HEADERS_ALL.RATE%TYPE      DEFAULT NULL
    ,p_rate_type      PO_HEADERS_ALL.RATE_TYPE%TYPE DEFAULT NULL
    ,p_rate_date     PO_HEADERS_ALL.RATE_DATE%TYPE DEFAULT NULL
    ,p_currency_code PO_HEADERS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
    /* End of Bug# 4242351 */
    )
  IS
      v_vendor_id         NUMBER; --File.Sql.35 Cbabu          :=  NVL( p_Vendor_Id, 0 );
      v_vendor_site_id    NUMBER; --File.Sql.35 Cbabu           :=  NVL( p_Vendor_Site_Id, 0 );
      v_po_hdr_id         NUMBER; --File.Sql.35 Cbabu           :=  p_Po_Header_Id;
      v_type_lookup_code  VARCHAR2(30); --File.Sql.35 Cbabu     :=  p_Type_Lookup_Code;
      v_quot_class_code   VARCHAR2(30); --File.Sql.35 Cbabu     :=  p_Quotation_Class_Code;
      v_ship_loc_id       NUMBER; --File.Sql.35 Cbabu           :=  p_Ship_To_Location_Id;
      v_org_id            NUMBER ;
      v_po_org_id         NUMBER; --File.Sql.35 Cbabu           :=  NVL( p_Org_Id, -999 );

      v_rate      NUMBER;
      v_rate_type   VARCHAR2(100);
      v_rate_date   DATE ;

      v_ship_to_loc_id  NUMBER; --File.Sql.35 Cbabu       :=  p_Ship_To_Location_Id;
      v_next_val    NUMBER;
      line_loc_flag   BOOLEAN;
      v_assessable_value  NUMBER;
      ln_vat_assess_value NUMBER; -- added rallamse bug#4250072
      v_func_curr         VARCHAR2(15);

      v_curr              VARCHAR2(100); --added by Sriram on 22-Nov-2001
      v_conv_rate         NUMBER;
      flag      VARCHAR2(10);
      v_line_cnt    NUMBER;
      v_tax_flag    VARCHAR2(1);
      v_old_vendor_id NUMBER;
      v_item_id   NUMBER;
      v_qty     NUMBER;
      v_price     NUMBER;
      v_uom     VARCHAR2(25);
      v_line_uom    VARCHAR2(25);
      v_cre_dt    DATE; --File.Sql.35 Cbabu             :=  p_Creation_Date;
      v_cre_by    NUMBER; --File.Sql.35 Cbabu       :=  p_Created_By;
      v_last_upd_dt   DATE ; --File.Sql.35 Cbabu            :=  p_Last_Update_Date;
      v_last_upd_by   NUMBER; --File.Sql.35 Cbabu           :=  p_Last_Updated_By;
      v_last_upd_login  NUMBER; --File.Sql.35 Cbabu       :=  p_Last_Update_Login;
      v_po_line_id1       NUMBER; --File.Sql.35 Cbabu  := p_Po_Line_Id; --added by Sriram on 22-Nov-2001
      v_line_location_id  NUMBER; --File.Sql.35 Cbabu  := p_line_location_id; --added by Sriram on 22-Nov-2001
      v_error  VARCHAR2(20) ;
      v_service_type_code varchar2(30);
    ------------------------------  ------------------------------  ------------------------------  ------------------------------

    -- Get the Inventory Organization Id

      CURSOR Fetch_Org_Id_Cur IS SELECT Inventory_Organization_id
                     FROM   Hr_Locations
                     WHERE  Location_Id = v_ship_loc_id;

    ------------------------------  ------------------------------  ------------------------------  ------------------------------

    -- Get the Line Focus Id from the Sequence

      CURSOR Fetch_Focus_Id IS SELECT JAI_PO_LINE_LOCATIONS_S.NEXTVAL
                 FROM   Dual;

    ------------------------------  ------------------------------  ------------------------------  ------------------------------

      CURSOR Lines_Cur IS SELECT DISTINCT Po_Line_Id
              FROM   Po_Line_Locations_all
              WHERE  Po_Header_Id = v_po_hdr_id;

      CURSOR Fetch_Item_Cur( Lineid IN NUMBER ) IS SELECT Item_Id
                   FROM   Po_Lines_All
                   WHERE  Po_Line_Id = Lineid;

      CURSOR Line_Loc_Cur( lineid IN NUMBER ) IS SELECT Line_Location_Id
                           FROM   po_line_locations_all
                           WHERE  Po_Line_Id = lineid;

    ------------------------------  ------------------------------  ------------------------------  ------------------------------

      CURSOR Fetch_Dtls_Cur( lineid IN NUMBER ) IS SELECT Quantity, Unit_Price, Unit_Meas_Lookup_Code
                       FROM   Po_Lines_All
                         WHERE  Po_Line_Id = lineid;

      CURSOR Fetch_Dtls1_Cur( lineid IN NUMBER, linelocid IN NUMBER ) IS SELECT Quantity, Price_Override,
                                Unit_Meas_Lookup_Code
                                 FROM   Po_Line_Locations_All
                                   WHERE  Po_Line_Id = lineid
                          AND   Line_Location_Id = linelocid;
    -- Get the Uom Code

      CURSOR Fetch_UOMCode_Cur IS SELECT Uom_Code
                  FROM   Mtl_Units_Of_Measure
                  WHERE  Unit_Of_Measure = v_uom;

      lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.copy_reqn_taxes';
  BEGIN

  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - jai_po_tax_pkg.copy_reqn_taxes.sql
  S.No  Date         Author and Details
  -------------------------------------------------------------------------------------------------------------------------
  1     22/11/2001   sriram bug# Version#115.1

  2.    14/03/2005   bug#4250072  rallamse Version# 115.2
                     Changes for VAT implementation

  3.    31/03/2005   Brathod, Bug#4242351, Version 115.3
                     Issue:-    Cursor get_po_hdr having a select statement on table po_headers_all
                                was raising mutating error.
                     Solution:- Four new parameters are passed to the procedure
                                to avoid select statement.
4.                   Kunkumar Added v_service_type_code and its manipulations for forward porting to R12.
  ===============================================================================

  Dependencies

  Version   Author     Dependencies           Comments
  115.2     rallamse   IN60106+4245089        Changes for VAT implementation

  --------------------------------------------------------------------------------------------------------------------------*/

       --File.Sql.35 Cbabu
       v_vendor_id            :=  NVL( p_Vendor_Id, 0 );
      v_vendor_site_id        :=  NVL( p_Vendor_Site_Id, 0 );
      v_po_hdr_id             :=  p_Po_Header_Id;
      v_type_lookup_code      :=  p_Type_Lookup_Code;
      v_quot_class_code       :=  p_Quotation_Class_Code;
      v_ship_loc_id           :=  p_Ship_To_Location_Id;
      v_ship_to_loc_id        :=  p_Ship_To_Location_Id;
      v_cre_dt                :=  p_Creation_Date;
      v_cre_by                :=  p_Created_By;
      v_last_upd_dt           :=  p_Last_Update_Date;
      v_last_upd_by           :=  p_Last_Updated_By;
      v_last_upd_login        :=  p_Last_Update_Login;
      v_po_line_id1           := p_Po_Line_Id; --added by Sriram on 22-Nov-2001
      v_line_location_id      := p_line_location_id; --added by Sriram on 22-Nov-2001

       -- Get the Inventory Organization Id

        OPEN  Fetch_Org_Id_Cur;
        FETCH Fetch_Org_Id_Cur INTO v_org_id;
        CLOSE fetch_Org_Id_Cur;

        /* Commented/Added by brathod, For Bug# 4242351 */
        -- OPEN get_po_hdr(v_po_hdr_id);
        -- FETCH get_po_hdr into v_rate,v_rate_type,v_rate_date,v_curr;
        -- CLOSE get_po_hdr;

        v_rate       :=  p_rate          ;
        v_rate_type  :=  p_rate_type     ;
        v_rate_date  :=  p_rate_date     ;
        v_curr       :=  p_currency_code ;

        /* End of Bug#4242351 */

        IF NVL( v_Line_Location_Id, -999 ) = -999
        THEN

          OPEN  Fetch_Dtls_Cur( v_po_Line_Id1 );
          FETCH Fetch_Dtls_Cur INTO v_qty, v_price, v_uom;
          CLOSE Fetch_Dtls_Cur;

          v_line_uom := v_uom;
          line_loc_flag := FALSE;
        ELSE

          OPEN  Fetch_Dtls1_Cur( v_Po_Line_Id1, v_Line_Location_Id );
          FETCH Fetch_Dtls1_Cur INTO v_qty, v_price, v_uom;
          CLOSE Fetch_Dtls1_Cur;

          IF v_uom IS NULL
          THEN
            FOR uom_rec IN  Fetch_Dtls_Cur( v_Po_Line_Id1 )
            LOOP
              v_uom := uom_rec.unit_meas_lookup_code;
            END LOOP;
          END IF;

          line_loc_flag := TRUE;
        END IF;

        OPEN  Fetch_UOMCode_Cur;
        FETCH Fetch_UOMCode_Cur INTO v_uom;
        CLOSE Fetch_UOMCode_Cur;

        OPEN  Fetch_Item_Cur( v_Po_Line_Id1 );
        FETCH Fetch_Item_Cur INTO v_item_id;
        CLOSE Fetch_Item_Cur;

        v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value
                                                ( v_vendor_id,
                                                  v_vendor_site_id,
                                                  v_item_id,
                                                  v_uom
                                                 );

        v_conv_rate := v_rate;

        jai_po_cmn_pkg.get_functional_curr
                              ( v_ship_to_loc_id, v_po_org_id, v_org_id,
                                v_curr, v_assessable_value,
                                v_conv_rate, v_rate_type, v_rate_date, v_func_curr
                               );

        IF NVL( v_assessable_value, 0 ) <= 0
        THEN
          v_assessable_value := v_price * v_qty;
        ELSE
          v_assessable_value := v_assessable_value * v_qty;
        END IF;

        /* Begin - Bug#4250072 - Added by rallamse for VAT */

        ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value (
                                                            p_party_id          => v_vendor_id,
                                                            p_party_site_id     => v_vendor_site_id,
                                                            p_inventory_item_id => v_item_id,
                                                            p_uom_code          => v_uom,
                                                            p_default_price     => v_price,
                                                            p_ass_value_date    => trunc(sysdate) ,
                                                            p_party_type        => 'V'
                                                          );
        v_conv_rate := v_rate;

        jai_po_cmn_pkg.get_functional_curr
                          ( v_ship_to_loc_id, v_po_org_id, v_org_id,
                            v_curr, ln_vat_assess_value,
                            v_conv_rate, v_rate_type, v_rate_date, v_func_curr
                           );

        ln_vat_assess_value := ln_vat_assess_value * v_qty ;

        /* End - Bug#4250072  - Added by rallamse for VAT */

        OPEN  Fetch_Focus_Id;
        FETCH Fetch_Focus_Id INTO v_next_val;
        CLOSE Fetch_Focus_Id;

v_service_type_code :=jai_ar_rctla_trigger_pkg.get_service_type(v_vendor_id,v_vendor_site_id,'V');


        INSERT INTO JAI_PO_LINE_LOCATIONS( Line_Focus_Id, Line_Location_Id, Po_Line_Id, Po_Header_Id,
           Tax_Modified_Flag, Tax_Amount, Total_Amount,
           Creation_Date, Created_By, Last_Update_Date, Last_Updated_By,
           Last_Update_Login,Service_type_code )
        VALUES
          ( v_next_val, v_Line_Location_Id, v_po_line_id1, v_po_hdr_id,
           'N', 0, 0,
           v_cre_dt, v_cre_by, v_last_upd_dt, v_last_upd_by,
           v_last_upd_login,v_service_type_code );

        IF v_type_lookup_code = 'BLANKET' OR
             v_quot_class_code = 'CATALOG'
        THEN
        --Addition by Ramakrishna on 15/12/2000 to check taxes defaulting
         if v_line_location_id is null
             then
               flag := 'INSLINES';
             else
               flag := 'I';
             end if;
        --end of addition by Ramakrishna
          ELSE
            flag := 'I';
          END IF;

          jai_po_tax_pkg.Ja_In_Po_Case2( v_Type_Lookup_Code,
                                                 v_Quot_Class_Code,
                                                 v_Vendor_Id,
                                                 v_Vendor_Site_Id,
                                               --p_Currency_Code,
                                                 v_curr,
                                                 v_org_id,
                                                 v_Item_Id,
                                                 v_Line_Location_Id,
                                                 v_po_hdr_id,
                                                 v_Po_Line_Id1,
                                                 v_price,
                                                 v_qty,
                                                 v_cre_dt,
                                                 v_cre_by,
                                                 v_last_upd_dt,
                                                 v_last_upd_by,
                                                 v_last_upd_login,
                                                 v_uom,
                                                 flag,
                                                 NVL( v_assessable_value, -9999 ),
                                                 ln_vat_assess_value,
                                                 NVL( v_conv_rate, 1 ) );

       /**    jai_po_tax_pkg.calculate_tax( 'STANDARDPO', v_po_hdr_id , v_Po_Line_Id1, v_line_location_id,
                           v_qty, v_price*v_qty, v_uom, v_assessable_value,
                           NVL( v_assessable_value, v_price*v_qty ), NULL, nvl(v_conv_rate,1));


      END LOOP;
    END LOOP;**/ --commented by Sriram on 22-Nov-2001

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END copy_reqn_taxes;

/* ------------------------------------------------------------------------------------------------------*/

  PROCEDURE calc_tax(
  -- Do not use this function to pass line_location_id in place of header_id, use relevant fields to pass
  -- the parameters
    p_type      IN  VARCHAR2,   -- Contains the type of document
    p_header_id   IN  NUMBER,     -- Contains the header_id of the document
    P_line_id   IN  NUMBER,     -- Contains the line_id of the document
    p_line_location_id  IN  NUMBER,   -- Shipment line_id of the PO Document
    p_line_focus_id IN  NUMBER,     -- unique key of JAI_PO_LINE_LOCATIONS table
    p_line_quantity IN  NUMBER,     -- quantity given in the line
    p_base_value  IN  NUMBER,     -- base value of the line i.e quantity * base price of item
    p_line_uom_code IN  VARCHAR2,   -- uom_code of the line item
    p_tax_amount  IN OUT NOCOPY  NUMBER,    -- total tax amount that should be returned to the calling procedure
    p_assessable_value  IN NUMBER DEFAULT NULL, -- assessable value of line on which excise duty is calculated i.e quantity * assessable_price
    p_vat_assess_value  IN NUMBER, -- vat assessable value /* rallamse bug#4250072 VAT */
    p_item_id     IN NUMBER DEFAULT NULL, -- inventory item given in the line
    p_conv_rate     IN NUMBER DEFAULT NULL, -- Convertion rate from Functional to PO currency
    p_po_curr   IN VARCHAR2 DEFAULT NULL, -- PO Header or Requisition line currency
    p_func_curr   IN VARCHAR2 DEFAULT NULL,  -- Functional currency of the organization or operating unit
    p_requisition_line_id   IN NUMBER   DEFAULT NULL    --Bgowrava for Bug#5877782
  , pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price on 2008/01/09
  ) IS

  -- The parameter p_conv_rate should contain the value which tells the no of FUNCTIONAL currency units for one foreign currency unit
  -- i.e functional_curr_tax_amount := PO_curr_tax_amount(foreign currency) * p_conv_rate
  -- eg. Amount in INR(FUNCTIONAL) = 1USD(FOREIGN) * 50 (50 is the p_conv_rate)

  /*
    Bug#2097413 is fixed on 09-nov-01 by subbu. Bug is raised for adhoc tax amounts are not
    coming FROM Requisition to Purchase Order instead adhoc tax amount coming as zero.This bug
    solved this bug and also considered Excise type of tax with UOM rate. Earlier this procedure
    solved Negative tax amounts bug.
  */
    TYPE num_tab IS TABLE OF NUMBER/*(14,3)Modified by Kevin Cheng for inclusive tax Dec 17, 2007*/ INDEX BY BINARY_INTEGER;
    TYPE tax_amt_num_tab IS TABLE OF NUMBER/*(25,3)Modified by Kevin Cheng for inclusive tax Dec 17, 2007*/ INDEX BY BINARY_INTEGER;
    TYPE currency_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE adhoc_flag_tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER; -- added for Bug#2097413
    TYPE uom_code_tab IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER; --pramasub for #6137011

    p1        NUM_TAB;
    p2        NUM_TAB;
    p3        NUM_TAB;
    p4        NUM_TAB;
    p5        NUM_TAB;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    p6        NUM_TAB;
    p7        NUM_TAB;
    p8        NUM_TAB;
    p9        NUM_TAB;
    p10        NUM_TAB;

-- END BUG 5228046

    rnd_factor                    NUM_TAB;
    p_inventory_item_id           NUMBER;
    tax_rate_tab                  NUM_TAB;
    tax_type_tab                  NUM_TAB;
    end_date_tab                  NUM_TAB;
    -- This is used mainly for adhoc taxes and not for taxes which has rates attached with them
    initial_tax_amt_t            TAX_AMT_NUM_TAB;

    tax_amt_tab                  TAX_AMT_NUM_TAB;
    tax_target_tab               TAX_AMT_NUM_TAB;
    curr_tab                     CURRENCY_TAB;
    adhoc_tab                    ADHOC_FLAG_TAB; -- added for Bug#2097413
    qty_tab                      NUM_TAB;
    uom_tab                      UOM_CODE_TAB; --pramasub for #6137011

    v_amt                        NUMBER;
    bsln_amt                     NUMBER; --File.Sql.35 Cbabu  := p_tax_amount;
    row_count                    NUMBER; --File.Sql.35 Cbabu  := 0;
    v_tax_amt                    NUMBER/*(25,3) Comment out by Kevin Cheng for bug 6838743 Feb 26, 2008*/; --File.Sql.35 Cbabu  := 0;
    vamt                         NUMBER/*(25,3) Comment out by Kevin Cheng for bug 6838743 Feb 26, 2008*/; --File.Sql.35 Cbabu  := 0;
    max_iter                     NUMBER  ;  -- Changed from 10 to 15 for bug 5228046
    v_conversion_rate            NUMBER;
    counter                      NUMBER;
    conv_rate                    NUMBER;
    v_rnd_factor                 NUMBER;

    v_curr                       VARCHAR2(30); --File.Sql.35 Cbabu   :=  p_line_uom_code;
    v_line_uom_code              VARCHAR2(30); --File.Sql.35 Cbabu  := p_line_uom_code;
    v_debug                      VARCHAR(1); --File.Sql.35 Cbabu  := 'N'; -- cbabu for Bug# 2659815

    v_adhoc_tax_amt              NUMBER;
    v_adhoc_flag                 VARCHAR2(1);
    v_qty_rate                   NUMBER;


    -- start, cbabu for Bug# cbabu for Bug# 2659815
    v_conv_rate                  NUMBER;
    v_po_curr                    VARCHAR2(30);
    v_func_curr                  VARCHAR2(30);
    v_sob                        NUMBER;
    v_org_id                     NUMBER;

    --Add by Kevin Cheng for inclusive tax Dec 17, 2007
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
    lt_func_tax_amt_tab          TAX_AMT_NUM_TAB;
    lv_uom_code                  VARCHAR2(10) := 'EA';
    lv_register_code             VARCHAR2(20);
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
    ln_assessable_value          NUMBER;
    ln_vat_assessable_value      NUMBER;
    ---------------------------------------------------
    CURSOR c_po_hdr_curr(p_po_header_id IN NUMBER) IS
            SELECT currency_code, org_id
            FROM po_headers_all
            WHERE po_header_id = p_po_header_id;

/*cursor modified to use headers instead of lines as it is mutating in reqn triggers
    for bug#5877782*/
    CURSOR c_reqn_curr(p_reqn_header_id IN NUMBER) IS
           SELECT  org_id
           FROM po_requisition_headers_all
           WHERE requisition_header_id = p_reqn_header_id;


    -- end Changes, cbabu for Bug# cbabu for Bug# 2659815

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors c_sob and c_func_curr
     * and implemented caching logic.
     */

    CURSOR fetch_item_cur IS
      SELECT item_id
      FROM po_lines_all
      WHERE po_line_id = p_line_id;
          /* Added by LGOPALSA. Bug 4210102.
            Added CVD and Excise education cess
          */

    /* start rallamse Bug#4250072 VAT  */
    CURSOR c_reqn_line_taxes(p_requisition_line_id IN NUMBER) is
    SELECT a.tax_line_no lno,
           a.precedence_1 p_1,
           a.precedence_2 p_2,
           a.precedence_3 p_3,
           a.precedence_4 p_4,
           a.precedence_5 p_5,
           a.precedence_6 p_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
           a.precedence_7 p_7,
           a.precedence_8 p_8,
           a.precedence_9 p_9,
           a.precedence_10 p_10,
           a.tax_id,
           a.tax_rate,
           nvl(a.tax_amount, 0) tax_amt,
           b.end_date valid_date,
           b.rounding_factor rnd_factor,
           a.qty_rate,
           a.uom uom_code,
           a.currency curr,
           b.adhoc_flag,
           b.inclusive_tax_flag, -- Add by Kevin Cheng for inclusive tax Dec 17, 2007
           DECODE( aa.regime_code, 'VAT', 4 ,
           DECODE( UPPER( A.Tax_Type ),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, --'CVD', 1,
           --'ADDITIONAL_CVD',1,  -- Added by Girish , w.r.t BUG#5143906
           --commented the CVD, ADDITIONAL_CVD and cvd_edu_cess for Bug#5219225 by Sanjikum
	   /* added by ssawant for bug 5989740 */
           --Comment out by Kevin Cheng for inclusive tax Dec 17, 2007
           /*JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,1,jai_constants.tax_type_exc_edu_cess, 1,*/ --,jai_constants.tax_type_cvd_edu_cess, 1,
           --Add by Kevin Cheng for inclusive tax Dec 17, 2007
           ---------------------------------------------------
           jai_constants.tax_type_exc_edu_cess, 6,
           jai_constants.tax_type_cvd_edu_cess , 6,
           jai_constants.tax_type_sh_exc_edu_cess, 6,
           jai_constants.tax_type_sh_cvd_edu_cess, 6,
           ---------------------------------------------------
           'TDS', 2, 0
                 )
                 ) tax_type_val
     FROM  JAI_PO_REQ_LINE_TAXES a, JAI_CMN_TAXES_ALL b, jai_regime_tax_types_v aa
     WHERE requisition_line_id = p_line_id
     AND   a.Tax_Id = b.Tax_Id
     AND   aa.tax_type(+) = b.tax_type
     order by 1/*2*/;--Modified by Kevin Cheng for inclusive tax Dec 17, 2007

    /* Added by LGOPALSA. Bug 4210102.
     * Added CVD and Excise education cess
     * */

    CURSOR c_po_line_location_taxes(p_po_line_id IN NUMBER, p_line_location_id IN NUMBER) is
    SELECT A.Tax_Line_No LNo,
           A.Precedence_1 P_1,
           A.Precedence_2 P_2,
           A.Precedence_3 P_3,
           A.Precedence_4 P_4,
           A.precedence_5 P_5,
           A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
           A.Precedence_7 P_7,
           A.Precedence_8 P_8,
           A.Precedence_9 P_9,
           A.precedence_10 P_10,
           A.Tax_Id,
           DECODE( aa.regime_code, 'VAT', 4 ,
           DECODE( UPPER( A.Tax_Type ),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, --'CVD', 1,
           --'ADDITIONAL_CVD',1,  -- Added by Girish , w.r.t BUG#5143906
           --commented the CVD, ADDITIONAL_CVD and cvd_edu_cess for Bug#5219225 by Sanjikum
	   /* added by ssawant for bug 5989740 */
           --Comment out by Kevin Cheng for inclusive tax Dec 17, 2007
           /*JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,1,jai_constants.tax_type_exc_edu_cess, 1,*/ --jai_constants.tax_type_cvd_edu_cess, 1,
           --Add by Kevin Cheng for inclusive tax Dec 17, 2007
           ---------------------------------------------------
           jai_constants.tax_type_exc_edu_cess, 6,
           jai_constants.tax_type_cvd_edu_cess , 6,
           jai_constants.tax_type_sh_exc_edu_cess, 6,
           jai_constants.tax_type_sh_cvd_edu_cess, 6,
           ---------------------------------------------------
           'TDS', 2, 0
               )
               ) tax_type_val,
           A.Tax_Rate tax_rate,
           A.Qty_Rate Qty_Rate,
           A.uom uom_code,
           A.Tax_Amount,
           A.currency curr,
           B.End_Date Valid_Date,
           B.rounding_factor rnd_factor,
           B.adhoc_flag adhoc_flag
           ,b.inclusive_tax_flag --Add by Kevin for inclusive tax Dec 17, 2007
     FROM  JAI_PO_TAXES A, JAI_CMN_TAXES_ALL B, jai_regime_tax_types_v aa
     WHERE Po_Line_Id = p_po_line_id
     AND   nvl(line_location_id,-999) = p_line_location_id   /*uncommented for bug 9307152, commented line below*/
     --AND   line_location_id = p_line_location_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
     AND   A.Tax_Id = B.Tax_Id
     AND   aa.tax_type(+) = b.tax_type
     order by 1/*2*/;--Modified by Kevin Cheng for inclusive tax Dec 17, 2007
     /* end rallamse Bug#4250072 VAT implementation */

    CURSOR uom_class_cur(p_line_uom_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
      SELECT a.uom_class
      FROM mtl_units_of_measure a, mtl_units_of_measure b
      WHERE a.uom_code = p_line_uom_code
      AND b.uom_code = p_tax_line_uom_code
      AND a.uom_class = b.uom_class;

    CURSOR fetch_sum_cur( p_line_location_id IN NUMBER ) IS
      SELECT SUM( NVL( tax_amount, 0 ) )
      FROM JAI_PO_TAXES
      WHERE line_location_id = p_line_location_id   -- For Blanket Rel Line Loc Id is passed in place of header id.
      AND tax_type <> jai_constants.tax_type_tds;  --'TDS'; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

    CURSOR fetch_line_uom_code IS
      SELECT uom_code
      FROM po_lines_all plines, mtl_units_of_measure units
      WHERE plines.po_line_id = p_line_id
      AND units.unit_of_measure = plines.unit_meas_lookup_code;

      lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.calc_tax';

      /* Bug 5243532. Added by Lakshmi Gopalsami
       * Defined variable for implementing caching logic.
       */
      l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
      -- End for bug 5243532

      /*rchandan for 5961325*/
      CURSOR cur_asbn_taxes(cp_source_doc_id NUMBER, cp_source_doc_line_id NUMBER) -- pramasub added cp_source_doc_id for bug #6137011
      IS
      SELECT A.Tax_Line_No  LNo,
             A.Precedence_1 P_1,
             A.Precedence_2 P_2,
               A.Precedence_3 P_3,
               A.Precedence_4 P_4,
               A.precedence_5 P_5,
               A.Precedence_6 P_6,
               A.Precedence_7 P_7,
               A.Precedence_8 P_8,
               A.Precedence_9 P_9,
               A.precedence_10 P_10,
               A.Tax_Id,
               DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                            'EXCISE', 1,
                                                                            'ADDL. EXCISE', 1,
                                                                            'OTHER EXCISE', 1,
                                                                            --Comment out by Kevin Cheng for inclusive tax Dec 17, 2007
                                                                            /*'Excise_Education_cess', 1,
                                                                            jai_constants.tax_type_sh_exc_edu_cess,1,*/
                                                                            --Add by Kevin Cheng for inclusive tax Dec 17, 2007
                                                                            ---------------------------------------------------
                                                                            jai_constants.tax_type_exc_edu_cess, 6,
                                                                            jai_constants.tax_type_cvd_edu_cess , 6,
                                                                            jai_constants.tax_type_sh_exc_edu_cess, 6,
                                                                            jai_constants.tax_type_sh_cvd_edu_cess, 6,
                                                                            ----------------------------------------------------
                                                                            'TDS', 2,
                                                                          0)) tax_type_val,
               A.Tax_Rate        tax_rate,
               A.Qty_Rate        Qty_Rate,
               A.uom             uom_code,
               A.Tax_Amt         tax_amount,
               A.currency_code   curr,
               B.End_Date        Valid_Date,
               B.rounding_factor rnd_factor,
               B.adhoc_flag      adhoc_flag
               , b.inclusive_tax_flag --Add by Kevin Cheng for inclusive tax Dec 17, 2007
          FROM Jai_cmn_document_Taxes A,
               JAI_CMN_TAXES_ALL B,
               jai_regime_tax_types_v aa
         WHERE source_doc_line_id = cp_source_doc_line_id
           AND source_doc_id = cp_source_doc_id --pramasub added this condn for bug #6137011
           AND A.Tax_Id = B.Tax_Id
           AND aa.tax_type(+) = b.tax_type
      ORDER BY 1;

--Added by Kevin Cheng for Retroactive Price 2008/01/10
--==============================================================================================
    /* start rallamse Bug#4250072 VAT  */
    CURSOR c_reqn_line_taxes_retro(p_requisition_line_id IN NUMBER) is
    SELECT a.tax_line_no lno,
           a.precedence_1 p_1,
           a.precedence_2 p_2,
           a.precedence_3 p_3,
           a.precedence_4 p_4,
           a.precedence_5 p_5,
           a.precedence_6 p_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
           a.precedence_7 p_7,
           a.precedence_8 p_8,
           a.precedence_9 p_9,
           a.precedence_10 p_10,
           a.tax_id,
           a.tax_rate,
           nvl(a.tax_amount, 0) tax_amt,
           b.end_date valid_date,
           b.rounding_factor rnd_factor,
           a.qty_rate,
           a.uom uom_code,
           a.currency curr,
           b.adhoc_flag,
           DECODE( aa.regime_code, 'VAT', 4 ,
           DECODE( UPPER( A.Tax_Type ),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, --'CVD', 1,
           --'ADDITIONAL_CVD',1,  -- Added by Girish , w.r.t BUG#5143906
           --commented the CVD, ADDITIONAL_CVD and cvd_edu_cess for Bug#5219225 by Sanjikum
	   /* added by ssawant for bug 5989740 */
           JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,1,jai_constants.tax_type_exc_edu_cess, 1, --,jai_constants.tax_type_cvd_edu_cess, 1,
           'TDS', 2, 0
                 )
                 ) tax_type_val
     FROM  JAI_PO_REQ_LINE_TAXES a, JAI_CMN_TAXES_ALL b, jai_regime_tax_types_v aa
     WHERE requisition_line_id = p_line_id
     AND   a.Tax_Id = b.Tax_Id
     AND   aa.tax_type(+) = b.tax_type
     order by 2;

    /* Added by LGOPALSA. Bug 4210102.
     * Added CVD and Excise education cess
     * */

    CURSOR c_po_line_location_taxes_retro(p_po_line_id IN NUMBER, p_line_location_id IN NUMBER) is
    SELECT A.Tax_Line_No LNo,
           A.Precedence_1 P_1,
           A.Precedence_2 P_2,
           A.Precedence_3 P_3,
           A.Precedence_4 P_4,
           A.precedence_5 P_5,
           A.Precedence_6 P_6, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
           A.Precedence_7 P_7,
           A.Precedence_8 P_8,
           A.Precedence_9 P_9,
           A.precedence_10 P_10,
           A.Tax_Id,
           DECODE( aa.regime_code, 'VAT', 4 ,
           DECODE( UPPER( A.Tax_Type ),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, --'CVD', 1,
           --'ADDITIONAL_CVD',1,  -- Added by Girish , w.r.t BUG#5143906
           --commented the CVD, ADDITIONAL_CVD and cvd_edu_cess for Bug#5219225 by Sanjikum
	   /* added by ssawant for bug 5989740 */
           JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,1,jai_constants.tax_type_exc_edu_cess, 1, --jai_constants.tax_type_cvd_edu_cess, 1,
           'TDS', 2, 0
               )
               ) tax_type_val,
           A.Tax_Rate tax_rate,
           A.Qty_Rate Qty_Rate,
           A.uom uom_code,
           A.Tax_Amount,
           A.currency curr,
           B.End_Date Valid_Date,
           B.rounding_factor rnd_factor,
           B.adhoc_flag adhoc_flag
           , pha.vendor_id hdr_vendor_id, a.vendor_id tax_vendor_id --Added by Kevin Cheng
     FROM  JAI_PO_TAXES A, JAI_CMN_TAXES_ALL B, jai_regime_tax_types_v aa
           , po_headers_all pha --Added by Kevin Cheng
     WHERE Po_Line_Id = p_po_line_id
     --AND   nvl(line_location_id,-999) = p_line_location_id
     AND   line_location_id = p_line_location_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
     AND   A.Tax_Id = B.Tax_Id
     AND   pha.po_header_id = A.Po_Header_Id --Added by Kevin Cheng
     AND   aa.tax_type(+) = b.tax_type
     order by 2;
     /* end rallamse Bug#4250072 VAT implementation */

     /*rchandan for 5961325*/
      CURSOR cur_asbn_taxes_retro(cp_source_doc_id NUMBER, cp_source_doc_line_id NUMBER) -- pramasub added cp_source_doc_id for bug #6137011
      IS
      SELECT A.Tax_Line_No  LNo,
             A.Precedence_1 P_1,
             A.Precedence_2 P_2,
               A.Precedence_3 P_3,
               A.Precedence_4 P_4,
               A.precedence_5 P_5,
               A.Precedence_6 P_6,
               A.Precedence_7 P_7,
               A.Precedence_8 P_8,
               A.Precedence_9 P_9,
               A.precedence_10 P_10,
               A.Tax_Id,
               DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                                                                            'EXCISE', 1,
                                                                            'ADDL. EXCISE', 1,
                                                                            'OTHER EXCISE', 1,
                                                                            'Excise_Education_cess', 1,
                                                                            jai_constants.tax_type_sh_exc_edu_cess,1,
                                                                            'TDS', 2,
                                                                          0)) tax_type_val,
               A.Tax_Rate        tax_rate,
               A.Qty_Rate        Qty_Rate,
               A.uom             uom_code,
               A.Tax_Amt         tax_amount,
               A.currency_code   curr,
               B.End_Date        Valid_Date,
               B.rounding_factor rnd_factor,
               B.adhoc_flag      adhoc_flag
          FROM Jai_cmn_document_Taxes A,
               JAI_CMN_TAXES_ALL B,
               jai_regime_tax_types_v aa
         WHERE source_doc_line_id = cp_source_doc_line_id
           AND source_doc_id = cp_source_doc_id --pramasub added this condn for bug #6137011
           AND A.Tax_Id = B.Tax_Id
           AND aa.tax_type(+) = b.tax_type
      ORDER BY 1;

  lv_tax_remain_flag          VARCHAR2(1);
  lv_process_flag             VARCHAR2(10);
  lv_process_message          VARCHAR2(2000);
--==============================================================================================
  BEGIN

  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - ja_in_po_calc_tax_p.sql
  S.No  Date  Author and Details
  -------------------------------------------------
  1.  30/12/2002  cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                  This procedure is created with this bug by getting the source from jai_po_tax_pkg.calculate_tax procedure with some modifications
                  commented with bug number. Basically two new parameters were added.
                  Initially all the plsql tables are filled with PO Currency data and finally when updating these into the database
                  they are converted back to the tax currency if there is any change in the currency.

  2.  17/12/2003  Vijay Shankar for Bug# 3324653 (3184673), FileVersion# 618.1
                   Cleanedup the code from Currency conversion handling perspective

  3.  12/03/2005  Bug 4210102. Added by LGOPALSA - Version 115.1
                  (1) Added check file syntax.
      (2) Added NOCOPY for IN OUT Parameters
      (3) Added CVD and Excise education cess

  4.  14/03/2005  Bug#4250072. rallamse - Version 115.2
                  Changed the cursor query for c_reqn_line_taxes , c_po_line_location_taxes.
                  Made changes for VAT implementation


  5.  04/07/2007  Bgowrava for bug#5877782 , File Version 120.16
		                Issue : TAX CALCULATED INCORRECTLY WHEN REQUISITION QUANTITY IS MODIFIED
		                  Fix : The cursor c_reqn_curr is modified to query from po_requistion_headers_all instead of
		                        po_requistion_lines_all as it was mutating when called from triggers on po_requistion_lines_all.

	6.  04/07/2007  Bgowrava for bug#5877782 , File Version 120.16
		                Issue : TAX CALCULATED INCORRECTLY WHEN REQUISITION QUANTITY IS MODIFIED
		                  Fix : Added a new parameter p_requisition_line_id to capture the requisition_line_id in case
		                        of REQUISITION_BLANKET as p_line_id would have po_line_id in this case.
		                        In case of requistion Blanket, v_po_curr is not populated at all. Added code to
		                        populate it with p_po_currency.
		                        Commented code to populate v_func_cur if p_func_curr is NULL
                        Added standard who columns in all update statements.

  7.  12/17/2007  Kevin Cheng   Update the logic for inclusive tax calculation

  8.  01/15/2008  Kevin Cheng   Add a branch to deal with taxes recalculate for retroactive price update

  9.  02/15/2008  Kevin Cheng   Modify code for bug 6816062.
                                reset non rate tax amount for ad hoc tax in the third calculation loop.

  10. 02/26/2008  Kevin Cheng   Modify code for bug 6838743.
                                Change variable v_tax_amt and vamt definition.
                                Remove precision restriction for these temp
                                variable, so the final result precision will
                                not be affected by them.
  ===============================================================================

  Dependencies

  Version   Author     Dependencies    Comments
  115.1     LGOPALSA   IN60106 +        Added Cess tax dependency
                       4146708

  115.2     rallamse   IN60106 +        Changes for VAT implementation
                       4146708 +
                       4245089
  --------------------------------------------------------------------------------------------------------------------------*/
  --Added by Kevin Cheng for Retroactive price 2008/01/10
  -------------------------------------------------------
  IF pv_retroprice_changed = 'N'
  THEN
  -------------------------------------------------------
   --File.Sql.35 Cbabu
    bsln_amt           := p_tax_amount;
    row_count          := 0;
    v_tax_amt          := 0;
    vamt               := 0;
    max_iter           := 15;  -- Date 03/11/2006 Bug 5228046 added by SACSETHI
    v_curr             :=  p_line_uom_code;
    v_line_uom_code    := p_line_uom_code;
    v_debug            := jai_constants.no;

  IF v_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Entered into the procedure 2' );
    fnd_file.put_line(fnd_file.log,
    -- INSERT INTO mc_debug values ( mc_debug_s.nextval,
      ' p_type -> '||p_type|| ' p_header_id -> '||p_header_id||
      ' P_line_id -> '||P_line_id|| ' p_line_location_id -> '||p_line_location_id||
      ' p_line_focus_id -> '||p_line_focus_id||
      ' p_line_quantity -> '||p_line_quantity|| ' p_base_value -> '||p_base_value);
    fnd_file.put_line(fnd_file.log, ' p_line_uom_code -> '||p_line_uom_code|| ' p_tax_amount -> '||p_tax_amount||
      ' p_assessable_value -> '||p_assessable_value|| ' p_item_id -> '||p_item_id||
      ' p_conv_rate -> '||p_conv_rate||
      ' p_po_curr -> '||p_po_curr|| ' p_func_curr -> '||p_func_curr
    );
  END IF;

  v_conv_rate := nvl( p_conv_rate, 1);
/*bgowrava for Bug#5877782*/
  IF p_type = 'REQUISITION' THEN
    OPEN c_reqn_curr(p_header_id);
    FETCH c_reqn_curr INTO  v_org_id;
    CLOSE c_reqn_curr;
    v_po_curr := p_po_curr; /*bgowrava for Bug#5877782*/
  ELSIF p_type in ('REQUISITION_BLANKET','ASBN') THEN
    v_po_curr := p_po_curr; /*bgowrava for Bug#5877782*/
  ELSE  -- means PO related shipments
    OPEN c_po_hdr_curr(p_header_id);
    FETCH c_po_hdr_curr INTO v_po_curr, v_org_id;
    CLOSE c_po_hdr_curr;
  END IF;

 /* IF p_func_curr IS NULL THEN
    Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors c_sob and c_func_curr
     * and implemented caching logic.

   l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_org_id );
   v_sob                 := l_func_curr_det.ledger_id;
   v_func_curr           := l_func_curr_det.currency_code;
  ELSE
    v_func_curr := p_func_curr;
  END IF;*/

  /*
	||bgowrava for bug#5877782. Commented the above code and added the following line
	||p_func_curr is nowhere being used so it is not required at all.
	*/
  v_func_curr := p_func_curr;

  IF p_type = 'REQUISITION' THEN

    IF p_item_id IS NULL THEN
      OPEN  Fetch_Item_Cur;
      FETCH Fetch_Item_Cur INTO p_inventory_item_id;
      CLOSE Fetch_Item_Cur;
    ELSE
      p_inventory_item_id := p_item_id;
    END IF;

    IF p_line_uom_code IS NULL THEN
      OPEN  Fetch_line_uom_code;
      FETCH Fetch_line_uom_code INTO v_line_uom_code;
      CLOSE Fetch_line_uom_code;
    END IF;

    FOR rec in c_reqn_line_taxes(p_line_id) LOOP

      P1(rec.lno) := nvl(rec.p_1,-1);
      P2(rec.lno) := nvl(rec.p_2,-1);
      P3(rec.lno) := nvl(rec.p_3,-1);
      P4(rec.lno) := nvl(rec.p_4,-1);
      P5(rec.lno) := nvl(rec.p_5,-1);

      -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      -- start bug#5228046
      P6(rec.lno) := nvl(rec.p_6,-1);
      P7(rec.lno) := nvl(rec.p_7,-1);
      P8(rec.lno) := nvl(rec.p_8,-1);
      P9(rec.lno) := nvl(rec.p_9,-1);
      P10(rec.lno) := nvl(rec.p_10,-1);
      -- end bug#5228046

      rnd_factor(rec.lno) := nvl(rec.rnd_factor,0);
      tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
      curr_tab(rec.lno) := nvl(rec.curr, v_po_curr);

      -- if tax_type is based on tax_rate then variable should be initialized with 0,
      -- if tax_type is ADHOC or UNIT RATE then they are handled later in the loop
      tax_amt_tab(rec.lno)  := 0;   -- nvl(rec.tax_amt,0);
      tax_target_tab(rec.lno) := 0;
      initial_tax_amt_t(rec.lno) := 0;
      tax_type_tab(rec.lno) := rec.tax_type_val;
      adhoc_tab(rec.lno) := nvl(rec.adhoc_flag, 'N');
      qty_tab(rec.lno) := rec.qty_rate;
      uom_tab(rec.lno) := rec.uom_code; --pramasub for #6066485

      --Add by Kevin Cheng for inclusive tax Dec 17, 2007
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

      lt_tax_amt_rate_tax_tab(rec.lno) := 0;
      lt_tax_amt_non_rate_tab(rec.lno) := 0; --tax inclusive
      lt_base_tax_amt_tab(rec.lno)     := 0;
      ---------------------------------------------------

      -- this condition will take care of the ADHOC taxes
      IF adhoc_tab(rec.lno) = 'Y' THEN

        tax_rate_tab(rec.lno) :=  -99999;
        /*tax_amt_tab(rec.lno)  := rec.tax_amt;*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        initial_tax_amt_t(rec.lno) := rec.tax_amt;
        tax_target_tab(rec.lno) := rec.tax_amt;
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.tax_amt, 0);   -- tax inclusive
        lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
        ---------------------------------------------------

      -- this condition will take care of the taxes that are UNIT RATE based , rec.qty_rate <> 0
      ELSIF adhoc_tab(rec.lno) = 'N' AND tax_rate_tab(rec.lno) = 0 THEN
        v_conversion_rate := 0;
        FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN
            INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
            IF nvl(v_conversion_rate, 0) <= 0  THEN
               v_conversion_rate := 0;
            END IF;
          END IF;
        tax_rate_tab( rec.lno ) := -99999;
        --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        --tax_amt_tab(rec.lno) := round(nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity,nvl(rec.rnd_factor,0));/*4281841*/
        initial_tax_amt_t(rec.lno) := round(nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity,nvl(rec.rnd_factor,0));/*4281841*/
        --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        --tax_target_tab(rec.lno) := tax_amt_tab(rec.lno);
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;   -- tax inclusive
        lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
        tax_target_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
        ---------------------------------------------------
        END LOOP;
      END IF;

      -- here we have to convert the tax_currency (func currency in case of foreign PO) into PO currency, so that all the
      -- taxes will be calculated in PO currency initially, then later while modifying them in database, then change them
      -- back to the tax currency
      -- ex. IF FUNCTIONAL CURRENCY -> USD, PO CURRENCY -> INR, TAX CURRENCY -> USD, then the if condition is satisfied
      IF curr_tab(rec.lno) <> v_po_curr THEN
      -- the following two lines are commented as the tax_amt becomes zero after this code execution (For UOM based rax lines in Reqn) pramasub #6066485
       -- tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) / v_conv_rate;
       -- tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
        tax_target_tab(rec.lno) := tax_target_tab(rec.lno) / v_conv_rate;
      END IF;

      IF rec.Valid_Date is NULL OR rec.Valid_Date >= Sysdate THEN
        End_Date_Tab(rec.lno) := 1;
      ELSE
        End_Date_Tab(rec.lno) := 0;
        tax_amt_tab(rec.lno)  := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;

      row_count := row_count + 1;
    END LOOP;

  ELSIF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN

    IF p_item_id IS NULL THEN
      OPEN  Fetch_Item_Cur;
      FETCH Fetch_Item_Cur INTO p_inventory_item_id;
      CLOSE Fetch_Item_Cur;
    ELSE
      p_inventory_item_id := p_item_id;
    END IF;


-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
    /*4281841 */
     IF p_line_uom_code IS NULL and p_type = 'REQUISITION_BLANKET' THEN
      /* OPEN  fetch_req_uom_code;
       FETCH fetch_req_uom_code INTO v_line_uom_code;
       CLOSE fetch_req_uom_code;*/null;
     END IF;
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

    FOR rec in c_po_line_location_taxes(p_line_id, p_line_location_id) LOOP

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


      rnd_factor(rec.lno) := nvl(rec.rnd_factor,0);
      tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
      tax_type_tab(rec.lno) := rec.tax_type_val;
      adhoc_tab(rec.lno) := nvl(rec.adhoc_flag,'N'); -- added for bug#2097413
      qty_tab(rec.lno) := rec.qty_rate; -- added for bug#2097413

      curr_tab(rec.lno) := nvl( rec.curr, v_po_curr); -- p_po_curr);  -- v_curr );
      tax_amt_tab(rec.lno) := 0;
      initial_tax_amt_t(rec.lno) := 0;
      tax_target_tab(rec.lno) := 0;

      --Add by Kevin Cheng for inclusive tax Dec 17, 2007
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

      lt_tax_amt_rate_tax_tab(rec.lno) := 0;
      lt_tax_amt_non_rate_tab(rec.lno) := 0; --tax inclusive
      lt_base_tax_amt_tab(rec.lno)     := 0;
      ---------------------------------------------------

      -- start of modifications for Bug#2097413
      -- IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 and nvl(rec.adhoc_flag,'N') = 'Y' THEN
      IF adhoc_tab(rec.lno) = 'Y' THEN

        tax_rate_tab(rec.lno) :=  -99999;
        /*tax_amt_tab(rec.lno) := nvl(rec.tax_amount,0);*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        initial_tax_amt_t(rec.lno) := nvl(rec.tax_amount,0);
        tax_target_tab(rec.lno) := nvl(rec.tax_amount,0);
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.tax_amount, 0);   -- tax inclusive
        lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
        ---------------------------------------------------

     ELSIF adhoc_tab(rec.lno) = 'N' AND qty_tab(rec.lno) <> 0 THEN -- tax_rate_tab(rec.lno) = 0 THEN
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
        v_conversion_rate := 0;
      FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
        INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0  THEN
            v_conversion_rate := 0;
          END IF;
        END IF;
      END LOOP;
      tax_rate_tab( rec.lno ) := -99999;
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      /*tax_amt_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));\*4281841*\*/
      initial_tax_amt_t(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      --tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;   -- tax inclusive
      --lt_tax_amt_non_rate_tab(rec.lno) := round(lt_tax_amt_non_rate_tab(rec.lno),nvl(rec.rnd_factor,0));
      lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
      tax_target_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
      ---------------------------------------------------
    END IF;
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

      -- THIS IS THE MAIN CHANGE FOR THE BUG# cbabu for Bug# 2659815
      -- here we have to convert the tax_currency (func currency in case of foreign PO) into PO currency, so that all the
      -- taxes will be calculated in PO currency initially, then later while modifying them in database, then change them
      -- back to the tax currency
      -- ex. FUNCTIONAL CURRENCY -> USD, PO CURRENCY -> INR, TAX CURRENCY -> USD, then the if condition is satisfied

      IF curr_tab(rec.lno) <> v_po_curr THEN
         --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
         /*tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
         tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));\*4281841*\*/
         --Add by Kevin Cheng for inclusive tax Dec 18, 2007
         ---------------------------------------------------
         lt_tax_amt_non_rate_tab(rec.lno)  := lt_tax_amt_non_rate_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
         --lt_tax_amt_non_rate_tab(rec.lno) := round(lt_tax_amt_non_rate_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
         ---------------------------------------------------
         tax_target_tab(rec.lno) := tax_target_tab(rec.lno) * v_conv_rate; -- YYYYYYY
      END IF;
      --end, cbabu for Bug# 2659815

      IF rec.Valid_Date is NULL Or rec.Valid_Date >= SYSDATE THEN
        end_date_tab(rec.lno) := 1;
      ELSE
        end_date_tab(rec.lno) := 0;
        tax_amt_tab(rec.lno)  := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      END IF;

      row_count := row_count + 1;

    END LOOP;
 ELSIF p_type IN  ( 'ASBN' ) THEN /*rchandan for 5961325*/

  FOR rec in cur_asbn_taxes( p_header_id, p_line_id ) LOOP -- pramasub added p_header_id for bug #6137011

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

    rnd_factor(rec.lno)   := nvl(rec.rnd_factor,0);
    tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
    tax_type_tab(rec.lno) := rec.tax_type_val;
    adhoc_tab(rec.lno)    := nvl(rec.adhoc_flag,'N'); -- added for bug#2097413
    qty_tab(rec.lno)      := rec.qty_rate; -- added for bug#2097413
    uom_tab(rec.lno)      := rec.uom_code; --pramasub for #6137011

    curr_tab(rec.lno)          := nvl( rec.curr, v_po_curr); -- p_po_curr);  -- v_curr );
    tax_amt_tab(rec.lno)       := 0;
    initial_tax_amt_t(rec.lno) := 0;
    tax_target_tab(rec.lno)    := 0;

    --Add by Kevin Cheng for inclusive tax Dec 17, 2007
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

    lt_tax_amt_rate_tax_tab(rec.lno) := 0;
    lt_tax_amt_non_rate_tab(rec.lno) := 0; --tax inclusive
    lt_base_tax_amt_tab(rec.lno)     := 0;
    ---------------------------------------------------

    IF adhoc_tab(rec.lno) = 'Y' THEN

      tax_rate_tab(rec.lno)      :=  -99999;
      /*tax_amt_tab(rec.lno)       := nvl(rec.tax_amount,0);*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      initial_tax_amt_t(rec.lno) := nvl(rec.tax_amount,0);
      tax_target_tab(rec.lno)    := nvl(rec.tax_amount,0);
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.tax_amount, 0);   -- tax inclusive
      lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
      ---------------------------------------------------

    ELSIF adhoc_tab(rec.lno) = 'N' AND qty_tab(rec.lno) <> 0 THEN
        v_conversion_rate := 0;
      FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
        INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0  THEN
            v_conversion_rate := 0;
          END IF;
        END IF;
      END LOOP;
      tax_rate_tab( rec.lno ) := -99999;
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      /*tax_amt_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));\*4281841*\*/
      initial_tax_amt_t(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      --tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;   -- tax inclusive
      --lt_tax_amt_non_rate_tab(rec.lno) := round(lt_tax_amt_non_rate_tab(rec.lno),nvl(rec.rnd_factor,0));
      lt_base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
      tax_target_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
      ---------------------------------------------------
    END IF;

    IF curr_tab(rec.lno) <> v_po_curr THEN
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      /*tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));\*4281841*\*/
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      lt_tax_amt_non_rate_tab(rec.lno)  := lt_tax_amt_non_rate_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
      --lt_tax_amt_non_rate_tab(rec.lno) := round(lt_tax_amt_non_rate_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
      ---------------------------------------------------
      tax_target_tab(rec.lno) := tax_target_tab(rec.lno) * v_conv_rate; -- YYYYYYY
    END IF;
    --end, cbabu for Bug# 2659815

    IF rec.Valid_Date is NULL Or rec.Valid_Date >= SYSDATE THEN
      end_date_tab(rec.lno) := 1;
    ELSE
      end_date_tab(rec.lno) := 0;
      tax_amt_tab(rec.lno)  := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    row_count := row_count + 1;

  END LOOP;

  END IF;

  bsln_amt := p_base_value;

  --Add by Kevin Cheng for inclusive tax Dec 18, 2007
  ---------------------------------------------------
  IF p_vat_assess_value <> p_base_value THEN
    ln_vat_assessable_value := p_vat_assess_value;
  ELSE
    ln_vat_assessable_value := 1;
  END IF;

  IF p_assessable_value <> p_base_value THEN
    ln_assessable_value := p_assessable_value;
  ELSE
    ln_assessable_value := 1;
  END IF;
  ---------------------------------------------------

  FOR i in 1..row_count LOOP
    IF end_date_tab(I) <> 0 THEN--Add by Kevin Cheng for inclusive tax Dec 18, 2007
    --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
    /*IF tax_type_tab(i) = 1 THEN
      bsln_amt := NVL( p_assessable_value, p_base_value );
     \* start rallamse bug#4250072 VAT *\
    ELSIF tax_type_tab(i) = 4 THEN
      bsln_amt := NVL( p_vat_assess_value, p_base_value );
    \* end rallamse Bug#4250072 VAT *\
    ELSE
      bsln_amt := p_base_value;
    END IF;*/
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      IF tax_type_tab(I) = 1
      THEN
        IF ln_assessable_value = 1
        THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 4
      THEN --IF tax_type_tab(I) = 1   THEN
        IF ln_vat_assessable_value = 1
        THEN
          bsln_amt := 1;
		      ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 6
      THEN  --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 0;
        ln_bsln_amt_nr := 0;
      ELSE --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 1;
        ln_bsln_amt_nr := 0;
      END IF; --IF tax_type_tab(I) = 1   THEN
      ---------------------------------------------------

      IF tax_rate_tab(I) <> 0 THEN --Add by Kevin Cheng for inclusive tax Dec 18, 2007

    IF p1(I) < I and p1(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p1(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p2(I) < I and p2(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p2(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p3(I) < I and p3(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p3(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p4(I) < I and p4(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p4(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p5(I) < I and p5(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p5(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) < I and p6(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p6(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p7(I) < I and p7(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p7(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p8(I) < I and p8(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p8(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p9(I) < I and p9(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p9(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p10(I) < I and p10(I) not in (-1,0) then
      vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
      ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ELSIF p10(I) = 0 then
      vamt  := vamt + bsln_amt;
      ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

-- END BUG 5228046

    IF tax_rate_tab(I) <> -99999 THEN
      v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
      IF END_date_tab(I) = 0 then
        tax_amt_tab(I) := 0;
      ELSIF END_date_tab(I) = 1 then
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
      END IF;
    ELSE
      tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
    END IF;
    --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
    --tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
    --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
    /*vamt      := 0;
    v_tax_amt := 0;*/
    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ---------------------------------------------------
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
        lt_base_tax_amt_tab(I) := vamt;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr;
        lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
        vamt := 0;
        v_tax_amt := 0;
        ln_tax_amt_nr := 0;
        ln_vamt_nr := 0;

      END IF; --IF tax_rate_tab(I) <> 0 THEN
    ELSE --IF end_date_tab(I) <> 0 THEN
      tax_amt_tab(I) := 0;
      lt_base_tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab(I) <> 0 THEN
    ---------------------------------------------------
  END LOOP;
  --i := null;

  FOR i in 1..row_count LOOP
    --i := v_taxid_tab(j);
    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ---------------------------------------------------
    IF end_date_tab( I ) <> 0 THEN
      IF tax_rate_tab(I) <> 0 THEN
    ---------------------------------------------------
    IF p1(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p1(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p2(I) > I  then
      vamt  := vamt + nvl(tax_amt_tab(p2(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p3(I) > I  then
      vamt  := vamt + nvl(tax_amt_tab(p3(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p4(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p4(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p5(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p5(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    IF p6(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p6(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p7(I) > I  then
      vamt  := vamt + nvl(tax_amt_tab(p7(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p8(I) > I  then
      vamt  := vamt + nvl(tax_amt_tab(p8(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p9(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p9(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

    IF p10(I) > I then
      vamt  := vamt + nvl(tax_amt_tab(p10(I)),0);
      ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    END IF;

-- END BUG 5228046

    IF tax_rate_tab(I) <> -99999 THEN
      v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
      IF END_date_tab(I) = 0 then
        tax_amt_tab(I) := 0;
      ELSIF END_date_tab(I) = 1 then
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
      END IF;
    ELSE -- added for Bug#2097413
      tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
    END IF;

-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
    --tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

    --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
    /*vamt      := 0;
    v_tax_amt := 0;*/
    --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ---------------------------------------------------
        lt_base_tax_amt_tab(I) := vamt;
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
        IF vamt <> 0
        THEN
          lt_base_tax_amt_tab(I) := lt_base_tax_amt_tab(I) + vamt;
        END IF;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr ;
        lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
        vamt := 0;
        ln_vamt_nr := 0;
        v_tax_amt := 0;
        ln_tax_amt_nr := 0;
      END IF; --IF tax_rate_tab(I) <> 0 THEN

    ELSE --IF end_date_tab( I ) <> 0 THEN
      lt_base_tax_amt_tab(I) := vamt;
      tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab( I ) <> 0 THEN
    ---------------------------------------------------
  END LOOP;
  --i := null;

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;
    ln_vamt_nr:= 0;   --Add by Kevin Cheng for inclusive tax Dec 18, 2007
    ln_tax_amt_nr:=0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007

    FOR i in 1..row_count LOOP
      --i := v_taxid_tab(j);

      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      IF ( tax_rate_tab( i ) <> 0 OR lt_tax_rate_zero_tab(I) = -9999) AND end_date_tab( I ) <> 0 THEN
      --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      /*IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0
        AND adhoc_tab(i) <> 'Y' AND qty_tab(i) IS NULL
      THEN*/
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      IF adhoc_tab(i) <> 'Y' AND nvl(qty_tab(i),0) = 0 /*Commented this condition qty_tab(i) IS NULL added NVL, by nprashar for bug # 8571137 */
      THEN
        -- added extra condition AND adhoc_tab(i) <> 'Y' , qty_tab(i) IS NULL for Bug#2097413
        IF tax_type_tab( i ) = 1 THEN
          --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ------------------------------------------------
          IF ln_assessable_value = 1
          THEN
            v_amt:=1;
            ln_bsln_amt_nr :=0;
          ELSE --IF ln_assessable_value = 1
            v_amt :=0;
            ln_bsln_amt_nr :=ln_assessable_value;
          END IF;
          ------------------------------------------------
          /*v_amt := NVL( p_assessable_value, p_base_value );*/--Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        /* start rallamse Bug#4250072 VAT */
        ELSIF tax_type_tab(i) = 4 THEN
          --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ------------------------------------------------
          IF ln_vat_assessable_value = 1
          THEN
            v_amt:=1;
            ln_bsln_amt_nr :=0;
          ELSE --IF ln_vat_assessable_value = 1
            v_amt :=0;
            ln_bsln_amt_nr :=ln_vat_assessable_value;
          END IF;
          ------------------------------------------------
          /*v_amt := NVL( p_vat_assess_value, p_base_value );*/--Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
        /* end rallamse Bug#4250072 VAT */
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        -------------------------------------
        ELSIF tax_type_tab(I) = 6 THEN
          v_amt:=0;
          ln_bsln_amt_nr :=0;
        -------------------------------------
        ELSIF v_amt = 0 OR tax_type_tab(i) <> 1 THEN
          /*v_amt := p_base_value;*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
          v_amt          := 1; --Added by Kevin Cheng for inclusive tax Dec 18, 2007
          ln_bsln_amt_nr := 0; --Added by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;

        IF p1( i ) <> -1 THEN
          IF p1( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p1( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p1(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p2( i ) <> -1 THEN
          IF p2( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p2( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p2(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p3( i ) <> -1 THEN
          IF p3( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p3( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p3(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p4( i ) <> -1 THEN
          IF p4( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p4( i ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p4(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p5( i ) <> -1 THEN
          IF p5( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p5( i ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p5(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  IF p6( i ) <> -1 THEN
          IF p6( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p6( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p6(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p7( i ) <> -1 THEN
          IF p7( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p7( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p7(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p8( i ) <> -1 THEN
          IF p8( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p8( I ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p8(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p9( i ) <> -1 THEN
          IF p9( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p9( i ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p9(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

        IF p10( i ) <> -1 THEN
          IF p10( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p10( i ) );
            ln_vamt_nr := ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          ELSIF p10(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
          END IF;
        END IF;

-- END BUG 5228046

  tax_target_tab(I) := vamt;
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_base_tax_amt_tab(I) := vamt;
        ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100));
        ln_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
        ---------------------------------------------------

        v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
        tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      -- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
      --tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/ --Comment out by Kevin Cheng for inclusive tax Dec 18, 2007
      -- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
      ELSIF tax_rate_tab( i ) = -99999 AND End_Date_Tab(I) <> 0  THEN
        --NULL; --Comment out by Kevin Cheng for bug 6816062 Feb 15, 2008
        ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i); --Add by Kevin Cheng for bug 6816062 Feb 15, 2008

      ELSE
        tax_amt_tab(I) := 0;
        tax_target_tab(I) := 0;
        --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        ---------------------------------------------------
        lt_base_tax_amt_tab(I) := 0;
        ln_func_tax_amt        := 0;
        ---------------------------------------------------
      END IF;
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
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
      lt_tax_amt_non_rate_tab(I):=ln_tax_amt_nr;
      ---------------------------------------------------

      IF counter = max_iter THEN
        IF END_date_tab(I) = 0 THEN
          tax_amt_tab(I) := 0;
          lt_func_tax_amt_tab(i) := 0; --Add by Kevin Cheng for inclusive tax Dec 18, 2007
        END IF;
      END IF;

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
      --Add by Kevin Cheng for inclusive tax Dec 18, 2007
      ---------------------------------------------------
      ln_func_tax_amt := 0;
      ln_vamt_nr :=0;
      ln_tax_amt_nr:=0;
      ---------------------------------------------------

    END LOOP;

  END LOOP;

  --Add by Kevin Cheng for inclusive tax Dec 18, 2007
  ---------------------------------------------------------------------------------------
  FOR I IN 1 .. ROW_COUNT
  LOOP
    IF lt_inclu_tax_tab(I) = 'Y'
    THEN
      ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
      ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
    END IF;
  END LOOP; --FOR I IN 1 .. ROW_COUNT
  ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

  IF ln_total_tax_per_rupee <> 0
  THEN
     ln_exclusive_price := (NVL(p_base_value,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
  END If;

  FOR i in 1 .. row_count
  LOOP
     tax_amt_tab (i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
     --tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,rnd_factor(I));

  END LOOP; --FOR i in 1 .. row_count
  --------------------------------------------------------------------------------------------------------

  --Added by Kevin Cheng for Retroactive Price 2008/01/10
  --======================================================================================================
  ELSIF pv_retroprice_changed = 'Y'
  THEN
       --File.Sql.35 Cbabu
    bsln_amt           := p_tax_amount;
    row_count          := 0;
    v_tax_amt          := 0;
    vamt               := 0;
    max_iter           := 15;  -- Date 03/11/2006 Bug 5228046 added by SACSETHI
    v_curr             :=  p_line_uom_code;
    v_line_uom_code    := p_line_uom_code;
    v_debug            := jai_constants.no;

  IF v_debug = 'Y' THEN
    fnd_file.put_line(fnd_file.log, 'Entered into the procedure 2' );
    fnd_file.put_line(fnd_file.log,
    -- INSERT INTO mc_debug values ( mc_debug_s.nextval,
      ' p_type -> '||p_type|| ' p_header_id -> '||p_header_id||
      ' P_line_id -> '||P_line_id|| ' p_line_location_id -> '||p_line_location_id||
      ' p_line_focus_id -> '||p_line_focus_id||
      ' p_line_quantity -> '||p_line_quantity|| ' p_base_value -> '||p_base_value);
    fnd_file.put_line(fnd_file.log, ' p_line_uom_code -> '||p_line_uom_code|| ' p_tax_amount -> '||p_tax_amount||
      ' p_assessable_value -> '||p_assessable_value|| ' p_item_id -> '||p_item_id||
      ' p_conv_rate -> '||p_conv_rate||
      ' p_po_curr -> '||p_po_curr|| ' p_func_curr -> '||p_func_curr
    );
  END IF;

  v_conv_rate := nvl( p_conv_rate, 1);
/*bgowrava for Bug#5877782*/
  IF p_type = 'REQUISITION' THEN
    OPEN c_reqn_curr(p_header_id);
    FETCH c_reqn_curr INTO  v_org_id;
    CLOSE c_reqn_curr;
    v_po_curr := p_po_curr; /*bgowrava for Bug#5877782*/
  ELSIF p_type in ('REQUISITION_BLANKET','ASBN') THEN
    v_po_curr := p_po_curr; /*bgowrava for Bug#5877782*/
  ELSE  -- means PO related shipments
    OPEN c_po_hdr_curr(p_header_id);
    FETCH c_po_hdr_curr INTO v_po_curr, v_org_id;
    CLOSE c_po_hdr_curr;
  END IF;

 /* IF p_func_curr IS NULL THEN
    Bug 5243532. Added by Lakshmi Gopalsami
     * Removed cursors c_sob and c_func_curr
     * and implemented caching logic.

   l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_org_id );
   v_sob                 := l_func_curr_det.ledger_id;
   v_func_curr           := l_func_curr_det.currency_code;
  ELSE
    v_func_curr := p_func_curr;
  END IF;*/

  /*
	||bgowrava for bug#5877782. Commented the above code and added the following line
	||p_func_curr is nowhere being used so it is not required at all.
	*/
  v_func_curr := p_func_curr;

  IF p_type = 'REQUISITION' THEN

    IF p_item_id IS NULL THEN
      OPEN  Fetch_Item_Cur;
      FETCH Fetch_Item_Cur INTO p_inventory_item_id;
      CLOSE Fetch_Item_Cur;
    ELSE
      p_inventory_item_id := p_item_id;
    END IF;

    IF p_line_uom_code IS NULL THEN
      OPEN  Fetch_line_uom_code;
      FETCH Fetch_line_uom_code INTO v_line_uom_code;
      CLOSE Fetch_line_uom_code;
    END IF;

    FOR rec in c_reqn_line_taxes_retro(p_line_id) LOOP

      P1(rec.lno) := nvl(rec.p_1,-1);
      P2(rec.lno) := nvl(rec.p_2,-1);
      P3(rec.lno) := nvl(rec.p_3,-1);
      P4(rec.lno) := nvl(rec.p_4,-1);
      P5(rec.lno) := nvl(rec.p_5,-1);

      -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      -- start bug#5228046
      P6(rec.lno) := nvl(rec.p_6,-1);
      P7(rec.lno) := nvl(rec.p_7,-1);
      P8(rec.lno) := nvl(rec.p_8,-1);
      P9(rec.lno) := nvl(rec.p_9,-1);
      P10(rec.lno) := nvl(rec.p_10,-1);
      -- end bug#5228046

      rnd_factor(rec.lno) := nvl(rec.rnd_factor,0);
      tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
      curr_tab(rec.lno) := nvl(rec.curr, v_po_curr);

      -- if tax_type is based on tax_rate then variable should be initialized with 0,
      -- if tax_type is ADHOC or UNIT RATE then they are handled later in the loop
      tax_amt_tab(rec.lno)  := 0;   -- nvl(rec.tax_amt,0);
      tax_target_tab(rec.lno) := 0;
      initial_tax_amt_t(rec.lno) := 0;
      tax_type_tab(rec.lno) := rec.tax_type_val;
      adhoc_tab(rec.lno) := nvl(rec.adhoc_flag, 'N');
      qty_tab(rec.lno) := rec.qty_rate;
      uom_tab(rec.lno) := rec.uom_code; --pramasub for #6066485

      -- this condition will take care of the ADHOC taxes
      IF adhoc_tab(rec.lno) = 'Y' THEN

        tax_rate_tab(rec.lno) :=  -99999;
        tax_amt_tab(rec.lno)  := rec.tax_amt;
        initial_tax_amt_t(rec.lno) := rec.tax_amt;
        tax_target_tab(rec.lno) := rec.tax_amt;

      -- this condition will take care of the taxes that are UNIT RATE based , rec.qty_rate <> 0
      ELSIF adhoc_tab(rec.lno) = 'N' AND tax_rate_tab(rec.lno) = 0 THEN
        v_conversion_rate := 0;
        FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN
            INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
            IF nvl(v_conversion_rate, 0) <= 0  THEN
               v_conversion_rate := 0;
            END IF;
          END IF;
        tax_rate_tab( rec.lno ) := -99999;
        tax_amt_tab(rec.lno) := round(nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity,nvl(rec.rnd_factor,0));/*4281841*/
        initial_tax_amt_t(rec.lno) := round(nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity,nvl(rec.rnd_factor,0));/*4281841*/
        tax_target_tab(rec.lno) := tax_amt_tab(rec.lno);
        END LOOP;
      END IF;

      -- here we have to convert the tax_currency (func currency in case of foreign PO) into PO currency, so that all the
      -- taxes will be calculated in PO currency initially, then later while modifying them in database, then change them
      -- back to the tax currency
      -- ex. IF FUNCTIONAL CURRENCY -> USD, PO CURRENCY -> INR, TAX CURRENCY -> USD, then the if condition is satisfied
      IF curr_tab(rec.lno) <> v_po_curr THEN
      -- the following two lines are commented as the tax_amt becomes zero after this code execution (For UOM based rax lines in Reqn) pramasub #6066485
       -- tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) / v_conv_rate;
       -- tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
        tax_target_tab(rec.lno) := tax_target_tab(rec.lno) / v_conv_rate;
      END IF;

      IF rec.Valid_Date is NULL OR rec.Valid_Date >= Sysdate THEN
        End_Date_Tab(rec.lno) := 1;
      ELSE
        End_Date_Tab(rec.lno) := 0;
      END IF;

      row_count := row_count + 1;
    END LOOP;

  ELSIF p_type IN  ( 'RELEASE', 'REQUISITION_BLANKET', 'STANDARDPO' ) THEN

    IF p_item_id IS NULL THEN
      OPEN  Fetch_Item_Cur;
      FETCH Fetch_Item_Cur INTO p_inventory_item_id;
      CLOSE Fetch_Item_Cur;
    ELSE
      p_inventory_item_id := p_item_id;
    END IF;


-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
    /*4281841 */
     IF p_line_uom_code IS NULL and p_type = 'REQUISITION_BLANKET' THEN
      /* OPEN  fetch_req_uom_code;
       FETCH fetch_req_uom_code INTO v_line_uom_code;
       CLOSE fetch_req_uom_code;*/null;
     END IF;
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

    FOR rec in c_po_line_location_taxes_retro(p_line_id, p_line_location_id) LOOP

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


      rnd_factor(rec.lno) := nvl(rec.rnd_factor,0);
      tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
      tax_type_tab(rec.lno) := rec.tax_type_val;
      adhoc_tab(rec.lno) := nvl(rec.adhoc_flag,'N'); -- added for bug#2097413
      qty_tab(rec.lno) := rec.qty_rate; -- added for bug#2097413

      curr_tab(rec.lno) := nvl( rec.curr, v_po_curr); -- p_po_curr);  -- v_curr );
      tax_amt_tab(rec.lno) := 0;
      initial_tax_amt_t(rec.lno) := 0;
      tax_target_tab(rec.lno) := 0;

  --Added by Kevin Cheng -- for remain unchanged taxes
  --1, Ad hoc taxes
  --2, UOM based taxes
  --3, Assessable value base taxes (Excise/VAT)
  --4, Third party taxes
  --=================================================================================
  IF NVL(rec.adhoc_flag,'N') = 'Y' --Ad hoc
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF NVL(rec.adhoc_flag,'N') = 'N' AND qty_tab(rec.lno) <> 0 --UOM based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec.tax_type_val = 1 AND p_assessable_value <> p_base_value--Excise assessable value based
  THEN
     lv_tax_remain_flag := 'Y';
  ELSIF rec.tax_type_val = 4 AND p_vat_assess_value <> p_base_value --VAT assessable value based
  THEN
    lv_tax_remain_flag := 'Y';
  ELSIF rec.hdr_vendor_id <> rec.tax_vendor_id --Third party
  THEN
    lv_tax_remain_flag := 'Y';
  ELSE
    lv_tax_remain_flag := 'N';
  END IF;

  IF lv_tax_remain_flag = 'Y'
  THEN
    SELECT
      original_tax_amount
    INTO
      tax_amt_tab(rec.lno)
    FROM
      Jai_Retro_Tax_Changes jrtc
    WHERE jrtc.tax_id = rec.tax_id
      AND jrtc.line_change_id = (SELECT
                                   line_change_id
                                 FROM
                                   Jai_Retro_Line_Changes jrlc
                                 WHERE jrlc.line_location_id = p_line_location_id
                                   AND jrlc.doc_type IN ( 'RELEASE'
                                                        , 'RECEIPT'
                                                        , 'STANDARD PO'
                                                        )
                                   AND jrlc.doc_version_number = (SELECT
                                                                    MAX(jrlc1.doc_version_number)
                                                                  FROM
                                                                    Jai_Retro_Line_Changes jrlc1
                                                                  WHERE jrlc1.line_location_id = p_line_location_id
                                                                    AND jrlc1.doc_type IN ( 'RELEASE'
                                                                                          , 'RECEIPT'
                                                                                          , 'STANDARD PO'
                                                                                          )
                                                                 )
                                );
    tax_rate_tab(rec.lno)      := -99999;
    tax_target_tab(rec.lno)    := nvl(rec.tax_amount,0);
    initial_tax_amt_t(rec.lno) := nvl(rec.tax_amount,0);
    adhoc_tab(rec.lno)         := 'Y';

  ELSIF lv_tax_remain_flag = 'N'
  THEN
    adhoc_tab(rec.lno):= nvl(rec.adhoc_flag,'N'); -- added by subbu on 08-nov-01
  END IF;
  --=================================================================================

      --Comment out by Kevin Cheng
      -- start of modifications for Bug#2097413
      -- IF nvl(rec.tax_rate,0) = 0 AND nvl(rec.qty_rate,0) = 0 and nvl(rec.adhoc_flag,'N') = 'Y' THEN
      /*IF adhoc_tab(rec.lno) = 'Y' THEN

        tax_rate_tab(rec.lno) :=  -99999;
        tax_amt_tab(rec.lno) := nvl(rec.tax_amount,0);
        initial_tax_amt_t(rec.lno) := nvl(rec.tax_amount,0);
        tax_target_tab(rec.lno) := nvl(rec.tax_amount,0);


     ELSIF adhoc_tab(rec.lno) = 'N' AND qty_tab(rec.lno) <> 0 THEN -- tax_rate_tab(rec.lno) = 0 THEN
-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
        v_conversion_rate := 0;
      FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
        INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0  THEN
            v_conversion_rate := 0;
          END IF;
        END IF;
      END LOOP;
      tax_rate_tab( rec.lno ) := -99999;
      tax_amt_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));\*4281841*\
      initial_tax_amt_t(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
    END IF;*/
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

      -- THIS IS THE MAIN CHANGE FOR THE BUG# cbabu for Bug# 2659815
      -- here we have to convert the tax_currency (func currency in case of foreign PO) into PO currency, so that all the
      -- taxes will be calculated in PO currency initially, then later while modifying them in database, then change them
      -- back to the tax currency
      -- ex. FUNCTIONAL CURRENCY -> USD, PO CURRENCY -> INR, TAX CURRENCY -> USD, then the if condition is satisfied

      IF curr_tab(rec.lno) <> v_po_curr THEN
         tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
         tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
         tax_target_tab(rec.lno) := tax_target_tab(rec.lno) * v_conv_rate; -- YYYYYYY
      END IF;
      --end, cbabu for Bug# 2659815

      IF rec.Valid_Date is NULL Or rec.Valid_Date >= SYSDATE THEN
        end_date_tab(rec.lno) := 1;
      ELSE
        end_date_tab(rec.lno) := 0;
      END IF;

      row_count := row_count + 1;

    END LOOP;
 ELSIF p_type IN  ( 'ASBN' ) THEN /*rchandan for 5961325*/

  FOR rec in cur_asbn_taxes_retro( p_header_id, p_line_id ) LOOP -- pramasub added p_header_id for bug #6137011

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

    rnd_factor(rec.lno)   := nvl(rec.rnd_factor,0);
    tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
    tax_type_tab(rec.lno) := rec.tax_type_val;
    adhoc_tab(rec.lno)    := nvl(rec.adhoc_flag,'N'); -- added for bug#2097413
    qty_tab(rec.lno)      := rec.qty_rate; -- added for bug#2097413
    uom_tab(rec.lno)      := rec.uom_code; --pramasub for #6137011

    curr_tab(rec.lno)          := nvl( rec.curr, v_po_curr); -- p_po_curr);  -- v_curr );
    tax_amt_tab(rec.lno)       := 0;
    initial_tax_amt_t(rec.lno) := 0;
    tax_target_tab(rec.lno)    := 0;

    IF adhoc_tab(rec.lno) = 'Y' THEN

      tax_rate_tab(rec.lno)      :=  -99999;
      tax_amt_tab(rec.lno)       := nvl(rec.tax_amount,0);
      initial_tax_amt_t(rec.lno) := nvl(rec.tax_amount,0);
      tax_target_tab(rec.lno)    := nvl(rec.tax_amount,0);

    ELSIF adhoc_tab(rec.lno) = 'N' AND qty_tab(rec.lno) <> 0 THEN
        v_conversion_rate := 0;
      FOR uom_cls IN uom_class_cur(v_line_uom_code, rec.uom_code) LOOP
        INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion(v_line_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0  THEN
            v_conversion_rate := 0;
          END IF;
        END IF;
      END LOOP;
      tax_rate_tab( rec.lno ) := -99999;
      tax_amt_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
      initial_tax_amt_t(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_line_quantity;
      tax_target_tab(rec.lno) := tax_amt_tab( rec.lno );
    END IF;

    IF curr_tab(rec.lno) <> v_po_curr THEN
      tax_amt_tab(rec.lno)  := tax_amt_tab(rec.lno) * v_conv_rate; -- YYYYYYYY
      tax_amt_tab(rec.lno) := round(tax_amt_tab(rec.lno),nvl(rec.rnd_factor,0));/*4281841*/
      tax_target_tab(rec.lno) := tax_target_tab(rec.lno) * v_conv_rate; -- YYYYYYY
    END IF;
    --end, cbabu for Bug# 2659815

    IF rec.Valid_Date is NULL Or rec.Valid_Date >= SYSDATE THEN
      end_date_tab(rec.lno) := 1;
    ELSE
      end_date_tab(rec.lno) := 0;
    END IF;

    row_count := row_count + 1;

  END LOOP;

  END IF;

  bsln_amt := p_base_value;

  FOR i in 1..row_count LOOP

    IF tax_type_tab(i) = 1 THEN
      bsln_amt := NVL( p_assessable_value, p_base_value );
     /* start rallamse bug#4250072 VAT */
    ELSIF tax_type_tab(i) = 4 THEN
      bsln_amt := NVL( p_vat_assess_value, p_base_value );
    /* end rallamse Bug#4250072 VAT */
    ELSE
      bsln_amt := p_base_value;
    END IF;

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

    IF tax_rate_tab(I) <> -99999 THEN
      v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
      IF END_date_tab(I) = 0 then
        tax_amt_tab(I) := 0;
      ELSIF END_date_tab(I) = 1 then
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
      END IF;
    ELSE
      tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
    END IF;
    tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
    vamt      := 0;
    v_tax_amt := 0;

  END LOOP;
  --i := null;

  FOR i in 1..row_count LOOP
    --i := v_taxid_tab(j);

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

    IF tax_rate_tab(I) <> -99999 THEN
      v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
      IF END_date_tab(I) = 0 then
        tax_amt_tab(I) := 0;
      ELSIF END_date_tab(I) = 1 then
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
      END IF;
    ELSE -- added for Bug#2097413
      tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
    END IF;

-- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
    tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
-- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN

    vamt      := 0;
    v_tax_amt := 0;
  END LOOP;
  --i := null;

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;

    FOR i in 1..row_count LOOP
      --i := v_taxid_tab(j);

      IF tax_rate_tab( i ) <> 0 AND End_Date_Tab(I) <> 0
        AND adhoc_tab(i) <> 'Y' AND qty_tab(i) IS NULL
      THEN
        -- added extra condition AND adhoc_tab(i) <> 'Y' , qty_tab(i) IS NULL for Bug#2097413
        IF tax_type_tab( i ) = 1 THEN
          v_amt := NVL( p_assessable_value, p_base_value );
        /* start rallamse Bug#4250072 VAT */
        ELSIF tax_type_tab(i) = 4 THEN
          v_amt := NVL( p_vat_assess_value, p_base_value );
        /* end rallamse Bug#4250072 VAT */
        ELSIF v_amt = 0 OR tax_type_tab(i) <> 1 THEN
          v_amt := p_base_value;
        END IF;

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

        v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
        tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      -- START ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
      tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
      -- END ILIPROCUREMENT FORWARD PORTING - KVAIDYAN
      ELSIF tax_rate_tab( i ) = -99999 AND End_Date_Tab(I) <> 0  THEN
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
  END IF;
  --======================================================================================================

  IF v_debug = 'Y' THEN
    fnd_file.put_line( fnd_file.log,' 1 After calculating the taxes -> '||row_count );
    FOR I in 1..row_count LOOP
      fnd_file.put_line(fnd_file.log, ' cur->'||curr_tab(i)||', tax_amt_tab('||i||') -> '||tax_amt_tab(i)||
        ', tax_target_tab -> '||tax_target_tab(i));
    END LOOP;

  END IF;

  IF p_type = 'REQUISITION' THEN
    FOR i in 1..row_count LOOP
      --i := v_taxid_tab(j);

      IF tax_type_tab( i ) <> 2 THEN
        v_tax_amt := v_tax_amt + round( nvl(tax_amt_tab(I),0), rnd_factor(I) );
      END IF;

      -- Currecy Conversion code by cbabu for Bug# cbabu for Bug# 2659815
      IF curr_tab(i) <> v_po_curr THEN
        IF tax_rate_tab(i) <> -99999 THEN
          tax_amt_tab(i)  := tax_amt_tab(i) * v_conv_rate;
        ELSE
          IF uom_tab(i) is not null then --pramasub start for #6066485
 	      tax_amt_tab(i)  := initial_tax_amt_t(i) * v_conv_rate;
          Else
              tax_amt_tab(i)  := initial_tax_amt_t(i);
          End If;  --pramasub end for #6066485
        END IF;
	    tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
      END IF;
      --end, cbabu for Bug# 2659815


--Bgowrava for Bug#5877782 Added standard Who columns
      UPDATE JAI_PO_REQ_LINE_TAXES
       SET    Tax_Amount = round( nvl(tax_amt_tab(I),0), nvl(rnd_factor(I),0) ),/*4281841*/
           Tax_Target_Amount = NVL( tax_target_tab(I), 0 ),
					 last_update_date  = sysdate,
					 last_updated_by   = fnd_global.user_id,
					 last_update_login = fnd_global.login_id
    WHERE  Requisition_Header_Id = p_header_id
    AND    Requisition_Line_Id = p_line_id
    AND    Tax_Line_No = I;
    END LOOP;

    -- cbabu for Bug# 2659815
    --Bgowrava for Bug#5877782 Added standard Who columns
    UPDATE JAI_PO_REQ_LINES
    SET Tax_Amount = v_tax_amt,
      total_amount = p_base_value + v_tax_amt,
      last_update_date  = sysdate,
      last_updated_by   = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    WHERE requisition_header_id = p_header_id
    AND requisition_line_id = p_line_id;

  ELSIF p_type = 'REQUISITION_BLANKET' THEN

    FOR i in 1..row_count LOOP

      IF tax_type_tab( i )  <> 2 THEN
        v_tax_amt := v_tax_amt + round( nvl(tax_amt_tab(I),0), rnd_factor(I) );
      END IF;

      -- Currecy Conversion code by cbabu for Bug# cbabu for Bug# 2659815
      IF curr_tab(i) <> v_po_curr THEN
        IF tax_rate_tab(i) <> -99999 THEN
          tax_amt_tab(i)  := tax_amt_tab(i) * v_conv_rate;
        ELSE
          tax_amt_tab(i)  := initial_tax_amt_t(i);
        END IF;
     END IF;
	--ILIPROCUREMENT START
	 IF tax_type_tab( i ) <> 2 THEN
         v_tax_amt := v_tax_amt + round( nvl(tax_amt_tab(I),0), rnd_factor(I) );
       END IF;
	--ILIPROCUREMENT END

      --end, cbabu for Bug# 2659815
      --Bgowrava for Bug#5877782 Added standard Who columns
      UPDATE JAI_PO_REQ_LINE_TAXES
      SET Tax_Amount = round( nvl(tax_amt_tab(I),0), rnd_factor(I) ),
        Tax_Target_Amount = NVL( tax_target_tab(I), 0 ),
        last_update_date  = sysdate,
				last_updated_by   = fnd_global.user_id,
				last_update_login = fnd_global.login_id
      WHERE Requisition_Line_Id = p_requisition_line_id/*5877782..replaced p_line_id with p_requisition_line_id */
      AND Tax_Line_No = I;
    END LOOP;


  ELSIF p_type IN ( 'RELEASE', 'STANDARDPO' ) THEN

    IF v_debug = 'Y' THEN
      fnd_file.put_line( fnd_file.log, '3 Before Updating the table');
    END IF;

    FOR i in 1..row_count LOOP

      IF tax_type_tab( i ) <> 2 THEN
        v_tax_amt := v_tax_amt + round( nvl(tax_amt_tab(I),0), rnd_factor(I) );
      END IF;

      -- Currecy Conversion code by cbabu for Bug# cbabu for Bug# 2659815
      IF curr_tab(i) <> v_po_curr THEN
        IF tax_rate_tab(i) <> -99999 THEN
          tax_amt_tab(i)  := tax_amt_tab(i) * v_conv_rate;
        ELSE
          tax_amt_tab(i)  := initial_tax_amt_t(i);
        END IF;
	--START ILIPROCUREMENT
	tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
	--END ILIPROCUREMENT
      END IF;
      --end, cbabu for Bug# 2659815

      IF v_debug = 'Y' THEN
        fnd_file.put_line( fnd_file.log,' cur->'||curr_tab(i)||', tax_amt_tab('||i||') -> '||tax_amt_tab(i)||
          ', tax_target_tab -> '||tax_target_tab(i));
      END IF;

			--Bgowrava for Bug#5877782 Added standard Who columns
      UPDATE  JAI_PO_TAXES
      SET tax_amount = round( nvl( tax_amt_tab(i), 0 ), nvl(rnd_factor(I),0) ),
        tax_target_amount = nvl( tax_target_tab(i), 0 ),
        last_update_date  = sysdate,
				last_updated_by   = fnd_global.user_id,
		    last_update_login = fnd_global.login_id
      WHERE line_location_id = p_line_location_id
      AND po_line_id = p_line_id
      AND tax_line_no = i;

      --Added by Kevin Cheng for Retroactive Price 2008/01/11
      --=====================================================
      IF pv_retroprice_changed = 'Y'
      THEN
        JAI_RETRO_PRC_PKG.Update_Price_Changes( pn_tax_amt         => round( nvl( tax_amt_tab(i), 0 ), nvl(rnd_factor(I),0) )
                                              , pn_line_no         => i
                                              , pn_line_loc_id     => p_line_location_id
                                              , pv_process_flag    => lv_process_flag
                                              , pv_process_message => lv_process_message
                                              );

        IF lv_process_flag IN ('EE', 'UE')
        THEN
          FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
          FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG','JAI_PO_TAX_PKG.CALC_TAX.Err:'||lv_process_message);
          app_exception.raise_exception;
        END IF;
      END IF;
      --=====================================================
    END LOOP;

		--Bgowrava for Bug#5877782 Added standard Who columns
    UPDATE JAI_PO_LINE_LOCATIONS
    SET Tax_Amount = NVL( v_tax_amt, 0 ),
      Total_Amount = v_tax_amt + p_base_value	,
      last_update_date  = sysdate,
			last_updated_by   = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    WHERE Line_Location_Id = p_line_location_id
    AND Po_Line_Id = p_line_id;

 ELSIF p_type in ( 'ASBN' ) THEN  /*rchandan for 5961325*/

  FOR i in 1..row_count LOOP

    IF tax_type_tab( i ) <> 2 THEN
      v_tax_amt := v_tax_amt + round( nvl(tax_amt_tab(I),0), rnd_factor(I) );
    END IF;

    -- Currecy Conversion code by cbabu for Bug# cbabu for Bug# 2659815

    IF curr_tab(i) <> v_po_curr THEN
      IF tax_rate_tab(i) <> -99999 THEN
        tax_amt_tab(i)  := tax_amt_tab(i) * 1/v_conv_rate;
      ELSE
        --tax_amt_tab(i)  := initial_tax_amt_t(i) ;
          IF uom_tab(i) is not null then --pramasub start for #6137011
              tax_amt_tab(i)  := initial_tax_amt_t(i) * 1/v_conv_rate;
          Else
              tax_amt_tab(i)  := initial_tax_amt_t(i);
          End If;  --pramasub end for #6137011

      END IF;
      tax_amt_tab(I) := round(tax_amt_tab(I),nvl(rnd_factor(I),0));/*4281841*/
    END IF;
    --end, cbabu for Bug# 2659815

    IF v_debug = 'Y' THEN
      FND_FILE.put_line(FND_FILE.LOG,' cur->'||curr_tab(i)||', tax_amt_tab('||i||') -> '||tax_amt_tab(i)||
                        ', tax_target_tab -> '||tax_target_tab(i));
    END IF;

    UPDATE jai_cmn_document_taxes
		   SET Tax_Amt             = round( nvl( tax_amt_tab(i), 0 ), nvl(rnd_factor(I),0) ),
		       last_update_date    = sysdate,
					 last_updated_by     = fnd_global.user_id,
				   last_update_login   = fnd_global.login_id
		 WHERE source_doc_id       = p_header_id
		   AND source_doc_Line_Id  = p_line_id
       AND Tax_Line_No         = I;

  END LOOP;

END IF;

  p_tax_amount := v_tax_amt;

  EXCEPTION
    WHEN OTHERS THEN
    p_tax_amount := null;
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END calc_tax;



/*-----------------------------------------------------------------------------------------*/

  PROCEDURE copy_source_taxes (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_type        VARCHAR2,
    p_po_hdr_id     NUMBER,
    p_po_line_id    NUMBER,
    p_po_line_loc_id  NUMBER,
    p_line_num      NUMBER,
    p_ship_num      NUMBER,
    p_item_id     NUMBER,
    p_from_hdr_id   NUMBER,
    p_from_type_lookup_code VARCHAR2,
    p_cre_dt      DATE,
    p_cre_by      NUMBER,
    p_last_upd_dt   DATE,
    p_last_upd_by   NUMBER,
    p_last_upd_login  NUMBER
  ) IS

    -- Copy Document for defaulting taxes in  Quotation to PO and PO to PO. It is executable
    -- FND CONCURRENT -> JAINCPDC

    v_seq_val     NUMBER;
    v_ln_loc_id   NUMBER;
--Added by kunkumar for forward porting to R12 Start
v_vendor_id number;
v_vendor_site_id  number;
v_service_type_code varchar2(30);


cursor fetch_vendor_id_cur IS
select vendor_id,vendor_site_id
from po_headers_all
where po_header_id=p_po_hdr_id;

--Added by kunkumar End

    v_line_id          NUMBER;

    CURSOR Fetch_Focus_Id_Cur IS
      SELECT JAI_PO_LINE_LOCATIONS_S.nextval FROM Dual;

    --  Cursor definition for picking line_location_id from po_line_locations_all

    CURSOR Fetch_Line_Loc_Id_Cur IS
      SELECT jpll.Line_Location_Id
      FROM po_line_locations_all plla, JAI_PO_LINE_LOCATIONS jpll,
        po_lines_all pla, po_headers_all pha
      WHERE pha.po_header_id = pla.po_header_id
      AND jpll.line_location_id = plla.line_location_id
      AND pha.po_header_id = plla.po_header_id
      AND pla.po_line_id = plla.po_line_id
      AND pha.po_header_id = p_from_hdr_id
      AND pla.line_num = p_line_num
      AND pla.item_id = p_item_id
      AND plla.shipment_num = p_ship_num;

    --  Cursor definition for picking po_line_id from po_lines_all
    CURSOR fetch_line_id_cur IS
      SELECT pla.Po_Line_Id
      FROM po_lines_all pla, po_headers_all pha
      WHERE pha.Po_Header_Id = p_from_hdr_id
      AND pla.line_num = p_line_num   -- Vijay Shankar for Bug# 3466223
      AND pha.po_header_id =pla.po_header_id;

    -- Cursor definition for picking values from JAI_PO_LINE_LOCATIONS
    -- using line_location_id as where clause
    CURSOR Fetch_Ja_In_Po_Ln_Loc_Cur IS
      SELECT line_location_id, po_line_id, po_header_id, tax_modified_flag,
        tax_amount, total_amount, line_focus_id, creation_date,
        created_by, last_update_date, last_updated_by, last_update_login,
        tax_category_id       -- cbabu for EnhancementBug# 2427465
      FROM JAI_PO_LINE_LOCATIONS
      WHERE Line_Location_Id = v_ln_loc_id;

    -- Cursor definition for picking values from JAI_PO_TAXES
    -- using line_location_id as where clause
    CURSOR fetch_po_ln_loc_tax_cur IS
      SELECT line_location_id,
             tax_line_no,
       po_line_id,
       po_header_id,
             precedence_1,
       precedence_2,
       precedence_3,
       precedence_4,
             precedence_5,
             precedence_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       precedence_7,
       precedence_8,
       precedence_9,
             precedence_10,
       tax_id,
       currency,
       tax_rate,
             qty_rate,
       uom,
       tax_amount,
       tax_type,
             vendor_id,
       modvat_flag,
       tax_target_amount,
       line_focus_id,
             creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
             tax_category_id       -- cbabu for EnhancementBug# 2427465
      FROM JAI_PO_TAXES
      WHERE Line_Location_Id = v_ln_loc_id;

    -- Cursor definition for picking values from JAI_PO_LINE_LOCATIONS
    -- using po_line_id as where clause
    CURSOR fetch_jain_line_cur IS
      SELECT line_location_id, po_line_id, po_header_id, tax_modified_flag,
        tax_amount, total_amount, line_focus_id, creation_date,
        created_by, last_update_date, last_updated_by, last_update_login,
        tax_category_id     -- cbabu for EnhancementBug# 2427465
      FROM JAI_PO_LINE_LOCATIONS
      WHERE Po_Line_Id = v_line_id
      AND po_header_id = p_from_hdr_id
      AND ( line_location_id IS NULL
        OR line_location_id = 0 );  -- cbabu for EnhancementBug# 2427465

    -- Cursor definition for picking values from JAI_PO_TAXES
    -- using po_line_id as where clause

    CURSOR fetch_jain_line_tax_cur IS
      SELECT line_location_id,
             tax_line_no,
       po_line_id,
       po_header_id,
             precedence_1,
       precedence_2,
       precedence_3,
       precedence_4,
             precedence_5,
             precedence_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
       precedence_7,
       precedence_8,
       precedence_9,
             precedence_10,
       tax_id,
       currency,
       tax_rate,
             qty_rate,
       uom,
       tax_amount,
       tax_type,
             vendor_id,
       modvat_flag,
       tax_target_amount,
       line_focus_id,
             creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
             tax_category_id       -- cbabu for EnhancementBug# 2427465
      FROM  JAI_PO_TAXES
      WHERE  Po_Line_Id = v_line_id
      AND po_header_id = p_from_hdr_id
      AND ( line_location_id IS NULL
        OR line_location_id = 0 );  -- cbabu for EnhancementBug# 2427465

    -- Cursor variable for Fetch_Po_Ln_Loc_Cur
    fetch_ja_in_po_ln_loc_rec   FETCH_JA_IN_PO_LN_LOC_CUR%ROWTYPE;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.copy_source_taxes';
  BEGIN

  /*-----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:   FILENAME: ja_in_po_copydoc_dflt_p.sql
  S.No   Date       Author and Details
  -------------------------------------------------------------------------------------------------------------------------
  1  06/12/2002   cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                     tax_category_id column is populated into PO and SO localization tables, which will be used to
                    identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                    the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.

  2 14/04/2004  Vijay Shankar for Bug# 3466223, FileVersion# 619.1
           Cursor fetch_line_id_cur is not having line_num filter that is added in this fix.
           Otherwise it is not defaulting properly
  -------------------------------------------------------------------------------------------------------------------------*/

    IF p_type = 'L' THEN
      Update JAI_PO_COPYDOC_T
      Set po_header_id = p_po_hdr_id
      Where po_line_id = p_po_line_id;
      IF SQL%NOTFOUND
      THEN
        RETURN;
      END IF;
    ELSE
      Update JAI_PO_COPYDOC_T
      Set po_header_id = p_po_hdr_id
      Where line_location_id = p_po_line_loc_id;
      IF SQL%NOTFOUND
       THEN
         RETURN;
       END IF;
      END IF;

    OPEN Fetch_Line_Loc_Id_Cur;
    FETCH Fetch_Line_Loc_Id_Cur INTO v_ln_loc_id ;
    CLOSE Fetch_Line_Loc_Id_Cur;

    OPEN Fetch_Line_Id_Cur;
    FETCH Fetch_Line_Id_Cur INTO v_line_id;
    CLOSE Fetch_Line_Id_Cur;

    --       Line Level
--Added by kunkumar for forward porting to R12
open fetch_vendor_id_cur;
fetch fetch_vendor_id_cur into v_vendor_id, v_vendor_site_id;
close fetch_vendor_id_cur;

v_service_type_code :=jai_ar_rctla_trigger_pkg.get_service_type(v_vendor_id,v_vendor_site_id,'V');
--Added by kunkumar End;
    IF p_type = 'L' THEN

      IF v_seq_val IS NULL THEN

        OPEN  Fetch_Focus_Id_Cur;
        FETCH Fetch_Focus_Id_Cur INTO v_seq_val;
        CLOSE Fetch_Focus_Id_Cur;

        FND_FILE.put_line( FND_FILE.log, 'v_seq_val->'||v_seq_val);

        FOR rec1 in Fetch_Jain_Line_Cur LOOP

          INSERT INTO JAI_PO_LINE_LOCATIONS (
            line_location_id, po_line_id,  po_header_id,
            tax_modified_flag, tax_amount, total_amount,
            line_focus_id, creation_date, created_by,
            last_update_date, last_updated_by, last_update_login,
            tax_category_id     -- cbabu for EnhancementBug# 2427465
         ,service_type_code ) VALUES (
            p_po_line_loc_id, p_po_line_id, p_po_hdr_id,
            'Y', rec1.tax_amount, rec1.total_amount,
            v_seq_val, p_cre_dt, p_cre_by,
            p_last_upd_dt, p_last_upd_by, p_last_upd_login,
            rec1.tax_category_id    -- cbabu for EnhancementBug# 2427465
          ,v_service_type_code);

        END LOOP;
      END IF;

      FND_FILE.put_line( FND_FILE.log, 'bef taxes');
        FOR rec2 in Fetch_Jain_Line_Tax_Cur LOOP
        FND_FILE.put_line( FND_FILE.log, 'rec2.tax_id->'||rec2.tax_id);


       -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

        INSERT INTO JAI_PO_TAXES (
          line_location_id, tax_line_no, po_line_id, po_header_id,
          precedence_1, precedence_2, precedence_3, precedence_4,precedence_5,
    precedence_6, precedence_7, precedence_8, precedence_9,
          precedence_10, tax_id, currency, tax_rate, qty_rate,
          uom, tax_amount, tax_type, vendor_id, modvat_flag,
          tax_target_amount, line_focus_id, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login,
          tax_category_id     -- cbabu for EnhancementBug# 2427465
        ) VALUES (
          p_po_line_loc_id, rec2.tax_line_no, p_po_line_id, p_po_hdr_id,
          rec2.precedence_1, rec2.precedence_2, rec2.precedence_3, rec2.precedence_4,rec2.precedence_5,
    rec2.precedence_6, rec2.precedence_7, rec2.precedence_8, rec2.precedence_9, rec2.precedence_10 ,
    rec2.tax_id, rec2.currency, rec2.tax_rate, rec2.qty_rate,
          rec2.uom, rec2.tax_amount, rec2.tax_type, rec2.vendor_id, rec2.modvat_flag,
          rec2.tax_target_amount, v_seq_val, p_cre_dt, p_cre_by,
          p_last_upd_dt, p_last_upd_by, p_last_upd_login,
          rec2.tax_category_id    -- cbabu for EnhancementBug# 2427465
        );

         END LOOP;

     ELSE

      IF v_ln_loc_id IS NOT NULL THEN

        OPEN  Fetch_Focus_Id_Cur;
        FETCH Fetch_Focus_Id_Cur INTO v_seq_val;
        CLOSE Fetch_Focus_Id_Cur;

        OPEN Fetch_Ja_In_Po_Ln_Loc_Cur ;
        FETCH Fetch_Ja_In_Po_Ln_Loc_Cur INTO Fetch_Ja_In_Po_Ln_Loc_Rec;

        INSERT INTO JAI_PO_LINE_LOCATIONS (
          line_location_id, po_line_id,  po_header_id,
          tax_modified_flag, tax_amount, total_amount, line_focus_id,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login,
          tax_category_id,service_type_code       -- cbabu for EnhancementBug# 2427465
        ) VALUES (
          p_po_line_loc_id, p_po_line_id, p_po_hdr_id,
          'Y', fetch_ja_in_po_ln_loc_rec.tax_amount, fetch_ja_in_po_ln_loc_rec.total_amount,
          v_seq_val, p_cre_dt, p_cre_by, p_last_upd_dt, p_last_upd_by, p_last_upd_login,
          fetch_ja_in_po_ln_loc_rec.tax_category_id     -- cbabu for EnhancementBug# 2427465
        ,v_service_type_code);

        CLOSE Fetch_Ja_In_Po_Ln_Loc_Cur;

       -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

        FOR rec in Fetch_Po_Ln_Loc_Tax_Cur LOOP
        INSERT INTO JAI_PO_TAXES (
          line_location_id, tax_line_no, po_line_id, po_header_id,
          precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
    precedence_6, precedence_7, precedence_8, precedence_9, precedence_10,
    tax_id, currency, tax_rate, qty_rate,
          uom, tax_amount, tax_type,  vendor_id, modvat_flag,
          tax_target_amount, line_focus_id, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login,
          tax_category_id       -- cbabu for EnhancementBug# 2427465
        ) VALUES (
          p_po_line_loc_id, rec.tax_line_no, p_po_line_id, p_po_hdr_id,
          rec.precedence_1, rec.precedence_2, rec.precedence_3, rec.precedence_4, rec.precedence_5,
    rec.precedence_6, rec.precedence_7, rec.precedence_8, rec.precedence_9, rec.precedence_10,
    rec.tax_id, rec.currency, rec.tax_rate, rec.qty_rate,
          rec.uom, rec.tax_amount, rec.tax_type, rec.vendor_id, rec.modvat_flag,
          rec.tax_target_amount, v_seq_val, p_cre_dt, p_cre_by,
          p_last_upd_dt, p_last_upd_by, p_last_upd_login,
          rec.tax_category_id     -- cbabu for EnhancementBug# 2427465
        );
        END LOOP;

      END IF;
    END IF;

     IF p_type = 'L' THEN
       Delete From JAI_PO_COPYDOC_T
        Where po_line_id = p_po_line_id
          AND line_location_id is null;
     ELSE
       Delete From JAI_PO_COPYDOC_T
        Where line_location_id = p_po_line_loc_id;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END copy_source_taxes;

  /*----------------------------------------------------------------------------------------*/

  PROCEDURE copy_quot_taxes
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_line_loc_id IN NUMBER,
    p_po_hdr_id IN NUMBER,
    p_po_line_id IN NUMBER,
    p_qty IN NUMBER,
    p_frm_hdr_id IN NUMBER,
    p_frm_line_id IN NUMBER,
    p_price IN NUMBER,
    p_unit_code IN VARCHAR2,
    p_assessable_value IN NUMBER,
    p_cre_dt IN DATE,
    p_cre_by IN NUMBER,
    p_last_upd_dt IN DATE,
    p_last_upd_by IN NUMBER,
    p_last_upd_login IN NUMBER
  )
  IS

    v_quot_line_loc_id            NUMBER;
    v_line_focus_id               NUMBER;
    v_unit_code                   VARCHAR2(25);
    v_tax_amt                     NUMBER;
    dummy                         NUMBER;
    ln_vat_assess_value           NUMBER;

    v_tax_category_id_holder JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE;    -- cbabu for EnhancementBug# 2427465
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.copy_quot_taxes';
    ------------------------------>

    CURSOR tax_cur IS
       SELECT a.Po_Line_Id, a.tax_line_no lno, a.tax_id,
              a.precedence_1 p_1,
              a.precedence_2 p_2,
              a.precedence_3 p_3,
              a.precedence_4 p_4,
              a.precedence_5 p_5,
              a.precedence_6 p_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
              a.precedence_7 p_7,
              a.precedence_8 p_8,
              a.precedence_9 p_9,
              a.precedence_10 p_10,
              a.currency, a.tax_rate, a.qty_rate, a.uom, a.tax_amount, a.tax_type,
              a.vendor_id, a.modvat_flag,
              tax_category_id     -- cbabu for EnhancementBug# 2427465
      FROM   JAI_PO_TAXES a
      /*condition modified for bug 7436368*/
      WHERE  ((a.line_location_id IS NULL AND v_quot_line_loc_id=-999) OR (a.line_location_id = v_quot_line_loc_id))
      --a.line_location_id = v_quot_line_loc_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    --WHERE  NVL( a.line_location_id, -999 ) = v_quot_line_loc_id
             AND  Po_Line_Id = p_frm_line_id
     ORDER BY  a.tax_line_no;

   CURSOR Fetch_Line_Focus_Id_Cur IS
      SELECT Line_Focus_Id
      FROM   JAI_PO_LINE_LOCATIONS
      WHERE  Po_Line_Id = p_po_line_id AND
             Line_Location_Id = p_line_loc_id;

    -- Start, added by Vijay Shankar for Bug# 3478460
    CURSOR c_line_tax_category_id_1(p_po_line_id IN NUMBER) IS
      SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
      WHERE po_line_id = p_po_line_id
      AND line_location_id IS NULL;

    CURSOR c_line_tax_category_id_2(p_po_line_id IN NUMBER, p_line_location_id IN NUMBER) IS
      SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
      WHERE po_line_id = p_po_line_id
      AND line_location_id = p_line_location_id;
    -- End, 3478460

  --Added by Nagaraj.s for Bug2953445..
  CURSOR c_check_adhoc_flag(p_tax_id number) IS
  select nvl(adhoc_flag,'N')
  from JAI_CMN_TAXES_ALL
  where tax_id = p_tax_id;

  --Added by Ravi for vat assessable vlue
  CURSOR cur_vendor
  IS
  SELECT vendor_id,vendor_site_id
    FROM po_headers_all
   WHERE po_header_id = p_po_hdr_id;

  CURSOR cur_item
  IS
  SELECT ITEM_ID
    FROM po_lines_all
   WHERE po_line_id = p_po_line_id;

  lv_item_id po_lines_all.item_id%type;

  vendor_rec  cur_vendor%ROWTYPE;
  v_check_adhoc_flag JAI_CMN_TAXES_ALL.adhoc_flag%type; --Nagaraj.s for Bug2953445.
  v_tax_amount       NUMBER;--Nagaraj.s for Bug2953445.

    ------------------------------>

  -- FND_EXECUTABLE -> JAINPOTD
  BEGIN

  /*-----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:   FILENAME: ja_in_po_quot_taxes_p.sql
  S.No   Date       Author and Details
  -------------------------------------------------------------------------------------------------------------------------
  1  06/12/2002   cbabu for EnhancementBug# 2427465, FileVersion# 615.1
                     tax_category_id column is populated into PO and SO localization tables, which will be used to
                    identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                    the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.

  2.   14/05/2003   Nagaraj.s for Bug#2953445. File Version : 616.1
                    In case of a Catalog Quotation, Adhoc Amounts Entered were defaulted as Zero, as previously Tax Amounts
                    were Zero irrespective of whether the Tax is an Adhoc Tax or not.
                    hence now a check has been incorporated, wherin if the Tax is of Adhoc Type, then The Tax Amounts
                    are populated as in the Quotation, else Tax Amounts are populated to Zero, so that Recalculation
                    of Taxes happen based upon precedences.

  3  09/03/2004   Vijay Shankar for Bug# 3478460, FileVersion# 618.1
                     Whenever the code doesn't fine a record for BPO Line in JAI_PO_LINE_LOCATIONS, then this procedure fails with either
                     no_data_found or duplicate_records found. Fixed this by taking tax category from tax lines otherwise fetching from
                     JAI_PO_LINE_LOCATIONS using the CURSORS c_line_tax_category_id_1 and c_line_tax_category_id_2

  4.   17/mar-2005     Rchandan for bug#4245365   Version#115.2. base bug#4245089
                       Changes made to calculate VAT assessable value . This vat assessable is passed
                       to the procedure that calculates the VAT related taxes

  -------------------------------------------------------------------------------------------------------------------------*/

      jai_po_cmn_pkg.locate_source_line
                       ( p_frm_hdr_id,
                         p_frm_line_id,
                         p_qty,
                         dummy,
                         v_quot_line_loc_id,
                         p_frm_line_id
                        );

       jai_po_cmn_pkg.insert_line
                    ( 'STANDARD',
                      p_line_loc_id,
                      p_po_hdr_id,
                      p_po_line_id,
                      p_cre_dt,
                      p_cre_by,
                      p_last_upd_dt,
                      p_last_upd_by,
                      p_last_upd_login,
                      'I'
                     );

       OPEN  Fetch_Line_Focus_Id_Cur;
       FETCH Fetch_Line_Focus_Id_Cur INTO v_line_focus_id;
       CLOSE Fetch_Line_Focus_Id_Cur;

       FOR rec in tax_cur LOOP
          --Added by Nagaraj.s to whether the Tax is an Adhoc One for Bug2953445.
      open c_check_adhoc_flag(rec.tax_id);
      fetch c_check_adhoc_flag into v_check_adhoc_flag;
      close c_check_adhoc_flag;

          --If this is an Adhoc Flag, then Tax Amount is to be the same Tax Amount as in Catalog Quotation
          --Else Tax Amount is Zero as before.

      if v_check_adhoc_flag ='Y' then
       v_tax_amount := rec.tax_amount;
      else
       v_tax_amount := 0;
      end if;
          --Ends here...

      INSERT INTO JAI_PO_TAXES(
                                  po_line_id,
                                  po_header_id,
                                  line_location_id,
                                  line_focus_id,
                                  tax_line_no,
                                  precedence_1,
                                  precedence_2,
                                  precedence_3,
                                  precedence_4,
                                  precedence_5,
                                  precedence_6,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
                                  precedence_7,
                                  precedence_8,
                                  precedence_9,
                                  precedence_10,
                                  tax_id, tax_rate, qty_rate, uom, tax_amount, tax_target_amount,
                                  tax_type, modvat_flag, vendor_id, currency,
                                  creation_date, created_by, last_update_date,
                                  last_updated_by, last_update_login,
                                  tax_category_id     -- cbabu for EnhancementBug# 2427465
                             )
        VALUES (
                      p_po_line_id, p_po_hdr_id, p_line_loc_id, v_line_focus_id, rec.lno,
                      rec.p_1, rec.p_2, rec.p_3, rec.p_4, rec.p_5,rec.p_6, rec.p_7, rec.p_8, rec.p_9, rec.p_10,
                      rec.tax_id, rec.tax_rate, rec.qty_rate, rec.uom, v_tax_amount, 0, --Previously The Value of TaxAmount is 0 Which is now changed to v_tax_amount for Bug2953445
                      rec.tax_type, rec.modvat_flag, rec.vendor_id, rec.currency,
                      p_cre_dt, p_cre_by, p_last_upd_dt, p_last_upd_by, p_last_upd_login,
                      rec.tax_category_id     -- cbabu for EnhancementBug# 2427465
              );

      -- Vijay Shankar for Bug# 3478460
      v_tax_category_id_holder := nvl( rec.tax_category_id, v_tax_category_id_holder);

      v_check_adhoc_flag :=NULL;
      v_tax_amount       :=0;
    END LOOP;

    -- Start, if clause added by Vijay Shankar for Bug# 3478460
    If v_tax_category_id_holder IS NULL THEN
      IF v_quot_line_loc_id = -999 THEN
        OPEN c_line_tax_category_id_1(p_frm_line_id);
        FETCH c_line_tax_category_id_1 INTO v_tax_category_id_holder;
        CLOSE c_line_tax_category_id_1;
      ELSE
        OPEN c_line_tax_category_id_2(p_frm_line_id, v_quot_line_loc_id);
        FETCH c_line_tax_category_id_2 INTO v_tax_category_id_holder;
        CLOSE c_line_tax_category_id_2;
      END IF;
    end if;

    UPDATE JAI_PO_LINE_LOCATIONS
    SET tax_category_id = v_tax_category_id_holder
    WHERE line_focus_id = v_line_focus_id;
    -- End, 3478460

    /* following block is commented and replaced with the above UPDATE statement
    -- Start, cbabu for EnhancementBug# 2427465
    BEGIN
      IF v_quot_line_loc_id = -999 THEN
        SELECT tax_category_id INTO v_tax_category_id_holder
        FROM JAI_PO_LINE_LOCATIONS
        WHERE po_line_id = p_frm_line_id
        AND (line_location_id IS NULL OR line_location_id = 0);
      ELSE -- line_location_id is present in PO_LINE_LOCATIONS_ALL
        SELECT tax_category_id INTO v_tax_category_id_holder
        FROM JAI_PO_LINE_LOCATIONS
        WHERE po_line_id = p_frm_line_id
        AND line_location_id = v_quot_line_loc_id;
      END IF;

      UPDATE JAI_PO_LINE_LOCATIONS
      SET tax_category_id = v_tax_category_id_holder
      WHERE line_focus_id = v_line_focus_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR( -20101, '1 Exception raised in jai_po_tax_pkg.copy_quot_taxes : '||SQLERRM, TRUE);
    END;
    -- End, cbabu for EnhancementBug# 2427465
    */
    OPEN cur_vendor;
    FETCH cur_vendor INTO vendor_rec;
    CLOSE cur_vendor;

    OPEN cur_item;
    FETCH cur_item INTO lv_item_id;
    CLOSE cur_item;

    ln_vat_assess_value := jai_general_pkg.ja_in_vat_assessable_value
             ( p_party_id => vendor_rec.vendor_id,
               p_party_site_id => vendor_rec.vendor_site_id,
               p_inventory_item_id => lv_item_id,
               p_uom_code => p_unit_code,
               p_default_price => p_price,
               p_ass_value_date => SYSDATE,
               p_party_type => 'V'
             ) ;   -- Ravi for VAT


    jai_po_tax_pkg.calculate_tax
          ( 'STANDARDPO', p_po_hdr_id , p_po_line_id, p_line_loc_id,
           p_qty, p_price*p_qty, p_unit_code, v_tax_amt, p_assessable_value, ln_vat_assess_value*p_qty, NULL );
            -- Ravi for VAT

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END copy_quot_taxes;

/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE copy_agreement_taxes
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_seq_val     IN  NUMBER,
    p_qty         IN  NUMBER,
    p_hdr_id      IN  NUMBER,
    p_line_id     IN  NUMBER,
    p_line_loc_id IN  NUMBER,
    p_ship_type   IN  VARCHAR2,
    p_cum_flag    IN  VARCHAR2,
    p_cre_dt      IN  DATE,
    p_cre_by      IN  NUMBER,
    p_last_cre_dt IN  DATE,
    p_last_cre_by IN  NUMBER,
    p_last_login  IN  NUMBER
  , pv_retroprice_changed IN VARCHAR2 --Added by Kevin Cheng for Retroactive Price 2008/01/10
  ) IS

    v_qty     NUMBER;   --File.Sql.35 Cbabu  := p_qty;
    v_old_qty     NUMBER;
    v_cum_qty     NUMBER;
    v_line_id     NUMBER;
    v_tax_amt     NUMBER;
    v_tax_amt1    NUMBER;
    v_total_amt   NUMBER;
    tax_amount    NUMBER;
    v_line_loc_id   NUMBER;
    i       NUMBER; --File.Sql.35 Cbabu  := 1;
    j       NUMBER;
    k       NUMBER;
    v_row     NUMBER;
    flag      BOOLEAN;  --File.Sql.35 Cbabu  :=  TRUE;
    v_temp_price    NUMBER;
    v_temp_qty1   NUMBER;
    v_temp_qty2   NUMBER;
    v_count     NUMBER;
    v_unit_price    NUMBER;
    v_uom     VARCHAR2(50);
    v_uom_code    VARCHAR2(50);
    v_po_hdr_id   NUMBER;
    v_po_line_id    NUMBER;
    v_vendor_id   NUMBER;
    v_vendor_site_id  NUMBER;
    v_assessable_value  NUMBER;
    ln_vat_assess_value     NUMBER;      -- Ravi for VAT
    v_doc_curr    VARCHAR2(100);
    v_item_id     NUMBER;
    v_curr_conv_factor    NUMBER;
    DUMMY                 NUMBER;   --File.Sql.35 Cbabu  := 1;
    v_tax_count       NUMBER;
    vQryOn      VARCHAR2(15);

    TYPE v_Llid_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    Llid_tab v_Llid_tab;

    TYPE v_Qty_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    Qty_tab v_Qty_Tab;

    TYPE v_Price_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    price_tab v_Price_Tab;

    -- Vijay Shankar for Bug# 3191450
    -- following TYPE definition is modified to use VARCHAR2 instead of CHAR, because this is padding spaces to the
    -- values in the plsql tables if string length of value is less than 50
    -- TYPE Uom IS TABLE OF CHAR(50) INDEX BY BINARY_INTEGER;
    TYPE Uom IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    uom_tab  uom;

    v_tax_category_id_holder JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE;  -- cbabu for EnhancementBug# 2427465


-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

    CURSOR Fetch_Taxes_Cur( lineid IN NUMBER, llid IN NUMBER ) IS
    SELECT Line_Location_Id, Tax_Line_No, Po_Line_Id, Po_Header_Id,
           Precedence_1, Precedence_2, Precedence_3, Precedence_4,Precedence_5,
     Precedence_6, Precedence_7, Precedence_8, Precedence_9,Precedence_10,
     Tax_Id, Currency, Tax_Rate, Qty_Rate, UOM, Tax_Amount, Tax_Type,
           Vendor_Id, Modvat_Flag, Tax_Target_Amount,
           tax_category_id    -- cbabu for EnhancementBug# 2427465
      FROM JAI_PO_TAXES
      WHERE NVL( Line_Location_Id, -999 ) = llid    /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980* -- NVL condition is added by SAcsethi for bug 6134628 */
       AND Po_Line_Id = lineid
     ORDER BY Tax_Line_No;

    CURSOR Fetch_Tax_Lines_Cur IS
    SELECT *
      FROM JAI_PO_REQUEST_T
     WHERE line_focus_id = p_seq_val  -- Modified By Sjha
     ORDER BY Tax_Line_No;

    v_junk_uom  MTL_UNITS_OF_MEASURE.unit_of_measure%TYPE;    -- Added by Vijay Shankar for Bug# 3205861
    CURSOR Fetch_Qty_Cur( llid IN NUMBER ) IS
    SELECT Quantity, Price_Override, Unit_Meas_Lookup_Code
      FROM Po_Line_Locations_All
     WHERE Line_Location_Id = llid;

    -- CURSOR Fetch_Cum_Qty_Cur IS
    CURSOR Fetch_Cum_Qty_Cur(pQryOn IN VARCHAR2, pShipToOrganizationId IN NUMBER, pShipToLocationId IN NUMBER, cp_shipment_type Po_Line_Locations_All.shipment_type%type) IS
    SELECT SUM( Quantity )
      FROM   Po_Line_Locations_All PLL
     WHERE  Po_Line_Id = p_line_id
          -- cbabu for Bug# 3102375
       AND shipment_type <> cp_shipment_type --'PRICE BREAK'
       AND ((pQryOn = 'ALL'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID = pShipToLocationId )
        OR (pQryOn = 'ORG'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID IS NULL )
        OR (pQryOn = 'NULL'  AND PLL.SHIP_TO_ORGANIZATION_ID IS NULL  AND PLL.SHIP_TO_LOCATION_ID IS NULL )
      );

    -- CURSOR Fetch_Count_Llid_Cur IS
    CURSOR Fetch_Count_Llid_Cur(pQryOn IN VARCHAR2, pShipToOrganizationId IN NUMBER, pShipToLocationId IN NUMBER, cp_shipment_type Po_Line_Locations_All.shipment_type%type) IS
    SELECT NVL( COUNT( Line_Location_Id ), 0 )
      FROM Po_Line_Locations_All PLL
     WHERE Po_Line_Id  = p_line_id
       AND Shipment_Type = cp_shipment_type --'PRICE BREAK'
          -- cbabu for Bug# 3102375
       AND ((pQryOn = 'ALL'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID = pShipToLocationId )
        OR (pQryOn = 'ORG'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID IS NULL )
        OR (pQryOn = 'NULL'  AND PLL.SHIP_TO_ORGANIZATION_ID IS NULL  AND PLL.SHIP_TO_LOCATION_ID IS NULL )
      )
       AND SYSDATE between nvl(start_date, SYSDATE) and nvl(end_date, SYSDATE);

    -- CURSOR Fetch_Locid_Cur IS
    CURSOR Fetch_Locid_Cur(pQryOn IN VARCHAR2, pShipToOrganizationId IN NUMBER, pShipToLocationId IN NUMBER, cp_shipment_type Po_Line_Locations_All.shipment_type%type) IS
    SELECT Line_Location_Id, Quantity, Price_Override, Unit_Meas_Lookup_Code
      FROM   Po_Line_Locations_All PLL
     WHERE  Po_Header_Id  = p_hdr_id
       AND    Po_Line_Id    = p_line_id
       AND    Shipment_Type = cp_shipment_type --'PRICE BREAK'
      -- cbabu for Bug# 3102375
       AND ((pQryOn = 'ALL'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID = pShipToLocationId )
        OR (pQryOn = 'ORG'  AND PLL.SHIP_TO_ORGANIZATION_ID = pShipToOrganizationId  AND PLL.SHIP_TO_LOCATION_ID IS NULL )
        OR (pQryOn = 'NULL'  AND PLL.SHIP_TO_ORGANIZATION_ID IS NULL AND PLL.SHIP_TO_LOCATION_ID IS NULL )
      )
       AND SYSDATE between nvl(start_date, SYSDATE) and nvl(end_date, SYSDATE)
     ORDER BY Quantity;

    -- added by cbabu for Bug# 3102375
    CURSOR cShipmentDetails(pLineLocationId IN NUMBER) IS
    SELECT ship_to_organization_id, ship_to_location_id
      FROM po_line_locations_all
     WHERE line_location_id = pLineLocationId;
    vShpDtl cShipmentDetails%ROWTYPE;

    ------------------------------Added by Nagaraj.s for Bug2461414>
    CURSOR Fetch_Price_cur IS
    SELECT Price_Override
      FROM Po_Line_Locations_All
     WHERE po_header_id = p_hdr_id
       AND po_line_id = p_line_id
       AND line_location_id=p_line_loc_id;

    CURSOR Fetch_Lineid_Cur IS
    SELECT Po_Line_Id, Unit_Price, Unit_Meas_Lookup_Code, Item_Id
      FROM   Po_Lines_All
     WHERE  Po_Line_Id = p_line_id;

    CURSOR Fetch_UOMCode_Cur( uom IN VARCHAR2 ) IS
    SELECT Uom_Code
      FROM   Mtl_Units_Of_Measure
     WHERE  Unit_Of_Measure = uom;

    CURSOR Fetch_Tot_Sum_Cur( llid IN NUMBER ) IS
    SELECT SUM( NVL( Tax_Amount, 0 ) )
      FROM   JAI_PO_TAXES
     WHERE  Line_Location_Id = llid
       AND   Tax_Type <> jai_constants.tax_type_tds; --'TDS';

    CURSOR Get_Assessable_Val_Cur IS
    SELECT Vendor_Id, Vendor_Site_Id, Currency_Code
      FROM   Po_Headers_All
     WHERE  Po_Header_Id = v_po_hdr_id;

    CURSOR Get_Item_Id_Cur IS
    SELECT Item_Id
      FROM   Po_Lines_All
     WHERE  Po_Line_Id = v_po_line_id;

    -- added by Vijay Shankar for Bug# 3487904
    CURSOR c_line_tax_category_id_1(p_po_line_id IN NUMBER) IS
    SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
     WHERE po_line_id = p_po_line_id
       AND line_location_id IS NULL;

    CURSOR c_line_tax_category_id_2(p_po_line_id IN NUMBER, p_line_location_id IN NUMBER) IS
    SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
     WHERE po_line_id = p_po_line_id
       AND line_location_id = p_line_location_id;
    -- End, 3487904


    /*  date 08-Aug-2007 by sacsethi for bug 6134628
        || Start 6134628
    */

    lv_override_flag JAI_CMN_VENDOR_SITES.override_flag%type ;
    lv_cre_dt    DATE;
    lv_cre_by    NUMBER;
    lv_last_upd_dt   DATE ;
    lv_last_upd_by   NUMBER;
    lv_last_upd_login  NUMBER;
    lv_price     NUMBER;
    lv_org_id            NUMBER ;
    lv_curr   PO_HEADERS_ALL.CURRENCY_CODE%TYPE ;
    lv_conv_rate number ;
    lv_type_lookup_code  VARCHAR2(30);
    lv_quot_class_code   VARCHAR2(30);
    lv_rate  PO_HEADERS_ALL.RATE%TYPE    ;
    lv_ship_to_location_id  PO_HEADERS_ALL.ship_to_location_id%type  ;

    lv_rate_type     PO_HEADERS_ALL.RATE_TYPE%TYPE DEFAULT NULL ;
    lv_rate_date     PO_HEADERS_ALL.RATE_DATE%TYPE DEFAULT NULL ;
    lv_func_curr         VARCHAR2(15);

    flag1     VARCHAR2(10);

    CURSOR tax_override_flag_cur(c_vendor_id NUMBER, c_vendor_site_id NUMBER) IS
    SELECT override_flag
    FROM JAI_CMN_VENDOR_SITES
    WHERE vendor_id = c_vendor_id
    AND vendor_site_id = nvl(c_vendor_site_id,0) ;

    cursor fetch_vendor_id_cur(p_po_hdr_id  po_headers_all.po_header_id%type )  IS
    select vendor_id,vendor_site_id , currency_code , rate ,RATE_TYPE , RATE_DATE  ,ship_to_location_id
    from po_headers_all
    where po_header_id=p_po_hdr_id;

    CURSOR Fetch_Dtls1_Cur( lineid IN NUMBER, linelocid IN NUMBER ) IS
    SELECT  Price_Override ,Unit_Meas_Lookup_Code
    FROM   Po_Line_Locations_All
    WHERE  Po_Line_Id = lineid
    AND   Line_Location_Id = linelocid;

    CURSOR Fetch_Org_Id_Cur IS
    SELECT Inventory_Organization_id
    FROM   Hr_Locations
    WHERE  Location_Id = lv_ship_to_location_id ;

    /*  end 6134628
    */

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.copy_agreement_taxes';
  BEGIN

  /*-----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:   FILENAME: ja_in_po_conc_process_p.sql
  S.No   Date       Author and Details
  -------------------------------------------------------------------------------------------------------------------------
  1    01/08/2002   Nagaraj.s for Bug#2461414
                    The Unit Price in case of an Blanket release was being fetched from  po_line_locations_all where
                    shipment type ='PRICE BREAK' The Price is now calculated based upon the price as available in base
                    apps screen based upon which taxes are calculated properly.

  2  06/12/2002   cbabu for EnhancementBug# 2427465, FileVersion# 615.2
                    tax_category_id column is populated into PO and SO localization tables, which will be used to
                    identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into
                    the  tax table will be useful to identify whether the tax is a defaulted or a manual tax.

  3  17/08/2003   Vijay Shankar for Bug# 3102375, FileVersion# 616.1
                     ship_to_location is not considered in the filter condition to fetch the PRICE BREAK information from the
                     cursors Fetch_Count_Llid_Cur and Fetch_Locid_Cur. The specified cursors are rectified, so that the cursors
                     fetch only records pertaining to the ship_to_location of the release shipment

  4  16/10/2003   Vijay Shankar for Bug# 3191450, FileVersion# 616.2
                     because UOM_CODE plsql table is defined as CHAR(50), all the values in plsql table is being padded with spaces.
                     this makes the cursor's to fail that are dependant on these values. So, modified the definition of UOM_CODE plsql
                     table to use VARCHAR2 instead of CHAR

  5  20/10/2003   Vijay Shankar for Bug# 3205861, FileVersion# 616.3
                     because UOM_CODE plsql table is defined as CHAR(50), all the values in plsql table is being padded with spaces.

  6  05/03/2004   Vijay Shankar for Bug# 3487904, FileVersion# 618.1
                     Whenever the code doesn't fine a record for BPO Line in JAI_PO_LINE_LOCATIONS, then this procedure fails with either
                     no_data_found or duplicate_records found. Fixed this by taking tax category from tax lines otherwise fetching from
                     JAI_PO_LINE_LOCATIONS using the CURSORS c_line_tax_category_id_1 and c_line_tax_category_id_2

  7.     17/mar-2005   Rchandan for bug#4245365   Version#115.2. base bug#4245089
                       Changes made to calculate VAT assessable value . This vat assessable is passed
                       to the procedure that calculates the VAT related taxes

  8.    08-Aug-2007    sacsethi for bug 6134628  , Version 120.19

                       Problem - R12RUP04-ST1: TAXES ARE NOT DEFAULTING FROM BPO TO RELEASES

		       Solution Approach -

		       Procedure copy_agreement_taxes , Code is added to check whether override_flag is Y or
		       If Override_Flag ='Y' then
		              Default Taxes by using tax defaultation Hirarchy
                       else
		              Copy Taxes from Blanked PO
                       end if ;

		       Changes Details
		       -----------------
                         Object Type           Object Name                 Desc.
			 -------------------------------------------------------
			 Procedure             copy_agreement_taxes        Code is added related to Supplier Override flag
			                                                   and Tax defaultation flag

			 Procedure             Ja_In_Po_Case2              code is added for RELEASE type_lookup_code

  9.    01/15/2008  Kevin Cheng   Add a parameter to distinguish retroactive price update process
  -------------------------------------------------------------------------------------------------------------------------*/

    --File.Sql.35 Cbabu
    v_qty    := p_qty;
    i        := 1;
    flag     :=  TRUE;
    DUMMY    := 1;


    /*  Date 08-Aug-2007 by sacsethi for bug 6134628
        || Start 6134628
    */
   v_vendor_id := null ;
   v_vendor_site_id := null;
   lv_override_flag := 'N' ;

   open fetch_vendor_id_cur(p_hdr_id)  ;
   fetch fetch_vendor_id_cur into v_vendor_id , v_vendor_site_id  ,lv_curr   ,lv_rate ,lv_rate_type , lv_rate_date ,lv_ship_to_location_id;
   close fetch_vendor_id_cur ;

   open tax_override_flag_cur (v_vendor_id   , v_vendor_site_id  )  ;
   fetch tax_override_flag_cur into lv_override_flag ;
   close tax_override_flag_cur ;

   open Fetch_Org_Id_Cur ;
   fetch Fetch_Org_Id_Cur into lv_org_id;
   close Fetch_Org_Id_Cur ;


  IF lv_override_flag ='Y' THEN
      --  Override_flag ='Y'
      --  Cause Tax defaultation to happen
      --  from defaultation hirarchy

      lv_cre_dt          := p_cre_dt       ;
      lv_cre_by          := p_cre_by       ;
      lv_last_upd_dt     := p_last_cre_dt  ;
      lv_last_upd_by     := p_last_cre_by  ;
      lv_last_upd_login  := p_last_login   ;
      v_line_loc_id     := p_line_loc_id;
      v_po_line_id      := p_line_id;
      v_po_hdr_id       := p_hdr_id;


      lv_type_lookup_code   := 'RELEASE' ;
      lv_quot_class_code    := 'OTHERS';

      OPEN  Get_Item_Id_Cur;
      FETCH Get_Item_Id_Cur INTO v_item_id;
      CLOSE Get_Item_Id_Cur;

      OPEN  Fetch_Dtls1_Cur( v_po_line_id, v_line_loc_id );
      FETCH Fetch_Dtls1_Cur INTO lv_price , v_uom;
      CLOSE Fetch_Dtls1_Cur;

      OPEN  Fetch_UomCode_Cur( v_uom );
      FETCH Fetch_UomCode_Cur INTO v_uom_code;
      CLOSE Fetch_UomCode_Cur;

      OPEN  Fetch_Org_Id_Cur;
      FETCH Fetch_Org_Id_Cur INTO lv_org_id;
      CLOSE fetch_Org_Id_Cur;

/*
      fnd_file.put_line(fnd_file.log,' v_type_lookup_code ' || v_type_lookup_code ||
                                     ' v_quot_class_code  ' || v_quot_class_code||
                                     'v_vendor_id ' || v_vendor_id||
                                     'v_vendor_site_id' ||v_vendor_site_id ||
                                     'v_curr  ' || v_curr||
                                     'v_org_id' ||v_org_id ||
                                     'v_Item_Id' ||v_Item_Id ||
                                     'v_line_loc_id ' ||v_line_loc_id ||
                                     'v_po_hdr_id ' ||v_po_hdr_id ||
                                     'v_po_line_id' || v_po_line_id||
                                     'v_price' || v_price||
                                     'v_qty         ' ||v_qty ||
                                     'v_cre_dt' || v_cre_dt||
                                     'v_cre_by' ||v_cre_by ||
                                     'v_last_upd_dt' || v_last_upd_dt||
                                     'v_last_upd_by' || v_last_upd_by||
                                     'v_last_upd_login' ||v_last_upd_login ||
                                     'v_uom_code' ||v_uom_code ||
                                     'flag1' ||flag1 ||
                                     'v_assessable_value ' ||v_assessable_value ||
                                     'ln_vat_assess_value ' || ln_vat_assess_value||
                                     'v_rate, 1 ) '  || v_rate  );
*/

      jai_po_tax_pkg.Ja_In_Po_Case2( lv_type_lookup_code  ,
                                     lv_quot_class_code  ,
                                     v_vendor_id,
                                     v_vendor_site_id,
                                     lv_curr,
                                     lv_org_id,
                                     v_Item_Id,
                                     v_line_loc_id,
                                     v_po_hdr_id     ,
                                     v_po_line_id     ,
                                     lv_price,
                                     v_qty         ,
                                     lv_cre_dt,
                                     lv_cre_by,
                                     lv_last_upd_dt,
                                     lv_last_upd_by,
                                     lv_last_upd_login,
                                     v_uom_code,
                                     'I',
                                     NVL( v_assessable_value, -9999 ),
                                     ln_vat_assess_value,
                                     NVL( lv_rate, 1 ) );
    /*
        End 6134628
    */
  ELSE  -- For Override filag = 'N'

  IF p_ship_type = 'SCHEDULED' THEN

    OPEN  Fetch_Qty_Cur( p_line_loc_id );
    FETCH Fetch_Qty_Cur INTO v_old_qty, v_temp_price, v_uom;
    CLOSE Fetch_Qty_Cur;

    FOR Tax_Rec IN Fetch_Tax_Lines_Cur LOOP

      v_tax_amt := ( NVL( Tax_Rec.Tax_Amount, 0 ) * NVL( v_qty, 0 ) ) / NVL( v_old_qty, 1 );
      --Incorporated by Nagaraj.s on 15/05/2002 for Bug#2373231

      BEGIN
        SELECT COUNT(1) INTO v_tax_count FROM
        JAI_PO_TAXES
        WHERE Line_Location_Id = Tax_Rec.Line_Location_Id AND
        TAX_ID = Tax_Rec.Tax_id;
      END;

      IF v_tax_count =0 THEN


         -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

         INSERT INTO JAI_PO_TAXES(
          Line_Focus_Id,
          Line_Location_Id,  Tax_Line_No,
          Po_Line_Id, Po_Header_Id,
    Precedence_1, Precedence_2, Precedence_3, Precedence_4,Precedence_5,
    Precedence_6, Precedence_7, Precedence_8, Precedence_9,Precedence_10,
    Tax_Id, Currency,  Tax_Rate, Qty_Rate, UOM, Tax_Amount,
          Tax_Type, Modvat_Flag, Vendor_Id, Tax_Target_Amount,
          Creation_Date, Created_By,
          Last_Update_Date, Last_Updated_By, Last_Update_Login,
          tax_category_id   -- cbabu for EnhancementBug# 2427465
        ) VALUES (
          Tax_Rec.Line_Focus_Id, --p_seq_val, -- Modified By Sjha
          Tax_Rec.Line_Location_Id, Tax_Rec.Tax_Line_No,
          Tax_Rec.Po_Line_Id, Tax_Rec.Po_Header_Id,
    Tax_Rec.Precedence_1,Tax_Rec.Precedence_2, Tax_Rec.Precedence_3, Tax_Rec.Precedence_4, Tax_Rec.Precedence_5,
    Tax_Rec.Precedence_6,Tax_Rec.Precedence_7, Tax_Rec.Precedence_8, Tax_Rec.Precedence_9, Tax_Rec.Precedence_10,
    Tax_Rec.Tax_Id, Tax_Rec.Currency,
          Tax_Rec.Tax_Rate, Tax_Rec.Qty_Rate, Tax_Rec.UOM, v_tax_amt,
          Tax_Rec.Tax_Type, Tax_Rec.Modvat_Flag, Tax_Rec.Vendor_Id, Tax_Rec.Tax_Target_Amount,
          Tax_Rec.Creation_Date, Tax_Rec.Created_By,
          Tax_Rec.Last_Update_Date, Tax_Rec.Last_Updated_By, Tax_Rec.Last_Update_Login,
          tax_rec.tax_category_id   -- cbabu for EnhancementBug# 2427465
        );
      END IF;
      v_line_loc_id := Tax_Rec.Line_Location_Id;
      v_po_hdr_id := Tax_Rec.Po_Header_Id;
      v_po_line_id := Tax_Rec.Po_Line_Id;

    END LOOP;

       OPEN  Fetch_Qty_Cur( v_line_loc_id );
       FETCH Fetch_Qty_Cur INTO v_qty, v_temp_price
        -- Only PLANNED Shipment Type (Source line_location_id) will have UOM and Scheduled type of Shipments will not have value
        -- and this is the reason why excise taxes are not getting calculated on assessable value, bcos ass value is based on UOM
        -- Commented by Vijay Shankar for Bug# 3205861
        -- , v_uom
        , v_junk_uom
        ;
       CLOSE Fetch_Qty_Cur;

       OPEN  Fetch_UomCode_Cur( v_uom );
       FETCH Fetch_UomCode_Cur INTO v_uom_code;
       CLOSE Fetch_UomCode_Cur;

       OPEN  Get_Assessable_Val_Cur;
       FETCH Get_Assessable_Val_Cur INTO v_vendor_id, v_vendor_site_id, v_doc_curr;
       CLOSE Get_Assessable_Val_Cur;

       OPEN  Get_Item_Id_Cur;
       FETCH Get_Item_Id_Cur INTO v_item_id;
       CLOSE Get_Item_Id_Cur;

       v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value
                     ( v_vendor_id, v_vendor_site_id,
                       v_item_id, v_uom_code
                      );

       ln_vat_assess_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                                ( p_party_id => v_vendor_id,
                                                  p_party_site_id => v_vendor_site_id,
                                                  p_inventory_item_id => v_item_id,
                                                  p_uom_code => v_uom_code,
                                                  /* Bug 4520049. Added by Lakshmi Gopalsami*/
                                                  p_default_price => nvl(v_temp_price,v_unit_price),
                                                  p_ass_value_date => SYSDATE,
                                                  p_party_type => 'V'
                                                 ) ;    -- Ravi for VAT

       IF v_assessable_value IS NULL THEN
          v_assessable_value := v_temp_price * v_qty;
       ELSE
          v_assessable_value := v_assessable_value * v_qty;
          jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_doc_curr, v_curr_conv_factor ) ;
       END IF;

       ln_vat_assess_value := ln_vat_assess_value * v_qty;   -- Ravi for VAT
       IF ln_vat_assess_value <> ( v_temp_price * v_qty ) THEN     -- Ravi for VAT

         jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, ln_vat_assess_value, v_doc_curr, v_curr_conv_factor ) ;

       END IF;/*Ravi*/


       jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, DUMMY, v_doc_curr, v_curr_conv_factor ) ;

       jai_po_tax_pkg.calculate_tax
        ( 'STANDARDPO', v_po_hdr_id , v_po_line_id, v_line_loc_id,
          v_qty, v_qty*v_temp_price, v_uom_code,
          v_assessable_value, v_assessable_value, NULL, v_curr_conv_factor
         );

       OPEN  Fetch_Tot_Sum_Cur( v_line_loc_id );
       FETCH Fetch_Tot_Sum_Cur INTO v_tax_amt1;
       CLOSE Fetch_Tot_Sum_Cur;

       UPDATE JAI_PO_LINE_LOCATIONS
       SET    Tax_Amount   = v_tax_amt1,
            Total_Amount = NVL( v_qty * v_temp_price, 0 ) + v_tax_amt1 ,
      Last_Update_Date  = p_last_cre_dt,
      Last_Updated_By =   p_last_cre_by,
      Last_Update_Login = p_last_login
       WHERE  Line_Location_Id =  v_line_loc_id;

    ELSE  -- BLANKET

  --  pShipToOrganizationId IN NUMBER DEFAULT NULL
  --  pShipToLocationId IN NUMBER DEFAULT NULL

    -- cbabu for Bug# 3102375
    OPEN  cShipmentDetails(p_line_loc_id);
    FETCH cShipmentDetails INTO vShpDtl;
    CLOSE cShipmentDetails;

    IF vShpDtl.ship_to_organization_id IS NOT NULL AND vShpDtl.ship_to_location_id IS NOT NULL THEN
      vQryOn := 'ALL';
    ELSIF vShpDtl.ship_to_organization_id IS NOT NULL AND vShpDtl.ship_to_location_id IS NULL THEN
      vQryOn := 'ORG';
    ELSE
      vQryOn := 'NULL';
    END IF;

      -- OPEN  Fetch_Count_Llid_Cur;
      OPEN  Fetch_Count_Llid_Cur(vQryOn, vShpDtl.ship_to_organization_id, vShpDtl.ship_to_location_id, 'PRICE BREAK'); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
      FETCH Fetch_Count_Llid_Cur INTO v_count;
      CLOSE Fetch_Count_Llid_Cur;

      OPEN  Fetch_Lineid_Cur;
      FETCH Fetch_Lineid_Cur INTO v_po_line_id, v_unit_price, v_uom, v_item_id;
      CLOSE Fetch_Lineid_Cur;
      v_qty := p_qty;
      IF v_count > 0 THEN

         IF p_cum_flag = 'CUMULATIVE' THEN
      -- OPEN  Fetch_Cum_Qty_Cur;
      OPEN  Fetch_Cum_Qty_Cur(vQryOn, vShpDtl.ship_to_organization_id, vShpDtl.ship_to_location_id, 'PRICE BREAK');    /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
      FETCH Fetch_Cum_Qty_Cur INTO v_qty;
      CLOSE Fetch_Cum_Qty_Cur;
         ELSE
      v_qty := p_qty;
         END IF;
         /*
             Check out for I line loc. id Qty. If p_qty < then consider the line.
       insert all the qty, price into PL/SQL table then do all the checking.
         */
         -- FOR Lines_Rec IN Fetch_Locid_Cur LOOP
         FOR Lines_Rec IN Fetch_Locid_Cur(vQryOn, vShpDtl.ship_to_organization_id, vShpDtl.ship_to_location_id, 'PRICE BREAK') LOOP /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
             Llid_tab( i ) := Lines_Rec.Line_Location_Id;
             Qty_Tab( i )  := Lines_Rec.Quantity;
         Price_Tab( i ) := Lines_Rec.Price_Override;
         Uom_Tab( i ) := Lines_Rec.Unit_Meas_Lookup_Code;
             i := i + 1;
         END LOOP;
         i := i - 1;
         IF ( Qty_Tab( 1 ) > v_qty ) THEN
             v_line_loc_id := -999;
       v_line_id := p_line_id;
       v_qty := p_qty;
         ELSE
          FOR j IN 1 .. i LOOP
             v_temp_qty1 := Qty_Tab( j );
             IF j < i - 1 THEN
          v_temp_qty2 := Qty_Tab( j+1  );
             ELSE
                v_temp_qty2 := v_qty + j;
             END IF;
             IF v_qty >= v_temp_qty1 AND v_qty < v_temp_qty2 THEN
                v_temp_price := Price_Tab( j );
                /*FOR k IN 1 .. J LOOP
                    IF v_temp_price < Price_Tab( k ) THEN
                       v_temp_price := Price_Tab( k );
                       v_row := k;
                    ELSE
          v_row := j;
                    END IF;
                END LOOP;*//*commented by rchandan for bug#3637364 and adde the following line*/ --pramasub FP
			   v_row := j;
             END IF;
           END LOOP;
        /*   Commented by nprashar for bug 7694945
          v_line_loc_id := Llid_Tab( v_row );
           v_line_id     := p_line_id;
       v_qty := Qty_Tab( v_row );
             v_qty := p_qty;   -- Added by Abhay and Anand on 19-Jul-2000
       v_uom := Uom_Tab( v_row ); Ends here */
       --v_unit_price := Price_Tab( v_row );

     /*Code Added by nprashar for bug # 7694945*/
    If v_row is not null and v_row > 0 then /*Added by nprashar for bug 7694945 */
              v_line_loc_id := -999; /*Commented this condition by nprashar for bug 8478826 Llid_Tab( v_row );*/
              v_line_id     := p_line_id;
              v_qty := Qty_Tab( v_row );
              v_uom := Uom_Tab( v_row );
           Else
                v_line_loc_id := -999;
                v_line_id     :=  p_line_id;
           End If;
             v_qty := p_qty;   -- Added by Abhay and Anand on 19-Jul-2000 /*Addition Ends here */

  /*--Added by Nagaraj.s for Fetching Price....
       OPEN FETCH_PRICE_CUR;
       FETCH FETCH_PRICE_CUR INTO v_unit_price;
       CLOSE FETCH_PRICE_CUR;
       --Ends Here.........*/
        END IF;

    ELSIF v_count = 0 THEN
      v_line_loc_id := -999;
      v_line_id := p_line_id;
      v_qty := p_qty;
    END IF;
	--pramasub FP start
	  OPEN FETCH_PRICE_CUR;/*rchandan for bug#3637364*/
 	  FETCH FETCH_PRICE_CUR INTO v_unit_price;
 	  CLOSE FETCH_PRICE_CUR;
	-- pramasub FP end

    OPEN  Fetch_UomCode_Cur( v_uom );
    FETCH Fetch_UomCode_Cur INTO v_uom_code;
    CLOSE Fetch_UomCode_Cur;

    FOR Tax_Rec IN Fetch_Taxes_Cur( v_line_id, v_line_loc_id ) LOOP

    -- v_tax_amt := Tax_Rec.Tax_Amount * v_qty / p_qty;
    --Incorporated by Nagaraj.s on 15/05/2002 for Bug#2373231
      BEGIN
        SELECT COUNT(1) INTO v_tax_count FROM
        JAI_PO_TAXES
        WHERE Line_Location_Id = p_line_Loc_Id AND
        TAX_ID = Tax_Rec.Tax_id;
      END;

     -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      IF v_tax_count =0 THEN
        INSERT INTO JAI_PO_TAXES(
          line_focus_id, line_location_id, tax_line_no,
          po_line_id, po_header_id,
    precedence_1, precedence_2, precedence_3, precedence_4, precedence_5,
    precedence_6, precedence_7, precedence_8, precedence_9, precedence_10 ,
          tax_id, currency, tax_rate,
          qty_rate, uom, tax_amount, tax_type,
          modvat_flag, vendor_id, tax_target_amount,
          creation_date, created_by, last_update_date, last_updated_by, last_update_login,
          tax_category_id   -- cbabu for EnhancementBug# 2427465
        ) VALUES (
          p_seq_val, p_line_Loc_Id, Tax_Rec.Tax_Line_No,
          p_Line_Id, p_hdr_id,
    Tax_Rec.Precedence_1,Tax_Rec.Precedence_2, Tax_Rec.Precedence_3, Tax_Rec.Precedence_4, Tax_Rec.Precedence_5,
      Tax_Rec.Precedence_6,Tax_Rec.Precedence_7, Tax_Rec.Precedence_8, Tax_Rec.Precedence_9, Tax_Rec.Precedence_10,
          Tax_Rec.Tax_Id, Tax_Rec.Currency, Tax_Rec.Tax_Rate,
          Tax_Rec.Qty_Rate, Tax_Rec.UOM, 0, Tax_Rec.Tax_Type,
          Tax_Rec.Modvat_Flag, Tax_Rec.Vendor_Id,   0,
          p_cre_dt, p_cre_by, p_last_cre_dt, p_last_cre_by, p_last_login,
          tax_rec.tax_category_id   -- cbabu for EnhancementBug# 2427465
        );
      END IF;

      -- Vijay Shankar for Bug# 3487904
      v_tax_category_id_holder := nvl( tax_rec.tax_category_id, v_tax_category_id_holder);

    END LOOP;

    -- if clause added by Vijay Shankar for Bug# 3487904
    If v_tax_category_id_holder IS NULL THEN
      IF v_line_loc_id = -999 THEN
        OPEN c_line_tax_category_id_1(v_po_line_id);
        FETCH c_line_tax_category_id_1 INTO v_tax_category_id_holder;
        CLOSE c_line_tax_category_id_1;
      ELSE
        OPEN c_line_tax_category_id_2(v_po_line_id, v_line_loc_id);
        FETCH c_line_tax_category_id_2 INTO v_tax_category_id_holder;
        CLOSE c_line_tax_category_id_2;
      END IF;
    end if;

    UPDATE JAI_PO_LINE_LOCATIONS
    SET tax_category_id = v_tax_category_id_holder
    WHERE line_focus_id = p_seq_val;
    -- End, 3487904

    /* following block is commented and replaced with the above UPDATE statement
    -- Start, cbabu for EnhancementBug# 2427465
    BEGIN
      IF v_line_loc_id = -999 THEN
        SELECT tax_category_id INTO v_tax_category_id_holder
        FROM JAI_PO_LINE_LOCATIONS
        WHERE po_line_id = v_po_line_id
        AND (line_location_id IS NULL OR line_location_id = 0);
      ELSE -- line_location_id is present in PO_LINE_LOCATIONS_ALL
        SELECT tax_category_id INTO v_tax_category_id_holder
        FROM JAI_PO_LINE_LOCATIONS
        WHERE po_line_id = v_po_line_id
        AND line_location_id = v_line_loc_id;
      END IF;

      UPDATE JAI_PO_LINE_LOCATIONS
      SET tax_category_id = v_tax_category_id_holder
      WHERE line_focus_id = p_seq_val;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR( -20101, '1 Exception raised in jai_po_tax_pkg.copy_agreement_taxes: '||SQLERRM, TRUE);
    END;
    -- End, cbabu for EnhancementBug# 2427465
    */

        v_line_loc_id := p_line_loc_id;
        v_po_line_id := p_line_id;
        v_po_hdr_id := p_hdr_id;
        OPEN  Get_Assessable_Val_Cur;
        FETCH Get_Assessable_Val_Cur INTO v_vendor_id, v_vendor_site_id, v_doc_curr;
        CLOSE Get_Assessable_Val_Cur;

        OPEN  Get_Item_Id_Cur;
        FETCH Get_Item_Id_Cur INTO v_item_id;
        CLOSE Get_Item_Id_Cur;

        v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value
                      ( v_vendor_id, v_vendor_site_id,
                        v_item_id, v_uom_code
                       );

        IF v_assessable_value IS NULL THEN
           v_assessable_value := v_unit_price * v_qty;
        ELSE
           v_assessable_value := v_assessable_value * v_qty;
           jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_doc_curr, v_curr_conv_factor ) ;
        END IF;

        ln_vat_assess_value :=  jai_general_pkg.ja_in_vat_assessable_value    /*Ravi*/
                                                      ( p_party_id => v_vendor_id,
                                                        p_party_site_id => v_vendor_site_id,
                                                        p_inventory_item_id => v_item_id,
                                                        p_uom_code => v_uom_code,
                                                        p_default_price => v_temp_price,
                                                        p_ass_value_date => SYSDATE,
                                                        p_party_type => 'V'
                                                 ) ;    -- Ravi for VAT

        ln_vat_assess_value := ln_vat_assess_value * v_qty;   -- Ravi for VAT
        IF ln_vat_assess_value <> ( v_temp_price * v_qty ) THEN    -- Ravi for VAT

          jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, ln_vat_assess_value, v_doc_curr, v_curr_conv_factor ) ;

        END IF; -- Ravi for VAT
        IF nvl(ln_vat_assess_value,0) = 0 THEN /*rchandan for bug#6685406(6766561)*/

           ln_vat_assess_value := v_unit_price * v_qty;

        END IF;

        jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, DUMMY, v_doc_curr, v_curr_conv_factor ) ;

      -- Pass Line_Location_Id in place of Header_Id in procedure Cal_Tax.
        jai_po_tax_pkg.calculate_tax( 'RELEASE', p_line_loc_id, p_line_id, v_line_loc_id,
              p_qty, v_unit_price * p_qty, v_uom_code,
              Tax_Amount, v_assessable_value,ln_vat_assess_value, NULL, v_curr_conv_factor
              , pv_retroprice_changed --Added by Kevin Cheng for Retroactive Price 2008/01/10
              );  -- Ravi for VAT
      END IF;

      DELETE FROM JAI_PO_REQUEST_T WHERE line_focus_id = p_seq_val;
 END IF ;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END copy_agreement_taxes;

  /*--------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME - ja_in_po_default_taxes_pkg.sql
  S.No  Date  Author and Details
  -------------------------------------------------
  1 5/12/2002 Vijay Shankar for Bug# 2695844, FileVersion: 615.1
           when making a call to jai_po_tax_pkg.calculate_tax procedure, v_uom is going as NULL and so the procedure is making a call to po_lines_all
           table to fetch the uom and which is giving the mutating error.
           Created a new variable v_uom_code and passing the same to jai_po_tax_pkg.calculate_tax that will not make a query on po_lines_all

  2 6/12/2002 Vijay Shankar for EnhancementBug# 2427465, FileVersion# 615.2
          tax_category_id column is populated into PO and SO localization tables, which will be used to
          identify from which tax_category the taxes are defaulted. Also the tax_category_id populated into the
          tax table will be useful to identify whether the tax is a defaulted or a manual tax.
          New parameter is added in JA_IN_PO_INSERT procedure that is internally called from other procedure of this package

  3 14/04/2004  Vijay Shankar for Bug# 3466223, FileVersion# 619.1
           RAISE_APPLICATION_ERROR is removed, this is stopping tax defaultation if tax_category_id is not found for
           the Source Document line/shipment in Localization tables.
           For this purpose Cursors c_line_tax_category_id_1 and c_line_tax_category_id_2 are added

  4 12/03/2005  Bug 4210102. Added by LGOPALSA
                (1) Added check file syntax
          (2) Added NOCOPY for OUT Parameters
          (3) Added CVD and Customs education cess

  5.17-Mar-2005  hjujjuru - bug #4245062  File version 115.2
                  The Assessable Value is calculated for the transaction. For this, a call is
                  made to the function ja_in_vat_assessable_value_f.sql with the parameters
                  relevant for the transaction. This assessable value is again passed to the
                  procedure that calucates the taxes.

                  Base bug - #4245089

  6. 22-Jun-2007  CSahoo for bug#6144740 File Version 120.15
  								added a new input parameter p_quantity to the procedure.



  ===============================================================================
  Dependencies

  Version  Author       Dependencies      Comments
  115.1    LGOPALSA      IN60106 +         Added cess related tax types
                         4146708

  115.2   hjujjuru       4245089         VAT Implelentation
  --------------------------------------------------------------------------------------------------------------------------*/

  PROCEDURE Ja_In_Po_Case1(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code  IN VARCHAR2,
    vendor_id IN NUMBER,
    v_vendor_site_id IN NUMBER,
    currency IN VARCHAR2,
    v_org_id IN NUMBER,
    v_item_id IN NUMBER,
    v_uom_measure IN VARCHAR2,
    v_line_loc_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_frm_po_line_id IN NUMBER,
    v_frm_line_loc_id IN NUMBER,
    v_price  IN NUMBER,
    v_qty IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    flag IN VARCHAR2,
    success IN OUT NOCOPY NUMBER,       -- If success doesnt return 0, then Use Ja_In_Po_Case2
		p_quantity   IN PO_LINE_LOCATIONS_ALL.quantity%TYPE  DEFAULT NULL   --added by csahoo for bug#6144740
  )
   IS

    v_seq_val       NUMBER;
    v_vendor_id       NUMBER; --File.Sql.35 Cbabu   :=  vendor_id;
    v_line_amt        NUMBER;
    v_reqn_entries          NUMBER;
    v_requisition_line_id   NUMBER;
    v_po_vendor_id      NUMBER;
    v_seq         NUMBER;

    v_curr          VARCHAR2(30);--File.Sql.35 Cbabu  := currency;
    v_tax_amt         NUMBER;
    v_total_amt       NUMBER;
    v_tax_line_no     NUMBER;
    v_prec1         NUMBER;
    v_prec2         NUMBER;
    v_prec3         NUMBER;
    v_prec4         NUMBER;
    v_prec5         NUMBER;
-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- start Bug 5228046
    v_prec6         NUMBER;
    v_prec7         NUMBER;
    v_prec8         NUMBER;
    v_prec9         NUMBER;
    v_prec10         NUMBER;
-- end Bug 5228046
    v_taxid         NUMBER;
    v_tax_rate        NUMBER;
    v_qty_rate        NUMBER;
    v_uom         VARCHAR2(100);
    v_tax_type        VARCHAR2(30);
    v_mod_flag        VARCHAR2(1);
    v_vendor2_id      NUMBER;
    v_mod_cr        NUMBER;
    v_vendor1_id      NUMBER;
    v_tax_target_amt    NUMBER;

    v_curr_conv_factor      NUMBER;
    v_assessable_value    NUMBER;
    ln_vat_assess_value   NUMBER;  -- added, Harshita for bug #4245062

    v_tax_category_id   JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE; -- cbabu for EnhancementBug# 2427465
    v_tax_category_id_dflt  JAI_PO_LINE_LOCATIONS.tax_category_id%TYPE; -- cbabu for EnhancementBug# 2427465

    CURSOR Fetch_UOMCode_Cur IS
      SELECT Uom_Code
      FROM   Mtl_Units_Of_Measure
      WHERE  Unit_Of_Measure = v_uom_measure;

    CURSOR Fetch_Focus_Id_Cur IS
      SELECT Line_Focus_Id
      FROM   JAI_PO_LINE_LOCATIONS
      WHERE  Po_Line_Id = v_po_line_id
      AND   Line_Location_Id IS NULL;

    CURSOR Fetch_Focus1_Id_Cur IS
      SELECT Line_Focus_Id
      FROM   JAI_PO_LINE_LOCATIONS
      WHERE  Po_Line_Id = v_po_line_id
      AND   Line_Location_Id = v_line_loc_id;

 -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    CURSOR QFetch_Taxes_Cur IS
      SELECT Tax_Line_no,
        Precedence_1, Precedence_2, Precedence_3, Precedence_4, PRecedence_5,
        Precedence_6, Precedence_7, Precedence_8, Precedence_9, PRecedence_10,
  Tax_Id, Currency, Tax_Rate, Qty_Rate,
        UOM, Tax_Amount, Tax_Type, Modvat_Flag, Vendor_Id,
        tax_category_id -- cbabu for EnhancementBug# 2427465
      FROM   JAI_PO_TAXES
      WHERE  Po_Line_Id = v_frm_po_line_id
      AND   Line_Location_Id IS NULL
      ORDER BY Tax_Line_No;

-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

    CURSOR Q1Fetch_Taxes_Cur IS
      SELECT Tax_Line_no,
        Precedence_1,Precedence_2, Precedence_3, Precedence_4, PRecedence_5,
        Precedence_6,Precedence_7, Precedence_8, Precedence_9, PRecedence_10,
  Tax_Id, Currency, Tax_Rate, Qty_Rate,
        UOM, Tax_Amount, Tax_Type, Modvat_Flag, Vendor_Id,
        tax_category_id -- cbabu for EnhancementBug# 2427465
      FROM   JAI_PO_TAXES
      WHERE  Po_Line_Id = v_frm_po_line_id
      AND   Line_Location_Id = v_frm_line_loc_id
      ORDER BY Tax_Line_No;

    CURSOR Fetch_Mod_Cr_Cur( taxid IN NUMBER ) IS
      SELECT Tax_Type, Mod_Cr_Percentage, Vendor_Id,adhoc_flag   --kundan kumar for forward porting to R12
      FROM   JAI_CMN_TAXES_ALL
      WHERE  Tax_Id = taxid;

    CURSOR Fetch_Sum_Cur( Lfid IN NUMBER ) IS
      SELECT SUM( NVL( Tax_Amount, 0 ) )
      FROM   JAI_PO_TAXES
      WHERE  Line_Focus_Id = lfid;

    v_uom_code  VARCHAR2(4);  -- cbabu for Bug# 2695844

    -- Start, added by Vijay Shankar for Bug# 3466223
    CURSOR c_line_tax_category_id_1(p_po_line_id IN NUMBER) IS
      SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
      WHERE po_line_id = p_po_line_id
      AND line_location_id IS NULL;

    CURSOR c_line_tax_category_id_2(p_po_line_id IN NUMBER, p_line_location_id IN NUMBER) IS
      SELECT tax_category_id
      FROM JAI_PO_LINE_LOCATIONS
      WHERE po_line_id = p_po_line_id
      AND line_location_id = p_line_location_id;
    -- End, Vijay Shankar for Bug# 3466223
--Start,Added the following for forward porting to R12 kundan kumar

 CURSOR c_po_quantity_1(p_po_line_id IN NUMBER) IS
    SELECT quantity
    FROM po_line_locations_all
    WHERE po_line_id = p_po_line_id
                  AND line_location_id IS NULL ;

  CURSOR c_po_quantity_2(p_po_line_id IN NUMBER,p_po_line_location_id NUMBER ) IS
  SELECT quantity
    FROM po_line_locations_all
   WHERE po_line_id = p_po_line_id
           AND line_location_id = p_po_line_location_id ;

   lv_adhoc_flag VARCHAR2(1) ;
         ln_tax_id    NUMBER ;
         ln_quot_qty     NUMBER ;
--End Added for Forward Porting kundan kumar
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.ja_in_po_case1';

  BEGIN

    --File.Sql.35 Cbabu
    v_vendor_id       :=  vendor_id;
    v_curr           := currency;

  -- following IF modified to work for 'BLANKET' also by Vijay Shankar for Bug# 3466223
  IF v_type_lookup_Code IN ( 'QUOTATION') THEN

    IF v_line_loc_id IS NULL THEN
      OPEN  Fetch_Focus_Id_Cur;
      FETCH Fetch_Focus_Id_Cur INTO v_seq_val;
      CLOSE Fetch_Focus_Id_Cur;
    ELSE
      OPEN  Fetch_Focus1_Id_Cur;
      FETCH Fetch_Focus1_Id_Cur INTO v_seq_val;
      CLOSE Fetch_Focus1_Id_Cur;
    END IF;

    OPEN  Fetch_UOMCode_Cur;
    FETCH Fetch_UOMCode_Cur INTO v_uom;
    CLOSE Fetch_UOMCode_Cur;

    -- cbabu for Bug# 2695844
    v_uom_code := v_uom;

    v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value
                          ( vendor_id, v_vendor_site_id, v_item_id, v_uom );

    jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_curr, v_curr_conv_factor );

    --added, Harshita for bug #4245062

    ln_vat_assess_value :=
                    jai_general_pkg.ja_in_vat_assessable_value
                    ( p_party_id => vendor_id,
                      p_party_site_id => v_vendor_site_id,
                      p_inventory_item_id => v_item_id,
                      p_uom_code => v_uom,
                      p_default_price => v_price,
                      p_ass_value_date => trunc(SYSDATE),
                      p_party_type => 'V'
                    ) ;

    If nvl(ln_vat_assess_value,0) = 0 Then
     ln_vat_assess_value := v_line_amt ;
    Else
      ln_vat_assess_value := ln_vat_assess_value * v_qty;
      jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id,
                                         ln_vat_assess_value,
           v_curr,
           v_curr_conv_factor );
    End if;
     --ended, Harshita for bug #4245062

    IF v_frm_po_line_id IS NOT NULL OR v_frm_line_loc_id IS NOT NULL THEN

      success := 0;             -- Case 1 is successful !

      IF v_frm_line_loc_id IS NOT NULL AND v_frm_po_line_id IS NOT NULL THEN

        OPEN Q1Fetch_Taxes_Cur;
        LOOP

          FETCH Q1Fetch_Taxes_Cur
    INTO
      v_tax_line_no,
      v_prec1, v_prec2, v_prec3, v_prec4, v_prec5, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
        v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
            v_taxid, v_curr, v_tax_rate, v_qty_rate, v_uom, v_tax_amt,
            v_tax_type, v_mod_flag, v_vendor2_id,
            v_tax_category_id;    -- cbabu for EnhancementBug# 2427465

          EXIT WHEN Q1Fetch_Taxes_Cur%NOTFOUND;

          OPEN Fetch_Mod_Cr_Cur( v_taxid );
          FETCH Fetch_Mod_Cr_Cur INTO v_tax_type, v_mod_cr, v_vendor1_id,lv_adhoc_flag;--Added adhoc flag by kundan kumar for forward porting to R12
          CLOSE Fetch_Mod_Cr_Cur;

          IF v_mod_flag IS NULL THEN
            v_mod_flag := v_mod_cr;
          END IF;

          /* Added by LGOPALSA. Bug 4210102
           * Added CVD and Customs Education Cess */

          IF upper(v_tax_type) IN ( 'CUSTOMS',
                               'CVD',
                                     jai_constants.tax_type_add_cvd ,        -- Date 31/10/2006 Bug 5228046 added by SACSETHI
                                     jai_constants.tax_type_customs_edu_cess,jai_constants.tax_type_sh_customs_edu_cess, /* added by ssawant for bug 5989740 */
                                     jai_constants.tax_type_cvd_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess) /* added by ssawant for bug 5989740 */
          THEN
            v_vendor_id := NULL;
          ELSIF  v_tax_type = 'TDS' THEN
            v_vendor_id := v_vendor1_id;
          ELSE
            v_vendor_id := vendor_id;
          END IF;
  /* added by csahoo for bug# 6144740, start*/
	IF nvl(p_quantity,0) <> 0 then
			ln_quot_qty := p_quantity;
	ELSE
			ln_quot_qty := 1;
	END IF;
	/*bug # 6144740, end*/

--start Added by kundan kumar for forward porting to R12
  IF nvl(lv_adhoc_flag,'N') = 'Y' THEN
  																		/*commented by csahoo for bug#6144740
                                        OPEN c_po_quantity_2(v_frm_po_line_id,v_frm_line_loc_id);
                                        FETCH c_po_quantity_2 INTO ln_quot_qty;
                                        CLOSE c_po_quantity_2;
                                  v_tax_amt := v_tax_amt * v_qty/ln_quot_qty ;*/
                                  v_tax_amt := v_tax_amt * v_qty/ln_quot_qty ;  --added by csahoo for bug#6144740

                                ELSE

                                  v_tax_amt := NULL;

        END IF ;

--End Added by kundan kumar for forward porting to R12

          jai_po_tax_pkg.Ja_In_Po_Insert( v_type_lookup_code, v_quot_class_code,
            v_seq_val, v_line_loc_id,
            v_tax_line_no, v_po_line_id,  v_po_hdr_id,
            v_prec1, v_prec2, v_prec3, v_prec4, v_prec5, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
            v_taxid, v_price, v_qty, v_curr,
            v_tax_rate, v_qty_rate, v_uom,
            v_tax_amt, v_tax_type,  v_mod_flag,--NULL WAS REPLACED BY KUNDAN KUMAR FOR FORWARD PORTING TO R12
            v_vendor_id, NULL,
            v_cre_dt,  v_cre_by, v_last_upd_dt, v_last_upd_by,
            v_last_upd_login,
            v_tax_category_id     -- cbabu for EnhancementBug# 2427465
          );

          -- Vijay Shankar for Bug# 3466223
          v_tax_category_id_dflt := nvl(v_tax_category_id_dflt, v_tax_category_id);

        END LOOP;
        CLOSE Q1Fetch_Taxes_Cur;

      ELSIF v_frm_po_line_id IS NOT NULL AND v_frm_line_loc_id IS NULL THEN

        OPEN QFetch_Taxes_Cur;
        LOOP
          FETCH QFetch_Taxes_Cur INTO  v_tax_line_no,
      v_prec1, v_prec2, v_prec3, v_prec4, v_prec5, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
            v_taxid, v_curr, v_tax_rate, v_qty_rate, v_uom, v_tax_amt,
            v_tax_type, v_mod_flag, v_vendor2_id,
            v_tax_category_id;  -- cbabu for EnhancementBug# 2427465

          EXIT WHEN QFetch_Taxes_Cur%NOTFOUND;


          OPEN Fetch_Mod_Cr_Cur( v_taxid );
          FETCH Fetch_Mod_Cr_Cur INTO v_tax_type, v_mod_cr, v_vendor1_id,lv_adhoc_flag;--Added by kundan kumar for forward porting
          CLOSE Fetch_Mod_Cr_Cur;

          IF v_mod_flag IS NULL THEN
            v_mod_flag := v_mod_cr;
          END IF;

          IF v_tax_type IN (    'Customs',
                                'CVD',
         jai_constants.tax_type_add_cvd ,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI
         jai_constants.tax_type_customs_edu_cess, jai_constants.tax_type_sh_customs_edu_cess, /* added by ssawant for bug 5989740 */
         jai_constants.tax_type_cvd_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess /* added by ssawant for bug 5989740 */
                 ) THEN
            v_vendor_id := NULL;
          ELSIF  v_tax_type = 'TDS' THEN
            v_vendor_id := v_vendor1_id;
          ELSE
            v_vendor_id := vendor_id;
          END IF;
 --Start , added by rchandan for bug#4591242
        IF nvl(lv_adhoc_flag,'N') = 'Y' THEN

                                  OPEN c_po_quantity_1(v_frm_po_line_id);
                                        FETCH c_po_quantity_1 INTO ln_quot_qty;
                                        CLOSE c_po_quantity_1;
                                  v_tax_amt := v_tax_amt * v_qty/ln_quot_qty;

                                ELSE

                                  v_tax_amt := NULL;

        END IF ;
        --End , added by rchandan for bug#4591242
  ---Added the above lines of code for forward porting to R12 ;kundan kumar

          jai_po_tax_pkg.Ja_In_Po_Insert( v_type_lookup_code, v_quot_class_code,
            v_seq_val, v_line_loc_id,
            v_tax_line_no, v_po_line_id,  v_po_hdr_id,
            v_prec1, v_prec2, v_prec3, v_prec4, v_prec5, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
            v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
            v_taxid, v_price, v_qty, v_curr,
            v_tax_rate, v_qty_rate, v_uom,
            v_tax_amt, v_tax_type,  v_mod_flag, --Added by kundan kumar for forward porting to R12
            v_vendor_id, NULL,
            v_cre_dt,  v_cre_by, v_last_upd_dt, v_last_upd_by,
            v_last_upd_login,
            v_tax_category_id
          );    -- cbabu for EnhancementBug# 2427465

          -- Vijay Shankar for Bug# 3466223
          v_tax_category_id_dflt := nvl(v_tax_category_id_dflt, v_tax_category_id);

        END LOOP;
        CLOSE QFetch_Taxes_Cur;

      END IF;

      -- Vijay Shankar for Bug# 3466223
      IF v_tax_category_id_dflt IS NULL THEN
        IF v_frm_line_loc_id IS NULL THEN
          OPEN c_line_tax_category_id_1(v_frm_po_line_id);
          FETCH c_line_tax_category_id_1 INTO v_tax_category_id_dflt;
          CLOSE c_line_tax_category_id_1;
        ELSE
          OPEN c_line_tax_category_id_2(v_frm_po_line_id, v_frm_line_loc_id);
          FETCH c_line_tax_category_id_2 INTO v_tax_category_id_dflt;
          CLOSE c_line_tax_category_id_2;
        END IF;
      END IF;

      UPDATE JAI_PO_LINE_LOCATIONS
      SET tax_category_id = v_tax_category_id_dflt
      WHERE line_focus_id = v_seq_val;
      -- End, Vijay Shankar for Bug# 3466223

      /* commented by Vijay Shankar for Bug# 3466223
      -- Start, cbabu for EnhancementBug# 2427465
      BEGIN
        IF v_frm_line_loc_id IS NOT NULL THEN
          SELECT tax_category_id INTO v_tax_category_id_dflt
          FROM JAI_PO_LINE_LOCATIONS
          WHERE line_location_id = v_frm_line_loc_id;
        ELSE
          SELECT tax_category_id INTO v_tax_category_id_dflt
          FROM JAI_PO_LINE_LOCATIONS
          WHERE po_line_id = v_frm_po_line_id
          AND (line_location_id IS NULL OR line_location_id = 0);
        END IF;

        UPDATE JAI_PO_LINE_LOCATIONS
        SET tax_category_id = v_tax_category_id_dflt
        WHERE line_focus_id = v_seq_val;

      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR( -20101, '5 Exception raised in ja_in_po_default_taxes_pkg'||SQLERRM, TRUE);
      END;
      -- End, cbabu for EnhancementBug# 2427465
      */
     END IF;

    If ( ( v_type_lookup_code <> 'QUOTATION' AND v_quot_class_code <> 'CATALOG' )
      OR v_type_lookup_code <> 'BLANKET' )
    THEN

      jai_po_tax_pkg.calculate_tax( 'STANDARDPO', v_po_hdr_id , v_po_line_id, v_line_loc_id,
        -- v_qty, v_price*v_qty, v_uom, v_tax_amt, v_assessable_value, v_item_id ); -- cbabu for Bug# 2695844
        v_qty, v_price*v_qty, v_uom_code, v_tax_amt, v_assessable_value,ln_vat_assess_value,  -- added, Harshita for bug #4245062
        v_item_id );

    END IF;

    IF  ( v_quot_class_code <> 'CATALOG' OR v_type_lookup_code <> 'BLANKET' ) THEN

      OPEN  Fetch_Sum_Cur( v_seq_val );
      FETCH Fetch_Sum_Cur INTO v_tax_amt;
      CLOSE Fetch_Sum_Cur;

      UPDATE JAI_PO_LINE_LOCATIONS
      SET Tax_Amount = NVL( v_tax_amt, 0 ),
        Total_Amount = NVL( ( v_qty * v_price ), 0 ) + Tax_Amount,
        Last_Updated_By = v_last_upd_by,
        Last_Update_Date = v_last_upd_dt,
        Last_Update_Login = v_last_upd_login
      WHERE  Line_Focus_id = v_seq_val;

    ELSE

      UPDATE JAI_PO_LINE_LOCATIONS
      SET Tax_Amount = NULL,
        Total_Amount = NULL,
        Last_Updated_By = v_last_upd_by,
        Last_Update_Date = v_last_upd_dt,
        Last_Update_Login = v_last_upd_login
      WHERE  Line_Focus_Id = v_seq_val;

    END IF;


  ELSE

    success := 1;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
  success:= null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
  END Ja_In_Po_Case1;

  -------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  PROCEDURE Ja_In_Po_Case2(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code  IN VARCHAR2,
    vendor_id IN NUMBER,
    v_vendor_site_id IN NUMBER,
    currency IN VARCHAR2,
    v_org_id IN NUMBER,
    v_item_id IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_po_line_id IN NUMBER,
    v_price  IN NUMBER,
    v_qty IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by IN NUMBER,
    v_last_upd_login IN NUMBER,
    v_uom_measure IN VARCHAR2,
    flag IN VARCHAR2,
    v_assessable_val IN NUMBER DEFAULT NULL,
    p_vat_assess_value IN NUMBER ,  -- added, Harshita for bug #4245062
    v_conv_rate IN NUMBER DEFAULT NULL,
    /* Bug 5096787. Added by Lakshmi Gopalsami  */
    v_rate IN NUMBER DEFAULT NULL,
    v_rate_date IN DATE DEFAULT NULL,
    v_rate_type IN VARCHAR2 DEFAULT NULL,
    p_tax_category_id IN NUMBER DEFAULT NULL
    ,pv_retroprice_changed IN VARCHAR2 DEFAULT 'N' --Added by Kevin Cheng for Retroactive Price 2008/01/13
  ) IS

    v_vendor_id       NUMBER; --File.Sql.35 Cbabu     :=  vendor_id;
    v_curr          VARCHAR2(30); --File.Sql.35 Cbabu   :=  currency;
    trans_name        VARCHAR2(200);
    v_seq_val       NUMBER;

    v_line_amt        NUMBER;
    v_assessable_value    NUMBER;
    ln_vat_assess_value   NUMBER;  -- added, Harshita for bug #4245062
    v_reqn_entries          NUMBER;
    v_requisition_line_id   NUMBER;

    v_item_class      VARCHAR2(4);
    v_tax_amt         NUMBER;
    v_total_amt       NUMBER;
    v_tax_ctg_id      NUMBER;
    v_uom_code        VARCHAR2(3);
    operation       VARCHAR2(2);
    operation_flag      NUMBER;
    dummy                   NUMBER; --File.Sql.35 Cbabu              :=    1;
    v_curr_conv_factor      NUMBER; -- This is used if v_conv_rate is NULL !

    CURSOR RFQ_Pref2_Cur( itemid IN NUMBER ) IS
      SELECT Item_Class
      FROM   JAI_INV_ITM_SETUPS
      WHERE  Inventory_Item_Id = itemid
      AND    Organization_id   = v_org_id;

    CURSOR Fetch_UOMCode_Cur IS
      SELECT Uom_Code
      FROM   Mtl_Units_Of_Measure
      WHERE  Unit_Of_Measure = v_uom_measure;

    CURSOR Fetch_Focus_Id IS
      SELECT Line_Focus_Id
      FROM   JAI_PO_LINE_LOCATIONS
      WHERE  Po_Line_Id = v_po_line_id
      AND   Po_Header_Id = v_po_hdr_id
      AND   Line_Location_Id IS NULL;

    CURSOR Fetch_Focus1_Id IS
      SELECT Line_Focus_Id
      FROM   JAI_PO_LINE_LOCATIONS
      WHERE  Po_Line_Id = v_po_line_id
      AND    Po_Header_Id = v_po_hdr_id
      AND    Line_Location_Id = v_line_loc_id;

    CURSOR Fetch_Sum_Cur IS
      SELECT SUM( NVL( Tax_Amount, 0 ) )
      FROM   JAI_PO_TAXES
      WHERE  Line_Location_Id = v_line_loc_id
      AND   Tax_Type <> jai_constants.tax_type_tds; -- 'TDS';     /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/

   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.ja_in_po_case2';

   BEGIN

    v_vendor_id    :=  vendor_id;
    v_curr         :=  currency;
    dummy          :=    1;

    OPEN RFQ_Pref2_Cur( v_item_id );
    FETCH RFQ_Pref2_Cur INTO v_item_class;
    CLOSE RFQ_Pref2_Cur;
if p_tax_category_id is null then
    IF v_line_loc_id IS NULL THEN

      jai_cmn_tax_defaultation_pkg.Ja_In_Vendor_Default_Taxes(
        v_org_id,
        v_vendor_id,
        v_vendor_site_id,
        v_item_id,
        v_po_hdr_id,
        v_po_line_id,
        v_tax_ctg_id
      );

    ELSE

      jai_cmn_tax_defaultation_pkg.Ja_In_Vendor_Default_Taxes(
        v_org_id,
        v_vendor_id,
        v_vendor_site_id,
        v_item_id,
        v_po_hdr_id,
        v_line_loc_id,   -- Pass Line location ID instead of line id
        v_tax_ctg_id
      );

    END IF;
 ELSE

                DELETE Jai_Po_Taxes
                 WHERE Po_Line_Id = v_po_line_id
                   AND NVL( Line_Location_Id, 0 ) = NVL( v_line_loc_id, 0 ); /* Replaced -999 with 0 - Bug 6012541 */

                UPDATE Jai_Po_Line_Locations
                         SET Tax_Amount                     = NULL,
                                         Total_Amount                   = NULL,
                                         Last_Updated_By                = fnd_global.user_id,
                                         Last_Update_Date               = sysdate,
                                         Last_Update_Login              = fnd_global.login_id
                 WHERE Po_Line_Id                     = v_po_line_id
             AND NVL( Line_Location_Id, 0 ) = NVL( v_line_loc_id, 0 ); /* Replaced -999 with 0 - Bug 6012541 */

                 v_tax_ctg_id := p_tax_category_id;

  END IF;/*p_tax_category_id IS NULL*/


    IF v_tax_ctg_id IS NOT NULL THEN    -- 000a

      IF v_type_lookup_code NOT IN ( 'STANDARD', 'BLANKET', 'CONTRACT', 'PLANNED' ) THEN
        jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, dummy, v_curr, v_curr_conv_factor );
      END IF;

      OPEN Fetch_UOMCode_Cur;
      FETCH Fetch_UOMCode_Cur INTO v_uom_code;
      CLOSE Fetch_UOMCode_Cur;

      IF flag = 'INSLINES' THEN
        v_line_amt := -1;   -- Line Level Tax Defaulting.
        operation_flag := -1;
        --v_assessable_value := -1;
      ELSE

        operation_flag := 0;
        v_line_amt := v_qty*v_price; -- Shipment/Price Break Level Tax Defaulting.

        IF NVL( v_assessable_val, -9999 ) = -9999 THEN
          v_assessable_value := jai_cmn_setup_pkg.get_po_assessable_value(
                      v_vendor_id, v_vendor_site_id,
                      v_item_id, v_uom_code
                    );

          IF v_assessable_value IS NULL THEN
            v_assessable_value := v_line_amt;
          ELSE
            jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, v_assessable_value, v_curr, v_curr_conv_factor );
            v_assessable_value := v_assessable_value * v_qty;
          END IF;

        ELSE
          v_assessable_value := v_assessable_val;
        END IF;

        -- added, Harshita for bug #4245062

  /* Bug 4516508. Added by Lakshmi Gopalsami
     Assign the default value of the assessable value
  */

  ln_vat_assess_value := p_vat_assess_value;

        IF NVL( ln_vat_assess_value, -9999 ) = -9999 THEN
          ln_vat_assess_value :=
                    jai_general_pkg.ja_in_vat_assessable_value
                    ( p_party_id => v_vendor_id,
                      p_party_site_id => v_vendor_site_id,
                      p_inventory_item_id => v_item_id,
                      p_uom_code => v_uom_code,
                      p_default_price => 0,
                      p_ass_value_date => trunc(SYSDATE),
                      p_party_type => 'V'
                    ) ;

          IF NVL(ln_vat_assess_value,0) = 0 THEN
            ln_vat_assess_value := v_line_amt ;
          ELSE
            ln_vat_assess_value := ln_vat_assess_value * v_qty ;
            jai_po_cmn_pkg.Ja_In_Po_Func_Curr( v_po_hdr_id, ln_vat_assess_value, v_curr, v_curr_conv_factor );
          END IF ;
        END IF ;

        -- ended, Harshita for bug #4245062

      END IF;

      IF flag = 'U' THEN
        operation := '$U';  -- Updation
      ELSE
        operation := '$I';  -- Insert
      END IF;

      IF v_type_lookup_code IN ( 'RFQ', 'QUOTATION' ) AND v_quot_class_code = 'BID'  THEN
        trans_name := v_type_lookup_code || TO_CHAR( v_line_loc_id ) || operation;

      ELSIF ( v_type_lookup_code IN ( 'RFQ', 'QUOTATION' ) AND v_quot_class_code = 'CATALOG' )
        OR v_type_lookup_code = 'BLANKET'
      THEN
        /* Added 'OR' condition - Bug 6012541 */
        IF v_line_loc_id IS NULL OR v_line_loc_id = 0 THEN
          trans_name := v_type_lookup_code || operation;
        ELSE
          trans_name := v_type_lookup_code || TO_CHAR( v_line_loc_id ) || operation;
        END IF;
-- Date 08-Aug-2007 by sacsethi for bug 6134628
-- RELEASE look up type added
      ELSIF v_type_lookup_code IN ( 'STANDARD', 'PLANNED' , 'RELEASE' ) THEN
        trans_name := 'OTHERS' || TO_CHAR( v_line_loc_id ) || operation;
      ELSIF v_type_lookup_code = 'SCHEDULED' THEN
        trans_name := v_type_lookup_code || TO_CHAR( v_line_loc_id ) || operation;
      ELSIF v_type_lookup_code = 'BLANKET' THEN
        trans_name := v_type_lookup_code || TO_CHAR( v_line_loc_id ) || operation;
      END IF;

      jai_cmn_tax_defaultation_pkg.Ja_In_Calc_Prec_Taxes(
        LTRIM( RTRIM( trans_name ) ),
        v_tax_ctg_id,
        v_po_hdr_id,
        v_po_line_id,
        v_assessable_value,
        v_line_amt,
        v_item_id,
        v_qty,
        v_uom_code,
        v_vendor_id,
        v_curr,
        1/v_curr_conv_factor, --v_conv_rate,
        v_cre_dt,
        v_cre_by,
        v_last_upd_dt,
        v_last_upd_by,
        v_last_upd_login,
        operation_flag,
        ln_vat_assess_value  -- added, Harshita for bug #4245062
      , pv_retroprice_changed --Added by Kevin Cheng for Retroactive Price 2008/01/13
      );

      IF ( v_quot_class_code = 'CATALOG' ) OR  ( v_type_lookup_code = 'BLANKET' ) THEN

      /* Added 'AND' condition - Bug 6012541 */
        IF v_line_loc_id IS NOT NULL AND v_line_loc_id <> 0 THEN
          UPDATE JAI_PO_TAXES
          SET Tax_Amount = NULL,
            Tax_Target_Amount = NULL,
            Last_Updated_By = v_last_upd_by,
            Last_Update_Date = v_last_upd_dt,
            Last_Update_Login = v_last_upd_login
          WHERE  Po_Line_Id       = v_po_line_id
          AND   Line_Location_Id = v_line_loc_id;

          UPDATE JAI_PO_LINE_LOCATIONS
          SET Tax_Amount = NULL,
            Total_Amount = NULL,
            Last_Updated_By = v_last_upd_by,
            Last_Update_Date = v_last_upd_dt,
            Last_Update_Login = v_last_upd_login
          WHERE  Po_Line_Id = v_po_line_id
          AND   Line_Location_id = v_line_loc_id;

        ELSE

          UPDATE JAI_PO_TAXES
          SET Tax_Amount = NULL,
            Tax_Target_Amount = NULL,
            Last_Updated_By = v_last_upd_by,
            Last_Update_Date = v_last_upd_dt,
            Last_Update_Login = v_last_upd_login
          WHERE  Po_Line_Id = v_po_line_id
          AND Line_Location_Id IS NULL;

          UPDATE JAI_PO_LINE_LOCATIONS
          SET Tax_Amount = NULL,
            Total_Amount = NULL,
            Last_Updated_By = v_last_upd_by,
            Last_Update_Date = v_last_upd_dt,
            Last_Update_Login = v_last_upd_login
          WHERE  Po_Line_Id = v_po_line_id
          AND Line_Location_id IS NULL;

        END IF;

      END IF;

    END IF;   -- 000a

    --This Part of code is placed after END IF, to correct the tax_amount , Total_Amount
    --Entry into Localization tables , Ramakrishna on 21-may-2001
    IF v_quot_class_code <> 'CATALOG' OR v_type_lookup_code <> 'BLANKET' THEN
      OPEN  Fetch_Sum_Cur;
      FETCH Fetch_Sum_Cur INTO v_tax_amt;
      CLOSE Fetch_Sum_Cur;

      UPDATE JAI_PO_LINE_LOCATIONS
      SET Tax_Amount = nvl(v_tax_amt,0),
        Total_Amount = NVL( ( v_qty * v_price ), 0 ) + nvl(v_tax_amt,0),
        Last_Updated_By = v_last_upd_by,
        Last_Update_Date = v_last_upd_dt,
        Last_Update_Login = v_last_upd_login
      WHERE  Line_Location_id = v_line_loc_id
      AND Po_Line_Id = v_po_line_id;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END Ja_In_Po_Case2;

  -------------------------------------------------------------------------------------------------


  PROCEDURE ja_in_po_insert(
    v_type_lookup_code IN VARCHAR2,
    v_quot_class_code IN VARCHAR2,
    v_seq_val IN NUMBER,
    v_line_loc_id IN NUMBER,
    v_tax_line_no IN NUMBER,
    v_po_line_id IN NUMBER,
    v_po_hdr_id IN NUMBER,
    v_prec1 IN NUMBER,
    v_prec2 IN NUMBER,
    v_prec3 IN NUMBER,
    v_prec4 IN NUMBER,
    v_prec5 IN NUMBER,
    v_prec6 IN NUMBER, -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    v_prec7 IN NUMBER,
    v_prec8 IN NUMBER,
    v_prec9 IN NUMBER,
    v_prec10 IN NUMBER,
    v_taxid IN NUMBER,
    v_price IN NUMBER,
    v_qty IN NUMBER,
    v_curr IN VARCHAR2,
    v_tax_rate IN NUMBER,
    v_qty_rate IN NUMBER,
    v_uom IN VARCHAR2,
    v_tax_amt IN NUMBER ,
    v_tax_type VARCHAR2,
    v_mod_flag IN VARCHAR2,
    v_vendor_id IN NUMBER,
    v_tax_target_amt IN NUMBER,
    v_cre_dt IN DATE,
    v_cre_by IN NUMBER,
    v_last_upd_dt IN DATE,
    v_last_upd_by  IN NUMBER,
    v_last_upd_login IN NUMBER,
    v_tax_category_id IN NUMBER       -- cbabu for EnhancementBug# 2427465
  ) IS

    v_tax_amt1    NUMBER;   --File.Sql.35 Cbabu  := 0;
    v_tax     NUMBER;
    v_tax_target  NUMBER;
--Start Added by  kundan kumar for forward porting to R12
CURSOR cur_taxes_adhoc(cp_tax_id number) IS  --rchandan for bug#4591242
  SELECT adhoc_flag
    FROM JAI_CMN_TAXES_ALL
   WHERE tax_id = cp_tax_id;

         lv_adhoc_flag varchar2(1);   --rchandan for bug#4591242
--End kundan kumar
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_tax_pkg.ja_in_po_insert';
  BEGIN
--Added the following cursor opening for forward porting to R12
 OPEN cur_taxes_adhoc(v_taxid);     -- added rchandan for bug#4591242
        FETCH cur_taxes_adhoc INTO lv_adhoc_flag;
        CLOSE cur_taxes_adhoc;

    v_tax_amt1    := 0;

    IF v_type_lookup_code = 'BLANKET' OR v_quot_class_code = 'CATALOG' THEN
      v_tax := NULL;
      v_tax_target := NULL;
    ELSE
      v_tax := v_tax_amt;
      v_tax_target := v_tax_target_amt;
    END IF;

-- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )

    INSERT INTO JAI_PO_TAXES(
      Line_Focus_Id, Line_Location_Id, Tax_Line_No,
      Po_Line_Id, Po_Header_Id,
      Precedence_1, Precedence_2, Precedence_3, Precedence_4, Precedence_5,
      Precedence_6, Precedence_7, Precedence_8, Precedence_9, Precedence_10,
      Tax_Id, Currency, Tax_Rate, Qty_Rate, UOM,
      Tax_Amount, Tax_Type, Modvat_Flag,
      Vendor_Id, Tax_Target_Amount,
      Creation_Date, Created_By, Last_Update_Date,
      Last_Updated_By, Last_Update_Login,
      tax_category_id       -- cbabu for EnhancementBug# 2427465
    ) VALUES  (
      v_seq_val, v_line_loc_id, v_tax_line_no,
      v_po_line_id, v_po_hdr_id,
      v_prec1, v_prec2, v_prec3, v_prec4, v_prec5,  -- Date 31/10/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      v_prec6, v_prec7, v_prec8, v_prec9, v_prec10,
      v_taxid, v_curr, v_tax_rate, v_qty_rate,
      v_uom, v_tax, v_tax_type, v_mod_flag,
      v_vendor_id, v_tax_target,
      v_cre_dt, v_cre_by, v_last_upd_dt,
      v_last_upd_by, v_last_upd_login,
      v_tax_category_id   -- cbabu for EnhancementBug# 2427465
    );

  EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;

  END Ja_In_Po_Insert;
END jai_po_tax_pkg;

/

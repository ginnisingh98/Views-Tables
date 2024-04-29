--------------------------------------------------------
--  DDL for Package Body JAI_OM_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_TAX_PKG" AS
/* $Header: jai_om_tax.plb 120.14.12010000.5 2010/05/07 05:11:05 srjayara ship $ */

/*------------------------------------------------------------------------------------------
 FILENAME:
1 08-Aug-2005     Ramananda for Bug#4540783. File Version 120.2
                      In Procedure recalculate_excise_taxes:
              Added a new parameter  - p_vat_assess_value and value for the same as ln_vat_assessable_value
                      while calling procedure jai_om_tax_pkg.recalculate_oe_taxes

2.25-Aug-2006  Bug 5490479, Added by aiyer, File version 120.5
               Issue:-
                Org_id parameter in all MOAC related Concurrent programs is getting derived from the profile org_id
                As this parameter is hidden hence not visible to users and so users cannot choose any other org_id from the security profile.

               Fix:-
                1. The Multi_org_category field for all MOAC related concurrent programs should be set to 'S' (indicating single org reports).
                   This would enable the SRS Operating Unit field. User would then be able to select operating unit values related to the
                   security profile.
                2. Remove the default value for the parameter p_org_id and make it Required false, Display false. This would ensure that null value gets passed
                   to the called procedures/ reports.
                3. Change the called procedures/reports. Remove the use of p_org_id and instead derive the org_id using the function mo_global.get_current_org_id
               This change has been made many procedures and reports.
               The procedure recalculate_excise_taxes has been changed for the same.

01/11/2006  SACSETHI for bug 5228046, File version 120.6
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.
16/04/2007  KUNKUMAR for bug 5989740 file version 115.11.6107.2 of file ja_in_calc_taxes_ato_p.sql;
              forward porting to R12
17/04/2007    bduvarag for the Bug#5989740, file version 120.8
      Forward porting the changes done in 11i bug#5907436

20/05/2007  KUNKUMAR for bugno 5604375, file version 120.9
                   Issue:Interface Trip Stop concurrent was running into a warning when the shipped qty field was updated
                         to less than the original ordered qty given during creation of  sales order.
                   Fix: The value of an  un-initialized variable was being accessed.
                        Made the appropriate assignment.
15/06/2007  bduvarag for the bug#6072461, Forward porting of 11i bug#5183031

6/18/2007 ssawant for bug 6134057
    row_count Changed to rec.lno in calculate_ato_taxes procedure.

12/10/2007 Kevin Cheng   Update the logic for inclusive tax calculation

05-Mar-08  Jia Li Added clause logic for bug# 6846048
                  Issue: When unit selling price is changed because of discounts,
                       inclusive taxes are getting added to the tax amount in the  JAI_OM_OE_SO_LINES table.
                       So at ship confirm time, comparing the tax amount in the lines table with the sum of exclusive taxes
                       in the taxes table was not matching and hence the trigger was returning an error.
                  Fix: Ensuring that only exclusive taxes are added to the tax amount in the jai_om_oe_so_lines table.

 22-Oct-2008     CSahoo - bug#4918667, File Version 120.14.12010000.2
                 Issue :- In case of retrobilling functionality, there was a divide by zero error which is caused.
                          The parameter p_line_quantity is being used as a denominator, and in case it is zero
                          it was causing a zero divide error.

                  Resolution :- made the change that in case the p_line_quantity is zero , the tax amt is also zero.

March 01. 2010  Bug 9382657
                Base Tax Amount is not calculated correctly.
                Calculated by multiplying the line amount with effective rate of the precedences
                base_tax_amt_tab(I) := ln_exclusive_price*base_tax_amt_tab(I) + base_tax_amount_nr_tab(I)

31-Mar-2010     Bug 9327049
                Issue - Could not create receipt for RMA for some transactions.
                Cause - Problematic code in procedure calculate_ato_taxes. The
                        pl sql array tax_rate_zero_tab is not not populated for RMA,
                        but is being used for comparison in tax calculation. This raises
                        a No Data Found error.
                Fix   - Added logic to populate the tax_rate_zero_tab array in case of
                        RMA also.

07-May-2010    Bug 9674771
               Issue - Interface trip stop errors out for partial shipment.
               Cause - Similar to that of bug 9327049. Here, the base_tax_amount_nr_tab table is not initialized
                       for zero rate taxes.
               Fix - Added code to initialize the pl sql table for zero rate tax lines also.

------------------------------------------------------------------------------------------*/

PROCEDURE calculate_ato_taxes
(
  transaction_name VARCHAR2,
  P_tax_category_id NUMBER,
  p_header_id NUMBER,
  p_line_id NUMBER,
  p_assessable_value NUMBER default 0,
  p_tax_amount IN OUT NOCOPY NUMBER,
  p_currency_conv_factor NUMBER,
  p_inventory_item_id NUMBER,
  p_line_quantity NUMBER,
  p_quantity NUMBER,
  p_uom_code VARCHAR2,
  p_vendor_id NUMBER,
  p_currency VARCHAR2,
  p_creation_date DATE,
  p_created_by NUMBER,
  p_last_update_date DATE,
  p_last_updated_by NUMBER,
  p_last_update_login NUMBER,
  p_vat_assessable_Value NUMBER DEFAULT 0,
  p_vat_reversal_price NUMBER DEFAULT 0 /*Bug#6072461, bduvarag*/
) IS
  TYPE num_tab IS TABLE OF number
  INDEX BY BINARY_INTEGER;
  TYPE tax_amt_num_tab IS TABLE OF number
  INDEX BY BINARY_INTEGER;

  -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ----------------------------------------------------
  TYPE CHAR_TAB IS TABLE OF  VARCHAR2(10)
  INDEX BY BINARY_INTEGER;

  lt_adhoc_tax_tab             CHAR_TAB;
  lt_inclu_tax_tab             CHAR_TAB;
  lt_tax_rate_tab              NUM_TAB;
  lt_tax_rate_per_rupee        NUM_TAB;
  lt_cumul_tax_rate_per_rupee  NUM_TAB;
  lt_tax_target_tab            NUM_TAB;
  lt_tax_amt_rate_tax_tab      TAX_AMT_NUM_TAB;
  lt_tax_amt_non_rate_tab      TAX_AMT_NUM_TAB;
  lt_func_tax_amt_tab          TAX_AMT_NUM_TAB;
  lv_uom_code                  VARCHAR2(10) := 'EA';
  lv_register_code             VARCHAR2(20);
  ln_inventory_item_id         NUMBER;
  ln_exclusive_price           NUMBER;
  ln_total_non_rate_tax        NUMBER := 0;
  ln_total_inclusive_factor    NUMBER;
  ln_bsln_amt_nr               NUMBER :=0;
  ln_tax_amt_nr                NUMBER(38,10) := 0;
  ln_func_tax_amt              NUMBER(38,10) := 0;
  ln_vamt_nr                   NUMBER(38,10) := 0;
  ln_excise_jb                 NUMBER;
  ln_total_tax_per_rupee       NUMBER;
  ln_assessable_value          NUMBER;
  ln_vat_assessable_value      NUMBER;
  ln_vat_reversal_price        NUMBER;
  ----------------------------------------------------
  p1 num_tab;
  p2 num_tab;
  p3 num_tab;
  p4 num_tab;
  p5 num_tab;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6 num_tab;
  p7 num_tab;
  p8 num_tab;
  p9 num_tab;
  p10 num_tab;

-- END BUG 5228046
  tax_rate_tab num_tab;
  /*
  || Aiyer for bug#4691616. Added tax_rate_zero_tab table
     -------------------------------------------------------------
     tax_rate(i)            tax_rate_tab(i)   tax_rate_zero_tab(i)
     -------------------------------------------------------------
     NULL                       0                 0
     0                          0               -9999
     n (non-zero and not null)  n                 n
     -------------------------------------------------------------
  */
  tax_rate_zero_tab   num_tab;

  tax_type_tab num_tab;
  tax_amt_tab tax_amt_num_tab;
  base_tax_amt_tab tax_amt_num_tab;
  base_tax_amount_nr_tab tax_amt_num_tab; /*Bug 9382657*/
  end_date_tab num_tab;
  rounding_factor_tab num_tab;
  bsln_amt number; -- := p_tax_amount; --Ramananda for File.Sql.35
  v_conversion_rate number := 0;
  v_currency_conv_factor number; -- := p_currency_conv_factor;    --Ramananda for File.Sql.35
  v_tax_amt number := 0;
  vamt  number :=0;
  v_amt number;
  row_count number := 0;
        counter number;
  max_iter number := 10;

        v_rma_ctr Number; -- variable added by sriram - bug # 2740443

        --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
        /*CURSOR tax_cur(p_header_id NUMBER, p_line_id NUMBER) IS
        SELECT c.tax_line_no lno, c.tax_id, c.tax_rate, c.qty_rate, c.uom uom_code, c.func_tax_amount, c.base_tax_amount,
        c.precedence_1 p_1, c.precedence_2 p_2, c.precedence_3 p_3,c.precedence_4 p_4, c.precedence_5 p_5,
  c.precedence_6 p_6, c.precedence_7 p_7, c.precedence_8 p_8,c.precedence_9 p_9, c.precedence_10 p_10,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  c.tax_amount, d.tax_type, d.end_date valid_date, d.rounding_factor,

        DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  \* added by ssumaith - bug# 4245053*\
                decode(upper(d.tax_type),
                       'EXCISE',          1,
                       'ADDL. EXCISE',    1,
                       'OTHER EXCISE',    1,
                       'CVD',             1,
                       'TDS',             2,
                       'EXCISE_EDUCATION_CESS',            1,
                       'CVD_EDUCATION_CESS',               1,
                       'SH_EXCISE_EDUCATION_CESS' ,1,--Added by kundan kumar for bug#5907436
                          'SH_CVD_EDUCATION_CESS' , 1, --Added by kundan kumar for bug#5907436
        'VAT REVERSAL',    5,\*Bug#6072461, bduvarag*\
                           0
                      )
              )
              tax_type_val,
        d.adhoc_flag
        FROM       JAI_OM_OE_SO_TAXES     c ,
                   JAI_CMN_TAXES_ALL        d ,
                   jai_regime_tax_types_v rgm_tax_types   \* added by ssumaith - bug# 4245053*\
        WHERE      c.line_id = p_line_id
        AND        c.header_id = p_header_id
        AND        c.tax_id = d.tax_id
        AND        rgm_tax_types.tax_type (+) = d.tax_type \* added by ssumaith - bug# 4245053*\
        ORDER      BY c.tax_line_no;*/

    --Add by Kevin Cheng for inclusive tax Dec 10, 2007
    CURSOR tax_cur( p_header_id NUMBER
                  , p_line_id NUMBER
                  )
    IS
    SELECT
      c.tax_line_no lno
    , c.tax_category_id
    , c.tax_id
    , c.tax_rate
    , c.qty_rate
    , c.uom uom_code
    , c.func_tax_amount
    , c.base_tax_amount
    , c.precedence_1 p_1
    , c.precedence_2 p_2
    , c.precedence_3 p_3
    , c.precedence_4 p_4
    , c.precedence_5 p_5
    , c.precedence_6 p_6
    , c.precedence_7 p_7
    , c.precedence_8 p_8
    , c.precedence_9 p_9
    , c.precedence_10 p_10  -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    , c.tax_amount
    , d.tax_type
    , d.end_date valid_date
    , nvl(d.rounding_factor,0) rounding_factor
    , DECODE( rgm_tax_types.regime_Code
            , jai_constants.vat_regime                          ,4  /* added by ssumaith - bug# 4245053*/
            , decode( upper(d.tax_type)
                    , 'EXCISE'                                  ,1
                    , 'ADDL. EXCISE'                            ,1
                    , 'OTHER EXCISE'                            ,1
                    , jai_constants.tax_type_cvd                ,1
                    , jai_constants.tax_type_tds                ,2
                    , jai_constants.tax_type_exc_edu_cess       ,6
                    , jai_constants.tax_type_cvd_edu_cess       ,6
                    , jai_constants.tax_type_sh_exc_edu_cess    ,6
                    , jai_constants.tax_type_sh_cvd_edu_cess    ,6
                    , 'VAT REVERSAL'                            ,5/*Bug#6072461, bduvarag*/
                    , 0
                    )
            ) tax_type_val
    , d.adhoc_flag
    , d.vendor_id
    , d.mod_cr_percentage
    , d.inclusive_tax_flag
    FROM
      Jai_Om_Oe_So_Taxes       c
    , Jai_Cmn_Taxes_All        d
    , Jai_Regime_Tax_Types_V   rgm_tax_types   /* added by ssumaith - bug# 4245053*/
    WHERE c.line_id = p_line_id
      AND c.header_id = p_header_id
      AND c.tax_id = d.tax_id
      AND rgm_tax_types.tax_type(+) = d.tax_type /* added by ssumaith - bug# 4245053*/
    ORDER BY
      c.tax_line_no;

    -- following cursor added by sriram - bug # 2740443

    CURSOR c_rma_info (v_header_id Number , v_line_id Number) is
    Select 1
    from JAI_OM_OE_RMA_LINES
    where rma_header_id = v_header_id
    and rma_line_id = v_line_id;

    --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
    /*CURSOR c_rma_tax_cur(p_line_id NUMBER) IS
    SELECT c.tax_line_no lno, c.tax_id, c.tax_rate, c.qty_rate, c.uom uom_code, c.func_tax_amount, c.base_tax_amount,
           c.precedence_1 p_1, c.precedence_2 p_2, c.precedence_3 p_3,c.precedence_4 p_4, c.precedence_5 p_5,
     c.precedence_6 p_6, c.precedence_7 p_7, c.precedence_8 p_8,c.precedence_9 p_9, c.precedence_10 p_10,  -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
     c.tax_amount, d.tax_type, d.end_date valid_date, d.rounding_factor,
           DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  \* added by ssumaith - bug# 4245053*\
                   decode(upper(d.tax_type),'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, 'CVD',1, 'TDS', 2, 0
                          )
                 )         tax_type_val,
           d.adhoc_flag
  FROM   JAI_OM_OE_RMA_TAXES    c,
         JAI_CMN_TAXES_ALL        d ,
         jai_regime_tax_types_v rgm_tax_types   \* added by ssumaith - bug# 4245053*\
    WHERE     c.rma_line_id = p_line_id
      AND     c.tax_id = d.tax_id
      AND     rgm_tax_types.tax_type(+) = d.tax_type \* added by ssumaith - bug# 4245053*\
  ORDER BY    c.tax_line_no;*/

  -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  CURSOR c_rma_tax_cur( p_line_id NUMBER
                      )
  IS
  SELECT
    c.tax_line_no lno
  , c.tax_id
  , c.tax_rate
  , c.qty_rate
  , c.uom uom_code
  , c.func_tax_amount
  , c.base_tax_amount
  , c.precedence_1 p_1
  , c.precedence_2 p_2
  , c.precedence_3 p_3
  , c.precedence_4 p_4
  , c.precedence_5 p_5
  , c.precedence_6 p_6
  , c.precedence_7 p_7
  , c.precedence_8 p_8
  , c.precedence_9 p_9
  , c.precedence_10 p_10 -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  , c.tax_amount
  , d.tax_type
  , d.end_date valid_date
  , nvl(d.rounding_factor,0) rounding_factor
  , DECODE( rgm_tax_types.regime_Code
          , jai_constants.vat_regime, 4  /* added by ssumaith - bug# 4245053*/
          , decode( upper(d.tax_type)
                  , 'EXCISE'                    ,1
                  , 'ADDL. EXCISE'              ,1
                  , 'OTHER EXCISE'              ,1
                  , jai_constants.tax_type_cvd                ,1
                  , jai_constants.tax_type_tds                ,2
                  , jai_constants.tax_type_exc_edu_cess       ,6
                  , jai_constants.tax_type_cvd_edu_cess       ,6
                  , jai_constants.tax_type_sh_exc_edu_cess    ,6
                  , jai_constants.tax_type_sh_cvd_edu_cess    ,6
                  , 'VAT REVERSAL'              ,5/*Bug#6072461, bduvarag*/
                  , 0
                  )
          ) tax_type_val
  , d.adhoc_flag
  , d.vendor_id
  , d.mod_cr_percentage
  , d.inclusive_tax_flag
  FROM
    Jai_Om_Oe_Rma_Taxes    c
  , Jai_Cmn_Taxes_All      d
  , Jai_Regime_Tax_Types_V rgm_tax_types   /* added by ssumaith - bug# 4245053*/
  WHERE c.rma_line_id = p_line_id
    AND c.tax_id = d.tax_id
    AND rgm_tax_types.tax_type(+) = d.tax_type /* added by ssumaith - bug# 4245053*/
  ORDER BY
    c.tax_line_no;

    -- Start of bug 3590208
  /*****************
  Code modified by aiyer for the bug 3590208
  Check whether the excise exemptions exist at the order line level.
  *****************/
    CURSOR c_excise_exemption
  IS
  SELECT
      '1'
  FROM
      JAI_OM_OE_SO_LINES     jsl
    WHERE
      jsl.excise_exempt_type  IS NOT NULL AND
      jsl.line_id       = p_line_id  ;

    lv_excise_exemption_exists VARCHAR2(1);

    -- End of bug 3590208

   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_tax_pkg.calculate_ato_taxes';
   BEGIN
/*------------------------------------------------------------------------------------------
 FILENAME: calculate_ato_taxes_P.sql


CHANGE HISTORY:
S.No      Date          Author and Details
1.  2001/11/09    Anuradha Parthasarathy
        Parameter p_quantity added To handle Adhoc Types of Taxes.
2.  2002/01/03    Anuradha Parthasarathy
        parameter p_quantity used in place of p_line_quantity for correct calculation
        of taxes for which the tax_rate is null.
3.      2003/01/18              Sriram  Bug # 2740443 File Version 615.1
                                When RMA was done without reference and mofifiers attached
                                to them, taxes were not getting recalculated.
                                Hence wrote code to get the same done by adding 2 cursors and checking
                                if the current header id and line id combination refers to a sales order
                                or rma order . if it corresponds to an rma order , update the
                                JAI_OM_OE_RMA_TAXES table .

4.    26-Feb-2004      Aiyer For the Bug #3590208 File Version 619.1
                       Issue:-
                        Excise Duty Recalculation happens for excise exempted tax lines if the order line quantity
            is changed.
                      Fix:-
              Code has been added to set the tax_rate, tax_amount and base_tax_amount to 0 when the Order Line has Excise
            exemptions and tax is of "Excise" type. The cursor c_excise_exemption has been added for the purpose.
           Dependency Due to this code :-
           None

5.   09-Aug-2004    Aiyer - Bug #3802074 File Version 115.2
                    Issue:-
                    Uom based taxes do not get calculated correctly if the qty or price is changed.

                    Reason:-
                    --------
                    Previous to this fix the uom currency uom conversion would happen only when the transaction uom code and the tax level uom code where
          in the same uom class. This was not required.
          This was happening because the UOM calculation was previously happening only for cases of exact match
                    between transaction uom and setup UOM.

                    Fix:-
                    ----
                    Removed the uom_class_cur for loop which used to check for the same uom class match condition. Now the uom conversion happens at all time.
          Now if an exact match is not found then the conversion rate between the two uom's is determined and tax amounts are calculated for defaultation.

                    Dependency Due to This Bug:-
                    ----------------------------
                    The refresh in the India Localization sales order form was not happening properly leading to taxes getting set incorrectly
          when the tax apply button is clicked (in JAINEORD) post updation of qty in Base apps form. To resolve this the locator logic
          was removed from the triggers ja_in_oe_order_lines_aiu_trg and ja_in_oe_order_lines_au_trg and a new trigger was created
          (ja_in_om_locator_aiu_trg). Some fix was also done in JAINEORD.fmb for the same.
          Hence all these objects should be displatched along with this object, due to functional dependency
          As this fix is also being taken in the current Due to this the tax was not getting bug

6. 2005/03/10       ssumaith - bug# 4245053 - File version 115.3

                    Taxes under the vat regime needs to be calculated based on the vat assessable value setup done.
                    In the vendor additional information screen and supplier additional information screen, a place
                    has been given to capture the vat assessable value.

                    This needs to be used for the calculation of the taxes registered under vat regime.

                    This  change has been done by using the view jai_regime_tax_types_v - and outer joining it with the
                    JAI_CMN_TAXES_ALL table based on the tax type column.

                    A parameter  p_vat_assessable_Value NUMBER DEFAULT 0  has been added to the procedure.

                    Dependency due to this bug - Huge
                    This patch should always be accompanied by the VAT consolidated patch - 4245089

7. 08-Jun-2005  Version 116.3 jai_om_tax -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

8. 13-Jun-2005    File Version: 116.4
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

9. 01-Jun-2006     Aiyer for bug# 4691616. File Version 120.3
                     Issue:-
                       UOM based taxes do not get calculated correctly.

                     Solution:-
                      Fwd ported the fix for the bug 4729742.
                      Changed the files JAINTAX1.pld, jai_cmn_tax_dflt.plb and jai_om_tax.plb.

10. 10-Dec-007    Kevin Cheng   Update the logic for inclusive tax calculation

11. 05-Mar-08     Jia Li        Added clause logic for bug# 6846048
                  Issue: When unit selling price is changed because of discounts,
                       inclusive taxes are getting added to the tax amount in the  JAI_OM_OE_SO_LINES table.
                       So at ship confirm time, comparing the tax amount in the lines table with the sum of exclusive taxes
                       in the taxes table was not matching and hence the trigger was returning an error.
                  Fix: Ensuring that only exclusive taxes are added to the tax amount in the jai_om_oe_so_lines table.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                    Version   Author   Date         Remarks
Of File                              On Bug/Patchset     Dependent On
calculate_ato_taxes_p.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.2                 3802074       IN60105D2            ja_in_om_locator_aiu_trg.sql     115.1   Aiyer    26-oct-2004   Functional Dependency
                                                         jai_cmn_utils_pkg.ja_in_set_locator 115.0
                                                         ja_in_oe_order_lines_aiu_trg     115.5
                                                         ja_in_oe_order_lines_aiu_trg     115.5
                                                         JAINEORD.fmb             115.3
                                                         calculate_ato_taxes_p.sql       115.2   Aiyer


115.3                 4245053       IN60106 +                                              ssumaith             Service Tax and VAT Infrastructure are created
                                    4146708 +                                                                   based on the bugs - 4146708 and 4545089 respectively.
                                    4245089


*************************************************************************************************************************************************************/

  bsln_amt               := p_tax_amount; --Ramananda for File.Sql.35
  v_currency_conv_factor := p_currency_conv_factor;    --Ramananda for File.Sql.35

Open  c_rma_info(p_header_id,p_line_id);
Fetch  c_rma_info into v_rma_ctr;
close  c_rma_info;

-- Start of bug 3590208
/*****************
Code modified by aiyer for the bug 3590208
*****************/
OPEN  c_excise_exemption;
FETCH c_excise_exemption INTO lv_excise_exemption_exists;
-- End of bug 3590208

IF NVL(v_rma_ctr,0) = 0 then -- added by sriram - bug #  2740443   abc

  FOR rec in tax_cur(p_header_id, p_line_id)
  LOOP
  p1(rec.lno) := nvl(rec.p_1,-1);
  p2(rec.lno) := nvl(rec.p_2,-1);
  p3(rec.lno) := nvl(rec.p_3,-1);
  p4(rec.lno) := nvl(rec.p_4,-1);
  p5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6(rec.lno) := nvl(rec.p_6,-1);
  p7(rec.lno) := nvl(rec.p_7,-1);
  p8(rec.lno) := nvl(rec.p_8,-1);/*Added by kunkumar,for bugno5604375,deleted second assignment of p7 */
  p9(rec.lno) := nvl(rec.p_9,-1);
  p10(rec.lno) := nvl(rec.p_10,-1);

-- END BUG 5228046

  tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);

  /*
  || The following code added by aiyer for the bug 4691616
  || Purpose:
  || rec.tax_rate = 0 means that tax_rate for such a tax line is actually zero (i.e it is not a replacement of null value)
  || So, when rec.tax_rate = 0, tax_rate_zero_tab is populated with -9999 to identify that this tax_line actually has tax_rate = 0
  || To calculate the BASE_TAX_AMOUNT of the taxes whose tax_rate is zero
  */

  IF rec.tax_rate is null THEN
    /*
    ||Indicates qty based taxes
    */
    tax_rate_zero_tab(rec.lno) := 0; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  ELSIF rec.tax_rate = 0 THEN
    /*
    ||Indicates 0% tax rate becasue a tax can have a rate as 0%.
    */
    tax_rate_zero_tab(rec.lno) := -9999; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  ELSE
    tax_rate_zero_tab(rec.lno) := rec.tax_rate; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  END IF;

  tax_type_tab(rec.lno) := rec.tax_type_val; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/
  /*End of bug 4691616 */

  tax_type_tab(rec.lno) := rec.tax_type_val;
  tax_amt_tab(rec.lno) := 0;
  base_tax_amt_tab(rec.lno) := 0;
  rounding_factor_tab(rec.lno) := NVL(rec.rounding_factor, 0);

  -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ----------------------------------------------------
  lt_tax_rate_per_rupee(rec.lno)   := NVL(rec.tax_rate,0)/100;
  ln_total_tax_per_rupee           := 0;
  lt_inclu_tax_tab(rec.lno)        := NVL(rec.inclusive_tax_flag,'N');
  lt_tax_amt_rate_tax_tab(rec.lno) := 0;
  lt_tax_amt_non_rate_tab(rec.lno) := 0; -- tax inclusive
  ----------------------------------------------------

  IF tax_rate_tab(rec.lno) = 0 THEN
    -- Start of bug 3802074
      /*
       Code added by aiyer for the bug 3802074.
     Removed the uom_class_cur for loop, as it used to check that the uom conversion should happen only when the transaction uom code and the tax uom code
     are in the same uom class. This was not required.
       Now the code check whether an exact match exists between the transaction uom and the setup uom.
       IF an exact match is found then the conversion rate is equal to 1 else the conversion rate between the two uom's would be
       determined and tax amounts, base_tax_amounts are calculated for defaultation.
      */

      inv_convert.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
    IF nvl(v_conversion_rate, 0) <= 0 THEN
      inv_convert.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
      IF nvl(v_conversion_rate, 0) <= 0 THEN
          v_conversion_rate := 0;
        END IF;
      END IF;
      --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
      /*tax_amt_tab(rec.lno) := ROUND(nvl(rec.qty_rate * v_conversion_rate, 0) * p_quantity, NVL(rec.rounding_factor, 0));*/
    -- End of bug 3802074

    --Add by Kevin Cheng for inclusive tax Dec 10, 2007
    ---------------------------------------------------
    lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_quantity;   -- tax inclusive
    base_tax_amt_tab(rec.lno)        := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
    ---------------------------------------------------

    IF rec.adhoc_flag = 'Y' THEN
        --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
        /*tax_amt_tab(rec.lno) := ROUND((rec.tax_amount * p_quantity/p_line_quantity), NVL(rec.rounding_factor, 0));*/
        --Add by Kevin Cheng for inclusive tax Dec 10, 2007
      -- csahoo - bug#4918667  added the if and the else so that we dont encounter a zero-divide error
      IF NVL(p_line_quantity,0) <> 0 THEN
        lt_tax_amt_non_rate_tab(rec.lno) := ROUND((rec.tax_amount * p_quantity/p_line_quantity), NVL(rec.rounding_factor, 0));
      ELSE
        lt_tax_amt_non_rate_tab(rec.lno) := 0;
      END IF;
    END IF;
    END IF;

  IF rec.valid_date is NULL or rec.valid_date >= sysdate
  THEN
    end_date_tab(rec.lno) := 1;
  ELSE
      tax_amt_tab(rec.lno)  := 0;
    end_date_tab(rec.lno) := 0;
    END IF;

    -- Start of bug 3590208
  /*****************
  Code modified by aiyer for the bug 3590208
  IF the line is excise exempted and the tax is of type Excise then set the tax_rate, tax_amount and base_tax_amount
  to zero.
  *****************/
  IF c_excise_exemption%FOUND  AND
     rec.tax_type_val = 1
  THEN
      /* Set tax_rate_tab = 0, tax_amt_tab = 0 and base_tax_amt_tab = 0 */
      tax_rate_tab(rec.lno)   := 0;
      tax_amt_tab(rec.lno)    := 0;
      base_tax_amt_tab(rec.lno) := 0;
      lt_tax_amt_non_rate_tab(rec.lno) :=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  END IF;
  -- End of bug 3590208

    row_count := row_count + 1;
  END LOOP;

ELSIF v_rma_ctr = 1 then    -- else part of abc
     -- v_rma_ctr value will be 1 if the current header id line id combination corresponds to a return order.
     -- added by sriram the section from the following elsif to end if- bug # 2740443

  FOR rec in c_rma_tax_cur(p_line_id) LOOP
  p1(rec.lno) := nvl(rec.p_1,-1);
  p2(rec.lno) := nvl(rec.p_2,-1);
  p3(rec.lno) := nvl(rec.p_3,-1);
  p4(rec.lno) := nvl(rec.p_4,-1);
  p5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6(rec.lno) := nvl(rec.p_6,-1);
  p7(rec.lno) := nvl(rec.p_7,-1);
  p8(rec.lno) := nvl(rec.p_8,-1);
  p9(rec.lno) := nvl(rec.p_9,-1);
  p10(rec.lno) := nvl(rec.p_10,-1);

-- END BUG 5228046


  tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
  tax_type_tab(rec.lno) := rec.tax_type_val;
  tax_amt_tab(rec.lno) := 0;
  base_tax_amt_tab(rec.lno) := 0;
  rounding_factor_tab(rec.lno) := NVL(rec.rounding_factor, 0);

/*bug 9327049*/
  IF rec.tax_rate is null THEN
    /*
    ||Indicates qty based taxes
    */
    tax_rate_zero_tab(rec.lno) := 0; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  ELSIF rec.tax_rate = 0 THEN
    /*
    ||Indicates 0% tax rate becasue a tax can have a rate as 0%.
    */
    tax_rate_zero_tab(rec.lno) := -9999; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  ELSE
    tax_rate_zero_tab(rec.lno) := rec.tax_rate; /*row_count Changed to rec.lno by  ssawant for bug 6134057*/

  END IF;
/*end bug 9327049*/

  -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ----------------------------------------------------
  lt_tax_rate_per_rupee(rec.lno) := NVL(rec.tax_rate,0)/100;
  ln_total_tax_per_rupee         := 0;
  lt_inclu_tax_tab(rec.lno)      := NVL(rec.inclusive_tax_flag,'N');

  IF rec.tax_rate IS NULL
  THEN
    tax_rate_zero_tab(rec.lno) := 0;
  ELSIF rec.tax_rate = 0
  THEN --IF rec.tax_rate IS NULL
    tax_rate_zero_tab(rec.lno) := -9999;
  ELSE --IF rec.tax_rate IS NULL
    tax_rate_zero_tab(rec.lno) := rec.tax_rate;
  END IF; --IF rec.tax_rate IS NULL

  lt_tax_amt_rate_tax_tab(rec.lno) :=0;
  lt_tax_amt_non_rate_tab(rec.lno) :=0; -- tax inclusive
  ----------------------------------------------------

  IF tax_rate_tab(rec.lno) = 0 THEN
    -- Start of bug 3802074
      /*
       Code added by aiyer for the bug 3802074
       Check whether an exact match exists between the transaction uom and the setup uom (obtained through the tax_category list).
       IF an exact match is found then the conversion rate is equal to 1 else the conversion rate between the two uom's would be
       determined and tax amounts,base_tax_amounts are calculated for defaultation.
      */

      inv_convert.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
    IF nvl(v_conversion_rate, 0) <= 0 THEN
      INV_CONVERT.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
      IF nvl(v_conversion_rate, 0) <= 0 THEN
          v_conversion_rate := 0;
        END IF;
      END IF;
      --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
    /*tax_amt_tab(rec.lno) := ROUND(nvl(rec.qty_rate * v_conversion_rate, 0) * p_quantity, NVL(rec.rounding_factor, 0));*/
    -- End of bug 3802074

    -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    ----------------------------------------------------
    lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.qty_rate * v_conversion_rate, 0) * p_quantity;   -- tax inclusive
    base_tax_amt_tab(rec.lno)        := lt_tax_amt_non_rate_tab(rec.lno); -- tax inclusive
    ----------------------------------------------------

    IF rec.adhoc_flag = 'Y' THEN
      --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
      /*tax_amt_tab(rec.lno) := ROUND((rec.tax_amount * p_quantity/p_line_quantity), NVL(rec.rounding_factor, 0));*/
      --Add by Kevin Cheng for inclusive tax Dec 10, 2007
      -- csahoo - bug#4918667  added the if and the else so that we dont encounter a zero-divide error
      IF NVL(p_line_quantity,0) <> 0 THEN
        lt_tax_amt_non_rate_tab(rec.lno) := ROUND((rec.tax_amount * p_quantity/p_line_quantity), NVL(rec.rounding_factor, 0));
      ELSE
        lt_tax_amt_non_rate_tab(rec.lno) := 0;
      END IF;
    END IF;
    END IF;

  IF rec.valid_date is NULL or rec.valid_date >= sysdate  THEN
    end_date_tab(rec.lno) := 1;
  ELSE
      tax_amt_tab(rec.lno)  := 0;
    end_date_tab(rec.lno) := 0;
    END IF;
    -- Start of bug 3590208
  /*****************
  Code modified by aiyer for the bug 3590208
  IF the line is excise exempted and the tax is of type Excise then set the tax_rate, tax_amount and base_tax_amount
  to zero.
  *****************/
  IF c_excise_exemption%FOUND  AND
     rec.tax_type_val = 1
  THEN
      /* Set tax_rate_tab = 0, tax_amt_tab = 0 and base_tax_amt_tab = 0 */
      tax_rate_tab(rec.lno)   := 0;
      tax_amt_tab(rec.lno)    := 0;
      base_tax_amt_tab(rec.lno) := 0;
      lt_tax_amt_non_rate_tab(rec.lno) :=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  END IF;
  -- End of bug 3590208
    row_count := row_count + 1;
  END LOOP;

END IF; -- added by sriram - bug # 2740443. End if of abc
-- Start of bug 3590208
 CLOSE c_excise_exemption ;
-- End of bug 3590208

--Add by Kevin Cheng for inclusive tax Dec 10, 2007
---------------------------------------------------
IF p_vat_assessable_value<>p_tax_amount
THEN
  ln_vat_assessable_value:=p_vat_assessable_value;
ELSE
  ln_vat_assessable_value:=1;
END IF;

IF p_assessable_value<>p_tax_amount
THEN
  ln_assessable_value:=p_assessable_value;
ELSE
  ln_assessable_value:=1;
END IF;

IF p_vat_reversal_price<>p_tax_amount
THEN
  ln_vat_reversal_price:=p_vat_reversal_price;
ELSE
  ln_vat_reversal_price:=1;
END IF;
---------------------------------------------------
--Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
     /*FOR I in 1..row_count LOOP
  IF tax_type_tab(I) = 1
  THEN
      bsln_amt := p_assessable_value;
  ELSIF tax_type_tab(I) = 4 THEN
      bsln_amt := p_vat_assessable_value;
 ELSIF tax_type_tab(I) = 5 THEN       \*bug#6072461, bduvarag*\
      bsln_amt := p_vat_reversal_price;

  ELSE
      bsln_amt := p_tax_amount;
  END IF;
  IF tax_rate_tab(I) <> 0
    THEN
       IF p1(I) < I and p1(I) not in (-1,0)
       THEN
    vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
       ELSIF p1(I) = 0 THEN
    vamt := vamt + bsln_amt;
       END IF;
       IF p2(I) < I and p2(I) not in (-1,0)
       THEN
    vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
       ELSIF p2(I) = 0 THEN
    vamt := vamt + bsln_amt;
       END IF;
       IF p3(I) < I and p3(I) not in (-1,0)
       THEN
    vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
       ELSIF p3(I) = 0 THEN
    vamt := vamt + bsln_amt;
       END IF;


       IF p4(I) < I and p4(I) not in (-1,0)
       THEN
    vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
       ELSIF p4(I) = 0 THEN
    vamt := vamt + bsln_amt;
       END IF;
       IF p5(I) < I and p5(I) not in (-1,0)
       THEN
    vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
       ELSIF p5(I) = 0 THEN
    vamt := vamt + bsln_amt;
       END IF;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

       IF p6(I) < I and p6(I) not in (-1,0)
       THEN
      vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
       ELSIF p6(I) = 0 THEN
            vamt := vamt + bsln_amt;
       END IF;
       IF p7(I) < I and p7(I) not in (-1,0)
       THEN
            vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
       ELSIF p7(I) = 0 THEN
      vamt := vamt + bsln_amt;
       END IF;

       IF p8(I) < I and p8(I) not in (-1,0)
       THEN
            vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
       ELSIF p8(I) = 0 THEN
      vamt := vamt + bsln_amt;
       END IF;
       IF p9(I) < I and p9(I) not in (-1,0)
       THEN
      vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
       ELSIF p9(I) = 0 THEN
      vamt := vamt + bsln_amt;
       END IF;

       IF p10(I) < I and p10(I) not in (-1,0)
       THEN
      vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
       ELSIF p10(I) = 0 THEN
      vamt := vamt + bsln_amt;
       END IF;

-- END BUG 5228046






       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       base_tax_amt_tab(I) := vamt;
             tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
           vamt := 0;
           v_tax_amt := 0;

  END IF;
  END LOOP;*/
  --Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ----------------------------------------------------
  FOR I in 1..row_count LOOP
    IF end_date_tab(I) <> 0 THEN
      IF tax_type_tab(I) = 1
      THEN
        IF ln_assessable_value = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 4  --IF tax_type_tab(I) = 1   THEN
      THEN
        IF ln_vat_assessable_value = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 5   --IF tax_type_tab(I) = 1   THEN
      THEN       /*bug#6072461, bduvarag*/
        IF ln_vat_reversal_price = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_reversal_price;
        END IF;
      ELSIF tax_type_tab(I) = 6
      THEN  --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 0;
        ln_bsln_amt_nr := 0;
      ELSE --IF tax_type_tab(I) = 1   THEN
        bsln_amt := 1;
        ln_bsln_amt_nr := 0;
      END IF;

      IF tax_rate_tab(I) <> 0
      THEN
        IF p1(I) < I and p1(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0);
        ELSIF p1(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p2(I) < I and p2(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0);
        ELSIF p2(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p3(I) < I and p3(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0);
        ELSIF p3(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;


        IF p4(I) < I and p4(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0);
        ELSIF p4(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p5(I) < I and p5(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0);
        ELSIF p5(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

    -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046

        IF p6(I) < I and p6(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0);
        ELSIF p6(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p7(I) < I and p7(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0);
        ELSIF p7(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p8(I) < I and p8(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0);
        ELSIF p8(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p9(I) < I and p9(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0);
        ELSIF p9(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

        IF p10(I) < I and p10(I) not in (-1,0)
        THEN
          vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0);
        ELSIF p10(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr;
        END IF;

    -- END BUG 5228046

        v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
        base_tax_amt_tab(I) := vamt;
        base_tax_amount_nr_tab(I):=ln_vamt_nr; /*Bug 9382657*/
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);

        vamt := 0;
        v_tax_amt := 0;
        ln_tax_amt_nr := 0;
        ln_vamt_nr := 0;
      ELSE /*bug 9674771 - populate base_tax_amount_nr_tab for zero rate taxes also*/
        base_tax_amount_nr_tab(I) := 0;
      END IF; --IF tax_rate_tab(I) <> 0
    ELSE --IF end_date_tab(I) <> 0 THEN
      tax_amt_tab(I) := 0;
      base_tax_amt_tab(I) := 0;
      base_tax_amount_nr_tab(I):=0; /*Bug 9382657*/
    END IF; --IF end_date_tab(I) <> 0 THEN
  END LOOP;
  ----------------------------------------------------
  --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
  /*FOR I in 1..row_count LOOP
  IF tax_rate_tab(I) <> 0 THEN
    IF p1(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
    END IF;
    IF p2(I) > I  THEN
      vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
    END IF;
    IF p3(I) > I  THEN
      vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
    END IF;
    IF p4(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
    END IF;
    IF p5(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
    END IF;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    IF p6(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
    END IF;
    IF p7(I) > I  THEN
      vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
    END IF;
    IF p8(I) > I  THEN
      vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
    END IF;
IF p9(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
    END IF;
    IF p10(I) > I THEN
      vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
    END IF;

-- END BUG 5228046


    v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
    IF vamt <> 0 THEN
       base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
    END IF;
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;

    vamt := 0;
    v_tax_amt := 0;

  END IF;
  END LOOP;*/
  --Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ---------------------------------------------------
  FOR I in 1..row_count LOOP
    IF end_date_tab( I ) <> 0
    THEN
      IF tax_rate_tab(I) <> 0 THEN
        IF p1(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p1(I)),0); -- tax inclusive
        END IF;
        IF p2(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p2(I)),0); -- tax inclusive
        END IF;
        IF p3(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p3(I)),0); -- tax inclusive
        END IF;
        IF p4(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p4(I)),0); -- tax inclusive
        END IF;
        IF p5(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p5(I)),0); -- tax inclusive
        END IF;

    -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046
        IF p6(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p6(I)),0); -- tax inclusive
        END IF;
        IF p7(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p7(I)),0); -- tax inclusive
        END IF;
        IF p8(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p8(I)),0); -- tax inclusive
        END IF;
        IF p9(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p9(I)),0); -- tax inclusive
        END IF;
        IF p10(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p10(I)),0); -- tax inclusive
        END IF;

    -- END BUG 5228046
        base_tax_amt_tab(I) := vamt;
        base_tax_amount_nr_tab(I):=ln_vamt_nr; /*9382657*/
        v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100)); -- tax inclusive
        IF vamt <> 0 THEN
           base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
        END IF;
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr ; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) :=  tax_amt_tab(I);

        vamt := 0;
        v_tax_amt := 0;
        ln_vamt_nr := 0 ;
        ln_tax_amt_nr := 0 ;
      END IF;
    ELSE --IF end_date_tab( I ) <> 0 THEN
      base_tax_amt_tab(I) := vamt;
      base_tax_amount_nr_tab(I):=ln_vamt_nr; /*9382657*/
      tax_amt_tab(I) := 0;
    END IF; --IF end_date_tab( I ) <> 0 THEN
  END LOOP;
  ---------------------------------------------------

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;
    ln_vamt_nr := 0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    ln_tax_amt_nr:=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007

    FOR i IN 1 .. row_count LOOP

      /*Commented by aiyer for the bug 4691616
              IF tax_rate_tab( i ) <> 0 THEN
      */

      /*
      || start of bug bug#4691616
      || IF statement modified by Aiyer for bug#4691616
      */

      IF ( tax_rate_tab( i ) <> 0  OR  tax_rate_zero_tab(I) = -9999 ) AND
           end_date_tab( I ) <> 0
      THEN
        /*
        || End of bug 4691616
        */
        IF tax_type_tab( I ) = 1 THEN
           --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
          /*v_amt := p_assessable_value;*/
          --Added by Kevin Cheng for inclusive tax Dec 10, 2007
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
        ELSIF tax_type_tab( I ) = 4 THEN
          --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
          /*v_amt := p_vat_assessable_value;*/
          --Added by Kevin Cheng for inclusive tax Dec 10, 2007
          ------------------------------------------------
          IF ln_vat_assessable_value =1
          THEN
            v_amt:=1;
            ln_bsln_amt_nr :=0;
          ELSE
            v_amt :=0;
            ln_bsln_amt_nr :=ln_vat_assessable_value;
          END IF;
          ------------------------------------------------
         ELSIF tax_type_tab( I ) = 5 THEN       /*Bug#6072461, bduvarag*/
              --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
              /*v_amt := p_vat_reversal_price;*/
        --Added by Kevin Cheng for inclusive tax Dec 10, 2007
        -------------------------------------
          IF ln_vat_reversal_price =1
          THEN
            v_amt:=1;
            ln_bsln_amt_nr :=0;
          ELSE
            v_amt :=0;
            ln_bsln_amt_nr :=ln_vat_reversal_price;
          END IF;
        ELSIF tax_type_tab(I) = 6 THEN
            v_amt:=0;
            ln_bsln_amt_nr :=0;
        -------------------------------------
        ELSE
          IF p_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
            /*v_amt := p_tax_amount;*/--Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
            v_amt:=1;                --Added by Kevin Cheng for inclusive tax Dec 10, 2007
            ln_bsln_amt_nr :=0;      --Added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p_vat_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 4 THEN
            /*v_amt := p_tax_amount;*/--Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
            v_amt:=1;                --Added by Kevin Cheng for inclusive tax Dec 10, 2007
            ln_bsln_amt_nr :=0;      --Added by Kevin Cheng for inclusive tax Dec 10, 2007
            ELSIF p_vat_reversal_price IN ( 0, -1 ) OR tax_type_tab( I ) <> 5 THEN /*Bug#6072461, bduvarag*/
               /*v_amt := p_tax_amount; */--Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
               v_amt:=1;                --Added by Kevin Cheng for inclusive tax Dec 10, 2007
               ln_bsln_amt_nr :=0;      --Added by Kevin Cheng for inclusive tax Dec 10, 2007

          END IF;
        END IF;

        IF p1( i ) <> -1 THEN
          IF p1( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p1( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p1(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p2( i ) <> -1 THEN
          IF p2( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p2( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p2(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p3( i ) <> -1 THEN
          IF p3( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p3( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p3(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p4( i ) <> -1 THEN
          IF p4( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p4( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p4(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

       IF p5( i ) <> -1 THEN
         IF p5( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p5( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
         ELSIF p5(i) = 0 THEN
           vamt := vamt + v_amt;
           ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
         END IF;
       END IF;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

       IF p6( i ) <> -1 THEN
          IF p6( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p6( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p6(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p7( i ) <> -1 THEN
          IF p7( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p7( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p7(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p8( i ) <> -1 THEN
          IF p8( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p8( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p8(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

        IF p9( i ) <> -1 THEN
          IF p9( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p9( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
          ELSIF p9(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
          END IF;
        END IF;

       IF p10( i ) <> -1 THEN
         IF p10( i ) <> 0 THEN
           vamt := vamt + tax_amt_tab( p10( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --added by Kevin Cheng for inclusive tax Dec 10, 2007
         ELSIF p10(i) = 0 THEN
           vamt := vamt + v_amt;
           ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 10, 2007
         END IF;
       END IF;

-- END BUG 5228046








       /*
       ||Added by aiyer for the bug 4691616
       ||added calculation for base_tax_amt and also changed the else to elsif
       */
       base_tax_amt_tab(I) := ROUND(vamt, rounding_factor_tab(I) );
       base_tax_amount_nr_tab(I):=ROUND(ln_vamt_nr, rounding_factor_tab(I) ); /*9382657*/
       -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
       ----------------------------------------------------
        lt_tax_target_tab(I) := vamt;
        ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100));
        ln_func_tax_amt := v_tax_amt +  ( vamt * ( tax_rate_tab( i )/100));
       ----------------------------------------------------
       v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));


     ELSIF tax_rate_tab(I) = 0 THEN
        /*
        || tax_rate_tab(i) will be zero when tax_rate of such a line is null.
        || i.e It is UOM based calculation. base_Tax_amount will be same as tax_amount
        */
        base_tax_amt_tab(I) := tax_amt_tab(i);
        v_tax_amt           := tax_amt_tab( i );
        ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i);  --Add by Kevin Cheng for inclusive tax Jan 08, 2008
        lt_tax_target_tab(I):= v_tax_amt; --Add by Kevin Cheng for inclusive tax Dec 10, 2007
        /*
        ||End of bug 4691616
        */
     --Add by Kevin Cheng for inclusive tax Dec 10, 2007
     ---------------------------------------------------
     ELSIF end_date_tab( I ) = 0 THEN
        tax_amt_tab(I) := 0;
        base_tax_amt_tab(I) := 0;
        base_tax_amount_nr_tab(I):=0; /*9382657*/
        lt_tax_target_tab(I) := 0;
     ---------------------------------------------------
     END IF;
      --Comment out by Kevin Cheng for inclusive tax Dec 10, 2007
      /*tax_amt_tab( I ) := NVL( v_tax_amt, 0 );

      IF counter = max_iter THEN
        tax_amt_tab( I ) := ROUND( tax_amt_tab( I ), rounding_factor_tab(I) );
      END IF;

      IF end_date_tab(I) = 0 THEN
        tax_amt_tab( i ) := 0;
        base_tax_amt_tab(i) := 0;
      END IF;*/

      --Add by Kevin Cheng for inclusive tax Dec 10, 2007
      ---------------------------------------------------
      tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      lt_tax_amt_rate_tax_tab(i) :=  tax_amt_tab(I);
      lt_tax_amt_non_rate_tab(I):=ln_tax_amt_nr;
      lt_func_tax_amt_tab(I) := NVL(ln_func_tax_amt,0);
      IF counter = max_iter THEN
        IF end_date_tab(I) = 0 THEN
          tax_amt_tab( i ) := 0;
          lt_func_tax_amt_tab(i) := 0;
        END IF;
      END IF;
      ---------------------------------------------------

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
      ln_func_tax_amt := 0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
      ln_vamt_nr :=0; -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
      ln_tax_amt_nr:=0;-- Add by Kevin Cheng for inclusive tax Dec 10, 2007
    END LOOP;
  END LOOP;

  --Added by Kevin Cheng for inclusive tax Dec 10, 2007
  ---------------------------------------------------------------------------------------
  FOR I IN 1 .. ROW_COUNT
  LOOP
    IF lt_inclu_tax_tab(I) = 'Y' THEN
      ln_total_tax_per_rupee := ln_total_tax_per_rupee + nvl(lt_tax_amt_rate_tax_tab(I),0) ;
      ln_total_non_rate_tax := ln_total_non_rate_tax + nvl(lt_tax_amt_non_rate_tab(I),0);
    END IF;
  END LOOP;

  ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

  IF ln_total_tax_per_rupee <> 0 THEN
     ln_exclusive_price := (NVL(p_tax_amount,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
  END If;

  FOR i in 1 .. row_count
  LOOP
    tax_amt_tab(i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
    tax_amt_tab(I) := round(tax_amt_tab(I)  ,rounding_factor_tab(I));
    /*Bug 9382657 - Multiply Line Amount with the Rate of the precedences*/
    base_tax_amt_tab(I):= ln_exclusive_price * base_tax_amt_tab(I) + base_tax_amount_nr_tab(I);
  END LOOP;
  --------------------------------------------------------------------------------------------------------

  if NVL(v_rma_ctr,0) = 0 then -- added by sriram - bug #  2740443

   FOR rec in  tax_cur(p_header_id, p_line_id) LOOP
     IF tax_type_tab(rec.lno) <> 2
     THEN
       IF NVL(rec.inclusive_tax_flag,'N') = 'N' THEN -- Added by Jia for bug# 6846048
         v_tax_amt := v_tax_amt + nvl(tax_amt_tab(rec.lno),0);
       END IF;   -- Added by Jia for bug# 6846048
     END IF;

     IF transaction_name = 'OE_LINES_UPDATE'
     THEN
             UPDATE  JAI_OM_OE_SO_TAXES
             SET  tax_amount = nvl(tax_amt_tab(rec.lno),0),
                base_tax_amount   = decode(nvl(base_tax_amt_tab(rec.lno), 0), 0, nvl(tax_amt_tab(rec.lno),0), nvl(base_tax_amt_tab(rec.lno), 0)),
                func_tax_amount   = ROUND(nvl(tax_amt_tab(rec.lno),0) *  v_currency_conv_factor, rounding_factor_tab(rec.lno) ),
                last_update_date  = p_last_update_date,
                last_updated_by   = p_last_updated_by,
                last_update_login = p_last_update_login
             WHERE  line_id = P_line_id
       AND  header_id = p_header_id
             AND  tax_line_no = rec.lno;
     END IF;
   END LOOP;
 elsif   v_rma_ctr = 1 then
    -- added by sriram -following from elsif to end if  bug # 2740443
    FOR rec in  c_rma_tax_cur(p_line_id) LOOP
      IF tax_type_tab(rec.lno) <> 2
      THEN
        v_tax_amt := v_tax_amt + nvl(tax_amt_tab(rec.lno),0);
      END IF;

      IF transaction_name = 'OE_LINES_UPDATE'
      THEN

  UPDATE  JAI_OM_OE_RMA_TAXES
        SET          tax_amount = nvl(tax_amt_tab(rec.lno),0),
                     base_tax_amount   = decode(nvl(base_tax_amt_tab(rec.lno), 0), 0, nvl(tax_amt_tab(rec.lno),0), nvl(base_tax_amt_tab(rec.lno), 0)),
                     func_tax_amount   = ROUND(nvl(tax_amt_tab(rec.lno),0) *  v_currency_conv_factor, rounding_factor_tab(rec.lno) ),
                     last_update_date  = p_last_update_date,
                     last_updated_by   = p_last_updated_by,
                     last_update_login = p_last_update_login
        WHERE rma_line_id = P_line_id
        AND tax_line_no = rec.lno;
      END IF;
   END LOOP;
 end if; -- ends here additions by sriram - bug # 2740443

   P_TAX_AMOUNT := nvl(v_tax_amt,0);

EXCEPTION
  WHEN OTHERS THEN
  p_tax_amount := null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END calculate_ato_taxes;


procedure recalculate_oe_taxes(
  p_header_id     IN NUMBER,
  p_line_id     IN NUMBER,
  p_assessable_value  IN NUMBER DEFAULT 0,
  p_vat_assess_value      IN NUMBER,
  p_tax_amount    IN OUT NOCOPY NUMBER,
  p_inventory_item_id IN NUMBER,
  p_line_quantity   IN NUMBER,
  p_uom_code      IN VARCHAR2,
  p_currency_conv_factor IN NUMBER,
  p_last_updated_date IN DATE,
  p_last_updated_by   IN NUMBER,
  p_last_update_login IN NUMBER
) IS

-- P_TAX_AMOUNT input parameter will contain the line_tax_amount after successful completion of the procedure which
-- can be used to update the line amount in JAI_OM_OE_SO_LINES

  TYPE num_tab IS TABLE OF NUMBER(20,3) INDEX BY BINARY_INTEGER;
  TYPE tax_amt_num_tab IS TABLE OF NUMBER(20,3) INDEX BY BINARY_INTEGER;

  --Add by Kevin Cheng for inclusive tax Dec 10, 2007
  ---------------------------------------------------
  TYPE CHAR_TAB IS TABLE OF VARCHAR2(10)
  INDEX BY BINARY_INTEGER;

  lt_adhoc_tax_tab             CHAR_TAB;
  lt_inclu_tax_tab             CHAR_TAB;
  lt_tax_rate_per_rupee        NUM_TAB;
  lt_cumul_tax_rate_per_rupee  NUM_TAB;
  lt_tax_rate_zero_tab         NUM_TAB;
  lt_round_factor_tab          NUM_TAB;
  lt_tax_amt_rate_tax_tab      TAX_AMT_NUM_TAB;
  lt_tax_amt_non_rate_tab      TAX_AMT_NUM_TAB;
  lv_register_code             VARCHAR2(20);
  ln_exclusive_price           NUMBER;
  ln_total_non_rate_tax        NUMBER := 0;
  ln_total_inclusive_factor    NUMBER;
  ln_bsln_amt_nr               NUMBER := 0;
  ln_currency_conv_factor      NUMBER;
  ln_tax_amt_nr                NUMBER(38,10) := 0;
  ln_vamt_nr                   NUMBER(38,10) := 0;
  ln_excise_jb                 NUMBER;
  ln_total_tax_per_rupee       NUMBER;
  ln_assessable_value          NUMBER;
  ln_vat_assessable_value      NUMBER;
  ---------------------------------------------------

  p1 NUM_TAB;
  p2 NUM_TAB;
  p3 NUM_TAB;
  p4 NUM_TAB;
  p5 NUM_TAB;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6 NUM_TAB;
  p7 NUM_TAB;
  p8 NUM_TAB;
  p9 NUM_TAB;
  p10 NUM_TAB;

-- END BUG 5228046


  tax_rate_tab    NUM_TAB;
  tax_type_tab    NUM_TAB;
  tax_target_tab    NUM_TAB;
  tax_amt_tab     TAX_AMT_NUM_TAB;
  base_tax_amt_tab  TAX_AMT_NUM_TAB;
  base_tax_amount_nr_tab tax_amt_num_tab; /*Bug 9382657*/
  func_tax_amt_tab  TAX_AMT_NUM_TAB;
  end_date_tab    NUM_TAB;

  bsln_amt      NUMBER; --  := p_tax_amount;   --Ramananda for File.Sql.35
  v_conversion_rate NUMBER := 0;
  v_tax_amt     NUMBER(20,3) := 0;
  v_func_tax_amt    NUMBER(20,3) := 0;
  v_rounded_tax   NUMBER(20,3) := 0;
  vamt        NUMBER(20,3) :=0;
  v_amt       NUMBER;
  row_count     NUMBER := 1;
  counter       NUMBER;
  max_iter      NUMBER := 10;

        /* Added by LGOPALSa. Bug 4210102.
   * Added Excise education cess in cursor */

   /*Added VAT regime in cursor by Ravi for bug#4245365*/
   --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
  /*CURSOR c_tax_lines(p_header_id IN NUMBER, p_line_id IN NUMBER) IS
    SELECT a.tax_id, a.tax_line_no lno,
      a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3,a.precedence_4 p_4, a.precedence_5 p_5,
      a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8,a.precedence_9 p_9, a.precedence_10 p_10, -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
      b.tax_amount, b.tax_rate, b.uom_code, b.end_date valid_date,
      a.tax_amount tax_line_amt,
      DECODE(aa.regime_code,'VAT',4, decode(upper(b.tax_type),
                                                     'EXCISE', 1,
                                               'ADDL. EXCISE', 1,
                                               'OTHER EXCISE', 1,
                          JAI_CONSTANTS.TAX_TYPE_SH_EXC_EDU_CESS,1,jai_constants.tax_type_exc_edu_Cess,1,  \*Bug 5989740 bduvarag*\
                                                        'TDS', 2, 0)) tax_type_val,
      b.tax_type,nvl(b.rounding_factor,0) rounding_factor
    FROM JAI_OM_OE_SO_TAXES a, JAI_CMN_TAXES_ALL b,jai_regime_tax_types_v aa
    WHERE a.header_id = p_header_id
    AND a.line_id = p_line_id
    AND a.tax_id = b.tax_id
    AND aa.tax_type(+) = b.tax_type
    ORDER BY a.tax_line_no;*/

  -- Add by Kevin Cheng for inclusive tax Dec 10, 2007
  CURSOR c_tax_lines( p_header_id IN NUMBER
                    , p_line_id   IN NUMBER
                    )
  IS
  SELECT
    a.tax_id
  , a.tax_category_id
  , a.tax_line_no lno
  , a.precedence_1 p_1
  , a.precedence_2 p_2
  , a.precedence_3 p_3
  , a.precedence_4 p_4
  , a.precedence_5 p_5
  , a.precedence_6 p_6
  , a.precedence_7 p_7
  , a.precedence_8 p_8
  , a.precedence_9 p_9
  , a.precedence_10 p_10 -- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
  , b.tax_amount
  , b.tax_rate
  , b.uom_code
  , b.end_date valid_date
  , a.tax_amount tax_line_amt
  , DECODE( aa.regime_code
          , JAI_CONSTANTS.VAT_REGIME
          , 4
          , decode( upper(b.tax_type)
                  , 'EXCISE'                    ,1
                  , 'ADDL. EXCISE'              ,1
                  , 'OTHER EXCISE'              ,1
                  , jai_constants.tax_type_tds                ,2
                  , jai_constants.tax_type_exc_edu_cess       ,6
                  , jai_constants.tax_type_cvd_edu_cess       ,6
                  , jai_constants.tax_type_sh_exc_edu_cess    ,6
                  , jai_constants.tax_type_sh_cvd_edu_cess    ,6
                  , 0
                  )
          ) tax_type_val
  , b.inclusive_tax_flag
  , b.mod_cr_percentage
  , b.vendor_id
  , b.tax_type
  , nvl(b.rounding_factor,0) rounding_factor
  FROM
    Jai_Om_Oe_So_Taxes       a
  , Jai_Cmn_Taxes_All        b
  , Jai_Regime_Tax_Types_V   aa
  WHERE a.header_id = p_header_id
    AND a.line_id = p_line_id
    AND a.tax_id = b.tax_id
    AND aa.tax_type(+) = b.tax_type
  ORDER BY
    a.tax_line_no;

  CURSOR c_uom_class(p_line_uom_code IN VARCHAR2, p_tax_line_uom_code IN VARCHAR2) IS
    SELECT A.uom_class
    FROM mtl_units_of_measure A, mtl_units_of_measure B
    WHERE A.uom_code = p_line_uom_code
    AND B.uom_code = p_tax_line_uom_code
    AND A.uom_class = B.uom_class;

  -- Start of bug 3565499
  /*****************
  Code modified by aiyer for the bug 3565499
  Check whether the excise exemptions exist at the order line level.
  *****************/
    CURSOR c_excise_exemption
  IS
  SELECT
      '1'
  FROM
      JAI_OM_OE_SO_LINES     jsl
    WHERE
      jsl.excise_exempt_type  IS NOT NULL AND
      jsl.line_id       = p_line_id  ;

    lv_excise_exemption_exists VARCHAR2(1);

    -- End of bug 3565499
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_tax_pkg.recalculate_oe_taxes';
BEGIN
/*-------------------------------------------------------------------------------------------------------------------------
S.No  Date(DD/MM/YY)  Author and Details of Changes
----  --------------  -----------------------------
1   31/07/02      Created by Vijay Shankar for Bug# 2485077, 2496481, File Version 615.1
            This procedure recalculates the taxes by picking tax lines attached to the sales order line.
            If the assessable value of an item is changed, then the excise duty attached to the sales orders
            have to be recalculated if they have order lines having assessable value changed. Sales order which
            are not ship confirmed( also partially shipped if user specified input says 'Partially Shipped' as 'Y'

3.    20-Feb-2004      Aiyer For the Bug #3565499 File Version 619.1
                       Issue:-
                        India Excise Duty Recalculation Concurrent program recalculates the excise duty even for excise exempted Order Lines.
                      Fix:-
              Code has been added to set the tax_rate, tax_amount and base_tax_amount to 0 when Order Like has Excise exemptions and tax is of "Excise" type.
            The cursor c_excise_exemption has been added for the purpose.

4.   12-Mar-2005     Bug 4210102. Added by LGOPALSA  version 115.1
                     (1) Added check file syntax
         (2) Added NOCOPY for OUT Parameters
         (3) Added <> instead of !=
         (4) Added Excise education cess type

5.   17/mar-2005  Rchandan for bug#4245365   Version 115.2
                  Changes made to calculate VAT taxes taking the VAT assessable value as base
                  New parameter is added for having vat assesable value.

6.   11-Dec-2007  Kevin Cheng   Update the logic for inclusive tax calculation
===============================================================================
Dependencies

Version    Dependencies          Comments
115.1       IN60106 + 4146708   Service and eduation cess functionality
115.2       4245089              VAT implementation
--------------------------------------------------------------------------------------------------------------------------*/

  bsln_amt      := p_tax_amount;   --Ramananda for File.Sql.35

  -- Start of bug 3565499
  /*****************
  Code modified by aiyer for the bug 3565499
  *****************/
  OPEN  c_excise_exemption;
  FETCH c_excise_exemption INTO lv_excise_exemption_exists;
  -- End of bug 3565499
  FOR rec in c_tax_lines(p_header_id, p_line_id) LOOP

    p1(rec.lno) := nvl(rec.p_1,-1);
    p2(rec.lno) := nvl(rec.p_2,-1);
    p3(rec.lno) := nvl(rec.p_3,-1);
    p4(rec.lno) := nvl(rec.p_4,-1);
    p5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

    p6(rec.lno) := nvl(rec.p_6,-1);
    p7(rec.lno) := nvl(rec.p_7,-1);
    p8(rec.lno) := nvl(rec.p_8,-1);
    p9(rec.lno) := nvl(rec.p_9,-1);
    p10(rec.lno) := nvl(rec.p_10,-1);

-- END BUG 5228046

    tax_rate_tab(rec.lno) := nvl(rec.tax_rate,0);
    tax_type_tab(rec.lno) := rec.tax_type_val;
    tax_amt_tab(rec.lno) := 0;
    base_tax_amt_tab(rec.lno) := 0;

    --Add by Kevin Cheng for inclusive tax Dec 11, 2007
    ---------------------------------------------------
    lt_tax_rate_per_rupee(rec.lno)  := NVL(rec.tax_rate,0)/100;
    ln_total_tax_per_rupee          := 0;
    lt_inclu_tax_tab(rec.lno)       := NVL(rec.inclusive_tax_flag,'N');
    lt_round_factor_tab(rec.lno)    := NVL(rec.rounding_factor,0);

    IF rec.tax_rate is null THEN
      lt_tax_rate_zero_tab(rec.lno) := 0;
    ELSIF rec.tax_rate = 0 THEN
      lt_tax_rate_zero_tab(rec.lno) := -9999;
    ELSE
      lt_tax_rate_zero_tab(rec.lno) := rec.tax_rate;
    END IF;

    lt_tax_amt_rate_tax_tab(rec.lno) := 0;
    lt_tax_amt_non_rate_tab(rec.lno) := 0; -- tax inclusive
    ---------------------------------------------------

    IF tax_rate_tab(rec.lno) = 0 THEN
      FOR uom_cls IN c_uom_class(p_uom_code, rec.uom_code) LOOP
        INV_CONVERT.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
        IF nvl(v_conversion_rate, 0) <= 0 THEN
          INV_CONVERT.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN
            v_conversion_rate := 0;
          END IF;
        END IF;

        --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
        /*tax_amt_tab(rec.lno) := (nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity);*/
        --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        lt_tax_amt_non_rate_tab(rec.lno) := (nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity);

        --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
        /*base_tax_amt_tab(rec.lno) := tax_amt_tab(rec.lno);*/
        --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        base_tax_amt_tab(rec.lno) := lt_tax_amt_non_rate_tab(rec.lno);
      END LOOP;

      --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
      /*IF tax_amt_tab(rec.lno) = 0 THEN -- this means user has given some adhoc amount
        tax_amt_tab(rec.lno) := nvl(rec.tax_line_amt,0);
      END IF;*/
      --Add by Kevin Cheng for inclusive tax Dec 11, 2007
      IF lt_tax_amt_non_rate_tab(rec.lno) = 0 THEN -- this means user has given some adhoc amount
        lt_tax_amt_non_rate_tab(rec.lno) := nvl(rec.tax_line_amt,0);
      END IF;
    END IF;

    IF rec.valid_date is NULL or rec.valid_date >= sysdate THEN
      end_date_tab(rec.lno) := 1;
    ELSE
      tax_amt_tab(rec.lno):= 0;
      end_date_tab(rec.lno) := 0;
    END IF;

    -- Start of bug 3565499
    /*****************
    Code modified by aiyer for the bug 3565499
    IF the line is excise exempted and the tax is of type Excise then set the tax_rate, tax_amount and base_tax_amount
    to zero.
    *****************/
    IF c_excise_exemption%FOUND  AND
       rec.tax_type_val = 1
    THEN
          /* Set tax_rate_tab = 0, tax_amt_tab = 0 and base_tax_amt_tab = 0 */
          tax_rate_tab(rec.lno)   := 0;
          tax_amt_tab(rec.lno)    := 0;
          base_tax_amt_tab(rec.lno) := 0;
          lt_tax_amt_non_rate_tab(rec.lno) :=0; -- Add by Kevin Cheng for inclusive tax Dec 11, 2007
    END IF;
    -- End of bug 3565499
    row_count := row_count + 1;
  END LOOP;
  -- Start of bug 3565499
    CLOSE c_excise_exemption ;
  -- End of bug 3565499

  row_count := row_count - 1;

  --added by Kevin Cheng for inclusive tax Dec 11, 2007
  -------------------------------------------------
  IF p_vat_assess_value <> p_tax_amount
  THEN
    ln_vat_assessable_value := p_vat_assess_value;
  ELSE
    ln_vat_assessable_value := 1;
  END IF;

  IF p_assessable_value <> p_tax_amount
  THEN
    ln_assessable_value := p_assessable_value;
  ELSE
    ln_assessable_value := 1;
  END IF;
  ---------------------------------------------------

  FOR I in 1..row_count LOOP
    IF end_date_tab(I) <> 0 THEN
      IF tax_type_tab(I) = 1 THEN
         /*bsln_amt := p_assessable_value;*/--Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
        --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ---------------------------------------------------
        IF ln_assessable_value = 1 THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_assessable_value;
        END IF;
        ---------------------------------------------------
      ELSIF tax_type_tab(I) = 4 THEN  --4245365
         /*bsln_amt := p_vat_assess_value;*/--Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
         --Add by Kevin Cheng for inclusive tax Dec 11, 2007
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
        ---------------------------------------------------
      --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
      /*ELSE
        bsln_amt := p_tax_amount;*/
      END IF;
      IF tax_rate_tab(I) <> 0 THEN

  IF p1(I) < I and p1(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p1(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p2(I) < I and p2(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p2(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p3(I) < I and p3(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p3(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p4(I) < I and p4(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p4(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p5(I) < I and p5(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p5(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  IF p6(I) < I and p6(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p6(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

  IF p7(I) < I and p7(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p7(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

  IF p8(I) < I and p8(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p8(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

  IF p9(I) < I and p9(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p9(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

  IF p10(I) < I and p10(I) not in (-1,0) THEN
          vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr  := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ELSIF p10(I) = 0 THEN
          vamt := vamt + bsln_amt;
          ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

-- END BUG 5228046

        v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
        base_tax_amt_tab(I) := vamt;
        base_tax_amount_nr_tab(I) := ln_vamt_nr; /*9382657*/
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;

        --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ---------------------------------------------------
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) := tax_amt_tab(I);
        ln_tax_amt_nr := 0;
        ln_vamt_nr := 0;
        ---------------------------------------------------

        vamt := 0;
        v_tax_amt := 0;
      END IF;
    ELSE
      tax_amt_tab(I) := 0;
      base_tax_amt_tab(I) := 0;
      base_tax_amount_nr_tab(I) := 0; /*9382657*/
    END IF;
--dbms_output.put_line( '2 tax_amt_tab('||i||') = '||tax_amt_tab(i)
--  ||', base_tax_amt_tab = '||base_tax_amt_tab(i) );
  END LOOP;

  FOR I in 1..row_count LOOP
    IF end_date_tab( I ) <> 0 THEN
      IF tax_rate_tab(I) <> 0 THEN
        IF p1(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p1(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p2(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p2(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p3(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p3(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p4(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p4(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p5(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p5(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;


-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  IF p6(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p6(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p7(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p7(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p8(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p8(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p9(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p9(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;
        IF p10(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(lt_tax_amt_non_rate_tab(p10(I)),0); --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        END IF;

-- END BUG 5228046


  base_tax_amt_tab(I) := vamt;
  base_tax_amount_nr_tab(I) := ln_vamt_nr; /*9382657*/
        v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
        IF vamt <> 0 THEN
          base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
        END IF;
        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        --Add by Kevin Cheng for inclusive tax Dec 11, 2007
        ---------------------------------------------------
        ln_tax_amt_nr := ln_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100)); -- tax inclusive
        lt_tax_amt_non_rate_tab(I) := NVL(lt_tax_amt_non_rate_tab(I),0) + ln_tax_amt_nr ; -- tax inclusive
        lt_tax_amt_rate_tax_tab(i) :=  tax_amt_tab(I);
        ln_vamt_nr := 0;
        ln_tax_amt_nr := 0;
        ---------------------------------------------------
        vamt := 0;
        v_tax_amt := 0;
      END IF;
    ELSE
      base_tax_amt_tab(I) := vamt;
      base_tax_amount_nr_tab(I) := ln_vamt_nr; /*9382657*/
      tax_amt_tab(I) := 0;
    END IF;
--dbms_output.put_line( '3 tax_amt_tab('||i||') = '||tax_amt_tab(i)
--  ||', base_tax_amt_tab = '||base_tax_amt_tab(i) );
  END LOOP;

  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    v_tax_amt := 0;
    ln_vamt_nr:= 0;   --added by Kevin Cheng for inclusive tax Dec 11, 2007
    ln_tax_amt_nr:=0; --added by Kevin Cheng for inclusive tax Dec 11, 2007

    FOR i IN 1 .. row_count LOOP
      IF tax_rate_tab( i ) <> 0 AND end_date_tab( I ) <> 0 THEN -- modified on 11-10-2k by anuradha.
        IF tax_type_tab( I ) = 1 THEN
          --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
           /*v_amt := p_assessable_value;*/
          --Added by Kevin Cheng for inclusive tax Dec 11, 2007
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
        ELSIF tax_type_tab(I) = 4 THEN
          --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
           /*v_amt := p_vat_assess_value;*/
          --Added by Kevin Cheng for inclusive tax Dec 11, 2007
          ------------------------------------------------
          IF ln_vat_assessable_value =1
          THEN
            v_amt:= 1;
            ln_bsln_amt_nr := 0;
          ELSE
            v_amt := 0;
            ln_bsln_amt_nr := ln_vat_assessable_value;
          END IF;
        ELSIF tax_type_tab(I) = 6 THEN
          v_amt := 0;
          ln_bsln_amt_nr := 0;
          ------------------------------------------------
        ELSE
          IF p_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
            --Comment out by Kevin Cheng for inclusive tax Dec 11, 2007
            /*v_amt := p_tax_amount;*/
            v_amt:=1;                --Added by Kevin Cheng for inclusive tax Dec 11, 2007
            ln_bsln_amt_nr :=0;      --Added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p1( i ) <> -1 THEN
          IF p1( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p1( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P1(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p1(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p2( i ) <> -1 THEN
          IF p2( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p2( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P2(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p2(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p3( i ) <> -1 THEN
          IF p3( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p3( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P3(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p3(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p4( i ) <> -1 THEN
          IF p4( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p4( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P4(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p4(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p5( i ) <> -1 THEN
          IF p5( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p5( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P5(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p5(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;


-- Date 01/11/2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

        IF p6( i ) <> -1 THEN
          IF p6( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p6( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P6(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p6(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p7( i ) <> -1 THEN
          IF p7( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p7( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P7(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p7(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p8( i ) <> -1 THEN
          IF p8( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p8( I ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P8(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p8(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p9( i ) <> -1 THEN
          IF p9( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p9( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P9(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p9(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;
        IF p10( i ) <> -1 THEN
          IF p10( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p10( i ) );
            ln_vamt_nr:=ln_vamt_nr+NVL(lt_tax_amt_non_rate_tab(P10(I)),0); --added by Kevin Cheng for inclusive tax Dec 11, 2007
          ELSIF p10(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr:=ln_vamt_nr+ln_bsln_amt_nr; --added by Kevin Cheng for inclusive tax Dec 11, 2007
          END IF;
        END IF;

-- END BUG 5228046

  base_tax_amt_tab(I) := vamt;
  base_tax_amount_nr_tab(I) := ln_vamt_nr; /*9382657*/
        tax_target_tab(I) := vamt;

        v_func_tax_amt := v_tax_amt +( vamt * ( tax_rate_tab( i )/100));
        v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
        ln_tax_amt_nr:=ln_tax_amt_nr+(ln_vamt_nr*(tax_rate_tab(i)/100));--Add by Kevin Cheng for inclusive tax Jan 08, 2008

      ELSIF tax_rate_tab(I) = 0 THEN
        base_tax_amt_tab(I) := tax_amt_tab(i);
        v_tax_amt := tax_amt_tab( i );
        ln_tax_amt_nr:=lt_tax_amt_non_rate_tab(i); --Add by Kevin Cheng for inclusive tax Jan 08, 2008
        tax_target_tab(I) := v_tax_amt;
      ELSIF end_date_tab( I ) = 0 THEN
        tax_amt_tab(I) := 0;
        base_tax_amt_tab(I) := 0;
        base_tax_amount_nr_tab(I) := 0; /*9382657*/
        tax_target_tab(I) := 0;
      END IF;

      tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      lt_tax_amt_non_rate_tab(I):=ln_tax_amt_nr; --Add by Kevin Cheng for inclusive tax Jan 08, 2008
      func_tax_amt_tab(I) := NVL(v_func_tax_amt,0);
      IF counter = max_iter THEN
        IF end_date_tab(I) = 0 THEN
          tax_amt_tab( i ) := 0;
          func_tax_amt_tab(i) := 0;
        END IF;
      END IF;
  --dbms_output.put_line( '4 tax_amt_tab('||i||') = '||tax_amt_tab(i)
    --||', func_tax_amt_tab = '||func_tax_amt_tab(i)
    --||', base_tax_amt_tab = '||base_tax_amt_tab(i) );

      lt_tax_amt_rate_tax_tab(i) :=  tax_amt_tab(I); --Add by Kevin Cheng for inclusive tax Dec 11, 2007

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
      v_func_tax_amt := 0;
      ln_vamt_nr :=0;    --added by Kevin Cheng for inclusive tax Dec 11, 2007
      ln_tax_amt_nr:=0;  --added by Kevin Cheng for inclusive tax Dec 11, 2007
    END LOOP;
  END LOOP;

  --Added by Kevin Cheng for inclusive tax Dec 11, 2007
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
    ln_exclusive_price := (NVL(p_tax_amount,0)  -  ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
  END IF;

  FOR i in 1 .. row_count
  LOOP
     tax_amt_tab (i) := (lt_tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + lt_tax_amt_non_rate_tab(I);
     tax_amt_tab(I) :=  round(tax_amt_tab(I)  ,lt_round_factor_tab(I));
     /*Bug 9382657 - Multiply Line Amount with the Rate of the precedences*/
     base_tax_amt_tab(I):= ln_exclusive_price * base_tax_amt_tab(I) + base_tax_amount_nr_tab(I); /*Bug 9382657*/
  END LOOP; --FOR i in 1 .. row_count
  --------------------------------------------------------------------------------------------------------

  FOR rec in c_tax_lines(p_header_id, p_line_id) LOOP
    v_rounded_tax := ROUND(nvl(tax_amt_tab(rec.lno),0), rec.rounding_factor);
    IF tax_type_tab(rec.lno) <> 2 THEN
      v_tax_amt := v_tax_amt + v_rounded_tax;
    END IF;
--dbms_output.put_line( '5 tax_amt_tab('||rec.lno||') = '||tax_amt_tab(rec.lno)
--  ||', func_tax_amt_tab = '||func_tax_amt_tab(rec.lno)
--  ||', base_tax_amt_tab = '||base_tax_amt_tab(rec.lno) );

    UPDATE JAI_OM_OE_SO_TAXES
       SET tax_amount = v_rounded_tax,
           base_tax_amount = decode(nvl(base_tax_amt_tab(rec.lno), 0), 0, nvl(tax_amt_tab(rec.lno),0), nvl(base_tax_amt_tab(rec.lno), 0)),
           func_tax_amount = nvl(func_tax_amt_tab(rec.lno),0) * p_currency_conv_factor,
           last_update_date= p_last_updated_date,
           last_updated_by = p_last_updated_by,
           last_update_login = p_last_update_login
     WHERE line_id = p_line_id
       AND header_id = p_header_id
       AND tax_line_no = rec.lno;

  END LOOP;

  p_tax_amount := nvl(v_tax_amt,0);
EXCEPTION
  WHEN OTHERS THEN
  p_tax_amount := null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END recalculate_oe_taxes;

PROCEDURE recalculate_excise_taxes (  errbuf     OUT NOCOPY VARCHAR2
                                    , retcode    OUT NOCOPY VARCHAR2
                                    , pn_org_id             NUMBER /* This parameter would no more be used after application of the bug 5490479- Aiyer, */
                                    , pn_start_order        NUMBER
                                    , pn_end_order          NUMBER
                                    , pn_order_type_id      NUMBER
                                    , pn_ship_from_org_id   NUMBER
                                    )
AS
/*****************************************************************
* Enhancement Bug#2152709, 06/06/2002 Vijay Shankar
* FILENAME: ja_in_assessable_price_change.sql
*
* DESCRIPTION:
* This SQL script is used to Recalculate the Excise Duty if there
* is any change in the asssessable price given in the price list
* attached to the customer
*
* PARAMETERS:
*    1  p_org_id
*    2  p_start_order
*    3  p_end_order
*    4  p_order_type_id
*    5  p_ship_from_org_id
*******************************************************************/

  v_header_id     oe_order_lines_all.header_id%TYPE;
  v_line_id       oe_order_lines_all.line_id%TYPE;
  v_line_number     oe_order_lines_all.line_number%TYPE;
  v_shipment_number oe_order_lines_all.shipment_number%TYPE;
  v_ship_to_site_use_id   oe_order_lines_all.ship_to_ORG_id%TYPE;
  v_inventory_item_id   oe_order_lines_all.inventory_item_id%TYPE;
  v_line_quantity   oe_order_lines_all.ordered_quantity%TYPE;
  v_uom_code      oe_order_lines_all.order_quantity_uom%TYPE;
  v_warehouse_id    oe_order_lines_all.SHIP_FROM_ORG_ID%TYPE;

  v_last_update_date  oe_order_lines_all.last_update_date%TYPE;
  v_last_updated_by oe_order_lines_all.last_updated_by%TYPE;
  v_last_update_login oe_order_lines_all.last_update_login%TYPE;

/* commented by cbabu for Bug#2496481
  v_created_by    oe_order_lines_all.created_by%TYPE;
  v_creation_date   oe_order_lines_all.creation_date%TYPE;
  v_transaction_name      varchar2(30) := 'SO_LINES_UPDATE';
  v_original_system_line_ref  oe_order_lines_all.ORIG_SYS_LINE_REF%TYPE;
  v_original_line_reference oe_order_lines_all.ORIG_SYS_LINE_REF%TYPE;
  v_split_from_line_id  oe_order_lines_all.split_from_line_id%TYPE;
  v_source_document_id  oe_order_lines_all.source_document_id%TYPE;
  v_source_document_line_id oe_order_lines_all.source_document_line_id%TYPE;
  v_source_order_category   varchar2(30);
  v_source_header_id      Number;
  v_source_id         Number;
*/
  v_source_document_type_id oe_order_lines_all.source_document_type_id%TYPE;
  v_Line_Category_Code  oe_order_lines_all.line_category_code%TYPE;
  v_reference_line_id   oe_order_lines_all.reference_line_id%TYPE; -- used for return lines
  v_item_type_code    oe_order_lines_all.item_type_code%TYPE;
  v_unit_selling_price  oe_order_lines_all.unit_selling_price%TYPE;
  v_operating_id      oe_order_lines_all.org_id%TYPE;
  v_old_assessable_value  JAI_OM_OE_SO_LINES.assessable_value%TYPE;
  v_line_amount     NUMBER := 0;

  v_original_system_reference VARCHAR2(50);
  v_customer_id       Number;
  v_address_id        Number;
  v_price_list_id       Number;
  v_org_id          Number;
  v_order_number        Number;
  v_conv_type_code      varchar2(30);
  v_conv_rate         Number;
  v_conv_date         Date;
  v_conv_factor       Number;
  v_set_of_books_id     Number;
  v_tax_category_id     Number;
  v_order_category      varchar2(30);
  v_assessable_value      Number;
  v_assessable_amount     Number;
  v_price_list_uom_code   Varchar2(3);
  v_converted_rate      Number;
  v_date_ordered        Date;
  v_ordered_date        Date;

  v_assessable_value_date   DATE;  --Commented for File.sql.35 := SYSDATE;  -- cbabu for Bug#2496494

  v_line_tax_amount     Number  := 0;
  v_conversion_rate     Number  := 0;
  v_currency_code       gl_sets_of_books.currency_code%TYPE;
  v_order_source_type     varchar2(240);

  CURSOR  address_cur(p_ship_to_site_use_id IN Number) IS
    SELECT  nvl(cust_acct_site_id , 0) address_id
    FROM  hz_cust_site_uses_all A -- Removed ra_site_uses_all  for Bug# 4434287
    WHERE   A.site_use_id = p_ship_to_site_use_id;  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    --WHERE   A.site_use_id = NVL(p_ship_to_site_use_id,0);

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed the cursor set_of_books_cur and implemented using caching logic.
   */

  /* commented by cbabu for Bug#2496481
  CURSOR order_tax_amount_Cur (p_header_id Number, p_line_id  Number) IS
  Select  sum(a.tax_amount)
  From    JAI_OM_OE_SO_TAXES a, JAI_CMN_TAXES_ALL b
  Where   a.Header_ID = p_header_id
  and     a.line_id   = p_line_id
  and     b.tax_id  = a.tax_id
  and     b.tax_type  != 'TDS';
  */

  CURSOR Get_Assessable_Value_Cur(p_customer_id Number,p_address_id Number, p_inventory_item_id Number,
    p_uom_code Varchar2, p_ordered_date date ) IS  -- p_ordered_date variable name is misleading but the actual value it get is the SYSDATE
    SELECT  b.operand list_price,
      c.product_uom_code list_price_uom_code
    FROM  JAI_CMN_CUS_ADDRESSES a, QP_LIST_LINES b, qp_pricing_attributes c
    WHERE   a.customer_id = p_customer_id
    AND   a.address_id  = p_address_id
    AND   a.price_list_id = b.LIST_header_ID
    AND   c.list_line_id  = b.list_line_id
    AND   c.product_attr_value  = p_inventory_item_id /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    AND trunc(p_ordered_date) BETWEEN trunc(nvl( start_date_active, p_ordered_date))  -- cbabu for Bug#2496494
      AND trunc(nvl( end_date_active, SYSDATE));

    /*
    AND   c.product_attr_value  = TO_CHAR(p_inventory_item_id) --2001/02/14 Manohar Mishra
    AND   c.product_uom_code  = p_uom_code       --2001/10/09 Anuradha Parthasarathy
    AND   TRUNC(NVL(b.end_date_active,SYSDATE)) >= TRUNC(p_ordered_date);
     */

  CURSOR get_source_id IS
    Select order_source_id
    From oe_order_headers_all
    Where header_id = v_header_id;

  CURSOR Get_Order_Source_Type(P_Source_Document_Type_Id Number) is
    Select  Name
    from  OE_ORDER_SOURCES
    where Order_Source_Id=P_Source_Document_Type_Id;

  ----------------------------------------------------------------------------------
  CURSOR line_details1(p_order_number1 IN NUMBER, p_order_number2 IN NUMBER, p_ship_from_org_id IN NUMBER,
      p_org_id IN NUMBER, p_order_type_id IN NUMBER) IS
    SELECT  base.header_id, base.line_id, base.line_number, base.SHIPMENT_NUMBER,
      base.ship_to_ORG_id, base.inventory_item_id, base.ordered_quantity, base.order_quantity_uom,
      base.SHIP_FROM_ORG_ID, base.creation_date, base.created_by, base.last_update_date,
      base.last_updated_by, base.last_update_login, base.ORIG_SYS_LINE_REF,
      base.Line_Category_Code, base.reference_line_id, base.item_type_code, base.split_from_line_id,
      base.unit_selling_price, base.ORG_ID, base.SOURCE_DOCUMENT_ID, base.SOURCE_DOCUMENT_LINE_ID,
      base.SOURCE_DOCUMENT_TYPE_ID, ja.assessable_value,
        NVL(head.org_id,0) org_id1, head.SOLD_TO_ORG_ID, head.SOURCE_DOCUMENT_ID hsdi, head.order_number,
        head.price_list_id, head.ORDER_CATEGORY_CODE, head.ORIG_SYS_DOCUMENT_REF, head.TRANSACTIONAL_CURR_CODE,
        head.conversion_type_code, head.conversion_rate, head.CONVERSION_RATE_DATE, nvl(head.ORDERED_DATE, head.creation_date) ordered_date
    FROM oe_order_headers_all head, oe_order_lines_all base, JAI_OM_OE_SO_LINES ja
    WHERE head.header_id = base.header_id
    and base.line_id  = ja.line_id
    and base.OPEN_FLAG  = 'Y'
    and base.line_category_code = 'ORDER'
    and base.ship_from_org_id = p_ship_from_org_id
    and base.org_id = p_org_id
    and head.order_type_id = p_order_type_id
    and head.order_number between p_order_number1 and p_order_number2;
    --and base.flow_status_code IN ( 'ENTERED', 'BOOKED' )

--vijay shankar some important flags
  -- OPEN_FLAG, BOOKED_FLAG, CALCELLED_FLAG, FULFILLED_FLAG, SHIPPABLE_FLAG, SHIP_MODEL_COMPLETE_FLAG,
  -- AUTHORIZED_TO_SHIP_FLAG, SHIPPING_INTERFACED_FLAG, CALCULATE_PRICE_FLAG, ORDER_CATEGORY(return,order etc)
  -- head.FLOW_STATUS_CODE, line.FLOW_STATUS_CODE, ORDER_CATEGORY_CODE, LINE_CATEGORY

  CURSOR get_shipped_line(p_line_id IN NUMBER, p_header_id IN NUMBER ) IS
    SELECT order_line_id
    FROM JAI_OM_WSH_LINES_ALL
    WHERE order_line_id = p_line_id
    AND order_header_id = p_header_id;

  ii NUMBER; -- := 1; Commented for File.Sql.35
  p_start_order NUMBER;
  p_end_order NUMBER;
  p_org_id NUMBER;
  p_order_type_id NUMBER;
  p_ship_from_org_id NUMBER;

  v_check_line NUMBER;

  ln_vat_assessable_value NUMBER;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_tax_pkg.recalculate_excise_taxes';

  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Defined variable for implementing caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;



BEGIN
/*-------------------------------------------------------------------------------------------------------------------
S.No  Date(DD/MM/YYYY) Author and Details of Changes
----  --------------   -----------------------------
1     05/08/2002     Vijay Shankar for Bug# 2496481
                     When new taxes are added to order after tax defaultation, then change the assessable price attached
                     to the item and run the excise duty recalculation Concurrent, the added taxes are not getting calculated
                     properly. Base bug 2152709 is made obsolete with this patch and this patch becomes a prerequisite
                     patch for future patches related to this object.

2     05/08/2002     Vijay Shankar for Bug# 2496494
                     When price list contains more than one price list lines for the same item, which has end date greater than the ordered_date
                     or end_date is null then more than one price list lines are picked up by the cursor.

3     30/05/2005     Brathod, For Bug# 4400993
                     Issue:-
                       ja_in_assessible_price_change.sql was a pl-sql executable script, which needs to be
                       a procedure inside a package
                     Fix:-
                       Script is migrated into a jai_om_tax_pkg as recalculate_excise_tax procedure
                       with following input parameters.
                       errbuf, retcode, pn_org_id, pn_start_order
                       , pn_end_order, pn_order_type_id, pn_ship_from_org_id
                       In JAINREPC Concurrent Definition execution mentod modified from
                       SQL*Plus to PL-SQL Stored Procedure

4     26/05/2005     Ramananda for Bug#4540783. File Version 120.2
                     While running the concurrent - INDIA - EXCISE DUTY RECALCULATION, system is giving error -
                     "wrong number or types of arguments in call to  'jai_om_tax_pkg.recalculate_oe_taxes'"
                     Added a new parameter  - p_vat_assess_value and value for the same as NULL,
                     while calling procedure jai_om_tax_pkg.recalculate_oe_taxes

--------------------------------------------------------------------------------------------------------------------*/
v_assessable_value_date := sysdate;
ii := 1;

FND_FILE.PUT_LINE(FND_FILE.LOG,'STARTED the procedure ' );

/*  Added by Brathod for Bug# 4400993*/
/*
|| Start of bug 5490479
|| Added by aiyer for the bug 5490479
|| Get the operating unit (org_id)
*/
p_org_id      :=   mo_global.get_current_org_id;
fnd_file.put_line(fnd_file.log, 'Operating unit p_org_id is -> '||p_org_id);
/*End of bug 5490479 */

p_start_order :=        pn_start_order;
p_end_order :=          pn_end_order ;
p_order_type_id :=      pn_order_type_id;
p_ship_from_org_id :=   pn_ship_from_org_id;
/* End of Bug# 4400993 */

-- added by cbabu for Bug#2496481, start
v_last_update_date  :=  SYSDATE;
v_last_updated_by :=  FND_GLOBAL.USER_ID;
v_last_update_login :=  FND_GLOBAL.LOGIN_ID;
-- added by cbabu for Bug#2496481, end

FND_FILE.PUT_LINE(FND_FILE.LOG,' Sl. No., Order Number, Header_id , line_id, line_number'
                               ||', ship_to_site_use_id, inventory_item_id, line_quantity, uom_code'
                               ||',warehouse_id, Line_Category_Code, reference_line_id, item_type_code'
                               ||',original_line_reference, unit_selling_price, operating_id, org_id'
                               ||',SOLD_TO_ORG_ID, hsdi, price_list_id, ORDER_CATEGORY_CODE, ORIG_SYS_DOCUMENT_REF'
                               ||',TRANSACTIONAL_CURR_CODE, conversion_type_code, conversion_rate'
                               ||',CONVERSION_RATE_DATE, ORDERED_DATE');

FOR rec IN line_details1( p_start_order, p_end_order,p_ship_from_org_id, p_org_id, p_order_type_id) LOOP
    ------------------------------------------------------------------------
    FND_FILE.PUT_LINE(FND_FILE.LOG,ii||', ' || rec.order_number||', '||rec.header_id|| ', '||rec.line_id|| ', '||rec.line_number||', '||rec.SHIP_FROM_ORG_ID
    ||', '||rec.inventory_item_id|| ', '||rec.ordered_quantity||', '||rec.order_quantity_uom|| ', '||rec.SHIP_FROM_ORG_ID
    ||', '||rec.Line_Category_Code||', '||rec.reference_line_id|| ', '||rec.item_type_code
    ||', '||rec.ORIG_SYS_LINE_REF||', '||rec.unit_selling_price||', '||rec.org_id
    ||', '||rec.org_id1|| ', '||rec.SOLD_TO_ORG_ID||', '||rec.hsdi
    ||', '||rec.price_list_id||', '||rec.ORDER_CATEGORY_CODE|| ', '||rec.ORIG_SYS_DOCUMENT_REF||', '||rec.TRANSACTIONAL_CURR_CODE
    ||', '||rec.conversion_type_code||', '||rec.conversion_rate||', '||rec.CONVERSION_RATE_DATE||', '||rec.ORDERED_DATE);
    ------------------------------------------------------------------------

  OPEN get_shipped_line(rec.line_id,rec.header_id);
  FETCH get_shipped_line INTO v_check_line;
  CLOSE get_shipped_line;

  IF v_check_line IS NULL THEN  --- zzz

    v_header_id         := rec.header_id;
    v_line_id           := rec.line_id;
    v_line_number         := rec.line_number;
    v_shipment_number     := rec.shipment_number;
    v_ship_to_site_use_id     := rec.SHIP_TO_ORG_ID;
    v_inventory_item_id     := rec.inventory_item_id;
    v_line_quantity       := rec.ordered_quantity;
    v_uom_code          := rec.order_quantity_uom;
    v_warehouse_id        := rec.SHIP_FROM_ORG_ID;

  /* commented for cbabu for Bug#2496481
    v_creation_date       := rec.creation_date;
    v_created_by        := rec.created_by;
    v_last_update_date      := rec.last_update_date;
    v_last_updated_by     := rec.last_updated_by;
    v_last_update_login     := rec.last_update_login;
    v_original_system_line_ref  := rec.ORIG_SYS_LINE_REF;
    v_original_line_reference := rec.ORIG_SYS_LINE_REF;
    v_split_from_line_id    := null;
    v_source_document_id    := null;
    v_source_document_line_id := null;
  */

    v_source_document_type_id := rec.source_document_type_id;
    v_Line_Category_Code    := rec.Line_Category_Code;
    v_reference_line_id     := rec.reference_line_id;
    v_item_type_code      := rec.item_type_code;
    v_unit_selling_price    := rec.unit_selling_price;
    v_operating_id        := rec.org_id;
    v_old_assessable_value    := rec.assessable_value;
    v_line_amount         := nvl(v_line_quantity,0) * nvl(v_unit_selling_price,0);

    FND_FILE.PUT_LINE(FND_FILE.LOG,ii|| ', 1 v_line_amount = ' ||v_line_amount) ;

    v_org_id          := rec.org_id1;
    v_customer_id       := rec.sold_to_org_id;

  /* commented for cbabu for Bug#2496481
    v_source_header_id      := rec.hsdi;
  */

    v_order_number        := rec.order_number;
    v_price_list_id       := rec.price_list_id;
    v_order_category      := rec.order_category_code;
    v_original_system_reference := rec.orig_sys_document_ref;
    v_currency_code       := rec.transactional_curr_code;
    v_conv_type_code      := rec.conversion_type_code;
    v_conv_rate         := rec.conversion_rate;
    v_conv_date         := rec.conversion_rate_date;
    v_date_ordered        := rec.ordered_date;

    IF v_conv_date IS NULL THEN
      v_conv_date := v_date_ordered;
    END IF;

    Open Get_Order_Source_Type(v_source_document_type_id);
    Fetch Get_Order_Source_Type Into v_order_source_type;
    Close Get_Order_Source_Type;

    IF v_item_type_code = 'STANDARD'
      AND (v_reference_line_id IS NOT NULL or v_order_category = 'RETURN')
      -- AND nvl(v_source_document_type_id,0) != 2
      AND UPPER(v_order_source_type) <> 'COPY'
    THEN --- aaa -- if execution enters here, it means it is a return order which need not be considered for recalculation
      --return;
      null;
      FND_FILE.PUT_LINE(FND_FILE.LOG,ii||', 2 , returning v_item_type_code = '||v_item_type_code||',  v_order_category = '||v_order_category||',  v_reference_line_id = '||v_reference_line_id);
    ELSIF v_line_category_code in ('ORDER') THEN --- aaa,  compute assessable value

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the cursor set_of_books_cur and implemented using caching logic.
     */
     l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => v_warehouse_id );
     v_set_of_books_id := l_func_curr_det.ledger_id;

      v_converted_rate := jai_cmn_utils_pkg.currency_conversion (v_set_of_books_id ,
        v_currency_code, v_conv_date , v_conv_type_code, v_conv_rate);

      OPEN address_cur(v_ship_to_site_use_id);
      FETCH address_cur INTO v_address_id;
      CLOSE address_cur;

      FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 3 v_address_id = '||v_address_id||', 121 v_customer_id = '||v_customer_id);
      -- Fetch Assessable Price List Value for the
      -- given Customer and Location Combination
      -- OPEN Get_Assessable_Value_Cur(v_customer_id, v_address_id, v_inventory_item_id, v_uom_code, v_date_ordered);
      /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980 --added to_char*/
      OPEN Get_Assessable_Value_Cur(v_customer_id, v_address_id, to_char(v_inventory_item_id), v_uom_code, v_assessable_value_date);  -- cbabu for Bug#2496494
      FETCH Get_Assessable_Value_Cur INTO v_assessable_value, v_price_list_uom_code;
      CLOSE Get_Assessable_Value_Cur;

      IF v_assessable_value IS NULL THEN    --5
        -- Fetch Assessable Price List Value for the
        -- given Customer and NULL LOCATION Combination
        -- OPEN Get_Assessable_Value_Cur(v_customer_id, 0, v_inventory_item_id, v_uom_code, v_date_ordered);
                              /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980 --added to_char*/
        OPEN Get_Assessable_Value_Cur(v_customer_id, 0, to_char(v_inventory_item_id), v_uom_code, v_assessable_value_date); -- cbabu for Bug#2496494
        FETCH Get_Assessable_Value_Cur INTO v_assessable_value, v_price_list_uom_code;
        CLOSE Get_Assessable_Value_Cur;
        FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 4 v_assessable_value = '||v_assessable_value);
      END IF;                                             --5

      FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 5 , v_assessable_value = '||v_assessable_value||', v_price_list_uom_code = '||v_price_list_uom_code);
      IF NVL(v_assessable_value,0) > 0 THEN   --6
        -- If still the Assessable Value is available
        IF v_price_list_uom_code IS NOT NULL THEN   --7
          FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 6 , v_uom_code = '||v_uom_code||', v_inventory_item_id = '||v_inventory_item_id||', v_conversion_rate = '||v_conversion_rate);
          INV_CONVERT.inv_um_conversion(v_uom_code, v_price_list_uom_code, v_inventory_item_id, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0 THEN    --8
            FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 7 , v_conversion_rate = '||v_conversion_rate);
            INV_CONVERT.inv_um_conversion(v_uom_code, v_price_list_uom_code, 0, v_conversion_rate);
            FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 8 , v_conversion_rate = '||v_conversion_rate);
            IF nvl(v_conversion_rate, 0) <= 0 THEN  --9
              v_conversion_rate := 0;
            END IF;   --9
          END IF;   --8
        END IF;   --7

        v_assessable_value := NVL(1/v_converted_rate,0) * nvl(v_assessable_value,0) * v_conversion_rate;
        v_assessable_amount := nvl(v_assessable_value,0) * v_line_quantity;

        FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 9 v_assessable_amount = '||v_assessable_amount||', v_assessable_value = '||v_assessable_value);
      ELSE    --6
        -- If the assessable value is not available
        -- then pick up the Line price for Tax Calculation
        v_assessable_value  := NVL(v_unit_selling_price,0);
        v_assessable_amount := v_line_amount;
        FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 10 v_assessable_amount = '||v_assessable_amount);
      END IF;   --6

      IF v_old_assessable_value <> v_assessable_value THEN ---bbb

        /* commented by cbabu for Bug#2496481
        Open  get_source_id;
        Fetch get_source_id into v_source_id;
        Close get_source_id;

        IF  v_line_category_code in ('ORDER') THEN    --11  , and V_Order_Source_Type = 'Internal'

          FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 11');
          ja_in_tax_pkg.ja_in_cust_default_taxes(
            v_warehouse_id, v_customer_id,v_ship_to_site_use_id, v_inventory_item_id,
            v_header_id,v_line_id,v_tax_category_id);
          IF v_tax_category_id IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 12');
            ja_in_tax_pkg.ja_in_org_default_taxes(v_warehouse_id, v_inventory_item_id, v_tax_category_id);
          ELSE                                                          --13
            v_line_tax_amount := v_line_amount;
            FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 13 = '||v_line_tax_amount);
          END IF;                                                   --13

          ja_in_tax_pkg.ja_in_calc_prec_taxes(
            v_transaction_name, v_tax_category_id, v_header_id, v_line_id,
            v_assessable_amount, v_line_tax_amount, v_inventory_item_id, v_line_quantity,
            v_uom_code, '', '', v_converted_rate,
            v_creation_date, v_created_by, v_last_update_date, v_last_updated_by, v_last_update_login);

        END IF;                                                         --11

        OPEN  order_tax_amount_Cur(v_header_id, v_LINE_ID);
        FETCH order_tax_amount_Cur INTO v_line_tax_amount;
        CLOSE order_tax_amount_Cur;
      */

        -- added by cbabu for Bug#2496481, start
        -- v_line_tax_amount is the OUT variable for ja_in_tax_recalc procedure which contains total tax amount for that line
        v_line_tax_amount := v_line_amount;
        FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 13 = '||v_line_tax_amount);
        /* Added by Brathod for Bug# 4400993 */
        ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                               (
                                p_party_id           => v_customer_id          ,
                                p_party_site_id      => v_ship_to_site_use_id  ,
                                p_inventory_item_id  => v_inventory_item_id    ,
                                p_uom_code           => v_uom_code             ,
                                p_default_price      => v_unit_selling_price   ,
                                p_ass_value_date     => v_date_ordered         ,
                                p_party_type         => 'C'
                               );

        ln_vat_assessable_value := nvl(ln_vat_assessable_value,0) * v_line_quantity;
        /* End OF Bug# 4400993 */

        jai_om_tax_pkg.recalculate_oe_taxes
        (
          v_header_id,
          v_line_id,
          v_assessable_amount,
          ln_vat_assessable_value ,                      /* Added by Brathod for Bug# 4400993,  Ramananda for Bug#4540783 */
          v_line_tax_amount,
          v_inventory_item_id,
          v_line_quantity,
          v_uom_code,
          v_converted_rate,
          v_last_update_date,
          v_last_updated_by,
          v_last_update_login
        );
        -- added by cbabu for Bug#2496481, end

        UPDATE JAI_OM_OE_SO_LINES
        SET assessable_value  = v_assessable_value,
          tax_amount      = nvl(v_line_tax_amount,0),
          line_amount     =   v_line_amount,
          line_tot_amount   =   v_line_amount + nvl(v_line_tax_amount,0),
          last_update_date  = v_last_update_date,
          last_updated_by   = v_last_updated_by,
          last_update_login = v_last_update_login
        WHERE line_id = v_line_id and header_id = v_header_id;

      END IF; ---bbb
    END IF; ---aaa

    FND_FILE.PUT_LINE(FND_FILE.LOG,ii||' 14');
    ------------------------------------------------------------------------
    v_original_system_reference := null;
    v_customer_id       := null;
    v_address_id        := null;
    v_price_list_id       := null;
    v_org_id          := null;
    v_order_number        := null;
    v_conv_type_code      := null;
    v_conv_rate         := null;
    v_conv_date         := null;
    v_conv_factor       := null;
    v_set_of_books_id     := null;
    v_tax_category_id     := null;
    v_order_category      := null;
    v_line_amount       := 0;
  /* commented by cbabu for Bug#2496481
    v_source_header_id      := null;
    v_source_order_category   := null;
    v_source_id         := null;
  */
    v_assessable_value      := null;
    v_assessable_amount     := null;
    v_price_list_uom_code   := null;
    v_converted_rate      := null;
    v_date_ordered        := null;
    v_ordered_date        := null;

    v_line_tax_amount     := 0;
    v_conversion_rate     := 0;
    v_currency_code       := null;
    v_order_source_type     := null;
    v_source_document_type_id := null;
    v_org_id          := null;
    v_customer_id       := null;
    v_order_number        := null;
    v_price_list_id       := null;
    v_order_category      := null;
    v_original_system_reference := null;
    v_currency_code       := null;
    v_conv_type_code      := null;
    v_conv_rate         := null;
    v_conv_date         := null;
    v_date_ordered        := null;
    ------------------------------------------------------------------------

  END IF; --- zzz
  v_check_line := null;
  ii := ii + 1;

END LOOP;
COMMIT;
FND_FILE.PUT_LINE(FND_FILE.LOG,'END of the procedure JA_IN_ASSESSABLE_PRICE_CHANGE');

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END recalculate_excise_taxes;

END jai_om_tax_pkg;

/

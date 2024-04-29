--------------------------------------------------------
--  DDL for Package Body JAI_AR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_UTILS_PKG" 
/* $Header: jai_ar_utils.plb 120.6.12010000.3 2009/12/03 06:51:24 xlv ship $ */
AS

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks

07/12/2005   4866533 Hjujjuru  File version 120.3
                    added the who columns in the insert into tables JAI_AP_ETDS_REQUESTS and JAI_AP_ETDS_T.
                    Dependencies Due to this bug:-
                    None

01/11/2006 SACSETHI for bug 5228046, File version 120.4
            Forward porting the change in 11i bug 5365523 (Additional CVD Enhancement).
            This bug has datamodel and spec changes.
16/04/2007 KUNKUMAR for bugno 5989740
           Forward porting to R12 from 11i version 115.3.6107.2
4/11/2009  walton for bug no 9080017
           Issue: base tax amount is not correct in IL table after tax calcualtion
           Anaysis: base_tax_amt_tab(i) is hoding rate instead of amount as part of inclusive ER due to new arithmetic
           Fix: re-compute base_tax_amt_tab(i) after tax calculation, formula is:
                base_tax_amt_tab(I):=ln_exclusive_price*base_tax_amt_tab(I)+base_tax_amount_nr_tab.
                and fix a existing tax re-calculation issue that tax amount is zero after saved changes on AR transaction line

03/12/2009 Modified by Xiao for bug#9109910
           Issue: tax_amount is Zero after Trx Line amount changed.
           Analysis: for adhoc tax, tax_amount is updated as JAI_CMN_TAXES_ALL.tax_amount, which is always Zero
                     when adhoc tax is defined in table JAI_CMN_TAXES_ALL.
           Fix: Modified cursor tax_cur, get JAI_AR_TRX_TAX_LINES.tax_amount instead of JAI_CMN_TAXES_ALL.tax_amount
                to update tax_amount.

---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_ar_utils -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.
*/

PROCEDURE recalculate_tax(transaction_name VARCHAR2,
        P_tax_category_id NUMBER,
        p_header_id NUMBER,
        p_line_id NUMBER,
        p_assessable_value NUMBER default 0,
        p_tax_amount IN OUT NOCOPY NUMBER,
        p_currency_conv_factor NUMBER,
        p_inventory_item_id NUMBER,
        p_line_quantity NUMBER,
        p_uom_code VARCHAR2,
        p_vendor_id NUMBER,
        p_currency VARCHAR2,
        p_creation_date DATE,
        p_created_by NUMBER,
        p_last_update_date DATE,
        p_last_updated_by NUMBER,
        p_last_update_login NUMBER ,
        p_vat_assessable_Value NUMBER Default 0
        )
IS
TYPE num_tab IS TABLE OF number
  INDEX BY BINARY_INTEGER;
  TYPE tax_amt_num_tab IS TABLE OF number
  INDEX BY BINARY_INTEGER;
  p1 num_tab;
  p2 num_tab;
  p3 num_tab;
  p4 num_tab;
  p5 num_tab;


-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046

  p6 num_tab;
  p7 num_tab;
  p8 num_tab;
  p9 num_tab;
  p10 num_tab;

-- END BUG 5228046

  tax_rate_tab num_tab;
  tax_type_tab num_tab;
  tax_amt_tab tax_amt_num_tab;
  base_tax_amt_tab tax_amt_num_tab;
  base_tax_amount_nr_tab tax_amt_num_tab; --Added by walton for bug#9080017
  end_date_tab num_tab;
  rounding_factor_tab num_tab;


/* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_ar_utils_pkg.recalculate_tax';

  bsln_amt number; -- := p_tax_amount; --Ramananda for File.Sql.35
  v_conversion_rate number; -- := 0;   --Ramananda for File.Sql.35
  v_currency_conv_factor number; -- := p_currency_conv_factor; --Ramananda for File.Sql.35
  v_tax_amt number;  --SACSETHI for File.Sql.35
  vamt  number;  --SACSETHI for File.Sql.35
  v_amt number;
  row_count number ; --SACSETHI for File.Sql.35

  counter number;
  max_iter number ;   --SACSETHI for File.Sql.35


  CURSOR tax_cur(p_line_id IN Number) IS
  SELECT a.tax_id, a.tax_line_no lno, b.adhoc_flag, a.base_tax_amount, a.func_tax_amount,
         a.precedence_1 p_1, a.precedence_2 p_2, a.precedence_3 p_3, a.precedence_4 p_4, a.precedence_5 p_5,
         a.precedence_6 p_6, a.precedence_7 p_7, a.precedence_8 p_8, a.precedence_9 p_9, a.precedence_10 p_10,
         b.tax_rate,
         a.tax_amount, --Modified by Xiao for bug#9109910 on 3-Dec-09, /*b.tax_amount, */
         b.uom_code, b.end_date valid_date, b.rounding_factor,
         DECODE(rgm_tax_types.regime_Code,jai_constants.vat_regime, 4,  /* added by ssumaith - bug# 4245053*/
                  decode(upper(b.tax_type),
                          'EXCISE',          1,
                          'ADDL. EXCISE',    1,
                          'OTHER EXCISE',    1,
                          'CVD',             1,
                          'TDS',             2,
                          -- Modified by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
                          -- change tax_type_val
                          -------------------------------------------------------------------------
                          'EXCISE_EDUCATION_CESS'    , 6,
                          'CVD_EDUCATION_CESS'       , 6,
                          'SH_EXCISE_EDUCATION_CESS' , 6,--Added by kundan kumar for bug#5907436
                          'SH_CVD_EDUCATION_CESS'    , 6, --Added by kundan kumar for bug#5907436    Added by kunkumar for forward porting
                          -------------------------------------------------------------------------
                          -- Modified by Jia Li for Tax Inclusive Computations on 2007/12/11, End
                          0
                        )
               )tax_type_val,
         b.mod_cr_Percentage, b.vendor_id, b.tax_type
       , b.inclusive_tax_flag -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    FROM JAI_AR_TRX_TAX_LINES a, JAI_CMN_TAXES_ALL b ,
         jai_regime_tax_types_v rgm_tax_types   /* added by ssumaith - bug# 4245053*/
    WHERE a.link_to_cust_trx_line_id = p_line_id
    AND   a.tax_id = b.tax_id
    AND   rgm_tax_types.tax_type (+) = b.tax_type /* added by ssumaith - bug# 4245053*/
   ORDER BY a.tax_line_no;

  CURSOR uom_class_cur(p_line_uom_code IN varchar2, p_tax_line_uom_code IN varchar2) IS
  SELECT A.uom_class
    FROM mtl_units_of_measure A, mtl_units_of_measure B
   WHERE A.uom_code = p_line_uom_code
     AND B.uom_code = p_tax_line_uom_code
     AND A.uom_class = B.uom_class;

  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
  -------------------------------------------------------------------------
  TYPE char_tab IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
  tax_amt_rate_tax_tab    TAX_AMT_NUM_TAB;
  tax_amt_non_rate_tab    TAX_AMT_NUM_TAB;
  func_tax_amt_tab        TAX_AMT_NUM_TAB;
  tax_rate_zero_tab       NUM_TAB;
  tax_rate_per_rupee      NUM_TAB;
  tax_target_tab          NUM_TAB;
  inclu_tax_tab           CHAR_TAB;
  ln_assessable_value     NUMBER;
  ln_vat_assessable_value NUMBER;
  ln_vamt_nr                 NUMBER(38,10);
  ln_bsln_amt_nr             NUMBER(38,10);
  ln_v_tax_amt_nr            NUMBER(38,10);
  ln_v_func_tax_amt          NUMBER(38,10);
  ln_exclusive_price         NUMBER(38,10);
  ln_total_non_rate_tax      NUMBER(38,10);
  ln_total_tax_per_rupee     NUMBER(38,10);
  -------------------------------------------------------------------------
  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

   BEGIN

/*---------------------------------------------

1. 2005/03/10       ssumaith - bug# 4245053 - File version 115.1

                    Taxes under the vat regime needs to be calculated based on the vat assessable value setup done.
                    In the vendor additional information screen and supplier additional information screen, a place
                    has been given to capture the vat assessable value.

                    This needs to be used for the calculation of the taxes registered under vat regime.

                    This  change has been done by using the view jai_regime_tax_types_v - and outer joining it with the
                    JAI_CMN_TAXES_ALL table based on the tax type column.

                    Added a parameter p_vat_assessable_Value NUMBER for this procedure.

                   Dependency due to this bug - Huge

                   It uses many tables . views and indexes created as part of the VAT base bug - 4245089
                   This patch should always be accompanied by the VAT consolidated patch - 4245089

2   04-Aug-2005  Bug4535701. Added by Lakshmi Gopalsami
                 Commented the references to WHO columns for
     global temporary table JAI_AR_TRX_APPS_RELS_T

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                    Version   Author   Date         Remarks
Of File                              On Bug/Patchset     Dependent On
jai_ar_utils_pkg.recalculate_tax_p.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.1                 4245053       IN60106 +                                              ssumaith             Service Tax and VAT Infrastructure are created
                                    4146708 +                                                                   based on the bugs - 4146708 and 4545089 respectively.
                                    4245089
*************************************************************************************************************************/

  bsln_amt          := p_tax_amount; --Ramananda for File.Sql.35
  v_conversion_rate := 0;   --Ramananda for File.Sql.35
  v_currency_conv_factor := p_currency_conv_factor; --Ramananda for File.Sql.35
  max_iter := 15;
  v_tax_amt :=0 ;
  vamt  := 0 ;
  row_count :=0 ;

  ln_vamt_nr      := 0;   -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
  ln_v_tax_amt_nr := 0;   -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
  ln_bsln_amt_nr  := 0;   -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11

  FOR rec in tax_cur(p_line_id) LOOP
  p1(rec.lno) := nvl(rec.p_1,-1);
  p2(rec.lno) := nvl(rec.p_2,-1);
  p3(rec.lno) := nvl(rec.p_3,-1);
  p4(rec.lno) := nvl(rec.p_4,-1);
  p5(rec.lno) := nvl(rec.p_5,-1);

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
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

    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
    -----------------------------------------------------------------------
    tax_rate_per_rupee(rec.lno) := NVL(rec.tax_rate, 0)/100;
    ln_total_tax_per_rupee         := 0;
    inclu_tax_tab(rec.lno)      := NVL(rec.inclusive_tax_flag, 'N');

    IF rec.tax_rate IS NULL
    THEN
      tax_rate_zero_tab(rec.lno) := 0;
    ELSIF rec.tax_rate = 0
    THEN
      tax_rate_zero_tab(rec.lno) := -9999;
    ELSE
      tax_rate_zero_tab(rec.lno) := rec.tax_rate;
    END IF; -- rec.tax_rate is null

    tax_amt_rate_tax_tab(rec.lno) := 0;
    tax_amt_non_rate_tab(rec.lno) := 0;
    -----------------------------------------------------------------------
    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

  IF tax_rate_tab(rec.lno) = 0
  THEN
    FOR uom_cls IN uom_class_cur(p_uom_code, rec.uom_code) LOOP
            INV_CONVERT.inv_um_conversion( p_uom_code, rec.uom_code, p_inventory_item_id, v_conversion_rate);
      IF nvl(v_conversion_rate, 0) <= 0
      THEN
        INV_CONVERT.inv_um_conversion( p_uom_code, rec.uom_code, 0, v_conversion_rate);
          IF nvl(v_conversion_rate, 0) <= 0
          THEN
                  v_conversion_rate := 0;
            END IF;
         END IF;
       tax_amt_tab(rec.lno) := ROUND(nvl(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity, NVL(rec.rounding_factor, 0));
        -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
        -----------------------------------------------------------------------
        tax_amt_non_rate_tab(rec.lno) := NVL(rec.tax_amount * v_conversion_rate, 0) * p_line_quantity;
        base_tax_amt_tab(rec.lno) := tax_amt_non_rate_tab(rec.lno);
        -----------------------------------------------------------------------
        -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End
    END LOOP;
        END IF;

  IF rec.valid_date is NULL or rec.valid_date >= sysdate
  THEN
    end_date_tab(rec.lno) := 1;
  ELSE
          tax_amt_tab(rec.lno)  := 0;
    end_date_tab(rec.lno) := 0;
      END IF;
      row_count := row_count + 1;
     END LOOP;

  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
  -----------------------------------------------------------------------
  IF p_assessable_value <> p_tax_amount
  THEN
    ln_assessable_value := p_assessable_value;
  ELSE
    ln_assessable_value := 1;
  END IF;

  IF p_vat_assessable_value <> p_tax_amount
  THEN
    ln_vat_assessable_value := p_vat_assessable_value;
  ELSE
    ln_vat_assessable_value := 1;
  END IF;
  -----------------------------------------------------------------------
  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

  FOR I in 1..row_count LOOP
   -- Delete by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
   -----------------------------------------------------------------------
   /*
  IF tax_type_tab(I) = 1
  THEN
      bsln_amt := p_assessable_value;
  ELSIF tax_type_tab(I) = 4 THEN
     bsln_amt := p_vat_assessable_value;
  ELSE
      bsln_amt := p_tax_amount;
  END IF;
    */
   -----------------------------------------------------------------------
   -- Delete by Jia Li for Tax Inclusive Computations on 2007/12/11, End

    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
    -----------------------------------------------------------------------
    IF end_date_tab(I) <> 0
    THEN
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
      THEN
        IF ln_vat_assessable_value = 1
        THEN
          bsln_amt := 1;
          ln_bsln_amt_nr := 0;
        ELSE
          bsln_amt := 0;
          ln_bsln_amt_nr := ln_vat_assessable_value;
        END IF;
      ELSIF tax_type_tab(I) = 6
      THEN
        bsln_amt := 0;
        ln_bsln_amt_nr := 0;
      ELSE
        bsln_amt := 1;
        ln_bsln_amt_nr := 0;
     END IF; -- tax_type_tab(I) = 1
    -----------------------------------------------------------------------
    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

  IF tax_rate_tab(I) <> 0
    THEN
   IF p1(I) < I and p1(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p1(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
   ELSIF p1(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p2(I) < I and p2(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p2(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p2(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p3(I) < I and p3(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p3(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p3(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p4(I) < I and p4(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p4(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p4(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p5(I) < I and p5(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p5(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p5(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

-- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
-- START BUG 5228046
    IF p6(I) < I and p6(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p6(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p6(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p7(I) < I and p7(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p7(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p7(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p8(I) < I and p8(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p8(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p8(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p9(I) < I and p9(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p9(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p9(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

    IF p10(I) < I and p10(I) not in (-1,0) THEN
        vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
        ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p10(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    ELSIF p10(I) = 0 THEN
        vamt := vamt + bsln_amt;
        ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
    END IF;

-- END BUG 5228046


       v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));
       base_tax_amt_tab(I) := vamt;
       tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;

      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
      -----------------------------------------------------------------------
      ln_v_tax_amt_nr := ln_v_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));
      tax_amt_non_rate_tab(I) := NVL(tax_amt_non_rate_tab(I), 0) + ln_v_tax_amt_nr;
      tax_amt_rate_tax_tab(I) := tax_amt_tab(I);
      -----------------------------------------------------------------------
      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End
      base_tax_amount_nr_tab(i):=ln_vamt_nr; --Added by walton for bug#9080017

       /*IF end_date_tab(I) = 0
       THEN

    tax_amt_tab(I) := 0;
    base_tax_amt_tab(I) := 0;
       ELSIF end_date_tab(I) = 1 THEN
         IF tax_type_tab(I) IN (1, 2)
         THEN
     v_tax_amt := ROUND(v_tax_amt);
         END IF;
         tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
       END IF;*/
      vamt := 0;
      v_tax_amt := 0;
      ln_vamt_nr      := 0;  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      ln_v_tax_amt_nr := 0;  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11

    END IF;
  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
  -----------------------------------------------------------------------
  ELSE
    tax_amt_tab(I) := 0;
    base_tax_amt_tab(I) := 0;
  END IF; -- end_date_tab(I) <> 0
  -----------------------------------------------------------------------
  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End
  END LOOP;

/*for i in 1 .. row_count loop
 insert into xc values( ' Tax Amt from I loop in bkend Line ' || to_char( i ) || ' is ' || to_char( tax_amt_tab( I ) ) );
end loop;*/
  FOR I in 1..row_count LOOP
    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
    -----------------------------------------------------------------------
    IF end_date_tab(I) <> 0
    THEN
    -----------------------------------------------------------------------
    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End
      IF tax_rate_tab(I) <> 0 THEN
        IF p1(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p1(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p1(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p2(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p2(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p2(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p3(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p3(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p3(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p4(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p4(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p4(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p5(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p5(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p5(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;

    -- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046
        IF p6(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p6(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p6(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p7(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p7(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p7(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p8(I) > I  THEN
          vamt := vamt + nvl(tax_amt_tab(p8(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p8(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p9(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p9(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p9(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;
        IF p10(I) > I THEN
          vamt := vamt + nvl(tax_amt_tab(p10(I)),0);
          ln_vamt_nr := ln_vamt_nr + NVL(tax_amt_non_rate_tab(p10(I)), 0); -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        END IF;

-- END BUG 5228046


        v_tax_amt := v_tax_amt + (vamt * (tax_rate_tab(I)/100));

        base_tax_amt_tab(I) := vamt;  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        ln_v_tax_amt_nr := ln_v_tax_amt_nr + (ln_vamt_nr * (tax_rate_tab(I)/100));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
        base_tax_amount_nr_tab(i):=ln_vamt_nr; --Added by walton for bug#9080017

        IF vamt <> 0 THEN
           base_tax_amt_tab(I) := base_tax_amt_tab(I) + vamt;
        END IF;

        tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
        -----------------------------------------------------------------------
        tax_amt_non_rate_tab(I) := NVL(tax_amt_non_rate_tab(I), 0) + ln_v_tax_amt_nr; --modified by walton for bug9080017
        tax_amt_rate_tax_tab(I) := tax_amt_tab(I);
        ln_vamt_nr := 0;
        ln_v_tax_amt_nr := 0;
        -----------------------------------------------------------------------
        -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

        /*IF end_date_tab(I) = 0 THEN

        tax_amt_tab(I) := 0;
        base_tax_amt_tab(I) := 0;
        ELSIF end_date_tab(I) = 1 THEN
          IF tax_type_tab(I) IN (1, 2)
          THEN
        v_tax_amt := ROUND(v_tax_amt);
          END IF;
          tax_amt_tab(I) := nvl(tax_amt_tab(I),0) + v_tax_amt;
        END IF;*/
        vamt := 0;
        v_tax_amt := 0;
      END IF;

    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
    -----------------------------------------------------------------------
    ELSE
      base_tax_amt_tab(I) := vamt;
      tax_amt_tab(I) := 0;
    END IF; -- end_date_tab(I) <> 0
    -----------------------------------------------------------------------
    -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End
  END LOOP;


/*for i in 1 .. row_count loop
 insert into xc values( ' Tax Amt from II loop in bkend Line ' || to_char( i ) || ' is ' || to_char( tax_amt_tab( I ) ) );
end loop;*/
  FOR counter IN 1 .. max_iter LOOP
    vamt := 0;
    ln_vamt_nr := 0; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/07
    v_tax_amt := 0;
    ln_v_tax_amt_nr:=0; --Added by walton for bug #9080017

    FOR i IN 1 .. row_count LOOP
--changed > to <> allow -ve tax rate computation - Gaurav 06-dec-99
      -- Deleted by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
      ------------------------------------------------------------------------
      /*
      IF tax_rate_tab( i ) <> 0 THEN
   IF tax_type_tab( I ) = 1 THEN
        v_amt := p_assessable_value;
   ELSIF tax_type_tab( I ) = 4 THEN
        v_amt := p_vat_assessable_value;
   ELSE
      IF p_assessable_value IN ( 0, -1 ) OR tax_type_tab( I ) <> 1 THEN
         v_amt := p_tax_amount;
      END IF;
   END IF;
      */
      ------------------------------------------------------------------------
      -- Deleted by Jia Li for Tax Inclusive Computations on 2007/12/11, End

      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
      -----------------------------------------------------------------------
      IF ( tax_rate_tab(I) <> 0 OR tax_rate_zero_tab(I) = -9999 )
         AND
         ( end_date_tab(I) <> 0 )
      THEN
        IF tax_type_tab(I) = 1
        THEN
          IF ln_assessable_value = 1
          THEN
            v_amt := 1;
            ln_bsln_amt_nr := 0;
          ELSE
            v_amt := 0;
            ln_bsln_amt_nr := ln_assessable_value;
          END IF;
        ELSIF tax_type_tab(I) = 4
        THEN
          IF ln_vat_assessable_value = 1
          THEN
            v_amt := 1;
            ln_bsln_amt_nr := 0;
          ELSE
            v_amt := 0;
            ln_bsln_amt_nr := ln_vat_assessable_value;
          END IF;
        ELSIF tax_type_tab(I) = 6
        THEN
          v_amt := 0;
          ln_bsln_amt_nr := 0;
        ELSE
          v_amt := 1;
          ln_bsln_amt_nr := 0;
        END IF; -- tax_type_tab(I) = 1
      -----------------------------------------------------------------------
      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

       IF p1( i ) <> -1 THEN
          IF p1( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p1( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p1(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p1(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p2( i ) <> -1 THEN
          IF p2( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p2( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p2(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p2(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p3( i ) <> -1 THEN
          IF p3( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p3( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p3(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p3(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p4( i ) <> -1 THEN
          IF p4( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p4( i ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p4(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p4(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;

       IF p5( i ) <> -1 THEN
          IF p5( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p5( i ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p5(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p5(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;

    -- Date 01-NOV-2006 Bug 5228046 added by SACSETHI  ( added column from Precedence 6 to 10 )
    -- START BUG 5228046

       IF p6( i ) <> -1 THEN
          IF p6( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p6( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p6(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p6(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p7( i ) <> -1 THEN
          IF p7( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p7( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p7(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p7(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p8( i ) <> -1 THEN
          IF p8( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p8( I ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p8(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p8(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p9( i ) <> -1 THEN
          IF p9( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p9( i ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p9(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p9(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;
       IF p10( i ) <> -1 THEN
          IF p10( i ) <> 0 THEN
            vamt := vamt + tax_amt_tab( p10( i ) );
            ln_vamt_nr := ln_vamt_nr + tax_amt_non_rate_tab(p10(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          ELSIF p10(i) = 0 THEN
            vamt := vamt + v_amt;
            ln_vamt_nr := ln_vamt_nr + ln_bsln_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
          END IF;
       END IF;

    -- END BUG 5228046

       v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab( i )/100));
      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
      -----------------------------------------------------------------------
        base_tax_amt_tab(I) := vamt;
        tax_target_tab(I) := vamt;
        ln_v_func_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab(I)/100 ));
        ln_v_tax_amt_nr := ln_v_tax_amt_nr+( ln_vamt_nr*(tax_rate_tab(i)/100));
        --v_tax_amt := v_tax_amt + ( vamt * ( tax_rate_tab(I)/100 ));  --Commented by walton for bug #9080017
      ELSIF tax_rate_tab(I) = 0
      THEN
        base_tax_amt_tab(I) := tax_amt_tab(I);
        v_tax_amt := tax_amt_tab(I);
        tax_target_tab(I) := v_tax_amt;
        ln_v_tax_amt_nr := tax_amt_non_rate_tab(i);
      ELSIF end_date_tab(I) = 0
      THEN
        tax_amt_tab(I) := 0;
        base_tax_amt_tab(I) := 0;
        tax_target_tab(I) := 0;
      END IF;  -- (tax_rate_tab(I) <> 0 OR tax_rate_zero_tab(I) = -9999) AND (end_date_tab(I) <> 0)
      -----------------------------------------------------------------------
      -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End

      -- Deleted by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
      -----------------------------------------------------------------------
      /*
          ELSE
             v_tax_amt := tax_amt_tab( i );
          END IF;
      */
      -----------------------------------------------------------------------
      -- Deleted by Jia Li for Tax Inclusive Computations on 2007/12/11, End

      tax_amt_tab( I ) := NVL( v_tax_amt, 0 );
      tax_amt_rate_tax_tab(I) := tax_amt_tab(I);  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      func_tax_amt_tab(I) := NVL(ln_v_func_tax_amt, 0);  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      tax_amt_non_rate_tab(I) := ln_v_tax_amt_nr; -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      base_tax_amount_nr_tab(i):=ln_vamt_nr; --Added by walton for bug#9080017

      IF counter = max_iter THEN
       /*IF tax_type_tab( I ) IN ( 1, 2 ) THEN */
          tax_amt_tab( I ) := ROUND( tax_amt_tab( I ), rounding_factor_tab(I) );
          func_tax_amt_tab(I) := ROUND( func_tax_amt_tab( I ), rounding_factor_tab(I));  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
       /*ELSE
          tax_amt_tab( I ) := ROUND( tax_amt_tab( I ), 2 );
       END IF;*/
      END IF;

      vamt := 0;
      v_amt := 0;
      v_tax_amt := 0;
      ln_v_func_tax_amt := 0;  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      ln_v_tax_amt_nr:=0; --Added by walton for bug #9080017
      ln_vamt_nr:=0; --Added by walton for bug #9080017

      IF end_date_tab(I) = 0 THEN
        tax_amt_tab( i ) := 0;
        func_tax_amt_tab(I) := 0;  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11
      END IF;
    END LOOP;
  END LOOP;

  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, Begin
  -- the following loop calculates the total tax per rupee and total tax thats not dependent on selling price.
  -- and calculation final tax amount
  -----------------------------------------------------------------------
  FOR I IN 1 .. row_count
  LOOP
    jai_cmn_utils_pkg.print_log('utils.log','tax_amt_rate_tax_tab(I) = ' || tax_amt_rate_tax_tab(I));
    jai_cmn_utils_pkg.print_log('utils.log','tax_amt_non_rate_tab(I) = ' || tax_amt_non_rate_tab(I));
    jai_cmn_utils_pkg.print_log('utils.log','inclu flag = ' || inclu_tax_tab(I));

    IF inclu_tax_tab(I) = 'Y'
    THEN
      ln_total_tax_per_rupee := ln_total_tax_per_rupee + NVL(tax_amt_rate_tax_tab(I),0)  ;
      ln_total_non_rate_tax := nvl(ln_total_non_rate_tax,0) + NVL(tax_amt_non_rate_tab(I),0);  --modified by walton for bug#9080017
    END IF;
  END LOOP;

  ln_total_tax_per_rupee := ln_total_tax_per_rupee + 1;

  IF ln_total_tax_per_rupee <> 0
  THEN
   ln_exclusive_price := (NVL(p_tax_amount,0) - ln_total_non_rate_tax ) / ln_total_tax_per_rupee;
  END If;

  jai_cmn_utils_pkg.print_log('utils.log','tot tax per rupee = ' || ln_total_tax_per_rupee || ' totl non tax = ' || ln_total_non_rate_tax );
  jai_cmn_utils_pkg.print_log('utils.log','incl sp = ' || p_tax_amount || 'excl price = ' || ln_exclusive_price);

  FOR I IN 1 .. row_count
  LOOP
     tax_amt_tab (I) := (tax_amt_rate_tax_tab(I) * ln_exclusive_price ) + tax_amt_non_rate_tab(I);
     base_tax_amt_tab(I):=ln_exclusive_price*base_tax_amt_tab(I)+base_tax_amount_nr_tab(i); --Added by walton for bug#9080017
     jai_cmn_utils_pkg.print_log('utils.log','in final loop , tax amt is ' ||tax_amt_tab(I));
  END LOOP;
  -----------------------------------------------------------------------
  -- Added by Jia Li for Tax Inclusive Computations on 2007/12/11, End


   FOR rec in  tax_cur(p_line_id) LOOP
     IF tax_type_tab(rec.lno) <> 2
     THEN
       v_tax_amt := v_tax_amt + nvl(tax_amt_tab(rec.lno),0);
     END IF;

     IF transaction_name = 'AR_LINES_UPDATE'
     THEN
       IF NVL(rec.adhoc_flag,'N') = 'Y' THEN
           UPDATE  JAI_AR_TRX_TAX_LINES
              SET  tax_amount = nvl(rec.tax_amount,0),
                   base_tax_amount   = nvl(rec.base_tax_amount,0),
                   func_tax_amount   = nvl(rec.func_tax_amount,0),
                   last_update_date  = p_last_update_date,
                   last_updated_by   = p_last_updated_by,
                   last_update_login = p_last_update_login
            WHERE  link_to_cust_trx_line_id = P_line_id
              AND  tax_line_no = rec.lno;
       ELSE
           UPDATE  JAI_AR_TRX_TAX_LINES
              SET  tax_amount = nvl(tax_amt_tab(rec.lno),0),
                   base_tax_amount   = decode(nvl(base_tax_amt_tab(rec.lno), 0), 0, nvl(tax_amt_tab(rec.lno),0), nvl(base_tax_amt_tab(rec.lno), 0)),
                   func_tax_amount   = ROUND(nvl(tax_amt_tab(rec.lno),0) *  v_currency_conv_factor, rounding_factor_tab(rec.lno)),
                   last_update_date  = p_last_update_date,
                   last_updated_by   = p_last_updated_by,
                   last_update_login = p_last_update_login
            WHERE  link_to_cust_trx_line_id = P_line_id
              AND  tax_line_no = rec.lno;
       END IF;
     END IF;
   END LOOP;
   P_TAX_AMOUNT := nvl(v_tax_amt,0);


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

 END recalculate_tax;

 Procedure locator_handler(
   p_trx_id NUMBER,
   p_flag VARCHAR2  -- DEFAULT 'Y'  -- Use jai_constants.yes in the call of this procedure. Ramananda for for File.Sql.35
  )
 IS
 pragma AUTONOMOUS_TRANSACTION;    -- Vijay Shankar for Bug# 3985561

   CURSOR get_temp_count IS
     SELECT  count(*)
     FROM  JAI_AR_TRX_UPDATE_T
     WHERE   trx_id =  p_trx_id;

   v_count NUMBER;

   /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_ar_utils_pkg.locator_handler';

 BEGIN
 /*------------------------------------------------------------------------------------------
 CHANGE HISTORY for FILENAME: jai_om_rg_pkg.sql
 Slno  dd/mm/yyyy   Author and Change Details
 ------------------------------------------------------------------------------------------
 1.    31/05/2004   Vijay Shankar for Bug# 3985561, Version: 115.1
                   Deadlocks being caused due to JAI_AR_TRX_UPDATE_T table as the same row of table is being updated from different forms and triggers.
                   To resolve this, procedure is made to execute in AUTONOMOUS_TRANSACTION (Nested TRANSACTION CYCLE with COMMIT) mode
                   This whole procedure is modified as an Table Handler for JAI_AR_TRX_UPDATE_T table. for this purpose a new parameter named p_flag
                   is added that takes care of INSERT/UPDATE/DELETE on the table

                   HIGH DEPENDENCY for future bugs

 ------------------------------------------------------------------------------------------ */

   -- 3985561
   If p_flag = 'N' THEN
     UPDATE JAI_AR_TRX_UPDATE_T
       SET modified_flag = p_flag
     WHERE trx_id = p_trx_id;
   ELSIF p_flag = 'D' THEN
     DELETE FROM JAI_AR_TRX_UPDATE_T
     WHERE trx_id = p_trx_id;

   ELSE

     OPEN get_temp_count;
     FETCH get_temp_count INTO v_count;
     CLOSE get_temp_count;

     IF v_count > 0 THEN

       UPDATE JAI_AR_TRX_UPDATE_T
       SET modified_flag = p_flag
       WHERE trx_id = p_trx_id;

     ELSIF p_flag <> 'D' THEN

       INSERT INTO JAI_AR_TRX_UPDATE_T(
         trx_ID, modified_flag,
         -- added, Harshita for Bug 4866533
         created_by, creation_date, last_updated_by, last_update_date
       ) VALUES (
         p_trx_id, p_flag,
         -- added, Harshita for Bug 4866533
         fnd_global.user_id, sysdate, fnd_global.user_id, sysdate
       );

     END IF;

   END IF;

   COMMIT;   -- Vijay Shankar for Bug# 3985561

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END locator_handler;

/*
FUNCTION get_register_type(i_item_id NUMBER) RETURN VARCHAR2 IS
     X_class  JAI_OPM_ITM_MASTERS.item_class%type;
     CURSOR cur IS SELECT item_class
       FROM JAI_OPM_ITM_MASTERS
       WHERE ITEM_ID = i_item_id;
   BEGIN
     open cur;
     FETCH cur into X_class;
     IF substr(X_class,1,2) = 'RM' or substr(X_class,1,2) = 'CC' then
         RETURN 'A';
      ELSIF substr(X_class,1,2) = 'CG' THEN
        RETURN 'C';
     END IF;
END get_register_type;
*/

PROCEDURE apps_rel_insert(p_org_id  IN NUMBER, p_loc_id IN NUMBER, p_rg_flag  IN Varchar2,
            p_reg_name IN Varchar2 ,p_complete_flag  IN Varchar2, p_cretaed_by IN Number,
        last_updated_by IN Number, p_last_update_login IN Number, p_creation_date IN Date, last_update_date IN Date
) IS

  -- v_paddr   v$session.paddr%type;

  /* Added by Ramananda for bug#4407165 */
       lv_object_name CONSTANT VARCHAR2(61) := 'jai_ar_utils_pkg.apps_rel_insert';

BEGIN

/*------------------------------------------------------------------------------------------
 FILENAME: apps_rel_insert.sql

 CHANGE HISTORY:
S.No      Date          Author and Details

--------------------------------------------------------------------------------------------*/
/*
Select paddr INTO v_paddr From v$session
Where sid = (Select sid From v$mystat Where Rownum = 1);
*/--commneted by GSri on 22-jun-01 for tuning

--added by GSri -n 22-jun-01
/*Select paddr into v_paddr
From v$session
Where audsid = userenv('SESSIONID');
*/
Insert Into JAI_AR_TRX_APPS_RELS_T(
  Organization_ID,Location_ID,RG_Update_Flag,Register_Type,
  Once_completed_flag
  /* Bug 4535701. Commented by Lakshmi Gopalsami
   * As part of global temporary table
   * WHO columns has been removed
  ,  paddr,
  created_by, last_updated_by, last_update_login, creation_date, last_update_date */
) Values (
  p_org_id,p_loc_id,p_rg_flag,p_reg_name,
  p_complete_flag/*,  v_paddr,
  p_cretaed_by, last_updated_by, p_last_update_login, p_creation_date, last_update_date */
);

COMMIT;


/* Added by Ramananda for bug#4407165 */
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END apps_rel_insert;


END jai_ar_utils_pkg;

/

--------------------------------------------------------
--  DDL for Package Body JAI_GENERAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_GENERAL_PKG" AS
/* $Header: jai_general.plb 120.8.12010000.8 2009/07/30 10:34:55 jijili ship $ */

/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_general_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                    This Package is coded for Common Procedure/Functions that will be used across localization Product.
                    Different Functions are Packages are available in this Package to make Application coding simple


2     15/12/2004   Vijay Shankar for Bug#4068823,   FileVersion:115.1
                    added following new procedures/functions for the purpose of ServiceTax and Education Cess Enhancements
                    - get_accounting_method : Returns the Accounting method corresponding to the Operating Unit
                    - is_item_an_expense    : Returns whether item is Expense or not based on Inventory_Item_Flag of Organization Item

3     07/03/2005   Harshita for bug #4245062,   FileVersion:115.2
                   Added the function ja_in_vat_assessable_value.
                   This function calculates the vat assessable value for a customer or a vendor.
                   Base bug - #4245089

                   DEPENDENCY :
                   ------------
                   4245089

3.    08-Jun-2005  Version 116.2 jai_general -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                   as required for CASE COMPLAINCE.

4.    06-Jul-2005  Sanjikum for Bug#4474501
                   Commented the definition of function get_accounting_method

5.    03-Feb-2006  avallabh for Bug 4929644. Version 120.2.
                   Removed the definition of function is_orgn_opm_enabled, since it is not used anywhere else. Also removed the
                   definition of function get_accounting_method, so that no unused code is left over.

6.    08-Jun-2009  Jia Li for IL Advanced Pricing.
                   There were enhancement requests from customers to enhance the current India Localization functionality
                   on assessable values where an assessable value can be defined either based on an item or an item category.

                    DEPENDENCY:
                    -----------
                    IN60105D2 + 3496408
                    IN60106   + 4068823

7.    14-Jul-2009   CSahoo for bug#8574874, File Version 120.7.12000000.6
                    Issue: FP12.0 8558734: PERFORMANCE ISSUE IN SALES ORDER FORM
                    FIX: modified the cursor c_vat_ass_value_cust,c_vat_ass_value_pri_uom_cust,c_vat_ass_value_other_uom_cust
                         to enhance the performance.

8.    28-Jul-2009   Xiao Lv for IL Advanced Pricing.
                    Add if condition control for specific release version, code as:
                    IF lv_release_name NOT LIKE '12.0%' THEN
                       Advanced Pricing code;
                    END IF;

9.   30-Jul-2009    Jia Li for Bug#8731811 and Bug#8743974
                    Add validation logic for null site level to fix bug#8731811
                    Modified party_site_id paramter for open vend_ass_value_category_cur
----------------------------------------------------------------------------------------------------------------------------*/


/* added by Vijay Shankar for Bug#4068823 */
FUNCTION is_item_an_expense(
  p_organization_id   IN  NUMBER,
  p_item_id           IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR c_item_flag(cp_organization_id IN NUMBER, cp_item_id IN NUMBER) IS
    SELECT inventory_item_flag
    FROM mtl_system_items
    WHERE organization_id = cp_organization_id
    AND inventory_item_id = cp_item_id;

  lv_inv_item_flag  MTL_SYSTEM_ITEMS.inventory_item_flag%TYPE;

  lv_expense_flag   VARCHAR2(1);
  lv_object_name    CONSTANT VARCHAR2 (61) := 'jai_general_pkg.is_item_an_expense';

BEGIN

  OPEN c_item_flag(p_organization_id, p_item_id);
  FETCH c_item_flag INTO lv_inv_item_flag;
  CLOSE c_item_flag;

  IF lv_inv_item_flag = 'Y' THEN
    lv_expense_flag := 'N';
  ELSE
    lv_expense_flag := 'Y';
  END IF;

  RETURN lv_expense_flag;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;
END is_item_an_expense;

FUNCTION get_fin_year( p_organization_id IN NUMBER) RETURN NUMBER IS

  CURSOR c_active_fin_year IS
    SELECT max(fin_year) fin_year
    FROM JAI_CMN_FIN_YEARS
    WHERE organization_id = p_organization_id
    AND fin_active_flag = 'Y';

  ln_fin_year NUMBER;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_fin_year';

BEGIN
  OPEN c_active_fin_year;
  FETCH c_active_fin_year INTO ln_fin_year;
  CLOSE c_active_fin_year;
  RETURN ln_fin_year;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_fin_year;

PROCEDURE get_range_division (
  p_vendor_id       in  number,
  p_vendor_site_id  in  number,
  p_range_no OUT NOCOPY varchar2,
  p_division_no OUT NOCOPY varchar2
) IS

  CURSOR c_range_division IS
    SELECT excise_duty_range, excise_duty_division
    FROM JAI_CMN_VENDOR_SITES
    WHERE vendor_id = p_vendor_id
    AND vendor_site_id = p_vendor_site_id;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_range_division';
BEGIN

  OPEN c_range_division;
  FETCH c_range_division INTO p_range_no, p_division_no;
  CLOSE c_range_division;
EXCEPTION
  WHEN OTHERS THEN
  p_range_no:=null;
  p_division_no:=null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_range_division;

FUNCTION get_currency_precision (
    p_organization_id   IN  NUMBER
) RETURN NUMBER IS

  CURSOR c_precision IS
    SELECT nvl(fcl.precision,0)
    -- FROM fnd_currencies_vl fcl
    FROM fnd_currencies fcl
    WHERE fcl.currency_code              = 'INR'
     AND NVL(fcl.enabled_flag, 'N')      = 'Y'
     AND NVL(fcl.currency_flag, 'N')     = 'Y'
     AND NVL(start_date_active, SYSDATE) <= SYSDATE
     AND NVL(end_date_active, SYSDATE )  >= SYSDATE;

  ln_precision    FND_CURRENCIES_VL.precision%TYPE;

BEGIN

  OPEN  c_precision;
  FETCH c_precision INTO ln_precision;
  CLOSE c_precision;

  RETURN ln_precision;

END get_currency_precision;

FUNCTION get_gl_concatenated_segments(
  p_code_combination_id IN NUMBER
) RETURN VARCHAR2 IS
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_gl_concatenated_segments';
  lv_concatenated_segments  GL_CODE_COMBINATIONS_KFV.concatenated_segments%TYPE;
  CURSOR c_concatenated_segments(cp_code_combination_id IN NUMBER) IS
    SELECT concatenated_segments
    FROM gl_code_combinations_kfv
    WHERE code_combination_id = cp_code_combination_id;

BEGIN

  OPEN  c_concatenated_segments(p_code_combination_id);
  FETCH c_concatenated_segments INTO lv_concatenated_segments;
  CLOSE c_concatenated_segments;

  RETURN lv_concatenated_segments;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_gl_concatenated_segments;

FUNCTION get_organization_code (
    p_organization_id   IN  NUMBER
) RETURN VARCHAR2 IS
  /* Bug 5243532. Added by Lakshmi Gopalsami
   * Removed the cursor c_fetch_orgn_code which is referring
   * to org_organization_definitions
   * and implemented using caching logic.
   */
  l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  -- End for bug 5243532
  lv_organization_code  ORG_ORGANIZATION_DEFINITIONS.organization_code%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_organization_code';
BEGIN

  l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_organization_id );
  lv_organization_code  := l_func_curr_det.organization_code;


  RETURN lv_organization_code;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_organization_code;

FUNCTION get_rg_register_type(p_item_class IN VARCHAR2) RETURN VARCHAR2 IS

  lv_register_type VARCHAR2(1);
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_rg_register_type';
BEGIN

  /* This procedure should be used only for Receipt Transactions. Because FGIN and FGEX should hit RG1, but incase of RMA Receipt
  the should hit RG23A Register */

  IF p_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX', 'FGIN', 'FGEX') THEN --narao
    lv_register_type := 'A';
  ELSIF p_item_class IN ('CGIN', 'CGEX') THEN
    lv_register_type := 'C';
  ELSE
    lv_register_type := NULL;
  END IF;

  RETURN lv_register_type;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_rg_register_type;

FUNCTION get_primary_uom_code(p_organization_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR c_get_primary_uom_code IS
    SELECT primary_uom_code
    FROM mtl_system_items
    WHERE organization_id = p_organization_id
    AND inventory_item_id = p_inventory_item_id;

  lv_uom_code  MTL_SYSTEM_ITEMS.primary_uom_code%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_primary_uom_code';

BEGIN

  OPEN   c_get_primary_uom_code;
  FETCH  c_get_primary_uom_code INTO lv_uom_code;
  CLOSE  c_get_primary_uom_code;

  RETURN lv_uom_code;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_primary_uom_code;

FUNCTION get_uom_code(p_uom IN VARCHAR2) RETURN VARCHAR2 IS
  CURSOR c_uom_code IS
    SELECT uom_code
    FROM mtl_units_of_measure
    WHERE unit_of_measure = p_uom;

  lv_uom_code  MTL_UNITS_OF_MEASURE.uom_code%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_uom_code';

BEGIN
  OPEN   c_uom_code;
  FETCH  c_uom_code INTO lv_uom_code;
  CLOSE  c_uom_code;

  RETURN lv_uom_code;

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_uom_code;

FUNCTION get_orgn_master_flag(p_organization_id IN NUMBER, p_location_id IN NUMBER) RETURN VARCHAR2 IS

  CURSOR c_master_flag IS
    SELECT master_org_flag
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id;

  lv_master_flag  JAI_CMN_INVENTORY_ORGS.master_org_flag%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_orgn_master_flag';
BEGIN
  OPEN   c_master_flag;
  FETCH  c_master_flag INTO lv_master_flag;
  CLOSE  c_master_flag;

  RETURN lv_master_flag;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_orgn_master_flag;

FUNCTION get_matched_boe_no(
  p_transaction_id    IN  NUMBER
) RETURN VARCHAR2 IS
  lv_boe_no     VARCHAR2(150); -- := ''; --rpokkula for File.Sql.35
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_matched_boe_no';
BEGIN

  lv_boe_no := ''; --rpokkula for File.Sql.35

  FOR r_boe IN (SELECT boe_id FROM JAI_CMN_BOE_MATCHINGS
                WHERE transaction_id = p_transaction_id)
  LOOP
    IF NVL(length(lv_boe_no), 0) <= 135 THEN
      lv_boe_no := lv_boe_no||to_char(r_boe.boe_id)||'/';
    END IF;
  END LOOP;

  lv_boe_no := Rtrim(lv_boe_no, '/');

  RETURN lv_boe_no;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_matched_boe_no;

FUNCTION trxn_to_primary_conv_rate(
  p_transaction_uom_code  IN  MTL_UNITS_OF_MEASURE.uom_code%TYPE,
  p_primary_uom_code      IN  MTL_UNITS_OF_MEASURE.uom_code%TYPE,
  p_inventory_item_id     IN  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE
) RETURN NUMBER IS
  vTransToPrimaryUOMConv  NUMBER;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.trxn_to_primary_conv_rate';
BEGIN

  IF p_transaction_uom_code <> p_primary_uom_code THEN
    INV_CONVERT.inv_um_conversion(
      p_transaction_uom_code, p_primary_uom_code,
      p_inventory_item_id, vTransToPrimaryUOMConv
    );

    IF nvl(vTransToPrimaryUOMConv, 0) <= 0 THEN
      INV_CONVERT.inv_um_conversion(
        p_transaction_uom_code, p_primary_uom_code,
        0, vTransToPrimaryUOMConv
      );
      IF nvl(vTransToPrimaryUOMConv, 0) <= 0  THEN
        vTransToPrimaryUOMConv := 1;
      END IF;
    END IF;

  ELSE
    vTransToPrimaryUOMConv := 1;
  END IF;

  RETURN vTransToPrimaryUOMConv;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END trxn_to_primary_conv_rate;

FUNCTION get_last_record_of_rg(
    p_register_name     IN VARCHAR2,
    p_organization_id   IN NUMBER,
    p_location_id       IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_fin_year          IN NUMBER   DEFAULT NULL
) RETURN NUMBER IS

  -- RG23 Part I
  CURSOR c_rg23_part1(cp_register_type IN VARCHAR2, cp_fin_year IN NUMBER) IS
    SELECT register_id FROM JAI_CMN_RG_23AC_I_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND register_type = cp_register_type
    AND inventory_item_id = p_inventory_item_id
    AND fin_year = cp_fin_year
    AND slno = (select max(slno) from JAI_CMN_RG_23AC_I_TRXS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id
                AND register_type = cp_register_type
                AND inventory_item_id = p_inventory_item_id
                AND fin_year = cp_fin_year);

  -- RG1
  CURSOR c_rg1(cp_fin_year IN NUMBER) IS
    SELECT register_id FROM JAI_CMN_RG_I_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND inventory_item_id = p_inventory_item_id
    AND fin_year = cp_fin_year
    AND slno = (select max(slno) from JAI_CMN_RG_I_TRXS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id
                AND inventory_item_id = p_inventory_item_id
                AND fin_year = cp_fin_year);

  -- RG23D
  CURSOR c_rg23d(cp_fin_year IN NUMBER) IS
    SELECT register_id FROM JAI_CMN_RG_23D_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND inventory_item_id = p_inventory_item_id
    AND fin_year = cp_fin_year
    AND slno = (select max(slno) from JAI_CMN_RG_23D_TRXS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id
                AND inventory_item_id = p_inventory_item_id
                AND fin_year = cp_fin_year);

  -- RG23 Part II
  CURSOR c_rg23_part2(cp_register_type IN VARCHAR2, cp_fin_year IN NUMBER) IS
    SELECT register_id FROM JAI_CMN_RG_23AC_II_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND register_type = cp_register_type
    AND fin_year = cp_fin_year
    AND slno = (select max(slno) from JAI_CMN_RG_23AC_II_TRXS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id
                AND register_type = cp_register_type
                AND fin_year = cp_fin_year);

  -- PLA
  CURSOR c_pla(cp_fin_year IN NUMBER) IS
    SELECT register_id FROM JAI_CMN_RG_PLA_TRXS
    WHERE organization_id = p_organization_id
    AND location_id = p_location_id
    AND fin_year = cp_fin_year
    AND slno = (select max(slno) from JAI_CMN_RG_PLA_TRXS
                WHERE organization_id = p_organization_id
                AND location_id = p_location_id
                AND fin_year = cp_fin_year);

  lv_register_type  VARCHAR2(1);
  ln_register_id    NUMBER;
  ln_fin_year       NUMBER(4);
  ln_prev_fin_year  NUMBER(4);
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.get_last_record_of_rg';
BEGIN

  IF p_fin_year IS NULL THEN
    ln_fin_year := jai_general_pkg.get_fin_year(p_organization_id);
  ELSE
    ln_fin_year := p_fin_year;
  END IF;
  ln_prev_fin_year := ln_fin_year - 1;

  IF p_register_name IN ('RG23A_1', 'RG23A_2') THEN
    lv_register_type := 'A';
  ELSIF p_register_name IN ('RG23C_1', 'RG23C_2') THEN
    lv_register_type := 'C';
  END IF;

  IF p_register_name IN ('RG23A_1', 'RG23C_1') THEN
    OPEN c_rg23_part1(lv_register_type, ln_fin_year);
    FETCH c_rg23_part1 INTO ln_register_id;
    CLOSE c_rg23_part1;
    IF ln_register_id IS NULL THEN
      OPEN c_rg23_part1(lv_register_type, ln_prev_fin_year);
      FETCH c_rg23_part1 INTO ln_register_id;
      CLOSE c_rg23_part1;
    END IF;

  ELSIF p_register_name = 'RG1' THEN
    OPEN c_rg1(ln_fin_year);
    FETCH c_rg1 INTO ln_register_id;
    CLOSE c_rg1;
    IF ln_register_id IS NULL THEN
      OPEN c_rg1(ln_prev_fin_year);
      FETCH c_rg1 INTO ln_register_id;
      CLOSE c_rg1;
    END IF;

  ELSIF p_register_name = 'RG23D' THEN
    OPEN c_rg23d(ln_fin_year);
    FETCH c_rg23d INTO ln_register_id;
    CLOSE c_rg23d;
    IF ln_register_id IS NULL THEN
      OPEN c_rg23d(ln_prev_fin_year);
      FETCH c_rg23d INTO ln_register_id;
      CLOSE c_rg23d;
    END IF;

  ELSIF p_register_name IN ('RG23A_2', 'RG23C_2') THEN
    OPEN c_rg23_part2(lv_register_type, ln_fin_year);
    FETCH c_rg23_part2 INTO ln_register_id;
    CLOSE c_rg23_part2;
    IF ln_register_id IS NULL THEN
      OPEN c_rg23_part2(lv_register_type, ln_prev_fin_year);
      FETCH c_rg23_part2 INTO ln_register_id;
      CLOSE c_rg23_part2;
    END IF;

  ELSIF p_register_name = 'PLA' THEN
    OPEN c_pla(ln_fin_year);
    FETCH c_pla INTO ln_register_id;
    CLOSE c_pla;
    IF ln_register_id IS NULL THEN
      OPEN c_pla(ln_prev_fin_year);
      FETCH c_pla INTO ln_register_id;
      CLOSE c_pla;
    END IF;

  END IF;

  RETURN ln_register_id;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_last_record_of_rg;

PROCEDURE update_rg_balances(
  p_organization_id IN NUMBER,
  p_location_id IN NUMBER,
  p_register IN VARCHAR2,
  p_amount IN NUMBER,
  p_transaction_source IN VARCHAR2,
  p_called_from IN VARCHAR2
) IS

  ln_rg23a_amount   NUMBER;
  ln_rg23c_amount   NUMBER;
  ln_pla_amount     NUMBER;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.update_rg_balances';

BEGIN

  IF p_register = 'A' THEN
    ln_rg23a_amount := p_amount;
    ln_rg23c_amount := 0;
    ln_pla_amount   := 0;
  ELSIF p_register = 'C' THEN
    ln_rg23a_amount := 0;
    ln_rg23c_amount := p_amount;
    ln_pla_amount   := 0;
  ELSIF p_register = 'PLA' THEN
    ln_rg23a_amount := 0;
    ln_rg23c_amount := 0;
    ln_pla_amount   := p_amount;
  ELSE
    ln_rg23a_amount := 0;
    ln_rg23c_amount := 0;
    ln_pla_amount   := 0;
  END IF;

  UPDATE JAI_CMN_RG_BALANCES
  SET rg23a_balance = nvl(rg23a_balance,0)  + ln_rg23a_amount,
      rg23c_balance = nvl(rg23c_balance,0)  + ln_rg23c_amount,
      pla_balance   = nvl(pla_balance,0)    + ln_pla_amount
  WHERE organization_id = p_location_id
  AND location_id = p_location_id;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END update_rg_balances;

function plot_codepath
(
  p_statement_id                            in        varchar2,
  p_codepath                                in        varchar2,
  p_calling_procedure                       in        varchar2 default null,
  p_special_call                            in        varchar2 default null
)
return varchar2
IS
  -- Bug 5581319. Set the length to 1996 instead of 2000

  lv_size_of_codepath     number:= 1996;
  lv_codepath             VARCHAR2(1996);

  lv_mesg                 varchar2(200); -- := ''; --rpokkula for File.Sql.35
  ln_tot_length           number;
begin
  lv_mesg := ''; --rpokkula for File.Sql.35
  -- P1 bug5243532 commented the following assignment.
  -- lv_codepath := p_codepath;

  if p_special_call = 'START'  then
    lv_mesg := lv_mesg || '>>' || nvl(p_calling_procedure, ' ') || '~';
  end if;

  lv_mesg := lv_mesg || ':' || NVL(p_statement_id, '0');

  if p_special_call = 'END'  then
    lv_mesg := lv_mesg || '<<' ;
  end if;

  -- P1 bug . changed to p_codepath instead of lv_codepath.

  ln_tot_length := length(p_codepath) + length(lv_mesg);

  if ln_tot_length > lv_size_of_codepath then
    lv_codepath := substr(p_codepath, ln_tot_length-lv_size_of_codepath +1 );

  ELSE
    /* Bug 5243532. Added by Lakshmi Gopalsami
     | Assigned the same value of p_codepath if the length is not exceeding.
     */
    lv_codepath := p_codepath;
  END  IF ;

  lv_codepath := lv_codepath ||lv_mesg;

  return lv_codepath;

exception
  when others then
    FND_FILE.put_line( FND_FILE.log, '/////// Error IN GENERAL_PKG.plot_codepath. lv_mesg'||lv_mesg);

    lv_codepath := 'Exception in plot_codepath :' || sqlerrm || '/' || lv_codepath;
    return lv_codepath;
end plot_codepath;



FUNCTION ja_in_vat_assessable_value(
    p_party_id IN NUMBER,
    p_party_site_id IN NUMBER,
    p_inventory_item_id IN NUMBER,
    p_uom_code IN VARCHAR2,
    p_default_price IN NUMBER,
    p_ass_value_date IN DATE,    -- DEFAULT SYSDATE, -- Added global variable gd_ass_value_date in package spec. by rpokkula for File.Sql.35
    p_party_type IN VARCHAR2
) RETURN NUMBER IS

   ------------------------------------------------Cursors for Customer------------------------------------------

    CURSOR address_cur( p_party_site_id IN NUMBER )
    IS
    SELECT NVL(cust_acct_site_id, 0) address_id
    FROM hz_cust_site_uses_all A  -- Removed ra_site_uses_all  for Bug# 4434287
    WHERE A.site_use_id = NVL(p_party_site_id,0);

    /* Coomented the following for bug#8574874, start
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, ,Ordered date.
     Exact Match condition

    CURSOR c_vat_ass_value_cust
                             ( p_party_id        NUMBER  ,
                               p_address_id         NUMBER  ,
                               p_inventory_item_id  NUMBER  ,
                               p_uom_code           VARCHAR2,
                               p_ordered_date       DATE
                             )
    IS
    SELECT
            b.operand list_price,
            c.product_uom_code list_price_uom_code
    FROM
            JAI_CMN_CUS_ADDRESSES a,
            qp_list_lines b,
            qp_pricing_attributes c
    WHERE
            a.customer_id           = p_party_id                                    AND
            a.address_id            = p_address_id                                  AND
            a.vat_price_list_id     = b.LIST_header_ID                              AND
            c.list_line_id          = b.list_line_id                                AND
            c.product_attr_value    = to_char(p_inventory_item_id)                  AND
            c.product_uom_code      = p_uom_code                                    AND
            p_ordered_date          BETWEEN nvl( start_date_active, p_ordered_date) AND
                                            nvl( end_date_active, SYSDATE);

    /*
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, Ordered date.
     Exact Match condition

     CURSOR c_vat_ass_value_pri_uom_cust(
                                        p_party_id        NUMBER,
                                        p_address_id         NUMBER,
                                        p_inventory_item_id  NUMBER,
                                        p_ordered_date       DATE
                                      )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             JAI_CMN_CUS_ADDRESSES a,
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             a.customer_id                           = p_party_id                         AND
             a.address_id                            = p_address_id                       AND
             a.vat_price_list_id                     = b.list_header_id                   AND
             c.list_line_id                          = b.list_line_id                     AND
             c.product_attr_value                    = to_char(p_inventory_item_id)       AND
             trunc(nvl(b.end_date_active,sysdate))   >= trunc(p_ordered_date)             AND
             nvl(primary_uom_flag,'N')               ='Y';

     CURSOR c_vat_ass_value_other_uom_cust
                                     (
                                       p_party_id              NUMBER,
                                       p_address_id            NUMBER,
                                       p_inventory_item_id     NUMBER,
                                       p_ordered_date          DATE
                                     )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             JAI_CMN_CUS_ADDRESSES a,
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             a.customer_id                  = p_party_id                     AND
             a.address_id                   = p_address_id                   AND
             a.vat_price_list_id            = b.LIST_header_ID               AND
             c.list_line_id                 = b.list_line_id                 AND
             c.PRODUCT_ATTR_VALUE           = TO_CHAR(p_inventory_item_id)   AND
             NVL(b.end_date_active,SYSDATE) >= p_ordered_date;
  Commented for bug#8574874, end             */

    --Added the following cursors for bug#8574874, start*/
    CURSOR c_vat_ass_value_cust
                             ( p_party_id        NUMBER  ,
                               p_address_id         NUMBER  ,
                               p_inventory_item_id  NUMBER  ,
                               p_uom_code           VARCHAR2,
                               p_ordered_date       DATE
                             )
    IS
    SELECT
            b.operand list_price,
            c.product_uom_code list_price_uom_code
    FROM
            qp_list_lines b,
            qp_pricing_attributes c
    WHERE
            c.list_line_id          = b.list_line_id                                AND
            c.product_attr_value    = to_char(p_inventory_item_id)                  AND
            c.product_uom_code      = p_uom_code                                    AND
            p_ordered_date          BETWEEN nvl( b.start_date_active, p_ordered_date)
                                        AND nvl( b.end_date_active, SYSDATE)        AND
            EXISTS (  Select  1
                      from    qp_list_headers qlh, JAI_CMN_CUS_ADDRESSES a
                      where   qlh.list_header_id      = b.list_header_id
                      and     a.customer_id           = p_party_id
                      AND     a.address_id            = p_address_id
                      AND     a.vat_price_list_id     = b.LIST_header_ID
                      and     p_ordered_date BETWEEN nvl( qlh.start_date_active, p_ordered_date)
                                              AND nvl( qlh.end_date_active, SYSDATE)
                      and nvl(qlh.active_flag,'N') = 'Y');


     CURSOR c_vat_ass_value_pri_uom_cust(
                                        p_party_id        NUMBER,
                                        p_address_id         NUMBER,
                                        p_inventory_item_id  NUMBER,
                                        p_ordered_date       DATE
                                      )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             c.list_line_id                          = b.list_line_id                     AND
             c.product_attr_value                    = to_char(p_inventory_item_id)       AND
             trunc(nvl(b.end_date_active,sysdate))   >= trunc(p_ordered_date)             AND
             exists ( select 1
                      from    qp_list_headers qlh, JAI_CMN_CUS_ADDRESSES a
                      where   a.customer_id          = p_party_id                         AND
                              a.address_id           = p_address_id                       AND
                              qlh.list_header_id     = b.list_header_id                   AND
                              a.vat_price_list_id    = b.list_header_id                   AND
                              trunc(nvl(qlh.end_date_active,sysdate)) >= trunc(p_ordered_date) AND
                              nvl(qlh.active_flag,'N') = 'Y' )                            AND
             nvl(primary_uom_flag,'N')               ='Y';

     CURSOR c_vat_ass_value_other_uom_cust
                                     (
                                       p_party_id              NUMBER,
                                       p_address_id            NUMBER,
                                       p_inventory_item_id     NUMBER,
                                       p_ordered_date          DATE
                                     )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             c.list_line_id                 = b.list_line_id                 AND
             c.PRODUCT_ATTR_VALUE           = TO_CHAR(p_inventory_item_id)   AND
             NVL(b.end_date_active,SYSDATE) >= p_ordered_date                AND
             EXISTS ( select  1
                      from    qp_list_headers qlh, JAI_CMN_CUS_ADDRESSES a
                      WHERE   a.customer_id    = p_party_id   AND
                              a.address_id     = p_address_id AND
                              qlh.list_header_id  = b.list_header_id AND
                              a.vat_price_list_id = b.LIST_header_ID AND
                              NVL(qlh.end_date_active,SYSDATE) >= p_ordered_date  AND
                              NVL( qlh.active_flag,'N') = 'Y' );
    --bug#8574874, end
-------------------------------------end, cursors for customer------------------------------------------------------

----------------------------------------cursors for vendor--------------------------------------------------

    /*
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, ,Ordered date.
     Exact Match condition
    */
    CURSOR c_vat_ass_value_vend
                             ( p_vendor_id        NUMBER  ,
                               p_address_id         NUMBER  ,
                               p_inventory_item_id  NUMBER  ,
                               p_uom_code           VARCHAR2,
                               p_ordered_date       DATE
                             )
    IS
    SELECT
            b.operand list_price,
            c.product_uom_code list_price_uom_code
    FROM
            JAI_CMN_VENDOR_SITES a,
            qp_list_lines b,
            qp_pricing_attributes c
    WHERE
            a.vendor_id             = p_vendor_id                                   AND
            a.vendor_site_id        = p_address_id                                  AND
            a.vat_price_list_id     = b.LIST_header_ID                              AND
            c.list_line_id          = b.list_line_id                                AND
            c.product_attr_value    = to_char(p_inventory_item_id)                  AND
            c.product_uom_code      = p_uom_code                                    AND
            p_ordered_date          BETWEEN nvl( start_date_active, p_ordered_date) AND
                                            nvl( end_date_active, SYSDATE);

    /*
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, Ordered date.
     Exact Match condition
    */

     CURSOR c_vat_ass_value_pri_uom_vend(
                                        p_vendor_id          NUMBER,
                                        p_address_id         NUMBER,
                                        p_inventory_item_id  NUMBER,
                                        p_ordered_date       DATE
                                      )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             JAI_CMN_VENDOR_SITES a,
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             a.vendor_id                             = p_vendor_id                        AND
             a.vendor_site_id                        = p_address_id                       AND
             a.vat_price_list_id                     = b.list_header_id                   AND
             c.list_line_id                          = b.list_line_id                     AND
             c.product_attr_value                    = to_char(p_inventory_item_id)       AND
             trunc(nvl(b.end_date_active,sysdate))   >= trunc(p_ordered_date)             AND
             nvl(primary_uom_flag,'N')               ='Y';

     CURSOR c_vat_ass_value_other_uom_vend
                                     (
                                       p_vendor_id             NUMBER,
                                       p_address_id            NUMBER,
                                       p_inventory_item_id     NUMBER,
                                       p_ordered_date          DATE
                                     )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code
     FROM
             JAI_CMN_VENDOR_SITES a,
             qp_list_lines b,
             qp_pricing_attributes c
     WHERE
             a.vendor_id                    = p_vendor_id                    AND
             a.vendor_site_id               = p_address_id                   AND
             a.vat_price_list_id            = b.LIST_header_ID               AND
             c.list_line_id                 = b.list_line_id                 AND
             c.PRODUCT_ATTR_VALUE           = TO_CHAR(p_inventory_item_id)   AND
             NVL(b.end_date_active,SYSDATE) >= p_ordered_date;

  --------------------------------end, cursors for vendor--------------------------------------------------
     v_primary_uom_code qp_pricing_attributes.product_uom_code%type;
     v_other_uom_code   qp_pricing_attributes.product_uom_code%type;

     v_debug CHAR(1); -- := 'N'; --rpokkula for File.Sql.35
     v_address_id NUMBER;
     v_assessable_value NUMBER;
     v_conversion_rate NUMBER;
     v_price_list_uom_code CHAR(4);
     lv_object_name CONSTANT VARCHAR2 (61) := 'jai_general_pkg.ja_in_vat_assessable_value';

    -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
    ----------------------------------------------------------------------------------------------------------
    -- add for record down the release version by Xiao on 24-Jul-2009
    lv_release_name VARCHAR2(30);
    lv_other_release_info VARCHAR2(30);
    lb_result BOOLEAN := FALSE ;
    -- Get category_set_name
    CURSOR category_set_name_cur
    IS
    SELECT
      category_set_name
    FROM
      mtl_default_category_sets_fk_v
    WHERE functional_area_desc = 'Order Entry';

    lv_category_set_name  VARCHAR2(30);

    --Get the VAT Assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, Ordered date.
    CURSOR cust_ass_value_category_cur
    ( pn_party_id          NUMBER
    , pn_address_id        NUMBER
    , pn_inventory_item_id NUMBER
    , pv_uom_code          VARCHAR2
    , pd_ordered_date      DATE
    )
    IS
    SELECT
      b.operand          list_price
    , c.product_uom_code list_price_uom_code
    FROM
      jai_cmn_cus_addresses a
    , qp_list_lines         b
    , qp_pricing_attributes c
    WHERE a.customer_id        = pn_party_id
      AND a.address_id         = pn_address_id
      AND a.vat_price_list_id  = b.list_header_id
      AND c.list_line_id       = b.list_line_id
      AND c.product_uom_code   = pv_uom_code
      AND pd_ordered_date BETWEEN NVL( b.start_date_active, pd_ordered_date)
                              AND NVL( b.end_date_active, SYSDATE)
      AND EXISTS ( SELECT
                     'x'
                   FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

    --Get the VAT Assessable Value based on the Primary Uom, Customer Id, Address Id, inventory_item_id, Ordered date.
     CURSOR cust_ass_value_pri_uom_cur
     ( pn_party_id          NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code
     FROM
       jai_cmn_cus_addresses a
     , qp_list_lines         b
     , qp_pricing_attributes c
     WHERE a.customer_id                           = pn_party_id
       AND a.address_id                            = pn_address_id
       AND a.vat_price_list_id                     = b.list_header_id
       AND c.list_line_id                          = b.list_line_id
       AND TRUNC(NVL(b.end_date_active,SYSDATE))   >= TRUNC(pd_ordered_date)
       AND NVL(primary_uom_flag,'N')               ='Y'
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

    --Get the VAT Assessable Value based on the Customer Id, Address Id, inventory_item_id, Ordered date.
     CURSOR cust_ass_value_other_uom_cur
     ( pn_party_id          NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code
     FROM
       jai_cmn_cus_addresses a
     , qp_list_lines         b
     , qp_pricing_attributes c
     WHERE a.customer_id                         = pn_party_id
       AND a.address_id                          = pn_address_id
       AND a.vat_price_list_id                   = b.list_header_id
       AND c.list_line_id                        = b.list_line_id
       AND TRUNC(NVL(b.end_date_active,SYSDATE)) >= TRUNC(pd_ordered_date)
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );


     -- Get the VAT Assessable Value based on the Vendor Id, Address Id, inventory_item_id, uom code, Ordered date.
     CURSOR vend_ass_value_category_cur
     ( pn_vendor_id         NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pv_uom_code          VARCHAR2
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code
     FROM
       jai_cmn_vendor_sites  a
     , qp_list_lines         b
     , qp_pricing_attributes c
     WHERE a.vendor_id             = pn_vendor_id
       AND a.vendor_site_id        = pn_address_id
       AND a.vat_price_list_id     = b.list_header_id
       AND c.list_line_id          = b.list_line_id
       AND c.product_uom_code      = pv_uom_code
       AND pd_ordered_date    BETWEEN NVL( b.start_date_active, pd_ordered_date)
                                 AND NVL( b.end_date_active, SYSDATE)
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

     -- Get the VAT Assessable Value based on the Primary Uom, Vendor Id, Address Id, inventory_item_id, Ordered date.
     CURSOR vend_ass_value_pri_uom_cur
     ( pn_vendor_id         NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code
     FROM
       jai_cmn_vendor_sites  a
     , qp_list_lines         b
     , qp_pricing_attributes c
     WHERE a.vendor_id                             = pn_vendor_id
       AND a.vendor_site_id                        = pn_address_id
       AND a.vat_price_list_id                     = b.list_header_id
       AND c.list_line_id                          = b.list_line_id
       AND TRUNC(NVL(b.end_date_active,SYSDATE))   >= TRUNC(pd_ordered_date)
       AND NVL(primary_uom_flag,'N')               ='Y'
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

     -- Get the VAT Assessable Value based on the Vendor Id, Address Id, inventory_item_id, Ordered date.
     CURSOR vend_ass_value_other_uom_cur
     ( pn_vendor_id         NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code
     FROM
       jai_cmn_vendor_sites  a
     , qp_list_lines         b
     , qp_pricing_attributes c
     WHERE a.vendor_id                             = pn_vendor_id
       AND a.vendor_site_id                        = pn_address_id
       AND a.vat_price_list_id                     = b.list_header_id
       AND c.list_line_id                          = b.list_line_id
       AND TRUNC(NVL(b.end_date_active,SYSDATE))   >= TRUNC(pd_ordered_date)
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );
    ----------------------------------------------------------------------------------------------------------
    -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

BEGIN
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY :


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On

----------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------*/
        v_debug := jai_constants.NO ; --rpokkula for File.Sql.35
   -- Add by Xiao to get release version on 24-Jul-2009
   lb_result := fnd_release.get_release(lv_release_name, lv_other_release_info);

  -- Added by Jia for Advanced Pricing on 26-Jun-2009, Begin
  ----------------------------------------------------------------------------------------------------------
  -- Get category_set_name
  OPEN category_set_name_cur;
  FETCH category_set_name_cur INTO lv_category_set_name;
  CLOSE category_set_name_cur;
  ----------------------------------------------------------------------------------------------------------
  -- Added by Jia for Advanced Pricing on 26-Jun-2009, End


  IF p_party_type = 'C' THEN  --- Processing for Customer

    /******************************** Part 1 Get Customer address id ******************************/
        OPEN address_cur(p_party_site_id);
        FETCH address_cur INTO v_address_id;
        CLOSE address_cur;


        IF v_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log, 'v_address_id -> '|| v_address_id);
        END IF;


        ----------------------------------------------------------------------------------------------------------
        /*
        --Assessable Value Fetching Logic is based upon the following logic now.....
        --Each Logic will come into picture only if the preceding one does not get any value.
        --1. Assessable Value is picked up for the Customer Id, Address Id, UOM Code, inventory_item_id,Assessable value date
        --1.1. Assessable Value of item category is picked up for the Customer Id, Address Id, UOM Code, inventory_item_id,Assessable value date

        --2. Assessable Value is picked up for the Customer Id, Null Site, UOM Code, Assessable value date
        --2.1. Assessable Value of item category is picked up for the Customer Id, Null Site, UOM Code, Assessable value date

        --3. Assessable Value and Primary UOM is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
             for the Primary UOM defined in Price List.
             Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
             as the product of the Assessable value.
        --3.1. Assessable Value of item category and Primary UOM is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
             for the Primary UOM defined in Price List.
             Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
             as the product of the Assessable value.

        --4. Assessable Value is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
             on a first come first serve basis.
        --4.1. Assessable Value of item category is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
             on a first come first serve basis.

        --5. If all the above are not found then the initial logic of picking up the Assessable value is followed (Unit selling price)
             and then inv_convert.inv_um_conversion is called and the UOM rate is calculated and is included
             as the product of the Assessable value.
        */
        ----------------------------------------------------------------------------------------------------------


        -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
        ----------------------------------------------------------------------------------------------------------
        -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
        -- in the transaction. If yes, give an exception error message to stop transaction.
        -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN
        Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_party_id
                                                       , pn_party_site_id     => v_address_id
                                                       , pn_inventory_item_id => p_inventory_item_id
                                                       , pd_ordered_date      => TRUNC(p_ass_value_date)
                                                       , pv_party_type        => 'C'
                                                       , pn_pricing_list_id   => NULL
                                                       );
        END IF;
        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, End


       /********************************************* Part 2 ****************************************/

       /*
        Get the Assessable Value based on the Customer Id, Address Id, UOM Code, inventory_item_id,Ordered date
        Exact Match condition.
       */

        -- Fetch Assessable Price List Value for the given Customer and Location Combination
        OPEN c_vat_ass_value_cust( p_party_id, v_address_id, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date));
        FETCH c_vat_ass_value_cust INTO v_assessable_value, v_price_list_uom_code;
        CLOSE c_vat_ass_value_cust;

        -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
        ----------------------------------------------------------------------------------------------------------
     -- add condition by Xiao for specific release version for Advanced Pricing code on 24-Junl-2009
     IF lv_release_name NOT LIKE '12.0%' THEN
        IF v_assessable_value IS NULL
        THEN
          -- Fetch VAT Assessable Value of item category for the given Customer, Site, Inventory Item and UOM Combination
          OPEN cust_ass_value_category_cur( p_party_id
                                          , v_address_id
                                          , p_inventory_item_id
                                          , p_uom_code
                                          , TRUNC(p_ass_value_date)
                                          );
          FETCH
            cust_ass_value_category_cur
          INTO
            v_assessable_value
          , v_price_list_uom_code;
          CLOSE cust_ass_value_category_cur;
        END IF; -- v_assessable_value is null for given customer/site/inventory_item_id/UOM
      END IF;  --lv_release_name NOT LIKE '12.0%'
        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

       /********************************************* Part 3 ****************************************/

       /*
        Get the Assessable Value based on the Customer Id, Null Site, UOM Code, inventory_item_id,Ordered date
        Null Site condition.
       */

        IF v_assessable_value IS NULL THEN

          IF v_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,' Inside IF OF v_assessable_value IS NULL ');
          END IF;

          -- Added by Jia for Bug#8731811 on 30-Jul-2009, Begin
          ----------------------------------------------------------------------------------------------------------
          IF lv_release_name NOT LIKE '12.0%'
          THEN
            Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_party_id
                                                           , pn_party_site_id     => 0
                                                           , pn_inventory_item_id => p_inventory_item_id
                                                           , pd_ordered_date      => TRUNC(p_ass_value_date)
                                                           , pv_party_type        => 'C'
                                                           , pn_pricing_list_id   => NULL
                                                           );
          END IF;
          ----------------------------------------------------------------------------------------------------------
          -- Added by Jia for for Bug#8731811 on 30-Jul-2009, End

          -- Fetch Assessable Price List Value for the
          -- given Customer and NULL LOCATION Combination
          OPEN c_vat_ass_value_cust( p_party_id, 0, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date) );
          FETCH c_vat_ass_value_cust INTO v_assessable_value, v_price_list_uom_code;
          CLOSE c_vat_ass_value_cust;

          -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
          ----------------------------------------------------------------------------------------------------------
          -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
          IF lv_release_name NOT LIKE '12.0%' THEN
          IF v_assessable_value IS NULL
          THEN
            -- Fetch the VAT Assessable Value of item category
            -- for the given Customer, null Site, Inventory Item Id, UOM and Ordered date Combination.
            OPEN cust_ass_value_category_cur( p_party_id
                                            , 0
                                            , p_inventory_item_id
                                            , p_uom_code
                                            , TRUNC(p_ass_value_date)
                                            );
            FETCH
              cust_ass_value_category_cur
            INTO
              v_assessable_value
            , v_price_list_uom_code;
            CLOSE cust_ass_value_category_cur;
          END IF; -- v_assessable_value is null for given customer/null site/inventory_item_id/UOM
          END IF;  --lv_release_name NOT LIKE '12.0%'
          ----------------------------------------------------------------------------------------------------------
          -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

        END IF;

        IF v_debug = 'Y' THEN
          fnd_file.put_line(fnd_file.log, '2 v_assessable_value -> '||v_assessable_value||', v_price_list_uom_code -> '||v_price_list_uom_code);
        END IF;

       /********************************************* Part 4 ****************************************/

       /*
        Get the Assessable Value based on the Customer Id, Address id, inventory_item_id,primary_uom_code and Ordered date
        Primary UOM condition.
       */


        IF v_assessable_value is null THEN

          open c_vat_ass_value_pri_uom_cust
          (
            p_party_id,
            v_address_id,
            p_inventory_item_id,
            trunc(p_ass_value_date)
          );
            fetch c_vat_ass_value_pri_uom_cust into v_assessable_value,v_primary_uom_code;
            close c_vat_ass_value_pri_uom_cust;

          IF v_primary_uom_code is not null THEN

            inv_convert.inv_um_conversion
            (
              p_uom_code,
              v_primary_uom_code,
              p_inventory_item_id,
              v_conversion_rate
            );


            IF nvl(v_conversion_rate, 0) <= 0 THEN
              Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
              IF NVL(v_conversion_rate, 0) <= 0 THEN
                v_conversion_rate := 0;
              END IF;
            END IF;

            v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

          ELSE
            -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
            ----------------------------------------------------------------------------------------------------------
            -- Fetch the VAT Assessable Value of item category and Primary UOM
            -- for the given Customer, Site, Inventory Item Id, Ordered date Combination.
            -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
            IF lv_release_name NOT LIKE '12.0%' THEN
            OPEN cust_ass_value_pri_uom_cur( p_party_id
                                           , v_address_id
                                           , p_inventory_item_id
                                           , TRUNC(p_ass_value_date)
                                           );
            FETCH
              cust_ass_value_pri_uom_cur
            INTO
              v_assessable_value
            ,v_primary_uom_code;
            CLOSE cust_ass_value_pri_uom_cur;

            IF v_primary_uom_code IS NOT NULL
            THEN
              inv_convert.inv_um_conversion( p_uom_code
                                           , v_primary_uom_code
                                           , p_inventory_item_id
                                           , v_conversion_rate
                                           );

              IF NVL(v_conversion_rate, 0) <= 0
              THEN
                Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                IF NVL(v_conversion_rate, 0) <= 0
                THEN
                  v_conversion_rate := 0;
                END IF;
              END IF;

              v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;
            END IF; -- v_primary_uom_code IS NOT NULL for Customer/Site/Inventory_item_id
            END IF; -- lv_release_name NOT LIKE '12.0%'

            IF v_assessable_value IS NULL
            THEN
            ----------------------------------------------------------------------------------------------------------
            -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

              /* Primary uom code setup not found for the customer id, address id, inventory_item_id and ordered_date.
               Get the assessable value for a combination of customer id, address id, inventory_item_id
               and ordered_date. Pick up the assessable value by first come first serve basis.
              */

              OPEN c_vat_ass_value_other_uom_cust
                (
                  p_party_id,
                  v_address_id,
                  p_inventory_item_id,
                  trunc(p_ass_value_date)
                );
              FETCH c_vat_ass_value_other_uom_cust into v_assessable_value,v_other_uom_code;
              CLOSE c_vat_ass_value_other_uom_cust;

              IF v_other_uom_code is not null THEN
                inv_convert.inv_um_conversion
                  (
                    p_uom_code,
                    v_other_uom_code,
                    p_inventory_item_id,
                    v_conversion_rate
                  );

                IF nvl(v_conversion_rate, 0) <= 0 THEN

                  Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );

                  IF NVL(v_conversion_rate, 0) <= 0 THEN
                    v_conversion_rate := 0;
                  END IF;
                END IF;
                v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

              -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
              ----------------------------------------------------------------------------------------------------------
              ELSE
                -- Primary uom code setup not found for the Customer, Site, Inventory item id and Ordered_date.
                -- Fetch the VAT Assessable Value of item category and other UOM
                -- for the given Customer, Site, Inventory Item Id, Ordered date Combination.
                -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
                IF lv_release_name NOT LIKE '12.0%' THEN
                OPEN cust_ass_value_other_uom_cur( p_party_id
                                                  , v_address_id
                                                  , p_inventory_item_id
                                                  , TRUNC(p_ass_value_date)
                                                  );
                FETCH
                  cust_ass_value_other_uom_cur
                INTO
                  v_assessable_value
                , v_other_uom_code;
                CLOSE cust_ass_value_other_uom_cur;

                IF v_other_uom_code IS NOT NULL
                THEN
                  inv_convert.inv_um_conversion( p_uom_code
                                               , v_other_uom_code
                                               , p_inventory_item_id
                                               , v_conversion_rate
                                               );

                  IF NVL(v_conversion_rate, 0) <= 0
                  THEN
                    Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                    IF NVL(v_conversion_rate, 0) <= 0
                    THEN
                      v_conversion_rate := 0;
                    END IF;
                  END IF;

                  v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;
                END IF; -- v_other_uom_code is not null for Customer/Site/Inventory_item_id
                END IF; -- lv_release_name NOT LIKE '12.0%'
              ----------------------------------------------------------------------------------------------------------
              -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

              END IF; --end if for v_other_uom_code is not null
            END IF; -- v_assessable_value is null, Added by Jia for Advanced Pricing on 08-Jun-2009.
          END IF; --end if for v_primary_uom_code is not null
        END IF; --end if for v_assessable_value
        --Ends here..........................
        IF nvl(v_assessable_value,0) =0 THEN
          IF v_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,' No Assessable value is defined, so default price is returning back ');
          END IF;

          v_assessable_value  := NVL(p_default_price, 0);
        END IF;

        RETURN v_assessable_value;

  ELSIF p_party_type = 'V' THEN -- Processing for vendor

      /******************************** Part 1 Get Vendor address id ******************************/
           ----------------------------------------------------------------------------------------------------------
          /*
          --Assessable Value Fetching Logic is based upon the following logic now.....
          --Each Logic will come into picture only if the preceding one does not get any value.
          --1. Assessable Value is picked up for the Vendor Id, Address Id, UOM Code, inventory_item_id,Assessable value date
          --1.1. Assessable Value of item category is picked up for the Vendor Id, Address Id, UOM Code, inventory_item_id,Assessable value date

          --2. Assessable Value is picked up for the Vendor Id, Null Site, UOM Code, Assessable value date
          --2.1. Assessable Value of item category is picked up for the Vendor Id, Null Site, UOM Code, Assessable value date

          --3. Assessable Value and Primary UOM is picked up for the Vendor Id, Address Id, inventory_item_id,  Assessable value date
         for the Primary UOM defined in Price List.
         Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.
          --3.1. Assessable Value of item category and Primary UOM is picked up for the Vendor Id, Address Id, inventory_item_id,  Assessable value date
         for the Primary UOM defined in Price List.
         Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.

          --4. Assessable Value is picked up for the Vendor Id, Address Id, inventory_item_id,  Assessable value date
         on a first come first serve basis.
          --4.1. Assessable Value of item category is picked up for the Vendor Id, Address Id, inventory_item_id,  Assessable value date
         on a first come first serve basis.

          --5. If all the above are not found then the initial logic of picking up the Assessable value is followed (Unit selling price)
         and then inv_convert.inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.
          */
          ----------------------------------------------------------------------------------------------------------

        -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
        ----------------------------------------------------------------------------------------------------------
        -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
        -- in the transaction. If yes, give an exception error message to stop transaction.
        -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN
        Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_party_id
                                                       , pn_party_site_id     => p_party_site_id
                                                       , pn_inventory_item_id => p_inventory_item_id
                                                       , pd_ordered_date      => trunc(p_ass_value_date)
                                                       , pv_party_type        => 'V'
                                                       , pn_pricing_list_id   => NULL
                                                       );
        END IF;
        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, End


         /********************************************* Part 2 ****************************************/

         /*
          Get the Assessable Value based on the Vendor Id, Address Id, UOM Code, inventory_item_id,Ordered date
          Exact Match condition.
         */

          -- Fetch Assessable Price List Value for the given Vendor and Location Combination
          OPEN c_vat_ass_value_vend( p_party_id, p_party_site_id, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date));
          FETCH c_vat_ass_value_vend INTO v_assessable_value, v_price_list_uom_code;
          CLOSE c_vat_ass_value_vend;

          -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
          ----------------------------------------------------------------------------------------------------------
          -- add condition for specific release version for Advanced Pricing code
          IF lv_release_name NOT LIKE '12.0%' THEN
          IF v_assessable_value IS NULL
          THEN
            -- Fetch VAT Assessable Value of item category for the given Vendor, Site, Inventory Item Id and UOM Combination
            OPEN vend_ass_value_category_cur( p_party_id
                                            , p_party_site_id  -- Modify paramete from v_address_id to p_party_site_id for Bug#8743974 by Jia on 30-Jul-2009
                                            , p_inventory_item_id
                                            , p_uom_code
                                            , TRUNC(p_ass_value_date)
                                            );
            FETCH
              vend_ass_value_category_cur
            INTO
              v_assessable_value
            , v_price_list_uom_code;
            CLOSE vend_ass_value_category_cur;
          END IF; -- v_assessable_value is null for given vendor/site/inventory_item_id/UOM
          END IF; --lv_release_name NOT LIKE '12.0%'
          ----------------------------------------------------------------------------------------------------------
          -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

         /********************************************* Part 3 ****************************************/

         /*
          Get the Assessable Value based on the vendor Id, Null Site, UOM Code, inventory_item_id,Ordered date
          Null Site condition.
         */

          IF v_assessable_value IS NULL THEN

            IF v_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,' Inside IF OF v_assessable_value IS NULL ');
            END IF;

            -- Added by Jia for Bug#8731811 on 30-Jul-2009, Begin
            ----------------------------------------------------------------------------------------------------------
            IF lv_release_name NOT LIKE '12.0%'
            THEN
              Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_party_id
                                                             , pn_party_site_id     => 0
                                                             , pn_inventory_item_id => p_inventory_item_id
                                                             , pd_ordered_date      => trunc(p_ass_value_date)
                                                             , pv_party_type        => 'V'
                                                             , pn_pricing_list_id   => NULL
                                                             );
            END IF;
            ----------------------------------------------------------------------------------------------------------
            -- Added by Jia for Bug#8731811 on 30-Jul-2009, End

            -- Fetch Assessable Price List Value for the
            -- given Vendor and NULL LOCATION Combination
            /*OPEN c_vat_ass_value_cust( p_party_id, 0, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date) );
            FETCH c_vat_ass_value_cust INTO v_assessable_value, v_price_list_uom_code;
            CLOSE c_vat_ass_value_cust;*/ -- commented the above three lines for bug #6445020
            -- and introduced the following three lines(rchandan)
            OPEN c_vat_ass_value_vend( p_party_id, 0, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date) );
            FETCH c_vat_ass_value_vend INTO v_assessable_value, v_price_list_uom_code;
            CLOSE c_vat_ass_value_vend;

            -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
            ----------------------------------------------------------------------------------------------------------
            -- Fetch the VAT Assessable Value of item category
            -- for the given Vendor, null Site, Inventory Item Id, UOM and Ordered date Combination.
            -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
            IF lv_release_name NOT LIKE '12.0%' THEN
            OPEN vend_ass_value_category_cur( p_party_id
                                            , 0
                                            , p_inventory_item_id
                                            , p_uom_code
                                            , TRUNC(p_ass_value_date)
                                            );
            FETCH
              vend_ass_value_category_cur
            INTO
              v_assessable_value
            , v_price_list_uom_code;
            CLOSE vend_ass_value_category_cur;
            END IF; --lv_release_name NOT LIKE '12.0%'
            ----------------------------------------------------------------------------------------------------------
            -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

          END IF;

          IF v_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log, '2 v_assessable_value -> '||v_assessable_value||', v_price_list_uom_code -> '||v_price_list_uom_code);
          END IF;

         /********************************************* Part 4 ****************************************/

         /*
          Get the Assessable Value based on the Vendor Id, Address id, inventory_item_id,primary_uom_code and Ordered date
          Primary UOM condition.
         */


          IF v_assessable_value is null THEN

            open c_vat_ass_value_pri_uom_vend
            (
              p_party_id,
              p_party_site_id,
              p_inventory_item_id,
              trunc(p_ass_value_date)
            );
              fetch c_vat_ass_value_pri_uom_vend into v_assessable_value,v_primary_uom_code;
              close c_vat_ass_value_pri_uom_vend;

            IF v_primary_uom_code is not null THEN

              inv_convert.inv_um_conversion
                (
                  p_uom_code,
                  v_primary_uom_code,
                  p_inventory_item_id,
                  v_conversion_rate
                );


              IF nvl(v_conversion_rate, 0) <= 0 THEN
                Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                  v_conversion_rate := 0;
                END IF;
              END IF;

              v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

            ELSE
              -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
              ----------------------------------------------------------------------------------------------------------
              -- Fetch the VAT Assessable Value of item category and Primary UOM
              -- for the given Vendor, Site, Inventory Item Id, Ordered date Combination.
              -- Add condition for specific release version for Advanced Pricing code on 24-Junl-2009
              IF lv_release_name NOT LIKE '12.0%' THEN
              OPEN vend_ass_value_pri_uom_cur( p_party_id
                                             , p_party_site_id
                                             , p_inventory_item_id
                                             , TRUNC(p_ass_value_date)
                                             );
              FETCH
                vend_ass_value_pri_uom_cur
              INTO
                v_assessable_value
              , v_primary_uom_code;
              CLOSE vend_ass_value_pri_uom_cur;

              IF v_primary_uom_code IS NOT NULL
              THEN
                inv_convert.inv_um_conversion( p_uom_code
                                             , v_primary_uom_code
                                             , p_inventory_item_id
                                             , v_conversion_rate
                                             );

                IF NVL(v_conversion_rate, 0) <= 0
                THEN
                  Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                  IF NVL(v_conversion_rate, 0) <= 0
                  THEN
                    v_conversion_rate := 0;
                  END IF;
                END IF;

                v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

              END IF; --v_primary_uom_code IS NOT NULL for Vendor/Site/Inventory_Item_Id

              END IF; --lv_release_name NOT LIKE '12.0%'
              IF v_assessable_value IS NULL
              THEN
              ----------------------------------------------------------------------------------------------------------
              -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

              /* Primary uom code setup not found for the Vendor id, address id, inventory_item_id and ordered_date.
                 Get the assessable value for a combination of Vendor id, address id, inventory_item_id
                 and ordered_date. Pick up the assessable value by first come first serve basis.
              */

                OPEN c_vat_ass_value_other_uom_vend
                  (
                    p_party_id,
                    p_party_site_id,
                    p_inventory_item_id,
                    trunc(p_ass_value_date)
                  );
                FETCH c_vat_ass_value_other_uom_vend into v_assessable_value,v_other_uom_code;
                CLOSE c_vat_ass_value_other_uom_vend;

                IF v_other_uom_code is not null THEN
                  inv_convert.inv_um_conversion
                    (
                      p_uom_code,
                      v_other_uom_code,
                      p_inventory_item_id,
                      v_conversion_rate
                    );

                  IF nvl(v_conversion_rate, 0) <= 0 THEN

                    Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );

                    IF NVL(v_conversion_rate, 0) <= 0 THEN
                      v_conversion_rate := 0;
                    END IF;
                  END IF;
                  v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

                -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
                ----------------------------------------------------------------------------------------------------------
                ELSE
                  -- Primary uom code setup not found for the Vendor, Site, Inventory Item Id and Ordered_date.
                  -- Fetch the VAT Assessable Value of item category and other UOM
                  -- for the given Vendor, Site, Inventory Item Id, Ordered date Combination.
                  -- add condition for specific release version for Advanced Pricing code on 24-Junl-2009
                  IF lv_release_name NOT LIKE '12.0%' THEN
                  OPEN vend_ass_value_other_uom_cur( p_party_id
                                                    , p_party_site_id
                                                    , p_inventory_item_id
                                                    , TRUNC(p_ass_value_date)
                                                    );
                  FETCH
                    vend_ass_value_other_uom_cur
                  INTO
                    v_assessable_value
                  , v_other_uom_code;
                  CLOSE vend_ass_value_other_uom_cur;

                  IF v_other_uom_code IS NOT NULL
                  THEN
                    inv_convert.inv_um_conversion( p_uom_code
                                                 , v_other_uom_code
                                                 , p_inventory_item_id
                                                 , v_conversion_rate
                                                 );

                    IF NVL(v_conversion_rate, 0) <= 0
                    THEN
                      Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                      IF NVL(v_conversion_rate, 0) <= 0
                      THEN
                        v_conversion_rate := 0;
                      END IF;
                    END IF;

                    v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;
                  END IF; -- v_other_uom_code is not null for Vendor/Site/Inventory_item_id
                  END IF; --lv_release_name NOT LIKE '12.0%'
                ----------------------------------------------------------------------------------------------------------
                -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

                END IF; --end if for v_other_uom_code is not null
              END IF; -- v_assessable_value is null, Added by Jia for Advanced Pricing on 08-Jun-2009.
            END IF; --end if for v_primary_uom_code is not null
          END IF; --end if for v_assessable_value
          --Ends here..........................
          IF nvl(v_assessable_value,0) =0 THEN
          IF v_debug = 'Y' THEN
              fnd_file.put_line(fnd_file.log,' No Assessable value is defined, so default price is returning back ');
          END IF;

            v_assessable_value  := NVL(p_default_price, 0);
          END IF;

        RETURN v_assessable_value;
  END IF ;

EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;

END ja_in_vat_assessable_value;

END jai_general_pkg;

/

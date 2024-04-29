--------------------------------------------------------
--  DDL for Package Body JAI_CMN_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_UTILS_PKG" AS
/* $Header: jai_cmn_utils.plb 120.8.12010000.3 2010/06/07 08:02:18 jijili ship $ */

  /********************************************************************************************************
   FILENAME      : ja_in_util_pkg_b.sql

   Created By    : ssumaith

   Created Date  : 29-Nov-2004

   Bug           : 4033992

   Purpose       :  Check whether The India Localization functionality should be used or not.

   Called from   : All india Localization triggers on base APPS tables

   --------------------------------------------------------------------------------------------------------
   CHANGE HISTORY:
   --------------------------------------------------------------------------------------------------------
   S.No      Date          Author and Details
   --------------------------------------------------------------------------------------------------------
   1.        2004/11/29   ssumaith - bug# 4033992 - File version 115.0

                          created the package spec for the common utility which will be used to check
                          if India Localization funtionality is being used.

                          This function check_jai_exists is to be called from all India localization triggers.
                          The  parameter - p_calling_object is a mandatory one and will have the name of the
                          trigger which calls the package.
                          The other parameters are optional , but one of them needs to be passed.
                          The second parameter is inventory_organization_id
                          The Third Parameter  is Operating_unit
                          The fouth Parameter  is Set_of_books_id
                          The fifth and sixth parameters are for future use.
                          The fifth parameter - p_value_string has the values passed seperated by colons
                          The sixth parameter - p_format_string has the corresponding labels seperated by colons,
                          which inform what each value is.

                          Example call to the package can be :

                          JA_IN_UTIL.CHECK_JAI_EXISTS(
                                                      P_CALLING_OBJECT => 'TRIGGER NAME'          ,
                                                      P_ORG_ID         => :New.org_id             ,
                                                      P_Value_string   => 'OM:OE_ORDER_LINES_ALL' ,
                                                      p_format_string  => 'MODULE NAME:TABLE NAME'
                                                     );

2.     8-Jun-2005        File Version 116.2 jai_cmn_utils -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                         as required for CASE COMPLAINCE.

3.     14-Jun-2005      rchandan for bug#4428980, Version 116.3
                        Modified the object to remove literals from DML statements and CURSORS.
                        This activity is done as a part of R12 initiatives.

4.     14-Jun-2005      rchandan for bug#4428980, Version 116.4,
                        As part OF R12 Inititive Inventory conversion the OPM code IS commented

5      06-Jul-2005      rallamse for bug# PADDR Elimination
                        1. Removed the procedures ja_in_put_locator , ja_in_set_locator and ja_in_get_locator
                           from both the specification and body.

6.     12-Jul-2005       Sanjikum for Bug#4483042, Version 117.2
                         1) Added a new function validate_po_type

7.     22-Sep-2005       Ramananda for issue#76. Bug 4627086 . Version 120.2
                         Added not null columns in the insert statement of update_rg_slno procedure

8.     06-Dec-2005       rallamse for Bug#4773914, Version 120.2
                         1) Added a new function get_operating_unit
                         This function get_operating_unit returns operating unit based on
			 inventory organization id.


9.      27-Dec-2005  Bug 4906958. Added by Lakshmi Gopalsami Version 120.4
                           Derived the value for default LE if the value is not retrieved via
			   default BSV.

10.    26-FEB-2007   SSAWANT , File version 120.7
		     Forward porting the change in 11.5 bug 4903380 to R12 bug no 5039365 .
		     Added a function return_valid_date. This function would take varchar2 as input. If
                     this input is a date then it would return the same otherwise it would return NULL.
                     This function is currently used in JAINASST.rdf and JAINYEDE.rdf.

                     Dependency
                     ----------
                        Yes

 11    18-MAY-2007	Bgowrava for Bug#6053352 , file version 120.8
                    Modified the date related codes to satisfy the GSCC compilance.


12.     09-Mar-2010   Jia for GL Drilldown ER
              Add a new function if_IL_drilldown that is used to Enable/Disable drilldown button
              according OFI journal source and journal categories.

13.     07-Jun-2010  Modified by Jia for bug#9736876
              Issue: TAXES POSTED TO PLA IN FOREIGN CURRENCY
                Fix: Modified the return value in function currency_conversion.

  *********************************************************************************************************/
  FUNCTION get_currency_code(p_operating_unit_id HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE) RETURN VARCHAR2 IS
    /* Bug 5243532. Added by Lakshmi Gopalsami.
       Removed the cursor c_set_of_books and c_sob_currency
       and implemented using caching logic.
     */

    ln_set_of_books_id       GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE;
    lv_sob_currency_code     GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE  ;

    /* Bug 5243532. Added by Lakshmi Gopalsami.
       Defined local variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

  BEGIN
      /* Bug 5243532. Added by Lakshmi Gopalsami
         Removed the reference to cursor and implemented
	 caching logic.
       */
      l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_operating_unit_id );

      ln_set_of_books_id   := l_func_curr_det.ledger_id;
      lv_sob_currency_code := l_func_curr_det.currency_code;

      RETURN(lv_sob_currency_code);
  END get_currency_code;

  FUNCTION check_jai_exists(p_calling_object      VARCHAR2                                                   ,
                            p_inventory_orgn_id   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE    DEFAULT NULL ,
                            p_org_id              HR_OPERATING_UNITS.ORGANIZATION_ID%TYPE       DEFAULT NULL ,
                            p_set_of_books_id     GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE         DEFAULT NULL ,
                            p_value_string        VARCHAR2                                      DEFAULT NULL ,
                            p_format_string       VARCHAR2                                      DEFAULT NULL
                           ) RETURN BOOLEAN
  IS
    /* Bug 5243532. Added by Lakshmi Gopalsami
       Removed the cursor c_set_of_books and c_operating_unit
       which is referring to hr_operating_units
       and org_organization_definitions. Replaced the same with caching logic.
       Replaced gl_sets_of_books with gl_ledgers
     */
    CURSOR c_sob_currency (cp_set_of_books_id GL_SETS_OF_BOOKS.SET_OF_BOOKS_ID%TYPE) IS
    SELECT currency_code
    FROM   gl_ledgers
    WHERE  ledger_id  = cp_set_of_books_id;

    lv_sob_currency_code          GL_SETS_OF_BOOKS.CURRENCY_CODE%TYPE;
    lv_calling_object             VARCHAR2(50);
    lv_message_text               VARCHAR2(3000);

    /* Bug 5243235. Added by Lakshmi Gopalsami
       Defined variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

  BEGIN
    /*
      If the mandatory parameter p_calling_object is not passed, then returning  false value so that no further processing needs
      to be done.
    */

    IF p_calling_object IS NULL  THEN
       return(false);
    END IF;

    /*
     set of books id is passed. Get the currency code from the gl_sets_of_books and return true or false
     depending on the curreny code = 'INR' or not.
    */
    IF  p_set_of_books_id IS NOT NULL THEN
      OPEN  c_sob_currency(p_set_of_books_id);
      FETCH c_sob_currency INTO lv_sob_currency_code;
      CLOSE c_sob_currency;

      IF lv_sob_currency_code = 'INR' THEN
        RETURN(TRUE);
      ELSE
        RETURN(FALSE);
      END IF;
    END IF;

    /* Bug 5243532. Added by Lakshmi Gopalsami
       Removed the existing code for deriving the SOB.
      Implemented using caching logic.
    */
    IF  p_org_id IS NOT NULL THEN
       l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_org_id );

    ELSIF  p_inventory_orgn_id IS NOT NULL THEN
       l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_inventory_orgn_id );
    END IF;
    lv_sob_currency_code := l_func_curr_det.currency_code;
    IF lv_sob_currency_code = 'INR' THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;

    /*
     The final return(false) below is to trap the case where none of the parameters p_inventory_orgn_id, p_org_id
     or p_set_of_books_id is passed.
    */

    RETURN(FALSE);
  EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001,'Unexpected Error in ja_in_util.check_jai_exists, called from ' || p_calling_object || ' The error is ' || sqlerrm);
  END check_jai_exists;
/*5039365 by ssawant*/
  FUNCTION return_valid_date( p_validate_text VARCHAR2 ) RETURN DATE IS
	ld_ret_value DATE;
	BEGIN
	  ld_ret_value := to_date( p_validate_text,'DD/MM/RRRR');
	  return ld_ret_value;
	EXCEPTION
	  when others then
	   return NULL;
  END return_valid_date;

FUNCTION get_operating_unit (
                              p_calling_object      VARCHAR2                                      ,
                              p_inventory_orgn_id   ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_ID%TYPE
                            ) RETURN NUMBER
IS
  CURSOR c_operating_unit IS
  SELECT operating_unit
  FROM   org_organization_definitions
  WHERE  organization_id = p_inventory_orgn_id;

  ln_operating_unit_id          ORG_ORGANIZATION_DEFINITIONS.OPERATING_UNIT%TYPE;

BEGIN
  /*
  || If the mandatory parameter p_calling_object is not passed, then returning
  || false value so that no further processing needs to be done.
  */
  IF p_calling_object IS NULL OR p_inventory_orgn_id IS NULL THEN
     return (-1) ;
  END IF;

  /*
  || Based on the inventory organization info , get the associated operating unit
  */
  OPEN  c_operating_unit;
  FETCH c_operating_unit INTO ln_operating_unit_id;
  CLOSE c_operating_unit;

  IF ln_operating_unit_id IS NULL THEN
    RETURN (-1);
  ELSE
    RETURN ( ln_operating_unit_id );
  END IF ;

EXCEPTION

 WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR (  -20001,
                              'Unexpected Error in ja_in_util.get_operating_unit, called from ' || p_calling_object || ' The error is ' || sqlerrm
                           );

END get_operating_unit ;

PROCEDURE update_rg_slno(
    pn_organization_id  IN  NUMBER,
    pn_location_id      IN  NUMBER,
    pv_register_type    IN  VARCHAR2,
    pn_fin_year         IN  NUMBER,
    pn_txn_amt          IN  NUMBER,
    pn_slno OUT NOCOPY NUMBER,
    pn_opening_balance OUT NOCOPY NUMBER,
    pn_closing_balance OUT NOCOPY NUMBER

  ) IS
    ln_fin_year     NUMBER;
    ln_slno       NUMBER;
    ln_closing_balance  NUMBER;

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_utils_pkg.update_rg_slno';


    PROCEDURE insert_record(
            pn_organization_id  NUMBER,
            pn_location_id      NUMBER,
            pn_current_fin_year NUMBER,
            pv_register_type    VARCHAR2)
    IS
      PRAGMA autonomous_transaction;
    BEGIN
--Issue#76. 4627086
      INSERT INTO JAI_CMN_RG_SLNOS
        (organization_id, location_id, current_fin_year, register_type, slno, balance,created_by, creation_date, last_updated_by, last_update_date )
      VALUES
        (pn_organization_id, pn_location_id, pn_current_fin_year, pv_register_type, 0, 0, fnd_global.user_id  , sysdate, fnd_global.user_id  , sysdate);

      COMMIT;

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        null;
    END insert_record;

  BEGIN

    UPDATE  JAI_CMN_RG_SLNOS
    SET     slno            = NVL(slno,0) + 1,
            balance         = NVL(balance,0) + pn_txn_amt
    WHERE   register_type   = pv_register_type
    AND     organization_id = pn_organization_id
    AND     location_id     = pn_location_id
    RETURNING slno, balance, current_fin_year INTO ln_slno, ln_closing_balance, ln_fin_year;

    IF SQL%NOTFOUND THEN

      insert_record(pn_organization_id, pn_location_id, pn_fin_year, pv_register_type);

      UPDATE  JAI_CMN_RG_SLNOS
      SET     slno            = NVL(slno,0) + 1,
              balance         = NVL(balance,0) + pn_txn_amt
      WHERE   register_type   = pv_register_type
      AND     organization_id = pn_organization_id
      AND     location_id     = pn_location_id
      RETURNING slno, balance, current_fin_year INTO ln_slno, ln_closing_balance, ln_fin_year;

    ELSIF ln_fin_year <> pn_fin_year THEN

      UPDATE  JAI_CMN_RG_SLNOS
      SET     slno        = 1,
              current_fin_year  = pn_fin_year
      WHERE   register_type     = pv_register_type
      AND     organization_id   = pn_organization_id
      AND     location_id       = pn_location_id
      RETURNING slno, current_fin_year INTO ln_slno, ln_fin_year;

    END IF;

    pn_slno            := ln_slno;
    pn_opening_balance := ln_closing_balance - pn_txn_amt;
    pn_closing_balance := ln_closing_balance;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      pn_opening_balance := null;
      pn_closing_balance := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END update_rg_slno;


  FUNCTION currency_conversion (c_set_of_books_id In Number,
                              c_from_currency_code In varchar2,
                              c_conversion_date in date,
                              c_conversion_type in varchar2,
                              c_conversion_rate in number) return number is
  v_func_curr varchar2(15);
  ret_value number;

  Cursor currency_code_cur IS
  Select currency_code from gl_sets_of_books
  where set_of_books_id = c_set_of_books_id;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_utils_pkg.currency_conversion';

Begin
  -- Bug 5148770. Added by Lakshmi Gopalsami

  print_log('jai_cmn_utils_pkg.currency_conversion.log',' SOB'|| c_set_of_books_id);

  Open  currency_code_cur;
  Fetch currency_code_cur Into v_func_curr;
  Close currency_code_cur;

  -- Bug 5148770. Added by Lakshmi Gopalsami

  print_log('jai_cmn_utils_pkg.currency_conversion.log',' Func curr '|| v_func_curr);
  print_log('jai_cmn_utils_pkg.currency_conversion.log', 'FROM curr code '|| c_from_currency_code);

  If NVL(v_func_curr,'NO') = c_from_currency_code Then
  -- Bug 5148770. Added by Lakshmi Gopalsami
   print_log('jai_cmn_utils_pkg.currency_conversion.log',
        ' func curr and from curr same - return 1');

    ret_value := 1;

  Elsif upper(c_conversion_type) = 'USER' Then
    -- Bug 5148770. Added by Lakshmi Gopalsami
    print_log('jai_cmn_utils_pkg.currency_conversion.log',
            ' User entered the rate - return '|| c_conversion_rate);
    ret_value := c_conversion_rate;

  Else

    Declare

     v_frm_curr Varchar2(10) := c_from_currency_code ; -- added by Subbu, Sri on 02-NOV-2000

     v_dr_type Varchar2(20);                          -- added by Subbu, Sri on 02-NOV-2000

  -- Cursor for checking currency whether derived from Euro Derived / Euro Currency or not
  -- added by Subbu, Sri on 02-NOV-2000

     CURSOR Chk_Derived_Type_Cur IS SELECT Derive_type FROM Fnd_Currencies
                                    WHERE Currency_Code in (v_frm_curr);
     /*  Bug 5148770. Added by Lakshmi Gopalsami
         Changed the select to get the rate into cursor.
     */
     CURSOR get_curr_rate(p_to_curr IN  varchar2,
                          p_from_curr   IN varchar2) IS
       SELECT Conversion_Rate
         FROM Gl_Daily_Rates
        WHERE To_Currency = p_to_curr
	  and From_Currency = p_from_curr
	  and trunc(Conversion_Date) = trunc(nvl(c_conversion_date,sysdate))
	  and Conversion_Type = c_conversion_type;

    Begin

      OPEN Chk_Derived_Type_Cur;
        FETCH Chk_Derived_Type_Cur INTO v_dr_type;
      CLOSE Chk_Derived_Type_Cur;

      -- Bug 5148770. Added by Lakshmi Gopalsami
    print_log('jai_cmn_utils_pkg.currency_conversion.log',
              ' derived type '|| v_dr_type);

     IF v_dr_type IS NULL THEN

      -- If currency is not derived from Euro derived / Euro Currency  by Subbu, Sri on 02-NOV-2000
      /* Bug 5148770. Added by Lakshmi Gopalsami
         Removed the select and changed the same into a cursor.
      */
      OPEN get_curr_rate(v_func_curr,v_frm_curr);
        FETCH get_curr_rate INTO ret_value;
      CLOSE get_curr_rate;

      -- Bug 5148770. Added by Lakshmi Gopalsami
      print_log('jai_cmn_utils_pkg.currency_conversion.log',
                ' derive type null - return value '|| ret_value);
     ELSE

       IF v_dr_type in('EMU','EURO') THEN

        -- If currency is derived from Euro derived / Euro Currency  by Subbu, Sri on 02-NOV-2000

        v_frm_curr := 'EUR';

	 /* Bug 5148770. Added by Lakshmi Gopalsami
	    Removed the select and changed the same into a cursor.
	  */
	  OPEN get_curr_rate(v_func_curr,v_frm_curr);
	    FETCH get_curr_rate INTO ret_value;
	  CLOSE get_curr_rate;

	   -- Bug 5148770. Added by Lakshmi Gopalsami
           print_log('jai_cmn_utils_pkg.currency_conversion.log',
                ' EURO/EMU - derive type  - return value '|| ret_value);
       END IF;

     END IF;

    Exception When Others Then
--old code      ret_value := 1;
    RAISE_APPLICATION_ERROR(-20120,'Currency Conversion Rate Not Defined In The System');
    End;
  End If;
  -- Modified by Jia for bug#9736876, Begin
  ----------------------------------------------
  -- Return(nvl(ret_value,1)); --Commented by Jia for bug#9736876
  Return (ret_value);
  ----------------------------------------------
  -- Modified by Jia for bug#9736876, End



   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

End currency_conversion;


PROCEDURE print_log (
        filename    VARCHAR2,
        text_to_write   VARCHAR2
           ) IS
v_myfilehandle  UTL_FILE.FILE_TYPE;
v_utl_location  VARCHAR2(40)      ;
lv_name varchar2(30);
BEGIN
  lv_name  := 'utl_file_dir';  --rchandan for bug#4428980
  SELECT
    decode(substr (value,1,instr(value,',') -1) ,
    null                        ,
    value                       ,
    substr (value,1,instr(value,',') -1))
  INTO
    v_utl_location
  FROM
    v$parameter
  WHERE
    name = lv_name;  --rchandan for bug#4428980

  v_myfilehandle := utl_file.fopen(v_utl_location,filename,'A');

  utl_file.put_line(v_myfilehandle,text_to_write);

  utl_file.fclose(v_myfilehandle);

EXCEPTION
  WHEN OTHERS THEN
      Null;
END print_log;
--rchandan for bug#4428980
--As part OF R12 Inititive Inventory conversion the OPM code IS commented
/*FUNCTION opm_uom_version(from_uom varchar2,to_uom varchar2,p_item_id number) RETURN NUMBER IS
  f_uom_type varchar2(20);
  t_uom_type varchar2(20);
  f_ref_um   varchar2(20);
  t_ref_um   varchar2(20);
  l_std_factor number;
  l_std_factor_t number;
  l_std_factor_typ_1 number;
  l_item_um   varchar2(20);
  x number;
  y number;
  z number;
  CURSOR C_Uom_Type(p_uom_code varchar2) IS Select upper(um_type),upper(ref_um) From sy_uoms_mst
                      Where upper(um_code) = upper(p_uom_code);
  CURSOR C_Conv_Val(p_uom_code varchar2) IS
                Select std_factor From sy_uoms_mst
                Where um_code = p_uom_code;
  CURSOR C_Uom_Type_Conv(p_uom_type varchar2) IS
                Select type_factor From ic_item_cnv
                Where um_type = p_uom_type and
                                      item_id = p_item_id;
  CURSOR C_Item_Um(p_item_id number) IS
                Select item_um From ic_item_mst
                Where item_id = p_item_id;

  Added by Ramananda for bug#4407165
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_utils_pkg.opm_uom_version';

BEGIN
  OPEN C_Uom_Type(from_uom);
  FETCH C_Uom_Type INTO f_uom_type,f_ref_um;
  CLOSE C_Uom_Type;
  OPEN C_Uom_Type(to_uom);
  FETCH C_Uom_Type INTO t_uom_type,t_ref_um;
  CLOSE C_Uom_Type;
  OPEN C_Conv_Val(from_uom);
  FETCH C_Conv_Val INTO l_std_factor;
  CLOSE C_Conv_Val;
  OPEN C_Conv_Val(to_uom);
  FETCH C_Conv_Val INTO l_std_factor_t;
  CLOSE C_Conv_Val;
  IF f_uom_type = t_uom_type THEN
    IF from_uom = to_uom THEN
      return(1);
    ELSIF  from_uom = f_ref_um THEN
        return(1/l_std_factor_t);
    ELSIF  to_uom = t_ref_um THEN
        return(l_std_factor);
    ELSE

        return(round((l_std_factor/l_std_factor_t),9));
    END IF;
  ELSE
    OPEN C_Uom_Type_Conv(t_uom_type);
    FETCH C_Uom_Type_Conv INTO l_std_factor_typ_1;
    CLOSE C_Uom_Type_Conv;
    OPEN C_Item_Um(p_item_id);
    FETCH C_Item_Um INTO l_item_um;
    CLOSE C_Item_Um;
    IF l_item_um = from_uom THEN
      IF from_uom = f_ref_um  AND to_uom = t_ref_um THEN
        return(l_std_factor_typ_1);
      ELSIF from_uom = f_ref_um AND to_uom <> t_ref_um THEN
        return(round((1/(l_std_factor_typ_1*l_std_factor_t)),9));
      ELSIF to_uom = t_ref_um AND from_uom <> f_ref_um THEN
        return(round((l_std_factor/l_std_factor_typ_1),2));
      ELSE
        return(round((l_std_factor/(l_std_factor_typ_1*l_std_factor_t)),9));
      END IF;
    ELSIF l_item_um = to_uom THEN
      x:= jai_cmn_utils_pkg.opm_uom_version(to_uom,from_uom,p_item_id);
    IF x = 0 THEN
      return(x);
      ELSE
        return(1/x);
      END IF;
    ELSE
    x := jai_cmn_utils_pkg.opm_uom_version(l_item_um,from_uom,p_item_id);
    y := jai_cmn_utils_pkg.opm_uom_version(l_item_um,to_uom,p_item_id);
      IF x > 0 THEN
        z := y/x;
      ELSE
      z := 0;
    END IF;
    return(z);
    END IF;
  END IF;


   -- Added by Ramananda for bug#4407165
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

End opm_uom_version;


FUNCTION get_opm_assessable_value(p_item_id number,p_qty number,p_exted_price number,P_Cust_Id Number Default 0 ) RETURN NUMBER IS
    Cursor C_Item_Dtl IS
        Select excise_calc_base -- , assessable_value (Commented as Assessable Value is picked by other conditions now )
        From JAI_OPM_ITM_MASTERS
        Where item_id = p_item_id;

        -- Added by Ramananda for bug#4407165
        lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_utils_pkg.get_opm_assessable_value';

---Added For OPM Localization By A.Raina on 22-02-2000
---Code Added For Fetching the Assessable_value at the customer level

    Cursor C_Price_list_id is
    Select Pricelist_Id
      From JAI_OPM_CUSTOMERS
     Where Cust_id = p_cust_id ;

    Cursor C_Cust_Ass_Value ( p_Pricelist_Id In Number ) is
    Select a.Base_Price
      From Op_Prce_Itm a ,op_prce_eff b
     Where a.pricelist_id = b.pricelist_id
       And a.Pricelist_Id = p_Pricelist_id
       And a.Item_Id      = p_item_id
       And sysdate between nvl(start_date, sysdate) and nvl(end_date, sysdate) ;

    CURSOR C_item_Ass_Value IS
    Select assessable_value
      From JAI_OPM_ITM_MASTERS
     Where item_id = p_item_id;

    v_pricelist_id  Number;
    v_assessable_flag char(1) ;
--End Addition
    l_assessable_val number;
    l_excise_cal varchar2(1);
  BEGIN

---Added For OPM Localization By A.Raina on 22-02-2000
---Code Added For Fetching the Assessable_value at the customer level

     OPEN C_Price_list_id ;
    FETCH C_Price_list_id into v_pricelist_id;
    CLOSE C_Price_list_id ;

    l_assessable_val := Null ;
   IF v_pricelist_id is Not Null Then
     OPEN  C_Cust_Ass_Value (v_pricelist_id ) ;
     FETCH C_Cust_Ass_Value into l_assessable_val ;
     CLOSE C_Cust_Ass_Value ;
   End If;
   IF l_assessable_val Is Null Then
     OPEN  C_item_Ass_Value ;
     FETCH C_item_Ass_Value into l_assessable_val ;
     CLOSE C_item_Ass_Value ;
   End If;

---End Addition

    OPEN C_Item_Dtl;
    FETCH C_Item_Dtl  INTO l_excise_cal ; -- l_assessable_val (Commented as Assessable Value is picked by other conditions now )
    CLOSE C_Item_Dtl ;

    IF NVL(l_excise_cal,'N') = 'Y' THEN
      Return(l_assessable_val*p_qty);
    ELSE
      Return(p_exted_price);
    END IF;

  -- Added by Ramananda for bug#4407165
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_opm_assessable_value;*/


procedure get_le_info
(
p_api_version             IN    NUMBER             ,
p_init_msg_list           IN    VARCHAR2           ,
p_commit                  IN    VARCHAR2           ,
p_ledger_id               IN    NUMBER             ,
p_bsv                     IN    VARCHAR2           ,
p_org_id                  IN    NUMBER             ,
x_return_status           OUT   NOCOPY  VARCHAR2   ,
x_msg_count               OUT   NOCOPY  NUMBER     ,
x_msg_data                OUT   NOCOPY  VARCHAR2   ,
x_legal_entity_id         OUT   NOCOPY  NUMBER     ,
x_legal_entity_name       OUT   NOCOPY  VARCHAR2
)
IS
ln_legal_entity_id  NUMBER;
CURSOR c_get_le_info is
SELECT XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_org_id)
FROM dual;

  /* Bug 4906958. Added by Lakshmi Gopalsami
      Get the value of legal entity from hr_operating_units
      if the above cursor is returning null.
  */
  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the cursor c_get_default_LE_id which
     is referring  to hr_operating_units
     and replaced with caching logic.
     Defined variable for implementing caching logic.
   */

   l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

BEGIN

IF p_ledger_id IS NOT NULL AND p_bsv IS NOT NULL THEN


   XLE_UTILITIES_GRP.Get_LegalEntity_LGER_BSV
   (
   p_api_version         ,
   p_init_msg_list   ,
   p_commit    ,
   x_return_status       ,
   x_msg_count     ,
   x_msg_data    ,
   p_ledger_id           ,
   p_bsv     ,
   x_legal_entity_id     ,
   x_legal_entity_name
   );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   RETURN;

END IF;

IF p_org_id IS NOT NULL THEN
   OPEN  c_get_le_info;
   FETCH c_get_le_info INTO   ln_legal_entity_id;
   CLOSE c_get_le_info;

  /* Bug 4906958. Added by Lakshmi Gopalsami
      If ln_legal_entity_id is null fetch the legal entity id
      from the default_legal_context_id from hr_operating_units
  */

  /* Bug 5243532. Added by Lakshmi Gopalsami
     Removed the cursor c_get_default_LE_id and implemented using
     cache logic.
   */

  If nvl(ln_legal_entity_id,-1) = -1 THEN
   l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_org_id);
   ln_legal_entity_id := l_func_curr_det.legal_entity;

  END IF;

   x_legal_entity_id := ln_legal_entity_id;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   RETURN;
END IF;


x_return_status := FND_API.G_RET_STS_ERROR;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END  get_le_info;


FUNCTION validate_po_type(p_po_type 		IN 	VARCHAR2	DEFAULT NULL,
			  p_style_id		IN	NUMBER		DEFAULT NULL,
			  p_po_header_id	IN	NUMBER		DEFAULT NULL
		   ) RETURN BOOLEAN

IS
	CURSOR	c_doc_style_headers(cp_style_id NUMBER)
	IS
	SELECT	progress_payment_flag
	FROM 	po_doc_style_headers
	WHERE 	style_id = cp_style_id;

	CURSOR	c_po_headers(cp_po_header_id NUMBER)
	IS
	SELECT	style_id
	FROM 	po_headers_all
	WHERE 	po_header_id = cp_po_header_id;

	r_doc_style_headers 	c_doc_style_headers%ROWTYPE;
	r_po_headers		c_po_headers%ROWTYPE;
	b_process_po		BOOLEAN;
	v_style_id		po_headers_all.style_id%TYPE;
BEGIN
	v_style_id := p_style_id;

	IF v_style_id IS NULL AND p_po_header_id IS NOT NULL THEN
		OPEN c_po_headers(p_style_id);
		FETCH c_po_headers INTO r_po_headers;
		CLOSE c_po_headers;

		v_style_id := r_po_headers.style_id;
	END IF;

	OPEN c_doc_style_headers(v_style_id);
	FETCH c_doc_style_headers INTO r_doc_style_headers;
	CLOSE c_doc_style_headers;

	--if progess_payment_flag = 'Y', then it is a complex work PO
	IF NVL(r_doc_style_headers.progress_payment_flag,'N') = 'Y' THEN
		b_process_po := FALSE;
	ELSE
		b_process_po := TRUE;
	END IF;

	RETURN b_process_po;
END validate_po_type;


--==========================================================================
--  FUNCTION NAME:
--
--    if_IL_drilldown                      Public
--
--  DESCRIPTION:
--
--    This function is used to Enable/Disable drilldown buttion
--    according OFI journal source and journal categories.
--
--  PARAMETERS:
--      In:  pn_je_source           Identifier of journal source
--           pn_je_category         Identifier of journal category
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_4_GL_Drilldown_V0.4.docx
--
--  CHANGE HISTORY:
--
--           09-Mar-2010   Jia Li   created
--==========================================================================
FUNCTION if_IL_drilldown (
   pn_je_source           VARCHAR2
 , pn_je_category         VARCHAR2
 ) RETURN BOOLEAN
IS
  lb_drilldown_flag   BOOLEAN := FALSE;
  lv_je_source  varchar2(100);
  lv_je_category varchar2(100);

  CURSOR get_user_source IS
  select user_je_source_name
  from gl_je_sources gjs
  where gjs.je_source_name = pn_je_source;

  CURSOR get_user_category IS
  select user_je_category_name
  from gl_je_categories gjc
  where gjc.je_category_name = pn_je_category;

BEGIN

  OPEN get_user_source;
  FETCH get_user_source INTO lv_je_source;
  CLOSE get_user_source;

  OPEN get_user_category;
  FETCH get_user_category INTO lv_je_category;
  CLOSE get_user_category;

  IF ((lv_je_source = 'Receivables India') AND (lv_je_category = 'Register India'))
       OR
      ((lv_je_source = 'Projects India') AND (lv_je_category = 'Register India'))
       OR
      ((lv_je_source = 'Inventory India') AND (lv_je_category = 'MTL'))
       OR
      ((lv_je_source = 'Payables India') AND (lv_je_category IN ('Bill of Entry India','Payments')))
       OR
      ((lv_je_source = 'Payables') AND (lv_je_category = 'BOE'))
       OR
      ((lv_je_source = 'Purchasing India') AND (lv_je_category IN ('Receiving India','OSP Issue India','OSP Receipt India', 'MMT')))
       OR
      ((lv_je_source = 'Register India') AND (lv_je_category IN ('Inventory India','VAT India','Register India')))
       OR
      ((lv_je_source IN ('VAT India','Service Tax India')) AND (lv_je_category = 'Register India'))
       OR
      ((lv_je_source = 'India Tax Collected') AND (lv_je_category = 'Receivalbes India'))
  THEN
     lb_drilldown_flag := TRUE;
  END IF;

  RETURN ( lb_drilldown_flag );

END if_IL_drilldown;


END jai_cmn_utils_pkg;

/

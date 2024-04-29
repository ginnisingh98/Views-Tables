--------------------------------------------------------
--  DDL for Package Body JAI_INV_MMT_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_INV_MMT_TRIGGER_PKG" AS
/* $Header: jai_inv_mmt_t.plb 120.5.12010000.8 2010/04/28 12:17:02 vkaranam ship $ */

/*
  REM +======================================================================+
  REM NAME          ARI_T1
  REM
  REM DESCRIPTION   Called from trigger JAI_INV_MMT_ARIUD_T1
  REM
  REM NOTES         Refers to old trigger JAI_INV_MMT_ARI_T1
  REM
  REM +======================================================================+
*/
  PROCEDURE ARI_T1 ( pr_old t_rec%type , pr_new t_rec%type , pv_action varchar2 , pv_return_code out nocopy varchar2 , pv_return_message out nocopy varchar2 ) IS
    v_excise_flag               CHAR;
    v_item_class                VARCHAR2 (4);
    v_f_year                    NUMBER (4);
    v_srno                      NUMBER (15);
    v_range_no                  VARCHAR2 (50);
    v_division_no               VARCHAR2 (50);
    v_opening_qty               NUMBER;
    v_closing_qty               NUMBER;
    v_op_qty                    NUMBER;
    v_cl_qty                    NUMBER;
    v_reg_type                  CHAR;
    v_trans_qty                 NUMBER;
    v_mis_qty                   NUMBER; ---added by Sriram on 04-may-01
    v_t_qty                     NUMBER;
    v_sr_no                     NUMBER;
    v_t_type                    VARCHAR2 (10);
    v_iss_qty                   NUMBER;
    v_iss_id                    VARCHAR2 (30); -- modified by subbu and sri on 28-nov-00
    v_rec_qty                   NUMBER;
    v_rec_id                    VARCHAR2 (30);
    v_iss_date                  DATE;
    v_rec_date                  DATE;
    v_loc_id                    NUMBER (15);
    v_bonded_curr               VARCHAR2 (50);
    v_manufactured_qty          NUMBER;
    v_manufactured_pack_qty     NUMBER;
    v_oth_pur_npe_qty           NUMBER;
    v_temp_item_class           VARCHAR2 (4);
    v_temp_excise_flag          CHAR;
    v_temp_loc_id               NUMBER;
    v_count_temp                NUMBER;
    v_temp_subinv_code          VARCHAR2 (20);
    v_temp_organization_id      NUMBER;
    v_temp_trans_qty            NUMBER;
    v_temp_inv_item_id          NUMBER;
    v_bonded_temp               VARCHAR2 (50);
    v_ins_from_temp_flag        NUMBER        := 0;
    v_ins_from_curr_flag        NUMBER        := 0;
    v_temp_trans_type_id        NUMBER;
    v_temp_trans_date           DATE;
    v_temp_trans_uom            VARCHAR2 (3);
    v_temp_range_no             VARCHAR2 (50);
    v_temp_division_no          VARCHAR2 (50);
    v_insert_flag               NUMBER        := 0;
    v_rg23_flag                 NUMBER        := 0;
    v_rg_flag                   NUMBER        := 0;
    v_manu_pkd_qty              NUMBER;
    v_manu_loose_qty            NUMBER;
    v_oth_purpose               VARCHAR2 (30);
    v_bal_packed                NUMBER;
    v_bal_loose                 NUMBER;
    v_pr_uom_code               VARCHAR2 (3);
    v_temp_pr_uom_code          VARCHAR2 (3);
    v_uom_qty                   NUMBER;
    v_pr_uom_class              VARCHAR2 (45);
    v_trans_uom_class           VARCHAR2 (45);
    v_temp_transaction_set_id   NUMBER;
    v_temp_transaction_id       NUMBER;    -- cbabu 25/07/02 for Bug#2480524
    v_manu_qty                  NUMBER;

    /* --Ramananda for File.Sql.35 */
    v_trans_uom_code            VARCHAR2 (3); --  := pr_new.transaction_uom;
    v_item_id                   NUMBER; --        := pr_new.inventory_item_id;
    v_new_trans_qty             NUMBER ; --       := pr_new.transaction_quantity;
    v_new_adjust_qty            NUMBER ; --       := pr_new.quantity_adjusted;
    v_debug                     VARCHAR2(1); -- :='Y';
    /* --Ramananda for File.Sql.35 */

    v_temp_modvat_flag          VARCHAR2 (1); --for Sub inventory transfer first record
    v_modvat_flag               VARCHAR2 (1);
    v_trading_flag              VARCHAR2 (1);
    v_trading_curr              VARCHAR2 (1);
    v_trading_temp              VARCHAR2 (1);
    v_item_trading_flag         VARCHAR2 (1);
    v_temp_item_trading_flag    VARCHAR2 (1);
    v_manufacturing_flag        VARCHAR2 (1);
    v_sub_qty                   NUMBER;     --- Start adding on 29-Mar-2001
    v_sr_no1                    NUMBER;     ---added by Sriram on 18-may-2001
    v_srno1                     NUMBER (15)   := 0;
    v_manu_home_qty             NUMBER; --Added by satya on 23-oct-01
    v_hit_rg23_qty              NUMBER; --Added by Nagaraj.s for Bug2649405
    v_hit_rg1_qty               NUMBER; --Added by Nagaraj.s for Bug2649405
    v_other_npe_qty             Number; -- Sriram -- Bug # 3258066

    ln_last_updated_by          JAI_CMN_TRANSACTIONS_T.LAST_UPDATED_BY%TYPE;
    ln_created_by               JAI_CMN_TRANSACTIONS_T.CREATED_BY%TYPE;
    ln_last_update_login        JAI_CMN_TRANSACTIONS_T.LAST_UPDATE_LOGIN%TYPE;

    CURSOR loc_id_cur (p_subinv_code IN VARCHAR2, p_organization_id IN NUMBER)
    IS
      SELECT location_id
        FROM JAI_INV_SUBINV_DTLS
       WHERE sub_inventory_name = p_subinv_code
         AND organization_id = p_organization_id;

    CURSOR item_class_cur (p_inv_item_id IN NUMBER, p_organization_id IN NUMBER)
    IS
      SELECT a.excise_flag, a.item_class, a.modvat_flag, a.item_trading_flag
        FROM JAI_INV_ITM_SETUPS a
       WHERE a.inventory_item_id = p_inv_item_id
         AND a.organization_id = p_organization_id;

    CURSOR fin_year_cur (p_org_id NUMBER)
    IS
      SELECT MAX (a.fin_year)
        FROM JAI_CMN_FIN_YEARS a
       WHERE fin_active_flag = 'Y' AND organization_id = p_org_id;

    CURSOR range_division_cur (p_organization_id IN NUMBER, p_loc_id IN NUMBER)
    IS
      SELECT NVL (excise_duty_range, ' '), NVL (excise_duty_division, ' ')
        FROM JAI_CMN_INVENTORY_ORGS
       WHERE organization_id = p_organization_id AND location_id = p_loc_id;

    CURSOR srno_i_cur (
      p_organization_id   IN   NUMBER,
      p_inv_item_id       IN   NUMBER,
      p_loc_id            IN   NUMBER,
      p_reg_type          IN   CHAR,
      p_f_year            IN   NUMBER
    )
    IS
      SELECT MAX (slno)
        FROM JAI_CMN_RG_23AC_I_TRXS
       WHERE organization_id = p_organization_id
         AND location_id = p_loc_id
         AND inventory_item_id = p_inv_item_id
         AND register_type = p_reg_type
         AND fin_year = p_f_year;


    /*
    CURSOR SRNO_II_CUR (  p_loc_id IN NUMBER, p_f_year IN NUMBER) IS
    SELECT MAX(slno)
    FROM   JAI_CMN_RG_I_TRXS
    WHERE  organization_id = pr_new.organization_id and
      location_id = p_loc_id and
      inventory_item_id = pr_new.inventory_item_id and
         fin_year = p_f_year;
    */

    CURSOR srno_ii_cur (p_loc_id IN NUMBER, p_f_year IN NUMBER)
    IS
      SELECT slno, balance_packed, balance_loose
        FROM JAI_CMN_RG_I_TRXS
       WHERE organization_id = pr_new.organization_id
         AND location_id = p_loc_id
         AND inventory_item_id = pr_new.inventory_item_id
         AND fin_year = p_f_year
         AND slno = (SELECT MAX (slno)
                       FROM JAI_CMN_RG_I_TRXS
                      WHERE organization_id = pr_new.organization_id
                        AND location_id = p_loc_id
                        AND inventory_item_id = pr_new.inventory_item_id
                        AND fin_year = p_f_year);

    CURSOR opening_balance_cur (
      p_organization_id   IN   NUMBER,
      p_inv_item_id       IN   NUMBER,
      p_sr_no             IN   NUMBER,
      p_loc_id            IN   NUMBER,
      p_reg_type          IN   CHAR,
      p_f_year            IN   NUMBER
    )
    IS
      SELECT opening_balance_qty, closing_balance_qty
        FROM JAI_CMN_RG_23AC_I_TRXS
       WHERE slno = p_sr_no
         AND organization_id = p_organization_id
         AND location_id = p_loc_id
         AND register_type = p_reg_type
         AND fin_year = p_f_year
         AND inventory_item_id = p_inv_item_id;

    CURSOR count_temp_cur
    IS
      SELECT COUNT (*)
        FROM JAI_CMN_TRANSACTIONS_T
       WHERE transaction_set_id = pr_new.transaction_set_id;

    CURSOR retrieve_temp_cur
    IS
      SELECT subinventory_code, organization_id, inventory_item_id,
             transaction_quantity, transaction_type_id, transaction_date,
             transaction_uom, transaction_set_id,
             transaction_id  -- cbabu for Bug# 2480584
        FROM JAI_CMN_TRANSACTIONS_T
       WHERE transaction_set_id = pr_new.transaction_set_id;


    /*
    CURSOR c_subinv_flags(p_subinv_code IN Varchar2, p_organization_id IN NUMBER)  IS
    SELECT bonded
    FROM   JAI_INV_SUBINV_DTLS
    WHERE  sub_inventory_name = p_subinv_code AND
         organization_id  = p_organization_id;
    */
    --added on 04/99/99
    CURSOR c_subinv_flags (
      p_subinv_code       IN   VARCHAR2,
      p_organization_id   IN   NUMBER
    )
    IS
      SELECT bonded, trading
        FROM JAI_INV_SUBINV_DTLS
       WHERE sub_inventory_name = p_subinv_code
         AND organization_id = p_organization_id;

    CURSOR fetch_type_name(v_transaction_type_id IN NUMBER)
    IS
      SELECT transaction_type_name
        FROM mtl_transaction_types
       WHERE transaction_source_type_id = v_transaction_type_id;

    -- cbabu 25/07/02 for Bug#2480524, start
    v_misc_recpt_rg_update NUMBER;
    v_misc_issue_rg_update NUMBER;
    CURSOR c_txn_type_id(v_transaction_type_name IN VARCHAR2)
    IS
      SELECT transaction_type_id
        FROM mtl_transaction_types
       WHERE transaction_type_name = v_transaction_type_name;
    -- cbabu 25/07/02 for Bug#2480524, end

   /* Start, PROJECTS COSTING IMPL Bug#6012567(5765161)*/
   CURSOR c_projects_flag(cp_transaction_type_id IN number)
   IS
      SELECT  nvl(type_class,-1) projects_flag
        FROM mtl_transaction_types
       WHERE transaction_type_id = cp_transaction_type_id;

   ln_projects_flag     mtl_transaction_types.type_class%type;  /* PROJECTS COSTING IMPL */
   /* End, PROJECTS COSTING IMPL Bug#6012567 (5765161)*/

    CURSOR get_pr_uom_cur (v_item_id IN NUMBER, v_org_id IN NUMBER)
    IS
      SELECT primary_uom_code
        FROM mtl_system_items
       WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;

    CURSOR chk_uom_cur (uom IN VARCHAR2)
    IS
      SELECT uom_class
        FROM mtl_units_of_measure
       WHERE unit_of_measure = uom;

    /*  -- cbabu 25/07/02 for Bug#2480524
    CURSOR get_subinv_dtl_cur
    IS
      SELECT manufacturing, trading
        FROM JAI_CMN_INVENTORY_ORGS
       WHERE organization_id = pr_new.organization_id AND location_id = 0;
    */
    -- cbabu, to execute this trigger only for indian operating units
    v_gl_set_of_bks_id  gl_sets_of_books.set_of_books_id%TYPE;
    v_currency_code   gl_sets_of_books.currency_code%TYPE;

   /* Bug 5413264. Added by Lakshmi Gopalsami
      Removed the cursor Fetch_Book_Id_Cur
   */
    CURSOR Sob_Cur(p_gl_set_of_bks_id IN NUMBER) IS
    SELECT Currency_code
    FROM gl_sets_of_books
    WHERE set_of_books_id = p_gl_set_of_bks_id;

    -- cbabu

     --start additions for bug#8530264

   cursor get_qty_update_flag
   is
   select quantity_register_flag
   from jai_rcv_transactions
   where transaction_id in(select parent_transaction_id from jai_rcv_transactions where transaction_id=pr_new.source_line_id) ;

   lv_qty_register_flag VARCHAR2(1);
     --end additions for bug#8530264

  /*bug 9122545*/
  CURSOR c_org_addl_rg_flag(cp_organization_id jai_cmn_inventory_orgs.organization_id%TYPE,
                            cp_location_id jai_cmn_inventory_orgs.location_id%TYPE)
  IS
  SELECT nvl(allow_negative_rg_flag,'N')
  FROM jai_cmn_inventory_orgs
  WHERE organization_id = cp_organization_id
  AND location_id = cp_location_id;

  lv_allow_negative_rg_flag jai_cmn_inventory_orgs.allow_negative_rg_flag%TYPE;
  /*end bug 9122545*/
  BEGIN
    pv_return_code := jai_constants.successful ;
    /*-------------------------------------------------------------------------------------------------------------------------
    S.No  Date(DD/MM/YY) Author and Details of Changes
    ----  -------------- -----------------------------
    1    25/07/02        Vijay Shankar, Bug# 2480584, Version: 615.1
                         Added Code for back tracking from RG1. From now onwards deleveloper can back track RG1 record corresponding
                         to MTL_MATERIAL_TRANSACTIONS as JAI_CMN_RG_I_TRXS.REF_DOC_NO = to_char(MTL_MATERIAL_TRANSACTIONS.transaction_id)
                         Code is modified to take care of bonded and trading flags, if the subinventories are not defined in localization setup.
                         During Subinventory transacfer transaction(i.e transaction_action_id = 2), the serial number and balances
                         are not calculated properly, which is resolved in this bug.

    2    29/07/02        Vijay Shankar, Bug# 2480584, Version: 615.2
                         Code added to hit RG register during pick release/staging transfer

    3    30/08/02        Vijay Shankar, Bug# 2541366, Version: 615.3
                         When a subinventory transfer is made from Bonded to Nonbonded subinventory, then balances are updated wrongly
                         in RG1 register. The reason for problem: location_id used to fetch the serial number should be temp location id
                         instead of present transaction location id.

    4    09/12/02        Nagaraj.s, Bug# 2649405, Version: 615.4
                         As per the functional requirement, is needed that for CCIN, CCEX
                         classes, in case of an Miscellaneous Receipt(RG Update). RG1 Register
                         is to be hit and in case of an Miscellaneous Issue(RG Update), it should
                         first hit to the tune of the Closing Quantity available in RG23 PART I
                         and the rest should be hit in  RG 1 Register.
                         This has been taken care by commenting pieces of code with Issue and with
                         ITEM Class CCIN and replaced by an elsif clause which checks the balances
                         in RG23 PART I Register and hits RG23 PART I and the rest Quantity hits
                         RG1 Register.

    5    31/12/02        cbabu for Bug# 2728521, Version: 615.5
                         Coding is done as per the functional inputs specified in the above bug for subinvetory transfer transaction

    6    13/01/03        Nagaraj.s for Bug#2744695 Version : 615.6
                         Changed the Insert statement of JAI_CMN_RG_I_TRXS table from
                         --to_other_factory_n_pay_ed_qty to other_purpose_n_pay_ed_qty as per
                         the Functional Requirement.
                         and also previously for FGIN and CCIN class of Items, the v_trans_qty
                         was null which is changed to the Abs(v_new_trans_qty) for CCIN class.

    7    03/04/03        Vijay Shankar for Bug# 2851028 Version : 615.7
                          Move Order Issue Transaction is taken care with this bug. If specified transcation is done, then it is routed to
                          execute the code corresponding to Misc. Issue (RG Update) transaction.

    8    23/04/03        Vijay Shankar for Bug# 2915814, FileVersion : 615.8
                          Coding is done as per the functional inputs specified in Bug# 2649405 for 'WIP Issue' transaction.
                          i.e when a WIP Issue transaction is done for CCIN items, then it should hit RG23 Part I register first
                          and then if quantity is not available with RG23 Part I it should hit RG1

    9.  03/12/2003       Ssumaith - Bug # 3258066 and 3258269 File Version 617.1
                         For Production Input and Production Receipt , The manufactured_qty and other_qty_n_pay_ed fields wee
                         not updated correctly.The requirement was that for Production Issue , the way it needed to be done was
                         Only Other_purpose_n_pay_ed column needed to be updated with the transaction Quantity.

                         For Production Receipt
                         Only Manufactured_loose_qty needed to be updated
                         These changes have been done by writing an If condition which selectively makes the variables Null

    10.   29-nov-2004    ssumaith - bug# 4037690  - File version 115.1
                         Check whether india localization is being used was done using a INR check in every trigger.
                         This check has now been moved into a new package and calls made to this package from this trigger
                         If the function jai_cmn_utils_pkg.check_jai_exists returns true it means INR is the set of books currency ,
                         Hence if this function returns FALSE , control should return.

    11.   19-jan-2005    ssumaith - bug#4130515   file version 115.2
                         An exit condition was commented which was causing the control to go into an infinite loop.
                         This exit condition has been uncommented and it resolves the issue.

    12    08-Jun-2005    This Object is Modified to refer to New DB Entity names in place of Old
                         DB Entity as required for CASE COMPLAINCE.  Version 116.1

    13.   13-Jun-2005    Ramananda for bug#4428980. File Version: 116.2
                         Removal of SQL LITERALs is done
    14.   28-Nov-2005    Aiyer for bug# 4764510. File Version: 120.1
                         Added the who columns in the insert into statment for the table JAI_CMN_TRANSACTIONS_T.
                         Dependencies due to this change:-
                         None

    15.   13-Feb-2007   bgowrava for forward porting bug#5275865 (11i bug#5217272) Version# 120.3
                        Issue : In case of a WIP Assebly transaction, data should be entered into
                        ja_in_rg_i as a "PR" type of transaction and not a "PI" type of transaction.

                        Fix : Moved the condition to check for Assembly Return under the "PR"
                        transaction type.

    16  24-Apr-2007     cbabu for forward porting bug#6012567 (5765161) version#120.4
                         forward ported the Project Costing changes R12

    17.   21-Oct-2008   CSahoo for bug#4541316, File Version 120.2.12000000.5
                        Added condition for Internal Sales Order transaction to hit RG-I
                        Internal Sales Order in mtl_material_transactions is defined as
                        (transaction_type_id =53, transaction_action_id =28, transaction_source_type_id = 8)
18.  19-jun-2009  vkaranam for bug#8530264 ,File Version 120.2.12000000.7
                   Issue:
                   For Correction of Deliver ,Issue Adjustment(IA) is generated due to which Onhand quantity does
                   not synchronize with quantity register.
                   Fix:
                   Issue Adjustment for Correction of Delivery should not be generated if parent
                   transaction (delivery) is not  generated in qty register.

                   query by bug number to see the changes.

19.  27-Nov-2009   bug 9122545 File version 120.2.12000000.8 / 120.5.12010000.5 / 120.9
                   Checked the setup option to allow negative quantity in RG before raising the error
                   "Enough RG23 Part1 balances do not exist".

16  05/Apr/2010    Bug 9550254
 	               The opening balance for the RG23 Part I and RG I has been derived from the
                   previous finyear closing balance, if no entries found for the current year.

    Future Dependencies For the release Of this Object:-
    (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
    A datamodel change )
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Current Version    Current Bug    Dependent           Files                Version   Author   Date          Remarks
    Of File                           On Bug/Patchset    Dependent On

    ja_in_tran_rg_entry_trg.sql
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    115.1              4037690        IN60105D2          ja_in_util_pkg_s.sql  115.0   Ssumaith 29-Nov-2004  Call to this function.
                                                         ja_in_util_pkg_s.sql  115.0   Ssumaith

    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

       /* --Ramananda for File.Sql.35 */
       v_trans_uom_code            := pr_new.transaction_uom;
       v_item_id                   := pr_new.inventory_item_id;
       v_new_trans_qty             := pr_new.transaction_quantity;
       v_new_adjust_qty            := pr_new.quantity_adjusted;
       v_debug                     := 'Y';
       ln_last_updated_by          :=  fnd_global.user_id; /* added by aiyer for the bug 4764510 */
       ln_created_by               :=  ln_last_updated_by; /* added by aiyer for the bug 4764510 */
       ln_last_update_login        :=  fnd_global.login_id;/* added by aiyer for the bug 4764510 */
       /* --Ramananda for File.Sql.35 */

     /* Bug 5413264. Added by Lakshmi Gopalsami
        Commented the following call as this check is already done in trigger
  and the variable v_gl_set_of_bks_id is not used anywhere.
      OPEN  Fetch_Book_Id_Cur(pr_new.organization_id);
      FETCH Fetch_Book_Id_Cur INTO v_gl_set_of_bks_id;
      CLOSE Fetch_Book_Id_Cur;
     */

      --If jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT => 'JA_IN_TRAN_RG_ENTRY' , P_SET_OF_BOOKS_ID => v_gl_set_of_bks_id) = false then
       --return;
      --end if;

      /* following code commented and added the above code instead to return in case of NON-India Localization implementation */
       /* OPEN Sob_cur(v_gl_set_of_bks_id);
          FETCH Sob_cur INTO v_currency_code;
          CLOSE Sob_cur;

          IF NVL(v_currency_code,'###') != 'INR' THEN
            RETURN;
            -- insert into debug_Data values ( 'v_currency_code = '||v_currency_code);
          END IF;
       */

      --start additions by vkaranam for bug#7605535
      if ((PR_NEW.transaction_action_id = 27 AND PR_NEW.transaction_source_type_id = 12)
          OR
          (PR_NEW.transaction_action_id = 1 AND PR_NEW.transaction_source_type_id = 12)
	  )
       then
           UPDATE jai_om_oe_rma_lines
           SET    received_flag = 'Y',
           last_update_date = pr_new.last_update_date,
           last_updated_by = pr_new.last_updated_by,
           last_update_login = pr_new.last_update_login
         WHERE  rma_line_id = pr_new.TRX_SOURCE_LINE_ID;  --added for bug#7605535,17 dec

 end if;
 --end additions by vkaranam for bug#7605535

       OPEN get_pr_uom_cur (pr_new.inventory_item_id, pr_new.organization_id);
       FETCH get_pr_uom_cur INTO v_pr_uom_code;
       CLOSE get_pr_uom_cur;

       IF NVL (v_pr_uom_code, '@##') = v_trans_uom_code
       THEN
          v_new_trans_qty := pr_new.transaction_quantity;
          v_new_adjust_qty := pr_new.quantity_adjusted;
       ELSIF NVL (v_pr_uom_code, '@##') <> v_trans_uom_code
       THEN
          inv_convert.inv_um_conversion (
             v_trans_uom_code,
             v_pr_uom_code,
             v_item_id,
             v_uom_qty
          );

          IF NVL (v_uom_qty, 0) <= 0
          THEN
             OPEN chk_uom_cur (v_pr_uom_code);
             FETCH chk_uom_cur INTO v_pr_uom_class;
             CLOSE chk_uom_cur;

             OPEN chk_uom_cur (v_trans_uom_code);
             FETCH chk_uom_cur INTO v_trans_uom_class;
             CLOSE chk_uom_cur;

             IF v_pr_uom_class <> v_trans_uom_class
             THEN
                v_uom_qty := 0;
             ELSE
                inv_convert.inv_um_conversion (
                   v_trans_uom_code,
                   v_pr_uom_code,
                   0,
                   v_uom_qty
                );
             END IF;
          END IF;

          v_new_trans_qty := NVL (v_new_trans_qty, 0) * NVL (v_uom_qty, 0);
          v_new_adjust_qty := NVL (v_new_adjust_qty, 0) * NVL (v_uom_qty, 0);
       END IF;

       OPEN c_subinv_flags (pr_new.subinventory_code, pr_new.organization_id);
       FETCH c_subinv_flags INTO v_bonded_curr, v_trading_flag;

       -- cbabu 25/07/02 for Bug#2480524
       IF c_subinv_flags%NOTFOUND THEN
        v_bonded_curr := 'N';
        v_trading_curr := 'N';
       ELSE
          IF nvl(v_trading_flag,'N') = 'Y' THEN
             v_trading_curr := 'Y';
         v_bonded_curr := 'N';
          ELSIF nvl(v_bonded_curr,'N') = 'Y' THEN
         v_bonded_curr := 'Y';
             v_trading_curr := 'N';
          ELSE
        v_bonded_curr := 'N';
        v_trading_curr := 'N';
          END IF;
       END IF;
       CLOSE c_subinv_flags;

       OPEN loc_id_cur (pr_new.subinventory_code, pr_new.organization_id);
       FETCH loc_id_cur INTO v_loc_id;
       CLOSE loc_id_cur;

       IF v_loc_id IS NULL THEN
          v_loc_id := 0;
       END IF;

       OPEN item_class_cur (pr_new.inventory_item_id, pr_new.organization_id);
       FETCH item_class_cur INTO v_excise_flag, v_item_class, v_modvat_flag, v_item_trading_flag;
       CLOSE item_class_cur;

       OPEN fin_year_cur (pr_new.organization_id);
       FETCH fin_year_cur INTO v_f_year;
       CLOSE fin_year_cur;

       OPEN range_division_cur (pr_new.organization_id, v_loc_id);
       FETCH range_division_cur INTO v_range_no, v_division_no;
       CLOSE range_division_cur;


           ------3rd case starts here for
       /* 3.  Inventory sub transfer/ Replenish supply subinventory.
          3a. Staging transfer of a sales order (transaction_type_id = 52, transaction_action_id = 28, transaction_source_type_id = 2)
       */
       IF ( pr_new.transaction_action_id = 2 AND pr_new.transaction_source_type_id = 13 ) --sub inventory
          OR
          ( pr_new.transaction_action_id = 2 AND pr_new.transaction_source_type_id = 4 ) --added by satya
          OR
          ( pr_new.transaction_action_id = 28 AND pr_new.transaction_source_type_id = 2 ) -- cbabu 29/07/2002 for Bug#2428044
          OR
          ( pr_new.transaction_type_id = 53 AND pr_new.transaction_action_id = 28 AND pr_new.transaction_source_type_id = 8 ) --added for bug#4541316
       THEN

    --Insert into debug_Data values ( to_char(pr_new.creation_date, 'dd-mon-yyyy hh24:mi:ss')||', T_type_id = '||pr_new.transaction_type_id||', t_id = '||pr_new.transaction_id
    --  ||', t_action_id = '||pr_new.transaction_action_id||', subinventory = '||pr_new.subinventory_code
    --  ||', o_id = '||pr_new.organization_id||', t_src_type_id = '||pr_new.transaction_source_type_id
    --  ||', t_src_id = '||pr_new.transaction_source_id );

          OPEN count_temp_cur;
          FETCH count_temp_cur INTO v_count_temp;
          CLOSE count_temp_cur;

          IF v_count_temp = 0 THEN
             /*
             || Added the who columns in the insert statement
             */
             INSERT INTO JAI_CMN_TRANSACTIONS_T
                         ( transaction_set_id              ,
                           inventory_item_id               ,
                           organization_id                 ,
                           subinventory_code               ,
                           transaction_type_id             ,
                           transaction_id                  ,
                           transaction_date                ,
                           transaction_quantity            ,
                           transaction_uom                 ,
                           created_by                      ,
                           creation_date                   ,
                           last_updated_by                 ,
                           last_update_date                ,
                           last_update_login
                         )
                  VALUES ( pr_new.transaction_set_id       ,
                           pr_new.inventory_item_id        ,
                           pr_new.organization_id          ,
                           pr_new.subinventory_code        ,
                           pr_new.transaction_type_id      ,
                           pr_new.transaction_id           ,
                           pr_new.transaction_date         ,
                           v_new_trans_qty                 ,
                           pr_new.transaction_uom          ,
                           ln_created_by                   , /* Added by aiyer for the bug 4764510 */
                           sysdate                         , /* Added by aiyer for the bug 4764510 */
                           ln_last_updated_by              , /* Added by aiyer for the bug 4764510 */
                           sysdate                         , /* Added by aiyer for the bug 4764510 */
                           ln_last_update_login
                         );
          ELSE
             OPEN retrieve_temp_cur;
             FETCH retrieve_temp_cur INTO v_temp_subinv_code, v_temp_organization_id, v_temp_inv_item_id,
                v_temp_trans_qty, v_temp_trans_type_id, v_temp_trans_date, v_temp_trans_uom, v_temp_transaction_set_id,
                v_temp_transaction_id; -- cbabu 25/07/02 for Bug#2480524
             CLOSE retrieve_temp_cur;

             -- cbabu 25/07/02 for Bug#2480524
             OPEN c_subinv_flags (v_temp_subinv_code, v_temp_organization_id);
             FETCH c_subinv_flags INTO v_bonded_temp, v_trading_flag;

             IF c_subinv_flags%NOTFOUND THEN
          v_bonded_temp := 'N';
          v_trading_temp := 'N';
             ELSE
                IF nvl(v_trading_flag,'N') = 'Y' THEN
                   v_trading_temp := 'Y';
             v_bonded_temp := 'N';
                ELSIF nvl(v_bonded_temp,'N') = 'Y' THEN
             v_bonded_temp := 'Y';
                   v_trading_temp := 'N';
                ELSE
            v_bonded_temp := 'N';
            v_trading_temp := 'N';
                END IF;
             END IF;
         ---------
             CLOSE c_subinv_flags;

             OPEN loc_id_cur (v_temp_subinv_code, v_temp_organization_id);
             FETCH loc_id_cur INTO v_temp_loc_id;
             CLOSE loc_id_cur;

             IF v_temp_loc_id IS NULL THEN
                v_temp_loc_id := 0;
             END IF;

             IF v_trading_temp = 'Y' THEN
                IF v_trading_curr = 'Y' THEN
                   IF v_temp_loc_id <> v_loc_id THEN
                      v_ins_from_temp_flag := 1;
                      v_ins_from_curr_flag := 1;

                   ELSIF v_temp_loc_id = v_loc_id THEN
                      v_ins_from_temp_flag := 0;
                      v_ins_from_curr_flag := 0;
                   END IF;

                ELSIF v_bonded_curr = 'Y' THEN
                   v_ins_from_temp_flag := 1;
                   v_ins_from_curr_flag := 1;

                ELSE --bonded_curr is 'N'
                   v_ins_from_temp_flag := 1;
                   v_ins_from_curr_flag := 0;
                END IF;

             ELSIF v_trading_curr = 'Y' THEN
                IF v_bonded_temp = 'Y' THEN
                   v_ins_from_temp_flag := 1;
                   v_ins_from_curr_flag := 1;
                ELSE  -- bonded_temp is 'N' then temp table transaction should not hit RG
                   v_ins_from_temp_flag := 0;
                   v_ins_from_curr_flag := 1;
                END IF;

             ELSIF v_bonded_temp = 'Y' THEN  -- temp transaction is bonded
                IF v_bonded_curr = 'Y' THEN  -- current transaction is bonded
                   IF v_temp_loc_id = v_loc_id THEN
                      v_ins_from_temp_flag := 0;
                      v_ins_from_curr_flag := 0;
                   ELSE   -- IF v_temp_loc_id = v_loc_id THEN
                      v_ins_from_temp_flag := 1;
                      v_ins_from_curr_flag := 1;
                   END IF;
                ELSE    -- IF v_bonded_curr = 'N' THEN
                   v_ins_from_temp_flag := 1;
                   v_ins_from_curr_flag := 0;
                END IF;

             -- ELSIF v_bonded_temp = 'N' THEN
             ELSE --if the execution comes here, then it means v_trading_temp = 'N', v_trading_curr = 'N', v_bonded_temp = 'N'
                IF v_bonded_curr = 'Y' THEN
                   v_ins_from_temp_flag := 0;  -- cbabu 25/07/02 for Bug#2480524 , when transaction is done from NB -> B Subinventory then RG is hitting twice which is wrong
                   --v_ins_from_temp_flag := 1; --added by sriram on 12-may-01 and commented by vijay shankar for -- cbabu 25/07/02 for Bug#2480524
                   v_ins_from_curr_flag := 1;
                ELSE    -- IF v_bonded_curr = 'N' THEN
                   v_ins_from_temp_flag := 0;
                   v_ins_from_curr_flag := 0;
                END IF;
             END IF;

             WHILE(TRUE) LOOP --To handle both entries with single insert

                -- If the temp transaction which is in temp table has to go into RG, then the following condition is TRUE
                IF v_ins_from_temp_flag = 1 THEN  --aaa

                   v_iss_qty := ABS (v_temp_trans_qty);
                   v_iss_id := v_temp_transaction_set_id;
                   v_iss_date := v_temp_trans_date;
                   v_rec_id := NULL;
                   v_rec_qty := NULL;
                   v_rec_date := NULL;

                   OPEN item_class_cur ( v_temp_inv_item_id, v_temp_organization_id );
                   FETCH item_class_cur INTO v_temp_excise_flag, v_temp_item_class, v_temp_modvat_flag, v_temp_item_trading_flag;
                   CLOSE item_class_cur;

                   OPEN range_division_cur ( v_temp_organization_id, v_temp_loc_id );
                   FETCH range_division_cur INTO v_temp_range_no, v_temp_division_no;
                   CLOSE range_division_cur;

                   OPEN get_pr_uom_cur ( v_temp_inv_item_id, v_temp_organization_id );
                   FETCH get_pr_uom_cur INTO v_temp_pr_uom_code;
                   CLOSE get_pr_uom_cur;

                   IF v_temp_trans_qty < 0 THEN
                      v_t_type := 'I';
                   ELSE
                      v_t_type := 'R';
                   END IF;

                   IF v_trading_temp = 'Y' THEN
                      IF NVL (v_temp_item_trading_flag, 'N') = 'Y' THEN
                         jai_cmn_rg_23d_trxs_pkg.make_entry (
                            pr_new.organization_id,
                            v_loc_id,
                            v_t_type,
                            pr_new.inventory_item_id,
                            pr_new.subinventory_code,
                            v_temp_pr_uom_code,
                            pr_new.transaction_uom,
                            v_rec_id,
                            v_rec_date,
                            v_rec_qty,
                            pr_new.transaction_type_id,
                            v_iss_id,
                            v_iss_date,
                            v_iss_qty,
                            pr_new.transaction_date,
                            pr_new.creation_date,
                            pr_new.created_by,
                            pr_new.last_update_date,
                            pr_new.last_update_login,
                            pr_new.last_updated_by
                         );
                      END IF;
                   ELSIF ( v_temp_excise_flag = 'Y'
                             AND v_temp_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX')
                             AND v_t_type = 'I'
                            )
                         OR ( v_temp_modvat_flag = 'Y'
                             AND v_temp_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX')
                             AND v_t_type = 'R'
                            )
                   THEN
                      IF    ( v_temp_excise_flag = 'Y'
                             AND v_temp_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')
                             AND v_t_type = 'I'
                            )
                         OR (    v_temp_modvat_flag = 'Y'
                             AND v_temp_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')
                             AND v_t_type = 'R'
                            )
                      THEN
                         v_reg_type := 'A';
                      ELSIF    ( v_temp_excise_flag = 'Y'
                                AND v_temp_item_class IN ('CGIN', 'CGEX')
                                AND v_t_type = 'I'
                               )
                            OR ( v_temp_modvat_flag = 'Y'
                                AND v_temp_item_class IN ('CGIN', 'CGEX')
                                AND v_t_type = 'R'
                               )
                      THEN
                         v_reg_type := 'C';
                      END IF;
                      /*Bug 9550254 - Start*/
                      /*
                      OPEN srno_i_cur ( v_temp_organization_id, v_temp_inv_item_id, v_temp_loc_id, v_reg_type, v_f_year );
                      FETCH srno_i_cur INTO v_srno;
                      CLOSE srno_i_cur;
                      */
                      /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
                      v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(v_temp_organization_id,v_temp_loc_id,v_temp_inv_item_id,v_f_year,v_reg_type,v_srno);
                      /*Bug 9550254 - End*/
                      IF NVL (v_srno, 0) = 0 THEN
                         v_srno := 1;
                         v_sr_no := 0;
                      ELSE
                         v_sr_no := v_srno;
                         v_srno := v_srno + 1;
                      END IF;

                      IF v_temp_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX') THEN

                IF v_sr_no = 0 THEN
                 /*Bug 9550254 - Start*/
                 -- v_opening_qty := 0;
                 -- v_closing_qty := v_temp_trans_qty;
                 v_closing_qty := v_opening_qty + v_temp_trans_qty;
                 /*Bug 9550254 - End*/

                ELSE
                 OPEN opening_balance_cur ( v_temp_organization_id, v_temp_inv_item_id, v_sr_no,
                  v_temp_loc_id, v_reg_type, v_f_year);
                 FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                 CLOSE opening_balance_cur;

                 IF NVL (v_cl_qty, 0) <> 0 THEN
                  v_opening_qty := v_cl_qty;
                  v_closing_qty := v_cl_qty + v_temp_trans_qty;

                 ELSE
                  v_opening_qty := 0;
                  v_closing_qty := v_temp_trans_qty;
                 END IF;

                END IF;
                v_rg23_flag := 1;

                      ELSE    -- IF v_temp_item_class in ('CCIN', 'CCEX')

                --Start, cbabu for Bug# 2728521
                IF v_sr_no = 0 THEN
                 IF v_temp_trans_qty < 0 THEN
                  v_iss_qty := null;
                  v_hit_rg1_qty := v_temp_trans_qty;
                 ELSE
                  /*Bug 9550254 - Start*/
                  --v_opening_qty := 0;
                  --v_closing_qty := v_temp_trans_qty;
                  v_closing_qty := v_opening_qty + v_temp_trans_qty;
                  /*Bug 9550254 - End*/
                  v_rg23_flag := 1;
                 END IF;

                ELSE

                 OPEN opening_balance_cur ( v_temp_organization_id, v_temp_inv_item_id, v_sr_no,
                  v_temp_loc_id, v_reg_type, v_f_year);
                 FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                 CLOSE opening_balance_cur;

                 IF v_cl_qty IS NOT NULL THEN   -- NVL (v_cl_qty, 0) != 0 THEN
                  v_closing_qty := v_cl_qty + v_temp_trans_qty;

                  --Start, cbabu for Bug# 2728521
                  IF v_cl_qty <= 0 THEN
                    v_iss_qty := null;
                    v_hit_rg1_qty := v_temp_trans_qty;

                  ELSIF v_closing_qty < 0 THEN
                    v_hit_rg1_qty := v_closing_qty;

                    v_iss_qty := v_cl_qty;
                    v_closing_qty := 0;

                    v_rg23_flag := 1;

                  ELSE  -- v_closing_qty > 0
                    -- Enough closing balance quantity is there, so hit RG23 and done hit RG1
                    v_rg23_flag := 1;
                  END IF;
                  --End, cbabu for Bug# 2728521

                  v_opening_qty := v_cl_qty;

                 ELSE

                  v_iss_qty := null;
                  v_hit_rg1_qty := v_temp_trans_qty;
                  -- v_opening_qty := 0;    -- cbabu for Bug# 2728521
                  -- v_closing_qty := v_temp_trans_qty; -- cbabu for Bug# 2728521
                 END IF;


                END IF;
              END IF;

                      -- v_rg23_flag := 1;  -- cbabu for Bug# 2728521

                   END IF; ------ADDED BY SRIRAM ON 18-APR-2001

             --The changes are made to solve the problem of CCIN items are not
             --appearing in the RG1 register when an Sub-inventory transfer is made.

                   IF ( v_temp_excise_flag = 'Y'
                          AND v_item_class IN ('FGIN', 'FGEX', 'CCIN'
                                                , 'CCEX' )    -- cbabu for Bug# 2728521
                          AND v_t_type = 'I'
                         ) ---ADDED BY SRIRAM ON 18-APR-2001
                      OR (    v_temp_modvat_flag = 'Y'
                          AND v_item_class IN ('FGIN', 'FGEX', 'CCIN'
                                                , 'CCEX' )    -- cbabu for Bug# 2728521
                          AND v_t_type = 'R'
                         )
                   THEN

                      -- cbabu for Bug# 2728521
                      IF v_item_class IN ('CCIN', 'CCEX') AND v_hit_rg1_qty IS NOT NULL THEN
                        v_temp_trans_qty := v_hit_rg1_qty;
                      ELSIF v_item_class IN ('CCIN', 'CCEX') THEN
                        GOTO skip_rg1_hit;
                      END IF;

                      IF v_t_type = 'I' THEN
                         v_trans_qty := v_temp_trans_qty;
                      ELSIF v_t_type = 'R' THEN
                         v_trans_qty := NULL;
                      END IF;
                      /*Bug 9550254 - Start*/
                      /*
                      -- OPEN srno_ii_cur (v_loc_id, v_f_year); -- commented by cbabu for Bug#2541366
                      OPEN srno_ii_cur (v_temp_loc_id, v_f_year); -- cbabu for Bug#2541366
                      --FETCH  SRNO_II_CUR INTO v_srno,v_bal_packed,v_bal_loose; --commented by --sriram on 18-may-01
                      FETCH srno_ii_cur INTO v_srno1, v_bal_packed, v_bal_loose;
                      CLOSE srno_ii_cur;
                      */
                      /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
 	                  v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_temp_loc_id,pr_new.inventory_item_id,v_f_year,
                                                                     v_srno1,v_bal_packed);
                      /*Bug 9550254 - End*/

                      --Start adding by Sriram on 18-may-01
                      IF NVL (v_srno1, 0) = 0 THEN
                         v_srno1 := 1;
                         v_sr_no1 := 0;

                      ELSE
                         v_sr_no1 := v_srno1;
                         v_srno1 := v_srno1 + 1;
                      END IF;

                      --end adding by Sriram on 18-may-01
                      v_manu_qty := 0;
                      v_manu_pkd_qty := NULL;
                      v_manu_loose_qty := NULL;

                      --          v_manu_qty := v_temp_trans_qty; --commented by sriram on 11-may-01
                      v_manu_pkd_qty := 0; --added by sriram on 11-may-01

                      /**start added by sriram on 15-may-01**/
                      IF v_t_type = 'R' THEN
                         v_manu_qty := v_temp_trans_qty; --added by sriram on 23-may-01
                         v_manu_loose_qty := ABS (v_temp_trans_qty); --added by sriram on 11-may-01
                      ELSIF v_t_type = 'I' THEN
                         v_manu_qty := 0; --added by sriram on 23-may-01
                         v_manu_loose_qty := 0;
                      END IF;

                      /**end added by sriram on 15-may-01**/
                      IF (  NVL (v_bal_packed, 0)
                          + NVL (v_bal_loose, 0)
                         ) >= ABS (v_temp_trans_qty)
                      THEN
                         IF NVL (v_bal_loose, 0) >= ABS (v_temp_trans_qty) THEN
                            v_bal_loose :=   NVL (v_bal_loose, 0)
                                           - ABS (NVL (v_temp_trans_qty, 0));
                         ELSE
                            v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_temp_trans_qty, 0));
                            v_bal_packed := NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0);
                            v_bal_loose := 0;
                         END IF;
                      ELSE
                         v_bal_packed := NVL (v_bal_packed, 0) - ABS (NVL (v_temp_trans_qty, 0));
                         v_bal_loose := NVL (v_bal_loose, 0) + NVL (v_bal_packed, 0);
                         v_bal_packed := 0;
                      END IF;

                      v_rg_flag := 1;

                      <<skip_rg1_hit>>
                        null;
                   END IF; ---ADDED BY SRIRAM ON 18-APR-2001

                   ---END IF;   ---COMMENTED BY SRIRAM ON 18-APR-2001
                   v_ins_from_temp_flag := 0;
                   v_insert_flag := 1;
                END IF;  --aaa

                IF v_insert_flag = 1 THEN --bbb
                   IF v_rg23_flag = 1 THEN
                   /*bug 9122545*/
                OPEN  loc_id_cur(pr_new.subinventory_code, pr_new.organization_id);
                FETCH loc_id_cur INTO v_loc_id;
                CLOSE loc_id_cur;

		IF v_loc_id IS NULL THEN
	            v_loc_id := 0;
	        END IF;

                OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
                FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
                CLOSE c_org_addl_rg_flag ;

                IF lv_allow_negative_rg_flag = 'N'
                THEN
		if v_closing_qty < 0 then
		 APP_EXCEPTION.RAISE_EXCEPTION( 'JA', -20109, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||v_temp_organization_id||','||v_temp_loc_id);
		end if;
		END IF;
                   /*end bug 9122545*/
                   --added rounding precision of 5 fro bug 9466919
                      INSERT INTO JAI_CMN_RG_23AC_I_TRXS(
                        register_id, fin_year, slno, last_update_date, last_updated_by,
              creation_date, created_by, last_update_login, TRANSACTION_SOURCE_NUM, inventory_item_id,
              organization_id, transaction_type, range_no, division_no, GOODS_ISSUE_ID_REF,
              goods_issue_date, goods_issue_quantity, OTH_RECEIPT_ID_REF, oth_receipt_date, oth_receipt_quantity,
              register_type, location_id, transaction_uom_code, transaction_date,
              opening_balance_qty, closing_balance_qty, primary_uom_code
            ) VALUES (
              JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, v_f_year, v_srno, pr_new.last_update_date, pr_new.last_updated_by,
              SYSDATE, pr_new.created_by, pr_new.last_update_login, v_temp_trans_type_id, v_temp_inv_item_id,
              v_temp_organization_id, v_t_type, v_temp_range_no, v_temp_division_no, v_iss_id,
              v_iss_date, round(v_iss_qty,5), v_rec_id, v_rec_date, round(v_rec_qty,5),
                        v_reg_type, v_temp_loc_id, v_temp_trans_uom, TRUNC (v_temp_trans_date),
              round(v_opening_qty,5), round(v_closing_qty,5), v_temp_pr_uom_code
                    );

                      v_rg23_flag := 0;
                   END IF;

            IF v_rg_flag = 1 THEN
              -- -- jai_cmn_utils_pkg.print_log('rg1.log','before 1');
                --added rounding precision of 5 for bug 9466919
            INSERT INTO JAI_CMN_RG_I_TRXS(
              register_id, fin_year, slno, manufactured_qty, manufactured_packed_qty,
              manufactured_loose_qty, balance_packed, balance_loose,
              to_other_factory_n_pay_ed_qty,
              for_export_n_pay_ed_qty, other_purpose_n_pay_ed_qty, last_update_date, last_updated_by,
              creation_date, created_by, last_update_login, TRANSACTION_SOURCE_NUM,
              inventory_item_id, organization_id, transaction_type, range_no,
              division_no, location_id, transaction_uom_code, transaction_date,
              primary_uom_code, REF_DOC_NO      -- cbabu 25/07/02 for Bug#2480524
            ) VALUES (
              JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno1,round( ABS(v_manu_qty),5),
              round(ABS(v_manu_pkd_qty),5), round(ABS(v_manu_loose_qty),5),round( v_bal_packed,5), round(v_bal_loose,5),  --abs(v_trans_qty), commented by Sriram on 26-Dec-2001
              NULL, -- abs(v_t_qty), commented by Sriram on 26-Dec-2001
              NULL, round(ABS(v_trans_qty),5), pr_new.last_update_date, pr_new.last_updated_by,
              SYSDATE, pr_new.created_by, pr_new.last_update_login, v_temp_trans_type_id,
              v_temp_inv_item_id, v_temp_organization_id, v_t_type, v_temp_range_no,
              v_temp_division_no, v_temp_loc_id, v_temp_trans_uom, TRUNC(v_temp_trans_date),
              v_pr_uom_code, v_temp_transaction_id   -- cbabu 25/07/02 for Bug#2480524
            );

            v_rg_flag := 0;
                  END IF;

                   v_insert_flag := 0;
                END IF;  --bbb

          v_hit_rg1_qty := null;    -- cbabu for Bug# 2728521

                IF v_ins_from_curr_flag = 1 THEN --ccc

                   -- Re - initialization for second Entry i.e current record for which the trigger is fired
                   v_reg_type := NULL;
                   v_srno := NULL;
                   v_sr_no := NULL;
                   v_opening_qty := NULL;
                   v_closing_qty := NULL;
                   v_op_qty := NULL;
                   v_cl_qty := NULL;
                   v_t_type := NULL;
                   v_iss_qty := NULL;
                   v_iss_id := NULL;
                   v_iss_date := NULL;
                   v_rec_id := pr_new.transaction_id;
                   v_rec_qty := v_new_trans_qty;
                   v_rec_date := pr_new.transaction_date;
                   v_temp_trans_type_id := pr_new.transaction_type_id;
                   v_temp_inv_item_id := pr_new.inventory_item_id;
                   v_temp_organization_id := pr_new.organization_id;
                   v_temp_range_no := v_range_no;
                   v_temp_division_no := v_division_no;
                   v_temp_loc_id := v_loc_id;
                   v_temp_trans_uom := pr_new.transaction_uom;
                   v_temp_trans_date := pr_new.transaction_date;
                   v_temp_trans_qty := v_new_trans_qty;

                   v_temp_transaction_id := pr_new.transaction_id;   -- cbabu 25/07/02 for Bug#2480524

                   v_bal_packed := 0;
                   v_bal_loose := 0;
                   v_temp_pr_uom_code := v_pr_uom_code;
                   v_manu_qty := v_new_trans_qty;

                   OPEN range_division_cur ( v_temp_organization_id, v_temp_loc_id );
                   FETCH range_division_cur INTO v_temp_range_no, v_temp_division_no;
                   CLOSE range_division_cur;

                   IF v_new_trans_qty < 0 THEN
                      v_t_type := 'I';
                   ELSE
                      v_t_type := 'R';
                   END IF;

                   IF NVL (v_trading_temp, 'N') = 'Y' THEN
                      IF NVL (v_item_trading_flag, 'N') = 'Y' THEN
                         --cal proc for RG23D entry
                         jai_cmn_rg_23d_trxs_pkg.make_entry (
                            pr_new.organization_id,
                            v_loc_id,
                            v_t_type,
                            pr_new.inventory_item_id,
                            pr_new.subinventory_code,
                            v_pr_uom_code,
                            pr_new.transaction_uom,
                            v_rec_id,
                            v_rec_date,
                            v_rec_qty,
                            pr_new.transaction_type_id,
                            v_iss_id,
                            v_iss_date,
                            v_iss_qty,
                            pr_new.transaction_date,
                            pr_new.creation_date,
                            pr_new.created_by,
                            pr_new.last_update_date,
                            pr_new.last_update_login,
                            pr_new.last_updated_by
                         );
                      END IF;
                   ELSIF (v_excise_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX')
                        AND v_t_type = 'I')
                      -- OR ( v_modvat_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX') -- cbabu for Bug# 2728521
                      OR ( v_modvat_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX') -- cbabu for Bug# 2728521
                          AND v_t_type = 'R' )
                   THEN
                      IF (v_excise_flag = 'Y' AND  v_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX') AND v_t_type = 'I')
                        -- OR (v_modvat_flag = 'Y' AND v_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX') AND v_t_type = 'R' )    -- cbabu for Bug# 2728521
                        OR (v_modvat_flag = 'Y' AND v_item_class IN ('RMIN', 'RMEX') AND v_t_type = 'R' ) -- cbabu for Bug# 2728521
                      THEN
                         v_reg_type := 'A';
                      ELSIF ( v_excise_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX') AND v_t_type = 'I' )
                        OR (v_modvat_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX') AND v_t_type = 'R' )
                      THEN
                         v_reg_type := 'C';
                      END IF;

                      /*Bug 9550254 - Start*/
                      /*
                      OPEN srno_i_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_loc_id, v_reg_type, v_f_year );
                      FETCH srno_i_cur INTO v_srno;
                      CLOSE srno_i_cur;
                      */
                      /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
 	                  v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
 	                                                                     v_f_year,v_reg_type,v_srno);
                      /*Bug 9550254 - End*/

                      IF NVL (v_srno, 0) = 0
                      THEN
                         v_srno := 1;
                         v_sr_no := 0;
                      ELSE
                         v_sr_no := v_srno;
                         v_srno := v_srno + 1;
                      END IF;

                      IF v_sr_no = 0 THEN
                         /*Bug 9550254 - Start*/
                         --v_opening_qty := 0;
                         --v_closing_qty := v_new_trans_qty;
                         v_closing_qty := v_new_trans_qty + v_opening_qty;
                         /*Bug 9550254 - End*/
                      ELSE
                         OPEN opening_balance_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_sr_no, v_loc_id,
                          v_reg_type, v_f_year );
                         FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                         CLOSE opening_balance_cur;

                         IF NVL (v_cl_qty, 0) <> 0 THEN
                            v_opening_qty := v_cl_qty;
                            v_closing_qty :=   v_cl_qty + v_new_trans_qty;
                         ELSE
                            v_opening_qty := 0;
                            v_closing_qty := v_new_trans_qty;
                         END IF;
                      END IF;

                      v_rg23_flag := 1;

                   ELSIF    (    v_excise_flag = 'Y'
                             AND v_item_class IN ('FGIN', 'FGEX')
                             AND v_t_type = 'I'
                            )
                         OR (    v_modvat_flag = 'Y'
                             -- AND v_item_class IN ('FGIN', 'FGEX')  -- cbabu for Bug# 2728521
                             AND v_item_class IN ('FGIN', 'FGEX', 'CCIN', 'CCEX') -- cbabu for Bug# 2728521
                             AND v_t_type = 'R'
                            )
                   THEN
                      -- IF v_item_class IN ('FGIN') THEN   -- cbabu for Bug# 2728521
                      IF v_item_class IN ('FGIN', 'CCIN') THEN  -- cbabu for Bug# 2728521
                         v_trans_qty := NULL;
                      -- ELSIF v_item_class IN ('FGEX', 'CCEX') THEN  -- cbabu for Bug# 2728521
                      ELSIF v_item_class IN ('FGEX', 'CCEX') THEN -- cbabu for Bug# 2728521
                         v_t_qty := NULL;
                      END IF;

                      /*Bug 9550254 - Start*/
                      /*
                      OPEN srno_ii_cur (v_loc_id, v_f_year);
                      -- FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
                      FETCH srno_ii_cur INTO v_srno1, v_bal_packed, v_bal_loose;
                      CLOSE srno_ii_cur;
                      */
                      /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
                      v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,
                                                                     v_srno1,v_bal_packed);
                      /*Bug 9550254 - End*/

                    /*
                    IF NVL (v_srno, 0) = 0 THEN
                         v_srno := 1;
                         v_sr_no := 0;
                         v_bal_packed := 0;
                         v_bal_loose := 0;
                      ELSE
                         v_sr_no := v_srno;
                         v_srno := v_srno + 1;
                      END IF;
                     */
                      IF NVL (v_srno1, 0) = 0 THEN
                         v_srno1 := 1;
                         v_sr_no := 0;
                         /*Commented for Bug 9550254 as it is already calculated by jai_om_rg_pkg.ja_in_rgi_balance above*/
                         -- v_bal_packed := 0;
                         -- v_bal_loose := 0;
                      ELSE
                         v_sr_no := v_srno1;
                         v_srno1 := v_srno1 + 1;
                      END IF;

                      v_manu_qty := v_new_trans_qty;
                      v_manu_pkd_qty := 0;
                      v_manu_loose_qty := v_new_trans_qty;

    --    v_bal_packed := NVL(v_bal_packed,0) + NVL(v_manu_pkd_qty,0);
                      v_bal_loose := NVL (v_bal_loose, 0) + NVL (v_new_trans_qty, 0);
                      v_rg_flag := 1;
                   END IF;

                   v_ins_from_curr_flag := 0;
                   v_insert_flag := 1;

                END IF;  --ccc

                IF v_ins_from_temp_flag = 0 AND v_ins_from_curr_flag = 0 AND v_insert_flag = 0 THEN
                   DELETE FROM JAI_CMN_TRANSACTIONS_T WHERE transaction_set_id = pr_new.transaction_set_id;
                   EXIT; /* Uncommented by ssumaith - bug# 4130515*/
                END IF;
             END LOOP;
          END IF;
          RETURN; -- cbabu 25/07/02 for Bug#2480524, required processing is done. so simply return
       END IF;

    --- 1st and 2nd case starts here
      /* 1.  Misc Issue(RG Update).
         2.  Misc Receipt(RG Update).
         3. Move Order Issue (added for Bug # 2851028)
      */

       -- cbabu 25/07/02 for Bug#2480524, start
       OPEN c_txn_type_id('Miscellaneous Issue(RG Update)');
       FETCH c_txn_type_id INTO v_misc_issue_rg_update;
       CLOSE c_txn_type_id;

       OPEN c_txn_type_id('Miscellaneous Recpt(RG Update)');
       FETCH c_txn_type_id INTO v_misc_recpt_rg_update;
       CLOSE c_txn_type_id;
       -- cbabu 25/07/02 for Bug#2480524, end

  /* following cursor added for PROJECTS COSTING IMPL Bug#6012567(5765161)*/
       OPEN c_projects_flag(pr_new.transaction_type_id);
       FETCH c_projects_flag INTO ln_projects_flag;
       CLOSE c_projects_flag;


       IF (   (    pr_new.transaction_action_id = 1
               AND pr_new.transaction_source_type_id = 13
               --AND pr_new.transaction_type_id = 93    -- cbabu 25/07/02 for Bug#2480524
               AND (pr_new.transaction_type_id = v_misc_issue_rg_update    -- cbabu 25/07/02 for Bug#2480524
                    OR ln_projects_flag = 1    /* condition added for PROJECTS COSTING IMPL Bug#6012567(5765161)*/
                   )
              )
           OR (    pr_new.transaction_action_id = 27
               AND pr_new.transaction_source_type_id = 13
               --AND pr_new.transaction_type_id = 94    -- cbabu 25/07/02 for Bug#2480524
               AND (pr_new.transaction_type_id = v_misc_recpt_rg_update    -- cbabu 25/07/02 for Bug#2480524
                   OR ln_projects_flag = 1   /* condition added for PROJECTS COSTING IMPL Bug#6012567(5765161)*/
                 )
              )
           -- cbabu for Bug# 2851028, to handle Move Order Issue transaction
           OR (    pr_new.transaction_action_id = 1
               AND pr_new.transaction_source_type_id = 4
               AND pr_new.transaction_type_id = 63
              )
          )
       THEN
          IF  v_bonded_curr = 'N' AND v_trading_curr = 'N' THEN
             RETURN;
          END IF;

          IF  (    pr_new.transaction_action_id = 1
              AND pr_new.transaction_source_type_id = 13
              --AND pr_new.transaction_type_id = 93   -- cbabu 25/07/02 for Bug#2480524
              AND (pr_new.transaction_type_id = v_misc_issue_rg_update    -- cbabu 25/07/02 for Bug#2480524
                     OR  ln_projects_flag = 1    /* condition added for PROJECTS COSTING IMPL Bug#6012567(5765161)*/
                )
              )
           -- cbabu for Bug# 2851028, to handle Move Order Issue transaction
           OR (    pr_new.transaction_action_id = 1
               AND pr_new.transaction_source_type_id = 4
               AND pr_new.transaction_type_id = 63
              )
          THEN
             v_t_type := 'I';
             v_iss_qty := ABS (v_new_trans_qty);
             v_iss_id := pr_new.transaction_id;
             v_iss_date := pr_new.transaction_date;
             v_rec_id := NULL;
             v_rec_qty := NULL;
             v_rec_date := NULL;
          ELSIF      pr_new.transaction_action_id = 27
                 AND pr_new.transaction_source_type_id = 13
                 --AND pr_new.transaction_type_id = 94    -- cbabu 25/07/02 for Bug#2480524
                 AND (pr_new.transaction_type_id = v_misc_recpt_rg_update    -- cbabu 25/07/02 for Bug#2480524
                     OR ln_projects_flag = 1    /* condition added for PROJECTS COSTING IMPL Bug#6012567(5765161)*/
                    )
          THEN
             v_t_type := 'R';
             v_iss_qty := NULL;
             v_iss_id := NULL;
             v_iss_date := NULL;
             v_rec_id := pr_new.transaction_id;
             v_rec_qty := v_new_trans_qty;
             v_rec_date := pr_new.transaction_date;
          END IF;

          IF NVL (v_trading_curr, 'N') = 'Y' THEN
             IF NVL (v_item_trading_flag, 'N') = 'Y' THEN
                --cal proc for RG23D entry
                jai_cmn_rg_23d_trxs_pkg.make_entry (
                   pr_new.organization_id,
                   v_loc_id,
                   v_t_type,
                   pr_new.inventory_item_id,
                   pr_new.subinventory_code,
                   v_pr_uom_code,
                   pr_new.transaction_uom,
                   v_rec_id,
                   v_rec_date,
                   v_rec_qty,
                   pr_new.transaction_type_id,
                   v_iss_id,
                   v_iss_date,
                   v_iss_qty,
                   pr_new.transaction_date,
                   pr_new.creation_date,
                   pr_new.created_by,
                   pr_new.last_update_date,
                   pr_new.last_update_login,
                   pr_new.last_updated_by
                );
             END IF;
          ELSE
             IF ( v_excise_flag = 'Y'
                   AND v_item_class IN ('RMIN', 'RMEX')
                    AND v_t_type = 'I'
                   )
                OR ( v_modvat_flag = 'Y'
                    AND v_item_class IN ('RMIN', 'RMEX')
                    AND v_t_type = 'R'
                   )
             THEN
                v_reg_type := 'A';
             ELSIF  v_excise_flag = 'Y' AND v_item_class IN ('CGIN', 'CGEX') THEN
                v_reg_type := 'C';
             END IF;

             IF    ( v_excise_flag = 'Y'
                    AND v_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX')
                    AND v_t_type = 'I'
                   )
                OR ( v_modvat_flag = 'Y'
                    AND v_item_class IN ('CGIN', 'CGEX', 'RMIN', 'RMEX')
                    AND v_t_type = 'R'
                   )
             THEN
                /*Bug 9550254 - Start*/
                /*
                OPEN srno_i_cur(pr_new.organization_id, pr_new.inventory_item_id, v_loc_id, v_reg_type, v_f_year );
                FETCH srno_i_cur INTO v_srno;
                CLOSE srno_i_cur;
                */
                /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
                v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
 	                                                               v_f_year,v_reg_type,v_srno);

                /*Bug 9550254 - End*/

                IF NVL (v_srno, 0) = 0 THEN
                   v_srno := 1;
                   v_sr_no := 0;
                ELSE
                   v_sr_no := v_srno;
                   v_srno := v_srno + 1;
                END IF;

                IF v_sr_no = 0 THEN
                   /*Bug 9550254 - Start*/
                   -- v_opening_qty := 0;
                   -- v_closing_qty := v_new_trans_qty;
                   v_closing_qty := v_opening_qty + v_new_trans_qty;
                   /*Bug 9550254 - End*/
                ELSE
                   OPEN opening_balance_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_sr_no, v_loc_id,
                      v_reg_type, v_f_year );
                   FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                   CLOSE opening_balance_cur;

                   IF NVL (v_cl_qty, 0) <> 0 THEN
                      v_opening_qty := v_cl_qty;
                      v_closing_qty := v_cl_qty + v_new_trans_qty;
                   ELSE
                      v_opening_qty := 0;
                      v_closing_qty := v_new_trans_qty;
                   END IF;
                END IF;

    /*Bug 9122545*/
    OPEN  loc_id_cur (pr_new.subinventory_code, pr_new.organization_id);
    FETCH loc_id_cur INTO v_loc_id;
    CLOSE loc_id_cur;

    IF v_loc_id IS NULL THEN
      v_loc_id := 0;
    END IF;

    OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
    FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
    CLOSE c_org_addl_rg_flag ;

    IF lv_allow_negative_rg_flag = 'N'
    THEN
    if v_closing_qty < 0 then
    APP_EXCEPTION.RAISE_EXCEPTION('JA', -20110, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||pr_new.organization_id||','||v_loc_id);
    end if;
    END IF;
    /*End bug 9122545*/
                INSERT INTO JAI_CMN_RG_23AC_I_TRXS
              (register_id, fin_year, slno,
               last_update_date, last_updated_by, creation_date,
               created_by, last_update_login,
               TRANSACTION_SOURCE_NUM, inventory_item_id,
               organization_id, transaction_type, range_no,
               division_no, GOODS_ISSUE_ID_REF, goods_issue_date,
               goods_issue_quantity, OTH_RECEIPT_ID_REF,
               oth_receipt_date, oth_receipt_quantity,
               register_type, location_id, transaction_uom_code,
               transaction_date, opening_balance_qty,
               closing_balance_qty, primary_uom_code)
           VALUES (JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
               pr_new.last_update_date, pr_new.last_updated_by, SYSDATE,
               pr_new.created_by, pr_new.last_update_login,
               pr_new.transaction_type_id, pr_new.inventory_item_id,
               pr_new.organization_id, v_t_type, v_range_no,
               v_division_no, v_iss_id, v_iss_date,
               round(v_iss_qty,5), v_rec_id,
               v_rec_date,   round(v_rec_qty,5),
               v_reg_type, v_loc_id, pr_new.transaction_uom,
               TRUNC (pr_new.transaction_date),   round(v_opening_qty,5),
                 round(v_closing_qty,5), v_pr_uom_code);
             END IF;                         /** ADDED BY SRIRAM ON 04-MAY-2001 **/


      /**    ELSIF (v_excise_flag = 'Y' AND v_item_class IN ('FGIN','FGEX','CCIN') AND v_t_type = 'I')
        OR
        (v_modvat_flag = 'Y' AND v_item_class IN ('FGIN','FGEX','CCIN') AND v_t_type = 'R')
      */ -- END ADDITION BY SRIRAM ON 04-MAY-2001

        --The above changes are made to resolve the problem of CCIN items
        --are not appearing in RG1 register when an miscelaneous issue or receipt is made

             IF ( v_excise_flag = 'Y'
                    --AND v_item_class IN ('FGIN', 'FGEX', 'CCIN')  --Changed by Nagaraj.s for Bug#2649405
                    --These lines are incorporated by Nagaraj.s for Bug#2649405
                    AND v_item_class IN ('FGIN', 'FGEX')
                    AND v_t_type = 'I'
                   )
                OR ( v_modvat_flag = 'Y'
                    --AND v_item_class IN ('FGIN', 'FGEX', 'CCIN') --Commented by Nagaraj.s for Bug#2649405
                    AND v_item_class IN ('FGIN', 'FGEX', 'CCIN','CCEX') --Added by Nagaraj.s for Bug#2649405
                    AND v_t_type = 'R'
                   )
             THEN

                IF v_item_class IN ('FGIN') THEN

                   IF v_t_type = 'I' THEN
                      v_trans_qty := ABS (v_new_trans_qty);
                   ELSIF v_t_type = 'R' THEN
                      v_trans_qty := NULL;
                   END IF;

                ELSIF v_item_class IN ('FGEX') THEN

                   IF v_t_type = 'I' THEN
                      v_t_qty := v_new_trans_qty;
                      v_trans_qty := v_t_qty;
                   ELSIF v_t_type = 'R' THEN
                      v_t_qty := NULL;
                   END IF;

             ---start addition by Sriram on 04-may-2001

                ELSIF v_item_class IN ('CCIN','CCEX') THEN

                   IF v_t_type = 'I' THEN
                      v_mis_qty := v_new_trans_qty;
                      v_trans_qty := v_mis_qty;
                   ELSIF v_t_type = 'R' THEN
                      v_mis_qty := NULL;
                   END IF;

             --- end addition by Sriram on 04-may-2001

                END IF;

                /*Bug 9550254 - Start*/
                /*
                OPEN srno_ii_cur (v_loc_id, v_f_year);
                FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
                CLOSE srno_ii_cur;
                */
                /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
                v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,v_srno,v_bal_packed);
                /*Bug 9550254 - Start*/

                IF NVL (v_srno, 0) = 0 THEN
                   v_srno := 1;
                   v_sr_no := 0;
                ELSE
                   v_sr_no := v_srno;
                   v_srno := v_srno + 1;
                END IF;

                IF v_t_type = 'I' THEN

                   /**   v_manu_qty := NULL;
                         v_manu_pkd_qty := NULL;
                         v_manu_loose_qty := NULL;
                    **/ --COMMENTED BY SRIRAM ON 07-MAY-2001

            --ADDED BY SRIRAM ON 07-MAY-2001

                   --   v_manu_qty := v_new_trans_qty; commented by Sriram on 24-Dec-01
                   v_manu_qty := 0; --add by Sriram on 24-Dec-01
                   v_manu_pkd_qty := 0;
                   v_manu_loose_qty := 0;
            --END ADDING BY SRIRAM ON 07-MAY-2001

                   IF (  NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0) ) >= ABS (v_new_trans_qty) THEN
                      IF NVL (v_bal_loose, 0) > ABS (v_new_trans_qty) THEN
                         v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));

                      ELSE
                         v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));
                         v_bal_packed := NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0);
                         v_bal_loose := 0;

                      END IF;

                   ELSE
                      v_bal_packed := NVL (v_bal_packed, 0) - ABS (NVL (v_new_trans_qty, 0));
                      v_bal_loose :=   NVL (v_bal_loose, 0) + NVL (v_bal_packed, 0);
                      v_bal_packed := 0;
                   END IF;

                ELSIF v_t_type = 'R' THEN
                   v_manu_qty := v_new_trans_qty;
                   v_manu_pkd_qty := 0;
                   v_manu_loose_qty := v_new_trans_qty;

            --    v_bal_packed := NVL(v_bal_packed,0) + NVL(v_manu_pkd_qty,0);
                   v_bal_loose :=   NVL (v_bal_loose, 0) + NVL (v_new_trans_qty, 0);
                END IF;
                -- jai_cmn_utils_pkg.print_log('rg1.log','before 2');
                INSERT INTO JAI_CMN_RG_I_TRXS(
                            register_id, fin_year, slno, manufactured_qty,
                             manufactured_packed_qty, manufactured_loose_qty,
                             balance_packed, balance_loose,
                             to_other_factory_n_pay_ed_qty,
                             for_export_n_pay_ed_qty, last_update_date,
                             last_updated_by, creation_date, created_by,
                             last_update_login, TRANSACTION_SOURCE_NUM,
                             inventory_item_id, organization_id,
                             transaction_type, range_no, division_no, location_id,
                             transaction_uom_code, transaction_date,
                             primary_uom_code,
                             REF_DOC_NO   -- cbabu 25/07/02 for Bug#2480524
                ) VALUES (JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno, round(ABS(v_manu_qty),5),
                             round(ABS(v_manu_pkd_qty),5), round(ABS(v_manu_loose_qty),5),
                             round(v_bal_packed,5), round(v_bal_loose,5),
                             round(ABS (v_trans_qty),5),
                             round(v_t_qty,5), pr_new.last_update_date,
                             pr_new.last_updated_by, SYSDATE, pr_new.created_by,
                             pr_new.last_update_login, pr_new.transaction_type_id,
                             pr_new.inventory_item_id, pr_new.organization_id,
                             v_t_type, v_range_no, v_division_no, v_loc_id,
                             pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
                             v_pr_uom_code,
                             pr_new.transaction_id  -- cbabu 25/07/02 for Bug#2480524
                );

             --This Whole Block is included by Nagaraj.s for Bug#2649405

             ELSIF ( v_excise_flag = 'Y'
                    AND v_item_class IN ('CCIN', 'CCEX')
                    AND v_t_type = 'I'
                   ) THEN

                   v_reg_type := 'A';
                   -- This is assigned as 'A' as per the Functional Input of this bug.
                /*Bug 9550254 - Start*/
                /*
                OPEN srno_i_cur(pr_new.organization_id, pr_new.inventory_item_id, v_loc_id, v_reg_type, v_f_year );
                FETCH srno_i_cur INTO v_srno;
                CLOSE srno_i_cur;
                */
                /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
                v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
                                                                   v_f_year,v_reg_type,v_srno);
                /*Bug 9550254 - End*/
                IF NVL (v_srno, 0) = 0 THEN
                   v_srno := 1;
                   v_sr_no := 0;
                ELSE
                   v_sr_no := v_srno;
                   v_srno := v_srno + 1;
                END IF;

                IF v_sr_no = 0 THEN
                   /*Bug 9550254 - Start*/
                   -- v_opening_qty := 0;
                   -- v_closing_qty := v_new_trans_qty;
                   v_closing_qty := v_opening_qty;
                   /*Bug 9550254 - End*/
                ELSE
                   OPEN opening_balance_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_sr_no, v_loc_id,
                      v_reg_type, v_f_year );
                   FETCH opening_balance_cur INTO v_opening_qty, v_closing_qty;
                   CLOSE opening_balance_cur;

                   v_opening_qty := v_closing_qty;
                END IF;

                IF v_closing_qty >0 then
                   -- There exists some balance in RG23 part I A

             IF v_closing_qty >= ABS(v_new_trans_qty) then

              -- balance is enough in RG23 Part I A
                v_hit_rg23_qty := ABS(v_new_trans_qty);
                v_hit_rg1_qty  := 0;

             ELSIF v_closing_qty <ABS(v_new_trans_qty) then
              -- balance is not enough in RG23 Part I A, find how much can be hit from here and the rest
              -- from RG1. RG1 can go negative also(functional input for this bug) ,
              -- so no need to check balance there.

               v_hit_rg23_qty := v_closing_qty;
               v_hit_rg1_qty  := ABS(v_new_trans_qty) - v_hit_rg23_qty;

             END IF;

                ELSE

            -- No balance in Rg23 Part 1 A, so the whole quantity to hit RG1.
             v_hit_rg23_qty :=0;
             v_hit_rg1_qty  := ABS(v_new_trans_qty);

                END IF;

                IF v_hit_rg23_qty > 0 THEN
       /*bug 9122545*/
       OPEN  loc_id_cur (pr_new.subinventory_code, pr_new.organization_id);
       FETCH loc_id_cur INTO v_loc_id;
       CLOSE loc_id_cur;

        IF v_loc_id IS NULL THEN
	   v_loc_id := 0;
	END IF;

      OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
      FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
      CLOSE c_org_addl_rg_flag ;

      IF lv_allow_negative_rg_flag = 'N'
      THEN
      if NVL(v_opening_qty,0) -NVL(v_hit_rg23_qty,0) < 0 then
        APP_EXCEPTION.RAISE_EXCEPTION('JA', -20111, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||pr_new.organization_id||','||v_loc_id);
      end if;
      END IF;
       /*end bug 9122545*/
                 INSERT INTO JAI_CMN_RG_23AC_I_TRXS
              (register_id,
              fin_year,
              slno,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              TRANSACTION_SOURCE_NUM,
              inventory_item_id,
              organization_id,
              transaction_type, range_no,
              division_no,
              GOODS_ISSUE_ID_REF,
              goods_issue_date,
              goods_issue_quantity,
              OTH_RECEIPT_ID_REF,
              oth_receipt_date,
              oth_receipt_quantity,
              register_type,
              location_id,
              transaction_uom_code,
              transaction_date,
              opening_balance_qty,
              closing_balance_qty,
              primary_uom_code)
           VALUES (JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL,
                   v_f_year,
                   v_srno,
               pr_new.last_update_date,
               pr_new.last_updated_by,
               SYSDATE,
               pr_new.created_by,
               pr_new.last_update_login,
               pr_new.transaction_type_id,
               pr_new.inventory_item_id,
               pr_new.organization_id,
               v_t_type,
               v_range_no,
               v_division_no,
               v_iss_id,
               v_iss_date,
               round(v_hit_rg23_qty,5),
               v_rec_id,
               v_rec_date,
               0,
               v_reg_type,
               v_loc_id,
               pr_new.transaction_uom,
               TRUNC (pr_new.transaction_date),
               round( v_opening_qty,5),
              round( NVL(v_opening_qty,0) -NVL(v_hit_rg23_qty,0),5),
               v_pr_uom_code);
                  END IF; -- End if for v_hit_rg23_qty


                  IF v_hit_rg1_qty >0 THEN
                   v_mis_qty := v_new_trans_qty;
                   v_trans_qty := v_mis_qty;
                   /*Bug 9550254 - Start*/
                   /*
                   OPEN srno_ii_cur (v_loc_id, v_f_year);
                   FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
                   CLOSE srno_ii_cur;
                   */
                   /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
                   v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,
                                                                  v_srno,v_bal_packed);
                   /*Bug 9550254 - End*/

                   IF NVL (v_srno, 0) = 0 THEN
                    v_srno := 1;
                    v_sr_no := 0;
                   ELSE
                    v_sr_no := v_srno;
                    v_srno := v_srno + 1;
                   END IF;
                   v_manu_qty := 0; --add by Sriram on 24-Dec-01
                   v_manu_pkd_qty := 0;
                   v_manu_loose_qty := 0;

                   IF (  NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0) ) >= ABS (v_hit_rg1_qty) THEN
                      IF NVL (v_bal_loose, 0) > ABS (v_hit_rg1_qty) THEN
                         v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_hit_rg1_qty, 0));

                      ELSE
                         v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_hit_rg1_qty, 0));
                         v_bal_packed := NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0);
                         v_bal_loose := 0;

                      END IF;

                   ELSE
                      v_bal_packed := NVL (v_bal_packed, 0) - ABS (NVL (v_hit_rg1_qty, 0));
                      v_bal_loose :=   NVL (v_bal_loose, 0) + NVL (v_bal_packed, 0);
                      v_bal_packed := 0;
                   END IF;


                -- jai_cmn_utils_pkg.print_log('rg1.log','before 3');
                INSERT INTO JAI_CMN_RG_I_TRXS(
                            register_id, fin_year, slno, manufactured_qty,
                             manufactured_packed_qty, manufactured_loose_qty,
                             balance_packed, balance_loose,
                             --to_other_factory_n_pay_ed_qty, Commented by Nagaraj.s for Bug#2744695
                             other_purpose_n_pay_ed_qty, --Added by Nagaraj.s for Bug#2744695
                             for_export_n_pay_ed_qty, last_update_date,
                             last_updated_by, creation_date, created_by,
                             last_update_login, TRANSACTION_SOURCE_NUM,
                             inventory_item_id, organization_id,
                             transaction_type, range_no, division_no, location_id,
                             transaction_uom_code, transaction_date,
                             primary_uom_code,
                             REF_DOC_NO   -- cbabu 25/07/02 for Bug#2480524
                ) VALUES (JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno, round(ABS(v_manu_qty),5),
                             round(ABS(v_manu_pkd_qty),5),round( ABS(v_manu_loose_qty),5),
                             round(v_bal_packed,5), round(v_bal_loose,5),
                             round(ABS (v_hit_rg1_qty),5),
                             round(v_t_qty,5), pr_new.last_update_date,
                             pr_new.last_updated_by, SYSDATE, pr_new.created_by,
                             pr_new.last_update_login, pr_new.transaction_type_id,
                             pr_new.inventory_item_id, pr_new.organization_id,
                             v_t_type, v_range_no, v_division_no, v_loc_id,
                             pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
                             v_pr_uom_code,
                             pr_new.transaction_id  -- cbabu 25/07/02 for Bug#2480524
                );
                  END IF; -- End if for v_hit_rg1_qty
             --Ends here by Nagaraj.s for Bug#2649405....

             END IF;

          END IF;

      -- KKK
    ---4th, 5th, 6th, 7th, 8th, 9th,10th case starts here
      /*
      4. WIP component issue.   : transaction_action_id -> 1, transaction_source_type_id -> 5, transaction_type_id -> 35
      5. WIP Component Return.
      6. WIP Assembly Completion.
      7. WIP Assembly Return.
      8. WIP Negative Component Issue.
      9. WIP Negative Component Return.
      10.WIP Scrap Transaction.
      */
       ELSIF (   (    pr_new.transaction_action_id = 1
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 27
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 31
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 32
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 33
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 34
                  AND pr_new.transaction_source_type_id = 5
                 )
              OR (    pr_new.transaction_action_id = 30
                  AND pr_new.transaction_source_type_id = 5
                 )
             )
       THEN

          IF v_trading_curr = 'Y' THEN
/*              raise_application_error (-20108, 'Subinventory Cannot be Trading');
          */ pv_return_code := jai_constants.expected_error ; pv_return_message :=  'Subinventory Cannot be Trading' ; return ;
          END IF;

          IF v_bonded_curr = 'N' THEN
             RETURN;
          END IF;

          IF (   (    pr_new.transaction_action_id = 1
                  AND pr_new.transaction_source_type_id = 5
                 )

                 --Commented by bgowrava for Forward porting bug#5275865
            /*  OR (    pr_new.transaction_action_id = 32
                  AND pr_new.transaction_source_type_id = 5
                 ) */
              OR (    pr_new.transaction_action_id = 34
                  AND pr_new.transaction_source_type_id = 5
                 )
             )
          THEN
             v_t_type := 'PI';
             v_iss_qty := ABS (v_new_trans_qty);
             v_iss_id := pr_new.transaction_id;
             v_iss_date := pr_new.transaction_date;
             v_rec_id := NULL;
             v_rec_qty := NULL;
             v_rec_date := NULL;

          ELSIF (   (    pr_new.transaction_action_id = 27
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 31
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 33
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 30
                     AND pr_new.transaction_source_type_id = 5
                    )
                    -- added by bgowrava for Forward porting bug#5275865
                 OR (    pr_new.transaction_action_id = 32
                     AND pr_new.transaction_source_type_id = 5
                    )
                )
          THEN

    /* redundant Check Commented by Vijay Shankar for Bug# 2915814Z
             IF (   (    pr_new.transaction_action_id = 27
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 33
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 31
                     AND pr_new.transaction_source_type_id = 5
                    )
                 OR (    pr_new.transaction_action_id = 30
                     AND pr_new.transaction_source_type_id = 5
                    )
                )
             THEN
                v_t_type := 'PR';

    -- commented on 12-feb-00 for wip assembly completion to be PR
    --      ELSIF pr_new.transaction_action_id = 31 and pr_new.transaction_source_type_id = 5
    --      THEN
    --        v_t_type    := 'R';
    --
             END IF;
    */
             v_t_type := 'PR';
             v_iss_qty := NULL;
             v_iss_id := NULL;
             v_iss_date := NULL;
             v_rec_id := pr_new.transaction_id;
             v_rec_qty := v_new_trans_qty;
             v_rec_date := pr_new.transaction_date;
          END IF;

          IF    (    v_excise_flag = 'Y'
                 AND v_item_class IN ('RMIN', 'RMEX', 'CGIN', 'CGEX')
                 AND v_t_type = 'PI'
                )
             OR (    v_modvat_flag = 'Y'
                 AND v_item_class IN ('RMIN', 'RMEX', 'CGIN', 'CGEX')
                 AND v_t_type IN ('PR', 'R')
                )
          THEN
             IF v_item_class IN ('RMIN', 'RMEX') THEN
                v_reg_type := 'A';

             ELSIF v_item_class IN ('CGIN', 'CGEX') THEN
                v_reg_type := 'C';
             END IF;
             /*Bug 9550254 - Start*/
             /*
             OPEN srno_i_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_loc_id, v_reg_type, v_f_year );
             FETCH srno_i_cur INTO v_srno;
             CLOSE srno_i_cur;
             */
             /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
             v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
 	                                                            v_f_year,v_reg_type,v_srno);
             /*Bug 9550254 - End*/
             IF NVL (v_srno, 0) = 0 THEN
                v_srno := 1;
                v_sr_no := 0;
             ELSE
                v_sr_no := v_srno;
                v_srno := v_srno + 1;
             END IF;

             IF v_sr_no = 0 THEN
                /*Bug 9550254 - Start*/
                -- v_opening_qty := 0;
                -- v_closing_qty := v_new_trans_qty;
                v_closing_qty := v_opening_qty + v_new_trans_qty;
                /*Bug 9550254 - End*/
             ELSE
                OPEN opening_balance_cur( pr_new.organization_id, pr_new.inventory_item_id, v_sr_no, v_loc_id, v_reg_type, v_f_year );
                FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                CLOSE opening_balance_cur;

                IF NVL (v_cl_qty, 0) <> 0 THEN
                   v_opening_qty := v_cl_qty;
                   v_closing_qty :=   v_cl_qty
                                    + v_new_trans_qty;
                ELSE
                   v_opening_qty := 0;
                   v_closing_qty := v_new_trans_qty;
                END IF;
             END IF;

	/*bug 9122545*/
	OPEN  loc_id_cur (pr_new.subinventory_code, pr_new.organization_id);
	FETCH loc_id_cur INTO v_loc_id;
	CLOSE loc_id_cur;

	IF v_loc_id IS NULL THEN
	 v_loc_id := 0;
	END IF;

	OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
	FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
	CLOSE c_org_addl_rg_flag ;

	IF lv_allow_negative_rg_flag = 'N'
	THEN
	if v_closing_qty < 0 then
	APP_EXCEPTION.RAISE_EXCEPTION('JA', -20112, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||pr_new.organization_id||','||v_loc_id);
	end if;
	END IF;
	/*end bug 9122545*/
        INSERT INTO JAI_CMN_RG_23AC_I_TRXS (
          register_id, fin_year, slno,
          last_update_date, last_updated_by, creation_date,
          created_by, last_update_login,
          TRANSACTION_SOURCE_NUM, inventory_item_id,
          organization_id, transaction_type, range_no,
          division_no, GOODS_ISSUE_ID_REF, goods_issue_date,
          goods_issue_quantity, OTH_RECEIPT_ID_REF, oth_receipt_date,
          oth_receipt_quantity, register_type, location_id,
          transaction_uom_code, transaction_date,
          opening_balance_qty, closing_balance_qty,
          primary_uom_code
        ) VALUES (
          JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
          pr_new.last_update_date, pr_new.last_updated_by, SYSDATE,
          pr_new.created_by, pr_new.last_update_login,
          pr_new.transaction_type_id, pr_new.inventory_item_id,
          pr_new.organization_id, v_t_type, v_range_no,
          v_division_no, v_iss_id, v_iss_date,
          round(v_iss_qty,5), v_rec_id, v_rec_date,
          round(v_rec_qty,5), v_reg_type, v_loc_id,
          pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
          round(v_opening_qty,5),round( v_closing_qty,5),
          v_pr_uom_code
        );

          ELSIF (    v_excise_flag = 'Y'
                    -- AND v_item_class IN ('CCIN', 'CCEX', 'FGIN', 'FGEX')    commented by Vijay Shankar for Bug# 2915814Z
                    AND v_item_class IN ('FGIN', 'FGEX')
                    AND v_t_type = 'PI'
                   )
                OR (    v_modvat_flag = 'Y'
                    AND v_item_class IN ('CCIN', 'CCEX', 'FGIN', 'FGEX')
                    AND v_t_type IN ('PR', 'R')
                   )
          THEN
             --This IF Clause is commented and replace by the One below
             --By Nagaraj.s for Bug#2744695.
             /*
             IF v_item_class IN ('FGIN', 'CCIN')
             THEN
                --v_trans_qty := v_new_trans_qty; --commented by Sriram on 23-may-01

                v_trans_qty := NULL; --Start addition by Sriram on 23-may-01
             */

             IF v_item_class IN ('FGIN') THEN
          V_TRANS_QTY := NULL;

             ELSIF v_item_class IN ('CCIN') THEN
                V_TRANS_QTY := ABS(V_NEW_TRANS_QTY);

             ELSIF v_item_class IN ('FGEX', 'CCEX') THEN
                /**v_t_qty := v_new_trans_qty;**/ --commented by sriram on 23-may-01

                v_t_qty := NULL; --Start addition by Sriram on 23-may-01
             END IF;
             /*Bug 9550254 - Start*/
             /*
             OPEN srno_ii_cur (v_loc_id, v_f_year);
             FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
             CLOSE srno_ii_cur;
             */
             /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
             v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,
 	                                                        v_srno,v_bal_packed);

             /*Bug 9550254 - End*/

             IF NVL (v_srno, 0) = 0 THEN
                v_srno := 1;
                v_sr_no := 0;
                /*Commented for Bug 9550254 as they are calculated via jai_om_rg_pkg.ja_in_rgi_balance above*/
                --v_bal_packed := 0;
                --v_bal_loose := 0;
             ELSE
                v_sr_no := v_srno;
                v_srno := v_srno + 1;
             END IF;

             IF v_new_trans_qty < 0 THEN
                v_manufactured_qty := 0;
                v_manufactured_pack_qty := NULL;
                v_manu_loose_qty := NULL;
                OPEN fetch_type_name (pr_new.transaction_type_id);
                FETCH fetch_type_name INTO v_oth_purpose;
                CLOSE fetch_type_name;

          -- v_oth_pur_npe_qty := abs(v_new_trans_qty); commented by Sriram on 22-may-01

          /** Added by Sriram on 15-OCT-01 **/
                v_manu_qty := 0; --add by Sriram on 23-dec-01
                -- v_manu_qty := v_new_trans_qty;
                v_manu_pkd_qty := 0;
                v_manu_loose_qty := ABS (v_new_trans_qty);

          /** End addition by Sriram on 15-OCT-01 **/

          /*  Added by Satya on 23-Oct-01   */
                IF ( pr_new.transaction_action_id = 32 AND pr_new.transaction_source_type_id = 5 ) THEN
                   v_manu_loose_qty := v_new_trans_qty;
                   v_manu_home_qty := NULL;
                   v_manu_pkd_qty := 0;
                   v_manufactured_qty := v_new_trans_qty; --adde by Sriram on 26-Dec-2001
                END IF;

                IF (  NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0) ) >= ABS (v_new_trans_qty) THEN
                   IF NVL (v_bal_loose, 0) >= ABS (v_new_trans_qty) THEN
                      v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));

                   ELSE
                      v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));
                      v_bal_packed := NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0);
                   END IF;

                ELSE
                   v_bal_packed := NVL (v_bal_packed, 0) - ABS (NVL (v_new_trans_qty, 0));
                   v_bal_loose := NVL (v_bal_loose, 0) + NVL (v_bal_packed, 0);
                   v_bal_packed := 0;
                END IF;

        /*  End of Addition by Satya on 23-Oct-01   */

             ELSE
                v_manufactured_qty := v_new_trans_qty;
                v_manufactured_pack_qty := 0;
                v_manu_loose_qty := v_manufactured_qty;
                v_bal_packed :=
                           NVL (v_bal_packed, 0)
                         + NVL (v_manufactured_pack_qty, 0);
                v_bal_loose :=   NVL (v_bal_loose, 0)
                               + NVL (v_manu_loose_qty, 0);
                v_oth_pur_npe_qty := 0;

          /** Added by Sriram on 15-OCT-01 **/
                v_manu_qty := v_new_trans_qty;
                v_manu_pkd_qty := 0;
                v_manu_loose_qty := v_new_trans_qty;

          /** End addition by Sriram on 15-OCT-01 **/

             END IF;

         -- start added by bug#3258066
             if v_t_type IN ('PR') then
                v_manu_loose_qty := v_new_trans_qty;
                v_other_npe_qty := Null;
             elsif v_t_type IN ('PI') then
                v_other_npe_qty := v_manu_loose_qty;
                v_manu_loose_qty:= Null;
             else
                v_other_npe_qty := v_trans_qty;
             end if;
        -- End added by bug#3258066

             -- jai_cmn_utils_pkg.print_log('rg1.log','before 4');

             INSERT INTO JAI_CMN_RG_I_TRXS (
           register_id, fin_year, slno,
            manufactured_qty, manufactured_packed_qty,
            manufactured_loose_qty, balance_packed, balance_loose,
            -- other_purpose_n_pay_ed_qty, -- by sriram
            to_other_factory_n_pay_ed_qty, other_purpose,
            -- to_other_factory_n_pay_ed_qty, --bby sriram
            other_purpose_n_pay_ed_qty, for_export_n_pay_ed_qty,
            for_home_use_pay_ed_qty, --Added by Satya on 23-Oct-01
            last_update_date,
            last_updated_by, creation_date, created_by,
            last_update_login, TRANSACTION_SOURCE_NUM,
            inventory_item_id, organization_id, transaction_type,
            range_no, division_no, location_id,
            transaction_uom_code, transaction_date,
            primary_uom_code,
            REF_DOC_NO    -- cbabu 25/07/02 for Bug#2480524
             ) VALUES (JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
            round(v_manufactured_qty,5), round(v_manufactured_pack_qty,5),
            round(v_manu_loose_qty,5), round(v_bal_packed,5), round(v_bal_loose,5), -- v_manu_loose_qty changed to null by sriram bug # 3258086on product management advice.
             round(v_oth_pur_npe_qty,5), v_oth_purpose,
             round(v_other_npe_qty,5), NULL, --earlier 'PI' corresponding field is number -- put v_manu_loose_qty instead of v_trans_qty - sriram
             round(v_manu_home_qty,5), --Added by Satya on 23-Oct-01
                    pr_new.last_update_date,
            pr_new.last_updated_by, SYSDATE, pr_new.created_by,
            pr_new.last_update_login, pr_new.transaction_type_id,
            pr_new.inventory_item_id, pr_new.organization_id, v_t_type,
            v_range_no, v_division_no, v_loc_id,
            pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
            v_pr_uom_code,
            pr_new.transaction_id   -- cbabu 25/07/02 for Bug#2480524
             );


      -- Start, Vijay Shankar for Bug# 2915814Z
          ELSIF (    v_excise_flag = 'Y'
                    AND v_item_class IN ('CCIN', 'CCEX')
                    AND v_t_type = 'PI'
                   )
          THEN

             v_iss_id := pr_new.transaction_id;
             v_iss_date := pr_new.transaction_date;

             IF v_item_class IN ('CCIN') THEN
                V_TRANS_QTY := ABS(V_NEW_TRANS_QTY);

             ELSIF v_item_class IN ('CCEX') THEN
                /**v_t_qty := v_new_trans_qty;**/ --commented by sriram on 23-may-01

                v_t_qty := NULL; --Start addition by Sriram on 23-may-01
             END IF;

        v_reg_type := 'A';
        -- This is assigned as 'A' as per the Functional Input of this bug.
        /*Bug 9550254 - Start*/
        /*
        OPEN srno_i_cur(pr_new.organization_id, pr_new.inventory_item_id, v_loc_id, v_reg_type, v_f_year );
        FETCH srno_i_cur INTO v_srno;
        CLOSE srno_i_cur;
        */
        /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
        v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
 	                                                       v_f_year,v_reg_type,v_srno);
        /*Bug 9550254 - End*/
        IF v_srno = 0 THEN
           /*Bug 9550254 - Start*/
           -- v_opening_qty := 0;
           -- v_closing_qty := v_new_trans_qty;
           v_closing_qty := v_opening_qty ;
           /*Bug 9550254 - End*/
           v_srno := 1;
        ELSE
           OPEN opening_balance_cur ( pr_new.organization_id, pr_new.inventory_item_id, v_srno, v_loc_id,
              v_reg_type, v_f_year );
           FETCH opening_balance_cur INTO v_opening_qty, v_closing_qty;
           CLOSE opening_balance_cur;

           v_opening_qty := v_closing_qty;
           v_srno := v_srno + 1;
        END IF;

        IF v_closing_qty > 0 THEN
           -- There exists some balance in RG23 part I A

          IF v_closing_qty >= ABS(v_new_trans_qty) THEN

            -- balance is enough in RG23 Part I A
            v_hit_rg23_qty := ABS(v_new_trans_qty);
            v_hit_rg1_qty  := 0;
             v_closing_qty := v_closing_qty - abs(v_new_trans_qty);

          -- this is the partial case
          ELSIF v_closing_qty < ABS(v_new_trans_qty) THEN
            -- balance is not enough in RG23 Part I A, find how much can be hit from here and the rest
            -- from RG1. RG1 can go negative also(functional input for this bug) ,
            -- so no need to check balance there.

            v_hit_rg23_qty := v_closing_qty;
            v_hit_rg1_qty  := ABS(v_new_trans_qty) - v_hit_rg23_qty;
             v_closing_qty := 0;

          END IF;

        ELSE

          -- No balance in Rg23 Part 1 A, so the whole quantity to hit RG1.
          v_hit_rg23_qty :=0;
          v_hit_rg1_qty  := ABS(v_new_trans_qty);

          -- here closing quantity for RG23 need not be set because if the execution comes here, then it is not going to hit RG23 Part I
        END IF;

        IF v_hit_rg23_qty > 0 THEN

              v_iss_qty := v_hit_rg23_qty;

   /*bug 9122545*/
   OPEN  loc_id_cur (pr_new.subinventory_code, pr_new.organization_id);
   FETCH loc_id_cur INTO v_loc_id;
   CLOSE loc_id_cur;

   IF v_loc_id IS NULL THEN
     v_loc_id := 0;
   END IF;

   OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
   FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
   CLOSE c_org_addl_rg_flag ;

   IF lv_allow_negative_rg_flag = 'N'
   THEN
   if v_closing_qty < 0 then
   APP_EXCEPTION.RAISE_EXCEPTION('JA', -20113, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||pr_new.organization_id||','||v_loc_id);
   end if;
   END IF;
   /*end bug 9122545*/
          INSERT INTO JAI_CMN_RG_23AC_I_TRXS (
            register_id, fin_year, slno,
            last_update_date, last_updated_by, creation_date,
            created_by, last_update_login,
            TRANSACTION_SOURCE_NUM, inventory_item_id,
            organization_id, transaction_type, range_no,
            division_no, GOODS_ISSUE_ID_REF, goods_issue_date,
            goods_issue_quantity, OTH_RECEIPT_ID_REF, oth_receipt_date,
            oth_receipt_quantity, register_type, location_id,
            transaction_uom_code, transaction_date,
            opening_balance_qty, closing_balance_qty,
            primary_uom_code
          ) VALUES (
            JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
            pr_new.last_update_date, pr_new.last_updated_by, SYSDATE,
            pr_new.created_by, pr_new.last_update_login,
            pr_new.transaction_type_id, pr_new.inventory_item_id,
            pr_new.organization_id, v_t_type, v_range_no,
            v_division_no, v_iss_id, v_iss_date,
             round(v_iss_qty,5), null, null,
            null, v_reg_type, v_loc_id,
            pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
             round(v_opening_qty,5), round( v_closing_qty,5),
            v_pr_uom_code
          );

        END IF;

        IF v_hit_rg1_qty >0 THEN

          v_new_trans_qty := -v_hit_rg1_qty;    -- quantity should be negetive because this is an issue transaction

          IF v_item_class IN ('CCIN') THEN
            v_trans_qty := abs(v_new_trans_qty);
          END IF;

          v_sr_no := null;
          v_srno := null;
          v_bal_packed := null;
          v_bal_loose := null;
          /*Bug 9550254 - Start*/
          /*
          OPEN srno_ii_cur (v_loc_id, v_f_year);
          FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
          CLOSE srno_ii_cur;
          */
          /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
          v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,
 	                                                     v_srno,v_bal_packed);
          /*Bug 9550254 - End*/
          IF NVL (v_srno, 0) = 0 THEN
            v_srno := 1;
            /*Bug 9550254 - Commented the below as it is already calculated via jai_om_rg_pkg.ja_in_rgi_balance*/
            -- v_bal_packed := 0;
            -- v_bal_loose := 0;
          ELSE
            v_srno := v_srno + 1;
          END IF;

          v_manufactured_qty := 0;
          v_manufactured_pack_qty := NULL;
          v_manu_loose_qty := NULL;

          OPEN fetch_type_name (pr_new.transaction_type_id);
          FETCH fetch_type_name INTO v_oth_purpose;
          CLOSE fetch_type_name;

          -- v_oth_pur_npe_qty := abs(v_new_trans_qty); commented by Sriram on 22-may-01

          /** Added by Sriram on 15-OCT-01 **/
          v_manu_qty := 0; --add by Sriram on 23-dec-01
          -- v_manu_qty := v_new_trans_qty;
          v_manu_pkd_qty := 0;
          v_manu_loose_qty := ABS (v_new_trans_qty);

          /** End addition by Sriram on 15-OCT-01 **/

          /*  Added by Satya on 23-Oct-01   */
          IF ( pr_new.transaction_action_id = 32 AND pr_new.transaction_source_type_id = 5 ) THEN
            v_manu_loose_qty := v_new_trans_qty;
            v_manu_home_qty := NULL;
            v_manu_pkd_qty := 0;
            v_manufactured_qty := v_new_trans_qty; --adde by Sriram on 26-Dec-2001
          END IF;


          IF (  NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0) ) >= ABS (v_new_trans_qty) THEN
            IF NVL (v_bal_loose, 0) >= ABS (v_new_trans_qty) THEN
              v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));

            ELSE
              v_bal_loose := NVL (v_bal_loose, 0) - ABS (NVL (v_new_trans_qty, 0));
              v_bal_packed := NVL (v_bal_packed, 0) + NVL (v_bal_loose, 0);
            END IF;

          ELSE
            v_bal_packed := NVL (v_bal_packed, 0) - ABS (NVL (v_new_trans_qty, 0));
            v_bal_loose := NVL (v_bal_loose, 0) + NVL (v_bal_packed, 0);
            v_bal_packed := 0;
          END IF;


                 -- jai_cmn_utils_pkg.print_log('rg1.log','before 5');
           INSERT INTO JAI_CMN_RG_I_TRXS (
             register_id, fin_year, slno,
              manufactured_qty, manufactured_packed_qty,
              manufactured_loose_qty, balance_packed, balance_loose,
              -- other_purpose_n_pay_ed_qty, -- by sriram
              to_other_factory_n_pay_ed_qty, other_purpose,
              -- to_other_factory_n_pay_ed_qty, --bby sriram
              other_purpose_n_pay_ed_qty, for_export_n_pay_ed_qty,
              for_home_use_pay_ed_qty, --Added by Satya on 23-Oct-01
              last_update_date,
              last_updated_by, creation_date, created_by,
              last_update_login, TRANSACTION_SOURCE_NUM,
              inventory_item_id, organization_id, transaction_type,
              range_no, division_no, location_id,
              transaction_uom_code, transaction_date,
              primary_uom_code,
              REF_DOC_NO    -- cbabu 25/07/02 for Bug#2480524
           ) VALUES (JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
              round(v_manufactured_qty,5),               round(v_manufactured_pack_qty,5),
              Null,               round(v_bal_packed,5),               round(v_bal_loose,5), -- v_manu_loose_qty set to null by sriram - bug # 3258066 based on product management advice.
                            round(v_oth_pur_npe_qty,5), v_oth_purpose,
                           round( v_manu_loose_qty,5), NULL, --earlier 'PI' corresponding field is number -- v_trans_qty changed to v_manu_loose_qty by sriram - bug # 3258066 based on p.m advice.
                            round(v_manu_home_qty,5), --Added by Satya on 23-Oct-01
                      pr_new.last_update_date,
              pr_new.last_updated_by, SYSDATE, pr_new.created_by,
              pr_new.last_update_login, pr_new.transaction_type_id,
              pr_new.inventory_item_id, pr_new.organization_id, v_t_type,
              v_range_no, v_division_no, v_loc_id,
              pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
              v_pr_uom_code,
              pr_new.transaction_id   -- cbabu 25/07/02 for Bug#2480524
           );

        END IF;     -- If v_hit_rg1_qty > 0
        -- End, Vijay Shankar for Bug# 2915814Z

          END IF;
      -- KKK

       ---11th, 12th, 13th case starts here for WIP Component Return
       /*
       11.  Inventory Delivery Adjustment
       12.  Cycle Count Adjustment.
       13.  Physical Inventory Adjustment.
       In this part if item class is in RMIN,RMEX,CCIN,CGEX then record will be inserted in
       RG23 Part I with transaction type as Issue Adjustment 'IA' or Receipt Adjustemt 'RA'
       based on adjusted quantity.
       If adjusted quantity is Negative then transaction type is IA otherwise for positive
       adjusted quantity the transaction type is RA.
       In this part if item class is in FGIN, FGEX then record will be inserted in RG I
       register with transaction type as Issue Adjustment 'IA' or Receipt Adjustemt 'RA'
       based on adjusted quantity.
       If adjusted quantity is Negative then transaction type is IA otherwise for positive
       adjusted quantity the transaction type is RA.
       */
       ELSIF (   (    pr_new.transaction_action_id = 29
                  AND pr_new.transaction_source_type_id = 13
                 )
              OR (    pr_new.transaction_action_id = 4
                  AND pr_new.transaction_source_type_id = 9
                 )
              OR (    pr_new.transaction_action_id = 29
                  AND pr_new.transaction_source_type_id = 1
                 )
              OR --added for phase 2 enhancement 15/10/99 Gaurav
                (    pr_new.transaction_action_id = 29
                 AND pr_new.transaction_source_type_id = 7
                )
              OR --added for phase 2 enhancement 15/10/99 Gaurav
                (    pr_new.transaction_action_id = 8
                 AND pr_new.transaction_source_type_id = 10
                )
             )
       THEN
          IF  v_bonded_curr = 'N' AND v_trading_curr = 'N'
          THEN
             RETURN;
          END IF;
     ---start additions for bug# 8530264
      /*this trigger will fire only at the time of delivery,

      here the issue is that the delivery adjustment hitting qty register ,irrespective of the qty register entry
      has been made for the parent delivery


      correction to the delivery shall not make any register entry if the parent delivery doesnot have the
      corresponding register entry.

      Added a condition to check whether the parenty delivery has register entry or not.
      if it is not register entry will not be made for the correction to the delivery.

     :NEW.transaction_action_id = 29  AND :NEW.transaction_source_type_id = 1   --> (Delivery adjustments on a Purchase order receipt)

      *****/



      if   ( pr_new.transaction_action_id = 29
              AND pr_new.transaction_source_type_id = 1  )
      THEN
             open   get_qty_update_flag;
             fetch get_qty_update_flag into    lv_qty_register_flag;
             close get_qty_update_flag;

                if NVL(lv_qty_register_flag,'N')='N'
                then
                  return;
                end if;

     end if;

     --end additions for bug#8530264


    --    IF pr_new.quantity_adjusted < 0  -- comminted by subbu and sri on 30th nov 2000
          IF v_new_trans_qty < 0 -- added by subbu and sri on 30th nov 2000
          THEN
             v_t_type := 'IA';
             --   v_iss_qty   := abs(v_new_adjust_qty); -- comminted by subbu and Sri on 30-NOV-00
             v_iss_qty := ABS (v_new_trans_qty); -- added by subbu and Sri on 30-NOV-00
             v_iss_id := pr_new.transaction_id;
             v_iss_date := pr_new.transaction_date;
             v_rec_id := NULL;
             v_rec_qty := NULL;
             v_rec_date := NULL;
          ELSE
             v_t_type := 'RA';
             v_iss_qty := NULL;
             v_iss_id := NULL;
             v_iss_date := NULL;
             v_rec_id := pr_new.transaction_id;
             v_rec_qty := v_new_trans_qty; --v_new_adjust_qty;ssumaith -bug#6609191
             v_rec_date := pr_new.transaction_date;
          END IF;

          IF NVL (v_trading_curr, 'N') = 'Y'
          THEN
             IF NVL (v_item_trading_flag, 'N') = 'Y'
             THEN
                --cal proc for RG23D entry
                jai_cmn_rg_23d_trxs_pkg.make_entry (
                   pr_new.organization_id,
                   v_loc_id,
                   v_t_type,
                   pr_new.inventory_item_id,
                   pr_new.subinventory_code,
                   v_pr_uom_code,
                   pr_new.transaction_uom,
                   v_rec_id,
                   v_rec_date,
                   v_rec_qty,
                   pr_new.transaction_type_id,
                   v_iss_id,
                   v_iss_date,
                   v_iss_qty,
                   pr_new.transaction_date,
                   pr_new.creation_date,
                   pr_new.created_by,
                   pr_new.last_update_date,
                   pr_new.last_update_login,
                   pr_new.last_updated_by
                );
             END IF;
          ELSE
             IF    (    v_excise_flag = 'Y'
                    AND v_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')
                    AND v_t_type = 'IA'
                   )
                OR (    v_modvat_flag = 'Y'
                    AND v_item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')
                    AND v_t_type = 'RA'
                   )
             THEN
                v_reg_type := 'A';
             ELSIF    (    v_excise_flag = 'Y'
                       AND v_item_class IN ('CGIN', 'CGEX')
                       AND v_t_type = 'IA'
                      )
                   OR (    v_modvat_flag = 'Y'
                       AND v_item_class IN ('CGIN', 'CGEX')
                       AND v_t_type = 'RA'
                      )
             THEN
                v_reg_type := 'C';
             END IF;

             IF    (    v_excise_flag = 'Y'
                    AND v_item_class IN
                                      ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX')
                    AND v_t_type = 'IA'
                   )
                OR (    v_modvat_flag = 'Y'
                    AND v_item_class IN
                                      ('CGIN', 'CGEX', 'RMIN', 'RMEX', 'CCIN', 'CCEX')
                    AND v_t_type = 'RA'
                   )
             THEN
                /*Bug 9550254 - Start*/
                /*
                OPEN srno_i_cur (
                   pr_new.organization_id,
                   pr_new.inventory_item_id,
                   v_loc_id,
                   v_reg_type,
                   v_f_year
                );
                FETCH srno_i_cur INTO v_srno;
                CLOSE srno_i_cur;
                */
                /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_23AC_I_TRXS*/
                v_opening_qty := jai_om_rg_pkg.ja_in_rg23i_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,
 	                                                               v_f_year,v_reg_type,v_srno);
                /*Bug 9550254 - End*/

                IF NVL (v_srno, 0) = 0
                THEN
                   v_srno := 1;
                   v_sr_no := 0;
                ELSE
                   v_sr_no := v_srno;
                   v_srno :=   v_srno
                             + 1;
                END IF;

                IF v_sr_no = 0
                THEN
                   /*Bug 9550254 - Start*/
                   -- v_opening_qty := 0;
                   -- v_closing_qty := v_new_trans_qty;
                   v_closing_qty := v_opening_qty + v_new_trans_qty;
                   /*Bug 9550254 - End*/
                ELSE
                   OPEN opening_balance_cur (
                      pr_new.organization_id,
                      pr_new.inventory_item_id,
                      v_sr_no,
                      v_loc_id,
                      v_reg_type,
                      v_f_year
                   );
                   FETCH opening_balance_cur INTO v_op_qty, v_cl_qty;
                   CLOSE opening_balance_cur;

                   IF NVL (v_cl_qty, 0) <> 0
                   THEN
                      v_opening_qty := v_cl_qty;
                      v_closing_qty :=   v_cl_qty
                                       + v_new_trans_qty;
                   ELSE
                      v_opening_qty := 0;
                      v_closing_qty := v_new_trans_qty;
                   END IF;
                END IF;

     /*bug 9122545*/
     OPEN  loc_id_cur (pr_new.subinventory_code,pr_new.organization_id);
     FETCH loc_id_cur INTO v_loc_id;
     CLOSE loc_id_cur;

     IF v_loc_id IS NULL THEN
     v_loc_id := 0;
     END IF;

     OPEN  c_org_addl_rg_flag(pr_new.organization_id, v_loc_id) ;
     FETCH c_org_addl_rg_flag INTO lv_allow_negative_rg_flag ;
     CLOSE c_org_addl_rg_flag ;

     IF lv_allow_negative_rg_flag = 'N'
     THEN
     if v_closing_qty < 0 then
     APP_EXCEPTION.RAISE_EXCEPTION('JA', -20114, 'Enough RG23 Part1 balances do not exist. Register Type,Org,Loc-'||v_reg_type||','||pr_new.organization_id||','||v_loc_id);
     end if;
     END IF;
     /*end bug 9122545*/
                INSERT INTO JAI_CMN_RG_23AC_I_TRXS
                            (register_id, fin_year, slno,
                             last_update_date, last_updated_by, creation_date,
                             created_by, last_update_login,
                             TRANSACTION_SOURCE_NUM, inventory_item_id,
                             organization_id, transaction_type, range_no,
                             division_no, GOODS_ISSUE_ID_REF, goods_issue_date,
                             goods_issue_quantity, OTH_RECEIPT_ID_REF,
                             oth_receipt_date, oth_receipt_quantity,
                             register_type, location_id, transaction_uom_code,
                             transaction_date, opening_balance_qty,
                             closing_balance_qty, primary_uom_code)
                     VALUES (JAI_CMN_RG_23AC_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
                             pr_new.last_update_date, pr_new.last_updated_by, SYSDATE,
                             pr_new.created_by, pr_new.last_update_login,
                             pr_new.transaction_type_id, pr_new.inventory_item_id,
                             pr_new.organization_id, v_t_type, v_range_no,
                             v_division_no, v_iss_id, v_iss_date,
                            round( v_iss_qty,5), v_rec_id,
                             v_rec_date,                            round( v_rec_qty,5),
                             v_reg_type, v_loc_id, pr_new.transaction_uom,
                             TRUNC (pr_new.transaction_date),                             round(v_opening_qty,5),
                                                        round( v_closing_qty,5), v_pr_uom_code);
             ELSIF    (    v_excise_flag = 'Y'
                       AND v_item_class IN ('FGIN', 'FGEX')
                       AND v_t_type = 'IA'
                      )
                   OR (    v_modvat_flag = 'Y'
                       AND v_item_class IN ('FGIN', 'FGEX')
                       AND v_t_type = 'RA'
                      )
             THEN
                IF v_t_type = 'IA'
                THEN
                   IF v_item_class IN ('FGIN')
                   THEN
                      -- v_trans_qty := v_new_adjust_qty; --comminted by Subbu and Sri ON 30-NOV-00
                      v_trans_qty := v_new_trans_qty; --added by subbu and Sri on 30-NOV-00
                   ELSIF v_item_class IN ('FGEX')
                   THEN
                      v_t_qty := v_new_trans_qty; -- ssumaith -6609191
                   END IF;
                END IF;
                /*Bug 9550254 - Start*/
                /*
                OPEN srno_ii_cur (v_loc_id, v_f_year);
                FETCH srno_ii_cur INTO v_srno, v_bal_packed, v_bal_loose;
                CLOSE srno_ii_cur;
                */
                /*Code modified to fetch the Opening Balance when no transactions currently exist in JAI_CMN_RG_I_TRXS*/
                v_bal_loose := jai_om_rg_pkg.ja_in_rgi_balance(pr_new.organization_id,v_loc_id,pr_new.inventory_item_id,v_f_year,
                                                               v_srno,v_bal_packed);
                /*Bug 9550254 - End*/

                IF NVL (v_srno, 0) = 0
                THEN
                   v_srno := 1;
                   v_sr_no := 0;
                ELSE
                   v_sr_no := v_srno;
                   v_srno :=   v_srno
                             + 1;
                END IF;

                IF v_new_trans_qty < 0
                THEN
                   v_manufactured_qty := 0;
                   v_manufactured_pack_qty := NULL;
                   v_manu_loose_qty := NULL;

                   IF (  NVL (v_bal_packed, 0)
                       + NVL (v_bal_loose, 0)
                      ) >= ABS (v_new_trans_qty)
                   THEN
                      IF NVL (v_bal_loose, 0) >= ABS (v_new_trans_qty)
                      THEN
                         v_bal_loose :=
                              NVL (v_bal_loose, 0)
                            - ABS (NVL (v_new_trans_qty, 0));
                      ELSE
                         v_bal_loose :=
                              NVL (v_bal_loose, 0)
                            - ABS (NVL (v_new_trans_qty, 0));
                         v_bal_packed :=
                                       NVL (v_bal_packed, 0)
                                     + NVL (v_bal_loose, 0);
                         v_bal_loose := 0;
                      END IF;
                   ELSE
                      v_bal_packed :=
                             NVL (v_bal_packed, 0)
                           - ABS (NVL (v_new_trans_qty, 0));
                      v_bal_loose :=   NVL (v_bal_loose, 0)
                                     + NVL (v_bal_packed, 0);
                      v_bal_packed := 0;
                   END IF;
                ELSE
                   v_manufactured_qty := v_new_trans_qty;
                   v_manufactured_pack_qty := 0;
                   v_manu_loose_qty := v_new_trans_qty;
                   v_bal_loose :=   NVL (v_bal_loose, 0)
                                  + NVL (v_new_trans_qty, 0);
                END IF;

                -- jai_cmn_utils_pkg.print_log('rg1.log','before 6');
                INSERT INTO JAI_CMN_RG_I_TRXS
                            (register_id, fin_year, slno,
                             manufactured_qty, manufactured_packed_qty,
                             manufactured_loose_qty, balance_packed,
                             balance_loose, to_other_factory_n_pay_ed_qty,
                             for_export_n_pay_ed_qty, last_update_date,
                             last_updated_by, creation_date, created_by,
                             last_update_login, TRANSACTION_SOURCE_NUM,
                             inventory_item_id, organization_id,
                             transaction_type, range_no, division_no, location_id,
                             transaction_uom_code, transaction_date,
                             primary_uom_code,
                             REF_DOC_NO   -- cbabu 25/07/02 for Bug#2480524
                ) VALUES (JAI_CMN_RG_I_TRXS_S.NEXTVAL, v_f_year, v_srno,
                                                         round(v_manufactured_qty,5),                             round(v_manufactured_pack_qty,5),
                                                         round(v_manu_loose_qty,5),                            round( v_bal_packed,5),
                                                        round( v_bal_loose,5),                            round( v_trans_qty,5),
                             round(v_t_qty,5), pr_new.last_update_date,
                             pr_new.last_updated_by, SYSDATE, pr_new.created_by,
                             pr_new.last_update_login, pr_new.transaction_type_id,
                             pr_new.inventory_item_id, pr_new.organization_id,
                             v_t_type, v_range_no, v_division_no, v_loc_id,
                             pr_new.transaction_uom, TRUNC (pr_new.transaction_date),
                             v_pr_uom_code,
                             pr_new.transaction_id    -- cbabu 25/07/02 for Bug#2480524
                );
             END IF;
          END IF;
       END IF;
    /* Added an exception block by Ramananda for bug#4570303 */
     EXCEPTION
       WHEN OTHERS THEN
         Pv_return_code     :=  jai_constants.unexpected_error;
         Pv_return_message  := 'Encountered an error in JAI_INV_MMT_TRIGGER_PKG.ARI_T1 '  || substr(sqlerrm,1,1900);
  END ARI_T1 ;

END JAI_INV_MMT_TRIGGER_PKG ;

/

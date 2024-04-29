--------------------------------------------------------
--  DDL for Package Body JAI_MTL_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_MTL_TRXS_PKG" AS
/* $Header: jai_mtl_trxs_pkg.plb 120.15.12010000.7 2010/04/15 10:46:45 boboli ship $ */

/*----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:             FILENAME: jai_mtl_trxs_pkg.plb
S.No    Date                Author and Details
------------------------------------------------------------------------------------------------------------------------
1       24-Jan-2007       rchandan for #2942973 for File Version 115.6 (INTER ORG Impl.)
                           The parameter p_receipt_num in claim_balance_cgvat was defined as NUMBER and
                           so the query was not happening properly. Now it is defined as VARCHAR2.
                           Also removed a delete statement which was deleting from jai_rgm_trm_schedules_t if
                           there were any installments generated already.

2   26/01/2007       cbabu for bug#2942973   Version: 115.9  (INTER ORG Impl.)
                       Added the procedures
                         default_taxes - This defaults or redefaults the taxes. Incase of redefaultation, deletes the
                           entire data that is saved before base transaction is saved

                         sync_with_base_trx - This deletes IL data where in record PKs do not exist in base transaction tables
                           this internally uses delete_trx_autonomous or delete_trx procedures

                           These changes are done as part of ReArch. Inter Org Form

3    29-Jan-2007       rchandan for #2942973 for File Version 115.11 (INTER ORG Impl.)
                       Modified procedure DEFAULT_TAXES to recalculate taxes if the quantity alone
                       is changed. In other cases it would redefault taxes

4    30-Jan-2007       rchandan for bug#942973 for File Version 115.11 (INTER ORG Impl.)
                       Deletion from JAI_CMN_MATCH_TAXES was missing when quantity is changed after matching.
                       So added this statement now

5. 5-mar-2007        kunkumar - bug#5907436 -file branch 6107 on 115 main code line.
                   Added higher education cess needed for implementing  requirements imposed by budget of 2007.
             Introduces huge dependencies as there are data model changes associated with this bug.

6. 14-apr-2007      Vkaranam for bug #5907436 ,File version #115.16.6107.4 / 115.19
                    ENH:Handling Secondary And Higher Education Cess.
                    Fix:
                    Code changes are done in do_cenvat_acctg and cenvat_process procedures.

7.  01-08-2007           rchandan for bug#6030615 , Version 120.0
                         Issue : Inter org Forward porting
                                 This is a new file in R12 now.
8.  21-aug-2007    vkaranam for bug#6030615,File version 120.3
                   1.Changed std_cost_entry procedure.
                   2.added journal_entry_id column in the insert stmt of jai_mtl_trx_jrnls
9.  21-aug-2007    vkaranam for bug#6030615,File version 120.4
                   Changes are done as part of the performance issue.

10. 27-sep-2007    forward porting of bug 6377964

11. 09-Oct-2007    rchandan for bug#6487364,File version 120.8
                   Issue : QA observations for Inter org
                     Fix : For receiving organization no cess entries were made For RG23D.
                           Added calls to do this

12  10/10/2007     rchandan for bug#6487803, File version 120.10
                   Issue : R12RUP04.I/ORG.QA.ST1:NOT ABLE TO DO RECEIVING IN NON BONDED SUB INVENTORY
                     Fix : When Direct org transfer is done to a Non Bonded Subinventory, the excise processing
                           should not happen for receiving org , but the transaction should go through fine.
                           Added an elsif condiftion to do nothing for receiving org.
                           For accounting as well added condition so that the excise entries will be accounted
                           only for trading organization or Manufacturing org for a Bonded subinventory.

13.  12/10/2007    rchandan for bug#6497301,6487489. File version 120.12
                   Issue : R12RUP04.I/ORG.QA.ST1: NOT ABLE TO MAKE A CAPTIAL GOODS TRANSFER FOR INTRANSIT
                     Fix : It is identified that there are new columns added to table jai_rcv_journal_entries
                           and these are not null. As the impact of this is not taken care in cenvat_auto_claim
                           procedure this issue was coming.
                           Now added these columns in the insert into JAI_RCV_JOURNAL_ENTRIES
                   Issue : R12RUP04.I/ORG.QA.ST1: PPV ENTRY TO BE GENERATED FOR STD COST REC ORG
                     Fix : For standard costing , Purchase price variance entry needs to generated
                           for the non - recoverable tax amount.
                           Made changes in std_cost_entry procedure to this effect.
                           PPV account is debited and Inventory receiving account is credited.

14.  15/10/2007    rchandan for bug#6487489. File version 120.13
                   Issue : R12RUP04.I/ORG.QA.ST1: PPV ENTRY TO BE GENERATED FOR STD COST REC ORG
                     Fix : The PPV generated should be for the sum of all non recoverable taxes and excisable
                           recoverable taxes in case of non bonded sub inventory. In case of Bonded it should be
                           generated only for Non receoverable tax only. Changes for this effect are made.

15.  15/10/2007    rchandan for bug#6501436, File Version 120.14
                   Issue : R12RUP04.I/ORG.QA.ST1:PART 2 SHOULD NOT BE UPDATED FOR REC ORG IN CASE OF FGIN
                     Fix : For receiving org when the item class is FGIN or FGEX, no register updates should
                           haappen and also accounting for this amount should also not happen.
                           A check for the item class is put wherever applicable.

                           Fix for the previous bug#6487489 is also made. In this ln_oth_modvat_amt is removed
                           from the calculation of ln_cost_amount.
                           Moreover for FGIN and FGEX clas also PPV entry needs to be modified to include the
                           recoverable tax which was not hitting the register and also not included in the accounting.

16.  16/10/2007    rchandan for bug#6504150, File Version 120.15
                   Issue : R12RUP04.I/ORG.QA.ST1:USER_JE_CATEGORY_NAM TO BE CHANGED FOR PPV ENTRY
                     Fix : In the gl_interface table the user_je_category_name should be populated as
                           'MTL' for PPV entry which is being generated for the receiving org in the
                            Direct Org Transfer. Made a change to this effect.

17.  12-May-2008   Changes by nprashar for bug # 6710747. Forward ported from 11i bug#6086452.
		   Issue:
		    When trying to save the IL interorg transfer a error message pops up and also
                    not allowing close the form. Which makes  to close the application and login again.

		    The above mentioned issue is happening because of the deadlock on jai_mtl_trxs table.
                     1.on the key commit trigger of mtl_trx_line in interorg form(JAINVMTX.fmb),there is an update stmt on jai_mtl_trxs table.
		     If any error occurs in this trigger and the user tries to comeout of the form there is a call to sync_with_base_trx
		     which will delete the error record in jai_mtl_trxs table.
		     since it is trying to delete the same record which has been locked  by the update stmt,deadlock error occurs waiting for the resource .

		     Fix:
                     changes are done in cenvat_process procedure

18. 01-JUL-2009  Bgowrava for Bug#8414075 , File Version 120.15.12000000.3
                     Addded round condition to the ln_amount value according to the rounding factor mentioned in tax setup and the same is passed
 	           to jai_cmn_rgm_terms_pkg.generate_term_schedules.

19.  18-aug-2009 vkaranam for bug#8800063,file version 120.15.12000000.6
                 Issue:
		 IL INTER ORGANIZATION TRANSFER IS GIVING DEADLOCK ERROR

		 issue is happening with the delete_trx_autonomous (Pragma autonomous
		 transaction) procedure.

		 The below stmt has been executed from (JAINVMTX.KEY-COMMIT)-->
		 jai_mtl_trxs_pkg. sync_trx_with_base (delete_trx) procedure.

		 Delete JAI_MTL_TRXS WHERE TRANSACTION_HEADER_ID = :B2 AND TRANSACTION_TEMP_ID
		  = NVL(:B1 , TRANSACTION_TEMP_ID ) AND TRANSACTION_COMMIT_DATE IS NULL.

		 Lock is acquired by the current session and it will be removed once the
		 transaction gets commited/rollbacked.

		 When any error comes during the forms commit processing the changes will not
		 get applied to the database..

		 Here  some base error "lot/serial number does not match" is coming and the
		 changes are not getting applied due to which lock exists on jai_mtl_trxs..

		 Now when we try to close the form then the below stmt will be executed.
		 ( JAINVMTX.KEY-EXIT --->sync_with_base_trx (delete_trx_autonomous)).

		 Delete JAI_MTL_TRXS WHERE TRANSACTION_HEADER_ID = :B2 AND TRANSACTION_TEMP_ID
		  = NVL(:B1 , TRANSACTION_TEMP_ID ) AND TRANSACTION_COMMIT_DATE IS NULL.

		 This delete is waiting for the lock acquired for the previous delete stmt.
		 hence the deadlock issue is coming

		 Fix:

		  Modified sync_with_base_trx such that delete_trx_autonomous will not be used
                  anymore.

13-oct-2009   vkaranam for bug#8882785
              Issue:
	      TST1212.XB1.QA.INCLUSIVE TAX IS NOT RIGHT FOR INTER-ORG TRANSFER TRANSACTION
	      if the interorg transfer has the inclusive taxes and the assessable price list is not \
	      attached to the internal ct,then the taxes are calculated wrongly.
	      issue is with the assessable_value being rounded.
	       In package jai_mtl_trxs_pkg.default_taxes, the variable is defined as
               following:

		   ln_assessable_value       number(15);
		   ln_vat_assessable_value   number(15);

		 So when calling function jai_om_utils_pkg.get_oe_assesaable_value,
		 these two variables will be truncated.

		 Fix:
		 Changed the ln_assessable_value, ln_vat_assessable_value variables declartion to
		 NUMBER;

		 added round with precision 2 in the below condition.
		 ln_assessable_value := nvl(ln_assessable_value,0)* p_line_quantity;

2010/04/14 Bo Li   For bug9305067
           Change the parameters for the procedure insert_vat_repository_entry .


------------------------------------------------------------------------------------------------------------------------
*/

   TYPE gl_params IS RECORD (
                   amount            NUMBER,
                   credit_account    gl_interface.code_combination_id%TYPE,
                   debit_account     gl_interface.code_combination_id%TYPE,
                   organization_id   NUMBER,
                   organization_code gl_interface.reference1%TYPE,
                   remarks           VARCHAR2(64));

   TYPE gl_entries IS TABLE OF gl_params INDEX BY  PLS_INTEGER;


PROCEDURE get_cost_amt
  (
      p_source_line_id              IN              NUMBER,
      p_organization_id             IN              NUMBER,
      p_location_id                 IN              NUMBER,
      p_item_id                     IN              NUMBER,
      p_excise_amount               OUT NOCOPY      NUMBER,
      p_non_modvat_amount           OUT NOCOPY      NUMBER,
      p_other_modvat_amount         OUT NOCOPY      NUMBER,
      p_process_message             OUT NOCOPY      VARCHAR2,
      p_process_status              OUT NOCOPY      VARCHAR2
  ) IS

    ln_modvat_amount            NUMBER  := 0;
    ln_non_modvat_amount        NUMBER  := 0;
    ln_other_modvat_amount      NUMBER  := 0;
    ln_conv_factor              NUMBER  := 1;
    lv_tax_modvat_flag          JAI_RCV_LINE_TAXES.modvat_flag%type;

    ln_precision                number:= 2 ;
    ln_recoverable_amt          number;
    ln_converted_tax_amt        number;

    lv_item_trading_flag  VARCHAR2(20);
    lv_excise_in_trading  VARCHAR2(20);
    lv_item_excisable     VARCHAR2(20);
    lv_organization_type  VARCHAR2(20);
    lv_manufacturing      VARCHAR2(20);
    lv_trading            VARCHAR2(20);



    cursor  c_get_org_info  IS
    SELECT  excise_in_RG23D excise_in_trading , NVL(manufacturing,'N') , NVL(trading ,'N')
    FROM    JAI_CMN_INVENTORY_ORGS
    WHERE   organization_id = p_organization_id
    AND     location_id     = p_location_id;

    cursor c_get_item_info  IS
    select item_Trading_flag , excise_flag
    from   JAI_INV_ITM_SETUPS
    where  inventory_item_id = p_item_id
    and    organization_id = p_organization_id;

  BEGIN


    OPEN  c_get_org_info;
    FETCH c_get_org_info INTO lv_excise_in_trading ,lv_manufacturing , lv_trading ;
    CLOSE c_get_org_info;

    OPEN  c_get_item_info;
    FETCH c_get_item_info INTO lv_item_trading_flag,lv_item_excisable ;
    CLOSE c_get_item_info;

    IF lv_manufacturing = 'Y' THEN
       lv_organization_type := 'M';
    ELSIF lv_trading = 'Y' THEN
       lv_organization_type := 'T';
    END IF;

    FOR tax_rec IN
      (
        SELECT
          rtl.tax_type,
          nvl(rtl.tax_amt, 0)        tax_amount,
          nvl(rtl.modvat_flag, 'N')     modvat_flag,
          nvl(rtl.currency_code, 'INR')      currency,
          nvl(jtc.mod_cr_percentage, 0) mod_cr_percentage
        FROM
          jai_cmn_document_taxes rtl,
          jai_cmn_taxes_all        jtc
        WHERE
          source_doc_line_id = p_source_line_id
          AND jtc.tax_id = rtl.tax_id
          AND  source_doc_type  = 'INTERORG_XFER'

        )
    LOOP

       ln_converted_tax_amt := tax_rec.tax_amount;
       ln_converted_tax_amt := nvl(ln_converted_tax_amt,0);

      if  tax_rec.modvat_flag = 'Y'
          and upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                           'ADDITIONAL_CVD', 'TDS', 'MODVAT RECOVERY',
                  jai_constants.tax_type_exc_edu_cess, jai_constants.tax_type_cvd_edu_cess, jai_constants.tax_type_sh_exc_edu_cess, jai_constants.tax_type_sh_cvd_edu_cess) --Added higher education cess by kundan kumar for bug#5907436

      then


        lv_tax_modvat_flag := 'Y';


      elsif tax_rec.modvat_flag = 'Y'
            and upper(tax_rec.tax_type) NOT IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                         'ADDITIONAL_CVD',
                  jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess,jai_constants.tax_type_sh_cvd_edu_cess, jai_constants.tax_type_cvd_edu_cess) --Added higher education cess by kundan kumar for bug#5907436

      then


        lv_tax_modvat_flag := 'Y';

      elsif tax_rec.modvat_flag                                = 'N'
            and  lv_item_trading_flag    = 'Y' /* Excise IN RG23D scenario */
            and  lv_excise_in_trading    = 'Y'
            and  lv_item_excisable       = 'Y'
            and  lv_organization_type    = 'T'
            and  upper(tax_rec.tax_type) IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                             'ADDITIONAL_CVD',
                  jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess, --Added higher education cess by kundan kumar for bug#5907436


jai_constants.tax_type_sh_cvd_edu_cess, jai_constants.tax_type_cvd_edu_cess)  --Added higher education cess by kundan kumar for bug#5907436

      then

            lv_tax_modvat_flag := 'Y';

      else
            lv_tax_modvat_flag := 'N';

      end if; --tax_rec.modvat_flag = 'Y'


      if upper(tax_rec.tax_type) NOT IN ('TDS', 'MODVAT RECOVERY') THEN


        if lv_tax_modvat_flag = 'Y'
        and upper(tax_rec.tax_type) IN ( 'EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                         'ADDITIONAL_CVD',
                  jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess, --Added higher education cess by kundan kumar for bug#5907436

jai_constants.tax_type_sh_cvd_edu_cess, --Added higher education cess by kundan kumar for bug#5907436

 jai_constants.tax_type_cvd_edu_cess)
        then


          ln_recoverable_amt :=
              round( tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_conv_factor, ln_precision);
          ln_modvat_amount     := ln_modvat_amount     + ln_recoverable_amt;
          ln_non_modvat_amount := ln_non_modvat_amount + ( ln_converted_tax_amt - ln_recoverable_amt);


        elsif lv_tax_modvat_flag = 'Y'
          and upper(tax_rec.tax_type) NOT IN ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE', 'CVD',
                                         'ADDITIONAL_CVD',
                  jai_constants.tax_type_exc_edu_cess,jai_constants.tax_type_sh_exc_edu_cess, --Added higher education cess by kundan kumar for bug#5907436

jai_constants.tax_type_sh_cvd_edu_cess, --Added higher education cess by kundan kumar for bug#5907436

 jai_constants.tax_type_cvd_edu_cess)
        then

          ln_recoverable_amt :=
              round( tax_rec.tax_amount * (tax_rec.mod_cr_percentage/100) * ln_conv_factor, ln_precision);
          ln_other_modvat_amount := ln_other_modvat_amount + ln_recoverable_amt;
          ln_non_modvat_amount := ln_non_modvat_amount + ( ln_converted_tax_amt - ln_recoverable_amt);

        ELSIF lv_tax_modvat_flag ='N' and upper(tax_rec.tax_type) NOT IN ('TDS', 'MODVAT RECOVERY') THEN

          ln_non_modvat_amount   := ln_non_modvat_amount + tax_rec.tax_amount * ln_conv_factor;

        end if;

      end if;

    END LOOP;


    p_excise_amount            := ln_modvat_amount;
    p_non_modvat_amount        := ln_non_modvat_amount;
    p_other_modvat_amount      := ln_other_modvat_amount;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status    := 'E';
      p_process_message   := 'get_tax_amount_breakup:' || sqlerrm;
  END get_cost_amt;



PROCEDURE cenvat_process(
  p_transaction_temp_id          IN  NUMBER,
  p_transaction_type in varchar2,
  p_excise_inv_no in varchar2, /*Added by nprashar for bug # 6710747*/
  p_process_status               OUT NOCOPY VARCHAR2,
  p_process_message              OUT NOCOPY VARCHAR2)
 IS
  CURSOR main_cur IS
    SELECT  trx.transaction_date,
      trx.inventory_item_id,
      trx.transaction_uom,
      trx.transaction_type_id,
      trx.from_organization,
      trx.to_organization,
      trx.to_subinventory,
      trx.transaction_temp_id,
      --trx.excise_invoice_no,/*Added by nprashar for bug 6710747*/
      trx.assessable_value,
      subinv.bonded,
      itm.excise_flag,
      itm.item_class,
      itm.item_trading_flag,
      subinv.trading,
      trx.location_id,
      trx.quantity,
      trx.creation_date,
      trx.created_by,
      trx.last_update_date,
      trx.last_update_login
    FROM jai_mtl_trxs trx,
      JAI_INV_SUBINV_DTLS subinv,
      JAI_INV_ITM_SETUPS itm
    WHERE subinv.organization_id = trx.to_organization
     AND itm.organization_id = trx.to_organization
     AND itm.inventory_item_id = trx.inventory_item_id
     AND subinv.sub_inventory_name = trx.to_subinventory
     AND trx.transaction_temp_id = p_transaction_temp_id
     AND trx.quantity > 0 ;
    /*Commented by nprashar for bug #  6710747 AND trx.excise_invoice_no IS NOT NULL;*/

  CURSOR organization_type_cur(p_org_id number,p_loc_id number) IS
    SELECT trading, manufacturing, excise_duty_range, excise_duty_division
    FROM JAI_CMN_INVENTORY_ORGS
    WHERE organization_id = p_org_id
     AND location_id = p_loc_id;


  CURSOR excise_cur(trx_temp_id number) IS
   SELECT SUM(decode(tax_type,   'Excise',   round(tax_amt),   0)) exc,
          SUM(decode(tax_type,   'Addl. Excise',   round(tax_amt),   0)) additional_ed,
          SUM(decode(tax_type,   'Other Excise',   round(tax_amt),   0)) other_ed,
          SUM(decode(tax_type,   jai_constants.tax_type_exc_edu_cess, round(tax_amt),   0)) other_cess,
          sum(decode(tax_type,   jai_constants.tax_type_sh_exc_edu_cess, round(tax_amt), 0)) other_sh_cess --Added higher education cess constants by vkaranam for bug#5907436
    FROM jai_cmn_document_taxes tax,
         jai_mtl_trxs trx
    WHERE tax.source_doc_line_id = trx.transaction_temp_id
     AND trx.transaction_header_id = tax.source_doc_id
     AND trx.transaction_temp_id = trx_temp_id;

       CURSOR c_excise_tax_rate(cp_temp_id number)
         IS
          SELECT NVL(sum(tax_rate),0) , count(1)
          FROM   jai_cmn_document_taxes
          WHERE  source_doc_line_id = cp_temp_id
          AND  TAX_TYPE in ('Addl. Excise','Excise','Other Excise');

    cursor c_rcpts_match (cp_temp_id IN NUMBER) IS
    select sum(a.quantity_applied) quantity_applied , sum(b.excise_duty_rate) excise_duty_rate
    from   JAI_CMN_MATCH_RECEIPTS a ,JAI_CMN_RG_23D_TRXS b
    where  a.receipt_id = b.register_id
    and    a.ref_line_id = cp_temp_id
    and    a.order_invoice = 'X';


    r_rcpts_match c_rcpts_match%rowtype;

  l_trading JAI_CMN_INVENTORY_ORGS.trading%TYPE;
  l_manufacturing JAI_CMN_INVENTORY_ORGS.manufacturing%TYPE;
  l_range JAI_CMN_RG_I_TRXS.range_no%TYPE;
  l_division JAI_CMN_RG_I_TRXS.division_no%TYPE;
  l_register_id JAI_CMN_RG_I_TRXS.register_id%TYPE;
  l_register_id_ii JAI_CMN_RG_I_TRXS.register_id_part_ii%TYPE;
  l_slno JAI_CMN_RG_I_TRXS.slno%TYPE;
  l_fin_year JAI_CMN_FIN_YEARS.fin_year%TYPE;
  l_register_type VARCHAR2(3);
  l_excise_duty  NUMBER;
  l_additional_ed NUMBER;
  l_other_ed  NUMBER;
  ln_cess_amount number;
  ln_other_sh_cess number; --Added higher education cess by kundan kumar for bug#5907436
  main_rec  main_cur%ROWTYPE;
  l_process_status VARCHAR2(5) DEFAULT NULL;
  l_process_message VARCHAR2(256) DEFAULT NULL;
  v_register_id number;
  lv_source_name varchar2(10);
  processed_flag VARCHAR2(32) := '0';
  stmt_name VARCHAR2(64);
  ln_total_tax_rate NUMBER;
  ln_number_of_Taxes NUMBER;
   v_tax_rate  NUMBER;
   l_duty_amt number;

BEGIN

  stmt_name := 'Opening main_cur';
  OPEN main_cur;
  FETCH main_cur INTO main_rec;
  IF main_cur%NOTFOUND THEN
      stmt_name := 'Fetching main_cur Cursor';
      RAISE NO_DATA_FOUND;
  END IF;

  stmt_name := 'Opening Organization_type_cur';
  OPEN organization_type_cur( main_rec.to_organization ,main_rec.location_id );
  FETCH organization_type_cur INTO l_trading, l_manufacturing, l_range, l_division;
  IF organization_type_cur%NOTFOUND THEN
      stmt_name := 'Fetching organization_type Cursor '||':'||main_rec.to_organization||':'||main_rec.location_id;
      CLOSE organization_type_cur;
      RAISE NO_DATA_FOUND;
  END IF;
  CLOSE organization_type_cur;

  stmt_name := 'Selecting fin_year from JAI_CMN_FIN_YEARS';
  SELECT fin_year
    INTO l_fin_year
  FROM JAI_CMN_FIN_YEARS
  WHERE organization_id = main_rec.to_organization
   AND fin_active_flag = 'Y';

  stmt_name := 'Opening excise_cur';
  OPEN excise_cur(main_rec.transaction_temp_id);
  FETCH excise_cur INTO l_excise_duty, l_additional_ed, l_other_ed,ln_cess_amount,ln_other_sh_cess;
  CLOSE excise_cur;

  l_duty_amt:=nvl(l_excise_duty,0)+nvl(l_additional_ed,0)+nvl(l_other_ed,0);

  OPEN  c_excise_tax_rate(main_rec.transaction_temp_id);
  FETCH c_excise_tax_rate INTO ln_total_tax_rate , ln_number_of_Taxes ;
  CLOSE c_excise_tax_rate;

  IF NVL(ln_number_of_Taxes,0) = 0 THEN
      ln_number_of_Taxes := 1;
    END IF;

  v_tax_rate := ln_total_tax_rate / ln_number_of_Taxes;

  IF main_rec.item_class IN ('FGIN','FGEX','CCEX','CCIN','RMIN', 'RMEX') THEN
     l_register_type := 'A';
  ELSE
     l_register_type := 'C';
  END IF;

  IF l_manufacturing = 'Y' THEN
     IF main_rec.excise_flag = 'Y' AND main_rec.bonded = 'Y' AND
        main_rec.item_class IN ('FGIN','FGEX','CCEX','CCIN') THEN
       stmt_name := 'Calling JAI_CMN_RG_I_TRXS_pkg.create_rg1_entry';
       JAI_CMN_RG_I_TRXS_pkg.create_rg1_entry(
            P_REGISTER_ID => l_register_id,
            P_REGISTER_ID_PART_II => null,
            P_FIN_YEAR => l_fin_year,
            P_SLNO => l_slno,
            P_TRANSACTION_ID => 3,
            P_ORGANIZATION_ID => main_rec.to_organization,
            P_LOCATION_ID => main_rec.location_id,
            P_TRANSACTION_DATE => main_rec.transaction_date,
            P_INVENTORY_ITEM_ID => main_rec.inventory_item_id,
            P_TRANSACTION_TYPE => 'R',
            P_REF_DOC_ID => main_rec.transaction_temp_id,
            P_QUANTITY => main_rec.quantity,
            P_TRANSACTION_UOM_CODE => main_rec.transaction_uom,
            P_ISSUE_TYPE => null,
            P_EXCISE_DUTY_AMOUNT => null,
            P_EXCISE_INVOICE_NUMBER => p_excise_inv_no /*Replacing main_rec.excise_invoice_no for bug # 6710747*/,
            P_EXCISE_INVOICE_DATE => null,
            P_PAYMENT_REGISTER => null,
            P_CHARGE_ACCOUNT_ID => null,
            P_RANGE_NO => l_range,
            P_DIVISION_NO => l_division,
            P_REMARKS => 'Inter Org transfer from '||main_rec.from_organization||' To '||main_rec.to_organization,
            P_BASIC_ED => l_excise_duty,
            P_ADDITIONAL_ED => l_additional_ed,
            P_OTHER_ED => l_other_ed,
            P_ASSESSABLE_VALUE => main_rec.assessable_value,
            P_EXCISE_DUTY_RATE => null,
            P_VENDOR_ID => main_rec.to_organization,
            P_VENDOR_SITE_ID => main_rec.location_id,
            P_CUSTOMER_ID => null,
            P_CUSTOMER_SITE_ID => null,
            P_CREATION_DATE => main_rec.creation_date,
            P_CREATED_BY => main_rec.created_by,
            P_LAST_UPDATE_DATE => sysdate,
            P_LAST_UPDATED_BY => fnd_global.user_id,
            P_LAST_UPDATE_LOGIN => main_rec.last_update_login,
            P_CALLED_FROM => 'XFER',
	    P_CESS_AMOUNT  => ln_cess_amount ,
	    P_SH_CESS_AMOUNT =>ln_other_sh_cess
       );
       processed_flag :='RG1';
     ELSIF  main_rec.excise_flag = 'Y' AND main_rec.bonded = 'Y' AND
            main_rec.item_class IN ('RMIN', 'RMEX', 'CGIN', 'CGEX') THEN
       stmt_name := 'Calling jai_cmn_rg_23ac_i_trxs_pkg.insert_row';
       jai_cmn_rg_23ac_i_trxs_pkg.insert_row(
              P_REGISTER_ID => l_register_id,
              P_INVENTORY_ITEM_ID => main_rec.inventory_item_id,
              P_ORGANIZATION_ID => main_rec.to_organization,
              P_QUANTITY_RECEIVED => main_rec.quantity,
              P_RECEIPT_ID => main_rec.transaction_temp_id,
              P_TRANSACTION_TYPE => 'R',
              P_RECEIPT_DATE => main_rec.transaction_date,
              P_PO_HEADER_ID => null,
              P_PO_HEADER_DATE => null,
              P_PO_LINE_ID => null,
              P_PO_LINE_LOCATION_ID => null,
              P_VENDOR_ID => main_rec.from_organization,
              P_VENDOR_SITE_ID => NULL,
              P_CUSTOMER_ID => null,
              P_CUSTOMER_SITE_ID => null,
              P_GOODS_ISSUE_ID => null,
              P_GOODS_ISSUE_DATE => null,
              P_GOODS_ISSUE_QUANTITY => null,
              P_SALES_INVOICE_ID => null,
              P_SALES_INVOICE_DATE => null,
              P_SALES_INVOICE_QUANTITY => null,
              P_EXCISE_INVOICE_ID => p_excise_inv_no /*Replacing main_rec.excise_invoice_no for bug # 6710747*/,
              P_EXCISE_INVOICE_DATE => sysdate,
              P_OTH_RECEIPT_QUANTITY => null,
              P_OTH_RECEIPT_ID => null,
              P_OTH_RECEIPT_DATE => null,
              P_REGISTER_TYPE => l_register_type,
              P_IDENTIFICATION_NO => null,
              P_IDENTIFICATION_MARK => null,
              P_BRAND_NAME => null,
              P_DATE_OF_VERIFICATION => null,
              P_DATE_OF_INSTALLATION => null,
              P_DATE_OF_COMMISSION => null,
              P_REGISER_ID_PART_II => null,
              P_PLACE_OF_INSTALL => null,
              P_REMARKS => 'Inter Org transfer from '||main_rec.from_organization||' To '||main_rec.to_organization,
              P_LOCATION_ID => main_rec.location_id,
              P_TRANSACTION_UOM_CODE => main_rec.transaction_uom,
              P_TRANSACTION_DATE => main_rec.transaction_date,
              P_BASIC_ED => l_excise_duty,
              P_ADDITIONAL_ED => l_additional_ed,
              P_ADDITIONAL_CVD => null,
              P_OTHER_ED => l_other_ed,
              P_CHARGE_ACCOUNT_ID => null,
              P_TRANSACTION_SOURCE => null,
              P_CALLED_FROM => 'XFER',
              P_SIMULATE_FLAG => null,
              P_PROCESS_STATUS => l_process_status,
              P_PROCESS_MESSAGE => l_process_message
            );
            if l_process_status='E' then
              app_exception.raise_exception;
            end if;
       processed_flag :='RG23';

     ELSIF main_rec.bonded = 'N' THEN /*6487803*/
		   l_process_status  := 'N'; /*Do Nothing for Non Bonded subinventory*/
		   l_process_message := NULL;
		   processed_flag    := 'N';
     END IF;
  ELSIF l_trading = 'Y' AND main_rec.trading = 'Y' AND main_rec.item_trading_flag = 'Y' THEN
      stmt_name := 'Calling jai_cmn_rg_23d_trxs_pkg.insert_row';

      if main_Rec.quantity <> 0 then
        v_tax_rate := round((l_duty_amt / main_Rec.quantity),2);
      end if;
      OPEN  c_rcpts_match (main_rec.transaction_temp_id);
      fetch c_rcpts_match INTO r_rcpts_match;
      close  c_rcpts_match;
      if r_rcpts_match.quantity_applied <> 0 THEN
         ln_total_tax_rate := round (( ( r_rcpts_match.excise_duty_rate *r_rcpts_match.quantity_applied  )  / r_rcpts_match.quantity_applied),2);
      end if;

      jai_cmn_rg_23d_trxs_pkg.insert_row(
          P_REGISTER_ID => l_register_id,
          P_ORGANIZATION_ID => main_rec.to_organization,
          P_LOCATION_ID => main_rec.location_id,
          P_TRANSACTION_TYPE => 'R',
          P_RECEIPT_ID => main_rec.transaction_temp_id,
          P_QUANTITY_RECEIVED => main_rec.quantity,
          P_INVENTORY_ITEM_ID => main_rec.inventory_item_id,
          P_SUBINVENTORY => main_rec.to_subinventory,
          P_REFERENCE_LINE_ID => null,
          P_TRANSACTION_UOM_CODE => main_rec.transaction_uom,
          P_CUSTOMER_ID => null,
          P_BILL_TO_SITE_ID => null,
          P_SHIP_TO_SITE_ID => null,
          P_QUANTITY_ISSUED => null,
          P_REGISTER_CODE => null,
          P_RELEASED_DATE => null,
          P_COMM_INVOICE_NO => p_excise_inv_no /*Replacing main_rec.excise_invoice_no for bug # 6710747*/,
          P_COMM_INVOICE_DATE => sysdate,
          P_RECEIPT_BOE_NUM => null,
          P_OTH_RECEIPT_ID => null,
          P_OTH_RECEIPT_DATE => null,
          P_OTH_RECEIPT_QUANTITY => null,
          P_REMARKS => 'Inter Org transfer from '||main_rec.from_organization||' To '||main_rec.to_organization,
          P_QTY_TO_ADJUST => main_rec.quantity,
          P_RATE_PER_UNIT =>  v_tax_rate,
          P_EXCISE_DUTY_RATE => ln_total_tax_rate,
          P_CHARGE_ACCOUNT_ID => null,
          P_DUTY_AMOUNT =>  round(l_duty_amt,0),
          P_RECEIPT_DATE => sysdate,
          P_GOODS_ISSUE_ID => null,
          P_GOODS_ISSUE_DATE => null,
          P_GOODS_ISSUE_QUANTITY => null,
          P_TRANSACTION_DATE => main_rec.transaction_date,
          P_BASIC_ED => round(l_excise_duty,0),
          P_ADDITIONAL_ED => round(l_additional_ed,0),
          P_ADDITIONAL_CVD => null,
          P_OTHER_ED => round(l_other_ed,0),
          P_CVD => null,
          P_VENDOR_ID => main_rec.from_organization,
          P_VENDOR_SITE_ID => NULL,
          P_RECEIPT_NUM => null,
          P_ATTRIBUTE1 => null,
          P_ATTRIBUTE2 => null,
          P_ATTRIBUTE3 => null,
          P_ATTRIBUTE4 => null,
          P_ATTRIBUTE5 => null,
          P_CONSIGNEE => null,
          P_MANUFACTURER_NAME => null,
          P_MANUFACTURER_ADDRESS => null,
          P_MANUFACTURER_RATE_AMT_PER_UN => null,
          P_QTY_RECEIVED_FROM_MANUFACTUR => null,
          P_TOT_AMT_PAID_TO_MANUFACTURER => null,
          P_OTHER_TAX_CREDIT => NVL(ln_cess_amount,0)+NVL(ln_other_sh_cess,0) ,--ADDED ln_other_sh_cessby vkaranam for bug #5907436
          P_OTHER_TAX_DEBIT => null,
          P_TRANSACTION_SOURCE => p_transaction_type,
          P_CALLED_FROM => 'XFER',
          P_SIMULATE_FLAG => null,
          P_PROCESS_STATUS => l_process_status,
          P_PROCESS_MESSAGE => l_process_message
        );
       processed_flag :='RG23D';

       -- rchandan for bug#6487364 start

       IF NVL(ln_cess_amount,0) <> 0 then

         stmt_name := 'Calling jai_cmn_rg_others_pkg.insert_row for Cess of RG23D';

         jai_cmn_rg_others_pkg.insert_row(p_source_type    => 3,
                                            p_source_name  => 'RG23D',
                                            p_source_id    => l_register_id,
                                            p_tax_type     => jai_constants.tax_type_exc_edu_cess,
                                            debit_amt      => NULL,
                                            credit_amt     => ln_cess_amount,
                                            p_process_flag => p_process_status,
                                            p_process_msg  => p_process_message
                                         );
         IF p_process_status <> 'SS' THEN
           app_exception.raise_exception;
         END IF;

       END IF;
       IF NVL(ln_other_sh_cess,0) <> 0 then

          stmt_name := 'Calling jai_cmn_rg_others_pkg.insert_row for SH Cess of RG23D';

					jai_cmn_rg_others_pkg.insert_row(p_source_type    => 3,
																						 p_source_name  => 'RG23D',
																						 p_source_id    => l_register_id,
																						 p_tax_type     => jai_constants.tax_type_sh_exc_edu_cess,
																						 debit_amt      => NULL,
																						 credit_amt     => ln_other_sh_cess,
																						 p_process_flag => p_process_status,
																						 p_process_msg  => p_process_message
																					);
					IF p_process_status <> 'SS' THEN
						app_exception.raise_exception;
					END IF;

       END IF;

       -- rchandan for bug#6487364 end

  END IF;
  IF processed_flag = '0' THEN
      l_process_status := 'E';
      l_process_message := 'No data Processed';
  ELSIF processed_flag IN ('RG1','RG23') and main_rec.item_class NOT IN ('FGIN', 'FGEX') THEN /*6501436*/
      stmt_name := 'Calling jai_cmn_rg_23ac_ii_pkg.insert_row';
      jai_cmn_rg_23ac_ii_pkg.insert_row(
          P_REGISTER_ID => l_register_id_ii,
          P_INVENTORY_ITEM_ID => main_rec.inventory_item_id,
          P_ORGANIZATION_ID => main_rec.to_organization,
          P_RECEIPT_ID => main_rec.transaction_temp_id,
          P_RECEIPT_DATE => null,
          P_CR_BASIC_ED => l_excise_duty,
          P_CR_ADDITIONAL_ED => l_additional_ed,
          P_CR_ADDITIONAL_CVD => null,
          P_CR_OTHER_ED => l_other_ed,
          P_DR_BASIC_ED => null,
          P_DR_ADDITIONAL_ED => null,
          P_DR_ADDITIONAL_CVD => null,
          P_DR_OTHER_ED => null,
          P_EXCISE_INVOICE_NO => p_excise_inv_no /*Replacing main_rec.excise_invoice_no for bug # 6710747*/,
          P_EXCISE_INVOICE_DATE => sysdate,
          P_REGISTER_TYPE => l_register_type,
          P_REMARKS => 'Inter Org transfer from '||main_rec.from_organization||' To '||main_rec.to_organization,
          P_VENDOR_ID => main_rec.from_organization,
          P_VENDOR_SITE_ID => NULL,
          P_CUSTOMER_ID => null,
          P_CUSTOMER_SITE_ID => null,
          P_LOCATION_ID => main_rec.location_id,
          P_TRANSACTION_DATE => main_rec.transaction_date,
          P_CHARGE_ACCOUNT_ID => null,
          P_REGISTER_ID_PART_I => l_register_id ,
          P_REFERENCE_NUM => null,
          P_ROUNDING_ID => null,
          P_OTHER_TAX_CREDIT =>nvl(ln_cess_amount,0)+NVL(ln_other_sh_cess,0) ,--ADDED ln_other_sh_cessby vkaranam for bug #5907436,
          P_OTHER_TAX_DEBIT => null,
          p_transaction_type => 'R',
          P_TRANSACTION_SOURCE => null,
          P_CALLED_FROM => null,
          P_SIMULATE_FLAG => null,
          P_PROCESS_STATUS => l_process_status,
          P_PROCESS_MESSAGE => l_process_message
        );
      IF processed_flag = 'RG1' THEN
         UPDATE JAI_CMN_RG_I_TRXS
         SET register_id_part_ii = l_register_id_ii,cess_amt = ln_Cess_amount
         WHERE register_id = l_register_id;
      ELSE
         UPDATE JAI_CMN_RG_23AC_I_TRXS SET register_id_part_ii = l_register_id_ii WHERE register_id = l_register_id;
      END IF;
      IF SQL%NOTFOUND THEN
         stmt_name := 'UPDATE register_id = '||l_register_id||': processed_flag = '||processed_flag;
         RAISE no_data_found;
      END IF;
      IF nvl(ln_cess_amount,0)<>0 THEN
      /*
      BEGIN
        SELECT JAI_CMN_RG_23AC_I_TRXSI_S.CURRVAL  INTO v_register_id FROM dual;
      EXCEPTION when others THEN
        SELECT JAI_CMN_RG_23AC_I_TRXSI_S.CURRVAL  INTO v_register_id FROM dual;
      END;
      *//*commented the above by vkaranam for bug #5907436*/
      BEGIN
        stmt_name := 'Calling jai_cmn_rg_others_pkg.insert_row';
        if l_register_type='A' THEN
           lv_source_name:='RG23A_P2';
        elsif l_register_type='C' THEN
           lv_source_name:='RG23C_P2';
        end if;
        jai_cmn_rg_others_pkg.insert_row(
                                     P_SOURCE_TYPE   => 1         ,
                                     P_SOURCE_NAME   => lv_source_name          ,
                                     P_SOURCE_ID     =>  l_register_id_ii          ,
                                     P_TAX_TYPE      => 'EXCISE_EDUCATION_CESS'  ,
                                     DEBIT_AMT       =>null ,
                                     CREDIT_AMT      =>ln_cess_amount                   ,
                                     P_PROCESS_FLAG  =>l_process_status       ,
                                     P_PROCESS_MSG   =>l_process_message
                                    );
      END;

      END IF;
      /*added the following for shcess by vkaranam for bug #5907436*/
      --start 5907436
      IF nvl(ln_other_sh_cess,0)<>0 THEN
      BEGIN
        stmt_name := 'Calling jai_cmn_rg_others_pkg.insert_row';
        if l_register_type='A' THEN
           lv_source_name:='RG23A_P2';
        elsif l_register_type='C' THEN
           lv_source_name:='RG23C_P2';
        end if;
        jai_cmn_rg_others_pkg.insert_row(
                                     P_SOURCE_TYPE   => 1         ,
                                     P_SOURCE_NAME   => lv_source_name          ,
                                     P_SOURCE_ID     =>  l_register_id_ii          ,
                                     P_TAX_TYPE      => jai_constants.tax_type_sh_exc_edu_cess ,
                                     DEBIT_AMT       =>null ,
                                     CREDIT_AMT      =>ln_other_sh_cess                   ,
                                     P_PROCESS_FLAG  =>l_process_status       ,
                                     P_PROCESS_MSG   =>l_process_message
                                    );
      END;
      --end bug #5907436

      END IF;


  END IF;
  CLOSE main_cur;
  p_process_status := l_process_status;
  p_process_message := l_process_message;
EXCEPTION
  WHEN OTHERS THEN
    p_process_status := 'E';
    p_process_message := 'Encounterd an error when doing '||stmt_name||' :'||sqlcode||': '||l_process_message;
END;
PROCEDURE recv_vat_process(p_organization_id         IN NUMBER,
                                           p_location_id             IN NUMBER,
                                           p_Set_of_books_id       IN number,
                                           p_currency in varchar2,
                                           p_transaction_header_id   IN NUMBER,
                                           p_transaction_temp_id     IN NUMBER,
                                           p_vat_invoice_no          IN VARCHAR2,
                                           p_process_status  OUT NOCOPY VARCHAR2,
                                           p_process_message OUT NOCOPY VARCHAR2)
IS
 ln_regime_id                    NUMBER;
 lv_inv_gen_process_flag         VARCHAR2(10);
 lv_inv_gen_process_message      VARCHAR2(2000);
 ln_repository_id                NUMBER;
 lv_source_trx_type              VARCHAR2(30):='RECEIVING';
 table_rcv_transactions          VARCHAR2(30):= 'JAI_MTL_TRXS';
 lv_account_name                 VARCHAR2(50);
 ln_code_combination_id          NUMBER;
 ln_interim_recovery_account     NUMBER;
 ln_entered_dr                   NUMBER;
 ln_entered_cr                   NUMBER;
 lv_process_status              VARCHAR2(2);
 lv_process_message             VARCHAR2(1000);
  v_source_name                   VARCHAR2(100) := 'Register India'                    ; -- bug 6487405
  v_category_name                 VARCHAR2(100) := 'VAT India'                  ; -- bug 6487405

--regime  varchar2(100):=jai_constants.vat_regime;
CURSOR c_regime_cur IS
    SELECT regime_id
    FROM   jai_rgm_definitions
    WHERE  regime_code = 'VAT';
    /*added the below cursor for performance issue*/
    --start
CURSOR c_chk_rgm_trxs(cp_transaction_header_id in number,cp_transaction_temp_id in number,cp_tax_id in number) IS
SELECT 1
        FROM
        jai_rgm_trx_records jrtr
        WHERE
         jrtr.attribute1         = cp_transaction_header_id         AND
         jrtr.source_document_id = cp_transaction_temp_id   AND
         jrtr.reference_id       = cp_tax_id AND
         jrtr.organization_id=p_organization_id AND
         jrtr.location_id=p_location_id;
CURSOR get_tax_id(cp_transaction_header_id in number,cp_transaction_temp_id in number)
IS
select tax_id
from jai_cmn_document_taxes
where source_doc_id=cp_transaction_header_id
and source_doc_line_id=cp_transaction_temp_id
and source_doc_type='INTERORG_XFER';
---END----
    CURSOR cur_get_mtltxns
              IS
              SELECT
                 jtc.tax_type,
                 jtc.tax_rate,
                 --jtc.tax_id,
                 jmt.transaction_temp_id,
                 jmt.transaction_header_id,
                 --jmt.creation_date,
                 sum(jcdt.tax_amt) tax_amt
              FROM
                 jai_mtl_trxs jmt,
                 jai_cmn_document_taxes jcdt,
                 jai_cmn_taxes_all jtc,
                 jai_rgm_registrations jrg,
		 jai_rgm_definitions jrr
                    WHERE
		      jmt.to_organization   = p_organization_id
		      AND jmt.location_id        = p_location_id
		      AND jmt.transaction_header_id  = p_transaction_header_id
		      AND jmt.transaction_temp_id=p_transaction_temp_id
		      AND jmt.transaction_header_id=jcdt.source_doc_id
		      AND jmt.transaction_temp_id=jcdt.source_doc_line_id
		      AND jcdt.tax_id=jtc.tax_id
		      AND jtc.tax_type= jrg.attribute_code    -- bug  6436781
		      AND jrr.regime_code = jai_constants.vat_regime
		      AND jrg.regime_id = jrr.regime_id
		      AND jrg.registration_type = 'TAX_TYPES'
		      AND upper(jrg.attribute_code) <> 'VAT REVERSAL'
		                  GROUP BY jtc.tax_type,
		                           jtc.tax_rate,
		                           jmt.transaction_temp_id,
		                             jmt.transaction_header_id;


 stmt_name VARCHAR2(64);
 ln_rgm_cnt number;--bug #6030615
 r_get_tax_id get_tax_id%rowtype;--bug #6030615
BEGIN
OPEN  c_regime_cur;
FETCH c_regime_cur into ln_regime_id;
CLOSE c_regime_cur;
FOR rec_claims IN cur_get_mtltxns
LOOP
ln_rgm_cnt:=0;
	FOR r_get_tax_id in get_tax_id(rec_claims.transaction_header_id,rec_claims.transaction_temp_id)
	LOOP
	open c_chk_rgm_trxs(rec_claims.transaction_header_id,rec_claims.transaction_temp_id,r_get_tax_id.tax_id);
	fetch c_chk_rgm_trxs into ln_rgm_cnt;
	close c_chk_rgm_trxs;
	if ln_rgm_cnt=1 then
	   exit;
	end if;
	END LOOP;
--added this if condition for performance issue
if nvl(ln_rgm_cnt,0) = 0 then
       lv_account_name := jai_constants.recovery;
       stmt_name:='Getting the interim recovery amount';
       ln_interim_recovery_account :=
                                      jai_cmn_rgm_recording_pkg.get_account(
                                         p_regime_id         => ln_regime_id,
                                         p_organization_type => jai_constants.orgn_type_io,
                                         p_organization_id   => p_organization_id,
                                         p_location_id       => p_location_id,
                                         p_tax_type          => rec_claims.tax_type,
                                         p_account_name      => jai_constants.recovery_interim);
      IF ln_interim_recovery_account IS NULL THEN
           p_process_status := jai_constants.expected_error;
           p_process_message := 'Interim recovery Account not defined in VAT Setup';
           RETURN;
      END IF;
      stmt_name:='Getting the code combination id';
      ln_code_combination_id :=
                                   jai_cmn_rgm_recording_pkg.get_account(
                                     p_regime_id         => ln_regime_id,
                                     p_organization_type => jai_constants.orgn_type_io,
                                     p_organization_id   => p_organization_id,
                                     p_location_id       => p_location_id,
                                     p_tax_type          => rec_claims.tax_type,
                                     p_account_name      => jai_constants.recovery);
         IF ln_code_combination_id IS NULL THEN
           p_process_status := jai_constants.expected_error;
           p_process_message := 'Recovery Account not defined in VAT Setup';
           RETURN;
         END IF;
      ln_entered_dr := NULL;
      ln_entered_cr := rec_claims.tax_amt;
      IF ln_entered_cr < 0 THEN
        ln_entered_dr := ln_entered_cr*-1;
        ln_entered_cr := NULL;
      END IF;
      stmt_name:='Calling insert vat repository entry';
   jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                    pn_repository_id        => ln_repository_id,
                                    pn_regime_id            => ln_regime_id,
                                    pv_tax_type             => rec_claims.tax_type,
                                    pv_organization_type    => jai_constants.orgn_type_io,
                                    pn_organization_id      => p_organization_id,
                                    pn_location_id          => p_location_id,
                                    pv_source               => jai_constants.source_rcv,
                                    pv_source_trx_type      => lv_source_trx_type,
                                    pv_source_table_name    => table_rcv_transactions,
                                    pn_source_id            => p_transaction_temp_id,
                                    pd_transaction_date     => trunc(sysdate),
                                    pv_account_name         => lv_account_name,
                                    pn_charge_account_id    => ln_code_combination_id,
                                    pn_balancing_account_id => ln_interim_recovery_account,
                                    pn_credit_amount        => ln_entered_cr,
                                    pn_debit_amount         => ln_entered_dr,
                                    pn_assessable_value     => NULL,
                                    pn_tax_rate             => NULL,
                                    pn_reference_id         => p_transaction_temp_id,/*r_claim_schedule.claim_schedule_id,*/
                                    pn_batch_id             => NULL,
                                    pn_inv_organization_id  => P_organization_id,
                                    pv_invoice_no           => p_vat_invoice_no,
                                    pd_invoice_date         => trunc(sysdate),
                                    pv_called_from          => 'JAINVMTX',
                                    pv_process_flag         => lv_process_status,
                                    pv_process_message      => lv_process_message,
                                    --Added by Bo Li for bug9305067 2010-4-14 BEGIN
                                    --------------------------------------------------
                                    pv_trx_reference_context    => NULL,
      														  pv_trx_reference1           => NULL,
      														  pv_trx_reference2           => NULL,
                                    pv_trx_reference3           => NULL,
                                    pv_trx_reference4           => NULL,
                                    pv_trx_reference5           => NULL
                                    --------------------------------------------------
                                    --Added by Bo Li for bug9305067 2010-4-14 END
                                    );
       IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
        END IF;
        begin
                         jai_mtl_trxs_pkg.do_cenvat_Acctg(
                                                          p_set_of_books_id     => p_set_of_books_id ,
                                                          p_transaction_temp_id =>p_transaction_temp_id ,
                                                          p_je_source_name      =>v_source_name ,
                                                          p_je_category_name    =>v_category_name,
                                                          p_currency_code       => p_currency  ,
                                                          p_register_type       => 'RVAT',
                                                          p_process_status      => lv_process_status,
                                                           p_process_message    =>lv_process_message
                                                       );
                          if   lv_process_message is not null then
                            p_process_message:=lv_process_message;
                            app_exception.raise_exception;
                          end if;
                   exception when others then
                      app_exception.raise_exception;
                   end;


        /*COMMENTED BY VASAVI*/
      ---CR Vat Recovery
      /*
      ln_entered_dr := NULL;
      ln_entered_cr := rec_claims.tax_amt;
      stmt_name:='calling do vat  accounting procedure for credit';
     jai_cmn_rgm_recording_pkg.do_vat_accounting(
                                      pn_regime_id            =>  ln_regime_id,
                                      pn_repository_id        =>  ln_repository_id,
                                      pv_organization_type    =>  jai_constants.orgn_type_io,
                                      pn_organization_id      =>  p_organization_id,
                                      pd_accounting_date      =>  trunc(sysdate),
                                      pd_transaction_date     =>  trunc(sysdate),
                                      pn_credit_amount        =>  ln_entered_cr,
                                      pn_debit_amount         =>  ln_entered_dr,
                                      pn_credit_ccid          =>  ln_interim_recovery_account  ,
                                      pn_debit_ccid           =>  ln_code_combination_id,
                                      pv_called_from          =>  NULL,
                                      pv_process_flag         =>  lv_process_status,
                                      pv_process_message      =>  lv_process_message,
                                      pv_tax_type             =>  rec_claims.tax_type,
                                      pv_source               =>  jai_constants.source_rcv,
                                      pv_source_trx_type      =>  lv_source_trx_type,
                                      pv_source_table_name    =>  table_rcv_transactions,
                                      pn_source_id            =>  p_transaction_temp_id,
                                      pv_reference_name       =>  NULL,
                                      pn_reference_id         =>  NULL
    );
  ---Dr Vat Recovery
      ln_entered_dr := rec_claims.tax_amt;
           ln_entered_cr:= NULL;
           stmt_name:='calling do vat  accounting procedure for debit';
             jai_cmn_rgm_recording_pkg.do_vat_accounting(
                                              pn_regime_id            =>  ln_regime_id,
                                              pn_repository_id        =>  ln_repository_id,
                                              pv_organization_type    =>  jai_constants.orgn_type_io,
                                              pn_organization_id      =>  p_organization_id,
                                              pd_accounting_date      =>  trunc(sysdate),
                                              pd_transaction_date     =>  trunc(sysdate),
                                              pn_credit_amount        =>  ln_entered_cr,
                                              pn_debit_amount         =>  ln_entered_dr,
                                              pn_credit_ccid          =>  ln_interim_recovery_account ,
                                              pn_debit_ccid           =>  ln_code_combination_id,
                                              pv_called_from          =>  NULL,
                                              pv_process_flag         =>  lv_process_status,
                                              pv_process_message      =>  lv_process_message,
                                              pv_tax_type             =>  rec_claims.tax_type,
                                              pv_source               =>  jai_constants.source_rcv,
                                              pv_source_trx_type      =>  lv_source_trx_type,
                                              pv_source_table_name    =>  table_rcv_transactions,
                                              pn_source_id            =>  p_transaction_temp_id,
                                              pv_reference_name       =>  NULL,
                                              pn_reference_id         =>  NULL
  );
  */
  end if; --ln_rgm_cnt
END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := 'E';
      p_process_message := 'SQL error @ '||stmt_name||' :'||sqlcode||': '||sqlerrm;
END;

procedure cenvat_recpt_det(block_data  in out NOCOPY claimcur,
                           p_organization_id in number)
is
begin
open block_data for
select rcv.receipt_num,
rcv.quantity,
cen.cenvat_claimed_ptg,
cen.quantity_for_2nd_claim,
cen.cenvat_amt_for_2nd_claim,
cen.shipment_line_id,
cen.cenvat_claimed_amt,
cen.other_cenvat_claimed_amt ,
cen.other_cenvat_amt_for_2nd_claim,
cen.cenvat_amount,
cen.other_cenvat_amt,
cen.transaction_id ,
rcv.excise_invoice_no ,
rcv.excise_invoice_date
from
JAI_RCV_TRANSACTIONS rcv,
JAI_RCV_CENVAT_CLAIMS cen
where
rcv.shipment_line_id=cen.shipment_line_id
and rcv.item_class in ('CGIN','CGEX')
and rcv.transaction_type='RECEIVE'
and cen.cenvat_claimed_ptg<>0
and cen.quantity_for_2nd_claim is not null
and organization_id=p_organization_id
order by receipt_num;
end cenvat_recpt_det;

PROCEDURE gl_entry(p_params IN gl_entries,
                   p_set_of_books_id     IN NUMBER,
                   p_je_source_name      IN VARCHAR2,
                   p_je_category_name    IN VARCHAR2,
                   p_currency_code       IN VARCHAR2,
                   p_transaction_temp_id IN NUMBER,
                   p_process_status      OUT NOCOPY VARCHAR2,
                   p_process_message     OUT NOCOPY VARCHAR2)
IS
   stmt_name VARCHAR2(256);
BEGIN

    FOR i IN 0..p_params.COUNT-1
    LOOP

        IF p_params(i).amount IS NOT NULL AND
           p_params(i).debit_account IS NOT NULL AND
           p_params(i).credit_account IS NOT NULL
        THEN
            stmt_name := 'Calling insert into gl_interface debit';
            insert into gl_interface
            ( status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              actual_flag,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
	      reference22
            )
            VALUES
            ('NEW',
             p_set_of_books_id,
             p_je_source_name,
             p_je_category_name,
             sysdate,
             p_currency_code,
             sysdate,
             fnd_global.user_id,
             'A',
             null,
             p_params(i).amount,
             sysdate,
             p_params(i).debit_account, -- Derived Value from JAI_CMN_INVENTORY_ORGS / mtl_interorg_parameters
             null,
             null,
             null,
             p_params(i).organization_code,   -- From mtl_parameters
             'India Localization Entry for Interorg-XFER ',
             'jai_mtl_trx_pkg.do_cenvat_Acctg',
             'jai_mtl_trxs',
             p_transaction_temp_id,
             'transaction_temp_id',
             to_char(p_params(i).organization_id),
	     'India Localization Entry' -- bug 6487405
            );


      stmt_name := 'Calling insert into jai_mtl_trx_jrnls debit';
            insert into jai_mtl_trx_jrnls
            (journal_entry_id,
            status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
              creation_Date,
              last_updated_by,
              last_update_date,
              last_update_login,
              transaction_temp_id

           )
            VALUES
            (jai_mtl_trx_jrnls_s.nextval,
            'NEW',
             p_set_of_books_id,
             p_je_source_name,
             p_je_category_name,
             sysdate,
             p_currency_code,
             sysdate,
             fnd_global.user_id,
             null,
             p_params(i).amount,
             sysdate,
             p_params(i).debit_account, -- Derived Value from JAI_CMN_INVENTORY_ORGS / mtl_interorg_parameters
             null,
             null,
             null,
             p_params(i).organization_code,   -- From mtl_parameters
             'India Localization Entry for Interorg-XFER ',
             'jai_mtl_trx_pkg.do_cenvat_Acctg',
             'jai_mtl_trxs',
             p_transaction_temp_id,
             'transaction_temp_id',
             to_char(p_params(i).organization_id),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             p_transaction_temp_id
	    );


            stmt_name := 'Calling insert int gl_interface credit';
            insert into gl_interface
            ( status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              actual_flag,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
              reference22
            )
            VALUES
            ('NEW',
             p_set_of_books_id,
             p_je_source_name,
             p_je_category_name,
             sysdate,
             p_currency_code,
             sysdate,
             fnd_global.user_id,
             'A',
             p_params(i).amount,
             null,
             sysdate,
             p_params(i).credit_account,
             null,
             null,
             null,
             p_params(i).organization_code,
             'India Localization Entry for Interorg-XFER ',
             'jai_mtl_trx_pkg.do_cenvat_Acctg',
             'jai_mtl_trxs',
             p_transaction_temp_id,
             'transaction_temp_id',
             to_char(p_params(i).organization_id),
	      'India Localization Entry' -- bug 6487405
            );


      stmt_name := 'Calling insert int jai_mtl_trx_jrnls credit';
            insert into jai_mtl_trx_jrnls
            (journal_entry_id,
            status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
              creation_Date,
              last_updated_by,
              last_update_date,
              last_update_login,
              transaction_temp_id
)
            VALUES
            (jai_mtl_trx_jrnls_s.nextval,
            'NEW',
             p_set_of_books_id,
             p_je_source_name,
             p_je_category_name,
             sysdate,
             p_currency_code,
             sysdate,
             fnd_global.user_id,
             p_params(i).amount,
             null,
             sysdate,
             p_params(i).credit_account,
             null,
             null,
             null,
             p_params(i).organization_code,
             'India Localization Entry for Interorg-XFER ',
             'jai_mtl_trx_pkg.do_cenvat_Acctg',
             'jai_mtl_trxs',
             p_transaction_temp_id,
             'transaction_temp_id',
             to_char(p_params(i).organization_id),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             p_transaction_temp_id
	    );

        END IF;
    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    p_process_status  := 'E';
    p_process_message := 'Stmt'||stmt_name||'-'||sqlcode||':'||sqlerrm;
    ROLLBACK TO gl_acctg;
END;



PROCEDURE do_cenvat_Acctg(
  p_set_of_books_id          IN NUMBER,
  p_transaction_temp_id      IN NUMBER,
  p_je_source_name           IN VARCHAR2,
  p_je_category_name         IN VARCHAR2,
  p_currency_code            IN VARCHAR2,
  p_register_type            IN VARCHAR2,
  p_process_status           OUT NOCOPY VARCHAR2,
  p_process_message          OUT  NOCOPY VARCHAR2
  )
 IS
  CURSOR main_cur IS
    SELECT A.Tax_Id,
           DECODE(aa.regime_code, 'VAT', 4, DECODE( UPPER( A.Tax_Type ),
                 'EXCISE', 1,
           'ADDL. EXCISE', 1,
           'OTHER EXCISE', 1,
           jai_constants.tax_type_exc_edu_cess, 5,jai_constants.tax_type_sh_exc_edu_cess,6, /*changed taxtype_val to 6 for sh_cess by vkaranam for bug #5907436*/--Added higher education cess by kundan kumar for bug#5907436

           'TDS', 2, 0)) tax_type_val,
           A.Tax_Amt tax_amount,
           b.tax_account_id ,
           A.Tax_Type tax_type,
           d.from_organization ,
           d.from_subinventory ,
           d.to_organization ,
           d.to_subinventory ,
           d.location_id,
           d.inventory_item_id
     FROM Jai_cmn_document_Taxes A,
          jai_cmn_taxes_all B,
          jai_mtl_trxs     D,
          jai_regime_tax_types_v aa
    WHERE source_doc_line_id = p_transaction_temp_id
      AND d.transaction_temp_id = p_transaction_temp_id
      AND a.source_doc_type  = 'INTERORG_XFER'
      AND A.Tax_Id = B.Tax_Id
      AND aa.tax_type(+) = b.tax_type;


  l_process_status VARCHAR2(5) DEFAULT NULL;
  l_process_message VARCHAR2(256) DEFAULT NULL;
  processed_flag VARCHAR2(32) := '0';
  stmt_name VARCHAR2(256);

  ln_from_loc_id   NUMBER;

  -- Parameter Table
  t_gl_entries  gl_entries;
  rec           NUMBER := 0;
  /*
  ccids from organization additional information setup
  */
  r_from_ja_in_hr_org    JAI_CMN_INVENTORY_ORGS%rowtype;
  r_to_ja_in_hr_org      JAI_CMN_INVENTORY_ORGS%rowtype;

  /*
  ccids from mtl interorg parameters
  */
  r_mtl_interorg         mtl_interorg_parameters%rowtype;

  /*
  cc id of inventory recvng accnt
  */
  ln_inv_recvng          NUMBER;



  CURSOR c_get_location(p_organization_id IN NUMBER , p_subinventory IN VARCHAR2)
  IS
  SELECT location_id
  FROM   JAI_INV_SUBINV_DTLS
  WHERE  organization_id = p_organization_id
  AND    sub_inventory_name    = p_subinventory;

  CURSOR c_get_ja_accts(p_organization_id NUMBER , p_location_id number)  IS
  SELECT *
  FROM   JAI_CMN_INVENTORY_ORGS
  WHERE  organization_id = p_organization_id
  AND    location_id    = p_location_id;

  CURSOR c_get_interorg_params( p_from_organization_id IN NUMBER, p_to_organization_id IN NUMBER ) IS
  SELECT *
  FROM   mtl_interorg_parameters
  WHERE  from_organization_id = p_from_organization_id
  AND    to_organization_id   = p_to_organization_id ;

  CURSOR c_get_trx_info IS
  SELECT * FROM jai_mtl_trxs
  WHERE  transaction_temp_id = p_transaction_temp_id;

  CURSOR c_rcv_params (p_organization_id IN NUMBER) IS
  select receiving_account_id
  FROM   rcv_parameters
  WHERE  organization_id = p_organization_id;

  CURSOR c_org_code(p_org_id IN NUMBER) IS
  SELECT organization_code
  FROM mtl_parameters
  WHERE organization_id = p_org_id;

  CURSOR c_item_class (cp_inv_item_id IN NUMBER , cp_orgn_id IN NUMBER) IS
  select item_class
  from   JAI_INV_ITM_SETUPS
  where  inventory_item_id = cp_inv_item_id
  and    organization_id   = cp_orgn_id ;

  r_item_class  c_item_class%rowtype;


  r_mtl_trx_info         c_get_trx_info%ROWTYPE;
  r_rcv_params           c_rcv_params%ROWTYPE;
  r_get_interorg_params  c_get_interorg_params%ROWTYPE;
  l_from_org_cd          mtl_parameters.organization_code%TYPE;
  l_to_org_cd            mtl_parameters.organization_code%TYPE;
  l_regime_id            NUMBER;

  lv_process_flag        VARCHAR2(20);
  lv_process_message     VARCHAR2(2000);

	CURSOR c_get_bonded(p_organization_id IN NUMBER , p_subinventory IN VARCHAR2)/*6487803*/
	IS
	SELECT bonded
	FROM   JAI_INV_SUBINV_DTLS
	WHERE  organization_id       = p_organization_id
	AND    sub_inventory_name    = p_subinventory;

	lv_bonded              JAI_INV_SUBINV_DTLS.bonded%TYPE; /*6487803*/



BEGIN
     SAVEPOINT gl_acctg;

     stmt_name := 'Opening main_cur';
     OPEN  c_get_trx_info;
     FETCH c_get_trx_info INTO r_mtl_trx_info;
     CLOSE c_get_trx_info;

     stmt_name := 'Selecting From_organization_code';
     OPEN c_org_code(r_mtl_trx_info.from_organization);
     FETCH c_org_code INTO l_from_org_cd;
     CLOSE c_org_code;

     stmt_name := 'Selecting to_organization_code';
     OPEN c_org_code(r_mtl_trx_info.to_organization);
     FETCH c_org_code INTO l_to_org_cd;
     CLOSE c_org_code;

     stmt_name := 'Selecting regime id';
     SELECT regime_id
       INTO l_regime_id
       FROM jai_rgm_definitions
      WHERE regime_Code = 'VAT';

     stmt_name := 'Opening c_get_interorg_params';
     OPEN   c_get_interorg_params(r_mtl_trx_info.from_organization, r_mtl_trx_info.to_organization) ;
     FETCH  c_get_interorg_params INTO r_get_interorg_params;
     CLOSE  c_get_interorg_params;

     /*
     get the from org accts from org additional info setup
     */


       /*
       1. get the FROM location
       2. get the accounts FROM ja_in_hr_organization units FOR FROM org AND TO org
       3. get the accounts FROM mtl_interorg_parameters based ON FROM org AND TO org
       4. get the inventory recvng accnt FROM rcv_parameters
     */

     stmt_name := 'Opening c_get_location';
     OPEN  c_get_location(r_mtl_trx_info.from_organization , r_mtl_trx_info.from_subinventory);
     FETCH c_get_location INTO ln_from_loc_id;
     CLOSE c_get_location;

     stmt_name := 'Opening c_get_bonded'; /*6487803*/
     OPEN  c_get_bonded(r_mtl_trx_info.to_organization , r_mtl_trx_info.to_subinventory);
     FETCH c_get_bonded INTO lv_bonded;
     CLOSE c_get_bonded;

     stmt_name := 'Opening c_get_ja_accts';
     OPEN  c_get_ja_accts ( r_mtl_trx_info.from_organization  , ln_from_loc_id);
     FETCH c_get_ja_accts INTO r_from_ja_in_hr_org;
     CLOSE c_get_ja_accts;

     stmt_name := 'Opening c_get_ja_accts';
     OPEN  c_get_ja_accts ( r_mtl_trx_info.to_organization  , r_mtl_trx_info.location_id);
     FETCH c_get_ja_accts INTO r_to_ja_in_hr_org;
     CLOSE c_get_ja_accts;

     stmt_name := 'Opening c_rcv_params';
     OPEN c_rcv_params(r_mtl_trx_info.to_organization);
     FETCH c_rcv_params INTO r_rcv_params;
     CLOSE c_rcv_params;



     FOR main_rec IN main_cur
     LOOP



	IF main_rec.tax_type_val = 1 and p_register_type IN ('A','C','PLA','RG23D' ) THEN

               IF   r_from_ja_in_hr_org.TRADING  <> 'Y' THEN    -- bug 6740006

		  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_from_ja_in_hr_org.excise_rcvble_account;


		  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Excise paid/payables a/c is null';
                      RETURN;
                  END IF;

                  IF r_from_ja_in_hr_org.excise_paid_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := '';
                  END IF;
                  IF p_register_type = 'A' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.modvat_rm_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Modvat RM a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'PLA' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.modvat_pla_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Modvat PLA a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'C' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.modvat_cg_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Modvat CG a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'RG23D' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Excise 23D a/c is null';
                          RETURN;
                      END IF;

                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;
                  rec := rec + 1;
               END IF ;   -- bug 6740006


          IF r_get_interorg_params.intransit_type = 2   /* Intransit */ THEN

            IF r_get_interorg_params.fob_point = 1 THEN  -- SHIPMENTS

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
		   IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_rcvble_account;
		  END if;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;

		  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Interorg Receivables a/c is null';
                      RETURN;
                  ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Excise paid/payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account ;
                  t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                  t_gl_entries(rec).organization_code := l_to_org_cd;
                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Intransit inventory a/c is null';
                      RETURN;
                  ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'InterOrg Payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

            ELSIF r_get_interorg_params.fob_point = 2 THEN  -- Receipt

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account ;
		  IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                    t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_rcvble_account;
		  END if;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;
                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Intransit inventory a/c is null';
                      RETURN;
                  ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Excise paid/payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

            END IF;

          ELSIF r_get_interorg_params.intransit_type = 1  THEN -- Direct

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;

		 IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6740006
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                 ELSE
                     t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_rcvble_account;
                 END IF;

                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;


                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'InterOrg receivables a/c is null';
                      RETURN;
                  ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Excise paid payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_rcv_params.receiving_account_id;
                  t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                  t_gl_entries(rec).organization_code := l_to_org_cd;



                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Inventory Receiving a/c is null';
                      RETURN;
                  ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'InterOrg Payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

		              open  c_item_class(main_rec.inventory_item_id, r_mtl_trx_info.to_organization);
                  FETCH c_item_class INTO r_item_class;
                  close c_item_class;

		              IF (r_to_ja_in_hr_org.TRADING = 'Y' or lv_bonded = 'Y') AND /*6487803*/
		                r_item_class.item_class NOT IN ('FGIN','FGEX') THEN /*6501436*/

                    t_gl_entries(rec).amount                   := main_rec.tax_amount;
                    -- CHANGES FOR START  BUG  6740006


		               IF   r_to_ja_in_hr_org.TRADING = 'Y' THEN
		                 t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.excise_23d_account;
                     IF r_to_ja_in_hr_org.excise_23d_account IS NULL THEN
                        p_process_status    :='E';
                        p_process_message   :='RG23D Account not defined in Receiving Org';
                        RETURN;
                     END IF;
                   ELSIF  r_item_class.item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')  then /*/*6501436.removed FGIN and FGEX*/
                     t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.modvat_rm_account_id;
                     IF r_to_ja_in_hr_org.modvat_rm_account_id IS NULL THEN
                        p_process_status     := 'E';
                        p_process_message := 'Modvat RM Account not defined in Receiving Org';
                        RETURN;
                     END IF;
		               ELSIF r_item_class.item_class IN ('CGIN', 'CGEX') then
                     t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.modvat_cg_account_id;
                     IF r_to_ja_in_hr_org.modvat_cg_account_id IS NULL THEN
                        p_process_status     :='E';
                        p_process_message    :='Modvat CG Account not defined in Receiving Org';
                        RETURN;
                     END IF;
		               end if;


                   -- CHANGES FOR END  BUG  6740006


                   t_gl_entries(rec).credit_account    := r_rcv_params.receiving_account_id;
                   IF t_gl_entries(rec).credit_account IS  NULL THEN
                      p_process_Status := 'E';
                      p_process_message := 'Receiving Inventory ACcount is not defined for Receiving Org';
                      RETURN;
                   END IF;
                   t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                   t_gl_entries(rec).organization_code := l_to_org_cd;
                   rec := rec + 1;
                 END IF;/*6487803*/

          END IF;
        ELSIF main_rec.tax_type_val = 5  and p_register_type IN ('A','C','PLA','RG23D' )  THEN      -- excise education cess

               IF   r_from_ja_in_hr_org.TRADING  <> 'Y' THEN    -- bug 6740006

		  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_from_ja_in_hr_org.cess_paid_payable_account_id;




                  IF p_register_type = 'A' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_edu_cess_rm_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Excise cess RM a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'PLA' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.modvat_pla_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Modvat PLA a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'C' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_edu_cess_cg_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Excise cess cg a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'RG23D' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Excise RG23D a/c is null';
                          RETURN;
                      END IF;

                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;
                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'Cess-Paid Payables a/c is null';
                      RETURN;
                  END IF;




                  rec := rec + 1;

               END IF;  -- bug 6740006

          IF r_get_interorg_params.intransit_type = 2  THEN -- IN TRANSIT

            IF r_get_interorg_params.fob_point = 1 THEN  -- Shipments
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
		  IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                 t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.cess_paid_payable_account_id;
		  END if;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg recevables a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit inventory a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

            ELSIF r_get_interorg_params.fob_point = 2 THEN   -- Receipts

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
		  IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.cess_paid_payable_account_id;
		 END if;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit Inventory a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

            END IF;

          ELSIF r_get_interorg_params.intransit_type = 1  THEN -- Direct

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;

		             IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6740006
                   t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                 ELSE
                   t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.cess_paid_payable_account_id;
		             END IF;

                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;




                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Inventory receiving a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_rcv_params.receiving_account_id;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;



                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Inventory receiving a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

          -- start entries for cenvat in direct org

								 open  c_item_class(main_rec.inventory_item_id, r_mtl_trx_info.to_organization);
								 FETCH c_item_class INTO r_item_class;
								 close c_item_class;

                 IF r_to_ja_in_hr_org.TRADING = 'Y' or lv_bonded = 'Y' /*6487803*/
                   AND r_item_class.item_class NOT IN ( 'FGIN', 'FGEX' ) THEN /*6501436*/


                   t_gl_entries(rec).amount := main_rec.tax_amount;

                   -- CHANGES FOR START  BUG  6740006

              	   IF   r_to_ja_in_hr_org.TRADING = 'Y' THEN
                        t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.excise_23d_account;
                     IF r_to_ja_in_hr_org.excise_23d_account IS NULL THEN
                        p_process_status    :='E';
                        p_process_message   :='RG23D Account not defined in Receiving Org';
                        RETURN;
                     END IF;
                   ELSIF  r_item_class.item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')  then  /*6501436..removed FGIN FGEX*/
			               t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.excise_edu_cess_rm_account;
                     IF r_to_ja_in_hr_org.excise_edu_cess_rm_account IS NULL THEN
                        p_process_status     := 'E';
                        p_process_message := 'Cess RM Account not defined in Receiving Org';
                        RETURN;
                     END IF;
                   ELSIF r_item_class.item_class IN ('CGIN', 'CGEX') then
		                 t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.excise_edu_cess_cg_account;
                     IF r_to_ja_in_hr_org.excise_edu_cess_cg_account IS NULL THEN
                        p_process_status     :='E';
                        p_process_message    :='Cess CG Account not defined in Receiving Org';
                        RETURN;
                     END IF;
                   END if;

                   -- CHANGES FOR END  BUG  6740006


                   t_gl_entries(rec).credit_account    := r_rcv_params.receiving_account_id;
                   IF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status := 'E';
                      p_process_message := 'Receiving Inventory Account not defined for receiving org';
                      RETURN;
                   END IF;
                   t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                   t_gl_entries(rec).organization_code := l_to_org_cd;

                   rec := rec + 1;

                 END IF;  /*6487803*/
          -- end

          END IF;
      /*following elsif condition added for shcess by vkaranam for bug #5907436*/
      --start 5907436

      ELSIF main_rec.tax_type_val = 6  and p_register_type IN ('A','C','PLA','RG23D' )  THEN


            IF   r_from_ja_in_hr_org.TRADING  <> 'Y' THEN    -- bug 6740006

                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := r_from_ja_in_hr_org.sh_cess_paid_payable_acct_id;
                  IF p_register_type = 'A' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.sh_cess_rm_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'SH Excise cess RM a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'PLA' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.modvat_pla_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Modvat PLA a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'C' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.sh_cess_cg_account_id;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'SH Excise cess cg a/c is null';
                          RETURN;
                      END IF;
                  ELSIF p_register_type = 'RG23D' THEN
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                      IF t_gl_entries(rec).credit_account IS  NULL THEN
                          p_process_status  := 'E';
                          p_process_message := 'Excise RG23D a/c is null';
                          RETURN;
                      END IF;

                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;


                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status  := 'E';
                      p_process_message := 'SH Cess-Paid Payables a/c is null';
                      RETURN;
                  END IF;
                  rec := rec + 1;

              END IF ; -- bug 6740006

          IF r_get_interorg_params.intransit_type = 2  THEN -- IN TRANSIT

            IF r_get_interorg_params.fob_point = 1 THEN  -- Shipments
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;--1102
		   IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                      t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.sh_cess_paid_payable_acct_id;
                 END if;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg recevables a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'SH Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit inventory a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

            ELSIF r_get_interorg_params.fob_point = 2 THEN   -- Receipts

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
		   IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6488406
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                  ELSE
                     t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.sh_cess_paid_payable_acct_id;
                  END if;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit Inventory a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'SH Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

            END IF;

          ELSIF r_get_interorg_params.intransit_type = 1  THEN -- Direct


                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;

		 IF r_from_ja_in_hr_org.TRADING = 'Y' THEN  -- BUG 6740006
                       t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.excise_23d_account;
                 ELSE
                     t_gl_entries(rec).credit_account    := r_from_ja_in_hr_org.sh_cess_paid_payable_acct_id;
		 END IF;

                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;



                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Inventory receiving a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'SH Cess-paid Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_rcv_params.receiving_account_id;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Inventory receiving a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

								 open  c_item_class(main_rec.inventory_item_id, r_mtl_trx_info.to_organization);
								 FETCH c_item_class INTO r_item_class;
								 close c_item_class;

                 IF r_to_ja_in_hr_org.TRADING = 'Y' or lv_bonded = 'Y' /*6487803*/
                    AND r_item_class.item_class NOT IN ('FGIN','FGEX') THEN /*6501436*/
                   -- start entries for cenvat in direct org
                   t_gl_entries(rec).amount := main_rec.tax_amount;


                   -- CHANGES FOR START  BUG  6740006


	             	  IF   r_to_ja_in_hr_org.TRADING = 'Y' THEN
	              		 t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.excise_23d_account;
                     IF r_to_ja_in_hr_org.excise_23d_account IS NULL THEN
                        p_process_status    :='E';
                        p_process_message   :='RG23D Account not defined in Receiving Org';
                        RETURN;
                     END IF;

	            	  ELSIF  r_item_class.item_class IN ('RMIN', 'RMEX', 'CCIN', 'CCEX')  then /*6501436.removed FGIN FGEX*/
                     t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.sh_cess_rm_account;
	                	 IF r_to_ja_in_hr_org.sh_cess_rm_account IS NULL THEN
			                 p_process_status     := 'E';
			                 p_process_message := 'SH Cess RM Account not defined in Receiving Org';
			                 RETURN;
			               END IF;
                  ELSIF r_item_class.item_class IN ('CGIN', 'CGEX') then
		                 t_gl_entries(rec).debit_account            := r_to_ja_in_hr_org.sh_cess_cg_account_id;
			               IF r_to_ja_in_hr_org.sh_cess_cg_account_id IS NULL THEN
			                 p_process_status     :='E';
			                 p_process_message    :='SH Cess CG Account not defined in Receiving Org';
			                 RETURN;
                     END IF;
                  end if;

                 -- CHANGES FOR END  BUG  6740006


                  t_gl_entries(rec).credit_account    := r_rcv_params.receiving_account_id;
                  IF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status := 'E';
                     p_process_message := 'Receiving Inventory Account not defined for receiving org';
                     RETURN;
                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                  t_gl_entries(rec).organization_code := l_to_org_cd;


                  rec := rec + 1;

               END IF;/*6487803*/
          -- end

          END IF;
          --END 5907436

        ELSIF main_rec.tax_type_val = 4 and p_register_type IN ('SVAT','RVAT') THEN  /* value added tax*/

             IF p_register_type='SVAT' and main_rec.tax_type <> 'VAT REVERSAL'  then
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 stmt_name := 'Calling:4 jai_cmn_rgm_recording_pkg.get_account()';
                 t_gl_entries(rec).debit_account     := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.liability_interim
                                                );
                 stmt_name := 'Calling:3 jai_cmn_rgm_recording_pkg.get_account()';
                 t_gl_entries(rec).credit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.liability
                                                ) ;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;

                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Interim Liability a/c is null for '||main_rec.tax_type;
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Liability a/c is null for '||main_rec.tax_type;
                     RETURN;
                 END IF;
                 rec := rec + 1;

            -- ELSIF  p_register_type='SVAT' and main_rec.tax_type =  'VAT REVERSAL'  then
                   /*
                         debit expense accnt
                         credit  VAT recovery Account
                   */
                --    t_gl_entries(rec).amount := main_rec.tax_amount;
               --     t_gl_entries(rec).debit_account     := jai_cmn_rgm_recording_pkg.get_account(
                 --                                 p_regime_id         => l_regime_id,
                 --                                 p_organization_type => jai_constants.orgn_type_io,
                 --                                 p_organization_id   => r_mtl_trx_info.from_organization,
                  --                                p_location_id       => ln_from_loc_id,
                  --                                p_tax_type          => main_rec.tax_type,
                  --                                p_account_name      => 'EXPENSE'
                  --                              );

                  -- t_gl_entries(rec).credit_account     := jai_cmn_rgm_recording_pkg.get_account(
                  --                                p_regime_id         => l_regime_id,
                  --                                p_organization_type => jai_constants.orgn_type_io,
                  --                                p_organization_id   => r_mtl_trx_info.from_organization,
                  --                                p_location_id       => ln_from_loc_id,
                  --                                p_tax_type          => main_rec.tax_type,
                  --                                p_account_name      => 'RECOVERY'
                  --                              );
                  -- IF t_gl_entries(rec).credit_account IS NULL THEN
                  --    p_process_status := 'E';
                  --    p_process_message := 'Recovery Account not setup in receiving Org for ' || main_rec.tax_type ;
                  --    RETURN;
                  -- END IF;
                  -- IF t_gl_entries(rec).debit_account IS NULL THEN
                  --    p_process_status := 'E';
                  --    p_process_message := 'Expense Account not setup in receiving Org for ' || main_rec.tax_type ;
                  --    RETURN;
                  -- END IF;
                  -- t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  -- t_gl_entries(rec).organization_code := l_from_org_cd;

                  -- rec := rec + 1;
             END IF;

          IF r_get_interorg_params.intransit_type = 2 and main_Rec.tax_type <> 'VAT REVERSAL'   THEN   /* Intransit */

             IF r_get_interorg_params.fob_point = 1 THEN  -- Shippment
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
                 stmt_name := 'Calling:2 jai_cmn_rgm_recording_pkg.get_account()';
                 t_gl_entries(rec).credit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.liability_interim
                                                );
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg receivable a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Interim Liablility a/c is null for '||main_rec.tax_type;
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit Inventory a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

            ELSIF r_get_interorg_params.fob_point = 2 THEN   --Receipt
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                 stmt_name := 'Calling:1 jai_cmn_rgm_recording_pkg.get_account()';
                 t_gl_entries(rec).credit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.liability_interim
                                                );
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Intransit Inventory a/c is null for '||main_rec.tax_type;
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Interim Liablility a/c is null for'||main_rec.tax_type;
                     RETURN;
                 END IF;
                 rec := rec + 1;

            END IF;

          ELSIF r_get_interorg_params.intransit_type = 1
          and p_register_type = 'RVAT' and main_rec.tax_type <> 'VAT RECOVERY'  /* Direct */ THEN
                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
                 stmt_name := 'Calling jai_cmn_rgm_recording_pkg.get_account()';
                 t_gl_entries(rec).credit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.liability_interim
                                                );
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                 t_gl_entries(rec).organization_code := l_from_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Receivable a/c is null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Interim Liablility a/c is null for'||main_rec.tax_type;
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 t_gl_entries(rec).amount := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account     := r_rcv_params.receiving_account_id;
                 t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 IF t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'Inventory Receiving a/c is Null';
                     RETURN;
                 ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status  := 'E';
                     p_process_message := 'InterOrg Payables a/c is null';
                     RETURN;
                 END IF;
                 rec := rec + 1;

                 -- starts here code for VAT
                 t_gl_entries(rec).amount           := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                       p_regime_id         => l_regime_id,
                                                       p_organization_type => jai_constants.orgn_type_io,
                                                       p_organization_id   => r_mtl_trx_info.to_organization,
                                                       p_location_id       => r_mtl_trx_info.location_id,
                                                       p_tax_type          => main_rec.tax_type,
                                                       p_account_name      => jai_constants.recovery_interim
                                                     );
                 IF  t_gl_entries(rec).debit_account IS NULL THEN
                     p_process_status := 'E';
                     p_process_message := 'Interim Recovery Account is not defined for ' || main_rec.tax_type;
                     RETURN;
                 END IF;
                 t_gl_entries(rec).credit_account := r_rcv_params.receiving_account_id;
                 IF  t_gl_entries(rec).credit_account IS NULL THEN
                     p_process_status := 'E';
                     p_process_message := 'Receiving Invetory is not defined ';
                     RETURN;
                 END IF;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 rec := rec + 1;


                 t_gl_entries(rec).amount           := main_rec.tax_amount;
                 t_gl_entries(rec).debit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.to_organization,
                                                  p_location_id       => r_mtl_trx_info.location_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => jai_constants.recovery
                                                  );

     IF t_gl_entries(rec).debit_account IS NULL THEN
        p_process_status := 'E';
        p_process_message := 'Recovery Account not defined for ' || main_rec.tax_type;
        RETURN;
     END IF;
                 t_gl_entries(rec).credit_account    := jai_cmn_rgm_recording_pkg.get_account(
                                                            p_regime_id         => l_regime_id,
                                                            p_organization_type => jai_constants.orgn_type_io,
                                                            p_organization_id   => r_mtl_trx_info.to_organization,
                                                            p_location_id       => r_mtl_trx_info.location_id,
                                                            p_tax_type          => main_rec.tax_type,
                                                            p_account_name      => jai_constants.recovery_interim
                                                         );
                 IF t_gl_entries(rec).credit_account IS NULL THEN
                    p_process_status := 'E';
                    p_process_message := 'Interim Recovery Account not defined for ' || main_rec.tax_type;
                    RETURN;
                 END IF;
                 t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                 t_gl_entries(rec).organization_code := l_to_org_cd;
                 rec := rec + 1;

-- ends here
          END IF;

        ELSIF main_rec.tax_type_val =0 and p_register_type is null   then
            /*  other tax types */
           IF r_get_interorg_params.intransit_type = 2    THEN   /* Intransit */
               IF main_rec.tax_type <> 'VAT REVERSAL' THEN
                 IF r_get_interorg_params.fob_point = 1 THEN  -- Shippments

                     t_gl_entries(rec).amount := main_rec.tax_amount;
                     t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
                     t_gl_entries(rec).credit_account    := main_rec.tax_account_id;
                     t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                     t_gl_entries(rec).organization_code := l_from_org_cd;
                     IF t_gl_entries(rec).debit_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'InterOrg Receivables a/c is Null';
                         RETURN;
                     ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Other Taxes account is null';
                         RETURN;
                     END IF;
                     rec := rec + 1;

                     t_gl_entries(rec).amount := main_rec.tax_amount;
                     t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                     t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                     t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                     t_gl_entries(rec).organization_code := l_to_org_cd;
                     IF t_gl_entries(rec).debit_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Intransit Inventory a/c is Null';
                         RETURN;
                     ELSIF t_gl_entries(rec).credit_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'InterOrg Payable a/c is null';
                         RETURN;
                     END IF;
                     rec := rec + 1;
                 ELSIF r_get_interorg_params.fob_point = 2 THEN  -- Receipts

                     IF r_get_interorg_params.intransit_inv_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Intransit Inventory a/c is Null';
                         RETURN;
                     ELSIF main_rec.tax_account_id IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Other Taxes a/c is null';
                         RETURN;
                     END IF;
                     t_gl_entries(rec).amount := main_rec.tax_amount;
                     t_gl_entries(rec).debit_account     := r_get_interorg_params.intransit_inv_account;
                     t_gl_entries(rec).credit_account    := main_rec.tax_account_id;
                     t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                     t_gl_entries(rec).organization_code := l_from_org_cd;
                     rec := rec + 1;
                 END IF;
                  -- do for vat reversal here
              ELSIF   main_rec.tax_type =  'VAT REVERSAL'  then
                 /*
                     debit expense accnt
                     credit  VAT recovery Account
                 */
                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => 'EXPENSE'
                                                );

                  t_gl_entries(rec).credit_account     := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => 'RECOVERY'
                                                );
                  IF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status := 'E';
                      p_process_message := 'Recovery Account not setup in receiving Org for ' || main_rec.tax_type ;
                      RETURN;
                  END IF;
                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status := 'E';
                      p_process_message := 'Expense Account not setup in receiving Org for ' || main_rec.tax_type ;
                      RETURN;
                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;

                  rec := rec + 1;
                  -- ends here for vat reversal
              END IF;
           ELSIF r_get_interorg_params.intransit_type = 1 and main_rec.tax_type <> 'VAT REVERSAL'   /* Direct */ THEN

                     IF r_get_interorg_params.interorg_receivables_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Inter-Organization Recevable a/c is Null';
                         RETURN;
                     ELSIF main_rec.tax_account_id IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Other Taxes a/c is null';
                         RETURN;
                     END IF;
                     t_gl_entries(rec).amount := main_rec.tax_amount;
                     t_gl_entries(rec).debit_account     := r_get_interorg_params.interorg_receivables_account;
                     t_gl_entries(rec).credit_account    := main_rec.tax_account_id;
                     t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                     t_gl_entries(rec).organization_code := l_from_org_cd;
                     rec := rec + 1;

                     IF r_get_interorg_params.interorg_payables_account IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Inter-org Payables a/c is null';
                         RETURN;
                     ELSIF r_rcv_params.receiving_account_id IS NULL THEN
                         p_process_status  := 'E';
                         p_process_message := 'Inventory Receiving a/c is null';
                         RETURN;
                     END IF;
                     t_gl_entries(rec).amount := main_rec.tax_amount;
                     t_gl_entries(rec).debit_account     := r_rcv_params.receiving_account_id;
                     t_gl_entries(rec).credit_account    := r_get_interorg_params.interorg_payables_account;
                     t_gl_entries(rec).organization_id   := r_mtl_trx_info.to_organization;
                     t_gl_entries(rec).organization_code := l_to_org_cd;
                     rec := rec + 1;
              -- for vat reversal in direct org transfer
              ELSIF   main_rec.tax_type =  'VAT REVERSAL'  then
                 /*
                     debit expense accnt
                     credit  VAT recovery Account
                 */
                  t_gl_entries(rec).amount := main_rec.tax_amount;
                  t_gl_entries(rec).debit_account     := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => 'EXPENSE'
                                                );

                  t_gl_entries(rec).credit_account     := jai_cmn_rgm_recording_pkg.get_account(
                                                  p_regime_id         => l_regime_id,
                                                  p_organization_type => jai_constants.orgn_type_io,
                                                  p_organization_id   => r_mtl_trx_info.from_organization,
                                                  p_location_id       => ln_from_loc_id,
                                                  p_tax_type          => main_rec.tax_type,
                                                  p_account_name      => 'RECOVERY'
                                                );
                  IF t_gl_entries(rec).credit_account IS NULL THEN
                      p_process_status := 'E';
                      p_process_message := 'Recovery Account not setup in receiving Org for ' || main_rec.tax_type ;
                      RETURN;
                  END IF;
                  IF t_gl_entries(rec).debit_account IS NULL THEN
                      p_process_status := 'E';
                      p_process_message := 'Expense Account not setup in receiving Org for ' || main_rec.tax_type ;
                      RETURN;
                  END IF;
                  t_gl_entries(rec).organization_id   := r_mtl_trx_info.from_organization;
                  t_gl_entries(rec).organization_code := l_from_org_cd;

                  rec := rec + 1;
                  -- ends here for vat reversal
              END IF;

        END IF;

      END LOOP;
              IF r_get_interorg_params.intransit_type = 1  and p_register_type is NULL THEN
                 do_costing(p_transaction_temp_id,
                          lv_process_flag,
                          lv_process_message);
              END IF;


      stmt_name := 'Calling gl_entry()';
      gl_entry(t_gl_entries,
               p_set_of_books_id,
               p_je_source_name,
               p_je_category_name,
               p_currency_code,
               p_transaction_temp_id,
               p_process_status,
               p_process_message);

EXCEPTION
  WHEN OTHERS THEN
    p_process_status  := 'E';
    p_process_message := 'Encountered an error when doing GL Entries '||stmt_name||' :'||sqlcode||': '||sqlerrm;
    ROLLBACK TO gl_acctg;
END;


procedure do_costing
(
transaction_id IN NUMBER,
process_flag OUT NOCOPY varchar2,
process_msg OUT NOCOPY varchar2
)
 is
CURSOR c_mtl_types(cp_transaction_type_name IN VARCHAR2) IS
SELECT transaction_type_id, transaction_source_type_id, transaction_action_id
FROM   mtl_transaction_types
WHERE  transaction_type_name = cp_transaction_type_name;

CURSOR c_costing_group ( cp_organization_id IN NUMBER) IS
SELECT mp.default_cost_group_id
FROM   mtl_parameters mp
WHERE  mp.organization_id = cp_organization_id
AND    mp.primary_cost_method = 2;       --Average

CURSOR c_rcv_params( cp_organization_id IN NUMBER) IS
SELECT * from rcv_parameters
WHERE  organization_id = cp_organization_id;

CURSOR c_mtl_params(cp_organization_id IN NUMBER) IS
SELECT *
FROM   mtl_parameters
WHERE  organization_id = cp_organization_id;

CURSOR c_jai_mtl_Trxs ( cp_Trx_temp_id IN NUMBER ) is
SELECT * from jai_mtl_Trxs
WHERE  transaction_Temp_id = cp_Trx_temp_id;


CURSOR c_proc_exists(cp_object_name    user_procedures.object_name%type ,
                      cp_procedure_name user_procedures.procedure_name%type) IS

SELECT 1
FROM  user_procedures
WHERE object_name    = cp_object_name
AND   procedure_name = cp_procedure_name ;

/*rchandan for bug#6487489..start*/

CURSOR c_ppv_acct(cp_from_organization_id NUMBER,cp_to_organization_id NUMBER)
IS
SELECT INTERORG_PRICE_VAR_ACCOUNT
  FROM mtl_interorg_parameters
 WHERE from_organization_id = cp_from_organization_id
   AND to_organization_id   = cp_to_organization_id ;

CURSOR cur_get_bonded(cp_organization_id NUMBER,
                      cp_sub_inventory   VARCHAR2)
IS
SELECT bonded
  FROM jai_inv_subinv_dtls
 WHERE organization_id    = cp_organization_id
   AND sub_inventory_name = cp_sub_inventory;

ln_cost_amount    NUMBER;
lv_bonded         jai_inv_subinv_dtls.bonded%TYPE;
ln_ppv_acct_id    NUMBER;/*6487489*/


/*rchandan for bug#6487489..end*/

p_trx_temp_id  NUMBER:= transaction_id ;--11015556;

ln_txn_header_id       NUMBER;
r_mtl_types            c_mtl_types%ROWTYPE;
r_Rcv_params           c_rcv_params%ROWTYPE;
r_mtl_params           c_mtl_params%Rowtype;
ln_costing_grp_id      NUMBER;
lv_trx_type_name       VARCHAR2(30);
r_mtl_Trxs             c_jai_mtl_Trxs%ROWTYPE;

ln_Excise_amt          NUMBER;
ln_non_modvat_amt      NUMBER;
ln_oth_modvat_amt      NUMBER;
lv_process_msg         VARCHAR2(2000);
lv_process_status      VARCHAR2(20);
lv_object_name    user_procedures.object_name%type ;
lv_procedure_name user_procedures.procedure_name%type ;
ln_exists         NUMBER := 0 ;
lv_sqlstmt        VARCHAR2(2000) ;
ln_retval         NUMBER;
lv_return_status  VARCHAR2(10);
ln_msg_cnt        NUMBER;
lv_msg_data      VARCHAR2(2000);
ln_trans_count    NUMBER;


cursor cur_item_class /*6501436*/
IS
SELECT jiis.item_class
	FROM jai_mtl_trxs jmt,
			 JAI_INV_ITM_SETUPS jiis
 WHERE jmt.inventory_item_id   = jiis.inventory_item_id
	 AND jmt.transaction_temp_id = p_trx_temp_id;

lv_item_class jai_inv_itm_setups.item_class%TYPE;/*6501436*/
BEGIN

lv_trx_type_name := 'Average cost update' ;--'Direct Org Transfer';

OPEN  c_jai_mtl_Trxs(p_trx_temp_id);
FETCH c_jai_mtl_Trxs INTO r_mtl_Trxs;
CLOSE c_jai_mtl_Trxs;

Open  c_mtl_types(lv_trx_type_name);
FETCH c_mtl_types INTO r_mtl_types;
CLOSE c_mtl_types;

OPEN  c_costing_group(r_mtl_Trxs.to_organization);
FETCH c_costing_group INTO ln_costing_grp_id;
CLOSE c_costing_group;

OPEN  c_rcv_params(r_mtl_Trxs.to_organization);
FETCH c_rcv_params INTO r_Rcv_params;
CLOSE c_rcv_params;

OPEN  c_mtl_params(r_mtl_Trxs.to_organization);
FETCH c_mtl_params INTO r_mtl_params;
CLOSE c_mtl_params;


/*
|| This procedure would get the cost amount
|| Need to pass the transaction_temp_id as the param for p_trx_temp_id
|| ln_non_modvat_amt variable would have the cost.
*/

 get_cost_amt
  (   p_source_line_id      => p_trx_temp_id    ,
      p_organization_id     => r_mtl_Trxs.to_organization,
      p_location_id         => r_mtl_Trxs.location_id,
      p_item_id             => r_mtl_Trxs.inventory_item_id,
      p_excise_amount       => ln_Excise_amt,
      p_non_modvat_amount   => ln_non_modvat_amt,
      p_other_modvat_amount => ln_oth_modvat_amt,
      p_process_message     => lv_process_msg,
      p_process_status      => lv_process_status  );

/*
|| avg costing if r_mtl_params.primary cost thod = 2
*/

If r_mtl_params.primary_cost_method=2 then
    avg_cost_entry( p_txn_header_id               => ln_txn_header_id ,
    p_item_id                     => r_mtl_Trxs.inventory_item_id,
    p_organization_id             => r_mtl_Trxs.to_organization,
    p_uom_code                    => r_mtl_Trxs.transaction_uom,
    p_transaction_date            => r_mtl_Trxs.transaction_Date,
    p_transaction_type_id         => r_mtl_types.transaction_type_id,
    p_transaction_source_type_id  => r_mtl_types.transaction_source_type_id ,
    p_transaction_id              => p_trx_temp_id ,
    p_cost_group_id               => ln_costing_grp_id ,
    p_receiving_account_id        => r_Rcv_params.receiving_account_id,
    p_absorption_account_id       => r_Rcv_params.receiving_account_id,
    p_value_change                => ln_non_modvat_amt,
    p_transaction_action_id       => r_mtl_types.transaction_action_id,
    p_from_organization_id        => r_mtl_trxs.from_organization,
    p_from_subinventory           => r_mtl_trxs.from_subinventory,
    p_to_subinventory             => r_mtl_trxs.to_subinventory,
    p_txn_quantity                => 0
    );

      lv_object_name    := 'INV_TXN_MANAGER_PUB' ;
      lv_procedure_name := 'PROCESS_TRANSACTIONS' ;

      OPEN c_proc_exists(lv_object_name, lv_procedure_name) ;
      FETCH c_proc_exists INTO ln_exists ;
      CLOSE c_proc_exists ;

         IF ln_exists = 1 THEN
              lv_sqlstmt := 'BEGIN
                              :ln_retval := inv_txn_manager_pub.process_transactions (
                                                    p_api_version         => 1,
                                                    p_init_msg_list       => :fnd_api_g_false ,
                                                    p_commit              => :fnd_api_g_false1 ,
                                                    p_validation_level    => :fnd_api_g_valid_level_full ,
                                                    x_return_status       => :lv_return_status,
                                                    x_msg_count           => :ln_msg_cnt,
                                                    x_msg_data            => :lv_msg_data,
                                                    x_trans_count         => :ln_trans_count,
                                                    p_table               => 1,
                                                    p_header_id           => :ln_txn_header_id
                                                 );
                            END; ';
              EXECUTE IMMEDIATE lv_sqlstmt USING OUT ln_retval                 ,
                                                 IN fnd_api.g_false            ,
                                                 IN fnd_api.g_false            ,
                                                 IN fnd_api.g_valid_level_full ,
                                                 OUT lv_return_status          ,
                                                 OUT ln_msg_cnt                ,
                                                 OUT lv_msg_data               ,
                                                 OUT ln_trans_count            ,
                                             IN  ln_txn_header_id ;


       END IF;


/*
|| std costing if r_mtl_params.primary cost thod = 1
*/

elsif r_mtl_params.primary_cost_method=1 then

OPEN cur_item_class;/*6501436*/
FETCH cur_item_class INTO lv_item_class;
CLOSE cur_item_class;

/*6487489 start*/

OPEN c_ppv_acct(r_mtl_Trxs.from_organization,r_mtl_Trxs.to_organization);
FETCH c_ppv_acct INTO ln_ppv_acct_id;
CLOSE c_ppv_acct;

OPEN cur_get_bonded(r_mtl_Trxs.to_organization,r_mtl_Trxs.to_subinventory);
FETCH cur_get_bonded INTO lv_bonded;
CLOSE cur_get_bonded;

IF lv_bonded = 'N' or lv_item_class IN ('FGIN','FGEX') THEN /*6501436..Included item check*/

  ln_cost_amount := nvl(ln_Excise_amt,0) + nvl(ln_non_modvat_amt,0)  ; /*it should include Excisable recoverable taxes and Non recoverable taxes*/

ELSE

  ln_cost_amount := nvl(ln_non_modvat_amt,0);

END IF;

/*6487489 end*/


IF ln_cost_amount <> 0 THEN /*6487489*/

	std_cost_entry(
	p_transaction_id             => p_trx_temp_id,
	p_reference_account          => ln_ppv_acct_id,/*6487489..replaced material account*/
	p_inventory_item_id          => r_mtl_Trxs.inventory_item_id,
	p_organization_id            => r_mtl_Trxs.to_organization,
	p_transaction_source_id      => p_trx_temp_id,
	p_transaction_source_type_id => r_mtl_types.transaction_source_type_id,
	p_primary_quantity           => r_mtl_Trxs.quantity,
	p_transaction_date           => r_mtl_Trxs.transaction_Date,
	p_cost_amount                => ln_cost_amount,
	p_process_flag               => lv_process_status ,
	p_process_msg                => lv_process_msg);

end if;

end if;


END do_costing;

PROCEDURE avg_cost_entry(
    p_txn_header_id               IN OUT NOCOPY NUMBER,
    p_item_id                     IN NUMBER,
    p_organization_id             IN NUMBER,
    p_uom_code                    IN VARCHAR2,
    p_transaction_date            IN DATE,
    p_transaction_type_id         IN NUMBER,
    p_transaction_source_type_id  IN NUMBER,
    p_transaction_id              IN NUMBER,
    p_cost_group_id               IN NUMBER,
    p_receiving_account_id        IN NUMBER,
    p_absorption_account_id       IN NUMBER,
    p_value_change                IN NUMBER,
    p_transaction_action_id       IN NUMBER,
    p_from_organization_id        IN NUMBER,
    p_from_subinventory           IN VARCHAR2,
    p_to_subinventory             IN VARCHAR2,
    p_txn_quantity               IN NUMBER
  ) IS

    ln_txn_interface_id         NUMBER;

    -- Default Values
    lv_transaction_source_name  VARCHAR2(30)  := 'Avg Cost Update Conversion';
    lv_source_code              VARCHAR2(50)  := 'IL-Value Change - Direct Org';
    ln_src_line_id              NUMBER        := -1;
    ln_src_header_id            NUMBER        := -1;
    ln_process_flag             NUMBER        := 1;
    ln_transaction_mode         NUMBER        := 3;
    ln_quantity                 NUMBER        := p_txn_quantity;
    ln_lock_flag                NUMBER        := 2;     -- No Lock
    ln_material_cost_element_id NUMBER        := 1;     -- Material
    ln_overhead_cost_element_id NUMBER        := 2;     -- Material
    ln_level_type               NUMBER        := 1;     -- This Level

  BEGIN

    INSERT INTO mtl_transactions_interface (
                                              source_code                                         ,
                                              source_line_id                                      ,
                                              source_header_id                                    ,
                                              process_flag                                        ,
                                              transaction_mode                                    ,
                                              transaction_interface_id                            ,
                                              transaction_header_id                               ,
                                              inventory_item_id                                   ,
                                              organization_id                                     ,
                                              revision                                            ,
                                              transaction_quantity                                ,
                                              transaction_uom                                     ,
                                              transaction_date                                    ,
                                              transaction_source_name                             ,
                                              transaction_type_id                                 ,
                                              transaction_source_type_Id                          ,
                                              rcv_transaction_id                                  ,
                                              transaction_reference                               ,-- mtl_transaction Id.
                                              last_update_date                                    ,
                                              last_updated_by                                     ,
                                              creation_date                                       ,
                                              created_by                                          ,
                                              cost_group_id                                       ,
                                              material_account                                    ,
                                              material_overhead_account                           ,--overhead absorption account
                                              resource_account                                    ,
                                              overhead_account                                    ,
                                              outside_processing_account                          ,
                                              lock_flag                                           ,
                                              transaction_action_id                               ,
                                              transfer_organization,
                                              transfer_subinventory ,
                                              subinventory_code ,
                                              value_change
                                          )
                                 VALUES (
                                              lv_source_code                                      ,
                                              ln_src_line_id                                      ,
                                              ln_src_header_id                                    ,
                                              ln_process_flag                                     ,
                                              ln_transaction_mode                                 ,
                                              mtl_material_transactions_s.nextval                 ,
                                              decode( p_txn_header_id, null                       ,
                                                      mtl_material_transactions_s.currval         ,
                                                      p_txn_header_id
                                                    )                                             ,
                                              p_item_id                                           ,
                                              p_organization_id                                   ,
                                              null                                                ,
                                              ln_quantity                                         ,      -- No Qty
                                              p_uom_code                                          ,
                                              p_transaction_date        ,
                                              lv_transaction_source_name                          ,
                                              p_transaction_type_id                               ,      -- Avg Cost Update
                                              p_transaction_source_type_id                        ,      -- Inventory
                                              p_transaction_id                                    ,
                                              to_char(p_transaction_id)                           ,
                                              sysdate                                             ,
                                              fnd_global.user_id                                  ,
                                              sysdate                                             ,
                                              fnd_global.user_id                                  ,
                                              p_cost_group_id                                     ,
                                              p_receiving_account_id                              ,
                                              p_absorption_account_id                             ,
                                              p_receiving_account_id                              ,
                                              p_receiving_account_id                              ,
                                              p_receiving_account_id                              ,
                                              ln_lock_flag                                        ,
                                              p_transaction_action_id                             ,
                                              p_from_organization_id   ,
                                              p_from_subinventory,
                                              p_to_subinventory ,
                                              p_value_change
                                          )
                                RETURNING transaction_interface_id                                ,
                                          transaction_header_id
                                INTO      ln_txn_interface_id                                     ,
                                          p_txn_header_id ;





      INSERT INTO JAI_MTL_TXN_CST_HDR_T (
                                                source_code                                         ,
                                                source_line_id                                      ,
                                                source_header_id                                    ,
                                                process_flag                                        ,
                                                transaction_mode                                    ,
                                                transaction_interface_id                            ,
                                                transaction_header_id                               ,
                                                inventory_item_id                                   ,
                                                organization_id                                     ,
                                                revision                                            ,
                                                transaction_quantity                                ,
                                                transaction_uom                                     ,
                                                transaction_date                                    ,
                                                transaction_source_name                             ,
                                                transaction_type_id                                 ,
                                                transaction_source_type_Id                          ,     --PVI
                                                rcv_transaction_id                                  ,
                                                transaction_reference                               ,     -- rcv_transaction Id.
                                                last_update_date                                    ,
                                                last_updated_by                                     ,
                                                creation_date                                       ,
                                                created_by                                          ,
                                                cost_group_id                                       ,
                                                material_account                                    ,
                                                material_overhead_account                           ,      --overhead absorption account
                                                resource_account                                    ,
                                                overhead_account                                    ,
                                                outside_processing_account                          ,
                                                lock_flag                                           ,
                                                transaction_id
                                              )


                             VALUES (
                                                lv_source_code                                      ,
                                                ln_src_line_id                                      ,
                                                ln_src_header_id                                    ,
                                                ln_process_flag                                     ,
                                                ln_transaction_mode                                 ,
                                                ln_txn_interface_id                                 ,
                                                p_txn_header_id                                     ,
                                                p_item_id                                           ,
                                                p_organization_id                                   ,
                                                null                                                ,
                                                ln_quantity                                         ,      -- No Qty
                                                p_uom_code                                          ,
                                                p_transaction_date        ,
                                                lv_transaction_source_name                          ,
                                                p_transaction_type_id                               ,      -- Avg Cost Update
                                                p_transaction_source_type_id                        ,      -- Inventory
                                                p_transaction_id                                    ,
                                                to_char(p_transaction_id)                           ,
                                                sysdate                                             ,
                                                fnd_global.user_id                                  ,
                                                sysdate                                             ,
                                                fnd_global.user_id                                  ,
                                                p_cost_group_id                                     ,
                                                p_receiving_account_id                              ,
                                                p_absorption_account_id                             ,
                                                p_receiving_account_id                              ,
                                                p_receiving_account_id                              ,
                                                p_receiving_account_id                              ,
                                                ln_lock_flag                                        ,
                                                ln_txn_interface_id
                                          ) ;


INSERT INTO mtl_txn_cost_det_interface (
                                              transaction_interface_id                       ,
                                              last_update_date                               ,
                                              last_updated_by                                ,
                                              creation_date                                  ,
                                              created_by                                     ,
                                              organization_id                                ,
                                              cost_element_id                                ,
                                              level_type                                     ,
                                              value_change
                                            )
                                     VALUES (
                                              ln_txn_interface_id                            ,
                                              sysdate                                        ,
                                              fnd_global.user_id                             ,
                                              sysdate                                        ,
                                              fnd_global.user_id                             ,
                                              p_organization_id                              ,
                                              ln_material_cost_element_id                    ,
                                              ln_level_type                                  ,
                                              p_value_change
                                            );

INSERT INTO JAI_MTL_TXN_CST_DTL_T(
                                              transaction_interface_id                       ,
                                              last_update_date                               ,
                                              last_updated_by                                ,
                                              creation_date                                  ,
                                              created_by                                     ,
                                              organization_id                                ,
                                              cost_element_id                                ,
                                              level_type                                     ,
                                              value_change
                                            )
                                     VALUES (
                                              ln_txn_interface_id                            ,
                                              sysdate                                        ,
                                              fnd_global.user_id                             ,
                                              sysdate                                        ,
                                              fnd_global.user_id                             ,
                                              p_organization_id                              ,
                                              ln_material_cost_element_id                    ,
                                              ln_level_type                                  ,
                                              p_value_change
                                            );




    INSERT INTO mtl_txn_cost_det_interface
       (
         transaction_interface_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         organization_id,
         cost_element_id,
         level_type,
         value_change
       )
       (SELECT
               ln_txn_interface_id   ,
               sysdate               ,
               fnd_global.user_id    ,
               sysdate               ,
               fnd_global.user_id    ,
               p_organization_id     ,
               clcd.cost_element_id  ,
               clcd.level_type       ,
               0
        FROM
               cst_layer_cost_details  clcd,
               cst_quantity_layers     cql
        WHERE
               cql.organization_id   = p_organization_id
        and    cql.inventory_item_id = p_item_id
        and    cql.cost_group_id     = p_cost_group_id
        and    clcd.layer_id         = cql.layer_id
        and   (clcd.cost_element_id,clcd.level_type) NOT IN
                                         ( SELECT
                                                   mctcd1.cost_element_id,
                                                   mctcd1.level_type
                                           FROM
                                                   mtl_txn_cost_det_interface mctcd1
                                           WHERE
                                                   mctcd1.transaction_interface_id = ln_txn_interface_id
                                         )
       );

    INSERT INTO JAI_MTL_TXN_CST_DTL_T
           (
             transaction_interface_id,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             organization_id,
             cost_element_id,
             level_type,
             value_change
           )
           (SELECT
                   ln_txn_interface_id   ,
                   sysdate               ,
                   fnd_global.user_id    ,
                   sysdate               ,
                   fnd_global.user_id    ,
                   p_organization_id     ,
                   clcd.cost_element_id  ,
                   clcd.level_type       ,
                   0
            FROM
                   cst_layer_cost_details  clcd,
                   cst_quantity_layers     cql
            WHERE
                   cql.organization_id   = p_organization_id
            and    cql.inventory_item_id = p_item_id
            and    cql.cost_group_id     = p_cost_group_id
            and    clcd.layer_id         = cql.layer_id
            and   (clcd.cost_element_id,clcd.level_type) NOT IN
                                             ( SELECT
                                                       mctcd1.cost_element_id,
                                                       mctcd1.level_type
                        FROM
                                                       jai_mtl_txn_cst_dtl_t mctcd1
                                               WHERE
                                                       mctcd1.transaction_interface_id = ln_txn_interface_id
                                             )
       );

  end avg_cost_entry;

PROCEDURE std_cost_entry(
p_transaction_id             IN  NUMBER,
p_reference_account          IN  NUMBER,
p_inventory_item_id          IN  NUMBER,
p_organization_id            IN  NUMBER,
p_transaction_source_id      IN  NUMBER,
p_transaction_source_type_id IN  NUMBER,
p_primary_quantity           IN  NUMBER,
p_transaction_date           IN  DATE,
p_cost_amount                IN  NUMBER,
p_process_flag OUT NOCOPY VARCHAR2,
p_process_msg OUT NOCOPY VARCHAR2
)
is
lv_organization_code       org_organization_definitions.organization_code%type;
ln_set_of_books_id         org_organization_definitions.set_of_books_id%type;

l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
lv_status   gl_interface.status%type;
lv_reference_entry       gl_interface.reference22%type;
lv_reference_10         gl_interface.reference10%TYPE;
lv_reference_23         gl_interface.reference23%TYPE;
lv_reference_24         gl_interface.reference24%TYPE;
lv_reference_25         gl_interface.reference25%TYPE;
lv_reference_26         gl_interface.reference26%TYPE;
lv_source_name          gl_interface.user_je_source_name%TYPE;
lv_category_name        gl_interface.user_je_category_name%TYPE;
lv_currency_code       gl_interface.currency_code%TYPE;

cursor cur_rcv_accnt(cp_organization_id NUMBER) /*6487489..added the cursor*/
IS
select receiving_account_id
  from rcv_parameters
 Where organization_id = cp_organization_id;

ln_receiving_accnt_id  NUMBER;


BEGIN
l_func_curr_det       := jai_plsql_cache_pkg.return_sob_curr
                              (p_org_id  =>  p_organization_id);
lv_organization_code  := l_func_curr_det.organization_code;
ln_set_of_books_id    := l_func_curr_det.ledger_id;
lv_source_name := 'Purchasing India';
lv_category_name:='MMT';/*6504150*/
lv_reference_10 :='India Local Standard Cost Entry For INTERORG_XFER  and Organization_code= '|| lv_organization_code ;
lv_reference_entry  := 'India Localization Entry';
lv_reference_23:='jai_mtl_trxs_pkg.std_cost_entry';
lv_reference_24:='jai_mtl_trxs';
lv_reference_26:='transaction_id';
lv_currency_code :='INR';

OPEN  cur_rcv_accnt(p_organization_id);
FETCH cur_rcv_accnt INTO ln_receiving_accnt_id;
CLOSE cur_rcv_accnt;

 p_process_flag := 'SUCCESS';

 lv_status := 'NEW' ;


 /*The following code is all added/modified for rchandan for bug#6487489 to generate PPV accounting*/
     insert into gl_interface
     (
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       accounting_date,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       entered_cr,
       entered_dr,
       transaction_date,
       code_combination_id,
       currency_conversion_date,
       user_currency_conversion_type,
       currency_conversion_rate,
       reference1,
       reference10,
       reference22,
       reference23,
       reference24,
       reference25,
       reference26,
       reference27
     )
     VALUES
     (
       lv_status , --'NEW',
       ln_set_of_books_id,
       lv_source_name,
       lv_category_name,
       trunc(sysdate),
       lv_currency_code,
       sysdate,
       fnd_global.user_id,
       'A',
       p_cost_amount,
       NULL,
       sysdate,
       ln_receiving_accnt_id,/*Inventory receiving Account*/
       NULL,
       NULL,
       NULL,
       lv_organization_code,
       lv_reference_10,
       lv_reference_entry,
       lv_reference_23,
       lv_reference_24,
       p_transaction_id,
       lv_reference_26,
       to_char(p_organization_id)
     );

    insert into jai_mtl_trx_jrnls
            (journal_entry_id,
            status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
              creation_Date,
              last_updated_by,
              last_update_date,
              last_update_login,
              transaction_temp_id

           )
            VALUES
            (jai_mtl_trx_jrnls_s.nextval,
            lv_status,
             ln_set_of_books_id,
             lv_source_name,
             lv_category_name,
             sysdate,
             lv_currency_code,
             sysdate,
             fnd_global.user_id,
             p_cost_amount,
             NULL,
             sysdate,
             ln_receiving_accnt_id,
             null,
             null,
             null,
             lv_organization_code,
						 lv_reference_10,
						 lv_reference_23,
						 lv_reference_24,
						 p_transaction_id,
						 lv_reference_26,
             to_char(p_organization_id),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             p_transaction_id
	    );


/*removed the insert to MTA by vkaranam for bug #6030615 as part of SLA uptake*/


 insert into gl_interface
     (
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       accounting_date,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       entered_cr,
       entered_dr,
       transaction_date,
       code_combination_id,
       currency_conversion_date,
       user_currency_conversion_type,
       currency_conversion_rate,
       reference1,
       reference10,
       reference22,
       reference23,
       reference24,
       reference25,
       reference26,
       reference27
     )
     VALUES
     (
       lv_status , --'NEW',
       ln_set_of_books_id,
       lv_source_name,
       lv_category_name,
       trunc(sysdate),
       lv_currency_code,
       sysdate,
       fnd_global.user_id,
       'A',
       NULL,
       p_cost_amount,
       sysdate,
       p_reference_account,/*PPV Account*/
       NULL,
       NULL,
       NULL,
       lv_organization_code,
       lv_reference_10,
       lv_reference_entry,
       lv_reference_23,
       lv_reference_24,
       p_transaction_id,
       lv_reference_26,
       to_char(p_organization_id)
     );

insert into jai_mtl_trx_jrnls
            (journal_entry_id,
            status,
              set_of_books_id,
              user_je_source_name,
              user_je_category_name,
              accounting_date,
              currency_code,
              date_created,
              created_by,
              entered_cr,
              entered_dr,
              transaction_date,
              code_combination_id,
              currency_conversion_date,
              user_currency_conversion_type,
              currency_conversion_rate,
              reference1,
              reference10,
              reference23,
              reference24,
              reference25,
              reference26,
              reference27,
              creation_Date,
              last_updated_by,
              last_update_date,
              last_update_login,
              transaction_temp_id

           )
            VALUES
            (jai_mtl_trx_jrnls_s.nextval,
            lv_status,
             ln_set_of_books_id,
             lv_source_name,
             lv_category_name,
             sysdate,
             lv_currency_code,
             sysdate,
             fnd_global.user_id,
             NULL,
             p_cost_amount,
             sysdate,
             p_reference_account,
             null,
             null,
             null,
             lv_organization_code,
						 lv_reference_10,
						 lv_reference_23,
						 lv_reference_24,
						 p_transaction_id,
						 lv_reference_26,
             to_char(p_organization_id),
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id,
             p_transaction_id
	    );


exception
WHEN OTHERS THEN
 p_process_flag := 'ERROR';
 p_process_msg  := SQLERRM;
end std_cost_entry;


procedure cenvat_auto_claim
(p_transaction_Temp_id IN NUMBER ,
 p_shipment_line_id    IN NUMBER ,
 p_applied_quantity    IN NUMBER
) IS
    CURSOR c_rcpt_dtls(cp_shipment_line_id IN NUMBER) Is
    SELECT * from jai_rcv_lines
    WHERE  shipment_line_id = cp_shipment_line_id;

    CURSOR c_recpt_tax_dtls(cp_shipment_line_id IN NUMBER) IS
    SELECT * from JAI_RCV_LINE_TAXES
    WHERE  shipment_line_id = cp_shipment_line_id;

    CURSOR c_trx (cp_transaction_id IN NUMBER) IS
    SELECT * from JAI_RCV_TRANSACTIONS
    WHERE  transaction_id = cp_transaction_id ;

    CURSOR c_base_trx (cp_transaction_id IN NUMBER) IS
    SELECT vendor_id , vendor_site_id , transaction_id , shipment_line_id  from rcv_transactions
    WHERE transaction_id = cp_transaction_id;

    CURSOR c_mtl_params(cp_organization_id IN NUMBER) IS
    SELECT * from mtl_parameters
    WHERE  organization_id = cp_organization_id;

    CURSOR c_cenvat_accts (cp_organization_id IN NUMBER , cp_location_id IN NUMBER) IS
    select  *
    FROM   JAI_CMN_INVENTORY_ORGS
    WHERE  organization_id = cp_organization_id
    AND    location_id     = cp_location_id ;

    CURSOR c_gl_periods(cp_set_of_books_id IN NUMBER) IS
    SELECT period_name
    FROM   gl_period_statuses
    where set_of_books_id = cp_set_of_books_id
    and sysdate between start_Date and end_Date
    and application_id = 101;


    lv_period_name        gl_period_statuses.period_name%type;
    ln_shipment_line_id   NUMBER;
    ln_register_id        NUMBER;
    lv_process_status     VARCHAR2(20);
    lv_process_message    VARCHAR2(2000);
    ln_Excise_amt         NUMBER;
    ln_addl_excise_amt    NUMBER;
    ln_oth_excise_amt     NUMBER;
    ln_excise_cess_amt    NUMBER;
    ln_cvd_cess_amt       NUMBER;
    ln_Cess_amt           NUMBER;
    ln_add_cvd_amt        NUMBER;
    ln_addl_cvd_amt       NUMBER;
    r_base_trx            c_base_trx%rowtype;
    r_trx                 c_trx%rowtype;
    ln_Factor             NUMBER := 0.5;
    ln_applied_qty        NUMBER;
    r_rcpt_Dtls           c_rcpt_dtls%ROWTYPE;
    lv_reference_num      VARCHAR2(100);
    r_mtl_params          c_mtl_params%ROWTYPE;
    r_cenvat_accts        c_cenvat_accts%ROWTYPE;
    ln_tot_cenvat_amt     NUMBER;
    ln_set_of_books_id    NUMBER;

    lv_reference_10       VARCHAR2(240);
    ln_created_by         NUMBER := fnd_global.user_id;


BEGIN


    ln_shipment_line_id := p_shipment_line_id;
    ln_applied_qty      := p_applied_quantity;

    fnd_profile.get('GL_SET_OF_BKS_ID',ln_set_of_books_id);

    OPEN  c_rcpt_dtls(ln_shipment_line_id);
    FETCH c_rcpt_dtls INTO r_rcpt_Dtls;
    CLOSE c_rcpt_dtls;

    OPEN   c_trx(r_rcpt_Dtls.transaction_id);
    FETCH  c_trx INTO r_Trx;
    CLOSE  c_trx;

    OPEN   c_base_trx(r_rcpt_Dtls.transaction_id);
    FETCH  c_base_Trx INTO r_base_trx;
    CLOSE  c_base_trx;

    OPEN   c_mtl_params(r_Trx.organization_id);
    FETCH  c_mtl_params INTO r_mtl_params;
    CLOSE  c_mtl_params;

    OPEN  c_cenvat_accts(r_trx.organization_id , r_trx.location_id);
    FETCH c_cenvat_accts INTO r_cenvat_accts;
    CLOSE c_cenvat_accts;

    OPEN  c_gl_periods(ln_set_of_books_id);
    FETCH c_gl_periods INTO lv_period_name;
    CLOSE c_gl_periods;

    ln_factor := ln_factor * ( ln_applied_qty/ r_Trx.quantity);


    FOR r_rcpt_Tax_dtls IN c_recpt_tax_dtls(ln_shipment_line_id)
    LOOP

       IF NVL(r_rcpt_Tax_dtls.modvat_flag,'N') = 'Y' THEN

         if UPPER(r_rcpt_Tax_dtls.tax_type) = 'EXCISE'  THEN
            ln_Excise_amt := NVL(ln_Excise_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         ELSIF UPPER(r_rcpt_Tax_dtls.tax_type) IN ('ADDL. EXCISE' ,'CVD') THEN
            ln_addl_excise_amt := NVL(ln_addl_excise_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         ELSIF UPPER(r_rcpt_Tax_dtls.tax_type) IN ('ADDITIONAL_CVD') THEN
            ln_addl_cvd_amt := NVL(ln_addl_cvd_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         ELSIF UPPER(r_rcpt_Tax_dtls.tax_type) = 'OTHER EXCISE' THEN
            ln_oth_excise_amt  := NVL(ln_oth_excise_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         ELSIF UPPER(r_rcpt_Tax_dtls.tax_type) = 'EXCISE_EDUCATION_CESS' THEN
            ln_excise_cess_amt := NVL(ln_excise_cess_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         ELSIF UPPER(r_rcpt_Tax_dtls.tax_type) = 'CVD_EDUCATION_CESS' THEN
            ln_cvd_cess_amt := NVL(ln_cvd_cess_amt,0) + NVL(r_rcpt_Tax_dtls.tax_amount,0);
         END IF;

       END IF;

    END LOOP;

    ln_tot_cenvat_amt := NVL(ln_Excise_amt,0) + NVL(ln_addl_excise_amt,0) + NVL(ln_oth_excise_amt,0) ;

    ln_Cess_amt := NVL(ln_cvd_cess_amt,0) + NVL(ln_excise_cess_amt,0);


    lv_reference_num := r_Trx.receipt_num || p_transaction_Temp_id;

    ln_Excise_amt      := ln_Excise_amt * ln_factor;
    ln_addl_excise_amt := ln_addl_excise_amt * ln_factor;
    ln_add_cvd_amt     := ln_add_cvd_amt  * ln_factor;
    ln_oth_excise_amt  := ln_oth_excise_amt * ln_factor;
    ln_Cess_amt        := ln_Cess_amt * ln_factor;

    ln_tot_cenvat_amt := NVL(ln_Excise_amt,0) + NVL(ln_addl_excise_amt,0) + NVL(ln_oth_excise_amt,0) ;

    --ln_Cess_amt := NVL(ln_cvd_cess_amt,0) + NVL(ln_excise_cess_amt,0);


    jai_cmn_rg_23ac_ii_pkg.insert_row
    (
    P_REGISTER_ID             => ln_register_id ,
    P_INVENTORY_ITEM_ID       => r_trx.inventory_item_id,
    P_ORGANIZATION_ID         => r_trx.organization_id,
    P_RECEIPT_ID              => r_Trx.transaction_id,
    P_RECEIPT_DATE            => r_Trx.transaction_date,
    P_CR_BASIC_ED             => ln_Excise_amt,
    P_CR_ADDITIONAL_ED        => ln_addl_excise_amt,
    P_CR_ADDITIONAL_CVD       => ln_add_cvd_amt,
    P_CR_OTHER_ED             => ln_oth_excise_amt,
    P_DR_BASIC_ED             => Null,
    P_DR_ADDITIONAL_ED        => null,
    P_DR_ADDITIONAL_CVD       => null,
    P_DR_OTHER_ED             => null,
    P_EXCISE_INVOICE_NO       => r_Trx.excise_invoice_no,
    P_EXCISE_INVOICE_DATE     => r_trx.excise_invoice_date,
    P_REGISTER_TYPE           => 'C',
    P_REMARKS                 => 'AutoClaim of remaining 50% for CG in interorg XFER',
    P_VENDOR_ID               => r_base_Trx.vendor_id,
    P_VENDOR_SITE_ID          => r_base_trx.vendor_site_id,
    P_CUSTOMER_ID             => null,
    P_CUSTOMER_SITE_ID        => null,
    P_LOCATION_ID             => r_trx.location_id,
    P_TRANSACTION_DATE        => trunc(sysdate),
    P_CHARGE_ACCOUNT_ID       => null,
    P_REGISTER_ID_PART_I      => null,
    P_REFERENCE_NUM           => lv_reference_num ,
    P_ROUNDING_ID             => null,
    P_OTHER_TAX_CREDIT        => ln_Cess_amt,
    P_OTHER_TAX_DEBIT         => null,
    P_TRANSACTION_TYPE        => 'R',
    P_TRANSACTION_SOURCE      => 'INTERORG_XFER',
    P_CALLED_FROM             => 'INTERORG_XFER',
    P_SIMULATE_FLAG           => 'N',
    P_PROCESS_STATUS          => lv_process_status,
    P_PROCESS_MESSAGE         => lv_process_message
    );

  lv_Reference_10 := 'India Local Receiving Entry for the Receipt Number' || r_trx.receipt_num || 'for the Trx Type RECEIVE for the Organization code' || r_mtl_params.organization_code ;

  insert into JAI_RCV_JOURNAL_ENTRIES
  (
  JOURNAL_ENTRY_ID,
  ORGANIZATION_CODE,
  RECEIPT_NUM,
  TRANSACTION_ID        ,
  CREATION_DATE         ,
  TRANSACTION_DATE      ,
  SHIPMENT_LINE_ID      ,
  ACCT_TYPE             ,
  ACCT_NATURE           ,
  SOURCE_NAME           ,
  CATEGORY_NAME         ,
  CODE_COMBINATION_ID   ,
  ENTERED_DR            ,
  ENTERED_CR            ,
  TRANSACTION_TYPE      ,
  PERIOD_NAME           ,
  CREATED_BY            ,
  CURRENCY_CODE         ,
  CURRENCY_CONVERSION_TYPE,
  CURRENCY_CONVERSION_DATE,
  CURRENCY_CONVERSION_RATE,
  REFERENCE_ID            ,
  REFERENCE_NAME          ,
  last_update_date        ,/*6497301*/
  last_updated_by         ,/*6497301*/
  last_update_login      /*6497301*/

  )
  VALUES
  (jai_rcv_journal_entries_s.nextval,/*6497301*/
   r_mtl_params.organization_code ,
   r_trx.receipt_num ,
   r_trx.transaction_id ,
   sysdate ,
   sysdate ,
   r_Trx.shipment_line_id,
   'REGULAR',
   'CENVAT-AUTOCLAIM-INTERORG-XFER',
   'Purchasing',
   'Receiving India',
    r_cenvat_accts.excise_rcvble_account,
    ln_tot_cenvat_amt,
    Null,
    'Receive',
    lv_period_name,
    ln_created_by,
    'INR',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    sysdate, /*6497301*/
    fnd_global.user_id,/*6497301*/
    fnd_global.login_id/*6497301*/
    );

    INSERT INTO GL_INTERFACE
    (
    status,
    set_of_books_id,
    user_je_source_name,
    user_je_category_name,
    accounting_date,
    currency_code,
    date_created,
    created_by,
    actual_flag,
    entered_cr,
    entered_dr,
    transaction_date,
    code_combination_id,
    currency_conversion_date,
    user_currency_conversion_type,
    currency_conversion_rate,
    reference1,
    reference10,
    reference22 ,
    reference23,
    reference24,
    reference25,
    reference26,
    reference27
    )
    VALUES
    (
     'NEW',
     ln_set_of_books_id,
     'Purchasing',
     'Receiving India',
     trunc(sysdate),
     'INR',
     sysdate,
     ln_created_by,
     'A',
     ln_tot_cenvat_amt,
     NULL,
     sysdate,
     r_cenvat_accts.excise_rcvble_account,
     Null,
     NULL,
     NULL,
     r_mtl_params.organization_code,
     lv_reference_10,
     'India Localization Entry',
     'jai_mtl_trxs_pkg.auto_claim',
     'rcv_transactions',
     'rcv_Transaction_id',
     r_Trx.transaction_id,
     r_trx.organization_id
    );


    INSERT INTO JAI_RCV_JOURNAL_ENTRIES
    (
    JOURNAL_ENTRY_ID       ,
    ORGANIZATION_CODE      ,
    RECEIPT_NUM            ,
    TRANSACTION_ID         ,
    CREATION_DATE          ,
    TRANSACTION_DATE       ,
    SHIPMENT_LINE_ID       ,
    ACCT_TYPE              ,
    ACCT_NATURE            ,
    SOURCE_NAME            ,
    CATEGORY_NAME          ,
    CODE_COMBINATION_ID    ,
    ENTERED_DR             ,
    ENTERED_CR             ,
    TRANSACTION_TYPE       ,
    PERIOD_NAME            ,
    CREATED_BY             ,
    CURRENCY_CODE          ,
    CURRENCY_CONVERSION_TYPE,
    CURRENCY_CONVERSION_DATE,
    CURRENCY_CONVERSION_RATE,
    REFERENCE_ID            ,
    REFERENCE_NAME          ,
    last_update_date        ,/*6497301*/
		last_updated_by         ,/*6497301*/
    last_update_login      /*6497301*/
    )
    VALUES
    (jai_rcv_journal_entries_s.nextval,
    r_mtl_params.organization_code ,
    r_trx.receipt_num ,
    r_trx.transaction_id ,
    sysdate ,
    sysdate ,
    r_Trx.shipment_line_id,
    'REGULAR',
    'CENVAT-AUTOCLAIM-INTERORG-XFER',
    'Purchasing',
    'Receiving India',
    r_cenvat_accts.modvat_cg_account_id   ,
    NULL,
    ln_tot_cenvat_amt,
    'Receive',
    lv_period_name,
    ln_created_by,
    'INR',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    sysdate, /*6497301*/
		fnd_global.user_id,/*6497301*/
    fnd_global.login_id/*6497301*/
    );

    INSERT INTO GL_INTERFACE
      (
      status,
      set_of_books_id,
      user_je_source_name,
      user_je_category_name,
      accounting_date,
      currency_code,
      date_created,
      created_by,
      actual_flag,
      entered_cr,
      entered_dr,
      transaction_date,
      code_combination_id,
      currency_conversion_date,
      user_currency_conversion_type,
      currency_conversion_rate,
      reference1,
      reference10,
      reference22 ,
      reference23,
      reference24,
      reference25,
      reference26,
      reference27
      )
      VALUES
      (
       'NEW',
       ln_set_of_books_id,
       'Purchasing',
       'Receiving India',
       trunc(sysdate),
       'INR',
       sysdate,
       ln_created_by,
       'A',
       NULL,
       ln_tot_cenvat_amt,
       sysdate,
       r_cenvat_accts.modvat_cg_account_id,
       Null,
       NULL,
       NULL,
       r_mtl_params.organization_code,
       lv_reference_10,
       'India Localization Entry',
       'jai_mtl_trxs_pkg.auto_claim',
       'rcv_transactions',
       'rcv_Transaction_id',
       r_Trx.transaction_id,
       r_trx.organization_id
    );



  IF ln_cvd_cess_amt IS NOT NULL THEN

    jai_cmn_rg_others_pkg.insert_row
    (
    P_SOURCE_TYPE          => 1,
    P_SOURCE_NAME          => 'RG23C_P2',
    P_SOURCE_ID            => ln_register_id,
    P_TAX_TYPE             => 'CVD_EDUCATION_CESS',
    DEBIT_AMT              => null,
    CREDIT_AMT             => ln_cvd_cess_amt * ln_factor,
    P_PROCESS_FLAG         => lv_process_status,
    P_PROCESS_MSG          => lv_process_message
    );

  END IF;

  IF ln_excise_cess_amt IS NOT NULL THEN
      jai_cmn_rg_others_pkg.insert_row
      (
      P_SOURCE_TYPE          => 1,
      P_SOURCE_NAME          => 'RG23C_P2',
      P_SOURCE_ID            => ln_register_id,
      P_TAX_TYPE             => 'EXCISE_EDUCATION_CESS',
      DEBIT_AMT              => null,
      CREDIT_AMT             => ln_excise_cess_amt * ln_factor,
      P_PROCESS_FLAG         => lv_process_status,
      P_PROCESS_MSG          => lv_process_message
      );
  END IF;

  IF ln_Cess_amt IS NOT NULL THEN

      INSERT INTO JAI_RCV_JOURNAL_ENTRIES
      (
      JOURNAL_ENTRY_ID,
      ORGANIZATION_CODE            ,
      RECEIPT_NUM                 ,
      TRANSACTION_ID              ,
      CREATION_DATE               ,
      TRANSACTION_DATE            ,
      SHIPMENT_LINE_ID            ,
      ACCT_TYPE                   ,
      ACCT_NATURE                 ,
      SOURCE_NAME                 ,
      CATEGORY_NAME               ,
      CODE_COMBINATION_ID         ,
      ENTERED_DR                  ,
      ENTERED_CR                  ,
      TRANSACTION_TYPE            ,
      PERIOD_NAME                 ,
      CREATED_BY                  ,
      CURRENCY_CODE               ,
      CURRENCY_CONVERSION_TYPE    ,
      CURRENCY_CONVERSION_DATE    ,
      CURRENCY_CONVERSION_RATE    ,
      REFERENCE_ID                ,
      REFERENCE_NAME          ,
			last_update_date        ,/*6497301*/
			last_updated_by         ,/*6497301*/
			last_update_login      /*6497301*/
      )
      VALUES
      (jai_rcv_journal_entries_s.nextval,/*6497301*/
      r_mtl_params.organization_code ,
       r_trx.receipt_num ,
       r_trx.transaction_id ,
       sysdate ,
       sysdate ,
       r_Trx.shipment_line_id,
       'REGULAR',
       'CENVAT-AUTOCLAIM-INTERORG-XFER',
       'Purchasing',
       'Receiving India',
       r_cenvat_accts.excise_edu_cess_rcvble_accnt,
       ln_Cess_amt,
       Null,
       'Receive',
       lv_period_name,
       ln_created_by,
       'INR',
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       sysdate, /*6497301*/
			 fnd_global.user_id,/*6497301*/
       fnd_global.login_id/*6497301*/
      );

      INSERT INTO GL_INTERFACE
      (
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       accounting_date,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       entered_cr,
       entered_dr,
       transaction_date,
       code_combination_id,
       currency_conversion_date,
       user_currency_conversion_type,
       currency_conversion_rate,
       reference1,
       reference10,
       reference22 ,
       reference23,
       reference24,
       reference25,
       reference26,
       reference27
      )
      VALUES
      (
       'NEW',
       ln_set_of_books_id,
       'Purchasing',
       'Receiving India',
       trunc(sysdate),
       'INR',
        sysdate,
        ln_created_by,
        'A',
        NULL,
        ln_cess_amt,
        sysdate,
        r_cenvat_accts.excise_edu_cess_rcvble_accnt,
        Null,
        NULL,
        NULL,
        r_mtl_params.organization_code,
        lv_reference_10,
        'India Localization Entry',
        'jai_mtl_trxs_pkg.auto_claim',
        'rcv_transactions',
        'rcv_Transaction_id',
        r_Trx.transaction_id,
        r_trx.organization_id
       );


       INSERT INTO JAI_RCV_JOURNAL_ENTRIES
       (
        JOURNAL_ENTRY_ID,
        ORGANIZATION_CODE         ,
        RECEIPT_NUM               ,
        TRANSACTION_ID            ,
        CREATION_DATE             ,
        TRANSACTION_DATE          ,
        SHIPMENT_LINE_ID          ,
        ACCT_TYPE                 ,
        ACCT_NATURE               ,
        SOURCE_NAME               ,
        CATEGORY_NAME             ,
        CODE_COMBINATION_ID       ,
        ENTERED_DR                ,
        ENTERED_CR                ,
        TRANSACTION_TYPE          ,
        PERIOD_NAME               ,
        CREATED_BY                ,
        CURRENCY_CODE             ,
        CURRENCY_CONVERSION_TYPE  ,
        CURRENCY_CONVERSION_DATE  ,
        CURRENCY_CONVERSION_RATE  ,
        REFERENCE_ID              ,
        REFERENCE_NAME          ,
				last_update_date        ,/*6497301*/
				last_updated_by         ,/*6497301*/
				last_update_login      /*6497301*/
       )
        VALUES
       (
        jai_rcv_journal_entries_s.nextval,/*6497301*/
        r_mtl_params.organization_code ,
        r_trx.receipt_num,
        r_trx.transaction_id ,
        sysdate ,
        sysdate ,
        r_Trx.shipment_line_id,
        'REGULAR',
        'CENVAT-AUTOCLAIM-INTERORG-XFER',
        'Purchasing',
        'Receiving India',
        r_cenvat_accts.excise_edu_cess_cg_account,
        NULL,
        ln_Cess_amt,
        'Receive',
        lv_period_name,
        ln_created_by,
        'INR',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate, /*6497301*/
				fnd_global.user_id,/*6497301*/
        fnd_global.login_id/*6497301*/
       );

       INSERT INTO GL_INTERFACE
      (
       status,
       set_of_books_id,
       user_je_source_name,
       user_je_category_name,
       accounting_date,
       currency_code,
       date_created,
       created_by,
       actual_flag,
       entered_cr,
       entered_dr,
       transaction_date,
       code_combination_id,
       currency_conversion_date,
       user_currency_conversion_type,
       currency_conversion_rate,
       reference1,
       reference10,
       reference22 ,
       reference23,
       reference24,
       reference25,
       reference26,
       reference27
      )
       VALUES
      (
       'NEW',
       ln_set_of_books_id,
       'Purchasing',
       'Receiving India',
       trunc(sysdate),
       'INR',
       sysdate,
       ln_created_by,
       'A',
       NULL,
       ln_cess_amt,
       sysdate,
       r_cenvat_accts.excise_edu_cess_cg_account,
       Null,
       NULL,
       NULL,
       r_mtl_params.organization_code,
       lv_reference_10,
       'India Localization Entry',
       'jai_mtl_trxs_pkg.auto_claim',
       'rcv_transactions',
       'rcv_Transaction_id',
       r_Trx.transaction_id,
       r_trx.organization_id
      );
  END IF;
END;
PROCEDURE CGVAT_REPOSIT_ENTRY(p_organization_id         IN NUMBER,
                              p_location_id             IN NUMBER,
                              p_Set_of_books_id       IN number,
                              p_currency in varchar2,
                              p_transaction_header_id   IN NUMBER,
                              p_transaction_temp_id     IN NUMBER,
                              p_transaction_id          IN NUMBER,
                              p_vat_invoice_no          IN VARCHAR2,
                              p_tax_type in varchar2,
                              p_amount in number,
                              p_claim_schedule_id in number,
                              p_process_status  OUT NOCOPY VARCHAR2,
                              p_process_message OUT NOCOPY VARCHAR2)
IS
 ln_regime_id                    NUMBER;
 lv_inv_gen_process_flag         VARCHAR2(10);
 lv_inv_gen_process_message      VARCHAR2(2000);
 ln_repository_id                NUMBER;
 lv_source_trx_type              VARCHAR2(30):='RECEIVING';
 table_rcv_transactions          VARCHAR2(30):= 'JAI_MTL_TRXS';
 lv_account_name                 VARCHAR2(50);
 ln_code_combination_id          NUMBER;
 ln_interim_recovery_account     NUMBER;
 ln_entered_dr                   NUMBER;
 ln_entered_cr                   NUMBER;
 lv_process_status              VARCHAR2(2);
 lv_process_message             VARCHAR2(1000);
  CURSOR c_regime_cur IS
    SELECT regime_id
    FROM   jai_rgm_definitions
    WHERE  regime_code = 'VAT';
stmt_name VARCHAR2(64);
BEGIN
OPEN  c_regime_cur;
FETCH c_regime_cur into ln_regime_id;
CLOSE c_regime_cur;
       lv_account_name := jai_constants.recovery;
       stmt_name:='Getting the interim recovery amount';
       ln_interim_recovery_account :=
                                      jai_cmn_rgm_recording_pkg.get_account(
                                         p_regime_id         => ln_regime_id,
                                         p_organization_type => jai_constants.orgn_type_io,
                                         p_organization_id   => p_organization_id,
                                         p_location_id       => p_location_id,
                                         p_tax_type          => p_tax_type,
                                         p_account_name      => jai_constants.recovery_interim);
      IF ln_interim_recovery_account IS NULL THEN
           p_process_status := jai_constants.expected_error;
           p_process_message := 'Interim recovery Account not defined in VAT Setup';
           RETURN;
      END IF;
      stmt_name:='Getting the code combination id';
      ln_code_combination_id :=
                                   jai_cmn_rgm_recording_pkg.get_account(
                                     p_regime_id         => ln_regime_id,
                                     p_organization_type => jai_constants.orgn_type_io,
                                     p_organization_id   => p_organization_id,
                                     p_location_id       => p_location_id,
                                     p_tax_type          => p_tax_type,
                                     p_account_name      => jai_constants.recovery);
         IF ln_code_combination_id IS NULL THEN
           p_process_status := jai_constants.expected_error;
           p_process_message := 'Recovery Account not defined in VAT Setup';
           RETURN;
         END IF;
ln_entered_cr:=p_amount;
      stmt_name:='Calling insert vat repository entry';
   jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                    pn_repository_id        => ln_repository_id,
                                    pn_regime_id            => ln_regime_id,
                                    pv_tax_type             => p_tax_type,
                                    pv_organization_type    => jai_constants.orgn_type_io,
                                    pn_organization_id      => p_organization_id,
                                    pn_location_id          => p_location_id,
                                    pv_source               => jai_constants.source_rcv,
                                    pv_source_trx_type      => lv_source_trx_type,
                                    pv_source_table_name    => table_rcv_transactions,
                                    pn_source_id            => p_transaction_id,
                                    pd_transaction_date     => trunc(sysdate),
                                    pv_account_name         => lv_account_name,
                                    pn_charge_account_id    => ln_code_combination_id,
                                    pn_balancing_account_id => ln_interim_recovery_account,
                                    pn_credit_amount        =>ln_entered_cr  ,
                                    pn_debit_amount         =>ln_entered_dr  ,
                                    pn_assessable_value     => NULL,
                                    pn_tax_rate             => NULL,
                                    pn_reference_id         => p_claim_schedule_id,/*r_claim_schedule.claim_schedule_id,*/
                                    pn_batch_id             => NULL,
                                    pn_inv_organization_id  => P_organization_id,
                                    pv_invoice_no           => p_vat_invoice_no,
                                    pd_invoice_date         => trunc(sysdate),
                                    pv_called_from          => 'JAINVMTX',
                                    pv_process_flag         => lv_process_status,
                                    pv_process_message      => lv_process_message,
                                    --Added by Bo Li for bug9305067 2010-4-14 BEGIN
                                    --------------------------------------------------
                                    pv_trx_reference_context    => NULL,
                                	  pv_trx_reference1           => NULL,
                                	  pv_trx_reference2           => NULL,
                                    pv_trx_reference3           => NULL,
                                    pv_trx_reference4           => NULL,
                                    pv_trx_reference5           => NULL
                                    --------------------------------------------------
                                    --Added by Bo Li for bug9305067 2010-4-14 END
                                      );
       IF lv_process_status <> jai_constants.successful THEN
          p_process_status := lv_process_status;
          p_process_message := lv_process_message;
          RETURN;
       END IF;

        process_vat_claim_acctg(
                                   ln_repository_id ,
                                   lv_procesS_status,
                                   lv_process_message);
         if lv_process_status<>  jai_constants.successful THEN
             app_exception.raise_exception;
         end if;


  exception when others then
       p_process_status := lv_process_status;
       p_process_message := lv_process_message;
end cgvat_reposit_entry;
PROCEDURE claim_balance_cgvat(
                p_term_id             IN          jai_rgm_terms.term_id%TYPE DEFAULT NULL,
                p_shipment_header_id  IN          rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                p_shipment_line_id    IN          rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                p_transaction_id      IN          rcv_transactions.transaction_id%TYPE DEFAULT NULL,
                p_tax_type            IN          jai_cmn_taxes_all.tax_type%TYPE DEFAULT NULL,
                p_tax_id              IN          jai_cmn_taxes_all.tax_id%TYPE DEFAULT NULL,
                p_receipt_num         IN          VARCHAR2,
                P_applied_qty         IN          NUMBER,
                p_organization_id     IN          NUMBER,
                p_inventory_item_id   IN          NUMBER,
                p_location_id         IN          NUMBER,
                p_Set_of_books_id         IN      NUMBER,
                p_currency                IN      VARCHAR2,
                p_transaction_header_id   IN       NUMBER,
                p_transaction_temp_id     IN NUMBER,
                p_vat_invoice_no          IN VARCHAR2,
                p_process_status      OUT         NOCOPY  VARCHAR2,
                p_process_message     OUT         NOCOPY  VARCHAR2)
  IS

    CURSOR  cur_lines(cp_shipment_header_id  IN  rcv_shipment_headers.shipment_header_id%TYPE,
                      cp_shipment_line_id    IN  rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  shipment_header_id, shipment_line_id
    FROM    jai_rcv_lines
    WHERE   shipment_header_id = NVL(cp_shipment_header_id, shipment_header_id)
    AND     shipment_line_id = NVL(cp_shipment_line_id, shipment_line_id)
    AND receipt_num=p_receipt_num
    and organization_id=p_organization_id
    and inventory_item_id=p_inventory_item_id
    ORDER BY shipment_line_id;


    CURSOR  cur_txns(cp_shipment_line_id  IN  rcv_shipment_lines.shipment_line_id%TYPE,
                     cp_transaction_id    IN  rcv_transactions.transaction_id%TYPE)
    IS
    SELECT  transaction_id,
            transaction_type,
            transaction_date,
            tax_transaction_id,
            parent_transaction_type,
            currency_conversion_rate,
            quantity
    FROM    JAI_RCV_TRANSACTIONS
    WHERE   shipment_line_id = NVL(cp_shipment_line_id, shipment_line_id)
    AND     transaction_id = NVL(cp_transaction_id, transaction_id)
    and organization_id=p_organization_id
    and inventory_item_id=p_inventory_item_id
    AND     (
              transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
            OR
              (   transaction_type = 'CORRECT'
              AND parent_transaction_type IN ('RECEIVE', 'RETURN TO VENDOR')
              )
            )
    ORDER BY transaction_id;



    CURSOR  cur_tax(cp_shipment_line_id           IN  rcv_transactions.shipment_line_id%TYPE,
                    cp_currency_conversion_rate IN  JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE)
    IS
    SELECT  DECODE(a.currency, jai_constants.func_curr, a.tax_amount, a.tax_amount*cp_currency_conversion_rate) tax_amount,  --Removed Round condition by Bgowrava for Bug#8414075
            a.tax_type,
            a.tax_id,
            NVL(b.rounding_factor,0) rounding_factor,
            c.qty_received
    FROM    JAI_RCV_LINE_TAXES a,
            jai_cmn_taxes_all b,
            jai_rcv_lines  c
    WHERE a.shipment_line_id =c.shipment_line_id
    AND a.shipment_line_id = cp_shipment_line_id
    AND     a.tax_type IN ( select tax_type
                            from jai_regime_tax_types_v
                            where regime_code = jai_constants.vat_regime
                          )
    AND     a.tax_id = b.tax_id
    AND     a.modvat_flag = 'Y'
    AND     NVL(a.tax_amount,0) <> 0;

    CURSOR  cur_term(cp_shipment_line_id IN rcv_shipment_lines.shipment_line_id%TYPE)
    IS
    SELECT  term_id, rcv_rgm_line_id, receipt_date
    FROM    jai_rcv_rgm_lines
    WHERE   shipment_line_id = cp_shipment_line_id
    AND     receipt_num=p_receipt_num
    and organization_id=p_organization_id
    and inventory_item_id=p_inventory_item_id
    AND    regime_code=jai_constants.vat_regime;

    CURSOR cur_sum_schedules(cp_schedule_id  IN  NUMBER)
    IS
    SELECT  SUM(installment_amount) total_installment_amount, MAX(installment_no) max_installment_no
    FROM    jai_rgm_trm_schedules_t
    WHERE   schedule_id = cp_schedule_id;


    CURSOR cur_installment_count( cp_rcv_rgm_line_id  IN  NUMBER,
                                  cp_transaction_id   IN  NUMBER,
                                  cp_tax_id           IN  NUMBER,
                                  cp_schedule_id      IN  NUMBER)
    IS
    SELECT  COUNT(*) count
    FROM    jai_rcv_rgm_claims
    WHERE   rcv_rgm_line_id = cp_rcv_rgm_line_id
    AND     transaction_id = cp_transaction_id
    AND     tax_id = cp_tax_id
    AND     installment_no IN ( SELECT  installment_no
                                FROM    jai_rgm_trm_schedules_t
                                WHERE   schedule_id = cp_schedule_id);
     CURSOR cur_installpaid_count( cp_rcv_rgm_line_id  IN  NUMBER,
                                        cp_transaction_id   IN  NUMBER,
                                        cp_tax_id           IN  NUMBER)
      IS
      SELECT  COUNT(*) count
      FROM    jai_rcv_rgm_claims
      WHERE   rcv_rgm_line_id = cp_rcv_rgm_line_id
      AND     transaction_id = cp_transaction_id
      AND     tax_id = cp_tax_id
      AND     installment_amount <> 0
      and     status='Y';



    cursor cur_get_schedule(cp_schedule_id in number)
    is
    select * from jai_rgm_trm_schedules_t
    where schedule_id=cp_schedule_id
    order by installment_no;

    r_term  cur_term%ROWTYPE;
    ln_schedule_id  NUMBER;
    lv_process_flag VARCHAR2(2);
    lv_process_msg  VARCHAR2(1000);
    ln_amount            NUMBER;
    r_sum_schedules      cur_sum_schedules%ROWTYPE;
    r_installment_count  cur_installment_count%ROWTYPE;
    ln_apportion_factor  NUMBER;
    ln_claim_schedule_id NUMBER;
    ln_instpaid_cnt      NUMBER;
    ln_debit_amt         NUMBER;
    LN_CNT               NUMBER;


  BEGIN

    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    FOR rec_lines IN cur_lines(p_shipment_header_id, p_shipment_line_id)
    LOOP


      OPEN cur_term(rec_lines.shipment_line_id);
      FETCH cur_term INTO r_term;
      CLOSE cur_term;

      FOR rec_txns IN cur_txns(rec_lines.shipment_line_id, p_transaction_id)
      LOOP
        ln_apportion_factor := ABS(jai_rcv_trx_processing_pkg.get_apportion_factor(rec_txns.transaction_id));


        FOR tax_rec IN cur_tax(rec_lines.shipment_line_id , rec_txns.currency_conversion_rate)  -- Harshita for Bug 4995579
        LOOP
          ln_cnt := 0;
          if tax_rec.qty_received<>0 then
            ln_amount := ROUND(((tax_rec.tax_amount * ln_apportion_factor)*(p_applied_qty/nvl(tax_rec.qty_received,1))),
			                     tax_rec.rounding_factor); --Added Round condition by Bgowrava for Bug#8414075
          end if;

          jai_cmn_rgm_terms_pkg.generate_term_schedules(p_term_id       => NVL(p_term_id,r_term.term_id),
                                                    p_amount        => ln_amount,
                                                    p_register_date => r_term.receipt_date,
                                                    p_schedule_id   => ln_schedule_id,
                                                    p_process_flag  => lv_process_flag,
                                                    p_process_msg   => lv_process_msg);

          IF lv_process_flag <> jai_constants.successful THEN

            DELETE  jai_rgm_trm_schedules_t
            WHERE   schedule_id = ln_schedule_id;

            p_process_status := lv_process_flag;
            p_process_message := lv_process_msg;
            RETURN;
          END IF;


            UPDATE  jai_rgm_trm_schedules_t
            SET     installment_amount = ROUND(installment_amount, tax_rec.rounding_factor)
            WHERE   schedule_id = ln_schedule_id;

            OPEN cur_sum_schedules(ln_schedule_id);
            FETCH cur_sum_schedules INTO r_sum_schedules;
            CLOSE cur_sum_schedules;

            IF NVL(r_sum_schedules.total_installment_amount,0) <> NVL(ln_amount,0) THEN
              UPDATE  jai_rgm_trm_schedules_t
              SET     installment_amount = installment_amount + ln_amount - r_sum_schedules.total_installment_amount
              WHERE   installment_no = r_sum_schedules.max_installment_no
              AND     schedule_id = ln_schedule_id;
            END IF;
              OPEN cur_installpaid_count( cp_rcv_rgm_line_id  => r_term.rcv_rgm_line_id,
                                         cp_transaction_id   => rec_txns.transaction_id,
                                         cp_tax_id           => tax_rec.tax_id);

              FETCH cur_installpaid_count INTO ln_instpaid_cnt;
              CLOSE cur_installpaid_count;

              UPDATE  jai_rgm_trm_schedules_t
              SET     installment_amount = installment_amount * (-1) /*This is to reduce the quantity available for claim*/
              WHERE   schedule_id = ln_schedule_id;


          for sch_det in cur_get_schedule(ln_schedule_id)
          loop
             select jai_rcv_rgm_claims_s.NEXTVAL into ln_claim_schedule_id from dual;
            INSERT
            INTO    jai_rcv_rgm_claims
                    (
                      CLAIM_SCHEDULE_ID,
                      RCV_RGM_LINE_ID,
                      Shipment_header_id,
                      Shipment_line_id,
                      Regime_code,
                      Tax_transaction_id,
                      Transaction_type,
                      Transaction_id,
                      Parent_transaction_type,
                      Installment_no,
                      Installment_amount,
                      Claimed_amount,
                      Scheduled_date,
                      claimed_date,
                      Status,
                      Manual_claim_flag,
                      Remarks,
                      Tax_type,
                      Tax_id,
                      Trx_tax_id,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATE_LOGIN
                    )values
                   (ln_claim_schedule_id,
                    r_term.rcv_rgm_line_id,
                    rec_lines.shipment_header_id,
                    rec_lines.shipment_line_id,
                    jai_constants.vat_regime,
                    rec_txns.tax_transaction_id,
                    rec_txns.transaction_type,
                    rec_txns.transaction_id,
                    rec_txns.parent_transaction_type,
                    sch_det.installment_no,
                    sch_det.installment_amount,
                    NULL,
                    sch_det.installment_date,
                    NULL,
                    'N',
                    NULL,
                    NULL,
                    tax_rec.tax_type,
                    tax_rec.tax_id,
                    NULL,
                    fnd_global.user_id,
                    SYSDATE,
                    fnd_global.user_id,
                    SYSDATE,
                    fnd_global.login_id);
            if ln_instpaid_cnt>nvl(ln_cnt,0) then
             update jai_rcv_rgm_claims
                set claimed_amount=0,
                    claimed_date=sysdate,
                    status='Y',
                    installment_amount=0
             where claim_schedule_id=ln_claim_schedule_id;
             ln_cnt:=nvl(ln_cnt,0)+1;
          else
            ln_debit_amt:=nvl(ln_debit_amt,0)+   sch_det.installment_amount;
           end if;

        end loop;
           update jai_rcv_rgm_lines
           set    recoverable_amount = nvl(recoverable_amount,0) + nvl(ln_debit_amt,0)
           where  rcv_rgm_line_id    = r_term.rcv_rgm_line_id;

           cgvat_reposit_entry(p_organization_id       ,
                                p_location_id          ,
                                p_Set_of_books_id      ,
                                p_currency             ,
                                p_transaction_header_id,
                                p_transaction_temp_id  ,
                                rec_txns.transaction_id,
                                p_vat_invoice_no       ,
                                tax_rec.tax_type       ,
                                (-1) * ln_debit_amt    ,
                                ln_schedule_id         ,
                                lv_process_flag        ,
                                lv_process_msg );

           if lv_process_flag<>  jai_constants.successful THEN
               app_exception.raise_exception;
           end if;

           DELETE jai_rgm_trm_schedules_t
            WHERE schedule_id = ln_schedule_id;

     END LOOP;

   END LOOP;

 END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := lv_process_flag;
      p_process_message := lv_process_msg;
END claim_balance_cgvat;

PROCEDURE process_vat_claim_acctg(
                p_repository_id       IN  NUMBER,
                p_process_status      OUT NOCOPY  VARCHAR2,
                p_process_message     OUT NOCOPY  VARCHAR2)
  IS
    CURSOR cur_claims
    IS
    SELECT REPOSITORY_ID,
               REGIME_CODE,
               TAX_TYPE,
               SOURCE_DOCUMENT_ID,
               DEBIT_AMOUNT,
               CREDIT_AMOUNT,
               ORGANIZATION_ID,
               LOCATION_ID
    FROM   jai_rgm_trx_records
  WHERE  repository_id = p_repository_id;

  CURSOR cur_regimes(cp_regime_code VARCHAR2)
  IS
  SELECT regime_id
  FROM jai_rgm_definitions
  WHERE regime_code = cp_regime_code;

    lv_accounting_type      VARCHAR2(100);
    lv_account_nature       VARCHAR2(100);
    lv_source_name          VARCHAR2(100);
    lv_category_name        VARCHAR2(100);
    ln_debit_ac                NUMBER;
    ln_credit_ac               NUMBER;
    lv_currency_code        VARCHAR2(10);
    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    ld_accounting_date      DATE;
    ln_repository_id        jai_rgm_trx_records.repository_id%TYPE;
    lv_destination          VARCHAR2(10);
    lv_code_path            JAI_RCV_TRANSACTIONS.codepath%TYPE;
    lv_process_status       VARCHAR2(2);
    lv_process_message      VARCHAR2(1000);
  ln_regime_id            jai_rgm_definitions.regime_id%TYPE;

  rec_claims cur_claims%ROWTYPE;

    lv_reference_10         gl_interface.reference10%TYPE;
    lv_reference_23         gl_interface.reference23%TYPE;
    lv_reference_24         gl_interface.reference24%TYPE;
    lv_reference_26         gl_interface.reference26%TYPE;

  sqlstmt                 VARCHAR2(512);
  BEGIN

  lv_accounting_type     := 'REVERSAL';
  lv_account_nature      := 'VAT CLAIM';
  lv_source_name         := 'Purchasing';
  lv_category_name       := 'Receiving India';
    lv_reference_10        := 'VAT claim accounting';
    lv_reference_23        := 'jai_mtl_trxs_pkg.process_vat_claim_acctg';
    lv_reference_24        := 'jai_rgm_trx_records';
    lv_reference_26        := 'repository_id';
  lv_currency_code       := jai_constants.func_curr;
  ld_accounting_date     := TRUNC(SYSDATE);
  lv_destination         := 'G';

  sqlstmt := 'opening cur_claims cursor';
    OPEN cur_claims;
  FETCH cur_claims INTO rec_claims;
  CLOSE cur_claims;

  sqlstmt := 'opening cur_regimes cursor';
    OPEN cur_regimes(rec_claims.regime_code);
  FETCH cur_regimes INTO ln_regime_id;
  CLOSE cur_regimes;

  sqlstmt := 'jai_cmn_rgm_recording_pkg.get_account for interim recovery account';
  ln_debit_ac := jai_cmn_rgm_recording_pkg.get_account(
                  p_regime_id         => ln_regime_id,
                  p_organization_type => jai_constants.orgn_type_io,
                  p_organization_id   => rec_claims.organization_id,
                  p_location_id       => rec_claims.location_id,
                  p_tax_type          => rec_claims.tax_type,
                  p_account_name      => jai_constants.recovery_interim);

  sqlstmt := 'jai_cmn_rgm_recording_pkg.get_account for recovery account';
  ln_credit_ac := jai_cmn_rgm_recording_pkg.get_account(
                  p_regime_id         => ln_regime_id,
                  p_organization_type => jai_constants.orgn_type_io,
                  p_organization_id   => rec_claims.organization_id,
                  p_location_id       => rec_claims.location_id,
                  p_tax_type          => rec_claims.tax_type,
                  p_account_name      => jai_constants.recovery);


  ln_entered_dr := rec_claims.credit_amount;
  ln_entered_cr := NULL;
  lv_reference_10 := 'India Local VAT Claim Entries For Repository id'||rec_claims.repository_id;

    sqlstmt := 'jai_rcv_accounting_pkg.process_transaction for debit';
  IF NVL(ln_entered_dr,0) <> 0 THEN
    jai_rcv_accounting_pkg.process_transaction(
              p_transaction_id      => rec_claims.source_document_id,
              p_acct_type           => lv_accounting_type,
              p_acct_nature         => lv_account_nature,
              p_source_name         => lv_source_name,
              p_category_name       => lv_category_name,
              p_code_combination_id => ln_debit_ac,
              p_entered_dr          => ln_entered_dr,
              p_entered_cr          => ln_entered_cr,
              p_currency_code       => lv_currency_code,
              p_accounting_date     => ld_accounting_date,
              p_reference_10        => lv_reference_10,
              p_reference_23        => lv_reference_23,
              p_reference_24        => lv_reference_24,
              p_reference_25        => p_repository_id,
              p_reference_26        => lv_reference_26,
              p_destination         => lv_destination,
              p_simulate_flag       => 'N',
              p_codepath            => lv_code_path,
              p_process_message     => lv_process_message,
              p_process_status      => lv_process_status,
              p_reference_name      => jai_constants.repository_name,
              p_reference_id        => p_repository_id);

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status := lv_process_status;
      p_process_message := lv_process_message;
      RETURN;
    END IF;
    END IF;

    ln_entered_dr := NULL;
    ln_entered_cr := rec_claims.credit_amount;
      sqlstmt := 'jai_rcv_accounting_pkg.process_transaction for credit';
    IF NVL(ln_entered_cr,0) <> 0 THEN
    jai_rcv_accounting_pkg.process_transaction(
              p_transaction_id      => rec_claims.source_document_id,
              p_acct_type           => lv_accounting_type,
              p_acct_nature         => lv_account_nature,
              p_source_name         => lv_source_name,
              p_category_name       => lv_category_name,
              p_code_combination_id => ln_credit_ac,
              p_entered_dr          => ln_entered_dr,
              p_entered_cr          => ln_entered_cr,
              p_currency_code       => lv_currency_code,
              p_accounting_date     => ld_accounting_date,
              p_reference_10        => lv_reference_10,
              p_reference_23        => lv_reference_23,
              p_reference_24        => lv_reference_24,
              p_reference_25        => p_repository_id,
              p_reference_26        => lv_reference_26,
              p_destination         => lv_destination,
              p_simulate_flag       => 'N',
              p_codepath            => lv_code_path,
              p_process_message     => lv_process_message,
              p_process_status      => lv_process_status,
              p_reference_name      => jai_constants.repository_name,
              p_reference_id        => p_repository_id);

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status := lv_process_status;
      p_process_message := lv_process_message;
      RETURN;
    END IF;
    END IF;

   p_process_status := jai_constants.successful;
EXCEPTION
   WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := 'SQL error while calling '||sqlstmt||' :'||SQLCODE||' : '||SQLERRM;
END process_vat_claim_acctg;

PROCEDURE delete_trx(p_transaction_header_id IN NUMBER,
                     p_transaction_temp_id   IN NUMBER)
IS
BEGIN

  DELETE jai_mtl_match_receipts
  WHERE  transaction_temp_id in
         (
            SELECT transaction_temp_id
            FROM   jai_mtl_trxs
            WHERE  transaction_header_id  = p_transaction_header_id
            AND    transaction_temp_id    = nvl(p_transaction_temp_id, transaction_temp_id )
            AND    transaction_commit_date is null
         );

  DELETE jai_cmn_document_taxes
  WHERE  source_doc_type = 'INTERORG_XFER'
  and source_table_name = 'MTL_MATERIAL_TRANSACTIONS_TEMP'
  AND    source_doc_line_id  IN
                        (
                        SELECT transaction_temp_id
                        FROM   jai_mtl_trxs
                        WHERE  transaction_header_id = p_transaction_header_id
                        AND    transaction_temp_id   = nvl(p_transaction_temp_id, transaction_temp_id )
                        AND    transaction_commit_date is null
                       );

  DELETE JAI_CMN_MATCH_TAXES
  WHERE  ref_line_id IN
                    (
                      SELECT transaction_temp_id
                      FROM   jai_mtl_trxs
                      WHERE  transaction_header_id = p_transaction_header_id
                      AND    transaction_temp_id   = nvl(p_transaction_temp_id, transaction_temp_id )
                      AND    transaction_commit_date is null
                    )
  AND    order_invoice='X';

  DELETE JAI_CMN_MATCH_RECEIPTS
  WHERE  ref_line_id IN
                    (
                      SELECT transaction_temp_id
                      FROM   jai_mtl_trxs
                      WHERE  transaction_header_id = p_transaction_header_id
                      AND    transaction_temp_id   = nvl(p_transaction_temp_id, transaction_temp_id )
                      AND    transaction_commit_date is null
                    )
  AND  order_invoice='X';

  DELETE jai_mtl_trxs
  WHERE  transaction_header_id = p_transaction_header_id
  AND    transaction_temp_id   = nvl(p_transaction_temp_id, transaction_temp_id )
  AND    transaction_commit_date is null;

END delete_trx;

PROCEDURE default_taxes(
  p_to_organization_id              number      ,
  p_to_location_code                VARCHAR2    ,
  p_transfer_subinventory           varchar2    ,
  p_toorg_location_id               number      ,
  p_organization_id                 number      ,
  p_subinventory_code               varchar2    ,
  p_transaction_type_id             number      ,
  p_header_id                       NUMBER      ,
  p_line_id                         NUMBER      ,
  p_inventory_item_id               NUMBER      ,
  p_uom_code                        VARCHAR2    ,
  p_line_quantity                   NUMBER      ,
  p_item_cost                       NUMBER      ,
  p_currency                        VARCHAR2    ,
  p_currency_conv_factor            NUMBER      ,
  p_date_order                      DATE        ,
  p_Iproc_profile_val               number      ,
  p_assessable_value          OUT NOCOPY  NUMBER      ,
  p_vat_assessable_value      OUT NOCOPY  NUMBER      ,
  p_tax_amount             IN OUT NOCOPY  NUMBER
)
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  cursor c_cust_dtl is
  SELECT su.site_use_id,cas.cust_account_id
  FROM
    hz_cust_acct_sites_all cas,
    hz_cust_site_uses_all su,
    po_location_associations_all pla,
    hr_locations hrl
  WHERE cas.cust_acct_site_id = su.cust_acct_site_id
  AND su.site_use_id = pla.site_use_id(+)
  AND pla.location_id = hrl.location_id(+)
  AND su.site_use_code = 'SHIP_TO'
  AND RTRIM(Ltrim(hrl.location_code)) = LTRIM(Rtrim(p_to_location_code))
  AND hrl.inventory_organization_id = p_to_organization_id ;  --  bug 6444945

  cursor c_jai_mtl_trxs is
  SELECT to_subinventory        ,
         inventory_item_id      ,
         quantity               ,
         transaction_uom
    FROM jai_mtl_trxs
   WHERE transaction_header_id = p_header_id
     AND transaction_temp_id   = p_line_id;

  r_jai_mtl_trxs            c_jai_mtl_trxs%ROWTYPE;
  ln_site_use_id            number(15);
  ln_cust_account_id        number(15);
  ln_tax_category_id        number(15);
  ln_user_id                number(15);

  ln_assessable_value      NUMBER; -- number(15); changed for bug #8882785
  ln_vat_assessable_value   NUMBER; -- number(15); changed for bug #8882785

BEGIN

  ln_user_id := fnd_global.user_id;

  open c_jai_mtl_trxs;
  fetch c_jai_mtl_trxs into r_jai_mtl_trxs;
  close c_jai_mtl_trxs;

/*
||The following condition is to see if only quantity is changed
||In this scenario the taxes need to be recalculated and not redefaulted.
||If any match information is present this would also be deleted
*/
  IF r_jai_mtl_trxs.quantity <> p_line_quantity THEN

    IF r_jai_mtl_trxs.inventory_item_id = p_inventory_item_id AND
       r_jai_mtl_trxs.transaction_uom   = p_uom_code          AND
       r_jai_mtl_trxs.to_subinventory   = p_transfer_subinventory THEN

       UPDATE jai_cmn_document_taxes
          SET tax_amt               = ( p_line_quantity / r_jai_mtl_trxs.quantity ) * tax_amt,
              FUNC_TAX_AMT          = ( p_line_quantity / r_jai_mtl_trxs.quantity ) * func_tax_amt,
              last_update_date      = sysdate,
              last_updated_by       = ln_user_id
        WHERE source_doc_id         = p_header_id
          AND source_doc_line_id    = p_line_id;

       UPDATE jai_mtl_trxs
          SET quantity              = p_line_quantity,
              last_update_date      = sysdate,
              last_updated_by        = ln_user_id
        WHERE transaction_header_id = p_header_id
          AND transaction_temp_id   = p_line_id;

        DELETE JAI_CMN_MATCH_RECEIPTS
         WHERE ref_line_id   = p_line_id
           AND order_invoice = 'X';

        DELETE jai_mtl_match_receipts
         WHERE transaction_temp_id = p_line_id ;

        DELETE JAI_CMN_MATCH_TAXES
         WHERE ref_line_id   = p_line_id
           AND order_invoice = 'X' ;

         COMMIT;

         RETURN;

    END IF;

  END IF;

  open c_cust_dtl;
  fetch c_cust_dtl into ln_site_use_id, ln_cust_account_id;
  close c_cust_dtl;


  /* following deletes all the IL data sofar saved as the taxes are going to redefault */
  delete_trx(
    p_transaction_header_id => p_header_id,
    p_transaction_temp_id   => p_line_id
  );

  -- lv_Iproc_profile_val := fnd_profile.value_specific(NAME =>'GL_SET_OF_BKS_ID',user_id=>ln_user_id);
  jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes (
      p_org_id              =>p_to_organization_id,
      p_customer_id         =>ln_cust_account_id,
      p_ship_to_site_use_id =>ln_site_use_id ,
      p_inventory_item_id   =>p_inventory_item_id ,
      p_header_id           =>p_header_id ,
      p_line_id             =>p_line_id ,
      p_tax_category_id     =>ln_tax_category_id
  );

  ln_assessable_value := jai_om_utils_pkg.get_oe_assessable_value
                                  (
                                      p_customer_id         => ln_cust_account_id,
                                      p_ship_to_site_use_id => ln_site_use_id,
                                      p_inventory_item_id   => p_inventory_item_id,
                                      p_uom_code            => p_uom_code,
                                      p_default_price       => p_item_cost,
                                      p_ass_value_date      => p_date_order,
                                      p_sob_id              => p_Iproc_profile_val,
                                      p_curr_conv_code      => null,
                                      p_conv_rate           => null
                              );

  -- copy(v_assessable_value,'MTL_TRX_LINE.ASSESSABLE_VALUE');

  ln_vat_assessable_value :=  jai_general_pkg.ja_in_vat_assessable_value
                                 (
                                  p_party_id           => ln_cust_account_id ,
                                  p_party_site_id      => ln_site_use_id ,
                                  p_inventory_item_id  => p_inventory_item_id   ,
                                  p_uom_code           => p_uom_code             ,
                                  p_default_price      => p_item_cost,
                                  p_ass_value_date     => p_date_order       ,
                                  p_party_type         => 'C'
                                 );

  ln_vat_assessable_value :=round( nvl(ln_vat_assessable_value,0) * p_line_quantity,2);--added round for bug#8882785

  -- copy(ln_vat_assessable_value,'MTL_TRX_LINE.VAT_ASSESSABLE_VALUE');

  INSERT INTO jai_mtl_trxs(
    transaction_id,
    transaction_header_id ,
    transaction_temp_id   ,
    transaction_type_id   ,
    from_organization     ,
    to_organization    ,
    inventory_item_id     ,
    from_subinventory     ,
    to_subinventory ,
    location_id        ,
    quantity  ,
    taxcategory_id       ,
    selling_price             ,
    assessable_value      ,
    vat_assessable_value  ,
    transaction_date,
    transaction_uom  ,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) VALUES (
    jai_mtl_trxs_s.nextval,
    p_header_id,                  -- :mtl_trx_line.transaction_header_id,
    p_line_id,                    -- :mtl_trx_line.transaction_temp_id,
    p_transaction_type_id,        -- :mtl_trx_line.transaction_type_id,
    p_organization_id,            -- :mtl_trx_line.organization_id,
    p_to_organization_id,                     -- :org.to_org_id,
    p_inventory_item_id,          -- :mtl_trx_line.inventory_item_id,
    p_subinventory_code,          -- :mtl_trx_line.subinventory_code,
    p_transfer_subinventory,      -- :mtl_trx_line.transfer_subinventory,
    p_toorg_location_id,          -- :mtl_trx_line.toorg_location_id
    p_line_quantity,              -- :mtl_trx_line.transaction_quantity
    ln_tax_category_id,           -- :ja_in_tax.tax_category_id,
    p_item_cost,                  -- :mtl_trx_line.item_cost,
    ln_assessable_value,          -- v_assessable_value,
    ln_vat_assessable_value,      -- :mtl_trx_line.vat_assessable_value,
    sysdate,              -- p_date_order
    p_uom_code,                   -- :mtl_trx_line.transaction_uom,
    sysdate,
    ln_user_id,
    sysdate,
    ln_user_id,
    fnd_global.login_id
  );

  --added round for bug#8882785
  ln_assessable_value := round(nvl(ln_assessable_value,0)* p_line_quantity,2);    /* value returned is excise assessable value of the line */

  jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes(
          transaction_name        => 'INTERORG_XFER',
          p_tax_category_id       => ln_tax_category_id,
          p_header_id             => p_header_id,
          p_line_id               => p_line_id,
          p_assessable_value      => ln_assessable_value   ,
          p_tax_amount            => p_tax_amount ,
          p_inventory_item_id     => p_inventory_item_id ,
          p_line_quantity         => p_line_quantity  ,
          p_uom_code              => p_uom_code,
          p_vendor_id             => NULL,
          p_currency              => 'INR',
          p_currency_conv_factor  => p_currency_conv_factor,
          p_creation_date         => sysdate  ,
          p_created_by            => ln_user_id,
          p_last_update_date      => sysdate ,
          p_last_updated_by       => ln_user_id,
          p_last_update_login     => fnd_global.login_id ,
          p_operation_flag        => NULL,
          p_vat_assessable_value  => ln_vat_assessable_value
  ) ;

  COMMIT;

  p_assessable_value := ln_assessable_value;                            /* value returned is excise assessable value of the line */
  p_vat_assessable_value := nvl(ln_vat_assessable_value,0);             /* value returned is VAT assessable value of the line */

exception
  when others then
    app_exception.raise_exception;

END default_taxes;

PROCEDURE delete_trx_autonomous(p_transaction_header_id IN NUMBER,
                                p_transaction_temp_id   IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

   delete_trx(p_transaction_header_id,p_transaction_temp_id) ;
   COMMIT;

END delete_trx_autonomous;


PROCEDURE  sync_with_base_trx(
    p_transaction_header_id IN NUMBER,
    p_transaction_temp_id   IN NUMBER,
    p_event                 IN VARCHAR2
) IS
BEGIN

   /*commented for bug#8800063
    delete_trx_autonomous is giving the deadlock if any error occurs
    during the forms commit processing*
    sync_with_base_trx will be called from key-exit,key-clrrec,key-clrblk,when-window-closed,key-clrform,
    hence added the commit stmt such that the delete_trx stmts will get commited.*

   IF p_event <> 'KEY-COMMIT' THEN

      delete_trx_autonomous(p_transaction_header_id ,
                              p_transaction_temp_id);

   ELSE
   */

      delete_trx(
        p_transaction_header_id ,
        p_transaction_temp_id
      );
      commit; --bug#8800063

--   END IF;

END sync_with_base_trx;

END;

/

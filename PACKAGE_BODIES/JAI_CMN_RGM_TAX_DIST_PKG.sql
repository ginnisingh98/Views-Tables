--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_TAX_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_TAX_DIST_PKG" AS
/* $Header: jai_cmn_rgm_dist.plb 120.14.12010000.19 2010/03/11 05:40:18 srjayara ship $ */
/***************************************************************************************************
CREATED BY       : ssumaith
CREATED DATE     : 11-JAN-2005
ENHANCEMENT BUG  : 4068911
PURPOSE          : To get the balances , to insert records into repository
CALLED FROM      : jai_cmn_rgm_settlement_pkg , JAIRGMDT.fmb , JAIRGMDT.fmb
/* -------------------------------------------------------------------------------------------------------------------
1. 08-Jun-2005    File Version 116.2. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                  as required for CASE COMPLAINCE.

2. 13-Jun-2005    rchandan for bug#4428980. File Version: 116.3
                  Removal of SQL LITERALs is done

3. 17-Aug-2005    Ramananda for bug#4557267 (Fwd porting for the bug 4276280 ) during R12 Sanity Testing. File Version 120.2
                  The Settlement form was erroring out when get_details button was pressed giving a
                  message "cannot insert NULL into debit balances". This was happening if the last
                  settlement balnce amount was NULL. From now it will be taken as zero instead of NULL.
                  While inserting into temp table nvl check is added for ln_settled_credit_balance
                  and ln_settled_debit_balance.
                  NVL() is added to the following parameters:
                    p_debit_amt    => nvl(ln_settled_debit_balance,0) + delta_rec.debit_amt
                    p_credit_amt   => nvl(ln_settled_credit_balance,0) + delta_rec.credit_amt
4.  25-Aug-2005   Bug4568078. Added by Lakshmi Gopalsami Version 120.3
                  (1) Added parameter p_pla_balance in procedure
                      insert_records_into_temp
                  (2) Added pla_balance while inserting into jai_rgm_balance_t
                  (3) Added nvl(pla_balance,0) in cursor c_balance_cur in
                      procedure calculate_balances_for_io. Added cursor
                      c_pla_cess_balance to fetch the pla_balance and
                      passed the same to insert_records_into_temp
                  (4) Passed NULL for p_pla_balance in the call to
                      insert_records_into_temp in procedure
                      calculate_balances_for_ou.

                  Dependencies:(Functional+Compilation)
                  ------------
                  JAIRGMDT.fmb 120.3

5   27/03/2006    Hjujjuru for Bug 5096787 , File Version 120.4
                   Spec changes have been made in this file as a part og Bug 5096787.
                   Now, the r12 Procedure/Function specs is in this file are in
                   sync with their corrsponding 11i counterparts

6.  19/12/2006    CSahoo for Bug 5073553, File Version 120.5
                  1.Changed the procedure jai_rgm_distribution_pkg.calculate_balances_for_io such that in case
                   the pla balance is -ve, populate the column JAI_RGM_BALANCE_T debit_amt and JAI_RGM_BALANCE_T pla_balance as 0
                   else (+ve value for PLA balance) let the value of o be populated into JAI_RGM_BALANCE_T debit_amt  and pla_balance
                   would be the register pla_amt amount for the IO.
                  2.Added a new function f_get_io_register in both package spec and body .
7.  30/01/2007   SACSETHI FOR BUG#5631784. FILE VERSION 120.7
      FORWARD PORTING BUG FROM 11I BUG 4742259
      NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES
      Changes -

      OBJECT TYPE       OBJECT NAME       CHANGE                 DESCRIPTION
      --------------------------------------------------------------------------------------
      PROCEDURE               PUNCH_SETTLEMENT_ID ARGUMENT ADDED           P_TAN_NO IS ADDED
      PROCEDURE               PUNCH_SETTLEMENT_ID ARGUMENT ADDED           P_ITEM_CLASSIFICATION IS ADDED
      PROCEDURE               PUNCH_SETTLEMENT_ID CODE ADDED               UPDATATION OF SETTLEMENT_ID IN TABLE
                               JAI_RGM_REFS_ALL FOR TCS
      PROCEDURE               GET_BALANCES    ARGUMENT ADDED           P_ITEM_CLASSIFICATIONIS ADDED
      PROCEDURE               GET_BALANCES    CURSOR ADDED             CUR_REGIME_CODE IS ADDED
      PROCEDURE               GET_BALANCES    CODE ADDED               PROCEDURE CALCULATE_RGM_BALANCES FOR TCS
      PROCEDURE               CALCULATE_RGM_BALANCES  NEW CREATED              NEWLY PROCEDURE ADDED FOR TCS
----------------------------------------------------------------------------------------------------------------
8  23/04/2007   bduvarag for the Bug#5879769, file version 120.8
      Forward porting the changes done in 11i bug#5694855

9  7-June-2007        ssawant for bug 5662296
          Forward porting R11 bugs 5642053 and 4346527 to R12 bug 5662296.

10. 09-June-2007  CSahoo for BUG#6109941 , FileVersion 120.11
                  Added the sh cess types.

11. 16-Jul-2007   CSahoo for bug#6235971, File Version 120.13
                  added the following and condition in the for loop
                  "AND  a.settlement_id  IS NULL".
12. 10-OCT-2008   JMEENA for bug#7445742
          Modified procedure calculate_balances_for_ou
          and added condition source <> 'VAT REVERSAL' in the query.
13.12-Nov-2008            Changes by nprashar for bug 6359082, Forward port the changes from 11i bug 6348081.

14. 20-Nov-2008        Changes by nprashar for bug # 7525691, FP changes of 11 i bug 7518230.
                            Issue : SVC TX SETTLEMENT PROCESS WITH DIFF SVC TYPES DIDN'T CREATE NETTING SERVICE JE
                            Fix: modified the code in the procedure insert_records_into_register. Added a variable
                                  lv_balancing_entry. The value is set as N for settlement else it is null. Passed this
                                  variable to the procedure insert_repository_entry

15 30-dec-2008        Vkaranam for bug#6773684,file version 120.4.12000000.8/120.14.12010000.5/120.20
                    Issue:
        SERVICE TAX DISTRIBUTION IN PLA/RG DOES NOT RESULT IN PLA REGISTER
        Reason:
        Cursor 'cur_get_dist_plg_rg' is used to fetch "Service Tax Distribution in PLA/RG" setup value.
        In this cursor the organization_type is given as 'OU'.But after the 'Service tax by IO' enhancement\
        service tax at OU level is not supported.Due to this 'cur_get_dist_plg_rg' always return null and the code in function f_get_io_register
        always return 'RG'.
        Fix:
        1)
  Changes are done in function f_get_io_register .
          1.1 Removed organization_type='OU' condition from   Cursor 'cur_get_dist_plg_rg'.
          1.2 Added a conditon to get the value as 'RG' ,If the setup is not done.
        2)
  while calling the f_get_io_register_type ,party id is passed as p_to_party_id if the transfer is "Service --Excise"
        and p_from_party_id is passed  if the transfer is from "Excise-- Service"  .
  Changes are done as per the above.

15 04-feb-2009        Vkaranam for bug#6773684,file version 120.4.12000000.9/120.14.12010000.6/120.21
                     Revereted back the changes done in fp bug#  7525691 as the fix is not yet tested/released.

16 18-Mar-2009   Bug 7525691 File version 120.4.12000000.10/120.14.12010000.7/120.22
                 Added parameter p_distribution_type when calling jai_cmn_rgm_recording_pkg.insert_repository_entry

17 21-Jul-2009   CSahoo for bug#8702609, File Version 120.4.12000000.13
                 Issue: ISSUES WITH SERVICE TAX DISTRIBUTION AND SETTLEMENT FORMS
                 Fix: modified the code in the procedure calculate_balances_for_ou. Initially the settled amount
                      was getting added up to the amount the to be distributed. So modified the code so that the
                      settled amount no more gets added up.

18 22-Jul-2009   CSahoo for bug#8289991, File Version 120.4.12000000.14
                 Issue: FP12.0 :7828827 SERVICE TAX CREDIT AMOUNT IS NOT CARRYING FORWARD TO NEXT SETTLEMENT
                 FIX: Modified the procedure calculate_balances_for_ou. Removed the logic of calculating the
                      credit and debit balance on the basis of the service type. Added the code to obtain
                      total credit and debit amount from the last settlement date to the new settlement date.
                      Then check the last settled credit and debit amount for each tax type. If there is a
                      credit carry forward then it is added to the total credit amount to be settled.

19 28-jul-2009   vumaasha for bug 8657720, reverted the change done for the bug 7445742

20 11-sep-2009 vkaranam for bug#8873924
Issue:SERVICE TAX DISTRIBUTION WITH EXCISE-SERVICE TRANSFER IS HITTING RG23A
Reason:
If the service tax distribution in RG/PLA setup has been given as "RG" ,and excise to transfer is always
hitting RG23A' register eventhough the balance is not available in that.
register_type='A' has been hardcode with setup as "RG"
hence the issue.
Fix:

If the service tax distribution in RG/PLA setup as "RG"   and with "Excise-service" Transfer
,either RG23A/RG23C register will get hit based on the Register prefernces and the balance available in
the individual registers.

Changes are done  in  create_io_register_entry procedure to fetch the register_type based on
Register prefernces and the balance available in the RG23A/C registers for excise-service transfer.

20.  12-oct-2009 vkaranam for bug#9005474
                 issue:
		 TCS tax is geeting doubled during the settlement
		 Reason:
		 Issue is that jai_rgm_balance_tmp is popualted with double amount.
                 Issue is with the jai_cmn_rgm_tax_dist_pkg.CALCULATE_RGM_BALANCES procedure

		  JAI_RGM_ORG_REGNS_V is retreiving 2 rows for TCS type of taxes.
		  This will occuer only if the organization is associated with more than one location.

		  Fix:
		  Removed the 	JAI_RGM_ORG_REGNS_V in cursor for delta_rec in (

		  Added the table jai_rgm_registrations table.

21  14-oct-2009   vkaranam for bug#9005474
                  Added the condition jrr.organization_id=nvl(p_org_id,jrr.organization_id)
		  as per review comments

22  03-Dec-2009   Added by Jia for FP Bug#6174148
               Issue:
                 Vendor_id has been updated with org_id in table JA_IN_RG23_PART_II,
                 this caused the vendor name to be displayed instead of org_name in rg23 Part II form.
		           Fix:
                  This was a forward port issue of the R11i Bug#6129789.
                  Code changes are done in insert_records_into_register procedure.
                  Vendor_id has been inserted with -1 * org_id to solve the above issue.

22  19-Dec-2009   Eric for bug#8333082 and bug8671217

23  10-Mar-2009   Bug 9445836
                  Issue - New transactions which have transaction date lying in settled period
                  are not considered for the next settlement.
                  Fix - Changed the filter condition to fetch delta records in calculate_balances_for_ou
                  procedure. Instead of getting the transactions with date between last settlement date
                  and new settlement date, we fetch all unsettled transactions with date less than
                  the new settlement date.
                  Also modified the filter for update statements in punch_settlement_id procedure.

-- #
-- # Change History -
-- # Future Dependencies For the release Of this Object:-
-- # (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
-- #  A datamodel change )
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Current Version   Current Bug    Dependent           Files          Version     Author   Date         Remarks
Of File                          On Bug/Patchset    Dependent On
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 115.1            4245365         4245089                                       rchandan  17/Mar/05   Changes made to implement VAT
 115.2            4245365         4245089                                       rchandan  20/03/2005  Observations in VAT. From now when we are settling
                                                                                                      balances the opening balance of the last settlemnt date is not considered if it was completely settled.
                                                                                                      Only the transaction amount in the delta period is taken into consideration. If it is not settled then
                                                                                                      the settlement balances are taken into consideration


11.22-jun-2007  kunkumar made changes for bug#6127194 file 120.11
                Added package body to create_io_register_entry and
    made calls to the proc from insert_into_register proc.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
***************************************************************************************************/


  PROCEDURE insert_records_into_temp(
                                     p_request_id          NUMBER   ,
                                     p_regime_id           NUMBER   ,
                                     p_party_type          VARCHAR2 ,
                                     p_party_id            NUMBER   ,
                                     p_location_id         NUMBER   ,
                                     p_bal_date            DATE     ,
                                     p_tax_type            VARCHAR2 ,
                                     p_debit_amt           NUMBER   ,
                                     p_credit_amt          NUMBER   ,
                                     /* Bug4568078. Added by Lakshmi Gopalsami */
                                     p_pla_balance         NUMBER default NULL,
                                      p_service_type_code   VARCHAR2 DEFAULT NULL/*Bug 5879769 bduvarag*/
                                    )
  is
  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_tax_dist_pkg.insert_records_into_temp';

  BEGIN
    INSERT INTO  JAI_RGM_BALANCE_T
               (
                REQUEST_ID                                            ,
                REGIME_ID                                             ,
                PARTY_TYPE                                            ,
                PARTY_ID                                              ,
                LOCATION_ID                                           ,
                BALANCE_DATE                                          ,
                TAX_TYPE                                              ,
                DEBIT_AMT                                             ,
                CREDIT_AMT                                            ,
                CREATION_DATE                                         ,
                CREATED_BY                                            ,
                LAST_UPDATE_DATE                                      ,
                LAST_UPDATED_BY                                       ,
                LAST_UPDATE_LOGIN ,
    program_application_id,
    program_id,
    program_login_id,
    /* Bug 4568078. Added by Lakshmi Gopalsami */
    pla_balance,
    service_type_code /*Bug 5879769 bduvarag*/
               )
               VALUES
               (
                p_request_id                                          ,
                p_regime_id                                           ,
                p_party_type                                          ,
                p_party_id                                            ,
                p_location_id                                         ,
                p_bal_date                                            ,
                p_tax_type                                            ,
                round(p_debit_amt,ln_rounding_precision)              ,
                round(p_credit_amt,ln_rounding_precision)             ,
                sysdate                                               ,
                fnd_global.user_id                                    ,
                sysdate                                               ,
                fnd_global.user_id                                    ,
                fnd_global.login_id ,
    fnd_profile.value('PROG_APPL_ID'),
    fnd_profile.value('CONC_PROGRAM_ID'),
    fnd_profile.value('CONC_LOGIN_ID'),
                /* Bug 4568078. Added by Lakshmi Gopalsami */
          p_pla_balance,
    p_service_type_code/*Bug 5879769 bduvarag*/
           );
 /* Added by Ramananda for bug#4407165 */
  EXCEPTION
   WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;
  END insert_records_into_temp;


--Added by Eric Ma for bug 8333082 on Dec-19-2009,begin
--------------------------------------------------------------------------------------
  PROCEDURE populate_all_orgs_vat( p_regn_no           jai_rgm_org_regns_v.attribute_value%TYPE,
                                 p_regn_id             jai_rgm_org_regns_v.registration_id%TYPE,
                                 p_regime_id           JAI_RGM_DEFINITIONS.regime_id%TYPE,
                                 p_request_id          NUMBER,
                                 p_balance_date        DATE,
                                 p_org_type            VARCHAR2 default NULL,
                                 p_settlement_id number,
                                 p_cramt_considered number --8671217
                                 )
IS
  CURSOR c_other_orgs(cp_regn_no jai_rgm_org_regns_v.attribute_value%TYPE,cp_regn_id jai_rgm_org_regns_v.registration_id%TYPE)
  IS
     SELECT organization_id,
      location_id
       FROM jai_rgm_org_regns_v
      WHERE regime_code                     = jai_constants.vat_regime
    AND attribute_code                      ='REGISTRATION_NO'
    AND attribute_value                     = cp_regn_no
    AND registration_id                     = cp_regn_id
    AND (organization_id, location_id) NOT IN
      (SELECT party_id, location_id FROM JAI_RGM_BALANCE_T where request_id=p_request_id
      );

  CURSOR cur_cr_bal(cp_regime_id JAI_RGM_DEFINITIONS.regime_id%TYPE)
  IS
     SELECT
     --(credit_balance - debit_balance) cr_balance,    8671217
(    sum(nvl(credit_balance,0))-sum(nvl(debit_balance,0)))  cr_balance ,
      tax_type
       FROM jai_rgm_stl_balances stl
      WHERE settlement_id =
      (SELECT MAX(jstl.settlement_id)
         FROM jai_rgm_stl_balances jstl,
        jai_rgm_Settlements jrs
        WHERE
        --jstl.party_id  = cp_org_id   8671217
      --AND jstl.location_id   = cp_location_id  8671217
      jstl.settlement_id = jrs.settlement_id
      and jstl.settlement_id<>p_settlement_id ---8671217 (To exclude from the current settlement)
      AND jrs.regime_id      = cp_regime_id
      )
      group by tax_type;---8671217
    --  AND stl.party_id  = cp_org_id    8671217
     --- AND stl.location_id   = cp_location_id;   8671217


  rec_other_orgs c_other_orgs%ROWTYPE;
  rec_cr_bal cur_cr_bal%ROWTYPE;
 ln_cr_balance NUMBER  ;

BEGIN


  OPEN c_other_orgs(p_regn_no,p_regn_id);
  LOOP
    FETCH c_other_orgs INTO rec_other_orgs ;
    EXIT WHEN c_other_orgs%NOTFOUND;

    --OPEN cur_cr_bal(rec_other_orgs.organization_id,rec_other_orgs.location_id,p_regime_id);
    OPEN cur_cr_bal(p_regime_id);
    LOOP
      FETCH cur_cr_bal INTO rec_cr_bal;
      EXIT
    WHEN cur_cr_bal%NOTFOUND;
      IF rec_cr_bal.cr_balance < 0 THEN
        rec_cr_bal.cr_balance :=0;
      END IF;
      --start additions for bug#8671217 (13-aug-2009)
      /***credit balance will updated only for the 1st organization in the c_other_orgs loop
      for the remaining orgs cr_balance is 0.
      ***/
      if c_other_orgs%rowcount=1
      then
         ln_cr_balance:= rec_cr_bal.cr_balance - nvl(p_cramt_considered,0);
      else
         ln_cr_balance :=0;
      end if;
      --end additions for bug#8671217  (13-aug-2009)

      insert_records_into_temp( p_request_id => p_request_id ,
                                p_regime_id => p_regime_id ,
                                p_party_type => p_org_type ,
                                p_party_id => rec_other_orgs.organization_id,
                                p_location_id => rec_other_orgs.location_id ,
                                p_bal_date => p_balance_date ,
                                p_tax_type => rec_cr_bal.tax_type ,
                                p_debit_amt => 0 ,
                                p_credit_amt => ln_cr_balance ,--rec_cr_bal.cr_balance,
                                p_pla_balance => NULL,
                                p_service_type_code => NULL
                             );
    END LOOP;
    CLOSE cur_cr_bal;
  END LOOP;
  CLOSE c_other_orgs;
/*un commented above   and commented the below for bug# 8671217

  --start additions for bug#8671217
  OPEN c_other_orgs(p_regn_no,p_regn_id);
  fetch   c_other_orgs INTO rec_other_orgs ;
  close    c_other_orgs;



  open cur_cr_bal(p_regime_id);
  loop
     FETCH cur_cr_bal INTO rec_cr_bal;
      EXIT   WHEN cur_cr_bal%NOTFOUND;


      IF rec_cr_bal.cr_balance < 0 THEN
        rec_cr_bal.cr_balance :=0;
      END IF;
      insert_records_into_temp( p_request_id => p_request_id ,
                                p_regime_id => p_regime_id ,
                                p_party_type => p_org_type ,
                                p_party_id => rec_other_orgs.organization_id,
                                p_location_id => rec_other_orgs.location_id ,
                                p_bal_date => p_balance_date ,
                                p_tax_type => rec_cr_bal.tax_type ,
                                p_debit_amt => 0 ,
                                p_credit_amt => rec_cr_bal.cr_balance,
                                p_pla_balance => NULL,
                                p_service_type_code => NULL
                             );
  END LOOP;
    CLOSE cur_cr_bal;
    --end bug#8671217
    */

END populate_all_orgs_vat;
--------------------------------------------------------------------------------
--Added by Eric Ma for bug 8333082 on Dec-19-2009,End


  PROCEDURE calculate_balances_for_io(p_regime_id     number ,
                                      p_balance_date  date   ,
                                      p_request_id    number,
                p_service_type_code   VARCHAR2 DEFAULT NULL/*Bug 5879769 bduvarag*/
                                     ) is
  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_tax_dist_pkg.calculate_balances_for_io';
    /*
      ||CSahoo. Bug 5073553. removed the where clause that the nvl(rg23A_balance,0) + nvl(rg23c_balance,0) <> 0
      ||instead now the criteria should be that in the form JAIRGMDT.fmb , user should not be able to select a IO with this sum = 0.
    */
    CURSOR c_balance_cur is
    SELECT org_unit_id             org_unit_id ,
           organization_id         party_id    ,
           location_id             location_id ,
           'EXCISE'                tax_type    ,
           nvl(rg23A_balance,0) + nvl(rg23c_balance,0)  Balance     ,
           'IO'                    party_type,
     /* Bug 4568078. Added by LGOPALSA */
     nvl(pla_balance,0) pla_balance
      FROM JAI_CMN_RG_BALANCES;
     --WHERE nvl(rg23A_balance,0) + nvl(rg23c_balance,0) <> 0 ;

    CURSOR c_cess_balance (cp_org_unit_id number) is
    SELECT SUM(balance)
      FROM JAI_CMN_RG_OTH_BALANCES
     WHERE org_unit_id = cp_org_unit_id
       AND register_type IN (jai_constants.reg_rg23a ,jai_constants.reg_rg23c)--rchandan for bug#4428980
       AND tax_type IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess);--rchandan for bug#4428980
    ln_cess_balance number :=0;
    /* Bug 4568078. Added by Lakshmi Gopalsami */

    CURSOR c_pla_cess_balance (cp_org_unit_id number) is
    SELECT SUM(balance)
      FROM JAI_CMN_RG_OTH_BALANCES
     WHERE org_unit_id = cp_org_unit_id
       AND register_type = jai_constants.reg_pla
       AND tax_type IN (jai_constants.tax_type_cvd_edu_cess,jai_constants.tax_type_exc_edu_cess) ;

    --added by csahoo for bug#6109941, start
    CURSOR c_sh_cess_balance (cp_org_unit_id number) is
    SELECT SUM(balance)
      FROM JAI_CMN_RG_OTH_BALANCES
     WHERE org_unit_id = cp_org_unit_id
       AND register_type IN (jai_constants.reg_rg23a ,jai_constants.reg_rg23c)
       AND tax_type IN (jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess);



    CURSOR c_sh_pla_cess_balance (cp_org_unit_id number) is
    SELECT SUM(balance)
      FROM JAI_CMN_RG_OTH_BALANCES
     WHERE org_unit_id = cp_org_unit_id
       AND register_type = jai_constants.reg_pla
       AND tax_type IN (jai_constants.tax_type_sh_cvd_edu_cess,jai_constants.tax_type_sh_exc_edu_cess) ;

    ln_sh_cess_balance  number :=0;
    ln_sh_pla_cess_balance  NUMBER :=0;
    ln_sh_debit_amt         NUMBER :=0;
    -- --added by csahoo for bug#6109941, end

    ln_rg23_cess_balance NUMBER :=0;
    ln_pla_cess_balance  NUMBER :=0;
    ln_debit_amt         NUMBER :=0;
    ln_pla_balance       NUMBER :=0;
    /* End for bug 4568078. Added by Lakshmi Gopalsami */

  BEGIN
      FOR bal_rec in c_balance_cur
        LOOP

         /*
          ||Start of bug 5073553.Added by CSahoo
          ||Initialize the variables
         */

          /*Start of bug 5073553*/
          ln_debit_amt          := 0;
          ln_pla_balance        := 0;
          ln_rg23_cess_balance  := 0;
          ln_pla_cess_balance   := 0;

          ln_sh_cess_balance  := 0;  --added by csahoo for bug#6109941
          ln_sh_pla_cess_balance   := 0;  --added by csahoo for bug#6109941

          IF  nvl(bal_rec.pla_balance,0) < 0 THEN
           /*
           ||-ve pla balance, then the amount should appear as the debit amt in the JAI_RGM_BALANCE_T table
           */
                                         /*Bug 8488788 - If the amount is represented on the debit side it infers that it is less than 0
                                         Hence representing as positive. The net amount in Service Tax Distribution form is calculated by
                                         subtracting debit from credit. If it is represented as -ve then it causes double effect*/
                                                ln_debit_amt := -bal_rec.pla_balance;
          ELSE
            /*
            || +ve pla balance then the amount should appear in the pla_balance
            */
            ln_pla_balance := bal_rec.pla_balance;
          END IF;
        /* End of bug 5073553*/
          insert_records_into_temp(
                                    p_request_id   => p_request_id        ,
                                    p_regime_id    => p_regime_id         ,
                                    p_party_type   => bal_rec.party_type  ,
                                    p_party_id     => bal_rec.party_id    ,
                                    p_location_id  => bal_rec.location_id ,
                                    p_bal_date     => p_balance_date      ,
                                    p_tax_type     => bal_rec.tax_type    ,
                                    /* changed by CSahoo for bug 5073553.
                                    ||put the variable ln_debit_amt instead of 0
                                    */
                                    p_debit_amt    => ln_debit_amt        ,
                                    p_credit_amt   => bal_rec.balance     ,
  p_pla_balance  => ln_pla_balance,
                                    /* Bug 4568078. Added by Lakshmi Gopalsami */
        p_service_type_code =>  p_service_type_code/*Bug 5879769 bduvarag*/
                                   );

          ln_debit_amt   := 0; -- Added by CSahoo, BUG#5073553
          OPEN  c_cess_balance(bal_rec.org_unit_id);
          FETCH c_cess_balance into ln_cess_balance;
          CLOSE c_cess_balance;

    OPEN c_pla_cess_balance(bal_rec.org_unit_id);
    FETCH c_pla_cess_balance into ln_pla_cess_balance;
    CLOSE c_pla_cess_balance;

           /*
          ||Start of bug 5073553.added by CSahoo
          ||If the cess balance is less than 0 then the same should appear in the debit_amt column of the JAI_RGM_BALANCE_T table
          || else it should appear in the pla_balance column
          */
          IF nvl(ln_pla_cess_balance,0) < 0 THEN
                                                /*Bug 8488788 - If the amount is represented on the debit side it infers that it is less than 0
                                                Hence representing as positive. The net amount in Service Tax Distribution form is calculated by
                                                subtracting debit from credit. If it is represented as -ve then it causes double effect*/
                                                ln_debit_amt        := -ln_pla_cess_balance;
            ln_pla_cess_balance := 0;
          END IF;
          /* End of bug 5073553*/
          insert_records_into_temp(
                                   p_request_id   => p_request_id        ,
                                   p_regime_id    => p_regime_id         ,
                                   p_party_type   => bal_rec.party_type  ,
                                   p_party_id     => bal_rec.party_id    ,
                                   p_location_id  => bal_rec.location_id ,
                                   p_bal_date     => p_balance_date      ,
                                   p_tax_type     => 'EXCISE-CESS'       ,
                                   p_debit_amt    => ln_debit_amt        , -- Added by CSahoo, BUG#5073553
                                   p_credit_amt   => ln_cess_balance     ,
        p_pla_balance  => ln_pla_cess_balance,
        p_service_type_code =>  p_service_type_code/*Bug 5879769 bduvarag*/
                                   );
        --added by csahoo for bug#6109941
        --start
        ln_sh_debit_amt   := 0;
        OPEN  c_sh_cess_balance(bal_rec.org_unit_id);
        FETCH c_sh_cess_balance into ln_sh_cess_balance;
        CLOSE c_sh_cess_balance;

        OPEN  c_sh_pla_cess_balance(bal_rec.org_unit_id);
        FETCH c_sh_pla_cess_balance into ln_sh_pla_cess_balance;
        CLOSE c_sh_pla_cess_balance;

        IF nvl(ln_sh_pla_cess_balance,0) < 0 THEN
                                        /*Bug 8488788 - If the amount is represented on the debit side it infers that it is less than 0
                                        Hence representing as positive. The net amount in Service Tax Distribution form is calculated by
                                        subtracting debit from credit. If it is represented as -ve then it causes double effect*/
                                        ln_sh_debit_amt        := -ln_sh_pla_cess_balance;
          ln_sh_pla_cess_balance := 0;
        END IF;


       insert_records_into_temp(
                                 p_request_id   => p_request_id        ,
                                 p_regime_id    => p_regime_id         ,
                                 p_party_type   => bal_rec.party_type  ,
                                 p_party_id     => bal_rec.party_id    ,
                                 p_location_id  => bal_rec.location_id ,
                                 p_bal_date     => p_balance_date      ,
                                 p_tax_type     => 'EXCISE_SH_EDU_CESS' ,
                                 p_debit_amt    => ln_sh_debit_amt        ,
                                 p_credit_amt   => ln_sh_cess_balance  ,
                                 p_pla_balance  => ln_sh_pla_cess_balance,
                                 p_service_type_code =>  p_service_type_code
                         );
        --added by csahoo for bug#6109941, end

        END LOOP;
  /* Added by Ramananda for bug#4407165 */
  EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;
  END calculate_balances_for_io;


  PROCEDURE punch_settlement_id( p_regime_id       number,
                                 p_settlement_id   number ,
                                 p_regn_id         number ,
                                 p_balance_date    date,
                           P_TAN_NO          VARCHAR2 DEFAULT NULL, -- ADDED BY SACSETHI ON 30-01-2007 FOR BUG 5631784
                                 p_org_id              NUMBER    default NULL,/*rchandan for bug#5642053*/
                                 p_location_id         NUMBER    default NULL,/*rchandan for bug#5642053*/
                           P_ITEM_CLASSIFICATION VARCHAR2 DEFAULT NULL, -- ADDED BY SACSETHI ON 30-01-2007 FOR BUG 5631784
                           p_regn_no              VARCHAR2  default NULL/*6835541*/
                                )
  is
  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_tax_dist_pkg.punch_settlement_id';

  CURSOR cur_regime_code IS      /* 4245365*/
  SELECT regime_code
    FROM JAI_RGM_DEFINITIONS -- ADDED BY SACSETHI ON 30-01-2007 FOR BUG 5631784
   WHERE regime_id = p_regime_id;
  lv_regime  JAI_RGM_DEFINITIONS.regime_code%TYPE;

  BEGIN
     OPEN cur_regime_code;                       /* 4245365*/
    FETCH cur_regime_code INTO lv_regime;
    CLOSE cur_regime_code;
  IF lv_regime IN  ('SERVICE')  THEN           /*6835541.removed VAT*/
     UPDATE jai_Rgm_trx_records
     SET    settlement_id = p_settlement_id
    /*Bug 5879769 bduvarag*/
      WHERE organization_id   = p_org_id
     AND location_id       = p_location_id
     AND regime_code       = lv_regime
     AND trunc(transaction_date) <=  p_balance_date  /*bug 9445836*/
     AND settlement_id IS NULL; /* added by ssawant for bug 5662296*/

  ELSIF lv_regime IN ('VAT') THEN /*6835541*/

         UPDATE jai_Rgm_trx_records
            SET settlement_id = p_settlement_id
          WHERE  (organization_id,location_id) in
               (SELECT organization_id,location_id
                  FROM JAI_RGM_ORG_REGNS_V
                 WHERE registration_id = p_regn_id
                   AND attribute_value = nvl(p_regn_no, attribute_value) -- 6835541. Added by Lakshmi Gopalsami
                   AND regime_code     = 'VAT'
                   AND organization_id = nvl(p_org_id,organization_id)
                   AND location_id     = nvl(p_location_id,location_id)
                )
            AND regime_code       = lv_regime --added for bug#8289991
            AND trunc(transaction_date) <= p_balance_date  /*bug 9445836*/
            AND settlement_id IS NULL;

  ELSIF lv_regime = jai_constants.tcs_regime THEN
     UPDATE JAI_RGM_REFS_ALL
        SET    SETTLEMENT_ID                = P_SETTLEMENT_ID
      WHERE  ORG_TAN_NO                   = P_TAN_NO AND
             ITEM_CLASSIFICATION          = P_ITEM_CLASSIFICATION AND
             TRUNC(SOURCE_DOCUMENT_DATE) <= P_BALANCE_DATE AND
             SETTLEMENT_ID IS NULL;
-- end 5631784
    END IF;
   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;
 END punch_settlement_id;


   PROCEDURE calculate_balances_for_ou(p_regime_id     number   ,
                                       p_balance_date  date     ,
                                       p_request_id    number   ,
                                       p_org_id        number   ,
                                       p_org_type      varchar2 ,
                                       p_regn_id       number   ,
                                       p_regn_no       varchar2 ,
                                       p_settlement_id number   ,
                                       p_called_from   varchar2,
                                       p_location_id   number default null, /*rchandan for bug#5642053*/
                                       p_service_type_code varchar2 default null -- bduvarag for Bug 5694855
                                      ) is
  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_tax_dist_pkg.calculate_balances_for_ou';
  lv_source_trx_type    jai_rgm_trx_records.source_trx_type%TYPE ;--rchandan for bug#4428980
  lv_reg_type           jai_rgm_registrations.registration_type%TYPE ;

    CURSOR c_regime_code IS
    SELECT regime_code
      FROM JAI_RGM_DEFINITIONS
     WHERE regime_id = p_regime_id;
     -- ld_trx_date  DATE; /* commented by ssawant for bug 5662296*/
     lv_regime_code JAI_RGM_DEFINITIONS.regime_code%TYPE;

/*Bug 5879769 bduvarag start*/

     CURSOR cur_inv_payment
     IS
     /*
      || This cursor is used to get the total invoice amount paid
      || when the last settlement was made
     */
      SELECT sum(credit_amount)
      FROM   jai_rgm_trx_records
      WHERE  regime_primary_regno = p_regn_no
      AND    source_trx_type      = 'Invoice Payment'
      AND    settlement_id        = ( SELECT MAX(jbal.settlement_id)
                                        FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                       WHERE jbal.settlement_id           = jstl.settlement_id
                                         AND jstl.primary_registration_no = p_regn_no
                                         AND jbal.party_type              = p_org_type
                                         AND jbal.party_id                = p_org_id
                                         AND nvl(jbal.location_id,-999)   = nvl(p_location_id,-999)
                                         AND jbal.settlement_id          <> nvl(p_settlement_id,-999)
                     );

      CURSOR cur_inv_payment_dist_io(cp_org_type   VARCHAR2,
                                  cp_org_id     NUMBER  ,
                                  cp_tax_type   VARCHAR2,
                                  cp_location_id NUMBER ,
                                  cp_service_type_code VARCHAR2
                                  )
      IS
      /*
      || This cursor is used to get the total invoice amount paid
      || when the last settlement was made. This is same as above cursor but it does not use registration no.
      || This cursor used when procedure is invoked from Distribution and so it does not have registration
      || details
      */
      SELECT credit_amount
      FROM   jai_rgm_trx_records
      WHERE  source_trx_type      = 'Invoice Payment'
      AND    service_type_code    = cp_service_type_code
      AND    settlement_id        = ( SELECT MAX(jbal.settlement_id)
                                      FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                      WHERE jbal.settlement_id           = jstl.settlement_id
                                       AND jbal.party_type              = cp_org_type
                                       AND jbal.party_id                = cp_org_id
                                       AND jbal.location_id             = nvl(cp_location_id,jbal.location_id)/*5694855*/
                                       AND jbal.tax_type                = cp_tax_type
                                       AND jbal.service_type_code       = cp_service_type_code
                                     );


      CURSOR cur_inv_payment_dist(cp_org_type   VARCHAR2,
                                  cp_org_id     NUMBER  ,
                                  cp_tax_type   VARCHAR2
                                  )
      IS
      /*
      || This cursor is used to get the total invoice amount paid
      || when the last settlement was made. This is same as above cursor but it does not use registration no.
      || This cursor used when procedure is invoked from Distribution and so it does not have registration
      || details
      */
      SELECT credit_amount
      FROM   jai_rgm_trx_records
      WHERE  /*regime_primary_regno = p_regn_no*/ -- Commented, Harshita for Bug 5694855
          source_trx_type      = 'Invoice Payment'
      AND    settlement_id        = ( SELECT MAX(jbal.settlement_id)
                                      FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                      WHERE jbal.settlement_id           = jstl.settlement_id
                                       AND jbal.party_type              = cp_org_type
                                       AND jbal.party_id                = cp_org_id
                                       AND jbal.tax_type                = cp_tax_type
                                     );

      CURSOR cur_balances  /* Modified by vumaasha for bug 7606212 */
      IS
      /*
      || This cursor is used to retrieve the sum of credit and debit balances as on
      || last settlement date for the given registration number,organization and location grouped at the tax type
      */
      SELECT sum(credit_balance) credit_balance,sum(debit_balance) debit_balance,jrs.settlement_id,jrs.tax_type,jrs.location_id
      FROM   jai_rgm_stl_balances jrs,
      (
       SELECT MAX(jbal.settlement_id) settlement_id,tax_type
       FROM  jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
       WHERE  jbal.settlement_id           = jstl.settlement_id
         AND  jstl.primary_registration_no = p_regn_no
         AND  jbal.party_type              = p_org_type
         AND  jbal.party_id                = p_org_id
         AND  NVL(jbal.location_id,-999)   = NVL(p_location_id,-999)
         AND  jbal.settlement_id          <> p_settlement_id/*This clause is used to exclude the current settlement*/
         GROUP BY jbal.tax_type
      )  sv
      WHERE
      jrs.settlement_id=sv.settlement_id
      AND jrs.tax_type= sv.tax_type
      GROUP BY jrs.settlement_id,jrs.tax_type,jrs.location_id ;

    CURSOR cur_last_settlement_id
      /* added this cursor for bug 7606212 by vumaasha */
      IS
      SELECT MAX(jbal.settlement_id)
                                        FROM  jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                       WHERE  jbal.settlement_id           = jstl.settlement_id
                                         AND  jstl.primary_registration_no = p_regn_no
                                         AND  jbal.party_type              = p_org_type
                                         AND  jbal.party_id                = p_org_id
                                         AND  NVL(jbal.location_id,-999)   = NVL(p_location_id,-999)
                                         AND  jbal.settlement_id          <> p_settlement_id;

 /*6835541..start*/

          CURSOR cur_inv_payment_vat(cp_organization_type VARCHAR2,
                                     cp_organization_id   NUMBER,
                                     cp_location_id       NUMBER
                                     )
          IS
          /*
          || This cursor is used to get the total invoice amount paid
          || when the last settlement was made for VAT regime
                 */
          SELECT sum(credit_amount)
                  FROM   jai_rgm_trx_records
                 WHERE  regime_primary_regno = p_regn_no
                   AND    source_trx_type      = 'Invoice Payment'
             AND    settlement_id        = ( SELECT MAX(jbal.settlement_id)
                                                     FROM jai_rgm_stl_balances jbal,
                                                          jai_rgm_settlements jstl,
                                                          jai_rgm_definitions jrg
                                                    WHERE jbal.settlement_id           = jstl.settlement_id
                                                      AND jrg.regime_id                = jstl.regime_id
                                                      AND jrg.regime_code              = 'VAT'
                                                      AND jstl.primary_registration_no = p_regn_no
                                                      AND jbal.party_type              = cp_organization_type
                                                      AND jbal.party_id                = cp_organization_id
                                                      AND jbal.location_id             = cp_location_id
                                                      AND jbal.settlement_id          <> nvl(p_settlement_id,-999) /*This clause is used to exclude the current settlement*/
                                                  );

         CURSOR cur_balances_vat(cp_organization_type VARCHAR2,
                                 cp_organization_id   NUMBER,
                                 cp_location_id       NUMBER
                                 )
         IS
      /* Modified by vumaasha for bug 7606212 */
         /*
         || This cursor is used to retrieve the sum of credit and debit balances as on
         || last settlement date for the given registration number,organization and location grouped at the tax type
         || for VAT
         */
         SELECT sum(credit_balance) credit_balance,sum(debit_balance) debit_balance,jrs.settlement_id,jrs.tax_type,jrs.location_id
    FROM   jai_rgm_stl_balances jrs,
      ( SELECT MAX(jbal.settlement_id) settlement_id,tax_type
         FROM  jai_rgm_stl_balances jbal,
         jai_rgm_settlements jstl,
         JAI_RGM_DEFINITIONS jrg
         WHERE  jbal.settlement_id           = jstl.settlement_id
         AND jrg.regime_id                 = jstl.regime_id
         AND jrg.regime_code               = 'VAT'
         AND  jstl.primary_registration_no = p_regn_no
         AND  jbal.party_type              = cp_organization_type
         AND  jbal.party_id                = cp_organization_id
         AND  jbal.location_id             = cp_location_id
         AND  jbal.settlement_id          <> p_settlement_id/*This clause is used to exclude the current settlement*/
         GROUP BY jbal.tax_type) sv
      WHERE
      jrs.settlement_id=sv.settlement_id
      AND jrs.tax_type= sv.tax_type
      GROUP BY jrs.settlement_id,jrs.tax_type,jrs.location_id ;

    CURSOR cur_last_settlement_id_vat(cp_organization_type VARCHAR2,
                                        cp_organization_id   NUMBER,
                                        cp_location_id       NUMBER
                                        )
      IS
      /* added this cursor for bug 7606212 by vumaasha */
      SELECT MAX(jbal.settlement_id)
                                        FROM  jai_rgm_stl_balances jbal,
                                              jai_rgm_settlements jstl,
                                              JAI_RGM_DEFINITIONS jrg
                                       WHERE  jbal.settlement_id           = jstl.settlement_id
                                         AND jrg.regime_id                 = jstl.regime_id
                                         AND jrg.regime_code               = 'VAT'
                                         AND  jstl.primary_registration_no = p_regn_no
                                         AND  jbal.party_type              = cp_organization_type
                                         AND  jbal.party_id                = cp_organization_id
                                         AND  jbal.location_id             = cp_location_id
                                         AND  jbal.settlement_id          <> p_settlement_id;


   /*6835541..end*/

       /*start ...rchandan for bug#5694855*/

       CURSOR c_delta_rec( cp_regime_id         NUMBER,
                           cp_regime_code       VARCHAR2,
                           cp_organization_type VARCHAR2,
                           cp_organization_id   NUMBER,
                           cp_location_id       NUMBER,
                           cp_tax_type          VARCHAR2
                          )
       IS
       SELECT
              organization_id                     ,
              location_id                         ,
              tax_type                            ,
              nvl(sum(debit_amount),0)  debit_amt ,
              nvl(sum(credit_amount),0) credit_amt
         FROM
              jai_rgm_trx_records
			 	WHERE trunc(transaction_date) <= p_balance_date  --changed the date condition for bug 9445836
          AND settlement_id  IS NULL
          AND source_trx_type   <> 'Invoice Payment'
          AND organization_id   = cp_organization_id
          AND location_id       = cp_location_id
          AND organization_type = cp_organization_type
          AND tax_type          = cp_tax_type
          AND regime_code       = cp_regime_code
          AND service_type_code = p_service_type_code
        GROUP BY
              organization_id,
              location_id    ,
              tax_type
        ORDER BY
              tax_type;

        /*added for bug#8289991*/
        CURSOR c_last_settlement_balance (cp_regime_id    IN NUMBER,
                                          cp_org_id       IN NUMBER,
                                          cp_location_id  IN NUMBER,
                                          cp_tax_type     IN VARCHAR2)
        IS
        SELECT sum(debit_balance), sum(credit_balance)
          FROM JAI_RGM_STL_BALANCES
         WHERE party_id                      = cp_org_id
           AND location_id                   = cp_location_id
           AND tax_type                      = cp_tax_type
           AND settlement_id                 = (SELECT MAX(jbal.settlement_id)
                                                  FROM JAI_RGM_STL_BALANCES jbal,
                                                       jai_rgm_settlements jstl
                                                 WHERE jbal.settlement_id            = jstl.settlement_id
                                                   AND jstl.regime_id                = cp_regime_id
                                                   AND party_id                      = cp_org_id
                                                   AND location_id                   = cp_location_id
                                                   AND tax_type                      = cp_tax_type);

        r_delta_rec     c_delta_rec%ROWTYPE;
/*Bug 5879769 bduvarag end*/
    lv_party_type varchar2(30) ; --:= 'OU';  File.Sql.35 BY Brathod
    ln_settled_debit_balance number  ;
    ln_settled_credit_balance number ;
    -- lv_inv_amount   jai_rgm_trx_records.credit_amount%type;/* commented by ssawant for bug 5662296*/
ln_invoice_amount           jai_rgm_trx_records.credit_amount%type;
cr_balance                  jai_rgm_stl_balances.credit_balance%type;  /*added by ssawant for bug 5662296*/
dr_balance                  jai_rgm_stl_balances.debit_balance%type;   /*added by ssawant for bug 5662296*/
ln_settled_flag             NUMBER(1) := 0;/*added by ssawant for bug 5662296*/
v_last_settlement_id        NUMBER;  /* added for bug 7606212 by vumaasha */
v_credit_exceeds_debit      BOOLEAN:=FALSE;/* added by vumaasha for bug 7606212 */

     lv_temp_insert      varchar2(1);--Added by Eric Ma for bug 8671217 on  Dec-19-2009
     ln_crbal_considered number;     --Added by Eric Ma for bug 8671217 on  Dec-19-2009
   BEGIN
        lv_party_type := 'OU';  -- File.Sql.35 by Brathod
        /* first get the balance as on the last settlement date for the passed org id
        get the records from the repository for the org id for the dates between the last settlement date and
        the date passed
        put the plus into one type of variable and minus into another type of variable
        finally do the arithmatic on these two variables.
        */
       OPEN c_regime_code;
       FETCH c_regime_code INTO lv_regime_code;
       CLOSE c_regime_code;

IF p_called_from = 'SETTLEMENT' THEN
       IF lv_regime_code = jai_constants.service_regime THEN
           lv_source_trx_type := 'Invoice Payment';--rchandan for bug#4428980
           FOR delta_rec in
           (
            SELECT a.organization_id                      ,
               a.location_id                          ,/*Bug 5879769 bduvarag*/
                   a.tax_type                             ,
                   nvl(sum(a.debit_amount),0)  debit_amt  ,
                   nvl(sum(a.credit_amount),0) credit_amt
              FROM jai_rgm_trx_records a
              WHERE trunc(transaction_date) <= p_balance_date --date condition changed for bug 9445836
               AND a.settlement_id  IS NULL/*rchandan for bug#5642053*/
               AND  a.regime_code      = lv_regime_code/*5694855*/
               AND a.organization_type = p_org_type/*5694855*/
               AND a.organization_id   = nvl(p_org_id,a.organization_id )
               AND a.location_id       = p_location_id/*5694855*/
               AND  a.source_trx_type  <> 'Invoice Payment'
             GROUP BY a.organization_id ,
                      a.location_id     ,/*5694855*/
                      a.tax_type
                )/*Bug 5879769 bduvarag*/
           LOOP
            /*
             insert the tax types for every operating unit for the delta period
             ie .. between the last settlement date and the date of transfer.
             get the debit balance and credit balance as on the last settlement for a given operating unit and tax type
             and add the value in this table.
             -- API call to settlement process.
            */
            --ld_trx_date := jai_cmn_rgm_settlement_pkg.get_last_settlement_date(delta_rec.organization_id) + 1;/* commented by ssawant for bug 5662296*/
            ln_settled_debit_balance  :=0;
            ln_settled_credit_balance :=0;
            /* Commented for bug#8289991
            v_credit_exceeds_debit:= FALSE;/* added by vumaasha for bug 7606212 */

            /* Modified below procedure call by vumaasha for bug 7606212
            jai_cmn_rgm_settlement_pkg.GET_LAST_BALANCE_AMOUNT(
                                     pn_regime_id     => p_regime_id,
                                     pn_org_id        => delta_rec.organization_id ,
                                     pn_location_id   => delta_rec.location_id ,
                                     pv_tax_type      => delta_rec.tax_type        ,
                                     pn_debit_amount  => ln_settled_debit_balance  ,
                                     pn_credit_amount => ln_settled_credit_balance
                                    );

            /*   OPEN cur_inv_payment(delta_rec.organization_id,NULL,delta_rec.tax_type,'Invoice Payment');
            FETCH cur_inv_payment INTO lv_inv_amount;
            CLOSE cur_inv_payment;*/

            --added the following for bug#8289991
            OPEN c_last_settlement_balance( p_regime_id,
                                            delta_rec.organization_id,
                                            delta_rec.location_id,
                                            delta_rec.tax_type);
            FETCH c_last_settlement_balance INTO ln_settled_debit_balance,ln_settled_credit_balance;
            CLOSE c_last_settlement_balance;
            --bug#8289991,end

            /*COMMENTED THE FOLLOWING FOR BUG#8289991,START
            -- start additions by nprashar- bug#6348081
            -- getting the invoice payment amount for every service type of the last settlement.
                 ln_invoice_amount := 0;
                 cr_balance        := 0;
                 dr_balance        := 0;

                 OPEN cur_inv_payment;   --6348081
                 FETCH cur_inv_payment INTO ln_invoice_amount;
                 CLOSE cur_inv_payment;

               /* added by vumaasha for bug 7606212
               OPEN  cur_last_settlement_id;
                 FETCH cur_last_settlement_id INTO  v_last_settlement_id;
                 CLOSE cur_last_settlement_id;

                 FOR rec_balances IN cur_balances
                 LOOP
                /* If condition modified by vumaasha for bug 7606212
                    IF nvl(rec_balances.debit_balance,0) - nvl(rec_balances.credit_balance,0) >= 0
                         AND rec_balances.settlement_id = v_last_settlement_id THEN

                           /*
                Check condition on settlement id is added to ensure that debit balances from the last made settlement are only considered.
                           || This check is put so that only the balances of those tax types which have net balance as
                           || debit are only considered.

                                       cr_balance := nvl(cr_balance,0) + nvl(rec_balances.credit_balance,0);
                                       dr_balance := nvl(dr_balance,0) + nvl(rec_balances.debit_balance,0);

                ELSIF ( nvl(rec_balances.credit_balance,0) - nvl(rec_balances.debit_balance,0) >0 ) AND rec_balances.tax_type = delta_rec.tax_type
                           AND ( rec_balances.location_id = delta_rec.location_id) THEN


                                       ln_settled_credit_balance:= ln_settled_credit_balance-ln_settled_debit_balance;
                                       ln_settled_debit_balance := 0;
                                       v_credit_exceeds_debit:=TRUE;

                 END IF;

                 END LOOP;

                 IF ( cr_balance + nvl(ln_invoice_amount,0) - dr_balance < 1 )
                AND NOT(v_credit_exceeds_debit) THEN
               /* If condition modified by vumaasha for bug 7606212*/
                 /*
                 ||If the balances at the last settlement balance are settled then flag is one, else flag is zero
                 ||if flag is one then balances at last settlement date are not carried forward. Otherwise they
                 ||are carried forward to the current settlement

                   ln_settled_flag := 1;
                 ELSE
                   ln_settled_flag := 0;
                 END IF;

            -- End additions by nprashar- bug#6348081

            IF ln_settled_flag = 1 THEN /*added by ssawant for bug 5662296
               ln_settled_debit_balance  :=0;
               ln_settled_credit_balance :=0;
             END IF;
             BUG#8289991,END       */

            --added the following for bug#8289991
            IF nvl(ln_settled_debit_balance,0) >= nvl(ln_settled_credit_balance,0) THEN
              ln_settled_debit_balance := 0;
              ln_settled_credit_balance := 0;
            ELSE
              ln_settled_credit_balance := ln_settled_credit_balance - ln_settled_debit_balance;
              ln_settled_debit_balance := 0;
            END IF;
            --bug#8289991, end

             insert_records_into_temp(
                    p_request_id   => p_request_id        ,
                    p_regime_id    => p_regime_id         ,
                    p_party_type   => p_org_type       ,
                    p_party_id     => delta_rec.organization_id  ,
                    p_location_id  => delta_rec.location_id                ,
                    p_bal_date     => p_balance_date      ,
                    p_tax_type     => delta_rec.tax_type  ,
                    p_debit_amt    => nvl(ln_settled_debit_balance,0) + delta_rec.debit_amt  ,    --4557267
                    p_credit_amt   => nvl(ln_settled_credit_balance,0) + delta_rec.credit_amt,     --4557267
                    /* Bug 4568078. Added by Lakshmi Gopalsami */
                    p_pla_balance  => NULL,
                    p_service_type_code => NULL /* modified by vumaasha for bug 7606212*/
                   );
           END LOOP;
           punch_settlement_id(p_regime_id => p_regime_id,
                               p_settlement_id => p_settlement_id ,
                               p_regn_id       => p_regn_id       ,
                               p_balance_date  => p_balance_date,
             p_location_id   => p_location_id, /*Bug 5879769 bduvarag*/
             p_org_id        => p_org_id /*added by ssawant for bug 5662296*/
                                          );
        ELSIF lv_regime_code = jai_constants.vat_regime THEN        /* 4245365*/
        /*Even though VAT is for IO ,  balances are calculated similar to an OU. i.e from
           jai_rgm_trx_records. hence the implementation is done in this procedure only*/
            lv_source_trx_type := 'Invoice Payment';--rchandan for bug#4428980
               FOR delta_rec in
                   (
                    SELECT
                     b.regime_id                            ,
                     a.organization_id                      ,
                     a.location_id                          ,
                     a.tax_type                             ,
                     a.organization_type                    , /*6835541*/
                     nvl(sum(a.debit_amount),0)  debit_amt  ,
                     nvl(sum(a.credit_amount),0) credit_amt
                    FROM
                     jai_rgm_trx_records a, JAI_RGM_ORG_REGNS_V b
                    WHERE  trunc(transaction_date) <= p_balance_date   --date condition changed for bug 9445836
                      AND  a.settlement_id  IS NULL  --added by csahoo for bug#6235971
                      AND  b.regime_id         = p_regime_id/*5694855 bduvarag*/
                      AND  a.regime_code       = lv_regime_code/*5694855 bduvarag*/
                      AND  a.organization_id = b.organization_id
                      AND  a.location_id     = b.location_id
                      AND  a.organization_type = b.organization_type
                      AND  b.registration_id =  p_regn_id
                      AND  a.organization_id = nvl(p_org_id,a.organization_id )
                      AND  a.organization_type = nvl(p_org_type,a.organization_type)
                      AND  b.attribute_value = p_regn_no
                      AND  a.location_id       = nvl(p_location_id,a.location_id)/*rchandan for bug#6835541. Added nvl*/
                      AND  a.source_trx_type <> lv_source_trx_type--rchandan for bug#4428980
                      GROUP BY a.organization_id , a.tax_type,a.location_id,b.regime_id,a.organization_type /*6835541. added organization_type*/
                   )
                   LOOP
                    /*
                     insert the tax types for every IO for the delta period
                     ie .. between the last settlement date and the date of transfer.
                     get the debit balance and credit balance as on the last settlement for a given IO , Location and tax type
                     and add the value in this table.
                     -- API call to settlement process.
                    */
                    --ld_trx_date := jai_cmn_rgm_settlement_pkg.get_last_settlement_date(delta_rec.regime_id,delta_rec.organization_id,delta_rec.location_id) + 1; /* commented by ssawant for bug 5662296*/
                    ln_settled_debit_balance  :=0;
                    ln_settled_credit_balance :=0;
          v_credit_exceeds_debit:= FALSE;/* added by vumaasha for bug 7606212*/

                    jai_cmn_rgm_settlement_pkg.GET_LAST_BALANCE_AMOUNT(
                               pn_regime_id     => delta_rec.regime_id,
                               pn_org_id        => delta_rec.organization_id ,
                               pn_location_id   => delta_rec.location_id ,
                               pv_tax_type      => delta_rec.tax_type        ,
                               pn_debit_amount  => ln_settled_debit_balance  ,
                               pn_credit_amount => ln_settled_credit_balance
                              );

                    /*6835541..start*/
                    ln_invoice_amount := 0;
                    cr_balance        := 0;
                    dr_balance        := 0;

                    OPEN cur_inv_payment_vat(cp_organization_type => delta_rec.organization_type,
                                             cp_organization_id   => delta_rec.organization_id,
                                             cp_location_id       => delta_rec.location_id);
          FETCH cur_inv_payment_vat INTO ln_invoice_amount;
                    CLOSE cur_inv_payment_vat;

          /* Added for bug 7606212 by vumaasha */
          OPEN cur_last_settlement_id_vat(cp_organization_type => delta_rec.organization_type,
                                                    cp_organization_id   => delta_rec.organization_id,
                                                    cp_location_id       => delta_rec.location_id
                                                    );
                    FETCH cur_last_settlement_id_vat INTO v_last_settlement_id;
                    CLOSE cur_last_settlement_id_vat;

                    FOR rec_balances IN cur_balances_vat(cp_organization_type => delta_rec.organization_type,
                                                         cp_organization_id   => delta_rec.organization_id,
                                                         cp_location_id       => delta_rec.location_id
                                                         )
                    LOOP
                      IF nvl(rec_balances.debit_balance,0) - nvl(rec_balances.credit_balance,0) >= 0
                         AND rec_balances.settlement_id = v_last_settlement_id THEN
                         /* If condition modified by vumaasha for bug 7606212
             Check condition on settlement id is added to ensure that debit balances from the last made settlement are only considered.
             */
                         /*
                         || This check is put so that only the balances of those tax types which have net balance as
                         || debit are only considered.
                         */
                           cr_balance := nvl(cr_balance,0) + nvl(rec_balances.credit_balance,0);
                           dr_balance := nvl(dr_balance,0) + nvl(rec_balances.debit_balance,0);

                         ELSIF ( nvl(rec_balances.credit_balance,0) - nvl(rec_balances.debit_balance,0) >0 ) AND rec_balances.tax_type = delta_rec.tax_type
             AND ( rec_balances.location_id = delta_rec.location_id) THEN
              /* elsif condition added by vumaasha for bug 7606212*/
                           ln_settled_credit_balance:= ln_settled_credit_balance-ln_settled_debit_balance;
                           ln_settled_debit_balance := 0;
                           v_credit_exceeds_debit:=TRUE;

                         END IF;
                  END LOOP;


                    IF ( cr_balance + nvl(ln_invoice_amount,0) - dr_balance < 1 )
              AND NOT(v_credit_exceeds_debit) THEN
                 /*
                        ||If the balances at the last settlement balance are settled then flag is one, else flag is zero
                        ||if flag is one then balances at last settlement date are not carried forward. Otherwise they
                        ||are carried forward to the current settlement
                        */
                        ln_settled_flag := 1;
                   ELSE
                        ln_settled_flag := 0;
                   END IF;
              /*6835541..end*/
                    /* OPEN cur_inv_payment(delta_rec.organization_id,delta_rec.location_id,delta_rec.tax_type,'Invoice Payment');
                     FETCH cur_inv_payment INTO lv_inv_amount;
                     CLOSE cur_inv_payment;*/
                     IF ln_settled_flag = 1 THEN /*added by ssawant for bug 5662296*/
                        ln_settled_debit_balance  :=0;
                        ln_settled_credit_balance :=0;
                     END IF;
                     insert_records_into_temp(
                            p_request_id   => p_request_id        ,
                            p_regime_id    => p_regime_id         ,
                            p_party_type   => delta_rec.organization_type,/*6835541*/
                            p_party_id     => delta_rec.organization_id  ,
                            p_location_id  => delta_rec.location_id  ,
                            p_bal_date     => p_balance_date      ,
                            p_tax_type     => delta_rec.tax_type  ,
                            p_debit_amt    => nvl(ln_settled_debit_balance,0) + delta_rec.debit_amt  ,   --4557267
                            p_credit_amt   => nvl(ln_settled_credit_balance,0) + delta_rec.credit_amt,    --4557267
          /* Bug 4568078. Added by Lakshmi Gopalsami */
          p_pla_balance  => NULL
                           );

                              ln_crbal_considered :=  nvl( ln_crbal_considered,0)+ nvl(ln_settled_credit_balance,0); --Added by Eric Ma for bug 8671217 on  Dec-19-2009
                     -- lv_temp_insert:='Y';     --bug# 8671217 12-aug-2009
                   END LOOP;


--Added by Eric Ma for bug 8333082 on Dec-19-2009,Begin
--------------------------------------------------------------------------------------
         IF ( p_org_id IS NULL AND p_location_id IS NULL )
         --and  nvl(lv_temp_insert,'N')<>'Y' THEN        --added by eric for bug#8671217 on Dec-19-2009
         THEN
          /*  If condition added for the bug   8333082 */

           populate_all_orgs_vat(  p_regn_no => p_regn_no,
                                   p_regn_id => p_regn_id ,
                                   p_regime_id => p_regime_id ,
                                   p_request_id => p_request_id,
                                   p_balance_date => p_balance_date,
                                   p_org_type => p_org_type  ,
                                   p_settlement_id=>p_settlement_id ,       --added by eric for bug#8671217 on Dec-19-2009
                                   p_cramt_considered=> ln_crbal_considered --added by eric for bug#8671217 on Dec-19-2009
                                );

         END IF;
         punch_settlement_id(p_regime_id => p_regime_id,
                             p_settlement_id => p_settlement_id ,
                             p_regn_id       => p_regn_id       ,
                             p_balance_date  => p_balance_date,
                             p_org_id        => p_org_id        ,/*added by ssawant for bug 5662296*/
                             p_location_id   => p_location_id,   /*added by ssawant for bug 5662296*/
                             p_regn_no        => p_regn_no /*6835541*/
                            );
       END IF;
--------------------------------------------------------------------------------------
--Added by Eric Ma for bug 8333082 on Dec-19-2009,End


/*Bug 5879769 bduvarag start*/
     ELSIF p_called_from = 'DISTRIBUTE_IO' THEN

       FOR tax_types_rec in
        (
          SELECT regime_id,
                 attribute_code tax_type
            FROM jai_rgm_org_regns_v
           WHERE organization_id   = p_org_id
             AND location_id       = p_location_id
             AND organization_type = p_org_type
             AND registration_type = jai_constants.regn_type_tax_types
             AND regime_code       = lv_regime_code
         )
         LOOP

            r_delta_rec := NULL;
            OPEN c_delta_rec(tax_types_rec.regime_id,
                             lv_regime_code         ,
                             p_org_type             ,
                             p_org_id               ,
                             p_location_id          ,
                             tax_types_rec.tax_type
                             );
            FETCH c_delta_rec INTO r_delta_rec;
            CLOSE c_delta_rec;

            ln_settled_debit_balance  :=0;
            ln_settled_credit_balance :=0;
          jai_cmn_rgm_settlement_pkg.GET_LAST_BALANCE_AMOUNT(
                     pn_regime_id     => tax_types_rec.regime_id   ,
                     pn_org_id        => p_org_id                  ,
                     pn_location_id   => p_location_id             ,
                     pv_tax_type      => tax_types_rec.tax_type    ,
                     pn_debit_amount  => ln_settled_debit_balance  ,
                     pn_credit_amount => ln_settled_credit_balance ,
                     pv_service_type_code => p_service_type_code
                    );
           ln_invoice_amount := 0;

           OPEN cur_inv_payment_dist_io(p_org_type,p_org_id,tax_types_rec.tax_type,p_location_id,p_service_type_code );
           FETCH cur_inv_payment_dist_io INTO ln_invoice_amount;
           CLOSE cur_inv_payment_dist_io;

          ln_settled_credit_balance := nvl(ln_settled_credit_balance,0) + nvl(ln_invoice_amount,0);/*rchandan for bug#5642053*/
          insert_records_into_temp(
                                   p_request_id   => p_request_id        ,
                                   p_regime_id    => p_regime_id         ,
                                   p_party_type   => p_org_type          ,
                                   p_party_id     => p_org_id  ,
                                   p_location_id  => p_location_id  ,
                                   p_bal_date     => p_balance_date      ,
                                   p_tax_type     => tax_types_rec.tax_type  ,
                                   -- modified for bug#8702609, start
                                   p_debit_amt    => nvl(r_delta_rec.debit_amt,0)  ,
                                   p_credit_amt   => nvl(r_delta_rec.credit_amt,0) ,
                                   -- bug#8702609, end
                                   p_pla_balance  => NULL ,
                                   p_service_type_code => p_service_type_code
                                   );
        END LOOP;
      ELSIF p_called_from = 'DISTRIBUTE_OU' THEN
/*Bug 5879769 bduvarag end*/
        lv_reg_type  := 'TAX_TYPES';
        FOR delta_rec in
        (
          SELECT
                 a.organization_id                     ,
                 a.tax_type                            ,
                 nvl(sum(debit_amount),0)  debit_amt   ,
                 nvl(sum(credit_amount),0) credit_amt
            FROM
/*Bug 5879769 bduvarag start*/
                 jai_rgm_trx_records a
           WHERE trunc(transaction_date) <= p_balance_date  --date condition removed for bug 9445836
             AND a.settlement_id  IS NULL
             AND a.source_trx_type   <> 'Invoice Payment'
             AND a.organization_id   = p_org_id
             AND a.organization_type = p_org_type/*5694855*/
           GROUP BY
                    a.organization_id,
                    a.tax_type
           ORDER BY
                    a.tax_type  desc
        )/*Bug 5879769 bduvarag end*/
        LOOP
          ln_settled_debit_balance  :=0;
          ln_settled_credit_balance :=0;
          jai_cmn_rgm_settlement_pkg.GET_LAST_BALANCE_AMOUNT(
                                                         pn_org_id        => delta_rec.organization_id ,
                                                         pv_tax_type      => delta_rec.tax_type        ,
                                                         pn_debit_amount  => ln_settled_debit_balance  ,
                                                         pn_credit_amount => ln_settled_credit_balance
                                                        );
-- start block added by ssawant for bug 5662296
           ln_invoice_amount := 0;

                    OPEN cur_inv_payment_dist('OU',delta_rec.organization_id,delta_rec.tax_type);
                    FETCH cur_inv_payment_dist INTO ln_invoice_amount;
                    CLOSE cur_inv_payment_dist;

                    ln_settled_credit_balance := nvl(ln_settled_credit_balance,0) + nvl(ln_invoice_amount,0);
-- end block added by ssawant for bug 5662296

          insert_records_into_temp(
                                   p_request_id   => p_request_id        ,
                                   p_regime_id    => p_regime_id         ,
                                   p_party_type   => p_org_type       ,/*Bug 5879769 bduvarag*/
                                   p_party_id     => delta_rec.organization_id  ,
                                   p_location_id  => null                ,
                                   p_bal_date     => p_balance_date      ,
                                   p_tax_type     => delta_rec.tax_type  ,
                                   -- modified for bug#8702609, start
                                   p_debit_amt    => nvl(delta_rec.debit_amt,0)  ,
                                   p_credit_amt   => nvl(delta_rec.credit_amt,0) ,
                                   -- bug#8702609, end
                                   /* Bug 4568078. Added by Lakshmi Gopalsami */
                                   p_pla_balance  => NULL
                                   );
        END LOOP;
      END IF;
   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;
    END calculate_balances_for_ou;




--------------------------------------------------------------------------------------------------
-- Added by sacsethi for bug 5631784 on 30-01-2007
-- FOR TCS
-- START -- 5631784
--------------------------------------------------------------------------------------------------
PROCEDURE CALCULATE_RGM_BALANCES( P_REGIME_ID       NUMBER   ,
          P_BALANCE_DATE        DATE     ,
          P_REQUEST_ID          NUMBER ,
          P_ORG_ID              NUMBER   ,
          P_REGN_ID             VARCHAR2 ,
          P_TAN_NO              VARCHAR2 ,
          P_ITEM_CLASSIFICATION VARCHAR2 ,
          P_SETTLEMENT_ID       NUMBER   ,
          P_CALLED_FROM         VARCHAR2)
IS

  CURSOR C_REGIME_CODE IS
  SELECT REGIME_CODE
    FROM JAI_RGM_DEFINITIONS
   WHERE REGIME_ID = P_REGIME_ID;
   -- LD_TRX_DATE    DATE; /*commented by ssawant for bug 5662296*/
   LV_REGIME_CODE JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;


BEGIN

    OPEN C_REGIME_CODE;
    FETCH C_REGIME_CODE INTO LV_REGIME_CODE;
    CLOSE C_REGIME_CODE;

  IF LV_REGIME_CODE = JAI_CONSTANTS.TCS_REGIME THEN
    FOR DELTA_REC IN
       (
        SELECT SUM(DECODE(SIGN(JRT.TAX_AMT),-1,-1 * JRT.TAX_AMT,1,0)) CREDIT_AMOUNT,
               SUM(DECODE(SIGN(JRT.TAX_AMT),1,JRT.TAX_AMT,-1,0))      DEBIT_AMOUNT,
               DECODE(JRT.TAX_TYPE,'TCS_SURCHARGE_CESS','TCS_CESS',JRT.TAX_TYPE) TAX_TYPE,
               JRR.ORGANIZATION_ID,
               JRR.REGIME_ID
        FROM  JAI_RGM_REFS_ALL    JRR,
              JAI_RGM_TAXES       JRT,
              --JAI_RGM_ORG_REGNS_V JOR	  --commented for bug# 9005474
	      JAI_RGM_REGISTRATIONS JOR --added for bug#9005474
        WHERE JRR.TRX_REF_ID            = JRT.TRX_REF_ID
  --      AND   JRR.ORGANIZATION_ID       = JOR.ORGANIZATION_ID	     commented for bug# 9005474
        AND   JOR.REGIME_ID             = JRR.REGIME_ID
        AND   JOR.REGISTRATION_TYPE     = 'TAX_TYPES'
        AND   JRT.TAX_TYPE              = JOR.ATTRIBUTE_CODE
        AND   JRR.REGIME_ID             = P_REGIME_ID
        AND   JRR.ORG_TAN_NO            = P_TAN_NO
	AND   JRR.ORGANIZATION_ID=NVL(P_ORG_ID,JRR.ORGANIZATION_ID)--added for bug 9005474
        AND   JRR.ITEM_CLASSIFICATION   = P_ITEM_CLASSIFICATION
        AND   JRR.SETTLEMENT_ID IS NULL
        AND   TRUNC(JRR.SOURCE_DOCUMENT_DATE) <= P_BALANCE_DATE
        GROUP BY DECODE(JRT.TAX_TYPE,'TCS_SURCHARGE_CESS','TCS_CESS',JRT.TAX_TYPE),
        JRR.ORGANIZATION_ID,JRR.REGIME_ID
      ) LOOP
  INSERT_RECORDS_INTO_TEMP(
          P_REQUEST_ID   => P_REQUEST_ID        ,
          P_REGIME_ID    => P_REGIME_ID         ,
          P_PARTY_TYPE   => 'IO'       ,
          P_PARTY_ID     => DELTA_REC.ORGANIZATION_ID  ,
          P_LOCATION_ID  => NULL                ,
          P_BAL_DATE     => P_BALANCE_DATE      ,
          P_TAX_TYPE     => DELTA_REC.TAX_TYPE  ,
          P_DEBIT_AMT    => DELTA_REC.DEBIT_AMOUNT  ,
          P_CREDIT_AMT   => DELTA_REC.CREDIT_AMOUNT ,
                    P_PLA_BALANCE  => NULL
              );
    END LOOP;
     PUNCH_SETTLEMENT_ID(  P_REGIME_ID           => P_REGIME_ID,
           P_SETTLEMENT_ID       => P_SETTLEMENT_ID ,
           P_REGN_ID             => P_REGN_ID       ,
           P_BALANCE_DATE        => P_BALANCE_DATE  ,
           P_TAN_NO              => P_TAN_NO,
           P_ITEM_CLASSIFICATION => P_ITEM_CLASSIFICATION
            );
  END IF;
-- END 5631784
END CALCULATE_RGM_BALANCES;
--------------------------------------------------------------------------------------



 PROCEDURE get_balances(p_request_id          NUMBER                ,
                        p_balance_date        DATE                  ,
                        p_Called_from         VARCHAR2              ,
                        p_regime_id           NUMBER   Default NULL ,
                        p_regn_no             VARCHAR2 default NULL ,
                        p_regn_id             NUMBER   default NULL ,
                        p_org_id              NUMBER   default NULL ,
                        p_org_type            VARCHAR2 default NULL ,
                        p_settlement_id       NUMBER   default NULL ,
      P_ITEM_CLASSIFICATION VARCHAR2 DEFAULT NULL,-- Added by sacsethi for bug 5631784 on 30-01-2007
                        p_transfer_type       VARCHAR2 default NULL ,/*Bug 5879769 bduvarag*/
                        p_service_type_code   VARCHAR2 default NULL, /*Bug 5879769 bduvarag*/
      p_location_id         NUMBER   DEFAULT NULL /*added by ssawant for bug 5662296  */
                        )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
-- Added by sacsethi for bug 5631784 on 30-01-2007
-- for TCS

   CURSOR CUR_REGIME_CODE(CP_REGIME_ID NUMBER)
    IS  SELECT REGIME_CODE
  FROM JAI_RGM_DEFINITIONS
  WHERE REGIME_ID = CP_REGIME_ID;
   LV_REGIME_CODE JAI_RGM_DEFINITIONS.REGIME_CODE%TYPE;



 BEGIN

  IF p_called_from = 'SETTLEMENT' THEN
-- Added by sacsethi for bug 5631784 on 30-01-2007
--START 5631784
-- CURSOR AND CALCULATE RGM BALANCES IS ADDED TO PROVIDE TCS FUNCTIONALITY
    OPEN CUR_REGIME_CODE( P_REGIME_ID);
    FETCH CUR_REGIME_CODE INTO LV_REGIME_CODE;
    CLOSE CUR_REGIME_CODE;
    IF LV_REGIME_CODE = JAI_CONSTANTS.TCS_REGIME THEN
    calculate_rgm_balances( p_regime_id           =>   p_regime_id          ,
          p_balance_date        =>   p_balance_date       ,
          p_request_id          =>   p_request_id         ,
          p_org_id              =>   p_org_id             ,
          p_regn_id             =>   p_regn_id            ,
          p_tan_no              =>   p_regn_no            ,
          p_item_classification =>   p_item_classification,
          p_settlement_id       =>   p_settlement_id      ,
          p_called_from         =>   p_called_from
             ) ;
--END 5631784
    ELSE
     CALCULATE_BALANCES_FOR_OU(P_REGIME_ID        =>   P_REGIME_ID    ,
                               P_BALANCE_DATE     =>   P_BALANCE_DATE ,
                               P_REQUEST_ID       =>   P_REQUEST_ID   ,
                               P_ORG_ID           =>   P_ORG_ID       ,
                               P_ORG_TYPE         =>   P_ORG_TYPE     ,
                               P_REGN_ID          =>   P_REGN_ID      ,
                               P_REGN_NO          =>   P_REGN_NO      ,
                               P_SETTLEMENT_ID    =>   P_SETTLEMENT_ID,
                               P_CALLED_FROM      =>   P_CALLED_FROM,
                              p_location_id      =>   p_location_id /*rchandan for bug#5662296*/
                              );
    END IF ;
  END IF;
  IF p_called_from  = 'DISTRIBUTION' THEN
/*Bug 5879769 bduvarag start*/
    IF p_transfer_type NOT IN ('S-S') THEN  -- added, Harshita for Bug 5694855

      calculate_balances_for_io(p_regime_id ,  p_balance_date , p_request_id, p_service_type_code);
    END IF ;
    IF p_transfer_type = 'BT' THEN -- added, Harshita for Bug 5694855

      /*
      ||The loop is commented by rchandan for Bug 5694855
      ||This loop is no more required as OU can only be a source and not a destination now
      ||We have the parameters for the OU
      */
    /*  FOR ou_rec in
      (
       SELECT organization_id  party_id     ,
              'OU'             party_type   ,
              set_of_books_id
       FROM
              hr_operating_units
      )
      LOOP
        IF  jai_cmn_utils_pkg.check_jai_exists(P_CALLING_OBJECT      => 'JAI_TAX_DISTRIB' ,
                                        P_SET_OF_BOOKS_ID     => ou_rec.set_of_books_id
                                       ) = TRUE
        THEN*/
/*Bug 5879769 bduvarag end*/
          calculate_balances_for_ou(p_regime_id        =>   p_regime_id        ,
                                    p_balance_date     =>   p_balance_date     ,
                                    p_request_id       =>   p_request_id       ,
                                    p_org_id           =>   p_org_id    ,/*Bug 5879769 bduvarag*/
                                    p_org_type         =>   'OU' ,/*Bug 5879769 bduvarag*/
                                    p_regn_id          =>   NULL               ,
                                    p_regn_no          =>   NULL               ,
                                    p_settlement_id    =>   NULL               ,
                                    p_called_from      =>   'DISTRIBUTE_OU'    ,/*Bug 5879769 bduvarag*/
                                    p_service_type_code =>  p_service_type_code /*Bug 5879769 bduvarag*/
                                   );
/*Bug 5879769 bduvarag start*/
    /*    END IF;
      END LOOP;*/
END IF;
    FOR io_rec IN
    ( select distinct
      organization_id, location_id
      from JAI_RGM_ORG_REGNS_V
      where organization_type = 'IO'
      and regime_code = 'SERVICE'
    )
    LOOP

          calculate_balances_for_ou(p_regime_id        =>   p_regime_id        ,
                                    p_balance_date     =>   p_balance_date     ,
                                    p_request_id       =>   p_request_id       ,
                                    p_org_id           =>   io_rec.organization_id ,
                                    p_org_type         =>   'IO'               ,
                                    p_regn_id          =>   NULL               ,
                                    p_regn_no          =>   NULL               ,
                                    p_settlement_id    =>   NULL               ,
                                    p_called_from      =>   'DISTRIBUTE_IO'    ,
                                    p_location_id      =>   io_rec.location_id ,
                                    p_service_type_code =>  p_service_type_code
                                   );
    END LOOP ;

/*Bug 5879769 bduvarag end*/
  END IF;
  COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
   raise_application_error (-20102 ,' Error Occured is ' || sqlerrm);
 END get_balances;




  PROCEDURE insert_records_into_register
                                      (
                                       p_repository_id OUT NOCOPY NUMBER   ,
                                       p_regime_id                  NUMBER   ,
                                       p_from_party_type            VARCHAR2 ,
                                       p_from_party_id              NUMBER   ,
                                       p_from_locn_id               NUMBER   ,
                                       p_from_tax_type              VARCHAR2 ,
                                       p_from_trx_amount            NUMBER   ,
                                       p_to_party_type              VARCHAR2 ,
                                       p_to_party_id                NUMBER   ,
                                       p_to_tax_type                VARCHAR2 ,
                                       p_to_trx_amount      IN OUT NOCOPY NUMBER   ,
                                       p_to_locn_id                 NUMBER   ,
                                       p_called_from                VARCHAR2 ,
                                       p_trx_date                   DATE     ,
                                       p_acct_req                   VARCHAR2 ,
                                       p_source                     VARCHAR2 ,
                                       P_SOURCE_TRX_TYPE            VARCHAR2 ,
                                       P_SOURCE_TABLE_NAME          VARCHAR2 ,
                                       p_source_doc_id              NUMBER   ,
                                       p_settlement_id              NUMBER   ,
                                       p_reference_id               NUMBER   ,
                                       p_process_flag OUT NOCOPY VARCHAR2 ,
                                       p_process_message OUT NOCOPY VARCHAR2 ,
                                       p_accounting_date            Date,
                                       p_from_service_type          VARCHAR2 default null, -- bduvarag for Bug 5694855
                                       p_to_service_type            VARCHAR2 default null -- bduvarag for Bug 5694855
                                      )
  is
   ln_repository_id   NUMBER;
   lv_acct_req_flag   VARCHAR2(10);
   lv_process_status  VARCHAR2(30);
   lv_process_message VARCHAR2(1996);
   ln_register_id     NUMBER;
   --lv_balancing_entry       VARCHAR2(1) DEFAULT NULL; /*Added  by nprashar for bug 7525691*/ commented for bug#6773684
   ln_transfer_id           NUMBER;
   ln_transfer_source_id    NUMBER;
   ln_transfer_Dest_id      NUMBER;
   ln_transfer_dest_line_id NUMBER;
   lv_transfer_num          VARCHAR2(30);
   lv_source                VARCHAR2(30);
   v_register_type          JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE ;--Added by CSahoo, BUG#5073553
   lv_rep_register_type    VARCHAR2(15);--added for bug#6773684
   ln_cess_credit_amt       NUMBER;
   ln_cess_debit_amt        NUMBER;
   ln_discounted_amt        NUMBER;
   ln_charge_account_id NUMBER;
   ln_cess_amount           NUMBER;
   lv_regime_code           JAI_RGM_DEFINITIONS.regime_code%TYPE;
   ln_charge_accounting_id  NUMBER;
   ln_balance_accounting_id NUMBER;
   ln_credit_amount         NUMBER;
   ln_debit_amount          NUMBER;
   lv_excise_cess           CONSTANT varchar2(30) := 'EXCISE-CESS';  --rchandan for bug#4428980
   /*Added by CSahoo, BUG#5073553*/
   lv_io_register           JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE;
   ln_receipt_id            JAI_CMN_RG_23AC_II_TRXS.receipt_ref%TYPE;
   ld_receipt_date          JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE;
   lv_reference_num         JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE;
   ln_ref_document_id       JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE;
   ld_ref_document_date     JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE;
   lv_vendor_cust_flag      JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE;

   lv_distribution_type    VARCHAR2(30);  /*bug 7525691*/


 ln_sh_cess_amount number;--Added by kunkumar for bug#6127194


   CURSOR c_pla_account(cp_inv_orgn_id number , cp_locn_id number) IS
   SELECT modvat_pla_account_id
   FROM   JAI_CMN_INVENTORY_ORGS
   WHERE  organization_id = cp_inv_orgn_id
   AND    location_id     = cp_locn_id;

   /*
   ||Start of bug 5073553
   ||Added by CSahoo
   */
   CURSOR  c_rg23a_account (cp_inv_orgn_id number , cp_locn_id number)
   IS
   SELECT modvat_rm_account_id
   FROM   JAI_CMN_INVENTORY_ORGS
   WHERE  organization_id = cp_inv_orgn_id
   AND    location_id     = cp_locn_id;

   --start additions for bug#8873924
    CURSOR  c_rg23c_account (cp_inv_orgn_id number , cp_locn_id number)
   IS
   SELECT modvat_cg_account_id
   FROM   JAI_CMN_INVENTORY_ORGS
   WHERE  organization_id = cp_inv_orgn_id
   AND    location_id     = cp_locn_id;

   --start additions for bug#8873924

CURSOR pref_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
SELECT pref_rg23a, pref_rg23c
FROM JAI_CMN_INVENTORY_ORGS
WHERE organization_id = p_organization_id
AND location_id = p_location_id ;

CURSOR rg_bal_cur(p_organization_id NUMBER, p_location_id NUMBER)IS
SELECT NVL(rg23a_balance,0) rg23a_balance ,NVL(rg23c_balance,0) rg23c_balance
FROM JAI_CMN_RG_BALANCES
WHERE organization_id = p_organization_id
AND location_id = p_location_id ;

v_pref_rg23a            NUMBER;
v_pref_rg23c            NUMBER;
v_rg23a_balance         NUMBER;
v_rg23c_balance         NUMBER;


--end additions for bug#8873924

   /* End of bug 5073553 */


   -- abcd
   CURSOR c_get_transfer_Dest_id IS
   SELECT transfer_Destination_id
   FROM   JAI_RGM_DIS_DES_TAXES
   WHERE  transfer_destination_line_id = p_reference_id;

   CURSOR c_cess_amt(cp_transfer_dest_id number) IS
   SELECT transfer_amount
   FROM   JAI_RGM_DIS_DES_TAXES
   WHERE  transfer_destination_id = cp_transfer_dest_id
  -- and    tax_type  in (lv_excise_cess,jai_constants.tax_type_service_edu_cess, jai_constants.tax_type_sh_service_edu_cess);  --rchandan for bug#4428980
    --commented the above and added the below by Sanjikum for Bug#6119459
   and    tax_type  in ('EXCISE-CESS','SERVICE_EDUCATION_CESS');

   --Added the below by kunkumar for bug#6127194
   CURSOR c_sh_cess_amt(cp_transfer_dest_id number) IS
   SELECT transfer_amount
   FROM   jai_rgm_dis_des_taxes
   WHERE  transfer_destination_id = cp_transfer_dest_id
   and    tax_type  in ('SERVICE_SH_EDU_CESS','EXCISE_SH_EDU_CESS');


  BEGIN

    IF p_called_from = 'SETTLEMENT' THEN

       SELECT jai_rgm_dis_src_hdrs_s.nextval ,
        JAI_RGM_DIS_SRC_TAXES_S.nextval ,
        jai_rgm_dis_des_hdrs_s.nextval ,
        JAI_RGM_DIS_DES_TAXES_S.nextval ,
        JAI_RGM_DIS_TRF_NUMS_S.nextval
       INTO   ln_transfer_id                 ,
        ln_transfer_source_id          ,
        ln_transfer_dest_id            ,
        ln_transfer_dest_line_id       ,
        lv_transfer_num
       FROM   dual;
       INSERT INTO jai_rgm_dis_src_hdrs
       (
       TRANSFER_ID        ,
       PARTY_ID           ,
       PARTY_TYPE         ,
       LOCATION_ID        ,
       TRANSFER_NUMBER    ,
       TRANSACTION_DATE   ,
       SETTLEMENT_ID      ,
       CREATION_DATE      ,
       CREATED_BY         ,
       LAST_UPDATE_DATE   ,
       LAST_UPDATED_BY    ,
       LAST_UPDATE_LOGIN
       )
       VALUES
       (
       ln_transfer_id     ,
       p_from_party_id    ,
       p_from_party_type  ,
       p_from_locn_id     ,
       lv_transfer_num    ,
       p_trx_date         ,
       p_settlement_id    ,
       sysdate            ,
       fnd_global.user_id ,
       sysdate            ,
       fnd_global.user_id ,
       fnd_global.login_id
       );
       INSERT INTO JAI_RGM_DIS_SRC_TAXES
       (
       TRANSFER_ID            ,
       TRANSFER_SOURCE_ID     ,
       TAX_TYPE               ,
       DEBIT_BALANCE          ,
       CREDIT_BALANCE         ,
       TRANSFER_AMOUNT        ,
       PARENT_TAX_TYPE        ,
       PERCENT_OF_PARENT      ,
       CREATION_DATE          ,
       CREATED_BY             ,
       LAST_UPDATE_DATE       ,
       LAST_UPDATED_BY        ,
       LAST_UPDATE_LOGIN
       )
       VALUES
       (
       ln_transfer_id         ,
       ln_transfer_source_id  ,
       p_from_tax_type        ,
       NULL                   ,
       NULL                   ,
       p_to_trx_amount        ,
       NULL                   ,
       NULL                   ,
       sysdate                ,
       fnd_global.user_id     ,
       sysdate                ,
       fnd_global.user_id     ,
       fnd_global.login_id
       );
       INSERT INTO jai_rgm_dis_des_hdrs
       (
       TRANSFER_ID                 ,
       TRANSFER_SOURCE_ID          ,
       TRANSFER_DESTINATION_ID     ,
       DESTINATION_PARTY_TYPE      ,
       DESTINATION_PARTY_ID        ,
       LOCATION_ID                 ,
       AMOUNT_TO_TRANSFER          ,
       TRANSFER_NUMBER             ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN
       )
       VALUES
       (
       ln_transfer_id         ,
       ln_transfer_source_id  ,
       ln_transfer_Dest_id    ,
       p_to_party_type        ,
       p_to_party_id          ,
       p_to_locn_id           ,
       p_to_trx_amount        ,
       lv_transfer_num        ,
       sysdate                ,
       fnd_global.user_id     ,
       sysdate                ,
       fnd_global.user_id     ,
       fnd_global.login_id
       );
       INSERT INTO JAI_RGM_DIS_DES_TAXES
       (
       TRANSFER_SOURCE_ID                 ,
       TRANSFER_DESTINATION_ID            ,
       TRANSFER_DESTINATION_LINE_ID       ,
       TAX_TYPE                           ,
       DEBIT_BALANCE                      ,
       CREDIT_BALANCE                     ,
       TRANSFER_AMOUNT                    ,
       CREATION_DATE                      ,
       CREATED_BY                         ,
       LAST_UPDATE_DATE                   ,
       LAST_UPDATED_BY                    ,
       LAST_UPDATE_LOGIN
       )
       VALUES
       (
       ln_transfer_source_id  ,
       ln_transfer_Dest_id    ,
       ln_transfer_dest_line_id,
       p_to_tax_type          ,
       NULL                   ,
       NULL                   ,
       p_to_trx_amount        ,
       sysdate                ,
       fnd_global.user_id     ,
       sysdate                ,
       fnd_global.user_id     ,
       fnd_global.login_id
       );
    END IF;
       /*
        end of logic for entering into distribution tables when called from settlement program
       */
      /*
      for the source party
      */
/*Bug 5879769 bduvarag start*/
    IF p_from_party_type IN ( 'OU' )
            OR
      ( p_from_party_type = 'IO'
  AND p_from_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess,
                   jai_constants.tax_type_sh_service_edu_cess))  THEN  -- added, Harshita for Bug 5694855
        --Modified by kunkumar for Bug#6127194
/*Bug 5879769 bduvarag end*/

    lv_acct_req_flag := jai_constants.YES;

       IF p_source = 'SETTLEMENT' THEN
         lv_source := jai_constants.source_settle_out ;
        -- lv_balancing_entry := jai_constants.NO;  --added by nprashar for bug # 7525691 commented for bug#6773684
       ELSIF p_source = 'DISTRIBUTION' THEN
         /*bug 7525691*/
         if p_from_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
    and p_to_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess )
   then
     lv_distribution_type:='S-S';
   end if;
         /*end bug 7525691*/
         lv_source := jai_constants.service_src_distribute_out;
       END IF;
       IF p_to_party_type = 'IO' and upper(p_to_tax_type) IN (upper(jai_constants.tax_type_excise), 'EXCISE-CESS',jai_constants.tax_type_sh_exc_edu_cess)
       THEN /*5694855*/
         /*
          ||Start of bug 5073553
          || Added by CSahoo
          || Determine the register setup from the from OU regime setup
          */

          IF f_get_io_register ( p_party_id        => p_to_party_id   ,    --changed p_from_party_id to p_to_party_id for bug#6773684
                                 p_from_party_type => p_from_party_type ,
                                 p_to_party_type   => p_to_party_type
                               ) = 'PLA'
          THEN
            v_register_type := jai_constants.register_type_pla;
          ELSE
            --v_register_type := jai_constants.REGISTER_TYPE_A; commented for bug#6773684
                 v_register_type :='RG';--bug#6773684
          END IF;
         /* End of bug 5073553 */
   /*Bug 5879769 bduvarag start*/
       ELSIF ( p_source = 'SETTLEMENT' or p_from_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess, jai_constants.tax_type_sh_service_edu_cess) ) THEN --Added by kunkumar for Bug#6127194
        lv_acct_req_flag := jai_constants.YES;
        v_register_type := NULL;
/*Bug 5879769 bduvarag end*/
       ELSE
         v_register_type := NULL;
       END IF;
       IF p_called_from = 'DISTRIBUTION' THEN
         ln_transfer_id := p_reference_id;
       END IF;

     --start additions for bug#6773684
     if v_register_type='RG'
     then
      lv_rep_register_type:=jai_constants.register_type_a;
     end if;
     --end additions for bug#6773684
    --this entry is for service to excise transfer
     jai_cmn_rgm_recording_pkg.insert_repository_entry
                                (
                                P_REPOSITORY_ID             => ln_repository_id   ,
                                P_REGIME_ID                 => p_regime_id        ,
                                P_TAX_TYPE                  => p_from_tax_type    ,
                                P_ORGANIZATION_TYPE         => p_from_party_type  ,
                                P_ORGANIZATION_ID           => p_from_party_id    ,
                                P_LOCATION_ID               => p_from_locn_id     ,
                                P_SOURCE                    => lv_source          ,
                                P_SOURCE_TRX_TYPE           => p_source_trx_type  ,
                                P_SOURCE_TABLE_NAME         => p_source_table_name,
                                P_SOURCE_DOCUMENT_ID        => p_source_doc_id    ,
                                P_TRANSACTION_DATE          => p_trx_date         ,
                                P_ACCOUNT_NAME              => NULL               ,
                                P_CHARGE_ACCOUNT_ID         => NULL               ,
                                P_BALANCING_ACCOUNT_ID      => NULL               ,
                                P_AMOUNT                    => p_to_trx_amount    ,
                                P_DISCOUNTED_AMOUNT         => ln_discounted_amt  ,
                                P_ASSESSABLE_VALUE          => NULL               ,
                                P_TAX_RATE                  => NULL               ,
                                P_REFERENCE_ID              => ln_transfer_id     ,
                                P_BATCH_ID                  => NULL               ,
                                P_CALLED_FROM               => p_called_from      ,
                                p_process_flag              => p_process_flag     ,
                                p_process_message           => p_process_message  ,
                                P_SETTLEMENT_ID             => p_settlement_id    ,
                                p_accounting_date           => p_accounting_date  ,
                                P_ACCNTG_REQUIRED_FLAG      => lv_acct_req_flag   ,
                                P_BALANCING_ORGN_TYPE       => p_to_party_type    ,
                                P_BALANCING_ORGN_ID         => p_to_party_id      ,
                                P_BALANCING_LOCATION_ID     => p_to_locn_id       ,
                                P_BALANCING_TAX_TYPE        => p_to_tax_type      ,
                                P_BALANCING_ACCNT_NAME      =>nvl(lv_rep_register_type ,v_register_type)  ,--added nvl(lv_rep_register_type for bug#6773684
                                P_CURRENCY_CODE             => jai_constants.func_curr , -- File.Sql.35 by Brathod
                    p_service_type_code         => p_from_service_type,
                                p_distribution_type         => lv_distribution_type  /*bug 7525691*/
                      );
       IF NVL(p_process_flag,'$') <> jai_constants.successful THEN
         rollback;
         return;
       END IF;
       p_repository_id := ln_repository_id;
    ELSIF  p_from_party_type = 'IO' THEN
      IF p_from_tax_type = 'EXCISE' THEN
        /*
        ||Start of bug 5073553
        || Added by CSahoo
        || Always debit the Rg register in case of IO to Ou distribution irrespective of the regime/regime party attribute setup. */


     --   v_register_type := 'RG';/*commented for bug#6773684*/
     --start additions for bug#6773684
     IF f_get_io_register ( p_party_id        => p_from_party_id   ,
          p_from_party_type => p_from_party_type ,
          p_to_party_type   => p_to_party_type
       ) = 'PLA'
          THEN
            v_register_type := jai_constants.register_type_pla;
          ELSE
            --v_register_type := jai_constants.REGISTER_TYPE_A;commented for bug#6773684
              v_register_type :='RG';--added for bug#6773684
          END IF;
--end additions for bug#6773684


        OPEN  c_get_transfer_Dest_id;
        FETCH c_get_transfer_Dest_id INTO ln_transfer_dest_id;
        CLOSE c_get_transfer_Dest_id;
        OPEN  c_cess_amt(ln_transfer_dest_id);
        FETCH c_cess_amt INTO ln_cess_amount;
        CLOSE c_cess_amt;

--Added by kunkumar for bug#6127194
OPEN c_sh_cess_amt(ln_transfer_dest_id);
FETCH c_sh_cess_amt INTO ln_sh_cess_amount;
CLOSE c_sh_cess_amt;

        IF v_register_type = 'RG' THEN
    ln_receipt_id      :=  p_reference_id   ;
    ld_receipt_date    :=  p_trx_date       ;
    lv_reference_num   :=  p_source_doc_id  ;
      --start additions for bug#8873924
      /*the preferences ,balances check has been added only for excise to service transfer,
      for service -excise transfer ,logic remains unchanged i.e always hit RG23A.
      **/

        OPEN pref_cur(p_from_party_id, p_from_locn_id);
        FETCH pref_cur INTO  v_pref_rg23a, v_pref_rg23c;
        CLOSE pref_cur;

	OPEN rg_bal_cur(p_from_party_id, p_from_locn_id);
        FETCH rg_bal_cur INTO v_rg23a_balance, v_rg23c_balance;
        CLOSE rg_bal_cur;
     --BASED on the preferences and balance availble fetch either A/C register
     IF v_pref_rg23a < v_pref_rg23c THEN
          if v_rg23a_balance >= NVL(p_to_trx_amount,0) THEN
            v_register_type := 'A';

           elsif v_rg23c_balance >= NVL(p_to_trx_amount,0)  THEN
              v_register_type  := 'C';
	   end if;
     ELSIF v_pref_rg23c < v_pref_rg23a THEN
          if v_rg23c_balance >= NVL(p_to_trx_amount,0) THEN
            v_register_type := 'C';

           elsif v_rg23a_balance >= NVL(p_to_trx_amount,0)  THEN
              v_register_type  := 'A';
	   end if;
     END IF;


       	   /*added if--elsif condition for bug#8873924*/
	    if v_register_type= 'A'
	    then
		    OPEN   c_rg23a_account(p_from_party_id ,p_from_locn_id );
		    FETCH  c_rg23a_account INTO ln_charge_account_id;
		    CLOSE  c_rg23a_account;
	    elsif v_register_type= 'C'
	    then
		    OPEN   c_rg23c_account(p_from_party_id ,p_from_locn_id );
		    FETCH  c_rg23c_account INTO ln_charge_account_id;
		    CLOSE  c_rg23c_account;
            end if;

--end additions for bug#8873924
      --start additions for bug#6773684
       ELSIF v_register_type = 'PLA' THEN
    ln_ref_document_id    :=   p_reference_id ;
    ld_ref_document_date  :=   p_trx_date     ;
    lv_vendor_cust_flag   :=   'O'            ;
    OPEN   c_pla_account(p_from_party_id ,p_from_locn_id );
    FETCH  c_pla_account INTO ln_charge_account_id;
    CLOSE  c_pla_account;

        END IF;
  --end additions for bug#6773684

  -- register_type = RG
        --commented the following by kunkumar for bug#6127194

 /*   jai_cmn_rg_23ac_ii_pkg.insert_row(
                   P_REGISTER_ID           => ln_register_id ,
                   P_INVENTORY_ITEM_ID     => -999         ,
                   P_ORGANIZATION_ID       => p_from_party_id ,
                   P_RECEIPT_ID            => p_reference_id ,
                   P_RECEIPT_DATE          => p_trx_date    ,
                   P_CR_BASIC_ED           => NULL,
                   P_CR_ADDITIONAL_ED      => NULL,
                   P_CR_OTHER_ED           => NULL,
                   P_DR_BASIC_ED           => p_to_trx_amount ,
                   P_DR_ADDITIONAL_ED      => NULL,
                   P_DR_OTHER_ED           => NULL,
                   P_EXCISE_INVOICE_NO     => NULL,
                   P_EXCISE_INVOICE_DATE   => NULL,
                   P_REGISTER_TYPE         => jai_constants.REGISTER_TYPE_A     ,
                   P_REMARKS               => 'DISTRIBUTION - OUT',
                   P_VENDOR_ID             => NULL,
                   P_VENDOR_SITE_ID        => NULL ,
                   P_CUSTOMER_ID           => NULL,
                   P_CUSTOMER_SITE_ID      => NULL,
                   P_LOCATION_ID           => p_from_locn_id,
                   P_TRANSACTION_DATE      => p_trx_date ,
                   P_CHARGE_ACCOUNT_ID     => NULL      ,
                   P_REGISTER_ID_PART_I    => NULL       ,
                   P_REFERENCE_NUM         => p_source_doc_id,
                   P_ROUNDING_ID           => NULL ,
                   P_OTHER_TAX_CREDIT      => NULL,
                   P_OTHER_TAX_DEBIT       => ln_cess_amount,
                   P_TRANSACTION_TYPE      => 'DISTRIBUTION' ,
                   P_TRANSACTION_SOURCE    => 'DISTRIBUTION' ,
                   P_CALLED_FROM           => p_called_from  ,
                   P_SIMULATE_FLAG         => 'N'       ,
                   p_process_status        => p_process_flag,
                   P_PROCESS_MESSAGE       => p_process_message
                   );*/
create_io_register_entry (
                                    p_register_type               =>  v_register_type                     ,
                                    p_tax_type                    =>  'EXCISE'                            ,
                                    p_organization_id             =>  p_from_party_id                     ,
                                    p_location_id                 =>  p_from_locn_id                      ,
                                    p_cr_basic_ed                 =>  NULL                                ,
                                    p_cr_additional_ed            =>  NULL                                ,
                                    p_cr_other_ed                 =>  NULL                                ,
                                    p_dr_basic_ed                 =>  p_to_trx_amount                     ,
                                    p_dr_additional_ed            =>  NULL                                ,
                                    p_dr_other_ed                 =>  NULL                                ,
                                    p_excise_invoice_no           =>  'DISTRIBUTION-'||ln_transfer_id   ,/*rchandan, Bug 5563300*/
                                    p_remarks                     =>  'DISTRIBUTION - OUT'                ,
                                    p_vendor_id                   =>  NULL                                ,
                                    p_vendor_site_id              =>  NULL                                ,
                                    p_transaction_date            =>  p_trx_date                          ,
                                    p_charge_account_id           =>  ln_charge_account_id                ,
                                    p_other_tax_credit            =>  NULL                                ,
                                    p_other_tax_debit             =>  NVL(ln_cess_amount,0) + NVL(ln_sh_cess_amount,0) ,
                                    p_transaction_type            =>  'DISTRIBUTION'                      ,
                                    p_transaction_source          =>  'DISTRIBUTION'                      ,
                                    p_called_from                 =>  p_called_from                       ,
                                    p_simulate_flag               =>  'N'                                 ,
                                    p_debit_amt                   =>  ln_cess_amount                      ,
                                    p_credit_amt                  =>  NULL                                ,
                                    --Added the below 2 columns by Sanjikum for Bug#6119459
                                    p_sh_cess_debit_amt                                         =>  ln_sh_cess_amount,
                                    p_sh_cess_credit_amt                                  =>  NULL       ,
                                    p_inventory_item_id           =>  -999                                ,
       /*RG specific parameters */
                                    p_receipt_id                  =>  ln_receipt_id                       ,
                                    p_receipt_date                =>  ld_receipt_date                     ,
                                    p_excise_invoice_date         =>  p_trx_date                         ,/*rchandan, Bug 5563300*/
                                    p_customer_id                 =>  NULL                                ,
                                    p_customer_site_id            =>  NULL                                ,
                                    p_register_id_part_i          =>  NULL                                ,
                                    p_reference_num               =>  lv_reference_num                    ,
                                    p_rounding_id                 =>  NULL                                ,
                                    /*PLA specific parameters */
                                    p_ref_document_id             =>  ln_ref_document_id                  ,
                                    p_ref_document_date           =>  ld_ref_document_date                ,
                                    p_dr_invoice_id               =>  NULL                                ,
                                    p_dr_invoice_date             =>  NULL                                ,
                                    p_bank_branch_id              =>  NULL                                ,
                                    p_entry_date                  =>  NULL                                ,
                                    p_vendor_cust_flag            =>  lv_vendor_cust_flag                 ,
                                    p_process_flag                =>  p_process_flag                      ,
                                    p_process_message             =>  p_process_message
                                 );

         /*jai_cmn_utils_pkg.print_log('dis.log','after call to from io process flag = ' || p_process_flag);
         jai_cmn_utils_pkg.print_log('dis.log','err messg is '||p_process_message );*/
        IF nvl(p_process_flag,jai_constants.successful) <> jai_constants.successful THEN
           rollback;
           return;
        END IF;
      END IF;
    END IF;
      /*
       for the destination party
      */
/*Bug 5879769 bduvarag*/
    IF p_to_party_type IN ('OU')
     OR
    ( p_to_party_type = 'IO' AND p_to_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess, jai_constants.tax_type_sh_service_edu_cess ))  THEN  -- added, Harshita for Bug 5694855 --Modified by kunkumar for Bug#6127194
      IF p_from_party_type = 'IO' AND upper(p_from_tax_type) IN (upper(jai_constants.tax_type_excise), 'EXCISE-CESS',upper(jai_constants.tax_type_sh_exc_edu_cess)) THEN/*Bug 5879769 bduvarag*/
         lv_acct_req_flag := jai_constants.YES;
      --   v_register_type := jai_constants.REGISTER_TYPE_A; commented for bug#6773684

--start additions for bug#6773684
IF f_get_io_register ( p_party_id        => p_from_party_id   ,
        p_from_party_type => p_from_party_type ,
        p_to_party_type   => p_to_party_type
     ) = 'PLA'
        THEN
          v_register_type := jai_constants.register_type_pla;
        ELSE
          --v_register_type := jai_constants.REGISTER_TYPE_A;--commneted for bug#6773684
          v_register_type :='RG';--added for bug#6773684
        END IF;
--end additions for bug#6773684
-- start additions for bug#8873924
/**this check has been added to fetch the v_register_type which will be used to insert into repository
with p from tax type as excise*/

  IF v_register_type = 'RG' THEN

        OPEN pref_cur(p_from_party_id, p_from_locn_id);
        FETCH pref_cur INTO  v_pref_rg23a, v_pref_rg23c;
        CLOSE pref_cur;

	OPEN rg_bal_cur(p_from_party_id, p_from_locn_id);
        FETCH rg_bal_cur INTO v_rg23a_balance, v_rg23c_balance;
        CLOSE rg_bal_cur;
     --BASED on the preferences and balance availble fetch either A/C register
     IF v_pref_rg23a < v_pref_rg23c THEN
          if v_rg23a_balance >= NVL(p_to_trx_amount,0) THEN
            v_register_type := 'A';

           elsif v_rg23c_balance >= NVL(p_to_trx_amount,0)  THEN
              v_register_type  := 'C';
	   end if;
     ELSIF v_pref_rg23c < v_pref_rg23a THEN
          if v_rg23c_balance >= NVL(p_to_trx_amount,0) THEN
            v_register_type := 'C';

           elsif v_rg23a_balance >= NVL(p_to_trx_amount,0)  THEN
              v_register_type  := 'A';
	   end if;
     END IF;
end if;

--end additions for bug#8873924



/*Bug 5879769 bduvarag start*/
      ELSIF ( p_source = 'SETTLEMENT' or p_to_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess, jai_constants.tax_type_sh_service_edu_cess )) THEN  --Added by kunkumar for Bug#6127194
        lv_acct_req_flag := jai_constants.YES;
        v_register_type := NULL;
/*Bug 5879769 bduvarag end*/
      ELSE
         lv_acct_req_flag := jai_constants.NO;
         v_register_type := NULL;
      END IF;
      IF p_source = 'SETTLEMENT' THEN
        lv_source := jai_constants.source_settle_in ;
       -- lv_balancing_entry := jai_constants.NO;  --added by nprashar for bug # 7525691 commented for bug#6773684
      ELSIF p_source = 'DISTRIBUTION' THEN
        /*bug 7525691*/
        if p_from_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
   and p_to_tax_type IN (jai_constants.tax_type_service, jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess )
  then
     lv_distribution_type:='S-S';
  end if;
        lv_source := jai_constants.service_src_distribute_in;
      END IF;
           /*  jai_cmn_utils_pkg.print_log('dis.log',' p_to_trx_amount is :' || p_to_trx_amount); */
      IF p_called_from = 'DISTRIBUTION' THEN
         ln_transfer_id := p_reference_id;
      END IF;

    --start additions for bug#6773684
     if  v_register_type='RG'
     then
        lv_rep_register_type :=jai_constants.register_type_a;
     else
         lv_rep_register_type:=	v_register_type;--added for bug#8873924
      end if;
     --end additions for bug#6773684


      jai_cmn_rgm_recording_pkg.insert_repository_entry
      (
       P_REPOSITORY_ID             => ln_repository_id   ,
       P_REGIME_ID                 => p_regime_id        ,
       P_TAX_TYPE                  => p_to_tax_type      ,
       P_ORGANIZATION_TYPE         => p_to_party_type    ,
       P_ORGANIZATION_ID           => p_to_party_id      ,
       P_LOCATION_ID               => p_to_locn_id       ,
       P_SOURCE                    => lv_source          ,
       P_SOURCE_TRX_TYPE           => p_source_trx_type  ,
       P_SOURCE_TABLE_NAME         => p_source_table_name,
       P_SOURCE_DOCUMENT_ID        => p_source_doc_id    ,
       P_TRANSACTION_DATE          => p_trx_date         ,
       P_ACCOUNT_NAME              => NULL               ,
       P_CHARGE_ACCOUNT_ID         => NULL               ,
       P_BALANCING_ACCOUNT_ID      => NULL               ,
       P_AMOUNT                    => p_to_trx_amount    ,
       P_DISCOUNTED_AMOUNT         => ln_discounted_amt  ,
       P_ASSESSABLE_VALUE          => NULL               ,
       P_TAX_RATE                  => NULL               ,
       P_REFERENCE_ID              => ln_transfer_id     ,
       P_BATCH_ID                  => NULL               ,
       P_CALLED_FROM               => p_called_from      ,
       p_process_flag              => p_process_flag     ,
       p_process_message           => p_process_message  ,
       P_SETTLEMENT_ID             => p_settlement_id    ,
       p_accounting_date           => p_trx_date         ,
       P_ACCNTG_REQUIRED_FLAG      => lv_acct_req_flag   ,
       P_BALANCING_ORGN_TYPE       => p_from_party_type  ,
       P_BALANCING_ORGN_ID         => p_from_party_id    ,
       P_BALANCING_LOCATION_ID     => p_from_locn_id     ,
       P_BALANCING_TAX_TYPE        => p_from_tax_type    ,
       P_BALANCING_ACCNT_NAME      =>lv_rep_register_type ,
       --added the nvl(lv_rep_register_type for bug#6773684
       P_CURRENCY_CODE             => jai_constants.func_curr , -- File.Sql.35 by Brathod
       p_service_type_code         => p_to_service_type  ,
       p_distribution_type         => lv_distribution_type   /*bug 7525691*/
      );
      IF nvl(p_process_flag,'$') <> jai_constants.successful THEN
         rollback;
         return;
      END IF;
      p_repository_id := ln_repository_id;
    ELSIF  p_to_party_type = 'IO' THEN
      IF p_to_tax_type = 'EXCISE' THEN

        /*
        ||Start of bug 5073553
        || Added By CSahoo BUG#5073553
        || Determine the register setup from the OU regime setup
        */

        v_register_type := f_get_io_register (  p_party_id        => p_to_party_id   ,     --changed p_from_party_id to p_to_party_id for bug#6773684
                                                p_from_party_type => p_from_party_type ,
                                                p_to_party_type   => p_to_party_type
                                             ) ;

        OPEN  c_get_transfer_Dest_id;
        FETCH c_get_transfer_Dest_id INTO ln_transfer_dest_id;
        CLOSE c_get_transfer_Dest_id;
        OPEN  c_cess_amt(ln_transfer_dest_id);
        FETCH c_cess_amt INTO ln_cess_amount;
        CLOSE c_cess_amt;
--Added by kunkumar for bug#6127194
OPEN c_sh_cess_amt(ln_transfer_dest_id);
FETCH c_sh_cess_amt INTO ln_sh_cess_amount;
CLOSE c_sh_cess_amt;

        IF v_register_type = 'RG' THEN
          ln_receipt_id      :=  p_reference_id   ;
          ld_receipt_date    :=  p_trx_date       ;
          lv_reference_num   :=  p_source_doc_id  ;
          OPEN   c_rg23a_account(p_to_party_id ,p_to_locn_id );  --changed from party id ,from locn id to to party id ,to locn id for bug#6773684
          FETCH  c_rg23a_account INTO ln_charge_account_id;
          CLOSE  c_rg23a_account;
        ELSIF v_register_type = 'PLA' THEN
          ln_ref_document_id    :=   p_reference_id ;
          ld_ref_document_date  :=   p_trx_date     ;
          lv_vendor_cust_flag   :=   'O'            ;
          OPEN   c_pla_account(p_to_party_id ,p_to_locn_id );
          FETCH  c_pla_account INTO ln_charge_account_id;
          CLOSE  c_pla_account;
        END IF; --v_register_type = 'RG'
        --Commented by kunkumar for Bug#6127194
       /* jai_cmn_rg_pla_trxs_pkg.insert_row(
                                   p_register_id                   => ln_register_id,
                                   p_tr6_challan_no                => NULL,
                                   p_tr6_challan_date              => NULL,
                                   p_cr_basic_ed                   => p_to_trx_amount,
                                   p_cr_additional_ed              => NULL,
                                   p_cr_other_ed                   => NULL,
                                   p_ref_document_id               => p_reference_id,
                                   p_ref_document_date             => p_trx_date,
                                   p_dr_invoice_id                 => NULL,
                                   p_dr_invoice_date               => NULL,
                                   p_dr_basic_ed                   => NULL,
                                   p_dr_additional_ed              => NULL,
                                   p_dr_other_ed                   => NULL,
                                   p_organization_id               => p_to_party_id,
                                   p_location_id                   => p_to_locn_id,
                                   p_bank_branch_id                => NULL,
                                   p_entry_date                    => NULL,
                                   p_inventory_item_id             => -999,
                                   p_vendor_cust_flag              => 'O',
                                   p_vendor_id                     => p_from_party_id,
                                   p_vendor_site_id                => NULL,
                                   p_excise_invoice_no             => NULL,
                                   p_remarks                       => 'DISTRIBUTION',
                                   p_transaction_date              => p_trx_date,
                                   p_charge_account_id             => ln_charge_account_id,
                                   p_other_tax_credit              => ln_cess_amount,
                                   p_other_tax_debit               => NULL,
                                   p_transaction_type              => 'DISTRIBUTION',
                                   p_transaction_source            => 'DISTRIBUTION',
                                   p_called_from                   => p_called_from,
                                   p_simulate_flag                 => 'N',
                                   p_process_status                => p_process_flag,
                                   p_process_message               => p_process_message
                                  );*/ --Added the call to create_io_register entry by kunkumar
create_io_register_entry (
                                    p_register_type               =>  v_register_type                   ,
                                    p_tax_type                    =>  'EXCISE'                          ,
                                    p_organization_id             =>  p_to_party_id                     ,
                                    p_location_id                 =>  p_to_locn_id                      ,
                                    p_cr_basic_ed                 =>  p_to_trx_amount                   ,
                                    p_cr_additional_ed            =>  NULL                              ,
                                    p_cr_other_ed                 =>  NULL                              ,
                                    p_dr_basic_ed                 =>  NULL                              ,
                                    p_dr_additional_ed            =>  NULL                              ,
                                    p_dr_other_ed                 =>  NULL                              ,
                                    p_excise_invoice_no           =>  'DISTRIBUTION-'||ln_transfer_id   ,/*rchandan, Bug 5563300*/
                                    p_remarks                     => 'DISTRIBUTION - IN'                ,
                                    p_vendor_id                   => -1 * p_from_party_id               , -- Added -1* by Jia for Bug#6174148
                                    p_vendor_site_id              => NULL                               ,
                                    p_transaction_date            => p_trx_date                         ,
                                    p_charge_account_id           => ln_charge_account_id               ,
                                    p_other_tax_credit            =>  NVL(ln_cess_amount,0) + NVL(ln_sh_cess_amount,0) , --changed by Sanjikum for Bug#6119459
                                    p_other_tax_debit             => NULL                               ,
                                    p_transaction_type            => 'DISTRIBUTION'                     ,
                                    p_transaction_source          => 'DISTRIBUTION'                     ,
                                    p_called_from                 => p_called_from                      ,
                                    p_simulate_flag               => 'N'                                ,
                                    p_debit_amt                   => NULL                               ,
                                    p_credit_amt                  => ln_cess_amount                     ,
                                    --Added the below 2 columns by Sanjikum for Bug#6119459
                                    p_sh_cess_debit_amt                                         =>  NULL                              ,
                                    p_sh_cess_credit_amt                                  =>  ln_sh_cess_amount                 ,
                                    p_inventory_item_id           => -999                               ,
                                    /*RG specific parameters */
                                    p_receipt_id                  => ln_receipt_id                      ,
            p_receipt_date                => ld_receipt_date                    ,
                                    p_excise_invoice_date         => p_trx_date                         ,/*rchandan, Bug 5563300*/
                                    p_customer_id                 => NULL                               ,
                                    p_customer_site_id            => NULL                               ,
                                    p_register_id_part_i          => NULL                               ,
                                    p_reference_num               => lv_reference_num                   ,
                                    p_rounding_id                 => NULL                               ,
                                    /*PLA specific parameters */
                                    p_ref_document_id             => ln_ref_document_id                 ,
                                    p_ref_document_date           => ld_ref_document_date               ,
                                    p_dr_invoice_id               => NULL                               ,
                                    p_dr_invoice_date             => NULL                               ,
                                    p_bank_branch_id              => NULL                               ,
                                    p_entry_date                  => NULL                               ,
                                    p_vendor_cust_flag            => lv_vendor_cust_flag                ,
                                    p_process_flag                => p_process_flag                     ,
                                    p_process_message             => p_process_message
                                 );

        IF nvl(p_process_flag,jai_constants.successful) <>  jai_constants.successful THEN
          rollback;
          return;
        END IF;--p_process_flag
      END IF;-- p_to_tax_type
    END IF;   --p_to_party_type
  COMMIT;
  p_process_flag    := 'SS';
  EXCEPTION
  WHEN OTHERS THEN
  p_process_flag    := 'UE';
  p_process_message := 'Error in procedure - insert_records_into_register ' || substr(sqlerrm,1,1500);
END insert_records_into_register;




  PROCEDURE delete_records(p_request_id number) IS

  BEGIN
   DELETE FROM JAI_RGM_BALANCE_T
   WHERE  request_id = p_request_id;
   COMMIT;

  END delete_records;



-- added, Harshita for Bug 5096787
PROCEDURE create_io_register_entry (
  p_register_type                 IN  JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE                            ,
  p_tax_type                      IN  VARCHAR2                                                      ,
  p_organization_id               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE                       ,
  p_location_id                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE                           ,
  p_cr_basic_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE                           ,
  p_cr_additional_ed              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE                      ,
  p_cr_other_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE                           ,
  p_dr_basic_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE                           ,
  p_dr_additional_ed              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE                      ,
  p_dr_other_ed                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE                           ,
  p_excise_invoice_no             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE                     ,
  p_remarks                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE                               ,
  p_vendor_id                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE                             ,
  p_vendor_site_id                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE                        ,
  p_transaction_date              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE                      ,
  p_charge_account_id             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE                     ,
  p_other_tax_credit              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE                      ,
  p_other_tax_debit               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE                       ,
  p_transaction_type              IN  VARCHAR2                                                      ,
  p_transaction_source            IN  VARCHAR2                                                      ,
  p_called_from                   IN  VARCHAR2                                                      ,
  p_simulate_flag                 IN  VARCHAR2                                                      ,
  p_debit_amt                     IN  JAI_CMN_RG_OTHERS.DEBIT%TYPE                                      ,
  p_credit_amt                    IN  JAI_CMN_RG_OTHERS.CREDIT%TYPE                                     ,
p_sh_cess_debit_amt IN JAI_CMN_RG_OTHERS.DEBIT%TYPE,--Added by kunkumar for bug#6127194
p_sh_cess_credit_amt  IN JAI_CMN_RG_OTHERS.CREDIT%TYPE,--Added by kunkumar for bug#6127194
  p_inventory_item_id             IN  JAI_CMN_RG_23AC_II_TRXS.INVENTORY_ITEM_ID%TYPE                     ,
  p_receipt_id                    IN  JAI_CMN_RG_23AC_II_TRXS.RECEIPT_REF%TYPE            Default NULL    ,
  p_receipt_date                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE          Default NULL    ,
  p_excise_invoice_date           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE   Default NULL    ,
  p_customer_id                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE           Default NULL    ,
  p_customer_site_id              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE      Default NULL    ,
  p_register_id_part_i            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE    Default NULL    ,
  p_reference_num                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE         Default NULL    ,
  p_rounding_id                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE           Default NULL    ,
  p_ref_document_id               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE                Default NULL    ,
  p_ref_document_date             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE              Default NULL    ,
  p_dr_invoice_id                 IN  JAI_CMN_RG_PLA_TRXS.DR_INVOICE_NO%TYPE                  Default NULL    ,
  p_dr_invoice_date               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE                Default NULL    ,
  p_bank_branch_id                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE                 Default NULL    ,
  p_entry_date                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE                     Default NULL    ,
  p_vendor_cust_flag              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE               Default NULL    ,
  p_process_flag                  OUT NOCOPY VARCHAR2                                               ,
  p_process_message               OUT NOCOPY VARCHAR2
                                   )
IS
--Added by kunkumar for bug#6127194, Start
ln_register_id           NUMBER                              ;
   ln_transfer_Dest_id      NUMBER                              ;
   ln_cess_amount           NUMBER                              ;
   ln_source_type           JAI_CMN_RG_OTHERS.SOURCE_TYPE%TYPE      ;
   lv_source_register       JAI_CMN_RG_OTHERS.SOURCE_REGISTER%TYPE  ;
   lv_register_type  VARCHAR2(10);
--End, Added by kunkumar

BEGIN
--Added the body of the procedure by kunkumar for bug#6127194
 /*
  ||Initialize the variables
  */
  p_process_flag        := jai_constants.successful;
  ln_source_type        := null                    ;
  lv_source_register    := null                    ;

  IF p_tax_type = 'EXCISE' THEN
     --start additions for bug#8873924
     IF p_register_type in  ('RG','A','C') THEN
      if  p_register_type='RG' then
	      ln_source_type        := 1          ;
	      lv_source_register    := 'RG23A_P2' ;
	      lv_register_type:='A';
       elsif p_register_type='A' then
	     lv_register_type:='A';
	     ln_source_type        := 1          ;
	      lv_source_register    := 'RG23A_P2' ;
       elsif p_register_type='C' then
	     lv_register_type:='C';
	     ln_source_type        := 1          ;
	      lv_source_register    := 'RG23C_P2' ;
	end if;


	--end additions for bug#8873924
jai_cmn_rg_23ac_ii_pkg.insert_row(
                                         p_register_id           => ln_register_id                      ,
                                         p_inventory_item_id     => p_inventory_item_id                 ,
                                         p_organization_id       => p_organization_id                   ,
                                         p_receipt_id            => p_receipt_id                        ,
                                         p_receipt_date          => p_receipt_date                      ,
                                         p_cr_basic_ed           => p_cr_basic_ed                       ,
                                         p_cr_additional_ed      => p_cr_additional_ed                  ,
                                         p_cr_other_ed           => p_cr_other_ed                       ,
                                         p_dr_basic_ed           => p_dr_basic_ed                       ,
                                         p_dr_additional_ed      => p_dr_additional_ed                  ,
                                         p_dr_other_ed           => p_dr_other_ed                       ,
                                         p_excise_invoice_no     => p_excise_invoice_no                 ,
                                         p_excise_invoice_date   => p_excise_invoice_date               ,
                                         p_register_type         => lv_register_type ,--jai_constants.register_type_a       , bug 8873924
                                         p_remarks               => p_remarks                           ,
                                         p_vendor_id             => p_vendor_id                         ,
 p_vendor_site_id        => p_vendor_site_id                    ,
                                         p_customer_id           => p_customer_id                       ,
                                         p_customer_site_id      => p_customer_site_id                  ,
                                         p_location_id           => p_location_id                       ,
                                         p_transaction_date      => p_transaction_date                  ,
                                         p_charge_account_id     => p_charge_account_id                 ,
                                         p_register_id_part_i    => p_register_id_part_i                ,
                                         p_reference_num         => p_reference_num                     ,
                                         p_rounding_id           => p_rounding_id                       ,
                                         p_other_tax_credit      => p_other_tax_credit                  ,
                                         p_other_tax_debit       => p_other_tax_debit                   ,
                                         p_transaction_type      => p_transaction_type                  ,
                                         p_transaction_source    => p_transaction_source                ,
                                         p_called_from           => p_called_from                       ,
                                         p_simulate_flag         => p_simulate_flag                     ,
                                         p_process_status        => p_process_flag                      ,
                                         p_process_message       => p_process_message
                                         );


    ELSIF p_register_type = 'PLA' THEN
      ln_source_type        := 2     ;
      lv_source_register    := 'PLA' ;

    jai_cmn_rg_pla_trxs_pkg.insert_row(
                                 p_register_id                   => ln_register_id              ,
                                 p_tr6_challan_no                => NULL                        ,
                                 p_tr6_challan_date              => NULL                        ,
                                 p_cr_basic_ed                   => p_cr_basic_ed               ,
                                 p_cr_additional_ed              => p_cr_additional_ed          ,
                                 p_cr_other_ed                   => p_cr_other_ed               ,
                                 p_ref_document_id               => p_ref_document_id           ,
                                 p_ref_document_date             => p_ref_document_date         ,
                                 p_dr_invoice_id                 => p_dr_invoice_id             ,
                                 p_dr_invoice_date               => p_dr_invoice_date           ,
                                 p_dr_basic_ed                   => p_dr_basic_ed               ,
                                 p_dr_additional_ed              => p_dr_additional_ed          ,
                                 p_dr_other_ed                   => p_dr_other_ed               ,
                                 p_organization_id               => p_organization_id           ,
                                 p_location_id                   => p_location_id               ,
                                 p_bank_branch_id                => p_bank_branch_id            ,
                                 p_entry_date                    => p_entry_date                ,
                                 p_inventory_item_id             => p_inventory_item_id         ,
                                 p_vendor_cust_flag              => p_vendor_cust_flag          ,
                                 p_vendor_id                     => p_vendor_id                 ,
                                 p_vendor_site_id                => p_vendor_site_id            ,
                                 p_excise_invoice_no             => p_excise_invoice_no         ,
                                 p_remarks                       => p_remarks                   ,
                                 p_transaction_date              => p_transaction_date          ,
                                 p_charge_account_id             => p_charge_account_id         ,
                                 p_other_tax_credit              => p_other_tax_credit          ,
                                 p_other_tax_debit               => p_other_tax_debit           ,
                                 p_transaction_type              => p_transaction_type          ,
                                 p_transaction_source            => p_transaction_source        ,
                                 p_called_from                   => p_called_from               ,
                                 p_simulate_flag                 => p_simulate_flag             ,
                                 p_process_status                => p_process_flag              ,
                                 p_process_message               => p_process_message
                                );

    END IF;

    IF nvl(p_process_flag,jai_constants.successful) <> jai_constants.successful THEN
      rollback;
      return;
    ELSE /* Pass cess entries in jai_rg_others table*/
      /* Update the cess amount in the ja_in_rg23_part_ii table*/
        IF nvl(p_credit_amt,0) <> 0 OR
     nvl(p_debit_amt,0) <>  0
         THEN

    jai_cmn_rg_others_pkg.insert_row( p_source_type  => ln_source_type          ,
                p_source_name  => lv_source_register      ,
                p_source_id    => ln_register_id          ,
                p_tax_type     => 'EXCISE_EDUCATION_CESS' ,
                debit_amt      => p_debit_amt             ,
                credit_amt     => p_credit_amt            ,
                p_process_flag => p_process_flag          ,
                p_process_msg  => p_process_message
              );

    IF  nvl(p_process_flag,jai_constants.successful)  <> jai_constants.successful THEN

      rollback;
      return;
    END IF;
             END IF;

    IF nvl(p_sh_cess_debit_amt,0) <> 0 OR
       nvl(p_sh_cess_credit_amt,0) <>  0
    THEN

      jai_cmn_rg_others_pkg.insert_row( p_source_type  => ln_source_type          ,
                  p_source_name  => lv_source_register      ,
                  p_source_id    => ln_register_id          ,
                  p_tax_type     => 'EXCISE_SH_EDU_CESS'    ,
                  debit_amt      => p_sh_cess_debit_amt     ,
                  credit_amt     => p_sh_cess_credit_amt    ,
                  p_process_flag => p_process_flag          ,
                  p_process_msg  => p_process_message
                );

    IF  nvl(p_process_flag,jai_constants.successful)  <> jai_constants.successful THEN

      rollback;
      return;
    END IF;
  END IF;
      END IF;
  END IF; -- end if of tax_type = 'Excise'
END create_io_register_entry;
--END ;


FUNCTION f_get_io_register ( p_party_id           JAI_RGM_BALANCE_T.PARTY_ID%TYPE    ,
                             p_from_party_type    JAI_RGM_BALANCE_T.PARTY_TYPE%TYPE  ,
                             p_to_party_type      JAI_RGM_BALANCE_T.PARTY_TYPE%TYPE
                           )
RETURN VARCHAR2
IS
/*
  || Check the setup value for the "Service Tax Distribution in PLA/RG" attribute for the Service Tax regime for the source OU. This should be either PLA or RG
  */
  CURSOR cur_get_dist_plg_rg
  IS
  SELECT
        attribute_value
  FROM
       jai_rgm_org_regns_v
  WHERE
 --organization_type = 'OU'   /*commented by vkaranam for bug#6773684*/
  organization_id   = p_party_id
  AND  regime_code       = 'SERVICE'
  AND  registration_type = 'OTHERS'
  AND  attribute_code    = 'DIST_PLA_RG';
  ln_attrval_dist_plarg JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE := NULL;
BEGIN
  /*
  || Determine the register for the given OU based on the "Service Tax distribution in PLA/RG" attribute setup,
  || set it to PLA in case no setup is found
  */
  OPEN  cur_get_dist_plg_rg  ;
  FETCH cur_get_dist_plg_rg into ln_attrval_dist_plarg;
  CLOSE cur_get_dist_plg_rg;
  /*
  || If the attribute value for Service TAx Distribution in PLA/RG is not set then do the following
  || 1. In case of IO to OU debit RG register
  || 2. In case of Ou to IO credit PLA register
  */
 /* commented by vkaranam for bug#6773684*
  IF ln_attrval_dist_plarg IS NULL THEN
    IF p_from_party_type = 'IO' THEN
      ln_attrval_dist_plarg := 'RG';
    ELSIF p_to_party_type = 'IO' THEN
      ln_attrval_dist_plarg := 'PLA';
    END IF;
  END IF;
  */

/*  || If the attribute value for Service TAx Distribution in PLA/RG is not set then Default register wil be RG Register
 start additons for  Bug #6773684*/
    IF ln_attrval_dist_plarg IS NULL THEN
   ln_attrval_dist_plarg := 'RG';
    END IF;
   /*end bug#6773684*/
  return(ln_attrval_dist_plarg);

END ;
-- ended, Harshita for Bug 5096787
----------------------------------------------------------------------------------------------------------------
END JAI_CMN_RGM_TAX_DIST_PKG;

/

--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_SETTLEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_SETTLEMENT_PKG" AS
/* $Header: jai_cmn_rgm_stl.plb 120.16.12010000.7 2010/01/07 11:07:55 xlv ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  File Version 116.2. Object is Modified to refer to New DB Entity names in place of
             Old DB Entity Names as required for CASE COMPLAINCE.

14-Jun-2005  rchandan for bug#4428980, Version 116.3
             Modified the object to remove literals from DML statements and CURSORS.

08-Jul-2005  Sanjikum for Bug#4482462
              1) Removed the column payment_method_lookup_code from cursors - for_terms_id, for_terms_id_2
              2) In the procedure create_invoice, commented the if condition of payment_method_lookup_code
              3) In the procedure create_invoice, commented the value of parameter - p_payment_method_lookup_code
                 while calling procedure - jai_ap_utils_pkg.insert_ap_inv_interface

18-Jul-2005  rchandan for bug#4487676.Version 117.2
              JAI_RGM_SETTLEMENT_INVOICE_S is replaced with JAI_RGM_SETTLEMENT_S1

23-Aug-2005  Ramananda for bug#4559828. File Version 120.3
             Problem:
             -------
             R12.FIN.A.QA.ST.2: GETTING ERROR ON PERFORMING SERVICE TAX SETTLEMENT
             This error is coming inspite of GL and AP periods being open

             Reason:
             ------
             Org_id in the form is populated when authority site is selected from the
             front end. When 'Process' Button is pressed, form makes a call to
             jai_cmn_rgm_settlement_pkg.create_invoice passing org_id.

             Presently, org_id is not passed to ap_utilities_pkg.get_open_gl_date and
             ap_utilities_pkg.get_current_gl_date. This is defaulted from mo_global.GET_CURRENT_ORG_ID.
             However the value is not retrieved from the same, hence the above reported error

             Fix:
             ----
             Added pn_org_id parameter while making a call to
               1. ap_utilities_pkg.get_open_gl_date
               2. ap_utilities_pkg.get_current_gl_date
             in jai_cmn_rgm_settlement_pkg.create_invoice is modified to pass org_id, which is solving the problem.
             i.e "APP-JA-460204: ORA 20001: No Open Period...after <settlement date in the form>"

02-Dec-2005  Bug 4774647. Added by Lakshmi Gopalsami  Version 120.4
             Passed operating unit also as this parameter has been added by base.

27-Feb-2006  Bug 4929081. Added by Lakshmi Gopalsami version 120.5
             (1) Moved cursor counter_cur after inserting into
           ap_invoices_interface so that invoice_id condition can be used.
             (2) Removed the select for count(*) and put the same in the cursor.
30-JAN-2007  Bug#5631784. Added by CSahoo File Version 120.11
             Forward Porting of BUG#4742259 (TCS solution)
             Changes made in the procedure create_invoice to create invoice at the
						 time of TCS settlement. A new cursor cur_distributions_TCS is defined to fetch
						 tax balances.

27-April-2007   ssawant for bug 5879769,6020629 ,File version 120.6
                Forward porting of
		ENH : SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION
		from 11.5( bug no 5694855) to R12 (bug no 5879769).
		forward porting of bug
		ACCOUNTING ENTRY ON SETTLEMENT NOT PASSED
		from 11.5( bug no 4287372) to R12 (bug no 6020629).

7-June-2007        ssawant for bug 5662296
		   Forward porting R11 bug 5642053 to R12 bug 5662296.

19-Sep-2007      anujsax for bug#6126142, File Version 120.16
                 Issue : VAT SETTLEMENT ENTRIES NOT GENERATED FOR OFFSET VALUE AT THE TIME OF PAYMENT.
                 The above issue was happening due to passing of SYSDATE for the accounting date
                 for creating AP Invoices and GL Interface.
                 Fix : The seettlement date has been passed as accounting date for AP Invoice and GL Interface

28-jun-2009 vumaasha for bug 8657720
                      Added an IF condition to consider 'VAT REVERSAL' tax type equivalent to 'VALUE ADDED TAX' during settlement.

30-sep-2009 vkaranam for bug#8974544
             Fix:
	     Added regime_id condition in the get_last_Settlement_date(pn_regime_id.pn_or_id) procedure.

13-Dec-2009 Eric Ma for bug#7031751
             Fix:  FP 12.0 : INDIA LOC- SETTLEMENT ENTRIES ARE NOT GETTING GENERATED

22-Dec-2009 Eric Ma for bug#8333082,8671217
             Fix:  FP:8281389: VAT SETTLEMENT PAYMENT DETAILS FORM NOT SHOWING THE DATA PROPERLY

--------------------------------------------------------------------------------------*/

PROCEDURE insert_into_vat_register(
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
      p_accounting_date            Date
                        )
IS
   ln_repository_id   number;
   lv_process_status  varchar2(30);
   lv_process_message VARCHAR2(1996);

   lv_source                varchar2(30);
   lv_regime_code           JAI_RGM_DEFINITIONS.regime_code%TYPE;
   ln_charge_accounting_id  NUMBER;
   ln_balance_accounting_id NUMBER;
   ln_credit_amount         NUMBER;
   ln_debit_amount          NUMBER;
   lv_statement             NUMBER;

BEGIN
 lv_source := jai_constants.source_settle_out;
 ln_credit_amount:= NULL;   --- these amounts are with respect to repository not w.r.t accounting
 ln_debit_amount := p_to_trx_amount;              ---  its is reverse w.r.t accounting


   ln_charge_accounting_id := jai_cmn_rgm_recording_pkg.get_account(
                p_regime_id            => p_regime_id,
                p_organization_type      => p_from_party_type,
                p_organization_id        => p_from_party_id,
                p_location_id            => p_from_locn_id,
                p_tax_type               => p_from_tax_type,
                p_account_name           => jai_constants.recovery
              );

   ln_balance_accounting_id :=  jai_cmn_rgm_recording_pkg.get_account(
                p_regime_id              => p_regime_id,
                p_organization_type      => p_to_party_type,
                p_organization_id        => p_to_party_id,
                p_location_id            => p_to_locn_id,
                p_tax_type               => p_to_tax_type,
                p_account_name           => jai_constants.recovery
              );


   jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
               pn_repository_id         => ln_repository_id,
               pn_regime_id             => p_regime_id,
               pv_tax_type              => p_from_tax_type ,
               pv_organization_type     => p_from_party_type,
               pn_organization_id       => p_from_party_id,
               pn_location_id           => p_from_locn_id,
               pv_source                => lv_source,
               pv_source_trx_type       => p_source_trx_type ,
               pv_source_table_name     => p_source_table_name,
               pn_source_id             => p_source_doc_id    ,
               pd_transaction_date      => p_trx_date,
               pv_account_name          => jai_constants.recovery,
               pn_charge_account_id     => ln_charge_accounting_id,
               pn_balancing_account_id  => ln_balance_accounting_id,
               pn_credit_amount         => ln_credit_amount,
               pn_debit_amount          => ln_debit_amount,
               pn_assessable_value      => NULL,
               pn_tax_rate              => NULL,
               pn_reference_id          => NULL,
               pn_batch_id              => NULL,
               pn_inv_organization_id   => p_from_party_id,
               pv_invoice_no            => NULL,
               pv_called_from           =>  p_called_from,
               pv_process_flag          => p_process_flag,
               pv_process_message       => p_process_message,
               pd_invoice_date          => NULL,
               pn_settlement_id         => p_settlement_id  --added for bug#7145898 on 25-Dec-2009  by Eric Ma
              );



    IF p_process_flag <> 'SS' THEN
      rollback;
      return;
    END IF;
    p_repository_id := ln_repository_id;


    jai_cmn_rgm_recording_pkg.do_vat_accounting(
          pn_regime_id            => p_regime_id,
          pn_repository_id        => ln_repository_id,
          pv_organization_type    => p_from_party_type,
          pn_organization_id      => p_from_party_id,
          pd_accounting_date      => trunc(sysdate),
          pd_transaction_date     => p_trx_date,
          pn_credit_amount        => ln_debit_amount,
          pn_debit_amount         => ln_credit_amount,
          pn_credit_ccid          => ln_charge_accounting_id,
          pn_debit_ccid           => ln_balance_accounting_id,
          pv_called_from          => p_called_from,
          pv_process_flag         => p_process_flag,
          pv_process_message      => p_process_message,
          pv_tax_type             => p_from_tax_type,
          pv_source               => lv_source,
          pv_source_trx_type      => p_source_trx_type,
          pv_source_table_name    => p_source_table_name,
          pn_source_id            => p_source_doc_id,
          pv_reference_name       => jai_constants.repository_name,
          pn_reference_id         => ln_repository_id
        );

    IF p_process_flag <> 'SS' THEN
       rollback;
       return;
    END IF;


/*for destination*/


  lv_source := jai_constants.source_settle_in ;
  ln_credit_amount := p_from_trx_amount;  --- these amounts are with respect to repository not w.r.t accounting
  ln_debit_amount  := NULL;             ---  its is reverse w.r.t accounting

  ln_charge_accounting_id := jai_cmn_rgm_recording_pkg.get_account(
              p_regime_id            => p_regime_id,
              p_organization_type    => p_to_party_type,
              p_organization_id      => p_to_party_id,
              p_location_id          => p_to_locn_id,
              p_tax_type             => p_to_tax_type,
              p_account_name         => jai_constants.recovery
            );

  ln_balance_accounting_id :=  jai_cmn_rgm_recording_pkg.get_account(
              p_regime_id            => p_regime_id,
              p_organization_type    => p_from_party_type,
              p_organization_id      => p_from_party_id,
              p_location_id          => p_from_locn_id,
              p_tax_type             => p_from_tax_type,
              p_account_name         => jai_constants.recovery
            );


   jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
              pn_repository_id         => ln_repository_id,
              pn_regime_id             => p_regime_id,
              pv_tax_type              => p_to_tax_type ,
              pv_organization_type     => p_to_party_type,
              pn_organization_id       => p_to_party_id,
              pn_location_id           => p_to_locn_id,
              pv_source                => lv_source,
              pv_source_trx_type       => p_source_trx_type ,
              pv_source_table_name     => p_source_table_name,
              pn_source_id             => p_source_doc_id    ,
              pd_transaction_date      => p_trx_date,
              pv_account_name          => jai_constants.recovery,
              pn_charge_account_id     => ln_charge_accounting_id,
              pn_balancing_account_id  => ln_balance_accounting_id,
              pn_credit_amount         => ln_credit_amount,
              pn_debit_amount          => ln_debit_amount,
              pn_assessable_value      => NULL,
              pn_tax_rate              => NULL,
              pn_reference_id          => NULL,
              pn_batch_id              => NULL,
              pn_inv_organization_id   => p_to_party_id,
              pv_invoice_no            => NULL,
              pv_called_from           =>  p_called_from,
              pv_process_flag          => p_process_flag,
              pv_process_message       => p_process_message,
              pd_invoice_date          => NULL,
              pn_settlement_id         => p_settlement_id   --added for bug#7145898 on 25-Dec-2009  by Eric Ma
          );



  IF p_process_flag <> 'SS' THEN
    rollback;
    return;
  END IF;
  p_repository_id := ln_repository_id;


  jai_cmn_rgm_recording_pkg.do_vat_accounting(
          pn_regime_id            => p_regime_id,
          pn_repository_id        => ln_repository_id,
          pv_organization_type    => p_to_party_type,
          pn_organization_id      => p_to_party_id,
          pd_accounting_date      => trunc(sysdate),
          pd_transaction_date     => p_trx_date,
          pn_credit_amount        => ln_debit_amount,
          pn_debit_amount         => ln_credit_amount,
          pn_credit_ccid          => ln_balance_accounting_id,
          pn_debit_ccid           => ln_charge_accounting_id,
          pv_called_from          => p_called_from,
          pv_process_flag         => p_process_flag,
          pv_process_message      => p_process_message,
          pv_tax_type             => p_to_tax_type,
          pv_source               => lv_source,
          pv_source_trx_type      => p_source_trx_type,
          pv_source_table_name    => p_source_table_name,
          pn_source_id            => p_source_doc_id,
          pv_reference_name       => jai_constants.repository_name,
          pn_reference_id         => ln_repository_id
        );


    IF p_process_flag <> 'SS' THEN
      rollback;
      return;
    END IF;

  commit;

    p_process_flag    := 'SS';

    exception
    when others then
    p_process_flag    := 'UE';
    p_process_message := 'Error in procedure - insert_records_into_register ' || substr(sqlerrm,1,1500);

end insert_into_vat_register;


  PROCEDURE transfer_balance( pn_settlement_id    IN    jai_rgm_stl_balances.settlement_id%TYPE,
                              pv_process_flag OUT NOCOPY VARCHAR2,
                              pv_process_message OUT NOCOPY VARCHAR2)
    IS
      CURSOR c_debit_balance(lv_tax_type jai_rgm_stl_balances.tax_type%TYPE) IS
      SELECT  NVL(debit_balance,0) - NVL(credit_balance,0) debit_balance,
      party_id,
      location_id,
      service_type_code , /* added by ssawant for bug 5879769 */
      party_type,
      rowid
      FROM    jai_rgm_stl_balances
      WHERE   settlement_id = pn_settlement_id
      AND     tax_type = lv_tax_type
      AND     NVL(debit_balance,0) - NVL(credit_balance,0) > 0
      ORDER BY 1 desc;

      CURSOR c_credit_balance(lv_tax_type jai_rgm_stl_balances.tax_type%TYPE) IS
      SELECT  NVL(credit_balance,0) - NVL(debit_balance,0) credit_balance,
      party_id,
      location_id,
      service_type_code ,/* added by ssawant for bug 5879769 */
      party_type,
      rowid
      FROM    jai_rgm_stl_balances
      WHERE   settlement_id = pn_settlement_id
      AND     tax_type = lv_tax_type
      AND     NVL(credit_balance,0) - NVL(debit_balance,0) > 0
      ORDER BY 1 desc;

      CURSOR c_debit_balance_trx(lv_tax_type jai_rgm_stl_balances.tax_type%TYPE,
                                 ln_party_id jai_rgm_stl_balances.party_id%TYPE,
                                 ln_location_id jai_rgm_stl_balances.location_id%TYPE,
                                 lv_party_type jai_rgm_stl_balances.party_type%TYPE
                                 ) IS
      SELECT  (NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0))*-1 debit_balance, organization_id party_id, rowid
      FROM    jai_rgm_trx_records
      WHERE   tax_type = lv_tax_type
      AND     organization_id = ln_party_id
      AND     nvl(location_id,-999) = nvl(ln_location_id,-999)
      AND     organization_type = lv_party_type
      AND     settlement_id <= pn_settlement_id
      AND     NVL(settled_flag,'N') <> 'Y'
      AND     NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0) < 0
      ORDER BY 1 desc;

      CURSOR c_credit_balance_trx(lv_tax_type jai_rgm_stl_balances.tax_type%TYPE,
                                 ln_party_id jai_rgm_stl_balances.party_id%TYPE,
                                 ln_location_id jai_rgm_stl_balances.location_id%TYPE,
                                 lv_party_type jai_rgm_stl_balances.party_type%TYPE
                                 ) IS
      SELECT  NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0) credit_balance, organization_id party_id, rowid
      FROM    jai_rgm_trx_records
      WHERE   tax_type = lv_tax_type
      AND     organization_id = ln_party_id
      AND     nvl(location_id,-999) = nvl(ln_location_id,-999)/*rchandan for Service Type FP*/
      AND     organization_type = lv_party_type
      AND     settlement_id <= pn_settlement_id
      AND     NVL(settled_flag,'N') <> 'Y'
      AND     NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0) > 0
      ORDER BY 1 desc;


   CURSOR cur_regime_id IS
      SELECT regime_id
        FROM jai_rgm_settlements
       WHERE settlement_id = pn_settlement_id;

      lv_regime_id jai_rgm_settlements.regime_id%type;

      cursor cur_regime_code is /*Ravi    */
      select regime_code
        from JAI_RGM_DEFINITIONS
       where regime_id = lv_regime_id;

      cursor cur_dist_detail IS            --  This is ditribution detail sequence
      SELECT JAI_RGM_DIS_DES_TAXES_S.nextval
        FROM DUAL;


   /* added by ssawant for bug 6020629 */
    CURSOR c_acct_balances IS
    SELECT  *
    FROM    jai_rgm_stl_balances
    WHERE   NVL(debit_balance,0) >= 0
    AND     NVL(credit_balance,0) >= 0
    AND     settlement_id = pn_settlement_id;

    /*CURSOR cur_regno IS
    SELECT primary_registration_no
      FROM jai_rgm_settlements
     WHERE settlement_id = pn_settlement_id;*/
    /*rchandan for bug#5642053..commented the above cursor and defined the following cursor*/

    CURSOR cur_stl_details IS
    SELECT jstl.primary_registration_no,
           jbal.party_type             ,
           jbal.party_id               ,
           jbal.location_id
      FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
     WHERE jbal.settlement_id = jstl.settlement_id
       AND jbal.settlement_id = pn_settlement_id;


/*    CURSOR cur_inv_payment(lp_regn_no         VARCHAR2)
        IS
--        || This cursor is used to get the total invoice amount paid
--        || when the last settlement was made
        SELECT sum(credit_amount)
        FROM   jai_rgm_trx_records
        WHERE  regime_primary_regno = lp_regn_no
        AND    source_trx_type      = 'Invoice Payment'
        AND    transaction_date     = ( select max(settlement_date) + 1
                                          from jai_rgm_stl_balances a
                                         where 2 = (select count(distinct jbal.settlement_date)
                                                      from jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                                    where  jbal.settlement_id = jstl.settlement_id
                                                      and  jstl.primary_registration_no =  lp_regn_no and jbal.settlement_date >= a.settlement_date));


        CURSOR cur_balances(lp_org_id number,lp_tax_type varchar2,lp_regn_no varchar2)  --4287372
        IS
        --|| This cursor is used to retrieve the sum of credit and debit balances as on
        --|| last settlement date for the given registration number
        SELECT sum(jbal.credit_balance) credit_balance,sum(jbal.debit_balance) debit_balance
        FROM   jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
        WHERE  jbal.settlement_id           = jstl.settlement_id
        AND    jstl.primary_registration_no = lp_regn_no
        AND    jbal.tax_type                = lp_tax_type
        AND    jbal.party_id                = lp_org_id
        AND    jstl.settlement_date         = ( select max(settlement_date)
                                          from jai_rgm_stl_balances a
                                         where 2 = (select count(distinct jbal.settlement_date)
                                                      from jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                                    where  jbal.settlement_id = jstl.settlement_id
                                                      and  jstl.primary_registration_no =  lp_regn_no and jbal.settlement_date >= a.settlement_date ));

*/

    /*rchandan for bug#5642053. Commented the above cursors and redefined them as follows*/

     CURSOR cur_inv_payment(cp_regn_no     VARCHAR2,
                            cp_org_type    VARCHAR2,
                            cp_org_id      NUMBER,
                            cp_location_id NUMBER)
     IS
     /*
      || This cursor is used to get the total invoice amount paid
      || when the last settlement was made
     */
      SELECT sum(credit_amount)
      FROM   jai_rgm_trx_records
      WHERE  source_trx_type      = 'Invoice Payment'
      AND    settlement_id        = ( SELECT MAX(jbal.settlement_id)
                                        FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                       WHERE jbal.settlement_id           = jstl.settlement_id
                                         AND jstl.primary_registration_no = cp_regn_no
                                         AND jbal.party_type              = cp_org_type
                                         AND jbal.party_id                = cp_org_id
                                         AND nvl(jbal.location_id,-999)   = nvl(cp_location_id,-999)
                                         AND jbal.settlement_id          <> pn_settlement_id /*This clause is used to exclude the current settlement*/
                                    );

      CURSOR cur_balances(cp_regn_no      VARCHAR2 ,
                          cp_org_type     VARCHAR2 ,
                          cp_org_id       NUMBER   ,
                          cp_location_id  NUMBER   ,
                          cp_tax_type     VARCHAR2 )
      IS
      /*
      || This cursor is used to retrieve the sum of credit and debit balances as on
      || last settlement date for the given registration number,organization and location grouped at the tax type
      */
      SELECT sum(credit_balance) credit_balance,sum(debit_balance) debit_balance
        FROM jai_rgm_stl_balances
       WHERE settlement_id                = ( SELECT MAX(jbal.settlement_id)
                                                FROM jai_rgm_stl_balances jbal,jai_rgm_settlements jstl
                                               WHERE jbal.settlement_id           = jstl.settlement_id
                                                 AND jstl.primary_registration_no = cp_regn_no
                                                 AND jbal.party_type              = cp_org_type
                                                 AND jbal.party_id                = cp_org_id
                                                 AND nvl(jbal.location_id,-999)   = nvl(cp_location_id,-999)
                                                 AND jbal.settlement_id          <> pn_settlement_id/*This clause is used to exclude the current settlement*/
                                            )
         AND tax_type                      = cp_tax_type;



      ln_debit_cnt      NUMBER;
      ln_credit_cnt     NUMBER;
      ln_credit_balance NUMBER;
      ln_transfer_amt   NUMBER;
      ln_repository_id  NUMBER;
      lv_regime_code    JAI_RGM_DEFINITIONS.regime_code%type;/* Ravi*/
      lv_statement      NUMBER;
      ln_dist_dtl_id    NUMBER;
      ln_acct_amount           NUMBER; /* added by ssawant for bug 6020629 */
      ln_charge_accounting_id  jai_rgm_trx_records.charge_account_id%type; /* added by ssawant for bug 6020629 */
      lv_organization_type     VARCHAR2(10); /* added by ssawant for bug 6020629 */
      ln_invoice_amount        jai_rgm_trx_records.credit_amount%type ;  /* added by ssawant for bug 6020629 */
      rec_balances             cur_balances%ROWTYPE;/* added by ssawant for bug 6020629 */
      lv_regn_no               jai_rgm_settlements.primary_registration_no%type;
      /*rchandan for bug#5642053 start*/
      ln_organization_id       jai_rgm_stl_balances.party_id%TYPE;
      ln_location_id           jai_rgm_stl_balances.location_id%TYPE;
      lv_org_type              jai_rgm_stl_balances.party_type%TYPE;
      /*rchandan for bug#5642053 end*/

    BEGIN
  /*  */
  -- #****************************************************************************************************************************************************************************************
  -- #
  -- # Change History -
  -- # 1. 27-Jan-2005   Sanjikum for Bug #4059774 Version #115.0
  -- #                  New Package created for Service Tax settlement
  -- #
  -- # 2. 23-Dec-2009   Eric Ma for bug#7145898
  -- #          ISSUE: VAT SETTLEMENT NOT HAPPENING AT REGISTRATION LEVEL ON HAVING MORE THEN ONE OU
  -- #            Fix: Added the parameter pn_settlement_id in the call to the procedure
  -- #                           jai_rgm_trx_recording_pkg.insert_vat_repository_entry.
  -- # Future Dependencies For the release Of this Object:-
  -- # (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  -- #  A datamodel change )

  --==============================================================================================================
  -- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- #  Current Version       Current Bug    Dependent           Files                                  Version     Author   Date         Remarks
  -- #  Of File                              On Bug/Patchset    Dependent On
  -- #  jai_rgm_settlement_pkg_b.sql
  -- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- #  115.0                 4068930       4146708                                                                 Sanjikum 27/01/2005   This file is part of Service tax enhancement. So
  -- #                                                                                                                                    dependent on Service Tax and Education Cess Enhancement
  -- #  115.1                 4245365       4245089                                                                 rchandan 17/03/2005   Changes made to implement VAT
  -- #  115.2                 4245365       4245089                                                                 rchandan 20/03/2005   Punching of settlement id in the repository for Invoice Payment happens here from now
  -- #                                                                                                                                    as this record is not considered while settlement.
  -- #  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- # ****************************************************************************************************************************************************************************************

      pv_process_flag := 'SS';


          OPEN cur_regime_id;
    FETCH cur_regime_id INTO lv_regime_id;
    CLOSE cur_regime_id;

    OPEN cur_regime_code;
    FETCH cur_regime_code INTO lv_regime_code;
    CLOSE cur_regime_code;
    /*rchandan for bug#5642053*/
    OPEN cur_stl_details;
    FETCH cur_stl_details INTO lv_regn_no,lv_org_type,ln_organization_id,ln_location_id;
    CLOSE cur_stl_details;


    OPEN cur_inv_payment(lv_regn_no,lv_org_type,ln_organization_id,ln_location_id);   /*rchandan for bug#5642053*/
    FETCH cur_inv_payment INTO ln_invoice_amount;
    CLOSE cur_inv_payment;


      /*start added by ssawant for bug 6020629 */
      FOR r_acct_balances IN c_acct_balances
      LOOP
        ln_acct_amount := 0;

        OPEN  cur_balances(lv_regn_no,r_acct_balances.party_type,r_acct_balances.party_id,r_acct_balances.location_id,r_acct_balances.tax_type);   -- rchandan for bug#5642053
        FETCH cur_balances INTO rec_balances;
        CLOSE cur_balances;

        IF NVL(r_acct_balances.debit_balance,0) - NVL(r_acct_balances.credit_balance,0) > 0 THEN

          ln_acct_amount := NVL(r_acct_balances.credit_balance,0);

/*Commented out by Eric Ma on 12-dec-2009, for bug 7031751,begin
          IF nvl(ln_invoice_amount,0) = 0 and ( nvl( rec_balances.credit_balance,0) <> nvl( rec_balances.debit_balance,0) ) THEN   -- added by ssawant for bug 6020629

          || If no invoice payment was made at the last settlement and if the credit and debit balances are not
          || equal in the previous settlement then the previous settled balance is deducted before making
          || accounting entries

            ln_acct_amount := ln_acct_amount - nvl( rec_balances.credit_balance,0);
          END IF;
Commented out by Eric Ma for bug 7031751,end*/

        ELSE

          ln_acct_amount  :=  NVL(r_acct_balances.debit_balance,0);
/* Commented out by Eric Ma on 12-dec-2009, for bug 7031751,begin
          IF nvl(ln_invoice_amount,0) = 0 and ( nvl( rec_balances.credit_balance,0) <> nvl( rec_balances.debit_balance,0) ) THEN-- added by ssawant for bug 6020629

          || If no invoice payment was made at the last settlement and if the credit and debit balances are not
          || equal in the previous settlement then the previous settled balance is deducted before making an
          || accounting entries

             ln_acct_amount := ln_acct_amount - nvl( rec_balances.debit_balance,0);
          END IF;
Commented out by Eric Ma for bug 7031751,end*/
        END IF;

        IF lv_regime_code       = jai_constants.service_regime THEN
          lv_organization_type := jai_constants.orgn_type_io;/* added by ssawant for bug 5879769 */
          ln_acct_amount       := ROUND(ln_acct_amount, jai_constants.service_rgm_rnd_factor);
        ELSIF lv_regime_code    = jai_constants.vat_regime THEN
          lv_organization_type := jai_constants.orgn_type_io;
          ln_acct_amount       := ROUND(ln_acct_amount, jai_constants.vat_rgm_rnd_factor);
        END IF;

        IF ln_acct_amount <> 0 THEN  /* added by ssawant for bug 6020629 */
          ln_charge_accounting_id :=
          jai_cmn_rgm_recording_pkg.get_account(p_regime_id         => lv_regime_id,
                                                p_organization_type => lv_organization_type,
                                                p_organization_id   => r_acct_balances.party_id,
                                                p_location_id       => r_acct_balances.location_id,
                                                p_tax_type          => r_acct_balances.tax_type,
                                                p_account_name      => jai_constants.liability);


          jai_cmn_rgm_recording_pkg.post_accounting(
            p_regime_code         => lv_regime_code,
            p_tax_type            => r_acct_balances.tax_type,
            p_organization_type   => lv_organization_type,
            p_organization_id     => r_acct_balances.party_id,
            p_source              => jai_constants.source_settle_in,
            p_source_trx_type     => 'Invoice Payment',
            p_source_table_name   => 'JAI_RGM_SETTLEMENTS',
            p_source_document_id  => pn_settlement_id,
            p_code_combination_id => ln_charge_accounting_id,
            p_entered_cr          => NULL,
            p_entered_dr          => ln_acct_amount,
            p_accounted_cr        => NULL,
            p_accounted_dr        => ln_acct_amount,
           -- p_accounting_date     => SYSDATE, commented by anujsax for bug #6126142
	    p_accounting_date     => r_acct_balances.settlement_date, --added by anujsax  for Bug#6126142
            p_transaction_date    => r_acct_balances.settlement_date,
            p_calling_object      => 'JAIRGMSP',
            p_repository_name     => jai_constants.repository_name,
            p_repository_id       => NULL,
            p_reference_name      => NULL,
            p_reference_id        => NULL,
            p_currency_code       => jai_constants.func_curr);

          IF pv_process_flag <> 'SS' THEN
            goto MAIN_EXIT;
          END IF;

        END IF;

        IF ln_acct_amount <> 0 THEN

          ln_charge_accounting_id :=
          jai_cmn_rgm_recording_pkg.get_account(p_regime_id         => lv_regime_id,
                                                p_organization_type => lv_organization_type,
                                                p_organization_id   => r_acct_balances.party_id,
                                                p_location_id       => r_acct_balances.location_id,
                                                p_tax_type          => r_acct_balances.tax_type,
                                                p_account_name      => jai_constants.recovery);

          jai_cmn_rgm_recording_pkg.post_accounting(
            p_regime_code         => lv_regime_code,
            p_tax_type            => r_acct_balances.tax_type,
            p_organization_type   => lv_organization_type,
            p_organization_id     => r_acct_balances.party_id,
            p_source              => jai_constants.source_settle_in,
            p_source_trx_type     => 'Invoice Payment',
            p_source_table_name   => 'JAI_RGM_SETTLEMENTS',
            p_source_document_id  => pn_settlement_id,
            p_code_combination_id => ln_charge_accounting_id,
            p_entered_cr          => ln_acct_amount,
            p_entered_dr          => NULL,
            p_accounted_cr        => ln_acct_amount,
            p_accounted_dr        => NULL,
            -- p_accounting_date     => SYSDATE, commented by anujsax for bug #6126142
	    p_accounting_date     => r_acct_balances.settlement_date, --added by anujsax  for Bug#6126142
            p_transaction_date    => r_acct_balances.settlement_date,
            p_calling_object      => 'JAIRGMSP',
            p_repository_name     => jai_constants.repository_name,
            p_repository_id       => NULL,
            p_reference_name      => NULL,
            p_reference_id        => NULL,
            p_currency_code       => jai_constants.func_curr);

          IF pv_process_flag <> 'SS' THEN
            goto MAIN_EXIT;
          END IF;

        END IF;


      END LOOP;
/*End added by ssawant for bug 6020629 */




      FOR I in (select  distinct b.regime_id, b.settlement_date, a.tax_type
                from    jai_rgm_stl_balances a,
                        jai_rgm_settlements b
                where   a.settlement_id = b.settlement_id
                AND     a.settlement_id = pn_settlement_id)
      LOOP
        SELECT  count(*)
        INTO    ln_debit_cnt
        FROM    jai_rgm_stl_balances
        WHERE   settlement_id = pn_settlement_id
        AND     debit_balance >0;


        IF ln_debit_cnt = 0 THEN
          --There is no Debit balance
          goto End_loop;
        END IF;

        SELECT  count(*)
        INTO    ln_credit_cnt
        FROM    jai_rgm_stl_balances
        WHERE   settlement_id = pn_settlement_id
        AND     credit_balance >0;


        IF ln_credit_cnt = 0 THEN
          --There is no Credit balance
          goto End_loop;
        END IF;

        FOR cur_credit in c_credit_balance(i.tax_type) LOOP
          ln_credit_balance := cur_credit.credit_balance;


          FOR cur_debit in c_debit_balance(i.tax_type) LOOP


            IF ln_credit_balance >= cur_debit.debit_balance THEN
              ln_credit_balance := ln_credit_balance - cur_debit.debit_balance;
              ln_transfer_amt := cur_debit.debit_balance;
            ELSE
              ln_transfer_amt := ln_credit_balance;
              ln_credit_balance := 0;
            END IF;

            OPEN cur_regime_id;
           FETCH cur_regime_id INTO lv_regime_id;
           CLOSE cur_regime_id;

            OPEN  cur_regime_code;
            FETCH cur_regime_code INTO lv_regime_code;
            CLOSE cur_regime_code;


            IF lv_regime_code = jai_constants.service_regime THEN /* 4245365*/


        jai_cmn_rgm_tax_dist_pkg.insert_records_into_register
              (p_repository_id => ln_repository_id,
              p_regime_id => i.regime_id,
              p_from_party_type => cur_credit.party_type,
              p_from_party_id => cur_credit.party_id,
              p_from_locn_id => cur_credit.location_id,/* added by ssawant for bug 5879769 */
              p_from_tax_type => i.tax_type,
	      p_from_service_type => cur_credit.service_type_code,/* added by ssawant for bug 5879769 */
              p_from_trx_amount => ln_transfer_amt,
              p_to_party_type => cur_debit.party_type,
              p_to_party_id => cur_debit.party_id,
              p_to_locn_id => cur_debit.location_id,/* added by ssawant for bug 5879769 */
              p_to_tax_type => i.tax_type,
	      p_to_service_type   => cur_debit.service_type_code,/* added by ssawant for bug 5879769 */
              p_to_trx_amount => ln_transfer_amt,
              p_called_from => 'SETTLEMENT',
              p_trx_date => i.settlement_date,
              p_acct_req => jai_constants.yes,
              p_source => 'SETTLEMENT',
              p_source_trx_type => 'SETTLEMENT',
              p_source_table_name => 'JAI_RGM_SETTLEMENTS',
              p_source_doc_id => pn_settlement_id,
              p_settlement_id => pn_settlement_id,
              p_reference_id => NULL,
              p_process_flag => pv_process_flag,
              p_process_message => pv_process_message,
              p_accounting_date => i.settlement_date);

        IF pv_process_flag <> 'SS' THEN
          goto MAIN_EXIT;
        END IF;

            ELSIF lv_regime_code = jai_constants.vat_regime THEN /* 4245365*/


            OPEN cur_dist_detail;
           FETCH cur_dist_detail INTO ln_dist_dtl_id;
           CLOSE cur_dist_detail;

           insert_into_vat_register(p_repository_id => ln_repository_id,
                  p_regime_id => i.regime_id,
                  p_from_party_type => cur_credit.party_type,
                  p_from_party_id => cur_credit.party_id,
                  p_from_locn_id => cur_credit.location_id,    --added for bug#7145898 on 25-Dec-2009 by Eric Ma
                  p_from_tax_type => i.tax_type,
                  p_from_trx_amount => ln_transfer_amt,
                  p_to_party_type => cur_debit.party_type,
                  p_to_party_id => cur_debit.party_id,
                  p_to_locn_id => cur_debit.location_id,
                  p_to_tax_type => i.tax_type,
                  p_to_trx_amount => ln_transfer_amt,
                  p_called_from => 'SETTLEMENT',
                  p_trx_date => i.settlement_date,
                  p_acct_req => jai_constants.yes,
                  p_source => 'SETTLEMENT',
                  p_source_trx_type => 'SETTLEMENT',
                  p_source_table_name => 'JAI_RGM_SETTLEMENTS',
                  p_source_doc_id => ln_dist_dtl_id,
                  p_settlement_id => pn_settlement_id,
                  p_reference_id => NULL,
                  p_process_flag => pv_process_flag,
                  p_process_message => pv_process_message,
                      p_accounting_date => i.settlement_date);


                 IF pv_process_flag <> 'SS' THEN
               goto MAIN_EXIT;
             END IF;



            END IF;

         IF lv_regime_code NOT IN (jai_constants.service_regime,jai_constants.vat_regime) THEN
		 /* added by vumaasha for bug 7606212 */

            update  jai_rgm_stl_balances
            SET     debit_balance = debit_balance - ln_transfer_amt
            WHERE   rowid = cur_debit.rowid;

            update  jai_rgm_stl_balances
            SET     credit_balance = credit_balance - ln_transfer_amt
            WHERE   rowid = cur_credit.rowid;

		 END IF;

            EXIT WHEN ln_credit_balance = 0;
          END LOOP;
        END LOOP;

        <<End_loop>>
        NULL;
      END LOOP;

      --for each transaction
      FOR I in (select  *
                from    jai_rgm_stl_balances
                where   settlement_id = pn_settlement_id)
      LOOP
        IF NVL(i.debit_balance,0) = NVL(i.credit_balance,0) THEN
          UPDATE  jai_rgm_trx_records
          SET     settled_flag = 'Y',
                  settled_amount = NULL
          WHERE   tax_type = i.tax_type
          AND     organization_id = i.party_id
          AND     nvl(location_id,-999) = nvl(i.location_id,-999)
          AND     organization_type = i.party_type
          AND     settlement_id <= pn_settlement_id;
        ELSE

          SELECT  count(*)
          INTO    ln_debit_cnt
          FROM    jai_rgm_trx_records
          WHERE   tax_type = i.tax_type
          AND     organization_id = i.party_id
          AND     nvl(location_id,-999)  = nvl(i.location_id,-999)
          AND     organization_type = i.party_type
          AND     settlement_id <= pn_settlement_id
          AND     NVL(settled_flag,'N') <> 'Y'
          AND     NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0) < 0;

          IF ln_debit_cnt = 0 THEN
            --There is no Debit balance
            goto End_loop_txn;
          END IF;

          SELECT  count(*)
          INTO    ln_credit_cnt
          FROM    jai_rgm_trx_records
          WHERE   tax_type = i.tax_type
          AND     organization_id = i.party_id
          AND     nvl(location_id,-999)  = nvl(i.location_id,-999)
          AND     organization_type = i.party_type
          AND     settlement_id <= pn_settlement_id
          AND     NVL(settled_flag,'N') <> 'Y'
          AND     NVL(credit_amount,0) - NVL(debit_amount,0) - NVL(settled_amount,0) > 0;

          IF ln_credit_cnt = 0 THEN
            --There is no Credit balance
            goto End_loop_txn;
          END IF;

          FOR cur_credit in c_credit_balance_trx(i.tax_type, i.party_id,i.location_id, i.party_type) LOOP
            ln_credit_balance := cur_credit.credit_balance;

            FOR cur_debit in c_debit_balance_trx(i.tax_type, i.party_id,i.location_id, i.party_type) LOOP
              IF ln_credit_balance >= cur_debit.debit_balance THEN
                ln_credit_balance := ln_credit_balance - cur_debit.debit_balance;
                ln_transfer_amt := cur_debit.debit_balance;
              ELSE
                ln_transfer_amt := ln_credit_balance;
                ln_credit_balance := 0;
              END IF;

              UPDATE  jai_rgm_trx_records
              SET     settled_amount = NVL(settled_amount,0) - ln_transfer_amt,
                      settled_flag = 'P'
              WHERE   rowid = cur_debit.rowid;

              UPDATE  jai_rgm_trx_records
              SET     settled_amount = NVL(settled_amount,0) + ln_transfer_amt,
                      settled_flag = 'P'
              WHERE   rowid = cur_credit.rowid;

              EXIT WHEN ln_credit_balance = 0;
            END LOOP;

          END LOOP;
        END IF;

        <<End_loop_txn>>

        UPDATE  jai_rgm_trx_records
        SET     settled_flag = 'Y',
                settled_amount = debit_amount*-1
        WHERE   settlement_id <= pn_settlement_id
        AND     organization_id = i.party_id
        AND     organization_type = i.party_type
        AND     nvl(location_id,-999)  = nvl(i.location_id,-999)
        AND     tax_type = i.tax_type
        AND     debit_amount > 0
        AND     debit_amount = settled_amount*-1;

        UPDATE  jai_rgm_trx_records
        SET     settled_flag = 'Y',
                settled_amount = credit_amount
        WHERE   settlement_id <= pn_settlement_id
        AND     organization_id = i.party_id
        AND     nvl(location_id,-999)  = nvl(i.location_id,-999)
        AND     organization_type = i.party_type
        AND     tax_type = i.tax_type
        AND     credit_amount > 0
        AND     credit_amount = settled_amount;

      END LOOP;

      <<MAIN_EXIT>>
      NULL;

    EXCEPTION
      WHEN OTHERS THEN
        pv_process_flag := 'UE';
        pv_process_message := SUBSTR(SQLERRM,1,200);
    END transfer_balance;


  PROCEDURE create_invoice( pn_regime_id          IN  jai_rgm_settlements.regime_id%TYPE,
                            pn_settlement_id      IN  jai_rgm_settlements.settlement_id%TYPE,
                            pd_settlement_date    IN  jai_rgm_settlements.settlement_date%TYPE,
                            pn_vendor_id          IN  jai_rgm_settlements.tax_authority_id%TYPE,
                            pn_vendor_site_id     IN  jai_rgm_settlements.tax_authority_site_id%TYPE,
                            pn_calculated_amount  IN  jai_rgm_settlements.calculated_amount%TYPE,
                            pn_invoice_amount     IN  jai_rgm_settlements.payment_amount%TYPE,
                            pn_org_id             IN  jai_rgm_stl_balances.party_id%TYPE,
                            pv_regsitration_no    IN  jai_rgm_settlements.primary_registration_no%TYPE,
                            pn_created_by         IN  ap_invoices_interface.created_by%TYPE,
                            pd_creation_date      IN  ap_invoices_interface.creation_date%TYPE,
                            pn_last_updated_by    IN  ap_invoices_interface.last_updated_by%TYPE,
                            pd_last_update_date   IN  ap_invoices_interface.last_update_date%TYPE,
                            pn_last_update_login  IN  ap_invoices_interface.last_update_login%TYPE,
                            pv_system_invoice_no OUT NOCOPY jai_rgm_settlements.system_invoice_no%TYPE,
                            pv_process_flag OUT NOCOPY VARCHAR2,
                            pv_process_message OUT NOCOPY VARCHAR2)
  IS

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * (1) Removed the cursor c_functional_currency which is referring
     * to hr_operating_units and implemented using caching logic.
     * (2) Removed cursor cur_currency_precision as the precision
     * is derived using caching logic.
     */

    CURSOR for_terms_id(ven_id NUMBER,ven_site_id NUMBER) IS
    SELECT  terms_id,
            --payment_method_lookup_code, --commented the column by Sanjikum for Bug#4482462
            pay_group_lookup_code
    FROM    po_vendor_sites_all
    WHERE   vendor_id = pn_vendor_id
    AND     vendor_site_id = pn_vendor_site_id;

    CURSOR for_terms_id_2(ven_id NUMBER) IS
    SELECT  terms_id,
            --payment_method_lookup_code, --commented the column by Sanjikum for Bug#4482462
            pay_group_lookup_code
    FROM    po_vendors
    WHERE   vendor_id = pn_vendor_id;

    CURSOR counter_cur(pn_invoice_id ap_invoices_interface.invoice_id%TYPE) IS
    SELECT  NVL(MAX(line_number),0)
    FROM    ap_invoice_lines_interface
    -- bug 4929081. Added by Lakshmi Gopalsami
    WHERE invoice_id = pn_invoice_id;

    CURSOR cur_invoice_no IS
    SELECT  jai_rgm_settlements_s1.NEXTVAL --rchandan for bug#4487676. JAI_RGM_SETTLEMENT_INVOICE_S is replaced with JAI_RGM_SETTLEMENTS_S1
    FROM    dual;

  /* commented the below cursor by ssawant for bug 5879769
    CURSOR cur_distributions IS
    SELECT  tax_type, debit, credit, NVL(debit,0) - NVL(credit,0) balance_amount
    FROM    JAI_RGM_STL_BALANCES_V
    WHERE   settlement_id = pn_settlement_id
    AND     NVL(debit,0) - NVL(credit,0) > 0;
    */
    /*
    || added by ssawant for bug 5879769 . Commented the above cursor and added the following
    */
    CURSOR cur_distributions_SERVICE
    IS
    SELECT party_id                          ,
           location_id                       ,
           service_type_code                 ,
           tax_type                          ,
		       sum(debit_balance) debit_balance  ,
		       sum(credit_balance) credit_balance,
		       NVL(sum(debit_balance),0) - NVL(sum(credit_balance),0) balance_amount
		  FROM JAI_RGM_STL_BALANCES
		 WHERE settlement_id = pn_settlement_id
		 GROUP BY party_id,location_id,service_type_code,tax_type
    HAVING sum(debit_balance) - sum(credit_balance) > 0 ;


    CURSOR cur_distributions_VAT IS
    SELECT party_id,location_id,tax_type,
           sum(debit_balance) debit_balance, sum(credit_balance) credit_balance,
           NVL(sum(debit_balance),0) - NVL(sum(credit_balance),0) balance_amount
      FROM JAI_RGM_STL_BALANCES
    WHERE   settlement_id = pn_settlement_id
    GROUP BY party_id,location_id,tax_type
    HAVING sum(debit_balance) - sum(credit_balance) > 0 ;

		CURSOR cur_distributions_TCS IS /*Added By CSahoo BUG#5631784*/
		SELECT party_id,location_id,tax_type,
					 sum(debit_balance) debit_balance, sum(credit_balance) credit_balance,
					 NVL(sum(debit_balance),0) - NVL(sum(credit_balance),0) balance_amount
			FROM JAI_RGM_STL_BALANCES
		WHERE   settlement_id = pn_settlement_id
    GROUP BY party_id,location_id,tax_type;

    CURSOR cur_tax_types(p_reg_type  jai_rgm_registrations.registration_type%TYPE )IS   --rchandan for bug#4428980
    SELECT  attribute_sequence, attribute_code tax_type, RATE
    FROM    JAI_RGM_REGISTRATIONS
    WHERE   regime_id = pn_regime_id
    AND     registration_type = p_reg_type--rchandan for bug#4428980
    ORDER BY 1 ASC;

    CURSOR cur_regime_code IS      /* 4245365*/
    SELECT regime_code,description
      FROM JAI_RGM_DEFINITIONS
     WHERE regime_id = pn_regime_id;

    CURSOR cur_org_io IS
    SELECT party_id,location_id
      FROM jai_rgm_stl_balances
     WHERE settlement_id = pn_settlement_id
     GROUP BY party_id,location_id
     HAVING sum(debit_balance) - sum(credit_balance) > 0;

    -- Bug 4929081. Added by Lakshmi Gopalsami

    CURSOR cur_inv_exists(pn_invoice_id  IN ap_invoices_interface.invoice_id%TYPE) IS
    SELECT  'Y'
      FROM  ap_invoices_interface
     WHERE  invoice_id = pn_invoice_id;


    lv_invoice_num              ap_invoices_interface.invoice_num%TYPE;
    lv_currency_code            gl_sets_of_books.currency_code%TYPE;
    for_terms_id_rec            for_terms_id%ROWTYPE;
    counter_tds_dm_v            NUMBER;
    ln_tmp                      NUMBER;
    ln_dist_code_combination_id ap_invoice_lines_interface.dist_code_combination_id%TYPE;
    lv_tax_type                jai_rgm_stl_balances.tax_type%TYPE;
    lv_tax_type1                jai_rgm_stl_balances.tax_type%TYPE;
    lv_tax_type2                jai_rgm_stl_balances.tax_type%TYPE;
    ln_amount                  jai_rgm_stl_balances.debit_balance%TYPE;
    ln_amount1                  jai_rgm_stl_balances.debit_balance%TYPE;
    ln_amount2                  jai_rgm_stl_balances.debit_balance%TYPE;
    ln_rate                     JAI_RGM_REGISTRATIONS.rate%TYPE;
    v_open_period               gl_period_statuses.period_name%type;
    v_open_gl_date              date;
    lv_inv_exists               varchar2(1) := 'N' ; -- Bug 4929081
    req_id                      NUMBER;
    ln_invoice_amount           NUMBER;
    ln_precision                fnd_currencies.precision%TYPE;
    ln_invoice_id               NUMBER;
    ln_invoice_line_id          NUMBER;
    lv_regime                   cur_regime_code%rowtype    ;/* 4245365*/
    ln_org_id                   NUMBER;
    org_io_rec                  cur_org_io%ROWTYPE;

    /* Bug5243532. Added by Lakshmi Gopalsami
       Defined the variable for implementing caching logic.
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;

  BEGIN

    pv_process_flag := 'SS';

    OPEN cur_regime_code;                       /* 4245365*/
    FETCH cur_regime_code INTO lv_regime;
    CLOSE cur_regime_code;


    OPEN cur_invoice_no;
    FETCH cur_invoice_no INTO ln_tmp;
    CLOSE cur_invoice_no;

    lv_invoice_num := upper(lv_regime.regime_code)||'/'||pn_org_id||'/'||ln_tmp; /*4245365*/

    /* Bug 5373747. Added by Lakshmi Gopalsami
     * Set the policy context before calling AP API
     */
    mo_global.set_policy_context('S', pn_org_id);

    /* Bug 5243532. Added by Lakshmi Gopalsami
     * Removed the reference to hr_operating_units
     * and implemented using caching logic for getting functional currency
     * and precision.
     */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                           (p_org_id  => pn_org_id );

    lv_currency_code := l_func_curr_det.currency_code;
    ln_precision     := l_func_curr_det.precision;

    -- Bug 4929081. Added by Lakshmi Gopalsami
    -- Moved the cursor after inserting headers.

    OPEN  for_terms_id(pn_vendor_id,pn_vendor_site_id);
    FETCH for_terms_id INTO for_terms_id_rec;
    CLOSE for_terms_id;

    IF ((for_terms_id_rec.terms_id IS  NULL)                   OR
        --(for_terms_id_rec.payment_method_lookup_code IS  NULL) OR --commented by Sanjikum for Bug#4482462
        (for_terms_id_rec.pay_group_lookup_code IS  NULL)
       ) THEN

      OPEN  for_terms_id_2(pn_vendor_id);
      FETCH for_terms_id_2 INTO for_terms_id_rec;
      CLOSE for_terms_id_2;
    END IF;
--commented by anujsax for bug 6126142
  --  v_open_period := ap_utilities_pkg.get_current_gl_date(TRUNC(pd_creation_date)
      --                                                    ,pn_org_id /* Added by Ramananda for bug#4559828 */
          --      	  );
-- added by anujsax for bug 6126142
  v_open_period := ap_utilities_pkg.get_current_gl_date(TRUNC(pd_settlement_date)
                                                         ,pn_org_id /* Added by Ramananda for bug#4559828 */
                                                         );
--ended by anujsax for bug 6126142
    if v_open_period is null then

      ap_utilities_pkg.get_open_gl_date (
                           -- TRUNC(pd_creation_date),/*commented by anujsax for bug#6126142*/
			    TRUNC(pd_settlement_date),/* addded by anujsax for bug#6126142*/
                            v_open_period,
                            v_open_gl_date
                            ,pn_org_id /* Added by Ramananda for bug#4559828 */
                            );

      if v_open_period is null then
        raise_application_error(-20001,'No Open period ... after '||pd_settlement_date);
      end if;
    else
    --commented by anujsax for bug 6126142
    --  v_open_gl_date := TRUNC(pd_creation_date);
    --added by anujsax for bug 6126142
    v_open_gl_date := TRUNC(pd_settlement_date);
     --ended by anujsax for bug 6126142
    end if;

    jai_ap_utils_pkg.insert_ap_inv_interface(
                    p_jai_source                  => 'SETTLEMENT',
                    p_invoice_id                  => ln_invoice_id,
                    p_invoice_num                 => lv_invoice_num,
                    p_invoice_date                => v_open_gl_date,
                    p_gl_date                     => v_open_gl_date,
                    p_vendor_id                   => pn_vendor_id,
                    p_vendor_site_id              => pn_vendor_site_id,
                    p_invoice_amount              => ROUND(pn_invoice_amount, ln_precision),
                    p_invoice_currency_code       => lv_currency_code,
                    p_terms_id                    => for_terms_id_rec.terms_id,
                    p_description                 => 'Settlement of '||lv_regime.description||' Liability on '||pd_settlement_date||' for registration no '||pv_regsitration_no,      /*4245365*/
    		    /* Bug 5359044. Added by Lakshmi Gopalsami
		     * Changed the p_source from 'EXTERNAL'
		     * to 'INDIA TAX SETTLEMENT INVOICES'
		     */
                    /* Bug 5373747. Added by Lakshmi Gopalsami
                     * As per the discussion with AP Team changing the source
                     * as 'INDIA TAX SETTLEMENT'
                     */
                    p_source                      => 'INDIA TAX SETTLEMENT',
                    p_voucher_num                 => lv_invoice_num,
                    --p_payment_method_lookup_code  => for_terms_id_rec.payment_method_lookup_code, --commented by Sanjikum for Bug#4482462
                    p_pay_group_lookup_code       => for_terms_id_rec.pay_group_lookup_code,
                    p_org_id                      => pn_org_id,
                    p_created_by                  => pn_created_by,
                    p_creation_date               => pd_creation_date,
                    p_last_updated_by             => pn_last_updated_by,
                    p_last_update_date            => pd_last_update_date,
                    p_last_update_login           => pn_last_update_login);

    -- Bug 4929081. Added by Lakshmi Gopalsami
    -- Moved the cursor here so that invoice_id can be used
    -- in the cursor.
    OPEN  counter_cur(ln_invoice_id);
    FETCH counter_cur INTO counter_tds_dm_v ;
    CLOSE counter_cur;

    IF upper(lv_regime.regime_code) = 'SERVICE' THEN

      FOR i IN cur_distributions_SERVICE LOOP /* added by ssawant for bug 5879769 */

  ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
                p_regime_id         =>  pn_regime_id,
                p_organization_type =>  jai_constants.orgn_type_io,/* added by ssawant for bug 5879769 */
                p_organization_id   =>  i.party_id,/* added by ssawant for bug 5879769 */
                p_location_id       =>  i.location_id,/* added by ssawant for bug 5879769 */
                p_tax_type          =>  i.tax_type,
                p_account_name      =>  jai_constants.liability);

        IF ln_dist_code_combination_id IS NULL THEN
          pv_process_flag := 'EE';
          pv_process_message := 'There is no account defined for AP Invoice creation. Can''t proceed';
          goto MAIN_EXIT;
        END IF;

        IF i.balance_amount <> 0 THEN

        counter_tds_dm_v := counter_tds_dm_v + 1;

        jai_ap_utils_pkg.insert_ap_inv_lines_interface(
                      p_jai_source                  => 'SETTLEMENT',
                      p_invoice_id                  => ln_invoice_id,
                      p_invoice_line_id             => ln_invoice_line_id,
                      p_line_number                 => counter_tds_dm_v,
                      p_line_type_lookup_code       => 'ITEM',
                      p_amount                      => ROUND(i.balance_amount,ln_precision),
                      p_accounting_date             => v_open_gl_date,
                      p_description                 => lv_regime.description||' Liability Payment for Tax Type '||i.tax_type||' of Service Type '||i.service_type_code,  /*4245365*//* added by ssawant for bug 5879769 . Added service_type_code*/
                      p_dist_code_combination_id    => ln_dist_code_combination_id,
                      p_created_by                  => pn_created_by,
                      p_creation_date               => pd_creation_date,
                      p_last_updated_by             => pn_last_updated_by,
                      p_last_update_date            => pd_last_update_date,
                      p_last_update_login           => pn_last_update_login);

        END IF;

      END LOOP;

    ELSIF upper(lv_regime.regime_code) = 'VAT' THEN

      FOR i IN cur_distributions_VAT LOOP

	  	/* added for bug 8657720 */
	    IF i.tax_type='VAT REVERSAL' THEN
			i.tax_type:='VALUE ADDED TAX';
		END IF;
		/* end for bug 8657720 */


        ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
                  p_regime_id         =>  pn_regime_id,
                  p_organization_type =>  jai_constants.orgn_type_io,
                  p_organization_id   =>  i.party_id,
                  p_location_id       =>  i.location_id,
                  p_tax_type          =>  i.tax_type,
                        p_account_name      =>  jai_constants.liability);


        IF ln_dist_code_combination_id IS NULL THEN
      pv_process_flag := 'EE';
    pv_process_message := 'There is no account defined for AP Invoice creation. Can''t proceed';
    goto MAIN_EXIT;
  END IF;

        IF i.balance_amount <> 0 THEN

          counter_tds_dm_v := counter_tds_dm_v + 1;

          jai_ap_utils_pkg.insert_ap_inv_lines_interface(
                    p_jai_source                  => 'SETTLEMENT',
                    p_invoice_id                  => ln_invoice_id,
                    p_invoice_line_id             => ln_invoice_line_id,
                    p_line_number                 => counter_tds_dm_v,
                    p_line_type_lookup_code       => 'ITEM',
                    p_amount                      => ROUND(i.balance_amount,ln_precision),
                    p_accounting_date             => v_open_gl_date,
                    p_description                 => lv_regime.description||' Liability Payment for Organization:'||i.party_id||'Location:'||i.location_id||' Tax Type: '||i.tax_type,  /*4245365*/
                    p_dist_code_combination_id    => ln_dist_code_combination_id,
                    p_created_by                  => pn_created_by,
                    p_creation_date               => pd_creation_date,
                    p_last_updated_by             => pn_last_updated_by,
                    p_last_update_date            => pd_last_update_date,
                    p_last_update_login           => pn_last_update_login);

        END IF;
      END LOOP;

       /*Added By CSahoo, BUG#5631784*/
       ELSIF upper(lv_regime.regime_code) = jai_constants.tcs_regime THEN

					FOR i IN cur_distributions_TCS LOOP

						ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
											p_regime_id         =>  pn_regime_id,
											p_organization_type =>  jai_constants.orgn_type_io,
											p_organization_id   =>  i.party_id,
											p_location_id       =>  i.location_id,
											p_tax_type          =>  i.tax_type,
											p_account_name      =>  jai_constants.liability);


						IF ln_dist_code_combination_id IS NULL THEN
								pv_process_flag := 'EE';
								pv_process_message := pn_regime_id||'There is no account defined for AP Invoice creation. Can''t proceed';
								goto MAIN_EXIT;
						END IF;

						IF i.balance_amount <> 0 THEN

							counter_tds_dm_v := counter_tds_dm_v + 1;

							jai_ap_utils_pkg.insert_ap_inv_lines_interface(
												p_jai_source                  => 'SETTLEMENT',
												p_invoice_id                  => ln_invoice_id,
												p_invoice_line_id             => ln_invoice_line_id,
												p_line_number                 => counter_tds_dm_v,
												p_line_type_lookup_code       => 'ITEM',
												p_amount                      => ROUND(i.balance_amount,ln_precision),
												p_accounting_date             => v_open_gl_date,
												p_description                 => lv_regime.description||' Liability Payment for Organization:'||i.party_id||'Location:'||i.location_id||' Tax Type: '||i.tax_type,
												p_dist_code_combination_id    => ln_dist_code_combination_id,
												p_created_by                  => pn_created_by,
												p_creation_date               => pd_creation_date,
												p_last_updated_by             => pn_last_updated_by,
												p_last_update_date            => pd_last_update_date,
												p_last_update_login           => pn_last_update_login);

						END IF;
      END LOOP;
    END IF;
    /*The following condition would never be met and hence not tested. This may not be correct as well
      This is the case where the amount paid is more than the amount to be settled and the
      following code does the proportioning of the excess amount to the differnt tax types
    */
    IF pn_invoice_amount > pn_calculated_amount THEN

      IF upper(lv_regime.regime_code) = 'SERVICE' THEN    /*4245365*/

        FOR j in cur_tax_types('TAX_TYPES') LOOP--rchandan for bug#4428980
    IF cur_tax_types%ROWCOUNT = 1 THEN
      lv_tax_type1 := j.tax_type;
    END IF;

    IF cur_tax_types%ROWCOUNT = 2 THEN
      lv_tax_type2 := j.tax_type;
      ln_rate      := j.rate;
    END IF;
        END LOOP;

        IF ln_rate IS NOT NULL THEN
    ln_amount2 := ROUND((pn_invoice_amount - pn_calculated_amount)*(ln_rate/(100+ln_rate)),ln_precision);
        END IF;

        ln_amount1 := pn_invoice_amount - pn_calculated_amount - NVL(ln_amount2,0);

        IF ln_amount1 <> 0 THEN


    ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
                p_regime_id         =>  pn_regime_id,
                p_organization_type =>  jai_constants.orgn_type_ou,
                p_organization_id   =>  pn_org_id,
                p_location_id       =>  NULL,
                p_tax_type          =>  lv_tax_type1,
                p_account_name      =>  jai_constants.liability);

    IF ln_dist_code_combination_id IS NULL THEN
      pv_process_flag := 'EE';
      pv_process_message := 'There is no account defined for AP Invoice creation. Cannot proceed';
      goto MAIN_EXIT;
    END IF;

    counter_tds_dm_v := counter_tds_dm_v + 1;

    jai_ap_utils_pkg.insert_ap_inv_lines_interface(
          p_jai_source                  => 'SETTLEMENT',
          p_invoice_id                  => ln_invoice_id,
          p_invoice_line_id             => ln_invoice_line_id,
          p_line_number                 => counter_tds_dm_v,
          p_line_type_lookup_code       => 'ITEM',
          p_amount                      => ln_amount1,
          p_accounting_date             => v_open_gl_date,
          p_description                 => 'Service Tax Excess Payment for Tax Type '||lv_tax_type1,
          p_dist_code_combination_id    => ln_dist_code_combination_id,
          p_created_by                  => pn_created_by,
          p_creation_date               => pd_creation_date,
          p_last_updated_by             => pn_last_updated_by,
          p_last_update_date            => pd_last_update_date,
          p_last_update_login           => pn_last_update_login);

        END IF;

        IF ln_amount2 <> 0 THEN
    ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
                p_regime_id         =>  pn_regime_id,
                p_organization_type =>  jai_constants.orgn_type_ou,
                p_organization_id   =>  pn_org_id,
                p_location_id       =>  NULL,
                p_tax_type          =>  lv_tax_type2,
                p_account_name      =>  jai_constants.liability);

    IF ln_dist_code_combination_id IS NULL THEN
      pv_process_flag := 'EE';
      pv_process_message := 'There is no account defined for AP Invoice creation. Cannot proceed';
      goto MAIN_EXIT;
    END IF;

    counter_tds_dm_v := counter_tds_dm_v + 1;

    jai_ap_utils_pkg.insert_ap_inv_lines_interface(
          p_jai_source                  => 'SETTLEMENT',
          p_invoice_id                  => ln_invoice_id,
          p_invoice_line_id             => ln_invoice_line_id,
          p_line_number                 => counter_tds_dm_v,
          p_line_type_lookup_code       => 'ITEM',
          p_amount                      => ln_amount2,
          p_accounting_date             => v_open_gl_date,
          p_description                 => 'Service Tax Excess Payment for Tax Type '||lv_tax_type2,
          p_dist_code_combination_id    => ln_dist_code_combination_id,
          p_created_by                  => pn_created_by,
          p_creation_date               => pd_creation_date,
          p_last_updated_by             => pn_last_updated_by,
          p_last_update_date            => pd_last_update_date,
          p_last_update_login           => pn_last_update_login);

        END IF;

      ELSIF lv_regime.regime_code = 'VAT' THEN

  FOR j in cur_tax_types('TAX_TYPES') LOOP--rchandan for bug#4428980

      lv_tax_type := j.tax_type;
      ln_rate      := j.rate;

      IF ln_rate IS NOT NULL THEN
        ln_amount := ROUND((pn_invoice_amount - pn_calculated_amount)*(ln_rate/(100+ln_rate)),ln_precision);
      END IF;


      IF nvl(ln_amount,0) <> 0 THEN
           ln_dist_code_combination_id := jai_cmn_rgm_recording_pkg.get_account(
                                                            p_regime_id         =>  pn_regime_id,
                  p_organization_type =>  jai_constants.orgn_type_io,
                  p_organization_id   =>  org_io_rec.party_id,
                  p_location_id       =>  org_io_rec.location_id,
                  p_tax_type          =>  lv_tax_type,
                  p_account_name      =>  jai_constants.liability);

    IF ln_dist_code_combination_id IS NULL THEN
      pv_process_flag := 'EE';
      pv_process_message := 'There is no account defined for AP Invoice creation. Cannot proceed';
      goto MAIN_EXIT;
    END IF;

    counter_tds_dm_v := counter_tds_dm_v + 1;

    jai_ap_utils_pkg.insert_ap_inv_lines_interface(
          p_jai_source                  => 'SETTLEMENT',
          p_invoice_id                  => ln_invoice_id,
          p_invoice_line_id             => ln_invoice_line_id,
          p_line_number                 => counter_tds_dm_v,
          p_line_type_lookup_code       => 'ITEM',
          p_amount                      => ln_amount,
          p_accounting_date             => v_open_gl_date,
          p_description                 => 'Value Added Tax Excess Payment for Tax Type '||lv_tax_type,
          p_dist_code_combination_id    => ln_dist_code_combination_id,
          p_created_by                  => pn_created_by,
          p_creation_date               => pd_creation_date,
          p_last_updated_by             => pn_last_updated_by,
          p_last_update_date            => pd_last_update_date,
          p_last_update_login           => pn_last_update_login);

      END IF;

        END LOOP;



      END IF;   ---regime_code

    END IF;

    -- bug 4929081. Added by Lakshmi Gopalsami
    -- Removed the select and created cursor.

    OPEN cur_inv_exists(ln_invoice_id);
     FETCH cur_inv_exists INTO lv_inv_exists;
    CLOSE cur_inv_exists;

    IF lv_inv_exists = 'Y' THEN
      req_id := Fnd_Request.submit_request(
                'SQLAP',
                'APXIIMPT',
                'Localization Payables Open Interface Import',
                '',
                FALSE,
                /* Bug 4774647. Added by Lakshmi Gopalsami
		 * Passed operating unit also as this parameter has been
		 * added by base .
		 */
		 '',
		 /* Bug 5359044. Added by Lakshmi Gopalsami
		  * Changed the p_source from 'EXTERNAL'
		  * to 'INDIA TAX SETTLEMENT INVOICES'
		  */
                 /* Bug 5373747. Added by Lakshmi Gopalsami
                  * As per the discussion with AP Team changing the source
                  * as 'INDIA TAX SETTLEMENT'
                  */
                'INDIA TAX SETTLEMENT',
                '',
                'EXTERNAL'||TO_CHAR(TRUNC(SYSDATE)),
                '',
                '',
                '',
                'Y',
                'N',
                'N',
                'N',
                1000,
                pn_created_by,
                pd_creation_date);
    END IF;

    pv_system_invoice_no := lv_invoice_num;

    <<MAIN_EXIT>>
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      pv_process_flag := 'UE';
      pv_process_message := SUBSTR(SQLERRM,1,200);
  END create_invoice;

  FUNCTION get_last_settlement_date
        (pn_org_id IN  jai_rgm_stl_balances.party_id%TYPE,
        /* Bug 5096787. Added by Lakshmi Gopalsami */
  pn_regime_id IN jai_rgm_settlements.regime_id%TYPE DEFAULT NULL
        )
    RETURN DATE
  IS
    CURSOR c_last_settlement_date
    IS
    SELECT  MAX(jbal.settlement_date)
    FROM    JAI_RGM_STL_BALANCES jbal,jai_rgm_settlements jstl      --bug 8974544
     WHERE jbal.settlement_id = jstl.settlement_id   --bug 8974544
       AND jstl.regime_id     = pn_regime_id
and  party_id = pn_org_id;

    ld_last_settlement_date jai_rgm_stl_balances.settlement_date%TYPE;

  BEGIN
    OPEN c_last_settlement_date;
    FETCH c_last_settlement_date INTO ld_last_settlement_date;
    CLOSE c_last_settlement_date;

    RETURN ld_last_settlement_date;

  END get_last_settlement_date;

  FUNCTION get_last_settlement_date(pn_regime_id IN jai_rgm_settlements.regime_id%type,
                                    pn_org_id IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pn_location_id IN  jai_rgm_stl_balances.location_id%TYPE)
  RETURN DATE
  IS
    CURSOR c_last_settlement_date
    IS
    SELECT MAX(jbal.settlement_date)
      FROM JAI_RGM_STL_BALANCES jbal,jai_rgm_settlements jstl
     WHERE jbal.settlement_id = jstl.settlement_id
       AND jstl.regime_id = pn_regime_id
       AND party_id = pn_org_id
       AND location_id = pn_location_id;

    ld_last_settlement_date jai_rgm_stl_balances.settlement_date%TYPE;

  BEGIN
    OPEN c_last_settlement_date;
    FETCH c_last_settlement_date INTO ld_last_settlement_date;
    CLOSE c_last_settlement_date;

    RETURN ld_last_settlement_date;

  END get_last_settlement_date;


  PROCEDURE get_last_balance_amount(pn_org_id         IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pv_tax_type       IN  jai_rgm_stl_balances.tax_type%TYPE,
                                    pn_debit_amount OUT NOCOPY jai_rgm_stl_balances.debit_balance%TYPE,
                                    pn_credit_amount OUT NOCOPY jai_rgm_stl_balances.credit_balance%TYPE
				    )
  IS

  /*ssawant : comenting the below cursor and redefining it for bug 5662296*/
   /*
    CURSOR c_last_settlement_balance
    IS
    SELECT  debit_balance, credit_balance
    FROM    JAI_RGM_STL_BALANCES
    WHERE   party_id = pn_org_id
    AND     tax_type = pv_tax_type
    AND     settlement_date = (SELECT MAX(settlement_date)
                              FROM    JAI_RGM_STL_BALANCES
                              WHERE   party_id = pn_org_id
                              AND     tax_type = pv_tax_type);

*/

/*cursor added for bug 5662296*/
   CURSOR c_last_settlement_balance
                IS
                SELECT  debit_balance, credit_balance
                FROM    JAI_RGM_STL_BALANCES
                WHERE   party_id = pn_org_id
                AND     tax_type = pv_tax_type
                AND     settlement_id = (SELECT MAX(settlement_id)
		FROM JAI_RGM_STL_BALANCES
		WHERE party_id = pn_org_id
		AND tax_type = pv_tax_type);

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_settlement_pkg.get_last_balance_amount';

  BEGIN
    OPEN c_last_settlement_balance;
    FETCH c_last_settlement_balance INTO pn_debit_amount, pn_credit_amount;
    CLOSE c_last_settlement_balance;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      pn_debit_amount  := null;
      pn_credit_amount := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_last_balance_amount;

  PROCEDURE get_last_balance_amount(pn_regime_id IN jai_rgm_settlements.regime_id%type,
                                    pn_org_id         IN  jai_rgm_stl_balances.party_id%TYPE,
                                    pn_location_id    IN  jai_rgm_stl_balances.location_id%TYPE,
                                    pv_tax_type       IN  jai_rgm_stl_balances.tax_type%TYPE,
                                    pn_debit_amount   OUT NOCOPY jai_rgm_stl_balances.debit_balance%TYPE,
                                    pn_credit_amount  OUT NOCOPY jai_rgm_stl_balances.credit_balance%TYPE,
				    pv_service_type_code IN jai_rgm_stl_balances.service_type_code%TYPE DEFAULT NULL /* added by ssawant for bug 5879769 */
				    )
  IS
   CURSOR c_last_settlement_balance
    IS
      SELECT sum(debit_balance), sum(credit_balance) /* added sum by ssawant for bug 5879769 */
     FROM JAI_RGM_STL_BALANCES
    WHERE party_id = pn_org_id
      AND location_id = pn_location_id
      AND tax_type = pv_tax_type
      AND nvl(service_type_code,'-999') = nvl(pv_service_type_code, '-999' ) /* added by ssawant for bug 5879769 */
      AND settlement_id                 = (SELECT MAX(jbal.settlement_id)
                                           FROM JAI_RGM_STL_BALANCES jbal,
					   jai_rgm_settlements jstl
				            WHERE jbal.settlement_id = jstl.settlement_id
				              AND jstl.regime_id = pn_regime_id
				              AND party_id = pn_org_id
				              AND location_id = pn_location_id
					      AND nvl(service_type_code,'-999') = nvl(pv_service_type_code, '-999' ) /* added by ssawant for bug 5879769 */
				              AND tax_type = pv_tax_type);

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_settlement_pkg.get_last_balance_amount';

  BEGIN
    OPEN c_last_settlement_balance;
    FETCH c_last_settlement_balance INTO pn_debit_amount, pn_credit_amount;
    CLOSE c_last_settlement_balance;

     /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      pn_debit_amount  := null;
      pn_credit_amount := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_last_balance_amount;



  PROCEDURE register_entry( pn_regime_id          IN  NUMBER,
                            pn_settlement_id      IN  NUMBER,
                            pd_transaction_date   IN  DATE,
                            pv_process_flag OUT NOCOPY VARCHAR2,
                            pv_process_message OUT NOCOPY VARCHAR2)
  IS

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_settlement_pkg.register_entry';

    CURSOR cur_distributions IS
    SELECT  tax_type                  ,
            SUM(debit_balance) debit  ,
            SUM(credit_balance) credit,
            NVL(SUM(debit_balance),0) - NVL(SUM(credit_balance),0) balance_amount,
            party_id                  ,
            party_type                ,
            location_id               ,
            service_type_code   /* added by ssawant for bug 5879769 */
    FROM    jai_rgm_stl_balances
    WHERE   settlement_id = pn_settlement_id
    GROUP BY tax_type, party_type, party_id,location_id,service_type_code   /* added by ssawant for bug 5879769 */
    HAVING NVL(SUM(debit_balance),0) - NVL(SUM(credit_balance),0) > 0;

    CURSOR  cur_settlement IS
    SELECT  *
    FROM    jai_rgm_settlements
    WHERE settlement_id = pn_settlement_id;

    CURSOR cur_tax_types(p_reg_type  jai_rgm_registrations.registration_type%TYPE ) IS   --rchandan for bug#4428980
    SELECT  attribute_sequence, attribute_code tax_type, RATE
    FROM    JAI_RGM_REGISTRATIONS
    WHERE   regime_id = pn_regime_id
    AND     registration_type = p_reg_type   --rchandan for bug#4428980
    ORDER BY 1 ASC;

    CURSOR cur_vendor_org_id(c_vendor_id      po_vendor_sites_all.vendor_id%TYPE,
                             c_vendor_site_id po_vendor_sites_all.vendor_site_id%TYPE)
    IS
    SELECT  org_id
    FROM    po_vendor_sites_all
    WHERE   vendor_id = c_vendor_id
    AND     vendor_site_id = c_vendor_site_id;

    CURSOR cur_regime_code IS      /* 4245365*/
    SELECT regime_code,description
      FROM JAI_RGM_DEFINITIONS
     WHERE regime_id = pn_regime_id;

    CURSOR cur_org_io IS
    SELECT party_id,location_id
      FROM jai_rgm_stl_balances
     WHERE settlement_id = pn_settlement_id
     GROUP BY party_id,location_id
     HAVING sum(debit_balance) - sum(credit_balance) > 0;

    /*SELECT organization_id,location_id
      FROM JAI_RGM_ORG_REGNS_V
     WHERE regime_code = 'VAT'
       AND rownum = 1;     */

    rec_settlement cur_settlement%ROWTYPE;

    ln_repository_id  jai_rgm_trx_records.repository_id%TYPE;

    lv_tax_type1                jai_rgm_stl_balances.tax_type%TYPE;
    lv_tax_type2                jai_rgm_stl_balances.tax_type%TYPE;
    ln_amount1                  jai_rgm_stl_balances.debit_balance%TYPE;
    ln_amount2                  jai_rgm_stl_balances.debit_balance%TYPE;
    ln_rate                     JAI_RGM_REGISTRATIONS.rate%TYPE;
    ln_org_id                   jai_rgm_stl_balances.party_id%TYPE;
    ln_amount                   jai_rgm_stl_balances.debit_balance%TYPE;
    lv_tax_type                 jai_rgm_stl_balances.tax_type%TYPE;

    ln_discounted_amount        NUMBER;
    lv_regime                   cur_regime_code%rowtype    ;/* 4245365*/
    org_io_rec                  cur_org_io%ROWTYPE;
    ln_credit_amount            NUMBER;
    ln_debit_amount             NUMBER;
    ln_charge_accounting_id     jai_rgm_trx_records.charge_account_id%type;

  BEGIN

    pv_process_flag := 'SS';

     OPEN cur_settlement;
    FETCH cur_settlement INTO rec_settlement;
    CLOSE cur_settlement;

     OPEN cur_regime_code;                       /* 4245365*/
    FETCH cur_regime_code INTO lv_regime;
    CLOSE cur_regime_code;

    FOR i in cur_distributions LOOP

      IF lv_regime.regime_code = 'SERVICE' THEN

        jai_cmn_rgm_recording_pkg.insert_repository_entry(
          p_repository_id        => ln_repository_id,
          p_regime_id            => pn_regime_id,
          p_tax_type             => i.tax_type,
          p_organization_type    => jai_constants.orgn_type_io,   /* added by ssawant for bug 5879769 */
          p_organization_id      => i.party_id,
          p_location_id          => i.location_id ,   /* added by ssawant for bug 5879769 */
          p_source               => jai_constants.source_settle_in,
          p_source_trx_type      => 'Invoice Payment',
          p_source_table_name    => 'JAI_RGM_SETTLEMENTS',
          p_source_document_id   => pn_settlement_id,
          p_transaction_date     => pd_transaction_date,/* +1 is removed by ssawant for bug 5662296 */
          p_account_name         => NULL,
          p_charge_account_id    => NULL,
          p_balancing_account_id => NULL,
          p_amount               => i.balance_amount,
          p_discounted_amount    => ln_discounted_amount,
          p_assessable_value     => NULL,
          p_tax_rate             => NULL,
          p_reference_id         => NULL,
          p_batch_id             => NULL,
          p_called_from          => 'JAIRGMSP',
          p_accntg_required_flag => jai_constants.no,
          p_process_flag         => pv_process_flag,
          p_process_message      => pv_process_message,
          p_accounting_date      => pd_transaction_date,
          p_currency_code        => jai_constants.func_curr, --File.Sql.35 Cbabu
	  p_service_type_code    => i.service_type_code /* added by ssawant for bug 5879769 */
      );


          IF pv_process_flag <> 'SS' THEN
            goto MAIN_EXIT;
          END IF;

          UPDATE jai_rgm_trx_records
             SET settlement_id = pn_settlement_id
           WHERE repository_id = ln_repository_id;

      ELSIF lv_regime.regime_code = 'VAT' THEN

        ln_credit_amount := i.balance_amount;
        ln_debit_amount  := NULL;


        ln_charge_accounting_id :=
        jai_cmn_rgm_recording_pkg.get_account(p_regime_id         => pn_regime_id,
                                              p_organization_type => jai_constants.orgn_type_io,
                                              p_organization_id   => i.party_id,
                                              p_location_id       => i.location_id,
                                              p_tax_type          => i.tax_type,
                                              p_account_name      => jai_constants.recovery);

        jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                  pn_repository_id  => ln_repository_id,
                                      pn_regime_id  => pn_regime_id,
                                       pv_tax_type  => i.tax_type,
                              pv_organization_type  => jai_constants.orgn_type_io,
                                pn_organization_id  => i.party_id,
                                    pn_location_id  => i.location_id,
                                         pv_source  => jai_constants.source_settle_in,
                                pv_source_trx_type  => 'Invoice Payment',
                              pv_source_table_name  => 'JAI_RGM_SETTLEMENTS',
                                      pn_source_id  => pn_settlement_id,
                               pd_transaction_date  => pd_transaction_date,/* +1 is removed by ssawant for bug 5662296 */
                                   pv_account_name  => jai_constants.recovery,
                              pn_charge_account_id  => ln_charge_accounting_id,
                           pn_balancing_account_id  => NULL,
                                  pn_credit_amount  => ln_credit_amount,
                                   pn_debit_amount  => ln_debit_amount,
                               pn_assessable_value  => NULL,
                                       pn_tax_rate  => NULL,
                                   pn_reference_id  => NULL,
                                       pn_batch_id  => NULL,
                            pn_inv_organization_id  => i.party_id,
                                     pv_invoice_no  => NULL,
                                    pv_called_from  => 'JAIRGMSP',
                                   pv_process_flag  => pv_process_flag,
                                pv_process_message  => pv_process_message,
                                pd_invoice_date     => NULL
      );

      END IF;

      IF pv_process_flag <> 'SS' THEN
        goto MAIN_EXIT;
      END IF;

      UPDATE jai_rgm_trx_records
         SET settlement_id = pn_settlement_id
       WHERE repository_id = ln_repository_id;
    END LOOP;

    /*The following condition would never be met and hence not tested. This may not be correct as well*/
    IF rec_settlement.payment_amount > rec_settlement.calculated_amount*-1 THEN

      IF lv_regime.regime_code = 'SERVICE' THEN

        FOR j in cur_tax_types('TAX_TYPES') LOOP   --rchandan for bug#4428980

      IF cur_tax_types%ROWCOUNT = 1 THEN
      lv_tax_type1 := j.tax_type;
    END IF;

    IF cur_tax_types%ROWCOUNT = 2 THEN
      lv_tax_type2 := j.tax_type;
      ln_rate      := j.rate;
    END IF;
  END LOOP;

  IF ln_rate IS NOT NULL THEN
    ln_amount2 := ROUND((rec_settlement.payment_amount - rec_settlement.calculated_amount)*(ln_rate/(100+ln_rate)),2);
  END IF;

  ln_amount1 := rec_settlement.payment_amount - rec_settlement.calculated_amount - NVL(ln_amount2,0);

   OPEN cur_vendor_org_id(rec_settlement.tax_authority_id, rec_settlement.tax_authority_site_id);
  FETCH cur_vendor_org_id INTO ln_org_id;
  CLOSE cur_vendor_org_id;

  IF NVL(ln_amount1,0) <> 0 THEN
    jai_cmn_rgm_recording_pkg.insert_repository_entry(
            p_repository_id         => ln_repository_id,
            p_regime_id             => pn_regime_id,
            p_tax_type              => lv_tax_type1,
            p_organization_type     => jai_constants.orgn_type_ou,
            p_organization_id       => ln_org_id,
            p_location_id           => NULL,
            p_source                => jai_constants.source_settle_in,
            p_source_trx_type       => 'Invoice Payment',
            p_source_table_name     => 'JAI_RGM_SETTLEMENTS',
            p_source_document_id    => pn_settlement_id,
            p_transaction_date      => pd_transaction_date,/* +1 is removed by ssawant for bug 5662296 */
            p_account_name          => NULL,
            p_charge_account_id     => NULL,
            p_balancing_account_id  => NULL,
            p_amount                => ln_amount1,
            p_discounted_amount     => ln_discounted_amount,
            p_assessable_value      => NULL,
            p_tax_rate              => NULL,
            p_reference_id          => NULL,
            p_batch_id              => NULL,
            p_called_from           => 'JAIRGMSP',
            p_accntg_required_flag  => jai_constants.no,
            p_process_flag          => pv_process_flag,
            p_process_message       => pv_process_message,
            p_accounting_date       => pd_transaction_date
          , p_currency_code           => jai_constants.func_curr --File.Sql.35 Cbabu
            );
    IF pv_process_flag <> 'SS' THEN
      goto MAIN_EXIT;
      END IF;

      ELSIF NVL(ln_amount2,0) <> 0 THEN

    jai_cmn_rgm_recording_pkg.insert_repository_entry(
            p_repository_id         => ln_repository_id,
            p_regime_id             => pn_regime_id,
            p_tax_type              => lv_tax_type2,
            p_organization_type     => jai_constants.orgn_type_ou,
            p_organization_id       => ln_org_id,
            p_location_id           => NULL,
            p_source                => jai_constants.source_settle_in,
            p_source_trx_type       => 'Invoice Payment',
            p_source_table_name     => 'JAI_RGM_SETTLEMENTS',
            p_source_document_id    => pn_settlement_id,
            p_transaction_date      => pd_transaction_date, /* +1 is removed by ssawant for bug 5662296 */
            p_account_name          => NULL,
            p_charge_account_id     => NULL,
            p_balancing_account_id  => NULL,
            p_amount                => ln_amount2,
            p_discounted_amount     => ln_discounted_amount,
            p_assessable_value      => NULL,
            p_tax_rate              => NULL,
            p_reference_id          => NULL,
            p_batch_id              => NULL,
            p_called_from           => 'JAIRGMSP',
            p_accntg_required_flag  => jai_constants.no,
            p_process_flag          => pv_process_flag,
            p_process_message       => pv_process_message,
            p_accounting_date       => pd_transaction_date
          , p_currency_code           => jai_constants.func_curr --File.Sql.35 Cbabu
            );
    IF pv_process_flag <> 'SS' THEN
      goto MAIN_EXIT;
    END IF;

  END IF;

      ELSIF lv_regime.regime_code = 'VAT' THEN

         FOR j in cur_tax_types('TAX_TYPES') LOOP   --rchandan for bug#4428980

     lv_tax_type := j.tax_type;
         ln_rate := j.rate;


     IF ln_rate IS NOT NULL THEN
       ln_amount := ROUND((rec_settlement.payment_amount - rec_settlement.calculated_amount)*(ln_rate/(100+ln_rate)),2);
     END IF;

      OPEN cur_org_io;
     FETCH cur_org_io INTO org_io_rec;
           CLOSE cur_org_io;

     IF nvl(ln_amount,0) <> 0 THEN

       ln_credit_amount := ln_amount;
       ln_debit_amount := NULL;
       jai_cmn_rgm_recording_pkg.insert_vat_repository_entry(
                                      pn_repository_id  => ln_repository_id,
                                          pn_regime_id  => pn_regime_id,
                                           pv_tax_type  => lv_tax_type,
                                  pv_organization_type  => jai_constants.orgn_type_io,
                                    pn_organization_id  => org_io_rec.party_id,
                                        pn_location_id  => org_io_rec.location_id,
                                             pv_source  => jai_constants.source_settle_in,
                                    pv_source_trx_type  => 'Invoice Payment',
                                  pv_source_table_name  => 'JAI_RGM_SETTLEMENTS',
                                          pn_source_id  => pn_settlement_id,
                                   pd_transaction_date  => pd_transaction_date, /* +1 is removed by ssawant for bug 5662296 */
                                       pv_account_name  => NULL,
                          pn_charge_account_id  => NULL,
                   pn_balancing_account_id  => NULL,
                          pn_credit_amount  => ln_credit_amount,
                           pn_debit_amount  => ln_debit_amount,
                       pn_assessable_value  => NULL,
                               pn_tax_rate  => NULL,
                           pn_reference_id  => NULL,
                               pn_batch_id  => NULL,
                    pn_inv_organization_id  => org_io_rec.party_id,
                             pv_invoice_no  => NULL,
                            pv_called_from  => 'JAIRGMSP',
                           pv_process_flag  => pv_process_flag,
                        pv_process_message  => pv_process_message,
                        pd_invoice_date     => NULL
      );

       IF pv_process_flag <> 'SS' THEN
         goto MAIN_EXIT;
       END IF;


    END IF;

        END LOOP;

      END IF;

   END IF;
 <<MAIN_EXIT>>
    null;

  EXCEPTION
    WHEN OTHERS THEN
      pv_process_flag := 'UE';
      pv_process_message := SUBSTR(SQLERRM,1,200);
  END register_entry;

/*
 	 ||The following function addded by rchandan for bug#6835541
 	 ||This function is used for VAT settlement where the user has the flexibility of
 	 || of doing settlement at either registartion or organization or organization-location level
 	 */
 	 FUNCTION get_last_settlement_date(pn_regime_id   IN NUMBER,
 	                                     pn_regn_no     IN VARCHAR2,
 	                                     pn_organization_id      IN NUMBER,
 	                                     pn_location_id IN NUMBER)
 	 RETURN DATE
 	 IS
 	 CURSOR c_last_settlement_date
 	 IS
 	 SELECT MAX(jbal.settlement_date)
 	   FROM JAI_RGM_STL_BALANCES jbal,jai_rgm_settlements jstl
 	  WHERE jbal.settlement_id = jstl.settlement_id
 	    AND jstl.regime_id     = pn_regime_id
 	    AND jstl.primary_registration_no = pn_regn_no
 	    AND jbal.party_id      = nvl(pn_organization_id,jbal.party_id)
 	    AND jbal.location_id   = nvl(pn_location_id,jbal.location_id);
--Added by Eric Ma for bug 8333082,8671217 on Dec-19-2009,begin
-------------------------------------------------------------------
CURSOR c_last_reg_level_Settlement IS
  select settlement_id from
 (
  select jstl.party_id,jstl.location_id,jstl.settlement_id from
 jai_rgm_stl_balances jstl,
 jai_rgm_Settlements jrs,
 JAI_RGM_DEFINITIONS jr
        WHERE jstl.settlement_id = jrs.settlement_id
      AND jrs.regime_id      = jr.regime_id
          AND  jr.regime_code         = 'VAT'
  group by  jstl.party_id,jstl.location_id,jstl.settlement_id
  )group by settlement_id
  having count(*) >1
  order by settlement_id desc;

CURSOR c_settlement_date(cp_settlement_id jai_rgm_stl_balances.settlement_id%TYPE) is
SELECT settlement_date FROM
jai_rgm_stl_balances where settlement_id = cp_settlement_id
and rownum=1;

l_last_reg_settlement jai_rgm_stl_balances.settlement_id%TYPE;
-----------------------------------------------------
--Added by Eric Ma for bug 8333082,8671217 on Dec-19-2009,end

 	 ld_settlement_date date;

 	 BEGIN

--Added by Eric Ma for bug 8333082,8671217 on Dec-19-2009,begin
-----------------------------------------------------
  IF ( pn_organization_id IS NULL AND pn_location_id IS NULL ) THEN

   OPEN c_last_reg_level_Settlement;
   FETCH c_last_reg_level_Settlement INTO l_last_reg_settlement;
   CLOSE c_last_reg_level_Settlement;

    IF l_last_reg_settlement IS NOT NULL THEN

      OPEN c_settlement_date(l_last_reg_settlement);
      FETCH c_settlement_date INTO ld_settlement_date;
      CLOSE c_settlement_date;

      return ld_settlement_date;

    END IF;

  END IF;
-----------------------------------------------------
--Added by Eric Ma for bug 8333082,8671217 on Dec-19-2009,end
 	   OPEN c_last_settlement_date;
 	   FETCH c_last_settlement_date INTO ld_settlement_date;
 	   CLOSE c_last_settlement_date;

 	   return ld_settlement_date;

 	 end get_last_settlement_date;


END jai_cmn_rgm_settlement_pkg;

/

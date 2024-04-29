--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_RECORDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_RECORDING_PKG" AS
/* $Header: jai_cmn_rgm_rec.plb 120.14.12010000.10 2010/04/15 10:45:49 boboli ship $ */

  /*----------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME: jai_rgm_trx_recording_pkg_b.sql
  S.No  dd/mm/yyyy   Author and Details
  ------------------------------------------------------------------------------------------------------------------------------
  1     15/12/2004   Vijay Shankar for Bug# 4068823, Version:115.0

              Coded for recording Service Tax into repository and related Accounting into GL

              - INSERT_REPOSITORY_ENTRY : Based on the input source, this procedure derives the type of entry that has to be made into
              the repository. Also accounting entries related to repository entry are passed only if p_accntg_required_flag parameter
              is 'Y'. This also passes discount accounting if the input parameter p_discounted_amount has a value

              - GET_ACCOUNT      : Returns the CODE_COMBINATION_ID related to the inputs passed. This returns values from regime setup
              incase of service tax and from Organization Addl. info incase of inventory organization and from Base Setup incase of
              AP discounts

              - GET_PERIOD_NAME  : Returns the period_name for which the entry is being made. This also returns the accounting_date as
              first_date of next open period, if the period corresponding to input accounting date is closed

              - POST_ACCOUNTING  : Inserts an Entry into GL_INTERFACE and Localization Subledger for the inputs passed to the call

              - INSERT_REFERENCE : Called from AP and AR Processing to insert data related to related Invoices

              - UPDATE_REFERENCE : Called from AP and AR Processing to update revocovered and discounted amounts for the invoice


  2.            Bug# 4193633  - Aiyer  - 15-feb-2005

                 Issue
                    The tax earned and unearned discount are not getting apportioned properly of service type of taxes and hence the India - Service Tax concurrent
                    ends up in a warning for records with these issues

                   Reason:-
                    In case of invoices having Service taxes and other type of taxes, the tax earned and unearned discounts should be approtioned across all the type of taxes
                    (Both Service and Non Service).
                    This apportionment logic was not present initially. This needs to be added

                   Fix: -
                    Modified the procedure. Did the following :-
                    1. Added a extra parameter p_total_disc_amount to the procedure.
                    2. used this parameter to apportion the tax earned discount amount and tax unearned discount amount

                  Dependency :-
                   In this procedure the added parameter is added to the procedure and hence causes a dependency issue.

                   The following objects should be sent together

                    1. jai_rgm_process_ar_taxes_pkg_s.sql          (115.1)
                    2. jai_rgm_process_ar_taxes_pkg_b.sql          (115.1)
                    3. jai_rgm_trx_recording_pkg_s.sql version     (115.1)
                    4. jai_rgm_trx_recording_pkg_b.sql version     (115.1)


  3.            Bug# 4204880 - ssumaith - 20-feb-2005 - File version 115.2

                A new column has been added into the table jai_Rgm_trx_Records called regime_primary_regno and it has been
                included in the insert column list in the table  jai_Rgm_trx_Records
                A cursor has been added to fetch the primary registration number.

                Dependency :-
                  High . A new column has been added into the jai_rgm_trx_records table which also needs data to be populated
                  If this file is sent alone , it will cause a dependency issue.
                  Need to ensure that the new column needs to be part of the table.


4    19/03/2005 Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.3
                .added two new procedure insert_vat_repository_entry and do_vat_accounting, a function get_rgm_attribute_value
                as part of VAT Impl.
                .user_je_category_name that is populated into GL_INTERFACE as jai_constants.je_category_rg_entry ('Register India')

                * This is a Dependant Bug for future Versions of the Object *

5. 08-Jun-2005  File Version 116.2 Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                as required for CASE COMPLAINCE.

6. 14-Jun-2005  rchandan for bug#4428980, Version 116.3
                Modified the object to remove literals from DML statements and CURSORS.

7. 06-Jul-2005  Ramananda for bug#4477004. File Version: 116.4
                GL Sources and GL Categories got changed. Refer bug for the details



  DEPENDANCY:
  -----------
  IN60106  + 4239736 + 4245089


   COMMON API that will be called from DIFFERENT Transactions of the Regime
  This will call APIS to insert data into regime repository and GL Tables
  Transactions that are calling this procedure are

   1) AP Invoice Payments
   2) AR Receipt applications onto Invoice
   3) Service Tax Manual Entry form
   4) Settlement Process
   5) Distribution Process

8. 11-Aug-2005   Ramananda for Bug#4546114. File Version 120.2
                 In case of distribution from IO to OU , the accounting for cess transferred is hitting
                 the cenvat RM or Cenvat CG account instead of the cess account.

                 After this fix, the accounts that will be hit are the cenvat rm a/c / cenvat cg a/c
                 for the excise amt and the edu cess rm a/c / edu cess cg a/c for the cess amt.

                 Dependency due to this fix:
                 None

9. 30-JAN-2007    CSahoo for bug#5631784. File Version 120.4
                  Forward Porting of Bug#4742259 (TCS solution)
                  Function get_account is modified to give the accounts for TCS regime also.


10. 16/04/2007 kunkumar for forward porting to R12 bugnos 5003538 5051541 and 4543358


11. 14-05-2007   ssawant for bug 5879769,
                 Objects was not compiling. so changes are done to make it compiling.
12.  18-may-2009 vkaranam for bug#7010029    120.14.12010000.7/120.20
                Issue: VAT ACCOUNTING ENTRIES FOR AR INVOICE GENERATED IN FUTRE PERIOD
                Fix: Modified the cursor c_period_dtl in the procedure get_period_name.
                     Added the following AND condition
                     AND closing_status in ('O','F')
                     Added a order by clause also.
13. 05-Feb-2009 CSahoo for bug#9350172
                ISSUE: FPBUG:CAN NOT ADD TAXES SUCCESSFULLY IN ENTER TXN INDIA LOCALIZATION FORM
                FIX: Added an input parameter pn_settlement_id to the procedure insert_vat_repository_entry
                     This parameter pn_settlement_id is used to populate the settlement_id in the table
                     jai_rgm_trx_records.

14.   4-Apr-2010  Bo Li for Bug9305067
                  Modify the procedure insert_repository_entry and insert_vat_repository_entry.
                  Replace the attribute parameters with new meaningful parameters


Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )
jai_rgm_trx_recording_pkg_b.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files                                  Version     Author     Date         Remarks
Of File                              On Bug/Patchset    Dependent On


115.1                 4204880        IN60106 + 4146708   ja_in_alter_table_4204880.sql           115.0       ssumaith    20-feb-05   New column added to the table.

                                                        jai_rgm_process_ar_taxes_pkg_s.sql       115.1       aiyer       21-feb-05   signature change in parameters.
                                                        jai_rgm_process_ar_taxes_pkg_b.sql       115.1       aiyer       21-feb-05   signature change in parameters.

115.3                 4245089        IN60106 + 4146708   ja_in_alter_table_4204880.sql           115.0       ssumaith    20-feb-05   New column added to the table.
                                      + 4204880




10. 01-MAR-2007   SSAWANT , File version 120.5
                  Forward porting the change in 11.5 bug 5642053 to R12 bug no 5662296.

                  Issue : PROCESSING SETTLEMENT (INDIA LOCAL) ON THE CURRENT DATE AND AT ORG LEVEL
                    Fix : Previously whenever transaction_date was less than or equal to last_settlement_date
                          it was modified to last_settlement_date + 1. Now this would be done only if
                          transaction_date is less than last_settlement_date as transactions can be
                          done on last_settlement_date.
11. 03-MAR-07   bduvarag, File version 120.5
                Forward porting the change in 11.5 bug 5051541 to R12 bug


12  25-April-2007   ssawant for bug 5879769 ,File version 120.6
                Forward porting of
                ENH : SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION from 11.5( bug no 5694855) to R12 (bug no 5879769).
                      Fix : A new parameter p_service_type_code is added to insert_repository procedure.
                              This is used to insert into jai_rgm_trx_records.
                              A new column repository_id is added to jai_sla_entries and so the insert statement
                              is modified to insert the repository id
                              The procedure get_account is modified to return the account if the regime is SERVICE, Org Type is IO and the
                              tax is not of EXCISE or EXCISE CESS types
13  02/05/2006     vkaranam  bug#5989740 - File version 120.8

                   Forward porting of 115 bug #5907436
                   ENH : HANDLING SECONDARY AND HIGHER EDUCATION CESS

                         additional cess of 1% on all taxes to be levied to fund secondary education and higher
                         education .

                   Code Changes - Cursor c_orgn_sh_cess_account is added to get code_combination_id for secondary and higher cess types .

14.  07/06/2007  sacsethi for bug 6109941
                  R12RUP03-ST1: CODE REVIEW COMMENTS FOR ENHANCEMENTS

                  Problem - when we trying to get code combination id for discount in AP , then we were passing
                            organization id but we defined code conbination id at OU Level in AP ,
                            wheich was resulting in error

                  Solution - 1. Now passing ln_org_id instead of organziation_id  for discounts .
                             2. procedure post_accounting  is changed to return if both credit and debit amount is zero
                                instead of generating oracle error.

15.     27/06/2007      CSahoo for bug#6155839, File Version 120.11
                        added the lv_source_name variable to get the service tax source or vat source depending on the value of the regime.

16.     07/12/2007      ssumaith - bug# 6664855 - file version -  120.3.12000000.5.
                        Issue :-
        When service tax distribution is done between two inventory organizations,
        it was causing the unbalances gl entries.
        Reason being - organziation id was inserted in the reference1 column of gl_interface table.
        The organization id was entered as source orgn id for source org entries and destination orgn id
        for des orgn entries as a result, there was only debits or credits for one orgn because referenc1 column
        is also in the used in the grouping logic.

                        Fix:

        This was a forward port issue of the R11i bug# 5410587.
        It has been forward ported.
        Changes done are to pass the combination of source org and destination org into reference1 column.

17. 06-Dec-2009   Bug 7692977 File version 120.14.12010000.3 / 120.16
                  Issue - Duplicate accounting entries are created for service tax distribution.
                  Cause - During distribution, the Dr entry due to SERVICE_DISTRIBUTE_IN will be
                          balanced by the Cr entry due to SERVICE_DISTRIBUTE_OUT. But balancing
                          entries are separately passed for each of these, therefore creating
                          duplicate accounting.
                  Fix   - Stopped balancing entry to be passed when the source is SERVICE_DISTRIBUTE_IN or
                          SERVICE_DISTRIBUTE_OUT. Also reverted  the changes done for bug 7525691 earlier
                          because it is causing dependency. The same fix can be done without causing the
                          dependency. Refer bug for more details.

18. 18-Mar-2009  Bug 7525691 File version 120.14.12010000.4/120.17
                 Issue - 1. Both credit and debit entries passed during service tax settlement hit
                            the same account (recovery).
                         2. Duplicate accounting entries are generated during settlement.
                 Fix - This is forward port for bug 7518230. Details:
                       1. Debit entry (source is settle_in) should hit the liability account.
                          Credit entry (source is settle_out) should hit the recovery account.
                       2. Balancing entries should not be passed when source is settle_in or settle_out
                       Along this, bug 8329634 is also fixed. After this fix, balancing entry will not
                       be passed when
                        - source is SETTLE_IN or SETTLE_OUT
                        - source is SERVICE_DISTRIBUTE_IN or SERVICE_DISTRIBUTE_OUT, with
                          distribution type as Service to Service.

19. 17-May-2009 Bug 7522584
                Issue : Service Tax entered in foreign currency for AR Invoice is not converted to Functional Currency
                Fix: Modified the code in the proc insert_repository_entry. Added a multipier to the discount amount
                so as to calulate the discount amount in functional currency.

20. 22-May-2009 Bug 8294236
                  Issue: Service Tax Transaction created Fr Exchange Balances on Tax Accounts after Settlement
                  Fix: Created a new procedure exc_gain_loss_accounting for creating the accounting
                  entries for foreign exchange gain or loss amount.

----------------------------------------------------------------------------------------------------------------------------*/


  /* ~~~~~~~~~~~~~~~ Start of Repository Entry ~~~~~~~~~~~~~~~~~ */
    PROCEDURE insert_repository_entry(
    p_repository_id OUT NOCOPY NUMBER,
    p_regime_id               IN      NUMBER,
    p_tax_type                IN      VARCHAR2,
    p_organization_type       IN      VARCHAR2,
    p_organization_id         IN      NUMBER,
    p_location_id             IN      NUMBER,
    p_source                  IN      VARCHAR2,
    p_source_trx_type         IN      VARCHAR2,
    p_source_table_name       IN      VARCHAR2,
    p_source_document_id      IN      NUMBER,
    p_transaction_date        IN      DATE,
    p_account_name            IN      VARCHAR2,
    p_charge_account_id       IN      NUMBER,
    p_balancing_account_id    IN      NUMBER,
    p_amount                  IN OUT NOCOPY NUMBER,           -- Recovered/Liable Service Tax Amount in INR Currency i.e functional
    p_assessable_value        IN      NUMBER,
    p_tax_rate                IN      NUMBER,
    p_reference_id            IN      NUMBER,
    p_batch_id                IN      NUMBER,
    p_called_from             IN      VARCHAR2,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2,
    p_discounted_amount       IN OUT NOCOPY NUMBER,
    p_inv_organization_id     IN      NUMBER    DEFAULT NULL,
    p_settlement_id           IN      NUMBER    DEFAULT NULL,
    -- Following all parameters are required for GL Accounting if p_balancing_account_id value is not passed to this procedure call
    p_accntg_required_flag    IN      VARCHAR2,  -- DEFAULT jai_constants.yes  File.Sql.35 by Brathod
    p_accounting_date         IN      DATE ,     -- DEFAULT sysdate           File.Sql.35 by Brathod
    p_balancing_orgn_type     IN      VARCHAR2  DEFAULT NULL,
    p_balancing_orgn_id       IN      NUMBER    DEFAULT NULL,
    p_balancing_location_id   IN      NUMBER    DEFAULT NULL,
    p_balancing_tax_type      IN      VARCHAR2  DEFAULT NULL,
    p_balancing_accnt_name    IN      VARCHAR2  DEFAULT NULL,
    p_currency_code           IN      VARCHAR2  ,  -- DEFAULT jai_constants.func_curr File.Sql.35 by Brathod
    p_curr_conv_date          IN      VARCHAR2  DEFAULT NULL,
    p_curr_conv_type          IN      VARCHAR2  DEFAULT NULL,
    p_curr_conv_rate          IN      VARCHAR2  DEFAULT NULL,
    p_trx_amount              IN      NUMBER    DEFAULT NULL,      -- recovered/liable service tax amount in foreign currency
    --Added by Bo Li for Bug9305067 BEGIN
    ------------------------------------------------------------
    p_trx_reference_context   IN      VARCHAR2  DEFAULT NULL,
    p_trx_reference1          IN      VARCHAR2  DEFAULT NULL,
    p_trx_reference2          IN      VARCHAR2  DEFAULT NULL,
    p_trx_reference3          IN      VARCHAR2  DEFAULT NULL,
    p_trx_reference4          IN      VARCHAR2  DEFAULT NULL,
    p_trx_reference5          IN      VARCHAR2  DEFAULT NULL,
    ------------------------------------------------------------
    --Added by Bo Li for Bug9305067 End

    p_service_type_code       IN      VARCHAR2  DEFAULT NULL, /* added by ssawant for bug 5989740 */
    p_distribution_type       IN      VARCHAR2  DEFAULT NULL
 ) IS

    lv_regime_code              JAI_RGM_DEFINITIONS.regime_code%TYPE;
    ln_credit                   NUMBER;
    ln_debit                    NUMBER;
    ln_trx_credit               NUMBER;
    ln_trx_debit                NUMBER;

    lv_register_entry_type      VARCHAR2(2);
    lv_account_name             JAI_RGM_TRX_RECORDS.account_name%TYPE;
    ln_charge_account_id        JAI_RGM_TRX_RECORDS.charge_account_id%TYPE;
    lv_charge_entry_type        VARCHAR2(2);
    lv_period_name              GL_PERIODS.period_name%TYPE;

    lv_balancing_tax_type       JAI_RGM_TRX_RECORDS.tax_type%TYPE;
    lv_balancing_orgn_type      JAI_RGM_TRX_RECORDS.organization_type%TYPE;
    ln_balancing_orgn_id        JAI_RGM_TRX_RECORDS.organization_id%TYPE;
    ln_balancing_location_id    JAI_RGM_TRX_RECORDS.location_id%TYPE;
    lv_balancing_accnt_name     JAI_RGM_TRX_RECORDS.account_name%TYPE;
    ln_balancing_account_id     JAI_RGM_TRX_RECORDS.charge_account_id%TYPE;
    lv_balancing_entry_type     VARCHAR2(2);
    lv_bal_entry_period_name    GL_PERIODS.period_name%TYPE;

    ln_trx_tax_amount           NUMBER;
    lv_reference_name           VARCHAR2(30);
    ln_reference_id             NUMBER;
    lv_statement                VARCHAR2(4);

    ln_discount_ccid            NUMBER(15);
    ln_disc_credit              NUMBER;
    ln_disc_debit               NUMBER;

    lv_codepath                 VARCHAR2(500); --  := '' File.Sql.35 by Brathod
    ln_trx_amount               NUMBER;
    ld_transaction_date         DATE;
    ld_last_settlement_date     DATE;

    ln_earned_discount          NUMBER;
    ln_earned_disc_accnt        NUMBER;
    ln_unearned_discount        NUMBER;
    ln_unearned_disc_accnt      NUMBER;

    /*
    Following cursor added by ssumaith for fetching the  primary registration number of the regime
    It will be inserted into jai_Rgm_trx_records table.
    Bug# 4204880
    */

    CURSOR c_primary_regno( p_att_type_code jai_rgm_registrations.attribute_Type_code%TYPE ) IS  --rchandan for bug#4428980
    SELECT attribute_value
    FROM   JAI_RGM_ORG_REGNS_V
    WHERE  regime_id           = p_regime_id
    AND    organization_id     = p_organization_id
    AND    organization_type   = p_organization_type
    AND    registration_type   = jai_constants.regn_type_others
    AND    attribute_Type_code = p_att_type_code;  --rchandan for bug#4428980

    lv_primary_regime_regno  JAI_RGM_REGISTRATIONS.ATTRIBUTE_VALUE%TYPE;


    /*Cursor added by ssawant for bug 5989740 */
    CURSOR cur_fetch_ou(cp_organization_id NUMBER)
    IS
    SELECT org_information3
    FROM   hr_organization_information
    WHERE  upper(ORG_INFORMATION_CONTEXT) = 'ACCOUNTING INFORMATION'
    AND    organization_id                = cp_organization_id;

    ln_org_id   NUMBER;  /* added by ssawant for bug 5989740 */

  BEGIN

    lv_statement := '0';
    lv_codepath := jai_general_pkg.plot_codepath(1, lv_codepath, 'Insert_Repository_Entry', 'START');

    OPEN c_regime_code(p_regime_id);
    FETCH c_regime_code INTO lv_regime_code;
    CLOSE c_regime_code;

        /* added by ssawant for bug 5989740 */
    OPEN  cur_fetch_ou(p_organization_id);
    FETCH cur_fetch_ou INTO ln_org_id;
    CLOSE cur_fetch_ou;

    lv_statement := '1';
    -- REGIME Validation
    IF lv_regime_code <> jai_constants.service_regime THEN
      lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);
      p_process_flag    := jai_constants.expected_error;
      p_process_message := 'Transactions other than SERVICE regime are not supported';
      FND_FILE.put_line( FND_FILE.log, p_process_message);
      fnd_file.put_line(fnd_file.log,p_process_message);
      RETURN;
    END IF;

    -- Rounding of Service Tax that is hitting repository
    p_amount := round(p_amount, jai_constants.service_rgm_rnd_factor);
    p_discounted_amount := round(p_discounted_amount, jai_constants.service_rgm_rnd_factor);
    IF p_trx_amount = 0 OR p_trx_amount IS NULL THEN
      ln_trx_amount := NULL;
    ELSE
      ln_trx_amount := round(p_trx_amount, jai_constants.service_rgm_rnd_factor);
    END IF;

    lv_statement            := '2';
    IF p_source IN (jai_constants.source_settle_in, jai_constants.source_settle_out) THEN
      ld_transaction_date := p_transaction_date;
      lv_codepath := jai_general_pkg.plot_codepath(2.1, lv_codepath);

    ELSE
      ld_last_settlement_date := jai_cmn_rgm_settlement_pkg.get_last_settlement_date(pn_regime_id => p_regime_id,pn_org_id => p_organization_id,pn_location_id => p_location_id);/* added location id by ssawant for bug 5989740 */
      IF ld_last_settlement_date > p_transaction_date THEN /*for bug 5662296 ,org_settlement. Replaced >= with >*/
        ld_transaction_date := ld_last_settlement_date + 1;
        lv_codepath := jai_general_pkg.plot_codepath(2.2, lv_codepath);
       ELSIF ld_last_settlement_date IS NULL or ld_last_settlement_date <= p_transaction_date THEN /* for bug 5662296 , org_settlement. Replaced < with <=*/
        ld_transaction_date := p_transaction_date;
        lv_codepath := jai_general_pkg.plot_codepath(2.3, lv_codepath);
      END IF;
    END IF;

    lv_statement := '2.1';
    -- ~~~~~~~~~~~~~~~~~~~~~~~ Start of Repository Entry ~~~~~~~~~~~~~~~~~~~

    IF p_source = jai_constants.source_ap THEN
      lv_statement := '3';
      lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);
      lv_register_entry_type  := jai_constants.credit;
      lv_account_name         := jai_constants.recovery;
      lv_charge_entry_type    := jai_constants.debit;
      lv_balancing_accnt_name := jai_constants.recovery_interim;
      lv_balancing_entry_type := jai_constants.credit;

    ELSIF p_source = jai_constants.source_ar THEN
      lv_statement := '4';
      lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);
      lv_register_entry_type  := jai_constants.debit;
      lv_account_name         := jai_constants.liability;
      lv_charge_entry_type    := jai_constants.credit;
      lv_balancing_accnt_name := jai_constants.liability_interim;
      lv_balancing_entry_type := jai_constants.debit;

    ELSIF p_source = jai_constants.source_manual_entry THEN
      /*No need to Set Balancing Account Name as there is no need to derive balancing account because User ENTERs it in MANUAL
      ENTRY Form*/
      lv_statement := '5';
      lv_codepath := jai_general_pkg.plot_codepath(5, lv_codepath);
      lv_account_name := p_account_name;
      IF lv_account_name IN (jai_constants.recovery, jai_constants.recovery_interim) THEN
        lv_codepath := jai_general_pkg.plot_codepath(6, lv_codepath);
        lv_register_entry_type  := jai_constants.credit;
        lv_charge_entry_type    := jai_constants.debit;
        lv_balancing_entry_type := jai_constants.credit;
      ELSIF lv_account_name IN (jai_constants.liability, jai_constants.liability_interim) THEN
        lv_codepath := jai_general_pkg.plot_codepath(7, lv_codepath);
        lv_register_entry_type  := jai_constants.debit;
        lv_charge_entry_type    := jai_constants.credit;
        lv_balancing_entry_type := jai_constants.debit;
      END IF;

    /* Incase of Distributions and settlements, we hit only recovery account and decrease/increase
    repository amounts as per _OUT/_IN trxns*/
    ELSIF p_source IN (jai_constants.service_src_distribute_out, jai_constants.source_settle_out) THEN
      lv_statement := '6';
      lv_codepath := jai_general_pkg.plot_codepath(8, lv_codepath);
      lv_register_entry_type    := jai_constants.debit;
      /* following is changed as per Shekhars finding. this is because incase of distributions and settlements,
      we should hit only recovery accounts*/
      lv_account_name           := jai_constants.recovery;    -- jai_constants.liability; This is changed as per Shekhars finding
      lv_charge_entry_type      := jai_constants.credit;
      lv_balancing_accnt_name   := jai_constants.recovery;
      lv_balancing_entry_type   := jai_constants.debit;
--       IF (p_source = jai_constants.source_settle_out) THEN
--        lv_balancing_accnt_name := jai_constants.liability;
--      END IF; /*Added  by nprashar for bug 7525691*/

    ELSIF p_source IN (jai_constants.service_src_distribute_in, jai_constants.source_settle_in) THEN
      lv_statement := '7';
      lv_codepath := jai_general_pkg.plot_codepath(9, lv_codepath);
      lv_register_entry_type    := jai_constants.credit;
      lv_account_name           := jai_constants.recovery;
      lv_charge_entry_type      := jai_constants.debit;
      lv_balancing_entry_type   := jai_constants.credit;
      lv_balancing_accnt_name   := jai_constants.recovery;    -- jai_constants.liability;
      /*bug 7525691*/
      IF (p_source = jai_constants.source_settle_in) THEN
        lv_account_name := jai_constants.liability;
      END IF;
      /*end bug 7525691*/

    END IF;

    IF lv_register_entry_type = jai_constants.debit THEN
      lv_statement := '8';
      lv_codepath := jai_general_pkg.plot_codepath(10, lv_codepath);
      ln_debit      := p_amount;
      ln_credit     := NULL;
      ln_trx_debit  := nvl(ln_trx_amount, p_amount);
      ln_trx_credit := null;
    ELSE
      lv_statement := '9';
      lv_codepath := jai_general_pkg.plot_codepath(11, lv_codepath);
      ln_debit      := NULL;
      ln_credit     := p_amount;
      ln_trx_debit  := null;
      ln_trx_credit := nvl(ln_trx_amount, p_amount);
    END IF;

    lv_statement := '13';
    IF p_charge_account_id IS NULL THEN
      lv_codepath := jai_general_pkg.plot_codepath(12, lv_codepath);
      ln_charge_account_id := get_account(
                                p_regime_id         => p_regime_id,
                                p_organization_type => p_organization_type,
                                p_organization_id   => p_organization_id,
                                p_location_id       => p_location_id,
                                p_tax_type          => p_tax_type,
                                p_account_name      => lv_account_name
                              );
    ELSE
      lv_statement := '14';
      ln_charge_account_id := p_charge_account_id;
    END IF;

    lv_statement := '9.1';
    lv_balancing_orgn_type      := p_balancing_orgn_type;
    ln_balancing_orgn_id        := p_balancing_orgn_id;
    ln_balancing_location_id    := p_balancing_location_id;
    lv_balancing_tax_type       := p_balancing_tax_type;
    lv_balancing_accnt_name     := nvl(p_balancing_accnt_name, lv_balancing_accnt_name);

    lv_statement := '12';
    IF ln_balancing_orgn_id IS NULL THEN
      lv_codepath := jai_general_pkg.plot_codepath(13, lv_codepath);
      lv_balancing_orgn_type      := p_organization_type;
      ln_balancing_orgn_id        := p_organization_id;
      ln_balancing_location_id    := p_location_id;
      lv_balancing_tax_type       := p_tax_type;
    END IF;

    lv_statement := '17';
    IF p_balancing_account_id IS NULL THEN -- AND lv_balancing_accnt_name IS NOT NULL THEN
      lv_codepath := jai_general_pkg.plot_codepath(14, lv_codepath);
      ln_balancing_account_id := get_account(
                                    p_regime_id         => p_regime_id,
                                    p_organization_type => lv_balancing_orgn_type,
                                    p_organization_id   => ln_balancing_orgn_id,
                                    p_location_id       => ln_balancing_location_id,
                                    p_tax_type          => lv_balancing_tax_type,
                                    p_account_name      => lv_balancing_accnt_name
                                 );
    ELSE
      ln_balancing_account_id := p_balancing_account_id;
    END IF;

    lv_statement := '10';
    /*
     Following cursor added by ssumaith to get the primary registration number - bug# 4204880
     Added the column regime_primary_regno in the insert column list of the table jai_rgm_trx_records table.
    */
    OPEN   c_primary_regno('PRIMARY');  --rchandan for bug#4428980
    FETCH  c_primary_regno into lv_primary_regime_regno;
    CLOSE  c_primary_regno;

    lv_codepath := jai_general_pkg.plot_codepath(15, lv_codepath);
    INSERT INTO jai_rgm_trx_records(
      repository_id, regime_code, tax_type, source,
      source_document_id, source_table_name, transaction_date, debit_amount, credit_amount,
      settled_amount, settled_flag, settlement_id, organization_type,
      organization_id, location_id, account_name, charge_account_id, balancing_account_id,
      reference_id, source_trx_type, tax_rate, assessable_value, batch_id,
      trx_currency, curr_conv_date, curr_conv_rate, trx_credit_amount, trx_debit_amount,
      creation_date, created_by, last_update_date, last_updated_by, last_update_login,
      trx_reference_context, trx_reference1, trx_reference2, trx_reference3, trx_reference4, trx_reference5
      , inv_organization_id, regime_primary_regno ,service_type_code /* added by ssawant for bug 5879769 */
    ) VALUES (
      jai_rgm_trx_records_s.nextval, lv_regime_code, p_tax_type, p_source,
      p_source_document_id, p_source_table_name, ld_transaction_date, ln_debit, ln_credit,
      null, null, p_settlement_id, p_organization_type,
      p_organization_id, p_location_id, p_account_name, ln_charge_account_id, ln_balancing_account_id,
      p_reference_id, p_source_trx_type, p_tax_rate, p_assessable_value, p_batch_id,
      p_currency_code, p_curr_conv_date, p_curr_conv_rate, ln_trx_credit, ln_trx_debit,
      sysdate, FND_GLOBAL.user_id, sysdate, FND_GLOBAL.user_id, fnd_global.login_id,
      p_trx_reference_context, p_trx_reference1, p_trx_reference2, p_trx_reference3, p_trx_reference4, p_trx_reference5
      , p_inv_organization_id , lv_primary_regime_regno ,p_service_type_code /* added by ssawant for bug 5879769 */
    ) RETURNING repository_id INTO p_repository_id;

    -- ~~~~~~~~~~~~~~~~~~~~~~~ Accounting of Recovered/Liable Service Tax ~~~~~~~~~~~~~~~~~~~~~

    lv_statement := '11';
    IF p_accntg_required_flag = jai_constants.yes THEN

      lv_statement := '15';
      lv_codepath := jai_general_pkg.plot_codepath(16, lv_codepath);
      IF ln_charge_account_id IS NULL THEN
        lv_codepath := jai_general_pkg.plot_codepath(17, lv_codepath);
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'Charge Account('||lv_account_name||') not defined for tax type '||p_tax_type;
        FND_FILE.put_line( FND_FILE.log, p_process_message); fnd_file.put_line(fnd_file.log,p_process_message);
        GOTO end_of_repository_entry;
      END IF;

      lv_statement := '16';
      IF g_debug='Y' THEN
        fnd_file.put_line(fnd_file.log,'pkg2. rgm_id:'||p_regime_id||',OrgType:'||lv_balancing_orgn_type
          ||',Oid:'||ln_balancing_orgn_id||',locid:'||ln_balancing_location_id
          ||',txty:'||lv_balancing_tax_type||',actName:'||lv_balancing_accnt_name
        );
      END IF;

      lv_statement := '18';
      IF ln_balancing_account_id IS NULL THEN
        lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
        p_process_flag    := jai_constants.expected_error;
        p_process_message := 'Balancing Account('||lv_balancing_accnt_name||') not defined for tax type '||lv_balancing_tax_type;
        FND_FILE.put_line( FND_FILE.log, p_process_message); fnd_file.put_line(fnd_file.log,p_process_message);
        GOTO end_of_repository_entry;
      END IF;

      ln_reference_id := p_reference_id;
      IF p_source IN ( jai_constants.source_ap, jai_constants.source_ar) THEN
        lv_reference_name   := jai_constants.rgm_trx_refs;
      END IF;

      lv_statement := '19';
      -- INITIAL_ENTRY
      IF lv_charge_entry_type = jai_constants.debit THEN
        lv_codepath := jai_general_pkg.plot_codepath(19, lv_codepath);
        ln_debit          := p_amount;
        ln_credit         := NULL;
        ln_trx_debit      := nvl(ln_trx_amount, p_amount);
        ln_trx_credit     := null;
      ELSE
        ln_debit          := NULL;
        ln_credit         := p_amount;
        ln_trx_debit      := null;
        ln_trx_credit     := nvl(ln_trx_amount, p_amount);
      END IF;

      lv_statement := '20';
      lv_codepath := jai_general_pkg.plot_codepath(20, lv_codepath);
      -- make a call to post_accounting procedure
      post_accounting(
        p_regime_code         => lv_regime_code,
        p_tax_type            => p_tax_type,
        p_organization_type   => p_organization_type,
        p_organization_id     => p_organization_id,
        p_source              => p_source,
        p_source_trx_type     => p_source_trx_type,
        p_source_table_name   => p_source_table_name,
        p_source_document_id  => p_source_document_id,
        p_code_combination_id => ln_charge_account_id,
        p_entered_cr          => ln_trx_credit,
        p_entered_dr          => ln_trx_debit,
        p_accounted_cr        => ln_credit,
        p_accounted_dr        => ln_debit,
        p_accounting_date     => p_accounting_date,
        p_transaction_date    => ld_transaction_date,
        p_calling_object      => p_called_from,
        p_repository_name     => jai_constants.repository_name,
        p_repository_id       => p_repository_id,
        p_reference_name      => lv_reference_name,
        p_reference_id        => ln_reference_id,
        p_currency_code       => p_currency_code,
        p_curr_conv_date      => p_curr_conv_date,
        p_curr_conv_type      => p_curr_conv_type,
        p_curr_conv_rate      => p_curr_conv_rate
      );

      /* START of DISCOUNT ACCOUNTING */
      IF nvl(p_discounted_amount, 0) <> 0 THEN
        -- Discount related code needs to be added here
        lv_statement := '20.1';
        lv_codepath := jai_general_pkg.plot_codepath(21, lv_codepath);

        IF p_source = jai_constants.source_ar THEN

          lv_codepath := jai_general_pkg.plot_codepath(21.1, lv_codepath);
          jai_ar_rgm_processing_pkg.get_ar_tax_disc_accnt  (
            p_receivable_application_id   => p_source_document_id,
            p_org_id                      => ln_org_id,/* added by ssawant for bug 5879769 */
            p_total_disc_amount           => p_discounted_amount, /* added by ssumaith - for bug# 4193633*/
            p_tax_ediscounted             => ln_earned_discount,
            p_earned_disc_ccid            => ln_earned_disc_accnt,
            p_tax_uediscounted            => ln_unearned_discount,
            p_unearned_disc_ccid          => ln_unearned_disc_accnt,
            p_process_flag                => p_process_flag,
            p_process_message             => p_process_message
          );

          IF p_process_flag IN (jai_constants.expected_error, jai_constants.unexpected_error) THEN
            lv_codepath := jai_general_pkg.plot_codepath(21.2, lv_codepath);
            -- some problem in the above call
            RETURN;
          ELSIF nvl(ln_earned_discount, 0) + nvl(ln_unearned_discount, 0) <> NVL(p_discounted_amount,0) THEN
            lv_codepath := jai_general_pkg.plot_codepath(21.3, lv_codepath);
            p_process_flag := jai_constants.expected_error;
            p_process_message := 'There is a discrepency in earned + unearned = discounted';
            RETURN;
          END IF;

          --- following will be used for first accounting entry incase of AR Receipt Application
          IF nvl(ln_earned_discount,0) <> 0 THEN
            ln_discount_ccid      := ln_earned_disc_accnt;
            IF lv_charge_entry_type = jai_constants.debit THEN
              lv_codepath := jai_general_pkg.plot_codepath(21.4, lv_codepath);
              ln_disc_credit        := null;
              ln_disc_debit         := ln_earned_discount;
            ELSE
              lv_codepath := jai_general_pkg.plot_codepath(21.5, lv_codepath);
              ln_disc_credit        := ln_earned_discount;
              ln_disc_debit         := null;
            END IF;

          ELSE
            ln_disc_credit        := null;
            ln_disc_debit         := null;
          END IF;

        /* following else will be executed for AP Transactions only */
        ELSE

          ln_discount_ccid := get_account(
                                  p_regime_id         => null,
                                  p_organization_type => p_organization_type,
                                  p_organization_id   => ln_org_id , -- Date 07/06/2007 by sacsethi for bug 6109941 - changed organization_id to org_id ( ou_level )
                                  p_location_id       => null,
                                  p_tax_type          => null,
                                  p_account_name      => jai_cmn_rgm_recording_pkg.ap_discount_accnt
                              );

          IF ln_discount_ccid IS NULL THEN
            lv_codepath := jai_general_pkg.plot_codepath(18, lv_codepath);
            p_process_flag    := jai_constants.expected_error;
            p_process_message := 'Discount Account is not defined in '||p_source;
            FND_FILE.put_line( FND_FILE.log, p_process_message); fnd_file.put_line(fnd_file.log,p_process_message);
            FND_FILE.put_line( FND_FILE.log, ln_org_id);
            GOTO end_of_repository_entry;
          END IF;

          IF lv_charge_entry_type = jai_constants.debit THEN
            ln_disc_credit    := null;
            ln_disc_debit     := p_discounted_amount;
          ELSE
            ln_disc_debit     := null;
            ln_disc_credit    := p_discounted_amount;
          END IF;

        END IF;

        IF ln_disc_debit IS NOT NULL OR ln_disc_credit IS NOT NULL THEN
          lv_codepath := jai_general_pkg.plot_codepath(21.6, lv_codepath);
          -- make a call to post_accounting procedure
          post_accounting(
            p_regime_code         => lv_regime_code,
            p_tax_type            => p_tax_type,
            p_organization_type   => p_organization_type,
            p_organization_id     => p_organization_id,
            p_source              => p_source,
            p_source_trx_type     => p_source_trx_type,
            p_source_table_name   => p_source_table_name,
            p_source_document_id  => p_source_document_id,
            p_code_combination_id => ln_discount_ccid,
            p_entered_cr          => ln_disc_credit,
            p_entered_dr          => ln_disc_debit,
      -- Added nvl(p_curr_conv_rate, 1) for Bug 7522584
            p_accounted_cr        => ln_disc_credit * nvl(p_curr_conv_rate, 1),
            p_accounted_dr        => ln_disc_debit * nvl(p_curr_conv_rate, 1),
            p_accounting_date     => p_accounting_date,
            p_transaction_date    => ld_transaction_date,
            p_calling_object      => p_called_from,
            p_repository_name     => jai_constants.repository_name,
            p_repository_id       => p_repository_id,
            p_reference_name      => lv_reference_name,
            p_reference_id        => ln_reference_id,
            p_currency_code       => p_currency_code,
            p_curr_conv_date      => p_curr_conv_date,
            p_curr_conv_type      => p_curr_conv_type,
            p_curr_conv_rate      => p_curr_conv_rate
          );

        END IF;

        -- following entry will happen only in case of AR Transactions
        IF nvl(ln_unearned_discount,0) <> 0 THEN
          lv_codepath := jai_general_pkg.plot_codepath(21.7, lv_codepath);
          ln_discount_ccid        := ln_unearned_disc_accnt;
          IF lv_charge_entry_type = jai_constants.debit THEN
            ln_disc_credit        := null;
            ln_disc_debit         := ln_unearned_discount;
          ELSE
            ln_disc_credit        := ln_unearned_discount;
            ln_disc_debit         := null;
          END IF;

          post_accounting(
            p_regime_code         => lv_regime_code,
            p_tax_type            => p_tax_type,
            p_organization_type   => p_organization_type,
            p_organization_id     => p_organization_id,
            p_source              => p_source,
            p_source_trx_type     => p_source_trx_type,
            p_source_table_name   => p_source_table_name,
            p_source_document_id  => p_source_document_id,
            p_code_combination_id => ln_discount_ccid,
            p_entered_cr          => ln_disc_credit,
            p_entered_dr          => ln_disc_debit,
      -- Added nvl(p_curr_conv_rate, 1) for Bug 7522584
            p_accounted_cr        => ln_disc_credit * nvl(p_curr_conv_rate, 1),
            p_accounted_dr        => ln_disc_debit * nvl(p_curr_conv_rate, 1),
            p_accounting_date     => p_accounting_date,
            p_transaction_date    => ld_transaction_date,
            p_calling_object      => p_called_from,
            p_repository_name     => jai_constants.repository_name,
            p_repository_id       => p_repository_id,
            p_reference_name      => lv_reference_name,
            p_reference_id        => ln_reference_id,
            p_currency_code       => p_currency_code,
            p_curr_conv_date      => p_curr_conv_date,
            p_curr_conv_type      => p_curr_conv_type,
            p_curr_conv_rate      => p_curr_conv_rate
          );

        END IF;

        lv_codepath := jai_general_pkg.plot_codepath(21.8, lv_codepath);
      END IF;
      /* END of DISCOUNT ACCOUNTING */


      lv_statement := '21';
      /*bug 7525691 - Service Tax Settlement creates duplicate entries.
        Balancing entry should not be passed in following cases:
        1. Settlement Transactions
        2. Distribution Transactions with distribution type Service->Service
        Modified the condition earlier added for distribution to consider distribution type
        also - observation from 11i bug 8315191 (R12 bug 8329634 gets fixed due to this)*/
      IF (p_source NOT IN (jai_constants.source_settle_in, jai_constants.source_settle_out))
      AND (p_source NOT IN (jai_constants.service_src_distribute_out, jai_constants.service_src_distribute_in)
           OR nvl(p_distribution_type,'X')<>'S-S')THEN
      -- BALANCING_ENTRY
      IF lv_balancing_entry_type = jai_constants.debit THEN
        lv_codepath := jai_general_pkg.plot_codepath(22, lv_codepath);
    ln_debit          := p_amount + (nvl(p_discounted_amount,0) * nvl(p_curr_conv_rate, 1));
    -- Added p_curr_conv_rate for Bug 7522584
        ln_credit         := NULL;
        ln_trx_debit      := nvl(ln_trx_amount, p_amount)+ nvl(p_discounted_amount,0);
        ln_trx_credit     := null;
      ELSE
        ln_debit          := NULL;
        ln_credit         := p_amount + (nvl(p_discounted_amount,0) * nvl(p_curr_conv_rate, 1));
    -- Added p_curr_conv_rate for Bug 7522584
        ln_trx_debit      := null;
        ln_trx_credit     := nvl(ln_trx_amount, p_amount)+ nvl(p_discounted_amount,0);
      END IF;

      lv_statement := '22';
      -- make a call to post_accounting procedure
      post_accounting(
        p_regime_code         => lv_regime_code,
        p_tax_type            => p_tax_type,
        p_organization_type   => lv_balancing_orgn_type,
        p_organization_id     => ln_balancing_orgn_id,
        p_source              => p_source,
        p_source_trx_type     => p_source_trx_type,
        p_source_table_name   => p_source_table_name,
        p_source_document_id  => p_source_document_id,
        p_code_combination_id => ln_balancing_account_id,
        p_entered_cr          => ln_trx_credit,           -- TRANSACTION_CURR
        p_entered_dr          => ln_trx_debit,
        p_accounted_cr        => ln_credit,               -- FUNC_CURR
        p_accounted_dr        => ln_debit,
        p_accounting_date     => p_accounting_date,
        p_transaction_date    => ld_transaction_date,
        p_calling_object      => p_called_from,
        p_repository_name     => jai_constants.repository_name,
        p_repository_id       => p_repository_id,
        p_reference_name      => lv_reference_name,
        p_reference_id        => ln_reference_id,
        p_currency_code       => p_currency_code,
        p_curr_conv_date      => p_curr_conv_date,
        p_curr_conv_type      => p_curr_conv_type,
        p_curr_conv_rate      => p_curr_conv_rate
      );

    END IF; --bug 7692977
    END IF;
    lv_statement := '23';
    p_process_flag    := jai_constants.successful;
    p_process_message := 'Successful';

    lv_statement := '24';
    <<end_of_repository_entry>>
    lv_codepath := jai_general_pkg.plot_codepath(23, lv_codepath, 'Insert_Repository_entry', 'END');

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := 'Repository Error(Stmt:'||lv_statement||') Occured:'||SQLERRM;
      lv_codepath := jai_general_pkg.plot_codepath(-999, lv_codepath);
      Fnd_file.put_line( fnd_file.log, 'Error in Insert_Repository_entry. Codepath:'||lv_codepath);

  END insert_repository_entry;

  /* ~~~~~~~~~~~~~~~ Start of Accounting Entry Procedure ~~~~~~~~~~~~~~~~~ */
  PROCEDURE post_accounting(
    p_regime_code           IN  VARCHAR2,
    p_tax_type              IN  VARCHAR2,
    p_organization_type     IN  VARCHAR2,
    p_organization_id       IN  NUMBER,
    p_source                IN  VARCHAR2,
    p_source_trx_type       IN  VARCHAR2,
    p_source_table_name     IN  VARCHAR2,
    p_source_document_id    IN  NUMBER,
    p_code_combination_id   IN  NUMBER,
    -- Transaction Currency Amount
    p_entered_cr            IN  NUMBER,
    p_entered_dr            IN  NUMBER,
    -- Functional Currency Amount
    p_accounted_cr          IN  NUMBER,
    p_accounted_dr          IN  NUMBER,
    p_accounting_date       IN  DATE,
    p_transaction_date      IN  DATE,
    p_calling_object        IN  VARCHAR2,
    p_repository_name       IN  VARCHAR2    DEFAULT NULL,
    p_repository_id         IN  NUMBER      DEFAULT NULL,
    p_reference_name        IN  VARCHAR2    DEFAULT NULL,
    p_reference_id          IN  NUMBER      DEFAULT NULL,
    p_currency_code         IN  VARCHAR2    DEFAULT NULL,
    p_curr_conv_date        IN  DATE        DEFAULT NULL,
    p_curr_conv_type        IN  VARCHAR2    DEFAULT NULL,
    p_curr_conv_rate        IN  NUMBER      DEFAULT NULL
  ) IS

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_recording_pkg.post_accounting';

    lv_reference10          GL_INTERFACE.reference10%type;
    lv_reference23          GL_INTERFACE.reference23%type;
    lv_reference24          GL_INTERFACE.reference24%type;
    lv_reference25          GL_INTERFACE.reference25%type;
    lv_reference26          GL_INTERFACE.reference26%type;

    ld_accounting_date      DATE;
    lv_message              VARCHAR2(100);

    lv_period_name          GL_PERIODS.period_name%TYPE;
    ln_sob_id               GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
    ln_currency_precision   FND_CURRENCIES.precision%TYPE;

    ln_entered_dr           NUMBER;
    ln_entered_cr           NUMBER;
    ln_accounted_dr         NUMBER;
    ln_accounted_cr         NUMBER;

    lv_regime_code          JAI_RGM_DEFINITIONS.regime_code%TYPE;
    lv_reference_name       VARCHAR2(30);
    ln_reference_id         NUMBER(15);
    lv_gl_je_category       varchar2(30); --File.Sql.35 Cbabu  jai_constants.je_category_rg_entry%type;
    lv_status               gl_interface.status%TYPE ; --rchandan for bug#4428980
    lv_source_name                                      VARCHAR2(30);  -- modified by csahoo for bug#6155839
    /*Begin-Added the following by kunkumar for forward porting 5051541 to R12*/


    lv_organization_code                mtl_parameters.organization_code%TYPE;

    CURSOR c_organization_code(cp_organization_id       IN      NUMBER)
    IS
    SELECT      organization_code
    FROM        mtl_parameters
    WHERE       organization_id = cp_organization_id;

    -- added, ssumaith for Bug 6664855

    Cursor c_get_source_info(cp_transfer_id NUMBER)
    IS
    select party_id
    from   jai_rgm_dis_src_hdrs
    where  transfer_id =  cp_transfer_id ;


    Cursor c_get_dest_info(cp_transfer_id NUMBER)
    IS
    select destination_party_id
    from   jai_rgm_dis_des_hdrs
    where  transfer_id =  cp_transfer_id ;

    Cursor c_get_source(cp_repository_id NUMBER)
    IS
    select source
    from   jai_rgm_trx_records
    where  repository_id = cp_repository_id      ;


    lv_source        jai_rgm_trx_records.source%TYPE ;
    lv_src_party_id  jai_rgm_dis_src_hdrs.party_id%TYPE ;
    lv_reference1    gl_interface.reference1%TYPE ;
    ln_loop_cnt      NUMBER;

    -- end, ssumaith for Bug 6664855

  BEGIN
    --Bug 5051541 bduvarag
    jai_cmn_utils_pkg.print_log('6395039.log', 'Start of post_accounting');

    -- added, ssumaith for Bug 6664855
    lv_reference1 := null ;

    OPEN  c_get_source(p_repository_id) ;
    FETCH c_get_source INTO lv_source ;
    CLOSE c_get_source ;

    /* Reference column should be populated with same value for a set of Journals that are passed as part
    of a transaction, else Journal Import will fail with EUXX error.
    Prior to this fix, incase of Distribution of duty from one orgn. to other, reference1 is getting populated
    with different values for different Journal. Hence the following logic of the IF condition is used to derive the
    value for reference1 for all the Journals that are part of the Distribution (Service tax or any duty distribution
    */

    IF lv_source IN (jai_constants.service_src_distribute_in, jai_constants.service_src_distribute_out,
                        'DISTRIBUTE_IN', 'DISTRIBUTE_OUT')
    THEN
        lv_reference1 := '' ;

  OPEN  c_get_source_info(p_source_document_id) ;
  FETCH c_get_source_info INTO lv_src_party_id ;
  CLOSE c_get_source_info ;

  lv_reference1 := to_char(lv_src_party_id)||'->';
  ln_loop_cnt := 1;
  FOR rec IN c_get_dest_info(p_source_document_id)
  LOOP
    if ln_loop_cnt > 1 then
       lv_reference1 := lv_reference1 || ',';
    end if;
    lv_reference1 := lv_reference1 || to_char(rec.destination_party_id);
    ln_loop_cnt := ln_loop_cnt + 1;
  END LOOP ;

    ELSE
        OPEN c_organization_code(p_organization_id);
        FETCH c_organization_code INTO lv_organization_code;
        CLOSE c_organization_code;
        lv_reference1 := lv_organization_code ;
    END IF ;

    -- ended, ssumaith for Bug 6664855

    /* following condition introduced for VAT Impl. Vijay Shankar for Bug#4250236(4245089) */
    IF p_regime_code = jai_constants.service_regime THEN
      lv_reference10 := 'Service Tax Accounting for '||p_source||'. Transaction Type:'||nvl(p_source_trx_type,'~~');
      lv_source_name := jai_constants.service_tax_source;    -- added by csahoo for bug#6155839
    ELSIF p_regime_code = jai_constants.vat_regime THEN
      lv_reference10 := 'VAT Accounting for '||p_source||'. Transaction Type:'||nvl(p_source_trx_type,'~~');
      lv_source_name := jai_constants.vat_source;    -- modified by csahoo for bug#6155839
      jai_cmn_utils_pkg.print_log('6395039.log', lv_reference10);
    END IF;

    ld_accounting_date := nvl( trunc(p_accounting_date), trunc(sysdate) );

    IF p_code_combination_id IS NULL THEN
      lv_message := 'Account not given';
      RAISE_APPLICATION_ERROR( -20011, lv_message);
    END IF;

    ln_currency_precision := jai_general_pkg.get_currency_precision(null);          -- CURRENCY is INR

    -- Use of Currency Precision to round off the values when posting to GL is mandatory thing
    ln_entered_dr   := round(p_entered_dr, ln_currency_precision);
    ln_entered_cr   := round(p_entered_cr, ln_currency_precision);
    ln_accounted_dr := round(p_accounted_dr, ln_currency_precision);
    ln_accounted_cr := round(p_accounted_cr, ln_currency_precision);

    IF ( nvl(ln_entered_dr, 0) = 0 AND nvl(ln_entered_cr,0) = 0
         OR nvl(ln_accounted_dr, 0) = 0 AND nvl(ln_accounted_cr,0) = 0 )
    THEN

     -- Date 07-jun-2007 by sacsethi for bug 6109941
     -- Previously we were generating raise application error which is changed
     -- to information level ....

      FND_FILE.put_line( FND_FILE.log, 'Accounting not done as Both Credit and Debit are Zero ');
      RETURN ;

    END IF;
                jai_cmn_utils_pkg.print_log('6395039.log', 'before call to get_period_name');
    get_period_name(
      p_organization_type => p_organization_type,
      p_organization_id   => p_organization_id,
      p_accounting_date   => ld_accounting_date,
      p_period_name       => lv_period_name,
      p_sob_id            => ln_sob_id
    );
    jai_cmn_utils_pkg.print_log('6395039.log', 'after call to get_period_name');

    /* following added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    lv_gl_je_category := jai_constants.je_category_rg_entry;
    lv_status := 'NEW';--rchandan for bug#4428980
    jai_cmn_utils_pkg.print_log('6395039.log', 'before insert inot gl_interface');
    INSERT INTO gl_interface (
      status, set_of_books_id, user_je_source_name, user_je_category_name,
      accounting_date, currency_code, date_created, created_by,
      actual_flag, entered_cr, entered_dr, accounted_cr, accounted_dr, transaction_date,
      code_combination_id, currency_conversion_date, user_currency_conversion_type, currency_conversion_rate,
      reference10, reference22, reference23, reference1,
      reference24, reference25, reference26, reference27
    ) VALUES (
      lv_status, ln_sob_id, lv_source_name, lv_gl_je_category,
      ld_accounting_date, p_currency_code, sysdate, FND_GLOBAL.user_id,
      'A', ln_entered_cr, ln_entered_dr, ln_accounted_cr, ln_accounted_dr, p_transaction_date,
      p_code_combination_id, p_curr_conv_date, p_curr_conv_type, p_curr_conv_rate,
      lv_reference10, jai_constants.gl_je_source_name, p_calling_object, lv_reference1,
      -- commented lv_organization_code and passed refererence1 ssumaith bug#6664855
      --Bug 5051541 kunkumar
      p_source_table_name, p_source_document_id, p_repository_name, p_organization_id
    );
                jai_cmn_utils_pkg.print_log('6395039.log', 'after insert inot gl_interface');
    IF p_reference_id IS NOT NULL OR p_reference_name IS NOT NULL THEN
      lv_reference_name   := p_reference_name;
      ln_reference_id     := p_reference_id;
    ELSE
      lv_reference_name   := p_repository_name;
      ln_reference_id     := p_repository_id;
    END IF;
                jai_cmn_utils_pkg.print_log('6395039.log', 'before insert inot JAI_CMN_JOURNAL_ENTRIES');
    INSERT INTO JAI_CMN_JOURNAL_ENTRIES(JOURNAL_ENTRY_ID,
      regime_code, organization_id, set_of_books_id, tax_type, period_name,
      code_combination_id, accounted_dr, accounted_cr, transaction_date,
      source, source_table_name, source_trx_id, reference_name, reference_id, repository_id,/* added by ssawant for bug 5879769 */
      currency_code, curr_conv_rate, creation_date, created_by, last_update_date, last_updated_by, last_update_login
    ) VALUES ( JAI_CMN_JOURNAL_ENTRIES_S.nextval,
      p_regime_code, p_organization_id, ln_sob_id, p_tax_type, lv_period_name,
      p_code_combination_id, ln_accounted_dr, ln_accounted_cr, p_transaction_date,
      p_source, p_source_table_name, p_source_document_id, p_reference_name, p_reference_id,p_repository_id,/* added by ssawant for bug 5879769 */
      p_currency_code, p_curr_conv_rate, sysdate, FND_GLOBAL.user_id, sysdate, fnd_global.user_id, fnd_global.login_id
    );

                jai_cmn_utils_pkg.print_log('6395039.log', 'after insert inot JAI_CMN_JOURNAL_ENTRIES');
   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      jai_cmn_utils_pkg.print_log('6395039.log', 'exception occured'||sqlerrm);
      app_exception.raise_exception;

  END post_accounting;

  PROCEDURE insert_reference(
    p_reference_id              OUT NOCOPY NUMBER,
    p_organization_id       IN  NUMBER,             /* Operating Unit */
    p_source                IN  VARCHAR2,
    p_invoice_id            IN  NUMBER,
    p_line_id               IN  NUMBER,
    p_tax_type              IN  VARCHAR2,
    p_tax_id                IN  NUMBER,
    p_tax_rate              IN  NUMBER,
    p_recoverable_ptg       IN  NUMBER,
    p_party_type            IN  VARCHAR2,
    p_party_id              IN  NUMBER,
    p_party_site_id         IN  NUMBER,
    p_trx_tax_amount        IN  NUMBER,
    p_trx_currency          IN  VARCHAR2,
    p_curr_conv_date        IN  DATE,
    p_curr_conv_rate        IN  NUMBER,
    p_tax_amount            IN  NUMBER,
    p_recoverable_amount    IN  NUMBER,
    p_recovered_amount      IN  NUMBER,
    p_item_line_id          IN  NUMBER,
    p_item_id               IN  NUMBER,
    p_taxable_basis         IN  NUMBER,
    p_parent_reference_id   IN  NUMBER,
    p_reversal_flag         IN  VARCHAR2,
    p_batch_id              IN  NUMBER,
    p_process_flag            OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
    /* Location_Id Required for VAT??? */
  ) IS

  BEGIN

    INSERT INTO jai_rgm_trx_refs(
      reference_id,
      organization_id,
      source,
      invoice_id,
      line_id,
      tax_type,
      tax_id,
      tax_rate,
      recoverable_ptg,
      trx_tax_amount,
      trx_currency,
      curr_conv_date,
      curr_conv_rate,
      tax_amount,
      recoverable_amount,
      recovered_amount,
      taxable_basis,
      party_type,
      party_id,
      party_site_id,
      item_line_id,
      item_id,
      parent_reference_id,
      reversal_flag,
      batch_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      jai_rgm_trx_refs_s.nextval,
      p_organization_id,
      p_source,
      p_invoice_id,
      p_line_id,
      p_tax_type,
      p_tax_id,
      p_tax_rate,
      p_recoverable_ptg,
      p_trx_tax_amount,
      p_trx_currency,
      p_curr_conv_date,
      p_curr_conv_rate,
      p_tax_amount,
      p_recoverable_amount,
      p_recovered_amount,
      p_taxable_basis,
      p_party_type,
      p_party_id,
      p_party_site_id,
      p_item_line_id,
      p_item_id,
      p_parent_reference_id,
      p_reversal_flag,
      p_batch_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id
    ) RETURNING reference_id INTO p_reference_id;

    p_process_flag := jai_constants.successful;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag := jai_constants.unexpected_error;
      p_process_message := 'jai_cmn_rgm_recording_pkg.insert_reference failed with error - '||SQLERRM;
      fnd_file.put_line( fnd_file.log, p_process_message);
  END insert_reference;

  FUNCTION get_account(
    p_regime_id         IN  NUMBER,
    p_organization_type IN  VARCHAR2,
    p_organization_id   IN  NUMBER,
    p_location_id       IN  NUMBER,
    p_tax_type          IN  VARCHAR2,
    p_account_name      IN  VARCHAR2
  ) RETURN NUMBER IS

   /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_recording_pkg.get_account';

    CURSOR c_orgn_account(cp_organization_id IN NUMBER, cp_location_id IN NUMBER, cp_register_type IN VARCHAR2) IS
      SELECT decode(cp_register_type,
                      jai_constants.register_type_a, modvat_rm_account_id,
                      jai_constants.register_type_c, modvat_cg_account_id,
                      jai_constants.register_type_pla, modvat_pla_account_id
                   )
      FROM JAI_CMN_INVENTORY_ORGS a
      WHERE organization_id = cp_organization_id
      AND ( (cp_location_id IS NOT NULL AND a.location_id = cp_location_id)
            OR (cp_location_id IS NULL AND (a.location_id IS NULL OR a.location_id = 0))
          );

      /*
      || Cursor added by Ramananda
      || Start of Bug#4546114
      */
      CURSOR c_orgn_cess_account(cp_organization_id IN NUMBER, cp_location_id IN NUMBER, cp_register_type IN VARCHAR2) IS
      SELECT decode(cp_register_type,
                      jai_constants.register_type_a,   excise_edu_cess_rm_account  ,
                      jai_constants.register_type_c,   excise_edu_cess_cg_account  ,
                      jai_constants.register_type_pla, modvat_pla_account_id
                   )
      FROM JAI_CMN_INVENTORY_ORGS a
      WHERE organization_id = cp_organization_id
      AND ( (cp_location_id IS NOT NULL AND a.location_id = cp_location_id)
            OR (cp_location_id IS NULL AND (a.location_id IS NULL OR a.location_id = 0))
          );
      /*
      || End of Bug#4546114
      */

      /*cursor added by vkaranam for bug #5989740*/
      -- start 5989740



          CURSOR c_orgn_sh_cess_account(cp_organization_id IN NUMBER, cp_location_id IN NUMBER, cp_register_type IN VARCHAR2) IS
            SELECT decode(cp_register_type,
                            jai_constants.register_type_a,   SH_CESS_RM_ACCOUNT  ,
                            jai_constants.register_type_c,   SH_CESS_CG_ACCOUNT_ID  ,
                            jai_constants.register_type_pla, modvat_pla_account_id
                         )
            FROM JAI_CMN_INVENTORY_ORGS  a
            WHERE organization_id = cp_organization_id
            AND ( (cp_location_id IS NOT NULL AND a.location_id = cp_location_id)
                  OR (cp_location_id IS NULL AND (a.location_id IS NULL OR a.location_id = 0))
                );
      -- end 5989740


    CURSOR c_orgn_tax_type_account(cp_regime_id IN NUMBER,
            cp_organization_type IN VARCHAR2, cp_organization_id IN NUMBER, cp_location_id IN NUMBER,
            cp_tax_type IN VARCHAR2, cp_account_name IN VARCHAR2) IS
      SELECT to_number(accnts.attribute_value)
      FROM JAI_RGM_REGISTRATIONS tax_types, JAI_RGM_ORG_REGNS_V accnts
      WHERE tax_types.regime_id = cp_regime_id
      AND tax_types.registration_type = jai_constants.regn_type_tax_types
      AND tax_types.attribute_code = cp_tax_type
      AND accnts.regime_id = tax_types.regime_id
      AND accnts.registration_type = jai_constants.regn_type_accounts
      AND accnts.parent_registration_id = tax_types.registration_id
      AND accnts.attribute_code = cp_account_name
      AND accnts.organization_type = cp_organization_type
      AND accnts.organization_id = cp_organization_id
      AND (cp_location_id IS NULL OR location_id = cp_location_id);


        /*Cursor added by ssawant for bug 5879769 */
        CURSOR c_orgn_tax_type_account_ou
     (  cp_regime_id IN NUMBER,
        cp_organization_type IN VARCHAR2,
        cp_organization_id IN NUMBER,
        cp_location_id IN NUMBER,
        cp_tax_type IN VARCHAR2,
        cp_account_name IN VARCHAR2
     )
   IS
      SELECT to_number(accnts.attribute_value)
      FROM JAI_RGM_REGISTRATIONS tax_types,
           jai_rgm_parties jrp ,
           JAI_RGM_REGISTRATIONS accnts
      WHERE tax_types.regime_id = cp_regime_id
      AND  jrp.regime_id = -accnts.regime_id
      AND tax_types.registration_type = jai_constants.regn_type_tax_types
      AND tax_types.attribute_code = cp_tax_type
      AND accnts.regime_id = tax_types.regime_id
      AND accnts.registration_type = jai_constants.regn_type_accounts
      AND accnts.parent_registration_id = tax_types.registration_id
      AND accnts.attribute_code = cp_account_name
      AND jrp.organization_type = cp_organization_type
      AND jrp.organization_id = cp_organization_id ;


    CURSOR c_operating_unit_of_inv_org(cp_organization_id IN NUMBER) IS
      SELECT to_number(operating_unit) org_id
      FROM org_organization_definitions
      WHERE organization_id = cp_organization_id;

    CURSOR c_ap_system_parameters(cp_org_id IN NUMBER) IS
      SELECT disc_taken_code_combination_id
      FROM ap_system_parameters_all
      WHERE org_id = cp_org_id;

    ln_code_combination_id    GL_CODE_COMBINATIONS.code_combination_id%TYPE;

    lv_organization_type      VARCHAR2(2);
    ln_organization_id        NUMBER;

    lv_regime_code            JAI_RGM_DEFINITIONS.regime_code%TYPE;
    lv_excise_cess            JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE; /* Added by Ramananda - bug# 4546114*/

  BEGIN

    lv_excise_cess := 'EXCISE-CESS'; /* Added by Ramananda - bug# 4546114*/

    /* following code is used to get the Discount Account in case of Payables */
    IF p_account_name = jai_cmn_rgm_recording_pkg.ap_discount_accnt THEN
      OPEN c_ap_system_parameters(p_organization_id);
      FETCH c_ap_system_parameters INTO ln_code_combination_id;
      CLOSE c_ap_system_parameters;

      GOTO end_of_function;
    END IF;

    OPEN c_regime_code(p_regime_id);
    FETCH c_regime_code INTO lv_regime_code;
    CLOSE c_regime_code;

    IF lv_regime_code = jai_constants.service_regime
      AND p_location_id IS NULL AND p_organization_type = jai_constants.orgn_type_io
    THEN
      lv_organization_type := jai_constants.orgn_type_ou;

      OPEN c_operating_unit_of_inv_org(p_organization_id);
      FETCH c_operating_unit_of_inv_org INTO ln_organization_id;
      CLOSE c_operating_unit_of_inv_org;

    ELSE
      lv_organization_type  := p_organization_type;
      ln_organization_id    := p_organization_id;
    END IF;

    IF lv_regime_code = jai_constants.service_regime
      AND lv_organization_type = jai_constants.orgn_type_io
    THEN

      IF  upper(p_tax_type) = UPPER(jai_constants.tax_type_excise)  THEN  /* IF condition added by Ramananda - bug#4546114 */
        OPEN c_orgn_account(ln_organization_id, p_location_id, p_account_name);
        FETCH c_orgn_account INTO ln_code_combination_id;
        CLOSE c_orgn_account;

        IF ln_code_combination_id IS NULL THEN
          OPEN c_orgn_account(ln_organization_id, NULL, p_account_name);
          FETCH c_orgn_account INTO ln_code_combination_id;
          CLOSE c_orgn_account;
        END IF;

     -- END IF ; /* END IF is commented and is replaced by elsif by ssawant for bug 5879769 */

      /*
      || Following IF condition and the cursor in it added by Ramananda
      || Start of Bug#4546114
      */
      ELSIF  upper(p_tax_type) IN (lv_excise_cess ,
                                jai_constants.tax_type_exc_edu_cess,
                                jai_constants.tax_type_cvd_edu_cess ,
                                jai_constants.tax_type_customs_edu_cess
                               )  THEN

          OPEN c_orgn_cess_account(ln_organization_id, p_location_id, p_account_name);
          FETCH c_orgn_cess_account INTO ln_code_combination_id;
          CLOSE c_orgn_cess_account;

          IF ln_code_combination_id IS NULL THEN
            OPEN c_orgn_cess_account(ln_organization_id, NULL, p_account_name);
            FETCH c_orgn_cess_account INTO ln_code_combination_id;
            CLOSE c_orgn_Cess_account;
          END IF;
--Date 05/03/2007 by vkaranam for bug#5989740
-- start 5989740
      ELSIF  upper(p_tax_type) IN (jai_constants.tax_type_sh_exc_edu_cess ,
                                   jai_constants.tax_type_sh_cvd_edu_cess ,
                                   jai_constants.tax_type_sh_customs_edu_Cess
                                  ) THEN

         OPEN c_orgn_sh_cess_account(ln_organization_id, p_location_id, p_account_name);
         FETCH c_orgn_sh_cess_account INTO ln_code_combination_id;
         CLOSE c_orgn_sh_cess_account;

         IF ln_code_combination_id IS NULL THEN
            OPEN c_orgn_sh_cess_account(ln_organization_id, NULL, p_account_name);
            FETCH c_orgn_sh_cess_account INTO ln_code_combination_id;
            CLOSE c_orgn_sh_cess_account;
          END IF;
-- end 5989740
        ELSE /* added by ssawant for bug 5879769 . This condition is newly added so that the Accoutn would be returned
             if regime SERVICE,org is IO and Taxes are of Service Type*/

        OPEN  c_orgn_tax_type_account(p_regime_id, lv_organization_type, ln_organization_id,
              p_location_id, p_tax_type, p_account_name);
        FETCH c_orgn_tax_type_account INTO ln_code_combination_id;
        CLOSE c_orgn_tax_type_account;
      END IF;
      /*
      || End of Bug#4546114
      */
    ELSIF lv_regime_code = jai_constants.vat_regime
          AND lv_organization_type = jai_constants.orgn_type_io
    THEN
        OPEN c_orgn_tax_type_account(p_regime_id, lv_organization_type, ln_organization_id,
              p_location_id, p_tax_type, p_account_name);
        FETCH c_orgn_tax_type_account INTO ln_code_combination_id;
        CLOSE c_orgn_tax_type_account;

                /*Added by CSahoo Bug# 5631784*/
                ELSIF lv_regime_code = jai_constants.tcs_regime THEN

                        OPEN c_orgn_tax_type_account(p_regime_id, lv_organization_type, ln_organization_id,
                                                p_location_id, p_tax_type, p_account_name);
                        FETCH c_orgn_tax_type_account INTO ln_code_combination_id;
      CLOSE c_orgn_tax_type_account;

    ELSIF  lv_organization_type = jai_constants.orgn_type_ou THEN

      /* added by ssawant for bug 5879769 */
     IF lv_regime_code = jai_constants.service_regime THEN

        OPEN c_orgn_tax_type_account_ou(p_regime_id, jai_constants.orgn_type_ou, ln_organization_id,
              null, p_tax_type, p_account_name);
        FETCH c_orgn_tax_type_account_ou INTO ln_code_combination_id;
        CLOSE c_orgn_tax_type_account_ou;
     ELSE
      OPEN c_orgn_tax_type_account(p_regime_id, jai_constants.orgn_type_ou, ln_organization_id,
            null, p_tax_type, p_account_name);
      FETCH c_orgn_tax_type_account INTO ln_code_combination_id;
      CLOSE c_orgn_tax_type_account;
    END IF;

    END IF;

    <<end_of_function>>

    RETURN ln_code_combination_id;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_account;

  PROCEDURE get_period_name(
    p_organization_type     IN      VARCHAR2,
    p_organization_id       IN      NUMBER,
    p_accounting_date       IN OUT NOCOPY DATE,
    p_period_name OUT NOCOPY VARCHAR2,
    p_sob_id OUT NOCOPY NUMBER
  ) IS

    /* Added by Ramananda for bug#4407165 */
    lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_recording_pkg.get_period_name';
    /* Bug 5243532. Added by Lakshmi Gopalsami
       Removed the cursors c_ou_sob_id and c_io_sob_id
       which is referring to hr_operating_units
       and org_organization_definitions respectively.
       Implemented the same using caching logic.
     */
     CURSOR c_period_dtl(cp_sob_id IN NUMBER, cp_accounting_date IN DATE) IS
      SELECT period_name, start_date, end_date, closing_status
      FROM gl_period_statuses
      WHERE application_id = jai_constants.gl_application_id
      AND set_of_books_id = cp_sob_id
      AND closing_status IN ('O','F')  -- added for bug#7010029
      AND cp_accounting_date BETWEEN start_date AND end_date
      ORDER BY period_year, period_num; -- added for bug#7010029

    r_period_dtl          c_period_dtl%ROWTYPE;
    ln_sob_id             NUMBER;
    ld_accounting_date    DATE;

    /* Bug 5243532. Added by Lakshmi Gopalsami
       Defined variable for implementing caching logic
     */
    l_func_curr_det jai_plsql_cache_pkg.func_curr_details;
  BEGIN

    -- CHK  we need to see whether the accounting date that is being used belong to a open period or not
    -- GL_PERIOD_STATUSES has CLOSING_STATUS column that tells whether the the period is closed or not for each APPLICATION

    -- Validation of whether the accounting date falls under an open period or not, if not, then we populate the first date of period
    /* Bug 5243532. Added by Lakshmi Gopalsami
       Removed the logic which is referring to hr_operating_units
       and org_organization_definitions for getting SOB and
       implemented the same using caching logic.
     */
    l_func_curr_det := jai_plsql_cache_pkg.return_sob_curr
                            (p_org_id  => p_organization_id );

    ln_sob_id := l_func_curr_det.ledger_id;

    OPEN c_period_dtl(ln_sob_id, p_accounting_date);
    FETCH c_period_dtl INTO r_period_dtl;
    CLOSE c_period_dtl;
    jai_cmn_utils_pkg.print_log('6395039.log', 'IN get_period_name : ln_sob_id '||ln_sob_id||' r_period_dtl.period_name '||r_period_dtl.period_name);

    IF r_period_dtl.closing_status IN ('O','F')  THEN
      p_sob_id        := ln_sob_id;
      p_period_name   := r_period_dtl.period_name;
    ELSE

      FOR period IN ( SELECT period_name, start_date, end_date, closing_status
                      FROM gl_period_statuses
                      WHERE application_id = jai_constants.gl_application_id
                      AND set_of_books_id = ln_sob_id
                      AND start_date > p_accounting_date
                      ORDER BY period_year, period_num
                    )
      LOOP
        IF period.closing_status IN('O','F') THEN
          p_sob_id          := ln_sob_id;
          p_period_name     := period.period_name;
          ld_accounting_date := period.start_date;
                                        jai_cmn_utils_pkg.print_log('6395039.log', 'IN get_period_name : in IF Block');
          exit;
        END IF;
      END LOOP;

      IF g_debug='Y' THEN
        fnd_file.put_line(fnd_file.log,'GL Period is closed for Accounting Date:'||to_char(p_accounting_date)
          ||'. Hence passing with Entries for '||to_char(ld_accounting_date)
        );
      END IF;

      p_accounting_date := ld_accounting_date;

    END IF;

   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      p_period_name := null;
      p_sob_id      := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_period_name;


  PROCEDURE get_accounting_dtls(
    p_source              IN  VARCHAR2,
    p_src_trx_type        IN  VARCHAR2,
    p_organization_type   IN  VARCHAR2,
    p_account_name OUT NOCOPY VARCHAR2,
    p_account_entry_type OUT NOCOPY VARCHAR2
  ) IS

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_recording_pkg.get_accounting_dtls';

  BEGIN

    -- following IF - ELSIF is valid for Organization Type OU w.r.t account_name and entry_type
    -- where as for Organization Type IO, it is valid only for entry_type
    IF p_source = jai_constants.source_receive THEN
      p_account_name         := jai_constants.recovery_interim;
      p_account_entry_type   := jai_constants.debit;

    ELSIF p_source = jai_constants.source_rtv THEN
      p_account_name         := jai_constants.liability_interim;
      p_account_entry_type   := jai_constants.credit;

    ELSIF p_source = jai_constants.source_ap THEN
      p_account_name         := jai_constants.recovery;
      p_account_entry_type   := jai_constants.debit;
    ELSIF p_source = jai_constants.source_ar THEN
      p_account_name         := jai_constants.liability;
      p_account_entry_type   := jai_constants.credit;

    ELSIF p_source = jai_constants.source_manual_entry THEN
      --lv_account_name := p_account_name;
      IF p_src_trx_type IN (jai_constants.recovery, jai_constants.recovery_interim) THEN
        p_account_entry_type    := jai_constants.debit;
      ELSIF p_src_trx_type IN (jai_constants.liability, jai_constants.liability_interim) THEN
        p_account_entry_type    := jai_constants.credit;
      END IF;

    ELSIF p_source IN (jai_constants.service_src_distribute_out, jai_constants.source_settle_out) THEN
      p_account_name           := jai_constants.liability;
      p_account_entry_type     := jai_constants.credit;

    ELSIF p_source IN (jai_constants.service_src_distribute_in, jai_constants.source_settle_in) THEN
      p_account_name           := jai_constants.recovery;
      p_account_entry_type     := jai_constants.debit;
    END IF;

    IF p_organization_type = jai_constants.orgn_type_io THEN
      p_account_name           := jai_constants.register_type_a;
    END IF;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      p_account_name       := null;
      p_account_entry_type := null;
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

  END get_accounting_dtls;

  ---------------------------- UPDATE_RECOVERED_AMOUNT ---------------------------
  PROCEDURE update_reference(
    p_source            IN  VARCHAR2,
    p_reference_id      IN  NUMBER,
    p_recovered_amount  IN  NUMBER,
    p_discounted_amount IN  NUMBER    DEFAULT NULL,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  ) IS

    lv_statement  VARCHAR2(2); -- := '1' File.Sql.35 by Brathod
  BEGIN
    lv_statement :='1' ;  -- File.Sql.35 by Brathod
    UPDATE jai_rgm_trx_refs
    SET  recovered_amount = nvl(recovered_amount,0) + nvl(p_recovered_amount, 0),
        discounted_amount = nvl(discounted_amount,0) + nvl(p_discounted_amount,0),
        -- recoverable_amount = recoverable_amount - nvl(p_amount, 0),
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id
    WHERE reference_id = p_reference_id;

    lv_statement := '2';
     p_process_flag := jai_constants.successful;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := 'jai_cmn_rgm_recording_pkg.update_reference (Stmt'||lv_statement||') Error Occured:'||SQLERRM;
  END update_reference;


  /* following procedure added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  PROCEDURE insert_vat_repository_entry(
    pn_repository_id             OUT NOCOPY NUMBER,
    pn_regime_id              IN      NUMBER,
    pv_tax_type               IN      VARCHAR2,
    pv_organization_type      IN      VARCHAR2,
    pn_organization_id        IN      NUMBER,
    pn_location_id            IN      NUMBER,
    pv_source                 IN      VARCHAR2,
    pv_source_trx_type        IN      VARCHAR2,
    pv_source_table_name      IN      VARCHAR2,
    pn_source_id              IN      NUMBER,
    pd_transaction_date       IN      DATE,
    pv_account_name           IN      VARCHAR2,
    pn_charge_account_id      IN      NUMBER,
    pn_balancing_account_id   IN      NUMBER,
    pn_credit_amount          IN  OUT NOCOPY    NUMBER,
    pn_debit_amount           IN  OUT NOCOPY    NUMBER,
    pn_assessable_value       IN      NUMBER,
    pn_tax_rate               IN      NUMBER,
    pn_reference_id           IN      NUMBER,
    pn_batch_id               IN      NUMBER,
    pn_inv_organization_id    IN      NUMBER,
    pv_invoice_no             IN      VARCHAR2,     /* this holds either generated VAT Invoice Number or Vendor Inovice Number */
    pd_invoice_date           IN      DATE,         /* this holds VAT Invoice Date or Vendor VAT Inovice Date */
    pv_called_from            IN      VARCHAR2,
    pv_process_flag              OUT NOCOPY VARCHAR2,
    pv_process_message           OUT NOCOPY VARCHAR2,
    --Added by Bo Li for Bug9305067 BEGIN
    -------------------------------------------------------------
    pv_trx_reference_context      IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference1             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference2             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference3             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference4             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference5             IN      VARCHAR2  DEFAULT NULL,
    ------------------------------------------------------------------
     --Added by Bo Li for Bug9305067 END
    pn_settlement_id          IN      NUMBER    DEFAULT NULL  --added for bug#9350172
  ) IS

    CURSOR c_primary_regno(cp_regime_id IN NUMBER, cp_orgn_type in varchar2,
          cp_orgn_id in number, cp_location_id in number,
    p_att_type_code jai_rgm_registrations.attribute_Type_code%TYPE) IS   --rchandan for bug#4428980
      SELECT attribute_value
      FROM   JAI_RGM_ORG_REGNS_V
      WHERE  regime_id           = cp_regime_id
      AND    organization_type   = cp_orgn_type
      AND    organization_id     = cp_orgn_id
      and    (cp_location_id is null or location_id = cp_location_id)
      AND    registration_type   = jai_constants.regn_type_others
      AND    attribute_type_code = p_att_type_code;

    lv_regime_code                JAI_RGM_DEFINITIONS.regime_code%TYPE;
    ld_transaction_date           DATE;
    lv_primary_regime_regno       jai_rgm_trx_records.regime_primary_regno%TYPE;

    lv_statement_id               VARCHAR2(3);
  BEGIN

    lv_statement_id := '1';
    OPEN c_regime_code(pn_regime_id);
    FETCH c_regime_code INTO lv_regime_code;
    CLOSE c_regime_code;

    lv_statement_id := '2';
    IF pd_transaction_date IS NOT NULL THEN
      ld_transaction_date := pd_transaction_date;
    ELSE
      ld_transaction_date := trunc(sysdate);
    END IF;

    lv_statement_id := '3';
    OPEN c_primary_regno(pn_regime_id, pv_organization_type, pn_organization_id, pn_location_id,'PRIMARY');  --rchandan for bug#4428980
    FETCH c_primary_regno INTO lv_primary_regime_regno;
    CLOSE c_primary_regno;

    lv_statement_id := '4';
    /* Rounding */
    pn_credit_amount  := round( pn_credit_amount, jai_constants.vat_rgm_rnd_factor);
    pn_debit_amount   := round( pn_debit_amount, jai_constants.vat_rgm_rnd_factor);

    lv_statement_id := '5';
    INSERT INTO jai_rgm_trx_records(
      repository_id, regime_code, tax_type, source,
      source_document_id, source_table_name, transaction_date, debit_amount, credit_amount,
      settled_amount, settled_flag, settlement_id, organization_type,
      organization_id, location_id, account_name, charge_account_id, balancing_account_id,
      reference_id, source_trx_type, tax_rate, assessable_value, batch_id,
      trx_currency, curr_conv_date, curr_conv_rate, trx_credit_amount, trx_debit_amount,
      creation_date, created_by, last_update_date, last_updated_by, last_update_login,
      trx_reference_context, trx_reference1, trx_reference2, trx_reference3, trx_reference4, trx_reference5
      , inv_organization_id, regime_primary_regno, invoice_no, invoice_date
    ) VALUES (
      jai_rgm_trx_records_s.nextval, lv_regime_code, pv_tax_type, pv_source,
      pn_source_id, pv_source_table_name, ld_transaction_date, pn_debit_amount, pn_credit_amount,
      null, null, pn_settlement_id, pv_organization_type, --added pn_settlement_id for bug#9350172
      pn_organization_id, pn_location_id, pv_account_name, pn_charge_account_id, pn_balancing_account_id,
      pn_reference_id, pv_source_trx_type, pn_tax_rate, pn_assessable_value, pn_batch_id,
      jai_constants.func_curr, null, null, pn_credit_amount, pn_debit_amount,
      sysdate, FND_GLOBAL.user_id, sysdate, FND_GLOBAL.user_id, fnd_global.login_id,
      pv_trx_reference_context, pv_trx_reference1, pv_trx_reference2, pv_trx_reference3, pv_trx_reference4, pv_trx_reference5
      , pn_inv_organization_id, lv_primary_regime_regno, pv_invoice_no, pd_invoice_date
    ) RETURNING repository_id INTO pn_repository_id;

    pv_process_flag := jai_constants.successful;
    lv_statement_id := '6';

  EXCEPTION
    WHEN OTHERS THEN
      pv_process_flag    := jai_constants.unexpected_error;
      pv_process_message := 'insert_vat_repository_entry Error(Stmt:'||lv_statement_id||') Occured:'||SQLERRM;
      --lv_codepath := jai_general_pkg.plot_codepath(-999, lv_codepath);
      Fnd_file.put_line( fnd_file.log, 'Error in insert_vat_repository_entry. Stmt:'||lv_statement_id);
  END insert_vat_repository_entry;


  /* following function added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  /* Two GL Entries are passed if both pn_credit_ccid and pn_debit_ccid are given as inputs to this procedure. Relevant amounts
      are taken while passing inserting into GL
     Incase a single entry needs to be passed, then pass the relevant ccid and amount
  */
  PROCEDURE do_vat_accounting(
    pn_regime_id                IN              NUMBER,
    pn_repository_id            IN              NUMBER,
    pv_organization_type        IN              VARCHAR2,
    pn_organization_id          IN              NUMBER,
    pd_accounting_date          IN              DATE,
    pd_transaction_date         IN              DATE,
    pn_credit_amount            IN              NUMBER,
    pn_debit_amount             IN              NUMBER,
    pn_credit_ccid              IN              NUMBER,
    pn_debit_ccid               IN              NUMBER,
    pv_called_from              IN              VARCHAR2,
    pv_process_flag                 OUT NOCOPY  VARCHAR2,
    pv_process_message              OUT NOCOPY  VARCHAR2,
    pv_tax_type                 IN              VARCHAR2    DEFAULT NULL,
    pv_source                   IN              VARCHAR2    DEFAULT NULL,
    pv_source_trx_type          IN              VARCHAR2    DEFAULT NULL,
    pv_source_table_name        IN              VARCHAR2    DEFAULT NULL,
    pn_source_id                IN              NUMBER      DEFAULT NULL,
    pv_reference_name           IN              VARCHAR2    DEFAULT NULL,
    pn_reference_id             IN              NUMBER      DEFAULT NULL
  ) IS

    r_repo_dtl                  c_repository_dtl%ROWTYPE;

    lv_regime_code              JAI_RGM_DEFINITIONS.regime_code%TYPE;
    lv_tax_type                 JAI_CMN_TAXES_ALL.tax_type%TYPE;
    ln_credit                   NUMBER;
    ln_debit                    NUMBER;
    ln_accounted_credit         NUMBER;
    ln_accounted_debit          NUMBER;
    ld_accounting_date          DATE;
    ld_transaction_date         DATE;

    lv_source                   JAI_RGM_TRX_RECORDS.source%TYPE;
    lv_source_trx_type          JAI_RGM_TRX_RECORDS.source_trx_type%TYPE;
    lv_source_table_name        JAI_RGM_TRX_RECORDS.source_table_name%TYPE;
    ln_source_id                JAI_RGM_TRX_RECORDS.source_document_id%TYPE;
    ln_repository_id            JAI_RGM_TRX_RECORDS.repository_id%TYPE;
    lv_repository_name          VARCHAR2(30);

    lv_statement_id             VARCHAR2(3);

  BEGIN

    lv_statement_id := '1';
    jai_cmn_utils_pkg.print_log('6395039.log','START '||lv_statement_id);

    IF pn_repository_id IS NULL THEN

      lv_statement_id := '2';
      OPEN c_regime_code(pn_regime_id);
      FETCH c_regime_code INTO lv_regime_code;
      CLOSE c_regime_code;
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id||' lv_regime_code '||lv_regime_code);

      lv_tax_type             := pv_tax_type;
      lv_source               := pv_source;
      lv_source_trx_type      := pv_source_trx_type;
      lv_source_table_name    := pv_source_table_name;
      ln_source_id            := pn_source_id;
      lv_repository_name      := pv_reference_name;
      ln_repository_id        := pn_reference_id;

    ELSE

      lv_statement_id := '3';
      OPEN c_repository_dtl(pn_repository_id);
      FETCH c_repository_dtl INTO r_repo_dtl;
      CLOSE c_repository_dtl;
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);

      lv_regime_code          := r_repo_dtl.regime_code;
      lv_tax_type             := r_repo_dtl.tax_type;
      lv_source               := r_repo_dtl.source;
      lv_source_trx_type      := r_repo_dtl.source_trx_type;
      lv_source_table_name    := r_repo_dtl.source_table_name;
      ln_source_id            := r_repo_dtl.source_document_id;
      lv_repository_name      := jai_constants.repository_name;
      ln_repository_id        := pn_repository_id;
    END IF;

    lv_statement_id := '4';
    jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
    IF pd_transaction_date IS NULL THEN
      ld_transaction_date := trunc(sysdate);
    ELSE
      ld_transaction_date := pd_transaction_date;
    END IF;

    lv_statement_id := '5';
    jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
    IF pd_accounting_date IS NULL THEN
      ld_accounting_date := ld_transaction_date;
    ELSE
      ld_accounting_date := pd_accounting_date;
    END IF;

    lv_statement_id := '6';
    jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
    IF pn_credit_ccid IS NOT NULL AND pn_credit_amount <> 0 THEN

      lv_statement_id := '7';
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
      ln_credit               := pn_credit_amount;
      ln_debit                := null;
      ln_accounted_credit     := pn_credit_amount;
      ln_accounted_debit      := null;

      lv_statement_id := '8';
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
      post_accounting(
        p_regime_code         => lv_regime_code,
        p_tax_type            => lv_tax_type,
        p_organization_type   => pv_organization_type,
        p_organization_id     => pn_organization_id,
        p_source              => lv_source,
        p_source_trx_type     => lv_source_trx_type,
        p_source_table_name   => lv_source_table_name,
        p_source_document_id  => ln_source_id,
        p_code_combination_id => pn_credit_ccid,
        p_entered_cr          => ln_credit,
        p_entered_dr          => ln_debit,
        p_accounted_cr        => ln_accounted_credit,
        p_accounted_dr        => ln_accounted_debit,
        p_accounting_date     => ld_accounting_date,
        p_transaction_date    => ld_transaction_date,
        p_calling_object      => pv_called_from,
        p_repository_name     => lv_repository_name,
        p_repository_id       => ln_repository_id,
        p_reference_name      => null,      --lv_reference_name,
        p_reference_id        => null,      --ln_reference_id,
        p_currency_code       => jai_constants.func_curr, --p_currency_code,
        p_curr_conv_date      => null,          --p_curr_conv_date,
        p_curr_conv_type      => null,       -- p_curr_conv_type,
        p_curr_conv_rate      => null   --p_curr_conv_rate
      );

    END IF;

    lv_statement_id := '9';
    jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
    IF pn_debit_ccid IS NOT NULL AND pn_debit_amount <> 0 THEN

      lv_statement_id := '10';
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
      ln_debit                := pn_debit_amount;
      ln_credit               := null;
      ln_accounted_debit      := pn_debit_amount;
      ln_accounted_credit     := null;

      lv_statement_id := '11';
      jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);
      post_accounting(
        p_regime_code         => lv_regime_code,
        p_tax_type            => lv_tax_type,
        p_organization_type   => pv_organization_type,
        p_organization_id     => pn_organization_id,
        p_source              => lv_source,
        p_source_trx_type     => lv_source_trx_type,
        p_source_table_name   => lv_source_table_name,
        p_source_document_id  => ln_source_id,
        p_code_combination_id => pn_debit_ccid,
        p_entered_cr          => ln_credit,
        p_entered_dr          => ln_debit,
        p_accounted_cr        => ln_accounted_credit,
        p_accounted_dr        => ln_accounted_debit,
        p_accounting_date     => ld_accounting_date,
        p_transaction_date    => ld_transaction_date,
        p_calling_object      => pv_called_from,
        p_repository_name     => lv_repository_name,
        p_repository_id       => ln_repository_id,
        p_reference_name      => null,      --lv_reference_name,
        p_reference_id        => null,      --ln_reference_id,
        p_currency_code       => jai_constants.func_curr, --p_currency_code,
        p_curr_conv_date      => null,          --p_curr_conv_date,
        p_curr_conv_type      => null,       -- p_curr_conv_type,
        p_curr_conv_rate      => null   --p_curr_conv_rate
      );

    END IF;

    pv_process_flag := jai_constants.successful;
    lv_statement_id := '15';
    jai_cmn_utils_pkg.print_log('6395039.log',lv_statement_id);

  EXCEPTION
    WHEN OTHERS THEN
      pv_process_flag    := jai_constants.unexpected_error;
      pv_process_message := 'doVatAccounting Error(Stmt:'||lv_statement_id||') Occured:'||SQLERRM;
      --lv_codepath := jai_general_pkg.plot_codepath(-999, lv_codepath);
      jai_cmn_utils_pkg.print_log('6395039.log', 'Error in doVatAccounting. Stmt:'||lv_statement_id);
      Fnd_file.put_line( fnd_file.log, 'Error in doVatAccounting. Stmt:'||lv_statement_id);

  END do_vat_accounting;

  /* following function added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  FUNCTION get_rgm_attribute_value(
    pv_regime_code          IN  VARCHAR2,
    pv_organization_type    IN  VARCHAR2,
    pn_organization_id      IN  NUMBER,
    pn_location_id          IN  NUMBER,
    pv_registration_type    IN  VARCHAR2,
    pv_attribute_type_code  IN  VARCHAR2,
    pv_attribute_code       IN  VARCHAR2
  ) RETURN VARCHAR2 IS

  /* Test Code
  select get_rgm_attribute_value('VAT', 'IO', 2832, 10023, 'OTHERS', 'PRIMARY', null) from dual;
  select jai_rgm_trx_recording_pkgget_rgm_attribute_value('VAT', 'IO', 2832, 10023, 'OTHERS', null, 'SAME_INVOICE_NO') from dual;

  pv_organization_type, pn_organization_id, pn_location_id, pv_registration_type, pv_attribute_type_code, pv_attribute_code
  )
  */

    CURSOR c_attribute_value (cp_regime_code IN varchar2,
        cp_orgn_type in varchar2, cp_orgn_id in number, cp_location_id in number,
        cp_registration_type in varchar2, cp_attribute_type_code in varchar2, cp_attribute_code in varchar2) IS
      SELECT attribute_value
      FROM   JAI_RGM_ORG_REGNS_V
      WHERE  regime_code         = cp_regime_code
      AND    organization_type   = cp_orgn_type
      AND    organization_id     = cp_orgn_id
      and    (cp_location_id is null or location_id = cp_location_id)
      AND    registration_type   = cp_registration_type
      AND    ( (cp_attribute_code IS NOT NULL AND attribute_code = cp_attribute_code)
              or (cp_attribute_code IS NULL AND attribute_type_code = cp_attribute_type_code)
             );

    lv_attribute_code     JAI_RGM_ORG_REGNS_V.attribute_code%type;
    lv_attribute_value    JAI_RGM_ORG_REGNS_V.attribute_value%type;

    ln_fetch_cnt          NUMBER;

  BEGIN

    IF pv_attribute_type_code = 'PRIMARY' THEN
      lv_attribute_code := NULL;
    ELSE
      lv_attribute_code := pv_attribute_code;
    END IF;

    OPEN c_attribute_value(pv_regime_code, pv_organization_type, pn_organization_id,
        pn_location_id, pv_registration_type, pv_attribute_type_code, lv_attribute_code);
    FETCH c_attribute_value INTO lv_attribute_value;
    ln_fetch_cnt := SQL%ROWCOUNT;
    CLOSE c_attribute_value;

    RETURN lv_attribute_value;

  END get_rgm_attribute_value;

  --added the procedure for Bug 8294236

  PROCEDURE exc_gain_loss_accounting(
       p_repository_id           IN      NUMBER,
       p_regime_id               IN      NUMBER,
       p_tax_type                IN      VARCHAR2,
       p_organization_type       IN      VARCHAR2,
       p_organization_id         IN      NUMBER,
       p_location_id             IN      NUMBER,
       p_source                  IN      VARCHAR2,
       p_source_trx_type         IN      VARCHAR2,
       p_source_table_name       IN      VARCHAR2,
       p_source_document_id      IN      NUMBER,
       p_transaction_date        IN      DATE,
       p_account_name            IN      VARCHAR2,
       p_charge_account_id       IN      NUMBER,
       p_balancing_account_id    IN      NUMBER,
       p_exc_gain_loss_amt       IN OUT NOCOPY NUMBER,
       p_reference_id            IN      NUMBER,
       p_called_from             IN      VARCHAR2,
       p_process_flag            OUT NOCOPY VARCHAR2,
       p_process_message         OUT NOCOPY VARCHAR2,
       p_accounting_date         IN      DATE      DEFAULT sysdate,
       p_balancing_orgn_type     IN      VARCHAR2  DEFAULT NULL,
       p_balancing_orgn_id       IN      NUMBER    DEFAULT NULL,
       p_balancing_location_id   IN      NUMBER    DEFAULT NULL,
       p_balancing_tax_type      IN      VARCHAR2  DEFAULT NULL,
       p_balancing_accnt_name    IN      VARCHAR2  DEFAULT NULL,
       p_currency_code           IN      VARCHAR2  DEFAULT jai_constants.func_curr,
       p_curr_conv_date          IN      VARCHAR2  DEFAULT NULL,
       p_curr_conv_type          IN      VARCHAR2  DEFAULT NULL,
       p_curr_conv_rate          IN      VARCHAR2  DEFAULT NULL
  ) IS

       CURSOR cur_fetch_ou(cp_organization_id NUMBER)
       IS
       SELECT org_information3
       FROM   hr_organization_information
       WHERE  upper(ORG_INFORMATION_CONTEXT) = 'ACCOUNTING INFORMATION'
       AND    organization_id                = cp_organization_id;

       CURSOR cur_get_exc_gain_acc_ar (p_org_id NUMBER)
       IS
       SELECT  code_combination_id_gain,
               code_combination_id_loss
       FROM    AR_SYSTEM_PARAMETERS_ALL
       WHERE   org_id = p_org_id;

       CURSOR cur_get_exc_gain_acc_ap (p_org_id NUMBER)
       IS
       SELECT  gain_code_combination_id,
               loss_code_combination_id
       FROM    AP_SYSTEM_PARAMETERS_ALL
       WHERE   org_id = p_org_id;

       ln_exc_gain_ccid            NUMBER;
       ln_exc_loss_ccid            NUMBER;
       ln_exc_ccid                 NUMBER;
       ln_debit_amt                NUMBER;
       ln_credit_amt               NUMBER;
       ld_transaction_date         DATE;
       ld_last_settlement_date     DATE;
       lv_regime_code              VARCHAR2(10);
       ln_org_id                   NUMBER;
       ln_bal_org_id               NUMBER;
       lv_codepath                 VARCHAR2(500) := '';
       lv_balancing_accnt_name     JAI_RGM_TRX_RECORDS.account_name%TYPE;
       lv_charge_entry_type        VARCHAR2(2);
       lv_balancing_entry_type     VARCHAR2(2);
       ln_charge_account_id        NUMBER;


     BEGIN
       FND_FILE.put_line( fnd_file.log, 'In jai_rgm_trx_recording_pkg.exc_gain_loss_accounting procedure');
       OPEN c_regime_code(p_regime_id);
       FETCH c_regime_code INTO lv_regime_code;
       CLOSE c_regime_code;

       OPEN  cur_fetch_ou(p_organization_id);
       FETCH cur_fetch_ou INTO ln_org_id;
       CLOSE cur_fetch_ou;

       OPEN  cur_fetch_ou(p_balancing_orgn_id);
       FETCH cur_fetch_ou INTO ln_bal_org_id;
       CLOSE cur_fetch_ou;

       IF lv_regime_code <> jai_constants.service_regime THEN
         lv_codepath := jai_general_pkg.plot_codepath(2, lv_codepath);
         p_process_flag    := jai_constants.expected_error;
         p_process_message := 'Transactions other than SERVICE regime are not supported';
         FND_FILE.put_line( fnd_file.log, p_process_message);
         RETURN;
       END IF;

       ld_last_settlement_date := jai_cmn_rgm_settlement_pkg.get_last_settlement_date(pn_regime_id => p_regime_id,
                                                                                  pn_org_id => p_organization_id,
                                                                                  pn_location_id => p_location_id);
       IF ld_last_settlement_date > p_transaction_date THEN
         ld_transaction_date := ld_last_settlement_date + 1;
         lv_codepath := jai_general_pkg.plot_codepath(2.2, lv_codepath);
       ELSIF ld_last_settlement_date IS NULL or ld_last_settlement_date <= p_transaction_date THEN
         ld_transaction_date := p_transaction_date;
         lv_codepath := jai_general_pkg.plot_codepath(2.3, lv_codepath);
       END IF;
       FND_FILE.put_line( fnd_file.log, 'p_source '|| p_source||' p_exc_gain_loss_amt '|| p_exc_gain_loss_amt);
       IF p_source = jai_constants.source_ar THEN

         lv_codepath := jai_general_pkg.plot_codepath(4, lv_codepath);

         lv_balancing_accnt_name := jai_constants.liability_interim;

         OPEN cur_get_exc_gain_acc_ar(ln_org_id);
         FETCH cur_get_exc_gain_acc_ar INTO ln_exc_gain_ccid, ln_exc_loss_ccid;
         CLOSE cur_get_exc_gain_acc_ar;
         IF p_exc_gain_loss_amt > 0 THEN
           ln_exc_ccid := nvl( ln_exc_gain_ccid, ln_exc_loss_ccid);
           lv_charge_entry_type    := jai_constants.debit;
           lv_balancing_entry_type := jai_constants.credit;

         ELSE
           ln_exc_ccid := nvl( ln_exc_loss_ccid, ln_exc_gain_ccid);
           lv_charge_entry_type    := jai_constants.credit;
           lv_balancing_entry_type := jai_constants.debit;
         END IF;
       ELSIF p_source = jai_constants.source_ap THEN

         lv_codepath := jai_general_pkg.plot_codepath(3, lv_codepath);

         lv_balancing_accnt_name := jai_constants.recovery_interim;


         OPEN cur_get_exc_gain_acc_ap(ln_org_id);
         FETCH cur_get_exc_gain_acc_ap INTO ln_exc_gain_ccid, ln_exc_loss_ccid;
         CLOSE cur_get_exc_gain_acc_ap;
         IF p_exc_gain_loss_amt > 0 THEN
           ln_exc_ccid := nvl( ln_exc_loss_ccid, ln_exc_gain_ccid);
           lv_charge_entry_type    := jai_constants.credit;
           lv_balancing_entry_type := jai_constants.debit;
         ELSE
           ln_exc_ccid := nvl( ln_exc_gain_ccid, ln_exc_loss_ccid);
           lv_charge_entry_type    := jai_constants.debit;
           lv_balancing_entry_type := jai_constants.credit;
         END IF;
       END IF;

       FND_FILE.put_line( fnd_file.log, 'ln_exc_ccid '|| ln_exc_ccid ||' lv_charge_entry_type '|| lv_charge_entry_type
                                      ||' lv_balancing_entry_type '|| lv_balancing_entry_type);

       IF ln_exc_ccid IS NULL THEN
         lv_codepath := jai_general_pkg.plot_codepath(21.10, lv_codepath);
         p_process_flag    := jai_constants.expected_error;
         p_process_message := 'Foreign Exchange Gain or Loss Account is not defined in '||p_source;
         FND_FILE.put_line( fnd_file.log, p_process_message);
         RETURN;
       END IF;

       IF lv_charge_entry_type = jai_constants.debit THEN
         ln_debit_amt          := abs(p_exc_gain_loss_amt);
         ln_credit_amt         := NULL;
       ELSE
         ln_debit_amt          := NULL;
         ln_credit_amt         := abs(p_exc_gain_loss_amt);
       END IF;

       FND_FILE.put_line( fnd_file.log,' ln_debit_amt '|| ln_debit_amt ||' ln_credit_amt '|| ln_credit_amt);

--       validate_negative_dr_cr(ln_debit_amt,ln_credit_amt );

       post_accounting(
         p_regime_code         => lv_regime_code,
         p_tax_type            => p_tax_type,
         p_organization_type   => p_organization_type,
         p_organization_id     => p_organization_id,
         p_source              => p_source,
         p_source_trx_type     => p_source_trx_type,
         p_source_table_name   => p_source_table_name,
         p_source_document_id  => p_source_document_id,
         p_code_combination_id => ln_exc_ccid,
         p_entered_cr          => ln_credit_amt,
         p_entered_dr          => ln_debit_amt,
         p_accounted_cr        => ln_credit_amt,
         p_accounted_dr        => ln_debit_amt,
         p_accounting_date     => p_accounting_date,
         p_transaction_date    => ld_transaction_date,
         p_calling_object      => p_called_from,
         p_repository_name     => jai_constants.repository_name,
         p_repository_id       => p_repository_id,
         p_reference_name      => jai_constants.rgm_trx_refs,
         p_reference_id        => p_reference_id,
         p_currency_code       => p_currency_code,
         p_curr_conv_date      => p_curr_conv_date,
         p_curr_conv_type      => p_curr_conv_type,
         p_curr_conv_rate      => p_curr_conv_rate
       );

       ln_charge_account_id := get_account(
                                   p_regime_id         => p_regime_id,
                                   p_organization_type => p_organization_type,
                                   p_organization_id   => p_organization_id,
                                   p_location_id       => p_location_id,
                                   p_tax_type          => p_tax_type,
                                   p_account_name      => lv_balancing_accnt_name
                                 );

       IF ln_charge_account_id IS NULL THEN
         lv_codepath := jai_general_pkg.plot_codepath(21.10, lv_codepath);
         p_process_flag    := jai_constants.expected_error;
         p_process_message := lv_balancing_accnt_name||' Account is not defined in '||p_source;
         FND_FILE.put_line( fnd_file.log, p_process_message);
         RETURN;
       END IF;

       IF lv_charge_entry_type = jai_constants.debit THEN
         ln_credit_amt          := abs(p_exc_gain_loss_amt);
         ln_debit_amt           := NULL;
       ELSE
         ln_credit_amt          := NULL;
         ln_debit_amt           := abs(p_exc_gain_loss_amt);
       END IF;
       FND_FILE.put_line( fnd_file.log,'1. ln_debit_amt '|| ln_debit_amt ||' ln_credit_amt '|| ln_credit_amt);
       post_accounting(
         p_regime_code         => lv_regime_code,
         p_tax_type            => p_tax_type,
         p_organization_type   => p_organization_type,
         p_organization_id     => p_organization_id,
         p_source              => p_source,
         p_source_trx_type     => p_source_trx_type,
         p_source_table_name   => p_source_table_name,
         p_source_document_id  => p_source_document_id,
         p_code_combination_id => ln_charge_account_id,
         p_entered_cr          => ln_credit_amt,
         p_entered_dr          => ln_debit_amt,
         p_accounted_cr        => ln_credit_amt,
         p_accounted_dr        => ln_debit_amt,
         p_accounting_date     => p_accounting_date,
         p_transaction_date    => ld_transaction_date,
         p_calling_object      => p_called_from,
         p_repository_name     => jai_constants.repository_name,
         p_repository_id       => p_repository_id,
         p_reference_name      => jai_constants.rgm_trx_refs,
         p_reference_id        => p_reference_id,
         p_currency_code       => p_currency_code,
         p_curr_conv_date      => p_curr_conv_date,
         p_curr_conv_type      => p_curr_conv_type,
         p_curr_conv_rate      => p_curr_conv_rate
       );

       p_process_flag    := jai_constants.successful;
       p_process_message := 'Successful';

       FND_FILE.put_line( fnd_file.log, 'End of jai_rgm_trx_recording_pkg.exc_gain_loss_accounting procedure');

     END exc_gain_loss_accounting;

END jai_cmn_rgm_recording_pkg;

/

--------------------------------------------------------
--  DDL for Package Body AP_INTEREST_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INTEREST_INVOICE_PKG" AS
/*$Header: apintinb.pls 120.30.12010000.10 2010/03/01 20:50:57 jaanders ship $*/

-- Declare Local procedures

PROCEDURE ap_int_inv_get_info(
   P_invoice_id                    IN           NUMBER,
   P_interest_amount               IN           NUMBER,
   P_exchange_rate                 IN           NUMBER,
   P_payment_num                   IN           NUMBER,
   P_currency_code                 IN           VARCHAR2,
   P_payment_dists_flag            IN           VARCHAR2,
   P_payment_mode                  IN           VARCHAR2,
   P_replace_flag                  IN           VARCHAR2,
   P_interest_accts_pay_ccid       OUT NOCOPY   NUMBER,
   P_asset_account_flag            OUT NOCOPY   VARCHAR2,
   P_pay_group_lookup_code         OUT NOCOPY   VARCHAR2,
   P_invoice_currency_code         OUT NOCOPY   VARCHAR2,
   P_payment_currency_code         OUT NOCOPY   VARCHAR2,
   P_immed_terms_id                OUT NOCOPY   NUMBER,
   P_terms_id                      OUT NOCOPY   NUMBER,
   P_terms_date                    OUT NOCOPY   DATE,
   P_payment_cross_rate            OUT NOCOPY   NUMBER,
   P_int_invoice_base_amount       OUT NOCOPY   NUMBER,
   P_int_payment_base_amount       OUT NOCOPY   NUMBER,
   P_External_Bank_Account_Id      OUT NOCOPY   NUMBER,
   P_legal_entity_id               OUT NOCOPY   NUMBER,
   P_vendor_id                     IN           NUMBER,
   P_vendor_site_id                IN           NUMBER,
   p_base_currency_code            OUT NOCOPY   VARCHAR2,
   p_type_1099                     OUT NOCOPY   VARCHAR2,
   p_income_tax_region             OUT NOCOPY   VARCHAR2,
   P_calling_sequence              IN           VARCHAR2,
   P_party_id                      OUT NOCOPY   NUMBER, --4746599
   P_party_site_id                 OUT NOCOPY   NUMBER, --4959918
   P_payment_priority              OUT NOCOPY   NUMBER);  -- Bug 5139574

PROCEDURE ap_int_inv_insert_ap_invoices(
   P_int_invoice_id                IN   NUMBER,
   P_check_date                    IN   DATE,
   P_vendor_id                     IN   NUMBER,
   P_vendor_site_id                IN   NUMBER,
   P_old_invoice_num               IN   VARCHAR2,
   P_int_invoice_num               IN   VARCHAR2,
   P_interest_amount               IN   NUMBER,
   P_interest_base_amount          IN   NUMBER,
   P_payment_method_code           IN   VARCHAR2, --4552701
   P_doc_sequence_value            IN   NUMBER,
   P_doc_sequence_id               IN   NUMBER,
   P_set_of_books_id               IN   NUMBER,
   P_last_updated_by               IN   NUMBER,
   P_interest_accts_pay_ccid       IN   NUMBER,
   P_pay_group_lookup_code         IN   VARCHAR2,
   P_invoice_currency_code         IN   VARCHAR2,
   P_payment_currency_code         IN   VARCHAR2,
   P_immed_terms_id                IN   NUMBER,
   P_terms_id                      IN   NUMBER,
   P_terms_date                    IN   DATE,
   P_payment_cross_rate            IN   NUMBER,
   P_exchange_rate                 IN   NUMBER,
   P_exchange_rate_type            IN   VARCHAR2,
   P_exchange_date                 IN   DATE,
   P_payment_dists_flag            IN   VARCHAR2,
   P_payment_mode                  IN   VARCHAR2,
   P_replace_flag                  IN   VARCHAR2,
   P_invoice_description           IN   VARCHAR2,
   P_org_id                        IN   NUMBER,
   P_last_update_login             IN   NUMBER,
   P_calling_sequence              IN   VARCHAR2,
   P_legal_entity_id               IN   NUMBER,
   P_party_id                      IN   NUMBER,  -- 4746599
   P_party_site_id                 IN   NUMBER/*,
   P_invoice_id                    IN   NUMBER*/
   -- commented p_invoice_id as part of bug 8557334
   ); --8249618


PROCEDURE ap_int_inv_insert_ap_inv_rel(
   P_invoice_id                    IN   NUMBER,
   P_int_invoice_id                IN   NUMBER,
   P_checkrun_name                 IN   VARCHAR2,
   P_last_updated_by               IN   NUMBER,
   P_payment_num                   IN   NUMBER,
   P_payment_dists_flag            IN   VARCHAR2,
   P_payment_mode                  IN   VARCHAR2,
   P_replace_flag                  IN   VARCHAR2,
   P_calling_sequence              IN   VARCHAR2);


PROCEDURE ap_int_inv_insert_ap_inv_line(
   P_int_invoice_id                IN      NUMBER,
   P_accounting_date               IN      DATE,
   P_old_invoice_num               IN      VARCHAR2,
   P_interest_amount               IN      NUMBER,
   P_interest_base_amount          IN      NUMBER,
   P_period_name                   IN      VARCHAR2,
   P_set_of_books_id               IN      NUMBER,
   P_last_updated_by               IN      NUMBER,
   P_last_update_login             IN      NUMBER,
   P_asset_account_flag            IN      VARCHAR2,
   P_Payment_cross_rate            IN      NUMBER,
   P_payment_mode                  IN      VARCHAR2,
   p_type_1099                     IN      VARCHAR2,
   p_income_tax_region             IN      VARCHAR2,
   p_org_id                        IN      NUMBER,
   p_calling_sequence              IN      VARCHAR2);


PROCEDURE ap_int_inv_insert_ap_inv_dist(
   P_int_invoice_id                IN   NUMBER,
   P_accounting_date               IN   DATE,
   P_vendor_id                     IN   NUMBER,
   P_old_invoice_num               IN   VARCHAR2,
   P_int_invoice_num               IN   VARCHAR2,
   P_interest_amount               IN   NUMBER,
   P_interest_base_amount          IN   NUMBER,
   P_period_name                   IN   VARCHAR2,
   P_set_of_books_id               IN   NUMBER,
   P_last_updated_by               IN   NUMBER,
   P_interest_accts_pay_ccid       IN   NUMBER,
   P_asset_account_flag            IN   VARCHAR2,
   P_Payment_cross_rate            IN   Number,
   P_exchange_rate                 IN   NUMBER,
   P_exchange_rate_type            IN   VARCHAR2,
   P_exchange_date                 IN   DATE,
   P_payment_dists_flag            IN   VARCHAR2,
   P_payment_mode                  IN   VARCHAR2,
   P_replace_flag                  IN   VARCHAR2,
   P_invoice_id                    IN   NUMBER,
   P_calling_sequence              IN   VARCHAR2,
   P_invoice_currency_code         IN   VARCHAR2,
   P_base_currency_code            IN   VARCHAR2,
   P_type_1099                     IN   VARCHAR2,
   P_income_tax_region             IN   VARCHAR2,
   P_org_id                        IN   NUMBER,
   P_last_update_login             IN   NUMBER,
   p_accounting_event_id           IN   NUMBER DEFAULT NULL);


PROCEDURE ap_int_inv_insert_ap_pay_sche(
   P_int_invoice_id                IN   NUMBER,
   P_check_date                    IN   DATE,
   P_interest_amount               IN   NUMBER,
   P_payment_method_code           IN   VARCHAR2, --4552701
   P_last_updated_by               IN   NUMBER,
   P_payment_cross_rate            IN   NUMBER,
   P_payment_priority              IN   NUMBER,
   P_payment_dists_flag            IN   VARCHAR2,
   P_payment_mode                  IN   VARCHAR2,
   P_replace_flag                  IN   VARCHAR2,
   P_calling_sequence              IN   VARCHAR2,
   P_External_Bank_Account_Id      IN   NUMBER,
   P_org_id                        IN   NUMBER,
   P_last_update_login             IN   NUMBER);



/*========================================================================
 * Main Procedure: Create Interest Invoice and pay it
 * Step 1. Call ap_int_inv_get_info to get some required fields
 * Step 2. Create interest ap_invoices line
 * Step 3. Create ap_invoice_relationships line
 * Step 4. Create ap_invoice_lines line
 * Step 5. Create ap_invoice_distributions line
 * Step 6. Create ap_payment_schedules line
 * Step 7. Create ap_invoice_payemnts line (Call ap_pay_invoice_pkg.ap_pay_
      insert_invoice_payments)

+=============================================================================+
| Step      | Description                                       | Work for*   |
+==========+====================================================+=============+
| Step 1:  | Call ap_int_inv_get_info to get some parameters    | PAY         |
|      |
+----------+----------------------------------------------------+-------------+
| Step 2:  | Call ap_int_inv_insert_ap_invoices                 | PAY         |
|      |
+----------+----------------------------------------------------+-------------+
| Step 3:  | Call ap_int_inv_insert_ap_inv_rel                  | PAY         |
|          |
+----------+----------------------------------------------------+-------------+
| Step 4:  | Call  ap_int_inv_insert_ap_inv_line                | PAY         |
|          |
+----------+----------------------------------------------------+-------------+
| Step 5:  | Call  ap_int_inv_insert_ap_inv_dist                | PAY         |
|          |
+----------+----------------------------------------------------+-------------+
| Step 6:  | Call ap_int_inv_insert_ap_pay_sche                 | PAY         |
|          |
+----------+----------------------------------------------------+-------------+
| Step 7:  | Call AP_PAY_INVOICE_PKG.ap_pay_insert_invoice      |             |
|          |     _payments : Insert AP_INVOICE_PAYMENTS         | PAY         |
+----------+----------------------------------------------------+-------------+

 *========================================================================*/


PROCEDURE ap_create_interest_invoice(
   P_invoice_id                  IN   NUMBER,
   P_int_invoice_id              IN   NUMBER,
   P_check_id                    IN   NUMBER,
   P_payment_num                 IN   NUMBER,
   P_int_invoice_payment_id      IN   NUMBER,
   P_old_invoice_payment_id      IN   NUMBER        Default NULL,
   P_period_name                 IN   VARCHAR2,
   P_invoice_type                IN   VARCHAR2      Default NULL,
   P_accounting_date             IN   DATE,
   P_amount                      IN   NUMBER,
   P_discount_taken              IN   NUMBER,
   P_discount_lost               IN   NUMBER        Default NULL,
   P_invoice_base_amount         IN   NUMBER        Default NULL,
   P_payment_base_amount         IN   NUMBER        Default NULL,
   P_vendor_id                   IN   NUMBER,
   P_vendor_site_id              IN   NUMBER        Default NULL,
   P_old_invoice_num             IN   VARCHAR2,
   P_int_invoice_num             IN   VARCHAR2,
   P_interest_amount             IN   NUMBER,
   P_payment_method_code         IN   VARCHAR2      Default NULL, --4552701
   P_doc_sequence_value          IN   NUMBER        Default NULL,
   P_doc_sequence_id             IN   NUMBER        Default NULL,
   P_checkrun_name               IN   VARCHAR2      Default NULL,
   P_payment_priority            IN   VARCHAR2      Default NULL,
   P_accrual_posted_flag         IN   VARCHAR2,
   P_cash_posted_flag            IN   VARCHAR2,
   P_posted_flag                 IN   VARCHAR2,
   P_set_of_books_id             IN   NUMBER,
   P_last_updated_by             IN   NUMBER,
   P_last_update_login           IN   NUMBER        Default NULL,
   P_currency_code               IN   VARCHAR2      Default NULL,
   P_base_currency_code          IN   VARCHAR2      Default NULL,
   P_exchange_rate               IN   NUMBER        Default NULL,
   P_exchange_rate_type          IN   VARCHAR2      Default NULL,
   P_exchange_date               IN   DATE          Default NULL,
   P_bank_account_id             IN   NUMBER        Default NULL,
   P_bank_account_num            IN   VARCHAR2      Default NULL,
   P_bank_account_type           IN   VARCHAR2      Default NULL,
   P_bank_num                    IN   VARCHAR2      Default NULL,
   P_future_pay_posted_flag      IN   VARCHAR2      Default NULL,
   P_exclusive_payment_flag      IN   VARCHAR2      Default NULL,
   P_accts_pay_ccid              IN   NUMBER        Default NULL,
   P_gain_ccid                   IN   NUMBER        Default NULL,
   P_loss_ccid                   IN   NUMBER        Default NULL,
   P_future_pay_ccid             IN   NUMBER        Default NULL,
   P_asset_ccid                  IN   NUMBER        Default NULL,
   P_payment_dists_flag          IN   VARCHAR2      Default NULL,
   P_payment_mode                IN   VARCHAR2      Default NULL,
   P_replace_flag                IN   VARCHAR2      Default NULL,
   P_invoice_description         IN   VARCHAR2      Default NULL,
   P_attribute1                  IN   VARCHAR2      Default NULL,
   P_attribute2                  IN   VARCHAR2      Default NULL,
   P_attribute3                  IN   VARCHAR2      Default NULL,
   P_attribute4                  IN   VARCHAR2      Default NULL,
   P_attribute5                  IN   VARCHAR2      Default NULL,
   P_attribute6                  IN   VARCHAR2      Default NULL,
   P_attribute7                  IN   VARCHAR2      Default NULL,
   P_attribute8                  IN   VARCHAR2      Default NULL,
   P_attribute9                  IN   VARCHAR2      Default NULL,
   P_attribute10                 IN   VARCHAR2      Default NULL,
   P_attribute11                 IN   VARCHAR2      Default NULL,
   P_attribute12                 IN   VARCHAR2      Default NULL,
   P_attribute13                 IN   VARCHAR2      Default NULL,
   P_attribute14                 IN   VARCHAR2      Default NULL,
   P_attribute15                 IN   VARCHAR2      Default NULL,
   P_attribute_category          IN   VARCHAR2      Default NULL,
   P_calling_sequence            IN   VARCHAR2      Default NULL,
   P_accounting_event_id         IN   NUMBER        Default NULL,
   P_org_id                      IN   NUMBER        Default NULL)
IS

   current_calling_sequence     VARCHAR2(2000);
   debug_info                   VARCHAR2(100);
   C_int_cc_id                  NUMBER;
   C_interest_accts_pay_ccid    NUMBER;
   C_asset_account_flag         VARCHAR2(1);
   C_pay_group_lookup_code      VARCHAR2(25);
   C_invoice_currency_code      VARCHAR2(15);
   C_payment_currency_code      VARCHAR2(15);
   C_immed_terms_id             NUMBER;
   C_terms_id                   NUMBER;
   C_terms_date                 DATE;
   C_payment_cross_rate         NUMBER;
   C_int_invoice_base_amount    NUMBER;
   C_int_payment_base_amount    NUMBER;
   C_External_Bank_Account_Id   NUMBER;
   C_interest_base_amount       NUMBER;
   C_Legal_entity_id            NUMBER;
   c_party_id                   number; --4746599
   c_party_site_id              Number; --4959918
   C_payment_priority           NUMBER; -- Bug 5139574
   l_base_currency_code         VARCHAR2(15);  /* Bug 4742671 */
   l_type_1099                  VARCHAR2(10);
   l_income_tax_region          VARCHAR2(150);

BEGIN

  current_calling_sequence :=
    'AP_INTEREST_INVOICE_PKG.ap_create_interest_invoice<-'||P_calling_sequence;
  --------------------------------------------
  -- Step 0:  Return if intertest amount is 0
  --------------------------------------------

  IF (P_interest_amount = 0) THEN
    RETURN;
  END IF;

  ---------------------------------------------------------------------------
  -- Step 1: Case for All : for both Pay and reverse:
  --  Call ap_int_inv_get_info to get some parameters
  ---------------------------------------------------------------------------
  AP_INTEREST_INVOICE_PKG.ap_int_inv_get_info(
          P_invoice_id,
          P_interest_amount,
          P_exchange_rate,
          P_payment_num,
          P_currency_code,
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          C_interest_accts_pay_ccid,
          C_asset_account_flag,
          C_pay_group_lookup_code,
          C_invoice_currency_code,
          C_payment_currency_code,
          C_immed_terms_id,
          C_terms_id,
          C_terms_date,
          C_payment_cross_rate,
          C_int_invoice_base_amount,
          C_int_payment_base_amount,
          C_External_Bank_Account_Id,
          C_Legal_entity_id,
          P_vendor_id,
          P_vendor_site_id,
          l_base_currency_code,
          l_type_1099,
          l_income_tax_region,
          Current_calling_sequence,
          c_party_id,  --4746599
          c_party_site_id,
          C_payment_priority); --4959918
  ---------------------------------------------------------------------------
  -- Step 2: Case for Pay : for Pay interest invoice only
  -- Call ap_int_inv_insert_ap_invoices: Insert AP_INVOICES
  ---------------------------------------------------------------------------

  AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_invoices(
          P_int_invoice_id,
          P_accounting_date,
          P_vendor_id,
          P_vendor_site_id,
          P_old_invoice_num,
          P_int_invoice_num,
          P_interest_amount,
          C_int_payment_base_amount,
          P_payment_method_code, --4552701
          P_doc_sequence_value,
          P_doc_sequence_id,
          P_set_of_books_id,
          P_last_updated_by,
          C_interest_accts_pay_ccid,
          C_pay_group_lookup_code,
          C_invoice_currency_code,
          C_payment_currency_code,
          C_immed_terms_id,
          C_terms_id,
          C_terms_date,
          C_payment_cross_rate,
          P_exchange_rate,
          P_exchange_rate_type,
          P_exchange_date,
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          P_invoice_description,
          P_org_id,
          P_last_update_login,
          Current_calling_sequence,
          C_Legal_entity_id,
          c_party_id, --4746599
          c_party_site_id/*,  -- 4959918
	  P_invoice_id*/
	  -- commented p_invoice_id as part of bug 8557334
	  );   --8249618
  ---------------------------------------------------------------------------
  -- Step 3: Case for Pay : for Pay interest invoice only
  -- Call ap_int_inv_insert_ap_inv_rel : Insert AP_INVOICE_RELATIONSHIPS
  ---------------------------------------------------------------------------

  AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_inv_rel(
          P_invoice_id,
          P_int_invoice_id,
          P_checkrun_name,
          P_last_updated_by,
          P_payment_num,
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          Current_calling_sequence);
  ---------------------------------------------------------------------------
  -- Step 4: Case for Pay : for Pay interest invoice only
  -- Call  ap_int_inv_insert_ap_inv_line: Insert AP_INVOICE_LINES
  ---------------------------------------------------------------------------

  AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_inv_line(
          P_int_invoice_id,
          P_accounting_date,
          P_old_invoice_num,
          P_interest_amount,
          C_int_payment_base_amount,
          P_period_name   ,
          P_set_of_books_id,
          P_last_updated_by  ,
          P_last_update_login ,
          C_asset_account_flag,
          C_Payment_cross_rate,
          P_payment_mode,
          l_type_1099,
          l_income_tax_region,
          P_org_id,
          P_calling_sequence);

  ---------------------------------------------------------------------------
  -- Step 5: Case for Pay : for Pay interest invoice only
  -- Call  ap_int_inv_insert_ap_inv_dist: Insert AP_INVOICE_DISTRIBUTIONS
  ---------------------------------------------------------------------------

  AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_inv_dist(
          P_int_invoice_id,
          P_accounting_date,
          P_vendor_id,
          P_old_invoice_num,
          P_int_invoice_num,
          P_interest_amount,
          C_int_payment_base_amount,
          P_period_name,
          P_set_of_books_id,
          P_last_updated_by,
          C_interest_accts_pay_ccid,
          C_asset_account_flag,
          C_payment_cross_rate,
          P_exchange_rate,
          P_exchange_rate_type,
          P_exchange_date,
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          P_invoice_id,
          current_calling_sequence,
          C_invoice_currency_code,
          l_base_currency_code,
          l_type_1099,
          l_income_tax_region,
          P_org_id,
          P_last_update_login,
          p_accounting_event_id);
  ---------------------------------------------------------------------------
  -- Step 6: Case for Pay : for Pay interest invoice only
  -- Call ap_int_inv_insert_ap_pay_sche : Insert AP_PAYMENT_SCHEDULES
  ---------------------------------------------------------------------------

  -- Bug 5139574
  if P_payment_priority is not null then
     C_payment_priority := P_payment_priority;
  end if;

  AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_pay_sche(
          P_int_invoice_id,
          P_accounting_date,
          P_interest_amount,
          P_payment_method_code, --4552701
          P_last_updated_by,
          C_payment_cross_rate,
          C_payment_priority,
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          Current_calling_sequence,
          C_External_Bank_Account_Id,
          P_org_id,
          P_last_update_login);

  ---------------------------------------------------------------------------
  -- Step 7: Case for ALL : for Pay and rev interest invoice
  -- Call AP_PAY_INVOICE_PKG.ap_pay_insert_invoice_payments :
  --                 Insert AP_INVOICE_PAYMENTS
  ---------------------------------------------------------------------------

  ap_pay_invoice_pkg.ap_pay_insert_invoice_payments(
          P_int_invoice_id,
          P_check_id,
          1,
          P_int_invoice_payment_id,
          P_old_invoice_payment_id,
          P_period_name,
          P_accounting_date,
          P_interest_amount,
          0,
          0,
          C_int_invoice_base_amount,
          C_int_payment_base_amount,
          'N',
          'N',
          'N',
          P_set_of_books_id,
          P_last_updated_by,
          P_last_update_login,
          sysdate,
          P_currency_code,
          P_base_currency_code,
          P_exchange_rate,
          P_exchange_rate_type,
          P_exchange_date,
          P_bank_account_id,
          P_bank_account_num,
          P_bank_account_type,
          P_bank_num,
          '',
          '',
          C_interest_accts_pay_ccid,
          P_gain_ccid,
          P_loss_ccid,
          P_future_pay_ccid,
          '',
          P_payment_dists_flag,
          P_payment_mode,
          P_replace_flag,
          P_attribute1,
          P_attribute2,
          P_attribute3,
          P_attribute4,
          P_attribute5,
          P_attribute6,
          P_attribute7,
          P_attribute8,
          P_attribute9,
          P_attribute10,
          P_attribute11,
          P_attribute12,
          P_attribute13,
          P_attribute14,
          P_attribute15,
          P_attribute_category,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          Current_calling_sequence,
          P_accounting_event_id,
          P_org_id);

END ap_create_interest_invoice;



/*==========================================================================
  This procedure is called to retrieve the various required information.
 *==========================================================================*/

PROCEDURE ap_int_inv_get_info(
          P_invoice_id                    IN           NUMBER,
          P_interest_amount               IN           NUMBER,
          P_exchange_rate                 IN           NUMBER,
          P_payment_num                   IN           NUMBER,
          P_currency_code                 IN           VARCHAR2,
          P_payment_dists_flag            IN           VARCHAR2,
          P_payment_mode                  IN           VARCHAR2,
          P_replace_flag                  IN           VARCHAR2,
          P_interest_accts_pay_ccid       OUT NOCOPY   NUMBER,
          P_asset_account_flag            OUT NOCOPY   VARCHAR2,
          P_pay_group_lookup_code         OUT NOCOPY   VARCHAR2,
          P_invoice_currency_code         OUT NOCOPY   VARCHAR2,
          P_payment_currency_code         OUT NOCOPY   VARCHAR2,
          P_immed_terms_id                OUT NOCOPY   NUMBER,
          P_terms_id                      OUT NOCOPY   NUMBER,
          P_terms_date                    OUT NOCOPY   DATE,
          P_payment_cross_rate            OUT NOCOPY   NUMBER,
          P_int_invoice_base_amount       OUT NOCOPY   NUMBER,
          P_int_payment_base_amount       OUT NOCOPY   NUMBER,
          P_External_Bank_Account_Id      OUT NOCOPY   NUMBER,
          P_Legal_entity_id               OUT NOCOPY   NUMBER,
          P_vendor_id                     IN           NUMBER,
          P_vendor_site_id                IN           NUMBER,
          p_base_currency_code            OUT NOCOPY   VARCHAR2,
          p_type_1099                     OUT NOCOPY   VARCHAR2,
          p_income_tax_region             OUT NOCOPY   VARCHAR2,
          P_calling_sequence              IN           VARCHAR2,
          P_party_id                      OUT NOCOPY   NUMBER, --4746599
          P_party_site_id                 OUT NOCOPY   NUMBER, -- 4959918
          P_payment_priority              OUT NOCOPY   NUMBER) -- 5139574
IS
  debug_info                 VARCHAR2(100);
  current_calling_sequence   VARCHAR2(2000);
  int_invoice_base_amount    NUMBER;
  int_payment_base_amount    NUMBER;

BEGIN

  current_calling_sequence := 'ap_int_inv_get_info<-'||P_calling_sequence;

  ----------------------------------------------------------------------------
  -- get some required ccid from ap_system_parameters and gl_code_combinations
  ----------------------------------------------------------------------------

  -- Interest Invoices project - Invoice Lines - 11ix
  -- Add the parameters
  --    P_vendor_id
  --    P_vendor_site_id
  --    P_base_currency_code
  --    P_type_1099
  --    P_income_tax_region
  -- Merge the existing SELECTs into two. One SELECT from ap_system_parameters.
  -- The other from ap_invoices. SELECT type_1099, income_tax_region,
  -- and base currency and pass them back to ap_create_interest_invoice_pkg.

  -- Remove expense interest account. Not need to select it

  debug_info := 'get some required ccid';

  SELECT  asp.interest_accts_pay_ccid,
          DECODE(glcc.account_type,'A','Y','N'),
          asp.base_currency_code,
          pv.type_1099,
          DECODE(pv.type_1099,
                 NULL, NULL,
                 DECODE(asp.combined_filing_flag,
                        'N', NULL,
                        DECODE(asp.income_tax_region_flag,
                               'Y', pvs.state,
                               asp.income_tax_region)))
    INTO  P_interest_accts_pay_ccid,
          P_asset_account_flag,
          P_base_currency_code,
          P_type_1099,
          P_income_tax_region
    FROM  ap_system_parameters asp,
          gl_code_combinations glcc,
          po_vendors pv,
          po_vendor_sites pvs
   WHERE  glcc.code_combination_id = asp.interest_code_combination_id
     AND  pv.vendor_id             = P_vendor_id
     AND  pvs.vendor_site_id       = P_vendor_site_id
     AND  NVL(pvs.org_id, -999)    = NVL(asp.org_id, -999);

  ----------------------------------------------------------------------------
  -- get some required information from ap_invoices
  ----------------------------------------------------------------------------

  debug_info := 'get some required field from ap_invoices';

  SELECT ai.pay_group_lookup_code,
         ai.invoice_currency_code,
         ai.payment_currency_code,
         ai.terms_id, ai.terms_date,
        /* bug 5000194 */
         (AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id /* External Bank Uptake */
                     ( ai.vendor_id,
                       ai.vendor_site_id,
                       ai.payment_function,
                       ai.org_id,
                       P_currency_code,
                       'Interest Invoice')),
         (P_interest_amount / ps.payment_cross_rate
                            * nvl(ai.exchange_rate,1)),
         (P_interest_amount / ps.payment_cross_rate
                            * nvl(P_exchange_rate,1)),
         nvl(ps.payment_cross_rate,1),
         ai.legal_entity_id,
         ai.party_id,
         ai.party_site_id,  -- bug 4959918
         ps.payment_priority -- Bug 5139574
    INTO P_pay_group_lookup_code,
         P_invoice_currency_code,
         P_payment_currency_code,
         P_terms_id,
         P_terms_date,
         P_External_Bank_Account_Id,
         int_invoice_base_amount,
         int_payment_base_amount,
         P_payment_cross_rate,
         P_Legal_Entity_ID,
         P_party_id,
         P_party_site_id,
         P_payment_priority
    FROM ap_invoices ai,
         ap_payment_schedules ps
   WHERE ai.invoice_id                  =  P_invoice_id
     AND ps.invoice_id                  =  P_invoice_id
     AND ps.payment_num                 =  P_payment_num;

  ----------------------------------------------------------------------------
  -- Round base_amount
  ----------------------------------------------------------------------------

  debug_info := 'Round the P_int_invoice_base_amount';
  P_int_invoice_base_amount := ap_utilities_pkg.ap_round_currency(
                 int_invoice_base_amount, P_currency_code);

  P_int_payment_base_amount := ap_utilities_pkg.ap_round_currency(
                 int_payment_base_amount, P_currency_code);

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
         ||', Payment_num = '||TO_CHAR(P_payment_num)
         ||', Interest Amount = '||TO_CHAR(P_interest_amount)
         ||', Exchange Rate = '||TO_CHAR(P_exchange_rate)
         ||', Currency_code = '||P_currency_code);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_get_info;


/*==========================================================================
  Insert AP_INVOICES
 *==========================================================================*/

PROCEDURE ap_int_inv_insert_ap_invoices(
          P_int_invoice_id               IN   NUMBER,
          P_check_date                   IN   DATE,
          P_vendor_id                    IN   NUMBER,
          P_vendor_site_id               IN   NUMBER,
          P_old_invoice_num              IN   VARCHAR2,
          P_int_invoice_num              IN   VARCHAR2,
          P_interest_amount              IN   NUMBER,
          P_interest_base_amount         IN   NUMBER,
          P_payment_method_code          IN   VARCHAR2, --4552701
          P_doc_sequence_value           IN   NUMBER,
          P_doc_sequence_id              IN   NUMBER,
          P_set_of_books_id              IN   NUMBER,
          P_last_updated_by              IN   NUMBER,
          P_interest_accts_pay_ccid      IN   NUMBER,
          P_pay_group_lookup_code        IN   VARCHAR2,
          P_invoice_currency_code        IN   VARCHAR2,
          P_payment_currency_code        IN   VARCHAR2,
          P_immed_terms_id               IN   NUMBER,
          P_terms_id                     IN   NUMBER,
          P_terms_date                   IN   DATE,
          P_payment_cross_rate           IN   NUMBER,
          P_exchange_rate                IN   NUMBER,
          P_exchange_rate_type           IN   VARCHAR2,
          P_exchange_date                IN   DATE,
          P_payment_dists_flag           IN   VARCHAR2,
          P_payment_mode                 IN   VARCHAR2,
          P_replace_flag                 IN   VARCHAR2,
          P_invoice_description          IN   VARCHAR2,
          P_org_id                       IN   NUMBER,
          P_last_update_login            IN   NUMBER,
          P_calling_sequence             IN   VARCHAR2,
          P_Legal_Entity_ID              IN   NUMBER,
          P_party_id                     IN   NUMBER,  --4746599
          P_party_site_id                IN   NUMBER/*,  --4959918
	  P_Invoice_id                   IN   NUMBER */
	  -- commented p_invoice_id as part of bug 8557334
	  ) --8249618
IS
  debug_info                   VARCHAR2(100);
  current_calling_sequence     VARCHAR2(2000);

  --Start of 8249618
     l_remit_party_id	AP_INVOICES_ALL.party_id%TYPE;	-- bug 8557334
     l_remit_to_supplier_name  AP_INVOICES.remit_to_supplier_name%TYPE;
     l_remit_to_supplier_id    AP_INVOICES.remit_to_supplier_id%TYPE;
     l_remit_to_supplier_site  AP_INVOICES.remit_to_supplier_site%TYPE;
     l_remit_to_supplier_site_id AP_INVOICES.remit_to_supplier_site_id%TYPE;
     l_relationship_id      AP_INVOICES.relationship_id%TYPE;
  --End of 8249618

BEGIN

  -- Interest Invoices project - Invoice Lines. - 11ix
  -- Add these parameters to signature and to INSERT statement
  --     P_org_id
  --     P_last_update_login
  -- Pass C_int_payment_base_amount for P_interest_base_amount
  -- instead of recalculating it.

  current_calling_sequence := 'ap_int_inv_insert_ap_invoices<-'||
                              P_calling_sequence;

  IF (P_payment_mode = 'PAY') THEN

    --Introduced below select statement for 8249618.
    -- modified code as per bug 8557334 starts

    /*SELECT remit_to_supplier_name, remit_to_supplier_id,
           remit_to_supplier_site, remit_to_supplier_site_id,
           relationship_id
    INTO l_remit_to_supplier_name, l_remit_to_supplier_id,
         l_remit_to_supplier_site, l_remit_to_supplier_site_id,
         l_relationship_id
    FROM AP_INVOICES_ALL
    WHERE INVOICE_ID = P_Invoice_id;*/

    IBY_EXT_PAYEE_RELSHIPS_PKG.default_Ext_Payee_Relationship (
	p_party_id				=> p_party_id,
	p_supplier_site_id			=> p_vendor_site_id,
	p_date				=> p_check_date,
	x_remit_party_id			=> l_remit_party_id,
	x_remit_supplier_site_id	=> l_remit_to_supplier_site_id,
	x_relationship_id			=> l_relationship_id
    );

    BEGIN
	    IF (l_relationship_id <> -1) THEN
		    SELECT vendor_name, vendor_id
		    INTO l_remit_to_supplier_name, l_remit_to_supplier_id
		    FROM ap_suppliers
		    WHERE party_id = l_remit_party_id;

		    SELECT vendor_site_code
		    into l_remit_to_supplier_site
		    from ap_supplier_sites_all
		    where vendor_site_id = l_remit_to_supplier_site_id;
	    ELSE
		    l_remit_to_supplier_name := null;
		    l_remit_to_supplier_id := null;
		    l_remit_to_supplier_site := null;
		    l_remit_to_supplier_site_id := null;
		    l_relationship_id := null;
	    END IF;
    EXCEPTION
	WHEN OTHERS THEN
		NULL;
    END;

    -- modified code as per bug 8557344 ends

    debug_info := 'Insert into ap_invoices';

    INSERT INTO AP_INVOICES(
          INVOICE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          VENDOR_ID,
          INVOICE_NUM,
          INVOICE_AMOUNT,
          BASE_AMOUNT,
          PAY_CURR_INVOICE_AMOUNT,
          VENDOR_SITE_ID,
          AMOUNT_PAID,
          DISCOUNT_AMOUNT_TAKEN,
          INVOICE_DATE,
          INVOICE_TYPE_LOOKUP_CODE,
          DESCRIPTION,
          AMOUNT_APPLICABLE_TO_DISCOUNT,
          TAX_AMOUNT,
          TERMS_ID,
          TERMS_DATE,
          PAY_GROUP_LOOKUP_CODE,
          SET_OF_BOOKS_ID,
          ACCTS_PAY_CODE_COMBINATION_ID,
          INVOICE_CURRENCY_CODE,
          PAYMENT_CURRENCY_CODE,
          PAYMENT_CROSS_RATE_TYPE,
          PAYMENT_CROSS_RATE_DATE,
          PAYMENT_STATUS_FLAG,
          POSTING_STATUS,
          CREATION_DATE,
          CREATED_BY,
          PAYMENT_CROSS_RATE,
          EXCHANGE_RATE,
          EXCHANGE_RATE_TYPE,
          EXCHANGE_DATE,
          SOURCE,
          PAYMENT_METHOD_CODE,  --4552701
          DOC_CATEGORY_CODE,
          DOC_SEQUENCE_VALUE,
          DOC_SEQUENCE_ID,
          GL_DATE,
          WFAPPROVAL_STATUS,
          APPROVAL_READY_FLAG,
          ORG_ID,
          LAST_UPDATE_LOGIN,
          Legal_Entity_ID,
          AUTO_TAX_CALC_FLAG,    -- BUG 3007085
          PARTY_ID,  --4746599
          PARTY_SITE_ID, --4959918
	  --Start 8249618
	  remit_to_supplier_name,
          remit_to_supplier_id,
          remit_to_supplier_site,
          remit_to_supplier_site_id,
          relationship_id
	   -- End 8249618
	   )
  VALUES (
          P_int_invoice_id,
          sysdate,
          P_last_updated_by,
          P_vendor_id,
          P_int_invoice_num,
          P_interest_amount / P_payment_cross_rate,
          P_interest_base_amount,
          P_interest_amount,
          P_vendor_site_id,
          P_interest_amount,
          0,
          P_check_date,
          'INTEREST',
          NVL(P_invoice_description, 'Interest : Overdue Invoice ' ||
                 P_old_invoice_num),
          0,
          0,
          nvl(P_immed_terms_id, P_terms_id),
          P_terms_date,
          P_pay_group_lookup_code,
          P_set_of_books_id,
          P_interest_accts_pay_ccid,
          P_invoice_currency_code,
          P_payment_currency_code,
          decode(P_payment_cross_rate, 1, NULL, 'EMU FIXED'),
          P_check_date,
          'Y',
          'N',
          sysdate,
          P_last_updated_by,
          nvl(P_payment_cross_rate,1),
          nvl(P_exchange_rate,1),
          P_exchange_rate_type,
          P_exchange_date,
          'QuickCheck',
          P_payment_method_code, --4552701
          'INT INV',
          P_doc_sequence_value,
          P_doc_sequence_id,
          P_check_date,
          'NOT REQUIRED',
          'Y',
          P_org_id,
          P_last_update_login,
          P_legal_entity_id,
          'N',                -- BUG 3007085
          P_party_id,  --4746599
          P_party_site_id, -- 4959918
	  --Start 8249618
	  l_remit_to_supplier_name,
          l_remit_to_supplier_id,
          l_remit_to_supplier_site,
          l_remit_to_supplier_site_id,
          l_relationship_id
	  --End 8249618
          );
	AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'I',
               p_key_value1 => P_Int_Invoice_id,
                p_calling_sequence => current_calling_sequence);

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
         ' Int_invoice_id = '||TO_CHAR(P_int_invoice_id)
         ||', Check_date = '||TO_CHAR(P_check_date)
         ||', Vendor_id = '||TO_CHAR(P_vendor_id)
         ||', Vendor_site_id = '||TO_CHAR(P_vendor_site_id)
         ||', Old_invoice_num = '||P_old_invoice_num
         ||', Int_invoice_num = '||P_int_invoice_num
         ||', Interest Amount = '||TO_CHAR(P_interest_amount)
         ||', Payment_method_code = '||
                         P_payment_method_code
         ||', Doc_sequence_value = '||TO_CHAR(P_doc_sequence_value)
         ||', Doc_sequence_id = '||TO_CHAR(P_doc_sequence_id)
         ||', Interest_accts_pay_ccid = '||
                         TO_CHAR(P_interest_accts_pay_ccid)
         ||', Pay_group_lookup_code = '||P_pay_group_lookup_code
         ||', Invoice_currency_code = '||P_invoice_currency_code
         ||', Payment_currency_code = '||P_payment_currency_code
         ||', Immed_terms_id = '||TO_CHAR(P_terms_id)
         ||', Terms_id = '||TO_CHAR(P_terms_id)
         ||', Payment_cross_rate = '||TO_CHAR(P_payment_cross_rate)
         ||', Exchange Rate = '||TO_CHAR(P_exchange_rate)
         ||', Exchange Rate Type = '||P_exchange_rate_type
         ||', Exchange Date = '||TO_CHAR(P_exchange_date)
         ||', Set 0f books id = '||TO_CHAR(P_set_of_books_id)
         ||', Last_updated_by = '||TO_CHAR(P_last_updated_by)
         ||', payment_dists_flag = '||P_payment_dists_flag
         ||', payment_mode = '||P_payment_mode
         ||', replace_flag = '||P_replace_flag);

        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_insert_ap_invoices;


/*==========================================================================
  Insert AP_INVOICE_RELATIONSHIPS
 *=====================================================================*/

PROCEDURE ap_int_inv_insert_ap_inv_rel(
          P_invoice_id           IN   NUMBER,
          P_int_invoice_id       IN   NUMBER,
          P_checkrun_name        IN   VARCHAR2,
          P_last_updated_by      IN   NUMBER,
          P_payment_num          IN   NUMBER,
          P_payment_dists_flag   IN   VARCHAR2,
          P_payment_mode         IN   VARCHAR2,
          P_replace_flag         IN   VARCHAR2,
          P_calling_sequence     IN   VARCHAR2) IS

  debug_info                   VARCHAR2(100);
  current_calling_sequence     VARCHAR2(2000);

BEGIN

  current_calling_sequence := 'ap_int_inv_insert_ap_inv_rel<-'||
                              P_calling_sequence;

  IF (P_payment_mode = 'PAY') THEN

    debug_info := 'Insert into ap_invoice_relations';

    INSERT INTO  AP_INVOICE_RELATIONSHIPS(
          ORIGINAL_INVOICE_ID,
          RELATED_INVOICE_ID,
          CREATED_BY,
          CREATION_DATE,
          ORIGINAL_PAYMENT_NUM,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          CHECKRUN_NAME)
   VALUES(
          P_invoice_id,
          P_int_invoice_id,
          P_last_updated_by,
          sysdate,
          P_payment_num,
          P_last_updated_by,
          sysdate,
          P_checkrun_name);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
         ||', Int_nvoice_id = '||TO_CHAR(P_int_invoice_id)
         ||', Payment_num = '||TO_CHAR(P_payment_num)
         ||', Checkrun_name = '||P_checkrun_name
         ||', Payment_num = '||TO_CHAR(P_payment_num)
         ||', Last_updated_by = '||TO_CHAR(P_last_updated_by)
         ||', payment_dists_flag = '||P_payment_dists_flag
         ||', payment_mode = '||P_payment_mode
         ||', replace_flag = '||P_replace_flag);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_insert_ap_inv_rel;


/*==========================================================================
  Insert AP_INVOICE_LINES
 *=====================================================================*/

PROCEDURE ap_int_inv_insert_ap_inv_line(
          P_int_invoice_id                IN      NUMBER,
          P_accounting_date               IN      DATE,
          P_old_invoice_num               IN      VARCHAR2,
          P_interest_amount               IN      NUMBER,
          P_interest_base_amount          IN      NUMBER,
          P_period_name                   IN      VARCHAR2,
          P_set_of_books_id               IN      NUMBER,
          P_last_updated_by               IN      NUMBER,
          P_last_update_login             IN      NUMBER,
          P_asset_account_flag            IN      VARCHAR2,
          P_Payment_cross_rate            IN      NUMBER,
          P_payment_mode                  IN      VARCHAR2,
          p_type_1099                     IN      VARCHAR2,
          p_income_tax_region             IN      VARCHAR2,
          p_org_id                        IN      NUMBER,
          p_calling_sequence              IN      VARCHAR2)
IS

  debug_info                      VARCHAR2(100);
  current_calling_sequence        VARCHAR2(2000);

BEGIN

  -- Interest Invoices project - Invoice Lines.
  -- This is a new procedure added with Invoice Lines to enter a single
  -- line for the created interest invoice regardless of the number of
  -- distributions created (which depends on the value of Prorate
  -- Across Overdue Invoice).

  current_calling_sequence := 'ap_int_inv_insert_ap_inv_line<-'||
                               P_calling_sequence;

  IF (P_payment_mode in ('PAY','PAYMENTBATCH')) THEN

    debug_info := 'Insert into ap_invoice_lines';

    INSERT INTO AP_INVOICE_LINES
       (INVOICE_ID,
        LINE_NUMBER,
        LINE_TYPE_LOOKUP_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        ACCOUNTING_DATE,
        PERIOD_NAME,
        AMOUNT,
        BASE_AMOUNT,
        ROUNDING_AMT,
        DESCRIPTION,
        TYPE_1099,
        INCOME_TAX_REGION,
        SET_OF_BOOKS_ID,
        ASSETS_TRACKING_FLAG,
        ASSET_BOOK_TYPE_CODE,
        ASSET_CATEGORY_ID,
        LINE_SOURCE,
        GENERATE_DISTS,
        MATCH_TYPE,
        PRORATE_ACROSS_ALL_ITEMS,
        DEFERRED_ACCTG_FLAG,
        WFAPPROVAL_STATUS,
        DISCARDED_FLAG,
        CANCELLED_FLAG,
        FINAL_MATCH_FLAG,
        REQUESTER_ID,
        /*GLOBAL_ATTRIBUTE_CATEGORY,
        GLOBAL_ATTRIBUTE1,
        GLOBAL_ATTRIBUTE2,
        GLOBAL_ATTRIBUTE3,
        GLOBAL_ATTRIBUTE4,
        GLOBAL_ATTRIBUTE5,
        GLOBAL_ATTRIBUTE6,
        GLOBAL_ATTRIBUTE7,
        GLOBAL_ATTRIBUTE8,
        GLOBAL_ATTRIBUTE9,
        GLOBAL_ATTRIBUTE10,
        GLOBAL_ATTRIBUTE11,
        GLOBAL_ATTRIBUTE12,
        GLOBAL_ATTRIBUTE13,
        GLOBAL_ATTRIBUTE14,
        GLOBAL_ATTRIBUTE15,
        GLOBAL_ATTRIBUTE16,
        GLOBAL_ATTRIBUTE17,
        GLOBAL_ATTRIBUTE18,
        GLOBAL_ATTRIBUTE19,
        GLOBAL_ATTRIBUTE20,*/
        ORG_ID)
   VALUES (
        P_int_invoice_id,             -- INVOICE_ID
        1,                            -- LINE_NUMBER
        'ITEM',                       -- LINE_TYPE_LOOKUP_CODE
        SYSDATE,                      -- LAST_UPDATE_DATE
        P_last_updated_by,            -- LAST_UPDATED_BY
        SYSDATE,                      -- CREATION_DATE
        P_last_updated_by,            -- CREATED_BY
        P_last_update_login,          -- LAST_UPDATE_LOGIN
        P_accounting_date,            -- ACCOUNTING_DATE
        P_period_name,                -- PERIOD_NAME
        P_interest_amount / nvl(P_payment_cross_rate,1),  -- AMOUNT
        P_interest_base_amount,       -- BASE_AMOUNT
        NULL,                         -- ROUNDING_AMT
        'Interest : Overdue Invoice ' || P_old_invoice_num,  -- DESCRIPTION
        p_type_1099,                  -- TYPE_1099
        p_income_tax_region,          -- INCOME_TAX_REGION
        P_set_of_books_id,            -- SET_OF_BOOKS_ID
        P_asset_account_flag,         -- ASSETS_TRACKING_FLAG
        NULL,                         -- ASSET_BOOK_TYPE_CODE
        NULL,                         -- ASSET_CATEGORY_ID
        'AUTO INVOICE CREATION',      -- LINE_SOURCE
        'D',                          -- GENERATE_DISTS
        'NOT_MATCHED',                -- MATCH_TYPE
        'N',                          -- PRORATE_ACROSS_ALL_ITEMS
        'N',                          -- DEFERRED_ACCTG_FLAG
        'NOT REQUIRED',               -- WFAPPROVAL_STATUS
        'N',                          -- DISCARDED_FLAG
        'N',                          -- CANCELLED_FLAG
        'N',                          -- FINAL_MATCH_FLAG
        NULL,                         -- REQUESTER_ID
        /*NULL,  -- Global Attributes NULLified for now.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,  */
        P_org_id);                    -- ORG_ID

   END IF;

EXCEPTION
 WHEN OTHERS THEN

  IF (SQLCODE <> -20001 ) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'Int_invoice_id = '             ||TO_CHAR(P_int_invoice_id)
                ||', Account_date = '           ||TO_CHAR(P_accounting_date)
                ||', Old_invoice_num = '        ||P_old_invoice_num
                ||', Asset_account_flag = '     ||P_asset_account_flag
                ||', Period name = '            ||P_period_name
                ||', Interest Amount = '        ||TO_CHAR(P_interest_amount)
                ||', Set 0f books id = '        ||TO_CHAR(P_set_of_books_id)
                ||', Last_updated_by = '        ||TO_CHAR(P_last_updated_by)
                ||', payment_mode = '           ||P_payment_mode
                ||', type_1099 = '              ||P_type_1099
                ||', income_tax_region = '      ||p_income_tax_region);

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
  END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_insert_ap_inv_line;


/*==========================================================================
  Insert AP_INVOICE_DISTRIBUTIONS
 *=====================================================================*/

PROCEDURE ap_int_inv_insert_ap_inv_dist(
          P_int_invoice_id                IN   NUMBER,
          P_accounting_date               IN   DATE,
          P_vendor_id                     IN   NUMBER,
          P_old_invoice_num               IN   VARCHAR2,
          P_int_invoice_num               IN   VARCHAR2,
          P_interest_amount               IN   NUMBER,
          P_interest_base_amount          IN   NUMBER,
          P_period_name                   IN   VARCHAR2,
          P_set_of_books_id               IN   NUMBER,
          P_last_updated_by               IN   NUMBER,
          P_interest_accts_pay_ccid       IN   NUMBER,
          P_asset_account_flag            IN   VARCHAR2,
          P_Payment_cross_rate            IN   NUMBER,
          P_exchange_rate                 IN   NUMBER,
          P_exchange_rate_type            IN   VARCHAR2,
          P_exchange_date                 IN   DATE,
          P_payment_dists_flag            IN   VARCHAR2,
          P_payment_mode                  IN   VARCHAR2,
          P_replace_flag                  IN   VARCHAR2,
          P_invoice_id                    IN   NUMBER,
          P_calling_sequence              IN   VARCHAR2,
          P_invoice_currency_code         IN   VARCHAR2,
          P_base_currency_code            IN   VARCHAR2,
          P_type_1099                     IN   VARCHAR2,
          P_income_tax_region             IN   VARCHAR2,
          P_org_id                        IN   NUMBER,
          P_last_update_login             IN   NUMBER,
          p_accounting_event_id           IN   NUMBER DEFAULT NULL)
IS

  debug_info                      VARCHAR2(100);
  current_calling_sequence        VARCHAR2(2000);
  l_invoice_distribution_id
      ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_proration_divisor             number;
  l_inv_distribution_line_number  number;
  l_distribution_total            number;
  l_distribution_base_total       number;
  l_account_from_ap_system CHAR(1) ;
  l_system_interest_account  ap_system_parameters_all.INTEREST_CODE_COMBINATION_ID%type;




  --Bug 4539462 DBI logging
  l_dbi_key_value_list        ap_dbi_pkg.r_dbi_key_value_arr;

  --  This cursor has the logic to prorate interest invoice  amount across
  --  'ITEM' lines of associated overdue invoice distribution lines.

  CURSOR c_prorate_int_inv IS
  SELECT ap_utilities_pkg.ap_round_currency
       (((amount * P_interest_amount)/l_proration_divisor),P_invoice_currency_code)
             prorated_dist_amount ,
       ap_utilities_pkg.ap_round_currency(
       nvl(P_exchange_rate,1) *
       ap_utilities_pkg.ap_round_currency
       (((amount * P_interest_amount)/l_proration_divisor),P_invoice_currency_code) -- amount rounded
       / nvl(P_payment_cross_rate, 1),
       P_base_currency_code) prorated_dist_base_amt,
         dist_code_combination_id,
         type_1099,
         income_tax_region
    FROM ap_invoice_distributions_all AID --bug 9328384
   WHERE AID.invoice_id            = P_invoice_id
     AND AID.line_type_lookup_code IN ('ITEM', 'IPV','ACCRUAL')
   ORDER BY AID.invoice_distribution_id;

  rec_prorate_int_inv            c_prorate_int_inv%rowtype;

BEGIN

  -- Interest Invoices project - Invoice Lines - 11ix
  -- Add the parameters
  --    P_invoice_currency_code
  --    P_base_currency_code
  --    P_type_1099
  --    P_income_tax_region
  --    P_org_id
  --    P_last_update_login
  -- Modify Cursor c_prorate_int_inv:
  --  1. Round interest amount depending on P_invoice_currency_code
  --  2. Round interest amount before using it in calculating the base
  --     currency interest amount.
  --  3. Add 'IPV' type along with 'ITEM' type distributions.
  -- Modify  SELECT   nvl(sum(AID.amount),0) to include 'IPV' type.
  -- Modify INSERT INTO AP_INVOICE_DISTRIBUTIONS:
  --   Add invoice_line_number, Remove exchange columns, Add a few
  --   other Columns.

  -- In 11ix we will always prorate distributions. We will not have
  -- the case of inserting one column any more.
  -- For that reason we will remove Prorate Across Distributions

  -- No Overlaying/flexbuilding needs to be done with SLA uptake,
  -- during the creation of the Interest Invoices. All the distributions
  -- that we create will have the same expense account as that of the
  -- parent invoice distributions.

  current_calling_sequence := 'ap_int_inv_insert_ap_inv_dist<-'||
                              P_calling_sequence;

  debug_info := 'Payment Mode Is: '||p_payment_mode;

  IF (P_payment_mode in ('PAY','PAYMENTBATCH')) THEN

    -- Find out NOCOPY if Interest Invoice needs to be prorated
    -- among ITEM distributions of overdue Invoice

    -- Get the divisor for proration from overdue invoice.
    -- If the proration divisor is zero then decoding value
    -- to 1 to avoid divide by zero error

      select PRORATE_INT_INV_ACROSS_DISTS  --start of code for bug 7112849
        into l_account_from_ap_system
	from ap_system_parameters_all
       where org_id = P_org_id ;  -- Bug#8763764

   -- 8453503 added NVL in the below condition

   IF ( NVL(l_account_from_ap_system,'N') <>'Y'  ) THEN

   -- check whether PRORATE_INT_INV_ACROSS_DISTS is Y or not if it is not Y use the system account defined on payables else use the invoice account and prorate
    select   INTEREST_CODE_COMBINATION_ID
      into l_system_interest_account
      from ap_system_parameters_all
     where org_id = P_org_id ;  -- Bug#8763764;

debug_info := 'inserting tax distribution using system defined account in ap_system_parameters';
   l_inv_distribution_line_number :=
           NVL(l_inv_distribution_line_number,0) + 1;
      INSERT INTO AP_INVOICE_DISTRIBUTIONS_ALL  --bug 9328384
             (INVOICE_ID,
              DIST_CODE_COMBINATION_ID,
              INVOICE_DISTRIBUTION_ID,
              INVOICE_LINE_NUMBER,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              ACCOUNTING_DATE,
              PERIOD_NAME,
              AMOUNT,
              BASE_AMOUNT,
              DESCRIPTION,
              TYPE_1099,
              INCOME_TAX_REGION,
              POSTED_FLAG,
              ASSETS_ADDITION_FLAG,
              SET_OF_BOOKS_ID,
              DISTRIBUTION_LINE_NUMBER,
              LINE_TYPE_LOOKUP_CODE,
              ACCRUAL_POSTED_FLAG,
              CASH_POSTED_FLAG,
              MATCH_STATUS_FLAG,
              ASSETS_TRACKING_FLAG,
              PA_ADDITION_FLAG,
              ACCTS_PAY_CODE_COMBINATION_ID,
              dist_match_type,
              distribution_class,
              amount_to_post,
              base_amount_to_post,
              posted_amount,
              posted_base_amount,
              upgrade_posted_amt,
              upgrade_base_posted_amt,
              rounding_amt,
              accounting_event_id,
              encumbered_flag,
              packet_id,
              reversal_flag,
              parent_reversal_id,
              cancellation_flag,
              asset_book_type_code,
              asset_category_id,
              last_update_login,
              /* TAX_CODE_OVERRIDE_FLAG,  Waiting for e-tax
              TAX_RECOVERY_RATE,
              TAX_RECOVERY_OVERRIDE_FLAG,
              TAX_RECOVERABLE_FLAG, */
              ORG_ID,
	      --Freight and Special Charges
	      RCV_CHARGE_ADDITION_FLAG)
        VALUES (
               P_int_invoice_id,
               l_system_interest_account ,
               ap_invoice_distributions_s.NEXTVAL,
               1,
               SYSDATE,
               P_last_updated_by,
               SYSDATE,
               P_last_updated_by,
               P_accounting_date,
               P_period_name,
               P_interest_amount / nvl(P_payment_cross_rate,1),  -- AMOUNT
	       P_interest_base_amount,       -- BASE_AMOUNT
               'Interest : Overdue Invoice ' || P_old_invoice_num,
               p_type_1099,                  -- TYPE_1099
               p_income_tax_region,          -- INCOME_TAX_REGION
               'N',
               'U',
               P_set_of_books_id,
               l_inv_distribution_line_number,
               'ITEM',
               'N',
               'N',
               'A',
               P_asset_account_flag,
               'E',
               P_interest_accts_pay_ccid,
               'PERMANENT',
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null, -- rounding amount
               p_accounting_event_id, -- aid.accounting_event_id /* Bug 4742671, switching null and 'N' */
               'N',
               null,
               null,
               null,
               null,
               null,
               null,
               P_last_update_login,
            /*   'N',
               '',
               'N',
               'N',   */
               p_org_id,
	       'N')
           returning invoice_distribution_id
           into l_invoice_distribution_id;  --end  of code for bug 7112849
 ELSE

    debug_info := 'Selecting distribution for proration';
    SELECT   nvl(sum(AID.amount),0)
      INTO   l_proration_divisor
      FROM   ap_invoice_distributions_all AID  --bug 9328384
     WHERE   AID.invoice_id            =  P_invoice_id
       AND   AID.line_type_lookup_code IN ('ITEM', 'IPV','ACCRUAL');

    debug_info := 'Opening the prorate cursor';
    OPEN c_prorate_int_inv;
      LOOP
        FETCH c_prorate_int_inv into rec_prorate_int_inv;

        EXIT WHEN c_prorate_int_inv%NOTFOUND;

        l_inv_distribution_line_number :=
           NVL(l_inv_distribution_line_number,0) + 1;
        l_distribution_total :=
           NVL(l_distribution_total,0) +
           rec_prorate_int_inv.prorated_dist_amount;
        l_distribution_base_total :=
           NVL(l_distribution_base_total,0) +
           rec_prorate_int_inv.prorated_dist_base_amt;


        debug_info := 'Inserting invoice ditsributions';
        INSERT INTO AP_INVOICE_DISTRIBUTIONS_ALL --bug 9328384
             (INVOICE_ID,
              DIST_CODE_COMBINATION_ID,
              INVOICE_DISTRIBUTION_ID,
              INVOICE_LINE_NUMBER,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              ACCOUNTING_DATE,
              PERIOD_NAME,
              AMOUNT,
              BASE_AMOUNT,
              DESCRIPTION,
              TYPE_1099,
              INCOME_TAX_REGION,
              POSTED_FLAG,
              ASSETS_ADDITION_FLAG,
              SET_OF_BOOKS_ID,
              DISTRIBUTION_LINE_NUMBER,
              LINE_TYPE_LOOKUP_CODE,
              ACCRUAL_POSTED_FLAG,
              CASH_POSTED_FLAG,
              MATCH_STATUS_FLAG,
              ASSETS_TRACKING_FLAG,
              PA_ADDITION_FLAG,
              ACCTS_PAY_CODE_COMBINATION_ID,
              dist_match_type,
              distribution_class,
              amount_to_post,
              base_amount_to_post,
              posted_amount,
              posted_base_amount,
              upgrade_posted_amt,
              upgrade_base_posted_amt,
              rounding_amt,
              accounting_event_id,
              encumbered_flag,
              packet_id,
              reversal_flag,
              parent_reversal_id,
              cancellation_flag,
              asset_book_type_code,
              asset_category_id,
              last_update_login,
              /* TAX_CODE_OVERRIDE_FLAG,  Waiting for e-tax
              TAX_RECOVERY_RATE,
              TAX_RECOVERY_OVERRIDE_FLAG,
              TAX_RECOVERABLE_FLAG, */
              ORG_ID,
	      --Freight and Special Charges
	      RCV_CHARGE_ADDITION_FLAG)
        VALUES (
               P_int_invoice_id,
               rec_prorate_int_inv.dist_code_combination_id,
               ap_invoice_distributions_s.NEXTVAL,
               1,
               SYSDATE,
               P_last_updated_by,
               SYSDATE,
               P_last_updated_by,
               P_accounting_date,
               P_period_name,
               rec_prorate_int_inv.prorated_dist_amount,
               rec_prorate_int_inv.prorated_dist_base_amt,
               'Interest : Overdue Invoice ' || P_old_invoice_num,
               rec_prorate_int_inv.type_1099,
               rec_prorate_int_inv.income_tax_region,
               'N',
               'U',
               P_set_of_books_id,
               l_inv_distribution_line_number,
               'ITEM',
               'N',
               'N',
               'A',
               P_asset_account_flag,
               'E',
               P_interest_accts_pay_ccid,
               'PERMANENT',
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null, -- rounding amount
               p_accounting_event_id, -- aid.accounting_event_id /* Bug 4742671, switching null and 'N' */
               'N',
               null,
               null,
               null,
               null,
               null,
               null,
               P_last_update_login,
            /*   'N',
               '',
               'N',
               'N',   */
               p_org_id,
	       'N')
           returning invoice_distribution_id
           into l_invoice_distribution_id;


           debug_info := 'Calling DBI Pkg';
	   --Bug 4539462 DBI logging
           AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => P_int_invoice_id,
               p_key_value2 => l_invoice_distribution_id,
                p_calling_sequence => current_calling_sequence);

      END LOOP;
    CLOSE c_prorate_int_inv;
      END IF ;

    --  Make sure that the total of amount and base amount in
    --  ap_invoice_distributions is equal to the invoice_amount
    --  and base_amount of ap_invoices table

    IF (p_interest_amount <> l_distribution_total OR
        p_interest_base_amount <> l_distribution_base_total ) THEN

      debug_info := 'Update AP_INVOICE_DISTRIBUTIONS_ALL (invoice_id = '||
                    p_int_invoice_id||')';


      -- Perf Bug 5059000
      UPDATE ap_invoice_distributions_all aid
             set amount = amount - l_distribution_total + p_interest_amount,
             base_amount = base_amount - l_distribution_base_total
                           + p_interest_base_amount
         WHERE aid.rowid =(
               select row_id from
                (
                  select rowid row_id,
                         rank() over(order by abs(aid3.amount) desc,
                         aid3.distribution_line_number desc) r
                  from ap_invoice_distributions_all aid3  --bug 9328384
                  WHERE aid3.invoice_id = p_int_invoice_id
                )
               where r=1 )
     RETURNING aid.invoice_distribution_id
     BULK COLLECT INTO l_dbi_key_value_list;  -- bug 4539462

/*   -- Perf Bug 5059000 - commented older UPDATE below
      UPDATE ap_invoice_distributions aid1
         SET amount = amount -
                        l_distribution_total +
                        p_interest_amount,
             base_amount = base_amount -
                        l_distribution_base_total +
                        p_interest_base_amount
       WHERE invoice_id = p_int_invoice_id
         AND distribution_line_number =
                 (SELECT MAX(distribution_line_number)
                    FROM ap_invoice_distributions aid2
                   WHERE aid2.invoice_id = p_int_invoice_id
                     AND ABS(aid2.amount) =
                         (SELECT MAX(ABS(aid3.amount))
                            FROM ap_invoice_distributions aid3
                           WHERE aid3.invoice_id = p_int_invoice_id))
	RETURNING aid1.invoice_distribution_id
        BULK COLLECT INTO l_dbi_key_value_list;  -- bug 4539462
*/
	--Bug 4539462 DBI logging
        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'U',
               p_key_value1 => p_int_invoice_id,
               p_key_value_list => l_dbi_key_value_list,
                p_calling_sequence => current_calling_sequence);

    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
         'Int_invoice_id = '||TO_CHAR(P_int_invoice_id)
         ||', Account_date = '||TO_CHAR(P_accounting_date)
         ||', Vendor_id = '||TO_CHAR(P_vendor_id)
         ||', Old_invoice_num = '||P_old_invoice_num
         ||', Int_invoice_num = '||P_int_invoice_num
         ||', Interest_accts_pay_ccid = '||
                     TO_CHAR(P_interest_accts_pay_ccid)
         ||', Asset_account_flag = '||P_asset_account_flag
         ||', Period name = '||P_period_name
         ||', Interest Amount = '||TO_CHAR(P_interest_amount)
         ||', Exchange Rate = '||TO_CHAR(P_exchange_rate)
         ||', Exchange Rate Type = '||P_exchange_rate_type
         ||', Exchange Date = '||TO_CHAR(P_exchange_date)
         ||', Set 0f books id = '||TO_CHAR(P_set_of_books_id)
         ||', Last_updated_by = '||TO_CHAR(P_last_updated_by)
         ||', payment_dists_flag = '||P_payment_dists_flag
         ||', payment_mode = '||P_payment_mode
         ||', replace_flag = '||P_replace_flag);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_insert_ap_inv_dist;


/*==========================================================================
 Insert AP_PAYMENT_SCHEDULES
 *==========================================================================*/

PROCEDURE ap_int_inv_insert_ap_pay_sche(
          P_int_invoice_id              IN   NUMBER,
          P_check_date                  IN   DATE,
          P_interest_amount             IN   NUMBER,
          P_payment_method_code         IN   VARCHAR2, --4552701
          P_last_updated_by             IN   NUMBER,
          P_payment_cross_rate          IN   NUMBER,
          P_payment_priority            IN   NUMBER,
          P_payment_dists_flag          IN   VARCHAR2,
          P_payment_mode                IN   VARCHAR2,
          P_replace_flag                IN   VARCHAR2,
          P_calling_sequence            IN   VARCHAR2,
          P_External_Bank_Account_Id    IN   NUMBER,
          P_org_id                      IN   NUMBER,
          P_last_update_login           IN   NUMBER) IS

  debug_info                   VARCHAR2(100);
  current_calling_sequence     VARCHAR2(2000);

  --Start of 8557334
     l_remit_to_supplier_name  AP_INVOICES.remit_to_supplier_name%TYPE;
     l_remit_to_supplier_id    AP_INVOICES.remit_to_supplier_id%TYPE;
     l_remit_to_supplier_site  AP_INVOICES.remit_to_supplier_site%TYPE;
     l_remit_to_supplier_site_id AP_INVOICES.remit_to_supplier_site_id%TYPE;
     l_relationship_id      AP_INVOICES.relationship_id%TYPE;
  --End of 8557334

BEGIN

  -- Interest Invoices project - Invoice Lines
  -- Add parameters to signature and INSERT statement
  --      P_org_id
  --      P_last_update_login

  current_calling_sequence := 'ap_int_inv_insert_ap_pay_sche<-'||
                              P_calling_sequence;

  IF (P_payment_mode = 'PAY') THEN
    debug_info := 'Insert into ap_payment_schedules';

    -- modified code as per bug 8557334 starts

    SELECT remit_to_supplier_name, remit_to_supplier_id,
           remit_to_supplier_site, remit_to_supplier_site_id,
           relationship_id
    INTO l_remit_to_supplier_name, l_remit_to_supplier_id,
         l_remit_to_supplier_site, l_remit_to_supplier_site_id,
         l_relationship_id
    FROM AP_INVOICES_ALL
    WHERE INVOICE_ID = P_int_invoice_id;


    INSERT INTO  AP_PAYMENT_SCHEDULES(
          INVOICE_ID,
          PAYMENT_NUM,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          DUE_DATE,
          DISCOUNT_DATE,
          GROSS_AMOUNT,
          INV_CURR_GROSS_AMOUNT,
          DISCOUNT_AMOUNT_AVAILABLE,
          AMOUNT_REMAINING,
          DISCOUNT_AMOUNT_REMAINING,
          PAYMENT_PRIORITY,
          PAYMENT_STATUS_FLAG,
          PAYMENT_CROSS_RATE,
          PAYMENT_METHOD_CODE, --4552701
          External_Bank_Account_Id,
          ORG_ID,
          LAST_UPDATE_LOGIN,
	  -- bug 8557334
	  REMIT_TO_SUPPLIER_NAME,
	  REMIT_TO_SUPPLIER_ID,
	  REMIT_TO_SUPPLIER_SITE,
	  REMIT_TO_SUPPLIER_SITE_ID,
	  RELATIONSHIP_ID
	  -- bug 8557334
	  )
    VALUES  (
          P_int_invoice_id,
          1,
          sysdate,
          P_last_updated_by,
          sysdate,
          P_last_updated_by,
          P_check_date,
          NULL,
          P_interest_amount,
          P_interest_amount /P_payment_cross_rate,
          0,
          0,
          0,
          P_payment_priority,
          'Y',
          P_payment_cross_rate,
          P_payment_method_code, --4552701
          P_External_Bank_Account_Id,
          P_org_id,
          P_last_update_login,
	  -- bug 8557334
	  l_remit_to_supplier_name,
	  l_remit_to_supplier_id,
          l_remit_to_supplier_site,
	  l_remit_to_supplier_site_id,
          l_relationship_id
	  -- bug 8557334
	  );

     -- modified code as per bug 8557334 ends

     --Bug 4539462 DBI logging
     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'I',
               p_key_value1 => P_int_invoice_id,
               p_key_value2 => 1,
                p_calling_sequence => current_calling_sequence);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN

      IF (SQLCODE <> -20001 ) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
         ' Int_invoice_id = '||TO_CHAR(P_int_invoice_id)
         ||', Check_date = '||TO_CHAR(P_check_date)
         ||', Interest Amount = '||TO_CHAR(P_interest_amount)
         ||', Payment_method_code = '||P_payment_method_code
         ||', Payment_cross_rate = '||TO_CHAR(P_payment_cross_rate)
         ||', Payment_priority = '||TO_CHAR(P_payment_priority)
         ||', Last_updated_by = '||TO_CHAR(P_last_updated_by)
         ||', payment_dists_flag = '||P_payment_dists_flag
         ||', payment_mode = '||P_payment_mode
         ||', replace_flag = '||P_replace_flag);

        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END ap_int_inv_insert_ap_pay_sche;


/*===================================================================
  Reverse Interest Invoice
  ===================================================================*/

PROCEDURE ap_reverse_Interest_Invoice (
          P_Check_Id            IN   NUMBER,
          P_Invoice_Payment_Id  IN   NUMBER,
          P_Check_Date          IN   DATE,
          P_Period_Name         IN   VARCHAR2,
          P_Last_Updated_By     IN   NUMBER,
          P_Calling_Sequence    IN   VARCHAR2,
          P_last_update_login   IN   NUMBER DEFAULT NULL )
IS

  l_Sys_Auto_Calc_Int_Flag    VARCHAR2(1);
  l_Vendor_Auto_Calc_Int_Flag VARCHAR2(1);
  l_Debug_Info                VARCHAR2(240);
  l_Curr_Calling_Sequence     VARCHAR2(2000);
  l_invoice_distribution_id   NUMBER;
  --Bug 4539462 DBI logging
  l_dbi_key_value_list1        ap_dbi_pkg.r_dbi_key_value_arr;
  l_dbi_key_value_list2        ap_dbi_pkg.r_dbi_key_value_arr;

  CURSOR C_Interest_Inv_Cur is
  SELECT  AID.invoice_id                               Invoice_Id,
          AID.dist_code_combination_id                 Dist_Code_Combination_Id,
          ap_invoice_distributions_s.NEXTVAL           Invoice_Distribution_Id,
          AID.invoice_line_number                      Invoice_Line_Number,
          AID.set_of_books_id                          Set_Of_Books_Id,
          0-AID.amount                                 Amount,
          AID.line_type_lookup_code                    Line_Type_Lookup_code,
          0-AID.base_amount                            Base_Amount,
          ALC.displayed_field || ' '||AID.description  Description,
          DECODE(GL.account_type, 'A', 'Y', 'N')       Assets_Tracking_Flag,
          AID.accts_pay_code_combination_id            Accts_Pay_Code_Combination_Id,
          AID.org_id                                   Org_Id
     FROM ap_invoice_distributions AID,
          gl_code_combinations GL,
          ap_invoice_payments AIP,
          ap_invoice_relationships AIR,
          ap_lookup_codes ALC
    WHERE AIR.related_invoice_id = AID.invoice_id
      AND GL.code_combination_id = AID.dist_code_combination_id
      AND AID.invoice_id         = AIP.invoice_id
      AND AIP.invoice_payment_id = P_Invoice_Payment_Id
      AND AIP.amount             > 0
      AND ALC.lookup_type        = 'NLS TRANSLATION'
      AND ALC.lookup_code        = 'VOID';

  Interest_Inv_Cur    C_Interest_Inv_Cur%rowtype;
  l_max_dist_line_num NUMBER;

BEGIN

  -- Interest Invoices project - Invoice Lines
  -- Add parameter  P_last_update_login
  -- Add the UPDATE statement UPDATE ap_invoice_lines AIL and MRC call
  --   to Reverse the line.
  -- Add SELECT max(aid.distribution_line_number)
  -- Add cursor C_Interest_Inv_Cur and define Interest_Inv_Cur of rowtype
  -- Use cursor to loop and insert an equivalent number of distributions
  --   to the original interest invoice in order to cancel them all. It used
  --   insert only one distribution which is wrong.
  -- Modify INSERT INTO AP_INVOICE_DISTRIBUTIONS


  l_Curr_Calling_Sequence := 'AP_INTEREST_INVOICE_PKG.AP_REVERSE_INTEREST_INVOICE<-'||
                             P_Calling_Sequence;

  -------------------------------------------------------------------
  l_Debug_Info := 'Get system and vendor PPA flags';

  SELECT APS.auto_calculate_interest_flag,
         PV.auto_calculate_interest_flag
    INTO l_Sys_Auto_Calc_Int_Flag,
         l_Vendor_Auto_Calc_Int_Flag
    FROM
         ap_product_setup aps,
         po_vendors PV,
         ap_checks AC
   WHERE AC.check_id  = P_Check_Id
     AND AC.vendor_id = PV.vendor_id;

  IF (l_Sys_Auto_Calc_Int_Flag = 'Y' AND
      l_Vendor_Auto_Calc_Int_Flag = 'Y') THEN

    -----------------------------------------------------------------
    l_Debug_Info := 'Zero related payment schedules';

    --Bug 4539462 DBI logging
    UPDATE ap_payment_schedules_all APS
       SET APS.last_updated_by = P_Last_Updated_By,
           APS.gross_amount = 0,
           APS.inv_curr_gross_amount = 0,
           APS.last_update_date = sysdate,
           APS.amount_remaining = 0
     WHERE  APS.invoice_id IN
      (SELECT AIR.related_invoice_id
         FROM ap_invoice_relationships AIR,
              ap_invoice_payments_all AIP
        WHERE AIP.invoice_payment_id = P_Invoice_Payment_Id
          AND AIR.related_invoice_id = AIP.invoice_id)
     RETURNING APS.invoice_id
     BULK COLLECT INTO l_dbi_key_value_list1;

    IF (SQL%NOTFOUND) THEN
      RETURN;
    END IF;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value_list => l_dbi_key_value_list1,
                p_calling_sequence => l_curr_calling_sequence);

    -----------------------------------------------------------------
    l_Debug_Info := 'Zero related invoice';

    --Bug 4539462 DBI logging
    --Bug 5056061 Modified the update to prevent FTS
    UPDATE ap_invoices_all AI
       SET AI.description='VOID '||AI.description,
           AI.invoice_amount = 0,
           AI.pay_curr_invoice_amount = 0,
           AI.amount_paid = 0,
           AI.invoice_distribution_total = 0
    WHERE  AI.invoice_id IN
      (SELECT /*+ UNNEST */ AIR.related_invoice_id
         FROM ap_invoice_relationships AIR,
              ap_invoice_payments_all AIP
        WHERE AIP.invoice_payment_id  = P_Invoice_Payment_Id
          AND AIR.related_invoice_id  = AIP.invoice_id)
     RETURNING invoice_id
     BULK COLLECT INTO l_dbi_key_value_list2;

     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value_list => l_dbi_key_value_list2,
                p_calling_sequence => l_curr_calling_sequence);



    -----------------------------------------------------------------
    -- Interest Invoices project - Invoice Lines

    l_Debug_Info := 'Zero related invoice line';
    --Bug 5056061 Modified the update to prevent FTS
    UPDATE ap_invoice_lines_all AIL
       SET AIL.description     = 'VOID '||AIL.description,
           AIL.amount          = 0,
           AIL.base_amount     = 0
     WHERE AIL.invoice_id IN
                (SELECT /*+ UNNEST */ AIR.related_invoice_id
                 FROM   ap_invoice_relationships AIR,
                        ap_invoice_payments_all AIP
                 WHERE  AIP.invoice_payment_id = P_Invoice_Payment_Id
                   AND  AIR.related_invoice_id = AIP.invoice_id);


    -----------------------------------------------------------------

    -- Interest Invoices project - Invoice Lines

    l_Debug_Info := 'Reverse related invoice distributions';

    SELECT max(aid.distribution_line_number)
      INTO   l_max_dist_line_num
      FROM   ap_invoice_distributions aid,
             gl_code_combinations gl,
             ap_invoice_payments aip,
             ap_invoice_relationships air,
             ap_lookup_codes alc
     WHERE   AIR.related_invoice_id = AID.invoice_id
       AND   GL.code_combination_id = AID.dist_code_combination_id
       AND   AID.invoice_id         = AIP.invoice_id
       AND   AIP.invoice_payment_id = P_Invoice_Payment_Id
       AND   AIP.amount             > 0
       AND   ALC.lookup_type        = 'NLS TRANSLATION'
       AND   ALC.lookup_code        = 'VOID';

    OPEN C_Interest_Inv_Cur;
      LOOP
        FETCH C_Interest_Inv_Cur INTO Interest_Inv_Cur;

        EXIT WHEN C_Interest_Inv_Cur%NOTFOUND;

        l_max_dist_line_num := l_max_dist_line_num + 1;

        INSERT INTO ap_invoice_distributions(
          INVOICE_ID,
          DIST_CODE_COMBINATION_ID,
          INVOICE_DISTRIBUTION_ID,
          INVOICE_LINE_NUMBER,
          LAST_UPDATED_BY,
          ASSETS_ADDITION_FLAG,
          ACCOUNTING_DATE,
          PERIOD_NAME,
          SET_OF_BOOKS_ID,
          AMOUNT,
          POSTED_FLAG,
          CASH_POSTED_FLAG,
          ACCRUAL_POSTED_FLAG,
          MATCH_STATUS_FLAG,
          DISTRIBUTION_LINE_NUMBER,
          LINE_TYPE_LOOKUP_CODE,
          BASE_AMOUNT,
          LAST_UPDATE_DATE,
          DESCRIPTION,
          PA_ADDITION_FLAG,
          CREATED_BY,
          CREATION_DATE,
          ASSETS_TRACKING_FLAG,
          ACCTS_PAY_CODE_COMBINATION_ID,
          ORG_ID,
          DIST_MATCH_TYPE,
          DISTRIBUTION_CLASS,
          AMOUNT_TO_POST,
          BASE_AMOUNT_TO_POST,
          POSTED_AMOUNT,
          POSTED_BASE_AMOUNT,
          UPGRADE_POSTED_AMT,
          UPGRADE_BASE_POSTED_AMT,
          ROUNDING_AMT,
          ACCOUNTING_EVENT_ID,
          ENCUMBERED_FLAG,
          PACKET_ID,
          REVERSAL_FLAG,
          PARENT_REVERSAL_ID,
          CANCELLATION_FLAG,
          ASSET_BOOK_TYPE_CODE,
          ASSET_CATEGORY_ID,
          LAST_UPDATE_LOGIN,
	  --Freight and Special Charges
	  RCV_CHARGE_ADDITION_FLAG)
    VALUES (
          Interest_Inv_Cur.invoice_id,
          Interest_Inv_Cur.dist_code_combination_id,
          Interest_Inv_Cur.invoice_distribution_id,
          Interest_Inv_Cur.invoice_line_number,
          P_Last_Updated_By,
          'U',
          P_Check_Date,
          P_Period_Name,
          Interest_Inv_Cur.set_of_books_id,
          0-Interest_Inv_Cur.amount,
          'N',
          'N',
          'N',
          'A',
          l_max_dist_line_num,
          Interest_Inv_Cur.line_type_lookup_code,
          0-Interest_Inv_Cur.base_amount,
          sysdate,
          Interest_Inv_Cur.description,
          'N',
          P_Last_Updated_By,
          sysdate,
          Interest_Inv_Cur.Assets_Tracking_Flag,
          Interest_Inv_Cur.accts_pay_code_combination_id,
          Interest_Inv_Cur.org_id,
          'MATCH_STATUS',
          'PERMANENT',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          'N',
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          P_last_update_login,
	  'N');

      END LOOP;
    CLOSE C_Interest_Inv_Cur;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_Curr_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
        ' CHECK_ID = '          || TO_CHAR(P_Check_Id)
      ||', INVOICE_PAYMENT_ID = '|| TO_CHAR(P_Invoice_Payment_Id)
      ||', CHECK_DATE = '        || TO_CHAR(P_Check_Date)
      ||', PERIOD_NAME = '       || P_Period_Name
      ||', LAST_UPDATED_BY = '   || TO_CHAR(P_Last_Updated_By));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_Debug_Info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END ap_reverse_Interest_Invoice;


/*======================================================================
 Public Function: Calculate Interest Invoice

 The function accept following parameter:

  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type          | Description           |
  +=====================================================================+
  | P_invoice_id        | No    | NUMBER        | invoice_id            |
  +---------------------------------------------------------------------+
  | P_sys_auto_calc_int |       |               | System Profile Otion  |
  | _flag               | No    | VARCHAR(1)    | 'Y'/'N'               |
  +---------------------------------------------------------------------+
  | P_auto_calculate    |       |               | From each record      |
  | _interest_flag      | No    | VARCHAR(1)    | 'Y'/'N'               |
  +---------------------------------------------------------------------+
  | P_check_date        | No    | DATE          | Account date          |
  +---------------------------------------------------------------------+
  | P_payment_num       | No    | NUMBER        | Payment number        |
  +---------------------------------------------------------------------+
  | P_amount_remaining  | Maybe | NUMBER        | Amount remaining      |
  +---------------------------------------------------------------------+
  | P_discount_taken    | Maybe | NUMBER        | Discount taken        |
  +---------------------------------------------------------------------+
  | P_disount_available | Maybe | NUMBER        | Discount Available    |
  +---------------------------------------------------------------------+
  | P_currency_code     | No    | VARCHAR2(15)  | Currency Code         |
  +---------------------------------------------------------------------+
  | P_payment_amount    | No    | NUMBER        | Payment Amount        |
  +---------------------------------------------------------------------+
  | P_calling_sequence  | Maybe | VARCHAR2(2000)| Calling sequence for  |
  |                     |       |               | debug usage           |
  +---------------------------------------------------------------------+


  There are 3 output parameter:
  +---------------------------------------------------------------------+
  | Variable            | NULL? | Type          | Description           |
  +=====================================================================+
  | P_interest_amount   | No    | NUMBER        | Interest Invoice Amount
  +---------------------------------------------------------------------+
  | P_interest_invoice  |       |               | New Int. Invoice Num  |
  | _num                | No    | VARCHAR2(50)  | = Inv_num||'-INT'||## |
  +---------------------------------------------------------------------+
  | P_due_date          | No    | DATE          | Due date for this PS  |
  +---------------------------------------------------------------------+


========================================================================*/

PROCEDURE ap_calculate_interest(
   P_invoice_id                     IN   NUMBER,
   P_sys_auto_calc_int_flag         IN   VARCHAR2,
   P_auto_calculate_interest_flag   IN   VARCHAR2,
   P_check_date                     IN   DATE,
   P_payment_num                    IN   NUMBER,
   P_amount_remaining               IN   NUMBER,
   P_discount_taken                 IN   NUMBER,
   P_discount_available             IN   NUMBER,
   P_currency_code                  IN   VARCHAR2,
   P_interest_amount                OUT NOCOPY   NUMBER,
   P_due_date                       OUT NOCOPY   DATE,
   P_interest_invoice_num           OUT NOCOPY   VARCHAR2,
   P_payment_amount                 IN   NUMBER,
   P_calling_sequence               IN   VARCHAR2) IS

  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(100);
  C_interest_tolerance_amount   NUMBER;
  C_int_inv_num_ext             NUMBER;
  C_int_inv_num_ext2            NUMBER;
  C_interest_amount             NUMBER;
  C_due_date                    DATE;

BEGIN

  current_calling_sequence := 'ap_calculate_interest<-'||P_calling_sequence;

  ---------------------------
  -- Get the tolerance amount
  ---------------------------

  debug_info := 'Get the interest tolerance amount';

  --4533605, modified this for moac

  SELECT nvl(interest_tolerance_amount,0)
    INTO C_interest_tolerance_amount
    FROM ap_system_parameters_all asp,
         ap_invoices_all ai
    WHERE ai.org_id = asp.org_id
    AND   ai.invoice_id = p_invoice_id;

  ----------------------------------------------------------
  -- Get the int_inv_num_ext - Use for interest_invoice_name
  ----------------------------------------------------------

  debug_info := 'Get the interest invoice NUM EXT';

  SELECT  count(*)
    INTO  C_int_inv_num_ext
    FROM  ap_invoice_relationships
   WHERE  original_invoice_id = P_invoice_id;

  -----------------------------------------------------------
  -- Get the int_inv_num_ext2 - Use for interest_invoice_name
  -----------------------------------------------------------

  debug_info := 'Get the interest invoice NUM EXT2';

  SELECT  count(*)
    INTO  C_int_inv_num_ext2
    FROM  ap_selected_invoices
-- CHANGES FOR BUG - 3293874 ** STARTS **
   --WHERE  original_invoice_id = P_invoice_id;
     WHERE  original_invoice_id = to_char(P_invoice_id);
-- CHANGES FOR BUG - 3293874 ** ENDS   **
  -------------------------------
  -- Set the interest invoice_num
  -------------------------------

  debug_info := 'Get the interest invoice Num';

  SELECT invoice_num|| '-INT' ||
           to_char(nvl(C_int_inv_num_ext, 0) + nvl(C_int_inv_num_ext2, 0) + 1)
    INTO P_interest_invoice_num
    FROM ap_invoices
   WHERE invoice_id = P_invoice_id;

  ---------------------------
  -- Get the due date
  ---------------------------

  debug_info := 'Get invoice_due_date';
  SELECT   due_date INTO C_due_date
    FROM   ap_payment_schedules
   WHERE   P_sys_auto_calc_int_flag       = 'Y'
     AND   P_auto_calculate_interest_flag = 'Y'
     AND   trunc(P_check_date)            > trunc(due_date)
     AND   payment_num                    = P_payment_num
     AND   invoice_id                     = P_invoice_id;

  -- Call custom calculate interest amount.  Make sure it returns both
  -- amount and due date and that it does appropriate rounding.
  -- If amount returned is null then continue with the following steps
  -- Else return;

  ---------------------------------
  --  Call custom interest package
  ---------------------------------

  debug_info := 'Calling custom interest package';

  -- bug 4995343.To Add a code hook to call Federal
  -- package for interest calculation passed extra parameters
  -- through the below package.

  AP_CUSTOM_INT_INV_PKG.ap_custom_calculate_interest(
              P_invoice_id ,
              P_sys_auto_calc_int_flag , --bug 4995343
              P_auto_calculate_interest_flag , --bug 4995343
              P_check_date ,
              P_payment_num ,
              P_amount_remaining , --bug 4995343
              P_discount_taken , --bug 4995343
              P_discount_available ,--bug 4995343
              P_currency_code  ,
              P_payment_amount ,
              C_interest_amount,
              C_due_date   );

  IF (C_interest_amount IS NULL) THEN

     -----------------------------------
     -- Calc the interest invoice amount
     -----------------------------------

     debug_info := 'Get the interest invoice_amount';

     SELECT (NVL(P_amount_remaining -
             least(nvl(P_discount_taken, 0), P_discount_available), 0) *
                    power(1 + (annual_interest_rate / (12 * 100)),
                          trunc((least(P_check_date, add_months(due_date, 12))
                                 -due_date) / 30)) *
                    (1 + ((annual_interest_rate / (360 * 100)) *
                          mod((least(P_check_date, add_months(due_date, 12))
                               -due_date), 30)))) -
             NVL(P_amount_remaining - least(nvl(P_discount_taken, 0),
                                          P_discount_available), 0)
       INTO  C_interest_amount
       FROM  ap_payment_schedules, ap_interest_periods
      WHERE  P_sys_auto_calc_int_flag = 'Y'
        AND  P_auto_calculate_interest_flag = 'Y'
        AND  TRUNC(P_check_date) > TRUNC(due_date)
        AND  payment_num = P_payment_num
        AND  invoice_id = P_invoice_id
        AND  TRUNC(due_date+1) BETWEEN TRUNC(start_date) AND TRUNC(end_date)
        AND  (NVL(P_amount_remaining -
             least(nvl(P_discount_taken, 0), P_discount_available), 0) *
                    power(1 + (annual_interest_rate / (12 * 100)),
                          trunc((least(P_check_date, add_months(due_date, 12))
                                 -due_date) / 30)) *
                    (1 + ((annual_interest_rate / (360 * 100)) *
                          mod((least(P_check_date, add_months(due_date, 12))
                               -due_date), 30)))) -
             nvl(P_amount_remaining - least(nvl(P_discount_taken, 0),
                                       P_discount_available), 0)
                           >= C_interest_tolerance_amount;

  ELSE

    -- custom interest package returned an interest amount
    -- so we skip ap's interest calculation.

    P_interest_amount := C_interest_amount;
    P_due_date := C_due_date;
    RETURN;
  END IF;

  --------------------------
  -- Round P_interest_amount
  --------------------------

  debug_info := 'Round the interest invoice_amount';

  P_interest_amount := ap_utilities_pkg.ap_round_currency(
                 C_interest_amount, P_currency_code);

  P_due_date := C_due_date;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (debug_info = 'Get the interest invoice_amount') OR
       (debug_info = 'Get invoice_due_date') then
      P_interest_amount := 0;
      P_due_date := C_due_date; /*Bug 5010005*/
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
      ||', Payment_num = '||TO_CHAR(P_payment_num)
      ||', Check_date = '||TO_CHAR(P_check_date)
      ||', sys_auto_calc_int_flag = '||P_sys_auto_calc_int_flag
      ||', auto_calculate_interest_flag = '||P_auto_calculate_interest_flag
      ||', Amount_remaining = '||TO_CHAR(P_amount_remaining)
      ||', Discount_taken = '||TO_CHAR(P_discount_taken)
      ||', Discount_available = '||TO_CHAR(P_discount_available)
      ||', Currency_code = '||P_currency_code);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(P_invoice_id)
       ||', Payment_num = '||TO_CHAR(P_payment_num)
       ||', Check_date = '||TO_CHAR(P_check_date)
       ||', sys_auto_calc_int_flag = '||P_sys_auto_calc_int_flag
       ||', auto_calculate_interest_flag = '||
                        P_auto_calculate_interest_flag
       ||', Amount_remaining = '||TO_CHAR(P_amount_remaining)
       ||', Discount_taken = '||TO_CHAR(P_discount_taken)
       ||', Discount_available = '||TO_CHAR(P_discount_available)
       ||', Currency_code = '||P_currency_code);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END ap_calculate_interest;

PROCEDURE ap_pay_insert_invoice_payments(
          P_reference_invoice_id          IN      NUMBER,
          P_reference_invoice_num         IN      VARCHAR2,
          P_reference_nls_int             IN      VARCHAR2,
          P_checkrun_name                 IN      VARCHAR2,
          P_vendor_id                     IN      NUMBER,
          P_vendor_site_id                IN      NUMBER,
          P_vendor_num                    IN      VARCHAR2,
          P_vendor_name                   IN      VARCHAR2,
          P_vendor_site_code              IN      VARCHAR2,
          P_address_line1                 IN      VARCHAR2,
          P_address_line2                 IN      VARCHAR2,
          P_address_line3                 IN      VARCHAR2,
          P_city                          IN      VARCHAR2,
          P_state                         IN      VARCHAR2,
          P_zip                           IN      VARCHAR2,
          P_voucher_num                   IN      VARCHAR2,
          P_ap_ccid                       IN      NUMBER,
          P_payment_priority              IN      NUMBER,
          P_province                      IN      VARCHAR2,
          P_country                       IN      VARCHAR2,
          P_withholding_status_lookup     IN      VARCHAR2,
          P_attention_ar_flag             IN      VARCHAR2,
          P_set_of_books_id               IN      NUMBER,
          P_invoice_exchange_rate         IN      NUMBER,
          P_payment_cross_rate            IN      NUMBER,
          P_customer_num                  IN      VARCHAR2,
          P_payment_num                   IN      NUMBER,
          P_last_update_date              IN      DATE,
          P_last_updated_by               IN      NUMBER,
          P_creation_date                 IN      DATE,
          P_created_by                    IN      NUMBER,
          P_invoice_date                  IN      DATE,
          P_invoice_amount                IN      NUMBER,
          P_amount_remaining              IN      NUMBER,
          P_amount_paid                   IN      NUMBER,
          P_discount_amount_taken         IN      NUMBER,
          P_due_date                      IN      DATE,
          P_invoice_description           IN      VARCHAR2,
          P_discount_amount_remaining     IN      NUMBER,
          P_payment_amount                IN      NUMBER,
          P_proposed_payment_amount       IN      NUMBER,
          P_discount_amount               IN      NUMBER,
          P_ok_to_pay_flag                IN      VARCHAR2,
          P_always_take_discount_flag     IN      VARCHAR2,
          P_amount_modified_flag          IN      VARCHAR2,
          P_original_invoice_id           IN      VARCHAR2,
          P_bank_account_num              IN      VARCHAR2,
          P_bank_account_type             IN      VARCHAR2,
          P_bank_num                      IN      VARCHAR2,
          P_original_payment_num          IN      NUMBER,
          P_sequence_num                  IN      NUMBER,
          P_pay_selected_check_id         IN      NUMBER,
          P_calling_sequence              IN      VARCHAR2,
          P_org_id                        IN      NUMBER DEFAULT NULL,
          P_last_update_login             IN      NUMBER DEFAULT NULL) IS

  current_calling_sequence        VARCHAR2(2000);
  debug_info                      VARCHAR2(100);
  C_int_num1                      number:=0;
  C_int_num2                      number:=0;
  C_invoice_num                   varchar2(50);
  C_invoice_id                    number;
BEGIN

  -- Interest Invoices project - Invoice Lines
  -- Add parameters to signature and INSERT Statement
  --    P_org_id
  --    P_last_update_login
  -- Remove SELECT org_id ..
  -- Remove SELECT NEXTVAL from Dual and SELECT NEXTVAL directly
  -- at INSERT time in the INSERT Statement.

  current_calling_sequence :=
    'AP_INTEREST_INVOICE_PKG.ap_pay_interest_invoice_payments<-'
         || P_calling_sequence;

  -- populating values later used to create interest invoice.

  debug_info := 'Count from ap_selected_invoices for P_reference_invoice_id';

  BEGIN
    SELECT COUNT(*)
      INTO C_int_num1
      FROM ap_selected_invoices
-- CHANGES FOR BUG - 3293874 ** STARTS **
     --WHERE original_invoice_id = P_reference_invoice_id;
     WHERE original_invoice_id = to_char(P_reference_invoice_id);
-- CHANGES FOR BUG - 3293874 ** ENDS   **

  EXCEPTION
   WHEN NO_DATA_FOUND then null;
  END;

  debug_info :=
    'Count from ap_invoice_relationships for P_reference_invoice_id';

  BEGIN
    SELECT count(*)
      INTO C_int_num2
      FROM ap_invoice_relationships
     WHERE original_invoice_id = P_reference_invoice_id;

  EXCEPTION
    WHEN No_Data_Found THEN NULL;
  END;

  -- Insert interest invoice here.
  -- calculate invoice num info

  debug_info := 'Calculating invoice num ';

  C_invoice_num := substrb(P_reference_invoice_num,
                   1,(50 - LENGTHB('-' || P_reference_nls_int ||
                   to_char(nvl(c_int_num1,0) +
                   nvl(C_int_num2,0)+1)))) || '-' ||
                   P_reference_nls_int || to_char(nvl(C_int_num1,0) +
                   nvl(C_int_num2,0)+1);

  debug_info := 'Insert ap_selected_invoices';

  INSERT INTO AP_SELECTED_INVOICES (
                checkrun_name,
                invoice_id,
                vendor_id,
                vendor_site_id,
                vendor_num,
                vendor_name,
                vendor_site_code,
                address_line1,
                address_line2,
                address_line3,
                city,
                state,
                zip,
                invoice_num,
                voucher_num,
                ap_ccid,
                payment_priority,
                province,country,
                withholding_status_lookup_code,
                attention_ar_flag,
                set_of_books_id,
                invoice_exchange_rate,
                payment_cross_rate,
                customer_num,
                payment_num,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                invoice_date,
                invoice_amount,
                amount_remaining,
                amount_paid,
                discount_amount_taken,
                due_date,
                invoice_description,
                discount_amount_remaining,
                payment_amount,
                proposed_payment_amount,
                discount_amount,
                ok_to_pay_flag,
                always_take_discount_flag,
                amount_modified_flag,
                original_invoice_id,
                bank_account_num,
                bank_account_type,
                bank_num,
                original_payment_num,
                sequence_num,
                pay_selected_check_id,
                org_id,
                last_update_login)
        VALUES (
                P_checkrun_name,
                ap_invoices_s.NEXTVAL,
                P_vendor_id,
                P_vendor_site_id,
                P_vendor_num,
                P_vendor_name,
                P_vendor_site_code,
                P_address_line1,
                P_address_line2,
                P_address_line3,
                P_city,
                P_state,
                P_zip,
                C_invoice_num,
                P_voucher_num,
                P_ap_ccid,
                P_payment_priority,
                P_province,
                P_country,
                P_withholding_status_lookup,
                P_attention_ar_flag,
                P_set_of_books_id,
                P_invoice_exchange_rate,
                P_payment_cross_rate,
                P_customer_num,
                P_payment_num,
                P_last_update_date,
                P_last_updated_by,
                P_creation_date,
                P_created_by,
                P_invoice_date,
                P_invoice_amount,
                P_amount_remaining,
                P_amount_paid,
                P_discount_amount_taken,
                P_due_date,
                P_invoice_description,
                P_discount_amount_remaining,
                P_payment_amount,
                P_proposed_payment_amount,
                P_discount_amount,
                P_ok_to_pay_flag,
                P_always_take_discount_flag,
                P_amount_modified_flag,
                P_original_invoice_id,
                P_bank_account_num,
                P_bank_account_type,
                P_bank_num,
                P_original_payment_num,
                P_sequence_num,
                P_pay_selected_check_id,
                P_org_id,
                P_last_update_login);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001 ) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_id = '||TO_CHAR(C_invoice_id)
                ||', Checkrun_name = '||P_Checkrun_name
                ||', Vendor_id = '||TO_CHAR(P_Vendor_id)
                ||', Vendor_site_id = '||TO_CHAR(P_Vendor_site_id)
                ||', Vendor_num = '||P_Vendor_num
                ||', Vendor_name = '||P_Vendor_name
                ||', Vendor_site_code = '||P_Vendor_site_code
                ||', Payment_num = '||TO_CHAR(P_payment_num)
                ||', Invoice_num = '||C_Invoice_num
                ||', Voucher_num = '||P_Voucher_num
                ||', Customer_num = '||P_Customer_num
                ||', Invoice_description = '||P_Invoice_description
                ||', sequence_num = '||P_sequence_num);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END ap_pay_insert_invoice_payments;

/* -----------------------------------------------------------------------
   This procedure is called from appbii.lpc (CONFIRM Program). This program
   is called to prorate Interest Invoice Distributions. Please see HLD/DLD
   for further details
   ----------------------------------------------------------------------- */

PROCEDURE ap_create_batch_interest_dists(
          P_checkrun_name                  IN VARCHAR2,
          P_base_currency_code             IN VARCHAR2,
          P_interest_accts_pay_ccid        IN NUMBER,
          P_last_updated_by                IN NUMBER,
          P_period_name                    IN VARCHAR2,
          P_asset_account_flag             IN VARCHAR2,
          P_calling_sequence               IN VARCHAR2,
          p_checkrun_id                    in number,
          p_completed_pmts_group_id        in number,
          p_org_id                         in number) IS

  CURSOR c_select_interest_invoices is
  SELECT new.invoice_id            P_int_invoice_id,
         new.due_date              P_accounting_date,
         pv.vendor_id              P_vendor_id,
         orig.invoice_num          P_old_invoice_num,
         new.invoice_num           P_int_invoice_num,
         new.payment_amount        P_interest_amount,
         decode(orig.invoice_currency_code, P_base_currency_code, NULL,
           decode(base.minimum_accountable_unit, null,
                  round(new.payment_amount / orig.payment_cross_rate *
			--bug 8899917 use new.payment_exchange_rate
                        nvl(new.payment_exchange_rate,1), base.precision),
                  round( ((new.payment_amount / orig.payment_cross_rate *
                        nvl(new.payment_exchange_rate,1)) /
                        base.minimum_accountable_unit) *
                        base.minimum_accountable_unit ) ) )
                                   P_interest_base_amount,
        orig.set_of_books_id       P_set_of_books_id,
        orig.payment_cross_rate    P_payment_cross_rate,
	--bug 8899917 use new.payment_exchange_rate
        new.payment_exchange_rate  P_exchange_rate,
        new.payment_exchange_rate_type  P_exchange_rate_type,
	--bug 8899917 new.exchange_rate_date is not reliably
	--populated so use ibydocs.payment_date
        ibydocs.payment_date       P_exchange_date,
        orig.invoice_id            P_invoice_id,
        orig.invoice_currency_code P_invoice_currency_code,
        orig.org_id                P_org_id
  FROM  po_vendors pv,
        ap_invoices_all orig,
        ap_selected_invoices_all new,
        fnd_currencies base,
        fnd_currencies fcinv,
        iby_fd_docs_payable_v ibydocs
 WHERE  new.original_invoice_id = orig.invoice_id --4346023, reverted 3293874
   AND  new.vendor_id = pv.vendor_id
   AND  new.checkrun_name = p_checkrun_name
   AND  new.checkrun_id = p_checkrun_id
   AND  base.currency_code = p_base_currency_code
   AND  fcinv.currency_code = orig.invoice_currency_code
   and  ibydocs.calling_app_doc_unique_ref1 = new.checkrun_id
   AND  ibydocs.calling_app_doc_unique_ref2 = new.invoice_id
   AND  ibydocs.calling_app_doc_unique_ref3 = new.payment_num
   and  ibydocs.completed_pmts_group_id = p_completed_pmts_group_id
   and  ibydocs.org_id = p_org_id
   and  new.org_id = p_org_id;


  rec_select_int_invoices  c_select_interest_invoices%rowtype;
  debug_info               VARCHAR2(100);
  l_login_id               ap_invoice_distributions.last_update_login%TYPE;

BEGIN

  -- Interest Invoices project - Invoice Lines
  -- Add l_login_id and pass it to ap_int_inv_insert_ap_inv_dist.
  -- Add P_org_id  and pass it to ap_int_inv_insert_ap_inv_dist.

  l_login_id  := TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'));

  debug_info := 'Fetch from cursor c_select_interest_invoices';

  OPEN c_select_interest_invoices;

    LOOP
      FETCH c_select_interest_invoices into rec_select_int_invoices;

      EXIT WHEN c_select_interest_invoices%NOTFOUND;

        AP_INTEREST_INVOICE_PKG.ap_int_inv_insert_ap_inv_dist(
          rec_select_int_invoices.P_int_invoice_id,
          rec_select_int_invoices.P_accounting_date,
          rec_select_int_invoices.P_vendor_id,
          rec_select_int_invoices.P_old_invoice_num,
          rec_select_int_invoices.P_int_invoice_num,
          rec_select_int_invoices.P_interest_amount,
          rec_select_int_invoices.P_interest_base_amount,
          P_period_name,
          rec_select_int_invoices.P_set_of_books_id,
          P_last_updated_by,
          P_interest_accts_pay_ccid,
          P_asset_account_flag,
          rec_select_int_invoices.p_payment_cross_rate,
          rec_select_int_invoices.P_exchange_rate,
          rec_select_int_invoices.P_exchange_rate_type,
          rec_select_int_invoices.P_exchange_date,
          null,
          'PAYMENTBATCH',
          null,
          rec_select_int_invoices.P_invoice_id,
          P_calling_sequence,
          rec_select_int_invoices.P_invoice_currency_code,
          P_base_currency_code,
          NULL,
          NULL,
          rec_select_int_invoices.P_org_id,
          l_login_id);

      END LOOP;
    CLOSE c_select_interest_invoices;

END ap_create_batch_interest_dists;

END AP_INTEREST_INVOICE_PKG;

/

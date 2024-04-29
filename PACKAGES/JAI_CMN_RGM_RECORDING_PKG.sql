--------------------------------------------------------
--  DDL for Package JAI_CMN_RGM_RECORDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RGM_RECORDING_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rgm_rec.pls 120.2.12010000.8 2010/04/15 10:44:57 boboli ship $ */

  /*  */
  /*----------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY for FILENAME: jai_rgm_trx_recording_pkg_s.sql
  S.No  dd/mm/yyyy   Author and Details
  ------------------------------------------------------------------------------------------------------------------------------
  1     15/12/2004   Vijay Shankar for Bug# 4068823, Version:115.0

              Coded for recording Service Tax into repository and related Accounting into GL

   2    25-April-2007   ssawant for bug 5879769 ,File version
                        Forward porting of
		        ENH : SERVICE TAX BY INVENTORY ORGANIZATION AND SERVICE TYPE SOLUTION from 11.5( bug no 5694855) to R12 (bug no 5879769).
			Fix : A new parameter p_service_type_code is added to insert_repository procedure

  DEPENDANCY:
  -----------
  IN60106  + 4068823


  2.        08-Jun-2005  Version 116.1 jai_cmn_rgm_rec -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

  3.     21-Nov-2008  Changes by nprashar for bug # 7525691
                              Issue: SVC TX SETTLEMENT PROCESS WITH DIFF SVC TYPES DIDN'T CREATE NETTING SERVICE JE
                              FIX: added a parameter p_balancing_entry to the procedure insert_repository_entry
  4.     06-Feb-2009 Bug 7525691 - The fix can be done without the p_balancing_entry paramter. Doing so will
                                   avoid any dependencies due to this bug. Therefore, removed the p_balancing_entry from
				   the specification.

  5.   18-Mar-2009  Bug 7525691 - File version 120.1.12000000.6/120.2.12010000.5/120.6
                    Introduced a new parameter p_distribution_type for procedure insert_repository_entry.

   6.   22-May-2009 Bug 8294236
 	                Issue: Service Tax Transaction created Fr Exchange Balances on Tax Accounts after Settlement
 	                Fix: Created a new procedure exc_gain_loss_accounting for creating the accounting
 	                            entries for foreign exchange gain or loss amount.

  7.   25-Dec-2009 Code change for bug7145898
 	                 Issue: VAT SETTLEMENT NOT HAPPENING AT REGN LEVEL ON HAVING MORE THEN ONE OU
 	                 Fix  : The settlment can be done for this case.

  8.   4-Apr-2010  Bo Li for Bug9305067
                   Modify the procedure insert_repository_entry and insert_vat_repository_entry.
                   Replace the attribute parameters with new meaningful parameters
----------------------------------------------------------------------------------------------------------------------------*/

  CURSOR c_regime_code(cp_regime_id IN NUMBER) IS
    SELECT regime_code
    FROM JAI_RGM_DEFINITIONS
    WHERE regime_id = cp_regime_id;

  CURSOR c_repository_dtl(cp_repository_id IN NUMBER) IS
    SELECT  regime_code, tax_type, source, source_table_name, source_document_id,
            source_trx_type, organization_id
    FROM jai_rgm_trx_records
    WHERE repository_id = cp_repository_id;

  g_debug             CONSTANT VARCHAR2(1)   := 'Y';
  ap_discount_accnt   CONSTANT VARCHAR2(30)  := 'AP_DISCOUNT_ACCOUNT';
  gd_accounting_date_dflt CONSTANT DATE := SYSDATE;

  -- COMMON API that will be called from DIFFERENT Transactions of the Regime
  -- This will call APIS to insert data into regime repository and GL Tables
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
    ----------------------------------------------------------
     --Added by Bo Li for Bug9305067 END
    p_service_type_code       IN      VARCHAR2  DEFAULT NULL, /* added by ssawant for bug 5989740 */
    p_distribution_type       IN      VARCHAR2  DEFAULT NULL  /*bug 7525691*/

 );

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
  );

  PROCEDURE insert_reference(
    p_reference_id OUT NOCOPY NUMBER,
    p_organization_id       IN  NUMBER,
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
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  );

  FUNCTION get_account(
    p_regime_id         IN  NUMBER,
    p_organization_type IN  VARCHAR2,
    p_organization_id   IN  NUMBER,
    p_location_id       IN  NUMBER,
    p_tax_type          IN  VARCHAR2,
    p_account_name      IN  VARCHAR2
  ) RETURN NUMBER;

  PROCEDURE get_period_name(
    p_organization_type     IN      VARCHAR2,
    p_organization_id       IN      NUMBER,
    p_accounting_date       IN OUT NOCOPY DATE,
    p_period_name OUT NOCOPY VARCHAR2,
    p_sob_id OUT NOCOPY NUMBER
  );

  PROCEDURE update_reference(
    p_source            IN  VARCHAR2,
    p_reference_id      IN  NUMBER,
    p_recovered_amount  IN  NUMBER,
    p_discounted_amount IN  NUMBER    DEFAULT NULL,
    p_process_flag OUT NOCOPY VARCHAR2,
    p_process_message OUT NOCOPY VARCHAR2
  );

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
    ---------------------------------------------------------------
    pv_trx_reference_context      IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference1             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference2             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference3             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference4             IN      VARCHAR2  DEFAULT NULL,
    pv_trx_reference5             IN      VARCHAR2  DEFAULT NULL,
    ------------------------------------------------------------------
     --Added by Bo Li for Bug9305067 END
    pn_settlement_id          IN      NUMBER    DEFAULT NULL  --added for bug#7145898, Eric Ma
  );

  /* following Procedure added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
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
    pv_process_flag                  OUT NOCOPY  VARCHAR2,
    pv_process_message               OUT NOCOPY  VARCHAR2,
    pv_tax_type                 IN              VARCHAR2    DEFAULT NULL,
    pv_source                   IN              VARCHAR2    DEFAULT NULL,
    pv_source_trx_type          IN              VARCHAR2    DEFAULT NULL,
    pv_source_table_name        IN              VARCHAR2    DEFAULT NULL,
    pn_source_id                IN              NUMBER      DEFAULT NULL,
    pv_reference_name           IN              VARCHAR2    DEFAULT NULL,
    pn_reference_id             IN              NUMBER      DEFAULT NULL
  );

  /* following function added by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  FUNCTION get_rgm_attribute_value(
    pv_regime_code          IN  VARCHAR2,
    pv_organization_type    IN  VARCHAR2,
    pn_organization_id      IN  NUMBER,
    pn_location_id          IN  NUMBER,
    pv_registration_type    IN  VARCHAR2,
    pv_attribute_type_code  IN  VARCHAR2,
    pv_attribute_code       IN  VARCHAR2
  ) RETURN VARCHAR2;

  /*Added this procedure for Bug 8294236*/
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
  );

END jai_cmn_rgm_recording_pkg;

/

--------------------------------------------------------
--  DDL for Package JAI_PA_BILLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_BILLING_PKG" AUTHID CURRENT_USER as
-- $Header: jai_pa_billing.pls 120.0.12000000.2 2007/10/25 02:22:44 rallamse noship $
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_pa_billing_pkg.pls
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     24/04/2007   Vijay Shankar for Bug#6012570 (5876390), Version:120.0 (115.2)
                    Forward ported to R12 from R11i
                      Package created for Projects Billing Implementation.

------------------------------------------------------------------------------------------------------------------------------*/

  gv_debug  constant boolean      := false;
  file      constant varchar2(30) := 'jai_pa_billing.log';

  -- gv_tax_source_doc_type    constant  varchar2(30)  := 'PROJECT_DRAFT_INVOICE';
  gv_source_projects        constant  varchar2(30)  := 'PROJECT_DRAFT_INVOICE';
  gv_draft_invoice_release  constant  varchar2(30)  := 'DRAFT_INVOICE_RELEASE';

  gv_draft_invoice_table    constant  varchar2(30)  := 'JAI_PA_DRAFT_INVOICES';
  gv_trx_type_draft_invoice constant  varchar2(30)  := 'DRAFT_INVOICE';

  gv_package_spec_version   constant varchar2(30)   := '120.0';

  function get_spec_version return varchar2;

  function get_body_version return varchar2;

  cursor c_regime_id(cp_regime_code in varchar2) is
    select regime_id
    from JAI_RGM_DEFINITIONS
    where regime_code = cp_regime_code;

  TYPE gl_entry IS RECORD (
     debit_amount          NUMBER,
     credit_amount        NUMBER,
     debit_ccid           gl_interface.code_combination_id%TYPE,
     credit_ccid          gl_interface.code_combination_id%TYPE,
     regime_code          varchar2(30),
     tax_type             varchar2(30),
     je_source            gl_je_headers.je_source%type,
     je_category          gl_je_headers.je_category%type,
     set_of_books_id      gl_sets_of_books.set_of_books_id%type,
     currency_code        gl_currencies.currency_code%type,
     currency_conv_rate   number,
     currency_conv_date   date,
     accounting_date      date,
     organization_code    gl_interface.reference1%TYPE,      -- p_params(i).organization_code,
     description          gl_interface.reference10%TYPE,     -- 'India Localization Entry for Interorg-XFER ',
     called_from          gl_interface.reference23%TYPE,     -- 'jai_mtl_trx_pkg.do_cenvat_Acctg',
     reference_table      gl_interface.reference24%TYPE,     -- 'jai_mtl_trxs',
     reference_column     gl_interface.reference25%TYPE,     -- p_transaction_temp_id,
     reference_id         gl_interface.reference26%TYPE,     -- 'transaction_temp_id',
     organization_id      gl_interface.reference27%TYPE,      -- to_char(p_params(i).organization_id)
     source               JAI_CMN_JOURNAL_ENTRIES.source%type,
     source_table_name    JAI_CMN_JOURNAL_ENTRIES.source_table_name%type,
     source_document_id   JAI_CMN_JOURNAL_ENTRIES.source_trx_id%type
  );

  procedure process_draft_invoice_release(
    pr_draft_invoice          IN  PA_DRAFT_INVOICES_ALL%rowtype,
    pv_called_from            IN  VARCHAR2,
    pv_process_flag           OUT NOCOPY  VARCHAR2,
    pv_process_message        OUT NOCOPY  VARCHAR2
  );

  PROCEDURE process_excise (
    pr_pa_draft_invoices_all  IN           pa_draft_invoices_all%rowtype      ,
    pv_called_from            IN           varchar2                           ,
    pv_process_flag           OUT  nocopy  varchar2                           ,
    pv_process_message        OUT  nocopy  varchar2
  );

  procedure process_vat(
    pn_project_id             IN  NUMBER,
    pn_draft_invoice_num      IN  NUMBER,
    -- pn_draft_invoice_id       IN  NUMBER,
    pv_called_from            IN  VARCHAR2,
    pv_process_flag           OUT nocopy  varchar2,
    pv_process_message        OUT nocopy  VARCHAR2
  );

  PROCEDURE check_excise_balance(
    pn_organization_id        IN    JAI_CMN_RG_23AC_II_TRXS.organization_id%type  ,
    pn_location_id            IN    JAI_CMN_RG_23AC_II_TRXS.location_id%type      ,
    pn_basic_excise_amt       IN    number                                   ,
    pn_additional_excise_amt  IN    number                                   ,
    pn_other_excise_amt       IN    number                                   ,
    pn_excise_cess_amt        IN    number                                   ,
    pn_sh_excise_cess_amt     IN    number                                   ,  /*budget07*/
    pv_called_from            IN    varchar2                                 ,
    pv_register               OUT  NOCOPY  varchar2                                 ,
    pv_process_flag           OUT  NOCOPY  varchar2                                 ,
    pv_process_message        OUT  NOCOPY  varchar2
  );

  procedure insert_gl_entry(
      pr_gl_entry             IN          JAI_PA_BILLING_PKG.GL_ENTRY,
      pv_process_flag         OUT NOCOPY  VARCHAR2,
      pv_process_message      OUT NOCOPY  VARCHAR2
  );

  procedure import_taxes_to_payables
  ( errbuf OUT NOCOPY varchar2
  , retcode OUT NOCOPY number
  , pn_request_id   in    ap_invoice_distributions_all.request_id%type
  , pn_invoice_id   in    ap_invoice_distributions_all.invoice_id%type
  , pv_event        in    varchar2
  );

end jai_pa_billing_pkg;
 

/

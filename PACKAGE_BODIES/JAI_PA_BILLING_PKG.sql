--------------------------------------------------------
--  DDL for Package Body JAI_PA_BILLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_BILLING_PKG" as
/* $Header: jai_pa_billing.plb 120.3.12010000.3 2010/03/31 10:49:27 mbremkum ship $ */
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_pa_billing_pkg.plb
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     24/04/2007   Vijay Shankar for Bug#6012570 (5876390), Version:120.0 (115.4)
                    Forward ported from R11i to R12
                      Package created for Projects Billing Implementation.
                      Initially the code is added to handle VAT and Excise taxes processing
2     18-Ayg-2007   brathod, Bug# 6012570, File Version 120.1
                    Insert statement for JAI_CMN_JOURNAL_ENTRIES modified to insert into column JOURNAL_ENTRY_ID

3.    04-Sep-2007   Bgowrava for Bug#6012570, File Version 120.3
                    Assigned the gl source for project accounting to the newly seeded gl source
                    'Projects India'.

4.    04-Nov-2008   Added for Forward Port Bug 6503813.
                    Added validation to check if the user has entered organization and location details in IL form.
                    This is to prevent the user from releasing the draft invoice from base form. If it is released,
                    it gets caught only in the auto-invoice import.

5.    31-Mar-2010   Bug 9535388
                    Description: Draft Invoice Release fails with le_org_loc_null exception though there are no
                    OFI taxes attached to the Draft Invoice
                    Fix: Get the number of OFI Tax Records for the Draft Invoice before throwing the exception
------------------------------------------------------------------------------------------------------------------------------*/
  --
  -- Forward declaration of private procedures
  --
  function update_payment_schedule (p_invoice_id  ap_invoices_all.invoice_id%type, p_total_tax number)
    return boolean ;
  procedure update_mrc_data (p_invoice_id ap_invoices_all.invoice_id%type);
  procedure insert_mrc_data (p_invoice_distribution_id number) ;

  gv_package_body_version constant varchar2(30) := '115.0';

  le_org_loc_null EXCEPTION; /*Added for Forward Port Bug 6503813*/

  cursor c_draft_invoice_dtls(cp_project_id in number, cp_draft_invoice_num in number) is
    select
        draft_invoice_id,
        organization_id,
        location_id,
        excise_invoice_no,
        excise_invoice_date ,
        vat_invoice_no,
        vat_invoice_date,
        project_id,
        draft_invoice_num,
        process_vat_flag,
        process_excise_flag,
        parent_draft_invoice_id
    from jai_pa_draft_invoices
    where project_id = cp_project_id
    and draft_invoice_num = cp_draft_invoice_num;

  cursor gc_fnd_curr_precision(cp_currency_code   fnd_currencies.currency_code%type)
  is
   select precision
   from   fnd_currencies
   where  currency_code = cp_currency_code;


  function get_spec_version return varchar2
  is
  begin
    return gv_package_body_version;
  end get_spec_version;

  function get_body_version return varchar2
  is
  begin
    return gv_package_body_version;
  end get_body_version;

  function get_sob_id(pn_org_id in number) return number
  is

    ln_sob_id   number(15);
    CURSOR c_ou_sob IS
      SELECT to_number(set_of_books_id) sob_id
      FROM hr_operating_units
      WHERE organization_id = pn_org_id;

  begin
    open c_ou_sob;
    fetch c_ou_sob into ln_sob_id;
    close c_ou_sob;

    return ln_sob_id;
  end get_sob_id;

  procedure insert_gl_entry(
      pr_gl_entry             IN          JAI_PA_BILLING_PKG.GL_ENTRY,
      pv_process_flag         OUT NOCOPY  VARCHAR2,
      pv_process_message      OUT NOCOPY  VARCHAR2
  ) is

    /* this is just for reference and not being used in this procedure
    CURSOR c_organization_accounts(cp_organization_id number, cp_location_id number) IS
    SELECT
        excise_rcvble_account           excise_debit_accnt ,
        cess_paid_payable_account_id    excise_edu_cess_debit_accnt,
        modvat_rm_account_id            cenvat_rm_accnt,
        excise_edu_cess_rm_account      cenvat_edu_cess_rm_accnt,
        modvat_cg_account_id            cenvat_cg_accnt,
        excise_edu_cess_cg_account      cenvat_edu_cess_cg_accnt
    FROM jai_cmn_inventory_orgs
    WHERE organization_id = cp_organization_id
    AND location_id = cp_location_id;
    */

    /* Sample GL_ENTRY
       gl_entry.debit_amount         := null;
       gl_entry.credit_amount        := xxx;
       gl_entry.debit_ccid           := excise_debit_accnt;                 -- gl_interface.code_combination_id%TYPE,
       gl_entry.credit_ccid          := <cenvat_rm or cenvat_cg>;           --gl_interface.code_combination_id%TYPE,
       gl_entry.regime_code          := 'EXCISE';                           -- varchar2(30),
       gl_entry.tax_type             := null;                               -- varchar2(30),
       gl_entry.je_source            := 'Project Accounting';               -- gl_je_headers.je_source%type,
       gl_entry.je_category          := 'Register Data Entry';              -- gl_je_headers.je_category%type,
       gl_entry.set_of_books_id      := ;                                   -- gl_sets_of_books.set_of_books_id%type,
       gl_entry.currency_code        := jai_constants.func_curr;            -- gl_currencies.currency_code%type,
       gl_entry.currency_conv_rate   := null;                               -- number,
       gl_entry.currency_conv_date   := null;                               -- date,
       gl_entry.accounting_date      := sysdate;                            -- date,
       gl_entry.organization_code    := ;                                   -- gl_interface.reference1%TYPE,      -- p_params(i).organization_code,
       gl_entry.description          := 'India Localization Entry for Projects Draft Invoice';       -- gl_interface.reference10%TYPE,     -- 'India Localization Entry for Interorg-XFER ',
       gl_entry.called_from          := <'jai_pa_billing_pkg.excise>;       -- gl_interface.reference23%TYPE,     -- 'jai_mtl_trx_pkg.do_cenvat_Acctg',
       gl_entry.reference_table      := 'JAI_PA_DRAFT_INVOICES';            -- gl_interface.reference24%TYPE,     -- 'jai_mtl_trxs',
       gl_entry.reference_column     := 'DRAFT_INVOICE_ID';                 -- gl_interface.reference25%TYPE,     -- p_transaction_temp_id,
       gl_entry.reference_id         := <draft_invoice_id>;                 -- gl_interface.reference26%TYPE,     -- 'transaction_temp_id',
       gl_entry.organization_id      := ;                                   -- gl_interface.reference27%TYPE,      -- to_char(p_params(i).organization_id)
       gl_entry.source               := 'PROJECTS';                         -- JAI_CMN_JOURNAL_ENTRIES.source%type,
       gl_entry.source_table_name    := 'PA_DRAFT_INVOICES_ALL';            -- JAI_CMN_JOURNAL_ENTRIES.source_table_name%type,
       gl_entry.source_document_id   := <draft_invoice_number>;             -- JAI_CMN_JOURNAL_ENTRIES.source_trx_id%type


      Entry 2 for ExciseEducation Cess
       gl_entry.amount               := zzz;
       gl_entry.credit_ccid          := <cenvat_cess_rm or cenvat_cess_cg>;       --gl_interface.code_combination_id%TYPE,
       gl_entry.debit_ccid           := excise_edu_cess_debit_accnt;       -- gl_interface.code_combination_id%TYPE,
       gl_entry.regime_code          := 'EXCISE_EDUCATION_CESS';       -- varchar2(30),
    */


  begin

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, 'Start insert_gl_entry');
    end if;

    if pr_gl_entry.credit_ccid is not null and nvl(pr_gl_entry.credit_amount,0) <> 0 then
      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '1 insert_gl_entry- Credit Entry');
      end if;

      insert into gl_interface(
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
      ) VALUES (
          'NEW',
          pr_gl_entry.set_of_books_id,
          pr_gl_entry.je_source,
          pr_gl_entry.je_category,
          nvl(pr_gl_entry.accounting_date, trunc(sysdate)) ,
          pr_gl_entry.currency_code,
          sysdate,
          fnd_global.user_id,
          'A',
          pr_gl_entry.credit_amount,
          null,
          sysdate,
          pr_gl_entry.credit_ccid,
          null,
          null,
          null,
          pr_gl_entry.organization_code,           --     reference1,                     p_params(i).organization_code,
          pr_gl_entry.description,                 --     reference10,                     'India Localization Entry for Interorg-XFER ',
          jai_constants.gl_je_source_name,         --     reference22,
          pr_gl_entry.called_from,                 --     reference23,                     'jai_mtl_trx_pkg.do_cenvat_Acctg',
          pr_gl_entry.source_table_name,           --     reference24,                     'jai_mtl_trxs',
          pr_gl_entry.source_document_id,          --     reference25,                     p_transaction_temp_id,
          pr_gl_entry.reference_table,             --     reference26,                     'transaction_temp_id',
          pr_gl_entry.organization_id              --     reference27                     to_char(p_params(i).organization_id)
      );

      INSERT INTO JAI_CMN_JOURNAL_ENTRIES(
          journal_entry_id,
          regime_code,
          organization_id,
          set_of_books_id,
          tax_type,
          -- period_name,
          code_combination_id,
          accounted_dr,
          accounted_cr,
          transaction_date,
          source,
          source_table_name,
          source_trx_id,
          reference_name,
          reference_id,
          currency_code,
          curr_conv_rate,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
      ) VALUES (
          jai_cmn_journal_entries_s.nextval,
          pr_gl_entry.regime_code,
          pr_gl_entry.organization_id,
          pr_gl_entry.set_of_books_id,
          pr_gl_entry.tax_type,
          -- lv_period_name,
          pr_gl_entry.credit_ccid,
          null,
          pr_gl_entry.credit_amount,
          nvl(pr_gl_entry.accounting_date,sysdate),
          pr_gl_entry.source,
          pr_gl_entry.source_table_name,
          pr_gl_entry.source_document_id,
          pr_gl_entry.reference_table,
          pr_gl_entry.reference_id,
          pr_gl_entry.currency_code,
          pr_gl_entry.currency_conv_rate,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id
      );
    end if;

    if pr_gl_entry.debit_ccid is not null and nvl(pr_gl_entry.debit_amount,0) <> 0 then
      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '2 insert_gl_entry- debit entry');
      end if;

      insert into gl_interface(
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
      ) VALUES (
          'NEW',
          pr_gl_entry.set_of_books_id,
          pr_gl_entry.je_source,
          pr_gl_entry.je_category,
          nvl(pr_gl_entry.accounting_date, trunc(sysdate)) ,
          pr_gl_entry.currency_code,
          sysdate,
          fnd_global.user_id,
          'A',
          null,
          pr_gl_entry.debit_amount,
          sysdate,
          pr_gl_entry.debit_ccid,
          null,
          null,
          null,
          pr_gl_entry.organization_code,           --     reference1,                     p_params(i).organization_code,
          pr_gl_entry.description,                 --     reference10,                     'India Localization Entry for Interorg-XFER ',
          jai_constants.gl_je_source_name,         --     reference22,
          pr_gl_entry.called_from,                 --     reference23,                     'jai_mtl_trx_pkg.do_cenvat_Acctg',
          pr_gl_entry.source_table_name,           --     reference24,                     'jai_mtl_trxs',
          pr_gl_entry.source_document_id,          --     reference25,                     p_transaction_temp_id,
          pr_gl_entry.reference_table,             --     reference26,                     'transaction_temp_id',
          pr_gl_entry.organization_id              --     reference27                     to_char(p_params(i).organization_id)
      );


      INSERT INTO jai_cmn_journal_entries(
          JOURNAL_ENTRY_ID,
          regime_code,
          organization_id,
          set_of_books_id,
          tax_type,
          -- period_name,
          code_combination_id,
          accounted_dr,
          accounted_cr,
          transaction_date,
          source,
          source_table_name,
          source_trx_id,
          reference_name,
          reference_id,
          currency_code,
          curr_conv_rate,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
      ) VALUES (
          JAI_CMN_JOURNAL_ENTRIES_S.NEXTVAL,
          pr_gl_entry.regime_code,
          pr_gl_entry.organization_id,
          pr_gl_entry.set_of_books_id,
          pr_gl_entry.tax_type,
          -- lv_period_name,
          pr_gl_entry.debit_ccid,
          pr_gl_entry.debit_amount,
          null,
          nvl(pr_gl_entry.accounting_date,sysdate),
          pr_gl_entry.source,
          pr_gl_entry.source_table_name,
          pr_gl_entry.source_document_id,
          pr_gl_entry.reference_table,
          pr_gl_entry.reference_id,
          pr_gl_entry.currency_code,
          pr_gl_entry.currency_conv_rate,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id
      );
    end if;

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, 'End insert_gl_entry');
    end if;

  end insert_gl_entry;

  procedure process_draft_invoice_release(
    --pn_project_id             IN  NUMBER,
    --pn_draft_invoice_num      IN  NUMBER,
    pr_draft_invoice          IN  PA_DRAFT_INVOICES_ALL%rowtype,
    pv_called_from            IN  VARCHAR2,
    pv_process_flag           OUT NOCOPY  VARCHAR2,
    pv_process_message        OUT NOCOPY  VARCHAR2
  ) is

    ln_draft_invoice_id     jai_pa_draft_invoices.draft_invoice_id%type;

    cursor c_tax_cnt(cp_draft_invoice_id in number) is
      select
        nvl( sum( decode( nvl(c.regime_code,'XX'), 'VAT', 1, 0)), 0) vat_cnt,
        nvl( sum( decode( upper(b.tax_type), 'EXCISE', 1, 'ADDL. EXCISE', 1, 'OTHER EXCISE', 1, 0)), 0) excise_cnt
      from  jai_cmn_document_taxes          b,
            jai_regime_tax_types_v          c
      where b.source_doc_type = jai_pa_billing_pkg.gv_source_projects
      and b.tax_type = c.tax_type(+)
      and b.source_doc_id = cp_draft_invoice_id;

    /*Bug 9535388 - Get the number of Tax Records for the Draft Invoice*/

    cursor c_all_tax_cnt(cp_draft_invoice_id in number) is
    select count (*) tax_cnt
    from  jai_cmn_document_taxes          b
    where b.source_doc_type = jai_pa_billing_pkg.gv_source_projects
    and   b.source_doc_id = cp_draft_invoice_id;

    r_tax_cnt               c_tax_cnt%rowtype;
    r_all_tax_cnt           NUMBER;
    r_draft_invoice_dtls    c_draft_invoice_dtls%rowtype;

    lv_statement_no     varchar2(10);

  begin

    lv_statement_no := '1';
    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, 'Start process_draft_invoice_release');
    end if;

    open c_draft_invoice_dtls(pr_draft_invoice.project_id, pr_draft_invoice.draft_invoice_num);
    fetch c_draft_invoice_dtls into r_draft_invoice_dtls;
    close c_draft_invoice_dtls;

    /*Bug 9535388 - Get the number of tax records. If r_all_tax_cnt is greater than 0 then raise there exception - Start*/
    r_all_tax_cnt := 0;

    open c_all_tax_cnt(r_draft_invoice_dtls.draft_invoice_id);
    fetch c_all_tax_cnt into r_all_tax_cnt;
    close c_all_tax_cnt;

    /*Stop the user from releasing the draft invoice without providing org / location information*/
    /*Forward Port Bug 6503813 - Start*/
    IF (r_draft_invoice_dtls.organization_id is null or r_draft_invoice_dtls.location_id is null) and r_all_tax_cnt > 0
    THEN
           raise le_org_loc_null ;
    END IF ;
    /*Forward Port Bug 6503813 - End*/
    /*Bug 9535388 - End*/

    open c_tax_cnt(r_draft_invoice_dtls.draft_invoice_id);
    fetch c_tax_cnt into r_tax_cnt;
    close c_tax_cnt;

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '1 pdir- ExcCnt:'||r_tax_cnt.excise_cnt||', VatCnt:'||r_tax_cnt.vat_cnt);
    end if;

    if r_tax_cnt.excise_cnt > 0 then
      lv_statement_no := '2';
      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '2 pdir- BefCall to ProcExcise:');
      end if;

      if nvl(r_draft_invoice_dtls.process_excise_flag, jai_constants.no) <>  jai_constants.yes then

        process_excise(
          --pn_project_id             => pr_draft_invoice.project_id        ,
          --pn_draft_invoice_num      => pr_draft_invoice.draft_invoice_num ,
          -- pn_draft_invoice_id       => r_draft_invoice_dtls.draft_invoice_id  ,
          pr_pa_draft_invoices_all  => pr_draft_invoice     ,
          pv_called_from            => pv_called_from||'.process_draft_invoice_release'       ,
          pv_process_flag           => pv_process_flag      ,
          pv_process_message        => pv_process_message
        ) ;

        if jai_pa_billing_pkg.gv_debug then
          jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '1.1 pdir- After process_excise. pv_process_message:'
                                ||pv_process_message);
        end if;

        if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
          goto end_of_procedure;
        end if;

      end if;

    end if;

    if r_tax_cnt.vat_cnt > 0 then
      lv_statement_no := '3';
      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3 pdir- BefCall to ProcVat');
      end if;

      if nvl(r_draft_invoice_dtls.process_vat_flag, jai_constants.no) <>  jai_constants.yes then
        process_vat(
          pn_project_id             => pr_draft_invoice.project_id        ,
          pn_draft_invoice_num      => pr_draft_invoice.draft_invoice_num ,
          -- pn_draft_invoice_id       => r_draft_invoice_dtls.draft_invoice_id  ,
          pv_called_from            => pv_called_from       ,
          pv_process_flag           => pv_process_flag      ,
          pv_process_message        => pv_process_message
        ) ;

        if jai_pa_billing_pkg.gv_debug then
          jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3.1 pdir- After process_vat. pv_process_message:'
                                ||pv_process_message);
        end if;

        if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
          goto end_of_procedure;
        end if;

      end if;

    end if;

    lv_statement_no := '4';
    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3 End pdir');
    end if;

    <<end_of_procedure>>
    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '9 End of process_draft_invoice_release');
    end if;

  exception
    /*Added for Forward Port Bug 6503813 - Start*/
    when le_org_loc_null then
       pv_process_flag     := 'E';
       pv_process_message  := 'Please specify Organization and Location in the India-Invoice form before releasing the draft invoice.' ;
    /*Added for Forward Port Bug 6503813 - End*/
    when others then
      pv_process_flag     := 'E';
      pv_process_message  := 'Error Occured in process_draft_invoice_release. Statement no:'||lv_statement_no
                              || '. Error:'||sqlerrm;
  end process_draft_invoice_release;

 procedure process_vat(
    pn_project_id             IN  NUMBER,
    pn_draft_invoice_num      IN  NUMBER,
    -- pn_draft_invoice_id       IN  NUMBER,
    pv_called_from            IN  VARCHAR2,
    pv_process_flag           OUT NOCOPY  VARCHAR2,
    pv_process_message        OUT NOCOPY  VARCHAR2
  ) is

    CURSOR c_same_inv_no(
        cp_organization_id  JAI_CMN_INVENTORY_ORGS.organization_id%TYPE,
        cp_location_id      JAI_CMN_INVENTORY_ORGS.location_id%TYPE,
        cp_regime_id        JAI_RGM_DEFINITIONS.regime_id%type
    ) IS
    SELECT attribute_value
    FROM   jai_rgm_org_regns_v
    WHERE  regime_id = cp_regime_id
    AND    attribute_type_code = jai_constants.regn_type_others
    AND    attribute_code = jai_constants.attr_code_same_inv_no
    AND    organization_id = cp_organization_id
    AND    location_id = cp_location_id;

    ln_regime_id              JAI_RGM_DEFINITIONS.regime_id%type;
    lv_same_invoice_no_flag   jai_rgm_org_regns_v.attribute_value%type;
    lv_vat_invoice_no         VARCHAR2(240);
    ld_vat_invoice_date       DATE;

    r_draft_invoice_dtls      c_draft_invoice_dtls%ROWTYPE;

    lv_credit_memo_flag               varchar2(1);
    lv_called_from                    varchar2(30);
    lv_debug            varchar2(1); /*added for R12 */

  begin

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '1 Start Process_Vat');
    end if;

    lv_credit_memo_flag := jai_constants.no;

    /* generate vat invoice no */
    open c_draft_invoice_dtls(pn_project_id, pn_draft_invoice_num);
    fetch c_draft_invoice_dtls into r_draft_invoice_dtls;
    close c_draft_invoice_dtls;

    if r_draft_invoice_dtls.parent_draft_invoice_id is not null then
      lv_credit_memo_flag := jai_constants.yes;
    end if;

    open c_regime_id(jai_constants.vat_regime);
    fetch c_regime_id into ln_regime_id;
    close c_regime_id;

    /* for CREDIT MEMO the VAT invoice number should not be generated */

    if lv_credit_memo_flag = jai_constants.no then

      open c_same_inv_no(r_draft_invoice_dtls.organization_id, r_draft_invoice_dtls.location_id, ln_regime_id);
      fetch c_same_inv_no into lv_same_invoice_no_flag;
      close c_same_inv_no;

      if nvl(lv_same_invoice_no_flag, jai_constants.no) = jai_constants.yes then
        lv_vat_invoice_no   := r_draft_invoice_dtls.excise_invoice_no;
        ld_vat_invoice_date := r_draft_invoice_dtls.excise_invoice_date;
      end if;

      if lv_vat_invoice_no is null then
        if jai_pa_billing_pkg.gv_debug then
          jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '2 rocess_Vat. BefCall to jai_cmn_rgm_setup_pkg.gen_invoice_number. Regime:'||ln_regime_id);
        end if;

        /* generation of vat invoice number uses the Default VAT Doc sequence setup */
        jai_cmn_rgm_setup_pkg.gen_invoice_number(
            p_regime_id        => ln_regime_id                          ,
            p_organization_id  => r_draft_invoice_dtls.organization_id  ,
            p_location_id      => r_draft_invoice_dtls.location_id      ,
            p_date             => sysdate                               ,
            p_doc_class        => 'D'       ,  /* means number will be generated from Default doc seq */
            p_doc_type_id      => -9999                                 ,
            p_invoice_number   => lv_vat_invoice_no                     ,
            p_process_flag     => pv_process_flag                       ,
            p_process_msg      => pv_process_message
        );

        if jai_pa_billing_pkg.gv_debug then
          jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3 rocess_Vat. AftCall to jai_cmn_rgm_setup_pkg.gen_invoice_number. lv_vat_invoice_no:'||lv_vat_invoice_no);
        end if;

      end if;

      if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
        goto end_of_procedure;

      elsif lv_vat_invoice_no is null then
        pv_process_flag     := jai_constants.expected_error;
        pv_process_message  := 'VAT Invoice could not be generated';
        goto end_of_procedure;
      end if;

      if lv_vat_invoice_no is not null then
        ld_vat_invoice_date := trunc(sysdate);
      end if;

    end if;

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '4 rocess_Vat. BefCall to jai_cmn_rgm_vat_accnt_pkg.process_order_invoice. DraftInvoceId:'||r_draft_invoice_dtls.draft_invoice_id);
    end if;

    if lv_credit_memo_flag = jai_constants.yes then
      lv_called_from := 'DRAFT_INVOICE_CM';
    else
      lv_called_from := 'DRAFT_INVOICE';
    end if;

    if jai_pa_billing_pkg.gv_debug then
      lv_debug := 'Y';
    else
      lv_debug := 'N';
    end if;

    /* Repository Hitting + VAT interim accounting should happen here.
    VAT Interim to Liability will happend in AR invoice is imported */
    jai_cmn_rgm_vat_accnt_pkg.process_order_invoice (
          p_regime_id         => ln_regime_id,
          p_source            => jai_pa_billing_pkg.gv_source_projects,
          p_organization_id   => r_draft_invoice_dtls.organization_id,
          p_location_id       => r_draft_invoice_dtls.location_id,
          p_delivery_id       => r_draft_invoice_dtls.draft_invoice_id,
          p_customer_trx_id   => NULL,
          p_transaction_type  => lv_called_from,
          p_vat_invoice_no    => lv_vat_invoice_no,
          p_default_invoice_date => ld_vat_invoice_date,
          p_batch_id          => NULL,
          p_called_from       => 'jai_pa_billing_pkg.process_vat', --jai_pa_billing_pkg.gv_draft_invoice_release,
          p_debug             => lv_debug,
          p_process_flag      => pv_process_flag,
          p_process_message   => pv_process_message
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '6 process_Vat. AftCall to jai_cmn_rgm_vat_accnt_pkg.process_order_invoice. pv_process_message:'||pv_process_message);
    end if;

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
      goto end_of_procedure;
    end if;

    UPDATE jai_pa_draft_invoices
    SET vat_invoice_no      = lv_vat_invoice_no,
        vat_invoice_date    = ld_vat_invoice_date,
        process_vat_flag    = 'Y',
        last_update_date    = sysdate,
        last_updated_by     = fnd_global.user_id,
        last_update_login   = fnd_global.login_id
    WHERE draft_invoice_id  = r_draft_invoice_dtls.draft_invoice_id;

    <<end_of_procedure>>
    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '7 End process_Vat. Aft  UPDATE jai_pa_draft_invoices');
    end if;

  exception
    when others then
      pv_process_flag     := jai_constants.unexpected_error;
      pv_process_message  := 'Error in process_vat. Message:'||SQLERRM;

  end process_vat;


PROCEDURE process_excise
(
  pr_pa_draft_invoices_all  IN           pa_draft_invoices_all%rowtype      ,
  pv_called_from            IN           varchar2                           ,
  pv_process_flag           OUT  nocopy  varchar2                           ,
  pv_process_message        OUT  nocopy  varchar2
)
IS

  cursor c_jai_pa_draft_invoices is
    select draft_invoice_id
          ,organization_id
          ,location_id
          ,draft_invoice_num
          ,project_id
    from  jai_pa_draft_invoices
    where project_id        = pr_pa_draft_invoices_all.project_id
      and draft_invoice_num = pr_pa_draft_invoices_all.draft_invoice_num;


  cursor c_exists_excise_tax (cpn_draft_invoice_id number) is
    select 'Y'
    from   jai_cmn_document_taxes
    where  source_doc_type         =  jai_pa_billing_pkg.gv_source_projects
      and  source_doc_id           =  cpn_draft_invoice_id
      and  upper(tax_type)
           in
           ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE',
             upper(jai_constants.tax_type_exc_edu_cess)
             , jai_constants.tax_type_sh_exc_edu_cess /*budget07*/
             );
  /* CVD type of taxes would not exist for projects invoice */

  cursor c_get_excise_breakup (cpn_draft_invoice_id number) is
    select round(sum( decode( upper(tax_type), 'EXCISE', func_tax_amt, 0 )), 2)             basic_excise
          ,round(sum( decode( upper(tax_type), 'ADDL. EXCISE', func_tax_amt, 0 )), 2)       additional_excise
          ,round(sum( decode( upper(tax_type), 'OTHER EXCISE', func_tax_amt, 0  )), 2)      other_excise
          ,round(sum( decode( upper(tax_type),
                upper(jai_constants.tax_type_exc_edu_cess), func_tax_amt, 0  )), 2)         excise_cess
          ,round(sum( decode( tax_type,
                jai_constants.tax_type_sh_exc_edu_cess, func_tax_amt, 0  )), 2)             sh_excise_cess /*budget07*/
    from   jai_cmn_document_taxes
    where  source_doc_type         =  jai_pa_billing_pkg.gv_source_projects
      and  source_doc_id           =  cpn_draft_invoice_id
      and  upper(tax_type)
           in
           ('EXCISE', 'ADDL. EXCISE', 'OTHER EXCISE',
             upper(jai_constants.tax_type_exc_edu_cess)
             , jai_constants.tax_type_sh_exc_edu_cess  /*budget07*/
           );


  cursor c_JAI_CMN_INVENTORY_ORGS (cpn_organization_id number, cpn_location_id number) is
    select
        excise_rcvble_account           excise_debit_accnt ,
        cess_paid_payable_account_id    excise_edu_cess_debit_accnt,
        modvat_rm_account_id            cenvat_rm_accnt,
        modvat_cg_account_id            cenvat_cg_accnt,
        modvat_pla_account_id           cenvat_pla_accnt,
        excise_edu_cess_rm_account      cenvat_edu_cess_rm_accnt,
        excise_edu_cess_cg_account      cenvat_edu_cess_cg_accnt,
        /*budget07*/
        sh_cess_paid_payable_acct_id    exc_sh_cess_debit_accnt,
        sh_cess_rm_account            exc_sh_cess_rm_accnt,
        sh_cess_cg_account_id       exc_sh_cess_cg_accnt
     from JAI_CMN_INVENTORY_ORGS
    where organization_id  =  cpn_organization_id
    and   (
           (cpn_location_id is not null and location_id = cpn_location_id)
           or
           (cpn_location_id is null and (location_id = 0 or location_id is null) )
          );

   /*
   cursor c_JAI_CMN_FIN_YEARS(cpn_organization_id in number) is
     select max(fin_year) fin_year
     from   JAI_CMN_FIN_YEARS
     where  organization_id = cpn_organization_id
       and  fin_active_flag = 'Y';
    */

  r_jai_pa_draft_invoices          c_draft_invoice_dtls%rowtype;
  r_jai_cmn_inventory_orgs    c_jai_cmn_inventory_orgs%rowtype;
  r_jai_cmn_inventory_orgs1   c_jai_cmn_inventory_orgs%rowtype;


  lv_exists_excise_tax             varchar2(1);
  ln_basic_excise_amt              number;
  ln_additional_excise_amt         number;
  ln_other_excise_amt              number;
  ln_excise_cess_amt               number;
  ln_sh_excise_cess_amt            number; /*budget07*/
  ln_register_id                   number;
  lv_register                      varchar2(30);
  ld_transaction_date              date;
  lv_rg23_part_ii_reg_type         varchar2(1);
  lv_remarks                       jai_cmn_rg_23ac_ii_trxs.remarks%type;
  lv_excise_inv_no                 jai_cmn_rg_23ac_ii_trxs.excise_invoice_no%type;
  ld_excise_invoice_date           date;

  ln_customer_id                   jai_cmn_rg_23ac_ii_trxs.customer_id%type;
  ln_customer_site_id              jai_cmn_rg_23ac_ii_trxs.customer_site_id%type;
  ln_debit_account_id              jai_cmn_rg_23ac_ii_trxs.charge_account_id%type;
  lv_transaction_type              varchar2(30);
  lv_transaction_source            varchar2(30);
  ln_fin_year                      JAI_CMN_FIN_YEARS.fin_year%type;
  lv_source_name                   varchar2(30);
  ln_source_type                   JAI_CMN_RG_OTHERS.source_type%type;

  r_gl_entry                        jai_pa_billing_pkg.GL_ENTRY;
  ln_excise_total                   number;
  ln_credit_ccid                    number;
  ln_debit_ccid                     number;

  lv_credit_memo_flag               varchar2(1);

BEGIN

  if jai_pa_billing_pkg.gv_debug then
    jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '1 Start process_excise');
  end if;

  /* defaults initialization */
  lv_transaction_type     := jai_pa_billing_pkg.gv_trx_type_draft_invoice;  -- 'DRAFT_INVOICE';
  lv_transaction_source   := jai_pa_billing_pkg.gv_draft_invoice_release;   -- 'DRAFT_INVOICE_RELEASE'
  lv_exists_excise_tax    := jai_constants.no;
  ld_transaction_date     := sysdate;
  lv_credit_memo_flag     := jai_constants.no;

  /* Get IL related info for the project invoice. */
  open  c_draft_invoice_dtls(pr_pa_draft_invoices_all.project_id, pr_pa_draft_invoices_all.draft_invoice_num);
  fetch c_draft_invoice_dtls into r_jai_pa_draft_invoices;
  close c_draft_invoice_dtls;

  if r_jai_pa_draft_invoices.parent_draft_invoice_id is not null then
    lv_credit_memo_flag := jai_constants.yes;
  end if;

  /* Check if Excise is applicable - that is if excise type of taxes exist */
  open  c_exists_excise_tax(r_jai_pa_draft_invoices.draft_invoice_id);
  fetch c_exists_excise_tax into lv_exists_excise_tax;
  close c_exists_excise_tax;

  if lv_exists_excise_tax <> jai_constants.yes then
    /* Excise taxes do not exist, excise processing is  not applicable, return with 'X' */
    pv_process_flag      := 'X';
    pv_process_message   := 'Excise processing is not applicable as excise taxes do not exist';
    goto exit_from_procedure;
  end if;

  /*** Control comes here only if excisable taxes exist for the invoice ***/

  /* Get the break up of tax amount for basic, additional, other excise and Cess */
  open  c_get_excise_breakup(r_jai_pa_draft_invoices.draft_invoice_id);
  fetch c_get_excise_breakup into ln_basic_excise_amt, ln_additional_excise_amt,
        ln_other_excise_amt, ln_excise_cess_amt
        , ln_sh_excise_cess_amt;/*budget07*/
  close c_get_excise_breakup;

  ln_excise_total :=
    nvl(ln_basic_excise_amt,0) + nvl(ln_additional_excise_amt,0) + nvl(ln_other_excise_amt,0);

  if ln_excise_total = 0 then
    pv_process_flag      := 'X';
    pv_process_message   := 'Excise processing is not applicable as excise total is 0';
    goto exit_from_procedure;
  end if;

  /* Check if sufficient balances exist for the transaction to go through,
     based on register preferences */
  if jai_pa_billing_pkg.gv_debug then
    jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '2 process_excise. BefChkExcBal.'
              ||', ln_basic_excise_amt:'||ln_basic_excise_amt
              ||', ln_additional_excise_amt:'||ln_additional_excise_amt
              ||', ln_other_excise_amt:'||ln_other_excise_amt
              ||', ln_excise_cess_amt:'||ln_excise_cess_amt
              ||', ln_sh_excise_cess_amt:'||ln_sh_excise_cess_amt
    );
  end if;

  check_excise_balance
  (
    pn_organization_id        =>  r_jai_pa_draft_invoices.organization_id   ,
    pn_location_id            =>  r_jai_pa_draft_invoices.location_id       ,
    pn_basic_excise_amt       =>  ln_basic_excise_amt                       ,
    pn_additional_excise_amt  =>  ln_additional_excise_amt                  ,
    pn_other_excise_amt       =>  ln_other_excise_amt                       ,
    pn_excise_cess_amt        =>  ln_excise_cess_amt                        ,
    pn_sh_excise_cess_amt     =>  ln_sh_excise_cess_amt                     , /*budget07*/
    pv_called_from            =>  'jai_pa_billing_pkg.process_excise'       ,
    pv_register               =>  lv_register                               ,
    pv_process_flag           =>  pv_process_flag                           ,
    pv_process_message        =>  pv_process_message
  );

  if jai_pa_billing_pkg.gv_debug then
    jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '3 process_excise. AftChkExcBal. lv_register:'||lv_register
                    ||', pv_process_message:'||pv_process_message);
  end if;

  if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
    goto exit_from_procedure;
  end if;
  /**** Control comes here only if excise balance exists ****/

  ln_fin_year := jai_general_pkg.get_fin_year(r_jai_pa_draft_invoices.organization_id);
  if jai_pa_billing_pkg.gv_debug then
    jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '5 process_excise. Before jai_cmn_setup_pkg.generate_excise_invoice_no');
  end if;

  /* Generate Excise Invoice
    for CREDIT MEMO the excise invoice number should not be generated
  */
  if lv_credit_memo_flag = jai_constants.no then

    jai_cmn_setup_pkg.generate_excise_invoice_no
    (
      p_organization_id        =>     r_jai_pa_draft_invoices.organization_id  ,
      p_location_id            =>     r_jai_pa_draft_invoices.location_id      ,
      p_called_from            =>     jai_pa_billing_pkg.gv_source_projects    ,
      p_order_invoice_type_id  =>     null                                     ,
      p_fin_year               =>     ln_fin_year                              ,
      p_excise_inv_no          =>     lv_excise_inv_no                         ,
      p_errbuf                 =>     pv_process_message
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '5 process_excise. After jai_cmn_setup_pkg.generate_excise_invoice_no. lv_excise_inv_no:'||lv_excise_inv_no
                      ||', pv_process_message:'||pv_process_message);
    end if;

    if pv_process_message is not null then
      pv_process_flag := jai_constants.expected_error;
      goto exit_from_procedure;
    end if;

    if lv_excise_inv_no is not null then
      ld_excise_invoice_date  := trunc(ld_transaction_date);
    end if;

  end if;

  if  pr_pa_draft_invoices_all.ship_to_customer_id is not null then
    ln_customer_id       := pr_pa_draft_invoices_all.ship_to_customer_id;
    ln_customer_site_id  := pr_pa_draft_invoices_all.ship_to_address_id;

  elsif pr_pa_draft_invoices_all.bill_to_customer_id is not null then
    ln_customer_id       := pr_pa_draft_invoices_all.bill_to_customer_id;
    ln_customer_site_id  := pr_pa_draft_invoices_all.bill_to_address_id;

  end if;

  /* Derive the required accounts */
  /* Accounts for the required location */
  open  c_jai_cmn_inventory_orgs(r_jai_pa_draft_invoices.organization_id, r_jai_pa_draft_invoices.location_id);
  fetch c_jai_cmn_inventory_orgs into r_jai_cmn_inventory_orgs;
  close c_jai_cmn_inventory_orgs;

  /* Accounts for the null location */
  open  c_jai_cmn_inventory_orgs(r_jai_pa_draft_invoices.organization_id, null);
  fetch c_jai_cmn_inventory_orgs into r_jai_cmn_inventory_orgs1;
  close c_jai_cmn_inventory_orgs;

  ln_debit_account_id := nvl(r_jai_cmn_inventory_orgs.excise_debit_accnt,
                                  r_jai_cmn_inventory_orgs1.excise_debit_accnt);


  /* Update RG Registers */
  if lv_register IN ('RG23A', 'RG23C') then

    if lv_register = 'RG23A' then
      lv_rg23_part_ii_reg_type := 'A';
    else
      lv_rg23_part_ii_reg_type := 'C';
    end if;

    lv_remarks := 'For projects draft invoice number-'||pr_pa_draft_invoices_all.draft_invoice_num;

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '8 process_excise. Before jai_cmn_rg_23ac_ii_trxs_pkg.insert_row'
                 );
    end if;

    jai_cmn_rg_23ac_ii_pkg.insert_row
    (
      p_register_id          =>   ln_register_id                                    ,
      p_inventory_item_id    =>   0  /* no inventory item for projects */           ,
      p_organization_id      =>   r_jai_pa_draft_invoices.organization_id           ,
      p_location_id          =>   r_jai_pa_draft_invoices.location_id               ,
      p_receipt_id           =>   r_jai_pa_draft_invoices.draft_invoice_id          ,
      p_receipt_date         =>   trunc(ld_transaction_date)                        ,
      p_cr_basic_ed          =>   null                                              ,
      p_cr_additional_ed     =>   null                                              ,
      p_cr_additional_cvd    =>   null                                              ,
      p_cr_other_ed          =>   null                                              ,
      p_dr_basic_ed          =>   ln_basic_excise_amt                               ,
      p_dr_additional_ed     =>   ln_additional_excise_amt                          ,
      p_dr_additional_cvd    =>   null                                              ,
      p_dr_other_ed          =>   ln_other_excise_amt                               ,
      p_excise_invoice_no    =>   lv_excise_inv_no                                  ,
      p_excise_invoice_date  =>   ld_excise_invoice_date                     ,
      p_register_type        =>   lv_rg23_part_ii_reg_type                          ,
      p_remarks              =>   lv_remarks                                        ,
      p_vendor_id            =>   null                                              ,
      p_vendor_site_id       =>   null                                              ,
      p_customer_id          =>   ln_customer_id                                    ,
      p_customer_site_id     =>   ln_customer_site_id                               ,
      p_transaction_date     =>   ld_transaction_date                               ,
      p_charge_account_id    =>   ln_debit_account_id                               ,
      p_register_id_part_i   =>   null /* no qty register for projects as no item */,
      p_reference_num        =>   r_jai_pa_draft_invoices.draft_invoice_id          ,
      p_rounding_id          =>   null                                              ,
      p_other_tax_credit     =>   null                                              ,
      p_other_tax_debit      =>   ln_excise_cess_amt  + ln_sh_excise_cess_amt       , -- Bug 6012570, Added sh cess
      p_transaction_type     =>   lv_transaction_type                               ,
      p_transaction_source   =>   lv_transaction_source                             ,
      p_called_from          =>   'jai_pa_billing_pkg.process_excise'               ,
      p_simulate_flag        =>   null                                              ,
      p_process_status       =>   pv_process_flag                                   ,
      p_process_message      =>   pv_process_message
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '9 process_excise. After jai_cmn_rg_23ac_ii_pkg.insert_row'
                 ||', ln_register_id:'||ln_register_id||', pv_process_message:'||pv_process_message);
    end if;

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error) then
      goto exit_from_procedure;
    end if;

    /* Set variables for Cess Register Entry */
    ln_source_type := 1;
    lv_source_name := lv_register || '_P2';

  elsif lv_register = 'PLA' then

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '11 process_excise. Before jai_cmn_rg_pla_trxs_pkg.insert_row'
                 );
    end if;

    jai_cmn_rg_pla_trxs_pkg.insert_row
    (
      p_register_id          =>   ln_register_id                                    ,
      p_ref_document_id      =>   r_jai_pa_draft_invoices.draft_invoice_id          ,
      p_ref_document_date    =>   ld_transaction_date                               ,
      p_dr_invoice_id        =>   lv_excise_inv_no                                  ,
      p_dr_invoice_date      =>   ld_excise_invoice_date                        ,
      p_dr_basic_ed          =>   ln_basic_excise_amt                               ,
      p_dr_additional_ed     =>   ln_additional_excise_amt                          ,
      p_dr_other_ed          =>   ln_other_excise_amt                               ,
      p_organization_id      =>   r_jai_pa_draft_invoices.organization_id           ,
      p_location_id          =>   r_jai_pa_draft_invoices.location_id               ,
      p_bank_branch_id       =>   null                                              ,
      p_entry_date           =>   ld_transaction_date                               ,
      p_inventory_item_id    =>   0 /* no inventory item for projects */            ,
      p_vendor_cust_flag     =>   'C'                                               ,
      p_vendor_id            =>   ln_customer_id                                    ,
      p_vendor_site_id       =>   ln_customer_site_id                               ,
      p_excise_invoice_no    =>   lv_excise_inv_no                                  ,
      p_remarks              =>   lv_remarks                                        ,
      p_transaction_date     =>   trunc(ld_transaction_date)                        ,
      p_charge_account_id    =>   ln_debit_account_id                               ,
      p_other_tax_credit     =>   null                                              ,
      p_other_tax_debit      =>   ln_excise_cess_amt  + ln_sh_excise_cess_amt       ,  -- Bug 6012570, Added sh cess
      p_transaction_type     =>   lv_transaction_type                               ,
      p_transaction_source   =>   lv_transaction_source                             ,
      p_called_from          =>   'jai_pa_billing_pkg.process_excise'               ,
      p_simulate_flag        =>   null                                              ,
      p_process_status       =>   pv_process_flag                                   ,
      p_process_message      =>   pv_process_message                                ,
      p_rounding_id          =>   null                                              ,
      p_tr6_challan_no       =>   null                                              ,
      p_tr6_challan_date     =>   null                                              ,
      p_cr_basic_ed          =>   null                                              ,
      p_cr_additional_ed     =>   null                                              ,
      p_cr_other_ed          =>   null
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '12 process_excise. After jai_cmn_rg_pla_trxs_pkg.insert_row'
                 ||', ln_register_id:'||ln_register_id||', pv_process_message:'||pv_process_message);
    end if;

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
      goto exit_from_procedure;
    end if;

    /* Set variables for Cess Register Entry */
    ln_source_type := 2;
    lv_source_name := lv_register;

  end if;


  /* Recording in Cess Register */
  if ln_register_id is not null and nvl(ln_excise_cess_amt,0) <> 0 then

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '14 process_excise. Before jai_cmn_rg_others_pkg.insert_row');
    end if;

    jai_cmn_rg_others_pkg.insert_row
    (
      p_source_type   =>    ln_source_type                ,
      p_source_name   =>    lv_source_name                ,
      p_source_id     =>    ln_register_id                ,
      p_tax_type      =>    'EXCISE_EDUCATION_CESS'       ,
      debit_amt       =>    ln_excise_cess_amt            ,
      credit_amt      =>    null                          ,
      p_process_flag  =>    pv_process_flag               ,
      p_process_msg   =>    pv_process_message
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '15 process_excise. After jai_cmn_rg_others_pkg.insert_row');
    end if;

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
      goto exit_from_procedure;
    end if;

  end if;

  /* start- budget07 changes */
  if ln_register_id is not null and nvl(ln_sh_excise_cess_amt,0) <> 0 then

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '14.1 process_excise. Before SH jai_cmn_rg_others_pkg.insert_row');
    end if;

    jai_cmn_rg_others_pkg.insert_row
    (
      p_source_type   =>    ln_source_type                ,
      p_source_name   =>    lv_source_name                ,
      p_source_id     =>    ln_register_id                ,
      p_tax_type      =>    jai_constants.tax_type_sh_exc_edu_cess       ,  /*budget07*/
      debit_amt       =>    ln_sh_excise_cess_amt            ,
      credit_amt      =>    null                          ,
      p_process_flag  =>    pv_process_flag               ,
      p_process_msg   =>    pv_process_message
    );

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '15.1 process_excise. After SH jai_cmn_rg_others_pkg.insert_row');
    end if;

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
      goto exit_from_procedure;
    end if;

  end if;
  /* end- budget07 changes */

  if ln_register_id is not null then

    if lv_register = 'RG23A' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_rm_accnt, r_jai_cmn_inventory_orgs1.cenvat_rm_accnt);
    elsif lv_register = 'RG23C' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_cg_accnt, r_jai_cmn_inventory_orgs1.cenvat_cg_accnt);
    elsif lv_register = 'PLA' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_pla_accnt, r_jai_cmn_inventory_orgs1.cenvat_pla_accnt);
    end if;

    if ln_credit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'Excise account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
    end if;

    ln_debit_ccid :=  nvl(r_jai_cmn_inventory_orgs.excise_debit_accnt, r_jai_cmn_inventory_orgs1.excise_debit_accnt);
    if ln_debit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'Excise account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
      null;
    end if;

    /* Process Accounting */
    r_gl_entry.debit_amount         := ln_excise_total;
    r_gl_entry.credit_amount        := ln_excise_total;
    r_gl_entry.debit_ccid           := ln_debit_ccid;                         -- gl_interface.code_combination_id%TYPE,
    r_gl_entry.credit_ccid          := ln_credit_ccid;                        --gl_interface.code_combination_id%TYPE,
    r_gl_entry.regime_code          := 'EXCISE';                              -- varchar2(30),
    r_gl_entry.tax_type             := null;                                  -- varchar2(30),
    /* -- Bug 6012570
       Journal entry source must be a seeded value and hence changing hardcoded Project Accounting string to a Seeded source Receivales India
       for Project Related AR Invoices.  In future when the Project Accounting source is sedded it can be used
    */
    /* r_gl_entry.je_source            := 'Project Accounting';                  -- gl_je_headers.je_source%type, */
    --r_gl_entry.je_source            := 'Receivables India';
    r_gl_entry.je_source            := jai_constants.pa_je_source;  --Added by bgowrava for Bug#6012570
    r_gl_entry.je_category          := jai_constants.je_category_rg_entry;    -- gl_je_headers.je_category%type,
    r_gl_entry.set_of_books_id      := get_sob_id(pr_pa_draft_invoices_all.org_id);        -- gl_sets_of_books.set_of_books_id%type,
    r_gl_entry.currency_code        := jai_constants.func_curr;               -- gl_currencies.currency_code%type,
    r_gl_entry.currency_conv_rate   := null;                                  -- number,
    r_gl_entry.currency_conv_date   := null;                                  -- date,
    r_gl_entry.accounting_date      := trunc(sysdate);                               -- date,
    r_gl_entry.organization_code    := jai_general_pkg.get_organization_code(r_jai_pa_draft_invoices.organization_id);      -- gl_interface.reference1%TYPE,      -- p_params(i).organization_code,
    r_gl_entry.description          := 'India Localization Entry for Project-'||r_jai_pa_draft_invoices.project_id;       -- gl_interface.reference10%TYPE,     -- 'India Localization Entry for Interorg-XFER ',
    r_gl_entry.called_from          := 'jai_pa_billing_pkg.process_excise';           -- gl_interface.reference23%TYPE,     -- 'jai_mtl_trx_pkg.do_cenvat_Acctg',
    r_gl_entry.reference_table      := 'PROJECT_ID:'||r_jai_pa_draft_invoices.project_id;     -- gl_interface.reference24%TYPE,     -- 'jai_mtl_trxs',
    r_gl_entry.reference_column     := 'DRAFT_INVOICE_NUM';                           -- gl_interface.reference25%TYPE,     -- p_transaction_temp_id,
    r_gl_entry.reference_id         := r_jai_pa_draft_invoices.draft_invoice_num;     -- gl_interface.reference26%TYPE,     -- 'transaction_temp_id',
    r_gl_entry.organization_id      := r_jai_pa_draft_invoices.organization_id;       -- gl_interface.reference27%TYPE,      -- to_char(p_params(i).organization_id)
    r_gl_entry.source               := jai_pa_billing_pkg.gv_source_projects;         -- JAI_CMN_JOURNAL_ENTRIES.source%type,
    r_gl_entry.source_table_name    := jai_pa_billing_pkg.gv_draft_invoice_table;     -- JAI_CMN_JOURNAL_ENTRIES.source_table_name%type,
    r_gl_entry.source_document_id   := r_jai_pa_draft_invoices.draft_invoice_id;      -- JAI_CMN_JOURNAL_ENTRIES.source_trx_id%type

    if jai_pa_billing_pkg.gv_debug then
      jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '18 process_excise. Before insert_gl_entry- Excise');
    end if;

    insert_gl_entry(
      pr_gl_entry         => r_gl_entry,
      pv_process_flag     => pv_process_flag,
      pv_process_message  => pv_process_message
    );

    if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
      goto exit_from_procedure;
    end if;

    /* Entry 2 for ExciseEducation Cess */
    ln_debit_ccid   := null;
    ln_credit_ccid  := null;
    if lv_register = 'RG23A' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_edu_cess_rm_accnt,
                                r_jai_cmn_inventory_orgs1.cenvat_edu_cess_rm_accnt);
    elsif lv_register = 'RG23C' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_edu_cess_cg_accnt,
                                r_jai_cmn_inventory_orgs1.cenvat_edu_cess_cg_accnt);
    elsif lv_register = 'PLA' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_pla_accnt,
                                r_jai_cmn_inventory_orgs1.cenvat_pla_accnt);
    end if;

    if ln_credit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'Excise education cess account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
    end if;

    ln_debit_ccid :=  nvl(r_jai_cmn_inventory_orgs.excise_edu_cess_debit_accnt,
                              r_jai_cmn_inventory_orgs1.excise_edu_cess_debit_accnt);
    if ln_debit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'Excise education cess account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
    end if;

    if nvl(ln_excise_cess_amt,0) <> 0 then
      r_gl_entry.debit_amount         := ln_excise_cess_amt;
      r_gl_entry.credit_amount        := ln_excise_cess_amt;
      r_gl_entry.credit_ccid          := ln_credit_ccid;                   --gl_interface.code_combination_id%TYPE,
      r_gl_entry.debit_ccid           := ln_debit_ccid;                 -- gl_interface.code_combination_id%TYPE,
      r_gl_entry.regime_code          := 'EXCISE_EDUCATION_CESS';       -- varchar2(30),

      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '19 process_excise. Before insert_gl_entry- Excise Edu Cess');
      end if;

      insert_gl_entry(
        pr_gl_entry         => r_gl_entry,
        pv_process_flag     => pv_process_flag,
        pv_process_message  => pv_process_message
      );

      if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
        goto exit_from_procedure;
      end if;
    end if;

    /* start- budget07 changes */
    /* Entry 3 for Secondary Higher Excise Education Cess */
    ln_debit_ccid   := null;
    ln_credit_ccid  := null;
    if lv_register = 'RG23A' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.exc_sh_cess_rm_accnt,
                                r_jai_cmn_inventory_orgs1.exc_sh_cess_rm_accnt);
    elsif lv_register = 'RG23C' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.exc_sh_cess_cg_accnt,
                                r_jai_cmn_inventory_orgs1.exc_sh_cess_cg_accnt);
    elsif lv_register = 'PLA' then
      ln_credit_ccid := nvl(r_jai_cmn_inventory_orgs.cenvat_pla_accnt,
                                r_jai_cmn_inventory_orgs1.cenvat_pla_accnt);
    end if;

    if ln_credit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'SH education cess account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
    end if;

    ln_debit_ccid :=  nvl(r_jai_cmn_inventory_orgs.exc_sh_cess_debit_accnt,
                              r_jai_cmn_inventory_orgs1.exc_sh_cess_debit_accnt);
    if ln_debit_ccid is null then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'SH education cess account not defined for '||lv_register
                              ||' register of Org/Loc:'||r_jai_pa_draft_invoices.organization_id
                              ||'/'||r_jai_pa_draft_invoices.location_id;
      goto exit_from_procedure;
    end if;

    if nvl(ln_sh_excise_cess_amt,0) <> 0 then
      r_gl_entry.debit_amount         := ln_sh_excise_cess_amt;
      r_gl_entry.credit_amount        := ln_sh_excise_cess_amt;
      r_gl_entry.credit_ccid          := ln_credit_ccid;                    --gl_interface.code_combination_id%TYPE,
      r_gl_entry.debit_ccid           := ln_debit_ccid;                   -- gl_interface.code_combination_id%TYPE,
      r_gl_entry.regime_code          := jai_constants.tax_type_sh_exc_edu_cess;       -- varchar2(30),

      if jai_pa_billing_pkg.gv_debug then
        jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '19.1 process_excise. Before insert_gl_entry- SH Excise Edu Cess');
      end if;

      insert_gl_entry(
        pr_gl_entry         => r_gl_entry,
        pv_process_flag     => pv_process_flag,
        pv_process_message  => pv_process_message
      );

      if pv_process_flag in (jai_constants.unexpected_error, jai_constants.expected_error, 'E') then
        goto exit_from_procedure;
      end if;
    end if;
    /*end- budget07 changes */

  end if;

  /* Update respective flags on jai_pa_draft_invoices to reflect the excise processing details */
  UPDATE jai_pa_draft_invoices
  SET excise_invoice_no       = lv_excise_inv_no,
      excise_invoice_date     = ld_excise_invoice_date,
      excise_register_type    = lv_register,
      excise_register_id      = ln_register_id,
      basic_excise_amt        = ln_basic_excise_amt,
      additional_excise_amt   = ln_additional_excise_amt,
      other_excise_amt        = ln_other_excise_amt,
      excise_cess_amt         = ln_excise_cess_amt,
      excise_sh_cess_amt      = ln_sh_excise_cess_amt,  /*budget07 */
      process_excise_flag     = 'Y',
      last_update_date        = sysdate,
      last_updated_by         = fnd_global.user_id,
      last_update_login       = fnd_global.login_id
  WHERE draft_invoice_id  = r_jai_pa_draft_invoices.draft_invoice_id;

  if jai_pa_billing_pkg.gv_debug then
    jai_cmn_utils_pkg.print_log ( jai_pa_billing_pkg.file, '20 process_excise. After UPDATE jai_pa_draft_invoices');
  end if;

  << exit_from_procedure >>
  null;

EXCEPTION
  when others then
    pv_process_flag     := jai_constants.unexpected_error;
    pv_process_message  := 'Error in process_excise. Message:'||SQLERRM;

END process_excise;


PROCEDURE check_excise_balance(
  pn_organization_id        IN    JAI_CMN_RG_23AC_II_TRXS.organization_id%type  ,
  pn_location_id            IN    JAI_CMN_RG_23AC_II_TRXS.location_id%type      ,
  pn_basic_excise_amt       IN    number                                   ,
  pn_additional_excise_amt  IN    number                                   ,
  pn_other_excise_amt       IN    number                                   ,
  pn_excise_cess_amt        IN    number                                   ,
  pn_sh_excise_cess_amt     IN    number                                   ,  /*budget07*/
  pv_called_from            IN    varchar2                                 ,
  pv_register               OUT   NOCOPY varchar2                                 ,
  pv_process_flag           OUT   NOCOPY varchar2                                 ,
  pv_process_message        OUT   NOCOPY varchar2
)
IS

  cursor c_jai_cmn_inventory_orgs (cpn_organization_id number, cpn_location_id number) is
    select pref_rg23a
          ,pref_rg23c
          ,pref_pla
          ,nvl(export_oriented_unit ,'N') export_oriented_unit
          ,ssi_unit_flag
     from jai_cmn_inventory_orgs
    where organization_id  =  cpn_organization_id
    and   (
           (cpn_location_id is not null and location_id = cpn_location_id)
           or
           (cpn_location_id is null and (location_id is null or location_id = 0) )
          );

  cursor c_jai_cmn_rg_balances(cpn_organization_id number, cpn_location_id number) is
    select nvl(rg23a_balance,0)           rg23a_balance
          ,nvl(rg23c_balance,0)           rg23c_balance
          ,nvl(pla_balance,0)             pla_balance
          ,nvl(basic_pla_balance,0)       basic_pla_balance
          ,nvl(additional_pla_balance,0)  additional_pla_balance
          ,nvl(other_pla_balance,0)       other_pla_balance
    from  jai_cmn_rg_balances
    where organization_id = cpn_organization_id
    and   location_id = cpn_location_id;

  r_jai_cmn_inventory_orgs     c_jai_cmn_inventory_orgs%rowtype;
  r_jai_cmn_inventory_orgs1    c_jai_cmn_inventory_orgs%rowtype;
  r_jai_cmn_rg_balances               c_jai_cmn_rg_balances%rowtype;

  ln_pref_rg23a                     jai_cmn_inventory_orgs.pref_rg23a%type;
  ln_pref_rg23c                     jai_cmn_inventory_orgs.pref_rg23c%type;
  ln_pref_pla                       jai_cmn_inventory_orgs.pref_pla%type;
  lv_export_oriented_unit           jai_cmn_inventory_orgs.export_oriented_unit%type;
  lv_ssi_unit_flag                  jai_cmn_inventory_orgs.ssi_unit_flag%type;
  ln_delivery_id                    number;
  ln_tot_excise_amt                 number;

BEGIN

  /* Getthe details from the organization, location */
  open  c_jai_cmn_inventory_orgs(pn_organization_id, pn_location_id);
  fetch c_jai_cmn_inventory_orgs into r_jai_cmn_inventory_orgs;
  close c_jai_cmn_inventory_orgs;

  /* Getthe details from the organization, null location */
  open  c_jai_cmn_inventory_orgs(pn_organization_id, null);
  fetch c_jai_cmn_inventory_orgs into r_jai_cmn_inventory_orgs1;
  close c_jai_cmn_inventory_orgs;

  ln_pref_rg23a :=
        nvl(r_jai_cmn_inventory_orgs.pref_rg23a, r_jai_cmn_inventory_orgs1.pref_rg23a);

  ln_pref_rg23c :=
        nvl(r_jai_cmn_inventory_orgs.pref_rg23c, r_jai_cmn_inventory_orgs1.pref_rg23c);

  ln_pref_pla :=
        nvl(r_jai_cmn_inventory_orgs.pref_pla, r_jai_cmn_inventory_orgs1.pref_pla);

  lv_export_oriented_unit :=
        nvl(r_jai_cmn_inventory_orgs.export_oriented_unit,
            r_jai_cmn_inventory_orgs1.export_oriented_unit);

  lv_ssi_unit_flag :=
        nvl(r_jai_cmn_inventory_orgs.ssi_unit_flag, r_jai_cmn_inventory_orgs1.ssi_unit_flag);



  /* Validations */

  /* Projects Draft Invoice Release */
  if pv_called_from = 'jai_pa_billing_pkg.process_excise'  then

    /* for projects, Inventory organization cannot be an export oriented unit */
    if lv_export_oriented_unit = 'Y' then
      pv_process_flag     := jai_constants.expected_error;
      pv_process_message  := 'Inventory organization cannot be an export oriented unit';
      pv_register         := 'ERROR';
      goto exit_from_procedure;
    end if;

  end if;

  ln_tot_excise_amt := nvl(pn_basic_excise_amt,0) + nvl(pn_additional_excise_amt,0) + nvl(pn_other_excise_amt,0);

  open  c_jai_cmn_rg_balances(pn_organization_id, pn_location_id);
  fetch c_jai_cmn_rg_balances into r_jai_cmn_rg_balances;
  close c_jai_cmn_rg_balances;

  pv_register := jai_om_wsh_processing_pkg.excise_balance_check (
                      p_pref_rg23a                    =>  ln_pref_rg23a                                     ,
                      p_pref_rg23c                    =>  ln_pref_rg23c                                     ,
                      p_pref_pla                      =>  ln_pref_pla                                       ,
                      p_ssi_unit_flag                 =>  lv_ssi_unit_flag                                  ,
                      p_tot_excise_amt                =>  ln_tot_excise_amt                                 ,
                      p_rg23a_balance                 =>  r_jai_cmn_rg_balances.rg23a_balance                 ,
                      p_rg23c_balance                 =>  r_jai_cmn_rg_balances.rg23c_balance                 ,
                      p_pla_balance                   =>  r_jai_cmn_rg_balances.pla_balance                   ,
                      p_basic_pla_balance             =>  r_jai_cmn_rg_balances.basic_pla_balance             ,
                      p_additional_pla_balance        =>  r_jai_cmn_rg_balances.additional_pla_balance        ,
                      p_other_pla_balance             =>  r_jai_cmn_rg_balances.other_pla_balance             ,
                      p_basic_excise_duty_amount      =>  pn_basic_excise_amt                               ,
                      p_add_excise_duty_amount        =>  pn_additional_excise_amt                          ,
                      p_oth_excise_duty_amount        =>  pn_other_excise_amt                               ,
                      p_export_oriented_unit          =>  lv_export_oriented_unit                           ,
                      p_register_code                 =>  null                                              ,
                      p_delivery_id                   =>  ln_delivery_id  /* used for OM only */            ,
                      p_organization_id               =>  pn_organization_id                                ,
                      p_location_id                   =>  pn_location_id                                    ,
                      p_cess_amount                   =>  pn_excise_cess_amt                                ,
                      p_sh_cess_amount                =>  pn_sh_excise_cess_amt                             , /*budget07*/
                      p_process_flag                  =>  pv_process_flag                                   ,
                      p_process_msg                   =>  pv_process_message
                  );

  << exit_from_procedure >>
  return ;

EXCEPTION
  when others then
    pv_process_flag     := jai_constants.unexpected_error;
    pv_process_message  := 'Error in check_excise_balance. Message:'||sqlerrm;

END check_excise_balance;

/*------------------------------------------------------------------------------------------------------------*/

              -------------------------------------------------------------------------------------
              --  The following procedures in this package are retained for future usage and are --
              --  not currently in use                                                           --
              --  import_taxes_to_payables                                                       --
              --  update_payment_schedule                                                        --
              --  update_mrc_data                                                                --
              --  insert_mrc_data                                                                --
              --  This procedure were coded for supporting InterProject functionality            --
              -------------------------------------------------------------------------------------

  procedure import_taxes_to_payables
  --
  --  This procedure imports the taxes from project draft invoice (jai_cmn_document_taxes) to
  --  payables (ap_invoice_distributions_all)
  --
  ( errbuf OUT NOCOPY varchar2
  , retcode OUT NOCOPY number
  , pn_request_id   in    ap_invoice_distributions_all.request_id%type
  , pn_invoice_id   in    ap_invoice_distributions_all.invoice_id%type
  , pv_event        in    varchar2
  )
  is
  begin  null; -- Please remove this line and un-comment the code to use this procedure
    /*
    ln_ap_invoice_distirbution_id       ap_invoice_distributions_all.invoice_distribution_id%type;
    ln_dist_line_num                    ap_invoice_distributions_all.distribution_line_number%type;
    ln_project_id                       ap_invoice_distributions_all.project_id%type;
    ln_task_id                          ap_invoice_distributions_all.task_id%type;
    lv_exp_type                         ap_invoice_distributions_all.expenditure_type%type;
    ld_exp_item_date                    ap_invoice_distributions_all.expenditure_item_date%type;
    ln_exp_organization_id              ap_invoice_distributions_all.expenditure_organization_id%type;
    lv_project_accounting_context       ap_invoice_distributions_all.project_accounting_context%type;
    lv_pa_addition_flag                 ap_invoice_distributions_all.pa_addition_flag%type;
    lv_assets_tracking_flag             ap_invoice_distributions_all.assets_tracking_flag%type;
    ln_service_rgm_id                   JAI_RGM_DEFINITIONS.regime_id%type;
    lv_dist_code_combination_id         ap_invoice_distributions_all.dist_code_combination_id%type;
    ln_lines_to_insert                  number;
    ln_nrec_tax_amt                     number;
    ln_rec_tax_amt                      number;
    ln_tax_amt                          number;
    ln_func_tax_amt                     number;
    ln_cum_tax_amt                      number;
    lv_modvat_flag                      ja_in_ap_tax_distributions.recoverable_flag%type;
    ln_precision                        fnd_currencies.precision%type;
    is_upd_pay_sch_success              boolean;
    lv_account_name                     jai_rgm_regns.attribute_code%type;
    ln_tax_variance_inv_cur             number;
    ln_user_id                          fnd_user.user_id%type     :=  fnd_global.user_id;
    ln_login_id                         fnd_logins.login_id%type  := fnd_global.login_id;
    ln_request_id                       number;
    ln_program_application_id           number;
    ln_program_id                       number;

    cursor c_get_invoices
    is
      select  invoice_id
            , batch_id
            , nvl(exchange_rate, 1) exchange_rate
            , invoice_currency_code
      from    ap_invoices_all
      where   invoice_id in ( select distinct apd.invoice_id
                              from   ap_invoice_distributions_all apd
                              where  ( (pn_request_id is not null and apd.request_id = pn_request_id)
                                    or (pn_invoice_id is not null and apd.invoice_id = pn_invoice_id)
                                     )
                            )
      order by invoice_id;

    cursor c_get_inv_distributions (cpn_invoice_id   ap_invoice_distributions_all.invoice_id%type)
    is
      select  accounting_date
            , accts_pay_code_combination_id
            , amount
            , assets_addition_flag
            , assets_tracking_flag
            , attribute1
            , attribute2
            , attribute3
            , created_by
            , creation_date
            , dist_code_combination_id
            , exchange_date
            , exchange_rate
            , exchange_rate_type
            , expenditure_item_date
            , expenditure_organization_id
            , expenditure_type
            , invoice_distribution_id
            , last_update_date
            , last_update_login
            , last_updated_by
            , matched_uom_lookup_code
            , pa_addition_flag
            , pa_cc_ar_invoice_id
            , pa_cc_ar_invoice_line_num
            , period_name
            , po_distribution_id
            , price_var_code_combination_id
            , program_application_id
            , program_id
            , program_update_date
            , project_accounting_context
            , project_id
            , rcv_transaction_id
            , set_of_books_id
            , task_id
      from   ap_invoice_distributions_all
      where  line_type_lookup_code in ('LINE', 'MISCELLANEOUS')
      and    invoice_id = cpn_invoice_id;

    cursor c_get_max_dist_line_num (cpn_invoice_id  ap_invoice_distributions_all.invoice_id%type)
    is
    select max(distribution_line_number)
    from   ap_invoice_distributions_all
    where  invoice_id = cpn_invoice_id;

    cursor c_get_pa_hdr_from_ar_ref ( cpn_pa_cc_ar_invoice_id   ap_invoice_distributions_all.pa_cc_ar_invoice_id%type)
    is
      select  jpdi.organization_id
            , jpdi.location_id
            , pdi.system_reference
            , pdi.project_id
            , pdi.draft_invoice_num
      from  jai_pa_draft_invoices jpdi
           ,pa_draft_invoices     pdi
      where pdi.project_id = jpdi.project_id
      and   pdi.draft_invoice_num = jpdi.draft_invoice_num
      and   pdi.system_reference = cpn_pa_cc_ar_invoice_id;

    r_pa_hdr  c_get_pa_hdr_from_ar_ref%rowtype;

    cursor c_get_taxes_from_ar_ref (cpn_project_id         jai_pa_draft_invoices.project_id%type
                                   ,cpn_draft_invoice_num  jai_pa_draft_invoices.draft_invoice_num%type
                                   ,cpn_ar_invoice_line_num  ap_invoice_distributions_all.pa_cc_ar_invoice_line_num%type
                                   )
    is
      select   jcdt.tax_id
             , jcdt.modvat_flag
             , jcdt.tax_amt
             , jcdt.doc_tax_id
      from   jai_pa_draft_invoice_lines jpdil
            ,jai_cmn_document_taxes     jcdt
      where  jpdil.project_id        =  cpn_project_id
      and    jpdil.draft_invoice_num =  cpn_draft_invoice_num
      and    jpdil.line_num          =  cpn_ar_invoice_line_num
      and    jpdil.draft_invoice_line_id = jcdt.source_doc_line_id
      and    jcdt.source_doc_type   = jai_constants.pa_draft_invoice;

      r_pa_tax    c_get_taxes_from_ar_ref%rowtype;

    cursor c_tax_details (cpn_tax_id  ja_in_tax_codes.tax_id%type)
    is
      select  tax_name
             ,tax_account_id
             ,mod_cr_percentage
             ,adhoc_flag
             ,nvl(tax_rate, -1) tax_rate
             ,tax_type
             ,rounding_factor
      from   ja_in_tax_codes
      where  tax_id = cpn_tax_id;

    r_tax_details   c_tax_details%rowtype ;

    cursor c_get_regime_id (cpv_regime_code JAI_RGM_DEFINITIONS.regime_code%type)
    is
      select regime_id
      from   JAI_RGM_DEFINITIONS
      where  regime_code = cpv_regime_code;

    cursor c_get_rgm_for_tax_type (cpv_tax_type     varchar2)
    is
     select regime_code
            ,regime_id
     from   jai_regime_tax_types_v
     where  tax_type = cpv_tax_type;

     r_regime  c_get_rgm_for_tax_type%rowtype;

    cursor c_get_invoice_distribution
    is
    select ap_invoice_distributions_s.nextval
    from   dual;


  begin

   if pv_event not in (jai_constants.IMPORT_TAXES) then
     return;
   end if;

    begin --> attempt_to_lock

      -- Lock the rows to get the maximum sequence number
      update ap_invoice_distributions_all apd
      set    last_update_date = last_update_date
      where  ( (pn_request_id is not null and apd.request_id = pn_request_id)
            or (pn_invoice_id is not null and apd.invoice_id = pn_invoice_id)
             );

    exception --> attempt_to_lock

      when others then
      errbuf := 'Unable to lock the distributions to get the next distributions number';
      retcode := 2;
      return;

    end ; --> attempt_to_lock

    for r_invs in c_get_invoices
    loop

      for r_inv_dist in c_get_inv_distributions (r_invs.invoice_id)
      loop

        if r_pa_hdr.system_reference is null
        or r_pa_hdr.system_reference  <> r_inv_dist.pa_cc_ar_invoice_id then

          open  c_get_pa_hdr_from_ar_ref (cpn_pa_cc_ar_invoice_id => r_inv_dist.pa_cc_ar_invoice_id);
          fetch c_get_pa_hdr_from_ar_ref into r_pa_hdr;
          close c_get_pa_hdr_from_ar_ref ;

        end if;
        -- get the maximum distribution line number
        open  c_get_max_dist_line_num (cpn_invoice_id => r_invs.invoice_id);
        fetch c_get_max_dist_line_num into ln_dist_line_num;
        close c_get_max_dist_line_num;

        -- Get project taxes using AR Invoice reference
        for  r_pa_tax in c_get_taxes_from_ar_ref
                                ( cpn_project_id          => r_pa_hdr.project_id
                                , cpn_draft_invoice_num   => r_pa_hdr.draft_invoice_num
                                , cpn_ar_invoice_line_num => r_inv_dist.pa_cc_ar_invoice_line_num
                                )
        loop

          -- Initialize variables
          ln_project_id           := null;
          ln_task_id              := null;
          lv_exp_type             := null;
          ld_exp_item_date        := null;
          ln_exp_organization_id  := null;
          lv_project_accounting_context := null;
          lv_pa_addition_flag           := null;

          lv_dist_code_combination_id := null;
          lv_assets_tracking_flag := null;
          ln_tax_amt      :=  null;
          ln_rec_tax_amt  :=  null;
          ln_nrec_tax_amt :=  null;
          ln_lines_to_insert := null;

          -- Get tax details for tax_id
          open  c_tax_details (r_pa_tax.tax_id);
          fetch c_tax_details into  r_tax_details;
          close c_tax_details;

          lv_assets_tracking_flag     := r_inv_dist.assets_tracking_flag;
          lv_dist_code_combination_id := null;

          if r_pa_tax.modvat_flag = jai_constants.YES
          and nvl(r_tax_details.mod_cr_percentage, -1) > 0 then

            -- recoverable tax
            lv_assets_tracking_flag := jai_constants.NO;

            open  c_get_rgm_for_tax_type ( r_tax_details.tax_type);
            fetch c_get_rgm_for_tax_type into r_regime;
            close c_get_rgm_for_tax_type;

            if r_regime.regime_code  = jai_constants.service_regime then

              -- Service type of tax
              lv_account_name := jai_constants.recovery_interim;

            elsif r_regime.regime_code  = jai_constants.vat_regime
            then

              lv_account_name := jai_constants.recovery;

            end if;

            if r_regime.regime_code in (jai_constants.service_regime, jai_constants.vat_regime)
            then

              lv_dist_code_combination_id := jai_rgm_trx_recording_pkg.get_account
              (
               p_regime_id            =>      r_regime.regime_id,
               p_organization_type    =>      jai_constants.orgn_type_io,
               p_organization_id      =>      r_pa_hdr.organization_id ,
               p_location_id          =>      r_pa_hdr.location_id,
               p_tax_type             =>      r_tax_details.tax_type,
               p_account_name         =>      jai_constants.recovery  -- RECOVERY
              );

            else
              -- Tax is other than of VAT or Serivce regime
              lv_dist_code_combination_id :=  r_tax_details.tax_account_id;
            end if;

          else  --> r_pa_tax.modvat_flag = jai_constants.YES ...

            ln_project_id                 := r_inv_dist.project_id;
            ln_task_id                    := r_inv_dist.task_id;
            lv_exp_type                   := r_inv_dist.expenditure_type;
            ld_exp_item_date              := r_inv_dist.expenditure_item_date;
            ln_exp_organization_id        := r_inv_dist.expenditure_organization_id;
            lv_project_accounting_context := r_inv_dist.project_accounting_context;
            lv_pa_addition_flag           := r_inv_dist.pa_addition_flag;

          end if;

          if lv_dist_code_combination_id is null then
            lv_dist_code_combination_id := r_inv_dist.dist_code_combination_id;
          end if;

          ln_tax_amt      := r_pa_tax.tax_amt;
          ln_rec_tax_amt  := null;
          ln_nrec_tax_amt := null;
          ln_lines_to_insert := 1; -- Loop controller to insert more than one lines for partially recoverable tax lines in PO

          Fnd_File.put_line(Fnd_File.LOG, 'r_pa_tax.modvat_flag ='||r_pa_tax.modvat_flag
                                        ||',r_tax_details.mod_cr_percentage='||r_tax_details.mod_cr_percentage
                           );

          if r_pa_tax.modvat_flag = jai_constants.YES
          and nvl(r_tax_details.mod_cr_percentage, -1) > 0
          and nvl(r_tax_details.mod_cr_percentage, -1) < 100
          then
            --
            -- Tax line is for partial Recoverable tax.  Hence split amount into two parts, Recoverable and Non-Recoverable
            -- and instead of one line, two lines needs to be inserted.
            -- For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100) there will be only one line inserted
            --
            ln_lines_to_insert := 2;
            ln_rec_tax_amt  := nvl(ln_tax_amt,0) * (r_tax_details.mod_cr_percentage/100) ;
            ln_nrec_tax_amt := nvl(ln_tax_amt,0) - nvl(ln_rec_tax_amt,0);

          end if;
          fnd_file.put_line(fnd_file.log, 'ln_lines_to_insert='||ln_lines_to_insert||
                                          ',ln_rec_tax_amt='||ln_rec_tax_amt          ||
                                          ',ln_nrec_tax_amt='||ln_nrec_tax_amt
                           );

          --
          --  If a line has a partially recoverable tax the following loop will be executed twice.  First line will always be for a
          --  non recoverable tax amount and the second line will be for a recoverable tax amount
          --  For ordinary lines (with modvat_flag = 'N' or with mod_cr_percentage = 100 fully recoverable) the variable
          --  ln_lines_to_insert will have value of 1 and hence only one line will be inserted with full tax amount
          --

          for line in 1..ln_lines_to_insert
          loop

            if line = 1 then

              ln_tax_amt     := nvl(ln_rec_tax_amt, ln_tax_amt);
              lv_modvat_flag := r_pa_tax.modvat_flag ;

            elsif line = 2 then

              ln_tax_amt := ln_nrec_tax_amt;

              if r_inv_dist.assets_tracking_flag = jai_constants.YES then
                lv_assets_tracking_flag := jai_constants.YES;
              end if;

              lv_modvat_flag := jai_constants.NO ;

              --
              -- This is a non recoverable line hence the tax amounts should be added into the project costs by populating
              -- projects related columns so that PROJECTS can consider this line for Project Costing
              --
              ln_project_id                 := r_inv_dist.project_id;
              ln_task_id                    := r_inv_dist.task_id;
              lv_exp_type                   := r_inv_dist.expenditure_type;
              ld_exp_item_date              := r_inv_dist.expenditure_item_date;
              ln_exp_organization_id        := r_inv_dist.expenditure_organization_id;
              lv_project_accounting_context := r_inv_dist.project_accounting_context;
              lv_pa_addition_flag           := r_inv_dist.pa_addition_flag;

              -- For non recoverable line charge account should be same as of the parent line
              lv_dist_code_combination_id  :=  r_inv_dist.dist_code_combination_id;

            end if;

            fnd_file.put_line(fnd_file.log, 'Before insert into jai_ap_source_doc_taxes ');

            open  gc_fnd_curr_precision  (r_invs.invoice_currency_code);
            fetch gc_fnd_curr_precision into ln_precision;
            close gc_fnd_curr_precision;

            if ln_precision is null then
              ln_precision := 0;
            end if;

            fnd_file.put_line(fnd_file.log,
            'Before inserting into ap_invoice_distributions_all for distribution line no :'|| ln_dist_line_num);

            ln_request_id                 := fnd_profile.value ('CONC_REQUEST_ID');
            ln_program_application_id     := r_inv_dist.program_application_id;
            ln_program_id                 := r_inv_dist.program_id;
            ln_dist_line_num              := ln_dist_line_num + 1;

            open  c_get_invoice_distribution;
            fetch c_get_invoice_distribution into ln_ap_invoice_distirbution_id;
            close c_get_invoice_distribution;

            insert into ap_invoice_distributions_all
            (
             accounting_date
            ,accrual_posted_flag
            ,assets_addition_flag
            ,assets_tracking_flag
            ,cash_posted_flag
            ,distribution_line_number
            ,dist_code_combination_id
            ,invoice_id
            ,last_updated_by
            ,last_update_date
            ,line_type_lookup_code
            ,period_name
            ,set_of_books_id
            ,amount
            ,base_amount
            ,batch_id
            ,created_by
            ,creation_date
            ,description
            ,exchange_rate_variance
            ,last_update_login
            ,match_status_flag
            ,posted_flag
            ,rate_var_code_combination_id
            ,reversal_flag
            ,exchange_date
            ,exchange_rate
            ,exchange_rate_type
            ,price_adjustment_flag
            ,program_application_id
            ,program_id
            ,program_update_date
            ,accts_pay_code_combination_id
            ,attribute1
            ,invoice_distribution_id
            ,quantity_invoiced
            ,attribute2
            ,attribute3
            ,po_distribution_id
            ,rcv_transaction_id
            ,price_var_code_combination_id
            ,invoice_price_variance
            ,base_invoice_price_variance
            ,matched_uom_lookup_code
            ,project_id
            ,task_id
            ,expenditure_type
            ,expenditure_item_date
            ,expenditure_organization_id
            ,project_accounting_context
            ,pa_addition_flag
            )
            values
            (
              r_inv_dist.accounting_date
            , jai_constants.NO
            , r_inv_dist.assets_addition_flag
            , lv_assets_tracking_flag
            , jai_constants.NO
            , ln_dist_line_num
            , lv_dist_code_combination_id
            , r_invs.invoice_id
            , r_inv_dist.last_updated_by
            , r_inv_dist.last_update_date
            , 'MISCELLANEOUS'
            , r_inv_dist.period_name
            , r_inv_dist.set_of_books_id
            , round(round( ln_tax_amt, r_tax_details.rounding_factor), ln_precision)
            , round(round((ln_tax_amt * r_inv_dist.exchange_rate), r_tax_details.rounding_factor), ln_precision)
            , r_invs.batch_id
            , r_inv_dist.created_by
            , r_inv_dist.creation_date
            , r_tax_details.tax_name
            , null
            , r_inv_dist.last_update_login
            , null
            , jai_constants.NO
            , null
            , null
            , r_inv_dist.exchange_date
            , r_inv_dist.exchange_rate
            , r_inv_dist.exchange_rate_type
            , jai_constants.NO
            , r_inv_dist.program_application_id
            , r_inv_dist.program_id
            , r_inv_dist.program_update_date
            , r_inv_dist.accts_pay_code_combination_id
            , r_inv_dist.attribute1
            , ln_ap_invoice_distirbution_id
            , -1
            , r_inv_dist.attribute2
            , r_inv_dist.attribute3
            , r_inv_dist.po_distribution_id
            , r_inv_dist.rcv_transaction_id
            , r_inv_dist.price_var_code_combination_id
            , null
            , null
            , r_inv_dist.matched_uom_lookup_code
            , ln_project_id
            , ln_task_id
            , lv_exp_type
            , ld_exp_item_date
            , ln_exp_organization_id
            , lv_project_accounting_context
            , lv_pa_addition_flag
            );

            insert into jai_ap_source_doc_taxes
            ( invoice_id
             ,invoice_distribution_id
             ,parent_invoice_distribution_id
             ,doc_tax_id
             ,tax_amt
             ,func_tax_amt
             ,recoverable_flag
             ,created_by
             ,creation_date
             ,last_updated_by
             ,last_update_date
             ,last_update_login
             ,request_id
             ,program_application_id
             ,program_id
             ,program_update_date
            )
            values
            ( r_invs.invoice_id
            , ln_ap_invoice_distirbution_id
            , r_inv_dist.invoice_distribution_id
            , r_pa_tax.doc_tax_id
            , round(round( ln_tax_amt, r_tax_details.rounding_factor), ln_precision)
            , round(round((ln_tax_amt * r_inv_dist.exchange_rate), r_tax_details.rounding_factor), ln_precision)
            , lv_modvat_flag
            , ln_user_id
            , sysdate
            , ln_user_id
            , sysdate
            , ln_login_id
            , ln_request_id
            , ln_program_application_id
            , ln_program_id
            , sysdate
            );

            insert_mrc_data(ln_ap_invoice_distirbution_id);

            ln_cum_tax_amt := ln_cum_tax_amt + round(round( ln_tax_amt, r_tax_details.rounding_factor), ln_precision);

          end loop; -- ln_lines_to_insert

        end loop; --> for r_pa_tax

      end loop; --> for r_inv_dist

      -- Invoice level proessing
      is_upd_pay_sch_success := update_payment_schedule(r_invs.invoice_id, ln_cum_tax_amt);

      update ap_invoices_all
      set   invoice_amount       =  invoice_amount   + ln_cum_tax_amt,
            approved_amount      =  approved_amount  + ln_cum_tax_amt,
            pay_curr_invoice_amount =  pay_curr_invoice_amount + ln_cum_tax_amt,
            amount_applicable_to_discount =  amount_applicable_to_discount + ln_cum_tax_amt,
            payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
      where  invoice_id = r_invs.invoice_id;

      update_mrc_data (r_invs.invoice_id) ;

    end loop; --> for r_invs

  */
  end import_taxes_to_payables;


  /*------------------------------------------------------------------------------------------------------------*/

  function update_payment_schedule (p_invoice_id  ap_invoices_all.invoice_id%type, p_total_tax NUMBER)
  return boolean is

    v_total_tax_in_payment  number;
    v_tax_installment       number;
    v_payment_num           ap_payment_schedules_all.payment_num%type;
    v_total_payment_amt     number;
    v_diff_tax_amount       number;
    ln_precision            fnd_currencies.precision%type;


    cursor  c_total_payment_amt is
    select  sum(gross_amount)
    from    ap_payment_schedules_all
    where   invoice_id = p_invoice_id;

    cursor c_get_inv_currency
    is
      select invoice_currency_code
      from   ap_invoices_all
      where  invoice_id = p_invoice_id;

    r_inv_curr   c_get_inv_currency%rowtype;

  begin

    fnd_file.put_line(fnd_file.log, 'start of function  update_payment_schedule');

    open    c_total_payment_amt;
    fetch   c_total_payment_amt into v_total_payment_amt;
    close   c_total_payment_amt;

    if nvl(v_total_payment_amt, -1) = -1 then
      Fnd_File.put_line(Fnd_File.LOG, 'Cannot update payment schedule, total payment amount :'
                                      || to_char(v_total_payment_amt));
      return false;
    end if;

    v_total_tax_in_payment := -1;

    open  c_get_inv_currency;
    fetch c_get_inv_currency into r_inv_curr;
    close c_get_inv_currency;

    open  gc_fnd_curr_precision  (r_inv_curr.invoice_currency_code);
    fetch gc_fnd_curr_precision into ln_precision;
    close gc_fnd_curr_precision;

    for c_installments
    in    ( select   gross_amount
                    ,payment_num
            from    ap_payment_schedules_all
            where   invoice_id = p_invoice_id
            order by payment_num
          )
    loop

      v_tax_installment := -1 ;
      v_payment_num  :=  c_installments.payment_num;

      v_tax_installment := p_total_tax * (c_installments.gross_amount / v_total_payment_amt);

      v_tax_installment := round(v_tax_installment, ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        =  gross_amount          + v_tax_installment,
             amount_remaining    =  amount_remaining      + v_tax_installment,
             inv_curr_gross_amount = inv_curr_gross_amount + v_tax_installment,
             payment_status_flag = decode(payment_status_flag, 'Y', 'P', payment_status_flag)
      where  invoice_id = p_invoice_id
      and    payment_num = v_payment_num;
      v_total_tax_in_payment := v_total_tax_in_payment + v_tax_installment;

    end loop;

    -- any difference in tax because of rounding has to be added to the last installment.
    if v_total_tax_in_payment <> p_total_tax then

      v_diff_tax_amount := round( p_total_tax - v_total_tax_in_payment,ln_precision);

      update ap_payment_schedules_all
      set    gross_amount        = gross_amount            + v_diff_tax_amount,
             amount_remaining      = amount_remaining      + v_diff_tax_amount,
             inv_curr_gross_amount = inv_curr_gross_amount + v_diff_tax_amount
      where  invoice_id = p_invoice_id
      and    payment_num = v_payment_num;

    end if;

    return true;

  exception
    when others then
      Fnd_File.put_line(Fnd_File.LOG, 'exception from function  update_payment_schedule');
      Fnd_File.put_line(Fnd_File.LOG, sqlerrm);
      return false;
  end update_payment_schedule;

  /*------------------------------------------------------------------------------------------------------------*/

  procedure update_mrc_data (p_invoice_id ap_invoices_all.invoice_id%type)
  is
    v_mrc_string VARCHAR2(10000);
  begin
      v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data (
      p_operation_mode    => ''UPDATE'',
      p_table_name        => ''AP_INVOICES_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax amount added to invoice header (Distribution_matching procedure)''
       ); END;';

      execute immediate v_mrc_string using p_invoice_id;

  exception
    when others then
    if sqlcode = -6551 then -- object referred in EXECUTE IMMEDIATE is not available in the database
      fnd_file.put_line(fnd_file.log, 'mrc api is not existing(update)');
    else
      fnd_file.put_line(fnd_file.log, 'mrc api exists and different err(update)->'||sqlerrm);
      raise;
    end if;
  end update_mrc_data;

/*------------------------------------------------------------------------------------------------------------*/
  procedure insert_mrc_data (p_invoice_distribution_id number)
  is
    v_mrc_string VARCHAR2(10000);
  begin

      v_mrc_string := 'BEGIN AP_MRC_ENGINE_PKG.Maintain_MRC_Data (
      p_operation_mode    => ''INSERT'',
      p_table_name        => ''AP_INVOICE_DISTRIBUTIONS_ALL'',
      p_key_value         => :a,
      p_key_value_list    => NULL,
      p_calling_sequence  =>
      ''India Local Tax line as Miscellaneous distribution line (Distribution_matching procedure)''
       ); END;';

      execute immediate v_mrc_string using p_invoice_distribution_id;

  -- Vijay Shankar for bug#3461030
  exception
    when others then
    if sqlcode = -6550 then
      -- object referred in execute immediate is not available in the database
      null;
      FND_FILE.put_line(FND_FILE.log, '*** MRC API is not existing(insert)');
    ELSE
      FND_FILE.put_line(FND_FILE.log, 'MRC API exists and different err(insert)->'||SQLERRM);
      RAISE;
    END IF;
  end insert_mrc_data;

/*------------------------------------------------------------------------------------------------------------*/

end jai_pa_billing_pkg;

/

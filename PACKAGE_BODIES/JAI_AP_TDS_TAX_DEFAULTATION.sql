--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_TAX_DEFAULTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_TAX_DEFAULTATION" AS
/* $Header: jai_ap_tds_dflt.plb 120.5.12010000.7 2009/12/29 09:08:06 erma ship $ */

/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_tax_defaultation_pkg_b.sql

 Created By    : Aparajita

 Created Date  : 24-dec-2004

 Bug           :

 Purpose       : Implementation of tax defaultation functionality on AP invoice.

 Called from   : Trigger ja_in_ap_aia_after_trg
                 Trigger ja_in_ap_aida_after_trg

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        24/12/2004   Aparajita for bug#4088186. version#115.0. TDS Clean Up.

                        Created this package for implementing the tax defaultation
                        functionality onto AP invoice.

2.         2/05/2005   rchandan for bug#4323338. Version 116.0
                        India Org Info DFF is eliminated as a part of JA migration. A table by name ja_in_ap_tds_org_tan is dropped
                        and a view jai_ap_tds_org_tan_v is created to capture the PAN No,TAN NO and WARD NO. The code changes are done
                        to refer to the new view instead of the dropped table.


3.         08-Jun-2005  Version 116.1 jai_ap_tds_dflt -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                        as required for CASE COMPLAINCE.

3.         14-Jun-2005  rchandan for bug#4428980, Version 116.2
                        Modified the object to remove literals from DML statements and CURSORS.

4.         24-jun-2005  Aparajita for /* AP lines uptake

5.         29-Jun-2005  ssumaith - bug#4448789 - removal of hr_operating_units.legal_entity_id from this trigger.

6.         29-Jul-2005  Bug4522540. Added by Lakshmi Gopalsami Version 120.3
                        Start date and end date of a threshold type was not
			being considered while selecting the applicable
			threshold. This has been modified  to check
			threshold validity date range against the GL_date of
                        invoice distributions

			Dependency(Functional)
			----------------------
			jai_ap_tds_gen.plb Version 120.4

7.   21-Dec-2007  Sanjikum for Bug#6708042, Version 120.5
                  Obsoleted the changes done for verion 120.4 and rechecked in the version 120.3 as 120.5

8.      07/Jul/2009    Bgowrava for  Bug 5911913 . File Version 120.3.12000000.9
 	                         Added two parameters
 	                         (1) p_old_input_dff_value_wct
 	                         (2) p_old_input_dff_value_essi
 	                         in procedure processs_invoice.
 	                         Added a check to set the value of lv_user_deleted_flag
 	                         for section_type in ('WCT_SECTION' and 'ESSI_SECTION')

9.     18-DEC-2009     Code modified by Eric Ma for PF bug#7340818
---------------------------------------------------------------------------- */

  procedure process_invoice
 (
   p_invoice_id                         in                 number,
   p_invoice_line_number                in                 number    default   null,
   p_invoice_distribution_id            in                 number    default   null,
   p_line_type_lookup_code              in                 varchar2,
   p_distribution_line_number           in                 number,
   p_parent_reversal_id                 in                 number,
   p_reversal_flag                      in                 varchar2,
   p_amount                             in                 number,
   p_invoice_currency_code              in                 varchar2,
   p_exchange_rate                      in                 number,
   p_set_of_books_id                    in                 number,
   p_po_distribution_id                 in                 number    default   null,
   p_rcv_transaction_id                 in                 number    default   null,
   p_vendor_id                          in                 number,
   p_vendor_site_id                     in                 number,
   p_input_dff_value_tds                in                 varchar2,
   p_input_dff_value_wct                in                 varchar2,
   p_old_input_dff_value_wct            in                 varchar2,  --Added by Bgowrava for Bug#5911913
   p_input_dff_value_essi               in                 varchar2,
   p_old_input_dff_value_essi           in                 varchar2,  --Added by Bgowrava for Bug#5911913
   p_org_id                             in                 number,
   p_accounting_date                    in                 date,
   p_call_from                          in                 varchar2,
   p_final_tds_tax_id                   out      nocopy    number,
   p_process_flag                       out      nocopy    varchar2,
   p_process_message                    out      nocopy    varchar2,
   p_codepath                           in out   nocopy    varchar2
  )
  is

      cursor c_gl_sets_of_books(cp_set_of_books_id  number) is
        select currency_code
        from   gl_sets_of_books
        where  set_of_books_id = cp_set_of_books_id;

      r_gl_sets_of_books                          c_gl_sets_of_books%rowtype;

      lv_default_tds_section_code                 jai_ap_tds_inv_taxes.default_section_code%type;
      ln_default_tds_tax_id                       jai_ap_tds_inv_taxes.default_tax_id%type;
      lv_default_from                             jai_ap_tds_inv_taxes.default_from%type;
      lv_default_type                             jai_ap_tds_inv_taxes.default_type%type;
      ln_exchange_rate                            ap_invoices_all.exchange_rate%type;


  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.process_invoice', 'START'); /* 1 */
    /* Check if defaulting can happen for the invoice */

    validate_status_for_default
    (
      p_invoice_id                      =>     p_invoice_id,
      p_invoice_line_number             =>     p_invoice_line_number,
      p_invoice_distribution_id         =>     p_invoice_distribution_id,
      p_line_type_lookup_code           =>     p_line_type_lookup_code,
      p_process_flag                    =>     p_process_flag,
      P_process_message                 =>     P_process_message,
      p_codepath                        =>     p_codepath
    );

    if nvl(p_process_flag, 'N') <> 'Y' then
      /* p_process_flag has the value of Y whenever TDS defaultation can take place */
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      goto exit_from_procedure;
    end if;

    open c_gl_sets_of_books(p_set_of_books_id);
    fetch c_gl_sets_of_books into r_gl_sets_of_books;
    close c_gl_sets_of_books;

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    if r_gl_sets_of_books.currency_code <> p_invoice_currency_code then
      /* Foreign currency invoice */
      p_codepath := jai_general_pkg.plot_codepath(3.1, p_codepath); /* 3.1 */
      ln_exchange_rate := p_exchange_rate;
    end if;

    ln_exchange_rate := nvl(ln_exchange_rate, 1);


    if p_input_dff_value_wct is not null or
 	   p_old_input_dff_value_wct is not null then   --Added by Bgowrava for Bug#5911913

      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

      populate_localization_inv_tax
      (
        p_invoice_id                      =>     p_invoice_id,
        p_invoice_line_number             =>     p_invoice_line_number,
        p_invoice_distribution_id         =>     p_invoice_distribution_id,
        P_distribution_line_number        =>     P_distribution_line_number,
        p_amount                          =>     p_amount,
        p_exchange_rate                   =>     ln_exchange_rate,
        p_section_type                    =>     'WCT_SECTION',
        p_default_type                    =>     null,
        p_default_section_code            =>     null,
        p_default_tax_id                  =>     null,
        p_input_dff_value                 =>     p_input_dff_value_wct,
        p_default_from                    =>     null,
        p_vendor_id                       =>     p_vendor_id,
        p_vendor_site_id                  =>     p_vendor_site_id,
        p_org_id                          =>     p_org_id,
        p_accounting_date                 =>     p_accounting_date,
        p_final_tds_tax_id                =>     p_final_tds_tax_id,
        p_process_flag                    =>     p_process_flag,
        P_process_message                 =>     P_process_message,
        p_codepath                        =>     p_codepath
      );



      if nvl(p_process_flag, 'N') = 'E' then
        p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
        goto exit_from_procedure;
      end if;

    end if; /* p_input_dff_value_wct */


    p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */

    if p_input_dff_value_essi is not null or
 	   p_old_input_dff_value_essi is not null then  --Added by Bgowrava for Bug#5911913

      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */

      populate_localization_inv_tax
      (
        p_invoice_id                      =>     p_invoice_id,
        p_invoice_line_number             =>     p_invoice_line_number,
        p_invoice_distribution_id         =>     p_invoice_distribution_id,
        P_distribution_line_number        =>     P_distribution_line_number,
        p_amount                          =>     p_amount,
        p_exchange_rate                   =>     ln_exchange_rate,
        p_section_type                    =>     'ESSI_SECTION',
        p_default_type                    =>     null,
        p_default_section_code            =>     null,
        p_default_tax_id                  =>     null,
        p_input_dff_value                 =>     p_input_dff_value_essi,
        p_default_from                    =>     null,
        p_vendor_id                       =>     p_vendor_id,
        p_vendor_site_id                  =>     p_vendor_site_id,
        p_org_id                          =>     p_org_id ,
        p_accounting_date                 =>     p_accounting_date,
        p_final_tds_tax_id                =>     p_final_tds_tax_id,
        p_process_flag                    =>     p_process_flag,
        P_process_message                 =>     P_process_message,
        p_codepath                        =>     p_codepath
      );

      if nvl(p_process_flag, 'N') = 'E' then
        p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
        goto exit_from_procedure;
      end if;

    end if; /* p_input_dff_value_essi */


    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */

    if p_rcv_transaction_id is not null then

      /* If the invoice has a receipt reference get the tax from receipt */
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */

      default_tds_from_receipt
      (
        p_invoice_id                    =>     p_invoice_id,
        p_invoice_line_number           =>     p_invoice_line_number,
        p_invoice_distribution_id       =>     p_invoice_distribution_id,
        p_line_type_lookup_code         =>     p_line_type_lookup_code,
        p_distribution_line_number      =>     p_distribution_line_number,
        p_rcv_transaction_id            =>     p_rcv_transaction_id,
        p_tds_section_code              =>     lv_default_tds_section_code,
        p_tds_tax_id                    =>     ln_default_tds_tax_id,
        p_default_from                  =>     lv_default_from,
        p_process_flag                  =>     p_process_flag,
        P_process_message               =>     P_process_message,
        p_codepath                      =>     p_codepath
      );

      if nvl(p_process_flag, 'N') = 'E' then
        p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
        goto exit_from_procedure;
      end if;

    elsif p_po_distribution_id is not null then
      /* If the invoice has a PO reference get the tax from PO */

      p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
      default_tds_from_po
      (
        p_invoice_id                    =>     p_invoice_id,
        p_invoice_line_number           =>     p_invoice_line_number,
        p_invoice_distribution_id       =>     p_invoice_distribution_id,
        p_line_type_lookup_code         =>     p_line_type_lookup_code,
        p_distribution_line_number      =>     p_distribution_line_number,
        p_po_distribution_id            =>     p_po_distribution_id,
        p_tds_section_code              =>     lv_default_tds_section_code,
        p_tds_tax_id                    =>     ln_default_tds_tax_id,
        p_default_from                  =>     lv_default_from,
        p_process_flag                  =>     p_process_flag,
        P_process_message               =>     P_process_message,
        p_codepath                      =>     p_codepath
      );

      if nvl(p_process_flag, 'N') = 'E' then
        p_codepath := jai_general_pkg.plot_codepath(13, p_codepath); /* 13 */
        goto exit_from_procedure;
      end if;


    end if;

    p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */

    if ln_default_tds_tax_id is null then
      /* Default from setup if not already defaulted from PO or Receipt */
      default_tds_from_setup
      (
        p_vendor_id                         =>     p_vendor_id,
        p_vendor_site_id                    =>     p_vendor_site_id,
        p_default_type                      =>     lv_default_type,
        p_tds_section_code                  =>     lv_default_tds_section_code,
        p_tds_tax_id                        =>     ln_default_tds_tax_id,
        p_default_from                      =>     lv_default_from,
        p_process_flag                      =>     p_process_flag,
        P_process_message                   =>     P_process_message,
        p_codepath                          =>     p_codepath
      );
    end if;

    if nvl(p_process_flag, 'N') = 'E' then
      p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(16, p_codepath); /* 16 */
    validate_default_tds
    (
      p_vendor_id                         =>     p_vendor_id,
      p_vendor_site_id                    =>     p_vendor_site_id,
      p_tds_section_code                  =>     lv_default_tds_section_code,
      p_tds_tax_id                        =>     ln_default_tds_tax_id,
      p_process_flag                      =>     p_process_flag,
      P_process_message                   =>     P_process_message,
      p_codepath                          =>     p_codepath
    );

    if nvl(p_process_flag, 'N') = 'E' then
      p_codepath := jai_general_pkg.plot_codepath(16.1, p_codepath); /* 16.1 */
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(17, p_codepath); /* 17 */

    populate_localization_inv_tax
    (
      p_invoice_id                        =>     p_invoice_id,
      p_invoice_line_number               =>     p_invoice_line_number,
      p_invoice_distribution_id           =>     p_invoice_distribution_id,
      P_distribution_line_number          =>     P_distribution_line_number,
      p_amount                            =>     p_amount,
      p_exchange_rate                     =>     ln_exchange_rate,
      p_section_type                      =>     'TDS_SECTION',
      p_default_type                      =>     lv_default_type,
      p_default_section_code              =>     lv_default_tds_section_code,
      p_default_tax_id                    =>     ln_default_tds_tax_id,
      p_input_dff_value                   =>     p_input_dff_value_tds,
      p_default_from                      =>     lv_default_from,
      p_vendor_id                         =>     p_vendor_id,
      p_vendor_site_id                    =>     p_vendor_site_id,
      p_org_id                            =>     p_org_id ,
      p_accounting_date                   =>     p_accounting_date,
      p_final_tds_tax_id                  =>     p_final_tds_tax_id,
      p_process_flag                      =>     p_process_flag,
      P_process_message                   =>     P_process_message,
      p_codepath                          =>     p_codepath
    );

    p_codepath := jai_general_pkg.plot_codepath(18, p_codepath); /* 18 */

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(19, p_codepath, null, 'END'); /* 19 */
    return;

   exception
      when others then
        p_process_flag := 'E';
        P_process_message := 'Error from process_invoice :' ||  sqlerrm;
        return;
  end process_invoice;

  /* ************************************* process_invoice ************************************ */


  /* ******************************* validate_status_for_default ****************************** */
  procedure validate_status_for_default
  (
    p_invoice_id                         in                 number,
    p_invoice_line_number                in                 number    default   null,
    p_invoice_distribution_id            in                 number    default   null,
    p_line_type_lookup_code              in                 varchar2,
    p_process_flag                       out      nocopy    varchar2,
    p_process_message                    out      nocopy    varchar2,
    p_codepath                           in out   nocopy    varchar2
  )
  is


     cursor c_check_tds_already_processed(p_invoice_id  number,p_process_status jai_ap_tds_inv_taxes.process_status%type) is--rchandan for bug#4428980
      select 'P'
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id
      and    process_status = p_process_status;

     cursor c_check_old_tds_processed(p_invoice_id number) is
      select 'Y'
      from   jai_ap_tds_invoices
      where  invoice_id = p_invoice_id;

     lv_tds_process_status    varchar2(1);

    begin

      p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.validate_status_for_default', 'START'); /* 1 */
      open  c_check_tds_already_processed(p_invoice_id,'P');--rchandan for bug#4428980
      fetch c_check_tds_already_processed into lv_tds_process_status;
      close c_check_tds_already_processed;

      if nvl(lv_tds_process_status, 'N') = 'P'then
        /* TDS invoice has already been processed for this invoice, Cannot process again */
        p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
        p_process_flag := 'P';
        P_process_message := 'TDS is already processed for this invoice ';
        goto exit_from_procedure;
      end if;

      lv_tds_process_status := null;
      open  c_check_old_tds_processed(p_invoice_id);
      fetch c_check_old_tds_processed into lv_tds_process_status;
      close c_check_old_tds_processed;

      if nvl(lv_tds_process_status, 'N') = 'Y' then
        p_codepath := jai_general_pkg.plot_codepath(2.1, p_codepath); /* 2.1 */
        p_process_flag := 'P';
        P_process_message := 'TDS is already processed for this invoice in the old system, cannot process.';
        goto exit_from_procedure;
      end if;


      /* Currently defaulting happens only for ITEM lines
         This will be extended to MISCELLANEOUS lines once the tax precedences ER is in place */

      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      if p_line_type_lookup_code not in ('ITEM', 'MISCELLANEOUS', 'ACCRUAL', 'IPV') then /* ACCRUAL - AP lines uptake */  --Added IPV by Bgowrava for bug#9214036
        p_process_flag := 'X';
        P_process_message := 'TDS is not applicable as the line is not an ITEM, ACCRUAL or or MISCELLANEOUS line';
        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
        goto exit_from_procedure;
      end if;


      << exit_from_procedure >>
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      if p_process_flag is null then
        /* All checks fine, TDS defaultation can take place */
        p_process_flag := 'Y';
        p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      end if;

      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath, null, 'END'); /* 7 */
      return;

    exception
      when others then
        p_process_flag := 'E';
        P_process_message := 'Error from validate_status_for_default :' || sqlerrm;
        return;
    end validate_status_for_default;

  /* ******************************* validate_status_for_default ****************************** */


  /* *********************************** default_from_receipt ********************************** */

  procedure default_tds_from_receipt
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number    default   null,
    p_invoice_distribution_id           in                  number    default   null,
    p_line_type_lookup_code             in                  varchar2,
    p_distribution_line_number          in                  number    default   null, /* AP lines uptake */
    p_rcv_transaction_id                in                  number,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_rcv_transactions(p_rcv_transaction_id   number) is
      select shipment_header_id,
             shipment_line_id
      from   rcv_transactions
      where  transaction_id = p_rcv_transaction_id;

    cursor c_check_receipt_tds_tax(p_shipment_header_id number, p_shipment_line_id number,p_section_type jai_cmn_taxes_all.section_type%type) is--rchandan for bug#4428980
      select jtc.section_code section_code,
             jrtl.tax_id tax_id
      from   jai_rcv_line_taxes jrtl,
             jai_cmn_taxes_all jtc
      where  jtc.tax_id = jrtl.tax_id
      and    jrtl.tax_type = jai_constants.tax_type_tds
      and    jtc.section_type = p_section_type--rchandan for bug#4428980
      and    jrtl.shipment_header_id = p_shipment_header_id
      and    jrtl.shipment_line_id = p_shipment_line_id
      order by jrtl.tax_line_no asc;

      c_rec_rcv_transactions              c_rcv_transactions%rowtype;
      c_rec_check_receipt_tds_tax         c_check_receipt_tds_tax%rowtype;

  begin

    /* Get Receipt Details */
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.default_tds_from_receipt', 'START'); /* 1 */
    open c_rcv_transactions(p_rcv_transaction_id);
    fetch c_rcv_transactions into c_rec_rcv_transactions;
    close c_rcv_transactions;

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    /* Check if TDS type of tax exists against the shipment line in Receipt taxes */
    open c_check_receipt_tds_tax
      (c_rec_rcv_transactions.shipment_header_id, c_rec_rcv_transactions.shipment_line_id,'TDS_SECTION');--rchandan for bug#4428980
    fetch c_check_receipt_tds_tax into c_rec_check_receipt_tds_tax;
    close c_check_receipt_tds_tax;

    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    if c_rec_check_receipt_tds_tax.section_code is null then
      /* No TDS tax exists against the receipt line */
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      goto exit_from_procedure;
    end if;

    /* Control comes here only when a TDS tax exists against the receipt */

    p_tds_section_code               :=    c_rec_check_receipt_tds_tax.section_code;
    p_tds_tax_id                     :=    c_rec_check_receipt_tds_tax.tax_id;
    p_default_from                   :=    'Receipt';

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath, null, 'END'); /* 5 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from default_from_receipt :' || sqlerrm;
      return;

  end default_tds_from_receipt;

/* *********************************** default_from_receipt ********************************** */

/* ************************************** default_from_po ************************************ */
  procedure default_tds_from_po
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number    default   null,
    p_invoice_distribution_id           in                  number    default   null,
    p_line_type_lookup_code             in                  varchar2,
    p_distribution_line_number          in                  number    default   null, /* AP lines uptake */
    p_po_distribution_id                in                  number,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_po_distributions_all(p_po_distribution_id number) is
      select po_header_id,
             po_line_id,
             line_location_id
      from   po_distributions_all
      where  po_distribution_id = p_po_distribution_id;


    cursor    c_po_taxes(p_po_header_id number, p_po_line_id number, p_line_location_id number,p_section_type jai_cmn_taxes_all.section_type%type)--rchandan for bug#4428980
    is
      select  jtc.section_code section_code,
              jpllt.tax_id tax_id
      from    jai_po_taxes jpllt,
              jai_cmn_taxes_all jtc
      where   jpllt.tax_id = jtc.tax_id
      and     jpllt.po_header_id = p_po_header_id
      and     jpllt.po_line_id = p_po_line_id
      and     jpllt.line_location_id = p_line_location_id
      and     jtc.tax_type = jai_constants.tax_type_tds
      and     jtc.section_type = p_section_type--rchandan for bug#4428980
      order by jpllt.tax_line_no asc;


    c_rec_po_distributions_all          c_po_distributions_all%rowtype;
    lv_last_section_type                JAI_CMN_TAXES_ALL.section_type%type;
    c_rec_po_taxes                      c_po_taxes%rowtype;

  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.default_tds_from_po', 'START'); /* 1 */
    open c_po_distributions_all(p_po_distribution_id);
    fetch c_po_distributions_all into c_rec_po_distributions_all;
    close c_po_distributions_all;

    /* Check if TDS type of tax exists against if PO taxes */
    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    open c_po_taxes
    (
      c_rec_po_distributions_all.po_header_id,
      c_rec_po_distributions_all.po_line_id,
      c_rec_po_distributions_all.line_location_id,
      'TDS_SECTION'                --rchandan for bug#4428980
     );
    fetch c_po_taxes into c_rec_po_taxes;
    close c_po_taxes;

    if c_rec_po_taxes.section_code is null then
      /* No TDS tax exists against the receipt line */
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      goto exit_from_procedure;
    end if;

    /* Control comes here only when a TDS tax exists against the receipt */
    p_tds_section_code                  :=    c_rec_po_taxes.section_code;
    p_tds_tax_id                        :=    c_rec_po_taxes.tax_id;
    p_default_from                      :=    'PO';

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath, null, 'END'); /* 4 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from default_from_po :' || sqlerrm;
      return;

  end default_tds_from_po;
/* ************************************** default_from_po ************************************ */


/* ************************************* default_from_setup *********************************** */

  procedure default_tds_from_setup
  (
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_default_type                      out       nocopy    varchar2,
    p_tds_section_code                  out       nocopy    varchar2,
    p_tds_tax_id                        out       nocopy    number,
    p_default_from                      out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_ja_in_vendor_tds_info_hdr (p_vendor_id number, p_vendor_site_id  number)
    is
      select section_code,
             tax_id
      from   JAI_AP_TDS_VENDOR_HDRS
      where  vendor_id = p_vendor_id
      and    vendor_site_id = p_vendor_site_id;

    crec_ja_in_vendor_tds_info_hdr        c_ja_in_vendor_tds_info_hdr%rowtype;

  begin

    /* Check from setup for vendor and site */
    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.default_tds_from_setup', 'START'); /* 1 */
    p_default_from := 'Vendor Site Setup';
    open c_ja_in_vendor_tds_info_hdr(p_vendor_id, p_vendor_site_id);
    fetch c_ja_in_vendor_tds_info_hdr into crec_ja_in_vendor_tds_info_hdr;
    close c_ja_in_vendor_tds_info_hdr;

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    if  crec_ja_in_vendor_tds_info_hdr.tax_id is null and
        crec_ja_in_vendor_tds_info_hdr.section_code is null
    then
      /* No setup exists for site, check for null site */
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      p_default_from := 'Vendor Null Site Setup';

      crec_ja_in_vendor_tds_info_hdr := null;
      open c_ja_in_vendor_tds_info_hdr(p_vendor_id, 0);
      fetch c_ja_in_vendor_tds_info_hdr into crec_ja_in_vendor_tds_info_hdr;
      close c_ja_in_vendor_tds_info_hdr;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
    if  crec_ja_in_vendor_tds_info_hdr.tax_id is not null and
        crec_ja_in_vendor_tds_info_hdr.section_code is not null
    then

      /* Tax has been define as the default */
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      p_tds_section_code := crec_ja_in_vendor_tds_info_hdr.section_code;
      p_tds_tax_id := crec_ja_in_vendor_tds_info_hdr.tax_id;
      p_default_type := 'TAX';

    elsif crec_ja_in_vendor_tds_info_hdr.tax_id is null and
          crec_ja_in_vendor_tds_info_hdr.section_code is not null
    then

      /* Section has been define as the default */
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      p_tds_section_code := crec_ja_in_vendor_tds_info_hdr.section_code;
      p_default_type := 'SECTION';

    else

      /* No Default has been setup for the vendor */
      p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */
      goto exit_from_procedure;

    end if;


    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(9, p_codepath, null, 'END'); /* 9 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from default_from_setup :' || sqlerrm;
      return;
  end default_tds_from_setup;

/* ************************************* default_from_setup *********************************** */

/* ************************************* validate_default_value *********************************** */
  procedure validate_default_tds
  (
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_tds_section_code                  in                  varchar2,
    p_tds_tax_id                        in                  number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_ja_in_vendor_tds_info_hdr(p_vendor_id number, p_vendor_site_id number) is
      select nvl(confirm_pan_flag, 'N') confirm_pan_flag
      from   JAI_AP_TDS_VENDOR_HDRS
      where  vendor_id = p_vendor_id
      and    vendor_site_id = p_vendor_site_id;

   cursor c_check_section_applicable(p_vendor_id number, p_vendor_site_id number, p_tds_section_code varchar2,p_section_type JAI_CMN_TAXES_ALL.section_type%type) is--rchandan for bug#4428980
      select 'Y'
      from   JAI_AP_TDS_TH_VSITE_V
      where  vendor_id = p_vendor_id
      and    vendor_site_id = p_vendor_site_id
      and    section_type = p_section_type--rchandan for bug#4428980
      and    section_code = p_tds_section_code;

    lv_confirm_pan_flag             JAI_AP_TDS_VENDOR_HDRS.confirm_pan_flag%type;
    lv_check_section_applicable     varchar2(1);

  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.validate_default_tds', 'START'); /* 1 */
    open  c_ja_in_vendor_tds_info_hdr(p_vendor_id, p_vendor_site_id);
    fetch c_ja_in_vendor_tds_info_hdr into lv_confirm_pan_flag;
    close c_ja_in_vendor_tds_info_hdr;

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    if lv_confirm_pan_flag = 'N' then
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
      p_process_flag := 'V';
      P_process_message := 'PAN of the vendor site not confirmed';
      goto exit_from_procedure;
    end if;

    p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */


    /* Check if section is applicable because of regular setup */
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    open c_check_section_applicable(p_vendor_id, p_vendor_site_id, p_tds_section_code,'TDS_SECTION' );
    fetch c_check_section_applicable into lv_check_section_applicable;
    close c_check_section_applicable;

    if nvl(lv_check_section_applicable, 'N') <> 'Y' then
      p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
      p_process_flag := 'V';
      P_process_message := 'Section is not applicable to the vendor and / or site';
    end if;


    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath, null, 'END'); /* 8 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from validate_default_value :' || sqlerrm;
      return;

  end validate_default_tds;

/* ************************************* validate_default_value *********************************** */

/* *********************************** populate_localization_inv_tax ****************************** */
 procedure populate_localization_inv_tax
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    P_distribution_line_number          in                  number           default   null, /* AP lines uptake */
    p_amount                            in                  number,
    p_exchange_rate                     in                  number,
    p_section_type                      in                  varchar2,
    p_default_type                      in                  varchar2,
    p_default_section_code              in                  varchar2,
    p_default_tax_id                    in                  number,
    p_input_dff_value                   in                  varchar2,
    p_default_from                      in                  varchar2,
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_org_id                            in                  number,
    p_accounting_date                   in                  date,
    p_final_tds_tax_id                  out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_check_if_record_exists
    (p_invoice_id number, p_invoice_line_number number, p_invoice_distribution_id number) is
      select  tds_inv_tax_id, actual_tax_id  --Added by Bgowrava for Bug#5911913
      from    jai_ap_tds_inv_taxes
      where   invoice_id =  p_invoice_id
      and     nvl(invoice_line_number, -9999) = nvl(p_invoice_line_number, -9999)
      and     nvl(invoice_distribution_id, -9999) =  nvl(p_invoice_distribution_id, -9999)
      and     section_type = p_section_type;

    ln_tds_inv_tax_id                   jai_ap_tds_inv_taxes.tds_inv_tax_id%type;
    ln_check_if_tax_is_input            number; --File.Sql.35 Cbabu  :=0;
    lv_actual_section_code              jai_ap_tds_inv_taxes.actual_section_code%type;
    ln_actual_tax_id                    jai_ap_tds_inv_taxes.actual_tax_id%type;
    ln_default_tax_id                   jai_ap_tds_inv_taxes.default_tax_id%type;
    lv_consider_for_redefault           jai_ap_tds_inv_taxes.consider_for_redefault%type; --File.Sql.35 Cbabu   := 'N';

    ln_default_threshold_grp_id         jai_ap_tds_inv_taxes.default_threshold_grp_id%type;
    ln_default_cum_threshold_slab       jai_ap_tds_inv_taxes.default_cum_threshold_slab_id%type;
    lv_default_cum_threshold_stage      jai_ap_tds_inv_taxes.default_cum_threshold_stage%type;
    ln_default_sin_threshold_slab       jai_ap_tds_inv_taxes.default_sin_threshold_slab_id%type;

    lv_input_dff_value                  varchar2(50);
    lv_user_deleted_tax_flag            jai_ap_tds_inv_taxes.user_deleted_tax_flag%type; --File.Sql.35 Cbabu  := 'N';
    lv_process_status                   jai_ap_tds_inv_taxes.process_status%type;

	ln_actual_dff_tax_id                number;  --Added by Bgowrava for Bug#5911913

  begin

    ln_check_if_tax_is_input            :=0;
    lv_consider_for_redefault           := 'N';
    lv_user_deleted_tax_flag            := 'N';

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.populate_localization_inv_tax', 'START'); /* 2 */

    ln_default_tax_id := p_default_tax_id;
    ln_actual_tax_id  := to_number(p_input_dff_value);
    ln_actual_dff_tax_id := 0;  --Added by Bgowrava for Bug#5911913

    if  p_section_type = 'TDS_SECTION' then

      /* If default value is SECTION check the default and the given tax  */

      if p_default_type = 'SECTION' and p_default_section_code is not null then

        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */

        get_default_tax_from_section
        (
          p_invoice_id                    =>     p_invoice_id                   ,
          p_invoice_line_number           =>     p_invoice_line_number           ,
          p_invoice_distribution_id       =>     p_invoice_distribution_id      ,
          p_vendor_id                     =>     p_vendor_id                    ,
          p_vendor_site_id                =>     p_vendor_site_id               ,
          p_amount                        =>     p_amount                       ,
          p_exchange_rate                 =>     p_exchange_rate                ,
          p_tds_section_code              =>     p_default_section_code         ,
          p_org_id                        =>     p_org_id                       ,
          p_accounting_date               =>     p_accounting_date              ,
          p_tds_tax_id                    =>     ln_default_tax_id              ,
          p_threshold_grp_id              =>     ln_default_threshold_grp_id    ,
          p_cumulative_threshold_slab_id  =>     ln_default_cum_threshold_slab  ,
          p_cumulative_threshold_stage    =>     lv_default_cum_threshold_stage ,
          p_single_threshold_slab_id      =>     ln_default_sin_threshold_slab  ,
          p_process_flag                  =>     p_process_flag                 ,
          P_process_message               =>     P_process_message              ,
          p_codepath                      =>     p_codepath
        );

      end if;

      /* process the input tds dff value */
      process_input_dff_tds
      (
        p_invoice_id                    =>     p_invoice_id                   ,
        p_invoice_line_number           =>     p_invoice_line_number          ,
        p_invoice_distribution_id       =>     p_invoice_distribution_id      ,
        p_input_tds_dff_value           =>     p_input_dff_value              ,
        p_output_tds_dff_value          =>     lv_input_dff_value             ,
        p_process_flag                  =>     p_process_flag                 ,
        P_process_message               =>     P_process_message              ,
        p_codepath                      =>     p_codepath
      );


      if  lv_input_dff_value = 'NO TDS' then
        p_codepath := jai_general_pkg.plot_codepath(6.1, p_codepath); /* 6.1 */
        lv_user_deleted_tax_flag := 'Y';
      elsif  lv_input_dff_value is not null then
        ln_actual_tax_id  := to_number(lv_input_dff_value);
      end if;

      /* Value for consider_for_redefault */
      if ln_actual_tax_id is null and lv_user_deleted_tax_flag <> 'Y' and  p_default_from not in ('PO', 'Receipt') then
        /* User has not given any input, or also has not specifically deleted the defaulted value or
           default is not because of PO or Receipt */
        p_codepath := jai_general_pkg.plot_codepath(14, p_codepath); /* 14 */
        if p_default_type  = 'SECTION' then
          lv_consider_for_redefault := 'Y';
          p_codepath := jai_general_pkg.plot_codepath(15, p_codepath); /* 15 */
        end if;
      end if;
      /* Value for consider_for_redefault */

    end if; /* if  p_section_type */

    p_codepath := jai_general_pkg.plot_codepath(19, p_codepath); /* 19 */
    open  c_check_if_record_exists(p_invoice_id, p_invoice_line_number, p_invoice_distribution_id);
    fetch c_check_if_record_exists into ln_tds_inv_tax_id, ln_actual_dff_tax_id;  --Modified by Bgowrava for Bug#5911913
    close c_check_if_record_exists;

	--Added below by Bgowrava for Bug#5911913
	if p_section_type in ('WCT_SECTION', 'ESSI_SECTION') then
 	    if ln_actual_dff_tax_id is not null and ln_actual_tax_id is null then
 	      lv_user_deleted_tax_flag := 'Y';
 	    end if ;
 	end if ;

    if ln_tds_inv_tax_id is null then

      p_codepath := jai_general_pkg.plot_codepath(20, p_codepath); /* 20 */
      lv_process_status := 'D';
      insert into jai_ap_tds_inv_taxes
      (
        tds_inv_tax_id                      ,
        invoice_id                          ,
        invoice_line_number                 ,
        invoice_distribution_id             ,
        distribution_line_number            ,
        amount                              ,
        section_type                        ,
        default_type                        ,
        default_section_code                ,
        default_tax_id                      ,
        actual_section_code                 ,
        actual_tax_id                       ,
        user_deleted_tax_flag               ,
        default_threshold_grp_id            ,
        default_cum_threshold_slab_id       ,
        default_cum_threshold_stage         ,
        default_sin_threshold_slab_id       ,
        default_from                        ,
        consider_for_redefault              ,
        process_status                      ,
        codepath                            ,
        created_by                          ,
        creation_date                       ,
        last_updated_by                     ,
        last_update_date                    ,
        last_update_login
      )
      values
      (
        jai_ap_tds_inv_taxes_s.nextval      ,
        p_invoice_id                        ,
        p_invoice_line_number               ,
        p_invoice_distribution_id           ,
        P_distribution_line_number          ,
        p_amount                            ,
        p_section_type                      ,
        p_default_type                      ,
        p_default_section_code              ,
        ln_default_tax_id                   ,
        lv_actual_section_code              ,
        ln_actual_tax_id                    ,
        lv_user_deleted_tax_flag            ,
        ln_default_threshold_grp_id         ,
        ln_default_cum_threshold_slab       ,
        lv_default_cum_threshold_stage      ,
        ln_default_sin_threshold_slab       ,
        p_default_from                      ,
        lv_consider_for_redefault           ,
        lv_process_status                   ,
        p_codepath                          ,
        fnd_global.user_id                  ,
        sysdate                             ,
        fnd_global.user_id                  ,
        sysdate                             ,
        fnd_global.login_id
      );

    else

      p_codepath := jai_general_pkg.plot_codepath(21, p_codepath); /* 21 */

      update jai_ap_tds_inv_taxes
      set    amount                            =           p_amount                            ,
             section_type                      =           p_section_type                      ,
             default_type                      =           p_default_type                      ,
             default_section_code              =           p_default_section_code              ,
             default_tax_id                    =           ln_default_tax_id                   ,
             actual_section_code               =           lv_actual_section_code              ,
             actual_tax_id                     =           ln_actual_tax_id                    ,
             user_deleted_tax_flag             =           lv_user_deleted_tax_flag            ,
             default_threshold_grp_id          =           ln_default_threshold_grp_id         ,
             default_cum_threshold_slab_id     =           ln_default_cum_threshold_slab       ,
             default_cum_threshold_stage       =           lv_default_cum_threshold_stage      ,
             default_sin_threshold_slab_id     =           ln_default_sin_threshold_slab       ,
             default_from                      =           p_default_from                      ,
             consider_for_redefault            =           lv_consider_for_redefault           ,
             process_status                    =           lv_process_status                   ,
             codepath                          =           p_codepath                          ,
             last_updated_by                   =           fnd_global.user_id                  ,
             last_update_date                  =           sysdate
      where  tds_inv_tax_id  = ln_tds_inv_tax_id;

    end if;


    if lv_consider_for_redefault = 'Y' and p_section_type = 'TDS_SECTION' then

      p_codepath := jai_general_pkg.plot_codepath(22, p_codepath); /* 22 */

      update jai_ap_tds_inv_taxes
      set    default_tax_id                  =       ln_default_tax_id
      where  tds_inv_tax_id                  <>      ln_tds_inv_tax_id
      and    invoice_id                      =      p_invoice_id
      and    nvl(invoice_line_number, -9999) =      nvl(p_invoice_line_number, -9999)
      and    consider_for_redefault          =      lv_consider_for_redefault
      and    section_type                    =      p_section_type;

    end if; /* lv_consider_for_redefault = 'Y' */

    if p_section_type = 'TDS_SECTION' then
      p_codepath := jai_general_pkg.plot_codepath(23, p_codepath); /* 23 */
      p_final_tds_tax_id := nvl(ln_actual_tax_id, ln_default_tax_id);
    end if;

    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, NULL, 'END'); /*100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from populate_localization_inv_tax :'  || sqlerrm;
      return;

  end populate_localization_inv_tax;

/* ******************************** populate_localization_inv_tax ****************************** */

/* ******************************** get_default_tax_from_section ****************************** */

  procedure get_default_tax_from_section
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    p_vendor_id                         in                  number,
    p_vendor_site_id                    in                  number,
    p_amount                            in                  number,
    p_exchange_rate                     in                  number,
    p_tds_section_code                  in                  varchar2,
    p_org_id                            in                  number,
    p_accounting_date                   in                  date,
    p_tds_tax_id                        out       nocopy    number,
    p_threshold_grp_id                  out       nocopy    number,
    p_cumulative_threshold_slab_id      out       nocopy    number,
    p_cumulative_threshold_stage        out       nocopy    varchar2,
    p_single_threshold_slab_id          out       nocopy    number,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

  cursor c_get_amount_for_redefault /* AP lines uptake - introduced line */
  (p_invoice_id number,  p_invoice_line_number number, p_invoice_distribution_id number, p_consider_for_redefault jai_ap_tds_inv_taxes.consider_for_redefault%type) is--rchandan for bug#4428980
    select sum(amount)
    from   jai_ap_tds_inv_taxes
    where  invoice_id = p_invoice_id
--Commented out by Eric Ma for PF bug#7340818    and    consider_for_redefault = p_consider_for_redefault--rchandan for bug#4428980
--Commented out by Eric Ma for PF bug#7340818    and    user_deleted_tax_flag <> 'Y'
    and    ( (p_invoice_distribution_id is null ) or (p_invoice_distribution_id is not null and invoice_distribution_id <> p_invoice_distribution_id ) )
    /*and    ( (p_invoice_line_number is null ) or ( p_invoice_line_number is not null and invoice_line_number <> p_invoice_line_number) )
      This is not required as we need to consider all distributions for redefaulting*/
    and invoice_distribution_id < p_invoice_distribution_id; --Added by Eric Ma for PF bug#7340818

  cursor c_get_threshold
  (p_vendor_id number, p_vendor_site_id number,  p_tds_section_code varchar2,p_section_type jai_cmn_taxes_all.section_type%type) is--rchandan for bug#4428980
    select threshold_hdr_id
    from   jai_ap_tds_th_vsite_v
    where  vendor_id = p_vendor_id
    and    vendor_site_id = p_vendor_site_id
    and    section_type = p_section_type--rchandan for bug#4428980
    and    section_code = p_tds_section_code;

  cursor c_jai_ap_tds_thhold_grps(p_threshold_grp_id number) is
    select  (
              nvl(total_invoice_amount, 0) -
              nvl(total_invoice_cancel_amount, 0) -
              nvl(total_invoice_apply_amount, 0)  +
              nvl(total_invoice_unapply_amount, 0)
            )
            total_invoice_amount
    from    jai_ap_tds_thhold_grps
    where   threshold_grp_id = p_threshold_grp_id;

  cursor c_jai_ap_tds_thhold_slabs
  ( p_threshold_hdr_id number, p_threshold_type varchar2, p_amount number) is
    select  threshold_slab_id, threshold_type_id, from_amount, to_amount
    from    jai_ap_tds_thhold_slabs
    where   threshold_hdr_id = p_threshold_hdr_id
    and     threshold_type_id in
            ( select threshold_type_id
              from   jai_ap_tds_thhold_types
              where   threshold_hdr_id = p_threshold_hdr_id
              and     threshold_type = p_threshold_type
	      /* Bug 4522540. Added by Lakshmi Gopalsami
	         Added the date condition */
	      and     trunc(p_accounting_Date) between from_date
	      and     nvl(to_date, p_accounting_date + 1)
            )
    and     nvl(to_amount, p_amount) >= p_amount
    order by from_amount asc;

  cursor c_jai_ap_tds_thhold_taxes(p_threshold_slab_id number, p_org_id number) is
    select tax_id
    from   jai_ap_tds_thhold_taxes
    where  threshold_slab_id = p_threshold_slab_id
    and    operating_unit_id = p_org_id;

    lv_attr_code  VARCHAR2(25);
    lv_attr_type_code VARCHAR2(25);
    lv_tds_regime     VARCHAR2(25);
    lv_regn_type_others VARCHAR2(25);

  cursor c_get_fin_year(p_gl_date  date, p_org_id number) is
    select fin_year
    from   jai_ap_tds_years
    where  tan_no in /* where clause and subquery added by ssumaith - bug# 4448789*/
        (
        SELECT  attribute_value
        FROM    JAI_RGM_ORG_REGNS_V
        WHERE   regime_code = lv_tds_regime
        AND     registration_type = lv_regn_type_others
        AND     attribute_type_code = lv_attr_type_Code
        AND     attribute_code = lv_attr_code
        AND     organization_id = p_org_id
        )
    and    p_gl_date between start_date and end_date;


  cursor c_get_vendor_pan_tan(p_vendor_id number , p_vendor_site_id number) is
    select    c.pan_no pan_no,
              d.org_tan_num tan_no
      from    po_vendors a,
              po_vendor_sites_all b,
              jai_ap_tds_vendor_hdrs c,
              jai_ap_tds_org_tan_v d     ---  JAI_AP_TDS_ORG_TANS is changed to view jai_ap_tds_org_tan_v  4323338
    where     a.vendor_id = b.vendor_id
      and     b.vendor_id = c.vendor_id
      and     b.vendor_site_id = c.vendor_site_id
      and     b.org_id = d.organization_id
      and     a.vendor_id = p_vendor_id
      and     b.vendor_site_id = p_vendor_site_id;

    cursor    c_get_threshold_group
    (p_vendor_id number, p_tan_no varchar2, p_pan_no varchar2,  p_tds_section_code varchar2 , p_fin_year  number,p_section_type jai_ap_tds_thhold_grps.section_type%type) is--rchandan for bug#4428980
      select  threshold_grp_id
      from    jai_ap_tds_thhold_grps
      where   vendor_id         =  p_vendor_id
      and     section_type      =  p_section_type   --rchandan for bug#4428980
      and     section_code      =  p_tds_section_code
      and     org_tan_num       =  p_tan_no
      and     vendor_pan_num    =  p_pan_no
      and     fin_year          =  p_fin_year;

    r_get_threshold                   c_get_threshold%rowtype;
    r_jai_ap_tds_thhold_slabs         c_jai_ap_tds_thhold_slabs%rowtype;
    r_jai_ap_tds_thhold_taxes         c_jai_ap_tds_thhold_taxes%rowtype;

    lv_pan_no                         jai_ap_tds_vendor_hdrs.pan_no%type;
    lv_tan_no                         jai_ap_tds_org_tan_v.org_tan_num %type;---  JAI_AP_TDS_ORG_TANS is changed to view jai_ap_tds_org_tan_v   4323338


    ln_total_invoice_amount           number;
    ln_amount_for_redefault            number;
    ln_fin_year                       number;
    ln_threshold_grp_id               number;
    ln_amount                         number;


  begin

    p_codepath := jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.get_default_tax_from_section', 'START'); /* 1 */

    ln_amount := p_amount * nvl(p_exchange_rate, 1);


   lv_attr_code  := 'TAN NO';
   lv_attr_type_code := 'PRIMARY';
   lv_tds_regime     := 'TDS';
   lv_regn_type_others := 'OTHERS';




    /* Get the fin year */
    open  c_get_fin_year(p_accounting_date, p_org_id);
    fetch c_get_fin_year into ln_fin_year;
    close c_get_fin_year;

    /* Get Pan number and Tan number for the vendor */
    open c_get_vendor_pan_tan(p_vendor_id, p_vendor_site_id);
    fetch c_get_vendor_pan_tan into lv_pan_no, lv_tan_no;
    close c_get_vendor_pan_tan;


    open c_get_amount_for_redefault(p_invoice_id, p_invoice_line_number, p_invoice_distribution_id,'Y');--rchandan for bug#4428980
    fetch c_get_amount_for_redefault into ln_amount_for_redefault;
    close c_get_amount_for_redefault;

    ln_amount_for_redefault := nvl(ln_amount_for_redefault, 0);
    ln_amount_for_redefault := ln_amount_for_redefault * nvl(p_exchange_rate, 1);

    p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
    /* Get threshold id */
    open c_get_threshold(p_vendor_id, p_vendor_site_id, p_tds_section_code,'TDS_SECTION');--rchandan for bug#4428980
    fetch c_get_threshold into r_get_threshold;
    close c_get_threshold;


    p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */
    if r_get_threshold.threshold_hdr_id is null then
      /* No threshold has been setup for the section and vendor,
         it is not possible to default a tax from section */
      p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
      p_tds_tax_id := null;
      goto exit_from_procedure;
    end if;

    /* Get threshold group id */
    p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
    open c_get_threshold_group(p_vendor_id, lv_tan_no, lv_pan_no, p_tds_section_code, ln_fin_year,'TDS_SECTION');
    fetch c_get_threshold_group into ln_threshold_grp_id;
    close c_get_threshold_group;

    /*  if there is no threshold group details,
        it means no transaction has happened for that section and vendor combination */
    if ln_threshold_grp_id is not null then
      p_codepath := jai_general_pkg.plot_codepath(6, p_codepath); /* 6 */
      open c_jai_ap_tds_thhold_grps(ln_threshold_grp_id);
      fetch c_jai_ap_tds_thhold_grps into ln_total_invoice_amount;
      close c_jai_ap_tds_thhold_grps;
      p_threshold_grp_id := ln_threshold_grp_id;
    end if;

    ln_total_invoice_amount := nvl(ln_total_invoice_amount, 0 ) ;

    p_codepath := jai_general_pkg.plot_codepath(7, p_codepath); /* 7 */
    /* Check if Cumulative threshold is reached */
    open  c_jai_ap_tds_thhold_slabs
    (r_get_threshold.threshold_hdr_id, 'CUMULATIVE', ln_total_invoice_amount + ln_amount + ln_amount_for_redefault);
    fetch c_jai_ap_tds_thhold_slabs into r_jai_ap_tds_thhold_slabs;
    close c_jai_ap_tds_thhold_slabs;

    p_codepath := jai_general_pkg.plot_codepath(8, p_codepath); /* 8 */

    p_cumulative_threshold_slab_id := r_jai_ap_tds_thhold_slabs.threshold_slab_id;

    if ln_total_invoice_amount >= r_jai_ap_tds_thhold_slabs.from_amount then
      /* Cumulative threshold amount is already reached */
      p_codepath := jai_general_pkg.plot_codepath(9, p_codepath); /* 9 */
      p_cumulative_threshold_stage := 'AFTER THRESHOLD';

    elsif (ln_total_invoice_amount + ln_amount + ln_amount_for_redefault) >= r_jai_ap_tds_thhold_slabs.from_amount then

      /* Threshold reached with this transaction */
      p_codepath := jai_general_pkg.plot_codepath(10, p_codepath); /* 10 */
      p_cumulative_threshold_stage := 'AT THRESHOLD';

    else

      p_cumulative_threshold_stage := 'BEFORE THRESHOLD';

      /* Cumulative threshold is not reached, default  the tax id anyway but
      check for SINGLE invoice threshold. This  has to be checked with only invoice amount */

      r_jai_ap_tds_thhold_slabs:= null;
      p_codepath := jai_general_pkg.plot_codepath(11, p_codepath); /* 11 */
      open  c_jai_ap_tds_thhold_slabs(r_get_threshold.threshold_hdr_id, 'SINGLE', ln_amount + ln_amount_for_redefault);
      fetch c_jai_ap_tds_thhold_slabs into r_jai_ap_tds_thhold_slabs;
      close c_jai_ap_tds_thhold_slabs;

      if ln_amount + ln_amount_for_redefault >= r_jai_ap_tds_thhold_slabs.from_amount then
        /* Cumulative threshold amount is reached */
        p_codepath := jai_general_pkg.plot_codepath(12, p_codepath); /* 12 */
        p_single_threshold_slab_id := r_jai_ap_tds_thhold_slabs.threshold_slab_id;
      end if;

    end if; /* Cumulative or single threshold amount */

    /* Get the tax id attached to the slab */
    open  c_jai_ap_tds_thhold_taxes(nvl(p_single_threshold_slab_id, p_cumulative_threshold_slab_id), p_org_id);
    fetch c_jai_ap_tds_thhold_taxes into r_jai_ap_tds_thhold_taxes;
    close c_jai_ap_tds_thhold_taxes;

    p_tds_tax_id := r_jai_ap_tds_thhold_taxes.tax_id;

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(13, p_codepath, null, 'END'); /* 13 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from get_default_tax_from_section :' || sqlerrm;
      return;

  end get_default_tax_from_section;


/* ******************************** get_default_tax_from_section ****************************** */


/* ********************************************* process_input_dff_tds ********************************************* */
  procedure process_input_dff_tds
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null, /* AP lines uptake */
    p_input_tds_dff_value               in                  varchar2,
    p_output_tds_dff_value              out       nocopy    varchar2,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2,
    p_codepath                          in out    nocopy    varchar2
  )
  is

    cursor c_get_existing_dff_values
    (p_invoice_id number, p_invoice_line_number number, p_invoice_distribution_id number, p_section_type jai_cmn_taxes_all.section_type%type) is--rchandan for bug#4428980
      select  tds_inv_tax_id, default_tax_id, actual_tax_id
      from    jai_ap_tds_inv_taxes
      where   invoice_id =  p_invoice_id
      and     nvl(invoice_line_number, -9999) = nvl(p_invoice_line_number, -9999)
      and     nvl(invoice_distribution_id, -9999) =  nvl(p_invoice_distribution_id, -9999)
      and     section_type = p_section_type;--rchandan for bug#4428980


    r_get_existing_dff_values     c_get_existing_dff_values%rowtype;


  begin

    p_codepath :=
    jai_general_pkg.plot_codepath(1, p_codepath, 'jai_ap_tds_tax_defaultation.process_input_dff_tds', 'START'); /* 1 */

    p_output_tds_dff_value := p_input_tds_dff_value;

    open  c_get_existing_dff_values(p_invoice_id, p_invoice_line_number, p_invoice_distribution_id,'TDS_SECTION');--rchandan for bug#4428980
    fetch c_get_existing_dff_values into r_get_existing_dff_values;
    close c_get_existing_dff_values;

    if r_get_existing_dff_values.tds_inv_tax_id is null then
      /* TDS defaultation Record does not exist */
      p_codepath := jai_general_pkg.plot_codepath(2, p_codepath); /* 2 */
      goto exit_from_procedure;
    end if;

    /* Control comes here only when defaultation details already exists */

    if p_input_tds_dff_value is null then

      /* user has not provided any input or has deleted the defaulted or earlier given value */
      p_codepath := jai_general_pkg.plot_codepath(3, p_codepath); /* 3 */

      if  r_get_existing_dff_values.default_tax_id is not null or
          r_get_existing_dff_values.actual_tax_id is not null  then

        p_codepath := jai_general_pkg.plot_codepath(4, p_codepath); /* 4 */
        /* User has deleted the earlier given or defaulted value no TDS should be deducted. */
        p_output_tds_dff_value := 'NO TDS';

      end if;

    elsif p_input_tds_dff_value = r_get_existing_dff_values.default_tax_id then
      /* User has given the same value as default. Actual can be set to null */
      p_codepath := jai_general_pkg.plot_codepath(5, p_codepath); /* 5 */
      p_output_tds_dff_value := null;

    end if; /* p_input_tds_dff_value */

    << exit_from_procedure >>
    p_codepath := jai_general_pkg.plot_codepath(100, p_codepath, null, 'END'); /* 100 */
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from jai_ap_tds_tax_defaultation.process_input_dff_tds :' || sqlerrm;
      return;
  end process_input_dff_tds;

/* ********************************************* process_input_dff_tds ********************************************* */

/* ********************************************* process_delete ********************************************* */

  procedure process_delete
  (
    p_invoice_id                        in                  number,
    p_invoice_line_number               in                  number           default   null, /* AP lines uptake */
    p_invoice_distribution_id           in                  number           default   null,
    p_process_flag                      out       nocopy    varchar2,
    P_process_message                   out       nocopy    varchar2
  )
  is
/* Change History
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
 1.        16/05/2008   JMEENA for bug#6995295.
 			Added NVL for process_status
*/
  begin

    /* AP lines uptake - introduced line */
    delete jai_ap_tds_inv_taxes
    where  invoice_id = p_invoice_id
    and    (
            (p_invoice_line_number is null ) or
            (p_invoice_line_number is not null and invoice_line_number = p_invoice_line_number)
           )
    and    (
            (p_invoice_distribution_id is null ) or
            (p_invoice_distribution_id is not null and invoice_distribution_id = p_invoice_distribution_id)
           )
    and    NVL(process_status,'D') <> 'P'; -- Added NVL by JMEENA for bug#6995295

    << exit_from_procedure >>
    return;

  exception
    when others then
      p_process_flag := 'E';
      P_process_message := 'Error from jai_ap_tds_tax_defaultation.process_delete :' || sqlerrm;
      return;
  end process_delete;

/* ********************************************* process_delete ********************************************* */


/* ********************************************* check_old_transaction ********************************************* */
  procedure check_old_transaction
  (
    p_invoice_id                        in                  number  default null,
    p_invoice_distribution_id           in                  number  default null,
    p_new_transaction                   out       nocopy    varchar2
  )
  is

    cursor c_jai_ap_tds_inv_taxes_inv(p_invoice_id number) is
      select 'Y'
      from   jai_ap_tds_inv_taxes
      where  invoice_id = p_invoice_id;


    cursor c_jai_ap_tds_inv_taxes_dist(p_invoice_distribution_id number) is
      select 'Y'
      from   jai_ap_tds_inv_taxes
      where  invoice_distribution_id = p_invoice_distribution_id;

    lv_new_transaction    varchar2(1);

  begin

    lv_new_transaction := 'N';

    if p_invoice_id is not null then

      open  c_jai_ap_tds_inv_taxes_inv(p_invoice_id);
      fetch c_jai_ap_tds_inv_taxes_inv into lv_new_transaction;
      close c_jai_ap_tds_inv_taxes_inv;

    elsif p_invoice_distribution_id is not null then

      open  c_jai_ap_tds_inv_taxes_dist(p_invoice_distribution_id);
      fetch c_jai_ap_tds_inv_taxes_dist into lv_new_transaction;
      close c_jai_ap_tds_inv_taxes_dist;

    end if;

    p_new_transaction := nvl(lv_new_transaction, 'N');

    << exit_from_procedure >>
    return;

  exception
    when others then
      return;
  end check_old_transaction;



/* ********************************************* check_old_transaction ********************************************* */

END jai_ap_tds_tax_defaultation;

/

--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_PROCESSING_PKG" as
/* $Header: jai_ap_tds_prc.plb 120.11.12010000.3 2008/11/24 09:37:20 mbremkum ship $ */
/* ----------------------------------------------------------------------------
 FILENAME      : jai_ap_tds_prc.plb

 Created By    : Aparajita

 Created Date  : 21-jul-2005

 Bug           :

 Purpose       : Revamp of TDS certificate and eTDS reporting.

 Called from   : Concurrents,
                 JAIATDSP -  India - Process TDS Payments
                 JAIATDSC -  India - Generate TDS Certificates

 CHANGE HISTORY:
 -------------------------------------------------------------------------------
 S.No      Date         Author and Details
 -------------------------------------------------------------------------------
  1.       21/7/2005    Created by Aparajita for bug#4448293. Version#115.0.

                        Cleanup of TDS certificate and eTDS reporting.

  2.      25/10/2005    Harshita for Bug # 4643633/4640996, File Version 115.2
                        Issue :
                         In case of an insert into jai_ap_tds_payments for invoices created
                         prior to TDS clean up, vendor_id and vendor_site_id are passed as null.

                        Fix :
                         Called cursor c_ap_invoices_all to generate the vendor_id and vendor_site_id.
                         Inserted these values into the jai_ap_tds_payments table.

                         Dependency due to this Bug :
                         Yes.

  3.      26/10/2005   Harshita for Bug 4692310/4640996, File Version 115.4
                       Issue :
                         In the cursors c_process_old_tds_payments, c_process_tds_payments, c_tds_invoice_paid_by_prepay,
                         and during deletion from jai_ap_tds_payments during regeneration,
                         The  join < jiaot.organization_id = hou.legal_entity_id > is failing and the
                       Fix  :
                         Suggested code change is as follows ..
                           to_char(jiaot.organization_id) = hou.DEFAULT_LEGAL_CONTEXT_ID

                        Dependency due to this Bug :
                         Yes.

  4.      26/06/2006   Sanjikum for Bug#5219225, File version 115.5
                       1) Changes are done in procedure - process_tds_payments. Here changed the fnd log text at one place

  5.      26/09/2006   rchandan for bug#4742259, File Version 115.7
                       Purpose: Impact due to TCS solution.
                           Fix : A new column by name regime_code is added in jai_ap_tds_certificate_nums
                                 so that the same table can be used for TCS. Changes are made in this
                                 package accordingly
  6.			25/1/2007    CSahoo for BUG#5631784, File Version 120.1
  				     Forward Porting of BUG#4742259
  				     A new column by name regime_code is added in jai_ap_tds_certificate_nums
				     so that the same table can be used for TCS. Changes are made in this
		                     package accordingly
  7.	 29/03/2007   bduvarag for bug#5647725,File version 120.2
	               Forward porting the changes done in 11i bug#5647215

  8.14-may-07   kunkumar made changes for Budget and ST by IO and Build issues resolved8.14-may-07   kunkumar made changes for Budget and ST by IO and Build issues resolved8.14-may-07

  9. 12-06-2007 sacsethi for bug 6119195 file version 120.6

                R12RUP03-ST1: INDIA - PROCESS TDS PAYMENTS GIVES ERROR MESSAGE WHILE SUBMITTING

		Probelem - After execution of Concurrent India TDS Payments , some concurrent execution
		           error was coming - FDPSTP failed due to ORA-01861: literal does not match format string

                Solution - This problem was due to procedure process_tds_payments , Argument pd_tds_payment_from_date ,
		           pd_tds_payment_to_date parameter was of date type , whcih we made it as varchar2 and
			   create two variable with name ld_tds_payment_to_date ,ld_tds_payment_from_date

                           replae all pd_tds_payment_from_date , pd_tds_payment_to_date with
			   ld_tds_payment_from_date , ld_tds_payment_to_date with

10. 14-JUN-2007  Bgowrava for Bug#6129650, File Version 120.7
                 Removed the cursor c_hr_operating_units. changed the parameter of the cursor c_ja_in_tds_year_info
                 from r_hr_operating_units.default_legal_context_id to cur_ou.operating_unit_id.
                 Also removed the union codes in the cursors c_process_old_tds_payments, c_tds_invoice_paid_by_prepay,
                 c_process_tds_payments

11. 18-jan-2008  ssumaith - bug#6761239
                  prepayment applied to tds invoices was snot showing in the TDS
certificates report.

12. 21-FEB-2008 Changes done by nprashar for Bug  # 6774129. Added a condition in cursor c_tds_invoice_paid_by_prepay,in order to avoid the problem of
                              TDS CERTIFICATE NOT GETTING GENERATED FOR PARTIAL PREPAYMENTS.
13. 7-March-2008. Changes by nprashar for Bug # 6774129. Change in cursor c_group_for_no_certificate, along with cursor
                  c_group_for_certificate.
14. 6-june-2008  Changes by nprashar for bug # 6195566. Forward port 11i bug # 6124751.

15. 20-Oct-2008   Bgowrava for Bug 6069891.  File Version 120.7.12000000.8,  120.11.12010000.2
                         Created cursor c_tds_multiple_payments and
			 its related variables. Implemented logic for multiple
			 payments for single TDS invoice in procedure
			 process_tds_payments.

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
----------------------------------------------------------------------------------------------------------------------------------------------------

115.2,115.4           4640996          4601658           Pls refer BCT for the list
                                                         of dependent files.

---------------------------------------------------------------------------- */


---------------------------------------------------------------------------- */

/* ********************************  process_tds_payments *******************************************  */
    procedure process_tds_payments
    (
      errbuf                              out            nocopy    varchar2     ,
      retcode                             out            nocopy    varchar2     ,
      pd_tds_payment_from_date            in             varchar2                   ,
      pd_tds_payment_to_date              in             varchar2                   ,
      pv_org_tan_num                      in             varchar2               ,
      p_section_type                      in             varchar2,/*bduvarag for Bug#5647725*/
      pv_tds_section                      in             varchar2  default null ,
      pn_tds_authority_id                 in             number    default null ,
      pn_tds_authority_site_id            in             number    default null ,
      pn_vendor_id                        in             number    default null ,
      pn_vendor_site_id                   in             number    default null ,
      pv_regenerate_flag                  in             varchar2  default 'N'
    )
    is

       ld_tds_payment_from_date  date ;  --Date 12-jun-2007 sacsethi for bug 6119195
       ld_tds_payment_to_date    date;   --Date 12-jun-2007 sacsethi for bug 6119195
       lv_sts_lookup_code_argument1   constant varchar2(10) := 'VOIDED' ;
       lv_sts_lookup_code_argument2   constant varchar2(20) := 'STOP INITIATED' ;  --Date 12-jun-2007 sacsethi for bug 6119195  Length Increases
       lv_payment_status_flag            constant varchar2(1)  := 'Y' ;
       lv_pv_regenerate_flag             constant varchar2(1)  := 'Y' ;
       lv_source_attribute               constant varchar2(12) := 'ATTRIBUTE1';
       lv_attribute_category    constant varchar2(30)  := 'India Original Invoice for TDS';
       lv_source constant   varchar2(10):= 'INDIA TDS' ; /* 6761239 */
       lv_line_type_lookup_code constant varchar2(6) := 'PREPAY' ;
       lv_tds_event  constant varchar2(25) := 'PREPAYMENT APPLICATION' ; --Date 12-jun-2007 sacsethi for bug 6119195 Length Increases


      cursor c_process_tds_payments
      (
        pd_tds_payment_from_date           date      ,
        pd_tds_payment_to_date             date      ,
        pv_org_tan_num                     varchar2  ,
        pv_tds_section                     varchar2  ,
        pn_tds_authority_id                number    ,
        pn_tds_authority_site_id           number    ,
        pn_vendor_id                       number    ,
        pn_vendor_site_id                  number
      )
      is
        select
          aca.org_id                            org_id                   ,
          aca.check_id                          check_id                 ,
          aca.check_number                      check_number             ,
          aca.check_date                        check_date               ,
          aca.amount                            check_amount             ,
          aipa.invoice_payment_id               invoice_payment_id       ,
          aipa.invoice_id                       invoice_id               ,
          aia.invoice_num                       invoice_num              ,
          aia.invoice_date                      invoice_date             ,
          aipa.amount                           payment_amount           ,
          jitc.section_code                     section_code             ,
          jattt.tax_id                          tax_id                   ,
          jattt.tax_rate                        tax_rate                 ,
          jattt.threshold_trx_id                threshold_trx_id         ,
          jattt.invoice_id                      parent_invoice_id        ,
          jattt.tds_event                       tds_event                ,
          jattt.taxable_amount                  taxable_basis            ,
          jattt.invoice_to_tds_authority_amt    tax_amount               ,
          jattt.tds_authority_vendor_id         tax_authority_id         ,
          jattt.tds_authority_vendor_site_id    tax_authority_site_id    ,
          jattt.vendor_id                       vendor_id                ,
          jattt.vendor_site_id                  vendor_site_id
        from
          ap_checks_all aca             ,
          ap_invoice_payments_all aipa  ,
          ap_invoices_all aia           ,
          jai_ap_tds_thhold_trxs   jattt,
          JAI_CMN_TAXES_ALL          jitc
        where
               aca.check_id                         = aipa.check_id
        and    aipa.invoice_id                      = jattt.invoice_to_tds_authority_id
        and    aipa.invoice_id                      = aia.invoice_id
        and    jattt.tax_id                         = jitc.tax_id
        and    aia.invoice_date                       between pd_tds_payment_from_date and pd_tds_payment_to_date
        and    aca.status_lookup_code               NOT IN (lv_sts_lookup_code_argument1, lv_sts_lookup_code_argument2)
        and    ( (aia.payment_status_flag = lv_payment_status_flag)
                 or
                 ( nvl( aia.invoice_amount, 0 ) =  nvl(aia.amount_paid, 0 ) )
               )
        and    aca.org_id in
        (
          select organization_id org_id
          from   JAI_AP_TDS_ORG_TAN_V
          where  org_tan_num = pv_org_tan_num
          --Removed the union code by Bgowrava for Bug#6129650
        )
        and    jattt.tds_authority_vendor_id        = nvl(pn_tds_authority_id, jattt.tds_authority_vendor_id)
        and    jattt.tds_authority_vendor_site_id   = nvl(pn_tds_authority_site_id, jattt.tds_authority_vendor_site_id)
        and    jattt.vendor_id                      = nvl(pn_vendor_id, jattt.vendor_id)
        and    jattt.vendor_site_id                 = nvl(pn_vendor_site_id, jattt.vendor_site_id)
        and    jitc.section_type                    = p_section_type -- 5647725, 6109941 brathod
        and    nvl(jitc.section_code,'XYZ')         = nvl(pv_tds_section,nvl(jitc.section_code,'XYZ')) /*bduvarag for Bug#5647725*/
        and    nvl(jitc.section_code,'XYZ')                   = nvl(pv_tds_section, section_code)
/*bduvarag for Bug#5647725*/
        and    not exists (
                            select '1'
                            from   JAI_AP_TDS_INV_PAYMENTS
                            where  check_id =  aca.check_id
			    and vendor_id = jattt.vendor_id  /*Added by nprashar for bug # 6195566*/
		            and invoice_id = aipa.invoice_id  /*Added by nprashar for bug # 6195566*/
                            and  tds_tax_id in  /*bduvarag for Bug#5647725*/
		            (
		                  select tax_id from JAI_CMN_TAXES_ALL where tax_type = 'TDS'
                                                   and section_type = p_section_type)
                          )
        ;

      cursor c_process_old_tds_payments
      (
        pd_tds_payment_from_date           date      ,
        pd_tds_payment_to_date             date      ,
        pv_org_tan_num                     varchar2  ,
        pn_tds_authority_id                number    ,
        pn_tds_authority_site_id           number
      )
      is
        select
          aca.org_id                              org_id                  ,
          aca.check_id                            check_id                ,
          aca.check_number                        check_number            ,
          aca.amount                              check_amount            ,
          aca.check_date                          check_date              ,
          aipa.invoice_payment_id                 invoice_payment_id      ,
          aipa.amount                             payment_amount          ,
          aia.invoice_id                          invoice_id              ,
          aia.invoice_num                         invoice_num             ,
          aia.invoice_date                        invoice_date            ,
          aia.invoice_amount                      tax_amount              ,
          aia.vendor_id                           tax_authority_id        ,
          aia.vendor_site_id                      tax_authority_site_id   ,
          nvl(aia.attribute_category,
              lv_attribute_category)   context                 ,
          aia.attribute1                          parent_invoice_id
        from
          ap_checks_all           aca,
          ap_invoice_payments_all aipa,
          ap_invoices_all         aia
        where  aca.check_id             = aipa.check_id
        and    aipa.invoice_id          = aia.invoice_id
        and    aia.source               = lv_source
        and    aia.invoice_date             between pd_tds_payment_from_date and pd_tds_payment_to_date
        and    aca.status_lookup_code     NOT IN  (lv_sts_lookup_code_argument1, lv_sts_lookup_code_argument2)
        and    ( (aia.payment_status_flag = lv_payment_status_flag)
                 or
                 ( nvl( aia.invoice_amount, 0 ) =  nvl(aia.amount_paid, 0 ) )
               )
        and    aia.vendor_id            =         nvl(pn_tds_authority_id, aia.vendor_id)
        and    aia.vendor_site_id       =         nvl(pn_tds_authority_site_id, aia.vendor_site_id)
        /*Added by nprashar for bug # 6195566*/
	and EXISTS ( SELECT 'Y'
                            FROM po_vendors pv
			   WHERE pv.vendor_id = aia.vendor_id
			       AND pv.vendor_type_lookup_code = 'INDIA TDS AUTHORITY'
                        )
   	and    aca.org_id in
        (
          select organization_id org_id
          from   JAI_AP_TDS_ORG_TAN_V
          where  org_tan_num = pv_org_tan_num
          --Removed the union code by Bgowrava for Bug#6129650
        )
        and    not exists (
                            select '1'
                            from   JAI_AP_TDS_INV_PAYMENTS
                            where  invoice_id =  aia.invoice_id
                          )
      and    not exists (
                          SELECT 1
                            FROM jai_ap_tds_thhold_trxs
                           WHERE invoice_to_tds_authority_id = aia.invoice_id
                         )/*bduvarag for Bug#5647725*/

        ;

      cursor c_ap_invoices_all(pn_invoice_id number) is
        select
          vendor_id,
          vendor_site_id,
          cancelled_date
        from
          ap_invoices_all
        where  invoice_id = pn_invoice_id;

      cursor c_JAI_AP_TDS_INVOICES(pn_parent_invoice_id number, pv_tds_invoice_num varchar2) is
        select
          invoice_id              parent_invoice_id ,
          invoice_amount          taxable_basis     ,
          tds_tax_id              tds_tax_id        ,
          tds_section             tds_section       ,
          tds_tax_rate            tds_tax_rate      ,
          tds_amount              tax_amount
        from
          JAI_AP_TDS_INVOICES
        where  invoice_id         =  nvl(pn_parent_invoice_id, invoice_id)
        and    tds_invoice_num    =  pv_tds_invoice_num
        and    source_attribute   = lv_source_attribute;

      /* identifies parent on basis of invoice number */
      cursor c_JAI_AP_TDS_INVOICES_1(pv_tds_invoice_num varchar2) is
        select
          invoice_id              parent_invoice_id ,
          invoice_amount          taxable_basis     ,
          tds_tax_id              tds_tax_id        ,
          tds_section             tds_section       ,
          tds_tax_rate            tds_tax_rate      ,
          tds_amount              tax_amount
        from
          JAI_AP_TDS_INVOICES
        where  tds_invoice_num    =  pv_tds_invoice_num
        and    source_attribute   = lv_source_attribute;



      cursor c_get_section_if_one(pn_invoice_id number) is
        select jiati_1.tds_section
        from   JAI_AP_TDS_INVOICES jiati_1
        where  jiati_1.invoice_id = pn_invoice_id
        and    source_attribute = lv_source_attribute
        and    not exists
              (
                select '1'
                from   JAI_AP_TDS_INVOICES jiati_2
                where  jiati_1.rowid <> jiati_2.rowid
                and    source_attribute = lv_source_attribute
                and    jiati_1.invoice_id = jiati_2.invoice_id
                and    jiati_1.tds_section <> jiati_2.tds_section
              );


      cursor c_get_tax_if_one(pn_invoice_id number) is
        select
          jiati_1.tds_tax_id ,
          jiati_1.tds_tax_rate
        from   JAI_AP_TDS_INVOICES jiati_1
        where  jiati_1.invoice_id = pn_invoice_id
        and    source_attribute = lv_source_attribute
        and    not exists
               (
                select '1'
                from   JAI_AP_TDS_INVOICES jiati_2
                where  jiati_1.rowid <> jiati_2.rowid
                and    source_attribute = lv_source_attribute
                and    jiati_1.invoice_id = jiati_2.invoice_id
                and    jiati_1.tds_tax_id <> jiati_2.tds_tax_id
                );


      cursor c_tds_invoice_paid_by_prepay
      (
        pd_tds_payment_from_date     date,
        pd_tds_payment_to_date       date,
        pv_org_tan_num               varchar2,
        pn_tds_authority_id          number,
        pn_tds_authority_site_id     number
      )
      is
    select
          aia.org_id                              org_id                  ,
          aia.invoice_id                          invoice_id              ,
          aia.invoice_num                         invoice_num             ,
          aia.invoice_date                        invoice_date            ,
          aia.invoice_amount                      tax_amount              ,
          aia.vendor_id                           tax_authority_id        ,
          aia.vendor_site_id                      tax_authority_site_id   ,
          nvl(aia.attribute_category,
              lv_attribute_category)   context                 ,
          aia.attribute1                          parent_invoice_id       ,
          aida_prepayment.invoice_id              prepay_invoice_id       ,
           -1 * sum(aida.amount)                  prepaid_amount
        from
          ap_invoices_all         aia,
          ap_invoice_distributions_all aida,
          ap_invoice_distributions_all aida_prepayment
        where aia.invoice_id = aida.invoice_id
        and   aida.prepay_distribution_id = aida_prepayment.invoice_distribution_id
        and   aida.line_type_lookup_code = lv_line_type_lookup_code
        and   aia.source               = lv_source
        and   aia.invoice_date             between pd_tds_payment_from_date and pd_tds_payment_to_date
        and    ( (aia.payment_status_flag = lv_payment_status_flag)
                 or
                 ( nvl( aia.invoice_amount, 0 ) =  nvl(aia.amount_paid, 0 ) )
               )
        and    aia.vendor_id            =         nvl(pn_tds_authority_id, aia.vendor_id)
        and    aia.vendor_site_id       =         nvl(pn_tds_authority_site_id, aia.vendor_site_id)
        and    aia.org_id in
        (
          select organization_id org_id
          from   JAI_AP_TDS_ORG_TAN_V
          where  org_tan_num = pv_org_tan_num
          --Removed the union code by Bgowrava for Bug#6129650
        )
        and    not exists (
                            select '1'
			    from   JAI_AP_TDS_INV_PAYMENTS  jatip
                            where  jatip.invoice_id =  aia.invoice_id
			    and  jatip.prepay_invoice_id = aida_prepayment.invoice_id ) --Added by nprashar for Bug # 6774129
        having sum(aida.amount) <> 0 -- Added by nprashar for Bug # 6774129
        group by
         aia.org_id                                                     ,
         aia.invoice_id                                                 ,
         aia.invoice_num                                                ,
         aia.invoice_date                                               ,
         aia.invoice_amount                                             ,
         aia.vendor_id                                                  ,
         aia.vendor_site_id                                             ,
         nvl(aia.attribute_category, lv_attribute_category)  ,
         aia.attribute1                                                 ,
         aida_prepayment.invoice_id
        ;

      cursor c_jai_ap_tds_thhold_trxs(pn_invoice_to_tds_authority_id number) is
      select
        jatt.threshold_trx_id,
        jatt.invoice_id,
        jatc.section_code tds_section,
        jatt.tax_id,
        jatt.tax_rate,
        jatt.taxable_amount,
        jatt.tax_amount,
        jatt.vendor_id,
        jatt.vendor_site_id
     from
      jai_ap_tds_thhold_trxs jatt,
      JAI_CMN_TAXES_ALL jatc
    where
      jatt.invoice_to_tds_authority_id = pn_invoice_to_tds_authority_id
    and  jatc.tax_id = jatt.tax_id
      and  jatc.section_type                = p_section_type /*bduvarag for Bug#5647725*/  ;

      cursor c_get_payment_details(pn_invoice_id number) is
      select
        aca.check_id                check_id,
        aca.check_date              check_date,
        aca.amount                  check_amount,
        aipa.invoice_payment_id     invoice_payment_id
      from
        ap_checks_all aca,
        ap_invoice_payments_all aipa
      where aca.check_id = aipa.check_id
      and   aipa.invoice_id =   pn_invoice_id;

       cursor c_get_total_tax_basis ( cp_invoice_id number) is  /*Added by nprashar for Bug # 6774129*/
       select sum(nvl(taxable_basis,0))
        from jai_ap_tds_inv_payments
        where invoice_id = cp_invoice_id;

/* START, Bgowrava for Bug#6069891*/

    CURSOR  c_tds_multiple_payments IS
     SELECT  jatp.*
       FROM  jai_ap_tds_inv_payments jatp
     WHERE  (jatp.invoice_id , jatp.taxable_basis,
                 jatp.tax_amount, jatp.tds_tax_id ) IN
    (SELECT invoice_id, taxable_basis, tax_amount , tds_tax_id
        FROM  jai_ap_tds_inv_payments
     GROUP BY  invoice_id, taxable_basis, tax_amount , tds_tax_id
     having count(*) > 1
    )
        AND  jatp.check_id NOT  IN  /* Filter out all voided and stop initiated checks*/
    (SELECT  check_id
        FROM ap_checks_all ac
      WHERE ac.check_id = jatp.check_id
          AND status_lookup_code in ('VOIDED', 'STOP INITIATED')
    )
       AND  TRUNC(jatp.creation_date) = TRUNC (sysdate)
       AND jatp.form16_hdr_id IS NULL /*Pick up payments for which certificates are not generated */
       ORDER BY tds_payment_id DESC ;

    r_ap_tds_payments  c_tds_multiple_payments%ROWTYPE ;
    TYPE get_tds_inv_details IS RECORD
    ( tds_payment_id  NUMBER ,
      taxable_basis     NUMBER ,
      invoice_id          NUMBER
    );
    TYPE get_tds_inv_details_tab IS TABLE OF get_tds_inv_details
      INDEX BY BINARY_INTEGER ;
    r_get_tds_inv_details get_tds_inv_details_tab;
    tab_index NUMBER;
    ln_temp_invoice_id NUMBER ;
 /* END, Bgowrava for Bug#6069891*/

      ln_program_id                   number;
      ln_program_login_id             number;
      ln_program_application_id       number;
      ln_request_id                   number;
      ln_user_id                      number(15);
      ln_last_update_login            number(15);
      ln_taxable_basis                number;
      lv_parent_invoice_cancel_flag   varchar2(1);
      ln_parent_invoice_id              number(15);
      lv_section_code                 varchar2(30);
      ln_tax_id                       number(15);
      ln_tax_rate                     number;
      ln_tax_amount                   number;
      ln_vendor_id                    number(15);
      ln_vendor_site_id               number(15);


      r_ap_invoices_all               c_ap_invoices_all%rowtype;
      r_JAI_AP_TDS_INVOICES         c_JAI_AP_TDS_INVOICES%rowtype;
      ln_record_count                 number;
      ln_threshold_trx_id             number;
      r_get_payment_details           c_get_payment_details%rowtype;

    -- Bug 6774129. Added by Lakshmi Gopalsami
    -- Observation as part of QA.
      ln_inv_tax_basis NUMBER;
    begin


      /* Get the statis fnd values for populating into the table */
      Fnd_File.put_line(Fnd_File.LOG, '** Start of procedure jai_ap_tds_processing_pkg.process_tds_payments **');
      ln_record_count             :=   0;
      ln_user_id                  :=   fnd_global.user_id;
      ln_last_update_login        :=   fnd_global.login_id          ;
      ln_program_id               :=   fnd_global.conc_program_id   ;
      ln_program_login_id         :=   fnd_global.conc_login_id     ;
      ln_program_application_id   :=   fnd_global.prog_appl_id      ;
      ln_request_id               :=   fnd_global.conc_request_id   ;


      ld_tds_payment_from_date :=   fnd_date.canonical_to_date(pd_tds_payment_from_date);--Date 12-jun-2007 sacsethi for bug 6119195
      ld_tds_payment_to_date :=   fnd_date.canonical_to_date(pd_tds_payment_to_date);--Date 12-jun-2007 sacsethi for bug 6119195
      /* Check regenerate option */
      if pv_regenerate_flag = lv_pv_regenerate_flag  then

        /* Flush the check records that have been processed earlier but are not paid */
        Fnd_File.put_line(Fnd_File.LOG, ' Flushing the data as regenration option is set to Yes');
        delete  JAI_AP_TDS_INV_PAYMENTS
        where   check_id in
          (
            select
              aca.check_id                          check_id
            from
              ap_checks_all aca             ,
              ap_invoice_payments_all aipa  ,
              ap_invoices_all aia           ,
              jai_ap_tds_thhold_trxs   jattt,
              JAI_CMN_TAXES_ALL          jitc
            where
                   aca.check_id                         = aipa.check_id
            and    aipa.invoice_id                      = jattt.invoice_to_tds_authority_id
            and    aipa.invoice_id                      = aia.invoice_id
            and    jattt.tax_id                         = jitc.tax_id
            and    aia.invoice_date                     between ld_tds_payment_from_date and ld_tds_payment_to_date
            and    aca.status_lookup_code               NOT IN (lv_sts_lookup_code_argument1, lv_sts_lookup_code_argument2)
            and    aca.org_id in
            (
              select organization_id org_id
              from   JAI_AP_TDS_ORG_TAN_V
              where  org_tan_num = pv_org_tan_num
              --Removed the union code by Bgowrava for Bug#6129650
            )
            and    jattt.tds_authority_vendor_id        = nvl(pn_tds_authority_id, jattt.tds_authority_vendor_id)
            and    jattt.tds_authority_vendor_site_id   = nvl(pn_tds_authority_site_id, jattt.tds_authority_vendor_site_id)
            and    jattt.vendor_id                      = nvl(pn_vendor_id, jattt.vendor_id)
            and    jattt.vendor_site_id                 = nvl(pn_vendor_site_id, jattt.vendor_site_id)
          and    nvl(jitc.section_code,'XYZ')         = nvl(pv_tds_section,nvl(jitc.section_code,'XYZ')) /*bduvarag for Bug#5647725*/
          )
        and   form16_hdr_id is null;

        Fnd_File.put_line(Fnd_File.LOG, ' No of records flushed : ' || to_char(sql%rowcount) );

      end if;  /*if pv_regenerate_flag = 'Y' */


      /* Get all payments from ap_checks_all */
      Fnd_File.put_line(Fnd_File.LOG, 'Start Processing Payment **');
      for cur_rec in
      c_process_tds_payments
      (
        ld_tds_payment_from_date         ,
        ld_tds_payment_to_date           ,
        pv_org_tan_num                   ,
        pv_tds_section                   ,
        pn_tds_authority_id              ,
        pn_tds_authority_site_id         ,
        pn_vendor_id                     ,
        pn_vendor_site_id
      )
      loop

        Fnd_File.put_line(Fnd_File.LOG, ' Processing Invoice / Check  : ' || cur_rec.invoice_num || ' / ' || cur_rec.check_number );

        ln_taxable_basis :=  cur_rec.taxable_basis;
        lv_parent_invoice_cancel_flag := null;

        if  ln_taxable_basis is null then
          ln_taxable_basis := cur_rec.tax_amount  * (100/cur_rec.tax_rate);
        end if;

        if cur_rec.tds_event in (lv_tds_event) then
          /* For prepayment application, taxable basis should be negative */
          ln_taxable_basis := -1 * ln_taxable_basis;
        end if;

        open  c_ap_invoices_all(cur_rec.parent_invoice_id);
        fetch c_ap_invoices_all into r_ap_invoices_all;
        close c_ap_invoices_all;

        if r_ap_invoices_all.cancelled_date is not null then
          lv_parent_invoice_cancel_flag := 'Y';
        end if;

        insert into JAI_AP_TDS_INV_PAYMENTS
        (
          tds_payment_id                 ,
          check_id                       ,
          check_amount                   ,
          check_date                     ,
          invoice_payment_id             ,
          payment_amount                 ,
          invoice_id                     ,
          invoice_date                   ,
          parent_invoice_id              ,
          parent_invoice_cancel_flag     ,
          threshold_trx_id               ,
          tds_section                    ,
          tds_tax_id                     ,
          tds_tax_rate                   ,
          taxable_basis                  ,
          tax_amount                     ,
          tax_authority_id               ,
          tax_authority_site_id          ,
          vendor_id                      ,
          vendor_site_id                 ,
          org_tan_num                    ,
          operating_unit_id              ,
          created_by                     ,
          creation_date                  ,
          last_updated_by                ,
          last_update_date               ,
          last_update_login              ,
          program_id                     ,
          program_login_id               ,
          program_application_id         ,
          request_id
        )
        values
        (
          jai_ap_tds_inv_payments_s.nextval  ,
          cur_rec.check_id               ,
          cur_rec.check_amount           ,
          cur_rec.check_date             ,
          cur_rec.invoice_payment_id     ,
          cur_rec.payment_amount         ,
          cur_rec.invoice_id             ,
          cur_rec.invoice_date           ,
          cur_rec.parent_invoice_id      ,
          lv_parent_invoice_cancel_flag  ,
          cur_rec.threshold_trx_id       ,
          cur_rec.section_code           ,
          cur_rec.tax_id                 ,
          cur_rec.tax_rate               ,
          ln_taxable_basis               ,
          cur_rec.tax_amount             ,
          cur_rec.tax_authority_id       ,
          cur_rec.tax_authority_site_id  ,
          cur_rec.vendor_id              ,
          cur_rec.vendor_site_id         ,
          pv_org_tan_num                 ,
          cur_rec.org_id                 ,
          ln_user_id                     ,
          sysdate                        ,
          ln_user_id                     ,
          sysdate                        ,
          ln_last_update_login           ,
          ln_program_id                  ,
          ln_program_login_id            ,
          ln_program_application_id      ,
          ln_request_id
        );

        ln_record_count := ln_record_count + 1;
      end loop;  /*  process tds payments  */


      /* Check for invoices generated prior to TDS threshold patch */
      --Fnd_File.put_line(Fnd_File.LOG, 'Start Processing Invoices created prior to TDS clean up if any **');
      --commented the above and added the below by Sanjikum for Bug#5219225
      Fnd_File.put_line(Fnd_File.LOG, 'Start Processing Invoices created prior to TDS Threshold if any **');

      for cur_rec in
      c_process_old_tds_payments
      (
        ld_tds_payment_from_date         ,
        ld_tds_payment_to_date           ,
        pv_org_tan_num                   ,
        pn_tds_authority_id              ,
        pn_tds_authority_site_id
      )
      loop

        Fnd_File.put_line(Fnd_File.LOG, ' Processing Invoice / Check  : ' || cur_rec.invoice_num || ' / ' || cur_rec.check_number );
        ln_parent_invoice_id            :=    null;
        lv_parent_invoice_cancel_flag   :=    null;
        lv_section_code                 :=    null;
        ln_tax_id                       :=    null;
        ln_tax_rate                     :=    null;
        ln_taxable_basis                :=    null;
        ln_vendor_id                    :=    null;
        ln_vendor_site_id               :=    null;

        r_ap_invoices_all               :=    null;
        r_JAI_AP_TDS_INVOICES         :=    null;

        ln_tax_amount := cur_rec.tax_amount;


        if cur_rec.context = lv_attribute_category and cur_rec.parent_invoice_id is not null then
          ln_parent_invoice_id := cur_rec.parent_invoice_id;
        end if;

        if ln_parent_invoice_id is not null then
          open  c_JAI_AP_TDS_INVOICES(ln_parent_invoice_id, cur_rec.invoice_num);
          fetch c_JAI_AP_TDS_INVOICES into r_JAI_AP_TDS_INVOICES;
          close c_JAI_AP_TDS_INVOICES;
        else
          /* try n find the parent based on invoice number */
          open  c_JAI_AP_TDS_INVOICES_1(cur_rec.invoice_num);
          fetch c_JAI_AP_TDS_INVOICES_1 into r_JAI_AP_TDS_INVOICES;
          close c_JAI_AP_TDS_INVOICES_1;
        end if;

        if ln_parent_invoice_id is null and r_JAI_AP_TDS_INVOICES.parent_invoice_id is null then
          /*  parent is not found in ap_invoices_all or JAI_AP_TDS_INVOICES,
              no other details can be found */
          goto populate_old_invoice_details;
        end if;

        /* A parent invoice has been traced, check if it passes filtering condition of vendor and site if given */
        if pn_vendor_id is not null or pn_vendor_site_id is not null then
          open  c_ap_invoices_all( nvl(ln_parent_invoice_id, r_JAI_AP_TDS_INVOICES.parent_invoice_id) );
          fetch c_ap_invoices_all into r_ap_invoices_all;
          close c_ap_invoices_all;

          if r_ap_invoices_all.vendor_id <> nvl(pn_vendor_id, r_ap_invoices_all.vendor_id) or
             r_ap_invoices_all.vendor_site_id <> nvl(pn_vendor_site_id, r_ap_invoices_all.vendor_site_id)
          then
            goto continue_with_next_record;
          end if;

        end if; /* checking parent vendor or site */


        if ln_parent_invoice_id is not null and r_JAI_AP_TDS_INVOICES.parent_invoice_id is null then
          /* parent invoice has been found, but details not captured in JAI_AP_TDS_INVOICES.
             could be a return invoice, check if only one section was applicable against the parent and populate if so */
          open  c_get_section_if_one(ln_parent_invoice_id);
          fetch c_get_section_if_one into lv_section_code;
          close c_get_section_if_one;

          if lv_section_code <> nvl(pv_tds_section, lv_section_code) then
            goto continue_with_next_record;
          end if;

          if lv_section_code is not null then
            open  c_get_tax_if_one(ln_parent_invoice_id);
            fetch c_get_tax_if_one into ln_tax_id, ln_tax_rate;
            close c_get_tax_if_one;

            ln_taxable_basis := ln_tax_amount  * (100/ln_tax_rate);
          end if;

        elsif r_JAI_AP_TDS_INVOICES.parent_invoice_id  is not null then
          /* A record in ja_in_ap_tds_invoice has been identified */

          if r_JAI_AP_TDS_INVOICES.tds_section <> nvl(pv_tds_section, r_JAI_AP_TDS_INVOICES.tds_section) then
             goto continue_with_next_record;
          end if;

          ln_parent_invoice_id := r_JAI_AP_TDS_INVOICES.parent_invoice_id;
          lv_section_code      := r_JAI_AP_TDS_INVOICES.tds_section;
          ln_tax_id            := r_JAI_AP_TDS_INVOICES.tds_tax_id;
          ln_tax_rate          := r_JAI_AP_TDS_INVOICES.tds_tax_rate;
          ln_taxable_basis     := r_JAI_AP_TDS_INVOICES.taxable_basis;
          ln_tax_amount        := r_JAI_AP_TDS_INVOICES.tax_amount;

        end if;

        -- added, Harshita for Bug 4643633
        open  c_ap_invoices_all(ln_parent_invoice_id );
        fetch c_ap_invoices_all into r_ap_invoices_all;
        close c_ap_invoices_all;
        -- ended, Harshita for Bug 4643633

        << populate_old_invoice_details >>
        insert into JAI_AP_TDS_INV_PAYMENTS
        (
          tds_payment_id                 ,
          check_id                       ,
          check_amount                   ,
          check_date                     ,
          invoice_payment_id             ,
          payment_amount                 ,
          invoice_id                     ,
          invoice_date                   ,
          parent_invoice_id              ,
          parent_invoice_cancel_flag     ,
          threshold_trx_id               ,
          tds_section                    ,
          tds_tax_id                     ,
          tds_tax_rate                   ,
          taxable_basis                  ,
          tax_amount                     ,
          tax_authority_id               ,
          tax_authority_site_id          ,
          vendor_id                      ,
          vendor_site_id                 ,
          org_tan_num                    ,
          operating_unit_id              ,
          source                         ,
          created_by                     ,
          creation_date                  ,
          last_updated_by                ,
          last_update_date               ,
          last_update_login              ,
          program_id                     ,
          program_login_id               ,
          program_application_id         ,
          request_id
        )
        values
        (
          jai_ap_tds_inv_payments_s.nextval  ,
          cur_rec.check_id               ,
          cur_rec.check_amount           ,
          cur_rec.check_date             ,
          cur_rec.invoice_payment_id     ,
          cur_rec.payment_amount         ,
          cur_rec.invoice_id             ,
          cur_rec.invoice_date           ,
          ln_parent_invoice_id           ,
          lv_parent_invoice_cancel_flag  ,
          null                           ,
          lv_section_code                ,
          ln_tax_id                      ,
          ln_tax_rate                    ,
          ln_taxable_basis               ,
          ln_tax_amount                  ,
          cur_rec.tax_authority_id       ,
          cur_rec.tax_authority_site_id  ,
          r_ap_invoices_all.vendor_id,          --ln_vendor_id       ,  Harshita for Bug 4643633
          r_ap_invoices_all.vendor_site_id ,    --ln_vendor_site_id  ,  Harshita for Bug 4643633
          pv_org_tan_num                 ,
          cur_rec.org_id                 ,
          'Invoice prior to threshold'   ,
          ln_user_id                     ,
          sysdate                        ,
          ln_user_id                     ,
          sysdate                        ,
          ln_last_update_login           ,
          ln_program_id                  ,
          ln_program_login_id            ,
          ln_program_application_id      ,
          ln_request_id
        );

        ln_record_count := ln_record_count + 1;

        << continue_with_next_record >>
        null;

      end loop; /* c_process_old_tds_payments */

      /* Payemnt by Prepayments */
      Fnd_File.put_line(Fnd_File.LOG, 'Processing Prepayment if any ');

      for cur_rec in
      c_tds_invoice_paid_by_prepay
      (
        ld_tds_payment_from_date            ,
        ld_tds_payment_to_date              ,
        pv_org_tan_num                      ,
        pn_tds_authority_id                 ,
        pn_tds_authority_site_id
      )
      loop

        Fnd_File.put_line(Fnd_File.LOG, ' Processing Invoice / Prepayment invoice id   : ' || cur_rec.invoice_num || ' / ' || cur_rec.prepay_invoice_id );

        ln_threshold_trx_id             :=    null;
        ln_parent_invoice_id            :=    null;
        lv_parent_invoice_cancel_flag   :=    null;
        lv_section_code                 :=    null;
        ln_tax_id                       :=    null;
        ln_tax_rate                     :=    null;
        ln_taxable_basis                :=    null;
        ln_vendor_id                    :=    null;
        ln_vendor_site_id               :=    null;

        r_ap_invoices_all               :=    null;
        r_JAI_AP_TDS_INVOICES         :=    null;


        /* Get payment information against the prepayment */
        r_get_payment_details := null;
        open  c_get_payment_details(cur_rec.prepay_invoice_id);
        fetch c_get_payment_details into r_get_payment_details;
        close c_get_payment_details;

        /* Check if the TDS invoice is created post clean up then get all info from there */
        open  c_jai_ap_tds_thhold_trxs(cur_rec.invoice_id);
        fetch c_jai_ap_tds_thhold_trxs into
          ln_threshold_trx_id,
          ln_parent_invoice_id,
          lv_section_code     ,
          ln_tax_id,
          ln_tax_rate,
          ln_taxable_basis,
          ln_tax_amount,
          ln_vendor_id,
          ln_vendor_site_id;
        close c_jai_ap_tds_thhold_trxs;

        if ln_threshold_trx_id is not null then
          goto populate_invoice_details;
        end if;


        ln_tax_amount := cur_rec.tax_amount;

        if cur_rec.context = lv_attribute_category and cur_rec.parent_invoice_id is not null then
          ln_parent_invoice_id := cur_rec.parent_invoice_id;
        end if;

        if ln_parent_invoice_id is not null then
          open  c_JAI_AP_TDS_INVOICES(ln_parent_invoice_id, cur_rec.invoice_num);
          fetch c_JAI_AP_TDS_INVOICES into r_JAI_AP_TDS_INVOICES;
          close c_JAI_AP_TDS_INVOICES;
        else
          /* try n find the parent based on invoice number */
          open  c_JAI_AP_TDS_INVOICES_1(cur_rec.invoice_num);
          fetch c_JAI_AP_TDS_INVOICES_1 into r_JAI_AP_TDS_INVOICES;
          close c_JAI_AP_TDS_INVOICES_1;
        end if;

        if ln_parent_invoice_id is null and r_JAI_AP_TDS_INVOICES.parent_invoice_id is null then
          /*  parent is not found in ap_invoices_all or JAI_AP_TDS_INVOICES,
              no other details can be found */
          goto populate_invoice_details;
        end if;

        /* A parent invoice has been traced, check if it passes filtering condition of vendor and site if given */
        if pn_vendor_id is not null or pn_vendor_site_id is not null then
          open  c_ap_invoices_all( nvl(ln_parent_invoice_id, r_JAI_AP_TDS_INVOICES.parent_invoice_id) );
          fetch c_ap_invoices_all into r_ap_invoices_all;
          close c_ap_invoices_all;

          if r_ap_invoices_all.vendor_id <> nvl(pn_vendor_id, r_ap_invoices_all.vendor_id) or
             r_ap_invoices_all.vendor_site_id <> nvl(pn_vendor_site_id, r_ap_invoices_all.vendor_site_id)
          then
            goto continue_with_next_record;
          end if;

        end if; /* checking parent vendor or site */


        if ln_parent_invoice_id is not null and r_JAI_AP_TDS_INVOICES.parent_invoice_id is null then
          /* parent invoice has been found, but details not captured in JAI_AP_TDS_INVOICES.
             could be a return invoice, check if only one section was applicable against the parent and populate if so */
          open  c_get_section_if_one(ln_parent_invoice_id);
          fetch c_get_section_if_one into lv_section_code;
          close c_get_section_if_one;

          if lv_section_code <> nvl(pv_tds_section, lv_section_code) then
            goto continue_with_next_record;
          end if;

          if lv_section_code is not null then
            open  c_get_tax_if_one(ln_parent_invoice_id);
            fetch c_get_tax_if_one into ln_tax_id, ln_tax_rate;
            close c_get_tax_if_one;

            ln_taxable_basis := ln_tax_amount  * (100/ln_tax_rate);
          end if;

        elsif r_JAI_AP_TDS_INVOICES.parent_invoice_id  is not null then
          /* A record in ja_in_ap_tds_invoice has been identified */

          if r_JAI_AP_TDS_INVOICES.tds_section <> nvl(pv_tds_section, r_JAI_AP_TDS_INVOICES.tds_section) then
             goto continue_with_next_record;
          end if;

          ln_parent_invoice_id := r_JAI_AP_TDS_INVOICES.parent_invoice_id;
          lv_section_code      := r_JAI_AP_TDS_INVOICES.tds_section;
          ln_tax_id            := r_JAI_AP_TDS_INVOICES.tds_tax_id;
          ln_tax_rate          := r_JAI_AP_TDS_INVOICES.tds_tax_rate;
          ln_taxable_basis     := r_JAI_AP_TDS_INVOICES.taxable_basis;
          ln_tax_amount        := r_JAI_AP_TDS_INVOICES.tax_amount;

        end if;

        << populate_invoice_details >>
       -- bug 6774129. Added by Lakshmi Gopalsami
	-- Observation as part of QA.
	-- Get the sum of taxable basis for the already existing line
	-- so that the difference will be updated for prepay lines.


	Open c_get_total_tax_basis(cur_rec.invoice_id);
        fetch c_get_total_tax_basis into ln_inv_tax_basis;
	Close c_get_total_tax_basis;

        ln_tax_amount := cur_rec.prepaid_amount;
	ln_taxable_basis := ln_inv_tax_basis - ln_taxable_basis;
	-- End for bug 6774129

	insert into JAI_AP_TDS_INV_PAYMENTS
        (
          tds_payment_id                 ,
          check_id                       ,
          check_amount                   ,
          check_date                     ,
          invoice_payment_id             ,
          prepay_invoice_id              ,
          payment_amount                 ,
          invoice_id                     ,
          invoice_date                   ,
          parent_invoice_id              ,
          parent_invoice_cancel_flag     ,
          threshold_trx_id               ,
          tds_section                    ,
          tds_tax_id                     ,
          tds_tax_rate                   ,
          taxable_basis                  ,
          tax_amount                     ,
          tax_authority_id               ,
          tax_authority_site_id          ,
          vendor_id                      ,
          vendor_site_id                 ,
          org_tan_num                    ,
          operating_unit_id              ,
          source                         ,
          created_by                     ,
          creation_date                  ,
          last_updated_by                ,
          last_update_date               ,
          last_update_login              ,
          program_id                     ,
          program_login_id               ,
          program_application_id         ,
          request_id
        )
        values
        (
          jai_ap_tds_inv_payments_s.nextval            ,
          r_get_payment_details.check_id           ,
          r_get_payment_details.check_amount       ,
          r_get_payment_details.check_date         ,
          r_get_payment_details.invoice_payment_id ,
          cur_rec.prepay_invoice_id      ,
          cur_rec.prepaid_amount         ,
          cur_rec.invoice_id             ,
          cur_rec.invoice_date           ,
          ln_parent_invoice_id           ,
          lv_parent_invoice_cancel_flag  ,
          ln_threshold_trx_id            ,
          lv_section_code                ,
          ln_tax_id                      ,
          ln_tax_rate                    ,
          ln_taxable_basis               ,
          ln_tax_amount                  ,
          cur_rec.tax_authority_id       ,
          cur_rec.tax_authority_site_id  ,
          ln_vendor_id                   ,
          ln_vendor_site_id              ,
          pv_org_tan_num                 ,
          cur_rec.org_id                 ,
          'Invoice paid by prepayment'   ,
          ln_user_id                     ,
          sysdate                        ,
          ln_user_id                     ,
          sysdate                        ,
          ln_last_update_login           ,
          ln_program_id                  ,
          ln_program_login_id            ,
          ln_program_application_id      ,
          ln_request_id
        );

        ln_record_count := ln_record_count + 1;
         -- bug 6774129. Added by Lakshmi Gopalsami
	-- Observation as part of QA.
	-- this will update the tax amount with the payment amount for
	-- all lines which has been paid by check.
        update jai_ap_tds_inv_payments
	   set tax_amount = payment_amount
	 where invoice_id = cur_rec.invoice_id
	   and prepay_invoice_id is null
	   and nvl(source,'ABC') <> 'Invoice paid by prepayment';
        << continue_with_next_record >>
        null;

      end loop; /* c_tds_invoice_paid_by_prepay */

/* START, Bgowrava for Bug#6069891*/
 /* Following logic is introduced to handle multiple payments made for a single TDS invoice.    */
    tab_index := 1; ln_temp_invoice_id := 0;
    FOR c_get_multiple_payments IN c_tds_multiple_payments
    LOOP
      IF ln_temp_invoice_id <> c_get_multiple_payments.invoice_id THEN
       r_get_tds_inv_details(tab_index).tds_payment_id := c_get_multiple_payments.tds_payment_id;
       r_get_tds_inv_details(tab_index).taxable_basis := c_get_multiple_payments.taxable_basis;
       r_get_tds_inv_details(tab_index).invoice_id := c_get_multiple_payments.invoice_id;
       tab_index := tab_index + 1;
      END IF ;
      UPDATE jai_ap_tds_inv_payments jatp
           SET jatp.taxable_basis = round(jatp.taxable_basis * jatp.payment_amount / jatp.tax_amount,2)
      WHERE jatp.tds_payment_id = c_get_multiple_payments.tds_payment_id ;
      UPDATE jai_ap_tds_inv_payments jatp
           SET jatp.tax_amount = jatp.payment_amount
      WHERE jatp.tds_payment_id = c_get_multiple_payments.tds_payment_id ;
    END LOOP ;

    /* Round the taxable basis correct if not rounded properly. */
    FOR ind IN 1..tab_index - 1
    LOOP
      UPDATE jai_ap_tds_inv_payments jatp
           SET jatp.taxable_basis =  jatp.taxable_basis +
	                                     ( r_get_tds_inv_details(ind).taxable_basis -
					       (SELECT sum(jatp1.taxable_basis)
					          FROM jai_ap_tds_inv_payments  jatp1
						WHERE jatp1.invoice_id = r_get_tds_inv_details(ind).invoice_id
						    AND jatp1.check_id NOT IN
						    (SELECT  check_id
						       FROM ap_checks_all ac
						     WHERE ac.check_id = jatp.check_id
						        AND status_lookup_code in ('VOIDED', 'STOP INITIATED')
						    )
					       )
					      )
       WHERE jatp.tds_payment_id = r_get_tds_inv_details(ind).tds_payment_id
           AND jatp.form16_hdr_id IS NULL ;
    END LOOP ;
 /* END, Bgowrava for Bug#6069891*/

      <<exit_from_procedure>>
      Fnd_File.put_line(Fnd_File.LOG, 'No of records inserted into JAI_AP_TDS_INV_PAYMENTS : ' || to_char(ln_record_count));
      Fnd_File.put_line(Fnd_File.LOG, '** Successful End of procedure jai_ap_tds_processing_pkg.process_tds_payments **');

      return;

    exception
      when others then
        retcode := 2;
        errbuf := 'Error from jai_ap_tds_processing_pkg.process_tds_payments : ' || sqlerrm;
        Fnd_File.put_line(Fnd_File.LOG, 'Error End of procedure jai_ap_tds_processing_pkg.process_tds_payments : ' || sqlerrm);
        Fnd_File.put_line(Fnd_File.LOG, '** Error End of procedure jai_ap_tds_processing_pkg.process_tds_payments **');

    end process_tds_payments;
/* ********************************  process_tds_payments *******************************************  */

/* ******************************  process_tds_certificates *****************************************  */
procedure process_tds_certificates
  (
    errbuf                              out            nocopy    varchar2,
    retcode                             out            nocopy    varchar2,
    pd_tds_payment_from_date            in             varchar2,
    pd_tds_payment_to_date              in             varchar2,
    pv_org_tan_num                      in             varchar2,
    p_section_type                      in             varchar2,/*bduvarag for Bug#5647725*/
    pv_tds_section                      in             varchar2  ,
    pn_tds_authority_id                 in             number    ,
    pn_tds_authority_site_id            in             number    default null,
    pn_vendor_id                        in             number    default null,
    pn_vendor_site_id                   in             number    default null
  )
  is
       ld_tds_payment_from_date  date ;  --Date 12-jun-2007 sacsethi for bug 6119195
       ld_tds_payment_to_date    date;   --Date 12-jun-2007 sacsethi for bug 6119195

    cursor c_get_distinct_ou
    (
      pd_tds_payment_from_date    date,
      pd_tds_payment_to_date      date,
      pv_org_tan_num              varchar2,
      pv_tds_section              varchar2,
      pn_tds_authority_id         number,
      pn_tds_authority_site_id    number,
      pn_vendor_id                number,
      pn_vendor_site_id           number
    )
    is
      select distinct operating_unit_id   operating_unit_id
      from   jai_ap_tds_inv_payments
      where  parent_invoice_id is not null
      and    tds_tax_id is not null
      and    tds_tax_rate is not null
      and    invoice_date between  pd_tds_payment_from_date and  pd_tds_payment_to_date
      and    form16_hdr_id is  null
      and    nvl(tds_section,'XYZ')         = nvl(pv_tds_section,nvl(tds_section,'XYZ')) /*rchandan for bug#4936956. Added nvl on left hand side and nvl within nvl on right side*/
      and    tax_authority_id      = pn_tds_authority_id
      and    tax_authority_site_id = nvl(pn_tds_authority_site_id, tax_authority_site_id)
      and    vendor_id             = nvl(pn_vendor_id, vendor_id)
      and    vendor_site_id        = nvl(pn_vendor_site_id, vendor_site_id)
      and    org_tan_num           = pv_org_tan_num
      and    tds_tax_id in ( SELECT tax_id
                               FROM JAI_CMN_TAXES_ALL
                              WHERE section_type = p_section_type
                           );/*bduvarag for Bug#5647725*/


    cursor c_get_distinct_invoice_date
    (
      pd_tds_payment_from_date    date,
      pd_tds_payment_to_date      date,
      pv_org_tan_num              varchar2,
      pv_tds_section              varchar2,
      pn_tds_authority_id         number,
      pn_tds_authority_site_id    number,
      pn_vendor_id                number,
      pn_vendor_site_id           number,
      pn_operating_unit_id        number
    )
    is
      select distinct invoice_date     invoice_date
      from   jai_ap_tds_inv_payments
      where  parent_invoice_id is not null
      and    tds_tax_id is not null
      and    tds_tax_rate is not null
      and    invoice_date between  pd_tds_payment_from_date and  pd_tds_payment_to_date
      and    form16_hdr_id is  null
      and    nvl(tds_section,'XYZ')         = nvl(pv_tds_section,nvl(tds_section,'XYZ')) /*rchandan for bug#4936956. Added nvl on left hand side and nvl within nvl on right side*/
      and    tax_authority_id      = pn_tds_authority_id
      and    tax_authority_site_id = nvl(pn_tds_authority_site_id, tax_authority_site_id)
      and    vendor_id             =  nvl(pn_vendor_id, vendor_id)
      and    vendor_site_id        = nvl(pn_vendor_site_id, vendor_site_id)
      and    org_tan_num           = pv_org_tan_num
      and    operating_unit_id     = pn_operating_unit_id
      and    tds_tax_id in ( SELECT tax_id
                               FROM JAI_CMN_TAXES_ALL
                              WHERE section_type = p_section_type
                           );/*bduvarag for Bug#5647725*/
--Commented below by Bgowrava for Bug#6129650
/*
    cursor c_hr_operating_units(pn_organization_id number) is
      select  default_legal_context_id
      from    hr_operating_units
      where   organization_id = pn_organization_id;*/

    cursor c_ja_in_tds_year_info(pn_legal_entity_id number, pd_invoice_date date) is
      select fin_year
      from   jai_ap_tds_years
      where  legal_entity_id = pn_legal_entity_id
      and    pd_invoice_date between start_date and end_date;

    cursor c_group_for_no_certificate/*Bug 5647725 start bduvarag*/
    (
      pd_tds_payment_from_date    date,
      pd_tds_payment_to_date      date,
      pv_org_tan_num              varchar2,
      pv_tds_section              varchar2,
      pn_tds_authority_id         number,
      pn_tds_authority_site_id    number,
      pn_vendor_id                number,
      pn_vendor_site_id           number
    )
    is
    select
    	     fin_year,
           org_tan_num,
           operating_unit_id,
           vendor_id,
           vendor_site_id,
           --tds_tax_id,
           tds_section,
           tax_authority_id,
			     parent_invoice_id
    from   jai_ap_tds_inv_payments /*Added by nprashar  for bug 6774129*/
    where  parent_invoice_id     is not null
    and    tds_tax_id            is not null
    and    tds_tax_rate          is not null
    and    invoice_date          between  pd_tds_payment_from_date and  pd_tds_payment_to_date
    and    form16_hdr_id         is  null
    and    tds_section           =  pv_tds_section
    and    fin_year              is not null
    and    tax_authority_id      = pn_tds_authority_id
    and    tax_authority_site_id = nvl(pn_tds_authority_site_id, tax_authority_site_id)
    and    vendor_id             =  nvl(pn_vendor_id, vendor_id)
    and    vendor_site_id        = nvl(pn_vendor_site_id, vendor_site_id)
    and    org_tan_num           = pv_org_tan_num
    and    tds_tax_id in ( SELECT tax_id
                             FROM JAI_CMN_TAXES_ALL
                            WHERE section_type = p_section_type
                           )
		group by
    	fin_year,
      org_tan_num,
      operating_unit_id,
      vendor_id,
      vendor_site_id,
      --tds_tax_id,
      tds_section,
      tax_authority_id,
			parent_invoice_id
	having sum(TAX_AMOUNT) = 0;
/*Bug 5647725 end bduvarag*/
    cursor c_group_for_certificate
    (
      pd_tds_payment_from_date    date,
      pd_tds_payment_to_date      date,
      pv_org_tan_num              varchar2,
      pv_tds_section              varchar2,
      pn_tds_authority_id         number,
      pn_tds_authority_site_id    number,
      pn_vendor_id                number,
      pn_vendor_site_id           number
    )
    is
    select distinct
      fin_year,
      org_tan_num,
      operating_unit_id,
      vendor_id,
      vendor_site_id,
      /*tds_tax_id, commented by nprashar for Bug : 6774129*/
      tds_section,
      tax_authority_id
    from jai_ap_tds_inv_payments
    where  parent_invoice_id is not null
    and    tds_tax_id is not null
    and    tds_tax_rate is not null
    and    invoice_date between  pd_tds_payment_from_date and  pd_tds_payment_to_date
    and    form16_hdr_id is  null
    and    nvl(tds_section,'XYZ')         = nvl(pv_tds_section,nvl(tds_section,'XYZ'))/*bduvarag for Bug#5647725*/
    and    fin_year is not null
    and    tax_authority_id = pn_tds_authority_id
    and    tax_authority_site_id = nvl(pn_tds_authority_site_id, tax_authority_site_id)
    and    vendor_id =  nvl(pn_vendor_id, vendor_id)
    and    vendor_site_id = nvl(pn_vendor_site_id, vendor_site_id)
    and    org_tan_num = pv_org_tan_num
    and    tds_tax_id in ( SELECT tax_id
                             FROM JAI_CMN_TAXES_ALL
                            WHERE section_type = p_section_type
                           );/*bduvarag for Bug#5647725*/


    cursor c_jai_ap_tds_cert_nums(pv_org_tan_num varchar2, pn_fin_year number, pv_regime_code VARCHAR2)
    is
      select nvl(certificate_num, 0) + 1
      from   jai_ap_tds_cert_nums
      where  org_tan_num   =  pv_org_tan_num
      and    fin_yr      =  pn_fin_year
      and    regime_code   =  pv_regime_code/*CSahoo for Bug#5631784*/
      ;


    cursor c_form16_cert_lines(cp_form16_hdr_id number) is
      select rowid row_id, parent_invoice_id, threshold_trx_id
      from jai_ap_tds_inv_payments
      where form16_hdr_id = cp_form16_hdr_id
      order by parent_invoice_id, invoice_id
      for update of certificate_line_num;

    cursor c_tds_thhold_event(cp_threshold_trx_id number) is
      select tds_event
      from   jai_ap_tds_thhold_trxs
      where  threshold_trx_id = cp_threshold_trx_id;

    cursor c_get_form16_hdr_id is
      select jai_ap_tds_f16_hdrs_all_s.nextval from dual;
/*bduvarag for Bug#5647725*/
          CURSOR cur_get_tds_section IS
    SELECT decode(p_section_type,'TDS_SECTION','TDS','WCT_SECTION','WCT','ESSI_SECTION','ESI')
      FROM dual;


    ln_cert_line_num            NUMBER(15);
    ln_prev_parent_invoice_id   ap_invoices_all.invoice_id%TYPE;
--    lv_prev_tds_event           jai_ap_tds_thhold_trxs.tds_event%TYPE;
/*Bug 5647725 bduvarag*/
    lv_tds_event                jai_ap_tds_thhold_trxs.tds_event%TYPE;


    --r_hr_operating_units       c_hr_operating_units%rowtype;
    r_ja_in_tds_year_info      c_ja_in_tds_year_info%rowtype;
    ln_certificate_num         jai_ap_tds_cert_nums.certificate_num%type;
    ln_form16_hdr_id           number;

    ln_program_id              number;
    ln_program_login_id        number;
    ln_program_application_id  number;
    ln_request_id              number;
    ln_user_id                 number(15);
    ln_last_update_login       number(15);
    ln_certificate_count       number;
    lv_tds_section             VARCHAR2(30);/*bduvarag for Bug#5647725*/

  begin

    /* Get the statis fnd values for populating into the table */
    Fnd_File.put_line(Fnd_File.LOG, '** Start of procedure jai_ap_tds_processing_pkg.process_tds_certificates **');

    ln_user_id                  :=   fnd_global.user_id           ;
    ln_last_update_login        :=   fnd_global.login_id          ;
    ln_program_id               :=   fnd_global.conc_program_id   ;
    ln_program_login_id         :=   fnd_global.conc_login_id     ;
    ln_program_application_id   :=   fnd_global.prog_appl_id      ;
    ln_request_id               :=   fnd_global.conc_request_id   ;

    ln_certificate_count        :=    0 ;

    ld_tds_payment_from_date :=   fnd_date.canonical_to_date(pd_tds_payment_from_date);--Date 12-jun-2007 sacsethi for bug 6119195
    ld_tds_payment_to_date :=   fnd_date.canonical_to_date(pd_tds_payment_to_date);--Date 12-jun-2007 sacsethi for bug 6119195

/*bduvarag for Bug#5647725 start*/

OPEN cur_get_tds_section;
    FETCH cur_get_tds_section INTO lv_tds_section;
    CLOSE cur_get_tds_section;

    IF lv_tds_section = 'TDS' and pv_tds_section IS NULL THEN

       raise_application_error(-20120,' Section Code is mandatory for TDS Section');

    END IF;
/*bduvarag for Bug#5647725 End*/

    for cur_ou in
    c_get_distinct_ou
    (
       ld_tds_payment_from_date  ,
       ld_tds_payment_to_date    ,
       pv_org_tan_num            ,
       pv_tds_section            ,
       pn_tds_authority_id       ,
       pn_tds_authority_site_id  ,
       pn_vendor_id              ,
       pn_vendor_site_id
    )
    loop


      Fnd_File.put_line(Fnd_File.LOG, 'Processing operating unit : ' || cur_ou.operating_unit_id);

--Commented below by Bgowrava for Bug#6129650
/*
      open  c_hr_operating_units(cur_ou.operating_unit_id);
      fetch c_hr_operating_units into r_hr_operating_units;
      close c_hr_operating_units;*/

      for cur_invoice_date in
      c_get_distinct_invoice_date
      (
         ld_tds_payment_from_date  ,
         ld_tds_payment_to_date    ,
         pv_org_tan_num            ,
         pv_tds_section            ,
         pn_tds_authority_id       ,
         pn_tds_authority_site_id  ,
         pn_vendor_id              ,
         pn_vendor_site_id         ,
         cur_ou.operating_unit_id
      )
      loop
        Fnd_File.put_line(Fnd_File.LOG, 'Processing cur_invoice_date : ' || cur_invoice_date.invoice_date);

        open  c_ja_in_tds_year_info(cur_ou.operating_unit_id, cur_invoice_date.invoice_date); --changed r_hr_operating_units.default_legal_context_id to cur_ou.operating_unit_id for Bug#6129650
        fetch c_ja_in_tds_year_info into r_ja_in_tds_year_info;
        close c_ja_in_tds_year_info;

        Fnd_File.put_line(Fnd_File.LOG, 'Updating ' || r_ja_in_tds_year_info.fin_year);

        update jai_ap_tds_inv_payments
        set    fin_year = r_ja_in_tds_year_info.fin_year
        where  parent_invoice_id is not null
        and    tds_tax_id is not null
        and    tds_tax_rate is not null
        and    invoice_date between  ld_tds_payment_from_date and  ld_tds_payment_to_date
        and    form16_hdr_id is  null
        and    nvl(tds_section,'XYZ')         = nvl(pv_tds_section,nvl(tds_section,'XYZ'))/*bduvarag for Bug#5647725*/
        and    tax_authority_id = pn_tds_authority_id
        and    tax_authority_site_id = nvl(pn_tds_authority_site_id, tax_authority_site_id)
        and    vendor_id =  nvl(pn_vendor_id, vendor_id)
        and    vendor_site_id = nvl(pn_vendor_site_id, vendor_site_id)
        and    org_tan_num = pv_org_tan_num
        and    operating_unit_id = cur_ou.operating_unit_id
        and    invoice_date = cur_invoice_date.invoice_date
	        and    tds_tax_id in ( SELECT tax_id
                                 FROM JAI_CMN_TAXES_ALL
                                WHERE section_type = p_section_type
                             );/*bduvarag for Bug#5647725*/



        Fnd_File.put_line(Fnd_File.LOG, ' No of records updated with Fin year : ' || to_char(sql%rowcount) );

      end loop; /*c_get_distinct_invoice_date */


    end loop; /* c_get_distinct_ou */

    /* Fin year update complete  */

    FOR cur_rec IN /*Bug 5647725 start bduvarag*/
      c_group_for_no_certificate
       (
         ld_tds_payment_from_date  ,
				 ld_tds_payment_to_date    ,
				 pv_org_tan_num            ,
				 pv_tds_section            ,
				 pn_tds_authority_id       ,
				 pn_tds_authority_site_id  ,
				 pn_vendor_id              ,
				 pn_vendor_site_id
			  )
    LOOP

				 ln_form16_hdr_id := null;

				 open  c_get_form16_hdr_id;
				 fetch c_get_form16_hdr_id into ln_form16_hdr_id;
				 close c_get_form16_hdr_id;

				 update jai_ap_tds_inv_payments /*changed by nprashar for bug 6774129 */
				 set      form16_hdr_id     = -1 * ln_form16_hdr_id
				        , last_update_date  = sysdate
								, last_update_login = ln_last_update_login
				 where  parent_invoice_id   = cur_rec.parent_invoice_id
				 --and    tds_tax_id          = cur_rec.tds_tax_id           --tds_tax_id,
				 and    tds_tax_rate        is not null
				 and    invoice_date        between  ld_tds_payment_from_date and  ld_tds_payment_to_date
				 and    form16_hdr_id       is  null
				 and    tds_section         =  cur_rec.tds_section
				 and    fin_year            = cur_rec.fin_year
				 and    tax_authority_id    = cur_rec.tax_authority_id
				 and    vendor_id           =  cur_rec.vendor_id
				 and    vendor_site_id      = cur_rec.vendor_site_id
				 and    org_tan_num         = pv_org_tan_num
				 and    operating_unit_id   = cur_rec.operating_unit_id
				 and    tds_tax_id in ( SELECT tax_id
																	FROM JAI_CMN_TAXES_ALL
																 WHERE section_type = p_section_type
											 );

    END LOOP; /*c_group_for_no_certificate*/
/*Bug 5647725 end bduvarag*/
    /* Group for TDS Certificates */

    Fnd_File.put_line(Fnd_File.LOG, ' Generating Certificates ' );

    for cur_rec in
    c_group_for_certificate
    (
       ld_tds_payment_from_date  ,
       ld_tds_payment_to_date    ,
       pv_org_tan_num            ,
       pv_tds_section            ,
       pn_tds_authority_id       ,
       pn_tds_authority_site_id  ,
       pn_vendor_id              ,
       pn_vendor_site_id
    )
    loop

      /* Get certificate number */
      ln_certificate_num := null;
      open  c_jai_ap_tds_cert_nums(pv_org_tan_num, cur_rec.fin_year, lv_tds_section); /*bduvarag for Bug#5647725*/ /*CSahoo for Bug#5631784*/
      fetch c_jai_ap_tds_cert_nums into ln_certificate_num;
      close c_jai_ap_tds_cert_nums;

      if ln_certificate_num is null then
        ln_certificate_num := 1;
      end if;

      ln_form16_hdr_id := null;

      open  c_get_form16_hdr_id;
      fetch c_get_form16_hdr_id into ln_form16_hdr_id;
      close c_get_form16_hdr_id;

      update jai_ap_tds_inv_payments
      set      form16_hdr_id    = ln_form16_hdr_id
             , certificate_num  = ln_certificate_num
             , last_update_date = sysdate
             , last_update_login = ln_last_update_login
      where  parent_invoice_id is not null
      /*and    tds_tax_id       = cur_rec.tds_tax_id commented by nprashar for bug # 6774129*/
      and    tds_tax_rate is not null
      and    invoice_date between  ld_tds_payment_from_date and  ld_tds_payment_to_date
      and    form16_hdr_id is  null
      and    nvl(tds_section,'XYZ') = nvl(cur_rec.tds_section,'XYZ') /*bduvarag for Bug#5647725*/
      and    fin_year         = cur_rec.fin_year
      and    tax_authority_id = cur_rec.tax_authority_id
      and    vendor_id        =  cur_rec.vendor_id
      and    vendor_site_id   = cur_rec.vendor_site_id
      and    org_tan_num = pv_org_tan_num
      and    operating_unit_id = cur_rec.operating_unit_id
            and    tds_tax_id in ( SELECT tax_id
                               FROM JAI_CMN_TAXES_ALL
                              WHERE section_type = p_section_type
                           );/*bduvarag for Bug#5647725*/

      if sql%rowcount = 0 then
        goto continue_with_next_certificate;
      end if;

      Fnd_File.put_line(Fnd_File.LOG, 'Certificate Number : ' || ln_certificate_num);
      Fnd_File.put_line(Fnd_File.LOG, ' No of Records for the Certificate : ' || to_char(sql%rowcount) );
      ln_certificate_count := ln_certificate_count + 1;

      if ln_certificate_num = 1 then
        Fnd_File.put_line(Fnd_File.LOG, 'Created a certificate record in jai_ap_tds_cert_nums');
        insert into jai_ap_tds_cert_nums
        (
          fin_yr_cert_id          ,
          regime_code             ,
          org_tan_num             ,
          fin_yr                ,
          certificate_num         ,
          created_by              ,
          creation_date           ,
          last_updated_by         ,
          last_update_date        ,
          last_update_login
        )
        values
        (
          jai_ap_tds_cert_nums_s.nextval, /*Bgowrava for Bug#6129650*/
          lv_tds_section          ,/*bduvarag for Bug#5647725*/ /*CSahoo for BUG#5631784*/
          pv_org_tan_num          ,
          cur_rec.fin_year        ,
          1                       ,
          ln_user_id              ,
          sysdate                 ,
          ln_user_id              ,
          sysdate                 ,
          ln_last_update_login
        );

      else

        Fnd_File.put_line(Fnd_File.LOG, 'Updated certificate number in jai_ap_tds_cert_nums');
        update jai_ap_tds_cert_nums
        set    certificate_num = ln_certificate_num
        where  org_tan_num   =  pv_org_tan_num
        and    fin_yr      =  cur_rec.fin_year
        and    regime_code   = lv_tds_section/*bduvarag for Bug#5647725*/ /*CSahoo for BUG#5631784*/
        ;
      end if;

      /* insert into jai_ap_tds_f16_hdrs_all */
          IF lv_tds_section = 'TDS' THEN/*bduvarag for Bug#5647725*/
      Fnd_File.put_line(Fnd_File.LOG, 'Inserting record in jai_ap_tds_f16_hdrs_all with form16_hdr_id : ' || to_char(ln_form16_hdr_id));
      insert into jai_ap_tds_f16_hdrs_all
      (
        form16_hdr_id                  ,
        fin_yr                         ,
        org_tan_num                    ,
        certificate_num                 ,
        certificate_date               ,
        vendor_id                      ,
        vendor_site_id                 ,
        --tds_tax_id                     ,/*Commented by nprashar for bug # 6774129*/
        tax_authority_id               ,
	from_date                      ,
        to_date                        ,
        print_flag                     ,
        org_id                         ,
        tds_tax_section                ,
        created_by                     ,
        creation_date                  ,
        last_updated_by                ,
        last_update_date               ,
        last_update_login              ,
        program_id                     ,
        program_login_id               ,
        program_application_id         ,
        request_id
      )
      values
      (
        ln_form16_hdr_id              ,
        cur_rec.fin_year              ,
        pv_org_tan_num                ,
        ln_certificate_num            ,
        trunc(sysdate)                ,
        cur_rec.vendor_id             ,
        cur_rec.vendor_site_id        ,
        --cur_rec.tds_tax_id                     ,/*Commented by nprashar for bug # 6774129*/
        cur_rec.tax_authority_id      ,
        ld_tds_payment_from_date      ,
        ld_tds_payment_to_date        ,
        'N'                           ,
        cur_rec.operating_unit_id     ,
        cur_rec.tds_section           ,
        ln_user_id                    ,
        sysdate                       ,
        ln_user_id                    ,
        sysdate                       ,
        ln_last_update_login          ,
        ln_program_id                 ,
        ln_program_login_id           ,
        ln_program_application_id     ,
        ln_request_id
      )
      ;
      END IF;/*bduvarag for Bug#5647725*/

      /* logic to punch the certificate line number */
      /* All tds invoices will be grouped by parent invoice provided tds invoice is not against a threshold transition */
      ln_cert_line_num := 0;
      ln_prev_parent_invoice_id := -9999;
--      lv_prev_tds_event := 'INITIAL';
/*Bug 5647725 bduvarag*/

      Fnd_File.put_line(Fnd_File.LOG, 'Puching certificate line numbers ');

      for tds_payment in c_form16_cert_lines(ln_form16_hdr_id)
      loop

        lv_tds_event := null;
        open c_tds_thhold_event(tds_payment.threshold_trx_id);
        fetch c_tds_thhold_event into lv_tds_event;
        close c_tds_thhold_event;

        lv_tds_event := nvl(lv_tds_event, 'NO EVENT');
        if ln_prev_parent_invoice_id <> tds_payment.parent_invoice_id
--          or (lv_prev_tds_event <> lv_tds_event and lv_tds_event like 'THRESHOLD TRANSITION%')
/*Bug 5647725 bduvarag*/
        then
          ln_cert_line_num := ln_cert_line_num + 1;
          ln_prev_parent_invoice_id := tds_payment.parent_invoice_id;
--          lv_prev_tds_event := lv_tds_event;
/*bduvarag for Bug#5647725*/
        end if;

        update  jai_ap_tds_inv_payments
        set     certificate_line_num = ln_cert_line_num
        where current of c_form16_cert_lines;

        Fnd_File.put_line(Fnd_File.LOG, 'Line number / No of records for the line :'
                          || to_char(ln_cert_line_num) || ' / ' || to_char(sql%rowcount) );
      end loop;


      << continue_with_next_certificate >>
        null;

    end loop; /* c_group_for_certificate */


    <<exit_from_procedure>>
    Fnd_File.put_line(Fnd_File.LOG, 'No of Certificates Generated : ' || to_char(ln_certificate_count));
    Fnd_File.put_line(Fnd_File.LOG, '** Successful End of procedure jai_ap_tds_processing_pkg.process_tds_certificates **');

    return;

exception
    when others then
      retcode := 2;
      errbuf := 'Error from jai_ap_tds_processing_pkg.process_tds_certificates : ' || sqlerrm;
      Fnd_File.put_line(Fnd_File.LOG, 'Error End of procedure jai_ap_tds_processing_pkg.process_tds_payments : ' || sqlerrm);

end process_tds_certificates;
/* ******************************  process_tds_certificates *****************************************  */
/* End added for bug#4448293 */

END jai_ap_tds_processing_pkg;

/

--------------------------------------------------------
--  DDL for Package Body JAI_TRX_REPO_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_TRX_REPO_EXTRACT_PKG" as
/* $Header: jai_trx_repo_ext.plb 120.19.12010000.12 2010/02/19 12:20:18 jmeena ship $ */
/*------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  Sl.No.          Date          Developer   BugNo       Version        Remarks
  ------------------------------------------------------------------------------------------------------------
  1.              22-Dec-2005   brathod     5694855     115.1          Created the initial version

  2.              05-Feb-2007   rchandan    5694855     115.9          Added a cursor c_get_rma_line_srvtyp to
                                                                       fetch the service type from RMA tables.
                                                                       This cursor is used if the line_category_code = 'RETURN'

  3.              06-Jul-2007    brathod     6012570     120.4         Enhanced the logic to suppor PROJECT DRAFT INVOICES
                                                                       changes are marked with bug number 5876390 or 6012570
                                                                       R12 Fwd Porting Bug: 6012570

  4.              23-Aug-2007    Bgowrava     6012570    120.6         modified the c_get_pa_details cursor query to select from the tables PA_DRAFT_INVOICES_ALL,
                                                                       PA_PROJECTS_ALL instead of pa_draft_invoices_v. This was done to improve the performance
                                                                       of the query

  5.              24-Sep-2007    vkantamn    6083978     120.8          The org_id for the po has been changed to fetch from the
                  PO table.
                  Also New transaction source 'RECEIVING' has been added,
                  and the org_id has been picked from the
                  ja_in_rcv_transactions for the above invoices.
  6.              04-Oct-2007    CSahoo      6457710      120.9         Added a ELSIF block related to projects in the procedure extract_rgm_trxs.

  7.              10-Oct-2007    CSahoo      6457710      120.10        Modified the follwing cursors in get_document_details procedure
                  c_get_po_line_loc_srvtyp
                  c_get_so_line_srvtyp
                  c_get_rma_line_srvtyp
                  c_get_pa_inv_line_tax
                  c_get_ra_line_srvtyp

                  Added the cess and sh cess tax types in the AND clause.

  8.              25-Feb-2008    rchandan    6841116      120.3.12000000.3 Issue : The PO Matched to Receipt transactions are not shown in the
                                                                                   'Service tax Repository Review' form after running the India Service Tax Processing' conc program.
                                                                             Fix : This above issue has been fixed by adding a new elsif condition for the 'RECIVING'
                                                                                   in the procedure 'extract_rgm_trxs'.
                                                                                   This is forward port of  bug#6323157

9. 3-march-2008   Changes by nprashar for bug # 6841116. Changes in procedure update_service_type.

10. 29-April-2008  Changes by nprashar for bug #6636517 , added a NVL clause in join condition of cursor c_get_po_details.

11. 31-july-2008   Changes by nprashar for bug 7172723.
                  Issue : India ST Processing concurrent should consider Third Party Invoices and
                        update India Service Tax Credit register report
                  Fix : Modifed following procedure to use receipt information for Third party
                  invoices which do not have reference to PO
                  1 - get_doc_from_reference - Added logic for third party invoices which do not have references to PO
                  Modified cursor - c_get_refs_rec
                  Added cursor - c_get_source_type,c_get_line_number,c_get_doc_details,c_get_ra_line_srvtyp
12. 03-Jul-2009   CSahoo for bug#8648359, File Version 120.3.12000000.8
                  Added an AND clause in the code in the procedure extract_rgm_trxs.
13. 14-Jul-2009   CSahoo for bug#8451703, File Version 120.3.12000000.9
                  Modified the IF clause in the procedure get_document_details.

14. 01-OCT-2009   JMEENA for bug#8943349
                  Issue: India Service Tax Processing Concurrent not processing Standalone Invoices
                    1. Modified procedure get_document_details and added cursor c_get_standalone_inv_details, c_get_standalone_org_loc
                      and c_get_standalone_inv_line_tax
                     2. Modified procedure derrive_doc_from_ref and added code for standalone invoice.
                     3. Modified procedure extract_rgm_trxs and added code to populate the table
                     jai_trx_repo_extract_gt for standalone invoice.

15. 08-Oct-2009   CSahoo for bug#8965721, File Version 120.19.12010000.7
                  Issue: TST1212.XB2.QA:SERVICE TAX CREDIT NOT ACCOUNTED FOR GOODS TRANSPORT OPERATORS
                  Fix: Modified the cursor c_get_doc_details. Replaced rcv_transactions by jai_rcv_transactions

16. 09-Dec-2009   CSahoo for bug#9192752, File Version 120.19.12010000.8
                  Issue: INTCUS:SERVCIE TAX PROCESSING LOG IS SHOWN ERROR MESSAGE
                  FIX: Modified the code in the procedure derrive_doc_from_ref. Moved the CLOSE cursor code
                       into the IF block.

17. 18-Dec-2009   Modifiey by Jia for FP Bug#6691866, File Version 120.19.12010000.10
                  Issue:
                      India - Service tax processor in landing in error. Error thrown is as below:
                      ORA-01652: unable to extend temp segment by 32 in tablespace MTEMP

                      This was a forward port issue of the R11i Bug#6652557.
                      In the query written for the cursor c_get_pa_details in procedure get_document_details,
                      four tables are used.But the join conditions in the where clause are only three which might be
                      leading to a cartesain join on the queries fetched.
                  FIX:
                       Modified cursor c_get_pa_details, included an inline-select statement for the field document_line_desc
                      and removed the Table pa_draft_invoice_items from the list to avoid the Cartesian join.

18.  18-Feb-2010   Bgowrava for bug#9385880, File Version 120.19.12010000.11
 	                   Issue: INDIA - SERVICE TAX PROCESSING IS COMPLETED WITH WARNING
 	                   Fix: Added a IF condition in the procedure get_doc_from_reference

19. 19-FEB-2010	JMEENA for bug#9298508
				Modified procedure get_document_details and added cursor c_get_ra_tax_amt_applied and c_get_ra_line_amt_applied
				to fetch the applied line and tax amount same is updated in temp table to show on service tax repository review form.
--------------------------------------------------------------------------------------------------------------*/

 /*----------------------------------------- PRIVATE MEMBERS DECLRATION -------------------------------------*/

      /** Package level variables used in debug package*/
      lv_object_name  jai_cmn_debug_contexts.log_context%type default 'JAI_TRX_REPO_EXTRACT_PKG';
      lv_member_name  jai_cmn_debug_contexts.log_context%type;
      lv_context      jai_cmn_debug_contexts.log_context%type;

      --
      -- Global variables used throught the package
      --
      lv_user_id  fnd_user.user_id%type     default fnd_global.user_id;
      lv_login_id fnd_logins.login_id%type  default fnd_global.login_id;

  function get_settled_service_type
            ( p_transaction_source jai_trx_repo_extract_gt.transaction_source%type
            , p_document_id        jai_trx_repo_extract_gt.document_id%type
            , p_document_line_id   jai_trx_repo_extract_gt.document_line_id%type
            )
  return varchar2;

  procedure set_debug_context
  is

  begin
    lv_context  := rtrim(lv_object_name || '.'||lv_member_name,'.');
  end set_debug_context;

  /*------------------------------------------------------------------------------------------------------------*/
  procedure extract_rgm_trxs
             ( p_regime_code     jai_rgm_trx_records.regime_code%type
             , p_organization_id jai_rgm_trx_records.organization_id%type default null
             , p_location_id     jai_rgm_trx_records.location_id%type default null
             , p_from_trx_date   date default null
             , p_to_trx_date     date default null
             , p_source          jai_rgm_trx_records.source%type default null
             , p_query_settled_flag   varchar2 default 'N'
             , p_query_only_null_srvtype varchar2 default 'N'
             , p_process_message OUT NOCOPY varchar
             , p_process_flag OUT NOCOPY varchar2
             )
  as
    cursor c_get_repo_recs
    is
    select         (recs.repository_id) repository_id
                  , nvl(refs.reference_id, recs.reference_id) reference_id
                  , refs.invoice_id
                  , refs.item_line_id
                  , recs.source
                  , recs.service_type_code
                  , nvl(recs.organization_id, recs.inv_organization_id) organization_id
                  , recs.location_id
                  , (nvl(trx_credit_amount,0) + nvl(trx_debit_amount,0)) repository_tax_amt
                  , recs.organization_type
                  , recs.source_document_id
    from     jai_rgm_trx_refs       refs
           , jai_rgm_trx_records    recs
    where   recs.reference_id = refs.reference_id (+)
    and    (  p_organization_id is null
           or (recs.organization_id     = p_organization_id)
           )
    and    (p_location_id is null     or recs.location_id     = p_location_id    )
    and    trunc(transaction_date) between nvl (p_from_trx_date, trunc(transaction_date)) and nvl (p_to_trx_date, trunc(transaction_date))
    and    recs.regime_code = p_regime_code
    and    ( (p_query_settled_flag = 'N' and (recs.settlement_id is null))
          or (p_query_settled_flag = jai_constants.yes)
           )
    and    ( (p_query_only_null_srvtype = 'Y' and (recs.service_type_code is null))
          or (p_query_only_null_srvtype = 'N')
           )
    and    (p_source is null or p_source = recs.source )
    and    recs.organization_type = 'IO'
    and    recs.source in ('AP'
                          ,'AR'
                          ,'MANUAL'
                          ,'SERVICE_DISTRIBUTE_OUT'
                          --,'SERVICE_DISTRIBUTE_IN'
                          );
    cursor c_get_organization_name (cp_organization_id hr_organization_units.organization_id%type)
    is
      select name
      from   hr_organization_units
      where  organization_id = cp_organization_id;

    cursor c_get_location_name (cp_location_id  hr_locations_all.location_id%type)
    is
      select description
      from   hr_locations_all
      where  location_id = cp_location_id;



    cursor c_get_settled_doc_service_typ (cp_source      jai_rgm_trx_refs.source%type
                                         ,cp_invoice_id  jai_rgm_trx_refs.invoice_id%type
                                         ,cp_line_id     jai_rgm_trx_refs.line_id%type
                                         )
    is
      select recs.service_type_code
      from   jai_rgm_trx_records recs, jai_rgm_trx_refs refs
      where  recs.reference_id = refs.reference_id
      and    refs.invoice_id = cp_invoice_id
      and    refs.line_id    = cp_line_id
      and    refs.source     = cp_source
      and    recs.settlement_id is not null
      and    recs.service_type_code is not null
      and    rownum = 1;

    cursor c_get_src_rec ( cp_transfer_id      jai_rgm_dis_src_hdrs.transfer_id%type
                         , cp_party_type       jai_rgm_dis_src_hdrs.party_type%type
                         , cp_party_id         jai_rgm_dis_src_hdrs.party_id%type
                         )
    is
      select transfer_number
            ,transaction_date
            ,party_id
            ,location_id
      from  jai_rgm_dis_src_hdrs
      where party_type = cp_party_type
      and   party_id   =  cp_party_id
      and   transfer_id = cp_transfer_id;

    cursor c_get_dest_rec( cp_transfer_id      jai_rgm_dis_des_hdrs.transfer_id%type
                         , cp_party_type       jai_rgm_dis_des_hdrs.destination_party_type%type
                         , cp_party_id         jai_rgm_dis_des_hdrs.destination_party_id%type
                         )
    is
      select transfer_number
            ,creation_date    transaction_date
            ,destination_party_id
            ,location_id
      from  JAI_RGM_DIS_DES_HDRS
      where destination_party_type = cp_party_type
      and   destination_party_id   = cp_party_id
      and   transfer_id = cp_transfer_id;

    r_src_rec    c_get_src_rec%rowtype;
    r_dest_rec   c_get_dest_rec%rowtype;

    cursor c_get_man_trx_rec (cp_trx_number jai_rgm_manual_trxs.transaction_number%type)
    is
      select  party_type
           ,  party_id
           ,  transaction_date
           ,  remarks
           ,  invoice_number
     from JAI_RGM_MANUAL_TRXS
     where  transaction_number = cp_trx_number;

   r_man_trx_rec      c_get_man_trx_rec%rowtype;

   cursor c_get_vendor_name (cp_vendor_id  po_vendors.vendor_id%type)
   is
    select vendor_name
    from   po_vendors
    where  vendor_id = cp_vendor_id;

   cursor c_get_customer_name (cp_party_id  po_vendors.vendor_id%type)
   is
    select hzp.party_name
    from   hz_cust_accounts hzca
          ,hz_parties       hzp
    where hzca.cust_account_id = cp_party_id
    and   hzp.party_id         = hzca.party_id;

    cursor c_st_transprt_inv_details(cp_invoice_id ap_invoices_all.invoice_id%type)/* Changes by nprashar , Forward porting from  bug 7172723*/
    is
    select
      aia.invoice_num,
      substr(aia.invoice_num,instr(aia.invoice_num,'/',1,1)+1,instr(aia.invoice_num,'/',1,2)-instr(aia.invoice_num,'/',1,1)-1) rcp_no,
      pha.segment1 po_num,
      aia.invoice_date
     from
      po_headers_all pha,
      rcv_transactions rt,
      rcv_shipment_headers rsh,
      ap_invoices_all aia
      where
      rsh.receipt_num=substr(aia.invoice_num,instr(aia.invoice_num,'/',1,1)+1,instr(aia.invoice_num,'/',1,2)-instr(aia.invoice_num,'/',1,1)-1) AND
      rsh.shipment_header_id=rt.shipment_header_id AND
      rt.po_header_id=pha.po_header_id AND
      pha.org_id=aia.org_id AND
      aia.invoice_id=cp_invoice_id
      and rownum=1;

    cursor c_st_transprt_party_details(cp_invoice_id ap_invoices_all.invoice_id%type) /* Changes by nprashar , Forward porting from  bug 7172723*/
    IS
    select pv.vendor_name,pv.vendor_id  from
     jai_rgm_trx_refs jrtr,
     po_vendors pv
    where invoice_id=cp_invoice_id
    and pv.vendor_id=jrtr.party_id
    and rownum=1;

   lv_party_name    hz_parties.party_name%type;

     rec_st_transprt_inv_details c_st_transprt_inv_details%rowtype;/* Changes by nprashar , Forward porting from  bug 7172723 */
     rec_st_transprt_party_details c_st_transprt_party_details%rowtype;/* Changes by nprashar , Forward porting from  bug 7172723 */
    lv_service_type_code  jai_rgm_trx_records.service_type_code%type;

    lr_trx_repo_extract   jai_trx_repo_extract_gt%rowtype;
    lv_organization_name  hr_organization_units.name%type;
    lv_location_name      hr_locations_all.description%type;
    ln_reg_id             number;

  begin

    lv_member_name := 'EXTRACT_RGM_TRXS';
    set_debug_context;
    p_process_flag := jai_constants.SUCCESSFUL;
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                                        , pn_reg_id  => ln_reg_id
                                        );

    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Call Parameters:'   ||                        fnd_global.local_chr(10) ||
                                               'p_regime_code    ='   ||p_regime_code        || fnd_global.local_chr(10) ||
                                               'p_organization_id='   ||p_organization_id    || fnd_global.local_chr(10) ||
                                               'p_location_id    ='   ||p_location_id        || fnd_global.local_chr(10) ||
                                               'p_from_trx_date  ='   ||p_from_trx_date      || fnd_global.local_chr(10) ||
                                               'p_to_trx_date    ='   ||p_to_trx_date        || fnd_global.local_chr(10) ||
                                               'p_query_settled_flag='||p_query_settled_flag
                                     );

    for r_repo_recs in c_get_repo_recs
    loop

      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Begin for r_repo_recs in c_get_repo_recs loop');
      lr_trx_repo_extract  := null;

      jai_cmn_debug_contexts_pkg.print (ln_reg_id, '1. r_repo_recs.service_type_code ='||r_repo_recs.service_type_code );

      jai_cmn_debug_contexts_pkg.print (ln_reg_id, '2. r_repo_recs.service_type_code ='||r_repo_recs.service_type_code || fnd_global.local_chr(10)
                                                  ||',r_repo_recs.source='||r_repo_recs.source );

      if r_repo_recs.source in ('AP','AR') then

          jai_trx_repo_extract_pkg.derrive_doc_from_ref
                                      ( p_reference_source        => r_repo_recs.source
                                      , p_reference_invoice_id    => r_repo_recs.invoice_id
                                      , p_reference_item_line_id  => r_repo_recs.item_line_id
                                      , p_trx_repo_extract_rec    => lr_trx_repo_extract
                                      , p_process_message         => p_process_message
                                      , p_process_flag            => p_process_flag
                                      );
          if p_process_flag <> jai_constants.SUCCESSFUL then
            return;
          end if;

     /* { Changes by nprashar , Forward porting from  bug 7172723 */
             if lr_trx_repo_extract.document_id is null
             --added the following and condition for bug#8648359
             and lr_trx_repo_extract.transaction_source not in ('RECEIVABLES', 'PROJECTS', 'ORDER MANAGEMENT','STANDALONE_INVOICE') then
                /* if document_id is null here this is a Serv.tax invoice for transporters*/

                 open c_st_transprt_inv_details(r_repo_recs.invoice_id);
                 fetch c_st_transprt_inv_details into rec_st_transprt_inv_details;
                 close c_st_transprt_inv_details;

                 open c_st_transprt_party_details(r_repo_recs.invoice_id);
                  fetch c_st_transprt_party_details into rec_st_transprt_party_details;
                  close c_st_transprt_party_details;


               lr_trx_repo_extract.transaction_source  := 'Payables' ;
               lr_trx_repo_extract.party_name          := rec_st_transprt_party_details.vendor_name;
               lr_trx_repo_extract.party_id            := rec_st_transprt_party_details.vendor_id;
               lr_trx_repo_extract.document_number     := rec_st_transprt_inv_details.invoice_num;
               lr_trx_repo_extract.document_date       := rec_st_transprt_inv_details.invoice_date;
               lr_trx_repo_extract.document_id         := r_repo_recs.invoice_id;
               lr_trx_repo_extract.document_line_desc  :='Service Tax - for Transporters -'||'PO-Number: '||rec_st_transprt_inv_details.po_num;
               lr_trx_repo_extract.organization_id     := r_repo_recs.organization_id;
               lr_trx_repo_extract.location_id         := r_repo_recs.location_id;
               lr_trx_repo_extract.repository_tax_amt  := r_repo_recs.repository_tax_amt;

            end if;
             /*  Changes by nprashar , Forward porting from  bug 7172723 }*/

      elsif r_repo_recs.source IN ('SERVICE_DISTRIBUTE_OUT') then

        lr_trx_repo_extract.document_line_desc :=  'Service Distribution Transaction' ;
        lr_trx_repo_extract.transaction_source :=  r_repo_recs.source ;


        if r_repo_recs.source = 'SERVICE_DISTRIBUTE_OUT' then
          open  c_get_src_rec ( cp_transfer_id      => r_repo_recs.source_document_id
                              , cp_party_type       => r_repo_recs.organization_type
                              , cp_party_id         => r_repo_recs.organization_id
                               );
          fetch c_get_src_rec into r_src_rec;
          close c_get_src_rec ;

          lr_trx_repo_extract.document_number := r_src_rec.transfer_number;
          lr_trx_repo_extract.document_date   := r_src_rec.transaction_date;
          lr_trx_repo_extract.document_id     := r_repo_recs.source_document_id;
          lr_trx_repo_extract.organization_id := r_src_rec.party_id   ;
          lr_trx_repo_extract.location_id     := r_src_rec.location_id  ;
          lr_trx_repo_extract.repository_tax_amt := r_repo_recs.repository_tax_amt ;

        end if; --> r_repo_recs.source = 'SERVICE_DISTRIBUTE_OUT'

      elsif r_repo_recs.source = 'MANUAL' then

        open  c_get_man_trx_rec (cp_trx_number => r_repo_recs.source_document_id);
        fetch c_get_man_trx_rec into r_man_trx_rec ;
        close c_get_man_trx_rec ;

        if r_man_trx_rec.party_type in ('VENDOR','AUTHORITY') then
          open  c_get_vendor_name (cp_vendor_id => r_man_trx_rec.party_id);
          fetch  c_get_vendor_name into lv_party_name;
          close c_get_vendor_name ;
        elsif r_man_trx_rec.party_type = 'CUSTOMER' then
          open   c_get_customer_name (cp_party_id => r_man_trx_rec.party_id);
          fetch  c_get_customer_name into lv_party_name;
          close  c_get_customer_name  ;
        end if;

        lr_trx_repo_extract.transaction_source  := r_repo_recs.source ;
        lr_trx_repo_extract.party_name          := lv_party_name;
        lr_trx_repo_extract.document_number     := r_repo_recs.source_document_id;
        lr_trx_repo_extract.document_date       := r_man_trx_rec.transaction_date;
        lr_trx_repo_extract.document_id         := r_repo_recs.source_document_id;
        lr_trx_repo_extract.document_line_desc  := nvl(r_man_trx_rec.remarks , 'Service Tax - Manual Transaction')
                                                                              || rtrim('/'||r_man_trx_rec.invoice_number,'/');
        lr_trx_repo_extract.organization_id     := r_repo_recs.organization_id;
        lr_trx_repo_extract.repository_tax_amt  := r_repo_recs.repository_tax_amt;

      end if; --> r_repo_recs.source

      lr_trx_repo_extract.transaction_repository_id :=    r_repo_recs.repository_id      ;
      lr_trx_repo_extract.transaction_reference_id  :=    r_repo_recs.reference_id       ;
      lr_trx_repo_extract.repository_source         :=    r_repo_recs.source             ;
      lr_trx_repo_extract.repository_invoice_id     :=    r_repo_recs.invoice_id         ;
      lr_trx_repo_extract.repository_line_id        :=    r_repo_recs.item_line_id       ;
      lr_trx_repo_extract.service_type_code         :=    r_repo_recs.service_type_code  ;

      jai_cmn_debug_contexts_pkg.print
                      (ln_reg_id
                      , 'Before insert into jai_trx_repo_extract_gt' || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.transaction_repository_id ='|| lr_trx_repo_extract.transaction_repository_id || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.transaction_reference_id  ='|| lr_trx_repo_extract.transaction_reference_id  || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.transaction_source        ='|| lr_trx_repo_extract.transaction_source        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.party_name                ='|| lr_trx_repo_extract.party_name                || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_number           ='|| lr_trx_repo_extract.document_number           || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_date             ='|| lr_trx_repo_extract.document_date             || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_id               ='|| lr_trx_repo_extract.document_id               || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_id          ='|| lr_trx_repo_extract.document_line_id          || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_num         ='|| lr_trx_repo_extract.document_line_num         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_item        ='|| lr_trx_repo_extract.document_line_item        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_desc        ='|| lr_trx_repo_extract.document_line_desc
                      );
     jai_cmn_debug_contexts_pkg.print
                     ( ln_reg_id
                     ,'lr_trx_repo_extract.document_line_qty         ='|| lr_trx_repo_extract.document_line_qty         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_uom         ='|| lr_trx_repo_extract.document_line_uom         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_amt         ='|| lr_trx_repo_extract.document_line_amt         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_currency_code    ='|| lr_trx_repo_extract.document_currency_code    || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.repository_tax_amt        ='|| lr_trx_repo_extract.repository_tax_amt        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.organization_name         ='|| lr_trx_repo_extract.organization_name         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.location_name             ='|| lr_trx_repo_extract.location_name             || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.organization_id           ='|| lr_trx_repo_extract.organization_id           || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.location_id               ='|| lr_trx_repo_extract.location_id               || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.inventory_item_id         ='|| lr_trx_repo_extract.inventory_item_id         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.party_id                  ='|| lr_trx_repo_extract.party_id                  || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.service_type_code         ='|| lr_trx_repo_extract.service_type_code
                     );
      insert into jai_trx_repo_extract_gt
          (
             transaction_repository_id
            ,transaction_reference_id
            ,transaction_source
            ,party_name
            ,document_number
            ,document_date
            ,document_id
            ,document_line_id
            ,document_line_num
            ,document_line_item
            ,document_line_desc
            ,document_line_qty
            ,document_line_uom
            ,document_line_amt
            ,document_currency_code
            ,repository_tax_amt
            ,organization_name
            ,location_name
            ,organization_id
            ,location_id
            ,inventory_item_id
            ,party_id
            ,service_type_code
            ,repository_invoice_id
            ,repository_line_id
            ,repository_source
            ,processed_flag
          )
       values
          (
              lr_trx_repo_extract.transaction_repository_id
             ,lr_trx_repo_extract.transaction_reference_id
             ,lr_trx_repo_extract.transaction_source
             ,lr_trx_repo_extract.party_name
             ,lr_trx_repo_extract.document_number
             ,lr_trx_repo_extract.document_date
             ,lr_trx_repo_extract.document_id
             ,lr_trx_repo_extract.document_line_id
             ,lr_trx_repo_extract.document_line_num
             ,lr_trx_repo_extract.document_line_item
             ,lr_trx_repo_extract.document_line_desc
             ,lr_trx_repo_extract.document_line_qty
             ,lr_trx_repo_extract.document_line_uom
             ,lr_trx_repo_extract.document_line_amt
             ,lr_trx_repo_extract.document_currency_code
             ,lr_trx_repo_extract.repository_tax_amt
             ,lr_trx_repo_extract.organization_name
             ,lr_trx_repo_extract.location_name
             ,lr_trx_repo_extract.organization_id
             ,lr_trx_repo_extract.location_id
             ,lr_trx_repo_extract.inventory_item_id
             ,lr_trx_repo_extract.party_id
             ,lr_trx_repo_extract.service_type_code
             ,lr_trx_repo_extract.repository_invoice_id
             ,lr_trx_repo_extract.repository_line_id
             ,lr_trx_repo_extract.repository_source
             ,null
          );
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'After insert into jai_trx_repo_extract_gt');
      jai_cmn_debug_contexts_pkg.print ( ln_reg_id, 'End of Loop -> for r_repo_recs in c_get_repo_recs');

    end loop; --> r_repo_recs in c_get_repo_recs


    --
    -- Fetch distinct documents from the global temporary table populated above and get document details for each distinct document
    -- and update temp table with document details
    --
    for r_docs in (select distinct  transaction_source
                                  , document_id
                                  , document_line_id
                   from             jai_trx_repo_extract_gt gt
                   where            gt.repository_source in ('AP','AR')
                   )
    loop

      lr_trx_repo_extract := null;
      if r_docs.transaction_source = 'ORDER MANAGEMENT' then

        -- Only line_id it self is primary key for oe_order_lines_all so only line_id will do the job
        jai_trx_repo_extract_pkg.get_document_details
                                (  p_document_id       =>  ''
                                 , p_document_line_id  =>  r_docs.document_line_id
                                 , p_document_source   =>  r_docs.transaction_source
                                 , p_called_from       =>  'JAINRPRW'
                                 , p_process_message   =>  p_process_message
                                 , p_process_flag      =>  p_process_flag
                                 , p_trx_repo_extract  =>  lr_trx_repo_extract
                                );

        if p_process_flag <> jai_constants.SUCCESSFUL then
          return;
        end if;
       /*added by csahoo for bug#6457710,start*/
       elsif r_docs.transaction_source = 'PROJECTS' then

        jai_trx_repo_extract_pkg.get_document_details
                                (  p_document_id       =>  r_docs.document_id
                                ,  p_document_line_id  =>  r_docs.document_line_id
                                ,  p_document_source   =>  r_docs.transaction_source
                                , p_called_from        =>  'JAINRPRW'
                                ,  p_process_message   =>  p_process_message
                                ,  p_process_flag      =>  p_process_flag
                                ,  p_trx_repo_extract  =>  lr_trx_repo_extract
                                );

        if p_process_flag <> jai_constants.SUCCESSFUL then
          return;
        end if;
  /*bug#6457710,end*/

      elsif r_docs.transaction_source = 'RECEIVABLES' then

        jai_trx_repo_extract_pkg.get_document_details
                                (  p_document_id       =>  r_docs.document_id
                                ,  p_document_line_id  =>  r_docs.document_line_id
                                ,  p_document_source   =>  r_docs.transaction_source
                                , p_called_from        =>  'JAINRPRW'
                                ,  p_process_message   =>  p_process_message
                                ,  p_process_flag      =>  p_process_flag
                                ,  p_trx_repo_extract  =>  lr_trx_repo_extract
                                );

        if p_process_flag <> jai_constants.SUCCESSFUL then
          return;
        end if;

      elsif r_docs.transaction_source = 'PURCHASING' then

        jai_trx_repo_extract_pkg.get_document_details
                                    (  p_document_id       =>  r_docs.document_id
                                    ,  p_document_line_id  =>  r_docs.document_line_id
                                    ,  p_document_source   =>  r_docs.transaction_source
                                    , p_called_from        =>  'JAINRPRW'
                                    ,  p_process_message   =>  p_process_message
                                    ,  p_process_flag      =>  p_process_flag
                                    ,  p_trx_repo_extract  =>  lr_trx_repo_extract
                                    );

      --Elsif added for Bug#6841116
         elsif r_docs.transaction_source = 'RECEIVING' then

                   jai_trx_repo_extract_pkg.get_document_details
                                       (  p_document_id       =>  r_docs.document_id
                                       ,  p_document_line_id  =>  r_docs.document_line_id
                                       ,  p_document_source   =>  r_docs.transaction_source
                                       , p_called_from        =>  'JAINRPRW'
                                       ,  p_process_message   =>  p_process_message
                                       ,  p_process_flag      =>  p_process_flag
                                       ,  p_trx_repo_extract  =>  lr_trx_repo_extract
                                       );

         --Till Here Bug#6841116
   elsif r_docs.transaction_source = 'STANDALONE_INVOICE' then  --Added for bug#8943349

                   jai_trx_repo_extract_pkg.get_document_details
                                       (  p_document_id       =>  r_docs.document_id
                                       ,  p_document_line_id  =>  r_docs.document_line_id
                                       ,  p_document_source   =>  r_docs.transaction_source
                                       , p_called_from        =>  'JAINRPRW'
                                       ,  p_process_message   =>  p_process_message
                                       ,  p_process_flag      =>  p_process_flag
                                       ,  p_trx_repo_extract  =>  lr_trx_repo_extract
                                       );
    if p_process_flag <> jai_constants.SUCCESSFUL then
          return;
        end if;
         --End of bug#8943349
      end if;

      --
      -- For each document line check if repository has a settled record with a service type attached.  If yes, then get the service type
      -- of the settled line and default it to current document line and mark the record as non-updatable
      --

      lv_service_type_code := get_settled_service_type
                              ( p_transaction_source => r_docs.transaction_source
                              , p_document_id        => lr_trx_repo_extract.document_id
                              , p_document_line_id   => lr_trx_repo_extract.document_line_id
                              );
      if lv_service_type_code is not null then

        lr_trx_repo_extract.service_type_code := lv_service_type_code;
        lr_trx_repo_extract.updatable_flag    := jai_constants.NO;
        lr_trx_repo_extract.processed_flag    := jai_constants.NO;

      end if;


      jai_cmn_debug_contexts_pkg.print
                      (ln_reg_id
                      , 'Before update into jai_trx_repo_extract_gt' || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.transaction_source        ='|| lr_trx_repo_extract.transaction_source        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.party_name                ='|| lr_trx_repo_extract.party_name                || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_number           ='|| lr_trx_repo_extract.document_number           || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_date             ='|| lr_trx_repo_extract.document_date             || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_id               ='|| lr_trx_repo_extract.document_id               || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_id          ='|| lr_trx_repo_extract.document_line_id          || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_num         ='|| lr_trx_repo_extract.document_line_num         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_item        ='|| lr_trx_repo_extract.document_line_item        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_desc        ='|| lr_trx_repo_extract.document_line_desc
                      );
     jai_cmn_debug_contexts_pkg.print
                     ( ln_reg_id
                     ,'lr_trx_repo_extract.document_line_qty         ='|| lr_trx_repo_extract.document_line_qty         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_uom         ='|| lr_trx_repo_extract.document_line_uom         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_line_amt         ='|| lr_trx_repo_extract.document_line_amt         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.document_currency_code    ='|| lr_trx_repo_extract.document_currency_code    || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.repository_tax_amt        ='|| lr_trx_repo_extract.repository_tax_amt        || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.organization_name         ='|| lr_trx_repo_extract.organization_name         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.location_name             ='|| lr_trx_repo_extract.location_name             || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.organization_id           ='|| lr_trx_repo_extract.organization_id           || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.location_id               ='|| lr_trx_repo_extract.location_id               || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.inventory_item_id         ='|| lr_trx_repo_extract.inventory_item_id         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.party_id                  ='|| lr_trx_repo_extract.party_id                  || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.service_type_code         ='|| lr_trx_repo_extract.service_type_code         || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.updatable_flag            ='|| lr_trx_repo_extract.updatable_flag            || fnd_global.local_chr(10) ||
                      'lr_trx_repo_extract.processed_flag            ='|| lr_trx_repo_extract.processed_flag
                     );

      update jai_trx_repo_extract_gt
      set  transaction_source     =  lr_trx_repo_extract.transaction_source
       ,   party_name             =  lr_trx_repo_extract.party_name
       ,   document_number        =  lr_trx_repo_extract.document_number
       ,   document_date          =  lr_trx_repo_extract.document_date
       ,   document_id            =  lr_trx_repo_extract.document_id
       ,   document_line_id       =  lr_trx_repo_extract.document_line_id
       ,   document_line_num      =  lr_trx_repo_extract.document_line_num
       ,   document_line_item     =  lr_trx_repo_extract.document_line_item
       ,   document_line_desc     =  lr_trx_repo_extract.document_line_desc
       ,   document_line_qty      =  lr_trx_repo_extract.document_line_qty
       ,   document_line_uom      =  lr_trx_repo_extract.document_line_uom
       ,   document_line_amt      =  lr_trx_repo_extract.document_line_amt
       ,   repository_tax_amt     =  lr_trx_repo_extract.repository_tax_amt
       ,   document_currency_code =  lr_trx_repo_extract.document_currency_code
       ,   inventory_item_id      =  lr_trx_repo_extract.inventory_item_id
       ,   party_id               =  lr_trx_repo_extract.party_id
       ,   organization_id        =  nvl(lr_trx_repo_extract.organization_id, organization_id)
       ,   location_id            =  nvl(lr_trx_repo_extract.location_id,location_id)
       ,   service_type_code      =  nvl(lr_trx_repo_extract.service_type_code, service_type_code)
       ,   updatable_flag         =  lr_trx_repo_extract.updatable_flag
       ,   processed_flag         =  lr_trx_repo_extract.processed_flag
      where transaction_source    =  r_docs.transaction_source
      and   (  (r_docs.document_id is not null and document_id  =  r_docs.document_id)
            or r_docs.document_id is null -- incase of order management it will be null
            )
      and   document_line_id     =  r_docs.document_line_id;

      jai_cmn_debug_contexts_pkg.print
                     ( ln_reg_id
                     , 'Number of rows updated ='||sql%rowcount
                     );
    end loop;

    --
    -- Get organization name for each distinct organization
    --

    for r_org in (select distinct organization_id from jai_trx_repo_extract_gt where organization_id is not null)
    loop

      jai_cmn_debug_contexts_pkg.print
                      (ln_reg_id
                      , 'OPEN/FETCH/CLOSE c_get_organization_name, r_org.organization_id='||r_org.organization_id
                      );

      open  c_get_organization_name (cp_organization_id => r_org.organization_id);
      fetch c_get_organization_name into lv_organization_name;
      close c_get_organization_name ;

      jai_cmn_debug_contexts_pkg.print
                (ln_reg_id
                ,'lv_organization_name='||lv_organization_name
                );


      update jai_trx_repo_extract_gt
      set    organization_name = lv_organization_name
      where  organization_id = r_org.organization_id;

    end loop;

    --
    -- Get location name for each distinct location
    --

    for r_loc in (select distinct location_id from jai_trx_repo_extract_gt where location_id is not null )
    loop
      jai_cmn_debug_contexts_pkg.print
                      (ln_reg_id
                      ,'OPEN/FETCH/CLOSE c_get_location_name, r_loc.location_id='||r_loc.location_id
                      );

      open  c_get_location_name (cp_location_id => r_loc.location_id);
      fetch c_get_location_name into lv_location_name;
      close c_get_location_name ;

      jai_cmn_debug_contexts_pkg.print
                      (ln_reg_id
                      ,'lv_location_name='||lv_location_name
                      );

      update jai_trx_repo_extract_gt
      set    location_name = lv_location_name
      where  location_id = r_loc.location_id;

    end loop;

    /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;
  end extract_rgm_trxs;

  /*------------------------------------------------------------------------------------------------------------*/


  procedure get_document_details
              (
                 p_document_id       in          number
              ,  p_document_line_id  in          number
              ,  p_document_source   in          varchar2
              ,  p_called_from       in          varchar2   default  null
              ,  p_process_message   out nocopy  varchar2
              ,  p_process_flag      out nocopy  varchar2
              ,  p_trx_repo_extract  in  out nocopy  jai_trx_repo_extract_gt%rowtype
              )
  as
    ln_reg_id   number;


    /*Added parameters cp_header_id and cp_line_id in c_get_po_details by vkantamn for Bug #6083978*/
    cursor c_get_po_details(cp_header_id number, cp_line_id number)
    is
    select pov.vendor_name      party_name
          ,poh.segment1         document_number
          ,poh.creation_date    document_date
          ,poh.po_header_id     document_id
          ,pol.po_line_id       document_line_id
          ,pol.line_num         document_line_num
          ,msi.segment1         document_line_item
          ,pol.item_description document_line_desc
          ,pol.quantity         document_line_qty
          ,pol.unit_meas_lookup_code document_line_uom
          ,(pol.unit_price * pol.quantity)  document_line_amt
          ,poh.currency_code    document_currency_code
          ,pol.item_id          inventory_item_id
          ,poh.vendor_id        party_id
         -- ,fsp.inventory_organization_id  organization_id /* Commented by vkantamn for Bug#6083978 */
    ,hl.inventory_organization_id  organization_id /* Added by vkantamn for Bug#6083978 */
          ,poll.ship_to_location_id       location_id
    from   po_headers_all     poh
         , po_lines_all       pol
         , po_line_locations_all  poll /*6841116*/
         , mtl_system_items   msi
         , po_vendors         pov
   , hr_locations       hl /* Added by vkantamn for Bug#6083978 */
        -- , financials_system_parameters fsp /* Commented by vkantamn for Bug#6083978 */
    where
           --poh.po_header_id = p_document_id /* Commented by vkantamn for Bug#6083978 */
     poh.po_header_id = cp_header_id /* Added by vkantamn for Bug#6083978 */
    and    pol.po_header_id = poh.po_header_id
   -- and    pol.po_line_id   = p_document_line_id /* Commented by vkantamn for Bug#6083978 */
    and    pol.po_line_id   = cp_line_id /* Added by vkantamn for Bug#6083978 */
    and    pol.po_line_id    = poll.po_line_id
    and    poll.po_header_id = poh.po_header_id
    and    pol.item_id      = msi.inventory_item_id (+)
    --and    nvl(msi.organization_id ,fsp.inventory_organization_id )= fsp.inventory_organization_id  /* Commented by vkantamn for Bug#6026463 */
    and    nvl(poll.ship_to_location_id,poh.ship_to_location_id )= hl.location_id  /*Commented by nprashar for bug # 6636517 and    poh.ship_to_location_id = hl.location_id */ /* Added by vkantamn for Bug#6083978 */
    and    pov.vendor_id = poh.vendor_id  ;

    cursor c_get_so_details
    is
      select hzp.party_name           party_name
          ,  oeh.order_number         document_number
          ,  oeh.ordered_date         document_date
          ,  oeh.header_id            document_id
          ,  oel.line_id              document_line_id
          ,  oel.line_number          document_line_num
          ,  msi.segment1             document_line_item
          ,  substr(oel.user_item_description,1,240) document_line_desc
          ,  oel.ordered_quantity     document_line_qty
          ,  oel.order_quantity_uom   document_line_uom
          ,  nvl(oel.unit_selling_price * oel.ordered_quantity,0) document_line_amt
          ,  oeh.transactional_curr_code  document_currency_code
          ,  oel.inventory_item_id    inventory_item_id
          ,  oeh.sold_to_org_id       party_id
          ,  oel.ship_from_org_id     organization_id
          ,  oel.line_category_code   line_category_code
      from
             oe_order_headers_all   oeh
            ,oe_order_lines_all     oel
            ,hz_parties             hzp
            ,hz_cust_accounts       hzca
            ,mtl_system_items       msi
      where  (p_document_id is null or  p_document_id = '' or oeh.header_id = p_document_id)
      and    oel.header_id = oeh.header_id
      and    oel.line_id   = p_document_line_id
      and    oel.inventory_item_id = msi.inventory_item_id
      and    oel.ship_from_org_id  = msi.organization_id
      and    hzca.cust_account_id  = oel.sold_to_org_id
      and    hzca.party_id         = hzp.party_id ;

  cursor c_get_ra_trx_details
  is
    select  hzp.party_name
           ,rct.trx_number              document_number
           ,rct.trx_date                document_date
           ,rct.customer_trx_id         document_id
           ,rctl.customer_trx_line_id   document_line_id
           ,rctl.line_number            document_line_num
           ,msi.segment1                document_line_item
           ,rctl.description            document_line_desc
           ,rctl.quantity_invoiced      document_line_qty
           ,rctl.uom_code               document_line_uom
           ,rctl.extended_amount        document_line_amt
           ,rct.invoice_currency_code   document_currency_code
           ,rctl.inventory_item_id      inventory_item_id
           ,nvl(rct.sold_to_customer_id, rct.bill_to_customer_id) party_id
           ,jrct.organization_id        organization_id
           ,jrct.location_id            location_id
    from   ra_customer_trx_all        rct
          ,ra_customer_trx_lines_all  rctl
          ,jai_ar_trxs      jrct
          ,hz_parties                 hzp
          ,hz_cust_accounts           hzca
          ,mtl_system_items           msi
    where rct.customer_trx_id = p_document_id
    and   jrct.customer_trx_id = rct.customer_trx_id
    and   rctl.customer_trx_id = rct.customer_trx_id
    and   rctl.customer_trx_line_id = p_document_line_id
    and   rctl.inventory_item_id    = msi.inventory_item_id (+)
    and   nvl(msi.organization_id,jrct.organization_id) = jrct.organization_id
    and   hzca.cust_account_id      = nvl(rct.sold_to_customer_id, rct.bill_to_customer_id)
    and   hzca.party_id             = hzp.party_id;

    -- Begin 5876390, 6012570
    /*modified the below cusrsor query to select from the tables PA_DRAFT_INVOICES_ALL,
    PA_PROJECTS_ALL instead of pa_draft_invoices_v.*/
    cursor c_get_pa_details
    is
    select   c.customer_name     party_name,
            p.segment1
             ||'/'
             ||padi.draft_invoice_num
                                            document_number
          ,  padi.creation_date             document_date
          ,  jpadi.draft_invoice_id         document_id
          ,  jpadil.draft_invoice_line_id   document_line_id
          ,  jpadil.line_num                document_line_num
          ,  null                           document_line_item
          -- Modified by Jia for FP Bug#6691866, Begin
          -------------------------------------------------------------------------------------------------
          --,  substr(padil.text,1,240)       document_line_desc -- Comment by Jia for FP Bug#6691866
          ,  (select substr(padil.text,1,240) from pa_draft_invoice_items padil
                                              where padil.draft_invoice_num = jpadi.draft_invoice_num
                                              and padil.project_id =jpadi.project_id
                                              and padil.line_num = jpadil.line_num  ) document_line_desc -- Added by Jia for FP Bug#6691866
          -------------------------------------------------------------------------------------------------
          -- Modified by Jia for FP Bug#6691866, End
          ,  null                           document_line_qty
          ,  null                           document_line_uom
          ,  jpadil.line_amt                document_line_amt
          ,  padi.inv_currency_code     document_currency_code
          ,  null                           inventory_item_id
          ,  padi.ship_to_customer_id       party_id
          ,  jpadi.organization_id          organization_id
          ,  jpadi.location_id              location_id
          ,  jpadil.service_type_code        service_type_code
      from
             PA_DRAFT_INVOICES_ALL       padi,
             PA_PROJECTS_ALL p
           -- ,pa_draft_invoice_items    padil  Removed by Jia for FP Bug#6691866
            ,jai_pa_draft_invoices     jpadi
            ,jai_pa_draft_invoice_lines jpadil
            ,PA_CUSTOMERS_V c
      where  jpadi.draft_invoice_id = p_document_id
      and    jpadil.draft_invoice_line_id = p_document_line_id
      and    jpadi.draft_invoice_id       = jpadil.draft_invoice_id
      and    jpadi.project_id         = padi.project_id
      and    jpadi.draft_invoice_num  = padi.draft_invoice_num
      and    p.project_id=padi.project_id
      and    padi.ship_to_customer_id=c.customer_id;
      -- End 5876390, 6012570


    cursor c_get_po_line_loc_srvtyp (cp_po_line_id  po_lines_all.po_line_id%type )
     is
      select service_type_code, sum(jpollt.tax_amount) service_tax_amount
      from   JAI_PO_LINE_LOCATIONS jpoll
            ,jai_po_taxes jpollt
      where  jpoll.po_line_id = cp_po_line_id
      and    jpollt.line_location_id = jpoll.line_location_id
      /*added the cess and sh cess tax types for bug#6457710*/
      and    jpollt.tax_type IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
      --and    jpollt.tax_type = 'Service'
      group by service_type_code;

    cursor c_get_ra_line_srvtyp (cp_customer_trx_line_id    jai_ar_trx_lines.customer_trx_line_id%type)
    is
      select service_type_code, sum(jrcttl.tax_amount) service_tax_amount
      from   JAI_AR_TRX_LINES jrctl
            ,JAI_AR_TRX_TAX_LINES jrcttl
            ,jai_cmn_taxes_all        jtc
      where  jrctl.customer_trx_line_id = cp_customer_trx_line_id
      and    jrcttl.link_to_cust_trx_line_id = jrctl.customer_trx_line_id
      and    jtc.tax_id                  = jrcttl.tax_id
      /*added the cess and sh cess tax types for bug#6457710*/
      and    jtc.tax_type IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
      --and    jtc.tax_type = 'Service'
      group  by service_type_code;

	--Added below cursor for bug#9298508 by JMEENA
	CURSOR c_get_ra_tax_amt_applied(cp_customer_trx_id	NUMBER)	IS
	SELECT Sum(Nvl(jrec.TRX_DEBIT_AMOUNT,0))+Sum(Nvl(jrec.TRX_CREDIT_AMOUNT,0))
	FROM      jai_rgm_trx_refs jref,  jai_rgm_trx_records jrec
	WHERE jref.invoice_id= cp_customer_trx_id
	AND jrec.reference_id=jref.reference_id
    AND jrec.TAX_TYPE IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess);

	CURSOR c_get_ra_line_amt_applied (cp_customer_trx_id	NUMBER) IS
	SELECT Sum(Nvl(line_applied,0)) FROM AR_RECEIVABLE_APPLICATIONS_ALL
	WHERE APPLIED_CUSTOMER_TRX_ID = cp_customer_trx_id
	AND status= jai_constants.ar_status_app;
	--End bug#9298508

    cursor c_get_so_line_srvtyp (cp_line_id  JAI_OM_OE_SO_LINES.line_id%type ) is
      select service_type_code, sum(jstl.tax_amount) service_tax_amount
      from    JAI_OM_OE_SO_LINES jsl
           , JAI_OM_OE_SO_TAXES jstl
           , jai_cmn_taxes_all jtc
      where  jsl.line_id  = cp_line_id
      and    jsl.line_id  = jstl.line_id
      and    jstl.tax_id =  jtc.tax_id
      /*added the cess and sh cess tax types for bug#6457710*/
      and    jtc.tax_type IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
      --and    jtc.tax_type = 'Service'
      group by service_type_code;

    /*The following cursor added by rchandan for RMA */

    cursor c_get_rma_line_srvtyp (cp_line_id jai_om_oe_so_lines.line_id%type )
    is
      select service_type_code, sum(jrtl.tax_amount) service_tax_amount
      from     JAI_OM_OE_RMA_LINES  jrl
           , JAI_OM_OE_RMA_TAXES jrtl
           , JAI_CMN_TAXES_ALL jtc
      where  jrl.rma_line_id  = cp_line_id
      and    jrl.rma_line_id  = jrtl.rma_line_id
      and    jrtl.tax_id =  jtc.tax_id
      /*added the cess and sh cess tax types for bug#6457710*/
      and    jtc.tax_type IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
      --and    jtc.tax_type = 'Service'
      group by service_type_code;

    -- Bug  5876390, 6012570
    cursor c_get_pa_inv_line_tax (cp_line_id jai_cmn_document_taxes.source_doc_line_id%type )
    is
      select sum(tax_amt) service_tax_amount
      from   jai_cmn_document_taxes jcdt
           , jai_cmn_taxes_all jtc
      where  jcdt.source_doc_line_id  = cp_line_id
      and    jcdt.source_doc_type = jai_constants.PA_DRAFT_INVOICE
      and    jcdt.tax_id =  jtc.tax_id
      /*added the cess and sh cess tax types for bug#6457710*/
      and    jtc.tax_type IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess);
      --and    jtc.tax_type = 'Service';

   /*Started addition by vkantamn for Bug#6083978*/
    cursor c_get_rcv_details
    is
    select rcv.organization_id  organization_id
          ,rcv.location_id       location_id
          ,rsl.po_header_id po_header_id
          ,rsl.po_line_id       po_line_id
    from   jai_rcv_transactions     rcv,
     rcv_shipment_lines rsl
    where
           rcv.shipment_header_id = rsl.shipment_header_id
    and    rcv.shipment_line_id = rsl.shipment_line_id
    and    rcv.shipment_header_id = p_document_id
    and    rcv.shipment_line_id   = p_document_line_id
    and    rcv.transaction_type = 'RECEIVE';
  --Start bug#8943349 by JMEENA
  CURSOR c_get_standalone_inv_details IS
    select pov.vendor_name      party_name
            ,apa.invoice_num         document_number
            ,apa.creation_date    document_date
            ,apa.invoice_id     document_id
            ,NULL       document_line_id
            ,apla.line_number         document_line_num
            ,NULL                 document_line_item
            ,NULL                 document_line_desc
            ,NULL                 document_line_qty
            ,NULL                 document_line_uom
            ,apla.amount     document_line_amt
            ,jasl.currency_code    document_currency_code
            ,NULL                  inventory_item_id
            ,apa.vendor_id        party_id
            ,jasl.organization_id  organization_id
            ,jasl.location_id       location_id
      from   ap_invoices_all    apa
           , ap_invoice_lines_all   apla
           , po_vendors         pov
           , jai_ap_invoice_lines jasl
      where
             apa.invoice_id = p_document_id
      and    apa.invoice_id = apla.invoice_id
      and    apla.line_number   = p_document_line_id
      and    jasl.invoice_id = apa.invoice_id
      and    jasl.invoice_line_number = apla.line_number
      and    pov.vendor_id = apa.vendor_id ;

  CURSOR c_get_standalone_org_loc  IS
       SELECT organization_id, location_id
       FROM JAI_AP_INVOICE_LINES
       where invoice_id = p_document_id
       and PARENT_INVOICE_LINE_NUMBER is NULL;

  CURSOR c_get_standalone_inv_line_tax (cp_invoice_id jai_cmn_document_taxes.source_doc_id%type, cp_line_id jai_cmn_document_taxes.source_doc_line_id%type) IS
        Select service_type_code,sum(jcdt.tax_amt)
      from jai_ap_invoice_lines jasl,
              jai_cmn_document_taxes jcdt,
        jai_cmn_taxes_all      jcta
        where source_doc_line_id  = cp_line_id
      AND jcdt.source_doc_id = cp_invoice_id
      AND jasl.invoice_id = jcdt.source_doc_id
        and jasl.invoice_line_number = jcdt.source_doc_line_id
      and jcta.tax_id      = jcdt.tax_id
      and jcta.tax_type    IN (jai_constants.tax_type_service,jai_constants.tax_type_service_edu_cess,jai_constants.tax_type_sh_service_edu_cess)
      GROUP BY service_type_code;

  r_ap_details c_get_standalone_inv_details%rowtype;
  r_standalone_org_loc c_get_standalone_org_loc%rowtype;
--End of bug#8943349 by JMEENA

    v_organization_id   number;
    v_location_id   number;
    v_po_header_id    number;
    v_po_line_id    number;

   /*End of addition by vkantamn for Bug#6083978*/

    r_po_details          c_get_po_details%rowtype;
    r_so_details          c_get_so_details%rowtype;
    r_ra_trx_details      c_get_ra_trx_details%rowtype;
    r_pa_details          c_get_pa_details%rowtype; -- Bug  5876390, 6012570


    lv_service_type       jai_rgm_trx_records.service_type_code%type;

  begin

    lv_member_name := 'GET_DOCUMENT_DETAILS';
    set_debug_context;
    p_process_flag := jai_constants.SUCCESSFUL;
    jai_cmn_debug_contexts_pkg.register ( pv_context => lv_context
                                        , pn_reg_id  => ln_reg_id
                                        );

    jai_cmn_debug_contexts_pkg.print ( ln_reg_id
                                     ,'Call Parameters:'      ||fnd_global.local_chr(10)
                                                     ||'p_document_id       =' ||p_document_id       ||fnd_global.local_chr(10)
                                                     ||'p_document_line_id  =' ||p_document_line_id  ||fnd_global.local_chr(10)
                                                     ||'p_document_source   =' ||p_document_source   ||fnd_global.local_chr(10)
                                     );

    if  p_document_line_id is null or p_document_source is null then
      p_process_message := 'Document references cannot be null, cannot continue to derive the document details';
      p_process_flag    := jai_constants.EXPECTED_ERROR;
      return;
    end if;

    --
    -- Check for source and based on the source deligate control to respective procedure to fetch the details
    --
    if p_document_source = 'PURCHASING' then
      --open  c_get_po_details;
      /*Added parameters to cursor by vkantamn for Bug#6083978 */
      open  c_get_po_details(p_document_id,p_document_line_id);
      fetch c_get_po_details into r_po_details;
      close c_get_po_details;

      if r_po_details.document_id is null then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                         ,'Purchase Order does not exists for po_header_id ='||p_document_id ||' and po_line_id='|| p_document_line_id
                                         );
      end if;

      p_trx_repo_extract.transaction_source        :=  'PURCHASING'                         ;
      p_trx_repo_extract.party_name                :=  r_po_details.party_name              ;
      p_trx_repo_extract.document_number           :=  r_po_details.document_number         ;
      p_trx_repo_extract.document_date             :=  r_po_details.document_date           ;
      p_trx_repo_extract.document_id               :=  r_po_details.document_id             ;
      p_trx_repo_extract.document_line_id          :=  r_po_details.document_line_id        ;
      p_trx_repo_extract.document_line_num         :=  r_po_details.document_line_num       ;
      p_trx_repo_extract.document_line_item        :=  r_po_details.document_line_item      ;
      p_trx_repo_extract.document_line_desc        :=  r_po_details.document_line_desc      ;
      p_trx_repo_extract.document_line_qty         :=  r_po_details.document_line_qty       ;
      p_trx_repo_extract.document_line_uom         :=  r_po_details.document_line_uom       ;
      p_trx_repo_extract.document_line_amt         :=  r_po_details.document_line_amt       ;
      p_trx_repo_extract.document_currency_code    :=  r_po_details.document_currency_code  ;
      p_trx_repo_extract.inventory_item_id         :=  r_po_details.inventory_item_id       ;
      p_trx_repo_extract.party_id                  :=  r_po_details.party_id                ;
      p_trx_repo_extract.organization_id           :=  r_po_details.organization_id         ;
      p_trx_repo_extract.location_id               :=  r_po_details.location_id             ;

      open  c_get_po_line_loc_srvtyp (cp_po_line_id => p_document_line_id) ;
      fetch c_get_po_line_loc_srvtyp into lv_service_type
                                         ,p_trx_repo_extract.repository_tax_amt;
      close c_get_po_line_loc_srvtyp;

      if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
      -- if called from Repository Review UI then do not default service type from document
        p_trx_repo_extract.service_type_code := lv_service_type;
      end if;


    end if;

    /*Started addition by vkantamn for Bug#6083978*/

     IF p_document_source = 'RECEIVING' THEN

  open  c_get_rcv_details;
  fetch c_get_rcv_details into v_organization_id,v_location_id,v_po_header_id,v_po_line_id;
  close c_get_rcv_details;

       open  c_get_po_details(v_po_header_id,v_po_line_id);
       fetch c_get_po_details into r_po_details;
       close c_get_po_details;

       if r_po_details.document_id is null then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                         ,'Purchase Order does not exists for po_header_id ='||p_document_id ||' and po_line_id='|| p_document_line_id
                                         );
       end if;

      p_trx_repo_extract.transaction_source        :=  'RECEIVING'                         ;
      p_trx_repo_extract.party_name                :=  r_po_details.party_name              ;
      p_trx_repo_extract.document_number           :=  r_po_details.document_number         ;
      p_trx_repo_extract.document_date             :=  r_po_details.document_date           ;
      p_trx_repo_extract.document_id               :=  r_po_details.document_id             ;
      p_trx_repo_extract.document_line_id          :=  r_po_details.document_line_id        ;
      p_trx_repo_extract.document_line_num         :=  r_po_details.document_line_num       ;
      p_trx_repo_extract.document_line_item        :=  r_po_details.document_line_item      ;
      p_trx_repo_extract.document_line_desc        :=  r_po_details.document_line_desc      ;
      p_trx_repo_extract.document_line_qty         :=  r_po_details.document_line_qty       ;
      p_trx_repo_extract.document_line_uom         :=  r_po_details.document_line_uom       ;
      p_trx_repo_extract.document_line_amt         :=  r_po_details.document_line_amt       ;
      p_trx_repo_extract.document_currency_code    :=  r_po_details.document_currency_code  ;
      p_trx_repo_extract.inventory_item_id         :=  r_po_details.inventory_item_id       ;
      p_trx_repo_extract.party_id                  :=  r_po_details.party_id                ;
      p_trx_repo_extract.organization_id           :=  v_organization_id        ;
      --modified the IF clause for bug#8451703
      if nvl(v_location_id,0) = 0 then
        p_trx_repo_extract.location_id               :=  r_po_details.location_id;
      else
        p_trx_repo_extract.location_id               :=  v_location_id;
      end if;

      open  c_get_po_line_loc_srvtyp (cp_po_line_id => v_po_line_id) ;
      fetch c_get_po_line_loc_srvtyp into lv_service_type,p_trx_repo_extract.repository_tax_amt;
      close c_get_po_line_loc_srvtyp;

      if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
      -- if called from Repository Review UI then do not default service type from document
        p_trx_repo_extract.service_type_code := lv_service_type;
      end if;

     END IF;

    /*Addition done by vkantamn for Bug#6083978*/

    if p_document_source = 'ORDER MANAGEMENT' then

      open  c_get_so_details;
      fetch c_get_so_details into r_so_details;
      close c_get_so_details;

      if r_so_details.document_id is null then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                         ,'Sales Order does not exists for header_id='||p_document_id ||' and line_id ='||p_document_line_id
                                         );
      end if;

      p_trx_repo_extract.transaction_source        :=  'ORDER MANAGEMENT'                   ;
      p_trx_repo_extract.party_name                :=  r_so_details.party_name              ;
      p_trx_repo_extract.document_number           :=  r_so_details.document_number         ;
      p_trx_repo_extract.document_date             :=  r_so_details.document_date           ;
      p_trx_repo_extract.document_id               :=  r_so_details.document_id             ;
      p_trx_repo_extract.document_line_id          :=  r_so_details.document_line_id        ;
      p_trx_repo_extract.document_line_num         :=  r_so_details.document_line_num       ;
      p_trx_repo_extract.document_line_item        :=  r_so_details.document_line_item      ;
      p_trx_repo_extract.document_line_desc        :=  r_so_details.document_line_desc      ;
      p_trx_repo_extract.document_line_qty         :=  r_so_details.document_line_qty       ;
      p_trx_repo_extract.document_line_uom         :=  r_so_details.document_line_uom       ;
      p_trx_repo_extract.document_line_amt         :=  r_so_details.document_line_amt       ;
      p_trx_repo_extract.document_currency_code    :=  r_so_details.document_currency_code  ;
      p_trx_repo_extract.inventory_item_id         :=  r_so_details.inventory_item_id       ;
      p_trx_repo_extract.party_id                  :=  r_so_details.party_id                ;
      p_trx_repo_extract.organization_id           :=  r_so_details.organization_id         ;
      --
      -- For sales order location will be derrived from invoice because an order can be a bill only or it can be a normal shipped order
      -- In order to derrive location complex logic needs to be implemented to check order type and based on that derive the location
      -- However here we already have a reference of invoice so it is better to derrive it from invoice only
      -- As an enahcement to this API a logic can be added here to derrive the location using order reference only

      IF r_so_details.line_category_code = 'ORDER' THEN

        open  c_get_so_line_srvtyp (cp_line_id => p_document_line_id);
        fetch c_get_so_line_srvtyp into  lv_service_type
                                        ,p_trx_repo_extract.repository_tax_amt;
        close c_get_so_line_srvtyp ;

      ELSIF r_so_details.line_category_code = 'RETURN' THEN

        open c_get_rma_line_srvtyp(cp_line_id => p_document_line_id);
        fetch c_get_rma_line_srvtyp into  lv_service_type
                                        ,p_trx_repo_extract.repository_tax_amt;
        close c_get_rma_line_srvtyp ;

      END IF;

      if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
      -- if called from Repository Review UI then do not default service type from document
        p_trx_repo_extract.service_type_code := lv_service_type;
      end if;


    end if;

    -- Begin 5876390, 6012570
    if p_document_source = 'PROJECTS' then -- Projects Invoice

      open  c_get_pa_details;
      fetch c_get_pa_details into r_pa_details;
      close c_get_pa_details;

      if r_pa_details.document_id is null then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                         ,'Project Draft Invoice does not exists for p_document_id ='||p_document_id ||' and p_document_line_id='||p_document_line_id
                                         );
      end if;

      p_trx_repo_extract.transaction_source        :=  'PROJECTS'                  ;
      p_trx_repo_extract.party_name                :=  r_pa_details.party_name              ;
      p_trx_repo_extract.document_number           :=  r_pa_details.document_number         ;
      p_trx_repo_extract.document_date             :=  r_pa_details.document_date           ;
      p_trx_repo_extract.document_id               :=  r_pa_details.document_id             ;
      p_trx_repo_extract.document_line_id          :=  r_pa_details.document_line_id        ;
      p_trx_repo_extract.document_line_num         :=  r_pa_details.document_line_num       ;
      p_trx_repo_extract.document_line_item        :=  r_pa_details.document_line_item      ;
      p_trx_repo_extract.document_line_desc        :=  r_pa_details.document_line_desc      ;
      p_trx_repo_extract.document_line_qty         :=  r_pa_details.document_line_qty       ;
      p_trx_repo_extract.document_line_uom         :=  r_pa_details.document_line_uom       ;
      p_trx_repo_extract.document_line_amt         :=  r_pa_details.document_line_amt       ;
      p_trx_repo_extract.document_currency_code    :=  r_pa_details.document_currency_code  ;
      p_trx_repo_extract.inventory_item_id         :=  r_pa_details.inventory_item_id       ;
      p_trx_repo_extract.party_id                  :=  r_pa_details.party_id                ;
      p_trx_repo_extract.organization_id           :=  r_pa_details.organization_id         ;
      p_trx_repo_extract.location_id               :=  r_pa_details.location_id              ;
      lv_service_type                              :=  r_pa_details.service_type_code       ;

      open  c_get_pa_inv_line_tax (cp_line_id => r_pa_details.document_line_id);
      fetch c_get_pa_inv_line_tax into  p_trx_repo_extract.repository_tax_amt;
      close c_get_pa_inv_line_tax ;

      if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
      -- if called from Repository Review UI then do not default service type from document
        p_trx_repo_extract.service_type_code := lv_service_type;
      end if;


    end if;
    -- End 5876390, 6012570

    if p_document_source = 'RECEIVABLES' then

      open  c_get_ra_trx_details;
      fetch c_get_ra_trx_details into r_ra_trx_details;
      close c_get_ra_trx_details;

      if r_ra_trx_details.document_id is null then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                          ,'AR Transaction does not exists for ra_customer_trx_id='||p_document_id ||' and customer_trx_line_id='||p_document_line_id
                                         );
      end if;
      p_trx_repo_extract.transaction_source        :=  'RECEIVABLES'                             ;
      p_trx_repo_extract.party_name                :=  r_ra_trx_details.party_name              ;
      p_trx_repo_extract.document_number           :=  r_ra_trx_details.document_number         ;
      p_trx_repo_extract.document_date             :=  r_ra_trx_details.document_date           ;
      p_trx_repo_extract.document_id               :=  r_ra_trx_details.document_id             ;
      p_trx_repo_extract.document_line_id          :=  r_ra_trx_details.document_line_id        ;
      p_trx_repo_extract.document_line_num         :=  r_ra_trx_details.document_line_num       ;
      p_trx_repo_extract.document_line_item        :=  r_ra_trx_details.document_line_item      ;
      p_trx_repo_extract.document_line_desc        :=  r_ra_trx_details.document_line_desc      ;
      p_trx_repo_extract.document_line_qty         :=  r_ra_trx_details.document_line_qty       ;
      p_trx_repo_extract.document_line_uom         :=  r_ra_trx_details.document_line_uom       ;
 --     p_trx_repo_extract.document_line_amt         :=  r_ra_trx_details.document_line_amt       ; -- Commented for  bug#9298508 by JMEENA
      p_trx_repo_extract.document_currency_code    :=  r_ra_trx_details.document_currency_code  ;
      p_trx_repo_extract.inventory_item_id         :=  r_ra_trx_details.inventory_item_id       ;
      p_trx_repo_extract.party_id                  :=  r_ra_trx_details.party_id                ;
      p_trx_repo_extract.organization_id           :=  r_ra_trx_details.organization_id         ;
      p_trx_repo_extract.location_id               :=  r_ra_trx_details.location_id             ;

      open  c_get_ra_line_srvtyp (cp_customer_trx_line_id => p_document_line_id) ;
      fetch c_get_ra_line_srvtyp into lv_service_type
                                     ,p_trx_repo_extract.repository_tax_amt;
      close c_get_ra_line_srvtyp ;

	  --Added for bug#9298508 by JMEENA
		OPEN c_get_ra_tax_amt_applied (p_document_id);
		FETCH c_get_ra_tax_amt_applied INTO p_trx_repo_extract.repository_tax_amt;
		CLOSE c_get_ra_tax_amt_applied;

		OPEN c_get_ra_line_amt_applied (p_document_id);
		FETCH c_get_ra_line_amt_applied INTO p_trx_repo_extract.document_line_amt;
		CLOSE c_get_ra_line_amt_applied;
		--End for bug#9298508 by JMEENA

      if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
      -- if called from Repository Review UI then do not default service type from document
        p_trx_repo_extract.service_type_code := lv_service_type;
      end if;


    end if;
  /* Below code is added to process the STANDALONE INVOICE
  Bug#8943349 by JMEENA
  */
  if p_document_source = 'STANDALONE_INVOICE' THEN

  OPEN c_get_standalone_inv_details;
  FETCH c_get_standalone_inv_details INTO r_ap_details;
  CLOSE c_get_standalone_inv_details;

    p_trx_repo_extract.transaction_source        := 'STANDALONE_INVOICE';
    p_trx_repo_extract.party_name                :=  r_ap_details.party_name              ;
    p_trx_repo_extract.document_number           :=  r_ap_details.document_number         ;
    p_trx_repo_extract.document_date             :=  r_ap_details.document_date           ;
    p_trx_repo_extract.document_id               :=  r_ap_details.document_id             ;
    p_trx_repo_extract.document_line_id          :=  r_ap_details.document_line_id        ;
    p_trx_repo_extract.document_line_num         :=  r_ap_details.document_line_num       ;
    p_trx_repo_extract.document_line_item        :=  r_ap_details.document_line_item      ;
  p_trx_repo_extract.document_line_desc        :=  r_ap_details.document_line_desc      ;
    p_trx_repo_extract.document_line_qty         :=  r_ap_details.document_line_qty       ;
    p_trx_repo_extract.document_line_uom         :=  r_ap_details.document_line_uom       ;
    p_trx_repo_extract.document_line_amt         :=  r_ap_details.document_line_amt       ;
    p_trx_repo_extract.document_currency_code    :=  r_ap_details.document_currency_code  ;
    p_trx_repo_extract.inventory_item_id         :=  r_ap_details.inventory_item_id       ;
    p_trx_repo_extract.party_id                  :=  r_ap_details.party_id                ;

  OPEN c_get_standalone_org_loc;
  FETCH c_get_standalone_org_loc INTO r_standalone_org_loc;
  CLOSE c_get_standalone_org_loc;

    p_trx_repo_extract.organization_id           :=  r_standalone_org_loc.organization_id         ;
  p_trx_repo_extract.location_id               :=  r_standalone_org_loc.location_id             ;

  OPEN c_get_standalone_inv_line_tax (r_ap_details.document_id, r_ap_details.document_line_num);
  FETCH c_get_standalone_inv_line_tax INTO lv_service_type,p_trx_repo_extract.repository_tax_amt;
  CLOSE c_get_standalone_inv_line_tax;

   if nvl(p_called_from,'$#$') not in ('JAINRPRW') then
             p_trx_repo_extract.service_type_code := lv_service_type;
   end if;
  END IF;
  --End of bug#8943349
    /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;
  end get_document_details ;

/*------------------------------------------------------------------------------------------------------------*/
  -- Overloading the GET_DOC_FROM_REFERENCE to return only organization_id, location_id and service_type_code for a given document reference
  procedure get_doc_from_reference
            ( p_reference_id          in          number
            , p_organization_id       out nocopy  number
            , p_location_id           out nocopy  number
            , p_service_type_code     out nocopy  varchar2
            , p_process_flag          out nocopy varchar2
            , p_process_message       out nocopy varchar2
            )
  is
    lr_trx_repo_ext_rec     jai_trx_repo_extract_gt%rowtype;
  begin

    -- Delegate the call to actual procedure that derrived the document details from refernece
    get_doc_from_reference
            ( p_reference_id          =>  p_reference_id
            , p_trx_repo_extract_rec  =>  lr_trx_repo_ext_rec
            , p_process_flag          =>  p_process_flag
            , p_process_message       =>  p_process_message
            );
    if p_process_flag = jai_constants.SUCCESSFUL then
      p_organization_id     := lr_trx_repo_ext_rec.organization_id;
      p_location_id         := lr_trx_repo_ext_rec.location_id;
      p_service_type_code   := lr_trx_repo_ext_rec.service_type_code;
    end if;


  end get_doc_from_reference ;

/*------------------------------------------------------------------------------------------------------------*/
  procedure get_doc_from_reference
            ( p_reference_id          in number
            , p_trx_repo_extract_rec  out nocopy jai_trx_repo_extract_gt%rowtype
            , p_process_flag          out nocopy varchar2
            , p_process_message       out nocopy varchar2
            )
  is

    cursor c_get_refs_rec
    is
      select reference_id
          ,  source
          ,  invoice_id
          ,  item_line_id
    ,  line_id  /*Added by nprashar for bug # 7172723*/
      from  jai_rgm_trx_refs refs
      where  refs.reference_id = p_reference_id;

/*Addition of code by nprashar for bug # 7172723*/
      cursor c_get_source_type
    is
  select source
  from ap_invoices_all aia
  where aia.invoice_id in
  (select invoice_id
   from jai_rgm_Trx_refs refs
   where refs.reference_id = p_reference_id);

   cursor c_get_line_number(p_invoice_id jai_rgm_trx_refs.invoice_id%type,p_line_id jai_rgm_trx_refs.line_id%type)
   is
  select inv_dist_id,
  line_num
  from
  (select
    INVOICE_DISTRIBUTION_ID inv_dist_id,
    row_number() over(ORDER BY INVOICE_DISTRIBUTION_ID) line_num
  from ap_invoice_distributions_all
  where INVOICE_ID=p_invoice_id
  )
  where inv_dist_id=p_line_id;

   lr_line_number number;
   lr_inv_dist_id ap_invoice_distributions_all.INVOICE_DISTRIBUTION_ID%type;

   cursor c_get_doc_details(p_invoice_id jai_rgm_trx_refs.invoice_id%type,p_row_number number)
   is
  SELECT shipment_header_id,
  shipment_line_id,
  receipt_num,
  creation_date,
  qty_received,
  tax_amount,
  organization_id,
  inventory_item_id,
  uom_code,
  location_id,
  vendor_id,
  vendor_site_id
FROM
  (SELECT jrt.shipment_header_id shipment_header_id,
     jrt.shipment_line_id shipment_line_id,
     jrt.receipt_num receipt_num,
     jrt.creation_date creation_date,
     jrt.qty_received qty_received,
     jrtxl.tax_amount tax_amount,
     jrt.organization_id organization_id,
     jrt.inventory_item_id inventory_item_id,
     jirt.uom_code uom_code,
     jirt.location_id location_id,
     jrti.vendor_id vendor_id,
     jrti.vendor_site_id vendor_site_id,
     row_number() over(
   ORDER BY jrtxl.shipment_line_id,jrtxl.tax_line_no) rn
   FROM jai_rcv_lines jrt,
       jai_rcv_transactions jirt,/* modified by vumaasha for bug 8965721 */
     jai_rcv_tp_invoices jrti,
     jai_rcv_line_taxes  jrtxl -- join to ja_in_receipt_tax_lines added by vumaasha for 6856213
   WHERE jrt.shipment_header_id = jrti.shipment_header_id
   AND jrti.invoice_id = p_invoice_id
   AND jrti.shipment_header_id = jirt.shipment_header_id
   AND jirt.transaction_type = 'RECEIVE'
   AND jirt.shipment_line_id = jrt.shipment_line_id
   AND jrtxl.shipment_header_id = jirt.shipment_header_id
   AND jrtxl.shipment_header_id = jrti.shipment_header_id
   AND jirt.shipment_line_id = jrtxl.shipment_line_id)
   WHERE rn =p_row_number ;

cursor c_get_ra_line_srvtyp(p_vendor_id jai_rcv_tp_invoices.VENDOR_ID%type,p_vendor_site_id jai_rcv_tp_invoices.VENDOR_SITE_ID%type)
   is
  select service_type_code
  from
  jai_cmn_vendor_sites
  where vendor_id= p_vendor_id
  and vendor_site_id=p_vendor_site_id;

   lr_service_type       jai_rgm_trx_records.service_type_code%type;
   lr_called_from  varchar2(20)   default  null;

/*Addition Ends for bug 7172723*/

    lr_refs_rec     c_get_refs_rec%rowtype;
    ln_doc_id number;
    ln_doc_line_id number;
    lv_trx_src jai_rgm_trx_records.source%type;
    lr_source_type  ap_invoices_all.source%type;
    lr_doc_details c_get_doc_details%rowtype;

  begin

    /*
    p_trx_repo_extract_rec.service_type_code := '105-E';
    p_trx_repo_extract_rec.organization_id   := 2832   ;
    p_trx_repo_extract_rec.location_id       := 10023  ;
    */
    open  c_get_refs_rec;
    fetch c_get_refs_rec into lr_refs_rec;
    close c_get_refs_rec;

    if lr_refs_rec.reference_id is null then
        p_process_flag    := jai_constants.EXPECTED_ERROR;
        p_process_message := 'Invalid reference id.  Unable to location a repository reference for P_REFERENCE_ID='||p_reference_id;
        return;
    end if;

    if  lr_refs_rec.source is null
    or  lr_refs_rec.invoice_id is null
    or  lr_refs_rec.item_line_id is null
    then
        p_process_flag    := jai_constants.EXPECTED_ERROR;
        p_process_message := 'Unable to find transaction references in the repository.  Source='|| lr_refs_rec.source
                                                                               ||', InvoiceID='|| lr_refs_rec.invoice_id
                                                                               ||', ItemLineID='  ||lr_refs_rec.item_line_id ;
        return;
    end if;

    /* For Bug# 7172723 */
    IF lr_refs_rec.source = 'AP' THEN   --Added by Bgowrava For bug#9385880
    open c_get_source_type;  /* To get the source type */
    fetch c_get_source_type into lr_source_type;
    close c_get_source_type;
    END IF;  --Added by Bgowrava For bug#9385880
    /* if source = Recipt ,for 3rd party invoices */
    if NVL(lr_source_type,'$$$') = 'INDIA TAX INVOICE' THEN  /*Added by nprashar for bug # 7172723*/
          /* open cursor c_get_line_number for invoice_id to fetch the exact delivery location number when multiple receipts lines are there.*/
      lr_line_number :=1;
      open c_get_line_number(lr_refs_rec.invoice_id,lr_refs_rec.line_id);
      fetch c_get_line_number into lr_inv_dist_id,lr_line_number;
      close c_get_line_number;
      /* get information from receipt */

             open c_get_doc_details(lr_refs_rec.invoice_id,lr_line_number);
       fetch c_get_doc_details into lr_doc_details;
       close c_get_doc_details;

        p_trx_repo_extract_rec.transaction_source        :=  'PURCHASING'                         ;
        -- p_trx_repo_extract.party_name                :=  lr_doc_details.party_name              ;
        p_trx_repo_extract_rec.document_number           :=  lr_doc_details.receipt_num         ;
        p_trx_repo_extract_rec.document_date             :=  lr_doc_details.creation_date           ;
        --p_trx_repo_extract.document_id               :=  lr_doc_details.document_id             ;
        --p_trx_repo_extract.document_line_id          :=  lr_doc_details.document_line_id        ;
        -- p_trx_repo_extract.document_line_num         :=  lr_doc_details.document_line_num       ;
        -- p_trx_repo_extract.document_line_item        :=  lr_doc_details.document_line_item      ;
        -- p_trx_repo_extract.document_line_desc        :=  lr_doc_details.document_line_desc      ;
        p_trx_repo_extract_rec.document_line_qty         :=  lr_doc_details.qty_received       ;
        p_trx_repo_extract_rec.document_line_uom         :=  lr_doc_details.uom_code       ;
        p_trx_repo_extract_rec.document_line_amt         :=  lr_doc_details.tax_amount       ;
        -- p_trx_repo_extract.document_currency_code    :=  lr_doc_details.document_currency_code  ;
        p_trx_repo_extract_rec.inventory_item_id         :=  lr_doc_details.inventory_item_id       ;
        p_trx_repo_extract_rec.party_id                  :=  lr_doc_details.vendor_id                ;
        p_trx_repo_extract_rec.organization_id           :=  lr_doc_details.organization_id         ;
        p_trx_repo_extract_rec.location_id               :=  lr_doc_details.location_id             ;

        --get service type from vendor addition information
        open c_get_ra_line_srvtyp(lr_doc_details.vendor_id,lr_doc_details.vendor_site_id);
        fetch c_get_ra_line_srvtyp into lr_service_type;
        close c_get_ra_line_srvtyp;
         -- if no service type for vendor and vendor site then get the service type for vendor null site
         if lr_service_type is null then
    open c_get_ra_line_srvtyp(lr_doc_details.vendor_id,'0');
    fetch c_get_ra_line_srvtyp into lr_service_type;
    close c_get_ra_line_srvtyp;
        end if;
        if nvl(lr_called_from,'$#$') not in ('JAINRPRW') then
        -- if called from Repository Review UI then do not default service type from document
    p_trx_repo_extract_rec.service_type_code := lr_service_type;
        end if;

      p_process_flag := jai_constants.SUCCESSFUL;
ELSE
    jai_trx_repo_extract_pkg.derrive_doc_from_ref
                              ( p_reference_source        =>  lr_refs_rec.source
                              , p_reference_invoice_id    =>  lr_refs_rec.invoice_id
                              , p_reference_item_line_id  =>  lr_refs_rec.item_line_id
                              , p_trx_repo_extract_rec    =>  p_trx_repo_extract_rec
                              , p_process_message         =>  p_process_message
                              , p_process_flag            =>  p_process_flag
                              ) ;
    ln_doc_id := p_trx_repo_extract_rec.document_id;
    ln_doc_line_id := p_trx_repo_extract_rec.document_line_id;
    lv_trx_src := p_trx_repo_extract_rec.transaction_source;


    if p_process_flag <> jai_constants.SUCCESSFUL then
      return;
    end if;
    jai_trx_repo_extract_pkg.get_document_details
                                (  p_document_id       =>  ln_doc_id
                                ,  p_document_line_id  =>  ln_doc_line_id
                                ,  p_document_source   =>  lv_trx_src
                                ,  p_process_message   =>  p_process_message
                                ,  p_process_flag      =>  p_process_flag
                                ,  p_trx_repo_extract  =>  p_trx_repo_extract_rec
                                );
    if p_process_flag <> jai_constants.SUCCESSFUL then
      return;
    end if;

END IF;

end get_doc_from_reference;

/*------------------------------------------------------------------------------------------------------------*/
  procedure update_service_type ( p_process_flag      out nocopy  varchar2
                                , p_process_message   out nocopy  varchar2
                                )
  is

    cursor c_get_recs_to_update
    is
      select *
      from   jai_trx_repo_extract_gt
      where  processed_flag = jai_constants.NO;

    ln_reg_id     number;

  begin

    lv_member_name := 'UPDATE_SERVICE_TYPE';
    set_debug_context;

    /* Initialize the process variables */
    p_process_flag := jai_constants.SUCCESSFUL;

    jai_cmn_debug_contexts_pkg.register (lv_context, ln_reg_id);
    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'Begin loop for C_GET_RECS_TO_UPDATE', jai_cmn_debug_contexts_pkg.summary);
    for rec in c_get_recs_to_update
    loop
      -- For each record in temporary table which is not yet processed
      jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'rec.transaction_source='||rec.transaction_source || fnd_global.local_chr(10) ||
                                        'rec.document_id='||rec.document_id               || fnd_global.local_chr(10) ||
                                        'rec.document_line_id='||rec.document_line_id     || fnd_global.local_chr(10) ||
                                        'rec.service_type_code='||rec.service_type_code
                                       );
      --
      -- Update the transaction tables with the service type code based on source value
      --
      if rec.transaction_source in ('PURCHASING', 'RECEIVING') /*Updated by nprashar for bug # 6841116*/ then

        update JAI_PO_LINE_LOCATIONS        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  po_header_id      = rec.document_id
        and    po_line_id        = rec.document_line_id;

      elsif rec.transaction_source = 'ORDER MANAGEMENT' then

        update JAI_OM_OE_SO_LINES        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  header_id      = rec.document_id
        and    line_id        = rec.document_line_id;

      elsif rec.transaction_source = 'RECEIVABLES' then

        update  JAI_AR_TRX_LINES        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  customer_trx_id        = rec.document_id
        and    customer_trx_line_id   = rec.document_line_id;

      elsif rec.transaction_source = 'MANUAL' then

        update jai_rgm_manual_trxs
        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        where  transaction_number = rec.document_id;

      elsif rec.transaction_source in  ('SERVICE_DISTRIBUTE_OUT') then

        -- Update Source of the distribution
        update jai_rgm_dis_src_hdrs
        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  transfer_id       = rec.document_id;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'No of rows updated in trx table='||sql%rowcount
                                        );

        --
        -- Update service type code for SERVICE_DISTRIBUTE_IN type of trx with the same service type
        -- code as give in the source (SERVICE_DISTRIBUTE_OUT)        --

        update jai_rgm_trx_records
        set    service_type_code  = rec.service_type_code
        ,      last_update_date   = sysdate
        ,      last_updated_by    = lv_user_id
        ,      last_update_login  = lv_login_id
        where  source_document_id = rec.document_id
        and    source = 'SERVICE_DISTRIBUTE_IN';

        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'No of rows updated in repository table for source SERVICE_DISTRIBUTE_IN='||sql%rowcount
                                        );

       -- Begin 5876390, 6012570
      elsif rec.transaction_source = 'PROJECTS' then

        update jai_pa_draft_invoice_lines
        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  draft_invoice_id  = rec.document_id
        and    draft_invoice_line_id = rec.document_line_id;

       -- End bug 5876390, 6012570

      end if;

      -- Bug 5876390, 6012570

      if rec.transaction_source in ('PROJECTS','ORDER MANAGEMENT') then
        -- In case of project and order invoices the invoice also should be updated
        update jai_ar_trx_lines
        set    service_type_code = rec.service_type_code
        ,      last_update_date  = sysdate
        ,      last_updated_by   = lv_user_id
        ,      last_update_login = lv_login_id
        where  customer_trx_id      = rec.repository_invoice_id
        and    customer_trx_line_id = rec.repository_line_id;

        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                         ,'Rows updated in ja_in_ra_customer_trx_lines='||sql%rowcount
                                         );
      end if;

      -- End Bug 5876390, 6012570

      if rec.transaction_source not in  ('SERVICE_DISTRIBUTE_OUT') then
        jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'No of rows updated in trx table='||sql%rowcount
                                        );
      end if;

      --
      -- Update repository records with service type code
      --

      update jai_rgm_trx_records
      set    service_type_code = rec.service_type_code
        ,    last_update_date  = sysdate
        ,    last_updated_by   = lv_user_id
      where  repository_id     = rec.transaction_repository_id;

      jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'No of rows updated in jai_rgm_trx_records table='||sql%rowcount
                                       );
      --
      -- Mark record in global temp table as PROCESSED
      --
      update jai_trx_repo_extract_gt
      set    processed_flag    = 'Y'
      where  transaction_repository_id = rec.transaction_repository_id;

      jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                       ,'No of rows updated in jai_trx_repo_extract_gt table='||sql%rowcount
                                       );

    end loop;
    jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'End loop for C_GET_RECS_TO_UPDATE', jai_cmn_debug_contexts_pkg.summary);

    /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end update_service_type;

  /*------------------------------------------------------------------------------------------------------------*/

  procedure derrive_doc_from_ref
            ( p_reference_source        in          jai_rgm_trx_refs.source%type
            , p_reference_invoice_id    in          jai_rgm_trx_refs.invoice_id%type
            , p_reference_item_line_id  in          jai_rgm_trx_refs.item_line_id%type
            , p_trx_repo_extract_rec    out nocopy  jai_trx_repo_extract_gt%rowtype
            , p_process_message         out nocopy  varchar2
            , p_process_flag            out nocopy  varchar2
            )
  is
    lv_created_from       ra_customer_trx_all.created_from%type ;

    cursor c_chk_ar_inv_attr (cp_customer_trx_id      ra_customer_trx_all.customer_trx_id%type
                             ,cp_customer_trx_line_id ra_customer_trx_lines_all.customer_trx_line_id%type
                             )
    is
      select  rct.created_from
            , rct.interface_header_context
            , rct.interface_header_attribute1   -- holds order number if context is ORDER_ENTRY
            , rctl.interface_line_attribute6  -- holds order line id if context is ORDER_ENTRY
            , rctl.interface_line_attribute1  -- 5876390, 6012570, holds PROJECT_NUMBER if context is PROJECTS INVOICES
            , rctl.interface_line_attribute2  -- 5876390, 6012570, holds DRAFT_INVOICE_NUM if context is PROJECTS_INOVICES
      from   ra_customer_trx_all rct, ra_customer_trx_lines_all rctl
      where  rct.customer_trx_id = cp_customer_trx_id
      and    rct.customer_trx_id = rctl.customer_trx_id
      and    rctl.customer_trx_line_id = cp_customer_trx_line_id;

    lr_inv_attr           c_chk_ar_inv_attr%rowtype;

    cursor c_get_po_reference (cp_invoice_id      ap_invoice_distributions_all.invoice_id%type
                              ,cp_distribution_id ap_invoice_distributions_all.invoice_distribution_id%type
                              )
    is
      select pod.po_header_id
            ,pod.po_line_id
            ,apd.rcv_transaction_id /*Added by vkantamn for Bug#6083978*/
      from  po_distributions_all pod
           ,ap_invoice_distributions_all apd
      where pod.po_distribution_id = apd.po_distribution_id
      and   apd.invoice_id = cp_invoice_id
      and   apd.invoice_distribution_id = cp_distribution_id;

    cursor c_get_loc_from_invoice (cp_customer_trx_id  jai_ar_trxs.customer_trx_id%type)
    is
      select location_id
      from  jai_ar_trxs
      where customer_trx_id = cp_customer_trx_id ;

    -- Begin 5876390, 6012570
    cursor c_get_jai_pa_details  (cp_project_number   pa_projects_all.segment1%type
                                 ,cp_draft_inv_num    jai_pa_draft_invoice_lines.draft_invoice_num%type
                                 ,cp_line_num         jai_pa_draft_invoice_lines.line_num%type
                                 )
    is
      select draft_invoice_id
            ,draft_invoice_line_id
      from   jai_pa_draft_invoice_lines jpdil
            ,pa_projects_all ppa
      where ppa.segment1    = cp_project_number
      and   ppa.project_id  = jpdil.project_id
      and   jpdil.draft_invoice_num = cp_draft_inv_num
      and   jpdil.line_num   = cp_line_num;

    ln_draft_invoice_id         jai_pa_draft_invoice_lines.draft_invoice_id%type;
    ln_draft_invoice_line_id    jai_pa_draft_invoice_lines.draft_invoice_line_id%type;

    -- End 5876390, 6012570

    /* Cursor Added by vkantamn for Bug#6083978 */
    cursor c_rcv_trans(cp_rcv_trans_id number)
    is
      select shipment_header_id,shipment_line_id
      from   rcv_transactions
      where  transaction_id = cp_rcv_trans_id;

    /* Addition done by vkantamn for Bug#6083978 */

    lr_po_reference     c_get_po_reference%rowtype;
    ln_reg_id             number;

  begin

    lv_member_name := 'DERRIVE_DOC_FROM_REF';
    set_debug_context;

    jai_cmn_debug_contexts_pkg.register ( lv_context, ln_reg_id );

    if p_reference_source = 'AR' then

      lv_created_from := null;
      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'OPEN/FETCH/CLOSE  c_chk_ar_inv_attr, p_reference_invoice_id='||p_reference_invoice_id);

      --
      -- Get the invoice attributes to make a decision regarding from where to fetch document details.
      -- If the invoice is an imported one then document is Sales Order other wise AR Invoice details will be fetched
      --
      open  c_chk_ar_inv_attr (cp_customer_trx_id => p_reference_invoice_id
                              , cp_customer_trx_line_id => p_reference_item_line_id
                              );
      fetch c_chk_ar_inv_attr into lr_inv_attr;
      close c_chk_ar_inv_attr;

      jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'lr_inv_attr.created_from='||lr_inv_attr.created_from
                                                ||',lr_inv_attr.interface_header_context='||lr_inv_attr.interface_header_context
                                                ||',lr_inv_attr.interface_header_attribute1(order number)='||lr_inv_attr.interface_header_attribute1
                                                ||',lr_inv_attr.interface_line_attribute6(oe_line_id)='||lr_inv_attr.interface_line_attribute6
                                        ) ;

      if lr_inv_attr.interface_header_context = 'ORDER ENTRY' then  -- Invoice imported from Sales order

        p_trx_repo_extract_rec.transaction_source := 'ORDER MANAGEMENT';
        p_trx_repo_extract_rec.document_id        :=  null;
        p_trx_repo_extract_rec.document_line_id   :=  lr_inv_attr.interface_line_attribute6;


        --
        -- The API get_document_details will not give location in case it is a Sales Order (Refer the API comments for details)
        -- So, derrive it from invoice reference
        --
        open  c_get_loc_from_invoice (cp_customer_trx_id => p_reference_invoice_id);
        fetch c_get_loc_from_invoice into p_trx_repo_extract_rec.location_id;
        close c_get_loc_from_invoice;

      -- Begin 5876390, 6012570
      elsif JAI_AR_RCTLA_TRIGGER_PKG.is_this_projects_context (lr_inv_attr.interface_header_context) then -- Invoice imported from Projects

        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'OPEN/FETCH/CLOSE c_get_jai_pa_details ' ||fnd_global.local_chr(10)
                                                    ||'cp_project_number='||lr_inv_attr.interface_line_attribute1 ||fnd_global.local_chr(10)
                                                    ||'cp_draft_inv_num='||lr_inv_attr.interface_line_attribute2 ||fnd_global.local_chr(10)
                                                    ||'cp_line_num='||lr_inv_attr.interface_line_attribute6 ||fnd_global.local_chr (10)
                                          );
        open  c_get_jai_pa_details ( cp_project_number  => lr_inv_attr.interface_line_attribute1
                                   , cp_draft_inv_num   => lr_inv_attr.interface_line_attribute2
                                   , cp_line_num        => lr_inv_attr.interface_line_attribute6
                                   );
        fetch c_get_jai_pa_details into ln_draft_invoice_id
                                       ,ln_draft_invoice_line_id;
        close c_get_jai_pa_details;


        jai_cmn_debug_contexts_pkg.print (ln_reg_id, 'ln_draft_invoice_id='||ln_draft_invoice_id
                                                   ||'ln_draft_invoice_line_id='||ln_draft_invoice_line_id
                                         );
        p_trx_repo_extract_rec.transaction_source := 'PROJECTS';
        p_trx_repo_extract_rec.document_id        :=  ln_draft_invoice_id;
        p_trx_repo_extract_rec.document_line_id   :=  ln_draft_invoice_line_id;

      --End 5876390, 6012570

      elsif lr_inv_attr.interface_header_context is null  then -- Manual AR Transactions

        p_trx_repo_extract_rec.transaction_source := 'RECEIVABLES';
        p_trx_repo_extract_rec.document_id        :=  p_reference_invoice_id;
        p_trx_repo_extract_rec.document_line_id   :=  p_reference_item_line_id;

      end if; --> lr_inv_attr.created

    elsif p_reference_source = 'AP' then
      jai_cmn_debug_contexts_pkg.print (ln_reg_id
                                          , 'OPEN/FETCH/CLOSE c_get_po_reference'||fnd_global.local_chr(10)
                                          ||'p_reference_invoice_id ='||p_reference_invoice_id
                                          ||'p_reference_item_line_id    ='||p_reference_item_line_id
                                         );

      open  c_get_po_reference (cp_invoice_id      => p_reference_invoice_id
                               ,cp_distribution_id => p_reference_item_line_id
                               );
      fetch c_get_po_reference into lr_po_reference;

      jai_cmn_debug_contexts_pkg.print(ln_reg_id
                                       ,'lr_po_reference.po_header_id =' ||lr_po_reference.po_header_id || fnd_global.local_chr(10)  ||
                                        'lr_po_reference.po_line_id   ='  ||lr_po_reference.po_line_id
                                      );
      if c_get_po_reference%FOUND THEN --If condition added by JMEENA for bug#8943349
        IF lr_po_reference.rcv_transaction_id is NULL THEN /*If Condition added by vkantamn for Bug#6083978 */
          p_trx_repo_extract_rec.transaction_source := 'PURCHASING';
          p_trx_repo_extract_rec.document_id        :=  lr_po_reference.po_header_id;
          p_trx_repo_extract_rec.document_line_id   :=  lr_po_reference.po_line_id;
        /* Else Part added by vkantamn for Bug#6083978 */
        ELSE
          p_trx_repo_extract_rec.transaction_source := 'RECEIVING';
          open c_rcv_trans(lr_po_reference.rcv_transaction_id);
          fetch c_rcv_trans into p_trx_repo_extract_rec.document_id,p_trx_repo_extract_rec.document_line_id;
          close c_rcv_trans;
        END IF;
      ELSE  -- Else part for bug#8943349

        p_trx_repo_extract_rec.transaction_source := 'STANDALONE_INVOICE'  ;
        p_trx_repo_extract_rec.document_id := p_reference_invoice_id;
        p_trx_repo_extract_rec.document_line_id :=p_reference_item_line_id;
        /* Addition done by vkantamn for Bug#6083978 */
      END IF;
      close c_get_po_reference; --moved this code here for bug#9192752
    end if;    -- End if of bug#8943349

    /** Deregister procedure and return*/
    <<deregister_and_return>>
    jai_cmn_debug_contexts_pkg.deregister (pn_reg_id => ln_reg_id);

  exception
    when others then
      p_process_flag    := jai_constants.unexpected_error;
      p_process_message := lv_context||'->'||sqlerrm;
      jai_cmn_debug_contexts_pkg.print(ln_reg_id,lv_context||'->'||sqlerrm,jai_cmn_debug_contexts_pkg.summary);
      jai_cmn_debug_contexts_pkg.print_stack;

  end derrive_doc_from_ref;

/*------------------------------------------------------------------------------------------------------------*/
  --
  -- A wraper function on top of the procedure get_doc_from_reference to return only service type code
  -- This functions are used by Serivce Tax reports for printing service type code
  --
  function get_service_type_from_ref (p_reference_id      in          jai_rgm_trx_refs.reference_id%type
                                     )

  return varchar2
  is
    lv_organization_id    number;
    lv_location_id        number;
    lv_service_type_code  jai_rgm_trx_records.service_type_code%type;
    lv_process_flag       varchar2 (2);
    lv_process_message    varchar2 (2000);

  begin
    jai_trx_repo_extract_pkg.get_doc_from_reference
    ( p_reference_id        =>  p_reference_id
    , p_organization_id     =>  lv_organization_id
    , p_location_id         =>  lv_location_id
    , p_service_type_code   =>  lv_service_type_code
    , p_process_flag        =>  lv_process_flag
    , p_process_message     =>  lv_process_message
    );
    if lv_process_flag = jai_constants.SUCCESSFUL then
      return lv_service_type_code;
    else
      return null;
    end if;
  end get_service_type_from_ref;
/*------------------------------------------------------------------------------------------------------------*/

  function get_settled_service_type
            ( p_transaction_source jai_trx_repo_extract_gt.transaction_source%type
            , p_document_id        jai_trx_repo_extract_gt.document_id%type
            , p_document_line_id   jai_trx_repo_extract_gt.document_line_id%type
            )
  return varchar2 is

    lv_service_type jai_rgm_trx_records.service_type_code%type;

    cursor c_get_so_settled_srvtyp
    is
      select recs.service_type_code
      from   jai_rgm_trx_records recs
            ,jai_rgm_trx_refs    refs
            ,ra_customer_trx_lines_all ractl
      where ractl.interface_line_attribute6 = p_document_line_id
      and   ractl.interface_line_context    = 'ORDER ENTRY'
      and   ractl.line_type                 = 'LINE'
      and   ractl.customer_trx_line_id      = refs.item_line_id
      and   refs.reference_id               = recs.reference_id
      and   recs.settlement_id is not null
      and   recs.service_type_code is not null
      and   recs.regime_code = 'SERVICE'
      and   recs.source = 'AR';

    cursor c_get_ar_settled_srvtyp
    is
      select recs.service_type_code
      from   jai_rgm_trx_records recs
            ,jai_rgm_trx_refs    refs
      where  refs.item_line_id = p_document_line_id
      and    recs.reference_id = refs.reference_id
      and    recs.settlement_id is not null
      and    recs.service_type_code is not null
      and    recs.regime_code = 'SERVICE'
      and    recs.source = 'AR';

    cursor c_get_po_settled_srvtyp
    is
      select recs.service_type_code
      from   jai_rgm_trx_records recs
            ,jai_rgm_trx_refs    refs
            ,po_distributions_all pod
            ,ap_invoice_distributions_all apd
      where pod.po_line_id = p_document_line_id
      and   pod.po_distribution_id = apd.po_distribution_id
      and   apd.invoice_distribution_id = refs.item_line_id
      and   recs.reference_id  = refs.reference_id
      and   recs.settlement_id is not null
      and   recs.service_type_code is not null
      and   recs.regime_code = 'SERVICE'
      and   recs.source = 'AP';

  begin

    if p_transaction_source = 'ORDER MANAGEMENT' then

      open  c_get_so_settled_srvtyp;
      fetch c_get_so_settled_srvtyp into lv_service_type;
      close c_get_so_settled_srvtyp ;

    elsif p_transaction_source = 'RECEIVABLES' then

      open  c_get_ar_settled_srvtyp;
      fetch c_get_ar_settled_srvtyp into lv_service_type;
      close c_get_ar_settled_srvtyp ;

    elsif p_transaction_source = 'PURCHASING' then

      open  c_get_po_settled_srvtyp;
      fetch c_get_po_settled_srvtyp into lv_service_type;
      close c_get_po_settled_srvtyp ;

    end if;

    return lv_service_type;

  end get_settled_service_type;



end jai_trx_repo_extract_pkg;

/

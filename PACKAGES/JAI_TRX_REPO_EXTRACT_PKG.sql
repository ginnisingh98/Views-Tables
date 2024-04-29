--------------------------------------------------------
--  DDL for Package JAI_TRX_REPO_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_TRX_REPO_EXTRACT_PKG" AUTHID CURRENT_USER as
/*$Header: jai_trx_repo_ext.pls 120.1.12000000.1 2007/07/24 06:56:20 rallamse noship $ */
/*------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY
  ------------------------------------------------------------------------------------------------------------
  Sl.No.          Date          Developer   BugNo       Version        Remarks
  ------------------------------------------------------------------------------------------------------------
  1.              22-Dec-2005   brathod     5694855     115.1          Created the initial version

--------------------------------------------------------------------------------------------------------------*/

  procedure get_document_details
              (  p_document_id       in          number
              ,  p_document_line_id  in          number
              ,  p_document_source   in          varchar2
              ,  p_called_from       in          varchar2   default  null
              ,  p_process_message   out nocopy  varchar2
              ,  p_process_flag      out nocopy  varchar2
              ,  p_trx_repo_extract  in out nocopy  jai_trx_repo_extract_gt%rowtype
              );
  procedure extract_rgm_trxs
             ( p_regime_code     jai_rgm_trx_records.regime_code%type
             , p_organization_id jai_rgm_trx_records.organization_id%type default null
             , p_location_id     jai_rgm_trx_records.location_id%type default null
             , p_from_trx_date   date default null
             , p_to_trx_date     date default null
             , p_source          jai_rgm_trx_records.source%type default null
             , p_query_settled_flag   varchar2 default 'N'
             , p_query_only_null_srvtype varchar2 default 'N'
             , p_process_message  out nocopy varchar
             , p_process_flag     out nocopy varchar2
             );

  procedure get_doc_from_reference
            ( p_reference_id          in number
            , p_trx_repo_extract_rec  out nocopy jai_trx_repo_extract_gt%rowtype
            , p_process_flag          out nocopy varchar2
            , p_process_message       out nocopy varchar2
            );

  procedure get_doc_from_reference
            ( p_reference_id          in          number
            , p_organization_id       out nocopy  number
            , p_location_id           out nocopy  number
            , p_service_type_code     out nocopy  varchar2
            , p_process_flag          out nocopy varchar2
            , p_process_message       out nocopy varchar2
            );

  procedure update_service_type
            ( p_process_flag      out nocopy  varchar2
            , p_process_message   out nocopy  varchar2
            );

  procedure derrive_doc_from_ref
            ( p_reference_source        in          jai_rgm_trx_refs.source%type
            , p_reference_invoice_id    in          jai_rgm_trx_refs.invoice_id%type
            , p_reference_item_line_id  in          jai_rgm_trx_refs.item_line_id%type
            , p_trx_repo_extract_rec    out nocopy  jai_trx_repo_extract_gt%rowtype
            , p_process_message         out nocopy  varchar2
            , p_process_flag            out nocopy  varchar2
            );
  function get_service_type_from_ref (p_reference_id      in          jai_rgm_trx_refs.reference_id%type
                                     )
   return varchar2;


end jai_trx_repo_extract_pkg;
 

/

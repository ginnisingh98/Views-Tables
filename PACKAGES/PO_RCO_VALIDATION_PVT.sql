--------------------------------------------------------
--  DDL for Package PO_RCO_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RCO_VALIDATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRCVS.pls 120.2.12010000.9 2013/05/22 09:28:26 bpulivar ship $*/

  g_pkg_name  CONSTANT    VARCHAR2(30) := 'PO_RCO_VALIDATION_PVT';
  g_file_name CONSTANT    VARCHAR2(30) := 'POXVRCVS.pls';

  TYPE change_rec_type IS RECORD(action_type					po_change_requests.action_type%TYPE,
                                 initiator						po_change_requests.initiator%TYPE,
                                 request_reason 				po_change_requests.request_reason%TYPE,
                                 document_type					po_change_requests.document_type%TYPE,
                                 request_level					po_change_requests.request_level%TYPE,
                                 request_status 				po_change_requests.request_status%TYPE,
                                 document_header_id				po_change_requests.document_header_id%TYPE,
                                 po_release_id					po_change_requests.po_release_id%TYPE,
                                 document_num					po_change_requests.document_num%TYPE,
                                 document_revision_num			po_change_requests.document_revision_num%TYPE,
                                 document_line_id				po_change_requests.document_line_id%TYPE,
                                 document_line_number			po_change_requests.document_line_number%TYPE,
                                 document_line_location_id		po_change_requests.document_line_location_id%TYPE,
                                 document_shipment_number		po_change_requests.document_shipment_number%TYPE,
                                 document_distribution_id		po_change_requests.document_distribution_id%TYPE,
                                 document_distribution_number	po_change_requests.document_distribution_number%TYPE,
                                 parent_line_location_id		po_change_requests.parent_line_location_id%TYPE,
                                 old_quantity				  	po_change_requests.old_quantity%TYPE,
                                 new_quantity				  	po_change_requests.new_quantity%TYPE,
                                 old_date			  			po_change_requests.old_need_by_date%TYPE,
                                 new_date			  			po_change_requests.new_need_by_date%TYPE,
                                 old_supplier_part_number		po_change_requests.old_supplier_part_number%TYPE,
                                 new_supplier_part_number		po_change_requests.new_supplier_part_number%TYPE,
                                 old_price						po_change_requests.old_price%TYPE,
                                 new_price						po_change_requests.new_price%TYPE,
                                 old_supplier_reference_number	po_change_requests.old_supplier_reference_number%TYPE,
                                 new_supplier_reference_number	po_change_requests.new_supplier_reference_number%TYPE,
                                 from_header_id 				NUMBER,
                                 old_currency_unit_price 		po_change_requests.old_currency_unit_price%TYPE,
                                 new_currency_unit_price 		po_change_requests.new_currency_unit_price%TYPE,
                                 recoverable_tax			  	po_change_requests.recoverable_tax%TYPE,
                                 non_recoverable_tax			po_change_requests.nonrecoverable_tax%TYPE,
                                 requester_id					po_change_requests.requester_id%TYPE,
                                 referenced_po_header_id		NUMBER,
                                 referenced_po_document_num		po_change_requests.ref_po_num%TYPE,
                                 referenced_release_id			NUMBER,
                                 referenced_release_num			NUMBER,
                                 old_start_date 			DATE,
                                 new_start_date 			DATE,
                                 old_end_date 				DATE,
                                 new_end_date 				DATE,
                                 old_budget_amount 			NUMBER,
                                 new_budget_amount 			NUMBER,
                                 old_currency_budget_amount		NUMBER,
                                 new_currency_budget_amount 		NUMBER,
                                 line_type  				VARCHAR2(60),
                                 dirty_flag VARCHAR2(1) DEFAULT 'N');

  TYPE change_tbl_type IS TABLE OF change_rec_type INDEX BY BINARY_INTEGER;

  TYPE error_rec_type IS RECORD(line_id NUMBER,
                                dist_id NUMBER,
                                err_count NUMBER,
                                err_msg VARCHAR2(2000));


  TYPE error_tbl_type IS TABLE OF error_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE calculate_disttax(p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_dist_id NUMBER,
                              p_price NUMBER,
                              p_quantity NUMBER,
                              p_dist_amount NUMBER,
                              p_rec_tax OUT NOCOPY NUMBER,
                              p_nonrec_tax OUT NOCOPY NUMBER);


  PROCEDURE is_req_line_changeable(p_api_version IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   p_req_line_id IN NUMBER,
                                   p_price_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_qty_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_start_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_end_date_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_amount_changeable_flag OUT NOCOPY VARCHAR2,
                                   p_cancellable_flag OUT NOCOPY VARCHAR2);

  PROCEDURE is_req_line_cancellable(p_api_version IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    p_req_line_id IN NUMBER,
                                    p_origin IN VARCHAR2);

  PROCEDURE save_ireqchange(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_change_table IN po_req_change_table,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            x_retmsg OUT NOCOPY VARCHAR2,
                            x_errtable OUT NOCOPY po_req_change_err_table);

  PROCEDURE save_ireqcancel(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            l_progress OUT NOCOPY VARCHAR2,
                            p_grp_id IN NUMBER);


  PROCEDURE save_reqchange(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_change_table IN po_req_change_table,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           x_errtable OUT NOCOPY po_req_change_err_table);

  PROCEDURE save_reqcancel(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           p_grp_id IN NUMBER);

  PROCEDURE submit_ireqchange (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               p_fundscheck_flag IN VARCHAR2,
                               p_note_to_approver IN VARCHAR2,
                               p_initiator IN VARCHAR2,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               x_errcode OUT NOCOPY VARCHAR2,
                               x_errtable OUT NOCOPY po_req_change_err_table);

  PROCEDURE submit_reqchange (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              p_fundscheck_flag IN VARCHAR2,
                              p_note_to_approver IN VARCHAR2,
                              p_initiator IN VARCHAR2,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              x_errcode OUT NOCOPY VARCHAR2,
                              x_errtable OUT NOCOPY po_req_change_err_table);

  PROCEDURE submit_ireqcancel (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               p_errtable OUT NOCOPY po_req_change_err_table,
                               p_origin IN VARCHAR2);

  PROCEDURE submit_reqcancel (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              p_errtable OUT NOCOPY po_req_change_err_table,
                              p_origin IN VARCHAR2);

  PROCEDURE is_internal_line_cancellable(p_api_version IN NUMBER,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         p_req_line_id IN NUMBER);


  PROCEDURE is_on_complex_work_order(p_line_loc_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_preparer_name(
                              p_req_hdr_id                  IN             NUMBER
                              ,  x_preparer_name                OUT NOCOPY    VARCHAR2
                              ,  x_return_status     OUT       NOCOPY VARCHAR2

                              );

 /* PROCEDURE update_reqcancel_from_so(
                                     p_req_hdr_id                  IN            NUMBER
                                     ,  p_req_line_id                  IN            NUMBER
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     ) ;*/

  PROCEDURE update_reqcancel_from_so(p_req_line_id       IN            NUMBER
															      , p_req_cancel_qty   IN            NUMBER
                                    , p_req_cancel_all   IN            BOOLEAN
                                    ,x_return_status     OUT       NOCOPY VARCHAR2 );

  PROCEDURE update_reqchange_from_so(
                                     p_req_line_id                  IN           NUMBER
                                     ,  p_delta_quantity               IN           NUMBER
                                     ,  p_new_need_by_date             IN           DATE
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     );

  PROCEDURE is_internal_line_changeable(p_api_version IN NUMBER
                                     ,  X_Update_Allowed OUT NOCOPY VARCHAR2
                                     ,  X_Cancel_Allowed OUT NOCOPY VARCHAR2
                                     ,  x_return_status OUT NOCOPY VARCHAR2
                                     ,   p_req_line_id IN NUMBER);

  procedure validate_internal_req_changes(
                                  p_req_line_id    IN NUMBER
                                , p_req_header_id  IN NUMBER
                                , p_need_by_date        IN  DATE DEFAULT NULL
                                , p_old_quantity       IN  NUMBER DEFAULT 0
                                , p_new_quantity       IN  NUMBER DEFAULT 0
                                ,  X_return_status           OUT NOCOPY VARCHAR2
                                );

PROCEDURE is_SO_line_cancellable(p_api_version IN NUMBER,
                                         x_return_status OUT NOCOPY VARCHAR2,
                                         p_req_line_id IN NUMBER,
                                         p_req_header_id IN NUMBER,
                                         x_cancellable OUT NOCOPY VARCHAR2 );

-- 14227140 changes starts
/**
* Procedure to update the cancel qty in req line from SO
* This method is called when a SO initiated partial
* cancellation of Qty (Primary or Secondary) or cancellation of line.
*

* @param p_req_line_id number canceled req line
* @param p_req_can_prim_qty number canceled Prim Qty of req line
* @param p_req_can_sec_qty number canceled Secondary Qty of req line
* @param p_req_can_all boolean to hole weather req line cancelation flag
* @param x_return_status returns the tstatus of the api.
*/
 PROCEDURE update_reqcancel_from_so(  p_req_line_id       IN           NUMBER
                                    , p_req_cancel_prim_qty   IN            NUMBER
                                    , p_req_cancel_sec_qty   IN        NUMBER
                                    , p_req_cancel_all   IN            BOOLEAN
                                    ,x_return_status     OUT       NOCOPY VARCHAR2 );

/**
* Procedure to update the Qty changes on req line from SO changes
* This method is called when a SO initiated change in Qty (Primary or Secondary).
*
* @param p_req_line_id number holds the req line number
* @param p_delta_quantity_prim number changed Prim Qty of SO
* @param p_delta_quantity_sec number changed Secondary Qty of SO
* @param p_new_need_by_date date need by date of SO.
* @param x_return_status returns the tstatus of the api
*/

 PROCEDURE update_reqchange_from_so(
                                        p_req_line_id                  IN           NUMBER
                                     ,  p_delta_quantity_prim          IN           NUMBER
                                     ,  p_delta_quantity_sec           IN           NUMBER
                                     ,  p_new_need_by_date             IN           DATE
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     );

-- 14227140 changes ends

-- 7669581 changes starts
/**
* Procedure to clear the change request attachments added at line level
* before inistiating the change request
* (To clear the attachments that are left unprocessed in change request flow).
*
* @param p_req_hdr_id number holds the req header id
* @param x_return_status returns the tstatus of the api
*/
 PROCEDURE del_req_line_chng_attachments(p_req_hdr_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);
-- 7669581 changes ends

-- 16839471  changes starts
/**
* Procedure to clear the change request attachments added at line level
*
* @param p_req_line_id number holds the req line id
* @param x_return_status returns the tstatus of the api
*/
 PROCEDURE del_chng_req_line_attachments(p_req_line_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);
-- 16839471 changes ends

END po_rco_validation_pvt;

/

--------------------------------------------------------
--  DDL for Package PO_RCO_VALIDATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RCO_VALIDATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGRCVS.pls 120.2.12010000.9 2012/08/24 09:52:18 bpulivar ship $*/

  FUNCTION is_req_cancellable(p_req_hdr_id IN NUMBER) RETURN VARCHAR2;

 function IS_ANY_LINE_WITHDRAWABLE(p_req_hdr_id in number) return varchar2;

  FUNCTION is_req_changeable(p_req_hdr_id IN NUMBER) RETURN VARCHAR2;

  FUNCTION is_reqline_cancellable(p_req_line_id IN NUMBER) RETURN VARCHAR2;

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
                                   p_price_flag OUT NOCOPY VARCHAR2,
                                   p_date_flag OUT NOCOPY VARCHAR2,
                                   p_qty_flag OUT NOCOPY VARCHAR2,
                                   p_start_date_flag OUT NOCOPY VARCHAR2,
                                   p_end_date_flag OUT NOCOPY VARCHAR2,
                                   p_amount_flag OUT NOCOPY VARCHAR2,
                                   p_cancel_flag OUT NOCOPY VARCHAR2);

  PROCEDURE is_req_line_cancellable(p_api_version IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    p_req_line_id IN NUMBER,
                                    p_flag IN VARCHAR2 DEFAULT NULL);

  PROCEDURE save_reqchange(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_change_table IN po_req_change_table,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           x_errtable OUT NOCOPY po_req_change_err_table);

  PROCEDURE save_ireqchange(p_api_version IN NUMBER,
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
                           p_grp_id IN NUMBER DEFAULT NULL);

  PROCEDURE submit_reqchange (p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              p_fundscheck_flag IN VARCHAR2,
                              p_note_to_approver IN VARCHAR2,
                              p_initiator IN VARCHAR2,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              x_errcode OUT NOCOPY VARCHAR2,
                              x_errtable OUT NOCOPY po_req_change_err_table );

  PROCEDURE submit_reqcancel (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              p_errtable OUT NOCOPY po_req_change_err_table,
                              p_flag IN VARCHAR2 DEFAULT NULL);


  PROCEDURE save_ireqcancel(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            x_retmsg OUT NOCOPY VARCHAR2,
                            p_grp_id IN NUMBER DEFAULT NULL);

  PROCEDURE submit_ireqchange (p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               p_fundscheck_flag IN VARCHAR2,
                               p_note_to_approver IN VARCHAR2,
                               p_initiator IN VARCHAR2,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               x_errcode OUT NOCOPY VARCHAR2,
                               x_errtable OUT NOCOPY po_req_change_err_table );

  PROCEDURE submit_ireqcancel (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               p_errtable OUT NOCOPY po_req_change_err_table,
                               p_flag IN VARCHAR2 DEFAULT NULL);


  PROCEDURE is_on_complex_work_order(p_line_loc_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2);



  PROCEDURE get_preparer_name(
                              p_api_version                 IN             NUMBER
                              ,  p_req_hdr_id                  IN             NUMBER
                              ,  x_return_status               OUT NOCOPY     VARCHAR2
                              ,  x_preparer_name               OUT NOCOPY    VARCHAR2
                              );


PROCEDURE update_reqcancel_from_so(
                                      p_api_version                 IN             NUMBER
                                     , p_req_line_id_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_qty_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_all                IN             Boolean
  			             ,  x_return_status             OUT NOCOPY     VARCHAR2
	                                       );

 PROCEDURE update_reqcancel_from_so(
 	                                       p_api_version                 IN             NUMBER
 	                                      ,  x_return_status             OUT NOCOPY     VARCHAR2
 	                                      ,  p_req_line_id_tbl           IN            Dbms_Sql.number_table    --this needs to be table of number
 	                                      );

  PROCEDURE update_reqchange_from_so(
                                     p_api_version                 IN             NUMBER
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     ,  p_req_line_id                  IN             NUMBER
                                     ,  p_delta_quantity               IN             NUMBER
                                     ,  p_new_need_by_date             IN             DATE
                                     );

-- 14227140 changes starts
/**
* Procedure to update the cancel qty in req line from SO
* This method is called when a SO initiated partial
* cancellation of Qty (Primary or Secondary) or cancellation of line.
*
* @param p_api_version of the procedure api
* @param p_req_line_id_tbl number table of canceled req lines
* @param p_req_can_prim_qty_tbl number table of canceled Prim Qty of req lines
* @param p_req_can_sec_qty_tbl number table of canceled Secondary Qty of req lines
* @param p_req_can_all boolean to hole weather req line cancelation flag
 * @param x_return_status returns the tstatus of the api.
*/
PROCEDURE update_reqcancel_from_so(
                                      p_api_version                 IN             NUMBER
                                     , p_req_line_id_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_prim_qty_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_sec_qty_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_all                IN             Boolean
                                     ,  x_return_status             OUT NOCOPY     VARCHAR2
                                     );


/**
* Procedure to update the Qty changes on req line from SO changes
* This method is called when a SO initiated change in Qty (Primary or Secondary).
*
* @param p_api_version of the procedure api
* @param x_return_status returns the tstatus of the api.
* @param p_req_line_id number holds the req line number
* @param p_delta_quantity_prim number changed Prim Qty of SO
* @param p_delta_quantity_sec number changed Secondary Qty of SO
* @param p_new_need_by_date date need by date of SO.
*/
PROCEDURE update_reqchange_from_so(
                                     p_api_version                 IN             NUMBER
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     ,  p_req_line_id                  IN             NUMBER
                                     ,  p_delta_quantity_prim          IN             NUMBER
                                     ,  p_delta_quantity_sec          IN             NUMBER
                                     ,  p_new_need_by_date             IN             DATE
                                     );

-- 14227140 changes ends


END po_rco_validation_grp;

/

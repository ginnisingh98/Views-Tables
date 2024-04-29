--------------------------------------------------------
--  DDL for Package Body PO_RCO_VALIDATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCO_VALIDATION_GRP" AS
/* $Header: POXGRCVB.pls 120.7.12010000.9 2012/08/24 09:54:10 bpulivar ship $ */

  g_pkg_name  CONSTANT     VARCHAR2(30) := 'PO_RCO_VALIDATION_GRP';
-- Read the profile option that enables/disables the debug log
-- Logging global constants
  d_package_base CONSTANT VARCHAR2(100) := po_log.get_package_base(g_pkg_name);

  c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Debugging
  g_debug_stmt CONSTANT BOOLEAN := po_debug.is_debug_stmt_on;
  g_debug_unexp CONSTANT BOOLEAN := po_debug.is_debug_unexp_on;

  FUNCTION is_req_cancellable(p_req_hdr_id IN NUMBER) RETURN VARCHAR2
  IS
  CURSOR l_line_csr(hdr_id NUMBER) IS
  SELECT requisition_line_id,
         line_location_id
    FROM po_requisition_lines_all
   WHERE requisition_header_id = hdr_id;

  l_line_id NUMBER;
  l_line_location_id NUMBER;
  l_line_with_po NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_c VARCHAR2(1);
  l_api_name VARCHAR2(50) := 'Is_Req_Cancellable';
  l_oe_flag VARCHAR2(1);

  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';



  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id', p_req_hdr_id);
    END IF;


    OPEN l_line_csr(p_req_hdr_id);
    LOOP
      FETCH l_line_csr
      INTO l_line_id,
      l_line_location_id;

      EXIT WHEN l_line_csr%notfound;

      IF (l_line_location_id IS NOT NULL) THEN
        l_line_with_po := l_line_with_po + 1;
      END IF; --Bug6747949
      l_c := is_reqline_cancellable(l_line_id);

      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress, 'l_line_id', l_line_id);
        po_debug.debug_var(l_log_head, l_progress, 'Is_ReqLine_Cancellable', l_c);
      END IF;

      IF(l_c = 'Y') THEN
        RETURN 'Y';
      END IF;
    END LOOP;
    CLOSE l_line_csr;

      IF g_debug_stmt THEN
        po_debug.debug_var(l_log_head, l_progress, 'returning  not cancellable', l_line_with_po);
      END IF;

          return 'N';

  EXCEPTION WHEN OTHERS THEN
    IF g_debug_stmt THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
      END IF;
    END IF;

    RETURN 'N';
  END is_req_cancellable;

  FUNCTION is_req_changeable(p_req_hdr_id IN NUMBER) RETURN VARCHAR2
  IS

  CURSOR l_line_csr(hdr_id NUMBER) IS
  SELECT requisition_line_id,
         line_location_id
    FROM po_requisition_lines_all
   WHERE requisition_header_id = hdr_id;

  l_line_id NUMBER;
  l_line_location_id NUMBER;
  l_line_with_po NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_p VARCHAR2(1);
  l_d VARCHAR2(1);
  l_q VARCHAR2(1);
  l_start_date VARCHAR2(1);
  l_end_date VARCHAR2(1);
  l_amount VARCHAR2(1);
  l_c VARCHAR2(1);
  l_api_name VARCHAR2(50) := 'Is_Req_Changeable';

  BEGIN

    OPEN l_line_csr(p_req_hdr_id);
    LOOP
      FETCH l_line_csr
      INTO l_line_id,
      l_line_location_id;
      EXIT WHEN l_line_csr%notfound;

      IF (l_line_location_id IS NOT NULL) THEN
        l_line_with_po := l_line_with_po + 1;

        is_req_line_changeable(
                               1.0,
                               l_return_status,
                               l_line_id,
                               l_p,
                               l_d,
                               l_q,
                               l_start_date,
                               l_end_date,
                               l_amount,
                               l_c);

        IF(l_p = 'Y' OR l_d = 'Y' OR l_q = 'Y' OR l_c = 'Y' OR
           l_start_date = 'Y' OR l_end_date = 'Y' OR l_amount = 'Y') THEN
          RETURN 'Y';
        END IF;
      END IF;
    END LOOP;
    CLOSE l_line_csr;

     -- if no line has po associated, the req is changeable
    IF (l_line_with_po = 0) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  EXCEPTION WHEN OTHERS THEN
    IF g_debug_stmt THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
      END IF;

    END IF;

    RETURN 'N';
  END is_req_changeable;

  FUNCTION is_reqline_cancellable(p_req_line_id IN NUMBER) RETURN VARCHAR2
  IS
  l_return_status VARCHAR2(1);
  BEGIN
    po_rco_validation_pvt.is_req_line_cancellable(
                                                  1.0,
                                                  l_return_status,
                                                  p_req_line_id,
                                                  NULL);
    IF(l_return_status = fnd_api.g_ret_sts_success) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END is_reqline_cancellable;


  PROCEDURE calculate_disttax(p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_dist_id NUMBER,
                              p_price NUMBER,
                              p_quantity NUMBER,
                              p_dist_amount NUMBER,
                              p_rec_tax OUT NOCOPY NUMBER,
                              p_nonrec_tax OUT NOCOPY NUMBER)
  IS
  BEGIN
    po_rco_validation_pvt.calculate_disttax(
                                            p_api_version,
                                            x_return_status,
                                            p_dist_id,
                                            p_price,
                                            p_quantity,
                                            p_dist_amount,
                                            p_rec_tax,
                                            p_nonrec_tax);
  END calculate_disttax;


  PROCEDURE is_req_line_cancellable(p_api_version IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2,
                                    p_req_line_id IN NUMBER,
                                    p_flag IN VARCHAR2 DEFAULT NULL)
  IS

  BEGIN
    po_rco_validation_pvt.is_req_line_cancellable(
                                                  p_api_version,
                                                  x_return_status,
                                                  p_req_line_id,
                                                  p_flag);


  END is_req_line_cancellable;

  PROCEDURE is_req_line_changeable(p_api_version IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   p_req_line_id IN NUMBER,
                                   p_price_flag OUT NOCOPY VARCHAR2,
                                   p_date_flag OUT NOCOPY VARCHAR2,
                                   p_qty_flag OUT NOCOPY VARCHAR2,
                                   p_start_date_flag OUT NOCOPY VARCHAR2,
                                   p_end_date_flag OUT NOCOPY VARCHAR2,
                                   p_amount_flag OUT NOCOPY VARCHAR2,
                                   p_cancel_flag OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    po_rco_validation_pvt.is_req_line_changeable(
                                                 p_api_version,
                                                 x_return_status,
                                                 p_req_line_id,
                                                 p_price_flag,
                                                 p_date_flag,
                                                 p_qty_flag,
                                                 p_start_date_flag,
                                                 p_end_date_flag,
                                                 p_amount_flag,
                                                 p_cancel_flag);

  END is_req_line_changeable;

  PROCEDURE save_ireqchange(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_change_table IN po_req_change_table,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            x_retmsg OUT NOCOPY VARCHAR2,
                            x_errtable OUT NOCOPY po_req_change_err_table)
  IS


  l_api_name     CONSTANT VARCHAR(30) := 'Save_IReqChange';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';


  BEGIN


    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id', p_req_hdr_id);
    END IF;

    po_rco_validation_pvt.save_ireqchange(
                                          p_api_version,
                                          x_return_status,
                                          p_req_hdr_id,
                                          p_change_table,
                                          p_cancel_table,
                                          p_change_request_group_id,
                                          x_retmsg,
                                          x_errtable);




    IF g_debug_stmt THEN   po_debug.debug_end(l_log_head); END IF;

  END save_ireqchange;

  PROCEDURE save_reqchange(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_change_table IN po_req_change_table,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           x_errtable OUT NOCOPY po_req_change_err_table)
  IS
  BEGIN
    po_rco_validation_pvt.save_reqchange(
                                         p_api_version,
                                         x_return_status,
                                         p_req_hdr_id,
                                         p_change_table,
                                         p_cancel_table,
                                         p_change_request_group_id,
                                         x_retmsg,
                                         x_errtable);
  END save_reqchange;

  PROCEDURE save_reqcancel(p_api_version IN NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           p_req_hdr_id IN NUMBER,
                           p_cancel_table IN po_req_cancel_table,
                           p_change_request_group_id OUT NOCOPY NUMBER,
                           x_retmsg OUT NOCOPY VARCHAR2,
                           p_grp_id IN NUMBER DEFAULT NULL)
  IS
  BEGIN
    po_rco_validation_pvt.save_reqcancel(
                                         p_api_version,
                                         x_return_status,
                                         p_req_hdr_id,
                                         p_cancel_table,
                                         p_change_request_group_id,
                                         x_retmsg,
                                         p_grp_id);
  END save_reqcancel;


  PROCEDURE submit_reqchange(p_api_version IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             p_group_id IN NUMBER,
                             p_fundscheck_flag IN VARCHAR2,
                             p_note_to_approver IN VARCHAR2,
                             p_initiator IN VARCHAR2,
                             x_retmsg OUT NOCOPY VARCHAR2,
                             x_errcode OUT NOCOPY VARCHAR2,
                             x_errtable OUT NOCOPY po_req_change_err_table )
  IS
  BEGIN
    po_rco_validation_pvt.submit_reqchange(p_api_version,
                                           x_return_status,
                                           p_group_id,
                                           p_fundscheck_flag,
                                           p_note_to_approver,
                                           p_initiator,
                                           x_retmsg,
                                           x_errcode,
                                           x_errtable );
  END submit_reqchange;

  PROCEDURE submit_reqcancel (
                              p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              p_errtable OUT NOCOPY po_req_change_err_table,
                              p_flag IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    po_rco_validation_pvt.submit_reqcancel (
                                            p_api_version ,
                                            x_return_status ,
                                            p_group_id ,
                                            x_retmsg ,
                                            p_errtable ,
                                            p_flag );
  END submit_reqcancel;



  PROCEDURE save_ireqcancel(p_api_version IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2,
                            p_req_hdr_id IN NUMBER,
                            p_cancel_table IN po_req_cancel_table,
                            p_change_request_group_id OUT NOCOPY NUMBER,
                            x_retmsg OUT NOCOPY VARCHAR2,
                            p_grp_id IN NUMBER DEFAULT NULL)
  IS

  l_api_name     CONSTANT VARCHAR(30) := 'Save_IReqCancel';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id', p_req_hdr_id);
    END IF;


    po_rco_validation_pvt.save_ireqcancel(
                                          p_api_version,
                                          x_return_status,
                                          p_req_hdr_id,
                                          p_cancel_table,
                                          p_change_request_group_id,
                                          x_retmsg,
                                          p_grp_id);
    IF g_debug_stmt THEN
      po_debug.debug_end(l_log_head);
    END IF;

  END save_ireqcancel;


  PROCEDURE submit_ireqchange(p_api_version IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_group_id IN NUMBER,
                              p_fundscheck_flag IN VARCHAR2,
                              p_note_to_approver IN VARCHAR2,
                              p_initiator IN VARCHAR2,
                              x_retmsg OUT NOCOPY VARCHAR2,
                              x_errcode OUT NOCOPY VARCHAR2,
                              x_errtable OUT NOCOPY po_req_change_err_table )
  IS
  l_api_name     CONSTANT VARCHAR(30) := 'Submit_IReqChange';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_group_ID', p_group_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_fundscheck_flag', p_fundscheck_flag);
      po_debug.debug_var(l_log_head, l_progress, 'p_note_to_approver', p_note_to_approver);
    END IF;

    po_rco_validation_pvt.submit_ireqchange(p_api_version,
                                            x_return_status,
                                            p_group_id,
                                            p_fundscheck_flag,
                                            p_note_to_approver,
                                            p_initiator,
                                            x_retmsg,
                                            x_errcode,
                                            x_errtable );

    IF g_debug_stmt THEN
      po_debug.debug_end(l_log_head);
    END IF;


  END submit_ireqchange;

  PROCEDURE submit_ireqcancel (
                               p_api_version IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_group_id IN NUMBER,
                               x_retmsg OUT NOCOPY VARCHAR2,
                               p_errtable OUT NOCOPY po_req_change_err_table,
                               p_flag IN VARCHAR2 DEFAULT NULL)
  IS
  l_api_name     CONSTANT VARCHAR(30) := 'Submit_IReqChange';
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
   --PO_DEBUG.debug_var(l_log_head,l_progress,'p_req_hdr_id',p_req_hdr_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_group_ID', p_group_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_flag', p_flag);
    END IF;


    po_rco_validation_pvt.submit_ireqcancel (
                                             p_api_version ,
                                             x_return_status ,
                                             p_group_id ,
                                             x_retmsg ,
                                             p_errtable ,
                                             p_flag );

    IF g_debug_stmt THEN
      po_debug.debug_end(l_log_head);
    END IF;
  END submit_ireqcancel;



  PROCEDURE is_on_complex_work_order(p_line_loc_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    po_rco_validation_pvt.is_on_complex_work_order(p_line_loc_id,
                                                   x_return_status);
  END is_on_complex_work_order;

 FUNCTION IS_ANY_LINE_WITHDRAWABLE(p_req_hdr_id in number) RETURN VARCHAR2
 	          IS
 	          l_line_to_withdraw_count NUMBER := 0;
 	          l_api_name varchar2(50) := 'AllLINES_ChangableORCancelled';

 	          BEGIN

 	            SELECT Count(*)
 	            INTO l_line_to_withdraw_count
 	            FROM po_requisition_lines_all
 	            WHERE  REQUISITION_HEADER_ID  = p_req_hdr_id
 	            AND    LINE_LOCATION_ID IS NULL
 	            AND   nvl(CANCEL_FLAG,'N') = 'N'
 	            AND   nvl(CLOSED_CODE,'OPEN') NOT IN ('FINALLY CLOSED');


 	            IF ( l_line_to_withdraw_count > 0)  THEN
 	                      return 'Y';
 	            ELSE
 	                      return 'N';
 	            END IF;

 	      exception when others then
 	            IF g_debug_unexp THEN
 	               po_debug.debug_var(l_api_name, '001', 'sqlerrm=', sqlerrm);
 	            END IF;
 	            RETURN 'Y';

 	          END IS_ANY_LINE_WITHDRAWABLE;



  PROCEDURE get_preparer_name(
                              p_api_version                 IN             NUMBER
                              ,  p_req_hdr_id                  IN             NUMBER
                              ,  x_return_status               OUT NOCOPY     VARCHAR2
                              ,  x_preparer_name                OUT NOCOPY    VARCHAR2
                              )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'get_preparer_name';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_hdr_id', p_req_hdr_id);
    END IF;

    l_progress := '010';

-- Standard Start of API savepoint
    SAVEPOINT get_preparer_name_sp;

    l_progress := '020';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '030';


--  Initialize API return status to success

    x_return_status := fnd_api.g_ret_sts_success;

    l_progress := '050';

    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'Calling Private Procedure get_preparer_name');
    END IF;

    l_progress := '060';


    po_rco_validation_pvt.get_preparer_name(p_req_hdr_id     => p_req_hdr_id
                                            ,  x_preparer_name    =>  x_preparer_name
                                            ,  x_return_status    =>  x_return_status);


    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'After Private Procedure get_preparer_name');
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO get_preparer_name_sp;
    x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO get_preparer_name_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
    ROLLBACK TO get_preparer_name_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'EXCEPTION: Location and SQL CODE is  ', SQLCODE);
    END IF;
  END get_preparer_name;

/**
* Bug: 14227140 deprecated with overridden method.
* version change from 2.0 to 3.0
*/
PROCEDURE update_reqcancel_from_so(
                                      p_api_version                 IN             NUMBER
                                     , p_req_line_id_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_qty_tbl            IN             Dbms_Sql.number_table
                                     , p_req_can_all                IN             Boolean
																		 ,  x_return_status             OUT NOCOPY     VARCHAR2
                                     )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'update_ReqCancel_from_SO';
  l_api_version           CONSTANT NUMBER := 3.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  p_req_hdr_id NUMBER :=0;
  p_qty  NUMBER;
  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
    END IF;

    l_progress := '010';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  END update_reqcancel_from_so;


/**
* Bug: 14227140 deprecated with overridden method.
* version change from 2.0 to 3.0
*/
PROCEDURE update_reqcancel_from_so(
                                      p_api_version                 IN             NUMBER
                                     ,  x_return_status             OUT NOCOPY     VARCHAR2
                                     ,  p_req_line_id_tbl           IN          Dbms_Sql.number_table    --this needs to be table of number
                                     )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'update_ReqCancel_from_SO';
  l_api_version           CONSTANT NUMBER := 3.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  p_req_hdr_id NUMBER :=0;

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
    END IF;

    l_progress := '010';

-- Standard Start of API savepoint
    SAVEPOINT update_reqcancel_from_so_sp;

    l_progress := '020';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '030';



    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'After Private Procedure update_ReqCancel_from_SO');
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'EXCEPTION: Location and SQL CODE is  ', SQLCODE);
    END IF;
  END update_reqcancel_from_so;


/**
* Bug: 14227140 deprecated with overridden method.
* version change from 1.0 to 2.0
*/

  PROCEDURE update_reqchange_from_so(
                                     p_api_version                 IN             NUMBER
                                     ,  x_return_status               OUT NOCOPY     VARCHAR2
                                     ,  p_req_line_id                  IN             NUMBER
                                     ,  p_delta_quantity               IN             NUMBER
                                     ,  p_new_need_by_date             IN             DATE
                                     )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'update_ReqChange_from_SO';
  l_api_version           CONSTANT NUMBER := 2.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
 /*  PO_DEBUG.debug_var(l_log_head,l_progress,'p_commit',p_commit);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_init_msg_list',p_init_msg_list);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_validation_level',p_validation_level);
*/   po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_delta_quantity', p_delta_quantity);
      po_debug.debug_var(l_log_head, l_progress, 'p_new_need_by_date', p_new_need_by_date);
    END IF;

    l_progress := '010';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

  END update_reqchange_from_so;





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
                                     , x_return_status             OUT NOCOPY     VARCHAR2
                                     )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'update_reqcancel_from_so';
  l_api_version           CONSTANT NUMBER := 4.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';
  p_req_hdr_id NUMBER :=0;
  p_prim_qty  NUMBER;
  p_sec_qty  NUMBER;
  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
    END IF;

    l_progress := '010';

-- Standard Start of API savepoint
    SAVEPOINT update_reqcancel_from_so_sp;

    l_progress := '020';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '030';

    IF (p_req_line_id_tbl IS  NULL  OR p_req_line_id_tbl.Count=0  ) THEN
     IF g_debug_stmt THEN
       po_debug.debug_stmt(l_log_head, l_progress,'Procedure update_ReqCancel_from_SO called with no req line id from OM');
     END IF;
     RAISE fnd_api.g_exc_unexpected_error;
    END IF;

--  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_progress := '050';

    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'Calling Private Procedure update_ReqCancel_from_SO table count ='|| p_req_line_id_tbl.Count);
    END IF;

    l_progress := '060';

    FOR i in 1.. p_req_line_id_tbl.COUNT LOOP

      IF g_debug_stmt THEN
          po_debug.debug_var(l_log_head, l_progress,'p_req_line_id',p_req_line_id_tbl(i));
          po_debug.debug_var(l_log_head, l_progress,'p_req_can_all',p_req_can_all);

      END IF;

      if p_req_can_all then
      	      p_prim_qty := 0;
              p_sec_qty := 0;
      else
              p_prim_qty :=  p_req_can_prim_qty_tbl(i) ;
              p_sec_qty :=  p_req_can_sec_qty_tbl(i) ;
      end if;
          IF g_debug_stmt THEN
          po_debug.debug_var(l_log_head, l_progress,'p_req_line_id',p_req_line_id_tbl(i));
          po_debug.debug_var(l_log_head, l_progress,'p_prim_qty',p_prim_qty);
          po_debug.debug_var(l_log_head, l_progress,'p_sec_qty',p_sec_qty);
          po_debug.debug_var(l_log_head, l_progress,'p_req_can_all',p_req_can_all);

      END IF;



      po_rco_validation_pvt.update_reqcancel_from_so(p_req_line_id     =>  p_req_line_id_tbl(i)
                                                    , p_req_cancel_prim_qty =>  p_prim_qty
                                                    , p_req_cancel_sec_qty =>  p_sec_qty
                                                    , p_req_cancel_all   => p_req_can_all
                                                     ,x_return_status    =>  x_return_status);

    END LOOP;


    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'After Private Procedure update_ReqCancel_from_SO');
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
    ROLLBACK TO update_reqcancel_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'EXCEPTION: Location and SQL CODE is  ', SQLCODE);
    END IF;
  END update_reqcancel_from_so;





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
                                     )
  IS

  l_api_name              CONSTANT VARCHAR2(30) := 'update_reqchange_from_so';
  l_api_version           CONSTANT NUMBER := 3.0;
  l_log_head              CONSTANT VARCHAR2(100) := c_log_head || l_api_name;
  l_progress              VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      po_debug.debug_begin(l_log_head);
      po_debug.debug_var(l_log_head, l_progress, 'p_api_version', p_api_version);
      po_debug.debug_var(l_log_head, l_progress, 'p_req_line_id', p_req_line_id);
      po_debug.debug_var(l_log_head, l_progress, 'p_delta_quantity_prim', p_delta_quantity_prim);
      po_debug.debug_var(l_log_head, l_progress, 'p_delta_quantity_sec', p_delta_quantity_sec);
      po_debug.debug_var(l_log_head, l_progress, 'p_new_need_by_date', p_new_need_by_date);
    END IF;

    l_progress := '010';

-- Standard Start of API savepoint

    SAVEPOINT update_reqchange_from_so_sp;

    l_progress := '020';

-- Standard call to check for call compatibility

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '040';

--  Initialize API return status to success

    x_return_status := fnd_api.g_ret_sts_success;

    l_progress := '050';

    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'Calling Private Procedure update_reqchange_from_so');
    END IF;

    l_progress := '060';


    IF (p_req_line_id IS NOT NULL ) AND
      (p_delta_quantity_prim IS NOT NULL OR p_delta_quantity_sec IS NOT NULL OR p_new_need_by_date IS NOT NULL ) THEN

      po_rco_validation_pvt.update_reqchange_from_so(
                                                     p_req_line_id     => p_req_line_id
                                                     , p_delta_quantity_prim  => p_delta_quantity_prim
                                                     , p_delta_quantity_sec  => p_delta_quantity_sec
                                                     , p_new_need_by_date =>  p_new_need_by_date
                                                     , x_return_status    =>  x_return_status);

    ELSE
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      po_debug.debug_stmt(l_log_head, l_progress,'After Private Procedure update_ReqChange_from_SO');
    END IF;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO update_reqchange_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO update_reqchange_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
    ROLLBACK TO update_reqchange_from_so_sp;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF g_debug_stmt THEN
      po_debug.debug_var(l_log_head, l_progress,'EXCEPTION: Location and SQL CODE is  ', SQLCODE);
    END IF;
  END update_reqchange_from_so;

-- 14227140 changes ends


END po_rco_validation_grp;

/

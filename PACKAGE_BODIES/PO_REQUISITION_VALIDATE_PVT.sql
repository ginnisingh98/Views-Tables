--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_VALIDATE_PVT" AS
/* $Header: POXRQVLB.pls 120.0.12010000.19 2014/07/16 03:19:46 fenyan noship $ */

/*===========================================================================+
 |               Copyright (c) 2013, 2014 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*===========================================================================
  FILE NAMe    :         POXRQVLB.pls
  PACKAGE NAME:         PO_REQUISITION_VALIDATE_PVT

  DESCRIPTION:
   PO_REQUISITION_VALIDATE_PVT API performs all the validations on requisition
   header,lines and distributions before updation

 PROCEDURES:
     val_requisition_hdr -- Validate Requisition Header Data
     val_requisition_line -- Validate Requisition Line Data
     val_requisition_dist -- Validate Distribution Data
     check_dist_unreserve -- Unreserve Distribution Lines
     check_lines_unreserve -- Unreserve Requisition Line
     call_account_generator -- Call Account generator
     rebuild_accounts -- Rebuild Charge Accounts on requisition update
==============================================================================*/
-- Read the profile option that enables/disables the debug log
G_FND_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_REQUISITION_VALIDATE_PVT';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXRQVLB.pls';
  -- Logging global constants
  D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);
  G_ERROR_COL VARCHAR2(100);

G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
g_func_currency VARCHAR2(30);

FUNCTION allow_changeonreq ( p_req_hdr_id IN NUMBER,
                          p_org_id IN NUMBER
                          ,p_req_line_id IN NUMBER) RETURN VARCHAR2 IS
v_exists VARCHAR2(2) := 'N';
l_module_name CONSTANT VARCHAR2(100) := 'does_po_exists';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;
v_modify_line varchar2(2):='N';

BEGIN
			  BEGIN
			   SELECT 'Y'
			   INTO v_modify_line
			   FROM po_requisition_lines_all prla
			   WHERE requisition_header_id = p_req_hdr_id
			   and requisition_line_id = nvl(p_req_line_id,requisition_line_id)
			   AND not exists (select 1 from
			                   po_distributions_all pda,
			                   po_req_distributions_all prda
			                   WHERE pda.req_distribution_id = prda.distribution_id
			                   and prda.requisition_line_id = prla.requisition_line_id)
			   AND rownum=1                ;


			  IF PO_LOG.d_stmt THEN
			        PO_LOG.stmt(d_module_base,d_progress,'v_exists',v_exists);

			  END IF;

			 EXCEPTION
			  WHEN NO_DATA_FOUND THEN
			     v_modify_line := 'N';
			  WHEN OTHERS THEN
			     v_modify_line := 'N';
			      po_message_s.sql_error('allow_changeonreq','010',SQLCODE);
			      RAISE;
			 END;
 RETURN v_modify_line;
END;

PROCEDURE LOG_INTERFACE_ERRORS(p_column_name VARCHAR2,
                               p_error_msg VARCHAR2,
                               p_transaction_id NUMBER,
                               p_table_name VARCHAR2,
                               p_line_id NUMBER DEFAULT NULL,
                               p_distribution_id NUMBER DEFAULT NULL)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 INSERT INTO po_interface_errors
      (interface_type,interface_transaction_id,column_name,error_message,
       creation_date,created_by,last_update_date,last_updated_by,
       last_update_login,
       program_update_date, table_name,interface_header_id,interface_line_id,interface_distribution_id)
 VALUES('REQ_UPDATE',p_transaction_id,SUBSTR(p_column_name,1,30),SUBSTR(p_error_msg,1,2000),
        SYSDATE,fnd_global.user_id,SYSDATE,fnd_global.user_id,
        fnd_global.login_id,
        SYSDATE,p_table_name,p_transaction_id,p_line_id,p_distribution_id);
COMMIT;

EXCEPTION
WHEN OTHERS THEN
    po_message_s.sql_error('LOG_INTERFACE_ERRORS','010',SQLCODE);
    RAISE;

END;

PROCEDURE clear_interface_errors(p_transaction_id IN NUMBER)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   DELETE FROM po_interface_errors
   WHERE interface_type = 'REQ_UPDATE'
   AND interface_transaction_id = p_transaction_id;

	 COMMIT;
EXCEPTION
WHEN OTHERS THEN
    po_message_s.sql_error('clear_interface_errors','010',SQLCODE);
    RAISE;

END;
PROCEDURE val_requisition_hdr (req_hdr IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr,
                               x_return_status OUT NOCOPY    VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg  OUT NOCOPY  VARCHAR2 ) IS

l_api_name CONSTANT VARCHAR2(40) := 'val_requisition_hdr';
l_req_hdr_id NUMBER;
l_err_msg VARCHAR2(1000);
l_log_msg VARCHAR2(1000);
l_auth_status VARCHAR2(50);

l_module_name CONSTANT VARCHAR2(100) := 'val_requisition_hdr';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;
l_segment1 VARCHAR2(50);
e_hdr_error EXCEPTION;
BEGIN

    ----dbms_OUTPUT.PUT_LINE('Start');
  d_progress := 10;
  --Initialize msg API
  IF Fnd_Api.to_Boolean(NVL(p_init_msg,fnd_api.g_true)) THEN
     Fnd_Msg_Pub.initialize;
  END IF;

   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'req_hdr.requisition_header_id', req_hdr.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'req_hdr.segment1', req_hdr.segment1);
   END IF;
  --  Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

 -- Check if req exists
 BEGIN
   SELECT requisition_header_id,segment1,
   authorization_status,org_id
   INTO l_req_hdr_id,l_segment1,
   l_auth_status,req_hdr.org_id
   FROM po_requisition_headers_all
   WHERE (requisition_header_id = req_hdr.requisition_header_id
          OR segment1 = req_hdr.segment1)
   AND   org_id = req_hdr.org_id;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
       x_error_msg := ' Invalid Requisition..Please enter a valid requisition Id/Number';
       G_ERROR_COL := 'REQUISITION_HEADER_ID OR SEGMENT1';
       RAISE e_hdr_error;
   WHEN OTHERS THEN
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('val_requisition_hdr',d_progress,SQLCODE);
       G_ERROR_COL := 'REQUISITION_HEADER_ID OR SEGMENT1';
       RAISE e_hdr_error;
 END;

 clear_interface_errors(l_req_hdr_id);

  d_progress := 20;
  req_hdr.authorization_status := l_auth_status;
  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_auth_status',l_auth_status);
        PO_LOG.stmt(d_module_base,d_progress,'l_req_hdr_id',l_req_hdr_id);
  END IF;

 IF l_err_msg IS NOT NULL THEN
   x_error_msg := l_err_msg;
   x_return_status := 'E';
   RETURN;
 END IF;
 --Dont update requisition with generated PO
 IF allow_changeonreq(req_hdr.requisition_header_id,req_hdr.org_id,NULL) = 'N' THEN
    d_progress := 30;
    x_error_msg := 'Requisition is not eligible for Update..PO Exists for this requisition';
    x_return_status := 'E';
    G_ERROR_COL := 'REQUISITION';
    RAISE e_hdr_error;
 END IF;


 IF l_auth_status IN ('CANCELLED','PRE-APPROVED','IN-PROCESS') THEN
    x_error_msg := 'Requisition with status '||l_auth_status||' is not eligible for update' ;
    x_return_status := 'E';
    G_ERROR_COL := 'AUTHORIZATION_STATUS';
    RAISE e_hdr_error;
 END IF;

x_return_status := 'S';
EXCEPTION
 WHEN e_hdr_error THEN
  l_err_msg := 'Validation Failure for Requisition with Number : '||l_segment1 ||'Id: '||req_hdr.requisition_header_id;
   log_interface_errors(G_ERROR_COL,x_error_msg,req_hdr.requisition_header_id,'PO_REQUISITION_HEADERS');
   x_error_msg := l_err_msg||x_error_msg;

   po_message_s.add_exc_msg(d_module_base,'val_requisition_hdr',x_error_msg);
    po_message_s.concat_fnd_messages_in_stack(Fnd_Msg_Pub.Count_Msg,x_error_msg);

   x_return_status := 'E';
 WHEN OTHERS THEN
      x_return_status :='E';
      x_error_msg := 'Validation Failure occured for Requisition No : '||l_segment1||'Unexpected error occured at '||d_progress|| SQLERRM;
      po_message_s.add_exc_msg(d_module_base,'val_requisition_hdr',x_error_msg||SQLERRM);
      po_message_s.concat_fnd_messages_in_stack(Fnd_Msg_Pub.Count_Msg,x_error_msg);
      x_return_status := 'E';
END;

FUNCTION get_project_id(p_project_no VARCHAR2) RETURN NUMBER
IS
l_project_id NUMBER := -1;
l_module_name CONSTANT VARCHAR2(100) := 'get_project_id';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

BEGIN

  SELECT project_id
  INTO l_project_id
  FROM pa_projects_expend_v
  WHERE project_number = p_project_no ;

  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,10,'l_project_id',l_project_id);
  END IF;

  RETURN l_project_id;

 EXCEPTION

 WHEN NO_DATA_FOUND THEN
    l_project_id := -1;
    RETURN l_project_id;
 WHEN OTHERS THEN
     po_message_s.sql_error('get_project_id',10,SQLCODE);
     RAISE;
END;

FUNCTION get_cc_id(p_ccid NUMBER,p_encumbered_date DATE,p_chart_of_accounts_id NUMBER) RETURN NUMBER
IS
l_ccid NUMBER := -1;
l_module_name CONSTANT VARCHAR2(100) := 'get_cc_id';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
d_position NUMBER;

BEGIN

   BEGIN
      SELECT code_combination_id
       INTO l_ccid
       FROM  gl_code_combinations gcc
                     WHERE  gcc.code_combination_id = p_ccid
                       AND  gcc.enabled_flag = 'Y'
           AND  TRUNC(NVL(p_encumbered_date,SYSDATE)) BETWEEN
              TRUNC(NVL(start_date_active,
                                            NVL(p_encumbered_date,SYSDATE) ))
                                AND
        TRUNC(NVL (end_date_active,
                                            NVL(p_encumbered_date,SYSDATE) ))
           AND gcc.detail_posting_allowed_flag = 'Y'
                       AND gcc.chart_of_accounts_id=
                                      p_chart_of_accounts_id
           AND gcc.summary_flag = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module_base, d_position, 'Not a valid ccid');
          END IF;
          fnd_message.set_name ('PO','PO_RI_INVALID_ACCRUAL_ACC_ID');
          fnd_msg_pub.ADD;
      END;

  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,10,'l_ccid',l_ccid);
  END IF;

  RETURN l_ccid;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    l_ccid := -1;
    RETURN l_ccid;
 WHEN OTHERS THEN
     po_message_s.sql_error('get_cc_id',10,SQLCODE);
     RAISE;
END;


FUNCTION get_task_id(p_project_id VARCHAR2,p_task_no VARCHAR2) RETURN NUMBER
IS
l_task_id NUMBER := -1;

BEGIN
  SELECT task_id
  INTO l_task_id
  FROM pa_tasks_expend_v
  WHERE project_id = p_project_id
  AND task_number = p_task_no;


  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt('get_task_id',10,'l_task_id',l_task_id);
  END IF;

  RETURN l_task_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN -1;
  WHEN OTHERS THEN
     po_message_s.sql_error('get_task_id',10,SQLCODE);
     RAISE;
END;

FUNCTION is_valid_expend_type(p_exp_type VARCHAR2,p_project_id NUMBER) RETURN BOOLEAN
IS
   l_valid_exp BOOLEAN := TRUE;
   CURSOR c_exp_type IS
   SELECT   expenditure_type
      FROM pa_expenditure_types_expend_v et
     WHERE system_linkage_function = 'VI'
       AND et.project_id = p_project_id
       AND TRUNC (SYSDATE) BETWEEN NVL (et.expnd_typ_start_date_active,
                                        TRUNC (SYSDATE)
                                       )
                               AND NVL (et.expnd_typ_end_date_active,
                                        TRUNC (SYSDATE)
                                       )
       AND TRUNC (SYSDATE) BETWEEN NVL (et.sys_link_start_date_active,
                                        TRUNC (SYSDATE)
                                       )
                               AND NVL (et.sys_link_end_date_active,
                                        TRUNC (SYSDATE)
                                       )
      AND et.expenditure_type = p_exp_type
  UNION
  SELECT   expenditure_type
      FROM pa_expenditure_types_expend_v et
     WHERE system_linkage_function = 'VI'
       AND et.project_id IS NULL
       AND TRUNC (SYSDATE) BETWEEN NVL (et.expnd_typ_start_date_active,
                                        TRUNC (SYSDATE)
                                       )
                               AND NVL (et.expnd_typ_end_date_active,
                                        TRUNC (SYSDATE)
                                       )
       AND TRUNC (SYSDATE) BETWEEN NVL (et.sys_link_start_date_active,
                                        TRUNC (SYSDATE)
                                       )
                               AND NVL (et.sys_link_end_date_active,
                                        TRUNC (SYSDATE)
                                       )
       AND et.expenditure_type = p_exp_type;
  l_exp_type VARCHAR2(30);
BEGIN
   OPEN   c_exp_type;
   FETCH c_exp_type INTO l_exp_type;
   IF c_exp_type%NOTFOUND THEN
     l_valid_exp := FALSE;
   END IF;
   CLOSE c_exp_type;

   RETURN l_valid_exp;
EXCEPTION
WHEN OTHERS THEN
    l_valid_exp := FALSE;
     po_message_s.sql_error('is_valid_expend_type',10,SQLCODE);
     RAISE;

END;

/*Expenditure item
date should be within the corresponding Project Task's START and COMPLETION
dates */

FUNCTION is_valid_exp_date(p_exp_item_date DATE,p_project_id NUMBER,p_task_id NUMBER) RETURN VARCHAR2 IS

l_valid_flag VARCHAR2(1):='N';
BEGIN
     SELECT  'Y'
     INTO l_valid_flag
    FROM    pa_projects_expend_v pap, pa_tasks_expend_v pat
    WHERE   pap.project_id = p_project_id
   AND     pap.project_id = pat.project_id
   AND     pat.task_id = p_task_id
   AND     p_exp_item_date BETWEEN NVL(pap.start_date,p_exp_item_date)
                           AND     NVL(pap.completion_date,p_exp_item_date)
   AND     p_exp_item_date BETWEEN NVL(pat.start_date,p_exp_item_date)
                           AND     NVL(pat.completion_date,p_exp_item_date) ;

     RETURN l_valid_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_valid_flag := 'N';
      RETURN l_valid_flag;
  WHEN OTHERS THEN
      l_valid_flag := 'E';
     po_message_s.sql_error('is_valid_exp_date',10,SQLCODE);
     RAISE;
END;

PROCEDURE isvalid_exp_org(p_exp_org_name IN VARCHAR2,p_exp_org_id IN OUT NOCOPY  VARCHAR2,p_exp_item_date IN DATE,x_status OUT NOCOPY  VARCHAR2)
IS
l_org_id NUMBER;
BEGIN
  SELECT poev.organization_id
  INTO  p_exp_org_id
    FROM pa_organizations_expend_v poev
   WHERE poev.active_flag = 'Y'
     AND NVL (p_exp_item_date, TRUNC (SYSDATE))
            BETWEEN TRUNC (poev.date_from)
                AND NVL (TRUNC (poev.date_to),
                         NVL (p_exp_item_date,
                              TRUNC (SYSDATE)
                             )
                        )
     AND  (poev.organization_id = p_exp_org_id  OR poev.NAME = p_exp_org_name) ;

     x_status := 'S';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     p_exp_org_id := -1;
     x_status := 'E';
  WHEN OTHERS THEN
     x_status := 'E';
     po_message_s.sql_error('isvalid_exp_org',10,SQLCODE);
     RAISE;
END;

PROCEDURE val_poet_data(p_project_no IN VARCHAR2,
                        p_task_no IN VARCHAR2,
                        p_exp_type VARCHAR2,
                        p_exp_org_name IN OUT NOCOPY  VARCHAR2,
                        p_exp_item_date IN  DATE,
                        p_project_id IN OUT NOCOPY  NUMBER,
                        p_task_id IN OUT NOCOPY  NUMBER,
                        p_exp_org_id IN OUT NOCOPY  NUMBER,
                        x_return_status OUT NOCOPY  VARCHAR2
                        )
IS
l_error_msg VARCHAR2(100);
l_progress VARCHAR2(100);

  l_module_name CONSTANT VARCHAR2(100) := 'val_poet_data';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;

BEGIN

 ----dbms_OUTPUT.PUT_LINE('In val_poet_data');
 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_project_no', p_project_no);
    PO_LOG.proc_begin(d_module_base, 'p_task_no', p_task_no);
    PO_LOG.proc_begin(d_module_base, 'p_exp_type', p_exp_type);
    PO_LOG.proc_begin(d_module_base, 'p_exp_org_name', p_exp_org_name);
    PO_LOG.proc_begin(d_module_base, 'p_exp_item_date', p_exp_item_date);
    PO_LOG.proc_begin(d_module_base, 'p_project_id', p_project_id);
    PO_LOG.proc_begin(d_module_base, 'p_task_id', p_task_id);
    PO_LOG.proc_begin(d_module_base, 'p_exp_org_id', p_exp_org_id);
  END IF;
  x_return_status := 'S';

 d_progress := 10;

  IF p_project_id IS NULL THEN
     p_project_id := get_project_id(p_project_no);
  END IF;

  IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'p_project_id',p_project_id);
  END IF;

  IF p_project_id = -1 THEN
    x_return_status := 'E';

    RETURN;
  END IF;
  d_progress := 20;

  IF p_task_id IS NULL THEN
     p_task_id := get_task_id (p_project_id,p_task_no);
   END IF;

  IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'p_task_id',p_task_id);
  END IF;

  d_progress := 30;

   IF p_task_id = -1 THEN
      x_return_status := 'E';
      RETURN;
   END IF;

   IF  NOT is_valid_expend_type(p_exp_type,p_project_id) THEN
      x_return_status :='E';
      RETURN;
   END IF;


   IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'p_task_id',p_task_id);
   END IF;

   d_progress := 40;

   IF  is_valid_exp_date(p_exp_item_date,p_project_id,p_task_id) <> 'Y' THEN
      x_return_status := 'E';
   END IF;

    d_progress := 50;
   isvalid_exp_org  (p_exp_org_name,p_exp_org_id,p_exp_item_date,x_return_status);

    d_progress := 60;

EXCEPTION
 WHEN OTHERS THEN
     po_message_s.sql_error('val_poet_data',d_progress,SQLCODE);

     x_return_status := 'E';
     RAISE;

END;

PROCEDURE isvalid_distribution(
                               p_req_hdr_id NUMBER,
                               p_req_line_id NUMBER,
                               p_req_dist_num NUMBER,
                               p_req_dist_id IN OUT NOCOPY  NUMBER,
                               p_project_flag IN OUT NOCOPY  VARCHAR2,
                               p_transfer_to_oe_flag OUT NOCOPY VARCHAR2,
                               x_status OUT NOCOPY  VARCHAR2)
IS
l_req_hdr_id NUMBER;

 l_module_name CONSTANT VARCHAR2(100) := 'isvalid_distribution';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_req_dist_id NUMBER;
  l_project_flag VARCHAR2(5);
  l_transfer_to_oe_flag VARCHAR2(5);
BEGIN

 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_hdr_id', p_req_hdr_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line_id', p_req_line_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_dist_num', p_req_dist_num);
    PO_LOG.proc_begin(d_module_base, 'p_req_dist_id', p_req_dist_id);


  END IF;

  IF p_req_dist_id IS NULL AND p_req_dist_num IS NOT NULL THEN
  BEGIN
    SELECT distribution_id
    INTO l_req_dist_id
    FROM po_req_distributions
    WHERE requisition_line_id = p_req_line_id
    AND distribution_num = p_req_dist_num;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_status := 'N';
    RETURN;
  WHEN OTHERS THEN
    x_status := 'E';
    RETURN;
  END;
  END IF;
    SELECT distribution_id,
    project_accounting_context,
	prl.TRANSFERRED_TO_OE_FLAG
    INTO l_req_dist_id,
      l_project_flag,
      l_transfer_to_oe_flag
    FROM po_req_distributions prd,
         po_requisition_lines prl,
         po_requisition_headers prh
    WHERE prh.requisition_header_id = prl.requisition_header_id
    AND   prl.requisition_line_id = prd.requisition_line_id
    AND   prl.requisition_line_id = p_req_line_id
    AND   prh.requisition_header_id = p_req_hdr_id
    AND   (prd.distribution_id = NVL(p_req_dist_id,-1) OR prd.distribution_num = NVL(p_req_dist_num,-1));

    x_status := 'S';
    p_req_dist_id := l_req_dist_id;
    p_project_flag := l_project_flag;
    p_transfer_to_oe_flag := l_transfer_to_oe_flag;

   IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'p_project_flag='||l_project_flag);
    END IF;

     IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'x_status',x_status);
      END IF;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
     x_status := 'W';
     p_req_dist_id := -1;
 WHEN OTHERS THEN
     x_status := 'E';
     po_message_s.sql_error('isvalid_distribution','010',SQLCODE);
     po_message_s.add_exc_msg(d_module_BASE,l_module_name,SQLCODE||SQLERRM);
     RAISE;
END;

PROCEDURE isvalid_award(p_award_id IN OUT NOCOPY  NUMBER,
                        p_award_no IN VARCHAR2,
                        p_project_id IN NUMBER,
                        p_task_id IN NUMBER,
                        x_return_status OUT NOCOPY   VARCHAR2)
IS
 CURSOR c_award IS
  SELECT DISTINCT gaw.award_id AS req_award_id
  FROM pa_tasks pts,
       gms_installments gis,
       gms_summary_project_fundings gspf,
       gms_budget_versions gbv,
       gms_awards gaw
  WHERE gbv.budget_status_code     = 'B'
    AND gbv.project_id             = p_project_id
    AND gbv.award_id               = gaw.award_id
    AND gspf.project_id              = gbv.project_id
    AND pts.project_id              = gbv.project_id
    AND pts.task_id                 = p_task_id
    AND ((gspf.task_id IS NULL) OR (gspf.task_id = pts.task_id) OR (gspf.task_id = pts.top_task_id ))
    AND gis.installment_id        = gspf.installment_id
    AND gis.award_id              = gaw.award_id
    AND gaw.status                 <> 'CLOSED'
    AND gaw.award_template_flag    = 'DEFERRED'
    AND (gaw.award_id = p_award_id OR gaw.award_number = p_award_no)
  UNION ALL
  SELECT default_dist_award_id
  FROM gms_implementations
  WHERE award_distribution_option = 'Y'
  AND( default_dist_award_id = p_award_id OR default_dist_award_number = p_award_no);

   l_module_name CONSTANT VARCHAR2(100) := 'isvalid_award';
    d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
    d_progress NUMBER;

BEGIN

   IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module_base);
     PO_LOG.proc_begin(d_module_base, 'p_award_id', p_award_id);
     PO_LOG.proc_begin(d_module_base, 'p_award_no', p_award_no);
     PO_LOG.proc_begin(d_module_base, 'p_project_id', p_project_id);
     PO_LOG.proc_begin(d_module_base, 'p_task_id', p_task_id);
    END IF;

    OPEN c_award;
    FETCH c_award INTO p_award_id;
    IF c_award%NOTFOUND THEN
       x_return_status := 'W';
    ELSE
       x_return_status := 'S';
    END IF;

    CLOSE c_award;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'p_award_id',p_award_id);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := 'E';
     p_award_id := -1;
     po_message_s.sql_error('isvalid_award','010',SQLCODE);
     RAISE;
END;

FUNCTION check_installed_application(p_application_name VARCHAR2) RETURN BOOLEAN
IS
l_exists VARCHAR2(1):='N';
l_ret_val BOOLEAN;
BEGIN
 l_ret_val := FALSE;

 SELECT 'Y'
 INTO l_exists
 FROM
 FND_PRODUCT_INSTALLATIONS fpi,
 fnd_application fa
 WHERE fpi.application_id = fa.application_id
 AND fa.application_short_name = p_application_name
 AND fpi.status IN ('I','S') ;

  l_ret_val := TRUE;

  RETURN l_ret_val;
 EXCEPTION
 WHEN OTHERS THEN
   l_ret_val := FALSE;
   RETURN l_ret_val;
END;



PROCEDURE validate_req_distribution (p_req_dist_rec IN  OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                x_status OUT NOCOPY  VARCHAR2) IS
l_status VARCHAR2(1);
l_progress NUMBER;
l_api VARCHAR2(50):='val_requisition_dist';
l_dest_type VARCHAR2(40);
l_msg_application VARCHAR2(50);
l_msg_type VARCHAR2(50);
l_msg_token1 VARCHAR2(50);
l_msg_token2 VARCHAR2(50);
l_msg_token3 VARCHAR2(50);
l_val_proj_error_code  VARCHAR2(100);
l_val_proj_result VARCHAR2(1);
l_auth_status VARCHAR2(50);
l_return_status VARCHAR2(2);
l_msg_count NUMBER;
x_msg_count NUMBER;

l_billable_flag VARCHAR2(20);

CURSOR c_dist_rec (p_dist_id NUMBER,p_req_line NUMBER)
IS
  SELECT *
  FROM po_req_distributions prd
  WHERE distribution_id = p_dist_id
  AND  requisition_line_id = p_req_line;

  CURSOR c_req_line(p_line_id NUMBER,p_hdr_id NUMBER)
  IS
  SELECT *
  FROM po_requisition_lines prl
  WHERE requisition_line_id = p_line_id
  AND  requisition_header_id = p_hdr_id;

  CURSOR cur_coa(p_org_id NUMBER)
   IS SELECT gsb.chart_of_accounts_id
  FROM financials_system_params_all fsp,
  gl_sets_of_books gsb
  WHERE fsp.org_id = p_org_id
  AND  gsb.set_of_books_id = fsp.set_of_books_id;

  l_dist_rec po_req_distributions%ROWTYPE;
  l_line_rec po_requisition_lines%ROWTYPE;
  l_req_no VARCHAR2(100);
  l_coa NUMBER;
  l_module_name CONSTANT VARCHAR2(100) := 'validate_req_distribution';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_sob_id NUMBER;
  user_error EXCEPTION;
  l_error_msg VARCHAR2(5000);
  L_VALID VARCHAR2(1);
  x_transfer_to_oe_flag VARCHAR2(10);
  l_req_enc_flag financials_system_params_all.REQ_ENCUMBRANCE_FLAG%TYPE;
  l_req_award_id po_req_distributions.req_award_id%TYPE;
  l_project_id po_req_distributions.project_id%TYPE;
  l_task_id po_req_distributions.task_id%TYPE;
BEGIN
  l_progress := 10;

  IF Fnd_Api.to_Boolean(NVL(p_init_msg,fnd_api.g_true)) THEN
     Fnd_Msg_Pub.initialize;
  END IF;


    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module_base);
      PO_LOG.proc_begin(d_module_base, 'req_header_id', p_req_dist_rec.req_header_id);
      PO_LOG.proc_begin(d_module_base, 'req_line_id', p_req_dist_rec.req_line_id);
      PO_LOG.proc_begin(d_module_base, 'distribution_num', p_req_dist_rec.distribution_num);
      PO_LOG.proc_begin(d_module_base, 'distribution_id', p_req_dist_rec.distribution_id);

   END IF;
   x_status := 'S';
     --validate distribution id

   IF p_req_dist_rec.req_header_id IS NULL AND p_req_dist_rec.requisition_number IS NOT NULL THEN
   BEGIN
     SELECT requisition_header_id
     INTO p_req_dist_rec.req_header_id
     FROM po_requisition_headers
     WHERE segment1 = p_req_dist_rec.requisition_number;
   EXCEPTION
   WHEN OTHERS THEN
     x_status := 'W' ;
     x_error_msg := 'Invalid Distribution/Distribution is not valid for given requisition..Please enter valid values for distribution and req';
     g_error_col := 'REQUISITION_NUMBER';
     RAISE user_error;
   END;
  END IF;

  IF p_req_dist_rec.req_line_id IS NULL AND p_req_dist_rec.req_line_num IS NOT NULL
  THEN
   BEGIN
    SELECT requisition_line_id
    INTO p_req_dist_rec.req_line_id
    FROM po_requisition_lines
    WHERE requisition_header_id = p_req_dist_rec.req_header_id
    AND line_num = p_req_dist_rec.req_line_num;
   EXCEPTION
   WHEN OTHERS THEN
     x_status := 'W' ;
     x_error_msg := 'Invalid Distribution/Distribution is not valid for given requisition..Please enter valid values for distribution and req';
     G_ERROR_COL := 'REQ_LINE_NUM';
     RAISE user_error;
   END;
  END IF;
  isvalid_distribution(p_req_dist_rec.req_header_id,
                       p_req_dist_rec.req_line_id,
                       p_req_dist_rec.distribution_num,
                       p_req_dist_rec.distribution_id,
                       p_req_dist_rec.project_accounting_context,
                       x_transfer_to_oe_flag,
                       x_status);

   IF NVL(x_transfer_to_oe_flag,'N') ='Y' THEN
       G_ERROR_COL := 'REQUISITION_LINE';
       x_error_msg := 'Line is placed onto sales order.It cannot be updated';
       RAISE user_error;
   END IF;
   l_progress:= 20;

    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'project_accounting_context',p_req_dist_rec.project_accounting_context);
    END IF;
   --dbms_OUTPUT.PUT_LINE('Status'||x_status);
   IF x_status = 'W' OR x_status ='E' THEN
       x_status := 'W' ;
       x_error_msg := 'Invalid Distribution/Distribution is not valid for given requisition..Please enter valid values for distribution and req';
       G_ERROR_COL := 'DISTRIBUTION_NUM OR DISTRIBUTION_ID';
       RAISE user_error;
   END IF;

   IF x_status = 'N' THEN
     p_req_dist_rec.action_flag := 'NEW';
   END IF;
   l_progress := 30;
    --Dont update requisition with generated PO
  IF allow_changeonreq(p_req_dist_rec.req_header_id,p_req_dist_rec.org_id,p_req_dist_rec.req_line_id) = 'N' THEN
     x_error_msg := 'Requisition line is not eligible for Update..PO Exists for this requisition line';
     x_return_status := 'E';

     IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg,'');
      END IF;
      G_ERROR_COL := 'REQUISITION';
      RAISE user_error;
  END IF;

  l_progress := 40;

  SELECT GSOB.chart_of_accounts_id,gsob.set_of_books_id,fsp.REQ_ENCUMBRANCE_FLAG
  INTO p_req_dist_rec.coa_id,l_sob_id,l_req_enc_flag
  FROM gl_sets_of_books gsob,
  financials_system_parameters fsp
  WHERE gsob.set_of_books_id = fsp.set_of_books_id;


 BEGIN
   SELECT prh.authorization_status,prh.org_id,
   prh.segment1
   INTO l_auth_status,p_req_dist_rec.org_id,
   l_req_no
   FROM po_requisition_headers prh,
   financialS_system_parameters fsp
   WHERE requisition_header_id = p_req_dist_rec.req_header_id;
 EXCEPTION
   WHEN OTHERS THEN
     x_error_msg := 'Error while fetching requisition status';
     x_status := 'E' ;
     po_message_s.sql_error('po_exists','040',SQLCODE);
     po_message_s.add_exc_msg(d_module_base,l_module_name,SQLCODE||SQLERRM);
     G_ERROR_COL := 'REQUISITION_HEADER_ID';
     RAISE user_error;
 END;

 OPEN cur_coa(p_req_dist_rec.org_id);
 FETCH cur_coa INTO l_coa;
 CLOSE cur_coa;
 l_progress := 50;
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'l_auth_status',l_auth_status);
      END IF;

  IF l_auth_status IN ('CANCELLED','PRE-APPROVED','IN-PROCESS') THEN
     x_error_msg := 'Requisition with status '||l_auth_status||' is not eligible for update' ;
     x_return_status := 'E';
     g_error_col := 'AUTHORIZATION_STATUS';
     RAISE user_error;

  END IF;

  l_progress := 60;

  OPEN c_dist_rec(p_req_dist_rec.distribution_id,p_req_dist_rec.req_line_id);
  FETCH c_dist_rec INTO l_dist_rec;
  CLOSE c_dist_rec;

  l_progress := 70;

   OPEN c_req_line(p_req_dist_rec.req_line_id, p_req_dist_rec.req_header_id);
   FETCH c_req_line INTO l_line_rec;
   CLOSE c_req_line;

   l_progress := 80;

   IF ( p_req_dist_rec.project_no IS NOT NULL OR p_req_dist_rec.project_id IS NOT NULL  OR
          p_req_dist_rec.task_no IS NOT NULL OR
          p_req_dist_rec.task_id IS NOT NULL OR
          p_req_dist_rec.expenditure_org_name IS NOT NULL OR
          p_req_dist_rec.expenditure_organization_id IS NOT NULL OR
          p_req_dist_rec.expenditure_item_date IS NOT NULL ) THEN

     l_progress := 802;
   --  --dbms_OUTPUT.PUT_LINE('Dest type'||l_line_rec.destination_type_code);
     IF ( (NOT check_installed_application('PA') AND l_line_rec.destination_type_code = 'EXPENSE')
          OR (l_line_rec.destination_type_code IN ('SHOP FLOOR','INVENTORY') AND NOT check_installed_application ('PJM')  )
         ) THEN
       fnd_message.set_name ('PO','PO_RI_INVALID_PAC_INFO');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_PAC_INFO');
       G_ERROR_COL := 'PROJECT ACCOUNTING CONTEXT';
       l_progress := 80.2;
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'PO_RI_INVALID_PAC_INFO',l_line_rec.destination_type_code);
       END IF;
    --  po_message_s.app_error('PO_RI_INVALID_PAC_INFO');
      RAISE user_error;
     ELSE
        l_progress := 803;
        -- --dbms_OUTPUT.PUT_LINE('val_poet_data');
       val_poet_data( p_req_dist_rec.project_no,
                      p_req_dist_rec.task_no,
                      p_req_dist_rec.expenditure_type,
                      p_req_dist_rec.expenditure_org_name,
                      p_req_dist_rec.expenditure_item_date,
                      p_req_dist_rec.project_id,
                      p_req_dist_rec.task_id,
                      p_req_dist_rec.expenditure_organization_id,
                      l_return_status);

       IF l_return_status = 'E' THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_PA_INFO');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_PA_INFO');
        G_ERROR_COL := 'PROJECT ACCOUNTING COLUMNS';
    --    po_message_s.app_error('PO_RI_INVALID_PA_INFO');
        RAISE USER_ERROR;
      END IF;

      l_progress := 80.4;
     --Validation on PA if dest type is EXPENSE
     IF l_dest_type = 'EXPENSE' THEN
        pa_transactions_pub.validate_transaction(
                p_req_dist_rec.project_id,
                   p_req_dist_rec.task_id,
                 TO_DATE(p_req_dist_rec.expenditure_item_date,'YYYY/MM/DD'),
                 NVL(p_req_dist_rec.expenditure_type,l_dist_rec.expenditure_type),
                 NULL,
                 NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
             NVL(p_req_dist_rec.expenditure_organization_id,l_dist_rec.expenditure_organization_id),
            NULL,
            NULL,
             'POXRQERQ',
             l_line_rec.suggested_buyer_id,
             NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            l_msg_application,
            l_msg_type,
            l_msg_token1,
            l_msg_token2,
            l_msg_token3,
            l_msg_count ,
            l_return_status,
                     l_billable_flag,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
            );
         IF l_return_status IS NOT NULL THEN
            fnd_message.set_name ('PO','PO_RI_INVALID_PA_INFO');
            fnd_msg_pub.ADD;
            x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_PA_INFO');
            G_ERROR_COL := 'PROJECT TC COLUMNS';
            x_error_msg := l_return_status;
           -- po_message_s.app_error('PO_RI_INVALID_PA_INFO');
         END IF;
      ELSIF l_dest_type IN ('SHOP FLOOR','INVENTORY') THEN
          -- Call PO wrapper procedure to validate the PJM project
        PO_PROJECT_DETAILS_SV.validate_proj_references_wpr
               (p_inventory_org_id => l_line_rec.destination_organization_id,
                p_operating_unit   => l_line_rec.org_id,
                p_project_id       => p_req_dist_rec.project_id,
                p_task_id          => p_req_dist_rec.task_id,
                p_date1            => l_line_rec.need_by_date,
                p_date2            => NULL,
                p_calling_function => 'REQIMPORT',
                x_error_code       => l_val_proj_error_code,
                x_return_code      => l_val_proj_result);

        IF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_failure) THEN
            fnd_message.set_name ('PO','PO_RI_INVALID_PA_INFO');
            fnd_msg_pub.ADD;
            x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_PA_INFO');
            RAISE USER_ERROR;
        ELSIF (l_val_proj_result = PO_PROJECT_DETAILS_SV.pjm_validate_warning) THEN
            fnd_message.set_name ('PO','PO_RI_INVALID_PA_INFO');
            fnd_msg_pub.ADD;
            x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_PA_INFO');
            RAISE USER_ERROR;
        END IF;

       END IF;
    END IF;
  END IF;


  -- Change for Update API 18245197
  -- Once the result of update distribution has req_award_id value then execute isvalid_award.
  l_progress := 90.0;
  IF nvl(p_req_dist_rec.award_id,l_dist_rec.req_award_id) IS NOT NULL THEN
	 --No need to do the validation if -999999 since award will be covered as null.
	 IF p_req_dist_rec.award_id <> -999999 THEN
		 l_req_award_id := nvl(p_req_dist_rec.award_id,l_dist_rec.req_award_id);
		 l_project_id := nvl(p_req_dist_rec.project_id,l_dist_rec.project_id);
		 l_task_id := nvl(p_req_dist_rec.task_id,l_dist_rec.task_id);
         --Validate the final value in the distribution.
		 IF ((l_req_award_id <>  l_dist_rec.req_award_id) OR
			 (l_project_id <>l_dist_rec.project_id OR
			  l_task_id <> l_dist_rec.task_id)) THEN
			--no need to fire the validation if no change for the project/task/award combination.
			 isvalid_award(l_req_award_id,
							null,
							l_project_id,
							l_task_id,
							x_return_status);
			 IF x_return_status = 'E' THEN
				 x_error_msg :='Error in Award validation';
				 RAISE USER_ERROR;
			 ELSIF x_return_status = 'W' THEN
				 x_error_msg :='Invalid Award fror given requisition. Please entern valid award value.';
				 RAISE USER_ERROR;
			 END IF;
		 END IF;
	 END IF;
   END IF;

  l_progress := 90;
  IF p_req_dist_rec.gl_encumbered_date IS NOT NULL THEN
     BEGIN
         SELECT 'Y'
         INTO L_VALID
                      FROM  gl_period_statuses ps1, gl_period_statuses ps2
                     WHERE  ps1.application_id = 101
                       AND  ps1.set_of_books_id = l_sob_id
                       /* bug 5498063 <R12 GL PERIOD VALIDATION> START*/
					   /* AND  ps1.closing_status in ('O','F') */
                       AND ((  NVL(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y') = 'Y'
 	                               AND  ps1.closing_status IN ('O', 'F'))
 	                             OR
 	                         (NVL(FND_PROFILE.VALUE('PO_VALIDATE_GL_PERIOD'),'Y') = 'N'))
                       /* bug 5498063  <R12 GL PERIOD VALIDATION> END */
					   AND  TRUNC(p_req_dist_rec.gl_encumbered_date) BETWEEN
                                                    TRUNC (ps1.start_date)
                                                   AND
                                                    TRUNC (ps1.end_date)
                       AND  ps1.period_name = ps2.period_name
                       AND  ps2.application_id = 201
                       AND  ps2.closing_status = 'O'
                       AND  ps2.set_of_books_id = L_SOB_ID;


     EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_GL_DATE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_GL_DATE');
        G_ERROR_COL := 'GL_DATE';
        RAISE USER_ERROR;
     END;

   END IF;

  IF p_req_dist_rec.gl_encumbered_date IS NULL THEN
    IF p_req_dist_rec.action_flag = 'UPDATE' THEN
      p_req_dist_rec.gl_encumbered_date := l_dist_rec.gl_encumbered_date;
    ELSIF P_REQ_DIST_REC.action_flag = 'NEW' THEN
      IF nvl(l_req_enc_flag,'N') = 'Y' THEN
      p_req_dist_rec.gl_encumbered_date := SYSDATE;
      ELSE
      p_req_dist_rec.gl_encumbered_date := NULL;
      END IF;
    END IF;
  END IF;

  IF (p_req_dist_rec.oke_contract_line_num IS NOT NULL OR p_req_dist_rec.oke_contract_deliverable_num IS NOT NULL
      OR p_req_dist_rec.oke_contract_line_id IS NOT NULL OR p_req_dist_rec.oke_contract_deliverable_id IS NOT NULL)
  THEN
    IF l_line_rec.oke_contract_header_id IS NULL THEN
      x_error_msg := 'Invalid Contract line/Deliverable values..Please check';

      RAISE user_error;
    END IF;

    BEGIN
      SELECT ID
      INTO p_req_dist_rec.oke_contract_line_id
      FROM okc_k_lines_b
      WHERE dnz_chr_id = l_line_rec.oke_contract_header_id
      AND  (ID = p_req_dist_rec.oke_contract_line_id OR line_number = p_req_dist_rec.oke_contract_line_num);
   EXCEPTION
    WHEN OTHERS THEN
       x_error_msg := 'Invalid Contract Line Number';
       RAISE USER_ERROR;
   END;

   BEGIN
      SELECT deliverable_id
      INTO p_req_dist_rec.oke_contract_deliverable_id
      FROM oke_k_deliverables_b
      WHERE k_line_id = p_req_dist_rec.oke_contract_line_id
      AND  (deliverable_id = p_req_dist_rec.oke_contract_deliverable_id OR deliverable_num = p_req_dist_rec.oke_contract_deliverable_num);
   EXCEPTION
    WHEN OTHERS THEN
       x_error_msg := 'Invalid Contract deliverable Number';
       RAISE USER_ERROR;
   END;
  END IF;
  IF ( p_req_dist_rec.action_flag = 'UPDATE' AND ((l_line_rec.item_id IS NOT NULL) AND (p_req_dist_rec.code_combination_id IS NOT NULL
     OR p_req_dist_rec.accrual_account IS NOT NULL OR p_req_dist_rec.accrual_account_id IS NOT NULL
     OR p_Req_dist_rec.variance_account IS NOT NULL OR p_req_dist_rec.variance_account IS NOT NULL
     OR p_req_dist_rec.budget_account IS NOT NULL OR p_req_dist_rec.budget_account_id IS NOT NULL))) THEN
             x_error_msg := 'Charge Accounts updation is not allowed for item based requisition';
             x_return_status := 'E';
             RAISE user_error;
   ELSE
      charge_account_update(p_req_dist_rec,l_coa,x_error_msg,x_return_status);
   END IF;

  l_progress := 91;
  IF x_return_status ='E' THEN
    x_error_msg := 'Error in Charge account Update'||x_error_msg;
    RAISE user_error;
  END IF;

  IF   l_dist_rec.encumbered_flag ='Y' THEN
         l_progress := 92;

         check_dist_unreserve(p_req_dist_rec,x_error_msg,x_return_status);
         IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,'x_return_status',x_return_status);
            PO_LOG.stmt(d_module_base,l_progress,'x_error_msg',x_error_msg);
            IF x_return_Status = 'E' THEN
              RAISE USER_ERROR;
            END IF;
         END IF;
  END IF;
  x_return_status := 'S';
 EXCEPTION
 WHEN USER_ERROR THEN
      x_return_status := 'E';
      log_interface_errors(g_error_col,
                               x_error_msg,
                               p_req_dist_rec.req_header_id,
                               p_req_dist_rec.req_header_id,
                               NVL(p_req_dist_rec.req_line_num,l_line_rec.line_num),
                               NVL(p_req_dist_rec.distribution_num,l_dist_rec.distribution_num) );
      l_error_msg := 'Validation failure occured at Requisition '||
                     'No/Id: '||NVL(p_req_dist_rec.requisition_number,l_req_no)||' /'||p_req_dist_rec.req_header_id||
      '  Line /ID:'||NVL(p_req_dist_rec.req_line_num,l_line_rec.line_num)||' /'||p_req_dist_rec.req_line_id||
      '   Distribution NO/ID:'||NVL(p_req_dist_rec.distribution_num,l_dist_rec.distribution_num)||'/'||p_req_dist_rec.distribution_id;
      x_error_msg := SUBSTR(l_error_msg||x_error_msg,1,2000);
      po_message_s.add_exc_msg('Package',d_module_base,SUBSTR(x_error_msg,1,240));
     -- po_message_s.concat_fnd_messages_in_stack(Fnd_Msg_Pub.Count_Msg,x_error_msg);

 WHEN OTHERS THEN
   x_error_msg := SQLERRM;
   x_return_status := 'E';
   po_message_s.sql_error('validate_req_distribution','010',SQLCODE);
   RAISE;
END;

PROCEDURE check_dist_unreserve(p_req_dist_rec PO_REQUISITION_UPDATE_PUB.req_dist,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                               x_ret_code OUT NOCOPY  NUMBER) IS

CURSOR c_req_dist(p_req_line_id NUMBER,p_req_dist_id NUMBER)
IS
  SELECT  prd.req_line_quantity,
          prd.recovery_rate,
          prd.req_line_amount,
          prd.project_id,
          prd.task_id,
          prd.award_id,
          prd.expenditure_type,
          prd.expenditure_organization_id,
          prd.expenditure_item_date
    FROM po_requisition_lines prl,
         po_req_distributions prd
    WHERE prd.requisition_line_id = p_req_line_id
    AND  prd.distribution_id = p_req_dist_id;

 l_enc_cols c_req_dist%ROWTYPE;

l_return_status    VARCHAR2(10);
l_doc_level        VARCHAR2(15);
l_doc_level_id     NUMBER;
l_po_return_code   VARCHAR2(10);
l_online_report_id NUMBER;
l_dist_reserved_flag VARCHAR2(2);

l_module_name CONSTANT VARCHAR2(100) := 'get_charge_account_fun';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;

BEGIN

 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_dist_rec.req_line_id', p_req_dist_rec.req_line_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_dist_rec.distribution_id', p_req_dist_rec.distribution_id);
   END IF;

  d_progress := 10;

  OPEN c_req_dist(p_req_dist_rec.req_line_id,p_req_dist_rec.distribution_id);
  FETCH c_req_dist INTO l_enc_cols;
  --CLOSE c_req_dist;

  d_progress := 20;

  IF c_req_dist% NOTFOUND THEN
    x_error_msg := 'Error in fetching distribution details';
    x_ret_code := 'E';
    po_message_s.sql_error('check_dist_unreserve',20,SQLCODE);
    CLOSE c_req_dist;
    RETURN;
  END IF;

  CLOSE c_req_dist;

    l_doc_level := 'DISTRIBUTION';
    l_doc_level_id := p_req_dist_rec.distribution_id;


   PO_CORE_S.are_any_dists_reserved(
      p_doc_type => 'REQUISITION'
   ,  p_doc_level => l_doc_level
   ,  p_doc_level_id => l_doc_level_id
   ,  x_some_dists_reserved_flag => l_dist_reserved_flag
   );

  d_progress := 30;


    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_dist_reserved_flag',l_dist_reserved_flag);
    END IF;

   IF l_dist_reserved_flag = 'Y' THEN
     ---DISTRIBUTIONS

            IF PO_LOG.d_stmt THEN
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.req_line_quantity',l_enc_cols.req_line_quantity);
                 PO_LOG.stmt(d_module_base,d_progress,'p_req_dist_rec.req_line_quantity',p_req_dist_rec.req_line_quantity);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.req_line_amount',l_enc_cols.req_line_amount);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.project_id',l_enc_cols.project_id);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.task_id',l_enc_cols.task_id);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.award_id',l_enc_cols.award_id);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.expenditure_type',l_enc_cols.expenditure_type);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.expenditure_organization_id',l_enc_cols.expenditure_organization_id);
                 PO_LOG.stmt(d_module_base,d_progress,'l_enc_cols.expenditure_item_date',l_enc_cols.expenditure_item_date);
            END IF;

           IF  ( l_enc_cols.req_line_quantity <> p_req_dist_rec.req_line_quantity
            --     OR nvl(l_enc_cols.recovery_rate,-99999999) <> nvl(p_req_dist_rec.recovery_rate,-99999999)
                 OR l_enc_cols.req_line_amount <> p_req_dist_rec.req_line_amount
                 OR NVL(l_enc_cols.project_id,-1) <> NVL(p_req_dist_rec.project_id,-1)
                 OR NVL(l_enc_cols.task_id,-1) <> NVL(p_req_dist_rec.task_id,-1)
                 OR NVL(l_enc_cols.award_id,-1) <> NVL(p_req_dist_rec.award_id,-1)
                 OR NVL(l_enc_cols.expenditure_type,'XXXX') <> NVL(p_req_dist_rec.expenditure_type,'XXXX')
                 OR NVL(l_enc_cols.expenditure_organization_id,-1) <> NVL(p_req_dist_rec.expenditure_organization_id,-1)
                 OR l_enc_cols.expenditure_item_date <> p_req_dist_rec.expenditure_item_date
                 )
                THEN

               --Do unreserve
                 PO_DOCUMENT_FUNDS_PVT.do_unreserve(
                       x_return_status     => l_return_status
                    ,  p_doc_type          => 'REQUISITION'
                    ,  p_doc_subtype       => NULL
                    ,  p_doc_level         => l_doc_level
                    ,  p_doc_level_id      => l_doc_level_id
                    ,  p_use_enc_gt_flag   => 'N'
                    ,  p_validate_document => 'N'
                    ,  p_override_funds    => 'N'
                    ,  p_use_gl_date       => 'U'
                    ,  p_override_date     => SYSDATE
                    ,  p_employee_id       => NULL
                    ,  x_po_return_code    => l_po_return_code
                    ,  x_online_report_id  => l_online_report_id
                    );


              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'l_online_report_id',l_online_report_id);
                PO_LOG.stmt(d_module_base,d_progress,'l_po_return_code',l_po_return_code);
              END IF;
         END IF;
   END IF;

   IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  x_error_msg := 'Unhandled Exception'|| SQLERRM;
  X_RET_CODE := 'E';
  po_message_s.sql_error('check_unique','010',SQLCODE);
  RAISE;
END;

PROCEDURE check_lines_unreserve(p_req_line_rec PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                x_ret_code OUT NOCOPY  VARCHAR2) IS

 CURSOR c_req_line (p_req_line_id NUMBER,p_req_hdr_id NUMBER)
 IS
 SELECT *
 FROM po_requisition_lines
 WHERE requisition_line_id = p_req_line_id
 AND  requisition_header_id = p_req_hdr_id;

 l_db_reqline c_req_line%ROWTYPE;
 l_bpa_header_id NUMBER;
 l_return_status    VARCHAR2(10);
 l_doc_level        VARCHAR2(15);
 l_doc_level_id     NUMBER;
 l_po_return_code   VARCHAR2(10);
 l_online_report_id NUMBER;
 l_dist_reserved_flag VARCHAR2(2);
 l_source_enc_flag VARCHAR2(10);

 l_module_name CONSTANT VARCHAR2(100) := 'check_lines_unreserve';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line_rec.requisition_line_id', p_req_line_rec.requisition_line_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line_rec.requisition_header_id', p_req_line_rec.requisition_header_id);
   END IF;


   l_doc_level := 'LINE';
   l_doc_level_id := p_req_line_rec.requisition_line_id;

  PO_CORE_S.are_any_dists_reserved(
       p_doc_type => 'REQUISITION'
    ,  p_doc_level => l_doc_level
    ,  p_doc_level_id => l_doc_level_id
    ,  x_some_dists_reserved_flag => l_dist_reserved_flag
   );

   IF NVL(l_dist_reserved_flag,'N')  <> 'Y' THEN
       IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,d_progress,'No eligible distributions exists for unreserve l_dist_reserved_flag',l_dist_reserved_flag);
    END IF;
   ELSE

    OPEN c_req_line(p_req_line_rec.requisition_line_id,p_req_line_rec.requisition_header_id);
    FETCH c_req_line INTO l_db_reqline;
    CLOSE c_req_line;

     l_bpa_header_id := l_db_reqline.blanket_po_header_id;

     IF (l_bpa_header_id IS NOT NULL) THEN
          PO_DOCUMENT_FUNDS_PVT.is_agreement_encumbered(
             x_return_status               => l_return_status
          ,  p_agreement_id                => l_bpa_header_id
          ,  x_agreement_encumbered_flag   => l_source_enc_flag
          );
     ELSE
          l_source_enc_flag := 'N';
     END IF;

    IF (     p_req_line_rec.unit_price <> l_db_reqline.unit_price
              OR p_req_line_rec.amount <> l_db_reqline.amount
              OR p_req_line_rec.unit_meas_lookup_code <> l_db_reqline.unit_meas_lookup_code
              OR p_req_line_rec.destination_organization_id <> l_db_reqline.destination_organization_id
              OR p_req_line_rec.deliver_to_location_id <> l_db_reqline.deliver_to_location_id
              OR p_req_line_rec.vendor_id <> l_db_reqline.vendor_id
              OR p_req_line_rec.vendor_site_id <> l_db_reqline.vendor_site_id
              OR  p_req_line_rec.need_by_date <> l_db_reqline.need_by_date
              OR l_source_enc_flag = 'Y'
        ) THEN

                   PO_DOCUMENT_FUNDS_PVT.do_unreserve(
                       x_return_status     => l_return_status
                    ,  p_doc_type          => 'REQUISITION'
                    ,  p_doc_subtype       => NULL
                    ,  p_doc_level         => l_doc_level
                    ,  p_doc_level_id      => l_doc_level_id
                    ,  p_use_enc_gt_flag   => 'N'
                    ,  p_validate_document => 'N'
                    ,  p_override_funds    => 'N'
                    ,  p_use_gl_date       => 'U'
                    ,  p_override_date     => SYSDATE
                    ,  p_employee_id       => NULL
                    ,  x_po_return_code    => l_po_return_code
                    ,  x_online_report_id  => l_online_report_id
                    );


              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,d_progress,'l_online_report_id',l_online_report_id);
                PO_LOG.stmt(d_module_base,d_progress,'l_po_return_code',l_po_return_code);
              END IF;
     END IF;
 END IF;

  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
EXCEPTION
WHEN OTHERS THEN
  x_error_msg := 'Unhandled Exception'|| SQLERRM;
  X_RET_CODE := 'E';
  po_message_s.sql_error('check_unique','010',SQLCODE);
  RAISE;
END;

PROCEDURE  build_chargeac_whereclause
(p_segment_name  IN VARCHAR2,
  p_segment_value IN VARCHAR2,
  x_sql IN OUT NOCOPY VARCHAR2
) IS

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_REQUISITION_VALIDATE_PVT';
  d_api_name CONSTANT VARCHAR2(30) := 'build_chargeac_whereclause';
  d_module   CONSTANT VARCHAR2(255) := G_PKG_NAME  || d_api_name || '.';
  d_position NUMBER;

BEGIN

  IF (p_segment_value IS NOT NULL) THEN
    x_sql := x_sql || ' AND GCC.' || p_segment_name || ' = :' || p_segment_name;
  ELSE
    -- if value is null, originally we do not need bind variable. However,
    -- to make coding simple we are still appending a dummy NVL operation
    -- just to make sure that we always have the same number of bind variables.

    x_sql := x_sql || ' AND NVL(:' || p_segment_name || ', GCC.' ||
             p_segment_name || ') IS NULL';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      G_PKG_NAME  ,
      d_api_name || '.' || d_position,SQLCODE||SQLERRM
    );
    RAISE;
END build_chargeac_whereclause;

PROCEDURE charge_account_update(p_req_dist IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist
                               ,p_chart_of_accounts_id IN NUMBER
                             -- ,x_account_id OUT NOCOPY  NUMBER
                               ,x_error_msg OUT NOCOPY  VARCHAR2
                               ,x_return_status OUT NOCOPY  VARCHAR2)
IS

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_REQUISITION_VALIDATE_PVT';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXRQVLB.pls';
  -- Logging global constants
  D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);

G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

 d_api_name CONSTANT VARCHAR2(30) := 'charge_account_update';
 d_module   CONSTANT VARCHAR2(255) := G_PKG_NAME || d_api_name || '.';
 d_position NUMBER;
 e_chargeac_error EXCEPTION;
 l_error_msg VARCHAR2(1000);
 l_sql VARCHAR2(4000);
 x_account_id NUMBER;
 x_budget_account_id NUMBER;
 x_accrual_account_id NUMBER;
 x_variance_account_id NUMBER;
 l_line_rec PO_REQUISITION_UPDATE_PUB.req_line_rec_type;

BEGIN


  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, ' p_chart_of_accounts_id ', p_chart_of_accounts_id);
  END IF;


  IF p_req_dist.code_combination_id IS NOT NULL THEN
    BEGIN
     SELECT code_combination_id
     INTO x_account_id
     FROM gl_code_combinations gcc
      WHERE gcc.code_combination_id = p_req_dist.code_combination_id
     AND gcc.enabled_flag = 'Y'
     AND TRUNC (NVL (p_req_dist.gl_encumbered_date, SYSDATE))
             BETWEEN TRUNC (NVL (start_date_active,
                                 NVL (p_req_dist.gl_encumbered_date, SYSDATE)
                                )
                           )
                 AND TRUNC (NVL (end_date_active,
                                 NVL (p_req_dist.gl_encumbered_date, SYSDATE)
                                )
                           )
      AND gcc.detail_posting_allowed_flag = 'Y'
      AND gcc.chart_of_accounts_id = p_chart_of_accounts_id
      AND gcc.summary_flag = 'N';
    EXCEPTION
      WHEN OTHERS THEN
        IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'Not a valid ccid');
       END IF;
       fnd_message.set_name ('PO','PO_RI_INVALID_CHARGE_ACC_ID');
       fnd_msg_pub.ADD;
     RAISE e_chargeac_error;
    END;
  END IF;
  /*ELSE
   IF (p_req_dist.account_segment1  IS NULL AND p_req_dist.account_segment2  IS NULL AND
       p_req_dist.account_segment3  IS NULL AND p_req_dist.account_segment4  IS NULL AND
       p_req_dist.account_segment5  IS NULL AND p_req_dist.account_segment6  IS NULL AND
       p_req_dist.account_segment7  IS NULL AND p_req_dist.account_segment8  IS NULL AND
       p_req_dist.account_segment9  IS NULL AND p_req_dist.account_segment10 IS NULL AND
       p_req_dist.account_segment11 IS NULL AND p_req_dist.account_segment12 IS NULL AND
       p_req_dist.account_segment13 IS NULL AND p_req_dist.account_segment14 IS NULL AND
       p_req_dist.account_segment15 IS NULL AND p_req_dist.account_segment16 IS NULL AND
       p_req_dist.account_segment17 IS NULL AND p_req_dist.account_segment18 IS NULL AND
       p_req_dist.account_segment19 IS NULL AND p_req_dist.account_segment20 IS NULL AND
       p_req_dist.account_segment21 IS NULL AND p_req_dist.account_segment22 IS NULL AND
       p_req_dist.account_segment23 IS NULL AND p_req_dist.account_segment24 IS NULL AND
       p_req_dist.account_segment25 IS NULL AND p_req_dist.account_segment26 IS NULL AND
       p_req_dist.account_segment27 IS NULL AND p_req_dist.account_segment28 IS NULL AND
       p_req_dist.account_segment29 IS NULL AND p_req_dist.account_segment30 IS NULL) THEN

     -- No segment has been provided
     RETURN;
   END IF;
    l_sql := 'SELECT GCC.code_combination_id FROM gl_code_combinations GCC ' ||
              'WHERE GCC.chart_of_accounts_id =  :p_chart_of_accounts_id ';

     build_chargeac_whereclause('segment1', p_req_dist.account_segment1, l_sql);
     build_chargeac_whereclause('segment2', p_req_dist.account_segment2, l_sql);
     build_chargeac_whereclause('segment3', p_req_dist.account_segment3, l_sql);
     build_chargeac_whereclause('segment4', p_req_dist.account_segment4, l_sql);
     build_chargeac_whereclause('segment5', p_req_dist.account_segment5, l_sql);
     build_chargeac_whereclause('segment6', p_req_dist.account_segment6, l_sql);
     build_chargeac_whereclause('segment7', p_req_dist.account_segment7, l_sql);
     build_chargeac_whereclause('segment8', p_req_dist.account_segment8, l_sql);
     build_chargeac_whereclause('segment9', p_req_dist.account_segment9, l_sql);
     build_chargeac_whereclause('segment10', p_req_dist.account_segment10, l_sql);
     build_chargeac_whereclause('segment11', p_req_dist.account_segment11, l_sql);
     build_chargeac_whereclause('segment12', p_req_dist.account_segment12, l_sql);
     build_chargeac_whereclause('segment13', p_req_dist.account_segment13, l_sql);
     build_chargeac_whereclause('segment14', p_req_dist.account_segment14, l_sql);
     build_chargeac_whereclause('segment15', p_req_dist.account_segment15, l_sql);
     build_chargeac_whereclause('segment16', p_req_dist.account_segment16, l_sql);
     build_chargeac_whereclause('segment17', p_req_dist.account_segment17, l_sql);
     build_chargeac_whereclause('segment18', p_req_dist.account_segment18, l_sql);
     build_chargeac_whereclause('segment19', p_req_dist.account_segment19, l_sql);
     build_chargeac_whereclause('segment20', p_req_dist.account_segment20, l_sql);
     build_chargeac_whereclause('segment21', p_req_dist.account_segment21, l_sql);
     build_chargeac_whereclause('segment22', p_req_dist.account_segment22, l_sql);
     build_chargeac_whereclause('segment23', p_req_dist.account_segment23, l_sql);
     build_chargeac_whereclause('segment24', p_req_dist.account_segment24, l_sql);
     build_chargeac_whereclause('segment25', p_req_dist.account_segment25, l_sql);
     build_chargeac_whereclause('segment26', p_req_dist.account_segment26, l_sql);
     build_chargeac_whereclause('segment27', p_req_dist.account_segment27, l_sql);
     build_chargeac_whereclause('segment28', p_req_dist.account_segment28, l_sql);
     build_chargeac_whereclause('segment29', p_req_dist.account_segment29, l_sql);
     build_chargeac_whereclause('segment30', p_req_dist.account_segment30, l_sql);

     d_position := 20;

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, ' stmt to generate acct id: ', l_sql);
      END IF;

     BEGIN
       EXECUTE IMMEDIATE l_sql INTO x_account_id
       USING p_chart_of_accounts_id,
             p_req_dist.account_segment1,  p_req_dist.account_segment2,
             p_req_dist.account_segment3,  p_req_dist.account_segment4,
             p_req_dist.account_segment5,  p_req_dist.account_segment6,
             p_req_dist.account_segment7,  p_req_dist.account_segment8,
             p_req_dist.account_segment9,  p_req_dist.account_segment10,
             p_req_dist.account_segment11, p_req_dist.account_segment12,
             p_req_dist.account_segment13, p_req_dist.account_segment14,
             p_req_dist.account_segment15, p_req_dist.account_segment16,
             p_req_dist.account_segment17, p_req_dist.account_segment18,
             p_req_dist.account_segment19, p_req_dist.account_segment20,
             p_req_dist.account_segment21, p_req_dist.account_segment22,
             p_req_dist.account_segment23, p_req_dist.account_segment24,
             p_req_dist.account_segment25, p_req_dist.account_segment26,
             p_req_dist.account_segment27, p_req_dist.account_segment28,
             p_req_dist.account_segment29, p_req_dist.account_segment30;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'cannot find account id based on segments provided');
       END IF;
       fnd_message.set_name ('PO','PO_RI_INVALID_ACCRUAL_ACC_ID');
     fnd_msg_pub.ADD;
     RAISE e_chargeac_error;
     END;

 END IF; */
  d_position := 30;

  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module,d_position,'x_account_id',x_account_id);
   END IF;

   IF p_req_dist.budget_account_id IS NOT NULL THEN
     x_budget_account_id := get_cc_id(p_req_dist.budget_account_id,p_req_dist.gl_encumbered_date,p_chart_of_accounts_id);
     IF x_budget_account_id = -1 THEN
           RAISE e_chargeac_error;
     END IF;
  END IF;

    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module,d_position,'p_req_dist.budget_account_id',p_req_dist.budget_account_id);
        PO_LOG.stmt(d_module,d_position,'p_req_dist.budget_account',p_req_dist.budget_account);
        PO_LOG.stmt(d_module,d_position,'p_req_dist.accrual_account_id',p_req_dist.accrual_account_id);
        PO_LOG.stmt(d_module,d_position,'p_req_dist.accrual_account',p_req_dist.accrual_account);
        PO_LOG.stmt(d_module,d_position,'p_req_dist.variance_account_id',p_req_dist.variance_account_id);
        PO_LOG.stmt(d_module,d_position,'p_req_dist.variance_account',p_req_dist.variance_account);

   END IF;

  IF p_req_dist.charge_account_id IS NULL AND p_Req_dist.charge_account IS NOT NULL THEN
   BEGIN
   SELECT CODE_COMBINATION_ID
   INTO p_req_dist.charge_account_id
   FROM gl_code_combinations_kfv
   WHERE concatenated_segments = p_req_dist.charge_account;

   --x_charge_account_id := p_req_dist.charge_account_id;
   p_req_dist.code_combination_id := p_req_dist.charge_account_id;

   EXCEPTION
   WHEN OTHERS THEN
     x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_CHARGE_ACC_ID');
     g_error_col := 'CHARGE ACCOUNT COLUMNS';
     RAISE e_chargeac_error;
   END;
  END IF;

  IF p_req_dist.budget_account_id IS NULL AND p_req_dist.budget_account IS NOT NULL THEN
  BEGIN
   SELECT CODE_COMBINATION_ID
   INTO p_req_dist.budget_account_id
   FROM gl_code_combinations_kfv
   WHERE concatenated_segments = p_req_dist.budget_account;

   x_budget_account_id := p_req_dist.budget_account_id;

   EXCEPTION
   WHEN OTHERS THEN
     x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_BUDGET_ACC_ID');
     g_error_col := 'BUDGET ACCOUNT COLUMNS';
     RAISE e_chargeac_error;
   END;
  END IF;

  IF p_req_dist.accrual_account_id IS NOT NULL THEN
     x_accrual_account_id := get_cc_id(p_req_dist.accrual_account_id,p_req_dist.gl_encumbered_date,p_chart_of_accounts_id);
     IF x_accrual_account_id = -1 THEN
           RAISE e_chargeac_error;
     END IF;
  END IF;

  IF p_req_dist.accrual_account_id IS NULL AND p_req_dist.accrual_account IS NOT NULL THEN
  BEGIN
   SELECT CODE_COMBINATION_ID
   INTO p_req_dist.accrual_account_id
   FROM gl_code_combinations_kfv
   WHERE concatenated_segments = p_req_dist.accrual_account;

   x_accrual_account_id := p_req_dist.accrual_account_id;

   EXCEPTION
   WHEN OTHERS THEN
     g_error_col := 'ACCRUAL ACCOUNT COLUMNS';
      x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ACCRUAL_ACC_ID');
     RAISE e_chargeac_error;
   END;
  END IF;

  IF p_req_dist.variance_account_id IS NOT NULL THEN
     x_variance_account_id := get_cc_id(p_req_dist.variance_account_id,p_req_dist.gl_encumbered_date,p_chart_of_accounts_id);
     IF x_variance_account_id = -1 THEN
           RAISE e_chargeac_error;
     END IF;
  END IF;

  IF p_req_dist.variance_account_id IS NULL AND p_req_dist.variance_account IS NOT NULL THEN
  BEGIN
   SELECT CODE_COMBINATION_ID
   INTO p_req_dist.variance_account_id
   FROM gl_code_combinations_kfv
   WHERE concatenated_segments = p_req_dist.variance_account;

   x_variance_account_id := p_req_dist.variance_account_id;

   EXCEPTION
   WHEN OTHERS THEN
     x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_VARIANCE_ACC_ID');
     g_error_col := 'VARIANCE ACCOUNT COLUMNS';
     RAISE e_chargeac_error;
   END;
  END IF;
  --No Need to call account generator if the values are passed
  IF (x_budget_account_id IS NOT NULL AND x_accrual_account_id IS NOT NULL AND x_variance_account_id IS NOT NULL) THEN
     RETURN;
  END IF;

 --Call account generator only if any related fields gets changed
 IF (p_req_dist.code_combination_id IS NOT NULL OR p_req_dist.project_id IS NOT NULL OR p_req_dist.task_id IS NOT NULL
     OR p_req_dist.award_id IS NOT NULL OR p_req_dist.expenditure_item_date IS NOT NULL OR p_req_dist.expenditure_organization_id IS NOT NULL
    OR p_req_dist.expenditure_type IS NOT NULL) THEN
      call_account_generator(p_req_dist,l_line_rec,p_req_dist.coa_id,x_account_id,l_error_msg,x_return_status);
 END IF;

 d_position := 40;

  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module,d_position,'x_return_status',x_return_status);
   END IF;

 IF x_return_status = 'E' THEN
     x_error_msg := l_error_msg;
      RAISE e_chargeac_error;

  END IF;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

 EXCEPTION
    WHEN e_chargeac_error THEN
     LOG_INTERFACE_ERRORS(g_error_col ,
                               x_error_msg ,
                               p_req_dist.req_header_id ,
                               'PO_REQ_DISTRIBUTIONS_ALL' ,
                               p_req_dist.req_line_id ,
                               p_req_dist.distribution_id ) ;
     PO_MESSAGE_S.add_exc_msg
     (
      g_pkg_name,
      d_api_name || '.' || d_position,x_error_msg
      );


   WHEN OTHERS THEN
     PO_MESSAGE_S.add_exc_msg
     (
       p_pkg_name => g_pkg_name,
       p_procedure_name => d_api_name || '.' || d_position
     );
     RAISE;
END;

PROCEDURE call_account_generator(p_req_dist_rec IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_dist,
                                 p_req_line IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                 p_coa_id NUMBER,
                                 p_ccid IN OUT NOCOPY NUMBER,
                                 x_error_msg OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2
                                 )
IS

l_rowid ROWID;
   CURSOR c_req_data_u(p_req_line_id NUMBER,p_req_dist_id NUMBER,p_req_hdr_id NUMBER)
   IS SELECT prd.ROWID, prl.CATEGORY_ID,
   prl.DESTINATION_TYPE_CODE,
   PRl.DELIVER_TO_LOCATION_ID,
   PRl.DESTINATION_ORGANIZATION_ID,
   prl.DESTINATION_SUBINVENTORY,
   PRD.EXPENDITURE_TYPE,
   PRD.EXPENDITURE_ORGANIZATION_ID,
   PRD.EXPENDITURE_ITEM_DATE,
   PRl.ITEM_ID,
   PRl.LINE_TYPE_ID,
   PRh.PREPARER_ID,
   PRD.PROJECT_ID,
   PRl.DOCUMENT_TYPE_CODE,
   PRl.SOURCE_TYPE_CODE,
   PRl.SOURCE_ORGANIZATION_ID,
   PRl.SOURCE_SUBINVENTORY,
   PRD.TASK_ID,
   PRd.AWARD_ID,
      NULL,
   PRl.vendor_ID,
   PRl.VENDOR_SITE_ID,
   PRl.WIP_ENTITY_ID,
   PRl.WIP_LINE_ID,
   PRl.WIP_REPETITIVE_SCHEDULE_ID,
   PRl.WIP_OPERATION_SEQ_NUM,
   PRl.WIP_RESOURCE_SEQ_NUM,
   fsp.req_ENCUMBRANCE_FLAG,
   PRD.GL_encumbered_DATE,
   prh.ATTRIBUTE1, prh.ATTRIBUTE2, prh.ATTRIBUTE3, prh.ATTRIBUTE4, prh.ATTRIBUTE5,
   prh.ATTRIBUTE6, prh.ATTRIBUTE7, prh.ATTRIBUTE8, prh.ATTRIBUTE9, prh.ATTRIBUTE10,
   prh.ATTRIBUTE11, prh.ATTRIBUTE12, prh.ATTRIBUTE13, prh.ATTRIBUTE14, prh.ATTRIBUTE15,
   prl.ATTRIBUTE1, prl.ATTRIBUTE2, prl.ATTRIBUTE3, prl.ATTRIBUTE4, prl.ATTRIBUTE5,
   prl.ATTRIBUTE6, prl.ATTRIBUTE7, prl.ATTRIBUTE8, prl.ATTRIBUTE9, prl.ATTRIBUTE10,
   prl.ATTRIBUTE11, prl.ATTRIBUTE12, prl.ATTRIBUTE13, prl.ATTRIBUTE14, prl.ATTRIBUTE15,
   prd.ATTRIBUTE1, prd.ATTRIBUTE2, prd.ATTRIBUTE3, prd.ATTRIBUTE4, prd.ATTRIBUTE5,
   prd.ATTRIBUTE6, prd.ATTRIBUTE7, prd.ATTRIBUTE8, prd.ATTRIBUTE9, prd.ATTRIBUTE10,
   prd.ATTRIBUTE11, prd.ATTRIBUTE12, prd.ATTRIBUTE13, prd.ATTRIBUTE14, prd.ATTRIBUTE15,
   PRl.UNIT_PRICE,
   p_req_dist_rec.BUDGET_ACCOUNT_ID,
   p_req_dist_rec.ACCRUAL_ACCOUNT_ID,
   p_req_dist_rec.VARIANCE_ACCOUNT_ID
   FROM po_requisition_lines prl,
        po_req_distributions prd,
     po_requisition_headers prh,
     financials_system_parameters fsp
   WHERE prd.requisition_line_id = prl.requisition_line_id
   AND   prl.requisition_header_id = prh.requisition_header_id
   AND   prh.requisition_header_id = p_req_hdr_id
   AND prl.requisition_line_id = p_req_line_id
   AND prd.distribution_id = p_req_dist_id;

   CURSOR c_req_data_n(p_req_line_id NUMBER,p_req_hdr_id NUMBER)
   IS SELECT prl.CATEGORY_ID,
   prl.DESTINATION_TYPE_CODE,
   PRl.DELIVER_TO_LOCATION_ID,
   PRl.DESTINATION_ORGANIZATION_ID,
   prl.DESTINATION_SUBINVENTORY,
   p_req_dist_rec.EXPENDITURE_TYPE,
   p_req_dist_rec.EXPENDITURE_ORGANIZATION_ID,
   p_req_dist_rec.EXPENDITURE_ITEM_DATE,
   PRl.ITEM_ID,
   PRl.LINE_TYPE_ID,
   PRh.PREPARER_ID,
   p_req_dist_rec.PROJECT_ID,
   PRl.DOCUMENT_TYPE_CODE,
   PRl.SOURCE_TYPE_CODE,
   PRl.SOURCE_ORGANIZATION_ID,
   PRl.SOURCE_SUBINVENTORY,
   p_req_dist_rec.TASK_ID,
   p_req_dist_rec.AWARD_ID,
      NULL,
   PRl.vendor_ID,
   PRl.VENDOR_SITE_ID,
   PRl.WIP_ENTITY_ID,
   PRl.WIP_LINE_ID,
   PRl.WIP_REPETITIVE_SCHEDULE_ID,
   PRl.WIP_OPERATION_SEQ_NUM,
   PRl.WIP_RESOURCE_SEQ_NUM,
   fsp.req_encumbrance_flag,
   p_req_dist_rec.GL_encumbered_DATE,
   prh.ATTRIBUTE1, prh.ATTRIBUTE2, prh.ATTRIBUTE3, prh.ATTRIBUTE4, prh.ATTRIBUTE5,
   prh.ATTRIBUTE6, prh.ATTRIBUTE7, prh.ATTRIBUTE8, prh.ATTRIBUTE9, prh.ATTRIBUTE10,
   prh.ATTRIBUTE11, prh.ATTRIBUTE12, prh.ATTRIBUTE13, prh.ATTRIBUTE14, prh.ATTRIBUTE15,
   prl.ATTRIBUTE1, prl.ATTRIBUTE2, prl.ATTRIBUTE3, prl.ATTRIBUTE4, prl.ATTRIBUTE5,
   prl.ATTRIBUTE6, prl.ATTRIBUTE7, prl.ATTRIBUTE8, prl.ATTRIBUTE9, prl.ATTRIBUTE10,
   prl.ATTRIBUTE11, prl.ATTRIBUTE12, prl.ATTRIBUTE13, prl.ATTRIBUTE14, prl.ATTRIBUTE15,
   p_req_dist_rec.ATTRIBUTE1, p_req_dist_rec.ATTRIBUTE2, p_req_dist_rec.ATTRIBUTE3, p_req_dist_rec.ATTRIBUTE4, p_req_dist_rec.ATTRIBUTE5,
   p_req_dist_rec.ATTRIBUTE6, p_req_dist_rec.ATTRIBUTE7, p_req_dist_rec.ATTRIBUTE8, p_req_dist_rec.ATTRIBUTE9, p_req_dist_rec.ATTRIBUTE10,
   p_req_dist_rec.ATTRIBUTE11, p_req_dist_rec.ATTRIBUTE12, p_req_dist_rec.ATTRIBUTE13, p_req_dist_rec.ATTRIBUTE14, p_req_dist_rec.ATTRIBUTE15,
   PRl.UNIT_PRICE,
   p_req_dist_rec.BUDGET_ACCOUNT_ID,
   p_req_dist_rec.ACCRUAL_ACCOUNT_ID,
   p_req_dist_rec.VARIANCE_ACCOUNT_ID
   FROM po_requisition_lines prl,
     po_requisition_headers prh,
     financials_system_parameters fsp
   WHERE prl.requisition_header_id = prh.requisition_header_id
   AND   prh.requisition_header_id = p_req_hdr_id
   AND prl.requisition_line_id = p_req_line_id;

    l_category_id NUMBER;
  l_destination_type_code VARCHAR2(150);
  l_deliver_to_location_id NUMBER;
  l_destation_organization_id NUMBER;
  l_destination_subinventory VARCHAR2(150);
  l_i_expenditure_type VARCHAR2(150);
  l_expenditure_organization_id NUMBER;
  l_expenditure_item_date DATE;
  l_item_id NUMBER;
  l_line_type_id NUMBER;
  l_preparer_id NUMBER;
  l_i_project_id NUMBER;
  l_document_type_code VARCHAR2(150);

  l_source_type_code VARCHAR2(150);
  l_source_organization_id NUMBER;
  l_source_subventory VARCHAR2(150);
  l_i_task_id NUMBER;
  l_award_set_id NUMBER;
  l_deliver_to_requestor_id NUMBER;
  l_suggested_vendor_id NUMBER;
  l_suggested_vendor_site_id NUMBER;
  l_wip_entity_id NUMBER;
  l_wip_line_id NUMBER;
  l_wip_repetitive_schedule_id NUMBER;
  l_wip_operation_seq_num NUMBER;
  l_wip_resource_seq_num NUMBER;
  l_prevent_encumbrance_flag VARCHAR2(15);
  l_gl_date DATE;
  l_header_att1 VARCHAR2(150);
  l_header_att2 VARCHAR2(150);
  l_header_att3 VARCHAR2(150);
  l_header_att4 VARCHAR2(150);
  l_header_att5 VARCHAR2(150);
  l_header_att6 VARCHAR2(150);
  l_header_att7 VARCHAR2(150);
  l_header_att8 VARCHAR2(150);
  l_header_att9 VARCHAR2(150);
  l_header_att10 VARCHAR2(150);
  l_header_att11 VARCHAR2(150);
  l_header_att12 VARCHAR2(150);
  l_header_att13 VARCHAR2(150);
  l_header_att14 VARCHAR2(150);
  l_header_att15 VARCHAR2(150);
  l_line_att1 VARCHAR2(150);
  l_line_att2 VARCHAR2(150);
  l_line_att3 VARCHAR2(150);
  l_line_att4 VARCHAR2(150);
  l_line_att5 VARCHAR2(150);
  l_line_att6 VARCHAR2(150);
  l_line_att7 VARCHAR2(150);
  l_line_att8 VARCHAR2(150);
  l_line_att9 VARCHAR2(150);
  l_line_att10 VARCHAR2(150);
  l_line_att11 VARCHAR2(150);
  l_line_att12 VARCHAR2(150);
  l_line_att13 VARCHAR2(150);
  l_line_att14 VARCHAR2(150);
  l_line_att15 VARCHAR2(150);
  l_dist_att1 VARCHAR2(150);
  l_dist_att2 VARCHAR2(150);
  l_dist_att3 VARCHAR2(150);
  l_dist_att4 VARCHAR2(150);
  l_dist_att5 VARCHAR2(150);
  l_dist_att6 VARCHAR2(150);
  l_dist_att7 VARCHAR2(150);
  l_dist_att8 VARCHAR2(150);
  l_dist_att9 VARCHAR2(150);
  l_dist_att10 VARCHAR2(150);
  l_dist_att11 VARCHAR2(150);
  l_dist_att12 VARCHAR2(150);
  l_dist_att13 VARCHAR2(150);
  l_dist_att14 VARCHAR2(150);
  l_dist_att15 VARCHAR2(150);
  l_unit_price NUMBER;
  l_batch_id NUMBER;
  l_transaction_id NUMBER;
  ----
  l_budget_account_id NUMBER;
  l_accrual_account_id NUMBER;
  l_variance_account_id NUMBER;
  result                    VARCHAR2(1);
  l_o_charge_success        VARCHAR2(1);
  l_o_budget_success        VARCHAR2(1);
  l_o_accrual_success       VARCHAR2(1);
  l_o_variance_success      VARCHAR2(1);
  l_o_code_combation_id     NUMBER;
  l_o_budget_account_id     NUMBER;
  l_o_accrual_account_id    NUMBER;
  l_o_variance_account_id   NUMBER;
  l_o_charge_account_flex   VARCHAR2(2000);
  l_o_budget_account_flex   VARCHAR2(2000);
  l_o_accrual_account_flex  VARCHAR2(2000);
  l_o_variance_account_flex VARCHAR2(2000);
  l_o_charge_account_desc   VARCHAR2(2000);
  l_o_budget_account_desc   VARCHAR2(2000);
  l_o_accrual_account_desc  VARCHAR2(2000);
  l_o_variance_account_desc VARCHAR2(2000);
  l_o_wf_itemkey            VARCHAR2(500);
  l_o_new_combation         VARCHAR2(500);
  l_o_FB_ERROR_MSG          VARCHAR2(1000);
BEGIN

 IF p_req_dist_rec.action_flag = 'UPDATE' THEN

 OPEN c_req_data_u(p_req_dist_rec.req_line_id,p_req_dist_rec.distribution_id,p_req_dist_rec.req_header_id);
 FETCH c_req_data_u INTO   l_rowid,
        l_category_id,
        l_destination_type_code,
        l_deliver_to_location_id,
        l_destation_organization_id,
        l_destination_subinventory,
        l_i_expenditure_type,
        l_expenditure_organization_id,
        l_expenditure_item_date,
        l_item_id,
        l_line_type_id,
        l_preparer_id,
        l_i_project_id,
        l_document_type_code,
        l_source_type_code,
        l_source_organization_id,
        l_source_subventory,
        l_i_task_id,
        l_award_set_id,
        l_deliver_to_requestor_id,
        l_suggested_vendor_id,
        l_suggested_vendor_site_id,
        l_wip_entity_id,
        l_wip_line_id,
        l_wip_repetitive_schedule_id,
        l_wip_operation_seq_num,
        l_wip_resource_seq_num,
        l_prevent_encumbrance_flag,
        l_gl_date,
        l_header_att1,
        l_header_att2,
        l_header_att3,
        l_header_att4 ,
        l_header_att5,
        l_header_att6,
        l_header_att7,
        l_header_att8,
        l_header_att9,
        l_header_att10,
        l_header_att11,
        l_header_att12,
        l_header_att13,
        l_header_att14,
        l_header_att15,
        l_line_att1,
        l_line_att2,
        l_line_att3,
        l_line_att4,
        l_line_att5,
        l_line_att6,
        l_line_att7,
        l_line_att8,
        l_line_att9,
        l_line_att10,
        l_line_att11,
        l_line_att12,
        l_line_att13,
        l_line_att14,
        l_line_att15,
        l_dist_att1,
        l_dist_att2,
        l_dist_att3,
        l_dist_att4,
        l_dist_att5,
        l_dist_att6,
        l_dist_att7,
        l_dist_att8,
        l_dist_att9,
        l_dist_att10,
        l_dist_att11,
        l_dist_att12,
        l_dist_att13,
        l_dist_att14,
        l_dist_att15,
        l_unit_price,
        l_budget_account_id,
        l_accrual_account_id,
        l_variance_account_id ;

        l_o_code_combation_id := p_req_dist_rec.code_combination_id;
        l_o_budget_account_id := p_req_dist_rec.budget_account_id;
        l_o_accrual_account_id := p_req_dist_rec.accrual_account_id;
        l_o_variance_account_id := p_req_dist_rec.variance_account_id;
    CLOSE c_req_data_u;
   ELSE
     OPEN c_req_data_n(p_req_dist_rec.req_line_id,p_req_dist_rec.req_header_id);
     FETCH c_req_data_n INTO
        l_category_id,
        l_destination_type_code,
        l_deliver_to_location_id,
        l_destation_organization_id,
        l_destination_subinventory,
        l_i_expenditure_type,
        l_expenditure_organization_id,
        l_expenditure_item_date,
        l_item_id,
        l_line_type_id,
        l_preparer_id,
        l_i_project_id,
        l_document_type_code,
        l_source_type_code,
        l_source_organization_id,
        l_source_subventory,
        l_i_task_id,
        l_award_set_id,
        l_deliver_to_requestor_id,
        l_suggested_vendor_id,
        l_suggested_vendor_site_id,
        l_wip_entity_id,
        l_wip_line_id,
        l_wip_repetitive_schedule_id,
        l_wip_operation_seq_num,
        l_wip_resource_seq_num,
        l_prevent_encumbrance_flag,
        l_gl_date,
        l_header_att1,
        l_header_att2,
        l_header_att3,
        l_header_att4 ,
        l_header_att5,
        l_header_att6,
        l_header_att7,
        l_header_att8,
        l_header_att9,
        l_header_att10,
        l_header_att11,
        l_header_att12,
        l_header_att13,
        l_header_att14,
        l_header_att15,
        l_line_att1,
        l_line_att2,
        l_line_att3,
        l_line_att4,
        l_line_att5,
        l_line_att6,
        l_line_att7,
        l_line_att8,
        l_line_att9,
        l_line_att10,
        l_line_att11,
        l_line_att12,
        l_line_att13,
        l_line_att14,
        l_line_att15,
        l_dist_att1,
        l_dist_att2,
        l_dist_att3,
        l_dist_att4,
        l_dist_att5,
        l_dist_att6,
        l_dist_att7,
        l_dist_att8,
        l_dist_att9,
        l_dist_att10,
        l_dist_att11,
        l_dist_att12,
        l_dist_att13,
        l_dist_att14,
        l_dist_att15,
        l_unit_price,
        l_budget_account_id,
        l_accrual_account_id,
        l_variance_account_id ;

        l_o_code_combation_id := p_req_dist_rec.code_combination_id;
        l_o_budget_account_id := p_req_dist_rec.budget_account_id;
        l_o_accrual_account_id := p_req_dist_rec.accrual_account_id;
        l_o_variance_account_id := p_req_dist_rec.variance_account_id;
    CLOSE c_req_data_n;
    END IF;
 ----dbms_OUTPUT.PUT_LINE('l_o_code_combation_id'||l_o_code_combation_id);
 result:= por_util_pkg.interface_start_workflow(
                    V_charge_success => l_o_charge_success,
                    V_budget_success => l_o_budget_success,
                    V_accrual_success => l_o_accrual_success,
                    V_variance_success => l_o_variance_success,
                    x_code_combination_id => l_o_code_combation_id,
                    x_budget_account_id => l_o_budget_account_id,
                    x_accrual_account_id => l_o_accrual_account_id,
                     x_variance_account_id => l_o_variance_account_id,
                    x_charge_account_flex => l_o_charge_account_flex,
                     x_budget_account_flex => l_o_budget_account_flex,
                     x_accrual_account_flex => l_o_accrual_account_flex ,
                     x_variance_account_flex => l_o_variance_account_flex,
                    x_charge_account_desc => l_o_charge_account_desc,
                    x_budget_account_desc => l_o_budget_account_desc,
                     x_accrual_account_desc => l_o_accrual_account_desc,
                     x_variance_account_desc => l_o_variance_account_desc,
                    x_coa_id => p_coa_id, x_bom_resource_id => NULL,
                    x_bom_cost_element_id => NULL,
                    x_category_id => NVL(p_req_line.category_id,l_category_id),
                    x_destination_type_code => NVL(p_req_line.destination_type_code,l_destination_type_code),
                    x_deliver_to_location_id => NVL(p_req_line.deliver_to_location_id,l_deliver_to_location_id),
                     x_destination_organization_id => l_destation_organization_id,
                    x_destination_subinventory => NVL(p_req_line.destination_subinventory,l_destination_subinventory),
                    x_expenditure_type => NVL(p_req_dist_rec.expenditure_type,l_i_expenditure_type),
                    x_expenditure_organization_id => NVL(p_req_dist_rec.expenditure_organization_id,l_expenditure_organization_id),
                     x_expenditure_item_date => NVL(p_req_dist_rec.expenditure_item_date,l_expenditure_item_date),
                    x_item_id => l_item_id,
                    x_line_type_id => NVL(p_req_line.line_type_id,l_line_type_id),
                    x_result_billable_flag => NULL,
                    x_preparer_id => l_preparer_id,
                    x_project_id => NVL(p_req_dist_rec.project_id,l_i_project_id),
                    x_document_type_code => l_document_type_code,
                    x_blanket_po_header_id => NULL,
                    x_source_type_code => NVL(p_req_line.source_type_code,l_source_type_code),
                    x_source_organization_id => NVL(p_req_line.source_organization_id,l_source_organization_id),
                    x_source_subinventory => NVL(p_req_line.source_subinventory,l_source_subventory),
                     x_task_id => NVL(p_req_dist_rec.task_id,l_i_task_id),
                      x_award_set_id => NVL(p_req_dist_rec.award_id,l_award_set_id),
                    x_deliver_to_person_id => l_deliver_to_requestor_id,
                    x_type_lookup_code => l_source_type_code,
                    x_suggested_vendor_id => NVL(p_req_line.vendor_id,l_suggested_vendor_id),
                     x_suggested_vendor_site_id => NVL(p_req_line.vendor_site_id,l_suggested_vendor_site_id),
                    x_wip_entity_id => l_wip_entity_id,
                     x_wip_entity_type => NULL,
                     x_wip_line_id => l_wip_line_id,
                     x_wip_repetitive_schedule_id => l_wip_repetitive_schedule_id,
                    x_wip_operation_seq_num => l_wip_operation_seq_num,
                     x_wip_resource_seq_num => l_wip_resource_seq_num,
                      x_po_encumberance_flag => l_prevent_encumbrance_flag,
                       x_gl_encumbered_date => NVL(p_req_dist_rec.gl_encumbered_date,l_gl_date),
                    wf_itemkey => l_o_wf_itemkey,
                    V_new_combination => l_o_new_combation,
                    header_att1 => l_header_att1,
                     header_att2 => l_header_att2,
                     header_att3 => l_header_att3,
                      header_att4 => l_header_att4,
                       header_att5 => l_header_att5,
                    header_att6 => l_header_att6,
                     header_att7 => l_header_att7,
                      header_att8 => l_header_att8,
                      header_att9 => l_header_att9,
                       header_att10 => l_header_att10,
                    header_att11 => l_header_att11,
                     header_att12 => l_header_att12,
                     header_att13 => l_header_att13,
                     header_att14 => l_header_att14,
                     header_att15 => l_header_att15,
                    line_att1 => NVL(p_req_line.attribute1,l_line_att1),
                    line_att2 => NVL(p_req_line.attribute2,l_line_att2),
                    line_att3 => NVL(p_req_line.attribute3,l_line_att3),
                    line_att4 => NVL(p_req_line.attribute4,l_line_att4),
                    line_att5 => NVL(p_req_line.attribute5,l_line_att5),
                    line_att6 => NVL(p_req_line.attribute6,l_line_att6),
                    line_att7 => NVL(p_req_line.attribute7,l_line_att7),
                    line_att8 => NVL(p_req_line.attribute8,l_line_att8),
                     line_att9 => NVL(p_req_line.attribute9,l_line_att9),
                     line_att10 => NVL(p_req_line.attribute10,l_line_att10),
                    line_att11 => NVL(p_req_line.attribute11,l_line_att11),
                    line_att12 => NVL(p_req_line.attribute12,l_line_att12),
                     line_att13 => NVL(p_req_line.attribute13,l_line_att13),
                     line_att14 => NVL(p_req_line.attribute14,l_line_att14),
                     line_att15 => NVL(p_req_line.attribute15,l_line_att15),
                    distribution_att1 => NVL(p_req_dist_rec.attribute1,l_dist_att1),
                    distribution_att2 => NVL(p_req_dist_rec.attribute2,l_dist_att2),
                     distribution_att3 => NVL(p_req_dist_rec.attribute3,l_dist_att3),
                      distribution_att4 => NVL(p_req_dist_rec.attribute4,l_dist_att4),
                       distribution_att5 => NVL(p_req_dist_rec.attribute5,l_dist_att5),
                    distribution_att6 => NVL(p_req_dist_rec.attribute6,l_dist_att6),
                     distribution_att7 => NVL(p_req_dist_rec.attribute7,l_dist_att7),
                     distribution_att8 => NVL(p_req_dist_rec.attribute8,l_dist_att8),
                     distribution_att9 => NVL(p_req_dist_rec.attribute9,l_dist_att9),
                     distribution_att10 => NVL(p_req_dist_rec.attribute10,l_dist_att10),
                    distribution_att11 => NVL(p_req_dist_rec.attribute11,l_dist_att11),
                    distribution_att12 => NVL(p_req_dist_rec.attribute12,l_dist_att12),
                    distribution_att13 => NVL(p_req_dist_rec.attribute13,l_dist_att13),
                    distribution_att14 => NVL(p_req_dist_rec.attribute14,l_dist_att14),
                    distribution_att15 => NVL(p_req_dist_rec.attribute15,l_dist_att15),
                    FB_ERROR_MSG => l_o_FB_ERROR_MSG,
                     p_unit_price => l_unit_price,
                     p_blanket_po_line_num => NULL
      );
      --dbms_OUTPUT.PUT_LINE('l_o_accrual_success'||l_o_accrual_success);
      --dbms_OUTPUT.PUT_LINE('l_o_accrual_account_id'||l_o_accrual_account_id);
      --dbms_OUTPUT.PUT_LINE('l_o_variance_success'||l_o_variance_success);
      --dbms_OUTPUT.PUT_LINE('l_o_variance_account_id'||l_o_variance_account_id);
        IF(result = 'Y') THEN
        --update charge account
        IF(l_o_charge_success ='Y' AND l_o_code_combation_id IS NOT NULL ) THEN
          p_req_dist_rec.code_combination_id :=l_o_code_combation_id;
        END IF;
        --update budget account
        IF(l_o_budget_success ='Y' AND l_o_budget_account_id IS NOT NULL AND l_budget_account_id IS NULL ) THEN
            p_req_dist_rec.budget_account_id := l_o_budget_account_id;
        END IF;
        --update accrual account
        IF(l_o_accrual_success ='Y' AND l_o_accrual_account_id IS NOT NULL AND l_accrual_account_id IS NULL ) THEN
          p_req_dist_rec.accrual_account_id := l_o_accrual_account_id;
        END IF;
        --update variance account
        IF(l_o_variance_success ='Y' AND l_o_variance_account_id IS NOT NULL AND l_variance_account_id IS NULL ) THEN
            p_req_dist_rec.variance_account_id:= l_o_variance_account_id;
        END IF;
    END IF;


END;

FUNCTION is_valid_line(p_req_line IN OUT NOCOPY PO_REQUISITION_UPDATE_PUB.req_line_rec_type)
RETURN VARCHAR2 IS
  l_valid_flag VARCHAR2(1);

BEGIN
  IF p_req_line.requisition_header_id IS NULL  THEN
    SELECT requisition_header_id
    INTO p_req_line.requisition_header_id
    FROM po_requisition_headers prh
    WHERE prh.segment1 = p_req_line.requisition_number;
  END IF;

  IF p_req_line.requisition_line_id IS NULL  THEN
  BEGIN
    SELECT requisition_line_id
    INTO p_req_line.requisition_line_id
    FROM po_requisition_lines prl
    WHERE prl.line_num = p_req_line.requisition_line_num
    AND prl.requisition_header_id = p_req_line.requisition_header_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_req_line.action_flag := 'NEW';
    --return l_valid_flag;
  WHEN OTHERS THEN
       l_valid_flag := 'E';
     po_message_s.sql_error('is_valid_line',10,SQLCODE);
     --return;
  END;
  END IF;
--dbms_OUTPUT.PUT_LINE('flag'||  p_req_line.action_flag );
  SELECT 'Y'
    INTO l_valid_flag
    FROM po_requisition_lines prla
    WHERE prla.requisition_line_id = p_req_line.requisition_line_id
    AND prla.requisition_header_id = p_req_line.requisition_header_id;
  RETURN l_valid_flag;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      l_valid_flag := 'N';
      RETURN l_valid_flag;
  WHEN OTHERS THEN
      l_valid_flag := 'E';
     po_message_s.sql_error('is_valid_line',10,SQLCODE);
     RAISE;
END is_valid_line;

PROCEDURE validate_item(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                        x_return_status OUT NOCOPY  VARCHAR2,
                        x_error_msg OUT NOCOPY  VARCHAR2) IS

l_module_name CONSTANT VARCHAR2(100) := 'validate_item';
d_module_base CONSTANT VARCHAR2(100) :=  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

-- Logging Info
l_progress     NUMBER;

-- local variables
l_dummy         VARCHAR2(240);
l_product       VARCHAR2(3);
l_status        VARCHAR2(1);
l_retvar        BOOLEAN;
l_eam_installed BOOLEAN;
l_inv_installed BOOLEAN;
l_wip_installed BOOLEAN;
l_autosource_flag VARCHAR2(1);

l_valid VARCHAR2(1);
l_services_enabled_flag VARCHAR2(1);
l_inventory_organization_id financials_system_params_all.Inventory_Organization_Id%TYPE;
l_outside_operation_flag_m mtl_system_items.outside_operation_flag%TYPE;
l_outside_operation_flag_p po_line_types_b.outside_operation_flag%TYPE;
l_unit_of_measure  po_line_types_b.unit_of_measure%TYPE;
l_order_type_lookup_code po_line_types_b.order_type_lookup_code%TYPE;
l_bom_item_type mtl_system_items.bom_item_type%TYPE;
l_purchasing_enabled_flag mtl_system_items.purchasing_enabled_flag%TYPE;
l_internal_order_enabled_flag mtl_system_items.internal_order_enabled_flag%TYPE;
l_rfq_required_flag mtl_system_items.rfq_required_flag%TYPE;
l_set_of_books_id  financials_system_params_all.set_of_books_id%TYPE;
l_REQ_ENCUMBRANCE_FLAG financials_system_params_all.REQ_ENCUMBRANCE_FLAG%TYPE;
l_uom mtl_system_items.primary_unit_of_measure%TYPE;
l_stock_enabled_flag mtl_system_items.stock_enabled_flag%TYPE;
l_func_currency gl_sets_of_books.currency_code%TYPE;
l_inventory_planning_code mtl_system_items.inventory_planning_code%TYPE;
l_mrp_planning_code mtl_system_items.mrp_planning_code%TYPE;
l_un_number_id mtl_system_items.un_number_id%TYPE;
l_hazard_class_id  mtl_system_items.hazard_class_id%TYPE;
l_validate_gl_period VARCHAR2(10);
l_tax_code_override VARCHAR2(1);
l_tracking_quantity_ind mtl_system_items.tracking_quantity_ind%TYPE;
l_process_enabled_flag mtl_parameters.process_enabled_flag%TYPE;
l_master_organization_id mtl_parameters.master_organization_id%TYPE;

BEGIN

  l_progress := 10;

 IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
 END IF;

 IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'item_id:',p_req_line.item_id);
      PO_LOG.stmt(d_module_base,l_progress,'item_number:',p_req_line.item_number);
      PO_LOG.stmt(d_module_base,l_progress,'source_type_code:',p_req_line.source_type_code);
      PO_LOG.stmt(d_module_base,l_progress,'destination_type_code:',p_req_line.destination_type_code);
      PO_LOG.stmt(d_module_base,l_progress,'category_id:',p_req_line.category_id);
      PO_LOG.stmt(d_module_base,l_progress,'item_category:',p_req_line.item_category);

 END IF;

       l_progress := 20;

     -- get inventory organization ( purchasing org ) from setup.

     BEGIN

      SELECT f.inventory_organization_id ,f.set_of_books_id ,g.currency_code,f.REQ_ENCUMBRANCE_FLAG,m.master_organization_id
      INTO l_inventory_organization_id ,l_set_of_books_id,l_func_currency,l_REQ_ENCUMBRANCE_FLAG,l_master_organization_id
      FROM financials_system_parameters f,gl_sets_of_books g,mtl_parameters m
      WHERE f.set_of_books_id = g.set_of_books_id
      AND f.inventory_organization_id = m.organization_id;

     EXCEPTION
     WHEN OTHERS THEN

       l_inventory_organization_id := p_req_line.destination_organization_id;

      END;
	g_func_currency := l_func_currency;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'l_inventory_organization_id:',l_inventory_organization_id);
        PO_LOG.stmt(d_module_base,l_progress,'l_set_of_books_id:',l_set_of_books_id);
        PO_LOG.stmt(d_module_base,l_progress,'l_func_currency:',l_func_currency);
        PO_LOG.stmt(d_module_base,l_progress,'l_REQ_ENCUMBRANCE_FLAG:',l_REQ_ENCUMBRANCE_FLAG);
        PO_LOG.stmt(d_module_base,l_progress,'l_master_organization_id:',l_master_organization_id);
      END IF;


 -- Need to get item_id from item_number if provided.

 l_progress := 30;

 IF p_req_line.item_id IS NULL AND p_req_line.item_number IS NOT NULL THEN

  BEGIN

   SELECT inventory_item_id
   INTO  p_req_line.item_id
   FROM mtl_system_items_kfv
   WHERE concatenated_segments = p_req_line.item_number
   AND organization_id = l_inventory_organization_id;

   EXCEPTION
   WHEN OTHERS  THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_ID');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_ID');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
  END;

 END IF;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.item_id:',p_req_line.item_id);
      END IF;

     IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.category_id:',p_req_line.category_id);
      END IF;

   -- line type info
   l_progress := 40;

      BEGIN

       SELECT outside_operation_flag , order_type_lookup_code ,unit_of_measure
       INTO l_outside_operation_flag_p , l_order_type_lookup_code ,l_unit_of_measure
       FROM po_line_types_b
       WHERE line_type_id = p_req_line.line_type_id;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'l_outside_operation_flag_p:',l_outside_operation_flag_p);
      PO_LOG.stmt(d_module_base,l_progress,'l_order_type_lookup_code:',l_order_type_lookup_code);
      PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_measure:',l_unit_of_measure);
    END IF;
   END;

      -- item level validations start
      IF p_req_line.item_id IS NOT NULL THEN
       BEGIN
       SELECT 'T',outside_operation_flag,bom_item_type,purchasing_enabled_flag,
              internal_order_enabled_flag,rfq_required_flag,primary_unit_of_measure,stock_enabled_flag,
              mrp_planning_code,inventory_planning_code,hazard_class_id,un_number_id
       INTO l_valid , l_outside_operation_flag_m, l_bom_item_type, l_purchasing_enabled_flag,
            l_internal_order_enabled_flag ,l_rfq_required_flag ,l_uom,l_stock_enabled_flag,
            l_mrp_planning_code,l_inventory_planning_code,l_hazard_class_id,l_un_number_id
       FROM mtl_system_items
       WHERE inventory_item_id = p_req_line.item_id
       AND organization_id = l_inventory_organization_id;
       EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_ID');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_ID');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'l_rfq_required_flag:',l_rfq_required_flag);
        PO_LOG.stmt(d_module_base,l_progress,'l_uom:',l_uom);
        PO_LOG.stmt(d_module_base,l_progress,'l_stock_enabled_flag:',l_stock_enabled_flag);
        PO_LOG.stmt(d_module_base,l_progress,'l_mrp_planning_code:',l_mrp_planning_code);
        PO_LOG.stmt(d_module_base,l_progress,'l_inventory_planning_code:',l_inventory_planning_code);
        PO_LOG.stmt(d_module_base,l_progress,'l_un_number_id:',l_un_number_id);
        PO_LOG.stmt(d_module_base,l_progress,'l_outside_operation_flag_m:',l_outside_operation_flag_m);
        PO_LOG.stmt(d_module_base,l_progress,'l_outside_operation_flag_m:',l_outside_operation_flag_m);
        PO_LOG.stmt(d_module_base,l_progress,'l_bom_item_type:',l_bom_item_type);
        PO_LOG.stmt(d_module_base,l_progress,'l_purchasing_enabled_flag:',l_purchasing_enabled_flag);
        PO_LOG.stmt(d_module_base,l_progress,'l_internal_order_enabled_flag:',l_internal_order_enabled_flag);
        PO_LOG.stmt(d_module_base,l_progress,'item_revision:',p_req_line.item_revision);
      END IF;

      -- item should not be of ATO or CTO model

      l_progress := 50;

       IF l_bom_item_type IN (1,2) THEN
        x_return_status :='E';
        fnd_message.set_name ('PO','PO_ATO_ITEM_NA');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_ATO_ITEM_NA');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
      END IF;

      -- if out side processing line type is used then item also should be of osp type

      l_progress := 60;

      IF NVL(l_outside_operation_flag_p,'N') = 'Y' AND NVL(l_outside_operation_flag_m,'N')<>'Y' THEN
       x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_LINE_TYPE_ITEM_MISMATCH');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_LINE_TYPE_ITEM_MISMATCH');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
      END IF;

      -- if item is OSP type and internal orders enabled and purchase enabled then line type should be
      -- of OSP type.

      l_progress := 70;

       IF NVL(l_outside_operation_flag_m,'N')='Y' AND (NVL(l_purchasing_enabled_flag,'N')='Y'
          OR NVL(l_internal_order_enabled_flag,'N')='Y') AND NVL(l_outside_operation_flag_p,'N') <> 'Y' THEN
        x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_ITEM_LINE_TYPE_MISMATCH');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_ITEM_LINE_TYPE_MISMATCH');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
      END IF;

      -- item id is not allowed for amount and fixed price based line types

      l_progress := 80;

      IF l_order_type_lookup_code IN ('AMOUNT', 'FIXED PRICE') THEN
        x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_ID_AMOUNT');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_ID_AMOUNT');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
      END IF;

      -- item revision should be valid if provided for item

      l_progress := 90;

        IF p_req_line.item_revision IS NOT NULL THEN

         BEGIN

          SELECT 'T'
          INTO l_valid
          FROM mtl_item_revisions
          WHERE revision = p_req_line.item_revision
          AND inventory_item_id = p_req_line.item_id
          AND organization_id = p_req_line.destination_organization_id;

       EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_REVISION');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_REVISION');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
      END;

       END IF;

      -- rfq_required_flag from item if null

      l_progress := 100;

      IF  p_req_line.rfq_required_flag IS NULL THEN

         p_req_line.rfq_required_flag :=  l_rfq_required_flag;

      END IF;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'l_rfq_required_flag:',l_rfq_required_flag);
        PO_LOG.stmt(d_module_base,l_progress,'rfq_required_flag:',p_req_line.rfq_required_flag);
      END IF;

     -- if category id is not provided then get it from item except for Fixed Price lines

     l_progress := 110;

       IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'category_id:',p_req_line.category_id);
      END IF;

      IF p_req_line.category_id IS NULL AND l_order_type_lookup_code <> 'FIXED_PRICE' THEN

      BEGIN

       SELECT mic.category_id
       INTO p_req_line.category_id
       FROM mtl_item_categories mic,
            mtl_default_sets_view mdsv
       WHERE mic.inventory_item_id = p_req_line.item_id
       AND mic.organization_id = l_inventory_organization_id
       AND mic.category_set_id = mdsv.category_set_id
       AND mdsv.functional_area_id = 2;

       EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_CATEGORY_ID');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_CATEGORY_ID');
       G_ERROR_COL := 'CATEGORY_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'category_id:',p_req_line.category_id);
      END IF;

      END IF;

      -- item null case category validation already present.

     -- get description of item if not provided.

     l_progress := 120;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'item_description:',p_req_line.item_description);
      END IF;

      IF p_req_line.item_description IS NULL THEN

       BEGIN

        SELECT description
        INTO p_req_line.item_description
        FROM mtl_system_items_tl
        WHERE inventory_item_id = p_req_line.item_id
        AND LANGUAGE = USERENV('LANG')
        AND organization_id = l_inventory_organization_id;

       EXCEPTION
        WHEN OTHERS THEN
          x_error_msg := 'Error while fetching from mtl_system_items_tl';
          G_ERROR_COL := 'ITEM_DESCRIPTION';
          IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          x_return_status := 'E';
        RETURN;

       END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'item_description:',p_req_line.item_description);
      END IF;

     END IF;

     l_progress := 130;

     IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'unit_meas_lookup_code:',p_req_line.unit_meas_lookup_code);
        PO_LOG.stmt(d_module_base,l_progress,'l_uom:',l_uom);
     END IF;

     IF p_req_line.unit_meas_lookup_code IS NULL THEN
        p_req_line.unit_meas_lookup_code := l_uom;
     END IF;

     -- uom for amount based line type should be written in item null case.

     IF p_req_line.unit_meas_lookup_code IS NULL AND l_order_type_lookup_code = 'AMOUNT' THEN
        p_req_line.unit_meas_lookup_code := l_unit_of_measure;
     END IF;
    -- need to see if proper UOM conversion exists if primary UOM of item is different from the one passed

    l_progress := 140;

    BEGIN

      SELECT 'T'
      INTO l_valid
      FROM MTL_UOM_CONVERSIONS UOM,
           MTL_UOM_CLASS_CONVERSIONS CLASS,
           MTL_UNITS_OF_MEASURE PRIME,
           MTL_SYSTEM_ITEMS ITEM,
           MTL_UNITS_OF_MEASURE INTER
      WHERE ITEM.inventory_item_id = p_req_line.item_id
      AND ITEM.organization_id = p_req_line.destination_organization_id
      AND UOM.unit_of_measure = p_req_line.unit_meas_lookup_code
      AND INTER.unit_of_measure = UOM.unit_of_measure
      AND ( ( ITEM.allowed_units_lookup_code IN (1, 3) AND
              UOM.inventory_item_id = p_req_line.item_id
             )
            OR
            ( ITEM.allowed_units_lookup_code = 1 AND
              UOM.inventory_item_id = 0 AND
              INTER.base_uom_flag = 'Y'
             )
            OR
            ( ITEM.allowed_units_lookup_code IN (2, 3) AND
              UOM.inventory_item_id = 0
             )
            )
       AND  NVL(UOM.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
       AND  PRIME.unit_of_measure = ITEM.primary_unit_of_measure
       AND  CLASS.inventory_item_id =DECODE(UOM.uom_class, PRIME.uom_class, 0, p_req_line.item_id)
       AND  CLASS.to_uom_class = UOM.uom_class
       AND  NVL(CLASS.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
       AND  l_order_type_lookup_code <> 'FIXED PRICE';

      EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_UNDEFINED_CONVERSIONS');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_UNDEFINED_CONVERSIONS');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
       END;

       -- need to check same for item null case.


       l_progress := 150;

       -- sourcing releated code should present.

       IF p_req_line.source_type_code = 'INVENTORY' THEN

       -- Item must have stock_enabled_flag = 'Y' for the source organization

       BEGIN

        SELECT 'T'
        INTO l_valid
        FROM mtl_system_items
        WHERE p_req_line.item_id = inventory_item_id
        AND p_req_line.source_organization_id = organization_id
        AND stock_enabled_flag = 'Y';

        EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_INV_S');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_INV_S');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

       END;

       -- Item must have internal_order_enabled_flag = 'Y' for the dest organization

       BEGIN

        SELECT 'T'
        INTO l_valid
        FROM mtl_system_items
        WHERE p_req_line.item_id = inventory_item_id
        AND p_req_line.destination_organization_id = organization_id
        AND internal_order_enabled_flag = 'Y'
        AND stock_enabled_flag = 'Y';

        EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_INV_D');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_INV_D');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

       END;

       END IF;

       -- item should be internal order enabled in purchasing org.
       l_progress := 160;

       IF NVL(l_internal_order_enabled_flag,'N') <> 'Y' THEN

        x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

       END IF;

       IF p_req_line.source_type_code = 'INVENTORY' THEN

         IF p_req_line.source_subinventory IS NOT NULL THEN

       -- item should be allowed in src sub inv or not be restricted to a sub inv
       l_progress := 170;

       IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'source_subinventory:',p_req_line.source_subinventory);
       END IF;


       BEGIN

        SELECT 'T'
        INTO l_valid
        FROM mtl_system_items msi
        WHERE msi.organization_id = p_req_line.source_organization_id
        AND msi.inventory_item_id = p_req_line.item_id
        AND (msi.restrict_subinventories_code = 2
            OR (msi.restrict_subinventories_code = 1
                AND EXISTS
                    (SELECT 'item exists in subinventory'
                        FROM mtl_item_sub_inventories misi
                       WHERE misi.organization_id = p_req_line.source_organization_id
                       AND misi.inventory_item_id = p_req_line.item_id
                       AND misi.secondary_inventory = p_req_line.source_subinventory)));

         EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_SRC_SUBINV_ITEM');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SRC_SUBINV_ITEM');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
       END;

        -- For MRP sourced internal requisitions, the source subinventory must
        -- be a non-nettable subinventory for intra-org transfers

       l_progress := 180;

        IF p_req_line.source_organization_id = p_req_line.destination_organization_id THEN

          BEGIN

           SELECT 'T'
           INTO l_valid
           FROM mtl_secondary_inventories msci,
                Mtl_System_Items Msi
           WHERE p_req_line.source_subinventory = msci.secondary_inventory_name
           AND p_req_line.source_organization_id = msci.organization_id
           AND p_req_line.source_organization_id = Msi.Organization_Id
           AND p_req_line.item_id = Msi.Inventory_Item_Id
           AND DECODE(msi.mrp_planning_code, '3', 2,
                      '4', 2, Msci.Availability_Type) = Msci.availability_type
           AND SYSDATE < NVL(msci.disable_date,SYSDATE+1);

       EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_MRP_TRANSACTION');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_MRP_TRANSACTION');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

           END;

          END IF;


        -- Transfer with asset item and expense source subinventory not allowed
        -- need to move out of itm_id if

        l_progress := 190;

          BEGIN

           SELECT 'N'
           INTO l_valid
           FROM mtl_secondary_inventories msci
           WHERE msci.organization_id = p_req_line.source_organization_id
           AND msci.secondary_inventory_name =  p_req_line.source_subinventory
           AND SYSDATE < NVL(msci.disable_date,SYSDATE+1)
           AND NVL(fnd_profile.VALUE('INV:EXPENSE_TO_ASSET_TRANSFER'),2) = 2
           AND msci.asset_inventory = 2;

       EXCEPTION
       WHEN OTHERS THEN
       l_valid := 'T' ;

           END;

           IF l_valid = 'N' THEN

              x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INV_INTRANSIT_ASSET');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INV_INTRANSIT_ASSET');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

           END IF;

           -- source sub inv reservable or not   (need to move out of itm_id if)

         l_progress := 200;

           -- need to add this later.

          END IF;    -- source sub inv not null  if
           -- For direct transfers, you cannot transfer items to a destination
           -- organization that has tighter revision,lot or serial control than
           -- the source  organization for that item
          l_progress := 210;
           BEGIN
            SELECT 'N'
            INTO l_valid
            FROM mtl_system_items ms1,
                 mtl_system_items ms2,
                 mtl_interorg_parameters mip
            WHERE ms1.inventory_item_id = p_req_line.item_id
            AND ms1.organization_id = p_req_line.source_organization_id
            AND ms2.inventory_item_id = p_req_line.item_id
            AND ms2.organization_id = p_req_line.destination_organization_id
            AND mip.from_organization_id = p_req_line.source_organization_id
            AND mip.to_organization_id = p_req_line.destination_organization_id
            AND mip.intransit_type=1
            AND ((ms1.lot_control_code = 1 AND
                  ms2.lot_control_code = 2)
                  OR (ms1.serial_number_control_code IN (1,6)
                  AND ms2.serial_number_control_code IN (2,3,5))
                  OR (ms1.revision_qty_control_code = 1 AND
                      ms2.revision_qty_control_code = 2));

           EXCEPTION
       WHEN OTHERS THEN
         l_valid := 'T';

           END;

           IF  l_valid = 'N' THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INV_LOOSE_TIGHT_DIRECT');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INV_LOOSE_TIGHT_DIRECT');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

           END IF;

           -- For intransit transfers, you cannot transfer items to a destination
           -- organization that has tighter revision control than
           -- the source  organization for that item

          l_progress := 220;

           BEGIN

            SELECT 'N'
            INTO l_valid
            FROM mtl_system_items ms1,
                 mtl_system_items ms2,
                 mtl_interorg_parameters mip
            WHERE ms1.inventory_item_id = p_req_line.item_id
            AND ms1.organization_id = p_req_line.source_organization_id
            AND ms2.inventory_item_id = p_req_line.item_id
            AND ms2.organization_id = p_req_line.destination_organization_id
            AND mip.from_organization_id = p_req_line.source_organization_id
            AND mip.to_organization_id = p_req_line.destination_organization_id
            AND mip.intransit_type=2
            AND (ms1.revision_qty_control_code = 1 AND ms2.revision_qty_control_code = 2);

            EXCEPTION
       WHEN OTHERS THEN
       l_valid := 'T' ;

           END;

           IF  l_valid = 'N' THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INV_LOOSE_TIGHT_INTRANS');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INV_LOOSE_TIGHT_INTRANS');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

           END IF;

        END IF; -- source type code inv if


          l_progress := 230;

         IF p_req_line.source_type_code = 'VENDOR' THEN

           -- if source_type_code = VENDOR and item_id is not NULL, we must have
           -- purchasing_enabled_flag = 'Y' for the purchasing org

          l_progress := 240;

          IF NVL(l_purchasing_enabled_flag,'N') <> 'Y' THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_VEND_P');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_VEND_P');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

          END IF;
           -- if source_type_code = VENDOR and item_id is not NULL, we must have
           -- purchasing_enabled_flag = 'Y' for the destination org
          l_progress := 250;
           BEGIN
            SELECT 'T'
            INTO l_valid
            FROM mtl_system_items msi
            WHERE p_req_line.item_id = msi.inventory_item_id
            AND p_req_line.destination_organization_id = msi.organization_id
            AND msi.purchasing_enabled_flag = 'Y';

           EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_VEND_D');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_VEND_D');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

           END;

         END IF; -- src type code ven if

         -- get buyer id from item if not provided.

         l_progress := 260;

         IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,'suggested_buyer_id:',p_req_line.suggested_buyer_id);
           PO_LOG.stmt(d_module_base,l_progress,'suggested_buyer_name:',p_req_line.suggested_buyer_name);
         END IF;

          IF p_req_line.suggested_buyer_id IS NULL  AND p_req_line.suggested_buyer_name IS NULL THEN

           SELECT buyer_id
           INTO p_req_line.suggested_buyer_id
           FROM mtl_system_items
           WHERE inventory_item_id = p_req_line.item_id
           AND organization_id = NVL(p_req_line.destination_organization_id,l_inventory_organization_id);

         END IF;

         IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,'suggested_buyer_id:',p_req_line.suggested_buyer_id);
         END IF;
         -- validate buyer id
          l_progress := 270;
          IF p_req_line.suggested_buyer_id IS NOT NULL THEN
          BEGIN
           SELECT 'T'
           INTO l_valid
           FROM po_buyers_val_v pbvv
           WHERE pbvv.employee_id = p_req_line.suggested_buyer_id;

           EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_SUGGESTED_BUYER');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SUGGESTED_BUYER');
       G_ERROR_COL := 'SUGGESTED_BUYER_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
           END;
          END IF;
          l_progress := 280;
           -- may need to include trx reason code defaulting.
         -- if destination_type_code=INVENTORY and destination_subinventory is
         -- provided then the item must either be allowed in the destination
         -- subinventory or not be restricted to a subinventory
         l_progress := 290;
         IF p_req_line.destination_type_code = 'INVENTORY' AND  p_req_line.destination_subinventory IS NOT NULL THEN
          BEGIN
           SELECT 'T'
           INTO l_valid
           FROM mtl_system_items msi
           WHERE msi.organization_id =  p_req_line.destination_organization_id
           AND msi.inventory_item_id = p_req_line.item_id
           AND (msi.restrict_subinventories_code = 2
               OR (msi.restrict_subinventories_code = 1
                   AND EXISTS
                   (SELECT 'item exists in subinventory'
                    FROM mtl_item_sub_inventories misi
                    WHERE misi.organization_id = p_req_line.destination_organization_id
                    AND misi.inventory_item_id = p_req_line.item_id
                    AND misi.secondary_inventory = p_req_line.destination_subinventory)));
            EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_DEST_SUBINV_ITEM');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_DEST_SUBINV_ITEM');
       G_ERROR_COL := 'SUGGESTED_BUYER_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
           END;
         END IF;
         l_progress := 300;
         -- EAM checks
         IF NOT check_installed_application('EAM') THEN
           IF  p_req_line.destination_type_code ='SHOP FLOOR' THEN
           -- item should be osp enabled and purchasable for shop floor dest type in purchasing org
           l_progress:=310;
             IF NVL(l_outside_operation_flag_m,'N')<>'Y' AND NVL(l_purchasing_enabled_flag,'N')<>'Y' THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_DEST_SHOP_P');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_DEST_SHOP_P');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

             END IF;

           -- item should be osp enabled and purchasable for shop floor dest type in destination org
           l_progress:=320;

            BEGIN

               SELECT 'T'
               INTO l_valid
               FROM mtl_system_items msi
               WHERE p_req_line.item_id = msi.inventory_item_id
               AND p_req_line.destination_organization_id = msi.organization_id
               AND msi.outside_operation_flag = 'Y'
               AND msi.purchasing_enabled_flag = 'Y';

    EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_DEST_SHOP_D');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_DEST_SHOP_D');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
           END;
         END IF;

         ELSE     -- EAM installed
           IF p_req_line.destination_type_code ='SHOP FLOOR' THEN
            -- if eam is installed then if destination_type_code = SHOP FLOOR then the item_id must be valid if
            -- provided and purchasing-enabled for the purchasing organization
            l_progress := 330;
            IF (NVL(l_stock_enabled_flag,'N')<>'N' AND NVL(l_outside_operation_flag_m,'N')<>'N'
               AND NVL(l_purchasing_enabled_flag,'N')<>'Y') AND (NVL(l_outside_operation_flag_m,'N')<>'Y'
               AND NVL(l_purchasing_enabled_flag,'N')<>'Y') THEN
               x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_DEST_EAM_P');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_DEST_EAM_P');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
            END IF;

            -- if eam is installed then if destination_type_code = SHOP FLOOR then the item_id must be valid if
            -- provided and purchasing-enabled for the dest organization
            l_progress := 340;

            BEGIN

               SELECT 'T'
               INTO l_valid
               FROM mtl_system_items msi
               WHERE p_req_line.item_id = msi.inventory_item_id
               AND p_req_line.destination_organization_id = msi.organization_id
               AND ((msi.outside_operation_flag = 'Y'
                    AND msi.purchasing_enabled_flag = 'Y')
                    OR (msi.stock_enabled_flag = 'N'
                        AND msi.outside_operation_flag = 'N'
                        AND msi.purchasing_enabled_flag = 'Y'));

           EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_DEST_EAM_D');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_DEST_EAM_D');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

           END;

           END IF;


         END IF;  -- eam inst


         -- need by date is required for PLANNED items
         -- if INVENTORY/MRP_PLANNING_CODE is 6 or NULL, then item is NOT planned
         l_progress := 350;

         IF p_req_line.need_by_date IS NULL AND (NVL(l_inventory_planning_code,6) <> 6
                                          OR  NVL(l_mrp_planning_code,6) <> 6) THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_M_INVALID_NEED_BY_DATE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_NEED_BY_DATE');
        G_ERROR_COL := 'NEED_BY_DATE';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

         END IF;

         l_progress := 360;
           -- secondary UOM validation if provided

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'secondary_uom_code:',p_req_line.secondary_uom_code);
              PO_LOG.stmt(d_module_base,l_progress,'secondary_quantity:',p_req_line.secondary_quantity);
           END IF;

           SELECT tracking_quantity_ind
           INTO l_tracking_quantity_ind
           FROM mtl_system_items msi
           WHERE p_req_line.item_id = msi.inventory_item_id
           AND msi.organization_id = p_req_line.destination_organization_id;

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_tracking_quantity_ind:',l_tracking_quantity_ind);
           END IF;

          l_progress := 370;
          -- Secondary quantity / UOM not allowed for non-dual item

          IF l_tracking_quantity_ind = 'P' AND (p_req_line.secondary_uom_code IS NOT NULL
                                                OR p_req_line.secondary_quantity IS NOT NULL) THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_SECONDARY_UOM_NOT_REQUIRED');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_SECONDARY_UOM_NOT_REQUIRED');
        G_ERROR_COL := 'SECONDARY_UOM_CODE';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

          END IF;

          l_progress := 380;
          -- validate secondary UOM
          IF p_req_line.secondary_uom_code IS NOT NULL AND  l_tracking_quantity_ind = 'PS' THEN
          BEGIN
           SELECT 'T'
           INTO l_valid
           FROM mtl_units_of_measure uom,mtl_system_items msi
           WHERE uom.unit_of_measure = p_req_line.secondary_uom_code
           AND uom.uom_code = msi.secondary_uom_code
           AND msi.inventory_item_id = p_req_line.item_id
           AND p_req_line.destination_organization_id =   msi.organization_id
           AND msi.tracking_quantity_ind = 'PS';

           EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_INCORRECT_SECONDARY_UOM');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_INCORRECT_SECONDARY_UOM');
       G_ERROR_COL := 'SECONDARY_UOM_CODE';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

            END;

          END IF;

          -- Outside Processing Item not allowed for a Process Org.
          l_progress := 390;

          BEGIN

          SELECT process_enabled_flag
          INTO l_process_enabled_flag
          FROM mtl_parameters mp
          WHERE p_req_line.destination_organization_id =  mp.organization_id;

          EXCEPTION
          WHEN OTHERS THEN
          l_process_enabled_flag := 'N';

          END;

          IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_process_enabled_flag:',l_process_enabled_flag);
          END IF;

          IF l_process_enabled_flag = 'Y' AND l_outside_operation_flag_p = 'Y' THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_OPS_ITEM_PROCESS_ORG');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_OPS_ITEM_PROCESS_ORG');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

          END IF;

           -- if un_number_id and hazard_class_id are still not populated get them from item
         l_progress := 400;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'un_number_id:',p_req_line.un_number_id);
              PO_LOG.stmt(d_module_base,l_progress,'hazard_class_id:',p_req_line.hazard_class_id);
             END IF;

            IF p_req_line.un_number_id IS NULL THEN

               p_req_line.un_number_id := l_un_number_id;

            END IF;

            IF p_req_line.hazard_class_id IS NULL THEN

               p_req_line.hazard_class_id := l_hazard_class_id;

            END IF;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'un_number_id:',p_req_line.un_number_id);
              PO_LOG.stmt(d_module_base,l_progress,'hazard_class_id:',p_req_line.hazard_class_id);
            END IF;

           l_progress := 430;

           -- get item mfg info
           BEGIN
           SELECT  mfg_part_num,
                   manufacturer_name,
                   MANUFACTURER_ID
           INTO p_req_line.manufacturer_part_number,
                p_req_line.manufacturer_name,
                p_req_line.manufacturer_id
           FROM mtl_mfg_part_numbers_all_v
           WHERE row_id = (SELECT MIN(row_id)
                           FROM   mtl_mfg_part_numbers_all_v
                           WHERE  inventory_item_id = p_req_line.item_id
                           AND organization_id = l_master_organization_id);

           EXCEPTION
           WHEN OTHERS THEN
           p_req_line.manufacturer_part_number := NULL;
           p_req_line.manufacturer_name := NULL;
           p_req_line.manufacturer_id := NULL;
           END;

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'manufacturer_part_number:',p_req_line.manufacturer_part_number);
              PO_LOG.stmt(d_module_base,l_progress,'manufacturer_name:',p_req_line.manufacturer_name);
              PO_LOG.stmt(d_module_base,l_progress,'manufacturer_id:',p_req_line.manufacturer_id);
            END IF;

    ELSE

        -- revision check for null item
        l_progress := 410;

        BEGIN

         IF p_req_line.item_revision IS NOT NULL THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_ITEM_REV_NOT_ALLOWED');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_ITEM_REV_NOT_ALLOWED');
        G_ERROR_COL := 'ITEM_REVISION';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

         END IF;

        END;


      IF p_req_line.unit_meas_lookup_code IS NULL AND l_order_type_lookup_code = 'AMOUNT' THEN

        p_req_line.unit_meas_lookup_code := l_unit_of_measure;

      END IF;

      --  UOM check for null item
      l_progress := 420;

      BEGIN

        SELECT 'T'
        INTO l_valid
        FROM MTL_UOM_CONVERSIONS UOM
        WHERE UOM.unit_of_measure = p_req_line.unit_meas_lookup_code
        AND UOM.inventory_item_id = 0
        AND l_order_type_lookup_code <> 'FIXED PRICE';

       EXCEPTION
       WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_UNDEFINED_CONVERSIONS');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_UNDEFINED_CONVERSIONS');
       G_ERROR_COL := 'ITEM_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

      END;
    END IF;   -- item id not null if

           --
           l_progress := 430;
           -- need to add VMI related code

           -- Derive / Default Secondary Quantity for dual uom items
           -- code need to be written for this.

           x_return_status :='S';
EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('validate_item','010',SQLCODE);
    RAISE;

 END validate_item;

PROCEDURE validate_Line_type(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type, x_return_status OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2
                             ,p_desttype_code IN VARCHAR2,p_source_type IN VARCHAR2,p_dest_org_id IN NUMBER)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'validate_Line_type';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  -- Logging Infra
  l_progress     NUMBER;

  -- local variables
  l_valid             VARCHAR2(1);
  l_order_type_lookup_code  po_line_types.order_type_lookup_code%TYPE;
  l_outside_operation_flag  po_line_types.outside_operation_flag%TYPE;
  l_unit_of_measure         po_line_types.unit_of_measure%TYPE;

  l_services_enabled_flag VARCHAR2(10);

BEGIN
/*  LINE_TYPE_ID
      - Should exists in po_line_types and should be in the same line type class
 */
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
   END IF;
  l_progress := 10;
  IF PO_LOG.d_stmt THEN
   PO_LOG.stmt(d_module_base,l_progress,'Line Type ID: ',p_req_line.line_type_id);
  END IF;

 BEGIN

    SELECT 'T', plt.line_type_id
    INTO l_valid, p_req_line.line_type_id
    FROM po_line_types plt
    WHERE (p_req_line.line_type_id = plt.line_type_id
      OR p_req_line.line_type = plt.line_type
      )
    AND SYSDATE < NVL(plt.inactive_date,SYSDATE+1)
    AND plt.purchase_basis <> 'TEMP LABOR';

  EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_LINE_TYPE_ID');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_LINE_TYPE_ID');
       G_ERROR_COL := 'LINE_TYPE_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
  END;

   /* if line_type is an 'Outside Operation' line type , then               */
   /* destination_type_code must be 'SHOP FLOOR'                            */
  /* validate that we cannot have a source_type_code of 'INVENTORY' and a   */
  /* line type of outside operation.                                        */

    l_progress := 20;

  SELECT plt.outside_operation_flag, plt.order_type_lookup_code, plt.unit_of_measure
   INTO l_outside_operation_flag, l_order_type_lookup_code, l_unit_of_measure
   FROM po_line_types plt, mtl_parameters mp
  WHERE p_req_line.line_type_id = plt.line_type_id
    AND NVL(p_req_line.destination_organization_id,p_dest_org_id) =  mp.organization_id;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'l_outside_operation_flag:',l_outside_operation_flag);
         PO_LOG.stmt(d_module_base,l_progress,'l_order_type_lookup_code:',l_order_type_lookup_code);
         PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_measure:',l_unit_of_measure);
    END IF;

     -- quantity must be >0 except for Fixed Price Services lines

        IF l_order_type_lookup_code <> 'FIXED PRICE' AND (p_req_line.quantity <= 0 OR p_req_line.quantity IS NULL)
         AND p_req_line.action_flag = 'NEW' THEN

            x_return_status :='E';
             x_error_msg := 'quantity must be > 0 except for Fixed Price Services lines';
             G_ERROR_COL := 'QUANTITY';
                IF PO_LOG.d_stmt THEN
                 PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
                END IF;
             RETURN;

        END IF;

  IF l_outside_operation_flag = 'Y' THEN
    IF NVL(p_req_line.destination_type_code,p_desttype_code) <> 'SHOP FLOOR' THEN
        x_return_status :='E';
    x_error_msg := ' line_type is an "Outside Operation" line type, destination_type_code should be SHOP FLOOR';
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      RETURN;
    END IF;

    IF NVL(p_req_line.source_type_code,p_source_type) = 'INVENTORY' THEN
        x_return_status :='E';
    x_error_msg := 'we cannot have a source_type_code of "INVENTORY" for line type outside operation';
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
    END IF;
  END IF;  -- end if l_outside_operation_flag = 'Y'


/*-  When user changes to AMOUNT based (i.e. item_id is NULL) then
 NULL out item atttributes. the need_by_date to not required
 get unit_of_measure from po_line_types for AMOUNT based line types */


  IF l_order_type_lookup_code ='AMOUNT' THEN

  l_progress := 30;
    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'AMOUNT based');
    END IF;

    p_req_line.unit_meas_lookup_code := l_unit_of_measure;
    -- TODO NULL out item attributes
    p_req_line.unit_price :=1;
  END IF;

  l_services_enabled_flag := PO_SETUP_S1.get_services_enabled_flag;

   IF l_services_enabled_flag = 'N' AND l_order_type_lookup_code = 'FIXED PRICE' THEN
      x_return_status :='E';
        fnd_message.set_name ('PO','PO_SVC_NOT_ENABLED_RI');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_SVC_NOT_ENABLED_RI');
        G_ERROR_COL := 'LINE_TYPE_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
    END IF;
  /* if line_type is a 'Fixed Price' line type , then */
  /* destination_type_code must be 'EXPENSE' */
  IF l_order_type_lookup_code = 'FIXED PRICE' THEN
      l_progress := 40;
     IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'Fixed Price line type, destination_type_code must be EXPENSE');
    END IF;
    IF NVL(p_req_line.destination_type_code,p_desttype_code) <> 'EXPENSE' AND NVL(p_req_line.destination_type_code,p_desttype_code) <> 'SHOP FLOOR' THEN
        x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_FIXEDPRICE_DEST_MISMATCH');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_FIXEDPRICE_DEST_MISMATCH');
        G_ERROR_COL := 'LINE_TYPE_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
    END IF;

  /* Fixed Price Service line type --> Item attributes are not updatable (Item,Qty,UOM,Price)"*/
    IF p_req_line.quantity IS NOT NULL THEN
        fnd_message.set_name ('PO','PO_RI_QUANTITY_NOT_NULL');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_QUANTITY_NOT_NULL');
        G_ERROR_COL := 'QUANTITY';
    END IF;
    IF p_req_line.unit_meas_lookup_code IS NOT NULL THEN
              fnd_message.set_name ('PO','PO_RI_UOM_NOT_NULL');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_UOM_NOT_NULL');
        G_ERROR_COL := 'UNIT_OF_MEASURE';
    END IF;

    IF p_req_line.item_id IS NOT NULL OR p_req_line.item_number IS NOT NULL THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_ID_AMOUNT');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_ID_AMOUNT');
        G_ERROR_COL := 'ITEM_ID';
    END IF;

    IF p_req_line.unit_price IS NOT NULL THEN
        fnd_message.set_name ('PO','PO_RI_UNIT_PRICE_NOT_NULL');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_UNIT_PRICE_NOT_NULL');
        G_ERROR_COL := 'UNIT_PRICE';
    END IF;

    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

  END IF; -- end if l_order_type_lookup_code = 'FIXED PRICE

  x_return_status :='S';
  EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('validate_Line_type','010',SQLCODE);
    --RAISE;
END validate_Line_type;

PROCEDURE validate_Currency(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type, x_return_status OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'validate_Currency';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  -- Logging Infra
  l_progress     NUMBER;
  l_log_msg             FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_currency_code gl_sets_of_books.currency_code%TYPE;
  l_set_of_books_id  financials_system_parameters.set_of_books_id%TYPE;
  l_valid VARCHAR2(1);
  x_currency_unit_price  NUMBER  := NULL;
  x_unit_price         NUMBER  := NULL;
  x_precision             NUMBER  := NULL;
  x_ext_precision         NUMBER  := NULL;
  x_min_acct_unit         NUMBER  := NULL;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
  END IF;
  l_progress := 10;
  --getting functional currency
  x_return_status := 'S';
  BEGIN
    SELECT DISTINCT gsob.currency_code, fsp.set_of_books_id
      INTO  l_currency_code, l_set_of_books_id
      FROM financials_system_parameters fsp,
             gl_sets_of_books gsob
    WHERE gsob.set_of_books_id = fsp.set_of_books_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := 'E';
        x_error_msg :='cannot find functional currency code';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RAISE;
    WHEN OTHERS THEN
        x_error_msg := SQLERRM;
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      x_return_status := 'E';
      po_message_s.sql_error('validate_Currency','010',SQLCODE);
      RAISE;
    END;


  /* if currency_code is NULL or the same as the functional currency, set */
  /* currency_unit_price,rate,rate_date, rate_type and currency_amount to NULL */

  IF (p_req_line.currency_code IS NULL OR l_currency_code =  p_req_line.currency_code) THEN
    p_req_line.currency_unit_price := NULL;
    p_req_line.rate := NULL;
    p_req_line.rate_type := NULL;
    p_req_line.rate_date := NULL;
    p_req_line.currency_amount := NULL;


    l_progress := 20;
    l_log_msg := 'currency_code is NULL or the same as the functional currency, set currency_unit_price,rate,rate_date, rate_type and currency_amount to NULL';
    IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,l_progress,l_log_msg);
    END IF;
    x_return_status := 'S';
    RETURN;
  END IF;

  /*
   currency_code                Y   fnd_currencies_vl where enabled_flag = 'Y' and currency_flag = 'Y'
   */
  BEGIN
     SELECT 'T'
     INTO l_valid
       FROM fnd_currencies fc
      WHERE fc.currency_code = p_req_line.currency_code
        AND fc.enabled_flag = 'Y'
        AND SYSDATE BETWEEN
            NVL (fc.start_date_active, SYSDATE-1)
                    AND
            NVL (fc.end_date_active,SYSDATE+1);
    l_progress := 30;
      IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'p_req_line.currency_code:',p_req_line.currency_code);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         x_return_status :='E';
          fnd_message.set_name ('PO','PO_RI_INVALID_CURRENCY_CODE');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_CURRENCY_CODE');
          G_ERROR_COL := 'CURRENCY_CODE';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
        RETURN;
  END;


 /* if currency_code is provided, get rate from gl_daily_conversion_rates */
 /* if it is not the functional currency only */
 /* If rate_type is EMU FIXED then overwrite the provided rate with the */
 /* gl_currency_api.get_rate */

  IF ( p_req_line.currency_code IS NOT NULL AND p_req_line.currency_code <> l_currency_code AND (p_req_line.rate IS NULL OR p_req_line.rate_type = 'EMU FIXED'))THEN
    IF p_req_line.rate_date IS NULL OR p_req_line.rate_type IS NULL THEN
        fnd_message.set_name ('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        G_ERROR_COL := 'RATE';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      x_return_status := 'E';
      RETURN;
    END IF;

    BEGIN
      SELECT 'T'
      INTO l_valid
      FROM gl_daily_conversion_types gdct
      WHERE gdct.conversion_type = p_req_line.rate_type;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        G_ERROR_COL := 'RATE TYPE';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      RETURN;
    END;


    p_req_line.rate :=  po_core_s.get_conversion_rate(l_set_of_books_id,  p_req_line.currency_code, p_req_line.rate_date, p_req_line.rate_type);

    l_progress := 40;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'calling po_core_s.get_conversion_rate');
    END IF;

    IF p_req_line.rate IS NULL THEN
        fnd_message.set_name ('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
        G_ERROR_COL := 'RATE';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      x_return_status := 'E';
      RETURN;
    END IF;
  END IF;

  IF p_req_line.currency_unit_price IS NULL THEN
    fnd_currency.get_info (p_req_line.currency_code,
                                             x_precision,
                                             x_ext_precision,
                                             x_min_acct_unit);
     x_currency_unit_price := ROUND(p_req_line.unit_price/
                           p_req_line.rate,x_ext_precision);
     p_req_line.currency_unit_price :=  x_currency_unit_price;
  ELSE
     fnd_currency.get_info (l_currency_code,
                            x_precision,
                            x_ext_precision,
                            x_min_acct_unit);

      x_unit_price := ROUND (p_req_line.currency_unit_price *
                            p_req_line.rate,x_ext_precision);
      p_req_line.unit_price :=  x_unit_price;
  END IF;

  x_return_status :='S';
EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('validate_Currency','010',SQLCODE);
    RAISE;
END validate_Currency;

PROCEDURE validate_VendorInfo(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type, p_vendor_id NUMBER,p_vendor_site_id IN NUMBER, p_vendor_contact_id IN NUMBER, x_return_status OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'validateVendorInfo';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  -- Logging Infra
  l_progress     NUMBER;

  -- local variables
  l_valid VARCHAR2(1);

BEGIN
  /*doc
     suggested_vendor_name /vendor_id       Y   "Source type should be Supplier.
Should be valid value in po_suppliers_val_V"
 suggested_vendor_location  /vendor_site_id Y   "Source type should be Supplier.
Should be valid value in po_supplier_po_sites_val_V for the given vendor name"
 suggested_vendor_contact  /vendor_contact_id   Y   Should be valid for the given vendor and location
 suggested_vendor_phone       Y   Should be valid for the given vendor contact
 suggested_vendor_product_co  Y   Any free text
  */
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
  END IF;
    IF (p_req_line.vendor_id IS NOT NULL OR p_req_line.suggested_vendor_name IS NOT NULL )THEN
      l_progress := 10;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'suggested_vendor_name:',p_req_line.suggested_vendor_name);
      PO_LOG.stmt(d_module_base,l_progress,'vendor_id:',p_req_line.vendor_id);
      PO_LOG.stmt(d_module_base,l_progress,'vendor_site_id:',p_req_line.vendor_site_id);
      PO_LOG.stmt(d_module_base,l_progress,'vendor_contact_id:',p_req_line.vendor_contact_id);
      PO_LOG.stmt(d_module_base,l_progress,'p_vendor_site_id:',p_vendor_site_id);
      PO_LOG.stmt(d_module_base,l_progress,'p_vendor_contact_id:',p_vendor_contact_id);

    END IF;

    BEGIN
      SELECT 'T', pv.vendor_id, pv.vendor_name
      INTO l_valid, p_req_line.vendor_id, p_req_line.suggested_vendor_name
      FROM po_vendors pv
      WHERE pv.vendor_id = p_req_line.vendor_id OR
            pv.vendor_name= p_req_line.suggested_vendor_name;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_SUGGESTED_VENDOR');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SUGGESTED_VENDOR');
        G_ERROR_COL := 'SUGGESTED_VENDOR_ID';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
    END;
  END IF; -- if p_req_line.vendor_id IS NOT NULL then

/*get suggested_vendor_location */
  IF p_req_line.suggested_vendor_location IS NOT NULL OR
    p_req_line.vendor_site_id IS NOT NULL  THEN
    l_progress := 20;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'suggested_vendor_location:',p_req_line.suggested_vendor_location);
     PO_LOG.stmt(d_module_base,l_progress,'vendor_site_id:',p_req_line.vendor_site_id);
    END IF;

    BEGIN
      SELECT 'T', pv.vendor_site_id, pv.vendor_site_code
      INTO l_valid, p_req_line.vendor_site_id, p_req_line.suggested_vendor_location
      FROM po_vendor_sites_all pv
      WHERE pv.vendor_id      = nvl(p_req_line.vendor_id,p_vendor_id)
      AND (pv.vendor_site_id = NVL(p_req_line.vendor_site_id, p_vendor_site_id)
          OR pv.vendor_site_code = p_req_line.suggested_vendor_location);

    l_progress := 20.1;
    IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_module_base,l_progress,'suggested_vendor_location:',p_req_line.suggested_vendor_location);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_INVALID_VENDOR_SITE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_VENDOR_SITE');
        G_ERROR_COL := 'SUGGESTED_VENDOR_SITE_ID';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
    END;
  END IF;


  /* get suggested_vendor_contact and phone from suggested_vendor_contact_id*/
  IF (p_req_line.suggested_vendor_contact IS NOT NULL
    OR NVL(p_req_line.vendor_contact_id,p_vendor_contact_id) IS NOT NULL )THEN
    BEGIN
      l_progress := 30;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'vendor_contact_id:',p_req_line.vendor_contact_id);
        PO_LOG.stmt(d_module_base,l_progress,'vendor_site_id:',p_req_line.vendor_site_id);
      END IF;

      SELECT 'T', pvc.vendor_contact_id,
      DECODE(pvc.first_name,NULL,pvc.last_name, pvc.last_name || ', ' || pvc.first_name), pvc.phone
      INTO l_valid, p_req_line.vendor_contact_id, p_req_line.suggested_vendor_contact, p_req_line.suggested_vendor_phone
      FROM po_vendor_contacts pvc
      WHERE (pvc.vendor_contact_id = NVL(p_req_line.vendor_contact_id, p_vendor_contact_id)
              OR DECODE(pvc.first_name,NULL,pvc.last_name, pvc.last_name || ', ' || pvc.first_name) = p_req_line.suggested_vendor_contact)
        AND pvc.vendor_site_id    =  NVL(p_req_line.vendor_site_id, p_vendor_site_id);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status :='E';
         fnd_message.set_name ('PO','PO_RI_INVALID_VENDOR_CONTACT');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_VENDOR_CONTACT');
        G_ERROR_COL := 'SUGGESTED_VENDOR_CONTACT_ID';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RETURN;
    END;
  END IF;

  x_return_status :='S';
  EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
    END IF;
    x_return_status := 'E';
    po_message_s.sql_error('validate_VendorInfo','010',SQLCODE);
    RAISE;
END validate_VendorInfo;


PROCEDURE validate_SourcingDoc(p_req_line IN OUT PO_REQUISITION_UPDATE_PUB.req_line_rec_type, x_return_status OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'validate_SourcingDoc';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  -- Logging Infra
  l_progress     NUMBER;

  --local variables
  l_valid VARCHAR2(1);
  CURSOR c_req_line(p_line_id NUMBER,p_header_id NUMBER)
  IS SELECT *
  FROM po_requisition_lines
  WHERE requisition_line_id = p_line_id
  AND requisition_header_id = p_header_id;

  l_reqline_rec c_req_line%ROWTYPE;
BEGIN
  /*
  document_type_code           Y   BLANKET, QUOTATION, CONTRACT
 blanket_po_header_id             "should exist in po_headers_all
 blanket_po_line_num              match with the blanket po header id
  */

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
   END IF;

   OPEN c_req_line(p_req_line.requisition_line_id,p_req_line.requisition_header_id);
   FETCH c_req_line INTO l_reqline_rec;
   CLOSE c_req_line;

  IF NOT(NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code) <> 'BLANKET'
    OR NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code) <> 'QUOTATION'
    OR NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code) <> 'CONTRACT') THEN
    x_return_status :='E';
    x_error_msg := 'The document type code should be BLANKET, QUOTATION, CONTRACT';

    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
    END IF;
    RETURN;
  END IF;


    l_progress := 10;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'document_type_code: ',p_req_line.document_type_code);
    END IF;

  IF (NVL(p_req_line.document_type_code,l_reqline_rec.document_type_code)= 'BLANKET') THEN
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress, 'BLANKET agreement');
    END IF;
    BEGIN
      SELECT 'T',  pha.po_header_id
      INTO l_valid, p_req_line.blanket_po_header_id
      FROM po_headers_all pha
      WHERE pha.type_lookup_code = NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code)
      AND (pha.po_header_id = p_req_line.blanket_po_header_id OR pha.segment1 = p_req_line.blanket_po_number);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status :='E';
      x_error_msg := 'Not a valid blanket purchasing document';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RETURN;
    WHEN OTHERS THEN
        x_error_msg := 'Error while fetching from po_headers_all';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        x_return_status := 'E';
        RETURN;
  END;

  l_progress := 20;
  IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'blanket_po_header_id:',p_req_line.blanket_po_header_id);
       PO_LOG.stmt(d_module_base,l_progress,'blanket_po_line_num:',p_req_line.blanket_po_line_num);
       PO_LOG.stmt(d_module_base,l_progress,'item_id:',l_reqline_rec.item_id);
       PO_LOG.stmt(d_module_base,l_progress,'vendor_id:',p_req_line.vendor_id);
       PO_LOG.stmt(d_module_base,l_progress,'org_id:',p_req_line.org_id);
       PO_LOG.stmt(d_module_base,l_progress,'vendor_site_id:',p_req_line.vendor_site_id);
    END IF;

    IF NVL(p_req_line.vendor_site_id,l_reqline_rec.vendor_site_id) IS NOT NULL THEN
      BEGIN
        SELECT 'T'
        INTO l_valid
        FROM po_headers_all pha, po_lines_all pla
        WHERE pla.po_header_id = NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id)
        AND pha.po_header_id = pla.po_header_id
        AND pla.LINE_NUM = NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num)
        AND pla.item_id = l_reqline_rec.item_id
        AND pha.vendor_id = NVL(p_req_line.vendor_id, l_reqline_rec.vendor_id)
        AND pla.org_id= NVL(p_req_line.org_id, l_reqline_rec.org_id)
        AND pha.vendor_site_id = NVL(p_req_line.vendor_site_id, l_reqline_rec.vendor_site_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_return_status :='E';
      x_error_msg := 'Not a valid BPA line';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      RETURN;
    WHEN OTHERS THEN
        x_error_msg := 'Error while fetching from po_headers_all, po_lines_all';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        x_return_status := 'E';
        RETURN;
      END;
    ELSE
      BEGIN
        SELECT 'T'
        INTO l_valid
        FROM po_headers_all pha, po_lines_all pla
        WHERE pla.po_header_id = NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id)
        AND pha.po_header_id = pla.po_header_id
        AND pla.LINE_NUM = NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num)
        AND pla.item_id = l_reqline_rec.item_id
        AND pha.vendor_id = NVL(p_req_line.vendor_id, l_reqline_rec.vendor_id)
        AND pla.org_id= NVL(p_req_line.org_id, l_reqline_rec.org_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_return_status :='E';
      x_error_msg := 'Not a valid BPA line';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RETURN;
    WHEN OTHERS THEN
        x_error_msg := 'Error while fetching from po_headers_all, po_lines_all';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        x_return_status := 'E';
        RETURN;
      END;
    END IF;
  END IF; -- end  p_req_line.document_type_code = 'BLANKET'

  x_return_status :='S';
  EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    x_return_status := 'E';
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
    END IF;
    po_message_s.sql_error('validate_SourcingDoc','010',SQLCODE);
    RAISE;
END validate_SourcingDoc;

PROCEDURE default_UnitPrice(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
    x_return_status  OUT NOCOPY  VARCHAR2, x_error_msg OUT NOCOPY  VARCHAR2)
IS
  l_module_name CONSTANT VARCHAR2(100) := 'default_UnitPrice';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  -- Logging Infra
  l_progress     NUMBER;

  CURSOR c_req_line(p_line_id NUMBER,p_header_id NUMBER)
  IS SELECT *
  FROM po_requisition_lines
  WHERE requisition_line_id = p_line_id
  AND requisition_header_id = p_header_id;

  l_reqline_rec c_req_line%ROWTYPE;
BEGIN
  /* doc
   unit_price                   Y   "1 . If the value is not null
  1.. Calculate price based on sourcing rules if exists
   vendor id , site id(optional, and org_id are needed.
   SELECT * FROM po_headers_all pha, po_lines_all pla WHERE pha.vendor_id = 21 AND pla.item_id =73
AND pha.po_header_ID = PLA.PO_header_id AND type_lookup_code='BLANKET'
  2. If no sourcing rules are found at item/supplier then default from item definition
  3. Price will always be in functional currency.
  4. For amount based line type it should always be 1" -- checked in validate_line_type
  */
   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
   END IF;

   OPEN c_req_line(p_req_line.requisition_line_id,p_req_line.requisition_header_id);
   FETCH c_req_line INTO l_reqline_rec;
   CLOSE c_req_line;

  l_progress :=10;
  p_req_line.unit_price := NULL;


  IF NVL(p_req_line.order_type_lookup_code, l_reqline_rec.order_type_lookup_code) = 'AMOUNT' THEN
    l_progress :=20;
    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'AMOUNT TYPE, unit price is defaulting to 1');
    END IF;
    p_req_line.unit_price :=1;
  END IF;

  IF (NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code) = 'BLANKET'
    AND NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id) <> NULL)  THEN

    l_progress :=30;
    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'Sourcing from BLANKET agreement');
    END IF;

    IF NVL(p_req_line.vendor_site_id,  l_reqline_rec.vendor_site_id) IS NOT NULL THEN
      l_progress :=40;
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'vendor_site_id is not null');
      END IF;
      SELECT pla.unit_price, pla.base_unit_price
      INTO p_req_line.unit_price, p_req_line.base_unit_price
      FROM po_headers_all pha, po_lines_all pla
      WHERE pha.vendor_id = NVL(p_req_line.vendor_id, l_reqline_rec.vendor_id)
      AND  pha.vendor_site_id = NVL(p_req_line.vendor_site_id, l_reqline_rec.vendor_site_id)
      AND pla.item_id =l_reqline_rec.item_id
      AND pha.po_header_id = pla.po_header_id
      AND NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id) = pha.po_header_id
      AND NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code)='BLANKET'
      AND NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num) =pla.LINE_NUM;

      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'blanket_po_header_id:',NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id));
         PO_LOG.stmt(d_module_base,l_progress,'blanket_po_line_num:',NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num));
         PO_LOG.stmt(d_module_base,l_progress,'unit_price: ',p_req_line.unit_price);
         PO_LOG.stmt(d_module_base,l_progress,'base_unit_price: ',p_req_line.base_unit_price);
      END IF;

      IF p_req_line.unit_price <> NULL THEN
        RETURN;
      END IF;
    END IF; -- if vendor site id is not null

    SELECT pla.unit_price, pla.base_unit_price
    INTO p_req_line.unit_price, p_req_line.base_unit_price
    FROM po_headers_all pha, po_lines_all pla
    WHERE pha.vendor_id = NVL(p_req_line.vendor_id, l_reqline_rec.vendor_id)
    AND pla.item_id =l_reqline_rec.item_id
    AND pha.po_header_id = pla.po_header_id
    AND NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id) = pha.po_header_id
    AND NVL(p_req_line.document_type_code, l_reqline_rec.document_type_code)='BLANKET'
    AND NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num) =pla.LINE_NUM;

  l_progress :=50;
  IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'blanket_po_header_id:',NVL(p_req_line.blanket_po_header_id, l_reqline_rec.blanket_po_header_id));
         PO_LOG.stmt(d_module_base,l_progress,'blanket_po_line_num:',NVL(p_req_line.blanket_po_line_num, l_reqline_rec.blanket_po_line_num));
         PO_LOG.stmt(d_module_base,l_progress,'unit_price: ',p_req_line.unit_price);
       PO_LOG.stmt(d_module_base,l_progress,'base_unit_price: ',p_req_line.base_unit_price);
    END IF;
     IF p_req_line.unit_price <> NULL THEN
       RETURN;
     END IF;
  END IF;
    l_progress :=60;
    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'default from item definiteion');
       PO_LOG.stmt(d_module_base,l_progress,'item_id:',l_reqline_rec.item_id);
       PO_LOG.stmt(d_module_base,l_progress,'source_organization_id: ',NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id));
       PO_LOG.stmt(d_module_base,l_progress,'unit_meas_lookup_code: ',NVL(p_req_line.unit_meas_lookup_code, l_reqline_rec.unit_meas_lookup_code));
    END IF;
   /*default from item definition*/
   p_req_line.unit_price := por_util_pkg.get_item_cost(l_reqline_rec.item_id,
                                                       NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id),
                                                       NVL(p_req_line.unit_meas_lookup_code, l_reqline_rec.unit_meas_lookup_code),
                                                       l_reqline_rec.destination_organization_id,
                                                       NVL(p_req_line.rate_date, l_reqline_rec.rate_date));
     x_return_status :='S';
     RETURN;
  EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    x_return_status := 'E';
    po_message_s.sql_error('default_UnitPrice','010',SQLCODE);
    RAISE;
END default_UnitPrice;
PROCEDURE default_setup_Attributes(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
x_return_status OUT NOCOPY  VARCHAR2,
                        x_error_msg OUT NOCOPY  VARCHAR2)
IS
l_module_name CONSTANT VARCHAR2(100) := 'default_setup_Attributes';
d_module_base CONSTANT VARCHAR2(100) :=  PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

-- Logging Info
l_progress     NUMBER;
l_valid VARCHAR2(1);
BEGIN
x_return_status := 'S';
IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_header_id', p_req_line.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_line.requisition_line_id', p_req_line.requisition_line_id);
 END IF;

 l_progress := 10;

 IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'source_type_code:',p_req_line.source_type_code);
      PO_LOG.stmt(d_module_base,l_progress,'destination_type_code:',p_req_line.destination_type_code);
 END IF;

 -- Need to default source type code if not provided and if destination type is Inventory

 IF p_req_line.source_type_code IS NULL AND NVL(p_req_line.destination_type_code,'VENDOR') = 'INVENTORY' THEN

    l_progress := 11;

 IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'item_id:',p_req_line.item_id);
      PO_LOG.stmt(d_module_base,l_progress,'destination_subinventory:',p_req_line.destination_subinventory);
      PO_LOG.stmt(d_module_base,l_progress,'destination_organization_id:',p_req_line.destination_organization_id);
 END IF;

  IF p_req_line.item_id IS NOT NULL AND p_req_line.destination_organization_id IS NOT NULL THEN

 BEGIN

     SELECT DECODE (NVL (misi.source_type,msci.source_type),
                    1,'INVENTORY',
                    2,'VENDOR',
                    NULL)
            INTO p_req_line.source_type_code
            FROM mtl_item_sub_inventories misi,
                 mtl_secondary_inventories msci
     WHERE misi.organization_id = p_req_line.destination_organization_id
     AND misi.inventory_item_id = p_req_line.item_id
     AND misi.secondary_inventory =  p_req_line.destination_subinventory
     AND msci.organization_id = p_req_line.destination_organization_id
     AND msci.secondary_inventory_name = p_req_line.destination_subinventory;

    EXCEPTION
    WHEN OTHERS THEN
     p_req_line.source_type_code := NULL;

  END;
     IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'source_type_code:',p_req_line.source_type_code);
   END IF;

    l_progress := 12;

   IF p_req_line.source_type_code IS NULL THEN

     BEGIN

      SELECT DECODE (NVL (msi.source_type, mp.source_type),
                     1,'INVENTORY',
                     2,'VENDOR',
                     'VENDOR')
             INTO p_req_line.source_type_code
             FROM mtl_system_items msi,
                  mtl_parameters mp
             WHERE  p_req_line.item_id = msi.inventory_item_id
             AND    p_req_line.destination_organization_id = msi.organization_id
             AND  mp.organization_id = p_req_line.destination_organization_id;

      EXCEPTION
      WHEN OTHERS THEN
      p_req_line.source_type_code := NULL;

      END;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'source_type_code:',p_req_line.source_type_code);
    END IF;

    END IF;

   END IF;

   END IF;

   -- source type code validation

   l_progress := 20;

   BEGIN

    SELECT 'T'
    INTO l_valid
    FROM po_lookup_codes
    WHERE lookup_type = 'REQUISITION SOURCE TYPE'
    AND lookup_code = p_req_line.source_type_code;

    EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_INVALID_SOURCE_TYPE_CODE');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SOURCE_TYPE_CODE');
       G_ERROR_COL := 'SOURCE_TYPE_CODE';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;
    END;

   x_return_status :='S';
   EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('default_setup_Attributes','010',SQLCODE);
    RAISE;
END default_setup_Attributes;

PROCEDURE val_line_non_upd_data(p_req_line IN po_requisition_update_pub.req_line_rec_type,
                               x_error_msg OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2)
IS
BEGIN
x_return_status := 'S';
IF p_req_line.item_id IS NOT NULL OR p_req_line.item_number IS NOT NULL THEN
   x_return_status := 'E';
   G_ERROR_COL := 'ITEM_ID';
   x_error_msg := 'Item Cannot be Updated On Existing Req Line';
END IF;
IF p_req_line.destination_type_code IS NOT NULL OR p_req_line.destination_type IS NOT NULL THEN
   x_return_status := 'E';
   G_ERROR_COL := 'DESTINATION_TYPE_CODE';
   x_error_msg := 'Destination Type Cannot be Updated On Existing Req Line';
END IF;
END val_line_non_upd_data;

FUNCTION validate_desttype(p_req_line IN OUT NOCOPY po_requisition_update_pub.req_line_rec_type) RETURN VARCHAR2
IS
l_flag VARCHAR2(1):='N';
BEGIN
	 SELECT 'Y',lookup_code
	 INTO l_flag,p_req_line.destination_type_code
   FROM po_lookup_codes plc
   WHERE plc.lookup_type = 'DESTINATION TYPE'
   AND (plc.lookup_code = p_req_line.destination_type_code OR plc.displayed_field = p_req_line.destination_type);

   IF p_req_line.destination_type_code = 'INVENTORY' and p_req_line.item_id is null THEN
       l_flag := 'N';
   END IF;

   RETURN L_FLAG;
EXCEPTION
 WHEN OTHERS THEN
   l_flag := 'E';
   RETURN l_flag;
END;

PROCEDURE populate_sourcinginfo(
	x_mode	IN	VARCHAR2,
  x_autosource_flag IN VARCHAR2,
	p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type
) IS
--<PKGCOMP R12 End>
l_module_name CONSTANT VARCHAR2(100) := 'populate_sourcinginfo';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
	x_item_id			NUMBER := NULL;
	x_category_id			NUMBER := NULL;
	x_dest_organization_id		NUMBER := NULL;
	x_dest_subinventory		VARCHAR2(10) := '';
	x_need_by_date			DATE := NULL;
	x_item_revision			VARCHAR2(3) := '';
	x_currency_code			VARCHAR2(15) := '';
	x_vendor_id			NUMBER := NULL;
	x_vendor_name			PO_VENDORS.VENDOR_NAME%TYPE := NULL; --Bug# 1813740 / Bug 2823775
	x_vendor_site_id		NUMBER := NULL;
	x_vendor_contact_id		NUMBER := NULL;
	x_source_organization_id	NUMBER := NULL;
	x_source_subinventory		VARCHAR2(10) := '';
	x_document_header_id		NUMBER := NULL;
	x_document_line_id		NUMBER := NULL;
	x_document_type_code		VARCHAR2(25) := '';
	x_document_line_num		NUMBER := NULL;
	x_buyer_id			NUMBER := NULL;
	x_vendor_product_num		VARCHAR2(240) := '';
	x_quantity			NUMBER := NULL;
	x_rate_type			VARCHAR2(30) := '';
	x_base_price			NUMBER := NULL;
	x_currency_price		NUMBER := NULL;
	x_discount			NUMBER := NULL;
	x_rate_date			DATE := NULL;
	x_rate				NUMBER := NULL;
	x_return_code			BOOLEAN := NULL;
	x_commodity_id			NUMBER := NULL;
	x_purchasing_uom		po_asl_attributes.purchasing_unit_of_measure%TYPE;
	x_uom_code			po_requisitions_interface.uom_code%TYPE;
	x_unit_of_measure		po_requisitions_interface.unit_of_measure%TYPE;
	--x_autosource_flag		po_requisitions_interface.autosource_flag%type;
	x_organization_id		NUMBER := NULL;
	x_conversion_rate		NUMBER := 1;
        x_item_buyer_id                 NUMBER;
        x_ga_flag                       VARCHAR2(1) := '';
        x_owning_org_id                 NUMBER;
        x_fsp_org_id                    NUMBER;
    --<Shared Proc FPJ START>
    x_suggested_vendor_site_code PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;
    l_buyer_ok                   VARCHAR2(1);
    --<Shared Proc FPJ END>

    l_negotiated_by_preparer_flag   PO_LINES_ALL.NEGOTIATED_BY_PREPARER_FLAG%TYPE;  -- PO DBI FPJ

    --<PKGCOMP R12 Start>
    l_asl_id               PO_ASL_DOCUMENTS.ASL_ID%TYPE;
    l_req_dist_sequence_id PO_REQUISITIONS_INTERFACE.req_dist_sequence_id%TYPE;
    l_primary_uom          MTL_SYSTEM_ITEMS.primary_unit_of_measure%TYPE;
    l_unit_of_issue        MTL_SYSTEM_ITEMS.unit_of_issue%TYPE;
    l_rounding_factor      MTL_SYSTEM_ITEMS.rounding_factor%TYPE;
    l_min_ord_qty          PO_ASL_ATTRIBUTES.min_order_qty%TYPE;
    l_fixed_lot_multiple   PO_ASL_ATTRIBUTES.fixed_lot_multiple%TYPE;
    l_uom_conversion_rate  NUMBER;
    l_enforce_full_lot_qty PO_SYSTEM_PARAMETERS.enforce_full_lot_quantities%TYPE;
    l_interface_source_code  PO_REQUISITIONS_INTERFACE.interface_source_code%TYPE;
    l_asl_purchasing_uom   PO_ASL_ATTRIBUTES.purchasing_unit_of_measure%TYPE; --<Bug#5137508>
    --<PKGCOMP R12 End>

    --<R12 STYLES PHASE II START>
    l_line_type_id     PO_REQUISITION_LINES_ALL.line_type_id%TYPE;
    l_destination_type PO_REQUISITION_LINES_ALL.destination_type_code%TYPE;
    l_progress NUMBER;

    p_multi_dist_flag VARCHAR2(1) := 'N';
    --<R12 STYLES PHASE II END>

BEGIN

  l_progress := 10;

      IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_mode:',x_mode);
              PO_LOG.stmt(d_module_base,l_progress,'x_autosource_flag:',x_autosource_flag);
      END IF;

  IF (x_mode = 'VENDOR') THEN

  l_progress := 20;

    BEGIN
		x_item_id  := p_req_line.item_id;
		x_category_id := p_req_line.category_id;
		x_dest_organization_id := p_req_line.destination_organization_id;
		x_dest_subinventory := p_req_line.destination_subinventory;
		x_need_by_date := NVL(p_req_line.need_by_date,SYSDATE);
		x_item_revision := p_req_line.item_revision;
		x_currency_code := p_req_line.currency_code;
		x_quantity := p_req_line.quantity;
		x_rate_type := p_req_line.rate_type;
                x_vendor_id := p_req_line.vendor_id;
                x_vendor_name := p_req_line.suggested_vendor_name; --Bug# 1813740
                x_vendor_site_id := p_req_line.vendor_site_id;
                x_suggested_vendor_site_code := p_req_line.suggested_vendor_location; --<Shared Proc FPJ>
                x_vendor_product_num := p_req_line.suggested_vendor_product_code;

    IF  p_req_line.unit_meas_lookup_code IS NOT NULL THEN
    BEGIN
		SELECT uom_code
    INTO x_uom_code
    FROM mtl_units_of_measure
    WHERE unit_of_measure = p_req_line.unit_meas_lookup_code;

    EXCEPTION
    WHEN OTHERS THEN
    x_uom_code := NULL;
    END;
    END IF;

		x_unit_of_measure := p_req_line.unit_meas_lookup_code;
                --<PKGCOMP R12 Start>
               l_req_dist_sequence_id := 1;
              -- l_interface_source_code
                --<PKGCOMP R12 End>
                --<R12 STYLES PHASE II START>
               l_line_type_id := p_req_line.line_type_id;
               l_destination_type  :=   p_req_line.destination_type_code;

    IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_item_id:',x_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_category_id:',x_category_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_dest_organization_id:',x_dest_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_dest_subinventory:',x_dest_subinventory);
              PO_LOG.stmt(d_module_base,l_progress,'x_need_by_date:',x_need_by_date);
              PO_LOG.stmt(d_module_base,l_progress,'x_item_revision:',x_item_revision);
              PO_LOG.stmt(d_module_base,l_progress,'x_currency_code:',x_currency_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_quantity:',x_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'x_rate_type:',x_rate_type);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_id:',x_vendor_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_name:',x_vendor_name);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_site_id:',x_vendor_site_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_suggested_vendor_site_code:',x_suggested_vendor_site_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_product_num:',x_vendor_product_num);
              PO_LOG.stmt(d_module_base,l_progress,'x_uom_code:',x_uom_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_unit_of_measure:',x_unit_of_measure);
              PO_LOG.stmt(d_module_base,l_progress,'l_req_dist_sequence_id:',l_req_dist_sequence_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_line_type_id:',l_line_type_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_destination_type:',l_destination_type);
      END IF;
                --<R12 STYLES PHASE II END>

	-- reinitialize values
    IF (x_autosource_flag = 'Y' OR ( x_autosource_flag = 'P' AND x_vendor_id
 IS NULL)) THEN
                x_vendor_id := NULL;
                x_vendor_name := NULL;  -- Bug# 1813740
                x_vendor_site_id := NULL;
                x_suggested_vendor_site_code := NULL; --<Shared Proc FPJ>
                x_vendor_product_num := NULL;
    END IF;

    l_progress := 30;

    IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_id:',x_vendor_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_name:',x_vendor_name);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_site_id:',x_vendor_site_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_suggested_vendor_site_code:',x_suggested_vendor_site_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_product_num:',x_vendor_product_num);
    END IF;
    -- DBI FPJ ** Begin
    IF x_document_type_code = 'BLANKET' THEN

        SELECT NEGOTIATED_BY_PREPARER_FLAG INTO l_negotiated_by_preparer_flag FROM PO_LINES_ALL
                WHERE
                PO_HEADER_ID = x_document_header_id AND LINE_NUM = x_document_line_num;

    ELSIF x_document_type_code = 'QUOTATION' THEN

        l_negotiated_by_preparer_flag := 'Y';

    ELSE

        l_negotiated_by_preparer_flag := 'N';

    END IF;
    -- DBI FPJ ** End
    l_progress := 40;

    IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_negotiated_by_preparer_flag:',l_negotiated_by_preparer_flag);
    END IF;

        x_document_header_id := NULL;
	x_document_line_id := NULL;
	x_document_type_code := NULL;
	x_document_line_num := NULL;
	x_vendor_contact_id := NULL;
--	x_vendor_product_num := NULL;
	x_purchasing_uom := NULL;
	x_buyer_id := NULL;

        --<PKGCOMP R12 Start>
        l_asl_id               := NULL;
        l_uom_conversion_rate  := 1;
        l_fixed_lot_multiple   := NULL;
        l_min_ord_qty          := NULL;
        l_primary_uom          := NULL;
        l_rounding_factor      := NULL;
        l_enforce_full_lot_qty := NULL;
        --<PKGCOMP R12 End>

/*      Bug # 1507557.
        The value of x_conversion_rate has to be initialised so that the
        conversion value of sourced record will not be carried to the
        next record.
*/
      x_conversion_rate := 1;

      l_progress := 50;
      IF x_dest_organization_id IS NULL THEN

       -- Get organization_id from financials_system_parameters.

            SELECT   inventory_organization_id
            INTO     x_organization_id
            FROM     financials_system_parameters;

      ELSE
           x_organization_id := x_dest_organization_id;
      END IF;

      IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_organization_id:',x_organization_id);
      END IF;

     IF (x_autosource_flag = 'Y' OR ( x_autosource_flag = 'P' AND x_vendor_id
 IS NULL)) THEN
        --<PKGCOMP R12 Start>
        --Added the parameter to get the asl_id for the ASL so that we can retrieve
	-- the order modifiers later in the procedure.
        --<PKGCOMP R12 End>

	PO_AUTOSOURCE_SV.autosource(
		'VENDOR',
		'REQ',
		x_item_id,
		x_category_id,   -- Bug# 5524728,
		x_dest_organization_id,
		x_dest_subinventory,
		x_need_by_date,
		x_item_revision,
		x_currency_code,
		x_vendor_id,
		x_vendor_site_id,
		x_vendor_contact_id,
		x_source_organization_id,
		x_source_subinventory,
		x_document_header_id,
		x_document_line_id,
		x_document_type_code,
		x_document_line_num,
		x_buyer_id,
		x_vendor_product_num,
		x_purchasing_uom,
                l_asl_id  --<PKGCOMP R12>
                --<R12 STYLES PHASE II START>
               ,NULL,
                l_line_type_id,
                l_destination_type,
                NULL
                --<R12 STYLES PHASE II END>
                );
     ELSE

           l_progress := 60;
            -- Get buyer_id from item definition.  If we cannot get buyer_id from
            -- the item definition then we will try to get it from the source document.

            IF (x_item_id IS NOT NULL) THEN

               SELECT   msi.buyer_id
               INTO     x_buyer_id
               FROM     mtl_system_items msi
               WHERE    msi.inventory_item_id = x_item_id
               AND      msi.organization_id = x_organization_id;

               x_item_buyer_id := x_buyer_id;

            END IF;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_buyer_id:',x_buyer_id);
            END IF;

            --<Shared Proc FPJ START>
            --To accommodate Planning calls: We do vendor site sourcing when
            --vendor site code is provided (vendor site_id is not provided)

            --<PKGCOMP R12 Start>
            -- Earlier hardcoded value of NULL was passed for asl_id in document_sourcing.
            -- But now we get back the value from document_sourcing procedure in l_asl_id.
            --<PKGCOMP R12 End>

	        IF (x_autosource_flag = 'P' AND x_vendor_id IS NOT NULL
                  AND x_vendor_site_id IS NULL
                  AND x_suggested_vendor_site_code IS NOT NULL) THEN

             PO_AUTOSOURCE_SV.document_sourcing(
                	x_item_id             	 	=> x_item_id,
                	x_vendor_id           		=> x_vendor_id,
                	x_destination_doc_type	    => 'REQ',
                	x_organization_id     		=> x_organization_id,
                	x_currency_code       		=> x_currency_code,
                	x_item_rev              	=> x_item_revision,
                	x_autosource_date     		=> x_need_by_date,
                	x_vendor_site_id     		=> x_vendor_site_id,
                	x_document_header_id	    => x_document_header_id,
                	x_document_type_code	    => x_document_type_code,
                	x_document_line_num 	    => x_document_line_num,
                	x_document_line_id   		=> x_document_line_id,
                	x_vendor_contact_id  		=> x_vendor_contact_id,
                	x_vendor_product_num	    => x_vendor_product_num,
                	x_buyer_id          		=> x_buyer_id,
                	x_purchasing_uom    		=>  x_purchasing_uom,
                        x_asl_id                    => l_asl_id, --<PKGCOMP R12>
                	x_multi_org        	    	=> 'N',
	        	p_vendor_site_sourcing_flag =>  'Y',
 	        	p_vendor_site_code  		=> x_suggested_vendor_site_code,
			p_category_id                =>x_category_id -- Bug# 5524728
                        --<R12 STYLES PHASE II START>
                       ,p_line_type_id     => l_line_type_id,
                        p_purchase_basis   => NULL,
                        p_destination_type => l_destination_type,
                        p_style_id         => NULL
                        --<R12 STYLES PHASE II END>
                        );
	        ELSE
                   --Its not required to do vendor site sourcing
 	           PO_AUTOSOURCE_SV.document_sourcing(
                	x_item_id             	 	=> x_item_id,
                	x_vendor_id           		=> x_vendor_id,
                	x_destination_doc_type	    => 'REQ',
                	x_organization_id     		=> x_organization_id,
                	x_currency_code       		=> x_currency_code,
                	x_item_rev              	=> x_item_revision,
                	x_autosource_date     		=> x_need_by_date,
                	x_vendor_site_id     		=> x_vendor_site_id,
                	x_document_header_id	    => x_document_header_id,
                	x_document_type_code	    => x_document_type_code,
                	x_document_line_num 	    => x_document_line_num,
                	x_document_line_id   		=> x_document_line_id,
                	x_vendor_contact_id  		=> x_vendor_contact_id,
                	x_vendor_product_num	    => x_vendor_product_num,
                	x_buyer_id          		=> x_buyer_id,
                	x_purchasing_uom    		=>  x_purchasing_uom,
                        x_asl_id                    => l_asl_id, --<PKGCOMP R12>
                	x_multi_org        	    	=> 'N',
	        	p_vendor_site_sourcing_flag =>  'N',
 	        	p_vendor_site_code  		=> NULL,
			p_category_id                =>x_category_id -- Bug# 5524728
                        --<R12 STYLES PHASE II START>
                       ,p_line_type_id     => l_line_type_id,
                        p_purchase_basis   => NULL,
                        p_destination_type => l_destination_type,
                        p_style_id         => NULL
                        --<R12 STYLES PHASE II END>
                        );
             END IF;
             --<Shared Proc FPJ END>

             l_progress := 70;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_buyer_id:',x_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_document_header_id:',x_document_header_id);
            END IF;

              --<Shared Proc FPJ START>
              IF x_document_header_id IS NOT NULL
                 AND x_buyer_id IS NOT NULL
              THEN
                      --The buyer on Source Document should be in the same business group as
                     --the requesting operating unit(current OU) or the profile option HR: Cross
                     --Business Group should be set to 'Y'. These two conditions are checked in
                     --view definition of per_people_f
                     BEGIN
                             SELECT 'Y'
                             INTO l_buyer_ok
                             FROM per_people_f ppf
                             WHERE x_buyer_id = ppf.person_id
                             AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date
                                     AND NVL(ppf.effective_end_date, SYSDATE +1);
                     EXCEPTION WHEN OTHERS THEN
                              x_buyer_id := NULL;
                     END;

              END IF;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_buyer_id:',x_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_document_header_id:',x_document_header_id);
            END IF;
              --<Shared Proc FPJ END>
        END IF;

        --<PKGCOMP R12 Start>

        --* Removing the code for bug 3810029 fix as we call the
        --  pocis_unit_of_measure for UOM defaulting before calling
        --  the sourcing procedure in reqimport code.

        -- We modify the quantity on the req line only if it is not null
        IF x_quantity IS NOT NULL THEN
            --* Retrieving the primary_unit_of_measure and rounding_factor
            -- from Item Masters

            BEGIN
              SELECT msi.primary_unit_of_measure, msi.rounding_factor
              INTO   l_primary_uom, l_rounding_factor
              FROM   mtl_system_items msi
              WHERE  msi.inventory_item_id = x_item_id
              AND    msi.organization_id = x_organization_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_primary_uom     := NULL;
                l_rounding_factor := NULL;
            END;

            l_progress := 80;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_primary_uom:',l_primary_uom);
              PO_LOG.stmt(d_module_base,l_progress,'l_rounding_factor:',l_rounding_factor);
              PO_LOG.stmt(d_module_base,l_progress,'x_purchasing_uom:',x_purchasing_uom);
            END IF;

        --* Retrieving the min_order_qty, fixed_lot_multiple from PO_ASL_ATTRIBUTES table,
        --  only if primary_uom of the item is same as the UOM mentioned on the requisition.

        --* This if condition is required as Order Modifiers will only be applied in case
        --  the above condition is true.


            --* Get the conversion rate between the Req's UOM and the Sourcing document's UOM
            --  if the source document exists else get the conversion rate between Req's UOM and
            --  ASL's Purchasing UOM if an ASL exists.

            --* Sourcing Document UOM is given preference over the ASL's Purchasing UOM.
            l_progress := 90;
            IF NVL(x_purchasing_uom, x_unit_of_measure) <> x_unit_of_measure THEN
              l_uom_conversion_rate := NVL(po_uom_s.po_uom_convert(x_unit_of_measure,
                                                                   x_purchasing_uom,
                                                                   x_item_id),1);
            END IF;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_uom_conversion_rate:',l_uom_conversion_rate);
            END IF;
            l_progress := 100;

             BEGIN
 	                   SELECT enforce_full_lot_quantities
 	                   INTO l_enforce_full_lot_qty
 	                   FROM po_system_parameters;
 	            EXCEPTION WHEN OTHERS THEN
 	              l_enforce_full_lot_qty := NULL;
 	            END;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_uom_conversion_rate:',l_uom_conversion_rate);
            END IF;

            -- Calling the procedure for applying order modifier, quantity conversion and rounding
            --  p_multi_dist_flag is passed as 'N' by default so currently no issue.
            -- if we have to pass it as 'Y' then need to write seperate code for procee req quantity.
            PO_AUTOSOURCE_SV.process_req_qty(p_mode                 => x_mode,
                                             p_request_id           => 1,
                                             p_multi_dist_flag      => p_multi_dist_flag,
                                             p_req_dist_sequence_id => l_req_dist_sequence_id,
                                             p_min_order_qty        => l_min_ord_qty,
                                             p_fixed_lot_multiple   => l_fixed_lot_multiple,
                                             p_uom_conversion_rate  => l_uom_conversion_rate,
                                             p_rounding_factor      => l_rounding_factor,
                                             p_enforce_full_lot_qty => l_enforce_full_lot_qty,
                                             x_quantity             => x_quantity);
        END IF;
        --<PKGCOMP R12 End>

  --Bug 14610956 start

     l_progress := 110;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_document_line_id:',x_document_line_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_product_num:',x_vendor_product_num);
              PO_LOG.stmt(d_module_base,l_progress,'l_asl_id:',l_asl_id);
            END IF;

   IF  x_document_line_id IS NULL AND
       x_vendor_product_num IS NULL AND
       l_asl_id IS NOT NULL THEN

   BEGIN

        SELECT primary_vendor_item
        INTO   x_vendor_product_num
        FROM   po_approved_supplier_lis_val_v
        WHERE  asl_id = l_asl_id;

   EXCEPTION
   WHEN OTHERS THEN

        x_vendor_product_num := NULL;

   END;

   END IF;

  --Bug 14610956 End
           l_progress := 120;

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_id:',p_req_line.vendor_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_id:',x_vendor_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_name:',x_vendor_name);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.suggested_vendor_name:',p_req_line.suggested_vendor_name);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_site_id:',x_vendor_site_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_site_id:',p_req_line.vendor_site_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_buyer_id:',x_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.suggested_buyer_id:',p_req_line.suggested_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_document_header_id:',x_document_header_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_document_line_num:',x_document_line_num);
              PO_LOG.stmt(d_module_base,l_progress,'x_document_type_code:',x_document_type_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_contact_id:',x_vendor_contact_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.unit_meas_lookup_code:',p_req_line.unit_meas_lookup_code);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_contact_id:',p_req_line.vendor_contact_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.suggested_vendor_product_code:',p_req_line.suggested_vendor_product_code);
              PO_LOG.stmt(d_module_base,l_progress,'x_vendor_product_num:',x_vendor_product_num);
              PO_LOG.stmt(d_module_base,l_progress,'x_purchasing_uom:',x_purchasing_uom);
              PO_LOG.stmt(d_module_base,l_progress,'x_unit_of_measure:',x_unit_of_measure);
              PO_LOG.stmt(d_module_base,l_progress,'x_quantity:',x_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'l_negotiated_by_preparer_flag:',l_negotiated_by_preparer_flag);
            END IF;

   -- Bug 1813740 - When suggested vendor name was populated in the Interface
   -- table and if Sourcing takes place and brings in a new Vendor Id the
   -- Vendor Name was not changed to that of the new vendor Id. To avoid this
   -- we now NULL out the vendor name when autosource flag is 'Y'. The logic in
   -- pocis.opc takes care of populating the suggested_vendor_name if it
   -- is NULL.
   -- Bug 3669203: The vendorname should only be nulled out if autosourcing
   -- brought back a new vendor.
   -- Bug 3810029 : changed the uom update : see above

   --<PKGCOMP R12 Start>
      -- Update the po_requisitions_interface table with the calculated quantity returned
      -- by the above procedure instead of computing the new quantity in the update statement.

   	p_req_line.vendor_id := NVL(x_vendor_id,p_req_line.vendor_id);
    /*IF p_req_line.vendor_id IS NOT NULL

      SELECT pv.vendor_name
      INTO p_req_line.suggested_vendor_name
      FROM po_vendors pv
      WHERE pv.vendor_id = p_req_line.vendor_id;
    END IF;

    IF p_req_line.vendor_site_id IS NOT NULL THEN
      SELECT vendor_site_code
      INTO p_req_line.suggested_vendor_location
      FROM po_vendor
    */
		p_req_line.vendor_site_id := NVL(x_vendor_site_id,p_req_line.vendor_site_id);
		p_req_line.suggested_buyer_id := NVL(p_req_line.suggested_buyer_id, x_buyer_id);
		p_req_line.blanket_po_header_id := x_document_header_id;
		p_req_line.blanket_po_line_num	:= x_document_line_num;
		p_req_line.document_type_code := x_document_type_code;
                -- Bug 4523369 START
                -- If autosourcing did not return a vendor site, keep the
                -- current vendor contact.

            SELECT  DECODE(x_vendor_site_id,
                         NULL, p_req_line.vendor_contact_id,
                         x_vendor_contact_id)
            INTO p_req_line.vendor_contact_id
            FROM dual;
                -- Bug 4523369 END
		p_req_line.suggested_vendor_product_code :=
			NVL(p_req_line.suggested_vendor_product_code, x_vendor_product_num);
		p_req_line.unit_meas_lookup_code := NVL(x_purchasing_uom,NVL(x_unit_of_measure,p_req_line.unit_meas_lookup_code));
		p_req_line.quantity := x_quantity; --<PKGCOMP R12>
    p_req_line.negotiated_by_preparer_flag := l_negotiated_by_preparer_flag; -- need to add in rec grp   -- DBI FPJ

   	EXCEPTION
    WHEN OTHERS THEN
      PO_MESSAGE_S.sql_error('PO_AUTOSOURCE_SV.L_GET_REQ_INFO_VENDOR_CSR',l_progress,SQLCODE);
    END;

   --<PKGCOMP R12 End>


  ELSIF (x_mode = 'INVENTORY') THEN

  l_progress := 130;


    --<PKGCONS Start>
    --Fecthing the value of ENFORCE_FULL_LOT_QUANTITY for determining whether
    --UOM conversion and rounding operations are to be performed on the
    --Requisition.
    SELECT enforce_full_lot_quantities
    INTO l_enforce_full_lot_qty
    FROM po_system_parameters;
    --<PKGCONS End>

	x_buyer_id := NULL;
	x_source_organization_id := NULL;
	x_source_subinventory := NULL;
	x_document_header_id := NULL;
	x_document_line_id := NULL;
	x_document_type_code := NULL;
	x_document_line_num := NULL;
	x_vendor_product_num := NULL;
	x_purchasing_uom := NULL;
        --<PKGCOMP R12 Start>
        x_quantity             := NULL;
        x_unit_of_measure      := NULL;
        l_uom_conversion_rate  := 1;
        l_fixed_lot_multiple   := NULL;
        l_min_ord_qty          := NULL;
        l_unit_of_issue        := NULL;
        l_req_dist_sequence_id := NULL;
        l_rounding_factor      := NULL;
        l_asl_id               := NULL;
        --<PKGCOMP R12 End>



    SELECT DECODE(p_req_line.item_id, NULL, p_req_line.category_id, NULL)
    INTO x_commodity_id
    FROM dual;

		x_item_id := p_req_line.item_id;
		x_dest_subinventory := p_req_line.destination_subinventory;
		x_dest_organization_id := p_req_line.destination_organization_id;
		x_source_organization_id := p_req_line.source_organization_id;
		x_source_subinventory := p_req_line.source_subinventory;
		x_need_by_date := NVL(p_req_line.need_by_date,SYSDATE);
                --<PKGCOMP R12 Start>
                x_quantity := p_req_line.quantity;
                x_unit_of_measure := p_req_line.unit_meas_lookup_code;
                l_req_dist_sequence_id := 1;
                l_interface_source_code := NULL;
                --<PKGCOMP R12 End>
                --<R12 STYLES PHASE II START>
                l_line_type_id  := p_req_line.line_type_id;
                l_destination_type := p_req_line.destination_type_code;

      IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_enforce_full_lot_qty:',l_enforce_full_lot_qty);
              PO_LOG.stmt(d_module_base,l_progress,'x_commodity_id:',x_commodity_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_item_id:',x_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_dest_subinventory:',x_dest_subinventory);
              PO_LOG.stmt(d_module_base,l_progress,'x_dest_organization_id:',x_dest_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_source_organization_id:',x_source_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_source_subinventory:',x_source_subinventory);
              PO_LOG.stmt(d_module_base,l_progress,'x_need_by_date:',x_need_by_date);
              PO_LOG.stmt(d_module_base,l_progress,'x_quantity:',x_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'x_unit_of_measure:',x_unit_of_measure);
              PO_LOG.stmt(d_module_base,l_progress,'l_req_dist_sequence_id:',l_req_dist_sequence_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_interface_source_code:',l_interface_source_code);
              PO_LOG.stmt(d_module_base,l_progress,'l_line_type_id:',l_line_type_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_destination_type:',l_destination_type);
       END IF;


                --<R12 STYLES PHASE II END>

        --<PKGCOMP R12 Start>
        -- Added the parameter to get the asl_id for the ASL so that we can retrieve the
        -- order modifiers later in the procedure.
        --<PKGCOMP R12 End>
	PO_AUTOSOURCE_SV.autosource(
		'INVENTORY',
		'REQ',
		x_item_id,
		x_commodity_id,
		x_dest_organization_id,
		x_dest_subinventory,
		x_need_by_date,
		x_item_revision,
		x_currency_code,
		x_vendor_id,
		x_vendor_site_id,
		x_vendor_contact_id,
		x_source_organization_id,
		x_source_subinventory,
		x_document_header_id,
		x_document_line_id,
		x_document_type_code,
		x_document_line_num,
		x_buyer_id,
		x_vendor_product_num,
		x_purchasing_uom,
		l_asl_id --<PKGCOMP R12>
                --<R12 STYLES PHASE II START>
               ,NULL,
                l_line_type_id,
                l_destination_type,
                NULL
                --<R12 STYLES PHASE II END>
                );

       l_progress := 140;

	--<PKGCOMP R12 Start>
        --Retrieving the primary_unit_of_measure and rounding_factor
        --from Item Masters of source organisation

	BEGIN
          SELECT msi.primary_unit_of_measure, msi.rounding_factor, msi.unit_of_issue
          INTO   l_primary_uom, l_rounding_factor, l_unit_of_issue
          FROM   mtl_system_items msi
          WHERE  msi.inventory_item_id = x_item_id
          AND    msi.organization_id = x_source_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_primary_uom     := NULL;
            l_rounding_factor := NULL;
            l_unit_of_issue   := NULL;
        END;

        IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_item_id:',x_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_source_organization_id:',x_source_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_primary_uom:',l_primary_uom);
              PO_LOG.stmt(d_module_base,l_progress,'l_rounding_factor:',l_rounding_factor);
              PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_issue:',l_unit_of_issue);
       END IF;

        -- We can apply the order modifiers or do any processing on the req quantity
        -- only if it is not null
        IF x_quantity IS NOT NULL THEN

        l_progress := 150;

            --* Get the conversion rate between the Req's UOM and the unit of issue.
            --  only if enforce_full_lot_quantities is set to 'ADVISORY' or 'MANDATORY'
            IF ( (NVL(l_unit_of_issue, x_unit_of_measure) <> x_unit_of_measure)
                 AND (NVL(l_enforce_full_lot_qty,'NONE') <> 'NONE')
               ) THEN
                 l_uom_conversion_rate := NVL(po_uom_s.po_uom_convert(x_unit_of_measure,
                                                                      l_unit_of_issue,
                                                                      x_item_id),1);
            END IF;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_item_id:',x_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_uom_conversion_rate:',l_uom_conversion_rate);
              PO_LOG.stmt(d_module_base,l_progress,'l_enforce_full_lot_qty:',l_enforce_full_lot_qty);
              PO_LOG.stmt(d_module_base,l_progress,'x_unit_of_measure:',x_unit_of_measure);
              PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_issue:',l_unit_of_issue);
           END IF;

            -- Calling the procedure for applying order modifier, quantity conversion and rounding
            PO_AUTOSOURCE_SV.process_req_qty(p_mode                 => x_mode,
                                             p_request_id           => 1,
                                             p_multi_dist_flag      => p_multi_dist_flag,
                                             p_req_dist_sequence_id => l_req_dist_sequence_id,
                                             p_min_order_qty        => l_min_ord_qty,
                                             p_fixed_lot_multiple   => l_fixed_lot_multiple,
                                             p_uom_conversion_rate  => l_uom_conversion_rate,
                                             p_rounding_factor      => l_rounding_factor,
                                             p_enforce_full_lot_qty => l_enforce_full_lot_qty,
                                             x_quantity             => x_quantity);

        END IF;
        -- Updating the quantity and the unit_of_measure in the po_requisitions_interface
        -- after the quantity conversion.

        -- We need to put the l_enforce_full_lot_qty in the decode as there should be no
        -- UOM conversion if enforce_full_lot_quantities is set to 'NONE'

        l_progress := 160;

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_source_organization_id:',x_source_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_source_subinventory:',x_source_subinventory);
              PO_LOG.stmt(d_module_base,l_progress,'x_buyer_id:',x_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.suggested_buyer_id:',p_req_line.suggested_buyer_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_issue:',l_unit_of_issue);
              PO_LOG.stmt(d_module_base,l_progress,'x_unit_of_measure:',x_unit_of_measure);
           END IF;


            p_req_line.source_organization_id := x_source_organization_id;
            p_req_line.source_subinventory    := x_source_subinventory;
            p_req_line.suggested_buyer_id     := NVL(p_req_line.suggested_buyer_id, x_buyer_id);
            p_req_line.quantity               := x_quantity;
            SELECT DECODE(NVL(l_enforce_full_lot_qty, 'NONE'),
                                               'NONE',x_unit_of_measure,
                                               NVL(l_unit_of_issue,x_unit_of_measure))
            INTO  p_req_line.unit_meas_lookup_code
            FROM dual;
        --<PKGCOMP R12 End>

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    NULL;
END populate_sourcinginfo;

PROCEDURE Set_Break_price(
  x_autosource_flag IN VARCHAR2,
	p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type
	)
 IS

 l_module_name CONSTANT VARCHAR2(100) := 'set_break_price';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

 l_src_blanket_header_id 	po_requisition_lines.blanket_po_header_id%TYPE;
 l_src_blanket_line_num	po_requisition_lines.blanket_po_line_num%TYPE;
 l_quantity			po_requisition_lines.quantity%TYPE;
 l_deliver_to_location		po_requisition_lines.deliver_to_location_id%TYPE;
 l_currency_code		po_requisition_lines.currency_code%TYPE;
 l_rate_type			po_requisition_lines.rate_type%TYPE;
 l_need_by_date		po_requisition_lines.need_by_date%TYPE;
 l_destination_org		po_requisition_lines.destination_organization_id%TYPE;
 l_base_price_out		po_requisition_lines.unit_price%TYPE;
 l_currency_price_out		po_requisition_lines.currency_unit_price%TYPE;
 l_discount_out		NUMBER;
 l_currency_code_out		po_requisition_lines.currency_code%TYPE;
 l_rate_type_out		po_requisition_lines.rate_type%TYPE;
 l_rate_date_out		po_requisition_lines.rate_date%TYPE;
 l_rate_out			po_requisition_lines.rate%TYPE;
 l_uom				po_requisitions_interface.unit_of_measure%TYPE;
 l_price_break_id              po_line_locations_all.line_location_id%TYPE;  -- <SERVICES FPJ>
 l_progress			NUMBER;

 -- <FPJ Advanced Price START>
 l_org_id 			po_requisitions_interface.org_id%TYPE;
 l_requisition_header_id 	po_requisition_lines.requisition_header_id%TYPE;
 l_requisition_line_id 	po_requisition_lines.requisition_line_id%TYPE;
 l_creation_date		po_requisitions_interface.creation_date%TYPE;
 l_item_id 			po_requisitions_interface.item_id%TYPE;
 l_item_revision 		po_requisitions_interface.item_revision%TYPE;
 l_category_id 		po_requisitions_interface.category_id%TYPE;
 l_line_type_id 		po_requisitions_interface.line_type_id%TYPE;
 l_suggested_vendor_item_num 	po_requisitions_interface.suggested_vendor_item_num%TYPE;
 l_suggested_vendor_id 	po_requisitions_interface.suggested_vendor_id%TYPE;
 l_suggested_vendor_site_id 	po_requisitions_interface.suggested_vendor_site_id%TYPE;
 -- Bug 3343892
 l_base_unit_price 		po_requisitions_interface.base_unit_price%TYPE;
 l_base_unit_price_out		po_requisition_lines.base_unit_price%TYPE;
 -- <FPJ Advanced Price END>

BEGIN

   l_progress :=10;

	l_src_blanket_header_id := p_req_line.blanket_po_header_id;
  l_src_blanket_line_num := p_req_line.blanket_po_line_num;
	l_quantity := p_req_line.quantity;
  l_deliver_to_location := p_req_line.deliver_to_location_id;
  l_currency_code := p_req_line.currency_code;
	l_rate_type := p_req_line.rate_type;
  l_need_by_date := p_req_line.need_by_date;
  l_destination_org := p_req_line.destination_organization_id;
   l_uom := p_req_line.unit_meas_lookup_code;
	-- <FPJ Advanced Price START>
	l_org_id := p_req_line.org_id;
	l_requisition_header_id := p_req_line.requisition_header_id;
	l_requisition_line_id := p_req_line.requisition_line_id;
	l_creation_date := SYSDATE;         -- need to add
	l_item_id := p_req_line.item_id;
	l_item_revision := p_req_line.item_revision;
	l_category_id := p_req_line.category_id;
	l_line_type_id := p_req_line.line_type_id;
	l_suggested_vendor_item_num := p_req_line.suggested_vendor_product_code;
	l_suggested_vendor_id := p_req_line.vendor_id;
	l_suggested_vendor_site_id := p_req_line.vendor_site_id;
	-- Bug 3343892
	l_base_unit_price := p_req_line.base_unit_price;

  IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_autosource_flag:',x_autosource_flag);
              PO_LOG.stmt(d_module_base,l_progress,'l_src_blanket_header_id:',l_src_blanket_header_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_src_blanket_line_num:',l_src_blanket_line_num);
              PO_LOG.stmt(d_module_base,l_progress,'l_quantity:',l_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'l_deliver_to_location:',l_deliver_to_location);
              PO_LOG.stmt(d_module_base,l_progress,'l_currency_code:',l_currency_code);
              PO_LOG.stmt(d_module_base,l_progress,'l_rate_type:',l_rate_type);
              PO_LOG.stmt(d_module_base,l_progress,'l_need_by_date:',l_need_by_date);
              PO_LOG.stmt(d_module_base,l_progress,'l_destination_org:',l_destination_org);
              PO_LOG.stmt(d_module_base,l_progress,'l_uom:',l_uom);
              PO_LOG.stmt(d_module_base,l_progress,'l_org_id:',l_org_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_requisition_header_id:',l_requisition_header_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_requisition_line_id:',l_requisition_line_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_creation_date:',l_creation_date);
              PO_LOG.stmt(d_module_base,l_progress,'l_item_id:',l_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_item_revision:',l_item_revision);
              PO_LOG.stmt(d_module_base,l_progress,'l_category_id:',l_category_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_line_type_id:',l_line_type_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_suggested_vendor_item_num:',l_suggested_vendor_item_num);
              PO_LOG.stmt(d_module_base,l_progress,'l_suggested_vendor_id:',l_suggested_vendor_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_suggested_vendor_site_id:',l_suggested_vendor_site_id);
              PO_LOG.stmt(d_module_base,l_progress,'l_base_unit_price:',l_base_unit_price);
      END IF;
	-- <FPJ Advanced Price END>


   l_progress :=20;
    po_price_break_grp.get_price_break
    (  p_source_document_header_id	=> l_src_blanket_header_id
    ,  p_source_document_line_num	=> l_src_blanket_line_num
    ,  p_in_quantity			=> l_quantity
    ,  p_unit_of_measure		=> l_uom
    ,  p_deliver_to_location_id		=> l_deliver_to_location
    ,  p_required_currency		=> l_currency_code
    ,  p_required_rate_type		=> l_rate_type
    ,  p_need_by_date			=> l_need_by_date		--  <TIMEPHASED FPI>
    ,  p_destination_org_id		=> l_destination_org		--  <TIMEPHASED FPI>
       -- <FPJ Advanced Price START>
    ,  p_org_id				=> l_org_id
    ,  p_supplier_id			=> l_suggested_vendor_id
    ,  p_supplier_site_id		=> l_suggested_vendor_site_id
    ,  p_creation_date			=> l_creation_date
    ,  p_order_header_id		=> l_requisition_header_id
    ,  p_order_line_id			=> l_requisition_line_id
    ,  p_line_type_id			=> l_line_type_id
    ,  p_item_revision			=> l_item_revision
    ,  p_item_id			=> l_item_id
    ,  p_category_id			=> l_category_id
    ,  p_supplier_item_num		=> l_suggested_vendor_item_num
    -- Bug 3343892
    ,  p_in_price			=> l_base_unit_price
    ,  x_base_unit_price		=> l_base_unit_price_out
       -- <FPJ Advanced Price END>
    ,  x_base_price			=> l_base_price_out
    ,  x_currency_price			=> l_currency_price_out
    ,  x_discount			=> l_discount_out
    ,  x_currency_code			=> l_currency_code_out
    ,  x_rate_type                 	=> l_rate_type_out
    ,  x_rate_date                 	=> l_rate_date_out
    ,  x_rate                      	=> l_rate_out
    ,  x_price_break_id            	=> l_price_break_id 		-- <SERVICES FPJ>
    );

   l_progress := 30;

     IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_base_price_out:',l_base_price_out);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'l_base_unit_price_out:',l_base_unit_price_out);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.base_unit_price:',p_req_line.base_unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'l_currency_price_out:',l_currency_price_out);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.currency_unit_price:',p_req_line.currency_unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'l_currency_code_out:',l_currency_code_out);
              PO_LOG.stmt(d_module_base,l_progress,'l_rate_type_out:',l_rate_type_out);
              PO_LOG.stmt(d_module_base,l_progress,'l_rate_date_out:',l_rate_date_out);
              PO_LOG.stmt(d_module_base,l_progress,'l_rate_out:',l_rate_out);
      END IF;


	    p_req_line.unit_price := NVL(l_base_price_out, p_req_line.unit_price);
      p_req_line.base_unit_price :=  NVL(l_base_unit_price_out, p_req_line.base_unit_price);
	    p_req_line.currency_unit_price := NVL(l_currency_price_out, p_req_line.currency_unit_price);
	    p_req_line.currency_code := l_currency_code_out;
	    p_req_line.rate_type := l_rate_type_out;
	    p_req_line.rate_date := l_rate_date_out;
	    p_req_line.rate := l_rate_out;


   l_progress :=40;

   EXCEPTION
	WHEN OTHERS THEN

    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,SQLERRM);
    END IF;
	po_message_s.sql_error('set_break_price', l_progress, SQLCODE);
END Set_Break_Price;

PROCEDURE calculate_secondaryqty
( p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
	x_return_status OUT NOCOPY  VARCHAR2,
	x_error_msg OUT NOCOPY  VARCHAR2
)


IS

l_module_name CONSTANT VARCHAR2(100) := 'calculate_secondaryqty';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_progress               NUMBER;

  l_rec PO_INTERFACE_ERRORS%ROWTYPE;
  l_rtn_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_row_id ROWID;


  l_item_um2		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_item_id		MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;
  l_tracking_qty_ind	MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE;
  l_secondary_default_ind MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;


  l_item_unit_of_measure_s	MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
  l_item_um2_s		MTL_UNITS_OF_MEASURE.UOM_CODE%TYPE;
  l_tracking_qty_ind_s	MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND%TYPE;
  l_secondary_default_ind_s MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;
  l_unit_of_measure_s   MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;

  l_sec_qty_source      NUMBER;

CURSOR Cr_item_attr(p_inv_item_id IN NUMBER,p_organization_id IN NUMBER) IS
SELECT	m.tracking_quantity_ind,
	m.secondary_uom_code,
	m.secondary_default_ind
FROM	mtl_system_items m
WHERE	m.inventory_item_id = p_inv_item_id
AND     m.organization_id = p_organization_id;

BEGIN

-- For bug 16278564 changing precision to 5 in all INV calls

l_progress := 10;
--Loop for every record in the interface table for the current concurrent request.

  l_item_um2		:= NULL;
  l_tracking_qty_ind	:= NULL;
  l_secondary_default_ind := NULL;

  l_tracking_qty_ind_s	       := NULL;
  l_item_um2_s		       := NULL;
  l_secondary_default_ind_s    := NULL;
  l_unit_of_measure_s          := NULL;
  l_sec_qty_source	:= NULL;

       IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.item_id:',p_req_line.item_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.destination_organization_id:',p_req_line.destination_organization_id);
        END IF;


  --Only where item_id is specified.
  IF p_req_line.item_id IS NOT NULL THEN

    -- Get Item Attributes
    BEGIN
       OPEN Cr_item_attr(p_req_line.item_id, p_req_line.destination_organization_id);
       FETCH Cr_item_attr INTO  l_tracking_qty_ind,
  	       			l_item_um2		,
  	       			l_secondary_default_ind;
       CLOSE Cr_item_attr;
    END;
    l_progress := 20;

      IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_tracking_qty_ind:',l_tracking_qty_ind);
              PO_LOG.stmt(d_module_base,l_progress,'l_item_um2:',l_item_um2);
              PO_LOG.stmt(d_module_base,l_progress,'l_secondary_default_ind:',l_secondary_default_ind);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_uom_code:',p_req_line.secondary_uom_code);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_quantity:',p_req_line.secondary_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.quantity:',p_req_line.quantity);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.unit_meas_lookup_code:',p_req_line.unit_meas_lookup_code);
        END IF;

    --If secondary quantity is not provided then compute it and update interface table.
    IF p_req_line.secondary_uom_code IS NOT NULL AND
       l_tracking_qty_ind = 'PS' THEN

       IF (p_req_line.secondary_quantity IS NULL OR
           l_secondary_default_ind = 'F')
       THEN

          p_req_line.secondary_quantity := INV_CONVERT.inv_um_convert(
                                                  item_id        =>  p_req_line.item_id,
                                                  PRECISION	 =>  5,
                                                  from_quantity  =>  p_req_line.quantity,
                                                  from_unit      => NULL,
                                                  to_unit        => NULL,
                                                  from_name	 =>  p_req_line.unit_meas_lookup_code ,
                                                  to_name	 =>  p_req_line.secondary_uom_code );
          l_progress := 30;
          IF p_req_line.secondary_quantity <=0 THEN

                x_return_status :='E';
        fnd_message.set_name ('INV','INV_NO_CONVERSION_ERR');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('INV','INV_NO_CONVERSION_ERR');
        G_ERROR_COL := 'SECONDARY_QUANTITY';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;
          END IF;
          l_progress := 40;
          IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_quantity:',p_req_line.secondary_quantity);
        END IF;

       --If secondary quantity is specified then check deviation for type Default and No Default items
       --for fixed type items do the conversion and update interface table.
       ELSE
          l_progress := 50;

          IF INV_CONVERT.within_deviation(
                      p_organization_id      =>  p_req_line.destination_organization_id ,
                      p_inventory_item_id    =>  p_req_line.item_id,
                      p_lot_number           =>  NULL ,
                      p_precision            =>  5 ,
                      p_quantity             =>  p_req_line.quantity,
                      p_unit_of_measure1     =>  p_req_line.unit_meas_lookup_code ,
                      p_quantity2            =>  p_req_line.secondary_quantity ,
                      p_unit_of_measure2     =>  p_req_line.secondary_uom_code,
                      p_uom_code1            =>  NULL,
                      p_uom_code2            =>  NULL) = 0 THEN



             l_progress := 60;
                   x_return_status :='E';
                x_error_msg := 'secondary_quantity is not within deviation';
                G_ERROR_COL := 'SECONDARY_QUANTITY';
                IF PO_LOG.d_stmt THEN
                 PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
                END IF;
              RETURN;


             l_progress := 70;
          END IF; /*NOT INV_CONVERT.within_deviation( */
       END IF; /*cr_rec.secondary_quantity IS NULL*/
    --Since item is not dual um controlled update all secondary attributes to NULL
    /*ELSIF l_tracking_qty_ind = 'P' THEN
       UPDATE po_requisitions_interface
       SET    secondary_quantity = NULL,
              secondary_uom_code = NULL,
              secondary_unit_of_measure = NULL
       WHERE  rowid = cr_rec.rowid;    */
    END IF; /*cr_rec.secondary_unit_of_measure IS NOT NULL*/

    l_progress := 80;

        IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_uom_code:',p_req_line.secondary_uom_code);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.source_type_code:',p_req_line.source_type_code);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.source_organization_id:',p_req_line.source_organization_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.item_id:',p_req_line.item_id);
        END IF;
    --Internal Orders
    --Validate that quantity is within deviation for both source and destination organization
    --only if item is dual uom controlled in destination organization
    IF p_req_line.source_type_code = 'INVENTORY' AND
       p_req_line.source_organization_id IS NOT NULL AND
       p_req_line.secondary_uom_code IS NOT NULL THEN

       -- Get Item Attributes for source organization
       BEGIN
          OPEN Cr_item_attr(p_req_line.item_id, p_req_line.source_organization_id);
          FETCH Cr_item_attr INTO  l_tracking_qty_ind_s,
  	       			   l_item_um2_s		,
  	       			   l_secondary_default_ind_s;
          CLOSE Cr_item_attr;
       END;
       l_progress := 90;
       IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_tracking_qty_ind_s:',l_tracking_qty_ind_s);
              PO_LOG.stmt(d_module_base,l_progress,'l_item_um2_s:',l_item_um2_s);
              PO_LOG.stmt(d_module_base,l_progress,'l_item_um2:',l_item_um2);
              PO_LOG.stmt(d_module_base,l_progress,'l_secondary_default_ind_s:',l_secondary_default_ind_s);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.item_id:',p_req_line.item_id);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_quantity:',p_req_line.secondary_quantity);
        END IF;
       IF l_tracking_qty_ind_s = 'PS' THEN

          IF l_item_um2_s <> l_item_um2 THEN

             l_sec_qty_source := INV_CONVERT.inv_um_convert(
                                        item_id   =>  p_req_line.item_id,
                                        PRECISION =>  5,
                                        from_quantity  => p_req_line.secondary_quantity,
                                        from_unit =>  l_item_um2 ,
                                        to_unit	  =>  l_item_um2_s,
                                        from_name =>  NULL ,
                                        to_name	 =>   NULL
                                         );

             SELECT unit_of_measure
             INTO   l_unit_of_measure_s
             FROM   mtl_units_of_measure
             WHERE  uom_code = l_item_um2_s;

             l_progress := 100;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_sec_qty_source:',l_sec_qty_source);
              PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_measure_s:',l_unit_of_measure_s);
            END IF;


          ELSE
             l_sec_qty_source := p_req_line.secondary_quantity;
             l_unit_of_measure_s := p_req_line.secondary_uom_code;
          END IF;

          l_progress := 110;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'l_sec_qty_source:',l_sec_qty_source);
              PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_measure_s:',l_unit_of_measure_s);
            END IF;

          IF INV_CONVERT.within_deviation(
                         p_organization_id   	=>  p_req_line.source_organization_id ,
                         p_inventory_item_id    =>  p_req_line.item_id,
                         p_lot_number           =>  NULL ,
                         p_precision            =>  5 ,
                         p_quantity             =>  p_req_line.quantity,
                         p_unit_of_measure1     =>  p_req_line.unit_meas_lookup_code  ,
                         p_quantity2            =>  l_sec_qty_source ,
                         p_unit_of_measure2     =>  l_unit_of_measure_s,
                         p_uom_code1            =>  NULL,
                         p_uom_code2            =>  NULL) = 0 THEN



             l_progress := 120;

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_SRCE_ORG_OUT_OF_DEV');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_SRCE_ORG_OUT_OF_DEV');
        G_ERROR_COL := 'SECONDARY_QUANTITY';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;


          END IF; /*NOT INV_CONVERT.within_deviation( */
       END IF; /*l_tracking_qty_ind_s = 'PS'*/
    END IF; /*cr_rec.source_type_code = 'INVENTORY'*/

    l_progress := 130;

  ELSIF p_req_line.item_id IS NULL  THEN
    l_progress := 140;
       --since its a one time item update all process attributes to NULL.

              p_req_line.secondary_quantity := NULL;
              p_req_line.secondary_uom_code := NULL;
              p_req_line.preferred_grade := NULL;

  END IF;
  l_progress := 150;

           IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_quantity:',p_req_line.secondary_quantity);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_uom_code:',p_req_line.secondary_uom_code);
              PO_LOG.stmt(d_module_base,l_progress,'p_req_line.preferred_grade:',p_req_line.preferred_grade);
            END IF;
  x_return_status :='S';

EXCEPTION
  WHEN OTHERS THEN
  x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
     po_message_s.sql_error('calculate_secondaryqty', l_progress, SQLCODE);
     RAISE;

END calculate_secondaryqty;

PROCEDURE get_uom_conversion_api(
p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
	x_return_status OUT NOCOPY  VARCHAR2,
	x_error_msg OUT NOCOPY  VARCHAR2,
x_inventory_org_id IN NUMBER) IS

l_module_name CONSTANT VARCHAR2(100) := 'get_uom_conversion_api';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

  l_progress		NUMBER ;
  x_item_id			NUMBER;
  x_uom				VARCHAR2(30);
  x_uom_conversion_temp		NUMBER := 1;
  --Bug#11668528
  x_list_price NUMBER;
  x_destination_org_id NUMBER;
  x_line_type_id NUMBER;
  --Bug#11668528

BEGIN

    l_progress := 10;

                x_item_id := p_req_line.item_id;
                x_uom := p_req_line.unit_meas_lookup_code;
                x_destination_org_id := p_req_line.destination_organization_id;
                x_line_type_id := p_req_line.line_type_id;  --Bug#11668528

     IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_item_id:',x_item_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_uom:',x_uom);
              PO_LOG.stmt(d_module_base,l_progress,'x_destination_org_id:',x_destination_org_id);
              PO_LOG.stmt(d_module_base,l_progress,'x_line_type_id:',x_line_type_id);
      END IF;

    BEGIN

    l_progress := 20;
       --Bug# 1347733
       --togeorge 12/05/2000
       --Switched the first two arguments in the call to the procedure po_uom_convert.
       --This is done to avoid inaccurate value after conversion.
       --SELECT  round(po_uom_s.po_uom_convert(msi.primary_unit_of_measure,  x_uom,  x_item_id),10)
       SELECT  ROUND(po_uom_s.po_uom_convert(x_uom, msi.primary_unit_of_measure, x_item_id),10)
	INTO x_uom_conversion_temp
             FROM mtl_system_items msi
            WHERE msi.inventory_item_id = x_item_id
            AND  x_inventory_org_id = msi.organization_id
            AND msi.primary_unit_of_measure <> x_uom;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
	 x_uom_conversion_temp := 1;
         WHEN OTHERS THEN
	 x_uom_conversion_temp := 1;
       END;

       IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_uom_conversion_temp:',x_uom_conversion_temp);
       END IF;

      l_progress := 30;
       --Bug#11668528 Start
       BEGIN
       	   SELECT ROUND(msi.list_price_per_unit * (x_uom_conversion_temp),10)
       	   INTO x_list_price
           FROM mtl_system_items msi,
                po_line_types plt
           WHERE msi.inventory_item_id = x_item_id
           AND msi.organization_id = x_destination_org_id
           AND plt.line_type_id = x_line_type_id
           AND plt.order_type_lookup_code = 'QUANTITY';
        EXCEPTION
          WHEN OTHERS THEN
             X_LIST_PRICE := NULL;
        END;

        IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_list_price:',x_list_price);
        END IF;

        IF x_list_price IS NULL THEN
            BEGIN
			       	   SELECT ROUND(msi.list_price_per_unit * (x_uom_conversion_temp),10)
			       	   INTO x_list_price
			           FROM mtl_system_items msi,
			                po_line_types plt
			           WHERE msi.inventory_item_id = x_item_id
			           AND msi.organization_id = x_inventory_org_id
			           AND plt.line_type_id = x_line_type_id
			           AND plt.order_type_lookup_code = 'QUANTITY';
		        EXCEPTION
			          WHEN OTHERS THEN
			             X_LIST_PRICE := NULL;
		        END;
		     END IF;

         l_progress := 40;
         IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'x_list_price:',x_list_price);
        END IF;

       -->Bug# 1347733 End

         p_req_line.unit_price := x_list_price;

         x_return_status :='S';

  EXCEPTION
  WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('get_uom_conversion_api', l_progress, SQLCODE);
    RAISE;
END get_uom_conversion_api;

PROCEDURE calculate_lineprice(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                        x_return_status OUT NOCOPY  VARCHAR2,
                        x_error_msg OUT NOCOPY  VARCHAR2) IS


l_module_name CONSTANT VARCHAR2(100) := 'calculate_lineprice';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);

l_return_status VARCHAR2(2);
l_error_msg VARCHAR2(1000);

-- Logging Info
l_progress     NUMBER;

-- local variables

l_valid VARCHAR2(1);
l_inventory_organization_id financials_system_params_all.Inventory_Organization_Id%TYPE;
l_outside_operation_flag_p po_line_types_b.outside_operation_flag%TYPE;
l_unit_of_measure  po_line_types_b.unit_of_measure%TYPE;
l_order_type_lookup_code po_line_types_b.order_type_lookup_code%TYPE;
l_set_of_books_id  financials_system_params_all.set_of_books_id%TYPE;
l_REQ_ENCUMBRANCE_FLAG financials_system_params_all.REQ_ENCUMBRANCE_FLAG%TYPE;
l_func_currency gl_sets_of_books.currency_code%TYPE;

BEGIN

   -- line type info
   l_progress := 10;

      BEGIN

       SELECT outside_operation_flag , order_type_lookup_code ,unit_of_measure
       INTO l_outside_operation_flag_p , l_order_type_lookup_code ,l_unit_of_measure
       FROM po_line_types_b
       WHERE line_type_id = p_req_line.line_type_id;

      END;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'l_outside_operation_flag_p:',l_outside_operation_flag_p);
      PO_LOG.stmt(d_module_base,l_progress,'l_order_type_lookup_code:',l_order_type_lookup_code);
      PO_LOG.stmt(d_module_base,l_progress,'l_unit_of_measure:',l_unit_of_measure);
    END IF;

     -- get inventory organization ( purchasing org ) from setup.

     BEGIN

      SELECT f.inventory_organization_id ,f.set_of_books_id ,g.currency_code,f.REQ_ENCUMBRANCE_FLAG
      INTO l_inventory_organization_id ,l_set_of_books_id,l_func_currency,l_REQ_ENCUMBRANCE_FLAG
      FROM financials_system_parameters f,gl_sets_of_books g
      WHERE f.set_of_books_id = g.set_of_books_id;

     EXCEPTION
     WHEN OTHERS THEN

      NULL;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'l_inventory_organization_id:',l_inventory_organization_id);
        PO_LOG.stmt(d_module_base,l_progress,'l_set_of_books_id:',l_set_of_books_id);
        PO_LOG.stmt(d_module_base,l_progress,'l_func_currency:',l_func_currency);
        PO_LOG.stmt(d_module_base,l_progress,'l_REQ_ENCUMBRANCE_FLAG:',l_REQ_ENCUMBRANCE_FLAG);
      END IF;

        -- IF there is a fixed rate relationship between the functional currency and
        -- the transaction currency then set rate_type = EMU FIXED

         l_progress :=20;

       IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'currency_code:',p_req_line.currency_code);
        PO_LOG.stmt(d_module_base,l_progress,'rate_type:',p_req_line.rate_type);
        PO_LOG.stmt(d_module_base,l_progress,'rate_date:',p_req_line.rate_date);
       END IF;

         IF p_req_line.currency_code IS NOT NULL AND l_func_currency <> p_req_line.currency_code
            AND gl_currency_api.is_fixed_rate(p_req_line.currency_code,l_func_currency,p_req_line.rate_date)='Y' THEN

           p_req_line.rate_type := 'EMU FIXED';

         END IF;

        -- calculate unit_price based on currency_unit_price and rate if provided

         l_progress := 30;

        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'currency_unit_price:',p_req_line.currency_unit_price);
          PO_LOG.stmt(d_module_base,l_progress,'rate:',p_req_line.rate);
          PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
        END IF;

        IF p_req_line.currency_code IS NOT NULL AND l_func_currency <> p_req_line.currency_code
           AND p_req_line.rate IS NOT NULL AND p_req_line.currency_unit_price IS NOT NULL THEN

           p_req_line.unit_price :=  (p_req_line.currency_unit_price * p_req_line.rate);

        END IF;

        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
        END IF;

        -- if currency_code is provided, rate, rate_date must be provided and
        -- rate_type must be valid ,if it is not the functional currency only

        l_progress := 40;

        IF p_req_line.currency_code IS NOT NULL AND l_func_currency <> p_req_line.currency_code
           AND p_req_line.rate IS NOT NULL AND p_req_line.rate_type IS NOT NULL AND p_req_line.rate_date IS NOT NULL THEN

          BEGIN

            SELECT 'T'
            INTO l_valid
            FROM gl_daily_conversion_types
            WHERE conversion_type = p_req_line.rate_type;

            EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_RATE_DATE_TYPE');
       G_ERROR_COL := 'RATE_TYPE';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RETURN;

           END;

        END IF;

        l_progress := 50;

        -- if price is null and inv installed then get price from item

        IF check_installed_application('INV') AND p_req_line.item_id IS NOT NULL AND p_req_line.source_type_code = 'INVENTORY' THEN

         IF NVL(p_req_line.unit_price,0)=0 THEN

         BEGIN

            p_req_line.unit_price := por_util_pkg.get_item_cost(p_req_line.item_id,
                                                                p_req_line.source_organization_id,
                                                                p_req_line.unit_meas_lookup_code,
                                                                p_req_line.destination_organization_id,
                                                                p_req_line.rate_date);
            p_req_line.base_unit_price :=  p_req_line.unit_price;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
            END IF;

            EXCEPTION
            WHEN OTHERS THEN
             x_error_msg := 'Error while fetching unit_price';
             G_ERROR_COL := 'UNIT_PRICE';
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
             x_return_status := 'E';
             RETURN;

         END;

         END IF;

         l_progress := 60;

           -- get price from  cic item costs corresponds to src org if null
           -- Added logic to convert the price according to Unit of Issue of Source Org
           -- Added multiplication by po_uom_convert and join to mtl_system_items.

           IF NVL(p_req_line.unit_price,0)=0 THEN

           BEGIN

           SELECT ROUND(cic.item_cost * po_uom_s.po_uom_convert(
                                                         p_req_line.unit_meas_lookup_code,
                                                         msi.primary_unit_of_measure,
                                                         p_req_line.item_id),NVL(c.EXTENDED_PRECISION,10)),
                                 ROUND(cic.item_cost * po_uom_s.po_uom_convert(
                                                         p_req_line.unit_meas_lookup_code,
                                                         msi.primary_unit_of_measure,
                                                         p_req_line.item_id),NVL(c.EXTENDED_PRECISION,10))
           INTO p_req_line.unit_price,p_req_line.base_unit_price
           FROM cst_item_costs_for_gl_view cic,
                    mtl_parameters mp,
                    mtl_system_items msi,
                    FND_CURRENCIES c
               WHERE cic.inventory_item_id = p_req_line.item_id
               AND c.currency_code = l_func_currency
               AND cic.organization_id = mp.cost_organization_id
               AND cic.inventory_asset_flag = 1
               AND mp.organization_id= p_req_line.source_organization_id
               AND msi.inventory_item_id = p_req_line.item_id
               AND msi.organization_id = p_req_line.source_organization_id
               AND EXISTS (
                       SELECT 'Same Currency'
                         FROM gl_sets_of_books glsob,
                              org_organization_definitions ood
                  WHERE l_func_currency = glsob.currency_code
                          AND glsob.set_of_books_id = ood.set_of_books_id
                          AND ood.organization_id = p_req_line.source_organization_id);

            EXCEPTION
            WHEN OTHERS THEN

             p_req_line.unit_price:= NULL;
             p_req_line.base_unit_price := NULL;

           END;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
            END IF;

           END IF;

           l_progress := 70;

           -- get price from  cic item costs corresponds to src org if null
           -- Added logic to convert the price according to Unit of Issue of Source Org
           -- Added multiplication by po_uom_convert and join to mtl_system_items.
           -- Now Doing the Currency Conversion for the Item CostIf the currency code of the SOB of the
           -- source_organization is different from the current organization's currency code

           IF NVL(p_req_line.unit_price,0)=0 THEN

             BEGIN

              SELECT ROUND(cic.item_cost * po_uom_s.po_uom_convert(
                                                         p_req_line.unit_meas_lookup_code,
                                                         msi.primary_unit_of_measure,
                                                         p_req_line.item_id) *
                                  gl_currency_api.get_closest_rate_sql (
                                   l_set_of_books_id,
                                   glsob.currency_code,
                                   TRUNC(NVL(p_req_line.rate_date,
                                     SYSDATE)),
                                   psp.DEFAULT_RATE_TYPE, 30),NVL(c.EXTENDED_PRECISION,10)),
                                 ROUND(cic.item_cost * po_uom_s.po_uom_convert(
                                                       p_req_line.unit_meas_lookup_code,
                                                         msi.primary_unit_of_measure,
                                                         p_req_line.item_id) *
                                  gl_currency_api.get_closest_rate_sql (
                                   l_set_of_books_id,
                                   glsob.currency_code,
                                   TRUNC(NVL(p_req_line.rate_date,
                                     SYSDATE)),
                                   psp.DEFAULT_RATE_TYPE, 30),NVL(c.EXTENDED_PRECISION,10))
              INTO p_req_line.unit_price,p_req_line.base_unit_price
              FROM cst_item_costs_for_gl_view cic,
                                 mtl_parameters mp,
                                 gl_sets_of_books glsob,
                                 org_organization_definitions ood,
                                 po_system_parameters psp,
                               mtl_system_items msi,
                               FND_CURRENCIES c
                   WHERE cic.inventory_item_id = p_req_line.item_id
                           AND cic.organization_id = mp.cost_organization_id
                           AND c.CURRENCY_CODE = l_func_currency
                           AND cic.inventory_asset_flag = 1
                             AND mp.organization_id= p_req_line.source_organization_id
                           AND l_func_currency <> glsob.currency_code
                             AND glsob.set_of_books_id = ood.set_of_books_id
                             AND ood.organization_id = p_req_line.source_organization_id
                             AND msi.inventory_item_id = p_req_line.item_id
                             AND msi.organization_id = p_req_line.source_organization_id
                             AND EXISTS (
                       SELECT 'Diff Currency'
                         FROM gl_sets_of_books glsob,
                              org_organization_definitions ood,
                              po_system_parameters psp
                      WHERE l_func_currency <> glsob.currency_code
                          AND glsob.set_of_books_id = ood.set_of_books_id
                          AND ood.organization_id = p_req_line.source_organization_id
                          AND ROUND(gl_currency_api.get_closest_rate_sql (
                                   l_set_of_books_id,
                                   glsob.currency_code,
                                   TRUNC(NVL(p_req_line.rate_date,
                                     SYSDATE)),
                                   psp.DEFAULT_RATE_TYPE, 30),10)>0);

               EXCEPTION
               WHEN OTHERS THEN

                 p_req_line.unit_price:= NULL;
                 p_req_line.base_unit_price := NULL;

             END;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
             END IF;

           END IF;


        END IF;

        -- If still price is null and src type is 'INVENTORY' get price from item list price
        l_progress := 80;

        IF p_req_line.source_type_code = 'INVENTORY' AND NVL(p_req_line.unit_price,0)=0
           AND p_req_line.item_id IS NOT NULL THEN

          BEGIN

          SELECT ROUND(msi.list_price_per_unit * po_uom_s.po_uom_convert(
                                                          p_req_line.unit_meas_lookup_code,
                                                            msi.primary_unit_of_measure,
                                                            p_req_line.item_id) ,NVL(c.EXTENDED_PRECISION,10)),
                              ROUND(msi.list_price_per_unit * po_uom_s.po_uom_convert(
                                                          p_req_line.unit_meas_lookup_code,
                                                            msi.primary_unit_of_measure,
                                                            p_req_line.item_id),NVL(c.EXTENDED_PRECISION,10))
          INTO p_req_line.unit_price,p_req_line.base_unit_price
          FROM mtl_system_items msi,
               FND_CURRENCIES c
          WHERE msi.inventory_item_id = p_req_line.item_id
          AND c.currency_code = l_func_currency
          AND msi.organization_id = p_req_line.source_organization_id
          AND EXISTS (
                       SELECT 'Same Currency'
                         FROM gl_sets_of_books glsob,
                              org_organization_definitions ood
                      WHERE l_func_currency = glsob.currency_code
                          AND glsob.set_of_books_id = ood.set_of_books_id
                          AND ood.organization_id = p_req_line.source_organization_id);

          EXCEPTION
          WHEN OTHERS THEN
            p_req_line.unit_price:= NULL;
            p_req_line.base_unit_price := NULL;

          END;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
             END IF;

          --If the currency code of the SOB of the source_organization is different
          -- from the current organization's currency code then we need to multiply
          --list Price by the conversion factor

          l_progress := 90;

          IF NVL(p_req_line.unit_price,0)=0 THEN

           BEGIN

            SELECT ROUND(msi.list_price_per_unit * po_uom_s.po_uom_convert(
                                                  p_req_line.unit_meas_lookup_code,
                                                    msi.primary_unit_of_measure,
                                                    p_req_line.item_id) *
                       gl_currency_api.get_closest_rate_sql (
                        l_set_of_books_id,
                        glsob.currency_code,
                        TRUNC(NVL(p_req_line.rate_date,
                        SYSDATE)),
                        psp.DEFAULT_RATE_TYPE, 30),NVL(c.EXTENDED_PRECISION,10)),
                        ROUND( msi.list_price_per_unit  * po_uom_s.po_uom_convert(
                                                  p_req_line.unit_meas_lookup_code,
                                                    msi.primary_unit_of_measure,
                                                    p_req_line.item_id) *
                       gl_currency_api.get_closest_rate_sql (
                        l_set_of_books_id,
                        glsob.currency_code,
                        TRUNC(NVL(p_req_line.rate_date,
                        SYSDATE)),
                        psp.DEFAULT_RATE_TYPE, 30),NVL(c.EXTENDED_PRECISION,10))
             INTO p_req_line.unit_price,p_req_line.base_unit_price
             FROM mtl_system_items msi,
                  gl_sets_of_books glsob,
                  org_organization_definitions ood,
                  po_system_parameters psp,
                  FND_CURRENCIES c
             WHERE msi.inventory_item_id = p_req_line.item_id
             AND msi.organization_id = p_req_line.source_organization_id
             AND c.currency_code = l_func_currency
             AND l_func_currency <> glsob.currency_code
             AND glsob.set_of_books_id = ood.set_of_books_id
             AND ood.organization_id = p_req_line.source_organization_id
             AND EXISTS (
               SELECT 'Diff Currency'
                 FROM gl_sets_of_books glsob,
                      org_organization_definitions ood,
                      po_system_parameters psp
              WHERE l_func_currency <> glsob.currency_code
                  AND glsob.set_of_books_id = ood.set_of_books_id
                  AND ood.organization_id = p_req_line.source_organization_id
                  AND ROUND(gl_currency_api.get_closest_rate_sql (
                           l_set_of_books_id,
                           glsob.currency_code,
                           TRUNC(NVL(p_req_line.rate_date,
                             SYSDATE)),
                           psp.DEFAULT_RATE_TYPE, 30),10)>0);


           EXCEPTION
           WHEN OTHERS THEN
            p_req_line.unit_price:= NULL;
            p_req_line.base_unit_price := NULL;

           END;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
             END IF;

          END IF;

        END IF;


        l_progress := 100;

        IF NVL(p_req_line.unit_price,0)=0 THEN

        BEGIN

        get_uom_conversion_api(p_req_line,l_return_status,l_error_msg,l_inventory_organization_id);

        IF l_return_status ='E' THEN
          x_return_status := l_return_status ;
          x_error_msg := l_error_msg;
          IF PO_LOG.d_stmt THEN
             PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RETURN;
       END IF;

        END;

        END IF;

        l_progress := 110;
        -- get custom price if used.

        IF p_req_line.source_type_code = 'INVENTORY' AND p_req_line.item_id IS NOT NULL THEN


        BEGIN

         SELECT ROUND(PO_CUSTOM_PRICE_PUB.GET_CUSTOM_INTERNAL_REQ_PRICE(1.0,
                                                p_req_line.item_id,
                                                p_req_line.category_id,
                                                p_req_line.requisition_header_id,
                                                p_req_line.requisition_line_id,
                                                p_req_line.SOURCE_ORGANIZATION_ID,
                                                p_req_line.SOURCE_SUBINVENTORY,
                                                p_req_line.DESTINATION_ORGANIZATION_ID,
                                                p_req_line.DESTINATION_SUBINVENTORY,
                                                p_req_line.DELIVER_TO_LOCATION_ID,
                                                p_req_line.need_by_date,
                                                p_req_line.unit_meas_lookup_code,
                                                p_req_line.quantity,
                                                p_req_line.currency_code,
                                                p_req_line.rate,
                                                p_req_line.rate_type,
                                                p_req_line.rate_date,
                                                p_req_line.unit_price
                                                ),NVL(c.EXTENDED_PRECISION,10)),
                                      ROUND(PO_CUSTOM_PRICE_PUB.GET_CUSTOM_INTERNAL_REQ_PRICE(1.0,
                                                p_req_line.item_id,
                                                p_req_line.category_id,
                                                p_req_line.requisition_header_id,
                                                p_req_line.requisition_line_id,
                                                p_req_line.SOURCE_ORGANIZATION_ID,
                                                p_req_line.SOURCE_SUBINVENTORY,
                                                p_req_line.DESTINATION_ORGANIZATION_ID,
                                                p_req_line.DESTINATION_SUBINVENTORY,
                                                p_req_line.DELIVER_TO_LOCATION_ID,
                                                p_req_line.need_by_date,
                                                p_req_line.unit_meas_lookup_code,
                                                p_req_line.quantity,
                                                p_req_line.currency_code,
                                                p_req_line.rate,
                                                p_req_line.rate_type,
                                                p_req_line.rate_date,
                                                p_req_line.unit_price
                                                ),NVL(c.EXTENDED_PRECISION,10))
          INTO p_req_line.unit_price,p_req_line.base_unit_price
          FROM FND_CURRENCIES c
          WHERE c.currency_code = l_func_currency;

          EXCEPTION
          WHEN OTHERS THEN
           NULL;

        END;

            IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'unit_price:',p_req_line.unit_price);
              PO_LOG.stmt(d_module_base,l_progress,'base_unit_price:',p_req_line.base_unit_price);
             END IF;

        END IF;


        -- unit price must be >= 0 except for Fixed Price Services lines
        l_progress := 120;

        IF l_order_type_lookup_code <> 'FIXED PRICE' AND (p_req_line.unit_price < 0 OR p_req_line.unit_price IS NULL) THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_UNIT_PRICE_LT_0');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_UNIT_PRICE_LT_0');
        G_ERROR_COL := 'UNIT_PRICE';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

        END IF;

        --Calculate Currency Amount when Rate is given for Fixed Price lines
        --if currency_amount is null
        l_progress := 130;

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'currency_amount:',p_req_line.currency_amount);
              PO_LOG.stmt(d_module_base,l_progress,'amount:',p_req_line.amount);
             END IF;

          IF l_order_type_lookup_code = 'FIXED PRICE' AND p_req_line.amount IS NOT NULL
             AND p_req_line.rate IS NOT NULL  AND p_req_line.currency_amount IS NULL THEN

             p_req_line.currency_amount := ROUND(p_req_line.amount/p_req_line.rate,
                                                 PO_CURRENCY_SV.get_currency_precision(p_req_line.currency_code));

             IF PO_LOG.d_stmt THEN
              PO_LOG.stmt(d_module_base,l_progress,'currency_amount:',p_req_line.currency_amount);
             END IF;

          END IF;


         --Amount must be not null or not less than zero for Fixed Price
         --Services lines
         l_progress := 140;

         IF l_order_type_lookup_code = 'FIXED PRICE' AND (p_req_line.amount < 0 OR p_req_line.amount IS NULL) THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_AMOUNT_NULL');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_AMOUNT_NULL');
        G_ERROR_COL := 'AMOUNT';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

         END IF;

         -- for fixed price line type converted amount and currency amount should match if provided
         l_progress := 150;

         IF l_order_type_lookup_code = 'FIXED PRICE' AND p_req_line.currency_amount <>
            ROUND(p_req_line.amount/p_req_line.rate,PO_CURRENCY_SV.get_currency_precision(p_req_line.currency_code)) THEN

             x_return_status :='E';
        fnd_message.set_name ('PO','PO_RI_AMOUNT_CURRENCY_MISMATCH');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_AMOUNT_CURRENCY_MISMATCH');
        G_ERROR_COL := 'AMOUNT';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RETURN;

         END IF;

           x_return_status :='S';

EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
    x_return_status := 'E';
    po_message_s.sql_error('calculate_lineprice','010',SQLCODE);
    RAISE;

 END calculate_lineprice;

PROCEDURE val_requisition_line (p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                p_accounts_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PVT.accounts_tbl,
                               x_return_status OUT   NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 )

IS
  l_module_name CONSTANT VARCHAR2(100) := 'val_requisition_line';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_progress NUMBER;
  user_error EXCEPTION;

  l_auth_status VARCHAR2(50);
  l_line_rec po_requisition_lines%ROWTYPE;
  l_desc                          mtl_system_items.description%TYPE;
  l_allow_item_desc_update_flag   mtl_system_items.allow_item_desc_update_flag%TYPE;
  l_valid VARCHAR(1);
  l_return_status VARCHAR2(2);
  l_err_msg VARCHAR2(5000);
  CURSOR c_req_line(p_line_id NUMBER,p_header_id NUMBER)
  IS SELECT *
  FROM po_requisition_lines
  WHERE requisition_line_id = p_line_id
  AND requisition_header_id = p_header_id;

  l_reqline_rec c_req_line%ROWTYPE;
  l_category_id NUMBER;
  l_location_id NUMBER;
  l_sob_id NUMBER;

BEGIN

   IF Fnd_Api.to_Boolean(NVL(p_init_msg,fnd_api.g_true)) THEN
     Fnd_Msg_Pub.initialize;
  END IF;

  l_progress := 10;
  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module_base);
      PO_LOG.proc_begin(d_module_base, 'req_header_id', p_req_line.requisition_header_id);
      PO_LOG.proc_begin(d_module_base, 'req_line_id', p_req_line.requisition_line_id);
    END IF;
  --dbms_OUTPUT.PUT_LINE('Debug1');
  --validate line id
  l_progress:= 20;
  IF  is_valid_line(p_req_line) <> 'Y' AND p_req_line.action_flag = 'UPDATE' THEN
    x_error_msg := 'Invalid requisition line';
    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'Invalid requisition line');
    END IF;
      po_message_s.sql_error(x_error_msg,'020','');
      x_return_status :='E';
      RAISE user_error;
  END IF;
----dbms_output.put_line('Debug2');
    l_progress := 30;
    --Dont update requisition with generated PO
   IF allow_changeonreq(p_req_line.requisition_header_id,p_req_line.org_id,p_req_line.requisition_line_id) = 'N' THEN
      x_error_msg := 'Requisition is not eligible for Update..PO Exists for this requisition';
      x_return_status := 'E';

      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      po_message_s.sql_error('po_exists','030','');
      RAISE user_error;
   END IF;

  l_progress := 40;

  IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'validate authorization_status');
  END IF;

  BEGIN
   SELECT authorization_status,fsp.set_of_books_id
   INTO l_auth_status,l_sob_id
   FROM po_requisition_headers_all prh,
    financials_system_parameters fsp
   WHERE requisition_header_id = p_req_line.requisition_header_id
   ;
  EXCEPTION
    WHEN OTHERS THEN
     x_error_msg := 'Error while fetching requisition status';
     IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
     x_return_status := 'E' ;
     po_message_s.sql_error('po_exists','040',SQLCODE);
     RAISE;
  END;

  l_progress := 50;
  IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'l_auth_status: ',l_auth_status);
  END IF;

  IF l_auth_status IN ('CANCELLED','PRE-APPROVED','IN-PROCESS') THEN
      x_error_msg := 'Requisition with status '||l_auth_status||' is not eligible for update' ;

      x_return_status := 'E';
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RAISE user_error;
  END IF;

  l_progress := 60;

  IF p_req_line.action_flag = 'UPDATE' THEN
     val_line_non_upd_data(p_req_line,x_error_msg,x_return_status);
     IF x_return_status = 'E' THEN
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RAISE USER_ERROR;
     END IF;
  END IF;

    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'l_auth_status',l_auth_status);
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.to_person_id: ',p_req_line.to_person_id);
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.requestor_name',p_req_line.requestor_name);
    END IF;

  l_progress := 70;

  IF p_req_line.destination_organization_id IS NOT NULL OR p_req_line.destination_organization IS NOT NULL
  THEN
    BEGIN
      SELECT ood.organization_id
      INTO p_req_line.destination_organization_id
      FROM org_organization_definitions ood
      WHERE (ood.organization_name = p_req_line.destination_organization OR ood.organization_id = p_Req_line.destination_organization_id)
      AND ood.set_of_books_id = l_sob_id;
    EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_DEST_ORG');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_DEST_ORG');
        g_error_col := 'DESTINATION_ORGANIZATION_ID';
      RAISE USER_ERROR;
    END;
  END IF;

  IF p_req_line.to_person_id IS NOT NULL OR p_req_line.requestor_name IS NOT NULL THEN
    BEGIN
    SELECT /*+ no_unnest */ 'T',hecv.person_id
    INTO l_valid, p_req_line.to_person_id
    FROM PER_WORKFORCE_CURRENT_X hecv
    WHERE hecv.person_id = p_req_line.to_person_id
    OR hecv.full_name=p_req_line.requestor_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_REQUESTOR');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_REQUESTOR');
        G_ERROR_COL := 'REQUESTOR_ID';
         IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
         RAISE user_error;
      WHEN TOO_MANY_ROWS THEN
        fnd_message.set_name ('PO','PO_RI_DUPLICATE_NAMES');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_DUPLICATE_NAMES');
        G_ERROR_COL := 'REQUESTOR_ID';
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RAISE user_error;
      WHEN OTHERS THEN
       x_error_msg := 'Error while fetching from PER_WORKFORCE_CURRENT_X';
       G_ERROR_COL := 'REQUESTOR_ID';
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       x_return_status := 'E' ;
       po_message_s.sql_error('validate requester','070',SQLCODE);
       RAISE;
    END;
  END IF;
  IF p_req_line.action_flag = 'UPDATE' THEN

     OPEN c_req_line(p_req_line.requisition_line_id,p_req_line.requisition_header_id);
     FETCH c_req_line INTO l_reqline_rec;
     CLOSE c_req_line;
	 IF NVL(l_reqline_rec.TRANSFERRED_TO_OE_FLAG,'N') = 'Y' THEN
	    G_ERROR_COL := 'REQUISITION_LINE';
		x_error_msg := 'Line is placed onto Sales Order..Line cannot be updated';
		RAISE USER_ERROR;
     END IF;
   ELSIF p_req_line.action_flag = 'NEW' THEN
      default_setup_attributes(p_req_line,x_return_status,x_error_msg);
      IF x_return_status ='E' THEN
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       RAISE USER_ERROR;
     END IF;
   END IF;

   IF p_req_line.action_flag = 'NEW' THEN
     IF validate_desttype(p_req_line) <> 'Y' THEN
        fnd_message.set_name ('PO','PO_RI_INVALID_DEST_TYPE_CODE');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_DEST_TYPE_CODE');
        G_ERROR_COL := 'DESTINATION_TYPE_CODE';
        RAISE USER_ERROR;
     END IF;

     IF p_req_line.destination_type_code IN ('EXPENSE','SHOP FLOOR') THEN
     p_req_line.destination_subinventory := NULL;
     END IF;

   END IF;

    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate source_type_code');
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.source_type_code',p_req_line.source_type_code);
    END IF;

  IF p_req_line.source_type_code IS NOT NULL OR p_req_line.source_type IS NOT NULL THEN
         /* validate source_type_code as a valid lookup code in po_lookup_codes    */
       /* must be one of INVENTORY / VENDOR                                      */
        IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,'source_type_code:', p_req_line.source_type_code);
            PO_LOG.stmt(d_module_base,l_progress,'source_type:', p_req_line.source_type);
        END IF;

         BEGIN
            SELECT 'T',lookup_code
            INTO l_valid,p_req_line.source_type_code
            FROM po_lookup_codes plc
            WHERE plc.lookup_type = 'REQUISITION SOURCE TYPE'
             AND (plc.lookup_code = p_req_line.source_type_code OR plc.displayed_field = p_req_line.source_type);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name ('PO','PO_RI_INVALID_SOURCE_TYPE_CODE');
               fnd_msg_pub.ADD;
               x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SOURCE_TYPE_CODE');
               G_ERROR_COL := 'SOURCE_TYPE_CODE';
               IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
               po_message_s.sql_error('validate source_type_code','070',SQLCODE);
               RAISE user_error;
            WHEN OTHERS THEN
                 x_error_msg := 'Error while fetching source type';
                 G_ERROR_COL := 'SOURCE_TYPE_CODE';
                 IF PO_LOG.d_stmt THEN
                   PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
                 END IF;
                 x_return_status := 'E' ;
                 po_message_s.sql_error('validate source_type_code','070',SQLCODE);
                 RAISE;
          END;
  END IF;
  l_progress := 80;

    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate line type');
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.line_type_id',p_req_line.line_type_id);
    END IF;

    IF p_req_line.line_type_id IS NULL AND p_req_line.line_type IS NULL AND p_req_line.action_flag = 'NEW' THEN
        SELECT line_type_id
        INTO  p_req_line.line_type_id
        FROM  po_system_parameters;
    END IF;
   /*validate line type */
   IF p_req_line.line_type_id IS NOT NULL OR p_req_line.line_type IS NOT NULL THEN

      validate_Line_type(p_req_line, l_return_status, l_err_msg,l_reqline_rec.destination_type_code,l_reqline_rec.source_type_code,l_reqline_rec.destination_organization_id);
     IF l_return_status ='E' THEN
       x_return_status := l_return_status ;
       x_error_msg := l_err_msg;
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       RAISE USER_ERROR;
     END IF;
   END IF;
--dbms_OUTPUT.PUT_LINE('Debug5');

   /* Validate category and it can be updated only for one time items
   */
   l_progress := 801;
    IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'Validate category');
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.category_id',p_req_line.category_id);
    END IF;

     IF l_reqline_rec.item_id IS NOT NULL AND p_req_line.action_flag = 'UPDATE' THEN
	   IF p_req_line.category_id IS NOT NULL OR p_req_line.item_category IS NOT NULL   THEN
             G_ERROR_COL := 'ITEM_CATEGORY';
             x_error_msg := 'Category cannot be updated for this line';
              IF PO_LOG.d_stmt THEN
                PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
             po_message_s.sql_error('validate_category','080',SQLCODE);
             RAISE USER_ERROR;
       END IF;
     ELSIF (( (p_req_line.category_id IS NOT NULL OR p_req_line.item_category IS NOT NULL) AND p_req_line.action_flag='UPDATE') OR p_req_line.action_flag = 'NEW')
        THEN
         BEGIN
           SELECT DISTINCT mckfv.category_id
           INTO p_req_line.category_id
           FROM mtl_category_set_valid_cats mcsvc,
                mtl_default_sets_view mdsv,
                mtl_categories_kfv mckfv
           WHERE mckfv.category_id = mcsvc.category_id
           AND mcsvc.category_set_id = mdsv.category_set_id
           AND mdsv.functional_area_id = 2
           AND NVL(mdsv.validate_flag,'N') = 'Y' -- Bug 4495328 added this condition
           AND (mckfv.category_id = p_req_line.category_id  OR mckfv.concatenated_segments = p_req_line.item_category)
           AND NVL(mckfv.disable_date, SYSDATE + 1) > SYSDATE
           UNION
           SELECT DISTINCT category_id
           FROM mtl_categories_kfv mic,
                mtl_default_sets_view mdsv
           WHERE mdsv.functional_area_id = 2
           AND NVL(mdsv.validate_flag,'N') = 'N'
           AND NVL(mic.disable_date, SYSDATE + 1) > SYSDATE
           AND mdsv.structure_id =  mic.structure_id
           AND (mic.category_id = p_req_line.category_id OR mic.concatenated_segments = p_req_line.item_category);
          EXCEPTION
            WHEN OTHERS THEN
              fnd_message.set_name ('PO','PO_RI_INVALID_CATEGORY_ID');
              fnd_msg_pub.ADD;
              x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_CATEGORY_ID');
              G_ERROR_COL := 'CATEGORY_ID';
              IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
               x_return_status := 'E' ;
               po_message_s.sql_error('validate_category','090',SQLCODE);
               RAISE USER_ERROR;
           END;
     END IF ;


  IF p_req_line.unit_price IS NOT NULL THEN
    IF p_req_line.base_unit_price IS NOT NULL AND p_req_line.unit_price <> p_req_line.base_unit_price THEN
      x_error_msg := 'unit price and base_unit_price is different';
      x_return_status := 'E' ;
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RETURN;
    END IF;
----dbms_output.put_line('Debug6');
    p_req_line.base_unit_price := p_req_line.unit_price;
  END IF;

   /* validate UOM */
   /*UNIT_MEAS_LOOKUP_CODE
      - Except for Fixed price lines--> Checked in line type
      - Should exists in mtl_units_of_measure ..
      - If item exists Defaults the value at item definition.
      - For amount based line types should be the value from po_line_types -- This Is not updatable"
  */
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,l_progress,'validate UOM');
    PO_LOG.stmt(d_module_base,l_progress,'p_req_line.unit_meas_lookup_code: ',p_req_line.unit_meas_lookup_code);
  END IF;
   IF (p_req_line.source_organization_id IS NOT NULL
        OR p_req_line.source_subinventory IS NOT NULL
        OR p_req_line.source_organization_name IS NOT NULL
        ) THEN

      IF NVL(p_req_line.source_type_code, l_reqline_rec.source_type_code)<> 'INVENTORY' THEN
         x_return_status := 'E' ;
         x_error_msg := 'INVALID SOURCE TYPE';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
      ELSE
        IF (p_req_line.source_organization_name IS NOT NULL OR p_req_line.source_organization_id IS NOT NULL) THEN
          BEGIN -- getting source organization_id from name
          SELECT 'T', ood.organization_id
          INTO l_valid, p_req_line.source_organization_id
          FROM org_organization_definitions ood
          WHERE ood.organization_id = p_req_line.source_organization_id
              OR ood.organization_name = p_req_line.source_organization_name;
          EXCEPTION
            WHEN OTHERS  THEN
              x_return_status := 'E' ;
              fnd_message.set_name ('PO','PO_RI_INVALID_SOURCE_ORG_ID');
              fnd_msg_pub.ADD;
              x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SOURCE_ORG_ID');
              G_ERROR_COL := 'SOURCE_ORGANIZATION_ID';
              IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
              RAISE USER_ERROR;
            END;
          END IF;
       -- validate_Dest_Subinventory(p_req_line, l_result_code);
         /*doc
       destination_subinventory     Y   "Source type should be INVENTORY
      Definition should exists in mtl_secondary_inventories"

    */
    /*if source_type_code = INVENTORY,item_id is REQUIRED and the item must
      have internal_order_enabled_flag = 'Y' for the purchasing organization*/
      l_progress := 190;
      IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'inventory item information');
          PO_LOG.stmt(d_module_base,l_progress,'item_id: ', l_reqline_rec.item_id);
          PO_LOG.stmt(d_module_base,l_progress,'source_organization_id: ', NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id));
          PO_LOG.stmt(d_module_base,l_progress,'source_organization_name: ', p_req_line.source_organization_name);
          PO_LOG.stmt(d_module_base,l_progress,'destination_organization_id: ', NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id));
      END IF;

       /* if source_type_code = INVENTORY and a source_subinventory             */
       /* is provided, it must be a valid subinventory for the source org       */
    l_progress :=200;
      IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'validate subinventory information');
          PO_LOG.stmt(d_module_base,l_progress,'p_req_line.source_subinventory', p_req_line.source_subinventory);
          PO_LOG.stmt(d_module_base,l_progress,'source_subinventory', NVL(p_req_line.source_subinventory, l_reqline_rec.source_subinventory));
          PO_LOG.stmt(d_module_base,l_progress,'source_organization_id', NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id));
      END IF;

      IF p_req_line.source_subinventory IS NOT NULL THEN
      BEGIN
       SELECT 'T'
       INTO l_valid
       FROM mtl_secondary_inventories msci
       WHERE NVL(p_req_line.source_subinventory, l_reqline_rec.source_subinventory) = msci.secondary_inventory_name
       AND NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id)= msci.organization_id
       AND SYSDATE < NVL(msci.disable_date,SYSDATE+1);
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_SRC_SUBINV');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SRC_SUBINV');
          G_ERROR_COL := 'SOURCE_SUBINVENTORY';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
       END;

      l_progress := 122;
      BEGIN
             SELECT 'T'
             INTO l_valid
             FROM mtl_secondary_inventories
             WHERE secondary_inventory_name = p_req_line.source_subinventory
             AND quantity_tracked = 1;

            EXCEPTION
           WHEN OTHERS  THEN
              x_return_status := 'E' ;
              fnd_message.set_name ('PO','PO_RI_SRC_SUB_NOT_QTY_TRACKED');
              fnd_msg_pub.ADD;
              x_error_msg := fnd_message.get_string('PO','PO_RI_SRC_SUB_NOT_QTY_TRACKED');
              G_ERROR_COL := 'SOURCE_SUBINVENTORY';
              IF PO_LOG.d_stmt THEN
               PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
              END IF;
              RAISE USER_ERROR;

       END;

       END IF;

    END IF; -- END IF p_req_line.source_type_code = 'INVENTORY'
      IF p_req_line.destination_subinventory IS NOT NULL THEN
      BEGIN
       SELECT 'T'
       INTO l_valid
       FROM mtl_secondary_inventories msci
       WHERE p_req_line.destination_subinventory = msci.secondary_inventory_name
       AND NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id) = msci.organization_id
       AND SYSDATE < NVL(msci.disable_date,SYSDATE+1);
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_DEST_SUBINV');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_DEST_SUBINV');
          G_ERROR_COL := 'DESTINATION_SUBINVENTORY';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
       END;
       END IF;

      -- Inter-organization transfers defined or not for source and dest org combo

      IF p_req_line.source_organization_id IS NOT NULL AND p_req_line.destination_organization_id IS NOT NULL
      AND p_req_line.source_organization_id <> p_req_line.destination_organization_id THEN

      l_progress := 124;

      BEGIN
             SELECT 'T'
             INTO l_valid
             FROM mtl_interorg_parameters
             WHERE from_organization_id = p_req_line.source_organization_id
             AND to_organization_id = p_req_line.destination_organization_id;

             EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       fnd_message.set_name ('PO','PO_RI_NO_INTERORG_ROW');
       fnd_msg_pub.ADD;
       x_error_msg := fnd_message.get_string('PO','PO_RI_NO_INTERORG_ROW');
       G_ERROR_COL := 'SOURCE_ORGANIZATION_ID';
      IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
       END IF;
       RAISE USER_ERROR;

           END;

     END IF;

  END IF;
       /* validate deliver_to_location_id - must be a valid location */
   IF p_req_line.deliver_to_location_id IS NOT NULL OR p_req_line.deliver_to_location_code IS NOT NULL THEN
      l_progress :=280;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate deliver_to_location_id');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.deliver_to_location_id: ', p_req_line.deliver_to_location_id);
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.deliver_to_location_code: ', p_req_line.deliver_to_location_code);
      END IF;

        BEGIN
            SELECT location_id
            INTO l_location_id
            FROM hr_locations hl
            WHERE (hl.location_id = p_req_line.deliver_to_location_id OR hl.location_code = p_req_line.deliver_to_location_code)
              AND NVL(hl.inactive_date,TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
              AND (hl.inventory_organization_id =
                                            NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id)
                                OR hl.inventory_organization_id IS NULL
                                OR l_reqline_rec.destination_organization_id IS NULL);
          EXCEPTION
              WHEN OTHERS  THEN
                x_return_status := 'E' ;
                fnd_message.set_name ('PO','PO_RI_INVALID_LOCATION');
                fnd_msg_pub.ADD;
                x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_LOCATION');
                G_ERROR_COL := 'DELIVER_TO_LOCATION_ID';
                IF PO_LOG.d_stmt THEN
                  PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
                END IF;
                RAISE USER_ERROR;
          END;
    p_req_line.deliver_to_location_id  := l_location_id;

    l_progress :=290;
    -- customer association check for DELIVER_TO_LOCATION_ID
    IF  p_req_line.source_type_code = 'INVENTORY' AND p_req_line.source_organization_id IS NOT NULL THEN
    IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,'deliver_to_location_id:',p_req_line.deliver_to_location_id);
          END IF;

          BEGIN

           SELECT 'T'
           INTO l_valid
           FROM po_location_associations_all pla,
                org_organization_definitions org
           WHERE pla.location_id = p_req_line.deliver_to_location_id
           AND org.organization_id = p_req_line.source_organization_id
           AND org.operating_unit = pla.org_id
           AND pla.site_use_id IS NOT NULL
           AND pla.customer_id IS NOT NULL
           AND pla.address_id IS NOT NULL;

           EXCEPTION
          WHEN OTHERS  THEN
                x_return_status := 'E' ;
                fnd_message.set_name ('PO','PO_RI_INVALID_DEL_LOC_ID_DEST');
                fnd_msg_pub.ADD;
                x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_DEL_LOC_ID_DEST');
                G_ERROR_COL := 'DELIVER_TO_LOCATION_ID';
                IF PO_LOG.d_stmt THEN
                  PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
                END IF;
                RAISE USER_ERROR;

           END;
    END IF;

  END IF;

   IF p_req_line.action_flag = 'NEW' THEN
     validate_item(p_req_line,x_return_status,x_error_msg);
     IF x_return_status = 'E' THEN
       RAISE USER_ERROR;
     END IF;
   END IF;
   --dbms_OUTPUT.PUT_LINE('debug6');
  IF p_req_line.unit_meas_lookup_code IS NOT NULL THEN
      l_progress := 90;
    BEGIN
      SELECT 'T', mum.unit_of_measure
      INTO l_valid, p_req_line.unit_meas_lookup_code
      FROM mtl_units_of_measure mum
      WHERE p_req_line.unit_meas_lookup_code = mum.unit_of_measure;
     EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('PO','PO_RI_M_INVALID_UOM');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_M_INVALID_UOM');
        G_ERROR_COL := 'UNIT_OF_MEAS_LOOKUP_CODE';
         IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        x_return_status := 'E' ;
        RAISE USER_ERROR;
     END ;
  END IF;

  l_progress := 100;
    IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'validate Currency');
    END IF;

   IF p_req_line.currency_code IS NOT NULL THEN

      validate_Currency(p_req_line,l_return_status, l_err_msg);
       IF l_return_status ='E' THEN
         x_return_status := l_return_status ;
         x_error_msg := l_err_msg;
         IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
         RAISE USER_ERROR;
       END IF;
   END IF;
   --dbms_OUTPUT.PUT_LINE('debug7');
    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate amount');
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.amount: ',p_req_line.amount);
    END IF;

  IF p_req_line.amount IS NOT NULL THEN
    IF NVL(p_req_line.order_type_lookup_code, l_reqline_rec.order_type_lookup_code) <> 'AMOUNT' THEN
         /* Only for amount based line types*/
      l_progress := 110;
       IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,'p_req_line.amount: ',p_req_line.amount);
           PO_LOG.stmt(d_module_base,l_progress,'p_req_line.order_type_lookup_code: ',p_req_line.order_type_lookup_code);
        END IF;
        x_return_status := 'E' ;
        fnd_message.set_name ('PO','PO_RI_AMOUNT_NOT_NULL');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_AMOUNT_NOT_NULL');
        G_ERROR_COL := 'AMOUNT';
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RAISE USER_ERROR;
    END IF;
   END IF;
   IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate vendor information');
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_id: ',p_req_line.vendor_id);
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_site_id: ',p_req_line.vendor_site_id);
       PO_LOG.stmt(d_module_base,l_progress,'p_req_line.vendor_contact_id: ',p_req_line.vendor_contact_id);
       PO_LOG.stmt(d_module_base,l_progress,'source_type_code: ',NVL(p_req_line.source_type_code, l_reqline_rec.source_type_code));
    END IF;

  IF((p_req_line.vendor_id IS NOT NULL OR p_req_line.vendor_site_id IS NOT NULL
    OR p_req_line.vendor_contact_id IS NOT NULL
    OR p_req_line.suggested_vendor_name IS NOT NULL
    OR p_req_line.suggested_vendor_location IS NOT NULL
    OR p_req_line.suggested_vendor_contact IS NOT NULL) ) THEN

   IF NVL(p_req_line.source_type_code, l_reqline_rec.source_type_code) = 'VENDOR' THEN
      l_progress := 120;
      validate_VendorInfo(p_req_line,l_reqline_rec.vendor_id, l_reqline_rec.vendor_site_id, l_reqline_rec.vendor_contact_id ,l_return_status, l_err_msg);
     IF l_return_status ='E' THEN
       x_return_status := l_return_status ;
       x_error_msg := l_err_msg;
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       RAISE USER_ERROR;
     END IF;
    ELSE
      x_return_status := 'E' ;
      x_error_msg := 'Source type code should be VENDOR';
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
      RAISE USER_ERROR;
    END IF;
  END IF;
   --dbms_OUTPUT.PUT_LINE('debug8');
   IF p_req_line.blanket_po_header_id IS NOT NULL OR p_req_line.blanket_po_number IS NOT NULL THEN
      l_progress := 130;
    IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'validate sourcing document');
      END IF;
      validate_SourcingDoc(p_req_line, l_return_status, l_err_msg);
        IF l_return_status ='E' THEN
       x_return_status := l_return_status ;
       x_error_msg := l_err_msg;
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       RAISE USER_ERROR;
     END IF;
   END IF;

   --dbms_OUTPUT.PUT_LINE('debug9');

   IF p_req_line.unit_price = -99999 AND p_req_line.action_flag='UPDATE' THEN
      l_progress := 140;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'redefaulting unit price');
      END IF;
    default_UnitPrice(p_req_line,l_return_status, l_err_msg);
   END IF;
   --dbms_OUTPUT.PUT_LINE('debug10');

----dbms_output.put_line('Debug9');
   IF p_req_line.item_description IS NOT NULL AND NVL(p_req_line.item_id,l_reqline_rec.item_id) IS NOT NULL  THEN
      /* validate item_description   Allow description flag is set at item*/
    l_progress := 150;
    BEGIN
      SELECT DISTINCT description, allow_item_desc_update_flag
      INTO l_desc, l_allow_item_desc_update_flag
      FROM mtl_system_items msi
      WHERE NVL(p_req_line.item_id,l_reqline_rec.item_id )= msi.inventory_item_id
      AND organization_id = NVL(p_req_line.destination_organization_id,l_reqline_rec.destination_organization_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'E' ;
        fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_ID');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_ID');
        G_ERROR_COL := 'ITEM_ID';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        po_message_s.sql_error('validate item_description, Allow description flag is set at item','150',SQLCODE);
        RAISE;
    END;
    --dbms_OUTPUT.PUT_LINE('debug10.1');
----dbms_output.put_line('Debug10');
    l_progress := 160;
    IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'validate item_description   Allow description flag is set at item');
         PO_LOG.stmt(d_module_base,l_progress,'item_id: ', l_reqline_rec.item_id);
         PO_LOG.stmt(d_module_base,l_progress,'item desc: ', l_desc);
         PO_LOG.stmt(d_module_base,l_progress,'p_req_line.item_description: ',p_req_line.item_description);
         PO_LOG.stmt(d_module_base,l_progress,'l_allow_item_desc_update_flag: ',l_allow_item_desc_update_flag);
      END IF;

    IF l_desc <> p_req_line.item_description  THEN
      IF l_allow_item_desc_update_flag <> 'Y' THEN
        x_return_status := 'E' ;
        fnd_message.set_name ('PO','PO_RI_ITEM_DESC_MISMATCH');
        fnd_msg_pub.ADD;
        x_error_msg := fnd_message.get_string('PO','PO_RI_ITEM_DESC_MISMATCH');
        G_ERROR_COL := 'ITEM_DESCRIPTION';
        IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
        RAISE USER_ERROR;
      END IF;
    END IF;
   END IF;
     --dbms_OUTPUT.PUT_LINE('debug10');
  /* doc
    Should be a valid buyer (Exists in po_buyers_val_v)"
  */
   IF p_req_line.suggested_buyer_id IS NOT NULL OR p_req_line.suggested_buyer_name IS NOT NULL THEN
      l_progress := 170;
       IF PO_LOG.d_stmt THEN
         PO_LOG.stmt(d_module_base,l_progress,'validate buyer id');
         PO_LOG.stmt(d_module_base,l_progress,'suggested_buyer_id:', p_req_line.suggested_buyer_name);
         PO_LOG.stmt(d_module_base,l_progress,'suggested_buyer_id:', p_req_line.suggested_buyer_id);
      END IF;

      BEGIN
        SELECT 'T', pbvv.employee_id
        INTO l_valid, p_req_line.suggested_buyer_id
        FROM po_buyers_val_v pbvv
        WHERE pbvv.employee_id = p_req_line.suggested_buyer_id OR pbvv.FULL_NAME = p_req_line.suggested_buyer_name;
    EXCEPTION
      WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_SUGGESTED_BUYER');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_SUGGESTED_BUYER');
          G_ERROR_COL := 'SUGGESTED_BUYER_ID';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
    END;
   END IF;
   --dbms_OUTPUT.PUT_LINE('debug10');
 /*
    source_type_code                "VENDOR/INVENTORY..
  If destination type is INVENTORY--> It should be INVENTORY
  Value gets derived from item defintion based on Purchased Item/Internal Ordered Item attribute"
  */

  l_progress := 180;
    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate source_organization_id');
    END IF;


     IF (p_req_line.source_organization_id IS NOT NULL
        OR p_req_line.source_subinventory IS NOT NULL
        OR p_req_line.source_organization_name IS NOT NULL
        ) THEN
      IF p_req_line.item_id IS NOT NULL OR l_reqline_rec.item_id IS NOT NULL THEN
      BEGIN
        SELECT 'T'
        INTO l_valid
        FROM mtl_system_items msi
        WHERE NVL(p_req_line.item_id,l_reqline_rec.item_id) = msi.inventory_item_id
        AND NVL(p_req_line.source_organization_id, l_reqline_rec.source_organization_id) = msi.organization_id
        AND msi.stock_enabled_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
          G_ERROR_COL := 'ITEM_ID';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
       END;
       BEGIN
        SELECT 'T'
        INTO l_valid
        FROM mtl_system_items msi
        WHERE NVL(p_req_line.item_id,l_reqline_rec.item_id) = msi.inventory_item_id
        AND NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id) =msi.organization_id
        AND msi.internal_order_enabled_flag = 'Y';
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_ITEM_SRC_INV_P');
          G_ERROR_COL := 'ITEM_ID';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
       END;
     END IF ;
    END IF;
    --dbms_OUTPUT.PUT_LINE('debug10');
    -- validate_HazardClasses(p_req_line, l_result_code);
    /*doc
    un_number_id/un number         Y   should in po_un_numbers_val_v
  hazard_class_id/hazard             Y   should in po_hazard_classes_val_v
  */

  IF p_req_line.secondary_quantity IS NOT NULL OR p_req_line.secondary_uom_code IS NOT NULL THEN
      -- validate_Secondary_UOM(p_req_line, l_result_code);
      /* Secondary unit of measure / secondary UOM not allowed for non-dual item */
      /* Secondary quantity not allowed for non-dual item */
      /* Validate secondary uom code */
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate_Secondary_UOM');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_quantity: ', p_req_line.secondary_quantity);
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.secondary_uom_code: ', p_req_line.secondary_uom_code);
      END IF;
      l_progress :=260;
    BEGIN
     SELECT 'T'
     INTO l_valid
     FROM  mtl_system_items msi
     WHERE NVL(p_req_line.item_id,l_reqline_rec.item_id) = msi.inventory_item_id
       AND NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id) =   msi.organization_id
       AND msi.tracking_quantity_ind = 'PS'
       AND msi.secondary_uom_code = p_req_line.secondary_uom_code;
      EXCEPTION
    WHEN NO_DATA_FOUND THEN
           x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_SECONDARY_UOM_NOT_REQUIRED');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_SECONDARY_UOM_NOT_REQUIRED');
          G_ERROR_COL := 'SECONDARY_UNIT_OF_MEASURE';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
          RAISE USER_ERROR;
      END;
    END IF;
    --dbms_OUTPUT.PUT_LINE('debug10');
    l_progress :=270;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,l_progress,'validate need_by_date');
      PO_LOG.stmt(d_module_base,l_progress,'p_req_line.need_by_date: ', p_req_line.need_by_date);
    END IF;
    IF p_req_line.need_by_date IS NOT NULL AND p_req_line.need_by_date < SYSDATE THEN
      x_return_status := 'E' ;
      x_error_msg := 'Need_By_Date needs to be greater than TODAY';
      IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
      RAISE USER_ERROR;
    END IF;
     --dbms_OUTPUT.PUT_LINE('debug10');
      IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'validate contract num');
    END IF;
  --dbms_OUTPUT.PUT_LINE('debug11');
  IF p_req_line.action_flag = 'NEW' THEN
     populate_sourcinginfo(p_req_line.source_type_code,'Y',p_req_line);

     validate_VendorInfo(p_req_line,l_reqline_rec.vendor_id,l_reqline_rec.vendor_site_id, l_reqline_rec.vendor_contact_id ,l_return_status, l_err_msg);
     IF l_return_status ='E' THEN
       x_return_status := l_return_status ;
       x_error_msg := l_err_msg;
       IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
      END IF;
       RAISE USER_ERROR;
     END IF;

     --dbms_OUTPUT.PUT_LINE('debug11.1');
     IF p_req_line.source_type_code = 'VENDOR' THEN
       Set_Break_Price('Y',p_req_line);
	   IF g_func_currency =  p_req_line.currency_code THEN
		    p_req_line.currency_unit_price := NULL;
		    p_req_line.rate := NULL;
		    p_req_line.rate_type := NULL;
		    p_req_line.rate_date := NULL;
		    p_req_line.currency_amount := NULL;
       END IF;
       --dbms_OUTPUT.PUT_LINE('debug11.2');
     END IF;
     IF NVL(p_req_line.unit_price,0)=0 THEN
       calculate_lineprice(p_req_line,x_return_status,x_error_msg);
       --dbms_OUTPUT.PUT_LINE('debug11.3');
       IF x_return_status = 'E' THEN
         RAISE USER_ERROR;
       END IF;
     END IF;
  END IF;
  --dbms_OUTPUT.PUT_LINE('debug12');
  -- validate need_by_date with source doc if populated

  IF p_req_line.need_by_date IS NOT NULL AND p_req_line.blanket_po_header_id IS NOT NULL THEN
  l_progress :=275;
  BEGIN
   SELECT 'T'
   INTO l_valid
   FROM po_headers_all poh
   WHERE poh.po_header_id = p_req_line.blanket_po_header_id
   AND p_req_line.need_by_date >= NVL(poh.start_date, p_req_line.need_by_date - 1);
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
           x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_PO_DATE_GTR_SED');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_PO_DATE_GTR_SED');
          G_ERROR_COL := 'NEED_BY_DATE';
          IF PO_LOG.d_stmt THEN
           PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
        END IF;
          RAISE USER_ERROR;
  END;
  END IF;

  IF p_req_line.un_number_id IS NOT NULL OR p_req_line.un_number IS NOT NULL THEN
    l_progress :=210;
    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate hazard class information, un_number_id/un number');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.un_number_id: ', p_req_line.un_number_id);
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.un_number: ', p_req_line.un_number);
    END IF;
    BEGIN
      SELECT 'T', punvv.un_number_id
      INTO l_valid, p_req_line.un_number_id
      FROM po_un_numbers_val_v punvv
      WHERE punvv.un_number_id = p_req_line.un_number_id
          OR punvv.un_number= p_req_line.un_number;
    EXCEPTION
    WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_UN_NUMBER_ID');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_UN_NUMBER_ID');
          G_ERROR_COL := 'UN_NUMBER_ID';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
       END;
  END IF;

    IF (p_req_line.hazard_class_id IS NOT NULL OR p_req_line.hazard_class IS NOT NULL)THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate hazard class information, hazard_class_id/hazard');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.hazard_class_id: ', p_req_line.hazard_class_id);
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.hazard_class: ', p_req_line.hazard_class);
      END IF;
      l_progress :=220;
      BEGIN
        SELECT 'T', phcvv.hazard_class_id
      INTO l_valid, p_req_line.hazard_class_id
      FROM po_hazard_classes_val_v phcvv
      WHERE phcvv.hazard_class_id = p_req_line.hazard_class_id
          OR phcvv.hazard_class = p_req_line.hazard_class;
    EXCEPTION
    WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_HAZARD_CLASS_ID');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_HAZARD_CLASS_ID');
          G_ERROR_COL := 'HAZARD_CLASS_ID';
          RAISE USER_ERROR;
      END;
    END IF;

    -- validate_Txn_Reason_Code(p_req_line, l_result_code);
        /* transaction_reason_code      Y   po_lookup_codes where lookup_type = 'TRANSACTION REASON'*/
    IF p_req_line.TRANSACTION_REASON_CODE IS NOT NULL THEN
      l_progress :=230;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate TRANSACTION_REASON_CODE');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.TRANSACTION_REASON_CODE: ', p_req_line.TRANSACTION_REASON_CODE);
      END IF;
      BEGIN
          SELECT 'T'
        INTO l_valid
        FROM po_lookup_codes plc
        WHERE lookup_type = 'TRANSACTION REASON'
          AND plc.lookup_code = p_req_line.TRANSACTION_REASON_CODE;
      EXCEPTION
    WHEN OTHERS  THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_RI_INVALID_TRX_REASON');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_RI_INVALID_TRX_REASON');
          G_ERROR_COL := 'TRANSACTION_REASON_CODE';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
      END;
    END IF;


    IF p_req_line.preferred_grade IS NOT NULL THEN
      -- validate_Pref_Grade(p_req_line, l_result_code);
      --  preferred_grade              Y   grade is not allowed for non-grade item
      l_progress :=240;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate preferred_grade');
        PO_LOG.stmt(d_module_base,l_progress,'p_req_line.preferred_grade: ', p_req_line.preferred_grade);
      END IF;
      BEGIN
      SELECT 'T'
      INTO l_valid
      FROM mtl_grades_b mgr
      WHERE mgr.grade_code = p_req_line.preferred_grade
      AND  disable_flag = 'N';
    EXCEPTION
    WHEN OTHERS THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_INVALID_GRADE_CODE');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_INVALID_GRADE_CODE');
          G_ERROR_COL := 'PREFERRED_GRADE';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
      END;

     l_progress :=250;
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,l_progress,'validate preferred_grade,  grade is not allowed for non-grade item');
      END IF;
      BEGIN
      SELECT 'T'
      INTO l_valid
      FROM  mtl_system_items msi
      WHERE l_reqline_rec.item_id = msi.inventory_item_id
      AND   NVL(p_req_line.destination_organization_id, l_reqline_rec.destination_organization_id) =   msi.organization_id
      AND    NVL(msi.grade_control_flag,'N') = 'N';
    EXCEPTION
    WHEN OTHERS  THEN
          x_return_status := 'E' ;
          fnd_message.set_name ('PO','PO_ITEM_NOT_GRADE_CTRL');
          fnd_msg_pub.ADD;
          x_error_msg := fnd_message.get_string('PO','PO_ITEM_NOT_GRADE_CTRL');
          G_ERROR_COL := 'PREFERRED_GRADE';
          IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,l_progress,x_error_msg);
          END IF;
          RAISE USER_ERROR;
      END;
    END IF; --end if p_req_line.preferred_grade IS NOT NULL then



    IF p_req_line.contract_number IS NOT NULL OR p_req_line.oke_contract_header_id IS NOT NULL THEN
       BEGIN
         SELECT ID
         INTO p_req_line.oke_contract_header_id
         FROM okc_k_headers_b
         WHERE (ID= p_req_line.oke_contract_header_id OR contract_number = p_req_line.contract_number);

        EXCEPTION
        WHEN OTHERS THEN
          x_error_msg := 'Error in fetching Contract details';
          RAISE USER_ERROR;
       END;
    END IF;

   IF p_req_line.rebuild_accounts = 'Y' THEN
     rebuild_accounts(p_req_line,p_accounts_tbl,x_return_status,p_init_msg,x_error_msg);
        IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'After rebuild_accounts call, error msg:' || x_error_msg);
        END IF;
   END IF;
   IF p_req_line.action_flag = 'NEW' THEN
     calculate_secondaryqty(p_req_line,x_return_status,x_error_msg);
     IF x_return_status =' E' THEN
       RAISE USER_ERROR;
     END IF;
   END IF;
  l_return_status :='S';
  IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,l_progress,'End Validation');
  END IF;
  --dbms_OUTPUT.PUT_LINE('Debug End');
EXCEPTION
   WHEN USER_ERROR THEN
      x_return_status := 'E';
      LOG_INTERFACE_ERRORS(g_error_col,x_error_msg,p_req_line.requisition_header_id,'PO_REQUISITION_LINES',p_req_line.requisition_line_num,NULL);
      l_err_msg := 'Validation failure occured at Requisition No/Id: '||p_req_line.requisition_number||'/'||p_req_line.requisition_header_id||'Line No/Id: '||p_req_line.requisition_line_num||'/'||p_req_line.requisition_line_id;
      x_error_msg := l_err_msg||x_error_msg;
    --  po_message_s.add_exc_msg(d_module_base,'val_requisition_line',x_error_msg);
      --po_message_s.concat_fnd_messages_in_stack(Fnd_Msg_Pub.Count_Msg,x_error_msg);
      --dbms_OUTPUT.PUT_LINE('x_error_msg'||x_error_msg);
     WHEN OTHERS THEN
      x_return_status :='E';
      x_error_msg := 'Unexpected error occured at '||l_progress|| SQLERRM;
      LOG_INTERFACE_ERRORS(g_error_col,x_error_msg,p_req_line.requisition_header_id,'PO_REQUISITION_LINES',p_req_line.requisition_line_num,NULL);
      po_message_s.sql_error('val_requisition_line',x_error_msg,SQLCODE);
      --dbms_OUTPUT.PUT_LINE('x_error_msg'||x_error_msg);
END val_requisition_line;

PROCEDURE rebuild_accounts(p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                p_accounts_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PVT.accounts_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 )
IS

  -- Logging Infra
  l_module_name CONSTANT VARCHAR2(100) := 'rebuild_accounts';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_progress NUMBER;
  user_error EXCEPTION;
  l_return_status VARCHAR2(2);
  --
  x_account_id NUMBER;
  CURSOR cur_coa(p_org_id NUMBER)
  IS SELECT gsb.chart_of_accounts_id
  FROM financials_system_params_all fsp,
  gl_sets_of_books gsb
  WHERE fsp.org_id = p_org_id
  AND  gsb.set_of_books_id = fsp.set_of_books_id;

  CURSOR c_dist(p_req_line NUMBER)
  IS SELECT *
  FROM po_req_distributions
  WHERE  REQUISITION_LINE_ID = p_req_line;

  l_coa NUMBER;
  l_counter NUMBER;
  l_orig_count NUMBER :=0;
  l_dist_rec PO_REQUISITION_UPDATE_PUB.req_dist;
BEGIN
  -- Logging Infra: Setting up runtime level

   IF p_req_line.rebuild_accounts = 'Y' THEN
     IF p_req_line.deliver_to_location_id IS NOT NULL
        OR p_Req_line.category_id IS NOT NULL
        OR p_req_line.destination_organization_id IS NOT NULL
        OR p_req_line.destination_type_code IS NOT NULL
        OR p_req_line.destination_subinventory IS NOT NULL
        OR p_req_line.vendor_id IS NOT NULL
        OR p_req_line.vendor_site_id IS NOT NULL
     THEN

         OPEN cur_coa(p_req_line.org_id);
         FETCH cur_coa INTO l_coa;
         CLOSE cur_coa;

       FOR i_rec IN c_dist(p_req_line.requisition_line_id)
       LOOP
        l_dist_rec.distribution_id := i_rec.distribution_id;
        l_dist_rec.req_line_id := p_req_line.requisition_line_id;
        l_dist_rec.req_header_id := p_req_line.requisition_header_id;
        x_error_msg := NULL;
        x_return_status := NULL;
        x_account_id := NULL;

        po_requisition_validate_pvt.call_account_generator(l_dist_rec,p_req_line,l_coa,x_account_id,x_error_msg,x_return_status);

        IF x_return_status = 'E' THEN
          x_error_msg := 'account generation failed for requisition, line_id: ' || p_req_line.requisition_line_id ;
          EXIT;
        END IF;

        IF p_accounts_tbl.FIRST IS NULL THEN
          l_counter := 1;
        ELSE
          l_counter := p_accounts_tbl.LAST;
          l_orig_count := l_counter;
        END IF;

        IF l_orig_count = 0 THEN
          l_orig_count := l_counter;
        END IF;

        p_accounts_tbl(l_counter).distribution_id := l_dist_rec.distribution_id;
        p_accounts_tbl(l_counter).req_line_id := l_dist_rec.req_line_id;
        p_accounts_tbl(l_counter).ccid := l_dist_rec.code_combination_id;
        p_accounts_tbl(l_counter).budget_account_id := l_dist_rec.budget_account_id;
        p_accounts_tbl(l_counter).variance_account_id := l_dist_rec.variance_account_id;
        p_accounts_tbl(l_counter).accrual_account_id := l_dist_rec.accrual_account_id;

        l_counter := l_counter+1;

       END LOOP;

       IF x_return_status = 'E' THEN
         p_accounts_tbl.DELETE(l_orig_count,l_counter-1);
       END IF;
     END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_error_msg := SQLERRM;
    x_return_status := 'E';
    po_message_s.sql_error('rebuild_accounts_from_line','010',SQLCODE);
    RAISE;
END rebuild_accounts;

procedure doc_state_check_approve(p_req_hdr PO_REQUISITION_UPDATE_PUB.req_hdr,
                                  p_document_subtype VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_error_msg OUT NOCOPY VARCHAR2)
IS
	l_ret_sts      VARCHAR2(1);
	l_exc_msg      VARCHAR2(2000);
	l_ret_code     VARCHAR2(25);
	l_module_name CONSTANT VARCHAR2(100) := 'doc_state_check_approve';
	d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_progress NUMBER;
BEGIN
	PO_DOCUMENT_ACTION_PVT.check_doc_status_approve(
    p_document_id        =>  p_req_hdr.requisition_header_id
 ,  p_document_type      =>  'REQUISITION'
 ,  p_document_subtype   =>  p_document_subtype
 ,  x_return_status      =>  l_ret_sts
 ,  x_return_code        =>  l_ret_code
 ,  x_exception_msg      =>  l_exc_msg
 );

   IF (l_ret_sts = 'S') THEN

    /*  If state check passed, then l_ret_code should be null
    **  otherwise it should be 'STATE_FAILED'.
    */

   IF (l_ret_code is NOT NULL) THEN
     l_progress := 10;
     x_return_status := 'E';
     x_error_msg := l_exc_msg;
   ELSE
      x_return_status := 'S';
   END IF;  -- l_ret_code IS NULL

 ELSE

   l_progress := 20;
   x_return_status := 'E';
   x_error_msg :=  l_exc_msg;

 END IF;  -- l_ret_sts = 'S'
END;

procedure document_submission_check(p_req_hdr  PO_REQUISITION_UPDATE_PUB.req_hdr,
                                    x_return_status OUT NOCOPY varchar2,
                                    x_error_msg OUT NOCOPY varchar2)
IS
    x_sub_check_status VARCHAR2(1);
    x_msg_data VARCHAR2(2000);
    l_error_msg VARCHAR2(100);
    l_error   VARCHAR2(1) := 'W';
    x_online_report_id NUMBER;
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_progress NUMBER;
    l_module_name CONSTANT VARCHAR2(100) := 'document_submission_check';
    d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
    l_attribute_text             VARCHAR2(4000);
    len_att_text                 NUMBER  := 0;
    i                            NUMBER;
    TYPE g_report_list_type       IS TABLE OF VARCHAR2(2000);
    l_report_text_lines          g_report_list_type;
    l_document_subtype po_requisition_headers_all.type_lookup_code%TYPE;
    user_error EXCEPTION;
BEGIN

   SELECT type_lookup_code
   INTO   l_document_subtype
   FROM po_requisition_headers
   WHERE requisition_header_id = p_req_hdr.requisition_header_id;

    x_return_status := 'S';

 l_progress := 5;

IF PO_LOG.d_stmt THEN
PO_LOG.stmt(d_module_base,l_progress,'requisition_header_id',p_req_hdr.requisition_header_id);
PO_LOG.stmt(d_module_base,l_progress,'type_lookup_code',l_document_subtype);
END IF;

 begin

  doc_state_check_approve(p_req_hdr,l_document_subtype,x_return_status,x_error_msg);

    if nvl(x_return_status,'S') <> 'S' THEN

      G_ERROR_COL := 'doc_state_check_approve';
      RAISE user_error;

    end if;

 End;

	PO_DOCUMENT_CHECKS_GRP.po_submission_check(
     p_api_version        => 1.0,
     p_action_requested   => 'DOC_SUBMISSION_CHECK',
     p_document_type      => 'REQUISITION',
     p_document_subtype   => l_document_subtype,
     p_document_id        => p_req_hdr.requisition_header_id,
     p_check_asl          => FALSE,
     x_return_status      => x_return_status,
     x_sub_check_status   => x_sub_check_status,
     x_msg_data           => x_msg_data,
     x_online_report_id   => x_online_report_id)
   ;
   commit;
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF x_sub_check_status = FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := 'S';
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'x_return_status',x_return_status);
      END IF;
      ELSE

         l_progress := 10;

            BEGIN
                -- SQL What:Checks for error message type in error table
                -- SQL Why :If no errors and only warnings then, success is returned
                -- SQL JOIN: NONE
                SELECT 'E'
                INTO l_error
                FROM dual
                WHERE EXISTS (SELECT 1
                         FROM PO_ONLINE_REPORT_TEXT
                         WHERE online_report_id = x_online_report_id
                         AND NVL(message_type, 'E') = 'E');  -- Bug 3906870
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_error:='W';
            END;
            IF (nvl(l_error,'W') = 'W') then
                 l_progress := 20;
                 x_return_status := 'S';
            ELSE
                 x_return_status := 'E';
            END IF; --l_error=W
      IF PO_LOG.d_stmt THEN
       PO_LOG.stmt(d_module_base,l_progress,'x_return_status',x_return_status);
      END IF;
     END IF;
    ELSE
      x_return_status := 'E';
    END IF;
		IF x_return_status = 'E' THEN
     SELECT substr(text_line, 1, 2000)
		  BULK COLLECT INTO l_report_text_lines
		  FROM po_online_report_text
		  WHERE online_report_id = x_online_report_id
		  ORDER BY sequence;

		  l_progress := 30;

		  -- Loop through the plsql table, and concatenate each of the lines.
		  -- Exit the loop if we run out of lines, or the string exceeds 2000 characters.
		  -- Overflow is avoided since l_attribute_text is 4000 char.
		  i := l_report_text_lines.FIRST;
		  WHILE ((i is NOT NULL) and (len_att_text < 2000))
		  LOOP
		    l_attribute_text := l_attribute_text || l_report_text_lines(i) || fnd_global.local_chr(10) ; --Bug 10625022
		    len_att_text := length(l_attribute_text);
		    i := l_report_text_lines.NEXT(i);
		  END LOOP;
		  x_error_msg := substr('Online Report Id'||x_online_report_id||l_attribute_text,1,2000);
		 G_ERROR_COL := 'SUBMISSION CHECK';
		 RAISE user_error;
		 END IF;

EXCEPTION
WHEN USER_ERROR THEN
      x_return_status := 'E';
      log_interface_errors(g_error_col,
                               x_error_msg,
                               p_req_hdr.requisition_header_id,
                               'PO_REQUISITION_HEADERS',
                               null,
                               null);
      l_error_msg := 'Validation failure occured at Requisition '||
                     'No/Id: '||NVL(p_req_hdr.segment1,p_req_hdr.requisition_header_id);
      x_error_msg := SUBSTR(l_error_msg||x_error_msg,1,2000);
      po_message_s.add_exc_msg('Package',d_module_base,SUBSTR(x_error_msg,1,240));
WHEN OTHERS THEN
       x_return_status :='E';
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('document_submission_check',l_progress,SQLCODE);
       RAISE;
END;

 END PO_REQUISITION_VALIDATE_PVT ;

/

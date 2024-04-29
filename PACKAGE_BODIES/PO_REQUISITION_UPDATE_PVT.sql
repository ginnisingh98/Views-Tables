--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_UPDATE_PVT" AS
/* $Header: POXRQUPVTB.pls 120.0.12010000.10 2014/07/16 03:11:34 fenyan noship $ */
/*===========================================================================
  FILE NAME    :         POXRQUPVTB.pls
  PACKAGE NAME:         PO_REQUISITION_UPDATE_PVT

  DESCRIPTION:
      PO_REQUISITION_UPDATE_PVT API performs update operations on Requisition
      header,line and distribution. It allows updation on requisition that is
      in Incomplete status or Approved without attached PO.

 PROCEDURES:
     update_requisition_header
     update_requisition_line
     update_requisition_dist

==============================================================================*/
-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PKG_NAME CONSTANT VARCHAR2(40) := 'PO_REQUISITION_UPDATE_PVT';

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);


PROCEDURE update_requisition_header ( p_req_hdr IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr,
                               x_return_status OUT NOCOPY    VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                               p_submit_approval IN VARCHAR2, p_commit IN VARCHAR2) IS
l_return_status VARCHAR2(20);
l_error_msg VARCHAR2(1000);
l_progress VARCHAR2(1000);

l_module_name CONSTANT VARCHAR2(100) := 'update_requisition_header';
d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
d_progress NUMBER;
l_authorization_status VARCHAR2(40);
l_preparer_id NUMBER;

BEGIN
  l_progress := '010';

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_hdr.requisition_header_id', p_req_hdr.requisition_header_id);
    PO_LOG.proc_begin(d_module_base, 'p_req_hdr.segment1', p_req_hdr.segment1);
  END IF;
  d_progress := 10;
  PO_REQUISITION_VALIDATE_PVT.val_requisition_hdr (p_req_hdr,
                               l_return_status ,
                               p_init_msg      ,
                               l_error_msg   );


  d_progress := 20;
  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_return_status',l_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'l_error_msg',l_error_msg);
  END IF;
  IF l_return_status = 'E' THEN
     x_return_status := 'E';
     x_error_msg := l_error_msg;
     po_message_s.sql_error('Validation failure',d_progress,'');
     RETURN;
  ELSE
     IF p_req_hdr.authorization_status = 'APPROVED' THEN
      BEGIN
       por_util_pkg.withdraw_req(p_req_hdr.requisition_header_id);
      EXCEPTION
        WHEN OTHERS THEN
        x_return_status :='E';
        x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
        po_message_s.sql_error('update_requisition_header_tbl',d_progress,SQLCODE);
        RAISE;
      END;
     END IF;
    --Perform table update
       -- Do Update
   l_progress := 'Before Update';
 UPDATE po_requisition_headers_all
 SET      summary_flag                 =   NVL(p_req_hdr.summary_flag,summary_flag

                                               ),
      enabled_flag                 =   NVL(p_req_hdr.enabled_flag,enabled_flag),
      end_date_active              =   NVL(p_req_hdr.end_date_active,end_date_active),
      description                  =   NVL(p_req_hdr.description,description),
      note_to_authorizer           =   NVL(p_req_hdr.note_to_authorizer,
                                           note_to_authorizer)  ,
      attribute_category           =   NVL(p_req_hdr.attribute_category,attribute_category)   ,
      attribute1                   =   NVL(p_req_hdr.attribute1,attribute1)           ,
      attribute2                   =   NVL(p_req_hdr.attribute2,attribute2)            ,
      attribute3                   =   NVL(p_req_hdr.attribute3,attribute3)            ,
      attribute4                   =   NVL(p_req_hdr.attribute4,attribute4)            ,
      attribute5                   =   NVL(p_req_hdr.attribute5,attribute5)            ,
      attribute6                   =   NVL(p_req_hdr.attribute6,  attribute6)           ,
      attribute7                   =   NVL(p_req_hdr.attribute7,  attribute7)           ,
      attribute8                   =   NVL(p_req_hdr.attribute8,  attribute8)           ,
      attribute9                   =   NVL(p_req_hdr.attribute9,  attribute9)           ,
      attribute10                  =   NVL(p_req_hdr.attribute10, attribute10)          ,
      attribute11                  =   NVL(p_req_hdr.attribute11, attribute11)          ,
      attribute12                  =   NVL(p_req_hdr.attribute12, attribute12)          ,
      attribute13                  =   NVL(p_req_hdr.attribute13, attribute13)          ,
      attribute14                  =   NVL(p_req_hdr.attribute14, attribute14)          ,
      attribute15                  =   NVL(p_req_hdr.attribute15, attribute15)          ,
      government_context           =   NVL(p_req_hdr.government_context,government_context )  ,
      last_update_date             = SYSDATE,
      last_updated_by              = fnd_global.user_id,
      last_update_login            = fnd_global.login_id
   WHERE (requisition_header_id = p_req_hdr.requisition_header_id OR segment1 = p_req_hdr.segment1)
   AND  org_id = p_req_hdr.org_id;

   l_progress := 'After Update';

   IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
   END IF;

   IF p_commit = 'Y' THEN
       COMMIT;
   END IF;

   IF p_submit_approval = 'Y' THEN
     BEGIN

       SELECT authorization_status,preparer_id
       INTO l_authorization_status,l_preparer_id
       FROM po_requisition_headers
       WHERE requisition_header_id = p_req_hdr.requisition_header_id;



       IF l_authorization_status = 'INCOMPLETE' THEN

          submit_for_approval(p_req_hdr.requisition_header_id,
                             l_preparer_id,
                             NULL,
                             p_req_hdr.note_to_approver,
                             x_return_status,
                             x_error_msg);

       END IF;
     EXCEPTION
      WHEN OTHERS THEN
         x_error_msg := ' Unxpected error occured '||SQLERRM;
         po_message_s.sql_error('update_requisition_header_submit_approval',d_progress,SQLCODE);
         RAISE;
     END;
    END IF;
  END IF;

  x_return_status := 'S';

  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
  END IF;
 EXCEPTION
 WHEN OTHERS THEN
      x_return_status :='E';
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('update_requisition_header',d_progress,SQLCODE);
       RAISE;

END;


PROCEDURE update_requisition_header ( p_req_hdr_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 ,
                               p_req_hdr_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               p_req_hdr_err_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_hdr_tbl,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2)
IS

l_return_status VARCHAR2(10);
l_error_msg VARCHAR2(1000);

D_PACKAGE_BASE VARCHAR2(1);
 l_module_name CONSTANT VARCHAR2(100) := 'update_requisition_header_tbl';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;

l_err_count NUMBER := 1;
l_success_count NUMBER :=1;
l_authorization_status VARCHAR2(50);
l_preparer_id NUMBER;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
  END IF;
  x_return_status := 'S';
  FOR i IN 1..p_req_hdr_tbl.COUNT
  LOOP
  BEGIN
    l_return_status := NULL;
    l_error_msg := NULL;

    PO_REQUISITION_VALIDATE_PVT.val_requisition_hdr (p_req_hdr_tbl(i),
                               l_return_status ,
                               p_init_msg      ,
                               l_error_msg   );

    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'p_req_hdr_tbl(i).requisition_header_id',p_req_hdr_tbl(i).requisition_header_id);
        PO_LOG.stmt(d_module_base,d_progress,'l_return_status',l_return_status);
    END IF;

    IF l_return_status = 'E' THEN
         p_req_hdr_err_tbl(l_err_count) :=  p_req_hdr_tbl(i);
         p_req_hdr_err_tbl(l_err_count).error_message := l_error_msg;
         l_err_count :=  l_err_count+1;
    ELSE
        IF p_req_hdr_tbl(i).authorization_status = 'APPROVED' THEN
        BEGIN
         d_progress := 40;
         por_util_pkg.withdraw_req(p_req_hdr_tbl(i).requisition_header_id);
         p_req_hdr_tbl_out(l_success_count) :=  p_req_hdr_tbl(i);
         l_success_count := l_success_count+1;
        EXCEPTION
          WHEN OTHERS THEN
          p_req_hdr_err_tbl(l_err_count) :=  p_req_hdr_tbl(i);
          l_err_count :=  l_err_count+1;
          x_return_status :='E';
          x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
          po_message_s.sql_error('update_requisition_header_tbl',d_progress,SQLCODE);
        END;
      ELSE
         p_req_hdr_tbl_out(l_success_count) :=  p_req_hdr_tbl(i);
         l_success_count := l_success_count+1;
      END IF; -- l_authorization_status = 'APPROVED'

    END IF;

    IF p_commit = 'Y' THEN
      COMMIT;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.add_exc_msg('update_requisition_header','Update_requisition_header',SQLCODE||SQLERRM);
  END;
  END LOOP;

  FORALL i IN 1..p_req_hdr_tbl_out.COUNT
   UPDATE po_requisition_headers_all
   SET
      summary_flag                 =   NVL(p_req_hdr_tbl_out(i).summary_flag,summary_flag),
      enabled_flag                 =   NVL(p_req_hdr_tbl_out(i).enabled_flag,enabled_flag),
      end_date_active              =   NVL(p_req_hdr_tbl_out(i).end_date_active,end_date_active),
      description                  =   NVL(p_req_hdr_tbl_out(i).description,description) ,
      note_to_authorizer           =   NVL(p_req_hdr_tbl_out(i).note_to_authorizer,note_to_authorizer)  ,
      attribute_category           =   NVL(p_req_hdr_tbl_out(i).attribute_category,attribute_category)   ,
      attribute1                   =   NVL(p_req_hdr_tbl_out(i).attribute1,attribute1)           ,
      attribute2                   =   NVL(p_req_hdr_tbl_out(i).attribute2,attribute2)            ,
      attribute3                   =   NVL(p_req_hdr_tbl_out(i).attribute3,attribute3)            ,
      attribute4                   =   NVL(p_req_hdr_tbl_out(i).attribute4,attribute4)            ,
      attribute5                   =   NVL(p_req_hdr_tbl_out(i).attribute5,attribute5)            ,
      attribute6                   =   NVL(p_req_hdr_tbl_out(i).attribute6,  attribute6)           ,
      attribute7                   =   NVL(p_req_hdr_tbl_out(i).attribute7,  attribute7)           ,
      attribute8                   =   NVL(p_req_hdr_tbl_out(i).attribute8,  attribute8)           ,
      attribute9                   =   NVL(p_req_hdr_tbl_out(i).attribute9,  attribute9)           ,
      attribute10                  =   NVL(p_req_hdr_tbl_out(i).attribute10, attribute10)          ,
      attribute11                  =   NVL(p_req_hdr_tbl_out(i).attribute11, attribute11)          ,
      attribute12                  =   NVL(p_req_hdr_tbl_out(i).attribute12, attribute12)          ,
      attribute13                  =   NVL(p_req_hdr_tbl_out(i).attribute13, attribute13)          ,
      attribute14                  =   NVL(p_req_hdr_tbl_out(i).attribute14, attribute14)          ,
      attribute15                  =   NVL(p_req_hdr_tbl_out(i).attribute15, attribute15)          ,
      government_context           =   NVL(p_req_hdr_tbl_out(i).government_context,government_context )  ,
      last_update_date             = SYSDATE,
      last_updated_by              = fnd_global.user_id,
      last_update_login            = fnd_global.login_id
   WHERE requisition_header_id = p_req_hdr_tbl_out(i).requisition_header_id;

   IF p_submit_approval = 'Y' THEN
      FOR i IN 1..p_req_hdr_tbl_out.COUNT
      LOOP
        l_return_status := NULL;
        l_error_msg := NULL;
        BEGIN
          SELECT authorization_status,preparer_id
          INTO l_authorization_status,l_preparer_id
          FROM po_requisition_headers
          WHERE requisition_header_id = p_req_hdr_tbl_out(i).requisition_header_id;
          IF l_authorization_status = 'INCOMPLETE' THEN
              submit_for_approval(p_req_hdr_tbl_out(i).requisition_header_id,
                                  l_preparer_id,
                                  NULL,
                                  p_req_hdr_tbl_out(i).note_to_approver,
                                  l_return_status,
                                  l_error_msg);

             IF l_return_status = 'E' THEN
              p_req_hdr_err_tbl(l_err_count) := p_req_hdr_tbl_out(i);
              p_req_hdr_err_tbl(l_err_count).error_message := l_error_msg;
              x_return_status := 'E';
              x_error_msg := x_error_msg||' '||l_error_msg;
              l_err_count := l_err_count+1;
             END IF;
           END IF;
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status :='E';
          po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
          RAISE;
      END;
     END LOOP;

   END IF;

  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'p_req_hdr_tbl_out.count',p_req_hdr_tbl_out.COUNT);
        PO_LOG.stmt(d_module_base,d_progress,'No of Error records',p_req_hdr_err_tbl.COUNT);
  END IF;


  IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
  END IF;

 EXCEPTION
 WHEN OTHERS THEN
      x_return_status :='E';
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('update_requisition_header_tbl',d_progress,SQLCODE);
       RAISE;
END;


PROCEDURE submit_for_approval(p_req_hdr_id IN NUMBER,
                              p_preparer_id IN NUMBER,
                              p_forward_to_id IN NUMBER,
                               p_note_to_approver IN VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2)
IS
l_document_subtype VARCHAR2(50);
x_wf_itemType po_requisition_headers_all.WF_item_type%TYPE;
x_wf_itemKey po_requisition_headers_all.WF_item_key%TYPE;
l_ameTransactionType po_document_types_all.ame_transaction_type%TYPE;
l_req_num po_requisition_headers_all.segment1%TYPE;
 l_module_name CONSTANT VARCHAR2(100) := 'submit_for_approval';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
BEGIN
  x_return_status := 'S';
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_hdr_id', p_req_hdr_id);
    PO_LOG.proc_begin(d_module_base, 'p_preparer_id', p_preparer_id);
    PO_LOG.proc_begin(d_module_base, 'p_forward_to_id', p_forward_to_id);
    PO_LOG.proc_begin(d_module_base, 'p_note_to_approver', p_note_to_approver);
  END IF;
  --Update Shopping cart flag to null
  UPDATE po_requisition_headers
  SET active_shopping_cart_flag = NULL
  WHERE requisition_header_id = p_req_hdr_id;

  d_progress := 20;



  BEGIN
    SELECT WF_item_type, WF_item_key,type_lookup_code INTO x_wf_itemType, x_wf_itemKey,l_document_subtype
    FROM po_requisition_headers_all
    WHERE requisition_header_id = p_req_hdr_id;
  EXCEPTION
    WHEN OTHERS THEN
       x_return_status :='E';
       x_error_msg := ' Unxpected error occured while fetching requisition details'||SQLERRM;
       po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
       RAISE;
  END;

  IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'wf_item_key',x_wf_itemType);
      PO_LOG.stmt(d_module_base,d_progress,'wf_item_type',x_wf_itemKey);
      PO_LOG.stmt(d_module_base,d_progress,'l_document_subtype',l_document_subtype);
  END IF;

  d_progress := 30;
   BEGIN
     SELECT ame_transaction_type
     INTO l_ameTransactionType
     FROM po_document_types
     WHERE document_type_code = 'REQUISITION'
     AND document_subtype   = l_document_subtype;
     EXCEPTION
    WHEN OTHERS THEN
            l_ameTransactionType := 'PURCHASE_REQ';
   END;

   d_progress := 40;

     IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'l_ameTransactionType',l_ameTransactionType);
    END IF;

     IF l_ameTransactionType IS NOT NULL THEN

     --Bug 7008748 (Changed ame_api.clearAllApprovals to ame_api2.clearAllApprovals
     --as directed by IP)

       ame_api2.clearAllApprovals(applicationIdIn=>201,
                       transactionIdIn=>p_req_hdr_id,
                       transactionTypeIn=>l_ameTransactionType);
     END IF;

     d_progress := 50;

      BEGIN
        UPDATE po_approval_list_headers
           SET latest_revision = 'N'
         WHERE document_id = p_req_hdr_id
          AND  document_type = 'REQUISITION'
           AND document_subtype = l_document_subtype
           AND latest_revision = 'Y'
           AND wf_item_type IS NULL
           AND wf_item_key IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
           x_return_status :='E';
           x_error_msg := ' Unxpected error occured while fetching requisition details'||SQLERRM;
           po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
           RAISE;
      END;

      d_progress := 60;

   PO_REQAPPROVAL_INIT1.Start_WF_Process(
       ItemType => x_wf_itemType,
       ItemKey   => x_wf_itemKey,
       WorkflowProcess => NULL,
       ActionOriginatedFrom => NULL,
       DocumentID  => p_req_hdr_id,
       DocumentNumber =>  l_req_num,
       PreparerID => p_preparer_id,
       DocumentTypeCode => 'REQUISITION',
       DocumentSubtype  => l_document_subtype,
       SubmitterAction => 'APPROVE',
       forwardToID  =>  p_forward_to_id,
       forwardFromID  => p_preparer_id,
       DefaultApprovalPathID => NULL,
       note => p_note_to_approver);

       d_progress := 70;

     IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
EXCEPTION
WHEN OTHERS THEN
       x_return_status :='E';
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
       RAISE;
END submit_for_approval;

PROCEDURE recalculate_dist_quantity (p_req_line IN PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                                p_original_quantity IN NUMBER,
                                x_distQuantity_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PVT.dist_quantity_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 )
IS

  l_module_name CONSTANT VARCHAR2(100) := 'recalculateDistQuantity';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_progress NUMBER;
  user_error EXCEPTION;
  l_return_status VARCHAR2(2);
  l_count NUMBER :=1;

  CURSOR c_dist(p_req_line NUMBER)
  IS SELECT distribution_id, requisition_line_id, req_line_quantity
  FROM po_req_distributions
  WHERE  REQUISITION_LINE_ID = p_req_line;

  l_dist_rec PO_REQUISITION_UPDATE_PUB.req_dist;
BEGIN
  FOR i_rec IN c_dist(p_req_line.requisition_line_id)
  LOOP
    x_distQuantity_tbl(l_count).distribution_id :=i_rec.distribution_id;
    x_distQuantity_tbl(l_count).req_line_id :=i_rec.requisition_line_id;
    x_distQuantity_tbl(l_count).req_line_quantity :=i_rec.req_line_quantity * (p_req_line.quantity/ p_original_quantity);
    l_count := l_count+1;
  END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
      x_error_msg := SQLERRM;
      x_return_status := 'E';
      po_message_s.sql_error('recalculate_dist_quantity ','010',SQLCODE);
      RAISE;
END recalculate_dist_quantity ;

PROCEDURE recal_dist_quantity_amount (p_req_dist_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl)
IS

  l_module_name CONSTANT VARCHAR2(100) := 'recal_dist_quantity_amount';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_req_quantity NUMBER;
  l_req_amount NUMBER;
  l_currency_code VARCHAR2(15);
  l_rate NUMBER;
  l_ORDER_TYPE_LOOKUP_CODE	VARCHAR2	(25);
BEGIN
  FOR i IN 1..p_req_dist_tbl.COUNT
  LOOP

     SELECT quantity , amount , CURRENCY_code , rate , ORDER_TYPE_LOOKUP_CODE
     INTO l_req_quantity , l_req_amount,l_currency_code, l_rate ,l_ORDER_TYPE_LOOKUP_CODE
     FROM po_requisition_lines
     WHERE requisition_line_id = p_req_dist_tbl(i).req_line_id;

  IF l_ORDER_TYPE_LOOKUP_CODE = 'FIXED PRICE' THEN

  IF p_req_dist_tbl(i).dist_amount IS NOT NULL OR p_req_dist_tbl(i).allocation_value IS NOT NULL
     THEN

     IF p_req_dist_tbl(i).dist_amount IS NOT NULL THEN

        p_req_dist_tbl(i).req_line_amount := p_req_dist_tbl(i).dist_amount;

     END IF;

     IF p_req_dist_tbl(i).allocation_value IS NOT NULL THEN

        p_req_dist_tbl(i).req_line_amount := ROUND((l_req_amount * (p_req_dist_tbl(i).allocation_value/100)),18);

     END IF;

   END IF;

     IF NVL(p_req_dist_tbl(i).req_line_amount,0) = 0  and p_req_dist_tbl(i).action_flag<> 'UPDATE'  THEN
        p_req_dist_tbl(i).req_line_amount := l_req_amount;
     END IF;

     IF l_rate IS NOT NULL THEN

        p_req_dist_tbl(i).currency_amount := ROUND(p_req_dist_tbl(i).req_line_amount/l_rate,
                                                   PO_CURRENCY_SV.get_currency_precision(l_currency_code));

     END IF;

  ELSE

  IF p_req_dist_tbl(i).dist_quantity IS NOT NULL OR p_req_dist_tbl(i).allocation_value IS NOT NULL
     THEN

     IF p_req_dist_tbl(i).dist_quantity IS NOT NULL THEN

        p_req_dist_tbl(i).req_line_quantity := p_req_dist_tbl(i).dist_quantity;

     END IF;

     IF p_req_dist_tbl(i).allocation_value IS NOT NULL THEN

        p_req_dist_tbl(i).req_line_quantity := ROUND((l_req_quantity * (p_req_dist_tbl(i).allocation_value/100)),18);

     END IF;

   END IF;

     IF NVL(p_req_dist_tbl(i).req_line_quantity,0) = 0 and p_req_dist_tbl(i).action_flag<> 'UPDATE' THEN
        p_req_dist_tbl(i).req_line_quantity := l_req_quantity;
     END IF;

   END IF;

  END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
      NULL;
END recal_dist_quantity_amount ;
/*
PROCEDURE val_dist_quantity_amount (p_req_dist_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                                    x_return_status OUT NOCOPY  VARCHAR2)
IS

  l_module_name CONSTANT VARCHAR2(100) := 'val_dist_quantity_amount';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  l_req_quantity NUMBER;
  l_req_amount NUMBER;
  l_dist_tbl PO_REQUISITION_UPDATE_PUB.req_dist_tbl;
  l_quantity NUMBER := 0;
  l_ORDER_TYPE_LOOKUP_CODE	VARCHAR2	(25);
  l_amount NUMBER := 0;
  x_error_msg VARCHAR2(5000);
  l_existing_line_qty NUMBER;
  l_upd_dist_num varchar2(2000);
BEGIN
  x_return_status := 'S';

  l_dist_tbl := p_req_dist_tbl;

  FOR i IN 1..p_req_dist_tbl.COUNT
  LOOP
   l_existing_line_qty:=0;
  IF p_req_dist_tbl(i).qty_amount_check = 'N' THEN
    SELECT quantity, amount , ORDER_TYPE_LOOKUP_CODE
     INTO l_req_quantity, l_req_amount, l_ORDER_TYPE_LOOKUP_CODE
     FROM po_requisition_lines
     WHERE requisition_line_id = p_req_dist_tbl(i).req_line_id;

    l_quantity := 0;
    l_amount := 0;
    IF l_ORDER_TYPE_LOOKUP_CODE = 'FIXED PRICE' THEN

    FOR j IN 1..l_dist_tbl.COUNT
    LOOP

      IF l_dist_tbl(j).req_line_id = p_req_dist_tbl(i).req_line_id THEN

          l_amount := ROUND(l_amount + NVL(l_dist_tbl(j).req_line_amount,0),18);
          p_req_dist_tbl(j).qty_amount_check := 'Y';
      END IF;

    END LOOP;

    IF ROUND(l_req_amount,18) <> l_amount THEN

     IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,10,'amount validation :: ',l_req_amount);
            PO_LOG.stmt(d_module_base,10,'amount validation :: ',l_amount);
     END IF;

     x_return_status := 'E';
     fnd_message.set_name ('PO','PO_RI_AMOUNT_MISMATCH');
     fnd_msg_pub.ADD;
     x_error_msg := fnd_message.get_string('PO','PO_RI_AMOUNT_MISMATCH');

   po_requisition_validate_pvt.log_interface_errors ( 'AMOUNT',SUBSTR(x_error_msg,1,2000),p_req_dist_tbl(i).req_header_id,
      'PO_REQ_DISTRIBUTIONS',p_req_dist_tbl(i).req_line_num ,p_req_dist_tbl(i).distribution_num);
      /*po_requisition_validate_pvt.log_interface_errors('AMOUNT',
                               x_error_msg,
                               p_req_dist_tbl(i).req_header_id,
                               p_req_dist_tbl(i).req_header_id,
                               p_req_dist_tbl(i).req_line_id,
                               p_req_dist_tbl(i).distribution_id ); */

   /* END IF;

    ELSE

    FOR j IN 1..l_dist_tbl.COUNT
    LOOP
      IF ((l_dist_tbl(j).req_line_id = p_req_dist_tbl(i).req_line_id ) OR (l_dist_tbl(j).req_line_num = p_req_dist_tbl(i).req_line_num)) THEN

          l_quantity := ROUND(l_quantity + NVL(l_dist_tbl(j).req_line_quantity,0),18);
          p_req_dist_tbl(j).qty_amount_check := 'Y';
      END IF;

    END LOOP;



    IF ROUND(l_req_quantity,18) <> l_quantity THEN

     IF PO_LOG.d_stmt THEN
            PO_LOG.stmt(d_module_base,10,'Quantity validation :: ',l_req_quantity);
            PO_LOG.stmt(d_module_base,10,'Quantity validation :: ',l_quantity);
     END IF;

     x_return_status := 'E';
     fnd_message.set_name ('PO','PO_RI_QUANTITY_MISMATCH');
     fnd_msg_pub.ADD;
     x_error_msg := fnd_message.get_string('PO','PO_RI_QUANTITY_MISMATCH');

     po_requisition_validate_pvt.log_interface_errors('QUANTITY',
                               x_error_msg,
                               p_req_dist_tbl(i).req_header_id,
                               'PO_REQ_DISTRIBUTIONS',
                               p_req_dist_tbl(i).req_line_num,
                               p_req_dist_tbl(i).distribution_num );

    END IF;
    END IF;
  END IF;
  END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
      NULL;
END val_dist_quantity_amount ;
*/
PROCEDURE update_requisition_line ( p_req_line IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_rec_type,
                               x_return_status OUT NOCOPY   VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                               p_submit_approval IN VARCHAR2,
                               p_commit IN VARCHAR2)
IS

  l_return_status VARCHAR2(20);
  l_error_msg VARCHAR2(5000);
  l_progress VARCHAR2(1000);

  l_module_name CONSTANT VARCHAR2(100) := 'update_requisition_line';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_authorization_status VARCHAR2(50);
  l_note_to_authorizer    PO_REQUISITION_HEADERS_ALL.note_to_authorizer%TYPE;
  l_preparer_id           PO_REQUISITION_HEADERS_ALL.preparer_id%TYPE;
  x_online_report_id    NUMBER;
  l_accounts_tbl PO_REQUISITION_UPDATE_PVT.accounts_tbl;
  l_distQuantity_tbl  PO_REQUISITION_UPDATE_PVT.dist_quantity_tbl;
  l_quantity  NUMBER;

  CURSOR c_req_line(p_hdr_id NUMBER,p_line_id NUMBER)
  IS SELECT *
  FROM po_requisition_lines
  WHERE requisition_line_id = p_line_id
  AND requisition_header_id = p_hdr_id;
  l_req_line_rec PO_REQUISITION_lines_all%ROWTYPE;

BEGIN
  d_progress := 10;
  x_return_status := 'S';
  PO_REQUISITION_VALIDATE_PVT.val_requisition_line (p_req_line,
                               l_accounts_tbl,
                               l_return_status ,
                               p_init_msg      ,
                               l_error_msg   );

  --dbms_output.put_line('After validate API'||l_error_msg);
  d_progress := 20;
  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_return_status',l_return_status);
        PO_LOG.stmt(d_module_base,d_progress,'l_error_msg',l_error_msg);
  END IF;

  d_progress := 30;

  IF l_return_status = 'E' THEN
     x_return_status := 'E';
     x_error_msg := l_error_msg;
     po_message_s.sql_error('Validation failure',d_progress,'');
     RETURN;
  ELSE
     SELECT authorization_status
     INTO l_authorization_status
     FROM po_requisition_headers
     WHERE requisition_header_id = p_req_line.requisition_header_id;
     d_progress := 40;
     IF l_authorization_status = 'APPROVED' THEN
      BEGIN
       por_util_pkg.withdraw_req(p_req_line.requisition_header_id);
      EXCEPTION
        WHEN OTHERS THEN
        x_return_status :='E';
        x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
        po_message_s.sql_error('update_requisition_header_tbl',d_progress,SQLCODE);
        RAISE;
      END;
     END IF;
     d_progress := 50;

    OPEN c_req_line(p_req_line.requisition_header_id,p_req_line.requisition_line_id);
    FETCH c_req_line INTO l_req_line_rec;
    CLOSE c_req_line;


     --update distribution quantity
    IF(p_req_line.quantity IS NOT NULL) THEN
      recalculate_dist_quantity(p_req_line, l_req_line_rec.quantity, l_distQuantity_tbl,
                            l_return_status ,
                            p_init_msg      ,
                            l_error_msg   );

      FORALL k IN 1..l_distQuantity_tbl.COUNT
      UPDATE po_req_distributions
      SET req_line_quantity = NVL(l_distQuantity_tbl(k).req_line_quantity, req_line_quantity)
      WHERE distribution_id = l_distQuantity_tbl(k).distribution_id
      AND requisition_line_id = l_distQuantity_tbl(k).req_line_id;
    END IF;

  --update distribution quantity

    UPDATE po_requisition_lines_all
    SET
         last_update_date                  =     SYSDATE,
          last_updated_by                   =     fnd_global.user_id,
          last_update_login                 =     fnd_global.login_id,
          line_type_id                  =NVL(p_req_line.line_type_id,line_type_id),
          item_description              =NVL(p_req_line.item_description,item_description),
          unit_meas_lookup_code         =NVL(p_req_line.unit_meas_lookup_code,unit_meas_lookup_code),
          unit_price                    =NVL(p_req_line.unit_price,unit_price),
          base_unit_price               =NVL(p_req_line.base_unit_price,base_unit_price),
          quantity                      =NVL(p_req_line.quantity,quantity),
          amount                        =NVL(p_req_line.amount,amount),
          source_type_code              =NVL(p_req_line.source_type_code,source_type_code),
          suggested_buyer_id            =NVL(p_req_line.Suggested_Buyer_Id,Suggested_Buyer_Id),
          document_type_code            =NVL(p_req_line.Document_Type_Code,Document_Type_Code),
          blanket_po_header_id          =NVL(p_req_line.Blanket_Po_Header_Id,Blanket_Po_Header_Id),
          blanket_po_line_num           =NVL(p_req_line.Blanket_Po_Line_Num,Blanket_Po_Line_Num),
          currency_code                 =NVL(p_req_line.Currency_Code,Currency_Code),
          rate_type                     =NVL(p_req_line.Rate_Type,Rate_Type),
          rate_date                     =NVL(p_req_line.Rate_Date,Rate_Date),
          rate                          =NVL(p_req_line.Rate,Rate),
          currency_unit_price           =NVL(p_req_line.Currency_Unit_Price,Currency_Unit_Price),
          currency_amount               =NVL(p_req_line.Currency_Amount,Currency_Amount),
          un_number_id                  =NVL(p_req_line.Un_Number_Id,Un_Number_Id),
          hazard_class_id               =NVL(p_req_line.Hazard_Class_Id,Hazard_Class_Id),
          source_organization_id        =NVL(p_req_line.Source_Organization_Id,Source_Organization_Id),
          source_subinventory           =NVL(p_req_line.Source_Subinventory,Source_Subinventory),
          destination_type_code         =NVL(p_req_line.Destination_Type_Code,Destination_Type_Code),
          destination_organization_id   =NVL(p_req_line.Destination_Organization_Id,Destination_Organization_Id),
          destination_subinventory      =NVL(p_req_line.Destination_Subinventory,Destination_Subinventory),
          secondary_quantity            =NVL(p_req_line.Secondary_Quantity,Secondary_Quantity),
          vendor_id                     =NVL(p_req_line.Vendor_Id,Vendor_Id),
          vendor_site_id                =NVL(p_req_line.Vendor_Site_Id,Vendor_Site_Id),
          vendor_contact_id             =NVL(p_req_line.Vendor_Contact_Id,Vendor_Contact_Id),
          research_agent_id             =NVL(p_req_line.Research_Agent_Id,Research_Agent_Id),
          on_line_flag                  =NVL(p_req_line.On_Line_Flag,On_Line_Flag),
          preferred_grade               =NVL(p_req_line.preferred_grade,preferred_grade),
          secondary_unit_of_measure     =NVL(p_req_line.secondary_uom_code,secondary_unit_of_measure),
          TRANSACTION_REASON_CODE       =NVL(p_req_line.TRANSACTION_REASON_CODE,TRANSACTION_REASON_CODE),
          suggested_vendor_name         =NVL(p_req_line.Suggested_Vendor_Name,Suggested_Vendor_Name),
          suggested_vendor_location     =NVL(p_req_line.Suggested_Vendor_Location,Suggested_Vendor_Location),
          suggested_vendor_contact     =NVL(p_req_line.Suggested_Vendor_Location,Suggested_Vendor_Contact),
          suggested_vendor_phone        =NVL(p_req_line.Suggested_Vendor_Phone,Suggested_Vendor_Phone),
          order_type_lookup_code        =NVL(p_req_line.order_type_lookup_code,order_type_lookup_code),
          justification                 =NVL(p_req_line.justification,justification),
          note_to_agent                 =NVL(p_req_line.note_to_agent,note_to_agent),
          note_to_receiver              =NVL(p_req_line.note_to_receiver,note_to_receiver),
          suggested_vendor_product_code =NVL(p_req_line.suggested_vendor_product_code,suggested_vendor_product_code),
          need_by_date                  =NVL(p_req_line.need_by_date,need_by_date),
          urgent_flag                   =NVL(p_req_line.urgent_flag,urgent_flag),
          deliver_to_location_id        =NVL(p_req_line.deliver_to_location_id,deliver_to_location_id),
          oke_contract_header_id        =NVL(p_req_line.oke_contract_header_id,oke_contract_header_id),
          attribute1                    =NVL(p_req_line.attribute1,attribute1),
          attribute2                    =NVL(p_req_line.attribute2,attribute2),
          attribute3                    =NVL(p_req_line.attribute3,attribute3),
          attribute4                    =NVL(p_req_line.attribute4,attribute4),
          attribute5                    =NVL(p_req_line.attribute5,attribute5),
          attribute6                    =NVL(p_req_line.attribute6,attribute6),
          attribute7                    =NVL(p_req_line.attribute7,attribute7),
          attribute8                    =NVL(p_req_line.attribute8,attribute8),
          attribute9                    =NVL(p_req_line.attribute9,attribute9),
          attribute10                   =NVL(p_req_line.attribute10,attribute10),
          attribute11                   =NVL(p_req_line.attribute11,attribute11),
          attribute12                   =NVL(p_req_line.attribute12,attribute12),
          attribute13                   =NVL(p_req_line.attribute13,attribute13),
          attribute14                   =NVL(p_req_line.attribute14,attribute14),
          attribute15                   =NVL(p_req_line.attribute15,attribute15),
          rfq_required_flag             =NVL(p_req_line.rfq_required_flag, rfq_required_flag),
          reference_num                 =NVL(p_req_line.reference_num, reference_num)
    WHERE requisition_header_id = p_req_line.requisition_header_id
          AND requisition_line_id =  p_req_line.requisition_line_id;

   d_progress := 60;
   l_progress := 'After Update';
   IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
   END IF;

    --Update Distributions

    IF p_req_line.rebuild_accounts ='Y' THEN
      PO_REQUISITION_VALIDATE_PVT.rebuild_accounts(p_req_line, l_accounts_tbl,
                               l_return_status ,
                               p_init_msg      ,
                               l_error_msg   );
      FORALL i IN 1..l_accounts_tbl.COUNT
        UPDATE po_req_distributions
        SET code_combination_id = NVL(l_accounts_tbl(i).ccid,code_combination_id)
        , budget_account_id = NVL(l_accounts_tbl(i).budget_account_id,budget_account_id),
        variance_account_id = NVL(l_accounts_tbl(i).variance_account_id,variance_account_id),
        accrual_account_id = NVL(l_accounts_tbl(i).accrual_account_id,accrual_account_id)
        WHERE distribution_id = l_accounts_tbl(i).distribution_id
        AND requisition_line_id = l_accounts_tbl(i).req_line_id;
    END IF;

    IF p_commit = 'Y' THEN
      COMMIT;
    END IF;

    IF p_submit_approval = 'Y' THEN
      BEGIN
        d_progress := 80;
        SELECT preparer_id, authorization_status, note_to_authorizer
        INTO l_preparer_id, l_authorization_status, l_note_to_authorizer
        FROM po_requisition_headers prh
        WHERE prh.requisition_header_id = p_req_line.requisition_header_id;

        IF l_authorization_status = 'INCOMPLETE' THEN
          submit_for_approval(p_req_line.requisition_header_id,
                                l_preparer_id,
                                NULL,
                                 l_note_to_authorizer,
                                 x_return_status,
                                 x_error_msg);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          x_return_status :='E';
          po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
          RAISE;
      END;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_return_status :='E';
       x_error_msg := ' Unxpected error occured '||SQLERRM;
       po_message_s.sql_error('update_requisition_line',d_progress,SQLCODE);
       RAISE;
END update_requisition_line;


PROCEDURE update_requisition_line ( p_req_line_tbl IN OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_init_msg      IN     VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2 ,
                               p_req_line_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               p_req_line_err_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_line_tbl,
                               p_submit_approval IN VARCHAR2, p_commit IN VARCHAR2)
IS
  l_return_status VARCHAR2(20);
  l_error_msg VARCHAR2(1000);
  l_progress VARCHAR2(1000);
  l_err_count NUMBER := 1;
  l_success_count NUMBER:= 1;

  l_module_name CONSTANT VARCHAR2(100) := 'update_requisition_line';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;
  l_authorization_status VARCHAR2(50);
  l_note_to_authorizer    PO_REQUISITION_HEADERS_ALL.note_to_authorizer%TYPE;
  l_preparer_id           PO_REQUISITION_HEADERS_ALL.preparer_id%TYPE;
  x_online_report_id    NUMBER;
  l_accounts_tbl PO_REQUISITION_UPDATE_PVT.accounts_tbl;
  l_quantity NUMBER;
  l_distQuantity_tbl PO_REQUISITION_UPDATE_PVT.dist_quantity_tbl;


BEGIN

  x_return_status := 'S';
  d_progress := 10;
  --dbms_output.put_line('p_req_line_tbl.COUNT'||p_req_line_tbl.COUNT);
  FOR i IN 1..p_req_line_tbl.COUNT
  LOOP
  BEGIN
      l_return_status := NULL;
      l_error_msg := NULL;

    PO_REQUISITION_VALIDATE_PVT.val_requisition_line (p_req_line_tbl(i),
                                 l_accounts_tbl,
                                 l_return_status ,
                                 p_init_msg      ,
                                 l_error_msg   );
    --dbms_output.put_line('x_return_status1'||x_return_status);

    d_progress := 20;
    IF PO_LOG.d_stmt THEN
          PO_LOG.stmt(d_module_base,d_progress,'p_req_line_tbl(i).requisition_line_id: ',p_req_line_tbl(i).requisition_line_id);
          PO_LOG.stmt(d_module_base,d_progress,'l_return_status',l_return_status);
          PO_LOG.stmt(d_module_base,d_progress,'l_error_msg',l_error_msg);
    END IF;
    d_progress := 30;
    IF l_return_status = 'E' THEN
        x_return_status := 'E';
         p_req_line_err_tbl(l_err_count) :=  p_req_line_tbl(i);
         p_req_line_err_tbl(l_err_count).error_message := l_error_msg;
         l_err_count :=  l_err_count+1;
    ELSE
      SELECT authorization_status
      INTO l_authorization_status
      FROM po_requisition_headers
      WHERE requisition_header_id = p_req_line_tbl(i).requisition_header_id;

      IF l_authorization_status = 'APPROVED' THEN
        BEGIN
         d_progress := 40;
         por_util_pkg.withdraw_req(p_req_line_tbl(i).requisition_header_id);
         p_req_line_tbl_out(l_success_count) :=  p_req_line_tbl(i);
         l_success_count := l_success_count+1;
        EXCEPTION
          WHEN OTHERS THEN
          p_req_line_err_tbl(l_err_count) :=  p_req_line_tbl(i);
          l_err_count :=  l_err_count+1;
          x_return_status :='E';
          x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
          po_message_s.sql_error('update_requisition_header_tbl',d_progress,SQLCODE);
        END;
      ELSE
        p_req_line_tbl_out(l_success_count) :=  p_req_line_tbl(i);
        l_success_count := l_success_count+1;
      END IF; -- l_authorization_status = 'APPROVED'
    END IF;-- l_return_status = 'E'
   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.add_exc_msg(d_module_base,'update_requisition_line',NVL(l_error_msg,x_error_msg));
   END;
  END LOOP;
  --dbms_output.put_line('x_return_status2'||x_return_status);
  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'p_req_line_tbl_out.count',p_req_line_tbl_out.COUNT);
        PO_LOG.stmt(d_module_base,d_progress,'No of Error records',p_req_line_err_tbl.COUNT);
  END IF;

  --update distribution quantity
  FOR i IN 1..p_req_line_tbl_out.COUNT
  LOOP
  IF(p_req_line_tbl_out(i).quantity IS NOT NULL AND p_req_line_tbl_out(i).action_flag ='UPDATE') THEN
        SELECT quantity
        INTO l_quantity
        FROM po_requisition_lines_all
        WHERE requisition_header_id = p_req_line_tbl_out(i).requisition_header_id
          AND requisition_line_id = p_req_line_tbl_out(i).requisition_line_id;

        recalculate_dist_quantity(p_req_line_tbl_out(i), l_quantity, l_distQuantity_tbl,
                               l_return_status ,
                               p_init_msg      ,
                               l_error_msg   );

        FORALL k IN 1..l_distQuantity_tbl.COUNT
        UPDATE po_req_distributions
        SET req_line_quantity = NVL(l_distQuantity_tbl(k).req_line_quantity, req_line_quantity)
        WHERE distribution_id = l_distQuantity_tbl(k).distribution_id
        AND requisition_line_id = l_distQuantity_tbl(k).req_line_id;
      END IF;
  END LOOP;
  --dbms_output.put_line('x_return_status3'||x_return_status);
  --update distribution quantity
  FORALL i IN 1..p_req_line_tbl_out.COUNT
    UPDATE po_requisition_lines_all
    SET
          last_update_date                  =     SYSDATE,
          last_updated_by                   =     fnd_global.user_id,
          last_update_login                 =     fnd_global.login_id,
          line_type_id                  =NVL(p_req_line_tbl_out(i).line_type_id, line_type_id),
          item_description              =NVL(p_req_line_tbl_out(i).item_description, item_description),
          unit_meas_lookup_code         =NVL(p_req_line_tbl_out(i).unit_meas_lookup_code, unit_meas_lookup_code),
          unit_price                    =NVL(p_req_line_tbl_out(i).unit_price, unit_price),
          base_unit_price               =NVL(p_req_line_tbl_out(i).base_unit_price, base_unit_price),
          quantity                      =NVL(p_req_line_tbl_out(i).quantity, quantity),
          amount                        =NVL(p_req_line_tbl_out(i).amount, amount),
          source_type_code              =NVL(p_req_line_tbl_out(i).source_type_code, source_type_code),
          suggested_buyer_id            =NVL(p_req_line_tbl_out(i).Suggested_Buyer_Id, Suggested_Buyer_Id),
          document_type_code            =NVL(p_req_line_tbl_out(i).Document_Type_Code, Document_Type_Code),
          blanket_po_header_id          =NVL(p_req_line_tbl_out(i).Blanket_Po_Header_Id, Blanket_Po_Header_Id),
          blanket_po_line_num           =NVL(p_req_line_tbl_out(i).Blanket_Po_Line_Num, Blanket_Po_Line_Num),
          currency_code                 =NVL(p_req_line_tbl_out(i).Currency_Code, Currency_Code),
          rate_type                     =NVL(p_req_line_tbl_out(i).Rate_Type, Rate_Type),
          rate_date                     =NVL(p_req_line_tbl_out(i).Rate_Date, Rate_Date),
          rate                          =NVL(p_req_line_tbl_out(i).Rate, Rate),
          currency_unit_price           =NVL(p_req_line_tbl_out(i).Currency_Unit_Price, Currency_Unit_Price),
          currency_amount               =NVL(p_req_line_tbl_out(i).Currency_Amount, Currency_Amount),
          un_number_id                  =NVL(p_req_line_tbl_out(i).Un_Number_Id, Un_Number_Id),
          hazard_class_id               =NVL(p_req_line_tbl_out(i).Hazard_Class_Id, Hazard_Class_Id),
          source_organization_id        =NVL(p_req_line_tbl_out(i).Source_Organization_Id, Source_Organization_Id),
          source_subinventory           =NVL(p_req_line_tbl_out(i).Source_Subinventory, Source_Subinventory),
          destination_type_code         =NVL(p_req_line_tbl_out(i).Destination_Type_Code, Destination_Type_Code),
          destination_organization_id   =NVL(p_req_line_tbl_out(i).Destination_Organization_Id, destination_organization_id),
          destination_subinventory      =NVL(p_req_line_tbl_out(i).Destination_Subinventory, destination_subinventory),
          oke_contract_header_id        =NVL(p_req_line_tbl_out(i).oke_contract_header_id,oke_contract_header_id),
          secondary_quantity            =NVL(p_req_line_tbl_out(i).Secondary_Quantity, Secondary_Quantity),
          vendor_id                     =NVL(p_req_line_tbl_out(i).Vendor_Id, Vendor_Id),
          vendor_site_id                =NVL(p_req_line_tbl_out(i).Vendor_Site_Id,Vendor_Site_Id),
          vendor_contact_id             =NVL(p_req_line_tbl_out(i).Vendor_Contact_Id, vendor_contact_id),
          research_agent_id             =NVL(p_req_line_tbl_out(i).Research_Agent_Id,research_agent_id),
          on_line_flag                  =NVL(p_req_line_tbl_out(i).On_Line_Flag, On_Line_Flag),
          preferred_grade               =NVL(p_req_line_tbl_out(i).preferred_grade, preferred_grade),
          secondary_unit_of_measure     =NVL(p_req_line_tbl_out(i).secondary_uom_code, SECONDARY_UNIT_OF_MEASURE),
          TRANSACTION_REASON_CODE       =NVL(p_req_line_tbl_out(i).TRANSACTION_REASON_CODE, TRANSACTION_REASON_CODE),
          suggested_vendor_name         =NVL(p_req_line_tbl_out(i).Suggested_Vendor_Name, Suggested_Vendor_Name),
          suggested_vendor_location     =NVL(p_req_line_tbl_out(i).Suggested_Vendor_Location, Suggested_Vendor_Location),
          suggested_vendor_phone        =NVL(p_req_line_tbl_out(i).Suggested_Vendor_Phone, Suggested_Vendor_Phone),
          order_type_lookup_code        =NVL(p_req_line_tbl_out(i).order_type_lookup_code, order_type_lookup_code),
          justification                 =NVL(p_req_line_tbl_out(i).justification, justification),
          note_to_agent                 =NVL(p_req_line_tbl_out(i).note_to_agent, note_to_agent),
          note_to_receiver              =NVL(p_req_line_tbl_out(i).note_to_receiver, note_to_receiver),
          suggested_vendor_product_code =NVL(p_req_line_tbl_out(i).suggested_vendor_product_code, suggested_vendor_product_code),
          need_by_date                  =NVL(p_req_line_tbl_out(i).need_by_date, need_by_date),
          urgent_flag                   =NVL(p_req_line_tbl_out(i).urgent_flag, urgent_flag),
          deliver_to_location_id        =NVL(p_req_line_tbl_out(i).deliver_to_location_id, deliver_to_location_id),
          attribute1                    =NVL(p_req_line_tbl_out(i).attribute1, attribute1),
          attribute2                    =NVL(p_req_line_tbl_out(i).attribute2, attribute2),
          attribute3                    =NVL(p_req_line_tbl_out(i).attribute3, attribute3),
          attribute4                    =NVL(p_req_line_tbl_out(i).attribute4, attribute4),
          attribute5                    =NVL(p_req_line_tbl_out(i).attribute5, attribute5),
          attribute6                    =NVL(p_req_line_tbl_out(i).attribute6, attribute6),
          attribute7                    =NVL(p_req_line_tbl_out(i).attribute7, attribute7),
          attribute8                    =NVL(p_req_line_tbl_out(i).attribute8, attribute8),
          attribute9                    =NVL(p_req_line_tbl_out(i).attribute9, attribute9),
          attribute10                   =NVL(p_req_line_tbl_out(i).attribute10, attribute10),
          attribute11                   =NVL(p_req_line_tbl_out(i).attribute11, attribute11),
          attribute12                   =NVL(p_req_line_tbl_out(i).attribute12, attribute12),
          attribute13                   =NVL(p_req_line_tbl_out(i).attribute13, attribute13),
          attribute14                   =NVL(p_req_line_tbl_out(i).attribute14, attribute14),
          attribute15                   =NVL(p_req_line_tbl_out(i).attribute15, attribute15),
          rfq_required_flag             =NVL(p_req_line_tbl_out(i).rfq_required_flag, rfq_required_flag),
          reference_num                 =NVL(p_req_line_tbl_out(i).reference_num, reference_num)
    WHERE requisition_header_id = p_req_line_tbl_out(i).requisition_header_id
          AND requisition_line_id =  p_req_line_tbl_out(i).requisition_line_id
          ;
  --dbms_output.put_line('x_return_status5'||x_return_status);
      FORALL j IN 1..l_accounts_tbl.COUNT
        UPDATE po_req_distributions
        SET code_combination_id = NVL(l_accounts_tbl(j).ccid,code_combination_id)
        , budget_account_id = NVL(l_accounts_tbl(j).budget_account_id,budget_account_id),
        variance_account_id = NVL(l_accounts_tbl(j).variance_account_id,variance_account_id),
        accrual_account_id = NVL(l_accounts_tbl(j).accrual_account_id,accrual_account_id)
        WHERE distribution_id = l_accounts_tbl(j).distribution_id
        AND requisition_line_id = l_accounts_tbl(j).req_line_id;
  --dbms_output.put_line('x_return_status6'||x_return_status);
     FORALL i IN 1..p_req_line_tbl_out.COUNT
     INSERT INTO po_requisition_lines_all
           (REQUISITION_LINE_ID,
           REQUISITION_HEADER_ID,
           LINE_NUM,
           LINE_TYPE_ID,
           CATEGORY_ID,
           item_id,
	         item_revision,
           ITEM_DESCRIPTION,
	         unit_meas_lookup_code,
	         unit_price,
	         base_unit_price,
	         quantity,
           DELIVER_TO_LOCATION_ID,
           TO_PERSON_ID,
           LAST_UPDATE_DATE,
           creation_date,
	         created_by,
           LAST_UPDATED_BY,
           SOURCE_TYPE_CODE,
	         last_update_login,
           ORDER_TYPE_LOOKUP_CODE,
           purchase_basis,
           matching_basis,
           org_id,
	         suggested_buyer_id,
	         encumbered_flag,
	         rfq_required_flag,
	         quantity_delivered,
	         need_by_date,
	         justification,
	         note_to_agent,
	         note_to_receiver,
	         blanket_po_header_id,
	         blanket_po_line_num,
	         suggested_vendor_name,
	         suggested_vendor_location,
	         suggested_vendor_contact,
	         suggested_vendor_phone,
	         suggested_vendor_product_code,
	         un_number_id,
	         hazard_class_id,
	         reference_num,
	         on_rfq_flag,
	         urgent_flag,
	         cancel_flag,
	         source_organization_id,
	         source_subinventory,
	         destination_type_code,
	         destination_organization_id,
	         destination_subinventory,
	         quantity_cancelled,
	         destination_context,
	         attribute1,
	         attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
	         attribute7,
	         attribute8,
	         attribute9,
	         attribute10,
	         attribute11,
	         attribute12,
	         attribute13,
	         attribute14,
	         attribute15,
	         currency_code,
	         currency_unit_price,
	         document_type_code,
	         rate,
	         rate_date,
	         rate_type,
	         transaction_reason_code,
	         oke_contract_header_id,
	         secondary_unit_of_measure,
	         secondary_quantity,
	         preferred_grade,
	         amount,
	         currency_amount,
	         negotiated_by_preparer_flag,
	         vendor_id,
	         vendor_site_id,
	         vendor_contact_id,
	         manufacturer_part_number,
	         manufacturer_name,
	         manufacturer_id)
         SELECT
         po_requisition_lines_s.NEXTVAL,
         p_req_line_tbl_out(i).requisition_header_id,
         p_req_line_tbl_out(i).requisition_line_num,
         p_req_line_tbl_out(i).line_type_id,
         p_req_line_tbl_out(i).category_id,
         p_req_line_tbl_out(i).item_id,
	       p_req_line_tbl_out(i).item_revision,
         p_req_line_tbl_out(i).item_description,
	       p_req_line_tbl_out(i).unit_meas_lookup_code,
	       p_req_line_tbl_out(i).unit_price,
	       p_req_line_tbl_out(i).base_unit_price,
	       p_req_line_tbl_out(i).quantity,
         p_req_line_tbl_out(i).deliver_to_location_id,
         p_req_line_tbl_out(i).to_person_id,
         SYSDATE,
         SYSDATE,
	       fnd_global.user_id,
         fnd_global.user_id,
         p_req_line_tbl_out(i).source_type_code,
	       fnd_global.login_id,
         plt.order_type_lookup_code,
         plt.purchase_basis,
         plt.matching_basis,
         p_req_line_tbl_out(i).org_id,
	       p_req_line_tbl_out(i).suggested_buyer_id,
	       'N',
	       p_req_line_tbl_out(i).rfq_required_flag,
	       0,
	       p_req_line_tbl_out(i).need_by_date,
	       p_req_line_tbl_out(i).justification,
	       p_req_line_tbl_out(i).note_to_agent,
	       p_req_line_tbl_out(i).note_to_receiver,
	       p_req_line_tbl_out(i).blanket_po_header_id,
	       p_req_line_tbl_out(i).blanket_po_line_num,
	       p_req_line_tbl_out(i).suggested_vendor_name,
	       p_req_line_tbl_out(i).suggested_vendor_location,
	       p_req_line_tbl_out(i).suggested_vendor_contact,
	       p_req_line_tbl_out(i).suggested_vendor_phone,
	       RTRIM(p_req_line_tbl_out(i).suggested_vendor_product_code),
	       p_req_line_tbl_out(i).un_number_id,
	       p_req_line_tbl_out(i).hazard_class_id,
	       p_req_line_tbl_out(i).reference_num,
	       'N',
	       p_req_line_tbl_out(i).urgent_flag,
       	 'N',
	       DECODE(p_req_line_tbl_out(i).source_type_code,'INVENTORY',
	       p_req_line_tbl_out(i).source_organization_id,''),
         p_req_line_tbl_out(i).source_subinventory,
	       p_req_line_tbl_out(i).destination_type_code,
	       p_req_line_tbl_out(i).destination_organization_id,
	       p_req_line_tbl_out(i).destination_subinventory,
	       0,
         p_req_line_tbl_out(i).destination_type_code,
	       p_req_line_tbl_out(i).attribute1,
	       p_req_line_tbl_out(i).attribute2,
	       p_req_line_tbl_out(i).attribute3,
	       p_req_line_tbl_out(i).attribute4,
	       p_req_line_tbl_out(i).attribute5,
	       p_req_line_tbl_out(i).attribute6,
	       p_req_line_tbl_out(i).attribute7,
	       p_req_line_tbl_out(i).attribute8,
	       p_req_line_tbl_out(i).attribute9,
	       p_req_line_tbl_out(i).attribute10,
	       p_req_line_tbl_out(i).attribute11,
	       p_req_line_tbl_out(i).attribute12,
	       p_req_line_tbl_out(i).attribute13,
	       p_req_line_tbl_out(i).attribute14,
	       p_req_line_tbl_out(i).attribute15,
      	 p_req_line_tbl_out(i).currency_code,
	       p_req_line_tbl_out(i).currency_unit_price,
	       p_req_line_tbl_out(i).document_type_code,
	       p_req_line_tbl_out(i).rate,
	       p_req_line_tbl_out(i).rate_date,
	       p_req_line_tbl_out(i).rate_type,
      	 p_req_line_tbl_out(i).transaction_reason_code,
	       p_req_line_tbl_out(i).oke_contract_header_id,
	       p_req_line_tbl_out(i).secondary_uom_code,
	       p_req_line_tbl_out(i).secondary_quantity,
	       p_req_line_tbl_out(i).preferred_grade,
	       p_req_line_tbl_out(i).amount,
	       p_req_line_tbl_out(i).currency_amount,
	       p_req_line_tbl_out(i).negotiated_by_preparer_flag,
	       p_req_line_tbl_out(i).vendor_id,
	       p_req_line_tbl_out(i).vendor_site_id,
	       p_req_line_tbl_out(i).vendor_contact_id,
	       p_req_line_tbl_out(i).manufacturer_part_number,
	       p_req_line_tbl_out(i).manufacturer_name,
	       p_req_line_tbl_out(i).manufacturer_id
         FROM po_line_types plt
         WHERE plt.line_type_id = p_req_line_tbl_out(i).line_type_id
         AND p_req_line_tbl_out(i).action_flag ='NEW';


     IF  p_req_line_tbl_out.COUNT = 0 THEN
       RETURN;
     END IF;

     IF NOT PO_SUPPLY.create_req(p_req_line_tbl_out(1).requisition_header_id,'REQ HDR') THEN
          x_return_status := 'E';
          x_error_msg := 'Error in Supply Req';
     END IF;
     --dbms_output.put_line('x_return_status8'||x_return_status);

      IF p_commit = 'Y' THEN
        COMMIT;
      END IF;

      IF p_submit_approval = 'Y' THEN
       FOR i IN 1..p_Req_line_tbl_out.COUNT
       LOOP
        BEGIN
          l_error_msg := NULL;
          l_return_status := NULL;
          d_progress := 80;
          SELECT preparer_id, authorization_status, note_to_authorizer
          INTO l_preparer_id, l_authorization_status, l_note_to_authorizer
          FROM po_requisition_headers prh
          WHERE prh.requisition_header_id = p_req_line_tbl_out(i).requisition_header_id;

          IF l_authorization_status = 'INCOMPLETE' THEN
            submit_for_approval(p_req_line_tbl_out(i).requisition_header_id,
                                  l_preparer_id,
                                  NULL,
                                   l_note_to_authorizer,
                                   l_return_status,
                                   l_error_msg);

            IF l_return_status ='E' THEN
              p_req_line_err_tbl(l_err_count) := p_req_line_tbl_out(i);
              p_req_line_err_tbl(l_err_count).error_message := l_error_msg;
              x_return_status := 'E';
              x_error_msg := l_error_msg;
              l_err_count := l_err_count+1;
            END IF;
          END IF;
     --dbms_output.put_line('x_return_status9'||x_return_status);
        EXCEPTION
          WHEN OTHERS THEN
            x_return_status :='E';
            po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
        END;
      END LOOP;
      END IF;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status :='E';
    x_error_msg := ' Unxpected error occured '||SQLERRM;
       RAISE;
END update_requisition_line;


PROCEDURE update_req_distribution (p_req_dist_rec IN  OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                p_submit_approval IN VARCHAR2, p_commit IN VARCHAR2)  IS
 l_module_name CONSTANT VARCHAR2(100) := 'update_req_distribution';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
 l_error_msg VARCHAR2(1000);
 l_return_status VARCHAR2(5);
 x_status VARCHAR2(10);
 l_authorization_status VARCHAR2(40);
 l_preparer_id NUMBER;
 l_dist_rec po_req_distributions%ROWTYPE;
 l_award_set_id po_req_distributions.award_id%TYPE;
BEGIN
   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_init_msg', p_init_msg);
  END IF;
  x_return_status := 'S';
  d_progress := 10;

  PO_REQUISITION_VALIDATE_PVT.validate_req_distribution(p_req_dist_rec ,
                                l_return_status ,
                                p_init_msg ,
                                l_error_msg,
                                x_status );
   IF l_return_status = 'E' THEN
     x_return_status := 'E';
     x_error_msg := l_error_msg;
     po_message_s.sql_error('Validation failure',d_progress,'');
     RETURN;
   ELSE
     SELECT authorization_status
     INTO l_authorization_status
     FROM po_requisition_headers
     WHERE requisition_header_id = p_req_dist_rec.req_header_id;
     d_progress := 40;
     IF l_authorization_status = 'APPROVED' THEN
      BEGIN
       por_util_pkg.withdraw_req(p_req_dist_rec.req_header_id);
      EXCEPTION
        WHEN OTHERS THEN
        x_return_status :='E';
        x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
        po_message_s.sql_error('update_requisition_header',d_progress,SQLCODE);
        RAISE;
      END;
     END IF;
     d_progress := 50;

     UPDATE PO_REQ_DISTRIBUTIONS_all
          SET
          last_update_date                  =     SYSDATE,
          last_updated_by                   =     fnd_global.user_id,
          requisition_line_id               =     p_req_dist_rec.req_line_id,
          last_update_login                 =     fnd_global.login_id,
          attribute_category                =     NVL(p_req_dist_rec.Attribute_Category,Attribute_Category),
          attribute1                        =     NVL(p_req_dist_rec.Attribute1,Attribute1),
          attribute2                        =     NVL(p_req_dist_rec.attribute2,attribute2),
          attribute3                        =     NVL(p_req_dist_rec.Attribute3,attribute3),
          attribute4                        =     NVL(p_req_dist_rec.Attribute4,attribute4),
          attribute5                        =     NVL(p_req_dist_rec.Attribute5,attribute5),
          attribute6                        =     NVL(p_req_dist_rec.Attribute6,attribute6),
          attribute7                        =     NVL(p_req_dist_rec.Attribute7,attribute7),
          attribute8                        =     NVL(p_req_dist_rec.Attribute8,attribute8),
          attribute9                        =     NVL(p_req_dist_rec.Attribute9,attribute9),
          attribute10                       =     NVL(p_req_dist_rec.Attribute10,attribute10),
          attribute11                       =     NVL(p_req_dist_rec.Attribute11,attribute11),
          attribute12                       =     NVL(p_req_dist_rec.Attribute12,attribute12),
          attribute13                       =     NVL(p_req_dist_rec.Attribute13,attribute13),
          attribute14                       =     NVL(p_req_dist_rec.Attribute14,attribute14),
          attribute15                       =     NVL(p_req_dist_rec.Attribute15,attribute15),
          project_id                        =     NVL(p_req_dist_rec.project_Id,project_id),
          task_id                           =     NVL(p_req_dist_rec.task_Id,task_id),
          expenditure_type                  =     NVL(p_req_dist_rec.expenditure_Type,expenditure_Type),
          oke_contract_line_id              =     NVL(p_req_dist_rec.oke_contract_line_id,oke_contract_line_id),
          oke_contract_deliverable_id       =     NVL(p_req_dist_rec.oke_contract_deliverable_id,oke_contract_deliverable_id),
      --    project_accounting_context        =     p_req_dist_rec.project_Accounting_Context,
          expenditure_organization_id       =     NVL(p_req_dist_rec.expenditure_Organization_Id,expenditure_Organization_Id),
          expenditure_item_date             =     NVL(p_req_dist_rec.expenditure_Item_Date,expenditure_Item_Date),
       --   end_item_unit_number              =     p_req_dist_rec.end_Item_Unit_Number,
          req_award_id                	 	=     decode(p_req_dist_rec.award_id,NULL,req_award_id,-999999,NULL,p_req_dist_rec.award_id),
          code_combination_id     = NVL(p_req_dist_rec.code_combination_id,code_combination_id),
          accrual_account_id     = NVL(p_req_dist_rec.accrual_account_id,accrual_account_id),
          variance_account_id    = NVL(p_req_dist_rec.variance_account_id,variance_account_id),
          budget_account_id   = NVL(p_req_dist_rec.budget_account_id,budget_account_id),
          gl_encumbered_date = NVL(p_req_dist_rec.gl_encumbered_date,gl_encumbered_date)
    WHERE distribution_id = p_req_dist_rec.distribution_id
    AND  requisition_line_id = p_req_dist_rec.req_line_id;

	SELECT *
	INTO l_dist_rec
	FROM PO_REQ_DISTRIBUTIONS_all
	WHERE distribution_id = p_req_dist_rec.distribution_id
    AND  requisition_line_id = p_req_dist_rec.req_line_id;

	-- For both Update and Insert action, calling GMS api is necessary
	-- Not handle case which needs to the delete record in GMS table.
	IF l_dist_rec.req_award_id IS NOT NULL-- AND l_dist_rec.req_award_id <> -999999
		THEN
		BEGIN
		GMS_POR_API.when_update_line(l_dist_rec.distribution_id,
									 l_dist_rec.project_id,
									 l_dist_rec.task_id,
									 l_dist_rec.req_award_id,
									 l_dist_rec.expenditure_type,
									 l_dist_rec.expenditure_item_date,
									 l_award_set_id,
									 x_status);

		UPDATE PO_REQ_DISTRIBUTIONS_all
		SET award_id = l_award_set_id
		WHERE distribution_id = l_dist_rec.distribution_id
		AND  requisition_line_id = l_dist_rec.requisition_line_id;

		EXCEPTION
        WHEN OTHERS THEN
			IF x_status <> 'S' THEN
			  x_error_msg := 'Unexcepted error occurred when calling GMS API.';
			  po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
			  RAISE;
			ELSE
			  x_status := 'E';
			  x_error_msg := 'Unexcepted error occurred when updating award_set_id';
			  po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
			  RAISE;
			END IF;
		END;

	END IF;


   END IF;

  IF p_commit = 'Y' THEN
      COMMIT;
  END IF;

   IF p_submit_approval = 'Y' THEN
       BEGIN
          d_progress := 80;
          SELECT preparer_id, authorization_status
          INTO l_preparer_id, l_authorization_status
          FROM po_requisition_headers prh
          WHERE prh.requisition_header_id = p_req_dist_rec.req_header_id;

          IF l_authorization_status = 'INCOMPLETE' THEN
            submit_for_approval(p_req_dist_rec.req_header_id,
                                  l_preparer_id,
                                  NULL,
                                   p_req_dist_rec.note_to_approver,
                                   x_return_status,
                                   x_error_msg);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            x_return_status :='E';
            po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
            RAISE;
        END;

   END IF;
    --Perform table update
       -- Do Update
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
 EXCEPTION
 WHEN OTHERS THEN
      x_return_status :='E';
       x_error_msg := 'Unxpected error occured '||SQLERRM ;
--       po_message_s.sql_error('update_req_distribution',d_progress,sqlcode);
       RAISE;
END;



PROCEDURE update_req_distribution (p_req_dist_tbl IN  OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_init_msg IN VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                p_req_dist_tbl_out OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                               p_req_dist_err_tbl OUT NOCOPY  PO_REQUISITION_UPDATE_PUB.req_dist_tbl,
                               p_submit_approval IN VARCHAR2, p_commit IN VARCHAR2)
IS
 l_module_name CONSTANT VARCHAR2(100) := 'update_req_distribution_tbl';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
 l_error_msg VARCHAR2(1000);
 l_return_status VARCHAR2(5);
 l_err_count NUMBER := 1;
 l_success_count NUMBER:= 1;
 x_status VARCHAR2(10);
 l_dist_rec po_req_distributions%ROWTYPE;
 l_authorization_status VARCHAR2(40);
 l_preparer_id NUMBER;
 l_award_set_id po_req_distributions.award_id%TYPE;
BEGIN
   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_init_msg', p_init_msg);
  END IF;
  x_return_status := 'S';
  d_progress := 10;

  FOR i IN 1..p_req_dist_tbl.COUNT
  LOOP
    l_error_msg := NULL;
    l_return_status := NULL;
    x_status := NULL;
      PO_REQUISITION_VALIDATE_PVT.validate_req_distribution(p_req_dist_tbl(i) ,
                                    l_return_status ,
                                    p_init_msg ,
                                    l_error_msg ,
                                    x_status );
       IF l_return_status = 'E' THEN
          p_req_dist_err_tbl(l_err_count) := p_req_dist_tbl(i);
          p_req_dist_err_tbl(l_err_count).error_message := l_error_msg;
          l_err_count := l_err_count+1;
          x_return_status := 'E';

       ELSE
          SELECT authorization_status,preparer_id
          INTO l_authorization_status,l_preparer_id
          FROM po_requisition_headers
          WHERE requisition_header_id = p_req_dist_tbl(i).req_header_id;

        p_req_dist_tbl(i).authorization_status := l_authorization_status;
        p_req_dist_tbl(i).preparer_id := l_preparer_id;

      IF l_authorization_status = 'APPROVED' THEN
        BEGIN
         d_progress := 40;
         por_util_pkg.withdraw_req(p_req_dist_tbl(i).req_header_id);
         p_req_dist_tbl_out(l_success_count) :=  p_req_dist_tbl(i);
         l_success_count := l_success_count+1;
        EXCEPTION
          WHEN OTHERS THEN
          p_req_dist_err_tbl(l_err_count) :=  p_req_dist_tbl(i);
          l_err_count :=  l_err_count+1;
          x_return_status :='E';
          x_error_msg := ' Unxpected error occured when withdrwaing requisition '||SQLERRM;
          po_message_s.sql_error('update_requisition_dist_tbl',d_progress,SQLCODE);
        END;
      ELSE
          p_req_dist_tbl_out(l_success_count) := p_req_dist_tbl(i);
          l_success_count := l_success_count+1;
      END IF; -- l_authorization_status = 'APPROVED'
    END IF;-- l_return_status = 'E'



    END LOOP;

   --dbms_output.put_line('Before qty val '||x_return_status);
   -- calc dist quantity/amount and validate it
   recal_dist_quantity_amount(p_req_dist_tbl_out);

   --val_dist_quantity_amount(p_req_dist_tbl_out,x_return_status);

    --dbms_output.put_line('after qty val '||x_return_status);

    FOR i IN 1..p_req_dist_tbl_out.COUNT
	LOOP
	 -- update req_award_id, not award_id
     -- decode for req_award_id in case if update it as null using -999999
     UPDATE PO_REQ_DISTRIBUTIONS_all prd
          SET
          last_update_date                  =     SYSDATE,
          last_updated_by                   =     fnd_global.user_id,
          requisition_line_id               =     p_req_dist_tbl_out(i).req_line_id,
          last_update_login                 =     fnd_global.login_id,
          req_line_quantity                 =     NVL(p_req_dist_tbl_out(i).req_line_quantity,req_line_quantity),
          req_line_amount                   =     NVL(p_req_dist_tbl_out(i).req_line_amount,req_line_amount) ,
          req_line_currency_amount          =     NVL(p_req_dist_tbl_out(i).currency_amount,req_line_currency_amount) ,
          attribute_category                =     NVL(p_req_dist_tbl_out(i).Attribute_Category,Attribute_Category),
          attribute1                        =     NVL(p_req_dist_tbl_out(i).Attribute1,Attribute1),
          attribute2                        =     NVL(p_req_dist_tbl_out(i).attribute2,attribute2),
          attribute3                        =     NVL(p_req_dist_tbl_out(i).Attribute3,attribute3),
          attribute4                        =     NVL(p_req_dist_tbl_out(i).Attribute4,attribute4),
          attribute5                        =     NVL(p_req_dist_tbl_out(i).Attribute5,attribute5),
          attribute6                        =     NVL(p_req_dist_tbl_out(i).Attribute6,attribute6),
          attribute7                        =     NVL(p_req_dist_tbl_out(i).Attribute7,attribute7),
          attribute8                        =     NVL(p_req_dist_tbl_out(i).Attribute8,attribute8),
          attribute9                        =     NVL(p_req_dist_tbl_out(i).Attribute9,attribute9),
          attribute10                       =     NVL(p_req_dist_tbl_out(i).Attribute10,attribute10),
          attribute11                       =     NVL(p_req_dist_tbl_out(i).Attribute11,attribute11),
          attribute12                       =     NVL(p_req_dist_tbl_out(i).Attribute12,attribute12),
          attribute13                       =     NVL(p_req_dist_tbl_out(i).Attribute13,attribute13),
          attribute14                       =     NVL(p_req_dist_tbl_out(i).Attribute14,attribute14),
          attribute15                       =     NVL(p_req_dist_tbl_out(i).Attribute15,attribute15),
          project_id                        =     NVL(p_req_dist_tbl_out(i).project_Id,project_id),
          task_id                           =     NVL(p_req_dist_tbl_out(i).task_Id,task_id),
          expenditure_type                  =     NVL(p_req_dist_tbl_out(i).expenditure_Type,expenditure_Type),
      --    project_accounting_context        =     p_req_dist_tbl_out(i).project_Accounting_Context,
          expenditure_organization_id       =     NVL(p_req_dist_tbl_out(i).expenditure_Organization_Id,expenditure_Organization_Id),
          expenditure_item_date             =     NVL(p_req_dist_tbl_out(i).expenditure_Item_Date,expenditure_Item_Date),
       --   end_item_unit_number              =     p_req_dist_tbl_out(i).end_Item_Unit_Number,
          req_award_id                 =      decode(p_req_dist_tbl_out(i).award_id,NULL,req_award_id,-999999,NULL,p_req_dist_tbl_out(i).award_id),
          code_combination_id     = NVL(p_req_dist_tbl_out(i).code_combination_id,code_combination_id),
          accrual_account_id     = NVL(p_req_dist_tbl_out(i).accrual_account_id,accrual_account_id),
          variance_account_id    = NVL(p_req_dist_tbl_out(i).variance_account_id,variance_account_id),
          budget_account_id   = NVL(p_req_dist_tbl_out(i).budget_account_id,budget_account_id),
          gl_encumbered_date = NVL(p_req_dist_tbl_out(i).gl_encumbered_date,gl_encumbered_date)
    WHERE distribution_id = p_req_dist_tbl_out(i).distribution_id
    AND  requisition_line_id = p_req_dist_tbl_out(i).req_line_id
    AND p_req_dist_tbl_out(i).action_flag = 'UPDATE'
    AND NOT EXISTS (SELECT 1 FROM po_interface_errors pie,
                    po_requisition_lines prl
                    WHERE pie.interface_line_id = prl.line_num
                    AND prl.requisition_line_id = prd.requisition_line_id
                    AND prl.requisition_header_id = pie.interface_transaction_id);
                    --AND interface_distribution_id = prd.distribution_id);

   -- need to delete line data for which dist is in error
  /*
   FORALL i IN 1..p_req_dist_tbl_out.COUNT
   DELETE FROM po_requisition_lines prl
   WHERE prl.requisition_line_id = p_req_dist_tbl_out(i).req_line_id
   AND p_req_dist_tbl_out(i).action_flag = 'NEW'
   AND EXISTS (select 1 from po_interface_errors
                    where interface_line_id = p_req_dist_tbl_out(i).req_line_id
                    AND interface_distribution_id = p_req_dist_tbl_out(i).distribution_id);

   FORALL i IN 1..p_req_dist_tbl_out.COUNT
   DELETE FROM mtl_supply prl
   WHERE prl.req_line_id = p_req_dist_tbl_out(i).req_line_id
   AND p_req_dist_tbl_out(i).action_flag = 'NEW'
   AND EXISTS (select 1 from po_interface_errors
                    where interface_line_id = p_req_dist_tbl_out(i).req_line_id
                    AND interface_distribution_id = p_req_dist_tbl_out(i).distribution_id);
   */
   --dbms_output.put_line('Before dist insert status'||x_return_status);
    --Insert stmt

    INSERT INTO PO_REQ_DISTRIBUTIONS_ALL
       (DISTRIBUTION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        REQUISITION_LINE_ID,
        SET_OF_BOOKS_ID,
        CODE_COMBINATION_ID,
	      req_line_quantity,
	      last_update_login,
	      creation_date,
	      created_by,
	      encumbered_flag,
	      gl_encumbered_date,
	      gl_encumbered_period_name,
	      attribute_category,
	      attribute1,
	      attribute2,
	      attribute3,
	      attribute4,
	      attribute5,
	      attribute6,
	      attribute7,
	      attribute8,
	      attribute9,
	      attribute10,
	      attribute11,
	      attribute12,
	      attribute13,
	      attribute14,
	      attribute15,
	      accrual_account_id,
	      budget_account_id,
	      variance_account_id,
	      government_context,
	      prevent_encumbrance_flag,
        distribution_num,
	      project_id,
	      task_id,
	      req_award_id,
	      expenditure_type,
	      expenditure_organization_id,
	      project_accounting_context,
	      expenditure_item_date,
	      allocation_type,
	      allocation_value,
	      oke_contract_line_id,
	      oke_contract_deliverable_id,
	      req_line_amount,
	      req_line_currency_amount,
        ORG_ID)
    SELECT po_req_distributions_s.NEXTVAL,
        SYSDATE,
        fnd_global.user_id,
        p_req_dist_tbl_out(i).req_line_id,
        fsp.set_of_books_id,
        p_req_dist_tbl_out(i).code_combination_id,
	      p_req_dist_tbl_out(i).req_line_quantity,
        fnd_global.login_id,
	      SYSDATE,
	      fnd_global.user_id,
	      'N',
	      TRUNC(p_req_dist_tbl_out(i).gl_encumbered_date),
	      p_req_dist_tbl_out(i).gl_encumbered_period_name,
	      p_req_dist_tbl_out(i).attribute_category,
	      p_req_dist_tbl_out(i).attribute1,
	      p_req_dist_tbl_out(i).attribute2,
	      p_req_dist_tbl_out(i).attribute3,
	      p_req_dist_tbl_out(i).attribute4,
	      p_req_dist_tbl_out(i).attribute5,
	      p_req_dist_tbl_out(i).attribute6,
	      p_req_dist_tbl_out(i).attribute7,
	      p_req_dist_tbl_out(i).attribute8,
	      p_req_dist_tbl_out(i).attribute9,
	      p_req_dist_tbl_out(i).attribute10,
	      p_req_dist_tbl_out(i).attribute11,
	      p_req_dist_tbl_out(i).attribute12,
	      p_req_dist_tbl_out(i).attribute13,
	      p_req_dist_tbl_out(i).attribute14,
	      p_req_dist_tbl_out(i).attribute15,
	      NVL(p_req_dist_tbl_out(i).accrual_account_id,p_req_dist_tbl_out(i).code_combination_id),
	      p_req_dist_tbl_out(i).budget_account_id,
	      NVL(p_req_dist_tbl_out(i).variance_account_id,p_req_dist_tbl_out(i).code_combination_id),
	      p_req_dist_tbl_out(i).government_context,
	      'N',
        p_req_dist_tbl_out(i).distribution_num,
	      p_req_dist_tbl_out(i).project_id,
	      p_req_dist_tbl_out(i).task_id,
	      p_req_dist_tbl_out(i).award_id,
	      p_req_dist_tbl_out(i).expenditure_type,
	      p_req_dist_tbl_out(i).expenditure_organization_id,
	      p_req_dist_tbl_out(i).project_accounting_context,
	      p_req_dist_tbl_out(i).expenditure_item_date,
	      DECODE(p_req_dist_tbl_out(i).allocation_value,NULL,NULL,'PERCENT'),
	      p_req_dist_tbl_out(i).allocation_value,
	      p_req_dist_tbl_out(i).oke_contract_line_id,
	      p_req_dist_tbl_out(i).oke_contract_deliverable_id,
	      p_req_dist_tbl_out(i).req_line_amount,
	      p_req_dist_tbl_out(i).currency_amount,
	      p_req_dist_tbl_out(i).org_id
    FROM  financials_system_parameters fsp
    WHERE p_req_dist_tbl_out(i).action_flag = 'NEW'
    AND NOT EXISTS (SELECT 1 FROM po_interface_errors pie,
                    po_requisition_lines prl
                    WHERE pie.interface_line_id = prl.line_num
                    AND prl.requisition_line_id = p_req_dist_tbl_out(i).req_line_id
                    AND prl.requisition_header_id = pie.interface_transaction_id
                    );

	SELECT *
	INTO l_dist_rec
	FROM PO_REQ_DISTRIBUTIONS_all
	WHERE distribution_id = p_req_dist_tbl_out(i).distribution_id
    AND  requisition_line_id = p_req_dist_tbl_out(i).req_line_id;

    -- For both Update and Insert action, calling GMS api is necessary
	-- Not handle case which needs to the delete record in GMS table.
	IF l_dist_rec.req_award_id IS NOT NULL-- AND l_dist_rec.req_award_id <> -999999
		THEN
		BEGIN
		GMS_POR_API.when_update_line(l_dist_rec.distribution_id,
									 l_dist_rec.project_id,
									 l_dist_rec.task_id,
									 l_dist_rec.req_award_id,
									 l_dist_rec.expenditure_type,
									 l_dist_rec.expenditure_item_date,
									 l_award_set_id,
									 x_status);

		UPDATE PO_REQ_DISTRIBUTIONS_all
		SET award_id = l_award_set_id
		WHERE distribution_id = l_dist_rec.distribution_id
		AND  requisition_line_id = l_dist_rec.requisition_line_id;

		EXCEPTION
        WHEN OTHERS THEN
			IF x_status <> 'S' THEN
			  x_error_msg := 'Unexcepted error occurred when calling GMS API.';
			  po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
			  RAISE;
			ELSE
			  x_status := 'E';
			  x_error_msg := 'Unexcepted error occurred when updating award_set_id';
			  po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
			  RAISE;
			END IF;
		END;

	END IF;


	END LOOP;

    IF p_commit = 'Y' THEN
      COMMIT;
    END IF;
    --dbms_output.put_line('after dist insert status'||x_return_status);
   /*
    IF p_submit_approval = 'Y' THEN
        FOR i IN 1..p_req_dist_tbl_out.COUNT
        LOOP

          IF p_req_dist_tbl_out(i).authorization_status = 'INCOMPLETE' THEN
            l_return_status := NULL;
            l_error_msg := NULL;
            submit_for_approval(p_req_dist_tbl_out(i).req_header_id,
                                  p_req_dist_tbl_out(i).preparer_id,
                                  NULL,
                                  p_req_dist_tbl_out(i).note_to_approver,
                                  l_return_status,
                                  l_error_msg);
            IF l_return_status ='E' THEN
              x_return_status := 'E';
              p_req_dist_err_tbl(l_err_count) := p_req_dist_tbl_out(i);
              p_req_dist_err_tbl(l_err_count).error_message := l_error_msg;
              l_err_count := l_err_count+1;
            END IF;
          END IF;

        END LOOP;
    END IF;
  */
  IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'p_req_dist_tbl_out.count',p_req_dist_tbl_out.COUNT);
        PO_LOG.stmt(d_module_base,d_progress,'No of Error records',p_req_dist_err_tbl.COUNT);
  END IF;
    --Perform table update
       -- Do Update
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
 EXCEPTION
 WHEN OTHERS THEN
      x_return_status :='E';
       x_error_msg := 'Unxpected error occured '||SQLERRM ;
--       po_message_s.sql_error('update_req_distribution',d_progress,sqlcode);
       RAISE;

END;


FUNCTION does_approval_list_exist(p_req_hdr_id NUMBER
                                  ) RETURN BOOLEAN

IS
 x_item_key PO_REQUISITION_HEADERS_ALL.WF_ITEM_KEY%TYPE;
 x_item_type po_requisition_headers_all.wf_item_type%TYPE;
 l_module_name CONSTANT VARCHAR2(100) := 'does_approval_list_exist';
 d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
 d_progress NUMBER;
 x_list_exist BOOLEAN;
 x_num NUMBER;
 x_error_msg VARCHAR2(1000);

BEGIN
  d_progress := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_req_hdr_id', p_req_hdr_id);
  END IF;

  SELECT wf_item_key,
         wf_item_type
  INTO x_item_key,
       x_item_type
  FROM   po_requisition_headers_all
  WHERE  requisition_header_id = p_req_hdr_id    ;

  d_progress := 20;
  IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'wf_item_key',x_item_key);
      PO_LOG.stmt(d_module_base,d_progress,'wf_item_type',x_item_type);
  END IF;

  IF x_item_key IS NULL OR x_item_type IS NULL THEN
    x_list_exist:= FALSE;
  ELSE
     d_progress := 30;

     SELECT
     COUNT(*)
    INTO
      x_num
    FROM
      PO_APPROVAL_LIST_HEADERS
    WHERE
      document_id = p_req_hdr_id AND
      wf_item_key = x_item_key AND
      wf_item_type = x_item_type;


   END IF;

     d_progress := 40;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;
   IF x_num > 0 THEN
     x_list_exist:= TRUE;
   ELSE
     x_list_exist:= FALSE;
   END IF;

   RETURN x_list_exist;

EXCEPTION
 WHEN OTHERS THEN
      x_error_msg := ' Unxpected error occured '||SQLERRM;
      po_message_s.sql_error('submit_for_approval',d_progress,SQLCODE);
   --   return false;
END;

END;

/

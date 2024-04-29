--------------------------------------------------------
--  DDL for Package Body PO_REQUISITION_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQUISITION_UPDATE_PUB" AS
/* $Header: POXRQUPB.pls 120.0.12010000.10 2014/07/10 08:42:20 uchennam noship $ */

/*===========================================================================
  FILE NAME    :         POXRQUPBS.pls
  PACKAGE NAME:         PO_REQUISITION_UPDATE_PUB

  DESCRIPTION:
   PO_REQUISITION_UPDATE_PUB API performs update operations on Requisition
   header,line and distribution. It allows updation on requisition that is
   in Incomplete status or Approved without attached PO.

 PROCEDURES:
     update_requisition_header --Update Requisition Header
     update_requisition_line  -- Update Requisition LIne
     update_req_distribution  -- Update Requisition Distribution
     update_requisition       --Update Wole requisition at a time

==============================================================================*/
PROCEDURE update_requisition_header ( p_req_hdr IN OUT NOCOPY  req_hdr,
                                      p_init_msg      IN     VARCHAR2,
                                      p_submit_approval IN VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_error_msg OUT NOCOPY  VARCHAR2,
                                       p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN
   PO_REQUISITION_UPDATE_PVT.update_requisition_header ( p_req_hdr ,
                               x_return_status,
                               p_init_msg  ,
                               x_error_msg ,
                               p_submit_approval,
                                p_commit );
EXCEPTION
 WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;

PROCEDURE update_requisition_line ( p_req_line IN OUT NOCOPY  req_line_rec_type,
                                   p_init_msg      IN     VARCHAR2,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                 p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN
  PO_REQUISITION_UPDATE_PVT.update_requisition_line ( p_req_line ,
                               x_return_status ,
                               p_init_msg      ,
                               x_error_msg,
                               p_submit_approval,
                                p_commit );
EXCEPTION
 WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;

PROCEDURE update_requisition_line ( p_req_line_tbl IN OUT NOCOPY  req_line_tbl,
                               p_init_msg      IN     VARCHAR2,
                               p_req_line_tbl_out OUT NOCOPY  req_line_tbl,
                               p_req_line_err_tbl OUT NOCOPY  req_line_tbl,
                               p_submit_approval IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                 p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN
  PO_REQUISITION_UPDATE_PVT.update_requisition_line ( p_req_line_tbl ,
                               x_return_status ,
                               p_init_msg      ,
                               x_error_msg  ,
                               p_req_line_tbl_out ,
                               p_req_line_err_tbl,
                               p_submit_approval,
                                p_commit );
EXCEPTION
 WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;


PROCEDURE update_req_distribution (p_req_dist_rec IN  OUT NOCOPY  req_dist,
                                p_init_msg IN VARCHAR2,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                 p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN
  PO_REQUISITION_UPDATE_PVT.update_req_distribution (p_req_dist_rec ,
                                x_return_status ,
                                p_init_msg ,
                                x_error_msg ,
                                p_submit_approval,
                                 p_commit );
EXCEPTION
 WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;

PROCEDURE update_req_distribution (p_req_dist_tbl IN  OUT NOCOPY  req_dist_tbl,
                                p_init_msg IN VARCHAR2,
                                p_req_dist_tbl_out OUT NOCOPY  req_dist_tbl,
                                p_req_dist_err_tbl OUT NOCOPY  req_dist_tbl,
                                p_submit_approval IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY  VARCHAR2,
                                 p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN

  PO_REQUISITION_UPDATE_PVT.update_req_distribution (p_req_dist_tbl ,
                                x_return_status,
                                p_init_msg ,
                                x_error_msg ,
                                p_req_dist_tbl_out ,
                               p_req_dist_err_tbl,
                               p_submit_approval,
                                p_commit );
EXCEPTION
WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;

PROCEDURE update_requisition_header ( p_req_hdr_tbl IN OUT NOCOPY  req_hdr_tbl,
                               p_init_msg      IN     VARCHAR2,
                               p_req_hdr_tbl_out OUT NOCOPY  req_hdr_tbl,
                               p_req_hdr_err_tbl OUT NOCOPY  req_hdr_tbl,
                               p_submit_approval IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_error_msg OUT NOCOPY  VARCHAR2,
                                p_commit IN VARCHAR2)
IS
l_error_msg VARCHAR2(10);
d_progress NUMBER;
BEGIN
  PO_REQUISITION_UPDATE_PVT.update_requisition_header ( p_req_hdr_tbl ,
                               x_return_status ,
                               p_init_msg      ,
                               x_error_msg ,
                               p_req_hdr_tbl_out ,
                               p_req_hdr_err_tbl,
                               p_submit_approval,
                                p_commit );
EXCEPTION
WHEN OTHERS THEN
       po_message_s.sql_error('update_req_distribution',d_progress,SQLCODE);
       RAISE;
END;

PROCEDURE update_requisition( p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
                              p_commit                     IN   VARCHAR2     ,
                              x_return_status              OUT  NOCOPY  /* file.sql.39 change */ VARCHAR2,
                              x_msg_count                  OUT  NOCOPY /* file.sql.39 change */  NUMBER,
                              x_msg_data                   OUT  NOCOPY /* file.sql.39 change */  VARCHAR2,
                              p_submit_approval            IN VARCHAR2,
                              p_req_hdr                    IN req_hdr,
                              p_req_line_tbl               IN req_line_tbl,
                              p_req_dist_tbl               IN req_dist_tbl
                               )
IS

l_req_hdr  po_requisition_update_pub.req_hdr;
l_req_line_tbl  po_requisition_update_pub.req_line_tbl;
l_req_line_tbl_out  po_requisition_update_pub.req_line_tbl;
l_req_line_tbl_err  po_requisition_update_pub.req_line_tbl;

l_req_dist_tbl  po_requisition_update_pub.req_dist_tbl;
l_req_dist_tbl_out  po_requisition_update_pub.req_dist_tbl;
l_req_dist_tbl_err  po_requisition_update_pub.req_dist_tbl;

l_error_msg VARCHAR2(5000);
l_return_status VARCHAR2(10);
l_preparer_id NUMBER;
l_err_cnt NUMBER := 0;
l_org_id NUMBER;
BEGIN
   l_req_hdr := p_req_hdr;
   l_req_line_tbl := p_req_line_tbl;
   l_req_dist_tbl := p_req_dist_tbl;


     -- Check if req exists
     BEGIN
       SELECT requisition_header_id
       , org_id
       INTO l_req_hdr.requisition_header_id
         ,l_org_id
       FROM po_requisition_headers_all
       WHERE (requisition_header_id = l_req_hdr.requisition_header_id
              OR (segment1 = l_req_hdr.segment1 AND org_id = nvl(l_req_hdr.org_id,org_id)))
       FOR UPDATE       ;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
           x_msg_data := ' Invalid Requisition..Please enter a valid requisition Id/Number';
		   x_return_status := 'E';
		   RETURN;
      WHEN TOO_MANY_ROWS THEN
          x_msg_data := 'Multiple Requisitions exists..Please provide Org ID Value';
          x_return_status := 'E';
     WHEN OTHERS THEN
           x_msg_data := ' Unxpected error occured '||SQLERRM;
           po_message_s.sql_error('val_requisition_hdr','10',SQLCODE);
		   		   x_return_status := 'E';
		   RETURN;
     END;

 l_req_hdr.org_id := l_org_id ;
     mo_global.set_policy_context('S',l_req_hdr.org_id);

      SAVEPOINT REQ_UPDATE_SP;
     po_requisition_update_pvt.update_requisition_header ( l_req_hdr ,
                               l_return_status,
                               p_init_msg_list  ,
                               l_error_msg ,
                               'N',
                                'N');

   DBMS_OUTPUT.PUT_LINE('After header call status'||l_return_status||x_msg_data);
  IF l_return_status = 'E' THEN
    x_return_status := l_return_status;
    x_msg_data := l_error_msg;
    x_msg_count := fnd_msg_pub.count_msg;
    RETURN;
  END IF;

  IF l_req_line_tbl.COUNT>0 THEN
  FOR i IN 1..l_req_line_tbl.COUNT
  LOOP

     l_req_line_tbl(i).requisition_header_id := l_req_hdr.requisition_header_id;
     l_req_line_tbl(i).org_id := l_req_hdr.org_id;
  END LOOP;
  l_return_status := NULL;
  PO_REQUISITION_UPDATE_PVT.update_requisition_line ( l_req_line_tbl ,
                               l_return_status ,
                               p_init_msg_list      ,
                               l_error_msg  ,
                               l_req_line_tbl_out ,
                               l_req_line_tbl_err,
                               'N',
                               'N');
  DBMS_OUTPUT.PUT_LINE('After line update status'||l_return_status);
  IF l_return_status = 'E' THEN
     x_msg_data := 'Number of Requisition Lines in Error: '||l_req_line_tbl_err.COUNT;

     po_message_s.concat_fnd_messages_in_stack(1,l_error_msg);
     x_msg_data :=  x_msg_data||' '||l_error_msg;
     x_msg_count := fnd_msg_pub.count_msg;
     ROLLBACK TO REQ_UPDATE_SP;
     x_return_status := 'E';
     RETURN;
  END IF;
 END IF;
  l_return_status := NULL;
  l_error_msg := NULL;

  IF p_req_dist_tbl.COUNT > 0 THEN
    FOR i IN 1..l_req_dist_tbl.COUNT
  LOOP

     l_req_dist_tbl(i).req_header_id := l_req_hdr.requisition_header_id;
     l_req_dist_tbl(i).org_id := l_req_hdr.org_id;
  END LOOP;
   PO_REQUISITION_UPDATE_PVT.update_req_distribution (l_req_dist_tbl ,
                                l_return_status,
                                p_init_msg_list ,
                                l_error_msg ,
                                l_req_dist_tbl_out ,
                                l_req_dist_tbl_err,
                                'N',
                                'N');
   --dbms_OUTPUT.PUT_LINE('After line update status'||l_error_msg);
   IF l_return_status = 'E' THEN
    SELECT COUNT(*)
    INTO l_err_cnt
    FROM po_interface_errors
    WHERE interface_type = 'REQ_UPDATE'
    AND table_name = 'PO_REQ_DISTRIBUTIONS'
    AND column_name IN ('AMOUNT','QUANTITY');
     l_err_cnt := l_err_cnt + l_req_dist_tbl_err.COUNT;
     x_msg_data := 'Number of Requisition Distributions in Error: '||l_err_cnt;
     po_message_s.concat_fnd_messages_in_stack(1,l_error_msg);
     x_msg_data := x_msg_data||' '||l_error_msg;
     x_msg_count := fnd_msg_pub.count_msg;
     ROLLBACK TO REQ_UPDATE_SP;
     x_return_status := 'E';
     --x_msg_data := l_error_msg;
     RETURN;
  END IF;
 END IF;

 IF p_commit = 'Y' THEN
   COMMIT;
 END IF;
x_return_status := 'S';

po_requisition_validate_pvt.document_submission_check(
                      l_req_hdr,
		      x_return_status,
		      x_msg_data);

IF nvl(x_return_status,'S') <> 'E' THEN
    x_return_status := 'S';
END IF;

  IF p_submit_approval = 'Y' AND x_return_status <> 'E' THEN
       SELECT preparer_id
       INTO l_preparer_id
       FROM po_requisition_headers
       WHERE requisition_header_id = l_req_hdr.requisition_header_id;

       po_requisition_update_pvt.submit_for_approval(l_req_hdr.requisition_header_id,
                             l_preparer_id,
                             NULL,
                             l_req_hdr.note_to_approver,
                             x_return_status,
                             x_msg_data);

  END IF;
  IF nvl(x_return_status,'S') <> 'E' THEN
    x_return_status := 'S';
  END IF;
END;

END;

/

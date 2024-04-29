--------------------------------------------------------
--  DDL for Package Body AHL_OPERATIONS_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OPERATIONS_APPROVAL_PVT" AS
/* $Header: AHLVOWKB.pls 120.1 2005/09/29 04:26:44 tamdas noship $ */

G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

PROCEDURE GET_FULLNAME
(
p_username         IN  VARCHAR2,
x_fullname         OUT NOCOPY VARCHAR2
)
AS
CURSOR CurGetName IS
SELECT full_name FROM AHL_JTF_RS_EMP_V WHERE  USER_NAME=p_username;
begin
        OPEN  CurGetName;
        FETCH CurGetName INTO x_fullname;

        IF CurGetName%notfound
        THEN
                x_fullname:=p_username;
        END IF;
        CLOSE CurGetName;
END;

PROCEDURE Set_Activity_Details(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
        ,resultout   OUT NOCOPY      VARCHAR2)
IS

  l_object_id             NUMBER;
  l_object                VARCHAR2(30)    := 'OPER';
  l_approval_type         VARCHAR2(30)    := 'CONCEPT';
  l_object_details        ahl_generic_aprv_pvt.ObjRecTyp;
  l_approval_rule_id      NUMBER;
  l_approver_seq          NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_subject               VARCHAR2(500);
  l_subject_rej           VARCHAR2(500);
  l_subject_apr           VARCHAR2(500);
  l_subject_aprvd         VARCHAR2(500);
  l_subject_req           VARCHAR2(500);
  l_subject_err           VARCHAR2(500);
  l_error_msg             VARCHAR2(2000);
  l_OPERATION_ID          NUMBER:=0;
  l_check_flag            VARCHAR2(1):='N';

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;


BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Set_Activity_Details Route','+DebugWfOper+');
	END IF;
  fnd_msg_pub.initialize;

  l_return_status :=fnd_api.g_ret_sts_success;

  l_object_id := wf_engine.getitemattrnumber(
                      itemtype => itemtype
                     ,itemkey  => itemkey
                     ,aname    => 'OBJECT_ID'
                   );

  l_object_details.operating_unit_id:=NULL;

  l_object_details.priority:=NULL;

  IF (funcmode = 'RUN') THEN
       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%FOUND
       THEN
               l_check_flag:='Y';

               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_subject := fnd_message.get;

               fnd_message.set_name('AHL','AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_subject_apr:= fnd_message.get;

               fnd_message.set_name('AHL', 'AHL_RM_OPER_AFT_APPR_REJTS_SUB');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_subject_rej:= fnd_message.get;

               fnd_message.set_name('AHL', 'AHL_RM_OPER_AFT_APPR_APRVS_SUB');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_subject_aprvd:= fnd_message.get;

               fnd_message.set_name('AHL', 'AHL_RM_OPER_ERROR_SUB');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_subject_err:= fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_subject_err:= fnd_message.get;
               l_subject_err:= l_subject_err||to_char(l_object_id);
       END IF;
       CLOSE GetOperationDet;

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'FORWARD_SUBJECT',
                 avalue   => l_subject_apr);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'APPROVAL_SUBJECT',
                 avalue   => l_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'REJECT_SUBJECT',
                 avalue   => l_subject_rej);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'APPROVED_SUBJECT',
                 avalue   => l_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'FINAL_SUBJECT',
                 avalue   => l_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'REMIND_SUBJECT',
                 avalue   => l_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype,
                 itemkey  => itemkey,
                 aname    => 'ERROR_SUBJECT',
                 avalue   => l_subject_err);

-----------------------------------------------------------------------------------
-- Get Approval Rule and First Approver Sequence
-----------------------------------------------------------------------------------

     ahl_generic_aprv_pvt.get_approval_details(
        p_object             => l_object,
        p_approval_type      => l_approval_type,
        p_object_details     => l_object_details,
        x_approval_rule_id   => l_approval_rule_id,
        x_approver_seq       => l_approver_seq,
        x_return_status      => l_return_status
     );

     IF l_return_status = fnd_api.g_ret_sts_success THEN

        wf_engine.setitemattrnumber(
           itemtype => itemtype,
           itemkey  => itemkey,
           aname    => 'RULE_ID',
           avalue   => l_approval_rule_id
        );

        wf_engine.setitemattrnumber(
           itemtype => itemtype,
           itemkey  => itemkey,
           aname    => 'APPROVER_SEQ',
           avalue   => l_approver_seq
        );

       resultout := 'COMPLETE:SUCCESS';

      RETURN;

     ELSE
        RAISE fnd_api.G_EXC_ERROR;
     END IF;
  END IF;

  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;


  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

EXCEPTION
WHEN fnd_api.G_EXC_ERROR THEN

        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );

        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_ROUTE_APROVAL_PVT','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);

     resultout := 'COMPLETE:ERROR';

  WHEN OTHERS THEN
      wf_core.context(
           'AHL_OPERATIONS_APPROVAL_PVT'
          ,'Set_Activity_Details'
          ,itemtype
          ,itemkey
          ,actid
          ,'Unexpected Error!'
        );
     RAISE;

END Set_Activity_Details;



PROCEDURE Ntf_Forward_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_body                VARCHAR2(3500);
l_object_id           NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);
l_apr_fulname         VARCHAR2(100);
l_req_fulname         VARCHAR2(100);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
  l_fullname                 VARCHAR2(100);

BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Ntf_Forward_FYI','+DebugWfOper+');
	END IF;

  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type,
                        itemkey  => l_item_key,
                        aname    => 'OBJECT_TYPE');

  l_object_id := wf_engine.getitemattrNumber(
                     itemtype => l_item_type,
                     itemkey  => l_item_key,
                     aname    => 'OBJECT_ID');

  l_approver := wf_engine.getitemattrtext(
                    itemtype => l_item_type,
                    itemkey  => l_item_key,
                    aname    => 'APPROVER');


        GET_FULLNAME
        (
        p_username =>l_approver,
        x_fullname =>l_fullname
        );


       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_CONTENT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               fnd_message.set_token('NAME',l_fullname, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

--  if nvl(l_fname,l_approver);

  l_body :=l_body||'.'||'Your request has been forwarded to ' ||l_fullname||' for approval' ;

  document := document || l_body;
  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','ntf_forward_fyi',
                      l_item_type,l_item_key,l_error_msg);
     RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Forward_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Forward_FYI;

PROCEDURE Ntf_Approved_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_body                VARCHAR2(3500);
l_object_id      NUMBER;

l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
  l_fullname                  VARCHAR2(100);

BEGIN

  	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Ntf_Approved_FYI ROUTE ','+DebugWfOper+');
	END IF;


  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;

        GET_FULLNAME
        (
        p_username =>l_approver,
        x_fullname =>l_fullname
        );


  l_body :='Your request has been approved by ' ||l_fullname ;

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Approved_FYI',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approved_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Approved_FYI;

PROCEDURE Ntf_Final_Approval_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_body                VARCHAR2(3500);
l_object_id      NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
BEGIN

  	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start NtfyFinalApproval','+DebugWfOper+');
	END IF;

  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );


/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;


  l_body :=l_body||'.'|| 'Your request has been approved by all approvers.';

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Final_Approval_FYI',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Final_Approval_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Final_Approval_FYI;


PROCEDURE Ntf_Rejected_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approver            VARCHAR2(30);
l_body                VARCHAR2(3500);
l_object_id      NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);
l_fullname              VARCHAR2(100);
  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
BEGIN

  	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'NtfRejectedFyi','+DebugWfOper+');
	END IF;

  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;

        GET_FULLNAME
        (
        p_username =>l_approver,
        x_fullname =>l_fullname
        );


  l_body := 'Your request has been rejected by ' ||l_fullname ;

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Rejected_FYI',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;

   WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Rejected_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Rejected_FYI;


PROCEDURE Ntf_Approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_requester           VARCHAR2(30);
l_requester_note      VARCHAR2(4000);
l_body                VARCHAR2(5000);
l_object_id           NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);
  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
  l_fullname                 VARCHAR2(100);
BEGIN

  	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Notify Approval','+DebugWfOper+');
	END IF;

  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );

  l_requester := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER'
                );

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

                     commit;
/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%FOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       END IF;
       CLOSE GetOperationDet;

        GET_FULLNAME
        (
        p_username =>l_requester,
        x_fullname =>l_fullname
        );


  l_body := 'You just received a request from '||l_requester;
  l_body := l_requester_note;

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Approval',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approval'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Approval;


PROCEDURE Ntf_Approval_Reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS
l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_requester           VARCHAR2(30);
l_requester_note      VARCHAR2(4000);
l_body                VARCHAR2(5000);
l_object_id           NUMBER;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);
l_fullname            VARCHAR2(100);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;
  l_operation_rec            GetOperationDet%rowtype;
BEGIN

  	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start NtfAprRemainder','+DebugWfOper+');
	END IF;

  document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );

  l_requester := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER'
                );

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );


/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;

        GET_FULLNAME
        (
        p_username =>l_requester,
        x_fullname =>l_fullname
        );


  l_body :=l_body||'.'|| 'Reminder: You just received a request from '||l_fullname;
  l_body := l_body ||'. The note from him/her is as following: '||l_requester_note;

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Approval_Reminder',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approval_Reminder'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Approval_Reminder;




PROCEDURE Ntf_Error_Act(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_body                VARCHAR2(3500);
l_object_id           NUMBER;
l_error_msg           VARCHAR2(4000);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start NtfErrorAct','+DebugWfOper+');
	END IF;


  document_type := 'text/plain';

  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_object := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'OBJECT_TYPE'
                     );

  l_object_id := wf_engine.getitemattrNumber(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'OBJECT_ID'
                );

  l_error_msg := wf_engine.getitemattrText(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'ERROR_MSG'
                );

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

       OPEN  GetOperationDet(l_object_id);
       FETCH GetOperationDet into l_operation_rec;

       IF GetOperationDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
       ELSE
               fnd_message.set_name('AHL', 'AHL_RM_OPERNTF_FORWARD_SUBJECT');
               fnd_message.set_token('SEGMENT',l_operation_rec.SEGMENT, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetOperationDet;



  l_body :=l_body||'.'|| 'An error occured in the approval process of your request.'||fnd_global.local_chr(10);
  l_body := l_body || 'Please choose to cancel or re-submit your request.'||fnd_global.local_chr(10);
  l_body := l_body || 'Error Message'||l_error_msg;

  document := document || l_body;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type   ,
           p_itemkey           => l_item_key    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','Ntf_Error_Act',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHL_OPERATIONS_APPROVAL_PVT'
                    , 'Ntf_Error_Act'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Error_Act;

PROCEDURE Update_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2)
IS
l_error_msg                VARCHAR2(4000);
l_next_status              VARCHAR2(30);
l_approval_status          VARCHAR2(30);
l_object_version_number    NUMBER;
l_object_id                NUMBER;
l_status_date              DATE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
-- Variables for executing Complete_mr_Revision
 l_api_name     CONSTANT VARCHAR2(30) := 'Update_Status';

 l_commit                VARCHAR2(1):=FND_API.G_TRUE;
 l_OPERATION_ID          number:=0;
 l_comp_OPERATION_ID          number:=0;
 l_api_version           NUMBER:=1.0;
 l_init_msg_list         VARCHAR2(1):= FND_API.G_TRUE;
 l_validate_only         VARCHAR2(1):= FND_API.G_TRUE;
 l_validation_level      NUMBER:= FND_API.G_VALID_LEVEL_FULL;
 l_module_type           VARCHAR2(1);
 x_return_status         VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 x_msg_count             NUMBER;
 x_msg_data              VARCHAR2(2000);
 l_default               VARCHAR2(1):= FND_API.G_FALSE;
 l_status                VARCHAR2(30);
 l_body              VARCHAR2(2000);
 l_approver_note         VARCHAR2(2000);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;


  l_operation_rec            GetOperationDet%rowtype;
BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start UpdateStatus','+DebugWfOper+');
	END IF;

  IF funcmode = 'RUN' THEN
     l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'UPDATE_GEN_STATUS'
                        );
       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Update Status After Getitemattrtext','+DebugWfOper+');
	END IF;

     IF l_approval_status = 'APPROVED' THEN
        l_next_status := wf_engine.getitemattrText(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'NEW_STATUS_ID'
                            );

     ELSE
        l_next_status := wf_engine.getitemattrText(
                               itemtype => itemtype
                              ,itemkey => itemkey
                              ,aname => 'REJECT_STATUS_ID'
                            );
     END IF;

     l_object_version_number := wf_engine.getitemattrnumber(
                                   itemtype => itemtype
                                  ,itemkey => itemkey
                                  ,aname => 'OBJECT_VER'
                                );
     l_object_id := wf_engine.getitemattrnumber(
                     itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'OBJECT_ID'
                   );

     l_status_date := SYSDATE;

     l_approver_note := wf_engine.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER NOTE' );

     OPEN GetOperationDet(l_object_id);
     FETCH GetOperationDet INTO l_operation_rec;
     IF GetOperationDet%notfound
     then
               fnd_message.set_name('AHL', 'AHL_RM_INVALID_OPERATION');
               l_body := fnd_message.get;
               l_body:=l_body||'-'||to_char(l_operation_rec.OPERATION_ID);
     end if;

     CLOSE GetOperationDet;
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'Before CompleteOperRev'||l_approval_status,'+DebugWfOper+');
	END IF;

        AHL_RM_APPROVAL_PVT.COMPLETE_OPER_REVISION
         (
         p_api_version               =>l_api_version,
         p_init_msg_list             =>l_init_msg_list,
         p_commit                    =>l_commit,
         p_validation_level          =>l_validation_level ,
         p_default                   =>l_default ,
         p_module_type               =>'JSP',
         x_return_status             =>l_return_status,
         x_msg_count                 =>x_msg_count ,
         x_msg_data                  =>x_msg_data  ,
         p_appr_status               =>l_approval_status,
         p_operation_id              =>l_object_id,
         p_object_version_number     =>l_object_version_number,
         p_approver_note             =>l_approver_note
         );
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'After CompleteOperRev'||l_approval_status,'+DebugWfOper+');
	END IF;

         COMMIT;
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;


EXCEPTION
  WHEN fnd_api.g_exc_error THEN
     	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'GExec Error:'||sqlerrm,'+DebugWfOper+');
	END IF;
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_RM_APPROVAL_PVT','UPDATE_STATUS',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
     RAISE;

  WHEN OTHERS THEN
   	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug( 'When others Error:'||sqlerrm,'+DebugwfOper+');
	END IF;

     wf_core.context(
        'AHL_OPERATIONS_APPROVAL_PVT'
       ,'Update_Status'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
     RAISE;

END Update_Status;

PROCEDURE Revert_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2)
IS
l_error_msg                VARCHAR2(4000);
l_next_status              VARCHAR2(30);
l_approval_status          VARCHAR2(30);
l_object_version_number    NUMBER;
l_object_id                NUMBER;
l_status_date              DATE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

  cursor GetOperationDet(c_OPERATION_ID number)
  is
  select OPERATION_ID,CONCATENATED_SEGMENTS SEGMENT
  from ahl_OPERATIONS_b_KFV
  where OPERATION_ID=c_OPERATION_ID;

  l_operation_rec            GetOperationDet%rowtype;
  l_return_status            VARCHAR2(1);

BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Revert Status','+WfforOper+');
	END IF;

  l_return_Status:='S';
  IF funcmode = 'RUN' THEN
     l_next_status := wf_engine.getitemattrText(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'ORG_STATUS_ID'
                            );

     l_object_version_number := wf_engine.getitemattrnumber(
                                   itemtype => itemtype
                                  ,itemkey => itemkey
                                  ,aname => 'OBJECT_VER'
                                );
     l_object_id := wf_engine.getitemattrnumber(
                     itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'OBJECT_ID'
                   );

     l_status_date := SYSDATE;

      UPDATE AHL_OPERATIONS_B
      SET REVISION_STATUS_CODE = 'DRAFT',
            object_version_number =l_object_version_number+1
      WHERE OPERATION_ID = l_object_id
      and   object_Version_number=l_object_version_number;

     COMMIT;
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;


EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_OPERATIONS_APPROVAL_PVT','revert_status',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
     RAISE;
  WHEN OTHERS THEN
     wf_core.context(
        'AHL_OPERATIONS_APPROVAL_PVT'
       ,'REVERT_STATUS'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
     RAISE;

END Revert_Status;
END AHL_OPERATIONS_APPROVAL_PVT;


/

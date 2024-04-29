--------------------------------------------------------
--  DDL for Package Body AHL_FMP_MR_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_MR_APPROVAL_PVT" AS
 /* $Header: AHLVMWKB.pls 120.0.12010000.2 2009/04/27 13:49:30 jkjain ship $ */
--G_DEBUG 		 VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
  G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;


PROCEDURE Set_Activity_Details(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
        ,resultout   OUT NOCOPY      VARCHAR2)
IS

  l_object_id             NUMBER;
  l_object                VARCHAR2(30)    := 'FMPMR';
  l_approval_type         VARCHAR2(30)    := 'CONCEPT';
  l_object_details        ahl_generic_aprv_pvt.ObjRecTyp;
  l_approval_rule_id      NUMBER;
  l_approver_seq          NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_subject               VARCHAR2(500);
  l_error_msg             VARCHAR2(2000);
  l_mr_header_id          NUMBER:=0;
  l_application_usg_code VARCHAR2(30) ;
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  Select mr_header_id,
	 title,
	 effective_from,
	 Version_number,
         mr_status_code
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_rec            GetMrHeaderDet%rowtype;
BEGIN
	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Set Actvity Details');
	END IF;

  	fnd_msg_pub.initialize;
  	l_return_status := fnd_api.g_ret_sts_success;

  	l_object_id := wf_engine.getitemattrnumber(
       	               itemtype => itemtype
       	              ,itemkey  => itemkey
       	              ,aname    => 'OBJECT_ID'
       		       );
  l_application_usg_code := wf_engine.getItemAttrText(
                      itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'APPLICATION_USG_CODE'
                   );
  l_object_details.application_usg_code := l_application_usg_code ;



  l_object_details.operating_unit_id :=NULL;

  l_object_details.priority  :=NULL;

  IF (funcmode = 'RUN') THEN
       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               l_subject := fnd_message.get;
       else
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
               fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
               l_subject := fnd_message.get;
       End if;
       CLOSE GetMrHeaderDet;

       fnd_message.set_name('AHL','AHL_FMP_MR_NTF_FORWARD_SUBJECT');
       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FORWARD_SUBJECT'
                 ,avalue   => l_subject
                         );
       IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
       THEN
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APPRVAL_SUBJECT');
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APPRTRM_SUBJECT');
       END IF;

       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVAL_SUBJECT'
                 ,avalue   => l_subject
                         );
       IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
       THEN
        fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_REJECT_SUBJECT');
       ELSE
        fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_REJECTR_SUBJECT');
       END IF;


       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REJECT_SUBJECT'
                 ,avalue   => l_subject
                         );

       IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
       THEN
        fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APPRVED_SUBJECT');
       ELSE
        fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APRVTRM_SUBJECT');
       END IF;

       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;


       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVED_SUBJECT'
                 ,avalue   => l_subject
                         );
       IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
       THEN
       fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FINAL_SUBJECT');
       else
       fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FINALTR_SUBJECT');
       end if;

       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FINAL_SUBJECT'
                 ,avalue   => l_subject
                         );
       IF L_MR_REC.MR_STATUS_CODE='APPROVAL_PENDING'
       THEN
       fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_REMIND_SUBJECT');
       ELSE
       fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_REMINDT_SUBJECT');
       END IF;

       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REMIND_SUBJECT'
                 ,avalue   => l_subject);
       fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_ERROR_SUBJECT');
       fnd_message.set_token('TITLE',l_mr_rec.TITLE, false);
       fnd_message.set_token('VERSION_NUMBER',l_mr_rec.VERSION_NUMBER);
       l_subject := fnd_message.get;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'ERROR_SUBJECT'
                 ,avalue   => l_subject
                         );

------------------------------------------------------------------------------
-- Get Approval Rule and First Approver Sequence
------------------------------------------------------------------------------
	IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug( 'Set Activity l_approval_RULE_ID-->'||l_approval_rule_id);
	END IF;

     ahl_generic_aprv_pvt.get_approval_details(
        p_object             => l_object,
        p_approval_type      => l_approval_type,
        p_object_details     => l_object_details,
        x_approval_rule_id   => l_approval_rule_id,
        x_approver_seq       => l_approver_seq,
        x_return_status      => l_return_status
     );


	IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug('Get approval details-->'||l_APPROVAL_RULE_ID);
	END IF;

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

  --
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
--
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_FMP_MR_APROVAL_PVT',
                       'Set_Activity_Details',
                       itemtype,
                       itemkey,
                       actid,
                       funcmode,
                       l_error_msg);

     resultout := 'COMPLETE:ERROR';
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;

  WHEN OTHERS THEN
      wf_core.context(
           'AHL_FMP_MR_APPROVAL_PVT'
          ,'Set_Activity_Details'
          ,itemtype
          ,itemkey
          ,actid
          ,'Unexpected Error!'
        );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject             VARCHAR2(500);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);

  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  Select mr_header_id,
	 title,
	 effective_from,
         effective_to,
	 Version_number
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_header_rec            GetMrHeaderDet%rowtype;
BEGIN
	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Notify Forward');
	END IF;

    -- Debug info.
	document_type := 'text/plain';

  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

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

       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
         fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
         fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID);
         l_body := fnd_message.get;
       ELSE
         fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
         fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
         fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.VERSION_NUMBER);
         l_body := fnd_message.get;
         l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

         fnd_message.set_name('AHL', 'AHL_FMP_MRNTF_FORWARD_FYI_BODY');
         fnd_message.set_token('APPROVER',l_approver);
--		 fnd_message.set_token('l_approver',l_mr_header_rec.TITLE, false);
         l_body := l_body||fnd_message.get;
         l_subject:= fnd_message.get||'-'||l_body;
         document := document || l_body;

    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type,
           p_itemkey           => l_item_key,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','NTF_FORWARD_FYI',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Forward_FYI'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject                VARCHAR2(500);
l_object_id      NUMBER;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);

  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,VERSION_NUMBER
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;

  l_mr_header_rec            GetMrHeaderDet%rowtype;

BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Notify Approved FYI');
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
       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
       fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
       fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID);
       l_body := fnd_message.get;
       ELSE
        fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
        fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
        fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.version_number);
        l_body := fnd_message.get;
        l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;

        fnd_message.set_name('AHL', 'AHL_FMP_MRNTF_APPRVED_FYI_BODY');
        fnd_message.set_token('APPROVER',l_approver);
        l_body :=l_body||'.'||fnd_message.get;
        l_subject :=l_body||fnd_message.get;
  document := document || l_body;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;

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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Approved_FYI',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approved_FYI'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject             VARCHAR2(500);
l_object_id           NUMBER;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);

  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,version_number
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;

  l_mr_header_rec            GetMrHeaderDet%rowtype;

BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start NTF Final approval');
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


/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/

       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID,false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
               fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.version_number);
               l_body := fnd_message.get;
               l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;

               fnd_message.set_name('AHL', 'AHL_FMP_MRNTF_FINAL_APPROVAL');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
               fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.version_number);



       l_body :=l_body||'.'|| fnd_message.get;

       document := document || l_body;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;

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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Final_Approval_FYI',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Final_Approval_FYI'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject             VARCHAR2(500);
l_object_id           NUMBER;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,VERSION_NUMBER
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_header_rec            GetMrHeaderDet%rowtype;
BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Notify Rejected');
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

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );
       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID,false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
               fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.VERSION_NUMBER,false);
               l_body := fnd_message.get;
               l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;

               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APPROVAL_REJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE);
               fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.VERSION_NUMBER);
               fnd_message.set_token('APPROVER',l_approver);
               l_body := fnd_message.get;


           l_body := l_body||fnd_message.get;
           l_subject:= l_body||fnd_message.get;

	document := document || l_body;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Rejected_FYI',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;

   WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Rejected_FYI'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_body                VARCHAR2(3500);
l_subject             VARCHAR2(500);
l_object_id           NUMBER;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,version_number
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_header_rec            GetMrHeaderDet%rowtype;
BEGIN

       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Nty_approval');
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

       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE);
		fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.VERSION_NUMBER);
               l_body := fnd_message.get;
               l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_APPROVER');
               fnd_message.set_token('REQUESTER',l_requester);
               fnd_message.set_token('REQUESTER_NOTE',l_requester_note);
               l_body :=l_body||fnd_message.get;
               document := document || l_body;

       IF G_DEBUG='Y' THEN
               AHL_DEBUG_PUB.disable_debug;
       END IF;
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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Approval',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approval'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(2000);
l_subject                VARCHAR2(500);
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,version_number
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_header_rec            GetMrHeaderDet%rowtype;
BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start ntfy Apprvl remainder');
	END IF;
	document_type := 'text/plain';

  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

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

       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID,false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
		fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.version_number);
               l_body := fnd_message.get;
               l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;



--l_body :=l_body||'.'|| 'Reminder: You just received a request from '||l_requester;
--l_body := l_body ||'. The note from him/her is as following: '||l_requester_note;
  document := document || l_body;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;

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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Approval_Reminder',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approval_Reminder'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject                VARCHAR2(500);
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from,VERSION_NUMBER
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;
  l_mr_header_rec            GetMrHeaderDet%rowtype;
BEGIN
       	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Start Ntfy error','+NOTIFY ERROR ACT+');
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

  l_error_msg := wf_engine.getitemattrText(
                   itemtype => l_item_type,
                   itemkey  => l_item_key,
                   aname    => 'ERROR_MSG'
                );


       OPEN  GetMrHeaderDet(l_object_id);
       FETCH GetMrHeaderDet into l_mr_header_rec;

       IF GetMrHeaderDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MR_HEADER_ID_INVALID');
               fnd_message.set_token('MR_HEADER_ID',l_mr_header_rec.MR_HEADER_ID,false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_FMP_MR_NTF_FORWARD_SUBJECT');
               fnd_message.set_token('TITLE',l_mr_header_rec.TITLE, false);
               fnd_message.set_token('VERSION_NUMBER',l_mr_header_rec.MR_HEADER_ID);
               l_body := fnd_message.get;
               l_subject:= fnd_message.get;
       END IF;
       CLOSE GetMrHeaderDet;



  l_body :=l_body||'.'|| 'An error occured in the approval process of your request.'||fnd_global.local_chr(10);
  l_body := l_body || 'Please choose to cancel or re-submit your request.'||fnd_global.local_chr(10);
  l_body := l_body || 'Error Message'||l_error_msg;

  document := document || l_body;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type ,
           p_itemkey           => l_item_key ,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','Ntf_Error_Act',
                      l_item_type,l_item_key,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHL_FMP_MR_APPROVAL_PVT'
                    , 'Ntf_Error_Act'
                    , l_item_type
                    , l_item_key
                    );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject                VARCHAR2(500);
 l_commit                VARCHAR2(1):=FND_API.G_TRUE;
 l_mr_header_id          number:=0;
 l_api_version           NUMBER:=1.0;
 l_init_msg_list         VARCHAR2(1):= FND_API.G_TRUE;
 l_validate_only         VARCHAR2(1):= FND_API.G_TRUE;
 l_validation_level      NUMBER:= FND_API.G_VALID_LEVEL_FULL;
 l_module_type           VARCHAR2(1);
 x_return_status         VARCHAR2(1);
 l_return_status         VARCHAR2(1);
 x_msg_count             NUMBER;
 x_msg_data              VARCHAR2(2000);
 l_mr_header_rec     ahl_FMP_mr_header_pvt.mr_header_Rec;
 l_default               VARCHAR2(1):= FND_API.G_FALSE;

BEGIN
	IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.enable_debug;
	  AHL_DEBUG_PUB.debug( 'Start Update Status API','+UPDATE_STATUS+');
	END IF;

  IF funcmode = 'RUN' THEN
     l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'UPDATE_GEN_STATUS'
                        );

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

        IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug( 'l_object_id mr_header_id'||l_object_id);
	AHL_DEBUG_PUB.debug( 'Approval Status--->'||l_approval_status);
	AHL_DEBUG_PUB.debug( 'Before complete complete_mr_revision api');
	END IF;
        AHL_FMP_MR_REVISION_PVT.COMPLETE_MR_REVISION
         (
         p_api_version               =>l_api_version,
         p_init_msg_list             =>l_init_msg_list,
         p_commit                    =>FND_API.G_FALSE,
         p_validation_level          =>l_validation_level ,
         p_default                   =>l_default ,
         p_module_type               =>'null',
         x_return_status             =>l_return_status,
         x_msg_count                 =>x_msg_count ,
         x_msg_data                  =>x_msg_data  ,
         p_appr_status               =>l_approval_status,
         p_mr_header_id              =>l_object_id,
         p_object_version_number     =>l_object_version_number
         );
        IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug( 'After complete Update Status');
	END IF;
	COMMIT;
     resultout := 'COMPLETE:';
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RETURN;
  END IF;

  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RETURN;
  END IF;


EXCEPTION
  WHEN fnd_api.g_exc_error THEN
        IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.debug( ' Error in workflow:'||sqlerrm||'Update_status');
	END IF;

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
      wf_core.context('AHL_FMP_APRV_PVT','UPDATE_STATUS',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RAISE;

  WHEN OTHERS THEN
           IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug( ' Error ...2..'||sqlerrm||'<--From-->UPDATE_STATUS');
            END IF;

     wf_core.context(
        'AHL_FMP_MR_APPROVAL_PVT'
       ,'Update_Status'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
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
l_subject                VARCHAR2(500);
  cursor GetMrHeaderDet(c_mr_header_id number)
  is
  select mr_header_id,title,effective_from
  from ahl_mr_headers_b
  where mr_header_id=c_mr_header_id;

  l_mr_header_rec            GetMrHeaderDet%rowtype;
  l_return_status            VARCHAR2(1);

BEGIN
        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( '10010','+REVERT STATUS+');
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
-- Update approval object table as following
-- FMPMR Code

     UPDATE AHL_MR_HEADERS_B
        SET MR_STATUS_CODE = 'DRAFT',
            object_version_number =l_object_version_number+1
      WHERE mr_header_id = l_object_id
      and   object_Version_number=l_object_version_number;

     if (sql%notfound)
     then
	FND_MESSAGE.Set_Name('AHL','AHL_APRV_OBJ_CHANGED');
	FND_MSG_PUB.Add;

	l_return_status := FND_API.G_RET_STS_ERROR;
	return;

     end if;
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
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
      wf_core.context('AHL_FMP_MR_APPROVAL_PVT','revert_status',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RAISE;
  WHEN OTHERS THEN
     wf_core.context(
        'AHL_FMP_MR_APPROVAL_PVT'
       ,'REVERT_STATUS'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
    IF G_DEBUG='Y' THEN
                  AHL_DEBUG_PUB.disable_debug;
    END IF;
     RAISE;

END Revert_Status;

END AHL_FMP_MR_APPROVAL_PVT;

/

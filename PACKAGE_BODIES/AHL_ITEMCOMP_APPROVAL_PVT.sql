--------------------------------------------------------
--  DDL for Package Body AHL_ITEMCOMP_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_ITEMCOMP_APPROVAL_PVT" AS
/* $Header: AHLVCWFB.pls 120.0 2005/05/26 01:48:12 appldev noship $ */
--------------------------------------------------------------------------
-- PROCEDURE
--   Set_Activity_Details
--
-- PURPOSE
--   This procedure will set the workflow attributes for the details of the activity.
--
-- IN
--   itemtype -  The internale name of the Item Type
--   itemkey  - Unique key formulated in Start_WF_Process for WF internal reference
--   actid    - The ID number of the activity from which this procedure is called.
--   funcmode -  The execution mode of the activity
-- OUT
--   resultout - The expected result thats returned when the procedure comletes.
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------


PROCEDURE Set_Activity_Details(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
        ,resultout   OUT NOCOPY      VARCHAR2)

        AS

        Cursor GetItemCompDet(c_ITEM_COMPOSITION_ID Number) IS

        Select
		item_composition_id          ,
		concatenated_segments,
		object_version_number,
		inventory_item_id,
		approval_status_code                 ,
		effective_end_date                   ,
		link_comp_id
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

	l_object_id NUMBER;
	l_subject   VARCHAR2(500);
	l_fwd_subject VARCHAR2(500);
	l_appr_subject VARCHAR2(500);
	l_reject_subject VARCHAR2(500);
	l_approved_subject VARCHAR2(500);
	l_final_subject VARCHAR2(500);
	l_remind_subject VARCHAR2(500);
	l_error_subject  VARCHAR2(500);
	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
  	l_msg_data              VARCHAR2(4000);
  	l_object_details        ahl_generic_aprv_pvt.ObjRecTyp;
  	l_object                VARCHAR2(30) := 'ICWF';
  	l_approval_type         VARCHAR2(30)    := 'CONCEPT';
  	l_approval_rule_id      NUMBER;
  	l_approver_seq          NUMBER;
  	l_error_msg             VARCHAR2(2000);



        BEGIN

	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
	      THEN
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
		'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Start SetActvityDetails');
	 END IF;
	    -- Debug info.

	  fnd_msg_pub.initialize;

	  l_return_status := fnd_api.g_ret_sts_success;

	  l_object_id := wf_engine.getitemattrnumber(
	                      itemtype => itemtype
	                     ,itemkey  => itemkey
	                     ,aname    => 'OBJECT_ID'
	                   );

	  l_object_details.operating_unit_id :=NULL;

	  l_object_details.priority  :=NULL;

	IF (funcmode = 'RUN') THEN

       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_subject := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FWD_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_fwd_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_APPR_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_appr_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_REJECT_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_reject_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_APPRD_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_approved_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FINAL_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_final_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_REMIND_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_remind_subject := fnd_message.get;
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_ERROR_SUBJECT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_error_subject := fnd_message.get;


       END IF;
       CLOSE GetItemCompDet;

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
	      THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','ItemGroups Name'||l_item_comp_rec.ITEM_COMPOSITION_ID);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Subject:'||l_subject);

	 END IF;


       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FORWARD_SUBJECT'
                 ,avalue   => l_fwd_subject);
       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVAL_SUBJECT'
                 ,avalue   => l_appr_subject);


       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REJECT_SUBJECT'
                 ,avalue   => l_reject_subject);


       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVED_SUBJECT'
                 ,avalue   => l_approved_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVED_SUBJECT'
                 ,avalue   => l_approved_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FINAL_SUBJECT'
                 ,avalue   => l_final_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REMIND_SUBJECT'
                 ,avalue   => l_remind_subject);

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'ERROR_SUBJECT'
                 ,avalue   => l_error_subject
                         );
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
	      THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
		'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'l_subject'||l_subject);
	 END IF;


-----------------------------------------------------------------------------------
-- Get Approval Rule and First Approver Sequence
-----------------------------------------------------------------------------------

	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
	   THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Before getting approval details'||l_subject);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', '---l_object-->'||l_object);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', '---l_approval_type-->'||l_approval_type);
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', '---l_approval_RULE_ID-->'||TO_CHAR(L_APPROVAL_RULE_ID));
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', '---L_APPROVER_SEQ-->'||TO_CHAR(L_APPROVER_SEQ));
	END IF;
     ahl_generic_aprv_pvt.get_approval_details(
        p_object             => l_object,
        p_approval_type      => l_approval_type,
        p_object_details     => l_object_details,
        x_approval_rule_id   => l_approval_rule_id,
        x_approver_seq       => l_approver_seq,
        x_return_status      => l_return_status
     );


     	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','AfterGetApprovalDetails:'||l_return_status||'-'||l_subject);
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
      wf_core.context('AHL_ITEMGROUPS_APROVAL_PVT','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);

     resultout := 'COMPLETE:ERROR';

  WHEN OTHERS THEN
      wf_core.context(
           'AHL_ITEMCOMP_APPROVAL_PVT'
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
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS
       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE                 ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

	l_object_id NUMBER;
	l_subject   VARCHAR2(500);
	l_hyphen_pos1         NUMBER;
	l_object              VARCHAR2(30);
	l_item_type           VARCHAR2(30);
	l_item_key            VARCHAR2(30);
	l_approver            VARCHAR2(30);
	l_body                VARCHAR2(3500);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);



        BEGIN
      	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Start NtfForwardFyi');
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

       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FWD_FYI_FWD');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('APPR_NAME',l_approver, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;


/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','ntf_forward_fyi',
                      l_item_type,l_item_key,l_error_msg);
     RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Forward_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;


  END ntf_forward_fyi;

PROCEDURE Ntf_Approved_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS

       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

	l_object_id NUMBER;
	l_subject   VARCHAR2(500);
	l_hyphen_pos1         NUMBER;
	l_object              VARCHAR2(30);
	l_item_type           VARCHAR2(30);
	l_item_key            VARCHAR2(30);
	l_approver            VARCHAR2(30);
	l_body                VARCHAR2(3500);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Start NtfApproved Fyi');
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
       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FWD_FYI_APPRVD');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('APPR_NAME',l_approver, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;



  l_body :=l_body||'.'|| 'Your request has been approved by ' ||l_approver ;

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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Approved_FYI',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Approved_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;

  END;

--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Final_Approval_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Final_Approval_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS

       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_hyphen_pos1         NUMBER;
	l_object              VARCHAR2(30);
	l_item_type           VARCHAR2(30);
	l_item_key            VARCHAR2(30);
	l_body                VARCHAR2(3500);
	l_object_id      NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);


	l_item_comp_rec  GetItemCompDet%ROWTYPE;


        BEGIN

       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','NtfyFinalApprovalFyi');
	END IF;


  document_type := 'text/plain';

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Notify Final approval;');
	END IF;
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

       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FWD_FYI_FINAL');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;


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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Final_Approval_FYI',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHLGAPP'
                    , 'Ntf_Final_Approval_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;

 END;
--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Rejected_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
AS
       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;


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


        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Start NtfyRejectedFYi');
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

/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_FWD_FYI_RJCT');
               fnd_message.set_token('GROUPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('APPR_NAME',l_approver, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;



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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Rejected_FYI',
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


--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Approval
--
-- PURPOSE
--   Generate the Document to ask for approval, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS

       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_requester           	VARCHAR2(30);
	l_requester_note      	VARCHAR2(4000);
	l_body                	VARCHAR2(5000);
	l_object_id           	NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Start NtfyApproval');
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

       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_APPROVAL');
               fnd_message.set_token('GROUPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('NOTE',l_requester_note, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;



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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Approval',
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
--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Approval_Reminder
--
-- PURPOSE
--   Generate the Reminder Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Approval_Reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS

       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

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

        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Start NtfyApprovalRemainder');
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


/*--------------------------------------------------------------------------
-- Query approval object table for any detail information of this object
-- that will be used to replace tokens defined in FND Messages.
-- Here to simplify, we are using hard-coded messages.
----------------------------------------------------------------------------*/
       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_REMIND');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               fnd_message.set_token('NOTE	',l_requester_note, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;


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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Approval_Reminder',
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



--------------------------------------------------------------------------
-- PROCEDURE
--   Ntf_Error_Act
--
-- PURPOSE
--   Generate the Document to request action to handle error, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Ntf_Error_Act(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)

AS

       Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

	l_hyphen_pos1         NUMBER;
	l_object              VARCHAR2(30);
	l_item_type           VARCHAR2(30);
	l_item_key            VARCHAR2(30);
	l_body                VARCHAR2(3500);
	l_object_id           NUMBER;
	l_error_msg           VARCHAR2(4000);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);


        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'NtfyErrorAct');
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

       OPEN  GetItemCompDet(l_object_id);
       FETCH GetItemCompDet into l_item_comp_rec;

       IF GetItemCompDet%NOTFOUND
       THEN
               fnd_message.set_name('AHL', 'AHL_MC_COMP_ID_INVALID');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.concatenated_segments ,false);
               fnd_message.set_token('COMP_ID',l_item_comp_rec.INVENTORY_ITEM_ID, false);
               l_body := fnd_message.get;
       ELSE
               fnd_message.set_name('AHL', 'AHL_MC_COMP_NTF_ERROR_ACT');
               fnd_message.set_token('COMPNAME',l_item_comp_rec.ITEM_COMPOSITION_ID ,false);
               fnd_message.set_token('ERR_MSG',l_error_msg, false);
               l_body := fnd_message.get;
       END IF;
       CLOSE GetItemCompDet;

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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','Ntf_Error_Act',
                      l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
     wf_core.context( 'AHL_ITEMCOMP_APPROVAL_PVT'
                    , 'Ntf_Error_Act'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END Ntf_Error_Act;

---------------------------------------------------------------------
-- PROCEDURE
--  Update_Status
--
-- PURPOSE
--   This Procedure will update the status
--
-- IN
--
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Update_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)

AS
          Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE                 ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

l_object_id                NUMBER;
l_approval_status          VARCHAR2(30);
l_error_msg           VARCHAR2(4000);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_next_status              VARCHAR2(30);
l_object_version_number    NUMBER;
l_status_date              DATE;
l_return_status         VARCHAR2(1);
l_api_version           NUMBER := 1.0;
l_init_msg_list         BOOLEAN := false;
l_commit                BOOLEAN :=false;


        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Start UpdateStatus');
	END IF;

  IF funcmode = 'RUN' THEN
     l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'UPDATE_GEN_STATUS'
                        );
       	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'After GetItemAttrText UpdateStatus');
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

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','l_object_id:'||to_char(l_object_id));
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','l_approvalStatus:'||l_approval_status);
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Object version id check :'||to_char(l_object_id));
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'l_approval_status:'||l_approval_status);
	END IF;

   	OPEN  GetItemCompDet(l_object_id);
	FETCH GetItemCompDet into l_item_comp_rec;
	CLOSE GetItemCompDet;


	ahl_mc_item_comp_pvt.approve_item_composiiton
         (
         p_api_version               =>l_api_version,
 --        p_init_msg_list             =>l_init_msg_list,
 --        p_commit                    =>l_commit,
 --        p_validation_level          =>NULL ,
 --        p_default                   =>NULL ,
         p_module_type               =>'JSP',
         x_return_status             =>l_return_status,
         x_msg_count                 =>l_msg_count ,
         x_msg_data                  =>l_msg_data  ,
         p_appr_status               =>l_approval_status,
         P_ITEM_COMP_ID                  =>l_object_id,
         p_object_version_number     =>l_object_version_number
         );

         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','After Complete Item Group Revision:L_ApprovalStatus'||l_approval_status);
	END IF;

        if (sql%notfound)
        then
                FND_MESSAGE.Set_Name('AHL','AHL_APRV_OBJ_CHANGED');
                FND_MSG_PUB.Add;
                l_return_status := FND_API.G_RET_STS_ERROR;
        End if;

        IF l_return_Status=fnd_api.g_ret_sts_success
        THEN
                COMMIT;
        ELSE
                ROLLBACK;
        END IF;

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
     	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details','Error G_exec UpdateSatus:'||sqlerrm);
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
      wf_core.context('AHL_FMP_APRV_PVT','UPDATE_STATUS',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
     RAISE;

  WHEN OTHERS THEN
   	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'UpdateStatus Whenothers Err:'||sqlerrm);

	END IF;

     wf_core.context(
        'AHL_ITEMCOMP_APPROVAL_PVT'
       ,'Update_Status'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
     RAISE;

END Update_Status;
---------------------------------------------------------------------
-- PROCEDURE
--  Revert_Status
--
-- PURPOSE
--   This Procedure will revert the status in the case of an error
--
-- IN
--
-- OUT
--
-- USED BY
--   Oracle CMRO Apporval
--
-- HISTORY
--   04/23/2003  Senthil Kumar  created
--------------------------------------------------------------------------
PROCEDURE Revert_Status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)

AS

l_error_msg                VARCHAR2(4000);
l_next_status              VARCHAR2(30);
l_approval_status          VARCHAR2(30);
l_object_version_number    NUMBER;
l_object_id                NUMBER;
l_status_date              DATE;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_return_status            VARCHAR2(1);

     Cursor GetItemCompDet(C_ITEM_COMPOSITION_ID Number) IS

        Select
		ITEM_COMPOSITION_ID ,
		concatenated_segments,
		object_version_number,
		INVENTORY_ITEM_ID,
		APPROVAL_STATUS_CODE              ,
		EFFECTIVE_END_DATE              ,
		LINK_COMP_ID
	FROM
		ahl_item_comp_v
	WHERE
		ITEM_COMPOSITION_ID =C_ITEM_COMPOSITION_ID;

	l_item_comp_rec  GetItemCompDet%ROWTYPE;

        BEGIN
       	IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
			'AHL_ITEMCOMP_APPROVAL_PVT.Set_Activity_Details', 'Start RevertStatus');
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

	OPEN  GetItemCompDet(l_object_id);
	FETCH GetItemCompDet into l_item_comp_rec;
	CLOSE GetItemCompDet;


              UPDATE AHL_ITEM_COMPOSITIONS
                SET APPROVAL_STATUS_CODE = 'DARFT',
                    object_version_number =l_object_version_number+1
              WHERE ITEM_COMPOSITION_ID = l_object_id
              and   object_Version_number=l_object_version_number;


     if (sql%notfound)
     then
	FND_MESSAGE.Set_Name('AHL','AHL_APRV_OBJ_CHANGED');
	FND_MSG_PUB.Add;

	l_return_status := FND_API.G_RET_STS_ERROR;
	return;

     end if;

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
      wf_core.context('AHL_ITEMCOMP_APPROVAL_PVT','revert_status',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
     RAISE;
  WHEN OTHERS THEN
     wf_core.context(
        'AHL_ITEMCOMP_APPROVAL_PVT'
       ,'REVERT_STATUS'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,'Unexpected Error!'
     );
     RAISE;

END Revert_Status;

END AHL_ITEMCOMP_APPROVAL_PVT;

/

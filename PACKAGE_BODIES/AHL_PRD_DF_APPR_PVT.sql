--------------------------------------------------------
--  DDL for Package Body AHL_PRD_DF_APPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PRD_DF_APPR_PVT" AS
/* $Header: AHLVPDAB.pls 120.2 2008/04/28 23:57:48 sikumar ship $ */
  G_PKG_NAME             CONSTANT  VARCHAR(30) := 'AHL_PRD_DF_APPR_PVT';
  G_APP_NAME             CONSTANT  VARCHAR2(3) := 'AHL';
  G_WORKFLOW_OBJECT_KEY  CONSTANT  VARCHAR2(30) := 'PRDWF';

FUNCTION getRequesterNote(
         p_df_header_info_rec     AHL_PRD_DF_PVT.df_header_info_rec_type,
         p_df_schedules_tbl       AHL_PRD_DF_PVT.df_schedules_tbl_type)RETURN VARCHAR2;

FUNCTION getReasonCode(p_defer_reason_code IN VARCHAR2) RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- Set the workflow details.
-- sets the subjects for various events and approval details in the form of
--    requester note.
--------------------------------------------------------------------------------

PROCEDURE Set_Activity_Details(
	 itemtype    IN       VARCHAR2,
	 itemkey     IN       VARCHAR2,
	 actid       IN       NUMBER,
	 funcmode    IN       VARCHAR2,
     resultout   OUT NOCOPY      VARCHAR2)
IS

  l_object_id             NUMBER;
  l_object                VARCHAR2(30)    := G_WORKFLOW_OBJECT_KEY;
  l_approval_type         VARCHAR2(30)    := 'CONCEPT';
  l_object_details        ahl_generic_aprv_pvt.ObjRecTyp;
  l_approval_rule_id      NUMBER;
  l_approver_seq          NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_temp_subject          VARCHAR2(500);
  l_subject               VARCHAR2(600);
  l_error_msg             VARCHAR2(2000);

  l_approver             VARCHAR2(30);
  l_requester            VARCHAR2(30);

  l_df_header_info_rec AHL_PRD_DF_PVT.df_header_info_rec_type;
  l_df_schedules_tbl       AHL_PRD_DF_PVT.df_schedules_tbl_type;

  CURSOR unit_effectivity_id_csr(p_unit_deferral_id IN NUMBER) IS
  SELECT unit_effectivity_id from ahl_unit_deferrals_b
  WHERE unit_deferral_id = p_unit_deferral_id;

  l_unit_effectivity_id NUMBER;

  l_requester_note VARCHAR2(4000);


BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details.begin',
			'At the start of PLSQL procedure'
		);

  END IF;

  fnd_msg_pub.initialize;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  l_object_id := wf_engine.getitemattrnumber(
                      itemtype => itemtype
                     ,itemkey  => itemkey
                     ,aname    => 'OBJECT_ID'
                   );

  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			'Starting workflow for unit_deferral_id : ' || l_object_id
		);
  END IF;

  l_object_details.operating_unit_id :=NULL;
  l_object_details.priority  :=NULL;

  IF (funcmode = 'RUN') THEN

       OPEN unit_effectivity_id_csr(l_object_id);
       FETCH unit_effectivity_id_csr INTO l_unit_effectivity_id;
       IF(unit_effectivity_id_csr%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME('AHL', 'AHL_PRD_DF_APPR_INV_DF');
          FND_MESSAGE.SET_TOKEN('DEFERRAL_ID',l_object_id);
          FND_MSG_PUB.ADD;
          IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			    'Unit effectivity record not found for unit deferral id : ' || l_object_id
		    );
          END IF;
          CLOSE unit_effectivity_id_csr;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
         AHL_PRD_DF_PVT.get_deferral_details (
            p_init_msg_list        => FND_API.G_FALSE,
            p_unit_effectivity_id  => l_unit_effectivity_id,
	        x_df_header_info_rec   => l_df_header_info_rec,
            x_df_schedules_tbl     => l_df_schedules_tbl,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data);
         IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_INV_DF');
            FND_MESSAGE.SET_TOKEN('DEFERRAL_ID',l_object_id);
            FND_MSG_PUB.ADD;
            IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		        fnd_log.string
		        (
			        fnd_log.level_unexpected,
			        'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			        'Deferral record details not found for unit deferral id : ' || l_object_id
		        );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSE
            IF(l_df_header_info_rec.deferral_type = AHL_PRD_DF_PVT.G_DEFERRAL_TYPE_MR)THEN
              FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_MR_SUBJECT');
              FND_MESSAGE.SET_TOKEN('MR_TITLE',l_df_header_info_rec.mr_title,false);
              FND_MESSAGE.SET_TOKEN('VISIT_NUMBER',l_df_header_info_rec.visit_number,false);
              l_temp_subject := FND_MESSAGE.get;
            ELSE
              FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_SR_SUBJECT');
              FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER',l_df_header_info_rec.incident_number,false);
              FND_MESSAGE.SET_TOKEN('VISIT_NUMBER',l_df_header_info_rec.visit_number,false);
              l_temp_subject := FND_MESSAGE.get;
            END IF;
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			        fnd_log.level_statement,
			        'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			        'getting requester note'
		        );
            END IF;
            l_requester_note := getRequesterNote(l_df_header_info_rec, l_df_schedules_tbl);
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		      fnd_log.string
		      (
			        fnd_log.level_statement,
			        'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			        'got requester note'
		        );
            END IF;
         END IF;
       END IF;
       CLOSE unit_effectivity_id_csr;

       IF(FND_MSG_PUB.count_msg > 0)THEN
        IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			    'Could not set activity details for deferral workflow of unit deferral id : ' || l_object_id
		    );
         END IF;
        RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		   fnd_log.string
		   (
			  fnd_log.level_statement,
			  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			  'SUBJECT : ' || l_temp_subject
		   );
           fnd_log.string
		   (
			  fnd_log.level_statement,
			  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			  'REQUESTER NOTE : ' || l_requester_note
		   );
       END IF;

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_FW_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FORWARD_SUBJECT'
                 ,avalue   => l_subject
                         );

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_APPR_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVAL_SUBJECT'
                 ,avalue   => l_subject
                         );

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_REJ_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REJECT_SUBJECT'
                 ,avalue   => l_subject
                         );

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_APVD_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'APPROVED_SUBJECT'
                 ,avalue   => l_subject
                         );

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_FIN_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'FINAL_SUBJECT'
                 ,avalue   => l_subject
                         );

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_REM_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REMIND_SUBJECT'
                 ,avalue   => l_subject);

       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_ERR_SUBJECT');
       l_subject := FND_MESSAGE.get || l_temp_subject;

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'ERROR_SUBJECT'
                 ,avalue   => l_subject
                         );

       wf_engine.setitemattrtext(
                 itemtype => itemtype
                 ,itemkey  => itemkey
                 ,aname    => 'REQUESTER_NOTE'
                 ,avalue   => l_requester_note
                         );

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

       IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

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
       ELSE
         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details',
			    'Could not set activity details for deferral workflow of unit deferral id : ' || l_object_id
		    );
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  ELSIF (funcmode IN ('CANCEL','TIMEOUT'))THEN
     resultout := 'COMPLETE:';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Set_Activity_Details.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(
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
        wf_core.context(G_PKG_NAME,'Set_Activity_Details', itemtype,itemkey,actid,funcmode,l_error_msg);
        resultout := 'COMPLETE:ERROR';
        RAISE;
  WHEN OTHERS THEN
        wf_core.context(G_PKG_NAME,'Set_Activity_Details', itemtype,itemkey,actid,funcmode,'UNEXPECTED_ERROR');
        resultout := 'COMPLETE:ERROR';
        RAISE;
END Set_Activity_Details;
--------------------------------------------------------------------------------
-- Procedure forwards the message to the requester that the approval
--   has been forwarded for approval to a specific approver.
--------------------------------------------------------------------------------
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
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);
l_requester_note      VARCHAR2(4000);


BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Forward_FYI.begin',
			'At the start of PLSQL procedure'
		);
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
   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Forward_FYI',
			'Deferral Approval Request has been forwarded for unit_deferral_id : ' || l_object_id
		);
   END IF;

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_FWD_BODY');
  FND_MESSAGE.SET_TOKEN('APPROVER',l_approver ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Forward_FYI',
		  'Forward FYI Body : ' || document
      );
  END IF;
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
	  (
		  fnd_log.level_procedure,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Forward_FYI.end',
		  'At the end of PLSQL procedure'
	  );
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
       FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
       );
       ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type,
           p_itemkey           => l_item_key ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
       )               ;
      wf_core.context(G_PKG_NAME,'Ntf_Forward_FYI',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Forward_FYI', l_item_type, l_item_key );
      RAISE;
END Ntf_Forward_FYI;
--------------------------------------------------------------------------------
-- Procedure forwards the message to the requester that the approval
--   has been approved by a specific approver.
--------------------------------------------------------------------------------
PROCEDURE Ntf_Approved_FYI(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2)IS

  l_hyphen_pos1         NUMBER;
  l_object              VARCHAR2(30);
  l_item_type           VARCHAR2(30);
  l_item_key            VARCHAR2(30);
  l_approver            VARCHAR2(30);
  l_requester_note      VARCHAR2(4000);
  l_object_id           NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_error_msg           VARCHAR2(2000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approved_FYI.begin',
			'At the start of PLSQL procedure'
		);
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
   IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approved_FYI',
			'Sending FYI for approval of unit_deferral_id : ' || l_object_id
		);
   END IF;

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_APRVD_BODY');
  FND_MESSAGE.SET_TOKEN('APPROVER',l_approver ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approved_FYI',
		  'Approved FYI Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approved_FYI.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      wf_core.context(G_PKG_NAME,'Ntf_Approved_FYI',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Approved_FYI', l_item_type, l_item_key );
      RAISE;
END Ntf_Approved_FYI;

--------------------------------------------------------------------------------
-- Procedure forwards the message to the requester that the approval
--   has been approved by all approvers.
--------------------------------------------------------------------------------
PROCEDURE Ntf_Final_Approval_FYI(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2) IS

   l_hyphen_pos1         NUMBER;
   l_object              VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_requester_note      VARCHAR2(4000);
   l_object_id           NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(4000);
   l_error_msg           VARCHAR2(2000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Final_Approval_FYI.begin',
			'At the start of PLSQL procedure'
		);
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
  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Final_Approval_FYI',
			'Deferral finally approved for unit_deferral_id : ' || l_object_id
		);
  END IF;

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_FAPPR_BODY');
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Final_Approval_FYI',
		  'Final Approval FYI Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Final_Approval_FYI.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      wf_core.context(G_PKG_NAME,'Ntf_Final_Approval_FYI',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Final_Approval_FYI', l_item_type, l_item_key );
      RAISE;
END Ntf_Final_Approval_FYI;

--------------------------------------------------------------------------------
-- Procedure forwards the message to the requester that the approval
--   has been rejected by a specific approver.
--------------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2) IS

   l_hyphen_pos1         NUMBER;
   l_object              VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_approver            VARCHAR2(30);
   l_requester_note      VARCHAR2(4000);
   l_object_id           NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(4000);
   l_error_msg           VARCHAR2(2000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Rejected_FYI.begin',
			'At the start of PLSQL procedure'
		);
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
  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Rejected_FYI',
			'Sending FYI for Deferral Rejection of unit_deferral_id : ' || l_object_id
		);
  END IF;

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'APPROVER'
                );

  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_REJ_BODY');
  FND_MESSAGE.SET_TOKEN('APPROVER',l_approver ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Rejected_FYI',
		  'Rejected FYI Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Rejected_FYI.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
 WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      wf_core.context(G_PKG_NAME,'Ntf_Rejected_FYI',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Rejected_FYI', l_item_type, l_item_key );
      RAISE;
END Ntf_Rejected_FYI;

--------------------------------------------------------------------------------
-- Procedure forwards the message to the approver for approval with the
-- requester note
--------------------------------------------------------------------------------

PROCEDURE Ntf_Approval(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2) IS

   l_hyphen_pos1         NUMBER;
   l_object              VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_requester           VARCHAR2(30);
   l_requester_note      VARCHAR2(4000);
   l_object_id           NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(4000);
   l_error_msg           VARCHAR2(2000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval.begin',
			'At the start of PLSQL procedure'
		);
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
  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval',
			'Sending notfication to approver for unit_deferral_id : ' || l_object_id
		);
  END IF;

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

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_APPR_BODY');
  FND_MESSAGE.SET_TOKEN('REQUESTER',l_requester ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval',
		  'Approval Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      wf_core.context(G_PKG_NAME,'Ntf_Approval',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Approval', l_item_type, l_item_key );
      RAISE;
END Ntf_Approval;

--------------------------------------------------------------------------------
-- Procedure forwards the reminder to the approver for approval with the
-- requester note
--------------------------------------------------------------------------------
PROCEDURE Ntf_Approval_Reminder(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2)
IS

l_hyphen_pos1         NUMBER;
l_object              VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_requester           VARCHAR2(30);
l_requester_note      VARCHAR2(4000);
l_object_id           NUMBER;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(4000);
l_error_msg           VARCHAR2(2000);




BEGIN
  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval_Reminder.begin',
			'At the start of PLSQL procedure'
		);
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
  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval_Reminder',
			'Sending reminder to approver for unit_deferral_id : ' || l_object_id
		);
  END IF;

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

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_APPRM_BODY');
  FND_MESSAGE.SET_TOKEN('REQUESTER',l_requester ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval_Reminder',
		  'Approval Reminder Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Approval_Reminder.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
      wf_core.context(G_PKG_NAME,'Ntf_Approval_Reminder',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Approval_Reminder', l_item_type, l_item_key );
      RAISE;
END Ntf_Approval_Reminder;

--------------------------------------------------------------------------------
-- Procedure forwards the message to the approver for approval with the
-- requester note
--------------------------------------------------------------------------------
PROCEDURE Ntf_Error_Act(
   document_id     IN       VARCHAR2,
   display_type    IN       VARCHAR2,
   document        IN OUT NOCOPY   VARCHAR2,
   document_type   IN OUT NOCOPY   VARCHAR2) IS

   l_hyphen_pos1         NUMBER;
   l_object              VARCHAR2(30);
   l_item_type           VARCHAR2(30);
   l_item_key            VARCHAR2(30);
   l_requester_note      VARCHAR2(4000);
   l_object_id           NUMBER;
   l_error_msg           VARCHAR2(4000);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(4000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Error_Act.begin',
			'At the start of PLSQL procedure'
		);
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

  IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_event,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Error_Act',
			'Error in approval workflow process for unit_deferral_id : ' || l_object_id
		);
  END IF;

  l_error_msg := wf_engine.getitemattrText(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'ERROR_MSG'
                );

  IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_error,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Error_Act',
			'Error Message : ' || l_error_msg
		);
  END IF;
  l_requester_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'REQUESTER_NOTE'
                );

  FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_ERR_BODY');
  FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_error_msg ,false);
  document := FND_MESSAGE.get;
  document := document || l_requester_note;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
	  fnd_log.string
      (
		  fnd_log.level_statement,
		  'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Error_Act',
		  'Approval Error Body : ' || document
      );
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Ntf_Error_Act.end',
			'At the end of PLSQL procedure'
		);
  END IF;

EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
       FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
       );
       ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => l_item_type,
           p_itemkey           => l_item_key ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
       )               ;
      wf_core.context(G_PKG_NAME,'Ntf_Error_Act',l_item_type,l_item_key,l_error_msg);
      RAISE;
  WHEN OTHERS THEN
      wf_core.context( 'AHLGAPP', 'Ntf_Error_Act', l_item_type, l_item_key );
      RAISE;
END Ntf_Error_Act;

PROCEDURE Update_Status(
   itemtype    IN       VARCHAR2,
   itemkey     IN       VARCHAR2,
   actid       IN       NUMBER,
   funcmode    IN       VARCHAR2,
   resultout   OUT NOCOPY      VARCHAR2) IS

  l_error_msg                VARCHAR2(4000);
  l_approval_status          VARCHAR2(30);
  l_new_status               VARCHAR2(30);
  l_object_id                NUMBER;
  l_object_version_number    NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
  l_return_status            VARCHAR2(1);
  l_approver_note            VARCHAR2(4000);

BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status.begin',
			'At the start of PLSQL procedure'
		);
  END IF;
  SAVEPOINT AHL_DEF_UPDATE_STATUS;

  MO_GLOBAL.INIT('AHL');

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (funcmode = 'RUN') THEN

     l_approval_status := wf_engine.getitemattrtext(
                           itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'UPDATE_GEN_STATUS'
                        );

     l_object_id   := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'OBJECT_ID'
                                 );
     l_object_version_number := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'OBJECT_VER'
                                 );
     l_approver_note         := wf_engine.getitemattrtext(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'APPROVER NOTE'
                                 );

     UPDATE AHL_UNIT_DEFERRALS_TL
     SET approver_notes = l_approver_note,
     SOURCE_LANG = userenv('LANG')
     WHERE unit_deferral_id = l_object_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status',
			'unit_deferral_id : ' || l_object_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status',
			'object_version_number : ' || l_object_version_number
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status',
			'approval status : ' || l_approval_status
		);

     END IF;

     IF (l_approval_status IN( 'DEFERRED','TERMINATED','CANCELLED')) THEN

        l_new_status := wf_engine.getitemattrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'NEW_STATUS_ID'
                            );
        AHL_PRD_DF_PVT.process_approval_approved(
                    p_unit_deferral_id      => l_object_id,
                    p_object_version_number => l_object_version_number,
                    p_new_status            => l_new_status,
                    x_return_status         => l_return_status
                    );
     ELSE
        l_new_status := wf_engine.getitemattrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'REJECT_STATUS_ID'
                            );
        AHL_PRD_DF_PVT.process_approval_rejected(
                    p_unit_deferral_id      => l_object_id,
                    p_object_version_number => l_object_version_number,
                    p_new_status            => l_new_status,
                    x_return_status         => l_return_status
                    );
     END IF;

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status',
			'new status : ' || l_new_status
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status',
			'return status after process_approval_rejected API call : ' || l_return_status
		);
     END IF;

     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSE
       COMMIT WORK;
     END IF;
     resultout := 'COMPLETE:';
  ELSIF (funcmode IN ('CANCEL','TIMEOUT'))THEN
     resultout := 'COMPLETE:';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Update_Status.end',
			'At the end of PLSQL procedure'
		);
  END IF;


EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO AHL_DEF_UPDATE_STATUS;
       FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
       );
       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_APPR_PVT.update_status',
			    ' Error Message : l_msg_data : ' || l_msg_data
		    );
       END IF;
       ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype,
           p_itemkey           => itemkey ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
       )               ;
      wf_core.context(G_PKG_NAME,'Update_Status',itemtype,itemkey,l_error_msg);

       IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)	THEN
		    fnd_log.string
		    (
			    fnd_log.level_unexpected,
			    'ahl.plsql.AHL_PRD_DF_APPR_PVT.update_status',
			    ' Error Message : l_error_msg : ' || l_error_msg
		    );
       END IF;

      -- update validation errors.
      UPDATE AHL_UNIT_DEFERRALS_TL
      SET approver_notes = substrb(l_error_msg,1,4000)
      WHERE unit_deferral_id = l_object_id
        AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE AHL_UNIT_DEFERRALS_B
      SET approval_status_code = 'DEFERRAL_REJECTED',
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE unit_deferral_id = l_object_id;
      COMMIT WORK;

      RAISE;
  WHEN OTHERS THEN
      ROLLBACK TO AHL_DEF_UPDATE_STATUS;
      wf_core.context( 'AHLGAPP', 'Update_Status', itemtype, itemkey );

      l_error_msg := SQLCODE || ': ' || SQLERRM;
       -- update validation errors.
      UPDATE AHL_UNIT_DEFERRALS_TL
      SET approver_notes = substrb(l_error_msg,1,4000)
      WHERE unit_deferral_id = l_object_id
        AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE AHL_UNIT_DEFERRALS_B
      SET approval_status_code = 'DEFERRAL_REJECTED',
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE unit_deferral_id = l_object_id;
      COMMIT WORK;


      RAISE;

END Update_Status;

PROCEDURE Revert_Status(
   itemtype    IN       VARCHAR2,
   itemkey     IN       VARCHAR2,
   actid       IN       NUMBER,
   funcmode    IN       VARCHAR2,
   resultout   OUT NOCOPY      VARCHAR2)
IS

  l_error_msg                VARCHAR2(4000);
  l_orig_status              VARCHAR2(30);
  l_object_version_number    NUMBER;
  l_object_id                NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(4000);
  l_return_status            VARCHAR2(1);
  l_approver_note            VARCHAR2(4000);

BEGIN
   MO_GLOBAL.INIT('AHL');
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status.begin',
			'At the start of PLSQL procedure'
		);
   END IF;
  SAVEPOINT AHL_DEF_REVT_STATUS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (funcmode = 'RUN') THEN
     l_orig_status           := wf_engine.getitemattrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'ORG_STATUS_ID'
                                 );
     l_object_id             := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'OBJECT_ID'
                                 );
     l_object_version_number := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'OBJECT_VER'
                                 );
     l_approver_note         := wf_engine.getitemattrnumber(
                                     itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'APPROVER NOTE'
                                 );

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status',
			'unit_deferral_id : ' || l_object_id
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status',
			'object_version_number : ' || l_object_version_number
		);
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status',
			'Original status : ' || l_orig_status
		);

     END IF;
     -- go in error mode
     AHL_PRD_DF_PVT.process_approval_rejected(
                    p_unit_deferral_id      => l_object_id,
                    p_object_version_number => l_object_version_number,
                    p_new_status            => l_orig_status,
                    x_return_status         => l_return_status
                    );
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
        fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status',
			'return status after process_approval_rejected API call : ' || l_return_status
		);
     END IF;

     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSE
        COMMIT WORK;
     END IF;
     resultout := 'COMPLETE:';
  ELSIF (funcmode IN ('CANCEL','TIMEOUT'))THEN
     resultout := 'COMPLETE:';
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_PRD_DF_APPR_PVT.Revert_Status.end',
			'At the end of PLSQL procedure'
		);
  END IF;
EXCEPTION
  WHEN fnd_api.G_EXC_ERROR OR FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO AHL_DEF_REVT_STATUS;
       FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
       );
       ahl_generic_aprv_pvt.Handle_Error
          (p_itemtype          => itemtype,
           p_itemkey           => itemkey ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'ERROR_MSG',
           x_error_msg         => l_error_msg
       )               ;
      wf_core.context(G_PKG_NAME,'Revert_Status',itemtype,itemkey,l_error_msg);

      -- update validation errors.
      UPDATE AHL_UNIT_DEFERRALS_TL
      SET approver_notes = substrb(l_error_msg,1,4000)
      WHERE unit_deferral_id = l_object_id
        AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE AHL_UNIT_DEFERRALS_B
      SET approval_status_code = 'DEFERRAL_REJECTED',
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE unit_deferral_id = l_object_id;
      COMMIT WORK;

      RAISE;
  WHEN OTHERS THEN
      ROLLBACK TO AHL_DEF_REVT_STATUS;
      wf_core.context( 'AHLGAPP', 'Revert_Status', itemtype, itemkey );

      l_error_msg := SQLCODE || ': ' || SQLERRM;
      -- update validation errors.
      UPDATE AHL_UNIT_DEFERRALS_TL
      SET approver_notes = substrb(l_error_msg,1,4000)
      WHERE unit_deferral_id = l_object_id
        AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

      UPDATE AHL_UNIT_DEFERRALS_B
      SET approval_status_code = 'DEFERRAL_REJECTED',
          object_version_number = object_version_number + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE unit_deferral_id = l_object_id;
      COMMIT WORK;

      RAISE;

END Revert_Status;

FUNCTION getRequesterNote(
         p_df_header_info_rec     AHL_PRD_DF_PVT.df_header_info_rec_type,
         p_df_schedules_tbl       AHL_PRD_DF_PVT.df_schedules_tbl_type) RETURN VARCHAR2 IS

     l_requester_note VARCHAR2(4000);
     l_defer_to_meaning VARCHAR2(80);
     l_defer_by_meaning VARCHAR2(80);

     CURSOR ctr_value_type_meaning_csr IS
     SELECT lookup_code, meaning FROM fnd_lookup_values_vl fnd
     WHERE fnd.lookup_type = 'AHL_PRD_DF_CT_VAL_TYPES';


BEGIN
     FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CTXT_TITLE');
     l_requester_note := FND_MESSAGE.get;

     IF(p_df_header_info_rec.deferral_type = AHL_PRD_DF_PVT.G_DEFERRAL_TYPE_MR)THEN
       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_MR_CTXT');
       FND_MESSAGE.SET_TOKEN('MR_TITLE',p_df_header_info_rec.mr_title,false);
       FND_MESSAGE.SET_TOKEN('VISIT_NUMBER',p_df_header_info_rec.visit_number,false);
       FND_MESSAGE.SET_TOKEN('MR_DESC',p_df_header_info_rec.mr_description,false);
       FND_MESSAGE.SET_TOKEN('DUE_DATE',p_df_header_info_rec.due_date,false);
       l_requester_note := l_requester_note || FND_MESSAGE.get;
     ELSE
       FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_SR_CTXT');
       FND_MESSAGE.SET_TOKEN('INCIDENT_NUMBER',p_df_header_info_rec.incident_number,false);
       FND_MESSAGE.SET_TOKEN('VISIT_NUMBER',p_df_header_info_rec.visit_number,false);
       FND_MESSAGE.SET_TOKEN('SUMMARY',p_df_header_info_rec.summary,false);
       FND_MESSAGE.SET_TOKEN('DUE_DATE',p_df_header_info_rec.due_date,false);
       l_requester_note := l_requester_note || FND_MESSAGE.get;
     END IF;

     FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_REASON');
     FND_MESSAGE.SET_TOKEN('REASON',getReasonCode(p_df_header_info_rec.defer_reason_code),false);
     l_requester_note := l_requester_note || FND_MESSAGE.get;

     FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_REMARK');
     FND_MESSAGE.SET_TOKEN('REMARK',p_df_header_info_rec.remarks,false);
     l_requester_note := l_requester_note || FND_MESSAGE.get;

     FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_SCHEDULE');
     l_requester_note := l_requester_note || FND_MESSAGE.get;
     IF(NVL(p_df_header_info_rec.skip_mr_flag,AHL_PRD_DF_PVT.G_NO_FLAG) = AHL_PRD_DF_PVT.G_YES_FLAG)THEN
       IF(NVL(p_df_header_info_rec.manually_planned_flag,AHL_PRD_DF_PVT.G_NO_FLAG) = AHL_PRD_DF_PVT.G_NO_FLAG)THEN
          FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_SKIP');
          l_requester_note := l_requester_note || FND_MESSAGE.get;
       ELSE
          FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CANCEL');
          l_requester_note := l_requester_note || FND_MESSAGE.get;
       END IF;
     ELSE
        IF(NVL(p_df_header_info_rec.affect_due_calc_flag,AHL_PRD_DF_PVT.G_NO_FLAG) = AHL_PRD_DF_PVT.G_YES_FLAG)THEN
           FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_DFR_AFFDUE');
           l_requester_note := l_requester_note || FND_MESSAGE.get;
        END IF;
        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_DFR_TODT');
        FND_MESSAGE.SET_TOKEN('SET_DUE_DATE',p_df_header_info_rec.set_due_date,false);
        l_requester_note := l_requester_note || FND_MESSAGE.get;

        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_DFR_EFFDT');
        FND_MESSAGE.SET_TOKEN('EFFECT_DATE',p_df_header_info_rec.deferral_effective_on,false);
        l_requester_note := l_requester_note || FND_MESSAGE.get;

        FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CNT_VALS');
        l_requester_note := l_requester_note || FND_MESSAGE.get;

        IF(p_df_schedules_tbl IS NOT NULL AND p_df_schedules_tbl.count > 0)THEN
          FOR meaning_rec IN ctr_value_type_meaning_csr LOOP
            IF(meaning_rec.lookup_code = AHL_PRD_DF_PVT.G_DEFER_BY)THEN
              l_defer_by_meaning := meaning_rec.meaning;
            ELSIF (meaning_rec.lookup_code = AHL_PRD_DF_PVT.G_DEFER_TO)THEN
              l_defer_to_meaning := meaning_rec.meaning;
            END IF;
          END LOOP;

          FOR i IN p_df_schedules_tbl.FIRST..p_df_schedules_tbl.LAST  LOOP
            FND_MESSAGE.SET_NAME(G_APP_NAME, 'AHL_PRD_DF_APPR_CNT_ROW');
            FND_MESSAGE.SET_TOKEN('COUNTER_NAME',p_df_schedules_tbl(i).counter_name,false);
            IF(p_df_schedules_tbl(i).CTR_VALUE_TYPE_CODE = AHL_PRD_DF_PVT.G_DEFER_BY)THEN
              FND_MESSAGE.SET_TOKEN('CTR_VAL_TYPE_CODE',l_defer_by_meaning,false);
            ELSIF (p_df_schedules_tbl(i).CTR_VALUE_TYPE_CODE = AHL_PRD_DF_PVT.G_DEFER_TO)THEN
              FND_MESSAGE.SET_TOKEN('CTR_VAL_TYPE_CODE',l_defer_to_meaning,false);
            END IF;
            FND_MESSAGE.SET_TOKEN('COUNTER_VALUE',p_df_schedules_tbl(i).counter_value,false);
            FND_MESSAGE.SET_TOKEN('UOM_CODE',p_df_schedules_tbl(i).unit_of_measure,false);
            l_requester_note := l_requester_note || FND_MESSAGE.get;
          END LOOP;
        END IF;
     END IF;
     RETURN l_requester_note;

END getRequesterNote;

FUNCTION getReasonCode(p_defer_reason_code IN VARCHAR2) RETURN VARCHAR2 IS

     l_return_meaning VARCHAR2(4000);

     l_temp1 NUMBER := 1;
     l_temp2 NUMBER;
     l_index NUMBER := 1;
     exit_flag boolean := false;
     l_string VARCHAR2(30);

     CURSOR val_reason_meaning_csr(p_reason_code IN VARCHAR2) IS
     SELECT meaning FROM fnd_lookup_values_vl fnd
     WHERE fnd.lookup_type = 'AHL_PRD_DF_REASON_TYPES'
     AND fnd.lookup_code = p_reason_code;

     l_meaning VARCHAR2(80) := '';

BEGIN

    IF(p_defer_reason_code IS NULL)THEN
      RETURN l_return_meaning;
    END IF;
    LOOP
      l_temp2 := instr(p_defer_reason_code,AHL_PRD_DF_PVT.G_REASON_CODE_DELIM,1,l_index);
      IF(l_temp2 = 0) THEN
        l_string := substr(p_defer_reason_code,l_temp1);
        OPEN val_reason_meaning_csr(l_string);
        FETCH val_reason_meaning_csr INTO l_meaning;
        IF(val_reason_meaning_csr%FOUND) THEN
          l_return_meaning := l_return_meaning || ' ' || l_meaning;
        END IF;
        CLOSE val_reason_meaning_csr;
        exit_flag := true;
      ELSE
        l_string := substr(p_defer_reason_code,l_temp1,l_temp2 - l_temp1);
        OPEN val_reason_meaning_csr(l_string);
        FETCH val_reason_meaning_csr INTO l_meaning;
        IF(val_reason_meaning_csr%FOUND) THEN
          l_return_meaning := l_return_meaning || ' ' || l_meaning;
        END IF;
        CLOSE val_reason_meaning_csr;
        l_index := l_index + 1;
        l_temp1 := l_temp2 + 1;
      END IF;
      EXIT WHEN exit_flag;
    END LOOP;
    RETURN l_return_meaning;

END getReasonCode;

END AHL_PRD_DF_APPR_PVT;--end package body

/

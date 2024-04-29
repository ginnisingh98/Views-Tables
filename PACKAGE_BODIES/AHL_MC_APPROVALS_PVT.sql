--------------------------------------------------------
--  DDL for Package Body AHL_MC_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_APPROVALS_PVT" AS
/* $Header: AHLVMWFB.pls 120.0 2005/05/26 10:59:35 appldev noship $ */

-- Define cursor to check MC with particular mc_header_id, object_version_number exists
CURSOR check_mc_exists(p_mc_header_id in number, p_object_version_number in number)
IS
	SELECT 	mc_header_id, name
	FROM 	ahl_mc_headers_b
	WHERE 	mc_header_id = p_mc_header_id and
	  	object_version_number = nvl(p_object_version_number, object_version_number);

PROCEDURE SET_ACTIVITY_DETAILS
(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
	,resultout   OUT  NOCOPY    VARCHAR2
)
IS

	l_object_id             NUMBER;
	l_object                VARCHAR2(30)    := 'MC';
	l_approval_type         VARCHAR2(30)    := 'CONCEPT';
	l_object_details        AHL_GENERIC_APRV_PVT.OBJRECTYP;
	l_approval_rule_id      NUMBER;
	l_approver_seq          NUMBER;
	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_subject               VARCHAR2(500);
	l_error_msg             VARCHAR2(2000);
	l_mc_header_id          NUMBER := 0;

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	fnd_msg_pub.initialize;

	l_return_status := FND_API.g_ret_sts_success;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	l_object_id := wf_engine.getitemattrnumber
	(
		 itemtype => itemtype
		,itemkey  => itemkey
		,aname    => 'OBJECT_ID'
	);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
			'OBJECT_ID='||l_object_id
		);
	END IF;

	l_object_details.operating_unit_id := NULL;
	l_object_details.priority := NULL;

	--
	-- RUN mode
	--

	IF (funcmode = 'RUN')
	THEN
		OPEN check_mc_exists(l_object_id, null);
		FETCH check_mc_exists into l_mc_header_rec;
		IF check_mc_exists%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
			fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
			fnd_message.set_token('NAME', l_mc_header_rec.NAME, false);
			fnd_msg_pub.add;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
					false
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE check_mc_exists;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_FORWARD_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'FORWARD_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'FORWARD_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_APPROVAL_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'APPROVAL_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'APPROVAL_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_REJECT_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'REJECT_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'REJECT_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_APPROVED_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'APPROVED_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'APPROVED_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_FINAL_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'FINAL_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'FINAL_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_REMIND_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'REMIND_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'REMIND_SUBJECT='||l_subject
			);
		END IF;

		fnd_message.set_name('AHL', 'AHL_MC_NTF_ERROR_SUBJECT');
		fnd_message.set_token('MC_HEADER_ID', l_mc_header_rec.mc_header_id, false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_subject := fnd_message.get;

		wf_engine.setitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'ERROR_SUBJECT'
			,avalue   => l_subject
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'ERROR_SUBJECT='||l_subject
			);
		END IF;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				'Calling AHL_GENERIC_APRV_PVT.GET_APPROVAL_DETAILS'
			);
		END IF;

		AHL_GENERIC_APRV_PVT.GET_APPROVAL_DETAILS
		(
			p_object             => l_object,
			p_approval_type      => l_approval_type,
			p_object_details     => l_object_details,
			x_approval_rule_id   => l_approval_rule_id,
			x_approver_seq       => l_approver_seq,
			x_return_status      => l_return_status
		);

		IF l_return_status = FND_API.g_ret_sts_success
		THEN
			wf_engine.setitemattrnumber
			(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'RULE_ID',
				avalue   => l_approval_rule_id
			);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
					'RULE_ID='||l_approval_rule_id
				);
			END IF;

			wf_engine.setitemattrnumber
			(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'APPROVER_SEQ',
				avalue   => l_approver_seq
			);

			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.string
				(
					fnd_log.level_statement,
					'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
					'APPROVER_SEQ='||l_approver_seq
				);
			END IF;

			resultout := 'COMPLETE:SUCCESS';
			RETURN;

		ELSE
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	--
	-- CANCEL mode
	--

	IF (funcmode = 'CANCEL')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	--
	-- TIMEOUT mode
	--

	IF (funcmode = 'TIMEOUT')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details.end',
			'At the end of PLSQL procedure'
		);
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.handle_error
		(
			p_itemtype          => itemtype   ,
			p_itemkey           => itemkey    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.Set_Activity_Details',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'SET_ACTIVITY_DETAILS',
			itemtype,
			itemkey,
			actid,
			funcmode,
			l_error_msg
		);
		resultout := 'COMPLETE:ERROR';

	WHEN OTHERS THEN
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'SET_ACTIVITY_DETAILS',
			itemtype,
			itemkey,
			actid,
			'Unexpected Error!'
		);
		RAISE;

END SET_ACTIVITY_DETAILS;

PROCEDURE NTF_FORWARD_FYI
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_approver            	VARCHAR2(30);
	l_body                	VARCHAR2(3500);
	l_object_id           	NUMBER;

	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FORWARD_FYI.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_approver := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'APPROVER'
	);

	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FORWARD_FYI',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_FWD_FYI_FWD');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('APPR_NAME',l_approver, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FORWARD_FYI',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FORWARD_FYI.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FORWARD_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_FORWARD_FYI',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;

	WHEN OTHERS THEN
		wf_core.context(
			'AHL_MC_APPROVAL_PVT',
			'NTF_FORWARD_FYI',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_FORWARD_FYI;

PROCEDURE NTF_APPROVED_FYI
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_approver            	VARCHAR2(30);
	l_body                	VARCHAR2(3500);
	l_object_id      	NUMBER;

	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVED_FYI.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_approver := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'APPROVER'
	);

	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVED_FYI',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_FWD_FYI_APPRVD');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('APPR_NAME',l_approver, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVED_FYI',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVED_FYI.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVED_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVED_API',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVED_API',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_APPROVED_FYI;

PROCEDURE NTF_FINAL_APPROVAL_FYI
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_body                	VARCHAR2(3500);
	l_object_id      	    NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FINAL_APPROVAL_FYI.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FINAL_APPROVAL_FYI',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_FWD_FYI_FINAL');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FINAL_APPROVAL_FYI',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FINAL_APPROVAL_FYI.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_FINAL_APPROVAL_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_FINAL_APPROVAL_FYI',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_FINAL_APPROVAL_FYI',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_FINAL_APPROVAL_FYI;


PROCEDURE NTF_REJECTED_FYI
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_approver            	VARCHAR2(30);
	l_body                	VARCHAR2(3500);
	l_object_id      	NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type   := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key    := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_approver := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'APPROVER'
	);

	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_FWD_FYI_RJCT');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('APPR_NAME',l_approver, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_REJECTED_FYI',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context(
			'AHL_MC_APPROVAL_PVT',
			'NTF_REJECTED_FYI',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_REJECTED_FYI;

PROCEDURE NTF_APPROVAL
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

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

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_requester := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'REQUESTER'
	);

	l_requester_note := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'REQUESTER_NOTE'
	);


	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_APPROVAL');
		fnd_message.set_token('REQUESTER',l_requester, false);
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('NOTE',l_requester_note, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_FYI',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_FYI.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVAL',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVAL',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_APPROVAL;

PROCEDURE NTF_APPROVAL_REMINDER
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

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

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_REMINDER.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_requester := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'REQUESTER'
	);

	l_requester_note := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'REQUESTER_NOTE'
	);


	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_REMINDER',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_REMIND');
		fnd_message.set_token('REQUESTER',l_requester, false);
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('NOTE',l_requester_note, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_REMINDER',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_REMINDER.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_APPROVAL_REMINDER',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVAL_REMINDER',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context(
			'AHL_MC_APPROVAL_PVT',
			'NTF_APPROVAL_REMINDER',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_APPROVAL_REMINDER;

PROCEDURE NTF_ERROR_ACT
(
	 document_id     IN       VARCHAR2
	,display_type    IN       VARCHAR2
	,document        IN OUT  NOCOPY VARCHAR2
	,document_type   IN OUT  NOCOPY VARCHAR2
)
IS

	l_hyphen_pos1         	NUMBER;
	l_object              	VARCHAR2(30);
	l_item_type           	VARCHAR2(30);
	l_item_key            	VARCHAR2(30);
	l_body                	VARCHAR2(3500);
	l_object_id           	NUMBER;
	l_error_msg           	VARCHAR2(4000);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_ERROR_ACT.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	document_type := 'text/plain';

	-- parse document_id for the ':' dividing item type name from item key value
	-- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
	-- release 2.5 version of this demo

	l_hyphen_pos1 := INSTR(document_id, ':');
	l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
	l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

	l_object := wf_engine.getitemattrtext
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_TYPE'
	);

	l_object_id := wf_engine.getitemattrNumber
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'OBJECT_ID'
	);

	l_error_msg := wf_engine.getitemattrText
	(
		 itemtype => l_item_type
		,itemkey  => l_item_key
		,aname    => 'ERROR_MSG'
	);

	OPEN check_mc_exists(l_object_id, null);
	FETCH check_mc_exists into l_mc_header_rec;

	IF check_mc_exists%NOTFOUND
	THEN
		fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_msg_pub.add;
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.message
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_ERROR_ACT',
				false
			);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		fnd_message.set_name('AHL', 'AHL_MC_NTF_ERROR_ACT');
		fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id ,false);
		fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
		fnd_message.set_token('ERR_MSG',l_error_msg, false);
		l_body := fnd_message.get;
	END IF;
	CLOSE check_mc_exists;

	document := document || l_body;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_ERROR_ACT',
			'document='||document
		);

		fnd_log.string
		(
			fnd_log.level_statement,
			'ahl.plsql.AHL_MC_Approvals_PVT.NTF_ERROR_ACT.end',
			'At the end of PLSQL procedure'
		);
	END IF;

	RETURN;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => l_item_type   ,
			p_itemkey           => l_item_key    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_ERROR_ACT',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_ERROR_ACT',
			l_item_type,
			l_item_key,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'NTF_ERROR_ACT',
			l_item_type,
			l_item_key
		);
		RAISE;

END NTF_ERROR_ACT;

PROCEDURE UPDATE_STATUS
(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
	,resultout   OUT    NOCOPY  VARCHAR2
)
IS

	l_error_msg                	VARCHAR2(4000);
	l_next_status          	    VARCHAR2(30);
	l_object_version_number    	NUMBER;
	l_object_id                	NUMBER;
	l_status_date              	DATE;
	l_msg_count             	NUMBER;
	l_msg_data              	VARCHAR2(4000);

	l_mc_header_rec check_mc_exists%ROWTYPE;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	--
	-- RUN Mode
	--
	IF (funcmode = 'RUN')
	THEN
		l_next_status := wf_engine.getitemattrtext
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'UPDATE_GEN_STATUS'
		);

		l_object_version_number := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_VER'
		);

		l_object_id := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_ID'
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS',
				'UPDATE_GEN_STATUS='||l_next_status||' -- OBJECT_VER='||l_object_version_number|| ' -- OBJECT_ID='||l_object_id
			);
		END IF;

		OPEN  check_mc_exists(l_object_id, l_object_version_number);
		FETCH check_mc_exists into l_mc_header_rec;

		IF check_mc_exists%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
			fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
			fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
			fnd_msg_pub.add;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS',
					false
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE check_mc_exists;

		UPDATE ahl_mc_headers_b
		SET 	config_status_code = l_next_status,
			object_version_number = l_object_version_number + 1,
			last_update_date = sysdate,
			last_updated_by = to_number(fnd_global.login_id),
			last_update_login = to_number(fnd_global.login_id)
		WHERE mc_header_id = l_object_id;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS',
				'Successfully completed the MC with mc_header_id='||l_object_id
			);
		END IF;

		resultout := 'COMPLETE:SUCCESS';
		RETURN;
	END IF;

	--
	-- CANCEL mode
	--
	IF (funcmode = 'CANCEL')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	--
	-- TIMEOUT mode
	--
	IF (funcmode = 'TIMEOUT')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS.end',
			'At the end of PLSQL procedure'
		);
	END IF;

EXCEPTION
	WHEN FND_API.g_exc_error THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => itemtype   ,
			p_itemkey           => itemkey    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.NTF_REJECTED_FYI',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'UPDATE_STATUS',
			itemtype,
			itemkey,
			actid,
			funcmode,
			l_error_msg
		);
		RAISE;

	WHEN OTHERS THEN
		wf_core.context(
			'AHL_MC_APPROVAL_PVT',
			'UPDATE_STATUS',
			itemtype,
			itemkey,
			actid,
			funcmode,
			l_error_msg
		);
		RAISE;

END UPDATE_STATUS;

PROCEDURE REVERT_STATUS
(
	 itemtype    IN       VARCHAR2
	,itemkey     IN       VARCHAR2
	,actid       IN       NUMBER
	,funcmode    IN       VARCHAR2
	,resultout   OUT    NOCOPY  VARCHAR2
)
IS

	l_error_msg                	VARCHAR2(4000);

	l_next_status              	VARCHAR2(30);
	l_object_version_number    	NUMBER;
	l_object_id                	NUMBER;
	l_status_date              	DATE;
	l_msg_count             	NUMBER;
	l_msg_data              	VARCHAR2(4000);

	l_mc_header_rec check_mc_exists%rowtype;

BEGIN

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.REVERT_STATUS.begin',
			'At the start of PLSQL procedure'
		);
	END IF;

	--
	-- RUN mode
	--
	IF (funcmode = 'RUN')
	THEN
		l_next_status := wf_engine.getitemattrText
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'ORG_STATUS_ID'
		);
		l_object_version_number := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_VER'
		);

		l_object_id := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_ID'
		);

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS',
				'ORG_STATUS_ID='||l_next_status||' -- OBJECT_VER='||l_object_version_number|| ' -- OBJECT_ID='||l_object_id
			);
		END IF;

		OPEN  check_mc_exists(l_object_id, l_object_version_number);
		FETCH check_mc_exists into l_mc_header_rec;

		IF check_mc_exists%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_MC_HEADER_ID_INVALID');
			fnd_message.set_token('MC_HEADER_ID',l_mc_header_rec.mc_header_id,false);
			fnd_message.set_token('NAME',l_mc_header_rec.NAME, false);
			fnd_msg_pub.add;
			IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
			THEN
				fnd_log.message
				(
					fnd_log.level_exception,
					'ahl.plsql.AHL_MC_Approvals_PVT.REVERT_STATUS',
					false
				);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE check_mc_exists;

		UPDATE ahl_mc_headers_b
		SET 	config_status_code = l_next_status,
			object_version_number = l_object_version_number + 1,
			last_update_date = sysdate,
			last_updated_by = to_number(fnd_global.login_id),
			last_update_login = to_number(fnd_global.login_id)
		WHERE mc_header_id = l_object_id;

		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_statement,
				'ahl.plsql.AHL_MC_Approvals_PVT.UPDATE_STATUS',
				'Successfully reverted status of the MC with mc_header_id='||l_object_id
			);
		END IF;

		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	--
	-- CANCEL mode
	--
	IF (funcmode = 'CANCEL')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	--
	-- TIMEOUT mode
	--
	IF (funcmode = 'TIMEOUT')
	THEN
		resultout := 'COMPLETE:';
		RETURN;
	END IF;

	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
	THEN
		fnd_log.string
		(
			fnd_log.level_procedure,
			'ahl.plsql.AHL_MC_Approvals_PVT.REVERT_STATUS.end',
			'At the end of PLSQL procedure'
		);
	END IF;

EXCEPTION
	WHEN FND_API.g_exc_error THEN
		FND_MSG_PUB.Count_And_Get
		(
			p_encoded => FND_API.G_FALSE,
			p_count => l_msg_count,
			p_data  => l_msg_data
		);
		AHL_GENERIC_APRV_PVT.Handle_Error
		(
			p_itemtype          => itemtype   ,
			p_itemkey           => itemkey    ,
			p_msg_count         => l_msg_count,
			p_msg_data          => l_msg_data ,
			p_attr_name         => 'ERROR_MSG',
			x_error_msg         => l_error_msg
		);
		IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
		THEN
			fnd_log.string
			(
				fnd_log.level_exception,
				'ahl.plsql.AHL_MC_Approvals_PVT.REVERT_STATUS',
				l_error_msg
			);
		END IF;
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT',
			'REVERT_STATUS',
			itemtype,
			itemkey,
			actid,
			funcmode,
			l_error_msg
		);
		RAISE;
	WHEN OTHERS THEN
		wf_core.context
		(
			'AHL_MC_APPROVAL_PVT'
			,'REVERT_STATUS'
			,itemtype
			,itemkey
			,actid
			,funcmode
			,'Unexpected Error!'
		);
		RAISE;

END REVERT_STATUS;

End AHL_MC_Approvals_PVT;

/

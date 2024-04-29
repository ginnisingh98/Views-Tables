--------------------------------------------------------
--  DDL for Package Body AHL_PC_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_PC_APPROVAL_PVT" AS
/* $Header: AHLVPWKB.pls 115.10 2003/10/20 19:37:07 sikumar noship $ */

--G_DEBUG VARCHAR2(1):=FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;

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
	l_object                VARCHAR2(30)    := 'PCWF';
	l_approval_type         VARCHAR2(30)    := 'CONCEPT';
	l_object_details        AHL_GENERIC_APRV_PVT.OBJRECTYP;
	l_approval_rule_id      NUMBER;
	l_approver_seq          NUMBER;
	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_subject               VARCHAR2(500);
	l_error_msg             VARCHAR2(2000);
	l_pc_header_id          NUMBER := 0;

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID, name
		from AHL_pc_headers_b
		where PC_HEADER_ID = c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
              	END IF;

		fnd_msg_pub.initialize;

		l_return_status := FND_API.g_ret_sts_success;

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- Begin');
              	END IF;

		l_object_id := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_ID'
		);

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- OBJECT_ID='||l_object_id);
              	END IF;

		l_object_details.operating_unit_id := NULL;
		l_object_details.priority := NULL;

		--
		-- RUN mode
		--

		IF (funcmode = 'RUN')
		THEN
			OPEN  GET_PC_HEADER_DET(l_object_id);
			FETCH GET_PC_HEADER_DET into l_pc_header_rec;
			IF GET_PC_HEADER_DET%NOTFOUND
			THEN
				fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
				fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
				fnd_message.set_token('NAME', l_pc_header_rec.NAME, false);
				l_subject := fnd_message.get;
			END IF;
			CLOSE GET_PC_HEADER_DET;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_FORWARD_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'FORWARD_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- FORWARD_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_APPROVAL_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'APPROVAL_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- APPROVAL_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_REJECT_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'REJECT_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- REJECT_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_APPROVED_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'APPROVED_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- APPROVED_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_FINAL_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'FINAL_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- FINAL_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_REMIND_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'REMIND_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- REMIND_SUBJECT='||l_subject);
              		END IF;

			fnd_message.set_name('AHL', 'AHL_PC_NTF_ERROR_SUBJECT');
			fnd_message.set_token('PC_HEADER_ID', l_pc_header_rec.PC_HEADER_ID, false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'ERROR_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- ERROR_SUBJECT='||l_subject);
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
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- Completed GET_APPROVAL_DETAILS');
              		END IF;

			IF l_return_status = FND_API.g_ret_sts_success
			THEN
				wf_engine.setitemattrnumber
				(
					itemtype => itemtype,
					itemkey  => itemkey,
					aname    => 'RULE_ID',
					avalue   => l_approval_rule_id
				);
				IF G_DEBUG='Y' THEN
		  		 AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- RULE_ID='||l_approval_rule_id);
              			END IF;

				wf_engine.setitemattrnumber
				(
					itemtype => itemtype,
					itemkey  => itemkey,
					aname    => 'APPROVER_SEQ',
					avalue   => l_approver_seq
				);
				IF G_DEBUG='Y' THEN
		  		 AHL_DEBUG_PUB.debug('PCWF -- SET_ACTIVITY_DETAILS -- APPROVER_SEQ='||l_approver_seq);
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
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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

		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_FWD_FYI_FWD');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_FORWARD_FYI -- document='||document);
              	END IF;

		COMMIT;
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_FORWARD_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;

		WHEN OTHERS THEN
			wf_core.context(
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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

		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_FWD_FYI_APPRVD');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_APPROVED_FYI -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_APPROVED_API',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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
	l_object_id      	NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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

		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_FWD_FYI_FINAL');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_FINAL_APPROVAL_FYI -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_FINAL_APPROVAL_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;


	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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

		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_FWD_FYI_RJCT');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_REJECTED_FYI -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_REJECTED_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;


	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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


		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_APPROVAL');
			fnd_message.set_token('REQUESTER',l_requester, false);
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('NOTE',l_requester_note, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_APPROVAL -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_APPROVAL',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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


		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_REMINDER');
			fnd_message.set_token('REQUESTER',l_requester, false);
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('NOTE',l_requester_note, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_APPROVAL_REMINDER -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_APPROVAL_REMINDER',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				'AHL_PC_APPROVAL_PVT',
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

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;


	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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

		/*
		-- Why were we doing this? INVALID is not a valid status.
		UPDATE AHL_PC_HEADERS_B
		SET STATUS='INVALID'
		WHERE PC_HEADER_ID=l_object_id;
		*/

		OPEN  GET_PC_HEADER_DET(l_object_id);
		FETCH GET_PC_HEADER_DET into l_pc_header_rec;

		IF GET_PC_HEADER_DET%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_PC_HEADER_ID_INVALID');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			l_body := fnd_message.get;
		ELSE
			fnd_message.set_name('AHL', 'AHL_PC_NTF_ERROR_ACT');
			fnd_message.set_token('PC_HEADER_ID',l_pc_header_rec.PC_HEADER_ID ,false);
			fnd_message.set_token('NAME',l_pc_header_rec.NAME, false);
			fnd_message.set_token('ERR_MSG',l_error_msg, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE GET_PC_HEADER_DET;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- NTF_ERROR_ACT -- document='||document);
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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
				'NTF_ERROR_ACT',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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
	l_next_status              	VARCHAR2(30);
	l_approval_status          	VARCHAR2(30);
	l_object_version_number    	NUMBER;
	l_object_id                	NUMBER;
	l_status_date              	DATE;
	l_msg_count             	NUMBER;
	l_msg_data              	VARCHAR2(4000);

	l_commit                	VARCHAR2(1) := FND_API.G_TRUE;
	l_pc_header_id          	NUMBER :=0;
	l_init_msg_list         	VARCHAR2(1) := FND_API.G_TRUE;
	l_validate_only         	VARCHAR2(1) := FND_API.G_TRUE;
	l_validation_level      	NUMBER := FND_API.G_VALID_LEVEL_FULL;
	l_module_type           	VARCHAR2(1);
	l_return_status			VARCHAR2(1);
	x_return_status         	VARCHAR2(2000);
	x_msg_count             	NUMBER;
	x_msg_data              	VARCHAR2(2000);
	l_pc_header_rec         	AHL_PC_HEADER_PUB.PC_HEADER_REC;
	l_default               	VARCHAR2(1) := FND_API.G_FALSE;

	CURSOR GET_PC_HEADER_DET(c_pc_header_id number)
	IS
		SELECT *
		FROM AHL_PC_HEADERS_VL
		WHERE PC_HEADER_ID = c_pc_header_id;

	l_pc_header_det GET_PC_HEADER_DET%ROWTYPE;

	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
              	END IF;

		--
		-- RUN Mode
		--
		IF (funcmode = 'RUN')
		THEN
			l_approval_status := wf_engine.getitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'UPDATE_GEN_STATUS'
			);
			IF G_DEBUG='Y' THEN
		  	  AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_approval_status='||l_approval_status);
              		END IF;

			/*
			IF l_approval_status = 'APPROVED'
			THEN
				l_next_status := wf_engine.getitemattrText
				(
					 itemtype => itemtype
					,itemkey  => itemkey
					,aname    => 'NEW_STATUS_ID'
				);
			ELSE
				l_next_status := wf_engine.getitemattrText
				(
					 itemtype => itemtype
					,itemkey => itemkey
					,aname => 'REJECT_STATUS_ID'
				);
			END IF;
			IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_next_status='||l_next_status);

	END IF;
			*/

			l_next_status := l_approval_status;

			l_object_version_number := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_VER'
			);
			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_object_version_number='||l_object_version_number);
              		END IF;

			l_object_id := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_ID'
			);
			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_object_id='||l_object_id);
              		END IF;

			l_status_date := SYSDATE;

			OPEN GET_PC_HEADER_DET(l_object_id);
			FETCH GET_PC_HEADER_DET INTO l_pc_header_det;
			CLOSE GET_PC_HEADER_DET;
			IF (l_pc_header_det.object_version_number <> l_object_version_number)
			THEN
				fnd_message.set_name('AHL', 'AHL_APRV_OBJ_CHANGED');
				fnd_msg_pub.add;
				l_msg_count := 1;
				l_return_status := FND_API.G_RET_STS_ERROR;
			ELSE
				l_pc_header_rec.PC_HEADER_ID := l_pc_header_det.PC_HEADER_ID;
				l_pc_header_rec.NAME := l_pc_header_det.NAME;
				l_pc_header_rec.DESCRIPTION := l_pc_header_det.DESCRIPTION;
				l_pc_header_rec.STATUS := l_next_status;
				l_pc_header_rec.PRODUCT_TYPE_CODE := l_pc_header_det.PRODUCT_TYPE_CODE;
				l_pc_header_rec.PRIMARY_FLAG := l_pc_header_det.PRIMARY_FLAG;
				l_pc_header_rec.ASSOCIATION_TYPE_FLAG := l_pc_header_det.ASSOCIATION_TYPE_FLAG;
				l_pc_header_rec.DRAFT_FLAG := l_pc_header_det.DRAFT_FLAG;
				l_pc_header_rec.LINK_TO_PC_ID := l_pc_header_det.LINK_TO_PC_ID;
				l_pc_header_rec.OBJECT_VERSION_NUMBER := l_object_version_number;
				l_pc_header_rec.ATTRIBUTE_CATEGORY := l_pc_header_det.ATTRIBUTE_CATEGORY;
				l_pc_header_rec.ATTRIBUTE1 := l_pc_header_det.ATTRIBUTE1;
				l_pc_header_rec.ATTRIBUTE2 := l_pc_header_det.ATTRIBUTE2;
				l_pc_header_rec.ATTRIBUTE3 := l_pc_header_det.ATTRIBUTE3;
				l_pc_header_rec.ATTRIBUTE4 := l_pc_header_det.ATTRIBUTE4;
				l_pc_header_rec.ATTRIBUTE5 := l_pc_header_det.ATTRIBUTE5;
				l_pc_header_rec.ATTRIBUTE6 := l_pc_header_det.ATTRIBUTE6;
				l_pc_header_rec.ATTRIBUTE7 := l_pc_header_det.ATTRIBUTE7;
				l_pc_header_rec.ATTRIBUTE8 := l_pc_header_det.ATTRIBUTE8;
				l_pc_header_rec.ATTRIBUTE9 := l_pc_header_det.ATTRIBUTE9;
				l_pc_header_rec.ATTRIBUTE10 := l_pc_header_det.ATTRIBUTE10;
				l_pc_header_rec.ATTRIBUTE11 := l_pc_header_det.ATTRIBUTE11;
				l_pc_header_rec.ATTRIBUTE12 := l_pc_header_det.ATTRIBUTE12;
				l_pc_header_rec.ATTRIBUTE13 := l_pc_header_det.ATTRIBUTE13;
				l_pc_header_rec.ATTRIBUTE14 := l_pc_header_det.ATTRIBUTE14;
				l_pc_header_rec.ATTRIBUTE15 := l_pc_header_det.ATTRIBUTE15;
				l_pc_header_rec.OPERATION_FLAG := 'U';
				l_pc_header_rec.COPY_ASSOS_FLAG := 'N';
				l_pc_header_rec.COPY_DOCS_FLAG := 'N';

				AHL_PC_HEADER_PVT.UPDATE_PC_HEADER
				(
					p_api_version           => 1.0,
					p_init_msg_list         => FND_API.G_FALSE,
					p_commit                => FND_API.G_TRUE,
					p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
					p_x_pc_header_rec	=> l_pc_header_rec,
					x_return_status         => x_return_status,
					x_msg_count             => x_msg_count,
					x_msg_data              => x_msg_data
				);
				IF G_DEBUG='Y' THEN
		  		 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- Completed AHL_PC_HEADER_PVT.UPDATE_PC_HEADER');
              	 		END IF;

				l_msg_count := x_msg_count;

				IF (l_msg_count > 0)
				THEN
					l_return_status := FND_API.G_RET_STS_ERROR;
				ELSE
					l_return_status := FND_API.G_RET_STS_SUCCESS;
				END IF;
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
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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
				'AHL_PC_APPROVAL_PVT',
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
	l_approval_status          	VARCHAR2(30);
	l_object_version_number    	NUMBER;
	l_object_id                	NUMBER;
	l_status_date              	DATE;
	l_msg_count             	NUMBER;
	l_msg_data              	VARCHAR2(4000);

	cursor GET_PC_HEADER_DET(c_pc_header_id number)
	is
		select PC_HEADER_ID,Name
		from AHL_PC_headers_b
		where PC_HEADER_ID=c_pc_header_id;

	l_pc_header_rec GET_PC_HEADER_DET%rowtype;


	BEGIN

		IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.ENABLE_DEBUG;
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
			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_next_status'||l_next_status);
              		END IF;

			l_object_version_number := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_VER'
			);
			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_object_version_number'||l_object_version_number);
              		END IF;

			l_object_id := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_ID'
			);
			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- l_object_id'||l_object_id);
              		END IF;

			l_status_date := SYSDATE;

			UPDATE AHL_PC_HEADERS_B
			SET STATUS = 'DRAFT',
			    OBJECT_VERSION_NUMBER = l_object_version_number + 1
			WHERE PC_HEADER_ID = l_object_id AND
			      OBJECT_VERSION_NUMBER = l_object_version_number;

			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('PCWF -- UPDATE_STATUS -- Completed reset of status');
              		END IF;

			COMMIT;

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
			)               ;
			wf_core.context
			(
				'AHL_PC_APPROVAL_PVT',
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
				'AHL_PC_APPROVAL_PVT'
				,'REVERT_STATUS'
				,itemtype
				,itemkey
				,actid
				,funcmode
				,'Unexpected Error!'
			);
			RAISE;

	END REVERT_STATUS;

END AHL_PC_APPROVAL_PVT;

/

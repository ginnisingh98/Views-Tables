--------------------------------------------------------
--  DDL for Package Body AHL_UC_WF_APPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_UC_WF_APPR_PVT" AS
/* $Header: AHLVUWFB.pls 115.2 2003/10/20 19:37:26 sikumar noship $ */

G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_UC_WF_APPR_PVT';

-- To check if AHL DEBUG is turned ON
--G_DEBUG 			VARCHAR2(1) 	:= FND_PROFILE.VALUE('AHL_API_FILE_DEBUG_ON');
G_DEBUG                VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;


CURSOR get_uc_header_det(c_uc_header_id in number)
IS
    SELECT unit_config_header_id, name, object_version_number, unit_config_status_code, active_uc_status_code
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id;

---------------------------
-- SET_ACTIVITY_DETAILS
---------------------------
PROCEDURE SET_ACTIVITY_DETAILS
	(
		 itemtype    IN       VARCHAR2
		,itemkey     IN       VARCHAR2
		,actid       IN       NUMBER
		,funcmode    IN       VARCHAR2
		,resultout   OUT  NOCOPY    VARCHAR2)
	IS
--
	l_object_id             NUMBER;
        l_object_version_number NUMBER;
	l_object                VARCHAR2(30) ;
	l_approval_type         VARCHAR2(30)    := 'CONCEPT';
	l_object_details        AHL_GENERIC_APRV_PVT.OBJRECTYP;
	l_approval_rule_id      NUMBER;
	l_approver_seq          NUMBER;
	l_return_status         VARCHAR2(1);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_subject               VARCHAR2(500);
	l_error_msg             VARCHAR2(2000);
        l_uc_header_rec         get_uc_header_det%rowtype;
--
BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Set Actvity Details');
        END IF;

        --Initiliaze message list
		fnd_msg_pub.initialize;

		l_return_status := FND_API.g_ret_sts_success;


		l_object_id := wf_engine.getitemattrnumber
		(
			 itemtype => itemtype
			,itemkey  => itemkey
			,aname    => 'OBJECT_ID'
		);
        IF G_DEBUG='Y' THEN
     	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS --> l_object_id='||l_object_id);
        END IF;

       l_object_version_number := wf_engine.getitemattrnumber
	   (
				 itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'OBJECT_VER'
	    );
    	IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS --> l_object_version_number='||l_object_version_number);
       	END IF;


		l_object_details.operating_unit_id := NULL;
		l_object_details.priority := NULL;

		--
		-- RUN mode
		--


		IF (funcmode = 'RUN') THEN

			OPEN  get_uc_header_det(l_object_id);
			FETCH get_uc_header_det into l_uc_header_rec;
			IF get_uc_header_det%NOTFOUND THEN
                fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
                fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
				RAISE FND_API.G_EXC_ERROR;
			END IF;
			CLOSE get_uc_header_det;

			--check if active uc status approval
			IF (l_uc_header_rec.active_uc_status_code = 'APPROVAL_PENDING') THEN
				l_object := 'UC_ACTST';
 		        ELSE
				l_object := 'UC';
 			END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_FORWARD_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'FORWARD_SUBJECT'
				,avalue   => l_subject
			);

			fnd_message.set_name('AHL', 'AHL_UC_NTF_APPROVAL_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'APPROVAL_SUBJECT'
				,avalue   => l_subject
			);
 			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- APPROVAL_SUBJECT='||l_subject);
            END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_REJECT_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'REJECT_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- REJECT_SUBJECT='||l_subject);
            END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_APPROVED_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'APPROVED_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- APPROVED_SUBJECT='||l_subject);
            END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_FINAL_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'FINAL_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- FINAL_SUBJECT='||l_subject);
            END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_REMIND_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'REMIND_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- REMIND_SUBJECT='||l_subject);
            END IF;

			fnd_message.set_name('AHL', 'AHL_UC_NTF_ERROR_SUBJECT');
			fnd_message.set_token('UC_HEADER_ID', l_uc_header_rec.unit_config_header_id, false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_subject := fnd_message.get;

			wf_engine.setitemattrtext
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'ERROR_SUBJECT'
				,avalue   => l_subject
			);
			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- ERROR_SUBJECT='||l_subject);
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


			IF l_return_status = FND_API.g_ret_sts_success THEN

				wf_engine.setitemattrnumber
				(
					itemtype => itemtype,
					itemkey  => itemkey,
					aname    => 'RULE_ID',
					avalue   => l_approval_rule_id
				);
				IF G_DEBUG='Y' THEN
		  		    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- RULE_ID='||l_approval_rule_id);
              	END IF;

				wf_engine.setitemattrnumber
				(
					itemtype => itemtype,
					itemkey  => itemkey,
					aname    => 'APPROVER_SEQ',
					avalue   => l_approver_seq
				);
				IF G_DEBUG='Y' THEN
		  		    AHL_DEBUG_PUB.debug('UC: SET_ACTIVITY_DETAILS -- APPROVER_SEQ='||l_approver_seq);
                    AHL_DEBUG_PUB.debug('UC:End Set Actvity Details');
                    AHL_DEBUG_PUB.disable_debug;
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
            IF G_DEBUG='Y' THEN
	            AHL_DEBUG_PUB.disable_debug;
            END IF;

			RETURN;
		END IF;

		--
		-- TIMEOUT mode
		--

		IF (funcmode = 'TIMEOUT')
		THEN
			resultout := 'COMPLETE:';

            IF G_DEBUG='Y' THEN
	            AHL_DEBUG_PUB.disable_debug;
            END IF;

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
				G_PKG_NAME,
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
				G_PKG_NAME,
				'SET_ACTIVITY_DETAILS',
				itemtype,
				itemkey,
				actid,
				'Unexpected Error!'
			);
			RAISE;

	END SET_ACTIVITY_DETAILS;

    -----------------------------
    -- NTF_FORWARD_FYI
    -----------------------------
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

	l_uc_header_rec         get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Notify Forward');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_FORWARD_FYI -- l_approver='||l_approver);
        END IF;

		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_FWD_FYI_FWD');
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_FORWARD_FYI -- document='||document);
        END IF;


        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'UC:END Notify Forward, l_object_id =' || l_object_id );
		    AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_FORWARD_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;

		WHEN OTHERS THEN
			wf_core.context(
				G_PKG_NAME,
				'NTF_FORWARD_FYI',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_FORWARD_FYI;

    -----------------------------
    -- NTF_APPROVED_FYI
    -----------------------------
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
	l_object_id      	    NUMBER;

	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Notify Approved FYI');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC:  NTF_APPROVED_FYI -- l_approver='||l_approver);
        END IF;

		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_FWD_FYI_APPRVD');
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC:  NTF_APPROVED_FYI -- document='||document);
        END IF;

        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug( 'UC:END Notify Approved FYI, l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_APPROVED_API',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				G_PKG_NAME,
				'NTF_APPROVED_API',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_APPROVED_FYI;

    --------------------------------
    --  NTF_FINAL_APPROVAL_FYI
    --------------------------------
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
    l_approver              VARCHAR2(30);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'Start NTF Final approval');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_FINAL_APPROVAL_FYI -- l_approver='||l_approver);
        END IF;

		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_FWD_FYI_FINAL');
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_FINAL_APPROVAL_FYI -- document='||document);
        END IF;

        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug( 'END UC NTF Final approval , l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_FINAL_APPROVAL_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				G_PKG_NAME,
				'NTF_FINAL_APPROVAL_FYI',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_FINAL_APPROVAL_FYI;

    ---------------------------
    -- NTF_REJECTED_FYI
    ---------------------------
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
	l_object_id      	    NUMBER;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(4000);
	l_error_msg             VARCHAR2(2000);

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Notify Rejected');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC:NTF_REJECTED_FYI -- l_approver='||l_approver);
        END IF;


		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_FWD_FYI_RJCT');
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('APPR_NAME',l_approver, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC:NTF_REJECTED_FYI -- document='||document);
        END IF;


        IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'UC:End Notify Rejected, l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_REJECTED_FYI',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				G_PKG_NAME,
				'NTF_REJECTED_FYI',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_REJECTED_FYI;

    ------------------------
    -- NTF_APPROVAL
    ------------------------
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

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC: Start Nty_approval');
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
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug('UC: NTF_APPROVAL --> l_requester='||l_requester);
       	END IF;
		l_requester_note := wf_engine.getitemattrtext
		(
			 itemtype => l_item_type
			,itemkey  => l_item_key
			,aname    => 'REQUESTER_NOTE'
		);


		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_APPROVAL');
			fnd_message.set_token('REQUESTER',l_requester, false);
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('NOTE',l_requester_note, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_APPROVAL -- document='||document);
        END IF;

		IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'UC: END Nty_approval, l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_APPROVAL',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				G_PKG_NAME,
				'NTF_APPROVAL',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_APPROVAL;

    -------------------------------
    -- NTF_APPROVAL_REMINDER
    -------------------------------
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

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'Start ntfy Apprvl remainder');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_APPROVAL_REMINDER -- l_requester='||l_requester);
        END IF;

		l_requester_note := wf_engine.getitemattrtext
		(
			 itemtype => l_item_type
			,itemkey  => l_item_key
			,aname    => 'REQUESTER_NOTE'
		);


		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_REMIND');
			fnd_message.set_token('REQUESTER',l_requester, false);
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('NOTE',l_requester_note, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC:  NTF_APPROVAL_REMINDER -- document='||document);
        END IF;

        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug( 'END ntfy Apprvl remainder, l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_APPROVAL_REMINDER',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context(
				G_PKG_NAME,
				'NTF_APPROVAL_REMINDER',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_APPROVAL_REMINDER;

    -------------------------
    --  NTF_ERROR_ACT
    --------------------------
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

	l_uc_header_rec get_uc_header_det%rowtype;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'Start Ntfy error');
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
        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_ERROR_ACT -- l_error_msg='||l_error_msg);
        END IF;

		OPEN  get_uc_header_det(l_object_id);
		FETCH get_uc_header_det into l_uc_header_rec;

		IF get_uc_header_det%NOTFOUND
		THEN
			fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			fnd_message.set_name('AHL', 'AHL_UC_NTF_ERROR_ACT');
			fnd_message.set_token('UC_HEADER_ID',l_uc_header_rec.unit_config_header_id ,false);
			fnd_message.set_token('NAME',l_uc_header_rec.name, false);
			fnd_message.set_token('ERR_MSG',l_error_msg, false);
			l_body := fnd_message.get;
		END IF;
		CLOSE get_uc_header_det;

		document := document || l_body;
		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug('UC: NTF_ERROR_ACT -- document='||document);
        END IF;

        IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.debug( 'END UC Ntfy error , l_object_id =' || l_object_id );
            AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
				'NTF_ERROR_ACT',
				l_item_type,
				l_item_key,
				l_error_msg
			);
			RAISE;
		WHEN OTHERS THEN
			wf_core.context
			(
				G_PKG_NAME,
				'NTF_ERROR_ACT',
				l_item_type,
				l_item_key
			);
			RAISE;

	END NTF_ERROR_ACT;

    ------------------------
    --  UPDATE_STATUS
    ------------------------
	PROCEDURE UPDATE_STATUS
	(
		 itemtype    IN       VARCHAR2
		,itemkey     IN       VARCHAR2
		,actid       IN       NUMBER
		,funcmode    IN       VARCHAR2
		,resultout   OUT    NOCOPY  VARCHAR2
	)
	IS


    CURSOR check_uc_ovn(c_uc_header_id in number, c_object_version_number in number)
    IS
    SELECT unit_config_header_id, name, unit_config_status_code, active_uc_status_code
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id
        AND object_version_number = c_object_version_number;


	l_uc_header_rec get_uc_header_det%ROWTYPE;
    l_check_uc_ovn check_uc_ovn%ROWTYPE;

    l_error_msg                	VARCHAR2(4000);
	l_object_version_number    	NUMBER;
	l_object_id                	NUMBER;

    l_approval_status      VARCHAR2(30);
    l_original_status      VARCHAR2(30);

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Update Status API');
        END IF;

		--
		-- RUN Mode
		--
		IF (funcmode = 'RUN') THEN

			l_approval_status := wf_engine.getitemattrtext
			(
				 itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'UPDATE_GEN_STATUS'
			);


        	IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: UPDATE_STATUS -- l_approval_status='||l_approval_status);
            END IF;

       /*     l_original_status := wf_engine.getitemattrtext
			(
				 itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORIG_STATUS_ID'
			);
            IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: UPDATE_STATUS -- l_original_status='||l_original_status);
            END IF;
        */
			l_object_version_number := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'OBJECT_VER'
			);

			IF G_DEBUG='Y' THEN
     	        AHL_DEBUG_PUB.debug('UC: UPDATE_STATUS --> l_object_version_number='||l_object_version_number);
        	END IF;

			l_object_id := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'OBJECT_ID'
			);

			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: UPDATE_STATUS --> l_object_id='||l_object_id);
            END IF;

            OPEN  get_uc_header_det(l_object_id);
            FETCH get_uc_header_det into l_uc_header_rec;

            IF get_uc_header_det%NOTFOUND
		    THEN
			    fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			    fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			    RAISE FND_API.G_EXC_ERROR;
		    END IF;
		    CLOSE get_uc_header_det;


			OPEN  check_uc_ovn(l_object_id, l_object_version_number);
			FETCH check_uc_ovn into l_check_uc_ovn;

			IF check_uc_ovn%NOTFOUND THEN

				fnd_message.set_name('AHL', 'AHL_COM_RECORD_CHANGED');

                IF G_DEBUG='Y' THEN
		  	        AHL_DEBUG_PUB.debug('UC: UPDATE_STATUS check_uc_ovn --> fnd_message='||fnd_message.get );
                END IF;

				RAISE FND_API.G_EXC_ERROR;
			END IF;
           CLOSE check_uc_ovn;

            AHL_GENERIC_APRV_PVT.Handle_Error
			(
				p_itemtype          => itemtype   ,
				p_itemkey           => itemkey    ,
				p_msg_count         => l_msg_count,
				p_msg_data          => l_msg_data ,
				p_attr_name         => 'ERROR_MSG',
				x_error_msg         => l_error_msg
			);

         IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug('UC:AHL_UC_WF_APPR_PVT.update_status -->l_msg_count...... ' || l_msg_count);
            AHL_DEBUG_PUB.debug('UC:AHL_UC_WF_APPR_PVT.update_status -->l_error_msg...... ' || l_error_msg);
            AHL_DEBUG_PUB.debug('UC:AHL_UC_WF_APPR_PVT.update_status -->l_msg_data...... ' || l_msg_data);
            AHL_DEBUG_PUB.debug('UC:AHL_UC_WF_APPR_PVT.update_status --> Before call to complete_uc_approval ');
		 END IF;

			--CALL AHL_UC_APPROVALS_PVT.complete_uc_approvals
            AHL_UC_APPROVALS_PVT.complete_uc_approval(
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_TRUE,
                p_commit                => FND_API.G_TRUE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                p_uc_header_id          => l_object_id,
                p_object_version_number => l_object_version_number,
                p_approval_status       => l_approval_status,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data
              );


			IF G_DEBUG='Y' THEN
                AHL_DEBUG_PUB.debug('SQLERRM' || SQLERRM );
                AHL_DEBUG_PUB.debug('l_return_status' || l_return_status);
                AHL_DEBUG_PUB.debug('l_msg_count' || l_msg_count);
                AHL_DEBUG_PUB.debug('l_msg_data' || l_msg_data);
				AHL_DEBUG_PUB.debug('UC:AHL_UC_WF_APPR_PVT.update_status -- Completed call to complete_uc_approval ');
			END IF;

            IF G_DEBUG='Y' THEN
		        AHL_DEBUG_PUB.debug( 'UC:End Update Status API, l_object_id =' || l_object_id );
                AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
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
				G_PKG_NAME,
				'UPDATE_STATUS',
				itemtype,
				itemkey,
				actid,
				funcmode,
				l_error_msg
			);
			RAISE;

	END UPDATE_STATUS;


    -------------------------
    -- REVERT_STATUS
    -------------------------
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

	CURSOR check_uc_ovn(c_uc_header_id in number, c_object_version_number in number)
    IS
    SELECT unit_config_header_id, name, unit_config_status_code, active_uc_status_code
    FROM ahl_unit_config_headers
    WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
        AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1))
        AND unit_config_header_id = c_uc_header_id
        AND object_version_number = c_object_version_number;


	l_uc_header_rec get_uc_header_det%ROWTYPE;
    l_check_uc_ovn check_uc_ovn%ROWTYPE;

	BEGIN

		IF G_DEBUG='Y' THEN
		    AHL_DEBUG_PUB.ENABLE_DEBUG;
            AHL_DEBUG_PUB.debug( 'UC:Start Revert Status');
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
		  	    AHL_DEBUG_PUB.debug('UC: REVERT_STATUS -- l_next_status'||l_next_status);
            END IF;

			l_object_version_number := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_VER'
			);

			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('UC: REVERT_STATUS -- l_object_version_number'||l_object_version_number);
            END IF;

			l_object_id := wf_engine.getitemattrnumber
			(
				 itemtype => itemtype
				,itemkey  => itemkey
				,aname    => 'OBJECT_ID'
			);

			IF G_DEBUG='Y' THEN
		  	    AHL_DEBUG_PUB.debug('UC: REVERT_STATUS -- l_object_id'||l_object_id);
            END IF;

			OPEN  get_uc_header_det(l_object_id);
            FETCH get_uc_header_det into l_uc_header_rec;

            IF get_uc_header_det%NOTFOUND
		    THEN
			    fnd_message.set_name('AHL', 'AHL_UC_HEADER_ID_INVALID');
			    fnd_message.set_token('UC_HEADER_ID', l_object_id, false);
			    RAISE FND_API.G_EXC_ERROR;
		    END IF;
		    CLOSE get_uc_header_det;


			OPEN  check_uc_ovn(l_object_id, l_object_version_number);
			FETCH check_uc_ovn into l_check_uc_ovn;

			IF check_uc_ovn%NOTFOUND
			THEN
				fnd_message.set_name('AHL', 'AHL_COM_RECORD_CHANGED');
				RAISE FND_API.G_EXC_ERROR;
			END IF;


            IF (l_check_uc_ovn.unit_config_status_code = 'APPROVAL_PENDING') THEN

			    UPDATE ahl_unit_config_headers
			    SET unit_config_status_code = l_next_status,
				    object_version_number = l_object_version_number + 1,
				    last_update_date = sysdate,
				    last_updated_by = to_number(fnd_global.login_id),
				    last_update_login = to_number(fnd_global.login_id)
			    WHERE unit_config_header_id = l_object_id;

             ELSIF (l_check_uc_ovn.active_uc_status_code = 'APPROVAL_PENDING') THEN

                UPDATE ahl_unit_config_headers
			    SET active_uc_status_code = l_next_status,
				    object_version_number = l_object_version_number + 1,
				    last_update_date = sysdate,
				    last_updated_by = to_number(fnd_global.login_id),
				    last_update_login = to_number(fnd_global.login_id)
			    WHERE unit_config_header_id = l_object_id;

             END IF;
            CLOSE check_uc_ovn;

			IF G_DEBUG='Y' THEN
		  	 AHL_DEBUG_PUB.debug('UC: REVERT_STATUS --> Completed resetting of status');
             AHL_DEBUG_PUB.debug('UC:END Revert Status, l_object_id =' || l_object_id );
             AHL_DEBUG_PUB.DISABLE_DEBUG;
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
				G_PKG_NAME,
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
				G_PKG_NAME,
				'REVERT_STATUS',
				itemtype,
				itemkey,
				actid,
				funcmode,
				'Unexpected Error!'
			);
			RAISE;

	END REVERT_STATUS;

END AHL_UC_WF_APPR_PVT;

/

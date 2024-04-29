--------------------------------------------------------
--  DDL for Package Body AP_IAW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_IAW_PKG" AS
/* $Header: apiawleb.pls 120.14 2006/04/07 14:10:24 vdesu noship $ */

--------------------------------------------------------------
--                     Types
--------------------------------------------------------------
TYPE rLineApproverMappings IS RECORD (
  line_number           NUMBER,
  approver_id           NUMBER,
  role_name             VARCHAR2(320));

TYPE tLineApprovers IS TABLE OF rLineApproverMappings
	INDEX BY BINARY_INTEGER;

--------------------------------------------------------------
--                    Global Variables                      --
--------------------------------------------------------------
  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_IAW_PKG';
  G_MSG_UERROR        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  -- TODO
  -- G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  -- G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT       CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_IAW_PKG';

-- get max notification iteration
-- invoice_key is invoice_id + invoice_iteration from ap_apinv_approvers
FUNCTION get_max_notif_iteration(p_invoice_key IN VARCHAR2)
  RETURN NUMBER IS

  l_notif_iter    NUMBER;
  l_debug_info	  VARCHAR2(2000);
  l_api_name      VARCHAR2(200) := 'get_max_notif_iteration';

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

   	-- get max notification iteration
	SELECT nvl(max(notification_iteration),0) + 1
	INTO l_notif_iter
	FROM AP_APINV_APPROVERS
	WHERE Invoice_Key = p_invoice_key;

	l_debug_info := 'invoice_key = ' || p_invoice_key ||
	 ', and current max notification iteration = ' || l_notif_iter;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

  	RETURN l_notif_iter;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'get_max_notif_iteration');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END get_max_notif_iteration;

--------------------------------------------------------------
--  Public Procedures called from WF process
--------------------------------------------------------------

/*This procedure is called from APINVLDP, the Check Header Requirements function
 node.  Its purpose is to stop the workflow if the invoice does not meet the
criteria defined by the user.   The two criteria that the users can set through
 AME attributes are Require Tax Calculation and Approve Matched Invoices. */

PROCEDURE Check_Header_Requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	l_result 	ame_util.stringlist;
	l_reason 	ame_util.stringlist;
	l_invoice_id	NUMBER;
	l_h_hist	ap_iaw_pkg.r_inv_aprvl_hist;
	l_tr_reason	VARCHAR2(240);
	l_api_name	CONSTANT VARCHAR2(200) := 'Check_Header_Requirements';
	l_org_id	NUMBER;
	l_rejected_check	BOOLEAN  := FALSE;
	l_required_check	BOOLEAN  := TRUE;
	l_iteration	NUMBER;
	l_amount	NUMBER;
	l_debug_info	VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	l_debug_info := 'get invoice amount';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	SELECT invoice_amount
	INTO l_amount
	FROM ap_invoices_all
	WHERE invoice_id = l_invoice_id;

	l_debug_info := 'check AME if production rules should prevent approval';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
        END IF;

	ame_api2.getTransactionProductions(applicationIdIn => 200,
		transactionIdIn     => to_char(l_invoice_id),
		transactionTypeIn =>  'APINV',
		variableNamesOut => l_result,
		variableValuesOut => l_reason);

	IF l_result IS NOT NULL THEN
		l_debug_info := 'loop through production results';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
						l_api_name,l_debug_info);
        	END IF;
		FOR i IN 1..l_result.count LOOP

			IF l_result(i) = 'NO INVOICE APPROVAL REQUIRED' THEN


				--set required flag
				l_required_check := FALSE;


				l_debug_info := 'get translation of reason';
				IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        			END IF;

				SELECT displayed_field
				into l_tr_reason
                       		FROM   ap_lookup_codes
                       		WHERE  lookup_code = l_reason(i)
                       		and    lookup_type = 'NLS TRANSLATION';


				l_debug_info := 'populate history record';
				IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        			END IF;

				l_h_hist.invoice_id := l_invoice_id;
				l_h_hist.iteration := l_iteration;
				l_h_hist.response := 'APPROVED';
				l_h_hist.approver_comments := l_tr_reason;
				l_h_hist.approver_id :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_h_hist.org_id := l_org_id;
				l_h_hist.created_by :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_h_hist.creation_date := sysdate;
				l_h_hist.last_update_date := sysdate;
				l_h_hist.last_updated_by :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_h_hist.last_update_login := -1;
				l_h_hist.amount_approved := l_amount;


				Insert_Header_History(
					p_inv_aprvl_hist => l_h_hist);

				l_debug_info := 'Set transaction statuses';
				IF (G_LEVEL_STATEMENT >=
                                                G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
                                        l_api_name,l_debug_info);
                                END IF;

				UPDATE AP_INVOICES_ALL
				SET WFApproval_Status = 'NOT REQUIRED'
				WHERE Invoice_Id = l_invoice_id
				AND WFApproval_Status = 'INITIATED';

				UPDATE AP_INVOICE_LINES_ALL
				SET WFApproval_Status = 'NOT REQUIRED'
				WHERE Invoice_Id = l_invoice_id
				AND WFApproval_Status = 'INITIATED';

				resultout := wf_engine.eng_completed||':'||'N';

				--we do not care if there are anymore
				--productions
				EXIT;

			ELSIF l_result(i) = 'INVOICE NOT READY' THEN

				--we need to know if header was rejected by
				--check
				l_rejected_check := TRUE;

				l_debug_info := 'get translated reason value';
				IF (G_LEVEL_STATEMENT >=
                                                G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
                                        l_api_name,l_debug_info);
                                END IF;

				SELECT l_tr_reason || ', ' || displayed_field
                                into l_tr_reason
                                FROM   ap_lookup_codes
                                WHERE  lookup_code = l_reason(i)
                                and    lookup_type = 'NLS TRANSLATION';

			END IF; --results
		END LOOP; -- production string lists

		IF l_required_check = TRUE and l_rejected_check = TRUE THEN

			l_debug_info := 'populate history record';
                        IF (G_LEVEL_STATEMENT >=
                                  G_CURRENT_RUNTIME_LEVEL) THEN
                       	            FND_LOG.STRING(G_LEVEL_STATEMENT,
						G_MODULE_NAME||
                                             l_api_name,l_debug_info);
                        END IF;
                        l_h_hist.invoice_id := l_invoice_id;
                        l_h_hist.iteration := l_iteration;
                        l_h_hist.response := 'REJECTED';
                        l_h_hist.approver_comments := l_tr_reason;
                        l_h_hist.approver_id :=
                                FND_PROFILE.VALUE('AP_IAW_USER');
                        l_h_hist.org_id := l_org_id;
			l_h_hist.created_by :=
                                        FND_PROFILE.VALUE('AP_IAW_USER');
                        l_h_hist.creation_date := sysdate;
                        l_h_hist.last_update_date := sysdate;
                        l_h_hist.last_updated_by :=
                                        FND_PROFILE.VALUE('AP_IAW_USER');
                        l_h_hist.last_update_login := -1;
                        l_h_hist.amount_approved := l_amount;

                        Insert_Header_History(
                                p_inv_aprvl_hist => l_h_hist);

                        UPDATE AP_INVOICES_ALL
                        SET WFApproval_Status = 'REJECTED'
                        WHERE Invoice_Id = l_invoice_id
                        AND WFApproval_Status = 'INITIATED';

                        UPDATE AP_INVOICE_LINES_ALL
                        SET WFApproval_Status = 'REJECTED'
                        WHERE Invoice_Id = l_invoice_id
                        AND WFApproval_Status = 'INITIATED';

			resultout := wf_engine.eng_completed||':'||'N';
		END IF; --required and rejected

	ELSE --there were no production results

		l_debug_info := 'continue with workflow';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                                               l_api_name,l_debug_info);
                END IF;
		resultout := wf_engine.eng_completed||':'||'Y';

	END IF;

	resultout := nvl(resultout, wf_engine.eng_completed||':'||'Y');

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Check_Header_Requirements',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Check_Header_Requirements;

/*This procedure checks whether the lines will meet the user defined
requirements for proceeding with approval.  Currently, the only requirement
users can define, is whether a matched line should go through the approval
process.*/

PROCEDURE Check_Line_Requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	CURSOR matched_lines (l_invoice_id IN VARCHAR2) IS
	   SELECT line_number, amount
	   FROM ap_invoice_lines_all
	   WHERE po_header_id is not null
	   AND invoice_id = l_invoice_id
	   AND wfapproval_status = 'INITIATED';

	l_result 	ame_util.stringlist;
	l_reason 	ame_util.stringlist;
	l_invoice_id	NUMBER;
	l_l_hist	ap_iaw_pkg.r_line_aprvl_hist;
	l_tr_reason	VARCHAR2(240);
	l_api_name	CONSTANT VARCHAR2(200) := 'Check_Line_Requirements';
	l_org_id	NUMBER;
	l_required_check	BOOLEAN  := TRUE;
	l_iteration	NUMBER;
	l_amount	NUMBER;
	l_debug_info	VARCHAR2(2000);
	l_line_number   NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	--check AME if any production rules should prevent approval

	ame_api2.getTransactionProductions(applicationIdIn => 200,
		transactionIdIn     => to_char(l_invoice_id),
		transactionTypeIn =>  'APINV',
		variableNamesOut => l_result,
		variableValuesOut => l_reason);


	--current hack because AME allows us to set production conditions
	--at the line level, but the production results are always at the
	--transaction level.
	--So we are looking for line level production pairs, but
	--we will still need to identify which lines apply.
	IF l_result IS NOT NULL THEN
	   --loop through production results
	   FOR i IN 1..l_result.count LOOP
		IF l_result(i) = 'NO LINE APPROVAL REQUIRED' THEN

		   IF l_reason(i) = 'LINE MATCHED' THEN

		  	l_debug_info := 'get translation';
			IF (G_LEVEL_STATEMENT >=
						G_CURRENT_RUNTIME_LEVEL) THEN
          		   FND_LOG.STRING(G_LEVEL_STATEMENT,
					G_MODULE_NAME||
					l_api_name,l_debug_info);
        		END IF;

			SELECT displayed_field
			into l_tr_reason
               		FROM   ap_lookup_codes
               		WHERE  lookup_code = l_reason(i)
               		and    lookup_type = 'NLS TRANSLATION';

			OPEN matched_lines(l_invoice_id);
			LOOP
			   FETCH matched_lines
			   INTO l_line_number, l_amount;

			   EXIT WHEN matched_lines %NOTFOUND;
				--populate history record
				l_l_hist.invoice_id := l_invoice_id;
				l_l_hist.iteration := l_iteration;
				l_l_hist.response := 'APPROVED';
				l_l_hist.approver_comments := l_tr_reason;
				l_l_hist.approver_id :=
			        	FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.org_id := l_org_id;
				l_l_hist.line_number := l_line_number;
				l_l_hist.line_amount_approved :=
						l_amount;
			 	l_l_hist.created_by :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.creation_date := sysdate;
				l_l_hist.last_updated_by :=
					FND_PROFILE.VALUE('AP_IAW_USER');
				l_l_hist.last_update_date := sysdate;
				l_l_hist.last_update_login := -1;
				l_l_hist.item_class := 'APINV';
				l_l_hist.item_id := l_invoice_id;

				Insert_Line_History(
					p_line_aprvl_hist => l_l_hist);
			END LOOP; --matched lines

			--Set transaction statuses
			UPDATE AP_INVOICE_LINES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND PO_Header_Id IS NOT NULL
			AND WFApproval_Status = 'INITIATED';

			--setting counter to end because we get
			--production pairs at the transaction level
			--but are checking for line requirements
			--Therefore, once we fix all the lines above
			--we do not need to check for any other line
			--production pairs.
			EXIT;
		   END IF; --reason
		END IF; --results
	   END LOOP; -- production string lists
	END IF; --productions

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Check_Line_Requirements',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Check_Line_Requirements;

/*This procedure will group items to be approved by the approver names in
AP_APINV_APPROVERS that receive notifications in parallel.  The records in
 AP_APINV_APPROVERS are then stamped by their grouping, and Identify_Approver
 chooses one to be sent first.  This procedure is called several times, in a
loop that sends out all the notifications needed.*/

PROCEDURE Identify_Approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	l_invoice_id	NUMBER;
	l_iteratation	NUMBER;
	l_not_iteration	NUMBER;
	l_pend		NUMBER;
	l_sent		NUMBER;
	l_comp		NUMBER;
	l_name		VARCHAR2(320);
 	l_api_name	CONSTANT VARCHAR2(200) := 'Identify_Approver';
	l_iteration	NUMBER;
	l_debug_info	VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.identify_approver (+)');
        END IF;

	l_debug_info := 'get variables from workflow: itemtype = ' || itemtype ||
			', itemkey = ' || itemkey;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	l_debug_info := l_api_name ||': invoice_id = ' || l_invoice_id ||
			', iteration = ' || l_iteration;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	--check for pending approvers
	--amy also could use orig system and id instead of name
	BEGIN
		SELECT 1, Role_Name
		INTO l_pend, l_name
		FROM AP_APINV_APPROVERS
		WHERE Notification_Status = 'PEND'
		AND Invoice_Key = itemkey
		AND rownum = 1;

		EXCEPTION
      		WHEN NO_DATA_FOUND THEN
         		l_pend := 0;
    	END;
	l_debug_info := l_api_name ||': pend = ' || l_pend ||
			', role_name = ' || l_name;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	IF l_pend > 0 THEN

		--get max notification iteration
		SELECT nvl(max(notification_iteration),0) + 1
		INTO l_not_iteration
		FROM AP_APINV_APPROVERS
		WHERE Invoice_Key = itemkey;

	      	l_debug_info := l_api_name ||': get max notification iteration';
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        	END IF;

		--set values for grouping
		UPDATE AP_APINV_APPROVERS
		SET Notification_Iteration = l_not_iteration
		    ,Notification_Key = itemkey || '_' || l_not_iteration
		WHERE Role_Name = l_name
		AND Invoice_Key = itemkey;

		--set notification attributes in wf
		set_attribute_values(itemtype,itemkey);

		resultout := 'MORE';
	ELSE -- no pending

		BEGIN
			--check for any notifications for invoice key
			SELECT sum(DECODE(Notification_Status, 'SENT', 1, 0)),
			sum(DECODE(Notification_Status, 'COMP', 1, 0))
			INTO l_sent, l_comp
			FROM AP_APINV_APPROVERS
			WHERE Invoice_Key = itemkey
			GROUP BY Invoice_Key;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
                	l_sent := 0;
			l_comp := 0;
        	END;
		l_debug_info := l_api_name ||': sent = ' || l_sent ||
			', complete = ' || l_comp;
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        	END IF;

		--None sent at all
		IF l_sent = 0 and l_comp = 0 THEN

			--Set transaction statuses
			UPDATE AP_INVOICES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND WFApproval_Status = 'INITIATED';

			UPDATE AP_INVOICE_LINES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND WFApproval_Status = 'INITIATED';

			--clear process records
			DELETE FROM AP_APINV_APPROVERS
			WHERE Invoice_Id = l_invoice_id;

			resultout := 'FINISH';

		--waiting for responses, regardless of whether some
		--notifications have completed or not
		ELSIF l_sent >0 THEN
			resultout := 'WAIT';

		--all complete, none waiting to be
		--sent(PEND) or waiting for response (SENT)
		ELSIF l_sent = 0 AND l_comp >0 THEN

			l_debug_info := l_api_name ||': all complete but none sent';
        		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
				l_api_name,l_debug_info);
        		END IF;

			--First set transaction statuses
			--to approved for header and lines
			--only set the header to approved, if it was actually
			--approved in the process.
			UPDATE AP_INVOICES_ALL
			SET WFApproval_Status = 'WFAPPROVED'
			WHERE WFApproval_Status = 'INITIATED'
			AND Invoice_Id IN (SELECT DISTINCT Invoice_ID
				FROM AP_APINV_APPROVERS
				WHERE Invoice_Id = l_invoice_id
				and Invoice_Iteration = l_iteration
				AND Line_Number IS NULL);

			--in the subselects, we do not need
			--to filter by approval_status
			-- since any rejection
			--would have set the Line's
			--wfapproval_status to 'Rejected'
			--already, so the line will
			-- not even be selected for update by the main
			--part of the query.
			UPDATE AP_INVOICE_LINES_ALL
			SET WFApproval_Status = 'WFAPPROVED'
			WHERE Invoice_Id = l_invoice_id
			AND WFApproval_Status = 'INITIATED'
			AND Line_Number IN (SELECT DISTINCT Line_Number
				FROM AP_APINV_APPROVERS
				WHERE invoice_id = l_invoice_id
				and Invoice_Iteration = l_iteration);

			--Now set transaction statuses
			--to not required for those transaction
			--records not touched by approval
			--process.  By default, the only ones
			-- that have not been set to 'Rejected'
			--or 'Approved', are still
			--'Initiated'
			UPDATE AP_INVOICES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND WFApproval_Status = 'INITIATED';

			UPDATE AP_INVOICE_LINES_ALL
			SET WFApproval_Status = 'NOT REQUIRED'
			WHERE Invoice_Id = l_invoice_id
			AND WFApproval_Status = 'INITIATED';

			--clear process records
                        DELETE FROM AP_APINV_APPROVERS
                        WHERE Invoice_Id = l_invoice_id;

			resultout := 'FINISH';
		END IF; -- sent/complete checks
	END IF; --pending check

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Identify_Approver',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;
END Identify_Approver;

/*This procedure gets a table of approvers and their associated items, so the
notifications can be grouped by approver and sent in parallel whenever
possible.*/

PROCEDURE Get_Approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	l_invoice_id		NUMBER;
	l_complete		VARCHAR2(1);
	l_next_approvers	ame_util.approversTable2;
	l_next_approver		ame_util.approverRecord2;
	l_index			ame_util.idList;
	l_ids			ame_util.stringList;
	l_class			ame_util.stringList;
	l_source		ame_util.longStringList;
	l_line_num		NUMBER;
	l_api_name		CONSTANT VARCHAR2(200) := 'Get_Approvers';
	l_iteration		NUMBER;
	l_debug_info		VARCHAR2(2000);
	l_org_id		NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_debug_info := l_api_name || ': get variables from workflow: itemtype = ' || itemtype ||
			', itemkey = ' || itemkey;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

        l_debug_info := l_api_name || ': get variables from workflow' ||
                ', l_invoice_id = ' || l_invoice_id ||
                ', l_iteration = ' || l_iteration ||
                ', l_org_id = ' || l_org_id;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
        END IF;


	--get the next layer (stage) of approvers
	AME_API2.getNextApprovers1(applicationIdIn => 200,
                    	transactionTypeIn => 'APINV',
			transactionIdIn => to_char(l_invoice_id),
                        flagApproversAsNotifiedIn => ame_util.booleanTrue,
			approvalProcessCompleteYNOut => l_complete,
			nextApproversOut => l_next_approvers,
			itemIndexesOut => l_index,
			itemIdsOut => l_ids,
			itemClassesOut => l_class,
			itemSourcesOut => l_source
			);

	-- More values in the approver list
	l_debug_info := l_api_name || ': after call to ame';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;
	IF l_complete = ame_util.booleanFalse THEN
	   -- Loop through approvers' table returned by AME
	   l_debug_info := l_api_name || ': more approvers';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
           END IF;

	   l_debug_info := l_api_name || ': looping through approvers'||
		', next_approvers.count = ' || l_next_approvers.count;
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
           END IF;

	   FOR l_table IN 1..l_next_approvers.count LOOP
	-- 	nvl(l_next_approvers.First,0)..nvl(l_next_Approvers.Last,-1) LOOP
		--set the record variable
		l_next_approver := l_next_approvers(l_table);
                l_debug_info := l_api_name || ': item_id = '|| l_next_approver.item_id;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME|| l_api_name,l_debug_info);
                END IF;

		--if the approver record does not have a value for item_id,
		--we need to
		--use the item lists returned by AME to determine
		--the items associated
		--with this approver.
		IF l_next_approver.item_id IS NULL THEN
		   l_debug_info := 'item_id is null';
        	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        	   END IF;

		   FOR l_rec IN 1..l_index.count LOOP
			--l_index contains the mapping between
			--approvers and items
			l_debug_info := 'looping through l_rec';
        		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        	l_api_name,l_debug_info);
        		END IF;
			IF l_index(l_rec) = l_table THEN
			   l_debug_info := 'check type of item class';
        		   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        	l_api_name,l_debug_info);
        		   END IF;
			   --Depending on the type of item class, we need to set
			   --some variables
			   --amy need correction once project/dist seeded
			   IF l_class(l_rec) =
				ame_util.lineItemItemClassName THEN
				l_line_num := l_ids(l_rec);
			   ELSIF l_class(l_rec) = 'project code' THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
			   ELSIF l_class(l_rec) =
                                ame_util.costCenterItemClassName THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
			   --distributions
			   ELSIF l_class(l_rec) <>
					ame_util.lineItemItemClassName
				AND l_class(l_rec) <>
					ame_util.headerItemClassName THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
				FROM AP_INVOICE_DISTRIBUTIONS_ALL
				WHERE invoice_distribution_id = l_ids(l_rec);

   			   END IF; --l_class

			   --Insert record into ap_apinv_approvers
			   INSERT INTO AP_APINV_APPROVERS(
				INVOICE_ID,
				INVOICE_ITERATION,
				INVOICE_KEY,
				LINE_NUMBER,
				NOTIFICATION_STATUS,
				ROLE_NAME,
				ORIG_SYSTEM,
				ORIG_SYSTEM_ID,
				DISPLAY_NAME,
				APPROVER_CATEGORY,
				API_INSERTION,
				AUTHORITY,
				APPROVAL_STATUS,
				ACTION_TYPE_ID,
				GROUP_OR_CHAIN_ID,
				OCCURRENCE,
				SOURCE,
				ITEM_CLASS,
				ITEM_ID,
				ITEM_CLASS_ORDER_NUMBER,
				ITEM_ORDER_NUMBER,
				SUB_LIST_ORDER_NUMBER,
				ACTION_TYPE_ORDER_NUMBER,
				GROUP_OR_CHAIN_ORDER_NUMBER,
				MEMBER_ORDER_NUMBER,
				APPROVER_ORDER_NUMBER,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				CREATED_BY,
				CREATION_DATE,
				PROGRAM_APPLICATION_ID,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID )
				VALUES(
				l_invoice_id,
				l_iteration,
				itemkey,
				l_line_num,
				'PEND',
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_next_approver.ACTION_TYPE_ID,
				l_next_approver.GROUP_OR_CHAIN_ID,
				l_next_approver.OCCURRENCE,
				l_next_approver.SOURCE,
				l_class(l_rec),
				l_ids(l_rec),
				l_next_approver.ITEM_CLASS_ORDER_NUMBER,
				l_next_approver.ITEM_ORDER_NUMBER,
				l_next_approver.SUB_LIST_ORDER_NUMBER,
				l_next_approver.ACTION_TYPE_ORDER_NUMBER,
				l_next_approver.GROUP_OR_CHAIN_ORDER_NUMBER,
				l_next_approver.MEMBER_ORDER_NUMBER,
				l_next_approver.APPROVER_ORDER_NUMBER,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
								sysdate,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
								-1),
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
				sysdate,
				200,
				0,
				sysdate,
				0);

				l_debug_info := 'after insert';
        			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        			l_api_name,l_debug_info);
        			END IF;
			END IF; --l_index mapping
		   END LOOP; -- l_index mapping

		ELSE  --only one item_id per approver

		   l_debug_info := 'only one item_id per approver';
        	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
         	   END IF;
		   --Depending on the type of item class, we need to set
		   --some variables:
		   IF l_next_approver.item_class =
                                ame_util.lineItemItemClassName THEN
                   	l_line_num := l_next_approver.item_id;
                   ELSIF l_next_approver.item_class = 'project code' THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
                   ELSIF l_next_approver.item_class =
                                ame_util.costCenterItemClassName THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
		   --distributions
                   ELSIF l_next_approver.item_class <>
                                        ame_util.lineItemItemClassName
                         AND l_next_approver.item_class <>
                                        ame_util.headerItemClassName THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE invoice_distribution_id = l_next_approver.item_id;

                   END IF; --l_class

		   --Insert record into ap_apinv_approvers
		   INSERT INTO AP_APINV_APPROVERS(
				INVOICE_ID,
				INVOICE_ITERATION,
				INVOICE_KEY,
				LINE_NUMBER,
				NOTIFICATION_STATUS,
				ROLE_NAME,
				ORIG_SYSTEM,
				ORIG_SYSTEM_ID,
				DISPLAY_NAME,
				APPROVER_CATEGORY,
				API_INSERTION,
				AUTHORITY,
				APPROVAL_STATUS,
				ACTION_TYPE_ID,
				GROUP_OR_CHAIN_ID,
				OCCURRENCE,
				SOURCE,
				ITEM_CLASS,
				ITEM_ID,
				ITEM_CLASS_ORDER_NUMBER,
				ITEM_ORDER_NUMBER,
				SUB_LIST_ORDER_NUMBER,
				ACTION_TYPE_ORDER_NUMBER,
				GROUP_OR_CHAIN_ORDER_NUMBER,
				MEMBER_ORDER_NUMBER,
				APPROVER_ORDER_NUMBER,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				CREATED_BY,
				CREATION_DATE,
				PROGRAM_APPLICATION_ID,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID )
				VALUES(
				l_invoice_id,
				l_iteration,
				itemkey,
				l_line_num,
				'PEND',
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_next_approver.ACTION_TYPE_ID,
				l_next_approver.GROUP_OR_CHAIN_ID,
				l_next_approver.OCCURRENCE,
				l_next_approver.SOURCE,
				l_next_approver.item_class,
				l_next_approver.item_id,
				l_next_approver.ITEM_CLASS_ORDER_NUMBER,
				l_next_approver.ITEM_ORDER_NUMBER,
				l_next_approver.SUB_LIST_ORDER_NUMBER,
				l_next_approver.ACTION_TYPE_ORDER_NUMBER,
				l_next_approver.GROUP_OR_CHAIN_ORDER_NUMBER,
				l_next_approver.MEMBER_ORDER_NUMBER,
				l_next_approver.APPROVER_ORDER_NUMBER,
				nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
                                				sysdate,
                                nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
								-1),
                                nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
                                sysdate,
                                200,
                                0,
                                sysdate,
                                0);

		END IF; --more than one item_id per approver

	   END LOOP; --nextApprovers table

	END IF; --complete

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Get_Approvers',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Get_Approvers;

/*This procedure gets a table of approvers and their associated items, for
the application history forms.*/

PROCEDURE Get_All_Approvers(p_invoice_id IN NUMBER,
                        p_calling_sequence IN VARCHAR2) IS

	l_invoice_id		NUMBER;
	l_complete		VARCHAR2(1);
	l_next_approvers	ame_util.approversTable2;
	l_next_approver		ame_util.approverRecord2;
	l_index			ame_util.idList;
	l_ids			ame_util.stringList;
	l_class			ame_util.stringList;
	l_source		ame_util.longStringList;
	l_line_num		NUMBER;
	l_api_name		CONSTANT VARCHAR2(200) := 'Get_All_Approvers';
	l_iteration		NUMBER;
	l_debug_info		VARCHAR2(2000);
	l_org_id                NUMBER;
	l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

	l_debug_info := 'set variables from workflow';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
					l_debug_info);
        END IF;

	l_invoice_id := p_invoice_id;

	--get all of the approvers
	AME_API2.getAllApprovers1(applicationIdIn => 200,
                    	transactionTypeIn => 'APINV',
			transactionIdIn => to_char(l_invoice_id),
			approvalProcessCompleteYNOut => l_complete,
			approversOut => l_next_approvers,
			itemIndexesOut => l_index,
			itemIdsOut => l_ids,
			itemClassesOut => l_class,
			itemSourcesOut => l_source
			);

	--More values in the approver list
	l_debug_info := 'after call to ame';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;
	IF l_complete = ame_util.booleanFalse THEN
	   --Loop through approvers' table returned by AME
	   l_debug_info := 'more approvers';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
           END IF;

	   FOR l_table IN
		nvl(l_next_approvers.First,0)..nvl(l_next_Approvers.Last,-1)
									 LOOP
		l_debug_info := 'looping through approvers';
        	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        	END IF;
		--set the record variable
		l_next_approver := l_next_approvers(l_table);

		--if the approver record does not have a value for item_id,
		--we need to
		--use the item lists returned by AME to determine
		--the items associated
		--with this approver.
		IF l_next_approver.item_id IS NULL THEN
		   l_debug_info := 'item_id is null';
        	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        	   END IF;

		   FOR l_rec IN 1..l_index.count LOOP
			--l_index contains the mapping between
			--approvers and items
			l_debug_info := 'looping through l_rec';
        		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        	l_api_name,l_debug_info);
        		END IF;
			IF l_index(l_rec) = l_table THEN
			   l_debug_info := 'check type of item class';
        		   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        	l_api_name,l_debug_info);
        		   END IF;
			   --Depending on the type of item class, we need to set
			   --some variables
			   --amy need correction once project/dist seeded
			   IF l_class(l_rec) =
				ame_util.lineItemItemClassName THEN
				l_line_num := l_ids(l_rec);
			   ELSIF l_class(l_rec) = 'project code' THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
			   ELSIF l_class(l_rec) =
                                ame_util.costCenterItemClassName THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
                                FROM AP_INVOICE_DISTRIBUTIONS_ALL
                                WHERE project_id =l_ids(l_rec);
			   --distributions
			   ELSIF l_class(l_rec) <>
					ame_util.lineItemItemClassName
				AND l_class(l_rec) <>
					ame_util.headerItemClassName THEN

				SELECT Invoice_Line_Number
				INTO l_line_num
				FROM AP_INVOICE_DISTRIBUTIONS_ALL
				WHERE invoice_distribution_id = l_ids(l_rec);

   			   END IF; --l_class

			   --Insert record into ap_approvers_list_gt
			   INSERT INTO AP_APPROVERS_LIST_GT(
				LINE_NUMBER,
				ROLE_NAME,
				ORIG_SYSTEM,
				ORIG_SYSTEM_ID,
				DISPLAY_NAME,
				APPROVER_CATEGORY,
				API_INSERTION,
				AUTHORITY,
				APPROVAL_STATUS,
				ITEM_CLASS,
				ITEM_ID,
				APPROVER_ORDER_NUMBER)
				VALUES(
				l_line_num,
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_class(l_rec),
				l_ids(l_rec),
				l_next_approver.APPROVER_ORDER_NUMBER);

				l_debug_info := 'after insert';
        			IF (G_LEVEL_STATEMENT >=
					G_CURRENT_RUNTIME_LEVEL) THEN
          				FND_LOG.STRING(G_LEVEL_STATEMENT,
							G_MODULE_NAME||
                        			l_api_name,l_debug_info);
        			END IF;
			END IF; --l_index mapping
		   END LOOP; -- l_index mapping

		ELSE  --only one item_id per approver

		   l_debug_info := 'only one item_id per approver';
        	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
         	   END IF;
		   --Depending on the type of item class, we need to set
		   --some variables:
		   IF l_next_approver.item_class =
                                ame_util.lineItemItemClassName THEN
                   	l_line_num := l_next_approver.item_id;
                   ELSIF l_next_approver.item_class = 'project code' THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
                   ELSIF l_next_approver.item_class =
                                ame_util.costCenterItemClassName THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE project_id = l_next_approver.item_id;
		   --distributions
                   ELSIF l_next_approver.item_class <>
                                        ame_util.lineItemItemClassName
                         AND l_next_approver.item_class <>
                                        ame_util.headerItemClassName THEN

                        SELECT Invoice_Line_Number
			INTO l_line_num
                        FROM AP_INVOICE_DISTRIBUTIONS_ALL
                        WHERE invoice_distribution_id = l_next_approver.item_id;

                   END IF; --l_class

			--Insert record into ap_approvers_list_gt
			INSERT INTO AP_APINV_APPROVERS(
                               LINE_NUMBER,
                                ROLE_NAME,
                                ORIG_SYSTEM,
                                ORIG_SYSTEM_ID,
                                DISPLAY_NAME,
                                APPROVER_CATEGORY,
                                API_INSERTION,
                                AUTHORITY,
                                APPROVAL_STATUS,
                                ITEM_CLASS,
                                ITEM_ID,
                                APPROVER_ORDER_NUMBER)
				VALUES(
				l_line_num,
				l_next_approver.NAME,
				l_next_approver.ORIG_SYSTEM,
				l_next_approver.ORIG_SYSTEM_ID,
				l_next_approver.DISPLAY_NAME,
				l_next_approver.APPROVER_CATEGORY,
				l_next_approver.API_INSERTION,
				l_next_approver.AUTHORITY,
				l_next_approver.APPROVAL_STATUS,
				l_next_approver.item_class,
				l_next_approver.item_id,
				l_next_approver.APPROVER_ORDER_NUMBER);

		END IF; --more than one item_id per approver

	   END LOOP; --nextApprovers table

	END IF; --complete

EXCEPTION
WHEN OTHERS
        THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Get_All_Approvers;

/*This procedure sets the item attributes (essentially global variables) to the
 appropriate values for the notification that is sent.*/

PROCEDURE Set_Approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2) IS

	l_level		VARCHAR2(10);
	l_api_name	CONSTANT VARCHAR2(200) := 'Set_Approver';
	l_debug_info	VARCHAR2(2000);
	l_invoice_key	VARCHAR2(50);


BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Determine if line or header level approver
	SELECT DECODE(nvl(Line_Number,''),'','HEADER','LINE'), invoice_key
	INTO l_level, l_invoice_key
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = itemkey
	AND rownum = 1;

	resultout := l_level;

	--update approvers table
	UPDATE AP_APINV_APPROVERS
	SET Notification_Status = 'SENT'
	WHERE Notification_Key = itemkey;


	--set wf attribute values
	set_attribute_values(itemtype,itemkey);

	--update appropriate history table
	IF l_level = 'HEADER' THEN
		Insert_Header_History(itemtype, itemkey, p_type => 'NEW');
	ELSE	-- 'LINE' Level
		Insert_Line_History(itemtype, itemkey, p_type => 'NEW');
	END IF;

	--amy
	--Let the parent process continue
	wf_engine.CompleteActivity(
                        itemType => 'APINVLDP',
                        itemKey  => l_invoice_key,
                        activity => 'APPROVAL_STAGING:BLOCK-LNP',
                        result   => 'NULL');
EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Set_Approver',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Set_Approver;

PROCEDURE Escalate_Header_Request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

	l_esc_approver 		AME_UTIL.approverRecord2;
	l_name          	VARCHAR2(30);
	l_esc_approver_name  	VARCHAR2(150);
	l_esc_approver_id    	NUMBER(15);
	l_approver_id   	NUMBER(15);
	l_invoice_id    	NUMBER(15);
	l_hist_id       	NUMBER(15);
	l_role			VARCHAR2(50);
	l_esc_role         	VARCHAR2(50);
	l_esc_role_display  	VARCHAR2(150);
	l_org_id        	NUMBER(15);
	l_level         	VARCHAR2(10);
        l_api_name      	CONSTANT VARCHAR2(200) :=
					'Escalate_Header_Request';
        l_debug_info    	VARCHAR2(2000);
	l_iteration		NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Get the current approver info
        l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID');

	l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

	l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID');

	l_role	:= WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'ROLE_NAME');


        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);

        --amy see if we have an TCA/WF Directory api for this select
        SELECT supervisor_id
        INTO l_esc_approver_id
        FROM per_employees_current_x
        WHERE employee_id = l_approver_id;

        WF_DIRECTORY.GetUserName('PER',
                        l_esc_approver_id,
                        l_name,
                        l_esc_approver_name);

	WF_DIRECTORY.GetRoleName('PER',
			l_esc_approver_id,
			l_esc_role,
			l_esc_role_display);

        l_esc_approver.name := l_esc_role;
        l_esc_approver.api_insertion := ame_util.apiInsertion;
        l_esc_approver.authority := ame_util.authorityApprover;
        l_esc_approver.approval_status := ame_util.forwardStatus;

	--update AME
	AME_API2.updateApprovalStatus2(applicationIdIn => 200,
			   transactionTypeIn =>  'APINV',
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.noResponseStatus,
                           approverNameIn  => l_role,
                           itemClassIn    => ame_util.headerItemClassName,
			   itemIdIn    => to_char(l_invoice_id),
                           forwardeeIn       => l_esc_approver);

	--Set WF attributes
	WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_APPROVER_NAME',
                        l_esc_approver_name);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'ESC_APPROVER_ID',
                        l_esc_approver_id);

        WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_ROLE_NAME',
                        l_esc_role);

	--update history for non-responding approver
	Update ap_inv_aprvl_hist_all
	Set Response = 'ESCALATED'
	    ,Last_Update_Date = sysdate
            ,Last_Updated_By = nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
            ,Last_Update_Login =
			nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1)
	Where invoice_id = l_invoice_id
 	AND iteration = l_iteration
	AND approver_id = l_approver_id;

	--create history for manager approval
	Insert_Header_History(itemtype, itemkey, p_type => 'ESC');


EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Escalate_Header_Request',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Escalate_Header_Request;

PROCEDURE Escalate_Line_Request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

	--Define cursor for lines affected by notification
	CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
	SELECT Item_Class, Item_Id
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = itemkey;

	l_esc_approver 		AME_UTIL.approverRecord2;
	l_name          	VARCHAR2(30);
	l_esc_approver_name  	VARCHAR2(150);
	l_esc_approver_id    	NUMBER(15);
	l_approver_id   	NUMBER(15);
	l_invoice_id    	NUMBER(15);
	l_hist_id       	NUMBER(15);
	l_role	              	VARCHAR2(50);
	l_esc_role         	VARCHAR2(50);
	l_esc_role_display  	VARCHAR2(150);
	l_org_id        	NUMBER(15);
	l_api_name              CONSTANT VARCHAR2(200) :=
                                        'Escalate_Line_Request';
        l_debug_info            VARCHAR2(2000);
        l_iteration             NUMBER;
	l_item_class		VARCHAR2(50);
	l_item_id		NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Get the current approver info
        l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID');

	l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

	l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID');

	l_role  := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'ROLE_NAME');

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);

        --amy see if we have an TCA/WF Directory api for this select
        SELECT supervisor_id
        INTO l_esc_approver_id
        FROM per_employees_current_x
        WHERE employee_id = l_approver_id;

        WF_DIRECTORY.GetUserName('PER',
                        l_esc_approver_id,
                        l_name,
                        l_esc_approver_name);

	WF_DIRECTORY.GetRoleName('PER',
				l_esc_approver_id,
				l_esc_role,
				l_esc_role_display);

        l_esc_approver.name := l_esc_role;
        l_esc_approver.api_insertion := ame_util.apiInsertion;
        l_esc_approver.authority := ame_util.authorityApprover;
        l_esc_approver.approval_status := ame_util.forwardStatus;

	OPEN Items_Cur(itemkey);
  	LOOP

    		FETCH Items_Cur INTO l_item_class, l_item_id;
    		EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

		--update AME
		AME_API2.updateApprovalStatus2(applicationIdIn => 200,
			transactionTypeIn =>  'APINV',
                           transactionIdIn     => to_char(l_invoice_id),
                           approvalStatusIn    => AME_UTIL.noResponseStatus,
                           approverNameIn  => l_role,
                           itemClassIn    => l_item_class,
                           itemIdIn    => l_item_id,
                           forwardeeIn       => l_esc_approver);

	END LOOP;
	CLOSE Items_Cur;

	--Set WF attributes
	WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_APPROVER_NAME',
                        l_esc_approver_name);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'ESC_APPROVER_ID',
                        l_esc_approver_id);

        WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'ESC_ROLE_NAME',
                        l_esc_role);

	--update history for non-responding approver
	Update ap_line_aprvl_hist_all
	Set Response = 'ESCALATED'
	    ,Last_Update_Date = sysdate
            ,Last_Updated_By = nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
            ,Last_Update_Login =
                        nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1)
        Where invoice_id = l_invoice_id
        AND approver_id = l_approver_id
	AND notification_key = itemkey;


	--create history for manager approval
	Insert_Line_History(itemtype, itemkey, p_type => 'ESC');

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Escalate_Request',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Escalate_Line_Request;

PROCEDURE Notification_Handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

	l_api_name        CONSTANT VARCHAR2(200) :=
                                        'Notification_Handler';
BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--users may not transfer, or reassign them
      	IF ( funcmode = 'TRANSFER' ) THEN
           resultout := 'ERROR:WFSRV_NO_DELEGATE';
           return;
	ELSE --users are allowed to forward notifications
	   resultout := 'COMPLETE';
           return;
	END IF;

	return;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Notification_Handler',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Notification_Handler;

PROCEDURE Response_Handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

	--Define cursor for lines affected by notification
	--Note that Invoice_Key s/b the same for all records in the cursor
	--but I want to avoid another select on the table
	CURSOR   Items_Cur(itemkey IN VARCHAR2) IS
	SELECT Item_Class, Item_Id, Role_Name, Invoice_Key
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = itemkey;

	l_api_name	CONSTANT VARCHAR2(200) := 'Response_Handler';
	l_invoice_id	NUMBER;
	l_level		VARCHAR2(20);
	l_result	VARCHAR2(20);
	l_invoice_key	VARCHAR2(50);
	l_name		AP_APINV_APPROVERS.ROLE_NAME%TYPE;
	l_item_class 	AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
	l_item_id    	AP_APINV_APPROVERS.ITEM_ID%TYPE;
	l_debug_info	VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

 	--Get wf attribute values
	l_result := WF_ENGINE.GetActivityAttrText(itemtype => itemtype,
                                  itemkey => itemkey,
                                  actid => actid,
                                  aname => 'NOTIFICATION_RESULT');

	l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

        l_debug_info := l_api_name || ': itemtype = ' || itemtype
                || ', itemkey = ' || itemkey
                || ', invoice_id = ' || l_invoice_id
                || ', result = ' || l_result;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;


	--Update Approvers table
	UPDATE AP_APINV_APPROVERS
	SET Notification_status = 'COMP'
	WHERE Notification_Key = itemkey;

	--Determine if line or header level approver
	SELECT DECODE(nvl(Line_Number,''),'','HEADER','LINE')
	INTO l_level
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = itemkey
	AND rownum = 1;

	--update history at appropriate level
	IF l_level = 'HEADER' THEN
		update_header_history(itemtype,
			actid,
                        itemkey);
	ELSE
		update_line_history(itemtype,
			actid,
                        itemkey);
	END IF;

	--update AME status
	--amy check with ame as to when updateApprovalStatuses will be available
	--so I will not need to loop.
	OPEN Items_Cur(itemkey);
  	LOOP

    		FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
					l_invoice_key;
    		EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

	        --update AME with response
        	IF l_result = 'APPROVED' THEN
        	        AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
				itemClassIn	=> l_item_class,
				itemIdIn	=> l_item_id);
		ELSE
        	        AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.rejectStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
				itemClassIn	=> l_item_class,
				itemIdIn	=> l_item_id);
        	END IF;
	END LOOP;
  	CLOSE Items_Cur;

	--Unblock the APINV parent process
	-- amy may need to make the Block a start node
	-- or use suspend/resume wf apis
	wf_engine.CompleteActivity(
			itemType => 'APINVLDP',
			itemKey  => l_invoice_key,
			activity => 'APPROVAL_STAGING:BLOCK-1',
			result   => 'NULL');

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLPN','Response_Handler',itemtype, itemkey,
                                  to_char(actid), funcmode);
          RAISE;

END Response_Handler;

/*handles all the updates for an approvers response.  This version called
 * from the framework pages
 */
PROCEDURE Response_Handler(p_invoice_id IN NUMBER,
                        p_line_num IN NUMBER,
                        p_not_key IN VARCHAR2,
                        p_response IN  VARCHAR2,
                        p_comments IN  VARCHAR2 ) IS

	--Define cursor for lines affected by notification
	--Note that Invoice_Key s/b the same for all records in the cursor
	--but I want to avoid another select on the table
	CURSOR   Items_Cur(l_not_key IN VARCHAR2, l_line_num IN NUMBER) IS
	SELECT Item_Class, Item_Id, Role_Name, Invoice_Key
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = l_not_key
	AND line_number = l_line_num;

	l_api_name	CONSTANT VARCHAR2(200) := 'Response_Handler_OA';
	l_invoice_id	NUMBER;
	l_level		VARCHAR2(20);
	l_result	VARCHAR2(20);
	l_invoice_key	VARCHAR2(50);
	l_name		AP_APINV_APPROVERS.ROLE_NAME%TYPE;
	l_item_class 	AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
	l_item_id    	AP_APINV_APPROVERS.ITEM_ID%TYPE;
	l_debug_info	VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Update Approvers table
	UPDATE AP_APINV_APPROVERS
	SET Notification_status = 'COMP'
	WHERE Notification_Key = p_not_key;

	--update history at appropriate level
        Update_Line_History(p_invoice_id,
                        p_line_num,
                        p_response,
                        p_comments);

	--update AME status
	--amy check with ame as to when updateApprovalStatuses will be available
	--so I will not need to loop.
	OPEN Items_Cur(p_not_key, p_line_num);
  	LOOP

    		FETCH Items_Cur INTO l_item_class, l_item_id, l_name,
					l_invoice_key;
    		EXIT WHEN Items_Cur%NOTFOUND OR Items_Cur%NOTFOUND IS NULL;

	        --update AME with response
        	IF l_result = 'WFAPPROVED' THEN
        	        AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(p_invoice_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
				itemClassIn	=> l_item_class,
				itemIdIn	=> l_item_id);
		ELSE
        	        AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(p_invoice_id),
                                approvalStatusIn    => AME_UTIL.rejectStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
				itemClassIn	=> l_item_class,
				itemIdIn	=> l_item_id);
        	END IF;

	END LOOP;
  	CLOSE Items_Cur;

	--Unblock the APINV parent process
	-- amy may need to make the Block a start node
	-- or use suspend/resume wf apis
	wf_engine.CompleteActivity(
			itemtype => 'APINVLDP',
			itemkey  => l_invoice_key,
			activity => 'APPROVAL_STAGING:BLOCK-1',
			result   => 'NULL');

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLPN','Response_Handler');

          RAISE;

END Response_Handler;


--Public Procedures called from other procedures

PROCEDURE IAW_Raise_Event(p_eventname IN VARCHAR2,
                          p_invoice_id IN VARCHAR2,
                          p_org_id IN NUMBER,
			  p_calling_sequence IN VARCHAR2) IS

	l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
	l_parameter_t 		wf_parameter_t:= wf_parameter_t(null, null);

	l_api_name	CONSTANT VARCHAR2(200) := 'IAW_Raise_Event';

	l_debug_info            varchar2(2000);
	l_invoice_id            NUMBER;
	l_iteration             NUMBER;
	l_calling_sequence	VARCHAR2(2000);
	l_invoice_supplier_name VARCHAR2(80);
	l_invoice_number 	VARCHAR2(50);
	l_invoice_date 		DATE;
	l_invoice_description 	VARCHAR2(240);
	l_supplier_role		varchar2(320);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

	l_debug_info := 'set variables';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
			l_debug_info);
        END IF;

	if instr(p_invoice_id, '_') > 0 then

		l_invoice_id := substr(p_invoice_id, 1, instr(p_invoice_id,'_')-1);
	        l_iteration := substr(p_invoice_id, instr(p_invoice_id,'_')+1, length(p_invoice_id));
	else
		l_invoice_id := p_invoice_id;
	end if;


	SELECT
      			PV.vendor_name,
      			AI.invoice_num,
      			AI.invoice_date,
      			AI.description,
			decode(AI.source, 'ISP', u.user_name, null)
    	INTO
      			l_invoice_supplier_name,
      			l_invoice_number,
      			l_invoice_date,
      			l_invoice_description,
			l_supplier_role
    	FROM
      			ap_invoices_all AI,
     			po_vendors PV,
      			po_vendor_sites_all PVS,
			fnd_user u
    	WHERE
      			AI.invoice_id = l_invoice_id AND
      			AI.vendor_id = PV.vendor_id AND
      			AI.vendor_site_id = PVS.vendor_site_id(+) and
	 		u.user_id = ai.created_by;


	wf_event.addparametertolist(p_name => 'INVOICE_ID',
				     p_value => to_char(l_invoice_id),
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'ORG_ID',
                                     p_value => to_char(p_org_id),
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'ITERATION',
                                     p_value => to_char(l_iteration),
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'INVOICE_SUPPLIER_NAME',
                                     p_value => l_invoice_supplier_name,
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'INVOICE_NUMBER',
                                     p_value => l_invoice_number,
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'INVOICE_DESCRIPTION',
                                     p_value => l_invoice_description,
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'INVOICE_DATE',
                                     p_value => to_char(l_invoice_date),
				     p_parameterlist => l_parameter_list);

	wf_event.addparametertolist(p_name => 'SUPPLIER_ROLE',
                                     p_value => l_supplier_role,
				     p_parameterlist => l_parameter_list);

	l_debug_info := 'raise event';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
			l_debug_info);
        END IF;


	wf_event.raise(p_event_name => p_eventname,
                        p_event_key => p_invoice_id||to_char(sysdate, 'ddmonyyyyssmmhh'),
			p_parameters => l_parameter_list);

	l_parameter_list.delete;

        commit;
	l_debug_info := 'after commit';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
			l_debug_info);
        END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END IAW_Raise_Event;

PROCEDURE Set_Attribute_Values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 ) IS

	l_iteration		NUMBER;
	l_not_key		VARCHAR2(50);
	l_not_it		NUMBER;
	l_invoice_id 		NUMBER(15);
	l_invoice_supplier_name VARCHAR2(80);
	l_invoice_supplier_site VARCHAR2(15);
	l_invoice_number 	VARCHAR2(50);
	l_invoice_date 		DATE;
	l_invoice_description 	VARCHAR2(240);
	l_invoice_item_total 	NUMBER;
	l_invoice_freight_total NUMBER;
	l_invoice_miscellaneous_total NUMBER;
	l_invoice_tax_total 	NUMBER;
	l_invoice_total 	NUMBER;
	l_invoice_currency_code VARCHAR2(15);
	l_org_id		NUMBER;
	l_api_name	CONSTANT VARCHAR2(200) := 'Set_Attribute_Values';
	l_role			VARCHAR2(50);
	l_orig_id		NUMBER;
	l_debug_info		VARCHAR2(2000);

BEGIN
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.set_attribute_values (+)');
        END IF;

        l_debug_info := l_api_name || ': itemtype = ' || itemtype ||
                        ', itemkey = ' || itemkey;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;

	IF itemtype = 'APINVLDP' THEN
	-- IF itemtype = 'APINVLPM' THEN

		SELECT Invoice_Id, Invoice_Iteration, Notification_Key,
			Notification_Iteration
		INTO l_invoice_id, l_iteration, l_not_key, l_not_it
		FROM AP_APINV_APPROVERS
		WHERE Invoice_Key = itemkey
		AND Notification_Status = 'PEND'
		AND ROWNUM = 1;

                l_debug_info := l_api_name ||': notification_key = ' || l_not_key ||
				', notification_iteration = '|| l_not_it;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                END IF;

        	WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'NOTIFICATION_KEY',
                                   l_not_key);

		WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ITERATION',
                                   l_not_it);

	ELSE --itemtype = 'APINVLPN'

		SELECT Invoice_Id, Invoice_Iteration, Notification_Key,
			Notification_Iteration, Role_Name, orig_system_id
		INTO l_invoice_id, l_iteration, l_not_key, l_not_it
			, l_role, l_orig_id
		FROM AP_APINV_APPROVERS
		WHERE Notification_Key = itemkey
		AND ROWNUM = 1;

                l_debug_info := l_api_name ||': notification_key = ' || l_not_key ||
                                ', notification_iteration = '|| l_not_it ||
				', orig_approver_id = ' || l_orig_id ||
				', role = '|| l_role || ', invoice_id = '|| l_invoice_id;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                END IF;

		WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID',
                                   l_orig_id);

		WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION',
                                   l_iteration);

        	WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'NOTIFICATION_KEY',
                                   l_not_key);

		WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'NOTIFICATION_ITERATION',
                                   l_not_it);

        	WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID',
                                   l_org_id);

        	WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID',
                                   l_invoice_id);

		WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'ROLE_NAME',
                                   l_role);

		SELECT
      			PV.vendor_name,
      			PVS.vendor_site_code,
      			AI.invoice_num,
      			AI.invoice_date,
      			AI.description,
      			NVL(AI.invoice_amount, 0),
      			AI.invoice_currency_code
    		INTO
      			l_invoice_supplier_name,
      			l_invoice_supplier_site,
      			l_invoice_number,
      			l_invoice_date,
      			l_invoice_description,
      			l_invoice_total,
      			l_invoice_currency_code
    		FROM
      			ap_invoices_all AI,
     			 po_vendors PV,
      			po_vendor_sites_all PVS
    		WHERE
      			AI.invoice_id = l_invoice_id AND
      			AI.vendor_id = PV.vendor_id AND
      			AI.vendor_site_id = PVS.vendor_site_id(+);

                l_debug_info := l_api_name ||': supplier_name ' || l_invoice_supplier_name ||
                                ', invoice_num = '|| l_invoice_number ||
                                ', invoice_total = '|| l_invoice_total;
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
                END IF;

		--set wf attributes

    		WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_SUPPLIER_NAME',
      		avalue => l_invoice_supplier_name
    		);

		WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_SUPPLIER_SITE',
      		avalue => l_invoice_supplier_site
    		);

    		WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_NUMBER',
      		avalue => l_invoice_number
    		);

    		WF_ENGINE.SETITEMATTRDATE
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_DATE',
      		avalue => l_invoice_date
    		);

    		WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_DESCRIPTION',
      		avalue => l_invoice_description
    		);

    		WF_ENGINE.SETITEMATTRNUMBER
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_TOTAL',
      		avalue => l_invoice_total
    		);

    		WF_ENGINE.SETITEMATTRTEXT
    		(
      		itemtype => itemtype,
      		itemkey => itemkey,
      		aname => 'INVOICE_CURRENCY_CODE',
      		avalue => l_invoice_currency_code
    		);

		/*amy failed gscc because of CHR()
 * 		find alternative
    		WF_ENGINE.SETITEMATTRTEXT
    		(
     		 itemtype => itemtype,
      		itemkey => itemkey,
     		 aname => 'INVOICE_ATTACHMENTS',
      		-- CHR(38) is the ampersand character. This is used instead
		--of the ampersand character literal to "hide" the ampersand
		--character from SQL*Plus so that SQL*Plus does not try and do
		--variable substitution when loading the package.
      		avalue => ('FND:entity=AP_INVOICES' || CHR(38) ||
			 'pk1name=INVOICE_ID' || CHR(38) || 'pk1value=' ||
			l_invoice_id)
    		);
		*/
	END IF;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Set_Attribute_Values',itemtype, itemkey);
          RAISE;

END Set_Attribute_Values;

/*When the approver for a line has been identified, this procedure places
a Pending record in the history table.*/

PROCEDURE Insert_Header_History(
                        p_inv_aprvl_hist IN ap_iaw_pkg.r_inv_aprvl_hist) IS

	l_api_name	CONSTANT VARCHAR2(200) := 'Insert_Header_History';
	l_hist_id	NUMBER;
	l_debug_info	VARCHAR2(2000);
	l_not_cnt	NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--set the environment
        fnd_client_info.set_org_context(p_inv_aprvl_hist.org_id);

        SELECT AP_INV_APRVL_HIST_S.nextval
        INTO l_hist_id
        FROM dual;

	SELECT max(notification_order) + 1
	INTO l_not_cnt
	FROM ap_inv_aprvl_hist_all
	WHERE invoice_id = p_inv_aprvl_hist.invoice_id
	AND  iteration = p_inv_aprvl_hist.iteration;

	--insert into the history table
        INSERT INTO  AP_INV_APRVL_HIST_ALL
        (APPROVAL_HISTORY_ID
        ,INVOICE_ID
        ,ITERATION
        ,RESPONSE
        ,APPROVER_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,ORG_ID
        ,AMOUNT_APPROVED
	,NOTIFICATION_ORDER)
        VALUES (
        l_hist_id
        ,p_inv_aprvl_hist.invoice_id
        ,p_inv_aprvl_hist.iteration
        ,p_inv_aprvl_hist.response
        ,p_inv_aprvl_hist.approver_id
        ,p_inv_aprvl_hist.created_by
        ,p_inv_aprvl_hist.creation_date
        ,p_inv_aprvl_hist.last_update_date
        ,p_inv_aprvl_hist.last_updated_by
        ,p_inv_aprvl_hist.last_update_login
        ,p_inv_aprvl_hist.org_id
        ,p_inv_aprvl_hist.amount_approved
	,l_not_cnt);

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Insert_Header_History');
          RAISE;

END Insert_Header_History;


/*When the approver for a line has been identified, this procedure places
a Pending record in the history table.*/
PROCEDURE Insert_Header_History(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
			p_type IN VARCHAR2 ) IS

	l_approver_id		NUMBER;
	l_invoice_id		NUMBER;
	l_iteration		NUMBER;
	l_org_id		NUMBER;
	l_amount		NUMBER;
	l_hist_id		NUMBER;
	l_api_name	CONSTANT VARCHAR2(200) := 'Insert_Header_History';
	l_debug_info		VARCHAR2(2000);
	l_not_cnt		NUMBER;

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Get attribute values to create record in the history table
	IF p_type = 'ESC' THEN
        	l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ESC_APPROVER_ID');
	ELSE
		l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID');
	END IF;

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

        l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID');

        l_amount := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_TOTAL');

        --Now set the environment
        --fnd_client_info.set_org_context(l_org_id);


        SELECT AP_INV_APRVL_HIST_S.nextval
        INTO l_hist_id
        FROM dual;

	SELECT max(nvl(notification_order,0)) + 1
        INTO l_not_cnt
        FROM ap_inv_aprvl_hist_all
        WHERE invoice_id = l_invoice_id
        AND  iteration = l_iteration;


 	--insert into the history table
        INSERT INTO  AP_INV_APRVL_HIST_ALL
        (APPROVAL_HISTORY_ID
        ,INVOICE_ID
        ,ITERATION
        ,RESPONSE
        ,APPROVER_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,ORG_ID
        ,AMOUNT_APPROVED
	,NOTIFICATION_ORDER)
        VALUES (
        l_hist_id
        ,l_invoice_id
        ,l_iteration
        ,'PENDING'
        ,l_approver_id
        ,-1 --nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
        ,sysdate
        ,sysdate
        ,-1 --nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
        ,-1 --nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1)
        ,l_org_id
        ,l_amount
	,l_not_cnt);

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Insert_Header_History',itemtype,
					itemkey);
          RAISE;

END Insert_Header_History;

/*When the approver for a line has been identified, this procedure places
a Pending record in the history table. */

PROCEDURE Insert_Line_History(
                        p_line_aprvl_hist IN ap_iaw_pkg.r_line_aprvl_hist) IS

	l_api_name      CONSTANT VARCHAR2(200) := 'Insert_Line_History';
        l_debug_info    VARCHAR2(2000);
	l_hist_id               NUMBER;
	l_not_cnt		NUMBER;
BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Now set the environment
        fnd_client_info.set_org_context(p_line_aprvl_hist.org_id);

		SELECT AP_INV_APRVL_HIST_S.nextval
        	INTO l_hist_id
        	FROM dual;

		SELECT max(notification_order) + 1
        	INTO l_not_cnt
        	FROM ap_line_aprvl_hist
        	WHERE invoice_id = p_line_aprvl_hist.invoice_id
        	AND  iteration = p_line_aprvl_hist.iteration
		AND line_number = p_line_aprvl_hist.line_number;

                --insert into the history table
                INSERT INTO  AP_LINE_APRVL_HIST
                (LINE_APRVL_HISTORY_ID
                ,LINE_NUMBER
                ,INVOICE_ID
                ,ITERATION
                ,RESPONSE
                ,APPROVER_ID
                --,NOTIFICATION_KEY
                ,LINE_AMOUNT_APPROVED
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,ORG_ID
                ,ITEM_CLASS
                ,ITEM_ID
		,NOTIFICATION_ORDER)
                VALUES (
                l_hist_id
                ,p_line_aprvl_hist.line_number
                ,p_line_aprvl_hist.invoice_id
                ,p_line_aprvl_hist.iteration
                ,'PENDING'
                ,p_line_aprvl_hist.approver_id
                --,p_line_aprvl_hist.notification_key
                ,p_line_aprvl_hist.line_amount_approved
                ,p_line_aprvl_hist.created_by
                ,p_line_aprvl_hist.creation_date
                ,p_line_aprvl_hist.last_update_date
                ,p_line_aprvl_hist.last_updated_by
                ,p_line_aprvl_hist.last_update_login
                ,p_line_aprvl_hist.org_id
                ,p_line_aprvl_hist.item_class
                ,p_line_aprvl_hist.item_id
		,l_not_cnt);

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Insert_Line_History');
          RAISE;

END Insert_Line_History;

/*When the approver for a line has been identified, this procedure places
a Pending record in the history table for each approver in ap_apinv_approvers
identified by the itemkey*/

PROCEDURE Insert_Line_History(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
			P_type IN VARCHAR2 ) IS

	l_approver_id		NUMBER;
	l_invoice_id		NUMBER;
	l_iteration		NUMBER;
	l_org_id		NUMBER;
	l_amount		NUMBER;
	l_hist_id		NUMBER;
	l_api_name	CONSTANT VARCHAR2(200) := 'Insert_Line_History';
	l_debug_info	VARCHAR2(2000);
	l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
        l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
	l_line_amt	NUMBER;
	l_line_num	AP_APINV_APPROVERS.LINE_NUMBER%TYPE;
	l_not_cnt	NUMBER;

	--Define cursor for lines affected by notification
	CURSOR   Lines_Cur(itemkey IN VARCHAR2) IS
	SELECT Line_Number, item_class, item_id
	FROM AP_APINV_APPROVERS
	WHERE Notification_Key = itemkey
	GROUP BY Line_Number, item_class, item_id;

BEGIN
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	--Get attribute values to create record in the history table
	IF p_type = 'ESC' THEN
        	l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ESC_APPROVER_ID');
	ELSE
		l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APPROVER_ID');
	END IF;

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

        l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'ORG_ID');

	l_line_amt := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'LINE_TOTAL');

       --Now set the environment
        fnd_client_info.set_org_context(l_org_id);


	OPEN Lines_Cur(itemkey);
  	LOOP

    		FETCH Lines_Cur INTO l_line_num, l_item_class, l_item_id;
    		EXIT WHEN Lines_Cur%NOTFOUND OR Lines_Cur%NOTFOUND IS NULL;

		SELECT AP_INV_APRVL_HIST_S.nextval
        	INTO l_hist_id
        	FROM dual;

		SELECT max(nvl(notification_order,0)) + 1
                INTO l_not_cnt
                FROM ap_line_aprvl_hist
                WHERE invoice_id = l_invoice_id
                AND  iteration = l_iteration
                AND line_number = l_line_num;

 		--insert into the history table
        	INSERT INTO  AP_LINE_APRVL_HIST
        	(LINE_APRVL_HISTORY_ID
		,LINE_NUMBER
        	,INVOICE_ID
        	,ITERATION
        	,RESPONSE
        	,APPROVER_ID
		,NOTIFICATION_KEY
		,LINE_AMOUNT_APPROVED
        	,CREATED_BY
        	,CREATION_DATE
        	,LAST_UPDATE_DATE
        	,LAST_UPDATED_BY
        	,LAST_UPDATE_LOGIN
        	,ORG_ID
		,ITEM_CLASS
		,ITEM_ID
		,NOTIFICATION_ORDER)
        	VALUES (
        	l_hist_id
		,l_line_num
        	,l_invoice_id
        	,l_iteration
        	,'PENDING'
        	,l_approver_id
		,itemkey
		,l_line_amt
              	,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
      		,sysdate
        	,sysdate
       		,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1)
        	,nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1)
        	,l_org_id
		,l_item_class
		,l_item_id
		,l_not_cnt);

	END LOOP;
  	CLOSE Lines_Cur;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLDP','Insert_Line_History',itemtype, itemkey);
          RAISE;

END Insert_Line_History;

/*This procedure updates the pending record in the history table with the
result values returned by the notification.  It will also set the line status
to Rejected, if that is the approver's response.*/
PROCEDURE Update_Header_History(itemtype IN VARCHAR2,
			actid IN NUMBER,
                        itemkey IN VARCHAR2) IS

	l_invoice_id    NUMBER(15);
	l_iteration	NUMBER(15);
	l_result        VARCHAR2(50);
	l_comments      VARCHAR2(240);
	l_amount       ap_invoices_all.invoice_amount%TYPE;
	l_status        VARCHAR2(50);
	l_org_id        NUMBER(15);
	l_user_id       NUMBER(15);
	l_login_id      NUMBER(15);
	l_api_name      CONSTANT VARCHAR2(200) := 'Update_Header_History';
        l_debug_info    VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

	l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ITERATION');

        l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'WF_NOTE');

        l_result := WF_ENGINE.GetActivityAttrText(itemtype,
                                  itemkey,
                                  actid,
                                  'NOTIFICATION_RESULT');

        l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

        l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
        l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

        IF l_result = 'APPROVED' THEN
                l_result := 'WFAPPROVED';
        END IF;

	--update history table status
	--If this is an escalation approver, need condition
        --to avoid clobbering original approvers record.
	Update ap_inv_aprvl_hist_all
	Set Response = l_result
	    ,Approver_Comments = l_comments
	    ,Last_Update_Date = sysdate
            ,Last_Updated_By = l_user_id
            ,Last_Update_Login = l_login_id
	Where invoice_id = l_invoice_id
	AND iteration = l_iteration
	And Response = 'PENDING';

	--Set transaction record status
        IF l_result = 'REJECTED' THEN

		--check that status
		--is initiated here.
               UPDATE AP_INVOICES
               SET wfapproval_status = l_result
		,Last_Update_Date = sysdate
            	,Last_Updated_By = l_user_id
            	,Last_Update_Login = l_login_id
               WHERE invoice_id = l_invoice_id
                AND wfapproval_status = 'INITIATED';

        END IF;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLPN','Update_Header_History',itemtype, itemkey,
                                  to_char(actid));
          RAISE;

End Update_Header_History;

/*This procedure updates the pending record in the history table with the
result values returned by the notification.  It will also set the line status
to Rejected, if that is the approver's response.*/

PROCEDURE Update_Line_History(
                        p_invoice_id IN NUMBER,
                        p_line_num IN NUMBER,
			p_response IN VARCHAR2,
			p_comments IN VARCHAR2) IS

        l_api_name      CONSTANT VARCHAR2(200) := 'Update_Line_History';
        l_debug_info    VARCHAR2(2000);
	l_response	VARCHAR2(50);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	IF p_response = 'APPROVED' THEN
                l_response := 'WFAPPROVED';
        END IF;

	--update line history table status
        --If this is an escalation approver, need
        --condition to avoid clobbering original approvers record.
        Update ap_line_aprvl_hist_all
        Set Response = p_response
            ,Approver_Comments = p_comments
            ,Last_Update_Date = sysdate
            ,Last_Updated_By = -1
            ,Last_Update_Login = -1
        Where  invoice_id = p_invoice_id
	AND line_number = p_line_num
        And Response = 'PENDING';

        --Set transaction record status
        IF p_response = 'REJECTED' THEN

               UPDATE AP_INVOICE_LINES
               SET wfapproval_status = p_response
                ,Last_Update_Date = sysdate
                ,Last_Updated_By = -1
                ,Last_Update_Login = -1
               WHERE invoice_id = p_invoice_id
                AND wfapproval_status <> 'MANUALLY APPROVED'
                AND line_number = p_line_num;


        END IF;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLPN','Update_Line_History');

          RAISE;

END Update_Line_History;

PROCEDURE Update_Line_History(itemtype IN VARCHAR2,
			actid IN NUMBER,
                        itemkey IN VARCHAR2) IS

	l_invoice_id    NUMBER(15);
	l_result        VARCHAR2(50);
	l_comments      VARCHAR2(240);
	l_amount       ap_invoices_all.invoice_amount%TYPE;
	l_status        VARCHAR2(50);
	l_org_id        NUMBER(15);
	l_user_id       NUMBER(15);
	l_login_id      NUMBER(15);
	l_api_name      CONSTANT VARCHAR2(200) := 'Update_Line_History';
        l_debug_info    VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'INVOICE_ID');

        l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'WF_NOTE');

        l_result := WF_ENGINE.GetActivityAttrText(itemtype,
                                  itemkey,
                                  actid,
                                  'NOTIFICATION_RESULT');

        l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

        l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
        l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

        IF l_result = 'APPROVED' THEN
                l_result := 'WFAPPROVED';
        END IF;

	--update line history table status
	--If this is an escalation approver, need
	--condition to avoid clobbering original approvers record.
	Update ap_line_aprvl_hist_all
	Set Response = l_result
	    ,Approver_Comments = l_comments
	    ,Last_Update_Date = sysdate
            ,Last_Updated_By = l_user_id
            ,Last_Update_Login = l_login_id
	Where Notification_key = itemkey
	And Response = 'PENDING';

	--Set transaction record status
        IF l_result = 'REJECTED' THEN

               UPDATE AP_INVOICE_LINES
               SET wfapproval_status = l_result
		,Last_Update_Date = sysdate
            	,Last_Updated_By = l_user_id
            	,Last_Update_Login = l_login_id
               WHERE invoice_id = l_invoice_id
                AND wfapproval_status <> 'MANUALLY APPROVED'
		AND line_number in (SELECT line_number
					FROM ap_apinv_approvers
					WHERE notification_key = itemkey);
        END IF;

EXCEPTION
WHEN OTHERS
        THEN
          WF_CORE.CONTEXT('APINVLPN','Update_Line_History',itemtype, itemkey,
                                  to_char(actid));
          RAISE;

END Update_Line_History;

--Public Functions called from other procedures

/*This procedure will be called by payables when committing the status of
'Needs Reapproval'.  It clears the AME history for the header. */
FUNCTION Clear_AME_History_Header(
                        p_invoice_id IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

	l_api_name      CONSTANT VARCHAR2(200) := 'clear_ame_history_header';
        l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
        l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
        l_debug_info    VARCHAR2(2000);
        l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

        l_debug_info := 'opening item cursor';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
			l_api_name,l_debug_info);
        END IF;

	--amy call ame api clearAllApprovers by item id

	return TRUE;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Clear_AME_History_Header;

/*This procedure will be called by payables when committing the status of
'Needs Reapproval'.  It clears the AME history for the line. */
FUNCTION Clear_AME_History_Line(
                        p_invoice_id IN NUMBER,
			p_line_num IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

	--Define cursor for this line's history records
	CURSOR   Item_Cur IS
	SELECT Item_Class, Item_Id
	FROM AP_LINE_APRVL_HIST_ALL
	WHERE Invoice_ID = p_invoice_id
	AND Line_Number = p_line_num
	GROUP BY Item_Class, Item_Id;

 	l_api_name      CONSTANT VARCHAR2(200) := 'clear_ame_history_line';
        l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
        l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
        l_debug_info    VARCHAR2(2000);
	l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

	l_debug_info := 'opening item cursor';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
					l_debug_info);
        END IF;

        OPEN Item_Cur;
        LOOP

                FETCH Item_Cur INTO l_item_class, l_item_id;
                EXIT WHEN Item_Cur%NOTFOUND OR Item_Cur%NOTFOUND IS NULL;

		--amy call ame api clearAllApprovers by item id

	END LOOP;
        CLOSE Item_Cur;

	Return TRUE;


EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Clear_AME_History_Line;

/*This function resolves several open status's when a user stops the approval
 process from the application.  If these steps are not taken at the time of
stopping, the approval process would not continue correctly when restarted.*/

FUNCTION Stop_Approval(
                        p_invoice_id IN NUMBER,
			p_line_number IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN IS

	--Define cursor for wf and ame records that need to be stopped
	CURSOR   Item_Cur IS
	SELECT Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
	FROM AP_APINV_APPROVERS
	WHERE Invoice_ID = p_invoice_id
	AND NOTIFICATION_STATUS = 'SENT'
	GROUP BY Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
	ORDER BY Notification_Key;

	CURSOR   Line_Item_Cur IS
        SELECT Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
        FROM AP_APINV_APPROVERS
        WHERE Invoice_ID = p_invoice_id
	AND Line_Number = p_line_number
        AND NOTIFICATION_STATUS = 'SENT'
        GROUP BY Item_Class, Item_Id, Role_Name, Invoice_Key, Notification_Key
        ORDER BY Notification_Key;

	l_api_name      CONSTANT VARCHAR2(200) := 'Stop_Approval';
        l_item_class    AP_APINV_APPROVERS.ITEM_CLASS%TYPE;
        l_item_id       AP_APINV_APPROVERS.ITEM_ID%TYPE;
	l_invoice_id	NUMBER;
	l_invoice_key   AP_APINV_APPROVERS.INVOICE_KEY%TYPE;
        l_not_key       AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_old_not_key   AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_name	        AP_APINV_APPROVERS.ROLE_NAME%TYPE;
        l_debug_info    VARCHAR2(2000);
        --Bug4926114 Added the following 3 local variables
        l_wf_exist      BOOLEAN;
        l_approval_iteration AP_INVOICES.approval_iteration%type;
        l_end_date      DATE;
        l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name || ' <-' || p_calling_sequence;

        /*Bug4926114  Added the following part to check of code
                      to check whether workflow is active or not */
        select approval_iteration
        into   l_approval_iteration
        from   ap_invoices
        where  invoice_id=p_invoice_id;

        l_invoice_key := p_invoice_id||'_'||l_approval_iteration;

        BEGIN
          SELECT  end_date
          INTO    l_end_date
          FROM    wf_items
          WHERE   item_type = 'APINVLDP'
          AND     item_key  = l_invoice_key;

          l_wf_exist  := TRUE;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_wf_exist  := FALSE;
       END;

       If not l_wf_exist then
              return TRUE;
       end if;

	IF p_line_number IS NULL THEN
	   --End WF processes
	   WF_Engine.abortProcess(
		itemType => 'APINVLDP',
		itemKey  => l_invoice_key,
		process => 'APPROVAL_STAGING');

	   l_debug_info := 'opening item cursor';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
           END IF;

           OPEN Item_Cur;
           LOOP

                FETCH Item_Cur INTO l_item_class, l_item_id, l_name,
					l_invoice_key, l_not_key;
                EXIT WHEN Item_Cur%NOTFOUND OR Item_Cur%NOTFOUND IS NULL;


		AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.nullStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
                                itemClassIn     => l_item_class,
                                itemIdIn        => l_item_id);

		IF l_not_key <> nvl(l_old_not_key, 'dummy') THEN

			WF_Engine.abortProcess(
			itemType => 'APINVLPN',
			itemKey  => l_not_key,
			process => 'SEND_NOTIFICATIONS');

			l_old_not_key := l_not_key;
		END IF;

           END LOOP;
           CLOSE Item_Cur;

	ELSE --just a line

           l_debug_info := 'opening line item cursor';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
           END IF;

           OPEN Item_Cur;
           LOOP

                FETCH Line_Item_Cur INTO l_item_class, l_item_id, l_name,
                                        l_invoice_key, l_not_key;
                EXIT WHEN Line_Item_Cur%NOTFOUND OR Line_Item_Cur%NOTFOUND IS NULL;


                AME_API2.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.nullStatus,
                                approverNameIn  => l_name,
                                transactionTypeIn =>  'APINV',
                                itemClassIn     => l_item_class,
                                itemIdIn        => l_item_id);

                IF l_not_key <> nvl(l_old_not_key, 'dummy') THEN

                        WF_Engine.abortProcess(
                        itemType => 'APINVLPN',
                        itemKey  => l_not_key,
                        process => 'SEND_NOTIFICATIONS');

                        l_old_not_key := l_not_key;
                END IF;

           END LOOP;
           CLOSE Line_Item_Cur;
	END IF; --just a line

	return true;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Stop_Approval;

/*This function terminates any invoice approval workflow processes
 when a user turns off the 'Use Invoice Approval Workflow' payables
option. */

PROCEDURE Terminate_Approval(
			errbuf OUT NOCOPY VARCHAR2,
                        retcode           OUT NOCOPY NUMBER) IS

	--Define cursor for wf and ame records that need to be terminated
	CURSOR   key_cur IS
	SELECT  Invoice_Key, Notification_Key, Invoice_ID, Notification_status
	FROM AP_APINV_APPROVERS
	GROUP BY Invoice_Key, Notification_Key, Invoice_Id, Notification_Status
	ORDER BY Notification_Key;

	l_api_name      CONSTANT VARCHAR2(200) := 'Terminate_Approval';
	l_invoice_id	NUMBER;
	l_invoice_key   AP_APINV_APPROVERS.INVOICE_KEY%TYPE;
        l_not_key       AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_old_inv_key   AP_APINV_APPROVERS.NOTIFICATION_KEY%TYPE;
	l_not_status    AP_APINV_APPROVERS.NOTIFICATION_STATUS%TYPE;
        l_debug_info    VARCHAR2(2000);
        l_calling_sequence      VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

        l_calling_sequence := l_api_name;

	l_debug_info := 'opening key cursor';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                                        l_debug_info);
        END IF;

        OPEN key_Cur;
        LOOP

                FETCH key_Cur INTO l_invoice_key, l_not_key, l_invoice_id,
					l_not_status;

                EXIT WHEN key_Cur%NOTFOUND OR key_Cur%NOTFOUND IS NULL;

		--only the sent records are active wf processes
		IF l_not_status = 'SENT' THEN
			WF_Engine.abortProcess(
			itemType => 'APINVLPN',
			itemKey  => l_not_key,
			process => 'SEND_NOTIFICATIONS');
		END IF;

		--we only need to update at the header level once
		IF l_invoice_key <> nvl(l_old_inv_key, 'dummy') THEN

			WF_Engine.abortProcess(
			itemType => 'APINVLDP',
			itemKey  => l_invoice_key,
			process => 'APPROVAL_STAGING');

			AME_API2.clearAllApprovals(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                transactionTypeIn =>  'APINV');

			l_old_inv_key := l_invoice_key;
		END IF;

        END LOOP;
        CLOSE key_Cur;

	--Clear all iaw processing records
	DELETE FROM AP_APINV_APPROVERS;

	--Set the lines status
	UPDATE  ap_invoice_lines_all
    	SET  wfapproval_status = 'NOT REQUIRED'
  	WHERE  wfapproval_status in ('INITIATED','REQUIRED','REJECTED',
					'NEEDS REAPPROVAL','STOPPED');

	--Set the header status
	UPDATE  ap_invoices_all
    	SET  wfapproval_status = 'NOT REQUIRED'
  	WHERE  wfapproval_status in ('INITIATED','REQUIRED','REJECTED',
					'NEEDS REAPPROVAL','STOPPED');

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Terminate_Approval;


/* This function is called from AME in order to provide the relevant segment
of the account fexfield to the calling AME attribute usage*/
FUNCTION AP_Dist_Accounting_Flex(p_seg_name IN VARCHAR2,
				 p_dist_id IN NUMBER) RETURN VARCHAR2 IS

	l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
	l_result                        BOOLEAN;
	l_chart_of_accounts_id          NUMBER;
	l_num_segments                  NUMBER;
	l_segment_num                   NUMBER;
	l_reason_flex                   VARCHAR2(2000):='';
	l_segment_delimiter             VARCHAR2(1);
	l_seg_val                       VARCHAR2(50);
	l_ccid				NUMBER;
	l_sob				NUMBER;
	l_debug_info			VARCHAR2(2000);
	l_api_name      CONSTANT VARCHAR2(200) := 'AP_Dist_Accounting_Flex';

BEGIN
        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	SELECT dist_code_combination_id,set_of_books_id
	INTO l_ccid,l_sob
	FROM ap_invoice_distributions_all
	WHERE invoice_distribution_id=p_dist_id;

	SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books
       WHERE set_of_books_id = l_sob;

        l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                                'SQLGL',
                                                'GL#',
                                                l_chart_of_accounts_id);
        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_result := FND_FLEX_EXT.GET_SEGMENTS(
                                      'SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      l_ccid,
                                      l_num_segments,
                                      l_segments);

        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                    101,
                                    'GL#',
                                    l_chart_of_accounts_id,
                                    p_seg_name,
                                    l_segment_num);
        IF (NOT l_result) THEN
            l_reason_flex := FND_MESSAGE.GET;
        END IF;

        l_seg_val := l_segments(l_segment_num);

        return l_seg_val;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINVLDP', 'p_dist_accounting_flex',
             p_seg_name , p_dist_id, l_debug_info);
    raise;
END AP_Dist_Accounting_Flex;


/*get_attribute_value is called by AME when determining the value for more
complicated attributes.  It can be called at the header or line level, and
the p_attribute_name is used to determine what the return value should be.
p_context is currently a miscellaneous parameter to be used as necessary in
the future.  The goal with this function is to avoid adding a new function
for each new AME attribute.*/

FUNCTION Get_Attribute_Value(p_invoice_id IN NUMBER,
                   p_sub_class_id IN NUMBER DEFAULT NULL,
		   p_attribute_name IN VARCHAR2,
		   p_context IN VARCHAR2 DEFAULT NULL)
				 RETURN VARCHAR2 IS

	l_debug_info	VARCHAR2(2000);
	l_return_val	VARCHAR2(2000);
	l_count_pa_rel  NUMBER;
	l_sum_matched	NUMBER;
	l_sum_calc	NUMBER;
	l_line_count	NUMBER;
	l_item_count	NUMBER;
	l_api_name      CONSTANT VARCHAR2(200) := 'Get_Attribute_Value';

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	IF p_context = 'header' THEN
		--dealing with a header level attribute
		IF p_attribute_name =
			'SUPPLIER_INVOICE_EXPENDITURE_ORGANIZATION_NAME' THEN

		  SELECT organization
		    INTO l_return_val
		    FROM PA_EXP_ORGS_IT
		   WHERE organization_id=(SELECT expenditure_organization_id
				       FROM ap_invoices_all
				       WHERE invoice_id = p_invoice_id);

		ELSIF p_attribute_name= 'SUPPLIER_INVOICE_PROJECT_RELATED' THEN

			SELECT count(invoice_distribution_id)
			INTO l_count_pa_rel
			FROM ap_invoice_distributions_all
			WHERE invoice_id = p_invoice_id
			AND project_id is not null;

			IF l_count_pa_rel >0 THEN
				l_return_val := 'Y';
			ELSE
				l_return_val := 'N';
			END IF;

		ELSIF p_attribute_name= 'SUPPLIER_INVOICE_MATCHED' THEN
			--an invoice is considered matched if all item
			--lines are matched

			SELECT sum(decode(po_header_id, null, 0, 1)),
					count(line_number)
			INTO l_sum_matched, l_item_count
			FROM ap_invoice_lines_all
			WHERE invoice_id = p_invoice_id
			AND line_type_lookup_code = 'ITEM';

			IF l_sum_matched >0
				and l_sum_matched = l_item_count THEN
				l_return_val := 'Y';
			ELSE
				l_return_val := 'N';
			END IF;
		ELSIF  p_attribute_name= 'SUPPLIER_INVOICE_TAX_CALCULATED' THEN

			SELECT sum(decode(tax_already_calculated_flag, 'Y',
					1, 0)), count(line_number)
                        INTO l_sum_calc, l_line_count
                        FROM ap_invoice_lines_all
                        WHERE invoice_id = p_invoice_id
                        AND line_type_lookup_code not in ('TAX','AWT');

                        IF l_sum_calc >0 and l_sum_matched = l_line_count THEN
                                l_return_val := 'Y';
                        ELSE
                                l_return_val := 'N';
			END IF;

		END IF;

	ELSIF p_context = 'distribution' THEN
		IF p_attribute_name =
			'SUPPLIER_INVOICE_DISTRIBUTION_PO_BUYER_EMP_NUM' THEN

		   SELECT employee_number
		     INTO l_return_val
		     FROM per_all_people_f pap
		    WHERE person_id = (SELECT ph.agent_id
			   FROM ap_invoice_distributions_all aid,
				po_distributions_all pd,
				po_headers_all ph
			   WHERE pd.po_distribution_id =
				aid.po_distribution_id
			   AND  pd.po_header_id = ph.po_header_id
			   AND aid.invoice_distribution_id =
						p_sub_class_id
			   AND pd.creation_date >= pap.effective_start_date
                           AND pd.creation_date <=
                                      nvl(pap.effective_end_date,sysdate));

		ELSIF p_attribute_name =
		  'SUPPLIER_INVOICE_DISTRIBUTION_PO_REQUESTER_EMP_NUM' THEN

		  SELECT employee_number
                    INTO l_return_val
                    FROM per_all_people_f pap
		   WHERE person_id = (
                        SELECT pd.deliver_to_person_id
                          FROM ap_invoice_distributions_all aid,
                               po_distributions_all pd
                         WHERE pd.po_distribution_id =
                               aid.po_distribution_id
                           AND aid.invoice_distribution_id =
                                      p_sub_class_id
			   AND pd.creation_date >= pap.effective_start_date
			   AND pd.creation_date <=
                                      nvl(pap.effective_end_date,sysdate));
		END IF;
	ELSIF p_context = 'line item' THEN

		IF p_attribute_name = 'SUPPLIER_INVOICE_LINE_MATCHED' THEN
			SELECT decode(po_header_id, null, 'N', 'Y')
                        INTO l_return_val
                        FROM ap_invoice_lines_all
                        WHERE invoice_id = p_invoice_id
                        AND line_number = p_sub_class_id;

		END IF;
	END IF;

	return l_return_val;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINVLDP', 'get_attribute_value',
                    p_invoice_id , p_sub_class_id, p_attribute_name,
				l_debug_info);
    raise;

END Get_Attribute_Value;


/*********************************************************************
 *********************************************************************
 *********************************************************************
 **                                                                 **
 ** Methods for Dispute Main Flow and Dispute Notification Flow     **
 **                                                                 **
 *********************************************************************
 *********************************************************************
 *********************************************************************/

PROCEDURE apply_matching_hold(	p_invoice_id in number) as


begin
   --Bug5148334 added select list
	INSERT 	INTO	AP_HOLDS_all(
                INVOICE_ID,
                LINE_LOCATION_ID,
                HOLD_LOOKUP_CODE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                HELD_BY,
                HOLD_DATE,
                HOLD_REASON,
                RELEASE_LOOKUP_CODE,
                RELEASE_REASON,
                STATUS_FLAG,
                LAST_UPDATE_LOGIN,
                CREATION_DATE,
                CREATED_BY,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                ORG_ID,
                RESPONSIBILITY_ID,
                RCV_TRANSACTION_ID,
                LINE_NUMBER)
	select 	il.invoice_id invoice_id,
		NULL,
		hc.hold_lookup_code,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		hc.description description,
		NULL,
		NULL,
		'S',
		NULL,
		sysdate,
		fnd_global.user_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		fnd_global.org_id,
		null,
		null,
		il.line_number line_number
	from	ap_invoice_lines_all il,
		po_lines_all pl,
		ap_hold_codes hc
	where	il.invoice_id = p_invoice_id
	and	il.po_line_location_id is not null
	and	pl.po_line_id = il.po_line_id
	and	pl.unit_price <> il.unit_price
	and	hc.hold_lookup_code = 'PRICE'
	and 	il.line_type_lookup_code = 'ITEM'
	UNION ALL
	select 	il.invoice_id invoice_id,
			NULL,
		hc.hold_lookup_code,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		hc.description description,
		NULL,
		NULL,
		'S',
		NULL,
		sysdate,
		fnd_global.user_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		fnd_global.org_id,
		null,
		null,
		il.line_number line_number
	from	ap_invoice_lines_all il,
		po_line_locations_all ll,
		ap_hold_codes hc
	where	il.invoice_id = p_invoice_id
	and	il.po_line_location_id = ll.line_location_id
	and	il.quantity_invoiced > ll.quantity_received
	and	hc.hold_lookup_code = 'QTY REC'
	and 	il.line_type_lookup_code = 'ITEM'
	UNION ALL
	select 	il.invoice_id invoice_id,
		NULL,
		hc.hold_lookup_code,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		hc.description description,
		NULL,
		NULL,
		'S',
		NULL,
		sysdate,
		fnd_global.user_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		fnd_global.org_id,
		null,
		null,
		il.line_number line_number
	from	ap_invoice_lines_all il,
		po_line_locations_all ll,
		ap_hold_codes hc
	where	il.invoice_id = p_invoice_id
	and	il.po_line_location_id = ll.line_location_id
	and	il.quantity_invoiced > ll.quantity
	and	hc.hold_lookup_code = 'QTY ORD'
	and 	il.line_type_lookup_code = 'ITEM'
	UNION ALL
	select 	il.invoice_id invoice_id,
		NULL,
		hc.hold_lookup_code,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		hc.description description,
		NULL,
		NULL,
		'S',
		NULL,
		sysdate,
		fnd_global.user_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		fnd_global.org_id,
		null,
		null,
		il.line_number line_number
	from	ap_invoice_lines_all il,
		po_line_locations_all ll,
		ap_hold_codes hc
	where	il.invoice_id = p_invoice_id
	and	il.po_line_location_id = ll.line_location_id
	and	il.amount > ll.amount
	and	hc.hold_lookup_code = 'AMT ORD'
	and 	il.line_type_lookup_code = 'ITEM'
	UNION ALL
	select 	il.invoice_id invoice_id,
		NULL,
		hc.hold_lookup_code,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		hc.description description,
		NULL,
		NULL,
		'S',
		NULL,
		sysdate,
		fnd_global.user_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		fnd_global.org_id,
		null,
		null,
		il.line_number line_number
	from	ap_invoice_lines_all il,
		po_line_locations_all ll,
		ap_hold_codes hc
	where	il.invoice_id = p_invoice_id
	and	il.po_line_location_id = ll.line_location_id
	and	il.amount > ll.amount_received
	and	hc.hold_lookup_code = 'AMT REC'
	and 	il.line_type_lookup_code = 'ITEM';
end;


PROCEDURE is_disputable(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_org_id NUMBER;
	l_invoice_id NUMBER;
	l_num number;

begin
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	update 	ap_invoice_lines_all il
	set	disputable_flag = 'Y'
	where	il.invoice_id = l_invoice_id
	and	il.org_id = l_org_id
	and	il.line_type_lookup_code = 'ITEM'
        -- bug 4611844
	-- non-po matched or
	-- po_matched: driven by line_location_id
        and	( il.po_line_location_id is null
		  or (exists
			(select	h.line_location_id
			 from	ap_holds_all h
			 where	h.invoice_id = l_invoice_id
			 and	h.org_id = l_org_id
	        	 and    il.po_line_location_id = h.line_location_id
			 and	h.status_flag = 'S'
			 and	h.hold_lookup_code in ('PRICE', 'QTY ORD', 'QTY REC', 'AMT ORD', 'AMT REC'))));

	select 	count(*)
	into	l_num
	from	ap_invoice_lines_all
	where 	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	disputable_flag = 'Y';

	if l_num = 0 then
	  resultout := wf_engine.eng_completed||':'||'N';
	else
	  resultout := wf_engine.eng_completed||':'||'Y';
	end if;

end is_disputable;

PROCEDURE exists_receiving_hold(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_org_id NUMBER;
	l_invoice_id NUMBER;
	l_num number;

begin
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
select count(*)
into   l_num
from  ap_holds_all
	where	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	hold_lookup_code in ('QTY REC', 'AMT REC');

	if l_num = 0 then
	  resultout := wf_engine.eng_completed||':'||'N';
	else
	  resultout := wf_engine.eng_completed||':'||'Y';
	end if;

end exists_receiving_hold;

PROCEDURE delay_dispute(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) AS
BEGIN
      -- we don't need to do anything once it's timeout
      null;

END delay_dispute;


-- this procedure is called when one approver
-- is assigned to all lines, eg. in case of
-- non-po matched invoice
-- or fallback internal rep
PROCEDURE assign_generic_role_for_lines(p_line_appr_tbl IN OUT NOCOPY tLineApprovers,
                     			p_invoice_id IN NUMBER,
                        		p_generic_role_name IN VARCHAR2) AS

  cursor lines_csr is
    select line_number
    from   ap_invoice_lines_all
    where  invoice_id = p_invoice_id
    and    line_type_lookup_code = 'ITEM'
    and    nvl(disputable_flag, 'N' ) = 'Y';

  i       NUMBER := 1;

BEGIN
      FOR l_rec in lines_csr LOOP
          p_line_appr_tbl(i).line_number := l_rec.line_number;
          p_line_appr_tbl(i).role_name := p_generic_role_name;
          i := i+1;
      END LOOP;

END assign_generic_role_for_lines;

-- insert a new approver record in AP_APIN_APPROVERS table
-- whenever there is new approver-item pair found
PROCEDURE insert_approver_rec(p_item_key IN VARCHAR2,
					p_invoice_id IN NUMBER,
					p_invoice_iteration IN NUMBER,
                              p_mapping_tbl IN tLineApprovers,
                              p_invoice_source IN VARCHAR2,
                              p_ext_user_name  IN VARCHAR2) as

  l_org_id              ap_invoices_all.org_id%TYPE;
  l_notif_key           ap_apinv_approvers.notification_key%TYPE;
  l_notif_iter          ap_apinv_approvers.notification_iteration%TYPE;
  l_api_name	     	CONSTANT VARCHAR2(200) := 'insert_approver_rec';
  l_debug_info		VARCHAR2(2000);
  i                     NUMBER := 0;

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

  for i IN 1..p_mapping_tbl.COUNT loop
    l_notif_iter := get_max_notif_iteration(p_item_key) + 1;

    l_notif_key := p_item_key||'_'||p_mapping_tbl(i).role_name;

    insert into ap_apinv_approvers (
		invoice_id,
 		invoice_iteration,
		invoice_key,
		line_number,
		notification_iteration,
		notification_key,
		notification_status,
		role_name,
		orig_system,
		orig_system_id,
		external_role_name,
		approval_status,
		access_control_flag,
		source,
		last_updated_by,
		last_update_date,
		created_by,
		creation_date,
		program_application_id,
		program_id,
		program_update_date,
		request_id)
	    VALUES (
		p_invoice_id,
		p_invoice_iteration,
		p_item_key,
		p_mapping_tbl(i).line_number,
		l_notif_iter,
		l_notif_key,
		'PEND',
		p_mapping_tbl(i).role_name,
		'PER',
		p_mapping_tbl(i).approver_id,
		decode(p_invoice_source,'ISP', p_ext_user_name, null),
		'NEGOTIATE',
		'I',
		p_invoice_source,
		nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')), -1),
		sysdate,
		nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')), -1),
		sysdate,
		200,
		0,
		sysdate,
		0);

	end loop;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      -- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

end insert_approver_rec;


PROCEDURE assign_internal_rep(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) AS

  l_po_header_id		po_headers_all.po_header_id%TYPE;
  l_po_line_location_id         po_line_locations_all.line_location_id%TYPE;
  l_invoice_id   		ap_invoices_all.invoice_id%TYPE;
  l_invoice_iteration  		ap_apinv_approvers.invoice_iteration%TYPE;
  l_invoice_type                ap_invoices_all.invoice_type_lookup_code%TYPE;
  l_internal_contact_email      ap_invoices_all.internal_contact_email%TYPE;
  l_source		        ap_invoices_all.source%TYPE;
  l_ext_user_name	        fnd_user.user_name%TYPE;
  l_adhoc_role_name	        wf_local_roles.name%TYPE;
  l_adhoc_display_name	        wf_local_roles.display_name%TYPE;
  l_fallback_role_name	        wf_local_roles.name%TYPE;
  -- l_line_appr_rec            rLineApproverMappings;
  l_line_appr_tbl               tLineApprovers;
  l_adhoc_role_count		NUMBER;


  l_api_name	     	CONSTANT VARCHAR2(200) := 'assign_internal_rep';
  l_debug_info		VARCHAR2(2000);
  i                     NUMBER := 1;

  -- clear cache
  -- l_line_appr_tbl.DELETE;

  -- the following cursors will simply return all the
  -- line-approver pairs, no grouping at this point

  -- po matched invoice's internal reps deriving logic:
  -- 1. complex work owners
  cursor owners_csr is
    select ail.line_number, pll.work_approver_id, wfr.name
    from   ap_invoice_lines_all ail,
           po_line_locations_all pll,
           ap_invoices_all ai,
           wf_local_roles wfr
    where  ai.invoice_id = l_invoice_id
    and    ai.invoice_id = ail.invoice_id
    and    ai.invoice_type_lookup_code in ('STANDARD', 'CREDIT', 'PREPAYMENT')
    and    ail.line_type_lookup_code = 'ITEM'
    and    nvl(ail.disputable_flag, 'N') = 'Y'
    and    pll.line_location_id = ail.po_line_location_id
    and    pll.work_approver_id = wfr.orig_system_id
    and    wfr.orig_system = 'PER';

  -- 2. po buyers
  cursor buyers_csr is
    select ph.agent_id, ail.line_number, wfr.name
    from   ap_invoice_lines_all ail,
           po_headers_all ph,
           ap_invoices_all ai,
           wf_local_roles wfr
    where  ai.invoice_id = l_invoice_id
    and    ai.invoice_id = ail.invoice_id
    and    ai.invoice_type_lookup_code in ('STANDARD', 'CREDIT', 'PREPAYMENT')
    and    ail.line_type_lookup_code = 'ITEM'
    and    nvl(ail.disputable_flag, 'N') = 'Y'
    and    ail.po_header_id = ph.po_header_id
    and    ph.agent_id = wfr.orig_system_id
    and    wfr.orig_system = 'PER';

  -- 3. po requesters
  -- since requester_id/proj_manager are on the distribution level,
  -- we will take the one populated on the invoice line level by
  -- the matching package, which means if there is one populated,
  -- then we'll take that one - we cannot go to the distribution
  -- level to pick a random one
  cursor requesters_csr is
    select ail.requester_id, ail.line_number, wfr.name
    from   ap_invoice_lines_all ail,
           ap_invoices_all ai,
           wf_local_roles wfr
    where  ai.invoice_id = l_invoice_id
    and    ai.invoice_id = ail.invoice_id
    and    ai.invoice_type_lookup_code in ('STANDARD', 'CREDIT', 'PREPAYMENT')
    and    ail.line_type_lookup_code = 'ITEM'
    and    nvl(ail.disputable_flag, 'N') = 'Y'
    and    ail.requester_id = wfr.orig_system_id
    and    wfr.orig_system = 'PER';

  -- 4. po project managers
  cursor proj_managers_csr is
    select pt.task_manager_person_id, ail.line_number, wfr.name
    from   ap_invoice_lines_all ail,
           ap_invoices_all ai,
           pa_tasks pt,
           wf_local_roles wfr
    where  ai.invoice_id = l_invoice_id
    and    ai.invoice_id = ail.invoice_id
    and    ai.invoice_type_lookup_code in ('STANDARD', 'CREDIT', 'PREPAYMENT')
    and    ail.line_type_lookup_code = 'ITEM'
    and    nvl(ail.disputable_flag, 'N') = 'Y'
    and    ail.project_id = pt.project_id
    and    ail.task_id = pt.task_id
    and    pt.task_manager_person_id = wfr.orig_system_id
    and    wfr.orig_system = 'PER';


BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

  l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

  l_invoice_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');

  l_debug_info := l_api_name || ': get variables from workflow: itemtype = ' ||
	itemtype || ', itemkey = ' || itemkey ||
	', invoice_id = ' || l_invoice_id ||
	', iteration = ' || l_invoice_iteration;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
  END IF;

  select ai.invoice_type_lookup_code, ai.internal_contact_email,
         ai.source, u.user_name
  into   l_invoice_type, l_internal_contact_email,
         l_source, l_ext_user_name
  from   ap_invoices_all ai,
         fnd_user u
  where  invoice_id = l_invoice_id
  and    u.user_id = ai.created_by
  and    trunc(sysdate) between trunc(u.start_date)
	 and trunc(nvl(u.end_date, sysdate+1));

  l_debug_info := l_api_name || ': invoice_type = ' ||
	l_invoice_type || ', internal_contact_email = ' ||
	l_internal_contact_email || ', source = ' || l_source ||
	', external_user_name = ' || l_ext_user_name;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
  END IF;

  -- for non po matched invoice, only 2 levels:
  -- 1. internal rep email addr entered in iSP UI
  -- 2. default Payables WF role
  if ( l_invoice_type IN ('INVOICE REQUEST', 'CREDIT MEMO REQUEST') ) then
    if ( l_internal_contact_email is not null )  then
      l_debug_info := l_api_name || ': non-po matched invoice, '||
	' internal contact email = ' || l_internal_contact_email;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
      END IF;

      -- get the corresponding role name
      -- create a AP workflow ad-hoc role
      -- based on internal rep's email address entered in UI
      -- l_adhoc_role_name := 'AP_DISP_ADHOC_ROLE';
      l_adhoc_role_name := 'MRJIANG';
      l_adhoc_display_name := 'AP Dispute Ad Hoc Role';

      -- check if the same ad-hoc role has already been created
      select count(*)
      into   l_adhoc_role_count
      from   wf_local_roles
      where  name = l_adhoc_role_name
      and    display_name = l_adhoc_display_name;

      IF ( l_adhoc_role_count <= 0 ) THEN
        WF_DIRECTORY.createAdHocRole(
          	role_name => l_adhoc_role_name,
        	role_display_name => l_adhoc_display_name,
		email_address => l_internal_contact_email,
		notification_preference => 'QUERY',
        	role_description => 'AP dispute ad hoc role based on internal rep email');
        l_debug_info := l_api_name || ': non-po matched invoice, '||
		' ad hoc role created.';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
        END IF;
      END IF; -- adhoc_role_count <= 0

      assign_generic_role_for_lines(p_line_appr_tbl => l_line_appr_tbl,
                     		p_invoice_id => l_invoice_id,
                        	p_generic_role_name => l_adhoc_role_name);
      l_debug_info := l_api_name || ': non-po matched invoice, '||
	' ap_apinv_approvers table populated.';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
		l_api_name,l_debug_info);
      END IF;

    end if; -- email is not null
  else -- po matched invoice

    -- derive the internal rep for po matched invoice
    -- based on following logic:
    -- 1. PO complex work owner
    -- 2. PO buyer
    -- 3. PO shipment requester
    -- 4. PO project manager
    -- 5. default Payables WF role

    -- TODO: need to consider following case?
    -- line 1 has requester_id but line 2 doesn't
    -- and line 2 has project manager
    -- based on current design, we'll lose info. on line 2
    -- so maybe we should go through all levels either way

    -- 1st priority: PO Owner - for complex work only
    if ( l_line_appr_tbl.COUNT = 0 ) then
      i := 1;
      OPEN owners_csr;
      LOOP
        FETCH owners_csr INTO l_line_appr_tbl(i);
        EXIT WHEN owners_csr%NOTFOUND or owners_csr%NOTFOUND is null;
        -- increment the index
        i := i + 1;
      END LOOP;
      CLOSE owners_csr;
    end if;

    -- 2nd priority: Buyer - on po header level
    if ( l_line_appr_tbl.COUNT = 0 ) then
      i := 1;
      OPEN buyers_csr;
      LOOP
        FETCH buyers_csr INTO l_line_appr_tbl(i);
        EXIT WHEN buyers_csr%NOTFOUND or buyers_csr%NOTFOUND is null;
        -- increment the index
        i := i + 1;
      END LOOP;
      CLOSE buyers_csr;
    end if;

    -- 3rd priority: Requester - deliver to person on the POD
    if ( l_line_appr_tbl.COUNT = 0 ) then
      i := 1;
      OPEN requesters_csr;
      LOOP
        FETCH requesters_csr INTO l_line_appr_tbl(i);
        EXIT WHEN requesters_csr%NOTFOUND or requesters_csr%NOTFOUND is null;
        -- increment the index
        i := i + 1;
      END LOOP;
      CLOSE requesters_csr;
    end if;

    -- 4th priority: Project Manager - if there is project associated with the PO
    if ( l_line_appr_tbl.COUNT = 0 ) then
      i := 1;
      OPEN proj_managers_csr;
      LOOP
        FETCH proj_managers_csr INTO l_line_appr_tbl(i);
        EXIT WHEN proj_managers_csr%NOTFOUND or proj_managers_csr%NOTFOUND is null;
        -- increment the index
        i := i + 1;
      END LOOP;
      CLOSE proj_managers_csr;
   end if;

  end if; -- po matched invoice

  -- last priority: Payables WF role - preseeded, user needs to assign a user with it
  if ( l_line_appr_tbl.COUNT = 0 ) then
      -- get default AP fallback role
      l_fallback_role_name := WF_ENGINE.GETITEMATTRText(itemtype,
                        itemkey,
                        'FALL_BACK_INT_REP');

      assign_generic_role_for_lines(p_line_appr_tbl => l_line_appr_tbl,
                     		p_invoice_id => l_invoice_id,
                        	p_generic_role_name => l_fallback_role_name);
  end if;

  if ( l_line_appr_tbl.COUNT <> 0 ) then
    -- insert into ap_inv_apinv_approvers table
    insert_approver_rec(itemkey, l_invoice_id, l_invoice_iteration,
	l_line_appr_tbl, l_source, l_ext_user_name);

    -- update ap_invoice_lines_all table for line_owner_role
    -- make sure the line_owner_role is populated
    -- as it's used for query in Negotiation page UI
    i := 1;
    FOR i IN 1..l_line_appr_tbl.count LOOP
      update ap_invoice_lines_all
      set    line_owner_role = l_line_appr_tbl(i).role_name
      where  invoice_id = l_invoice_id
      and    line_number = l_line_appr_tbl(i).line_number
      and    line_type_lookup_code = 'ITEM'
      and    line_owner_role is null
      and    disputable_flag = 'Y';
    END LOOP;
  end if;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- TODO: close all cursors

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      -- FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO', l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

end assign_internal_rep;

PROCEDURE create_approver_rec(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as

	l_org_id NUMBER;
	l_invoice_id NUMBER;
	l_notif_key varchar2(320);

	cursor internal_reps is
	  select distinct il.line_owner_role, i.source, u.user_name
	  from	 ap_invoice_lines_all il,
		 ap_invoices_all i,
		 fnd_user u
	  where	 il.line_owner_role is not null
	  and 	 il.line_type_lookup_code = 'ITEM'
          and	 i.invoice_id = l_invoice_id
	  and 	 i.org_id = l_org_id
	  and	 i.invoice_id = il.invoice_id
	  and 	 il.org_id = l_org_id
	  and 	 u.user_id = i.created_by;

begin
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

  	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	for l_rec in internal_reps loop

	  l_notif_key := l_rec.line_owner_role||to_char(sysdate, 'ddmonyyyyssmmhh');

	  insert into ap_apinv_approvers
            (	invoice_id,
		invoice_key,
		notification_key,
		role_name,
		external_role_name,
		approval_status,
		access_control_flag,
		source)
	    values
            (	l_invoice_id,
		itemKey,
		l_notif_key,
		l_rec.line_owner_role,
		decode(l_rec.source,'ISP', l_rec.user_name, null),
		'NEGOTIATE',
		'I',
		l_rec.source);
	end loop;
end;

PROCEDURE exist_null_int_rep(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_num NUMBER;
	l_org_id NUMBER;
	l_invoice_id NUMBER;

begin
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	select 	count(*)
	into	l_num
	from	ap_invoice_lines_all
	where	org_id = l_org_id
	and	invoice_id = l_invoice_id
	and	line_owner_role is null
	and 	line_type_lookup_code = 'ITEM';

	if l_num = 0 then
	  resultout := wf_engine.eng_completed||':'||'N';
	else
	  resultout := wf_engine.eng_completed||':'||'Y';
	end if;
end;

PROCEDURE asgn_fallback_int_rep(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_role	VARCHAR2(320);
	l_org_id NUMBER;
	l_invoice_id NUMBER;

begin
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_role := wf_engine.getItemAttrText(itemType, itemKey, 'FALL_BACK_INT_REP');

	update 	ap_invoice_lines_all
	set	line_owner_role = l_role
	where	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	line_type_lookup_code = 'ITEM'
	and	line_owner_role is null
	and	disputable_flag = 'Y';

	create_approver_rec(itemtype,itemkey,actid,funcmode, resultout);

end;

PROCEDURE exist_internal_rep(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_num number;
	l_invoice_id NUMBER;
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	select 	count(*)
	into	l_num
	from	ap_apinv_approvers
	where	invoice_id = l_invoice_id
	and	invoice_key = itemKey
	and 	notification_status is NULL;

	if l_num > 0 then
	  resultout := wf_engine.eng_completed||':'||'Y';
	else
	  resultout := wf_engine.eng_completed||':'||'N';
	end if;
end;

PROCEDURE is_rejected(		itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_org_id number;
	l_f varchar2(1) := null;
	l_r varchar2(1);
	l_dispute_key varchar2(320);

begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');
	begin
		select 	'X'
		into	l_f
		from	dual
		where	exists(	select 'e' from ap_invoices_all
				where invoice_id = l_invoice_id and
				org_id = l_org_id and wfapproval_status = 'REJECTED'
				union all
				select 'e' from ap_invoice_lines_all
				where invoice_id = l_invoice_id and
				org_id = l_org_id and wfapproval_status = 'REJECTED');
	exception
		when no_data_found then
			null;
	end;

	if l_f is null then
		l_r := 'N';
	else
		l_r := 'Y';
	end if;
	resultout := wf_engine.eng_completed||':'||l_r;
end;


PROCEDURE launch_disp_notif_flow(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id            ap_invoices_all.invoice_id%TYPE;
	l_rowid rowid := null;
	l_notification_key varchar2(320);
	l_org_id number;
	l_iteration number;
	l_invoice_supplier_name VARCHAR2(80);
	l_invoice_number 	VARCHAR2(50);
	l_invoice_date 		DATE;
	l_invoice_description 	VARCHAR2(240);
	l_role_name		ap_apinv_approvers.role_name%TYPE;

	cursor  notif_process is
  	  select 	rowid, notification_key
	  from		ap_apinv_approvers
	  where		notification_status is null
	  and		invoice_id = l_invoice_id
	  and		invoice_key = itemKey
	  for 		update;

	cursor  dispute_process_csr is
  	  select 	distinct role_name,  notification_key
	  from		ap_apinv_approvers
	  -- for dispute child process, we use role_name for grouping
  	  -- notification_key is not necessary
	  where         notification_status = 'PEND'
	  and		invoice_id = l_invoice_id
	  and		invoice_key = itemKey;

	l_api_name	CONSTANT VARCHAR2(200) := 'launch_disp_notif_flow';
	l_debug_info		VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
        l_iteration := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ITERATION');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');
        l_debug_info := l_api_name || ': itemtype ='|| itemtype ||
		    ', itemkey = ' || itemkey ||
                ', l_invoice_id = ' || l_invoice_id ||
                ', l_iteration = ' || l_iteration ||
                ', l_org_id = ' || l_org_id;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;


	SELECT
      			PV.vendor_name,
      			AI.invoice_num,
      			AI.invoice_date,
      			AI.description
    	INTO
      			l_invoice_supplier_name,
      			l_invoice_number,
      			l_invoice_date,
      			l_invoice_description
    	FROM
      			ap_invoices_all AI,
     			po_vendors PV,
      			po_vendor_sites_all PVS
    	WHERE
      			AI.invoice_id = l_invoice_id AND
      			AI.vendor_id = PV.vendor_id AND
      			AI.vendor_site_id = PVS.vendor_site_id(+);

	OPEN dispute_process_csr;
	LOOP
	  FETCH dispute_process_csr into l_role_name, l_notification_key;

          EXIT WHEN dispute_process_csr%NOTFOUND;


	  wf_engine.createProcess('APINVLDN', l_notification_key, 'DISP_NOTIF_PROCESS');

          WF_ENGINE.SetItemAttrNumber('APINVLDN', l_notification_key, 'ORG_ID',l_org_id);
	  WF_ENGINE.SetItemAttrNumber('APINVLDN', l_notification_key, 'INVOICE_ID', l_invoice_id);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLDN', l_notification_key,'INVOICE_SUPPLIER_NAME',l_invoice_supplier_name);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLDN', l_notification_key,'INVOICE_NUMBER',l_invoice_number);
	  WF_ENGINE.SETITEMATTRDATE('APINVLDN', l_notification_key,'INVOICE_DATE',l_invoice_date);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLDN', l_notification_key,'INVOICE_DESCRIPTION',l_invoice_description);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLDN', l_notification_key,'NOTIFICATION_KEY',l_notification_key);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLDN', l_notification_key,'DISP_NOT_RECEIVER',l_role_name);

	  WF_ENGINE.setItemParent('APINVLDN', l_notification_key,
		'APINVLDP', itemkey, null);

	  wf_engine.startProcess('APINVLDN', l_notification_key);

	  update 	ap_apinv_approvers
	  set		notification_status = 'SENT'
   	  where		invoice_id = l_invoice_id
	  and   	invoice_key = itemkey
 	  and  	        role_name = l_role_name;

       	END LOOP;
	CLOSE dispute_process_csr;

END launch_disp_notif_flow;

PROCEDURE set_access_control(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_rowid rowid;
	l_note	varchar2(500);


	cursor notif_process is
		select 	rowid
		from	ap_apinv_approvers
		where	invoice_id = l_invoice_id
		and	notification_key = itemkey;

begin
	if(funcmode = 'RUN') then
		l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
        	                itemkey,
                	        'INVOICE_ID');
		l_note := WF_ENGINE.getItemAttrText(itemtype, itemkey, 'WF_NOTE');
		wf_engine.setItemAttrText(itemType, itemkey, 'WF_NOTE', NULL);

		open notif_process;
		fetch notif_process into l_rowid;

		update	ap_apinv_approvers
		set	access_control_flag =
			decode(access_control_flag, 	'I', 'E',
							'E', 'I',
							'I')
		where	rowid = l_rowid;
		close notif_process;
	end if;
end;

PROCEDURE clear_approver_rec(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	delete 	from ap_apinv_approvers
	where 	invoice_id = l_invoice_id
	and 	invoice_key = itemkey;
end;


PROCEDURE set_dispute_notif_reciever(
				itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_a varchar2(320);

	cursor notif_process is
		select 	decode(access_control_flag,
			'E',EXTERNAL_ROLE_NAME, ROLE_NAME)
		from	ap_apinv_approvers
		where	invoice_id = l_invoice_id
		and	notification_key = itemkey;

begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	open notif_process;
	fetch notif_process into l_a;
	close notif_process;

	wf_engine.setItemAttrText(itemType, itemKey, 'DISP_NOT_RECEIVER', l_a);
end;


PROCEDURE cancel_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_org_id number;
	l_last_updated_by number;
	l_last_update_login number;
	l_accounting_date date;
	l_message_name varchar2(30);
	l_invoice_amount number;
	l_base_amount number;
	l_temp_cancelled_amount number;
	l_cancelled_by number;
	l_cancelled_amount number;
	l_cancelled_date date;
	l_last_update_date date;
	l_original_prepayment_amount number;
	l_pay_curr_invoice_amount number;
	l_token varchar2(30);
	l_result boolean;

	cursor invoice is
		select 	gl_date,
			last_updated_by,
			last_update_login
		from	ap_invoices_all
		where	invoice_id = l_invoice_id
		and	org_id = l_org_id;
begin
  if(funcmode = 'RUN') then
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	open invoice;
	fetch invoice into l_accounting_date, l_last_updated_by, l_last_update_login;
	close invoice;

	l_result := ap_cancel_pkg.ap_cancel_single_invoice(
		l_invoice_id,
		l_last_updated_by,
		l_last_update_login,
		l_accounting_date,
		l_message_name,
		l_invoice_amount,
		l_base_amount,
		l_temp_cancelled_amount,
		l_cancelled_by,
		l_cancelled_amount,
		l_cancelled_date,
		l_last_update_date,
		l_original_prepayment_amount,
		l_pay_curr_invoice_amount,
		l_token,
		null);

	wf_engine.setItemAttrText(itemType, itemKey, 'IS_ACCEPTED', 'N');
  end if;
end;

PROCEDURE accept_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_org_id number;
begin
  if(funcmode = 'RUN') then
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	update 	ap_invoice_lines_all
	set	disputable_flag = 'N'
	where	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	line_owner_role =(
			select 	ROLE_NAME
			from	ap_apinv_approvers
			where	invoice_id = l_invoice_id
			and	notification_key = itemkey);
	wf_engine.setItemAttrText(itemType, itemKey, 'IS_ACCEPTED', 'Y');
  end if;
end;

PROCEDURE unwait_main_flow(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_r varchar2(1);
	l_invoice_id number;
	l_invoice_key varchar2(50);

	cursor notif_process is
		select 	invoice_key
		from	ap_apinv_approvers
		where	invoice_id = l_invoice_id
		and	notification_key = itemkey;
begin
	l_r := wf_engine.getItemAttrText(itemType, itemKey, 'IS_ACCEPTED');

        if l_r = 'Y' then
		l_r := 'N';
	else
	 	l_r := 'Y';
	end if;
	l_invoice_id := wf_engine.getItemAttrNumber(itemType, itemKey, 'INVOICE_ID');

	open notif_process;
	fetch notif_process into l_invoice_key;
	close notif_process;

	wf_engine.CompleteActivity(
                        itemType => 'APINVLDP',
                        itemKey  => l_invoice_key,
                        activity => 'DISPUTE_MAIN:WAIT_COMPLETION',
                        result   => l_r);
end;

PROCEDURE is_all_accepted(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_num number;
	l_invoice_id number;
	l_org_id number;
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	select 	count(*)
	into	l_num
	from	ap_invoice_lines_all
	where	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	disputable_flag = 'Y'
	and	line_type_lookup_code = 'ITEM';

	if l_num = 0 then
	  resultout := wf_engine.eng_completed||':'||'Y';
	else
	  resultout := wf_engine.eng_completed||':'||'N';
	end if;
end;

PROCEDURE is_invoice_updated(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_num number;
	l_invoice_id number;
	l_org_id number;
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	select 	count(*)
	into	l_num
	from	ap_invoice_lines_all
	where	invoice_id = l_invoice_id
	and	org_id = l_org_id
	and	creation_date <> last_update_date
	and	line_type_lookup_code = 'ITEM';

	if l_num = 0 then
	  resultout := wf_engine.eng_completed||':'||'N';
	else
	  resultout := wf_engine.eng_completed||':'||'Y';
	end if;
end;

PROCEDURE is_internal(		itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_a varchar2(1);

	cursor notif_process is
		select 	access_control_flag
		from	ap_apinv_approvers
		where	invoice_id = l_invoice_id
		and	notification_key = itemkey;

begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');

	open notif_process;
	fetch notif_process into l_a;
	close notif_process;

	if l_a = 'E' then
	  resultout := wf_engine.eng_completed||':'||'N';
	else
	  resultout := wf_engine.eng_completed||':'||'Y';
	end if;
end;

PROCEDURE is_invoice_request(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_org_id number;
	l_type varchar2(30);
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');
	begin
		select 	invoice_type_lookup_code
		into	l_type
		from	ap_invoices_all
		where 	invoice_id = l_invoice_id
		and	org_id = l_org_id;
	exception
		when no_data_found then
			null;
	end;
	if l_type = 'INVOICE REQUEST' or l_type = 'CREDIT MEMO REQUEST' then
		resultout := wf_engine.eng_completed||':'||'Y';
	else
		resultout := wf_engine.eng_completed||':'||'N';
	end if;
end;

-- update invoice type after invoice request becomes legal document
PROCEDURE update_to_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_org_id number;
begin
	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');
	update	ap_invoices_all
	set	invoice_type_lookup_code =
		decode(invoice_type_lookup_code,
			'INVOICE REQUEST', 'STANDARD',
			'CREDIT MEMO REQUEST', 'CREDIT', 'STANDARD')
        where   invoice_id = l_invoice_id;

end;

PROCEDURE is_isp_enabled(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as

begin
	resultout := wf_engine.eng_completed||':'||'Y';
end;

FUNCTION getRoleEmailAddress(	p_role	in varchar2) return varchar2 as
	display_name varchar2(320);
	email_address varchar2(2000);
	notification_pref varchar2(30);
	language varchar2(30);
	territory varchar2(30);
begin
	wf_directory.getRoleInfo(p_role, display_name, email_address, notification_pref, language, territory);
	return email_address;
end;

PROCEDURE launch_approval_notif_flow(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
	l_invoice_id number;
	l_iteration  number;
	l_rowid rowid := null;
	l_notification_key varchar2(320);
	l_org_id number;
	l_invoice_supplier_name VARCHAR2(80);
	l_invoice_number 	VARCHAR2(50);
	l_invoice_date 		DATE;
	l_invoice_description 	VARCHAR2(240);

	cursor  notif_process is
  	  select 	rowid, notification_key
	  from		ap_apinv_approvers
	  where		notification_status is null
	  and		invoice_id = l_invoice_id
	  and		invoice_key = itemKey
	  and 		rownum = 1
	  for 		update;

	l_api_name	CONSTANT VARCHAR2(200) := 'launch_approval_notif_flow';
	l_debug_info		VARCHAR2(2000);

BEGIN

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
        END IF;

	l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
	l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');

	SELECT
      			PV.vendor_name,
      			AI.invoice_num,
      			AI.invoice_date,
      			AI.description
    	INTO
      			l_invoice_supplier_name,
      			l_invoice_number,
      			l_invoice_date,
      			l_invoice_description
    	FROM
      			ap_invoices_all AI,
     			po_vendors PV,
      			po_vendor_sites_all PVS
    	WHERE
      			AI.invoice_id = l_invoice_id AND
      			AI.vendor_id = PV.vendor_id AND
      			AI.vendor_site_id = PVS.vendor_site_id(+);

        l_debug_info := l_api_name || ': itemtype = ' || itemtype
        	|| ', itemkey = ' || itemkey
        	|| ', invoice_id = ' || l_invoice_id
        	|| ', org_id = ' || l_org_id;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;


	open notif_process;

	-- LOOP
        -- we don't need to loop here as the cursor will only return one row

	fetch notif_process into l_rowid, l_notification_key;
	-- EXIT WHEN notif_process%NOTFOUND;

        l_debug_info := l_api_name || ': l_notification_key = ' || l_notification_key;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
        END IF;

	if l_rowid is not null then
	  wf_engine.createProcess('APINVLPN', itemkey, 'SEND_NOTIFICATIONS');

          l_debug_info := l_api_name || ': create APINVLPN process';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
          END IF;

          WF_ENGINE.SetItemAttrNumber('APINVLPN', itemkey, 'ORG_ID',l_org_id);
	  WF_ENGINE.SetItemAttrNumber('APINVLPN', itemkey, 'INVOICE_ID', l_invoice_id);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', itemkey,'INVOICE_SUPPLIER_NAME',l_invoice_supplier_name);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', itemkey,'INVOICE_NUMBER',l_invoice_number);
	  WF_ENGINE.SETITEMATTRDATE('APINVLPN', itemkey,'INVOICE_DATE',l_invoice_date);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', itemkey,'INVOICE_DESCRIPTION',l_invoice_description);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', itemkey,'NOTIFICATION_KEY',l_notification_key);

  	  WF_ENGINE.setItemParent('APINVLPN', itemkey, 'APINVLDP', l_notification_key, null);

          wf_engine.startProcess('APINVLPN', itemkey);

          l_debug_info := l_api_name || ': APINVLPN process started';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||
                        l_api_name,l_debug_info);
          END IF;


/*
	  wf_engine.createProcess('APINVLPN', l_notification_key, 'SEND_NOTIFICATIONS');

          WF_ENGINE.SetItemAttrNumber('APINVLPN', l_notification_key, 'ORG_ID',l_org_id);
	  WF_ENGINE.SetItemAttrNumber('APINVLPN', l_notification_key, 'INVOICE_ID', l_invoice_id);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', l_notification_key,'INVOICE_SUPPLIER_NAME',l_invoice_supplier_name);
    	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', l_notification_key,'INVOICE_NUMBER',l_invoice_number);
	  WF_ENGINE.SETITEMATTRDATE('APINVLPN', l_notification_key,'INVOICE_DATE',l_invoice_date);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', l_notification_key,'INVOICE_DESCRIPTION',l_invoice_description);
	  WF_ENGINE.SETITEMATTRTEXT('APINVLPN', l_notification_key,'NOTIFICATION_KEY',l_notification_key);

          wf_engine.startProcess('APINVLPN', l_notification_key);
*/

	  update 	ap_apinv_approvers
	  set		notification_status = 'STARTED'
   	  where		rowid = l_rowid;

	end if;
	-- END LOOP;
	close notif_process;

END launch_approval_notif_flow;

PROCEDURE revalidate_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as
  l_invoice_id	ap_invoices_all.invoice_id%TYPE;
  l_vendor_id 	ap_invoices_all.vendor_id%TYPE;
  l_org_id 	ap_invoices_all.org_id%TYPE;
  l_set_of_books_id	ap_invoices_all.set_of_books_id%TYPE;
  l_holds_count	NUMBER;
  l_approval_status VARCHAR2(240);
  l_funds_return_code VARCHAR(240);

  l_api_name	CONSTANT VARCHAR2(200) := 'revalidate_invoice';
  l_debug_info		VARCHAR2(2000);

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

  l_invoice_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'INVOICE_ID');
  l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'ORG_ID');
select vendor_id, set_of_books_id
into   l_vendor_id, l_set_of_books_id
from   ap_invoices_all
where  invoice_id = l_invoice_id;

	ap_approval_pkg.approve(
              p_run_option          => 'All',
              p_invoice_batch_id    => null,
              p_begin_invoice_date  => null,
              p_end_invoice_date    => null,
              p_vendor_id           => l_vendor_id,
              p_pay_group           => null,
              p_invoice_id          => l_invoice_id,
              p_entered_by          => 1008924,
              p_set_of_books_id     => l_set_of_books_id,
              p_trace_option        => null,
              p_conc_flag           => null,
              p_holds_count         => l_holds_count,
              p_approval_status     => l_approval_status,
              p_funds_return_code   => l_funds_return_code,
              p_calling_mode        => 'APPROVE',
              p_calling_sequence    => 'AP Workflow ',
              p_debug_switch        => 'Y',
              p_budget_control      => 'N'
        ) ;

           l_debug_info := l_api_name || ': holds count = ' ||
		l_holds_count ||', approval_status = '|| l_approval_status;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, l_debug_info);
        END IF;


end revalidate_invoice;

PROCEDURE release_holds(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2) as

  l_api_name	CONSTANT VARCHAR2(200) := 'release_holds';
  l_debug_info		VARCHAR2(2000);

BEGIN

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_IAW_PKG.'|| l_api_name);
  END IF;

  /*l_curr_calling_sequence := 'AP_APPROVAL_PKG.'||l_debug_loc||'<-'||
                             p_calling_sequence;

  IF (g_debug_mode = 'Y') THEN
    l_debug_info := 'Check hold_code to retrieve release code';
    AP_Debug_Pkg.Print(g_debug_mode, l_debug_info );
  END IF;

  IF ( p_hold_lookup_code in ('QTY ORD', 'QTY REC',
           'AMT ORD','AMT REC', 'PRICE') ) THEN

    l_release_lookup_code := 'NEGOTIATION AND APPROVED';
  END IF;

  IF ( l_release_lookup_code is not null ) THEN
    UPDATE ap_holds_all
    SET  release_lookup_code = l_release_lookup_code,
         release_reason = (SELECT description
                             FROM   ap_lookup_codes
                             WHERE  lookup_code = l_release_lookup_code
                               AND    lookup_type = 'HOLD CODE'),
         last_update_date = sysdate,
         last_updated_by = 5,
         status_flag = 'R'
    WHERE invoice_id = p_invoice_id
    -- AND   nvl(line_location_id, -1) = nvl(p_line_location_id, -1)
    -- AND   nvl(rcv_transaction_id, -1) = nvl(rcv_transaction_id, -1)
    AND   hold_lookup_code = p_hold_lookup_code
    AND   nvl(status_flag, 'x') <> 'x';
  END IF;
*/

   l_debug_info := l_api_name || ': Adjust the Release Count';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, l_debug_info);
   END IF;

end release_holds;


END AP_IAW_PKG;

/

--------------------------------------------------------
--  DDL for Package Body AP_WFAPPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WFAPPROVAL_PKG" AS
/* $Header: apiawgeb.pls 120.3.12000000.3 2007/07/20 07:09:22 schamaku ship $ */
--  Public Procedure Specifications

-- Procedure Definitions

FUNCTION ap_accounting_flex(p_ccid IN NUMBER,
			    p_seg_name IN VARCHAR2,
			    p_set_of_books_id  IN NUMBER ) RETURN VARCHAR2 IS

l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
l_result			BOOLEAN;
l_chart_of_accounts_id          NUMBER;
l_num_segments                  NUMBER;
l_segment_num	           	NUMBER;
l_reason_flex           	VARCHAR2(2000):='';
l_segment_delimiter             VARCHAR2(1);
current_calling_sequence        VARCHAR2(2000);
l_seg_val			VARCHAR2(50);
BEGIN
	SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books
       WHERE set_of_books_id = p_set_of_books_id;

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
                                      p_ccid,
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
END;

FUNCTION ap_dist_accounting_flex(p_seg_name IN VARCHAR2,
				 p_dist_id IN NUMBER) RETURN VARCHAR2 IS

l_segments                      FND_FLEX_EXT.SEGMENTARRAY;
l_result                        BOOLEAN;
l_chart_of_accounts_id          NUMBER;
l_num_segments                  NUMBER;
l_segment_num                   NUMBER;
l_reason_flex                   VARCHAR2(2000):='';
l_segment_delimiter             VARCHAR2(1);
current_calling_sequence        VARCHAR2(2000);
l_seg_val                       VARCHAR2(50);
l_ccid				NUMBER;
l_sob				NUMBER;

BEGIN

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
END;

PROCEDURE iaw_po_check(itemtype IN VARCHAR2,
			itemkey IN VARCHAR2,
			actid   IN NUMBER,
			funcmode IN VARCHAR2,
			resultout  OUT NOCOPY VARCHAR2 ) IS

	l_po_count	NUMBER;
	l_check_PO_match VARCHAR2(3);
	l_org_id 	NUMBER;
	l_debug      VARCHAR2(240);

BEGIN

--check 'Approve PO Matched' flag here
	l_check_PO_match :=	WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AAPO');

        --we need to get the org_id until I can change the raise event
	--in the invoice workbench

	SELECT org_id
	INTO l_org_id
	FROM ap_invoices_all
	WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1);

        -- lets go ahead and set the wf attribute
	WF_ENGINE.SETITEMATTRNumber(itemtype,
			itemkey,
			'APINV_AOI',
			l_org_id);

	--Now set the environment
	fnd_client_info.set_org_context(l_org_id);


	IF l_check_PO_match = 'Y' THEN

		SELECT count(invoice_distribution_id)
		INTO l_po_count
		FROM ap_invoice_distributions
		WHERE po_distribution_id is null
		AND invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1);


		IF nvl(l_po_count,0) = 0 THEN
			resultout := wf_engine.eng_completed||':'||'Y';
                        --update invoice status
                        UPDATE AP_INVOICES
                        SET wfapproval_status = 'NOT REQUIRED'
                        WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
			AND wfapproval_status <> 'MANUALLY APPROVED';
		ELSE
			resultout := wf_engine.eng_completed||':'||'N';
		END IF;
	ELSE
		resultout := wf_engine.eng_completed||':'||'N';
	END IF;

	WF_ENGINE.SETITEMATTRText(itemtype,
                        itemkey,
                        'APINV_ADB',
                        l_debug);
EXCEPTION

WHEN FND_API.G_EXC_ERROR
        THEN
        WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
                RAISE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN
        WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('APINV','SELECT_APPROVER',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END;

PROCEDURE get_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

l_next_approver	AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name 		VARCHAR2(30);
l_display_name	VARCHAR2(150);
l_debug_info	VARCHAR2(50);
l_role          VARCHAR2(50);
l_role_display  VARCHAR2(150);
l_org_id	NUMBER(15);
l_error_message               VARCHAR2(2000);
l_invoice_id 	NUMBER(15);
l_iteration 	NUMBER(9);
l_count		NUMBER(9);
l_orig_system   WF_ROLES.ORIG_SYSTEM%TYPE;     -- bug 4961253
l_orig_sys_id   WF_ROLES.ORIG_SYSTEM_ID%TYPE;  -- bug 4961253

BEGIN

	AME_API.getNextApprover(200,
                                substr(itemkey, 1, instr(itemkey,'_')-1),
                                'APINV',
                                l_next_approver);

	--Bug 2743734 instead of checking against admin approver, checking
	-- next approver status
	IF l_next_approver.approval_status = ame_util.exceptionStatus THEN
	--	raise EXCEPTION
        	l_debug_info := 'Error in AME_API.getNextApprover call';
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;

        l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'APINV_AOI');

	l_invoice_id := substr(itemkey, 1, instr(itemkey,'_')-1);
	l_iteration := substr(itemkey, instr(itemkey,'_')+1, length(itemkey));

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);
        -- bug 4961253 added user_id condition.
	IF l_next_approver.person_id is null
          AND l_next_approver.user_id is null THEN /*no approver on the list*/

		resultout := wf_engine.eng_completed||':'||'N';

		--check for prior approvers
		SELECT count(*)
		INTO l_count
		FROM ap_inv_aprvl_hist
		WHERE invoice_id = l_invoice_id
		AND iteration = l_iteration
		AND RESPONSE <> 'MANUALLY APPROVED';

		IF l_count >0 THEN
        		--update invoice header status
        		UPDATE AP_INVOICES
        		SET wfapproval_status = 'WFAPPROVED'
        		WHERE invoice_id = l_invoice_id
			AND wfapproval_status <> 'MANUALLY APPROVED';
		ELSE
			UPDATE AP_INVOICES
                        SET wfapproval_status = 'NOT REQUIRED'
                        WHERE invoice_id = l_invoice_id
                        AND wfapproval_status <> 'MANUALLY APPROVED';
		END IF;

	ELSE /*have approver*/
                -- bug 4961253 initialise the variables.
                IF l_next_approver.person_id is not null THEN
                    -- Approver is a HR employee
                    l_orig_system := 'PER';
                    l_orig_sys_id := l_next_approver.person_id;
                ELSE
                    -- Approver is a FND user
                    l_orig_system := 'FND_USR';
                    l_orig_sys_id := l_next_approver.user_id;
                END IF;
                -- end bug 4961253

               WF_DIRECTORY.GetRoleName(l_orig_system,  -- bug 4961253
                                l_orig_sys_id,           -- bug 4961253
                                l_role,
                                l_role_display);

                WF_DIRECTORY.GetUserName(l_orig_system,  -- bug 4961253
                                l_orig_sys_id,           -- bug 4961253
                                l_name,
                                l_display_name);


        	WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'APINV_ANA',
                        l_display_name);

        	WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'APINV_ANAI',
                        l_orig_sys_id); --bug4961253

        	WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'APINV_ARN',
                        l_role);

		WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AAN',
                                  l_display_name);


		--call set attributes so that notification tokens will be correct
		set_attribute_values(itemtype,itemkey);

		resultout := wf_engine.eng_completed||':'||'Y';

		insert_history(itemtype,itemkey);
	END IF;
        WF_ENGINE.SETITEMATTRText(itemtype,
                        itemkey,
                        'APINV_ADB',
                        l_debug_info);

EXCEPTION

     WHEN OTHERS THEN
    	Wf_Core.Context('APINV', 'Get_Approver',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    	raise;
END Get_Approver;

PROCEDURE update_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

l_next_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_approver	VARCHAR2(150);
l_approver_id	NUMBER(15);
l_invoice_id	NUMBER(15);
l_result	VARCHAR2(50);
l_hist_id	NUMBER(15);
l_comments	VARCHAR2(240);
l_amount       ap_invoices_all.invoice_amount%TYPE;
l_status	VARCHAR2(50);
l_org_id	NUMBER(15);
l_user_id	NUMBER(15);
l_login_id	NUMBER(15);


BEGIN
--Get attribute values to update the history table

	l_approver := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_ANA');

	l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_ANAI');

	l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AII');

	l_comments := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AC');

	l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AHI');

	--Bug 2685695
	l_result := WF_ENGINE.GetActivityAttrText(itemtype,
                                  itemkey,
				  actid,
                                  'APINV_RSLT');

        l_amount := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AIA');

        l_org_id := WF_ENGINE.GETITEMATTRNumber(itemtype,
                        itemkey,
                        'APINV_AOI');

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);


	WF_ENGINE.SetItemAttrText(itemtype,
				itemkey,
				'APINV_APC',
				l_comments);


	--update AME with response
	IF l_result = 'APPROVED' THEN
       		AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.approvedStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APINV');

	ELSE
	        AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.rejectStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APINV');
	END IF;

	--Bug 2674037 set to -1 if responding to email notification
	l_user_id := nvl(to_number(fnd_profile.value('USER_ID')),-1);
	l_login_id := nvl(to_number(fnd_profile.value('LOGIN_ID')),-1);

	IF l_result = 'APPROVED' THEN
		l_result := 'WFAPPROVED';
	END IF;

	--update the history table
	UPDATE AP_INV_APRVL_HIST
	SET	RESPONSE = l_result,
		APPROVER_COMMENTS = l_comments,
		AMOUNT_APPROVED = l_amount,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = l_user_id,
		LAST_UPDATE_LOGIN = l_login_id
	WHERE APPROVAL_HISTORY_ID = l_hist_id;

	IF l_result = 'REJECTED' THEN
               --update invoice status
               UPDATE AP_INVOICES
               SET wfapproval_status = l_result
               WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1)
		AND wfapproval_status <> 'MANUALLY APPROVED';
	END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINV', 'update_history',
                     itemtype, itemkey, to_char(actid), l_debug_info);
    raise;

END update_history;


PROCEDURE insert_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 ) IS

l_next_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_name          VARCHAR2(30);
l_approver      VARCHAR2(150);
l_approver_id   NUMBER(15);
l_invoice_id    NUMBER(15);
l_result        VARCHAR2(50);
l_org_id       NUMBER(15);
l_comments      VARCHAR2(240);
l_iteration	NUMBER(9);
l_hist_id       NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;

BEGIN
--Get attribute values to create record in the history table

        l_approver := WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_ANA');

        l_approver_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_ANAI');

        l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AII');

        l_iteration := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AI');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AOI');

	l_amount := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AIA');


        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);

	SELECT AP_INV_APRVL_HIST_S.nextval
	INTO l_hist_id
	FROM dual;

        --insert into the history table
        INSERT INTO  AP_INV_APRVL_HIST
	(APPROVAL_HISTORY_ID
        ,INVOICE_ID
        ,ITERATION
        ,RESPONSE
        ,APPROVER_ID
        ,APPROVER_NAME
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,ORG_ID
	,AMOUNT_APPROVED)
        VALUES (
	l_hist_id,
	l_invoice_id,
	l_iteration,
	'PENDING',
	l_approver_id,
	l_approver,
	nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
	sysdate,
	sysdate,
	nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),-1),
	nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),-1),
	l_org_id,
	l_amount);

	WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AHI',
				   l_hist_id);

	EXCEPTION
  		WHEN OTHERS THEN
    		Wf_Core.Context('APINV', 'insert_history',
                     itemtype, itemkey, l_debug_info);
    		raise;

END insert_history;

PROCEDURE insert_history(p_invoice_id  IN NUMBER,
                        p_iteration IN NUMBER,
                        p_org_id IN NUMBER,
                        p_status IN VARCHAR2) IS
	l_hist_id	NUMBER;
	l_amount        ap_invoices_all.invoice_amount%TYPE;
BEGIN
		--insert into the history table
		SELECT AP_INV_APRVL_HIST_S.nextval
        	INTO l_hist_id
        	FROM dual;

		SELECT invoice_amount
		INTO l_amount
		FROM AP_INVOICES_ALL
		WHERE invoice_id = p_invoice_id;

        	INSERT INTO  AP_INV_APRVL_HIST
        	(APPROVAL_HISTORY_ID
        	,INVOICE_ID
        	,ITERATION
        	,RESPONSE
        	,APPROVER_ID
        	,APPROVER_NAME
		,AMOUNT_APPROVED
        	,CREATED_BY
        	,CREATION_DATE
        	,LAST_UPDATE_DATE
        	,LAST_UPDATED_BY
        	,LAST_UPDATE_LOGIN
        	,ORG_ID)
        	VALUES (
        	l_hist_id,
        	p_invoice_id,
        	p_iteration,
		p_status,
        	 NULL,
        	FND_PROFILE.VALUE('USERNAME'),
		l_amount,
		TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
        	sysdate,
        	sysdate,
        	TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),
        	TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
        	p_org_id);

commit;

END insert_history;

PROCEDURE escalate_request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS

l_esc_approver AME_UTIL.approverRecord;
l_admin_approver AME_UTIL.approverRecord;
l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_manager_id	NUMBER(15);
l_employee_id	NUMBER(15);
l_invoice_id	NUMBER(15);
l_hist_id	NUMBER(15);
l_role		VARCHAR2(50);
l_role_display	VARCHAR2(150);
l_org_id	NUMBER(15);

BEGIN

	/*Get the current approver's manager*/
	l_employee_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_ANAI');

        l_org_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AOI');

	--Now set the environment
        fnd_client_info.set_org_context(l_org_id);

	--see if we have an HR api for this select
	SELECT supervisor_id, first_name, last_name
	INTO l_manager_id, l_esc_approver.first_name, l_esc_approver.last_name
	FROM per_employees_current_x
	WHERE employee_id = l_employee_id;

	WF_DIRECTORY.GetUserName('PER',
			l_manager_id,
			l_name,
			l_display_name);

	l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AII');

        l_hist_id := WF_ENGINE.GetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AHI');

	l_esc_approver.user_id := NULL;
	l_esc_approver.person_id := l_manager_id;
	l_esc_approver.api_insertion := ame_util.apiInsertion;
	l_esc_approver.authority := ame_util.authorityApprover;
	l_esc_approver.approval_status := ame_util.forwardStatus;

        --update AME
        /*AME_API.updateApprovalStatus2(200,
                                l_invoice_id,
                                ame_util.noResponseStatus,
                                l_employee_id,
                                null,
                                'APINV',
                                  l_esc_approver);*/

	AME_API.updateApprovalStatus2(applicationIdIn => 200,
                                transactionIdIn     => to_char(l_invoice_id),
                                approvalStatusIn    => AME_UTIL.noResponseStatus,
                                approverPersonIdIn  => l_employee_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn =>  'APINV',
				forwardeeIn       => l_esc_approver);

        --update the history table
        UPDATE AP_INV_APRVL_HIST
        SET     RESPONSE = 'ESCALATED'
        WHERE APPROVAL_HISTORY_ID = l_hist_id;

	WF_DIRECTORY.GetRoleName('PER',l_manager_id,l_role,l_role_display);

	WF_ENGINE.SetItemAttrText(itemtype,
			itemkey,
			'APINV_ANA',
			l_display_name);

	WF_ENGINE.SetItemAttrNumber(itemtype,
                        itemkey,
                        'APINV_ANAI',
                        l_manager_id);

 	WF_ENGINE.SetItemAttrText(itemtype,
                        itemkey,
                        'APINV_ARN',
                        l_role);

	insert_history(itemtype,itemkey);

END escalate_request;

PROCEDURE set_attribute_values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 ) IS

l_ret_approver VARCHAR2(50);
l_name          VARCHAR2(30);
l_display_name  VARCHAR2(150);
l_debug_info    VARCHAR2(50);
l_name          VARCHAR2(30);
l_approver      VARCHAR2(150);
l_approver_id   NUMBER(15);
l_invoice_id    NUMBER(15);
l_result        VARCHAR2(50);
l_org_id       NUMBER(15);
l_comments      VARCHAR2(240);
l_iteration     NUMBER(9);
l_vendor_site_code	VARCHAR2(15);
l_vendor_name	po_vendors.vendor_name%TYPE;
l_description	VARCHAR2(240);
l_currency	VARCHAR2(15);
l_vendor_id	NUMBER(15);
l_vendor_site_id	NUMBER(15);
l_amount        ap_invoices_all.invoice_amount%TYPE;
l_invoice_num	VARCHAR(50);
l_invoice_date  DATE;
l_prev_com	VARCHAR2(240);
l_dsp_format	VARCHAR2(50);
l_dsp_amount	VARCHAR2(100);
l_po_num	VARCHAR2(20);
l_po_count	NUMBER(9);
--bug 2785396
l_requester_id  NUMBER(15);
l_requester_name VARCHAR(250);


BEGIN

        --we need to get the org_id until I can change the raise event
        --in the invoice workbench

        SELECT org_id
        INTO l_org_id
        FROM ap_invoices_all
        WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1);

        -- lets go ahead and set the wf attribute again
        WF_ENGINE.SETITEMATTRNumber(itemtype,
                        itemkey,
                        'APINV_AOI',
                        l_org_id);

        --Now set the environment
        fnd_client_info.set_org_context(l_org_id);

	--set env so will not need to access all table
	SELECT approval_iteration,
		vendor_id,
		vendor_site_id,
		invoice_amount,
		description,
		invoice_currency_code,
		org_id,
		invoice_id,
		invoice_num,
		invoice_date,
		requester_id
	INTO
		l_iteration,
		l_vendor_id,
		l_vendor_site_id,
		l_amount,
		l_description,
		l_currency,
		l_org_id,
		l_invoice_id,
		l_invoice_num,
		l_invoice_date,
		l_requester_id
	FROM AP_INVOICES
	WHERE invoice_id = substr(itemkey, 1, instr(itemkey,'_')-1);

	SELECT vendor_name
	INTO l_vendor_name
	FROM PO_VENDORS
	WHERE vendor_id = l_vendor_id;

        SELECT vendor_site_code
        INTO l_vendor_site_code
        FROM PO_VENDOR_SITES
        WHERE vendor_site_id = l_vendor_site_id;

	SELECT count(invoice_distribution_id)
	INTO l_po_count
	FROM ap_invoice_distributions
	WHERE invoice_id = l_invoice_id
	and po_distribution_id is not null;

	IF l_po_count >1 THEN
		SELECT displayed_field
		INTO l_po_num
		FROM ap_lookup_codes
		WHERE lookup_code = 'MULTIPLE'
		AND lookup_type = 'NLS TRANSLATION';
	ELSIF l_po_count = 1 THEN
		SELECT poh.segment1
		INTO l_po_num
		FROM ap_invoice_distributions aid,
		po_distributions pod,
		po_headers poh
		WHERE aid.invoice_id = l_invoice_id
		AND aid.po_distribution_id = pod.po_distribution_id
		AND pod.po_header_id = poh.po_header_id;
	ELSE
		l_po_num := '';
	END IF;

	--Bug 2785396 get requester name
	IF l_requester_id IS NOT NULL THEN
        	SELECT full_name
        	INTO l_requester_name
        	FROM per_all_people_f pap
        	WHERE person_id = l_requester_id
                and trunc(sysdate) between effective_start_date --bug3815124
                                     and nvl(effective_end_date,trunc(sysdate));

		--Bug 2785396 Set requester name
        	WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_ARQN',
                                  l_requester_name);
	ELSE
		l_requester_name := '';
	END IF;


--Set attribute values in WF

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_APON',
                                   l_po_num);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AIDE',
                                   l_description);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AIC',
				  l_currency);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AS',
                                  l_vendor_name);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_ASSI',
                                  l_vendor_site_code);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AI',
				   l_iteration);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AIA',
                                   l_amount);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AOI',
                                   l_org_id);

        WF_ENGINE.SetItemAttrNumber(itemtype,
                                  itemkey,
                                  'APINV_AII',
                                   l_invoice_id);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AIN',
                                  l_invoice_num);

        WF_ENGINE.SetItemAttrDate(itemtype,
                                  itemkey,
                                  'APINV_AID',
                                  l_invoice_date);

	--set previous comments
	l_prev_com :=  WF_ENGINE.GetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AC');

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_APC',
                                  l_prev_com);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AC',
                                  '');

	--Bug 2645332 Changed format parameter to 30
	--set display amount
	l_dsp_format := fnd_currency.get_format_mask(l_currency,30);
	l_dsp_amount := to_char(l_amount,l_dsp_format);

        WF_ENGINE.SetItemAttrText(itemtype,
                                  itemkey,
                                  'APINV_AIAD',
                                  l_dsp_amount);


END set_attribute_values;

PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 ) IS


BEGIN

      if ( funcmode = 'FORWARD' ) then


           resultout := 'COMPLETE';

           return;

      end if;

      if ( funcmode = 'TRANSFER' ) then


           resultout := 'ERROR:WFSRV_NO_DELEGATE';

           return;

      end if;

return;
EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AP_WF',itemtype, itemkey, to_char(actid), funcmode);
        RAISE;

END;

PROCEDURE iaw_raise_event(eventname IN VARCHAR2,
                        itemkey IN VARCHAR2,
			p_org_id IN NUMBER ) IS

l_parameter_list	wf_parameter_list_t;
l_debug			varchar2(200);
l_invoice_id            NUMBER;
l_iteration             NUMBER;

BEGIN

        l_invoice_id := substr(itemkey, 1, instr(itemkey,'_')-1);
        l_iteration := substr(itemkey, instr(itemkey,'_')+1, length(itemkey));

        --Bug 2626619 Clear AME for this invoice
        AME_API.clearAllApprovals(200,
                        l_invoice_id,
                        'APINV');


	wf_event.raise(eventname,
			itemkey);

	--Bug 2739340
	commit;

EXCEPTION

WHEN OTHERS
   THEN
        WF_CORE.CONTEXT('AP_WF',eventname, itemkey);
        RAISE;

END;

/*get_attribute_value is called by AME when determining the value for more
complicated attributes.  It can be called at the header or line level, and
the p_attribute_name is used to determine what the return value should be.
p_context is currently a miscellaneous parameter to be used as necessary in
the future.  The goal with this function is to avoid adding a new function
for each new AME attribute.*/

FUNCTION get_attribute_value(p_invoice_id IN NUMBER,
                   p_dist_id IN NUMBER DEFAULT NULL,
		   p_attribute_name IN VARCHAR2,
		   p_context IN VARCHAR2 DEFAULT NULL)
				 RETURN VARCHAR2 IS

l_debug_info	VARCHAR2(2000);
l_return_val	VARCHAR2(2000);
l_count_pa_rel  NUMBER;

BEGIN

	IF p_dist_id is null THEN
		/*dealing with a header level attribute*/
		IF p_attribute_name =
			'SUPPLIER_INVOICE_EXPENDITURE_ORGANIZATION_NAME' THEN

			SELECT organization
			INTO l_return_val
			FROM PA_EXP_ORGS_IT
			WHERE organization_id=(SELECT expenditure_organization_id
					       FROM ap_invoices_all
					       WHERE invoice_id = p_invoice_id);

		ELSIF p_attribute_name = 'SUPPLIER_INVOICE_PROJECT_RELATED' THEN

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

		END IF;
	ELSE /*p_dist_id is not null*/
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
									p_dist_id
					   AND pd.creation_date >= pap.effective_start_date
                                           AND pd.creation_date <= nvl(pap.effective_end_date,sysdate));

		ELSIF p_attribute_name =
			'SUPPLIER_INVOICE_DISTRIBUTION_PO_REQUESTER_EMP_NUM' THEN

			SELECT employee_number
                        INTO l_return_val
                        FROM per_all_people_f pap
			WHERE person_id = (SELECT pd.deliver_to_person_id
                                           FROM ap_invoice_distributions_all aid,
                                                po_distributions_all pd
                                           WHERE pd.po_distribution_id =
                                                aid.po_distribution_id
                                           AND aid.invoice_distribution_id =
                                                                        p_dist_id
					   AND pd.creation_date >= pap.effective_start_date
					   AND pd.creation_date <= nvl(pap.effective_end_date,sysdate));
		END IF;
	END IF;

	return l_return_val;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('APINV', 'get_attribute_value',
                    p_invoice_id , p_dist_id, p_attribute_name, l_debug_info);
    raise;

END get_attribute_value;
--Bug 5968183
-- Added procedure to update in
PROCEDURE Update_Invoice_Status(
                               p_invoice_id IN ap_invoices_all.invoice_id%TYPE) IS

PRAGMA autonomous_transaction;
BEGIN
        UPDATE ap_inv_aprvl_hist_all
        SET RESPONSE ='CANCELLED'
        WHERE invoice_id = p_invoice_id
        AND response ='PENDING';
 commit;
END Update_Invoice_Status;

END AP_WFAPPROVAL_PKG;

/

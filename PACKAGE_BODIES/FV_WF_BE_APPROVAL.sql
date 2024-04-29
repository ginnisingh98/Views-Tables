--------------------------------------------------------
--  DDL for Package Body FV_WF_BE_APPROVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_WF_BE_APPROVAL" AS
    /* $Header: FVBEWFPB.pls 120.11.12010000.5 2009/09/30 16:34:04 amaddula ship $ */

    --  ======================================================================
    --                  Variable Naming Conventions
    --  ======================================================================
    --  1. Global Variables have the format	             "vg_<Variable_Name>"
    --  2. Procedure Level local variables have
    --     the format                                        "vl_<Variable_Name>"
    --  3. User Defined Exceptions have                      "e_<Exception_Name>"

    --  ======================================================================
    --                  Global Variable Declarations
    --  ======================================================================

  g_module_name VARCHAR2(100) := 'fv.plsql.Fv_Wf_Be_Approval.';
    vg_errbuf           VARCHAR2(1000)                          ;
    vg_retcode          NUMBER := 0                             ;

    vg_itemtype     	wf_items.item_type%TYPE;
    vg_itemkey      	wf_items.item_key%TYPE;

    vg_sob_id		Gl_Sets_Of_Books.set_of_books_id%TYPE;
    vg_doc_id		Fv_Be_Trx_Hdrs.doc_id%TYPE;
    vg_to_rpr_doc_id 	Fv_Be_Trx_Hdrs.doc_id%TYPE;
    vg_user_id 	fnd_user.user_id%TYPE;
    vg_resp_id 	fnd_responsibility.responsibility_id%TYPE;
    vg_response_note    VARCHAR2(240);
    vg_doc_type         VARCHAR2(40);
    vg_event_type       VARCHAR2(40);
    vg_calling_sequence VARCHAR2(80);
    vg_bc_mode          VARCHAR2(1);
    vg_gl_date          DATE;

    e_invalid		EXCEPTION;

    TYPE be_trx_record IS RECORD (
  	gl_date          Fv_Be_Trx_Dtls.gl_date%TYPE,
  	trx_type         Fv_Be_Transaction_Types.apprn_transaction_type%TYPE,
  	trx_code         Fv_Be_Trx_Dtls.sub_type%TYPE,
  	inc_dec_flag     VARCHAR2(15),
  	amount           Fv_Be_Trx_Dtls.amount%TYPE,
	fund_dist        Fv_Be_Trx_Dtls.budgeting_segments%TYPE );


-- BCPSA-BE enhancements

PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
	p_sob_id		  IN        NUMBER,
        p_submitter_id    IN        NUMBER,
        p_approver_id     IN        NUMBER,
        p_doc_id          IN       NUMBER,
        p_note            IN        VARCHAR2,
        p_to_rpr_doc_id   IN        NUMBER,
	p_user_id		  IN	NUMBER,
	p_resp_id         IN        NUMBER) IS

  l_module_name VARCHAR2(200) := g_module_name || 'Main';
    	vg_itemtype		VARCHAR2(30);
    	vg_itemkey	 	VARCHAR2(80);
	vl_doc_number		Fv_Be_Trx_Hdrs.doc_number%TYPE;
	vl_revision_num		Fv_Be_Trx_Hdrs.revision_num%TYPE;
	vl_ts_id		Fv_Be_Trx_Hdrs.treasury_symbol_id%TYPE;
	vl_fund_value		Fv_Be_Trx_Hdrs.fund_value%TYPE;
	vl_fund_dist		Fv_Be_Trx_Hdrs.budgeting_segments%TYPE;
	vl_budlevel_id		Fv_Be_Trx_Hdrs.budget_level_id%TYPE;
	vl_budget_desc		Fv_Budget_Levels.description%TYPE;
	vl_treasury_symbol	Fv_Treasury_symbols.treasury_symbol%TYPE;
	vl_form_name   		VARCHAR2(20);
	vl_submitter_username   VARCHAR2(30);
	vl_approver_username	VARCHAR2(30);
	vl_submitter_dispname	VARCHAR2(80);
	vl_approver_dispname	VARCHAR2(80);
	vl_item_seq   		NUMBER;
	vl_orig_system		VARCHAR2(14);
	vl_user_id		Fnd_User.user_id%TYPE;
	vl_owner 		Fnd_User.user_name%TYPE;
	vl_rev_total   		NUMBER;
	vl_curr_code	   	VARCHAR2(15);


	CURSOR get_otherattr_cur IS
	SELECT doc_number, revision_num, treasury_symbol_id,
		fund_value, budgeting_segments, budget_level_id
	FROM Fv_Be_Trx_Hdrs
	WHERE doc_id = p_doc_id
	AND set_of_books_id = p_sob_id;

	CURSOR get_tsymbol_cur IS
	SELECT treasury_symbol
	FROM Fv_Treasury_Symbols
	WHERE treasury_symbol_id = vl_ts_id
	AND set_of_books_id = p_sob_id;

	CURSOR get_buddesc_cur IS
	SELECT description
	FROM Fv_Budget_Levels
	WHERE budget_level_id = vl_budlevel_id
	AND set_of_books_id = p_sob_id;

	CURSOR get_revtotal_csr IS
	SELECT SUM(amount)
	FROM Fv_Be_Trx_Dtls
	WHERE doc_id = p_doc_id
	AND set_of_books_id = p_sob_id
	AND revision_num = vl_revision_num;

	CURSOR get_currency_csr IS
	SELECT currency_code
	FROM Gl_Sets_Of_Books
	WHERE set_of_books_id = p_sob_id;
BEGIN
	-- Set the retcode
     	retcode := 0;

	-- Check if any of the required parameters are null
	IF (p_sob_id IS NULL OR p_submitter_id IS NULL
		OR p_approver_id IS NULL OR p_doc_id IS NULL
		OR p_user_id IS NULL OR p_resp_id IS NULL) THEN

		-- Raise an error.
		errbuf:= 'Either the SOB Id,Doc Id,Submitter Id,Approver Id,'||
		'User Id or the Responsibility Id is null.'||
		'Workflow process has not been started.';
		retcode := 2;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);

		RETURN;

	END IF;

	-- Get the sequence value for the itemkey.
	SELECT fv_be_wf_itemkey_s.NEXTVAL
	INTO	vl_item_seq
	FROM 	DUAL;

	-- Set the Itemtype,Itemkey
	vg_itemtype := 'FVBEAPPR';
	vg_itemkey  := p_doc_id || '-' || vl_item_seq;

	-- Get all the other attributes which are needed in the workflow process
	OPEN get_otherattr_cur;
	FETCH get_otherattr_cur INTO
		vl_doc_number, vl_revision_num, vl_ts_id,
		vl_fund_value, vl_fund_dist, vl_budlevel_id;
	CLOSE get_otherattr_cur;

	-- Get the Treasury_Symbol
	OPEN get_tsymbol_cur;
	FETCH get_tsymbol_cur INTO vl_treasury_symbol;
	CLOSE get_tsymbol_cur;

	-- Get the Budget Level Description
	OPEN get_buddesc_cur;
	FETCH get_buddesc_cur INTO vl_budget_desc;
	CLOSE get_buddesc_cur;

	-- Get the Total Amount for the document for the revision that is processed.
	OPEN get_revtotal_csr;
	FETCH get_revtotal_csr INTO vl_rev_total;
	CLOSE get_revtotal_csr;

	-- Get the Functional Currency
	OPEN get_currency_csr;
	FETCH get_currency_csr INTO vl_curr_code;
	CLOSE get_currency_csr;

	-- Append the word Distribution to vl_fund_dist
	vl_fund_dist := 'Distribution    : '||vl_fund_dist;

	-- Derive the Orig_System for the submitter_id
	Get_Orig_System(p_submitter_id,vl_orig_system,vl_user_id,vg_errbuf,vg_retcode);

	IF (vg_retcode <> 0) THEN
		RAISE e_invalid;
	END IF;

	-- Get the Submitter Username and Display Name
	Wf_Directory.GetUserName(vl_orig_system,
				vl_user_id,
				vl_submitter_username,
				vl_submitter_dispname);

	-- Derive the Orig_System for the approver_id
	Get_Orig_System(p_approver_id,vl_orig_system,vl_user_id,vg_errbuf,vg_retcode);
	IF (vg_retcode <> 0) THEN
		RAISE e_invalid;
	END IF;

	-- Get the Approver Username and Display Name
	Wf_Directory.GetUserName(vl_orig_system,
				vl_user_id,
				vl_approver_username,
				vl_approver_dispname);

	-- Call to the Create Process
	Wf_Engine.CreateProcess(ItemType => vg_itemtype,
				ItemKey  => vg_itemkey,
				Process  => 'FV_BEAP');

	-- Set the ItemUserKey
	Wf_Engine.SetItemUserKey(ItemType => vg_itemtype,
				 ItemKey  => vg_itemkey,
				 UserKey  => vl_doc_number);

	-- Set all the attributes
	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'SOB',
				  AValue   => p_sob_id );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'DOC_ID',
				  AValue   => p_doc_id );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'SUBMITTER_ID',
				  AValue   => p_submitter_id );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'APPROVER_ID',
				  AValue   => p_approver_id );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'TO_RPR_DOC_ID',
				  AValue   => p_to_rpr_doc_id );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'NOTE',
				  AValue   => p_note );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'SUBMITTER_NAME',
				  AValue   => vl_submitter_username );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'SUBMITTER_DISP_NAME',
				  AValue   => vl_submitter_dispname );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'APPROVER_NAME',
				  AValue   => vl_approver_username );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'APPROVER_DISP_NAME',
				  AValue   => vl_approver_dispname );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'DOC_NUMBER',
				  AValue   => vl_doc_number );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'REVISION_NUM',
				  AValue   => vl_revision_num );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'TREASURY_SYMBOL',
				  AValue   => vl_treasury_symbol );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'FUND_VALUE',
				  AValue   => vl_fund_value );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'FROM_DISTRIBUTION',
				  AValue   => vl_fund_dist );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'BUDGET_LEVEL_DESC',
				  AValue   => vl_budget_desc );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => 'RESPONSE_NOTE',
                                  AValue   => vg_response_note );

 	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => 'REVISION_TOTAL',
                                  AValue   => vl_rev_total );

 	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => 'REVISION_TOTAL_DISP',
                                  AValue   => TO_CHAR(vl_rev_total)||' '||
						vl_curr_code);

	Wf_Engine.SetItemAttrText(itemtype => vg_itemtype,
                                itemkey  => vg_itemkey,
                                aname    => 'TRANSACTION_DETAILS',
                                avalue   => 'PLSQL:FV_WF_BE_APPROVAL.GET_TRX_DOC_DETAILS/'|| vg_itemtype ||':'||vg_itemkey );

	-- Populate #HDR_1(revision total amount), only if header attributes
	-- are supported.
	IF  (Wf_Core.Translate('WF_HEADER_ATTR') = 'Y') then
 		Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => '#HDR_1',
                                  AValue   => TO_CHAR(vl_rev_total)||' '||
						vl_curr_code);
	END IF;

	-- Disable the relevant attribute that should not be displayed on the
	-- notifications, based on the budget level id
	IF (vl_budlevel_id = 1) THEN
	   -- If it is Appropriation Document, then disable the distribution form.
	   Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'DIST_FORM_DETAILS',
				  AValue   => '' );

	  vl_form_name := 'Appropriation';
	ELSE
	   -- If it is Distribution Document, then disable the appropriation form.
	   Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'TRX_FORM_DETAILS',
				  AValue   => '' );

	  vl_form_name := 'Distribution';
	END IF;

	-- Set the Budget Level Form Name
	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
				  ItemKey  => vg_itemkey,
				  AName    => 'BUDGET_LEVEL_FORM_NAME',
				  AValue   => vl_form_name );

        -- Set the User Id and Responsibility Id
	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => 'USER_ID',
                                  AValue   => p_user_id );

	Wf_Engine.SetItemAttrNumber(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => 'RESP_ID',
                                  AValue   => p_resp_id );

	Wf_Engine.SetItemAttrText(ItemType => vg_itemtype,
                                  ItemKey  => vg_itemkey,
                                  AName    => '#FROM_ROLE',
                                  AValue   => vl_submitter_username );

	-- Call to set the ProcessOwner
	Wf_Engine.SetItemOwner(itemtype => vg_itemtype,
		               itemkey  => vg_itemkey,
			       owner    => vl_submitter_username);

	-- Call to the Start Process
	Wf_Engine.StartProcess(ItemType => vg_itemtype,
			       ItemKey  => vg_itemkey);

	COMMIT;

EXCEPTION
	WHEN e_invalid THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','Main',vg_itemtype,vg_itemkey,vg_errbuf,vg_retcode);

	   errbuf := vg_errbuf;
	   retcode := vg_retcode;

     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.e_invalid',errbuf);
	   Raise;

	   RETURN;
   	WHEN OTHERS THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','Main',vg_itemtype,vg_itemkey,SQLERRM,SQLCODE);

	   errbuf := SQLERRM ||' -- Error in Main procedure';
	   retcode := SQLCODE;

     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

	   Raise;
	   RETURN;
END Main;


----------------------------------------------
PROCEDURE VerifyStatus(itemtype VARCHAR2,
			itemkey	VARCHAR2,
			actid	NUMBER,
			funcmode VARCHAR2,
			resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'VerifyStatus';
  l_errbuf      VARCHAR2(1024);

	vl_doc_status	Fv_Be_Trx_Dtls.transaction_status%TYPE;
	vl_doc_status_desc VARCHAR2(80);

	CURSOR get_transtat_cur IS
		SELECT doc_status
		FROM Fv_Be_Trx_Hdrs
		WHERE set_of_books_id = vg_sob_id
		AND doc_id = vg_doc_id;

	CURSOR get_desc_cur IS
		SELECT description
		FROM Fv_Lookup_Codes
		WHERE  lookup_type = 'BE_DOC_STATUS'
		AND lookup_code = vl_doc_status;
BEGIN

	IF (funcmode = 'RUN') THEN
		-- Call to get the sob and doc id item attributes
		vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'SOB');

		vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'DOC_ID');

		OPEN get_transtat_cur;
		FETCH get_transtat_cur INTO vl_doc_status;
		CLOSE get_transtat_cur;

		IF (vl_doc_status = 'IP') THEN
			resultout := 'COMPLETE:SUCCESS';
		ELSE
			OPEN get_desc_cur;
			FETCH get_desc_cur INTO vl_doc_status_desc;
			CLOSE get_desc_cur;

			-- Set the Doc Status Desctiption Attribute
			Wf_Engine.SetItemAttrText(ItemType => itemtype,
						  ItemKey  => itemkey,
						  AName    => 'DOC_STATUS',
						  AValue   => vl_doc_status_desc );
			resultout := 'COMPLETE:FAILURE';
		END IF;
	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
     l_errbuf := SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','VerifyStatus',itemtype,itemkey,to_char(actid),l_errbuf,SQLCODE);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END VerifyStatus;


----------------------------------------------

PROCEDURE CheckRPRDocId(itemtype VARCHAR2,
			itemkey	VARCHAR2,
			actid	NUMBER,
			funcmode VARCHAR2,
			resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'CheckRPRDocId';
  l_errbuf      VARCHAR2(1024);
BEGIN

	IF (funcmode = 'RUN') THEN
		-- Call to get the to_rpr_doc_id item attributes
		vg_to_rpr_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'TO_RPR_DOC_ID');

		IF (vg_to_rpr_doc_id IS NOT NULL) THEN
			resultout := 'COMPLETE:Y';
		ELSE
			resultout := 'COMPLETE:N';
		END IF;
	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
     l_errbuf := SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','CheckRPRDocId',itemtype,itemkey,to_char(actid),l_errbuf,SQLCODE);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END CheckRPRDocId;


----------------------------------------------

PROCEDURE GetRPRDetails(itemtype VARCHAR2,
			itemkey	VARCHAR2,
			actid	NUMBER,
			funcmode VARCHAR2,
			resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'GetRPRDetails';
  l_errbuf      VARCHAR2(1024);
BEGIN

	IF (funcmode = 'RUN') THEN
		-- Call to get the to_rpr_doc_id item attributes
		vg_to_rpr_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'TO_RPR_DOC_ID');

		-- Set the attribute RPR_Trx_Details
		Wf_Engine.SetItemAttrText(itemtype => itemtype,
                              	itemkey  => itemkey,
                              	aname    => 'RPR_TRX_DETAILS',
                              	avalue   => 'PLSQL:FV_WF_BE_APPROVAL.GET_RPR_DOC_DETAILS/'||itemtype||':'||itemkey );


		resultout := 'COMPLETE';

	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
     l_errbuf := SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','GetRPRDetails',itemtype,itemkey,to_char(actid),l_errbuf,SQLCODE);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END GetRPRDetails;


----------------------------------------------

PROCEDURE ApproverPostNtf(itemtype VARCHAR2,
			itemkey	VARCHAR2,
			actid	NUMBER,
			funcmode VARCHAR2,
			resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'ApproverPostNtf';
  l_errbuf      VARCHAR2(1024);

	vl_nid	NUMBER;
	vl_ntf_result  	  VARCHAR2(30);

BEGIN

	IF (funcmode = 'RESPOND') THEN
		-- Call to get the notification_id
		vl_nid := Wf_Engine.Context_Nid;

		-- Call to get the sob_id, doc_id,to_rpr_doc_id item attributes
		vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'SOB');

		vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'DOC_ID');

		vg_to_rpr_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'TO_RPR_DOC_ID');

	 	vg_response_note := Wf_Engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'RESPONSE_NOTE');

		-- Get the notification result
		vl_ntf_result := Wf_Notification.GetAttrText(vl_nid,'RESULT');

		IF (vl_ntf_result = 'REJECTED') THEN

			-- Update the status for the doc_id to Rejected
			Update_Status(vg_sob_id,vg_doc_id,'RJ',vg_errbuf,vg_retcode);

			IF (vg_retcode <> 0) THEN
			   RAISE e_invalid;
			END IF;

			IF (vg_to_rpr_doc_id IS NOT NULL) THEN

			   -- Update the status for the to_rpr_doc_id to Rejected
			   Update_Status(vg_sob_id,vg_to_rpr_doc_id,'RJ',vg_errbuf,vg_retcode);
			   IF (vg_retcode <> 0) THEN
	   		      RAISE e_invalid;
			   END IF;

			END IF; /* To RPR Doc Id */

		END IF; /* Reject */

		resultout := Wf_Engine.Eng_Completed||':'||vl_ntf_result;
		RETURN;

	ELSIF (funcmode = 'TRANSFER') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

	ELSIF (funcmode = 'FORWARD') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

	ELSIF (funcmode = 'RUN') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

	ELSIF (funcmode = 'CANCEL') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

	END IF;

EXCEPTION
	WHEN e_invalid THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','ApproverPostNtf',itemtype,itemkey,to_char(actid),vg_errbuf,vg_retcode);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.e_invalid',vg_errbuf);
	   Raise;

	WHEN OTHERS THEN
     l_errbuf := SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','ApproverPostNtf',itemtype,itemkey,to_char(actid),l_errbuf,SQLCODE);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END ApproverPostNtf;


----------------------------------------------

PROCEDURE Update_Status(p_sob_id NUMBER,
			p_doc_id NUMBER,
			p_doc_status VARCHAR2,
			errbuf OUT NOCOPY VARCHAR2,
			retcode OUT NOCOPY NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Update_Status';
  l_errbuf      VARCHAR2(1024);

BEGIN

	-- Update the Headers table
	UPDATE Fv_Be_Trx_Hdrs
	SET doc_status = p_doc_status
	WHERE doc_id = p_doc_id
	AND set_of_books_id = p_sob_id;

	-- Update the Details table
	UPDATE Fv_Be_Trx_Dtls
	SET transaction_status = p_doc_status
	WHERE doc_id = p_doc_id
	AND set_of_books_id = p_sob_id
	AND transaction_status = 'IP';

EXCEPTION
	WHEN OTHERS THEN
	   errbuf := SQLERRM || ' -- Error in the Update_Status Procedure';
	   retcode := SQLCODE;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

	   RETURN;
END Update_Status;


----------------------------------------------

PROCEDURE ApproveDoc(itemtype VARCHAR2,
			itemkey	VARCHAR2,
			actid	NUMBER,
			funcmode VARCHAR2,
			resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'ApproveDoc';
  l_errbuf      VARCHAR2(1024);

	vl_packet_id NUMBER;
	vl_approver_id	Fnd_User.user_id%TYPE;
	x_return_status VARCHAR2(1);
 	x_status_code   VARCHAR2(100);
	vg_doc_type		VARCHAR2(25);
	vg_event_type	VARCHAR2(25);
	vg_gl_date		DATE;
	vg_budget_level_id NUMBER;
	--vg_source		VARCHAR2(5);
        vg_source    VARCHAR2(25);

BEGIN

	IF (funcmode = 'RUN') THEN
		-- Call to get the sob_id, doc_id,to_rpr_doc_id item attributes
		vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'SOB');

		vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'DOC_ID');

		vl_approver_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'APPROVER_ID');

		vg_to_rpr_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'TO_RPR_DOC_ID');

		vg_user_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'USER_ID');

		vg_resp_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
						itemkey   => itemkey,
						aname     => 'RESP_ID');


------****** Code suggested by Rani Shergil *****************
/*
CURSOR fetch_doc_info IS
    SELECT  doc_id, transaction_date, budget_level_id, source
    FROM    fv_be_trx_hdrs
    WHERE   doc_id  = p_doc_id

FOR doc_rec IN fetch_doc_info LOOP

            IF doc_rec.source = 'RPR' then

                l_doc_type := 'BE_RPR_TRANSACTIONS';

                      IF doc_rec.budget_level_id = 1 THEN

                            l_event_type := 'RPR_BA_RESERVE';

                      ELSE

                            l_event_type := 'RPR_FD_RESERVE';

                      END IF;

            ELSE

                l_doc_type := 'BE_TRANSACTIONS';

                      IF doc_rec.budget_level_id = 1 THEN

                           l_event_type := 'BA_RESERVE';

                      ELSE

                           l_event_type := 'FD_RESERVE';

                      END IF;

            END IF;

       call Main ( .........);

    END LOOP;

*/
----------------------*/*******************************

    SELECT  transaction_date, budget_level_id, source
    INTO    vg_gl_date, vg_budget_level_id, vg_source
    FROM    fv_be_trx_hdrs
    WHERE   doc_id  = vg_doc_id;

    IF vg_source = 'RPR' then
 	   vg_doc_type := 'BE_RPR_TRANSACTIONS';
           IF vg_budget_level_id = 1 THEN
        	   vg_event_type := 'RPR_BA_RESERVE';
           ELSE
                   vg_event_type := 'RPR_FD_RESERVE';
           END IF;
     ELSE
           vg_doc_type := 'BE_TRANSACTIONS';
           IF vg_budget_level_id = 1 THEN
	           vg_event_type := 'BA_RESERVE';
           ELSE
                   vg_event_type := 'FD_RESERVE';
           END IF;
     END IF;


--BCPSA-BE Enhancement -
		-- Call to the Funds Reservation Process
		Fv_Be_Fund_Pkg.Main(vg_errbuf
							,vg_retcode
							,'R'
							,vg_sob_id
							,vg_doc_id
							,vg_to_rpr_doc_id
							,vl_approver_id
						    ,vg_doc_type
       		                    ,vg_event_type
         	                    ,vg_gl_date
					        ,x_return_status
       		                    ,x_status_code
							,vg_user_id
							,vg_resp_id);

		IF (x_return_status = 'S') THEN
			resultout := 'COMPLETE:SUCCESS';
		ELSE
			-- Set the attribute for the packet id
			Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                       		      	itemkey  => itemkey,
                       		       	aname    => 'PACKET_ID',
                       		       	avalue   => vl_packet_id );

			resultout := 'COMPLETE:FAILURE';
		END IF;
	ELSIF (funcmode = 'CANCEL') THEN
		resultout := 'COMPLETE';
		RETURN;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
     l_errbuf := vg_errbuf||SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','ApproveDoc',itemtype,itemkey,to_char(actid),vg_errbuf,vg_retcode);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END ApproveDoc;


----------------------------------------------

PROCEDURE TimeoutPostNtf(itemtype VARCHAR2,
                        itemkey VARCHAR2,
                        actid   NUMBER,
                        funcmode VARCHAR2,
                        resultout IN OUT NOCOPY VARCHAR2 ) IS
  l_module_name VARCHAR2(200) := g_module_name || 'TimeoutPostNtf';
  l_errbuf      VARCHAR2(1024);

BEGIN

        IF (funcmode = 'RESPOND') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

        ELSIF (funcmode = 'TRANSFER') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

        ELSIF (funcmode = 'FORWARD') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

        ELSIF (funcmode = 'RUN') THEN

                -- Call to get the sob_id, doc_id,to_rpr_doc_id item attributes
                vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'SOB');

                vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'DOC_ID');

                vg_to_rpr_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey   => itemkey,
                                                aname     => 'TO_RPR_DOC_ID');

		-- Get Revision Number for doc_id
		Get_Revision_Number(vg_sob_id,vg_doc_id,vg_errbuf,vg_retcode);

		IF (vg_retcode <> 0) THEN
	           RAISE e_invalid;
		END IF;

                IF (vg_to_rpr_doc_id IS NOT NULL) THEN

			-- Get Revision Number for to_rpr_doc_id
			Get_Revision_Number(vg_sob_id,vg_to_rpr_doc_id,vg_errbuf,vg_retcode);

		        IF (vg_retcode <> 0) THEN
	           	   RAISE e_invalid;
		        END IF;
                END IF;

		resultout := Wf_Engine.Eng_Completed || ':' || Wf_Engine.Eng_Null;
		RETURN;

        ELSIF (funcmode = 'CANCEL') THEN
		resultout := Wf_Engine.Eng_Null;
		RETURN;

        END IF;

EXCEPTION
	WHEN e_invalid THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','TimeoutPostNtf',itemtype,itemkey,to_char(actid),vg_errbuf,vg_retcode);
	   Wf_Core.Context('FV_WF_BE_APPROVAL','ApproveDoc',itemtype,itemkey,to_char(actid),vg_errbuf,vg_retcode);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.e_invalid',vg_errbuf);
	   Raise;

	WHEN OTHERS THEN
     l_errbuf := SQLERRM;
	   Wf_Core.Context('FV_WF_BE_APPROVAL','TimeoutPostNtf',itemtype,itemkey,to_char(actid),l_errbuf,SQLCODE);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
	   Raise;
END TimeoutPostNtf;


----------------------------------------------

PROCEDURE Get_Revision_Number(sob_id NUMBER,
			   doc_id NUMBER,
			   errbuf OUT NOCOPY VARCHAR2,
			   retcode OUT NOCOPY NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_Revision_Number';
  l_errbuf      VARCHAR2(1024);

	CURSOR get_revnum_cur IS
		SELECT MAX(revision_num)
		FROM Fv_Be_Trx_Dtls
		WHERE set_of_books_id = sob_id
		AND doc_id = doc_id
		AND transaction_status = 'IP';

	vl_rev_num	Fv_Be_Trx_Dtls.revision_num%TYPE;

BEGIN

	--  Get the revision number for doc_id
	OPEN get_revnum_cur;
	FETCH get_revnum_cur INTO vl_rev_num;
	CLOSE get_revnum_cur;

	IF (vl_rev_num = 0) THEN
                -- Update the status for the doc_id to Incomplete
                Update_Status(sob_id,doc_id,'IN',errbuf,retcode);
	ELSE
                -- Update the status for the doc_id to Requires Reapproval
                Update_Status(sob_id,doc_id,'RA',errbuf,retcode);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	   errbuf := SQLERRM || ' -- Error in the Get_Revision_Number Procedure';
	   retcode := SQLCODE;
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

	   RETURN;
END Get_Revision_Number;


----------------------------------------------

PROCEDURE Get_Orig_System(p_user_id NUMBER,
		     p_orig_system OUT NOCOPY VARCHAR2,
		     p_new_user_id OUT NOCOPY NUMBER,
		     errbuf OUT NOCOPY VARCHAR2,
		     retcode OUT NOCOPY NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_Orig_System';
  l_errbuf      VARCHAR2(1024);

	CURSOR get_empid_cur(c_user_id Fnd_User.user_id%TYPE) IS
	SELECT employee_id
	FROM Fnd_User
	WHERE user_id = c_user_id;

	vl_emp_id		Fnd_User.employee_id%TYPE;
BEGIN

	OPEN get_empid_cur(p_user_id);
	FETCH get_empid_cur INTO vl_emp_id;
	CLOSE get_empid_cur;

	IF (vl_emp_id IS NULL) THEN
		p_new_user_id := p_user_id;
		p_orig_system := 'FND_USR';
	ELSE
		p_new_user_id := vl_emp_id;
		p_orig_system := 'PER';
	END IF;

EXCEPTION
	WHEN OTHERS THEN
           errbuf := SQLERRM || ' -- Error in the Get_Orig_System Procedure';
           retcode := SQLCODE;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

           RETURN;
END Get_Orig_System;


----------------------------------------------

PROCEDURE Get_Trx_Doc_Details( document_id IN VARCHAR2,
				display_type IN VARCHAR2,
				document IN OUT NOCOPY VARCHAR2,
				document_type IN OUT NOCOPY VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_Trx_Doc_Details';
  l_errbuf      VARCHAR2(1024);
    vl_document 	VARCHAR2(32000) := 'Get_Trx_Doc_Details';
BEGIN

   -- Derive the itemtype
   vg_itemtype := SUBSTR(document_id, 1, INSTR(document_id, ':') - 1);

   -- Derive the itemkey
   vg_itemkey := SUBSTR(document_id, INSTR(document_id, ':') + 1);

   -- Call to get the sob and doc id item attributes
   vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype  => vg_itemtype,
                                            itemkey   => vg_itemkey,
                                            aname     => 'SOB');

   vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => vg_itemtype,
                                            itemkey   => vg_itemkey,
                                            aname     => 'DOC_ID');

   -- Call to build the document
   Build_Document('N',display_type,vl_document,vg_errbuf,vg_retcode);

   IF (vg_retcode <> 0) THEN
	Raise e_invalid;
   END IF;

   document := vl_document;

EXCEPTION
	WHEN e_invalid THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','Get_Trx_Doc_Details',vg_itemtype,vg_itemkey,vg_errbuf,vg_retcode);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.e_invalid',vg_errbuf);
	   Raise;
	WHEN OTHERS THEN
           l_errbuf := SQLERRM;
           Wf_Core.Context('FV_WF_BE_APPROVAL','Get_Trx_Doc_Details',vg_itemtype,vg_itemkey,l_errbuf,SQLCODE);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
           Raise;
END Get_Trx_Doc_Details;


----------------------------------------------

PROCEDURE Get_RPR_Doc_Details( document_id IN VARCHAR2,
				display_type IN VARCHAR2,
				document IN OUT NOCOPY VARCHAR2,
				document_type IN OUT NOCOPY VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Get_RPR_Doc_Details';
  l_errbuf      VARCHAR2(1024);
    vl_document 	VARCHAR2(32000) := 'Get_RPR_Doc_Details';
BEGIN

   vg_itemtype := SUBSTR(document_id, 1, INSTR(document_id, ':') - 1);

   vg_itemkey := SUBSTR(document_id, INSTR(document_id, ':') + 1);

   -- Call to get the sob and doc id(in this case,it is the rpr doc id)item attributes
   vg_sob_id := Wf_Engine.GetItemAttrNumber(itemtype  => vg_itemtype,
                                            itemkey   => vg_itemkey,
                                            aname     => 'SOB');

   vg_doc_id := Wf_Engine.GetItemAttrNumber(itemtype => vg_itemtype,
                                            itemkey   => vg_itemkey,
                                            aname     => 'TO_RPR_DOC_ID');

   -- Call to build the document
   Build_Document('Y',display_type,vl_document,vg_errbuf,vg_retcode);

   IF (vg_retcode <> 0) THEN
	Raise e_invalid;
   END IF;

   document := vl_document;

EXCEPTION
	WHEN e_invalid THEN
	   Wf_Core.Context('FV_WF_BE_APPROVAL','Get_RPR_Doc_Details',vg_itemtype,vg_itemkey,vg_errbuf,vg_retcode);
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.e_invalid',vg_errbuf);
	   Raise;
	WHEN OTHERS THEN
           l_errbuf := SQLERRM;
           Wf_Core.Context('FV_WF_BE_APPROVAL','Get_RPR_Doc_Details',vg_itemtype,vg_itemkey,l_errbuf,SQLCODE);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
           Raise;
END Get_RPR_Doc_Details;


----------------------------------------------

PROCEDURE Build_Document(rpr_flag VARCHAR2,
			disp_type VARCHAR2,
			doc       OUT NOCOPY VARCHAR2,
			errbuf	  OUT NOCOPY VARCHAR2,
			retcode   OUT NOCOPY NUMBER) IS
  l_module_name VARCHAR2(200) := g_module_name || 'Build_Document';
  l_errbuf      VARCHAR2(1024);

    vl_trx_record  be_trx_record;
    NL 	                VARCHAR2(1) := fnd_global.newline;
    vl_document 	VARCHAR2(32000) := 'Build_Document';
   vl_date_str VARCHAR2(32000) DEFAULT NULL;

CURSOR get_trx_cur IS
	SELECT D.gl_date,
		T.apprn_transaction_type ,
		D.sub_type ,
		decode(D.increase_decrease_flag,'I','Increase','Decrease') ,
		D.amount ,
		D.budgeting_segments
	FROM Fv_Be_Trx_Dtls D, Fv_Be_Transaction_Types T
	WHERE D.set_of_books_id = vg_sob_id
	AND D.doc_id = vg_doc_id
	AND D.transaction_type_id = T.be_tt_id
	AND D.revision_num = (SELECT MAX(revision_num)
				FROM Fv_Be_Trx_Hdrs
				WHERE doc_id = vg_doc_id
				AND set_of_books_id = vg_sob_id)
	ORDER BY D.gl_date ;

BEGIN

   IF (rpr_flag = 'N') THEN
        vl_document := NL || NL ||'<P><B> Transaction Details </B>';
   ELSE
        vl_document := NL || NL ||'<P><B> Re-Programming Transaction Details </B>';
   END IF;

   IF (disp_type = 'text/html') THEN
        vl_document := vl_document || ' <TABLE border=1 cellpadding=2 cellspacing=1> '
|| NL;

        vl_document := vl_document ||'<TR> '||NL;

        vl_document := vl_document ||'<TH>GL Date</TH> '||NL;

        vl_document := vl_document ||'<TH>Transaction Type</TH> '||NL;

        vl_document := vl_document ||'<TH>Transaction Code</TH> '||NL;

        vl_document := vl_document ||'<TH>Inc/Dec</TH> '||NL;

        vl_document := vl_document ||'<TH>Amount</TH> '||NL;

        vl_document := vl_document ||'<TH>Fund Distribution</TH> '||NL;

        vl_document := vl_document ||'</TR> '||NL;

        OPEN get_trx_cur;

        LOOP
                FETCH get_trx_cur INTO vl_trx_record;

                EXIT WHEN get_trx_cur%NOTFOUND;

                vl_document := vl_document ||'<TR>'||NL;


--		vl_document := vl_document ||'<TD nowrap align=CENTER>'|| nvl(to_char(vl_trx_record.gl_date), ' ') ||'</TD>'||NL;
/*
 *FOR BUG 7538261
 * Is modified to use TO_CHAR(datetime) with NLS_CALENDAR
 * parameter.
 **/
/*
  Modified for bug 7713511.
*/
--   IF FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', vg_user_id) IS
--    NOT NULL THEN

 IF ((FND_RELEASE.MAJOR_VERSION = 12 and FND_RELEASE.minor_version >= 1 and
      FND_RELEASE.POINT_VERSION >= 1 )
        or (FND_RELEASE.MAJOR_VERSION > 12)) THEN
  /*
   * Execute for versions equal and above R12.1.1
    */
           IF vg_user_id IS NULL OR vg_user_id = '' THEN
             vg_user_id:=fnd_global.user_id;
           END IF;
        -- BUG 8974285
        vl_date_str := nvl(to_char(vl_trx_record.gl_date,
                FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',
                                                      vg_user_id),
                                      'NLS_CALENDAR = ''' ||
                        NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR',
vg_user_id),'GREGORIAN') || ''''),'');
           IF (disp_type=wf_notification.doc_html) THEN
              vl_date_str := '<BDO DIR="LTR">' ||
                                      vl_date_str || '</BDO>';
             END IF;
       ELSE
          vl_date_str := nvl(to_char(vl_trx_record.gl_date),'');
       END IF;

      vl_document := vl_document ||'<TD nowrap align=CENTER>'||
vl_date_str||'</TD>'||NL;

                vl_document := vl_document ||'<TD nowrap align=CENTER>'|| nvl(vl_trx_record.trx_type, ' ') ||'</TD>'||NL;

                vl_document := vl_document ||'<TD nowrap align=CENTER>'|| nvl(vl_trx_record.trx_code, ' ') ||'</TD>'||NL;

                vl_document := vl_document ||'<TD nowrap align=CENTER>'|| nvl(vl_trx_record.inc_dec_flag, ' ') ||'</TD>'||NL;

                vl_document := vl_document ||'<TD nowrap align=RIGHT>'|| nvl(to_char(vl_trx_record.amount,'999,999,999,990.90'), 0) ||'</TD>'||NL;

                vl_document := vl_document ||'<TD align=CENTER>'|| nvl(vl_trx_record.fund_dist, ' ') ||'</TD>'||NL;

                vl_document := vl_document ||'</TR>'||NL;

        END LOOP;

        CLOSE get_trx_cur;

        vl_document := vl_document ||'</TABLE> </P>'||NL;

        doc := vl_document;
   END IF;

EXCEPTION
	WHEN OTHERS THEN
           l_errbuf := SQLERRM;
           Wf_Core.Context('FV_WF_BE_APPROVAL','Get_RPR_Doc_Details',vg_itemtype,vg_itemkey,l_errbuf,SQLCODE);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
           Raise;
END Build_Document;

END Fv_Wf_Be_Approval;

/

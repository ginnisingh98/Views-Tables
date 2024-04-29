--------------------------------------------------------
--  DDL for Package Body QA_RESULTS_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULTS_WF_PKG" as
/* $Header: qanotb.pls 115.2 2003/10/10 19:38:41 ksoh ship $ */



PROCEDURE process_updates  (
	itemtype IN VARCHAR2,
        itemkey  IN VARCHAR2,
        actid    IN NUMBER,
        funcmode IN VARCHAR2,
        result   OUT NOCOPY VARCHAR2) IS

    l_value  varchar2(2000);
    l_occurrence number;
    l_plan_id number;
    l_collection_id number;
    l_PCA_ID number; --plan char action id
    l_org_id number;
    l_txnheader_id number;
    QA_RES_UPDATE_FAILED exception;

    l_char_id number;
    l_wf_attr VARCHAR2(1000);

    do_update BOOLEAN := FALSE;

    elements qa_validation_api.ElementsArray;

        error_array qa_validation_api.ErrorArray;
        message_array qa_validation_api.MessageArray;
        return_status VARCHAR2(1);
        action_result VARCHAR2(1);
        msg_count NUMBER;
        msg_data VARCHAR2(2000);

    cursor c1(c_pca_id NUMBER) IS
	SELECT 	qpcao.token_name, qpcao.char_id
	FROM qa_plan_char_action_outputs qpcao
	WHERE qpcao.plan_char_action_id = c_pca_id
	AND qpcao.token_name like 'X_%';

    cursor txn_hdr_cur IS
	SELECT qr.txn_header_id
	FROM qa_results qr
	WHERE qr.plan_id = l_plan_id
	AND qr.collection_id = l_collection_id
	AND qr.occurrence = l_occurrence;

BEGIN

    IF (funcmode = 'RUN') THEN  --this needs to be RUN i guess

/*	insert into ilam1 values ('Got here... '||itemtype||'-'||itemkey||'-'||actid||'-'||funcmode);
commit; */
	l_plan_id := to_number(wf_engine.getitemattrtext(
        		 	itemtype => itemtype,
            			itemkey  => itemkey,
            			aname    => 'PLAN_ID'));

	l_org_id := to_number(wf_engine.getitemattrtext(
        		 	itemtype => itemtype,
            			itemkey  => itemkey,
            			aname    => 'ORG_ID'));

	l_collection_id := wf_engine.getitemattrnumber(
				itemtype => itemtype,
				itemkey => itemkey,
				aname => 'COLLECTION_ID');

	l_occurrence := wf_engine.getitemattrnumber(
				itemtype => itemtype,
				itemkey => itemkey,
				aname => 'OCCURRENCE');

	l_PCA_ID := wf_engine.getitemattrnumber(
				itemtype => itemtype,
				itemkey => itemkey,
				aname => 'PCA_ID');
	--insert into ilam1 values ('Before Loop'); commit;
	FOR token_rec IN c1(l_PCA_ID) LOOP

		do_update := TRUE;

		l_char_id := token_rec.char_id;
		l_wf_attr := token_rec.token_name;

		l_value := wf_engine.getitemattrtext(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => l_wf_attr);

		elements(l_char_id).value := l_value;
	END LOOP;

	if (do_update) THEN
	 qa_results_pub.update_row(
            p_api_version => 1.0,
	    p_init_msg_list => fnd_api.g_true,
            p_commit => fnd_api.g_true,
            p_plan_id => l_plan_id,
            p_org_id => l_org_id,
            p_enabled_flag => 2,
            p_collection_id => l_collection_id,
            p_occurrence => l_occurrence,
            x_row_elements => elements,
            x_msg_count => msg_count,
            x_msg_data  => msg_data,
            x_error_array => error_array,
            x_message_array => message_array,
            x_return_status => return_status,
            x_action_result => action_result);

	if (return_status = FND_API.G_RET_STS_ERROR)
	then
	  FOR i IN error_array.FIRST .. error_array.LAST LOOP
            qa_skiplot_utility.insert_error_log
		(p_module_name => 'qa_results_wf_pkg.process_updates',
		 p_error_message => itemtype|| '-' || itemkey
			|| ' *** '
		 	|| 'char_id: '||error_array(i).element_id
			|| ' Error: ' || error_array(i).error_code);
   	  END LOOP;
	  raise QA_RES_UPDATE_FAILED;
	end if;--endif for x_return_status check

	--insert into ilam1 values ('Update has been called');

	OPEN txn_hdr_cur;
	FETCH txn_hdr_cur INTO l_txnheader_id;
	CLOSE txn_hdr_cur;

        QA_PARENT_CHILD_PKG.insert_history_auto_rec(
			l_plan_id,
			l_txnheader_id,
			1, 4);
	--commit;
	END IF; -- end if do_update check

	-- if commit is needed for above call
	-- do an autonomous commit, for now i think commit not needed

    END IF; --end if funcmode = RESPOND

EXCEPTION
	WHEN OTHERS THEN
	wf_core.context('qa_results_wf_pkg', 'process_updates',
			itemtype, itemkey, to_char(actid), funcmode);
	raise;

END process_updates;

PROCEDURE set_results_url  (itemtype IN VARCHAR2,
    itemkey  IN VARCHAR2,
    actid    IN NUMBER,
    funcmode IN VARCHAR2,
    result   OUT NOCOPY VARCHAR2)

IS
	url_string VARCHAR2(1000);
	l_plan_id VARCHAR2(1000);
	l_template_plan_id QA_PLANS.TEMPLATE_PLAN_ID%TYPE;
	l_collection_id NUMBER;
	l_occurrence NUMBER;
	extension VARCHAR2(5);
	search_clause VARCHAR2(1000);
	search_vars VARCHAR2(1000);
	HGRID_QUERY_FROM_PCTXT VARCHAR2(250) := 'FROM_PCTXT';
	PCTXT_VAR_PREFIX VARCHAR2(250) := '__QA_SSQR_PCTXT_';
	PCTXT_REQUERY_HGRID VARCHAR2(250) := PCTXT_VAR_PREFIX || 'RequeryHgrid';
	PCTXT_CLEAR_HGRID VARCHAR2(250) := PCTXT_VAR_PREFIX || 'ClearHgrid';
	PCTXT_HGRID_SEARCH_CLAUSE VARCHAR2(250) := PCTXT_VAR_PREFIX || 'HgridSearchClauseStr';
	PCTXT_HGRID_SEARCH_VARS VARCHAR2(250) := PCTXT_VAR_PREFIX || 'HgridSearchVarsStr';
	cursor c(p_plan_id VARCHAR2) is
		select template_plan_id
		from qa_plans
		where plan_id = p_plan_id;


BEGIN
	l_plan_id := wf_engine.getitemattrtext(
        		 	itemtype => itemtype,
            			itemkey  => itemkey,
            			aname    => 'PLAN_ID');

	l_collection_id := wf_engine.getitemattrnumber(
				itemtype => itemtype,
				itemkey => itemkey,
				aname => 'COLLECTION_ID');

	l_occurrence := wf_engine.getitemattrnumber(
				itemtype => itemtype,
				itemkey => itemkey,
				aname => 'OCCURRENCE');

    -- determine if the function name contains NCM_ or CAR_ based on template plan id
    open c(l_plan_id);
    fetch c into l_template_plan_id;
    close c;

    if l_template_plan_id in (18, 35) then
	extension := 'NCM_';
    elsif l_template_plan_id = 65 then
	extension := 'CAR_';
    else
        extension := '';
    end if;

    search_clause := 'plan_id=:1 and occurrence=:2 and collection_id=:3';
    search_clause := replace(search_clause, ' ', '%20');
    search_clause := replace(search_clause, '=', '%3D');
    search_vars := l_plan_id || '@' || l_occurrence || '@' || l_collection_id;

    url_string := 'JSP:/OA_HTML/OA.jsp?OAFunc=QA_SSQR_HGRID_' || extension || 'PAGE' ||
	'&' || 'OAHP=QA_SSQR_APPLICATION_MENU' ||
	'&' || 'OASF=QA_SSQR_HGRID_' || extension || 'PAGE' ||
        '&' || PCTXT_REQUERY_HGRID || '=' || HGRID_QUERY_FROM_PCTXT ||
        '&' || PCTXT_HGRID_SEARCH_CLAUSE || '=' || search_clause ||
        '&' || PCTXT_HGRID_SEARCH_VARS || '=' || search_vars ||
        '&' || 'RootPlanId=' || l_plan_id ||
        '&' || 'NtfId=-' ||
        '&' || '#NID-';

      wf_engine.setitemattrtext(
       itemtype => itemtype,
       itemkey  => itemkey,
       aname    => 'RESULTS_URL',
       avalue   => url_string);

EXCEPTION
	WHEN OTHERS THEN
	wf_core.context('qa_results_wf_pkg', 'set_results_url',
			itemtype, itemkey, to_char(actid), funcmode);
	raise;

END set_results_url;

END qa_results_wf_pkg;

/

--------------------------------------------------------
--  DDL for Package Body PSP_ER_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ER_WORKFLOW" as
/* $Header: PSPERWFB.pls 120.11.12010000.7 2008/08/05 10:12:54 ubhat ship $ */
procedure fatal_err_occured(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is

  l_request_id integer;
  l_retry_request_id	NUMBER(15, 0);
  cursor fatal_error_cursor is
  select count(*)
  from psp_report_errors
  where request_id = l_request_id
    and	(l_retry_request_id = -1
	OR retry_request_id = l_retry_request_id)
    and message_level  = 'E';   --- count fatal errors that require
                                --- to stop the process.
  cursor count_er is
  select count(*)
  from psp_eff_reports
  where status_code IN ('N', 'A')
    and request_id = l_request_id;

  l_er_count integer;
  l_error_count integer;
begin
  ---hr_utility.trace_on('Y','WF-1');
  l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');

  l_retry_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RETRY_REQUEST_ID');

    hr_utility.trace('er_workflow --> FATAL error .. request_id = '||l_request_id);
  open fatal_error_cursor;
  fetch fatal_error_cursor into l_error_count;
  close fatal_error_cursor;

  hr_utility.trace('er_workflow --> FATAL error .. count = '||l_er_count);
  open count_er;
  fetch count_er into l_er_count;
  close count_er;

  hr_utility.trace('er_workflow --> FATAL error .. count = '||l_error_count);
  if (l_er_count + l_error_count) = 0 then
      result := 'COMPLETE:NOERRORNOREPORT';
  elsif (l_er_count > 0) AND (l_error_count > 0) THEN
      result := 'COMPLETE:ERRORSANDREPORTS';
  elsif (l_er_count = 0) AND (l_error_count > 0) THEN
      result := 'COMPLETE:ALLERRORSNOREPORT';
  elsif (l_er_count > 0) AND (l_error_count = 0) THEN
      result := 'COMPLETE:NOERRORALLREPORTS';
  end if;

exception
 when others then
    -- populate stack with error message
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'FATAL_ERR_OCCURED', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

/*  Main Procedure */
procedure pyugen_er_workflow(pactid in number) as
  cursor get_request_id is
    select request_id
    from pay_payroll_actions
    where pactid = payroll_action_id;
    l_request_id number;

CURSOR	orig_request_id_cur IS
SELECT	paa.request_id
FROM	fnd_concurrent_requests fcr,
	pay_payroll_actions paa
WHERE	fcr.request_id = l_request_id
AND	paa.payroll_action_id = TO_NUMBER(fcr.argument2);

CURSOR	conc_program_name_cur IS
SELECT	fcp.concurrent_program_name
FROM	fnd_concurrent_programs fcp,
	fnd_concurrent_requests fcr
WHERE	fcp.concurrent_program_id = fcr.concurrent_program_id
AND	fcr.request_id = l_request_id;

CURSOR	original_request_id_cur IS
SELECT	request_id
FROM	psp_report_templates_h
WHERE	payroll_action_id = pactid;

l_return_status		CHAR(1);
l_original_request_id	NUMBER(15);
l_program_name		VARCHAR2(30);
begin

   ---fnd_file.put_line(fnd_file.log,'RUNNING THE DEINIT');
   open get_request_id;
   fetch get_request_id into l_request_id;
   close get_request_id;

	OPEN conc_program_name_cur;
	FETCH conc_program_name_cur INTO l_program_name;
	CLOSE conc_program_name_cur;

	IF (l_program_name <> 'PSPRTEF') THEN
		start_initiator_wf(l_request_id);

		psp_xmlgen.update_er_error_details	(p_request_id		=>	l_request_id,
							p_retry_request_id	=>	NULL,
							p_return_status		=>	l_return_status);
	ELSE
		OPEN original_request_id_cur;
		FETCH original_request_id_cur INTO l_original_request_id;
		CLOSE original_request_id_cur;

		psp_xmlgen.update_er_error_details	(p_request_id		=>	l_original_request_id,
							p_retry_request_id	=>	l_request_id,
							p_return_status		=>	l_return_status);
	END IF;

--	Moved teh deletion of temporary table to submit and Purge code paths.
   /* Following statement added to purge psp_selected_persons_t in dinit code, when run is successful * /
    DELETE from psp_selected_persons_t WHERE request_id=l_request_id and not exists
     (select 1 from pay_payroll_actions where payroll_action_id =pactid and action_status
      ='E')  ;
--	End of comment	*****/

    EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;



end;

procedure record_initiator_apprvl(itemtype in  varchar2,
                                  itemkey  in  varchar2,
                                  actid    in  number,
                                  funcmode in  varchar2,
                                  result   out nocopy varchar2) is
  l_request_id integer;
  cursor check_pre_approved_cur is
   select 1
     from psp_report_templates_h
   where request_id = l_request_id
     and approval_type = 'PRE';
  l_flag integer;
begin
 l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');
 update psp_report_templates_h
 set initiator_accept_flag = 'Y'
 where request_id = l_request_id;

 open check_pre_approved_cur;
 fetch check_pre_approved_cur into l_flag;
 if check_pre_approved_cur%found then
    update psp_eff_reports
       set status_code = 'A',
           last_update_date = sysdate,
            last_update_login = fnd_global.login_id,
            last_updated_by = fnd_global.user_id
    where request_id = l_request_id;
 end if;
 close  check_pre_approved_cur;

--	Following statement added to purge psp_selected_persons_t in dinit code, when run is successful
	DELETE FROM psp_selected_persons_t
	WHERE	request_id=l_request_id;
exception
 when others then
    -- populate stack with error message
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'RECORD_INITIATOR_APPRVL', itemtype, itemkey, to_char(actid), funcmode);
     raise;

end;

procedure record_initiator_rjct(itemtype in  varchar2,
                                itemkey  in  varchar2,
                                actid    in  number,
                                funcmode in  varchar2,
                                result   out nocopy varchar2) is
  l_request_id integer;
begin
  l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');
 update psp_report_templates_h
 set initiator_accept_flag = 'N'
 where request_id = l_request_id;
exception
 when others then
    -- populate stack with error message
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'RECORD_INITIATOR', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

procedure init_approvals(itemtype in  varchar2,
                         itemkey  in  varchar2,
                         actid    in  number,
                         funcmode in  varchar2,
                         result   out nocopy varchar2) is

-- Cursor added for bug 4106614: Effort Manual Override
  cursor effort_manual_override_cur(p_request_id integer) is
    select MANUAL_ENTRY_OVERRIDE_FLAG
    from psp_report_templates_h where  request_id = p_request_id;

  cursor wf_item_key_cur(p_request_id integer) is
  select wf_role_name,
         psp_wf_item_key_s.nextval
    from (select era.wf_role_name
            from psp_eff_report_approvals era,
                 psp_eff_reports er,
                 psp_eff_report_details erd
           where erd.effort_report_id = er.effort_report_id
             and erd.effort_report_detail_id = era.effort_report_detail_id
             and era.approval_status = 'P'
             and era.approver_order_num = 1
             and er.request_id = p_request_id
             and er.status_code = 'N'
           group by wf_role_name);


  type t_integer  is table of number(15)    index by binary_integer;
  type t_varchar2 is table of varchar2(320) index by binary_integer;
  wf_rname_array t_varchar2;
  wf_ikey_array  t_integer;
  k integer;
  l_initiator_rname wf_roles.name%type;
  l_request_id integer;
  l_start_date varchar2(50);
  l_end_date varchar2(50);
  l_template_name varchar2(200);
  l_time_out integer;
  l_param_string varchar2(1000);
  effort_manual_override_flag varchar2(10);  --added for bug 4106614: Effort Manual Override

begin
    ---hr_utility.trace_on('Y','WF-1');
    hr_utility.trace('er_workflow --> 100');
   if funcmode = 'RUN' then
    l_initiator_rname :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INITIATOR');

    l_request_id :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'REQUEST_ID');

    l_start_date :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'START_DATE');
    l_end_date :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'END_DATE');

    l_template_name :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'TEMPLATE_NAME');

    l_time_out :=
             wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TIMEOUT');

    l_param_string :=
             wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CONC_PARAM_STRING');


    --- approval records will be created in the thread
    --- get distinct role names from approvals table.
    open  wf_item_key_cur(l_request_id);
    fetch wf_item_key_cur bulk collect into wf_rname_array, wf_ikey_array;
    close wf_item_key_cur;

    if wf_rname_array.count = 0 then
    hr_utility.trace('er_workflow --> count =0 req_id='||to_char(l_request_id));
      --dbms_output.put_line('INIT APPROVALS:no recs for approval.. raise error');
      ---- raise error here, with appropriate error;
	RAISE fnd_api.g_exc_unexpected_error;
    end if;

     forall k in 1..wf_rname_array.count
       update psp_eff_report_approvals
          set wf_item_key = wf_ikey_array(k)
        where wf_role_name = wf_rname_array(k)
          and effort_report_detail_id in
                 (select erd.effort_report_detail_id
                    from psp_eff_reports er,
                         psp_eff_report_details erd
                   where erd.effort_report_id = er.effort_report_id
                     and er.request_id = l_request_id
                     and er.status_code = 'N');
    k := 1;
    hr_utility.trace('er_workflow --> LOOP START ');
    loop
    hr_utility.trace('er_workflow --> INSIDE LOOP ');
      if k > wf_rname_array.count then
         exit;
      end if;
      -- call workflow
      --dbms_output.put_line('FROM INIT - item key ='||wf_ikey_array(k));

      wf_engine.CreateProcess(itemtype => 'PSPERAVL',
                              itemkey  => wf_ikey_array(k),
                              process  => 'APPROVER_WORKFLOW');

      /*Added for bug 7004679 */
      wf_engine.setitemowner(itemtype => 'PSPERAVL',
                             itemkey  => wf_ikey_array(k),
                             owner    => wf_rname_array(k));


      wf_engine.SetItemParent(itemType       => 'PSPERAVL',
                              itemKey        => wf_ikey_array(k),
                              parent_ItemType => itemType,
                              parent_ItemKey  => itemKey,
                              parent_context  => null);

      wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'REQUEST_ID',
                                 avalue   => l_request_id);

      wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'APPROVER_ORDER_NUM',
                                 avalue   => 1);

      wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'TIMEOUT',
                                 avalue   => l_time_out);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'INITIATOR',
                                 avalue   => l_initiator_rname);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'ITEM_KEY',
                                 avalue   => wf_ikey_array(k));

	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => wf_ikey_array(k),
				aname    => 'RECEIVER_FLAG',
				avalue   => 'AR');

-- Fix for bug 4106614 : Effort Manual Override START
	 open effort_manual_override_cur(l_request_id);
		fetch effort_manual_override_cur into effort_manual_override_flag;
	    close effort_manual_override_cur;

	    if effort_manual_override_flag = 'N' then
		wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
					itemKey  => wf_ikey_array(k),
					aname    => 'EFFORT_MANUAL_OVERRIDE',
					avalue   => null);
	/*    else   -- else part is defaulted in psperavl.wft
		wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
					itemKey  => wf_ikey_array(k),
					aname    => 'EFFORT_MANUAL_OVERRIDE',
					avalue   => 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/psp/effortreporting/workflow/webui/EffManualOverridePG&akRegionApplicationId=8403&requestId=-&MSG_REQUEST_ID-&wfItemKey=-&MSG_IKEY-&wfRoleName=-&APPROVER_ROLE-&approverOrderNum=-&APPROVER_ORDER-');
	*/
	    end if;
-- Fix for bug 4106614 : Effort Manual Override END

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => '#ATTACHMENTS',
                                 avalue   => 'FND:entity=ERDETAILS&pk1name=WF_ITEM_KEY&pk1value=' || wf_ikey_array(k));

--Bug 7135471
      wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => wf_ikey_array(k),
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || 'PSPERAVL' || ':' || wf_ikey_array(k));

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'START_DATE',
                                 avalue   => l_start_date);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                 aname    => 'END_DATE',
                                 avalue   => l_end_date);

        wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
                                aname    => 'TEMPLATE_NAME',
                                avalue   => l_template_name);


    	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
                                 itemkey  => wf_ikey_array(k),
				aname    => 'CONC_PARAM_STRING',
				avalue   => l_param_string);
      k := k + 1;
    end loop;
    k := 1;
    loop
      if k > wf_rname_array.count then
         exit;
      end if;

      wf_engine.StartProcess(itemtype => 'PSPERAVL',
                            itemkey  => wf_ikey_array(k));
      k := k + 1;
    end loop;
    wf_ikey_array.delete;

    hr_utility.trace('er_workflow --> 1000 ');
    result := 'COMPLETE';
  end if; --- funcmode = RUN

result := 'COMPLETE';
exception
 when others then
    hr_utility.trace('er_workflow --> err '||sqlerrm);
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'INIT_APPROVALS', itemtype, itemkey, to_char(actid), funcmode);
    raise;
end;

procedure purge_er(itemtype in  varchar2,
                   itemkey  in  varchar2,
                   actid    in  number,
                   funcmode in  varchar2,
                   result   out nocopy varchar2)
is
   l_request_id     integer;
begin

   if (funcmode = 'RUN') then
      l_request_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'REQUEST_ID');
     delete psp_eff_report_approvals
      where effort_report_detail_id in
           (select effort_report_detail_id
              from psp_eff_report_details
             where effort_report_id in
                 (select effort_report_id
                    from psp_eff_reports
                  where request_id = l_request_id));

     delete psp_eff_report_details
      where effort_report_id in
          (select effort_report_id
             from psp_eff_reports
            where request_id = l_request_id);

     delete psp_eff_reports
     where request_id = l_request_id;

     delete psp_report_errors
      where request_id = l_request_id;

	DELETE	fnd_lobs fl
	WHERE	fl.file_id IN	(SELECT	fdl.media_id
				FROM	fnd_attached_documents fad,
					fnd_documents_vl  fdl
				WHERE	fad.pk1_value = itemkey
				AND	fdl.document_id = fad.document_id
				AND	fad.entity_name = 'ERDETAILS');

	DELETE	fnd_lobs fl
	WHERE	fl.file_id IN	(SELECT	fdl.media_id
				FROM	fnd_attached_documents fad,
					fnd_documents_vl  fdl
				WHERE	fad.pk1_value IN (SELECT	wf_item_key
							FROM	psp_eff_report_approvals pera
							WHERE	pera.effort_report_detail_id IN (SELECT	perd.effort_report_detail_id
									FROM	psp_eff_report_details perd
									WHERE	perd.effort_report_id	IN	(SELECT	per.effort_report_id
											FROM	psp_eff_reports per
											WHERE	per.request_id = l_request_id)))
				AND	fdl.document_id = fad.document_id
				AND	fad.entity_name = 'ERDETAILS');

--	Following statement added to purge psp_selected_persons_t in dinit code, when run is successful
	DELETE FROM psp_selected_persons_t
	WHERE	request_id=l_request_id;

     result := 'COMPLETE';
   end if;

exception
   when others then
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'PURGE_ER', itemtype, itemkey, to_char(actid), funcmode);
    raise;
end;

/* GET_NEXT_APPROVER:
 PURPOSE:  Get the next approver from AME

 HISTORY:
 Aug-1, 2004
 Following scenarios arise:-
  A notification can contain many ER details records, and relate to
  many AME transaction IDs. Approvers are found for each txn id.

 1) AB, A     : then B will continue with same item key- Approver FOUND
 2) AB, AC    : create 2 new item keys, one for B and other C- FORK
 3) A,  A     : approver NOT FOUND.
 4) AB, AC, A : Then FORK

 In short following is the precedence
 FORK (supercedes)--> FOUND (supercedes)--> NOT_FOUND

** Sep-2, 2004
 Removed the notification Forking. As a business rule, user will always
 identify the lowest notification unit. For example, if there is
     A, S  --- ERD1
     A, X  --- ERD2
 then user will rearrange it in AME to get following approval sequence
     S, A  -- ERD1
     X, A  -- ERD2
 Also if user has
    A, S
    A
Then same notification can be sent to S also. Assume S, X are special
approvals.

However if the user does not re-arrange the approvers into SA, XA then
but instead has set up as AS, AX then S and X will be sent their respective
notifications, however WF thread will wait till both finish before going
to next level if there is one.

JUSTIFICATION for the business rule that AS, AX should be modified into SA, XA
is that S, A, X are horizontal approvers, there is no
pyramid type of approvals, or no clear cut hierarchy

 1) AB, AC    : should not arise due to new business rule restrictions,
                 if it does arise then , B and C will recieve separate
                 notifications in sequcen */

procedure get_next_approver(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is

  l_approver_order_num integer;
  l_role_name varchar2(320);
  l_role_display_name varchar2(360);
  l_user_id fnd_user.user_id%type;
  l_login_id number;

  cursor role_name_cur is
  select wf_role_name
    from psp_eff_report_approvals
   where wf_item_key = itemkey
     and rownum = 1
     and approver_order_num = 1;

  cursor ame_txn_id_cur is
  select distinct erd.ame_transaction_id
    from psp_eff_report_details erd
   where erd.effort_report_detail_id in
        (select era.effort_report_detail_id
           from psp_eff_report_approvals era
          where wf_item_key = itemkey
            and approval_status = 'A');

  --- same level unapproved ER details
  cursor same_approval_level_cur(p_approver_order_num in integer) is
  select wf_role_name,
         wf_role_display_name
    from psp_eff_report_approvals
   where wf_item_key = itemkey
     and approver_order_num = p_approver_order_num
     and approval_status = 'P'
     and rownum = 1;

  type t_integer   is table of number(15)     index by binary_integer;
  type t1_varchar2 is table of varchar2(320) index by binary_integer;
  type t2_varchar2 is table of varchar2(50)  index by binary_integer;

  wf_rname_array      t1_varchar2;
  app_order_num_array t_integer;
  ame_txn_id_array    t2_varchar2;
  i integer;
  l_next_approver ame_util.approversTable2;
  l_wf_rname varchar2(320);
  l_fork_flag varchar2(1);
  l_request_id integer;
  l_process_complete varchar2(10);
  l_temp_not_found   varchar2(40);   --- to indicate atleast
                                  -- some ER details did not have approver.
  l_jsp_string varchar2(4000);
  l_same_approval_level varchar2(1);

  l_return_status	CHAR(1);

  l_approval_type       varchar2(10);

  cursor get_approval_type is
   select approval_type
     from psp_Report_templates_h
    where request_id = l_request_id;

begin
  hr_utility.trace(' Entering GET_NEXT_APPROVER');
  l_same_approval_level := 'N';
  ---hr_utility.trace_on('Y','WF-1');

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;
  if funcmode = 'RUN' then
    l_approver_order_num :=
            wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'APPROVER_ORDER_NUM');
    l_request_id :=
           wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'REQUEST_ID');
    open get_approval_type;
    fetch get_approval_type into l_approval_type;
    close get_approval_type;

    --- all ame transactions have been grouped based on the first
    --- approver. Since approver is already avaialable, no need to call AME
    if l_approver_order_num = 1 then
       open role_name_cur;
       fetch role_name_cur into l_wf_rname;
       close role_name_cur;
       l_role_display_name := wf_directory.GetRoleDisplayName(l_wf_rname);
       result := 'COMPLETE:FOUND';
    elsif l_approval_type in ('PMG', 'TMG', 'GPI') then
           update psp_eff_reports er
              set er.status_code = 'A',
                  er.last_update_date = sysdate,
                  er.last_update_login = fnd_global.login_id,
                  er.last_updated_by = fnd_global.user_id
            where er.status_code = 'N'
              and er.effort_report_id in
                  (select erd.effort_report_id
                     from psp_eff_report_details erd,
                          psp_eff_report_approvals era
                    where era.effort_report_detail_id = erd.effort_report_detail_id
                      and era.wf_item_key = itemkey)
              and not exists
                  (select 1
                   from psp_eff_report_approvals era,
                         psp_eff_report_details erd
                   where era.effort_report_detail_id = erd.effort_report_detail_id
                     and erd.effort_report_id = er.effort_report_id
                     and era.approval_status <> 'A');
                   result := 'COMPLETE:NOTFOUND';

    else
      open same_approval_level_cur(l_approver_order_num);
      fetch same_approval_level_cur into l_wf_rname, l_role_display_name;
      if same_approval_level_cur%notfound then
            l_same_approval_level := 'N';
      else
            l_same_approval_level := 'Y';
            result := 'COMPLETE:FOUND';
      end if;
      close same_approval_level_cur;
      if l_same_approval_level = 'N' then
         open ame_txn_id_cur;
         fetch ame_txn_id_cur bulk collect into ame_txn_id_array;
         close ame_txn_id_cur;
         i := 1;
         loop
            if i > ame_txn_id_array.count then
              exit;
            end if;
            ame_api2.getNextApprovers4(applicationidIn => 8403,
                                       transactiontypeIn => 'PSP-ER-APPROVAL',
                                       transactionIdIn => ame_txn_id_array(i),
                                       flagApproversAsNotifiedIn => 'Y',
                                       approvalProcessCompleteYNout => l_process_complete,
                                       nextApproversOut=> l_next_approver);
               --- ignoring parallel approvers, assuming only one approver role
            if l_next_approver.count = 0 then
                if result is null then
                   result := 'COMPLETE:NOTFOUND';
                   l_temp_not_found := 'Y';
                end if;
            else
               l_wf_rname := l_next_approver(1).name;
               l_role_display_name := l_next_approver(1).display_name;
               result := 'COMPLETE:FOUND';
               insert into psp_eff_report_approvals
                   (effort_report_approval_id,
                    effort_report_detail_id,
                    wf_role_name,
                    wf_orig_system_id,
                    wf_orig_system,
                    approver_order_num,
                    approval_status,
                    wf_item_key,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     creation_date,
                     created_by,
                     wf_role_display_name,
                     object_version_number)
               select psp_eff_report_approvals_s.nextval,
                      erd.effort_report_detail_id,
                      l_next_approver(1).name,
                      l_next_approver(1).orig_system_id,
                      l_next_approver(1).orig_system,
                      l_approver_order_num,
                      nvl(l_next_approver(1).approval_status,'P'),
                      itemkey,
                      sysdate,
                     l_user_id,
                     l_login_id,
                     sysdate,
                     l_user_id,
                     l_next_approver(1).display_name,
                     1
                 from psp_eff_report_details erd
                where erd.ame_transaction_id = ame_txn_id_array(i)
                  and erd.effort_report_id in
                      (select er.effort_report_id
                         from psp_eff_reports er
                        where er.request_id = l_request_id
                          and er.status_code  = 'N');
              hr_utility.trace(' ER workflow -> order number = '||l_next_approver(1).approver_order_number);
              -- copy the previous approvers overwrites to the new approver
              if l_next_approver(1).approver_order_number > 1 then
              update psp_eff_report_approvals A1
                 set (A1.actual_cost_share, A1.overwritten_effort_percent, comments,
			/* Add DF Columns for Hospital Effort report */
			pera_information1, pera_information2, pera_information3, pera_information4, pera_information5,
			pera_information6, pera_information7, pera_information8, pera_information9, pera_information10,
			pera_information11, pera_information12, pera_information13, pera_information14, pera_information15,
			eff_information1, eff_information2, eff_information3,eff_information4, eff_information5,
			eff_information6,eff_information7, eff_information8 , eff_information9,eff_information10,
			eff_information11, eff_information12, eff_information13, eff_information14, eff_information15) =
                      (select A2.actual_cost_share, A2.overwritten_effort_percent, comments,
			/* Add DF Columns for Hospital Effort report */
			pera_information1, pera_information2, pera_information3, pera_information4, pera_information5,
			pera_information6, pera_information7, pera_information8, pera_information9, pera_information10,
			pera_information11, pera_information12, pera_information13, pera_information14, pera_information15,
			eff_information1, eff_information2, eff_information3,eff_information4, eff_information5,
			eff_information6,eff_information7, eff_information8 , eff_information9,eff_information10,
			eff_information11, eff_information12, eff_information13, eff_information14, eff_information15
                         from psp_eff_report_approvals A2
                        where A1.effort_report_detail_id = A2.effort_report_detail_id
/* Bug 5235725: Replacing l_next_approver(1).approver_order_number with l_approver_order_num.
In case of reassign a notification function ame_api2.getNextApprovers4 resturns nextApproversOut.approver_order_number with an
incremented value while in our system (Effort rporting) we do not increment the approver_order_number in case of reassign */
--                          and A2.approver_order_num = l_next_approver(1).approver_order_number -1)
                          and A2.approver_order_num = l_approver_order_num -1)
--                where A1.approver_order_num = l_next_approver(1).approver_order_number and
                where A1.approver_order_num = l_approver_order_num and
                     A1.effort_report_detail_id in
                      (select erd.effort_report_detail_id
                         from psp_eff_reports er,
                              psp_eff_report_details erd
                        where er.request_id = l_request_id
                          and er.effort_report_id = erd.effort_report_id
                          and erd.ame_transaction_id = ame_txn_id_array(i)
                          and er.status_code  = 'N');
              hr_utility.trace(' ER workflow -> update count= '||sql%rowcount);
               end if;


            end if;
            i := i +1;
         end loop;
         if l_temp_not_found = 'Y' then
           update psp_eff_reports er
              set er.status_code = 'A',
                  er.last_update_date = sysdate,
                  er.last_update_login = fnd_global.login_id,
                  er.last_updated_by = fnd_global.user_id
            where er.status_code = 'N'
              and er.effort_report_id in
                  (select erd.effort_report_id
                     from psp_eff_report_details erd,
                          psp_eff_report_approvals era
                    where era.effort_report_detail_id = erd.effort_report_detail_id
                      and era.wf_item_key = itemkey)
              and not exists
                  (select 1
                   from psp_eff_report_approvals era,
                         psp_eff_report_details erd
                   where era.effort_report_detail_id = erd.effort_report_detail_id
                     and erd.effort_report_id = er.effort_report_id
                     and era.approval_status <> 'A');
         end if;
     end if;  --- same approval level flag = N
    end if;   --- approver order number > 1
    if result = 'COMPLETE:FOUND' then
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_ROLE_NAME',
                                    avalue   => l_wf_rname);
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue   => l_role_display_name);
          wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => '#ATTACHMENTS',
                              avalue   => 'FND:entity=ERDETAILS&pk1name=WF_ITEM_KEY&pk1value=' || itemkey || l_wf_rname );

	--Bug 7135471
          wf_engine.SetItemAttrText(itemType => itemtype,
				itemKey  => itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || itemtype || ':' || itemkey);


      	  /*Added for bug 7004679 */
          wf_engine.setitemowner(itemtype => itemtype,
                                 itemkey  => itemkey,
                                 owner    => l_wf_rname);



          /*
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'EMBED_WF_ER_DETAILS',
                                    avalue   => 'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_WF_ER_DETAILS&wfItemKey='||itemkey
                                                ||'&requestId='||l_request_id
                                                ||'&wfRoleName='||l_wf_rname
                                                ||'&approverOrderNum='||l_approver_order_num); */

            hr_utility.trace('GET_NEXT value for temp_approver_order ='|| l_approver_order_num);
                    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'TEMP_APPROVER_ORDER',
                                                avalue   => l_approver_order_num);

    hr_utility.trace('er_workflow --> GET NEXT APPROVER jsp string='||
                           'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_WF_ER_DETAILS&wfItemKey='||itemkey
                                                ||'&requestId='||l_request_id
                                                ||'&wfRoleName='||l_wf_rname
                                                ||'&approverOrderNum='||l_approver_order_num);

          if l_same_approval_level = 'N' then
            l_approver_order_num :=  l_approver_order_num + 1;
            wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'APPROVER_ORDER_NUM',
                                        avalue   => l_approver_order_num);
          end if;
    end if;

-- Code Moved from process Approvals
	psp_xmlgen.update_er_person_xml	(p_wf_item_key	=>	itemkey,
					p_return_status	=>	l_return_status);

	IF (l_return_status = 'E') THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

  end if;   --- funcmode = RUN
exception
   when others then
     result := 'ERROR';
     --result := substr(sqlerrm,15);
     wf_core.context('PSP_EFFORT_REPORTS', 'GET_NEXT_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

procedure process_rejections(itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2) is
  l_rname  wf_roles.name%type;
  l_request_id integer;
  l_effort_report_id integer;
  l_initiator_rname wf_roles.name%type;
  l_orig_system_id wf_roles.orig_system_id%type;
  l_orig_system    wf_roles.orig_system%type;
  l_txn_id         varchar2(50);
  approver_rec     ame_util.approverRecord2;
  l_recipnt_role varchar2(300);

  cursor effort_report_id_cur is
  select effort_report_id
    from psp_eff_reports
   where effort_report_id in
       (select effort_report_id
          from psp_eff_report_details
         where effort_report_detail_id in
             (select effort_report_detail_id
                from psp_eff_report_approvals
               where wf_item_key = itemkey
                 and wf_role_name = l_rname));

  --- one person can have more than one approver.
  --- partial approval by 2 approvers.
  cursor past_approvers_cur is
  select distinct era.wf_role_name
    from psp_eff_reports er,
         psp_eff_report_details erd,
         psp_eff_report_approvals era,
         fnd_user fu                                 -- Bug 6641216
   where era.effort_report_detail_id = erd.effort_report_detail_id
     and erd.effort_report_id = er.effort_report_id
     and era.approval_status in ( 'A','P')
     and er.request_id = l_request_id
     and er.effort_report_id in
       (select effort_report_id
          from psp_eff_reports
         where effort_report_id in
            (select effort_report_id
               from psp_eff_report_details
              where effort_report_detail_id in
                  (select effort_report_detail_id
                     from psp_eff_report_approvals
                    where wf_item_key = itemkey
                      and wf_role_name = l_rname)))
     and era.wf_role_name = fu.user_name   -- Bug 6641216
     and trunc(sysdate) between trunc(fu.start_date) and nvl(trunc(fu.end_date),trunc(sysdate)) -- Bug 6641216
   union
   select name
     from wf_roles
    where orig_system = 'PER'
      and orig_system_id in
         (select initiator_person_id
            from psp_report_templates_h
           where request_id = l_request_id);

  cursor get_txn_id_cur is
  select distinct ame_transaction_id
    from psp_eff_report_details erd,
         psp_eff_report_approvals era
   where erd.effort_report_detail_id = era.effort_report_detail_id
     and era.wf_item_key = itemkey
     and era.approval_status = 'P'
     and era.wf_role_name = l_rname
     and era.wf_orig_system_id = l_orig_system_id
     and era.wf_orig_system = l_orig_system;

  --- same level unapproved ER details
  cursor same_approval_level_cur(p_approver_order_num in integer) is
  select wf_role_name
    from psp_eff_report_approvals
   where wf_item_key = itemkey
     and approver_order_num = p_approver_order_num
     and approval_status = 'P'
     and rownum = 1;

  l_approver_order_num integer;

begin
  l_recipnt_role := 'PSP_PAST_APPROVERS_'||itemkey;
  ---hr_utility.trace_on('Y','WF-1');
  if funcmode = 'RUN' then
    hr_utility.trace('er_workflow -->1 ');
    l_request_id :=
           wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'REQUEST_ID');
    l_rname :=
           wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');

   l_approver_order_num :=
          wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'APPROVER_ORDER_NUM');
   select orig_system_id,
          orig_system
     into l_orig_system_id,
          l_orig_system
     from wf_roles
   where name = l_rname;

    approver_rec.name := l_rname;
    approver_rec.orig_system := l_orig_system;
    approver_rec.orig_system_id := l_orig_system_id;
    approver_rec.approval_status:= 'REJECTED';

    hr_utility.trace('er_workflow -->2 ');
    open get_txn_id_cur;
    loop
    hr_utility.trace('er_workflow -->3 ');
      fetch get_txn_id_cur into l_txn_id;
      if get_txn_id_cur%notfound then
        close get_txn_id_cur;
        exit;
      end if;
    hr_utility.trace('er_workflow -->5 ');

      ame_api2.updateapprovalstatus(applicationidin => 8403,
                                    transactiontypein => 'PSP-ER-APPROVAL',
                                    transactionidin => l_txn_id,
                                    approverin => approver_rec);
    hr_utility.trace('er_workflow -->6 ');
    end loop;

    hr_utility.trace('er_workflow -->7 ');
      update psp_eff_report_approvals era
        set era.approval_status = 'S',
            era.response_date = sysdate,
            era.last_update_date = sysdate,
            era.last_update_login = fnd_global.login_id,
            era.last_updated_by = fnd_global.user_id
      where era.wf_item_key = itemkey
       and era.wf_role_name = l_rname
       and exists
              ( select  erd.effort_report_detail_id
                from    psp_eff_report_details erd,
                        psp_eff_reports er
                where er.effort_report_id = erd.effort_report_id
                and   erd.effort_report_detail_id = era.effort_report_detail_id
         and er.status_code = 'S' );


    update psp_eff_report_approvals era
       set era.approval_status = 'R',
            era.response_date = sysdate,
           era.last_update_date = sysdate,
           era.last_update_login = fnd_global.login_id,
           era.last_updated_by = fnd_global.user_id
     where era.wf_item_key = itemkey
       and era.wf_role_name = l_rname
       and not exists
              ( select  erd.effort_report_detail_id
                from    psp_eff_report_details erd,
                        psp_eff_reports er
                where er.effort_report_id = erd.effort_report_id
                and   erd.effort_report_detail_id = era.effort_report_detail_id
         and er.status_code = 'S' );

    hr_utility.trace('er_workflow -->8 ');
    open effort_report_id_cur;
    loop
       fetch effort_report_id_cur into l_effort_report_id;
       hr_utility.trace('er_workflow -->9 ');
       if effort_report_id_cur%notfound then
         close effort_report_id_cur;
         exit;
       end if;
       update psp_eff_reports
          set status_code = 'R',
              last_update_date = sysdate,
              last_update_login = fnd_global.login_id,
              last_updated_by = fnd_global.user_id
        where effort_report_id = l_effort_report_id;
       hr_utility.trace('er_workflow -->19 ');
    end loop;

     l_initiator_rname :=
           wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'INITIATOR');

    wf_directory.createAdhocRole(l_recipnt_role,
                                 l_recipnt_role);
    hr_utility.trace('er_workflow -->29 ');
    open past_approvers_cur;
    loop
    hr_utility.trace('er_workflow -->39 ');
    fetch past_approvers_cur into l_rname;
       if past_approvers_cur%notfound then
         close past_approvers_cur;
         exit;
       end if;
       hr_utility.trace('er_workflow -->49 ');
       wf_directory.AddUsersToAdHocRole
               (role_name  => l_recipnt_role,
                role_users => l_rname);
    end loop;

    hr_utility.trace('er_workflow -->59 ');
    wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                               itemkey => itemkey,
                                 aname => 'NOTIFY_REJECTIONS_ROLE',
                                avalue => l_recipnt_role);
          hr_utility.trace('er_workflow -->69 ');

    result := 'COMPLETE:REJECTED';
    open same_approval_level_cur(l_approver_order_num);
    fetch same_approval_level_cur into l_rname;
    --- this user has rejected.. but there is one or more different
    --- users,from which response is required.
    if same_approval_level_cur%found then
       result := 'COMPLETE:MORE_RESP_REQD';
    end if;
    close same_approval_level_cur;
    hr_utility.trace('er_workflow -->79 ');
  end if;   --- funcmode
    hr_utility.trace('er_workflow -->89 ');
exception
   when others then
    hr_utility.trace('er_workflow -->when others then exception occured Error = '||sqlerrm);
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'PROCESS_REJECTIONS', itemtype, itemkey, to_char(actid), funcmode);
     --- debug;
     raise;
end;

procedure process_approvals(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is

  l_rname          wf_roles.name%type;
  l_orig_system_id wf_roles.orig_system_id%type;
  l_orig_system    wf_roles.orig_system%type;
  l_txn_id         varchar2(50);
  approver_rec     ame_util.approverRecord2;
  l_return_status	CHAR(1);

  cursor get_orig_system is
  select wf_orig_system_id,
         wf_orig_system
    from psp_eff_report_approvals
   where wf_item_key = itemkey
    and approval_status = 'P'
    and wf_role_name = l_rname;

  cursor get_txn_id_cur is
  select distinct ame_transaction_id
    from psp_eff_report_details erd,
         psp_eff_report_approvals era
   where erd.effort_report_detail_id = era.effort_report_detail_id
     and era.wf_item_key = itemkey
     and era.approval_status = 'A'
     and era.wf_role_name = l_rname
     and era.wf_orig_system_id = l_orig_system_id
     and era.wf_orig_system = l_orig_system;

begin
  hr_utility.trace(' the valus of Run Id is : '|| funcmode);
  if funcmode = 'RUN' then
    l_rname :=
           wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');

    open get_orig_system;
    fetch get_orig_system into  l_orig_system_id, l_orig_system;
    close get_orig_system;


--  Intorduced for Supercedence to set status_code = 'S'
--  when the psp_eff_reports gets superceded

   update psp_eff_report_approvals era
   set era.approval_status = 'S',
       era.response_date	= SYSDATE,
       era.last_update_date = sysdate,
       era.last_update_login = fnd_global.login_id,
       era.last_updated_by = fnd_global.user_id
   where era.wf_item_key = itemkey
   and era.wf_role_name = l_rname
   and era.wf_orig_system_id = l_orig_system_id
   and era.wf_orig_system = l_orig_system
   and era.approval_status = 'P'
   and exists
       ( select  erd.effort_report_detail_id
         from    psp_eff_report_details erd,
                 psp_eff_reports er
         where er.effort_report_id = erd.effort_report_id
         and   erd.effort_report_detail_id = era.effort_report_detail_id
         and er.status_code = 'S' );


    update psp_eff_report_approvals era
   set era.approval_status = 'A',
       era.response_date	= SYSDATE,
       era.last_update_date = sysdate,
       era.last_update_login = fnd_global.login_id,
       era.last_updated_by = fnd_global.user_id
   where era.wf_item_key = itemkey
   and era.wf_role_name = l_rname
   and era.wf_orig_system_id = l_orig_system_id
   and era.wf_orig_system = l_orig_system
   and era.approval_status = 'P'
   and not  exists
       ( select  erd.effort_report_detail_id
         from    psp_eff_report_details erd,
                 psp_eff_reports er
         where er.effort_report_id = erd.effort_report_id
         and   erd.effort_report_detail_id = era.effort_report_detail_id
         and er.status_code = 'S' );




    approver_rec.name := l_rname;
    approver_rec.orig_system := l_orig_system;
    approver_rec.orig_system_id := l_orig_system_id;
    approver_rec.approval_status:= ame_util.approvedStatus;

    open get_txn_id_cur;
    loop
      fetch get_txn_id_cur into l_txn_id;
      if get_txn_id_cur%notfound then
        close get_txn_id_cur;
        exit;
      end if;
      ame_api2.updateapprovalstatus(applicationidin => 8403,
                                    transactiontypein => 'PSP-ER-APPROVAL',
                                    transactionidin => l_txn_id,
                                    approverin => approver_rec);
    end loop;
    result := 'COMPLETE';
-- MOving this code to Procedure get_next Approver

	psp_xmlgen.update_er_person_xml	(p_wf_item_key	=>	itemkey,
					p_return_status	=>	l_return_status);

	IF (l_return_status = 'E') THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;

  end if;   ---funcmode
exception
   when others then
     result := 'ERROR';
     --result := result||'=='||sqlerrm;
     wf_core.context('PSP_EFFORT_REPORTS', 'PROCESS_APPROVALS', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;
procedure approver_post_notify(itemtype in  varchar2,
                               itemkey  in  varchar2,
                               actid    in  number,
                               funcmode in  varchar2,
                               result   out nocopy varchar2) is

  l_rname          wf_roles.name%type;
  l_orig_system_id wf_roles.orig_system_id%type;
  l_orig_system    wf_roles.orig_system%type;
  l_rname2          wf_roles.name%type;
  l_orig_system_id2 wf_roles.orig_system_id%type;
  l_orig_system2    wf_roles.orig_system%type;
  l_txn_id         varchar2(50);
  approver_rec     ame_util.approverRecord2;
  forward_rec      ame_util.approverRecord2;
  l_return_status	CHAR(1);

  cursor get_orig_system is
  select wf_orig_system_id,
         wf_orig_system
    from psp_eff_report_approvals
   where wf_item_key = itemkey
    and approval_status = 'P'
    and wf_role_name = l_rname;

  cursor get_txn_id_cur is
  select distinct ame_transaction_id
    from psp_eff_report_details erd,
         psp_eff_report_approvals era
   where erd.effort_report_detail_id = era.effort_report_detail_id
     and era.wf_item_key = itemkey
     and era.approval_status = 'P'
     and era.wf_role_name = l_rname2
     and era.wf_orig_system_id = l_orig_system_id2
     and era.wf_orig_system = l_orig_system2;

  cursor get_forwarde_details is
  select orig_system,
         orig_system_id,
         display_name
    from wf_roles
   where name = l_rname2;
  l_role_display_name2 wf_roles.display_name%type;
  l_nid number;

/* Added for hundred percent validation for overridden effort */
  l_result varchar2(240);
  l_request_id Number;
  l_wf_role_name VARCHAR2(320);
  l_wf_item_key VARCHAR2(240);
  l_approver_order_num Number;
  l_hundred_pcrent_eff_flag Varchar2(1);
  l_start_date Date;
  l_end_date Date;
  l_person_id Number;
  l_assignment_id Number;
  l_full_name varchar2(240);
  l_assignemnt_number varchar2(30);
  l_last_approver varchar2(1);
  l_temp Number;
  l_percent Number;
  l_error_message varchar2(4000);

  CURSOR get_person_Assignment_list_csr IS
  SELECT distinct prth.hundred_pcent_eff_at_per_asg, per.start_date,
  per.end_date, per.person_id, perd.assignment_id, per.full_name, perd.assignment_number
  FROM   psp_report_templates_h prth,
        psp_eff_reports per,
        psp_eff_report_details perd,
        psp_eff_report_approvals prea
  WHERE  prth.request_id = per.request_id
  AND    per.effort_report_id = perd.effort_report_id
  AND    perd.effort_report_detail_id = prea.effort_report_detail_id
  AND    per.request_id = l_request_id
  AND    prea.wf_role_name = l_wf_role_name
  AND    prea.wf_item_key = l_wf_item_key
  AND    prea.approver_order_num = l_approver_order_num;

  CURSOR is_person_last_approver_csr  IS
  SELECT 1
  FROM   psp_eff_reports per,
         psp_eff_report_details perd,
         psp_eff_report_approvals prea
  WHERE  per.effort_report_id = perd.effort_report_id
  AND    perd.effort_report_detail_id = prea.effort_report_detail_id
  AND    per.person_id = l_person_id
  AND    per.start_date = l_start_date
  AND    per.end_date = l_end_date
  AND    prea.wf_role_name <> l_wf_role_name
  AND    approver_order_num = l_approver_order_num
  AND    prea.approval_status ='P'
  AND    per.status_code IN ('N','A');

  CURSOR is_asg_last_approver_csr IS
  SELECT 1
  FROM   psp_eff_reports per,
         psp_eff_report_details perd,
         psp_eff_report_approvals prea
  WHERE  per.effort_report_id = perd.effort_report_id
  AND    perd.effort_report_detail_id = prea.effort_report_detail_id
  AND    perd.assignment_id = l_assignment_id
  AND    per.start_date = l_start_date
  AND    per.end_date = l_end_date
  AND    prea.wf_role_name <> l_wf_role_name
  AND    approver_order_num = l_approver_order_num
  AND    prea.approval_status = 'P'
  AND    per.status_code IN ('N','A');


  CURSOR person_percent_csr  IS
  SELECT sum(nvl(overwritten_effort_percent,payroll_percent))
  FROM   psp_eff_reports per,
         psp_eff_report_details perd,
         psp_eff_report_approvals prea
  WHERE  per.effort_report_id = perd.effort_report_id
  AND    perd.effort_report_detail_id = prea.effort_report_detail_id
  AND    per.person_id = l_person_id
  AND    per.start_date = l_start_date
  AND    per.end_date = l_end_date
  AND    approver_order_num = l_approver_order_num
  AND    prea.approval_status IN ('P','A')
  AND    per.status_code IN ('N','A');

  CURSOR assignment_percent_csr IS
  SELECT sum(nvl(overwritten_effort_percent,payroll_percent))
  FROM   psp_eff_reports per,
         psp_eff_report_details perd,
         psp_eff_report_approvals prea
  WHERE  per.effort_report_id = perd.effort_report_id
  AND    perd.effort_report_detail_id = prea.effort_report_detail_id
  AND    perd.assignment_id = l_assignment_id
  AND    per.start_date = l_start_date
  AND    per.end_date = l_end_date
  AND    approver_order_num = l_approver_order_num
  AND    prea.approval_status IN ('P','A')
  AND    per.status_code IN ('N','A');

BEGIN

/* Added for Hundred percent validation for overriden effort */
  IF funcmode in ('RESPOND') THEN
    l_result := Wf_Notification.GetAttrText(wf_engine.context_nid, 'RESULT');
    IF l_result = 'APPROVED' THEN
      l_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'REQUEST_ID');
      l_wf_role_name :=  wf_engine.GetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'APPROVER_ROLE_NAME');
      l_approver_order_num := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APPROVER_ORDER_NUM');
      l_approver_order_num := l_approver_order_num - 1;
      l_wf_item_key := itemkey;
      OPEN get_person_Assignment_list_csr;
      LOOP
        FETCH get_person_Assignment_list_csr INTO l_hundred_pcrent_eff_flag, l_start_date,
              l_end_date, l_person_id, l_assignment_id, l_full_name, l_assignemnt_number;
        IF get_person_Assignment_list_csr%NOTFOUND THEN
            CLOSE get_person_Assignment_list_csr;
            EXIT;
        END IF;
        IF l_hundred_pcrent_eff_flag = 'P' THEN
          OPEN is_person_last_approver_csr;
          FETCH is_person_last_approver_csr INTO l_temp ;
	  IF is_person_last_approver_csr%NOTFOUND THEN
		l_last_approver := 'Y';
          ELSE
		l_last_approver := 'N';
	  END IF;
	  CLOSE is_person_last_approver_csr;

	  IF l_last_approver = 'Y' THEN
              OPEN person_percent_csr;
              FETCH person_percent_csr into l_percent;
              CLOSE person_percent_csr;
              IF l_percent <> 100 THEN
                FND_MESSAGE.set_name('PSP','PSP_ER_EMP_PERCENT_NOT_100');
                fnd_message.set_token('EMP_NAME', l_full_name);
                fnd_message.set_token('PERCENT', l_percent);
                l_error_message := fnd_message.get;
                raise_application_error(-20002, l_error_message);
	      END IF;
          END IF;
        ELSIF l_hundred_pcrent_eff_flag = 'A' THEN
          OPEN   is_asg_last_approver_csr;
          FETCH is_asg_last_approver_csr INTO l_temp;
	  IF is_asg_last_approver_csr%NOTFOUND THEN
		l_last_approver := 'Y';
          ELSE
		l_last_approver := 'N';
	  END IF;
	  CLOSE is_asg_last_approver_csr;
          IF l_last_approver = 'Y' THEN
            OPEN assignment_percent_csr;
            FETCH assignment_percent_csr into l_percent;
            CLOSE assignment_percent_csr;
            IF l_percent <> 100 THEN
              FND_MESSAGE.set_name('PSP','PSP_ER_ASG_PERCENT_NOT_100');
              fnd_message.set_token('EMP_NAME', l_full_name);
              fnd_message.set_token('ASG_NUMBER', l_assignemnt_number);
              fnd_message.set_token('PERCENT', l_percent);
              l_error_message := fnd_message.get;
              raise_application_error(-20002, l_error_message);
	   END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END IF;

  if funcmode in ('TRANSFER', 'FORWARD') then
  ---hr_utility.trace_on('Y','WF-1');
    hr_utility.trace('Post Notification...TRANSFER  . FORWARD');
    l_rname := wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');
    hr_utility.trace('role name from T and F = '||l_rname);

    open get_orig_system;
    fetch get_orig_system into  l_orig_system_id, l_orig_system;
    close get_orig_system;

    approver_rec.name := l_rname;
    approver_rec.orig_system := l_orig_system;
    approver_rec.orig_system_id := l_orig_system_id;
    approver_rec.approval_status:= ame_util.forwardStatus;
    l_rname2 := wf_engine.context_text;
    l_nid    := wf_engine.context_nid;
    open get_forwarde_details;
    fetch get_forwarde_details into l_orig_system2, l_orig_system_id2,l_role_display_name2;
    close get_forwarde_details;
    forward_rec.name := l_rname2;
    hr_utility.trace('post notification...Transfer  . Forwardee='||l_rname2||' nid ='||l_nid);
    forward_rec.orig_system := l_orig_system2;
    forward_rec.orig_system_id := l_orig_system_id2;
    forward_rec.approval_status:= ame_util.notifiedStatus;
    update psp_eff_report_approvals
       set wf_role_name = l_rname2,
           wf_role_display_name = l_role_display_name2,
           wf_orig_system = l_orig_system2,
           wf_orig_system_id = l_orig_system_id2
     where wf_item_key = itemkey
       and wf_role_name = l_rname
       and wf_orig_system_id = l_orig_system_id
       and wf_orig_system = l_orig_system
       and approval_status = 'P';

    -- Added for Bug 6996115
    update fnd_attached_documents
    set pk1_value = itemkey||l_rname2
    where pk1_value = itemkey||l_rname;



          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_ROLE_NAME',
                                    avalue   => l_rname2);
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue   => l_role_display_name2);
          wf_notification.setAttrText(nid => l_nid,
                                      aname => 'APPROVER_ROLE',
                                      avalue => l_rname2);
    open get_txn_id_cur;
    loop
      fetch get_txn_id_cur into l_txn_id;
      if get_txn_id_cur%notfound then
        close get_txn_id_cur;
        exit;
      end if;
      hr_utility.trace('Transfer mode CALLING UPDATEAME txn_id ='||l_txn_id);
      ame_api2.updateapprovalstatus(applicationidin => 8403,
                                   transactiontypein => 'PSP-ER-APPROVAL',
                                   transactionidin => l_txn_id,
                                   approverin => approver_rec,
                                   forwardeein => forward_rec);
    end loop;
  else
    l_rname :=            wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');



    hr_utility.trace('funcmode, role name from RUN = '||funcmode||','||l_rname);
  end if;   ---funcmode

-- BUG 4334816 START
-- New code added to capture the Notification id in  psp_eff_report_approvals table
    l_nid    := wf_engine.context_nid;
    l_rname  := wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');

    update psp_eff_report_approvals    set NOTIFICATION_ID = l_nid
    where WF_ITEM_KEY = itemkey
    AND WF_ROLE_NAME = l_rname;

-- BUG 4334816 END

exception
   when others then
     result := 'ERROR';
     --result := result||'=='||sqlerrm;
     wf_core.context('PSP_EFFORT_REPORTS', 'APPROVER_POST_NOTIFY', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

procedure set_pdf_gen_failures(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is
begin
  --- delete any left over PDF files due to failed Conc process for generating
  --- split PDFs
  null;

end;

procedure approver_pdf_fail(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is

l_person_id integer;
l_rname varchar2(300);
l_request_id integer;

l_pdf_request_id    NUMBER;
l_retry_request_id  NUMBER;
l_error_count       NUMBER;

CURSOR  report_error_cur IS
SELECT  1
FROM    psp_report_errors
WHERE   pdf_request_id = l_pdf_request_id;

/*cursor get_person_id is
select person_id
from psp_eff_reports
where effort_report_id in
    (select effort_report_id
      from psp_eff_report_details
     where request_id = l_request_id
       and  effort_report_detail_id in
         (select effort_report_detail_id
            from psp_eff_report_approvals
             where wf_item_key = itemkey
              and wf_role_name = l_rname));*/
begin
  if funcmode = 'RUN' then
    l_rname :=
           wf_engine.GetItemAttrText(itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_ROLE_NAME');
      l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');

      l_pdf_request_id :=
         wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PDF_REQUEST_ID');

      l_retry_request_id :=
         wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'RETRY_REQUEST_ID');

/*
      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => itemkey,
                                 aname    => 'WF_EMBED_INITIATOR',
                                 avalue   =>  'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_ER_WF_INIT_STATUS_DETAILS&erRequestId=-&MSG_REQUEST_ID-'
					|| '&pdfRequestId=-&PDF_REQUEST_ID-&wfItemKey=-&MSG_IKEY-&processParameters=-&PROCESS_PARAMETERS-');

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => itemkey,
                                 aname    => 'INITIATOR_ERROR_STATUS',
                                 avalue   =>  '');
      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => itemkey,
                                 aname    => 'WF_EMBED_INITIATOR_ERRORS',
                                 avalue   =>  'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_ER_WF_INITIATOR_ERRORS&erRequestId=-&MSG_REQUEST_ID-'
					|| '&pdfRequestId=-&PDF_REQUEST_ID-&wfItemKey=-&MSG_IKEY-&processParameters=-&PROCESS_PARAMETERS-');
*/
/*   open get_person_id;
   fetch get_person_id into l_person_id;
   close get_person_id;	*/

	OPEN report_error_cur;
	FETCH report_error_cur INTO l_error_count;
	CLOSE report_error_cur;

	IF (NVL(l_error_count, 0) = 0) THEN
		insert into psp_report_errors
			(error_sequence_id, request_id, message_level, source_id,
			error_message, retry_request_id, pdf_request_id)
		values (psp_report_errors_s.nextval,
			l_request_id, 'E',l_person_id,
			'PDF Generation Failed, please see the Concurrent process log',
			l_retry_request_id, l_pdf_request_id);
	END IF;
  end if;
     result := 'COMPLETE';
exception
   when others then
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'APPROVER_PDF_FAIL', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

 procedure start_initiator_wf(p_request_id in integer)
 is
  l_wf_itemkey varchar2(100);
  l_user_name varchar2(100);
	l_start_date	DATE;
	l_end_date	DATE;
	l_template_name	psp_report_templates_h.template_name%TYPE;
	l_preview_flag	psp_report_templates_h.preview_effort_report_flag%TYPE;
        l_time_out integer;

	CURSOR	template_name_cur IS
	SELECT	template_name,
		preview_effort_report_flag,
                notification_reminder_in_days,
		fnd_date.canonical_to_date(fnd_date.date_to_canonical(parameter_value_2)) start_date,
		fnd_date.canonical_to_date(fnd_date.date_to_canonical(parameter_value_3)) end_date
	FROM	psp_report_templates_h prth
	WHERE	prth.request_id = p_request_id;

        l_param_string		VARCHAR2(2000);
	l_icx_date_format	VARCHAR2(30);
	l_gl_sob		NUMBER;

	CURSOR	get_sob_cur IS
	SELECT	set_of_books_id
	FROM	psp_report_templates_h
	WHERE	request_id = p_request_id;

	CURSOR get_param_strings IS
	SELECT  prt.template_name,
		TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_2)), l_icx_date_format) start_date,
		TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_3)), l_icx_date_format) end_date,
--		xtt.template_name report_layout,
		flv1.meaning sort_option1,
		flv2.meaning order_by1,
		flv3.meaning sort_option2,
		flv4.meaning order_by2,
		flv5.meaning sort_option3,
		flv6.meaning order_by3,
		flv7.meaning sort_option4,
		flv8.meaning order_by4
	FROM	psp_report_templates_h prth,
		xdo_templates_tl xtt,
		psp_report_templates prt,
		(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, l_gl_sob)) flv1,
		(select * from fnd_lookup_values_vl where lookup_type = 'PSP_ORDERING_CRITERIA') flv2,
		(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, l_gl_sob)) flv3,
		(select * from fnd_lookup_values_vl where lookup_type = 'PSP_ORDERING_CRITERIA') flv4,
		(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, l_gl_sob)) flv5,
		(select * from fnd_lookup_values_vl where lookup_type = 'PSP_ORDERING_CRITERIA') flv6,
		(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, l_gl_sob)) flv7,
		(select * from fnd_lookup_values_vl where lookup_type = 'PSP_ORDERING_CRITERIA') flv8
	WHERE	prth.request_id = p_request_id
	AND	prt.template_id = prth.template_id
	AND	flv1.lookup_code = prth.parameter_value_5
--	AND	flv2.lookup_type = 'PSP_ORDERING_CRITERIA'
	AND	flv2.lookup_code = prth.parameter_value_6
	AND	flv3.lookup_code = prth.parameter_value_7
--	AND	flv4.lookup_type = 'PSP_ORDERING_CRITERIA'
	AND	flv4.lookup_code = prth.parameter_value_8
	AND	flv5.lookup_code (+) = prth.parameter_value_9
--	AND	NVL(flv6.lookup_type, 'PSP_ORDERING_CRITERIA') = 'PSP_ORDERING_CRITERIA'
	AND	flv6.lookup_code (+) = prth.parameter_value_10
	AND	flv7.lookup_code (+) = prth.parameter_value_11
--	AND	NVL(flv8.lookup_type, 'PSP_ORDERING_CRITERIA') = 'PSP_ORDERING_CRITERIA'
	AND	flv8.lookup_code (+) = prth.parameter_value_12
	AND	xtt.template_code = prth.report_template_code
	AND	xtt.application_short_name = 'PSP';

	CURSOR	payroll_action_id_cur IS
	SELECT	payroll_action_id
	FROM	pay_payroll_actions
	WHERE	request_id = p_request_id;

	l_arg1		VARCHAR2(100);
	l_arg2		VARCHAR2(100);
	l_arg3		VARCHAR2(100);
	l_arg4		VARCHAR2(100);
	l_arg5		VARCHAR2(100);
	l_arg6		VARCHAR2(100);
	l_arg7		VARCHAR2(100);
	l_arg8		VARCHAR2(100);
	l_arg9		VARCHAR2(100);
	l_arg10		VARCHAR2(100);
	l_arg11		VARCHAR2(100);
	l_arg12		VARCHAR2(100);

	l_retry_request_id		NUMBER(15, 0);
	l_payroll_action_id		NUMBER(15, 0);
	l_emp_matching_selection	NUMBER;

CURSOR	emp_matching_selection_cur IS
SELECT	COUNT(DISTINCT person_id)		-- Modified count(*) to count(distinct person_id) for bug fix 4429787
FROM	psp_selected_persons_t
WHERE	request_id = p_request_id;
 begin

   l_user_name := fnd_global.user_name;
	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);
	l_retry_request_id := fnd_global.conc_request_id;

	OPEN get_sob_cur;
	FETCH get_sob_cur INTO l_gl_sob;
	CLOSE get_sob_cur;

	OPEN payroll_action_id_cur;
	FETCH payroll_action_id_cur INTO l_payroll_action_id;
	CLOSE payroll_action_id_cur;

      select psp_wf_item_key_s.nextval
       into  l_wf_itemkey
       from dual;

	OPEN template_name_cur;
	FETCH template_name_cur INTO l_template_name, l_preview_flag, l_time_out, l_start_date, l_end_date;
	CLOSE template_name_cur;

--BUG 4334816 START
-- code added to store WF_Item_Key in Psp_report_templates_h
        update psp_report_templates_h
        set INITIATOR_WF_ITEM_KEY =  l_wf_itemkey
        where request_id = p_request_id;

--BUG 4334816 END

        --- dynamic timeout should be expresed in minutes,
        --- days to minutes conversion.
        l_time_out := l_time_out * 1440;

      --dbms_output.put_line('FROM START item key ='||l_wf_itemkey);

      wf_engine.CreateProcess(itemtype => 'PSPERAVL',
                              itemkey  => l_wf_itemkey,
                              process  => 'INITIATOR_PROCESS');

    hr_utility.trace('er_workflow --> start_int: reqid ='||to_char(p_request_id));

      /*Added for bug 7004679 */
      wf_engine.setitemowner(itemtype => 'PSPERAVL',
                             itemkey  => l_wf_itemkey,
                             owner    => l_user_name);

      wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'REQUEST_ID',
                                 avalue   => p_request_id);

      wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'TIMEOUT',
                                 avalue   => l_time_out);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'INITIATOR',
                                 avalue   => l_user_name);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'WF_EMBED_INITIATOR',
                                 avalue   =>  'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_ER_WF_INITIATOR_DETAILS&requestId='||p_request_id);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'WF_EMBED_FINAL_RECIPIENT',
                                 avalue   =>  'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_ER_WF_FIN_REC_STATUS&requestId='||p_request_id);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'INITIATOR_ERROR_STATUS',
                                 avalue   =>  'JSP:/OA_HTML/OA.jsp?OAFunc=PSP_ER_WF_ERROR_STATUS&requestId='||p_request_id);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'START_DATE',
                                 avalue   => l_start_date);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'END_DATE',
                                 avalue   => l_end_date);

      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                itemkey  => l_wf_itemkey,
                                aname    => 'ITEM_KEY',
                                avalue   => l_wf_itemkey);

    	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => l_wf_itemkey,
				aname    => 'RECEIVER_FLAG',
				avalue   => 'IR');

    	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => l_wf_itemkey,
				aname    => 'TEMPLATE_NAME',
				avalue   => l_template_name);

	IF (l_preview_flag = 'Y') THEN
	      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => '#ATTACHMENTS',
                                 avalue   => 'FND:entity=ERDETAILS&pk1name=WF_ITEM_KEY&pk1value=' || l_wf_itemkey || '&pk2name=RECEIVER_FLAG&pk2value=' || 'IR');
          --Bug 7135471
          wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => l_wf_itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || 'PSPERAVL' || ':' || l_wf_itemkey);

	ELSE
	      wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => '#ATTACHMENTS',
                                 avalue   => '');

	      --Bug 7135471
              wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => l_wf_itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => '');

	END IF;

	IF (p_request_id <> l_retry_request_id) THEN
		wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
			itemkey  => l_wf_itemkey,
			aname    => 'RETRY_REQUEST_ID',
			avalue   => l_retry_request_id);
	END IF;

	OPEN emp_matching_selection_cur;
	FETCH emp_matching_selection_cur INTO l_emp_matching_selection;
	CLOSE emp_matching_selection_cur;

	wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
		itemkey  => l_wf_itemkey,
		aname    => 'EMP_MATCHING_SELECTION',
		avalue   => l_emp_matching_selection);

	OPEN get_param_strings;
	FETCH get_param_strings INTO l_arg1, l_arg2, l_arg3, /* l_arg4,*/ l_arg5, l_arg6, l_arg7, l_arg8, l_arg9, l_arg10, l_arg11, l_arg12;
	CLOSE get_param_strings;

	fnd_message.set_name('PSP', 'PSP_ER_WF_PROCESS_PARAMETERS');
	fnd_message.set_token('TEMPLATE_NAME', l_arg1);
	fnd_message.set_token('START_DATE', l_arg2);
	fnd_message.set_token('END_DATE', l_arg3);
--	fnd_message.set_token('REPORT_LAYOUT', l_arg4);
	fnd_message.set_token('FIRST_SORT_BY', l_arg5);
	fnd_message.set_token('FIRST_ORDER_BY', l_arg6);
	fnd_message.set_token('SECOND_SORT_BY', l_arg7);
	fnd_message.set_token('SECOND_ORDER_BY', l_arg8);
	fnd_message.set_token('THIRD_SORT_BY', l_arg9);
	fnd_message.set_token('THIRD_ORDER_BY', l_arg10);
	fnd_message.set_token('FOURTH_SORT_BY', l_arg11);
	fnd_message.set_token('FOURTH_ORDER_BY', l_arg12);

	l_param_string := fnd_message.get;

    	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => l_wf_itemkey,
				aname    => 'CONC_PARAM_STRING',
				avalue   => l_param_string);

	wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
		itemkey	=>	l_wf_itemkey,
		aname	=>	'PAYROLL_ACTION_ID',
		avalue	=>	l_payroll_action_id);

      wf_engine.StartProcess(itemtype => 'PSPERAVL',
                            itemkey  => l_wf_itemkey);
   end;

procedure initiator_response(itemtype in  varchar2,
                             itemkey  in  varchar2,
                             actid    in  number,
                             funcmode in  varchar2,
                             result   out nocopy varchar2) is
 l_request_id integer;
 cursor get_init_response is
 select initiator_accept_flag
   from psp_report_templates_h
  where request_id = l_request_id;
 l_response varchar2(10);
begin
 if funcmode = 'RUN' then
  l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');
  open get_init_response;
  fetch get_init_response into l_response;
  close get_init_response;
  if l_response = 'Y' then
   result := 'COMPLETE:APPROVED';
  else
   result := 'COMPLETE:REJECTED';
  end if;
 end if;
exception
   when others then
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'INITIATOR_RESPONSE', itemtype, itemkey, to_char(actid), funcmode);
     raise;
end;

 procedure create_frp_role(itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2) is

    l_recipnt_role wf_roles.name%type;
    l_request_id integer;
    l_member_rname wf_roles.name%type;

    cursor get_member_role is
    select distinct wf.name
     from wf_roles wf,
          psp_report_template_details_h temp
    where temp.request_id = l_request_id
      and wf.orig_system = 'PER'
      and to_char(wf.orig_system_id) = temp.criteria_value1
      and temp.criteria_lookup_type = 'PSP_SELECTION_CRITERIA'
      and temp.criteria_lookup_code = 'FRP';
   i integer := 0;
   l_debug varchar2(2000);
   l_frp_role_display varchar2(100);

   cursor check_approval_count is
     select count(*)
     from psp_eff_reports
     where status_code = 'A'
       and request_id = l_request_id;

   l_count integer;
begin
	l_recipnt_role := 'PSP_FINAL_RECIPIENT_'||itemkey;
	l_frp_role_display := 'Effort Report Final Recipients';
        l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');

        wf_directory.createAdhocRole(l_recipnt_role,
                                     l_frp_role_display);

      open check_approval_count;
      fetch check_approval_count into l_count;
      close check_approval_count;

     if l_count > 0 then
        open get_member_role;
        loop
        fetch get_member_role into l_member_rname;
           if get_member_role%notfound then
              close get_member_role;
              exit;
           end if;
           i := i + 1;
           wf_directory.AddUsersToAdHocRole
               (role_name  => l_recipnt_role,
                role_users => l_member_rname);
        end loop;

        if i > 0 then

         result := 'COMPLETE:Y';

	   wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
				   itemkey  => itemkey,
				   aname    => 'FINAL_RECIPIENT',
				   avalue   => l_recipnt_role);
           update psp_report_templates_h
              set final_recip_notified_flag = 'Y'
           where request_id = l_request_id;
        else
         result := 'COMPLETE:N';
        end if;
    else
         result := 'COMPLETE:N';
    end if;

exception
   when others then
     ---l_debug := sqlerrm;
     ---hr_utility.trace('er_workflow --> 120'||l_debug);
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'CREATE_FRP_ROLE', itemtype, itemkey, to_char(actid), funcmode);
end;

 procedure get_pdf_for_apprvr(itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2) is
 begin
  -- to consutruct the attachment attribute for the notification.
  --- link the PDF using the attachment attribute
  --dbms_output.put_line(' attach the pdf here for the notification');
/*

	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || itemtype || ':' || itemkey);
*/
null;

 end;

 procedure gen_modified_pdf(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is
 begin
	fnd_wf_standard.executeconcprogram(itemtype ,
				itemkey  ,
				actid    ,
				funcmode ,
				result   );

	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || itemtype || ':' || itemkey);

 end;

 procedure update_receiver(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is

   -- Bug 7135471 starts
   l_request_id integer;

   cursor get_approval_type is
     select approval_type
      from psp_report_templates_h
      where request_id = l_request_id;

   l_approval_type varchar2(100);

 begin

   l_request_id :=
	         wf_engine.GetItemAttrText(itemtype => itemtype,
	                                   itemkey  => itemkey,
	                                   aname    => 'REQUEST_ID');

   open get_approval_type;
   fetch get_approval_type into l_approval_type;
   close get_approval_type;

   IF   l_approval_type = 'PRE'   THEN

   --this code is to delete the pdf that has already been created with the DRAFT watermark
   --for PRE APPROVED report types
     delete from fnd_lobs
     where file_id in(select media_id from fnd_documents_vl
                      where document_id in(select document_id from fnd_attached_documents
                                           where pk1_value = itemkey));



     delete from fnd_attached_documents
     where pk1_value = itemkey;

   END IF;
  -- Bug 7135471 End



    wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => itemkey,
				aname    => 'RECEIVER_FLAG',
				avalue   => 'FR');

    wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                              itemkey  => itemkey,
                              aname    => '#ATTACHMENTS',
                              avalue   => 'FND:entity=ERDETAILS&pk1name=WF_ITEM_KEY&pk1value=' || itemkey || '&pk2name=RECEIVER_FLAG&pk2value=' || 'FR');

  --Bug 7135471
     wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
	    			itemKey  => itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || 'PSPERAVL' || ':' || itemkey);


 end update_receiver;

 procedure update_approver(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2) is
 begin
	wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => itemkey,
				aname    => 'RECEIVER_FLAG',
				avalue   => 'AR');

    wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                              itemkey  => itemkey,
                              aname    => '#ATTACHMENTS',
                              avalue   => 'FND:entity=ERDETAILS&pk1name=WF_ITEM_KEY&pk1value=' || itemkey || '&pk2name=RECEIVER_FLAG&pk2value=' || 'AR');

--Bug 7135471
          wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
				itemKey  => itemkey,
				aname    => 'PDF_ATTACHMENT',
				avalue   => 'PLSQLBLOB:psp_xmlgen.attach_pdf/' || 'PSPERAVL' || ':' || itemkey);


 end update_approver;

procedure pre_approved(itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   out nocopy varchar2) is

  l_request_id integer;
  cursor get_approval_type is
  select approval_type
    from psp_report_templates_h
   where request_id = l_request_id;
  l_approval_type varchar2(100);
begin
  l_request_id :=
         wf_engine.GetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'REQUEST_ID');
  open get_approval_type;
  fetch get_approval_type into l_approval_type;
  close get_approval_type;

  if l_approval_type = 'PRE' then
         result := 'COMPLETE:Y';
  else
         result := 'COMPLETE:N';
  end if;
exception
   when others then
     result := 'ERROR';
     wf_core.context('PSP_EFFORT_REPORTS', 'PRE_APPROVED', itemtype, itemkey, to_char(actid),
funcmode);

end;

PROCEDURE update_initiator_message      (itemtype       IN  varchar2,
                                        itemkey         IN  varchar2,
                                        actid           IN  number,
                                        funcmode        IN  varchar2,
                                        result          OUT nocopy varchar2) IS
l_message_name          fnd_new_messages.message_name%TYPE;
l_message_text          fnd_new_messages.message_text%TYPE;
BEGIN
        l_message_name := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'INITIATOR_MESSAGE_NAME');
        fnd_message.set_name('PSP', l_message_name);
        l_message_text := fnd_message.get;
        wf_engine.SetItemAttrText(itemtype      =>      itemtype,
                                itemkey         =>      itemkey,
                                aname           =>      'ERROR_MESSAGE',
                                avalue          =>      l_message_text);

        result := 'COMPLETE';

EXCEPTION
WHEN OTHERS THEN
--      Populate stack with error message
        result := 'ERROR';
        wf_core.context('PSP_EFFORT_REPORTS', 'update_initiator_message', itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
END update_initiator_message;

PROCEDURE set_wf_admin(itemtype IN  varchar2,
                       itemkey  IN  varchar2,
                       actid    IN  number,
                       funcmode IN  varchar2,
                       result   OUT nocopy varchar2) IS

 l_initiator_rname wf_roles.name%type;

BEGIN
       l_initiator_rname :=
        wf_engine.GetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'INITIATOR');

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey    => itemkey,
                                aname      => 'WF_ADMINISTRATOR',
                                avalue     => l_initiator_rname);

	--Bug 7135471
        If itemkey is not null then

         	if(item_attribute_exists(itemtype,itemkey,'PDF_ATTACHMENT')) then
	       hr_utility.trace('PDF_ATTACHMENT attribute exists');
	else
		                 wf_engine.additemattr
	   			            (itemtype     => itemtype,
	 			             itemkey      => itemkey,
	 			             aname        => 'PDF_ATTACHMENT',
	 		    	             text_value   => '');
	        end if;

         end if;


        result := 'COMPLETE';

        ---- call the user hook for wf admin role here.
        ---- By default setting it to Initiator.
        psp_er_wf_custom.set_custom_wf_admin(itemtype ,
                                             itemkey  ,
                                             actid    ,
                                             funcmode ,
                                             result);
EXCEPTION
WHEN OTHERS THEN
  result := 'ERROR';
  wf_core.context('PSP_EFFORT_REPORTS', 'SET_WF_ADMIN', itemtype, itemkey, to_char(actid), funcmode);
   raise;
END;

PROCEDURE get_timeout_approver(itemtype IN  varchar2,
                               itemkey  IN  varchar2,
                               actid    IN  number,
                               funcmode IN  varchar2,
                               result   OUT nocopy varchar2) IS
BEGIN
        result := 'COMPLETE';
       ---- user hook for time out approver
        psp_er_Wf_custom.set_custom_timeout_approver(itemtype ,
                                                     itemkey  ,
                                                     actid    ,
                                                     funcmode ,
                                                     result   );

EXCEPTION
WHEN OTHERS THEN
--      Populate stack with error message
        result := 'ERROR';
        wf_core.context('PSP_EFFORT_REPORTS', 'GET_TIMEOUT_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
        RAISE;
END;

PROCEDURE preview_er	(itemtype	IN  varchar2,
			itemkey		IN  varchar2,
			actid		IN  number,
			funcmode	IN  varchar2,
			result		OUT nocopy varchar2) IS
l_preview_flag	psp_report_templates_h.preview_effort_report_flag%TYPE;
l_request_id	NUMBER(15, 0);
CURSOR	preview_er_cur IS
SELECT	preview_effort_report_flag
FROM	psp_report_templates_h prth
WHERE	prth.request_id = l_request_id;
BEGIN
	l_request_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                itemkey    => itemkey,
                                aname      => 'REQUEST_ID');

	OPEN preview_er_cur;
	FETCH preview_er_cur INTO l_preview_flag;
	CLOSE preview_er_cur;

	result := 'COMPLETE:' || l_preview_flag;
EXCEPTION
WHEN OTHERS THEN
--      Populate stack with error message
        result := 'ERROR';
        wf_core.context('PSP_EFFORT_REPORTS', 'PREVIEW_ER', itemtype, itemkey, TO_CHAR(actid), funcmode);
        RAISE;
END preview_er;

-- Added this function for Bug 7135471
FUNCTION item_attribute_exists
                (p_item_type in wf_items.item_type%type,
                 p_item_key  in wf_item_activity_statuses.item_key%type,
                 p_name      in wf_item_attribute_values.name%type)
                 return boolean is

      l_dummy varchar2(1);

BEGIN

      select 'Y'
        into l_dummy
        from wf_item_attribute_values
       where item_type = p_item_type
         and item_key = p_item_key
         and name = p_name;

      return true;

Exception
       When others then
         return false;

END item_attribute_exists;

end;

/

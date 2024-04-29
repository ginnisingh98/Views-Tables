--------------------------------------------------------
--  DDL for Package Body PO_CHANGEORDERWF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHANGEORDERWF_PVT" AS
/* $Header: POXVSCWB.pls 120.36.12010000.21 2014/02/10 15:09:00 pneralla ship $ */


g_pkg_name CONSTANT VARCHAR2(50) := 'PO_ChangeOrderWF_PVT';
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

-- Read the profile option that determines whether the promise date will be defaulted with need-by date or not
g_default_promise_date VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('POS_DEFAULT_PROMISE_DATE_ACK'),'N');
NL                VARCHAR2(1) := fnd_global.newline;

/*Initializing Private Procedures/Functions*/
PROCEDURE Notify_Requester_Sup_Change(	p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										p_chg_req_grp_id in number,
										p_requestor_id in number);

PROCEDURE Notify_Planner_Sup_Change(	p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										p_chg_req_grp_id in number,
										p_planner_id in number);

/*************************************************************************
 * Private Procedure: InsertActionHist
 * Effects: insert into action history table.
 *
 *          It is called when the change request is submitted (by requester
 *          or buyer) and when buyer responds to the change request.
 *
 *          the action can be 'SUBMIT CHANGE', 'ACCEPTED', 'REJECTED'
 *          or 'RESPOND'
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
PROCEDURE InsertActionHist(
        p_doc_id number,
        p_doc_type varchar2,
        p_doc_subtype varchar2,
        p_employee_id number,
        p_action varchar2,
        p_note varchar2,
        p_path_id number);

PROCEDURE		Commit_CancelPO(
			x_return_status out NOCOPY varchar2,
			p_can_doc_type in varchar2,
			p_can_doc_subtype in varchar2,
			p_can_hdr_id in number,
			p_can_rel_id in number,
			p_can_line_id in number,
			p_can_line_loc_id in number,
			p_can_reason in varchar2,
            p_can_req_flag in varchar2,
			p_launch_approvals_flag IN VARCHAR2 --Bug 13114334
			);

PROCEDURE initialize(p_employee_id in NUMBER, p_org_id IN NUMBER);

-- Making this api public RDP requirements
/* procedure NotifySupAllChgRpdWF( 	p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number);  */

procedure CancelPO( x_return_status out NOCOPY varchar2,
					p_header_id in number,
					p_release_id in number,
					p_chg_req_grp_id in number);

Procedure Insert_Acc_Rejection_Row(	p_itemtype        in  varchar2,
                              	   	p_itemkey         in  varchar2,
	                           		p_actid           in  number,
				   					p_flag		   in  varchar2);

Procedure Update_Chg_Req_If_Po_Apprvd(  p_header_id  in number,
                                        p_release_id in number);

/**
 * Private procedure: Carry_Over_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 * Effects:  Carry over the shipment_level acknowledgement results from the
 *           previous revision, it is called before launching PO approval
 *           workflow after supplier's change has been accepted by buyer.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *
 * Bugs Fixed:
 * 7205793 - Added internal procedure, which is an autonomous transaction
 *           to avoid deadlock during PO Approval Process.
 */
PROCEDURE Carry_Over_Acknowledgement (x_return_status  OUT  NOCOPY VARCHAR2,
                                      p_po_header_id   IN   NUMBER,
                                      p_po_release_id  IN   NUMBER,
                                      p_revision_num   IN   NUMBER );

PROCEDURE Notify_Requester_Sup_Change(	p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										p_chg_req_grp_id in number,
										p_requestor_id in number)
IS
l_api_name varchar2(50):= 'Notify_Requester_Sup_Change';
l_progress varchar2(5) := '000';
l_seq number;
l_item_key 					varchar2(2000);

l_supplier_username fnd_user.user_name%type;
l_requestor_username fnd_user.user_name%type;
l_requestor_disp_name varchar2(2000);

n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;
t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;
BEGIN

	if(p_requestor_id is null or p_chg_req_grp_id is null) then
		return;
	end if;

	select PO_SUPPLIER_CHANGE_WF_S.nextval into l_seq from dual;
	if(p_release_id is null) then
		l_item_key := 'NRSC-'||to_char(p_requestor_id)||'-'||to_char(p_header_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
	else
		l_item_key := 'NRSC-'||to_char(p_requestor_id)||'-'||to_char(p_release_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
	end if;

	l_progress := '001';

	wf_engine.createProcess (	ItemType => 'POSCHORD',
								ItemKey => l_item_key,
								Process => 'NOTIFY_REQUESTER_SUP_CHN');

	l_progress := '002';
	wf_directory.GetUserName    ( p_orig_system    => 'PER',
                                  p_orig_system_id => p_requestor_id,
                                  p_name           => l_requestor_username,
                                  p_display_name   => l_requestor_disp_name);

  IF(l_requestor_disp_name is not null) THEN
    l_progress := '003';
	-- Get Supplier User Name
	select user_name
	into l_supplier_username
	from fnd_user
	where user_id = fnd_global.user_id;

	n_varname(1) := 'PO_HEADER_ID';
	n_varval(1)  := p_header_id;
	n_varname(2) := 'PO_RELEASE_ID';
	n_varval(2)  := p_release_id;
	n_varname(3) := 'PO_REVISION_NUM';
	n_varval(3)  := p_revision_num;
        n_varname(4) := 'CHANGE_REQUEST_GROUP_ID';
        n_varval(4)  := p_chg_req_grp_id;

	t_varname(1) := 'FROM_SUPPLIER';
	t_varval(1)  := l_supplier_username;
	t_varname(2) := 'NTF_FOR_REQ_SUP_CHN';
	t_varval(2)  := 'PLSQLCLOB:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_REQ_SUP_CHN/'||
							'@'	||p_header_id||'#'
								||p_release_id||'$'
								||p_chg_req_grp_id||'%'
								||p_requestor_id||'^';

	t_varname(3) := 'NTF_FOR_REQ_SUBJECT';
	t_varval(3)  := 'PLSQL:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_REQ_SUBJECT/'||l_item_key;
	t_varname(4) := 'PREPARER_USERNAME';
	t_varval(4)  := l_requestor_username;


	l_progress := '004';

	Wf_Engine.SetItemAttrNumberArray('POSCHORD', l_item_key,n_varname,n_varval);
	Wf_Engine.SetItemAttrTextArray('POSCHORD', l_item_key,t_varname,t_varval);

	wf_engine.StartProcess(	ItemType => 'POSCHORD',
							ItemKey => l_item_key);
END IF;
exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;

END Notify_Requester_Sup_Change;

PROCEDURE Notify_Planner_Sup_Change(	p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										p_chg_req_grp_id in number,
										p_planner_id in number)
IS
l_api_name varchar2(50):= 'Notify_Planner_Sup_Change';
l_progress varchar2(5) := '000';
l_seq number;
l_item_key 					varchar2(2000);

l_supplier_username fnd_user.user_name%type;
l_planner_username fnd_user.user_name%type;
l_planner_disp_name varchar2(2000);
l_type_lookup_code po_headers_all.type_lookup_code%type;

n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;
t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;

BEGIN

	if(p_planner_id is null or p_chg_req_grp_id is null) then
		return;
	end if;

	select PO_SUPPLIER_CHANGE_WF_S.nextval into l_seq from dual;

        if(p_release_id is null) then
                l_item_key := 'NPSC-'||to_char(p_planner_id)||'-'||to_char(p_header_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
        else
                l_item_key := 'NPSC-'||to_char(p_planner_id)||'-'||to_char(p_release_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
	end if;

	l_progress := '001';
	wf_engine.createProcess (	ItemType => 'POSCHORD',
								ItemKey => l_item_key,
								Process => 'NOTIFY_PLANNER_SUP_CHN');

	l_progress := '002';
	wf_directory.GetUserName    ( p_orig_system    => 'PER',
                                  p_orig_system_id => p_planner_id,
                                  p_name           => l_planner_username,
                                  p_display_name   => l_planner_disp_name);

  IF(l_planner_disp_name is not null) THEN
    l_progress := '003';
	-- Get Supplier User Name
	select user_name
	into l_supplier_username
	from fnd_user
	where user_id = fnd_global.user_id;


	n_varname(1) := 'PO_HEADER_ID';
	n_varval(1)  := p_header_id;
	n_varname(2) := 'PO_RELEASE_ID';
	n_varval(2)  := p_release_id;
	n_varname(3) := 'PO_REVISION_NUM';
	n_varval(3)  := p_revision_num;
        n_varname(4) := 'CHANGE_REQUEST_GROUP_ID';
	n_varval(4)  := p_chg_req_grp_id;


	t_varname(1) := 'FROM_SUPPLIER';
	t_varval(1)  := l_supplier_username;
	t_varname(2) := 'NTF_FOR_PLAN_SUP_CHN';
	t_varval(2)  := 'PLSQLCLOB:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_PLAN_SUP_CHN/'||
							'@'	||p_header_id||'#'
								||p_release_id||'$'
								||p_chg_req_grp_id||'%'
								||p_planner_id||'^';

	t_varname(3) := 'NTF_FOR_PLAN_SUBJECT';
	t_varval(3)  := 'PLSQL:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_PLAN_SUBJECT/'||l_item_key;
	t_varname(4) := 'PLANNER_USERNAME';
	t_varval(4)  := l_planner_username;


	l_progress := '004';

	Wf_Engine.SetItemAttrNumberArray('POSCHORD', l_item_key,n_varname,n_varval);
	Wf_Engine.SetItemAttrTextArray('POSCHORD', l_item_key,t_varname,t_varval);

	wf_engine.StartProcess(	ItemType => 'POSCHORD',
							ItemKey => l_item_key);
END IF;
exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;

END Notify_Planner_Sup_Change;


/*************************************************************************
 * Private Procedure: InsertActionHist
 * Effects: insert into action history table.
 *
 *          It is called when the change request is submitted (by requester
 *          or buyer) and when buyer responds to the change request.
 *
 *          the action can be 'SUBMIT CHANGE', 'ACCEPTED', 'REJECTED'
 *          or 'RESPOND'
 *
 *          the process will commit when it exits.
 *
 * Returns:
 ************************************************************************/
PROCEDURE InsertActionHist(
        p_doc_id number,
        p_doc_type varchar2,
        p_doc_subtype varchar2,
        p_employee_id number,
        p_action varchar2,
        p_note varchar2,
        p_path_id number) is

pragma AUTONOMOUS_TRANSACTION;

l_action_code po_action_history.action_code%type;
l_revision_num number := NULL;
l_hist_count   number := NULL;
l_sequence_num   number := NULL;
l_approval_path_id number;

CURSOR action_hist_cursor(doc_id number , doc_type varchar2) is
   select max(sequence_num)
   from po_action_history
   where object_id= doc_id and
   object_type_code = doc_type;

CURSOR action_hist_code_cursor (doc_id number , doc_type varchar2, seq_num number) is
   select action_code
   from po_action_history
   where object_id = doc_id and
   object_type_code = doc_type and
   sequence_num = seq_num;


x_progress varchar2(3):='000';

BEGIN

  /* Get the document authorization status.
  ** has been submitted before, i.e.
  ** First insert a row with  a SUBMIT action.
  ** Then insert a row with a NULL ACTION_CODE to simulate the forward-to
  */

  x_progress := '001';

  l_approval_path_id := p_path_id;

  IF p_doc_type IN ('PO','PA') THEN

    x_progress := '003';

      select revision_num
             into l_revision_num
      from PO_HEADERS_ALL
      where po_header_id = p_doc_id;

  ELSIF p_doc_type = 'RELEASE' THEN

      x_progress := '004';

      select revision_num
             into l_revision_num
      from PO_RELEASES_ALL
      where po_release_id = p_doc_id;

  END IF;

   x_progress := '005';

   /* Check if this document had been submitted to workflow at some point
   ** and somehow kicked out. If that's the case, the sequence number
   ** needs to be incremented by one. Otherwise start at zero.
   */
   OPEN action_hist_cursor(p_doc_id , p_doc_type );
   FETCH action_hist_cursor into l_sequence_num;
   CLOSE action_hist_cursor;
   IF l_sequence_num is NULL THEN
      l_sequence_num := 1; --Bug 13370924
   ELSE
      OPEN action_hist_code_cursor(p_doc_id , p_doc_type, l_sequence_num);
      FETCH action_hist_code_cursor into l_action_code;
      l_sequence_num := l_sequence_num +1;
   END IF;


   x_progress := '006';
   IF ((l_sequence_num = 1)
        OR
       (l_sequence_num > 1 and l_action_code is NOT NULL)) THEN
      x_progress := '007';
      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_doc_id,
              p_doc_type,
              p_doc_subtype,
              l_sequence_num,
              sysdate,
              nvl(fnd_global.user_id, 1),
              sysdate,
              nvl(fnd_global.user_id, 1),
              p_action,
              decode(p_action, '',to_date(null,'DD/MM/YYYY'), sysdate),
              p_employee_id,
              p_note,
              l_revision_num,
              nvl(fnd_global.login_id, 1),
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );
      x_progress := '008';

    ELSE
        l_sequence_num := l_sequence_num - 1;
        x_progress := '009';
        UPDATE PO_ACTION_HISTORY
          set object_id = p_doc_id,
              object_type_code = p_doc_type,
              object_sub_type_code = p_doc_subtype,
              sequence_num = l_sequence_num,
              last_update_date = sysdate,
              last_updated_by = nvl(fnd_global.user_id, 1),
              creation_date = sysdate,
              created_by = nvl(fnd_global.user_id, 1),
              action_code = p_action,
              action_date = decode(p_action, '',to_date(null,'DD/MM/YYYY'), sysdate),
              employee_id = p_employee_id,
              note = p_note,
              object_revision_num = l_revision_num,
              last_update_login = nvl(fnd_global.login_id, 1),
              request_id = 0,
              program_application_id = 0,
              program_id = 0,
              program_update_date = '',
              approval_path_id = l_approval_path_id,
              offline_code = ''
        WHERE
              object_id= p_doc_id and
              object_type_code = p_doc_type and
              sequence_num = l_sequence_num;

      x_progress := '010';
    END IF;
    x_progress := '017';

commit;
EXCEPTION
   WHEN OTHERS THEN
        wf_core.context('PO_ChangeOrderWF_PVT',
                               'InsertActionHist'||sqlerrm,x_progress);
        raise;

END InsertActionHist;


PROCEDURE Update_Chg_Req_If_Po_Apprvd(p_header_id number ,
                                         p_release_id number)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_api_name varchar2(50) :='Update_Chg_Req_If_Po_Apprvd';
Begin

IF (p_release_id is not null) THEN
                update po_releases_all
                set change_requested_by = null
                where po_release_id = p_release_id;
ELSE
        update po_headers_all
                set change_requested_by = null
                where po_header_id = p_header_id;
END IF;

commit;
exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception',sqlerrm);
	END IF;
End Update_Chg_Req_If_Po_Apprvd;

/**
 * Private procedure: Carry_Over_Acknowledgement
 * Requires: PO_HEADER_ID, PO_RELEASE_ID, REVISION_NUM,
 * Effects:  Carry over the shipment_level acknowledgement results from the
 *           previous revision, it is called before launching PO approval
 *           workflow after supplier's change has been accepted by buyer.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if all messages are appended
 *                     FND_API.G_RET_STS_ERROR if an error occurs
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 *
 * Bugs Fixed:
 * 7205793 - Added internal procedure, which is an autonomous transaction
 *           to avoid deadlock during PO Approval Process.
 */

PROCEDURE Carry_Over_Acknowledgement( x_return_status  OUT  NOCOPY  VARCHAR2,
                                      p_po_header_id   IN   NUMBER,
                                      p_po_release_id  IN   NUMBER,
                                      p_revision_num   IN   NUMBER )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
  l_api_name varchar2(50) :='Carry_Over_Acknowledgement';
  l_carryover_exception exception;
Begin
  IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name || '.invoked','Autonomous Transaction');
  END IF;

  PO_ACKNOWLEDGE_PO_GRP.carry_over_acknowledgement(1.0,
                                                   FND_API.G_FALSE,
                                                   x_return_status,
                                                   p_po_header_id,
                                                   p_po_release_id,
                                                   p_revision_num);
  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    raise l_carryover_exception;
  end if;
  commit;
exception when others then
  IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
    FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix || l_api_name || '.others_exception',sqlerrm);
  END IF;
  RAISE;
End Carry_Over_Acknowledgement;


PROCEDURE		Commit_CancelPO(
			x_return_status out NOCOPY varchar2,
			p_can_doc_type in varchar2,
			p_can_doc_subtype in varchar2,
			p_can_hdr_id in number,
			p_can_rel_id in number,
			p_can_line_id in number,
			p_can_line_loc_id in number,
			p_can_reason in varchar2,
            p_can_req_flag in varchar2,
			p_launch_approvals_flag IN VARCHAR2 --Bug 13114334
			)
IS
pragma AUTONOMOUS_TRANSACTION;
l_api_name varchar2(50):= 'Commit_CancelPO';
l_cancel_flag varchar2(1);
BEGIN

-- start of fix for bug 3864512
-- update status of buyer approved cancel shipment requests to a special status WAIT_CANCEL_APP

update po_change_requests
set request_status = 'WAIT_CANCEL_APP'
where request_status = 'BUYER_APP'
and action_type = 'CANCELLATION'
and request_level = 'SHIPMENT'
and document_line_location_id = p_can_line_loc_id;

-- end of fix for bug 3864512


--Commiting Status to "APPOVED".
	if(p_can_rel_id is null) then
		update po_headers_all
		set authorization_status = 'APPROVED'
		where po_header_id = p_can_hdr_id;
	else
		update po_releases_all
		set authorization_status = 'APPROVED'
		where po_release_id = p_can_rel_id;
	end if;
	commit;
	PO_Document_Control_GRP.control_document
		   (p_api_version  => 1.0,
		    p_init_msg_list => FND_API.G_TRUE,
		    p_commit     => FND_API.G_TRUE,
		    x_return_status  => x_return_status,
		    p_doc_type    => p_can_doc_type,
		    p_doc_subtype  => p_can_doc_subtype,
		    p_doc_id    => p_can_hdr_id,
		    p_doc_num    => null,
		    p_release_id  => p_can_rel_id,
		    p_release_num  => null,
		    p_doc_line_id  => p_can_line_id,
		    p_doc_line_num  => null,
		    p_doc_line_loc_id  => p_can_line_loc_id ,
		    p_doc_shipment_num => null,
		    p_source     => null,
		    p_action      => 'CANCEL',
		    p_action_date   => sysdate,
		    p_cancel_reason  => p_can_reason,
		    p_cancel_reqs_flag  => p_can_req_flag,
		    p_print_flag     => 'N',
		    p_note_to_vendor  =>null,
			p_launch_approvals_flag => p_launch_approvals_flag --Bug 13114334
			);
	--Restoring PO's Authorization status back to "IN PROCESS".
	if(p_can_rel_id is null) then
		if(p_can_line_loc_id is null) then
			select cancel_flag into l_cancel_flag
			from po_headers_all
			where po_header_id = p_can_hdr_id;
		else
			select cancel_flag into l_cancel_flag
			from po_line_locations_all
			where line_location_id = p_can_line_loc_id;
		end if;
		update po_headers_all
		set authorization_status = 'IN PROCESS'
		where po_header_id = p_can_hdr_id;
	else
		if(p_can_line_loc_id is null) then
			select cancel_flag into l_cancel_flag
			from po_releases_all
			where po_release_id = p_can_rel_id;
		else
			select cancel_flag into l_cancel_flag
			from po_line_locations_all
			where line_location_id = p_can_line_loc_id;
		end if;

		update po_releases_all
		set authorization_status = 'IN PROCESS'
		where po_release_id = p_can_rel_id;
	end if;
	commit;

	if(l_cancel_flag = 'Y') then
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;

exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	--Restoring PO's Authorization status back to "IN PROCESS".
	if(p_can_rel_id is null) then
		update po_headers_all
		set authorization_status = 'IN PROCESS'
		where po_header_id = p_can_hdr_id;
	else
		update po_releases_all
		set authorization_status = 'IN PROCESS'
		where po_release_id = p_can_rel_id;
	end if;
	commit;

end 	Commit_CancelPO;


/*
*This API is called by ProcessResponse, to process Cancellation Requests approved by the Buyer.
*This API needs to be an autonomous transaction because of the following reason:
*The moment when this API is called, the PO authorization status should be "IN PROCESS". However, in order to
*call PO Cancel API, the autho status needs to be commited to "APPROVED". Thus this API
*commits the status to "APPROVED", afterwhich commits it back to "IN PROCESS".
*/
procedure CancelPO( x_return_status out NOCOPY varchar2,
					p_header_id in number,
					p_release_id in number,
					p_chg_req_grp_id in number)
is
l_api_name varchar2(50) := 'CancelPO';
l_can_req_id number;
l_can_hdr_id number;
l_can_rel_id number;
l_can_line_id number;
l_can_line_loc_id number;
l_can_reason po_change_requests.request_reason%TYPE;
l_cancel_backing_req  po_change_requests.cancel_backing_req%TYPE;
l_can_doc_type po_document_types_all.document_type_code%TYPE;
l_can_doc_subtype po_document_types_all.document_subtype%TYPE;
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_return_status varchar2(1);
x_progress varchar2(3);
l_ship_can_err_msg varchar2(2000) := fnd_message.get_string('PO','PO_CHN_CAN_SHIP_ERR');
l_hdr_can_err_msg varchar2(2000) := fnd_message.get_string('PO','PO_CHN_CAN_HDR_ERR');
/* Code changes for bug 13114334 - Start */
l_cancel_count number;
l_cancel_index number;
l_launch_approvals_flag  varchar2(1) := 'N';
/* Code changes for bug 13114334 - End */
cursor l_cancel_ship_csr(grp_id number) is
select
	change_request_id,
	document_header_id,
	po_release_id,
	document_line_id,
	document_line_location_id,
	request_reason,
      document_type,
      cancel_backing_req
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'SHIPMENT'
and request_status = 'BUYER_APP';

cursor l_cancel_hdr_csr(grp_id number) is
select
	change_request_id,
	document_header_id,
	po_release_id,
	request_reason
	,document_type,
	cancel_backing_req
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'HEADER'
and request_status = 'BUYER_APP';

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* Code changes for bug 13114334 - Start */
    	select count(*) into l_cancel_count
    	from  po_change_requests
    	where change_request_group_id=p_chg_req_grp_id
              and request_status='BUYER_APP'
	      and request_level = 'SHIPMENT'
              and action_type='CANCELLATION';
    	l_cancel_index := 0;
	/* Code changes for bug 13114334 - End */

--Calling PO Cancel API to process Shipment level Cancellation approved by the buyer.
	open l_cancel_ship_csr(p_chg_req_grp_id);
	loop
	fetch l_cancel_ship_csr into
		l_can_req_id,
		l_can_hdr_id,
		l_can_rel_id,
		l_can_line_id,
		l_can_line_loc_id,
		l_can_reason,
		l_can_doc_type,
            l_cancel_backing_req;
	exit when l_cancel_ship_csr%NOTFOUND;

            if (l_cancel_backing_req <> 'Y') then
               l_cancel_backing_req := 'N';
            end if;

	    /* Code changes for bug 13114334 - Start */
			l_cancel_index := l_cancel_index + 1;
            if(l_cancel_index = l_cancel_count ) then
	      	   l_launch_approvals_flag := 'Y';
            end if;
        /* Code changes for bug 13114334 - End */

		select type_lookup_code
		into l_type_lookup_code
		from po_headers_all
		where po_header_id = l_can_hdr_id;
		if(l_can_rel_id is null) then
			l_can_doc_type := 'PO';
			if(l_type_lookup_code = 'STANDARD') then
				l_can_doc_subtype := 'STANDARD';
			elsif(l_type_lookup_code = 'PLANNED') then
				l_can_doc_subtype := 'PLANNED';
			elsif(l_type_lookup_code = 'BLANKET') then
				l_can_doc_type := 'PA';
				l_can_doc_subtype := 'BLANKET';
			else
				l_can_doc_subtype := 'ERROR';
			end if;

		else
			l_can_doc_type := 'RELEASE';
			l_can_line_id := null;
			if(l_type_lookup_code = 'BLANKET') then
				l_can_doc_subtype := 'BLANKET';
			elsif(l_type_lookup_code = 'PLANNED') then
				l_can_doc_subtype := 'SCHEDULED';
			else
				l_can_doc_subtype := 'ERROR';
			end if;

		end if;

		Commit_CancelPO(
			l_return_status,
			l_can_doc_type,
			l_can_doc_subtype,
			l_can_hdr_id,
			l_can_rel_id,
			l_can_line_id,
			l_can_line_loc_id,
			l_can_reason,
            l_cancel_backing_req,
			l_launch_approvals_flag --bug 13114334
			);

		--If PO Cancel API fails, we'll assume buyer has rejected the cancellation request
		if(l_return_status <> 'S') then
			x_return_status := FND_API.G_RET_STS_ERROR;
			update po_change_requests
			set request_status = 'REJECTED',
			response_reason = l_ship_can_err_msg,
			validation_error = l_ship_can_err_msg
			-- change_active_flag = 'N'       /* commented out due to bug 3574114 */
			where change_request_id = l_can_req_id;
		end if;
	end loop;
	close l_cancel_ship_csr;
x_progress:='003';

--Calling PO Cancel API to process Header level Cancellation approved by the buyer.
	open l_cancel_hdr_csr(p_chg_req_grp_id);
	loop
	fetch l_cancel_hdr_csr into
		l_can_req_id,
		l_can_hdr_id,
		l_can_rel_id,
		l_can_reason,
		l_can_doc_type,
		l_cancel_backing_req;
	exit when l_cancel_hdr_csr%NOTFOUND;
		select type_lookup_code
		into l_type_lookup_code
		from po_headers_all
		where po_header_id = l_can_hdr_id;
		if(l_can_rel_id is null) then
			l_can_doc_type := 'PO';
			if(l_type_lookup_code = 'STANDARD') then
				l_can_doc_subtype := 'STANDARD';
			elsif(l_type_lookup_code = 'PLANNED') then
				l_can_doc_subtype := 'PLANNED';
			elsif(l_type_lookup_code = 'BLANKET') then
				l_can_doc_type := 'PA';
				l_can_doc_subtype := 'BLANKET';
			elsif(l_type_lookup_code = 'CONTRACT') then
				l_can_doc_type := 'PA';
				l_can_doc_subtype := 'CONTRACT';
			else
				l_can_doc_subtype := 'ERROR';
			end if;

		else
			l_can_doc_type := 'RELEASE';
			if(l_type_lookup_code = 'BLANKET') then
				l_can_doc_subtype := 'BLANKET';
			elsif(l_type_lookup_code = 'PLANNED') then
				l_can_doc_subtype := 'SCHEDULED';
			else
				l_can_doc_subtype := 'ERROR';
			end if;

		end if;

		Commit_CancelPO(
			l_return_status,
			l_can_doc_type,
			l_can_doc_subtype,
			l_can_hdr_id,
			l_can_rel_id,
			null,
			null,
			l_can_reason,
                        l_cancel_backing_req,
			'Y' --bug 13114334
			);

		--If PO Cancel API fails, we'll assume buyer has rejected the cancellation request
		if(l_return_status <> 'S') then
			x_return_status := FND_API.G_RET_STS_ERROR;
			update po_change_requests
			set request_status = 'REJECTED' ,
			response_reason = l_hdr_can_err_msg,
			validation_error = l_hdr_can_err_msg,
			change_active_flag = 'N'
			where change_request_id = l_can_req_id;
		end if;
	end loop;
	close l_cancel_hdr_csr;

exception when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
	END IF;
end CancelPO;

/*
*taken from PO_REQAPPROVAL_INIT1, because it had the procedure as a PRIVATE procedure
*This API is used by Register_rejection
*/
Procedure Insert_Acc_Rejection_Row(p_itemtype        in  varchar2,
                              	   p_itemkey         in  varchar2,
	                           p_actid           in  number,
				   p_flag		   in  varchar2)
is
	l_api_name varchar2(50) := 'Insert_Acc_Rejection_Row';
   l_Acceptance_id      number;
   --  Bug 2850566
   l_rowid              ROWID;
   l_Last_Update_Login  PO_ACCEPTANCES.last_update_login%TYPE;
   l_acc_po_header_id   PO_HEADERS_ALL.po_header_id%TYPE;
   -- End of Bug 2850566
   l_Last_Update_Date   date;
   l_Last_Updated_By    number;
   l_Creation_Date      date           	:=  TRUNC(SYSDATE);
   l_Created_By         number         	:=  fnd_global.user_id;
   l_Po_Header_Id       number;
   l_Po_Release_Id      number;
   l_Action             varchar2(240)	:= 'NEW';
   l_Action_Date        date    	:=  TRUNC(SYSDATE);
   l_Employee_Id        number;
   l_Revision_Num       number;
   l_Accepted_Flag      varchar2(1)	:= p_flag;
--   l_Acceptance_Lookup_Code varchar2(25);
   l_document_id	number;
   l_document_type_code po_document_types_all.DOCUMENT_TYPE_CODE%TYPE;
   l_acceptance_note	PO_ACCEPTANCES.note%TYPE;	--bug 2178922
   l_rspndr_usr_name    fnd_user.user_name%TYPE := '';
   l_accepting_party    varchar2(1);
begin

	SELECT po_acceptances_s.nextval into l_Acceptance_id FROM sys.dual;

-- commented out the usage of accptance_type (FPI)
/*
	l_Acceptance_Lookup_Code := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                   		       	       itemkey  => p_itemkey,
                            	 	               	       aname    => 'ACCEPTANCE_LOOKUP_CODE');
*/

	l_acceptance_note := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => p_itemtype,
                                   		       	itemkey  => p_itemkey,
                            	 	               	aname    => 'ACCEPTANCE_COMMENTS');

-- commented out the usage of accptance_type (FPI)
/*
	if (l_Acceptance_Lookup_Code is NULL) then
	   if p_flag = 'Y' then
		l_Acceptance_Lookup_Code := 'Accepted Terms';
	   else
		l_Acceptance_Lookup_Code := 'Unacceptable Changes';
	   end if;
        end if;
*/

	l_document_id := wf_engine.GetItemAttrNumber ( itemtype => p_itemtype,
                                   		       itemkey  => p_itemkey,
                            	 	               aname    => 'DOCUMENT_ID');

	l_document_type_code := wf_engine.GetItemAttrText   ( itemtype => p_itemtype,
                                   		       	      itemkey  => p_itemkey,
                            	 	               	      aname    => 'DOCUMENT_TYPE');

	-- abort any outstanding acceptance notifications for any previous revision of the document.

	if l_document_type_code <> 'RELEASE' then
		l_Po_Header_Id := l_document_id;

		select
			revision_num,
			agent_id
		into
			l_revision_num,
			l_employee_id
		from po_headers
		where po_header_id = l_document_id;
	else
		l_Po_Release_Id := l_document_id;

		select
			po_header_id,
			revision_num,
			agent_id
		into
			l_Po_Header_Id,
			l_revision_num,
			l_employee_id
		from po_releases
		where po_release_id = l_document_id;
	end if;

   --  Bug 2850566 RBAIRRAJ
   --  Calling the Acceptances row handler to insert into the PO_ACCEPTANCES table
   --  instead of writing an Insert statement.

   IF l_po_release_id IS NULL THEN
     l_acc_po_header_id := l_po_header_id;
   ELSE
     l_acc_po_header_id := NULL;
   END IF;

   l_rspndr_usr_name := wf_engine.GetItemAttrText   ( itemtype => p_itemtype,
                                      		       	      itemkey  => p_itemkey,
                               	 	               	      aname    => 'SUPPLIER_USER_NAME');

       begin
         select user_id into   l_Last_Updated_By
         from fnd_user
         where user_name = upper(l_rspndr_usr_name);
         l_accepting_party := 'S';
       exception when others then
         --in case of non-isp users there wont be any suppliers
         l_Last_Updated_By := l_Created_By;
         l_accepting_party := 'S';  --ack is always by the supplier.
       end;
    l_Last_Update_Login := l_Last_Updated_By;


    PO_ACCEPTANCES_INS_PVT.insert_row(
            x_rowid                 =>  l_rowid,
			x_acceptance_id			=>  l_Acceptance_id,
            x_Last_Update_Date      =>  l_Last_Update_Date,
            x_Last_Updated_By       =>  l_Last_Updated_By,
            x_Last_Update_Login     =>  l_Last_Update_Login,
			p_creation_date			=>  l_Creation_Date,
			p_created_by			=>  l_Last_Updated_By,
			p_po_header_id			=>  l_acc_po_header_id,
			p_po_release_id			=>  l_Po_Release_Id,
			p_action			    =>  l_Action,
			p_action_date			=>  l_Action_Date,
			p_employee_id			=>  NULL,
			p_revision_num			=>  l_Revision_Num,
			p_accepted_flag			=>  l_Accepted_Flag,
			p_note                  =>  l_acceptance_note,
			p_accepting_party        =>  l_accepting_party
			);

   --  End of Bug 2850566 RBAIRRAJ

   -- Reset the Acceptance required Flag
   --Bug 6772960 - Start
   --Update the last update date when po_headers_all/po_releases_all tables are updated.
   if l_po_release_id is not null then
      update po_releases
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_release_id = l_po_release_id;
   else
      update po_headers
      set acceptance_required_flag = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      acceptance_due_date = ''
      where po_header_id = l_po_header_id;
   end if;
   --Bug 6772960 - End

exception
	when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
	END IF;
	raise;
end;

/*
*taken from PO_REQAPPROVAL_INIT1
*PO_REQAPPROVAL_INIT1.Register_rejection will be updated to support older version of poxwfpoa.wft
*In other words, initial version of poxwfpoa.wft only calls PO_REQ_APPROVAL_INIT1.Register_rejection.
*New version will call PO_ChangeOrderWF_PVT.IS_PO_HDR_REJECTED followed by PO_ChangeOrderWF_PVT.Register_rejection.
*In order for older version of workflow to have the new functionality, PO_REQ_APPROVAL_INIT1.Register_rejection will
*need to include the logic of PO_ChangeOrderWF_PVT.IS_PO_HDR_REJECTED within.
*/
procedure  Register_rejection   (  itemtype        in  varchar2,
                              	   itemkey         in  varchar2,
		                           actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
		l_api_name varchar2(50):= 'Register_rejection';
		l_progress              varchar2(3) := '000';
		l_acceptance_result	varchar2(30);
		l_org_id		number;
        l_document_id           number;
        l_document_type_code    po_document_types_all.DOCUMENT_TYPE_CODE%TYPE;
        l_vendor po_vendors.vendor_name%TYPE;
		--l_accp_type		varchar2(100);
        x_supp_user_name        varchar2(100);
        x_supplier_displayname  varchar2(100);
	l_nid                   number;
        l_ntf_role_name         varchar2(320);
begin

  -- set the org context
  l_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	    itemkey  => itemkey,
                            	 	    aname    => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

  fnd_message.set_name ('PO','PO_WF_REJECTED_VALUE');
  l_acceptance_result := fnd_message.get;

  l_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  l_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');

	-- commented out the usage of accptance_type (FPI)
	/*
  l_accp_type := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               	itemkey  => itemkey,
                                               	aname    => 'ACCEPTANCE_TYPE');
*/

  l_acceptance_result := PO_WF_UTIL_PKG.GetItemAttrText(itemtype => itemtype,
                                               		itemkey  => itemkey,
                                               		aname    => 'ACCEPTANCE_RESULT');

if l_document_type_code <> 'RELEASE' then
        select pov.vendor_name
        into l_vendor
        from
        	po_vendors pov,
        	po_headers poh
        where pov.vendor_id = poh.vendor_id
        and poh.po_header_id=l_document_id;
else
        select pov.vendor_name
        into l_vendor
        from
        	po_releases por,
        	po_headers_all poh,   -- <R12 MOAC>
        	po_vendors pov
        where por.po_release_id = l_document_id
        and por.po_header_id    = poh.po_header_id
        and poh.vendor_id       = pov.vendor_id;
end if;



  PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'SUPPLIER',
                                   avalue   => l_vendor);

-- commented out the usage of accptance_type (FPI)
/*
   IF (l_accp_type is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                                   	itemkey  => itemkey,
                                   	aname    => 'ACCEPTANCE_TYPE',
                                   	avalue   => 'Rejected' );
   END IF;
*/

   IF (l_acceptance_result is NULL) THEN
      PO_WF_UTIL_PKG.SetItemAttrText  (	itemtype => itemtype,
                              		itemkey  => itemkey,
                              		aname    => 'ACCEPTANCE_RESULT',
                              		avalue   => fnd_message.get_string('PO','PO_WF_NOTIF_REJ') );
   END IF;

   if (l_document_type_code <> 'RELEASE') then

           --dbms_output.put_line('For std pos');
          begin
           select a.notification_id, a.recipient_role
           INTO   l_nid, l_ntf_role_name
           from   wf_notifications a,
                  wf_item_activity_statuses wa
           where  itemkey=wa.item_key
           and    itemtype=wa.item_type
           and    a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and    a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
          end;

          else
          begin
           --dbms_output.put_line('For Releases');
           select a.notification_id, a.recipient_role
           INTO  l_nid, l_ntf_role_name
           from  wf_notifications a,
                 wf_item_activity_statuses wa
           where itemkey=wa.item_key
           and   itemtype=wa.item_type
           and   a.message_name in ('PO_EMAIL_PO_WITH_RESPONSE', 'PO_EMAIL_PO_PDF_WITH_RESPONSE')
           and   a.notification_id=wa.notification_id and a.status = 'CLOSED';
          exception
           when others then l_nid := null;
         end;
       end if;

       if (l_nid is null) then
         --we do not want to continue if the notification is not closed.
         return;
       else
        x_supp_user_name := wf_notification.responder(l_nid);
       end if;

     if (substr(x_supp_user_name, 1, 6) = 'email:') then
        --Get the username and store that in the supplier_user_name.
        x_supp_user_name := PO_ChangeOrderWF_PVT.getEmailResponderUserName
                                      (x_supp_user_name, l_ntf_role_name);


     end if;
      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'SUPPLIER_USER_NAME',
                                   avalue   => x_supp_user_name);



  Insert_Acc_Rejection_Row(itemtype, itemkey, actid, 'N');

EXCEPTION
  WHEN OTHERS THEN
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
	END IF;
    	wf_core.context('PO_ChangeOrderWF_PVT','Register_rejection',l_progress);
    	raise;
end;

/*
*Kicks of POAPPRV workflow for supplier change or for requester change.
*/
procedure KickOffPOApproval( 		p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									x_return_msg out NOCOPY varchar2)
IS
l_api_name varchar2(50) := 'KickOffPOApproval';
l_org_id number;
l_agent_id number;
l_document_id number;
l_document_num po_headers_all.segment1%TYPE;
l_document_type_code po_document_types_all.DOCUMENT_TYPE_CODE%TYPE;
l_document_subtype po_document_types_all.DOCUMENT_SUBTYPE%TYPE;
l_seq number;
l_item_key po_headers_all.wf_item_key%TYPE;
l_item_type po_headers_all.wf_item_type%TYPE;
l_workflow_process PO_DOCUMENT_TYPES_V.WF_APPROVAL_PROCESS%TYPE;

/* Bug 2810156 BEGIN*/
l_orig_itemtype		po_headers.wf_item_type%TYPE;
l_orig_itemkey	       	po_headers.wf_item_key%TYPE;
l_user_id		number;
l_resp_id		number;
l_appl_id		number;
/* Bug 2810156 END */

/* BUG 5228026: Added the l_CommunicatePriceChange variable */
 l_CommunicatePriceChange varchar2(1) := 'N';

--<BUG 7688032 START>
l_email_address   po_vendor_sites_all.email_address%TYPE;
l_email_flag      VARCHAR2(1)    := 'N';
l_fax_flag        VARCHAR2(1)    := 'N';
l_faxnum          po_vendor_contacts.fax%TYPE;
l_fax_area        po_vendor_sites_all.fax_area_code%TYPE;
l_preparer_id     NUMBER;
l_default_method  po_vendor_sites_all.supplier_notif_method%TYPE;
l_doc_num         po_headers_all.segment1%TYPE;
l_print_flag      VARCHAR2(1)    := 'N';
--<BUG 7688032 END>

BEGIN

	if p_release_id is not null then
		-- shipment for a release
		l_document_id := p_release_id;
		select 	por.release_type,
			por.org_id ,
			poh.segment1,
			por.agent_id
		into   	l_Document_SubType,
			l_org_id,
			l_document_num,
			l_agent_id
		from po_releases_all por,
                     po_headers_all  poh
		where po_release_id = p_release_id
                and  por.po_header_id=poh.po_header_id;

		l_Document_Type_Code := 'RELEASE';

	else
		l_document_id := p_header_id;
		select
			poh.segment1,
			poh.agent_id,
			poh.type_lookup_code,
			poh.org_id
		into
			l_document_num,
			l_agent_id,
			l_document_subtype,
			l_org_id
		from po_headers_all poh
		where
		     poh.po_header_id = p_header_id;

		if l_Document_SubType in ('BLANKET', 'CONTRACT') then
			l_Document_Type_Code := 'PA';
		else
			l_Document_Type_Code := 'PO';
		end if;
	end if;

	x_return_msg:='001';

       	/* Bug 2810156 BEGIN
           Call apps_initialze using IDs stored in the original PO approval workflow.
       	*/

        BEGIN
	  if (NVL(l_Document_Type_Code, 'PO') <> 'RELEASE') then
             select wf_item_type, wf_item_key
             into   l_orig_itemtype, l_orig_itemkey
             from   po_headers_all
             where  po_header_id = l_document_id;
          else
             select wf_item_type, wf_item_key
             into   l_orig_itemtype, l_orig_itemkey
             from   po_releases_all
             where  po_release_id = l_document_id;
	  end if;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    l_orig_itemtype := null;
	    l_orig_itemkey  := null;
        END;

        if (l_orig_itemtype is not null and l_orig_itemkey is not null) then

  	  l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => l_orig_itemtype,
                                         	   itemkey  => l_orig_itemkey,
                                         	   aname    => 'USER_ID');

  	  l_resp_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => l_orig_itemtype,
                                         	   itemkey  => l_orig_itemkey,
                                         	   aname    => 'RESPONSIBILITY_ID');

  	  l_appl_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => l_orig_itemtype,
                                         	   itemkey  => l_orig_itemkey,
                                         	   aname    => 'APPLICATION_ID');

  	   if (l_user_id is not null and
      	      l_resp_id is not null and
      	      l_appl_id is not null )then

      	    fnd_global.APPS_INITIALIZE(l_user_id, l_resp_id, l_appl_id);

         else

           	initialize (l_agent_id, l_org_id);

  	   end if;

        end if;

	x_return_msg:='002';

	if (l_org_id is NOT NULL) then
          PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>
	end if;

       	/* Bug 2810156 END */


	x_return_msg:='003';

	select
		wf_approval_itemtype,
		wf_approval_process
	into
		l_Item_Type,
		l_Workflow_Process
	from PO_DOCUMENT_TYPES_V
	where DOCUMENT_TYPE_CODE = l_Document_Type_Code
	and DOCUMENT_SUBTYPE =  l_Document_Subtype;

    select to_char(PO_WF_ITEMKEY_S.NEXTVAL) into l_seq from sys.dual;
    l_Item_Key := to_char(l_Document_ID) || '-' || l_seq;



x_return_msg:='004';
IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
			l_api_name || '.start_wf_process', l_Item_Type||'*'||l_Item_Key);
END IF;

--<BUG 7688032 START>
--Added the following code to fetch the default transmission
--method of the supplier and setting the corresponding flags accordingly.
PO_VENDOR_SITES_SV.Get_Transmission_Defaults(p_document_id => l_document_id,
                                             p_document_type => l_Document_Type_Code,
                                             p_document_subtype => l_document_subtype,
                                             p_preparer_id => l_preparer_id,
                                             x_default_method => l_default_method,
                                             x_email_address => l_email_address,
                                             x_fax_number => l_faxnum,
                                             x_document_num => l_doc_num );

IF (l_default_method = 'EMAIL' ) AND (l_email_address IS NOT NULL) THEN
	l_email_flag := 'Y';
ELSIF (l_default_method  = 'FAX')  AND (l_faxnum IS NOT NULL) THEN
        l_email_address := NULL;
        l_faxnum := l_fax_area || l_faxnum;
        l_fax_flag := 'Y';
ELSIF  l_default_method  = 'PRINT' THEN
        l_email_address := NULL;
        l_faxnum := NULL;
        l_print_flag := 'Y';
ELSE
        l_email_address := null;
        l_faxnum := null;
END IF;
--<BUG 7688032 END>

IF( (l_Document_Type_Code = 'RELEASE' AND l_Document_Subtype = 'BLANKET') OR (l_Document_Type_Code = 'PO' AND l_Document_Subtype = 'STANDARD') ) THEN
        l_CommunicatePriceChange := 'Y';
END IF;
	--<BUG 7688032 Passing the transmission flags to the Start_WF_Process
	--so that the change request flow transmit the changes done to the PO
	--to the supplier in their default transmission method.
	PO_REQAPPROVAL_INIT1.Start_WF_Process(
							ItemType => l_Item_Type,
							ItemKey => l_Item_Key,
							WorkflowProcess => l_workflow_process,
							ActionOriginatedFrom => 'POS_SUP_CHN',
							DocumentID => l_document_id,
							DocumentNumber => l_document_num,
							preparerid => l_agent_id,
							DocumentTypeCode => l_Document_Type_Code,
			  				DocumentSubtype => l_Document_Subtype,
			  				SubmitterAction => 'APPROVE',
			  				forwardToID => null,
			  				forwardFromID => null,
			  				DefaultApprovalPathID => null,
							Note => '',
							printFlag => l_print_flag,
							FaxFlag => l_fax_flag,
							FaxNumber => l_faxnum,
							EmailFlag => l_email_flag,
							EmailAddress => l_email_address,
                                                        CommunicatePriceChange => l_CommunicatePriceChange);
x_return_msg:='005';
	x_return_status := FND_API.G_RET_STS_SUCCESS;
exception when others then
	x_return_msg:='KO_U'||x_return_msg||sqlerrm;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', x_return_msg);
	END IF;

END KickOffPOApproval;


/*
*Called from POAPPRV workflow, to execute IsPOHeaderRejected
*/
procedure IS_PO_HDR_REJECTED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type_code    po_document_types_all.DOCUMENT_TYPE_CODE%TYPE;
l_revision_num number;
x_progress varchar2(3) := '000';
l_return_status varchar2(1);
BEGIN
  	l_document_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOCUMENT_ID');

  	l_document_type_code := wf_engine.GetItemAttrText   ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'DOCUMENT_TYPE');
	x_progress := '001';
    if (l_document_type_code <> 'RELEASE') then
		select revision_num
		into l_revision_num
		from po_headers_all
		where po_header_id = l_document_id;
		IsPOHeaderRejected(
							1.0,
							l_return_status,
							l_document_id,
							null,
							l_revision_num,
							resultout);
	else
		select revision_num
		into l_revision_num
		from po_releases_all
		where po_release_id = l_document_id;
		IsPOHeaderRejected(
							1.0,
							l_return_status,
							null,
							l_document_id,
							l_revision_num,
							resultout);
	end if;
exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','IS_PO_HDR_REJECTED',x_progress);
    raise;
END IS_PO_HDR_REJECTED;

/*
*Checks if Supplier has rejected the PO (which requires acknowledgement) at the Header Level.
*Explaination: When a PO (which requires ACK) is created, it holds at the node which awaits supplier to respond.
*If supplier rejects the header level via notification or UI, this node will be awaken, and this API shall return "Y".
*On the other hand, supplier could respond to the PO at the shipment level, and this node will be awaken with
*action = "REJECT", even though there is no rejection. Thus this API will return "N".
*/
procedure IsPOHeaderRejected(			p_api_version in number,
										x_return_status out NOCOPY varchar2,
										p_header_id in number,
										p_release_id in number,
										p_revision_num in number,
										x_result_code out NOCOPY varchar)
IS
l_id number;

cursor l_header_csr(hdr_id number, rev_num number) is
select change_request_id
from po_change_requests
where document_header_id = hdr_id
and document_revision_num = rev_num
and request_status = 'PENDING'
and initiator = 'SUPPLIER'
union all
select acceptance_id
from po_acceptances
where po_header_id = hdr_id
and revision_num = rev_num
and po_line_location_id is not null;

cursor l_release_csr(rel_id number,rev_num number) is
select change_request_id
from po_change_requests
where po_release_id = rel_id
and document_revision_num = rev_num
and request_status = 'PENDING'
and initiator = 'SUPPLIER'
union all
select acceptance_id
from po_acceptances
where po_release_id = rel_id
and revision_num = rev_num
and po_line_location_id is not null;

BEGIN
	x_result_code := 'Y';
	-- If any Pending records exist in PO_CHANGE_REQUESTS table, that means the PO is not really header rejected
	if(p_header_id is not null) then
		open l_header_csr(p_header_id, p_revision_num);
		fetch l_header_csr into l_id;
		close l_header_csr;
		if(l_id is not null) then
			x_result_code := 'N';
		end if;
	else
		open l_release_csr(p_release_id, p_revision_num);
		fetch l_release_csr into l_id;
		close l_release_csr;
		if(l_id is not null) then
			x_result_code := 'N';
		end if;
	end if;
exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','IsPOHeaderRejected','000');
    raise;
END IsPOHeaderRejected;

PROCEDURE GEN_NTF_FOR_REQ_SUP_CHN( 	p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2)
IS
l_header_id number;
l_release_id number;
l_grp_id number;
l_requester_id number;
l_api_name varchar2(50) := 'GEN_NTF_FOR_REQ_SUP_CHN';

l_progress varchar2(5) := '000';

l_rel_total number;
l_rel_currency po_headers.currency_code%TYPE;
--l_blanket_num number;
l_blanket_num po_headers_all.segment1%TYPE;
--l_release_num number;
l_release_num po_releases_all.release_num%TYPE;
l_po_doc_id number;
l_rel_doc_id number;
l_acc_req_flag varchar2(1);
l_document varchar2(32000);
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_document_type varchar2(2000);
l_po_num po_headers_all.segment1%TYPE;
l_revision_num number;
l_po_total number;
l_po_currency po_headers.currency_code%TYPE;
l_vendor_id number;
l_vendor_site_id number;
l_supplier_name po_vendors.vendor_name%TYPE;
l_sup_address_line1 po_vendor_sites_all.address_line1%TYPE;
l_sup_address_line2 po_vendor_sites_all.address_line2%TYPE;
l_sup_address_line3 po_vendor_sites_all.address_line3%TYPE;
l_sup_city	po_vendor_sites_all.city%TYPE;
l_sup_state po_vendor_sites_all.state%TYPE;
l_sup_zip po_vendor_sites_all.zip%TYPE;
l_order_date varchar2(2000);
l_fob po_headers_all.fob_lookup_code%TYPE;
l_carrier po_headers_all.ship_via_lookup_code%TYPE;
l_ship_to_id number;
l_ship_addr_l1 hr_locations_all.address_line_1%TYPE;
l_ship_addr_l2 hr_locations_all.address_line_2%TYPE;
l_ship_addr_l3 hr_locations_all.address_line_3%TYPE;
l_ship_city hr_locations_all.town_or_city%TYPE;
l_ship_state hr_locations_all.region_1%TYPE;
l_ship_zip hr_locations_all.postal_code%TYPE;
l_base_url varchar2(2000);
l_base_url_tag varchar2(2000);

l_document1 VARCHAR2(32000) := '';

/*varchar Variables for creating the notification*/
lc_line_num 		varchar2(2000);
lc_ship_num 		varchar2(2000);
lc_buyer_pt_num 	mtl_system_items_kfv.concatenated_segments%TYPE;
lc_old_sup_pt_num 	po_lines_all.vendor_product_num%TYPE;
lc_new_sup_pt_num 	po_change_requests.new_supplier_part_number%TYPE;
lc_old_prom_date	varchar2(2000);
lc_new_prom_date	varchar2(2000);
lc_old_qty 			varchar2(2000);
lc_new_qty 			varchar2(2000);
lc_old_price 		varchar2(2000);
lc_new_price 		varchar2(2000);
lc_action_type 		varchar2(2000);
lc_item_desc 		po_lines_all.item_description%TYPE;
lc_uom 				po_lines_all.unit_meas_lookup_code%TYPE;
lc_ship_to_location hr_locations_all.location_code%TYPE;
lc_action_code 		po_change_requests.ACTION_TYPE%TYPE;
lc_reason			po_change_requests.request_reason%TYPE;
lc_split			varchar2(2000);
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
/*Modified as part of bug 7550964 changing date format*/
cursor l_po_chg_req_csr(grp_id number, l_requestor_id number) is
select
	to_char(LINE_NUM),
	to_char(SHIPMENT_NUM),
	BUYER_PT_NUM,
	OLD_SUP_PT_NUM,
	NEW_SUP_PT_NUM,
	to_char(OLD_PROM_DATE,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                             'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
	to_char(NEW_PROM_DATE, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                             'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
	to_char(OLD_QTY),
	to_char(NEW_QTY),
	to_char(OLD_PRICE),
	to_char(NEW_PRICE),
	ACTION_TYPE,
	ITEM_DESCRIPTION,
	UOM,
	SHIP_TO_LOCATION,
	ACTION_CODE,
	REASON,
	SPLIT
from(

-- LINE CHANGES for Standard PO
select
	pcr.document_line_number LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	pcr.new_supplier_part_number NEW_SUP_PT_NUM,
	to_date(null,'DD/MM/YYYY') OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	pla.quantity OLD_QTY,
	to_number(null) NEW_QTY,
	pla.unit_price		OLD_PRICE,
	pcr.new_price		NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),
						'CANCELLATION',fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	pla.unit_meas_lookup_code	UOM,
	null SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.request_reason REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pla.po_line_id = pcr.document_line_id
and pcr.change_request_group_id =grp_id
and pcr.request_level = 'LINE'
and pcr.request_status in ('PENDING','REQ_APP')
and pla.latest_external_flag = 'Y'
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
and exists (select 1 from po_distributions_all
			where po_line_id = pcr.document_line_id
			and deliver_to_person_id = l_requestor_id)
UNION ALL

-- SHIPMENT CHANGES for Standard PO and Releases
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(pcr.old_promised_date, nvl(plla.promised_date,plla.need_by_date))	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	decode(pla.matching_basis,'AMOUNT',DECODE(plla.payment_type,'RATE',nvl(pcr.old_price,plla.price_override),nvl(pcr.old_amount,plla.amount)),nvl(pcr.old_price,plla.price_override))      OLD_PRICE,
        decode(pla.matching_basis,'AMOUNT',DECODE(plla.payment_type,'RATE',pcr.new_price,pcr.new_amount),pcr.new_price) NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.document_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status in ('PENDING','REQ_APP')
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
and exists (select 1 from po_distributions_all
			where line_location_id = pcr.document_line_location_id
			and deliver_to_person_id = l_requestor_id)
UNION ALL

--SPLIT SHIPMENTS
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(pcr.old_promised_date, nvl(plla.promised_date,plla.need_by_date))	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	decode(pla.matching_basis,'AMOUNT',DECODE(nvl(pcr.new_progress_type,plla.payment_type),'RATE',nvl(pcr.new_price,plla.price_override),nvl(pcr.old_amount,plla.amount)),nvl(pcr.old_price,plla.price_override))      OLD_PRICE,
        decode(pla.matching_basis,'AMOUNT',DECODE(nvl(pcr.new_progress_type,plla.payment_type),'RATE',pcr.new_price,pcr.new_amount),pcr.new_price) NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	fnd_message.get_string('PO','PO_WF_NOTIF_YES') SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.parent_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status in ('PENDING','REQ_APP')
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
and exists (select 1 from po_distributions_all
			where line_location_id = pcr.parent_line_location_id
			and deliver_to_person_id = l_requestor_id)
)
order by LINE_NUM,nvl(SHIPMENT_NUM,0);

l_id number;
l_header_response po_change_requests.request_status%type;
l_header_cancel varchar2(1);
cursor l_header_cancel_csr(grp_id number) is
select change_request_id,
	request_status
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'HEADER';

l_additional_changes po_change_requests.additional_changes%type;

cursor l_header_changes_csr(grp_id number)
is
select additional_changes
from po_change_requests
where change_request_group_id = grp_id
and request_level = 'HEADER'
and additional_changes is not null;

BEGIN
	l_header_id := 	to_number(substr(p_code,2,						instr(p_code,'#')-instr(p_code,'@')-1));
	l_release_id := to_number(substr(p_code,instr(p_code,'#')+1,	instr(p_code,'$')-instr(p_code,'#')-1));
	l_grp_id := 	to_number(substr(p_code,instr(p_code,'$')+1,	instr(p_code,'%')-instr(p_code,'$')-1));
	l_requester_id := 		  substr(p_code,instr(p_code,'%')+1,	instr(p_code,'^')-instr(p_code,'%')-1);

	l_progress := '001';
	l_base_url := fnd_profile.value('APPS_WEB_AGENT');
	l_base_url := substr(
							l_base_url,
							0,
							instr(rtrim(l_base_url,'/'),'/',-1,2)-1
						);
	l_base_url_tag := '<base href= "'||l_base_url||'">';
	l_progress := '001a';

	l_header_cancel := 'N';
	if(l_grp_id is not null) then
		open l_header_cancel_csr(l_grp_id);
		fetch l_header_cancel_csr
		into l_id,
			l_header_response;
		close l_header_cancel_csr;
		if(l_id is not null) then
			l_header_cancel := 'Y';
		end if;
	end if;

	if(l_release_id is null) then
                                                   /*Modified as part of bug 7550964 changing date format*/
		select 	segment1,
				revision_num,
				pos_totals_po_sv.get_po_total(po_header_id),
				currency_code,
				vendor_id,
				vendor_site_id,
				to_char(creation_date, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                        'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) , 'GREGORIAN' ) || ''''),
				fob_lookup_code,
				ship_via_lookup_code,
				ship_to_location_id,
				type_lookup_code,
				GLOBAL_AGREEMENT_FLAG
		into
				l_po_num,
				l_revision_num,
				l_po_total,
				l_po_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code,
				l_global_agreement_flag
		from po_headers_all
		where po_header_id = l_header_id;

		if(l_type_lookup_code = 'STANDARD') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO');
		elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
 	                l_document_type := fnd_message.get_string('PO','PO_GA_TYPE');
		elsif(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET');
		elsif(l_type_lookup_code = 'CONTRACT') then
			l_document_type := fnd_message.get_string('PO','PO_POTYPE_CNTR');
		else
			l_document_type := 'Error';
		end if;

	else
                                                   /*Modified as part of bug 7550964 changing date format*/
		select
				ph.segment1,
				pr.release_num,
				pr.revision_num,
				pos_totals_po_sv.get_release_total(pr.po_release_id),
				ph.currency_code,
				ph.vendor_id,
				ph.vendor_site_id,
				to_char(pr.creation_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                        'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
				ph.fob_lookup_code,
				ph.ship_via_lookup_code,
				ph.ship_to_location_id,
				ph.type_lookup_code
		into
				l_blanket_num,
				l_release_num,
				l_revision_num,
				l_rel_total,
				l_rel_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code
		from po_releases_all pr,
				po_headers_all ph
		where pr.po_release_id = l_release_id
		and pr.po_header_id = ph.po_header_id;

		if(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL');
		else
			l_document_type := 'Error';
		end if;

	end if;
	l_progress := '002';
	select
		vendor_name
	into
		l_supplier_name
	from po_vendors
	where vendor_id = l_vendor_id;

	select
		address_line1,
		address_line2,
		address_line3,
		city,
		state,
		zip
	into
		l_sup_address_line1,
		l_sup_address_line2,
		l_sup_address_line3,
		l_sup_city,
		l_sup_state,
		l_sup_zip
	from po_vendor_sites_all
	where vendor_site_id = l_vendor_site_id;

      /*  Shipto  */
	select
		address_line_1,
		address_line_2,
		address_line_3,
		town_or_city,
		region_1,
		postal_code
	into
		l_ship_addr_l1,
		l_ship_addr_l2,
		l_ship_addr_l3,
		l_ship_city,
		l_ship_state,
		l_ship_zip
	from hr_locations_all
	where location_id = l_ship_to_id;
	l_progress := '003';

if(l_release_id is null) then
	l_document :=	l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_po_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')
		||' '||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_po_currency||') '||
		TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>';
else
	l_document :=	l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_blanket_num||'-'||l_release_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
		||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_po_currency||') '||
		TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>';
end if;

l_document := l_document||'
<TABLE  cellpadding=2 cellspacing=1>
<TR>
<TD>
<TABLE cellpadding=2 cellspacing=1>
<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||'</B></font></TD>
<TD nowrap><font color=black>'||l_supplier_name||'</font></TD>
</TR>
<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||'</B></font></TD>
<TD nowrap><font color=black>';

if(l_sup_address_line1 is not null) then
	l_document := l_document || l_sup_address_line1||'<BR>';
end if;
if(l_sup_address_line2 is not null) then
	l_document := l_document || l_sup_address_line2||'<BR>';
end if;
if(l_sup_address_line3 is not null) then
	l_document := l_document || l_sup_address_line3||'<BR>';
end if;

l_document := l_document||l_sup_city||', '||l_sup_state||' '||l_sup_zip||
                      '</font></TD>
</TR>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_fob||
    '</font></TD>
</TR>


<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||'</B></font></TD>
<TD nowrap><font color=black>'||l_carrier||
                      '</font></TD>
</TR>
</TABLE>
</TD>
<TD valign=TOP>
<TABLE cellpadding=2 cellspacing=1>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_order_date||
    '</font></TD>
</TR>

<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||'</B></font></TD>
<TD nowrap><font color=black>
						'||
						l_ship_addr_l1||' '||l_ship_addr_l2||' '||l_ship_addr_l3||'<BR>'||
						l_ship_city||', '||l_ship_state||' '||l_ship_zip
						||'
						</font></TD>
</TR>

</TABLE>
</TD>
</TABLE></P>';
WF_NOTIFICATION.WriteToClob(document,l_document);


lc_line_num := null;
if(l_header_cancel = 'N') then
	open l_po_chg_req_csr(l_grp_id,l_requester_id);
	fetch l_po_chg_req_csr
	into
		lc_line_num,
		lc_ship_num,
		lc_buyer_pt_num,
		lc_old_sup_pt_num,
		lc_new_sup_pt_num,
		lc_old_prom_date,
		lc_new_prom_date,
		lc_old_qty,
		lc_new_qty,
		lc_old_price,
		lc_new_price,
		lc_action_type,
		lc_item_desc,
		lc_uom,
		lc_ship_to_location,
		lc_action_code,
		lc_reason,
		lc_split;
	close l_po_chg_req_csr;
	if(lc_line_num is not null) then
		l_document := '<font size=3 color=#336699 face=arial><b>'||
					fnd_message.get_string('PO', 'PO_WF_NOTIF_CH_CA_REQ')||
					'</B></font><HR size=1 color=#cccc99>';
		l_document := l_document||'<TABLE><TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '<TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/cancelind_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL_PENDING');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '</TABLE>' || NL;
		l_document := l_document ||'
		<TABLE WIDTH=100% cellpadding=2 cellspacing=1>
		<TR bgcolor=#cccc99>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_LINE_NUMBER')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPMENT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SUP_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_DOC_DESCRIPTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_UNIT')||'</font></TH>';
		if (l_type_lookup_code = 'BLANKET') then
		    l_document := l_document || ' <TH align=left><font color=#336699 >'||fnd_message.get_string('PO','POS_PRICE_BREAK')||'</font></TH>';
		 else
		   l_document := l_document || ' <TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PRICE')||'</font></TH> ';
		end if;
		l_document := l_document ||
		'<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_QTY_ORDERED')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PROM_DATE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPTO')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ACTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_REASON')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SPLIT')||'</font></TH>
		</TR>
		</B>';

		WF_NOTIFICATION.WriteToClob(document,l_document);

		open l_po_chg_req_csr(l_grp_id,l_requester_id);
		loop
		fetch l_po_chg_req_csr
		into
			lc_line_num,
			lc_ship_num,
			lc_buyer_pt_num,
			lc_old_sup_pt_num,
			lc_new_sup_pt_num,
			lc_old_prom_date,
			lc_new_prom_date,
			lc_old_qty,
			lc_new_qty,
			lc_old_price,
			lc_new_price,
			lc_action_type,
			lc_item_desc,
			lc_uom,
			lc_ship_to_location,
			lc_action_code,
			lc_reason,
			lc_split;
		EXIT when l_po_chg_req_csr%NOTFOUND;

		if(lc_split is not null) then
			lc_old_sup_pt_num := nvl(lc_old_sup_pt_num,lc_new_sup_pt_num);
			lc_new_sup_pt_num := null;

			lc_old_price:=nvl(lc_old_price,lc_new_price);
			lc_new_price:= null;

			lc_new_prom_date:= nvl(lc_new_prom_date,lc_old_prom_date);
			lc_old_prom_date:= null;

			lc_new_qty:=nvl(lc_new_qty,lc_old_qty);
			lc_old_qty:= null;
		end if;

		lc_line_num := nvl(lc_line_num,'`&nbsp');
		lc_ship_num:= nvl(lc_ship_num,'`&nbsp');
		lc_buyer_pt_num:= nvl(lc_buyer_pt_num,'`&nbsp');

		lc_old_sup_pt_num:= nvl(lc_old_sup_pt_num,'`&nbsp');
		lc_new_sup_pt_num:= nvl(lc_new_sup_pt_num,'`&nbsp');

		lc_old_prom_date:= nvl(lc_old_prom_date,'`&nbsp');
		lc_new_prom_date:= nvl(lc_new_prom_date,'`&nbsp');

		lc_old_qty:= nvl(lc_old_qty,'`&nbsp');
		lc_new_qty:= nvl(lc_new_qty,'`&nbsp');

		lc_old_price:= nvl(lc_old_price,'`&nbsp');
		lc_new_price:= nvl(lc_new_price,'`&nbsp');

		lc_action_type:= nvl(lc_action_type,'`&nbsp');
		lc_item_desc:= nvl(lc_item_desc,'`&nbsp');
		lc_uom:= nvl(lc_uom,'`&nbsp');
		lc_ship_to_location:= nvl(lc_ship_to_location,'`&nbsp');
		lc_reason := nvl(lc_reason,'`&nbsp');
		lc_split := nvl(lc_split,'`&nbsp');


		l_document := '
		        <TR bgcolor=#f7f7e7>

		        <TD align=left><font color=black>'||lc_line_num||
		                      '</font></TD> ';

		if(lc_action_code = 'CANCELLATION') then
			l_document := l_document ||'
			        <TD align=left><font color=black>
			        	<TABLE>
			        		<TR>
			        			<TD>
				        			<img src=/OA_MEDIA/cancelind_status.gif ALT="">
			        			</TD>
			        			<TD alight=right>'
				        			||lc_ship_num||
			        			'</TD>
			        		</TR>
			        	</TABLE>
			        </font></TD> ';
		else
			l_document := l_document ||'
			        <TD align=left><font color=black>'||lc_ship_num||
		    	                  '</font></TD> ';
		end if;
		l_document := l_document ||'
			<TD align=left><font color=black>'||lc_buyer_pt_num||
	                                  '</font></TD> ';

		    if(lc_new_sup_pt_num = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_sup_pt_num||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_sup_pt_num||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_sup_pt_num||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

			l_document := l_document || '
		        <TD align=left><font color=black>'||lc_item_desc||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_uom||
		                      '</font></TD> ';

		    if(lc_new_price = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_price||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_price||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_price||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(lc_new_qty = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_qty||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_qty||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		     if(lc_new_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_prom_date||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_prom_date||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;
			l_document := l_document || '

		        <TD align=left><font color=black>'||lc_ship_to_location||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_action_type||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_reason||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_split||
		                      '</font></TD>

		        </TR>
			';
			WF_NOTIFICATION.WriteToClob(document,l_document);

		END LOOP;
		CLOSE l_po_chg_req_csr;
		WF_NOTIFICATION.WriteToClob(document, '
		</TABLE></P>
		');


	end if;
	open l_header_changes_csr(l_grp_id);
	fetch l_header_changes_csr into l_additional_changes;
	close l_header_changes_csr;

	if(l_additional_changes is not null) then
		l_document := '<BR><B>'||fnd_message.get_string('PO','PO_WF_NOTIF_ADD_CHN_REQ')||'</B>'||
                ' `&nbsp '||l_additional_changes||'<BR>';
		WF_NOTIFICATION.WriteToClob(document,l_document);
	end if;

else
	fnd_message.set_name('PO','PO_WF_NOTIF_CAN_ENTIER');
	fnd_message.set_token('DOC',l_document_type);
	l_document := fnd_message.get;
	WF_NOTIFICATION.WriteToClob(document,l_document);
end if;
exception when others then
	WF_NOTIFICATION.WriteToClob(document,'Exception occured:'||sqlerrm);
END GEN_NTF_FOR_REQ_SUP_CHN;


PROCEDURE GEN_NTF_FOR_PLAN_SUP_CHN( 	p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2)
IS
l_header_id number;
l_release_id number;
l_grp_id number;
l_planner_id number;
l_api_name varchar2(50) := 'GEN_NTF_FOR_PLAN_SUP_CHN';

l_progress varchar2(5) := '000';

l_rel_total number;
l_rel_currency po_headers.currency_code%TYPE;
--l_blanket_num number;
l_blanket_num po_headers_all.segment1%TYPE;
--l_release_num number;
l_release_num po_releases_all.release_num%TYPE;
l_po_doc_id number;
l_rel_doc_id number;
l_acc_req_flag varchar2(1);
l_document varchar2(32000);
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_document_type varchar2(2000);
l_po_num po_headers_all.segment1%TYPE;
l_revision_num number;
l_po_total number;
l_po_currency po_headers.currency_code%TYPE;
l_vendor_id number;
l_vendor_site_id number;
l_supplier_name po_vendors.vendor_name%TYPE;
l_sup_address_line1 po_vendor_sites_all.address_line1%TYPE;
l_sup_address_line2 po_vendor_sites_all.address_line2%TYPE;
l_sup_address_line3 po_vendor_sites_all.address_line3%TYPE;
l_sup_city	po_vendor_sites_all.city%TYPE;
l_sup_state po_vendor_sites_all.state%TYPE;
l_sup_zip po_vendor_sites_all.zip%TYPE;
l_order_date varchar2(2000);
l_fob po_headers_all.fob_lookup_code%TYPE;
l_carrier po_headers_all.ship_via_lookup_code%TYPE;
l_ship_to_id number;
l_ship_addr_l1 hr_locations_all.address_line_1%TYPE;
l_ship_addr_l2 hr_locations_all.address_line_2%TYPE;
l_ship_addr_l3 hr_locations_all.address_line_3%TYPE;
l_ship_city hr_locations_all.town_or_city%TYPE;
l_ship_state hr_locations_all.region_1%TYPE;
l_ship_zip hr_locations_all.postal_code%TYPE;

l_document1 VARCHAR2(32000) := '';
l_base_url varchar2(2000);
l_base_url_tag varchar2(2000);

/*varchar Variables for creating the notification*/
lc_change_id 		number;
lc_line_num 		varchar2(2000);
lc_ship_num 		varchar2(2000);
lc_buyer_pt_num 	mtl_system_items_kfv.concatenated_segments%TYPE;
lc_old_sup_pt_num 	po_lines_all.vendor_product_num%TYPE;
lc_new_sup_pt_num 	po_change_requests.new_supplier_part_number%TYPE;
lc_old_prom_date	varchar2(2000);
lc_new_prom_date	varchar2(2000);
lc_old_qty 			varchar2(2000);
lc_new_qty 			varchar2(2000);
lc_old_price 		varchar2(2000);
lc_new_price 		varchar2(2000);
lc_action_type 		varchar2(2000);
lc_item_desc 		po_lines_all.item_description%TYPE;
lc_uom 				po_lines_all.unit_meas_lookup_code%TYPE;
lc_ship_to_location hr_locations_all.location_code%TYPE;
lc_action_code 		po_change_requests.ACTION_TYPE%TYPE;
lc_reason			po_change_requests.request_reason%TYPE;
lc_split			varchar2(2000);
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
/*Modified as part of bug 7550964 changing date format*/

cursor l_po_chg_req_csr(grp_id number, l_planner_id number) is
select
	distinct
	CHANGE_ID,
	to_char(LINE_NUM),
	to_char(SHIPMENT_NUM),
	BUYER_PT_NUM,
	OLD_SUP_PT_NUM,
	NEW_SUP_PT_NUM,
	to_char(OLD_PROM_DATE, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                       'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
	to_char(NEW_PROM_DATE, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                       'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
	to_char(OLD_QTY),
	to_char(NEW_QTY),
	to_char(OLD_PRICE),
	to_char(NEW_PRICE),
	ACTION_TYPE,
	ITEM_DESCRIPTION,
	UOM,
	SHIP_TO_LOCATION,
	ACTION_CODE,
	REASON,
	SPLIT
from(

-- LINE CHANGES for Standard PO
select
	pcr.change_request_id CHANGE_ID,
	pcr.document_line_number LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	pcr.new_supplier_part_number NEW_SUP_PT_NUM,
	to_date(null,'DD/MM/YYYY') OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	pla.quantity OLD_QTY,
	to_number(null) NEW_QTY,
	pla.unit_price		OLD_PRICE,
	pcr.new_price		NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),
						'CANCELLATION',fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	pla.unit_meas_lookup_code	UOM,
	null SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.request_reason REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	mtl_system_items_kfv msi,
	mtl_planners mtp,
	financials_system_params_all fsp
where pla.po_line_id = pcr.document_line_id
and pcr.change_request_group_id =grp_id
and pcr.request_level = 'LINE'
and pcr.request_status in ('PENDING','REQ_APP')
and pla.latest_external_flag = 'Y'
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and fsp.org_id = pla.org_id
and msi.organization_id = fsp.inventory_organization_id
and msi.planner_code = mtp.planner_code
and msi.organization_id = mtp.organization_id
and mtp.employee_id = l_planner_id
UNION ALL

-- SHIPMENT CHANGES for Standard PO and Releases
select
	pcr.change_request_id CHANGE_ID,
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(pcr.old_promised_date, nvl(plla.promised_date,plla.need_by_date))	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	decode(pla.matching_basis,'AMOUNT',DECODE(plla.payment_type,'RATE',nvl(pcr.old_price,plla.price_override),nvl(pcr.old_amount,plla.amount)),nvl(pcr.old_price,plla.price_override))      OLD_PRICE,
        decode(pla.matching_basis,'AMOUNT',DECODE(plla.payment_type,'RATE',pcr.new_price,pcr.new_amount),pcr.new_price) NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
	mtl_planners mtp,
	financials_system_params_all fsp
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.document_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status in ('PENDING','REQ_APP')
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and fsp.org_id = pla.org_id
and msi.organization_id = fsp.inventory_organization_id
and msi.planner_code = mtp.planner_code
and msi.organization_id = mtp.organization_id
and mtp.employee_id = l_planner_id

UNION ALL

--SPLIT SHIPMENTS
select
	pcr.change_request_id CHANGE_ID,
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(pcr.old_promised_date, nvl(plla.promised_date,plla.need_by_date))	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	decode(pla.matching_basis,'AMOUNT',DECODE(nvl(pcr.new_progress_type,plla.payment_type),'RATE',nvl(pcr.new_price,plla.price_override),nvl(pcr.old_amount,plla.amount)),nvl(pcr.old_price,plla.price_override))      OLD_PRICE,
        decode(pla.matching_basis,'AMOUNT',DECODE(nvl(pcr.new_progress_type,plla.payment_type),'RATE',pcr.new_price,pcr.new_amount),pcr.new_price) NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	fnd_message.get_string('PO','PO_WF_NOTIF_YES') SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
	mtl_planners mtp,
	financials_system_params_all fsp
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.parent_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status in ('PENDING','REQ_APP')
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and fsp.org_id = pla.org_id
and msi.organization_id = fsp.inventory_organization_id
and msi.planner_code = mtp.planner_code
and msi.organization_id = mtp.organization_id
and mtp.employee_id = l_planner_id
)
order by LINE_NUM,nvl(SHIPMENT_NUM,0);

l_id number;
l_header_response po_change_requests.request_status%type;
l_header_cancel varchar2(1);
cursor l_header_cancel_csr(grp_id number) is
select change_request_id,
	request_status
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'HEADER';

l_additional_changes po_change_requests.additional_changes%type;

cursor l_header_changes_csr(grp_id number)
is
select additional_changes
from po_change_requests
where change_request_group_id = grp_id
and request_level = 'HEADER'
and additional_changes is not null;

BEGIN
	l_header_id := 	to_number(substr(p_code,2,						instr(p_code,'#')-instr(p_code,'@')-1));
	l_release_id := to_number(substr(p_code,instr(p_code,'#')+1,	instr(p_code,'$')-instr(p_code,'#')-1));
	l_grp_id := 	to_number(substr(p_code,instr(p_code,'$')+1,	instr(p_code,'%')-instr(p_code,'$')-1));
	l_planner_id := 		  substr(p_code,instr(p_code,'%')+1,	instr(p_code,'^')-instr(p_code,'%')-1);

	l_progress := '001';
	l_base_url := fnd_profile.value('APPS_WEB_AGENT');
	l_base_url := substr(
							l_base_url,
							0,
							instr(rtrim(l_base_url,'/'),'/',-1,2)-1
						);
	l_base_url_tag := '<base href= "'||l_base_url||'">';
	l_progress := '001a';

	l_header_cancel := 'N';
	if(l_grp_id is not null) then
		open l_header_cancel_csr(l_grp_id);
		fetch l_header_cancel_csr
		into l_id,
			l_header_response;
		close l_header_cancel_csr;
		if(l_id is not null) then
			l_header_cancel := 'Y';
		end if;
	end if;

	if(l_release_id is null) then
                                                     /*Modified as part of bug 7550964 changing date format*/
		select 	segment1,
				revision_num,
				pos_totals_po_sv.get_po_total(po_header_id),
				currency_code,
				vendor_id,
				vendor_site_id,
				to_char(creation_date, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                        'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
				fob_lookup_code,
				ship_via_lookup_code,
				ship_to_location_id,
				type_lookup_code,
				GLOBAL_AGREEMENT_FLAG
		into
				l_po_num,
				l_revision_num,
				l_po_total,
				l_po_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code,
				l_global_agreement_flag
		from po_headers_all
		where po_header_id = l_header_id;

		if(l_type_lookup_code = 'STANDARD') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO');
		elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
	               l_document_type := fnd_message.get_string('PO','PO_GA_TYPE');
		elsif(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET');
		elsif(l_type_lookup_code = 'CONTRACT') then
			l_document_type := fnd_message.get_string('PO','PO_POTYPE_CNTR');
		else
			l_document_type := 'Error';
		end if;

	else
                                                    /*Modified as part of bug 7550964 changing date format*/
		select
				ph.segment1,
				pr.release_num,
				pr.revision_num,
				pos_totals_po_sv.get_release_total(pr.po_release_id),
				ph.currency_code,
				ph.vendor_id,
				ph.vendor_site_id,
				to_char(pr.creation_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                       'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''),
				ph.fob_lookup_code,
				ph.ship_via_lookup_code,
				ph.ship_to_location_id,
				ph.type_lookup_code
		into
				l_blanket_num,
				l_release_num,
				l_revision_num,
				l_rel_total,
				l_rel_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code
		from po_releases_all pr,
				po_headers_all ph
		where pr.po_release_id = l_release_id
		and pr.po_header_id = ph.po_header_id;
                                                    /*Modified as part of bug 7550964 changing date format*/
		if(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL');
		else
			l_document_type := 'Error';
		end if;

	end if;
	l_progress := '002';
	select
		vendor_name
	into
		l_supplier_name
	from po_vendors
	where vendor_id = l_vendor_id;

	select
		address_line1,
		address_line2,
		address_line3,
		city,
		state,
		zip
	into
		l_sup_address_line1,
		l_sup_address_line2,
		l_sup_address_line3,
		l_sup_city,
		l_sup_state,
		l_sup_zip
	from po_vendor_sites_all
	where vendor_site_id = l_vendor_site_id;

	select
		address_line_1,
		address_line_2,
		address_line_3,
		town_or_city,
		region_1,
		postal_code
	into
		l_ship_addr_l1,
		l_ship_addr_l2,
		l_ship_addr_l3,
		l_ship_city,
		l_ship_state,
		l_ship_zip
	from hr_locations_all
	where location_id = l_ship_to_id;
	l_progress := '003';

if(l_release_id is null) then
	l_document :=l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_po_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')
		||' '||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_po_currency||') '||
		TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>';
else
	l_document :=l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_blanket_num||'-'||l_release_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
		||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_po_currency||') '||
		TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>';
end if;

l_document := l_document||'
<TABLE  cellpadding=2 cellspacing=1>
<TR>
<TD>
<TABLE cellpadding=2 cellspacing=1>
<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||'</B></font></TD>
<TD nowrap><font color=black>'||l_supplier_name||'</font></TD>
</TR>
<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||'</B></font></TD>
<TD nowrap><font color=black>';

if(l_sup_address_line1 is not null) then
	l_document := l_document || l_sup_address_line1||'<BR>';
end if;
if(l_sup_address_line2 is not null) then
	l_document := l_document || l_sup_address_line2||'<BR>';
end if;
if(l_sup_address_line3 is not null) then
	l_document := l_document || l_sup_address_line3||'<BR>';
end if;

l_document := l_document||l_sup_city||', '||l_sup_state||' '||l_sup_zip||
                      '</font></TD>
</TR>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_fob||
    '</font></TD>
</TR>


<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||'</B></font></TD>
<TD nowrap><font color=black>'||l_carrier||
                      '</font></TD>
</TR>
</TABLE>
</TD>
<TD valign=TOP>
<TABLE cellpadding=2 cellspacing=1>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_order_date||
    '</font></TD>
</TR>

<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||'</B></font></TD>
<TD nowrap><font color=black>
						'||
						l_ship_addr_l1||' '||l_ship_addr_l2||' '||l_ship_addr_l3||'<BR>'||
						l_ship_city||', '||l_ship_state||' '||l_ship_zip
						||'
						</font></TD>
</TR>

</TABLE>
</TD>
</TABLE></P>';
WF_NOTIFICATION.WriteToClob(document,l_document);

lc_line_num := null;
if(l_header_cancel = 'N') then
	open l_po_chg_req_csr(l_grp_id,l_planner_id);
	fetch l_po_chg_req_csr
	into
		lc_change_id,
		lc_line_num,
		lc_ship_num,
		lc_buyer_pt_num,
		lc_old_sup_pt_num,
		lc_new_sup_pt_num,
		lc_old_prom_date,
		lc_new_prom_date,
		lc_old_qty,
		lc_new_qty,
		lc_old_price,
		lc_new_price,
		lc_action_type,
		lc_item_desc,
		lc_uom,
		lc_ship_to_location,
		lc_action_code,
		lc_reason,
		lc_split;
	close l_po_chg_req_csr;
	if(lc_line_num is not null) then
		l_document := '<font size=3 color=#336699 face=arial><b>'||
					fnd_message.get_string('PO', 'PO_WF_NOTIF_CH_CA_REQ')||
					'</B></font><HR size=1 color=#cccc99>';
		l_document := l_document||'<TABLE><TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '<TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/cancelind_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL_PENDING');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '</TABLE>' || NL;
		l_document := l_document ||'
		<TABLE WIDTH=100% cellpadding=2 cellspacing=1>
		<TR bgcolor=#cccc99>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_LINE_NUMBER')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPMENT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SUP_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_DOC_DESCRIPTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_UNIT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PRICE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_QTY_ORDERED')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PROM_DATE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPTO')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ACTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_REASON')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SPLIT')||'</font></TH>
		</TR>
		</B>';

		WF_NOTIFICATION.WriteToClob(document,l_document);

		open l_po_chg_req_csr(l_grp_id,l_planner_id);
		loop
		fetch l_po_chg_req_csr
		into
			lc_change_id,
			lc_line_num,
			lc_ship_num,
			lc_buyer_pt_num,
			lc_old_sup_pt_num,
			lc_new_sup_pt_num,
			lc_old_prom_date,
			lc_new_prom_date,
			lc_old_qty,
			lc_new_qty,
			lc_old_price,
			lc_new_price,
			lc_action_type,
			lc_item_desc,
			lc_uom,
			lc_ship_to_location,
			lc_action_code,
			lc_reason,
			lc_split;
		EXIT when l_po_chg_req_csr%NOTFOUND;

		if(lc_split is not null) then
			lc_old_sup_pt_num := nvl(lc_old_sup_pt_num,lc_new_sup_pt_num);
			lc_new_sup_pt_num := null;

			lc_old_price:=nvl(lc_old_price,lc_new_price);
			lc_new_price:= null;

			lc_new_prom_date:= nvl(lc_new_prom_date,lc_old_prom_date);
			lc_old_prom_date:= null;

			lc_new_qty:=nvl(lc_new_qty,lc_old_qty);
			lc_old_qty:= null;
		end if;
		lc_line_num := nvl(lc_line_num,'`&nbsp');
		lc_ship_num:= nvl(lc_ship_num,'`&nbsp');
		lc_buyer_pt_num:= nvl(lc_buyer_pt_num,'`&nbsp');
		lc_old_sup_pt_num:= nvl(lc_old_sup_pt_num,'`&nbsp');
		lc_new_sup_pt_num:= nvl(lc_new_sup_pt_num,'`&nbsp');
		lc_old_prom_date:= nvl(lc_old_prom_date,'`&nbsp');
		lc_new_prom_date:= nvl(lc_new_prom_date,'`&nbsp');
		lc_old_qty:= nvl(lc_old_qty,'`&nbsp');
		lc_new_qty:= nvl(lc_new_qty,'`&nbsp');
		lc_old_price:= nvl(lc_old_price,'`&nbsp');
		lc_new_price:= nvl(lc_new_price,'`&nbsp');
		lc_action_type:= nvl(lc_action_type,'`&nbsp');
		lc_item_desc:= nvl(lc_item_desc,'`&nbsp');
		lc_uom:= nvl(lc_uom,'`&nbsp');
		lc_ship_to_location:= nvl(lc_ship_to_location,'`&nbsp');
		lc_reason := nvl(lc_reason,'`&nbsp');
		lc_split := nvl(lc_split,'`&nbsp');


		l_document := '
		        <TR bgcolor=#f7f7e7>

		        <TD align=left><font color=black>'||lc_line_num||
		                      '</font></TD> ';

		if(lc_action_code = 'CANCELLATION') then
			l_document := l_document ||'
			        <TD align=left><font color=black>
			        	<TABLE>
			        		<TR>
			        			<TD>
				        			<img src=/OA_MEDIA/cancelind_status.gif ALT="">
			        			</TD>
			        			<TD alight=right>'
				        			||lc_ship_num||
			        			'</TD>
			        		</TR>
			        	</TABLE>
			        </font></TD> ';
		else
			l_document := l_document ||'
			        <TD align=left><font color=black>'||lc_ship_num||
		    	                  '</font></TD> ';
		end if;
		l_document := l_document ||'
			<TD align=left><font color=black>'||lc_buyer_pt_num||
	                                  '</font></TD> ';

		    if(lc_new_sup_pt_num = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_sup_pt_num||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_sup_pt_num||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_sup_pt_num||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

			l_document := l_document || '
		        <TD align=left><font color=black>'||lc_item_desc||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_uom||
		                      '</font></TD> ';

		    if(lc_new_price = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_price||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_price||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_price||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(lc_new_qty = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_qty||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_qty||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

			if(lc_new_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_prom_date||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_prom_date||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;
			l_document := l_document || '

		        <TD align=left><font color=black>'||lc_ship_to_location||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_action_type||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_reason||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_split||
		                      '</font></TD>

		        </TR>
			';
			WF_NOTIFICATION.WriteToClob(document,l_document);

		END LOOP;
		CLOSE l_po_chg_req_csr;
		WF_NOTIFICATION.WriteToClob(document, '
		</TABLE></P>
		');
	end if;
	open l_header_changes_csr(l_grp_id);
	fetch l_header_changes_csr into l_additional_changes;
	close l_header_changes_csr;

	if(l_additional_changes is not null) then
		l_document := '<BR><B>'||fnd_message.get_string('PO','PO_WF_NOTIF_ADD_CHN_REQ')||'</B>'||
                              ' `&nbsp '||l_additional_changes||'<BR>';
		WF_NOTIFICATION.WriteToClob(document,l_document);
	end if;

else
	fnd_message.set_name('PO','PO_WF_NOTIF_CAN_ENTIER');
	fnd_message.set_token('DOC',l_document_type);
	l_document := fnd_message.get;
	WF_NOTIFICATION.WriteToClob(document,l_document);
end if;
exception when others then
	WF_NOTIFICATION.WriteToClob(document,'Exception occured:'||sqlerrm);

END GEN_NTF_FOR_PLAN_SUP_CHN;

/*
* Generate Notification Body for Buyer.
* This Notification will be sent when
* 1. Supplier changes a PO which was in 'APPROVED' status
* 2. Supplier acknowledges a PO (which requires acknowledgement) with acceptance, rejection, or modifications
*/
PROCEDURE GEN_NTF_FOR_BUYER_SUP_CHG(p_code IN varchar2,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2)
IS
/* l_api_name varchar2(50) := 'GEN_NTF_FOR_BUYER_SUP_CHG';  --   RDP Not needed , Replaced by JRAD Notification
l_progress varchar2(5) := '000';
l_header_id number;
l_release_id number;
l_grp_id number;
l_rel_total number;
l_rel_currency po_headers.currency_code%TYPE;
--l_blanket_num number;
l_blanket_num po_headers_all.segment1%TYPE;
--l_release_num number;
l_release_num po_releases_all.release_num%TYPE;
l_po_doc_id number;
l_rel_doc_id number;
l_acc_req_flag varchar2(1);
l_document varchar2(32000);
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_document_type varchar2(2000);
l_po_num po_headers_all.segment1%TYPE;
l_revision_num number;
l_po_total number;
l_po_currency po_headers.currency_code%TYPE;
l_vendor_id number;
l_vendor_site_id number;
l_supplier_name po_vendors.vendor_name%TYPE;
l_sup_address_line1 po_vendor_sites_all.address_line1%TYPE;
l_sup_address_line2 po_vendor_sites_all.address_line2%TYPE;
l_sup_address_line3 po_vendor_sites_all.address_line3%TYPE;
l_sup_city	po_vendor_sites_all.city%TYPE;
l_sup_state po_vendor_sites_all.state%TYPE;
l_sup_zip po_vendor_sites_all.zip%TYPE;
l_order_date varchar2(2000);
l_fob po_headers_all.fob_lookup_code%TYPE;
l_carrier po_headers_all.ship_via_lookup_code%TYPE;
l_ship_to_id number;
l_ship_addr_l1 hr_locations_all.address_line_1%TYPE;
l_ship_addr_l2 hr_locations_all.address_line_2%TYPE;
l_ship_addr_l3 hr_locations_all.address_line_3%TYPE;
l_ship_city hr_locations_all.town_or_city%TYPE;
l_ship_state hr_locations_all.region_1%TYPE;
l_ship_zip hr_locations_all.postal_code%TYPE;

l_document1 VARCHAR2(32000) := '';
l_base_url varchar2(2000);
l_base_url_tag varchar2(2000);
l_new_prom_date	varchar2(2000);
l_old_prom_date	varchar2(2000); */

/*varchar Variables for creating the notification*/
 /* lc_line_num 		varchar2(2000);
lc_ship_num 		varchar2(2000);
lc_buyer_pt_num 	mtl_system_items_kfv.concatenated_segments%TYPE;
lc_old_sup_pt_num 	po_lines_all.vendor_product_num%TYPE;
lc_new_sup_pt_num 	po_change_requests.new_supplier_part_number%TYPE;
lc_old_prom_date        date;
lc_new_prom_date        date;
lc_old_qty 			varchar2(2000);
lc_new_qty 			varchar2(2000);
lc_old_price 		varchar2(2000);
lc_new_price 		varchar2(2000);
lc_action_type 		varchar2(2000);
lc_item_desc 		po_lines_all.item_description%TYPE;
lc_uom 				po_lines_all.unit_meas_lookup_code%TYPE;
lc_ship_to_location hr_locations_all.location_code%TYPE;
lc_action_code 		po_change_requests.ACTION_TYPE%TYPE;
lc_reason			po_change_requests.request_reason%TYPE;
lc_split			varchar2(2000);
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE;
l_po_rev    number;
l_rel_rev   number;

cursor l_po_chg_req_csr(grp_id number) is
select
	to_char(LINE_NUM),
	to_char(SHIPMENT_NUM),
	BUYER_PT_NUM,
	OLD_SUP_PT_NUM,
	NEW_SUP_PT_NUM,
	OLD_PROM_DATE,
        NEW_PROM_DATE,
	to_char(OLD_QTY),
	to_char(NEW_QTY),
	to_char(OLD_PRICE),
	to_char(NEW_PRICE),
	ACTION_TYPE,
	ITEM_DESCRIPTION,
	UOM,
	SHIP_TO_LOCATION,
	ACTION_CODE,
	REASON,
	SPLIT
from(

-- LINE CHANGES for Standard PO
select
	pcr.document_line_number LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	pcr.new_supplier_part_number NEW_SUP_PT_NUM,
	to_date(null,'DD/MM/YYYY') OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	pla.quantity OLD_QTY,
	to_number(null) NEW_QTY,
	pla.unit_price		OLD_PRICE,
	pcr.new_price		NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),
						'CANCELLATION',fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	pla.unit_meas_lookup_code	UOM,
	null SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.request_reason REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pla.po_line_id = pcr.document_line_id
and pcr.change_request_group_id =grp_id
and pcr.request_level = 'LINE'
and pcr.request_status = 'PENDING'
and pla.latest_external_flag = 'Y'
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
UNION ALL

-- SHIPMENT CHANGES for Standard PO and Releases
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	decode(pcr.new_promised_date, null, plla.promised_date, pcr.old_promised_date)	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	plla.price_override	OLD_PRICE,
	pcr.new_price NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
		nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	null SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.document_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status = 'PENDING'
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
UNION ALL

--SPLIT SHIPMENTS
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	decode(pcr.new_promised_date, null, plla.promised_date, pcr.old_promised_date)	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	plla.quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	plla.price_override	OLD_PRICE,
	pcr.new_price NEW_PRICE,
	decode(pcr.ACTION_TYPE,'MODIFICATION',fnd_message.get_string('PO','PO_WF_NOTIF_CHANGE'),'CANCELLATION',
			fnd_message.get_string('PO','PO_WF_NOTIF_CANCEL'),'Error') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.ACTION_TYPE ACTION_CODE,
	pcr.REQUEST_REASON REASON,
	fnd_message.get_string('PO','PO_WF_NOTIF_YES') SPLIT
from
	po_change_requests pcr,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where pcr.change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.parent_line_location_id
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.request_status = 'PENDING'
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
)
order by LINE_NUM,nvl(SHIPMENT_NUM,0);

cursor l_po_ack_csr(l_po_document_id number, l_rel_document_id number, l_rev number)
IS
select
	to_char(LINE_NUM),
	to_char(SHIPMENT_NUM),
	BUYER_PT_NUM,
	OLD_SUP_PT_NUM,
	NEW_SUP_PT_NUM,
        OLD_PROM_DATE,
        NEW_PROM_DATE,
	to_char(OLD_QTY),
	to_char(NEW_QTY),
	to_char(OLD_PRICE),
	to_char(NEW_PRICE),
	ACTION_TYPE,
	ITEM_DESCRIPTION,
	UOM,
	SHIP_TO_LOCATION,
	NOTE
from(
-- SHIPMENT ACCEPTANCE/REJECTION for Standard PO
select
	pla.line_num LINE_NUM,
	plla.shipment_num SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.VENDOR_PRODUCT_NUM OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(plla.promised_date,plla.need_by_date)	OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	plla.quantity OLD_QTY,
	to_number(null) NEW_QTY,
	plla.price_override OLD_PRICE,
	to_number(null) NEW_PRICE,
	decode(pa.accepted_flag,'Y',fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPT'),
					'N',fnd_message.get_string('PO','PO_WF_NOTIF_REJECT'),'NA') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pa.note NOTE
from
	po_acceptances pa,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where plla.po_header_id = l_po_document_id
and plla.po_line_id = pla.po_line_id
and pa.po_line_location_id = plla.line_location_id
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
--and plla.latest_external_flag = 'Y'
and pla.latest_external_flag = 'Y'
and pa.revision_num = l_rev
and plla.revision_num = (select  max(revision_num)
                          from po_line_locations_archive_all plla2
                          where plla2.line_location_id =  plla.line_location_id and
                          plla.revision_num <= l_rev)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
UNION ALL

-- SHIPMENT ACCEPTANCE/REJECTION for Releases
select
	pla.line_num LINE_NUM,
	plla.shipment_num SHIPMENT_NUM,
	msi.concatenated_segments BUYER_PT_NUM,
	pla.VENDOR_PRODUCT_NUM OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	nvl(plla.promised_date,plla.need_by_date)	OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	plla.quantity OLD_QTY,
	to_number(null) NEW_QTY,
	plla.price_override OLD_PRICE,
	to_number(null) NEW_PRICE,
	decode(pa.accepted_flag,'Y',fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPT'),'N',fnd_message.get_string('PO','PO_WF_NOTIF_REJECT'),'NA') ACTION_TYPE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pa.NOTE NOTE
from
	po_acceptances pa,
	po_lines_archive_all pla,
	po_line_locations_archive_all plla,
	hr_locations_all hla, hz_locations hz,
	mtl_system_items_kfv msi,
    FINANCIALS_SYSTEM_PARAMS_ALL FSP
where plla.po_release_id = l_rel_document_id
and plla.po_line_id = pla.po_line_id
and pa.po_line_location_id = plla.line_location_id
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
--and plla.latest_external_flag = 'Y'
and pla.latest_external_flag = 'Y'
and pa.revision_num = l_rev
and plla.revision_num = (select  max(revision_num)
                          from po_line_locations_archive_all plla2
                          where plla2.line_location_id =  plla.line_location_id and
                          plla.revision_num <= l_rev)
and msi.inventory_item_id(+) = pla.item_id
--and msi.organization_id(+) = pla.org_id
and NVL(MSI.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
AND FSP.ORG_ID = PLA.ORG_ID
)
order by LINE_NUM,SHIPMENT_NUM;

l_id number;
l_header_response po_change_requests.request_status%type;
l_header_cancel varchar2(1);

cursor l_header_cancel_csr(grp_id number) is
select change_request_id,
	request_status
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'HEADER';

l_additional_changes po_change_requests.additional_changes%type;

cursor l_header_changes_csr(grp_id number)
is
select additional_changes
from po_change_requests
where change_request_group_id = grp_id
and request_level = 'HEADER'
and additional_changes is not null;
 */
BEGIN
/*	l_header_id := 	to_number(substr(p_code,2,						instr(p_code,'#')-instr(p_code,'@')-1));
	l_release_id := to_number(substr(p_code,instr(p_code,'#')+1,	instr(p_code,'$')-instr(p_code,'#')-1));
	l_grp_id := 	to_number(substr(p_code,instr(p_code,'$')+1,	instr(p_code,'%')-instr(p_code,'$')-1));
	l_acc_req_flag := 		  substr(p_code,instr(p_code,'%')+1,	instr(p_code,'^')-instr(p_code,'%')-1);


	l_progress := '001';
	l_base_url := fnd_profile.value('APPS_WEB_AGENT');
	l_base_url := substr(
							l_base_url,
							0,
							instr(rtrim(l_base_url,'/'),'/',-1,2)-1
						);
	l_base_url_tag := '<base href= "'||l_base_url||'">';
	l_progress := '001a';
	l_header_cancel := 'N';
	if(l_grp_id is not null) then
		open l_header_cancel_csr(l_grp_id);
		fetch l_header_cancel_csr
		into l_id,
			l_header_response;
		close l_header_cancel_csr;
		if(l_id is not null) then
			l_header_cancel := 'Y';
		end if;
	end if;

	if(l_release_id is null) then

		select 	segment1,
				revision_num,
				pos_totals_po_sv.get_po_total(po_header_id),
				currency_code,
				vendor_id,
				vendor_site_id,
				to_char(creation_date, fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS'),
				fob_lookup_code,
				ship_via_lookup_code,
				ship_to_location_id,
				type_lookup_code,
				GLOBAL_AGREEMENT_FLAG
		into
				l_po_num,
				l_revision_num,
				l_po_total,
				l_po_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code,
				l_global_agreement_flag
		from po_headers_all
		where po_header_id = l_header_id;

		if(l_type_lookup_code = 'STANDARD') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO');
	        elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
	          l_document_type := fnd_message.get_string('PO','PO_GA_TYPE');
		elsif(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET');
		elsif(l_type_lookup_code = 'CONTRACT') then
			l_document_type := fnd_message.get_string('PO','PO_POTYPE_CNTR');
		else
			l_document_type := 'Error';
		end if;

		if(l_acc_req_flag = 'Y') then
			l_po_doc_id := l_header_id;
		else
			l_po_doc_id := -1;
		end if;

	else

		select
				ph.segment1,
				pr.release_num,
				pr.revision_num,
				pos_totals_po_sv.get_release_total(pr.po_release_id),
				ph.currency_code,
				ph.vendor_id,
				ph.vendor_site_id,
				to_char(pr.creation_date, fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS'),
				ph.fob_lookup_code,
				ph.ship_via_lookup_code,
				ph.ship_to_location_id,
				ph.type_lookup_code
		into
				l_blanket_num,
				l_release_num,
				l_revision_num,
				l_rel_total,
				l_rel_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code
		from po_releases_all pr,
				po_headers_all ph
		where pr.po_release_id = l_release_id
		and pr.po_header_id = ph.po_header_id;

		if(l_type_lookup_code = 'BLANKET') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL');
		elsif(l_type_lookup_code = 'PLANNED') then
			l_document_type := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL');
		else
			l_document_type := 'Error';
		end if;

		if(l_acc_req_flag = 'Y') then
			l_rel_doc_id := l_release_id;
		else
			l_rel_doc_id := -1;
		end if;

	end if;
	l_progress := '002';
	select
		vendor_name
	into
		l_supplier_name
	from po_vendors
	where vendor_id = l_vendor_id;

	select
		address_line1,
		address_line2,
		address_line3,
		city,
		state,
		zip
	into
		l_sup_address_line1,
		l_sup_address_line2,
		l_sup_address_line3,
		l_sup_city,
		l_sup_state,
		l_sup_zip
	from po_vendor_sites_all
	where vendor_site_id = l_vendor_site_id;

	select
		address_line_1,
		address_line_2,
		address_line_3,
		town_or_city,
		region_1,
		postal_code
	into
		l_ship_addr_l1,
		l_ship_addr_l2,
		l_ship_addr_l3,
		l_ship_city,
		l_ship_state,
		l_ship_zip
	from hr_locations_all
	where location_id = l_ship_to_id;
	l_progress := '003';

if(l_release_id is null) then
	l_document :=l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_po_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')
		||' '||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_po_currency||') '||
		TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>';  */
		/*
	if(l_acc_req_flag <> 'Y') then
		l_document := l_document ||
			'- '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
			l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELLED')||' - '||l_num_of_cancels||'</B></font><HR size=1 color=#cccc99>';
	end if;	*/
/*
else
	l_document :=l_base_url_tag||
		'
		<font size=3 color=#336699 face=arial><b>'||l_document_type||' '||l_blanket_num||'-'||l_release_num||' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
		||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
		l_rel_currency||') '||
		TO_CHAR(l_rel_total, FND_CURRENCY.GET_FORMAT_MASK(l_rel_currency, 30))
		||')</B></font><HR size=1 color=#cccc99>'; */
		/*
	if(l_acc_req_flag <> 'Y') then
		l_document := l_document ||
			'- '||fnd_message.get_string('PO','PO_WF_NOTIF_NUM_OF_CHN')||' - '||
			l_num_of_changes||' '||fnd_message.get_string('PO','PO_WF_NOTIF_CANCELLED')||' - '||l_num_of_cancels||'</B></font><HR size=1 color=#cccc99>';
	end if;*/
/*
end if;

l_document := l_document||'
<TABLE  cellpadding=2 cellspacing=1>
<TR>
<TD>
<TABLE cellpadding=2 cellspacing=1>
<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||'</B></font></TD>
<TD nowrap><font color=black>'||l_supplier_name||'</font></TD>
</TR>
<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||'</B></font></TD>
<TD nowrap><font color=black>';

if(l_sup_address_line1 is not null) then
	l_document := l_document || l_sup_address_line1||'<BR>';
end if;
if(l_sup_address_line2 is not null) then
	l_document := l_document || l_sup_address_line2||'<BR>';
end if;
if(l_sup_address_line3 is not null) then
	l_document := l_document || l_sup_address_line3||'<BR>';
end if;

l_document := l_document||l_sup_city||', '||l_sup_state||' '||l_sup_zip||
                      '</font></TD>
</TR>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_fob||
    '</font></TD>
</TR>


<TR>
<TD nowrap><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||'</B></font></TD>
<TD nowrap><font color=black>'||l_carrier||
                      '</font></TD>
</TR>
</TABLE>
</TD>
<TD valign=TOP>
<TABLE cellpadding=2 cellspacing=1>
<TR>
	<TD nowrap><font color=black><B>
	'||fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_order_date||
    '</font></TD>
</TR>

<TR>
<TD nowrap valign=TOP><font color=black><B>
                      '||fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||'</B></font></TD>
<TD nowrap><font color=black>
						'||
						l_ship_addr_l1||' '||l_ship_addr_l2||' '||l_ship_addr_l3||'<BR>'||
						l_ship_city||', '||l_ship_state||' '||l_ship_zip
						||'
						</font></TD>
</TR>

</TABLE>
</TD>
</TABLE></P>';
WF_NOTIFICATION.WriteToClob(document,l_document);

if(l_header_cancel = 'N') then
	open l_po_ack_csr(l_po_doc_id, l_rel_doc_id, l_revision_num);
	fetch l_po_ack_csr
	into
		lc_line_num,
		lc_ship_num,
		lc_buyer_pt_num,
		lc_old_sup_pt_num,
		lc_new_sup_pt_num,
		lc_old_prom_date,
		lc_new_prom_date,
		lc_old_qty,
		lc_new_qty,
		lc_old_price,
		lc_new_price,
		lc_action_type,
		lc_item_desc,
		lc_uom,
		lc_ship_to_location,
		lc_reason;
	close l_po_ack_csr;
	if(lc_line_num is not null) then
		l_document := '<font size=3 color=#336699 face=arial><b>'||fnd_message.get_string('PO','PO_WF_NOTIF_ACK_RESPONSE')||'</B></font><HR size=1 color=#cccc99>
		<TABLE WIDTH=100% cellpadding=2 cellspacing=1>
		<TR bgcolor=#cccc99>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_LINE_NUMBER')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPMENT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SUP_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_DOC_DESCRIPTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_UNIT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PRICE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_QTY_ORDERED')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PROM_DATE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPTO')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ACTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_REASON')||'</font></TH>
		</TR>
		</B>';

		WF_NOTIFICATION.WriteToClob(document,l_document);
		open l_po_ack_csr(l_po_doc_id, l_rel_doc_id, l_revision_num);
		loop
		fetch l_po_ack_csr
		into
			lc_line_num,
			lc_ship_num,
			lc_buyer_pt_num,
			lc_old_sup_pt_num,
			lc_new_sup_pt_num,
			lc_old_prom_date,
			lc_new_prom_date,
			lc_old_qty,
			lc_new_qty,
			lc_old_price,
			lc_new_price,
			lc_action_type,
			lc_item_desc,
			lc_uom,
			lc_ship_to_location,
			lc_reason;
		EXIT when l_po_ack_csr%NOTFOUND;

	        l_old_prom_date := to_char(lc_old_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
                l_new_prom_date := to_char(lc_new_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
		lc_line_num := nvl(lc_line_num,'`&nbsp');
		lc_ship_num:= nvl(lc_ship_num,'`&nbsp');
		lc_buyer_pt_num := nvl(lc_buyer_pt_num,'`&nbsp');
		lc_old_sup_pt_num:= nvl(lc_old_sup_pt_num,'`&nbsp');
		lc_new_sup_pt_num:= nvl(lc_new_sup_pt_num,'`&nbsp');
		l_old_prom_date:= nvl(l_old_prom_date,'`&nbsp');
		l_new_prom_date:= nvl(l_new_prom_date,'`&nbsp');
		lc_old_qty:= nvl(lc_old_qty,'`&nbsp');
		lc_new_qty:= nvl(lc_new_qty,'`&nbsp');
		lc_old_price:= nvl(lc_old_price,'`&nbsp');
		lc_new_price:= nvl(lc_new_price,'`&nbsp');
		lc_action_type:= nvl(lc_action_type,'`&nbsp');
		lc_item_desc:= nvl(lc_item_desc,'`&nbsp');
		lc_uom:= nvl(lc_uom,'`&nbsp');
		lc_ship_to_location:= nvl(lc_ship_to_location,'`&nbsp');
		lc_reason := nvl(lc_reason,'`&nbsp');


		l_document := '
		        <TR bgcolor=#f7f7e7>

		        <TD align=left><font color=black>'||lc_line_num||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_ship_num||
	    	                      '</font></TD>
			<TD align=left><font color=black>'||lc_buyer_pt_num||
	                              '</font></TD>
		        <TD align=left><font color=black>'||lc_old_sup_pt_num||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_item_desc||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_uom||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_old_price||'
		                      </font></TD>
		        <TD align=left><font color=black>'||lc_old_qty||'
		                      </font></TD>
		        <TD align=left><font color=black>'||l_old_prom_date||'
		                      </font></TD>
		        <TD align=left><font color=black>'||lc_ship_to_location||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_action_type||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_reason||
		                      '</font></TD>

		        </TR>
			';
			WF_NOTIFICATION.WriteToClob(document,l_document);

		END LOOP;
		CLOSE l_po_ack_csr;
		WF_NOTIFICATION.WriteToClob(document, '
		</TABLE></P>
		');
	end if;


	lc_line_num := null;
	open l_po_chg_req_csr(l_grp_id);
	fetch l_po_chg_req_csr
	into
		lc_line_num,
		lc_ship_num,
		lc_buyer_pt_num,
		lc_old_sup_pt_num,
		lc_new_sup_pt_num,
		lc_old_prom_date,
		lc_new_prom_date,
		lc_old_qty,
		lc_new_qty,
		lc_old_price,
		lc_new_price,
		lc_action_type,
		lc_item_desc,
		lc_uom,
		lc_ship_to_location,
		lc_action_code,
		lc_reason,
		lc_split;
	close l_po_chg_req_csr;
	if(lc_line_num is not null) then
		l_document := '<font size=3 color=#336699 face=arial><b>'||
					fnd_message.get_string('PO', 'PO_WF_NOTIF_CH_CA_REQ')||
					'</B></font><HR size=1 color=#cccc99>';
		l_document := l_document||'<TABLE><TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '<TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/cancelind_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL_PENDING');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '</TABLE>' || NL;
		l_document := l_document ||'
		<TABLE WIDTH=100% cellpadding=2 cellspacing=1>
		<TR bgcolor=#cccc99>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_LINE_NUMBER')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPMENT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SUP_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_DOC_DESCRIPTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_UNIT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PRICE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_QTY_ORDERED')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PROM_DATE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPTO')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ACTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_REASON')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SPLIT')||'</font></TH>
		</TR>
		</B>';

		WF_NOTIFICATION.WriteToClob(document,l_document);
		--, l_po_doc_id, l_rel_doc_id
		open l_po_chg_req_csr(l_grp_id);
		loop
		fetch l_po_chg_req_csr
		into
			lc_line_num,
			lc_ship_num,
			lc_buyer_pt_num,
			lc_old_sup_pt_num,
			lc_new_sup_pt_num,
			lc_old_prom_date,
			lc_new_prom_date,
			lc_old_qty,
			lc_new_qty,
			lc_old_price,
			lc_new_price,
			lc_action_type,
			lc_item_desc,
			lc_uom,
			lc_ship_to_location,
			lc_action_code,
			lc_reason,
			lc_split;
		EXIT when l_po_chg_req_csr%NOTFOUND;

		if(lc_split is not null) then
			lc_old_sup_pt_num := nvl(lc_old_sup_pt_num,lc_new_sup_pt_num);
			lc_new_sup_pt_num := null;

			lc_old_price:=nvl(lc_old_price,lc_new_price);
			lc_new_price:= null;

			lc_new_prom_date:= nvl(lc_new_prom_date,lc_old_prom_date);
			lc_old_prom_date:= null;

			lc_new_qty:=nvl(lc_new_qty,lc_old_qty);
			lc_old_qty:= null;
		end if;

		if(fnd_timezones.timezones_enabled()='Y') then
                            fnd_date_tz.init_timezones_for_fnd_date(true);
                            l_old_prom_date := fnd_date.date_to_displayDT(lc_old_prom_date);
                            l_new_prom_date := fnd_date.date_to_displayDT(lc_new_prom_date);
                        else
			    l_old_prom_date := to_char(lc_old_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
            		    l_new_prom_date := to_char(lc_new_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
                        end if;


		lc_line_num := nvl(lc_line_num,'`&nbsp');
		lc_ship_num:= nvl(lc_ship_num,'`&nbsp');
		lc_buyer_pt_num:= nvl(lc_buyer_pt_num,'`&nbsp');
		lc_old_sup_pt_num:= nvl(lc_old_sup_pt_num,'`&nbsp');
		lc_new_sup_pt_num:= nvl(lc_new_sup_pt_num,'`&nbsp');
		l_old_prom_date:= nvl(l_old_prom_date,'`&nbsp');
		l_new_prom_date:= nvl(l_new_prom_date,'`&nbsp');
		lc_old_qty:= nvl(lc_old_qty,'`&nbsp');
		lc_new_qty:= nvl(lc_new_qty,'`&nbsp');
		lc_old_price:= nvl(lc_old_price,'`&nbsp');
		lc_new_price:= nvl(lc_new_price,'`&nbsp');
		lc_action_type:= nvl(lc_action_type,'`&nbsp');
		lc_item_desc:= nvl(lc_item_desc,'`&nbsp');
		lc_uom:= nvl(lc_uom,'`&nbsp');
		lc_ship_to_location:= nvl(lc_ship_to_location,'`&nbsp');
		lc_reason := nvl(lc_reason,'`&nbsp');
		lc_split := nvl(lc_split,'`&nbsp');


		l_document := '
		        <TR bgcolor=#f7f7e7>

		        <TD align=left><font color=black>'||lc_line_num||
		                      '</font></TD> ';

		if(lc_action_code = 'CANCELLATION') then
			l_document := l_document ||'
			        <TD align=left><font color=black>
			        	<TABLE>
			        		<TR>
			        			<TD>
				        			<img src=/OA_MEDIA/cancelind_status.gif ALT="">
			        			</TD>
			        			<TD alight=right>'
				        			||lc_ship_num||
			        			'</TD>
			        		</TR>
			        	</TABLE>
			        </font></TD> ';
		else
			l_document := l_document ||'
			        <TD align=left><font color=black>'||lc_ship_num||
		    	                  '</font></TD> ';
		end if;
		l_document := l_document ||'
			<TD align=left><font color=black>'||lc_buyer_pt_num||
	                                  '</font></TD> ';

		    if(lc_new_sup_pt_num = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_sup_pt_num||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_sup_pt_num||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_sup_pt_num||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

			l_document := l_document || '
		        <TD align=left><font color=black>'||lc_item_desc||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_uom||
		                      '</font></TD> ';

		    if(lc_new_price = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_price||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_price||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_price||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(lc_new_qty = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_qty||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_qty||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(l_new_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||l_old_prom_date||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp' OR l_old_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||l_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||l_old_prom_date||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||l_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;
			l_document := l_document || '

		        <TD align=left><font color=black>'||lc_ship_to_location||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_action_type||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_reason||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_split||
		                      '</font></TD>

		        </TR>
			';
			WF_NOTIFICATION.WriteToClob(document,l_document);

		END LOOP;
		CLOSE l_po_chg_req_csr;
		WF_NOTIFICATION.WriteToClob(document, '
		</TABLE></P>
		');
	end if;
	open l_header_changes_csr(l_grp_id);
	fetch l_header_changes_csr into l_additional_changes;
	close l_header_changes_csr;

	if(l_additional_changes is not null) then
		l_document := '<BR><B>'||fnd_message.get_string('PO','PO_WF_NOTIF_ADD_CHN_REQ')||'</B>'||
			      ' `&nbsp '||l_additional_changes||'<BR>';
		WF_NOTIFICATION.WriteToClob(document,l_document);
	end if;
else
	fnd_message.set_name('PO','PO_WF_NOTIF_CAN_ENTIER');
	fnd_message.set_token('DOC',l_document_type);
	l_document := fnd_message.get;
	WF_NOTIFICATION.WriteToClob(document,l_document);
end if;
exception when others then
	IF g_fnd_debug = 'Y' THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;
	WF_NOTIFICATION.WriteToClob(document,'Exception occured:'||sqlerrm);  */
null;

END GEN_NTF_FOR_BUYER_SUP_CHG;


/*
*Generate Notification for Supplier, informing him/her of Buyer's response to supplier's change request.
*/
PROCEDURE GEN_NTF_FOR_SUP_BUY_RP(	p_chg_req_grp_id IN number,
								    display_type   in      Varchar2,
								    document in out NOCOPY clob,
								    document_type  in out NOCOPY  varchar2)
IS
/*                                                                        -- RDP changes replaced by Jrad Notification
l_api_name varchar2(50):='GEN_NTF_FOR_SUP_BUY_RP';
l_progress varchar2(5) := '000';
l_po_release_id number;
l_rel_total number;
l_rel_currency po_headers.currency_code%TYPE;
--l_blanket_num number;
l_blanket_num po_headers_all.segment1%TYPE;
--l_release_num number;
l_release_num po_releases_all.release_num%TYPE;
l_document varchar2(32000);
l_document_header_id number;
l_document_type varchar2(2000);
l_po_num po_headers_all.segment1%TYPE;
l_revision_num number;
l_po_total number;
l_po_currency po_headers.currency_code%TYPE;
l_vendor_id number;
l_vendor_site_id number;
l_supplier_name po_vendors.vendor_name%TYPE;
l_sup_address_line1 po_vendor_sites_all.address_line1%TYPE;
l_sup_address_line2 po_vendor_sites_all.address_line2%TYPE;
l_sup_address_line3 po_vendor_sites_all.address_line3%TYPE;
l_sup_city	po_vendor_sites_all.city%TYPE;
l_sup_state po_vendor_sites_all.state%TYPE;
l_sup_zip po_vendor_sites_all.zip%TYPE;
l_order_date varchar2(2000);
l_fob po_headers_all.fob_lookup_code%TYPE;
l_carrier po_headers_all.ship_via_lookup_code%TYPE;
l_ship_to_id number;
l_ship_addr_l1 hr_locations_all.address_line_1%TYPE;
l_ship_addr_l2 hr_locations_all.address_line_2%TYPE;
l_ship_addr_l3 hr_locations_all.address_line_3%TYPE;
l_ship_city hr_locations_all.town_or_city%TYPE;
l_ship_state hr_locations_all.region_1%TYPE;
l_ship_zip hr_locations_all.postal_code%TYPE;

l_base_url varchar2(2000);
l_base_url_tag varchar2(2000);

l_document1 VARCHAR2(32000) := '';
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';

l_old_prom_date	varchar2(2000);
l_new_prom_date	varchar2(2000);

l_doc_hdr_info varchar2(2000);
lc_action_code po_change_requests.action_type%type;
lc_line_num 		varchar2(2000);
lc_ship_num 		varchar2(2000);
lc_old_sup_pt_num 	po_lines_all.vendor_product_num%TYPE;
lc_new_sup_pt_num 	po_change_requests.new_supplier_part_number%TYPE;
lc_old_prom_date        date;
lc_new_prom_date        date;
lc_old_qty 			varchar2(2000);
lc_new_qty 			varchar2(2000);
lc_old_price 		varchar2(2000);
lc_new_price 		varchar2(2000);
lc_response 		varchar2(2000);
lc_item_desc 		po_lines_all.item_description%TYPE;
lc_uom 				po_lines_all.unit_meas_lookup_code%TYPE;
lc_ship_to_location hr_locations_all.location_code%TYPE;
lc_reason			po_change_requests.response_reason%TYPE;
lc_split varchar2(2000);


cursor l_po_chg_req_csr(grp_id number) is
select
	to_char(LINE_NUM),
	to_char(SHIPMENT_NUM),
	OLD_SUP_PT_NUM,
	NEW_SUP_PT_NUM,
        OLD_PROM_DATE,
        NEW_PROM_DATE,
	to_char(OLD_QTY),
	to_char(NEW_QTY),
	to_char(OLD_PRICE),
	to_char(NEW_PRICE),
	RESPONSE,
	ITEM_DESCRIPTION,
	UOM,
	SHIP_TO_LOCATION,
	REASON,
	SPLIT,
	ACTION_CODE
from(
-- Respond to Changes on Line for Standard PO
select
	pcr.document_line_number LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	pcr.old_supplier_part_number OLD_SUP_PT_NUM,
	pcr.new_supplier_part_number NEW_SUP_PT_NUM,
	to_date(null,'DD/MM/YYYY') OLD_PROM_DATE,
	to_date(null,'DD/MM/YYYY') NEW_PROM_DATE,
	nvl(pcr.old_quantity, pla.quantity) OLD_QTY,
	to_number(null) NEW_QTY,
	nvl(pcr.old_price,pla.unit_price) OLD_PRICE,
	pcr.new_price		NEW_PRICE,
	decode(pcr.REQUEST_STATUS,'ACCEPTED',fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED'),
		'REJECTED',fnd_message.get_string('PO','PO_WF_NOTIF_REJ'),'Error') RESPONSE,
	pla.item_description ITEM_DESCRIPTION,
	pla.unit_meas_lookup_code	UOM,
	null SHIP_TO_LOCATION,
	pcr.response_reason REASON,
	null SPLIT,
	pcr.action_type ACTION_CODE
from po_change_requests pcr, po_lines_archive_all pla
where pla.po_line_id = pcr.document_line_id
and pcr.change_request_group_id =grp_id
--and pcr.document_revision_num = pla.revision_num
and pcr.request_level = 'LINE'
and pla.latest_external_flag = 'Y'
UNION ALL
--Respond to changes on Shipment for Releases AND Standard PO
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	pcr.old_promised_date	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	nvl(pcr.old_quantity,plla.quantity)	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
	nvl(pcr.old_price,plla.price_override) OLD_PRICE,
	pcr.new_price NEW_PRICE,
	decode(pcr.REQUEST_STATUS,'ACCEPTED',fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED'),
		'REJECTED',fnd_message.get_string('PO','PO_WF_NOTIF_REJ'),'Error') RESPONSE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
        nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.response_reason REASON,
	decode(pcr.parent_line_location_id, null, null, fnd_message.get_string('PO','PO_WF_NOTIF_YES')) SPLIT,
	pcr.action_type ACTION_CODE

from po_change_requests pcr, po_lines_archive_all pla, po_line_locations_archive_all plla,
hr_locations_all hla, hz_locations hz
where change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.document_line_location_id
--and pcr.document_revision_num = pla.revision_num
--and pcr.document_revision_num = plla.revision_num
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and pcr.new_supplier_order_line_number is null
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)
and pcr.parent_line_location_id is null
UNION ALL
--Respond to changes on Split Shipment
select
	pla.line_num LINE_NUM,
	pcr.document_shipment_number SHIPMENT_NUM,
	pla.vendor_product_num OLD_SUP_PT_NUM,
	null NEW_SUP_PT_NUM,
	pcr.old_promised_date	OLD_PROM_DATE,
	pcr.new_promised_date 	NEW_PROM_DATE,
	pcr.old_quantity	OLD_QTY,
	pcr.new_quantity	NEW_QTY,
        nvl(pcr.old_price,plla.price_override) OLD_PRICE,
	pcr.new_price NEW_PRICE,
	decode(pcr.REQUEST_STATUS,'ACCEPTED',fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED'),
		'REJECTED',fnd_message.get_string('PO','PO_WF_NOTIF_REJ'),'Error') RESPONSE,
	pla.item_description ITEM_DESCRIPTION,
	nvl(plla.unit_meas_lookup_code,pla.unit_meas_lookup_code) UOM,
	nvl(hla.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,60)) SHIP_TO_LOCATION,
	pcr.response_reason REASON,
	decode(pcr.parent_line_location_id, null, null, fnd_message.get_string('PO','PO_WF_NOTIF_YES')) SPLIT,
	pcr.action_type ACTION_CODE
from po_change_requests pcr, po_lines_archive_all pla, po_line_locations_archive_all plla,
hr_locations_all hla, hz_locations hz
where change_request_group_id =grp_id
and pla.po_line_id = pcr.document_line_id
and pla.latest_external_flag = 'Y'
and plla.line_location_id = pcr.parent_line_location_id
--and pcr.document_revision_num = pla.revision_num
--and pcr.document_revision_num = plla.revision_num
and plla.latest_external_flag = 'Y'
and request_level = 'SHIPMENT'
and hla.location_id(+) = plla.ship_to_location_id
and plla.SHIP_TO_LOCATION_ID = hz.LOCATION_ID(+)

)
order by LINE_NUM,nvl(SHIPMENT_NUM,0);

l_id number;
l_header_response po_change_requests.request_status%type;
l_header_cancel varchar2(1);

cursor l_header_cancel_csr(grp_id number) is
select change_request_id,
	request_status
from po_change_requests
where change_request_group_id = grp_id
and action_type = 'CANCELLATION'
and request_level = 'HEADER';

l_additional_changes po_change_requests.additional_changes%type;

cursor l_header_changes_csr(grp_id number)
is
select additional_changes, request_status
from po_change_requests
where change_request_group_id = grp_id
and request_level = 'HEADER'
and additional_changes is not null;  */

BEGIN
  /*	select distinct
		document_header_id,
		document_type,
		po_release_id
	into
		l_document_header_id,
		l_document_type,
		l_po_release_id
	from po_change_requests
	where change_request_group_id = p_chg_req_grp_id;

	l_progress := '001';
	l_base_url := POS_URL_PKG.get_external_url;

	l_base_url_tag := '<base href= "'||l_base_url||'">';
	l_progress := '001a';
	l_header_cancel := 'N';
	if(p_chg_req_grp_id is not null) then
		open l_header_cancel_csr(p_chg_req_grp_id);
		fetch l_header_cancel_csr
		into l_id,
			l_header_response;
		close l_header_cancel_csr;
		if(l_id is not null) then
			l_header_cancel := 'Y';
		end if;
	end if;

	if(l_po_release_id is null) then
		select 	segment1,
				revision_num,
				pos_totals_po_sv.get_po_total(po_header_id),
				currency_code,
				vendor_id,
				vendor_site_id,
				to_char(creation_date, fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS'),
				fob_lookup_code,
				ship_via_lookup_code,
				ship_to_location_id,
				type_lookup_code,
				GLOBAL_AGREEMENT_FLAG
		into
				l_po_num,
				l_revision_num,
				l_po_total,
				l_po_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code,
				l_global_agreement_flag
		from po_headers_all
		where po_header_id = l_document_header_id;
	else
		select 	ph.segment1,
				pr.release_num,
				pr.revision_num,
				pos_totals_po_sv.get_release_total(pr.po_release_id),
				ph.currency_code,
				ph.vendor_id,
				ph.vendor_site_id,
				to_char(pr.creation_date, fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS'),
				ph.fob_lookup_code,
				ph.ship_via_lookup_code,
				ph.ship_to_location_id,
				ph.type_lookup_code,
				global_agreement_flag
		into
				l_blanket_num,
				l_release_num,
				l_revision_num,
				l_rel_total,
				l_rel_currency,
				l_vendor_id,
				l_vendor_site_id,
				l_order_date,
				l_fob,
				l_carrier,
				l_ship_to_id,
				l_type_lookup_code,
				l_global_agreement_flag
		from po_releases_all pr,
			po_headers_all ph
		where pr.po_release_id = l_po_release_id
		and pr.po_header_id = ph.po_header_id;
	end if;
	l_progress := '002';
	select vendor_name
	into l_supplier_name
	from po_vendors
	where vendor_id = l_vendor_id;

	select
		address_line1,
		address_line2,
		address_line3,
		city,
		state,
		zip
	into
		l_sup_address_line1,
		l_sup_address_line2,
		l_sup_address_line3,
		l_sup_city,
		l_sup_state,
		l_sup_zip
	from po_vendor_sites_all
	where vendor_site_id = l_vendor_site_id;

	select
		address_line_1,
		address_line_2,
		address_line_3,
		town_or_city,
		region_1,
		postal_code
	into
		l_ship_addr_l1,
		l_ship_addr_l2,
		l_ship_addr_l3,
		l_ship_city,
		l_ship_state,
		l_ship_zip
	from hr_locations_all
	where location_id = l_ship_to_id;
	l_progress := '003';
if (display_type = 'text/html') then

	if(l_po_release_id is null) then
	if(l_type_lookup_code = 'STANDARD') then
	  l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO')||' '||l_po_num;
	elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
	  l_doc_hdr_info := fnd_message.get_string('PO','PO_GA_TYPE') ||' '||l_po_num;
	elsif(l_type_lookup_code = 'BLANKET') then
	  l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET')||' '||l_po_num;
	  l_po_total := pos_totals_po_sv.get_po_archive_total(l_document_header_id,l_revision_num,
				                              l_type_lookup_code );
	elsif(l_type_lookup_code = 'CONTRACT') then
	  l_doc_hdr_info := fnd_message.get_string('PO','PO_POTYPE_CNTR')||' '||l_po_num;
	elsif(l_type_lookup_code = 'PLANNED') then
	  l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO')||' '||l_po_num;
	end if;
			l_document :=l_base_url_tag|| '
			<font size=3 color=#336699 face=arial><b>'||l_doc_hdr_info||' '||
			fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
			||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||l_po_currency||')'||
			TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_po_currency, 30))
			||')</B></font><HR size=1 color=#cccc99>';

	else
			if(l_type_lookup_code = 'BLANKET') then
				l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL')||' '||l_blanket_num||'-'||l_release_num;
			elsif(l_type_lookup_code = 'PLANNED') then
				l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL')||' '||l_blanket_num||'-'||l_release_num;
			end if;
			l_document :=l_base_url_tag|| '
			<font size=3 color=#336699 face=arial><b>'||l_doc_hdr_info||
			' '||fnd_message.get_string('PO','PO_WF_NOTIF_REV')||' '
			||l_revision_num||' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||'('||
			l_rel_currency||')'||
			TO_CHAR(l_rel_total, FND_CURRENCY.GET_FORMAT_MASK(l_rel_currency, 30))
			||')</B></font><HR size=1 color=#cccc99>';

	end if;
	l_progress := '004';
	l_document := l_document || '
	<TABLE  cellpadding=2 cellspacing=1>
	<TR>
	<TD>
	<TABLE cellpadding=2 cellspacing=1>
	<TR>
	<TD nowrap><font color=black><B>
	                      '||fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_supplier_name||'</font></TD>
	</TR>
	<TR>
	<TD nowrap valign=TOP><font color=black><B>
	                      '||fnd_message.get_string('PO','PO_WF_NOTIF_ADDRESS')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_sup_address_line1||' '||l_sup_address_line2||' '||
									l_sup_address_line3||'<BR>'||l_sup_city||', '||l_sup_state||' '||l_sup_zip||
	                      '</font></TD>
	</TR>
	<TR>
		<TD nowrap><font color=black><B>
		'||fnd_message.get_string('PO','PO_WF_NOTIF_FOB')||'</B></font></TD>
		<TD nowrap><font color=black>'||l_fob||
	    '</font></TD>
	</TR>


	<TR>
	<TD nowrap><font color=black><B>
	                      '||fnd_message.get_string('PO','PO_WF_NOTIF_CARRIER')||'</B></font></TD>
	<TD nowrap><font color=black>'||l_carrier||
	                      '</font></TD>
	</TR>
	</TABLE>
	</TD>
	<TD valign=TOP>
	<TABLE cellpadding=2 cellspacing=1>
	<TR>
		<TD nowrap><font color=black><B>
		'||fnd_message.get_string('PO','PO_WF_NOTIF_ORDER_DATE')||'</B></font></TD>
		<TD nowrap><font color=black>'||l_order_date||
	    '</font></TD>
	</TR>

	<TR>
	<TD nowrap valign=TOP><font color=black><B>
	                      '||fnd_message.get_string('PO','PO_WF_NOTIF_SHPTO_ADD')||'</B></font></TD>
	<TD nowrap><font color=black>';
	if(l_ship_addr_l1 is not null) then
		l_document := l_document || l_ship_addr_l1||'<BR>';
	end if;
	if(l_ship_addr_l2 is not null) then
		l_document := l_document || l_ship_addr_l2||'<BR>';
	end if;
	if(l_ship_addr_l3 is not null) then
		l_document := l_document || l_ship_addr_l3||'<BR>';
	end if;


	l_document := l_document || l_ship_city||', '||l_ship_state||' '||l_ship_zip
							||'
							</font></TD>
	</TR>

	</TABLE>
	</TD>
	</TABLE></P>';

	WF_Notification.WriteToClob(document,l_document);
	if(l_header_cancel = 'N') then
		l_document := '<font size=3 color=#336699 face=arial><b>'||fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_DETAILS')||'</B></font><HR size=1 color=#cccc99>';
	--LEGENDS
		l_document := l_document||'<TABLE><TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEW_VALUE');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '<TR>'|| NL;
	    l_document:= l_document||'<TD class=instructiontext>'||
	      			'<img src=/OA_MEDIA/cancelind_status.gif ALT="">'
	                 || fnd_message.get_string('PO', 'PO_WF_NOTIF_CANCEL_PENDING');
	    l_document := l_document || '</TD></TR>' || NL;
	    l_document := l_document || '</TABLE>' || NL;

		l_document := l_document ||
		'<TABLE WIDTH=100% cellpadding=2 cellspacing=1>
		<TR bgcolor=#cccc99>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_LINE_NUMBER')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPMENT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SUP_ITEM')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_DOC_DESCRIPTION')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_UNIT')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PRICE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_QTY_ORDERED')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_PROM_DATE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SHIPTO')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_RESPONSE')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_REASON')||'</font></TH>
		<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_SPLIT')||'</font></TH>
		</TR>
		</B>';
		WF_NOTIFICATION.WriteToClob(document,l_document);
		open l_po_chg_req_csr(p_chg_req_grp_id);
		loop
		fetch l_po_chg_req_csr
		into
			lc_line_num,
			lc_ship_num,
			lc_old_sup_pt_num,
			lc_new_sup_pt_num,
			lc_old_prom_date,
			lc_new_prom_date,
			lc_old_qty,
			lc_new_qty,
			lc_old_price,
			lc_new_price,
			lc_response,
			lc_item_desc,
			lc_uom,
			lc_ship_to_location,
			lc_reason,
			lc_split,
			lc_action_code;
		EXIT when l_po_chg_req_csr%NOTFOUND;
			if(lc_split is not null) then
				lc_old_sup_pt_num := nvl(lc_old_sup_pt_num,lc_new_sup_pt_num);
				lc_new_sup_pt_num := null;

				lc_old_price:=nvl(lc_old_price,lc_new_price);
				lc_new_price:= null;


				lc_new_prom_date := nvl(lc_new_prom_date,lc_old_prom_date);
				lc_old_prom_date := null;

				lc_new_qty:= nvl(lc_new_qty,lc_old_qty);
				lc_old_qty:= null;
			end if;

			if(fnd_timezones.timezones_enabled()='Y') then
                            fnd_date_tz.init_timezones_for_fnd_date(true);
                            l_old_prom_date := fnd_date.date_to_displayDT(lc_old_prom_date);
                            l_new_prom_date := fnd_date.date_to_displayDT(lc_new_prom_date);
                        else
			    l_old_prom_date := to_char(lc_old_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
			    l_new_prom_date := to_char(lc_new_prom_date,fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS');
                        end if;


			lc_line_num := nvl(lc_line_num,'`&nbsp');
			lc_ship_num:= nvl(lc_ship_num,'`&nbsp');
			lc_old_sup_pt_num:= nvl(lc_old_sup_pt_num,'`&nbsp');
			lc_new_sup_pt_num:= nvl(lc_new_sup_pt_num,'`&nbsp');
			l_old_prom_date:= nvl(l_old_prom_date,'`&nbsp');
			l_new_prom_date:= nvl(l_new_prom_date,'`&nbsp');
			lc_old_qty:= nvl(lc_old_qty,'`&nbsp');
			lc_new_qty:= nvl(lc_new_qty,'`&nbsp');
			lc_old_price:= nvl(lc_old_price,'`&nbsp');
			lc_new_price:= nvl(lc_new_price,'`&nbsp');
			lc_response := nvl(lc_response ,'`&nbsp');
			lc_item_desc:= nvl(lc_item_desc,'`&nbsp');
			lc_uom:= nvl(lc_uom,'`&nbsp');
			lc_ship_to_location:= nvl(lc_ship_to_location,'`&nbsp');
			lc_reason:= nvl(lc_reason,'`&nbsp');
			lc_split:= nvl(lc_split,'`&nbsp');

		l_document := '
		        <TR bgcolor=#f7f7e7>';

		if(lc_action_code = 'CANCELLATION') then
			l_document := l_document ||'
		        <TD align=left><font color=black>
			        	<TABLE>
			        		<TR>
			        			<TD>
				        			<img src=/OA_MEDIA/cancelind_status.gif ALT="">
			        			</TD>
			        			<TD alight=right>'
				        			||lc_line_num||
			        			'</TD>
			        		</TR>
			        	</TABLE>
			        </font></TD> ';
		else
			l_document := l_document ||'
		        <TD align=left><font color=black>'||lc_line_num||
		    	                  '</font></TD> ';
		end if;
			l_document := l_document ||
				'<TD align=left><font color=black>'||lc_ship_num||
		                      '</font></TD> ';

		    if(lc_new_sup_pt_num = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_sup_pt_num||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_sup_pt_num||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_sup_pt_num||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

			l_document := l_document || '
		        <TD align=left><font color=black>'||lc_item_desc||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_uom||
		                      '</font></TD> ';

		    if(lc_new_price = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_price||'
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_price||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_price||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(lc_new_qty = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||lc_old_qty||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||lc_old_qty||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||lc_new_qty||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;

		    if(l_new_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>'||l_old_prom_date||'
		                      </font></TD>';
		    elsif(lc_split <> '`&nbsp' OR l_old_prom_date = '`&nbsp') then
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||l_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			else
				l_document := l_document || '
		        <TD align=left><font color=black>
		        	<table>
		        		<tr>
		        			<td>'||l_old_prom_date||'
		        			</td>
		        		</tr>
		        		<tr>
		        			<td>'||l_new_prom_date||'
		        			</td>
		        			<td>
		        			<img src=/OA_MEDIA/newupdateditem_status.gif ALT="">
		        			</td>
		        		</tr>
		        	</table>
		                      </font></TD>';
			end if;
			l_document := l_document || '

		        <TD align=left><font color=black>'||lc_ship_to_location||
		                      '</font></TD>

		        <TD align=left><font color=black>'||lc_response||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_reason||
		                      '</font></TD>
		        <TD align=left><font color=black>'||lc_split||
		                      '</font></TD>

		        </TR>
			';
			WF_NOTIFICATION.WriteToClob(document,l_document);
		END LOOP;
		CLOSE l_po_chg_req_csr;
		WF_NOTIFICATION.WriteToClob(document, '
		</TABLE></P>
		');
		open l_header_changes_csr(p_chg_req_grp_id);
				fetch l_header_changes_csr into l_additional_changes, l_header_response ;
				close l_header_changes_csr;

				if(l_additional_changes is not null) then
				  if(l_header_response = 'ACCEPTED') then
					l_header_response := fnd_message.get_string('PO','PO_WF_NOTIF_ACCEPTED');
				  else
					l_header_response := fnd_message.get_string('PO','PO_WF_NOTIF_REJ');
				  end if;
				  l_document := '<BR><TABLE WIDTH=100% cellpadding=2 cellspacing=1>' ||
				                   '<TR bgcolor=#cccc99>' ||
				                   '<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_ADD_CHN_REQ_NCOL')||
				                                  '</font></TH>' ||
				                   '<TH align=left><font color=#336699 >'||fnd_message.get_string('PO','PO_WF_NOTIF_RESPONSE')||
				                   '</font></TH>' ||
				                   '</TR>' ||
				                   '<TR>' || '<TD  align=left><font color=black>' || l_additional_changes ||
				                   '</font></TD><TD  align=left><font color=black>' || l_header_response ||

				                   '</font></TD></TR>' ||
				                   '</TABLE>';

					WF_NOTIFICATION.WriteToClob(document,l_document);
				end if;

	else  --if header_cnacel = N
		if(l_header_response = 'ACCEPTED') then
			l_header_response := fnd_message.get_string('PO','PO_WF_NOTIF_SACCEPTED');
		else
			l_header_response := fnd_message.get_string('PO','PO_WF_NOTIF_SREJECTED');
		end if;
		fnd_message.set_name('PO','PO_WF_NOTIF_BUY_RESP_CAN');
	    fnd_message.set_token('DOC',l_doc_hdr_info);
	    fnd_message.set_token('RESPONSE',l_header_response);
	    l_document := fnd_message.get;
	    WF_NOTIFICATION.WriteToClob(document,l_document);
	end if;
else
	WF_NOTIFICATION.WriteToClob(document,'GEN_NTF_FOR_SUP_BUY_RP for no html customer');
end if;
exception when others then
	IF g_fnd_debug = 'Y' THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;
	WF_NOTIFICATION.WriteToClob(document,'Exception occured:'||sqlerrm);  */
 null;

END GEN_NTF_FOR_SUP_BUY_RP;

---------------------------------------------------------
--  public
--
--  workflow document procedure to generate notification
--  subject for buyer
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_BUYER_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
IS

l_po_num po_headers_all.segment1%TYPE;
l_supplier_name po_vendors.vendor_name%TYPE;
l_blanket_num po_headers_all.segment1%TYPE;
--l_release_num number;
l_release_num po_releases_all.release_num%TYPE;
l_document_header_info varchar2(2000);
l_type_lookup_code po_headers_all.type_lookup_code%TYPE;
l_global_agreement_flag varchar2(3);
l_header_cancel varchar2(1);
l_id NUMBER;
l_revision_num NUMBER;  -- RDP changes
l_po_total NUMBER;
l_currency_code VARCHAR2(5);
l_rel_revision_num NUMBER;
l_rel_total NUMBER;
l_rel_currency_code VARCHAR2(5);

CURSOR l_header_cancel_csr(grp_id number) IS
    select change_request_id
    from po_change_requests
    where change_request_group_id = grp_id
    and action_type = 'CANCELLATION'
    and request_level = 'HEADER';

l_itemtype VARCHAR2(30);
l_itemkey po_change_requests.wf_item_key%TYPE;
l_header_id NUMBER;
l_release_id NUMBER;
l_chg_req_grp_id NUMBER;
l_ack_req_flag VARCHAR2(30);
l_notif_usage VARCHAR2(30);                -- RDP changes
l_message_name fnd_new_messages.message_name%TYPE;
l_display_name varchar2(1000);
l_msg_header varchar2(1000);

BEGIN

  l_itemtype := 'POSCHORD';
  l_itemkey :=  document_id;

  l_header_id := wf_engine.GetItemAttrNumber(
				    itemtype => l_itemtype,
				    itemkey => l_itemkey,
				    aname => 'PO_HEADER_ID');

  l_release_id := wf_engine.GetItemAttrNumber(
				    itemtype => l_itemtype,
				    itemkey => l_itemkey,
				    aname => 'PO_RELEASE_ID');

  l_chg_req_grp_id := wf_engine.GetItemAttrNumber(
				    itemtype => l_itemtype,
				    itemkey => l_itemkey,
				    aname => 'CHANGE_REQUEST_GROUP_ID');

  l_ack_req_flag := wf_engine.GetItemAttrText(
				    itemtype => l_itemtype,
				    itemkey => l_itemkey,
				    aname => 'ACKNOWLEDGE_REQ_FLAG');

  l_notif_usage := wf_engine.GetItemAttrText(                                -- RDP changes
                                    itemtype => l_itemtype,
                                    itemkey => l_itemKey,
                                    aname => 'NOTIF_USAGE');




  l_header_cancel := 'N';

  IF(l_chg_req_grp_id is not null) THEN
    OPEN l_header_cancel_csr(l_chg_req_grp_id);
    FETCH l_header_cancel_csr
    INTO l_id;
    CLOSE l_header_cancel_csr;
    IF(l_id is not null) THEN
      l_header_cancel := 'Y';
    END IF;
  END IF;

  IF(l_release_id is null) THEN
    select
      pv.vendor_name,
      pha.segment1,
      pha.type_lookup_code,
      pha.GLOBAL_AGREEMENT_FLAG,
      pha.revision_num,
      pos_totals_po_sv.get_po_total(pha.po_header_id),
      pha.currency_code,
      PDSL.DISPLAY_NAME
     into
      l_supplier_name,
      l_po_num,
      l_type_lookup_code,
      l_global_agreement_flag,
      l_revision_num,
      l_po_total,
      l_currency_code,
      l_display_name
     from
      po_headers_all pha,
      po_vendors pv,
      PO_ALL_DOC_STYLE_LINES PDSL
    where pha.po_header_id = l_header_id
	    and pha.vendor_id = pv.vendor_id
	    AND NVL(PHA.STYLE_ID, 0) = PDSL.STYLE_ID (+)
            AND PHA.TYPE_LOOKUP_CODE = PDSL.DOCUMENT_SUBTYPE (+)
            AND PDSL.ENABLED_FLAG (+) = 'Y' AND PDSL.STATUS (+) = 'ACTIVE'
            AND PDSL.LANGUAGE (+) = USERENV('LANG');

  IF( l_display_name IS NULL) THEN
    if(l_type_lookup_code = 'STANDARD') then
      l_message_name := 'PO_WF_NOTIF_STD_PO';
    elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_GA_TYPE';
    elsif(l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_WF_NOTIF_BLANKET';
    elsif(l_type_lookup_code = 'CONTRACT') then
      l_message_name := 'PO_POTYPE_CNTR';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_PLAN_PO';
    else
      return;
    end if;

    fnd_message.set_name('PO', l_message_name);
    l_msg_header := fnd_message.get;
  ELSIF( l_display_name IS NOT NULL) THEN
    l_msg_header := l_display_name;
  END IF;

    --fnd_message.set_token('PO_NUMBER', l_po_num);
  IF (l_notif_usage = 'BUYER_AUTO_FYI') THEN                                         -- RDP if Auto Approved add Auto Approve message
    l_document_header_info := l_msg_header || ' ' || l_po_num || ', ' ||
                              l_revision_num|| ' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')||' '
                              ||TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) ||
                              ' ' || l_currency_code || ') ' || fnd_message.get_string('POS','POS_AUTO_APP_MSG');
    ELSE
        IF(l_type_lookup_code = 'BLANKET') THEN
          l_document_header_info := l_msg_header || ' ' || l_po_num || ', ' || l_revision_num;     -- RDP if Blanket don't display Total
        ELSE
    l_document_header_info := l_msg_header || ' ' || l_po_num || ', ' || l_revision_num|| ' ('||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')
                              ||' '||TO_CHAR(l_po_total, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30))
                              || ' ' || l_currency_code || ') ';
        END IF;
    END IF;

  ELSE  -- l_release_id is not null
    select
	pv.vendor_name,
	pha.segment1,
	pra.release_num,
	pha.type_lookup_code,
	pra.revision_num,
	pos_totals_po_sv.get_release_total(pra.po_release_id),
        pha.currency_code
    into
	l_supplier_name,
	l_blanket_num,
	l_release_num,
	l_type_lookup_code,
	l_rel_revision_num,
	l_rel_total,
        l_rel_currency_code
    from
        po_releases_all pra,
	po_headers_all pha,
	po_vendors pv
    where pra.po_release_id = l_release_id
      and pra.po_header_id = pha.po_header_id
      and pha.vendor_id = pv.vendor_id;

    if(l_type_lookup_code = 'BLANKET')then
      l_message_name := 'PO_WF_NOTIF_BKT_REL2';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_SCH_REL2';
    else
      return;
    end if;

    fnd_message.set_name('PO', l_message_name);
    fnd_message.set_token('BLANKET_NUMBER', l_blanket_num);
    fnd_message.set_token('RELEASE_NUMBER', l_release_num);
   IF (l_notif_usage = 'BUYER_AUTO_FYI') THEN                      -- RDP  generating subject for releases if auto approved
        l_document_header_info := fnd_message.get  || ', ' || l_rel_revision_num ||'('
          ||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')|| ' '|| TO_CHAR(l_rel_total, FND_CURRENCY.GET_FORMAT_MASK(l_rel_currency_code, 30))||' '||l_rel_currency_code||') '|| fnd_message.get_string('POS','POS_AUTO_APP_MSG');
   ELSE
        l_document_header_info :=  fnd_message.get  || ', ' || l_rel_revision_num ||'('
          ||fnd_message.get_string('PO','PO_WF_NOTIF_TOTAL')|| ' '|| TO_CHAR(l_rel_total, FND_CURRENCY.GET_FORMAT_MASK(l_rel_currency_code, 30))||' '||l_rel_currency_code||')';
   END IF;

  END IF;



  IF(l_header_cancel = 'N') THEN
    if(l_ack_req_flag = 'Y') then
      l_message_name := 'PO_WF_NOTIF_ACK_REP_FROM2';
    else
      l_message_name := 'PO_WF_NOTIF_CHN_REQ_FROM2';
    end if;

  ELSE
    l_message_name := 'PO_WF_NOTIF_CANCEL_REQ_FROM';
  END IF;

  fnd_message.set_name('PO', l_message_name);
  fnd_message.set_token('SUPPLIER_NAME', l_supplier_name);
  fnd_message.set_token('HEADER_INFO', l_document_header_info);
  document := fnd_message.get;

END GEN_NTF_FOR_BUYER_SUBJECT;

---------------------------------------------------------
--  public
--
--  workflow document procedure to generate notification
--  subject for supplier
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_SUP_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
IS

l_po_num                                po_headers_all.segment1%TYPE;
l_blanket_num                           po_headers_all.segment1%TYPE;
--l_release_num                           number;
l_release_num po_releases_all.release_num%TYPE;
l_buyer_name                            hr_all_organization_units_tl.name%TYPE;
l_type_lookup_code                      po_headers_all.type_lookup_code%TYPE;
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
l_doc_hdr_info varchar2(2000);

l_id number;
l_header_cancel varchar2(1);
CURSOR l_header_cancel_csr(grp_id number) IS
    select change_request_id
    from po_change_requests
    where change_request_group_id = grp_id
      and action_type = 'CANCELLATION'
      and request_level = 'HEADER';

l_itemtype VARCHAR2(30);
l_itemkey po_change_requests.wf_item_key%TYPE;
l_header_id NUMBER;
l_release_id NUMBER;
l_chg_req_grp_id NUMBER;
l_revision_num NUMBER;
l_display_name varchar2(1000);
l_msg_header varchar2(1000);
l_message_name fnd_new_messages.message_name%TYPE;
-- Bug 8223635. Modified size of the l_temp_message from 30 to 1000
-- in order store longer buyer names.
l_temp_message varchar2(1000);

BEGIN

  l_itemtype := 'POSCHORD';
  l_itemkey :=  document_id;

  l_header_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_HEADER_ID');

  l_release_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_RELEASE_ID');

  l_chg_req_grp_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'CHANGE_REQUEST_GROUP_ID');

  l_revision_num := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_REVISION_NUM');

  l_header_cancel := 'N';
  if(l_chg_req_grp_id is not null) then
    open l_header_cancel_csr(l_chg_req_grp_id);
    fetch l_header_cancel_csr
    into l_id;
    close l_header_cancel_csr;
    if(l_id is not null) then
      l_header_cancel := 'Y';
    end if;
  end if;

  IF(l_release_id is null) THEN
    select pha.segment1,
	   hou.name,
	   pha.type_lookup_code,
	   pha.global_agreement_flag,
	   PDSL.DISPLAY_NAME
    into   l_po_num,
	   l_buyer_name,
	   l_type_lookup_code,
	   l_global_agreement_flag,
	   l_display_name
    from   po_headers_all pha,
	   hr_all_organization_units_tl hou,
	   PO_ALL_DOC_STYLE_LINES PDSL
    where  pha.po_header_id = l_header_id
      and  pha.org_id = hou.organization_id(+)
      and  hou.language(+) = userenv('LANG')
      AND NVL(PHA.STYLE_ID, 0) = PDSL.STYLE_ID (+)
      AND PHA.TYPE_LOOKUP_CODE = PDSL.DOCUMENT_SUBTYPE (+)
      AND PDSL.ENABLED_FLAG (+) = 'Y' AND PDSL.STATUS (+) = 'ACTIVE'
      AND PDSL.LANGUAGE (+) = USERENV('LANG');

 IF(l_display_name IS NULL) THEN
    if(l_type_lookup_code = 'STANDARD') then
      l_message_name := 'PO_WF_NOTIF_STD_PO';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_PLAN_PO';
    elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_GA_TYPE';
    elsif(l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_WF_NOTIF_BLANKET';
    elsif(l_type_lookup_code = 'CONTRACT') then
      l_message_name := 'PO_POTYPE_CNTR';
    else
      RETURN;
    end if;

    fnd_message.set_name('PO', l_message_name);
    l_msg_header := fnd_message.get;
  ELSIF(l_display_name IS NOT NULL) THEN
    l_msg_header := l_display_name;
  END IF;
    --fnd_message.set_token('PO_NUMBER', l_po_num);
     l_doc_hdr_info := l_msg_header || ' ' || l_po_num || ',' || l_revision_num;     -- RDP changes (generating subject for Supplier Notification)

  ELSE
    select pha.segment1,
	   pra.release_num,
	   hou.name,
	   pha.type_lookup_code
    into   l_blanket_num,
	   l_release_num,
	   l_buyer_name,
	   l_type_lookup_code
    from   po_headers_all pha,
	   po_releases_all pra,
	   hr_all_organization_units_tl hou
    where  pra.po_release_id = l_release_id
    and    pha.po_header_id = pra.po_header_id
    and    pha.org_id = hou.organization_id(+)
    and    hou.language(+) = userenv('LANG');

    if(l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_WF_NOTIF_BKT_REL2';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_SCH_REL2';
    else
      RETURN;
    end if;

    fnd_message.set_name('PO', l_message_name);
    fnd_message.set_token('BLANKET_NUMBER', l_blanket_num);
    fnd_message.set_token('RELEASE_NUMBER', l_release_num);
    l_doc_hdr_info := fnd_message.get || ',' || l_revision_num;                     --   RDP changes

  END IF;

  if(l_header_cancel = 'N') then


     /*   fnd_message.set_name('POS','PO_WF_NOTIF_RESP_SUB_CHG');
          fnd_message.set_token('DOC',l_doc_hdr_info);
          fnd_message.set_token('BUYER',l_buyer_name);
          document := fnd_message.get;   */

        l_temp_message := l_buyer_name || ' - ';
        fnd_message.set_name('POS','POS_SUP_RESP_MSG');
        fnd_message.set_token('DOC',l_doc_hdr_info);
        document := l_temp_message ||  fnd_message.get;                             --  RDP changes

  else

     /*   fnd_message.set_name('POS','PO_WF_NOTIF_RESP_SUB_CAN');
          fnd_message.set_token('DOC',l_doc_hdr_info);
          fnd_message.set_token('BUYER',l_buyer_name);
          document := fnd_message.get;     */

        l_temp_message := l_buyer_name || ' - ';
        fnd_message.set_name('POS','POS_SUP_RESP_MSG_CAN');
        fnd_message.set_token('DOC',l_doc_hdr_info);
        document := l_temp_message ||  fnd_message.get;                             --  RDP changes

  end if;

END GEN_NTF_FOR_SUP_SUBJECT;

---------------------------------------------------------
--  public
--
--  workflow document procedure to generate notification
--  subject for planner
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_PLAN_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
IS

l_po_num                                po_headers_all.segment1%TYPE;
l_blanket_num                           po_headers_all.segment1%TYPE;
--l_release_num                           number;
l_release_num                           po_releases_all.release_num%TYPE;
l_supplier_name po_vendors.vendor_name%TYPE;
l_type_lookup_code                      po_headers_all.type_lookup_code%TYPE;
l_document_header_info varchar2(2000);

l_id number;
l_header_cancel varchar2(1);
CURSOR l_header_cancel_csr(grp_id number) IS
    select change_request_id
    from po_change_requests
    where change_request_group_id = grp_id
      and action_type = 'CANCELLATION'
      and request_level = 'HEADER';

l_itemtype VARCHAR2(30);
l_itemkey po_change_requests.wf_item_key%TYPE;
l_header_id NUMBER;
l_release_id NUMBER;
l_chg_req_grp_id NUMBER;

l_message_name fnd_new_messages.message_name%TYPE;
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
l_display_name varchar2(1000);
l_msg_header varchar2(1000);


BEGIN

  l_itemtype := 'POSCHORD';
  l_itemkey :=  document_id;

  l_header_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_HEADER_ID');

  l_release_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_RELEASE_ID');

  l_chg_req_grp_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'CHANGE_REQUEST_GROUP_ID');

  IF(l_release_id is null) THEN
    select pha.type_lookup_code,
           pha.segment1,
	   pv.vendor_name,
	   pha.global_agreement_flag,
	   PDSL.display_name
    into   l_type_lookup_code,
	   l_po_num,
	   l_supplier_name,
	   l_global_agreement_flag,
	   l_display_name
    from   po_headers_all pha,
	   po_vendors pv,
	   PO_ALL_DOC_STYLE_LINES PDSL
    where  pha.po_header_id = l_header_id
    and    pv.vendor_id = pha.vendor_id
    AND NVL(PHA.STYLE_ID, 0) = PDSL.STYLE_ID (+)
    AND PHA.TYPE_LOOKUP_CODE = PDSL.DOCUMENT_SUBTYPE (+)
    AND PDSL.ENABLED_FLAG (+) = 'Y' AND PDSL.STATUS (+) = 'ACTIVE'
    AND PDSL.LANGUAGE (+) = USERENV('LANG');

 IF(l_display_name IS NULL) THEN
    if(l_type_lookup_code = 'STANDARD') then
      l_message_name := 'PO_WF_NOTIF_STD_PO';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_PLAN_PO';
    elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_GA_TYPE';
    elsif(l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_WF_NOTIF_BLANKET';
    elsif(l_type_lookup_code = 'CONTRACT') then
      l_message_name := 'PO_POTYPE_CNTR';
    end if;

    fnd_message.set_name('PO', l_message_name);
    l_msg_header := fnd_message.get;
  ELSIF(l_display_name IS NOT NULL) THEN
    l_msg_header := l_display_name;
  END IF;
    --fnd_message.set_token('PO_NUMBER', l_po_num);
    l_document_header_info := l_msg_header || ' ' || l_po_num;

  ELSE
    select pha.type_lookup_code,
	   pha.segment1,
	   pra.release_num,
	   pv.vendor_name
    into   l_type_lookup_code,
	   l_blanket_num,
	   l_release_num,
	   l_supplier_name
    from   po_headers_all pha,
	   po_releases_all pra,
	   po_vendors pv
    where  pra.po_release_id = l_release_id
    and    pra.po_header_id = pha.po_header_id
    and    pv.vendor_id = pha.vendor_id;

    if(l_type_lookup_code = 'BLANKET')then
      l_message_name := 'PO_WF_NOTIF_BKT_REL2';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_SCH_REL2';
    end if;

    fnd_message.set_name('PO', l_message_name);
    fnd_message.set_token('BLANKET_NUMBER', l_blanket_num);
    fnd_message.set_token('RELEASE_NUMBER', l_release_num);
    l_document_header_info := fnd_message.get;

  END IF;

  l_header_cancel := 'N';
  if(l_chg_req_grp_id is not null) then
    open l_header_cancel_csr(l_chg_req_grp_id);
    fetch l_header_cancel_csr
    into l_id;
    close l_header_cancel_csr;
    if(l_id is not null) then
      l_header_cancel := 'Y';
    end if;
  end if;

  if(l_header_cancel = 'N') then
    l_message_name := 'PO_WF_NOTIF_CHN_REQ_FROM2';
  else
    l_message_name := 'PO_WF_NOTIF_CANCEL_REQ_FROM';
  end if;

  fnd_message.set_name('PO', l_message_name);
  fnd_message.set_token('SUPPLIER_NAME', l_supplier_name);
  fnd_message.set_token('HEADER_INFO', l_document_header_info);
  document := fnd_message.get;

END GEN_NTF_FOR_PLAN_SUBJECT;

---------------------------------------------------------
--  public
--
--  workflow document procedure to generate notification
--  subject for requester
---------------------------------------------------------
PROCEDURE GEN_NTF_FOR_REQ_SUBJECT
  (document_id   IN VARCHAR2,
   display_type  IN VARCHAR2,
   document      IN OUT nocopy VARCHAR2,
   document_type IN OUT nocopy VARCHAR2)
IS

l_po_num                                po_headers_all.segment1%TYPE;
l_blanket_num                           po_headers_all.segment1%TYPE;
--l_release_num                           number;
l_release_num po_releases_all.release_num%TYPE;
l_supplier_name po_vendors.vendor_name%TYPE;
l_type_lookup_code                      po_headers_all.type_lookup_code%TYPE;
l_document_header_info varchar2(2000);

l_id number;
l_header_cancel varchar2(1);
CURSOR l_header_cancel_csr(grp_id number) IS
    select change_request_id
    from po_change_requests
    where change_request_group_id = grp_id
      and action_type = 'CANCELLATION'
      and request_level = 'HEADER';

l_itemtype VARCHAR2(30);
l_itemkey po_change_requests.wf_item_key%TYPE;
l_header_id NUMBER;
l_release_id NUMBER;
l_chg_req_grp_id NUMBER;

l_message_name fnd_new_messages.message_name%TYPE;
l_global_agreement_flag  po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
l_display_name varchar2(1000);
l_msg_header varchar2(1000);

BEGIN

  l_itemtype := 'POSCHORD';
  l_itemkey :=  document_id;

  l_header_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_HEADER_ID');

  l_release_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'PO_RELEASE_ID');

  l_chg_req_grp_id := wf_engine.GetItemAttrNumber(
                                    itemtype => l_itemtype,
                                    itemkey => l_itemkey,
                                    aname => 'CHANGE_REQUEST_GROUP_ID');

  IF(l_release_id is null) THEN
    select pha.type_lookup_code,
	   pha.segment1,
	   pv.vendor_name,
	   pha.global_agreement_flag,
	   PDSL.display_name
    into   l_type_lookup_code,
	   l_po_num,
	   l_supplier_name,
	   l_global_agreement_flag,
	   l_display_name
    from   po_headers_all pha,
	   po_vendors pv,
	   PO_ALL_DOC_STYLE_LINES PDSL
    where  pha.po_header_id = l_header_id
    and    pv.vendor_id = pha.vendor_id
           AND NVL(PHA.STYLE_ID, 0) = PDSL.STYLE_ID (+)
           AND PHA.TYPE_LOOKUP_CODE = PDSL.DOCUMENT_SUBTYPE (+)
           AND PDSL.ENABLED_FLAG (+) = 'Y' AND PDSL.STATUS (+) = 'ACTIVE'
           AND PDSL.LANGUAGE (+) = USERENV('LANG');

 IF(l_display_name IS NULL) THEN
    if(l_type_lookup_code = 'STANDARD') then
      l_message_name := 'PO_WF_NOTIF_STD_PO';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_PLAN_PO';
    elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_GA_TYPE';
    elsif(l_type_lookup_code = 'BLANKET') then
      l_message_name := 'PO_WF_NOTIF_BLANKET';
    elsif(l_type_lookup_code = 'CONTRACT') then
      l_message_name := 'PO_POTYPE_CNTR';
    end if;

    fnd_message.set_name('PO', l_message_name);
    l_msg_header := fnd_message.get;
 ELSIF(l_display_name IS NOT NULL) THEN
    l_msg_header := l_display_name;
 END IF;
    --fnd_message.set_token('PO_NUMBER', l_po_num);
    l_document_header_info := l_msg_header || ' ' || l_po_num;

  ELSE
    select pha.type_lookup_code,
	   pha.segment1,
	   pra.release_num,
	   pv.vendor_name
    into   l_type_lookup_code,
	   l_blanket_num,
	   l_release_num,
	   l_supplier_name
    from   po_headers_all pha,
	   po_releases_all pra,
	   po_vendors pv
    where  pra.po_release_id = l_release_id
    and    pra.po_header_id = pha.po_header_id
    and    pv.vendor_id = pha.vendor_id;

    if(l_type_lookup_code = 'BLANKET')then
      l_message_name := 'PO_WF_NOTIF_BKT_REL2';
    elsif(l_type_lookup_code = 'PLANNED') then
      l_message_name := 'PO_WF_NOTIF_SCH_REL2';
    end if;

    fnd_message.set_name('PO', l_message_name);
    fnd_message.set_token('BLANKET_NUMBER', l_blanket_num);
    fnd_message.set_token('RELEASE_NUMBER', l_release_num);
    l_document_header_info := fnd_message.get;

  end if;

  l_header_cancel := 'N';
  if(l_chg_req_grp_id is not null) then
    open l_header_cancel_csr(l_chg_req_grp_id);
    fetch l_header_cancel_csr
    into l_id;
    close l_header_cancel_csr;
    if(l_id is not null) then
      l_header_cancel := 'Y';
    end if;
  end if;

  if(l_header_cancel = 'N') then
    l_message_name := 'PO_WF_NOTIF_CHN_REQ_FROM2';
  else
    l_message_name := 'PO_WF_NOTIF_CANCEL_REQ_FROM';
  end if;

  fnd_message.set_name('PO', l_message_name);
  fnd_message.set_token('SUPPLIER_NAME', l_supplier_name);
  fnd_message.set_token('HEADER_INFO', l_document_header_info);
  document := fnd_message.get;

END GEN_NTF_FOR_REQ_SUBJECT;

/*
*Prorate is needed if supplier has changed the Quantity of a PO SHipment,Price of a Shipment of FPS Type  with multiple distributions.
*/
procedure IS_PRORATE_NEEDED(		  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
l_chg_req_grp_id number;
l_po_header_id number;
l_temp number;
x_progress varchar2(3) := '000';
cursor l_x_csr(id number) is
select pcr.document_line_locatiON_id
from    po_change_requests pcr,
	po_distributions_all pda
where pcr.document_line_location_id = pda.line_location_id
and pcr.change_request_group_id = id                                      -- added checks FPS Shipment Amount, Shipment price Prorate
and (pcr.new_quantity is not null or pcr.new_amount is not null or  pcr.new_price is not null)
group by pcr.document_line_location_id
having count(1) > 1;
l_header_change number;
l_retro_count number;

BEGIN
    l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');

    l_po_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_HEADER_ID');

    select count(*) into l_retro_count
    from po_change_requests pcr, po_headers_all poh
    where poh.po_header_id = pcr.document_header_id
    and poh.po_header_id = l_po_header_id
    and poh.type_lookup_code = 'BLANKET'
    and pcr.change_request_group_id = l_chg_req_grp_id
    and pcr.po_release_id is null
    and pcr.request_level in ('LINE', 'SHIPMENT')
    and pcr.action_type='MODIFICATION'
    and ((pcr.new_price is not null) or (pcr.new_quantity is not null))
    and pcr.request_status in ('PENDING');

    open l_x_csr(l_chg_req_grp_id);
    fetch l_x_csr into l_temp;
    close l_x_csr;

	select count(*)
	into l_header_change
	from po_change_requests
	where change_request_group_id = l_chg_req_grp_id
	and request_level = 'HEADER'
	and additional_changes is not null;

    if(l_temp is not null or l_header_change > 0 or l_retro_count > 0) then
		resultout := 'Y';
		wf_engine.SetItemAttrText(itemtype => itemtype,     -- RDP if PRORATE,ADIITIONAL CHANGES , set the NOTIF_USAGE as BUYER_FYI
		                          itemkey => itemkey,
		                          aname => 'NOTIF_USAGE',
                                          avalue => 'BUYER_FYI');


		if(l_header_change = 0) then                        -- RDP means no ADDITIONAL changes but PRORATE is required, set EXPLAIN_FYI
		    wf_engine.SetItemAttrText (   itemtype   => itemtype,
		                                  itemkey    => itemkey,
		                                  aname      => 'EXPLAIN_FYI',
		                                  avalue     => fnd_message.get_string('PO','PO_WF_NOTIF_EXPLAIN_FYI'));
		else
		    wf_engine.SetItemAttrText (   itemtype   => itemtype,
		                                  itemkey    => itemkey,
		                                  aname      => 'EXPLAIN_FYI',
		                                  avalue     => '');
		end if;

	else
		resultout := 'N';
	    wf_engine.SetItemAttrText (   itemtype   => itemtype,
	                                  itemkey    => itemkey,
	                                  aname      => 'EXPLAIN_FYI',
	                                  avalue     => '');

	end if;
exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','IS_PRORATE_NEEDED',x_progress);
    raise;
END IS_PRORATE_NEEDED;

/*
*update authorization_status of PO to "APPROVED".
*/
procedure CHG_STATUS_TO_APPROVED(	  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
l_header_id number;
l_release_id number;
l_revision_num number;
l_chg_req_grp_id number;
l_add_changes_accepted number;
l_responded_by number;
l_authorization_status po_headers_all.authorization_status%TYPE;
l_check_result varchar2(1);

x_progress varchar2(3) := '000';
BEGIN

    l_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_HEADER_ID');
    l_release_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_RELEASE_ID');
    l_revision_num := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_REVISION_NUM');
     l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');


      l_authorization_status := 'APPROVED';

                select count(*)
                into l_add_changes_accepted
                from po_change_requests
                where change_request_group_id = l_chg_req_grp_id
                -- and request_status = 'ACCEPTED'
                and request_status = 'BUYER_APP'     /* fix for bug 3691061 */
                and request_level = 'HEADER'
                and additional_changes is not null;

                if (l_add_changes_accepted > 0) then
                   l_authorization_status := 'REQUIRES REAPPROVAL';
                end if;

      if (l_authorization_status = 'REQUIRES REAPPROVAL') then

        select max(responded_by) into l_responded_by
        from po_change_requests
        where request_level = 'HEADER'
        -- and request_status = 'ACCEPTED'
        and request_status = 'BUYER_APP'         /* fix for bug 3691061 */
        and additional_changes is not null
        and change_request_group_id = l_chg_req_grp_id;

        if (l_responded_by = 0) then
          l_responded_by :=  null;
        end if;

        if(l_release_id is not null) then

          update po_releases_all set
          authorization_status = 'REQUIRES REAPPROVAL',
          revision_num = revision_num + 1,
          revised_date = sysdate,
          last_update_date = sysdate,
          last_updated_by = nvl(l_responded_by, last_updated_by),
          change_requested_by = null,
          approved_flag = 'R'
          where po_release_id = l_release_id;

        else

          update po_headers_all set
          authorization_status = 'REQUIRES REAPPROVAL',
          revision_num = revision_num + 1,
          revised_date = sysdate,
          last_update_date = sysdate,
          last_updated_by = nvl(l_responded_by, last_updated_by),
          change_requested_by = null,
          approved_flag = 'R'
          where po_header_id = l_header_id;

        end if;

      else  -- authorization status is approved

      -- added due to bug 3574114
      update po_change_requests
      set change_active_flag = 'N'
      where change_request_group_id = l_chg_req_grp_id;

	if(l_release_id is not null) then
		update po_releases_all
		set authorization_status = l_authorization_status,
		change_requested_by = null
		where po_release_id = l_release_id;
	else
		update po_headers_all
		set authorization_status = l_authorization_status,
		change_requested_by = null
		where po_header_id = l_header_id;
	end if;


	x_progress := '002';

        /* Bug 3534807, mji
           Check if all shipments has been acknowledged, if yes post header
           acknowledgement record.
        */
        PO_ACKNOWLEDGE_PO_GRP.Set_Header_Acknowledgement (
    		1.0,
    		FND_API.G_FALSE,
		l_check_result,
		l_header_id,
		l_release_id );

	x_progress := '003';


      end if;

exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','CHG_STATUS_TO_APPROVED',x_progress);
    raise;
END CHG_STATUS_TO_APPROVED;


/*
*Supplier could have changed and accepted shipments at the same time. Once the change requests are responded, we will need
*to carry over the previously accepted shipments to the new revision, by Calling
*PO_ACKNOWLEDGE_PO_GRP.carry_over_acknowledgement
*/
procedure CARRY_SUP_ACK_TO_NEW_REV(	  	itemtype        in varchar2,
			                           	itemkey         in varchar2,
    	    		                   	actid           in number,
	    	        		         	funcmode        in varchar2,
            	            		    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type po_document_types_all.document_type_code%TYPE;
l_header_id number;
l_release_id number;
l_revision_num number;
x_progress varchar2(3) := '000';
l_carryover_status varchar2(1);
l_carryover_exception exception;
BEGIN

    l_document_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');
	x_progress := '001';
    if(l_document_type = 'RELEASE') then
    	l_header_id := null;
    	l_release_id := l_document_id;
    	select revision_num
    	into l_revision_num
    	from po_releases_all
    	where po_release_id = l_document_id;
    else
    	l_header_id := l_document_id;
    	l_release_id := null;
    	select revision_num
    	into l_revision_num
    	from po_headers_all
    	where po_header_id = l_document_id;
    end if;
    x_progress := '002';
        /*PO_ACKNOWLEDGE_PO_GRP.carry_over_acknowledgement(1.0,
                                                                                                        FND_API.G_FALSE,
                                                                                                        l_carryover_status,
                                                                                                        l_header_id ,
                                                                                                        l_release_id ,
                                                                                                        l_revision_num);*/
    /*Bug 7205793: Added an internal procedure, which is an autonomous transaction
                   to avoid deadlock during PO Approval Process. */
    Carry_Over_Acknowledgement( l_carryover_status,
                                l_header_id,
                                l_release_id,
                                l_revision_num);

exception when others then
        wf_core.context('PO_ChangeOrderWF_PVT','CARRY_SUP_ACK_TO_NEW_REV',x_progress);
    raise;
END CARRY_SUP_ACK_TO_NEW_REV;

/*
*Checks if acceptance_required_flag = 'Y'
*/
procedure DOES_PO_REQ_SUP_ACK(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type po_document_types_all.document_type_code%TYPE;
l_acc_flag varchar2(1);
x_progress varchar2(3) := '000';
BEGIN
    l_document_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');

	if(l_document_type = 'RELEASE') then
		select acceptance_required_flag
		into l_acc_flag
		from po_releases_all
		where po_release_id = l_document_id;
	else
		select acceptance_required_flag
		into l_acc_flag
		from po_headers_all
		where po_header_id = l_document_id;
	end if;
	if(l_acc_flag= 'Y') then
		resultout := 'Y';
	else
		resultout := 'N';
	END if;

exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','DOES_PO_REQ_SUP_ACK',x_progress);
    raise;
END DOES_PO_REQ_SUP_ACK;

/*
*Checks if PO Change request is approved/rejected by the PO Approval Hierachy.
*Meanwhile, prepare the notification which is to be sent to the supplier, informing him/her of buyer's response to
*Supplier's Change request
*Note:  Also sets the request_group_id value into the wf attribute
*       which is useful for the later activities.
*/
procedure is_po_approved_by_hie( itemtype  in varchar2,
                                 itemkey   in varchar2,
                                 actid     in number,
                                 funcmode  in varchar2,
                                 resultout out NOCOPY varchar2)
IS
  l_document_id                number;
  p_header_id                  number;
  l_document_type              po_document_types_all.document_type_code%TYPE;
  l_authorization_status       po_headers_all.authorization_status%TYPE;
  l_acceptance_required_flag   po_headers_all.acceptance_required_flag%TYPE;   -- fix for bug 4946410
  l_supplier_user_id           number;
  l_change_request_group_id    number;
  l_supplier_username          fnd_user.user_name%TYPE;
  l_blanket_num                po_headers_all.segment1%TYPE;
  --l_release_num              number;
  l_release_num                po_releases_all.release_num%TYPE;
  l_buyer_name                 hr_all_organization_units_tl.name%TYPE;
  l_po_num                     po_headers_all.segment1%TYPE;
  l_revision_num               number;
  l_revision_num2              number;
  l_notification_subject       varchar2(2000);
  l_type_lookup_code           po_headers_all.type_lookup_code%TYPE;
  l_doc_hdr_info               varchar2(1000);
  l_buyer_agent_id             number;
  l_responded_by_id            number;
  l_buyer_username             fnd_user.user_name%TYPE;
  l_buyer_disp_name            varchar2(2000);
  l_po_style                   varchar2(10);
  x_return_status              varchar2(1);
  x_complex_flag               varchar2(1);

  -- Bug 6722239 - Start
  /*
  Added the following variables
  l_role_name          -> Adhoc Role Name Created
  l_vendor_id          -> Supplier Id
  l_role_display_name  -> Supplier_Name which need to be displayed in the Notification
                          sent to supplier for buyer's response
  l_expiration_date    -> Notification Expiry Date
  l_user_name          -> Supplier User Name who modified the purchase order
  l_users              -> Users list in the form of userTable to create an Adhoc role
  x_resultout          -> Variable to set the role in the Workflow file
  t_document_type      -> Temporary Variable used to store the document type
  */

  l_role_name                  WF_USER_ROLES.ROLE_NAME%TYPE;
  l_role_display_name          varchar2(100):=null;
  l_expiration_date            DATE;
  l_vendor_id                  NUMBER;
  x_resultout                  varchar2(100):=null;
  l_users                      WF_DIRECTORY.UserTable;
  l_user_name                  varchar2(100);
  t_document_type              po_document_types_all.document_type_code%TYPE := null;
  u1                           pls_integer := 0;
  --Bug 6722239 - End

  x_progress                   varchar2(100) := '000';
  t_varname                    Wf_Engine.NameTabTyp;
  t_varval                     Wf_Engine.TextTabTyp;
  l_global_agreement_flag      po_headers_all.GLOBAL_AGREEMENT_FLAG%TYPE := 'F';
  l_po_header_id               po_headers_all.po_header_id%TYPE;
  l_id                         number;
  l_header_cancel              varchar2(1);

  cursor l_header_cancel_csr(grp_id number) is
    select change_request_id
    from po_change_requests
    where change_request_group_id = grp_id
    and action_type = 'CANCELLATION'
    and request_level = 'HEADER';

  /*
  Collecting the accepted line location ids for which changes were made during
  Acknowledgement process.
  */
  l_line_loc_id                 number;
  l_user_id                     number;

  -- Bug 6722239 - Start
  /*
  Added the Following Cursor; This will get the list of supplier users
  who have done the changes to the purchase order during the process of
  PO Acknowledgement.
  */
  cursor l_get_user_list_csr(x_document_id NUMBER,x_document_type varchar2) is
    select distinct created_by ,
    change_request_group_id
    from po_change_requests
    where request_status in ('BUYER_APP', 'WAIT_CANCEL_APP')
    and ((document_header_id = x_document_id) OR (po_release_id = x_document_id))
    and initiator = 'SUPPLIER'
    and document_type = x_document_type;
  --Bug 6722239 - End

  CURSOR getLineLocID(l_chg_req_grp_id_csr IN NUMBER) IS
    SELECT document_line_location_id
    FROM PO_CHANGE_REQUESTS
    WHERE change_request_group_id = l_chg_req_grp_id_csr
    AND request_level = 'SHIPMENT'
    AND request_status = 'BUYER_APP'
    AND (NEW_AMOUNT is not null OR NEW_QUANTITY is not null);

  /* Curosr to get the change_responded by*/
  CURSOR getChangeRespBy(l_chg_req_grp_id_csr IN NUMBER) IS
    SELECT distinct fndu.employee_id
    FROM   po_change_requests pcr,
    fnd_user fndu
    WHERE  pcr.change_request_group_id = l_chg_req_grp_id_csr
    AND fndu.user_id = pcr.responded_by;

BEGIN
  l_document_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                               itemkey => itemkey,
                                               aname => 'DOCUMENT_ID');

  l_document_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey => itemkey,
                                               aname => 'DOCUMENT_TYPE');

  if(l_document_type = 'RELEASE') then
    -- Bug 6722239 - Start
    -- Added a cursor above to fetch multiple records
    /*
    select distinct created_by,
                    change_request_group_id
    into l_supplier_user_id ,
         l_change_request_group_id
    from po_change_requests
    where request_status in ('BUYER_APP', 'WAIT_CANCEL_APP')
    and po_release_id = l_document_id
    and initiator = 'SUPPLIER'
    and document_type = 'RELEASE';
    */
    -- Bug 6722239 - End

    select pha.segment1,
           pha.po_header_id,                                 --    RDP changes
           pra.release_num,
           pra.revision_num,                                 --    RDP changes
           hou.name,
           pra.authorization_status,
           pha.type_lookup_code,
           pra.agent_id,
           pha.vendor_id,
           pra.acceptance_required_flag                      -- bug 4868859
    into   l_blanket_num,
           l_po_header_id,
           l_release_num,
           l_revision_num,
           l_buyer_name ,
           l_authorization_status,
           l_type_lookup_code,
           l_buyer_agent_id,
           l_vendor_id,
           l_acceptance_required_flag
    from   po_headers_all pha,
           po_releases_all pra,
           hr_all_organization_units_tl hou
    where  pra.po_release_id = l_document_id
    and pha.po_header_id = pra.po_header_id
    and pha.org_id = hou.organization_id(+)
    and hou.language(+) = userenv('LANG');

    select revision_num
    into l_revision_num2
    from po_releases_archive_all
    where po_release_id = l_document_id
    and latest_external_flag='Y';

    l_header_cancel := 'N';
    if(l_change_request_group_id is not null) then
      open l_header_cancel_csr(l_change_request_group_id);
      fetch l_header_cancel_csr
      into l_id;
      close l_header_cancel_csr;
      if(l_id is not null) then
        l_header_cancel := 'Y';
      end if;
    end if;

    if(l_type_lookup_code = 'PLANNED') then
      l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_SCH_REL')||' '||l_blanket_num||'-'||l_release_num;
    elsif(l_type_lookup_code = 'BLANKET') then
      l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_BKT_REL')||' '||l_blanket_num||'-'||l_release_num;
    end if;

    if(l_header_cancel = 'N') then
      fnd_message.set_name('PO','PO_WF_NOTIF_RESP_SUB_CHG');
      fnd_message.set_token('DOC',l_doc_hdr_info);
      fnd_message.set_token('BUYER',l_buyer_name);
      l_notification_subject := fnd_message.get;
    else
      fnd_message.set_name('PO','PO_WF_NOTIF_RESP_SUB_CAN');
      fnd_message.set_token('DOC',l_doc_hdr_info);
      fnd_message.set_token('BUYER',l_buyer_name);
      l_notification_subject := fnd_message.get;
    end if;

    /*
    update po_releases_all
    set change_requested_by = null
    where po_release_id = l_document_id;
    */

    Update_Chg_Req_If_Po_Apprvd(null,l_document_id);

    PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'PO_RELEASE_ID',
                                      avalue     => l_document_id);

    PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'PO_REVISION_NUM',
                                      avalue   => l_revision_num2);

     PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'PO_HEADER_ID',
                                       avalue     => l_po_header_id);

   else
     -- Bug 6722239 - Start
     -- Added a cursor above to fetch multiple records
     /*
     select distinct created_by ,
                     change_request_group_id
     into l_supplier_user_id  ,
          l_change_request_group_id
     from po_change_requests
     where request_status in ('BUYER_APP', 'WAIT_CANCEL_APP')
     and document_header_id = l_document_id
     and initiator = 'SUPPLIER'
     and document_type = 'PO';
     */
     -- Bug 6722239 - End

     select pha.segment1,
            hou.name,
            pha.authorization_status,
            pha.revision_num,
            pha.type_lookup_code,
            pha.agent_id,
            pha.GLOBAL_AGREEMENT_FLAG,
            pha.vendor_id,
            pha.acceptance_required_flag
      into  l_po_num,
            l_buyer_name,
            l_authorization_status,
            l_revision_num,
            l_type_lookup_code,
            l_buyer_agent_id,
            l_global_agreement_flag,
            l_vendor_id,
            l_acceptance_required_flag
      from  po_headers_all pha,
            hr_all_organization_units_tl hou
      where pha.po_header_id = l_document_id
      and pha.org_id = hou.organization_id(+)
      and hou.language(+) = userenv('LANG');

      select revision_num
      into l_revision_num2
      from po_headers_archive_all
      where po_header_id=l_document_id
      and latest_external_flag='Y';

      l_header_cancel := 'N';
      if(l_change_request_group_id is not null) then
        open l_header_cancel_csr(l_change_request_group_id);
        fetch l_header_cancel_csr
        into l_id;
        close l_header_cancel_csr;
        if(l_id is not null) then
          l_header_cancel := 'Y';
        end if;
      end if;

      if(l_type_lookup_code = 'STANDARD') then
        l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_STD_PO')||' '||l_po_num;
      elsif (l_global_agreement_flag = 'Y' and l_type_lookup_code = 'BLANKET') then
        l_doc_hdr_info := fnd_message.get_string('PO','PO_GA_TYPE') ||' '||l_po_num;
      elsif(l_type_lookup_code = 'BLANKET') then
        l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_BLANKET')||' '||l_po_num;
      elsif(l_type_lookup_code = 'CONTRACT') then
        l_doc_hdr_info := fnd_message.get_string('PO','PO_POTYPE_CNTR')||' '||l_po_num;
      elsif(l_type_lookup_code = 'PLANNED') then
        l_doc_hdr_info := fnd_message.get_string('PO','PO_WF_NOTIF_PLAN_PO')||' '||l_po_num;
      end if;

      if(l_header_cancel = 'N') then
        fnd_message.set_name('PO','PO_WF_NOTIF_RESP_SUB_CHG');
        fnd_message.set_token('DOC',l_doc_hdr_info);
        fnd_message.set_token('BUYER',l_buyer_name);
        l_notification_subject := fnd_message.get;
      else
        fnd_message.set_name('PO','PO_WF_NOTIF_RESP_SUB_CAN');
        fnd_message.set_token('DOC',l_doc_hdr_info);
        fnd_message.set_token('BUYER',l_buyer_name);
        l_notification_subject := fnd_message.get;
      end if;

      /*
      update po_headers_all
      set change_requested_by = null
      where po_header_id = l_document_id;
      */

      Update_Chg_Req_If_Po_Apprvd(l_document_id,null);

      PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'PO_HEADER_ID',
                                        avalue => l_document_id);

       PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PO_REVISION_NUM',
                                         avalue   => l_revision_num2);

     end if;  --end of if on l_doc_type

     -- Bug 6722239 - Start
     /* Added a cursor to fetch multiple records. Previous code was not capable of holding more than one record if
     fetched FROM database. Because of the cursor multiple records can be stored from which supplier user names
     will be fetched. So, the notifications will be send to all the supplier users who have done the modification
     to the PO during PO Acknowledgement process.*/

     if(l_document_type = 'RELEASE') THEN
       t_document_type := 'RELEASE';
     ELSE
       t_document_type := 'PO';
     END IF;

     open l_get_user_list_csr(l_document_id,t_document_type);
       loop
         fetch l_get_user_list_csr INTO
           l_supplier_user_id  ,
           l_change_request_group_id;
         exit when l_get_user_list_csr%NOTFOUND;
         select user_name
         INTO l_user_name
         from fnd_user
         where user_id = l_supplier_user_id;
         l_users(u1) := l_user_name;
         u1 := u1 + 1;
       end loop;
     close l_get_user_list_csr;
     -- Bug 6722239 - End

     x_progress := '001';

     PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CHANGE_REQUEST_GROUP_ID',
                                       avalue     => l_change_request_group_id);

     -- fix for bug 4946410 added signature flag check( these po's are blocked and changed to 'APPROVED' after background process is run
     if((l_authorization_status = 'APPROVED') OR (l_authorization_status = 'PRE-APPROVED' AND l_acceptance_required_flag = 'S')) then
       resultout := 'Y';
       l_user_id := FND_GLOBAL.USER_ID;
       -- For those records which has been approved default the promised date
       if(l_authorization_status = 'APPROVED' AND l_acceptance_required_flag = 'Y' AND g_default_promise_date  = 'Y') THEN
         OPEN getLineLocID(l_change_request_group_id);
           LOOP
             FETCH getLineLocID INTO l_line_loc_id;
             EXIT WHEN getLineLocID%NOTFOUND;
             IF(l_document_type = 'RELEASE') THEN
               POS_ACK_PO.Acknowledge_promise_date(l_line_loc_id,l_po_header_id,l_document_id,l_revision_num,l_user_id);
             ELSE
               POS_ACK_PO.Acknowledge_promise_date(l_line_loc_id,l_document_id,null,l_revision_num,l_user_id);
             END IF;
           END LOOP;
         CLOSE getLineLocID;
       end if;

       update po_change_requests
       set request_status = 'ACCEPTED'
       where change_request_group_id = l_change_request_group_id
       and request_status in ('BUYER_APP', 'WAIT_CANCEL_APP');

       /* added code for bug 3574114 - update change active flag due to final buyer response */

       update po_change_requests
       set change_active_flag = 'N'
       where change_request_group_id = l_change_request_group_id;

     else
       resultout := 'N';

       update po_change_requests
       set request_status = 'REJECTED',
       response_reason = null
       where change_request_group_id = l_change_request_group_id
       and request_status in ('BUYER_APP', 'WAIT_CANCEL_APP');

       /* added code for bug 3574114 - update change active flag due to final buyer response */

       update po_change_requests
       set change_active_flag = 'N'
       where change_request_group_id = l_change_request_group_id;

     END if;


     x_progress := '002';
     -- Bug 6722239 - Start
     -- Commented the below code because the new changes will send
     -- notification to the role instead of a single supplier.

     /*
     select user_name
     into l_supplier_username
     from fnd_user
     where user_id = l_supplier_user_id;
     */

     /*Following code creates and Adhoc role for all the supplier users who have done
     some modification to the Purchase order during PO Acknowledgement process.
     l_role_name         -> Adhoc role name created for the above mentioned users
     l_role_display_name -> Name which need to be mentioned in the Notification
     l_expiration_date   -> Expiry date of the notification
     CreateAdHocRole2    -> Takes the above parameters as input and creates an Adhoc role.
     x_resultout         -> Variable used to set the Performer in the Workflow.
     */

     l_role_name := substr('ADHOC_SUP_CHG_RESP' || to_char(sysdate, 'JSSSSS')|| l_document_id || l_document_type, 1, 50);

     select vendor_name
     into l_role_display_name
     from po_vendors
     where vendor_id=l_vendor_id;

     if (l_document_type in ('PO', 'PA')) then
       select max(need_by_date)+180
       into l_expiration_date
       from po_line_locations
       where po_header_id = to_number(l_document_id)
       and cancel_flag = 'N';

       if l_expiration_date <= sysdate then
         l_expiration_date := sysdate + 180;
       end if;
     elsif (l_document_type = 'RELEASE') then
       select max(need_by_date)+180
       into l_expiration_date
       from po_line_locations
       where po_release_id = to_number(l_document_id)
       and cancel_flag = 'N';

       if l_expiration_date <= sysdate then
         l_expiration_date := sysdate + 180;
       end if;
     else
       l_expiration_date:=null;
     end if;

     WF_DIRECTORY.CreateAdHocRole2(l_role_name,
                                   l_role_display_name,
                                   null,
                                   null,
                                   null,
                                   'MAILHTML',
                                   l_users,
                                   null,
                                   null,
                                   'ACTIVE',
                                   l_expiration_date);
     x_resultout:=l_role_name;
     -- Bug 6722239 - End

     /* Bug 4949617 get the reponded_by id from po_change_requests table */
     OPEN getChangeRespBy(l_change_request_group_id);
       LOOP
         FETCH getChangeRespBy INTO l_responded_by_id;
         EXIT WHEN getChangeRespBy%NOTFOUND;
       END LOOP;
     CLOSE getChangeRespBy;

     IF(l_responded_by_id = l_buyer_agent_id) THEN
       wf_directory.GetUserName ( p_orig_system    => 'PER',
                                  p_orig_system_id => l_buyer_agent_id,
                                  p_name           => l_buyer_username,
                                  p_display_name   => l_buyer_disp_name);
     ELSE
       wf_directory.GetUserName ( p_orig_system    => 'PER',
                                  p_orig_system_id => l_responded_by_id,
                                  p_name           => l_buyer_username,
                                  p_display_name   => l_buyer_disp_name);
     END IF;

     if(l_document_type = 'RELEASE' OR l_document_type = 'PA') THEN
       l_po_style := 'NORMAL';
     elsif(l_document_type = 'PO') THEN
       p_header_id := l_document_id;

       /*
       PO- API  set item attribute PO_STYLE_TYPE depending upon the type of the PO
       PO_STYLE_TYPE - COMPLEX ,complex work PO's
       PO_STYLE_TYPE - NORMAL
       */

       PO_COMPLEX_WORK_GRP.is_complex_work_po(1.0,
                                              p_header_id,
                                              x_return_status,
                                              x_complex_flag);

       IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
         IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                          g_module_prefix,
                          x_progress || 'x_return_status=' || x_return_status || 'x_complex_flag ' || x_complex_flag);
         END IF;

       ELSE
         IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                          g_module_prefix,
                          x_progress ||'x_return_status = ' || x_return_status);
         END IF;
       END IF;

       IF (x_complex_flag = 'N') THEN
         l_po_style :='NORMAL';
       ELSE
         l_po_style := 'COMPLEX';
       END IF;
     end if;

     t_varname(1) := 'NTF_FOR_SUP_SUBJECT';
     t_varval(1)  := 'PLSQL:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_SUP_SUBJECT/'||itemkey;
     t_varname(2) := 'NTF_FOR_SUP_BUY_RP';
     -- RDP set the item Attribute to point to the notifications page
     t_varval(2)  := 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/notifications/webui/PosNotificationsRN'||
     '&L_CHG_REQ_GRP_ID=-&CHANGE_REQUEST_GROUP_ID-&L_PO_HEADER_ID=-&PO_HEADER_ID-&L_PO_RELEASE_ID=-&PO_RELEASE_ID-'||
     '&L_PO_ACC_REQ_FLAG=-&ACKNOWLEDGE_REQ_FLAG-&L_NOTIF_USAGE=-&NOTIF_USAGE-&L_EXPLAIN_FYI=-&EXPLAIN_FYI-&L_STYLE_PARAM=-&PO_STYLE_TYPE-';
     t_varname(3) := 'SUPPLIER_USERNAME';
     --t_varval(3)  := l_supplier_username;
     t_varval(3)  := x_resultout;
     t_varname(4) := 'FROM_BUYER';
     t_varval(4)  := l_buyer_username;
     t_varname(5)  := 'NOTIF_USAGE';
     t_varval(5)  := 'BUYER_RESP';
     t_varname(6)  := 'PO_STYLE_TYPE';
     t_varval(6)   := l_po_style;

     Wf_Engine.SetItemAttrTextArray(itemtype, itemkey,t_varname,t_varval);

exception when others then
  wf_core.context('PO_ChangeOrderWF_PVT','is_po_approved_by_hie',x_progress);
  raise;
END is_po_approved_by_hie;


procedure set_data_sup_chn_evt(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type po_document_types_all.document_type_code%TYPE;
l_seq number;
l_item_key varchar2(2000);
x_progress varchar2(3) := '000';
BEGIN
    l_document_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');



	select PO_SUPPLIER_CHANGE_WF_S.nextval into l_seq from dual;

	if(l_document_type = 'RELEASE') then
		l_item_key := 'SC_REL'||'-'||l_document_id||'-'||l_seq;
	else
		l_item_key := 'SC_PO'||'-'||l_document_id||'-'||l_seq;
	end if;


    wf_engine.SetItemAttrText (   itemtype   => itemtype,
                                  itemkey    => itemkey,
                                  aname      => 'SUP_CHANGE_EVENT_KEY',
                                  avalue     => l_item_key );


exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','set_data_sup_chn_evt',x_progress);
    raise;
END set_data_sup_chn_evt;


procedure ANY_NEW_SUP_CHN(	  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_chg_req_grp_id number;
l_header_id number;
l_release_id number;
l_doc_id number;
l_doc_type po_document_types_all.document_type_code%TYPE;
l_doc_subtype po_document_types_all.document_subtype%TYPE;
l_employee_id number;
l_acc_req_flag VARCHAR2(10);

x_progress varchar2(3) := '000';
cursor l_change_csr(grp_id number) is
select change_request_id from
po_change_requests
where action_type = 'MODIFICATION'
and change_request_group_id = grp_id;

BEGIN
	l_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_HEADER_ID');
	l_release_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_RELEASE_ID');

        l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');
        l_acc_req_flag  :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey => itemkey,
                                                      aname => 'ACKNOWLEDGE_REQ_FLAG');


	if(l_release_id is null) then
		l_doc_id := l_header_id;
		select
			type_lookup_code,
			agent_id
		into
			l_doc_subtype,
			l_employee_id
		from po_headers_all
		where po_header_id = l_header_id;

		if(l_doc_subtype = 'BLANKET' or l_doc_subtype = 'CONTRACT') then
			l_doc_type := 'PA';
		elsif(l_doc_subtype in ('PLANNED','STANDARD')) then
			l_doc_type := 'PO';
		end if;
	else
		l_doc_id := l_release_id;
		l_doc_type := 'RELEASE';
		select
			pha.type_lookup_code,
			pra.agent_id
		into
			l_doc_subtype,
			l_employee_id
		from po_headers_all pha, po_releases_all pra
		where pra.po_release_id = l_release_id
		and pra.po_header_id = pha.po_header_id;
	end if;
	x_progress := '001';
    if(l_chg_req_grp_id is null) then
    	resultout := 'N';
	    wf_engine.SetItemAttrText (   itemtype   => itemtype,
	                                  itemkey    => itemkey,
	                                  aname      => 'EXPLAIN_FYI',
	                                  avalue     => '');

	if(l_acc_req_flag = 'Y') then                                     -- RDP no changes just Acknowledged ( Set the NOTIF_USAGE as BUYER_ACK)
             wf_engine.SetItemAttrText (  itemtype   => itemtype,
                                          itemkey    => itemkey,
                                          aname      => 'NOTIF_USAGE',
                                          avalue     => 'BUYER_ACK');
        end if;
    else
    	resultout := 'Y';
		InsertActionHist(
				p_doc_id => l_doc_id,
				p_doc_type => l_doc_type,
				p_doc_subtype => l_doc_subtype,
				p_employee_id => null,
				p_action => 'SUBMIT CHANGE',
				p_note => null,
				p_path_id => null);
    end if;
exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','ANY_NEW_SUP_CHN',x_progress);
    raise;
END ANY_NEW_SUP_CHN;

procedure any_supplier_change(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_document_id number;
l_document_type po_document_types_all.document_type_code%TYPE;
l_count number;
l_cancel_app_count number;   /* fix for bug 3864512 */
x_progress varchar2(100) := '000';
l_change_request_group_id  number := null;
BEGIN

    l_document_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_ID');
    l_document_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'DOCUMENT_TYPE');


    if(l_document_type = 'RELEASE') then
		select count(1)
		into l_count
		from po_change_requests
		where initiator = 'SUPPLIER'
		and document_type = 'RELEASE'
		and po_release_id = l_document_id
		and request_status = 'BUYER_APP';

                select count(1)
                into l_cancel_app_count
                from po_change_requests
                where initiator = 'SUPPLIER'
                and document_type = 'RELEASE'
                and po_release_id = l_document_id
                and request_status = 'WAIT_CANCEL_APP';

		if ((l_count > 0) OR (l_cancel_app_count > 0)) then
		  -- no chance for no_data_found exception.
		  select distinct(change_request_group_id)
		                  into l_change_request_group_id
		                  from po_change_requests
		  where initiator = 'SUPPLIER'
		  and document_type = 'RELEASE'
		  and po_release_id = l_document_id
		  and request_status in ('BUYER_APP', 'WAIT_CANCEL_APP');
		end if;

                -- need to update the processed cancel shipment record to ACCEPTED
                -- so as to prevent it from blocking processing of other records

                if (l_count > 0 AND l_cancel_app_count > 0) then

                  update po_change_requests set request_status = 'ACCEPTED'
                  where initiator = 'SUPPLIER'
                  and document_type = 'RELEASE'
                  and po_release_id = l_document_id
                  and request_status = 'WAIT_CANCEL_APP';

                end if;

	else
		select count(1)
		into l_count
		from po_change_requests
		where initiator = 'SUPPLIER'
		and document_type = 'PO'
		and document_header_id = l_document_id
		and request_status = 'BUYER_APP';

                select count(1)
                into l_cancel_app_count
                from po_change_requests
                where initiator = 'SUPPLIER'
                and document_type = 'PO'
                and document_header_id = l_document_id
                and request_status = 'WAIT_CANCEL_APP';

                if ((l_count > 0) OR (l_cancel_app_count > 0)) then
		  -- no chance for no_data_found exception.
		  select distinct(change_request_group_id)
		                  into l_change_request_group_id
		                  from po_change_requests
		  where initiator = 'SUPPLIER'
		  and document_type = 'PO'
		  and document_header_id = l_document_id
		  and request_status in ('BUYER_APP', 'WAIT_CANCEL_APP');
	       end if;

               -- need to update the processed cancel shipment record to ACCEPTED
               -- so as to prevent it from blocking processing of other records

               if (l_count > 0 AND l_cancel_app_count > 0) then

                  update po_change_requests set request_status = 'ACCEPTED'
                  where initiator = 'SUPPLIER'
                  and document_type = 'PO'
                  and document_header_id = l_document_id
                  and request_status = 'WAIT_CANCEL_APP';

               end if;

	end if;

	begin
          PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
	                             itemkey  => itemkey,
	                             aname    => 'CHANGE_REQUEST_GROUP_ID',
	                             avalue     => l_change_request_group_id);
	exception when others then
	  null;
	end;

	if ((l_count > 0 AND l_cancel_app_count = 0) OR (l_count = 0 AND l_cancel_app_count > 0)) then
          resultout := 'Y';
        else
	  resultout := 'N';
	end if;

exception when no_data_found then
	wf_core.context('PO_ChangeOrderWF_PVT','any_supplier_change','010');
	raise;
when others then
	wf_core.context('PO_ChangeOrderWF_PVT','any_supplier_change',x_progress);
    raise;
END any_supplier_change;



procedure NotifySupAllChgRpdWF( 	p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number)
IS
l_api_name varchar2(50) := 'NotifySupAllChgRpdWF';
l_progress varchar2(100) := '000';
l_item_key 					varchar2(2000);
l_seq 						number;
l_supplier_username 		fnd_user.user_name%TYPE;
l_notification_subject 		varchar2(2000);

--l_po_num 					po_headers_all.segment1%TYPE;
--l_blanket_num 				po_headers_all.segment1%TYPE;
--l_release_num 				number;
--l_buyer_name 				hr_all_organization_units_tl.name%TYPE;
--l_type_lookup_code 			po_headers_all.type_lookup_code%TYPE;
--l_document_type 			varchar2(2000);
l_buyer_agent_id number;
l_responded_by_id number;
l_buyer_username fnd_user.user_name%TYPE;
l_buyer_disp_name varchar2(2000);
--l_doc_type po_document_types_all.document_type_code%TYPE;
l_document_id number;
l_po_style varchar2(10);
x_return_status  varchar2(1);
x_complex_flag   varchar2(1);

n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;
t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;


--l_id number;
--l_header_cancel varchar2(1);
--cursor l_header_cancel_csr(grp_id number) is
--select change_request_id
--from po_change_requests
--where change_request_group_id = grp_id
--and action_type = 'CANCELLATION'
--and request_level = 'HEADER';
--l_doc_hdr_info varchar2(2000);
l_supplier_user_id number;

/* Curosr to get the change_responded by*/
CURSOR getChangeRespBy(l_chg_req_grp_id_csr IN NUMBER) IS
SELECT distinct fndu.employee_id
FROM   po_change_requests pcr,
       fnd_user fndu
WHERE  pcr.change_request_group_id = l_chg_req_grp_id_csr
       AND fndu.user_id = pcr.responded_by;


BEGIN
	select PO_SUPPLIER_CHANGE_WF_S.nextval into l_seq from dual;
	if(p_release_id is not null) then
		l_document_id := p_release_id;
		l_item_key := 'NSCR'||'-'||to_char(p_release_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
	else
		l_document_id := p_header_id;
		l_item_key := 'NSCR'||'-'||to_char(p_header_id)||'-'||to_char(p_revision_num)||'-'||to_char(l_seq);
	end if;

	wf_engine.createProcess (	ItemType => 'POSCHORD',
								ItemKey => l_item_key,
								Process => 'CHG_RESPONDED_FYI_TO_SUPPLIER');

	l_progress := '001';
	if(p_release_id is null) then
		select pha.agent_id
		into l_buyer_agent_id
		from po_headers_all pha
		where pha.po_header_id = p_header_id;
	else
		select pra.agent_id
		into l_buyer_agent_id
		from po_releases_all pra
		where pra.po_release_id = p_release_id;
	end if;

	/* Commenting out for bug 3484201. Since change has already been requested by a
	specific user, the notification needs to be sent to the user on the change request */

	--PO_REQAPPROVAL_INIT1.locate_notifier(l_document_id, l_doc_type, l_supplier_username);

	if(l_supplier_username is null) then
		select max(created_by)
		into l_supplier_user_id
		from po_change_requests
		where change_request_group_id = p_chg_req_grp_id;

		select user_name
		into l_supplier_username
		from fnd_user
		where user_id = l_supplier_user_id;
	end if;

     /* Bug 4949617 get the reponded_by id from po_change_requests table */
       OPEN getChangeRespBy(p_chg_req_grp_id);
       LOOP
       FETCH getChangeRespBy INTO l_responded_by_id;
       EXIT WHEN getChangeRespBy%NOTFOUND;
       END LOOP;
       CLOSE getChangeRespBy;

       IF(l_responded_by_id = l_buyer_agent_id) THEN

	wf_directory.GetUserName ( p_orig_system    => 'PER',
                                  p_orig_system_id => l_buyer_agent_id,
                                  p_name           => l_buyer_username,
                                  p_display_name   => l_buyer_disp_name);
        ELSE
	  wf_directory.GetUserName ( p_orig_system    => 'PER',
                                  p_orig_system_id => l_responded_by_id,
                                  p_name           => l_buyer_username,
                                  p_display_name   => l_buyer_disp_name);
        END IF;


     l_progress := '002: call is_complex_po';          -- RDP Changes

         /*   PO- API  set item attribute PO_STYLE_TYPE depending upon the type of the PO
        PO_STYLE_TYPE - COMPLEX ,complex work PO's
        PO_STYLE_TYPE - NORMAL            */

 IF( p_release_id is not null) THEN
   l_po_style := 'NORMAL';

 ELSIF( p_release_id is null) THEN
  PO_COMPLEX_WORK_GRP.is_complex_work_po(
                          1.0,
                          p_header_id,
                          x_return_status,
                         x_complex_flag);

   IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_module_prefix,
                       l_progress
                       || 'x_return_status=' || x_return_status
                       || 'x_complex_flag ' || x_complex_flag);
     END IF;

   ELSE
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_module_prefix,
                       l_progress
                       ||'x_return_status = ' || x_return_status);
     END IF;
   END IF;

  IF(x_complex_flag = 'N') THEN
  l_po_style :='NORMAL';
  ELSE
  l_po_style := 'COMPLEX';
  END IF;

  END IF;


    n_varname(1) := 'PO_HEADER_ID';
	n_varval(1)  := p_header_id;
	n_varname(2) := 'PO_RELEASE_ID';
	n_varval(2)  := p_release_id;
	n_varname(3) := 'PO_REVISION_NUM';
	n_varval(3)  := p_revision_num;
	n_varname(4) := 'CHANGE_REQUEST_GROUP_ID';
	n_varval (4) := p_chg_req_grp_id;

	t_varname(1) := 'SUPPLIER_USERNAME';
	t_varval(1)  := l_supplier_username;
     /*	t_varname(2) := 'NTF_FOR_SUP_BUY_RP';
	t_varval(2)  := 'PLSQLCLOB:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_SUP_BUY_RP/'|| p_chg_req_grp_id;  */

        t_varname(2) := 'NTF_FOR_SUP_BUY_RP';                     -- RDP changing to point to the notifications Page
        t_varval(2)  :=  'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/notifications/webui/PosNotificationsRN'||
                         '&L_CHG_REQ_GRP_ID=-&CHANGE_REQUEST_GROUP_ID-&L_PO_HEADER_ID=-&PO_HEADER_ID-&L_PO_RELEASE_ID=-&PO_RELEASE_ID-'||
                         '&L_PO_ACC_REQ_FLAG=-&ACKNOWLEDGE_REQ_FLAG-&L_NOTIF_USAGE=-&NOTIF_USAGE-&L_EXPLAIN_FYI=-&EXPLAIN_FYI-&L_STYLE_PARAM=-&PO_STYLE_TYPE-';
	t_varname(3) := 'NTF_FOR_SUP_SUBJECT';
	t_varval(3)  := 'PLSQL:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_SUP_SUBJECT/'||l_item_key;
	t_varname(4) := 'FROM_BUYER';
	t_varval(4)  := l_buyer_username;
        t_varname(5) := 'NOTIF_USAGE';
        t_varval(5)  := 'BUYER_RESP';
        t_varname(6) := 'PO_STYLE_TYPE';
        t_varval(6)  := l_po_style;
	t_varname(7) := '#WFM_HTMLAGENT';
	t_varval(7)  := fnd_profile.value('POS_EXTERNAL_URL');


	Wf_Engine.SetItemAttrNumberArray('POSCHORD', l_item_key,n_varname,n_varval);
	Wf_Engine.SetItemAttrTextArray('POSCHORD', l_item_key,t_varname,t_varval);
	l_progress := '003';
	wf_engine.StartProcess(	ItemType => 'POSCHORD',
							ItemKey => l_item_key);

exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;
END NotifySupAllChgRpdWF;

procedure ProcessHdrCancelResponse( p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_user_id in number,
									p_acc_rej in varchar2,
									p_reason in varchar2,
									p_cancel_back_req in varchar2 DEFAULT NULL --Bug 18202450
)
IS
l_api_name varchar2(50) := 'ProcessHdrCancelResponse';
l_progress varchar2(5) := '000';
l_chn_req_grp_id number;
l_retcode number;
l_retmsg varchar2(2000);
l_doc_check_rec_type POS_ERR_TYPE;

BEGIN
	x_return_status := 'S';
	if(p_release_id is null) then
		select change_request_group_id
		into l_chn_req_grp_id
		from po_change_requests
		where document_header_id = p_header_id
		and request_status = 'PENDING'
		and request_level = 'HEADER'
		and initiator = 'SUPPLIER'
		and action_type ='CANCELLATION';

	else
		select change_request_group_id
		into l_chn_req_grp_id
		from po_change_requests
		where po_release_id = p_release_id
		and request_status = 'PENDING'
		and request_level = 'HEADER'
		and initiator = 'SUPPLIER'
		and action_type ='CANCELLATION';
	end if;
	l_progress := '001';
	if(p_acc_rej = 'A') then
		update po_change_requests
		set request_status = 'BUYER_APP',
                responded_by = p_user_id,
                response_date = sysdate,
                response_reason = p_reason,
                cancel_backing_req = p_cancel_back_req
        	where change_request_group_id = l_chn_req_grp_id;
	else
		update po_change_requests
		set request_status = 'REJECTED',
		    change_active_flag = 'N',
                responded_by = p_user_id,
                response_date = sysdate,
                response_reason = p_reason
		where change_request_group_id = l_chn_req_grp_id;
	end if;
	l_progress := '002';
	ProcessResponse(1.0, x_return_status, p_header_id, p_release_id,
                        p_revision_num, l_chn_req_grp_id, p_user_id, l_retmsg,
                        l_retcode, l_doc_check_rec_type, null, 'Y');

exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;
	x_return_status := 'U';
End ProcessHdrCancelResponse;


/*
*This API could originate from 2 sources
*1. Buyer Accept or Reject Supplier Change through Notification => Buyer Accept ALL OR Rejects ALL
*2. Buyer Accept or Reject Supplier Change through UI. If response DOES NOT cover all changes
*	return;
*   Else (response cover all changes)
*   	continue...
*   		1. Send Notification to Supplier if all changes are responded
*   			=> 	NO BUYER_APP/PENDING
*   		2. Send Notification to Buyer if PO requires Acknowledgement, and everything is responded
*   			=> 	ACC_REQUIRED_FLAG = 'Y'
*   				NO BUYER_APP/PENDING
*   				ALL SHIPMENTS ACCEPTED/REJECTED
*
*
*/
procedure ProcessResponse(p_api_version in number,
			x_return_status out NOCOPY varchar2,
			p_header_id in number,
			p_release_id in number,
			p_revision_num in number,
			p_chg_req_grp_id in number,
			p_user_id in number,
			x_err_msg out NOCOPY varchar2,
			x_return_code out NOCOPY number,
			x_doc_check_rec_type out NOCOPY POS_ERR_TYPE,
			p_flag in varchar2,
                        p_launch_approvals_flag in varchar2,
                        p_mass_update_releases   IN VARCHAR2 DEFAULT NULL -- Bug 3373453
                       )
IS
l_api_name varchar2(50):= 'ProcessResponse';
l_count number;
l_number_of_buyer_app number;
l_acc_req_flag varchar2(1);
l_item_key  		po_change_requests.wf_item_key%TYPE;
l_return_status 	varchar2(1);
l_po_cancel_api exception;
l_org_id number;
l_agent_id number;
x_progress 			varchar2(3):='000';
l_cancel_status 	varchar2(1);
l_mc_return_status 	varchar2(1);
l_mc_return_code number;
l_kickoff_status 	varchar2(1);
l_kickoff_msg 		varchar2(2000);
l_doc_id number;
l_employee_id number;

l_authorization_status po_headers_all.authorization_status%TYPE;
l_add_changes_accepted NUMBER;

l_doc_type po_document_types_all.document_type_code%TYPE;
l_doc_subtype po_document_types_all.document_subtype%TYPE;
l_id number;
l_action po_lookup_codes.lookup_code%TYPE;
l_acc_id number;
l_rej_id number;
l_closed_code po_headers_all.closed_code%type;

/*Start : Code Added for bug:16991952*/
l_orig_itemtype         po_headers.wf_item_type%TYPE;
l_orig_itemkey                 po_headers.wf_item_key%TYPE;
l_user_id               number;
l_resp_id               number;
l_appl_id               number;
/*End : Code Added for bug:16991952*/

cursor l_accept_csr(grp_id number) is
select change_request_id
from po_change_requests
where change_request_group_id = grp_id
and request_status in ('ACCEPTED','BUYER_APP');

cursor l_reject_csr(grp_id number) is
select change_request_id
from po_change_requests
where change_request_group_id = grp_id
and request_status = 'REJECTED';

cursor l_pending_csr(grp_id number) is
select change_request_id
from po_change_requests
where change_request_group_id = grp_id
and request_status = 'PENDING';


BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;


	if p_release_id is not null then
		l_doc_id := p_release_id;
		l_doc_type := 'RELEASE';
		select
			por.org_id ,
			por.agent_id,
			pha.type_lookup_code,
			nvl(por.closed_code,'OPEN')
		into
			l_org_id,
			l_agent_id,
			l_doc_subtype,
			l_closed_code
		from po_releases_all por,
			po_headers_all pha
		where po_release_id = p_release_id
		and por.po_header_id= pha.po_header_id;


	else
		l_doc_id := p_header_id;
		select
			poh.agent_id,
			poh.org_id,
			poh.type_lookup_code,
			nvl(poh.closed_code,'OPEN')
		into
			l_agent_id,
			l_org_id,
			l_doc_subtype,
			l_closed_code
		from po_headers_all poh
		where poh.po_header_id = p_header_id ;

		if(l_doc_subtype = 'BLANKET' or l_doc_subtype = 'CONTRACT') then
			l_doc_type := 'PA';
		elsif(l_doc_subtype = 'PLANNED' or l_doc_subtype = 'STANDARD') then
			l_doc_type := 'PO';
		end if;
	end if;

	/*Start : Code Added for bug:16991952*/
	BEGIN
        IF ( Nvl(l_doc_type, 'PO') <> 'RELEASE' ) THEN
          SELECT wf_item_type,
                 wf_item_key
          INTO   l_orig_itemtype, l_orig_itemkey
          FROM   po_headers_all
          WHERE  po_header_id = l_doc_id;
        ELSE
          SELECT wf_item_type,
                 wf_item_key
          INTO   l_orig_itemtype, l_orig_itemkey
          FROM   po_releases_all
          WHERE  po_release_id = l_doc_id;
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
          l_orig_itemtype := NULL;

          l_orig_itemkey := NULL;
    END;

    IF ( l_orig_itemtype IS NOT NULL
         AND l_orig_itemkey IS NOT NULL ) THEN
      l_user_id := po_wf_util_pkg.Getitemattrnumber(itemtype => l_orig_itemtype,
                   itemkey
                   =>
      l_orig_itemkey
                   , aname => 'USER_ID');

      l_resp_id := po_wf_util_pkg.Getitemattrnumber(itemtype => l_orig_itemtype,
                                itemkey => l_orig_itemkey, aname =>
                   'RESPONSIBILITY_ID');

      l_appl_id := po_wf_util_pkg.Getitemattrnumber(itemtype => l_orig_itemtype,
                                itemkey => l_orig_itemkey, aname =>
                   'APPLICATION_ID'
                   );

      IF ( l_user_id IS NOT NULL
           AND l_resp_id IS NOT NULL
           AND l_appl_id IS NOT NULL )THEN
        fnd_global.Apps_initialize(l_user_id, l_resp_id, l_appl_id);
      ELSE
        Initialize (l_agent_id, l_org_id);
      END IF;
    END IF;

	/*End : Code Added for bug:16991952*/
--	initialize(l_agent_id, l_org_id);
    PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;         -- <R12 MOAC>

--Check if any Change is still Pending, if yes, return
--This is just for double check.. This API should only be called when all changes are responded
	open l_pending_csr(p_chg_req_grp_id);
	fetch l_pending_csr into l_id;
	if (l_id is not null) then
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_err_msg := 'PENDING RECORDS EXIST';
		close l_pending_csr;
		return;
	end if;
	close l_pending_csr;
	l_id := null;

--Action History
	open l_accept_csr(p_chg_req_grp_id);
	fetch l_accept_csr into l_acc_id;
	close l_accept_csr;
	open l_reject_csr(p_chg_req_grp_id);
	fetch l_reject_csr into l_rej_id;
	close l_reject_csr;

	if(l_acc_id is not null and l_rej_id is not null) then
		l_action := 'RESPOND';
	elsif(l_acc_id is not null) then
		l_action := 'ACCEPT';
	elsif(l_rej_id is not null) then
		l_action := 'REJECT';
	end if;

	if(l_closed_code = 'OPEN') then

		l_employee_id := l_agent_id;
		if (p_user_id is not null) then
		    begin
		        select employee_id into l_employee_id from fnd_user where user_id = p_user_id;
		    exception when others then
		        null;
		    end;
		end if;

		if (l_employee_id is null) then

		    l_employee_id := l_agent_id;
		end if ;


		InsertActionHist(
					p_doc_id => l_doc_id,
					p_doc_type => l_doc_type,
					p_doc_subtype => l_doc_subtype,
				        p_employee_id => l_employee_id,
				     -- p_employee_id => l_agent_id,
                                     -- p_employee_id => p_user_id,            -- RDP ( instead of agent_id , user_id should be used)
					p_action => l_action,
					p_note => null,
					p_path_id => null);
	end if;

/* 0. Are changes responded at header level?
	If NO => There is a notification waiting for Buyer to Respond at the Header Level.
				Kill IT!!!
*/
	x_progress:='001';
	if(p_flag is null) then
		begin
			select distinct wf_item_key
			into l_item_key
			from po_change_requests
			where change_request_group_id = p_chg_req_grp_id;
			wf_engine.completeActivity('POSCHORD',l_item_key,'NOTIFY_BUYER_OF_CHN', 'Abort');
		exception when others then
			null;
		end;
	end if;

	x_progress:='002';
	CancelPO(l_cancel_status, p_header_id,p_release_id,p_chg_req_grp_id);


	x_progress:='004';

-- 2. Update po_change_requests table.. for those supplier change request to cancel, if accepted
-- 		change them from BUYER_APP to ACCEPTED
	update po_change_requests
	set request_status = 'ACCEPTED'
	-- change_active_flag = 'N'   /* commented out due to bug 3574114 */
	where change_request_group_id = p_chg_req_grp_id
	and request_status in ('BUYER_APP', 'WAIT_CANCEL_APP')
	and action_type = 'CANCELLATION';

/*
WHETHER TO SEND NOTIFICATION TO SUPPLIER OR NOT:
At this Stage, there is NO MORE Changes in Pending Stage.
If There is no more change that requires Buyer Hierachy  Approval (BUYER_APP),
	we know the supplier changes have been fully responded. => Send Notification to Supplier
Else
	There are records which requries Buyer Hierachy Approval
		=> MoveChangeToPO, kick off Buyer Approval Workflow
*/

-- Bug 3771964

if (l_rej_id is not null) then
 if (p_release_id is null) then
        update po_line_locations_all
        set approved_flag = 'Y'
        where po_header_id=p_header_id
        and po_release_id is null;
    else
        update po_line_locations_all
        set approved_flag = 'Y'
        where po_header_id=p_header_id
        and po_release_id = p_release_id;
   end if;
end if;

	x_progress:='005';

	select count(1)
	into l_number_of_buyer_app
	from po_change_requests
	where change_request_group_id = p_chg_req_grp_id
	and request_status = 'BUYER_APP';

	if(l_number_of_buyer_app = 0) then
		x_progress:='006';

        	NotifySupAllChgRpdWF(
				p_header_id,
				p_release_id,
				p_revision_num,
				p_chg_req_grp_id);

	else
		-- Call MoveChangeToPO
		x_progress:='007';
		PO_CHANGE_RESPONSE_PVT.MoveChangeToPO(
	         					1.0,
							l_mc_return_status,
							p_header_id,
							p_release_id,
							p_chg_req_grp_id ,
							p_user_id,
							l_mc_return_code,
							x_err_msg,
							x_doc_check_rec_type,
                                                        p_launch_approvals_flag,
                                                        p_mass_update_releases
                                                       );

		x_return_status := l_mc_return_status;
		x_return_code := l_mc_return_code;


                /* COMMENTED OUT - WAIT_MGR_APP status is no longer used and is replaced by BUYER_APP
		update po_change_requests
		set request_status = 'WAIT_MGR_APP'
		where change_request_group_id = p_chg_req_grp_id
		and request_status = 'BUYER_APP';
                */

		x_progress:='008';
                /* COMMENTED OUT - Now handled in Change PO API
        	KickOffPOApproval(
							1.0,
							l_kickoff_status,
							p_header_id,
							p_release_id,
							l_kickoff_msg);


		if(l_kickoff_status <> FND_API.G_RET_STS_SUCCESS) then
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			x_err_msg := 'STARTPOWF_ERROR:'||l_kickoff_msg;
		end if;
                */
	end if;

exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', x_progress||':'||sqlerrm);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_err_msg := x_progress||'*'||sqlerrm;

END ProcessResponse;

procedure NOTIFY_REQ_PLAN (	  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_progress varchar2(5) := '000';
l_chg_req_grp_id number;
l_requestor_id number;
l_planner_id number;
l_header_id number;
l_release_id number;
l_revision_num number;
l_agent_id number;

--Bug6885296 - Added condition to restrict requesters from being
--notified when supplier requests changes for Blanket Purchase Agreement.

cursor l_requestors_csr(grp_id number)
is
select pda.deliver_to_person_id
from
	po_change_requests pcr,
	po_distributions_all pda,
        po_line_locations_all pll
where pcr.change_request_group_id = grp_id
and pcr.request_level = 'LINE'
and pcr.document_line_id = pda.po_line_id
and pda.line_location_id = pll.line_location_id
and pll.shipment_type = 'STANDARD'
union
select pda.deliver_to_person_id
from
	po_change_requests pcr,
	po_distributions_all pda
where pcr.change_request_group_id = grp_id
and pcr.request_level = 'SHIPMENT'
and pcr.document_line_location_id = pda.line_location_id;


/* Start of code changes for Bug 17057621 */

cursor l_planners_csr(grp_id number)
is
select
	distinct mtp.employee_id
from
	mtl_system_items msi,
	mtl_planners mtp,
	po_change_requests pcr,
	po_lines_all pla,
	po_headers_all poh
where pcr.change_request_group_id = grp_id
AND pcr.document_header_id = poh.po_header_id
and pcr.document_line_id = pla.po_line_id
and pla.item_id = msi.inventory_item_id
and msi.planner_code = mtp.planner_code
and msi.organization_id = mtp.organization_id
AND mtp.organization_id IN (SELECT psv.organization_id
 	                    FROM   po_ship_to_loc_org_v psv
 	                    WHERE  psv.location_id = poh.ship_to_location_id);

cursor t_planners_csr(grp_id number)
is
 SELECT DISTINCT mtp.employee_id
 FROM   mtl_system_items msi,
        mtl_planners mtp,
        po_change_requests pcr,
        po_lines_all pla,
        po_headers_all poh
 WHERE  pcr.change_request_group_id = grp_id
    AND pcr.document_header_id = poh.po_header_id
    AND pcr.document_line_id = pla.po_line_id
    AND pla.item_id = msi.inventory_item_id
    AND msi.planner_code = mtp.planner_code
    AND msi.organization_id = mtp.organization_id
    AND mtp.organization_id = poh.org_id;

/* END of code changes for Bug 17057621 */

BEGIN
    l_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_HEADER_ID');
    l_release_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_RELEASE_ID');
    l_revision_num := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_REVISION_NUM');

    l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');
	if(l_release_id is null) then
		select agent_id
		into l_agent_id
		from po_headers_all
		where po_header_id = l_header_id;
	else
		select agent_id
		into l_agent_id
		from po_releases_all
		where po_release_id = l_release_id;
	end if;

	l_progress := '001';
	open l_requestors_csr( l_chg_req_grp_id );
	loop
	fetch l_requestors_csr into l_requestor_id;
	exit when l_requestors_csr%NOTFOUND;
		if(l_requestor_id is not null AND
			l_requestor_id <> l_agent_id) then
			Notify_Requester_Sup_Change(
										l_header_id,
										l_release_id,
										l_revision_num,
										l_chg_req_grp_id,
										l_requestor_id);
		end if;
	end loop;
	close l_requestors_csr;

	l_progress := '002';

	open l_planners_csr(l_chg_req_grp_id );
	loop
	fetch l_planners_csr into l_planner_id;
	exit when l_planners_csr%NOTFOUND;
		if(l_planner_id is not null AND
			l_planner_id <> l_agent_id) then
			Notify_Planner_Sup_Change(
										l_header_id,
										l_release_id,
										l_revision_num,
										l_chg_req_grp_id,
										l_planner_id);
		end if;
	end loop;

	/* Start of code changes for Bug 17057621 */

 		IF(l_planners_csr%ROWCOUNT = 0) THEN
 	            open t_planners_csr(l_chg_req_grp_id);
 	            loop
 	            fetch t_planners_csr into l_planner_id;
 	            exit when t_planners_csr%NOTFOUND;
 	            if(l_planner_id is not null AND l_planner_id <> l_agent_id) THEN
 	                Notify_Planner_Sup_Change( l_header_id,
 	                                            l_release_id,
 	                                           l_revision_num,
 	                                           l_chg_req_grp_id,
 	                                           l_planner_id);

 	            end if;
 	            end loop;
 	            close t_planners_csr;
 	         END IF;
	close l_planners_csr;

       /* end of Code Changes for Bug 17057621 */

exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','NOTIFY_REQ_PLAN',l_progress);
    raise;
END   NOTIFY_REQ_PLAN ;

procedure PROCESS_RESPONSE	(	  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS
l_header_id number;
l_release_id number;
l_revision_num number;
l_chg_req_grp_id number;
l_return_code number;
l_err_msg 		varchar2(2000);
x_progress 		varchar2(3) := '000';
l_return_status varchar2(1);
l_doc_check_rec_type POS_ERR_TYPE;

BEGIN
    l_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_HEADER_ID');
    l_release_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_RELEASE_ID');
    l_revision_num := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'PO_REVISION_NUM');
    l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');

	x_progress := '001';
	ProcessResponse(1.0, l_return_status, l_header_id, l_release_id,
                        l_revision_num, l_chg_req_grp_id, fnd_global.user_id, l_err_msg,
                        l_return_code,l_doc_check_rec_type, 'Y', 'Y');

exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','PROCESS_RESPONSE',x_progress);
    raise;
END PROCESS_RESPONSE;

procedure BUYER_ACCEPT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS

l_chg_req_grp_id number;
l_responded_by number;
l_notif_usage VARCHAR2(30);

BEGIN

    l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');

    l_notif_usage := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                    itemkey => itemKey,
                                    aname => 'NOTIF_USAGE');

   IF( l_notif_usage = 'BUYER_AUTO_FYI') THEN
     l_responded_by :=null;
  ELSE
   l_responded_by :=fnd_global.user_id;
  END IF;

      update po_change_requests
	set request_status ='BUYER_APP',
		responded_by = l_responded_by,
		response_date = sysdate
	where change_request_group_id = l_chg_req_grp_id
	and request_status in ('PENDING','REQ_APP');           -- RDP ( Update records lying in REQ_APP status too)

exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','BUYER_ACCEPT_CHANGE','000');
    raise;
end BUYER_ACCEPT_CHANGE;

procedure BUYER_REJECT_CHANGE  (  	itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		    resultout       out NOCOPY varchar2)
IS

-- curosr to get the ReqHeaderId
cursor c_getReqHdrId(p_po_header_id_csr IN NUMBER) is
        select distinct porh.requisition_header_id
        from   po_requisition_headers_all porh,
               po_requisition_lines_all porl,
               po_headers_all poh,
               po_line_locations_all poll
        where  porh.requisition_header_id = porl.requisition_header_id AND
               porl.line_location_id = poll.line_location_id  AND
               poh.po_header_id = poll.po_header_id AND
               poh.po_header_id = p_po_header_id_csr;

l_chg_req_grp_id number;
l_notif_usage VARCHAR2(30);
l_req_hdr_id number;
l_po_header_id number;
BEGIN

    l_chg_req_grp_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                            itemkey => itemkey,
                                            aname => 'CHANGE_REQUEST_GROUP_ID');


    l_notif_usage      :=  wf_engine.GetItemAttrText(itemtype => itemtype,
                                                     itemkey => itemkey,
                                                     aname => 'NOTIF_USAGE');

    l_po_header_id     :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
					                itemkey  => itemkey,
	                                                aname    => 'PO_HEADER_ID');

    -- Withdraw the lock from requisition , if the changes have been rejected by the requester
   IF( l_notif_usage = 'REQ') THEN
       OPEN c_getReqHdrId(l_po_header_id);
        LOOP
          FETCH c_getReqHdrId INTO l_req_hdr_id;
          EXIT WHEN c_getReqHdrId%NOTFOUND;
            BEGIN
	     update po_requisition_headers_all
             set change_pending_flag = 'N'
             where requisition_header_id = l_req_hdr_id
	     AND change_pending_flag = 'Y';
            EXCEPTION
              WHEN OTHERS THEN NULL;
            END;
	 END LOOP;
       CLOSE c_getReqHdrId;
    END IF;



	update po_change_requests
	set request_status ='REJECTED',
		change_active_flag = 'N',
		responded_by = fnd_global.user_id,
		response_date = sysdate
	where change_request_group_id = l_chg_req_grp_id
	and request_status in ('PENDING','REQ_APP');           -- RDP ( Update records lying in REQ_APP status too)
exception when others then
	wf_core.context('PO_ChangeOrderWF_PVT','BUYER_REJECT_CHANGE','000');
    raise;
end BUYER_REJECT_CHANGE;

/*
This API is called from ISP Change Details Page. If the supplier submits a change, OR, if the supplier completely finishes
acknowledging the PO at the shipment level (which may contain accept/reject/change), this API will be executed.
*/
procedure StartSupplierChangeWF( 	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_header_id in number,
									p_release_id in number,
									p_revision_num in number,
									p_chg_req_grp_id in number,
									p_acc_req_flag in varchar2 default 'N')
IS
l_api_name varchar2(50) := 'StartSupplierChangeWF';
l_progress varchar2(100) := '000';
l_count number;
l_seq number;
l_po_style varchar2(10);
l_item_key po_change_requests.wf_item_key%TYPE;
l_doc_type_code varchar2(1);
l_buyer_notif_code varchar2(240);
l_buyer_agent_id number;
l_buyer_username fnd_user.user_name%TYPE;
l_supplier_username fnd_user.user_name%TYPE;
l_buyer_disp_name varchar2(2000);
n_varname   Wf_Engine.NameTabTyp;
n_varval    Wf_Engine.NumTabTyp;
t_varname   Wf_Engine.NameTabTyp;
t_varval    Wf_Engine.TextTabTyp;
x_ret_status  varchar2(1);
x_complex_flag   varchar2(1);


BEGIN
IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
	FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
			l_api_name || 'start',p_header_id||'*'||p_release_id||'*'||p_revision_num||'*'||p_chg_req_grp_id);
END IF;

	-- Start Workflow
	select PO_SUPPLIER_CHANGE_WF_S.nextval into l_seq from dual;
	if(p_release_id is not null) then
		l_doc_type_code := 'R';
		l_item_key := p_release_id||'-'||p_revision_num||'-'||l_doc_type_code||'-'||to_char(l_seq);
	else
		l_doc_type_code := 'P';
		l_item_key := p_header_id||'-'||p_revision_num||'-'||l_doc_type_code||'-'||to_char(l_seq);
	end if;




	wf_engine.createProcess (	ItemType => 'POSCHORD',
								ItemKey => l_item_key,
								Process => 'MAIN_PROCESS');

	l_progress := '001';

	l_buyer_notif_code := '@'||p_header_id||'#'||p_release_id||'$'||p_chg_req_grp_id||'%'||p_acc_req_flag||'^';

	-- Get Supplier User Name
	select user_name
	into l_supplier_username
	from fnd_user
	where user_id = fnd_global.user_id;

	wf_engine.SetItemAttrText(itemtype => 'POSCHORD',
			          itemkey  => l_item_key,
			          aname    => 'RESP_ID',
                                  avalue   => fnd_global.RESP_ID);

        wf_engine.SetItemAttrText(itemtype => 'POSCHORD',
			          itemkey  => l_item_key,
			          aname    => 'APPL_RESP_ID',
                                  avalue   => fnd_global.RESP_APPL_ID);

	if(p_release_id is null) then
	    select agent_id
	    into   l_buyer_agent_id
	    from   po_headers_all
	    where  po_headers_all.po_header_id = p_header_id;
	else
	    select pra.agent_id
	    into l_buyer_agent_id
	    from po_releases_all pra,
	    	 po_headers_all pha
	    where pra.po_release_id = p_release_id
	    and pra.po_header_id = pha.po_header_id;
        end if;

	l_progress := '003';

	-- Get Buyer UserName:
	wf_directory.GetUserName    ( p_orig_system    => 'PER',
                                  p_orig_system_id => l_buyer_agent_id,
                                  p_name           => l_buyer_username,
                                  p_display_name   => l_buyer_disp_name);

 IF(p_release_id is not null) THEN

    l_po_style := 'NORMAL';

 ELSIF(p_release_id is null) THEN

         l_progress := '004: call is_complex_po';

         /*   PO- API  set item attribute PO_STYLE_TYPE depending upon the type of the PO
        PO_STYLE_TYPE - COMPLEX ,complex work PO's
        PO_STYLE_TYPE - NORMAL */


   PO_COMPLEX_WORK_GRP.is_complex_work_po(
                          1.0,
                          p_header_id,
                          x_ret_status,
                         x_complex_flag);

   IF x_return_status IS NOT NULL AND  x_return_status = FND_API.g_ret_sts_success THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                       g_module_prefix,
                       l_progress
                       || 'x_return_status=' || x_return_status);
     END IF;

   ELSE
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_module_prefix,
                       l_progress
                       ||'x_return_status = ' || x_return_status);
     END IF;
   END IF;

    IF(x_complex_flag = 'N') THEN
    l_po_style :='NORMAL';
    ELSE
    l_po_style := 'COMPLEX';
    END IF;
 END IF;

	n_varname(1) := 'PO_HEADER_ID';
	n_varval(1)  := p_header_id;
	n_varname(2) := 'PO_RELEASE_ID';
	n_varval(2)  := p_release_id;
	n_varname(3) := 'PO_REVISION_NUM';
	n_varval(3)  := p_revision_num;
	n_varname(4) := 'CHANGE_REQUEST_GROUP_ID';
	n_varval(4)  := p_chg_req_grp_id;

	t_varname(1) := 'NTF_FOR_BUYER_SUBJECT';
	t_varval(1)  := 'PLSQL:PO_ChangeOrderWF_PVT.GEN_NTF_FOR_BUYER_SUBJECT/'||l_item_key;
	t_varname(2) := 'NOTIF_FOR_BUYER_SUP_CHG';                                          -- RDP set the item Attibute value to the Notifications Page
	t_varval(2)  := 'JSP:/OA_HTML/OA.jsp?page=/oracle/apps/pos/notifications/webui/PosNotificationsRN'||
                         '&L_CHG_REQ_GRP_ID=-&CHANGE_REQUEST_GROUP_ID-&L_PO_HEADER_ID=-&PO_HEADER_ID-&L_PO_RELEASE_ID=-&PO_RELEASE_ID-'||
                         '&L_PO_ACC_REQ_FLAG=-&ACKNOWLEDGE_REQ_FLAG-&L_NOTIF_USAGE=-&NOTIF_USAGE-&L_EXPLAIN_FYI=-&EXPLAIN_FYI-&L_STYLE_PARAM=-&PO_STYLE_TYPE-';
	t_varname(3) := 'BUYER_USERNAME';
	t_varval(3)  := l_buyer_username;
	t_varname(4) := 'FROM_SUPPLIER';
	t_varval(4)  := l_supplier_username;
	t_varname(5) := 'ACKNOWLEDGE_REQ_FLAG';
	t_varval(5)  := p_acc_req_flag;
        t_varname(6) := 'PO_STYLE_TYPE';
        t_varval(6)  := l_po_style;

	Wf_Engine.SetItemAttrNumberArray('POSCHORD', l_item_key,n_varname,n_varval);
	Wf_Engine.SetItemAttrTextArray('POSCHORD', l_item_key,t_varname,t_varval);



/*update data to include wf item key and item type. p_chg_req_grp_id could be null in the case where user accepts/rejects
all shipments and no changes was made. Thus, in this case, we will NOT store the wf_item_key or wf_item_type anywhere.
*/
	if(p_chg_req_grp_id is not null) then
		update po_change_requests
		set wf_item_type = 'POSCHORD',wf_item_key = l_item_key
		where change_request_group_id = p_chg_req_grp_id;
	end if;
	l_progress := '004';

	wf_engine.StartProcess(	ItemType => 'POSCHORD',
							ItemKey => l_item_key);

	x_return_status := FND_API.G_RET_STS_SUCCESS;
exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', l_progress||':'||sqlerrm);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end StartSupplierChangeWF;


PROCEDURE initialize(p_employee_id in NUMBER,p_org_id IN NUMBER) IS

  l_resp_id NUMBER := -1;
  l_user_id NUMBER := -1;

    /* bug 9672656 : application id is hard coded to 201. In case of custom application with custom reponsibilities,
   when requistion is changed (which is on an approved PO), and the eventual PO Change Request fires, the
  resulting POAPPRV process errors.
  Fetching application id from fnd_global resolves the issue. */
 -- Bug 13915321 reverting the fix
  l_resp_appl_id NUMBER := 201;

  --l_resp_appl_id NUMBER := fnd_global.resp_appl_id;

  l_api_name varchar2(50) := 'initialize';
  l_progress varchar2(5) := '000';

  cursor l_get_user_info_csr
  is
	select fr.responsibility_id,fu.user_id
	from wf_local_user_roles wur,
	     fnd_responsibility fr,
	     financials_system_params_all fsp,
	     fnd_user fu
	  where wur.user_name = fu.user_name
	    and wur.role_orig_system = 'FND_RESP'
	    and wur.role_orig_system_id = fr.responsibility_id
	    and wur.partition_id = 2
	   and (((wur.start_date is NULL) or (trunc(sysdate) >= trunc(wur.start_date)))
	  and	 ((wur.expiration_date is NULL) or
	  (trunc(sysdate) < trunc(wur.expiration_date)))
	  and	 ((wur.user_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.user_start_date)))
	  and	 ((wur.user_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.user_end_date)))
	  and	 ((wur.role_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.role_start_date)))
	  and	 ((wur.role_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.role_end_date))))
	    and fr.application_id = 201
	    and fr.start_date < sysdate
	    and nvl(fr.end_date, sysdate +1) >= sysdate
           and nvl(fsp.org_id,-1) = nvl(p_org_id,-1);
          /* and nvl(fsp.business_group_id,-1) = nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL, fr.responsibility_id, fr.application_id),-1);*/


   CURSOR l_get_resp_info_csr ( p_user_id NUMBER)
   IS
      SELECT fr.responsibility_id
	  FROM   wf_local_user_roles wur,
       fnd_responsibility fr,
       financials_system_params_all fsp,
       fnd_user fu
	  WHERE  fu.user_name = wur.user_name
       AND fu.user_id = p_user_id
       AND wur.role_orig_system = 'FND_RESP'
       AND wur.role_orig_system_id = fr.responsibility_id
       AND wur.partition_id = 2
       AND ( ( ( wur.start_date IS NULL )
                OR ( Trunc(SYSDATE) >= Trunc(wur.start_date) ) )
             AND ( ( wur.expiration_date IS NULL )
                    OR ( Trunc(SYSDATE) < Trunc(wur.expiration_date) ) )
             AND ( ( wur.user_start_date IS NULL )
                    OR ( Trunc(SYSDATE) >= Trunc(wur.user_start_date) ) )
             AND ( ( wur.user_end_date IS NULL )
                    OR ( Trunc(SYSDATE) < Trunc(wur.user_end_date) ) )
             AND ( ( wur.role_start_date IS NULL )
                    OR ( Trunc(SYSDATE) >= Trunc(wur.role_start_date) ) )
             AND ( ( wur.role_end_date IS NULL )
                    OR ( Trunc(SYSDATE) < Trunc(wur.role_end_date) ) ) )
       AND fr.application_id = 201
       AND fr.start_date < SYSDATE
       AND Nvl(fr.end_date, SYSDATE + 1) >= SYSDATE
       AND Nvl(fsp.org_id, -1) = Nvl(p_org_id, -1);


BEGIN
/* bug 13915321 begin Moving the block here*/
  BEGIN
  l_progress := '001';
	SELECT FND.user_id
	INTO   l_user_id
	FROM   FND_USER FND, HR_EMPLOYEES_CURRENT_V HR
        WHERE  HR.EMPLOYEE_ID = p_employee_id
        AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID
        AND    ROWNUM = 1;

   EXCEPTION
      WHEN OTHERS THEN
	 l_user_id := -1;
   END;

   IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_progress||' '||l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
   END IF;
/* bug 13915321 end*/
   /* bug 13915321 The fix to use following logic for searching
   first of all search for the user id
   if user id is valid, search for a valid purchasing responsibility

   if user id is not valid, search for user and responsibility associated
   with purchasing.
   if responsibility is not found search for a custom responsibility as fail safe case
   (retaining fix 9672656)
   If still the responsibility is not found then
   search for custom responsibility and user associated*/

   /* bug 13915321 begin*/
   /* If user_id is valid, search for a valid responsibility*/
   /*bug 16991952*/
   /*Added below cursor to get a valid responsibility assigned to the user*/
 if(l_user_id <>-1) then
  BEGIN
  l_progress := '002';
    open l_get_resp_info_csr(l_user_id);
       fetch l_get_resp_info_csr into
       l_resp_id;
       close l_get_resp_info_csr;
     EXCEPTION
     when others then
	   l_resp_id := -1;
   END;
   IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_progress||' '||l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
   END IF;
end if;
if ((l_user_id = -1) or (l_resp_id = -1 OR l_resp_id is null)) then
   l_progress := '003';
		open l_get_user_info_csr;
		fetch l_get_user_info_csr into
			l_resp_id, l_user_id;
		close l_get_user_info_csr;
   IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_progress||' '||l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
   END IF;
end if;
 /* As a fail safe case retaining the fix in  9672656
 Actually we should not have entertained the fix in that bug
 whenever customer creates a custom responsibility
 he should attach it to purchasing only
 in 11.5.10 it is all the more important because
 document manager can proceed only  on
 purchasing responsibility
 But retaining the fix for avoiding regressions after discussion with Raja*/
if (l_resp_id = -1 OR l_resp_id is null) then
l_resp_appl_id := fnd_global.resp_appl_id;
if(l_user_id <>-1) then
   l_progress := '004';
   BEGIN
	select MIN(fr.responsibility_id)
	into l_resp_id
   	from wf_local_user_roles wur,
	     fnd_responsibility fr,
	     financials_system_params_all fsp,
	     fnd_user fu
	  where wur.user_name = fu.user_name
	    and fu.user_id = l_user_id
	    and wur.role_orig_system = 'FND_RESP'
	    and wur.role_orig_system_id = fr.responsibility_id
	    and wur.partition_id = 2
	   and (((wur.start_date is NULL) or (trunc(sysdate) >= trunc(wur.start_date)))
	  and	 ((wur.expiration_date is NULL) or
	  (trunc(sysdate) < trunc(wur.expiration_date)))
	  and	 ((wur.user_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.user_start_date)))
	  and	 ((wur.user_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.user_end_date)))
	  and	 ((wur.role_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.role_start_date)))
	  and	 ((wur.role_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.role_end_date))))
	    and fr.application_id = l_resp_appl_id
	    and fr.start_date < sysdate
	    and nvl(fr.end_date, sysdate +1) >= sysdate
           and nvl(fsp.org_id,-1) = nvl(p_org_id,-1);
         /*  and nvl(fsp.business_group_id,-1) = nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL, fr.responsibility_id, fr.application_id),-1); */
    IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_progress||' '||l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
    END IF;
   EXCEPTION
     when others then
	l_resp_id := -1;
   END;
end if;
if ((l_user_id = -1) or (l_resp_id = -1 OR l_resp_id is null)) then
   l_progress := '005';
    BEGIN
	select MIN(fr.responsibility_id),fu.user_id
	into l_resp_id,l_user_id
   	from wf_local_user_roles wur,
	     fnd_responsibility fr,
	     financials_system_params_all fsp,
	     fnd_user fu
	  where wur.user_name = fu.user_name
	    and wur.role_orig_system = 'FND_RESP'
	    and wur.role_orig_system_id = fr.responsibility_id
	    and wur.partition_id = 2
	   and (((wur.start_date is NULL) or (trunc(sysdate) >= trunc(wur.start_date)))
	  and	 ((wur.expiration_date is NULL) or
	  (trunc(sysdate) < trunc(wur.expiration_date)))
	  and	 ((wur.user_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.user_start_date)))
	  and	 ((wur.user_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.user_end_date)))
	  and	 ((wur.role_start_date is NULL) or
	  (trunc(sysdate) >= trunc(wur.role_start_date)))
	  and	 ((wur.role_end_date is NULL) or
	  (trunc(sysdate) < trunc(wur.role_end_date))))
	    and fr.application_id = l_resp_appl_id
	    and fr.start_date < sysdate
	    and nvl(fr.end_date, sysdate +1) >= sysdate
           and nvl(fsp.org_id,-1) = nvl(p_org_id,-1);
         /*  and nvl(fsp.business_group_id,-1) = nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL, fr.responsibility_id, fr.application_id),-1); */
   IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_progress||' '||l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
   END IF;
   EXCEPTION
     when others then
	l_resp_id := -1;
   END;
end if;
end if;
/* bug 13915321 end*/
   l_progress := '006';
   IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.intialize parameters',l_user_id||'*'||l_resp_id||'*'||l_resp_appl_id );
   END IF;
   FND_GLOBAL.APPS_INITIALIZE(l_user_id,l_resp_id,l_resp_appl_id);
exception when others then
	IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL  THEN
		FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
	END IF;
END initialize;

function getEmailResponderUserName(p_supp_user_name varchar2,
                                   p_ntf_role_name  varchar2) return varchar2
         IS
l_user_name   varchar2(320);
l_email    varchar2(2000);
l_start    pls_integer;
l_end      pls_integer;
begin
   /*  This part of the code is copied from the procedure
       wf_directory.GetInfoFromMail.  So, watch for fixes by wf in this part
       of the code.
    */

   -- strip off the unwanted info from email. Emails from the mailer
   -- could be of the form "Vijay Shanmugam"<vshanmug@oracle.com>
   l_start := instr(p_supp_user_name, '<', 1, 1);
   if (l_start > 0) then
       l_end := instr(p_supp_user_name, '>', l_start);
       l_email := substr(p_supp_user_name, l_start+1, l_end-l_start-1);
   else
       l_email := p_supp_user_name;
   end if;

  select wur.user_name
    into l_user_name
  from wf_user_roles wur,wf_users wr
  where wur.role_name=p_ntf_role_name and
        wr.name =wur.user_name and
        upper(wr.email_address)=upper(l_email);

  return l_user_name;

  exception when others then
  --note: if the ntf has been responded by somebody not in the role,
  -- it can fail.
    return null;
end;
                                                            -- RDP called from NotificationsAMImpl.java ( gets the additional changes if any)
PROCEDURE getAdditionalChanges( p_chg_req_grp_id in number,
                                x_addl_chg out nocopy  varchar2,
                                x_count out nocopy number)
is
CURSOR additional_changes(chg_req_grp_id_csr IN NUMBER) IS
select  additional_changes
from po_change_requests
where change_request_group_id = chg_req_grp_id_csr
and request_level = 'HEADER'
and additional_changes is not null;

-- returns 1 when only additional changes at header level are requested otherwise 0
CURSOR getRequestLevel(chg_req_grp_id_csr IN NUMBER)  IS
SELECT COUNT(1) FROM po_change_requests WHERE NOT EXISTS ( SELECT 1
                                                           FROM po_change_requests
                                                           WHERE change_request_group_id = chg_req_grp_id_csr
                                                           AND request_level IN ('LINE','SHIPMENT'))
AND change_request_group_id = chg_req_grp_id_csr
AND action_type = 'MODIFICATION';

-- Bug 7487461
-- Modified the data type for additional changes to capture the entire text.
l_additional_changes po_change_requests.additional_changes%type;
l_count NUMBER(10);
begin
OPEN getRequestLevel(p_chg_req_grp_id);
LOOP
FETCH getRequestLevel
INTO l_count;
EXIT WHEN getRequestLevel%NOTFOUND;
END LOOP;
CLOSE getRequestLevel;

IF(l_count = 1) THEN
x_count := l_count;
ELSE
x_count := 0;
END IF;

OPEN additional_changes(p_chg_req_grp_id);
LOOP
FETCH additional_changes
INTO l_additional_changes;
EXIT WHEN additional_changes%NOTFOUND;
END LOOP;
CLOSE additional_changes;

x_addl_chg := l_additional_changes;

end getAdditionalChanges;


PROCEDURE  getReqNumber(p_po_header_id in number , p_po_release_id in number,  x_req_num out nocopy varchar2, x_req_hdr_id out nocopy varchar2)  -- RDP(backing)
IS
CURSOR getReqHdrId(c_po_header_id in NUMBER) IS
select   distinct(porla.requisition_header_id)
from     po_requisition_lines_all  porla,
         po_line_locations_all   polla
where    polla.po_header_id = c_po_header_id
         and porla.line_location_id = polla.line_location_id;

CURSOR getReqNum(c_req_header_id in NUMBER) IS
select   porha.segment1
from po_requisition_headers_all porha
where requisition_header_id = c_req_header_id;

-- for releases
CURSOR getReqHdrId_rel(c_po_header_id in NUMBER, c_po_release_id in NUMBER) IS
select   distinct(porla.requisition_header_id)
from     po_requisition_lines_all  porla,
         po_line_locations_all   polla
where    polla.po_header_id = c_po_header_id
         and polla.po_release_id = c_po_release_id
         and porla.line_location_id = polla.line_location_id;



l_req_header_id  NUMBER(10);
l_req_num        NUMBER(10);


BEGIN
IF (p_po_release_id is null) THEN
    OPEN getReqHdrId(p_po_header_id);
    LOOP
    FETCH getReqHdrId INTO l_req_header_id;
    EXIT WHEN getReqHdrId%NOTFOUND;
    END LOOP;
    CLOSE getReqHdrId;
ELSE
   OPEN getReqHdrId_rel(p_po_header_id,p_po_release_id);
   LOOP
   FETCH getReqHdrId_rel INTO l_req_header_id;
   EXIT WHEN getReqHdrId_rel%NOTFOUND;
   END LOOP;
   CLOSE getReqHdrId_rel;
END IF;

OPEN getReqNum(l_req_header_id);
LOOP
FETCH getReqNum INTO l_req_num;
EXIT  WHEN getReqNum%NOTFOUND;
END LOOP;

CLOSE getReqNum;

IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.string(FND_LOG.level_procedure, g_module_prefix || '.getReqNumber', l_req_num ||' * '|| l_req_header_id);
END IF;

x_req_num := TO_CHAR(l_req_num);
x_req_hdr_id := TO_CHAR(l_req_header_id);

EXCEPTION
   WHEN OTHERS THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         ':unexpected error' || Sqlerrm);
     END IF;

end  getReqNumber;


PROCEDURE getChgReqMode(p_chg_req_grp_id in number, x_req_mode out nocopy varchar2)  -- RDP(identifies whether this is a CANCELLATION or MODIFICATION request)
IS                                                                                   -- To be used to set the Header Msg of Chg Request Table
l_temp  VARCHAR2(15);
l_req_mode  VARCHAR2(15);
BEGIN
select decode(count(distinct(action_type)),2,'BOTH',1,'CHG') into
l_req_mode
from
po_change_requests
where
change_request_group_id = p_chg_req_grp_id
and request_level in('LINE','SHIPMENT')
and action_type in('MODIFICATION','CANCELLATION');

if l_req_mode = 'BOTH' then
x_req_mode := 'BOTH';
elsif l_req_mode = 'CHG' then
select distinct(action_type) into
l_temp
from
po_change_requests
where
change_request_group_id = p_chg_req_grp_id
and request_level in('LINE','SHIPMENT')
and action_type in('MODIFICATION','CANCELLATION');

 if l_temp = 'CANCELLATION' then
 x_req_mode := 'CANCELLATION';
 elsif l_temp = 'MODIFICATION' then
 x_req_mode := 'MODIFICATION';
 end if;
end if;

EXCEPTION
   WHEN OTHERS THEN
      IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         ':unexpected error' || Sqlerrm);
     END IF;

end getChgReqMode;

PROCEDURE getOpenShipCount(po_line_location_id in number, x_ship_invalid_for_ctrl_actn out nocopy varchar2)
IS
l_ship_invalid_for_ctrl_actn varchar2(1);
BEGIN
 SELECT 'N'
 INTO l_ship_invalid_for_ctrl_actn
 FROM DUAL
 WHERE EXISTS(
              SELECT 1
              FROM po_line_locations_all poll1,
                   po_line_locations_all poll2
              WHERE poll1.line_location_id = po_line_location_id
              AND poll1.po_line_id  = poll2.po_line_id
                        AND NVL(poll2.cancel_flag,'N') <> 'Y'
                        AND NVL(poll2.payment_type, 'NULL') NOT IN ('ADVANCE', 'DELIVERY') --<Complex Work R12>
                        AND NVL(poll2.closed_code, 'OPEN')
                            <> 'FINALLY CLOSED'
                        AND poll2.line_location_id <> po_line_location_id);

 x_ship_invalid_for_ctrl_actn := l_ship_invalid_for_ctrl_actn;
EXCEPTION
WHEN NO_DATA_FOUND THEN
--Current shipment is the only shipment on the line that is not cancelled or finally closed
--OR there are no open, uncancelled shipments.
x_ship_invalid_for_ctrl_actn := 'Y';
END getOpenShipCount;



PROCEDURE getHdrCancel(p_chg_req_grp_id in number,
                       po_header_id   in  number,
                       po_release_id  in  number,
                       x_action_type out nocopy varchar2,
                       x_request_status out nocopy varchar2,
                       x_doc_type out nocopy varchar2,
                       x_doc_num out nocopy varchar2,
                       x_revision_num out nocopy varchar2)
IS
l_count              number;
l_action_type        varchar2(15) := null;
l_request_status     varchar2(15) := null;
l_doc_type           varchar2(15) := null;
l_doc_num            varchar2(15) := null;
l_revision_num       varchar2(15) := null;

CURSOR HdrCancelCsrCount(p_chg_req_grp_id_csr IN NUMBER) IS
SELECT count(*)
FROM   po_change_requests pcr
WHERE  pcr.CHANGE_REQUEST_GROUP_ID = p_chg_req_grp_id_csr
AND   pcr.REQUEST_LEVEL = 'HEADER'
AND   pcr.ACTION_TYPE = 'CANCELLATION';

CURSOR HdrCancelCsrVal(p_chg_req_grp_id_csr IN NUMBER) IS
SELECT pcr.action_type,
       pcr.request_status,
       poh.type_lookup_code,
       pcr.document_num
FROM   PO_CHANGE_REQUESTS pcr,
       PO_HEADERS_ALL     poh
WHERE  pcr.CHANGE_REQUEST_GROUP_ID =  p_chg_req_grp_id_csr
       AND   pcr.REQUEST_LEVEL = 'HEADER'
       AND   pcr.ACTION_TYPE = 'CANCELLATION'
       AND pcr.document_header_id = poh.po_header_id;

CURSOR getRevisionNum(p_chg_req_grp_id_csr IN NUMBER) IS
SELECT distinct(pcr.document_revision_num)
FROM   po_change_requests pcr
WHERE  pcr.CHANGE_REQUEST_GROUP_ID = p_chg_req_grp_id_csr;

CURSOR getRevisionNumAck(po_header_id_csr IN NUMBER) IS
SELECT revision_num
FROM   po_headers_all
WHERE  po_header_id = po_header_id_csr;

CURSOR getRevisionNumAckRel(po_header_id_csr IN NUMBER,po_release_id_csr IN NUMBER) IS
SELECT pora.revision_num
FROM po_releases_all pora
WHERE pora.po_header_id = po_header_id_csr
AND   pora.po_release_id = po_release_id_csr;

BEGIN

IF(p_chg_req_grp_id is null) THEN

 IF(po_release_id is null) THEN
  OPEN getRevisionNumAck(po_header_id);
  FETCH getRevisionNumAck
  INTO
  l_revision_num;
  CLOSE getRevisionNumAck;
 ELSE
  OPEN getRevisionNumAckRel(po_header_id,po_release_id);
  FETCH getRevisionNumAckRel
  INTO
  l_revision_num;
  CLOSE getRevisionNumAckRel;
 END IF;

ELSE

OPEN HdrCancelCsrCount(p_chg_req_grp_id);
LOOP
FETCH HdrCancelCsrCount
INTO
l_count;
EXIT WHEN HdrCancelCsrCount%NOTFOUND;
END LOOP;
CLOSE HdrCancelCsrCount;

IF(l_count = 0) THEN
l_action_type := 'NOCANCEL';
OPEN getRevisionNum(p_chg_req_grp_id);
LOOP
FETCH getRevisionNum
INTO l_revision_num;
EXIT WHEN getRevisionNum%NOTFOUND;
END LOOP;
CLOSE getRevisionNum;

ELSIF(l_count = 1) THEN
OPEN HdrCancelCsrVal(p_chg_req_grp_id);
LOOP
FETCH HdrCancelCsrVal
INTO l_action_type,
     l_request_status,
     l_doc_type,
     l_doc_num;
EXIT WHEN HdrCancelCsrVal%NOTFOUND;
END LOOP;
CLOSE HdrCancelCsrVal;

 END IF;
END IF;

x_action_type := l_action_type;
x_request_status := l_request_status;
x_doc_type       := l_doc_type;
x_doc_num        := l_doc_num;
x_revision_num   := l_revision_num;

EXCEPTION
  WHEN OTHERS THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         ':unexpected error' || Sqlerrm);
     END IF;

END  getHdrCancel;

/*
This procedure sets the supplier user context after the auto acceptance of
the PO.
*/

PROCEDURE SET_SUPPLIER_CONTEXT(p_supplier_user_id in NUMBER,p_resp_id in NUMBER,p_appl_resp_id in NUMBER)
IS
BEGIN

IF g_fnd_debug = 'Y' AND FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.string(FND_LOG.level_procedure, g_module_prefix || '.SET_SUPPLIER_CONTEXT', 'user_id:'||p_supplier_user_id||'resp:'||p_resp_id||'appl id:'||p_appl_resp_id );
END IF;

fnd_global.APPS_INITIALIZE(p_supplier_user_id, p_resp_id, p_appl_resp_id);

EXCEPTION
  WHEN OTHERS THEN
     IF( g_fnd_debug = 'Y' AND FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                         g_module_prefix,
                         ':unexpected error' || Sqlerrm);
     END IF;

END SET_SUPPLIER_CONTEXT;

procedure CHECK_POS_EXTERNAL_URL(  		itemtype        in varchar2,
		                           	itemkey         in varchar2,
        		                   	actid           in number,
	            		         	funcmode        in varchar2,
                        		        resultout       out NOCOPY varchar2)
is
  l_api_name varchar2(50) := 'CHECK_POS_EXTERNAL_URL';
  l_external_url varchar2(500);
begin

  l_external_url := fnd_profile.value('POS_EXTERNAL_URL');
  IF (g_fnd_debug = 'Y' AND FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.string(FND_LOG.level_procedure, g_module_prefix ||
				l_api_name || '.start', 'POS_EXTERNAL_URL=' || l_external_url);
  END IF;
  resultout := 'N:' || l_external_url;

  if (l_external_url is not null) then

    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => '#WFM_HTMLAGENT',
                                   avalue   => l_external_url);

    resultout := 'Y:' || l_external_url;
  end if;

exception when others then
    IF (g_fnd_debug = 'Y' AND FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
				l_api_name || '.others_exception', sqlerrm);
    END IF;
    resultout := 'F:' || l_external_url;
    return;
end CHECK_POS_EXTERNAL_URL;

procedure post_approval_notif (p_itemtype        in varchar2,
                               p_itemkey         in varchar2,
                               p_actid           in number,
                               p_funcmode        in varchar2,
                               x_resultout       out NOCOPY varchar2) IS

l_api_name                         varchar2(50) := p_itemkey || ' post_approval_notif';
l_notification_id                  number;
l_forwardTo                        varchar2(240);
l_result                           varchar2(100);
l_forward_to_username_response     varchar2(240) :='';
l_action                           po_action_history.action_code%TYPE;
l_new_recipient_id                 wf_roles.orig_system_id%TYPE;
l_current_recipient_id   wf_roles.orig_system_id%TYPE;
l_origsys                          wf_roles.orig_system%TYPE;

-- Declare following context setting variables.
l_responder_id       fnd_user.user_id%TYPE;
l_session_user_id    NUMBER;
l_session_resp_id    NUMBER;
l_session_appl_id    NUMBER;
l_preparer_resp_id   NUMBER;
l_preparer_appl_id   NUMBER;
l_progress           VARCHAR2(1000);
l_preserved_ctx      VARCHAR2(5);

BEGIN

  l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 01.';
  IF (g_fnd_debug = 'Y') THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'Enter in post_approval_notif ' || l_progress);
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'p_itemtype ' || p_itemtype);
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'p_itemkey ' || p_itemkey);
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'p_actid ' || p_actid);
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'p_funcmode ' || p_funcmode);
  END IF;

  if (p_funcmode IN  ('FORWARD', 'QUESTION', 'ANSWER')) THEN
    if (p_funcmode = 'FORWARD') then
      l_action := 'DELEGATE';
    elsif (p_funcmode = 'QUESTION') then
      l_action := 'QUESTION';
    elsif (p_funcmode = 'ANSWER') then
      l_action := 'ANSWER';
    end if;


    Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);
  l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 02.';

 if (p_funcmode = 'RESPOND') then
    l_notification_id := WF_ENGINE.context_nid;
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'l_notification_id '||l_notification_id );
    END IF;
 l_result := wf_notification.GetAttrText(l_notification_id, 'RESULT');

    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_api_name, 'l_result '||l_result );
    END IF;

    if (l_result = 'FORWARD') THEN

      l_forwardTo := wf_notification.GetAttrText(l_notification_id, 'FORWARD_TO_USERNAME_RESPONSE');
      l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => p_itemtype,
                                                                   itemkey  => p_itemkey,
                                                                   aname    => 'FORWARD_TO_USERNAME_RESPONSE');

      if(l_forwardTo is null) then
        fnd_message.set_name('ICX', 'ICX_POR_WF_NOTIF_NO_USER');
        app_exception.raise_exception;
      end if;
    end if;

    if (wf_engine.preserved_context = TRUE) then
      l_preserved_ctx := 'TRUE';
    else
      l_preserved_ctx := 'FALSE';
    end if;

    l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 03.' ;

    -- <debug start>
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_preserved_ctx ' ||l_preserved_ctx);
    END IF;
 -- <debug end>


    SELECT fu.USER_ID
    INTO   l_responder_id
    FROM   fnd_user fu,
           wf_notifications wfn
    WHERE  wfn.notification_id = l_notification_id
           AND wfn.original_recipient = fu.user_name;

    l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 04.' ;

    -- <debug start>
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_responder_id ' ||l_responder_id);
    END IF;
    -- <debug end>
    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;

    -- <debug start>
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_user_id ' ||l_session_user_id);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_resp_id ' ||l_session_resp_id);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_appl_id ' ||l_session_appl_id);
    END IF;
    -- <debug end>
    IF (l_session_user_id = -1) THEN
      l_session_user_id := NULL;
    END IF;

    IF (l_session_resp_id = -1) THEN
      l_session_resp_id := NULL;
    END IF;

    IF (l_session_appl_id = -1) THEN
      l_session_appl_id := NULL;
    END IF;
    -- <debug start>
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_user_id ' ||l_session_user_id);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_resp_id ' ||l_session_resp_id);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_session_appl_id ' ||l_session_appl_id);
    END IF;
    -- <debug end>

    l_preparer_resp_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'RESP_ID');
    l_preparer_appl_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                      itemkey  => p_itemkey,
                                                      aname   => 'APPLICATION_ID');

    l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 05.' ;

    -- <debug start>
  IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_preparer_resp_id ' ||l_preparer_resp_id);
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_preparer_appl_id ' ||l_preparer_appl_id);
    END IF;
    -- <debug end>
    if (l_responder_id is not null) then
      if (l_responder_id <> l_session_user_id) then
        /* possible in 2 scenarios :
           1. when the response is made from email using guest user feature
                 2. When the response is made from sysadmin login
        */

        l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 06.' ;

        -- <debug start>
        IF (g_fnd_debug = 'Y') THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress || 'When the response is made from email using guest user feature');
        END IF;
        -- <debug end>

        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_USER_ID',
                                    avalue  => l_responder_id);
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_RESP_ID',
 avalue  => l_preparer_resp_id);
        wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname   => 'RESPONDER_APPL_ID',
                                    avalue  => l_preparer_appl_id);
      ELSE
        l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 07.' ;

        -- <debug start>
        IF (g_fnd_debug = 'Y') THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress || 'When the response is made from sysadmin login');
        END IF;
 -- <debug end>

        if (l_session_resp_id is null) THEN
                /* possible when the response is made from the default worklist without choosing a valid responsibility */
       l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 07.' ;
          -- <debug start>
       IF (g_fnd_debug = 'Y') THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress '||l_progress || 'When the response is made from the default worklist');
       END IF;
          -- <debug end>
          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_USER_ID',
                                      avalue  => l_responder_id);
          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_RESP_ID',
                                      avalue  => l_preparer_resp_id);
          wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname   => 'RESPONDER_APPL_ID',
                                      avalue  => l_preparer_appl_id);
        else

          /* All values available - possible when the response is made after choosing a correct responsibility */
          /* If the values of responsibility_id and application
             id are available but are incorrect. This may happen when a
             response is made through the email or the background process
             picks the wf up.  This may happen due to the fact that the
             mailer / background process carries the context set by
              the notification /wf it processed last */

          l_progress := 'PO_ChangeOrderWF_PVT.post_approval_notif: 09.' ;

          -- <debug start>
          IF (g_fnd_debug = 'Y') THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,l_api_name,'l_progress ' ||l_progress || 'When the response is made after choosing a correct responsibility');
          END IF;
          -- <debug end>

          if ( l_preserved_ctx = 'TRUE') then
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_session_resp_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_session_appl_id);
          else
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_USER_ID',
                                        avalue  => l_responder_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_RESP_ID',
                                        avalue  => l_preparer_resp_id);
            wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                                        itemkey  => p_itemkey,
                                        aname   => 'RESPONDER_APPL_ID',
                                        avalue  => l_preparer_appl_id);
          end if;
        end if;
      end if;
    end if;
    end if;

    x_resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
    return;
  end if;



EXCEPTION
  when no_data_found then
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_api_name, 'No data found in post_approval_notif ' || l_progress);
    END IF;
    raise;

  when others then
    IF (g_fnd_debug = 'Y') THEN
       FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_api_name,'Exception in post_approval_notif ' || l_progress);
    END IF;
    raise;
END post_approval_notif;

-------------------------------------------------------------------------------
-- Start of Comments
-- Name: PO_SUPCHG_SELECTOR
-- Pre-reqs: None.
-- Modifies:
--   Application user id
--   Application responsibility id
--   Application application id
-- Locks: None.
-- Function:
--   This procedure sets the correct application context when a process is
--   picked up by the workflow background engine. When called in
--   TEST_CTX mode it compares workflow attribute org id with the current
--   org id and workflow attributes user id, responsibility id and
--   application id with their corresponding profile values. It returns TRUE
--   if these values match and FALSE otherwise. When called in SET_CTX mode
--   it sets the correct apps context based on workflow parameters.
-- Parameters:
-- IN:
--   p_itemtype
--     Specifies the itemtype of the workflow process
--   p_itemkey
--     Specifies the itemkey of the workflow process
--   p_actid
--     activity id passed by the workflow
--   p_funcmode
--     Input values can be TEST_CTX or SET_CTX (RUN not implemented)
--     TEST_CTX to test if current context is correct
--     SET_CTX to set the correct context if current context is wrong
-- IN OUT:
--   resultout
--     For TEST_CTX a TRUE value means that the context is correct and
--     SET_CTX need not be called. A FALSE value means that current context
--     is incorrect and SET_CTX need to set correct context
-- Testing:
--   There is not script to test this procedure but the correct functioning
--   may be tested by verifying from the debug_message in table po_wf_debug
--   that if at any time the workflow process gets started with a wrong
--   context then the selector is called in TEST_CTX and SET_CTX modes and
--   correct context is set.
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE PO_SUPCHG_SELECTOR ( p_itemtype   IN VARCHAR2,
                          p_itemkey    IN VARCHAR2,
                          p_actid      IN NUMBER,
                          p_funcmode   IN VARCHAR2,
                          resultout   IN OUT NOCOPY VARCHAR2) IS

-- Declare context setting variables start
l_session_user_id         NUMBER;
l_session_resp_id         NUMBER;
l_responder_id            NUMBER;
l_user_id_to_set          NUMBER;
l_resp_id_to_set          NUMBER;
l_appl_id_to_set          NUMBER;
l_progress                VARCHAR2(1000);
l_preserved_ctx           VARCHAR2(5):= 'TRUE';
l_org_id                  NUMBER;
-- Declare context setting variables End

BEGIN
 -- <debug start>
 IF (g_fnd_debug = 'Y') THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','Inside PO_SUPCHG_SELECTOR procedure');
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','p_itemtype : '||p_itemtype);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','p_itemkey : '||p_itemkey);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','p_actid : '||p_actid);
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','p_funcmode : '||p_funcmode);
  END IF;
 -- <debug end>


  l_org_id := wf_engine.GetItemAttrNumber (itemtype => p_itemtype,
                                           itemkey  => p_itemkey,
                                           aname    => 'ORG_ID');
  l_session_user_id := fnd_global.user_id;
  l_session_resp_id := fnd_global.resp_id;

  IF (l_session_user_id = -1) THEN
    l_session_user_id := NULL;
  END IF;

  IF (l_session_resp_id = -1) THEN
    l_session_resp_id := NULL;
  END IF;

  l_responder_id :=  wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                 itemkey  => p_itemkey,
                                                 aname    => 'RESPONDER_USER_ID');

  --<debug start>
  l_progress :='010 - ses_user_id:'||l_session_user_id ||' ses_resp_id :'||l_session_resp_id||' responder id:' ||l_responder_id||' org id :'||l_org_id;

 IF (g_fnd_debug = 'Y') THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','l_progress1 : '||l_progress);
  END IF;
  --<debug end>

  IF (p_funcmode = 'TEST_CTX') THEN
    -- wf shouldn't run without the session user, hence always set the ctx if session user id is null.
    if (l_session_user_id is null) then
      resultout := 'NOTSET';
      return;
    else
      if (l_responder_id is not null) then
        if (l_responder_id <> l_session_user_id) then
          resultout := 'FALSE';
          return;
        else
          if (l_session_resp_id is Null) then
            resultout := 'NOTSET';
            return;
          else
            -- If the selector fn is called from a background ps
            -- notif mailer then force the session to use preparer's or responder
            -- context. This is required since the mailer/bckgrnd ps carries the
            -- context from the last wf processed and hence even if the context values
            -- are present, they might not be correct.

            if (wf_engine.preserved_context = TRUE) then
              resultout := 'TRUE';
            else
              resultout:= 'NOTSET';
 end if;

            -- introduce an org context setting call here
            -- required in the case when the right resonder makes a response
            -- from a NON-PO RESP.
            IF l_org_id is NOT NULL THEN
              PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
            END IF;
            return;
          end if;
        end if;
      else
        -- always setting the ctx at the start of the wf
        resultout := 'NOTSET';
        return;
      end if;
    end if;  -- l_session_user_id is null
  ELSIF (p_funcmode = 'SET_CTX') THEN
    if l_responder_id is not null then

      l_user_id_to_set := l_responder_id;

      l_resp_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_RESP_ID');
      l_appl_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESPONDER_APPL_ID');
--<debug start>
      l_progress := '020 selection fn responder id not null';

 IF (g_fnd_debug = 'Y') THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','l_progress2 : '||l_progress);
      END IF;
      --<debug end>

      --<debug start>
      l_progress :='030 selector fn : setting user id :'||l_responder_id ||' resp id '||l_resp_id_to_set||' l_appl id '||l_appl_id_to_set;

 IF (g_fnd_debug = 'Y') THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','l_progress3 : '||l_progress);
      END IF;
      --<debug end>
    else
 l_user_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'USER_ID');
      l_resp_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'RESP_ID');
      l_appl_id_to_set := wf_engine.GetItemAttrNumber (itemtype  => p_itemtype,
                                                       itemkey  => p_itemkey,
                                                       aname  => 'APPLICATION_ID');
      --<debug start>
      l_progress := '040 selector fn responder id null';
 IF (g_fnd_debug = 'Y') THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','l_progress4 : '||l_progress);
      END IF;
      --<debug end>

      --<debug start>
      l_progress := '050 selector fn : set user '||l_user_id_to_set||' resp id ' ||l_resp_id_to_set||' appl id '||l_appl_id_to_set;

 IF (g_fnd_debug = 'Y') THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','l_progress4 : '||l_progress);
      END IF;
      --<debug end>
    end if;

    fnd_global.apps_initialize(l_user_id_to_set, l_resp_id_to_set,l_appl_id_to_set);

    -- obvious place to make such a call, since we are using an apps_initialize,
    -- this is required since the responsibility might have a different OU attached
    -- than what is required.
  IF l_org_id is NOT NULL THEN
      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;
    END IF;

  END IF;
EXCEPTION WHEN OTHERS THEN

 IF (g_fnd_debug = 'Y') THEN
    fnd_log.string(FND_LOG.LEVEL_PROCEDURE, 'pos.plsql.PO_ChangeOrderWF_PVT.PO_SUPCHG_SELECTOR.invoked','Exception in Selector Procedure');
  END IF;

  WF_CORE.context('PO_ChangeOrderWF_PVT', 'PO_SUPCHG_SELECTOR', p_itemtype, p_itemkey, p_actid, p_funcmode);
  RAISE;

END PO_SUPCHG_SELECTOR;

END PO_ChangeOrderWF_PVT;

/

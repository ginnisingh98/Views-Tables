--------------------------------------------------------
--  DDL for Package Body IGW_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_WORKFLOW" as
--$Header: igwwfrob.pls 120.7 2005/09/12 21:06:26 vmedikon ship $
----------- procedure start_workflow ------------------------------
procedure start_workflow(p_proposal_id   in   number,
                         p_run_id        in   number) is




begin

  null;

end start_workflow;


----------- procedure select_persons_to_notify -----------------------------
procedure select_persons_to_notify(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  nocopy varchar2) is

cursor get_notification_role is
select  distinct
        ppms.wf_role_name
from    igw_prop_maps ppm,
        igw_prop_map_stops ppms
where   ppm.prop_map_id = ppms.prop_map_id
and     ppm.run_id = to_number(itemkey)
and     ppm.map_type = 'N'
and     ppms.submission_date is null;

l_wf_role_name          varchar2(100);

begin

  null;

end select_persons_to_notify;

----------- procedure select_approver -----------------------------
procedure select_approver(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  nocopy varchar2) is

begin
  null;
end select_approver;



----------- procedure update_approval_status  -----------------------------
procedure disable_reassign(itemtype    in   varchar2,
                           itemkey     in   varchar2,
                           actid       in   number,
                           funcmode    in   varchar2,
                           result      out  nocopy varchar2) is

begin
  null;

end disable_reassign;

----------- procedure expire_role  -----------------------------
procedure expire_role(itemkey    in   varchar2) is


begin

  null;

end expire_role;


----------- procedure update_approval_status  -----------------------------
procedure update_approval_status(itemtype    in   varchar2,
                                  itemkey     in   varchar2,
                                  actid       in   number,
                                  funcmode    in   varchar2,
                                  result      out  nocopy varchar2) is



begin


  null;
end update_approval_status;



----------- procedure delete_approval_roles  -----------------------------
procedure delete_approval_roles(l_proposal_id    in   number) is




begin

  null;
end delete_approval_roles;


----------- procedure update_rejection_status  -----------------------------
procedure update_rejection_status(itemtype    in   varchar2,
                                  itemkey     in   varchar2,
                                  actid       in   number,
                                  funcmode    in   varchar2,
                                  result      out  nocopy varchar2) is

  cursor select_responder(l_forward_to_username varchar2) is
  select wn.responder,wna.text_value
  from   wf_notification_attributes  wna,
         wf_notifications wn
  where  wn.notification_id = wna.notification_id
  and    wna.name = 'NOTE'
  and    wn.recipient_role = l_forward_to_username
  and    wn.responder is not null
  and    wn.message_name = 'NOTIFY_APPROVER';

  l_responder            varchar2(100);
  l_text_value           varchar2(2000);
  l_proposal_id          number(15);
  l_forward_to_username  varchar2(100);

begin


  null;
end update_rejection_status;


----------- procedure last_approver  -----------------------------
procedure last_approver(itemtype    in   varchar2,
                      itemkey     in   varchar2,
                      actid       in   number,
                      funcmode    in   varchar2,
                      result      out  nocopy varchar2) is


l_proposal_id      number(15);

begin

  null;
end last_approver;
end igw_workflow;

/

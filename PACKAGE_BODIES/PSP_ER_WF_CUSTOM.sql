--------------------------------------------------------
--  DDL for Package Body PSP_ER_WF_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ER_WF_CUSTOM" as
/* $Header: PSPERWCB.pls 120.0.12010000.2 2008/08/05 10:11:38 ubhat ship $ */
procedure set_custom_wf_admin(itemtype IN  varchar2,
                              itemkey  IN  varchar2,
                              actid    IN  number,
                              funcmode IN  varchar2,
                              result   OUT nocopy varchar2) is
 l_wf_role wf_roles.name%type;
begin
  --- Set the  WF admin to the WF Role u need
  --- sample code below. This custom Role will override the seeded
  -- behavior. The product is shipped with  WF Administrator set to
  -- WF role of the  Effort Report process  INITIATOR person.
  --
  -- The significance of WF Administrator in a Workflow thread,
  -- is that this WF role(or person) will
  -- receive all error notifications, he/she can take
  -- take appropriate action to fix the cause for error and
  -- and then  Submit the WF thread for RETRY.
    /* wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey    => itemkey,
                                aname      => 'WF_ADMINISTRATOR',
                                avalue     => l_wf_role);
        result := 'COMPLETE'; */
     null;
EXCEPTION
WHEN OTHERS THEN
  result := 'ERROR';
  wf_core.context('PSP_EFFORT_REPORTS', 'SET_CUSTOM_WF_ADMIN', itemtype, itemkey,
                   to_char(actid), funcmode);
   raise;
end set_custom_wf_Admin;


procedure set_custom_timeout_approver(itemtype IN  varchar2,
                                      itemkey  IN  varchar2,
                                      actid    IN  number,
                                      funcmode IN  varchar2,
                                      result   OUT nocopy varchar2) is

  l_new_display_name   wf_roles.display_name%TYPE; -- Bug 6641216
  l_new_user_name      fnd_user.user_name%TYPE;    -- Bug 6641216


begin

   --   set the time out approver, by default notification is
   -- the inbox of the approver. If a different approver is
   -- set, the notification moves from the approver to a different
   -- approver.
   -- Example below:
      /*  wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_ROLE_NAME',
                                    avalue   => 'TIMEOUT_APPROVER');
          wf_engine.SetItemAttrText(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVER_DISPLAY_NAME',
                                    avalue   => 'TIMEOUT_APPROVER_DISPLAY_NAME');
       */

   -- Bug 6641216
   -- Another sample code to set the timeout approver as the WORKFLOW ADMINISTRATOR
   -- Example Below

   /*

    l_new_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
      		                		 itemkey  => itemkey,
                             			 aname    => 'WF_ADMINISTRATOR');

    select display_name into l_new_display_name
    from wf_roles where name = l_new_user_name;

   wf_engine.SetItemAttrText(itemtype => itemtype,
   		             itemkey  => itemkey,
                             aname    => 'APPROVER_ROLE_NAME',
                             avalue   => l_new_user_name);

   wf_engine.SetItemAttrText(itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'APPROVER_DISPLAY_NAME',
                             avalue   => l_new_display_name);

   result := 'COMPLETE'; */



    null;
EXCEPTION
WHEN OTHERS THEN
  result := 'ERROR';
  wf_core.context('PSP_EFFORT_REPORTS', 'SET_CUSTOM_TIMEOUT_APPROVER', itemtype, itemkey,
                   to_char(actid), funcmode);
   raise;
end set_custom_timeout_approver;
end;

/

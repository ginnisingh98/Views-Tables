--------------------------------------------------------
--  DDL for Package Body GMD_QMDSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QMDSC" AS
/* $Header: GMDQMSCB.pls 120.2 2006/12/05 16:06:22 rlnagara noship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


PROCEDURE VERIFY_EVENT(
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
	 l_event_name varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
	 l_event_key varchar2(240) := WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

	 l_status_change varchar2(40);
	 l_change_to varchar2(40);
	 l_log varchar2(200);

	 cursor get_from_role is
	     select nvl( text, '')
		from wf_Resources where name = 'WF_ADMIN_ROLE'   --RLNAGARA B5654562 Changed from WF_ADMIN to WF_ADMIN_ROLE
		and language = userenv('LANG')   ;

 BEGIN

    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Sampledisp');
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Event  ' || l_event_name);
       gmd_debug.put_line('Event key  ' || l_event_key);
    END IF;

    if l_event_name = 'oracle.apps.gmd.qm.samplingevent.disposition' then
	l_log := 'Composite and lot status change' ;
	GMD_RESULTS_GRP.composite_and_change_lot(l_event_key,
						 'NO',
						 l_status_change);
   elsif l_event_name = 'oracle.apps.gmd.qm.sample.disposition' then
	l_log := 'Sample status change' ;
	GMD_RESULTS_GRP.change_disp_for_auto_lot(l_event_key,
						 l_change_to,
						 l_status_change);
    end if;


    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed Result GRP APIs');
    END IF;

    /* No Approval Required */
    P_resultout:='COMPLETE:NO_WORKFLOW';
    return;


  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMDSC','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
      raise;

  END VERIFY_EVENT;



/* AME Code which is not used at the moment */
PROCEDURE CHECK_NEXT_APPROVER(
   /* procedure to verify event if the event is sample disposition or sample event disposition */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
 l_event_name varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
 l_event_key varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

 l_current_approver varchar2(240);

 l_application_id number;
 l_transaction_type varchar2(100):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'AME_TRANS');
 l_user varchar2(32);
 Approver ame_util.approverRecord;
 l_item_no varchar2(240);
 l_item_desc varchar2(240);
 l_lot_no varchar2(240);
 l_sublot_no varchar2(240);
 l_sample_no varchar2(240);
 l_sample_plan varchar2(240);
 l_sample_disposition varchar2(240);
 l_sample_source varchar2(240);
 l_specification varchar2(240);
 l_validity_rule varchar2(240);
 l_validity_rule_version varchar2(240);
 l_sample_event_text varchar2(4000);
 l_sampling_event_id number;
 l_form varchar2(240);

 BEGIN

      /* Get Next Approver */
        /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

       ame_api.getNextApprover(applicationIdIn => l_application_id,
                              transactionIdIn => l_event_key,
                              transactionTypeIn => l_transaction_type,
                              nextApproverOut => Approver);

     if(Approver.user_id is null and Approver.person_id is null) then
       /* No Approval Required */
        P_resultout:='COMPLETE:N';
     else
       if(Approver.person_id is null) then
         select user_name into l_user from fnd_user
           where user_id=Approver.user_id;
       else
         /*select user_name into l_user from fnd_user a,per_all_people b
          where
           b.person_id=Approver.person_id and
           a.employee_id is not null and
           a.employee_id = b.person_id; */

	  -- Bug# 5226352
	  -- Commented the above select statement and added new select to fix performance issues
	  select user_name into l_user from fnd_user a
           where a.employee_id = Approver.person_id
             and a.employee_id is not null
             and exists (select 1 from per_all_people where person_id = Approver.person_id);

        end if;

         /* Set the User Attribute */

         WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => 'CURRENT_APPROVER',
         					  avalue => l_user);
         P_resultout:='COMPLETE:Y';
          Approver.approval_status := ame_util.approvedStatus;
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);
     end if;
  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMDSC','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;



END GMD_QMDSC;

/

--------------------------------------------------------
--  DDL for Package Body GMD_SS_TEST_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_TEST_WF_PKG" AS
/* $Header: GMDQSTSB.pls 120.0 2005/05/26 00:54:01 appldev noship $ */


  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE VERIFY_EVENT(
   /* procedure to verify event and send out notifications*/
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
 l_transaction_type varchar2(100):='GMDQM_STABILITY_PARENTTEST';
 l_user varchar2(32);
 Approver ame_util.approverRecord;


   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_notify_lead number ;
   l_grace_lead number ;
   l_notify_lead_unit varchar2(10) ;
   l_grace_lead_unit varchar2(10) ;
   l_notify_ahead number;
   l_grace_ahead number;

   l_time_id number;
   l_time date ;
   l_wf_sent varchar2(10);
   l_se_id number ;
   l_disp varchar2(10);

cursor C1 is
	select NOTIFICATION_LEAD_TIME , NOTIFICATION_LEAD_TIME_UNIT,
		TESTING_GRACE_PERIOD , TESTING_GRACE_PERIOD_UNIT
	from gmd_stability_studies_b
	where ss_id = l_event_key ;

cursor C2 is
 select distinct time.time_point_id , time.scheduled_date, time.wf_sent, time.sampling_event_id
 from gmd_ss_time_points time ,
      gmd_ss_variants variant ,
      gmd_ss_material_sources sources,
      gmd_stability_studies ss
 where time.variant_id = variant.variant_id
  and sources.source_id = variant.material_source_id
  and variant.ss_id = l_event_key
  and ss.ss_id = variant.ss_id
  and nvl(variant.actual_end_date, sysdate+1) >= sysdate
  and nvl(ss.ACTUAL_END_DATE , sysdate+1) >= sysdate
  and variant.delete_mark = 0 ;

Cursor C3 (se_id_in number) is
select disposition
from gmd_sampling_events
where sampling_event_id = se_id_in ;


 BEGIN


    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('StabStudyParentTest');
       gmd_debug.put_line('Event Name ' || l_event_name );
       gmd_debug.put_line('Event Key ' || l_event_key );
    END IF;


    IF P_FUNCMODE='RUN' THEN

     /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

      /* Check which event has been raised */
      wf_log_pkg.string(6, 'Dummy','Entered Stability Study Testing '||l_event_key);

	/* Get the notification and grace time information */
          OPEN C1;
           	Fetch C1 into l_notify_lead , l_notify_lead_unit , l_grace_lead , l_grace_lead_unit  ;
	  CLOSE C1;

	 /* In case notify and grace leads are not defined, default to 0 */
	 if (l_notify_lead is null) then
		l_notify_lead := 0;
	 end if ;
	 if (l_grace_lead is null) then
		l_grace_lead := 0;
	 end if ;


         /* Get the time diff to compare to sysdate - scheduled_date */
         GET_TIME(l_notify_lead, l_notify_lead_unit, l_notify_ahead);
         GET_TIME(l_grace_lead, l_grace_lead_unit, l_grace_ahead);


         IF (l_debug = 'Y') THEN
     		  gmd_debug.put_line('Notify Lead ' || l_notify_lead);
     		  gmd_debug.put_line('Grace Lead ' || l_grace_lead);
         END IF;


	  /* Go through each timepoint and see if need to send a timepoint notification
		or late timepoint one */
          OPEN C2;
     	    LOOP
           	Fetch C2 into l_time_id, l_time, l_wf_sent, l_se_id;
		exit when C2%notfound;

		if (nvl(l_wf_sent,'##') <> 'Y')
		   and ((l_time  -  l_notify_ahead) <= sysdate) then
			/* We should send a timepoint testing workflow */

		         IF (l_debug = 'Y') THEN
     				  gmd_debug.put_line('Timepoint test ' || l_time_id);
		         END IF;
			gmd_api_pub.raise('oracle.apps.gmd.qm.ss.tp',to_char(l_time_id) );
		elsif (nvl(l_wf_sent,'##') = 'Y')
		   and ((l_time  +  l_grace_ahead) <= sysdate) then

			open C3 (l_se_id);
				fetch C3 into l_disp ;
			close C3 ;

			if ((l_disp = '0RT') or (l_disp = '1P'))  then
				/* We should send a late timepoint testing workflow */
			         IF (l_debug = 'Y') THEN
     					  gmd_debug.put_line('Late timepoint test ' || l_time_id);
			         END IF;

				gmd_api_pub.raise('oracle.apps.gmd.qm.ss.tplt',to_char(l_time_id) );
			end if;
		end if;
     	    END LOOP;
 	  CLOSE C2;

    END IF;

     /* Right now, let the workflow keep on going indefinitely */
     p_resultout:='COMPLETE:Y';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_SS_TEST_WF_PKG','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
      raise;

END VERIFY_EVENT;


/* procedure to get time as a fraction, unit of measure is days */
PROCEDURE GET_TIME(
		p_value IN NUMBER,
		p_unit IN VARCHAR2,
		p_time OUT NOCOPY NUMBER
		) IS
   l_number number := 0;

BEGIN


	if (p_unit = 'TY') then
		p_time := p_value*365;
	end if;

	if (p_unit = 'TM') then
		p_time := p_value*30;
	end if;

	if (p_unit = 'TW') then
		p_time := p_value*7;
	end if;

	if (p_unit = 'TD') then
		p_time := p_value;
	end if;

	if (p_unit = 'TH') then
		p_time := p_value / 24;
	end if;



END GET_TIME;


PROCEDURE CHECK_NEXT_APPROVER(
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
         select user_name into l_user from fnd_user
          where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
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
      WF_CORE.CONTEXT ('GMD_SS_TEST_WF_PKG','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


END GMD_SS_TEST_WF_PKG ;

/

--------------------------------------------------------
--  DDL for Package Body AMW_CM_EVENT_LISTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CM_EVENT_LISTNER_PKG" as
/*$Header: amwcmlsb.pls 120.2 2006/08/25 10:58:43 yreddy noship $*/

FUNCTION listen_cm_approval
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2
IS

l_key                      varchar2(240) := p_event.GetEventKey();
p_ChangeId  NUMBER;
p_NewApprovalStatusCode  NUMBER;
p_WorkflowRouteStatus  varchar2(240);
ename  varchar2(80);
pk1  varchar2(100);
pk2  varchar2(100);
pk3  varchar2(100);
process_id        number;
organization_id   number;
revnum            number;

begin

p_ChangeId              :=  p_event.GetValueForParameter('ChangeId');
p_NewApprovalStatusCode   :=  p_event.GetValueForParameter('NewApprovalStatusCode');
p_WorkflowRouteStatus  :=  p_event.GetValueForParameter('WorkflowRouteStatus');


select entity_name,pk1_value,pk2_value,pk3_value
into ename, pk1, pk2, pk3
from eng_change_subjects
where change_id = p_ChangeId
and change_line_id is null
and subject_level=1;

if ename = 'AMW_REVISION_ETTY' then
    process_id := pk1;
    revnum := pk2;

    if p_WorkflowRouteStatus in ('TIME_OUT', 'ABORTED') then
        AMW_PROC_APPROVAL_PKG.reject(process_id);
    else
        if p_NewApprovalStatusCode = 3 then
        	AMW_PROC_APPROVAL_PKG.sub_for_approval(p_process_id => process_id, p_webadi_call => null);
        elsif p_NewApprovalStatusCode = 5 then
        	AMW_PROC_APPROVAL_PKG.approve(process_id);
        elsif p_NewApprovalStatusCode in (4,7,8) then
                AMW_PROC_APPROVAL_PKG.reject(process_id);
        end if;
    end if;


elsif ename = 'AMW_ORG_REV_ETTY' then
    organization_id := pk1;
    process_id := pk2;
    revnum  := pk3;

    if p_WorkflowRouteStatus in ('TIME_OUT', 'ABORTED') then
        AMW_PROC_ORG_APPROVAL_PKG.reject(process_id, organization_id);
    else
        if p_NewApprovalStatusCode = 3 then
        	AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(process_id, organization_id);
        elsif p_NewApprovalStatusCode = 5 then
        	AMW_PROC_ORG_APPROVAL_PKG.approve(process_id, organization_id);
        elsif p_NewApprovalStatusCode in (4,7,8) then
            AMW_PROC_ORG_APPROVAL_PKG.reject(process_id, organization_id);
        end if;
    end if;

end if;

commit;

return 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('amw_cm_event_listner_pkg', 'listen_cm_approval', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

end listen_cm_approval;


---10.11.2005 npanandi: changed the signature of
---listen_cm_approval to the below procedure
---bug 4473863 fix
procedure UPDATE_APPROVAL_STATUS(
   p_change_id 			in number
  ,p_base_change_mgmt_type_code in varchar2
  ,p_new_approval_status_code   in varchar2
  ,p_workflow_status_code	in varchar2
  ,x_return_status		out nocopy varchar2
  ,x_msg_count			out nocopy number
  ,x_msg_data 			out nocopy varchar2
)
is
   dummy1  varchar2(100);

   ----l_key                      varchar2(240) := p_event.GetEventKey();
   p_ChangeId  NUMBER;
   p_NewApprovalStatusCode  NUMBER;
   p_WorkflowRouteStatus  varchar2(240);
   l_ename  varchar2(80);
   l_pk1    varchar2(100);
   l_pk2    varchar2(100);
   l_pk3    varchar2(100);
   l_process_id        number;
   l_organization_id   number;
   l_revnum            number;
   l_audit_project_id  number;
   l_sign_off_status   varchar2(30);

begin
   x_return_status := fnd_api.g_ret_sts_success;

   select entity_name,pk1_value,pk2_value,pk3_value
     into l_ename, l_pk1, l_pk2, l_pk3
     from eng_change_subjects
    where change_id = p_change_id
      and change_line_id is null
      and subject_level=1;

   if l_ename = 'AMW_REVISION_ETTY' then
      l_process_id := l_pk1;
      l_revnum := l_pk2;

      if p_workflow_status_code in ('TIME_OUT', 'ABORTED') then
         AMW_PROC_APPROVAL_PKG.reject(l_process_id);
      else
         if p_new_approval_status_code = 3 then
            AMW_PROC_APPROVAL_PKG.sub_for_approval(p_process_id => l_process_id, p_webadi_call => null);
         elsif p_new_approval_status_code = 5 then
            AMW_PROC_APPROVAL_PKG.approve(l_process_id);
         elsif p_new_approval_status_code in (4,7,8) then
            AMW_PROC_APPROVAL_PKG.reject(l_process_id);
         end if;
      end if;

   elsif l_ename = 'AMW_ORG_REV_ETTY' then
      l_organization_id := l_pk1;
      l_process_id := l_pk2;
      l_revnum  := l_pk3;

      if p_workflow_status_code in ('TIME_OUT', 'ABORTED') then
         AMW_PROC_ORG_APPROVAL_PKG.reject(l_process_id, l_organization_id);
      else
         if p_new_approval_status_code = 3 then
            AMW_PROC_ORG_APPROVAL_PKG.sub_for_approval(l_process_id, l_organization_id);
         elsif p_new_approval_status_code = 5 then
            AMW_PROC_ORG_APPROVAL_PKG.approve(l_process_id, l_organization_id);
         elsif p_new_approval_status_code in (4,7,8) then
            AMW_PROC_ORG_APPROVAL_PKG.reject(l_process_id, l_organization_id);
         end if;
      end if;

   elsif l_ename = 'PROJECT' then
      l_audit_project_id := l_pk1;

      if p_workflow_status_code in ('TIME_OUT', 'ABORTED') then
         l_sign_off_status := 'NOT_COMPLETED';
      else
         if p_new_approval_status_code = 3 then
            l_sign_off_status := 'PENDING_APPROVAL';
         elsif p_new_approval_status_code = 5 then
            l_sign_off_status := 'APPROVED';
         elsif p_new_approval_status_code in (4,7,8) then
            l_sign_off_status := 'REJECTED';
         end if;
      end if;

      /* update the Engagement status */
      IF l_sign_off_status = 'APPROVED' THEN
        UPDATE AMW_AUDIT_PROJECTS
        SET audit_project_status = 'SIGN',
            sign_off_status = 'APPROVED'
        WHERE AUDIT_PROJECT_ID = l_audit_project_id
          AND AUDIT_PROJECT_STATUS = 'ACTI';
      ELSE  /* Update the signOffStatus. */
        UPDATE AMW_AUDIT_PROJECTS
        SET sign_off_status = l_sign_off_status
        WHERE AUDIT_PROJECT_ID = l_audit_project_id;
      END IF;

   end if;

   commit;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
	  -- Standard call to get message count and if count=1, get the message
      fnd_msg_pub.count_and_get (p_encoded => fnd_api.g_false,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data);
end UPDATE_APPROVAL_STATUS;


end amw_cm_event_listner_pkg;

/

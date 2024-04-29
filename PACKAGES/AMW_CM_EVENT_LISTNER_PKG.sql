--------------------------------------------------------
--  DDL for Package AMW_CM_EVENT_LISTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_CM_EVENT_LISTNER_PKG" AUTHID CURRENT_USER as
/*$Header: amwcmlss.pls 120.1 2005/12/06 07:15:03 appldev noship $*/

FUNCTION listen_cm_approval
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

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
);

end amw_cm_event_listner_pkg;

 

/

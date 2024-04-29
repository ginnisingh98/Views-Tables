--------------------------------------------------------
--  DDL for Package AMW_PROJECT_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PROJECT_EVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvpjes.pls 120.1.12000000.1 2007/01/16 20:44:57 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROJECT_EVENT_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

FUNCTION Scope_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

FUNCTION Evaluation_Update
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;

PROCEDURE update_org_summary_table (
	  p_audit_project_id	IN 	NUMBER,
	  p_org_id 		IN 	NUMBER
);

PROCEDURE update_proc_summary_table (
	  p_audit_project_id	IN 	NUMBER,
	  p_org_id 		IN 	NUMBER,
	  p_proc_id		IN	NUMBER
);

PROCEDURE Synchronize_Eng_Denorm_Tables(
    errbuf       OUT NOCOPY      VARCHAR2,
    retcode      OUT NOCOPY      VARCHAR2,
    p_audit_project_id  IN       NUMBER
);

FUNCTION Update_Eng_Sign_Off_Status
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t
) return VARCHAR2;


PROCEDURE UPDATE_SIGNOFF_STATUS(
   p_change_id 			in number
  ,p_base_change_mgmt_type_code in varchar2
  ,p_new_approval_status_code   in varchar2
  ,p_workflow_status_code	in varchar2
  ,x_return_status		out nocopy varchar2
  ,x_msg_count			out nocopy number
  ,x_msg_data 			out nocopy varchar2
);

END AMW_PROJECT_EVENT_PVT;




 

/

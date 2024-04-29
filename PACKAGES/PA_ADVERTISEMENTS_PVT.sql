--------------------------------------------------------
--  DDL for Package PA_ADVERTISEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADVERTISEMENTS_PVT" AUTHID CURRENT_USER AS
--$Header: PARAVPVS.pls 120.2 2005/12/12 23:27:47 msachan noship $
--



----------------------------------------------------------------------
-- Procedure
--   Order Advertisement Action Lines
--
-- Purpose
--   Order the action lines of an advertisement action set
--   or an advertisement action lines on a requirement that have been
--   inserted into pa_action_set_lines table.
----------------------------------------------------------------------
PROCEDURE Order_Adv_Action_Lines (
  p_action_set_id                  IN  pa_action_sets.action_set_id%TYPE
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, p_object_start_date              IN  DATE        := NULL
, p_action_set_status_code         IN  pa_action_sets.status_code%TYPE := NULL
, p_action_set_actual_start_date   IN  pa_action_sets.actual_start_date%TYPE := NULL
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Publish To All
--
-- Purpose
--   Advertise to everyone
----------------------------------------------------------------------
PROCEDURE Publish_To_All (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Publish To Organizations
--
-- Purpose
--   Advertise to all resources in organizations under the starting
--   organization in the organization hierarchy.
----------------------------------------------------------------------
PROCEDURE Publish_To_Organizations (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_org_hierarchy_version_id       IN  per_org_structure_versions.org_structure_version_id%TYPE
, p_starting_organization_id       IN  hr_organization_units.organization_id%TYPE := NULL
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Escalate to Next Level
--
-- Purpose
--   Advertise to all resources in organizations under a higher starting
--   organization in the organization hierarchy.
----------------------------------------------------------------------
PROCEDURE Escalate_to_Next_Level (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_action_set_line_number         IN  pa_action_set_lines.action_set_line_number%TYPE
, p_action_set_id                  IN  pa_action_sets.action_set_id%TYPE
, p_action_set_line_rec_ver_num    IN  pa_action_set_lines.record_version_number%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_action_set_line_cond_tbl       IN  pa_action_set_utils.action_line_cond_tbl_type
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Publish To Staffing Managers
--
-- Purpose
--   Advertise to staffing managers of the specified organization.
----------------------------------------------------------------------
PROCEDURE Publish_To_Staffing_Managers (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_organization_id                IN  hr_organization_units.organization_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


----------------------------------------------------------------------
-- Procedure
--   Perform Send Email
--
-- Purpose
--   Send the advertisement email to a specific email address.
----------------------------------------------------------------------
PROCEDURE Send_Email (
 p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_email_address                  IN  VARCHAR2
, p_project_id                     IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Send Notification
--
-- Purpose
--   Send the advertisement notification to a specific person or role
--   on the project.
----------------------------------------------------------------------
PROCEDURE Send_Notification (
 p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_method                         IN  VARCHAR2
, p_person_id                      IN  pa_resources_denorm.person_id%TYPE := FND_API.G_MISS_NUM
, p_project_role_id                IN  pa_project_role_types.project_role_id%TYPE := FND_API.G_MISS_NUM
, p_project_id                     IN  pa_project_assignments.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Start Notification Workflow
--
-- Purpose
--   Start Workflow process to send advertisement notification
----------------------------------------------------------------------
PROCEDURE Start_Adv_Notification_WF (
  p_action_code                  IN  pa_action_set_lines.action_code%TYPE
, p_ntf_recipient_person_id_tbl  IN  system.pa_num_tbl_type := NULL
, p_ntf_recipient_name_tbl       IN  system.pa_varchar2_240_tbl_type := NULL
, p_wf_user_name                 IN  VARCHAR2 := NULL
, p_wf_process                   IN  VARCHAR2
, p_wf_item_type                 IN  VARCHAR2 := 'PARADVWF'
, p_assignment_id                IN  pa_project_assignments.assignment_id%TYPE
, p_project_id                   IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag            IN  VARCHAR2 := 'T'
, x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Update Staffing Priority
--
-- Purpose
--   Update the staffing priority of the requirement.
----------------------------------------------------------------------
PROCEDURE Update_Staffing_Priority (
  p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_staffing_priority_code         IN  pa_project_assignments.staffing_priority_code%TYPE
, p_record_version_number          IN  pa_project_assignments.record_version_number%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Procedure
--   Perform Remove Advertisement
--
-- Purpose
--   Remove the visibility or advertisement of the requirement.
----------------------------------------------------------------------
PROCEDURE Remove_Advertisement (
 p_action_set_line_id             IN  pa_action_set_lines.action_set_line_id%TYPE
, p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_action_code                    IN  pa_action_set_lines.action_code%TYPE
, p_action_status_code             IN  pa_action_set_lines.status_code%TYPE
, p_project_id                     IN  pa_projects_all.project_id%TYPE
, p_insert_audit_flag              IN  VARCHAR2 := 'T'
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- Start changes for 4777149
----------------------------------------------------------------------
-- Procedure
--   Perform Check  Assignment is in Open Status
--
-- Purpose
--  Check if assignment is in open status before sending the advertisement mail.
----------------------------------------------------------------------
PROCEDURE  check_assignment_open(
itemtype                        IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT NOCOPY VARCHAR2  --NOCOPY required for OUT and IN/OUT parameters
);
-- End changes for 4777149

END PA_ADVERTISEMENTS_PVT;
 

/

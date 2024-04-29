--------------------------------------------------------
--  DDL for Package PA_ADVERTISEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ADVERTISEMENTS_PUB" AUTHID CURRENT_USER AS
--$Header: PARAVPBS.pls 120.1 2005/08/19 16:48:50 mwasowic noship $
--

-- global variable to store the audit lines to be returned
-- to the generic action set api when an action line is performed
g_action_line_audit_tbl pa_action_set_utils.insert_audit_lines_tbl_type;

-- global variable to store the start advertisement action set flag
g_start_adv_action_set_flag VARCHAR2(1) := NULL;

----------------------------------------------------------------------
-- Procedure
--   Validate Advertisement Action Line
--
-- Purpose
--   This API is currently empty.
--   Validate a single action line of an advertisement action set
--   template or an advertisement action set on a requirement.
----------------------------------------------------------------------
PROCEDURE Validate_Action_Set_Line (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


----------------------------------------------------------------------
-- Procedure
--   Process Advertisement Action Set
--
-- Purpose
--   Re-order the action lines and validate the advertisement
--   action set or advertisement action lines on a requirement.
--   Invoked when a new action set is created, an existing action
--   set or action lines on the requirement are updated, or an action
--   set is started on a requirement.
----------------------------------------------------------------------
PROCEDURE Process_Action_Set (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


----------------------------------------------------------------------
-- Procedure
--   Perform Advertisement Action Set Line
--
-- Purpose
--   Invoked by the generic perform action set API to perform an action
--   line in the advertisement action set on an object.
----------------------------------------------------------------------
PROCEDURE Perform_Action_Set_Line (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_details_rec         IN  pa_action_sets%ROWTYPE
, p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
, x_action_line_audit_tbl          OUT NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type  -- For 1159 mandate changes bug#2674619
, x_action_line_result_code        OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


----------------------------------------------------------------------
-- Procedure
--   Reevaluate Advertisement Action Set
--
-- Purpose
--   Re-evaluate the advertisement action lines on the requirement by
--   updating the statuses of the action lines based on the
--   condition and the new requirement start date.
----------------------------------------------------------------------
PROCEDURE Reevaluate_Adv_Action_Set (
  p_object_id                      IN  pa_action_sets.object_id%TYPE
, p_object_type                    IN  pa_action_sets.object_type%TYPE
, p_new_object_start_date          IN  DATE
, p_validate_only                  IN  VARCHAR2    := FND_API.G_TRUE
, p_api_version                    IN  NUMBER      := 1.0
, p_init_msg_list                  IN  VARCHAR2    := FND_API.G_FALSE
, p_commit                         IN  VARCHAR2    := FND_API.G_FALSE
, x_return_status                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

----------------------------------------------------------------------
-- Function
--   Is Action Set Started On Apply
--
-- Purpose
--   Check if the action set should be started upon application.
----------------------------------------------------------------------
FUNCTION Is_Action_Set_Started_On_Apply(
 p_action_set_type_code   IN pa_action_sets.action_set_type_code%TYPE
,p_object_type            IN pa_action_sets.object_type%TYPE
,p_object_id              IN pa_action_sets.object_id%TYPE
) RETURN VARCHAR2;


END PA_ADVERTISEMENTS_PUB;
 

/

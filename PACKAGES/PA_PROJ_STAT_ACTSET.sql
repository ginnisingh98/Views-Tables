--------------------------------------------------------
--  DDL for Package PA_PROJ_STAT_ACTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STAT_ACTSET" AUTHID CURRENT_USER as
/* $Header: PAASPSS.pls 115.12 2003/04/08 18:46:48 mwasowic noship $ */
/*=======================================================================*/
-- Procedure
--   Perform Project Status Report (Reminder) Action Set
--
-- Purpose
--   Invoked by the generic perform action set API to perform action
--   lines in the reminder action set of type PA_PROJ_STATUS_REPORT
--   or PA_TASK_PROGRESS on an project.

-- global table to store the audit lines
g_action_line_audit_tbl pa_action_set_utils.insert_audit_lines_tbl_type;


/*=======================================================================*/
-- Procedure
--   Process Action Set
-- Purpose
--   Validate the action set or action lines.
--   Invoked when a new action set is created, an existing action
--   set or action lines on the requirement are updated, or an action
--   set is started on a requirement.
/*=======================================================================*/
PROCEDURE Process_Action_Set (
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2
);


/*=======================================================================*/
  PROCEDURE perform_action_set_line                    /* Default value N added for bug#2463257 */
  (p_action_set_type_code  IN   pa_action_sets.action_set_type_code%TYPE:='PA_PROJ_STATUS_REPORT',
  p_action_set_details_rec       IN   pa_action_sets%ROWTYPE,
  p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
  p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
  x_action_line_audit_tbl       OUT NOCOPY   pa_action_set_utils.insert_audit_lines_tbl_type,
  x_action_line_result_code     OUT NOCOPY   VARCHAR2);
/*=======================================================================*/
-- Procedure
--   Validate Project Status Report (Reminder) Action Set Line
--
-- Purpose
--   Invoked by the generic validate action set API to validate action
--   line in the reminder action set of type PA_PROJ_STATUS_REPORT
--   or PA_TASK_PROGRESS on an project.
/*=======================================================================*/
PROCEDURE validate_action_set_line (
  p_action_set_type_code    IN  VARCHAR2    := 'PA_PROJ_STATUS_REPORT'
, p_action_set_line_rec     IN pa_action_set_lines%ROWTYPE
, p_action_line_conditions_tbl     IN pa_action_set_utils.action_line_cond_tbl_type
, x_return_status                  OUT NOCOPY VARCHAR2
);
/*=======================================================================*/
-- Procedure
--   Validate Project Status Reports (Reminder) Action Set Line
--
-- Purpose
--   Invoked by the generic validate action set API to validate action
--   line in the reminder action set of type PA_PROJ_STATUS_REPORT
--   or PA_TASK_PROGRESS on an project.
/*=======================================================================*/
PROCEDURE validate_action_set (
  p_action_set_type_code           IN  VARCHAR2  := 'PA_PROJ_STATUS_REPORT'
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  VARCHAR2
, x_return_status                  OUT NOCOPY VARCHAR2
);

/*=======================================================================*/
FUNCTION validate_action_type_code (
  p_action_set_type_code           IN  VARCHAR2
  ) return BOOLEAN;

/*=======================================================================*/
--FUNCTION get_project_id (
--  p_action_set_type_code           IN  VARCHAR2
-- ,p_action_set_line_rec            IN  VARCHAR2
--  ) return NUMBER;

/*=======================================================================*/
FUNCTION action_allowed_for_status (
   p_project_id              IN  NUMBER
  ,p_project_status          IN  VARCHAR2
  ) return BOOLEAN;

FUNCTION project_dates_valid (
   p_project_id              IN  NUMBER
  ) return VARCHAR2;


FUNCTION ok_to_perform_action (
   p_report_date                IN pa_object_page_layouts.next_reporting_date%TYPE
  ,p_action_set_line_rec        IN pa_action_set_lines%ROWTYPE
  ,p_action_line_conditions_tbl IN pa_action_set_utils.action_line_cond_tbl_type
  ) return BOOLEAN;

PROCEDURE  perform_selected_action(
    p_project_id                     IN  NUMBER
   ,p_report_type_id                 IN  NUMBER
   ,p_layout_id                      IN  NUMBER
   ,p_action_set_type_code           IN  VARCHAR2
   ,p_action_set_line_rec            IN  pa_action_set_lines%ROWTYPE
   ,p_action_line_conditions_tbl     IN  pa_action_set_utils.action_line_cond_tbl_type
   ,x_action_performed               OUT NOCOPY VARCHAR2
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2);


PROCEDURE copy_action_sets(
    p_project_id_from   IN  NUMBER
   ,p_project_id_to     IN  NUMBER
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2);


--FUNCTION get_number_of_days(
--        p_action_line_conditions_tbl  IN pa_action_set_utils.action_line_cond_tbl_type
--        ) return NUMBER;

FUNCTION is_action_repeating(
        p_action_line_conditions_tbl  IN pa_action_set_utils.action_line_cond_tbl_type
        ) return BOOLEAN;

PROCEDURE delete_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code    IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_PROJ_STATUS_REPORT'
 ,p_object_type             IN    pa_action_sets.object_type%TYPE             := 'PA_PROJ_STATUS_REPORTS'
 ,p_object_id               IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_record_version_number   IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,p_api_version             IN    NUMBER               := 1.0
 ,p_commit                  IN    VARCHAR2             := FND_API.G_FALSE
 ,p_validate_only           IN    VARCHAR2             := FND_API.G_TRUE
 ,p_init_msg_list           IN    VARCHAR2             := FND_API.G_TRUE
 ,x_return_status          OUT NOCOPY    VARCHAR2
 ,x_msg_count              OUT NOCOPY    NUMBER
 ,x_msg_data               OUT NOCOPY    VARCHAR2
);


PROCEDURE update_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code    IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_PROJ_STATUS_REPORT'
 ,p_object_type             IN    pa_action_sets.object_type%TYPE             := 'PA_PROJ_STATUS_REPORTS'
 ,p_object_id               IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_perform_action_set_flag IN    VARCHAR2             := 'N'
 ,p_record_version_number   IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,p_api_version             IN    NUMBER               := 1.0
 ,p_commit                  IN    VARCHAR2             := FND_API.G_FALSE
 ,p_validate_only           IN    VARCHAR2             := FND_API.G_TRUE
 ,p_init_msg_list           IN    VARCHAR2             := FND_API.G_TRUE
 ,x_new_action_set_id      OUT NOCOPY    NUMBER
 ,x_return_status          OUT NOCOPY    VARCHAR2
 ,x_msg_count              OUT NOCOPY    NUMBER
 ,x_msg_data               OUT NOCOPY    VARCHAR2
);

END;

 

/

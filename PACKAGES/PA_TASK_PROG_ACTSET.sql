--------------------------------------------------------
--  DDL for Package PA_TASK_PROG_ACTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_PROG_ACTSET" AUTHID CURRENT_USER as
/* $Header: PAASTPS.pls 115.7 2003/04/08 18:46:23 mwasowic noship $ */
/*=======================================================================*/
-- Procedure
--   Perform Task Progress (Reminder) Action Set
--
-- Purpose
--   Invoked by the generic perform action set API to perform action
--   lines in the reminder action set of type
--   PA_TASK_PROGRESS on an project.

/*=======================================================================*/

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
  p_action_set_type_code           IN  pa_action_sets.action_set_type_code%TYPE := 'PA_TASK_PROGRESS'
, p_action_set_id                  IN  NUMBER
, p_action_set_template_flag       IN  pa_action_sets.action_set_template_flag%TYPE :=NULL
, x_return_status                  OUT NOCOPY VARCHAR2
);
/*=======================================================================*/

  PROCEDURE perform_action_set_line(p_action_set_type_code    IN   VARCHAR2 := 'PA_TASK_PROGRESS',
                                     p_action_set_details_rec       IN   pa_action_sets%ROWTYPE,
                                     p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
                                     p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
                                     x_action_line_audit_tbl       OUT NOCOPY   pa_action_set_utils.insert_audit_lines_tbl_type,
                                     x_action_line_result_code     OUT NOCOPY   VARCHAR2);


/*=======================================================================*/

PROCEDURE copy_action_sets(
    p_project_id_from   IN  NUMBER
   ,p_project_id_to     IN  NUMBER
   ,x_return_status                  OUT NOCOPY VARCHAR2
   ,x_msg_count                      OUT NOCOPY NUMBER
   ,x_msg_data                       OUT NOCOPY VARCHAR2);


FUNCTION validate_action_type_code (
  p_action_set_type_code           IN  VARCHAR2
  ) return BOOLEAN;

FUNCTION action_allowed_for_status (
   p_project_id              IN  NUMBER
  ,p_project_status          IN  VARCHAR2
  ) return BOOLEAN;

FUNCTION ok_to_perform_action (
   p_project_id              IN  NUMBER
  ,p_proj_start_date                IN  DATE
  ) return BOOLEAN;


FUNCTION is_action_repeating(
        p_action_line_conditions_tbl  IN pa_action_set_utils.action_line_cond_tbl_type
        ) return BOOLEAN;


PROCEDURE delete_action_set
 (p_action_set_id          IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code   IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_TASK_PROGRESS'
 ,p_object_type            IN    pa_action_sets.object_type%TYPE             := 'PA_PROJECTS'
 ,p_object_id              IN    pa_action_sets.object_id%TYPE               := NULL
 ,p_record_version_number  IN    pa_action_sets.record_version_number%TYPE   := NULL
 ,p_api_version            IN    NUMBER               := 1.0
 ,p_commit                 IN    VARCHAR2             := FND_API.G_FALSE
 ,p_validate_only          IN    VARCHAR2             := FND_API.G_TRUE
 ,p_init_msg_list          IN    VARCHAR2             := FND_API.G_TRUE
 ,x_return_status         OUT NOCOPY    VARCHAR2
 ,x_msg_count             OUT NOCOPY    NUMBER
 ,x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE update_action_set
 (p_action_set_id           IN    pa_action_sets.action_set_id%TYPE           := NULL
 ,p_action_set_type_code    IN    pa_action_sets.action_set_type_code%TYPE    := 'PA_TASK_PROGRESS'
 ,p_object_type             IN    pa_action_sets.object_type%TYPE             := 'PA_PROJECTS'
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

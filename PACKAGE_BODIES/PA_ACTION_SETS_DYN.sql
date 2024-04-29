--------------------------------------------------------
--  DDL for Package Body PA_ACTION_SETS_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACTION_SETS_DYN" AS
  PROCEDURE validate_action_set_line(p_action_set_type_code          IN   VARCHAR2,
                                      p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
                                      p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
                                      x_return_status               OUT   NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
  IS
  BEGIN
  NULL;
  END;
  PROCEDURE process_action_set(p_action_set_type_code         IN   VARCHAR2,
                                 p_action_set_id                IN   NUMBER,
                                 p_action_set_template_flag     IN   VARCHAR2,
                                 x_return_status               OUT   NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
  IS
  BEGIN
  NULL;
  
        IF p_action_set_type_code = 'ADVERTISEMENT' THEN
            PA_ADVERTISEMENTS_PUB.Process_Action_Set
                                  (p_action_set_type_code       => 'ADVERTISEMENT',
                                   p_action_set_id              => p_action_set_id,
                                   p_action_set_template_flag   => p_action_set_template_flag,
                                   x_return_status              => x_return_status);
        END IF;
        
        IF p_action_set_type_code = 'PA_PROJ_STATUS_REPORT' THEN
            PA_PROJ_STAT_ACTSET.PROCESS_ACTION_SET
                                  (p_action_set_type_code       => 'PA_PROJ_STATUS_REPORT',
                                   p_action_set_id              => p_action_set_id,
                                   p_action_set_template_flag   => p_action_set_template_flag,
                                   x_return_status              => x_return_status);
        END IF;
        
        IF p_action_set_type_code = 'PA_TASK_PROGRESS' THEN
            PA_TASK_PROG_ACTSET.PROCESS_ACTION_SET
                                  (p_action_set_type_code       => 'PA_TASK_PROGRESS',
                                   p_action_set_id              => p_action_set_id,
                                   p_action_set_template_flag   => p_action_set_template_flag,
                                   x_return_status              => x_return_status);
        END IF;
        END;
  FUNCTION Is_Action_Set_Started_On_Apply(p_action_set_type_code         IN   VARCHAR2,
                                          p_object_type                  IN   VARCHAR2,
                                          p_object_id                    IN   NUMBER)
     RETURN VARCHAR2
  IS
   l_is_action_set_started  VARCHAR2(1);
  BEGIN
  NULL;
  
        IF p_action_set_type_code = 'ADVERTISEMENT' THEN
              l_is_action_set_started := PA_ADVERTISEMENTS_PUB.Is_Action_Set_Started_On_Apply
                                             (p_action_set_type_code       => 'ADVERTISEMENT',
                                              p_object_type                => p_object_type,
                                              p_object_id                  => p_object_id);  
           RETURN l_is_action_set_started;
        END IF;
        
        IF p_action_set_type_code = 'PA_PROJ_STATUS_REPORT' THEN
              l_is_action_set_started := 'Y';
           RETURN l_is_action_set_started;
        END IF;
        
        IF p_action_set_type_code = 'PA_TASK_PROGRESS' THEN
              l_is_action_set_started := 'Y';
           RETURN l_is_action_set_started;
        END IF;
        END;
 PROCEDURE get_action_set_line_ids( p_action_set_type_code        IN   VARCHAR2,
                                    p_project_number_from         IN   VARCHAR2,
                                    p_project_number_to           IN   VARCHAR2,
                                    x_action_set_line_id_tbl      OUT  NOCOPY pa_action_set_utils.action_set_line_id_tbl_type, -- For 1159 mandate changes bug#2674619
                                    x_object_name_tbl             OUT  NOCOPY pa_action_set_utils.object_name_tbl_type, -- For 1159 mandate changes bug#2674619
                                    x_project_number_tbl          OUT  NOCOPY pa_action_set_utils.project_number_tbl_type -- For 1159 mandate changes bug#2674619
                                    )
  IS
  BEGIN
  NULL;
  
     IF p_action_set_type_code = 'ADVERTISEMENT' THEN
       -- 2778044: Removed the nvl statement on project_number to allow CBO to use
       -- indexes properly.
       IF p_project_number_from IS NOT NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_ADV_RULE_OBJECTS_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number BETWEEN p_project_number_from  AND p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NOT NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_ADV_RULE_OBJECTS_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number >= p_project_number_from
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_ADV_RULE_OBJECTS_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number <= p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_ADV_RULE_OBJECTS_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE
                 conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        END IF;
        -- End fixes for 2778044
     END IF;
     
     IF p_action_set_type_code = 'PA_PROJ_STATUS_REPORT' THEN
       -- 2778044: Removed the nvl statement on project_number to allow CBO to use
       -- indexes properly.
       IF p_project_number_from IS NOT NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_PROJ_STATUS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number BETWEEN p_project_number_from  AND p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NOT NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_PROJ_STATUS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number >= p_project_number_from
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_PROJ_STATUS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number <= p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_PROJ_STATUS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE
                 conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        END IF;
        -- End fixes for 2778044
     END IF;
     
     IF p_action_set_type_code = 'PA_TASK_PROGRESS' THEN
       -- 2778044: Removed the nvl statement on project_number to allow CBO to use
       -- indexes properly.
       IF p_project_number_from IS NOT NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_TASK_PROGRESS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number BETWEEN p_project_number_from  AND p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NOT NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_TASK_PROGRESS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number >= p_project_number_from
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NOT NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_TASK_PROGRESS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE project_number <= p_project_number_to
             AND conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        ELSIF p_project_number_from IS NULL AND p_project_number_to IS NULL THEN
          SELECT alines.action_set_line_id,
                 conc_view.object_name,
                 conc_view.project_number
            BULK COLLECT INTO x_action_set_line_id_tbl,
                   x_object_name_tbl,
                   x_project_number_tbl
            FROM PA_TASK_PROGRESS_REMINDER_V conc_view,
                 pa_action_sets asets,
                 pa_action_set_lines alines
           WHERE
                 conc_view.object_type = asets.object_type
             AND conc_view.object_id = asets.object_id
             AND asets.action_set_type_code = nvl(p_action_set_type_code, asets.action_set_type_code)
             AND asets.status_code IN ('STARTED', 'RESUMED')
             AND asets.action_set_id = alines.action_set_id
             AND alines.status_code IN ('PENDING', 'ACTIVE', 'REVERSE_PENDING', 'UPDATE_PENDING')
          ORDER BY alines.action_set_line_number;
        END IF;
        -- End fixes for 2778044
     END IF;
     END;
  PROCEDURE perform_action_set_line(p_action_set_type_code          IN   VARCHAR2,
                                     p_action_set_details_rec       IN   pa_action_sets%ROWTYPE,
                                     p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
                                     p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
                                     x_action_line_audit_tbl       OUT   NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type, -- For 1159 mandate changes bug#2674619
                                     x_action_line_result_code     OUT   NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
  IS
  BEGIN
  NULL;
  
        IF p_action_set_type_code = 'ADVERTISEMENT' THEN
            PA_ADVERTISEMENTS_PUB.Perform_Action_Set_Line
                                  (p_action_set_type_code       => 'ADVERTISEMENT',
                                   p_action_set_details_rec     => p_action_set_details_rec,
                                   p_action_set_line_rec        => p_action_set_line_rec,
                                   p_action_line_conditions_tbl => p_action_line_conditions_tbl,
                                   x_action_line_audit_tbl      => x_action_line_audit_tbl,
                                   x_action_line_result_code    => x_action_line_result_code);
        END IF;
        
        IF p_action_set_type_code = 'PA_PROJ_STATUS_REPORT' THEN
            PA_PROJ_STAT_ACTSET.PERFORM_ACTION_SET_LINE
                                  (p_action_set_type_code       => 'PA_PROJ_STATUS_REPORT',
                                   p_action_set_details_rec     => p_action_set_details_rec,
                                   p_action_set_line_rec        => p_action_set_line_rec,
                                   p_action_line_conditions_tbl => p_action_line_conditions_tbl,
                                   x_action_line_audit_tbl      => x_action_line_audit_tbl,
                                   x_action_line_result_code    => x_action_line_result_code);
        END IF;
        
        IF p_action_set_type_code = 'PA_TASK_PROGRESS' THEN
            PA_TASK_PROG_ACTSET.PERFORM_ACTION_SET_LINE
                                  (p_action_set_type_code       => 'PA_TASK_PROGRESS',
                                   p_action_set_details_rec     => p_action_set_details_rec,
                                   p_action_set_line_rec        => p_action_set_line_rec,
                                   p_action_line_conditions_tbl => p_action_line_conditions_tbl,
                                   x_action_line_audit_tbl      => x_action_line_audit_tbl,
                                   x_action_line_result_code    => x_action_line_result_code);
        END IF;
        END;END;

/

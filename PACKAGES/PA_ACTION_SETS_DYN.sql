--------------------------------------------------------
--  DDL for Package PA_ACTION_SETS_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SETS_DYN" AUTHID CURRENT_USER AS
/*$Header: PARASDYS.pls 120.1 2005/08/19 16:47:55 mwasowic noship $*/


PROCEDURE validate_action_set_line(p_action_set_type_code         IN   VARCHAR2,
                                      p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
                                      p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
                                      x_return_status               OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE process_action_set(p_action_set_type_code            IN   VARCHAR2,
                                 p_action_set_id                IN   NUMBER,
                                 p_action_set_template_flag     IN   VARCHAR2,
                                 x_return_status               OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE perform_action_set_line(p_action_set_type_code         IN   VARCHAR2,
                                     p_action_set_details_rec       IN   pa_action_sets%ROWTYPE,
                                     p_action_set_line_rec          IN   pa_action_set_lines%ROWTYPE,
                                     p_action_line_conditions_tbl   IN   pa_action_set_utils.action_line_cond_tbl_type,
                                     x_action_line_audit_tbl       OUT   NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type,  -- For 1159 mandate changes bug#2674619
                                     x_action_line_result_code     OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


 PROCEDURE get_action_set_line_ids( p_action_set_type_code        IN   VARCHAR2,
                                    p_project_number_from          IN   VARCHAR2,
                                    p_project_number_to           IN   VARCHAR2,
                                    x_action_set_line_id_tbl     OUT   NOCOPY pa_action_set_utils.action_set_line_id_tbl_type,  -- For 1159 mandate changes bug#2674619
                                    x_object_name_tbl             OUT  NOCOPY pa_action_set_utils.object_name_tbl_type, -- For 1159 mandate changes bug#2674619
                                    x_project_number_tbl          OUT  NOCOPY pa_action_set_utils.project_number_tbl_type  -- For 1159 mandate changes bug#2674619
                                    );

  FUNCTION Is_Action_Set_Started_On_Apply(p_action_set_type_code         IN   VARCHAR2,
                                          p_object_type                  IN   VARCHAR2,
                                          p_object_id                    IN   NUMBER)
     RETURN VARCHAR2;

END;

 

/

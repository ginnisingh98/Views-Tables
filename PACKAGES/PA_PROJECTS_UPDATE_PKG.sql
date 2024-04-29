--------------------------------------------------------
--  DDL for Package PA_PROJECTS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECTS_UPDATE_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRPK2S.pls 120.1 2005/08/19 17:24:24 mwasowic noship $ */

--
-- Procedure     : Insert_row
-- Purpose       : Create Row in PA_PROJECTS_UPDATE_TEMP.
--
--
PROCEDURE insert_row
      ( p_project_name                    IN pa_projects_update_temp.project_name%TYPE,
	      p_project_number		              IN pa_projects_update_temp.project_number%TYPE,
        p_project_status_name             IN pa_projects_update_temp.project_status_name%TYPE,
        p_old_probability                 IN pa_projects_update_temp.old_probability%TYPE,
        p_new_probability		              IN pa_projects_update_temp.new_probability%TYPE,
        p_old_value                       IN pa_projects_update_temp.old_value%TYPE,
        p_new_value			                  IN pa_projects_update_temp.new_value%TYPE,
        p_old_value_currency              IN pa_projects_update_temp.old_value_currency%TYPE,
        p_new_value_currency              IN pa_projects_update_temp.new_value_currency%TYPE,
        p_old_exp_proj_apprvl_date        IN pa_projects_update_temp.old_expected_proj_apprvl_date%TYPE,
        p_new_exp_proj_apprvl_date        IN pa_projects_update_temp.new_expected_proj_apprvl_date%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          ,  --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            ,  --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_PROJECTS_UPDATE_PKG;

 

/

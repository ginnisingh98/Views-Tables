--------------------------------------------------------
--  DDL for Package PA_TASK_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_MANAGER" AUTHID CURRENT_USER as
/* $Header: PATMUPGS.pls 120.1 2005/08/19 17:04:34 mwasowic noship $ */

/* Function to get the profile option value  */
 function get_profile_value (p_name IN VARCHAR2) return VARCHAR2;

/* Procedure to check the break periods if the task manager is existing as a project member */
 procedure validate_member_exists ( p_project_id              IN  NUMBER,
                                    p_task_manager_person_id  IN  NUMBER,
                                    p_proj_role_id            IN  NUMBER,
                                    p_start_date_active       IN  DATE,
                                    p_end_date_active         IN  DATE,
                                    p_project_end_date        IN  DATE);

/* Main Procedure to upgrade the task managers as project members */
 procedure upgrade_task_manager ( errbuf                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				  retcode               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 				  p_project_num_from    IN  VARCHAR2,
				  p_project_num_to      IN  VARCHAR2,
				  p_project_role        IN  VARCHAR2,
	                          p_project_org         IN  NUMBER,
			          p_project_type        IN  VARCHAR2);

/* procedure to print the debug messages in the log file */
 procedure tm_log ( p_message IN VARCHAR2 );

/* procedure to print the data in the output report for the concurrent process */
 procedure tm_out ( p_project_id              IN NUMBER,
                    p_task_manager_person_id  IN NUMBER,
                    p_message                 IN VARCHAR2);

/* procedure to print the output report for the concurrent process */
 procedure print_output (p_project_num_from    IN  VARCHAR2,
                         p_project_num_to      IN  VARCHAR2,
                         p_project_role        IN  VARCHAR2,
                         p_project_org         IN  NUMBER,
                         p_project_type        IN  VARCHAR2);
END PA_TASK_MANAGER;
 

/

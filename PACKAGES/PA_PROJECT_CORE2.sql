--------------------------------------------------------
--  DDL for Package PA_PROJECT_CORE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CORE2" AUTHID CURRENT_USER as
-- $Header: PAXPCO2S.pls 120.1 2005/08/19 17:16:13 mwasowic noship $

--
--  PROCEDURE
--              copy_task
--  PURPOSE
--
--              The objective of this procedure is to create a new
--              tasks for a project by copying the tasks of another project.
--              Task level information such as transaction controls, billing
--              assignment, project asset assignments, percent completes,
--              burden schedules, and overrides will also be copied.
--
--              Users must pass in x_orig_project_id and x_new_project_id.
--
procedure copy_task (     x_orig_project_id     	IN        number
                        , x_new_project_id      	IN        number
                        , x_err_code                    IN OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_err_stage                   IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_err_stack                   IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895


-- ------------------------------------------------------------
-- Create_Def_Prj_Stus_Controls
--   This procedure creates the default project status controls
--   for a new project status.  The defaults are created from
--   the system status of the new status being created.
--
--   This procedure should be called after inserting a new
--   project status.
-- ------------------------------------------------------------

PROCEDURE Create_Def_Prj_Stus_Controls(
			X_Project_Status_Code		IN	VARCHAR2,
			X_Project_System_Status_Code	IN	VARCHAR2,
			X_err_code			IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_err_stage			IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_err_stack			IN OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


end PA_PROJECT_CORE2 ;

 

/

--------------------------------------------------------
--  DDL for Package PA_FP_CI_INCLUDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CI_INCLUDE_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPINCS.pls 120.1 2005/08/19 16:26:54 mwasowic noship $ */

--Copy exception
RAISE_COPY_CI_ERROR   EXCEPTION;
PRAGMA EXCEPTION_INIT(RAISE_COPY_CI_ERROR, -503);


 PROCEDURE FP_CI_COPY_CONTROL_ITEMS
 (
   p_project_id			IN pa_budget_versions.project_id%TYPE,
   p_source_ci_id_tbl		IN PA_PLSQL_DATATYPES.IdTabTyp,
   p_target_ci_id		IN pa_budget_versions.ci_id%TYPE,
   p_merge_unmerge_mode		IN VARCHAR2 DEFAULT 'MERGE',
   p_commit_flag		IN VARCHAR2 DEFAULT 'N',
   p_init_msg_list		IN VARCHAR2 DEFAULT 'N',
   p_calling_context		IN VARCHAR2 DEFAULT 'COPY',
   x_warning_flag		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_data          		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count         		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_return_status     		OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

/*=============================================================================
 This api is called to create financial realted impacts in pa_ci_impacts during
 change document inclusion or change document copy.

 02-Jul-2004   rravipat  Bug 3677924
                         Initial Creation
==============================================================================*/

PROCEDURE populate_ci_fin_impact_records(
          p_project_id           IN   pa_projects_all.project_id%TYPE
          ,p_source_ci_id        IN   pa_budget_versions.ci_id%TYPE
          ,p_target_ci_id        IN   pa_budget_versions.ci_id%TYPE
          ,p_calling_context     IN   VARCHAR2
          ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data            OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_fp_ci_include_pkg;

 

/

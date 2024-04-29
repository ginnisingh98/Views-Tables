--------------------------------------------------------
--  DDL for Package PA_FP_EXCLUDED_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_EXCLUDED_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPXELS.pls 120.1 2005/08/19 16:32:11 mwasowic noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PA_FP_EXCLUDED_ELEMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PAFPEXLS.pls';

PROCEDURE Insert_Row
(
 p_proj_fp_options_id           IN pa_fp_excluded_elements.proj_fp_options_id%TYPE    := Null
,p_project_id                   IN pa_fp_excluded_elements.project_id%TYPE            := Null
,p_fin_plan_type_id             IN pa_fp_excluded_elements.fin_plan_type_id%TYPE      := Null
,p_element_type                 IN pa_fp_excluded_elements.element_type%TYPE          := Null
,p_fin_plan_version_id          IN pa_fp_excluded_elements.fin_plan_version_id%TYPE   := Null
,p_task_id                      IN pa_fp_excluded_elements.task_id%TYPE               := Null
,x_row_id                       OUT NOCOPY ROWID --File.Sql.39 bug 4440895
,x_return_status                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
(
 p_proj_fp_options_id           IN pa_fp_excluded_elements.proj_fp_options_id%TYPE    := Null
,p_project_id                   IN pa_fp_excluded_elements.project_id%TYPE            := Null
,p_fin_plan_type_id             IN pa_fp_excluded_elements.fin_plan_type_id%TYPE      := Null
,p_element_type                 IN pa_fp_excluded_elements.element_type%TYPE          := Null
,p_fin_plan_version_id          IN pa_fp_excluded_elements.fin_plan_version_id%TYPE   := Null
,p_task_id                      IN pa_fp_excluded_elements.task_id%TYPE               := Null
,p_record_version_number        IN pa_fp_excluded_elements.record_version_number%TYPE := Null
,p_row_id                       IN ROWID                                              := Null
,x_return_status                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_proj_fp_options_id          IN pa_fp_excluded_elements.proj_fp_options_id%TYPE    := Null
 ,p_element_type                IN pa_fp_excluded_elements.element_type%TYPE          := Null
 ,p_task_id                     IN pa_fp_excluded_elements.task_id%TYPE               := Null
 ,p_row_id                      IN ROWID
 ,p_record_version_number       IN NUMBER                                             := Null
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_row_id                         IN ROWID
 ,p_record_version_number          IN NUMBER                                          := Null
 ,x_return_status                  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fp_excluded_elements_pkg;

 

/

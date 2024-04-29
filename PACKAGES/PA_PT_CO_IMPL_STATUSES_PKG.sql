--------------------------------------------------------
--  DDL for Package PA_PT_CO_IMPL_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PT_CO_IMPL_STATUSES_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPCOIS.pls 120.1 2005/08/19 16:25:37 mwasowic noship $ */

/*==================================================================
   API for inserting into the table
 ==================================================================*/
PROCEDURE INSERT_ROW (
      p_pt_co_impl_statuses_id           IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                 IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                       IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                     IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                      IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_impl_default_flag                IN       pa_pt_co_impl_statuses.impl_default_flag%TYPE,
      x_row_id                           OUT      NOCOPY ROWID, --File.Sql.39 bug 4440895
      x_return_status                    OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                        OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                         OUT      NOCOPY VARCHAR2);         --File.Sql.39 bug 4440895

/*==================================================================
   API for updating records of the table
 ==================================================================*/
PROCEDURE UPDATE_ROW (
      p_pt_co_impl_statuses_id           IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                 IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                       IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                     IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                      IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_impl_default_flag                IN       pa_pt_co_impl_statuses.impl_default_flag%TYPE,
      p_record_version_number            IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_lock_row                         IN       VARCHAR2,
      x_return_status                    OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                        OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                         OUT      NOCOPY VARCHAR2);           --File.Sql.39 bug 4440895

/*==================================================================
   API for deleting records of the table
 ==================================================================*/
PROCEDURE DELETE_ROW (
      p_pt_co_impl_statuses_id           IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_fin_plan_type_id                 IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                       IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                     IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                      IN       pa_pt_co_impl_statuses.status_code%TYPE,
      p_record_version_number            IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_lock_row                         IN       VARCHAR2,
      x_return_status                    OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                        OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                         OUT      NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*==================================================================
   API for locking records of the table
 ==================================================================*/
PROCEDURE LOCK_ROW (
      p_row_id                          IN       ROWID,
      p_pt_co_impl_statuses_id          IN       pa_pt_co_impl_statuses.pt_co_impl_statuses_id%TYPE,
      p_record_version_number           IN       pa_pt_co_impl_statuses.record_version_number%TYPE,
      p_fin_plan_type_id                IN       pa_pt_co_impl_statuses.fin_plan_type_id%TYPE,
      p_ci_type_id                      IN       pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                    IN       pa_pt_co_impl_statuses.version_type%TYPE,
      p_status_code                     IN       pa_pt_co_impl_statuses.status_code%TYPE,
      x_return_status                   OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                       OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                        OUT      NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PT_CO_IMPL_STATUSES_PKG;

 

/

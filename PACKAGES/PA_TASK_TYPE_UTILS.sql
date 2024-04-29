--------------------------------------------------------
--  DDL for Package PA_TASK_TYPE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_TYPE_UTILS" AUTHID CURRENT_USER AS
/*$Header: PATTUTLS.pls 120.1 2005/08/19 17:06:45 mwasowic noship $*/

FUNCTION is_task_type_unique(p_task_type      IN  VARCHAR2,
                             p_task_type_id   IN  NUMBER := NULL) RETURN VARCHAR2;

PROCEDURE change_task_type_allowed(p_task_id IN NUMBER,
          p_from_task_type_id     IN NUMBER,
          p_to_task_type_id       IN NUMBER,
          x_change_allowed        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE change_wi_allowed(p_task_id IN NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE change_uom_allowed(p_task_id IN NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_planned_quantity(p_planned_quantity IN NUMBER,
          p_actual_work_quantity  IN  NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_page_layout_referenced(
p_page_id    NUMBER ) RETURN BOOLEAN;

PROCEDURE validate_progress_attributes(
           p_prog_entry_enable_flag        IN VARCHAR2
          ,p_prog_entry_req_flag           IN VARCHAR2
          ,p_initial_progress_status_code  IN VARCHAR2
          ,p_task_prog_entry_page_id       IN NUMBER
          ,p_wq_enable_flag                IN VARCHAR2
          ,p_work_item_code                IN VARCHAR2
          ,p_uom_code                      IN VARCHAR2
          ,p_actual_wq_entry_code          IN VARCHAR2
          ,p_percent_comp_enable_flag      IN VARCHAR2
          ,p_base_percent_comp_deriv_code  IN VARCHAR2
          ,p_task_weighting_deriv_code     IN VARCHAR2
          ,p_remain_effort_enable_flag     IN VARCHAR2
          ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_tk_type_effective(p_task_type_id IN NUMBER)
         RETURN VARCHAR2;

FUNCTION check_tk_type_progressable(p_task_type_id IN NUMBER)
         RETURN VARCHAR2;

FUNCTION check_tk_type_wq_enabled(p_task_type_id IN NUMBER)
         RETURN VARCHAR2;

END pa_task_type_utils;

 

/

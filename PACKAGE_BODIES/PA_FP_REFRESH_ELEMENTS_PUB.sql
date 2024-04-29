--------------------------------------------------------
--  DDL for Package Body PA_FP_REFRESH_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_REFRESH_ELEMENTS_PUB" AS
/* $Header: PAFPPERB.pls 120.3 2005/08/19 16:27:59 mwasowic noship $ */
p_pa_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE fp_write_log_ss_or_conc(
                   p_calling_context IN VARCHAR2,
                   p_msg IN VARCHAR2,
                   p_log_level IN NUMBER,
                   p_module IN VARCHAR2 ) IS
   l_dummy NUMBER;
   /* p_calling_context - SS when called from OA pages and
      CP when called from concurrent program */
BEGIN
   IF p_calling_context = 'SS' THEN
      pa_debug.write( x_module => p_module,
                      x_msg => p_msg,
                      x_log_level => p_log_level);
   ELSIF p_calling_context = 'CP' THEN
      PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
   END IF;
END fp_write_log_ss_or_conc;

/* This API updates the budget version and proj fp options table
   for plan processing code and process_update_wbs_flag columns based on the
   p_return_status value. */
PROCEDURE update_process_status( p_fp_opt_tab        IN PA_PLSQL_DATATYPES.IdTabTyp,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    NULL;
END update_process_status;

/* This API internally calls update_process_status to update  the
   status. Exception : This API is having a autonomous COMMIT.
   This API should be called only in case of unexpected errors and the process
   is running thru the concurrent program. */

PROCEDURE update_process_status_auto(
                                 p_fp_opt_tab        IN PA_PLSQL_DATATYPES.IdTabTyp,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER,
                                 x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data          OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    NULL;

END update_process_status_auto;



/* This procedure expects either p_budget_version_id or p_proj_fp_options_id
to be passed as NOT NULL. Based on the parameter values it returns the concurrent
request id , processing code and a flag which indicates whether the record
requires a planning elements refresh or not. */

PROCEDURE get_refresh_plan_ele_dtls(
                    p_budget_version_id   IN pa_budget_versions.budget_version_id%TYPE
                    DEFAULT NULL,
                    p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                    DEFAULT NULL,
                    x_request_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_process_code    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_refresh_required_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    NULL;
END get_refresh_plan_ele_dtls;

/* This procedure updates the concurrent request id, process code and
refresh required flag in budget versions or fp options table based on the
parameter passed. If the p_proj_fp_options_id and p_budget_version_id is passed
as NULL, then the API updates all the appropriate records ( only Task level planning
records ) in both budget versions and proj fp options table.
*/
PROCEDURE set_process_flag_opt(
                    p_project_id   IN pa_projects_all.project_id%TYPE,
                    p_request_id   IN pa_budget_versions.request_id%TYPE,
                    p_process_code    IN pa_budget_versions.plan_processing_code%TYPE,
                    p_refresh_required_flag IN VARCHAR2,
                    p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                    DEFAULT NULL,
                    p_budget_version_id   IN pa_budget_versions.budget_version_id%TYPE
                    DEFAULT NULL,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    NULL;

END set_process_flag_opt;

/* This procedure updates the concurrent request id, process code and
refresh required flag in all the appropriate records ( only Task level planning
records ) in both budget versions and proj fp options table. This API internally
calls the API set_process_flag_opt.
*/

PROCEDURE set_process_flag_proj(
                    p_project_id   IN pa_projects_all.project_id%TYPE,
                    p_request_id   IN pa_budget_versions.request_id%TYPE,
                    p_process_code    IN pa_budget_versions.plan_processing_code%TYPE,
                    p_refresh_required_flag IN VARCHAR2,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    NULL;
END set_process_flag_proj;

PROCEDURE refresh_planning_elements(
                    p_project_id         IN pa_projects_all.project_id%TYPE,
                    p_request_id         IN pa_budget_versions.request_id%TYPE,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
   l_impacted_tasks_rec PA_FP_ELEMENTS_PUB.l_wbs_refresh_tasks_tbl_typ;
   i number;
   l_task_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
   l_top_task_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
   l_parent_task_id_tab PA_PLSQL_DATATYPES.IdTabTyp;
   l_task_level_tab PA_PLSQL_DATATYPES.Char1TabTyp;
   l_fp_opt_tbl PA_PLSQL_DATATYPES.IdTabTyp;
   l_tname_tbl  PA_PLSQL_DATATYPES.Char30TabTyp;
   l_dummy NUMBER;
   l_module VARCHAR2(255):='pa_fp_refresh_elements_pub.refresh_planning_elements';
   l_calling_context VARCHAR2(10);
   l_msg VARCHAR2(300);
   l_ret_status VARCHAR2(100);
   x_return_status_in VARCHAR2(100);
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_task_id_tab.DELETE;
   l_top_task_id_tab.DELETE;
   l_fp_opt_tbl.DELETE;

   IF p_request_id IS NOT NULL THEN
      l_calling_context := 'CP';
   ELSE
      l_calling_context := 'SS';
   END IF;

    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_err_stack(l_module);
       pa_debug.set_process('refresh_planning_elements: ' || 'PLSQL','LOG',p_pa_debug_mode);
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
       l_msg := 'Project Id:'||to_char(p_project_id) ||' Req Id :'||to_char(p_request_id);
        pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
    END IF;

   BEGIN
      IF p_request_id IS NOT NULL THEN
      SELECT proj_fp_options_id,l_tname
      BULK COLLECT INTO l_fp_opt_tbl,l_tname_tbl
      FROM
      (
      SELECT proj_fp_options_id proj_fp_options_id,'OPT' l_tname
      FROM pa_proj_fp_options
      WHERE
      project_id = p_project_id AND
             fin_plan_option_level_code IN ( 'PROJECT',
             'PLAN_TYPE' ) AND
             ( nvl(all_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(cost_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(revenue_fin_plan_level_code,'x' ) IN ( 'L','T','M' )    ) AND
               NVL(process_update_wbs_flag,'N') = 'Y' AND
               p_request_id = request_id AND
               plan_processing_code = 'WUP'
      UNION ALL
      SELECT proj_fp_options_id proj_fp_options_id, 'BV' l_tname FROM
      pa_proj_fp_options opt,
      pa_budget_versions bv
      WHERE
      opt.project_id = p_project_id AND
      opt.fin_plan_option_level_code = 'PLAN_VERSION' AND
      bv.budget_version_id = opt.fin_plan_version_id AND
             ( nvl(opt.all_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(opt.cost_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(opt.revenue_fin_plan_level_code,'x' ) IN ( 'L','T','M' )    ) AND
               NVL(bv.process_update_wbs_flag,'N') = 'Y' AND
               p_request_id = bv.request_id AND
               bv.plan_processing_code = 'WUP'
     );
   ELSE
      SELECT proj_fp_options_id,l_tname
      BULK COLLECT INTO l_fp_opt_tbl,l_tname_tbl
      FROM
      (
      SELECT proj_fp_options_id proj_fp_options_id,'OPT' l_tname
      FROM pa_proj_fp_options
      WHERE
      project_id = p_project_id AND
             fin_plan_option_level_code IN ( 'PROJECT',
             'PLAN_TYPE' ) AND
             ( nvl(all_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(cost_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(revenue_fin_plan_level_code,'x' ) IN ( 'L','T','M' )    ) AND
               NVL(process_update_wbs_flag,'N') = 'Y'
      UNION ALL
      SELECT proj_fp_options_id proj_fp_options_id, 'BV' l_tname FROM
      pa_proj_fp_options opt,
      pa_budget_versions bv
      WHERE
      opt.project_id = p_project_id AND
      opt.fin_plan_option_level_code = 'PLAN_VERSION' AND
      bv.locked_by_person_id IS NULL AND /* Bug 3091568 */
      bv.budget_version_id = opt.fin_plan_version_id AND
             ( nvl(opt.all_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(opt.cost_fin_plan_level_code,'x' ) IN ( 'L','T','M' ) OR
               nvl(opt.revenue_fin_plan_level_code,'x' ) IN ( 'L','T','M' )    ) AND
               NVL(bv.process_update_wbs_flag,'N') = 'Y'
     );
   END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       l_dummy := 1;
   END;

   IF l_fp_opt_tbl.COUNT = 0 THEN
      IF p_pa_debug_mode = 'Y' THEN
         l_msg := 'l_fp_opt_tbl count is zero. Returning ';
         pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
      END IF;
      RETURN;
   END IF;


   SELECT task_id,top_task_id,
          parent_task_id,
          decode(task_id,top_task_id,'T',
          decode(pa_task_utils.check_child_exists(task_id),
       1,'M','L' ))
   BULK COLLECT INTO
   l_task_id_tab,
   l_top_task_id_tab,
   l_parent_task_id_tab,
   l_task_level_tab
   FROM pa_tasks WHERE
   project_id = p_project_id
   ORDER BY PA_PROJ_ELEMENTS_UTILS.GET_DISPLAY_SEQUENCE(task_id);

   IF l_task_id_tab.COUNT = 0 THEN
      IF p_pa_debug_mode = 'Y' THEN
         l_msg := 'task tbl count is zero. Returning ';
         pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
      END IF;
      RETURN;
   END IF;

   FOR task_idx IN 1 .. l_task_id_tab.COUNT LOOP
      l_impacted_tasks_rec(task_idx).task_id := l_task_id_tab(task_idx);
      l_impacted_tasks_rec(task_idx).parent_task_id := l_parent_task_id_tab(task_idx);
      l_impacted_tasks_rec(task_idx).top_task_id := l_top_task_id_tab(task_idx);
      l_impacted_tasks_rec(task_idx).task_level := l_task_level_tab(task_idx);
   END LOOP;

   IF p_pa_debug_mode = 'Y' THEN
         l_msg := 'before calling PA_FP_ELEMENTS_PUB.make_new_tasks_plannable';
         pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
   END IF;

    PA_FP_ELEMENTS_PUB.make_new_tasks_plannable
   (p_project_id             => p_project_id,
    p_tasks_tbl              => l_impacted_tasks_rec,
    P_refresh_fp_options_tbl => l_fp_opt_tbl,
    x_return_status          => x_return_status,
    x_msg_count              => x_msg_count,
    x_msg_data               => x_msg_data );

   /* the return status should be retained to pass the value
      back to the calling API. */
   l_ret_status := x_return_status;

   IF p_pa_debug_mode = 'Y' THEN
         l_msg := 'after calling PA_FP_ELEMENTS_PUB.make_new_tasks_plannable'
                  || 'ret status:'||x_return_status;
         pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
   END IF;

    IF p_request_id IS NULL  OR
       ( p_request_id IS NOT NULL AND
         x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
       IF p_pa_debug_mode = 'Y' THEN
          l_msg := 'calling pa_fp_refresh_elements_pub.update_process_status';
          pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
       END IF;
	   x_return_status_in := x_return_status;
       pa_fp_refresh_elements_pub.update_process_status(
                        p_fp_opt_tab        => l_fp_opt_tbl,
                        p_return_status     => x_return_status_in,
                        p_project_id        => p_project_id,
                        p_request_id        => p_request_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data );
   ELSIF p_request_id IS NOT NULL AND
         x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF p_pa_debug_mode = 'Y' THEN
          l_msg := 'calling pa_fp_refresh_elements_pub.update_process_status_auto';
          pa_fp_refresh_elements_pub.fp_write_log_ss_or_conc(
                   p_calling_context => l_calling_context,
                   p_msg => l_msg,
                   p_log_level => 3,
                   p_module => l_module );
       END IF;
	   x_return_status_in := x_return_status;
       pa_fp_refresh_elements_pub.update_process_status_auto(
                        p_fp_opt_tab        => l_fp_opt_tbl,
                        p_return_status     => x_return_status_in,
                        p_project_id        => p_project_id,
                        p_request_id        => p_request_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data );
   END  IF;
   /* setting the return status from  PA_FP_ELEMENTS_PUB.make_new_tasks_plannable */
   x_return_status := l_ret_status;

   IF p_pa_debug_mode = 'Y' THEN
      PA_DEBUG.Reset_Err_stack;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF p_pa_debug_mode = 'Y' THEN
       PA_DEBUG.Reset_Err_stack;
    END IF;
    IF p_request_id IS NOT NULL THEN
	   x_return_status_in := x_return_status;
       pa_fp_refresh_elements_pub.update_process_status_auto(
                        p_fp_opt_tab        => l_fp_opt_tbl,
                        p_return_status     => x_return_status_in,
                        p_project_id        => p_project_id,
                        p_request_id        => p_request_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_fp_refresh_elements_pub',
                            p_procedure_name => 'refresh_planning_elements',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

END refresh_planning_elements;



END pa_fp_refresh_elements_pub;

/

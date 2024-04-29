--------------------------------------------------------
--  DDL for Package Body PA_FP_ORG_FCST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ORG_FCST_UTILS" as
/* $Header: PAFPORUB.pls 120.4 2007/02/06 10:02:46 dthakker ship $ */
-- Start of Comments
-- Package name     : PA_FP_ORG_FCST_UTILS
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

/*     20-Mar-2002 SManivannan   Added Procedure Get_Tp_Amount_Type  */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_forecast_option_details
  ( x_fcst_period_type           OUT NOCOPY pa_forecasting_options_all.org_fcst_period_type%TYPE --File.Sql.39 bug 4440895
   ,x_period_set_name            OUT NOCOPY pa_implementations_all.period_set_name%TYPE --File.Sql.39 bug 4440895
   ,x_act_period_type            OUT NOCOPY gl_periods.period_type%TYPE --File.Sql.39 bug 4440895
   ,x_org_projfunc_currency_code OUT NOCOPY gl_sets_of_books.currency_code%TYPE --File.Sql.39 bug 4440895
   ,x_number_of_periods          OUT NOCOPY pa_forecasting_options_all.number_of_periods%TYPE --File.Sql.39 bug 4440895
   ,x_weighted_or_full_code      OUT NOCOPY pa_forecasting_options_all.weighted_or_full_code%TYPE --File.Sql.39 bug 4440895
   ,x_org_proj_template_id       OUT NOCOPY pa_forecasting_options_all.org_fcst_project_template_id%TYPE --File.Sql.39 bug 4440895
   ,x_org_structure_version_id   OUT NOCOPY pa_implementations_all.org_structure_version_id%TYPE --File.Sql.39 bug 4440895
   ,x_fcst_start_date            OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_fcst_end_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_org_id                     OUT NOCOPY pa_implementations_all.org_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code                   OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_org_id                     pa_implementations_all.org_id%TYPE;
l_set_of_books_id            pa_implementations_all.set_of_books_id%TYPE;
l_org_struc_version_id       pa_implementations_all.org_structure_version_id%TYPE;
l_start_organization         pa_implementations_all.start_organization_id%TYPE;
l_pa_period_type             pa_implementations_all.pa_period_type%TYPE;
l_fcst_period_type           pa_forecasting_options_all.org_fcst_period_type%TYPE;
l_start_period_name          pa_forecasting_options_all.start_period_name%TYPE;
l_number_of_periods          pa_forecasting_options_all.number_of_periods%TYPE;
l_weighted_or_full_code      pa_forecasting_options_all.weighted_or_full_code%TYPE;
l_org_proj_template_id       pa_forecasting_options_all.org_fcst_project_template_id%TYPE;

l_period_set_name            gl_sets_of_books.period_set_name%TYPE;
l_accounted_period_type      gl_sets_of_books.accounted_period_type%TYPE;
l_org_projfunc_currency_code gl_sets_of_books.currency_code%TYPE;

l_fcst_start_date        date;
l_fcst_end_date          date;

l_stage number := 0;
l_debug_mode VARCHAR2(30);

CURSOR gl_periods IS
SELECT gp.end_date
  FROM gl_periods gp
 WHERE gp.period_set_name = l_period_set_name
   AND gp.period_type     = l_accounted_period_type
   AND gp.start_date      >= l_fcst_start_date
   AND gp.adjustment_period_flag = 'N'
 ORDER BY gp.start_date;

CURSOR pa_periods IS
SELECT gp.end_date
  FROM gl_periods gp
 WHERE gp.period_set_name = l_period_set_name
   AND gp.period_type     = l_pa_period_type
   AND gp.start_date      >= l_fcst_start_date
   AND gp.adjustment_period_flag = 'N'
 ORDER BY gp.start_date;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_forecast_option_details');
     END IF;

     --fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := 'Y';

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_forecast_option_details: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Entered PA_FP_ORG_FCST_UTILS.get_forecast_option_details');
           pa_debug.write_file('get_forecast_option_details: ' || pa_debug.g_err_stage);
        END IF;
     l_stage := 100;

       SELECT nvl(org_id,-99),
              set_of_books_id,
              org_structure_version_id,
              start_organization_id,
              pa_period_type
         INTO l_org_id,
              l_set_of_books_id,
              l_org_struc_version_id,
              l_start_organization,
              l_pa_period_type
         FROM pa_implementations;

     l_stage := 200;

       SELECT org_fcst_period_type,
              start_period_name,
              number_of_periods,
              weighted_or_full_code,
              org_fcst_project_template_id
         INTO l_fcst_period_type,
              l_start_period_name,
              l_number_of_periods,
              l_weighted_or_full_code,
              l_org_proj_template_id
         FROM pa_forecasting_options;

      l_stage := 300;

       SELECT period_set_name
             ,accounted_period_type
             ,currency_code
         INTO l_period_set_name
             ,l_accounted_period_type
             ,l_org_projfunc_currency_code
         FROM gl_sets_of_books
        WHERE set_of_books_id = l_set_of_books_id;

     l_stage := 400;

    IF l_fcst_period_type = 'GL' THEN

      l_stage := 500;

       x_act_period_type      := l_accounted_period_type;

       SELECT start_date, end_date
         INTO l_fcst_start_date, l_fcst_end_date
         FROM gl_periods
        WHERE period_set_name = l_period_set_name
          AND period_type     = l_accounted_period_type
          AND period_name     = l_start_period_name
          AND adjustment_period_flag = 'N';

       l_stage := 600;

       OPEN gl_periods;
       FOR i IN 1..l_number_of_periods LOOP
           FETCH gl_periods INTO l_fcst_end_date;
       END LOOP;
       CLOSE gl_periods;
       l_stage := 700;
    ELSE -- PA period
       l_stage := 800;
       x_act_period_type      := l_pa_period_type;

       SELECT start_date, end_date
         INTO l_fcst_start_date, l_fcst_end_date
         FROM gl_periods
        WHERE period_set_name = l_period_set_name
          AND period_type     = l_pa_period_type
          AND period_name     = l_start_period_name
          AND adjustment_period_flag = 'N';

        l_stage := 900;

        OPEN pa_periods;
        FOR i IN 1..l_number_of_periods LOOP
           FETCH pa_periods INTO l_fcst_end_date;
        END LOOP;
        CLOSE pa_periods;
        l_stage := 1000;

    END IF;

        x_fcst_period_type           := l_fcst_period_type;
        x_period_set_name            := l_period_set_name;
        x_org_projfunc_currency_code := l_org_projfunc_currency_code;
        x_number_of_periods          := l_number_of_periods;
        x_weighted_or_full_code      := l_weighted_or_full_code;
        x_org_proj_template_id       := l_org_proj_template_id;
        x_org_structure_version_id   := l_org_struc_version_id;
        x_fcst_start_date            := l_fcst_start_date;
        x_fcst_end_date              := l_fcst_end_date;
        x_org_id                     := l_org_id;

        IF l_fcst_period_type           IS NULL OR
           l_period_set_name            IS NULL OR
           l_org_projfunc_currency_code IS NULL OR
           l_number_of_periods          IS NULL OR
           l_weighted_or_full_code      IS NULL OR
           l_org_proj_template_id       IS NULL OR
           l_org_struc_version_id       IS NULL OR
           l_fcst_start_date            IS NULL OR
           l_fcst_end_date              IS NULL OR
           l_org_id                     IS NULL THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_err_code      := -1;
        END IF;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('Leaving PA_FP_ORG_FCST_UTILS.get_forecast_option_details');
           pa_debug.write_file('get_forecast_option_details: ' || pa_debug.g_err_stage);
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.get_forecast_options_details'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_forecast_option_details: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_forecast_option_details;

PROCEDURE get_org_project_info
  ( p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,x_org_project_id      OUT NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is
   l_stage NUMBER := 0;
   l_debug_mode VARCHAR2(30);

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_org_project_info');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_org_project_info: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_stage := 100;
        pa_debug.g_err_stage := 'Entered PA_FP_ORG_FCST_UTILS.get_org_project_info for Org ['||p_organization_id        ||
                              ']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_org_project_info: ' || pa_debug.g_err_stage);
        END IF;

      /* bug 3106741 though template_flag is a nullable column care has been taken to populate the column always.
         so removed NVL for performance reasons
       */
      SELECT pp.project_id
        INTO x_org_project_id
        FROM pa_projects pp
       WHERE pp.carrying_out_organization_id = p_organization_id
         AND pp.project_type in ( SELECT ppt.project_type
                                       FROM pa_project_types ppt
                                      WHERE ppt.org_project_flag = 'Y')
         AND pp.template_flag = 'N';
         -- bug 3106741 AND NVL(pp.template_flag,'N') = 'N';

         pa_debug.g_err_stage := 'Leaving PA_FP_ORG_FCST_UTILS.get_org_project_info';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('get_org_project_info: ' || pa_debug.g_err_stage);
         END IF;
         pa_debug.reset_err_stack;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          x_org_project_id := -9999;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('get_org_project_info: ' || 'Org Project Not Found for organization Id = '
                              ||p_organization_id);
          END IF;
          pa_debug.reset_err_stack;
     WHEN OTHERS THEN
                  FND_MSG_PUB.add_exc_msg(
                    p_pkg_name => 'PA_FP_ORG_FCST_UTILS.org_project_exists'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack);

                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_err_code      := SQLERRM;
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write_file('get_org_project_info: ' || SQLERRM);
                  END IF;
                  pa_debug.reset_err_stack;
END get_org_project_info;

PROCEDURE get_org_task_info
  ( p_project_id           IN pa_projects_all.project_id%TYPE
                              := NULL
   ,x_org_task_id         OUT NOCOPY pa_tasks.task_id%TYPE --File.Sql.39 bug 4440895
   ,x_organization_id     OUT NOCOPY hr_organization_units.organization_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

    l_debug_mode VARCHAR2(30);

    CURSOR own_task IS
    SELECT pt.task_id,
           pt.carrying_out_organization_id
        FROM pa_tasks pt
       WHERE pt.project_id = p_project_id;

    l_stage NUMBER := 0;

BEGIN
     BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_org_task_info');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_org_task_info: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_stage := 100;
        pa_debug.g_err_stage := 'Entered PA_FP_ORG_FCST_UTILS.get_org_task_info for Project ['||p_project_id || ']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_org_task_info: ' || pa_debug.g_err_stage);
        END IF;

         OPEN own_task;
         FETCH own_task into x_org_task_id, x_organization_id;
         CLOSE own_task;
     l_stage := 200;
     pa_debug.g_err_stage := 'Leaving PA_FP_ORG_FCST_UTILS.get_org_task_info';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('get_org_task_info: ' || pa_debug.g_err_stage);
     END IF;
     pa_debug.reset_err_stack;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
          x_org_task_id := -9999;
          x_organization_id := -9999;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_err_code      := SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('get_org_task_info: ' || 'Org Own Task Not Found');
          END IF;
          pa_debug.reset_err_stack;
     END;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.org_project_exists'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_org_task_info: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_org_task_info;

PROCEDURE get_utilization_details
  ( p_org_id               IN pa_implementations_all.org_id%TYPE
                              := NULL
   ,p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_period_type          IN pa_forecasting_options_all.org_fcst_period_type%TYPE
                              := NULL
   ,p_period_set_name      IN gl_periods.period_set_name%TYPE
                              := NULL
   ,p_period_name          IN gl_periods.period_name%TYPE
                              := NULL
   ,x_utl_hours           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_capacity        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_percent         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
    l_debug_mode VARCHAR2(30);

CURSOR get_utilization_amts IS
SELECT psb.amount_type_id,
       nvl(sum(psb.period_balance),0)
  FROM pa_objects po,
       pa_summ_balances psb
 WHERE po.object_type_code            = 'ORG'
   AND po.expenditure_org_id          = p_org_id
   AND po.project_org_id              = -1
   AND po.expenditure_organization_id = p_organization_id
   AND po.project_organization_id     = -1
   AND po.project_id                  = -1
   AND po.task_id                     = -1
   AND po.person_id                   = -1
   AND po.work_type_id                = -1
   AND po.org_util_category_id        = -1
   AND po.res_util_category_id        = -1
   AND po.balance_type_code           = 'FORECAST'
   AND po.assignment_id               = -1
   AND psb.object_id                  = po.object_id
   AND psb.period_type                = p_period_type
   AND psb.object_type_code           = 'ORG'
   AND psb.version_id                 = -1
   AND psb.period_set_name            = p_period_set_name
   AND psb.period_name                = p_period_name
   AND psb.global_exp_period_end_date = trunc(to_date('01/01/1420','MM/DD/YYYY'))
   AND psb.amount_type_id in (32,37,38) /* 32-Weighted hours, 37-capacity, 38-Reduced Capacity */
   GROUP BY amount_type_id;

   l_amount_type_id    pa_summ_balances.amount_type_id%TYPE;
   l_period_balance    pa_summ_balances.period_balance%TYPE :=0;
   l_hours             pa_summ_balances.period_balance%TYPE :=0;
   l_capacity          pa_summ_balances.period_balance%TYPE :=0;
   l_reduced_capacity  pa_summ_balances.period_balance%TYPE :=0;

   l_stage NUMBER := 0;

BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_utilization_details');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_utilization_details: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_stage := 100;
             -- hr_utility.trace('p_org_id           ['||p_org_id          ||']');
             -- hr_utility.trace('p_organization_id  ['||p_organization_id ||']');
             -- hr_utility.trace('p_period_type      ['||p_period_type     ||']');
             -- hr_utility.trace('p_period_set_name  ['||p_period_set_name ||']');
             -- hr_utility.trace('p_period_name      ['||p_period_name     ||']');

      OPEN get_utilization_amts;
           -- hr_utility.trace('ROWS = '||to_char(SQL%ROWCOUNT));
      LOOP
           FETCH get_utilization_amts INTO l_amount_type_id, l_period_balance;
           EXIT WHEN get_utilization_amts%NOTFOUND;
            -- hr_utility.trace('Amount Type Id = '||to_char(l_amount_type_id));
            -- hr_utility.trace('Period Balance = '||to_char(l_period_balance));
           l_stage := 200;

           IF l_amount_type_id = 32 THEN
              l_hours            := l_period_balance;
           ELSIF l_amount_type_id = 37 THEN
              l_capacity         := l_period_balance;
           ELSIF l_amount_type_id = 38 THEN
              l_reduced_capacity := l_period_balance;
           END IF;
      END LOOP;
           l_stage := 300;
      CLOSE get_utilization_amts;

           IF ((l_hours = 0) OR (l_capacity - l_reduced_capacity <=0 )) THEN
                l_stage := 400;
                x_utl_hours := 0;
                x_utl_capacity := 0;
                x_utl_percent  := 0;
           ELSE
                l_stage := 400;
                x_utl_hours    := l_hours;
                x_utl_capacity := l_capacity - l_reduced_capacity;
                x_utl_percent  := (l_hours/(l_capacity-l_reduced_capacity))*100;
           END IF;
         /*
           pa_debug.g_err_stage := 'x_utl_hours             ['||x_utl_hours              ||
                                 '] x_utl_capacity          ['||x_utl_capacity           ||
                                 '] x_utl_percent           ['||x_utl_percent            ||
                                 ']';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write_file('get_utilization_details: ' || pa_debug.g_err_stage);
           END IF;
         */
           pa_debug.reset_err_stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.get_utilization_details'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_utilization_details: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_utilization_details;

PROCEDURE get_headcount
  ( p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_effective_date       IN DATE
                              := NULL
   ,x_headcount           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_stage NUMBER := 0;
   l_debug_mode VARCHAR2(30);

CURSOR get_headcount IS
SELECT COUNT(*)
         FROM   per_assignments_f paf
               ,per_all_people_f ppf
               ,per_periods_of_service pps
         WHERE paf.organization_id = p_organization_id
           AND p_effective_date BETWEEN paf.effective_start_date
                                    AND paf.effective_end_date
           AND paf.assignment_type in ('E','C') /*Bug#2911451*/
           AND paf.primary_flag = 'Y'
           AND ppf.person_id = paf.person_id
           AND p_effective_date BETWEEN ppf.effective_start_date
                                    AND ppf.effective_end_date
           AND pps.person_id = ppf.person_id
           AND nvl(pps.actual_termination_date,p_effective_date) >= p_effective_date;


BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('get_headcount: ' || 'PA_FP_ORG_FCST_UTILS.get_utilization_details');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_headcount: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      /*
        pa_debug.g_err_stage := 'p_organization_id       ['||p_organization_id        ||
                              '] p_effective_date        ['||p_effective_date         ||
                              ']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_headcount: ' || pa_debug.g_err_stage);
        END IF;
      */

      OPEN get_headcount;
      FETCH get_headcount INTO x_headcount;
      CLOSE get_headcount;

      /*
        pa_debug.g_err_stage := 'x_headcount             ['||x_headcount              ||
                              ']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_headcount: ' || pa_debug.g_err_stage);
        END IF;
      */
        pa_debug.reset_err_stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.get_headcount'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_headcount: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_headcount;

PROCEDURE get_probability_percent
  ( p_project_id           IN pa_projects_all.project_id%TYPE
                              := NULL
   ,x_prob_percent OUT NOCOPY pa_probability_members.probability_percentage%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   IS
   l_debug_mode VARCHAR2(30);
   l_probability_member_id pa_projects_all.probability_member_id%TYPE;
BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_probability_percent');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_probability_percent: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

    SELECT nvl(probability_member_id,-99)
      INTO l_probability_member_id
      FROM pa_projects_all
     WHERE project_id = p_project_id;

    IF l_probability_member_id < 0 THEN
       x_prob_percent := 100;
    ELSE
       SELECT nvl(probability_percentage,100)
         INTO x_prob_percent
         FROM pa_probability_members
        WHERE probability_member_id = l_probability_member_id;
    END IF;
        pa_debug.g_err_stage := 'Txn Project_id =      ['||p_project_id ||']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_probability_percent: ' || pa_debug.g_err_stage);
        END IF;
        pa_debug.g_err_stage := 'Probability    =      ['||x_prob_percent||']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_probability_percent: ' || pa_debug.g_err_stage);
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.get_probability_percent'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);

              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_probability_percent: ' || SQLERRM);
              END IF;
              x_err_code      := SQLERRM;
              pa_debug.reset_err_stack;
END get_probability_percent;

PROCEDURE get_period_profile
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,p_period_profile_type IN pa_proj_period_profiles.period_profile_type%TYPE
                             := NULL
   ,p_plan_period_type    IN pa_forecasting_options.org_fcst_period_type%TYPE
                             := NULL
   ,p_period_set_name     IN gl_periods.period_set_name%TYPE
                             := NULL
   ,p_act_period_type     IN gl_periods.period_type%TYPE
                             := NULL
   ,p_start_date          IN gl_periods.start_date%TYPE
                             := NULL
   ,p_number_of_periods   IN pa_forecasting_options.number_of_periods%TYPE
   ,x_period_profile_id  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   IS
   l_debug_mode VARCHAR2(30);
BEGIN
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.get_period_profile');
     END IF;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'Y');

     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.set_process('get_period_profile: ' || 'PLSQL','LOG',l_debug_mode);
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    SELECT ppp.period_profile_id
      INTO x_period_profile_id
      FROM pa_proj_period_profiles ppp
     WHERE ppp.project_id          = p_project_id
       AND ppp.period_profile_type = p_period_profile_type
       AND ppp.plan_period_type    = p_plan_period_type
       AND ppp.period_set_name     = p_period_set_name
       AND ppp.gl_period_type      = p_act_period_type
       AND ppp.period1_start_date  = p_start_date
       AND ppp.number_of_periods   = p_number_of_periods;

       --pa_debug.write_file('Period_profile Found');
  EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_period_profile_id := -99;
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write_file('get_period_profile: ' || 'Period_profile Not Found');
         END IF;
         x_err_code := SQLERRM;
  END;
      /*
        pa_debug.g_err_stage := 'x_period_profile_id     ['||x_period_profile_id      ||
                              ']';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write_file('get_period_profile: ' || pa_debug.g_err_stage);
        END IF;
      */
         pa_debug.reset_err_stack;
EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS.get_period_profile'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('get_period_profile: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END get_period_profile;

FUNCTION check_org_proj_template
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   RETURN VARCHAR2 IS

   l_org_proj_template_exists varchar2(1);

BEGIN
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Entered PA_FP_ORG_FCST_UTILS.check_org_proj_template');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_org_proj_template_exists := 'N';

       SELECT 'Y'
         INTO l_org_proj_template_exists
         FROM pa_forecasting_options
        WHERE org_fcst_project_template_id = p_project_id;

   x_return_status := FND_API.G_RET_STS_ERROR;

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Leaving PA_FP_ORG_FCST_UTILS.check_org_proj_template');
   END IF;
   pa_debug.reset_err_stack;
   return(l_org_proj_template_exists);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_org_proj_template_exists := 'N';
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          return(l_org_proj_template_exists);
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS'
             ,p_procedure_name => 'check_org_proj_template');
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('check_org_proj_template: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END check_org_proj_template;

PROCEDURE Get_Tp_Amount_Type(p_project_id        IN  NUMBER,
                             p_work_type_id      IN  NUMBER,
                             x_tp_amount_type    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data          OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
   l_org_id NUMBER;
BEGIN

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  x_tp_amount_type := NULL;

  IF p_work_type_id IS NOT NULL THEN
      SELECT Tp_Amt_Type_Code
      INTO x_tp_amount_type
      FROM Pa_Work_Types_B
      WHERE Work_Type_Id = p_work_type_id;

      IF x_tp_amount_type IS NOT NULL THEN
         RETURN;
      END IF;
  END IF;

  IF p_project_id IS NOT NULL THEN
     BEGIN
        SELECT  NVL(Org_Id,-99)
        INTO    l_org_id
        FROM    Pa_Projects_All
        WHERE   Project_Id = p_project_id;

        SELECT  Default_Tp_Amount_Type
        INTO    x_tp_amount_type
        FROM    Pa_Forecasting_Options_All
        WHERE   nvl(Org_Id,-99) = l_org_id;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        PA_UTILS.Add_Message(
                              p_app_short_name => 'PA'
                             ,p_msg_name      =>'PA_FORECAST_OPTIONS_NOT_SETUP');
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data      := 'PA_FORECAST_OPTIONS_NOT_SETUP';
          x_msg_count := FND_MSG_PUB.Count_Msg;
     END;
  END IF;
  RETURN;
EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SUBSTR(SQLERRM,1,30);
    FND_MSG_PUB.add_exc_msg
         (             p_pkg_name       => 'PA_FP_ORG_FCST_UTILS',
                       p_procedure_name => 'Get_Tp_Amount_Type');
    RAISE;
END Get_Tp_Amount_Type;

FUNCTION check_org_project
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   RETURN VARCHAR2 IS

   l_org_project_exists varchar2(1);

BEGIN
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Entered PA_FP_ORG_FCST_UTILS.check_org_project');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_org_project_exists := 'N';

       SELECT 'Y'
         INTO l_org_project_exists
         FROM pa_projects pp,
              pa_project_types pt
        WHERE pp.project_id = p_project_id
          AND pt.project_type = pp.project_type
          AND pt.org_project_flag = 'Y';

   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Leaving PA_FP_ORG_FCST_UTILS.check_org_project');
   END IF;
   pa_debug.reset_err_stack;
   return(l_org_project_exists);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_org_project_exists := 'N';
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          return(l_org_project_exists);
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS'
             ,p_procedure_name => 'check_org_project');
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              --x_err_code      := SQLERRM;   bug 4338407
	      x_err_code      := SQLCODE;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('check_org_project: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
	      return('E');  -- bug 4338407
END check_org_project;

FUNCTION calculate_gl_amount
  ( p_amount_code         IN pa_amount_types_b.amount_type_code%TYPE
                             := NULL)
   RETURN NUMBER IS

   Revenue              number := 0;
   Cost                 number := 0;
   Headcount            number := 0;
   Util_Hours           number := 0;
   Util_capacity        number := 0;
   Util_percent         number := 0;

BEGIN

   IF p_amount_code = 'MARGIN_PERCENT' THEN

      SELECT
      (
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount1,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount1,0)*-1,
                                nvl(pppd.period_amount1,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount2,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount2,0)*-1,
                                                        nvl(pppd.period_amount2,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount3,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount3,0)*-1,
                                                        nvl(pppd.period_amount3,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount4,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount4,0)*-1,
                                                        nvl(pppd.period_amount4,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount5,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount5,0)*-1,
                                                        nvl(pppd.period_amount5,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount6,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount6,0)*-1,
                                                        nvl(pppd.period_amount6,0)
                  )
            )
       ) as Total
     INTO revenue
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'REVENUE'
    ORDER BY pppd.amount_type_id;

      SELECT
      (
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount1,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount1,0)*-1,
                                nvl(pppd.period_amount1,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount2,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount2,0)*-1,
                                                        nvl(pppd.period_amount2,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount3,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount3,0)*-1,
                                                        nvl(pppd.period_amount3,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount4,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount4,0)*-1,
                                                        nvl(pppd.period_amount4,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount5,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount5,0)*-1,
                                                        nvl(pppd.period_amount5,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount6,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount6,0)*-1,
                                                        nvl(pppd.period_amount6,0)
                  )
            )
       ) as Total
     INTO cost
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'COST'
    ORDER BY pppd.amount_type_id;

      IF revenue = 0 THEN
         return 0;
      ELSE
         return ((revenue-cost)/revenue) * 100;
      END IF;

    END IF;

    IF p_amount_code = 'HEADCOUNT' THEN

      SELECT
  round((sum(nvl(pppd.period_amount1,0))+
        sum(nvl(pppd.period_amount2,0))+
        sum(nvl(pppd.period_amount3,0))+
        sum(nvl(pppd.period_amount4,0))+
        sum(nvl(pppd.period_amount5,0))+
        sum(nvl(pppd.period_amount6,0)))/6,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'HEADCOUNT'
    ORDER BY pppd.amount_type_id;

    return headcount;

   END IF;

    IF p_amount_code = 'HEADCOUNT_ADJUSTMENTS' THEN

      SELECT
      round((nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0))/6,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.object_type_code = 'RES_ASSIGNMENT'
      AND pppd.object_id = pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS';

    return headcount;

   END IF;

    IF p_amount_code = 'BEGIN_HEADCOUNT' THEN

      SELECT
       round((nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0))/6,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'BEGIN_HEADCOUNT';

    return headcount;

   END IF;

   IF p_amount_code = 'UTILIZATION_PERCENT' THEN

      SELECT
       (nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0))/6
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'UTILIZATION_PERCENT';

         return util_percent;

    END IF;
   IF p_amount_code = 'UTILIZATION_ADJUSTMENTS' THEN

      SELECT
       (nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0))/6
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.object_type_code = 'RES_ASSIGNMENT'
      AND pppd.object_id = pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'UTILIZATION_ADJUSTMENTS';

         return util_percent;

    END IF;

   IF p_amount_code = 'UTILIZATION' THEN

      SELECT
       (sum(nvl(pppd.period_amount1,0))+
        sum(nvl(pppd.period_amount2,0))+
        sum(nvl(pppd.period_amount3,0))+
        sum(nvl(pppd.period_amount4,0))+
        sum(nvl(pppd.period_amount5,0))+
        sum(nvl(pppd.period_amount6,0)))/6
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'UTILIZATION';


         return util_percent;

    END IF;


END calculate_gl_amount;

FUNCTION calculate_pa_amount
  ( p_amount_code         IN pa_amount_types_b.amount_type_code%TYPE
                             := NULL)
   RETURN NUMBER IS
   Revenue              number := 0;
   Cost                 number := 0;
   Headcount            number := 0;
   Util_hours           number := 0;
   Util_capacity        number := 0;
   Util_percent         number := 0;

BEGIN

   IF p_amount_code = 'MARGIN_PERCENT' THEN

      SELECT
      (
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount1,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount1,0)*-1,
                                nvl(pppd.period_amount1,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount2,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount2,0)*-1,
                                                        nvl(pppd.period_amount2,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount3,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount3,0)*-1,
                                                        nvl(pppd.period_amount3,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount4,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount4,0)*-1,
                                                        nvl(pppd.period_amount4,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount5,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount5,0)*-1,
                                                        nvl(pppd.period_amount5,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount6,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount6,0)*-1,
                                                        nvl(pppd.period_amount6,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount7,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount7,0)*-1,
                                nvl(pppd.period_amount7,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount8,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount8,0)*-1,
                                                        nvl(pppd.period_amount8,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount9,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount9,0)*-1,
                                                        nvl(pppd.period_amount9,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount10,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount10,0)*-1,
                                                        nvl(pppd.period_amount10,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount11,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount11,0)*-1,
                                                        nvl(pppd.period_amount11,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount12,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount12,0)*-1,
                                                        nvl(pppd.period_amount12,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount13,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount13,0)*-1,
                                                        nvl(pppd.period_amount13,0)
                  )
            )
       )
     INTO revenue
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'REVENUE'
    ORDER BY pppd.amount_type_id;

      SELECT
      (
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount1,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount1,0)*-1,
                                nvl(pppd.period_amount1,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount2,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount2,0)*-1,
                                                        nvl(pppd.period_amount2,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount3,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount3,0)*-1,
                                                        nvl(pppd.period_amount3,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount4,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount4,0)*-1,
                                                        nvl(pppd.period_amount4,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount5,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount5,0)*-1,
                                                        nvl(pppd.period_amount5,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount6,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount6,0)*-1,
                                                        nvl(pppd.period_amount6,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount7,0)*-1,
                                   'TP_COST_OUT',   nvl(pppd.period_amount7,0)*-1,
                                nvl(pppd.period_amount7,0)
          )
        )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount8,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount8,0)*-1,
                                                        nvl(pppd.period_amount8,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount9,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount9,0)*-1,
                                                        nvl(pppd.period_amount9,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount10,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount10,0)*-1,
                                                        nvl(pppd.period_amount10,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount11,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount11,0)*-1,
                                                        nvl(pppd.period_amount11,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount12,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount12,0)*-1,
                                                        nvl(pppd.period_amount12,0)
                  )
            )+
        sum(decode(amount_subtype_code,'TP_REVENUE_OUT',nvl(pppd.period_amount13,0)*-1,
                                       'TP_COST_OUT',   nvl(pppd.period_amount13,0)*-1,
                                                        nvl(pppd.period_amount13,0)
                  )
            )
       )
     INTO cost
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'COST'
    ORDER BY pppd.amount_type_id;

      IF revenue = 0 THEN
         return 0;
      ELSE
         return ((revenue-cost)/revenue) * 100;
      END IF;

    END IF;

    IF p_amount_code = 'HEADCOUNT' THEN

      SELECT
       round((sum(nvl(pppd.period_amount1,0))+
        sum(nvl(pppd.period_amount2,0))+
        sum(nvl(pppd.period_amount3,0))+
        sum(nvl(pppd.period_amount4,0))+
        sum(nvl(pppd.period_amount5,0))+
        sum(nvl(pppd.period_amount6,0))+
        sum(nvl(pppd.period_amount7,0))+
        sum(nvl(pppd.period_amount8,0))+
        sum(nvl(pppd.period_amount9,0))+
        sum(nvl(pppd.period_amount10,0))+
        sum(nvl(pppd.period_amount11,0))+
        sum(nvl(pppd.period_amount12,0))+
        sum(nvl(pppd.period_amount13,0)))/13,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'HEADCOUNT';

    return headcount;

   END IF;

    IF p_amount_code = 'HEADCOUNT_ADJUSTMENTS' THEN

      SELECT
       round((nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0)+
        nvl(pppd.period_amount7,0)+
        nvl(pppd.period_amount8,0)+
        nvl(pppd.period_amount9,0)+
        nvl(pppd.period_amount10,0)+
        nvl(pppd.period_amount11,0)+
        nvl(pppd.period_amount12,0)+
        nvl(pppd.period_amount13,0))/13,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.object_type_code = 'RES_ASSIGNMENT'
      AND pppd.object_id = pra.resource_assignment_id
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS';

    return headcount;

   END IF;

    IF p_amount_code = 'BEGIN_HEADCOUNT' THEN

      SELECT
       round((nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0)+
        nvl(pppd.period_amount7,0)+
        nvl(pppd.period_amount8,0)+
        nvl(pppd.period_amount9,0)+
        nvl(pppd.period_amount10,0)+
        nvl(pppd.period_amount11,0)+
        nvl(pppd.period_amount12,0)+
        nvl(pppd.period_amount13,0))/13,0)
     INTO headcount
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'BEGIN_HEADCOUNT'
    ORDER BY pppd.amount_type_id;

    return headcount;

   END IF;

   IF p_amount_code = 'UTILIZATION_PERCENT' THEN

      SELECT
       (nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0)+
        nvl(pppd.period_amount7,0)+
        nvl(pppd.period_amount8,0)+
        nvl(pppd.period_amount9,0)+
        nvl(pppd.period_amount10,0)+
        nvl(pppd.period_amount11,0)+
        nvl(pppd.period_amount12,0)+
        nvl(pppd.period_amount13,0)) /13
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'UTILIZATION_PERCENT'
    ORDER BY pppd.amount_type_id;

         return util_percent;

    END IF;
   IF p_amount_code = 'UTILIZATION_ADJUSTMENTS' THEN

      SELECT
       (nvl(pppd.period_amount1,0)+
        nvl(pppd.period_amount2,0)+
        nvl(pppd.period_amount3,0)+
        nvl(pppd.period_amount4,0)+
        nvl(pppd.period_amount5,0)+
        nvl(pppd.period_amount6,0)+
        nvl(pppd.period_amount7,0)+
        nvl(pppd.period_amount8,0)+
        nvl(pppd.period_amount9,0)+
        nvl(pppd.period_amount10,0)+
        nvl(pppd.period_amount11,0)+
        nvl(pppd.period_amount12,0)+
        nvl(pppd.period_amount13,0)) /13
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.object_type_code = 'RES_ASSIGNMENT'
      AND pppd.object_id = pra.resource_assignment_id
      AND pppd.amount_subtype_code = 'UTILIZATION_ADJUSTMENTS';

         return util_percent;

    END IF;
   IF p_amount_code = 'UTILIZATION' THEN

      SELECT
       (sum(nvl(pppd.period_amount1,0))+
        sum(nvl(pppd.period_amount2,0))+
        sum(nvl(pppd.period_amount3,0))+
        sum(nvl(pppd.period_amount4,0))+
        sum(nvl(pppd.period_amount5,0))+
        sum(nvl(pppd.period_amount6,0))+
        sum(nvl(pppd.period_amount7,0))+
        sum(nvl(pppd.period_amount8,0))+
        sum(nvl(pppd.period_amount9,0))+
        sum(nvl(pppd.period_amount10,0))+
        sum(nvl(pppd.period_amount11,0))+
        sum(nvl(pppd.period_amount12,0))+
        sum(nvl(pppd.period_amount13,0))) /13
     INTO util_percent
     FROM pa_resource_assignments pra,
          pa_budget_versions      pbv,
          pa_fp_period_values_v   pppd
    WHERE pbv.budget_version_id = pa_fin_plan_view_global.Get_Version_ID()
      AND pra.project_id = pbv.project_id
      AND pra.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pra.resource_assignment_type='PROJECT'
      AND pppd.budget_version_id=pa_fin_plan_view_global.Get_Version_ID()
      AND pppd.resource_assignment_id=pra.resource_assignment_id
      AND pppd.amount_type_code = 'UTILIZATION';

         return util_percent;

    END IF;

END calculate_pa_amount;

/* dlai - added detect_org_project for use with project assignments 04/21/02 */
procedure detect_org_project
  ( p_project_id          IN pa_projects_all.project_id%TYPE
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
is

l_is_org_project   VARCHAR2(1);
l_return_status    VARCHAR2(1);
l_err_code         VARCHAR2(30);

BEGIN
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write_file('Entered PA_FIN_PLAN_UTILS.detect_org_project');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_is_org_project := PA_FP_ORG_FCST_UTILS.is_org_project
                       (p_project_id    => p_project_id);
   if x_return_status = FND_API.G_RET_STS_SUCCESS then
       if l_is_org_project = 'Y' then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_err_code := 'PA_FP_ORG_FCST_MSG';
           return;
       else
           return;
       end if;
   else
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                            p_msg_name       => l_err_code);
       return;
   end if;

   pa_debug.reset_err_stack;
   return;

EXCEPTION
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS'
             ,p_procedure_name => 'detect_org_project');
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_err_code      := SQLERRM;
              IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write_file('detect_org_project: ' || SQLERRM);
              END IF;
              pa_debug.reset_err_stack;
END detect_org_project;

/* dlai 04/25/02 added function same_org_id and procedure check_same_org_id
 * to ensure user login org_id is the same as the project org_id he/she is
 * trying to modify
 * dlai 07/13/05 -- commented out same_org_id and check_same_org_id, because
 *                  in R12, CLIENT_INFO should no longer be used
 */
/*
FUNCTION same_org_id
    (p_project_id     IN    pa_projects_all.project_id%TYPE)
 return VARCHAR2 is
  l_login_org_id      pa_projects_all.org_id%TYPE;
  l_project_org_id    pa_projects_all.org_id%TYPE;
  l_login_org_id_data VARCHAR2(1000);
  l_same_org_id       VARCHAR2(1);
  org_id_endpoint     NUMBER(15);
BEGIN
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FP_ORG_FCST_UTILS.same_org_id');
       pa_debug.set_process('same_org_id: ' || 'PLSQL','LOG', 'Y');
       pa_debug.write('plsql.pa.pa_fp_org_fcst_utils.same_org_id', 'Entered PA_FP_ORG_FCST_UTILS.same_org_id', 1);
    END IF;
    l_same_org_id := 'N';

    select org_id, USERENV('CLIENT_INFO')
        into l_project_org_id, l_login_org_id_data
        from pa_projects_all
        where
            project_id=p_project_id;

    org_id_endpoint := INSTR(l_login_org_id_data, ' ');
    l_login_org_id := TO_NUMBER(RTRIM(SUBSTR(l_login_org_id_data,1,org_id_endpoint)));
    if nvl(l_login_org_id,-99) = nvl(l_project_org_id,-99) then -- added nvl for bug # 2890558
        l_same_org_id := 'Y';
    end if;
    pa_debug.reset_err_stack;
    return(l_same_org_id);
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write_file('same_org_id: ' || 'NO DATA FOUND EXCEPTION');
          END IF;
          l_same_org_id := 'E';
          return(l_same_org_id);
     WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg(
              p_pkg_name => 'PA_FP_ORG_FCST_UTILS'
             ,p_procedure_name => 'same_org_id');
          pa_debug.reset_err_stack;
          return('U');
END same_org_id;

PROCEDURE check_same_org_id
    (p_project_id           IN      pa_projects_all.project_id%TYPE,
     x_return_status        OUT     VARCHAR2,
     x_msg_count            OUT     NUMBER,
     x_msg_data             OUT     VARCHAR2)
is
  l_same_org_id         VARCHAR2(1);
  l_return_status       VARCHAR2(1);
  l_err_code            VARCHAR2(2000);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_data                VARCHAR2(2000);
  l_msg_index_out       NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_same_org_id := pa_fp_org_fcst_utils.same_org_id
                        (p_project_id     => p_project_id);
        if l_same_org_id = 'N' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                 p_msg_name            => 'PA_FP_ORG_ID_MISMATCH');
            l_msg_count := FND_MSG_PUB.count_msg;
            if l_msg_count = 1 then
                PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
            end if;
            x_msg_count := l_msg_count;
            return;
        end if;
EXCEPTION
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FP_ORG_FCST_UTILS',
                               p_procedure_name   => 'check_same_org_id');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
END check_same_org_id;
*/

/* for Sheenie: function which takes in only 1 argument:
 * returns 'Y' if project is an org project
 * returns 'N' if project is not an org project
 * returns 'E' if there is an exception error
 */
FUNCTION is_org_project
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL)
   RETURN VARCHAR2
is
  l_org_project_exists varchar2(1);
BEGIN

   l_org_project_exists := 'N';
       SELECT 'Y'
         INTO l_org_project_exists
         FROM pa_projects_all pp,
              pa_project_types_all pt
        WHERE pp.project_id = p_project_id
          AND pt.project_type = pp.project_type
      AND pp.org_id = pt.org_id
          AND pt.org_project_flag = 'Y';
   return(l_org_project_exists);
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_org_project_exists := 'N';
          return(l_org_project_exists);
     WHEN OTHERS THEN
          l_org_project_exists := 'E';
          return(l_org_project_exists);
END is_org_project;


END pa_fp_org_fcst_utils;

/

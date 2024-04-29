--------------------------------------------------------
--  DDL for Package Body PA_FP_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ELEMENTS_PUB" as
/* $Header: PAFPELPB.pls 120.2.12010000.3 2010/04/15 00:37:12 rbruno ship $ */

l_module_name VARCHAR2(100) := 'pa.plsql.pa_fp_elements_pub';
g_plsql_max_array_size  NUMBER        := 200;

/*==================================================================================================
  REFRESH_FP_ELEMENTS: This procedure is used to refresh the existing FP Elements records i.e.
  delete and recreate the FP Elements Records based on the Planning Levels passed to this procedure.

  Bug :- 2920954 This is an existing api that has been modified to insert resource elements for the
  default task elements based on the automatic resource selection parameter and resource planning
  level for automatic resource selection. Currently only the defaul task elements are created based
  on the input planning level and resource list id.
==================================================================================================*/
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Refresh_FP_Elements (
          p_proj_fp_options_id               IN   NUMBER
          ,p_cost_planning_level             IN   VARCHAR2
          ,p_revenue_planning_level          IN   VARCHAR2
          ,p_all_planning_level              IN   VARCHAR2
          ,p_cost_resource_list_id           IN   NUMBER
          ,p_revenue_resource_list_id        IN   NUMBER
          ,p_all_resource_list_id            IN   NUMBER
          /*Bug :- 2920954 start of new parameters added for post fp-K one off patch */
          ,p_select_cost_res_auto_flag       IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_cost_res_planning_level         IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          ,p_select_rev_res_auto_flag        IN   pa_proj_fp_options.select_rev_res_auto_flag%TYPE
          ,p_revenue_res_planning_level      IN   pa_proj_fp_options.revenue_res_planning_level%TYPE
          ,p_select_all_res_auto_flag        IN   pa_proj_fp_options.select_all_res_auto_flag%TYPE
          ,p_all_res_planning_level          IN   pa_proj_fp_options.all_res_planning_level%TYPE
          /*Bug :- 2920954 end of new parameters added for post fp-K one off patch */
          ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_debug_mode      VARCHAR2(30);

BEGIN

    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FP_ELEMENTS_PUB.Refresh_FP_Elements');
    END IF;
    fnd_profile.get('pa_debug_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Refresh_FP_Elements: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_proj_fp_options_id IS NULL) THEN
        pa_debug.g_err_stage := 'Err- Proj FP Options ID cannot be NULL.';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* Depending on the Planning Level, i.e 'COST', PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE or PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, delete the
       fp_elements for the Proj_FP_Options_ID and then call the Insert_Default procedure
       to insert into fp_elements. */

    pa_debug.g_err_stage := 'Deleting records from pa_fp_elements and calling insert_Default';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;

    IF (p_cost_planning_level IS NOT NULL) THEN
    pa_debug.g_err_stage := 'Deleting and inserting for Cost Planning Level';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;
       delete_elements(p_proj_fp_options_id => p_proj_fp_options_id
                       ,p_element_type      => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                       ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK
                       ,x_return_status     => x_return_status
                       ,x_msg_count         => x_msg_count
                       ,x_msg_data          => x_msg_data);

        insert_default(p_proj_fp_options_id => p_proj_fp_options_id
                       ,p_element_type            =>   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                       ,p_planning_level          =>   p_cost_planning_level
                       ,p_resource_list_id        =>   p_cost_resource_list_id
                       ,p_select_res_auto_flag    =>   p_select_cost_res_auto_flag /* Bug 2920954*/
                       ,p_res_planning_level      =>   p_cost_res_planning_level   /* Bug 2920954*/
                       ,x_return_status           =>   x_return_status
                       ,x_msg_count               =>   x_msg_count
                       ,x_msg_data                =>   x_msg_data);
    END IF;

    IF (p_revenue_planning_level IS NOT NULL) THEN
    pa_debug.g_err_stage := 'Deleting and inserting for Revenue Planning Level';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;
       delete_elements(p_proj_fp_options_id => p_proj_fp_options_id
                       ,p_element_type      => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                       ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK
                       ,x_return_status     => x_return_status
                       ,x_msg_count         => x_msg_count
                       ,x_msg_data          => x_msg_data);

       insert_default(p_proj_fp_options_id => p_proj_fp_options_id
                      ,p_element_type             =>   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                      ,p_planning_level           =>   p_revenue_planning_level
                      ,p_resource_list_id         =>   p_revenue_resource_list_id
                      ,p_select_res_auto_flag     =>   p_select_rev_res_auto_flag    /* Bug 2920954*/
                      ,p_res_planning_level       =>   p_revenue_res_planning_level  /* Bug 2920954*/
                      ,x_return_status            =>   x_return_status
                      ,x_msg_count                =>   x_msg_count
                      ,x_msg_data                 =>   x_msg_data);
    END IF;

    IF (p_all_planning_level IS NOT NULL) THEN
    pa_debug.g_err_stage := 'Deleting and inserting for All Planning Level';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;
       delete_elements(p_proj_fp_options_id => p_proj_fp_options_id
                       ,p_element_type      => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
                       ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK
                       ,x_return_status     => x_return_status
                       ,x_msg_count         => x_msg_count
                       ,x_msg_data          => x_msg_data);

       insert_default(p_proj_fp_options_id => p_proj_fp_options_id
                      ,p_element_type             =>   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
                      ,p_planning_level           =>   p_all_planning_level
                      ,p_resource_list_id         =>   p_all_resource_list_id
                      ,p_select_res_auto_flag     =>   p_select_all_res_auto_flag   /* Bug 2920954*/
                      ,p_res_planning_level       =>   p_all_res_planning_level     /* Bug 2920954*/
                      ,x_return_status            =>   x_return_status
                      ,x_msg_count                =>   x_msg_count
                      ,x_msg_data                 =>   x_msg_data);
    END IF;

    pa_debug.g_err_stage := 'End of Refresh_FP_Elements';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;
    pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
      RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Refresh_FP_Elements'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Refresh_FP_Elements: ' || l_module_name,SQLERRM,4);
           pa_debug.write('Refresh_FP_Elements: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Refresh_FP_Elements;

/*==================================================================================================
  COPY_ELEMENTS: This procedure is used to copy FP Elements from the Source FP Option to the Target
  FP OPtion.
  -> If the Source FP Option is not passed (i.e. FP Elements are being created for a new FP
  Option. In this case, details are got from the Parent of the Target FP Option, if not found, then
  Defaults are inserted for the new Proj FP Option.
  -> If the Source FP Option is passed, then details are got from the Source FP Option and inserted
  for the Target FP Option.

  Bug 2920954 :- This is an existing api that has been modified to include the resource selection and
  resource planning level parameters to pa_fp_elements_pub.insert_default api. P_copy_mode has been
  added as a parameter to this api. If copying elements for baselined version, only the elements with
  plan amounts need to copied.

   For bug 2976168. Copy the elements from excluded_elements table if the copy mode is not B
   and only when the source exists
==================================================================================================*/
PROCEDURE Copy_Elements (
          p_from_proj_fp_options_id   IN   NUMBER
          ,p_from_element_type        IN   VARCHAR2
          ,p_to_proj_fp_options_id    IN   NUMBER
          ,p_to_element_type          IN   VARCHAR2
          ,p_to_resource_list_id      IN   NUMBER
          ,p_copy_mode                IN   VARCHAR2 /* Bug 2920954 */
          ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_debug_mode            VARCHAR2(30);
l_msg_count             NUMBER := 0;
l_data                  VARCHAR2(2000);
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;
l_return_status         VARCHAR2(2000);
l_stage                 NUMBER := 100;
l_par_fp_option_id      pa_proj_fp_options.PROJ_FP_OPTIONS_ID%TYPE;
l_planning_level        pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
l_cost_planning_level   pa_proj_fp_options.COST_FIN_PLAN_LEVEL_CODE%TYPE;
l_rev_planning_level    pa_proj_fp_options.REVENUE_FIN_PLAN_LEVEL_CODE%TYPE;
l_from_proj_fp_option_id pa_proj_fp_options.PROJ_FP_OPTIONS_ID%TYPE;
l_from_element_type     pa_fp_elements.ELEMENT_TYPE%TYPE;
l_to_fin_plan_type_id   pa_proj_fp_options.FIN_PLAN_TYPE_ID%TYPE;
l_to_fin_plan_version_id pa_proj_fp_options.FIN_PLAN_VERSION_ID%TYPE;
l_to_project_id          pa_projects.project_id%TYPE;
l_from_project_id        pa_projects.project_id%TYPE;
l_element_level          VARCHAR2(30) := PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK;

l_source_preference_code pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;  /* M20-AUG */
l_target_preference_code pa_proj_fp_options.FIN_PLAN_PREFERENCE_CODE%TYPE;  /* M20-AUG */
l_from_planning_level    pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
l_to_planning_level      pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
l_from_resource_list_id  pa_proj_fp_options.ALL_RESOURCE_LIST_ID%TYPE;
l_to_resource_list_id    pa_proj_fp_options.ALL_RESOURCE_LIST_ID%TYPE;

/* Start of  Variables defined for the bug :- 2684766 */

l_all_fin_plan_level_code      pa_proj_fp_options.all_fin_plan_level_code%TYPE;
l_cost_fin_plan_level_code     pa_proj_fp_options.cost_fin_plan_level_code%TYPE;
l_revenue_fin_plan_level_code  pa_proj_fp_options.revenue_fin_plan_level_code%TYPE;

/* End of  Variables defined for the bug :- 2684766 */

/* start of variables defined for Bug 2920954*/
l_select_res_auto_flag          PA_PROJ_FP_OPTIONS.select_cost_res_auto_flag%TYPE;
l_res_planning_level            PA_PROJ_FP_OPTIONS.cost_res_planning_level%TYPE;
l_select_cost_res_auto_flag     PA_PROJ_FP_OPTIONS.select_cost_res_auto_flag%TYPE;
l_cost_res_planning_level       PA_PROJ_FP_OPTIONS.cost_res_planning_level%TYPE;
l_select_rev_res_auto_flag      PA_PROJ_FP_OPTIONS.select_rev_res_auto_flag%TYPE;
l_revenue_res_planning_level    PA_PROJ_FP_OPTIONS.revenue_res_planning_level%TYPE;
/* end of variables defined for Bug 2920954*/

BEGIN

    FND_MSG_PUB.initialize;
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.init_err_stack('PA_FP_ELEMENTS_PUB.Copy_Elements');
    END IF;
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Copy_Elements: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;
    x_msg_count := 0;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_to_proj_fp_options_id IS NULL) THEN
      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Target Proj FP Options ID is NULL.';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
   END IF;

   IF (p_to_element_type IS NULL) THEN

       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Target Element Type is NULL.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                            p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
   END IF;

   IF (p_from_proj_fp_options_id IS NOT NULL AND p_from_element_type IS NULL) THEN

       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Source Element Type is NULL.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                            p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );

   END IF;

   IF FND_MSG_PUB.count_msg > 0 THEN
      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;

   l_stage := 200;
   IF (p_from_proj_fp_options_id IS NOT NULL) THEN
      /* If the Source Proj FP Option is passed, then the records have to be copied
         from pa_fp_elements for the Source FP Option and the Source Element Type. */
      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Source Proj FP Option is passed.';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
      END IF;

      l_from_proj_fp_option_id := p_from_proj_fp_options_id;
      l_from_element_type := p_from_element_type;

   ELSE
       l_stage := 300;
      /* If the Source FP Option is not passed, get the Parent FP Option ID */
      l_par_fp_option_id := PA_PROJ_FP_OPTIONS_PUB.Get_Parent_FP_Option_ID(p_to_proj_fp_options_id);


      IF (l_par_fp_option_id IS NOT NULL) THEN
       /* Since Parent FP Option is found, records have to be copied from pa_fp_elements
          for the Parent FP Option and the Target Element Type.  */
         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Parent FP Option is not null.';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
         END IF;

         l_from_proj_fp_option_id := l_par_fp_option_id ;
         -- l_from_element_type := p_to_element_type;      /* M20-08: commented  this */

         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Got parent. l_from_proj_fp_option_id = '|| l_from_proj_fp_option_id ;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;


         /* M20-AUG changes start from here */
         SELECT pfo_src.fin_plan_preference_code
               ,pfo_target.fin_plan_preference_code
           INTO l_source_preference_code
               ,l_target_preference_code
           FROM PA_PROJ_FP_OPTIONS pfo_src
               ,PA_PROJ_FP_OPTIONS pfo_target
          WHERE pfo_src.proj_fp_options_id = l_from_proj_fp_option_id
            AND pfo_target.proj_fp_options_id = p_to_proj_fp_options_id;


         IF l_source_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN
            /* this is true whenever parent is project level option. Can also be true when
               version is created for cost and revenue separately plan type */
            IF l_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY THEN
               l_from_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

            ELSIF l_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY THEN
               l_from_element_type := PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;

            ELSIF l_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME THEN
               l_from_element_type :=  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;

            ELSIF l_target_preference_code = PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP THEN
               /* this case occurres when adding a cost and revenue separately plan type to a project */
               l_from_element_type :=  p_to_element_type;

            END IF;
         ELSE
            /* adding a version to a plan type. In this case we dont need to do anything.
               this is because when plan type is COST AND REVENUE SEPARATELY then case is already handled
               when plan type is other than this than version and plan type preference code has to be
               same. Hence set the from element type same as to element type */

               l_from_element_type := p_to_element_type;

         END IF;

         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': from element type set = '|| l_from_element_type ;
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
         END IF;


      ELSE
      /* Parent Proj Option ID not found, so Insert Default */
          /* First delete the records from pa_fp_elements and then insert the Default
             Values into PA_FP_Elements table. */

            pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Parent FP Option is null, hence insert_default.';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
            END IF;

            Delete_Elements(p_proj_fp_options_id => p_to_proj_fp_options_id
                            ,p_element_type      => p_to_element_type
                            ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK  -- 'TASK' /* M20-08: changed to null */
                            ,x_return_status     => x_return_status
                            ,x_msg_count         => x_msg_count
                            ,x_msg_data          => x_msg_data);

            /* Insert Default values for the proj_fp_option_id, element_type and planning_level. */
            IF (p_to_element_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH) THEN
                l_stage := 400;
                pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Inserting Default Values for Both - COST
                                                             and REVENUE.';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
                END IF;

                /* Get the value of the Cost and Revenue Planning Level for the proj_fp_options_id
                   depending on the p_element_type value.  */

                   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting planning level.';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
                   END IF;

                   SELECT cost_fin_plan_level_code
                          ,revenue_fin_plan_level_code
                          ,select_cost_res_auto_flag     /* Bug 2920954 */
                          ,cost_res_planning_level       /* Bug 2920954 */
                          ,select_rev_res_auto_flag      /* Bug 2920954 */
                          ,revenue_res_planning_level    /* Bug 2920954 */
                     INTO l_cost_planning_level
                          ,l_rev_planning_level
                          ,l_select_cost_res_auto_flag   /* Bug 2920954 */
                          ,l_cost_res_planning_level     /* Bug 2920954 */
                          ,l_select_rev_res_auto_flag    /* Bug 2920954 */
                          ,l_revenue_res_planning_level  /* Bug 2920954 */
                     FROM pa_proj_fp_options
                    WHERE proj_fp_options_id = p_to_proj_fp_options_id;

               /* Call Insert_Default twice, once with Element_Type as 'COST' and then as PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                  as the case of element_type being 'BOTH' is not handled in Insert_Default. */
               pa_debug.g_err_stage := TO_CHAR(l_Stage)||': calling insert default for cost.';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
               END IF;
               Insert_Default(p_proj_fp_options_id    =>    p_to_proj_fp_options_id
                             ,p_element_type          =>    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                             ,p_planning_level        =>    l_cost_planning_level
                             ,p_resource_list_id      =>    p_to_resource_list_id
                             ,p_select_res_auto_flag  =>    l_select_cost_res_auto_flag /* Bug 2920954 */
                             ,p_res_planning_level    =>    l_cost_res_planning_level   /* Bug 2920954 */
                             ,x_return_status         =>    x_return_status
                             ,x_msg_count             =>    x_msg_count
                             ,x_msg_data              =>    x_msg_data);

               pa_debug.g_err_stage := TO_CHAR(l_Stage)||': calling insert default for revenue.';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
               END IF;

               Insert_Default(p_proj_fp_options_id    =>   p_to_proj_fp_options_id
                             ,p_element_type          =>   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                             ,p_planning_level        =>   l_rev_planning_level
                             ,p_resource_list_id      =>   p_to_resource_list_id
                             ,p_select_res_auto_flag  =>   l_select_rev_res_auto_flag     /* Bug 2920954 */
                             ,p_res_planning_level    =>   l_revenue_res_planning_level   /* Bug 2920954 */
                             ,x_return_status         =>   x_return_status
                             ,x_msg_count             =>   x_msg_count
                             ,x_msg_data              =>   x_msg_data);
            ELSE
                l_stage := 500;
                /* Get the value of the Planning Level for the proj_fp_options_id depending on the
                   p_element_type value.  */

                   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Inserting Default Values for either COST
                                                            OR REVENUE.';
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
                   END IF;

                   /* M20-AUG: replaced select with call to fin plan utils */

                   l_planning_level := PA_FIN_PLAN_UTILS.get_option_planning_level(p_to_proj_fp_options_id ,l_planning_level);

                   IF P_PA_DEBUG_MODE = 'Y' THEN
                        pa_debug.g_err_stage := TO_CHAR(l_Stage)||': fetching auto res addition params from option.';
                        pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
                   END IF;

                   /* Bug 2920954 start of changes */

                   SELECT decode(p_to_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,   select_cost_res_auto_flag
                                               ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,select_rev_res_auto_flag
                                               ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,    select_all_res_auto_flag
                                               ,NULL) select_res_auto_flag
                         ,decode(p_to_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,   cost_res_planning_level
                                               ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,revenue_res_planning_level
                                               ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,    all_res_planning_level
                                               ,NULL) res_planning_level
                     INTO l_select_res_auto_flag
                         ,l_res_planning_level
                     FROM pa_proj_fp_options
                    WHERE proj_fp_options_id = p_to_proj_fp_options_id;

                    /* Bug 2920954 end of changes */

                    pa_debug.g_err_stage := TO_CHAR(l_Stage)||': calling insert default for element type.';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
                    END IF;

                    Insert_Default(p_proj_fp_options_id     =>   p_to_proj_fp_options_id
                                  ,p_element_type           =>   p_to_element_type
                                  ,p_planning_level         =>   l_planning_level
                                  ,p_resource_list_id       =>   p_to_resource_list_id
                                  ,p_select_res_auto_flag   =>   l_select_res_auto_flag   /* Bug 2920954 */
                                  ,p_res_planning_level     =>   l_res_planning_level     /* Bug 2920954 */
                                  ,x_return_status          =>   x_return_status
                                  ,x_msg_count              =>   x_msg_count
                                  ,x_msg_data               =>   x_msg_data);
            END IF;
      END IF;
   END IF;

   IF (l_from_proj_fp_option_id IS NOT NULL AND l_from_element_type IS NOT NULL) THEN
   l_stage := 600;

    /* Get the values of the Plan_Type_ID and Plan_Version_ID of the Target
       FP Option to be used while inserting records into pa_fp_elements. */

        pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting info from to option id.';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
        END IF;

        SELECT fin_plan_type_id, fin_plan_version_id,project_id,
               DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_fin_plan_level_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_fin_plan_level_code) planning_level,
               DECODE(fin_plan_preference_code,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME, all_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,         cost_resource_list_id,
                 PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,      revenue_resource_list_id) resource_list_id
          INTO l_to_fin_plan_type_id, l_to_fin_plan_version_id,l_to_project_id, l_to_planning_level,
               l_to_resource_list_id
          FROM pa_proj_fp_options
         WHERE proj_fp_options_id = p_to_proj_fp_options_id;


    /*Get the project id of source fp options id */
      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting project of source.';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
      END IF;

      SELECT project_id,
             DECODE(l_from_element_type,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,      all_fin_plan_level_code,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,     cost_fin_plan_level_code,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,  revenue_fin_plan_level_code) plan_type_planning_level,
             DECODE(l_from_element_type,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,      all_resource_list_id,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,     cost_resource_list_id,
                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,  revenue_resource_list_id) plan_type_resource_list_id
      INTO   l_from_project_id, l_from_planning_level,l_from_resource_list_id
      FROM   pa_proj_fp_options
      WHERE  proj_fp_options_id = l_from_proj_fp_option_id;
/*      WHERE  proj_fp_options_id = p_from_proj_fp_options_id; manokuma -- UT fixed*/

      /* Bug# 2676352 - Included the below check to catch such cases where copy elements is being called
         with incompatible planning levels. This procedure needs to be changed for handling this */

      IF (l_from_planning_level <> l_to_planning_level OR
         l_from_resource_list_id <> l_to_resource_list_id) THEN

        pa_debug.g_err_stage := 'Bug# 2684787: PA_FP_ELEMENTS_PUB.COPY_ELEMENTS being called with ' ||
                                'incompatible planning levels/resource list ids..';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,4);
        END IF;
        pa_debug.g_err_stage := l_from_planning_level || ':' || l_to_planning_level || ':' ||
                                to_char(l_from_resource_list_id) || ':' || to_char(l_to_resource_list_id);
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,4);
        END IF;
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;


    /* Delete the records from pa_fp_elements for the Target Proj FP Option and Target Element Type
       before inserting records into pa_fp_elements. */
       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Deleting the Elements from FP Elements';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
       END IF;
       Delete_Elements(p_proj_fp_options_id => p_to_proj_fp_options_id
                      ,p_element_type      => p_to_element_type
                      ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK -- 'TASK'
                      ,x_return_status     => x_return_status
                      ,x_msg_count         => x_msg_count
                      ,x_msg_data          => x_msg_data);

    /* Get the records from pa_fp_elements for the Proj FP Option and the Element Type
       and insert into PA_FP_ELEMENTS.   */
       l_stage :=700;

       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Inserting records into PA_FP_ELEMENTS';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
       END IF;

        -- IF source and target projects are same

        IF l_from_project_id = l_to_project_id THEN

                     INSERT INTO pa_fp_elements
                           (PROJ_FP_ELEMENTS_ID
                           ,PROJ_FP_OPTIONS_ID
                           ,PROJECT_ID
                           ,FIN_PLAN_TYPE_ID
                           ,ELEMENT_TYPE
                           ,FIN_PLAN_VERSION_ID
                           ,TASK_ID
                           ,TOP_TASK_ID
                           ,RESOURCE_LIST_MEMBER_ID
                           ,TOP_TASK_PLANNING_LEVEL
                           ,RESOURCE_PLANNING_LEVEL
                           ,PLANNABLE_FLAG
                           ,RESOURCES_PLANNED_FOR_TASK
                           ,PLAN_AMOUNT_EXISTS_FLAG
                           ,TMP_PLANNABLE_FLAG
                           ,TMP_TOP_TASK_PLANNING_LEVEL
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_LOGIN)
                     SELECT pa_fp_elements_s.nextval
                           ,p_to_proj_fp_options_id
                           ,project_id
                           ,l_to_fin_plan_type_id
                           ,decode(p_to_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_to_element_type)
                           ,l_to_fin_plan_version_id
                           ,task_id
                           ,top_task_id
                           ,resource_list_member_id
                           ,top_task_planning_level
                           ,resource_planning_level
                           ,plannable_flag
                           ,resources_planned_for_task
                           ,NVL(plan_amount_exists_flag,'N') /* Bug 2966275 its better to store to as 'N' */
                           ,plannable_flag          /* Same as plannable_flag */
                           ,top_task_planning_level /* Same as top_task_planning_level */
                           ,1
                           ,sysdate
                           ,fnd_global.user_id
                           ,sysdate
                           ,fnd_global.user_id
                           ,fnd_global.login_id
                      FROM pa_fp_elements
                     WHERE proj_fp_options_id = l_from_proj_fp_option_id
                       AND element_type       = decode(l_from_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,l_from_element_type)
                       AND NVL(plan_amount_exists_flag,'N') = decode(p_copy_mode,PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED,'Y',NVL(plan_amount_exists_flag,'N')); /* Bug 2920954 */

              /* Bug 2966275 null handling is necessary for plan_amount_exists_flag as in someplaces its being populated as null */

        ELSE  --if projects are different then

                IF P_PA_DEBUG_MODE = 'Y' THEN
                           pa_debug.g_err_stage := TO_CHAR(l_Stage)||': projects are different.';
                           pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
                END IF;

                INSERT INTO pa_fp_elements
                           (PROJ_FP_ELEMENTS_ID
                           ,PROJ_FP_OPTIONS_ID
                           ,PROJECT_ID
                           ,FIN_PLAN_TYPE_ID
                           ,ELEMENT_TYPE
                           ,FIN_PLAN_VERSION_ID
                           ,TASK_ID
                           ,TOP_TASK_ID
                           ,RESOURCE_LIST_MEMBER_ID
                           ,TOP_TASK_PLANNING_LEVEL
                           ,RESOURCE_PLANNING_LEVEL
                           ,PLANNABLE_FLAG
                           ,RESOURCES_PLANNED_FOR_TASK
                           ,PLAN_AMOUNT_EXISTS_FLAG
                           ,TMP_PLANNABLE_FLAG
                           ,TMP_TOP_TASK_PLANNING_LEVEL
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_LOGIN)
                     SELECT
                            pa_fp_elements_s.nextval
                           ,p_to_proj_fp_options_id
                           ,l_to_project_id
                           ,l_to_fin_plan_type_id
                           ,decode(p_to_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_to_element_type)
                           ,l_to_fin_plan_version_id
                           ,target_pt.task_id
                           ,target_pt.top_task_id
                           ,resource_list_member_id
                           ,top_task_planning_level
                           ,resource_planning_level
                           ,plannable_flag
                           ,resources_planned_for_task
                           ,NVL(plan_amount_exists_flag,'N') /* Bug 2966275 its better to store to as 'N' */
                           ,plannable_flag          /* Same as plannable_flag */
                           ,top_task_planning_level /* Same as top_task_planning_level */
                           ,1
                           ,sysdate
                           ,fnd_global.user_id
                           ,sysdate
                           ,fnd_global.user_id
                           ,fnd_global.login_id
                      FROM pa_fp_elements fp,
                           pa_tasks  source_pt,
                           pa_tasks  target_pt
                     WHERE fp.proj_fp_options_id = l_from_proj_fp_option_id
                       AND fp.task_id = source_pt.task_id
                       AND source_pt.task_number = target_pt.task_number
                       AND target_pt.project_id = l_to_project_id
                       --AND source_pt.project_id = l_from_project_id /* Bug# 2688544 */    Commented for bug 2814165
                       AND element_type       = decode(l_from_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,l_from_element_type);

/*** start of changes  for bug :- 2684766 ***/
                -- The above select just inserts the elements with task_id <> 0
                -- We also need to copy elements having task_id = 0 as in the case of
                -- project level planning for the fp option we have elements with task_id as 'zero'.

                BEGIN
                      SELECT   all_fin_plan_level_code
                              ,cost_fin_plan_level_code
                              ,revenue_fin_plan_level_code
                      INTO     l_all_fin_plan_level_code
                              ,l_cost_fin_plan_level_code
                              ,l_revenue_fin_plan_level_code
                      FROM    pa_proj_fp_options
                      WHERE   proj_fp_options_id = l_from_proj_fp_option_id;

                EXCEPTION
                   WHEN OTHERS THEN
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                              pa_debug.g_err_stage := 'Error while fetching the fp option record of '||l_from_proj_fp_option_id;
                              pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
                       END IF;
                       RAISE;
                END;

                -- If any of these have palnning level is populated as 'P' ie. project
                -- it means for this fp option  there are elemnts with task_id = 0
                -- and they have to be copied.

                IF (l_all_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT) OR
                   (l_cost_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT ) OR
                   (l_revenue_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT )
                THEN
                        INSERT INTO pa_fp_elements
                                   (PROJ_FP_ELEMENTS_ID
                                   ,PROJ_FP_OPTIONS_ID
                                   ,PROJECT_ID
                                   ,FIN_PLAN_TYPE_ID
                                   ,ELEMENT_TYPE
                                   ,FIN_PLAN_VERSION_ID
                                   ,TASK_ID
                                   ,TOP_TASK_ID
                                   ,RESOURCE_LIST_MEMBER_ID
                                   ,TOP_TASK_PLANNING_LEVEL
                                   ,RESOURCE_PLANNING_LEVEL
                                   ,PLANNABLE_FLAG
                                   ,RESOURCES_PLANNED_FOR_TASK
                                   ,PLAN_AMOUNT_EXISTS_FLAG
                                   ,TMP_PLANNABLE_FLAG
                                   ,TMP_TOP_TASK_PLANNING_LEVEL
                                   ,RECORD_VERSION_NUMBER
                                   ,LAST_UPDATE_DATE
                                   ,LAST_UPDATED_BY
                                   ,CREATION_DATE
                                   ,CREATED_BY
                                   ,LAST_UPDATE_LOGIN)
                             SELECT pa_fp_elements_s.nextval
                                   ,p_to_proj_fp_options_id
                                   ,l_to_project_id
                                   ,l_to_fin_plan_type_id
                                   ,decode(p_to_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_to_element_type)
                                   ,l_to_fin_plan_version_id
                                   ,fp.task_id
                                   ,fp.top_task_id
                                   ,resource_list_member_id
                                   ,top_task_planning_level
                                   ,resource_planning_level
                                   ,plannable_flag
                                   ,resources_planned_for_task
                                   ,NVL(plan_amount_exists_flag,'N') /* Bug 2966275 its better to store to as 'N' */
                                   ,plannable_flag          /* Same as plannable_flag */
                                   ,top_task_planning_level /* Same as top_task_planning_level */
                                   ,1
                                   ,sysdate
                                   ,fnd_global.user_id
                                   ,sysdate
                                   ,fnd_global.user_id
                                   ,fnd_global.login_id
                              FROM pa_fp_elements fp
                             WHERE fp.proj_fp_options_id = l_from_proj_fp_option_id
                               AND fp.task_id = 0
                               AND element_type  = decode(l_from_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,l_from_element_type);

                END IF;
/*** end of changes  for bug :- 2684766 ***/

        END IF; --project ids are different


   END IF;

   /* For bug 2976168. Copy the elements from excluded_elements table if the copy mode is not B
      and only when the source exists */

   IF nvl(p_copy_mode ,'-99') <> PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED  AND
      l_from_proj_fp_option_id IS NOT NULL AND
      l_from_element_type IS NOT NULL THEN

         pa_debug.g_err_stage := TO_CHAR(l_stage)||': About to call Copy_Excluded_Elements';
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
         END IF;

         PA_FP_EXCLUDED_ELEMENTS_PUB.Copy_Excluded_Elements
         ( p_from_proj_fp_options_id   => l_from_proj_fp_option_id
          ,p_from_element_type         => l_from_element_type
          ,p_to_proj_fp_options_id     => p_to_proj_fp_options_id
          ,p_to_element_type           => p_to_element_type
          ,x_return_status             => x_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage)||'Copy_Excluded_Elements errored out '||x_msg_data;
                IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
   END IF;

   pa_debug.g_err_stage := TO_CHAR(l_stage)||': End of Copy_Elements';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;
   pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Copy_Elements'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Copy_Elements: ' || l_module_name,SQLERRM,4);
           pa_debug.write('Copy_Elements: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Copy_Elements;

/*==================================================================================================
  INSERT_DEFAULT: This procedure is used to insert records into FP Elements. This procedure is
  called from Copy_Elements and Refresh_FP_Elements.
  -> The insertion of records is based on the Planning Level passed to this procedure. The planning
  level coud be at Top and Lowest Task or only Top Tasks.
  -> Two different cursors are created for this purpose, one for Top and Lowest Tasks and
  one for only Top Tasks.

  NOTE:- Input parameter p_res_planning_level refers to the resource planning level

  Bug 2920954 :- This is an existing api that has been modified to insert resource elements for the
  default task elements based on the i/p parameters for automatic resource selection and resource
  planning level for automatic resource selection.
==================================================================================================*/
PROCEDURE Insert_Default (
          p_proj_fp_options_id     IN   NUMBER
          ,p_element_type          IN   VARCHAR2
          ,p_planning_level        IN   VARCHAR2
          ,p_resource_list_id      IN   NUMBER
          /* Bug 2920954 start of parameters added for post fp-K one off patch */
          ,p_select_res_auto_flag  IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_res_planning_level    IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          /* Bug 2920954 end of parameters added for post fp-K one off patch */
          ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_project_id               pa_proj_fp_options.PROJECT_ID%TYPE;
l_fin_plan_type_id         pa_proj_fp_options.FIN_PLAN_TYPE_ID%TYPE;
l_fin_plan_version_id      pa_proj_fp_options.FIN_PLAN_VERSION_ID%TYPE;
l_msg_count                NUMBER := 0;
l_data                     VARCHAR2(2000);
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            NUMBER;
l_return_status            VARCHAR2(2000);
l_debug_mode               VARCHAR2(30);
l_stage                    NUMBER := 100;
l_planning_level           pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE;
l_resource_list_id         pa_proj_fp_options.ALL_RESOURCE_LIST_ID%TYPE;
-- Bug 2920954 l_res_planning_level       pa_fp_elements.RESOURCE_PLANNING_LEVEL%TYPE;

/* start of variables defined for Bug 2920954*/
l_select_res_auto_flag     pa_proj_fp_options.select_cost_res_auto_flag%TYPE;
l_res_planning_level       pa_proj_fp_options.cost_res_planning_level%TYPE;
/*end of variables defined for Bug 2920954*/

l_resource_list_member_id  CONSTANT pa_fp_elements.RESOURCE_LIST_MEMBER_ID%TYPE := 0;
l_task_planning_level_top  CONSTANT pa_fp_elements.TOP_TASK_PLANNING_LEVEL%TYPE := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP;
l_task_planning_level_low  CONSTANT pa_fp_elements.TOP_TASK_PLANNING_LEVEL%TYPE
                           := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST;
l_res_planned_for_task     CONSTANT pa_fp_elements.RESOURCES_PLANNED_FOR_TASK%TYPE := 'N';
l_plan_amt_exists_flag     CONSTANT pa_fp_elements.PLAN_AMOUNT_EXISTS_FLAG%TYPE  := 'N';

/* Bug 2586647*/
l_res_list_is_uncategorized PA_RESOURCE_LISTS_ALL_BG.UNCATEGORIZED_FLAG%TYPE;
l_is_resource_list_grouped  VARCHAR2(1);
l_group_resource_type_id    PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%TYPE;

/* According to guidelines from Performance group
   plsql table size should never exceed 200 */

   l_plsql_max_array_size   NUMBER := 200;
   l_prev_txn_id            NUMBER := NULL;
   l_counter                NUMBER;  /* Used by plsql tables during their population */

TYPE l_task_id_tbl_typ IS TABLE OF
        pa_tasks.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_top_task_id_tbl_typ IS TABLE OF
        pa_tasks.TOP_TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_top_plan_level_tbl_typ IS TABLE OF
        PA_FP_ELEMENTS.TOP_TASK_PLANNING_LEVEL%TYPE INDEX BY BINARY_INTEGER;
TYPE l_plannable_flag_tbl_typ IS TABLE OF
        PA_FP_ELEMENTS.PLANNABLE_FLAG%TYPE INDEX BY BINARY_INTEGER;

l_task_id_tbl            l_task_id_tbl_typ       ;
l_top_task_id_tbl        l_top_task_id_tbl_typ   ;
l_top_plan_level_tbl     l_top_plan_level_tbl_typ;
l_plannable_flag_tbl     l_plannable_flag_tbl_typ;
l_dummy_task_id_tbl      pa_fp_elements_pub.l_task_id_tbl_typ;

/* Cursor for Top and Lowest Tasks */
/* M24-08: Modified this cursor as it was previously inserting top and lowest task with plannable
   flag as 'N'
   Now first union will select only those top tasks for which any lowest task exists.
   Second union will select all Lowest and 'Top and Lowest' Tasks. If task id is same
   as top and lowest task then planning level will be lowest else null
*/
CURSOR top_low_tasks_cur(p_project_id NUMBER) is

/* Bug 3106741 for performance improvement Order By removed, UNION replaced with UNION ALL */
   SELECT task_id                    task_id
         ,top_task_id                top_task_id
         ,l_task_planning_level_low  top_task_planning_level
         ,'N'                        plannable_flag
     FROM pa_tasks t1
    WHERE project_id = p_project_id
      AND task_id    = top_task_id
      AND exists (SELECT 'x'
                        FROM pa_tasks t2
                       WHERE t2.parent_task_id = t1.task_id)
   UNION ALL -- bug 3106741 UNION
   SELECT task_id                    task_id
         ,top_task_id                top_task_id
         ,decode(task_id,top_task_id,l_task_planning_level_low,null)    top_task_planning_level
         ,'Y'                        plannable_flag
     FROM pa_tasks t1
    WHERE project_id = p_project_id
      AND not exists (SELECT 'x'
                        FROM pa_tasks t2
                       WHERE t2.parent_task_id = t1.task_id);
--    AND task_id <> top_task_id
/*     ORDER BY task_id; Bug 3106741 */

/* Cursor for Top Tasks*/
CURSOR top_tasks_cur(p_project_id NUMBER) is
   SELECT task_id                    task_id
         ,top_task_id                top_task_id
         ,l_task_planning_level_top  top_task_planning_level
         ,'Y'                        plannable_flag
     FROM pa_tasks
    WHERE project_id = p_project_id
      AND task_id    = top_task_id;

BEGIN

    pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.Insert_Default');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Insert_Default: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check for the input parameters not being NULL. */
    IF (p_proj_fp_options_id IS NULL) THEN
            pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Proj FP Option ID cannot be NULL.';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,5);
            END IF;
       IF (p_element_type IS NULL) THEN
           pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Element Type cannot be NULL.';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;
       END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_INV_PARAM_PASSED');
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    l_stage :=200;
    /* If the Planning Level parameter is not passed, get the value of the planning level
       from the table pa_proj_fp_options depending on the Element_Type. */

    pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Getting the value of Planning Level.';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;

    IF (p_planning_level IS NOT NULL) THEN
        /* Planning Level is passed to the procedure, if Proj FP Option records
           have not been saved to the Database. */
        l_planning_level := p_planning_level;
    ELSE

       l_planning_level := PA_FIN_PLAN_UTILS.GET_OPTION_PLANNING_LEVEL(p_proj_fp_options_id,p_element_type);
       /* M20-AUG replaced by call
       SELECT decode(p_element_type,'COST',cost_fin_plan_level_code,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,revenue_fin_plan_level_code,
                     PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,all_fin_plan_level_code,NULL)
         INTO l_planning_level
         FROM pa_proj_fp_options
        WHERE proj_fp_options_id = p_proj_fp_options_id;
      */

    END IF;

    l_stage := 300;
    /* If the Resouce List ID parameter is not passed, get the value of the resource list id
       from the table pa_proj_fp_options depending on the Element_Type. */

    IF (p_resource_list_id IS NOT NULL) THEN
        /* Resource List ID is passed to the procedure, if Proj FP Option records
           have not been saved to the Database. */
        l_resource_list_id := p_resource_list_id;
    ELSE
       pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Resource List ID not passed getting from option.';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
       END IF;

       SELECT decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,cost_resource_list_id
                                   ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,revenue_resource_list_id,
                                    PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,all_resource_list_id,NULL)
         INTO l_resource_list_id
         FROM pa_proj_fp_options
        WHERE proj_fp_options_id = p_proj_fp_options_id;
    END IF;

    /* Bug 2920954 If the auto resource addition paramters aren't passed, get the values
       from the table pa_proj_fp_options depending on the Element_Type. */

    IF (p_select_res_auto_flag IS NULL) AND (p_res_planning_level IS NULL)
    THEN

         IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Auto res addition params not passed getting from option.';
              pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
         END IF;

         SELECT decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,   select_cost_res_auto_flag
                                     ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,select_rev_res_auto_flag
                                     ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,    select_all_res_auto_flag
                                     ,NULL) select_res_auto_flag
               ,decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,   cost_res_planning_level
                                     ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE,revenue_res_planning_level
                                     ,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,    all_res_planning_level
                                     ,NULL) res_planning_level
           INTO l_select_res_auto_flag
               ,l_res_planning_level
           FROM pa_proj_fp_options
          WHERE proj_fp_options_id = p_proj_fp_options_id;

    ELSE

          /* The parameters are passed incase the changes arenot
            commited to the database yet. */

           l_select_res_auto_flag     := p_select_res_auto_flag;
           l_res_planning_level       := p_res_planning_level  ;
    END IF;

   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting project id plan type id and plan version id from option.';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;

   SELECT project_id, fin_plan_type_id, fin_plan_version_id
     INTO l_project_id, l_fin_plan_type_id, l_fin_plan_version_id
     FROM pa_proj_fp_options
    WHERE proj_fp_options_id = p_proj_fp_options_id;

   /* Get the value of the Resource Planning Level. The value is NULL if the resource_list_id of the
      element_type is Uncategorised, else it is "RESOURCE". */
   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': getting resource planning level from resource list.';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;

/*   SELECT decode(uncategorized_flag,'Y',NULL,PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R)
     INTO l_res_planning_level
     FROM pa_resource_lists_all_bg R1, pa_implementations_all I
    WHERE R1.resource_list_id = l_resource_list_id
      AND R1.business_group_id = I.business_group_id;
*/

/* Fix for 2586647. Commented the above select. Replaced with the following call. */

   PA_FIN_PLAN_UTILS.GET_RESOURCE_LIST_INFO(
                    P_RESOURCE_LIST_ID          => l_resource_list_id,
                    X_RES_LIST_IS_UNCATEGORIZED => l_res_list_is_uncategorized,
                    X_IS_RESOURCE_LIST_GROUPED  => l_is_resource_list_grouped,
                    X_GROUP_RESOURCE_TYPE_ID    => l_group_resource_type_id,
                    X_RETURN_STATUS             => x_return_status,
                    X_MSG_COUNT                 => x_msg_count,
                    X_MSG_DATA                  => x_msg_data
                    );

  /*
    If auto res selection is chosen, resource planning level for the task should be
    res_planning_level chosen on the plan_settings page.
   */

   IF   (l_select_res_auto_flag <> 'Y')
   THEN           /* Bug 2920954 */
        IF l_res_list_is_uncategorized = 'N' THEN
          l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;
        ELSE
          l_res_planning_level := NULL;
        END IF;
   END IF;   /* Bug 2920954 */

/* fix for 2586647 */


   l_stage := 400;


   /* The values that are inserted into the table PA_FP_ELEMENTS depending on the the planning level.
      The values of the columns task_id, top_task_id, top_task_planning_level, plannable_flag to be
      inserted into the table would depend on the Planning Level. */

--<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
-- References to PA_FP_ELEMENTS table have been commented as records are no longer inserted in it
--Comment START.

/*
   pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Bulk Inserting records into PA_FP_Elements';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
   END IF;
   IF l_planning_level IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST,PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_M)
   THEN                           --Planning Level is Top and Lowest Task (OR) Lowest Task
     l_stage := 500;
     pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Fetching records for Top and Lowest Tasks.';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
     END IF;

     pa_debug.g_err_stage := TO_CHAR(l_Stage)||': opening top and lowest task cur';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN top_low_tasks_cur(l_project_id);
     LOOP
          FETCH  top_low_tasks_cur BULK COLLECT INTO
                        l_task_id_tbl
                       ,l_top_task_id_tbl
                       ,l_top_plan_level_tbl
                       ,l_plannable_flag_tbl
               LIMIT l_plsql_max_array_size;

          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': fetched ' || sql%rowcount || ' records';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
          END IF;

               IF nvl(l_task_id_tbl.last,0) >= 1 THEN   -- only if something is fetched

                 pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Inserting records for Top and Lowest Tasks.';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                  FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
                   -- Bulk Insert records into PA_FP_ELEMENTS table for the details fetched
                   -- from the above tables.
                     INSERT INTO pa_fp_elements
                           (PROJ_FP_ELEMENTS_ID
                           ,PROJ_FP_OPTIONS_ID
                           ,PROJECT_ID
                           ,FIN_PLAN_TYPE_ID
                           ,ELEMENT_TYPE
                           ,FIN_PLAN_VERSION_ID
                           ,TASK_ID
                           ,TOP_TASK_ID
                           ,RESOURCE_LIST_MEMBER_ID
                           ,TOP_TASK_PLANNING_LEVEL
                           ,RESOURCE_PLANNING_LEVEL
                           ,PLANNABLE_FLAG
                           ,RESOURCES_PLANNED_FOR_TASK
                           ,PLAN_AMOUNT_EXISTS_FLAG
                           ,TMP_PLANNABLE_FLAG
                           ,TMP_TOP_TASK_PLANNING_LEVEL
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_LOGIN)
                     VALUES
                           (pa_fp_elements_s.nextval
                           ,p_proj_fp_options_id
                           ,l_project_id
                           ,l_fin_plan_type_id
                           ,p_element_type
                           ,l_fin_plan_version_id
                           ,l_task_id_tbl(i)
                           ,l_top_task_id_tbl(i)
                           ,l_resource_list_member_id
                           ,l_top_plan_level_tbl(i)
                           ,l_res_planning_level
                           ,l_plannable_flag_tbl(i)
                           ,l_res_planned_for_task
                           ,l_plan_amt_exists_flag
                           ,l_plannable_flag_tbl(i) -- Same as plannable_flag
                           ,l_top_plan_level_tbl(i) -- Same as top_task_planning_level
                           ,1
                           ,sysdate
                           ,fnd_global.user_id
                           ,sysdate
                           ,fnd_global.user_id
                           ,fnd_global.login_id);

                          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': inserted ' || sql%rowcount || ' records';
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
                          END IF;


               END IF;

               EXIT WHEN nvl(l_task_id_tbl.last,0) < l_plsql_max_array_size;

          END LOOP;
     CLOSE top_low_tasks_cur;

   ELSIF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP THEN   -- Planning Level is Top Task
     l_stage := 600;
     pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Fetching records for Top Tasks only.';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     OPEN top_tasks_cur(l_project_id);
     LOOP
          FETCH  top_tasks_cur BULK COLLECT INTO
                        l_task_id_tbl
                       ,l_top_task_id_tbl
                       ,l_top_plan_level_tbl
                       ,l_plannable_flag_tbl
               LIMIT l_plsql_max_array_size;

               IF nvl(l_task_id_tbl.last,0) >= 1 THEN  -- only if something is fetched
                 pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Inserting records for Top Tasks only.';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                  FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
                   -- Bulk Insert records into PA_FP_ELEMENTS table for the details fetched
                   -- from the above tables.
                     INSERT INTO pa_fp_elements
                           (PROJ_FP_ELEMENTS_ID
                           ,PROJ_FP_OPTIONS_ID
                           ,PROJECT_ID
                           ,FIN_PLAN_TYPE_ID
                           ,ELEMENT_TYPE
                           ,FIN_PLAN_VERSION_ID
                           ,TASK_ID
                           ,TOP_TASK_ID
                           ,RESOURCE_LIST_MEMBER_ID
                           ,TOP_TASK_PLANNING_LEVEL
                           ,RESOURCE_PLANNING_LEVEL
                           ,PLANNABLE_FLAG
                           ,RESOURCES_PLANNED_FOR_TASK
                           ,PLAN_AMOUNT_EXISTS_FLAG
                           ,TMP_PLANNABLE_FLAG
                           ,TMP_TOP_TASK_PLANNING_LEVEL
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_LOGIN)
                     VALUES
                           (pa_fp_elements_s.nextval
                           ,p_proj_fp_options_id
                           ,l_project_id
                           ,l_fin_plan_type_id
                           ,p_element_type
                           ,l_fin_plan_version_id
                           ,l_task_id_tbl(i)
                           ,l_top_task_id_tbl(i)
                           ,l_resource_list_member_id
                           ,l_top_plan_level_tbl(i)
                           ,l_res_planning_level
                           ,l_plannable_flag_tbl(i)
                           ,l_res_planned_for_task
                           ,l_plan_amt_exists_flag
                           ,l_plannable_flag_tbl(i) -- Same as plannable_flag
                           ,l_top_plan_level_tbl(i) -- Same as top_task_planning_level
                           ,1
                           ,sysdate
                           ,fnd_global.user_id
                           ,sysdate
                           ,fnd_global.user_id
                           ,fnd_global.login_id);

               END IF;

               EXIT WHEN nvl(l_task_id_tbl.last,0) < l_plsql_max_array_size;

          END LOOP;
     CLOSE top_tasks_cur;

   ELSIF l_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN -- Planning Level is Project

    l_stage := 700;

     -- No records will be inserted into pa_fp_elements if the Planning Level is 'Project'

      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Nothing to be done for Planning Level at PROJECT';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
      END IF;
      NULL;

   END IF; -- End of check for l_planning_level

*/
--<Patchset M: B and F impact changes : AMG:>-- Bug # 3507156
--Comment END

   /*
      Bug 2920954 If the automatic resource addition is chosen, resources need to be added for all the plannable tasks.
      Call add_resources_automatically api with entire option i/p as 'Y'
    */

   IF l_select_res_auto_flag = 'Y'
   THEN

        IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.g_err_stage := TO_CHAR(l_stage)||'Calling add_resources_automatically';
             pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
        END IF;

        PA_FP_ELEMENTS_PUB.Add_resources_automatically
                ( p_proj_fp_options_id    => p_proj_fp_options_id
                 ,p_element_type          => p_element_type
                 ,p_fin_plan_level_code   => l_planning_level
                 ,p_resource_list_id      => l_resource_list_id
                 ,p_res_planning_level    => l_res_planning_level
                 ,p_entire_option         => 'Y'
                 ,p_element_task_id_tbl   => l_dummy_task_id_tbl
                 ,x_return_status         => x_return_status
                 ,x_msg_count             => x_msg_count
                 ,x_msg_data              => x_msg_data
                 );
   END IF;

   pa_debug.g_err_stage := TO_CHAR(l_stage)||': End of Insert_Default';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;
   pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RAISE;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Insert_Default'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Insert_Default: ' || l_module_name,SQLERRM,4);
           pa_debug.write('Insert_Default: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Default;

/*==================================================================================================
  DELETE_ELEMENTS: This procedure is used to delete records from PA_FP_ELEMENTS table for a
  particular Proj FP Options ID depending on the Element Type and the Element Level.
  - If element_type is BOTH, delete both the cost and revenue planning elements.
  - If the element_level is 'TASK', then delete all the task elements and corresponding resources.
  - If the element_level is resource, delete on the resources for all the task elements

  Bug 2976168. Delete from pa_fp_excluded_elements also

==================================================================================================*/
PROCEDURE Delete_Elements (
          p_proj_fp_options_id     IN   NUMBER
          ,p_element_type          IN   VARCHAR2  /* COST,REVENUE,ALL,BOTH */
          ,p_element_level         IN   VARCHAR2  /* TASK,RESOURCE */
          ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_msg_count                NUMBER := 0;
l_data                     VARCHAR2(2000);
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            NUMBER;
l_return_status            VARCHAR2(2000);
l_debug_mode               VARCHAR2(30);

BEGIN

    pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.Delete_Elements');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Delete_Elements: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* Delete the records from the table PA_FP_Elements based on the Element_Type and
      the Element_Level. If the Element_Type is 'BOTH' then both the COST and
      REVENUE Planning Elements have to be deleted. */

     pa_debug.g_err_stage := 'Deleting Elements from PA_FP_Elements';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('Delete_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
     END IF;

      IF (p_element_level = PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK) THEN

      /* If Element Level is 'TASK', then delete FP Elements with Level as 'TASK' */

          pa_debug.g_err_stage := 'Deleting Elements for the Element Level as TASK';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Delete_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
          END IF;

          DELETE FROM pa_fp_elements
           WHERE proj_fp_options_id = p_proj_fp_options_id
             AND element_type = decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_element_type)
             AND p_element_level = PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK ;

          /* For bug 2976168. Delete from pa_fp_excluded_elements also */

          DELETE FROM pa_fp_excluded_elements
          WHERE  proj_fp_options_id = p_proj_fp_options_id
          AND    element_type = decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_element_type)
          AND    p_element_level = PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_TASK ;

      ELSIF (p_element_level = PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_RESOURCE) THEN

      /* If Element Level is 'RESOURCE', then delete FP Elements with Level as
         'RESOURCE' and where the resource_list_memeber_id is not 0 */

          pa_debug.g_err_stage := 'Deleting Elements for the Element Level as RESOURCE';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Delete_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
          END IF;

          DELETE FROM pa_fp_elements
           WHERE proj_fp_options_id = p_proj_fp_options_id
             AND element_type = decode(p_element_type,PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,element_type,p_element_type)
             AND p_element_level = PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_RESOURCE
             AND resource_list_member_id <> 0;
      END IF;

   pa_debug.g_err_stage := 'End of Delete_Elements';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Delete_Elements: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;
   pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Delete_Elements'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Delete_Elements: ' || l_module_name,SQLERRM,4);
           pa_debug.write('Delete_Elements: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Elements;


/*==================================================================================================
  DELETE_ELEMENT: This procedure is used to delete records from PA_FP_ELEMENTS table for a
  particular task_id and resource_list_member_id.
  If resource_list_member_id is populated then only resource level element will be deleted.
  Else if task_id is lowest task and its top task does not have any other tasks then the
       input task_id as well as its top task will be deleted.
==================================================================================================*/
PROCEDURE Delete_Element (
           p_task_id                 IN   NUMBER
          ,p_resource_list_member_id IN   NUMBER
          ,p_budget_version_id       IN   NUMBER
          ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                OUT  NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_msg_count                NUMBER := 0;
l_data                     VARCHAR2(2000);
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            NUMBER;
l_return_status            VARCHAR2(2000);
l_debug_mode               VARCHAR2(30);

l_uncat_res_list_id         pa_resource_lists.RESOURCE_LIST_ID%TYPE;
l_uncat_res_list_mem_id     pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE;
l_uncat_res_id              pa_resource_list_members.RESOURCE_ID%TYPE;
l_uncat_track_as_labor_flg  pa_resource_assignments.TRACK_AS_LABOR_FLAG%TYPE;
l_err_code                  NUMBER;
l_err_stage                 VARCHAR2(100);
l_err_stack                 VARCHAR2(1000);

l_resource_exists_flag      VARCHAR2(1);
l_proj_fp_options_id        PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;

--Bug 2774779
l_top_task_id               pa_tasks.task_id%TYPE;
l_row_update_count          NUMBER;

BEGIN

    pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.Delete_Element');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('Delete_Element: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_debug.g_err_stage := 'calling pa_get_resource.get_uncateg_resource_info';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
    END IF;

     pa_get_resource.get_uncateg_resource_info(p_resource_list_id        => l_uncat_res_list_id
                                              ,p_resource_list_member_id => l_uncat_res_list_mem_id
                                              ,p_resource_id             => l_uncat_res_id
                                              ,p_track_as_labor_flag     => l_uncat_track_as_labor_flg
                                              ,p_err_code                => l_err_code
                                              ,p_err_stage               => l_err_stage
                                              ,p_err_stack               => l_err_stack);

       SELECT proj_fp_options_id
         INTO l_proj_fp_options_id
         FROM pa_proj_fp_options pfo
        WHERE fin_plan_version_id = p_budget_version_id;

     /* #2593264: The following condition was corrected from
        p_resource_list_member_id <> l_uncat_res_list_mem_id. */

     IF (p_resource_list_member_id = l_uncat_res_list_mem_id) THEN

      /* If its an uncategorized resource then task level record needs to be deleted.
         task level records in pa_fp_elements always have resource list member id as zero. */

          pa_debug.g_err_stage := 'Deleting Elements for the task';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
          END IF;

          DELETE FROM pa_fp_elements
           WHERE proj_fp_options_id = l_proj_fp_options_id
             AND task_id = p_task_id
             AND resource_list_member_id = 0
             RETURNING top_task_id into l_top_task_id;  --Bug 2774779

          --Bug 2774779 Maintain the plan amount exists flag for the top task record.
          --This update need not be issued if the planning level is top task(l_top_task_id = p_task_id)
          --as this record would have been deleted already.

          IF l_top_task_id <> p_task_id THEN

               update pa_fp_elements
               set plan_amount_exists_flag = 'N',
                   record_version_number = record_version_number + 1,
                   last_update_date = sysdate,
                   last_updated_by = FND_GLOBAL.USER_ID,
                   last_update_login = FND_GLOBAL.LOGIN_ID
               where proj_fp_options_id = l_proj_fp_options_id
               and task_id = l_top_task_id
               and not exists
               (
                select 1
                from pa_fp_elements
                where top_task_id = l_top_task_id
                and task_id <> l_top_task_id
                and proj_fp_options_id = l_proj_fp_options_id
                and nvl(plan_amount_exists_flag,'N') = 'Y'
               );

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.g_err_stage := 'Number of rows updated for plan amount exists flag : '||sql%rowcount;
                  pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;
          END IF;

      ELSE

          /* If its a normal resource from a resource list then we need to delete the resource
            level element from fp elements. */

             pa_debug.g_err_stage := 'Deleting Elements for the RESOURCE';
             IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
             END IF;

             DELETE FROM pa_fp_elements
              WHERE proj_fp_options_id  = l_proj_fp_options_id  -- included for Bug 3062798
                AND fin_plan_version_id = p_budget_version_id
                AND task_id = p_task_id
                AND resource_list_member_id = p_resource_list_member_id
                RETURNING top_task_id into l_top_task_id;  --Bug 2774779

            -- Bug 2774779
            -- Maintain the plan amount exists flag for the top task and lowest task elements.
            -- The following update also takes care of the situation where resource are planned for the
            -- Top Task and not the lowest task.

            update pa_fp_elements
            set plan_amount_exists_flag = 'N',
                record_version_number = record_version_number + 1,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login = FND_GLOBAL.LOGIN_ID
            where proj_fp_options_id = l_proj_fp_options_id
            and resource_list_member_id = 0
            and task_id = p_task_id
            and not exists
            (
             select 1
             from pa_fp_elements
             where task_id = p_task_id
             and proj_fp_options_id = l_proj_fp_options_id
             and resource_list_member_id <> 0
             and nvl(plan_amount_exists_flag,'N') = 'Y'
            );

            l_row_update_count := sql%rowcount;
            IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.g_err_stage := 'Number of rows updated for plan amount exists flag : '|| l_row_update_count;
                   pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;


             IF p_task_id <> l_top_task_id and l_row_update_count > 0 then

                 update pa_fp_elements
                 set plan_amount_exists_flag = 'N',
                     record_version_number = record_version_number + 1,
                     last_update_date = sysdate,
                     last_updated_by = FND_GLOBAL.USER_ID,
                     last_update_login = FND_GLOBAL.LOGIN_ID
                 where proj_fp_options_id = l_proj_fp_options_id
                 and resource_list_member_id = 0
                 and task_id = l_top_task_id
                 and not exists
                 (
                  select 1
                  from  pa_fp_elements
                  where top_task_id = l_top_task_id
                  and proj_fp_options_id = l_proj_fp_options_id
                  and resource_list_member_id <> 0
                  and nvl(plan_amount_exists_flag,'N') = 'Y'
                 );

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.g_err_stage := 'Number of rows updated for plan amount exists flag : '||sql%rowcount;
                       pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

             END IF;


            /* now need to set the resources_planned_for_task flag. In case the task has no more resources
               defined under it then set this to 'N'
            */

            pa_debug.g_err_stage := 'Checking for more resources under the task';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
            END IF;

            l_resource_exists_flag := 'N';
            BEGIN
                 SELECT 'Y'
                   INTO l_resource_exists_flag
                   FROM dual
                  WHERE exists (select 1
                                  from pa_fp_elements fp
                                 where proj_fp_options_id = l_proj_fp_options_id
                                   and fp.task_id = p_task_id
                                   and fp.resource_list_member_id <> 0);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   l_resource_exists_flag := 'N';
            END;

            IF l_resource_exists_flag = 'N' THEN

                pa_debug.g_err_stage := 'setting resource planning level to N';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
                END IF;

                UPDATE pa_fp_elements
                   SET resources_planned_for_task = 'N',
                       record_version_number = record_version_number + 1,
                       last_update_date = sysdate,
                       last_updated_by = FND_GLOBAL.USER_ID,
                       last_update_login = FND_GLOBAL.LOGIN_ID
                 WHERE proj_fp_options_id = l_proj_fp_options_id
                   AND task_id = p_task_id
                   AND resource_list_member_id = 0;
             END IF;

      END IF;

   pa_debug.g_err_stage := 'End of Delete_Elements';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.g_err_stage,1);
   END IF;
   pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Delete_Element'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('Delete_Element: ' || l_module_name,SQLERRM,4);
           pa_debug.write('Delete_Element: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Element;


/*==================================================================================================
 This procedure inserts records into PA_FP_ELEMENTS in BULK
  ==================================================================================================*/


 PROCEDURE Insert_Bulk_Rows (
            p_proj_fp_options_id       IN NUMBER
           ,p_project_id               IN NUMBER
           ,p_fin_plan_type_id         IN NUMBER
           ,p_element_type             IN VARCHAR2
           ,p_plan_version_id          IN NUMBER
           ,p_task_id_tbl              IN l_task_id_tbl_typ
           ,p_top_task_id_tbl          IN l_top_task_id_tbl_typ
           ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
           ,p_task_planning_level_tbl  IN l_task_planning_level_tbl_typ
           ,p_res_planning_level_tbl   IN l_res_planning_level_tbl_typ
           ,p_plannable_flag_tbl       IN l_plannable_flag_tbl_typ
           ,p_res_planned_for_task_tbl IN l_res_planned_for_task_tbl_typ
           ,p_planamount_exists_tbl    IN l_planamount_exists_tbl_typ
           ,p_res_uncategorized_flag   IN VARCHAR2
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

 l_stage NUMBER :=100;
 l_debug_mode VARCHAR2(10);

 BEGIN

        -- Set the error stack.
           pa_debug.set_err_stack('PA_FP_ELELEMNTS_PUB.Insert_Bulk_Rows');

        -- Get the Debug mode into local variable and set it to 'Y' if its NULL
           fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
           l_debug_mode := NVL(l_debug_mode, 'Y');

        -- Initialize the return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;

            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.set_process('Insert_Bulk_Rows: ' || 'PLSQL','LOG',l_debug_mode);
            END IF;

            pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_ELELEMNTS_PUB.Insert_Bulk_Rows ';
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
            END IF;

      /*
       * Bulk Insert records into PA_FP_ELEMENTS table for the records fetched
       * from cursor top_task_cur.
       */
    pa_debug.g_err_stage := TO_CHAR(l_stage)||': In  Insert_Bulk_Rows';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
    END IF;

    pa_debug.g_err_stage := TO_CHAR(l_stage)||': Bulk inserting into PA_FP_ELEMENTS';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
    END IF;

    FORALL i in p_top_task_id_tbl.first..p_top_task_id_tbl.last

        INSERT INTO pa_fp_elements
             (PROJ_FP_ELEMENTS_ID
             ,PROJ_FP_OPTIONS_ID
             ,PROJECT_ID
             ,FIN_PLAN_TYPE_ID
             ,ELEMENT_TYPE
             ,FIN_PLAN_VERSION_ID
             ,TASK_ID
             ,TOP_TASK_ID
             ,RESOURCE_LIST_MEMBER_ID
             ,TOP_TASK_PLANNING_LEVEL
             ,RESOURCE_PLANNING_LEVEL
             ,PLANNABLE_FLAG
             ,RESOURCES_PLANNED_FOR_TASK
             ,PLAN_AMOUNT_EXISTS_FLAG
             ,TMP_PLANNABLE_FLAG
             ,TMP_TOP_TASK_PLANNING_LEVEL
             ,RECORD_VERSION_NUMBER
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,CREATION_DATE
             ,CREATED_BY
             ,LAST_UPDATE_LOGIN)
        VALUES
             (pa_fp_elements_s.nextval
             ,p_proj_fp_options_id
             ,p_project_id
             ,p_fin_plan_type_id
             ,p_element_type
             ,p_plan_version_id
             ,p_task_id_tbl(i)
             ,p_top_task_id_tbl(i)
             ,decode(p_res_uncategorized_flag,'Y',0,p_res_list_mem_id_tbl(i))
             ,p_task_planning_level_tbl(i)
             ,p_res_planning_level_tbl(i)
             ,p_plannable_flag_tbl(i)
             ,p_res_planned_for_task_tbl(i)
             ,p_planamount_exists_tbl(i)
             ,p_plannable_flag_tbl(i)
             ,p_task_planning_level_tbl(i)
             ,1
             ,sysdate
             ,fnd_global.user_id
             ,sysdate
             ,fnd_global.user_id
             ,fnd_global.login_id);

     pa_debug.reset_err_stack;
 EXCEPTION
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Insert_Bulk_Rows'
             ,p_procedure_name =>  pa_debug.G_Err_Stack );
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,SQLERRM,4);
            pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.G_Err_Stack,4);
         END IF;
         pa_debug.reset_err_stack;

         raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END Insert_Bulk_Rows;

/*==================================================================================================
 This procedure inserts records into PA_RESOURCE_ASSIGNMENTS in BULK
  ==================================================================================================*/

 PROCEDURE Insert_Bulk_Rows_Res (
            p_project_id               IN NUMBER
           ,p_plan_version_id          IN NUMBER
           ,p_task_id_tbl              IN l_task_id_tbl_typ
           ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
           ,p_unit_of_measure_tbl      IN l_unit_of_measure_tbl_typ
           ,p_track_as_labor_flag_tbl  IN l_track_as_labor_flag_tbl_typ
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 ) is --File.Sql.39 bug 4440895

 l_stage NUMBER :=100;
 l_debug_mode VARCHAR2(10);

 BEGIN

       -- Set the error stack.
          pa_debug.set_err_stack('PA_FP_ELELEMNTS_PUB.Insert_Bulk_Rows_Res');

       -- Get the Debug mode into local variable and set it to 'Y' if its NULL
          fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
          l_debug_mode := NVL(l_debug_mode, 'Y');

       -- Initialize the return status to success
           x_return_status := FND_API.G_RET_STS_SUCCESS;

           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.set_process('Insert_Bulk_Rows: ' || 'PLSQL','LOG',l_debug_mode);
           END IF;

           pa_debug.g_err_stage := TO_CHAR(l_stage)||':In PA_FP_ELELEMNTS_PUB.Insert_Bulk_Rows_Res ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
           END IF;


      /*
       * Bulk Insert records into PA_FP_ELEMENTS table for the records fetched
       * from cursor top_task_cur.
       */
    pa_debug.g_err_stage := TO_CHAR(l_stage)||': In  Insert_Bulk_Rows_Res';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
    END IF;

    pa_debug.g_err_stage := TO_CHAR(l_stage)||': Bulk inserting into PA_RESOURCE_ASSIGNMENTS';
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.g_err_stage,2);
    END IF;

    FORALL i in p_task_id_tbl.first..p_task_id_tbl.last

        INSERT INTO pa_resource_assignments
            (RESOURCE_ASSIGNMENT_ID
            ,BUDGET_VERSION_ID
            ,PROJECT_ID
            ,TASK_ID
            ,RESOURCE_LIST_MEMBER_ID
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,UNIT_OF_MEASURE
            ,TRACK_AS_LABOR_FLAG
            ,PROJECT_ASSIGNMENT_ID
            ,RESOURCE_ASSIGNMENT_TYPE )
        VALUES
            (PA_RESOURCE_ASSIGNMENTS_S.NEXTVAL
            ,p_plan_version_id                -- BUDGET_VERSION_ID
            ,p_project_id                     -- PROJECT_ID
            ,p_task_id_tbl(i)                 -- TASK_ID
            ,p_res_list_mem_id_tbl(i)         -- RESOURCE_LIST_MEMBER_ID
            ,sysdate                          -- LAST_UPDATE_DATE
            ,fnd_global.user_id               -- LAST_UPDATED_BY
            ,sysdate                          -- CREATION_DATE
            ,fnd_global.user_id               -- CREATED_BY
            ,fnd_global.login_id              -- LAST_UPDATE_LOGIN
            ,p_unit_of_measure_tbl(i)         -- UNIT_OF_MEASURE
            ,p_track_as_labor_flag_tbl(i)     -- TRACK_AS_LABOR_FLAG
            ,-1                               -- PROJECT_ASSIGNMENT_ID
            ,PA_FP_CONSTANTS_PKG.G_USER_ENTERED)   ;  -- RESOURCE_ASSIGNMENT_TYPE

        pa_debug.reset_err_stack;

 EXCEPTION
   WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count     := 1;
         x_msg_data      := SQLERRM;
         FND_MSG_PUB.add_exc_msg
            ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.Insert_Bulk_Rows_Res'
             ,p_procedure_name =>  pa_debug.G_Err_Stack );
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,SQLERRM,4);
            pa_debug.write('Insert_Bulk_Rows: ' || l_module_name,pa_debug.G_Err_Stack,4);
         END IF;
         pa_debug.reset_err_stack;

         raise FND_API.G_EXC_UNEXPECTED_ERROR;

 END Insert_Bulk_Rows_Res;


/*============================================================================
  This api  makes use of PA_FP_ELEMENTS and enters only user_entered records
  if they aren't already present in PA_RESOURCE_ASSIGNMENTS. Uncategorised
  resource_list has been dealt separately, as in this case, we can avoid a
  table join with pa_resource_list_members.It also deals the case when
  planning level is project and resource_list is uncategorised, in which
  case the given version doesn't have a record  in PA_FP_ELEMENTS.

  Bug 2920954 - To create ras for a particular task and control deletion
  of resource assignments, p_task_id and p_res_del_req_flag parameters have
  been introduced.
 ============================================================================*/

   PROCEDURE create_enterable_resources
      ( p_plan_version_id      IN    NUMBER
        ,p_task_id             IN    pa_tasks.task_id%TYPE /* Bug 2920954 */
        ,p_res_del_req_flag    IN    VARCHAR2              /* Bug 2920954 */
        ,x_return_status       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count           OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data            OUT   NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   AS

     l_msg_count       NUMBER := 0;
     l_data            VARCHAR2(2000);
     l_msg_data        VARCHAR2(2000);
     l_error_msg_code  VARCHAR2(30);
     l_msg_index_out   NUMBER;
     l_return_status   VARCHAR2(2000);
     l_debug_mode      VARCHAR2(30);

     l_max_fetch_size  NUMBER  := 200; -- limiting the max fetch size

     l_resource_list_id    PA_BUDGET_VERSIONS.RESOURCE_LIST_ID%TYPE;
     l_project_id          PA_BUDGET_VERSIONS.PROJECT_ID%TYPE;
     l_uncat_flag          PA_RESOURCE_LISTS.UNCATEGORIzED_FLAG%TYPE;
     l_fp_pref_code        PA_PROJ_FP_OPTIONS.FIN_PLAN_PREFERENCE_CODE%TYPE;
     l_fp_level_code       PA_PROJ_FP_OPTIONS.COST_FIN_PLAN_LEVEL_CODE%TYPE;
     l_proj_fp_options_id  PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;
     l_uncat_rlmid         PA_RESOURCE_ASSIGNMENTS.RESOURCE_LIST_MEMBER_ID%TYPE;
     l_track_as_labor_flag PA_RESOURCE_LIST_MEMBERS.TRACK_AS_LABOR_FLAG%TYPE;
     l_unit_of_measure     PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE;

     TYPE l_ra_id_tbl_typ IS TABLE OF
             PA_RESOURCE_ASSIGNMENTS.RESOURCE_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER;

     l_task_id_tbl                l_task_id_tbl_typ;
     l_rlmid_tbl                  l_res_list_mem_id_tbl_typ;
     l_track_as_labor_flag_tbl    l_track_as_labor_flag_tbl_typ;
     l_uom_tbl                    l_unit_of_measure_tbl_typ;
     l_ra_id_tbl                  l_ra_id_tbl_typ;

     CURSOR l_cur_for_uncat_project_level IS
            SELECT  0              --task_id
                    ,l_uncat_rlmid --resource_list_member_id
                    ,l_track_as_labor_flag
                    ,l_unit_of_measure    /* Modified for bug #2586307. */
             FROM   DUAL
             WHERE  NOT EXISTS ( SELECT 'x'
                                 FROM   pa_resource_assignments ra
                                 WHERE  ra.budget_version_id = p_plan_version_id
                                   AND  ra.task_id           = 0
                                   AND  ra.resource_list_member_id =
                                                l_uncat_rlmid);

     CURSOR  l_cur_for_uncat_task_level IS
            SELECT fp.task_id     --task_id
                   ,l_uncat_rlmid --resource_list_member_id
                   ,l_track_as_labor_flag
                   ,l_unit_of_measure     /* Modified for bug #2586307. */
            FROM   pa_fp_elements fp
            WHERE  proj_fp_options_id = l_proj_fp_options_id  /* included for bug 3062798*/
            AND  fin_plan_version_id = p_plan_version_id
            AND  plannable_flag = 'Y'
            AND  fp.task_id =  Nvl(p_task_id,fp.task_id) /* Bug 2920954 */
            AND  NOT EXISTS ( SELECT 'x'
                              FROM   pa_resource_assignments ra
                              WHERE  ra.budget_version_id = fp.fin_plan_version_id
                                AND  ra.project_id        = fp.project_id
                                AND  ra.task_id           = fp.task_id
                                AND  ra.resource_list_member_id = l_uncat_rlmid);

     CURSOR l_cur_for_cat_res_list IS
           SELECT fp.task_id
                  ,fp.resource_list_member_id
                  ,prlm.track_as_labor_flag
                  ,decode(prlm.track_as_labor_flag,'Y',PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,
                          'N',decode(pr.unit_of_measure,PA_FP_CONSTANTS_PKG.G_UNIT_OF_MEASURE_HOURS,NULL,pr.unit_of_measure)
                          ) unit_of_measure /* Modified for bug #2586307 */
           FROM   pa_fp_elements fp, pa_resource_list_members prlm, pa_resources pr
           WHERE  proj_fp_options_id = l_proj_fp_options_id  /* included for bug 3062798*/
             AND  fin_plan_version_id = p_plan_version_id
             AND  fp.resource_list_member_id <> 0 -- select only resource level records
             AND  fp.plannable_flag = 'Y'         --resource is plannable
             AND  fp.resource_list_member_id = prlm.resource_list_member_id
             AND  pr.resource_id = prlm.resource_id
             AND  fp.task_id =  Nvl(p_task_id,fp.task_id) /* Bug 2920954 */
             AND  NOT EXISTS ( SELECT 'x'
                               FROM   pa_resource_assignments ra
                               WHERE  ra.budget_version_id = fp.fin_plan_version_id
                                 AND  ra.project_id        = fp.project_id
                                 AND  ra.task_id           = fp.task_id
                                 AND  ra.resource_list_member_id =
                                               fp.resource_list_member_id);

 /* Added for the bug #2615837 */
     CURSOR l_cur_for_res_del IS
           SELECT pra.resource_assignment_id
             FROM pa_resource_assignments pra
            WHERE pra.budget_version_id = p_plan_version_id
              AND resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED
              AND NOT EXISTS (SELECT 1
                                FROM pa_fp_elements fpe
                               WHERE proj_fp_options_id = l_proj_fp_options_id  /* included for bug 3062798*/
                                 AND fpe.fin_plan_version_id = p_plan_version_id
                                 AND fpe.task_id = pra.task_id
                                 AND fpe.resource_list_member_id = decode(pra.resource_list_member_id,l_uncat_rlmid,
                                                                           0,pra.resource_list_member_id)
                    );
   BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.Create_Enterable_Resources');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('create_enterable_resources: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;


      -- Check for business rules violations

      pa_debug.g_err_stage:= 'validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Check if plan version id is null

      IF p_plan_version_id is NULL THEN

           pa_debug.g_err_stage:= 'plan version id is null';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      pa_debug.g_err_stage:='fetching resource_list_id, project_id';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT resource_list_id
             ,project_id
      INTO   l_resource_list_id
             ,l_project_id
      FROM   pa_budget_versions
      WHERE  budget_version_id = p_plan_version_id;

      -- 3062798 fetch options_id and use in the cursors to
      -- avoid full table scan on pa_fp_elements

      SELECT proj_fp_options_id
      INTO   l_proj_fp_options_id
      FROM   pa_proj_fp_options
      WHERE  fin_plan_version_id = p_plan_version_id;

      pa_debug.g_err_stage:='checking if resource list is uncategorised';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
      END IF;

      SELECT NVL(uncategorized_flag,'N')
      INTO   l_uncat_flag
      FROM   pa_resource_lists
      WHERE  resource_list_id = l_resource_list_id;


     /* Checking uncategorised flag to avoid a join with
      * pa_resource_list_members table if it is 'Y'
      */

      IF l_uncat_flag = 'Y' THEN

           -- Fetch resource_list_member_id and track_as_labor_flag and unit of measure

           pa_debug.g_err_stage:='resource_list is uncategorised ';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           pa_debug.g_err_stage:=' fetching resource_list_member_id,track_as_labor_flag';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           DECLARE
             l_dummy_res_list_id PA_RESOURCE_LISTS_ALL_BG.resource_list_id%TYPE;
           BEGIN

             PA_FIN_PLAN_UTILS.Get_Uncat_Resource_List_Info
             (x_resource_list_id        => l_dummy_res_list_id
             ,x_resource_list_member_id => l_uncat_rlmid
             ,x_track_as_labor_flag     => l_track_as_labor_flag
             ,x_unit_of_measure         => l_unit_of_measure
             ,x_return_status           => x_return_status
             ,x_msg_count               => x_msg_count
             ,x_msg_data                => x_msg_data);

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               pa_debug.g_err_stage := 'Error while fetching uncat res list id info ...';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,5);
               END IF;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
             END IF;

           END;

     END IF;


     pa_debug.g_err_stage:= 'parameter validation complete';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     --Fetching the finplan planning level

     l_fp_level_code := pa_fin_plan_utils.get_fin_plan_level_code(
                                      p_fin_plan_version_id => p_plan_version_id);

     /* #2615837: If the resources have been unchecked in the pages, then the elements are
        deleted from pa_fp_elements but not from resource_assignments. These records have
        to be deleted from pa_resource_assignments also else they will be once again
        available in the Edit Plan page. */

     /* Should NOT be done when planning level is project and resource list is uncategorized
        as there needs to be one record existing in pa_resource_assignments for this case. */

     /* Bug #2634979: Modified the logic of deleting records from pa_resource_assignments.
        If the Planning level is 'Project' and the resource list is uncategorized, then
        the records for the Plan Version ID have to be deleted except the project level
        records and the records with uncategorized resource list member id.

        This will handle the case where the plannning level has been modified to 'Project',
        and the resource list has been changed to an uncategorized resource list.
        In this case the old records have to be deleted from resource assignments and new
        resource assignments need to be created after the new FP elements are define. */


     /* Bug 2920954 - Deletion of resource assignments would be done only if p_res_del_req_flag is Y */

        IF p_res_del_req_flag = 'Y' THEN

          IF (l_fp_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT AND
                         l_uncat_flag =  'Y' ) THEN

                 pa_debug.g_err_stage:= 'Deleting resource assignments';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 DELETE FROM pa_resource_assignments
                  WHERE budget_version_id = p_plan_version_id
                    AND (task_id <> 0 or resource_list_member_id <> l_uncat_rlmid);

          ELSE

          /* In all other cases, records have to be deleted from pa_resource_assignments
             which do not exist in pa_fp_elements. */

                 pa_debug.g_err_stage:= 'fetching resource assignments that should be deleted';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 OPEN l_cur_for_res_del;
                    pa_debug.g_err_stage:= 'Deleting records from Resource Assignments.';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    FETCH l_cur_for_res_del BULK COLLECT INTO
                          l_ra_id_tbl;

                    pa_debug.g_err_stage := 'Fetched ' || sql%rowcount || ' records';
                    IF P_PA_DEBUG_MODE = 'Y' THEN
                       pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                    END IF;

                    IF (nvl(l_ra_id_tbl.last,0) > 0) THEN

                          FORALL i in l_ra_id_tbl.first..l_ra_id_tbl.last

                             DELETE FROM pa_resource_assignments
                              WHERE resource_assignment_id = l_ra_id_tbl(i);

                             pa_debug.g_err_stage := 'Deleted ' || sql%rowcount || ' records';
                             IF P_PA_DEBUG_MODE = 'Y' THEN
                                pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                             END IF;
                    END IF;
                  CLOSE l_cur_for_res_del;

          END IF;

     END IF; /* Bug 2920954 - p_res_del_req_flag = 'Y' */

     IF l_uncat_flag ='Y' THEN

           IF l_fp_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

               -- CASE:planning level 'project' and  'uncategorised resource_list'

               pa_debug.g_err_stage:='project level planning and resource_list uncategorised';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;
               pa_debug.g_err_stage:='opening l_cur_for_uncat_project_level';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               OPEN   l_cur_for_uncat_project_level;

                 pa_debug.g_err_stage:= 'fetching cursor values and doing bulk insert';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

               LOOP

                    FETCH l_cur_for_uncat_project_level BULK COLLECT INTO
                          l_task_id_tbl
                          ,l_rlmid_tbl
                          ,l_track_as_labor_flag_tbl
                          ,l_uom_tbl
                    LIMIT l_max_fetch_size;

                    --Calling Bulk insert api

                    IF nvl(l_task_id_tbl.last,0) >= 1 THEN
                            Insert_Bulk_Rows_Res(
                        p_project_id             =>l_project_id
                       ,p_plan_version_id        =>p_plan_version_id
                       ,p_task_id_tbl            =>l_task_id_tbl
                       ,p_res_list_mem_id_tbl    =>l_rlmid_tbl
                       ,p_unit_of_measure_tbl    =>l_uom_tbl
                       ,p_track_as_labor_flag_tbl=>l_track_as_labor_flag_tbl
                       ,x_return_status          =>l_return_status
                       ,x_msg_count              =>l_msg_count
                       ,x_msg_data               =>l_msg_data  );
                    END IF;

               -- Exit if fetch size is less than 200

                    EXIT WHEN NVL(l_task_id_tbl.last,0) < l_max_fetch_size;

               END LOOP;

               CLOSE l_cur_for_uncat_project_level;


           ELSIF l_fp_level_code <> PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

               -- CASE: planning level 'task' and uncategorised resource_list

               pa_debug.g_err_stage:='task level planning and Uncategorised resource_list';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               pa_debug.g_err_stage:='opening l_elements_cur';
               IF P_PA_DEBUG_MODE = 'Y' THEN
                  pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
               END IF;

               OPEN   l_cur_for_uncat_task_level;

                 pa_debug.g_err_stage:= 'fetching cursor values and doing bulk insert';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

               LOOP

                    FETCH l_cur_for_uncat_task_level BULK COLLECT INTO
                          l_task_id_tbl
                          ,l_rlmid_tbl
                          ,l_track_as_labor_flag_tbl
                          ,l_uom_tbl
                    LIMIT l_max_fetch_size;

                    --Calling Bulk insert api

                      IF nvl(l_task_id_tbl.last,0) >= 1 THEN
                            Insert_Bulk_Rows_Res(
                        p_project_id             =>l_project_id
                       ,p_plan_version_id        =>p_plan_version_id
                       ,p_task_id_tbl            =>l_task_id_tbl
                       ,p_res_list_mem_id_tbl    =>l_rlmid_tbl
                       ,p_unit_of_measure_tbl    =>l_uom_tbl
                       ,p_track_as_labor_flag_tbl=>l_track_as_labor_flag_tbl
                       ,x_return_status          =>l_return_status
                       ,x_msg_count              =>l_msg_count
                       ,x_msg_data               =>l_msg_data  );
                    END IF;

                     -- Exit if fetch size is less than 200

                    EXIT WHEN NVL(l_task_id_tbl.last,0) < l_max_fetch_size;

               END LOOP;

               CLOSE l_cur_for_uncat_task_level;

           END IF; -- l_fp_level_code

     ELSIF l_uncat_flag = 'N' THEN

           -- CASE: resource_list is categorised

           pa_debug.g_err_stage:='Categorised resource_list';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           pa_debug.g_err_stage:='opening l_cur_for_cat_res_list';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
           END IF;

           OPEN   l_cur_for_cat_res_list;

                 pa_debug.g_err_stage:= 'fetching cursor values and doing bulk insert';
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

           LOOP

                    FETCH l_cur_for_cat_res_list BULK COLLECT INTO
                          l_task_id_tbl
                          ,l_rlmid_tbl
                          ,l_track_as_labor_flag_tbl
                          ,l_uom_tbl
                    LIMIT l_max_fetch_size;

                    --Calling Bulk insert api

                      IF nvl(l_task_id_tbl.last,0) >= 1 THEN
                            Insert_Bulk_Rows_Res(
                        p_project_id             =>l_project_id
                       ,p_plan_version_id        =>p_plan_version_id
                       ,p_task_id_tbl            =>l_task_id_tbl
                       ,p_res_list_mem_id_tbl    =>l_rlmid_tbl
                       ,p_unit_of_measure_tbl    =>l_uom_tbl
                       ,p_track_as_labor_flag_tbl=>l_track_as_labor_flag_tbl
                       ,x_return_status          =>l_return_status
                       ,x_msg_count              =>l_msg_count
                       ,x_msg_data               =>l_msg_data  );
                     END IF;

                     -- Exit if fetch size is less than 200

                     EXIT WHEN NVL(l_task_id_tbl.last,0) < l_max_fetch_size;

           END LOOP;

           CLOSE l_cur_for_cat_res_list;

     END IF; --l_uncat_flag

     pa_debug.g_err_stage:= 'Exiting Create_Enterable_Resources';
     IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,3);
     END IF;

     pa_debug.reset_err_stack;

  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,5);
           END IF;

           x_return_status := FND_API.G_RET_STS_ERROR;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_FP_ELEMENTS_PUB'
                                  ,p_procedure_name  => 'CREATE_ENTERABLE_RESOURCES');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('create_enterable_resources: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END create_enterable_resources;

/*==================================================================================================
  get_element_id: This procedure is used from setup pages to get the element id in case an element
  is already available in database.
==================================================================================================*/
FUNCTION get_element_id (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.proj_fp_elements_id%TYPE
IS

l_proj_fp_elements_id pa_fp_elements.proj_fp_elements_id%TYPE := -99;
BEGIN

   SELECT proj_fp_elements_id
     INTO l_proj_fp_elements_id
     FROM pa_fp_elements fpe
    WHERE fpe.proj_fp_options_id = p_proj_fp_options_id
      AND fpe.element_type = p_element_type
      AND fpe.task_id = p_task_id
      AND fpe.resource_list_member_id = p_resource_list_member_id;

   RETURN l_proj_fp_elements_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_proj_fp_elements_id := -99;
       RETURN l_proj_fp_elements_id; /* when no data found then return -99 */
  WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_element_id;

/*==================================================================================================
  get_element_plannable_flag: This procedure is used from setup pages to get the plannable flag  in
  case an element is already available in database.
==================================================================================================*/
FUNCTION get_element_plannable_flag (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.plannable_flag%TYPE
IS

l_plannable_flag pa_fp_elements.plannable_flag%TYPE := 'N';
BEGIN

   SELECT plannable_flag
     INTO l_plannable_flag
     FROM pa_fp_elements fpe
    WHERE fpe.proj_fp_options_id = p_proj_fp_options_id
      AND fpe.element_type = p_element_type
      AND fpe.task_id = p_task_id
      AND fpe.resource_list_member_id = p_resource_list_member_id;

   RETURN l_plannable_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_plannable_flag := 'N';
       RETURN l_plannable_flag;
  WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_element_plannable_flag;

/*==================================================================================================
  get_plan_amount_exists_flag: This procedure is used from setup pages to get the plan amount exists
  in case an elementis already available in database.
==================================================================================================*/
FUNCTION get_plan_amount_exists_flag (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.plan_amount_exists_flag%TYPE
IS

l_plan_amount_exists_flag pa_fp_elements.plan_amount_exists_flag%TYPE := 'N';
BEGIN

   SELECT plan_amount_exists_flag
     INTO l_plan_amount_exists_flag
     FROM pa_fp_elements fpe
    WHERE fpe.proj_fp_options_id = p_proj_fp_options_id
      AND fpe.element_type = p_element_type
      AND fpe.task_id = p_task_id
      AND fpe.resource_list_member_id = p_resource_list_member_id;

   RETURN l_plan_amount_exists_flag;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_plan_amount_exists_flag := 'N';
       RETURN l_plan_amount_exists_flag;
  WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_plan_amount_exists_flag;

/*=======================================================================
The following function returns resource_planning_level based upon the i/ps.
========================================================================*/
FUNCTION get_resource_planning_level(
          p_parent_member_id            IN      pa_resource_list_members.parent_member_id%TYPE
         ,p_uncategorized_flag          IN      pa_resource_lists.uncategorized_flag%TYPE
         ,p_grouped_flag                IN      VARCHAR2)
RETURN pa_fp_elements.resource_planning_level%TYPE IS

l_resource_planning_level pa_fp_elements.resource_planning_level%TYPE;

BEGIN
    IF p_uncategorized_flag = 'N' THEN
            IF p_grouped_flag = 'Y' THEN

                    IF p_parent_member_id IS NULL THEN

                         l_resource_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_G;

                    ELSE
                         l_resource_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;

                    END IF; --parent_member_id

            ELSIF p_grouped_flag = 'N'  THEN

                        l_resource_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;

            END IF; --p_grouped_flag
    ELSIF p_uncategorized_flag = 'Y' THEN

            l_resource_planning_level := NULL;

    END IF;

    RETURN  l_resource_planning_level;
END get_resource_planning_level;

/*===================================================================
The follwing procedure creates elements from the budget versions id
passed for the fp options id passed. The starategy is
  1)First,create resource level elements
  2)Then, create task level elements which are plannable and present in
          pa_resource_assignments.
  3)Lastly,create top task level elements for the above included tasks
    if they aren't already created.

 Bug:- 2634900, the cursors have been modified so that the api can be
 called mulitiple times and the next time the api is called only those
 elements that are not inserted already are chosen for insertion.

 Bug :- 2625872, In the new budgets model,for a given task the user can
 plan either at resource level or resource group level butn't both.
 As this api is also being used to upgrade budget_versions from old model
 to new model, we should check if mixed resource planning level exists
 for the current budget version.
 ===================================================================*/
PROCEDURE Create_elements_from_version(
          p_proj_fp_options_id                  IN      pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type                       IN      pa_fp_elements.element_type%TYPE
          ,p_from_version_id                    IN      pa_budget_versions.budget_version_id%TYPE
          ,p_resource_list_id                   IN      pa_budget_versions.resource_list_id%TYPE
          ,x_mixed_resource_planned_flag        OUT     NOCOPY VARCHAR2  -- new parameter for Bug :- 2625872 --File.Sql.39 bug 4440895
          ,x_return_status                      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                           OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_return_status                         VARCHAR2(2000);
l_msg_count                             NUMBER :=0;
l_msg_data                              VARCHAR2(2000);
l_data                                  VARCHAR2(2000);
l_msg_index_out                         NUMBER;
l_debug_mode                            VARCHAR2(30);

l_plsql_max_array_size                  NUMBER := 200;

l_uncategorized_flag                    pa_resource_lists.uncategorized_flag%TYPE;
l_grouped_flag                          VARCHAR2(1);  --indicates if resource_list is grouped
l_group_resource_type_id                pa_resource_lists.group_resource_type_id%TYPE;

l_task_id_tbl                           l_task_id_tbl_typ;
l_top_task_id_tbl                       l_top_task_id_tbl_typ;
l_res_list_member_id_tbl                l_res_list_mem_id_tbl_typ;
l_top_task_planning_level_tbl           l_task_planning_level_tbl_typ;
l_res_planning_level_tbl                l_res_planning_level_tbl_typ;
l_plannable_flag_tbl                    l_plannable_flag_tbl_typ;
l_res_planned_for_task_tbl              l_res_planned_for_task_tbl_typ;
l_plan_amount_exists_flag_tbl           l_planamount_exists_tbl_typ;

        ----  variables  added for  Bug :- 2625872 ----

TYPE l_resource_level_tbl_typ IS TABLE OF
     VARCHAR2(30) INDEX BY BINARY_INTEGER;

l_resource_level_tbl                    l_resource_level_tbl_typ;
l_prev_res_level                        VARCHAR2(30);
l_prev_task_id                          pa_tasks.task_id%TYPE;

-- The following exception would be raised if the budget version
-- has mixed resource planning level

Mixed_Res_Plan_Level_Exc                EXCEPTION;

        ----  variables  added for  Bug :- 2625872 ----

CURSOR fp_options_cur(
       c_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
       ,c_element_type         IN   pa_fp_elements.element_type%TYPE) IS
SELECT project_id
      ,fin_plan_type_id
      ,fin_plan_version_id
      ,PA_FIN_PLAN_UTILS.GET_OPTION_PLANNING_LEVEL(c_proj_fp_options_id,c_element_type) fin_plan_level_code
FROM  pa_proj_fp_options
WHERE proj_fp_options_id = c_proj_fp_options_id;

fp_options_rec   fp_options_cur%ROWTYPE;

-- The following cursor is opened for the case of project level planning and
-- categorized resource list

CURSOR resources_for_proj_level_cur(
         c_from_version_id  IN   pa_budget_versions.budget_version_id%TYPE) IS
SELECT  0      task_id
       ,0      top_task_id
       ,pra.resource_list_member_id  resource_list_member_id
       ,NULL    top_task_planning_level
       ,NULL    resource_planning_level
       ,'Y'     plannable_flag
       ,NULL    resources_planned_for_task
       ,'Y'     plan_amount_exists_flag
       ,DECODE(prlm.parent_member_id, NULL, 'G','R')     resource_level   -- Bug :- 2625872
FROM   pa_resource_assignments pra
       ,pa_resource_list_members prlm
WHERE  budget_version_id = c_from_version_id
AND    NVL(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_USER_ENTERED) =
              PA_FP_CONSTANTS_PKG.G_USER_ENTERED
AND    prlm.resource_list_member_id = pra.resource_list_member_id
AND    NOT EXISTS(select 'x' from pa_fp_elements e
                  where  e.proj_fp_options_id = p_proj_fp_options_id
                  and    e.element_Type       = p_element_Type
                  and    e.task_id            = 0
                  and    e.resource_list_member_id = pra.resource_list_member_id);

-- The following cursor is opened for the case of task level planning and
-- categorized resource list to fetch resource level records

CURSOR resources_for_task_level_cur(
         c_from_version_id  IN   pa_budget_versions.budget_version_id%TYPE) IS
SELECT  pra.task_id      task_id
       ,pt.top_task_id   top_task_id
       ,pra.resource_list_member_id  resource_list_member_id
       ,NULL    top_task_planning_level
       ,NULL    resource_planning_level
       ,'Y'     plannable_flag
       ,NULL    resources_planned_for_task
       ,'Y'     plan_amount_exists_flag
       ,DECODE(prlm.parent_member_id, NULL, 'G','R')     resource_level   -- Bug :- 2625872
FROM   pa_resource_assignments pra
       ,pa_tasks  pt
       ,pa_resource_list_members prlm
WHERE  budget_version_id = c_from_version_id
AND    pt.task_id = pra.task_id
AND    NVL(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_USER_ENTERED) =
                       PA_FP_CONSTANTS_PKG.G_USER_ENTERED
AND    prlm.resource_list_member_id = pra.resource_list_member_id
AND    NOT EXISTS(select 'x' from pa_fp_elements e
                  where  e.proj_fp_options_id = p_proj_fp_options_id
                  and    e.element_Type       = p_element_Type
                  and    e.task_id            = pra.task_id
                  and    e.resource_list_member_id = pra.resource_list_member_id)
ORDER BY pra.task_id ;

-- The following cursor is opened for the case of task level planning
-- to fetch task level records irrespective of resource list categorized or not

/* Bug #2933875: In the below cursor for Top_Task_Planning_Level, added the check for
   Planning level as Top and Lowest (G_BUDGET_ENTRY_LEVEL_M). If the Planning level is
   Top and Lowest and the Task is also the Top task then the top_task_planning_level
   should be 'LOWEST' and not 'TOP' as it was getting defaulted earlier. */

/* Bug 3019572 : The fix done for bug 2933875 is incomplete. If budget planning level is
   'Top and Lowest' , top task planning level for a top task should be derived as follows:

        if task has chidren
                Populate as 'Planned at Top Task'
        else
                Populate as 'Planned at Lowest Task'
        end if;

   Note: Please note that top task planning level column needs to be populated for
         top task records only.
 */

CURSOR task_level_elements_cur(
       c_from_version_id       IN   pa_budget_versions.budget_version_id%TYPE) IS
SELECT DISTINCT pra.task_id          task_id
               ,pt.top_task_id       top_task_id
               ,0                    resource_list_member_id
/* Bug 3019572
               ,DECODE(fp_options_rec.fin_plan_level_code,
                       PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST, PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST,
                       PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_M, DECODE(pra.task_id, pt.top_task_id, PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST),
                       DECODE(pra.task_id,pt.top_task_id,PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP,
                              PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST))    top_task_planning_level
*/
               ,DECODE(pra.task_id,
                       pt.top_task_id,
                           DECODE(fp_options_rec.fin_plan_level_code,
                                  PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST,
                                        PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST,
                                  PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP,
                                        PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP,
                                  PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_M,
                                        DECODE(pa_task_utils.check_child_exists(pra.task_id),
                                               1,  PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP,
                                               PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST)
                                  ),
                       null
                       ) top_task_planning_level
               ,get_resource_planning_level( prlm.parent_member_id
                                            ,l_uncategorized_flag
                                            ,l_grouped_flag )           resource_planning_level
               ,'Y'     plannable_flag
               ,DECODE(l_uncategorized_flag,'Y',NULL,'Y')     resources_planned_for_task
               ,'Y'     plan_amount_exists_flag
FROM   pa_resource_assignments pra
       ,pa_tasks  pt
       ,pa_resource_list_members prlm
WHERE  budget_version_id = c_from_version_id
AND    pt.task_id = pra.task_id
AND    prlm.resource_list_member_id = pra.resource_list_member_id
AND    NVL(resource_assignment_type,PA_FP_CONSTANTS_PKG.G_USER_ENTERED) = PA_FP_CONSTANTS_PKG.G_USER_ENTERED
AND    NOT EXISTS(select 'x' from pa_fp_elements e
                  where  e.proj_fp_options_id = p_proj_fp_options_id
                  and    e.element_Type       = p_element_Type
                  and    e.task_id            = pra.task_id
                  and    e.resource_list_member_id = 0);


-- The following cursor is opened for the case of task level planning
-- to insert top task level records for the task level records inserted using  the above cursor
-- irrespective of resource list categorized or not

CURSOR top_task_level_elements_cur(
       c_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE ) IS
SELECT DISTINCT pt.top_task_id      task_id
               ,pt.top_task_id      top_task_id
               ,0                   resource_list_member_id
               ,PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST top_task_planning_level
               ,NULL      resource_planning_level
               ,'N'       plannable_flag
               ,NULL      resources_planned_for_task
               ,'Y'       plan_amount_exists_flag
FROM   pa_fp_elements pfe
       ,pa_tasks      pt
WHERE  pfe.proj_fp_options_id = c_proj_fp_options_id
AND    pfe.element_type =  p_element_type
AND    pt.task_id = pfe.task_id
AND    pt.top_task_id <> pfe.task_id
AND     NOT EXISTS (SELECT 'x'          -- not exists clause added for bug#2803724
                     FROM pa_fp_elements e
                    WHERE e.proj_fp_options_id = p_proj_fp_options_id
                      AND e.element_Type       = p_element_Type
                      AND e.task_id            = pt.top_task_id
                      AND e.resource_list_member_id = 0 );

-- The following procedure calls insert bulk rows api

PROCEDURE Call_Insert_Bulk_Rows_Elements IS
BEGIN
     PA_FP_ELEMENTS_PUB.Insert_Bulk_Rows (
                 p_proj_fp_options_id         =>   p_proj_fp_options_id
                ,p_project_id                 =>   fp_options_rec.project_id
                ,p_fin_plan_type_id           =>   fp_options_rec.fin_plan_type_id
                ,p_element_type               =>   p_element_type
                ,p_plan_version_id            =>   fp_options_rec.fin_plan_version_id
                ,p_task_id_tbl                =>   l_task_id_tbl
                ,p_top_task_id_tbl            =>   l_top_task_id_tbl
                ,p_res_list_mem_id_tbl        =>   l_res_list_member_id_tbl
                ,p_task_planning_level_tbl    =>   l_top_task_planning_level_tbl
                ,p_res_planning_level_tbl     =>   l_res_planning_level_tbl
                ,p_plannable_flag_tbl         =>   l_plannable_flag_tbl
                ,p_res_planned_for_task_tbl   =>   l_res_planned_for_task_tbl
                ,p_planamount_exists_tbl      =>   l_plan_amount_exists_flag_tbl
                ,p_res_uncategorized_flag     =>   NULL
                ,x_return_status              =>   l_return_status
                ,x_msg_count                  =>   l_msg_count
                ,x_msg_data                   =>   l_msg_data);

END Call_Insert_Bulk_Rows_Elements;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      pa_debug.set_err_stack('Create_elements_from_version');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      pa_debug.set_process('PLSQL','LOG',l_debug_mode);

      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Entered Create_elements_from_version';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      -- Check for not null parameters

      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.g_err_stage := 'Checking for valid parameters:';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      IF (p_proj_fp_options_id  IS   NULL)  OR
         (p_element_type        IS   NULL)  OR
         (p_from_version_id     IS   NULL)  OR
         (p_resource_list_id    IS   NULL)
      THEN
           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'p_proj_fp_options_id = '||p_proj_fp_options_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'p_element_type = '||p_element_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'p_from_version_id = '||p_from_version_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                pa_debug.g_err_stage := 'p_resource_list_id = '||p_resource_list_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
           END IF;
           PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                                p_msg_name      => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Parameter validation complete';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage := 'p_proj_fp_options_id = '||p_proj_fp_options_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage := 'p_from_version_id = '||p_from_version_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           pa_debug.g_err_stage := 'p_resource_list_id = '||p_resource_list_id;
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;

      --Get the required fp options info using p_proj_fp_options_id

      OPEN fp_options_cur(p_proj_fp_options_id,p_element_type);
      FETCH fp_options_cur INTO fp_options_rec;
      CLOSE fp_options_cur;

      --get resourcelist info regarding the categorization and grouping of resourcelist

      pa_fin_plan_utils.get_resource_list_info(
            p_resource_list_id              =>    p_resource_list_id
           ,x_res_list_is_uncategorized     =>    l_uncategorized_flag
           ,x_is_resource_list_grouped      =>    l_grouped_flag
           ,x_group_resource_type_id        =>    l_group_resource_type_id
           ,x_return_status                 =>    l_return_status
           ,x_msg_count                     =>    l_msg_count
           ,x_msg_data                      =>    l_msg_data);

      -- Initialising the varaibles used to check mixed resource planning level to NULL

      l_prev_res_level := NULL;
      l_prev_task_id   := NULL;

      -- Setting the OUT varible to 'N' initially

      x_mixed_resource_planned_flag := 'N';

      IF (fp_options_rec.fin_plan_level_code  = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT) THEN

           IF  l_uncategorized_flag = 'N' THEN

              -- Case:-  project level planning and categorised resource list

              --Fetch and insert resource level records into pa_fp_elements.

              IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Opening resources_for_proj_level_cur';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              END IF;

              OPEN resources_for_proj_level_cur(p_from_version_id);
              LOOP
                   FETCH resources_for_proj_level_cur BULK COLLECT INTO
                         l_task_id_tbl
                         ,l_top_task_id_tbl
                         ,l_res_list_member_id_tbl
                         ,l_top_task_planning_level_tbl
                         ,l_res_planning_level_tbl
                         ,l_plannable_flag_tbl
                         ,l_res_planned_for_task_tbl
                         ,l_plan_amount_exists_flag_tbl
                         ,l_resource_level_tbl           -- Bug :- 2625872
                   LIMIT l_plsql_max_array_size;

                   -- Check if mixed planning level exists for the fetched records
                   IF NVL(l_resource_level_tbl.last,0) >= 1 THEN

                        FOR i IN  l_resource_level_tbl.first .. l_resource_level_tbl.last
                        LOOP

                                IF (l_prev_res_level  IS NULL)  THEN

                                   -- we are at the first record, and so initialise
                                   -- l_prev_res_level with the current record

                                   l_prev_res_level := l_resource_level_tbl(i);

                                ELSIF l_prev_res_level <> l_resource_level_tbl(i) THEN

                                   -- for the current record, the resource planning level
                                   -- has changed from previous record and so return error
                                   RAISE Mixed_Res_Plan_Level_Exc;
                                END IF;
                        END LOOP;
                   END IF;
                   -- If there are no mixed resoruce planning level records insert elements

                   IF NVL(l_task_id_tbl.last,0) >= 1 THEN
                         pa_debug.g_err_stage := 'Calling call_insert_bulk_rows_elements';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
                         Call_Insert_Bulk_Rows_Elements;
                   END IF;

                   EXIT WHEN NVL(l_task_id_tbl.last,0) < l_plsql_max_array_size;
              END LOOP;
              CLOSE resources_for_proj_level_cur;

              IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Closed resources_for_proj_level_cur';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
              END IF;

           END IF;

      ELSE   --task level planning

           IF l_uncategorized_flag = 'N' THEN

                --CASE :- task level planning and categorised resource list
                --Fetch and insert resource level records into pa_fp_elements.

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Opening resources_for_task_level_cur';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;

                OPEN resources_for_task_level_cur(p_from_version_id);
                LOOP
                     FETCH resources_for_task_level_cur BULK COLLECT INTO
                           l_task_id_tbl
                           ,l_top_task_id_tbl
                           ,l_res_list_member_id_tbl
                           ,l_top_task_planning_level_tbl
                           ,l_res_planning_level_tbl
                           ,l_plannable_flag_tbl
                           ,l_res_planned_for_task_tbl
                           ,l_plan_amount_exists_flag_tbl
                           ,l_resource_level_tbl           -- Bug :- 2625872
                     LIMIT l_plsql_max_array_size;

                     -- Check if mixed planning level exists for the fetched records
                     IF NVL(l_task_id_tbl.last,0) >= 1 THEN

                          FOR i IN  l_resource_level_tbl.first..l_resource_level_tbl.last
                          LOOP
                               IF  l_prev_res_level IS NULL OR
                                   l_prev_task_id   IS NULL OR
                                   l_prev_task_id <> l_task_id_tbl(i)
                               THEN

                                    IF p_pa_debug_mode = 'Y' THEN
                                         pa_debug.g_err_stage := 'previous task = '||l_prev_task_id;
                                         pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                                    END IF;

                                    -- we are at the first record fetched or the task has changed
                                    -- So initialise l_prev_res_level, l_prev_task_id with the
                                    -- current record

                                    l_prev_res_level := l_resource_level_tbl(i);
                                    l_prev_task_id   := l_task_id_tbl(i);

                               ELSIF l_prev_res_level <> l_resource_level_tbl(i) THEN

                                    -- the task is same but resource planning level is different
                                    -- so raise mixed resource planning exception
                                    RAISE Mixed_Res_Plan_Level_Exc;
                               END IF;
                          END LOOP;

                     END IF;

                     -- If there are no mixed resoruce planning level records insert elements

                     IF NVL(l_task_id_tbl.last,0) >= 1 THEN
                          Call_Insert_Bulk_Rows_Elements;
                     END IF;
                     EXIT WHEN NVL(l_task_id_tbl.last,0) < l_plsql_max_array_size;
                END LOOP;
                CLOSE resources_for_task_level_cur;

                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage := 'Closed resources_for_task_level_cur';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                END IF;
           END IF;

           --Fetch and insert task level records into pa_fp_elements

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Opening task_level_elements_cur';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;

           OPEN task_level_elements_cur(p_from_version_id);
           LOOP
                FETCH task_level_elements_cur BULK COLLECT INTO
                      l_task_id_tbl
                      ,l_top_task_id_tbl
                      ,l_res_list_member_id_tbl
                      ,l_top_task_planning_level_tbl
                      ,l_res_planning_level_tbl
                      ,l_plannable_flag_tbl
                      ,l_res_planned_for_task_tbl
                      ,l_plan_amount_exists_flag_tbl
                LIMIT l_plsql_max_array_size;

                IF NVL(l_task_id_tbl.last,0) >= 1 THEN
                      Call_Insert_Bulk_Rows_Elements;
                END IF;

                EXIT WHEN NVL(l_task_id_tbl.last,0) < l_plsql_max_array_size;
           END LOOP;
           CLOSE task_level_elements_cur;

           --Fetch and insert top task level records if they aren't already inserted.

           IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage := 'Closed task_level_elements_cur';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
                pa_debug.g_err_stage := 'Opening top_task_level_elements_cur';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;

           OPEN top_task_level_elements_cur(p_proj_fp_options_id);
           LOOP
                FETCH top_task_level_elements_cur BULK COLLECT INTO
                      l_task_id_tbl
                      ,l_top_task_id_tbl
                      ,l_res_list_member_id_tbl
                      ,l_top_task_planning_level_tbl
                      ,l_res_planning_level_tbl
                      ,l_plannable_flag_tbl
                      ,l_res_planned_for_task_tbl
                      ,l_plan_amount_exists_flag_tbl
                LIMIT l_plsql_max_array_size;

                IF NVL(l_task_id_tbl.last,0) >= 1 THEN
                    Call_Insert_Bulk_Rows_Elements;
                END IF;

                EXIT WHEN NVL(l_task_id_tbl.last,0) < l_plsql_max_array_size;
           END LOOP;
           CLOSE top_task_level_elements_cur;

           IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Closed top_task_level_elements_cur';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
           END IF;
      END IF;
      IF p_pa_debug_mode = 'Y' THEN
           pa_debug.g_err_stage := 'Exiting Create_elements_from_version';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
      END IF;
      pa_debug.reset_err_stack;
EXCEPTION

   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
        END IF;
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RAISE;

   WHEN Mixed_Res_Plan_Level_Exc THEN

        IF resources_for_proj_level_cur%ISOPEN THEN
           CLOSE resources_for_proj_level_cur;
        END IF;
        IF resources_for_task_level_cur%ISOPEN THEN
           CLOSE resources_for_task_level_cur;
        END IF;

        x_mixed_resource_planned_flag := 'Y';
        x_return_status:= FND_API.G_RET_STS_ERROR;
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Budget_Version '||p_from_version_id ||' has mixed planning level';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.reset_err_stack;
        RETURN;

   WHEN Others THEN

        IF resources_for_proj_level_cur%ISOPEN THEN
           CLOSE resources_for_proj_level_cur;
        END IF;
        IF resources_for_task_level_cur%ISOPEN THEN
           CLOSE resources_for_task_level_cur;
        END IF;
        IF task_level_elements_cur%ISOPEN THEN
           CLOSE task_level_elements_cur;
        END IF;
        IF top_task_level_elements_cur%ISOPEN THEN
           CLOSE top_task_level_elements_cur;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_FP_UPGRADE_PKG'
                        ,p_procedure_name  => 'Create_elements_from_version');
        IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,5);
        END IF;
        pa_debug.reset_err_stack;
        RAISE;
END Create_elements_from_version;

/*==================================================================================================
  refresh_res_list_changes: This procedure is used to delete resource elements from PA_FP_ELEMENTS
  table for a particular Proj FP Options ID depending on the Element Type when the resource list is
  changed in the plan settings page. After deleting the resource records, it sets the
  resource planning level for the task records to 'R' if the resource list is categorized or to NULL
  if it is not categorized
  Bug 2920954 :- This api has been modifed to insert resource elements for the already selected task
  or project elements based on the input resource list id and the automatic resource selection
  parameter and resource planning level for automatic resource selection
==================================================================================================*/
PROCEDURE refresh_res_list_changes (
           p_proj_fp_options_id              IN    PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE
          ,p_element_type                    IN    PA_FP_ELEMENTS.ELEMENT_TYPE%TYPE  /* COST,REVENUE,ALL,BOTH */
          ,p_cost_resource_list_id           IN    PA_PROJ_FP_OPTIONS.COST_RESOURCE_LIST_ID%TYPE
          ,p_rev_resource_list_id            IN    PA_PROJ_FP_OPTIONS.REVENUE_RESOURCE_LIST_ID%TYPE
          ,p_all_resource_list_id            IN    PA_PROJ_FP_OPTIONS.ALL_RESOURCE_LIST_ID%TYPE
          /* Bug 2920954 start of new parameters added for post fp-K one off patch */
          ,p_select_cost_res_auto_flag       IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_cost_res_planning_level         IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          ,p_select_rev_res_auto_flag        IN   pa_proj_fp_options.select_rev_res_auto_flag%TYPE
          ,p_revenue_res_planning_level      IN   pa_proj_fp_options.revenue_res_planning_level%TYPE
          ,p_select_all_res_auto_flag        IN   pa_proj_fp_options.select_all_res_auto_flag%TYPE
          ,p_all_res_planning_level          IN   pa_proj_fp_options.all_res_planning_level%TYPE
          /* Bug 2920954 end of new parameters added for post fp-K one off patch */
          ,x_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT   NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

l_msg_count                    NUMBER := 0;
l_data                         VARCHAR2(2000);
l_msg_data                     VARCHAR2(2000);
l_msg_index_out                NUMBER;
l_return_status                VARCHAR2(2000);
l_debug_mode                   VARCHAR2(30);
l_res_list_is_uncategorized    PA_RESOURCE_LISTS_ALL_BG.UNCATEGORIZED_FLAG%TYPE;
l_is_resource_list_grouped     VARCHAR2(1);
l_group_resource_type_id       PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%TYPE;
l_resource_list_id             PA_PROJ_FP_OPTIONS.ALL_RESOURCE_LIST_ID%TYPE;
l_res_planning_level           PA_FP_ELEMENTS.RESOURCE_PLANNING_LEVEL%TYPE;
l_fin_plan_level_code          PA_PROJ_FP_OPTIONS.COST_FIN_PLAN_LEVEL_CODE%TYPE;
l_stage                        NUMBER := 100;

l_dummy_task_id_tbl            pa_fp_elements_pub.l_task_id_tbl_typ;

BEGIN

    pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.refresh_res_list_changes');
    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'Y');
    IF P_PA_DEBUG_MODE = 'Y' THEN
       pa_debug.set_process('refresh_res_list_changes: ' || 'PLSQL','LOG',l_debug_mode);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_proj_fp_options_id IS NULL) or (p_element_type IS NULL) THEN

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Proj FP Options ID is .'
                           || p_proj_fp_options_id ||': Err- Element Type is .' || p_element_type;
         pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;

      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
      x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE

      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.g_err_stage := TO_CHAR(l_Stage)||'Input parameters are valid ';
         pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
      END IF;

   END IF;


   IF FND_MSG_PUB.count_msg > 0 THEN
      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
   END IF;



   /* Delete the records from the table PA_FP_Elements based on the Element_Type and
      for Element level RESOURCE. */

   pa_debug.g_err_stage := 'Deleting Elements from PA_FP_Elements';
   IF P_PA_DEBUG_MODE = 'Y' THEN
      pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
   END IF;

   delete_elements(p_proj_fp_options_id => p_proj_fp_options_id
                       ,p_element_type      => p_element_type
                       ,p_element_level     => PA_FP_CONSTANTS_PKG.G_ELEMENT_LEVEL_RESOURCE
                       ,x_return_status     => x_return_status
                       ,x_msg_count         => x_msg_count
                       ,x_msg_data          => x_msg_data);

   /* Depending upon the element type, if the resource list chosen is categorized
    then update the resource planning level for the task records to 'R'. If the
    resource list is not categorized make the resource planning level NULL */

   IF (p_element_type =PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST  OR
       p_element_type =PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH) THEN


       IF (p_cost_resource_list_id IS NULL) THEN
          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Cost Resource List Id is NULL.';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_debug.g_err_stage := 'Element Type is Cost ';
            pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF p_select_cost_res_auto_flag = 'Y'
       THEN   /* Bug 2920954 */
            /* p_cost_res_planning_level should be either 'R'/'G' */

            IF p_cost_res_planning_level NOT IN ('R','G')
            THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Cost Auto Res Plan Level is Invalid';
                      pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
                 END IF;

                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_fin_plan_level_code := PA_FIN_PLAN_UTILS.Get_option_planning_level(
                                       P_PROJ_FP_OPTIONS_ID => p_proj_fp_options_id,
                                       P_ELEMENT_TYPE       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST);

            /* If automatic resource addition is enabled, call add_resources_automatically api for entire option */

             PA_FP_ELEMENTS_PUB.Add_resources_automatically
                     ( p_proj_fp_options_id    => p_proj_fp_options_id
                      ,p_element_type          => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                      ,p_fin_plan_level_code   => l_fin_plan_level_code
                      ,p_resource_list_id      => p_cost_resource_list_id
                      ,p_res_planning_level    => p_cost_res_planning_level
                      ,p_entire_option         => 'Y'
                      ,p_element_task_id_tbl   => l_dummy_task_id_tbl
                      ,x_return_status         => x_return_status
                      ,x_msg_count             => x_msg_count
                      ,x_msg_data              => x_msg_data
                      );

       ELSE  /* Bug 2920954 */
            PA_FIN_PLAN_UTILS.GET_RESOURCE_LIST_INFO(
                         P_RESOURCE_LIST_ID          => p_cost_resource_list_id,
                         X_RES_LIST_IS_UNCATEGORIZED => l_res_list_is_uncategorized,
                         X_IS_RESOURCE_LIST_GROUPED  => l_is_resource_list_grouped,
                         X_GROUP_RESOURCE_TYPE_ID    => l_group_resource_type_id,
                         X_RETURN_STATUS             => x_return_status,
                         X_MSG_COUNT                 => x_msg_count,
                         X_MSG_DATA                  => x_msg_data
                         );
            IF l_res_list_is_uncategorized = 'N' THEN
                l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;
            ELSE
                l_res_planning_level := NULL;
            END IF;


            pa_debug.g_err_stage := 'Resource Planning Level is '||l_res_planning_level;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            /*Added the condition resources_planned_for_task = 'N' for bug 2676456 so that
              the resource plannned for task column in planning elements page shows correct value
            */

            UPDATE  pa_fp_elements
            SET     resource_planning_level = l_res_planning_level
                   ,resources_planned_for_task = 'N'
                   ,record_version_number = record_version_number + 1
                   ,last_update_date = sysdate
                   ,last_updated_by = FND_GLOBAL.USER_ID
                   ,last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE   proj_fp_options_id = p_proj_fp_options_id
            AND     element_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST;
       END IF;  /* Bug 2920954 */
   END IF;

   IF (p_element_type =PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE OR
       p_element_type =PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH)  THEN

       IF (p_rev_resource_list_id IS NULL) THEN
          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Revenue Resource List Id is NULL.';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       pa_debug.g_err_stage := 'Element Type is REVENUE ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF p_select_rev_res_auto_flag = 'Y'
       THEN   /* Bug 2920954 */
            /* p_revenue_res_planning_level should be either 'R'/'G' */

            IF p_revenue_res_planning_level NOT IN ('R','G')
            THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- Revenue Auto Res Plan Level is Invalid';
                      pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
                 END IF;

                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_fin_plan_level_code := PA_FIN_PLAN_UTILS.Get_option_planning_level(
                                       P_PROJ_FP_OPTIONS_ID => p_proj_fp_options_id,
                                       P_ELEMENT_TYPE       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE);

            /* If automatic resource addition is enabled, call add_resources_automatically api for entire option */

             PA_FP_ELEMENTS_PUB.Add_resources_automatically
                     ( p_proj_fp_options_id    => p_proj_fp_options_id
                      ,p_element_type          => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                      ,p_fin_plan_level_code   => l_fin_plan_level_code
                      ,p_resource_list_id      => p_rev_resource_list_id
                      ,p_res_planning_level    => p_revenue_res_planning_level
                      ,p_entire_option         => 'Y'
                      ,p_element_task_id_tbl   => l_dummy_task_id_tbl
                      ,x_return_status         => x_return_status
                      ,x_msg_count             => x_msg_count
                      ,x_msg_data              => x_msg_data
                      );
       ELSE  /* Bug 2920954 */
            PA_FIN_PLAN_UTILS.GET_RESOURCE_LIST_INFO(
                         P_RESOURCE_LIST_ID          => p_rev_resource_list_id,
                         X_RES_LIST_IS_UNCATEGORIZED => l_res_list_is_uncategorized,
                         X_IS_RESOURCE_LIST_GROUPED  => l_is_resource_list_grouped,
                         X_GROUP_RESOURCE_TYPE_ID    => l_group_resource_type_id,
                         X_RETURN_STATUS             => x_return_status,
                         X_MSG_COUNT                 => x_msg_count,
                         X_MSG_DATA              => x_msg_data
                         );
            IF l_res_list_is_uncategorized = 'N' THEN
                l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;
            ELSE
             l_res_planning_level := NULL;
            END IF;

            pa_debug.g_err_stage := 'Resource Planning Level is '||l_res_planning_level;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            UPDATE  pa_fp_elements
            SET     resource_planning_level = l_res_planning_level
                   ,resources_planned_for_task = 'N'        --for bug 2676456
                   ,record_version_number = record_version_number + 1
                   ,last_update_date = sysdate
                   ,last_updated_by = FND_GLOBAL.USER_ID
                   ,last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE   proj_fp_options_id = p_proj_fp_options_id
            AND     element_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE;
       END IF;  /* Bug 2920954 */

   END IF;

   IF (p_element_type =PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL )  THEN

       IF (p_all_resource_list_id IS NULL) THEN
          pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- All Resource List Id is NULL.';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
          PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

       pa_debug.g_err_stage := 'Element Type is ALL ';
       IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
       END IF;

       IF p_select_all_res_auto_flag = 'Y'
       THEN   /* Bug 2920954 */
            /* p_all_res_planning_level should be either 'R'/'G' */

            IF p_all_res_planning_level NOT IN ('R','G')
            THEN
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := TO_CHAR(l_Stage)||': Err- All Auto Res Plan Level is Invalid';
                      pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,5);
                 END IF;

                 PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                                      p_msg_name            => 'PA_FP_INV_PARAM_PASSED' );
                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

            l_fin_plan_level_code := PA_FIN_PLAN_UTILS.Get_option_planning_level(
                                       P_PROJ_FP_OPTIONS_ID => p_proj_fp_options_id,
                                       P_ELEMENT_TYPE       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL);

            /* If automatic resource addition is enabled, call add_resources_automatically api for entire option */

             PA_FP_ELEMENTS_PUB.Add_resources_automatically
                     ( p_proj_fp_options_id    => p_proj_fp_options_id
                      ,p_element_type          => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
                      ,p_fin_plan_level_code   => l_fin_plan_level_code
                      ,p_resource_list_id      => p_all_resource_list_id
                      ,p_res_planning_level    => p_all_res_planning_level
                      ,p_entire_option         => 'Y'
                      ,p_element_task_id_tbl   => l_dummy_task_id_tbl
                      ,x_return_status         => x_return_status
                      ,x_msg_count             => x_msg_count
                      ,x_msg_data              => x_msg_data
                      );
       ELSE  /* Bug 2920954 */
            PA_FIN_PLAN_UTILS.GET_RESOURCE_LIST_INFO(
                         P_RESOURCE_LIST_ID          => p_all_resource_list_id,
                         X_RES_LIST_IS_UNCATEGORIZED => l_res_list_is_uncategorized,
                         X_IS_RESOURCE_LIST_GROUPED  => l_is_resource_list_grouped,
                         X_GROUP_RESOURCE_TYPE_ID    => l_group_resource_type_id,
                         X_RETURN_STATUS             => x_return_status,
                         X_MSG_COUNT                 => x_msg_count,
                         X_MSG_DATA              => x_msg_data
                         );
            IF l_res_list_is_uncategorized = 'N' THEN
                l_res_planning_level := PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R;
            ELSE
                l_res_planning_level := NULL;
            END IF;

            pa_debug.g_err_stage := 'Resource Planning Level is '||l_res_planning_level;
            IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            UPDATE  pa_fp_elements
            SET     resource_planning_level = l_res_planning_level
                   ,resources_planned_for_task = 'N'        --for bug 2676456
                   ,record_version_number = record_version_number + 1
                   ,last_update_date = sysdate
                   ,last_updated_by = FND_GLOBAL.USER_ID
                   ,last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE   proj_fp_options_id = p_proj_fp_options_id
            AND     element_type = p_element_type;
       END IF;   /* Bug 2920954 */

   END IF;
   pa_debug.reset_err_stack;

EXCEPTION
  WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
      ELSE
             x_msg_count := l_msg_count;
      END IF;
      pa_debug.reset_err_stack;
    RETURN;

  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;
        FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_ELEMENTS_PUB.refresh_res_list_changes'
            ,p_procedure_name => pa_debug.G_Err_Stack );
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('refresh_res_list_changes: ' || l_module_name,SQLERRM,4);
           pa_debug.write('refresh_res_list_changes: ' || l_module_name,pa_debug.G_Err_Stack,4);
        END IF;
        pa_debug.reset_err_stack;

        raise FND_API.G_EXC_UNEXPECTED_ERROR;
END refresh_res_list_changes;

/*
     This API creates resource assignments and elements for a budget version.
The API expects that the necessary data(only) to create the above two are available in
pa_fp_rollup_tmp table(task_id in system_reference1 and resource_list_member_id in
system_reference2). The resource assignment id contains -1 if the RA id doesnot exist.
*/
PROCEDURE CREATE_ASSGMT_FROM_ROLLUPTMP
    ( p_fin_plan_version_id   IN      pa_budget_versions.budget_version_id%TYPE
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(1);
l_debug_mode                    VARCHAR2(30);


/* Bug 2677597 - introduced the following types and commented out the rest */
l_task_id_tbl                  l_task_id_tbl_typ;
l_res_list_mem_id_tbl          l_res_list_mem_id_tbl_typ     ;
l_unit_of_measure_tbl          l_unit_of_measure_tbl_typ     ;
l_track_as_labor_flag_tbl      l_track_as_labor_flag_tbl_typ ;

--l_task_id_tbl                  pa_fp_rollup_pkg.l_task_id_tbl_typ;
--l_res_list_mem_id_tbl          pa_fp_rollup_pkg.l_res_list_mem_id_tbl_typ;
--l_unit_of_measure_tbl          pa_fp_rollup_pkg.l_unit_of_measure_tbl_typ;
--l_track_as_labor_flag_tbl      pa_fp_rollup_pkg.l_track_as_labor_flag_tbl_typ;
--l_proj_raw_cost_tbl            pa_fp_rollup_pkg.l_proj_raw_cost_tbl_typ;
--l_proj_burdened_cost_tbl       pa_fp_rollup_pkg.l_proj_burd_cost_tbl_typ;
--l_proj_revenue_tbl             pa_fp_rollup_pkg.l_proj_revenue_tbl_typ;
--l_projfunc_raw_cost_tbl        pa_fp_rollup_pkg.l_projfunc_raw_cost_tbl_typ;
--l_projfunc_burd_cost_tbl       pa_fp_rollup_pkg.l_projfunc_burd_cost_tbl_typ;
--l_projfunc_revenue_tbl         pa_fp_rollup_pkg.l_projfunc_revenue_tbl_typ;
--l_quantity_tbl                 pa_fp_rollup_pkg.l_quantity_tbl_typ;
/* Bug 2677597 - declaration change end */

l_project_id                   pa_projects_all.project_id%TYPE;
l_fp_options_id                pa_proj_fp_options.proj_fp_options_id%TYPE;
l_element_type                 pa_fp_elements.element_type%TYPE;
l_resource_list_id             pa_budget_versions.resource_list_id%TYPE;
l_mixed_resource_planned_flag  VARCHAR2(1);  -- Added for Bug:- 2625872

--Bug # 3507156 : Patchset M: B and F impact changes : AMG
--Added some variables.
l_context                      VARCHAR2(30);
l_task_elem_version_id_tbl     SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_resource_list_member_id_tbl  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_rlm_id_tbl_tmp               SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
/*Bug # 3622551 --Added some parameters */

l_parent_structure_version_id  pa_proj_element_versions.parent_structure_version_id%TYPE ;
l_task_id_tmp_tbl              SYSTEM.pa_num_tbl_type         := SYSTEM.PA_NUM_TBL_TYPE();


/*Bug # 3622551 -- Added a join to the cursor to get the value of wbs_element_version_id*/
CURSOR res_assign_cur(c_version_id NUMBER
                     ,c_parent_structure_version_id pa_proj_element_versions.parent_structure_version_id%TYPE) IS
select distinct  system_reference1 task_id
                ,system_reference2 resource_list_member_id
                ,system_reference4 unit_of_measure
                ,system_reference5 track_as_labor_flag
                ,decode(rollup.system_reference1,0,0,pelm.element_version_id) wbs_element_version_id
     /* included null columns after UT */
     --        ,null              proj_raw_cost           /* Bug 2677597 */
     --        ,null             proj_burdened_cost
     --        ,null              proj_revenue
     --        ,null             projfunc_raw_cost
     --        ,null              projfunc_burd_cost
     --        ,null             projfunc_revenue
     --        ,null             quantity
from pa_fp_rollup_tmp rollup
    ,pa_proj_element_versions pelm
where not exists
(
     select pra.resource_assignment_id
     from  pa_resource_assignments pra
     where pra.task_id=rollup.system_reference1
     and   pra.resource_list_member_id = rollup.system_reference2
     and   pra.budget_version_id = c_version_id
)
and   decode(rollup.system_reference1,0,c_parent_structure_version_id,rollup.system_reference1)
    = decode(rollup.system_reference1,0,pelm.element_version_id,pelm.proj_element_id) -- Bug 3655290
and   pelm.parent_structure_version_id = c_parent_structure_version_id
order by task_id,resource_list_member_id;

 --Bug # 3507156 : Patchset M: B and F impact changes : AMG
 --Added a curosr to get the value of plan_class_code

 CURSOR get_context_csr IS
 SELECT pfp.plan_class_code FROM pa_fin_plan_types_b pfp,pa_budget_versions pbv
 WHERE pfp.FIN_PLAN_TYPE_ID = pbv.FIN_PLAN_TYPE_ID
 AND pbv.budget_version_id =p_fin_plan_version_id ;

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.CREATE_ASSGMT_FROM_ROLLUPTMP');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      pa_debug.g_err_stage:= 'Validating input parameters';
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Validate plan version id

      IF (p_fin_plan_version_id IS NULL)
      THEN

                   pa_debug.g_err_stage:= 'fin_plan_version_id = '|| p_fin_plan_version_id;
                   IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                   END IF;

                   PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                          p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

        pa_debug.g_err_stage:= 'Obtain the relevant parameters for the version';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

     BEGIN
          select  opt.project_id,
                  opt.proj_fp_options_id,
                  pbv.version_type,                  -- Version type and element type are used interchangeably.
                  pbv.resource_list_id
          into
                l_project_id
               ,l_fp_options_id
               ,l_element_type
               ,l_resource_list_id
          from pa_proj_fp_options opt,pa_budget_versions pbv
          where opt.fin_plan_version_id = pbv.budget_version_id
          and   pbv.budget_version_id   = p_fin_plan_version_id;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               pa_debug.g_err_stage:= 'Could not get the details of the plan version option';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                  END IF;
               RAISE;
     END;

        pa_debug.g_err_stage:= 'Create resource assignments - Bulk collect into the plsql tables';
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;

 /*Bug # 3622551 -- Get the value of l_parent_structure_version_id */
     l_parent_structure_version_id := pa_project_structure_utils.get_fin_struc_ver_id(l_project_id);

     OPEN res_assign_cur(p_fin_plan_version_id,l_parent_structure_version_id);
     LOOP

          FETCH res_assign_cur
          BULK COLLECT INTO l_task_id_tbl
                           ,l_resource_list_member_id_tbl
                           ,l_unit_of_measure_tbl
                           ,l_track_as_labor_flag_tbl
                           ,l_task_elem_version_id_tbl
     --                    ,l_proj_raw_cost_tbl              /* Bug 2677597 */
     --                    ,l_proj_burdened_cost_tbl
     --                    ,l_proj_revenue_tbl
     --                    ,l_projfunc_raw_cost_tbl
     --                    ,l_projfunc_burd_cost_tbl
     --                    ,l_projfunc_revenue_tbl
     --                    ,l_quantity_tbl
             LIMIT g_plsql_max_array_size;

          pa_debug.g_err_stage:= 'Create resource assignments - Call the API';
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          END IF;

          -- getting the context
          OPEN get_context_csr ;
          FETCH get_context_csr INTO l_context ;
          CLOSE get_context_csr ;

           IF(nvl(l_task_id_tbl.last,0) > 0) THEN
           /* Bug 4200168: calling add_planning_transactions with p_one_to_one_mapping as Y
            * and discarding the earlier logic to pass the cartesian product for task_id and rlm_id
            */
                pa_fp_planning_transaction_pub.add_planning_transactions
                 (
                  p_context                     =>       l_context
                 ,p_one_to_one_mapping_flag     =>       'Y' /*Bug 4200168*/
                 ,p_calling_module              =>       'CREATE_VERSION' -- Bug 3655290
                 ,p_project_id                  =>       l_project_id
                 ,p_budget_version_id           =>       p_fin_plan_version_id
                 ,p_task_elem_version_id_tbl    =>       l_task_elem_version_id_tbl
                 ,p_resource_list_member_id_tbl =>       l_resource_list_member_id_tbl
                 ,x_return_status               =>       x_return_status
                 ,x_msg_count                   =>       x_msg_count
                 ,x_msg_data                    =>       x_msg_data
                 );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                END IF;

          END IF;
     EXIT WHEN nvl(l_task_id_tbl.last,0) < g_plsql_max_array_size;
     END LOOP;

     --Update the roll up tmp table with the newly created resource assignment id.
     update pa_fp_rollup_tmp rollup
     set resource_assignment_id =
     (
          select resource_assignment_id
          from pa_resource_assignments ra
          where ra.budget_version_id = p_fin_plan_version_id
          and   ra.task_id = rollup.system_reference1
          and   ra.resource_list_member_id = rollup.system_reference2
          and   ra.resource_assignment_id IS NOT NULL
 );
     pa_debug.g_err_stage:= 'No of records updated in rollup tmp-> ' || sql%rowcount;
        IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
        END IF;


  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_ELEMENTS_PUB'
                                  ,p_procedure_name  => 'CREATE_ASSGMT_FROM_ROLLUPTMP');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('CREATE_ASSGMT_FROM_ROLLUPTMP: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;

END CREATE_ASSGMT_FROM_ROLLUPTMP;

/*==============================================================================
  This is a private api called from  Create_CI_Resource_Assignments api for
  insertion of a record into PA_RESOURCE_ASSIGNMENTS package.
 ===============================================================================*/

PROCEDURE Insert_Resource_Assignment(
          p_project_id                  IN      pa_resource_assignments.project_id%TYPE
         ,p_budget_version_id           IN      pa_resource_assignments.budget_version_id%TYPE
         ,p_task_id                     IN      pa_resource_assignments.task_id%TYPE
         ,p_resource_list_member_id     IN      pa_resource_assignments.resource_list_member_id%TYPE
         ,p_unit_of_measure             IN      pa_resource_assignments.unit_of_measure%TYPE
         ,p_track_as_labor_flag         IN      pa_resource_assignments.track_as_labor_flag%TYPE )
AS

l_row_id                     rowid;
l_return_status              VARCHAR2(30);
l_resource_assignment_id     pa_resource_assignments.resource_assignment_id%TYPE;

BEGIN

        PA_FP_RESOURCE_ASSIGNMENTS_PKG.Insert_Row
                ( px_resource_assignment_id       =>   l_resource_assignment_id
                 ,p_budget_version_id             =>   p_budget_version_id
                 ,p_project_id                    =>   p_project_id
                 ,p_task_id                       =>   p_task_id
                 ,p_resource_list_member_id       =>   p_resource_list_member_id
                 ,p_unit_of_measure               =>   p_unit_of_measure
                 ,p_track_as_labor_flag           =>   p_track_as_labor_flag
                 ,p_standard_bill_rate            =>   NULL
                 ,p_average_bill_rate             =>   NULL
                 ,p_average_cost_rate             =>   NULL
                 ,p_project_assignment_id         =>   -1
                 ,p_plan_error_code               =>   NULL
                 ,p_total_plan_revenue            =>   NULL
                 ,p_total_plan_raw_cost           =>   NULL
                 ,p_total_plan_burdened_cost      =>   NULL
                 ,p_total_plan_quantity           =>   NULL
                 ,p_average_discount_percentage   =>   NULL
                 ,p_total_borrowed_revenue        =>   NULL
                 ,p_total_tp_revenue_in           =>   NULL
                 ,p_total_tp_revenue_out          =>   NULL
                 ,p_total_revenue_adj             =>   NULL
                 ,p_total_lent_resource_cost      =>   NULL
                 ,p_total_tp_cost_in              =>   NULL
                 ,p_total_tp_cost_out             =>   NULL
                 ,p_total_cost_adj                =>   NULL
                 ,p_total_unassigned_time_cost    =>   NULL
                 ,p_total_utilization_percent     =>   NULL
                 ,p_total_utilization_hours       =>   NULL
                 ,p_total_utilization_adj         =>   NULL
                 ,p_total_capacity                =>   NULL
                 ,p_total_head_count              =>   NULL
                 ,p_total_head_count_adj          =>   NULL
                 ,p_resource_assignment_type      =>   PA_FP_CONSTANTS_PKG.G_USER_ENTERED
                 ,p_total_project_raw_cost        =>   NULL
                 ,p_total_project_burdened_cost   =>   NULL
                 ,p_total_project_revenue         =>   NULL
                 ,p_parent_assignment_id          =>   NULL
                 ,x_row_id                        =>   l_row_id
                 ,x_return_status                 =>   l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                pa_debug.g_err_stage:= 'Exception while inserting a row into pa_resource_assignments;';
                IF P_PA_DEBUG_MODE = 'Y' THEN
                   pa_debug.write('Insert_Resource_Assignment: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
END Insert_Resource_Assignment;

/*==============================================================================
  This api is called to create resource assignments during creation of CI budget
  version for a given impacted task id.
 ===============================================================================*/

--
--  01-JUL-2003 jwhite    - Bug 2989874
--                          For Create_CI_Resource_Assignment,
--                          default ci from the  current working version.

--  12-APR-2004 dbora       FP.M Changes
--  13-MAY-2004 rravipat    Bug  3615617
--                          Create_res_task_maps api specification has changed
--                          target resource list member id should be derived and
--                          passed to the api

PROCEDURE Create_CI_Resource_Assignments
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_budget_version_id       IN      pa_budget_versions.budget_version_id%TYPE
     ,p_version_type            IN      pa_budget_versions.version_type%TYPE
     ,p_impacted_task_id        IN      pa_resource_assignments.task_id%TYPE
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_error_msg_code                VARCHAR2(30);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);
l_debug_mode                    VARCHAR2(30);

l_err_code                      NUMBER;
l_err_stage                     VARCHAR2(100);
l_err_stack                     VARCHAR2(1000);

l_no_of_records_processed       NUMBER;
l_count                         NUMBER;

l_fin_plan_type_id              pa_proj_fp_options.fin_plan_type_id%TYPE;

-- Bug Fix: 4569365. Removed MRC code.
-- l_calling_context               pa_mrc_finplan.g_calling_module%TYPE;
l_calling_context               VARCHAR2(30);

l_ci_apprv_cw_bv_id             pa_budget_versions.budget_version_id%TYPE :=NULL;
l_plan_version_planning_level   pa_proj_fp_options.all_fin_plan_level_code%TYPE;

/* PL/SQL table types to be passed to create_res_task_map */

l_src_ra_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE;
l_src_elem_ver_id_tbl           SYSTEM.PA_NUM_TBL_TYPE;
l_targ_elem_ver_id_tbl          SYSTEM.PA_NUM_TBL_TYPE;
l_targ_proj_assmt_id_tbl        SYSTEM.PA_NUM_TBL_TYPE;
l_planning_start_date_tbl       SYSTEM.PA_DATE_TBL_TYPE;
l_planning_end_date_tbl         SYSTEM.PA_DATE_TBL_TYPE;
l_schedule_start_date_tbl       SYSTEM.PA_DATE_TBL_TYPE;
l_schedule_end_date_tbl         SYSTEM.PA_DATE_TBL_TYPE;
l_targ_rlm_id_tbl               SYSTEM.PA_NUM_TBL_TYPE; -- bug 3615617

/* The existing cursors were replaced by the following cursors to get the resource assignments
 * for the impacted task, or its childrens or its parent's childrens as the case may be
 */

CURSOR impacted_task_cur(c_impacted_task_id  pa_tasks.task_id%TYPE) IS
SELECT parent_task_id,
       top_task_id
FROM   pa_tasks
WHERE  task_id = c_impacted_task_id;

impacted_task_rec        impacted_task_cur%ROWTYPE;

CURSOR cur_elements_for_project IS
SELECT pra.resource_assignment_id,
       pra.wbs_element_version_id, -- This column is selected so that it can be passed, to create_res_task_maps. One for source and one for target.
       pra.wbs_element_version_id, -- This would be null for budgets and forecasts!
       pra.project_assignment_id,  -- This would be -1 for Budgets and Forecasts
       pra.planning_start_date,
       pra.planning_end_date,
       pra.schedule_start_date,
       pra.schedule_end_date,
       pra.resource_list_member_id -- Bug 3615617
FROM   pa_resource_assignments pra
WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id;

CURSOR cur_elements_for_task (c_task_id pa_tasks.task_id%TYPE) IS
SELECT pra.resource_assignment_id,
       pra.wbs_element_version_id, -- This column is selected so that it can be passed, to create_res_task_maps. One for source and one for target.
       pra.wbs_element_version_id, -- This would be null for budgets and forecasts!
       pra.project_assignment_id,  -- This would be -1 for Budgets and Forecasts
       pra.planning_start_date,
       pra.planning_end_date,
       pra.schedule_start_date,
       pra.schedule_end_date,
       pra.resource_list_member_id -- Bug 3615617
FROM   pa_resource_assignments pra
WHERE  pra.budget_version_id = l_ci_apprv_cw_bv_id
AND    pra.task_id IN (SELECT t.task_id
                       FROM   pa_tasks t
                       WHERE  t.project_id = p_project_id
                       CONNECT BY PRIOR t.task_id = t.parent_task_id
                       START WITH t.task_id = c_task_id);

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.set_err_stack('PA_FP_ELEMENTS_PUB.Create_CI_Resource_Assignments');
      fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
      l_debug_mode := NVL(l_debug_mode, 'Y');
      IF P_PA_DEBUG_MODE = 'Y' THEN
         pa_debug.set_process('Create_CI_Resource_Assignments: ' || 'PLSQL','LOG',l_debug_mode);
      END IF;

      -- Check for business rules violations

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      --Check if plan version id is null

      IF (p_project_id        IS NULL) OR
         (p_budget_version_id IS NULL) OR
         (p_impacted_task_id  IS NULL) OR
         (p_version_type      IS NULL)
      THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
               pa_debug.g_err_stage:= 'p_project_id = '||p_project_id;
               pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

               pa_debug.g_err_stage:= 'p_budget_version_id = '||p_budget_version_id;
               pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

               pa_debug.g_err_stage:= 'p_impacted_task_id = '||p_impacted_task_id;
               pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);

               pa_debug.g_err_stage:= 'p_version_type = '||p_version_type;
               pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;

           PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Fetch the plan type fp options id and resource list attached

      BEGIN
          SELECT bv.fin_plan_type_id
          INTO   l_fin_plan_type_id
          FROM   pa_budget_versions bv
          WHERE  budget_version_id = p_budget_version_id;
      EXCEPTION
         WHEN OTHERS THEN
                  pa_debug.g_err_stage:= 'Failed to fetch plan type and resource list for given budget version';
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                  END IF;
                  RAISE;
      END;

      l_plan_version_planning_level := Pa_Fin_Plan_Utils.Get_Fin_Plan_Level_Code(
                                         p_fin_plan_version_id  => p_budget_version_id);

      -- Fetch current working approved budget version id
      Pa_Fp_Control_Items_Utils.CHK_APRV_CUR_WORKING_BV_EXISTS(
                         p_project_id       => p_project_id,
                         p_fin_plan_type_id => l_fin_plan_type_id,
                         p_version_type     => p_version_type,
                         x_cur_work_bv_id   => l_ci_apprv_cw_bv_id,
                         x_return_status    => l_return_status,
                         x_msg_count        => l_msg_count,
                         x_msg_data         => l_msg_data );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      /* Bug# 2676352  - Creating plannable elements based on the impacted task is ONLY applicable
         if the plan type level planning level is Task level.

         If planning level is Project, only create the plannable resources, if using a resource list.
         Otherwise, just one resource assignment for entire project when not using a resource list.

         Please refer bug for compelete business rules.
      */

      IF l_plan_version_planning_level = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

            pa_debug.g_err_stage := 'Planning level of the plan version is project ..';
            IF P_PA_DEBUG_MODE = 'Y' THEN
                 pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
            END IF;

            OPEN  cur_elements_for_project;
            FETCH cur_elements_for_project  BULK COLLECT INTO
                  l_src_ra_id_tbl,
                  l_src_elem_ver_id_tbl,
                  l_targ_elem_ver_id_tbl,
                  l_targ_proj_assmt_id_tbl,
                  l_planning_start_date_tbl,
                  l_planning_end_date_tbl,
                  l_schedule_start_date_tbl,
                  l_schedule_end_date_tbl,
                  l_targ_rlm_id_tbl;   -- Bug 3615617
            CLOSE cur_elements_for_project;

            IF l_src_ra_id_tbl.count > 0 THEN

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'Calling create_res_task_map';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;

                 pa_fp_copy_from_pkg.create_res_task_maps(
                       p_context                     => 'BUDGET'
                      ,p_src_ra_id_tbl               => l_src_ra_id_tbl
                      ,p_src_elem_ver_id_tbl         => l_src_elem_ver_id_tbl
                      ,p_targ_elem_ver_id_tbl        => l_targ_elem_ver_id_tbl
                      ,p_targ_proj_assmt_id_tbl      => l_targ_proj_assmt_id_tbl
                      ,p_targ_rlm_id_tbl             => l_targ_rlm_id_tbl  -- Bug 3615617
                      ,p_planning_start_date_tbl     => l_planning_start_date_tbl
                      ,p_planning_end_date_tbl       => l_planning_end_date_tbl
                      ,p_schedule_start_date_tbl     => l_schedule_start_date_tbl
                      ,p_schedule_end_date_tbl       => l_schedule_end_date_tbl
                      ,x_return_status               => l_return_status
                      ,x_msg_count                   => l_msg_count
                      ,x_msg_data                    => l_msg_data );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'The call to create_res_task_map returned with error';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;

                 IF P_PA_DEBUG_MODE = 'Y' THEN
                     pa_debug.g_err_stage := 'copy_resource_assignments';
                     pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                 END IF;
                 pa_fp_copy_from_pkg.copy_resource_assignments(
                                      p_source_plan_version_id  => l_ci_apprv_cw_bv_id
                                     ,p_target_plan_version_id  => p_budget_version_id
                                     ,p_adj_percentage          => -99
                                     -- Bug 4200168
                                     ,p_calling_context         => 'CI'
                                     ,x_return_status           => l_return_status
                                     ,x_msg_count               => l_msg_count
                                     ,x_msg_data                => l_msg_data );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'The call to copy_resource_assignments returned with error';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
            END IF; /* l_src_ra_id_tbl.count > 0  */

      ELSE /* Task level planning */

            OPEN  cur_elements_for_task(p_impacted_task_id);
            FETCH cur_elements_for_task  BULK COLLECT INTO
                  l_src_ra_id_tbl,
                  l_src_elem_ver_id_tbl,
                  l_targ_elem_ver_id_tbl,
                  l_targ_proj_assmt_id_tbl,
                  l_planning_start_date_tbl,
                  l_planning_end_date_tbl,
                  l_schedule_start_date_tbl,
                  l_schedule_end_date_tbl,
                  l_targ_rlm_id_tbl;   -- Bug 3615617
            CLOSE cur_elements_for_task;

            IF l_src_ra_id_tbl.count = 0 THEN

                  OPEN  impacted_task_cur(p_impacted_task_id);
                  FETCH impacted_task_cur INTO impacted_task_rec;
                  CLOSE impacted_task_cur;

                  IF impacted_task_rec.top_task_id = p_impacted_task_id THEN

                       /* No record are there to be inserted. Ideally, control should never come
                        * here since is_create_ci_version_Allowed should have caught this case and
                        * thrown an error! */
                       null;
                  ELSE
                       OPEN  cur_elements_for_task(impacted_task_rec.top_task_id);
                       FETCH cur_elements_for_task  BULK COLLECT INTO
                             l_src_ra_id_tbl,
                             l_src_elem_ver_id_tbl,
                             l_targ_elem_ver_id_tbl,
                             l_targ_proj_assmt_id_tbl,
                             l_planning_start_date_tbl,
                             l_planning_end_date_tbl,
                             l_schedule_start_date_tbl,
                             l_schedule_end_date_tbl,
                             l_targ_rlm_id_tbl;   -- Bug 3615617
                       CLOSE cur_elements_for_task;
                  END IF;
            END IF;

            IF l_src_ra_id_tbl.count = 0 THEN
                  /* No record are there to be inserted. Ideally, control should never come here since
                   * is_create_ci_version_Allowed should have caught this case and thrown an error! */
                  null;
            ELSE
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                      pa_debug.g_err_stage := 'Calling create_res_task_map';
                      pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;

                  pa_fp_copy_from_pkg.create_res_task_maps(
                       p_context                     => 'BUDGET'
                      ,p_src_ra_id_tbl               => l_src_ra_id_tbl
                      ,p_src_elem_ver_id_tbl         => l_src_elem_ver_id_tbl
                      ,p_targ_elem_ver_id_tbl        => l_targ_elem_ver_id_tbl
                      ,p_targ_proj_assmt_id_tbl      => l_targ_proj_assmt_id_tbl
                      ,p_targ_rlm_id_tbl             => l_targ_rlm_id_tbl  -- Bug 3615617
                      ,p_planning_start_date_tbl     => l_planning_start_date_tbl
                      ,p_planning_end_date_tbl       => l_planning_end_date_tbl
                      ,p_schedule_start_date_tbl     => l_schedule_start_date_tbl
                      ,p_schedule_end_date_tbl       => l_schedule_end_date_tbl
                      ,x_return_status               => l_return_status
                      ,x_msg_count                   => l_msg_count
                      ,x_msg_data                    => l_msg_data );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'The call to create_res_task_map returned with error';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                  END IF;

                  IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'copy_resource_assignments';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                  END IF;
                  pa_fp_copy_from_pkg.copy_resource_assignments(
                                      p_source_plan_version_id  => l_ci_apprv_cw_bv_id
                                      ,p_target_plan_version_id => p_budget_version_id
                                      ,p_adj_percentage         => -99
                                      -- Bug 4200168
                                      ,p_calling_context         => 'CI'
                                      ,x_return_status          => l_return_status
                                      ,x_msg_count              => l_msg_count
                                      ,x_msg_data               => l_msg_data );

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF P_PA_DEBUG_MODE = 'Y' THEN
                             pa_debug.g_err_stage := 'The call to copy_resource_assignments returned with error';
                             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,3);
                       END IF;
                       RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 END IF;
            END IF; /* l_src_ra_id_tbl.count > 0  */

      END IF;

      IF P_PA_DEBUG_MODE = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting Create_CI_Resource_Assignments';
          pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_err_stack;

  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;

           pa_debug.g_err_stage:= 'Invalid Arguments Passed';
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
           END IF;
           pa_debug.reset_err_stack;
           RAISE;

   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_FP_ELEMENTS_PUB'
                                  ,p_procedure_name  => 'Create_CI_Resource_Assignments');
          pa_debug.g_err_stage:= 'Unexpected Error'||SQLERRM;
          IF P_PA_DEBUG_MODE = 'Y' THEN
             pa_debug.write('Create_CI_Resource_Assignments: ' || l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
          END IF;
          pa_debug.reset_err_stack;
          RAISE;
END Create_CI_Resource_Assignments;

/*==================================================================
   When automatic resource selection is enabled for an option,this
   api inserts resources or resource group elements to a project
   or a pl/sql table of tasks based on the option planning level that
   is passed.

   The api can also be called for an entire option in which case
   resource/ resource groups elements would be added to all the
   plannable tasks for that element type,fp option combination.

 NOTE(S):-
  1. If the option planning level is project, the task_id tbl should
     contain one and only one record and that should be zero as we
     enter 0(zero) for task_id column in pa_fp_elements for project
     level planning options.
 ==================================================================*/

PROCEDURE Add_resources_automatically
   (  p_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
     ,p_element_type          IN   pa_fp_elements.element_type%TYPE
     ,p_fin_plan_level_code   IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_resource_list_id      IN   pa_resource_lists_all_bg.resource_list_id%TYPE
     ,p_res_planning_level    IN   pa_proj_fp_options.cost_res_planning_level%TYPE
     ,p_entire_option         IN   VARCHAR2
     ,p_element_task_id_tbl   IN   pa_fp_elements_pub.l_task_id_tbl_typ
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_return_status                 VARCHAR2(2000);

l_task_tbl_index                NUMBER;
l_rlm_tbl_index                 NUMBER;
l_res_uncategorized_flag        VARCHAR2(1);
l_is_resource_list_grouped      VARCHAR2(1);
l_group_resource_type_id        pa_resource_lists_all_bg.group_resource_type_id%TYPE;


/*
   The following pl/sql tables are used to store task_id, top_task_id,
   resource_list_member_ids. The table types have defined in the package
   specification.
 */
l_task_id_tbl                    l_task_id_tbl_typ;
l_top_task_id_tbl                l_top_task_id_tbl_typ;
l_res_list_mem_id_tbl            l_res_list_mem_id_tbl_typ;

/* The cursors used in the api*/

/*
    The following cursor is used to fetch project_id, plan_type_id
    based on the element type etc., for an option_id
 */
CURSOR proj_fp_options_info_cur
      ( c_proj_fp_options_id     pa_proj_fp_options.proj_fp_options_id%TYPE
       ,c_element_type           pa_fp_elements.element_type%TYPE)
IS
     SELECT  project_id
            ,fin_plan_type_id
            ,fin_plan_version_id
     FROM   pa_proj_fp_options
     WHERE  proj_fp_options_id = c_proj_fp_options_id;

proj_fp_options_info_rec          proj_fp_options_info_cur%ROWTYPE;

/*
    The following cursor is used to fetch all the tasks that can be
    planned for an option and element_type combination for automatic
    resource addition in the context of entire option
 */
CURSOR all_plannable_tasks_cur
      ( c_proj_fp_options_id     pa_proj_fp_options.proj_fp_options_id%TYPE
       ,c_element_type           pa_fp_elements.element_type%TYPE)
IS
     SELECT  task_id
             ,top_task_id
     FROM    pa_fp_elements
     WHERE   proj_fp_options_id       =  c_proj_fp_options_id
     AND     element_type             =  c_element_type
     AND     resource_list_member_id  =  0
     AND     plannable_flag           =  'Y';

/*
    The following cursor is used to fetch all the resource list
    members in case the input resource list is ungrouped.
    'UNCLASSIFIED' resource list member is filtered as that
    shouldn't be added to the option.
 */
CURSOR ungrouped_res_cur
      ( c_resource_list_id       pa_resource_lists_all_bg.resource_list_id%TYPE)
IS
     SELECT resource_list_member_id
     FROM   pa_resource_list_members
     WHERE  resource_list_id    =   c_resource_list_id
     AND    resource_type_code  <>  PA_FP_CONSTANTS_PKG.G_UNCLASSIFIED
     AND    enabled_flag='Y'    -- bug 3289243
     AND    display_flag='Y';   -- bug 3289243

/*
    The following cursor is used to fetch all the resource list members
    in case the input resource list is grouped and resource planning level
    is Resource.'UNCLASSIFIED' resource list member is filtered as that
    shouldn't be added to the option.
 */
CURSOR grouped_res_level_res_cur
      ( c_resource_list_id       pa_resource_lists_all_bg.resource_list_id%TYPE)
IS
     SELECT resource_list_member_id
     FROM   pa_resource_list_members
     WHERE  resource_list_id    =   c_resource_list_id
     AND    resource_type_code  <>  PA_FP_CONSTANTS_PKG.G_UNCLASSIFIED
     AND    enabled_flag='Y'    -- bug 3289243
     AND    display_flag='Y'    -- bug 3289243
     AND    parent_member_id    IS NOT NULL; -- to filter all the resource group level records

/*
    The following cursor is used to fetch all the resource list members
    in case the input resource list is grouped and resource planning level
    is Resource Group.'UNCLASSIFIED' resource list member is filtered as that
    shouldn't be added to the option.
 */
CURSOR grouped_resgrp_level_res_cur
      ( c_resource_list_id       pa_resource_lists_all_bg.resource_list_id%TYPE)
IS
     SELECT resource_list_member_id
     FROM   pa_resource_list_members
     WHERE  resource_list_id    =   c_resource_list_id
     AND    resource_type_code  <>  PA_FP_CONSTANTS_PKG.G_UNCLASSIFIED
     AND    enabled_flag='Y'    -- bug 3289243
     AND    display_flag='Y'    -- bug 3289243
     AND    parent_member_id    IS NULL; -- to filter all the resource level records

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      PA_DEBUG.Set_Curr_Function( p_function   => 'Add_resources_automatically',
                                  p_debug_mode => p_pa_debug_mode );

      -- Check for NOT NULL parameters
      IF  (p_proj_fp_options_id  IS NULL) OR
          (p_element_type        IS NULL) OR
          (p_fin_plan_level_code IS NULL) OR
          (p_resource_list_id    IS NULL) OR
          (p_res_planning_level  IS NULL) OR
          (p_entire_option       IS NULL)
      THEN
            IF p_pa_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_proj_fp_options_id = '|| p_proj_fp_options_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_element_type = '|| p_element_type;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_fin_plan_level_code = '|| p_fin_plan_level_code;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_resource_list_id = '|| p_resource_list_id;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_res_planning_level = '|| p_res_planning_level;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_entire_option = '|| p_entire_option;
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      -- Fetch project_id, plan_type_id for the i/p option, element_type

      OPEN   proj_fp_options_info_cur(p_proj_fp_options_id,p_element_type);
      FETCH  proj_fp_options_info_cur INTO proj_fp_options_info_rec;

           IF proj_fp_options_info_cur%NOTFOUND
           THEN
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'Unexpected error while fetching option_id Info for the option: '
                                     ||p_proj_fp_options_id||'the error message is: '||sqlerrm;
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                END IF;
                PA_UTILS.ADD_MESSAGE
                       (p_app_short_name => 'PA',
                        p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
      CLOSE proj_fp_options_info_cur;
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
           END IF;

      CLOSE  proj_fp_options_info_cur;

      /*
         If resources are to be added for an entire option we need to
         fetch all the plannable tasks for the option and element type.
       */

      IF  p_entire_option  =  'Y'
      THEN
           /*
             If option planning level is 'Project', l_task_id_tbl
             table would contain only one record and top_task_id
             for this record is also populated as zero.
             Else fetch all the plannable tasks.
            */
           IF p_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT
           THEN
                l_task_id_tbl(1) := 0;
                l_top_task_id_tbl(1) := 0;
           ELSE
                 IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Cursor all_plannable_tasks_cur is opened';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;

                 OPEN  all_plannable_tasks_cur(p_proj_fp_options_id,p_element_type);
                 FETCH all_plannable_tasks_cur
                 BULK COLLECT INTO
                       l_task_id_tbl
                      ,l_top_task_id_tbl;
                 CLOSE all_plannable_tasks_cur;
           END IF;

      ELSE

           -- If entire option is 'N', then table of pl/sql tables is passed as input

           l_task_id_tbl := p_element_task_id_tbl;

           IF l_task_id_tbl.count = 0
           THEN
                IF p_pa_debug_mode = 'Y' THEN
                     pa_debug.g_err_stage:= 'l_task_id_Tbl is empty. Returning...';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                END IF;
                pa_debug.reset_curr_function;
                RETURN; -- as no tasks are to be processed.
           END IF;

           /*
              If option planning level is 'Project', l_task_id_tbl
              table should contain only one record and top_task_id
              for this record is to be populated as zero.
              Else fetch top tasks all the tasks in the pl/sql table.
            */

           IF p_fin_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT
           THEN

                 l_task_tbl_index := l_task_id_tbl.first;

                 IF   (l_task_id_tbl.count <> 1) OR (l_task_id_tbl(l_task_tbl_index) <> 0)
                 THEN
                     IF p_pa_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage:= 'Invalid task(s) passed for project plan level case';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                     END IF;
                     PA_UTILS.ADD_MESSAGE
                            (p_app_short_name => 'PA',
                             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                 ELSE
                     l_top_task_id_tbl(l_task_tbl_index) := 0;
                 END IF;

           ELSE   -- Option is not planned at project level

                FOR l_task_tbl_index IN l_task_id_tbl.first .. l_task_id_tbl.last
                LOOP

                      IF p_pa_debug_mode = 'Y' THEN
                             pa_debug.g_err_stage:= 'Fetching top task for each task_id';
                             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                      END IF;

                      BEGIN
                            SELECT top_task_id
                            INTO   l_top_task_id_tbl(l_task_tbl_index)
                            FROM   pa_fp_elements
                            WHERE  proj_fp_options_id      =  p_proj_fp_options_id
                            AND    element_type            =  p_element_type
                            AND    task_id                 =  l_task_id_tbl(l_task_tbl_index)
                            AND    resource_list_member_id =  0
                            AND    plannable_flag          =  'Y';
                      EXCEPTION
                            WHEN NO_DATA_FOUND THEN

                                 IF p_pa_debug_mode = 'Y' THEN
                                         pa_debug.g_err_stage:= 'While fetching top_task for the task: '
                                                       ||l_task_id_tbl(l_task_tbl_index)|| 'Error is: '||sqlerrm;
                                         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                                 END IF;
                                 PA_UTILS.ADD_MESSAGE
                                        (p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                      END;
                END LOOP;

           END IF; -- Option planning level 'P' or not

      END IF;  -- entire option 'Y'/'N'

      /*
        To know  if the given resource list id is grouped/ ungrouped
        call pa_fin_plan_utils.get_resource_list_info.
       */

      PA_FIN_PLAN_UTILS.GET_RESOURCE_LIST_INFO
                  (
                     p_resource_list_id          => p_resource_list_id
                    ,x_res_list_is_uncategorized => l_res_uncategorized_flag
                    ,x_is_resource_list_grouped  => l_is_resource_list_grouped
                    ,x_group_resource_type_id    => l_group_resource_type_id
                    ,x_return_status             => x_return_status
                    ,x_msg_count                 => x_msg_count
                    ,x_msg_data                  => x_msg_data
                  );

      /* return if resource list is uncategorized as no resources are to be added in this case*/
      IF l_res_uncategorized_flag = 'Y'
      THEN
          IF p_pa_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'l_res_uncategorized_flag is Y. Returning...';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
               pa_debug.reset_curr_function;
          END IF;
          RETURN;
      END IF;

      /*
       Depending on the resource list being grouped/ungrouped,
       p_res_planning_level 'R'(resource)/'G'(resource group)
       we need to open the appropriate cursor. bulk fetch all
       the resource list memners into l_res_list_mem_id_tbl.
      */

      IF    l_is_resource_list_grouped  = 'N'
      THEN

            IF p_pa_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'ungrouped_res_cur is opened';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
            END IF;

            OPEN  ungrouped_res_cur (p_resource_list_id);
            FETCH ungrouped_res_cur BULK COLLECT INTO
                   l_res_list_mem_id_tbl;
            CLOSE ungrouped_res_cur;
      ELSE
           IF    p_res_planning_level = PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_R
           THEN

                 IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'grouped_res_level_res_cur is opened';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;

                 OPEN  grouped_res_level_res_cur(p_resource_list_id);
                 FETCH grouped_res_level_res_cur BULK COLLECT INTO
                        l_res_list_mem_id_tbl;
                 CLOSE  grouped_res_level_res_cur;

           ELSIF p_res_planning_level = PA_FP_CONSTANTS_PKG.G_RESOURCE_PLANNING_LEVEL_G
           THEN

                 IF p_pa_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'grouped_resgrp_level_res_cur is opened';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                 END IF;

                 OPEN  grouped_resgrp_level_res_cur(p_resource_list_id);
                 FETCH grouped_resgrp_level_res_cur BULK COLLECT INTO
                        l_res_list_mem_id_tbl;
                 CLOSE  grouped_resgrp_level_res_cur;
           END IF;
      END IF;

     /*
       For each task_id in the task_id table we need to insert
       all the resource_list_memebers fetched in pa_fp_elements table.
      */

      IF p_pa_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= 'for each task in task_id_tbl inserting all the rlmids fetched';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      FOR l_task_tbl_index IN l_task_id_tbl.first .. l_task_id_tbl.last
      LOOP

           /* Insert all the resource_list_members fetched for each task */

           FORALL l_rlm_tbl_index IN l_res_list_mem_id_tbl.first .. l_res_list_mem_id_tbl.last
             INSERT INTO pa_fp_elements
                  (PROJ_FP_ELEMENTS_ID
                  ,PROJ_FP_OPTIONS_ID
                  ,PROJECT_ID
                  ,FIN_PLAN_TYPE_ID
                  ,ELEMENT_TYPE
                  ,FIN_PLAN_VERSION_ID
                  ,TASK_ID
                  ,TOP_TASK_ID
                  ,RESOURCE_LIST_MEMBER_ID
                  ,TOP_TASK_PLANNING_LEVEL
                  ,RESOURCE_PLANNING_LEVEL
                  ,PLANNABLE_FLAG
                  ,RESOURCES_PLANNED_FOR_TASK
                  ,PLAN_AMOUNT_EXISTS_FLAG
                  ,TMP_PLANNABLE_FLAG
                  ,TMP_TOP_TASK_PLANNING_LEVEL
                  ,RECORD_VERSION_NUMBER
                  ,LAST_UPDATE_DATE
                  ,LAST_UPDATED_BY
                  ,CREATION_DATE
                  ,CREATED_BY
                  ,LAST_UPDATE_LOGIN)
             VALUES
                  (pa_fp_elements_s.nextval
                  ,p_proj_fp_options_id
                  ,proj_fp_options_info_rec.project_id
                  ,proj_fp_options_info_rec.fin_plan_type_id
                  ,p_element_type
                  ,proj_fp_options_info_rec.fin_plan_version_id
                  ,l_task_id_tbl(l_task_tbl_index)               -- task_id
                  ,l_top_task_id_tbl(l_task_tbl_index)           -- top_task_id
                  ,l_res_list_mem_id_tbl(l_rlm_tbl_index)        -- resource_list_member_id
                  ,NULL                                          -- top_task_planning_level
                  ,NULL                                          -- resource_planning_level
                  ,'Y'                                           -- plannable_flag
                  ,NULL                                          -- resources_planned_for_task
                  ,'N'                                           -- plan_amount_exists_flag
                  ,'Y'                                           -- tmp_plannable_flag
                  ,NULL                                          -- tmp_top_task_planning_level
                  ,1                                             -- record_version_number
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id);
      END LOOP;

      -- Bulk update all the task records to reflect that resources selection is done

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Bulk updating all the tasks to reflect resource selection status';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;

      IF l_res_list_mem_id_tbl.count > 0
      THEN
           FORALL  l_task_tbl_index IN l_task_id_tbl.first .. l_task_id_tbl.last
             UPDATE pa_fp_elements
             SET    resources_planned_for_task = 'Y'
                   ,resource_planning_level    = p_res_planning_level
                   ,record_version_number = record_version_number + 1
                   ,last_update_date = sysdate
                   ,last_updated_by = FND_GLOBAL.USER_ID
                   ,last_update_login = FND_GLOBAL.LOGIN_ID
             WHERE  proj_fp_options_id       =  p_proj_fp_options_id
             AND    element_type             =  p_element_type
             AND    task_id                  =  l_task_id_tbl(l_task_tbl_index)
             AND    resource_list_member_id  = 0;
      END IF;

      IF p_pa_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Add_resources_automatically';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;
      pa_debug.reset_curr_function;
  EXCEPTION

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

           x_return_status := FND_API.G_RET_STS_ERROR;
           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                      (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
           ELSE
                x_msg_count := l_msg_count;
           END IF;
           pa_debug.reset_curr_function;
           RETURN;
   WHEN others THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg
                          ( p_pkg_name        => 'PA_FP_ELEMENTS_PUB'
                           ,p_procedure_name  => 'ADD_RESOURCES_AUTOMATICALLY'
                           ,p_error_text      => sqlerrm);
          pa_debug.reset_curr_function;
          RAISE;
END Add_resources_automatically;

/* Bug 2920954 - This procedure deletes all the planning elements
   (pa_fp_elements/pa_resource_assignments) of this task and all
   its child tasks.  This is called during the task deletion. These
   tasks would have plannable plan_amount_exists_flag as 'N'. Its
   assumed that the check apis would have been called to ensure
   that deletion of p_task_id is allowed. One main check in the check api
   is that p_task_id should not be present in pa_resource_assignments
   of a BASELINED version since we should not be touching RA table
   of BASELINED versions. When plan amounts donot exists, pa_proj_periods_denorm
   will not contain any data for that task.

   Bug 2976168. Delete from pa_fp_excluded_elements */

PROCEDURE Delete_task_elements
   (  p_task_id               IN   pa_tasks.task_id%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

L_DEBUG_LEVEL2                   CONSTANT NUMBER := 2;
L_DEBUG_LEVEL3                   CONSTANT NUMBER := 3;
L_DEBUG_LEVEL4                   CONSTANT NUMBER := 4;
L_DEBUG_LEVEL5                   CONSTANT NUMBER := 5;

l_records_deleted                NUMBER;
BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     pa_debug.set_curr_function( p_function   => 'delete_task_elements',
                                 p_debug_mode => l_debug_mode );

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     L_DEBUG_LEVEL3);
     END IF;

     IF (p_task_id IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_task_id = '|| p_task_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           L_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Deleting from pa_resource_assignments for task id ' || to_char(p_task_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                          L_DEBUG_LEVEL3);
          END IF;

          DELETE FROM pa_resource_assignments r
          WHERE r.task_id IN (SELECT t.task_id
                              FROM   pa_tasks t
                              CONNECT BY PRIOR t.task_id = t.parent_task_id
                              START WITH t.task_id = p_task_id);

          l_records_deleted := sql%rowcount;

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= To_char(l_records_deleted) || ' records deleted.';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
          END IF;

     IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting delete_task_elements';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
     END IF;

     pa_debug.reset_curr_function;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     pa_debug.reset_curr_function;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_Fp_elements_pub'
                    ,p_procedure_name  => 'delete_task_elements'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
     END IF;
     pa_debug.reset_curr_function;
     RAISE;
END delete_task_elements;
/*
For bug 2976168.
This API is called from pa_fp_elements_pub.make_new_tasks_plannable api for an option and element_type.
This API will be used to decide whether to insert a task in fp elements table or not. This api will also
provide the plannable flag and task planning level of all the tasks that are eligible for insertion.
*/
PROCEDURE Get_Task_Element_Attributes
( p_proj_fp_options_id             IN     pa_proj_fp_options.proj_fp_options_id%TYPE
 ,p_element_type                   IN     pa_fp_elements.element_type%TYPE
 ,p_task_id                        IN     pa_fp_elements.task_id%TYPE
 ,p_top_task_id                    IN     pa_fp_elements.top_task_id%TYPE
 ,p_task_level                     IN     VARCHAR2
 ,p_option_plan_level_code         IN     pa_proj_fp_options.cost_fin_plan_level_code%TYPE
 ,x_task_inclusion_flag            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_task_plannable_flag            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_top_task_planning_level        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                      OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                       OUT    NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

--Declare the variables which are required as a standard
l_msg_count                      NUMBER := 0;
l_data                           VARCHAR2(2000);
l_msg_data                       VARCHAR2(2000);
l_msg_index_out                  NUMBER;
l_debug_mode                     VARCHAR2(1);

L_DEBUG_LEVEL3                   CONSTANT NUMBER   := 3;
L_DEBUG_LEVEL5                   CONSTANT NUMBER   := 5;
L_TASK_LEVEL_TOP                 CONSTANT VARCHAR2(1) := 'T';
L_TASK_LEVEL_MIDDLE              CONSTANT VARCHAR2(1) := 'M';
L_TASK_LEVEL_LOWEST              CONSTANT VARCHAR2(1) := 'L';
L_PROCEDURE_NAME                 CONSTANT VARCHAR2(100) :='Get_Task_Element_Attributes: '||
                                                         l_module_name ;

--Variables required in this procedure
l_continue_processing            VARCHAR2(1) := 'Y';
l_dummy                          VARCHAR2(1);
l_child_task_exists              NUMBER;     /* Indicates if child tasks exists for a task
                                                 0 - No child tasks exists
                                                 1 - Child task exists
                                                 Other Number - Sql Error */

--Cursors required for this procedure

--This cursor is used to know whether a task already exists in pa_fp_elements or not
CURSOR task_element_info_cur (
 c_task_id pa_fp_elements.task_id%TYPE)
IS
SELECT pfe.top_task_planning_level,
       pfe.plannable_flag
FROM   pa_fp_elements pfe
WHERE  pfe.proj_fp_options_id = p_proj_fp_options_id
AND    pfe.element_type = p_element_type
AND    pfe.task_id = c_task_id
AND    pfe.resource_list_member_id = 0;

task_element_info_rec task_element_info_cur%ROWTYPE;

--This cursor is used to know whether a task is explicitly made unplannable
CURSOR excluded_task_cur
( c_task_id pa_tasks.task_id%TYPE
 ,c_top_task_id pa_tasks.task_id%TYPE)
IS
SELECT 'Y'
FROM   pa_fp_excluded_elements pfe
WHERE  pfe.proj_fp_options_id = p_proj_fp_options_id
AND    pfe.element_type = p_element_type
AND    pfe.task_id IN (c_task_id,c_top_task_id);

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'Get_Task_Element_Attributes',
                                      p_debug_mode => l_debug_mode );
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Validating input parameters';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      IF p_proj_fp_options_id     IS NULL OR
         p_element_type           IS NULL OR
         p_task_id                IS NULL OR
         p_top_task_id            IS NULL OR
         p_task_level             IS NULL OR
         p_option_plan_level_code IS NULL
      THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_proj_fp_options_id = '|| p_proj_fp_options_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_element_type = '|| p_element_type;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_task_id = '|| p_task_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_top_task_id = '|| p_top_task_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_task_level = '|| p_task_level;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_option_plan_level_code = '|| p_option_plan_level_code;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

            END IF;
            PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Check if the task is already included as a plannable element.
      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Check if task is already plannable(existence in pa_fp_elements)';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      -- If p_task_id already exists in pa_fp_elements for the option_id and element_type, no further
      -- processing is required.

      OPEN task_element_info_cur(p_task_id);
      FETCH task_element_info_cur INTO task_element_info_rec;
      IF task_element_info_cur%NOTFOUND THEN
            l_continue_processing := 'Y';
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'task doesnt exists in pa_fp_elements. Proceeding further..';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;
      ELSE
            l_continue_processing := 'N';
            x_task_inclusion_flag := 'N';
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'task is already plannable and exists in pa_fp_elements. No processing required...';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;
      END IF;
      CLOSE task_element_info_cur;

      --Check if the task is already made unplannable.
      IF l_continue_processing = 'Y' THEN

                 OPEN excluded_task_cur( p_task_id
                                   ,p_top_task_id);
            FETCH excluded_task_cur INTO l_dummy;
            IF excluded_task_cur%FOUND THEN
                  l_continue_processing := 'N';
                  x_task_inclusion_flag := 'N';
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Task ' ||p_task_id ||' is not processed as it exists in pa_fp_excluded_elements';
                        pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;
            END IF;
            CLOSE excluded_task_cur;
      END IF;

      --Continue processing if the task is not either made plannable or unplannable.
      IF l_continue_processing='Y' THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage := 'Continuing with the processing of task ' || p_task_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            -- Planning level for the options is top task
            IF p_option_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP THEN

                  --The task passed is a top task

                  IF p_task_level = L_TASK_LEVEL_TOP THEN

                        -- When the planning level of the option is TOP,
                        -- only top task are plannable
                        x_task_inclusion_flag     := 'Y';
                        x_task_plannable_flag     := 'Y';
                        x_top_task_planning_level := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_TOP;
                  ELSE

                        x_task_inclusion_flag := 'N';

                  END IF; /* p_task_id = p_top_task_id */

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Option planned at Top Task and x_task_inclusion_flag = ' ||
                                                x_task_inclusion_flag || ' x_task_plannable_flag =' || x_task_plannable_flag ||
                                                ' x_top_task_planning_level ' || x_top_task_planning_level;
                        pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

            --Planning level of the options is either LOWEST or TOP AND LOWEST

            ELSIF p_option_plan_level_code IN (PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_LOWEST,
                                               PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_M) THEN

                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'Option planned at Lowest Task or Top and Lowest Task';
                        pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

                  --The task is a top task
                  IF p_task_level = L_TASK_LEVEL_TOP THEN

                        l_child_task_exists := pa_task_utils.check_child_exists(x_task_id => p_task_id);

                        IF l_child_task_exists = 1 THEN /* Child task exsists */

                               /* This is a TOP task which is being created only now. But the planning
                                  level is L/M. Since we always have top task records in pa_fp_elements,
                                  this top task should be inserted in pa_fp_elements with plannable flag
                                  as N. Resource elements should not be added for this top task */

                              x_task_inclusion_flag         := 'Y';
                              x_task_plannable_flag         := 'N' ;
                              x_top_task_planning_level     := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST;

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Task is a TOP TASK and x_task_inclusion_flag = '
                                                          || x_task_inclusion_flag || ' x_task_plannable_flag ='
                                                          ||x_task_plannable_flag || ' and x_top_task_planning_level =' ||
                                                          x_top_task_planning_level;
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                              END IF;

                        --The task is both top and lowest
                        ELSIF l_child_task_exists = 0 THEN

                         /* TOP AND LOWEST TASK is always plannable when planning
                            level of the option is LOWEST or TOP AND LOWEST */

                              x_task_inclusion_flag         := 'Y';
                              x_task_plannable_flag         := 'Y' ;
                              x_top_task_planning_level     := PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST;

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Task is a TOP and LOWEST TASK and x_task_inclusion_flag = '
                                                          || x_task_inclusion_flag || ' x_task_plannable_flag ='
                                                          ||x_task_plannable_flag || ' and x_top_task_planning_level =' ||
                                                          x_top_task_planning_level;

                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                              END IF;

                        ELSE

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Error returned by pa_task_utils.check_child_exists. Sqlerrcode ' || to_char(l_child_task_exists);
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                              END IF;

                              RAISE FND_API.G_Exc_Unexpected_Error;

                        END IF;

                  ELSIF p_task_level = L_TASK_LEVEL_LOWEST THEN

                        /* p_task_id is a sub task.
                        We need to check if the top task of p_task_id is marked plannable */

                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'Task is a sub task';
                              pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                        END IF;

                        OPEN task_element_info_cur(p_top_task_id);
                        FETCH task_element_info_cur INTO task_element_info_rec;

                        /* If top task of p_task_id is not plannable,
                        then p_task_id is not plannable */

                        IF task_element_info_cur%NOTFOUND THEN

                              /* Note that we dont expect this case to happen since our assumption is that
                                 the top task record would be first called to be made plannable and then the
                                 lowest task. If we need to handle this case, we have to first insert the
                                 p_top_task_id record into pa_fp_elements and then the p_task_id record. */

                              x_task_inclusion_flag := 'N';

                              CLOSE task_element_info_cur;

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'Top Task not found in pa_fp_elements and hence x_task_inclusion_flag  ' || x_task_inclusion_flag;
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                              END IF;

                        ELSE

                              CLOSE task_element_info_cur;
                              IF task_element_info_rec.top_task_planning_level = PA_FP_CONSTANTS_PKG.G_TASK_PLAN_LEVEL_LOWEST THEN

                                    /* If top task of p_task_id is plannable at LOWEST task level,
                                    then p_task_id (which is a lowest task here) should be made plannable */

                                    x_task_inclusion_flag := 'Y';
                                    x_task_plannable_flag := 'Y';


                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Top task is planned at lowest task level and x_task_inclusion_flag = ' || x_task_inclusion_flag
                                                                                                           ||' x_task_plannable_flag = ' ||x_task_plannable_flag;
                                          pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                    END IF;

                              ELSE

                                    /* If top task is not plannable at LOWEST task level,
                                    then p_task_id should not be plannable */

                                    x_task_inclusion_flag := 'N';

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= 'Top task is NOT planned at lowest task and so x_task_inclusion_flag = ' || x_task_inclusion_flag;
                                          pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                    END IF;

                              END IF; /* task_element_info_rec.top_task_planning_level = 'LOWEST' */

                        END IF; /* task_element_info_cur%NOTFOUND */

                  END IF; /* p_task_level = L_TASK_LEVEL_TOP */

            END IF; /* p_option_plan_level_code = PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_TOP*/

      END IF;/* If l_continue_processing = 'Y' */

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting Get_Task_Element_Attributes';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 and x_msg_data IS NULL THEN
            PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
            x_msg_count := l_msg_count;
      END IF;
      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

      RETURN;

WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_FP_ELEMENTS_PUB'
                    ,p_procedure_name  => 'Get_Task_Element_Attributes'
                    ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            pa_debug.reset_curr_function;
      END IF;
      RAISE;
END Get_Task_Element_Attributes;

/* Bug 2920954 - This is a PRIVATE api that would be called from the make_new_tasks_plannable
   api for each fp option in the context of COST/REVENUE/ALL. The api checks if the input
   new task can be made plannable depending on the planning level of the fp option and top
   task planning level. If the new task is plannable, task level record is inserted into
   fp elements table and if resources are to be added automatically, the procedure
   ADD_RESOURCES_AUTOMATICALLY api is called. Also, resource assignments and fp elements that
   were present for original task that was earlier plannable but now unplannable is deleted.

   Bug 2976168. Changed the signature of the API. Also the logic of deriving is a task is
   plannable or not is moved to Get_Task_Element_Attributes Api

   Bug 2989900. In case of CI versions, the tasks would be made plannable only if the task
   is an impacted task or a child task of impacted task */

PROCEDURE add_tasks_to_option
    ( p_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
     ,p_element_type          IN   pa_fp_elements.element_type%TYPE
     ,p_tasks_tbl             IN   pa_fp_elements_pub.l_wbs_refresh_tasks_tbl_typ
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

L_DEBUG_LEVEL3                   CONSTANT NUMBER := 3;
L_DEBUG_LEVEL5                   CONSTANT NUMBER := 5;
L_TASK_LEVEL_TOP                 CONSTANT VARCHAR2(1) := 'T';
L_TASK_LEVEL_MIDDLE              CONSTANT VARCHAR2(1) := 'M';
L_TASK_LEVEL_LOWEST              CONSTANT VARCHAR2(1) := 'L';

CURSOR proj_fp_options_cur
IS
SELECT pfo.project_id,
       pfo.fin_plan_type_id,
       pfo.fin_plan_version_id,
       pfo.fin_plan_option_level_code,
       DECODE(p_element_type,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,pfo.cost_fin_plan_level_code,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,pfo.all_fin_plan_level_code,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, pfo.revenue_fin_plan_level_code) fin_plan_level_code,
       DECODE(p_element_type,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,pfo.select_cost_res_auto_flag,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL, pfo.select_all_res_auto_flag,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, pfo.select_rev_res_auto_flag) auto_res_selection_flag,
       DECODE(p_element_type,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,    pfo.cost_res_planning_level,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,     pfo.all_res_planning_level,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, pfo.revenue_res_planning_level) auto_res_plan_level,
       DECODE(p_element_type,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST,    pfo.cost_resource_list_id,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL,     pfo.all_resource_list_id,
                  PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE, pfo.revenue_resource_list_id) resource_list_id
FROM   pa_proj_fp_options pfo
WHERE  pfo.proj_fp_options_id = p_proj_fp_options_id;

proj_fp_options_rec  proj_fp_options_cur%ROWTYPE;


l_task_id_tbl                 pa_fp_elements_pub.l_task_id_tbl_typ;

l_task_plannable_flag         VARCHAR2(1); /* represents the plannable of the task to
                                              be inserted*/

--For Bug 2976168.
l_task_inclusion_flag         VARCHAR2(1);   /*Required to know whether the task can be is
                                               eligible for inserting into pa_fp_elements or not*/
CURSOR ci_version_info_cur
       (c_plan_version_id pa_proj_fp_options.fin_plan_version_id%TYPE)
IS
SELECT bv.ci_id,
       impacted_task_id
FROM   pa_budget_versions bv,
       pa_ci_impacts ci
WHERE  budget_version_id = c_plan_version_id
AND    bv.ci_id = ci.ci_id
AND    bv.ci_id IS NOT NULL;

ci_version_info_rec  ci_version_info_cur%ROWTYPE;

CURSOR ci_impacted_tasks_cur
       (c_project_id NUMBER, c_impacted_task_id NUMBER) IS
SELECT task_id
FROM   pa_tasks t
WHERE  t.project_id = c_project_id
START WITH t.task_id = c_impacted_task_id
CONNECT BY prior t.task_id = t.parent_task_id;

ci_impacted_tasks_rec  ci_impacted_tasks_cur%ROWTYPE;

l_continue_processing         VARCHAR2(1);
l_ci_impacted_tasks_tbl       PA_PLSQL_DATATYPES.NumTabTyp;
l_top_task_planning_level     pa_fp_elements.top_task_planning_level%TYPE;
L_PROCEDURE_NAME              CONSTANT VARCHAR2(100):='add_task_to_option :'||l_module_name;

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'add_task_to_option',
                                        p_debug_mode => l_debug_mode );
            pa_debug.g_err_stage:= 'Validating input parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      IF  (p_proj_fp_options_id IS NULL) OR
          (p_element_type IS NULL) THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_proj_fp_options_id = '|| p_proj_fp_options_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                  pa_debug.g_err_stage:= 'p_element_type = '|| p_element_type;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Opening proj_fp_options_cur.';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      OPEN proj_fp_options_cur;
      FETCH proj_fp_options_cur INTO proj_fp_options_rec;
      CLOSE proj_fp_options_cur;

      IF proj_fp_options_rec.fin_plan_version_id IS NOT NULL THEN

            OPEN  ci_version_info_cur(proj_fp_options_rec.fin_plan_version_id);
            FETCH ci_version_info_cur INTO ci_version_info_rec;
            IF ci_version_info_cur%NOTFOUND THEN
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'The Option does not correspond to a CI Version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;
            ELSE
                  IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage:= 'The Option corresponds to a CI Version';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

                  --Check whether an impacted task id exists or not. If it exists store all the tasks
                  --below that task in wbs in a pl/sql table so that only those tasks are processed.

                  IF ci_version_info_rec.impacted_task_id IS NOT NULL THEN
                        IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage:= 'The impacted task id is '
                                                         ||ci_version_info_rec.impacted_task_id;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                        END IF;

                        FOR ci_impacted_tasks_rec IN  ci_impacted_tasks_cur( proj_fp_options_rec.project_id
                                                                            ,ci_version_info_rec.impacted_task_id) LOOP

                              l_ci_impacted_tasks_tbl(ci_impacted_tasks_rec.task_id) := 1 ;

                        END LOOP;

                  END IF; /* IF ci_version_info_rec.impacted_task_id IS NOT NULL THEN */

            END IF; /* IF ci_version_info_cur%NOTFOUND THEN */

            CLOSE ci_version_info_cur;

      END IF; /* IF proj_fp_options_rec.fin_plan_version_id IS NOT NULL THEN */

      --Process the tasks passed by looping thru the pl/sql table (we are sure the plsql table contains records)

      FOR i IN p_tasks_tbl.first .. p_tasks_tbl.last LOOP

            l_continue_processing := 'Y';

            IF p_tasks_tbl(i).task_level IN ( L_TASK_LEVEL_LOWEST
                                             ,L_TASK_LEVEL_TOP) THEN

                  IF ci_version_info_rec.impacted_task_id IS NOT NULL THEN

                        /* Process the task only if the task is under the impacted task id */

                        IF  l_ci_impacted_tasks_tbl.exists(p_tasks_tbl(i).task_id) THEN

                              l_continue_processing := 'Y';
                        ELSE

                              l_continue_processing := 'N';

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage:= 'The task '||p_tasks_tbl(i).task_id
                                                           ||' is not under the impacted task '
                                                           ||ci_version_info_rec.impacted_task_id;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                              END IF;

                        END IF;

                  END IF; /* IF ci_version_info_rec.impacted_task_id IS NOT NULL THEN */

                  IF l_continue_processing = 'Y' THEN

                        l_task_inclusion_flag     := Null;
                        l_task_plannable_flag     := Null;
                        l_top_task_planning_level := Null;

                        --Call the api that helps in deciding whether to insert the task or not.

                        Get_Task_Element_Attributes
                        ( p_proj_fp_options_id       => p_proj_fp_options_id
                         ,p_element_type             => p_element_type
                         ,p_task_id                  => p_tasks_tbl(i).task_id
                         ,p_top_task_id              => p_tasks_tbl(i).top_task_id
                         ,p_task_level               => p_tasks_tbl(i).task_level
                         ,p_option_plan_level_code   => proj_fp_options_rec.fin_plan_level_code
                         ,x_task_inclusion_flag      => l_task_inclusion_flag
                         ,x_task_plannable_flag      => l_task_plannable_flag
                         ,x_top_task_planning_level  => l_top_task_planning_level
                         ,x_return_status            => x_return_status
                         ,x_msg_count                => x_msg_count
                         ,x_msg_data                 => x_msg_data);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                              IF l_debug_mode = 'Y' THEN
                                    pa_debug.g_err_stage := 'Error in Get_Task_Element_Attributes for  task'
                                                                                 || p_tasks_tbl(i).task_id ;
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                        END IF;

                        IF l_task_inclusion_flag = 'Y' THEN

                              IF p_tasks_tbl(i).parent_task_id = p_tasks_tbl(i).top_task_id THEN

                                    /* If the parent task is a top task,

                                    1. We need to remove only the resources elements attached
                                       to the parent task from pa_fp_elements.

                                    2. Since we always have the top task record of a plannable
                                       task in pa_fp_elements, we shouldnt delete the top task
                                       record. We just have to set the plannable flag
                                       of this task to N. */

                                    DELETE pa_fp_elements pfe
                                    WHERE  pfe.proj_fp_options_id = p_proj_fp_options_id
                                    AND    pfe.element_type = p_element_type
                                    AND    pfe.task_id = p_tasks_tbl(i).parent_task_id
                                    AND    pfe.resource_list_member_id <> 0;

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= to_char(sql%rowcount) || ' records deleted from pa_fp_elements';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                    END IF;

                                    UPDATE pa_fp_elements pfe
                                    SET    pfe.plannable_flag = 'N',
                                           pfe.tmp_plannable_flag = 'N',
                                           pfe.resources_planned_for_task = Null,
                                           pfe.record_version_number = pfe.record_version_number + 1,
                                           last_update_date = sysdate,
                                           last_updated_by = FND_GLOBAL.USER_ID,
                                           last_update_login = FND_GLOBAL.LOGIN_ID
                                    WHERE  pfe.proj_fp_options_id = p_proj_fp_options_id
                                    AND    pfe.element_type = p_element_type
                                    AND    pfe.task_id = p_tasks_tbl(i).parent_task_id
                                    AND    pfe.resource_list_member_id = 0;

                                    IF l_debug_mode = 'Y' THEN
                                          pa_debug.g_err_stage:= to_char(sql%rowcount) || ' records updated in pa_fp_elements';
                                          pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                    END IF;

                                    IF proj_fp_options_rec.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

                                          /* If this option corresponds to a plan version, we should delete the resource assignments also
                                             for p_task_id. */

                                          DELETE pa_resource_assignments pra
                                          WHERE  pra.budget_version_id = proj_fp_options_rec.fin_plan_version_id
                                          AND    pra.task_id = p_tasks_tbl(i).parent_task_id
                                          AND    pra.resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED;

                                          IF l_debug_mode = 'Y' THEN
                                                pa_debug.g_err_stage:= 'PLAN_VERSION option. ' || to_char(sql%rowcount) || ' records deleted from pa_resource_assignments';
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                          END IF;

                                    END IF; /* Option is PLAN_VERSION */

                              ELSE

                                   /* If p_task_id is not a top task then it would not be required to delete here
                                       as we BULK delete in make_new_tasks_plannable api for this case */
                                   Null;

                              END IF;

                              INSERT INTO PA_FP_ELEMENTS
                             (PROJ_FP_ELEMENTS_ID
                             ,PROJ_FP_OPTIONS_ID
                             ,PROJECT_ID
                             ,FIN_PLAN_TYPE_ID
                             ,ELEMENT_TYPE
                             ,FIN_PLAN_VERSION_ID
                             ,TASK_ID
                             ,TOP_TASK_ID
                             ,RESOURCE_LIST_MEMBER_ID
                             ,TOP_TASK_PLANNING_LEVEL
                             ,RESOURCE_PLANNING_LEVEL
                             ,PLANNABLE_FLAG
                             ,RESOURCES_PLANNED_FOR_TASK
                             ,PLAN_AMOUNT_EXISTS_FLAG
                             ,TMP_PLANNABLE_FLAG
                             ,TMP_TOP_TASK_PLANNING_LEVEL
                             ,RECORD_VERSION_NUMBER
                             ,LAST_UPDATE_DATE
                             ,LAST_UPDATED_BY
                             ,CREATION_DATE
                             ,CREATED_BY
                             ,LAST_UPDATE_LOGIN)
                           VALUES
                             (pa_fp_elements_s.nextval
                             ,p_proj_fp_options_id
                             ,proj_fp_options_rec.project_id
                             ,proj_fp_options_rec.fin_plan_type_id
                             ,p_element_type
                             ,proj_fp_options_rec.fin_plan_version_id
                             ,p_tasks_tbl(i).task_id
                             ,p_tasks_tbl(i).top_task_id
                             ,0                                                  -- resource_list_member_id
                             ,l_top_task_planning_level                          -- top_task_planning_level
                             ,decode(l_task_plannable_flag,
                                       'N',Null,
                                       proj_fp_options_Rec.auto_res_plan_level)  -- resource_planning_level
                             ,l_task_plannable_flag                              -- plannable_flag
                             ,proj_fp_options_rec.auto_res_selection_flag        -- resources_planned_for_task
                             ,'N'                                                -- plan_amount_exists_flag
                             ,l_task_plannable_flag                              -- tmp_plannable_flag
                             ,l_top_task_planning_level                          -- tmp_top_task_planning_level
                             ,1
                             ,SYSDATE
                             ,FND_GLOBAL.USER_ID
                             ,SYSDATE
                             ,FND_GLOBAL.USER_ID
                             ,FND_GLOBAL.LOGIN_ID);

                              IF proj_fp_options_rec.auto_res_selection_flag = 'Y' THEN

                                /* We should be adding resources only if p_task_id is a plannable task record.
                                   It should not be added to a top task record that is plannable at lowest task level */

                                    IF l_task_plannable_flag = 'Y' THEN

                                          /* If automatic resource selection is 'Y' for the proj_fp_option/element type,
                                          then resource elements need to be added */

                                          IF l_debug_mode = 'Y' THEN
                                                pa_debug.g_err_stage:= 'Calling add_resources_automatically...';
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                                          END IF;

                                          l_task_id_tbl(1) := p_tasks_tbl(i).task_id;

                                          PA_FP_ELEMENTS_PUB.ADD_RESOURCES_AUTOMATICALLY
                                          (  p_proj_fp_options_id    => p_proj_fp_options_id
                                            ,p_element_type          => p_element_type
                                            ,p_fin_plan_level_code   => proj_fp_options_rec.fin_plan_level_code
                                            ,p_resource_list_id      => proj_fp_options_rec.resource_list_id
                                            ,p_res_planning_level    => proj_fp_options_rec.auto_res_plan_level
                                            ,p_entire_option         => 'N'
                                            ,p_element_task_id_tbl   => l_task_id_tbl
                                            ,x_return_status         => x_return_status
                                            ,x_msg_count             => x_msg_count
                                            ,x_msg_data              => x_msg_data);

                                          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                                pa_debug.g_err_stage := 'Error while adding resoruces to task id ' || p_tasks_tbl(i).task_id ||
                                                                         'for ' || p_element_type || ' option id ' || p_proj_fp_options_id;
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                                                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                          END IF;

                                    END IF; /* l_task_plannable_flag = 'Y' */

                              END IF; /* proj_fp_options_rec.auto_res_selection_flag = 'Y' */

                        END IF; /* IF l_task_inclusion_flag = 'Y' THEN */

                  END IF; /* IF l_continue_processing = 'Y' THEN */

            END IF; /* IF p_tasks_tbl(i).task_level IN (T,L) */

      END LOOP; /* p_tasks_tbl.first .. p_tasks_tbl.last loop */

      /* Add_tasks_to_option is called only when the planning level is NOT project */

      IF proj_fp_options_rec.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Calling create_enterable_resources...';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            PA_FP_ELEMENTS_PUB.create_enterable_resources
              (  p_plan_version_id     => proj_fp_options_rec.fin_plan_version_id
                ,p_res_del_req_flag    => 'N' /* Since deletion of resource assignments has already been done in this flow */
                ,x_return_status       => x_return_status
                ,x_msg_count           => x_msg_count
                ,x_msg_data            => x_msg_data);

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                  pa_debug.g_err_stage := 'Error calling create enterable resoruces for version id'
                                           || proj_fp_options_rec.fin_plan_version_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;

      END IF; /* IF proj_fp_options_rec.fin_plan_option_level_code = PLAN_VERSION */

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting add_task_to_option';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            pa_debug.reset_curr_function;
      END IF;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := FND_MSG_PUB.count_msg;

      IF l_msg_count = 1 and x_msg_data IS NULL THEN
            PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
            x_msg_count := l_msg_count;
      END IF;
      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;
      RETURN;

WHEN others THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;

      FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fp_elements_pub'
                    ,p_procedure_name  => 'add_task_to_option'
                    ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            pa_debug.reset_curr_function;
      END IF;
      RAISE;
END add_tasks_to_option;

/* Bug 2920954 - This is the main  API that does the processing
   necessary to make the tasks plannable automatically at project level
   option, plan type level options and for all the working plan
   versions. This is api is called by projects / workplan code to make
   the new tasks that are created as plannable. */

/* Bug 2976168. Changed the signature of the api. This api will now be called from
   pa_fin_plan_maint_ver_global.resubmit_concurrent_request */

PROCEDURE make_new_tasks_plannable
    ( p_project_id              IN   pa_projects_all.project_id%TYPE
     ,p_tasks_tbl               IN   pa_fp_elements_pub.l_wbs_refresh_tasks_tbl_typ
     ,p_refresh_fp_options_tbl  IN   PA_PLSQL_DATATYPES.IdTabTyp
     ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

L_DEBUG_LEVEL3                  CONSTANT NUMBER := 3;
L_DEBUG_LEVEL5                  CONSTANT NUMBER := 5;


CURSOR fp_options_info_cur
       (c_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE)
IS
SELECT pfo.proj_fp_options_id,
       pfo.fin_plan_option_level_code,
       pfo.fin_plan_preference_code,
       pfo.cost_fin_plan_level_code,
       pfo.revenue_fin_plan_level_code,
       pfo.all_fin_plan_level_code,
       pfo.fin_plan_version_id
FROM   pa_proj_fp_options pfo
WHERE  pfo.proj_fp_options_id = c_proj_fp_options_id;
fp_options_info_rec   fp_options_info_cur%ROWTYPE;

l_process_option                 VARCHAR2(1);

L_PROCEDURE_NAME                 CONSTANT VARCHAR2(100):='make_new_tasks_plannable :'||l_module_name;
L_TASK_LEVEL_TOP                 CONSTANT VARCHAR2(1) := 'T';
L_TASK_LEVEL_MIDDLE              CONSTANT VARCHAR2(1) := 'M';
L_TASK_LEVEL_LOWEST              CONSTANT VARCHAR2(1) := 'L';

BEGIN

      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


      -- Check for business rules violations

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'make_new_tasks_plannable',
                                        p_debug_mode => l_debug_mode );
            pa_debug.g_err_stage:= 'Validating input parameters';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      IF (p_project_id IS NULL)
      THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Continue processing only if the task table has some records.

      IF NVL(p_tasks_tbl.last,0) = 0  OR
         NVL(p_refresh_fp_options_tbl.last,0) = 0 THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'task table/proj fp options table have no records. Returning from make_new_tasks_plannable ';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            RETURN;

      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'task table has  records.';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      /* Loop through the table and process the task records */

      FOR i IN  p_tasks_tbl.first .. p_tasks_tbl.last
      LOOP
            /* If the task is a middle level task delete all the references of that task from
               pa_fp_elements and pa_resource_assignments */

            IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'task_id ' || p_tasks_tbl(i).task_id;
                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                    pa_debug.g_err_stage:= 'task_level ' || p_tasks_tbl(i).task_level;
                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            IF p_tasks_tbl(i).task_level = L_TASK_LEVEL_MIDDLE THEN

                  --Delete the task references from pa_fp_elements
                  FORALL k IN p_refresh_fp_options_tbl.first .. p_refresh_fp_options_tbl.last
                        DELETE
                        FROM   pa_fp_elements
                        WHERE  task_id = p_tasks_tbl(i).task_id
                        AND    proj_fp_options_id = p_refresh_fp_options_tbl(k); /* We are deleting irrespective of element_type */

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'No of records deleted from pa_fp_elements ' ||SQL%ROWCOUNT;
                         pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

                  --Delete the task references from pa_resource_assignments
                  FORALL k IN p_refresh_fp_options_tbl.first .. p_refresh_fp_options_tbl.last
                        DELETE
                        FROM   pa_resource_assignments pra
                        WHERE  pra.task_id = p_tasks_tbl(i).task_id
                        AND    pra.budget_version_id in (SELECT pfo.fin_plan_version_id
                                                        FROM   pa_proj_fp_options pfo
                                                        WHERE  pfo.proj_fp_options_id =
                                                                       p_refresh_fp_options_tbl(k))
                        AND    pra.resource_assignment_type = PA_FP_CONSTANTS_PKG.G_USER_ENTERED;

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'No of records deleted from pa_resource_assignments ' ||SQL%ROWCOUNT;
                         pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

            END IF; /* IF p_tasks_tbl(i).task_level = M */

      END LOOP; /* FOR i IN  p_tasks_tbl.first .. p_tasks_tbl.last */

      --Loop through the table and process the option records
      FOR j IN  p_refresh_fp_options_tbl.first .. p_refresh_fp_options_tbl.last  LOOP

            IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage:= 'Opening fp_options_info_cur';
                   pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            OPEN fp_options_info_cur(p_refresh_fp_options_tbl(j));
            FETCH fp_options_info_cur INTO fp_options_info_rec;
            IF fp_options_info_cur%NOTFOUND THEN

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'fp_options_info_cur did not return rows for option id '||p_refresh_fp_options_tbl(j);
                         pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                  END IF;
                  CLOSE fp_options_info_cur;
                  RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

            ELSE
                  CLOSE fp_options_info_cur;
                  l_process_option := 'Y' ;
            END IF;

            IF  l_process_option= 'Y' THEN

                  IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'About to process the  option id '||p_refresh_fp_options_tbl(j);
                         pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                  END IF;

                  IF fp_options_info_rec.fin_plan_preference_code IN
                                                          (PA_FP_CONSTANTS_PKG.G_PREF_COST_ONLY,
                                                           PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

                        IF fp_options_info_rec.cost_fin_plan_level_code <>
                                                 PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

                              add_tasks_to_option (p_proj_fp_options_id  => p_refresh_fp_options_tbl(j)
                                                  ,p_element_type       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST
                                                  ,p_tasks_tbl          => p_tasks_tbl
                                                  ,x_return_status      => x_return_status
                                                  ,x_msg_count          => x_msg_count
                                                  ,x_msg_data           => x_msg_data);

                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                    pa_debug.g_err_stage := 'Error while adding tasks to cost option id ' || p_refresh_fp_options_tbl(j);
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                        END IF; /* fp_options_info_rec.cost_fin_plan_level_code  <> 'P' */

                  END IF; /* fp_options_info_rec.cost_fin_plan_level_code IN (COST_ONLY, COST_AND_REV_SEP */

                  IF fp_options_info_rec.fin_plan_preference_code IN
                                                     (PA_FP_CONSTANTS_PKG.G_PREF_REVENUE_ONLY,
                                                      PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SEP) THEN

                        IF fp_options_info_rec.revenue_fin_plan_level_code <>
                                                  PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

                              add_tasks_to_option (p_proj_fp_options_id => p_refresh_fp_options_tbl(j)
                                           ,p_element_type       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE
                                           ,p_tasks_tbl          => p_tasks_tbl
                                           ,x_return_status      => x_return_status
                                           ,x_msg_count          => x_msg_count
                                           ,x_msg_data           => x_msg_data);

                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                    pa_debug.g_err_stage := 'Error while adding task id to revenue option id '
                                                                                    || p_refresh_fp_options_tbl(j);
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                        END IF; /* fp_options_info_rec.fin_plan_preference_code <> 'P' */

                  END IF; /* fp_options_info_rec.revenue_fin_plan_level_code IN (REVENUE_ONLY, COST_AND_REV_SEP) */

                  IF fp_options_info_rec.fin_plan_preference_code in  (PA_FP_CONSTANTS_PKG.G_PREF_COST_AND_REV_SAME) THEN

                        IF fp_options_info_rec.all_fin_plan_level_code <>
                                                PA_FP_CONSTANTS_PKG.G_BUDGET_ENTRY_LEVEL_PROJECT THEN

                              add_tasks_to_option (p_proj_fp_options_id => p_refresh_fp_options_tbl(j)
                                                 ,p_element_type       => PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL
                                                 ,p_tasks_tbl          => p_tasks_tbl
                                                 ,x_return_status      => x_return_status
                                                 ,x_msg_count          => x_msg_count
                                                 ,x_msg_data           => x_msg_data);

                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                    pa_debug.g_err_stage := 'Error while adding task id to ALL option id '
                                                                             || p_refresh_fp_options_tbl(j);
                                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                        END IF; /* fp_options_info_rec.all_fin_plan_level_code <> 'P' */

                  END IF; /* fp_options_info_rec.fin_plan_preference_code IN (COST_AND_REV_SAME) */

            END IF; /* l_process_option = 'Y' */

      END LOOP; /* FOR j IN  p_refresh_fp_options_tbl.first .. p_refresh_fp_options_tbl.last */

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting make_new_tasks_plannable';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            pa_debug.reset_curr_function;
      END IF;


EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
           pa_debug.reset_curr_function;
     END IF;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fp_elements_pub'
                    ,p_procedure_name  => 'make_new_tasks_plannable'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
     END IF;

     RAISE;
END make_new_tasks_plannable;


/* Bug 2920954 - This API does the bulk processing necessary to add and
   remove plannable tasks as a result of  changes to the WBS. The api has
   to be called once for all impacted tasks. Impacted task here means,
   that task on which the action is taken and/or whose parent has changed. */

/* Valid values of ACTION in p_impacted_tasks_tbl are
                 'INSERT','REPARENT','DELETE'

   Please note that p_impacted_tasks_tbl has no relation to the impacted task of a CI version

   When action is 'INSERT' the plsql record should contain the following:
          Impacted_task_id,
          New_parent_task_id,
          Top_task_id
   When the action is 'REPARENT' the plsql record should contain the following:
          Impacted_task_id,
          Old_parent_task_id,
          New_parent_task_id,
          Top_task_id
   When action is 'DELETE' the plsql record should contain the following:
          Impacted_task_id,
          Old_parent_task_id,
          Top_task_id

   Assumptions:
   1. A task id cannot be present more than once as impacted_task_id in the
      p_impacted_tasks_tbl input parameter.
   2. When the action is DELETE, only the task that is deleted is passed in the
      plsql table and not all the tasks below the deleted task.
   3. The order of task records in the input plsql table p_impacted_tasks_tbl
      under a top task is same as the order of the tasks in the WBS, i.e.,
      task 2.0 would appear before any of its lowest tasks in the plsql table,
      if any. Its ok, if task 3.0 appears after task 4.0. The assumption is that
      3.1 cannot appear before 3.0.
   4. When action is INSERT and REPARENT, we assume that the operation INSERT/REPARENT
      operation has already been done for the tasks. But when action is DELETE,
      we assume that the tasks would be deleted only after the bulk api is called.
   5. This api would not be called for organization forecasting projects

   Bug 2976168. This api is NOT being called now for INSERT and REPARENT. This api will be
   called only in the case of DELETE.

*/

PROCEDURE maintain_plannable_tasks
   (p_project_id             IN   pa_projects_all.project_id%TYPE
   ,p_impacted_tasks_tbl     IN   l_impacted_task_in_tbl_typ
   ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

L_DEBUG_LEVEL2                  CONSTANT NUMBER := 2;
L_DEBUG_LEVEL3                  CONSTANT NUMBER := 3;
L_DEBUG_LEVEL4                  CONSTANT NUMBER := 4;
L_DEBUG_LEVEL5                  CONSTANT NUMBER := 5;

L_ACTION_INSERT                 CONSTANT VARCHAR2(30) := 'INSERT';
L_ACTION_REPARENT               CONSTANT VARCHAR2(30) := 'REPARENT';
L_ACTION_DELETE                 CONSTANT VARCHAR2(30) := 'DELETE';

L_TASK_LEVEL_TOP                CONSTANT VARCHAR2(1) := 'T';
L_TASK_LEVEL_MIDDLE             CONSTANT VARCHAR2(1) := 'M';
L_TASK_LEVEL_LOWEST             CONSTANT VARCHAR2(1) := 'L';

TYPE l_char_typ IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

/* Indicates if financial planning options have been setup for the project.
   0 - Financial planning option has NOT been setup for the project
   1 - Financial planning option has been created for the project
   Other numbers - Sql error  */

l_option_exists                  NUMBER;

/* Contains Y if no option exists for the project or
   p_impacted_tasks_tbl is empty */

l_continue_processing_flag       VARCHAR2(1);

/* Indicates if task has to made be plannable. Used when action is INSERT */

l_make_task_plannable        VARCHAR2(1);

/* Plsql table that contains the tasks in p_impacted_tasks_tbl
   for which child tasks exists */

l_middle_task_tbl                l_char_typ;

/* Plsql table that contains the tasks in p_impacted_tasks_tbl
   that have been made plannable */

l_task_made_plannable_tbl        l_char_typ;

/* Plsql table that contains the tasks in p_impacted_tasks_tbl
   that have been made unplannable */

l_tasks_removed_tbl              l_char_typ;

l_records_deleted                NUMBER;

/* start of Bug 3342975 */

CURSOR  check_options_exists_cur
IS
 select 1
        from   sys.dual
        where  exists
               (select 1 from pa_proj_fp_options
                where project_id = p_project_id);

/* end of Bug 3342975 */
/* The below declarations are for Bug 2976168 */

CURSOR  all_fp_options_cur
IS
SELECT  pfo.proj_fp_options_id
FROM    pa_proj_fp_options pfo
WHERE   pfo.project_id = p_project_id
AND     pfo.fin_plan_option_level_code <> PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
UNION ALL
SELECT pfo.proj_fp_options_id
FROM   pa_budget_versions bv,
       pa_proj_fp_options pfo
WHERE  bv.project_id = p_project_id
AND    pfo.fin_plan_option_level_code = PA_FP_CONSTANTS_PKG.G_OPTION_LEVEL_PLAN_VERSION
AND    bv.budget_status_code <> PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_BASELINED /* Should not modify baselined versions */
AND    pfo.project_id = bv.project_id
AND    pfo.fin_plan_type_id = bv.fin_plan_type_id
AND    pfo.fin_plan_version_id = bv.budget_version_id;

l_all_fp_options_tbl   PA_PLSQL_DATATYPES.IdTabTyp;

--If the task is not a top task , this cursor always returns L as the task level as all the middle
--level would have been eliminated by the time this cursor is opened.

CURSOR task_info_cur(c_task_id pa_tasks.task_id%TYPE) IS
SELECT  pt.top_task_id      top_task_id
       ,pt.parent_task_id   parent_task_id
       ,DECODE(c_task_id,
               pt.top_task_id,L_TASK_LEVEL_TOP,
                              L_TASK_LEVEL_LOWEST) task_level
FROM   pa_tasks pt
WHERE  pt.task_id = c_task_id;

task_info_rec task_info_cur%ROWTYPE;

l_wbs_refresh_tasks_tbl  l_wbs_refresh_tasks_tbl_typ;

/****** This is a LOCAL function to the bulk api which checks if a task is middle level task
 ****** by checking l_middle_task_tbl and then the db. */

     FUNCTION is_middle_level_task(p_task_id     pa_tasks.task_id%TYPE,
                                    p_top_task_id pa_tasks.task_id%TYPE)
                                    RETURN VARCHAR2 IS

     /* Indicates if child tasks exists for a particular task.
        0 - Child task does NOT exists
        1 - Child task exists
        Other numbers - Sql error */

     l_child_task_exists              NUMBER;

     BEGIN


          IF l_middle_task_tbl.exists(p_task_id) THEN

               /* Middle level task and this need NOT be inserted into pa_fp_elements */

               return 'N';

          ELSIF p_top_task_id = p_task_id THEN

               /* Top task needs to be processed */

               return 'Y';

          ELSE

               /* Refer db to know if the impacted_task_id is a middle level task.
                  Child exists would mean that it is a middle level task (since we have eliminated
                  top task records in the above condition). */

               l_child_task_exists := pa_task_utils.check_child_exists(x_task_id => p_task_id);

               IF l_child_task_exists = 1 THEN

                    /* Child task exists. So, impacted task is a middle level task */

                    l_middle_task_tbl(p_task_id) := 'Y';

                    return 'N';

               ELSIF l_child_task_exists = 0 THEN

                    /* Child tasks donot exists. So, the task is a lowest level task */
                    return 'Y';

               ELSE

                   /* Oracle error returned */

                    IF l_debug_mode = 'Y' THEN

                         pa_debug.g_err_stage:= 'Oracle error occurred while calling check_child_exists. Sqlerrcode ' || to_char(l_child_task_exists);
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                    END IF;

                    RAISE FND_API.G_Exc_Unexpected_Error;

               END IF; /* l_child_tasks_exists = 1 */

          END IF; /* l_middle_task_tbl.exists(p_impacted_tasks_tbl(i).impacted_task_id) */

     END is_middle_level_task;

/****** END of function is_middle_level_task which is a local procedure to maintain_plannable_tasks ******/

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'maintain_plannable_tasks',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                     L_DEBUG_LEVEL3);
     END IF;

     IF (p_project_id IS NULL) THEN

          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                           L_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     /* Checking if financial planning option have been setup for the task's project */
     /* commented for bug 3342975
     l_option_exists := pa_fin_plan_utils.Check_Proj_Fp_Options_Exists(p_project_id => p_project_id);
     start of bug 3342975
     */
      OPEN  check_options_exists_cur;
          FETCH check_options_exists_cur
          INTO l_option_exists;
            IF check_options_exists_cur%NOTFOUND THEN
             l_option_exists := 0;
           END IF;
          CLOSE check_options_exists_cur;
     /* end of bug 3342975 */
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Option Exists for project id: '
                                 || to_char(p_project_id) || ' is '
                                 || l_option_exists;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   L_DEBUG_LEVEL3);
          pa_debug.g_err_stage:= 'Number of tasks to be processed: '
                                 || to_char(p_impacted_tasks_tbl.count);
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   L_DEBUG_LEVEL3);
     END IF;

     /* No processing is required if financial planning options
        have not been setup for the project or if the i/p tasks
        plsql table is empty */

     IF l_option_exists = 0 OR p_impacted_tasks_tbl.count = 0 THEN

          l_continue_processing_flag := 'N';

     ELSIF l_option_exists = 1 THEN

          l_continue_processing_flag := 'Y';

          /* For bug 2976168. Store the options in a pl/sql table so that they can be
             passed to make_new_tasks_plannable api later. */

          OPEN  all_fp_options_cur;
          FETCH all_fp_options_cur
          BULK COLLECT INTO l_all_fp_options_tbl;
          CLOSE all_fp_options_cur;

     ELSIF l_option_exists NOT IN (1,0) THEN

          /* Unexpected oracle error */

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Check_Proj_Fp_Options_Exists returned oracle error ' ||
                                      to_char(l_option_exists);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        L_DEBUG_LEVEL5);
          END IF;

         Raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

     END IF;

     IF l_continue_processing_flag = 'Y' THEN

          /* Multiple tasks can be inserted, reparented or deleted.

             Caching is implemented so that

             1. We need not call make_new_tasks_plannable for a task that is already made plannable.
             2. We do not have to call delete_task_elements for the new parent task (to make it
                unplannable) if it has already been made unplannable.

             To achieve this check if the inserted task is a middle level task. Since middle level
             task need not be inserted, we can store middle level tasks (new_parent_task_id) in
             l_middle_task_tbl plsql table. If l_middle_task_tbl plsql table doesnt contain an
             entry for a task id, only then we refer the database to check if the task is a
             middle level task and if so, cache it in the plsql table. */

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Identifying middle level tasks by looping the p_impacted_tasks_tbl';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                        L_DEBUG_LEVEL3);
          END IF;

          FOR I in p_impacted_tasks_tbl.first .. p_impacted_tasks_tbl.last LOOP

               /* If parent task exists for impacted_task_id and
                  if impacted_task's parent is not a top task, it means
                  impacted task's parent is a middle level task */

               IF p_impacted_tasks_tbl(i).new_parent_task_id IS NOT NULL AND
                  p_impacted_tasks_tbl(i).new_parent_task_id <> p_impacted_tasks_tbl(i).top_task_id THEN

                    l_middle_task_tbl(p_impacted_tasks_tbl(i).new_parent_task_id) := 'Y';

               END IF;

          END LOOP;

          FOR I in p_impacted_tasks_tbl.first .. p_impacted_tasks_tbl.last LOOP

               IF l_debug_mode = 'Y' THEN

                    pa_debug.g_err_stage:= 'impacted task id is ' || p_impacted_tasks_tbl(i).impacted_task_id;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                    pa_debug.g_err_stage:= 'old parent task id is ' || p_impacted_tasks_tbl(i).old_parent_task_id;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                    pa_debug.g_err_stage:= 'new parent task id is ' || p_impacted_tasks_tbl(i).new_parent_task_id;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                    pa_debug.g_err_stage:= 'top task id is ' || p_impacted_tasks_tbl(i).top_task_id;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
                    pa_debug.g_err_stage:= 'action is ' || p_impacted_tasks_tbl(i).action;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

               END IF;

               l_make_task_plannable         := Null;

               IF p_impacted_tasks_tbl(i).action = L_ACTION_INSERT THEN

                    IF p_impacted_tasks_tbl(i).impacted_task_id IS NULL OR
                       (p_impacted_tasks_tbl(i).impacted_task_id <> p_impacted_tasks_tbl(i).top_task_id AND
                        p_impacted_tasks_tbl(i).new_parent_task_id IS NULL) OR
                       p_impacted_tasks_tbl(i).top_task_id IS NULL THEN

                         IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'For INSERT action : ' ||
                                                      'Impacted_task_id, New_parent_task_id, Top_task_id should be passed';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                         END IF;
                         PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                    END IF;

                    /*   If Impacted task has already been added as plannable task, we need not be
                         adding it once again */

                    IF NOT(l_task_made_plannable_tbl.exists(p_impacted_tasks_tbl(i).impacted_task_id)) THEN

                         /* Calling local function is_middle_level_task to check
                            if impacted task id is a middle level task */

                         l_make_task_plannable :=
                              is_middle_level_task(p_task_id     => p_impacted_tasks_tbl(i).impacted_task_id,
                                                   p_top_task_id => p_impacted_tasks_tbl(i).top_task_id);

                         IF l_debug_mode = 'Y' THEN

                              pa_debug.g_err_stage:= 'l_make_task_plannable = ' || l_make_task_plannable;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                         END IF;

                         IF l_make_task_plannable = 'Y' THEN

                              /*   If Impacted task has already been added as plannable task, we need not be
                                   adding it once again */

                              IF l_debug_mode = 'Y' THEN

                                   pa_debug.g_err_stage:= 'Calling make_new_tasks_plannable for impacted task id';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                              END IF;

                              /* Calling pa_fp_elements_pub.make_new_tasks_plannable for impacted task id */

                              /* For Bug 2976168. Modified the call to make new task plannable api.

                                PA_FP_ELEMENTS_PUB.make_new_task_plannable
                                  ( p_project_id    => p_project_id
                                   ,p_task_id       => p_impacted_tasks_tbl(i).impacted_task_id
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data);

                              */

                              OPEN  task_info_cur(p_impacted_tasks_tbl(i).impacted_task_id);
                              FETCH task_info_cur INTO task_info_rec;
                              CLOSE  task_info_cur;

                              l_wbs_refresh_tasks_tbl(1).task_id           := p_impacted_tasks_tbl(i).impacted_task_id;
                              l_wbs_refresh_tasks_tbl(1).parent_task_id    := task_info_rec.parent_task_id;
                              l_wbs_refresh_tasks_tbl(1).top_task_id       := task_info_rec.top_task_id;
                              l_wbs_refresh_tasks_tbl(1).task_level        := task_info_rec.task_level;

                             PA_FP_ELEMENTS_PUB.make_new_tasks_plannable
                              ( p_project_id              => p_project_id
                               ,p_tasks_tbl               => l_wbs_refresh_tasks_tbl
                               ,p_refresh_fp_options_tbl  => l_all_fp_options_tbl
                               ,x_return_status           => x_return_status
                               ,x_msg_count               => x_msg_count
                               ,x_msg_data                => x_msg_data);


                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                   IF l_debug_mode = 'Y' THEN
                                        pa_debug.g_err_stage:= 'Error returned by make_new_tasks_plannable for task_id ' ||
                                                               p_impacted_tasks_tbl(i).impacted_task_id;
                                        pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                                   END IF;

                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                              END IF;

                              l_task_made_plannable_tbl(p_impacted_tasks_tbl(i).impacted_task_id) := 'Y';

                         END IF; /* l_make_task_plannable = 'Y' */

                    END IF; /* l_task_made_plannable_tbl.exists(p_impacted_tasks_tbl(i).impacted_task_id) */

               /* For reparenting old parent need to be made plannable if its a lowest task now and
                  new parent need to be removed */

               ELSIF p_impacted_tasks_tbl(i).action = L_ACTION_REPARENT THEN

                    IF p_impacted_tasks_tbl(i).impacted_task_id IS NULL OR
                       p_impacted_tasks_tbl(i).new_parent_task_id IS NULL OR
                       p_impacted_tasks_tbl(i).old_parent_task_id IS NULL OR
                       p_impacted_tasks_tbl(i).top_task_id IS NULL THEN

                         IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'For REPARENT action : ' ||
                              'Impacted_task_id, New_parent_task_id, old_parent_task_id, Top_task_id should be passed';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                         END IF;
                         PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                    END IF;

                    /* If old parent task and new parent task are same, no need to do any processing since
                       no reparenting has happened */

                    IF p_impacted_tasks_tbl(i).old_parent_task_id <> p_impacted_tasks_tbl(i).new_parent_task_id THEN

                         /* If old parent task has already been added then
                            nothing needs to be done for this */

                         IF NOT(l_task_made_plannable_tbl.exists(p_impacted_tasks_tbl(i).old_parent_task_id)) THEN

                              /* Calling is_middle_level_task to check if old parent task id is a middle level task */

                              l_make_task_plannable :=
                                   is_middle_level_task(p_task_id     => p_impacted_tasks_tbl(i).old_parent_task_id,
                                                        p_top_task_id => pa_task_utils.get_top_task_id(x_task_id => p_impacted_tasks_tbl(i).old_parent_task_id));

                              IF l_debug_mode = 'Y' THEN

                                   pa_debug.g_err_stage:= 'l_make_task_plannable = ' || l_make_task_plannable;
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                              END IF;

                              /* If old task is a middle level task then
                                 nothing needs to be done for this */

                              IF l_make_task_plannable = 'Y' THEN

                                   IF l_debug_mode = 'Y' THEN

                                        pa_debug.g_err_stage:= 'Calling make_new_tasks_plannable for old parent task id';
                                        pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                                   END IF;

                                   /* Calling pa_fp_elements_pub.make_new_tasks_plannable for old parent task id */

                                   /* Bug 2976168. Changed the way make_new_task_plannable is called

                                   PA_FP_ELEMENTS_PUB.make_new_task_plannable
                                       ( p_project_id    => p_project_id
                                        ,p_task_id       => p_impacted_tasks_tbl(i).old_parent_task_id
                                        ,x_return_status => x_return_status
                                        ,x_msg_count     => x_msg_count
                                        ,x_msg_data      => x_msg_data);
                                   */

                                   OPEN  task_info_cur(p_impacted_tasks_tbl(i).old_parent_task_id);
                                   FETCH task_info_cur INTO task_info_rec;
                                   CLOSE  task_info_cur;

                                   l_wbs_refresh_tasks_tbl(1).task_id           := p_impacted_tasks_tbl(i).old_parent_task_id;
                                   l_wbs_refresh_tasks_tbl(1).parent_task_id    := task_info_rec.parent_task_id;
                                   l_wbs_refresh_tasks_tbl(1).top_task_id       := task_info_rec.top_task_id;
                                   l_wbs_refresh_tasks_tbl(1).task_level        := task_info_rec.task_level;

                                   PA_FP_ELEMENTS_PUB.make_new_tasks_plannable
                                   ( p_project_id              => p_project_id
                                    ,p_tasks_tbl               => l_wbs_refresh_tasks_tbl
                                    ,p_refresh_fp_options_tbl  => l_all_fp_options_tbl
                                    ,x_return_status           => x_return_status
                                    ,x_msg_count               => x_msg_count
                                    ,x_msg_data                => x_msg_data);

                                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                        IF l_debug_mode = 'Y' THEN
                                             pa_debug.g_err_stage:= 'Error returned by make_new_tasks_plannable for task_id ' ||
                                                                    p_impacted_tasks_tbl(i).old_parent_task_id;
                                             pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                                        END IF;

                                        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                                   END IF;

                                   l_task_made_plannable_tbl(p_impacted_tasks_tbl(i).old_parent_task_id) := 'Y';

                              END IF; /* l_make_task_plannable = 'Y' */

                         END IF; /* NOT(l_task_made_plannable_tbl.exists(p_impacted_tasks_tbl(i).old_parent_task_id)) THEN */

                         /* Note for removing new parent as plannable:

                            1. If it was a Top task earlier then no action required as none of its attribute changes.
                            2. If it was a middle level task earlier then also no action required.
                            3. New parent need to be removed from all options only if it was a lowest task earlier.

                            Only way to know if the task was earlier a lowest task can be to look into any of the
                            existing option and see if this is plannable. */

                         IF NOT(l_tasks_removed_tbl.exists(p_impacted_tasks_tbl(i).new_parent_task_id)) THEN

                              /* Check if new_parent_task_id is not a TOP task */

                              IF pa_task_utils.get_top_task_id(x_task_id => p_impacted_tasks_tbl(i).new_parent_task_id)
                                 <> p_impacted_tasks_tbl(i).new_parent_task_id THEN

                                   /* Check if it exists in pa_fp_elements. If yes, then its a lowest task */

                                   IF pa_fin_plan_utils.check_task_in_fp_option(p_task_id => p_impacted_tasks_tbl(i).new_parent_task_id) = 'Y' THEN
                                        /* Delete planning elements and resource assignments for new parent task id.
                                           Pls note that delete task elements deletes the task and its children from
                                           all plan options. Hence we cannot call it since it might delete a
                                           plannable impacted task also from pa_fp_elements and pa_resource_assignments */

                                        IF l_debug_mode = 'Y' THEN

                                             pa_debug.g_err_stage:= 'Deleting task fp elements for new parent task id';
                                             pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                                        END IF;

                                        DELETE FROM pa_fp_elements e
                                        WHERE  e.task_id  = p_impacted_tasks_tbl(i).new_parent_task_id;

                                        l_records_deleted := sql%rowcount;

                                        IF l_debug_mode = 'Y' THEN
                                             pa_debug.g_err_stage:= To_char(l_records_deleted) || ' records deleted.';
                                             pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                                        L_DEBUG_LEVEL3);
                                        END IF;

                                        IF l_records_deleted <> 0 THEN

                                             IF l_debug_mode = 'Y' THEN
                                                  pa_debug.g_err_stage:= 'Deleting from pa_resource_assignments for task id ' || to_char(p_impacted_tasks_tbl(i).new_parent_task_id);
                                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                                             L_DEBUG_LEVEL3);
                                             END IF;

                                             DELETE FROM pa_resource_assignments r
                                             WHERE r.task_id = p_impacted_tasks_tbl(i).new_parent_task_id;

                                             l_records_deleted := sql%rowcount;

                                             IF l_debug_mode = 'Y' THEN
                                                  pa_debug.g_err_stage:= To_char(l_records_deleted) || ' records deleted.';
                                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                                                           L_DEBUG_LEVEL3);
                                             END IF;

                                        END IF;

                                        l_tasks_removed_tbl(p_impacted_tasks_tbl(i).new_parent_task_id) := 'Y';

                                   END IF; /* pa_fin_plan_utils.task_exists_in_option(p_task_id => p_impacted_tasks_tbl(i).new_parent_task_id) = 'Y' */

                              END IF; /* pa_task_utils.get_top_task_id(x_task_id => p_impacted_tasks_tbl(i).new_parent_task_id)
                                              <> p_impacted_tasks_tbl(i).new_parent_task_id  */

                         END IF; /* l_tasks_removed_tbl.exists(p_impacted_tasks_tbl(i).new_parent_task_id) */

                    END IF; /* p_impacted_tasks_tbl(i).old_parent_task_id <> p_impacted_tasks_tbl(i).new_parent_task_id */

               ELSIF p_impacted_tasks_tbl(i).action = L_ACTION_DELETE THEN

                    IF p_impacted_tasks_tbl(i).impacted_task_id IS NULL OR
                       (p_impacted_tasks_tbl(i).impacted_task_id <> p_impacted_tasks_tbl(i).top_task_id AND
                        p_impacted_tasks_tbl(i).old_parent_task_id IS NULL) OR
                         p_impacted_tasks_tbl(i).top_task_id IS NULL THEN

                         IF l_debug_mode = 'Y' THEN
                               pa_debug.g_err_stage:= 'For DELETE action : ' ||
                                                      'Impacted_task_id, old_parent_task_id, Top_task_id should be passed';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                         END IF;
                         PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                    END IF;

                    /* If impacted task has already been deleted then
                       nothing needs to be done for this */

                    IF NOT(l_tasks_removed_tbl.exists(p_impacted_tasks_tbl(i).impacted_task_id)) THEN

                         IF l_debug_mode = 'Y' THEN

                              pa_debug.g_err_stage:= 'Calling delete_task_elements for impacted task id';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                         END IF;

                         /* Calling pa_fp_elements_pub.delete_task_elements for impacted task id */
                         PA_FP_ELEMENTS_PUB.Delete_task_elements
                           (  p_task_id       => p_impacted_Tasks_tbl(i).impacted_task_id
                             ,x_return_status => x_return_status
                             ,x_msg_count     => x_msg_count
                             ,x_msg_data      => x_msg_data);

                         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                              IF l_debug_mode = 'Y' THEN
                                   pa_debug.g_err_stage:= 'Error returned by delete_task_elements for task_id ' ||
                                                         p_impacted_tasks_tbl(i).impacted_task_id;
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                             END IF;

                             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                         END IF;

                         l_tasks_removed_tbl(p_impacted_tasks_tbl(i).impacted_task_id) := 'Y';

                    END IF; /* NOT(l_tasks_removed_tbl.exists(p_impacted_tasks_tbl(i).impacted_task_id)) */

                    /* Proceed only if old_parent_task_id has NOT already been added */

                    IF p_impacted_tasks_tbl(i).old_parent_task_id IS NOT NULL AND
                       NOT(l_task_made_plannable_tbl.exists(p_impacted_tasks_tbl(i).old_parent_task_id)) THEN

                         /* We should not make the old_parent_task a plannable task if it is middle level task */
                         /* Since tasks would not have yet been deleted, we need to check if the new parent would
                            still be a middle level task after the impacted task id is deleted */

                         DECLARE
                              cursor c1 is
                              select 'N'
                              from sys.dual
                              where exists (SELECT null
                                            FROM pa_tasks
                                            where parent_task_id = p_impacted_tasks_tbl(i).old_parent_task_id
                                            and   task_id <> p_impacted_tasks_tbl(i).impacted_task_id);
                         BEGIN
                               OPEN c1;
                               FETCH c1 into l_make_task_plannable;
                               IF c1%NOTFOUND THEN
                                    l_make_task_plannable := 'Y';
                               END IF;
                               CLOSE c1;
                         END;

                         IF l_debug_mode = 'Y' THEN

                              pa_debug.g_err_stage:= 'l_make_task_plannable = ' || l_make_task_plannable;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                         END IF;

                         /* We need to call make new task plannable to add the old parent task id as plannable */

                         IF l_make_task_plannable = 'Y' THEN

                              IF l_debug_mode = 'Y' THEN

                                  pa_debug.g_err_stage:= 'Calling make_new_tasks_plannable for old parent task id';
                                           pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);

                             END IF;

                              /*
                              Bug 2976168. Changed the way make_new_task_plannable is called

                              PA_FP_ELEMENTS_PUB.make_new_task_plannable
                                  ( p_project_id    => p_project_id
                                   ,p_task_id       => p_impacted_tasks_tbl(i).old_parent_task_id
                                   ,x_return_status => x_return_status
                                   ,x_msg_count     => x_msg_count
                                   ,x_msg_data      => x_msg_data);
                              */

                             OPEN  task_info_cur(p_impacted_tasks_tbl(i).impacted_task_id);
                             FETCH task_info_cur INTO task_info_rec;
                             CLOSE  task_info_cur;

                             l_wbs_refresh_tasks_tbl(1).task_id           := p_impacted_tasks_tbl(i).impacted_task_id;
                             l_wbs_refresh_tasks_tbl(1).parent_task_id    := task_info_rec.parent_task_id;
                             l_wbs_refresh_tasks_tbl(1).top_task_id       := task_info_rec.top_task_id;
                             l_wbs_refresh_tasks_tbl(1).task_level        := task_info_rec.task_level;

                             PA_FP_ELEMENTS_PUB.make_new_tasks_plannable
                             ( p_project_id              => p_project_id
                              ,p_tasks_tbl               => l_wbs_refresh_tasks_tbl
                              ,p_refresh_fp_options_tbl  => l_all_fp_options_tbl
                              ,x_return_status           => x_return_status
                              ,x_msg_count               => x_msg_count
                              ,x_msg_data                => x_msg_data);

                             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                                   IF l_debug_mode = 'Y' THEN
                                        pa_debug.g_err_stage:= 'Error returned by make_new_tasks_plannable for task_id ' ||
                                                               p_impacted_tasks_tbl(i).old_parent_task_id;
                                        pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                                   END IF;

                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

                             END IF;

                             l_task_made_plannable_tbl(p_impacted_tasks_tbl(i).old_parent_task_id) := 'Y';

                         END IF; /* l_make_task_plannable = 'Y' */

                    END IF; /* p_impacted_tasks_tbl(i).old_parent_task_id IS NOT NULL AND
                               NOT(l_task_made_plannable_tbl(p_impacted_tasks_tbl(i).old_parent_task_id).exists) */

               ELSE

                    /* Invalid action passed */

                    IF l_debug_mode = 'Y' THEN
                         pa_debug.g_err_stage:= 'Invalid value for action passed. Action passed is ' ||
                                                p_impacted_tasks_tbl(i).action;
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
                    END IF;

                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

               END IF;

          END LOOP;

          /* Since planning elements have been modified for the proj fp option,
             we need to increase the record_version_number */

          IF nvl(l_all_fp_options_tbl.last,0) >= 1 THEN /* only if something is fetched */

               IF P_PA_DEBUG_MODE = 'Y' THEN
                    pa_debug.g_err_stage := 'Updating pa_proj_fp_options with RVN and who columns.';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
               END IF;

               FORALL i in l_all_fp_options_tbl.first..l_all_fp_options_tbl.last
                    UPDATE pa_proj_fp_options pfo
                    SET    pfo.record_version_number = pfo.record_version_number + 1,
                           pfo.last_update_date = sysdate,
                           pfo.last_updated_by = FND_GLOBAL.USER_ID,
                           pfo.last_update_login = FND_GLOBAL.LOGIN_ID
                    WHERE  pfo.proj_fp_options_id = l_all_fp_options_tbl(i);

               /* Since resource assignments might have been deleted and recreated
                  for the new task, the version has been modified and its
                  record version number has to be increased */

               FORALL i in l_all_fp_options_tbl.first..l_all_fp_options_tbl.last
                    UPDATE pa_budget_versions bv
                    SET    bv.record_version_number = bv.record_version_number + 1,
                           bv.last_update_date = sysdate,
                           bv.last_updated_by = FND_GLOBAL.USER_ID,
                           bv.last_update_login = FND_GLOBAL.LOGIN_ID
                    WHERE  bv.budget_version_id in (SELECT pfo.fin_plan_version_id
                                                    FROM   pa_proj_fp_options pfo
                                                    WHERE  pfo.proj_fp_options_id = l_all_fp_options_tbl(i));

          END IF; /* nvl(l_all_fp_options_tbl.last,0) >= 1 */

     END IF; /* l_continue_processing_flag = 'Y' */

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting maintain_plannable_tasks';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                                   L_DEBUG_LEVEL3);
          pa_debug.reset_curr_function;
     END IF;

EXCEPTION

WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              L_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fp_elements_pub'
                    ,p_procedure_name  => 'maintain_plannable_tasks'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              L_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END maintain_plannable_tasks;

End PA_FP_ELEMENTS_PUB;

/

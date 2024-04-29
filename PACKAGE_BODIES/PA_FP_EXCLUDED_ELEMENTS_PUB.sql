--------------------------------------------------------
--  DDL for Package Body PA_FP_EXCLUDED_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_EXCLUDED_ELEMENTS_PUB" as
/* $Header: PAFPXEPB.pls 120.1 2005/08/19 16:32:15 mwasowic noship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PA_FP_EXCLUDED_ELEMENTS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PAFPXEPB.pls';

--This api will creates record for  p_to_proj_fp_options_id in pa_fp_excluded_elements copying
--them from those of p_from_proj_fp_options_id. If the project ids are different for the two
--options the records are mapped based on task numbers.
PROCEDURE  Copy_Excluded_Elements
( p_from_proj_fp_options_id       IN  pa_proj_fp_options.proj_fp_options_id%TYPE
 ,p_from_element_type             IN  pa_fp_elements.element_type%TYPE
 ,p_to_proj_fp_options_id         IN  pa_proj_fp_options.proj_fp_options_id%TYPE
 ,p_to_element_type               IN  pa_fp_elements.element_type%TYPE
 ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

CURSOR fp_options_info_cur
      (c_proj_fp_options_id pa_proj_fp_options.proj_fp_options_id%TYPE)
IS
SELECT project_id
      ,fin_plan_type_id
      ,fin_plan_version_id
FROM   pa_proj_fp_options
WHERE  proj_fp_options_id = c_proj_fp_options_id;
l_from_fp_option_info_rec         fp_options_info_cur%ROWTYPE;
l_to_fp_option_info_rec           fp_options_info_cur%ROWTYPE;

l_from_project_id                 pa_projects_all.project_id%TYPE;
l_to_project_id                   pa_projects_all.project_id%TYPE;

--Declare the variables which are required as a standard
l_msg_count                       NUMBER := 0;
l_data                            VARCHAR2(2000);
l_msg_data                        VARCHAR2(2000);
l_msg_index_out                   NUMBER;
l_debug_mode                      VARCHAR2(1);

L_DEBUG_LEVEL3                    CONSTANT NUMBER   := 3;
L_DEBUG_LEVEL5                    CONSTANT NUMBER   := 5;
L_PROCEDURE_NAME                  CONSTANT VARCHAR2(100) :='Copy_Excluded_Elements: '||
                                                         G_PKG_NAME ;
BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function    => 'Copy_Excluded_Elements',
                                         p_debug_mode => l_debug_mode );
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Validating input parameters';
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
      END IF;

      IF p_from_proj_fp_options_id    IS NULL OR
         p_from_element_type          IS NULL OR
         p_to_proj_fp_options_id      IS NULL OR
         p_to_element_type            IS NULL
      THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_from_proj_fp_options_id = '|| p_from_proj_fp_options_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_from_element_type = '|| p_from_element_type;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_to_proj_fp_options_id = '|| p_to_proj_fp_options_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);

                  pa_debug.g_err_stage:= 'p_to_element_type = '|| p_to_element_type;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;

      --Get the Details of the source and target option Ids
      OPEN  fp_options_info_cur(p_from_proj_fp_options_id);
      FETCH fp_options_info_cur INTO l_from_fp_option_info_rec;
      IF fp_options_info_cur%NOTFOUND THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_from_proj_fp_options_id  '|| p_from_proj_fp_options_id
                                           ||' is invalid ';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            END IF;
            CLOSE fp_options_info_cur;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      CLOSE fp_options_info_cur;

      OPEN  fp_options_info_cur(p_to_proj_fp_options_id);
      FETCH fp_options_info_cur INTO l_to_fp_option_info_rec;
      IF fp_options_info_cur%NOTFOUND THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_to_proj_fp_options_id  '|| p_to_proj_fp_options_id
                                           ||' is invalid ';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            END IF;
            CLOSE fp_options_info_cur;
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;

      END IF;
      CLOSE fp_options_info_cur;

      IF l_from_fp_option_info_rec.project_id = l_to_fp_option_info_rec.project_id THEN

            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'project ids are same. inserting into excluded elements';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            INSERT INTO pa_fp_excluded_elements
                       ( proj_fp_options_id
                        ,project_id
                        ,fin_plan_type_id
                        ,element_type
                        ,fin_plan_version_id
                        ,task_id
                        ,record_version_number
                        ,last_update_date
                        ,last_updated_by
                        ,creation_date
                        ,created_by
                        ,last_update_login)
                 SELECT  p_to_proj_fp_options_id                     proj_fp_options_id
                        ,l_to_fp_option_info_rec.project_id          project_id
                        ,l_to_fp_option_info_rec.fin_plan_type_id    fin_plan_type_id
                        ,DECODE( p_to_element_type,
                                                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,ee.element_type,
                                                                                           p_to_element_type)
                        ,l_to_fp_option_info_rec.fin_plan_version_id fin_plan_version_id
                        ,ee.task_id                                  task_id
                        ,1                                           record_version_number
                        ,sysdate                                     last_update_date
                        ,fnd_global.user_id                          last_updated_by
                        ,sysdate                                     creation_date
                        ,fnd_global.user_id                          created_by
                        ,fnd_global.login_id                         last_update_login
                 FROM
                         pa_fp_excluded_elements  ee
                 WHERE   ee.proj_fp_options_id = p_from_proj_fp_options_id
                 AND     ee.element_type = DECODE( p_from_element_type,
                                                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,ee.element_type,
                                                                                           p_from_element_type);

      ELSE
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'project ids are DIFFERENT. inserting into excluded elements';
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL3);
            END IF;

            --Map the tasks from source to project using the task number.
            INSERT INTO pa_fp_excluded_elements
                       ( proj_fp_options_id
                        ,project_id
                        ,fin_plan_type_id
                        ,element_type
                        ,fin_plan_version_id
                        ,task_id
                        ,record_version_number
                        ,last_update_date
                        ,last_updated_by
                        ,creation_date
                        ,created_by
                        ,last_update_login)
                 SELECT  p_to_proj_fp_options_id                     proj_fp_options_id
                        ,l_to_fp_option_info_rec.project_id          project_id
                        ,l_to_fp_option_info_rec.fin_plan_type_id    fin_plan_type_id
                        ,DECODE( p_to_element_type,
                                                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,ee.element_type,
                                                                                           p_to_element_type)
                        ,l_to_fp_option_info_rec.fin_plan_version_id fin_plan_version_id
                        ,target_pt.task_id                           task_id
                        ,1                                           record_version_number
                        ,sysdate                                     last_update_date
                        ,fnd_global.user_id                          last_updated_by
                        ,sysdate                                     creation_date
                        ,fnd_global.user_id                          created_by
                        ,fnd_global.login_id                         last_update_login
                 FROM    pa_fp_excluded_elements ee,
                         pa_tasks  source_pt,
                         pa_tasks  target_pt
                 WHERE   proj_fp_options_id = p_from_proj_fp_options_id
                 AND     target_pt.project_id = l_to_fp_option_info_rec.project_id
                 AND     ee.element_type = DECODE( p_from_element_type,
                                                   PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_BOTH,ee.element_type,
                                                                                           p_from_element_type)
                 AND     source_pt.task_id = ee.task_id
                 AND     target_pt.task_number = source_pt.task_number;

      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Exiting Copy_Excluded_Elements';
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
                   ( p_pkg_name        => G_PKG_NAME
                    ,p_procedure_name  => 'Copy_Excluded_Elements'
                    ,p_error_text      => x_msg_data);

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
            pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,L_DEBUG_LEVEL5);
            pa_debug.reset_curr_function;
      END IF;
      RAISE;
END Copy_Excluded_Elements;

/*==================================================================
  This api is called to delete all the tasks that are made plannable
  while copying actuals etc., from pa_fp_excluded_elements.
 ==================================================================*/

PROCEDURE Synchronize_Excluded_Elements
   (  p_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
     ,p_element_type          IN   pa_fp_elements.element_type%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_procedure_name       CONSTANT VARCHAR2(100) :='Synchronize_Excluded_Elements: '||G_PKG_NAME ;

BEGIN
      x_msg_count := 0;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      PA_DEBUG.Set_Curr_Function( p_function   => 'Synchronize_Excluded_Elements',
                                  p_debug_mode => l_debug_mode );

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Inside Synchronize_Excluded_Elements';
              pa_debug.write(l_procedure_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
      END IF;


      -- Check for NOT NULL parameters

      IF (p_proj_fp_options_id IS NULL) OR (p_element_type IS NULL)
      THEN
            IF l_debug_mode = 'Y' THEN
                pa_debug.g_err_stage:= 'p_proj_fp_options_id = '|| p_proj_fp_options_id;
                pa_debug.write(l_procedure_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'p_element_type = '|| p_element_type;
                pa_debug.write(l_procedure_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
                pa_debug.g_err_stage:= 'Invalid Arguments Passed';
                pa_debug.write(l_procedure_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
            PA_UTILS.ADD_MESSAGE
                   (p_app_short_name => 'PA',
                    p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;

      /*
       * Delete all the tasks that are made plannable from
       * pa_fp_excluded_elements
       * Note: Please note that
       */
      DELETE FROM pa_fp_excluded_elements fee
      WHERE  fee.proj_fp_options_id = p_proj_fp_options_id
        AND  fee.element_type       = p_element_type
        AND  fee.task_id IN (SELECT pfe.task_id
                               FROM pa_fp_elements pfe
                              WHERE pfe.proj_fp_options_id = p_proj_fp_options_id
                                AND pfe.element_type       = p_element_type
                                AND pfe.plannable_flag     = 'Y'
                                AND pfe.resource_list_member_id = 0);

      IF l_debug_mode = 'Y' THEN
              pa_debug.g_err_stage:= 'Exiting Synchronize_Excluded_Elements';
              pa_debug.write(l_procedure_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
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
                          ( p_pkg_name        => G_PKG_NAME
                           ,p_procedure_name  => 'Synchronize_Excluded_Elements'
                           ,p_error_text      => sqlerrm);
          pa_debug.reset_curr_function;
          RAISE;
END Synchronize_Excluded_Elements;

/* Called from setup pages to delete from pa_fp_excluded_elements when a task element is
   made plannable. If the task element is not present in pa_fp_excluded_elements, the
   delete_Row table handler is not called */

PROCEDURE Delete_Excluded_Elements
     ( p_proj_fp_options_id    IN   pa_fp_excluded_elements.proj_fp_options_id%TYPE
      ,p_element_type          IN   pa_fp_excluded_elements.element_type%TYPE
      ,p_task_id               IN   pa_fp_excluded_elements.task_id%TYPE
      ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data              OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode 			       VARCHAR2(1);

L_DEBUG_LEVEL2                  CONSTANT NUMBER := 2;
L_DEBUG_LEVEL3                  CONSTANT NUMBER := 3;
L_DEBUG_LEVEL4                  CONSTANT NUMBER := 4;
L_DEBUG_LEVEL5                  CONSTANT NUMBER := 5;
L_PROCEDURE_NAME                CONSTANT VARCHAR2(100) := 'Pa_Fp_Excluded_Elements_Pkg.Delete_Excluded_Elements';

CURSOR cur_excl_elems IS
SELECT rowid
FROM   pa_fp_excluded_elements
WHERE  proj_fp_options_id = p_proj_fp_options_id
AND    element_type = p_element_type
AND    task_id = p_task_id;

excl_elems_rec                 cur_excl_elems%ROWTYPE;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'Delete_Excluded_Elements',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                     L_DEBUG_LEVEL3);
     END IF;

     IF (p_proj_fp_options_id IS NULL) OR
        (p_element_type IS NULL) OR
        (p_task_id IS NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'p_proj_fp_options_id = '|| p_proj_fp_options_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                           L_DEBUG_LEVEL5);
                  pa_debug.g_err_stage:= 'p_element_type = '|| p_element_type;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                           L_DEBUG_LEVEL5);
                  pa_debug.g_err_stage:= 'p_task_id = '|| p_task_id;
                  pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                           L_DEBUG_LEVEL5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                 p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_Constants_Pkg.Invalid_Arg_Exc;

     END IF;

     OPEN cur_excl_elems;
     FETCH cur_excl_elems INTO excl_elems_rec;

     /* Record to be deleted doesnt exists and no need to call delete_row table handler */

     IF cur_excl_elems%FOUND THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:= 'Calling PA_FP_EXCLUDED_ELEMENTS_PKG.DELETE_ROW...';
               pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                          L_DEBUG_LEVEL3);
          END IF;

          PA_FP_EXCLUDED_ELEMENTS_PKG.DELETE_ROW(
                p_row_id                      => excl_elems_rec.rowid,
                x_return_status               => x_return_status);

          IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage:= 'Error returned by PA_FP_EXCLUDED_ELEMENTS_PKG.DELETE_ROW';
                    pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                               L_DEBUG_LEVEL5);
               END IF;
               CLOSE cur_excl_elems;
               RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

     END IF;

     CLOSE cur_excl_elems;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Exiting Delete_Excluded_Elements';
          pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                                   L_DEBUG_LEVEL3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Pa_Fp_Constants_Pkg.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF cur_excl_elems%ISOPEN THEN
          CLOSE cur_excl_elems;
     END IF;

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

     IF cur_excl_elems%ISOPEN THEN
          CLOSE cur_excl_elems;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'pa_fp_excluded_elements_pub'
                    ,p_procedure_name  => 'Delete_Excluded_Elements'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(L_PROCEDURE_NAME,pa_debug.g_err_stage,
                              L_DEBUG_LEVEL5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END Delete_Excluded_Elements;

END pa_fp_excluded_elements_pub;

/

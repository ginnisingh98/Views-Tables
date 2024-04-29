--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUC_MAPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUC_MAPPING_PUB" AS
/* $Header: PAPSMPPB.pls 120.1.12010000.2 2009/07/28 09:53:06 jravisha ship $ */

g_module_name   VARCHAR2(100) := 'PA_PROJ_STRUC_MAPPING_PUB';
Invalid_Arg_Exc_WP Exception;

-- Procedure            : DELETE_MAPPING
-- Type                 : Public Procedure
-- Purpose              : This API will be called from task details relationships sub tab.
--                      : This will be called when the user clicks on the delete icon
--                      : in the mapping region of the fin task details page
-- Note                 : This API can work in 3 modes.
--                      : --If both WkpTask ID and Fin Task ID are passed --- The correspondinf mapping is removed
--                      : --Only FP task id is passed. --- All the mapping for this FP task id will be removed
--                      : --Only WP task id is passed. --- The mapping corresponding to this Wkp Task ID will be removed
--                      : The parameter p_wp_from_task_name is  not used currently but will be used in future.
--                      :
-- Assumptions          :

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_wp_from_task_name          VARCHAR2   NO            Indicates the workplan tasks name. This can be a string of workplan tasks.
-- p_wp_task_version_id         NUMBER     NO            Task Version ID of workplan task for which mapping needs to be deleted.
-- p_fp_task_version_id         NUMEBR     NO            Task Version ID of Financial Task for which mapping needs to be deleted.

PROCEDURE DELETE_MAPPING
    (
       p_api_version           IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_record_version_number IN   NUMBER   := FND_API.G_MISS_NUM
     , p_wp_from_task_name     IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_task_version_id    IN   NUMBER := FND_API.G_MISS_NUM
     , p_fp_task_version_id    IN   NUMBER := FND_API.G_MISS_NUM
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2         --File.Sql.39 bug 4440895
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_object_relationship_id        NUMBER;
l_rec_version_num                       NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;


--This cursor selects relationship id, record version number from pa_object_relationship for the passed work plan task id
CURSOR c_get_mapping_frm_wp_task (l_wp_task_version_id NUMBER)
IS
SELECT
        obj.object_relationship_id
      , obj.record_version_number
FROM
     PA_OBJECT_RELATIONSHIPS obj
WHERE obj.object_id_from1 = l_wp_task_version_id
AND obj.relationship_type='M';

--This cursor selects relationship id , record version number from pa_object_relationship for the passed work plan and financial task
--This will return more than a row
CURSOR c_get_mapping_frm_fp_task ( l_fp_task_version_id NUMBER)
IS
SELECT
       object_relationship_id
     , record_version_number
FROM
     PA_OBJECT_RELATIONSHIPS
WHERE
    object_id_to1 = l_fp_task_version_id
AND relationship_type='M';

--This cursor selects relationship id ,record version number from pa_object_relationship for the passed WP task id and FP task id
CURSOR c_get_mapping_frm_wp_fp_task (l_wp_task_version_id NUMBER , l_fp_task_version_id NUMBER)
IS
SELECT
        obj.object_relationship_id
      , obj.record_version_number
FROM
     PA_OBJECT_RELATIONSHIPS obj
WHERE obj.object_id_from1 = l_wp_task_version_id
AND   obj.object_id_to1 = l_fp_task_version_id
AND   obj.relationship_type='M';

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_MAPPING',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_from_task_name'||':'||p_wp_from_task_name,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_task_version_id'||':'||p_wp_task_version_id,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_fp_task_version_id'||':'||p_fp_task_version_id,
                                     l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_MAPPING_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (
          ( p_wp_task_version_id IS NULL OR p_wp_task_version_id = FND_API.G_MISS_NUM ) AND
          ( p_fp_task_version_id IS NULL OR p_fp_task_version_id = FND_API.G_MISS_NUM )
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Both p_wp_task_version_id and p_fp_task_version_id are null';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;
      --Following is added to implement locking
      -- If both WP task ID and FP Task ID are passed from self service
      IF ( ( p_wp_task_version_id IS NOT NULL AND p_wp_task_version_id <> FND_API.G_MISS_NUM )
           AND
           ( p_fp_task_version_id IS NOT NULL AND p_fp_task_version_id <> FND_API.G_MISS_NUM )
         )
      THEN
          --Get the object_relationship_id
           OPEN  c_get_mapping_frm_wp_fp_task ( p_wp_task_version_id , p_fp_task_version_id );
           FETCH c_get_mapping_frm_wp_fp_task INTO l_object_relationship_id , l_rec_version_num ;
           -- If no row found
          -- Raise exception and populate error message
           IF ( c_get_mapping_frm_wp_fp_task%NOTFOUND )
           THEN
               IF l_debug_mode = 'Y' THEN
                    Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : No Mapping Exists';
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
               END IF;
	       -- Bug 4142254 : Record has been changes error make sense for Self Service, but from AMG
	       -- it should be "Mapping does not exist between the given tasks."
	       IF p_calling_module = 'AMG' THEN
	               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_TASK_MAPPING_NOT_EXIST' );
		       RAISE FND_API.G_EXC_ERROR ;
		ELSE
	               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_RECORD_CHANGED' );
		       RAISE FND_API.G_EXC_ERROR ;
		END IF;
           END IF;
           CLOSE c_get_mapping_frm_wp_fp_task;
          -- if any row found, delete the row
           IF (l_object_relationship_id IS NOT NULL)
           THEN
                IF l_debug_mode = 'Y' THEN
                    Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Calling delete';
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
                END IF;

               -- Call public API for deleting the relationship

                PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP
                (
                   p_api_version             => p_api_version
                 , p_init_msg_list           => FND_API.G_FALSE
                 , p_commit                  => p_commit
                 , p_validate_only           => p_validate_only
                 , p_calling_module          => 'SELF_SERVICE'
                 , p_debug_mode              => l_debug_mode
                 , p_object_relationship_id  => l_object_relationship_id
                 , p_record_version_number   => l_rec_version_num
                 , x_return_status           => x_return_status
                 , x_msg_count               => x_msg_count
                 , x_msg_data                => x_msg_data
                 );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;

      -- If the WP task ID is not NULL, get the relationship ID and delete mapping
      ELSIF (p_wp_task_version_id IS NOT NULL AND p_wp_task_version_id <> FND_API.G_MISS_NUM )
      THEN
           OPEN  c_get_mapping_frm_wp_task ( p_wp_task_version_id );
           FETCH c_get_mapping_frm_wp_task INTO l_object_relationship_id , l_rec_version_num ;
           CLOSE c_get_mapping_frm_wp_task;

           IF (l_object_relationship_id IS NOT NULL)
           THEN
                IF l_debug_mode = 'Y' THEN
                    Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Calling delete';
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
                END IF;

               -- Call public API for deleting the relationship

                PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP
                (
                   p_api_version             => p_api_version
                 , p_init_msg_list           => FND_API.G_FALSE
                 , p_commit                  => p_commit
                 , p_validate_only           => p_validate_only
                 , p_calling_module          => 'SELF_SERVICE'
                 , p_debug_mode              => l_debug_mode
                 , p_object_relationship_id  => l_object_relationship_id
                 , p_record_version_number   => l_rec_version_num
                 , x_return_status           => x_return_status
                 , x_msg_count               => x_msg_count
                 , x_msg_data                => x_msg_data
                 );

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

          ELSE
                    IF l_debug_mode = 'Y' THEN
                         Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : Mapping does not exist for the passed WP task ID';
                         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                 l_debug_level3);
                    END IF;
          END IF;--IF (l_object_relationship_id IS NOT NULL) ENDS


      -- If financial task id is passed get the mapping with FP task id
      ELSIF ( p_fp_task_version_id IS NOT NULL AND p_fp_task_version_id <> FND_API.G_MISS_NUM )
          THEN
               FOR map_rec IN c_get_mapping_frm_fp_task ( p_fp_task_version_id ) LOOP

                    PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP
                     (
                             p_api_version             => p_api_version
                           , p_init_msg_list           => FND_API.G_FALSE
                           , p_commit                  => p_commit
                           , p_validate_only           => p_validate_only
                           , p_calling_module          => 'SELF_SERVICE'
                           , p_debug_mode              => l_debug_mode
                           , p_object_relationship_id  => map_rec.object_relationship_id
                           , p_record_version_number   => map_rec.record_version_number
                           , x_return_status           => x_return_status
                           , x_msg_count               => x_msg_count
                           , x_msg_data                => x_msg_data
                      );
                     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                     THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

               END LOOP;
      END IF;


 IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
 END IF;


EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_MAPPING_PUBLIC;
     END IF;

     IF c_get_mapping_frm_wp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_wp_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_fp_task;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_MAPPING : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_MAPPING_PUBLIC;
     END IF;
     IF c_get_mapping_frm_wp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_wp_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_fp_task;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'DELETE_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_MAPPING_PUBLIC;
     END IF;

     IF c_get_mapping_frm_wp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_task;
     END IF;

     IF c_get_mapping_frm_wp_fp_task%ISOPEN THEN
        CLOSE c_get_mapping_frm_wp_fp_task;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'DELETE_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_MAPPING ;

-- Procedure            : CREATE_MAPPING
-- Type                 : Public Procedure
-- Purpose              : This API will be used to create the mapping for the passed tasks.
--                      : This will be called from Create Mapping pages.
--                      : This will also be called from update_mapping api.
-- Note                 : Using the two task IDs as input, the mapping is created. First CHECK_CREATE_MAPPING_OK is called.
--                      : If task name is passed instead of task ID, task id is fetched from
--                      : the table using parent_structure_version_id and used.
--                      :
-- Assumptions          : The FP task will have only one version

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_wp_task_name               VARCHAR2    NO             If WP task version id is null, then task name should be passed
-- p_wp_task_version_id         NUMBER      NO            The WP task id from which mapping has to be done
-- p_parent_str_version_id      NUMBER      NO             It is required to get the task id from task name.
-- p_fp_task_version_id         NUMBER      NO            FP task version id to which mapping wil be created
-- p_fp_task_name               VARCHAR2    NO             IF FP task id is not passed, task name will be required
-- p_project_id                 NUMBER      Yes            The project id will be used in case of getting task ids from task names

PROCEDURE CREATE_MAPPING
   (
       p_api_version           IN   NUMBER := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_wp_task_name          IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_task_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_parent_str_version_id IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_name          IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_project_id            IN   NUMBER
     , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT  NOCOPY VARCHAR2         --File.Sql.39 bug 4440895
  )
  IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_wp_task_version_id            NUMBER ;
l_fp_task_version_id            NUMBER ;
l_create_mapping_ok             VARCHAR2(1);
l_error_message_code            VARCHAR2(32);
l_relationship_id               VARCHAR2(20);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

/*Bug 8574986 BEGIN*/
 l_msg_type   VARCHAR2(2);
 l_fp_task_id number;
 l_msg_token1 VARCHAR2(1000);
  /*Bug 8574986 END*/

 --select the wp_task_version_id for the corresponding name
CURSOR c_get_wp_task_ver_id_frm_name ( l_task_name VARCHAR2, l_project_id NUMBER, l_parent_str_version_id NUMBER)
IS
SELECT
 ppv.element_version_id

FROM
  pa_proj_element_versions ppv
, pa_proj_elements pae
WHERE  pae.name = l_task_name
AND    pae.project_id = l_project_id
AND    ppv.project_id = l_project_id
AND    ppv.proj_element_id = pae.proj_element_id
AND    ppv.parent_structure_version_id = l_parent_str_version_id
AND    pae.object_type = 'PA_TASKS'
AND    pae.project_id = ppv.project_id ;

--select the fp_task_version_id for the corresponding name , it does not require parent str ver id
CURSOR c_get_fp_task_ver_id_frm_name ( l_task_name VARCHAR2, l_project_id NUMBER)
IS
SELECT
  ppv.element_version_id

FROM
   pa_proj_element_versions   ppv
 , pa_proj_elements           pae
 , pa_proj_elem_ver_structure str_ver
 , pa_proj_structure_types    str_type
 , pa_structure_types

WHERE  pae.name = l_task_name
AND    pae.project_id = l_project_id
AND    ppv.project_id = l_project_id
AND    ppv.proj_element_id = pae.proj_element_id
AND    ppv.parent_structure_version_id = str_ver.element_version_id
AND    pae.object_type = 'PA_TASKS'
AND    ppv.object_type = 'PA_TASKS'
AND    str_ver.project_id = l_project_id
AND    str_ver.proj_element_id = str_type.proj_element_id
AND    str_type.structure_type_id = pa_structure_types.structure_type_id
AND    pa_structure_types.structure_type = 'FINANCIAL'
AND    pae.project_id = ppv.project_id ;


BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CREATE_MAPPING',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_MAPPING_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_task_name'||':'||p_wp_task_name,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_task_version_id'||':'||p_wp_task_version_id,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_parent_str_version_id'||':'||p_parent_str_version_id,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_fp_task_version_id'||':'||p_fp_task_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_fp_task_name'||':'||p_fp_task_name,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, l_debug_level3);
     END IF;

      --Check if project id is null , raise an error
      IF (p_project_id is NULL)
      THEN
          IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : project id can not be null';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                      l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc_WP;
      END IF;

	  /*Bug 8574986 BEGIN*/

	  select proj_element_id
	  into l_fp_task_id
	  from pa_proj_element_versions where element_version_id=p_fp_task_version_id;

PA_TRANSACTIONS_PUB.validate_task(X_project_id=> p_project_id
									, X_task_id=> l_fp_task_id
									, X_msg_data=> l_msg_data
									, X_msg_type=> l_msg_type
									, X_msg_token1=>l_msg_token1
									, X_msg_count=> l_msg_count);


              IF (l_msg_count>0 and l_msg_type='E') Then
 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_CM_SUB_TASK_MAP',
						p_token1=>'PATC_MSG_TOKEN1',
						p_value1=>l_msg_token1);
              RAISE FND_API.G_EXC_ERROR ;


		        End If;
/*Bug 8574986 END*/

      -- if wp task id and wp task name both are null , or
      -- if fp task id and and fp task name both are null
      -- raise error
      IF (
          (
           ( p_wp_task_name is NULL OR p_wp_task_name = FND_API.G_MISS_CHAR ) AND
           ( p_wp_task_version_id is NULL OR p_wp_task_version_id = FND_API.G_MISS_NUM )
          ) OR
          (
           ( p_fp_task_name is NULL OR p_fp_task_name = FND_API.G_MISS_CHAR ) AND
           ( p_fp_task_version_id is NULL OR p_fp_task_version_id = FND_API.G_MISS_NUM )
          )
         )
      THEN
           IF l_debug_mode = 'Y' THEN
                 Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : Both work plan task id and task name are null';
                 Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                 l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
      END IF;

      -- Parent structure version id is essential to get task id using task name , so it should be validated
      IF (
           ( p_wp_task_version_id IS NULL OR p_wp_task_version_id = FND_API.G_MISS_NUM ) AND
           (
             ( p_wp_task_name IS NOT NULL AND p_wp_task_name <> FND_API.G_MISS_CHAR ) AND
             ( p_parent_str_version_id IS NULL OR p_parent_str_version_id = FND_API.G_MISS_NUM )
           )
         )
      THEN
          IF l_debug_mode = 'Y' THEN
                 Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : parent structue version id can not be null, if wp task name is not null';
                 Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                 l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
      END IF;

     -- If the task name is passed insteand of task id, we need to fetch the task id

     IF ( p_wp_task_version_id IS NOT NULL AND p_wp_task_version_id <> FND_API.G_MISS_NUM )
     THEN
          l_wp_task_version_id := p_wp_task_version_id;

     ELSIF
     (  ( p_wp_task_name IS NOT NULL AND p_wp_task_name <> FND_API.G_MISS_CHAR )AND
        ( p_parent_str_version_id IS NOT NULL AND p_parent_str_version_id <> FND_API.G_MISS_NUM )
     )
     THEN
          --select the wp_task_version_id for the corresponding name and store it in l_wp_task_version_id

         OPEN  c_get_wp_task_ver_id_frm_name ( p_wp_task_name , p_project_id ,  p_parent_str_version_id );

         FETCH c_get_wp_task_ver_id_frm_name INTO l_wp_task_version_id ;
         IF ( c_get_wp_task_ver_id_frm_name%NOTFOUND )
         THEN
              PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_OBJECT_NAME_INV' );
              RAISE FND_API.G_EXC_ERROR ;
         END IF;
         CLOSE c_get_wp_task_ver_id_frm_name ;

     END IF;

     IF ( ( p_fp_task_version_id IS NOT NULL AND p_fp_task_version_id <> FND_API.G_MISS_NUM )
        )
     THEN
          l_fp_task_version_id := p_fp_task_version_id;

     ELSIF  (  p_fp_task_name IS NOT NULL AND p_fp_task_name <> FND_API.G_MISS_CHAR )
     THEN
          -- get the fp_task_version_id and place it in l_fp_task_version_id;
          -- Assuming there will be only one version for the FP task.
        Pa_Debug.WRITE('test',l_fp_task_version_id, l_debug_level3);
         OPEN  c_get_fp_task_ver_id_frm_name ( p_fp_task_name , p_project_id  );
         FETCH c_get_fp_task_ver_id_frm_name INTO l_fp_task_version_id ;
         IF ( c_get_fp_task_ver_id_frm_name%NOTFOUND )
         THEN
              PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_OBJECT_NAME_INV' );
              RAISE FND_API.G_EXC_ERROR ;
         END IF;
         CLOSE c_get_fp_task_ver_id_frm_name ;

     END IF;

     IF l_debug_mode = 'Y' THEN
            Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : Calling PA_PROJ_STRUC_MAPPING_UTILS.CHECK_CREATE_MAPPING_OK ';
            Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, l_debug_level3);
     END IF;

    -- Call util API to check whether the mapping can be created
     PA_PROJ_STRUC_MAPPING_UTILS.CHECK_CREATE_MAPPING_OK
     (  p_task_version_id_WP => l_wp_task_version_id
      , p_task_version_id_FP => l_fp_task_version_id
      , p_api_version        => p_api_version
      , p_calling_module     => p_calling_module
      , x_return_status      => l_create_mapping_ok
      , x_msg_count          => x_msg_count
      , x_msg_data           => x_msg_data
      , x_error_message_code => l_error_message_code
     );

     x_return_status := l_create_mapping_ok;

     IF  l_create_mapping_ok <> FND_API.G_RET_STS_SUCCESS
     THEN

          -- Mapping can't be created
          IF l_debug_mode = 'Y' THEN
                 Pa_Debug.g_err_stage:= ' PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : '|| l_error_message_code;
                 Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                      l_debug_level3);
          END IF;
          Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     => l_error_message_code);
          RAISE FND_API.G_EXC_ERROR;
     ELSE
        -- Mapping Can be created, call public API to create mapping
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING :  Calling create'||l_wp_task_version_id||l_fp_task_version_id;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
           END IF;

        --Call public API to create the mapping

           PA_RELATIONSHIP_PUB.CREATE_RELATIONSHIP
           (
              p_init_msg_list           => FND_API.G_FALSE
            , p_commit                  => p_commit
            , p_debug_mode              => l_debug_mode
            , p_project_id_from         => p_project_id
            , p_task_version_id_from    => l_wp_task_version_id
            , p_project_id_to           => p_project_id
            , p_task_version_id_to      => l_fp_task_version_id
            , p_structure_type          => NULL
            , p_relationship_type       => 'M'
            , p_initiating_element      => NULL
            , x_object_relationship_id  => l_relationship_id
            , x_return_status           => x_return_status
            , x_msg_count               => x_msg_count
            , x_msg_data                => x_msg_data

          );
     END IF;
IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
     RAISE FND_API.G_EXC_ERROR;
END IF;
IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          l_msg_count := Fnd_Msg_Pub.count_msg;

          IF (p_commit = FND_API.G_TRUE) THEN
               ROLLBACK TO CREATE_MAPPING_PUBLIC;
          END IF;

          IF l_msg_count = 1 AND x_msg_data IS NULL
           THEN
               Pa_Interface_Utils_Pub.get_messages
                   ( p_encoded        => Fnd_Api.G_TRUE
                   , p_msg_index      => 1
                   , p_msg_count      => l_msg_count
                   , p_msg_data       => l_msg_data
                   , p_data           => l_data
                   , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.reset_curr_function;
          END IF;

    WHEN Invalid_Arg_Exc_WP THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_PROJ_STRUC_MAPPING_PUB : CREATE_MAPPING : NULL arguments are passed to the procedure';

           IF (p_commit = FND_API.G_TRUE) THEN
               ROLLBACK TO CREATE_MAPPING_PUBLIC;
           END IF;

          Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                         , p_procedure_name  => 'CREATE_MAPPING'
                         , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
          RAISE;


    WHEN OTHERS THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

           IF (p_commit = FND_API.G_TRUE) THEN
               ROLLBACK TO CREATE_MAPPING_PUBLIC;
          END IF;
               Pa_Debug.g_err_stage:= 'x_msg_count='||x_msg_count;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, l_debug_level5);


          Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                         , p_procedure_name  => 'CREATE_MAPPING'
                         , p_error_text      => x_msg_data);
               Pa_Debug.g_err_stage:= 'x_msg_count='||x_msg_count;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, l_debug_level5);


          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
          RAISE;
END CREATE_MAPPING ;



-- Procedure            : UPDATE_MAPPING
-- Type                 : Public Procedure
-- Purpose              : This API will be used to update the mapping for existing tasks.
--                      : This API will be called from following pages:
--                      : 1.Map Workplan to Financial Task (HGRID - All Tasks)
--                      : 2.Map Workplan Tasks (Selected)
--                      : 3.Map Financial Tasks
--                      : 4.UPDATE TASK page

-- Note                 : This API will update the mapping , In workplan context
--                      :  -- If no mapping is existing, it will create the mapping if the passed fp_task is valid.
--                      :
--                      :  -- If mapping exists, and fp task name is changed on the page, the mapping will deleted and new mapping
--                      :  -- with new fp task name will be created.
--                      :  In Financial context
--                      :  -- Similar to workplan
--                      : If called from self service, the object relationship id will be passed.
--                      : If this is null,new mapping will be created. If this is not null, exitsting mapping will be deleted.
--                      : The record version number will also be passed from self service application.
-- Assumptions          : From Financial context, many WP names will be passed and from Workplan context, only one Wp task ID or Task Name will be passed

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
--  p_structure_type            VARCHAR2  Yes            The value will contain the context for which the Update is happening. Its value will be FINANCIAL or WORKPLAN.
--  p_project_id                NUMBER    Yes            The project id will be used in case of getting task ids from task names
--  p_wp_task_name              VARCHAR2  NO             If WP task version id is null, then task name should be passed. Incase of financial context this will be multiple names
--  p_wp_prnt_str_ver_id        NUMBER    NO             It is required to get the task id from task name.
--  p_wp_task_version_id        NUMBER    Yes            The WP task id from which mapping has to be updated
--  p_fp_task_name              VARCHAR2  NO             IF FP task id is not passed, task name will be required
--  p_fp_task_version_id        NUMBER    Yes            FP task id in mapping which needs to b updated
--  p_object_relationship_id    NUMBER    NO             The Object relationship Id of the existing mapping

PROCEDURE UPDATE_MAPPING
   (
       p_api_version               IN   NUMBER   := 1.0
     , p_init_msg_list             IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                    IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only             IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module            IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode                IN   VARCHAR2 := 'N'
     , p_record_version_number     IN   NUMBER   := FND_API.G_MISS_NUM
     , p_structure_type            IN   VARCHAR2 := 'WORKPLAN'
     , p_project_id                IN   NUMBER
     , p_wp_task_name              IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_wp_prnt_str_ver_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_wp_task_version_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_fp_task_name              IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_fp_task_version_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_object_relationship_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data                  OUT  NOCOPY VARCHAR2         --File.Sql.39 bug 4440895
  )
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_wp_task_version_id            NUMBER ;
l_fp_task_version_id            NUMBER ;
l_notfound                      BOOLEAN;
l_wp_task_version_id_tbl        PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;
l_map_wp_task_ver_id_tbl        PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;
l_wp_task_name_table            PA_PROJ_STRUC_MAPPING_PUB.OBJECT_NAME_TABLE_TYPE ;
l_parse_return_message          VARCHAR2(30);
l_proj_element_version_id       NUMBER;
l_object_relationship_id        NUMBER;
l_rec_version_num               NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;


-- This cursor selects the task version id given task name , project_id and parent str ver id
-- This same cursor can be used for WP tasks
CURSOR c_get_wp_task_ver_id_frm_name (l_wp_task_name VARCHAR2 , l_projectid NUMBER ,l_prnt_str_ver_id NUMBER )
IS
SELECT ppv.element_version_id
FROM   pa_proj_element_versions ppv, pa_proj_elements pae
WHERE  pae.name = l_wp_task_name
AND    pae.project_id = l_projectid
AND    ppv.proj_element_id = pae.proj_element_id
AND    ppv.parent_structure_version_id = l_prnt_str_ver_id
AND    pae.object_type = 'PA_TASKS'
AND    pae.project_id = ppv.project_id;


-- Select the object relationship id corresponding to existing mapping
CURSOR cur_get_object_relationship_id (l_wp_task_version_id NUMBER )
IS
SELECT object_relationship_id , record_version_number
FROM pa_object_relationships
WHERE object_id_from1 = l_wp_task_version_id
AND relationship_type = 'M';


--select the fp_task_version_id for the corresponding name , it does not require parent str ver id
CURSOR c_get_fp_task_ver_id_frm_name ( l_task_name VARCHAR2, l_project_id NUMBER)
IS
SELECT
  ppv.element_version_id
FROM
   pa_proj_element_versions   ppv
 , pa_proj_elements           pae
 , pa_proj_elem_ver_structure str_ver
 , pa_proj_structure_types    str_type
 , pa_structure_types
WHERE  pae.name = l_task_name
AND    pae.project_id = l_project_id
AND    ppv.project_id = l_project_id
AND    ppv.proj_element_id = pae.proj_element_id
AND    ppv.parent_structure_version_id = str_ver.element_version_id
AND    pae.object_type = 'PA_TASKS'
AND    ppv.object_type = 'PA_TASKS'
AND    str_ver.project_id = l_project_id
AND    str_ver.proj_element_id = str_type.proj_element_id
AND    str_type.structure_type_id = pa_structure_types.structure_type_id
AND    pa_structure_types.structure_type = 'FINANCIAL'
AND    ppv.project_id = pae.project_id;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'UPDATE_MAPPING',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF ( p_commit = FND_API.G_TRUE ) THEN
        savepoint UPDATE_MAPPING_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_structure_type'||':'||p_structure_type,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_task_name'||':'||p_wp_task_name,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_wp_prnt_str_ver_id'||':'||p_wp_prnt_str_ver_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_wp_task_version_id'||':'||p_wp_task_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_fp_task_name'||':'||p_fp_task_name,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_fp_task_version_id'||':'||p_fp_task_version_id,
                                     l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     -- if PROJECT id IS NULL RAISE ERROR MESSAGE
     IF (p_project_id is NULL)
     THEN
          IF l_debug_mode = 'Y' THEN
                      Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : project id can not be null';
                      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                      l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;

      -- if wp task id and wp task name both are null , or
      -- if fp task id and and fp task name both are null
      -- raise error
      IF (
          (
           ( p_wp_task_name is NULL OR p_wp_task_name = FND_API.G_MISS_CHAR ) AND
           ( p_wp_task_version_id is NULL OR p_wp_task_version_id = FND_API.G_MISS_NUM )
          ) AND
          (
           ( p_fp_task_name is NULL OR p_fp_task_name = FND_API.G_MISS_CHAR ) AND
           ( p_fp_task_version_id is NULL OR p_fp_task_version_id = FND_API.G_MISS_NUM )
          )
         )
      THEN
           IF l_debug_mode = 'Y' THEN
                 Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : Both of tasks id and tasks name are null';
                 Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                 l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
      END IF;

     -- Parent structure version id is essential to get task id using task name , so it should be validated
      IF (
           ( p_wp_task_version_id IS NULL OR p_wp_task_version_id = FND_API.G_MISS_NUM ) AND
           (
             ( p_wp_task_name IS NOT NULL AND p_wp_task_name <> FND_API.G_MISS_NUM ) AND
             ( p_wp_prnt_str_ver_id IS NULL OR p_wp_prnt_str_ver_id = FND_API.G_MISS_NUM )
           )
         )
      THEN
          IF l_debug_mode = 'Y' THEN
                 Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : parent structue version id can not be null, if wp task name is not null';
                 Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                 l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
      END IF;

     IF  ( p_wp_task_version_id IS NOT NULL AND p_wp_task_version_id <> FND_API.G_MISS_NUM  )
     THEN
          l_wp_task_version_id := p_wp_task_version_id;
     ELSIF (
             ( p_wp_task_name IS NOT NULL AND p_wp_task_name <> FND_API.G_MISS_CHAR ) AND
             ( p_wp_prnt_str_ver_id IS NOT NULL AND p_wp_prnt_str_ver_id <> FND_API.G_MISS_NUM )
           )
     THEN
          --get the wp_task_version_id and place it in l_wp_task_version_id;
          OPEN  c_get_wp_task_ver_id_frm_name ( p_wp_task_name , p_project_id , p_wp_prnt_str_ver_id );
          FETCH c_get_wp_task_ver_id_frm_name INTO  l_wp_task_version_id;
          IF (c_get_wp_task_ver_id_frm_name%NOTFOUND)
          THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_OBJECT_NAME_INV' );
               RAISE FND_API.G_EXC_ERROR ;
          END IF;
          CLOSE c_get_wp_task_ver_id_frm_name;

     END IF;
     IF ( p_fp_task_version_id IS NOT NULL AND p_fp_task_version_id <> FND_API.G_MISS_NUM )
     THEN
          l_fp_task_version_id := p_fp_task_version_id;

     ELSIF (  p_fp_task_name IS NOT NULL AND p_fp_task_name <> FND_API.G_MISS_CHAR
           )
     THEN
          -- get the fp_task_version_id and place it in l_fp_task_version_id;
          -- Assuming there will be only one version for the FP task.Parent structure version id is passed
          -- in view that in future there wil be versions for financial tasks also
          OPEN  c_get_fp_task_ver_id_frm_name ( p_fp_task_name, p_project_id  );
          FETCH c_get_fp_task_ver_id_frm_name INTO l_fp_task_version_id;
          IF (c_get_fp_task_ver_id_frm_name%NOTFOUND)
          THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_OBJECT_NAME_INV' );
               RAISE FND_API.G_EXC_ERROR ;
          END IF;
          CLOSE c_get_fp_task_ver_id_frm_name;
     END IF;

     IF ( ( p_object_relationship_id IS NULL OR p_object_relationship_id = FND_API.G_MISS_NUM )
          AND
            p_calling_module <> 'SELF_SERVICE'
        )
     THEN
          OPEN  cur_get_object_relationship_id (l_wp_task_version_id);
          FETCH cur_get_object_relationship_id INTO l_object_relationship_id , l_rec_version_num;
          CLOSE cur_get_object_relationship_id;
     ELSE
          l_object_relationship_id := p_object_relationship_id;
          l_rec_version_num := p_record_version_number;
     END IF;

     --If l_object_relationship_id is not null
     IF ( l_object_relationship_id IS NOT NULL AND l_object_relationship_id <> FND_API.G_MISS_NUM  )
     THEN
          --delete the existing mapping
          PA_RELATIONSHIP_PUB.DELETE_RELATIONSHIP
           (
              p_api_version             => p_api_version
            , p_init_msg_list           => FND_API.G_FALSE
            , p_commit                  => p_commit
            , p_validate_only           => p_validate_only
            , p_calling_module          => 'SELF_SERVICE'
            , p_debug_mode              => l_debug_mode
            , p_object_relationship_id  => l_object_relationship_id
            , p_record_version_number   => l_rec_version_num
            , x_return_status           => x_return_status
            , x_msg_count               => x_msg_count
            , x_msg_data                => x_msg_data
           );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
          THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;

     --IF l_fp_task_ver_id is not null
     IF (
          (l_fp_task_version_id IS NOT NULL AND l_fp_task_version_id <> FND_API.G_MISS_NUM ) AND
          (l_wp_task_version_id IS NOT NULL AND l_wp_task_version_id <> FND_API.G_MISS_NUM )
        )
     THEN
     --create new mapping with l_wp_task_ver_id and l_fp_task_ver_id
         -- Call CREATE_MAPPING
          PA_PROJ_STRUC_MAPPING_PUB.CREATE_MAPPING(
            p_wp_task_version_id    => l_wp_task_version_id
          , p_fp_task_version_id    => l_fp_task_version_id
          , p_project_id            => p_project_id
          , p_init_msg_list         => FND_API.G_FALSE
          , p_commit                => p_commit
          , p_debug_mode            => l_debug_mode
          , x_return_status         => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          );
          IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS )
          THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;

 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
 THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF ( p_commit = FND_API.G_TRUE ) THEN
     COMMIT;
 END IF;

 EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          l_msg_count := Fnd_Msg_Pub.count_msg;

          IF ( p_commit = FND_API.G_TRUE ) THEN
               ROLLBACK TO UPDATE_MAPPING_PUBLIC;
          END IF;

          IF cur_get_object_relationship_id%ISOPEN THEN
               CLOSE cur_get_object_relationship_id;
          END IF;

          IF c_get_fp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_fp_task_ver_id_frm_name;
          END IF;

          IF c_get_wp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_wp_task_ver_id_frm_name;
          END IF;

          IF l_msg_count = 1 AND x_msg_data IS NULL
           THEN
               Pa_Interface_Utils_Pub.get_messages
                   ( p_encoded        => Fnd_Api.G_TRUE
                   , p_msg_index      => 1
                   , p_msg_count      => l_msg_count
                   , p_msg_data       => l_msg_data
                   , p_data           => l_data
                   , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.reset_curr_function;
          END IF;

 WHEN Invalid_Arg_Exc_WP THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := Fnd_Msg_Pub.count_msg;
          x_msg_data      := 'PA_PROJ_STRUC_MAPPING_PUB : UPDATE_MAPPING : Some parameters are NULL';

          IF ( p_commit = FND_API.G_TRUE ) THEN
               ROLLBACK TO UPDATE_MAPPING_PUBLIC;
          END IF;

          IF cur_get_object_relationship_id%ISOPEN THEN
               CLOSE cur_get_object_relationship_id;
          END IF;

          IF c_get_wp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_wp_task_ver_id_frm_name;
          END IF;

          IF c_get_fp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_fp_task_ver_id_frm_name;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                         , p_procedure_name  => 'UPDATE_MAPPING'
                         , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;


 WHEN OTHERS THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          IF ( p_commit = FND_API.G_TRUE ) THEN
               ROLLBACK TO UPDATE_MAPPING_PUBLIC;
          END IF;

          IF cur_get_object_relationship_id%ISOPEN THEN
               CLOSE cur_get_object_relationship_id;
          END IF;

          IF c_get_fp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_fp_task_ver_id_frm_name;
          END IF;

          IF c_get_wp_task_ver_id_frm_name%ISOPEN THEN
               CLOSE c_get_wp_task_ver_id_frm_name;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
           (  p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
            , p_procedure_name  => 'UPDATE_MAPPING'
            , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;

END UPDATE_MAPPING ;


-- Procedure            : COPY_MAPPING
-- Type                 : Public Procedure
-- Purpose              : This API copies the mappings from source structure tasks to destinations structure tasks
--                      : This will be called from copy_project, create working version, publish version api.
--                      :
-- Note                 : The API's function will depend on the P_CONTEXT.
--                      : 1. P_CONTEXT is COPY_PROJECT: The structure version IDs passed will be ignored in this case and they will taken from the database.
--                      :    Mapping will be created depending as in existing src stuructures
--                      : 2. P_CONTEXT is (create or publish): In this context, the structure version ids will be passed and src project id will be ignored
--                      :
-- Assumptions          : This will be called after the copy project has been called ,
--                      : so that the element version ids of the destination projects are available.
--                      : Only for split structure

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_context                      IN     VARCHAR2        This will tell whether the context is copy_project or other
-- p_src_project_id               IN     NUMBER          The project id which is being copied
-- p_dest_project_id              IN     NUMBER          The project id to which it is being copied
-- p_src_str_version_id           IN     NUMBER          The structure version id from source project
-- p_dest_str_version_id          IN     NUMBER          The structure version id from source at the destinantion project

PROCEDURE COPY_MAPPING
    (
       p_api_version           IN   NUMBER := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_record_version_number IN   NUMBER   := FND_API.G_MISS_NUM
     , p_context               IN   VARCHAR2
     , p_src_project_id        IN   NUMBER   := FND_API.G_MISS_NUM
     , p_dest_project_id       IN   NUMBER   := FND_API.G_MISS_NUM
     , p_src_str_version_id    IN   NUMBER   := FND_API.G_MISS_NUM
     , p_dest_str_version_id   IN   NUMBER   := FND_API.G_MISS_NUM
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2         --File.Sql.39 bug 4440895

   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_user_id                       NUMBER;
l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;



-- This cursor will select the element_version_id , source structure version id and structure type for the passed
-- project id.
CURSOR c_get_dest_structures ( l_dest_project_id NUMBER )
IS
SELECT
  pelever.element_version_id AS structure_version
, pelever.attribute15 AS src_str_version_id
, pstrType.structure_type AS structure_type
FROM
  pa_proj_element_versions pelever,
  pa_proj_structure_types prjstrType,
  pa_structure_types pstrType
WHERE
  pelever.object_type = 'PA_STRUCTURES'
AND
  pelever.project_id = l_dest_project_id
AND
  prjstrType.proj_element_id  = pelever.proj_element_id
AND
  pstrType.structure_type_id = prjstrType.structure_type_id
AND
  pstrType.structure_type =  'WORKPLAN'
AND
  pstrType.structure_type_class_code = 'WORKPLAN';


--This cursor will select all the tasks which are mapped for a particular structure which needs to be passed.
CURSOR c_get_mapped_tasks (l_parent_str_version_id NUMBER, l_project_id NUMBER)
IS
SELECT
      paObrel.OBJECT_ID_FROM1 as OBJECT_ID_FROM1
    , paObrel.OBJECT_ID_TO1 as OBJECT_ID_TO1
FROM
      pa_proj_element_versions elever
    , pa_object_relationships  paObrel
WHERE elever.PARENT_STRUCTURE_VERSION_ID = l_parent_str_version_id
AND   paObrel.OBJECT_ID_FROM1 = elever.element_version_id
AND   elever.project_id = l_project_id
AND   paObrel.RELATIONSHIP_TYPE = 'M'
AND   elever.object_type = 'PA_TASKS';

-- This cursor will get the task version id from pa_proj_element_versions , where src task version id is passed
CURSOR c_get_mapped_task_version ( l_src_task_version_id  NUMBER, l_project_id NUMBER )
IS
SELECT ELEMENT_VERSION_ID
FROM   PA_PROJ_ELEMENT_VERSIONS ELEVER
WHERE  ELEVER.ATTRIBUTE15 = l_src_task_version_id
AND    ELEVER.OBJECT_TYPE = 'PA_TASKS'
AND    ELEVER.PROJECT_ID = l_project_id;

CURSOR c_get_mapped_task_id ( l_task_ver_id  NUMBER , l_str_version_id NUMBER, l_project_id NUMBER  )
IS
SELECT proj_element_id
FROM   pa_proj_element_versions
WHERE  OBJECT_TYPE = 'PA_TASKS'
AND    element_version_id = l_task_ver_id
AND    parent_structure_version_id = l_str_version_id
AND    pa_proj_element_versions.project_id = l_project_id;

CURSOR c_get_mapped_task_ver_id ( l_task_id  NUMBER , l_str_version_id NUMBER, l_project_id NUMBER  )
IS
SELECT element_version_id
FROM   pa_proj_element_versions
WHERE  OBJECT_TYPE = 'PA_TASKS'
AND    parent_structure_version_id = l_str_version_id
AND    proj_element_id = l_task_id
AND    pa_proj_element_versions.project_id = l_project_id;

l_src_from_tasks_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;
l_src_to_tasks_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;

l_dest_from_tasks_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;
l_dest_to_tasks_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;

l_from_task_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_ID_TABLE_TYPE;
l_to_task_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJECT_ID_TABLE_TYPE;

l_from_dest_task_ver_id PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;
l_to_dest_task_ver_id PA_PROJ_STRUC_MAPPING_PUB.OBJECT_VERSION_ID_TABLE_TYPE;

BEGIN


     x_msg_count := 0;
     l_user_id := FND_GLOBAL.USER_ID;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'COPY_MAPPING',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_context'||p_context,l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_src_project_id'||p_src_project_id,l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_dest_project_id'||p_dest_project_id,l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_src_str_version_id'||p_src_str_version_id,l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_dest_str_version_id'||p_dest_str_version_id,l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( p_context IS NULL ) THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : p_context is mandatory and cant be null';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                       l_debug_level3);

          RAISE Invalid_Arg_Exc_WP;
     END IF;

          --If context is copy_project, src and destination project id must be passed and they should not be same
     IF (  p_context ='COPY_PROJECT' ) THEN
         IF
           (
                ( p_src_project_id IS NULL OR p_src_project_id = FND_API.G_MISS_NUM )
             OR ( p_dest_project_id IS NULL OR p_dest_project_id = FND_API.G_MISS_NUM )
             OR ( p_src_project_id = p_dest_project_id )
           )
          THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : if p_context is Copy Project , both src and destination project id will be required';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                       l_debug_level3);

          RAISE Invalid_Arg_Exc_WP;

          ELSE
           -- Code for copy-project context
               --get the destination structures
               --This for loop gets all the workplan structures in the destination project id.
               --For each workplan structure , find the mapped task version id in source project
               --and corresponding task version id in destination project
               FOR str_rec IN c_get_dest_structures (p_dest_project_id) LOOP

                    --IF str_rec.structure_type = 'WORKPLAN' THEN

                         --For each workplan structure , find the mapped task version id in source project
                         --delete all elements from the table before using it;
                         l_src_to_tasks_id_tbl.DELETE;
                         l_src_from_tasks_id_tbl.DELETE;
                         OPEN  c_get_mapped_tasks ( str_rec.src_str_version_id , p_src_project_id );
                         FETCH c_get_mapped_tasks BULK COLLECT
                         INTO  l_src_from_tasks_id_tbl , l_src_to_tasks_id_tbl;
                         CLOSE c_get_mapped_tasks ;

                         --For each task version id in source, get the corresponding one in destination project
                         l_dest_from_tasks_id_tbl.DELETE;
                         FOR iCounter in 1..l_src_from_tasks_id_tbl.COUNT LOOP

                              OPEN  c_get_mapped_task_version ( l_src_from_tasks_id_tbl ( iCounter ) , p_dest_project_id ) ;
                              FETCH c_get_mapped_task_version INTO l_dest_from_tasks_id_tbl ( iCounter ) ;
                              CLOSE c_get_mapped_task_version ;

                         END LOOP;
                         --For each task version id in source, get the corresponding one in destination project
                         l_dest_to_tasks_id_tbl.DELETE;
                         FOR iCounter in 1..l_src_to_tasks_id_tbl.COUNT LOOP

                              OPEN  c_get_mapped_task_version ( l_src_to_tasks_id_tbl ( iCounter ) , p_dest_project_id ) ;
                              FETCH c_get_mapped_task_version INTO l_dest_to_tasks_id_tbl ( iCounter ) ;
                              CLOSE c_get_mapped_task_version ;

                         END LOOP;


                      -- Create Mapping from the dest task ids using BULK INSERT
		      --added if condition bug.3578265,3574885
               --rtarway bug 3916440, the forall should be called only when l_src_to_tasks_id_tbl is not empty
			IF (l_dest_from_tasks_id_tbl.count > 0 AND l_dest_to_tasks_id_tbl.COUNT > 0)
			THEN
                          FORALL iCounter IN l_dest_from_tasks_id_tbl.FIRST..l_dest_from_tasks_id_tbl.LAST

                          INSERT INTO PA_OBJECT_RELATIONSHIPS
                                 (
                                       object_relationship_id,
                                       object_type_from,
                                       object_id_from1,
                                       object_id_from2,
                                       object_id_from3,
                                       object_id_from4,
                                       object_id_from5,
                                       object_type_to,
                                       object_id_to1,
                                       object_id_to2,
                                       object_id_to3,
                                       object_id_to4,
                                       object_id_to5,
                                       relationship_type,
                                       relationship_subtype,
                                       lag_day,
                                       imported_lag,
                                       priority,
                                       pm_product_code,
                                       Record_Version_Number,
                                       CREATED_BY,
                                       CREATION_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATE_LOGIN,
                                       weighting_percentage
                                 )

                          VALUES (     pa_object_relationships_s.nextval,
                                       'PA_TASKS',
                                       l_dest_from_tasks_id_tbl(iCounter),
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       'PA_TASKS',
                                       l_dest_to_tasks_id_tbl(iCounter),
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       'M',
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       1,
                                       l_user_id,
                                       sysdate,
                                       l_user_id,
                                       sysdate,
                                       l_user_id,
                                       NULL
                                 );
		 END IF;
                    --END IF;--If the condition is workplan
               END LOOP;--End of For loop
          END IF;-- if p_src_project_id is not null

     -- For other than copy mapping, e.g. create working version or publish ,
     -- src_project_id and structure version id should be considered and hence these cant be null
     -- It is assumed that p_src_project_id will be passed in this case
     -- src_project_id will make the c_get_mapped_tasks efficient with project Id filter.
     ELSIF (p_context = 'CREATE_WORKING_VERSION' OR p_context = 'PUBLISH_VERSION')
      THEN
          IF (   ( p_src_str_version_id IS NULL OR p_src_str_version_id = FND_API.G_MISS_NUM )
               OR( p_dest_str_version_id IS NULL OR p_dest_str_version_id = FND_API.G_MISS_NUM )
               OR( p_src_project_id IS NULL OR p_src_project_id = FND_API.G_MISS_NUM )
             ) THEN

           Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : if p_context is create_working_version,both src and destination str ver id will be required';
           Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                       l_debug_level3);
           RAISE Invalid_Arg_Exc_WP;
          END IF;

        -- get the mapped task-version-id for the source str version id.
          l_src_from_tasks_id_tbl.DELETE;
          l_src_to_tasks_id_tbl.DELETE;
          OPEN  c_get_mapped_tasks ( p_src_str_version_id , p_src_project_id );
          FETCH c_get_mapped_tasks BULK COLLECT
          INTO  l_src_from_tasks_id_tbl , l_src_to_tasks_id_tbl;
          CLOSE c_get_mapped_tasks ;
        -- for each task version id mapped, get the proj_element_id
          l_from_task_id_tbl.DELETE;
          FOR iCounter in 1..l_src_from_tasks_id_tbl.COUNT LOOP
              OPEN  c_get_mapped_task_id ( l_src_from_tasks_id_tbl ( iCounter ),
                 p_src_str_version_id , p_src_project_id );
              FETCH c_get_mapped_task_id  INTO l_from_task_id_tbl ( iCounter );
              CLOSE c_get_mapped_task_id  ;
          END LOOP;



          --for each task id mapped, get the task version ids for the dest structure version id, project should be same
          l_from_dest_task_ver_id.DELETE;
          FOR iCounter in 1..l_from_task_id_tbl.COUNT LOOP
               OPEN  c_get_mapped_task_ver_id ( l_from_task_id_tbl (iCounter) ,
                  p_dest_str_version_id , p_src_project_id );
               FETCH c_get_mapped_task_ver_id INTO l_from_dest_task_ver_id ( iCounter );
               CLOSE c_get_mapped_task_ver_id;
          END LOOP;

          Pa_Debug.WRITE(g_module_name,'l_from_task_id_tbl.COUNT '||l_from_task_id_tbl.COUNT ,l_debug_level3);

         -- Insert into PA_OBJECT_RELATIONSHIPS
         --bug 3574885, the forall should be called only when l_from_dest_task_ver_id is not empty
         --rtarway ,bug 3916440, the forall should be called only when l_src_to_tasks_id_tbl is not empty
         IF (l_from_dest_task_ver_id.COUNT > 0 AND l_src_to_tasks_id_tbl.count > 0)
         THEN
         FORALL iCounter IN l_from_dest_task_ver_id.FIRST..l_from_dest_task_ver_id.LAST

            INSERT INTO PA_OBJECT_RELATIONSHIPS (
                        object_relationship_id,
                        object_type_from,
                        object_id_from1,
                        object_id_from2,
                        object_id_from3,
                        object_id_from4,
                        object_id_from5,
                        object_type_to,
                        object_id_to1,
                        object_id_to2,
                        object_id_to3,
                        object_id_to4,
                        object_id_to5,
                        relationship_type,
                        relationship_subtype,
                        lag_day,
                        imported_lag,
                        priority,
                        pm_product_code,
                        Record_Version_Number,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        weighting_percentage)
           VALUES (     pa_object_relationships_s.nextval,
                        'PA_TASKS',
                        l_from_dest_task_ver_id(iCounter),
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        'PA_TASKS',
                        l_src_to_tasks_id_tbl(iCounter),
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        'M',
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        1,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        sysdate,
                        l_user_id,
                        NULL
          );
         END IF;
      END IF;

 Pa_Debug.WRITE(g_module_name,'After Completing insert',l_debug_level3);

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_PROJ_STRUC_MAPPING_PUB : COPY_MAPPING : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'COPY_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;


     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'COPY_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

 END COPY_MAPPING ;



-- Procedure            : DELETE_ALL_MAPPING
-- Type                 : Public Procedure
-- Purpose              : This API will be called when we change a split mapping project to split no mapping.
--                      :
-- Note                 : 1. Get all the financial tasks of the passed project id.
--                      : 2. If any of these tasks is existing in PA_OBJECT_RELATIONSHIPS, with relationship_type 'M'
--                      :          delete the record in pa_object_relationships
-- Assumptions          : The financial structure will have only one version in any case whether versioning enabled or disabled

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_project_id                 NUMBER   Y               The project id for which the mappings have to be deleted

PROCEDURE DELETE_ALL_MAPPING
    (
       p_api_version           IN       NUMBER   := 1.0
     , p_init_msg_list         IN       VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN       VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN       VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN       VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN       VARCHAR2 := 'N'
     , p_project_id            IN       NUMBER
     , x_return_status         OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT      NOCOPY VARCHAR2        --File.Sql.39 bug 4440895
   )
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);


l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
--Table to collect all the mapped financial task version id
l_mapped_obj_rel_id_tbl PA_PROJ_STRUC_MAPPING_PUB.OBJ_REL_ID_TABLE_TYPE;

--This cursor will give all mapped financial tasks and object_relationships_id for the passed project id.
CURSOR c_get_fin_task_ver_id (l_project_id NUMBER)
IS
SELECT
  obRel.object_relationship_id
FROM
      pa_proj_element_versions elever1
    , pa_proj_element_versions elever2
--    , pa_proj_structure_types  projStrType Bug 3693235 Performance Fix
--    , pa_structure_types strType Bug 3693235 Performance Fix
    , pa_object_relationships obRel
WHERE
	elever1.object_type = 'PA_TASKS'
AND  elever1.parent_structure_version_id = elever2.element_version_id
AND  elever2.object_type = 'PA_STRUCTURES'
-- Bug 3693235 Performance Fix
--AND  elever2.proj_element_id = projStrType.proj_element_id
--AND  projStrType.structure_type_id = strType.structure_type_id
--AND  strType.structure_type = 'FINANCIAL'
AND exists (SELECT 'xyz' FROM pa_proj_structure_types WHERE proj_element_id = elever2.proj_element_id and structure_type_id = 6) -- Bug 3693235 Performance Fix
AND  elever1.project_id = l_project_id
AND  elever2.project_id = l_project_id
AND  elever1.project_id = elever2.project_id
AND  elever1.element_version_id = obRel.object_id_to1
AND  obRel.relationship_type='M'
-- Bug 3693235 Performance Fix
AND obRel.object_type_from = 'PA_TASKS'
AND obRel.object_type_to = 'PA_TASKS'
;


BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     --l_debug_mode  := NVL(p_debug_mode,'N');
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'DELETE_ALL_MAPPING',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_ALL_MAPPING : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_ALL_MAPPING_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_ALL_MAPPING : Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( p_project_id IS NULL )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_ALL_MAPPING : p_project_id can not be null';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;

     --Get all the mapped financial tasks
     l_mapped_obj_rel_id_tbl.DELETE;
     OPEN  c_get_fin_task_ver_id  ( p_project_id );
     FETCH c_get_fin_task_ver_id  BULK COLLECT
     INTO  l_mapped_obj_rel_id_tbl ;
     CLOSE c_get_fin_task_ver_id  ;

     IF (l_mapped_obj_rel_id_tbl IS NOT NULL AND l_mapped_obj_rel_id_tbl.COUNT > 0  )
     THEN
          FORALL iCounter IN l_mapped_obj_rel_id_tbl.FIRST..l_mapped_obj_rel_id_tbl.LAST

               DELETE FROM PA_OBJECT_RELATIONSHIPS
               WHERE
               OBJECT_RELATIONSHIP_ID = l_mapped_obj_rel_id_tbl(iCounter);
     END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
    END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_ALL_MAPPING_PUBLIC;
     END IF;
     IF c_get_fin_task_ver_id%ISOPEN THEN
          CLOSE c_get_fin_task_ver_id;
     END IF;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     --x_msg_data      := 'PA_PROJ_STRUC_MAPPING_PUB : DELETE_ALL_MAPPING : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_ALL_MAPPING_PUBLIC;
     END IF;
     IF c_get_fin_task_ver_id%ISOPEN THEN
          CLOSE c_get_fin_task_ver_id;
     END IF;
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'DELETE_ALL_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO DELETE_ALL_MAPPING_PUBLIC;
     END IF;

     IF c_get_fin_task_ver_id%ISOPEN THEN
          CLOSE c_get_fin_task_ver_id;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   (  p_pkg_name         => 'PA_PROJ_STRUC_MAPPING_PUB'
                    , p_procedure_name  => 'DELETE_ALL_MAPPING'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END DELETE_ALL_MAPPING ;

END PA_PROJ_STRUC_MAPPING_PUB;

/

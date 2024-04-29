--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CHECK_PVT" as
/*$Header: PAPMPCVB.pls 120.13.12010000.2 2009/08/06 10:09:26 rthumma ship $*/

--Global constants to be used in error messages
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'PA_PROJECT_CHECK_PUB';
G_PROJECT_CODE    CONSTANT VARCHAR2(7)  := 'PROJECT';
G_CUSTOMER_CODE      CONSTANT VARCHAR2(8)  := 'CUSTOMER';
G_KEY_MEMBER      CONSTANT VARCHAR2(10) := 'KEY_MEMBER';
G_CLASS_CATEGORY_CODE   CONSTANT VARCHAR2(14) := 'CLASS_CATEGORY';
G_TASK_CODE    CONSTANT VARCHAR2(4)  := 'TASK';

--package global to be used during updates
G_USER_ID      CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID     CONSTANT NUMBER := FND_GLOBAL.login_id;

--------------------------------------------------------------------------------
-- Name:		Check_Delete_Task_OK_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if it is OK to delete a task.
--			Otherwise, it returns 'N'.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--			, Convert_Pm_Taskref_To_Id
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		20-NOV-96	Update  lwerker Changed handling of error messages
--		02-DEC-96	Update  lwerker Removed Savepoint and Rollbacks

PROCEDURE Check_Delete_Task_OK_pvt
( p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT NOCOPY	NUMBER /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--Project Structure changes done for bug 2765115
, p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
, p_task_version_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--END Project Structure changes done for bug 2765115
, p_delete_task_ok_flag		OUT NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
)
IS
l_api_name			CONSTANT 	VARCHAR2(30)		:= 'Check_Delete_Task_Ok_Pvt';
l_value_conversion_error			BOOLEAN			:= FALSE;
l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER	:= 0;
l_task_id_out					NUMBER	:= 0;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

--bug 2765115
   l_structure_version_id      NUMBER;
   l_task_version_id           NUMBER;
   l_error_message_code        VARCHAR2(4000);
--bug 2765115

   l_versioning_enabled  VARCHAR2(1) := 'N';
   l_workplan_enabled    VARCHAR2(1) := 'N';

-- Bug Fix 5263429
   l_Published_version_exists VARCHAR2(1);
   l_IS_WP_SEPARATE_FROM_FN   VARCHAR2(1);
   l_IS_WP_VERSIONING_ENABLED VARCHAR2(1);
   l_structure_type VARCHAR2(30);

BEGIN


	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;

       PA_PROJECT_PVT.Convert_pm_projref_to_id
                 ( p_pm_project_reference       =>      p_pm_project_reference
                 , p_pa_project_id              =>      p_project_id
                 , p_out_project_id             =>      l_project_id_out
                 , p_return_status              =>      l_return_status         );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
        THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
        THEN

                RAISE  FND_API.G_EXC_ERROR;
        END IF;

	-- Added for the bug 4728670
        /* Bug #5050424: Calling the API Convert_pm_taskref_to_id_all instead
           of Convert_pm_taskref_to_id so that the Structure Type also gets
           passed. */

/* Bug Fix 5263429
Issue :

 When ever a task was deleted then the error "Task ID invalid" was thrown and the task deletion failed.

Analysis:

 This error was also coming up from the Convert_pm_taskref_to_id_all API. There was a call to the
 PA_PROJECT_PVT.Convert_pm_taskref_to_id_all API in the flow. MSP calls the PA_PROJECT_PUB.check_task_mfd API
 to determine whether a task can be deleted at all or not. This in turn calls  the pa_project_pub.Check_Delete_Task_OK
 API and that in turn calls the pa_project_check_pvt.Check_Delete_Task_OK_pvt API.
 In this API the call to PA_PROJECT_PVT.Convert_pm_taskref_to_id_all the structure type is also passed as shown below.
 As the structure type 'FINANCIAL' was passed the Convert_pm_taskref_to_id_all API was looking for the task in the
 PA_TASKS  table in the cursor l_task_id_csr. As this was not returning any rows the above error is thrown. The task
 is there but due to  the structure type 'WORKPLAN' it is residing in the elements tables as it is not yet published as well.
 Ideally we should pass 'WORKPLAN' as the structure type. This is being done in the PA_PROJECT_PUB.DELETE_TASK API.
   -- If the following criteria is satisfied,
   -- switch flow to WORKPLAN
   -- i) Workplan is enabled;
   -- ii) Structure is SHARED;
   -- iii) Published version exists;

Solution:

 So we need to pass the structure type as 'WORKPLAN' if the following three conditions are satified.
   -- i) Workplan is enabled;
   -- ii) Structure is SHARED;
   -- iii) Published version exists;

*/

   l_Published_version_exists := PA_PROJ_TASK_STRUC_PUB.Published_version_exists( p_project_id );
   l_IS_WP_SEPARATE_FROM_FN   := PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN( p_project_id );
   l_IS_WP_VERSIONING_ENABLED := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED( p_project_id );

   l_structure_type := p_structure_type;

   IF l_Published_version_exists = 'Y'
      AND l_IS_WP_SEPARATE_FROM_FN = 'N'
      AND l_IS_WP_VERSIONING_ENABLED = 'Y'
      AND p_structure_type = 'FINANCIAL'
   THEN
       --Change the flow to WORKPLAN
       l_structure_type := 'WORKPLAN';
   END IF;

        PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                ( p_pa_project_id       =>      l_project_id_out
                , p_pa_task_id          =>      p_task_id
                , p_pm_task_reference   =>      p_pm_task_reference
                , p_structure_type      =>      l_structure_type
                , p_out_task_id         =>      l_task_id_out
                , p_return_status       =>      l_return_status  );

-- End of Bug Fix 5263429
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
        THEN

                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
        THEN

                RAISE  FND_API.G_EXC_ERROR;
        END IF;
-- end for the bug 4738608

--Project Structure changes done for bug 2765115

        l_versioning_enabled := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED( l_project_id_out );
        l_workplan_enabled := PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( l_project_id_out );

        IF ( p_task_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
           OR p_task_version_id IS NULL ) AND
           l_workplan_enabled = 'Y' AND
           l_versioning_enabled = 'Y'
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PS_TSK_VER_REQ_WP'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'GENERAL'
                  ,p_attribute1       => ''
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --get structure_version_id and task_version_id

        PA_PROJ_TASK_STRUC_PUB.get_version_ids(
                  p_task_id               =>     l_task_id_out     --p_task_id changed for Bug No 4738608
                 ,p_task_version_id       =>     p_task_version_id
                 ,p_project_id            =>     l_project_id_out  --p_project_id changed for Bug No 4738608
                 ,x_structure_version_id  =>     l_structure_version_id
                 ,x_task_version_id       =>     l_task_version_id
             );
--Project Structure changes done for bug 2765115

/*
	PA_PROJECT_PVT.Convert_pm_projref_to_id
		 ( p_pm_project_reference	=>	p_pm_project_reference
		 , p_pa_project_id 		=>	p_project_id
		 , p_out_project_id 		=>	l_project_id_out
		 , p_return_status 		=>	l_return_status 	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;
*/  --moved up


--bug 2893028

  IF l_structure_version_id IS NOT NULL AND
     PA_PROJECT_STRUCTURE_UTILS.is_structure_version_updatable( l_structure_version_id ) = 'N' AND
     l_workplan_enabled = 'Y'
  THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_STRUCT_VER_NO_UPDATE'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'GENERAL'
                  ,p_attribute1       => ''
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
  END IF;
--bug 2893028

  IF p_structure_type = 'FINANCIAL'        --Project Structure changes done for bug 2765115
  THEN

      IF p_task_id IS NOT NULL AND p_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
         l_amg_task_number := null;
         OPEN l_amg_task_csr( p_task_id );
         FETCH l_amg_task_csr INTO l_amg_task_number;
         CLOSE l_amg_task_csr;
      END IF;

      IF l_versioning_enabled = 'Y'
         AND PA_PROJ_TASK_STRUC_PUB.Published_version_exists( l_project_id_out ) = 'Y'
         AND l_amg_task_number IS NULL         --if the task is not in pa_tasks
      THEN
          --deleting task from a working version when there is a published structure exists
          null;     --in this case there wont be any task in pa_task
      ELSE

       /* Commented below code and moved it above the call to PA_PROJ_TASK_STRUC_PUB.get_version_ids for bug 4738608
	PA_PROJECT_PVT.Convert_pm_taskref_to_id
	 	( p_pa_project_id	=>	l_project_id_out
	 	, p_pa_task_id		=>	p_task_id
		, p_pm_task_reference	=>	p_pm_task_reference
		, p_out_task_id		=>	l_task_id_out
	 	, p_return_status	=>	l_return_status	 );

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN

		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;
        */
        l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
                       (p_task_number=> ''
                       ,p_task_reference => p_pm_task_reference
                       ,p_task_id => l_task_id_out);

      END IF;   --<< check if published version exists and

  END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id_out );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id_out );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
/*   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> ''
    ,p_task_reference => p_pm_task_reference
    ,p_task_id => l_task_id_out);
*/

/* Project Structure changes done for bug 2765115
 	PA_TASK_UTILS.Check_Delete_Task_Ok
		( x_task_id	=>	l_task_id_out
--bug 3010538                , x_validation_mode => 'R'    --bug 2947492
		, x_err_code	=>	l_err_code
		, x_err_stage	=>	l_err_stage
		, x_err_stack	=>	l_err_stack	);

*/
--Project Structure changes done for bug 2765115
        PA_PROJ_ELEMENTS_UTILS.Check_Delete_task_Ver_Ok
                     (
                   p_project_id                       => p_project_id
                  ,p_task_version_id                  => l_task_version_id
                  ,p_parent_structure_ver_id          => l_structure_version_id
--bug 3010538                  ,p_validation_mode                  => 'R'       --bug 2947492
                  ,x_return_status                    => l_return_status
                  ,x_error_message_code               => l_error_message_code
               );

--Project Structure changes done for bug 2765115

--    	IF l_err_code > 0
    	IF l_return_status <> 'S'     --Project Structure changes done for bug 2765115
    	THEN
            p_delete_task_ok_flag := 'N';

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               IF NOT pa_project_pvt.check_valid_message(l_err_stage)
               THEN
                   pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_DELETE_TASK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
               ELSE
                   pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_error_message_code
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
               END IF;
           END IF;
--Project Structure changes done for bug 2765115
/*    	ELSIF l_err_code < 0
    	THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              IF NOT pa_project_pvt.check_valid_message(l_err_stage)
              THEN
                  pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_DELETE_TASK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
              ELSE
                  pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
              END IF;
           END IF;
*/
--Project Structure changes done for bug 2765115
--	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   RAISE FND_API.G_EXC_ERROR;

	ELSE --l_err_code = 0
		p_delete_task_ok_flag := 'Y';
    	END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
			p_return_status := FND_API.G_RET_STS_ERROR;

			-- 4537865 : RESET OUT PARAM VALUES
		        p_delete_task_ok_flag := 'N' ;  -- Made this value as 'N' as per logic in the API

			FND_MSG_PUB.Count_And_Get
			(
				p_encoded => 'F', -- Added for Issues found during Unit Testing 4096218
				p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		        -- 4537865 : RESET OUT PARAM VALUES
                        p_delete_task_ok_flag := 'N' ;  -- Made this value as 'N' as per logic in the API

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
	THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

			-- 4537865 : RESET OUT PARAM VALUES
                        p_delete_task_ok_flag := 'N' ;  -- Made this value as 'N' as per logic in the API

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;
			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END Check_Delete_Task_Ok_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Add_Subtask_OK_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if it is OK to add subtask, 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--			, Convert_Pm_Taskref_To_Id
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		20-NOV-96	Update  lwerker Changed handling of error messages
--		02-DEC-96	Update  lwerker Removed Savepoint and Rollbacks
--

PROCEDURE Check_Add_Subtask_OK_pvt
(p_api_version_number		IN	NUMBER
,p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT	 NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
, p_msg_count			OUT	 NOCOPY NUMBER  /*Added the nocopy check for 4537865 */
, p_msg_data			OUT	NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_add_subtask_ok_flag		OUT	NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
)
IS
l_api_name			CONSTANT 	VARCHAR2(30)		:= 'Check_Add_Subtask_Ok_Pvt';
l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER	:= 0;
l_task_id_out					NUMBER	:= 0;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;


	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;

	PA_PROJECT_PVT.Convert_pm_projref_to_id
		 ( p_pm_project_reference	=>	p_pm_project_reference
		 , p_pa_project_id 		=>	p_project_id
		 , p_out_project_id 		=>	l_project_id_out
		 , p_return_status 		=>	l_return_status 	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;


	PA_PROJECT_PVT.Convert_pm_taskref_to_id
	 	( p_pa_project_id	=>	l_project_id_out
	 	, p_pa_task_id		=>	p_task_id
		, p_pm_task_reference	=>	p_pm_task_reference
		, p_out_task_id		=>	l_task_id_out
	 	, p_return_status	=>	l_return_status	 );

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN

		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id_out );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id_out );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> ''
    ,p_task_reference => p_pm_task_reference
    ,p_task_id => l_task_id_out);

	PA_TASK_UTILS.Check_Create_Subtask_Ok
		( x_task_id	=>	l_task_id_out
--bug3010538                , x_validation_mode => 'R'    --bug 2947492
		, x_err_code	=>	l_err_code
		, x_err_stage	=>	l_err_stage
		, x_err_stack	=>	l_err_stack	);


    	IF l_err_code > 0
    	THEN
		p_add_subtask_ok_flag := 'N';
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      IF NOT pa_project_pvt.check_valid_message(l_err_stage)
      THEN
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_ADD_SUBTASK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'ADDT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'ADDST'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      END IF;
      END IF;

    	ELSIF l_err_code < 0
    	THEN
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		IF NOT pa_project_pvt.check_valid_message(l_err_stage)
		THEN
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_ADD_SUBTASK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'ADDT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
		ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'ADDST'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
		END IF;
	   END IF;

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSE --l_err_code = 0

		p_add_subtask_ok_flag := 'Y';

    	END IF;


EXCEPTION

		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;

			-- 4537865 RESET OUT param value
			p_add_subtask_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        -- 4537865 RESET OUT param value
                        p_add_subtask_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        -- 4537865 RESET OUT param value
                        p_add_subtask_ok_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;
			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END Check_Add_Subtask_Ok_pvt;


--------------------------------------------------------------------------------
-- Name:		Check_Unique_Task_Ref_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the task reference does not exist,
--			 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		20-NOV-96	Update  lwerker Added use of cursor and changed handling of error messages
--		02-DEC-96	Update  lwerker Removed Savepoint and Rollbacks
--
PROCEDURE Check_Unique_Task_Ref_pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT NOCOPY	NUMBER /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_pm_task_reference		IN	VARCHAR2
, p_unique_task_ref_flag	OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
)
IS

   CURSOR l_unique_task_ref_csr (p_project_id IN NUMBER
   				,p_pm_task_reference IN VARCHAR2 )
   IS
   SELECT 	1
   FROM 	pa_tasks
   WHERE	pm_task_reference 	= p_pm_task_reference
   AND		project_id  		= p_project_id;



l_api_name			CONSTANT  	VARCHAR2(30) 	:= 'Check_Unique_Task_Ref_Pvt';
l_value_conversion_error			BOOLEAN		:= FALSE;
l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER		:=  -1;
l_err_stage					VARCHAR2(2000)	:= NULL;
l_err_stack					VARCHAR2(2000)	:= NULL;

l_project_id_out				NUMBER		:= 0;
l_task_id_out					NUMBER		:= 0;
l_dummy						NUMBER;
l_exists_status					NUMBER		:= 1;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;

	PA_PROJECT_PVT.Convert_pm_projref_to_id
		 ( p_pm_project_reference	=>	p_pm_project_reference
		 , p_pa_project_id 		=>	p_project_id
		 , p_out_project_id 		=>	l_project_id_out
		 , p_return_status 		=>	l_return_status 	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	OPEN l_unique_task_ref_csr( l_project_id_out, p_pm_task_reference );
	FETCH l_unique_task_ref_csr INTO l_dummy;

    	IF l_unique_task_ref_csr%FOUND
    	THEN
		p_unique_task_ref_flag := 'N';

	ELSE
		p_unique_task_ref_flag := 'Y';

    	END IF;

    	CLOSE l_unique_task_ref_csr;


EXCEPTION
		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;
			-- 4537865 : RESET OUT param values.
			p_unique_task_ref_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			-- 4537865 : RESET OUT param values.
                        p_unique_task_ref_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			-- 4537865 : RESET OUT param values.
                        p_unique_task_ref_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END Check_Unique_Task_Ref_pvt;


--------------------------------------------------------------------------------
-- Name:		Check_Unique_Project_Ref_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the project reference does not exist
--			, 'N' otherwise.
--
-- Called Subprograms: none.
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--
--		02-DEC-96	Update  lwerker Added use of cursor and changed handling of error messages
--						Removed Savepoint and Rollbacks
--
PROCEDURE Check_Unique_Project_Ref_pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT NOCOPY	NUMBER /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_pm_project_reference	IN	VARCHAR2
, p_unique_project_ref_flag	OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
)
IS

   CURSOR l_unique_project_ref_csr (p_pm_project_reference IN VARCHAR2	)
   IS
   SELECT 	1
   FROM 	pa_projects
   WHERE	pm_project_reference  		= p_pm_project_reference;


l_api_name			CONSTANT  	VARCHAR2(30) 		:= 'Check_Unique_Project_Ref_Pvt';

l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER	:= 0;
l_task_id_out					NUMBER	:= 0;
l_dummy						NUMBER	:= 0;
l_exists_status					NUMBER	:= 1;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;

	OPEN l_unique_project_ref_csr( p_pm_project_reference );
	FETCH l_unique_project_ref_csr INTO l_dummy;

    	IF l_unique_project_ref_csr%FOUND
    	THEN
		p_unique_project_ref_flag := 'N';

	ELSE
		p_unique_project_ref_flag := 'Y';

    	END IF;

    	CLOSE l_unique_project_ref_csr;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
		p_return_status := FND_API.G_RET_STS_ERROR;
		-- 4537865 : RESET OUT param values
		p_unique_project_ref_flag := 'N';

		FND_MSG_PUB.Count_And_Get
		(   p_count		=>	p_msg_count	,
		    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                -- 4537865 : RESET OUT param values
                p_unique_project_ref_flag := 'N';

		FND_MSG_PUB.Count_And_Get
		(   p_count		=>	p_msg_count	,
		    p_data		=>	p_msg_data	);

	WHEN OTHERS
	THEN
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                -- 4537865 : RESET OUT param values
                p_unique_project_ref_flag := 'N';

		IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
		END IF;

		FND_MSG_PUB.Count_And_Get
		(   p_count		=>	p_msg_count	,
		    p_data		=>	p_msg_data	);

END Check_Unique_Project_Ref_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Delete_Project_OK_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the project can be deleted, 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		02-DEC-96	Update  lwerker Changed handling of error messages
--						Removed Savepoint and Rollbacks
--

PROCEDURE Check_Delete_Project_OK_pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
, p_msg_count			OUT NOCOPY 	NUMBER  /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_delete_project_ok_flag	OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
)
IS
l_api_name			CONSTANT 	VARCHAR2(30)		:= 'Check_Delete_Project_Ok_Pvt';
l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER			:= 0;
l_task_id_out					NUMBER			:= 0;

l_amg_segment1       VARCHAR2(25);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;


	PA_PROJECT_PVT.Convert_pm_projref_to_id
	(	 p_pm_project_reference	=>	p_pm_project_reference
		 ,  p_pa_project_id 	=>	p_project_id
		 ,  p_out_project_id 	=>	l_project_id_out
		 ,  p_return_status 	=>	l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN

		RAISE  FND_API.G_EXC_ERROR;
	END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id_out );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

	PA_PROJECT_UTILS.Check_Delete_Project_Ok
		 ( x_project_id  	  =>	l_project_id_out
--bug3010538                , x_validation_mode       => 'R'         --bug 2947492
		, x_err_code	=>	l_err_code
		 , x_err_stage	=>	l_err_stage
		 , x_err_stack	=>	l_err_stack);

    	IF l_err_code > 0
    	THEN
		p_delete_project_ok_flag := 'N';
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      IF NOT pa_project_pvt.check_valid_message(l_err_stage)
      THEN
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_DEL_PROJECT_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELP'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      END IF;
      END IF;

    	ELSIF l_err_code < 0
    	THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      IF NOT pa_project_pvt.check_valid_message(l_err_stage)
      THEN
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHECK_DEL_PROJECT_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELP'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      END IF;
      END IF;

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSE --l_err_code = 0

		p_delete_project_ok_flag := 'Y';

    	END IF;


EXCEPTION

		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;
			-- 4537865 : RESET OUT PARAM VALUES
			p_delete_project_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_delete_project_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_delete_project_ok_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END Check_Delete_Project_Ok_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Change_Parent_OK_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the task can be moved to another parent; 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		02-DEC-96	Update  lwerker	Changed handling of return values.
--						Removed Savepoint and Rollbacks
--
PROCEDURE Check_Change_Parent_OK_pvt
(p_api_version_number		 IN	NUMBER
, p_init_msg_list		 IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		 OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
, p_msg_count			 OUT NOCOPY	NUMBER  /*Added the nocopy check for 4537865 */
, p_msg_data			 OUT	 NOCOPY VARCHAR2  /*Added the nocopy check for 4537865 */
, p_project_id			 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	 IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		 IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_new_parent_task_id		 IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_new_parent_task_reference IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_parent_ok_flag	 OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
)
IS

l_api_name			CONSTANT 	VARCHAR2(30)		:= 'Check_Change_Parent_Ok_Pvt';

l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER			:= 0;
l_task_id_out					NUMBER			:= 0;
l_parent_task_id_out				NUMBER			:= 0;
l_top_task_id					NUMBER			:= 0;
l_new_parent_top_task_id			NUMBER			:= 0;
l_change_parent_ok_flag				VARCHAR2(1)		:= NULL;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;


	PA_PROJECT_PVT.Convert_pm_projref_to_id
	(	 p_pm_project_reference	=>	p_pm_project_reference
		 ,  p_pa_project_id 	=>	p_project_id
		 ,  p_out_project_id 	=>	l_project_id_out
		 ,  p_return_status 	=>	l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	PA_PROJECT_PVT.Convert_pm_taskref_to_id
	 	( 	p_pa_project_id		=>	l_project_id_out
	 	 ,  	p_pa_task_id		=>	p_task_id
		 ,  	p_pm_task_reference	=>	p_pm_task_reference
		 ,  	p_out_task_id		=>	l_task_id_out
	 	 ,  	p_return_status		=>	l_return_status
	 	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	PA_PROJECT_PVT.Convert_pm_taskref_to_id
	 ( p_pa_project_id		=>	l_project_id_out
	   ,  p_pa_task_id		=>	p_new_parent_task_id
	   ,  p_pm_task_reference	=>	p_pm_new_parent_task_reference
	   ,  p_out_task_id		=>	l_parent_task_id_out
 	   ,  p_return_status		=>	l_return_status );

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	BEGIN
		SELECT 	top_task_id
		INTO	l_top_task_id
		FROM   	pa_tasks
		WHERE 	task_id = l_task_id_out;

		IF (l_task_id_out = l_top_task_id)
		THEN
			l_change_parent_ok_flag := 'N';  --Top tasks can not be moved.
		END IF;

	EXCEPTION
		WHEN OTHERS
		THEN RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;


	IF l_change_parent_ok_flag IS NULL
	THEN
	   BEGIN
		SELECT 	top_task_id
		INTO	l_new_parent_top_task_id
		FROM   	pa_tasks
		WHERE 	task_id = l_parent_task_id_out;

		IF (l_top_task_id  <> l_new_parent_top_task_id )
		THEN
			l_change_parent_ok_flag := 'N';  --a task can not be moved to another top task
		END IF;

	   EXCEPTION
		WHEN OTHERS
		THEN RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END;
	END IF;

	IF l_change_parent_ok_flag IS NULL
	THEN
		p_change_parent_ok_flag := 'Y';
	ELSE
		p_change_parent_ok_flag := l_change_parent_ok_flag;
	END IF;

EXCEPTION
		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;

			-- 4537865
			p_change_parent_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865
                        p_change_parent_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        -- 4537865
                        p_change_parent_ok_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END Check_Change_Parent_OK_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Change_Proj_Org_OK_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the project organization can be changed, 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		02-DEC-96	Update  lwerker Changed error handling
--						Removed Savepoint and Rollbacks
--

PROCEDURE Check_Change_Proj_Org_OK_pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT NOCOPY	NUMBER  /*Added the nocopy check for 4537865 */
, p_msg_data			OUT	 NOCOPY VARCHAR2 /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_change_project_org_ok_flag	OUT NOCOPY	VARCHAR2  /*Added the nocopy check for 4537865 */
)
IS

l_api_name			CONSTANT  	VARCHAR2(30) 		:= 'Check_Change_Proj_Org_OK_Pvt';

l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER			:= 0;
l_task_id_out					NUMBER			:= 0;

l_amg_segment1       VARCHAR2(25);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;


	PA_PROJECT_PVT.Convert_pm_projref_to_id
	(	 p_pm_project_reference	=>	p_pm_project_reference
		 ,  p_pa_project_id 	=>	p_project_id
		 ,  p_out_project_id 	=>	l_project_id_out
		 ,  p_return_status 	=>	l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id_out );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

	PA_PROJECT_UTILS.Change_Pt_Org_Ok
	       ( x_project_id  	=>	l_project_id_out
		, x_err_code	=>	l_err_code
		, x_err_stage	=>	l_err_stage
		, x_err_stack	=>	l_err_stack);

    	IF l_err_code > 0
    	THEN
		p_change_project_org_ok_flag := 'N';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
                  IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_PR_CANT_CHG_PROJ_TYPE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  ELSE
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
         END IF;

    	ELSIF l_err_code < 0
    	THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
                  IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_PR_CANT_CHG_PROJ_TYPE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  ELSE
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
         END IF;

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSE --l_err_code = 0

		p_change_project_org_ok_flag := 'Y';

    	END IF;

EXCEPTION
		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;
			-- 4537865 : RESET OUT PARAM VALUES
			 p_change_project_org_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                         p_change_project_org_ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        -- 4537865 : RESET OUT PARAM VALUES
                         p_change_project_org_ok_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;
			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END Check_Change_Proj_Org_Ok_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Unique_Task_Number_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if the task number does NOT already exist; 'N' otherwise.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		02-DEC-96	Update	lwerker	Changed handling of return values
--						Removed Savepoint and Rollbacks
--

PROCEDURE Check_Unique_Task_Number_pvt
(p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT	 NOCOPY NUMBER /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number			IN	VARCHAR2
, p_unique_task_number_flag	OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
)
IS

   CURSOR l_unique_task_num_csr (p_project_id IN NUMBER
   				,p_task_number IN VARCHAR2 )
   IS
   SELECT 	1
   FROM 	pa_tasks
   WHERE	task_number 		= p_task_number
   AND		project_id  		= p_project_id;


l_api_name			CONSTANT  	VARCHAR2(30) 		:= 'Check_Unique_Task_Number_Pvt';

l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER	:= 0;
l_dummy						NUMBER	:= 0;


BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;


	PA_PROJECT_PVT.Convert_pm_projref_to_id
	(	 p_pm_project_reference	=>	p_pm_project_reference
		 ,  p_pa_project_id 	=>	p_project_id
		 ,  p_out_project_id 	=>	l_project_id_out
		 ,  p_return_status 	=>	l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	OPEN l_unique_task_num_csr( l_project_id_out, p_task_number );
	FETCH l_unique_task_num_csr INTO l_dummy;

    	IF l_unique_task_num_csr%FOUND
    	THEN
		p_unique_task_number_flag := 'N';

	ELSE
		p_unique_task_number_flag := 'Y';

    	END IF;

    	CLOSE l_unique_task_num_csr;


EXCEPTION
		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
			p_unique_task_number_flag := 'N';

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_unique_task_number_flag := 'N';

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_unique_task_number_flag := 'N';

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END Check_Unique_Task_Number_pvt;

--------------------------------------------------------------------------------
-- Name:		Check_Task_Numb_Change_Ok_pvt
-- Type:		PL/SQL Procedure
-- Decscription:	This procedure returns 'Y' if it is OK to change a LOWEST task.
--			Otherwise, it returns 'N'.
--
-- Called Subprograms: Convert_Pm_Projref_To_Id
--			, Convert_Pm_Taskref_To_Id
-- History:	15-AUG-96	Created	jwhite
--		23-AUG-96	Update	jwhite	replaced local convert procedure with library
--						procedure.
--		26-AUG-96	Update	jwhite	Applied latest messaging standards.
--		02-DEC-96	Update	lwerker	Changed the way return values are handled
--						Removed Savepoint and Rollbacks

PROCEDURE Check_Task_Numb_Change_Ok_pvt
( p_api_version_number		IN	NUMBER
, p_init_msg_list		IN	VARCHAR2	:= FND_API.G_FALSE
, p_return_status		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_msg_count			OUT	NOCOPY NUMBER /*Added the nocopy check for 4537865 */
, p_msg_data			OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
, p_project_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_project_reference	IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_id			IN	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, p_pm_task_reference		IN	VARCHAR2	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_task_number_change_Ok_flag	OUT	 NOCOPY VARCHAR2 /*Added the nocopy check for 4537865 */
)
IS

l_api_name			CONSTANT  	VARCHAR2(30) 		:= ' Check_Task_Numb_Change_Ok_Pvt';

l_return_status					VARCHAR2(1);
l_msg_count					INTEGER;

l_err_code					NUMBER			:=  -1;
l_err_stage					VARCHAR2(2000)		:= NULL;
l_err_stack					VARCHAR2(2000)		:= NULL;

l_project_id_out				NUMBER	:= 0;
l_task_id_out					NUMBER	:= 0;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

	IF NOT FND_API.Compatible_API_Call ( g_api_version_number	,
    	    	    	    	    	 p_api_version_number	,
    	    	    	    	    	 l_api_name 	    	,
    	    	    	    	    	 G_PKG_NAME 	    	)
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;

	IF FND_API.TO_BOOLEAN( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;


	PA_PROJECT_PVT.Convert_pm_projref_to_id
	(	 p_pm_project_reference	=>	p_pm_project_reference
		 ,  p_pa_project_id 	=>	p_project_id
		 ,  p_out_project_id 	=>	l_project_id_out
		 ,  p_return_status 	=>	l_return_status
	);

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

	PA_PROJECT_PVT.Convert_pm_taskref_to_id
	 (	 p_pa_project_id		=>	l_project_id_out
	 	  ,  p_pa_task_id		=>	p_task_id
		   ,  p_pm_task_reference	=>	p_pm_task_reference
		   ,  p_out_task_id		=>	l_task_id_out
	 	   ,  p_return_status		=>	l_return_status
	 );

	IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
	THEN
		RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
	THEN
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id_out );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id_out );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> ''
    ,p_task_reference => p_pm_task_reference
    ,p_task_id => l_task_id_out);

	PA_TASK_UTILS.Change_Lowest_Task_Num_Ok
	(	x_task_id	=>	l_task_id_out
		 , x_err_code	=>	l_err_code
		 , x_err_stage	=>	l_err_stage
		 , x_err_stack	=>	l_err_stack
	);

    	IF l_err_code > 0
    	THEN
		p_task_number_change_Ok_flag := 'N';
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
                  IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHANGE_TASK_NUM_OK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'MODT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  ELSE
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'MODT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
         END IF;

    	ELSIF l_err_code < 0
    	THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
                  IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                  THEN
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_CHANGE_TASK_NUM_OK_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'MODT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  ELSE
                      pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'MODT'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                  END IF;
         END IF;

	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSE --l_err_code = 0

		p_task_number_change_Ok_flag := 'Y';

    	END IF;


EXCEPTION
		WHEN FND_API.G_EXC_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
			p_task_number_change_Ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_task_number_change_Ok_flag := 'N' ;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

		WHEN OTHERS
		THEN
			p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        -- 4537865 : RESET OUT PARAM VALUES
                        p_task_number_change_Ok_flag := 'N' ;

			IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
				FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
			END IF;

			FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END Check_Task_Numb_Change_Ok_Pvt;

--====================================================================================
--Name:               Validate_billing_info_Pvt
--
--Type:               Procedure
--Description:        This procedure can be used to validate billing information
--		      for contract type projects
--
--
--Called subprograms: none
--
--
--
--History:
--    automn-1996        Ramesh K.    Created
--
PROCEDURE Validate_billing_info_Pvt
          (p_project_id		    IN    NUMBER,  --Added for Bug 5643876
	   p_project_class_code     IN    VARCHAR2,
           p_in_task_rec            IN    pa_project_pub.task_in_rec_type,
           p_return_status         OUT NOCOPY    VARCHAR2  /*Added the nocopy check for 4537865 */
) IS
--Added for Bug 5643876
l_project_id       pa_projects_all.project_id%type;

/* Commented for Bug No 4721987
CURSOR l_labor_bill_rate_org_csr (l_org_id IN NUMBER ) IS
SELECT 'x' FROM
pa_organizations_v o,
pa_std_bill_rate_schedules brs
WHERE o.organization_id = l_org_id
AND   o.organization_id = brs.organization_id
AND   brs.schedule_type <> 'NON-LABOR';*/

--- Start of Addition for Bug no 4721987
/*Start of changes for Bug 5643876. Modifying the cursors l_job_brs_csr and l_emp_brs_csr.*/

/*CURSOR l_job_brs_csr (l_job_rate_schdid IN NUMBER) IS
SELECT 'x'
FROM
pa_std_bill_rate_schedules brs
WHERE  brs.schedule_type = 'JOB'
AND brs.BILL_RATE_SCH_ID = l_job_rate_schdid;

CURSOR l_emp_brs_csr (l_emp_rate_schdid IN NUMBER) IS
SELECT 'x'
FROM
pa_std_bill_rate_schedules brs
WHERE  brs.schedule_type = 'EMPLOYEE'
AND brs.BILL_RATE_SCH_ID = l_emp_rate_schdid;*/

CURSOR l_job_brs_csr( l_job_rate_schdid NUMBER)
IS
SELECT       'x'
FROM         pa_std_bill_rate_schedules_all brs, pa_project_types_all pt, pa_projects pa
WHERE        bill_rate_sch_id = l_job_rate_schdid
AND          pa.project_id = l_project_id
AND          brs.job_group_id = pt.bill_job_group_id
and          brs.schedule_type = 'JOB'
AND          pa.project_type = pt.project_type
AND	     pa.org_id = pt.org_id              --added for Bug 5675391
AND          ( pa.multi_currency_BILLING_flag = 'Y'
OR           (pa.multi_currency_billing_flag = 'N'
AND          brs.rate_sch_currency_code = pa.projfunc_currency_code))
AND          ((pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'Y')
or  (pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'N'
and              brs.org_id = pa.org_id))
and (brs.share_across_ou_flag = 'Y'
     OR  (brs.share_across_ou_flag = 'N'
          and brs.org_id = pa.org_id
          ));

CURSOR l_emp_brs_csr( l_emp_rate_schdid NUMBER)
IS
SELECT       'x'
FROM         pa_std_bill_rate_schedules_all brs, pa_projects pa
WHERE        brs.bill_rate_sch_id = l_emp_rate_schdid
AND          pa.project_id = l_project_id
and          brs.schedule_type = 'EMPLOYEE'
AND          ( pa.multi_currency_BILLING_flag = 'Y'
OR           (pa.multi_currency_billing_flag='N'
AND          brs.rate_sch_currency_code = pa.projfunc_currency_code))
AND          ((pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'Y')
or  (pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'N'
and              brs.org_id = pa.org_id))
and (brs.share_across_ou_flag = 'Y'
     OR  (brs.share_across_ou_flag = 'N'
          and brs.org_id = pa.org_id
          ));

/* End of changes for bug 5643876*/

-- End of addition for bug 4721987

CURSOR l_non_labor_bill_rate_org_csr (l_org_id IN NUMBER ) IS
SELECT 'x' FROM
pa_organizations_v o,
pa_std_bill_rate_schedules brs
WHERE o.organization_id = l_org_id
AND   o.organization_id = brs.organization_id
AND   brs.schedule_type = 'NON-LABOR';

/* Commented for Bug no 4721987
CURSOR l_labor_brs_csr (l_org_id IN NUMBER ,l_bill_rate_schdl IN VARCHAR2) IS
SELECT 'x'
FROM
pa_std_bill_rate_schedules brs,
pa_lookups l
WHERE organization_id = l_org_id
AND brs.schedule_type <> 'NON-LABOR'
AND l.lookup_type = 'SCHEDULE TYPE'
AND l.lookup_code (+) = brs.schedule_type
AND brs.std_bill_rate_schedule = l_bill_rate_schdl;*/

CURSOR l_non_labor_brs_csr (l_org_id IN NUMBER,l_bill_rate_schdl IN VARCHAR2) IS
SELECT 'x'
FROM
pa_std_bill_rate_schedules brs,
pa_lookups l
WHERE organization_id = l_org_id
AND brs.schedule_type = 'NON-LABOR'
AND l.lookup_type = 'SCHEDULE TYPE'
AND l.lookup_code (+) = brs.schedule_type
AND brs.std_bill_rate_schedule = l_bill_rate_schdl;

CURSOR l_burden_sch_csr (l_sch_id IN NUMBER ) IS
SELECT 'x'
FROM pa_lookups l, pa_ind_rate_schedules irs
WHERE l.lookup_type = 'IND RATE SCHEDULE TYPE'
AND l.lookup_code = irs.ind_rate_schedule_type
AND irs.ind_rate_sch_id = l_sch_id
AND irs.project_id IS NULL
AND TRUNC(SYSDATE) BETWEEN TRUNC(irs.start_date_active )
AND NVL (irs.end_date_active,TRUNC(SYSDATE)) ;

l_task_rec		pa_project_pub.task_in_rec_type;
l_api_name	        CONSTANT    VARCHAR2(30)  := 'Validate_Billing_Info_Pvt';
l_dummy                 VARCHAR2(1);
l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);
l_amg_project_id         NUMBER;


--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   project_id
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

-- Initialize p_return_status as Success
p_return_status := FND_API.G_RET_STS_SUCCESS ;
l_project_id := p_project_id;  -- Added for bug 5643876
l_task_rec := p_in_task_rec;

-- Get segment1 for AMG messages
/*
   OPEN l_amg_task_csr( l_task_rec.pa_task_id );
   FETCH l_amg_task_csr INTO l_amg_project_id;
   CLOSE l_amg_task_csr;

   OPEN l_amg_project_csr( l_amg_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

   l_amg_task_number := l_task_rec.pa_task_number;
*/

 -- Need to validate all fields if CONTRACT project
IF p_project_class_code = 'CONTRACT' THEN

    IF (l_task_rec.labor_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND l_task_rec.labor_sch_type IS NOT NULL)
    AND l_task_rec.labor_sch_type NOT IN ('I','B')
    THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_LABOR_SCH_TYPE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF (l_task_rec.non_labor_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND l_task_rec.non_labor_sch_type IS NOT NULL)
    AND l_task_rec.non_labor_sch_type NOT IN ('I','B')
    THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_NON_LABOR_SCH_TYPE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;
/* Commented for Bug No 4721987
    IF l_task_rec.labor_sch_type = 'I'  -- (I- burden schedule B-Bill rate sch)
      					-- ensure that bill rate orgid is not supplied
    AND (l_task_rec.labor_bill_rate_org_id IS NOT NULL
    AND l_task_rec.labor_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
    THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_LBR_ORG_ID_NOT_VALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;*/

    IF l_task_rec.non_labor_sch_type = 'I'	--(I- burden schedule B-Bill rate sch)
       						-- ensure that bill rate orgid is not supplied
    AND (l_task_rec.non_labor_bill_rate_org_id IS NOT NULL
    AND  l_task_rec.non_labor_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
    THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_NON_LBR_ORG_ID_NOT_VALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;


    IF (l_task_rec.labor_sch_type = 'I' OR l_task_rec.non_labor_sch_type = 'I' )
    THEN

    -- ensure that invoice schedule is specified if labor or non labor
    -- sch types are burden schedules

       IF l_task_rec.inv_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       OR l_task_rec.inv_ind_rate_sch_id IS NULL
       THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INV_IND_RATE_SCH_ID_REQD'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
         END IF;
         RAISE  FND_API.G_EXC_ERROR;
       END IF;

       -- ensure that revenue schedule is specified
       IF l_task_rec.rev_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       OR l_task_rec.rev_ind_rate_sch_id IS NULL
       THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_REV_IND_RATE_SCH_ID_REQD'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
         END IF;
         RAISE  FND_API.G_EXC_ERROR;
       END IF;

       -- validate invoice schedule
       OPEN l_burden_sch_csr (l_task_rec.inv_ind_rate_sch_id);
       FETCH l_burden_sch_csr INTO l_dummy;

       IF l_burden_sch_csr%NOTFOUND
       THEN

          CLOSE l_burden_sch_csr;
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	  THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INV_IND_RATE_SCH_ID_INV'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
          END IF;
          RAISE  FND_API.G_EXC_ERROR;

       ELSE
          CLOSE l_burden_sch_csr;
       END IF;

       OPEN l_burden_sch_csr (l_task_rec.rev_ind_rate_sch_id);
       FETCH l_burden_sch_csr INTO l_dummy;

       IF l_burden_sch_csr%NOTFOUND
       THEN
          CLOSE l_burden_sch_csr;
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	  THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_REV_IND_RATE_SCH_ID_INV'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
          END IF;
          RAISE  FND_API.G_EXC_ERROR;

       ELSE
          CLOSE l_burden_sch_csr;
       END IF;

    END IF;
/*Commented for Bug no 4721987
    IF l_task_rec.labor_sch_type = 'B' -- (I- burden schedule B-Bill rate sch)
    THEN

         IF (l_task_rec.labor_bill_rate_org_id IS NULL
         OR  l_task_rec.labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
         THEN
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_LBR_ORG_ID_REQD'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

         OPEN l_labor_bill_rate_org_csr (l_task_rec.labor_bill_rate_org_id);
         FETCH l_labor_bill_rate_org_csr INTO l_dummy;

         IF l_labor_bill_rate_org_csr%NOTFOUND
         THEN
            CLOSE l_labor_bill_rate_org_csr;
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_LBR_ORG_ID_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;

         ELSE
            CLOSE l_labor_bill_rate_org_csr;
         END IF;

         IF (l_task_rec.labor_std_bill_rate_schdl IS NOT NULL
         AND l_task_rec.labor_std_bill_rate_schdl <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
         THEN
             OPEN l_labor_brs_csr (l_task_rec.labor_bill_rate_org_id,
                                   l_task_rec.labor_std_bill_rate_schdl );
             FETCH l_labor_brs_csr INTO l_dummy;

             IF l_labor_brs_csr%NOTFOUND
             THEN
                CLOSE l_labor_brs_csr;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_LBR_BRS_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

             ELSE
                CLOSE l_labor_brs_csr;
             END IF;
         END IF;

    END IF;*/

    /*Start of addition for Bug No 4721987
    For labor_sch_type = 'B' If PJR is licensed then a valid job_bill_rate_schedule_id is mandatory
 Else either a valid job_bill_rate_schedule_id or emp_bill_rate_schedule_id should be present*/

				IF l_task_rec.labor_sch_type = 'B' -- (I- burden schedule B-Bill rate sch)
    THEN
				    IF PA_INSTALL.IS_PRM_LICENSED = 'Y'
								THEN
								    IF (l_task_rec.job_bill_rate_schedule_id IS NULL
                OR  l_task_rec.job_bill_rate_schedule_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
												THEN
												    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	               THEN
                    pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_JOB_SCH_ID_NOT_NULL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'GENERAL'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
																 END IF;
																	RAISE  FND_API.G_EXC_ERROR;
												 END IF;
								ELSE
								    IF (l_task_rec.job_bill_rate_schedule_id IS NULL
                OR  l_task_rec.job_bill_rate_schedule_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) AND
																(l_task_rec.emp_bill_rate_schedule_id IS NULL
                OR  l_task_rec.emp_bill_rate_schedule_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
												 THEN
																IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	               THEN
                    pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_EJ_BILL_RT_SCH_NOT_NULL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'GENERAL'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
																 END IF;
																	RAISE  FND_API.G_EXC_ERROR;
													END IF;
								END IF;  -- end PA_INSTALL.IS_PRM_LICENSED = 'Y'
								IF (l_task_rec.job_bill_rate_schedule_id IS NOT NULL
                AND  l_task_rec.job_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
								THEN
								     OPEN l_job_brs_csr (l_task_rec.job_bill_rate_schedule_id );
             FETCH l_job_brs_csr INTO l_dummy;

             IF l_job_brs_csr%NOTFOUND
             THEN
                CLOSE l_job_brs_csr;
		              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		              THEN
												        pa_interface_utils_pub.map_new_amg_msg
															     ( p_old_message_code => 'PA_JOB_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'GENERAL'
                      ,p_attribute1       => ''
                      ,p_attribute2       => ''
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                 END IF;
                 RAISE  FND_API.G_EXC_ERROR;
              ELSE
                 CLOSE l_job_brs_csr;
              END IF;
								END IF;
								IF (l_task_rec.emp_bill_rate_schedule_id IS NOT NULL
                AND  l_task_rec.emp_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
								THEN
								     OPEN l_emp_brs_csr (l_task_rec.emp_bill_rate_schedule_id );
             FETCH l_emp_brs_csr INTO l_dummy;

             IF l_emp_brs_csr%NOTFOUND
             THEN
                CLOSE l_emp_brs_csr;
		              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		              THEN
												        pa_interface_utils_pub.map_new_amg_msg
															     ( p_old_message_code => 'PA_INVALID_EMP_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'GENERAL'
                      ,p_attribute1       => ''
                      ,p_attribute2       => ''
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                 END IF;
                 RAISE  FND_API.G_EXC_ERROR;
              ELSE
                 CLOSE l_emp_brs_csr;
              END IF;
								END IF;

					END IF;   -- IF l_task_rec.labor_sch_type = 'B'

		/*	End of addition for bug 4721987	*/

    IF l_task_rec.non_labor_sch_type = 'B'--(I- burden schedule B-Bill rate sch)
    THEN

         IF (l_task_rec.non_labor_bill_rate_org_id IS NULL
         OR  l_task_rec.non_labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
         THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_NON_LBR_ORG_ID_REQD'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             	END IF;
             	RAISE  FND_API.G_EXC_ERROR;
         END IF;

         OPEN l_non_labor_bill_rate_org_csr
                 (l_task_rec.non_labor_bill_rate_org_id);
         FETCH l_non_labor_bill_rate_org_csr INTO l_dummy;

         IF l_non_labor_bill_rate_org_csr%NOTFOUND
         THEN
            	CLOSE l_non_labor_bill_rate_org_csr;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_NON_LBR_ORG_ID_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            	END IF;
            	RAISE  FND_API.G_EXC_ERROR;

         ELSE
            CLOSE l_non_labor_bill_rate_org_csr;
         END IF;

         IF (l_task_rec.non_labor_std_bill_rate_schdl IS NOT NULL
         AND l_task_rec.non_labor_std_bill_rate_schdl <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
         THEN

             OPEN l_non_labor_brs_csr (l_task_rec.non_labor_bill_rate_org_id,
                                   l_task_rec.non_labor_std_bill_rate_schdl );
             FETCH l_non_labor_brs_csr INTO l_dummy;

             IF l_non_labor_brs_csr%NOTFOUND
             THEN
                CLOSE l_non_labor_brs_csr;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_NON_LBR_BRS_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

             ELSE
                CLOSE l_non_labor_brs_csr;
             END IF;
         END IF;

    END IF;
END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
    	     p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
	     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	        THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	     END IF;

END Validate_billing_info_Pvt;

--====================================================================================
--Name:               check_start_end_date_Pvt
--Type:               Procedure
--Description:        This procedure can be used to pass old and new start_dates
--		      and old and new end_dates, from the PUBLIC API's. This procedure
--		      will check whether the new situation is going to be valid, and returns
--		      flags indicating whether start_date or end_date needs updating.
--
--
--Called subprograms: none
--
--
--
--History:
--    03-DEC-1996        L. de Werker    Created
--
PROCEDURE check_start_end_date_Pvt
( p_return_status			OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
 ,p_old_start_date			IN	DATE
 ,p_new_start_date			IN	DATE
 ,p_old_end_date			IN	DATE
 ,p_new_end_date			IN	DATE
 ,p_update_start_date_flag		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
 ,p_update_end_date_flag		OUT NOCOPY	VARCHAR2 /*Added the nocopy check for 4537865 */
)
IS

   l_api_name			 CONSTANT	VARCHAR2(30) 		:= 'check_start_end_date_Pvt';

   l_start_date			DATE;
   l_end_date			DATE;

BEGIN

p_return_status := FND_API.G_RET_STS_SUCCESS;

IF p_new_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
AND p_new_start_date IS NOT NULL 		--redundant, but added for clarity
THEN
	IF p_new_start_date <> NVL(p_old_start_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
	THEN
		p_update_start_date_flag := 'Y';
		l_start_date := p_new_start_date;
	ELSE
		p_update_start_date_flag := 'N';
		l_start_date := p_new_start_date;
	END IF;

	IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
	AND p_new_end_date IS NOT NULL	--redundant, but added for clarity
	THEN
		IF p_new_end_date <> NVL(p_old_end_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
		THEN
			p_update_end_date_flag := 'Y';
			l_end_date := p_new_end_date;
		ELSE
			p_update_end_date_flag := 'N';
			l_end_date := p_new_end_date;
		END IF;

		IF l_start_date > l_end_date
		THEN
			IF FND_MSG_PUB.check_msg_level
                          (FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
		END IF;

	ELSIF p_new_end_date IS NULL
	THEN
		IF p_old_end_date IS NOT NULL
		THEN
			p_update_end_date_flag := 'Y';
		ELSE
			p_update_end_date_flag := 'N';
		END IF;
	ELSE

		p_update_end_date_flag := 'N';

		IF p_old_end_date IS NULL
		THEN
			NULL;
		ELSE

		    IF l_start_date > p_old_end_date THEN
			IF FND_MSG_PUB.check_msg_level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	   	    END IF;
		END IF;
	END IF;

ELSIF p_new_start_date IS NULL
THEN
	IF p_old_start_date IS NOT NULL
	THEN
		p_update_start_date_flag := 'Y';
	ELSE
		p_update_start_date_flag := 'N';
	END IF;

	IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
	AND p_new_end_date IS NOT NULL
	THEN
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_DATES_INVALID_3'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
		END IF;

		RAISE FND_API.G_EXC_ERROR;

	ELSIF p_new_end_date IS NULL
	THEN
		IF p_old_end_date IS NOT NULL
		THEN
			p_update_end_date_flag := 'Y';
		ELSE
			p_update_end_date_flag := 'N';
		END IF;
	ELSE

		p_update_end_date_flag := 'N';

		IF p_old_end_date IS NOT NULL   --start_date is null
		THEN
			IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
			THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_DATES_INVALID_3'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
			END IF;

			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

ELSE	--p_new_start_date was not passed

	p_update_start_date_flag := 'N';

	IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
	AND p_new_end_date IS NOT NULL
	THEN
		IF p_new_end_date <> nvl(p_old_end_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
		THEN
			p_update_end_date_flag := 'Y';

			IF p_old_start_date IS NULL
			OR p_old_start_date > p_new_end_date
			THEN
			  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
				THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
				END IF;

				RAISE FND_API.G_EXC_ERROR;
			END IF;

		ELSE
			p_update_end_date_flag := 'N';

		END IF;

	ELSIF p_new_end_date IS NULL
	THEN
		IF p_old_end_date IS NOT NULL
		THEN
			p_update_end_date_flag := 'Y';

		ELSE
			p_update_end_date_flag := 'N';

		END IF;
	ELSE
		p_update_end_date_flag := 'N';

	END IF;
END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN

	p_return_status := FND_API.G_RET_STS_ERROR;
	-- 4537865
	p_update_end_date_flag := NULL  ;
	p_update_start_date_flag := NULL ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- 4537865
        p_update_end_date_flag := NULL  ;
        p_update_start_date_flag := NULL ;

	WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- 4537865
        p_update_end_date_flag := NULL  ;
        p_update_start_date_flag := NULL ;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	END IF;

END check_start_end_date_Pvt;

--------------------------------------------------------------------------------
--Name:               check_for_one_manager
--Type:               Procedure
--Description:        See below.
--
--Called subprograms:
--
--
--
--History:
--    	31-JUL-1996     R. Krishnamurthy    	Created
--	03-DEC-1996	L. de Werker		Moved from pa_project_pub to pa_project_pvt
--  12-JUL-2000 Mohnish
--              added code for ROLE BASED SECURITY:
--              added the call to PA_PROJECT_PARTIES_PUB.UPDATE_PROJECT_PARTY
--  19-JUL-2000 Mohnish incorporated PA_PROJECT_PARTIES_PUB API changes
--
PROCEDURE check_for_one_manager_Pvt
(p_project_id   	IN 	NUMBER
,p_person_id    	IN 	NUMBER
,p_key_members  	IN 	pa_project_pub.project_role_tbl_type
,p_start_date   	IN 	DATE
,p_end_date     	IN 	DATE
,p_return_status 	OUT  NOCOPY 	VARCHAR2 ) /*Added the nocopy check for 4537865 */
IS

CURSOR l_current_project_man_csr
IS
SELECT person_id,
       start_date_active,
       end_date_active
-- begin NEW code for ROLE BASED SECURITY
       , PROJECT_PARTY_ID
       , RESOURCE_ID
       , RESOURCE_TYPE_ID
       , RECORD_VERSION_NUMBER
       , scheduled_flag
-- end NEW code for ROLE BASED SECURITY
FROM   pa_project_players
WHERE  project_id = p_project_id
AND    project_role_type = 'PROJECT MANAGER'
-- AND    nvl(end_date_active,nvl(p_start_date,sysdate)) between nvl(p_start_date,sysdate) and nvl(p_end_date,sysdate);
AND    nvl(end_date_active,nvl(p_start_date,sysdate)) between nvl(p_start_date,sysdate) and nvl(p_end_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE); -- Added for Bug 5183218

l_wf_type                           VARCHAR2(250);
l_wf_item_type                           VARCHAR2(250);
l_wf_process                             VARCHAR2(250);
l_assignment_id                          NUMBER;
l_current_project_man_rec     	l_current_project_man_csr%ROWTYPE;
l_manager_dates_overlap         VARCHAR2(1) := 'N';
l_current_manager_updated       VARCHAR2(1) := 'N';
l_new_end_date                  DATE;
-- begin NEW code for ROLE BASED SECURITY
x_return_status VARCHAR2(255);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(2000);
-- end NEW code for ROLE BASED SECURITY

--needed to get the field values associated to a AMG message
-- added COMPLETION_DATE to the cursor l_amg_project_csr for ROLE BASED SECURITY

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1, COMPLETION_DATE
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);
   v_completion_date   DATE;
   l_project_role_id   NUMBER;
   v_end_date           DATE;
   v_null_number        NUMBER:= to_number(NULL);
   v_null_char          VARCHAR2(1):= to_char(NULL);

BEGIN
/*
   If a project manager is sought to be created, then check whether
   there is already a project manager for the project. If so, check
   whether this is the same person. If not,then check the start and
   end dates for the existing manager. If dates overlap,then
   check the input table to see whether the existing project manager
   is being de-activated. If so,go ahead and create a new project manager and
   update the end date of the existing manager with the date provided
   Else update the end date of the existing manager to either
   (a) new manager's start date -1 or (b) sysdate -1
   (being done in check_for_one_manager);
*/
     p_return_status := FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('Inside check_for one_manager_pvt');

-- begin NEW code for ROLE BASED SECURITY
-- getting the project_role_id for call to PA_PROJECT_PARTIES_PUB.UPDATE_PROJECT_PARTY
       Select project_role_id
	   Into   l_project_role_id
       From   pa_project_role_types
       Where  project_role_type='PROJECT MANAGER';
-- end NEW code for ROLE BASED SECURITY
-- Get segment1 for AMG messages
    --dbms_output.put_line('Value of l_project_role_id '||l_project_role_id);

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1,v_completion_date;
   CLOSE l_amg_project_csr;

     OPEN l_current_project_man_csr;
     FETCH l_current_project_man_csr INTO l_current_project_man_rec;

     IF l_current_project_man_csr%NOTFOUND
     THEN
        CLOSE l_current_project_man_csr;
        RETURN;
     END IF;
    CLOSE l_current_project_man_csr;

     --dbms_output.put_line('value of l_current_project_man_rec.person_id'||l_current_project_man_rec.person_id);
    -- dbms_output.put_line('value of l_current_project_man_rec.start_date_active'||l_current_project_man_rec.start_date_active);
    -- dbms_output.put_line('value of l_current_project_man_rec.end_date_active'||l_current_project_man_rec.end_date_active);
    -- dbms_output.put_line('value of l_current_project_man_rec.PROJECT_PARTY_ID'||l_current_project_man_rec.PROJECT_PARTY_ID);
    -- dbms_output.put_line('value of l_current_project_man_rec.RESOURCE_ID'||l_current_project_man_rec.RESOURCE_ID);
     IF l_current_project_man_rec.person_id <> p_person_id
     THEN

        IF l_current_project_man_rec.start_date_active > nvl(p_start_date,sysdate)
           THEN
              -- if the start date of the existing manager is > than the
              -- new manager's start date, then raise error

	 -- This check is added so that the user is allowed to enter back-dated project managers records.
	 -- Bug 4300015
	 If l_current_project_man_rec.start_date_active < nvl(p_end_date,sysdate)
	 THEN

             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PR_TOO_MANY_MGRS'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                RAISE  FND_API.G_EXC_ERROR;
          End If;
	 END IF;
          l_current_manager_updated       := 'N';

           FOR i in 1..p_key_members.COUNT LOOP

             	IF (p_key_members(i).person_id = l_current_project_man_rec.person_id
             	AND p_key_members(i).project_role_type = 'PROJECT MANAGER')
             	THEN
/*
-- begin OLD code before changes for ROLE BASED SECURITY
                 	IF  p_key_members(i).end_date < p_start_date
                 	THEN
                     		UPDATE pa_project_players
                     		SET end_date_active =  p_key_members(i).end_date
                     		WHERE project_id = p_project_id
                     		AND   person_id  = l_current_project_man_rec.person_id
                     		AND   project_role_type = 'PROJECT MANAGER';
                     	ELSE
			        UPDATE pa_project_players
              			SET end_date_active =
                                Decode( nvl(p_start_date,
                                PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              		        ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                SYSDATE-1,p_start_date-1)
              		        WHERE project_id = p_project_id
              		        AND   person_id  =
                                l_current_project_man_rec.person_id
              		        AND   project_role_type = 'PROJECT MANAGER';
	                END IF;
-- end OLD code before changes for ROLE BASED SECURITY
*/
-- begin NEW code for ROLE BASED SECURITY
                 	IF  p_key_members(i).end_date < p_start_date
                 	THEN
                        v_end_date := p_key_members(i).end_date;
                    ELSE
                        Select Decode( nvl(p_start_date,
                               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              		           ,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                               SYSDATE-1,p_start_date-1)
                        Into v_end_date
						From dual;
	                END IF;
   /*Added the OR condition in the below statement for the bug 2846478*/
 IF l_current_project_man_rec.scheduled_flag ='N' OR l_current_project_man_rec.scheduled_flag IS NULL
   THEN
     PA_PROJECT_PARTIES_PUB.update_project_party(
          p_api_version => 1.0                -- p_api_version
          , p_init_msg_list => FND_API.G_TRUE   -- p_init_msg_list
          , p_commit => FND_API.G_FALSE          -- p_commit /* bug#2417448 */
          , p_validate_only => FND_API.G_FALSE  -- p_validate_only
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL          -- p_validation_level
          , p_debug_mode => 'N'                 -- p_debug_mode
          , p_object_id => p_project_id         -- p_object_id
          , p_OBJECT_TYPE => 'PA_PROJECTS'         -- p_OBJECT_TYPE
          , p_project_role_id => l_project_role_id  -- p_project_role_id
          , p_project_role_type => 'PROJECT MANAGER' -- p_project_role_type
          , p_resource_type_id => l_current_project_man_rec.resource_type_id -- p_resource_type_id
          , p_resource_source_id => l_current_project_man_rec.person_id -- p_resource_source_id
          , p_resource_id => l_current_project_man_rec.resource_id  -- Bug 6631033
          , p_resource_name => v_null_char     -- p_resource_name
          , p_start_date_active => l_current_project_man_rec.start_date_active --  p_start_date_active
          , p_scheduled_flag => l_current_project_man_rec.scheduled_flag       -- p_scheduled_flag
          , p_record_version_number => l_current_project_man_rec.record_version_number --  p_record_version_number
          , p_calling_module => 'FORM'         -- p_calling_module
          , p_project_id => p_project_id     -- p_project_id
          , p_project_end_date => v_completion_date    -- p_project_end_date
          , p_project_party_id => l_current_project_man_rec.project_party_id --   p_project_party_id
          , p_end_date_active => v_end_date    -- p_end_date_active
          , x_wf_type         => l_wf_type
          , x_wf_item_type    => l_wf_item_type
          , x_wf_process      => l_wf_process
          , x_assignment_id   => l_assignment_id
          , x_return_status =>x_return_status  -- x_return_status
          , x_msg_count => x_msg_count         -- x_msg_count
          , x_msg_data => x_msg_data           -- x_msg_data
          );
          IF    (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                p_return_status := x_return_status;
--                p_msg_count     := x_msg_count;
--                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
         END IF;
     END IF;
-- end NEW code for ROLE BASED SECURITY
                  l_current_manager_updated       := 'Y';
                EXIT;   -- come out of the loop
             END IF;
         END LOOP;
         IF l_current_manager_updated = 'N' THEN
            IF ( p_start_date IS NULL OR
                 p_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) THEN
                 l_new_end_date  := SYSDATE - 1;
            ELSE
                 l_new_end_date  := p_start_date - 1;
            END IF;
/*
-- begin OLD code before changes for ROLE BASED SECURITY
	    UPDATE pa_project_players
            SET end_date_active =
               Decode (SIGN(start_date_active-l_new_end_date),1,
                       start_date_active, l_new_end_date)
            WHERE project_id = p_project_id
            AND   person_id  =
            l_current_project_man_rec.person_id
            AND   project_role_type = 'PROJECT MANAGER';
-- end OLD code before changes for ROLE BASED SECURITY
*/
-- begin NEW code for ROLE BASED SECURITY

       /* Added the code below for Bug 5196620 */
       IF SIGN(l_current_project_man_rec.start_date_active - l_new_end_date) = 1 then
              v_end_date := l_current_project_man_rec.start_date_active;
        ELSE
              v_end_date := l_new_end_date;
        End if;


       /* Bug 5196620 : Commented the query to fetch end-date as its incorrect. This would fail if
          we have same person_id as PM for different dates. It would fecth multiple
          records in this scenario
         Select
               Decode (SIGN(start_date_active-l_new_end_date),1,
                       start_date_active, l_new_end_date)
         Into v_end_date
         From pa_project_players
         Where project_id = p_project_id
         And person_id = l_current_project_man_rec.person_id
         And project_role_type = 'PROJECT MANAGER'; */

         /* End of code changes for Bug 5196620 */
 /*Added the OR condition in the below statement for the bug 2846478*/
 /* IF l_current_project_man_rec.scheduled_flag ='N' OR l_current_project_man_rec.scheduled_flag IS NULL
 THEN */ -- Commented FOR Bug 6631033
   PA_PROJECT_PARTIES_PUB.UPDATE_PROJECT_PARTY(
          p_api_version => 1.0                 -- p_api_version
          , p_init_msg_list => FND_API.G_TRUE  -- p_init_msg_list
          , p_commit => FND_API.G_FALSE         -- p_commit  /* bug#2417448 */
          , p_validate_only => FND_API.G_FALSE -- p_validate_only
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL          -- p_validation_level
          , p_debug_mode => 'N'                -- p_debug_mode
          , p_object_id => p_project_id        -- p_object_id
          , p_OBJECT_TYPE => 'PA_PROJECTS'        -- p_OBJECT_TYPE
          , p_project_role_id => l_project_role_id    -- p_project_role_id
          , p_project_role_type => 'PROJECT MANAGER'  -- p_project_role_type
          , p_resource_type_id => l_current_project_man_rec.resource_type_id -- p_resource_type_id
          , p_resource_source_id => l_current_project_man_rec.person_id -- p_resource_source_id
          , p_resource_id => l_current_project_man_rec.resource_id --Added resource_id parameter for Bug 6631033
          , p_resource_name => v_null_char     -- p_resource_name
          , p_start_date_active => l_current_project_man_rec.start_date_active --  p_start_date_active
          , p_scheduled_flag => l_current_project_man_rec.scheduled_flag            -- p_scheduled_flag
          , p_record_version_number => l_current_project_man_rec.record_version_number --  p_record_version_number
          , p_calling_module => 'FORM'         -- p_calling_module
          , p_project_id => p_project_id       -- p_project_id
          , p_project_end_date => v_completion_date    -- p_project_end_date
          , p_project_party_id => l_current_project_man_rec.project_party_id --   p_project_party_id
          , p_end_date_active => v_end_date    -- p_end_date_active
          , x_assignment_id   => l_assignment_id
          , x_wf_type         => l_wf_type
          , x_wf_item_type    => l_wf_item_type
          , x_wf_process      => l_wf_process
          , x_return_status => x_return_status -- x_return_status
          , x_msg_count => x_msg_count         -- x_msg_count
          , x_msg_data => x_msg_data           -- x_msg_data
          );
          IF    (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                p_return_status := x_return_status;
--                p_msg_count     := x_msg_count;
--                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
         END IF;
   END IF;
-- end NEW code for ROLE BASED SECURITY
  -- END IF; -- Commented FOR Bug 6631033

     END IF;
-- 4537865
EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => 'check_for_one_manager_Pvt');

        END IF;

END check_for_one_manager_Pvt;

Procedure handle_task_number_change_Pvt
          (p_project_id                   IN NUMBER,
           p_task_id                      IN NUMBER,
           p_array_cell_number            IN NUMBER,
           p_in_task_number               IN VARCHAR2,
           p_in_task_tbl                  IN pa_project_pub.task_in_tbl_type,
           p_proceed_with_update_flag    OUT NOCOPY VARCHAR2, /*Added the nocopy check for 4537865 */
           p_return_status               OUT NOCOPY VARCHAR2 /*Added the nocopy check for 4537865 */
) IS

   CURSOR l_get_task_number_csr (p_task_id IN NUMBER)
   IS
   SELECT task_number
   FROM pa_tasks
   WHERE task_id = p_task_id;

   CURSOR l_get_task_id_csr (p_project_id IN NUMBER,
	                     p_task_number IN VARCHAR2 )
   IS
   SELECT task_id,pm_task_reference
   FROM pa_tasks
   WHERE project_id = p_project_id
   AND   task_number = p_task_number ;

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);
   l_amg_task_number       VARCHAR2(50);

   l_task_number        VARCHAR2(30);
   l_task_id            NUMBER := 0;
   l_pm_task_reference  VARCHAR2(30);
   l_tot_task_count     NUMBER := 0;
   l_count              NUMBER := 0;
   p_multiple_task_msg           VARCHAR2(1) := 'T';

BEGIN

       p_return_status := FND_API.G_RET_STS_SUCCESS;

       p_proceed_with_update_flag := 'Y';

    -- check whether task number is changing

       IF p_in_task_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
          p_in_task_number IS NULL THEN
          p_proceed_with_update_flag := 'Y';
          RETURN;
       END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

       OPEN l_get_task_number_csr (p_task_id);
       FETCH l_get_task_number_csr INTO l_task_number;
       CLOSE l_get_task_number_csr;

-- If task number is not being changed, then need not proceed further
-- can proceed with the regular update

        IF l_task_number = substrb(p_in_task_number,1,25) THEN  --bug 6193314  added substrb
              p_proceed_with_update_flag := 'Y';
              RETURN;
       END IF;

-- If the new task number would result in unique constraint violation
-- then scan the array to check whether the task which presently
-- has the task number to which this task is changing to, is also being
-- changed.
-- Eg : If we are processing Task number 2.1 which is getting changed to
-- 2.3, then check whether the existing task with task number 2.3, is
-- also getting changed in the same session. If it is not getting changed
-- then we cannot update this task to 2.3 and would raise an error

     IF pa_task_utils.check_unique_task_number
          (p_project_id,p_in_task_number,NULL) = 0 THEN
          -- get the task id and task reference for the task whose
          -- present task number = the task number which is being changed to

            OPEN l_get_task_id_csr (p_project_id,substrb(p_in_task_number,1,25)); --bug 6193314  added substrb
           FETCH l_get_task_id_csr
           INTO  l_task_id,
                 l_pm_task_reference;
           IF l_get_task_id_csr%NOTFOUND THEN
              CLOSE l_get_task_id_csr;
              RETURN;
           ELSE
              CLOSE l_get_task_id_csr;
           END IF;

             -- scan the input array to check whether
             -- the fetched task is also getting changed

           l_tot_task_count := p_in_task_tbl.COUNT;
           --FOR i IN 1..l_tot_task_count LOOP,
           --commented and added following by rtarway for bug fix 4016583
             FOR i IN  p_in_task_tbl.FIRST..p_in_task_tbl.LAST LOOP
             IF p_in_task_tbl(i).pa_task_id = l_task_id OR
                 p_in_task_tbl(i).pm_task_reference = l_pm_task_reference THEN
               IF p_in_task_tbl(i).pa_task_number = p_in_task_number THEN
                 -- The task number for this task is not getting changed
                 -- Hence , we cannot update the task that we are processing
                 -- to the new task number.
                 -- Eg: We are processing task 2.1
                 -- It is getting changed to 2.3. There is already a task
                 -- in the database with task number = 2.3. Unless, this
                 -- is getting changed to something else, we cannot update
                 -- 2.1 to 2.3
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> p_in_task_tbl(i).task_name
    ,p_task_reference => p_in_task_tbl(i).pm_task_reference
    ,p_task_id => l_task_id);

	         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_NUMBER_NOT_UNIQUE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
              	 END IF;
                p_multiple_task_msg := 'F';
--              RAISE  FND_API.G_EXC_ERROR;
               END IF;
               IF G_task_num_updated_index_tbl.EXISTS(1) THEN
                  l_count := G_task_num_updated_index_tbl.COUNT;
                  l_count := l_count + 1;
               ELSE
                  l_count := 1;
               END IF;
               G_index_counter := G_index_counter + 1;
               G_task_num_updated_index_tbl(l_count).task_index
                 := p_array_cell_number;
               G_task_num_updated_index_tbl(l_count).task_id
                 := p_task_id;
               -- Now update the processing task number to a temporary value
               UPDATE pa_tasks
               SET task_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ||
                                 TO_CHAR(G_index_counter)
               WHERE task_id = p_task_id;
               p_proceed_with_update_flag := 'N';
               EXIT;
             END IF;
           END LOOP;
           IF p_multiple_task_msg = 'F'
           THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN

	p_return_status := FND_API.G_RET_STS_ERROR;

	-- 4537865
	p_proceed_with_update_flag := 'N' ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- 4537865
        p_proceed_with_update_flag := 'N' ;

	WHEN OTHERS THEN

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- 4537865
        p_proceed_with_update_flag := 'N';

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=>
                                  'handle_task_number_change' );

	END IF;

END handle_task_number_change_Pvt;

Procedure check_parent_child_tk_dts_Pvt
          (p_project_id                   IN NUMBER,
           p_return_status               OUT NOCOPY VARCHAR2 ) /*Added the nocopy check for 4537865 */
IS

CURSOR l_get_tasks_csr IS
SELECT task_id,parent_task_id,TRUNC(start_date) start_date,TRUNC(completion_date) completion_date,task_name, -- Bug Fix 4705139
pm_task_reference
FROM   pa_tasks pt where project_id = p_project_id
AND
(
parent_task_id IS NOT NULL
OR EXISTS
(SELECT 'x' FROM pa_tasks pt2
 WHERE parent_task_id = pt.task_id));

CURSOR l_get_child_dates_csr (l_project_id NUMBER,l_task_id NUMBER )
IS
SELECT min(TRUNC(start_date)),max(TRUNC(completion_date))  FROM -- Bug Fix 4705139
PA_TASKS
WHERE project_id = l_project_id
AND   parent_task_id = l_task_id;

CURSOR l_get_parent_dates_csr (l_project_id NUMBER,l_task_id NUMBER)
IS
SELECT TRUNC(start_date) start_date,TRUNC(completion_date) completion_date -- Bug Fix 4705139
FROM
PA_TASKS
WHERE project_id = l_project_id
AND   task_id = l_task_id;

l_get_tasks_rec l_get_tasks_csr%rowtype;
l_min_child_start_date         DATE;
l_max_child_completion_date    DATE;
l_parent_start_date            DATE;
l_parent_completion_date       DATE;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

p_multiple_task_msg        VARCHAR2(1) := 'T';

BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

   OPEN l_get_tasks_csr;
    LOOP
      FETCH l_get_tasks_csr INTO
            l_get_tasks_rec;
      EXIT WHEN l_get_tasks_csr%NOTFOUND;
/*
   OPEN l_amg_task_csr( l_get_tasks_rec.task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> l_get_tasks_rec.task_name
    ,p_task_reference => l_get_tasks_rec.pm_task_reference
    ,p_task_id => l_get_tasks_rec.task_id);

      IF l_get_tasks_rec.parent_task_id IS NOT NULL THEN
         OPEN l_get_parent_dates_csr (p_project_id,
                                       l_get_tasks_rec.parent_task_id);
          FETCH l_get_parent_dates_csr INTO
                l_parent_start_date,
                l_parent_completion_date;
          IF l_get_parent_dates_csr%NOTFOUND THEN
	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             END IF;
             CLOSE l_get_parent_dates_csr;
             p_multiple_task_msg := 'F';
--             RAISE  FND_API.G_EXC_ERROR;
          ELSE
             CLOSE l_get_parent_dates_csr;
          END IF;
          IF l_parent_start_date > l_get_tasks_rec.start_date THEN
	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PARENT_START_LATER'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             END IF;
             CLOSE l_get_tasks_csr;
             p_multiple_task_msg := 'F';
--             RAISE  FND_API.G_EXC_ERROR;
          END IF;

          IF l_parent_completion_date < l_get_tasks_rec.completion_date THEN
	     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PARENT_COMPLETION_EARLIER'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             END IF;
             CLOSE l_get_tasks_csr;
             p_multiple_task_msg := 'F';
--             RAISE  FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      l_min_child_start_date          := NULL;
      l_max_child_completion_date     := NULL;

      OPEN  l_get_child_dates_csr(p_project_id,l_get_tasks_rec.task_id);
      FETCH l_get_child_dates_csr INTO
            l_min_child_start_date,
            l_max_child_completion_date ;
      CLOSE l_get_child_dates_csr;
      IF l_min_child_start_date IS NOT NULL THEN
         IF l_get_tasks_rec.start_date >  l_min_child_start_date
            OR
            l_min_child_start_date > l_get_tasks_rec.completion_date THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_CHILD_START_EARLIER'
                   ,p_msg_attribute    => 'CHANGE'
                   ,p_resize_flag      => 'N'
                   ,p_msg_context      => 'TASK'
                   ,p_attribute1       => l_amg_segment1
                   ,p_attribute2       => l_amg_task_number
                   ,p_attribute3       => ''
                   ,p_attribute4       => ''
                   ,p_attribute5       => '');
              END IF;
             p_multiple_task_msg := 'F';
--             RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      IF l_max_child_completion_date IS NOT NULL THEN
         IF l_get_tasks_rec.completion_date < l_max_child_completion_date
            OR
            l_max_child_completion_date < l_get_tasks_rec.start_date
            THEN
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_PARENT_START_LATER'
                   ,p_msg_attribute    => 'CHANGE'
                   ,p_resize_flag      => 'N'
                   ,p_msg_context      => 'TASK'
                   ,p_attribute1       => l_amg_segment1
                   ,p_attribute2       => l_amg_task_number
                   ,p_attribute3       => ''
                   ,p_attribute4       => ''
                   ,p_attribute5       => '');
            END IF;
             p_multiple_task_msg := 'F';
--             RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END LOOP;

   IF p_multiple_task_msg = 'F'
   THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE l_get_tasks_csr;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	THEN
        IF l_get_tasks_csr%ISOPEN THEN
           CLOSE l_get_tasks_csr;
        END IF;

	p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
        IF l_get_tasks_csr%ISOPEN THEN
           CLOSE l_get_tasks_csr;
        END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
        IF l_get_tasks_csr%ISOPEN THEN
           CLOSE l_get_tasks_csr;
        END IF;

	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=>
                                  'check_parent_child_task_dates' );

	END IF;

END check_parent_child_tk_dts_Pvt;

--  History
--
--  16-Feb-2005  pkanupar   created for bug #2111806

/* This is a wrapper API which is called from the AMG API pa_project_pub to
check the Manager date range on a Project */

Procedure check_manager_date_range
          (p_project_id           IN NUMBER,
           p_return_status       OUT NOCOPY VARCHAR2 ) IS /*Added the nocopy check for 4537865 */

l_error_occured     VARCHAR2(50);
l_start_no_mgr_date DATE;
l_end_no_mgr_date   DATE;

BEGIN
   p_return_status := FND_API.G_RET_STS_SUCCESS;
--dbms_output.put_line('is this called');
   PA_PROJECT_PARTIES_UTILS.validate_manager_date_range( p_mode               => 'AMG'
                                                        ,p_project_id         => p_project_id
 	                                                ,x_start_no_mgr_date  => l_start_no_mgr_date
	                                                ,x_end_no_mgr_date    => l_end_no_mgr_date
                                                        ,x_error_occured      => l_error_occured);

--dbms_output.put_line('Value of l_error_occured'||l_error_occured);
   IF l_error_occured = 'PA_PR_NO_MGR_DATE_RANGE' THEN

	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

               pa_utils.add_message
                ( p_app_short_name   => 'PA'
                 ,p_msg_name         => 'PA_PR_NO_MGR_DATE_RANGE'
		 ,p_token1           => 'START_DATE'
                 ,p_value1           => l_start_no_mgr_date
                 ,p_token2           => 'END_DATE'
                 ,p_value2           => l_end_no_mgr_date
                );
          END IF;
          RAISE  FND_API.G_EXC_ERROR;

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
       p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
	   FND_MSG_PUB.add_exc_msg
		( p_pkg_name		=> G_PKG_NAME
		, p_procedure_name	=> 'check_manager_date_range' );

       END IF;

END check_manager_date_range;

--------------------------------------------------------------------------------
end PA_PROJECT_CHECK_PVT;

/

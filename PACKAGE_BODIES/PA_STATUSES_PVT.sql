--------------------------------------------------------
--  DDL for Package Body PA_STATUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUSES_PVT" as
/* $Header: PARSTAVB.pls 120.1 2005/08/19 17:00:43 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_STATUSES_PVT
-- Purpose          : Private Package for table PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
--                    11-OCT-2000 Partha        serveroutput is removed
--                    14-FEB-2003 mrajput       Bug2778408 : Added api Process_Phase_Code_Delete
--

-- NOTE             :
--                  : Subprogram Name          Type
--                  : ------------------       -----------------------
--                  : delete_status_pvt        PL/SQL procedure

-- End of Comments
--Global constants to be used in error messages
G_PKG_NAME    CONSTANT VARCHAR2(30)   :='PA_STATUSES_PVT';
G_USER_ID     CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID    CONSTANT NUMBER := FND_GLOBAL.login_id;

-- ============================================================================

PROCEDURE delete_status_pvt
( p_api_version_number      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM --- (Bug 1851096)
 ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE      -- (Bug 1851096)
 ,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
 ,p_validate_only           IN VARCHAR2 := FND_API.G_FALSE
 ,p_max_msg_count           IN NUMBER
 ,p_pa_project_status_code  IN VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_allow_deletion_flag    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_api_name     CONSTANT  VARCHAR2(30) := 'delete_status';
   l_err_code               NUMBER;
   l_err_stage              VARCHAR2(120);
   l_err_stack              VARCHAR2(630);
   l_status_type            VARCHAR2(30);
   l_resp_id                NUMBER := 0;
   l_user_id                NUMBER := 0;
   x_err_code               NUMBER := 0;
   x_err_stage              VARCHAR2(30);
   x_err_stack              VARCHAR2(630);

/* Added for Bug 2778408 */
l_msg_count                NUMBER;
l_data                     VARCHAR2(2000);
l_msg_data                 VARCHAR2(2000);
l_return_status            VARCHAR2(1);
l_errorcode                NUMBER;
l_msg_index_out               NUMBER;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT delete_status_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (
                   g_api_version_number  ,
                   p_api_version_number   ,
                   l_api_name          ,
                   G_PKG_NAME          ) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


--   Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;


--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;


-- Check the status code passed
   IF     p_pa_project_status_code is NULL  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

--  get the status_type for the current status_code
    select status_type
    into   l_status_type
    from pa_project_statuses
    where project_status_code=p_pa_project_status_code;

--  check if the status is deletable, ie. not being used anywhere
    pa_project_stus_utils.allow_status_deletion(
                          p_pa_project_status_code
                          , l_status_type
                          , x_err_code
                          , x_err_stage
                          , x_err_stack
                          , x_allow_deletion_flag);

--  call the table handler of PA_PROJECT_STATUSES, PA_PROJECT_STATUS_CONTROLS
--  and PA_NEXT_ALLOW_STATUSES for delete if there is no error in the above call
    IF   (x_allow_deletion_flag = 'Y')  THEN
         /* Start Changes for Bug 2778408 */
	 IF (l_status_type='PHASE') THEN

                PA_EGO_WRAPPER_PUB.process_phase_code_delete(
                        p_api_version                   => p_api_version_number         ,
                        p_phase_code                    => p_pa_project_status_code     ,
                        p_init_msg_list                 => p_init_msg_list              ,
                        p_commit                        => p_commit                     ,
                        x_return_status                 => l_return_status              ,
                        x_errorcode                     => l_errorcode                  ,
                        x_msg_count                     => l_msg_count                  ,
                        x_msg_data                      => l_msg_data);

        	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   l_msg_count := FND_MSG_PUB.count_msg;
		   If l_msg_count > 0 THEN
		      x_msg_count := l_msg_count;
	           If l_msg_count = 1 THEN
		      pa_interface_utils_pub.get_messages
			 (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		      x_msg_data := l_data;
		   End if;
		   End if;
		   RAISE  FND_API.G_EXC_ERROR;
	         END IF;
          End IF;
	  /* End of Changes for Bug 2778408 */
         PA_PROJECT_STATUSES_PKG.delete_row(p_pa_project_status_code);
         PA_PROJECT_STATUS_CONTROLS_PKG.delete_row(p_pa_project_status_code);
         PA_NEXT_ALLOW_STATUSES_PKG.delete_row(p_pa_project_status_code);
    ELSE
    x_msg_data := x_err_stage;
         ROLLBACK TO delete_status_pub;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      COMMIT;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO delete_status_pub;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get
              (   p_count    => x_msg_count ,
                  p_data     => x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO delete_status_pub;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             FND_MSG_PUB.Count_And_Get
              (   p_count    => x_msg_count ,
                  p_data     => x_msg_data  );

      WHEN ROW_ALREADY_LOCKED THEN
           ROLLBACK TO delete_status_pub;
           x_return_status := FND_API.G_RET_STS_ERROR;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED');
          FND_MESSAGE.SET_TOKEN('ENTITY', p_pa_project_status_code);
          FND_MSG_PUB.ADD;
   END IF;
   FND_MSG_PUB.Count_And_Get
         (   p_count    => x_msg_count ,
             p_data     => x_msg_data  );

      WHEN OTHERS THEN
           ROLLBACK TO delete_status_pub;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.add_exc_msg
                    ( p_pkg_name      => G_PKG_NAME
                    , p_procedure_name   => l_api_name
                    , p_error_text    => SUBSTR(SQLERRM, 1, 240) );
                FND_MSG_PUB.add;
         END IF;

         FND_MSG_PUB.Count_And_Get
             (   p_count    => x_msg_count ,
              p_data        => x_msg_data  );

END delete_status_pvt;

--------------------------------------------------------------------------------

end PA_STATUSES_PVT;

/

--------------------------------------------------------
--  DDL for Package Body PA_STATUSES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STATUSES_PUB" as
/* $Header: PARSTAPB.pls 120.2 2005/08/19 17:00:35 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_STATUSES_PUB
-- Purpose          : Public Package for table PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
--                    11-OCT-2000 Partha        serveroutput is removed
-- NOTE             :
--                  : Subprogram Name          Type
--                  : ------------------       -----------------------
--                  : delete_status            PL/SQL procedure
-- End of Comments

PROCEDURE delete_status
( p_api_version_number      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE -- 1851096 changed for TRUE to FALSE
 ,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
 ,p_validate_only           IN VARCHAR2 := FND_API.G_FALSE
 ,p_max_msg_count           IN NUMBER
 ,p_pa_project_status_code  IN VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_allow_deletion_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
 v_status_type   VARCHAR2(30);
 x_status_code   VARCHAR2(30);
 x_error_message_code VARCHAR2(255);
 unknown_action_exc   EXCEPTION;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  select status_type
  into v_status_type
  from pa_project_statuses
  where project_status_code = p_pa_project_status_code;


  PA_PROJECT_STUS_UTILS.Check_Status_Name_or_Code(
                 p_status_code         => p_pa_project_status_code
                 ,p_status_name        => NULL
                 ,p_status_type        => v_status_type
                 ,p_check_id_flag      => 'Y'
                 ,x_status_code        => x_status_code
                 ,x_return_status      => x_return_status
                 ,x_error_message_code => x_error_message_code
                 );
   IF NOT (x_status_code=p_pa_project_status_code)  THEN
          raise unknown_action_exc;
   END IF;

  pa_statuses_pvt.delete_status_pvt
     (p_api_version_number      => p_api_version_number
     ,p_init_msg_list           => p_init_msg_list
     ,p_commit                  => p_commit
     ,p_validate_only           => p_validate_only
     ,p_max_msg_count           => p_max_msg_count
     ,p_pa_project_status_code  => p_pa_project_status_code
     ,x_return_status           => x_return_status
     ,x_msg_count               => x_msg_count
     ,x_msg_data                => x_msg_data
     ,x_allow_deletion_flag    => x_allow_deletion_flag
     );
EXCEPTION
    WHEN unknown_action_exc THEN
      rollback;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('PA','PA_UNKNOWN_ACTION');
      fnd_message.set_token('PKG_NAME','PA_STATUSES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','delete_status');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      rollback;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_STATUSES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','delete_status');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;
    WHEN OTHERS THEN
      rollback;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name  =>  'PA_STATUSES_PUB',
                              p_procedure_name  => 'delete_status',
                              p_error_text  =>  SUBSTRB(SQLERRM,1,240));
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
	  raise;


END delete_status;

--------------------------------------------------------------------------------
end PA_STATUSES_PUB;

/

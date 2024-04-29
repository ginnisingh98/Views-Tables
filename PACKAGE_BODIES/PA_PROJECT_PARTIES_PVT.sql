--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_PARTIES_PVT" as
/* $Header: PARPPUTB.pls 120.12.12010000.6 2009/08/21 12:00:43 nkapling ship $ */

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE CREATE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_resource_type_id      IN NUMBER := 101,
                                p_project_role_id       IN NUMBER,
                                p_resource_source_id    IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_calling_module        IN VARCHAR2,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE,
                p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_project_party_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_resource_id           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_error_occured           VARCHAR2(50) := 'N';
  x_call_overlap            VARCHAR2(1) := 'Y';
  x_assignment_action       VARCHAR2(20) := 'NOACTION';
  l_resource_id             NUMBER;
  l_record_version_number   NUMBER := 1;
  l_project_party_id        NUMBER;
  l_project_id              NUMBER;
  l_grant_id                RAW(16);          ---------NUMBER;
  x_assignment_number       NUMBER;
  x_assignment_row_id       ROWID;
  l_unfilled_assignment_id  NUMBER;
  l_valid                   VARCHAR2(1) := 'N';
  l_error_msg_code          VARCHAR2(255);
  l_proj_role_name          VARCHAR2(80);
  l_assignment_rec          PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_source_type             VARCHAR2(8) := 'PERSON';
  l_job_schedulable         VARCHAR2(1) := 'N';
  l_date                    DATE;
  l_is_valid                   VARCHAR2(1) := 'N';  /* Added for bug 3234293 */
  l_return_status          VARCHAR2(1000);    /* Added for bug 3234293 */

  /* Start of code for bug #2111806 */
  l_start_no_mgr_date     DATE;
  l_end_no_mgr_date       DATE;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(1000);
  /* End of code for bug #2111806 */
  l_msg_index_out         NUMBER;                     --Bug 5186830
  l_data                  VARCHAR2(2000);             --Bug 5186830

  l_is_valid_denorm    VARCHAR2(1) := 'N';/* Added for bug 6077424 */
  l_past_resource      VARCHAR2(10);

BEGIN

   if p_commit = FND_API.G_TRUE then
        savepoint project_parties;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if p_project_id = FND_API.G_MISS_NUM or p_project_id is null then
      l_project_id := null;
   else
      l_project_id := p_project_id;
   end if;


   if p_validation_level > 0 then
    if (p_debug_mode = 'Y') then
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.debug('Create_project_party: Calling validate_project_party.');
         END IF;
    end if;
   pa_debug.G_err_stage := 'Calling validate_project_party';
   pa_project_parties_utils.validate_project_party(
                                p_validation_level,
                                p_debug_mode,
                                p_object_id,
                                p_OBJECT_TYPE,
                                p_project_role_id,
                                p_resource_type_id,
                                p_resource_source_id,
                                p_start_date_active,
                                NVL(p_scheduled_flag, 'N'),
                                l_record_version_number,
                                p_calling_module,
                                'INSERT',
                                l_project_id,
                                p_project_end_date,
                                p_end_date_active,
                                l_project_party_id,
                                x_call_overlap,
                                x_assignment_action,
                                x_return_status);
   end if;

   --dbms_output.put_line('return :'||x_return_status);
   --dbms_output.put_line('project_role_id :'||to_char(p_project_role_id));

   If x_return_status = FND_API.G_RET_STS_SUCCESS and not(fnd_api.to_boolean(nvl(p_validate_only,FND_API.G_FALSE))) then
       --if pa_install.is_prm_licensed() = 'Y' then

    --MT: OrgRole changes
       IF p_resource_type_id=101 THEN

/* Added for bug 3234293 - We check if resource exists, call resource pull only if resource does not exist */
                    pa_resource_utils.check_res_exists(
                          P_PERSON_ID     => p_resource_source_id,
                          X_VALID         => l_is_valid,
                          X_RETURN_STATUS => l_return_status);

/* Added for bug 6077424*/
		BEGIN
			SELECT 'Y' INTO l_is_valid_denorm FROM pa_resources_denorm
				WHERE person_id = p_resource_source_id
				AND rownum=1;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				l_is_valid_denorm := 'N';

		END;
/* End for bug 6077424*/

--         IF (nvl(p_scheduled_flag, 'N') = 'Y' OR l_is_valid <> 'Y' ) THEN -- 6077424
         IF ((nvl(p_scheduled_flag, 'N') = 'Y' AND (l_is_valid <> 'Y' OR l_is_valid_denorm = 'N') ))
	 or l_is_valid <> 'Y' THEN /* Added for bug 6077424,  Changed for bug 6398283*/


/* End of code added for bug 3234293 */

         pa_debug.G_err_stage := 'Calling create_resource';
         pa_r_project_resources_pub.create_resource(p_api_version => 1.0,
                                p_init_msg_list   => fnd_api.g_false,
                                p_commit      => p_commit,
                                p_validate_only => p_validate_only,
                                p_person_id => p_resource_source_id,
                p_internal => 'Y',
                                p_individual => 'Y',
                                p_check_resource => 'Y',
                p_resource_type => 'EMPLOYEE',
                P_SCHEDULED_MEMBER_FLAG => NVL(p_scheduled_flag, 'N'),
		P_START_DATE => p_start_date_active, -- Bug 5337454
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_resource_id => l_resource_id);
	 --Bug 5186830
           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
/* Added for bug 3234293 - Added this else condition to get the resource id */
      ELSE

               SELECT resource_id
               INTO l_resource_id
           FROM pa_resource_txn_attributes
               WHERE person_id = p_resource_source_id
           and rownum=1;

      END IF;
/* End of code added for bug 3234293 */

    ELSIF p_resource_type_id=112 THEN

    l_source_type := 'HZ_PARTY';

/* Added for bug 3234293 - We check if resource exists, call resource pull only if resource does not exist */

        pa_resource_utils.check_res_exists(
              P_PARTY_ID      => p_resource_source_id,
              X_VALID         => l_is_valid,
              X_RETURN_STATUS => l_return_status);

         IF ((nvl(p_scheduled_flag, 'N') = 'Y') OR (l_is_valid <> 'Y')) THEN

/* End of code added for bug 3234293 */

         pa_debug.G_err_stage := 'Calling create_resource';
         pa_r_project_resources_pub.create_resource(p_api_version => 1.0,
                                p_init_msg_list   => fnd_api.g_false,
                                p_commit      => p_commit,
                                p_validate_only => p_validate_only,
                                p_party_id => p_resource_source_id,
                                p_internal => 'N',
                                p_individual => 'Y',
                p_resource_type => 'HZ_PARTY',
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_resource_id => l_resource_id);
       --Bug 5186830
           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
/* Added for bug 3234293 - Added this else condition to get the resource id */

      ELSE

         select resource_id into l_resource_id
             from pa_resource_txn_attributes
             where party_id = p_resource_source_id
         and rownum=1;

      END IF;

/* End of code added for bug 3234293 */

    END IF;
        --MT: End OrgRole changes

        if (x_return_status = FND_API.G_RET_STS_SUCCESS and p_scheduled_flag = 'Y') then
           l_past_resource := pa_resource_utils.is_past_resource(l_resource_id);
           IF(NVL(l_past_resource,'XXX') = 'Y') THEN
           pa_resource_utils.CHECK_RES_BELONGS_EXPORG(p_resource_id => l_resource_id,
                                                      p_start_date_active => p_start_date_active,
                                                      p_end_date_active => p_end_date_active,
                                                      x_valid => l_valid,
                                                      x_return_status => x_return_status,
                                                      x_error_message_code => l_error_msg_code);
           ELSE
           pa_resource_utils.CHECK_RES_BELONGS_EXPORG(p_resource_id => l_resource_id,
                                                      x_valid => l_valid,
                                                      x_return_status => x_return_status,
                                                      x_error_message_code => l_error_msg_code);
           END IF;
           if (l_valid <> 'Y') then
              -- check that the person is allowed to have schedule
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('PA','PA_NO_SCHEDULABLE_PERSON');
              fnd_msg_pub.add();
           end if;

           -- if the res belongs to the expenditure org hierarchy, check if the res's
           -- job is schedulable

           IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	      IF(NVL(l_past_resource,'XXX') = 'Y') THEN --Added for Bug 8811314
		SELECT max(resource_effective_end_date)
                 INTO l_date
                 FROM pa_resources_denorm
                 WHERE resource_id = l_resource_id ;
	      else
	         l_date :=pa_resource_utils.Get_Resource_Effective_Date(p_resource_id => l_resource_id);
              end if;
		 l_job_schedulable := PA_HR_UPDATE_API.check_job_schedulable
                                       ( p_person_id => p_resource_source_id
                                        ,p_date      => l_date );
              IF l_job_schedulable <> 'Y' THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('PA','PA_NOT_SCHEDULABLE_JOB');
                 fnd_msg_pub.add();
              END IF;
           END IF;
        end if;


      if x_call_overlap = 'N' and x_return_status = FND_API.G_RET_STS_SUCCESS then
         -- call update api
         if (p_debug_mode = 'Y') then
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.debug('Create_project_party: Calling update_row.');
              END IF;
         end if;

            x_project_party_id := l_project_party_id;
            x_resource_id := l_resource_id;

            --dbms_output.put_line('calling update');
            pa_debug.G_err_stage := 'Calling update_row from create_project_party';
            PA_PROJECT_PARTIES_PKG.UPDATE_ROW (
                  X_PROJECT_PARTY_ID => l_project_party_id,
                  X_PROJECT_ID => l_project_id,
                  X_RESOURCE_SOURCE_ID => p_resource_source_id,
                  X_RESOURCE_TYPE_ID => p_resource_type_id,
                  X_PROJECT_ROLE_ID => p_project_role_id,
                  X_START_DATE_ACTIVE => trunc(p_start_date_active),
                  X_END_DATE_ACTIVE => trunc(p_end_date_active),
                  X_GRANT_ID => null,
                  X_SCHEDULED_FLAG => NVL(p_scheduled_flag, 'N'),
                  X_RECORD_VERSION_NUMBER => l_record_version_number,
                  X_LAST_UPDATE_DATE  => sysdate,
                  X_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
                  X_RETURN_STATUS => x_return_status);
                  if (x_return_status = 'N') then
                       if p_calling_module = 'FORM' then
                            fnd_message.set_name('FND','FORM_RECORD_CHANGED');
                            --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PKG');
                            --fnd_message.set_token('PROCEDURE_NAME','UPDATE_ROW');
                            fnd_msg_pub.add;
                       else
                            fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
                            --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PKG');
                            --fnd_message.set_token('PROCEDURE_NAME','UPDATE_ROW');
                            fnd_msg_pub.add;

                       end if;
                  end if;

      elsif x_return_status = FND_API.G_RET_STS_SUCCESS then

        pa_security_pvt.grant_role(
                            p_project_role_id => p_project_role_id,
                            p_object_name     => p_object_type,
                            p_object_key      => p_object_id,
                            p_instance_type   => 'SET',
                            p_party_id        => p_resource_source_id,
                            p_source_type     => l_source_type,
                            x_grant_guid      => l_grant_id,
                            x_return_status   => x_return_status,
                            x_msg_count       => x_msg_count,
                            x_msg_data        => x_msg_data);
        l_grant_id := null;

       if x_return_status = FND_API.G_RET_STS_SUCCESS then

         x_resource_id := l_resource_id;

         if (p_debug_mode = 'Y') then
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.debug('Create_project_party: Calling insert_row.');
              END IF;
         end if;
            pa_debug.G_err_stage := 'Calling insert_row';
            ----dbms_output.put_line('calling insert');
            PA_PROJECT_PARTIES_PKG.INSERT_ROW (
                  X_PROJECT_PARTY_ID => x_project_party_id,
          X_OBJECT_ID => p_object_id,
                  X_OBJECT_TYPE => p_object_type,
                  X_PROJECT_ID => l_project_id,
                  X_RESOURCE_ID => l_resource_id,
                  X_RESOURCE_TYPE_ID => p_resource_type_id,
                  X_RESOURCE_SOURCE_ID => p_resource_source_id,
                  X_PROJECT_ROLE_ID => p_project_role_id,
                  X_START_DATE_ACTIVE => trunc(p_start_date_active),
                  X_END_DATE_ACTIVE => trunc(p_end_date_active),
                  X_SCHEDULED_FLAG => NVL(p_scheduled_flag, 'N'),
                  X_GRANT_ID => l_grant_id,
                  X_CREATED_BY  => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID) ;
       end if;
      end if;

      if x_return_status = FND_API.G_RET_STS_SUCCESS and x_assignment_action = 'CREATE' and p_calling_module = 'PROJECT_MEMBER' then
         --  call assignments api
        --   l_assignment_rec.assignment_name             := ;
           l_assignment_rec.assignment_type             := 'STAFFED_ASSIGNMENT';
       l_assignment_rec.project_id                  := l_project_id;
       l_assignment_rec.project_role_id             := p_project_role_id;
       l_assignment_rec.resource_id                 := l_resource_id;
       l_assignment_rec.project_party_id            := x_project_party_id;
       l_assignment_rec.start_date                  := p_start_date_active;
       l_assignment_rec.end_date                    := p_end_date_active;

           PA_ASSIGNMENTS_PUB.Create_Assign_with_def
          ( p_assignment_rec             => l_assignment_rec
           ,p_resource_source_id         => p_resource_source_id
           ,p_validate_only              => 'F'
           ,x_new_assignment_id          => x_assignment_id
           ,x_assignment_number          => x_assignment_number
           ,x_assignment_row_id          => x_assignment_row_id
           ,x_return_status              => x_return_status
           ,x_msg_count                  => x_msg_count
           ,x_msg_data                   => x_msg_data);

     end if;

     --Bug 5856712
     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;


    /* Start of code for bug #2111806:
       Following validation needs to be done only when called from Self Service.
       In the case of Assignments flow, this API is being called from PL/SQL code
       with p_calling_module = 'ASSIGNMENT' and so added this check also.
       Call the check_manager_date_range to check if the Project
       Manager exists for the complete duration of the Project. */

       IF (p_mgr_validation_type = 'SS' OR  p_calling_module = 'ASSIGNMENT') THEN
        l_error_occured := 'N';
        PA_PROJECT_PARTIES_UTILS.validate_manager_date_range( p_mode               => 'SS'
                                 ,p_project_id         => l_project_id
                                 ,x_start_no_mgr_date  => l_start_no_mgr_date
                                 ,x_end_no_mgr_date    => l_end_no_mgr_date
                                 ,x_error_occured      => l_error_occured);

         IF l_error_occured = 'PA_PR_NO_MGR_DATE_RANGE' THEN
         /* If a Manager does not exist for the entire duration of the project */
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
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
         END IF;

         /* Throw an error if there are no Project Managers assigned.
        This has to be thrown irrespective of whether there are any Key Member records
        being passed or not. So, it cannot be done in the above IF condition. */
        IF l_project_id IS NOT NULL THEN
            PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS( p_project_id    => l_project_id
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data     );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
            END IF;
        END IF;
       END IF;
    /* End of code for bug #2111806 */

    if fnd_api.to_boolean(nvl(p_commit,FND_API.G_FALSE)) and x_return_status = FND_API.G_RET_STS_SUCCESS then
        if (p_debug_mode = 'Y') then
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.debug('Create_project_party: Commiting data.');
            END IF;
        end if;
        commit work;
    end if;
   end if;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,
                             p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
--Bug 5186830
WHEN FND_API.G_EXC_ERROR THEN

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
    x_return_status := FND_API.G_RET_STS_ERROR;
    pa_debug.reset_err_stack;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','CREATE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;

 WHEN OTHERS THEN
    if p_commit = FND_API.G_TRUE then
            rollback to project_parties;
    end if;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.G_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;

END CREATE_PROJECT_PARTY;

PROCEDURE UPDATE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_object_id             IN NUMBER := FND_API.G_MISS_NUM,
                                p_object_type           IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_role_id       IN NUMBER,
                                p_resource_type_id      IN NUMBER := 101,
                                p_resource_source_id    IN NUMBER,
                                p_resource_id           IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_end_date      IN DATE,
                                p_project_party_id      IN  NUMBER,
                                p_assignment_id         IN NUMBER,
                                p_assign_record_version_number IN NUMBER,
                p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_assignment_id         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_wf_type               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_item_type          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_wf_process            OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_error_occured      VARCHAR2(50) := 'N';
  x_call_overlap       VARCHAR2(1) := 'Y';
  x_assignment_action  VARCHAR2(20) := 'NOACTION';
  l_record_version_number  NUMBER;
  l_project_party_id  NUMBER := p_project_party_id;
  l_grant_id          RAW(16);    ---NUMBER;
  l_resource_id       NUMBER;
  l_valid             VARCHAR2(1) := 'N';
  l_error_msg_code    VARCHAR2(255);
  x_assignment_number NUMBER;
  x_assignment_row_id ROWID;
  l_assignment_rec    PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_source_type       VARCHAR2(8) := 'PERSON';
  l_job_schedulable   VARCHAR2(1) := 'N';
  l_date              DATE;
  /* Start of code for bug #2111806 */
  l_start_no_mgr_date     DATE;
  l_end_no_mgr_date       DATE;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(1000);
  l_return_status         VARCHAR2(1000);
  /* End of code for bug #2111806 */
  l_msg_index_out         NUMBER;                     --Bug 5856712
  l_data                  VARCHAR2(2000);             --Bug 5856712
  l_past_resource         VARCHAR2(10);

  /* Added for Bug 6631033 */
  CURSOR l_staff_assn_exists_csr
  IS
  SELECT * FROM pa_project_assignments
             WHERE project_id = p_project_id
             AND   ASSIGNMENT_TYPE = 'STAFFED_ASSIGNMENT'
             AND PROJECT_ROLE_ID = 1
             AND start_date = p_start_date_active
             AND resource_id = p_resource_id
	     AND APPRVL_STATUS_CODE NOT IN -- This condition added after bug 7023082
 	              ('ASGMT_APPRVL_REJECTED','ASGMT_APPRVL_CANCELED');
  l_staff_assn_exists_rec         l_staff_assn_exists_csr%ROWTYPE;

BEGIN
   if p_commit = FND_API.G_TRUE then
        savepoint project_parties;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --dbms_output.put_line('role id '||to_char(p_project_role_id));
   --dbms_output.put_line('resource source id '||to_char(p_resource_source_id));
   --dbms_output.put_line('project party id '||to_char(p_project_party_id));
   l_record_version_number := p_record_version_number;

   if p_validation_level > 0 then
         if (p_debug_mode = 'Y') then
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.debug('Update_project_party: Calling validate_project_party.');
              END IF;
         end if;
      pa_debug.g_err_stage := 'Calling validate_project_party';
      pa_project_parties_utils.validate_project_party(
                                p_validation_level,
                                p_debug_mode,
                                p_object_id,
                                p_OBJECT_TYPE,
                                p_project_role_id,
                                p_resource_type_id,
                                p_resource_source_id,
                                p_start_date_active,
                                NVL(p_scheduled_flag, 'N'),
                                l_record_version_number,
                                p_calling_module,
                                'UPDATE',
                                p_project_id,
                                p_project_end_date,
                                p_end_date_active,
                                l_project_party_id,
                                x_call_overlap,
                                x_assignment_action,
                                x_return_status);
   end if;


   If x_return_status = FND_API.G_RET_STS_SUCCESS and not(fnd_api.to_boolean(nvl(p_validate_only,FND_API.G_FALSE))) then

      if x_assignment_action = 'CREATE' then
         --  call assignments api

          IF (p_scheduled_flag = 'Y') THEN
             l_past_resource := pa_resource_utils.is_past_resource(l_resource_id);
           IF(NVL(l_past_resource,'XXX') = 'Y') THEN
              pa_resource_utils.CHECK_RES_BELONGS_EXPORG(p_resource_id => l_resource_id,
                                                        p_start_date_active => p_start_date_active,
                                                        p_end_date_active => p_end_date_active,
                                                        x_valid => l_valid,
                                                        x_return_status => x_return_status,
                                                        x_error_message_code => l_error_msg_code);
           ELSE
             pa_resource_utils.CHECK_RES_BELONGS_EXPORG(p_resource_id => p_resource_id,
                                                        x_valid => l_valid,
                                                        x_return_status => x_return_status,
                                                        x_error_message_code => l_error_msg_code);
          END IF;
             IF (l_valid <> 'Y') then
                -- check that the person is allowed to have schedule
                x_return_status := FND_API.G_RET_STS_ERROR;
                fnd_message.set_name('PA','PA_NO_SCHEDULABLE_PERSON');
                fnd_msg_pub.add();
             END IF;

             -- if the res belongs to the expenditure org hierarchy, check if the res's
             -- job is schedulable


        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
--  Added for bug 3149239
             IF(NVL(l_past_resource,'XXX') = 'Y') THEN --Added for bug 8811314
		 SELECT max(resource_effective_end_date)
                 INTO l_date
                 FROM pa_resources_denorm
                 WHERE resource_id = l_resource_id ;
	     else
	         l_date :=pa_resource_utils.Get_Resource_Effective_Date(p_resource_id => p_resource_id);
	     end if;
             l_job_schedulable := PA_HR_UPDATE_API.check_job_schedulable
                                       ( p_person_id => p_resource_source_id
                                        ,p_date      => l_date );

                IF l_job_schedulable <> 'Y' THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   fnd_message.set_name('PA','PA_NOT_SCHEDULABLE_JOB');
                   fnd_msg_pub.add();
                END IF;
             END IF;
          END IF;
          if x_return_status = FND_API.G_RET_STS_SUCCESS then

           l_assignment_rec.assignment_type             := 'STAFFED_ASSIGNMENT';
           l_assignment_rec.project_id                  := p_project_id;
           l_assignment_rec.project_role_id             := p_project_role_id;
           l_assignment_rec.resource_id                 := p_resource_id;
           l_assignment_rec.project_party_id            := p_project_party_id;
           l_assignment_rec.start_date                  := p_start_date_active;
           l_assignment_rec.end_date                    := p_end_date_active;


           PA_ASSIGNMENTS_PUB.Create_Assign_with_def
           ( p_assignment_rec             => l_assignment_rec
            ,p_resource_source_id         => p_resource_source_id
            ,p_validate_only              => 'F'
            ,x_new_assignment_id          => x_assignment_id
            ,x_assignment_number          => x_assignment_number
            ,x_assignment_row_id          => x_assignment_row_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data);
          end if;

      elsif x_assignment_action = 'DELETE' then
         --  call delete assignments api
    --MT Only call the api if assignment_id is passed in
    IF p_assignment_id > 0 THEN

        pa_project_parties_pvt.l_delete_proj_party := 'N';

        PA_ASSIGNMENTS_PUB.Delete_Assignment
        ( p_assignment_id         => p_assignment_id
         ,p_assignment_type       => 'STAFFED_ASSIGNMENT'
         ,p_record_version_number => p_assign_record_version_number
         ,p_commit                => p_commit
         ,p_validate_only         => FND_API.G_FALSE
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

    END IF;

        pa_project_parties_pvt.l_delete_proj_party := 'Y';

/* Code added for Bug 6631033 */
      elsif x_assignment_action = 'NOACTION' THEN

          OPEN l_staff_assn_exists_csr;
          FETCH l_staff_assn_exists_csr INTO l_staff_assn_exists_rec;

          IF l_staff_assn_exists_csr%FOUND
          THEN

                        PA_SCHEDULE_PUB.update_schedule (
                        p_project_id                   => p_project_id
                        -- ,p_mass_update_flag            => FND_API.G_FLASE
                        ,p_exception_type_code         => 'CHANGE_DURATION'
                        ,p_record_version_number       => l_staff_assn_exists_rec.record_version_number
                        ,p_assignment_id               => l_staff_assn_exists_rec.assignment_id
                        ,p_change_start_date           => p_start_date_active
                        ,p_change_end_date             => p_end_date_active
                        ,p_assignment_status_code      => l_staff_assn_exists_rec.status_code
                        ,p_non_working_day_flag        => 'N'
                        ,p_called_by_proj_party        => 'Y'
                        ,p_commit                      => p_commit
                        ,p_validate_only               => FND_API.G_FALSE--'F'
                        ,x_return_status               => x_return_status
                        ,x_msg_count                   => x_msg_count
                        ,x_msg_data                    => x_msg_data );

                         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                               Close l_staff_assn_exists_csr;
                               RAISE FND_API.G_EXC_ERROR;
                         END IF;


          END IF;
          Close l_staff_assn_exists_csr;
      end if;
/* End of code changes for Bug 6631033 */

         -- call update api
         if (p_debug_mode = 'Y') then
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.debug('Update_project_party: Calling update_row.');
              END IF;
         end if;

/* FP-L status-based security
         l_grant_id := pa_project_parties_utils.get_grant_id(p_project_party_id => p_project_party_id);

                if x_return_status = FND_API.G_RET_STS_SUCCESS and l_grant_id > 0 then
                      -- call fnd_grants
        IF p_resource_type_id = 112 THEN
                  l_source_type := 'HZ_PARTY';
                END IF;

                pa_security_pvt.update_role(p_grant_guid         => l_grant_id,
                                           p_project_role_id_old => p_project_role_id,
                                           p_object_name_old     => p_object_type,
                                           p_object_key_type_old => 'INSTANCE',
                                           p_object_key_old      => p_object_id,
                                           p_party_id_old        => p_resource_source_id,
                                           p_source_type_old     => l_source_type,
                                           p_start_date_old      => to_date(null),
                                           p_start_date_new      => p_start_date_active,
                                           p_end_date_new        => p_end_date_active,
                                           x_return_status    => x_return_status,
                                           x_msg_count        => x_msg_count,
                                           x_msg_data         => x_msg_data
                                           );

                end if;

*/

        if x_return_status = FND_API.G_RET_STS_SUCCESS then
        l_grant_id := null;

        ----dbms_output.put_line('calling update api');
        pa_debug.g_err_stage := 'Calling Update_row';
        PA_PROJECT_PARTIES_PKG.UPDATE_ROW (
                  X_PROJECT_PARTY_ID => p_project_party_id,
                  X_PROJECT_ID => p_project_id,
                  X_RESOURCE_SOURCE_ID => p_resource_source_id,
                  X_RESOURCE_TYPE_ID => p_resource_type_id,
                  X_PROJECT_ROLE_ID => p_project_role_id,
                  X_START_DATE_ACTIVE => trunc(p_start_date_active),
                  X_END_DATE_ACTIVE => trunc(p_end_date_active),
                  X_SCHEDULED_FLAG => NVL(p_scheduled_flag, 'N'),
                  X_GRANT_ID => l_grant_id,
                  X_record_version_number => p_record_version_number,
                  X_LAST_UPDATE_DATE => sysdate,
                  X_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID,
                  X_RETURN_STATUS => x_return_status);
                  if (x_return_status = 'N') then
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       if p_calling_module = 'FORM' then
                            fnd_message.set_name('FND','FORM_RECORD_CHANGED');
                            --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PKG');
                            --fnd_message.set_token('PROCEDURE_NAME','UPDATE_ROW');
                            fnd_msg_pub.add;
                       else
                            fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
                            --fnd_message.set_token('PKG_NAME',to_char(p_project_party_id));
                            --fnd_message.set_token('PROCEDURE_NAME',to_char(p_record_version_number));
                            fnd_msg_pub.add;

                       end if;
                  end if;

            end if;

      end if;

     --Bug 5856712
     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;


    /* Start of code for bug #2111806:
       Following validation needs to be done only when called from Self Service.
       In the case of Assignments flow, this API is being called from PL/SQL code
       with p_calling_module = 'ASSIGNMENT' and so added this check also.

       Call the check_manager_date_range to check if the Project
       Manager exists for the complete duration of the Project. */

       IF ( p_mgr_validation_type = 'SS' OR p_calling_module = 'ASSIGNMENT') THEN
        l_error_occured := 'N';
        PA_PROJECT_PARTIES_UTILS.validate_manager_date_range( p_mode               => 'SS'
                                 ,p_project_id         => p_project_id
                                 ,x_start_no_mgr_date  => l_start_no_mgr_date
                                 ,x_end_no_mgr_date    => l_end_no_mgr_date
                                 ,x_error_occured      => l_error_occured);

         IF l_error_occured = 'PA_PR_NO_MGR_DATE_RANGE' THEN
         /* If a Manager does not exist for the entire duration of the project */
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
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
         END IF;

         /* Throw an error if there are no Project Managers assigned.
        This has to be thrown irrespective of whether there are any Key Member records
        being passed or not. So, it cannot be done in the above IF condition. */
        IF p_project_id IS NOT NULL THEN
            PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS( p_project_id    => p_project_id
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data     );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
            END IF;
        END IF;
       END IF;
    /* End of code for bug #2111806 */

    if fnd_api.to_boolean(nvl(p_commit,fnd_api.G_FALSE)) and x_return_status = FND_API.G_RET_STS_SUCCESS then
        if (p_debug_mode = 'Y') then
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.debug('Update_project_party: Commiting data.');
            END IF;
        end if;
        commit work;
    end if;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION

-- bug 5856712
WHEN FND_API.G_EXC_ERROR THEN

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
    x_return_status := FND_API.G_RET_STS_ERROR;
    pa_debug.reset_err_stack;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PUB');
      fnd_message.set_token('PROCEDURE_NAME','UPDATE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;


    WHEN OTHERS THEN
    if p_commit = fnd_api.G_TRUE then
       rollback to project_parties;
    end if;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

    raise;

end update_project_party;


PROCEDURE DELETE_PROJECT_PARTY( p_commit                IN VARCHAR2 := FND_API.G_FALSE,
                                p_validate_only         IN VARCHAR2 := FND_API.G_TRUE,
                                p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 default 'N',
                                p_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
                                p_calling_module        IN VARCHAR2 := FND_API.G_MISS_CHAR,
                                p_project_id            IN NUMBER := FND_API.G_MISS_NUM,
                                p_project_party_id      IN NUMBER := FND_API.G_MISS_NUM,
                                p_scheduled_flag        IN VARCHAR2 := 'N',
/* code commented for the bug#1851096, starts here */
/*                             p_assignment_id         IN NUMBER := FND_API.G_MISS_NUM,
                               p_assign_record_version_number IN NUMBER := FND_API.G_MISS_NUM,
*/
/* code commented for the bug#1851096, end here */
/* code added for the bug#1851096, starts here */
                                p_assignment_id         IN NUMBER := 0,
                                p_assign_record_version_number IN NUMBER := 0,
/* code added for the bug#1851096, end here */
                                p_mgr_validation_type   IN VARCHAR2 := FND_API.G_MISS_CHAR,/*Added for bug 2111806*/
                                x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_project_id         NUMBER;
   l_grant_id           RAW(16);                ------NUMBER;
   API_ERROR            EXCEPTION;

  -- 4616302 TCA UPTAKE: HZ_PARTY_RELATIONS IMPACTS
  -- changed hz_party_relationships usage to hz_relationships
  -- changed column party_relationship_type usage to relationship_type

  /*
  CURSOR c_ext_people IS
  SELECT pp.project_party_id project_party_id,
         pp.record_version_number record_version_number
  FROM pa_project_parties po,
       pa_project_parties pp,
       hz_party_relationships hzr
  WHERE po.resource_type_id = 112
    AND po.project_party_id = p_project_party_id
    AND pp.resource_type_id = 112
    AND pp.object_type = po.object_type
    AND pp.object_id = po.object_id
    AND hzr.party_relationship_type IN ( 'EMPLOYEE_OF', 'CONTACT_OF')
    AND hzr.subject_id = pp.resource_source_id
    AND hzr.object_id = po.resource_source_id;
  */

  CURSOR c_ext_people IS
  SELECT pp.project_party_id project_party_id,
         pp.record_version_number record_version_number
  FROM pa_project_parties po,
       pa_project_parties pp,
       hz_relationships hzr
  WHERE po.resource_type_id = 112
    AND po.project_party_id = p_project_party_id
    AND pp.resource_type_id = 112
    AND pp.object_type = po.object_type
    AND pp.object_id = po.object_id
    AND hzr.relationship_code IN ( 'EMPLOYEE_OF', 'CONTACT_OF')
    AND hzr.subject_id = pp.resource_source_id
    AND hzr.object_id = po.resource_source_id
    AND hzr.object_table_name = 'HZ_PARTIES'
    AND hzr.subject_type = 'PERSON'
    AND hzr.subject_table_name = 'HZ_PARTIES';

   -- 4616302 end

  CURSOR c_billing_accounts IS
  SELECT customer_id, record_version_number
  FROM pa_project_customers
  WHERE project_id = p_project_id
    AND project_party_id = p_project_party_id;

/* Start of code for bug #2111806 */
l_start_no_mgr_date     DATE;
l_end_no_mgr_date       DATE;
l_error_occured         VARCHAR2(50);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(1000);
l_return_status         VARCHAR2(1000);
/* End of code for bug #2111806 */

BEGIN
   if p_commit = FND_API.G_TRUE then
        savepoint project_parties;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (p_debug_mode = 'Y') then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.debug('Delete_project_party : Lock Key Members ');
       END IF;
   end if;

   --lock the project player

   if (p_debug_mode = 'Y') then
       IF P_DEBUG_MODE = 'Y' THEN
          pa_debug.debug('Delete_project_party : Before delete from pa_project_players ');
       END IF;
   end if;

   /* Added the following code for bug #2111806:
      When this API is called during an Assignment deletion, then the p_project_id is not being passed.
      We require the project_id to call the validate_manager_date_range API.
      So, fetching the p_project_id based on the p_project_party_id. */

   l_project_id := p_project_id;  -- Added for bug 4483205

   IF (( p_project_id IS NULL OR p_project_id = FND_API.G_MISS_NUM) AND
      ( nvl(p_project_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM )) THEN

       SELECT project_id
         INTO l_project_id
         FROM pa_project_parties
        WHERE project_party_id = p_project_party_id;

   END IF;

   if (pa_project_parties_pvt.l_delete_proj_party = 'Y') then

   if pa_project_parties_utils.validate_delete_party_ok(l_project_id,p_project_party_id) = 'Y' then

     --Deleting all external people before deleting the org.
     FOR rec IN c_ext_people LOOP
       pa_project_parties_pvt.delete_project_party(
         p_commit                 => p_commit,
         p_validate_only          => p_validate_only,
         p_validation_level       => p_validation_level,
         p_debug_mode             => p_debug_mode,
         p_record_version_number  => rec.record_version_number,
         p_calling_module         => p_calling_module,
         p_project_id             => l_project_id,
         p_project_party_id       => rec.project_party_id,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);
       EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;
     END LOOP;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
     END IF;

     FOR rec In c_billing_accounts LOOP
       pa_customers_contacts_pub.delete_project_customer(
         p_validate_only          => p_validate_only,
         p_validation_level       => p_validation_level,
         p_calling_module         => p_calling_module,
         p_debug_mode             => p_debug_mode,
         p_project_id             => l_project_id,
         p_customer_id            => rec.customer_id,
         p_record_version_number  => rec.record_version_number,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data);
       EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;
     END LOOP;

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
     END IF;

        l_grant_id := pa_project_parties_utils.get_grant_id(p_project_party_id => p_project_party_id);
        pa_debug.g_err_stage := 'Calling delete_row';
        pa_project_parties_pkg.delete_row(x_project_id => l_project_id,
                                     x_project_party_id => p_project_party_id,
                                     x_record_version_number => p_record_version_number);
   end if;

/*  FP-L status-based security
    -----  if x_return_status = FND_API.G_RET_STS_SUCCESS and pa_install.is_prm_licensed() = 'Y' and l_grant_id > 0 then
    if x_return_status = FND_API.G_RET_STS_SUCCESS and l_grant_id > 0 then
                pa_security_pvt.revoke_grant(p_grant_guid      => l_grant_id,
                                           x_return_status    => x_return_status,
                                           x_msg_count        => x_msg_count,
                                           x_msg_data         => x_msg_data
                                           );

     end if;
*/

    /* Start of code for bug #2111806:
       Following validation needs to be done only when called from Self Service.
       In the case of Assignments flow, this API is being called from PL/SQL code
       with p_calling_module = 'ASSIGNMENT' and so added this check also.

       Call the check_manager_date_range to check if the Project
       Manager exists for the complete duration of the Project. */

       IF ( p_mgr_validation_type = 'SS' OR  p_calling_module = 'ASSIGNMENT') THEN
            l_error_occured := 'N';
        PA_PROJECT_PARTIES_UTILS.validate_manager_date_range( p_mode               => 'SS'
                                 ,p_project_id         => l_project_id
                                 ,x_start_no_mgr_date  => l_start_no_mgr_date
                                 ,x_end_no_mgr_date    => l_end_no_mgr_date
                                 ,x_error_occured      => l_error_occured);

         IF l_error_occured = 'PA_PR_NO_MGR_DATE_RANGE' THEN
         /* If a Manager does not exist for the entire duration of the project */
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
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
         END IF;

         /* Throw an error if there are no Project Managers assigned.
        This has to be thrown irrespective of whether there are any Key Member records
        being passed or not. So, it cannot be done in the above IF condition. */
        IF p_project_id IS NOT NULL THEN
            PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS( p_project_id    => l_project_id
                                     ,x_return_status => x_return_status
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data     );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
            END IF;
        END IF;

       END IF;
    /* End of code for bug #2111806 */

    if fnd_api.to_boolean(nvl(p_commit,fnd_api.G_FALSE)) and x_return_status = FND_API.G_RET_STS_SUCCESS then
        if (p_debug_mode = 'Y') then
            IF P_DEBUG_MODE = 'Y' THEN
               pa_debug.debug('Delete_project_party: Commiting data.');
            END IF;
        end if;
        commit work;
    end if;

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
   end if;

  pa_debug.reset_err_stack;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('PA','PA_UNEXPECTED_ERROR');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_PVT');
      fnd_message.set_token('PROCEDURE_NAME','DELETE_PROJECT_PARTY');
      fnd_msg_pub.add();
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      raise;

   WHEN NO_DATA_FOUND THEN

     if (p_debug_mode = 'Y') then
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.debug('Delete_project_party : Exception NO_DATA_FOUND  ');
         END IF;
     end if;

     --fnd_message.set_name('PA', 'PA_XC_NO_DATA_FOUND');
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN TIMEOUT_ON_RESOURCE THEN

     if (p_debug_mode = 'Y') then
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.debug('Delete_project_party : Exception TIMEOUT_ON_RESOURCE  ');
         END IF;
     end if;

     fnd_message.set_name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;

   WHEN OTHERS then
    if p_commit = fnd_api.G_TRUE then
       rollback to project_parties;
    end if;

     if (p_debug_mode = 'Y') then
         IF P_DEBUG_MODE = 'Y' THEN
            pa_debug.debug('Delete_project_party : Exception OTHERS  ');
         END IF;
     end if;

     if(SQLCODE = -54) then
        FND_MESSAGE.Set_Name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
        x_msg_data := FND_MESSAGE.get;
        x_return_status := FND_API.G_RET_STS_ERROR;
      else
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_PUB',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
        x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

END DELETE_PROJECT_PARTY;

end;


/

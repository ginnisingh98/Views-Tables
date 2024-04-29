--------------------------------------------------------
--  DDL for Package Body AMW_AUDIT_ENGAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AUDIT_ENGAGEMENT_PVT" AS
/* $Header: amwvengb.pls 120.3 2008/02/08 14:24:50 adhulipa ship $ */
/*===========================================================================*/


PROCEDURE copy_scope_from_engagement(
    p_source_entity_id		IN	 NUMBER,
    p_target_entity_id          IN       NUMBER,
    l_copy_ineff_controls boolean :=false,
    x_return_status             OUT      nocopy VARCHAR2
) IS


   l_source     varchar2(3):= 'PA';
   l_scope_exits varchar2(1);

   l_parent_task_id AMW_AUDIT_TASKS_B.PARENT_TASK_ID%TYPE;
   l_top_task_id    AMW_AUDIT_TASKS_B.TOP_TASK_ID%TYPE;

   l_return_status VARCHAR2(32767);
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(32767);

   cursor c_child_tasks IS
     SELECT audit_project_id, task_id, parent_task_id, top_task_id
     FROM   amw_audit_tasks_b
     WHERE  audit_project_id = p_target_entity_id
       AND  parent_task_id is not null;

BEGIN

  /*---------------------------------------------------+
   | The scope needs to be copied only when it exists. |
   | Templates do not have scope.                      |
   +---------------------------------------------------*/
   BEGIN
    select 'Y' into l_scope_exits
    from dual
    where exists ( select 1
                   from amw_execution_scope
                   where entity_type = 'PROJECT'
                   and entity_id = p_source_entity_id);
   EXCEPTION
     WHEN no_data_found THEN
       l_scope_exits := 'N';
   END;

  /*---------------------------------------------------+
   | Copy the tasks only when the source is ICM.       |
   | For PA , the tasks are copied in PA.              |
   +---------------------------------------------------*/
   BEGIN
    select 'ICM' into l_source
    from amw_audit_projects
    where audit_project_id = p_source_entity_id
    and project_id is null;
   EXCEPTION
     WHEN no_data_found THEN
       l_source := 'PA';
   END;

   IF (l_scope_exits = 'Y') THEN
   IF(l_copy_ineff_controls)

THEN
    COPY_SCOPE_INEFF_CONTROLS(p_source_entity_id,p_target_entity_id,x_return_status);
ElSE
      INSERT INTO AMW_EXECUTION_SCOPE (
         EXECUTION_SCOPE_ID,
         ENTITY_TYPE,
         ENTITY_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         SCOPE_CHANGED_STATUS,
         LEVEL_ID,
         SUBSIDIARY_VS,
         SUBSIDIARY_CODE,
         LOB_VS,
         LOB_CODE,
         ORGANIZATION_ID,
         PROCESS_ID,
         PROCESS_ORG_REV_ID,
         TOP_PROCESS_ID,
         PARENT_PROCESS_ID)
      SELECT amw_execution_scope_s.nextval,
                  'PROJECT',
                  p_target_entity_id,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID,
                  'C',
                  LEVEL_ID,
                  SUBSIDIARY_VS,
                  SUBSIDIARY_CODE,
                  LOB_VS,
                  LOB_CODE,
                  ORGANIZATION_ID,
                  PROCESS_ID,
                  PROCESS_ORG_REV_ID,
                  TOP_PROCESS_ID,
                  PARENT_PROCESS_ID
       FROM AMW_EXECUTION_SCOPE
       WHERE ENTITY_TYPE = 'PROJECT'
       AND   ENTITY_ID = p_source_entity_id;
END IF;

       /* Insert data into entity hierarchies table */

       INSERT INTO AMW_ENTITY_HIERARCHIES(
         ENTITY_HIERARCHY_ID,
	 ENTITY_TYPE,
	 ENTITY_ID,
	 CREATED_BY,
	 CREATION_DATE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
	 OBJECT_TYPE,
	 OBJECT_ID,
	 PARENT_OBJECT_TYPE,
	 PARENT_OBJECT_ID,
	 LEVEL_ID)
       SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
	 ENTITY_TYPE,
	 p_target_entity_id,
	 FND_GLOBAL.USER_ID,
	 SYSDATE,
	 SYSDATE,
	 FND_GLOBAL.USER_ID,
	 FND_GLOBAL.USER_ID,
	 OBJECT_TYPE,
	 OBJECT_ID,
	 PARENT_OBJECT_TYPE,
	 PARENT_OBJECT_ID,
	 LEVEL_ID
       FROM AMW_ENTITY_HIERARCHIES
       WHERE ENTITY_TYPE = 'PROJECT'
       AND   ENTITY_ID = p_source_entity_id;


   END IF; --end of l_scope_exits == 'Y'

   IF (l_source = 'ICM') THEN
       INSERT into amw_audit_tasks_b(
         TASK_ID,
         AUDIT_PROJECT_ID,
         TASK_NUMBER,
         TOP_TASK_ID,
         PARENT_TASK_ID,
         LEVEL_ID,
         START_DATE,
         COMPLETION_DATE,
         TASK_MANAGER_PERSON_ID,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER)
       select amw_audit_tasks_s.nextval,
         p_target_entity_id,
         TASK_NUMBER,
         TOP_TASK_ID,
         PARENT_TASK_ID,
         LEVEL_ID,
         START_DATE,
         COMPLETION_DATE,
         TASK_MANAGER_PERSON_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.USER_ID,
         1
        from amw_audit_tasks_b
        where audit_project_id = p_source_entity_id;

       /* Insert data into the tl table */

      INSERT INTO AMW_AUDIT_TASKS_TL(
         TASK_ID,
         TASK_NAME,
         DESCRIPTION,
         LANGUAGE,
         SOURCE_LANG,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         OBJECT_VERSION_NUMBER)
      select
         b.TASK_ID,
         stl.TASK_NAME,
         stl.DESCRIPTION,
         stl.LANGUAGE,
         stl.SOURCE_LANG,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.USER_ID,
         1
      from amw_audit_tasks_b b,
           amw_audit_tasks_tl stl,
           amw_audit_tasks_b sb
      where sb.audit_project_id = p_source_entity_id
       and  sb.task_id = stl.task_id
       and  b.task_number = sb.task_number
       and  b.audit_project_id = p_target_entity_id;


       /* Update the top_task_id for the top_tasks */

        UPDATE amw_audit_tasks_b
        SET top_task_id = task_id
        WHERE audit_project_id = p_target_entity_id
          AND parent_task_id is null;


      FOR child_tasks IN c_child_tasks LOOP

        select target.task_id into l_parent_task_id
        from amw_audit_tasks_b source,
             amw_audit_tasks_b target
        where source.task_id = child_tasks.parent_task_id
        and   source.audit_project_id = p_source_entity_id
        and   target.task_number = source.task_number
        and   target.audit_project_id = p_target_entity_id;

        select target.task_id into l_top_task_id
        from amw_audit_tasks_b source,
             amw_audit_tasks_b target
        where source.task_id = child_tasks.top_task_id
        and   source.audit_project_id = p_source_entity_id
        and   target.task_number = source.task_number
        and   target.audit_project_id = p_target_entity_id;

        UPDATE amw_audit_tasks_b
        SET parent_task_id = l_parent_task_id,
            top_task_id = l_top_task_id
        WHERE task_id = child_tasks.task_id;

      END LOOP;
   END IF;
           /* populate the denorm tables and build task */
 IF (l_scope_exits = 'Y') THEN
       AMW_SCOPE_PVT.populate_proj_denorm_tables(p_audit_project_id => p_target_entity_id);

 IF (l_copy_ineff_controls) THEN
       AMW_SCOPE_PVT.build_project_audit_task
       (
        p_api_version_number    =>  1.0 ,
	p_audit_project_id	=>  p_target_entity_id,
	l_ineff_controls    =>true,
    p_source_project_id	=> p_source_entity_id,
	x_return_status         =>  l_return_status,
	x_msg_count             =>  l_msg_count,
	x_msg_data              =>  l_msg_data
       );
    ELSE
      AMW_SCOPE_PVT.build_project_audit_task
       (
        p_api_version_number    =>  1.0 ,
	p_audit_project_id	=>  p_target_entity_id,
	x_return_status         =>  l_return_status,
	x_msg_count             =>  l_msg_count,
	x_msg_data              =>  l_msg_data
       );
END IF;
   END IF;

IF(l_copy_ineff_controls)THEN
    AMW_AUDIT_ENGAGEMENT_PVT.cp_tasks(
        p_source_project_id=>p_source_entity_id,
        p_dest_project_id=>  p_target_entity_id,
        x_return_status =>  x_return_status
        );
ELSE
    AMW_AUDIT_ENGAGEMENT_PVT.cp_tasks_all(
         p_source_project_id=>p_source_entity_id,
         p_dest_project_id=>  p_target_entity_id,
            x_return_status =>  x_return_status
        );

END IF;


  x_return_status := 'S';

  EXCEPTION
    when OTHERS then
      x_return_status := 'E';

END copy_scope_from_engagement;


PROCEDURE create_engagement_for_pa(
    p_project_id   IN      NUMBER,
    p_audit_project_id     OUT     nocopy NUMBER,
    x_return_status        OUT     nocopy VARCHAR2
) IS

   l_audit_project_id  NUMBER ;
   l_engagement_type_id NUMBER;

 BEGIN


    select AMW_AUDIT_PROJECTS_S.nextval into l_audit_project_id FROM DUAL;

    select typ.work_type_id into l_engagement_type_id
    from pa_projects_all ppa,
         amw_work_types_b typ,
         pa_project_types_all pt
    where ppa.project_id = p_project_id
      and ppa.project_type = pt.project_type
      and pt.project_type_id = typ.project_type_id;

    INSERT INTO AMW_AUDIT_PROJECTS (
       AUDIT_PROJECT_ID,
       PROJECT_ID,
       ENGAGEMENT_TYPE_ID,
       AUDIT_PROJECT_STATUS,
       SIGN_OFF_STATUS,
       TEMPLATE_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER)
     SELECT l_audit_project_id,
       p_project_id,
       l_engagement_type_id,
       'ACTI',
       'NOT_SUBMITTED',
       'N',
       FND_GLOBAL.USER_ID,
       SYSDATE,
       SYSDATE,
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_ID,
       1
     FROM dual
     WHERE not exists (SELECT 'Y'
                       FROM AMW_AUDIT_PROJECTS
                       WHERE PROJECT_ID = p_project_id);

     p_audit_project_id := l_audit_project_id ;
     x_return_status := 'S';
     COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';

END create_engagement_for_pa;



PROCEDURE create_engagement_in_pa(
    p_created_from_project_id   IN      NUMBER,
    p_project_name		IN	VARCHAR2,
    p_project_number            IN      VARCHAR2,
    p_project_description       IN      VARCHAR2,
    p_project_manager           IN      NUMBER,
    p_project_status            IN      VARCHAR2,
    p_start_date                IN      DATE,
    p_completion_date           IN      DATE,
    p_project_id                OUT     nocopy NUMBER,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
) IS


   l_commit         VARCHAR2(1) := 'F';
   l_init_msg_list     VARCHAR2(1) := 'F';
   l_msg_count          NUMBER;
   l_msg_data          VARCHAR2(2000);
--   x_return_status     VARCHAR2(1);
   l_workflow_started  VARCHAR2(1);

   G_PM_PRODUCT_CODE   VARCHAR2(30) := 'AMW';

  -- Define local table and record datatypes
   l_project_rec        PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
   l_project_out        PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;

   l_task_in            PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
   l_task_out           PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
   l_key_members        PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
   l_class_categories   PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;

   l_data          VARCHAR2(2000);
   l_msg_index_out  NUMBER;

   l_return_status VARCHAR2(1);
  i  NUMBER;

  cursor c_tasks IS
   select *
   from pa_tasks
   where project_id = p_created_from_project_id
   start with parent_task_id is null
   connect by prior task_id = parent_task_id;

   l_pm_parent_task_reference varchar2(25);


BEGIN

  i := 1;
  FOR task_rec IN c_tasks LOOP
   l_task_in(i).PM_TASK_REFERENCE := task_rec.TASK_NUMBER;
   l_task_in(i).PA_TASK_NUMBER    := task_rec.TASK_NUMBER;
   l_task_in(i).TASK_NAME         := task_rec.TASK_NAME;
   l_task_in(i).TASK_DESCRIPTION  := task_rec.DESCRIPTION;

   if task_rec.PARENT_TASK_ID is NOT NULL then
     SELECT task_number into l_pm_parent_task_reference
     FROM pa_tasks
     WHERE task_id = task_rec.PARENT_TASK_ID;

     l_task_in(i).PM_PARENT_TASK_REFERENCE := l_pm_parent_task_reference;
   end if;

   i := i+1;
  END LOOP;

  IF p_project_manager IS NOT NULL THEN
    l_key_members(1).person_id            := p_project_manager;
    l_key_members(1).project_role_type    := 'PROJECT MANAGER';
  END IF;


PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
           p_api_version_number => 1,
           p_responsibility_id   => FND_GLOBAL.RESP_ID,
           p_user_id           => FND_GLOBAL.USER_ID,
           p_resp_appl_id      => 242,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data,
           p_return_status     => l_return_status);


             -- TO CREATE PROJECT IN PROJECTS
             l_Project_rec.PM_PROJECT_REFERENCE      := p_project_number;
             l_Project_rec.PROJECT_NAME              := p_project_name;
             l_Project_rec.CREATED_FROM_PROJECT_ID   := p_created_from_project_id;
             l_Project_rec.PROJECT_STATUS_CODE       := 'ACTIVE';
             l_Project_rec.DESCRIPTION               := p_project_description;
             l_Project_rec.START_DATE                := p_start_date;
             l_Project_rec.COMPLETION_DATE           := p_completion_date;
             l_Project_rec.SCHEDULED_START_DATE      := p_start_date;


            FND_MSG_PUB.initialize;

                   PA_PROJECT_PUB.CREATE_PROJECT
                       (p_api_version_number     => 1,
                        p_commit                 => l_commit,
                        p_init_msg_list          => l_init_msg_list,
                        p_msg_count              => l_msg_count,
                        p_msg_data               => l_msg_data,
                        p_return_status          => x_return_status,
                        p_workflow_started       => l_workflow_started,
                        p_pm_product_code        => 'AMW',
                        p_project_in             => l_project_rec,
                        p_project_out            => l_project_out,
                        p_key_members            => l_key_members,
                        p_class_categories       => l_class_categories,
                        p_tasks_in                => l_task_in,
                        p_tasks_out               => l_task_out
                       );

              -- dbms_output.put_line('status :' || x_return_status);

IF x_return_status <> 'S' THEN
  if l_msg_count > 0 THEN
    for i in 1..l_msg_count loop
	pa_interface_utils_pub.get_messages(
	 	p_data           => l_data
		,p_msg_index      => i
		,p_msg_count      => l_msg_count
		,p_msg_data       => l_msg_data
		,p_msg_index_out  => l_msg_index_out );

        if l_data IS NOT NULL then
          p_msg_data := p_msg_data || l_data;
        end if;
--      dbms_output.put_line(l_data);
    end loop;
  end if;
END IF;
 p_project_id := l_project_out.PA_PROJECT_ID;

END create_engagement_in_pa;





PROCEDURE update_engagement_in_pa(
    p_project_id                IN      NUMBER,
    p_project_name              IN      VARCHAR2,
    p_project_number            IN      VARCHAR2,
    p_project_description       IN      VARCHAR2,
    p_project_manager           IN      NUMBER ,
    p_project_status            IN      VARCHAR2 default 'ACTIVE',
    p_start_date                IN      DATE default SYSDATE,
    p_completion_date           IN      DATE default NULL,
    p_sign_off_required         IN      VARCHAR2,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
) IS

   l_commit         VARCHAR2(1) := 'F';
   l_init_msg_list     VARCHAR2(1) := 'F';
   l_msg_count          NUMBER;
   l_msg_data          VARCHAR2(2000);
   l_workflow_started  VARCHAR2(1);


  -- Define local table and record datatypes
   l_project_rec        PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
   l_project_out        PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;

   l_task_in            PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
   l_task_out           PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;
   l_key_members        PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
   l_class_categories   PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;

   l_data          VARCHAR2(2000);
   l_msg_index_out  NUMBER;

   l_return_status VARCHAR2(1);
   l_created_from_project_id pa_projects_all.created_from_project_id%TYPE;
   l_project_status          pa_projects_all.project_status_code%TYPE;
   l_project_number          pa_projects_all.segment1%TYPE;
   l_project_name            pa_projects_all.name%TYPE;


BEGIN

   select created_from_project_id, project_status_code, segment1, name
   into l_created_from_project_id, l_project_status, l_project_number, l_project_name
   from pa_projects_all
   where project_id = p_project_id;

--   IF p_project_manager IS NOT NULL THEN
--     l_key_members(1).person_id            := p_project_manager;
--     l_key_members(1).project_role_type    := 'PROJECT MANAGER';
--   END IF;


PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
           p_api_version_number => 1,
           p_responsibility_id   => FND_GLOBAL.RESP_ID,
           p_user_id           => FND_GLOBAL.USER_ID,
           p_resp_appl_id      => 242,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data,
           p_return_status     => l_return_status);



             -- TO CREATE PROJECT IN PROJECTS
             l_Project_rec.PM_PROJECT_REFERENCE      := l_project_number;
             l_Project_rec.PA_PROJECT_ID             := p_project_id;
             l_Project_rec.PROJECT_NAME              := l_project_name;
             l_Project_rec.CREATED_FROM_PROJECT_ID   := l_created_from_project_id;
             l_Project_rec.PROJECT_STATUS_CODE       := l_project_status;
             l_Project_rec.DESCRIPTION               := p_project_description;
             l_Project_rec.START_DATE                := p_start_date;
             l_Project_rec.COMPLETION_DATE           := p_completion_date;
             l_Project_rec.SCHEDULED_START_DATE      := p_start_date;


            FND_MSG_PUB.initialize;

                   PA_PROJECT_PUB.UPDATE_PROJECT
                       (p_api_version_number     => 1,
                        p_commit                 => l_commit,
                        p_init_msg_list          => l_init_msg_list,
                        p_msg_count              => l_msg_count,
                        p_msg_data               => l_msg_data,
                        p_return_status          => x_return_status,
                        p_workflow_started       => l_workflow_started,
                        p_pm_product_code        => 'AMW',
                        p_project_in             => l_project_rec,
                        p_project_out            => l_project_out,
                        p_key_members            => l_key_members,
                        p_class_categories       => l_class_categories,
                        p_tasks_in                => l_task_in,
                        p_tasks_out               => l_task_out
                       );

              --dbms_output.put_line('status :' || x_return_status);

          IF x_return_status = 'S' THEN
           /* Update the status in the icm table */
            UPDATE amw_audit_projects
            SET    audit_project_status = p_project_status
            WHERE  project_id = p_project_id
              AND  audit_project_status <> p_project_status;

           /* Update the signOffRequired flag in the icm table */
            UPDATE amw_audit_projects
            SET    sign_off_required_flag = p_sign_off_required
            WHERE  project_id = p_project_id
              AND  NVL(sign_off_required_flag,'N') <> p_sign_off_required;
          END IF;


IF x_return_status <> 'S' THEN
  if l_msg_count > 0 THEN
    for i in 1..l_msg_count loop
        pa_interface_utils_pub.get_messages(
                p_data           => l_data
                ,p_msg_index      => i
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_msg_index_out  => l_msg_index_out );

        if l_data IS NOT NULL then
          p_msg_data := p_msg_data || l_data;
        end if;
--      dbms_output.put_line(l_data);
    end loop;
  end if;
END IF;


END update_engagement_in_pa;

PROCEDURE create_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_parent_task_id            IN      NUMBER,
    p_task_name                 IN      VARCHAR2,
    p_task_number               IN      VARCHAR2,
    p_task_description          IN      VARCHAR2,
    p_task_manager              IN      NUMBER,
    p_start_date                IN      DATE ,
    p_completion_date           IN      DATE ,
    p_task_id                   OUT     nocopy NUMBER,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
) IS


   l_commit              VARCHAR2(1) := 'F';
   l_init_msg_list          VARCHAR2(1) := 'F';
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out     NUMBER;
   l_data          VARCHAR2(2000);

   l_pa_project_id_out  NUMBER;
   l_pa_project_number_out  VARCHAR2(25);
   l_task_id            NUMBER;

   l_prj_number           VARCHAR2(20);
   l_prj_ref              VARCHAR2(20);
   l_return_status      VARCHAR2(1);


BEGIN

   PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
           p_api_version_number => 1,
           p_responsibility_id   => FND_GLOBAL.RESP_ID,
           p_user_id           => FND_GLOBAL.USER_ID,
           p_resp_appl_id      => 242,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data,
           p_return_status     => l_return_status);

   select segment1,pm_project_reference into l_prj_number,l_prj_ref
   from pa_projects_all
   where project_id = p_project_id;

   FND_MSG_PUB.initialize;

   PA_PROJECT_PUB.ADD_TASK(
                p_api_version_number    => 1
               ,p_commit                => l_commit
               ,p_init_msg_list         => l_init_msg_list
               ,p_msg_count             => l_msg_count
               ,p_msg_data              => l_msg_data
               ,p_return_status         => x_return_status
               ,p_pm_product_code       => 'AMW'
               ,p_pm_project_reference  => l_prj_ref
               ,p_pa_project_id         => p_project_id
               ,p_pa_parent_task_id   => p_parent_task_id
               ,p_pm_task_reference     => p_task_number
               ,p_pa_task_number        => p_task_number
               ,p_task_name             => p_task_name
               ,p_task_description      => p_task_description
               ,p_pa_project_id_out     => l_pa_project_id_out
               ,p_pa_project_number_out => l_pa_project_number_out
               ,p_task_id               => p_task_id);

--   dbms_output.put_line('status :' || x_return_status);

   IF x_return_status <> 'S' THEN
     if l_msg_count > 0 THEN
       for i in 1..l_msg_count loop
         pa_interface_utils_pub.get_messages(
                p_data           => l_data
                ,p_msg_index      => i
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_msg_index_out  => l_msg_index_out );

         if l_data IS NOT NULL then
           p_msg_data := p_msg_data || l_data;
         end if;
--       dbms_output.put_line(l_data);
       end loop;
     end if;
   END IF;

END create_audit_task_in_pa;


PROCEDURE update_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_task_id                   IN      NUMBER,
    p_parent_task_id            IN      NUMBER,
    p_task_name                 IN      VARCHAR2,
    p_task_number               IN      VARCHAR2,
    p_task_description          IN      VARCHAR2,
    p_task_manager              IN      NUMBER,
    p_start_date                IN      DATE ,
    p_completion_date           IN      DATE ,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
) IS


   l_commit              VARCHAR2(1) := 'F';
   l_init_msg_list          VARCHAR2(1) := 'F';
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out     NUMBER;
   l_data          VARCHAR2(2000);

   l_out_pa_task_id  NUMBER;
   l_out_pm_task_reference  VARCHAR2(25);
   l_task_id            NUMBER;

   l_prj_number           VARCHAR2(20);
   l_prj_ref              VARCHAR2(20);
   l_return_status      VARCHAR2(1);


BEGIN

   PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
           p_api_version_number => 1,
           p_responsibility_id   => FND_GLOBAL.RESP_ID,
           p_user_id           => FND_GLOBAL.USER_ID,
           p_resp_appl_id      => 242,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data,
           p_return_status     => l_return_status);

   select segment1,pm_project_reference into l_prj_number,l_prj_ref
   from pa_projects_all
   where project_id = p_project_id;

   FND_MSG_PUB.initialize;

   PA_PROJECT_PUB.UPDATE_TASK(
                p_api_version_number    => 1
               ,p_commit                => l_commit
               ,p_init_msg_list         => l_init_msg_list
               ,p_msg_count             => l_msg_count
               ,p_msg_data              => l_msg_data
               ,p_return_status         => x_return_status
               ,p_pm_product_code       => 'AMW'
               ,p_pm_project_reference  => l_prj_ref
               ,p_pa_project_id         => p_project_id
               ,p_pm_task_reference     => p_task_number
               ,p_pa_task_id               => p_task_id
               ,p_task_name             => p_task_name
               ,p_task_number        => p_task_number
               ,p_task_description      => p_task_description
--               ,p_pa_parent_task_id   => p_parent_task_id
               ,p_out_pa_task_id        => l_out_pa_task_id
               ,p_out_pm_task_reference => l_out_pm_task_reference);

--   dbms_output.put_line('status :' || x_return_status);

   IF x_return_status <> 'S' THEN
     if l_msg_count > 0 THEN
       for i in 1..l_msg_count loop
         pa_interface_utils_pub.get_messages(
                p_data           => l_data
                ,p_msg_index      => i
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_msg_index_out  => l_msg_index_out );

         if l_data IS NOT NULL then
           p_msg_data := p_msg_data || l_data;
         end if;
--       dbms_output.put_line(l_data);
       end loop;
     end if;
   END IF;

END update_audit_task_in_pa;


PROCEDURE delete_audit_task_in_pa(
    p_project_id                IN      NUMBER,
    p_task_id                   IN      NUMBER,
--    p_task_number               IN      VARCHAR2,
    p_msg_data                  OUT     nocopy VARCHAR2,
    x_return_status             OUT     nocopy VARCHAR2
) IS


   l_commit              VARCHAR2(1) := 'F';
   l_init_msg_list          VARCHAR2(1) := 'F';
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   l_msg_index_out     NUMBER;
   l_data          VARCHAR2(2000);

   l_task_id  NUMBER;
   l_project_id            NUMBER;

   l_prj_number           VARCHAR2(20);
   l_prj_ref              VARCHAR2(20);
   l_return_status      VARCHAR2(1);

   l_task_number        VARCHAR2(25);


BEGIN

   PA_INTERFACE_UTILS_PUB.SET_GLOBAL_INFO(
           p_api_version_number => 1,
           p_responsibility_id   => FND_GLOBAL.RESP_ID,
           p_user_id           => FND_GLOBAL.USER_ID,
           p_resp_appl_id      => 242,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data,
           p_return_status     => l_return_status);

   select segment1,pm_project_reference into l_prj_number,l_prj_ref
   from pa_projects_all
   where project_id = p_project_id;

   select task_number into l_task_number
   from pa_tasks
   where task_id = p_task_id
   and project_id = p_project_id;

   FND_MSG_PUB.initialize;

   PA_PROJECT_PUB.DELETE_TASK(
                p_api_version_number    => 1
               ,p_commit                => l_commit
               ,p_init_msg_list         => l_init_msg_list
               ,p_msg_count             => l_msg_count
               ,p_msg_data              => l_msg_data
               ,p_return_status         => x_return_status
               ,p_pm_product_code       => 'AMW'
               ,p_pm_project_reference  => l_prj_ref
               ,p_pa_project_id         => p_project_id
               ,p_pm_task_reference     => l_task_number
               ,p_pa_task_id            => p_task_id
               ,p_cascaded_delete_flag  => 'Y'
               ,p_project_id            => l_project_id
               ,p_task_id               => l_task_id);

--   dbms_output.put_line('status :' || x_return_status);

   IF x_return_status <> 'S' THEN
     if l_msg_count > 0 THEN
       for i in 1..l_msg_count loop
         pa_interface_utils_pub.get_messages(
                p_data           => l_data
                ,p_msg_index      => i
                ,p_msg_count      => l_msg_count
                ,p_msg_data       => l_msg_data
                ,p_msg_index_out  => l_msg_index_out );

         if l_data IS NOT NULL then
           p_msg_data := p_msg_data || l_data;
         end if;
--       dbms_output.put_line(l_data);
       end loop;
     end if;
   END IF;

END delete_audit_task_in_pa;


PROCEDURE delete_audit_task_in_icm(
    p_audit_project_id  IN      NUMBER,
    p_task_id           IN      NUMBER,
    x_return_status     OUT     nocopy VARCHAR2
) IS

   l_audit_project_id  NUMBER ;
 BEGIN

   DELETE  FROM amw_audit_tasks_b
   WHERE task_id IN (SELECT task_id
                     FROM amw_audit_tasks_b
                     START WITH task_id = p_task_id
                     CONNECT BY PRIOR task_id = parent_task_id);

   DELETE  FROM amw_audit_tasks_tl
   WHERE task_id IN (SELECT task_id
                     FROM amw_audit_tasks_b
                     START WITH task_id = p_task_id
                     CONNECT BY PRIOR task_id = parent_task_id);

     x_return_status := 'S';
     COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';

END delete_audit_task_in_icm;

FUNCTION is_workplan_version_shared( p_project_id IN NUMBER) return VARCHAR2
IS

  l_fin_structure_id  NUMBER;
  l_published         VARCHAR2(1):='N';
  l_versioned         VARCHAR2(1):='N';
  l_shared            VARCHAR2(1):='N';
  l_dummy             VARCHAR2(1):='N';
BEGIN

   l_fin_structure_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUCTURE_ID(p_project_id);
   IF l_fin_structure_id is NOT NULL THEN
     l_published := PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_project_id,l_fin_structure_id);
   END IF;
   l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id);
   l_shared    := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(p_project_id);

   IF (l_shared = 'Y' AND l_published = 'Y' AND l_versioned = 'Y') THEN
     l_dummy := 'Y';
   END IF;

   return l_dummy;
END is_workplan_version_shared;

PROCEDURE cp_tasks
    ( p_source_project_id IN NUMBER,
      p_dest_project_id IN NUMBER,
      x_return_status OUT nocopy VARCHAR2)
    IS
      -- Enter the procedure variables here. As shown below
     l_audit_procedure_id NUMBER;
     l_audit_procedure_rev_id NUMBER;
     v_category_id    NUMBER;
     src_task_id NUMBER;
     dest_task_id NUMBER;
     org_id NUMBER;

     TYPE ap_cur_type IS REF CURSOR; --RETURN amw_ap_associations%ROWTYPE;
     my_rec ap_cur_type;
     x_number amw_ap_associations.audit_procedure_id%TYPE;

      CURSOR c_srceng_ap IS
        SELECT
                    PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    APPROVAL_STATUS,
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    END_DATE,
                    APPROVAL_DATE,
                    AUDIT_PROCEDURE_ID,
                    AUDIT_PROCEDURE_REV_ID,
                    CURR_APPROVED_FLAG,
                    LATEST_REVISION_FLAG,
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
   	                CLASSIFICATION
        FROM AMW_AUDIT_PROCEDURES_B
        WHERE PROJECT_ID = p_source_project_id and
                    (END_DATE>=SYSDATE  or END_DATE is null);
    cursor c_tasks
      is
      select src.task_id src_task_id,dest.task_id dest_task_id
      from amw_audit_tasks_v src , amw_audit_tasks_v dest
       where dest.audit_project_id =p_dest_project_id
       and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number;

      CURSOR c_apdetails IS
            select  distinct src.pk1 src_pk1,src.pk2 src_pk2,src.pk3 src_pk3,src.pk4 src_pk4,
                dest.pk1 dest_pk1,dest.pk2 dest_pk2,dest.pk3 dest_pk3,
                dest.pk4 dest_pk4,src.audit_procedure_rev_id src_audit_procedure_rev_id,
                dest.audit_procedure_rev_id dest_audit_procedure_rev_id
            from amw_ap_associations src ,amw_ap_associations dest
            where src.pk1=p_source_project_id and dest.pk1=p_dest_project_id
                and src.OBJECT_TYPE='PROJECT' and src.association_creation_date is not null
                and dest.OBJECT_TYPE ='PROJECT_NEW' and dest.association_creation_date is not null
                and src.pk2=dest.pk2 and src.pk3=dest.pk3
                and src.audit_procedure_id =dest.audit_procedure_id ;

     Cursor c_task_icm is select src.task_id src_task_id,dest.task_id dest_task_id
        from amw_audit_tasks_v src , amw_audit_tasks_v dest
        where dest.audit_project_id =p_dest_project_id
        and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number
        and src.source_code='ICM';

   BEGIN

FOR ap_rec IN c_srceng_ap
    LOOP
    select amw_procedures_s.nextval into l_audit_procedure_id from dual;
    select amw_procedure_rev_s.nextval into l_audit_procedure_rev_id from dual;
   -- l_audit_procedure_id :=amw_procedures_s.nextval;
  --  l_audit_procedure_rev_id :=amw_procedure_rev_s.nextval;
     insert into AMW_AUDIT_PROCEDURES_B (
                    PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    OBJECT_VERSION_NUMBER,
                    APPROVAL_STATUS,
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    AUDIT_PROCEDURE_ID,
                    AUDIT_PROCEDURE_REV_ID,
                    AUDIT_PROCEDURE_REV_NUM,
                    END_DATE,
                    APPROVAL_DATE,
                    CURR_APPROVED_FLAG,
                    LATEST_REVISION_FLAG,
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CLASSIFICATION
                  )
                    SELECT p_dest_project_id,
                    ap_rec.ATTRIBUTE10,
                    ap_rec.ATTRIBUTE11,
                    ap_rec.ATTRIBUTE12,
                    ap_rec.ATTRIBUTE13,
                    ap_rec.ATTRIBUTE14,
                    ap_rec.ATTRIBUTE15,
                    1,
                    ap_rec.APPROVAL_STATUS,
                    ap_rec.ORIG_SYSTEM_REFERENCE,
                    ap_rec.REQUESTOR_ID,
                    ap_rec.ATTRIBUTE6,
                    ap_rec.ATTRIBUTE7,
                    ap_rec.ATTRIBUTE8,
                    ap_rec.ATTRIBUTE9,
                    ap_rec.SECURITY_GROUP_ID,
                    l_audit_procedure_id,
                    l_audit_procedure_rev_id,
                    1,
                    ap_rec. END_DATE,
                    ap_rec.APPROVAL_DATE,
                    ap_rec.CURR_APPROVED_FLAG,
                    ap_rec.LATEST_REVISION_FLAG,
                    ap_rec.ATTRIBUTE5,
                    ap_rec.ATTRIBUTE_CATEGORY,
                    ap_rec.ATTRIBUTE1,
                    ap_rec.ATTRIBUTE2,
                    ap_rec.ATTRIBUTE3,
                    ap_rec. ATTRIBUTE4,
    			    SYSDATE,
    			    FND_GLOBAL.USER_ID,
    			    SYSDATE,
    			    FND_GLOBAL.USER_ID,
    			    FND_GLOBAL.LOGIN_ID,
                    ap_rec.CLASSIFICATION
                    FROM dual;

    insert into AMW_AUDIT_PROCEDURES_TL (
                    AUDIT_PROCEDURE_REV_ID,
                    NAME,
                    DESCRIPTION,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    SECURITY_GROUP_ID,
                    LANGUAGE,
                    SOURCE_LANG
                    )

                select
                    l_audit_procedure_rev_id,
                    SYSDATE||B.NAME,
                    B.DESCRIPTION,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    B.LAST_UPDATE_LOGIN,
                    B.SECURITY_GROUP_ID,
                    B.LANGUAGE,
                    B.SOURCE_LANG
                from AMW_AUDIT_PROCEDURES_TL B
                where AUDIT_PROCEDURE_REV_ID =ap_rec.AUDIT_PROCEDURE_REV_ID;
     INSERT INTO amw_ap_associations (
        ap_association_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        association_creation_date,
        last_update_login,
        audit_procedure_id,
        audit_procedure_rev_id,
        pk1,
        pk2,
        pk3,
        pk4,
        object_type,
        object_version_number)
        SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE ,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID ,
		l_audit_procedure_id,
		l_audit_procedure_rev_id,
		p_dest_project_id,
		apa.pk2 ,
		apa.pk3,
		apa.pk4,
		'PROJECT_NEW',
		   1
		   from
		   amw_ap_associations apa
		  where  pk1=ap_rec.PROJECT_ID
		    and apa.OBJECT_TYPE='PROJECT' and association_creation_date is not null
		    and apa.AUDIT_PROCEDURE_ID=ap_rec.AUDIT_PROCEDURE_ID
            and  NOT EXISTS
		    (SELECT 'Y' from amw_ap_associations apa2
            where apa2.object_type in ('PROJECT','PROJECT_NEW')
              AND apa2.pk1 = p_dest_project_id
              AND apa2.pk2 = apa.pk2
              AND apa2.pk3 = apa.pk3
              AND apa2.pk4 = apa.pk4
              AND apa2.AUDIT_PROCEDURE_ID=apa.AUDIT_PROCEDURE_ID)
              AND (apa.pk3=-1 or apa.pk3 in (select 1 from amw_control_associations  WHERE object_type='PROJECT'
              AND pk1 = p_source_project_id and control_id=apa.pk3));


            OPEN my_rec FOR SELECT audit_procedure_id from amw_ap_associations where
            pk1=p_dest_project_id and audit_procedure_id=l_audit_procedure_id ;
            LOOP
                FETCH my_rec INTO x_number;
                EXIT WHEN my_rec%NOTFOUND;
            --    DBMS_OUTPUT.PUT_LINE(x_number);
            END LOOP;
        IF(x_number is not null) THEN
        select src.task_id,dest.task_id into src_task_id, dest_task_id
        from amw_audit_tasks_v src , amw_audit_tasks_v dest
        where dest.audit_project_id =p_dest_project_id
        and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number
        and src.task_id=(select distinct pk4 from  amw_ap_associations where
        audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id  );

        update amw_ap_associations  set pk4=dest_task_id
        where pk1=p_dest_project_id and pk4=src_task_id
        and audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id;

		select distinct pk2 into org_id from amw_ap_associations
		where audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id;

	    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROJECT_AP',
                                                     X_from_pk1_value => p_source_project_id,
                                                     X_from_pk2_value =>org_id,
			                                         X_from_pk3_value =>src_task_id,
		                                             X_from_pk4_value =>ap_rec.AUDIT_PROCEDURE_REV_ID,
			                                         X_to_entity_name => 'AMW_PROJECT_AP',
                                                     X_to_pk1_value => p_dest_project_id,
                                                     X_to_pk2_value => org_id,
                                                     X_to_pk3_value => dest_task_id,
                                                     X_to_pk4_value => l_audit_procedure_rev_id,
                                                     X_FROM_CATEGORY_ID => v_category_id,
                                                     X_TO_CATEGORY_ID => v_category_id);
        END IF;


    END LOOP;
     INSERT INTO amw_ap_associations (
        ap_association_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        association_creation_date,
        last_update_login,
        audit_procedure_id,
        audit_procedure_rev_id,
        pk1,
        pk2,
        pk3,
        pk4,
        object_type,
        object_version_number)
        SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE ,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   apa.audit_procedure_id,
		   apa.audit_procedure_rev_id,
		   p_dest_project_id,
		   apa.pk2,
		   apa.pk3,
	       apa.pk4,
		   'PROJECT_NEW',
		   1
		   from
		   amw_ap_associations apa
		   where apa.audit_procedure_id not in (
		   select distinct audit_procedure_id from amw_audit_procedures_b where
           project_id=p_source_project_id
           )
		    and apa.OBJECT_TYPE='PROJECT' and association_creation_date is not null
		    and apa.pk1=p_source_project_id
		    and  NOT EXISTS
		    (SELECT 'Y' from amw_ap_associations apa2
            where apa2.object_type in ('PROJECT','PROJECT_NEW')
              AND apa2.pk1 = p_dest_project_id
              AND apa2.pk2 = apa.pk2
              AND apa2.pk3 = apa.pk3
              AND apa2.pk4 = apa.pk4
              AND apa2.AUDIT_PROCEDURE_ID=apa.AUDIT_PROCEDURE_ID)
              AND (apa.pk3=-1 or apa.pk3 in (select 1 from amw_control_associations  WHERE object_type='PROJECT'
              AND pk1 = p_source_project_id and control_id=apa.pk3));
       FOR ap_task in c_tasks LOOP
        update amw_ap_associations  set pk4=ap_task.dest_task_id
        where pk1=p_dest_project_id and pk4=ap_task.src_task_id;
     END LOOP;

    select category_id into v_category_id
    from fnd_document_categories where name = 'AMW_WORK_PAPERS';

  FOR apdetails_rec IN c_apdetails LOOP
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROJECT_AP',
                                                     X_from_pk1_value => p_source_project_id,
                                                     X_from_pk2_value =>apdetails_rec.src_pk2,
			                                         X_from_pk3_value =>apdetails_rec.src_pk4,
		                                             X_from_pk4_value =>apdetails_rec.src_audit_procedure_rev_id,
			                                         X_to_entity_name => 'AMW_PROJECT_AP',
                                                     X_to_pk1_value => p_dest_project_id,
                                                     X_to_pk2_value => apdetails_rec.dest_pk2,
                                                     X_to_pk3_value => apdetails_rec.dest_pk4,
                                                     X_to_pk4_value => apdetails_rec.dest_audit_procedure_rev_id,
                                                     X_FROM_CATEGORY_ID => v_category_id,
                                                     X_TO_CATEGORY_ID => v_category_id);

   END LOOP;

    update amw_ap_associations  set object_type = 'PROJECT'
       where object_type = 'PROJECT_NEW'
       and pk1 = p_dest_project_id;

    For ap_task_icm in c_task_icm
    LOOP
   --   select  src.audit_procedure_rev_id into l_audit_procedure_rev_id
 --   from amw_ap_associations dest ,amw_ap_associations src
--   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
--    and src.audit_procedure_id=dest.audit_procedure_id
--    and src.pk4=ap_task_icm.src_task_id
--    and src.audit_procedure_rev_id=dest.audit_procedure_rev_id;

    update amw_ap_associations
    set pk4= ap_task_icm.dest_task_id
    where pk1=p_dest_project_id
   and audit_procedure_id in (
   select  src.audit_procedure_id
    from amw_ap_associations dest ,amw_ap_associations src
   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
    and src.audit_procedure_id=dest.audit_procedure_id
    and src.pk4=ap_task_icm.src_task_id
    and src.association_creation_date is null);

    update fnd_attached_documents
    set pk3_value=ap_task_icm.dest_task_id
    where pk1_value=to_char(p_dest_project_id) and pk3_value=-1
    and pk4_value in (
    select  src.audit_procedure_rev_id
    from amw_ap_associations dest ,amw_ap_associations src
   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
    and src.audit_procedure_id=dest.audit_procedure_id
    and src.pk4=ap_task_icm.src_task_id
    and src.association_creation_date is null) ;

   END LOOP;


   END cp_tasks;

PROCEDURE cp_tasks_all(
    p_source_project_id		IN	 NUMBER,
    p_dest_project_id          IN       NUMBER,
    x_return_status             OUT      nocopy VARCHAR2
) IS

    -- Enter the procedure variables here. As shown below
     l_audit_procedure_id NUMBER;
     l_audit_procedure_rev_id NUMBER;
     v_category_id    NUMBER;
     src_task_id NUMBER;
     dest_task_id NUMBER;
     org_id NUMBER;


      CURSOR c_srceng_ap IS
        SELECT
                    PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    APPROVAL_STATUS,
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    END_DATE,
                    APPROVAL_DATE,
                    AUDIT_PROCEDURE_ID,
                    AUDIT_PROCEDURE_REV_ID,
                    CURR_APPROVED_FLAG,
                    LATEST_REVISION_FLAG,
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
   	                CLASSIFICATION
        FROM AMW_AUDIT_PROCEDURES_B
        WHERE PROJECT_ID = p_source_project_id and
                    (END_DATE>=SYSDATE  or END_DATE is null);
    cursor c_tasks
      is
      select src.task_id src_task_id,dest.task_id dest_task_id
      from amw_audit_tasks_v src , amw_audit_tasks_v dest
       where dest.audit_project_id =p_dest_project_id
       and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number;

      CURSOR c_apdetails IS
            select  distinct src.pk1 src_pk1,src.pk2 src_pk2,src.pk3 src_pk3,src.pk4 src_pk4,
                dest.pk1 dest_pk1,dest.pk2 dest_pk2,dest.pk3 dest_pk3,
                dest.pk4 dest_pk4,src.audit_procedure_rev_id src_audit_procedure_rev_id,
                dest.audit_procedure_rev_id dest_audit_procedure_rev_id
            from amw_ap_associations src ,amw_ap_associations dest
            where src.pk1=p_source_project_id and dest.pk1=p_dest_project_id
                and src.OBJECT_TYPE='PROJECT' and src.association_creation_date is not null
                and dest.OBJECT_TYPE ='PROJECT_NEW' and dest.association_creation_date is not null
                and src.pk2=dest.pk2 and src.pk3=dest.pk3
                and src.audit_procedure_id =dest.audit_procedure_id ;

     Cursor c_task_icm is select src.task_id src_task_id,dest.task_id dest_task_id
        from amw_audit_tasks_v src , amw_audit_tasks_v dest
        where dest.audit_project_id =p_dest_project_id
        and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number
        and src.source_code='ICM';

   BEGIN

FOR ap_rec IN c_srceng_ap
    LOOP
    select amw_procedures_s.nextval into l_audit_procedure_id from dual;
    select amw_procedure_rev_s.nextval into l_audit_procedure_rev_id from dual;
   -- l_audit_procedure_id :=amw_procedures_s.nextval;
  --  l_audit_procedure_rev_id :=amw_procedure_rev_s.nextval;
     insert into AMW_AUDIT_PROCEDURES_B (
                    PROJECT_ID,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    OBJECT_VERSION_NUMBER,
                    APPROVAL_STATUS,
                    ORIG_SYSTEM_REFERENCE,
                    REQUESTOR_ID,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    SECURITY_GROUP_ID,
                    AUDIT_PROCEDURE_ID,
                    AUDIT_PROCEDURE_REV_ID,
                    AUDIT_PROCEDURE_REV_NUM,
                    END_DATE,
                    APPROVAL_DATE,
                    CURR_APPROVED_FLAG,
                    LATEST_REVISION_FLAG,
                    ATTRIBUTE5,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CLASSIFICATION
                  )
                    SELECT p_dest_project_id,
                    ap_rec.ATTRIBUTE10,
                    ap_rec.ATTRIBUTE11,
                    ap_rec.ATTRIBUTE12,
                    ap_rec.ATTRIBUTE13,
                    ap_rec.ATTRIBUTE14,
                    ap_rec.ATTRIBUTE15,
                    1,
                    ap_rec.APPROVAL_STATUS,
                    ap_rec.ORIG_SYSTEM_REFERENCE,
                    ap_rec.REQUESTOR_ID,
                    ap_rec.ATTRIBUTE6,
                    ap_rec.ATTRIBUTE7,
                    ap_rec.ATTRIBUTE8,
                    ap_rec.ATTRIBUTE9,
                    ap_rec.SECURITY_GROUP_ID,
                    l_audit_procedure_id,
                    l_audit_procedure_rev_id,
                    1,
                    ap_rec. END_DATE,
                    ap_rec.APPROVAL_DATE,
                    ap_rec.CURR_APPROVED_FLAG,
                    ap_rec.LATEST_REVISION_FLAG,
                    ap_rec.ATTRIBUTE5,
                    ap_rec.ATTRIBUTE_CATEGORY,
                    ap_rec.ATTRIBUTE1,
                    ap_rec.ATTRIBUTE2,
                    ap_rec.ATTRIBUTE3,
                    ap_rec. ATTRIBUTE4,
    			    SYSDATE,
    			    FND_GLOBAL.USER_ID,
    			    SYSDATE,
    			    FND_GLOBAL.USER_ID,
    			    FND_GLOBAL.LOGIN_ID,
                    ap_rec.CLASSIFICATION
                    FROM dual;

    insert into AMW_AUDIT_PROCEDURES_TL (
                    AUDIT_PROCEDURE_REV_ID,
                    NAME,
                    DESCRIPTION,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    SECURITY_GROUP_ID,
                    LANGUAGE,
                    SOURCE_LANG
                    )

                select
                    l_audit_procedure_rev_id,
                    SYSDATE||B.NAME,
                    B.DESCRIPTION,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    B.LAST_UPDATE_LOGIN,
                    B.SECURITY_GROUP_ID,
                    B.LANGUAGE,
                    B.SOURCE_LANG
                from AMW_AUDIT_PROCEDURES_TL B
                where AUDIT_PROCEDURE_REV_ID =ap_rec.AUDIT_PROCEDURE_REV_ID;
     INSERT INTO amw_ap_associations (
        ap_association_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        association_creation_date,
        last_update_login,
        audit_procedure_id,
        audit_procedure_rev_id,
        pk1,
        pk2,
        pk3,
        pk4,
        object_type,
        object_version_number)
        SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE ,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID ,
		l_audit_procedure_id,
		l_audit_procedure_rev_id,
		p_dest_project_id,
		apa.pk2 ,
		apa.pk3,
		apa.pk4,
		'PROJECT_NEW',
		   1
		   from
		   amw_ap_associations apa
		  where  pk1=ap_rec.PROJECT_ID
		    and apa.OBJECT_TYPE='PROJECT' and association_creation_date is not null
		    and apa.AUDIT_PROCEDURE_ID=ap_rec.AUDIT_PROCEDURE_ID
            and  NOT EXISTS
		    (SELECT 'Y' from amw_ap_associations apa2
            where apa2.object_type in ('PROJECT','PROJECT_NEW')
              AND apa2.pk1 = p_dest_project_id
              AND apa2.pk2 = apa.pk2
              AND apa2.pk3 = apa.pk3
              AND apa2.pk4 = apa.pk4
              AND apa2.AUDIT_PROCEDURE_ID=apa.AUDIT_PROCEDURE_ID);

        select src.task_id,dest.task_id into src_task_id, dest_task_id
        from amw_audit_tasks_v src , amw_audit_tasks_v dest
        where dest.audit_project_id =p_dest_project_id

        and src.audit_project_id =p_source_project_id and src.task_name=dest.task_name
        and src.task_number = dest.task_number
        and src.task_id=(select distinct pk4 from  amw_ap_associations where
        audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id  );

        update amw_ap_associations  set pk4=dest_task_id
        where pk1=p_dest_project_id and pk4=src_task_id
        and audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id;

		select distinct pk2 into org_id from amw_ap_associations
		where audit_procedure_id=l_audit_procedure_id and
		audit_procedure_rev_id=l_audit_procedure_rev_id;

	    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROJECT_AP',
                                                     X_from_pk1_value => p_source_project_id,
                                                     X_from_pk2_value =>org_id,
			                                         X_from_pk3_value =>src_task_id,
		                                             X_from_pk4_value =>ap_rec.AUDIT_PROCEDURE_REV_ID,
			                                         X_to_entity_name => 'AMW_PROJECT_AP',
                                                     X_to_pk1_value => p_dest_project_id,
                                                     X_to_pk2_value => org_id,
                                                     X_to_pk3_value => dest_task_id,
                                                     X_to_pk4_value => l_audit_procedure_rev_id,
                                                     X_FROM_CATEGORY_ID => v_category_id,
                                                     X_TO_CATEGORY_ID => v_category_id);



    END LOOP;
     INSERT INTO amw_ap_associations (
        ap_association_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        association_creation_date,
        last_update_login,
        audit_procedure_id,
        audit_procedure_rev_id,
        pk1,
        pk2,
        pk3,
        pk4,
        object_type,
        object_version_number)
        SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE ,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   apa.audit_procedure_id,
		   apa.audit_procedure_rev_id,
		   p_dest_project_id,
		   apa.pk2,
		   apa.pk3,
	       apa.pk4,
		   'PROJECT_NEW',
		   1
		   from
		   amw_ap_associations apa
		   where apa.audit_procedure_id not in (
		   select distinct audit_procedure_id from amw_audit_procedures_b where
           project_id=p_source_project_id
           )
		    and apa.OBJECT_TYPE='PROJECT' and association_creation_date is not null
		    and apa.pk1=p_source_project_id
		    and  NOT EXISTS
		    (SELECT 'Y' from amw_ap_associations apa2
            where apa2.object_type in ('PROJECT','PROJECT_NEW')
              AND apa2.pk1 = p_dest_project_id
              AND apa2.pk2 = apa.pk2
              AND apa2.pk3 = apa.pk3
              AND apa2.pk4 = apa.pk4
              AND apa2.AUDIT_PROCEDURE_ID=apa.AUDIT_PROCEDURE_ID);
       FOR ap_task in c_tasks LOOP
        update amw_ap_associations  set pk4=ap_task.dest_task_id
        where pk1=p_dest_project_id and pk4=ap_task.src_task_id;
     END LOOP;

    select category_id into v_category_id
    from fnd_document_categories where name = 'AMW_WORK_PAPERS';

  FOR apdetails_rec IN c_apdetails LOOP
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_PROJECT_AP',
                                                     X_from_pk1_value => p_source_project_id,
                                                     X_from_pk2_value =>apdetails_rec.src_pk2,
			                                         X_from_pk3_value =>apdetails_rec.src_pk4,
		                                             X_from_pk4_value =>apdetails_rec.src_audit_procedure_rev_id,
			                                         X_to_entity_name => 'AMW_PROJECT_AP',
                                                     X_to_pk1_value => p_dest_project_id,
                                                     X_to_pk2_value => apdetails_rec.dest_pk2,
                                                     X_to_pk3_value => apdetails_rec.dest_pk4,
                                                     X_to_pk4_value => apdetails_rec.dest_audit_procedure_rev_id,
                                                     X_FROM_CATEGORY_ID => v_category_id,
                                                     X_TO_CATEGORY_ID => v_category_id);

   END LOOP;

    update amw_ap_associations  set object_type = 'PROJECT'
       where object_type = 'PROJECT_NEW'
       and pk1 = p_dest_project_id;

    For ap_task_icm in c_task_icm
    LOOP
   --   select  src.audit_procedure_rev_id into l_audit_procedure_rev_id
 --   from amw_ap_associations dest ,amw_ap_associations src
--   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
--    and src.audit_procedure_id=dest.audit_procedure_id
--    and src.pk4=ap_task_icm.src_task_id
--    and src.audit_procedure_rev_id=dest.audit_procedure_rev_id;

    update amw_ap_associations
    set pk4= ap_task_icm.dest_task_id
    where pk1=p_dest_project_id
   and audit_procedure_id in (
   select  src.audit_procedure_id
    from amw_ap_associations dest ,amw_ap_associations src
   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
    and src.audit_procedure_id=dest.audit_procedure_id
    and src.pk4=ap_task_icm.src_task_id
    and src.association_creation_date is null);

    update fnd_attached_documents
    set pk3_value=ap_task_icm.dest_task_id
    where pk1_value=to_char(p_dest_project_id) and pk3_value=-1
    and pk4_value in (
    select  src.audit_procedure_rev_id
    from amw_ap_associations dest ,amw_ap_associations src
   where dest.pk1=p_dest_project_id and src.pk1=p_source_project_id
    and src.audit_procedure_id=dest.audit_procedure_id
    and src.pk4=ap_task_icm.src_task_id
    and src.association_creation_date is null) ;

   END LOOP;


END cp_tasks_all;


PROCEDURE COPY_SCOPE_INEFF_CONTROLS(
    p_source_entity_id		IN	 NUMBER,
    p_target_entity_id          IN       NUMBER,
    x_return_status             OUT      nocopy VARCHAR2
) IS
  l_audit_project_id NUMBER;
BEGIN


INSERT INTO AMW_EXECUTION_SCOPE (
         EXECUTION_SCOPE_ID,
         ENTITY_TYPE,
         ENTITY_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         SCOPE_CHANGED_STATUS,
         LEVEL_ID,
         SUBSIDIARY_VS,
         SUBSIDIARY_CODE,
         LOB_VS,
         LOB_CODE,
         ORGANIZATION_ID,
         PROCESS_ID,
         PROCESS_ORG_REV_ID,
         TOP_PROCESS_ID,
         PARENT_PROCESS_ID)

      SELECT amw_execution_scope_s.nextval,
                  'PROJECT',
                  p_target_entity_id,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID,
                  'C',
                  LEVEL_ID,
                  SUBSIDIARY_VS,
                  SUBSIDIARY_CODE,
                  LOB_VS,
                  LOB_CODE,
                  ORGANIZATION_ID,
                  PROCESS_ID,
                  PROCESS_ORG_REV_ID,
                  TOP_PROCESS_ID,
                  PARENT_PROCESS_ID
       FROM AMW_EXECUTION_SCOPE aes
       WHERE ENTITY_TYPE = 'PROJECT'
       AND   ENTITY_ID = p_source_entity_id
       AND aes.PROCESS_ID is not null
       and exists(
        select 1 from amw_control_associations where pk1=p_source_entity_id and object_type='PROJECT'
        and control_id  not in (select pk1_value from  amw_opinions_v where  pk2_value =p_source_entity_id
         and audit_result_code ='EFFECTIVE' and
         object_name='AMW_ORG_CONTROL') and  pk3=aes.PROCESS_ID);


        INSERT INTO AMW_EXECUTION_SCOPE (
         EXECUTION_SCOPE_ID,
         ENTITY_TYPE,
         ENTITY_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         SCOPE_CHANGED_STATUS,
         LEVEL_ID,
         SUBSIDIARY_VS,
         SUBSIDIARY_CODE,
         LOB_VS,
         LOB_CODE,
         ORGANIZATION_ID,
         PROCESS_ID,
         PROCESS_ORG_REV_ID,
         TOP_PROCESS_ID,
         PARENT_PROCESS_ID)
         SELECT  amw_execution_scope_s.nextval,
                  'PROJECT',
                  p_target_entity_id,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID,
                  'C',
                  LEVEL_ID,
                  SUBSIDIARY_VS,
                  SUBSIDIARY_CODE,
                  LOB_VS,
                  LOB_CODE,
                  ORGANIZATION_ID,
                  PROCESS_ID,
                  PROCESS_ORG_REV_ID,
                  TOP_PROCESS_ID,
                  PARENT_PROCESS_ID
       FROM AMW_EXECUTION_SCOPE aes
       WHERE ENTITY_TYPE = 'PROJECT'
       AND   ENTITY_ID = p_source_entity_id
       AND aes.PARENT_PROCESS_ID =-1
       AND exists(select 1 from AMW_EXECUTION_SCOPE aes2 where
       exists (select 1 from amw_control_associations where pk1=p_source_entity_id and object_type='PROJECT'
        and control_id  not in (select pk1_value from  amw_opinions_v where  pk2_value =p_source_entity_id
         and audit_result_code ='EFFECTIVE' and
         object_name='AMW_ORG_CONTROL') and  pk3=aes2.PROCESS_ID) and aes.process_id=aes2.parent_process_id );


    INSERT INTO AMW_EXECUTION_SCOPE (
         EXECUTION_SCOPE_ID,
         ENTITY_TYPE,
         ENTITY_ID,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         SCOPE_CHANGED_STATUS,
         LEVEL_ID,
         SUBSIDIARY_VS,
         SUBSIDIARY_CODE,
         LOB_VS,
         LOB_CODE,
         ORGANIZATION_ID,
         PROCESS_ID,
         PROCESS_ORG_REV_ID,
         TOP_PROCESS_ID,
         PARENT_PROCESS_ID)
         SELECT  amw_execution_scope_s.nextval,
                  'PROJECT',
                  p_target_entity_id,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID,
                  'C',
                  LEVEL_ID,
                  SUBSIDIARY_VS,
                  SUBSIDIARY_CODE,
                  LOB_VS,
                  LOB_CODE,
                  ORGANIZATION_ID,
                  PROCESS_ID,
                  PROCESS_ORG_REV_ID,
                  TOP_PROCESS_ID,
                  PARENT_PROCESS_ID
       FROM AMW_EXECUTION_SCOPE aes
       WHERE ENTITY_TYPE = 'PROJECT'
       AND   ENTITY_ID = p_source_entity_id
       AND aes.PROCESS_ID is null
       and exists(
        select 1 from amw_control_associations where pk1=p_source_entity_id and object_type='PROJECT'
        and control_id  not in (select pk1_value from  amw_opinions_v where  pk2_value =p_source_entity_id
         and audit_result_code ='EFFECTIVE' and
         object_name='AMW_ORG_CONTROL') and  pk3 is null);




--select audit_project_id into l_audit_project_id from AMW_AUDIT_SCOPE_PROCESSES where audit_project_id=59134;
--return x_return_status;
END COPY_SCOPE_INEFF_CONTROLS;
END AMW_AUDIT_ENGAGEMENT_PVT;

/

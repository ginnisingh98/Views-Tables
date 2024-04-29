--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUCTURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUCTURE_PVT" as
/* $Header: PAXSTRVB.pls 120.4 2007/02/06 10:24:17 dthakker ship $ */
--
--
function CHECK_ASSO_PROJ_OK
(
        p_task_id                       IN      NUMBER,
        p_project_id    IN      NUMBER
)
return VARCHAR2
IS
        l_looped                VARCHAR2(1);
        l_linked                VARCHAR2(1);
        l_msgcnt                        NUMBER;
        l_msg                                   VARCHAR2(2000);
BEGIN
        pa_debug.set_err_stack('CHECK_ASSO_PROJ_OK');
--
        BEGIN
                PA_PROJ_STRUCTURE_UTILS.CHECK_LOOPED_PROJECT(
                        p_task_id => p_task_id,
                        p_project_id => p_project_id,
                        x_return_status => l_looped,
                        x_msg_count => l_msgcnt,
                        x_msg_data => l_msg
                );
        END;
--
        BEGIN
                PA_PROJ_STRUCTURE_UTILS.CHECK_MERGED_PROJECT(
                        p_task_id => p_task_id,
                        p_project_id => p_project_id,
                        x_return_status => l_linked,
                        x_msg_count => l_msgcnt,
                        x_msg_data => l_msg
                );
        END;
--
        IF ((l_looped = FND_API.G_RET_STS_SUCCESS) AND
                        (l_linked = FND_API.G_RET_STS_SUCCESS)) THEN
                return FND_API.G_RET_STS_SUCCESS;
        ELSE
                return FND_API.G_RET_STS_ERROR;
        END IF;
--
        pa_debug.reset_err_stack;
EXCEPTION
        WHEN OTHERS THEN
                RAISE;
--              return FND_API.G_RET_STS_UNEXP_ERROR;
END CHECK_ASSO_PROJ_OK;
--
--
--
procedure CREATE_RELATIONSHIP
(
        p_api_version                           IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                                                IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                            IN              VARCHAR2        := 'N',
        p_task_id                                               IN              NUMBER,
        p_project_id                            IN              NUMBER,
        x_return_status                 OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                                     OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_msg_data                                      OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
        l_owning_proj_id                                                NUMBER;
        l_create_ok                                                                     VARCHAR2(1);
        l_user_id                                                                               NUMBER;
        l_object_relationships_id               NUMBER;
        l_msg_index_out                                                 NUMBER;
        l_cc_prvdr                                                                      VARCHAR2(1);
--
        l_proj_start_date                                               DATE;
        l_proj_end_date                                                 DATE;
        l_task_start_date                                               DATE;
        l_task_end_date                                                 DATE;
        -- added for Bug: 4537865
        l_new_msg_count                         NUMBER;
        -- added for Bug: 4537865
--
        CURSOR get_owning_project_id(l_task_id NUMBER) IS
        select project_id
        from pa_tasks
        where task_id = l_task_id;
--
        CURSOR get_task_dates(l_task_id NUMBER) IS
        select start_date, completion_date
        from pa_tasks
        where task_id = l_task_id;
--
        CURSOR get_project_dates(l_project_id NUMBER) IS
        select start_date, completion_date
        from pa_projects_all
        where project_id = l_project_id;
--
        CURSOR IS_CC_PRVDR(l_project_id NUMBER) IS
        select cc_prvdr_flag
        from pa_project_types_all t, pa_projects_all p
--Added the org_id join for bug 5561054
	where t.org_id = p.org_id
	and t.project_type = p.project_type and
        p.project_id = l_project_id;
--
        --This is cursor is used when source task id and dest project id are passed to this api.
        --This cursor returns subproject association relationships ids for the
        --given source task id and destination project id.
        CURSOR get_src_task_det(cp_src_task_id NUMBER) IS
         SELECT ppev.element_version_id src_task_ver_id,ppe.project_id src_proj_id
           FROM pa_proj_elements ppe,
                pa_proj_element_versions ppev,
                pa_tasks pt
          WHERE ppe.proj_element_id = cp_src_task_id
            AND ppe.project_id = ppev.project_id
            AND ppe.proj_element_id = ppev.proj_element_id
            AND pt.task_id = ppe.proj_element_id
-- Added for bug 4999937
            AND ppev.parent_structure_version_id =
PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(ppev.project_id);
--
        l_src_task_det_rec  get_src_task_det%ROWTYPE;
        l_dest_proj_name    VARCHAR2(50);
        l_src_task_id       NUMBER;
        l_dest_proj_id      NUMBER;
        -- added for Bug: 4537865
        l_new_dest_proj_id  NUMBER;
        -- added for Bug: 4537865
        l_error_msg_code    VARCHAR2(250);
        l_data              VARCHAR2(250);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(250);
--
Begin
        pa_debug.set_err_stack('CREATE_RELATIONSHIP');
--
        x_return_status :=      FND_API.G_RET_STS_SUCCESS;
        l_user_id := FND_GLOBAL.USER_ID;
--
        l_src_task_id:= p_task_id;
        l_dest_proj_id:=p_project_id;
        IF ((l_dest_proj_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) OR
              (l_dest_proj_id IS NULL)) THEN
           PA_UTILS.ADD_MESSAGE( 'PA', 'PA_PS_DEST_PROJ_NULL');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
--
        OPEN IS_CC_PRVDR(p_project_id);
        LOOP
                FETCH IS_CC_PRVDR INTO l_cc_prvdr;
                EXIT WHEN IS_CC_PRVDR%NOTFOUND;
        END LOOP;
        CLOSE IS_CC_PRVDR;
--
        IF (l_cc_prvdr <> 'Y') AND (l_cc_prvdr <> 'y') THEN
                l_create_ok := CHECK_ASSO_PROJ_OK(p_task_id => p_task_id, p_project_id => p_project_id);
--
                IF (l_create_ok = FND_API.G_RET_STS_SUCCESS) THEN
--
                        OPEN get_src_task_det(p_task_id);
                        FETCH get_src_task_det INTO l_src_task_det_rec;
                        IF get_src_task_det%NOTFOUND THEN
                           PA_UTILS.ADD_Message('PA','PA_STRUCT_CREATE_ERR');
                           x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                        CLOSE get_src_task_det;
                        PA_PROJ_ELEMENTS_UTILS.Project_Name_Or_Id(
                              p_project_name              => l_dest_proj_name
                             ,p_project_id                => l_dest_proj_id
                             ,p_check_id_flag             => PA_STARTUP.G_Check_ID_Flag
                           --,x_project_id                => l_dest_proj_id             * commented for Bug: 4537865
                             ,x_project_id                => l_new_dest_proj_id         -- added for Bug: 4537865
                             ,x_return_status             => x_return_status
                             ,x_error_msg_code            => l_error_msg_code
                        );

                        -- added for Bug: 4537865
                        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        l_dest_proj_id := l_new_dest_proj_id;
                        END IF;
                        -- added for Bug: 4537865

                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           PA_UTILS.ADD_MESSAGE( 'PA', l_error_msg_code);
                           x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
--
                        /* Find owning project id */
                        OPEN get_owning_project_id(p_task_id);
                        LOOP
                                FETCH get_owning_project_id INTO l_owning_proj_id;
                                EXIT WHEN get_owning_project_id%NOTFOUND;
                        END LOOP;
                        CLOSE get_owning_project_id;
--
                        IF (l_owning_proj_id is NULL) THEN
                                /* Selected task does not belong to a valid project */
                                PA_UTILS.ADD_Message('PA','PA_STRUCT_CREATE_ERR');
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        ELSE
                                /* call table handler */
                                /*pa_object_relationships_pkg.insert_row(
                                        p_user_id => l_user_id,
                                        p_object_type_from => 'PA_TASKS',
                                        p_object_id_from1 => p_task_id,
                                        p_object_id_from2 => l_owning_proj_id,
                                        p_object_id_from3 => null,
                                        p_object_id_from4 => null,
                                        p_object_id_from5 => null,
                                        p_object_type_to => 'PA_PROJECTS',
                                        p_object_id_to1 => p_project_id,
                                        p_object_id_to2 => null,
                                        p_object_id_to3 => null,
                                        p_object_id_to4 => null,
                                        p_object_id_to5 => null,
                                        p_relationship_type => 'H',
                                        p_relationship_subtype => null,
                                        p_lag_day => null,
                                        p_imported_lag => null,
                                        p_priority => null,
                                        p_pm_product_code => null,
                                        X_OBJECT_RELATIONSHIP_ID => l_object_relationships_id,
                                        X_RETURN_STATUS => x_return_status
                                );*/ --commented the call to implement new functionality
--
                                 PA_RELATIONSHIP_PVT.create_subproject_association(
                                        p_api_version       =>  p_api_version,
                                        p_init_msg_list     =>  p_init_msg_list,
                                        p_validate_only     =>  p_validate_only,
--                                        p_validation_level  =>  p_validation_level,
--                                        p_calling_module    =>  p_calling_module,
                                        p_commit            =>  p_commit,
                                        p_debug_mode        =>  p_debug_mode,
                                        p_max_msg_count     =>  x_msg_count,
                                        p_src_proj_id       =>  l_src_task_det_rec.src_proj_id,
                                        p_task_ver_id       =>  l_src_task_det_rec.src_task_ver_id,
                                        p_dest_proj_id      =>  l_dest_proj_id,
                                        p_dest_proj_name    =>  l_dest_proj_name,
                                        p_comment           =>  NULL,
                                        x_return_status     =>  x_return_status,
                                      --x_msg_count         =>  x_msg_count,    * commented for Bug Fix: 4537865
                                        x_msg_count         =>  l_new_msg_count, --added for Bug: 4537865
                                        x_msg_data          =>  x_msg_data);
--
                        /* Check for date warning */
                                IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
--
                                        --added for Bug: 4537865
                                        x_msg_count := l_new_msg_count;
                                        --added for Bug: 4537865
                                        OPEN get_task_dates(p_task_id);
                                        LOOP
                                                FETCH get_task_dates INTO l_task_start_date, l_task_end_date;
                                                EXIT WHEN get_task_dates%NOTFOUND;
                                        END LOOP;
                                        CLOSE get_task_dates;
--
                                        OPEN get_project_dates(p_project_id);
                                        LOOP
                                                FETCH get_project_dates INTO l_proj_start_date, l_proj_end_date;
                                                EXIT WHEN get_project_dates%NOTFOUND;
                                        END LOOP;
                                        CLOSE get_project_dates;
--
                                        /* Check for date warning */
                                        /* Check if subproject start date is earlier than task start date */
                                        IF (l_task_start_date IS NOT NULL) THEN
                                                IF (l_proj_start_date IS NULL) THEN
                                                        x_return_status := 'W';
                                                ELSIF (l_proj_start_date < l_task_start_date) THEN
                                                        x_return_status := 'W';
                                                END IF;
                                        END IF;
                                        /* Check if subproject end date is later than task end date */
                                        IF (l_task_end_date IS NOT NULL) THEN
                                                IF      (l_proj_end_date IS NULL) THEN
                                                        x_return_status := 'W';
                                                ELSIF (l_proj_end_date > l_task_end_date) THEN
                                                        x_return_status := 'W';
                                                END IF;
                                        END IF;
--
                                        IF (x_return_status = 'W') THEN
                                                PA_UTILS.Add_Message('PA','PA_STRUCT_DATE_WARNING');
                                        END IF;
--
                                ELSE
                                        PA_UTILS.ADD_Message('PA','PA_STRUCT_CREATE_ERR');
                                END IF; /* End Date warning check */
--
                        END IF; /* End Create Relationship */
                ELSE
                        PA_UTILS.Add_Message('PA','PA_STRUCT_PJ_EXT_IN_STRUCT');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
        ELSE
                PA_UTILS.Add_Message('PA','PA_STRUCT_PROJ_BILLABLE');
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
--
        x_msg_count :=  FND_MSG_PUB.Count_Msg;
--
        IF (x_msg_count = 1) THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );

        ELSE
                x_msg_data := null;
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
        When OTHERS Then
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
END CREATE_RELATIONSHIP;
--
--
--
procedure DELETE_RELATIONSHIP
(
        p_api_version                           IN              NUMBER          := 1.0,
        p_init_msg_list                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_commit                                                IN              VARCHAR2        := FND_API.G_FALSE,
        p_validate_only                 IN              VARCHAR2        := FND_API.G_TRUE,
        p_debug_mode                            IN              VARCHAR2        := 'N',
        p_task_id                                               IN              NUMBER,
        p_project_id                            IN              NUMBER,
        x_return_status                 OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                                     OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_msg_data                                      OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
        l_project_id                                                            NUMBER;
        l_task_id                                                                               NUMBER;
        l_project_from_id           NUMBER;
        l_object_relationship_id                NUMBER;
        l_msg_index_out                                                 NUMBER;
  l_disassociation            VARCHAR2(1);
--
        CURSOR get_all_projects_for_task(l_task_id NUMBER) IS
        select
                object_id_to1, object_relationship_id
        from
                pa_object_relationships
        where
                object_id_from1 = l_task_id and
                OBJECT_TYPE_FROM = 'PA_TASKS' and
                relationship_type = 'H';
--
        CURSOR get_all_tasks_for_project(l_project_id NUMBER) IS
        select
                object_id_from1, object_relationship_id
        from
                pa_object_relationships
        where
                (object_id_to1 = l_project_id and
                relationship_type = 'H')
                or
                (object_id_from2 = l_project_id and
                relationship_type = 'H');
--
        CURSOR get_selected_relationship(l_task_id NUMBER, l_project_id NUMBER) IS
        select
                object_relationship_id
        from
                pa_object_relationships
        where
                object_type_to = 'PA_PROJECTS' and
                object_type_from = 'PA_TASKS' and
                object_id_to1 = l_project_id and
                object_id_from1 = l_task_id and
                relationship_type = 'H';
--
--
         CURSOR get_src_task_det(cp_src_task_id NUMBER) IS
         SELECT ppev.element_version_id src_task_ver_id,ppe.project_id src_proj_id
           FROM pa_proj_elements ppe,
                pa_proj_element_versions ppev,
                pa_tasks pt
          WHERE ppe.proj_element_id = cp_src_task_id
            AND ppe.project_id = ppev.project_id
            AND ppe.proj_element_id = ppev.proj_element_id
            AND pt.task_id = ppe.proj_element_id
	    AND ppev.parent_structure_version_id =
                PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(ppev.project_id); -- Added for Bug 5687144
--
         --This is cursor is used when source task id and dest project id are passed to this api.
         --This cursor returns subproject association relationships ids for the
         --given source task id and destination project id.
--
         CURSOR get_relationship_det1(cp_src_task_ver_id NUMBER,
                                     cp_src_proj_id NUMBER,
                                     cp_dest_proj_id NUMBER) IS
         SELECT porb.object_relationship_id lnk_obj_rel_id,
                porb.record_version_number lnk_rel_rec_ver_number
           FROM pa_proj_element_versions ppev,
                pa_object_relationships pora,
                pa_object_relationships porb,
                pa_proj_elements ppe
          WHERE pora.relationship_type = 'S'
            AND ppev.project_id = cp_src_proj_id
            AND pora.OBJECT_ID_FROM1 = cp_src_task_ver_id
            AND pora.object_type_from = 'PA_TASKS'
            AND pora.OBJECT_ID_to1 = ppev.ELEMENT_VERSION_ID
            AND ppe.proj_element_id = ppev.proj_element_id
            AND pora.object_id_to1=porb.object_id_from1
            AND porb.object_id_to2 <> porb.object_id_from2
	    AND porb.object_id_to2 = cp_dest_proj_id  -- Added for Bug 5687144
            AND porb.object_type_to = 'PA_STRUCTURES'
            AND porb.relationship_type = 'LF'
            AND ppe.link_task_flag = 'Y';
--
         --This cursor is used when the destination project id is not passed to this api
         --This cursor will return all the relationship ids that are going out of the
         --source task version id.
         CURSOR get_all_sub_proj_ass_det(cp_src_task_ver_id NUMBER,
                                         cp_src_proj_id NUMBER) IS
         SELECT porb.object_relationship_id lnk_obj_rel_id,
                porb.record_version_number lnk_rel_rec_ver_number
           FROM pa_proj_element_versions ppev,
                pa_object_relationships pora,
                pa_object_relationships porb,
                pa_proj_elements ppe
          WHERE pora.relationship_type = 'S'
            AND ppev.project_id = cp_src_proj_id
            AND pora.OBJECT_ID_FROM1 = cp_src_task_ver_id
            AND pora.object_type_from = 'PA_TASKS'
            AND pora.OBJECT_ID_to1 = ppev.ELEMENT_VERSION_ID
            AND ppe.proj_element_id = ppev.proj_element_id
            AND pora.object_id_to1=porb.object_id_from1
            AND porb.object_id_to2 <> porb.object_id_from2
            AND porb.object_id_from2 = cp_src_proj_id
            AND porb.object_type_to = 'PA_STRUCTURES'
            AND porb.object_type_from = 'PA_TASKS'
            AND porb.relationship_type ='LF'
            AND ppe.link_task_flag = 'Y';
--
         --This is cursor is used when the source task id is not passed to this api
         --Cursor will return all the incoming links to the financial structure
         --on the p_project_id, which is destination project id.
         CURSOR get_str_sub_proj_ass_det(cp_dest_struct_ver_id NUMBER,
                                         cp_dest_proj_id NUMBER) IS
         SELECT porb.object_relationship_id lnk_obj_rel_id,
                porb.record_version_number lnk_rel_rec_ver_number
           FROM pa_object_relationships porb
          WHERE porb.OBJECT_ID_to1 = cp_dest_struct_ver_id
            AND porb.object_id_from2 = cp_dest_proj_id
            AND porb.object_id_to2 <> porb.object_id_from2
            AND porb.object_type_to = 'PA_STRUCTURES'
            AND porb.object_type_from = 'PA_TASKS'
            AND porb.relationship_type ='LF';
--
          l_rel_id                    NUMBER;
          l_rec_ver_num               NUMBER;
          l_src_task_ver_id           NUMBER;
          l_src_proj_id               NUMBER;
          l_dest_proj_name            VARCHAR2(50);
          l_error_msg_code            VARCHAR2(250);
          l_dest_fin_str_ver_id       NUMBER;
          l_data                      VARCHAR2(250);
          l_msg_count                 NUMBER;
          l_msg_data                  VARCHAR2(250);
--
Begin
        pa_debug.set_err_stack('DELETE_RELATIONSHIP');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
--
        IF p_task_id IS NOT NULL THEN
           OPEN get_src_task_det(p_task_id);
           FETCH get_src_task_det INTO l_src_task_ver_id,l_src_proj_id;
           IF get_src_task_det%NOTFOUND THEN
              PA_UTILS.ADD_Message('PA','PA_STRUCT_CREATE_ERR');
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE get_src_task_det;
        END IF;
--
/* new */
        IF (p_task_id IS NOT NULL) AND (p_project_id IS NOT NULL) THEN
--
--
              OPEN get_relationship_det1(l_src_task_ver_id,l_src_proj_id,p_project_id);
              FETCH get_relationship_det1 INTO l_rel_id,l_rec_ver_num;
              IF get_relationship_det1%NOTFOUND THEN
                 PA_UTILS.ADD_Message('PA','PA_STRUCT_CREATE_ERR');
                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE get_relationship_det1;
--
--
--
    /* check if any children has contract associated to it */
    -- Get task owning project
/*              select project_id
                into l_project_from_id
                from pa_tasks
                where task_id = p_task_id;*/
--
/*              IF (pa_install.is_product_installed('OKE')) THEN
                        OKE_PA_CHECKS_PUB.Disassociation_Allowed(p_api_version => 1.0,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_return_status => x_return_status,
                                From_Project_ID => l_project_from_id,
                                From_Task_ID => p_task_id,
                                To_Project_ID => p_project_id,
                                X_Result => l_disassociation
                        );
                ELSE
                        l_disassociation := 'Y';
                END IF;*/                        --Commented if block
                l_disassociation := 'Y';         --Moved this line here from the above if block
--
                If ('Y' = l_disassociation) THEN
                        /* disassociation allowed */
--
                        /*OPEN get_selected_relationship(p_task_id, p_project_id);
                        LOOP
                                FETCH get_selected_relationship INTO l_object_relationship_id;
                                EXIT WHEN get_selected_relationship%NOTFOUND;
                                BEGIN
                                        pa_object_relationships_pkg.delete_row(
                                                P_OBJECT_RELATIONSHIP_ID => l_object_relationship_id,
                                                P_OBJECT_TYPE_FROM => null,
                                                P_OBJECT_ID_FROM1 => p_task_id,
                                                P_OBJECT_ID_FROM2 => null,
                                                P_OBJECT_ID_FROM3 => null,
                                                P_OBJECT_ID_FROM4 => null,
                                                P_OBJECT_ID_FROM5 => null,
                                                P_OBJECT_TYPE_TO => null,
                                                P_OBJECT_ID_TO1 => p_project_id,
                                                P_OBJECT_ID_TO2 => null,
                                                P_OBJECT_ID_TO3 => null,
                                                P_OBJECT_ID_TO4 => null,
                                                P_OBJECT_ID_TO5 => null,
                                                P_RECORD_VERSION_NUMBER => null,
                                                P_PM_PRODUCT_CODE => null,
                                                X_RETURN_STATUS => x_return_status
                                        );
                                EXCEPTION
                                        WHEN OTHERS THEN
                                                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                                PA_UTILS.ADD_Message('PA','PA_STRUCT_DELETE_ERR');
                                END;
                                EXIT WHEN (x_return_status <> FND_API.G_RET_STS_SUCCESS);
                        END LOOP;*/     --Commented the code to implement new functionality for subproject association
                        PA_RELATIONSHIP_PVT.Delete_SubProject_Association(
                                 p_commit                  =>  p_commit
                                ,p_validate_only           =>  p_validate_only
                                ,p_debug_mode              =>  p_debug_mode
                                ,p_object_relationships_id =>  l_rel_id
                                ,p_record_version_number   =>  l_rec_ver_num
                                ,x_return_status           =>  x_return_status
                                ,x_msg_count               =>  x_msg_count
                                ,x_msg_data                =>  x_msg_data);

                ELSE
                        /* Can't delete relationship due to other contracts*/
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        PA_UTILS.ADD_Message('PA','PA_STRUCT_HAS_SUB_CONT');
                END IF;
        ELSIF (p_task_id IS NOT NULL) AND (p_project_id IS NULL) THEN
                /* If task_id is not null, then delete all relationships that the task is associated with */
    -- Get task owning project
                select project_id
                into l_project_from_id
                from pa_tasks
                where task_id = p_task_id;
--
                OPEN get_all_sub_proj_ass_det(l_src_task_ver_id,l_src_proj_id);
                LOOP
                     l_rec_ver_num:=NULL;
                     l_rel_id:=NULL;
                     FETCH get_all_sub_proj_ass_det INTO l_rel_id,l_rec_ver_num;
                     EXIT WHEN get_all_sub_proj_ass_det%NOTFOUND;
--
--              OPEN get_all_projects_for_task(p_task_id);
--              LOOP
--                      FETCH get_all_projects_for_task INTO l_project_id, l_object_relationship_id;
--                      EXIT WHEN get_all_projects_for_task%NOTFOUND;
--
                        /* check if this relationship can be removed */
                        /*IF (pa_install.is_product_installed('OKE')) THEN
                                OKE_PA_CHECKS_PUB.Disassociation_Allowed(p_api_version => 1.0,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data,
                                        x_return_status => x_return_status,
                                        From_Project_ID => l_project_from_id,
                                        From_Task_ID => p_task_id,
                                        To_Project_ID => l_project_id,
                                        X_Result => l_disassociation
                                );
                        ELSE
                                l_disassociation := 'Y';
                        END IF;*/                                 --Commented if block
                                l_disassociation := 'Y';          --Moved this line here from the above if block
                        if (l_disassociation = 'N') THEN
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                PA_UTILS.ADD_Message('PA','PA_STRUCT_HAS_SUB_CONT');
                        end if;
                        --EXIT when l_disassociation = 'N';
--
                        -- call table handler api
                        BEGIN
                                /*pa_object_relationships_pkg.delete_row(
                                        P_OBJECT_RELATIONSHIP_ID => l_object_relationship_id,
                                        P_OBJECT_TYPE_FROM => null,
                                        P_OBJECT_ID_FROM1 => p_task_id,
                                        P_OBJECT_ID_FROM2 => null,
                                        P_OBJECT_ID_FROM3 => null,
                                        P_OBJECT_ID_FROM4 => null,
                                        P_OBJECT_ID_FROM5 => null,
                                        P_OBJECT_TYPE_TO => null,
                                        P_OBJECT_ID_TO1 => l_project_id,
                                        P_OBJECT_ID_TO2 => null,
                                        P_OBJECT_ID_TO3 => null,
                                        P_OBJECT_ID_TO4 => null,
                                        P_OBJECT_ID_TO5 => null,
                                        P_RECORD_VERSION_NUMBER => null,
                                        P_PM_PRODUCT_CODE => null,
                                        X_RETURN_STATUS => x_return_status
                                );*/    --Commented the code to implement new functionality for subproject association
--
                                PA_RELATIONSHIP_PVT.Delete_SubProject_Association(
                                       p_commit                  =>  p_commit
                                      ,p_validate_only           =>  p_validate_only
                                      ,p_debug_mode              =>  p_debug_mode
                                      ,p_object_relationships_id =>  l_rel_id
                                      ,p_record_version_number   =>  l_rec_ver_num
                                      ,x_return_status           =>  x_return_status
                                      ,x_msg_count               =>  x_msg_count
                                      ,x_msg_data                =>  x_msg_data);
                                EXCEPTION
                                        WHEN OTHERS THEN
                                                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                                PA_UTILS.ADD_Message('PA','PA_STRUCT_DELETE_ERR');
                                END;
                        --EXIT WHEN (x_return_status <> FND_API.G_RET_STS_SUCCESS);

                END LOOP;
--              CLOSE get_all_projects_for_task;
                CLOSE get_all_sub_proj_ass_det;
        ELSIF (p_project_id IS NOT NULL) AND (p_task_id IS NULL) THEN
--
              l_dest_fin_str_ver_id:=PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(p_project_id);
              IF l_dest_fin_str_ver_id IS NULL THEN
                 --get only version for fin
                 PA_PROJECT_STRUCTURE_UTILS.Get_Financial_Version(p_project_id,l_dest_fin_str_ver_id);
              END IF;
--
                /* If project_id is not null, then delete all relationships that the project is associated with */

--              OPEN get_all_tasks_for_project(p_project_id);
--              LOOP
--                      FETCH get_all_tasks_for_project INTO l_task_id, l_object_relationship_id;
--                      EXIT WHEN get_all_tasks_for_project%NOTFOUND;
                OPEN get_str_sub_proj_ass_det(l_dest_fin_str_ver_id,
                                              p_project_id);
                LOOP
                    l_rec_ver_num:=NULL;
                    l_rel_id:=NULL;
                    FETCH get_str_sub_proj_ass_det INTO l_rel_id,l_rec_ver_num;
                    EXIT WHEN get_str_sub_proj_ass_det%NOTFOUND;
                        /* do not need to check subproject relationship because delete task  */
                        /* will check them. do not need to check current project relationship */
                        /* with other tasks because we check if contract is associated to it */
                        /* call table handler api */
                        BEGIN
                                /*pa_object_relationships_pkg.delete_row(
                                        P_OBJECT_RELATIONSHIP_ID => l_object_relationship_id,
                                        P_OBJECT_TYPE_FROM => null,
                                        P_OBJECT_ID_FROM1 => l_task_id,
                                        P_OBJECT_ID_FROM2 => null,
                                        P_OBJECT_ID_FROM3 => null,
                                        P_OBJECT_ID_FROM4 => null,
                                        P_OBJECT_ID_FROM5 => null,
                                        P_OBJECT_TYPE_TO => null,
                                        P_OBJECT_ID_TO1 => p_project_id,
                                        P_OBJECT_ID_TO2 => null,
                                        P_OBJECT_ID_TO3 => null,
                                        P_OBJECT_ID_TO4 => null,
                                        P_OBJECT_ID_TO5 => null,
                                        P_RECORD_VERSION_NUMBER => null,
                                        P_PM_PRODUCT_CODE => null,
                                        X_RETURN_STATUS => x_return_status
                                );*/   --Commented the code to implement new functionality for subproject association
                              PA_RELATIONSHIP_PVT.Delete_SubProject_Association(
                                        p_commit                  =>  p_commit
                                       ,p_validate_only           =>  p_validate_only
                                       ,p_debug_mode              =>  p_debug_mode
                                       ,p_object_relationships_id =>  l_rel_id
                                       ,p_record_version_number   =>  l_rec_ver_num
                                       ,x_return_status           =>  x_return_status
                                       ,x_msg_count               =>  x_msg_count
                                       ,x_msg_data                =>  x_msg_data);
--
                        EXCEPTION
                                WHEN OTHERS THEN
                                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                        PA_UTILS.ADD_Message('PA','PA_STRUCT_DELETE_ERR');
                        END;
                        EXIT WHEN (x_return_status <> FND_API.G_RET_STS_SUCCESS);
                END LOOP;
--              CLOSE get_all_tasks_for_project;
                CLOSE get_str_sub_proj_ass_det;      --SMukka Added
        ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_Message('PA','PA_STRUCT_DELETE_ERR');
        END IF;
--
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
--
        x_msg_count :=  FND_MSG_PUB.Count_Msg;
        IF (x_msg_count = 1) THEN
            pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                                 ,p_msg_index     => 1
                                                 ,p_data          => x_msg_data
                                                 ,p_msg_index_out => l_msg_index_out
                                                 );
        ELSE
            x_msg_data := null;
        END IF;
        pa_debug.reset_err_stack;
EXCEPTION
        When OTHERS Then
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                Raise;
END DELETE_RELATIONSHIP;



end PA_PROJ_STRUCTURE_PVT;


/

--------------------------------------------------------
--  DDL for Package Body PA_USER_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_USER_ATTR_PVT" AS
/* $Header: PAUATTVB.pls 115.3 2003/07/07 22:09:17 anlee noship $ */


-- API name		: DELETE_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE DELETE_USER_ATTRS_DATA
( p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2 := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_project_id                    IN NUMBER
 ,p_proj_element_id               IN NUMBER DEFAULT NULL
 ,p_old_classification_id         IN NUMBER
 ,p_new_classification_id         IN NUMBER DEFAULT NULL
 ,p_classification_type           IN VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_return_status                 VARCHAR2(1);
  l_error_msg_code                VARCHAR2(250);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;

  l_attr_group_id                 NUMBER;
  l_data_level                    VARCHAR2(30);
  l_dummy                         VARCHAR2(1);
  l_dummy2                        VARCHAR2(1);
  l_proj_element_id               NUMBER;

  CURSOR get_deleted_attr_grps1
  IS
  SELECT assocs.attr_group_id, assocs.data_level
  FROM EGO_OBJ_AG_ASSOCS_B assocs,
       FND_OBJECTS obj
  WHERE assocs.classification_code = p_classification_type||':'||to_char(p_old_classification_id)
  AND assocs.object_id = obj.object_id
  AND obj.obj_name = 'PA_PROJECTS'
  MINUS
  SELECT assocs.attr_group_id, assocs.data_level
  FROM EGO_OBJ_AG_ASSOCS_B assocs,
       FND_OBJECTS obj
  WHERE assocs.classification_code = p_classification_type||':'||to_char(p_new_classification_id)
  AND assocs.object_id = obj.object_id
  AND obj.obj_name = 'PA_PROJECTS';

  CURSOR get_deleted_attr_grps2
  IS
  SELECT assocs.attr_group_id, assocs.data_level
  FROM EGO_OBJ_AG_ASSOCS_B assocs,
       FND_OBJECTS obj
  WHERE assocs.classification_code = p_classification_type||':'||to_char(p_old_classification_id)
  AND assocs.object_id = obj.object_id
  AND obj.obj_name = 'PA_PROJECTS';

  CURSOR exists_in_other_drivers(c_attr_group_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE c_attr_group_id IN
  (SELECT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECTS_ALL ppa,
        PA_PROJECT_TYPES ppt,
        FND_OBJECTS obj
   WHERE ppa.project_id = p_project_id
   AND ppa.project_type = ppt.project_type
   AND assocs.classification_code = 'PROJECT_TYPE:'||to_char(ppt.project_type_id)
   AND assocs.data_level = 'PROJECT_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS'
   UNION
   SELECT DISTINCT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECT_CLASSES ppc,
        PA_CLASS_CATEGORIES pcc,
        FND_OBJECTS obj
   WHERE ppc.project_id = p_project_id
   AND ppc.class_category = pcc.class_category
   AND assocs.classification_code = 'CLASS_CATEGORY:'||to_char(pcc.class_category_id)
   AND assocs.data_level = 'PROJECT_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS'
   UNION
   SELECT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECT_CLASSES ppc,
        PA_CLASS_CODES pcc,
        FND_OBJECTS obj
   WHERE ppc.project_id = p_project_id
   AND ppc.class_category = pcc.class_category
   AND ppc.class_code = pcc.class_code
   AND assocs.classification_code = 'CLASS_CODE:'||to_char(pcc.class_code_id)
   AND assocs.data_level = 'PROJECT_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS');

  CURSOR exists_in_other_task_drivers(c_attr_group_id NUMBER, c_proj_element_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE c_attr_group_id IN
  (SELECT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECTS_ALL ppa,
        PA_PROJECT_TYPES ppt,
        FND_OBJECTS obj
   WHERE ppa.project_id = p_project_id
   AND ppa.project_type = ppt.project_type
   AND assocs.classification_code = 'PROJECT_TYPE:'||to_char(ppt.project_type_id)
   AND assocs.data_level = 'TASK_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS'
   UNION
   SELECT DISTINCT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECT_CLASSES ppc,
        PA_CLASS_CATEGORIES pcc,
        FND_OBJECTS obj
   WHERE ppc.project_id = p_project_id
   AND ppc.class_category = pcc.class_category
   AND assocs.classification_code = 'CLASS_CATEGORY:'||to_char(pcc.class_category_id)
   AND assocs.data_level = 'TASK_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS'
   UNION
   SELECT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJECT_CLASSES ppc,
        PA_CLASS_CODES pcc,
        FND_OBJECTS obj
   WHERE ppc.project_id = p_project_id
   AND ppc.class_category = pcc.class_category
   AND ppc.class_code = pcc.class_code
   AND assocs.classification_code = 'CLASS_CODE:'||to_char(pcc.class_code_id)
   AND assocs.data_level = 'TASK_LEVEL'
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS'
   UNION
   SELECT assocs.attr_group_id
   FROM EGO_OBJ_AG_ASSOCS_B assocs,
        PA_PROJ_ELEMENTS ppe,
        FND_OBJECTS obj
   WHERE ppe.project_id = p_project_id
   AND ppe.proj_element_id = c_proj_element_id
   AND assocs.classification_code = 'TASK_TYPE:'||to_char(ppe.type_id)
   AND assocs.object_id = obj.object_id
   AND obj.obj_name = 'PA_PROJECTS');

  CURSOR get_proj_elements
  IS
  SELECT proj_element_id
  FROM PA_PROJ_ELEMENTS
  WHERE project_id = p_project_id;

BEGIN
  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PVT.Delete_User_Attrs_Data BEGIN');
  end if;

  if p_commit = FND_API.G_TRUE then
    savepoint delete_user_attrs_data_pvt;
  end if;

  if p_classification_type IN ('PROJECT_TYPE', 'CLASS_CATEGORY', 'CLASS_CODE') then
    if p_new_classification_id is not NULL then
      OPEN get_deleted_attr_grps1;
      LOOP
        FETCH get_deleted_attr_grps1 INTO l_attr_group_id, l_data_level;
        EXIT WHEN get_deleted_attr_grps1%NOTFOUND;


        if l_data_level = 'PROJECT_LEVEL' then
          OPEN exists_in_other_drivers(l_attr_group_id);
          FETCH exists_in_other_drivers INTO l_dummy;

          if exists_in_other_drivers%NOTFOUND then
            l_dummy := 'N';
            if p_validate_only <> FND_API.G_TRUE then
              DELETE FROM PA_PROJECTS_ERP_EXT_B
              WHERE PROJECT_ID = p_project_id
              AND PROJ_ELEMENT_ID is NULL
              AND ATTR_GROUP_ID = l_attr_group_id;

              DELETE FROM PA_PROJECTS_ERP_EXT_TL
              WHERE PROJECT_ID = p_project_id
              AND PROJ_ELEMENT_ID is NULL
              AND ATTR_GROUP_ID = l_attr_group_id;
            end if;
          end if;

          CLOSE exists_in_other_drivers;
        end if;

        if l_data_level = 'TASK_LEVEL' then
          OPEN get_proj_elements;
          LOOP
            FETCH get_proj_elements INTO l_proj_element_id;
            EXIT WHEN get_proj_elements%NOTFOUND;

            OPEN exists_in_other_task_drivers(l_attr_group_id, l_proj_element_id);
            FETCH exists_in_other_task_drivers INTO l_dummy2;

            if exists_in_other_task_drivers%NOTFOUND then
              if p_validate_only <> FND_API.G_TRUE then
                DELETE FROM PA_PROJECTS_ERP_EXT_B
                WHERE PROJECT_ID = p_project_id
                AND PROJ_ELEMENT_ID = l_proj_element_id
                AND ATTR_GROUP_ID = l_attr_group_id;

                DELETE FROM PA_PROJECTS_ERP_EXT_TL
                WHERE PROJECT_ID = p_project_id
                AND PROJ_ELEMENT_ID = l_proj_element_id
                AND ATTR_GROUP_ID = l_attr_group_id;
              end if;
            end if;

            CLOSE exists_in_other_task_drivers;
          END LOOP;
          CLOSE get_proj_elements;
        end if;

      END LOOP;
      CLOSE get_deleted_attr_grps1;
    else
      OPEN get_deleted_attr_grps2;
      LOOP
        FETCH get_deleted_attr_grps2 INTO l_attr_group_id, l_data_level;
        EXIT WHEN get_deleted_attr_grps2%NOTFOUND;

        if l_data_level = 'PROJECT_LEVEL' then
          OPEN exists_in_other_drivers(l_attr_group_id);
          FETCH exists_in_other_drivers INTO l_dummy;

          if exists_in_other_drivers%NOTFOUND then
            l_dummy := 'N';
            if p_validate_only <> FND_API.G_TRUE then
              DELETE FROM PA_PROJECTS_ERP_EXT_B
              WHERE PROJECT_ID = p_project_id
              AND PROJ_ELEMENT_ID is NULL
              AND ATTR_GROUP_ID = l_attr_group_id;

              DELETE FROM PA_PROJECTS_ERP_EXT_TL
              WHERE PROJECT_ID = p_project_id
              AND PROJ_ELEMENT_ID is NULL
              AND ATTR_GROUP_ID = l_attr_group_id;
            end if;
          end if;

          CLOSE exists_in_other_drivers;
        end if;

        if l_data_level = 'PA_TASKS' then
          OPEN get_proj_elements;
          LOOP
            FETCH get_proj_elements INTO l_proj_element_id;
            EXIT WHEN get_proj_elements%NOTFOUND;

            OPEN exists_in_other_task_drivers(l_attr_group_id, l_proj_element_id);
            FETCH exists_in_other_task_drivers INTO l_dummy2;

            if exists_in_other_task_drivers%NOTFOUND then
              if p_validate_only <> FND_API.G_TRUE then
                DELETE FROM PA_PROJECTS_ERP_EXT_B
                WHERE PROJECT_ID = p_project_id
                AND PROJ_ELEMENT_ID = l_proj_element_id
                AND ATTR_GROUP_ID = l_attr_group_id;

                DELETE FROM PA_PROJECTS_ERP_EXT_TL
                WHERE PROJECT_ID = p_project_id
                AND PROJ_ELEMENT_ID = l_proj_element_id
                AND ATTR_GROUP_ID = l_attr_group_id;
              end if;
            end if;

            CLOSE exists_in_other_task_drivers;
          END LOOP;
          CLOSE get_proj_elements;
        end if;

      END LOOP;
      CLOSE get_deleted_attr_grps2;
    end if;

  elsif p_classification_type = 'TASK_TYPE' then
    OPEN get_deleted_attr_grps1;
    LOOP
      FETCH get_deleted_attr_grps1 INTO l_attr_group_id, l_data_level;
      EXIT WHEN get_deleted_attr_grps1%NOTFOUND;

      OPEN exists_in_other_task_drivers(l_attr_group_id, p_proj_element_id);
      FETCH exists_in_other_task_drivers INTO l_dummy;

      if exists_in_other_task_drivers%NOTFOUND then
        if p_validate_only <> FND_API.G_TRUE then
          DELETE FROM PA_PROJECTS_ERP_EXT_B
          WHERE PROJECT_ID = p_project_id
          AND PROJ_ELEMENT_ID = p_proj_element_id
          AND ATTR_GROUP_ID = l_attr_group_id;

          DELETE FROM PA_PROJECTS_ERP_EXT_TL
          WHERE PROJECT_ID = p_project_id
          AND PROJ_ELEMENT_ID = p_proj_element_id
          AND ATTR_GROUP_ID = l_attr_group_id;
        end if;
      end if;

      CLOSE exists_in_other_task_drivers;
    END LOOP;

    CLOSE get_deleted_attr_grps1;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_commit = FND_API.G_TRUE then
    commit work;
  end if;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PVT.Delete_User_Attrs_Data END');
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PVT',
                              p_procedure_name => 'Delete_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PVT',
                              p_procedure_name => 'Delete_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_USER_ATTRS_DATA;


PROCEDURE DELETE_ALL_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2 := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_project_id                    IN NUMBER
 ,p_proj_element_id               IN NUMBER DEFAULT NULL
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_return_status                 VARCHAR2(1);
  l_error_msg_code                VARCHAR2(250);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;

BEGIN
  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PVT.Delete_All_User_Attrs_Data BEGIN');
  end if;

  if p_commit = FND_API.G_TRUE then
    savepoint delete_all_user_attrs_data_pvt;
  end if;

  if p_validate_only <> FND_API.G_TRUE then
    if p_proj_element_id is NULL then
      DELETE FROM PA_PROJECTS_ERP_EXT_B
      WHERE PROJECT_ID = p_project_id;

      DELETE FROM PA_PROJECTS_ERP_EXT_TL
      WHERE PROJECT_ID = p_project_id;
    else
      DELETE FROM PA_PROJECTS_ERP_EXT_B
      WHERE PROJECT_ID = p_project_id
      AND PROJ_ELEMENT_ID = p_proj_element_id;

      DELETE FROM PA_PROJECTS_ERP_EXT_TL
      WHERE PROJECT_ID = p_project_id
      AND PROJ_ELEMENT_ID = p_proj_element_id;
    end if;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_commit = FND_API.G_TRUE then
    commit work;
  end if;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PVT.Delete_All_User_Attrs_Data END');
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PVT',
                              p_procedure_name => 'Delete_All_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PVT',
                              p_procedure_name => 'Delete_All_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_ALL_USER_ATTRS_DATA;

END PA_USER_ATTR_PVT;

/

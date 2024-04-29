--------------------------------------------------------
--  DDL for Package Body PA_USER_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_USER_ATTR_PUB" AS
/* $Header: PAUATTPB.pls 120.1.12010000.2 2009/06/12 06:00:39 snizam ship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_USER_ATTR_PUB';
G_ATTR_GROUP_TYPE       CONSTANT VARCHAR2(30) := 'PA_PROJ_ATTR_GROUP_TYPE';

-- API name		: COPY_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.
PROCEDURE COPY_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
 ,p_debug_mode                    IN VARCHAR2 := 'N'
 ,p_object_id_from                IN NUMBER
 ,p_object_id_to                  IN NUMBER
 ,p_object_type                   IN VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_errorcode                     OUT NOCOPY NUMBER
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR(30) := 'Copy_User_Attrs_Data';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_orig_proj_pk_value_pairs      EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_proj_pk_value_pairs       EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_orig_task_pk_value_pairs      EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_new_task_pk_value_pairs       EGO_COL_NAME_VALUE_PAIR_ARRAY;

  CURSOR get_project_id(c_task_id NUMBER)
  IS
  SELECT project_id
  FROM PA_PROJ_ELEMENTS
  WHERE proj_element_id = c_task_id;

  CURSOR get_proj_elements(c_project_id NUMBER)
  IS
  SELECT proj_element_id
  FROM PA_PROJ_ELEMENTS
  WHERE project_id = c_project_id;

  CURSOR get_new_proj_element_id(c_old_proj_element_id NUMBER, c_old_project_id NUMBER, c_new_project_id NUMBER)
  IS
  SELECT ppe2.proj_element_id
  FROM PA_PROJ_ELEMENTS ppe, PA_PROJ_ELEMENTS ppe2
  WHERE ppe.project_id = c_old_project_id
  AND ppe.proj_element_id = c_old_proj_element_id
  AND ppe.element_number = ppe2.element_number
  AND ppe2.project_id = c_new_project_id;

  CURSOR get_categories(c_project_id NUMBER)
  IS
  SELECT DISTINCT limiting_value
  FROM pa_project_copy_overrides
  WHERE project_id = c_project_id
  AND field_name = 'CLASSIFICATION';

  CURSOR check_category_removed(c_category VARCHAR2, c_old_project_id NUMBER, c_new_project_id NUMBER)
  IS
  SELECT class_category
  FROM PA_PROJECT_CLASSES
  WHERE project_id = c_old_project_id
  AND class_category = c_category
  AND class_category NOT IN
  (SELECT class_category
   FROM PA_PROJECT_CLASSES
   where project_id = c_new_project_id);

  CURSOR get_codes(c_category VARCHAR2, c_old_project_id NUMBER, c_new_project_id NUMBER)
  IS
  SELECT class_code
  FROM PA_PROJECT_CLASSES
  WHERE project_id = c_old_project_id
  AND class_category = c_category
  MINUS
  SELECT class_code
  FROM PA_PROJECT_CLASSES
  WHERE project_id = c_new_project_id
  AND class_category = c_category;

  CURSOR get_category_id(c_category VARCHAR2)
  IS
  SELECT class_category_id
  FROM PA_CLASS_CATEGORIES
  WHERE class_category = c_category;

  CURSOR get_code_id(c_category VARCHAR2, c_code VARCHAR2)
  IS
  SELECT class_code_id
  FROM PA_CLASS_CODES
  WHERE class_category = c_category
  AND class_code = c_code;


  l_project_id_from               NUMBER;
  l_project_id_to                 NUMBER;
  l_old_proj_element_id           NUMBER;
  l_new_proj_element_id           NUMBER;
  l_category                      VARCHAR2(30);
  l_code                          VARCHAR2(30);
  l_deleted_category              VARCHAR2(30);
  l_category_id                   NUMBER;
  l_code_id                       NUMBER;

  l_return_status                 VARCHAR2(1);
  l_error_msg_code                VARCHAR2(250);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;
  l_errorcode                     NUMBER;

BEGIN
  pa_debug.init_err_stack('PA_USER_ATTR_PUB.Copy_User_Attrs_Data');

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Copy_User_Attrs_Data BEGIN');
  end if;

  if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if p_commit = FND_API.G_TRUE then
     savepoint copy_user_attrs_data;
  end if;

  if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
    FND_MSG_PUB.initialize;
  end if;

  if p_object_type = 'PA_PROJECTS' then

    l_orig_proj_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJECT_ID', p_object_id_from));
    l_new_proj_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJECT_ID', p_object_id_to));

    l_orig_task_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJ_ELEMENT_ID', NULL));
    l_new_task_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJ_ELEMENT_ID', NULL));

    EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data (
     p_api_version                      => 1.0
    ,p_application_id                   => 275
    ,p_object_name                      => 'PA_PROJECTS'
    ,p_old_pk_col_value_pairs           => l_orig_proj_pk_value_pairs
    ,p_old_dtlevel_col_value_pairs      => l_orig_task_pk_value_pairs
    ,p_new_pk_col_value_pairs           => l_new_proj_pk_value_pairs
    ,p_new_dtlevel_col_value_pairs      => l_new_task_pk_value_pairs
    ,p_commit                           => FND_API.G_FALSE
    ,x_return_status                    => l_return_status
    ,x_errorcode                        => l_errorcode
    ,x_msg_count                        => l_msg_count
    ,x_msg_data                         => l_msg_data );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    OPEN get_proj_elements(p_object_id_from);
    LOOP
      FETCH get_proj_elements INTO l_old_proj_element_id;
      EXIT WHEN get_proj_elements%NOTFOUND;

      OPEN get_new_proj_element_id(l_old_proj_element_id, p_object_id_from, p_object_id_to);
      FETCH get_new_proj_element_id INTO l_new_proj_element_id;
      if get_new_proj_element_id%FOUND THEN
        l_orig_task_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJ_ELEMENT_ID', l_old_proj_element_id));
        l_new_task_pk_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PROJ_ELEMENT_ID', l_new_proj_element_id));

        EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data (
         p_api_version                      => 1.0
        ,p_application_id                   => 275
        ,p_object_name                      => 'PA_PROJECTS'
        ,p_old_pk_col_value_pairs           => l_orig_proj_pk_value_pairs
        ,p_old_dtlevel_col_value_pairs      => l_orig_task_pk_value_pairs
        ,p_new_pk_col_value_pairs           => l_new_proj_pk_value_pairs
        ,p_new_dtlevel_col_value_pairs      => l_new_task_pk_value_pairs
        ,p_commit                           => FND_API.G_FALSE
        ,x_return_status                    => l_return_status
        ,x_errorcode                        => l_errorcode
        ,x_msg_count                        => l_msg_count
        ,x_msg_data                         => l_msg_data );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count,
             p_msg_data       => l_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

      end if;
      CLOSE get_new_proj_element_id;

    END LOOP;
    CLOSE get_proj_elements;

    -- Get all of the class categories included as quick entry overrides
    -- For each class category, find out which codes were in the source but are no longer
    -- in the destination
    OPEN get_categories(p_object_id_from);
    LOOP
      FETCH get_categories INTO l_category;
      EXIT WHEN get_categories%NOTFOUND;

      OPEN check_category_removed(l_category, p_object_id_from, p_object_id_to);
      FETCH check_category_removed INTO l_deleted_category;
      if check_category_removed%FOUND THEN
        OPEN get_category_id(l_category);
        FETCH get_category_id INTO l_category_id;
        CLOSE get_category_id;

        PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
         p_validate_only             => FND_API.G_FALSE
        ,p_project_id                => p_object_id_to
        ,p_old_classification_id     => l_category_id
        ,p_classification_type       => 'CLASS_CATEGORY'
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count,
             p_msg_data       => l_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
      CLOSE check_category_removed;

      OPEN get_codes(l_category, p_object_id_from, p_object_id_to);
      LOOP
        FETCH get_codes INTO l_code;
        EXIT WHEN get_codes%NOTFOUND;

        OPEN get_code_id(l_category, l_code);
        FETCH get_code_id INTO l_code_id;
        CLOSE get_code_id;

        PA_USER_ATTR_PUB.DELETE_USER_ATTRS_DATA (
         p_validate_only             => FND_API.G_FALSE
        ,p_project_id                => p_object_id_to
        ,p_old_classification_id     => l_code_id
        ,p_classification_type       => 'CLASS_CODE'
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count,
             p_msg_data       => l_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

      END LOOP;
      CLOSE get_codes;

    END LOOP;
    CLOSE get_categories;

  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_commit = FND_API.G_TRUE then
    commit work;
  end if;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Copy_User_Attrs_Data END');
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_user_attrs_data;
      end if;
      x_errorcode := l_errorcode;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_user_attrs_data;
      end if;
      x_errorcode := l_errorcode;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Copy_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to copy_user_attrs_data;
      end if;
      x_errorcode := l_errorcode;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Copy_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END COPY_USER_ATTRS_DATA;


-- API name		: DELETE_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE DELETE_USER_ATTRS_DATA
( p_api_version                   IN NUMBER   := 1.0
 ,p_init_msg_list                 IN VARCHAR2 := FND_API.G_TRUE
 ,p_commit                        IN VARCHAR2 DEFAULT FND_API.G_FALSE
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
  l_api_name                      CONSTANT VARCHAR(30) := 'Delete_User_Attrs_Data';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_return_status                 VARCHAR2(1);
  l_error_msg_code                VARCHAR2(250);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;

BEGIN
  pa_debug.init_err_stack('PA_USER_ATTR_PUB.Delete_User_Attrs_Data');

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Delete_User_Attrs_Data BEGIN');
  end if;

  if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

   if p_commit = FND_API.G_TRUE then
     savepoint delete_user_attrs_data;
   end if;

  if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
    FND_MSG_PUB.initialize;
  end if;

  PA_USER_ATTR_PVT.DELETE_USER_ATTRS_DATA (
   p_commit                      => FND_API.G_FALSE
  ,p_validate_only               => p_validate_only
  ,p_validation_level            => p_validation_level
  ,p_calling_module              => p_calling_module
  ,p_debug_mode                  => p_debug_mode
  ,p_project_id                  => p_project_id
  ,p_proj_element_id             => p_proj_element_id
  ,p_old_classification_id       => p_old_classification_id
  ,p_new_classification_id       => p_new_classification_id
  ,p_classification_type         => p_classification_type
  ,x_return_status               => l_return_status
  ,x_msg_count                   => l_msg_count
  ,x_msg_data                    => l_msg_data );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    x_msg_count := FND_MSG_PUB.count_msg;
    if x_msg_count = 1 then
      pa_interface_utils_pub.get_messages
      (p_encoded        => FND_API.G_TRUE,
       p_msg_index      => 1,
       p_msg_count      => l_msg_count,
       p_msg_data       => l_msg_data,
       p_data           => l_data,
       p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_commit = FND_API.G_TRUE then
    commit work;
  end if;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Delete_User_Attrs_Data END');
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Delete_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Delete_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_USER_ATTRS_DATA;



-- API name		: CHECK_DELETE_ASSOC_OK
-- Type			: Public
-- Pre-reqs		: None.

PROCEDURE CHECK_DELETE_ASSOC_OK
( p_api_version                   IN NUMBER   := 1.0
 ,p_association_id                IN NUMBER
 ,p_classification_code           IN VARCHAR2
 ,p_data_level                    IN VARCHAR2
 ,p_attr_group_id                 IN NUMBER
 ,p_application_id                IN NUMBER
 ,p_attr_group_type               IN VARCHAR2
 ,p_attr_group_name               IN VARCHAR2
 ,p_enabled_code                  IN VARCHAR2
 ,x_ok_to_delete                  OUT NOCOPY VARCHAR2
 ,x_return_status                 OUT NOCOPY VARCHAR2
 ,x_errorcode                     OUT NOCOPY NUMBER
 ,x_msg_count                     OUT NOCOPY NUMBER
 ,x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_api_name                      CONSTANT VARCHAR(30) := 'Check_Delete_Assoc_Ok';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_ok_to_delete                  VARCHAR2(250);
  l_return_status                 VARCHAR2(1);
  l_errorcode                     NUMBER;
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;

  l_dummy                         VARCHAR2(1);
  l_assoc_date                    DATE;
  l_max_ext_date                  DATE;

  CURSOR exists_in_ext_tbl
  IS
  SELECT 'Y'
  FROM PA_PROJECTS_ERP_EXT_B
  WHERE attr_group_id = p_attr_group_id;

  CURSOR get_assoc_date
  IS
  SELECT creation_date
  FROM EGO_OBJ_AG_ASSOCS_B
  WHERE association_id = p_association_id;

  CURSOR get_max_ext_date
  IS
  SELECT max(creation_date)
  FROM PA_PROJECTS_ERP_EXT_B
  WHERE attr_group_id = p_attr_group_id;

BEGIN

  if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  OPEN exists_in_ext_tbl;
  FETCH exists_in_ext_tbl INTO l_dummy;

  if exists_in_ext_tbl%NOTFOUND then
    x_ok_to_delete := FND_API.G_TRUE;
  else
    OPEN get_assoc_date;
    FETCH get_assoc_date INTO l_assoc_date;
    CLOSE get_assoc_date;

    OPEN get_max_ext_date;
    FETCH get_max_ext_date INTO l_max_ext_date;
    CLOSE get_max_ext_date;

    if l_assoc_date > l_max_ext_date then
      x_ok_to_delete := FND_API.G_TRUE;
    else
      x_ok_to_delete := FND_API.G_FALSE;
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_EXT_CANT_DEL_ASSOC');

    end if;
  end if;

  l_msg_count := FND_MSG_PUB.count_msg;
  if l_msg_count > 0 then
     x_msg_count := l_msg_count;
     if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
         p_msg_count      => l_msg_count,
         p_msg_data       => l_msg_data,
         p_data           => l_data,
         p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
     end if;
     x_return_status := FND_API.G_RET_STS_ERROR;
   else
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;

EXCEPTION
   when OTHERS then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                             p_procedure_name => 'Check_Delete_Assoc_Ok',
                             p_error_text     => SUBSTRB(SQLERRM,1,240));
     x_ok_to_delete := FND_API.G_FALSE;
     raise;
END CHECK_DELETE_ASSOC_OK;



-- API name		: DELETE_ALL_USER_ATTRS_DATA
-- Type			: Public
-- Pre-reqs		: None.

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
  l_api_name                      CONSTANT VARCHAR(30) := 'Delete_All_User_Attrs_Data';
  l_api_version                   CONSTANT NUMBER      := 1.0;

  l_return_status                 VARCHAR2(1);
  l_errorcode                     NUMBER;
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(250);
  l_msg_index_out                 NUMBER;

BEGIN
  pa_debug.init_err_stack('PA_USER_ATTR_PUB.Delete_All_User_Attrs_Data');

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Delete_All_User_Attrs_Data BEGIN');
  end if;

  if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

   if p_commit = FND_API.G_TRUE then
     savepoint delete_all_user_attrs_data;
   end if;

  if FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_FALSE)) then
    FND_MSG_PUB.initialize;
  end if;

  PA_USER_ATTR_PVT.DELETE_ALL_USER_ATTRS_DATA (
   p_commit                      => FND_API.G_FALSE
  ,p_validate_only               => p_validate_only
  ,p_validation_level            => p_validation_level
  ,p_calling_module              => p_calling_module
  ,p_debug_mode                  => p_debug_mode
  ,p_project_id                  => p_project_id
  ,p_proj_element_id             => p_proj_element_id
  ,x_return_status               => l_return_status
  ,x_msg_count                   => l_msg_count
  ,x_msg_data                    => l_msg_data );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    x_msg_count := FND_MSG_PUB.count_msg;
    if x_msg_count = 1 then
      pa_interface_utils_pub.get_messages
      (p_encoded        => FND_API.G_TRUE,
       p_msg_index      => 1,
       p_msg_count      => l_msg_count,
       p_msg_data       => l_msg_data,
       p_data           => l_data,
       p_msg_index_out  => l_msg_index_out);
       x_msg_data := l_data;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  if p_commit = FND_API.G_TRUE then
    commit work;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_debug_mode = 'Y') then
    pa_debug.debug('PA_USER_ATTR_PUB.Delete_All_User_Attrs_Data END');
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Delete_All_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_all_user_attrs_data;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'Delete_All_User_Attrs_Data',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
END DELETE_ALL_USER_ATTRS_DATA;


-- API name     : Process_User_Attrs_Data
-- Type         : Public
-- Pre-reqs     : None.
-- Description  : This API is a wrapper for the EGO API
--                EGO_USER_ATTRS_DATA_PUB.Process_User_Attr_Data
--                It performs the following operations:
--                1. transpose data from the PA data structure
--                to a format that is understood by the EGO API
--                2. Call the EGO api and return the results
PROCEDURE Process_User_Attrs_Data
(  p_api_version   	 IN   NUMBER := 1.0
   , p_object_name	 IN   VARCHAR2 := 'PA_PROJECTS'
   , p_ext_attr_data_table IN   PA_PROJECT_PUB.PA_EXT_ATTR_TABLE_TYPE
   , p_project_id     IN   NUMBER  := 0
   , p_structure_type IN   VARCHAR2 := 'FINANCIAL'
   , p_entity_id      IN   NUMBER  := NULL
   , p_entity_index   IN   NUMBER  := NULL
   , p_entity_code    IN   VARCHAR2   := NULL
   , p_debug_mode      IN   VARCHAR2 := 'N'
   , p_debug_level    IN   NUMBER     := 0
   , p_init_error_handler        IN   VARCHAR2   := FND_API.G_FALSE
   , p_write_to_concurrent_log   IN   VARCHAR2   := FND_API.G_FALSE
   , p_init_msg_list  IN   VARCHAR2   := FND_API.G_FALSE
   , p_log_errors     IN   VARCHAR2   := FND_API.G_FALSE
   , p_commit         IN   VARCHAR2   := FND_API.G_FALSE
   , x_failed_row_id_list OUT NOCOPY VARCHAR2
   , x_return_status  OUT NOCOPY VARCHAR2
   , x_errorcode      OUT NOCOPY NUMBER
   , x_msg_count      OUT NOCOPY NUMBER
   , x_msg_data       OUT NOCOPY VARCHAR2)
IS

   l_api_name      CONSTANT VARCHAR(30) := 'Process_User_Attrs_Data';
   l_api_version   CONSTANT NUMBER      := 1.0;
   i NUMBER;
   attr_rec PA_PROJECT_PUB.PA_EXT_ATTR_ROW_TYPE;
   p_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
   p_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
   p_attributes_row_table   EGO_USER_ATTR_ROW_TABLE;
   p_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;
   l_prev_loop_row_identifier NUMBER;
   l_at_start_of_row        BOOLEAN;

   l_failed_row_id_list     VARCHAR2(32767);
   l_return_status          VARCHAR2(1);
   l_errorcode              NUMBER;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(1000);
   l_data                   VARCHAR2(250);
   l_msg_index_out          NUMBER;
   l_proj_elem_id           NUMBER;

BEGIN
   pa_debug.init_err_stack('PA_USER_ATTR_PUB.Process_User_Attrs_Data');

   SAVEPOINT PROCESS_USER_ATTRS_DATA_PUB;

   if (p_debug_mode = 'Y') then
     pa_debug.debug('PA_USER_ATTR_PUB.Process_User_Attrs_Data BEGIN');
   end if;

   if not FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   i := p_ext_attr_data_table.first;

   if (p_debug_mode = 'Y') then
     pa_debug.debug('Project Id = ' || to_char(p_project_id));
   end if;

   ------------------------------------------------------------------
   -- Initialization phase:                                        --
   -- 1. Build arrays for the Primary Key columns and the          --
   --    Classification Code columns                               --
   -- 2. We also build Attr Row and Attr Data tables               --
   ------------------------------------------------------------------
   p_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                   EGO_COL_NAME_VALUE_PAIR_OBJ('PROJECT_ID', p_project_id)
                                 );

   p_attributes_row_table := EGO_USER_ATTR_ROW_TABLE();
   p_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();


   ------------------------------------------------------------------
   -- Loop through pl/sql table to build data structures which     --
   -- will be passed in as parameters to the PLM API               --
   ------------------------------------------------------------------
   WHILE i IS NOT NULL LOOP
      attr_rec := p_ext_attr_data_table(i);

      -----------------------------------------------------
      -- Figure out whether we're now starting a new row --
      -----------------------------------------------------
      l_at_start_of_row := (l_prev_loop_row_identifier IS NULL OR
                           l_prev_loop_row_identifier <> attr_rec.ROW_IDENTIFIER);

     ---------------------------------------------------
     -- Build an Attr Row Object for each logical row --
     ---------------------------------------------------
     IF (l_at_start_of_row) THEN

       --------------------------------------------
       -- Resolve PROJ_ELEMENT_ID, if necessary  --
       --------------------------------------------
       l_proj_elem_id := NULL;
       IF (attr_rec.PROJ_ELEMENT_ID IS NULL) THEN
         IF (attr_rec.PROJ_ELEMENT_REFERENCE IS NOT NULL) THEN
            PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
            ( p_pa_project_id       => p_project_id
            , p_structure_type      => p_structure_type
            , p_pm_task_reference   => attr_rec.PROJ_ELEMENT_REFERENCE
            , p_out_task_id         => l_proj_elem_id
            , p_return_status       => l_return_status    );

            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
            THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR)
            THEN
               RAISE  FND_API.G_EXC_ERROR;
            END IF;
         END IF;
       ELSE
         l_proj_elem_id := attr_rec.PROJ_ELEMENT_ID;
       END IF;

       p_attributes_row_table.EXTEND();
       p_attributes_row_table(p_attributes_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(
                                                                attr_rec.ROW_IDENTIFIER
                                                               ,attr_rec.ATTR_GROUP_ID
                                                               ,275
                                                               ,G_ATTR_GROUP_TYPE
                                                               ,attr_rec.ATTR_GROUP_INT_NAME
                                                               ,null
                                                               ,l_proj_elem_id
                                                               ,null
                                                               ,null
                                                               ,null
                                                               ,null
                                                               ,attr_rec.TRANSACTION_TYPE
                                                              );

       IF (p_debug_mode = 'Y') then
         pa_debug.debug('Build Row Object:');
         pa_debug.debug('Row Identifier =' || attr_rec.ROW_IDENTIFIER);
         pa_debug.debug('ATTR_GROUP_ID =' || attr_rec.ATTR_GROUP_ID);
         pa_debug.debug('ATTR_GROUP_INT_NAME =' || attr_rec.ATTR_GROUP_INT_NAME);
         pa_debug.debug('PROJ_ELEMENT_ID =' || l_proj_elem_id);
         pa_debug.debug('TRANSACTION_TYPE =' || attr_rec.TRANSACTION_TYPE);
       END IF;
     END IF;

     ---------------------------------------------------------------
     -- Add an Attr Data object to the Attr Data table every time --
     ---------------------------------------------------------------
     p_attributes_data_table.EXTEND();
     p_attributes_data_table(p_attributes_data_table.LAST) := EGO_USER_ATTR_DATA_OBJ(
                                                                attr_rec.ROW_IDENTIFIER
                                                               ,attr_rec.ATTR_INT_NAME
                                                               ,attr_rec.ATTR_VALUE_STR
                                                               ,attr_rec.ATTR_VALUE_NUM
                                                               ,attr_rec.ATTR_VALUE_DATE
                                                               ,attr_rec.ATTR_DISP_VALUE
                                                               ,null -- ATTR_UNIT_OF_MEASURE
                                                               ,attr_rec.USER_ROW_IDENTIFIER
                                                              );
     IF (p_debug_mode = 'Y') then
       pa_debug.debug('Build Data Object:');
       pa_debug.debug('Row Identifier =' || attr_rec.ROW_IDENTIFIER);
       pa_debug.debug('ATTR_INT_NAME =' || attr_rec.ATTR_INT_NAME);
       pa_debug.debug('ATTR_VALUE_STR =' || attr_rec.ATTR_VALUE_STR);
       pa_debug.debug('ATTR_VALUE_NUM =' || attr_rec.ATTR_VALUE_NUM);
       pa_debug.debug('ATTR_VALUE_DATE =' || attr_rec.ATTR_VALUE_DATE);
       pa_debug.debug('ATTR_DISP_VALUE =' || attr_rec.ATTR_DISP_VALUE);
     END IF;
      ------------------------------------------------------
      -- Update these variables for the next loop through --
      ------------------------------------------------------
      l_prev_loop_row_identifier := attr_rec.ROW_IDENTIFIER;
      i := p_ext_attr_data_table.next(i);

   END LOOP;

   -------------------------------------------------------------------------
   -- Since we are done looping and constructing the pl/sql tables,we are --
   -- ready to process the data we've collected for this project instance --
   -------------------------------------------------------------------------
   if (p_debug_mode = 'Y') then
     pa_debug.debug('>> EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data');
   end if;
   p_class_code_name_value_pairs :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(); --Bug 7688888
   EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
   (
     p_api_version                   => 1.0
    ,p_object_name                   => p_object_name
    ,p_attributes_row_table          => p_attributes_row_table
    ,p_attributes_data_table         => p_attributes_data_table
    ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
    ,p_add_errors_to_fnd_stack	 => FND_API.G_TRUE
    ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs  --Bug 7688888
    ,p_entity_id                     => p_entity_id
    ,p_entity_index                  => p_entity_index
    ,p_entity_code                   => p_entity_code
    ,p_debug_level                   => p_debug_level
    ,p_commit                        => p_commit
    ,p_log_errors                    => FND_API.G_TRUE
    ,x_failed_row_id_list            => l_failed_row_id_list
    ,x_return_status                 => l_return_status
    ,x_errorcode                     => l_errorcode
    ,x_msg_count                     => l_msg_count
    ,x_msg_data                      => l_msg_data
   );
   if (p_debug_mode = 'Y') then
     pa_debug.debug('>> EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data');
     pa_debug.debug('Return Status = ' || l_return_status);
     pa_debug.debug('Message Count = ' || l_msg_count);
   end if;

   -- process error status/messages
   x_failed_row_id_list := l_failed_row_id_list;
   x_return_status      := l_return_status;
   x_errorcode          := l_errorcode;

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => l_msg_count,
          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_commit = FND_API.G_TRUE then
   commit work;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to PROCESS_USER_ATTRS_DATA_PUB;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to PROCESS_USER_ATTRS_DATA_PUB;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'PROCESS_USER_ATTRS_DATA',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
   when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to PROCESS_USER_ATTRS_DATA_PUB;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_USER_ATTR_PUB',
                              p_procedure_name => 'PROCESS_USER_ATTRS_DATA',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;

END Process_User_Attrs_Data;


-- API name     : Check_Class_Assoc_Exists
-- Type         : Public
-- Pre-reqs     : None.

PROCEDURE CHECK_CLASS_ASSOC_EXISTS
(  P_ROW_ID               IN VARCHAR2
  ,P_NEW_CLASS_CATEGORY   IN VARCHAR2 DEFAULT NULL
  ,P_NEW_CLASS_CODE       IN VARCHAR2 DEFAULT NULL
  ,P_MODE                 IN VARCHAR2
  ,X_ASSOC_EXISTS         OUT NOCOPY VARCHAR2
)
IS
  CURSOR C1
  IS
  SELECT class_category, class_code
  FROM PA_PROJECT_CLASSES
  WHERE rowid = p_row_id;

  l_class_category     VARCHAR2(30);
  l_class_category_id  NUMBER;
  l_new_class_category_id NUMBER;
  l_class_code         VARCHAR2(30);
  l_class_code_id      NUMBER;
  l_new_class_code_id  NUMBER;
  l_check_cat_assoc    VARCHAR2(1);
  l_check_new_cat_assoc VARCHAR2(1);
  l_check_code_assoc   VARCHAR2(1);
  l_check_new_code_assoc VARCHAR2(1);

  CURSOR get_class_category_id(c_class_category VARCHAR2)
  IS
  SELECT class_category_id
  FROM PA_CLASS_CATEGORIES
  WHERE class_category = c_class_category;

  CURSOR get_class_code_id(c_class_category VARCHAR2, c_class_code VARCHAR2)
  IS
  SELECT class_code_id
  FROM PA_CLASS_CODES
  WHERE class_category = c_class_category
  AND   class_code = c_class_code;

  CURSOR check_cat_assoc(c_class_category_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS
    (SELECT classification_code
     FROM EGO_OBJ_AG_ASSOCS_B assocs,
          FND_OBJECTS obj
     WHERE assocs.classification_code = 'CLASS_CATEGORY:'||to_char(c_class_category_id)
     AND   assocs.object_id = obj.object_id
     AND obj.obj_name = 'PA_PROJECTS');

  CURSOR check_code_assoc(c_class_code_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS
    (SELECT classification_code
     FROM EGO_OBJ_AG_ASSOCS_B assocs,
          FND_OBJECTS obj
     WHERE assocs.classification_code = 'CLASS_CODE:'||to_char(c_class_code_id)
     AND   assocs.object_id = obj.object_id
     AND obj.obj_name = 'PA_PROJECTS');

BEGIN

  x_assoc_exists := 'N';

  if p_mode = 'DELETE' then
    OPEN C1;
    FETCH C1 INTO l_class_category, l_class_code;
    CLOSE C1;

    OPEN get_class_category_id(l_class_category);
    FETCH get_class_category_id INTO l_class_category_id;
    CLOSE get_class_category_id;

    OPEN get_class_code_id(l_class_category, l_class_code);
    FETCH get_class_code_id INTO l_class_code_id;
    CLOSE get_class_code_id;

    OPEN check_cat_assoc(l_class_category_id);
    FETCH check_cat_assoc INTO l_check_cat_assoc;
    if check_cat_assoc%FOUND then
      x_assoc_exists := 'Y';
      CLOSE check_cat_assoc;
      return;
    end if;

    OPEN check_code_assoc(l_class_code_id);
    FETCH check_code_assoc INTO l_check_code_assoc;
    if check_code_assoc%FOUND then
      x_assoc_exists := 'Y';
      CLOSE check_code_assoc;
      return;
    end if;

  elsif p_mode = 'UPDATE' then
    OPEN C1;
    FETCH C1 INTO l_class_category, l_class_code;
    CLOSE C1;

    if (l_class_category = p_new_class_category) AND (l_class_code = p_new_class_code) then
      return;
    else
      OPEN get_class_category_id(l_class_category);
      FETCH get_class_category_id INTO l_class_category_id;
      CLOSE get_class_category_id;

      OPEN get_class_category_id(p_new_class_category);
      FETCH get_class_category_id INTO l_new_class_category_id;
      CLOSE get_class_category_id;

      OPEN get_class_code_id(l_class_category, l_class_code);
      FETCH get_class_code_id INTO l_class_code_id;
      CLOSE get_class_code_id;

      OPEN get_class_code_id(p_new_class_category, p_new_class_code);
      FETCH get_class_code_id INTO l_new_class_code_id;
      CLOSE get_class_code_id;

      OPEN check_cat_assoc(l_class_category_id);
      FETCH check_cat_assoc INTO l_check_cat_assoc;
      if check_cat_assoc%FOUND then
        x_assoc_exists := 'Y';
        CLOSE check_cat_assoc;
        return;
      end if;
      CLOSE check_cat_assoc;

      OPEN check_cat_assoc(l_new_class_category_id);
      FETCH check_cat_assoc INTO l_check_new_cat_assoc;
      if check_cat_assoc%FOUND then
        x_assoc_exists := 'Y';
        CLOSE check_cat_assoc;
        return;
      end if;
      CLOSE check_cat_assoc;

      OPEN check_code_assoc(l_class_code_id);
      FETCH check_code_assoc INTO l_check_code_assoc;
      if check_code_assoc%FOUND then
        x_assoc_exists := 'Y';
        CLOSE check_code_assoc;
        return;
      end if;
      CLOSE check_code_assoc;

      OPEN check_code_assoc(l_new_class_code_id);
      FETCH check_code_assoc INTO l_check_new_code_assoc;
      if check_code_assoc%FOUND then
        x_assoc_exists := 'Y';
        CLOSE check_code_assoc;
        return;
      end if;
      CLOSE check_code_assoc;
    end if;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_assoc_exists := 'N';

END CHECK_CLASS_ASSOC_EXISTS;


-- API name     : Check_PT_Assoc_Exists
-- Type         : Public
-- Pre-reqs     : None.

PROCEDURE CHECK_PT_ASSOC_EXISTS
(  P_PROJECT_ID           IN NUMBER
  ,P_NEW_PROJECT_TYPE     IN VARCHAR2
  ,X_ASSOC_EXISTS         OUT NOCOPY VARCHAR2
)
IS

  CURSOR check_pt_assoc(c_project_type_id NUMBER)
  IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS
    (SELECT classification_code
     FROM EGO_OBJ_AG_ASSOCS_B assocs,
          FND_OBJECTS obj
     WHERE assocs.classification_code = 'PROJECT_TYPE:'||to_char(c_project_type_id)
     AND   assocs.object_id = obj.object_id
     AND obj.obj_name = 'PA_PROJECTS');

  CURSOR get_old_project_type_id
  IS
  SELECT PTT.project_type_id
  FROM pa_project_types PTT, pa_projects_all PPA
  WHERE PPA.project_id = p_project_id
  AND   PPA.project_type = PTT.project_type;

  CURSOR get_new_project_type_id
  IS
  SELECT project_type_id
  FROM pa_project_types
  WHERE project_type = p_new_project_type;


  l_old_project_type_id    NUMBER;
  l_new_project_type_id    NUMBER;
  l_check_old_pt_assoc     VARCHAR2(1);
  l_check_new_pt_assoc     VARCHAR2(1);

BEGIN
  x_assoc_exists := 'N';

  OPEN get_old_project_type_id;
  FETCH get_old_project_type_id INTO l_old_project_type_id;
  CLOSE get_old_project_type_id;

  OPEN get_new_project_type_id;
  FETCH get_new_project_type_id INTO l_new_project_type_id;
  CLOSE get_new_project_type_id;

  if l_old_project_type_id = l_new_project_type_id then
    return;
  else
    OPEN check_pt_assoc(l_old_project_type_id);
    FETCH check_pt_assoc INTO l_check_old_pt_assoc;
    if check_pt_assoc%FOUND then
      x_assoc_exists := 'Y';
      CLOSE check_pt_assoc;
      return;
    end if;
    CLOSE check_pt_assoc;

    OPEN check_pt_assoc(l_new_project_type_id);
    FETCH check_pt_assoc INTO l_check_new_pt_assoc;
    if check_pt_assoc%FOUND then
      x_assoc_exists := 'Y';
      CLOSE check_pt_assoc;
      return;
    end if;
    CLOSE check_pt_assoc;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    x_assoc_exists :=  'N';

END CHECK_PT_ASSOC_EXISTS;


END PA_USER_ATTR_PUB;

/

--------------------------------------------------------
--  DDL for Package Body PA_WORKPLAN_ATTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORKPLAN_ATTR_UTILS" AS
/* $Header: PAPRWPUB.pls 120.2 2005/08/23 04:30:25 sunkalya noship $ */

-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_WORKPLAN_ATTR_UTILS';

-- API name		: CHECK_LIFECYCLE_NAME_OR_ID
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id	           IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_lifecycle_name                IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_lifecycle_id	           OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_LIFECYCLE_NAME_OR_ID
(  p_lifecycle_id	           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_lifecycle_name                IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_lifecycle_id	           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
   if (p_lifecycle_id = FND_API.G_MISS_NUM) OR (p_lifecycle_id is NULL) then
      if (p_lifecycle_name is not NULL) then
          SELECT pev.element_version_id
          INTO x_lifecycle_id
          FROM pa_proj_elements pe, pa_proj_element_versions pev,
               pa_lifecycle_usages plu
          WHERE pe.project_id=0
          AND   pe.proj_element_id = pev.proj_element_id
          AND   pe.element_number = p_lifecycle_name
          AND   pe.proj_element_id = plu.LIFECYCLE_ID
          AND   plu.USAGE_TYPE = 'PROJECTS';
      else
	  x_lifecycle_id := NULL;
      end if;
   else
      if p_check_id_flag = 'Y' then
         x_lifecycle_id := p_lifecycle_id;
      ELSIF (p_check_id_flag='N') THEN
         x_lifecycle_id := p_lifecycle_id;
      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_lifecycle_name IS NULL) THEN
                 x_lifecycle_id := NULL;
             ELSE
                  SELECT pev.element_version_id
                  INTO x_lifecycle_id
                  FROM pa_proj_elements pe, pa_proj_element_versions pev,
                       pa_lifecycle_usages plu
                  WHERE pe.project_id=0
                  AND   pe.proj_element_id = pev.proj_element_id
                  AND   pe.element_number = p_lifecycle_name
                  AND   pe.proj_element_id = plu.LIFECYCLE_ID
                  AND   plu.USAGE_TYPE = 'PROJECTS';
            END IF;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_lifecycle_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_LCYL_NOT_VALID';
   when OTHERS then
      x_lifecycle_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS', p_procedure_name  => 'CHECK_LIFECYCLE_NAME_OR_ID');
      raise;
END CHECK_LIFECYCLE_NAME_OR_ID;

-- API name		: CHECK_LIFECYCLE_PHASE_NAME_ID
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id	           IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase_id    IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_current_lifecycle_phase       IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_current_lifecycle_phase_id    OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_LIFECYCLE_PHASE_NAME_ID
(  p_lifecycle_id	           IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase_id    IN NUMBER     := FND_API.G_MISS_NUM
  ,p_current_lifecycle_phase       IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_current_lifecycle_phase_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  NO_LIFECYCLE EXCEPTION;
BEGIN
   if (p_lifecycle_id = FND_API.G_MISS_NUM) OR (p_lifecycle_id is NULL) then
      RAISE NO_LIFECYCLE;
   end if;

   if (p_current_lifecycle_phase_id = FND_API.G_MISS_NUM) OR (p_current_lifecycle_phase_id is NULL) then
      if (p_current_lifecycle_phase is not NULL) then
          SELECT pev.element_version_id
          INTO x_current_lifecycle_phase_id
          FROM pa_proj_elements pe, pa_proj_element_versions pev
          WHERE pe.project_id=0
	  AND   pe.element_number = p_current_lifecycle_phase
	  AND   pe.proj_element_id = pev.proj_element_id
   	  AND   pev.parent_structure_version_id = p_lifecycle_id;
      else
	  x_current_lifecycle_phase_id := NULL;
      end if;
   else
      if p_check_id_flag = 'Y' then
         x_current_lifecycle_phase_id := p_current_lifecycle_phase_id;
      ELSIF (p_check_id_flag='N') THEN
         x_current_lifecycle_phase_id := p_current_lifecycle_phase_id;
      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_current_lifecycle_phase IS NULL) THEN
                 x_current_lifecycle_phase_id := NULL;
             ELSE
	          SELECT pev.element_version_id
	          INTO x_current_lifecycle_phase_id
	          FROM pa_proj_elements pe, pa_proj_element_versions pev
        	  WHERE pe.project_id=0
	 	  AND   pe.element_number = p_current_lifecycle_phase
		  AND   pe.proj_element_id = pev.proj_element_id
	   	  AND   pev.parent_structure_version_id = p_lifecycle_id;
            END IF;
      end if;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_LIFECYCLE then
      x_current_lifecycle_phase_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_LCYL_LIFECYCLE_REQUIRED';
   when NO_DATA_FOUND then
      x_current_lifecycle_phase_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_LCYL_PHASE_NOT_VALID';
   when OTHERS then
      x_current_lifecycle_phase_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS', p_procedure_name  => 'CHECK_LIFECYCLE_PHASE_NAME_ID');
      raise;
END CHECK_LIFECYCLE_PHASE_NAME_ID;

-- API name		: Check_Approver_Name_Or_Id
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_approver_source_id            IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_source_type          IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- p_approver_name                 IN VARCHAR2   Optional Default = FND_API.G_MISS_CHAR
-- p_check_id_flag                 IN VARCHAR2   Optional Default = 'A'
-- x_approver_source_id            OUT NUMBER    Required
-- x_approver_source_type          OUT NUMBER    Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required

PROCEDURE CHECK_APPROVER_NAME_OR_ID
(  p_approver_source_id            IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_source_type          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_approver_name                 IN VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_check_id_flag                 IN VARCHAR2   := 'A'
  ,x_approver_source_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_approver_source_type          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_error_msg_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
   l_current_source_id NUMBER := NULL;
   l_current_source_type NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';

   CURSOR c_ids IS
      SELECT resource_source_id, resource_type_id
      FROM pa_people_lov_v
      WHERE name = p_approver_name;

BEGIN
   if (p_approver_source_id = FND_API.G_MISS_NUM) OR (p_approver_source_id is NULL) then
      if (p_approver_name is not NULL) then
          SELECT resource_source_id, resource_type_id
          INTO x_approver_source_id, x_approver_source_type
          FROM pa_people_lov_v
          WHERE name = p_approver_name;
      else
	  x_approver_source_id := NULL;
          x_approver_source_type := NULL;
      end if;
   else
      if p_check_id_flag = 'Y' then
         SELECT resource_source_id, resource_type_id
         INTO x_approver_source_id, x_approver_source_type
         FROM pa_people_lov_v
         WHERE resource_source_id = p_approver_source_id
         AND   resource_type_id = p_approver_source_type;
      ELSIF (p_check_id_flag='N') THEN
         x_approver_source_id := p_approver_source_id;
         x_approver_source_type := p_approver_source_type;

      ELSIF (p_check_id_flag = 'A') THEN
             IF (p_approver_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                 x_approver_source_id := NULL;
                 x_approver_source_type := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_source_id, l_current_source_type;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_source_id = p_approver_source_id) AND
                           (l_current_source_type = p_approver_source_type) THEN
                         	l_id_found_flag := 'Y';
                        	x_approver_source_id := p_approver_source_id;
                                x_approver_source_type := p_approver_source_type;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_approver_source_id := l_current_source_id;
                     x_approver_source_type := l_current_source_type;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;
      end if;
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when NO_DATA_FOUND then
      x_approver_source_id := NULL;
      x_approver_source_type := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_APPR_SOURCE_NAME_INV';
   when TOO_MANY_ROWS then
      x_approver_source_id := NULL;
      x_approver_source_type := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_APPR_SOURCE_NAME_MULTIPLE';
   when OTHERS then
      x_approver_source_id := NULL;
      x_approver_source_type := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS', p_procedure_name  => 'CHECK_APPROVER_NAME_OR_ID');
      raise;
END CHECK_APPROVER_NAME_OR_ID;


-- API name		: Check_Wp_Versioning_Enabled
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id            IN NUMBER     Required


FUNCTION CHECK_WP_VERSIONING_ENABLED
(  p_project_id            IN NUMBER
) RETURN VARCHAR2
IS
   l_wp_versioning_enabled VARCHAR2(1);

   /*Bug No 3489940 */
   /* Modified get_flag cursor to check for workplan structure */
   /*CURSOR get_flag IS
   SELECT wp_enable_version_flag
   FROM pa_proj_workplan_attr
   WHERE project_id = p_project_id;*/
   CURSOR get_flag IS
   SELECT ppwa.wp_enable_version_flag
     FROM pa_proj_workplan_attr ppwa,
          pa_proj_elements ppe,
          pa_proj_structure_types ppst,
          pa_structure_types pst
    WHERE ppwa.project_id = p_project_id
      AND ppe.project_id = ppwa.project_id
      AND ppe.proj_element_id = ppwa.proj_element_id
      AND ppe.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id = pst.structure_type_id
      AND pst.structure_type_class_code = 'WORKPLAN';

BEGIN

   OPEN get_flag;
   FETCH get_flag INTO l_wp_versioning_enabled;
   CLOSE get_flag;

   return l_wp_versioning_enabled;

EXCEPTION
   WHEN OTHERS THEN
     return NULL;
END CHECK_WP_VERSIONING_ENABLED;



-- API name		: Check_DATE_SYNC_ENABLED
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id       IN NUMBER     Required

FUNCTION CHECK_AUTO_DATE_SYNC_ENABLED
(  p_proj_element_id            IN NUMBER
) RETURN VARCHAR2
IS
  l_sync_enabled VARCHAR2(1);
  --Jul 23rd Only Workplan
  CURSOR get_sync_flag IS
  select ppwa.AUTO_SYNC_TXN_DATE_FLAG
    from pa_proj_workplan_attr ppwa,
         pa_proj_elements ppe,
         pa_proj_structure_types ppst,
         pa_structure_types pst
   WHERE ppwa.proj_element_id = p_proj_element_id
     AND ppe.project_id = ppwa.project_id
     AND ppe.proj_element_id = ppwa.proj_element_id
     AND ppe.proj_element_id = ppst.proj_element_id
     AND ppst.structure_type_id = pst.structure_type_id
     AND pst.structure_type_class_code = 'WORKPLAN';
/*  select AUTO_SYNC_TXN_DATE_FLAG
  from pa_proj_workplan_attr
  Where proj_element_id = p_proj_element_id;*/
BEGIN
  open get_sync_flag;
  FETCH get_sync_flag into l_sync_enabled;
  CLOSE get_sync_flag;

  return l_sync_enabled;

END CHECK_AUTO_DATE_SYNC_ENABLED;


-- API name		: GET_SYNC_BUF_DAYS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id       IN NUMBER     Required

FUNCTION GET_SYNC_BUF_DAYS
( p_proj_element_id              IN NUMBER
) RETURN NUMBER
IS
  l_sync_days NUMBER;
  --Jul 23rd Only Workplan
  CURSOR get_sync_days IS
  select ppwa.TXN_DATE_SYNC_BUF_DAYS
    from pa_proj_workplan_attr ppwa,
         pa_proj_elements ppe,
         pa_proj_structure_types ppst,
         pa_structure_types pst
   WHERE ppwa.proj_element_id = p_proj_element_id
     AND ppe.project_id = ppwa.project_id
     AND ppe.proj_element_id = ppwa.proj_element_id
     AND ppe.proj_element_id = ppst.proj_element_id
     AND ppst.structure_type_id = pst.structure_type_id
     AND pst.structure_type_class_code = 'WORKPLAN';
/*  select TXN_DATE_SYNC_BUF_DAYS
  from pa_proj_workplan_attr
  Where proj_element_id = p_proj_element_id;  */
BEGIN
  OPEN get_sync_days;
  FETCH get_sync_days into l_sync_days;
  CLOSE get_sync_days;

  return l_sync_days;
END GET_SYNC_BUF_DAYS;


-- API name		: CHECK_WP_PROJECT_EXISTS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_id       IN NUMBER     Required

PROCEDURE CHECK_WP_PROJECT_EXISTS
(     p_lifecycle_id                  IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  CURSOR get_lifecycle_version(c_proj_element_id IN NUMBER) IS
    SELECT element_version_id
    FROM pa_proj_element_versions
    WHERE proj_element_id = c_proj_element_id;
  cur_lifecycle_version get_lifecycle_version%ROWTYPE;

  CURSOR c1(c_lifecycle_version_id IN NUMBER) IS
    SELECT project_id
    FROM pa_proj_workplan_attr
    WHERE lifecycle_version_id = c_lifecycle_version_id;

  l_delete_lifecycle_error EXCEPTION;
  l_msg_index_out NUMBER;
  -- added for Bug fix: 4537865
  l_new_msg_data	VARCHAR2(2000);
  -- added for Bug fix: 4537865

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_lifecycle_version(p_lifecycle_id);
  FETCH get_lifecycle_version INTO cur_lifecycle_version;
  CLOSE get_lifecycle_version;

  OPEN c1(cur_lifecycle_version.element_version_id);
  IF c1%FOUND THEN
    RAISE l_delete_lifecycle_error;
  END IF;
  CLOSE c1;

EXCEPTION
    WHEN l_delete_lifecycle_error THEN
      PA_UTILS.add_message('PA','PA_DEL_LIFECYCLE_ERROR');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_DEL_LIFECYCLE_ERROR';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,			* Commented for Bug fix: 4537865
					p_data		 => l_new_msg_data,		-- added for Bug fix: 4537865
					p_msg_index_out  => l_msg_index_out );
		 -- added for Bug fix: 4537865
		 x_msg_data := l_new_msg_data;
		 -- added for Bug fix: 4537865
		 End if;

    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS.CHECK_WP_PROJECT_EXISTS',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;

END CHECK_WP_PROJECT_EXISTS;


-- API name		: CHECK_WP_TASK_EXISTS
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_phase_id       IN NUMBER     Required

PROCEDURE CHECK_WP_TASK_EXISTS
(     p_lifecycle_phase_id            IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  CURSOR get_phase_version(c_proj_element_id IN NUMBER) IS
    SELECT element_version_id
    FROM pa_proj_element_versions
    WHERE proj_element_id = c_proj_element_id;
  cur_phase_version get_phase_version%ROWTYPE;

  CURSOR c1(c_phase_version_id IN NUMBER) IS
    SELECT proj_element_id
    FROM pa_proj_elements
    WHERE phase_version_id = c_phase_version_id;

  l_del_lifecycle_phase_error EXCEPTION;
  l_msg_index_out NUMBER;
  -- added for Bug fix: 4537865
  l_new_msg_data	VARCHAR2(2000);
  -- added for Bug fix: 4537865
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN get_phase_version(p_lifecycle_phase_id);
  FETCH get_phase_version INTO cur_phase_version;
  CLOSE get_phase_version;

  OPEN c1(cur_phase_version.element_version_id);
  IF c1%FOUND THEN
    RAISE l_del_lifecycle_phase_error;
  END IF;
  CLOSE c1;

EXCEPTION
  WHEN l_del_lifecycle_phase_error THEN
      PA_UTILS.add_message('PA','PA_DEL_LIFECYCLE_PHASE_ERROR');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_DEL_LIFECYCLE_PHASE_ERROR';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
		--			p_data           => x_msg_data,		* Commented for Bug fix: 4537865
					p_data		 => l_new_msg_data,	-- added for Bug fix: 4537865
					p_msg_index_out  => l_msg_index_out );
		 -- added for Bug fix: 4537865
			x_msg_data := l_new_msg_data;
  		 -- added for Bug fix: 4537865
		 End if;

  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS.CHECK_WP_TASK_EXISTS',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;

END CHECK_WP_TASK_EXISTS;

-- API name		: UPDATE_CURRENT_PHASE
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_lifecycle_phase_id       IN NUMBER     Required
-- p_proj_element_id          IN NUMBER   Required

PROCEDURE UPDATE_CURRENT_PHASE
(
      p_lifecycle_phase_id            IN NUMBER
     ,p_proj_element_id               IN NUMBER
     ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  --Jul 23rd Only Workplan
  CURSOR cur_wrkpln_attrs
  IS
    select ppwa.*
      from pa_proj_workplan_attr ppwa,
           pa_proj_elements ppe,
           pa_proj_structure_types ppst,
           pa_structure_types pst
     WHERE ppwa.proj_element_id = p_proj_element_id
       AND ppe.project_id = ppwa.project_id
       AND ppe.proj_element_id = ppwa.proj_element_id
       AND ppe.proj_element_id = ppst.proj_element_id
       AND ppst.structure_type_id = pst.structure_type_id
       AND pst.structure_type_class_code = 'WORKPLAN';
    /*SELECT *
      FROM PA_PROJ_WORKPLAN_ATTR
     WHERE proj_element_id = p_proj_element_id; */

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(250);
   l_msg_count                     NUMBER;
   l_msg_data                      VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600
   l_data                          VARCHAR2(2000); --precision changed from 250 to 2000 for bug 4093600

  l_del_lifecycle_phase_error EXCEPTION;
  l_msg_index_out NUMBER;
  l_cur_wrkpln_attrs_rec      cur_wrkpln_attrs%ROWTYPE;

BEGIN

     OPEN cur_wrkpln_attrs;
     FETCH cur_wrkpln_attrs INTO l_cur_wrkpln_attrs_rec;
     IF cur_wrkpln_attrs%FOUND
     THEN
         PA_WORKPLAN_ATTR_PUB.update_proj_workplan_attrs(
               p_validate_only                 => FND_API.G_FALSE
              ,p_project_id                    => l_cur_wrkpln_attrs_rec.project_id
              ,p_proj_element_id               => p_proj_element_id
              ,p_approval_reqd_flag            => l_cur_wrkpln_attrs_rec.WP_APPROVAL_REQD_FLAG
              ,p_auto_publish_flag             => l_cur_wrkpln_attrs_rec.WP_AUTO_PUBLISH_FLAG
              ,p_approver_source_id            => l_cur_wrkpln_attrs_rec.WP_APPROVER_SOURCE_ID
              ,p_approver_source_type          => l_cur_wrkpln_attrs_rec.WP_APPROVER_SOURCE_TYPE
              ,p_default_display_lvl           => l_cur_wrkpln_attrs_rec.WP_DEFAULT_DISPLAY_LVL
              ,p_enable_wp_version_flag        => l_cur_wrkpln_attrs_rec.WP_ENABLE_VERSION_FLAG
              ,p_lifecycle_id                  => l_cur_wrkpln_attrs_rec.LIFECYCLE_VERSION_ID
              ,p_current_lifecycle_phase_id    => p_lifecycle_phase_id
              ,p_auto_pub_upon_creation_flag   => l_cur_wrkpln_attrs_rec.AUTO_PUB_UPON_CREATION_FLAG
              ,p_auto_sync_txn_date_flag       => l_cur_wrkpln_attrs_rec.AUTO_SYNC_TXN_DATE_FLAG
              ,p_txn_date_sync_buf_days        => l_cur_wrkpln_attrs_rec.TXN_DATE_SYNC_BUF_DAYS
              ,p_record_version_number         => l_cur_wrkpln_attrs_rec.RECORD_VERSION_NUMBER
              ,x_return_status                 => l_return_status
              ,x_msg_count                     => l_msg_count
              ,x_msg_data                      => l_msg_data
           );
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

     END IF;
     CLOSE cur_wrkpln_attrs;

/*  UPDATE PA_PROJ_WORKPLAN_ATTR
  SET    current_phase_version_id  = p_lifecycle_phase_id
  WHERE  proj_element_id 	   = p_proj_element_id;
*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;

EXCEPTION
   when FND_API.G_EXC_ERROR then
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS.UPDATE_CURRENT_PHASE',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
      x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_WORKPLAN_ATTR_UTILS.UPDATE_CURRENT_PHASE',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE;

END UPDATE_CURRENT_PHASE;


FUNCTION CHECK_APPROVAL_REQUIRED
(     p_project_id                    IN  NUMBER
) RETURN VARCHAR2
IS
   --Jul 23rd Only Workplan
   CURSOR get_flag IS
   select ppwa.WP_APPROVAL_REQD_FLAG
     from pa_proj_workplan_attr ppwa,
          pa_proj_elements ppe,
          pa_proj_structure_types ppst,
          pa_structure_types pst
    WHERE ppwa.project_id = p_project_id
      AND ppe.project_id = ppwa.project_id
      AND ppe.proj_element_id = ppwa.proj_element_id
      AND ppe.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id = pst.structure_type_id
      AND pst.structure_type_class_code = 'WORKPLAN';
 /*  SELECT WP_APPROVAL_REQD_FLAG
   FROM pa_proj_workplan_attr
   WHERE project_id = p_project_id;*/

   l_flag            VARCHAR2(1);
BEGIN
   OPEN get_flag;
   FETCH get_flag INTO l_flag;
   CLOSE get_flag;

   return l_flag;
END  CHECK_APPROVAL_REQUIRED;


FUNCTION CHECK_AUTO_PUB_ENABLED
(     p_project_id                    IN  NUMBER
) RETURN VARCHAR2
IS
   --Jul 23rd Only Workplan
   CURSOR get_flag IS
   select ppwa.WP_AUTO_PUBLISH_FLAG
     from pa_proj_workplan_attr ppwa,
          pa_proj_elements ppe,
          pa_proj_structure_types ppst,
          pa_structure_types pst
    WHERE ppwa.project_id = p_project_id
      AND ppe.project_id = ppwa.project_id
      AND ppe.proj_element_id = ppwa.proj_element_id
      AND ppe.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id = pst.structure_type_id
      AND pst.structure_type_class_code = 'WORKPLAN';
/*   SELECT WP_AUTO_PUBLISH_FLAG
   FROM pa_proj_workplan_attr
   WHERE project_id = p_project_id;*/

   l_flag            VARCHAR2(1);
BEGIN
   OPEN get_flag;
   FETCH get_flag INTO l_flag;
   CLOSE get_flag;

   return l_flag;
END CHECK_AUTO_PUB_ENABLED;


FUNCTION CHECK_AUTO_PUB_AT_CREATION
(     p_template_id                    IN  NUMBER
) RETURN VARCHAR2
IS
   --Jul 23rd Only Workplan
   CURSOR get_flag IS
   select ppwa.AUTO_PUB_UPON_CREATION_FLAG
     from pa_proj_workplan_attr ppwa,
          pa_proj_elements ppe,
          pa_proj_structure_types ppst,
          pa_structure_types pst
    WHERE ppwa.project_id = p_template_id
      AND ppe.project_id = ppwa.project_id
      AND ppe.proj_element_id = ppwa.proj_element_id
      AND ppe.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id = pst.structure_type_id
      AND pst.structure_type_class_code = 'WORKPLAN';
/*   SELECT AUTO_PUB_UPON_CREATION_FLAG
   FROM pa_proj_workplan_attr
   WHERE project_id = p_template_id;*/

   l_flag            VARCHAR2(1);
BEGIN
   OPEN get_flag;
   FETCH get_flag INTO l_flag;
   CLOSE get_flag;

   return l_flag;
END CHECK_AUTO_PUB_AT_CREATION;


END PA_WORKPLAN_ATTR_UTILS;

/

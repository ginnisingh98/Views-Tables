--------------------------------------------------------
--  DDL for Package Body PA_TASK_TYPE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_TYPE_UTILS" AS
/*$Header: PATTUTLB.pls 120.2 2005/08/25 03:28:25 sunkalya noship $*/

FUNCTION is_task_type_unique(p_task_type      IN  VARCHAR2,
                             p_task_type_id   IN  NUMBER := NULL) RETURN VARCHAR2
IS
  l_task_type_unique VARCHAR2(1);

  CURSOR c1 IS
  SELECT 'X'
  FROM pa_task_types
  WHERE task_type = p_task_type
  AND object_type = 'PA_TASKS'  /* bug 3279978 FP M Enhancement */
  AND ((task_type_id <> p_task_type_id AND p_task_type_id IS NOT NULL)
       OR p_task_type_id IS NULL);

BEGIN
  OPEN c1;
  FETCH c1 INTO l_task_type_unique;
  IF c1%FOUND THEN
    RETURN 'N';
  ELSE
    RETURN 'Y';
  END IF;

  CLOSE c1;

EXCEPTION
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.is_task_type_unique',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;
END is_task_type_unique;


PROCEDURE change_task_type_allowed(p_task_id IN NUMBER,
          p_from_task_type_id     IN NUMBER,
          p_to_task_type_id       IN NUMBER,
          x_change_allowed        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  CURSOR c1(p_task_type_id IN NUMBER) IS
    SELECT prog_entry_enable_flag, wq_enable_flag, percent_comp_enable_flag, remain_effort_enable_flag
    FROM pa_task_types
    WHERE task_type_id = p_task_type_id;

  CURSOR c2(p_task_type_id IN NUMBER) IS
    SELECT prog_entry_enable_flag, wq_enable_flag, percent_comp_enable_flag, remain_effort_enable_flag
    FROM pa_task_types
    WHERE task_type_id = p_task_type_id;

  v_c1 c1%ROWTYPE;
  v_c2 c2%ROWTYPE;

--hsiu: bug 2663532
  CURSOR c3(p_task_id NUMBER) IS
    select a.project_id, a.proj_element_id
      from pa_proj_element_versions a,
           pa_proj_element_versions b
     where b.proj_element_id = p_task_id
       and b.parent_structure_version_id = a.element_version_id
       and b.project_id = a.project_id;
  v_c3 c3%ROWTYPE;
--end bug 2663532

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_change_allowed := 'N';

  OPEN c1(p_from_task_type_id);
  FETCH c1 INTO v_c1;
  CLOSE c1;

  OPEN c2(p_to_task_type_id);
  FETCH c2 INTO v_c2;
  CLOSE c2;

  OPEN c3(p_task_id);
  FETCH c3 INTO v_c3;
  CLOSE c3;

  IF (PA_PROGRESS_UTILS.check_task_has_progress(p_task_id) = 'N') THEN
    IF (v_c1.prog_entry_enable_flag = 'Y' AND v_c2.prog_entry_enable_flag = 'N') AND
       ('Y' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(v_c3.project_id, v_c3.proj_element_id)
         AND 'Y' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(v_c3.project_id)) THEN
      x_change_allowed := 'N';
    ELSE
      x_change_allowed := 'Y';
    END IF;
  ELSE
    -- If the change is Y -> N, then it is NOT allowed.
    IF ((v_c1.prog_entry_enable_flag = 'Y' AND v_c2.prog_entry_enable_flag = 'N')
         AND ('Y' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(v_c3.project_id, v_c3.proj_element_id)
         AND 'Y' = PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(v_c3.project_id)))
       OR
       (v_c1.wq_enable_flag = 'Y' AND v_c2.wq_enable_flag = 'N')
       OR
       (v_c1.percent_comp_enable_flag = 'Y' AND v_c2.percent_comp_enable_flag = 'N')
       OR
       (v_c1.remain_effort_enable_flag = 'Y' AND v_c2.remain_effort_enable_flag = 'N')
    THEN
      x_change_allowed := 'N';
--added by hsiu
    ELSE
      x_change_allowed := 'Y';
--end changes
    END IF;

  END IF;

EXCEPTION
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.change_task_type_allowed',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;
END change_task_type_allowed;


PROCEDURE change_wi_allowed(p_task_id IN NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  l_msg_index_out NUMBER;
  --Bug: 4537865
  l_new_msg_data  VARCHAR2(2000);
  --Bug: 4537865
  l_change_wi_not_allowed EXCEPTION;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF PA_PROGRESS_UTILS.check_task_has_progress(p_task_id) = 'Y' THEN
    RAISE l_change_wi_not_allowed;
  END IF;

EXCEPTION
    WHEN l_change_wi_not_allowed THEN
      PA_UTILS.add_message('PA','PA_CHANGE_WI_NOT_ALLOWED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_CHANGE_WI_NOT_ALLOWED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ; -- 4537865
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.change_work_item_allowed',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;

END change_wi_allowed;


PROCEDURE change_uom_allowed(p_task_id IN NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  l_msg_index_out NUMBER;
  --Bug: 4537865
  l_new_msg_data	   VARCHAR2(2000);
  l_change_uom_not_allowed EXCEPTION;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF PA_PROGRESS_UTILS.check_task_has_progress(p_task_id) = 'Y' THEN
    RAISE l_change_uom_not_allowed;
  END IF;

EXCEPTION
    WHEN l_change_uom_not_allowed THEN
      PA_UTILS.add_message('PA','PA_CHANGE_UOM_NOT_ALLOWED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_CHANGE_UOM_NOT_ALLOWED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,	--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ; -- 4537865
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.change_uom_allowed',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;

END change_uom_allowed;


PROCEDURE check_planned_quantity(p_planned_quantity IN NUMBER,
          p_actual_work_quantity  IN  NUMBER,
          x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  l_msg_index_out NUMBER;
  --bug: 4537865
  l_new_msg_data  VARCHAR2(2000);
  --bug: 4537865
  l_planned_quantity_error EXCEPTION;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_planned_quantity < p_actual_work_quantity THEN
    RAISE l_planned_quantity_error;
  END IF;

EXCEPTION
    WHEN l_planned_quantity_error THEN
      PA_UTILS.add_message('PA','PA_PLANNED_QUANTITY_ERROR');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_PLANNED_QUANTITY_ERROR';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.change_task_type_allowed',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;

END check_planned_quantity;

 FUNCTION check_page_layout_referenced(
 p_page_id    NUMBER ) RETURN BOOLEAN
 is
  Cursor c_task_type_ref
  is
  Select 'X' from pa_task_types
  where task_progress_entry_page_id = p_page_id
  AND object_type = 'PA_TASKS';  /* bug 3279978 FP M Enhancement */

  l_dummy varchar2(1);
  l_return_value boolean := FALSE;

 Begin
   open c_task_type_ref;
   fetch c_task_type_ref into l_dummy;
   if (c_task_type_ref%FOUND) then
     l_return_value := TRUE;
   end if;
   close c_task_type_ref;

   return l_return_value;

 End check_page_layout_referenced;


PROCEDURE validate_progress_attributes(
           p_prog_entry_enable_flag        IN VARCHAR2
          ,p_prog_entry_req_flag           IN VARCHAR2
          ,p_initial_progress_status_code  IN VARCHAR2
          ,p_task_prog_entry_page_id       IN NUMBER
          ,p_wq_enable_flag                IN VARCHAR2
          ,p_work_item_code                IN VARCHAR2
          ,p_uom_code                      IN VARCHAR2
          ,p_actual_wq_entry_code          IN VARCHAR2
          ,p_percent_comp_enable_flag      IN VARCHAR2
          ,p_base_percent_comp_deriv_code  IN VARCHAR2
          ,p_task_weighting_deriv_code     IN VARCHAR2
          ,p_remain_effort_enable_flag     IN VARCHAR2
          ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  l_prog_entry_enable_invalid EXCEPTION;
  l_wq_enable_invalid  EXCEPTION;
  l_percent_comp_enable_invalid EXCEPTION;
  l_prog_entry_attr_missing EXCEPTION;
  l_wq_attr_missing EXCEPTION;
  l_percent_comp_attr_missing EXCEPTION;
  l_base_deriv_method_invalid EXCEPTION;

  l_msg_index_out NUMBER;
  -- Bug: 4537865
  l_new_msg_data  VARCHAR2(2000);
  -- Bug: 4537865

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_prog_entry_enable_flag = 'N' THEN
    IF ( p_prog_entry_req_flag            = 'Y'
       OR p_initial_progress_status_code  IS NOT NULL
       OR p_task_prog_entry_page_id       IS NOT NULL
       OR p_wq_enable_flag                = 'Y'
       OR p_work_item_code                IS NOT NULL
       OR p_uom_code                      IS NOT NULL
       OR p_actual_wq_entry_code          IS NOT NULL
       OR p_percent_comp_enable_flag      = 'Y'
       OR p_base_percent_comp_deriv_code  IS NOT NULL
       OR p_task_weighting_deriv_code     IS NOT NULL
       OR p_remain_effort_enable_flag     = 'Y'      ) THEN

      RAISE l_prog_entry_enable_invalid;

    END IF;

  ELSE

    IF p_prog_entry_enable_flag = 'Y' AND p_initial_progress_status_code IS NULL THEN

      RAISE l_prog_entry_attr_missing;

    END IF;

    IF p_wq_enable_flag = 'Y' AND (p_work_item_code IS NULL OR p_uom_code IS NULL
                                   OR p_actual_wq_entry_code IS NULL) THEN

      RAISE l_wq_attr_missing;

    END IF;

    IF p_percent_comp_enable_flag = 'Y' AND p_base_percent_comp_deriv_code IS NULL THEN

      RAISE l_percent_comp_attr_missing;

    END IF;

    -- 2621629: Added validation for base % complete derivation method.
    IF p_percent_comp_enable_flag = 'Y' AND p_wq_enable_flag = 'N' AND p_base_percent_comp_deriv_code = 'WQ_DERIVED' THEN

      RAISE l_base_deriv_method_invalid;

    END IF;

    IF p_wq_enable_flag = 'N' AND (p_work_item_code IS NOT NULL OR p_uom_code IS NOT NULL
                                   OR p_actual_wq_entry_code IS NOT NULL) THEN

      RAISE l_wq_enable_invalid;

    END IF;

    IF p_percent_comp_enable_flag = 'N' AND p_base_percent_comp_deriv_code IS NOT NULL THEN

      RAISE l_percent_comp_enable_invalid;

    END IF;

  END IF;

EXCEPTION
    WHEN l_prog_entry_enable_invalid THEN
      PA_UTILS.add_message('PA','PA_PROG_ENTRY_ENABLE_INVALID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_PROG_ENTRY_ENABLE_INVALID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

    WHEN l_prog_entry_attr_missing THEN
      PA_UTILS.add_message('PA','PA_PROG_ENTRY_ATTR_MISSING');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_PROG_ENTRY_ATTR_MISSING';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

    WHEN l_wq_enable_invalid THEN
      PA_UTILS.add_message('PA','PA_WQ_ENABLE_INVALID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_WQ_ENABLE_INVALID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
			--Bug: 4537865
			x_msg_data := l_new_msg_data;
			--Bug: 4537865
		 End if;

     WHEN l_wq_attr_missing THEN
      PA_UTILS.add_message('PA','PA_WQ_ATTR_MISSING');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_WQ_ATTR_MISSING';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

    WHEN l_percent_comp_enable_invalid THEN
      PA_UTILS.add_message('PA','PA_PERCENT_COMP_ENABLE_INVALID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_PERCENT_COMP_ENABLE_INVALID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

     WHEN l_percent_comp_attr_missing THEN
      PA_UTILS.add_message('PA','PA_PERCENT_COMP_ATTR_MISSING');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_PERCENT_COMP_ATTR_MISSING';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

    WHEN l_base_deriv_method_invalid THEN
      PA_UTILS.add_message('PA','PA_BASE_DERIV_METHOD_INVALID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_BASE_DERIV_METHOD_INVALID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		--Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
						p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		 End if;

    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_TASK_TYPE_UTILS.validate_progress_attributes',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       RAISE;

END validate_progress_attributes;

FUNCTION check_tk_type_effective(p_task_type_id IN NUMBER)
         RETURN VARCHAR2
IS
  CURSOR c1 IS
    select 'Y'
      from pa_task_types
     where task_type_id = p_task_type_id
       and sysdate > start_date_active
       and (end_date_active IS NULL or end_date_active > sysdate);
  l_dummy VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%NOTFOUND THEN
    l_dummy := 'N';
  END IF;
  CLOSE c1;
  return l_dummy;
END check_tk_type_effective;

FUNCTION check_tk_type_progressable(p_task_type_id IN NUMBER)
         RETURN VARCHAR2
IS
  CURSOR c1 IS
    select 'Y'
      from pa_task_types
     where task_type_id = p_task_type_id
       and PROG_ENTRY_ENABLE_FLAG = 'Y';
  l_dummy VARCHAR2(1);

BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%NOTFOUND THEN
    l_dummy := 'N';
  END IF;
  CLOSE c1;
  return l_dummy;
END check_tk_type_progressable;


FUNCTION check_tk_type_wq_enabled(p_task_type_id IN NUMBER)
         RETURN VARCHAR2
IS
  CURSOR c1 IS
    select 'Y'
      from pa_task_types
     where task_type_id = p_task_type_id
       and WQ_ENABLE_FLAG = 'Y';
  l_dummy VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%NOTFOUND THEN
    l_dummy := 'N';
  END IF;
  CLOSE c1;
  return l_dummy;
END check_tk_type_wq_enabled;

END pa_task_type_utils;

/

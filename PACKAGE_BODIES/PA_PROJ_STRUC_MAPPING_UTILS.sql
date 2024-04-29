--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUC_MAPPING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUC_MAPPING_UTILS" AS
/* $Header: PAPSMPUB.pls 120.6.12010000.2 2009/04/28 09:07:58 spasala ship $ */

g_module_name   VARCHAR2(100) := 'PA_PROJ_STRUC_MAPPING_UTILS';
Invalid_Arg_Exc_WP Exception;
-- Procedure            : CHECK_TASK_HAS_MAPPING
-- Type                 : Public Function
-- Purpose              : The function will check whether the mapping exists for the passed financial task_id. Returns 'Y'
--                      : if mapping exists
-- NOTE                 : This first checks whether it is shared or not.
--                      : If its not shared, we check in PA_OBJECT_RELATIONSHIPS for the passed project elem id
--                      : if any relationship exists with type 'M'.
--                      : If there is any row, 'Y' is returned else 'N' is returned
-- Assumptions          : 1. This API will return always N in case of shared structure as mapping is not
--                           possible in shared structure.
--                      : 2. Financial task has just one version always

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_project_id                 NUMBER   Yes             Task_Id for which mapping needs to be checked.
-- p_proj_element_id            NUMBER   Yes             Returns to calling program whether mapping exists for the task or not.

FUNCTION Check_Task_Has_Mapping
  (
       p_project_id             IN      NUMBER
     , p_proj_element_id        IN      NUMBER
   )
RETURN VARCHAR2
IS
l_is_fin_task                   BOOLEAN;
l_elem_version_id               NUMBER;
l_num_mapping                   VARCHAR2(1);
l_mapping_exists                VARCHAR2(1) := 'N'; -- This is the return value, if mapping exists , it is set to 'Y'
l_shared                        VARCHAR2(1) := 'N'; -- This will be set to 'Y' only if sharing is enabled

-- This cursor fetches the element version Ids for the passed element id, of the type PA_TASKS
CURSOR c_get_element_version_id
IS
SELECT element_version_id
FROM   PA_PROJ_ELEMENT_VERSIONS elver
WHERE  elver.proj_element_id = p_proj_element_id
AND elver.object_type='PA_TASKS'
AND elver.project_id = p_project_id;

-- This cursor will select 'X' if any version of FP task exists in PA_OBJECT_RELATIONSHIPS
-- for Mapping type relation and passed task ver id

CURSOR c_mapping_exists (l_elem_version_id NUMBER)
IS
SELECT 'X'
FROM DUAL
WHERE EXISTS
(    SELECT NULL
     FROM PA_OBJECT_RELATIONSHIPS
     WHERE OBJECT_ID_TO1 = l_elem_version_id
     AND relationship_type = 'M'
);

BEGIN
     l_mapping_exists := 'N';
     l_shared := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(p_project_id);

     IF l_shared = 'Y' THEN
        -- In case of sharing, no need to check for mapping as mapping is not possible
        return l_mapping_exists;
     END IF;

     -- Checking mapping exists
     -- Check whether the task id passed is Financial Task or WorkPlan Task
     -- This is done additionally so that this API can also be called for Workplan task
     IF ( p_proj_element_id IS NOT NULL AND p_project_id IS NOT NULL ) THEN
          IF (Pa_Proj_Elements_Utils.CHECK_IS_FINANCIAL_TASK(p_proj_element_id) <> 'Y') THEN
               return l_mapping_exists;
          END IF;

          OPEN  c_get_element_version_id;
          FETCH c_get_element_version_id into l_elem_version_id;
          CLOSE c_get_element_version_id;

          OPEN  c_mapping_exists (l_elem_version_id);
          FETCH c_mapping_exists into l_num_mapping;
          CLOSE c_mapping_exists;

          IF (l_num_mapping = 'X')       THEN
               l_mapping_exists := 'Y';

          ELSE
               l_mapping_exists := 'N';
          END IF;

     END IF;
return l_mapping_exists;

EXCEPTION
WHEN OTHERS THEN


     IF c_get_element_version_id%ISOPEN THEN
          CLOSE c_get_element_version_id;
     END IF;

     IF c_mapping_exists%ISOPEN THEN
          CLOSE c_mapping_exists;
     END IF;
     l_mapping_exists := NULL;
     return l_mapping_exists;

END Check_Task_Has_Mapping;

-- Procedure            : CHECK_CREATE_MAPPING_OK
-- Type                 : Public Procedure
-- Purpose              : This procedure will check whether the mapping can be created for the passed task_id

-- NOTE                 :  It first checks whether the financial task is lowest financial task or not.
--                      :  It then checks if a mapping already exists for on upper or lower ladder for the passed WP task id.

-- Assumptions          : 1. If a summary workplan task is selected then only
--                      :    the summary task will have the link to define mappings.
--                      :
--                      : 2. If a summary task is selected for mapping then neither its children nor its parent
--                      :    up in the hierarchy till root can be selected for mapping.

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_task_version_id_WP         NUMBER   Yes             Element Version ID of from WP task
-- p_task_version_id_FP         NUMBER   Yes             Element Version ID of from FP task

PROCEDURE CHECK_CREATE_MAPPING_OK

   (
       p_api_version            IN      NUMBER := 1.0
     , p_calling_module         IN      VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN      VARCHAR2 := 'N'
     , p_task_version_id_WP     IN      NUMBER
     , p_task_version_id_FP     IN      NUMBER
     , x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
     , x_error_message_code     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_dup_map                       VARCHAR2(1);


l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

-- This cursor selects all task ids in the parent ladder and lower level ladder for the passed  workplan task id.
CURSOR c_get_all_object_id
IS
SELECT object_id_to1 object_id
FROM pa_object_relationships
WHERE relationship_type ='S'
AND relationship_subtype ='TASK_TO_TASK'
START WITH object_id_from1 = p_task_version_id_WP
CONNECT BY object_id_from1 = PRIOR object_id_to1
UNION
SELECT object_id_from1 object_id
FROM pa_object_relationships
WHERE relationship_type  = 'S'
AND relationship_subtype = 'TASK_TO_TASK'
START WITH object_id_to1 = p_task_version_id_WP
CONNECT BY Object_id_to1 = PRIOR object_id_from1
UNION
SELECT p_task_version_id_WP
FROM DUAL;

--This Cursor will return 'X' if any mapping already exists for the passed workplan task id
CURSOR c_dup_mapping_exists (l_from_task_id NUMBER)
IS
SELECT 'X'
FROM dual
WHERE EXISTS
(
 SELECT NULL
 FROM PA_OBJECT_RELATIONSHIPS
 WHERE relationship_type ='M'
 AND object_id_from1 = l_from_task_id
);

BEGIN


     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CHECK_CREATE_MAPPING_OK',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_UTILS : CHECK_CREATE_MAPPING_OK : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_task_version_id_WP'||':'||p_task_version_id_WP,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_task_version_id_FP'||':'||p_task_version_id_FP,
                                     l_debug_level3);
     END IF;


     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_UTILS : CHECK_CREATE_MAPPING_OK : Validating Business rule: Financial task is lowest';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     -- Check for FP TASK to be lowest
     IF (PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_task_version_id_FP) = 'N')
     THEN
        --Raise en error and populate message
         x_error_message_code := 'PA_PS_NOT_LOWEST_FINTASK';
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          return;
     END IF;


    IF (l_debug_mode = 'Y') THEN

       Pa_Debug.g_err_stage:= 'PA_PROJ_STRUC_MAPPING_UTILS : CHECK_CREATE_MAPPING_OK : Validating Business rule: Duplicate mapping exists for WP task';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage, l_debug_level3);
    END IF;


    --This loop checks for if any mapping already exists either on upper or lower ladder for the passed WP task id
    FOR wp_rec IN c_get_all_object_id LOOP

     OPEN  c_dup_mapping_exists ( wp_rec.object_id );
     FETCH c_dup_mapping_exists INTO l_dup_map;
     CLOSE c_dup_mapping_exists;

     IF (l_dup_map = 'X')
        THEN
                 x_error_message_code := 'PA_PS_DUP_MAP_EXISTS';
                 x_return_status := FND_API.G_RET_STS_ERROR;
           EXIT;
        END IF;
    END LOOP;

   IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          return;
   END IF;

EXCEPTION
WHEN OTHERS THEN

     x_error_message_code := SQLCODE ; -- RESET OUT PARAM x_error_message_code : 4537865

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF c_get_all_object_id%ISOPEN THEN
          CLOSE c_get_all_object_id;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_STRUC_MAPPING_UTILS'
                    ,p_procedure_name  => 'CHECK_CREATE_MAPPING_OK'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END CHECK_CREATE_MAPPING_OK;

-- Procedure            : PARSE_NAMES
-- Type                 : Public Function
-- Purpose              : This function will return a pl/sql table of tokens separated by delimiter which are passed as input to this function

-- NOTE                 : This parses the input string for tokens separted by delimiter and puts each token in PL/SQL table,
--                      : which is finally returned by the function


-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_wPlan                      VARCHAR2   Yes            String to be parsed
-- p_delim                      VARCHAR2   Yes            Delimiter character or string

FUNCTION PARSE_NAMES
   (
      p_wPlan                 IN   VARCHAR2
    , p_delim                 IN   VARCHAR2

   ) RETURN  PA_PROJ_STRUC_MAPPING_UTILS.TASK_NAME_TABLE_TYPE
IS

l_workplan_name_table_type           PA_PROJ_STRUC_MAPPING_UTILS.TASK_NAME_TABLE_TYPE;
l_str_length             NUMBER;
l_start_pos              NUMBER := 1;
l_curr_pos               NUMBER;
l_counter                NUMBER := 0;

BEGIN
     IF  ( p_wPlan  IS NOT NULL AND p_delim  IS NOT NULL )
     THEN
          --Get the length of string
          l_str_length := LENGTH ( p_wPlan );

          LOOP
               -- get the first postion of delimiter character
               l_curr_pos := INSTR(p_wPlan,p_delim,l_start_pos);

               IF l_curr_pos = 0
               THEN
                    --This is to get last token
                    l_workplan_name_table_type(l_counter):= SUBSTR( p_wPlan,l_start_pos);

                    l_counter := l_counter + 1;
               ELSE
                    --This is to get other tokens
                    l_workplan_name_table_type(l_counter) := SUBSTR( p_wPlan,l_start_pos,l_curr_pos - l_start_pos);
                    l_counter := l_counter + 1;
               END IF;

               IF l_curr_pos = 0
               THEN
                    EXIT;
               ELSE
                    l_start_pos := l_curr_pos + 1;
               END IF;
          END LOOP;

     ELSE
          RAISE Invalid_Arg_Exc_WP;

     END IF;
return l_workplan_name_table_type;

EXCEPTION

WHEN Invalid_Arg_Exc_WP THEN
return l_workplan_name_table_type;

WHEN OTHERS THEN
return l_workplan_name_table_type;

END PARSE_NAMES;

-- Procedure            : GET_TASK_NAME_FROM_VERSION
-- Type                 : Public Function
-- Purpose              : To get the task name of given task version id

-- NOTE                 :


-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
--   p_task_version_id            NUMBER   Yes             task version id of the task whose name is to be found

FUNCTION GET_TASK_NAME_FROM_VERSION
   ( p_task_version_id    IN   NUMBER
   ) RETURN  VARCHAR2
IS

l_task_name pa_proj_elements.name%TYPE;

CURSOR c_get_task_name IS
SELECT projelem.name
FROM pa_proj_elements projelem
   , pa_proj_element_versions elemver
WHERE elemver.element_version_id = p_task_version_id
AND elemver.proj_element_id = projelem.proj_element_id
AND elemver.object_type = 'PA_TASKS'
AND projelem.object_type = 'PA_TASKS'
AND elemver.project_id = projelem.project_id;

BEGIN

-- Bug Fix 5611948.
-- The cursor is uncoditionally getting executed even when the passed in value is null.
-- This is causing numerous executions especially during the temp table population where
-- this is getting called. It is very much possible that the mapped task id is null.
-- In order to avoid the numerous executions we can make code change at the calling point to
-- see if the id is null. if null we dont call this. another approach is to make the change
-- in the core so if more than one calling point is there then we can minimize the code changes
-- as this will return null if the passed in id is null.

IF p_task_version_id IS NULL THEN

 l_task_name := NULL;
 return l_task_name;

END IF;


OPEN c_get_task_name;
FETCH c_get_task_name INTO l_task_name;
CLOSE c_get_task_name;

return l_task_name;

EXCEPTION
WHEN OTHERS THEN
     l_task_name := null;
     return l_task_name;
END GET_TASK_NAME_FROM_VERSION;

FUNCTION GET_MAPPED_FIN_TASK_VERSION_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER
IS
   cursor C1 (evid number) is
   select object_id_from1,object_id_to1
   from pa_object_relationships
   where relationship_type='S'
   and object_type_to='PA_TASKS'
   connect by prior object_id_from1 = object_id_to1
   and prior relationship_type = relationship_type -- Bug # 4621730.
   start with object_id_to1 = C1.evid;

   l_mapped_fin_task_version_id NUMBER;
   l_proj_element_id NUMBER;
   l_c1rec C1%ROWTYPE;
BEGIN
   l_mapped_fin_task_version_id := NULL;
   if (p_structure_sharing_code = 'SPLIT_MAPPING') then
      for l_c1rec in C1(p_element_version_id)
         LOOP
           BEGIN -- Added exception block for Bug# 6411931
            select object_id_to1 into l_mapped_fin_task_version_id
            from pa_object_relationships
            where relationship_type='M'
            and object_type_from='PA_TASKS'
            and object_type_to='PA_TASKS'
            and object_id_from1 = l_c1rec.object_id_to1;
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
             null;
           END;

            if l_mapped_fin_task_version_id IS NOT NULL then
          EXIT;
         end if;
         END LOOP;
   elsif (p_structure_sharing_code = 'SHARE_PARTIAL') then
      for l_c1rec in C1(p_element_version_id)
         LOOP
         select proj_element_id into l_proj_element_id
            from pa_proj_element_versions
         where element_version_id = l_c1rec.object_id_to1;
            if (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_proj_element_id) = 'Y') then
               l_mapped_fin_task_version_id := l_c1rec.object_id_to1;
         end if;
            if l_mapped_fin_task_version_id IS NOT NULL then
          EXIT;
         end if;
         END LOOP;
   end if;
   return (l_mapped_fin_task_version_id);
EXCEPTION
WHEN OTHERS THEN
     l_mapped_fin_task_version_id := NULL;
     return l_mapped_fin_task_version_id;
END GET_MAPPED_FIN_TASK_VERSION_ID;


FUNCTION GET_MAPPED_FIN_TASK_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER
IS
   l_mapped_fin_task_version_id NUMBER;
   l_mapped_fin_task_id NUMBER;
BEGIN
   l_mapped_fin_task_version_id :=  GET_MAPPED_FIN_TASK_VERSION_ID(p_element_version_id,p_structure_sharing_code);
   select proj_element_id into l_mapped_fin_task_id
   from pa_proj_element_versions
   where element_version_id = l_mapped_fin_task_version_id;
   return (l_mapped_fin_task_id);
EXCEPTION
WHEN OTHERS THEN
     l_mapped_fin_task_id := NULL;
     return l_mapped_fin_task_id;
END GET_MAPPED_FIN_TASK_ID;


FUNCTION GET_MAPPED_FIN_TASK_NAME
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN VARCHAR2
IS
   l_mapped_fin_task_version_id NUMBER;
   l_mapped_fin_task_name pa_proj_elements.name%TYPE; --Bug8443049:BIG WORDS DO NOT APPEAR IN THE FIELD FINANCIAL TASK MAPPED IN WBS
BEGIN
   l_mapped_fin_task_version_id :=  GET_MAPPED_FIN_TASK_VERSION_ID(p_element_version_id,p_structure_sharing_code);
   l_mapped_fin_task_name := GET_TASK_NAME_FROM_VERSION(l_mapped_fin_task_version_id);
   return (l_mapped_fin_task_name);
EXCEPTION
WHEN OTHERS THEN
     l_mapped_fin_task_name := NULL;
     return l_mapped_fin_task_name;
END GET_MAPPED_FIN_TASK_NAME;

FUNCTION GET_MAPPED_STRUCT_VER_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER
IS
   l_mapped_fin_task_version_id NUMBER;
   l_mapped_structure_version_id NUMBER;
BEGIN
   l_mapped_fin_task_version_id :=  GET_MAPPED_FIN_TASK_VERSION_ID(p_element_version_id,p_structure_sharing_code);
   select parent_structure_version_id into l_mapped_structure_version_id
   from pa_proj_element_versions
   where element_version_id = l_mapped_fin_task_version_id;
   return (l_mapped_structure_version_id);
EXCEPTION
WHEN OTHERS THEN
     l_mapped_structure_version_id := NULL;
     return l_mapped_structure_version_id;
END GET_MAPPED_STRUCT_VER_ID;

--Added by rtarway to get mapped wkp task names
FUNCTION GET_MAPPED_WKP_TASK_NAMES
   (
     p_mapped_fin_task_version_id IN NUMBER
     ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2
IS
CURSOR C_get_mapped_wkp_task_names IS
select ppe.name
from
     pa_proj_elements ppe,
     pa_proj_element_versions ppev,
     pa_object_relationships por_mapping
where
     ppe.proj_element_id=ppev.proj_element_id
and
     ppe.project_id = ppev.project_id
and
     ppev.project_id = p_project_id
and
     ppev.element_version_id = por_mapping.object_id_from1
and
     por_mapping.object_id_to1 = p_mapped_fin_task_version_id
and
     por_mapping.relationship_type = 'M';

l_mapped_wkp_task_names  VARCHAR2(10000);

BEGIN
     l_mapped_wkp_task_names := '';
for l_rec in C_get_mapped_wkp_task_names loop

l_mapped_wkp_task_names := l_mapped_wkp_task_names||l_rec.name||',';

end loop;

--strip last comma
l_mapped_wkp_task_names := rtrim(l_mapped_wkp_task_names, ',');

return l_mapped_wkp_task_names;

EXCEPTION
WHEN OTHERS THEN
    l_mapped_wkp_task_names := NULL;
     return l_mapped_wkp_task_names;
END GET_MAPPED_WKP_TASK_NAMES;


--Added by rtarway to get mapped wkp task ids
FUNCTION GET_MAPPED_WKP_TASK_IDS
   (
     p_mapped_fin_task_version_id IN NUMBER
     ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2
IS
CURSOR C_get_mapped_wkp_task_Ids IS
select ppe.proj_element_id
from
     pa_proj_elements ppe,
     pa_proj_element_versions ppev,
     pa_object_relationships por_mapping
where
     ppe.proj_element_id=ppev.proj_element_id
and
     ppe.project_id = ppev.project_id
and
     ppev.project_id = p_project_id
and
     ppev.element_version_id = por_mapping.object_id_from1
and
     por_mapping.object_id_to1 = p_mapped_fin_task_version_id
and
     por_mapping.relationship_type = 'M';

l_mapped_wkp_task_ids  VARCHAR2(10000);

BEGIN
     l_mapped_wkp_task_ids := '';
for l_rec in C_get_mapped_wkp_task_Ids loop

l_mapped_wkp_task_ids := l_mapped_wkp_task_ids||l_rec.proj_element_id||',';

end loop;

--strip last comma
l_mapped_wkp_task_ids := rtrim(l_mapped_wkp_task_ids, ',');

return l_mapped_wkp_task_ids;

EXCEPTION
WHEN OTHERS THEN
    l_mapped_wkp_task_ids := NULL;
     return l_mapped_wkp_task_ids;
END GET_MAPPED_WKP_TASK_IDS;

--Added by rtarway to get mapped wkp task ids
FUNCTION GET_MAPPED_FIN_TASK_ID_AMG
   (
     p_mapped_wkp_task_version_id IN NUMBER
     ,p_project_id  IN NUMBER
   ) RETURN NUMBER
IS
CURSOR C_get_mapped_fin_task_Id IS
select ppe.proj_element_id
from
     pa_proj_elements ppe,
     pa_proj_element_versions ppev,
     pa_object_relationships por_mapping
where
     ppe.proj_element_id=ppev.proj_element_id
and
     ppe.project_id = ppev.project_id
and
     ppev.project_id = p_project_id
and
     ppev.element_version_id = por_mapping.object_id_to1
and
     por_mapping.object_id_from1 = p_mapped_wkp_task_version_id
and
     por_mapping.relationship_type = 'M';

l_mapped_fin_task_id  NUMBER;

BEGIN
     l_mapped_fin_task_id := NULL;

OPEN  C_get_mapped_fin_task_Id;
FETCH C_get_mapped_fin_task_Id INTO l_mapped_fin_task_id;
CLOSE C_get_mapped_fin_task_Id;

return l_mapped_fin_task_id;

EXCEPTION
WHEN OTHERS THEN
    l_mapped_fin_task_id := NULL;
     return l_mapped_fin_task_id;
END GET_MAPPED_FIN_TASK_ID_AMG;

--Added by rtarway to get mapped wkp task ids
FUNCTION GET_MAPPED_FIN_TASK_NAME_AMG
   (
     p_mapped_wkp_task_version_id IN NUMBER
     ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2
IS
CURSOR C_get_mapped_fin_task_name IS
select ppe.name
from
     pa_proj_elements ppe,
     pa_proj_element_versions ppev,
     pa_object_relationships por_mapping
where
     ppe.proj_element_id=ppev.proj_element_id
and
     ppe.project_id = ppev.project_id
and
     ppev.project_id = p_project_id
and
     ppev.element_version_id = por_mapping.object_id_to1
and
     por_mapping.object_id_from1 = p_mapped_wkp_task_version_id
and
     por_mapping.relationship_type = 'M';

l_mapped_fin_task_name VARCHAR2(240);

BEGIN
     l_mapped_fin_task_name := NULL;
OPEN  C_get_mapped_fin_task_name;
FETCH C_get_mapped_fin_task_name INTO l_mapped_fin_task_name;
CLOSE C_get_mapped_fin_task_name;

return l_mapped_fin_task_name;

EXCEPTION
WHEN OTHERS THEN
    l_mapped_fin_task_name := NULL;
     return l_mapped_fin_task_name;
END GET_MAPPED_FIN_TASK_NAME_AMG;

END PA_PROJ_STRUC_MAPPING_UTILS;

/

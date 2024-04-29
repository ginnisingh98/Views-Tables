--------------------------------------------------------
--  DDL for Package Body OKE_PA_CHECKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PA_CHECKS_PUB" AS
/* $Header: OKEPPACB.pls 120.2 2007/12/20 07:52:52 neerakum ship $ */

--G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OKE_PA_CHECKS_PUB';
g_api_type		CONSTANT VARCHAR2(4) := '_PUB';

--
--  Name          : Project_Used
--  Function      : This function checks if a certain project is used by OKE
--
--  Parameters    :
--  IN            : Project_ID NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2     ( 'Y'  'N' )
--


PROCEDURE Project_Used
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  Project_ID 		    IN	  NUMBER
,  X_Result		    OUT   NOCOPY VARCHAR2
) IS
l_project_id NUMBER:=Project_ID;

CURSOR c_used IS
  SELECT 'Y' FROM (
    SELECT project_id FROM oke_k_headers
    UNION ALL
    SELECT project_id FROM oke_k_lines
    UNION ALL
    SELECT project_id FROM oke_k_fund_allocations
    UNION ALL
    SELECT project_id FROM oke_k_deliverables_b
    UNION ALL
    SELECT bill_project_id FROM oke_k_billing_events
  ) WHERE project_id=l_project_id;


BEGIN

  X_Result:='N';
  OPEN c_used;
  FETCH c_used INTO X_Result;
  CLOSE c_used;

END Project_Used;



--
--  Name          : Task_Used
--  Function      : This function checks if a certain task is used by OKE
--
--  Parameters    :
--  IN            : Task_ID	NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2     ( 'Y'  'N' )
--

PROCEDURE Task_Used
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  Task_ID 		    IN	  NUMBER
,  X_Result		    OUT   NOCOPY VARCHAR2
) IS

l_task_id NUMBER:=Task_ID;

  CURSOR c_used IS
    SELECT 'Y' FROM (
    SELECT task_id FROM oke_k_lines
    UNION ALL
    SELECT task_id FROM oke_k_fund_allocations
    UNION ALL
    SELECT task_id FROM oke_k_deliverables_b
    UNION ALL
    SELECT bill_task_id FROM oke_k_billing_events
  ) WHERE task_id=l_task_id;

BEGIN

  X_Result:='N';
  OPEN c_used;
  FETCH c_used INTO X_Result;
  CLOSE c_used;

END Task_Used;

PROCEDURE Get_Parent_Proj_Task (
   p_head_id 		    IN	  NUMBER
,  p_line_id 		    IN	  NUMBER
,  p_proj_id		    OUT   NOCOPY NUMBER
,  p_task_id		    OUT   NOCOPY NUMBER
) IS

 CURSOR c_plines IS
  SELECT PROJECT_ID, TASK_ID
  FROM OKE_K_LINES E, OKC_ANCESTRYS A
  WHERE K_LINE_ID = CLE_ID_ASCENDANT AND CLE_ID = P_LINE_ID AND PROJECT_ID IS NOT NULL
  ORDER BY LEVEL_SEQUENCE desc
 ;
 CURSOR c_line(cp_line_id NUMBER) IS
  SELECT PROJECT_ID, TASK_ID, parent_line_id
  FROM OKE_K_LINES
  WHERE K_LINE_ID = CP_LINE_ID AND PROJECT_ID IS NOT NULL
 ;
 CURSOR c_head IS
   SELECT PROJECT_ID FROM oke_k_headers WHERE k_header_id = p_head_id
 ;
 l_line_id NUMBER := p_line_id;

BEGIN

  p_proj_id:=NULL;
  p_task_id:=NULL;
  WHILE (l_line_id IS NOT NULL AND p_proj_id IS NULL) LOOP
    OPEN c_line(l_line_id);
    FETCH c_line INTO p_proj_id,p_task_id,l_line_id;
    CLOSE c_line;
  END LOOP;

  IF (p_proj_id IS NULL) THEN
    OPEN c_head;
    FETCH c_head INTO p_proj_id;
    CLOSE c_head;
  END IF;

END Get_Parent_Proj_Task;

--
--  Name          : is_Hierarchy_Valid
--  Function      : This function checks if there is a valid project hierarchy
--   from (p_from_proj,p_from_task) to p_to_proj
--   avoiding direct link from p_delf_proj+p_delf_task to p_delt_proj
--
--  IN Parameters    :
--			p_from_proj		NUMBER
--			p_from_task		NUMBER
--			p_to_proj		NUMBER
--			p_delf_proj		NUMBER  from-project to delete
--			p_delf_task		NUMBER  from-task to delete
--			p_delt_proj		NUMBER  to-project to delete
--  Returns       : BOOLEAN
FUNCTION is_Hierarchy_Valid( p_from_proj NUMBER, p_from_task NUMBER, p_to_proj NUMBER,
 p_delf_proj NUMBER, p_delf_task NUMBER, p_delt_proj NUMBER)
 RETURN BOOLEAN IS
  CURSOR check_prj_hier IS
    SELECT 'x' FROM dual
     WHERE p_to_proj IN (
      SELECT object_id_to1 prj_id FROM (
        SELECT *
        FROM  pa_object_relationships
        WHERE NOT (object_id_from2=p_delf_proj AND object_id_from1=p_delf_task AND object_id_to1=p_delt_proj)
        )
        WHERE object_type_from   = 'PA_TASKS'
          AND object_type_to     = 'PA_PROJECTS'
          AND relationship_type  = 'H'
        START WITH (object_id_from2, object_id_from1)
                IN (SELECT p_from_proj, task_id FROM pa_tasks
                     WHERE project_id = p_from_proj
                       AND top_task_id = nvl(p_from_task, top_task_id))
        CONNECT BY object_id_from2 = PRIOR object_id_to1
      UNION ALL
      SELECT object_id_to2 prj_id FROM (
        SELECT *
        FROM  pa_object_relationships p
        WHERE NOT (object_id_to2=p_delt_proj AND object_type_from = 'PA_TASKS'
                  AND object_id_from1 IN (SELECT ppev.element_version_id
                  FROM pa_tasks pt, pa_proj_element_versions ppev, pa_proj_elem_ver_structure ppevs
                  WHERE ppev.proj_element_id = pt.task_id
                   AND pt.top_task_id = nvl(p_delf_task, pt.top_task_id)
                   AND pt.task_id = pt.top_task_id
                   AND pt.project_id = p_delf_proj
                   AND ppev.project_id = ppevs.project_id
                   AND ppev.parent_structure_version_id = ppevs.element_version_id
                   AND ppevs.status_code = 'STRUCTURE_PUBLISHED'
                   AND ppevs.latest_eff_published_flag = 'Y'  ))
        )
        START WITH object_type_from = 'PA_TASKS' AND object_id_from1
            IN (SELECT ppev.element_version_id
                  FROM pa_tasks pt, pa_proj_element_versions ppev, pa_proj_elem_ver_structure ppevs
                  WHERE ppev.proj_element_id = pt.task_id
                   AND pt.top_task_id = nvl(p_from_task, pt.top_task_id)
                   AND pt.task_id = pt.top_task_id
                   AND pt.project_id = p_from_proj
                   AND ppev.project_id = ppevs.project_id
                   AND ppev.parent_structure_version_id = ppevs.element_version_id
                   AND ppevs.status_code = 'STRUCTURE_PUBLISHED'
                   AND ppevs.latest_eff_published_flag = 'Y'  )
      CONNECT BY object_id_from1 = PRIOR object_id_to1 AND relationship_type IN ('S','LF')
     )
  ;
  l_result VARCHAR2(1):='?';
 BEGIN
  IF p_from_proj=p_delf_proj AND p_from_task=p_delf_task AND p_to_proj=p_delt_proj THEN
    RETURN FALSE;
   ELSE
    IF p_from_proj=p_to_proj THEN
      RETURN TRUE;
     ELSE
      -- check hierarchy
      OPEN check_prj_hier;
      FETCH check_prj_hier INTO l_result;
      CLOSE check_prj_hier;
      RETURN l_result='x';
    END IF;
  END IF;
END is_Hierarchy_Valid;


--
--  Name          : Disassociation_Allowed
--  Function      : This function checks if a certain project(To_Project_ID)
--			can be disassociatied from
--			a task(From_Project_ID,From_Task_ID)
--
--  Parameters    :
--  IN            : 	From_Project_ID		NUMBER
--			From_Task_ID		NUMBER
--			To_Project_ID		NUMBER
--  OUT           : None
--
--  Returns       : VARCHAR2     ( 'Y'  'N' )
--


PROCEDURE Disassociation_Allowed
(  p_api_version		IN	NUMBER
,  p_commit			IN	VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE
,  x_msg_count			OUT	NOCOPY NUMBER
,  x_msg_data			OUT	NOCOPY VARCHAR2
,  x_return_status		OUT	NOCOPY VARCHAR2
,  From_Project_ID		IN	NUMBER
,  From_Task_ID			IN	NUMBER
,  To_Project_ID		IN	NUMBER
,  X_Result			OUT 	NOCOPY VARCHAR2
) IS


CURSOR used_refs(p_project_ID NUMBER) IS
  SELECT header_id, line_id, project_id FROM (
    SELECT dnz_chr_id header_id, c.cle_id line_id, project_id
     FROM oke_k_lines e, okc_k_lines_b c
     WHERE e.k_line_id=c.id
    UNION ALL
    SELECT object_id header_id, k_line_id, project_id FROM oke_k_fund_allocations
    UNION ALL
    SELECT k_header_id header_id, k_line_id, project_id FROM oke_k_deliverables_b
    UNION ALL
    SELECT k_header_id header_id, NULL, bill_project_id FROM oke_k_billing_events
  ) WHERE project_id IN (
    	SELECT to_number(object_id_to1) project_id
  	FROM   pa_object_relationships
  	WHERE  object_type_from   = 'PA_TASKS'
          AND    object_type_to     = 'PA_PROJECTS'
  	AND    relationship_type  = 'H'
  	START WITH object_id_from2 = p_project_ID
  	CONNECT BY object_id_from2 = PRIOR object_id_to1
       UNION ALL
       SELECT TO_NUMBER(OBJECT_ID_TO2) PROJECT_ID
       FROM   PA_OBJECT_RELATIONSHIPS p
        START WITH OBJECT_TYPE_FROM = 'PA_STRUCTURES' AND object_id_from1 IN
        (SELECT element_version_id
            FROM pa_proj_elem_ver_structure ppevs
             WHERE ppevs.project_id=p_project_ID
               AND status_code = 'STRUCTURE_PUBLISHED'
               AND ppevs.latest_eff_published_flag = 'Y')
            CONNECT BY object_id_from1 = PRIOR object_id_to1
             AND relationship_type IN('S','LF')
       UNION ALL
    SELECT p_project_ID FROM DUAL
  ) ORDER BY project_id, line_id
;

  lp_proj  	NUMBER;
  lp_task  	NUMBER;
  l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_result 	VARCHAR2(1) := 'Y';

  l_api_name	CONSTANT VARCHAR2(30) 	:= 'DISASSOCIATION_ALLOWED';
  l_api_version	NUMBER 			:= 1.0;

 BEGIN

    l_return_status := OKE_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => l_return_status);

    -- check if activity started successfully
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
       RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    -- initialize return status
    x_return_status := OKE_API.G_RET_STS_SUCCESS;

  -- get parent header/lines for all objects where subhierarchy of To_Project_ID is used
  -- i.e. building a list of restricting objects
	FOR c IN used_refs(To_Project_ID) LOOP
    -- get parent Proj/Task
 	  Get_Parent_Proj_Task( c.header_id, c.line_id, lp_proj, lp_task );

 	  -- verify if exist a hierarchy bw lp_proj+lp_task and c.project_id w/o from_project_ID+from_task_ID
 	  IF NOT is_Hierarchy_Valid( lp_proj, lp_task, c.project_id,
                       from_project_ID, from_task_ID, To_Project_ID)
     THEN
 	    -- if not - skip rest
	    l_result := 'N';
	    EXIT;
    END IF;
	END LOOP;

  X_Result := l_result;

  OKE_API.END_ACTIVITY(	x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKE_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Disassociation_Allowed;





END OKE_PA_CHECKS_PUB;

/

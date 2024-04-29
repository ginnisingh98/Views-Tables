--------------------------------------------------------
--  DDL for Package Body PA_ROLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_UTILS" AS
-- $Header: PARLUTLB.pls 120.2 2006/09/26 00:06:53 rfadia noship $

--
--  PROCEDURE
--              Check_Role_Name_Or_Id
--  PURPOSE
--              This procedure does the following
--              If role name is passed converts it to the id
--		If id is passed, based on the check_id_flag validates it
--  HISTORY
--   23-JUN-2000      R. Krishnamurthy       Created
--

---Procedure Check_Role_Name_Or_Id
------------------------------------------------------
procedure Check_Role_Name_Or_Id
      ( p_role_id         IN pa_project_role_types.project_role_id%TYPE
       ,p_role_name       IN pa_project_role_types.meaning%TYPE
       ,p_check_id_flag   IN VARCHAR2 := 'A'
       ,x_role_id        OUT NOCOPY pa_project_role_types.project_role_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

	CURSOR c_ids IS
                  SELECT project_role_id
                  FROM pa_project_role_types_vl
                  WHERE meaning = p_role_name;
	l_current_id NUMBER := NULL;
	l_num_ids NUMBER:= 0;
	l_id_found_flag VARCHAR(1) := 'N';

BEGIN
    pa_debug.init_err_stack ('pa_role_utils.Check_Role_Name_Or_Id');
        IF p_role_id IS NOT NULL AND p_role_id <> FND_API.G_MISS_NUM THEN
	 IF p_check_id_flag = 'Y' THEN
           SELECT project_role_id
           INTO   x_role_id
           FROM   pa_project_role_types_b /* Bug#2788815-Changed pa_project_role_types_vl to
                                                          pa_project_role_types_b */
           WHERE  project_role_id = p_role_id
           AND TRUNC(SYSDATE) BETWEEN
           start_date_active AND
           NVL(end_date_active,TRUNC(SYSDATE));
	 ELSIF (p_check_id_flag = 'N') then
	    x_role_id := p_role_id;
	 ELSIF (p_check_id_flag = 'A') THEN
	    IF p_role_name IS NULL THEN
	       -- return a null since since the name is null
	       x_role_id := NULL;
	    ELSE
	       -- fine the ID which matches the name
	       OPEN c_ids;
	       LOOP
		  FETCH c_ids INTO l_current_id;
		  EXIT WHEN c_ids%notfound;
		  IF (l_current_id = p_role_id) THEN
		     l_id_found_flag := 'Y';
		     x_role_id := p_role_id;
		  END IF;
	       END LOOP;
	       l_num_ids := c_ids%rowcount;
	       CLOSE c_ids;

	       IF l_num_ids = 0 THEN
		  -- No IDS for the name
		  RAISE no_data_found;
	       ELSIF(l_num_ids = 1) THEN
		  -- there is only one
		  x_role_id := l_current_id;
	       ELSIF (l_id_found_flag = 'N') THEN
		  -- more than one ID found for the name
		  RAISE too_many_rows;
	       END IF;
	    END IF;
	 END IF;
	 ELSE
	    IF (p_role_name IS NOT NULL) then
	      SELECT project_role_id
	      INTO   x_role_id
	      FROM   pa_project_role_types_vl
	      WHERE  meaning = p_role_name
	      AND TRUNC(SYSDATE) BETWEEN
	      start_date_active AND
	      NVL(end_date_active,TRUNC(SYSDATE));
	    ELSE
	       x_role_id := NULL;

	    END IF;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
        pa_debug.reset_err_stack;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
      x_role_id := null;
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_INVALID_AMBIGOUS';

	WHEN TOO_MANY_ROWS THEN
      x_role_id := null;
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_INVALID_AMBIGOUS';
        WHEN OTHERS THEN
              x_role_id := null;
          fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  	 RAISE;
END Check_Role_Name_Or_Id;

procedure Check_Role_RoleList
      ( p_role_id         IN pa_project_role_types.project_role_id%TYPE
       ,p_role_name       IN pa_project_role_types.meaning%TYPE
       ,p_role_list_id    IN pa_role_lists.role_list_id%TYPE := NULL
       ,p_role_list_name  IN pa_role_lists.name%TYPE := null
       ,p_check_id_flag   IN VARCHAR2
       ,x_role_id        OUT NOCOPY pa_project_role_types.project_role_id%TYPE --File.Sql.39 bug 4440895
       ,x_role_list_id   OUT NOCOPY pa_role_lists.role_list_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

       l_status VARCHAR2(10) ;
       l_sysdate DATE := TRUNC(sysdate);
BEGIN
   pa_debug.init_err_stack ('pa_role_utils.Check_Role_RoleList');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
        IF p_role_id IS NOT NULL AND p_role_id <> FND_API.G_MISS_NUM THEN
	 IF p_check_id_flag = 'Y' THEN
           SELECT project_role_id
           INTO   x_role_id
           FROM   pa_project_role_types_b /* Bug#2788815-Changed pa_project_role_types_vl to
                                                      pa_project_role_types_b */
           WHERE  project_role_id = p_role_id
           AND TRUNC(SYSDATE) BETWEEN
           start_date_active AND
           NVL(end_date_active,TRUNC(SYSDATE));
	 ELSE
	    x_role_id := p_role_id;
	 END IF;
        ELSE
           SELECT project_role_id
           INTO   x_role_id
           FROM   pa_project_role_types_vl
           WHERE  meaning = p_role_name
           AND TRUNC(SYSDATE) BETWEEN
           start_date_active AND
           NVL(end_date_active,TRUNC(SYSDATE));
	END IF;


   EXCEPTION
	WHEN NO_DATA_FOUND THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_INVALID_AMBIGOUS';

	WHEN TOO_MANY_ROWS THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_INVALID_AMBIGOUS';

        WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  	 RAISE;
   END;

   -- if it alread fails, then we return.
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   -- the role_list_id and role_list_name are not passed in
   -- we will return here too
   IF p_role_list_id IS NULL and p_role_list_name IS NULL then
      RETURN;
   END IF;


   BEGIN
    IF p_role_list_id IS NOT NULL AND p_role_list_id <> FND_API.G_MISS_NUM THEN
       IF p_check_id_flag <> 'N' THEN
	  SELECT role_list_id
	    INTO x_role_list_id
	    FROM pa_role_lists
	    WHERE role_list_id = p_role_list_id
	    AND TRUNC(start_date_active) <= l_sysdate
	    AND (end_date_active IS NULL OR l_sysdate <= TRUNC(end_date_active));
	ELSE
	  x_role_list_id := p_role_list_id;
       END IF;
     ELSE
       SELECT role_list_id
	 INTO x_role_list_id
	 FROM pa_role_lists
	 WHERE name = p_role_list_name
	 AND TRUNC(start_date_active) <= l_sysdate
	 AND (end_date_active IS NULL OR l_sysdate <= TRUNC(end_date_active));
    END IF;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 x_error_message_code := 'PA_ROLE_LIST_INVALID_AMBIGOUS';

      WHEN TOO_MANY_ROWS THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 x_error_message_code := 'PA_ROLE_LIST_INVALID_AMBIGOUS';

      WHEN OTHERS THEN
	 fnd_msg_pub.add_exc_msg
	   (p_pkg_name => 'PA_ROLE_LIST_UTILS',
	    p_procedure_name => pa_debug.g_err_stack );
	 x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	 RAISE;

   END;


   -- if it alread fails, then we return.
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- we need to validate that the role actually belongs to the role_type
   SELECT 'Y' INTO l_status
     FROM dual
     WHERE exists
     (
      SELECT role_list_id FROM pa_role_list_members
      WHERE role_list_id = x_role_list_id
      AND project_role_id = x_role_id
      );

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_error_message_code := NULL;
   pa_debug.reset_err_stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_NOT_IN_ROLELIST';
   WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ROLE_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE;

END Check_Role_RoleList;

--
--  PROCEDURE
--              get_role_defaults
--  PURPOSE
--		This procedure returns the defaults for a role
--
--  HISTORY
PROCEDURE Get_Role_Defaults
(p_role_id                IN pa_project_role_types.project_role_id%TYPE
,x_meaning                OUT  NOCOPY pa_project_role_types.meaning%TYPE --File.Sql.39 bug 4440895
,x_default_min_job_level OUT NOCOPY pa_project_role_types.default_min_job_level%TYPE --File.Sql.39 bug 4440895
,x_default_max_job_level  OUT NOCOPY pa_project_role_types.default_max_job_level%TYPE --File.Sql.39 bug 4440895
,x_menu_id                OUT NOCOPY pa_project_role_types.menu_id%TYPE --File.Sql.39 bug 4440895
,x_schedulable_flag       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_default_job_id         OUT NOCOPY pa_project_role_types.default_job_id%TYPE --File.Sql.39 bug 4440895
,x_def_competencies	 OUT  NOCOPY pa_hr_competence_utils.competency_tbl_typ --File.Sql.39 bug 4440895
,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_error_message_code     OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_num		 NUMBER;
l_return_status  VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_competency_tbl  pa_hr_competence_utils.competency_tbl_typ;
CURSOR l_role_csr IS
SELECT meaning,
       default_min_job_level,
       default_max_job_level,
       menu_id,
       default_job_id
FROM   pa_project_role_types_vl
WHERE  project_role_id = p_role_id ;
BEGIN
    pa_debug.init_err_stack ('pa_role_utils.get_role_defaults');
    OPEN l_role_csr;
    FETCH l_role_csr INTO
          x_meaning,
	  x_default_min_job_level,
          x_default_max_job_level,
          x_menu_id,
          x_default_job_id ;
    IF l_role_csr%NOTFOUND THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_INVALID_AMBIGOUS';
          CLOSE l_role_csr;
          pa_debug.reset_err_stack;
          RETURN;
    END IF;
    CLOSE l_role_csr;
  -- Get the info on whether the role is schedulable here
     x_schedulable_flag := get_schedulable_flag(p_role_id);
  -- Get the default competencies for the role
    pa_hr_competence_utils.get_competencies
   ( p_object_name	    => 'PROJECT_ROLE'
    ,p_object_id	    =>  p_role_id
    ,x_competency_tbl	    => l_competency_tbl
    ,x_no_of_competencies   => l_num
    ,x_error_message_code   => l_error_message_code
    ,x_return_status        => l_return_status );
   -- It is possible the the role does not have competencies
   -- It is ok to have no competencies;hence we will not raise errors
   -- if l_num = 0;
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_error_message_code := l_error_message_code;
       x_return_status := l_return_status;
       pa_debug.reset_err_stack;
       RETURN ;
    END IF ;
    x_def_competencies := l_competency_tbl;
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ROLE_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Get_Role_Defaults;


--  PROCEDURE
--              Validate_Role_Competencies
--  PURPOSE
--	This procedure validates the competencies for a given role
--
--  HISTORY
PROCEDURE Validate_Role_Competency
	     (p_competence_id   IN per_competences.competence_id%TYPE
	     ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
l_business_group_id NUMBER := 0;

CURSOR l_get_bg_csr IS
SELECT business_group_id
FROM   per_competences
WHERE  competence_id = p_competence_id;
BEGIN
      pa_debug.init_err_stack ('pa_role_utils.validate_role_competency');
      OPEN l_get_bg_csr;
      FETCH l_get_bg_csr INTO l_business_group_id;
      IF l_get_bg_csr%NOTFOUND THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_COMPETENCY_INVALID_AMBIGOUS';
      ELSIF (l_business_group_id IS NOT NULL AND
            pa_cross_business_grp.IsCrossBGProfile = 'Y' ) THEN
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	  x_error_message_code := 'PA_ROLE_COMPETENCY_NOT_GLOBAL';
      ELSIF l_business_group_id is not null THEN
         IF l_business_group_id <> pa_utils.business_group_id THEN
  	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_ROLE_COMPETENCY_BG_INVALID';
         END IF;
      ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE l_get_bg_csr;
      pa_debug.reset_err_stack;
EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ROLE_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END Validate_Role_Competency ;


----PROCEDURE Get_Schedulable_flag
----This procedure returns the schedulable flag for the role
--- If the role has the Allow Scheduling control defined,the flag will be 'Y'
--- Otherwise the flag will be 'N'
--- The return status will be 'S' if the API completes succesfully
--- The return status will be 'E' if the API has an error
--- The return status will be 'U' if the API has an unexpected error
----x_error_message_code is the fnd message code
----------------------------------------------------------------------------
PROCEDURE Get_Schedulable_flag (p_role_id in number
                                ,x_schedulable_flag out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_return_status    out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
cursor c_allow_schedule is
  --select '1'
  --from dual
  --where exists
    select 'Y'
        from pa_role_controls
        where project_role_id=p_role_id
      and  role_control_code='ALLOW_SCHEDULE'
      AND ROWNUM = 1;
v_dummy varchar2(1);
begin
 open c_allow_schedule;
 fetch c_allow_schedule into v_dummy;
 if c_allow_schedule%FOUND then
    x_schedulable_flag:='Y';
    x_return_status:=FND_API.G_RET_STS_SUCCESS;
 else
   x_schedulable_flag:='N';
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
 end if;
 close c_allow_schedule;
exception
 when others then
   close c_allow_schedule;
   x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
   x_error_message_code:=SQLCODE;
end;

---FUNCTION  Get_Schedulable_flag
FUNCTION Get_Schedulable_flag (p_role_id in number) return varchar2 is
cursor c_allow_schedule is
  --select '1'
  --from dual
  --where exists
       select 'Y'
        from pa_role_controls
        where project_role_id=p_role_id
	 and  role_control_code='ALLOW_SCHEDULE'
	 AND ROWNUM =1;
v_dummy varchar2(1);
begin
 open c_allow_schedule;
 fetch c_allow_schedule into v_dummy;
 if c_allow_schedule%FOUND then
     close c_allow_schedule;
     return 'Y';
 else
    close c_allow_schedule;
    return 'N';
 end if;
exception
 when others then
   close c_allow_schedule;
   raise;
end;


---   PROCEDURE Check_delete_role_OK
---This procedure will check if the role can be deleted or not.
-- Here are the rules:
--1.Roles in pa_project_parties table can not be deleted
--2.Roles in pa_project_assignments table can not be deleted
--3.Roles in any contracts team table (?) can not be deleted
--4 Pre-seeded roles can not be deleted. We decide the pre-seeded roles by
-- the project_role_id. All pre-seeded roles should have project_role_id <1000
--If the x_return_status is 'S', then the role can be deleted
--If the x_return_status is 'E', then the role can not be deleted
--If the x_return_status is 'U', then unexpected error happen
--x_error_message_code is the fnd message code if the x_return_status is 'E'
--x_error_message_code is the SQL error code if the x_return_status is 'U'
--------------------------------------------------------------------------------
PROCEDURE Check_delete_role_OK (p_role_id in number
                                ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
cursor c_seed_roles is
   --select '1'
   --from dual
   --where exists
   select 'Y'
                 from pa_project_role_types_b /* Bug#2788815-Changed pa_project_role_types_vl to
                                               pa_project_role_types_b */
                 where project_role_id in (1,2,3,4)
     and project_role_id=p_role_id
     AND ROWNUM =1;

v_dummy varchar2(1);
v_dummy1 varchar2(1);
Begin
 open c_seed_roles;
 fetch c_seed_roles into v_dummy1;
 if c_seed_roles%FOUND then
     x_return_status:=FND_API.G_RET_STS_ERROR;
     x_error_message_code:='PA_COMMON_SEEDED_ROLES';
 else
   if is_role_in_use(p_role_id)='N' then
     x_return_status:=FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status:=FND_API.G_RET_STS_ERROR;
     x_error_message_code:='PA_COMMON_ROLE_IN_USE';
   end if;
 end if;
 close c_seed_roles;
 exception
   when others then
     close c_seed_roles;
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
End;


----   PROCEDURE Check_remove_control_ok
-- This procedure will check if the user can remove any control
-- for the role
---Business rules:
---The user is not allowed to remove any of the controls if
---the role is in use and the role control matches the object_type in
---pa_project_parties in a certain way
--If the x_return_status is 'S', then the role control can not be removed
--If the x_return_status is 'E', then the role control can not be removed
--If the x_return_status is 'U', then unexpected error happen
--x_error_message_code is the fnd message code if the x_return_status is 'E'
--x_error_message_code is the SQL error code if the x_return_status is 'U'
------------------------------------------------------------------
PROCEDURE Check_remove_control_ok(p_role_id in number
                                  ,p_role_control_code in varchar2
                                  ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                  ,x_error_message_code out NOCOPY varchar2) is --File.Sql.39 bug 4440895
/* Fix for bug 1829383 */
cursor c_role_control is
select created_by
from pa_role_controls
where project_role_id=p_role_id
and role_control_code =p_role_control_code;
/* Fix for bug 1829383 */
cursor c_seed_roles is
   --select '1'
   --from dual
   --where exists
   select 'Y'
     from pa_project_role_types_b /* Bug#2788815-Changed pa_project_role_types to
                                               pa_project_role_types_b */
     where project_role_id in (1,2,3,4)
     and project_role_id=p_role_id
     AND ROWNUM =1;
v_dummy varchar2(1);
v_cr_by NUMBER;

Begin

  ------The following logic need be modified later to
  ------consider the object_type in pa_project_parties

 open c_seed_roles;
 fetch c_seed_roles into v_dummy;
 if c_seed_roles%FOUND then
	/* Fix for bug 1829383
	To make it possible for a user to remove the user defined controls
	from the pre-seeded role types 		*/
	OPEN c_role_control;
	FETCH c_role_control INTO v_cr_by;
	IF c_role_control%FOUND THEN
		IF v_cr_by =1 THEN
			x_return_status:=FND_API.G_RET_STS_ERROR;
			x_error_message_code:='PA_COMMON_SEEDED_ROLES';
		ELSE
			x_return_status:=FND_API.G_RET_STS_SUCCESS;
		END IF;
--     x_return_status:=FND_API.G_RET_STS_SUCCESS;
--     x_return_status:=FND_API.G_RET_STS_ERROR;
--   x_error_message_code:='PA_COMMON_SEEDED_ROLES';
	END IF;
	CLOSE c_role_control;
/* Fix for bug 1829383*/
 else
/* Commented the following line for bug 2375913
	x_return_status:=FND_API.G_RET_STS_SUCCESS;
*/
/* Uncommented the following block of code for bug 2375913 */
 /* Added the below if condition for ALLOW_QUERY_LABOR_COST for Bug 2951857 */
 If p_role_control_code <> 'ALLOW_QUERY_LABOR_COST' then
    if is_role_in_use(p_role_id)='N' then
      x_return_status:=FND_API.G_RET_STS_SUCCESS;
    else
      x_return_status:=FND_API.G_RET_STS_ERROR;
      x_error_message_code:='PA_COMMON_ROLE_IN_USE';
    end if;
 else
      x_return_status:=FND_API.G_RET_STS_SUCCESS;
 end if;
/* end of code uncommented for bug 2375913 */
end if;
CLOSE c_seed_roles;
 exception
   when others then
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
End;


------ PROCEDURE Check_delete_role_list_OK
-- This procedure will check if the role list can be removed or not
-- If a role list has been associated with a project , then it
-- can not be removed
--If the x_return_status is 'S', then the role list can be deleted
--If the x_return_status is 'E', then the role list can not be deleted
--If the x_return_status is 'U', then unexpected error happen
--x_error_message_code is the fnd message code if the x_return_status is 'E'
--x_error_message_code is the SQL error code if the x_return_status is 'U'
--------------------------------------------------------------------
PROCEDURE Check_delete_role_list_OK(p_role_list_id in number
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895

cursor c_role_list_in_use is
  --select '1'
  --from dual
  --where exists
          select 'Y'
           from pa_projects_all
	    where role_list_id=p_role_list_id
	    AND ROWNUM=1;
v_dummy varchar2(1);

begin
  open c_role_list_in_use;
  fetch c_role_list_in_use into v_dummy;
  if c_role_list_in_use%NOTFOUND then
     x_return_status:=FND_API.G_RET_STS_SUCCESS;
  else
     x_return_status:=FND_API.G_RET_STS_ERROR;
     x_error_message_code:='PA_COMMON_ROLE_LIST_IN_USE';
  end if;
  close c_role_list_in_use;
exception
   when others then
     close c_role_list_in_use;
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
End;


----The following procedure is commented out becuase of the business rules changes
---Based on the discussion on August 25, 2000 with Mary and Selva, we should allow
---the user to change the menu name for pre-seeded roles and roles in use.
---We need to update the menu_id in fnd_grants with changed menu_id .
/*---PROCEDURE Check_change_role_menu_OK
---This procedure check if the user can change the menu for the role
---Here, 'change' means changing the menu_id by choosing another menu for the role,
--- instead of changing functions for the same menu in the menu form
---If a role has a menu and the role is used in pa_project_parties (fnd_grants)then
---the menu can not be changed in the role
PROCEDURE Check_change_role_menu_OK(p_role_id in number
                                    ,x_return_status out varchar2
                                    ,x_error_message_code out varchar2) IS
v_menu_id number;
begin
 select menu_id
 into v_menu_id
 from pa_project_role_types
 where project_role_id=p_role_id;

 if v_menu_id is not null then
   if is_role_in_use(p_role_id)='N' then
     x_return_status:=FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status:=FND_API.G_RET_STS_ERROR;
     x_error_message_code:='PA_COMMON_ROLE_IN_USE';
   end if;
else
    x_return_status:=FND_API.G_RET_STS_ERROR;
end if;

 exception
   when no_data_found then
     null;
   when others then
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
end; */


----PROCEDURE update_menu_in_grants
----This procedure updates the menu_id (role_id) in fnd_grants
----in case the user changes the menu id for the role
PROCEDURE update_menu_in_grants(p_role_id in number
                               ,p_menu_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
v_return_status varchar2(1);
v_msg_count number;
v_msg_data varchar2(240);
l_count    number;

begin
select count(*)
into   l_count
from pa_project_parties
where project_role_id = p_role_id;

IF l_count > 0 THEN

   pa_security_pvt.update_menu(
     p_commit           => FND_API.G_FALSE,
     -- p_debug_mode       => 'N',
     p_project_role_id  => p_role_id,
     p_menu_id          => p_menu_id,
     x_return_status    => v_return_status,
     x_msg_count        => v_msg_count,
     x_msg_data         => v_msg_data
   );

  if v_return_status=fnd_api.g_ret_sts_success then
     x_return_status:=fnd_api.g_ret_sts_success;
     return;
  else
     x_return_status:=fnd_api.g_ret_sts_error;
     return;
  end if;

END IF;

x_return_status:=fnd_api.g_ret_sts_success;

exception
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     x_error_message_code:=SQLCODE;
end ;

----PROCEDURE Disable_role_based_sec
----This procedure remove the records from fnd_grants
----in case the user disables role based security from
----role form
PROCEDURE disable_role_based_sec(p_role_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
v_return_status varchar2(1);
v_msg_count number;
v_msg_data varchar2(240);
l_count    number;

begin
select count(*)
into   l_count
from   pa_project_parties
where  project_role_id = p_role_id;

IF l_count > 0 THEN

   pa_security_pvt.revoke_role_based_sec(
      p_commit           => FND_API.G_FALSE,
      -- p_debug_mode       =>'N',
      p_project_role_id  => p_role_id,
      x_return_status    => v_return_status,
      x_msg_count        => v_msg_count,
      x_msg_data         => v_msg_data
    );

   if v_return_status = fnd_api.g_ret_sts_success then
      x_return_status := fnd_api.g_ret_sts_success;
      return;
   else
      x_return_status := fnd_api.g_ret_sts_error;
      return;
  end if;
END IF;

x_return_status:=fnd_api.g_ret_sts_success;

exception
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     x_error_message_code:=SQLCODE;
end ;

----PROCEDURE Enable_role_based_sec
----This procedure upgrades existing records in pa_project_parties
-----to fnd_grants in case the user enables role based security from
----role form
PROCEDURE Enable_role_based_sec(p_role_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895

v_return_status varchar2(1);
v_msg_count number;
v_msg_data varchar2(240);
l_count    number;

begin
select count(*)
into   l_count
from pa_project_parties
where project_role_id = p_role_id;
--  and parties.grant_id is null;

-- hr_utility.trace('before call to grant_role_based_sec');
IF l_count > 0 THEN
   pa_security_pvt.grant_role_based_sec(
     p_commit           => FND_API.G_FALSE,
     -- p_debug_mode       => 'N',
     p_project_role_id  => p_role_id,
     x_return_status    => v_return_status,
     x_msg_count        => v_msg_count,
     x_msg_data         => v_msg_data
   );
-- hr_utility.trace('v_return_status is ' || v_return_status);

-- hr_utility.trace('after call to grant_role_based_sec');
  if v_return_status = fnd_api.g_ret_sts_success then
     x_return_status := fnd_api.g_ret_sts_success;
     return;
  else
     x_return_status := fnd_api.g_ret_sts_error;
     return;
  end if;

END IF;

x_return_status := fnd_api.g_ret_sts_success;

exception
  when others then
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     x_error_message_code := SQLCODE;
end ;


--Function  is_role_in_use
------------------------------------------------------------------
FUNCTION is_role_in_use(p_role_id in number) return varchar2 IS

/***********************************************************
 * Bug - 3575890
 * Desc - We should also check if the role exists in
 *        pa_rbs_elements and pa_resource_list_members
 *        table.
 *********************************************************/
cursor c_role_in_use is
 SELECT '1'
 FROM dual
   WHERE EXISTS (SELECT 'Y'
               FROM  pa_project_parties ppp
               WHERE ppp.project_role_id=p_role_id)
      OR EXISTS
               (SELECT 'Y'
               FROM  pa_project_assignments ppa
               WHERE ppa.project_role_id=p_role_id)
      OR EXISTS
               (SELECT 'Y'
                FROM pa_rbs_elements
                WHERE resource_type_id = 15
                AND resource_source_id = p_role_id)
      OR EXISTS
               (SELECT 'Y'
                FROM pa_resource_list_members
                where project_role_id = p_role_id);
v_dummy varchar2(1);
Begin
   open c_role_in_use;
   fetch c_role_in_use into v_dummy;
   if c_role_in_use%NOTFOUND then
     close c_role_in_use;
     return 'N';
   else
     close c_role_in_use;
     return 'Y';
   end if;
 exception
   when others then
     close c_role_in_use;
     raise;
End;

---PROCEDURE Check_dup_role_name
---This procedure check if the role name (meaning) is duplicate
---It will be called in private api before insert into
---a new record into the role table or update an existing record
PROCEDURE Check_dup_role_name(p_meaning in varchar2
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
cursor c_exist is
select 'y'
from pa_project_role_types_vl
where meaning =p_meaning;

v_dummy varchar2(1) ;
begin
open c_exist;
fetch c_exist into v_dummy;
if c_exist%notfound then
    x_return_status:=fnd_api.g_ret_sts_success;
else
  x_return_status:=fnd_api.g_ret_sts_error;
  x_error_message_code:='PA_COMMON_DUP_ROLE_NAME';
end if;
 close c_exist;
exception
   when others then
     close c_exist;
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
end;

---PROCEDURE Check_dup_role_list_name
---This procedure checks if the role list name is duplicate
---It will be called in private api before insert into
---a new record into the role list table or update an existing record
PROCEDURE Check_dup_role_list_name(p_name in varchar2
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
cursor c_exist is
select 'y'
from pa_role_lists
where name =p_name;

v_dummy varchar2(1) ;
begin
open c_exist;
fetch c_exist into v_dummy;
if c_exist%notfound then
    x_return_status:=fnd_api.g_ret_sts_success;
else
  x_return_status:=fnd_api.g_ret_sts_error;
  x_error_message_code:='PA_COMMON_DUP_ROLE_LIST_NAME';
end if;
close c_exist;
exception
   when others then
     close c_exist;
     x_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code:=SQLCODE;
end;

end PA_ROLE_UTILS ;

/

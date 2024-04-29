--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STRUCTURE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STRUCTURE_UTILS" as
/*$Header: PAXSTCUB.pls 120.14.12010000.6 2010/02/09 09:06:57 vgovvala ship $*/

-- API name                      : Check_Delete_Structure_Ver_Ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_structure_version_id         IN      NUMBER
--   x_return_status                OUT     VARCHAR2
--   x_error_message_code           OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--


  procedure Check_Delete_Structure_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    l_user_id  NUMBER;
    l_person_id NUMBER;
    l_dummy     VARCHAR2(1);

    cursor get_person_id(p_user_id NUMBER) IS
    select p.person_id
      from per_all_people_f p, fnd_user f
     where f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date
       and f.user_id = p_user_id;

    cursor get_lock_user(p_person_id NUMBER) IS
    select '1'
      from pa_proj_element_versions v, pa_proj_elem_ver_structure s
     where v.element_version_id = p_structure_version_id
       and v.project_id = s.project_id
       and v.element_version_id = s.element_version_id
       and (locked_by_person_id IS NULL
        or locked_by_person_id = p_person_id);

    cursor get_link IS
    select '1'
      from pa_object_relationships
     where (object_id_from1 = p_structure_version_id
        or object_id_to1 = p_structure_version_id)
       and relationship_type = 'L';

  BEGIN
    l_user_id := FND_GLOBAL.USER_ID;

    --get the current user's person_id
    open get_person_id(l_user_id);
    fetch get_person_id into l_person_id;
    if get_person_id%NOTFOUND then
      l_person_id := -1;
    end if;
    close get_person_id;

    open get_lock_user(l_person_id);
    fetch get_lock_user into l_dummy;
    if get_lock_user%NOTFOUND then
      --the structure version is locked by another user.
      close get_lock_user;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_STRUC_VER_LOCKED';
      return;
    end if;
    close get_lock_user;

    --Check if this is a published version

--Commented by hsiu
--for Advanced Structure changes
--
--    If (Check_Struc_Ver_Published(p_project_id, p_structure_version_id) = 'Y') THEN
      --version is published. Error.
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      x_error_message_code := 'PA_PS_DEL_PUB_STRUC_ERR';
--      return;
--    END IF;

    --Check if this is a billing/costing structure version
    --  if it is, error if this is the only structure version.


    --Check if this structure version has any links
    open get_link;
    fetch get_link into l_dummy;
    if get_link%FOUND then
      --a link exists
      close get_link;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_LINK_EXISTS';
      return;
    end if;
    close get_link;


  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- 4537865 RESET OUT PARAMS
      x_error_message_code :=  SQLERRM ;

      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'Check_Delete_Structure_Ver_Ok');
      RAISE;
  END Check_Delete_Structure_Ver_Ok;

-- API name                      : Check_Structure_Name_Unique
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--   p_structure_name               IN      VARCHAR2
--   p_structure_id                 IN      NUMBER
--   p_project_id                   IN      NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Structure_Name_Unique
  (
    p_structure_name                    IN  VARCHAR2
   ,p_structure_id                      IN  NUMBER
   ,p_project_id                        IN  NUMBER
  ) return VARCHAR2
  IS
    cursor c1 is
           select 1 from pa_proj_elements
           where project_id = p_project_id
           and object_type = 'PA_STRUCTURES'
           and name = p_structure_name;

    cursor c2 IS
           select 1 from pa_proj_elements
           where project_id = p_project_id
           and object_type = 'PA_STRUCTURES'
           and name = p_structure_name
           and proj_element_id <> p_structure_id;

    l_dummy NUMBER;

  BEGIN
    if (p_project_id IS NULL or p_structure_name is NULL) then
      return (null);
    end if;

    IF (p_structure_id IS NULL) THEN
      open c1;
      fetch c1 into l_dummy;
      if c1%notfound THEN
        close c1;
        return('Y');
      else
        close c1;
        return('N');
      end if;
    ELSE
      open c2;
      fetch c2 into l_dummy;
      if c2%notfound THEN
        close c2;
        return ('Y');
      else
        close c2;
        return('N');
      end if;
    END IF;
  EXCEPTION
    when others then
      return (SQLCODE);
  END Check_Structure_Name_Unique;


-- API name                      : Check_Struc_Ver_Name_Unique
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--    p_structure_version_name            IN  VARCHAR2
--    p_pev_structure_id                  IN  NUMBER
--    p_structure_id                      IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Struc_Ver_Name_Unique
  (
    p_structure_version_name            IN  VARCHAR2
   ,p_pev_structure_id                  IN  NUMBER
   ,p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
  ) return varchar2
  IS
    cursor c1 is
           select name from pa_proj_elem_ver_structure
           where project_id = p_project_id
           and proj_element_id = p_structure_id
           and name = p_structure_version_name;
    c1_rec c1%rowtype;

    cursor c2 is
           select name from pa_proj_elem_ver_structure
           where project_id = p_project_id
           and proj_element_id = p_structure_id
           and name = p_structure_version_name
           and pev_structure_id <> p_pev_structure_id;
    c2_rec c2%rowtype;

  BEGIN
    if (p_project_id IS NULL or p_structure_version_name is NULL or p_structure_id is NULL) then
      return (null);
    end if;

    IF (p_pev_structure_id IS NULL) THEN
      open c1;
      fetch c1 into c1_rec;
      if c1%notfound THEN
        close c1;
        return('Y');
      else
        close c1;
        return('N');
      end if;
    ELSE
      open c2;
      fetch c2 into c2_rec;
      if c2%notfound THEN
        close c2;
        return('Y');
      else
        close c2;
        return('N');
      end if;
    END IF;
  EXCEPTION
    when others then
      return (SQLCODE);
  END Check_Struc_Ver_Name_Unique;



-- API name                      : Check_Structure_Type_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--
--  19-Dec-03   avaithia     -Modified
--


  procedure Check_Structure_Type_Exists
  (
    p_project_id                        IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
   ,x_return_status                     OUT NOCOPY  VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS

    l_dummy    VARCHAR2(1);

    cursor c1 is
           select '1'
           from pa_proj_structure_types p, pa_proj_elements e, pa_structure_types t
           where e.project_id = p_project_id
           and e.proj_element_id = p.proj_element_id
           and p.structure_type_id = t.structure_type_id
           and t.structure_type_class_code = p_structure_type
           and t.structure_type_class_code IN ('WORKPLAN', 'FINANCIAL','DELIVERABLE');

  BEGIN

    if (p_project_id IS NULL or p_structure_type is NULL) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_INPUT_NOT_SPECIFIC';
      return;
    end if;

    open c1;
    fetch c1 into l_dummy;
    if c1%notfound THEN
      close c1;
      -- selected structure type does not exist
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    else
      close c1;
      -- selected structure type exists
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_STRUC_TYPE_EXISTS';
    end if;
  EXCEPTION
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 RESET OUT PARAMS
      x_error_message_code := SQLERRM ;

      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'Check_Structure_Type_Exists');
      RAISE;
  END Check_Structure_Type_Exists;


-- API name                      : Get_Struc_Type_For_Structure
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N if not exists; Y if exists.
-- Parameters
--    p_structure_id                      IN  NUMBER
--    p_structure_type                    IN  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Get_Struc_Type_For_Structure
  (
    p_structure_id                      IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
  ) return VARCHAR2
  IS
    l_dummy VARCHAR2(1);

    cursor c1 is
           select '1'
           from pa_proj_structure_types p,
                pa_structure_types t
           where p.proj_element_id = p_structure_id
           and p.structure_type_id = t.structure_type_id
           and t.structure_type_class_code = p_structure_type
           and t.structure_type_class_code IN ('WORKPLAN', 'FINANCIAL');


  BEGIN

    if (p_structure_id IS NULL or p_structure_type IS NULL) then
      return (null);
    end if;

    open c1;
    fetch c1 into l_dummy;
    if c1%notfound THEN
      close c1;
      return('N');
    else
      close c1;
      return('Y');
    end if;
  EXCEPTION
    when others then
      return (SQLCODE);
    return null;
  END Get_Struc_Type_For_Structure;




-- API name                      : Get_Struc_Type_For_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    p_structure_type                    IN  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Get_Struc_Type_For_Version
  (
    p_structure_version_id              IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
  ) return VARCHAR2
  IS
    l_dummy VARCHAR2(1);

    cursor c1 is
           select '1'
           from pa_proj_structure_types p, pa_proj_elements e,
                pa_structure_types t, pa_proj_element_versions v
           where v.element_version_id = p_structure_version_id
           and v.proj_element_id = e.proj_element_id
           and e.proj_element_id = p.proj_element_id
           and p.structure_type_id = t.structure_type_id
           and t.structure_type_class_code = p_structure_type
           and t.structure_type_class_code IN ('WORKPLAN', 'FINANCIAL');


  BEGIN

    if (p_structure_version_id IS NULL or p_structure_type IS NULL) then
      return (null);
    end if;

    open c1;
    fetch c1 into l_dummy;
    if c1%notfound THEN
      close c1;
      return('N');
    else
      close c1;
      return('Y');
    end if;
  EXCEPTION
    when others then
      return (SQLCODE);
    return null;
  END Get_Struc_Type_For_Version;



-- API name                      : Check_Publish_Struc_Ver_Ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if ok; N if can't publish.
-- Purpose
--    Check if the structure version can be published (ie, if linked child are
--             published.)
--
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Publish_Struc_Ver_Ok
  (
    p_structure_version_id              IN  NUMBER
  ) return varchar2
  IS
    CURSOR get_linked_element_parent IS
      select v1.project_id, v1.parent_structure_version_id
        from pa_object_relationships r,
             pa_proj_element_versions v1,
             pa_proj_element_versions v2
       where r.relationship_type = 'L'
         and r.object_type_from IN ('PA_TASKS','PA_STRUCTURES')
         and r.object_id_from1 = v2.element_version_id
         and r.object_id_to1 = v1.element_version_id
         and v2.parent_structure_version_id = p_structure_version_id;

    l_project_id            PA_PROJ_ELEMENT_VERSIONS.PROJECT_ID%TYPE;
    l_struc_ver_id          PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;


    cursor get_other_unpub_ver IS
      select b.element_version_id
        from pa_proj_element_versions a,
             pa_proj_element_versions b,
             pa_proj_elem_ver_structure c
       where a.element_version_id = p_structure_version_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> p_structure_version_id
         and b.object_type = 'PA_STRUCTURES'
         and b.project_id = c.project_id
         and b.element_version_id = c.element_version_id
         and c.status_code <> 'STRUCTURE_PUBLISHED';

  BEGIN
    OPEN get_other_unpub_ver;
    LOOP
      FETCH get_other_unpub_ver into l_struc_ver_id;
      EXIT WHEN get_other_unpub_ver%NOTFOUND;
      IF ('O' = PA_PROJECT_STRUCTURE_UTILS.IS_STRUC_VER_LOCKED_BY_USER(
                  FND_GLOBAL.USER_ID, l_struc_ver_id)) THEN
        CLOSE get_other_unpub_ver;
        return 'N';
      END IF;
    END LOOP;
    CLOSE get_other_unpub_ver;

/*
    OPEN get_linked_element_parent;
    LOOP
      FETCH get_linked_element_parent into l_project_id, l_struc_ver_id;
      EXIT WHEN get_linked_element_parent%NOTFOUND;
      IF ('N' = PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(l_project_id,l_struc_ver_id)) THEN
        CLOSE get_linked_element_parent;
        return 'N';
      END IF;
    END LOOP;
    CLOSE get_linked_element_parent;
*/
    return 'Y';
  END Check_Publish_Struc_Ver_Ok;


-- API name                      : Check_Struc_Ver_Published
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N if not published; Y if published.
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Struc_Ver_Published
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
  ) return VARCHAR2
  IS
    cursor c1 is
      select '1'
      from pa_proj_elem_ver_structure
      where project_id = p_project_id
      and element_version_id = p_structure_version_id
      and status_code = 'STRUCTURE_PUBLISHED';
    c1_rec c1%rowtype;

  BEGIN
    if (p_project_id IS NULL or p_structure_version_id IS NULL) then
      return (null);
    end if;

    open c1;
    fetch c1 into c1_rec;
    if c1%notfound THEN
      close c1;
      return('N');
    else
      close c1;
      return('Y');
    end if;
  EXCEPTION
    when others then
      return (SQLCODE);
  END Check_Struc_Ver_Published;



-- API name                      : Get_New_Struc_Ver_Name
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    x_structure_version_name            OUT VARCHAR2
--    x_return_status                     OUT VARCHAR2
--    x_error_message_code                OUT VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Get_New_Struc_Ver_Name
  (
    p_structure_version_id              IN  NUMBER
   ,x_structure_version_name            OUT NOCOPY VARCHAR2 -- 4537865
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    l_posA              NUMBER;
    l_name              PA_PROJ_ELEM_VER_STRUCTURE.name%TYPE;
    l_suffix            NUMBER;
    l_new_name          PA_PROJ_ELEM_VER_STRUCTURE.name%TYPE;
    l_project_id        PA_PROJECTS_ALL.project_id%TYPE;
    l_proj_element_id   PA_PROJ_ELEMENTS.proj_element_id%TYPE;

    l_dummy             VARCHAR2(1);

    cursor getname is
      select s.name, v.project_id, v.proj_element_id
        from pa_proj_element_versions v, pa_proj_elem_ver_structure s
       where v.element_version_id = p_structure_version_id and
             s.project_id = v.project_id and
             s.element_version_id = v.element_version_id;

    cursor new_name_valid(p_project_id PA_PROJECTS_ALL.project_id%TYPE,
                          p_structure_id PA_PROJ_ELEMENTS.proj_element_id%TYPE,
                          p_new_name VARCHAR2) is
      select '1'
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and proj_element_id = p_structure_id
         and name = p_new_name;
  BEGIN

    open getname;
    fetch getname into l_name, l_project_id, l_proj_element_id;
    if  getname%NOTFOUND then
      close getname;
      RAISE NO_DATA_FOUND;
    end if;
    close getname;

    l_posA := instr(l_name, ' - ', -1, 1);
    if (l_posA = 0) then
      x_structure_version_name := substrb(l_name||' - 1',0,240); -- 4537865 replaced substr usage with substrb
      x_return_status:= FND_API.G_RET_STS_SUCCESS;
      return;
    end if;
    if (l_posA > 0) then
      --check if this is a number
      begin
        l_suffix := to_number(substrb(l_name, 3+l_posA)); -- 4537865 replaced substr usage with substrb
        LOOP
          --check if new name is unique
          l_suffix := l_suffix + 1;
          l_new_name := substrb(l_name, 0, l_posA - 1)||' - '||to_char(l_suffix); -- 4537865 replaced substr usage with substrb
          open new_name_valid(l_project_id, l_proj_element_id, l_new_name);
          fetch new_name_valid into l_dummy;

          if new_name_valid%NOTFOUND then
            --name is valid
            x_structure_version_name := l_new_name;
            x_return_status:= FND_API.G_RET_STS_SUCCESS;
            close new_name_valid;
            EXIT;
          end if;
          close new_name_valid;
        END LOOP;
      EXCEPTION
        when VALUE_ERROR then
          --character after dash.
          --start off with 1 for suffix.
          l_suffix := 0;
          LOOP
            --check if new name is unique
            l_suffix := l_suffix + 1;
            l_new_name := l_name||' - '||to_char(l_suffix);
            open new_name_valid(l_project_id, l_proj_element_id, l_new_name);
            fetch new_name_valid into l_dummy;

            if new_name_valid%NOTFOUND then
              --name is valid
              x_structure_version_name := l_new_name;
              x_return_status:= FND_API.G_RET_STS_SUCCESS;
              close new_name_valid;
              EXIT;
            end if;
            close new_name_valid;
          END LOOP;
      end;
    end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_STRUC_VER_NAME_GEN_ERR';
      -- 4537865 RESET OUT PARAMS
    x_structure_version_name := NULL ;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- 4537865 RESET OUT PARAMS
        x_structure_version_name := NULL ;
    x_error_message_code := SQLERRM ;

      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'Get_New_Struc_Ver_Name');
      RAISE;
  END;




-- API name                      : Structure_Version_Name_Or_Id
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_structure_id                      IN  NUMBER
--    p_structure_version_name            IN  VARCHAR2
--    p_structure_version_id              IN  NUMBER
--    p_check_id_flag                     IN  VARCHAR2 :=  PA_STARTUP.G_Check_ID_Flag
--    x_structure_version_id              OUT  NUMBER
--    x_return_status                     OUT  VARCHAR2
--    x_error_message_code                OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Structure_Version_Name_Or_Id
  (
    p_structure_id                      IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_id              IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 :=  PA_STARTUP.G_Check_ID_Flag
   ,x_structure_version_id              OUT NOCOPY  NUMBER  -- 4537865
   ,x_return_status                     OUT NOCOPY VARCHAR2  -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2  -- 4537865
  )
  IS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';

  BEGIN
    IF (p_structure_version_id IS NOT NULL) THEN
      IF (p_check_id_flag = 'Y') THEN
        select pev.element_version_id
          into x_structure_version_id
          from pa_proj_element_versions pev
--               pa_proj_elem_ver_structure pevs,
--               pa_proj_elements pe
         where
--               pe.proj_element_id = p_structure_id
               pev.element_version_id = p_structure_version_id;
--           and pevs.project_id = pe.project_id
--           and pevs.element_version_id = pev.element_version_id;
      ELSE
        x_structure_version_id := p_structure_version_id;
      END IF;
    ELSE
      --get by name
      select pevs.element_version_id
        into x_structure_version_id
        from pa_proj_elem_ver_structure pevs,
             pa_proj_elements pe
       where pe.proj_element_id = p_structure_id
         and pevs.project_id = pe.project_id
         and pevs.proj_element_id = pe.proj_element_id
         and pevs.name = p_structure_version_name;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_message_code:= 'PA_PS_INVAL_STRUC_VER_NAME';

      -- 4537865 RESET OUT PARAMS
     x_structure_version_id := NULL ;

       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_message_code:= 'PA_PS_STRUC_V_NAME_NOT_UNIQUE';

          -- 4537865 RESET OUT PARAMS
         x_structure_version_id := NULL ;
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

          -- 4537865 RESET OUT PARAMS
         x_structure_version_id := NULL ;
     x_error_message_code := SQLERRM ;

         RAISE;
  END;


-- API name                      : Structure_Name_Or_Id
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_project_id                        IN  NUMBER
--    p_structure_name                    IN  VARCHAR2
--    p_structure_id                      IN  NUMBER
--    p_check_id_flag                     IN  VARCHAR2 :=  PA_STARTUP.G_Check_ID_Flag
--    x_structure_id                      OUT  NUMBER
--    x_return_status                     OUT  VARCHAR2
--    x_error_message_code                OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Structure_Name_Or_Id
  (
    p_project_id                        IN  NUMBER
   ,p_structure_name                    IN  VARCHAR2
   ,p_structure_id                      IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 :=  PA_STARTUP.G_Check_ID_Flag
   ,x_structure_id                      OUT NOCOPY  NUMBER -- 4537865
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
  BEGIN
    IF (p_structure_id IS NOT NULL) THEN
      IF (p_check_id_flag = 'Y') THEN
        select proj_element_id
          into x_structure_id
          from pa_proj_elements
         where proj_element_id = p_structure_id;
      ELSE
        x_structure_id := p_structure_id;
      END IF;
    ELSE
      select proj_element_id
        into x_structure_id
        from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_STRUCTURES'
         and name = p_structure_name;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_message_code:= 'PA_PS_INVALID_STRUCT_NAME';

     -- 4537865 RESET OUT PARAM
    x_structure_id := NULL ;
       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_message_code:= 'PA_PS_STRUC_NAME_NOT_UNIQUE';

         -- 4537865 RESET OUT PARAM
        x_structure_id := NULL ;
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

         -- 4537865 RESET OUT PARAM
        x_structure_id := NULL ;
    x_error_message_code := SQLERRM ;
         RAISE;
  END;



-- API name                      : IS_STRUC_VER_LOCKED_BY_USER
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y is locked by user - and returns Y also when locked by other users
--                                   and the current user has privelege to Unlock the structure version,
--                                 N is not locked,
--                                 O is locked by other user.
-- Parameters
--   p_user_id                 NUMBER
--   p_structure_version_id    NUMBER
--
--  History
--
--  01-NOV-01   HSIU             -Created
--


  function IS_STRUC_VER_LOCKED_BY_USER(p_user_id NUMBER,
                                       p_structure_version_id NUMBER)
  return VARCHAR2
  IS
    l_person_id number;
    l_locked_person_id number;

    cursor get_person_id IS
    select p.person_id
      from fnd_user f,
           per_all_people_f p
     where p_user_id = f.user_id
       and f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date;

    cursor get_lock_user IS
    select s.locked_by_person_id
      from pa_proj_element_versions v,
           pa_proj_elem_ver_structure s
     where v.element_version_id = p_structure_version_id
       and v.project_id = s.project_id
       and v.element_version_id = s.element_version_id;

  BEGIN

    OPEN get_lock_user;
    FETCH get_lock_user into l_locked_person_id;
    IF (get_lock_user%NOTFOUND) THEN
      CLOSE get_lock_user;
      return NULL;
    END IF;
    CLOSE get_lock_user;

    IF (l_locked_person_id IS NULL) THEN
      return 'N';
    END IF;

    --structure version is locked. Continue.
    OPEN get_person_id;
    FETCH get_person_id into l_person_id;
    IF (get_person_id%NOTFOUND) THEN
      CLOSE get_person_id;
      return NULL;
    END IF;
    CLOSE get_person_id;

--bug 3071008: adding the check back in Update_Structure_version_attr
--and is_structure_version_updatable
/*
    IF (PA_SECURITY_PVT.check_user_privilege('PA_UNLOCK_ANY_STRUCTURE'
                                             ,NULL
                                             ,to_number(NULL))
       = FND_API.G_TRUE) THEN
      --current user is super user. can edit
      return 'Y';
    END IF;
*/
--end bug 3071008

    IF (l_person_id = l_locked_person_id) THEN
      --locked by current user
      return 'Y';
    ELSE
      --locked by other user
      return 'O';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return (NULL);
  END IS_STRUC_VER_LOCKED_BY_USER;

-- This function is same as above except for it returns 'O' when locked by other users
-- and current user has privelege to Unlock the structure version
-- API name                      : IS_STRUC_VER_LOCKED_BY_USER1
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y is locked by user,
--                                 N is not locked,
--                                 O is locked by other user.
-- Parameters
--   p_user_id                 fnd_user.user_id%TYPE
--   p_structure_version_id    pa_proj_element_versions.element_version_id%TYPE
--
--  History
--
--  20-may-03   mrajput             -Created
--  Added For bug 2964237


  function IS_STRUC_VER_LOCKED_BY_USER1(p_user_id fnd_user.user_id%TYPE,
                                       p_structure_version_id pa_proj_element_versions.element_version_id%TYPE)
  return VARCHAR2
  IS

--Cursor to get the persion id from the user id passed to thia api
    cursor get_person_id IS
    select p.person_id
      from fnd_user f,
           per_all_people_f p
     where p_user_id = f.user_id
       and f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date;

--Cursor to get the locked by person id for a structure version
    cursor get_lock_user IS
    select s.locked_by_person_id
      from pa_proj_element_versions v,
           pa_proj_elem_ver_structure s
     where v.element_version_id = p_structure_version_id
       and v.project_id = s.project_id
       and v.element_version_id = s.element_version_id;

    l_person_id           per_all_people_f.person_id%TYPE;
    l_locked_person_id    pa_proj_elem_ver_structure.locked_by_person_id%TYPE;

    l_module_name         VARCHAR2(100) := 'pa.plsql.IS_STRUC_VER_LOCKED_BY_USER1';
    l_debug_mode          varchar2(1);


  BEGIN

    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN

        pa_debug.g_err_stage := 'The value of passed user_id to this api is: ' || p_user_id;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

        pa_debug.g_err_stage := 'The value of passed structure version_id to this api is: ' || p_structure_version_id;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);

    END IF;

    OPEN get_lock_user;
    FETCH get_lock_user into l_locked_person_id;
    IF (get_lock_user%NOTFOUND) THEN
         CLOSE get_lock_user;
         return NULL;
    END IF;
    CLOSE get_lock_user;

    IF (l_locked_person_id IS NULL) THEN
          return 'N';
    END IF;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'The Structure version passed is locked by person id : ' || l_locked_person_id;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;


    --structure version is locked. Continue.
    OPEN get_person_id;
    FETCH get_person_id into l_person_id;
    IF (get_person_id%NOTFOUND) THEN
      CLOSE get_person_id;
      return NULL;
    END IF;
    CLOSE get_person_id;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'The person id of the fnd user passed is : ' || l_person_id;
        pa_debug.write(l_module_name,pa_debug.g_err_stage,3);
    END IF;


    IF (l_person_id = l_locked_person_id) THEN
      --locked by current user
      return 'Y';
    ELSE
      --locked by other user
      return 'O';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return (NULL);
  END IS_STRUC_VER_LOCKED_BY_USER1;


-- API name                      : GET_APPROVAL_OPTION
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N is no approval,
--                                 M is approval with manual publish,
--                                 A is approval with auto publish.
-- Parameters
--   p_project_id    NUMBER
--
--  History
--
--  06-NOV-01   HSIU             -Created
--

  function GET_APPROVAL_OPTION(p_project_id NUMBER)
  return VARCHAR2
  IS

    /* Bug 3946599 . This Cursor is Wrong.This will return both Financial as well as WP record
    CURSOR c1 IS
      select wp_approval_reqd_flag, wp_auto_publish_flag
        from pa_proj_workplan_attr
       where project_id = p_project_id; */

    -- Bug 3946599 : Included an additional clause in above cursor that
    --               The Structure Type is Workplan.

     CURSOR c1 IS
      select wp_approval_reqd_flag, wp_auto_publish_flag
        from pa_proj_workplan_attr ppw
            ,pa_proj_structure_types ppst
            ,pa_structure_types pst
      where ppw.project_id = p_project_id
        and ppw.proj_element_id = ppst.proj_element_id
        and ppst.structure_type_id = pst.structure_type_id
        and pst.structure_type = 'WORKPLAN' ;

    --Bug 3946599 :End of Changes by avaithia

    l_approval  VARCHAR2(1);
    l_auto_pub  VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_approval, l_auto_pub;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    END IF;

    CLOSE c1;
    IF (l_approval = 'N') THEN
      return 'N';
    ELSE
      IF (l_auto_pub = 'Y') THEN
        return 'A';
      ELSE
        return 'M';
      END IF;
    END IF;
  END GET_APPROVAL_OPTION;


-- API name                      : IS_STRUC_TYPE_LICENSED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y for licensed,
--                                 N for not licensed.
--
-- Parameters
--   p_structure_type            VARCHAR2
--
--  History
--
--  06-NOV-01   HSIU             -Created
--

  function IS_STRUC_TYPE_LICENSED(p_structure_type VARCHAR2)
  return VARCHAR2
  IS
  BEGIN
    IF p_structure_type = 'WORKPLAN' THEN
      return pa_install.is_pjt_licensed;
    ELSIF p_structure_type = 'FINANCIAL' THEN
      return pa_install.is_costing_licensed;
    END IF;
    return 'N';
  END IS_STRUC_TYPE_LICENSED;

-- API name                      : CHECK_PUBLISHED_VER_EXISTS
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y for published version exists,
--                                 N for not exist.
--
-- Parameters
--   p_project_id               NUMBER
--   p_structure_id             NUMBER
--
--  History
--
--  16-JAN-02   HSIU             -Created
--
  function CHECK_PUBLISHED_VER_EXISTS(p_project_id NUMBER,
                                      p_structure_id NUMBER)
  return VARCHAR2
  IS
    CURSOR c1 IS
      select '1'
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and proj_element_id = p_structure_id
         and status_code = 'STRUCTURE_PUBLISHED';
    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    END IF;
    CLOSE c1;
    return 'Y';
  END CHECK_PUBLISHED_VER_EXISTS;


-- API name                      : Product_Licensed
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : BOTH -- for workplan and (costing or billing)
--                                 WORKPLAN -- for workplan only
--                                 FINANCIAL -- for costing or billing only
--
--
-- Parameters
--   None
--
--  History
--
--  14-MAR-02   HSIU             -Created
--
  function Product_Licensed
  return varchar2
  IS
    l_financial varchar2(1) := 'N';
    l_workplan varchar2(1):= 'N';
    retval VARCHAR2(10);
  BEGIN
    l_workplan := IS_STRUC_TYPE_LICENSED('WORKPLAN') ;
    l_financial := IS_STRUC_TYPE_LICENSED('FINANCIAL') ;

    IF (l_workplan = 'Y' AND (l_financial = 'Y') ) THEN
      retval := 'BOTH';
    ELSIF (l_workplan = 'Y') THEN
      retval := 'WORKPLAN';
    ELSE
      retval := 'FINANCIAL';
    END IF;

    return retval;
  END Product_Licensed;



-- Parameters
--   p_project_id                NUMBER
--
--  History
--
--  14-MAR-02   HSIU             -Created
--
  function Associated_Structure(p_project_id NUMBER)
  return varchar2
  IS
    cursor c1 IS
      select proj_element_id from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_STRUCTURES';
    c1_rec c1%ROWTYPE;

    l_financial varchar2(1) := 'N';
    l_workplan varchar2(1):= 'N';
    retval varchar2(10);
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 into c1_rec;
      EXIT when c1%NOTFOUND;
      IF (Get_Struc_Type_For_Structure(c1_rec.proj_element_id, 'WORKPLAN') = 'Y') THEN
        l_workplan := 'Y';
      END IF;
      IF (Get_Struc_Type_For_Structure(c1_rec.proj_element_id, 'FINANCIAL') = 'Y') THEN
        l_financial := 'Y';
      END IF;
    END LOOP;
    If c1%ROWCOUNT = 2 THEN
      retval := 'SPLIT';
    ELSE
      IF (l_workplan = 'Y' and l_financial = 'Y' ) THEN
        retval := 'BOTH';
      ELSIF (l_workplan = 'Y') THEN
        retval := 'WORKPLAN';
      ELSE
        retval := 'FINANCIAL';
      END IF;
    END IF;
    CLOSE c1;

    return retval;
  END Associated_Structure;


-- API name                      : Get_Rollup_Dates
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_element_version_id             IN   NUMBER
--   p_min_sch_start_date             OUT  DATE
--   p_max_sch_finish_date            OUT  DATE
--   p_rollup_last_update_date        OUT  DATE
--
--  History
--
--  25-MAR-02   HSIU             -Created
--
  procedure Get_Rollup_Dates
  (
     p_element_version_id           IN  NUMBER
    ,p_min_sch_start_date           OUT NOCOPY DATE -- 4537865
    ,p_max_sch_finish_date          OUT NOCOPY DATE -- 4537865
    ,p_rollup_last_update_date      OUT NOCOPY DATE -- 4537865
  )
  IS
     CURSOR c1 IS
       select min(a.scheduled_start_date)
         from pa_proj_elem_ver_schedule a,
              pa_object_relationships b,
              pa_proj_element_versions c
        where relationship_type IN ('S', 'L')
          and b.object_id_from1 = p_element_version_id
          and b.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          and b.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
          and b.object_id_to1 = c.element_version_id
          and c.project_id = a.project_id
          and c.element_version_id = a.element_version_id;

     CURSOR c2 IS
       select max(a.scheduled_finish_date)
         from pa_proj_elem_ver_schedule a,
              pa_object_relationships b,
              pa_proj_element_versions c
        where relationship_type IN ('S', 'L')
          and b.object_id_from1 = p_element_version_id
          and b.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          and b.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
          and b.object_id_to1 = c.element_version_id
          and c.project_id = a.project_id
          and c.element_version_id = a.element_version_id;

    CURSOR c3 IS
      select '1'
        from pa_object_relationships a,
             pa_proj_elements b,
             pa_proj_element_versions c
       where a.object_id_from1 = p_element_version_id
         and a.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
         and a.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
         and a.object_id_to1 = c.element_version_id
         and c.proj_element_id = b.proj_element_id
         and c.project_id = b.project_id
         and b.link_task_flag = 'Y';

    --bug 3074706
    --add pa_proj_element_versions and add condition project_id to use index
    CURSOR c4 IS
      select max(a.last_update_date)
        from pa_proj_elem_ver_schedule a,
             pa_object_relationships b,
             pa_proj_element_versions c
       where a.element_version_id = c.element_version_id
         and a.project_id = c.project_id
         and c.element_version_id = b.object_id_to1
         and b.object_type_to = 'PA_TASKS'
         and b.object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
         and b.relationship_type = 'S'
         and b.object_id_from1 = p_element_version_id;
    --end bug 3074706

    l_start_date DATE;
    l_finish_date DATE;
    l_last_update_date DATE;
    l_dummy VARCHAR2(1);
  BEGIN
    --Check if any children is a linking task.
    OPEN c3;
    FETCH c3 INTO l_dummy;
    IF c3%NOTFOUND THEN
      CLOSE c3;
      return;
    END IF;
    CLOSE c3;

    OPEN c1;
    FETCH c1 INTO l_start_date;
    CLOSE c1;

    OPEN c2;
    FETCH c2 INTO l_finish_date;
    CLOSE c2;

    OPEN c4;
    FETCH c4 INTO l_last_update_date;
    CLOSE c4;

    p_min_sch_start_date := l_start_date;
    p_max_sch_finish_date := l_finish_date;
    p_rollup_last_update_date := l_last_update_date;
  -- 4537865
  EXCEPTION
    WHEN OTHERS THEN
        p_min_sch_start_date := NULL ;
        p_rollup_last_update_date := NULL ;
        p_max_sch_finish_date := NULL ;

        fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                            p_procedure_name => 'Get_Rollup_Dates',
                    p_error_text => SUBSTRB(SQLERRM,1,240)
                    );
        RAISE ;
  END Get_Rollup_Dates;

-- API name                      : Get_Workplan_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_project_id                   IN   NUMBER
--   p_structure_version_id         OUT  DATE
--
--  History
--
--  10-MAY-02   HSIU             -Created
--  30-NOV-04   AVAITHIA         -3968091 : Performance Fix
  procedure Get_Workplan_Version
  (
    p_project_id               IN NUMBER
   ,p_structure_version_id    OUT NOCOPY NUMBER   -- 4537865
  )
  IS
    CURSOR c1 IS
    /* Commented the following query for Performance Bug fix : 3968091
      select c.element_version_id
        from pa_proj_element_versions c,
             pa_proj_elements b,
             pa_proj_structure_types a,
             pa_structure_types d
       where d.structure_type_class_code = 'WORKPLAN'
         and d.structure_type_id = a.structure_type_id
         and a.proj_element_id = b.proj_element_id
         and b.project_id = p_project_id
         and b.proj_element_id = c.proj_element_id
         and b.project_id = c.project_id
         and c.object_type = 'PA_STRUCTURES';
    */
       select c.element_version_id  /*New Query with improved Performance : 3968091 */
        from pa_proj_element_versions c,
             pa_proj_structure_types a,
             pa_structure_types d
       where d.structure_type_class_code = 'WORKPLAN'
         and d.structure_type_id = a.structure_type_id
         and a.proj_element_id = c.proj_element_id
         and c.project_id = p_project_id
         and c.object_type = 'PA_STRUCTURES';
  BEGIN

    OPEN c1;
    FETCH c1 INTO p_structure_version_id;
    IF c1%NOTFOUND THEN
      p_structure_version_id := -1;
    END IF;
    CLOSE c1;

-- 4537865
  EXCEPTION
    WHEN OTHERS THEN
        p_structure_version_id := NULL;

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'Get_Workplan_Version',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END Get_Workplan_Version;


-- API name                      : Get_Financial_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_project_id                   IN   NUMBER
--   p_structure_version_id         OUT  NUMBER
--
--  History
--
--  26-JAN-04   sdnambia             -Created
--  30-NOV-04   AVAITHIA             -3968091 : Performance Fix
--
  procedure Get_Financial_Version
  (
    p_project_id               IN NUMBER
   ,p_structure_version_id    OUT NOCOPY NUMBER -- 4537865
  )
  IS
    CURSOR c1 IS
      /*Commented the following Query for Performance Bug fix : 3968091
      select c.element_version_id
        from pa_proj_element_versions c,
             pa_proj_elements b,
             pa_proj_structure_types a,
             pa_structure_types d
       where d.structure_type_class_code = 'FINANCIAL'
         and d.structure_type_id = a.structure_type_id
         and a.proj_element_id = b.proj_element_id
         and b.project_id = p_project_id
         and b.proj_element_id = c.proj_element_id
         and b.project_id = c.project_id
         and c.object_type = 'PA_STRUCTURES';
       */
       select c.element_version_id  /*New Query with improved Performance : 3968091 */
        from pa_proj_element_versions c,
             pa_proj_structure_types a,
             pa_structure_types d
       where d.structure_type_class_code = 'FINANCIAL'
         and d.structure_type_id = a.structure_type_id
         and a.proj_element_id = c.proj_element_id
         and c.project_id = p_project_id
         and c.object_type = 'PA_STRUCTURES';
  BEGIN

    OPEN c1;
    FETCH c1 INTO p_structure_version_id;
    IF c1%NOTFOUND THEN
      p_structure_version_id := -1;
    END IF;
    CLOSE c1;
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                p_structure_version_id := NULL;

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'Get_Financial_Version',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END Get_Financial_Version;


-- API name                      : check_miss_transaction_tasks
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not missing any tasks with transactions
--                                 N if tasks with transactions are missing
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  24-MAY-01   HSIU             -Created
--
--
  PROCEDURE check_miss_transaction_tasks
  (
     p_structure_version_id              IN  NUMBER
    ,x_return_status                     OUT NOCOPY VARCHAR2
    ,x_msg_count                         OUT NOCOPY NUMBER
    ,x_msg_data                          OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR cur_proj_elem_ver(c_element_version_id NUMBER)
    IS
      SELECT project_id, proj_element_id
        FROM pa_proj_element_versions
       WHERE element_version_id = c_element_version_id;

    CURSOR get_latest_pub_ver IS
      select b.element_version_id
        from pa_proj_element_versions a,
             pa_proj_elem_ver_structure b
       where a.project_id = b.project_id
         and a.element_version_id = p_structure_version_id
         and a.proj_element_id = b.proj_element_id
         and b.LATEST_EFF_PUBLISHED_FLAG = 'Y'
         and b.status_code = 'STRUCTURE_PUBLISHED';

/* Bug 2680486 -- Performance changes -- Commented the following cursor definition. Restructured it to
                                        avoid  Hash Join*/

/*    CURSOR get_missing_tasks(c_struc_ver_id NUMBER, c_latest_struc_ver_id NUMBER) IS
      select project_id, element_version_id
        from pa_proj_element_versions
       where parent_structure_version_id = c_latest_struc_ver_id
         and proj_element_id IN (
      select proj_element_id
        from pa_proj_element_versions
       where parent_structure_version_id = c_latest_struc_ver_id
      minus
      select proj_element_id
        from pa_proj_element_versions
       where parent_structure_version_id = c_struc_ver_id);
*/
    CURSOR get_missing_tasks(c_struc_ver_id NUMBER, c_latest_struc_ver_id NUMBER) IS
      select a.project_id, a.element_version_id
        from pa_proj_element_versions a
       where a.parent_structure_version_id = c_latest_struc_ver_id
         and EXISTS (
      select b.proj_element_id
        from pa_proj_element_versions b
       where b.parent_structure_version_id = c_latest_struc_ver_id
       and   b.proj_element_id = a.proj_element_id
      minus
      select c.proj_element_id
        from pa_proj_element_versions c
       where c.parent_structure_version_id = c_struc_ver_id
       and   c.proj_element_id = a.proj_element_id);

    CURSOR get_task_name_num(c_project_id NUMBER, c_proj_element_id NUMBER) IS
      select name, element_number
      from pa_proj_elements
      where project_id = c_project_id
      and proj_element_id = c_proj_element_id;

    l_ret_stat              VARCHAR2(1);
    l_err_code              VARCHAR2(2000);
    l_err_stage             VARCHAR2(2000);
    l_err_stack             VARCHAR2(2000);
    l_elem_ver_id           NUMBER;
    l_latest_struc_ver_id   NUMBER;
    l_project_id            NUMBER;
    l_proj_element_id       NUMBER;
    l_elem_proj_id          NUMBER;
    l_task_name             PA_PROJ_ELEMENTS.NAME%TYPE;
    l_task_number           PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE;
  BEGIN
    --check if new structure version missing tasks with transactions
    OPEN get_latest_pub_ver;
    FETCH get_latest_pub_ver into l_latest_struc_ver_id;
    IF get_latest_pub_ver%FOUND THEN
      --a published structure exists. Check if missing tasks have transactions.
      OPEN get_missing_tasks(p_structure_version_id, l_latest_struc_ver_id);
      LOOP
        FETCH get_missing_tasks into l_elem_proj_id, l_elem_ver_id;
        EXIT WHEN get_missing_tasks%NOTFOUND;
        --check for transactions.

        OPEN cur_proj_elem_ver(l_elem_ver_id);
        FETCH cur_proj_elem_ver INTO l_project_id, l_proj_element_id;
        CLOSE cur_proj_elem_ver;

        --Check for control items
        IF (1 = PA_CONTROL_ITEMS_UTILS.CHECK_CONTROL_ITEM_EXISTS(l_project_id, l_proj_element_id) ) THEN
--          CLOSE get_missing_tasks;
--          CLOSE get_latest_pub_ver;
--          return 'N';
          OPEN get_task_name_num(l_project_id, l_proj_element_id);
          FETCH get_task_name_num into l_task_name, l_task_number;
          CLOSE get_task_name_num;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_MISS_TRANSAC_TASK',
                               'TASK_NAME', l_task_name,
                               'TASK_NUMBER', l_task_number);
          --Add error message to stack
        END IF;


        IF   PA_PROJ_ELEMENTS_UTILS.structure_type(
                 p_structure_version_id     => p_structure_version_id
                 ,p_task_version_id          => null
                 ,p_structure_type           => 'WORKPLAN'
                 ) = 'Y'
        THEN
         --call selvas API
           IF PA_PROJECT_STRUCTURE_UTILS.check_task_progress_exist(l_proj_element_id) = 'Y' THEN
--             CLOSE get_missing_tasks;
--             CLOSE get_latest_pub_ver;
--             return 'N';
             --Add error message to stack
          OPEN get_task_name_num(l_project_id, l_proj_element_id);
          FETCH get_task_name_num into l_task_name, l_task_number;
          CLOSE get_task_name_num;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_MISS_TRANSAC_TASK',
                               'TASK_NAME', l_task_name,
                               'TASK_NUMBER', l_task_number);
           END IF;

        END IF;

        IF PA_PROJ_ELEMENTS_UTILS.structure_type(
                 p_structure_version_id     => p_structure_version_id
                 ,p_task_version_id          => null
                 ,p_structure_type           => 'FINANCIAL'
                 ) = 'Y' THEN
        --Check if this is a financial structure version
         --if it is, check to see if it is the last version

          --Bug 2947492:The following api call is modified to pass parameters by notation.

             --Check if it is okay to delete task
             PA_TASK_UTILS.CHECK_DELETE_TASK_OK(
                              x_task_id      => l_proj_element_id,
                              x_err_code     => l_err_code,
                              x_err_stage    => l_err_stage,
                              x_err_stack    => l_err_stack);

             IF (l_err_code <> 0) THEN
--               CLOSE get_missing_tasks;
--               CLOSE get_latest_pub_ver;
--               return 'N';
               --Add error message to stack
               OPEN get_task_name_num(l_project_id, l_proj_element_id);
               FETCH get_task_name_num into l_task_name, l_task_number;
               CLOSE get_task_name_num;
               PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_MISS_TRANSAC_TASK',
                                    'TASK_NAME', l_task_name,
                                    'TASK_NUMBER', l_task_number);
             END IF;

        END IF;

      END LOOP;
      CLOSE get_missing_tasks;
    END IF;
    CLOSE get_latest_pub_ver;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --4537865
      x_msg_count := 1;
      x_msg_data := SQLERRM ;

      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'check_miss_transaction_tasks',
                  p_error_text => x_msg_data); -- 4537865
      RAISE;
  END check_miss_transaction_tasks;

-- API name                      : Get_Struc_Ver_Display_Text
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : display text for structure version dropdown
--                                 list
--
-- Parameters
--
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
--

  FUNCTION Get_Struc_Ver_Display_Text
  ( p_structure_version_name            IN VARCHAR2
   ,p_structure_version_number          IN VARCHAR2
   ,p_status                            IN VARCHAR2
   ,p_baseline_flag                     IN VARCHAR2
  ) return varchar2
  IS
    l_display_text VARCHAR2(2000);
  BEGIN
    IF (p_baseline_flag = 'Y') THEN
      fnd_message.set_name('PA', 'PA_PS_STRUC_INFO_POP_B');
    ELSE
      fnd_message.set_name('PA', 'PA_PS_STRUC_INFO_POP_NB');
    END IF;
    FND_MESSAGE.Set_token('STRUC_VER_NAME', p_structure_version_name);
    FND_MESSAGE.Set_token('STRUC_VER_NUM', p_structure_version_number);
    FND_MESSAGE.Set_token('STATUS', p_status);
    l_display_text := fnd_message.get;
    return l_display_text;
  END Get_Struc_Ver_Display_Text;


-- API name                      : CHECK_WORKPLAN_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if workplan is enabled
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_workplan_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
    SELECT 'Y'
    FROM pa_proj_elements a,
         pa_proj_structure_types b,
         pa_structure_types c
    WHERE c.structure_type_class_code = 'WORKPLAN'
    AND   c.structure_type_id = b.structure_type_id
    AND   b.proj_element_id = a.proj_element_id
    AND   a.project_id = p_project_id;

    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c1;
    return l_dummy;
  END check_workplan_enabled;


-- API name                      : CHECK_FINANCIAL_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if financial is enabled. Y if enabled,
--                                 N if not.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_financial_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
    SELECT 'Y'
    FROM pa_proj_elements a,
         pa_proj_structure_types b,
         pa_structure_types c
    WHERE c.structure_type_class_code = 'FINANCIAL'
    AND   c.structure_type_id = b.structure_type_id
    AND   b.proj_element_id = a.proj_element_id
    AND   a.project_id = p_project_id;

    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c1;
    return l_dummy;
  END check_financial_enabled;


-- API name                      : CHECK_SHARING_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if workplan and financial
--                                 are sharing 1 structure. Y if shared,
--                                 N if not.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_sharing_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
    SELECT 'Y'
    FROM pa_proj_elements a,
         pa_proj_structure_types b,
         pa_structure_types c,
         pa_proj_structure_types d,
         pa_structure_types e
    WHERE c.structure_type_class_code = 'WORKPLAN'
    AND   e.structure_type_class_code = 'FINANCIAL'
    AND   c.structure_type_id = b.structure_type_id
    AND   e.structure_type_id = d.structure_type_id
    AND   b.proj_element_id = a.proj_element_id
    AND   d.proj_element_id = a.proj_element_id
    AND   a.project_id = p_project_id;

    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c1;
    return l_dummy;
  END check_sharing_enabled;


-- API name                      : CHECK_ENABLE_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to enable workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_enable_wp_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2  -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2  -- 4537865
  )
  IS
    CURSOR get_calendar_id IS
      select CALENDAR_ID
        from pa_projects_all
       where project_id = p_project_id;
    l_cal_id   NUMBER;

    CURSOR get_hrs_per_day IS
      select FTE_DAY
        from pa_implementations;
    l_hrs_per_day  NUMBER;
  BEGIN
    --check if calendar is available
    OPEN get_calendar_id;
    FETCH get_calendar_id INTO l_cal_id;
    CLOSE get_calendar_id;

    IF (l_cal_id IS NULL) THEN
      x_err_msg_code := 'PA_PS_NO_CALENDAR_ERR';
      x_return_status := 'N';
      return;
    END IF;

    OPEN get_hrs_per_day;
    FETCH get_hrs_per_day into l_hrs_per_day;
    CLOSE get_hrs_per_day;

    IF (l_hrs_per_day IS NULL) OR (l_hrs_per_day = 0) THEN
      x_err_msg_code := 'PA_PS_INV_HRS_PER_DAY';
      x_return_status := 'N';
      return;
    END IF;

    x_return_status := 'Y';
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
        x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_enable_wp_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_enable_wp_ok;


-- API name                      : CHECK_DISABLE_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to disable workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  Procedure check_disable_wp_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    l_structure_id NUMBER;
     --Bug No 3692992 Performance fix
/*    CURSOR get_tasks IS
      SELECT proj_element_id
        from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_TASKS'
         and proj_element_id IN (
             select distinct ppev1.proj_element_id
               from pa_proj_element_versions ppev1,
                    pa_proj_element_versions ppev2
              where ppev2.object_type = 'PA_STRUCTURES'
                and ppev2.project_id = p_project_id
                and ppev2.proj_element_id = l_structure_id
                and ppev1.parent_structure_version_id = ppev2.element_version_id);*/

    CURSOR get_tasks IS
    select distinct ppev1.proj_element_id
      from pa_proj_element_versions ppev1,
           pa_proj_element_versions ppev2
     where ppev2.object_type = 'PA_STRUCTURES'
       and ppev2.project_id = p_project_id
       and ppev2.proj_element_id = l_structure_id
       and ppev1.object_type = 'PA_TASKS'
       and ppev1.parent_structure_version_id = ppev2.element_version_id;

    l_task_id NUMBER;

    CURSOR get_wp_id IS
      SELECT ppe.proj_element_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN';
  BEGIN
    OPEN get_wp_id;
    FETCH get_wp_id into l_structure_id;
    CLOSE get_wp_id;
    --check progress for project and all tasks
    IF (check_proj_progress_exist(p_project_id, l_structure_id,'WORKPLAN') = 'Y') THEN -- Bug 6914708
      x_return_status := 'N';
      x_err_msg_code := 'PA_PS_PROJ_PROGRESS_ERR';
      return;
    END IF;

    OPEN get_tasks;
    LOOP
      FETCH get_tasks into l_task_id;
      EXIT when get_tasks%NOTFOUND;
      IF (check_task_progress_exist(l_task_id) = 'Y') THEN
        CLOSE get_tasks;
        x_return_status := 'N';
        x_err_msg_code := 'PA_PS_TASK_PROGRESS_ERR';
        return;
      END IF;
    END LOOP;
    CLOSE get_tasks;

    x_return_status := 'Y';
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
                x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_disable_wp_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_disable_wp_ok;


-- API name                      : CHECK_SHARING_ON_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to share workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_sharing_on_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    CURSOR get_tasks IS
      SELECT proj_element_id
        from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_TASKS'
         and proj_element_id NOT IN (
             select task_id
               from PA_TASKS
              where project_id = p_project_id);
    l_task_id NUMBER;

    CURSOR get_wp_id IS
      SELECT ppe.proj_element_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN';
    l_structure_id NUMBER;
  BEGIN
    --check if progress exists for structure
    OPEN get_wp_id;
    FETCH get_wp_id into l_structure_id;
    CLOSE get_wp_id;
    IF (check_proj_progress_exist(p_project_id, l_structure_id) = 'Y') THEN
      x_return_status := 'N';
      x_err_msg_code := 'PA_PS_PROJ_PROGRESS_ERR';
      return;
    END IF;

--bug 2805602
--hsiu: commented out because this is covered in check_del_all_task_ver_ok
--      when enabling sharing.
--    OPEN get_tasks;
--    LOOP
--      FETCH get_tasks into l_task_id;
--      EXIT when get_tasks%NOTFOUND;
--      IF (check_task_progress_exist(l_task_id) = 'Y') THEN
--        CLOSE get_tasks;
--        x_return_status := 'N';
--        x_err_msg_code := 'PA_PS_TASK_PROGRESS_ERR';
--        return;
--      END IF;
--    END LOOP;
--    CLOSE get_tasks;

    x_return_status := 'Y';
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
                x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_sharing_on_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_sharing_on_ok;

-- API name                      : CHECK_SHARING_OFF_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to split workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_sharing_off_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    CURSOR get_tasks IS
      SELECT proj_element_id
        from pa_proj_elements
       where project_id = p_project_id
         and object_type = 'PA_TASKS';
    l_task_id NUMBER;
  BEGIN
    --check if progress exists for current structure
    IF (check_proj_progress_exist(p_project_id, 0) = 'Y') THEN
      x_err_msg_code := 'PA_PS_PROJ_PROGRESS_ERR';
      x_return_status := 'N';
      return;
    END IF;

    OPEN get_tasks;
    LOOP
      FETCH get_tasks into l_task_id;
      EXIT when get_tasks%NOTFOUND;
      IF (check_task_progress_exist(l_task_id) = 'Y') THEN
        CLOSE get_tasks;
        x_err_msg_code := 'PA_PS_TASK_PROGRESS_ERR';
        x_return_status := 'N';
        return;
      END IF;
    END LOOP;
    CLOSE get_tasks;

    x_return_status := 'Y';
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
                x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_sharing_off_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_sharing_off_ok;


-- API name                      : CHECK_PROJ_PROGRESS_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for project
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_proj_progress_exist
  (  p_project_id IN NUMBER
    ,p_structure_id IN NUMBER
    ,p_structure_type IN VARCHAR2 := null
  ) return VARCHAR2
  IS
  BEGIN
    --get API from Saima
    IF (p_structure_type = 'WORKPLAN')
 	  THEN
      return PA_PROGRESS_UTILS.check_project_has_progress(p_project_id, p_structure_id,'WORKPLAN'); -- Added for the BUG 6914708
    ELSE
      return PA_PROGRESS_UTILS.check_project_has_progress(p_project_id, p_structure_id);
 	  END IF;
  END check_proj_progress_exist;


-- API name                      : CHECK_TASK_PROGRESS_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for task
--                                 Return Y or N
--
-- Parameters
--  p_task_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
--  05-APR-2004 Rakesh Raghavan  Progress Management Changes. Bug # 3420093.
--
  FUNCTION check_task_progress_exist
  (  p_task_id IN NUMBER
  ) return VARCHAR2
  IS
  -- Progress Management Changes. Bug # 3420093.
    l_project_id NUMBER;
  -- Progress Management Changes. Bug # 3420093.

 -- Bug 3933576 : Added cursor c_get_project_id
  CURSOR c_get_project_id IS
  SELECT project_id
  FROM pa_proj_elements
  where proj_element_id = p_task_id;

  BEGIN
    --get API from Saima

    -- Progress Management Changes. Bug # 3420093.
    -- Bug 3933576 : Call pa_proj_tsk_utils.get_task_project_id gives the project_id from pa_tasks
    -- It is wrong..
    --l_project_id := pa_proj_tsk_utils.get_task_project_id(p_task_id);
    OPEN c_get_project_id;
    FETCH c_get_project_id INTO l_project_id;
    CLOSE c_get_project_id;

    return (pa_progress_utils.check_object_has_prog(p_project_id => l_project_id
                                                     -- ,p_proj_element_id => p_task_id));
                                                    ,p_object_id => p_task_id));

    -- Progress Management Changes. Bug # 3420093.

  END check_task_progress_exist;

-- API name                      : GET_LAST_UPDATED_WORKING_VER
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Return last update working structure
--                                 version id
--
-- Parameters
--  p_proj_element_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LAST_UPDATED_WORKING_VER
  (  p_structure_id IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      select str.element_version_id
        from pa_proj_elem_ver_structure str,
             pa_proj_elements ppe
       where ppe.proj_element_id = p_structure_id
         and ppe.project_id = str.project_id
         and ppe.proj_element_id = str.proj_element_id
         and str.CURRENT_WORKING_FLAG = 'Y';
/*
    CURSOR c1 IS
      SELECT MAX(a.last_update_date), b.parent_structure_version_id
        FROM pa_proj_element_versions b,
             pa_proj_elem_ver_schedule a,
             pa_proj_elem_ver_structure c
       WHERE a.element_version_id (+)= b.element_version_id
         AND a.project_id (+) = b.project_id
         AND a.proj_element_id (+) = b.proj_element_id
         AND b.parent_structure_version_id = c.element_version_id
         AND b.project_id = c.project_id
         AND c.status_code <> 'STRUCTURE_PUBLISHED'
         AND b.proj_element_id = p_structure_id
    GROUP BY b.parent_structure_version_id
    ORDER BY MAX(a.last_update_date) desc;
*/
    l_date                 DATE;
    l_structure_version_id NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_structure_version_id;
--    FETCH c1 into l_date, l_structure_version_id;
    CLOSE c1;
    return l_structure_version_id;
  END GET_LAST_UPDATED_WORKING_VER;


-- API name                      : CHECK_VERSIONING_ON_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to version workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_versioning_on_ok
  (  p_proj_element_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
  BEGIN
    x_return_status := 'Y';
-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
                x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_versioning_on_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_versioning_on_ok;

-- API name                      : CHECK_VERSIONING_OFF_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to turn off workplan
--                                 versioning
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_versioning_off_ok
  (  p_proj_element_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 -- 4537865
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    CURSOR get_project_id IS
    SELECT project_id
    FROM PA_PROJ_ELEMENTS
    WHERE proj_element_id = p_proj_element_id;

    l_project_id   NUMBER;
  BEGIN
    OPEN get_project_id;
    FETCH get_project_id INTO l_project_id;
    CLOSE get_project_id;

    if PA_PROGRESS_UTILS.PROJ_TASK_PROG_EXISTS( l_project_id, 0 ) = 'Y' then
      x_return_status := 'N';
      x_err_msg_code := 'PA_PS_CANT_DIS_VER';
    else
      x_return_status := 'Y';
    end if;

-- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_err_msg_code := SQLCODE;
                x_return_status := 'N'; -- Based on Usage of this API

                fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                                        p_procedure_name => 'check_versioning_off_ok',
                                        p_error_text => SUBSTRB(SQLERRM,1,240)
                                        );
                RAISE ;
  END check_versioning_off_ok;


-- API name                      : CHECK_FIN_TASK_PROG_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for financial task
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_fin_task_prog_exist
  (  p_project_id IN NUMBER
  ) return VARCHAR2
  IS

/* Bug 2680486 -- Performance changes -- Commented the following cursor definition. Restructured it to
                                        avoid  Hash Join*/

/*    CURSOR c1 is
      select 1
        from pa_tasks a,
             pa_percent_completes b
       where b.project_id = a.project_id
         and b.task_id = a.task_id
         and a.project_id = p_project_id;
*/

    CURSOR c1 is
       select 1
         from dual
         where exists
           ( select 1
             from pa_tasks a,
                  pa_percent_completes b
             where b.project_id = a.project_id
               and b.task_id = a.task_id
               and a.project_id = p_project_id
           );

    l_dummy NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 INTO l_dummy;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    ELSE
      CLOSE c1;
      return 'Y';
    END IF;
  END check_fin_task_prog_exist;


-- API name                      : CHECK_WORKING_VERSION_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if working version exists for
--                                 workplan structure
--                                 Return Y or N
--
-- Parameters
--  p_proj_element_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_working_version_exist
  (  p_proj_element_id IN NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
      select 1
        from pa_proj_elements a,
             pa_proj_elem_ver_structure b
       where a.proj_element_id = p_proj_element_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.status_code <> 'STRUCTURE_PUBLISHED';
    l_dummy NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    ELSE
      CLOSE c1;
      return 'Y';
    END IF;
  END check_working_version_exist;


-- API name                      : CHECK_EDIT_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if the workplan structure version
--                                 can be edited
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_edit_wp_ok
  (  p_project_id IN NUMBER
    ,p_structure_version_id IN NUMBER
  ) return VARCHAR2
  IS
    l_published VARCHAR2(1);
    l_versioned VARCHAR2(1);
  BEGIN
    l_published := PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                                                  p_project_id,
                                                  p_structure_version_id);
    l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                  p_project_id);
    IF (l_published = 'Y' and l_versioned = 'Y') THEN
      return 'N';
    ELSE
      return 'Y';
    END IF;
  END check_edit_wp_ok;

-- API name                      : CHECK_EDIT_FIN_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if the financial structure version
--                                 can be edited
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_edit_fin_ok
  (  p_project_id IN NUMBER
    ,p_structure_version_id IN NUMBER
  ) return VARCHAR2
  IS
    l_published VARCHAR2(1);
    l_versioned VARCHAR2(1);
    l_shared    VARCHAR2(1);
  BEGIN
    l_published := PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(
                                                  p_project_id,
                                                  p_structure_version_id);
    l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                  p_project_id);

    l_shared    := PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(
                                                  p_project_id);

    IF (l_shared = 'Y' AND l_published = 'N' AND l_versioned = 'Y') THEN
      return 'N';
    ELSE
      return 'Y';
    END IF;
  END check_edit_fin_ok;



-- API name                      : GET_FIN_STRUCTURE_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the financial structure id
--                                 Return structure id for the financial
--                                 structure
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_FIN_STRUCTURE_ID
  ( p_project_id IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      select ppe.proj_element_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'FINANCIAL';
    l_structure_id NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_structure_id;
    CLOSE c1;
    return l_structure_id;
  END GET_FIN_STRUCTURE_ID;

-- API name                      : GET_LATEST_FIN_STRUC_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the latest financial structure version
--                                 id.  Return structure version id for the
--                                 latest financial structure version. Return
--                                 NULL if no published version exists.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LATEST_FIN_STRUC_VER_ID
  ( p_project_id IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      select ppevs.element_version_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppe.project_id = ppevs.project_id
         and ppe.proj_element_id = ppevs.proj_element_id
         and ppevs.status_code = 'STRUCTURE_PUBLISHED'
	 /* Commented for Bug 4998101
         and ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'*/
         and ppst.structure_type_id = pst.structure_type_id
--	 and ppevs.process_code is null   -- Added for Bug Bug 4998101
         and ( ppevs.process_code is null or ppevs.process_code = 'PRE') -- Added for Bug #5659575
         and pst.structure_type_class_code = 'FINANCIAL'
	 order by ppevs.published_date desc;  -- Added for Bug Bug 4998101
    l_structure_version_id NUMBER;

    CURSOR c2 IS
      select ppevs.element_version_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppe.project_id = ppevs.project_id
         and ppe.proj_element_id = ppevs.proj_element_id
         and ppevs.status_code <> 'STRUCTURE_PUBLISHED'
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'FINANCIAL';

  BEGIN
    OPEN c1;
    FETCH c1 into l_structure_version_id;
    IF c1%NOTFOUND THEN
      OPEN c2;
      FETCH c2 into l_structure_version_id;
      CLOSE c2;
    END IF;
    CLOSE c1;

    return l_structure_version_id;

  END GET_LATEST_FIN_STRUC_VER_ID;

-- API name                      : GET_LATEST_FIN_STRUC_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'FINANCIAL' for a financial only task or
--                                 structure, 'WORKPLAN' for a workplan only
--                                 or shared structure.
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_proj_element_id           IN NUMBER
--  p_object_type               IN VARCHAR2
--
--  History
--
--  23-OCT-02   HSIU             -Created
  FUNCTION get_element_struc_type
  ( p_project_id       IN NUMBER
   ,p_proj_element_id  IN NUMBER
   ,p_object_type      IN VARCHAR2
  ) return VARCHAR2
  IS
    CURSOR get_parent_structure IS
      select a.proj_element_id
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where b.proj_element_id = p_proj_element_id
         and b.project_id = p_project_id
         and b.parent_structure_version_id = a.element_version_id
         and a.project_id = p_project_id;
    l_structure_id  NUMBER;
    l_ret           VARCHAR2(30);
  BEGIN
    --Find structure
    IF (p_object_type = 'PA_TASKS') THEN
      OPEN get_parent_structure;
      FETCH get_parent_structure into l_structure_id;
      CLOSE get_parent_structure;
    ELSE --'PA_STRUCTURES'
      l_structure_id := p_proj_element_id;
    END IF;

    --Get Type
    IF ('Y' = Get_Struc_Type_For_Structure(l_structure_id, 'WORKPLAN')) THEN
      l_ret := 'WORKPLAN';
    ELSE
      l_ret := 'FINANCIAL';
    END IF;
    return l_ret;
  END get_element_struc_type;


  FUNCTION GET_LATEST_WP_VERSION
  ( p_project_id IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      select ppevs.element_version_id
        from pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       where ppe.project_id = p_project_id
         and ppe.proj_element_id = ppst.proj_element_id
         and ppe.project_id = ppevs.project_id
         and ppe.proj_element_id = ppevs.proj_element_id
         and ppevs.status_code = 'STRUCTURE_PUBLISHED'
         and ppevs.LATEST_EFF_PUBLISHED_FLAG = 'Y'
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN';
    l_structure_version_id NUMBER;

  BEGIN
    OPEN c1;
    FETCH c1 into l_structure_version_id;
    CLOSE c1;
    return l_structure_version_id;

  END GET_LATEST_WP_VERSION;


-- API name                      : Check_del_work_struc_ver_ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to delete working structure
--                                 version
--                                 Return Y or N
--
-- Parameters
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_del_work_struc_ver_ok
  ( p_structure_version_id IN NUMBER
  ) return VARCHAR2
  IS
    l_project_id      NUMBER;
    l_structure_id    NUMBER;
    l_count           NUMBER;

    CURSOR c1 IS
      select project_id, proj_element_id
      from pa_proj_element_versions
      where element_version_id = p_structure_version_id;

    CURSOR c2 IS
      select count(1)
      from pa_proj_elem_ver_structure
      where project_Id = l_project_id
      and proj_element_id = l_structure_id
      and status_code <> 'STRUCTURE_PUBLISHED';

  BEGIN
    OPEN c1;
    FETCH c1 into l_project_id, l_structure_id;
    CLOSE c1;

    IF ('N' = pa_project_structure_utils.check_published_ver_exists(l_project_id, l_structure_id)) THEN
      OPEN c2;
      FETCH c2 into l_count;
      CLOSE c2;

      IF (l_count = 1) THEN
        return 'N';
      END IF;
    ELSE
      return 'Y';
    END IF;
    return 'Y';
  END check_del_work_struc_ver_ok;


-- API name                      : Check_txn_on_summary_tasks
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if transactions exist on summary task
--                                 N if not
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  24-MAY-01   HSIU             -Created
--
--
  PROCEDURE Check_txn_on_summary_tasks
  (
    p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_msg_count                         OUT NOCOPY NUMBER
   ,x_msg_data                          OUT NOCOPY VARCHAR2
  )
  IS
    --cursor to select summary tasks
    CURSOR c1 IS
      select ppev.proj_element_id, ppev.element_version_id
        from pa_proj_element_versions ppev,
             pa_object_relationships por
       where ppev.parent_structure_version_id = p_structure_version_id
         and ppev.object_type = 'PA_TASKS'
         and ppev.element_version_id = por.object_id_from1
         and ppev.object_type = por.object_type_from
         and por.relationship_type = 'S';
    l_workplan   VARCHAR2(1);
    l_financial  VARCHAR2(1);
    l_err_code   VARCHAR2(2000);
    l_err_stage  VARCHAR2(2000);
    l_err_stack  VARCHAR2(2000);
    l_proj_element_id  NUMBER;
    l_element_version_id  NUMBER;

--bug 4068736
    CURSOR c2(c_task_ver_id number) IS
      select 1
        from pa_proj_element_versions ppev,
             pa_object_relationships por
       where por.object_id_from1 = c_task_ver_id
         and por.relationship_type = 'S'
         and por.object_id_to1 = ppev.element_version_id
         and ppev.financial_task_flag = 'Y'
         and rownum = 1;
--bug 4068736

    CURSOR get_task_name_num(c_proj_element_id NUMBER) IS
      select name, element_number
      from pa_proj_elements
      where proj_element_id = c_proj_element_id;
    l_task_name             PA_PROJ_ELEMENTS.NAME%TYPE;
    l_task_number           PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE;
    l_message_text          VARCHAR2(2000);

    l_dummy                 NUMBER;
  BEGIN
    l_workplan := Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
    l_financial := Get_Struc_Type_For_Version(p_structure_version_id, 'FINANCIAL');

    OPEN c1;
    LOOP
      FETCH c1 into l_proj_element_id, l_element_version_id;
      EXIT WHEN c1%NOTFOUND;

--removed for bug 2740802
--summary task can have progress transactions
--      IF (l_workplan = 'Y') THEN
        --check for progress
--        IF pa_project_structure_utils.check_task_progress_exist(l_proj_element_id) = 'Y' THEN
--          l_message_text := FND_MESSAGE.GET_STRING('PA','PA_PS_TASK_HAS_PROG');
--          OPEN get_task_name_num(l_proj_element_id);
--          FETCH get_task_name_num into l_task_name, l_task_number;
--          CLOSE get_task_name_num;
--          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NAME_NUM_ERR',
--                               'TASK_NAME', l_task_name,
--                               'TASK_NUMBER', l_task_number,
--                               'MESSAGE', l_message_text);
--        END IF;
--      END IF;

      IF (l_financial = 'Y') THEN
        --hsiu: changes for bug 2817687
        BEGIN
          select 1 into l_dummy
          from pa_tasks where task_id = l_proj_element_id;

          --bug 4068736
          OPEN c2(l_element_version_id);
          fetch c2 into l_dummy;
          IF c2%FOUND THEN
            --Bug 2947492:The following api call is modified to pass parameters by notation.
            PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(
                                x_task_id     => l_proj_element_id,
                                x_err_code    => l_err_code,
                                x_err_stage   => l_err_stage,
                                x_err_stack   => l_err_stack);

            IF (l_err_code <> 0) THEN
              l_message_text := FND_MESSAGE.GET_STRING('PA',l_err_stage);
              OPEN get_task_name_num(l_proj_element_id);
              FETCH get_task_name_num into l_task_name, l_task_number;
              CLOSE get_task_name_num;
              PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_TASK_NAME_NUM_ERR',
                                 'TASK_NAME', l_task_name,
                                 'TASK_NUMBER', l_task_number,
                                 'MESSAGE', l_message_text);
            END IF;
          END IF;
          CLOSE c2;
          --bug 4068736
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            NULL;
        END; --for bug 2817687
      END IF;
    END LOOP;
    CLOSE c1;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg; -- 4537865
      x_msg_data := l_message_text ; -- 4537865

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;  -- 4537865
      x_msg_data := SQLERRM ;  -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'Check_txn_on_summary_tasks',
                  p_error_text => x_msg_data);  -- 4537865
      RAISE;
  END Check_txn_on_summary_tasks;


  PROCEDURE check_tasks_statuses_valid
  (
    p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_msg_count                         OUT NOCOPY NUMBER
   ,x_msg_data                          OUT NOCOPY VARCHAR2
  )
  IS
    CURSOR c1 IS
      select ppev.proj_element_id, ppev.element_version_id
        from pa_proj_element_versions ppev,
             pa_object_relationships por
       where ppev.parent_structure_version_id = p_structure_version_id
         and ppev.object_type = 'PA_TASKS'
         and ppev.element_version_id = por.object_id_from1
         and ppev.object_type = por.object_type_from
         and por.relationship_type = 'S';
    l_proj_element_id     NUMBER;
    l_element_version_id  NUMBER;

    CURSOR c2(c_proj_element_id NUMBER) IS
      select pps.project_system_status_code
        from pa_project_statuses pps,
             pa_proj_elements ppe
       where ppe.proj_element_id = c_proj_element_id
         and ppe.status_code = pps.project_status_code
         and pps.status_type = 'TASK'
         and pps.project_system_status_code = 'CANCELLED';

    CURSOR c3(c_parent_task_ver_id NUMBER) IS
      select pps.project_system_status_code
        from pa_project_statuses pps,
             pa_proj_elements ppe,
             pa_proj_element_versions ppev,
             pa_object_relationships por
       where por.object_id_from1 = c_parent_task_ver_id
         and por.object_type_from = 'PA_TASKS'
         and por.relationship_type = 'S'
         and por.object_type_to = 'PA_TASKS'
         and por.object_id_to1 = ppev.element_version_id
         and ppev.project_id = ppe.project_id
         and ppev.proj_element_id = ppe.proj_element_id
         and ppev.object_type = ppe.object_type
         and ppe.status_code = pps.project_status_code
         and pps.status_type = 'TASK'
         and pps.project_system_status_code NOT IN ('CANCELLED','COMPLETED')
         and ppev.TASK_UNPUB_VER_STATUS_CODE = 'TO_BE_DELETED';
    l_system_status_code   pa_project_statuses.project_system_status_code%TYPE;

    CURSOR get_task_name_num(c_proj_element_id NUMBER) IS
      select name, element_number
      from pa_proj_elements
      where proj_element_id = c_proj_element_id;
    l_task_name             PA_PROJ_ELEMENTS.NAME%TYPE;
    l_task_number           PA_PROJ_ELEMENTS.ELEMENT_NUMBER%TYPE;

  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 into l_proj_element_id, l_element_version_id;
      EXIT when c1%NOTFOUND;
      --if summary task exists, check if status is contsistent with child tasks
      OPEN c2(l_proj_element_id);
      FETCH c2 INTO l_system_status_code;
      IF c2%FOUND THEN
        --if any task is found, that means the statuses between
        --parent and child can be inconsistent. Check child statuses
        OPEN c3(l_element_version_id);
        FETCH c3 into l_system_status_code;
        IF (c3%FOUND) THEN
          --inconsistent statuses. Error
--          x_error_message_code := 'PA_PS_PUB_TK_STATS_ERR';
--          raise FND_API.G_EXC_ERROR;
          OPEN get_task_name_num(l_proj_element_id);
          FETCH get_task_name_num into l_task_name, l_task_number;
          CLOSE get_task_name_num;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_PUB_TK_STATS_ERR',
                               'TASK_NAME', l_task_name,
                               'TASK_NUMBER', l_task_number);
        END IF;
        CLOSE c3;
      END IF;
      CLOSE c2;
    END LOOP;
    CLOSE c1;

    x_msg_count := FND_MSG_PUB.count_msg;
    IF (x_msg_count > 0) THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg; -- 4537865
      x_msg_data := 'PA_PS_PUB_TK_STATS_ERR'; -- 4537865

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;  -- 4537865
      x_msg_data := SQLERRM ;  -- 4537865
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_UTILS',
                              p_procedure_name => 'Check_tasks_statuses_valid',
                  p_error_text  => x_msg_data ); -- 4537865
      RAISE;
  END check_tasks_statuses_valid;


-- API name                      : get_unpub_version_count
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : number of unpublished structure versions
-- Parameters
--   p_project_id                   IN      NUMBER
--   p_structure_id                 IN      NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function get_unpub_version_count
  (
    p_project_id                        IN  NUMBER
   ,p_structure_ver_id                  IN  NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      select count(1)
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and proj_element_id =
         (select proj_element_id
            from pa_proj_element_versions
           where element_version_id = p_structure_ver_id)
         and status_code <> 'STRUCTURE_PUBLISHED';
    l_cnt   NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_cnt;
    CLOSE c1;
    return l_cnt;
  END get_unpub_version_count;

-- API name                      : get_structrue_version_status
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the status of a structure version
-- Parameters
--   p_project_id                   IN      NUMBER
--   p_structure_version_id         IN      NUMBER
--
--  History
--
--  08-JAN-03   maansari             -Created
--
--


  function get_structrue_version_status
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
  ) return VARCHAR2 IS

    CURSOR cur_pa_proj_elem_ver_str
    IS
     SELECT  status_code
       FROM  pa_proj_elem_ver_structure
      WHERE  project_id = p_project_id
        AND  element_version_id = p_structure_version_id;
    l_str_status_code  VARCHAR2(150);
BEGIN

     OPEN cur_pa_proj_elem_ver_str;
     FETCH cur_pa_proj_elem_ver_str INTO l_str_status_code;
     CLOSE cur_pa_proj_elem_ver_str;

     RETURN l_str_status_code;
END get_structrue_version_status;


  function is_structure_version_updatable
  (
    p_structure_version_id              IN  NUMBER
  ) return VARCHAR2 IS
    cursor c1 IS
      select ppa.project_id, ppa.template_flag
        from pa_projects_all ppa,
             pa_proj_element_versions ppev
       where ppev.element_version_id = p_structure_version_id
         and ppev.project_id = ppa.project_id;
    l_project_id NUMBER;
    l_template_flag VARCHAR2(1);

    cursor c2 IS
      select 1
        from pa_proj_elem_ver_structure
       where project_id = l_project_id
         and element_version_id = p_structure_version_id
         and status_code = 'STRUCTURE_WORKING';
    l_dummy NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_project_id, l_template_flag;
    CLOSE c1;

    IF l_template_flag = 'Y' THEN
      return 'Y';
    END IF;

    --check if shared or split
    IF (PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(l_project_id) = 'Y')
    THEN
      --shared; check structure version status
      IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id) = 'Y')
      THEN
        --versioning enabled. Check structure version status
        OPEN c2;
        FETCH c2 into l_dummy;
        CLOSE c2;

        IF (l_dummy = 1) THEN
          --found; check if locked by another user
          IF (IS_STRUC_VER_LOCKED_BY_USER(FND_GLOBAL.USER_ID,
             p_structure_version_id) = 'O') THEN
            --added for bug 3071008
            IF (PA_SECURITY_PVT.check_user_privilege('PA_UNLOCK_ANY_STRUCTURE'
                                             ,NULL
                                             ,to_number(NULL))
                = FND_API.G_TRUE) THEN
              return 'Y';
            END IF;
            --end bug 3071008
            return 'N';
          ELSE
            return 'Y';
          END IF;
        ELSE
          --not found; not a working version
          return 'N';
        END IF;
      ELSE
        --versioning disabled
        return 'Y';
      END IF;
    ELSE
      --split; check structure type
      IF (GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id, 'FINANCIAL') = 'Y') THEN
        --split financial; ok to edit
        return 'Y';
      ELSE
        --split workplan; check versioning
        IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id) = 'Y')
        THEN
          --versioning enabled. Check structure version status
          OPEN c2;
          FETCH c2 into l_dummy;
          CLOSE c2;
          IF (l_dummy = 1) THEN
            --found; check if locked by another user
            IF (IS_STRUC_VER_LOCKED_BY_USER(FND_GLOBAL.USER_ID,
                p_structure_version_id) = 'O') THEN
              --added for bug 3071008
              IF (PA_SECURITY_PVT.check_user_privilege('PA_UNLOCK_ANY_STRUCTURE'
                                             ,NULL
                                             ,to_number(NULL))
                  = FND_API.G_TRUE) THEN
                return 'Y';
              END IF;
              --end bug 3071008
              return 'N';
            ELSE
              return 'Y';
            END IF;
          ELSE
            --not found; not working ver
            return 'N';
          END IF;
        ELSE
          --versioning disabled
          return 'Y';
        END IF;

      END IF;
    END IF;

  END is_structure_version_updatable;

-- Bug 3010538
-- This function will return the process_update_wbs_flag of the structure version.
FUNCTION GET_UPDATE_WBS_FLAG(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE
)
return VARCHAR2 IS
     -- This cursor gets the process_update_wbs_flag for the structure version.
     cursor cur_update_wbs_flag(c_project_id pa_projects_all.project_id%TYPE,
                                c_structure_version_id pa_proj_element_versions.element_version_id%TYPE)
     IS
          select process_update_wbs_flag
          from pa_proj_elem_ver_structure
          where project_id = c_project_id
          and element_version_id = c_structure_version_id;

     l_update_wbs_flag   pa_proj_elem_ver_structure.process_update_wbs_flag%TYPE;
BEGIN
     OPEN cur_update_wbs_flag(p_project_id,p_structure_version_id);
     fetch cur_update_wbs_flag into l_update_wbs_flag;
     close cur_update_wbs_flag;
     return nvl(l_update_wbs_flag,'N');
END GET_UPDATE_WBS_FLAG;


-- Bug 3010538
-- This is a function that returns the status of the cocurrent program for any
-- particular structure version. If the process code is null, the function returns
-- null and the caller has to do suitable null handling.
FUNCTION GET_PROCESS_STATUS_CODE(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE
)
return VARCHAR2 IS
     -- This cursor fetches the process code for the structure version.
     cursor cur_process_code(c_project_id pa_projects_all.project_id%TYPE,
                             c_structure_version_id pa_proj_element_versions.element_version_id%TYPE)
     is
          select process_code
          from pa_proj_elem_ver_structure
          where project_id = c_project_id
          and   element_version_id = c_structure_version_id;
     l_process_code pa_proj_elem_ver_structure.process_code%TYPE;
BEGIN
     open cur_process_code(p_project_id,p_structure_version_id);
     fetch cur_process_code into l_process_code;
     close cur_process_code;
     return l_process_code;
END GET_PROCESS_STATUS_CODE;


-- Bug 3010538
-- This API will be used to determine from the profile vaues if we need to do concurrent
-- processing or online processing. The function returns ONLINE if the process has to be
-- launched online or CONCURRENT if the process is to be launched as a concurrent process.
FUNCTION GET_PROCESS_WBS_UPDATES_OPTION(
     p_task_count            IN  NUMBER
    ,p_project_id            IN  NUMBER  default null     --bug 4370533
)
return VARCHAR2 IS

     l_wbs_update_option  fnd_lookups.meaning%TYPE;
     l_threshold_task_cnt number;

 CURSOR cur_link_exists
 IS
    Select 'x' from pa_object_relationships
     where relationship_type = 'LW'
       and (object_id_from2 = p_project_id or object_id_to2 = p_project_id);

 l_dummy_link_char VARCHAR2(1);

-- Begin Bug # 4611527.
 CURSOR cur_del_lnk_event
 IS
   SELECT 1
    FROM dual
    WHERE EXISTS (SELECT LOG.event_id
             FROM pji_pa_proj_events_log LOG,
                  pa_proj_element_versions ver
            WHERE LOG.event_type='PRG_CHANGE'
             AND LOG.event_object =TO_CHAR(ver.prg_group)
             AND ver.project_id=p_project_id
              UNION ALL
            SELECT LOG.event_id
              FROM pa_pji_proj_events_log LOG,
                   pa_proj_element_versions ver
             WHERE LOG.event_type='PRG_CHANGE'
               AND LOG.event_object =TO_CHAR(ver.prg_group)
               AND ver.project_id=p_project_id);
 -- End Bug # 4611527.

BEGIN

     IF p_project_id IS NOT NULL
     THEN
        OPEN cur_link_exists;
        FETCH cur_link_exists INTO l_dummy_link_char;
        IF cur_link_exists%FOUND
        THEN
	    close cur_link_exists; -- Bug#6678573
            return 'CONCURRENT';
        END IF;
	close cur_link_exists; -- Bug#6678573

        -- Begin Bug # 4611527.
        OPEN  cur_del_lnk_event;
        FETCH cur_del_lnk_event INTO l_dummy_link_char;
        IF cur_del_lnk_event%FOUND
        THEN
	    close cur_del_lnk_event;  -- Bug#6678573
            return 'CONCURRENT';
        END IF;
        CLOSE cur_del_lnk_event;
        -- End Bug # 4611527.

     END IF;

     l_wbs_update_option := nvl(FND_PROFILE.value('PA_PROCESS_WBS_UPDATES'),'STANDARD');
     IF l_wbs_update_option = 'ONLINE' THEN
          return 'ONLINE';
     ELSE
          l_threshold_task_cnt := nvl(FND_PROFILE.value('PA_PROC_WBS_UPD_THRESHOLD'),50);
          IF p_task_count > l_threshold_task_cnt THEN
               return 'CONCURRENT';
          ELSE
               return 'ONLINE';
          END IF;
     END IF;

EXCEPTION

WHEN OTHERS THEN
close cur_link_exists; -- Bug#6678573
close cur_del_lnk_event; -- Bug#6678573


END GET_PROCESS_WBS_UPDATES_OPTION;


-- Bug 3010538
-- This is an overloaded function that will accept the project id and the structure type
-- and return the status code of the only structure version that can be either in status WUP / WUE.
-- If none of the structure versions are in the above mentioned statuses, the function will return NULL.

FUNCTION GET_PROCESS_STATUS_CODE(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
)
return VARCHAR2 IS
     -- This cursor fetches the process code of WUP or WUE if the process is in
     -- progress for any of the structure versions or if the process has errored out.
     Cursor  cur_proc_ver(c_project_id pa_projects_all.project_id%TYPE,
                          c_structure_type pa_structure_types.structure_type%TYPE)
     is
     select vs.process_code
     from pa_proj_elem_ver_structure vs,
          pa_proj_structure_types pst,
          pa_structure_types st
     where
          vs.project_id        = c_project_id
     and  vs.process_code      in ('WUP','WUE')
     and pst.PROJ_ELEMENT_ID   = vs.proj_element_id
     and pst.structure_type_id = st.structure_type_id
     and  st.structure_type    = c_structure_type;

     l_process_code   FND_LOOKUPS.lookup_code%TYPE;
BEGIN

     open  cur_proc_ver(p_project_id,p_structure_type);
     fetch cur_proc_ver into l_process_code;
     close cur_proc_ver;

     return l_process_code;

END GET_PROCESS_STATUS_CODE;


function GET_FIN_STRUC_VER_ID(p_project_id IN NUMBER) return NUMBER
IS
  cursor projOrTemp IS
    select TEMPLATE_FLAG from pa_projects_all where project_id = p_project_id;
  l_template_flag VARCHAR2(1);

  l_struc_ver_id NUMBER;
  cursor getFinOnlyStrucVer(c_project_id NUMBER) IS
    /*Commented the Following SQL Query for Performance Bug fix : 3968091
    select pev.element_version_id
    from pa_proj_element_versions pev, pa_proj_elements pe,
         pa_proj_structure_types pst
    where pe.project_id = c_project_id
      and pe.project_id = pev.project_id
      and pe.proj_element_id = pev.proj_element_id
      and pe.object_type = 'PA_STRUCTURES'
      and pe.proj_element_id = pst.proj_element_id
      and pst.structure_type_id = 6;
     */
    select pev.element_version_id /*New Query with improved Performance : 3968091 */
    from pa_proj_element_versions pev,
         pa_proj_structure_types pst
    where pev.project_id = c_project_id
      and pev.object_type = 'PA_STRUCTURES'
      and pev.proj_element_id = pst.proj_element_id
      and pst.structure_type_id = 6;

BEGIN
  OPEN projOrTemp;
  FETCH projOrTemp into l_template_flag;
  CLOSE projOrTemp;

  IF l_template_flag = 'Y' THEN
    --this is a template; only has one version of financial structure
    OPEN getFinOnlyStrucVer(p_project_id);
    FETCH getFinOnlyStrucVer into l_struc_ver_id;
    CLOSE getFinOnlyStrucVer;
    return l_struc_ver_id;
  ELSE
    --this is a project; check if workplan is enabled
    IF (PA_PROJECT_STRUCTURE_UTILS.Check_Workplan_enabled(p_project_id) = 'N') THEN
      --workplan is not enabled; financial structure only
      OPEN getFinOnlyStrucVer(p_project_id);
      FETCH getFinOnlyStrucVer into l_struc_ver_id;
      CLOSE getFinOnlyStrucVer;
      return l_struc_ver_id;
    ELSE
      --Workplan enabled; check if it is shared of split
      IF (PA_PROJECT_STRUCTURE_UTILS.Check_Sharing_Enabled(p_project_id) = 'Y') THEN
        --this is a shared project; check if versioning is enabled
        IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id) = 'Y') THEN
          --get latest published, if published exist
          l_struc_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(p_project_id);
          IF l_struc_ver_id IS NULL THEN
            --get working version, which is the only version
            OPEN getFinOnlyStrucVer(p_project_id);
            FETCH getFinOnlyStrucVer into l_struc_ver_id;
            CLOSE getFinOnlyStrucVer;
          END IF;
          return l_struc_ver_id;
        ELSE
          --get the only version
          OPEN getFinOnlyStrucVer(p_project_id);
          FETCH getFinOnlyStrucVer into l_struc_ver_id;
          CLOSE getFinOnlyStrucVer;
          return l_struc_ver_id;
        END IF;
      ELSE
        --this is a split project; should only have one structure version
        OPEN getFinOnlyStrucVer(p_project_id);
        FETCH getFinOnlyStrucVer into l_struc_ver_id;
        CLOSE getFinOnlyStrucVer;
        return l_struc_ver_id;
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_NUMBER(NULL);
end GET_FIN_STRUC_VER_ID;

-- Bug 3010538
-- This is a procedure that will accept the project id and the structure type and
-- return the request id, process status code and the structure version id of the
-- concurrent program that is being run or that has errored out for any of the
-- structure version of the type corresponding to  structure_type. The structure
-- type parameter is required as when the structure is split, there could be two
-- concurrent programs running one for the FINANCIAL structure and the other for
-- the WORKPLAN structure.
PROCEDURE GET_CONC_REQUEST_DETAILS(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
    ,x_request_id            OUT NOCOPY pa_proj_elem_ver_structure.conc_request_id%TYPE -- 4537865
    ,x_process_code          OUT NOCOPY pa_proj_elem_ver_structure.process_code%TYPE -- 4537865
    ,x_structure_version_id  OUT NOCOPY pa_proj_elem_ver_structure.element_version_id%TYPE -- 4537865
    ,x_return_status         OUT NOCOPY VARCHAR2 -- 4537865
    ,x_msg_count             OUT NOCOPY NUMBER -- 4537865
    ,x_msg_data              OUT NOCOPY VARCHAR2 -- 4537865
)
AS
-- Cursor used in this API.

-- This cursor returns the concurrent request id, process code and the
-- structure version for which the concurrent request was launched - This
-- currently could be in process or could have completed with errors.
cursor cur_request_details(c_project_id pa_projects_all.project_id%TYPE,
                           c_structure_type pa_structure_types.structure_type%TYPE)
IS
select vs.conc_request_id, vs.process_code, vs.element_version_id
from  pa_proj_elem_ver_structure vs,
      pa_proj_structure_types pst,
      pa_structure_types st
where vs.project_id         = c_project_id
and   vs.process_code       in ('WUP','WUE')
and   pst.PROJ_ELEMENT_ID   = vs.proj_element_id
and   pst.structure_type_id = st.structure_type_id
and   st.structure_type     = c_structure_type;

INVALID_ARG_EXC_WP              EXCEPTION;
l_module_name                   CONSTANT VARCHAR2(30) := 'PA_PROJECT_STRUCTURE_UTILS';
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                   VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'GET_CONC_REQUEST_DETAILS',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

          pa_debug.g_err_stage:= 'p_project_id = '|| p_project_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

          pa_debug.g_err_stage:= 'p_structure_type ='|| p_structure_type;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_project_id IS NULL) OR
        (p_structure_type IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_WP;
     END IF;

     open  cur_request_details(p_project_id,p_structure_type);
     fetch cur_request_details into
          x_request_id,
          x_process_code,
          x_structure_version_id;
     close cur_request_details;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'request id : ' || x_request_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

          pa_debug.g_err_stage:= 'process code : ' || x_process_code;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

          pa_debug.g_err_stage:= 'structure version id : '||x_structure_version_id;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);

          pa_debug.g_err_stage:= 'Exiting GET_CONC_REQUEST_DETAILS';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          pa_debug.reset_curr_function;
     END IF;
EXCEPTION

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     -- 4537865 RESET OUT PARAMS
     x_request_id := NULL ;
     x_process_code := NULL ;
     x_structure_version_id := NULL ;

     IF cur_request_details%ISOPEN THEN
          CLOSE cur_request_details;
     END IF;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
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
     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     -- 4537865 RESET OUT PARAMS
     x_request_id := NULL ;
     x_process_code := NULL ;
     x_structure_version_id := NULL ;

     IF cur_request_details%ISOPEN THEN
          CLOSE cur_request_details;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJECT_STRUCTURE_UTILS'
                    ,p_procedure_name  => 'GET_CONC_REQUEST_DETAILS'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END GET_CONC_REQUEST_DETAILS;

--Bug 3010538
-- This is a function that will accept the project id and the structure type and
-- return the request id of the concurrent program that is being run or that has
-- errored out for any of the structure version of the type corresponding to
-- structure_type. The structure type parameter is required as when the structure
-- is split, there could be two concurrent programs running one for the FINANCIAL
-- structure and the other for the WORKPLAN structure.
FUNCTION GET_CONC_REQUEST_ID(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
)
return NUMBER IS
     -- This cursor returns the concurrent request id, process code and the
     -- structure version for which the concurrent request was launched - This
     -- currently could be in process or could have completed with errors.
     cursor cur_request_details(c_project_id pa_projects_all.project_id%TYPE,
                                c_structure_type pa_structure_types.structure_type%TYPE)
     IS
     select vs.conc_request_id
     from  pa_proj_elem_ver_structure vs,
           pa_proj_structure_types pst,
           pa_structure_types st
     where vs.project_id         = c_project_id
     and   vs.process_code       in ('WUP','WUE')
     and   pst.PROJ_ELEMENT_ID   = vs.proj_element_id
     and   pst.structure_type_id = st.structure_type_id
     and   st.structure_type     = c_structure_type;

     l_request_id   pa_proj_elem_ver_structure.conc_request_id%TYPE;

BEGIN
     open  cur_request_details(p_project_id,p_structure_type);
     fetch cur_request_details into l_request_id;
     close cur_request_details;

     return l_request_id;
END GET_CONC_REQUEST_ID;

--Below function is added for bug#3049157

FUNCTION GET_STRUCT_CONC_ID(
     p_structure_version_id  IN  pa_proj_element_versions.parent_structure_version_id%TYPE
     ,p_project_id            IN  pa_projects_all.project_id%TYPE -- Included for Performance Fix : 3968091
)
return NUMBER IS
     -- Returns the conc. request id for the structure version id .
     cursor cur_request_details(c_structure_version_id pa_proj_element_versions.parent_structure_version_id%TYPE )
     IS
     select vs.conc_request_id
     from  pa_proj_elem_ver_structure vs
     where vs.element_version_id = c_structure_version_id
       and vs.project_id = p_project_id ; --  Included for Performance Fix : 3968091

     l_request_id   pa_proj_elem_ver_structure.conc_request_id%TYPE;
BEGIN
     open  cur_request_details(p_structure_version_id);
     fetch cur_request_details into l_request_id;
     close cur_request_details;
     return l_request_id;
END GET_STRUCT_CONC_ID ;


-----------------------------------------------------------------------
-- API name                      : CHECK_DELIVERABLE_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if deliverable is enabled
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  17-Dec-03   Bhumesh K.       -Created
--  This is added for FP_M changes
-----------------------------------------------------------------------

  FUNCTION check_Deliverable_enabled (
       p_project_id IN NUMBER
  ) Return VARCHAR2
  IS
    CURSOR c1 IS
    SELECT 'Y'
    FROM pa_proj_elements a,
         pa_proj_structure_types b,
         pa_structure_types c
    WHERE c.structure_type_class_code = 'DELIVERABLE'
    AND   c.structure_type_id = b.structure_type_id
    AND   b.proj_element_id = a.proj_element_id
    AND   a.project_id = p_project_id;

    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c1;
    return l_dummy;
  END check_Deliverable_enabled;

--FPM changes bug 3301192
--Function to get the WP current working version
FUNCTION get_current_working_ver_id( p_project_id  NUMBER
)
RETURN NUMBER AS
 CURSOR cur_cwv
 IS
      SELECT ppevs.element_version_id
        FROM pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst,
             pa_proj_elem_ver_structure ppevs
       WHERE ppe.project_id = p_project_id
         AND ppe.proj_element_id = ppst.proj_element_id
         AND ppe.project_id = ppevs.project_id
         AND ppe.proj_element_id = ppevs.proj_element_id
         AND ppevs.status_code = 'STRUCTURE_WORKING'
         AND ppevs.CURRENT_WORKING_FLAG = 'Y'
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = 'WORKPLAN';

 l_structure_version_id NUMBER;
BEGIN

    OPEN cur_cwv;
    FETCH cur_cwv into l_structure_version_id;
    CLOSE cur_cwv;
    return l_structure_version_id;

END get_current_working_ver_id;


--------------------------------------------------------------------------
-- API name                      : Check_Struct_Has_Dep
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check the dependency of a structure version ID
--
-- Parameters
--  P_Version_ID                IN NUMBER
--
--  History
--
-- 6-Jan-04   Bhumesh K.       -Created
-- This is added for FP_M changes. Refer to tracking bug 3305199 for more details

FUNCTION Check_Struct_Has_Dep (
    P_Version_ID    IN      NUMBER
    )
RETURN VARCHAR2
IS
l_Exist_Flag    varchar2(2)   := 'N';

  BEGIN
  For Rec IN (  select a.ELEMENT_VERSION_ID
        from   pa_proj_element_versions a
        -- where  a.project_id = 1027
        -- This line is not reqd. Its used only for testing
        where  a.Parent_Structure_Version_ID = P_Version_ID
        and    a.Element_Version_ID IN (
                Select b.OBJECT_ID_FROM1
                from pa_object_relationships b
                    where b.Relationship_Type = 'S'
                    and b.Object_Type_From = 'PA_TASKS'
             ) )
  Loop
    Begin
      Select 'Y'
      Into   l_Exist_Flag
      from pa_object_relationships b
      where Rec.Element_Version_ID IN ( b.Object_ID_From1, b.Object_ID_To1 )
      and b.Object_Type_From = 'PA_TASKS'
      and b.Object_Type_To   = 'PA_TASKS'
      and b.Relationship_Type = 'D';
      Exception when No_Data_Found Then Null;
    End;
    If l_Exist_Flag = 'Y' then
      Return l_Exist_Flag;
    End IF;
  End Loop;

  Return l_Exist_Flag;

  END Check_Struct_Has_Dep;

--this function should return one of the followings:
--  SHARE_FULL
--  SHARE_PARTIAL
--  SPLIT_MAPPING
--  SPLIT_NO_MAPPING
--
-- null can also be returned

  FUNCTION get_Structure_sharing_code(
        p_project_id    IN      NUMBER
  )
  RETURN VARCHAR2
  IS
    CURSOR c1 IS
      select STRUCTURE_SHARING_CODE
      from pa_projects_all
      where project_id = p_project_id;
    l_sharing_code varchar2(30);
  BEGIN
    OPEN c1;
    FETCH c1 into l_sharing_code;
    CLOSE c1;
    return l_sharing_code;
  END get_structure_sharing_code;


  FUNCTION check_third_party_sch_flag(
        p_project_id    IN      NUMBER
  )
  RETURN VARCHAR2
  IS
    cursor get_third_party_flag IS
      Select ppwa.SCHEDULE_THIRD_PARTY_FLAG
        from pa_proj_workplan_attr ppwa,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where p_project_id = ppwa.project_id
         and ppwa.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type = 'WORKPLAN';
    l_flag VARCHAR2(1) := 'N';
  BEGIN
    OPEN get_third_party_flag;
    FETCH get_third_party_flag into l_flag;
    CLOSE get_third_party_flag;
    IF l_flag IS NULL THEN
      return 'N';
    END IF;
    return l_flag;
  END check_third_party_sch_flag;

  FUNCTION check_dep_on_summary_tk_ok(
    p_project_id   IN NUMBER
  )
  RETURN VARCHAR2
  IS
    cursor get_lowest_tsk_dep_flag IS
      Select ppwa.ALLOW_LOWEST_TSK_DEP_FLAG
        from pa_proj_workplan_attr ppwa,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where p_project_id = ppwa.project_id
         and ppwa.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type = 'WORKPLAN';
    l_flag VARCHAR2(1) := 'Y';
  BEGIN
    OPEN get_lowest_tsk_dep_flag;
    FETCH get_lowest_tsk_dep_flag into l_flag;
    CLOSE get_lowest_tsk_dep_flag;
    IF l_flag IS NULL THEN
      return 'Y';
    END IF;

    IF (l_flag = 'Y') THEN
      return 'N';
    END IF;
    return 'Y';
  END check_dep_on_summary_tk_ok;

  FUNCTION GET_LAST_UPD_WORK_VER_OLD
  (  p_structure_id IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1 IS
      SELECT MAX(a.last_update_date), b.parent_structure_version_id
        FROM pa_proj_element_versions b,
             pa_proj_elem_ver_schedule a,
             pa_proj_elem_ver_structure c
       WHERE a.element_version_id (+)= b.element_version_id
         AND a.project_id (+) = b.project_id
         AND a.proj_element_id (+) = b.proj_element_id
         AND b.parent_structure_version_id = c.element_version_id
         AND b.project_id = c.project_id
         AND c.status_code <> 'STRUCTURE_PUBLISHED'
         AND b.proj_element_id = p_structure_id
    GROUP BY b.parent_structure_version_id
    ORDER BY MAX(a.last_update_date) desc;
    l_date                 DATE;
    l_structure_version_id NUMBER;
  BEGIN
    OPEN c1;
    FETCH c1 into l_date, l_structure_version_id;
    CLOSE c1;
    return l_structure_version_id;
  END GET_LAST_UPD_WORK_VER_OLD;

  FUNCTION GET_STRUCT_VER_UPDATE_FLAG(
    p_structure_version_id NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
      select project_id from pa_proj_element_versions
       where element_version_id = p_structure_version_id;
    l_proj_id NUMBER;

    CURSOR c2(c_project_id NUMBER) IS
      select process_update_wbs_flag from pa_proj_elem_ver_structure
       where project_id = c_project_id and element_version_id = p_structure_Version_id;
    l_flag VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_proj_id;
    CLOSE c1;

    OPEN c2(l_proj_id);
    FETCH c2 into l_flag;
    CLOSE c2;

    IF l_flag <> 'N' THEN
      IF get_process_status_code(l_proj_id, p_structure_version_id) <> 'WUP' THEN
        return 'Y';
      END IF;
      return 'C';
    END IF;

    RETURN 'N';
  END GET_STRUCT_VER_UPDATE_FLAG;
--
  FUNCTION Get_Baseline_Struct_Ver(p_project_id IN NUMBER)
     RETURN NUMBER
  IS
     --Bug No 3692992 Performance fix
/*     CURSOR get_baseline_wp_ver(cp_proj_id NUMBER) IS
     SELECT ppev.element_version_id
       FROM pa_proj_elements ppe,
            pa_proj_element_versions ppev,
            pa_proj_elem_ver_structure ppevs,
            pa_proj_structure_types ppst,
            pa_structure_types pst
      WHERE ppe.proj_element_id = ppev.proj_element_id
        AND ppe.project_id = ppev.project_id
        AND ppe.project_id = cp_proj_id
        AND ppe.object_type = 'PA_STRUCTURES'
        AND ppev.element_version_id = ppevs.ELEMENT_VERSION_ID
        AND ppevs.CURRENT_FLAG = 'Y'
        AND pst.structure_type_id = ppst.structure_type_id
        AND ppst.proj_element_id = ppe.proj_element_id
        AND pst.structure_type_class_code = 'WORKPLAN';*/

     CURSOR get_baseline_wp_ver(cp_proj_id NUMBER) IS
     SELECT ppev.element_version_id
       FROM pa_proj_elements ppe,
            pa_proj_element_versions ppev,
            pa_proj_elem_ver_structure ppevs,
            pa_proj_structure_types ppst,
            pa_structure_types pst
      WHERE ppe.proj_element_id = ppev.proj_element_id
        AND ppe.project_id = ppev.project_id
        AND ppe.project_id = cp_proj_id
        AND ppe.object_type = 'PA_STRUCTURES'
        AND ppev.element_version_id = ppevs.ELEMENT_VERSION_ID
        AND ppev.project_id = ppevs.project_id
        AND ((ppevs.CURRENT_FLAG = 'Y') OR ((ppevs.CURRENT_FLAG = 'N') AND (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(cp_proj_id) = 'N') ) )
	--Added for the fix of 7658505
        AND pst.structure_type_id = ppst.structure_type_id
        AND ppst.proj_element_id = ppe.proj_element_id
        AND pst.structure_type_class_code = 'WORKPLAN';

        l_baseln_wp_struct_ver_id   NUMBER;
--
  BEGIN
      OPEN get_baseline_wp_ver(p_project_id);
      FETCH get_baseline_wp_ver INTO l_baseln_wp_struct_ver_id;
      IF get_baseline_wp_ver%NOTFOUND THEN
         l_baseln_wp_struct_ver_id := -1;
      END IF;
      CLOSE get_baseline_wp_ver;

      RETURN l_baseln_wp_struct_ver_id;

  END GET_BASELINE_STRUCT_VER;
--
--
FUNCTION Get_Sch_Dirty_fl
( p_project_id           IN NUMBER
 ,p_structure_version_id IN NUMBER)
 RETURN VARCHAR2
IS
--
   CURSOR get_sch_dirty_fl(cp_project_id NUMBER,cp_structure_version_id NUMBER) IS
   SELECT schedule_dirty_flag
     FROM pa_proj_elem_ver_structure
    WHERE project_id = cp_project_id
      AND element_version_id = cp_structure_version_id;
   l_dirty_flag  pa_proj_elem_ver_structure.schedule_dirty_flag%TYPE;
--
BEGIN
--
    OPEN get_sch_dirty_fl(p_project_id,p_structure_version_id);
    FETCH get_sch_dirty_fl INTO l_dirty_flag;
    IF get_sch_dirty_fl%NOTFOUND THEN
       l_dirty_flag := NULL;
    END IF;
    CLOSE get_sch_dirty_fl;
--
    RETURN l_dirty_flag;
--
END Get_Sch_Dirty_fl;
--
--
-- API name                      : Check_Subproject_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API check if there is subproject association for the given
--                                 sturcture version id and project_id.  Return Y if there is subproject
--                                 association or N if there is subproject association
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_ver_id          IN NUMBER
--
--  History
--
--  29-Mar-04   SMUKKA             -Created
--
FUNCTION Check_Subproject_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
    ,p_link_type        VARCHAR2     default 'SHARED'    --bug 4541039
)RETURN VARCHAR2
IS
--bug 4087964: changed sql
    CURSOR check_subproj_exists IS
    SELECT '1'
      FROM pa_proj_element_Versions ppev,
           pa_object_relationships por
     where ppev.parent_structure_version_id = p_structure_ver_id
       and ppev.element_version_id = por.object_id_from1
       and ppev.project_id = p_project_id
       and por.relationship_type IN ('LW', 'LF');


--bug 4541039
    CURSOR check_subproj_exists_wp IS
    SELECT '1'
      FROM pa_proj_element_Versions ppev,
           pa_object_relationships por
     where ppev.parent_structure_version_id = p_structure_ver_id
       and ppev.element_version_id = por.object_id_from1
       and ppev.project_id = p_project_id
       and por.relationship_type = 'LW';

    CURSOR check_subproj_exists_fn IS
    SELECT '1'
      FROM pa_proj_element_Versions ppev,
           pa_object_relationships por
     where ppev.parent_structure_version_id = p_structure_ver_id
       and ppev.element_version_id = por.object_id_from1
       and ppev.project_id = p_project_id
       and por.relationship_type = 'LF';
--bug 4541039



/*
    CURSOR chk_lnk_task(cp_structure_version_id NUMBER,cp_project_id NUMBER) IS
    SELECT '1'
      FROM pa_proj_element_versions ppev,
           pa_proj_elements ppe
     WHERE ppev.element_version_id = cp_structure_version_id
       AND ppev.project_id  = cp_project_id
       AND ppev.project_id = ppe.project_id
       AND ppev.proj_element_id = ppe.parent_structure_id
       AND ppe.link_task_flag = 'Y';
*/
    l_dummy VARCHAR2(1);
BEGIN
    IF p_link_type = 'SHARED'  --bug 4541039
    THEN
        OPEN check_subproj_exists;
        FETCH check_subproj_exists INTO l_dummy;
        IF check_subproj_exists%NOTFOUND THEN
        CLOSE check_subproj_exists;
          RETURN 'N';
        ELSE
          CLOSE check_subproj_exists;
          RETURN 'Y';
        END IF;
--bug 4541039
    ELSIF p_link_type = 'WORKPLAN'
    THEN
        OPEN check_subproj_exists_wp;
        FETCH check_subproj_exists_wp INTO l_dummy;
        IF check_subproj_exists_wp%NOTFOUND THEN
        CLOSE check_subproj_exists_wp;
          RETURN 'N';
        ELSE
          CLOSE check_subproj_exists_wp;
          RETURN 'Y';
        END IF;
    ELSIF p_link_type = 'FINANCIAL'
    THEN
        OPEN check_subproj_exists_fn;
        FETCH check_subproj_exists_fn INTO l_dummy;
        IF check_subproj_exists_fn%NOTFOUND THEN
        CLOSE check_subproj_exists_fn;
          RETURN 'N';
        ELSE
          CLOSE check_subproj_exists_fn;
          RETURN 'Y';
        END IF;
    END IF;
--end bug 4541039

END Check_Subproject_Exists;
--
--
-- API name                      : Check_Structure_Ver_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API check if there is structure version is valid exists for the
--                                 given sturcture version id and project_id.  Return Y if there is structure version
--                                 or N if there is no structure version.
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_ver_id          IN NUMBER
--
--  History
--
--  16-JUL-04   SMUKKA             -Created
--
--
FUNCTION Check_Structure_Ver_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
)RETURN VARCHAR2
IS
   CURSOR chk_structure_ver(cp_project_id NUMBER,cp_struct_ver_id NUMBER)
   IS
     SELECT 'Y'
       FROM pa_proj_element_versions
      WHERE project_id = cp_project_id
        AND element_version_id = cp_struct_ver_id
    AND object_type = 'PA_STRUCTURES';
--
   l_dummy VARCHAR2(1) := 'N';
--
BEGIN
--
   open chk_structure_ver(p_project_id, p_structure_ver_id);
   FETCH chk_structure_ver into l_dummy;
   IF chk_structure_ver%FOUND THEN
      l_dummy := 'Y';
   END IF;
   close chk_structure_ver;
--
   Return l_dummy;
--
END Check_Structure_Ver_Exists;
--
--
Function Check_Project_exists(p_project_id IN NUMBER)
RETURN VARCHAR2
IS
   CURSOR chk_project(cp_project_id NUMBER)
   IS
     SELECT 'Y'
       FROM pa_projects_all
      WHERE project_id = cp_project_id;
--
   l_dummy VARCHAR2(1) := 'N';
--
BEGIN
--
   open chk_project(p_project_id);
   FETCH chk_project into l_dummy;
   IF chk_project%FOUND THEN
      l_dummy := 'Y';
   END IF;
   close chk_project;
--
   Return l_dummy;
--
END Check_Project_exists;
--
--
-- Begin fix for Bug # 4373055.

PROCEDURE GET_PROCESS_STATUS_MSG(
p_project_id              IN  pa_projects_all.project_id%TYPE
, p_structure_type        IN  pa_structure_types.structure_type%TYPE := NULL
, p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE := NULL
, p_context               IN  VARCHAR2 := NULL
, x_message_name          OUT NOCOPY VARCHAR2   -- 4537865
, x_message_type          OUT NOCOPY VARCHAR2   -- 4537865
, x_structure_version_id  OUT NOCOPY NUMBER   -- 4537865
, x_conc_request_id       OUT NOCOPY NUMBER)   -- 4537865
IS

/*
This API fetches the message name of the message to be displayed based on the process status code
of the workplan structure. These process status codes signify either that a process is in progress
on the structure version / structure type or a process has failed with errors on the structure version /
structure type.
*/

cursor  cur_proc_ver(c_project_id pa_projects_all.project_id%TYPE
             , c_structure_type pa_structure_types.structure_type%TYPE) is
select vs.process_code, vs.element_version_id, vs.conc_request_id
from pa_proj_elem_ver_structure vs
     , pa_proj_structure_types pst
     , pa_structure_types st
where vs.project_id       = c_project_id
and pst.PROJ_ELEMENT_ID   = vs.proj_element_id
and pst.structure_type_id = st.structure_type_id
and st.structure_type    = c_structure_type
and vs.process_code is not null; -- Fix for Bug # 4373055.

cursor cur_process_code(c_project_id pa_projects_all.project_id%TYPE
            , c_structure_version_id pa_proj_element_versions.element_version_id%TYPE) is
select process_code, element_version_id, conc_request_id
from pa_proj_elem_ver_structure
where project_id = c_project_id
and element_version_id = c_structure_version_id;

l_process_code      FND_LOOKUPS.lookup_code%TYPE := null;
l_structure_version_id  NUMBER:= null;
l_conc_request_id   NUMBER := null;

cursor cur_message(c_process_code FND_LOOKUPS.lookup_code%TYPE) is
select meaning message_name, 'PROCESS' message_type
from pa_lookups
where lookup_code = c_process_code
and c_process_code like '%P'
union all
select meaning message_name, 'ERROR_EDITABLE' message_type
from pa_lookups
where lookup_code = c_process_code
and c_process_code like '%E'
and c_process_code <> 'PUE'
union all
select meaning message_name, 'ERROR_NOT_EDITABLE' message_type
from pa_lookups
where lookup_code = c_process_code
and c_process_code = 'PUE'
;

l_message_name  VARCHAR2(30) := null;
l_message_type  VARCHAR2(30) := null;

BEGIN

        l_process_code := null;
        l_message_name := null;
    l_message_type := null;
        x_structure_version_id  :=  null;
        x_conc_request_id := null;

    if (p_structure_type is not null) then

            open  cur_proc_ver(p_project_id,p_structure_type);
            fetch cur_proc_ver into l_process_code, l_structure_version_id
                    , l_conc_request_id;
            close cur_proc_ver;

    elsif (p_structure_version_id is not null) then

            open  cur_process_code(p_project_id, p_structure_version_id);
            fetch cur_process_code into l_process_code, l_structure_version_id
                            , l_conc_request_id;
            close cur_process_code;

    else
        l_process_code := null;

    end if;

    if l_process_code is not NULL then

-- Begin fix for Bug # 4475657.

-- The architecture team requires the meaning of lookup types to be translatable text.
-- Hence, we have removed the message name from the meaning column of the lookup type and matched
-- a lookup code to its corresponding message using the PL/SQL logic below.

        if (l_process_code = 'CPI') then

            l_message_name := 'PA_PS_PUBWBS_PRC_CHLDPUB';

            l_message_type := 'INFORMATION';

        elsif (l_process_code = 'APP') then

            l_message_name := 'PA_PS_APLPRG_PRC_INPROC';

            l_message_type := 'PROCESS';

        elsif (l_process_code = 'APE') then

            l_message_name := 'PA_PS_APLPRG_PRC_ERR';

            l_message_type := 'ERROR_EDITABLE';

                elsif (l_process_code = 'APS') then

                        l_message_name := null;

                        l_message_type := null;

        elsif (l_process_code = 'PUP') then

            l_message_name := 'PA_PS_PUBWBS_PRC_INPROC';

            l_message_type := 'PROCESS';

        elsif (l_process_code = 'PUE') then

            l_message_name := 'PA_PS_PUBWBS_PRC_ERR';

            l_message_type :=  'ERROR_NOT_EDITABLE'; -- Bug # 4577934. -- 'ERROR_EDITABLE'; -- Bug # 4562309.

                elsif (l_process_code = 'PUS') then

                        l_message_name := null;

                        l_message_type := null;

        elsif (l_process_code = 'WUP') then

            l_message_name := 'PA_PS_UDTWBS_PRC_INPROC';

            l_message_type := 'PROCESS';

        elsif (l_process_code = 'WUE') then

            l_message_name := 'PA_PS_UDTWBS_PRC_ERR';

            l_message_type := 'ERROR_EDITABLE';

        elsif (l_process_code = 'WUS') then

            l_message_name := null;

            l_message_type := null;

        /* Added For bug#5659575 */
	elsif (l_process_code = 'PRE' and p_context is NULL) then

	    l_message_name := 'PA_PS_UPDPERF_PRC_ERR';

	    l_message_type := 'ERROR_EDITABLE';

        end if;

        -- open  cur_message(l_process_code);
            -- fetch cur_message into l_message_name, l_message_type;
            -- close cur_message;

-- End fix for Bug # 4475657.

    end if;

    if  ((p_context = 'UPDATE_AMG') and (l_message_name is not null)) then -- Fix for Bug # 4373055.

        l_message_name := l_message_name||'_AMG';

    end if;

        x_message_name := l_message_name;
    x_message_type := l_message_type;
    x_structure_version_id  :=  l_structure_version_id;
    x_conc_request_id := l_conc_request_id;
  -- 4537865
  EXCEPTION
    WHEN OTHERS THEN
        x_message_name := NULL ;
        x_message_type := NULL ;
        x_structure_version_id := NULL ;
        x_conc_request_id := NULL ;

        Fnd_Msg_Pub.add_exc_msg
                ( p_pkg_name        => 'PA_PROJECT_STRUCTURE_UTILS'
                , p_procedure_name  => 'GET_PROCESS_STATUS_MSG'
                , p_error_text      => SUBSTRB(SQLERRM,1,240));

        RAISE ;

END GET_PROCESS_STATUS_MSG;


PROCEDURE SET_PROCESS_CODE_IN_PROC(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_calling_context       IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT  NOCOPY   VARCHAR2) -- 4537865
IS

l_return_status VARCHAR2(30) := NULL;

BEGIN

l_return_status := FND_API.G_RET_STS_SUCCESS;

update pa_proj_elem_ver_structure
set process_code = decode(p_calling_context, 'APPLY_PROGRESS', 'APP'
                           , 'CONC_PUBLISH', 'PUP'
                           , 'CONC_UPDATE', 'WUP'
                                           , 'ASGMT_PLAN_CHANGE', 'WUP'
                                           ,null)  ---4492493
, conc_request_id = p_conc_request_id
where element_version_id = p_structure_version_id
and project_id = p_project_id;

x_return_status := l_return_status;

commit;

EXCEPTION

when others then

    -- Changed l_return_status to x_return_status : 4537865
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    raise;

END SET_PROCESS_CODE_IN_PROC;


PROCEDURE SET_PROCESS_CODE_ERR(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_calling_context       IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT NOCOPY  VARCHAR2) -- 4537865
IS

l_return_status VARCHAR2(30) := NULL;

BEGIN

l_return_status := FND_API.G_RET_STS_SUCCESS;

update pa_proj_elem_ver_structure
set process_code = decode(p_calling_context, 'APPLY_PROGRESS', 'APE'
                       , 'CONC_PUBLISH', 'PUE'
                       , 'CONC_UPDATE', 'WUE', null)
, conc_request_id = p_conc_request_id
where element_version_id = p_structure_version_id
and project_id = p_project_id;

x_return_status := l_return_status;

commit;

EXCEPTION

when others then
    -- 4537865 Changed l_return_status to x_return_status
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        raise;

END SET_PROCESS_CODE_ERR;

-- End fix for Bug # 4373055.


-- Begin fix for Bug # 5659575.

PROCEDURE SET_PROCESS_CODE(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_process_code          IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT   NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(30) := NULL;

BEGIN

l_return_status := FND_API.G_RET_STS_SUCCESS;
if p_process_code = 'PRE' then
	update pa_proj_elem_ver_structure
	set process_code = p_process_code
	, conc_request_id = p_conc_request_id
	where element_version_id = p_structure_version_id
	and project_id = p_project_id
	and process_code is null;
else
	update pa_proj_elem_ver_structure
	set process_code = NULL
	where project_id = p_project_id
	and process_code = 'PRE';
end if;
x_return_status := l_return_status;

EXCEPTION

when others then

	-- Changed l_return_status to x_return_status for NOCOPY
        x_return_status := FND_API.G_RET_STS_ERROR;

        raise;

END SET_PROCESS_CODE;

-- End fix for Bug # 5659575.

-- Begin fix for Bug # 4502325.

procedure get_structure_msg(p_project_id          IN    NUMBER
                , p_structure_type        IN    VARCHAR2
                , p_structure_version_id  IN    NUMBER
                , p_context               IN    VARCHAR2 := NULL
                , x_message_name          OUT   NOCOPY VARCHAR2  -- 4537865
                , x_message_type          OUT   NOCOPY VARCHAR2  -- 4537865
                , x_structure_version_id  OUT   NOCOPY NUMBER  -- 4537865
                , x_conc_request_id       OUT   NOCOPY NUMBER)  -- 4537865
is

    cursor cur_str_sharing_code(c_project_id NUMBER) is
    select ppa.structure_sharing_code
    from pa_projects_all ppa
    where ppa.project_id = c_project_id;

    l_str_sharing_code  VARCHAR2(30)    := null;

    cursor cur_proc_upd_flag(c_project_id NUMBER, c_structure_version_id VARCHAR2) is
    select ppevs.process_update_wbs_flag, ppevs.process_code
    from pa_proj_elem_ver_structure ppevs, pa_proj_structure_types ppst, pa_structure_types pst
    where ppevs.proj_element_id = ppst.proj_element_id
    and ppst.structure_type_id = pst.structure_type_id
    and ppevs.project_id = c_project_id
    and ppevs.element_version_id = c_structure_version_id;

    l_proc_upd_flag     VARCHAR2(1)     := null;
    l_process_code      VARCHAR2(30)    := null;
    l_message_name      VARCHAR2(30)    := null;
    l_message_type      VARCHAR2(30)    := null;
    l_structure_version_id  NUMBER      := null;
    l_conc_request_id   NUMBER      := null;

begin

        l_proc_upd_flag         := null;
        l_process_code      := null;
        l_message_name      := null;
    l_message_type      := null;
        l_structure_version_id  := null;
        l_conc_request_id   := null;


    if  ((p_project_id is null)
          or (p_structure_type is null)
          or (p_structure_version_id is null)) then

            l_message_name      := null;
        l_message_type      := null;
        l_structure_version_id  := null;
        l_conc_request_id   := null;

    else

        open cur_str_sharing_code(p_project_id);
        fetch cur_str_sharing_code into l_str_sharing_code;
        close cur_str_sharing_code;

        open cur_proc_upd_flag(p_project_id, p_structure_version_id);
        fetch cur_proc_upd_flag into l_proc_upd_flag, l_process_code;
        close cur_proc_upd_flag;

        if (l_process_code is not null) then

                        PA_PROJECT_STRUCTURE_UTILS.GET_PROCESS_STATUS_MSG
                        (p_project_id                   => p_project_id
                         , p_structure_type             => NULL
                         , p_structure_version_id       => p_structure_version_id
                         , p_context                    => p_context
                         , x_message_name               => l_message_name
                         , x_message_type               => l_message_type
                         , x_structure_version_id       => l_structure_version_id
                         , x_conc_request_id            => l_conc_request_id);

        elsif (l_proc_upd_flag = 'Y') then

            if (p_structure_type = 'WORKPLAN') then
             -- Bug 5999999
	     IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN

                    if l_str_sharing_code in ('SHARE_FULL' , 'SHARE_PARTIAL') then

                        l_message_name := 'PA_PS_VD_SH_UPD_WBS_PRC_REQ';
                    else

                            l_message_name := 'PA_PS_VD_SP_UPD_WBS_PRC_REQ';

                    end if;
			ELSE

                             l_message_name := 'PA_PS_DEF_RUP_UPD_WBS_PRC_REQ';
                        END IF;

                elsif (p_structure_type = 'FINANCIAL') then

		IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN

                    if l_str_sharing_code in ('SHARE_FULL' , 'SHARE_PARTIAL') then

                        l_message_name := 'PA_PS_VD_SH_UPD_WBS_PRC_REQ';

                else

                        l_message_name := 'PA_PS_VD_SP_UPD_FBS_PRC_REQ';

                    end if;
                ELSE
		      l_message_name := 'PA_PS_DEF_RUP_UPD_WBS_PRC_REQ';
                END IF;


                end if;

                    l_message_type          := 'INFORMATION';
                    l_structure_version_id  := p_structure_version_id;
                    l_conc_request_id       := null;

        else

                    l_message_name          := null;
                    l_message_type          := null;
                    l_structure_version_id  := null;
                    l_conc_request_id       := null;

        end if;

    end if;

        x_message_name      := l_message_name;
    x_message_type      := l_message_type;
    x_structure_version_id  := l_structure_version_id;
    x_conc_request_id   := l_conc_request_id;
-- 4537865
EXCEPTION
    WHEN OTHERS THEN
        x_message_name := NULL ;
        x_message_type := NULL ;
        x_structure_version_id := NULL ;
        x_conc_request_id := NULL ;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_UTILS',
                                p_procedure_name => 'get_structure_msg',
                                p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
end  get_structure_msg;

-- End fix for Bug # 4502325.

-- Begin Bug # 4582750.

procedure lock_unlock_wp_str_autonomous
(p_project_id                       IN  NUMBER
 ,p_structure_version_id            IN  NUMBER
 ,p_lock_status_code            IN  VARCHAR2 := 'LOCKED'
 ,p_calling_module                  IN  VARCHAR2   := 'SELF_SERVICE'
 ,x_return_status                   OUT NOCOPY VARCHAR2
 ,x_msg_count                       OUT NOCOPY NUMBER
 ,x_msg_data                        OUT NOCOPY VARCHAR2)
is

PRAGMA AUTONOMOUS_TRANSACTION;

l_module_name                   CONSTANT VARCHAR2(61) := 'PA_PROJECT_STRUCTURE_UTILS.LOCK_UNLOCK_WP_STR_AUTONOMOUS';
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);
l_wp_str            VARCHAR2(30);

cursor l_cur_ppevs(c_project_id NUMBER, c_str_ver_id NUMBER) is
select ppevs.name, ppevs.pev_structure_id, ppevs.record_version_number
from pa_proj_elem_ver_structure ppevs
where ppevs.project_id = c_project_id
and ppevs.element_version_id = c_str_ver_id;

l_rec_ppevs l_cur_ppevs%rowtype;

begin

savepoint lock_unlock_wp_str;

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

if l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function( p_function   => 'lock_unlock_wp_str_autonomous');
        pa_debug.write(l_module_name,'p_project_id = '||p_project_id,3);
        pa_debug.write(l_module_name,'p_structure_version_id = '||p_structure_version_id,3);
    pa_debug.write(l_module_name,'p_lock_status_code = '||p_lock_status_code,3);
end if;

l_wp_str := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');

if l_debug_mode = 'Y' THEN
        pa_debug.write(l_module_name,'l_wp_str = '||l_wp_str,3);
end if;

if (l_wp_str = 'Y') then

    open l_cur_ppevs(p_project_id, p_structure_version_id);
    fetch l_cur_ppevs into l_rec_ppevs;
    close l_cur_ppevs;

        if l_debug_mode = 'Y' THEN
            pa_debug.write(l_module_name,'Before Calling pa_project_structure_pub1.update_structure_version_attr',3);
            pa_debug.write(l_module_name,'l_rec_ppevs.pev_structure_id = '||l_rec_ppevs.pev_structure_id,3);
            pa_debug.write(l_module_name,'l_rec_ppevs.name= '||l_rec_ppevs.name,3);
            pa_debug.write(l_module_name,'l_rec_ppevs.record_version_number= '||l_rec_ppevs.record_version_number,3);
        end if;

    pa_project_structure_pub1.update_structure_version_attr
    (p_pev_structure_id            => l_rec_ppevs.pev_structure_id
         , p_locked_status_code        => p_lock_status_code
         , p_structure_version_name    => l_rec_ppevs.name
         , p_init_msg_list             => FND_API.G_FALSE    -- Added for bug 5130360
         , p_record_version_number     => l_rec_ppevs.record_version_number
         , p_calling_module            => p_calling_module
         , x_return_status             => x_return_status
         , x_msg_count                 => x_msg_count
         , x_msg_data                  => x_msg_data);

        if l_debug_mode = 'Y' THEN
            pa_debug.write(l_module_name,'After calling pa_project_structure_pub1.update_structure_version_attr x_return_status='||x_return_status,3);
        end if;


end if;

if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    commit;
else
     raise FND_API.G_EXC_ERROR;
end if;

exception

    when FND_API.G_EXC_ERROR then
            /*rollback to lock_unlock_wp_str; bug#6414944*/
            rollback; /*bug# 6414944*/

    when others then
           /* rollback to lock_unlock_wp_str; bug#6414944*/
           rollback; /*Bug# 6414944*/
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_UTILS',
                                    p_procedure_name => 'lock_unlock_wp_str_autonomous',
                                    p_error_text     => SUBSTRB(SQLERRM,1,240));

end lock_unlock_wp_str_autonomous;

procedure lock_unlock_wp_str
(p_project_id                       IN  NUMBER
 ,p_structure_version_id            IN  NUMBER
 ,p_lock_status_code            IN  VARCHAR2 := 'LOCKED'
 ,p_calling_module                  IN  VARCHAR2   := 'SELF_SERVICE'
 ,x_return_status                   OUT NOCOPY VARCHAR2
 ,x_msg_count                       OUT NOCOPY NUMBER
 ,x_msg_data                        OUT NOCOPY VARCHAR2)
is

l_module_name                   CONSTANT VARCHAR2(61) := 'PA_PROJECT_STRUCTURE_UTILS.LOCK_UNLOCK_WP_STR';
l_msg_count                     NUMBER := 0;
l_msg_data                      VARCHAR2(2000);
l_debug_mode                    VARCHAR2(1);
l_wp_str            VARCHAR2(30);

cursor l_cur_ppevs(c_project_id NUMBER, c_str_ver_id NUMBER) is
select ppevs.name, ppevs.pev_structure_id, ppevs.record_version_number
from pa_proj_elem_ver_structure ppevs
where ppevs.project_id = c_project_id
and ppevs.element_version_id = c_str_ver_id;

l_rec_ppevs l_cur_ppevs%rowtype;

begin

savepoint lock_unlock_wp_str2;

x_msg_count := 0;
x_return_status := FND_API.G_RET_STS_SUCCESS;
l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

if l_debug_mode = 'Y' THEN
    pa_debug.set_curr_function( p_function   => 'lock_unlock_wp_str');
        pa_debug.write(l_module_name,'p_project_id = '||p_project_id,3);
        pa_debug.write(l_module_name,'p_structure_version_id = '||p_structure_version_id,3);
    pa_debug.write(l_module_name,'p_lock_status_code = '||p_lock_status_code,3);
end if;

l_wp_str := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');

if l_debug_mode = 'Y' THEN
        pa_debug.write(l_module_name,'l_wp_str = '||l_wp_str,3);
end if;

if (l_wp_str = 'Y') then

    open l_cur_ppevs(p_project_id, p_structure_version_id);
    fetch l_cur_ppevs into l_rec_ppevs;
    close l_cur_ppevs;

        if l_debug_mode = 'Y' THEN
            pa_debug.write(l_module_name,'Before Calling pa_project_structure_pub1.update_structure_version_attr',3);
            pa_debug.write(l_module_name,'l_rec_ppevs.pev_structure_id = '||l_rec_ppevs.pev_structure_id,3);
            pa_debug.write(l_module_name,'l_rec_ppevs.name= '||l_rec_ppevs.name,3);
            pa_debug.write(l_module_name,'l_rec_ppevs.record_version_number= '||l_rec_ppevs.record_version_number,3);
        end if;

    pa_project_structure_pub1.update_structure_version_attr
    (p_pev_structure_id            => l_rec_ppevs.pev_structure_id
         , p_locked_status_code        => p_lock_status_code
         , p_structure_version_name    => l_rec_ppevs.name
         , p_init_msg_list             => FND_API.G_FALSE    -- Added for bug 5130360
         , p_record_version_number     => l_rec_ppevs.record_version_number
         , p_calling_module            => p_calling_module
         , x_return_status             => x_return_status
         , x_msg_count                 => x_msg_count
         , x_msg_data                  => x_msg_data);

        if l_debug_mode = 'Y' THEN
            pa_debug.write(l_module_name,'After calling pa_project_structure_pub1.update_structure_version_attr x_return_status='||x_return_status,3);
        end if;


end if;

if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
    --commit;
    null;
else
    raise FND_API.G_EXC_ERROR;
end if;

exception

    when FND_API.G_EXC_ERROR then
            rollback to lock_unlock_wp_str2;

    when others then
            rollback to lock_unlock_wp_str2;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_UTILS',
                                    p_procedure_name => 'lock_unlock_wp_str',
                                    p_error_text     => SUBSTRB(SQLERRM,1,240));

end lock_unlock_wp_str;

-- End Bug # 4582750.

--bug 4597323
FUNCTION check_program_flag_enable(
     p_project_id          NUMBER
) RETURN VARCHAR2 IS

    CURSOR cur_proj
    IS
      SELECT sys_program_flag
        FROM pa_projects_all
       WHERE project_id=p_project_id
       ;
l_return_value    VARCHAR2(1);
BEGIN

     IF p_project_id IS NOT NULL
     THEN
        OPEN cur_proj;
        FETCH cur_proj INTO l_return_value;
        CLOSE cur_proj;
     END IF;

     return l_return_value;

END check_program_flag_enable;
--end bug 4597323

-- API name                      : check_del_pub_struc_ver_ok
-- Tracking Bug                  : 4925192
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to delete Published structure
--                                 version
--                                 Return Y or N
--
-- Parameters
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  20-OCT-06   Ram Namburi             -Created
--
--  Purpose:
--  This API will determine whether a published structure version can be deleted or not.
--
--  Business Rules:
--
--  The published version cannot be deleted if
--
--  1.	It is the current baseline version - because the metrics are calculated using
--      the baselined values from the current baselined workplan structure version
--  2.	It is the latest published version - because the PJI module uses the
--      financial plan to rollup data on the latest published workplan structure version
--  3.	It is a part of a program - because it is technically challenging to handle
--      the deletion of published workplan structure versions that belong to the
--      program itself or an intermediate sub-project in a program hierarchy



  FUNCTION check_del_pub_struc_ver_ok
  ( p_structure_version_id IN NUMBER
   ,p_project_id IN NUMBER
  ) return VARCHAR2
  IS
    l_object_relationship_id      NUMBER;
    l_current_flag                pa_proj_elem_ver_structure.current_flag%TYPE;
    l_LATEST_EFF_PUBLISHED_FLAG   pa_proj_elem_ver_structure.LATEST_EFF_PUBLISHED_FLAG%TYPE;
    l_version_name                pa_proj_elem_ver_structure.name%TYPE;
    l_version_number              pa_proj_elem_ver_structure.version_number%TYPE;

    -- Checks whether the published workplan structure version is part of a program

	CURSOR link_exists_cur IS
        SELECT 1 FROM DUAL WHERE EXISTS (
	SELECT por.object_relationship_id
	FROM pa_object_relationships por,
         pa_proj_element_versions ppev
	WHERE por.object_id_from1 = ppev.element_version_id
	AND por.relationship_type in ('LW', 'LF')
	AND ppev.parent_structure_version_id = p_structure_version_id
	UNION ALL
	SELECT por. object_relationship_id
	FROM pa_object_relationships por,
         pa_proj_element_versions ppev
	WHERE por.object_id_to1 = ppev.element_version_id
	AND por.relationship_type in ('LW', 'LF')
	AND ppev.parent_structure_version_id = p_structure_version_id);

    -- Checks whether the published workplan structure version is CURRENT or Latest
    -- Published version.

    CURSOR curr_lat_pub_ver_cur  IS
	SELECT ppevs.current_flag,
	       ppevs.LATEST_EFF_PUBLISHED_FLAG,
	       ppevs.name,
             ppevs.version_number
	FROM pa_proj_elem_ver_structure ppevs
       WHERE ppevs.element_version_id = p_structure_version_id
         AND ppevs.project_id = p_project_id;

  BEGIN

      OPEN curr_lat_pub_ver_cur;
      FETCH curr_lat_pub_ver_cur into l_current_flag,l_LATEST_EFF_PUBLISHED_FLAG,l_version_name,l_version_number;
      CLOSE curr_lat_pub_ver_cur;

      IF l_current_flag = 'Y' THEN
        FND_MESSAGE.set_name('PA','PA_PS_DEL_CURR_BASE_VER');
        -- Commenting out the following as the messages are changed in the FD.
        -- Now as per the latest FD the above message doesnt need any tokens.
        -- FND_MESSAGE.set_token('VER_NAME',l_version_name);
        -- FND_MESSAGE.set_token('VER_NUMBER',l_version_number);
        FND_MSG_PUB.add;

        return 'N';
      END IF;

      IF l_LATEST_EFF_PUBLISHED_FLAG = 'Y' THEN
        FND_MESSAGE.set_name('PA','PA_PS_DEL_LATEST_PUB_VER');
        -- Commenting out the following as the messages are changed in the FD.
        -- Now as per the latest FD the above message doesnt need any tokens.
        -- FND_MESSAGE.set_token('VER_NAME',l_version_name);
        -- FND_MESSAGE.set_token('VER_NUMBER',l_version_number);
        FND_MSG_PUB.add;

        return 'N';
      END IF;

      OPEN link_exists_cur;
      FETCH link_exists_cur into l_object_relationship_id;
      IF link_exists_cur%FOUND THEN
        FND_MESSAGE.set_name('PA','PA_PS_DEL_PART_OF_PROG');
        -- Commenting out the following as the messages are changed in the FD.
        -- Now as per the latest FD the above message doesnt need any tokens.
        -- FND_MESSAGE.set_token('VER_NAME',l_version_name);
        -- FND_MESSAGE.set_token('VER_NUMBER',l_version_number);
        FND_MSG_PUB.add;
        CLOSE link_exists_cur;
        return 'N';
      END IF;
      CLOSE link_exists_cur;

      RETURN 'Y';

  END check_del_pub_struc_ver_ok;


-- bug 5183704
-- API name                      : check_pending_link_changes
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API returns "Y" if pending link changes exist for a given project as per
--				   log type PRG_CHANGE in the pa_pji_proj_events_log, pji_pa_proj_events_log tables.
--                                 It's created to use from Projects Self Services (sql from vijay r).
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  09-MAY-06   sliburd             -Created
--
 function CHECK_PENDING_LINK_CHANGES(p_project_id NUMBER
                                     ,p_version_id NUMBER)
  return VARCHAR2
  IS
    CURSOR c1 IS
     select 1
     from dual
     where exists (select log.event_id
                   from   pji_pa_proj_events_log log,pa_proj_element_versions ver
                   where  log.event_type='PRG_CHANGE'
                   and    log.event_object =to_char(ver.prg_group)
                   and    ver.project_id=p_project_id
                   and    ver.parent_structure_version_id = nvl(p_version_id,ver.parent_structure_version_id) --Bug#8889029.added nvl
                   union all
                   select log.event_id
                   from   pa_pji_proj_events_log log,pa_proj_element_versions ver
                   where  log.event_type='PRG_CHANGE'
                   and    log.event_object =to_char(ver.prg_group)
                   and    ver.project_id=p_project_id
                   and    ver.parent_structure_version_id = nvl(p_version_id,ver.parent_structure_version_id) --Bug#8889029.added nvl
                   );

    l_dummy VARCHAR2(1);

  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    END IF;
    CLOSE c1;
    return 'Y';
  END CHECK_PENDING_LINK_CHANGES;

  -- bug 8889029
-- API name                      : CHECK_UPPD_RUNNING
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API returns "Y" if PRC: Update Project Performance Data
--                                    is running for a given project
-- Parameters
--  p_project_id                IN NUMBER
--  p_version_id                IN NUMBER
--
--  History
--
--  26-APR-07   bnoorbha             -Created
--
  function CHECK_UPPD_RUNNING(p_project_id NUMBER
                              ,p_version_id NUMBER)
  return VARCHAR2
  IS
    CURSOR c1 IS
     select distinct worker_id
     from pji_pjp_proj_batch_map
     where project_id = p_project_id;

    l_worker_id  NUMBER;
    l_request_id NUMBER;
    l_process VARCHAR2(30);

  BEGIN
    OPEN c1;
    FETCH c1 into l_worker_id;
    IF c1%NOTFOUND THEN
      CLOSE c1;
      return 'N';
    END IF;

    l_process := PJI_PJP_SUM_MAIN.g_process || l_worker_id;

    l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                           l_process);

    IF (PJI_PROCESS_UTIL.REQUEST_STATUS('RUNNING',
                                        l_request_id,
                                        PJI_PJP_SUM_MAIN.g_incr_disp_name) ) THEN
       return 'Y';
     ELSE
       return 'N';
     END IF;
  END CHECK_UPPD_RUNNING;

-- bug 8889029
-- API name                      : CHECK_UPPD_RUNNING
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : To control the profile option PA: Program Amounts Rollup Processing
--                                 when pending program changes exists.
-- Parameters
--  lookup_code                IN VARCHAR2
--
--  History
--
--  26-APR-07   bnoorbha             -Created
--
  function GET_ROLLUP_PROFILE_VAL(lookup_code IN VARCHAR2)
  return VARCHAR2
  IS
    CURSOR c1 IS
     select 1
     from dual
     where exists (select log.event_id
                   from   pji_pa_proj_events_log log
                   where  log.event_type='PRG_CHANGE'
                   union all
                   select log.event_id
                   from   pa_pji_proj_events_log log
                   where  log.event_type='PRG_CHANGE'
                   );

    l_dummy VARCHAR2(1);

  BEGIN
    IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN
        return lookup_code;
    ELSE
        OPEN c1;
        FETCH c1 into l_dummy;
        IF c1%NOTFOUND THEN
          CLOSE c1;
          return lookup_code;
        END IF;
        return 'MANUAL';
    END IF;
  END GET_ROLLUP_PROFILE_VAL;


  -- 9072357 : Validate all the lowest level task dates against the expenditure item dates
  procedure check_exp_item_dates (
      p_project_id               IN NUMBER
     ,p_structure_version_id     IN NUMBER
     ,x_return_status            OUT NOCOPY VARCHAR2
     ,x_msg_count                OUT NOCOPY NUMBER
     ,x_msg_data                 OUT NOCOPY VARCHAR2
  )
  IS

     l_msg_index_out  NUMBER;
     l_msg_count      NUMBER;
     l_return_status  VARCHAR2(1);
     l_msg_data       VARCHAR2(2000);

     l_structure_id   pa_proj_elem_ver_structure.proj_element_id%TYPE;
     l_buffer         pa_proj_workplan_attr.txn_date_sync_buf_days%TYPE;

     l_old_task_start_date     DATE;
     l_old_task_finish_date    DATE;
     l_task_start_date         DATE;
     l_task_finish_date        DATE;

     CURSOR get_structure_id
     IS
       SELECT a.proj_element_id
       FROM pa_proj_elements a,
            pa_proj_structure_types b,
            pa_structure_types c
       WHERE a.proj_element_id = b.proj_element_id
       AND a.object_type = 'PA_STRUCTURES'
       AND a.project_id = p_project_id
       AND b.structure_type_id = c.structure_type_id
       AND c.structure_type = 'WORKPLAN';

     CURSOR get_buffer(c_structure_id pa_proj_elem_ver_structure.proj_element_id%TYPE)
     IS
       SELECT NVL(txn_date_sync_buf_days, 0)
       FROM pa_proj_workplan_attr
       WHERE proj_element_id = c_structure_id;

    CURSOR get_tasks
    IS
      SELECT ppe.proj_element_id,
        ppe.element_number,
        ppev.element_version_id
      FROM  pa_proj_elements ppe,
        pa_proj_element_versions ppev,
        pa_proj_elem_ver_schedule ppevs
      WHERE ppe.project_id = p_project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.parent_structure_version_id = p_structure_version_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppev.element_version_id = ppevs.element_version_id
      AND NVL(ppe.link_task_flag, 'N') = 'N';

    CURSOR get_transaction_dates(c_proj_element_id pa_proj_elements.proj_element_id%TYPE)
    IS
      SELECT pt.start_date,
        pt.completion_date
      FROM pa_tasks pt
      WHERE pt.task_id = c_proj_element_id;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_structure_id;
    FETCH get_structure_id INTO l_structure_id;
    CLOSE get_structure_id;

    IF (PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'N') THEN
      RETURN;
    END IF;

    OPEN get_buffer(l_structure_id);
    FETCH get_buffer INTO l_buffer;
    CLOSE get_buffer;

    FOR rec IN get_tasks LOOP

      -- Validate expenditure item dates for lowest level tasks (financial) only
      IF ((PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(rec.proj_element_id) = 'Y') AND
          (PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_PROJ_TASK(rec.element_version_id, p_project_id) = 'Y')) THEN

        l_old_task_start_date  := null;
        l_old_task_finish_date := null;
        l_task_start_date      := null;
        l_task_finish_date     := null;

        -- Get the new transaction start and end date
        pa_project_dates_utils.get_task_copy_dates(
                          p_project_id                  => p_project_id,
                          p_proj_element_id             => rec.proj_element_id,
                          p_parent_structure_version_id => p_structure_version_id,
                          x_task_start_date             => l_task_start_date,
                          x_task_finish_date            => l_task_finish_date,
                          p_act_fin_date_flag           => 'Y');

        l_task_start_date := l_task_start_date - l_buffer;
        l_task_finish_date := l_task_finish_date + l_buffer;

        -- Get the existing transaction dates from db
        OPEN get_transaction_dates(rec.proj_element_id);
        FETCH get_transaction_dates INTO l_old_task_start_date, l_old_task_finish_date;
        CLOSE get_transaction_dates;

        IF (NVL(l_old_task_start_date, sysdate) <> NVL(l_task_start_date, sysdate)) THEN

          PA_TASKS_MAINT_UTILS.Check_Start_Date_EI (
                       p_project_id    => p_project_id,
                       p_task_id       => rec.proj_element_id,
                       p_start_date    => l_task_start_date,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data
          );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        ELSIF (NVL(l_old_task_finish_date, sysdate) <> NVL(l_task_finish_date, sysdate)) THEN

          PA_TASKS_MAINT_UTILS.Check_End_Date_EI (
                       p_project_id    => p_project_id,
                       p_task_id       => rec.proj_element_id,
                       p_end_date      => l_task_finish_date,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data
          );

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        END IF;

      END IF; -- PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_PROJ_TASK
    END LOOP; -- get_tasks

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := FND_MSG_PUB.count_msg;

    IF x_msg_count > 0 THEN
      PA_INTERFACE_UTILS_PUB.get_messages (
                  p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => x_msg_count
                , p_msg_data       => x_msg_data
                , p_data           => x_msg_data
                , p_msg_index_out  => l_msg_index_out);
    END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := FND_MSG_PUB.count_msg;

    IF x_msg_count > 0 THEN
      PA_INTERFACE_UTILS_PUB.get_messages (
                  p_encoded        => FND_API.G_FALSE
                , p_msg_index      => 1
                , p_msg_count      => x_msg_count
                , p_msg_data       => x_msg_data
                , p_data           => x_msg_data
                , p_msg_index_out  => l_msg_index_out);
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SUBSTRB(SQLERRM, 1, 240);
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg (
            p_pkg_name         => 'pa_project_structure_utils'
           ,p_procedure_name   => 'check_exp_item_dates');
    END IF;

  END check_exp_item_dates;

end PA_PROJECT_STRUCTURE_UTILS;

/

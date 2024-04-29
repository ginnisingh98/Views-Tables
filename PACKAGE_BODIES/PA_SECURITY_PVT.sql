--------------------------------------------------------
--  DDL for Package Body PA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SECURITY_PVT" AS
 /* $Header: PASECPVB.pls 120.9.12010000.3 2009/05/27 07:34:04 nisinha ship $ */
G_PKG_NAME varchar2(30) :='PA_SECURITY_PVT';
G_responsibility_id NUMBER :=FND_GLOBAL.RESP_ID;
G_user_id NUMBER:=FND_GLOBAL.USER_ID;
G_source_type VARCHAR2(30) := '';
G_source_id NUMBER;
G_grantee_key VARCHAR2(240) := '';
G_debug_flag varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
G_source_type_id   NUMBER;
G_project_system_status_code VARCHAR2(30) := '';
G_project_roles_ins_set_id NUMBER;
G_project_roles_ins_set_name FND_OBJECT_INSTANCE_SETS.instance_set_name%TYPE := 'PA_PROJECT_ROLES';

l_api_version number :=1.0;
l_errorcode number;

/*** ----------------------------------------------- */
procedure Init_global
is
  l_emp_id NUMBER;
  l_cust_id NUMBER;
BEGIN
  G_responsibility_id := FND_GLOBAL.RESP_ID;
  G_user_id := FND_GLOBAL.USER_ID;
  G_debug_flag := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);

  SELECT employee_id, person_party_id -- Bug 4527617. Replaced customer_id with person_party_id.
  INTO l_emp_id, l_cust_id
  FROM fnd_user
  WHERE user_id=G_user_id;

  IF l_emp_id IS NOT NULL AND l_emp_id > 0 THEN
    G_source_type    := 'PERSON';
    G_source_id      := l_emp_id;
    G_grantee_key    := get_grantee_key('PERSON',l_emp_id,'Y'); -- Added 'Y' parameter for bug 3471913
    G_source_type_id := 101;
  ELSIF l_cust_id IS NOT NULL AND l_cust_id > 0 THEN
    G_source_type    := 'HZ_PARTY';
    G_source_id      := l_cust_id;
    G_grantee_key    := get_grantee_key('HZ_PARTY',l_cust_id,'Y'); -- Added 'Y' parameter for bug 3471913
    G_source_type_id := 112;
  END IF;
END;

FUNCTION get_resource_source_id RETURN NUMBER
IS
BEGIN
 RETURN G_source_id;
END get_resource_source_id;

FUNCTION get_resource_type_id RETURN NUMBER
IS
BEGIN
 RETURN G_source_type_id;
END get_resource_type_id;

FUNCTION get_project_system_status_code RETURN VARCHAR2
IS
BEGIN
 RETURN G_project_system_status_code;
END get_project_system_status_code;

FUNCTION get_grantee_key(
  p_source_type IN VARCHAR2 DEFAULT 'USER',
  p_source_id IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
  p_HZ_WF_Synch IN VARCHAR2 DEFAULT 'N') -- Modified default value to 'N' for bug 3471913
RETURN VARCHAR2 IS
  l_emp_id NUMBER;
  l_cust_id NUMBER;
  l_grantee_key VARCHAR2(240) := '';

/* Bug 3484332 - Reverted the outer join fix for performance */

  cursor get_role_for_employee(c_emp_id NUMBER) is
    select wfr.name, per.party_id
      from per_all_people_f per,
           wf_roles wfr
     where per.person_id = c_emp_id
       and per.party_id = wfr.orig_system_id /* Added outer join for bug 3417803 */
       and wfr.orig_system = 'HZ_PARTY' /* Added outer join for bug 3417803 */
       and rownum = 1;

  cursor get_role_for_customer(c_cust_id NUMBER) is
      select name
        from wf_roles
       where orig_system_id = c_cust_id
         and orig_system = 'HZ_PARTY'
         and rownum = 1;

/* Added for bug 3484332 */
   CURSOR get_party_id(c_emp_id NUMBER) IS
   SELECT per.party_id
   FROM per_all_people_f per
   WHERE per.person_id = c_emp_id;

BEGIN
  IF p_source_type='USER' THEN
    SELECT employee_id, person_party_id -- Bug 4527617. Replaced customer_id with person_party_id.
    INTO l_emp_id, l_cust_id
    FROM fnd_user
    WHERE user_id=p_source_id;

    IF l_emp_id IS NOT NULL AND l_emp_id > 0 THEN
       OPEN get_role_for_employee(l_emp_id);
       FETCH get_role_for_employee into l_grantee_key, l_cust_id;
       CLOSE get_role_for_employee;

    ELSIF l_cust_id IS NOT NULL AND l_cust_id > 0 THEN
       OPEN get_role_for_customer(l_cust_id);
       FETCH get_role_for_customer into l_grantee_key;
       CLOSE get_role_for_customer;

    END IF;

  ELSIF p_source_type='PERSON' THEN
       OPEN get_role_for_employee(p_source_id);
       FETCH get_role_for_employee into l_grantee_key, l_cust_id;
       CLOSE get_role_for_employee;
       l_emp_id := p_source_id;  -- Added for bug 3484332

  ELSIF p_source_type='HZ_PARTY' THEN
       OPEN get_role_for_customer(p_source_id);
       FETCH get_role_for_customer into l_grantee_key;
       CLOSE get_role_for_customer;
       l_cust_id := p_source_id;
  END IF;

  -- Invoke TCA API to create WF_ROLES if it does not exists
/* Bug 3417803 - Modified condition l_grantee_key = '' to l_grantee_key is null */
  IF (l_grantee_key is null OR l_grantee_key = '')
      AND  p_HZ_WF_Synch = 'Y' THEN
      /* Added get_party_id code and if condition for bug 3484332 */
    IF l_cust_id is null THEN
     OPEN get_party_id(l_emp_id);
     FETCH get_party_id into l_cust_id;
     CLOSE get_party_id;
    END IF;
    HZ_WF_Synch.SynchPersonWFRole(partyid => l_cust_id);
    OPEN get_role_for_customer(l_cust_id);
    FETCH get_role_for_customer into l_grantee_key;
    CLOSE get_role_for_customer;

  END IF;

  RETURN l_grantee_key;
END get_grantee_key;

/*** ----------------------------------------------- */

---This is the generic security API which is used for
---function security check. It applies all functions
---except confirm assignment function
---  Procedure Check User Privilege
----------------------------------------------------
Procedure check_user_privilege
  (
   p_privilege    IN  VARCHAR2,
   p_object_name   IN  VARCHAR2,
   p_object_key    IN  NUMBER,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   p_init_msg_list  IN  VARCHAR2 DEFAULT 'Y') is

-- secure_role_flag varchar2(1);
 secure_resp_flag varchar2(1);
 v_fnd_api_ret_code varchar2(1);
 i BINARY_INTEGER;
 l_exist_flag varchar2(1):='F';

Begin
  Init_global ;

  --Clear the global PL/SQL message table
  IF p_init_msg_list = 'Y' THEN
     FND_MSG_PUB.initialize;
  END IF;

  pa_debug.Init_err_stack ( 'Check User Privilege');
  x_msg_count :=0;
  x_msg_data:= null;
  x_return_status:=fnd_api.g_ret_sts_success;
  x_ret_code:=fnd_api.g_true;

------- Check for License
  IF pa_product_install_utils.check_function_licensed(p_privilege) <> 'Y'  THEN
    x_ret_code:= fnd_api.g_false;
    x_return_status:=fnd_api.g_ret_sts_success;
    RETURN;
  END IF;
------- End check for License

  If nvl(p_object_key,-999) =-999 then
    -----Not in object instance context. Check responbility level
    ------function security
    pa_debug.G_err_stage := 'check responsibility level security: not in object instance context';
    IF G_debug_flag = 'Y' THEN
       pa_debug.write_file('check_user_privilege: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    if fnd_function.test(p_privilege) then
      x_ret_code:=fnd_api.g_true;
      x_return_status:=fnd_api.g_ret_sts_success;
    else
      x_ret_code:=fnd_api.g_false;
      x_return_status:=fnd_api.g_ret_sts_success;
    end if;
    return;
  end if;

  --------check role based security ------------
  pa_debug.G_err_stage := 'check role based security';
  -- store project system status code in global variable for instance set
  IF p_object_name = 'PA_PROJECTS' THEN
    select project_system_status_code into G_project_system_status_code
      from pa_projects_all ppa,
           pa_project_statuses pps
     where ppa.project_status_code = pps.project_status_code
       and ppa.project_id = p_object_key;
  END IF;

  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_user_privilege: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  --dbms_output.put_line('before: calling fnd_data_sec');
  --dbms_output.put_line('get_grantee_key:'||get_grantee_key);
  --dbms_output.put_line('p_privilege:'||p_privilege);
  --dbms_output.put_line('p_object_name:'||p_object_name);
  --dbms_output.put_line('p_object_key:'||p_object_key);


  v_fnd_api_ret_code:=fnd_data_security.check_function(
               p_api_version =>l_api_version,
               p_function   =>p_privilege,
               p_object_name  => p_object_name,
               p_instance_pk1_value=>p_object_key,
               p_instance_pk2_value => NULL,
               p_instance_pk3_value => NULL,
               p_instance_pk4_value  => NULL,
               p_instance_pk5_value  => NULL );
               -- p_user_name   => get_grantee_key ); Commented for Bug 4498436.

         --dbms_output.put_line('after calling fnd_data_sec');
         --dbms_output.put_line('v_fnd_api_ret_code:'||v_fnd_api_ret_code);
  if v_fnd_api_ret_code=fnd_api.g_ret_sts_error
     OR v_fnd_api_ret_code=fnd_api.g_ret_sts_unexp_error then
    x_ret_code:=fnd_api.g_false;
    x_return_status:=fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get
                (p_count             =>      x_msg_count ,
                 p_data              =>      x_msg_data
                 );
    return;
  end if;

  if v_fnd_api_ret_code=fnd_api.g_true then
    x_ret_code:= fnd_api.g_true;
    x_return_status:=fnd_api.g_ret_sts_success;
    return;
  end if;

  if v_fnd_api_ret_code=fnd_api.g_false then
    x_ret_code:= fnd_api.g_false;
    x_return_status:=fnd_api.g_ret_sts_success;
    ----not return from here. need to continue to do
    ----responsibility level check
  end if;
  -----------End of check role based security-----------

  pa_debug.G_err_stage := 'get secure_resp_flag';
  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_user_privilege: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;

  -----check if responsibility based security is enforced
  ---(check if any of the roles the user plays on the object
  ----does not have a menu_id or the user does not play any role on the object)
  IF p_object_name='PA_PROJECTS' THEN
    -----------fixing bug 1484710-------------------
    PA_SECURITY.Initialize(X_user_id =>G_user_id  ,
                           X_calling_module  => 'PAXPREPR');
    ----------end of fixing bug 1484710------------
  END IF;

  secure_resp_flag:=check_sec_by_resp
       (
       G_user_id ,
       p_object_name ,
       G_source_type  ,
       p_object_key  );


      if  secure_resp_flag =FND_API.G_RET_STS_UNEXP_ERROR then
         x_ret_code:=fnd_api.g_false;
         x_return_status:=fnd_api.g_ret_sts_unexp_error;

         FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
         return;
      end if;

  -----Check responsibility level function security in these cases:
  -----1. The user plays unsecured roles (roles without menu) on the object
  -----2. The user doesn't play any roles (instance assignment) on the object

  if  secure_resp_flag=fnd_api.g_true then
    pa_debug.G_err_stage := 'check responsibility level security: in object context';
    IF G_debug_flag = 'Y' THEN
       pa_debug.write_file('check_user_privilege: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    if p_object_name='PA_PROJECTS' then
      if pa_security.allow_update (p_object_key)<>'Y' then
        x_ret_code:=fnd_api.g_false;
        x_return_status:=fnd_api.g_ret_sts_success;
        return;
      end if;
    end if;

    if fnd_function.test(p_privilege) then
      x_ret_code:=fnd_api.g_true;
      x_return_status:=fnd_api.g_ret_sts_success;
      return;
    end if;

    x_ret_code:=fnd_api.g_false;
    x_return_status:=fnd_api.g_ret_sts_success;

   ---The following code is for testing the error page
  /* fnd_message.set_name('PA','PA_SEC_NO_ACCESS');
       fnd_msg_pub.ADD;
       FND_MSG_PUB.Count_And_Get
           (p_count             =>      x_msg_count ,
            p_data              =>      x_msg_data
          ); */

    return;
  end if ;
Exception
  when others then
    pa_debug.G_err_stage := 'exceptions raised';
    IF G_debug_flag = 'Y' THEN
       pa_debug.write_file('check_user_privilege: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    fnd_msg_pub.add_exc_msg
       (p_pkg_name => G_PKG_NAME,
        p_procedure_name =>'CHECK_USER_PRIVILEGE' );
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    x_ret_code :=fnd_api.g_false;
    FND_MSG_PUB.Count_And_Get
           (p_count             =>      x_msg_count ,
            p_data              =>      x_msg_data
            );
end check_user_privilege;


-----The following code is commented out because of instance sets and
-----resource roles like project authority and resource authority are not
-----in pa_project_parties
-----there is no perfect way to check if role based security is enforced or not

 /*---This API check if role based security is enforced or not
 ----function check_sec_by_role
 -----------------------------------------
  function  check_sec_by_role
  (
   p_user_id in number,
   p_object_name in varchar2,
   p_source_type  in varchar2,
   p_object_key in number  ) return varchar2  is

  cursor c_role_sec_enabled is
  select 'Y'
  from fnd_user users,
       pa_project_parties ppp,
       pa_project_role_types roletypes
  where decode (p_source_type, 'PERSON', users.employee_id,
                               'HZ_PARTY', users.customer_id)
        = ppp.resource_source_id
    and ppp.resource_type_id= decode(p_source_type, 'PERSON', 101,
                                                    'HZ_PARTY', 112,
                                                    111)
    and ppp.project_role_id=roletypes.project_role_id
    and users.user_id =p_user_id
    and ppp.object_id=p_object_key
    and ppp.object_type=p_object_name
    and roletypes.menu_id is not null
    and ROWNUM=1;

v_dummy varchar2(1);

Begin
  open c_role_sec_enabled;
  fetch c_role_sec_enabled into v_dummy;
  if c_role_sec_enabled%found then
       close c_role_sec_enabled; -- Bug #2994870: closing the cursor.
       return fnd_api.g_true;
  else
       close c_role_sec_enabled; -- Bug #2994870: closing the cursor.
       return fnd_api.g_false;
  end if;
Exception
    when others then
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg
        (p_pkg_name => G_PKG_NAME,
         p_procedure_name => 'check_sec_by_role');
       end if;
     return fnd_api.g_ret_sts_unexp_error;
end;*/


 ---This API check if responsibility based security is enforced or not
 ----funcrion check_sec_by_resp
 -----------------------------------------
  Function  check_sec_by_resp
  (
   p_user_id in number,
   p_object_name in varchar2,
   p_source_type  in varchar2,
   p_object_key in number  ) return varchar2 is

  cursor c_unsecured_role is
  select 'Y'
  from fnd_user users,
       pa_project_parties ppp,
       --pa_project_role_types roletypes --bug 4004821
       pa_project_role_types_b roletypes
  where decode (p_source_type, 'PERSON', users.employee_id,
                               'HZ_PARTY', users.person_party_id) -- Bug 4527617. Replaced customer_id with person_party_id.
        = ppp.resource_source_id
    and ppp.resource_type_id= decode(p_source_type,'PERSON',101,
                                                   'HZ_PARTY', 112,
                                                   111)
    and ppp.project_role_id=roletypes.project_role_id
    and users.user_id =p_user_id
    and ppp.object_id=p_object_key
    and ppp.object_type=p_object_name
    and roletypes.menu_id is null
    and roletypes.role_party_class = 'PERSON'   --bug 4004821
    and ROWNUM=1;

  cursor c_any_role is
  select 'Y'
  from fnd_user users,
       pa_project_parties ppp
  where decode (p_source_type, 'PERSON', users.employee_id,
                               'HZ_PARTY', users.person_party_id) -- Bug 4527617. Replaced customer_id with person_party_id.
        = ppp.resource_source_id
    and ppp.resource_type_id= decode(p_source_type,'PERSON',101,
                                                   'HZ_PARTY', 112,
                                                   111)
    and users.user_id =p_user_id
    and ppp.object_id=p_object_key
    and ppp.object_type=p_object_name
    and ROWNUM=1;

    ------There might be an issue for pre-seeded resource roles,like resource authority
    ------or project authority. The assignments of these roles are not in pa_project_parties.
    ---- check_sec_by_resp will always return true for these assignments.

    /*      select 'Y'
          from dual
          where not exists
          (select 'Y'
           from fnd_grants fg,
                fnd_objects obj
           where fg.object_id=obj.object_id
            and  obj.obj_name=p_object_name
            and  fg.grantee_type='USER'
            and  fg.grantee_key='PER:'||to_char(get_party_id)
            and  fg.instance_type='INSTANCE'
            and  fg.instance_pk1_value=p_object_key);
        ---we have not considered the instance sets in fnd_grants
        -- We may need to enhance this api to consider the instance sets
        ---(right now we only have instance sets for project authority and
        ----resource authority)*/

v_dummy varchar2(1);

Begin
  OPEN c_unsecured_role;
  FETCH c_unsecured_role INTO v_dummy;
  IF c_unsecured_role%found THEN
    --Check responsibility if an unsecured role is found
    CLOSE c_unsecured_role;
    RETURN fnd_api.g_true;
  END IF;
  CLOSE c_unsecured_role;

  OPEN c_any_role;
  FETCH c_any_role INTO v_dummy;
  IF c_any_role%found THEN
/*nisinha bug#8541727 */
    --Check responsibility if no roles are found
    CLOSE c_any_role;
    RETURN fnd_api.g_true;
  END IF;
  CLOSE c_any_role;

  IF p_object_name IN ('PA_PROJECTS')
     AND pa_security.g_cross_project_user='Y' THEN
    --profile option override this check
    RETURN fnd_api.g_true;
  END IF;

  RETURN fnd_api.g_false;

Exception
    when others then
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         fnd_msg_pub.add_exc_msg
        (p_pkg_name => G_PKG_NAME,
         p_procedure_name => 'check_sec_by_resp');
       end if;
       return fnd_api.g_ret_sts_unexp_error;
end;


--function get_resource_person_id
--This function will return person_id given a resource_id
FUNCTION get_resource_person_id(p_resource_id NUMBER) RETURN NUMBER IS
  ret NUMBER;
BEGIN
  SELECT person_id INTO ret
  FROM pa_resource_txn_attributes
  WHERE resource_id = p_resource_id
  AND person_id IS NOT NULL;

  RETURN ret;
END;

------------------------------------------------------------------
--This API is currently owned by PJR team (Alex.Yang)
------------------------------------------------------------------
----This API wraps all logic for check the
----confirm assignment privilege.
---procedure check_confirm_asmt
---p_resource_id or p_resource_name: only one of them is necessary
--------------------------------------------------
 procedure check_confirm_asmt
          (p_project_id in number,
           p_resource_id in number,
           p_resource_name in varchar2,
           p_privilege in varchar2,
           p_start_date in date DEFAULT SYSDATE,
           p_init_msg_list  IN VARCHAR2 DEFAULT 'T',    -- Added for bug 5130421
           x_ret_code out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_msg_count out NOCOPY varchar2, --File.Sql.39 bug 4440895
           x_msg_data out NOCOPY varchar2     ) is --File.Sql.39 bug 4440895

v_resource_id number ;
v_resource_type_id number;
v_ret_code varchar2(1);
v_return_status varchar2(1);
v_error_message_code varchar2(30);
v_resource_org_id number;
v_resource_emp_id number;
v_project_org_id number;
v_fnd_api_ret_code varchar2(1);
v_resource_super_user varchar2(1) := 'N';
l_fnd_function_test boolean:=false; -- Added for Bug2970209
begin

  Init_global ;

  --Clear the global PL/SQL message table : Changed for bug 5130421
  IF p_init_msg_list = 'T' THEN
	  FND_MSG_PUB.initialize;
  END IF;

  pa_debug.Init_err_stack ( 'check_confirm_asmt');
  x_msg_count :=0;
  x_msg_data:= null;
  x_return_status:=fnd_api.g_ret_sts_success;
  x_ret_code:=fnd_api.g_true;

  --Return false if login user is not an employee
  IF G_source_type<>'PERSON' THEN
    x_ret_code:=FND_API.G_FALSE;
    RETURN;
  END IF;

    -----Initialization: get resource id, resource org, project org
  pa_debug.G_err_stage := 'Initialization: get resource id, resource org, project org';
  -- Bug 4359282 : Added check before calling pa_debug.write_file
  IF G_debug_flag = 'Y' THEN
	pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
  END IF;

------- Check for License
  IF pa_product_install_utils.check_function_licensed(p_privilege) <> 'Y'  THEN
    x_ret_code:= fnd_api.g_false;
    RETURN;
  END IF;
------- End check for License


    v_resource_id:=p_resource_id;
    If p_resource_id is null then
          pa_resource_utils.Check_ResourceName_Or_Id(
                        P_RESOURCE_ID=>p_resource_id           ,
                        P_RESOURCE_NAME=>p_resource_name         ,
                        P_CHECK_ID_FLAG=>'Y'                     ,
                        X_RESOURCE_ID=>v_resource_id           ,
                        X_RESOURCE_TYPE_ID=>v_resource_type_id      ,
                        X_RETURN_STATUS=>v_return_status         ,
                        X_ERROR_MESSAGE_CODE=>v_error_message_code     );
          if v_return_status <>fnd_api.g_ret_sts_success then
                        x_msg_count := x_msg_count+1;
                        x_msg_data  := v_error_message_code;
                        x_return_status := fnd_api.g_ret_sts_error;
                        x_ret_code:=fnd_api.g_false;
                        FND_MSG_PUB.add_exc_msg
                        (p_pkg_name =>'pa_resource_utils',
                         p_procedure_name => 'Check_ResourceName_Or_Id',
                         p_error_text => v_error_message_code);
                        RETURN;
          end IF;
   end if;

     get_resource_org_id
          (v_resource_id ,
           p_start_date ,
           v_resource_org_id ,
           v_return_status ,
           v_error_message_code   )   ;
     if v_return_status <>fnd_api.g_ret_sts_success then
                x_msg_count := x_msg_count+1;
                x_msg_data  := v_error_message_code;
                x_return_status := v_return_status;
                x_ret_code:=fnd_api.g_false;
                --Bug# 6134740 Fix start
                /*FND_MSG_PUB.add_exc_msg
                (p_pkg_name =>G_PKG_NAME,
                 p_procedure_name => 'GET_RESOURCE_ORG_ID',
                 p_error_text => v_error_message_code);*/
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                                     ,p_msg_name         => v_error_message_code);
                --Bug# 6134740 Fix end
                RETURN;
     end IF;

/* Bug 2970209 -- Commented the code to call check_user_privilege. Now new
   code is added in the last to check for resource autority */
/*------- Check if the user has resource authority on the resource
  pa_debug.G_err_stage := 'Check if the user has resource authority on the resource';
  pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

    check_user_privilege(p_privilege => p_privilege,
			p_object_name => 'ORGANIZATION',
			p_object_key => v_resource_org_id,
			x_ret_code => x_ret_code,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

    IF x_return_status<>fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

     if x_ret_code=fnd_api.g_true then
      return;
     end if;
     ---------End of check if the user has resource authority------
*/

  -- Bug 2970209 : Getting the value from fnd_function.test, which will be used at other places in this code
  l_fnd_function_test:=fnd_function.test(p_privilege);

  -- Bug 2991490 Added the following condition.
  -- If the logged in user is the resource on which the action is being performed, then grant privilege to the user.

  IF (p_resource_id = pa_resource_utils.get_resource_id(G_source_id) and l_fnd_function_test = true) THEN
      x_ret_code:=fnd_api.g_true;
      x_return_status:=fnd_api.g_ret_sts_success;
      return;
  END IF;


  -----------Check if user is Resource Super User--------------
  pa_debug.G_err_stage := 'Check if the user is a resource super user';
  IF G_debug_flag = 'Y' THEN
	  pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
  END IF;

  v_resource_super_user := fnd_profile.value_specific('PA_SUPER_RESOURCE',
                                                      G_USER_ID,
                                                      G_RESPONSIBILITY_ID ,
                                                      fnd_global.resp_appl_id);
  IF v_resource_super_user = 'Y' THEN

    pa_debug.G_err_stage := 'check FND function security';

    IF G_debug_flag = 'Y' THEN
	pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
    END IF;

    if l_fnd_function_test then
      x_ret_code:=fnd_api.g_true;
      x_return_status:=fnd_api.g_ret_sts_success;
      return;
    else
      x_ret_code:=fnd_api.g_false;
      x_return_status:=fnd_api.g_ret_sts_success;
    end if;

  END IF;

  -----------End Resource Super User Check-------------------

  ---------Check if the user is the manager of the resource in HR hierarchy
  pa_debug.G_err_stage := 'Check if the user is the manager of the resource in HR hierarchy';
  IF G_debug_flag = 'Y' THEN
	pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
  END IF;

-- Bug 2970209 The following condition is not needed and it is unambiguoys, because we are defaulting x_ret_code as true
-- so this check will not be fired if v_resource_super_user <> Y
-- if x_ret_code =fnd_api.g_false  then
          v_resource_emp_id := get_resource_person_id(v_resource_id);
          check_manager_relation
             (v_resource_emp_id,
--              G_user_emp_id,
              G_source_id,
              p_start_date,
              v_ret_code,
              v_return_status,
              v_error_message_code);

         if v_return_status <>fnd_api.g_ret_sts_success then
              x_msg_count := x_msg_count+1;
              x_msg_data  := v_error_message_code;
              x_return_status := v_return_status;
              x_ret_code:=fnd_api.g_false;
              FND_MSG_PUB.add_exc_msg
              (p_pkg_name =>G_PKG_NAME,
               p_procedure_name => 'CHECK_MANAGER_RELATION',
               p_error_text => v_error_message_code);
              RETURN;
          end if;

         if (v_ret_code=fnd_api.g_true and l_fnd_function_test = true)then
              x_ret_code:=v_ret_code;
              x_return_status:=v_return_status;
	      return;
	 else
              x_ret_code:=fnd_api.g_false;
              x_return_status:=v_return_status;
	 end if;

-- end if;
     -------------End of check HR hierarchy---------------------
     -- Bug 2970209 Added role based security here
     --------check role based security ------------
     pa_debug.G_err_stage := 'check role based security';
     IF G_debug_flag = 'Y' THEN
         pa_debug.write_file('check_confirm_asmt: ' ||  'LOG', pa_debug.G_err_stage);
     END IF;

--dbms_output.put_line('p_privilege IS : ' || p_privilege);
--dbms_output.put_line('v_resource_org_id IS : ' || v_resource_org_id);
--dbms_output.put_line('get_grantee_key IS : ' || get_grantee_key);

     v_fnd_api_ret_code:=fnd_data_security.check_function(
               p_api_version =>l_api_version,
               p_function   => p_privilege,
               p_object_name  => 'ORGANIZATION',
               p_instance_pk1_value=>v_resource_org_id,
               p_instance_pk2_value => NULL,
               p_instance_pk3_value => NULL,
               p_instance_pk4_value  => NULL,
               p_instance_pk5_value  => NULL );
               -- p_user_name   => get_grantee_key); Commented for Bug 4498436.
--dbms_output.put_line('fter fnd_data_security.check_function');
--dbms_output.put_line('v_fnd_api_ret_code IS : ' || v_fnd_api_ret_code);

     if v_fnd_api_ret_code=fnd_api.g_ret_sts_error
     OR v_fnd_api_ret_code=fnd_api.g_ret_sts_unexp_error then
            x_ret_code:=fnd_api.g_false;
            x_return_status:=fnd_api.g_ret_sts_unexp_error;
            FND_MSG_PUB.Count_And_Get
                (p_count             =>      x_msg_count ,
                 p_data              =>      x_msg_data
                 );
         return;
     end if;

     -- Bug 4099469 changes - If the person has organization authority
     -- over the resource organization and the call to FND's security
     -- returns TRUE, then give access. At this time do not check if the
     -- function is in the responsibility.
     -- Hence commenting out check of l_fnd_function_test

     --if (v_fnd_api_ret_code=fnd_api.g_true and l_fnd_function_test = true)then
     if (v_fnd_api_ret_code=fnd_api.g_true) then
           x_ret_code:= fnd_api.g_true;
           x_return_status:=fnd_api.g_ret_sts_success;
          return;
     end if;


     x_ret_code:= fnd_api.g_false;
     x_return_status:=fnd_api.g_ret_sts_success;
     return;

  -----------End of check role based security-----------


Exception
   when others then
  pa_debug.G_err_stage := SUBSTR(SQLERRM, 1, 200);
  IF G_debug_flag = 'Y' THEN
	pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
  END IF;
       fnd_msg_pub.add_exc_msg
       (p_pkg_name => G_PKG_NAME,
        p_procedure_name =>'CHECK_CONFIRM_ASMT' );
        x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count:=x_msg_count+1;
        x_ret_code :=fnd_api.g_false;
        raise;
 end;



----This API is for getting the resource organization id
------Procedure get_resource_org_id
------------------------------------------------
  PROCEDURE get_resource_org_id
         (p_resource_id IN NUMBER,
          p_start_date IN DATE,
          x_resource_org_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_error_message_code OUT NOCOPY VARCHAR2  ) IS --File.Sql.39 bug 4440895
  v_person_id NUMBER;
  v_org_id NUMBER;
  l_future_term_wf_flag   pa_resources.future_term_wf_flag%TYPE := NULL  ; --Added for Bug 6056112

  --If p_start_date is null, the cursor will select org_id from
  --the first assignment available from sysdate
  -- Bug 2911451 - Included condition for Assignment_type ='E'
  CURSOR c_org_id IS
    SELECT organization_id
    FROM per_all_assignments_f -- Bug 4359282: Changed from per_assignments_f to all
    WHERE person_id=v_person_id
      AND TRUNC(effective_start_date)<=TRUNC(NVL(p_start_date, effective_start_date))
      AND TRUNC(NVL(p_start_date,SYSDATE))<=TRUNC(effective_end_date)
      AND primary_flag='Y'
      AND Assignment_type in ('E', 'C')
    ORDER BY effective_start_date;

/* Added for Bug 6056112 */
  CURSOR c_fut_term_org_id IS
    SELECT RESOURCE_ORGANIZATION_ID
    FROM pa_resources_denorm
    WHERE person_id = v_person_id
      AND TRUNC(resource_effective_start_date)<=TRUNC(NVL(p_start_date, resource_effective_start_date))
      AND TRUNC(NVL(p_start_date,SYSDATE))<=TRUNC(resource_effective_end_date);

  BEGIN
    x_return_status:=fnd_api.g_ret_sts_success;
    v_person_id:=get_resource_person_id(p_resource_id);

     /* Added for Bug 6056112 */
     SELECT nvl(future_term_wf_flag,'N')
     INTO l_future_term_wf_flag
     FROM pa_resources
     WHERE resource_id = p_resource_id;

    OPEN c_org_id;
    FETCH c_org_id INTO x_resource_org_id;
    IF c_org_id%NOTFOUND THEN
      /* Start of Changes for Bug 6056112 */
      IF (nvl(l_future_term_wf_flag,'N') = 'Y') THEN
        OPEN c_fut_term_org_id;
        FETCH c_fut_term_org_id INTO x_resource_org_id;
        IF c_fut_term_org_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_RESOURCE_ORG_AMBIGUOUS';
        END IF ;
        CLOSE c_fut_term_org_id;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_RESOURCE_ORG_AMBIGUOUS';
      END IF ;
      /* End of Changes for Bug 6056112 */
    END IF;
    CLOSE c_org_id; /* Bug #2994870: Closing the cursor. */
  END get_resource_org_id;

 -----This API is for getting the project owning organization
 ------Procedure get_project_org_id
 ------------------------------------------------
 procedure get_project_org_id
         (p_project_id in number,
          x_project_org_id out NOCOPY number, --File.Sql.39 bug 4440895
          x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_error_message_code out NOCOPY varchar2  ) is --File.Sql.39 bug 4440895
 begin
    x_return_status:=fnd_api.g_ret_sts_success;
    select CARRYING_OUT_ORGANIZATION_ID
    into  x_project_org_id
    from pa_projects_all
    where project_id=p_project_id;
 exception
     WHEN NO_DATA_FOUND THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_error_message_code := 'PA_PROJ_ORG_AMBIGUOUS';
     WHEN TOO_MANY_ROWS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
                x_error_message_code := 'PA_PROJ_ORG_AMBIGUOUS';
      WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 end;


--This procedure checks if the p_manager_id is a HR manager
--of p_person_id. It checks the HR supervisor hierarchy
--for all managers of the given person p_person_id
--Procedure check_manager_relation
--------------------------------------------------------
PROCEDURE check_manager_relation
         (p_person_id in number,
          p_manager_id in number,
          p_start_date in date,
          x_ret_code out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_return_status out NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_error_message_code out NOCOPY varchar2  ) is --File.Sql.39 bug 4440895
l_is_manager VARCHAR2(1) := 'N';

--Added for bug 5916094
 l_person_id NUMBER;
 l_mgr_id NUMBER;
 l_mgr_str VARCHAR2(4000);
 l_mgr_str1 VARCHAR2(20);

BEGIN
  x_return_status:=fnd_api.g_ret_sts_success;
  x_ret_code:=fnd_api.g_false;

  BEGIN
  /* Commented for bug 5916094
 There can exists overlapping RM for a resource for same 2 resources for a same duration
 Like for a duration A is manager of B and for same duration B is manager of A

    SELECT 'Y'
    INTO l_is_manager
    FROM dual
    WHERE p_manager_id IN ( SELECT  Manager_id
                            FROM   	pa_resources_denorm
                            WHERE   nvl(p_start_date, trunc(sysdate)) BETWEEN resource_effective_start_date
                                                                      AND resource_effective_end_date
                            AND     manager_id is not null
                            START WITH person_id = p_person_id
                            CONNECT BY PRIOR manager_id = person_id
                            AND     manager_id <> prior person_id
                            AND     nvl(p_start_date, trunc(sysdate)) BETWEEN resource_effective_start_date
                                                                      AND resource_effective_end_date);

    */

 --Added below code  for bug 5916094

 l_person_id := p_person_id;
 l_mgr_str := ',' || p_manager_id || ',';

 LOOP
         BEGIN
                 SELECT manager_id INTO l_mgr_id
                 FROM pa_resources_denorm WHERE
                 person_id = l_person_id
                 AND nvl(p_start_date, trunc(sysdate))
                         BETWEEN resource_effective_start_date  AND resource_effective_end_date;

                 IF l_mgr_id IS NULL THEN
                         l_is_manager := 'N';
                         EXIT;
                 ELSIF l_mgr_id = p_manager_id THEN
                         l_is_manager := 'Y';
                         EXIT;
                 ELSE
                         l_person_id := l_mgr_id;
                         l_mgr_str1 := ',' || l_mgr_id || ',';
                 END IF;

                 IF instr(l_mgr_str, l_mgr_str1) <> 0 THEN
                         l_is_manager := 'N';
                         EXIT;
                 ELSE
                         l_mgr_str := l_mgr_str || l_mgr_str1;
                 END IF;

         EXCEPTION
                 WHEN OTHERS  THEN
                         EXIT;
         END;

 END LOOP;

    IF l_is_manager = 'Y' THEN
      x_ret_code:=fnd_api.g_true;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_ret_code:=fnd_api.g_false;
  END;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_ret_code:=fnd_api.g_false;
    raise;
END;


-- This API is called when a person is assigned to a new role
-- from create_project_party
PROCEDURE grant_role
  (
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   p_debug_mode      in varchar2  default 'N',
   p_project_role_id IN  number,
   p_object_name     IN  VARCHAR2,
   p_instance_type   IN  VARCHAR2,
   p_object_key      IN  NUMBER,
   p_party_id        IN  NUMBER,
   p_source_type     IN  varchar2,
   x_grant_guid      OUT NOCOPY raw, --File.Sql.39 bug 4440895
   x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

l_success varchar2(1);
l_error_code number;
l_instance_set_id number;
l_grantee_key fnd_grants.grantee_key%TYPE;
l_grant_exists VARCHAR2(1);
l_status_level VARCHAR2(30);
l_default_menu_name fnd_menus.menu_name%TYPE := null;
l_status_type_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_status_code_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_menu_name_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_exp_error varchar2(1) := 'F';
l_unexp_error  varchar2(1) := 'F';
l_parameter2 fnd_grants.parameter2%TYPE;
l_role_status_menu_id_tbl SYSTEM.pa_num_tbl_type := null;
l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_error_message_code VARCHAR2(30);

begin

  --dbms_output.put_line('pa_security_pvt.grant_role');

  x_return_status:=fnd_api.g_ret_sts_success;
  x_msg_count:=0;
  x_msg_data:=null;

  l_grantee_key:=get_grantee_key(p_source_type, p_party_id, 'Y');   -- Added 'Y' parameter for bug 3471913

  -- for role-based security, check to see the this person already has a FND_GRANTS
  -- record for this given role. Only grant if person does not have such records.
  IF p_project_role_id IS NOT NULL AND p_object_name = 'PA_PROJECTS' THEN
    pa_security_pvt.check_grant_exists(p_project_role_id => p_project_role_id,
                                       p_instance_type => 'SET',
                                       p_instance_set_name => G_project_roles_ins_set_name,
                                       p_grantee_type => 'USER',
                                       p_grantee_key => l_grantee_key,
                                       x_instance_set_id => l_instance_set_id,
                                       x_ret_code => l_grant_exists
                                       );

    --dbms_output.put_line('grant_exist: '||l_grant_exists);
    --dbms_output.put_line('instance_set_id: '||l_instance_set_id);

    IF l_grant_exists = 'F' THEN

     -- returns all menus-statuses associated with this role
     pa_role_status_menu_utils.Get_Role_Status_Menus(
               p_role_id            => p_project_role_id
              ,x_status_level       => l_status_level
              ,x_default_menu_name  => l_default_menu_name
              ,x_status_type_tbl    => l_status_type_tbl
              ,x_status_code_tbl    => l_status_code_tbl
              ,x_menu_name_tbl      => l_menu_name_tbl
              ,x_role_status_menu_id_tbl => l_role_status_menu_id_tbl
              ,x_return_status      => l_return_status
              ,x_error_message_code => l_error_message_code);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name => l_error_message_code );

     ELSE

      --dbms_output.put_line('default menu name: '||l_default_menu_name);

      IF l_default_menu_name is not null AND l_return_status = fnd_api.g_ret_sts_success THEN

        IF l_status_code_tbl IS NULL OR l_status_code_tbl.COUNT = 0 THEN
          l_parameter2 := 'NON_STATUS_BASED';
        ELSE
          l_parameter2 := 'DEFAULT';
        END IF;

        --dbms_output.put_line('before calling grant_function');
        --dbms_output.put_line('l_grantee_key: '||l_grantee_key);

        fnd_grants_pkg.grant_function
        (
        p_api_version           =>  l_api_version,
        p_menu_name             =>  l_default_menu_name,
        p_object_name           =>  'PA_PROJECTS',
        p_instance_type         =>  'SET',
        p_instance_set_id       =>  l_instance_set_id,
        p_instance_pk1_value    =>  null,
        p_instance_pk2_value    =>  null,
        p_instance_pk3_value    =>  null,
        p_instance_pk4_value    =>  null,
        p_instance_pk5_value    =>  null,
        p_grantee_type          => 'USER',
        p_grantee_key           =>  l_grantee_key,
        p_parameter1            =>  p_project_role_id,
        p_parameter2            =>  l_parameter2,
        p_parameter3            =>  null,
        p_start_date            =>  sysdate,
        p_end_date              =>  null,
        x_grant_guid            =>x_grant_guid,
        x_success               =>l_success,
        x_errorcode             =>l_error_code
        );

       --dbms_output.put_line('grant_function: '||l_success);

        if l_success <> fnd_api.g_true then
          if l_error_code >0 then
            l_exp_error := 'T';
          else
            l_unexp_error := 'T';
          end if;
        end if;

        IF l_status_code_tbl IS NOT NULL AND l_status_code_tbl.COUNT > 0 THEN

         FOR i IN l_status_code_tbl.FIRST .. l_status_code_tbl.LAST LOOP

          --dbms_output.put_line('status menu name: '||l_menu_name_tbl(i));

          fnd_grants_pkg.grant_function
          (
          p_api_version           =>  l_api_version,
          p_menu_name             =>  l_menu_name_tbl(i),
          p_object_name           =>  'PA_PROJECTS',
          p_instance_type         =>  'SET',
          p_instance_set_id       =>  l_instance_set_id,
          p_instance_pk1_value    =>  null,
          p_instance_pk2_value    =>  null,
          p_instance_pk3_value    =>  null,
          p_instance_pk4_value    =>  null,
          p_instance_pk5_value    =>  null,
          p_grantee_type          => 'USER',
          p_grantee_key           =>  l_grantee_key,
          p_parameter1            =>  p_project_role_id,
          p_parameter2            =>  l_status_level,
          p_parameter3            =>  l_status_code_tbl(i),
          p_parameter4            =>  l_role_status_menu_id_tbl(i),
          p_start_date            =>  sysdate,
          p_end_date              =>  null,
          x_grant_guid            =>  x_grant_guid,
          x_success               =>  l_success,
          x_errorcode             =>  l_error_code
          );

       --dbms_output.put_line('grant_function: '||l_success);


          if l_success <> fnd_api.g_true then
            if l_error_code >0 then
              l_exp_error := 'T';
            else
              l_unexp_error := 'T';
            end if;
          end if;

        END LOOP;
       END IF; -- IF l_status_code_tbl IS NOT NULL OR l_status_code_tbl.COUNT > 0 THEN

       if l_exp_error = 'F' and l_unexp_error = 'F' then
         l_return_status:=fnd_api.g_ret_sts_success;
       else
         if l_unexp_error = 'T' then
           l_return_status:=fnd_api.g_ret_sts_unexp_error;
         else
           l_return_status:=fnd_api.g_ret_sts_error;
         end if;
       end if;

      END IF; -- IF l_default_menu_id is not null THEN

     END IF; -- IF pa_role_status_menu_utils.Get_Role_Status_Menus errors out;
    END IF; -- IF l_grant_exists = 'F'

  END IF; --IF p_project_role_id IS NOT NULL AND p_object_name = 'PA_PROJECTS' THEN

  --dbms_output.put_line('l_exp_error: '||l_exp_error||' l_unexp_error: '||l_unexp_error);
  x_return_status := l_return_status;

  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
  END IF;

exception
  when others then
    raise;
end grant_role;


-- This API is called when Organization Authority is granted
-- to specified resources.
PROCEDURE grant_org_authority
  (
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   p_debug_mode      in varchar2  default 'N',
   p_project_role_id IN  number,
   p_menu_name       in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_source_type    IN  varchar2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_grant_guid       OUT NOCOPY raw, --File.Sql.39 bug 4440895
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS
v_menu_name varchar2(30);
l_success varchar2(1);
l_error_code number;
l_instance_pk1_value number;
l_instance_set_id number;
l_grantee_key varchar2(240);
l_object_key_type varchar2(8);

begin

  --Clear the global PL/SQL message table
  -- FND_MSG_PUB.initialize; commented the call for Bug 2887390

  --dbms_output.put_line('inside grant role');
  x_return_status:=fnd_api.g_ret_sts_success;
  x_msg_count:=0;
  x_msg_data:=null;
  if p_menu_name is null then
     v_menu_name:=get_menu_name(p_project_role_id);
  else
     v_menu_name:=p_menu_name;
  end if;
--  l_grantee_key:='PER:'||to_char(p_party_id);
  l_grantee_key:=get_grantee_key(p_source_type, p_party_id, 'Y');  -- Added 'Y' parameter for bug 3471913
  if v_menu_name is not null then
    if p_object_key_type='INSTANCE' then
       l_instance_pk1_value:=p_object_key;
       l_instance_set_id:=null;
       l_object_key_type:='INSTANCE';
    else
       l_instance_set_id:=p_object_key;
       l_instance_pk1_value:=null;
       l_object_key_type:='SET';
    end if;

   fnd_grants_pkg.grant_function
  (
   p_api_version   =>l_api_version,
   p_menu_name     =>v_menu_name,
   p_object_name   =>p_object_name,
   p_instance_type  =>l_object_key_type,
   p_instance_set_id  =>l_instance_set_id,
   p_instance_pk1_value =>l_instance_pk1_value,
   p_instance_pk2_value =>null,
   p_instance_pk3_value =>null,
   p_instance_pk4_value =>null,
   p_instance_pk5_value =>null,
   p_grantee_type   => 'USER',
   p_grantee_key    =>l_grantee_key,
   p_start_date     =>p_start_date,
   p_end_date       =>p_end_date,
   x_grant_guid     =>x_grant_guid,
   x_success        =>l_success,
   x_errorcode      =>l_error_code
  ) ;
  if l_success=fnd_api.g_true then
     x_return_status:=fnd_api.g_ret_sts_success;
  else
    if l_error_code >0 then
       x_return_status:=fnd_api.g_ret_sts_error;
    else
       x_return_status:=fnd_api.g_ret_sts_unexp_error;
    end if;
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
   end if;
end if;
exception
  when others then
    raise;
end;

 PROCEDURE revoke_grant
  (
    p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_debug_mode     in varchar2  default 'N',
    p_grant_guid       in raw,
   x_return_status  OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS
  l_success varchar2(1);
 l_error_code number;

begin

  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

 x_return_status :=fnd_api.g_ret_sts_success;
 x_msg_count:=0;
 x_msg_data :=null;
 --dbms_output.put_line('inside pa revoke_grants');
 fnd_grants_pkg.revoke_grant
  (
   p_api_version   =>l_api_version,
   p_grant_guid      =>p_grant_guid,
   x_success       =>l_success,
   x_errorcode     =>l_error_code
  );

  if l_success=fnd_api.g_true then
    x_return_status:=fnd_api.g_ret_sts_success;
  else
    if l_error_code >0 then
       x_return_status:=fnd_api.g_ret_sts_error;
    else
       x_return_status:=fnd_api.g_ret_sts_unexp_error;
    end if;
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
  end if;
exception
  when others then
    raise;
end;


PROCEDURE revoke_role
  (
   p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_debug_mode     in varchar2  default 'N',
   p_project_role_id            IN  number,
   p_menu_name         in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  NUMBER,
   p_party_id       IN  NUMBER,
   p_source_type    in varchar2,
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS
l_menu_id NUMBER ;
l_object_id NUMBER;
l_object_key_type VARCHAR2(8);
l_grant_guid RAW(16);
l_success VARCHAR2(1);
l_error_code NUMBER;

begin
  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  x_msg_count:=0;
  x_msg_data:=null;

  select object_id
  into l_object_id
  from fnd_objects
  where obj_name=p_object_name;
  if p_project_role_id is not null then
    l_menu_id:=get_menu_id_for_role(p_project_role_id);
  else
    l_menu_id:=get_menu_id(p_menu_name);
  end if;

   if p_object_key_type='INSTANCE' then
      l_object_key_type:='INSTANCE';
   else
      l_object_key_type:='SET';
   end if;

  --Standard Start of API savepoint
  SAVEPOINT     revoke_role_PUB;

  SELECT grant_guid
  INTO l_grant_guid
  FROM fnd_grants
  WHERE grantee_type='USER' AND
        grantee_key=get_grantee_key(p_source_type, p_party_id) AND
        menu_id=l_menu_id AND
        object_id=l_object_id AND
        instance_type=l_object_key_type AND
        ((l_object_key_type='INSTANCE' AND
          instance_pk1_value=TO_CHAR(p_object_key)) OR
         (l_object_key_type='SET' AND
          instance_set_id=p_object_key));

  fnd_grants_pkg.revoke_grant(
    p_api_version => l_api_version,
    p_grant_guid  => l_grant_guid,
    x_success     => l_success,
    x_errorcode   => l_error_code);

  IF l_success=fnd_api.g_true THEN
    x_return_status:=fnd_api.g_ret_sts_success;
  ELSE
    IF l_error_code>0 THEN
       x_return_status:=fnd_api.g_ret_sts_error;
    ELSE
       x_return_status:=fnd_api.g_ret_sts_unexp_error;
    END IF;
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
    RETURN;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
  END IF;

EXCEPTION
       WHEN OTHERS THEN
          ROLLBACK TO revoke_role_PUB;
          x_return_status := FND_API.g_ret_sts_unexp_error ;
              IF      FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (       G_PKG_NAME ,
                              'revoke_role'
                      );
              END IF;
       FND_MSG_PUB.Count_And_Get
                  (p_count             =>      x_msg_count ,
                   p_data              =>      x_msg_data
                   );
 end;

 -- obsoleted API
 PROCEDURE update_role
  (  p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode     in varchar2  default 'N',
     p_grant_guid       in raw,
     p_project_role_id_old       IN  number default null,
     p_object_name_old          IN  VARCHAR2 default null,
     p_object_key_type_old  IN  VARCHAR2 default null,
     p_object_key_old     IN  NUMBER default null,
     p_party_id_old       IN  NUMBER default null,
     p_source_type_old        in varchar2 default null,
     p_start_date_old   IN  DATE default null,
     p_start_date_new  IN  DATE default null,
     p_end_date_new       IN  DATE,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is
   l_success varchar2(1);

begin
  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  x_return_status:=fnd_api.g_ret_sts_success;
  x_msg_count:=0;
  x_msg_data:=null;
  fnd_grants_pkg.update_grant
  (
   p_api_version    =>l_api_version,
   p_grant_guid       =>p_grant_guid,
   p_start_date     =>p_start_date_new,
   p_end_date       =>p_end_date_new,
   x_success        =>l_success
  ) ;
  if l_success=fnd_api.g_true then
    x_return_status:=fnd_api.g_ret_sts_success;
  else
       x_return_status:=fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
  end if;
exception
  when others then
    raise;

end;


 PROCEDURE lock_grant
  (
    p_commit         IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_debug_mode     in varchar2  default 'N',
    p_grant_guid        in raw,
    p_project_role_id_old       IN  number default null,
    p_object_name_old          IN  VARCHAR2 default null,
    p_object_key_type_old  IN  VARCHAR2 default null,
    p_object_key_old     IN  number default null,
    p_party_id_old       IN  NUMBER default null,
    p_source_type_old    in varchar2 default null,
    p_start_date_old   IN  DATE default null,
   p_project_role_id      IN  number,
   p_party_id       IN  NUMBER,
   p_source_type    in varchar2,
   p_object_name          IN  VARCHAR2,
   p_object_key_type  IN  VARCHAR2,
   p_object_key     IN  number,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is
 v_menu_id number;
 l_instance_set_id number;
 l_instance_pk1_value number;
 l_object_key_type varchar2(8);
 l_object_id number;

begin
  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  x_msg_count:=0;
  x_msg_data:=null;

  v_menu_id:=get_menu_id_for_role(p_project_role_id);
  if p_object_key_type='INSTANCE' then
     l_instance_pk1_value:=p_object_key;
     l_instance_set_id:=null;
     l_object_key_type:='INSTANCE';
  else
     l_instance_set_id:=p_object_key;
     l_instance_pk1_value:=null;
     l_object_key_type:='SET';
  end if;

  select object_id
  into l_object_id
  from fnd_objects
  where obj_name=p_object_name;

  fnd_grants_pkg.lock_grant
  (
   p_grant_guid   =>p_grant_guid,
   p_menu_id      =>v_menu_id,
--   p_grantee_key  =>'PER:'||to_char(p_party_id),
   p_grantee_key  =>get_grantee_key(p_source_type, p_party_id),
   p_grantee_type =>'USER',
   p_object_id  =>l_object_id,
   p_instance_type =>l_object_key_type,
   p_instance_set_id =>l_instance_set_id,
   p_instance_pk1_value =>l_instance_pk1_value,
   p_instance_pk2_value =>null,
   p_instance_pk3_value =>null,
   p_instance_pk4_value =>null,
   p_instance_pk5_value =>null,
   p_start_date   => p_start_date,
   p_end_date     => p_end_date,
   p_program_name =>null,
   p_program_tag =>null
  ) ;
  x_return_status:='S';
exception
   when others then
   x_return_status:=fnd_api.g_ret_sts_unexp_error;
    raise;
end;


FUNCTION get_instance_set_id (p_set_name in varchar2) return number IS
 l_api_name varchar2(30):='get_instance_set_id';
 l_set_id number;
 begin
  select instance_set_id into l_set_id
  from fnd_object_instance_sets
  where instance_set_name=p_set_name;
  return l_set_id;
exception
   when no_data_found then
       fnd_message.set_name('PA','PA_COMMON_NO_INS_SET');
       fnd_msg_pub.ADD;
       return null;
   when others then
       IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME ,
                  l_api_name
            );
       END IF;
      return null;
end;


FUNCTION get_menu_name (p_project_role_id in number) return varchar2 is
v_menu_name varchar2(30);
l_api_name varchar2(30):='get_menu_name';
begin
 select menu.menu_name
  into  v_menu_name
  from  fnd_menus menu,
        --pa_project_role_types role
          pa_project_role_types_b role  --Bug 4867700
  where menu.menu_id=role.menu_id
   and  role.project_role_id= p_project_role_id;
   return v_menu_name;
exception
  when no_data_found then
     --fnd_message.set_name('PA','PA_COMMON_NO_ROLE_MENU');
     --fnd_msg_pub.ADD;
     return null;
   when others then
       IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME ,
                  l_api_name
            );
       END IF;
       return null;
end;

FUNCTION get_menu_name_from_id (p_menu_id in number) return varchar2 is
v_menu_name varchar2(30);
begin
 select menu.menu_name
  into  v_menu_name
  from  fnd_menus menu
  where menu.menu_id=p_menu_id;
  return v_menu_name;
exception
   when others then
       return null;
end;

-----The following function is obsoleted because of translation issue for pre-seeded
-----roles
/*FUNCTION get_menu_name (p_project_role_name in varchar2) return varchar2 is
v_menu_name varchar2(30);
l_api_name varchar2(30):='get_menu_name';
begin
 select menu.menu_name
  into  v_menu_name
  from  fnd_menus menu,
        pa_project_role_types role
  where menu.menu_id=role.menu_id
   and  role.meaning= p_project_role_name;
   return v_menu_name;
exception
  when no_data_found then
     --fnd_message.set_name('PA','PA_COMMON_NO_ROLE_MENU');
     --fnd_msg_pub.ADD;
     return null;
   when others then
       IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME ,
                  l_api_name
            );
       END IF;
      return null;
end;*/


FUNCTION get_menu_id (p_menu_name in varchar2) return number is
v_menu_id number;
l_api_name varchar2(30):='get_menu_id';
begin
 select menu_id into v_menu_id
 from fnd_menus
 where  menu_name =p_menu_name;
 return v_menu_id;
exception
  when no_data_found then
    -- fnd_message.set_name('PA','PA_COMMON_NO_ROLE_MENU');
    -- fnd_msg_pub.ADD;
     return null;
   when others then
       IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME ,
                  l_api_name
            );
       END IF;
      return null;
end;

FUNCTION get_menu_id_for_role (p_project_role_id in number) return number is
v_menu_id number;
l_api_name varchar2(30):='get_menu_id_for_role';
begin
 select menu_id into v_menu_id
 --from pa_project_role_types --bug 4004821
 from pa_project_role_types_b
 where  project_role_id =p_project_role_id;
 return v_menu_id;
exception
  when no_data_found then
    -- fnd_message.set_name('PA','PA_COMMON_NO_ROLE_MENU');
    -- fnd_msg_pub.ADD;
     return null;
   when others then
       IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           FND_MSG_PUB.Add_Exc_Msg
           (       G_PKG_NAME ,
                  l_api_name
            );
       END IF;
      return null;
end;

FUNCTION get_proj_role_name(p_project_role_id in number) return varchar2 is
v_role_name varchar2(80);
begin
 select meaning
 into v_role_name
 from pa_project_role_types
 where project_role_id =p_project_role_id;
 return v_role_name;
exception
   when others then
     raise;
end;

FUNCTION get_party_id RETURN NUMBER IS
BEGIN
  RETURN G_source_id;
END;



-----FUNCTION is_role_exists-------------
----This FUnction is created by Hari. It is used in resource model
--------------------------------------------------------------------------
FUNCTION is_role_exists ( p_object_name     IN FND_OBJECTS.OBJ_NAME%TYPE
                         ,p_object_key_type IN FND_GRANTS.INSTANCE_TYPE%TYPE DEFAULT 'INSTANCE'
                         ,p_role_id         IN FND_MENUS.MENU_ID%TYPE
                         ,p_object_key      IN FND_GRANTS.INSTANCE_PK1_VALUE%TYPE
                         ,p_party_id        IN NUMBER
                        ) RETURN BOOLEAN IS

--l_yes         CONSTANT BOOLEAN := TRUE;
--l_exists_flag BOOLEAN DEFAULT FALSE;
l_dummy VARCHAR2(1);
l_object_key_type varchar2(8);
  l_grantee_key fnd_grants.grantee_key%TYPE := '';

BEGIN
if p_object_key_type='INSTANCE' then
   l_object_key_type:='INSTANCE';
else
   l_object_key_type:='SET';
end if;
----------------------------------------------------------------------
--object_name    object_key_type    role_id     object_key      party_id
--                                 (menu_id)    (org_id)
--                                              (set_id)
------------------------------------------------------------------------
--ORGANIZATION   INSTANCE             1          1274             53
--PEOPLE         SET                  1          999              53
------------------------------------------------------------------------

--
-- The person_id can be NULL, when the caller tries to check
-- whether there is anybody else holding a particular authority in
-- that organizaton.
--
--
-- There'll be a INSTANCE record - corresponding to each (person_id, role_id) combination
-- To check whether there are *any* INSTANCE records for a particular (person_id, role_id) combination,
-- the caller would send the object_key ( org_id ) as NULL.
--


     BEGIN

       IF p_party_id IS NOT NULL THEN
         l_grantee_key := get_grantee_key('PERSON', p_party_id);
       END IF;

       SELECT DISTINCT 'Y'
         INTO l_dummy
         FROM fnd_grants fg ,
              fnd_objects fo
        WHERE fg.object_id=fo.object_id
          AND fo.obj_name = p_object_name
          AND fg.INSTANCE_type = l_object_key_type
          AND fg.menu_id = p_role_id
          AND fg.grantee_type='USER'
	  AND (p_party_id IS NULL OR fg.grantee_key=l_grantee_key)
          AND trunc(SYSDATE) BETWEEN trunc(fg.start_date)
              and trunc(NVL(fg.END_DATE, SYSDATE+1))
	  AND ((l_object_key_type='INSTANCE' AND
                instance_pk1_value=NVL(p_object_key, instance_pk1_value)) OR
               (l_object_key_type='SET' AND
                fg.instance_set_id=TO_NUMBER(p_object_key)));

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_dummy := 'N';
     END;
  IF l_dummy='Y' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END is_role_exists;



--------FUNCTION check_user_privilege
---This function will be used in select statement in some of the PRM pages
FUNCTION check_user_privilege
         (p_privilege in varchar2,
          p_object_name in varchar2,
          p_object_key in number,
          p_init_msg_list  IN  VARCHAR2 DEFAULT 'Y') return varchar2 is
x_ret_code varchar2(1);
x_return_status varchar2(1);
x_msg_count number;
x_msg_data varchar2(240);

begin
   check_user_privilege(p_privilege,
                        p_object_name,
                        p_object_key,
                        x_ret_code,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        p_init_msg_list);
   return x_ret_code;
exception
   when others then
     raise;
end;

---------PROCEDURE get_pk_information
--Getting the database information about an object
Procedure get_pk_information(p_object_name in VARCHAR2,
                             x_pk1_column_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_pk2_column_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_pk3_column_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_pk4_column_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_pk5_column_name out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_aliased_pk_column out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_aliased_ik_column out NOCOPY varchar2, --File.Sql.39 bug 4440895
                             x_database_object_name out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
cursor c_pk is
    SELECT pk1_column_name
           ,pk2_column_name
           ,pk3_column_name
           ,pk4_column_name
           ,pk5_column_name
           , database_object_name
    FROM fnd_objects
    WHERE obj_name=p_object_name  ;
begin
   open c_pk;
   fetch c_pk into
   x_pk1_column_name  ,
   x_pk2_column_name  ,
   x_pk3_column_name ,
   x_pk4_column_name  ,
   x_pk5_column_name ,
   x_database_object_name;
   close c_pk; /* Bug #2994870: closing the cursor. */

   x_aliased_pk_column:=x_pk1_column_name;
   x_aliased_ik_column:='INSTANCE_PK1_VALUE';
   if x_pk2_COLUMN_name is not null then
            x_aliased_pk_column:=x_aliased_pk_column||','||x_pk2_COLUMN_name;
            x_aliased_ik_column:=x_aliased_ik_column||','||'INSTANCE_PK2_VALUE';
            if x_pk3_COLUMN_name is not null then
                 x_aliased_pk_column :=x_aliased_pk_column||','||x_pk3_COLUMN_name;
                 x_aliased_ik_column:=x_aliased_ik_column||','||'INSTANCE_PK3_VALUE';
                 if x_pk4_COLUMN_name is not null then
                     x_aliased_pk_column:=x_aliased_pk_column||','||x_pk4_COLUMN_name;
                     x_aliased_ik_column:=x_aliased_ik_column||','||'INSTANCE_PK4_VALUE';
                     if x_pk5_COLUMN_name is not null then
                         x_aliased_pk_column:=x_aliased_pk_column||','||x_pk5_COLUMN_name;
                         x_aliased_ik_column:=x_aliased_ik_column||','||'INSTANCE_PK5_VALUE';
                     end if;
                 end if;
            end if;
     end if;
exception
  when others then
      raise;
end;

---------PROCEDURE check_access_exist
--Check where the user has access to any object with the given privilege
PROCEDURE check_access_exist(p_privilege IN VARCHAR2,
                             p_object_name IN VARCHAR2,
                             x_ret_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_db_object_name        fnd_objects.database_object_name%TYPE;
  l_db_pk1_column         fnd_objects.pk1_column_name%TYPE;
  l_db_pk2_column         fnd_objects.pk2_column_name%TYPE;
  l_db_pk3_column         fnd_objects.pk3_column_name%TYPE;
  l_db_pk4_column         fnd_objects.pk4_column_name%TYPE;
  l_db_pk5_column         fnd_objects.pk5_column_name%TYPE;
  l_aliased_pk_column     VARCHAR2(180);
  l_aliased_ik_column     VARCHAR2(180);

  TYPE DYNAMIC_CUR IS REF CURSOR;
  l_cur DYNAMIC_CUR;
  l_dummy NUMBER;
  l_sql VARCHAR2(32767);
  l_predicate VARCHAR2(32767);
BEGIN
  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  pa_debug.Init_err_stack ( 'Check_Access_Exist');

  Init_global;
  x_ret_code := FND_API.G_TRUE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

------- Check for License
  IF pa_product_install_utils.check_function_licensed(p_privilege) <> 'Y'  THEN
    x_ret_code:= fnd_api.g_false;
    x_return_status:=fnd_api.g_ret_sts_success;
    RETURN;
  END IF;
------- End check for License

  pa_debug.G_err_stage := 'get objects primary keys information';
  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  get_pk_information(p_object_name  ,
                     l_db_pk1_column  ,
                     l_db_pk2_column  ,
                     l_db_pk3_column  ,
                     l_db_pk4_column  ,
                     l_db_pk5_column  ,
                     l_aliased_pk_column  ,
                     l_aliased_ik_column  ,
                     l_db_object_name);

  pa_debug.G_err_stage := 'check access from responsibility level';
  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  IF fnd_function.test(p_privilege) THEN
  --Adding the below code for the bug 3137696
  x_ret_code := FND_API.G_TRUE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  RETURN;
  --Commented the below code for the bug 3137696
    /*IF p_object_name='PA_PROJECTS' THEN
-- Bug 1571014, faulty dynamic sql
      l_sql := 'SELECT 1 FROM '||l_db_object_name||
               ' WHERE pa_security_pvt.check_sec_by_resp('||
                 g_user_id||',''PA_PROJECTS'','''||
                 g_source_type||''','||l_db_pk1_column||')=''T'''||
               ' AND pa_security.allow_update('||l_db_pk1_column||')=''Y'''||
               ' AND ROWNUM=1';

      pa_debug.G_err_stage := 'checking allow_update in case of PA_PROJECTS';
      IF G_debug_flag = 'Y' THEN
         pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
      END IF;

      PA_SECURITY.Initialize(X_user_id =>G_user_id  ,
                             X_calling_module  => 'PAXPREPR');

      OPEN l_cur FOR l_sql;
      FETCH l_cur INTO l_dummy;
      IF l_cur%FOUND THEN
        CLOSE l_cur; -- Bug #2994870: closing the cursor.
        RETURN;
      END IF;
      CLOSE l_cur; -- Bug #2994870: closing the cursor.

    ELSE
-- Bug 1571014, faulty dynamic sql
      l_sql := 'SELECT 1 FROM '||l_db_object_name||
               ' WHERE pa_security_pvt.check_sec_by_resp('||
                 g_user_id||','''||p_object_name||''','''||
                 g_source_type||''','||l_db_pk1_column||')=''T'''||
               ' AND ROWNUM=1';

      pa_debug.G_err_stage := 'checking check_sec_by_resp';
      IF G_debug_flag = 'Y' THEN
         pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
      END IF;

      PA_SECURITY.Initialize(X_user_id =>G_user_id  ,
                             X_calling_module  => 'PAXPREPR');

      OPEN l_cur FOR l_sql;
      FETCH l_cur INTO l_dummy;
      IF l_cur%FOUND THEN
        CLOSE l_cur; -- Bug #2994870: closing the cursor.
        RETURN;
      END IF;
      CLOSE l_cur; -- Bug #2994870: closing the cursor.
    END IF;*/
  END IF;


  pa_debug.G_err_stage := 'get predicate from fnd_data_security';
  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  fnd_data_security.get_security_predicate(
	p_api_version => l_api_version,
	p_function => p_privilege,
	p_object_name => p_object_name,
--	p_user_name => 'PER:'||to_char(G_user_emp_id),
--	p_user_name => get_grantee_key, Commented for Bug 4498436.
        p_statement_type => 'EXISTS',
	x_predicate => l_predicate,
	x_return_status => x_return_status);

--  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
  IF x_return_status<>'T' AND x_return_status<>'F' THEN
    x_ret_code := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
           (p_count             =>      x_msg_count ,
            p_data              =>      x_msg_data);
    RETURN;
  ELSIF x_return_status='F' THEN
    x_ret_code := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := '';
    RETURN;
  END IF;

--  l_predicate := LTRIM(l_predicate, l_aliased_pk_column || ' IN ');
--  l_predicate := 'SELECT 1 FROM DUAL WHERE EXISTS '||l_predicate;
--Bug 2603255, selecting from db_object table instead of dual
--  l_predicate := 'SELECT 1 FROM DUAL WHERE '||l_predicate;
  l_predicate := 'SELECT 1 FROM '||l_db_object_name||' WHERE '||l_predicate;

  pa_debug.G_err_stage := 'open cursor for dynamic sql';
  IF G_debug_flag = 'Y' THEN
     pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
  END IF;
  OPEN l_cur FOR l_predicate;
  FETCH l_cur INTO l_dummy;
  IF l_cur%NOTFOUND THEN
    x_ret_code := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := '';
    CLOSE l_cur; -- Bug #2994870: closing the cursor.
    RETURN;
  END IF;
  CLOSE l_cur; -- Bug #2994870: closing the cursor.

EXCEPTION
  WHEN OTHERS THEN
    pa_debug.G_err_stage := 'exceptions raised';
    IF G_debug_flag = 'Y' THEN
       pa_debug.write_file('check_access_exist: ' ||  'LOG', pa_debug.G_err_stage);
    END IF;
    x_ret_code := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
           (p_count             =>      x_msg_count ,
            p_data              =>      x_msg_data);

END check_access_exist;

PROCEDURE check_grant_exists(p_project_role_id in NUMBER,
                             p_instance_type in fnd_grants.INSTANCE_TYPE%TYPE,
                             p_instance_set_name in fnd_object_instance_sets.instance_set_name%TYPE,
                             p_grantee_type in fnd_grants.GRANTEE_TYPE%TYPE,
                             p_grantee_key in fnd_grants.GRANTEE_KEY%TYPE,
                             x_instance_set_id out NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_ret_code out NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            ) IS

 l_instance_set_id NUMBER := null;
 l_grant_exists VARCHAR2(1) := 'F';

BEGIN



 IF p_instance_set_name = G_project_roles_ins_set_name THEN
   IF G_project_roles_ins_set_id IS NULL THEN
     G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
   END IF;
   l_instance_set_id := G_project_roles_ins_set_id;
   x_instance_set_id := G_project_roles_ins_set_id;
 END IF;

 select 'T' into l_grant_exists
   from fnd_grants
  where grantee_key = p_grantee_key
    and grantee_type = 'USER'
    and instance_set_id = l_instance_set_id
    and grantee_type = p_grantee_type
    and instance_type = p_instance_type
    and parameter1 = to_char(p_project_role_id)
    and rownum=1;

 x_ret_code := l_grant_exists;

EXCEPTION
  WHEN OTHERS THEN
    x_instance_set_id := l_instance_set_id;
    x_ret_code := l_grant_exists;

END check_grant_exists;

----------------------------------------------------------------------
-- The APIs below will be used by Roles form:
-- 1. update_menu
-- 2. revoke_role_based_sec
-- 3. grant_role_based_sec
-- 4. revoke_status_based_sec
-- 5. update_status_based_sec
----------------------------------------------------------------------

 -- This API is called when the default Menu is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE update_menu
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     p_menu_id          IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

BEGIN

 IF G_project_roles_ins_set_id IS NULL THEN
   G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
 END IF;

 -- update menu_id in FND_GRANTS
 UPDATE fnd_grants
    SET menu_id = p_menu_id
  WHERE parameter1 = to_char(p_project_role_id)
    AND (parameter2 = 'NON_STATUS_BASED' OR parameter2 = 'DEFAULT')
    AND instance_type = 'SET'
    AND instance_set_id = G_project_roles_ins_set_id;

 x_return_status:=fnd_api.g_ret_sts_success;

EXCEPTION
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_SECURITY_PVT',
        p_procedure_name => 'UPDATE_MENU',
        p_error_text     => SQLCODE);
     x_msg_count := 1;

END update_menu;


 -- This API is called when Enforce Role-based Security checkbox
 -- is unchecked in Roles form for existing roles which are in use.
 PROCEDURE revoke_role_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

BEGIN

 IF G_project_roles_ins_set_id IS NULL THEN
   G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
 END IF;

 -- delete from FND_GRANTS
 DELETE FROM fnd_grants
  WHERE parameter1 = to_char(p_project_role_id)
    AND instance_type = 'SET'
    AND instance_set_id = G_project_roles_ins_set_id;

 x_return_status:=fnd_api.g_ret_sts_success;

EXCEPTION
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_SECURITY_PVT',
        p_procedure_name => 'REVOKE_ROLE_BASED_SEC',
        p_error_text     => SQLCODE);
     x_msg_count := 1;
END revoke_role_based_sec;


 -- This API is called when Enforce Role-based Security checkbox
 -- is checked in Roles form for existing roles which are in use.
 PROCEDURE grant_role_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

l_success varchar2(1);
l_error_code number;
l_instance_set_id number;
l_grantee_key fnd_grants.grantee_key%TYPE;
l_grant_exists VARCHAR2(1);
l_status_level VARCHAR2(30);
l_default_menu_name fnd_menus.menu_name%TYPE := null;
l_status_type_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_status_code_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_menu_name_tbl SYSTEM.pa_varchar2_30_tbl_type := null;
l_exp_error varchar2(1) := 'F';
l_unexp_error  varchar2(1) := 'F';
l_parameter2 fnd_grants.parameter2%TYPE;
l_return_status varchar2(1) := fnd_api.g_ret_sts_success;
l_error_message_code VARCHAR2(30);
l_grant_guid fnd_grants.grant_guid%TYPE;
l_role_status_menu_id_tbl SYSTEM.pa_num_tbl_type := null;

cursor get_resources_on_role is
select distinct ppp.resource_type_id,ppp.resource_source_id
-- , wfr.name grantee_key
  from pa_project_parties ppp
--        wf_roles wfr
    where ppp.project_role_id = p_project_role_id;
--    and ppp.resource_type_id = 112
--    and ppp.resource_source_id = wfr.orig_system_id
--    and wfr.orig_system = 'HZ_PARTY'
/*
UNION ALL
select distinct ppp.resource_type_id,ppp.resource_source_id, wfr.name grantee_key
  from pa_project_parties ppp,
       per_all_people_f per,
       wf_roles wfr
 where ppp.project_role_id = p_project_role_id
   and ppp.resource_type_id = 101
   and ppp.resource_source_id = per.person_id
   and per.party_id = wfr.orig_system_id
   and wfr.orig_system = 'HZ_PARTY';

*/
BEGIN

  IF G_project_roles_ins_set_id IS NULL THEN
    G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
  END IF;

  -- get all menus-statuses associated with this role
  pa_role_status_menu_utils.Get_Role_Status_Menus(
               p_role_id            => p_project_role_id
              ,x_status_level       => l_status_level
              ,x_default_menu_name  => l_default_menu_name
              ,x_status_type_tbl    => l_status_type_tbl
              ,x_status_code_tbl    => l_status_code_tbl
              ,x_menu_name_tbl      => l_menu_name_tbl
              ,x_role_status_menu_id_tbl => l_role_status_menu_id_tbl
              ,x_return_status      => l_return_status
              ,x_error_message_code => l_error_message_code);

  --dbms_output.put_line('Get_Role_Status_Menus:'||l_return_status);

  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                          ,p_msg_name => l_error_message_code );
  ELSE

    IF l_status_code_tbl IS NULL OR l_status_code_tbl.COUNT = 0 THEN
     l_parameter2 := 'NON_STATUS_BASED';
    ELSE
     l_parameter2 := 'DEFAULT';
    END IF;

    -- insert records back to fnd_Grants
    FOR res in get_resources_on_role LOOP

      IF res.resource_type_id = 112 THEN
          SELECT wfr.name grantee_key
          INTO l_grantee_key
          FROM wf_roles wfr
          WHERE wfr.orig_system_id = res.resource_source_id
          AND  wfr.orig_system = 'HZ_PARTY'
          AND rownum = 1;
      ELSIF res.resource_type_id  = 101 THEN
          SELECT wfr.name grantee_key
          INTO l_grantee_key
          FROM per_all_people_f per,
               wf_roles wfr
          WHERE res.resource_source_id = per.person_id
          AND   per.party_id = wfr.orig_system_id
          AND   wfr.orig_system = 'HZ_PARTY'
          AND   rownum = 1;
      END IF;

      -- l_grantee_key := res.grantee_key;

      --dbms_output.put_line('------------------------------');
      --dbms_output.put_line('grantee_key: ' || l_grantee_key);

      -- insert new records into FND_GRANTS
      fnd_grants_pkg.grant_function
      (
        p_api_version           =>  l_api_version, -- Modified the parameter from '1.0' to l_api_version: Bug #3983570
        p_menu_name             =>  l_default_menu_name,
        p_object_name           =>  'PA_PROJECTS',
        p_instance_type         =>  'SET',
        p_instance_set_id       =>  G_project_roles_ins_set_id,
        p_instance_pk1_value    =>  null,
        p_instance_pk2_value    =>  null,
        p_instance_pk3_value    =>  null,
        p_instance_pk4_value    =>  null,
        p_instance_pk5_value    =>  null,
        p_grantee_type          => 'USER',
        p_grantee_key           =>  l_grantee_key,
        p_parameter1            =>  p_project_role_id,
        p_parameter2            =>  l_parameter2,
        p_parameter3            =>  null,
        p_start_date            =>  sysdate,
        p_end_date              =>  null,
        x_grant_guid            =>  l_grant_guid,
        x_success               =>  l_success,
        x_errorcode             =>  l_error_code
       );

      if l_success <> fnd_api.g_true then
        if l_error_code >0 then
          l_exp_error := 'T';
        else
          l_unexp_error := 'T';
        end if;
      end if;

      IF l_status_code_tbl IS NOT NULL AND l_status_code_tbl.COUNT > 0 THEN

        FOR i IN l_status_code_tbl.FIRST..l_status_code_tbl.LAST LOOP

          fnd_grants_pkg.grant_function
          (
          p_api_version           =>  l_api_version, -- Modified the parameter from '1.0' to l_api_version: Bug #3983570
          p_menu_name             =>  l_menu_name_tbl(i),
          p_object_name           =>  'PA_PROJECTS',
          p_instance_type         =>  'SET',
          p_instance_set_id       =>  G_project_roles_ins_set_id,
          p_instance_pk1_value    =>  null,
          p_instance_pk2_value    =>  null,
          p_instance_pk3_value    =>  null,
          p_instance_pk4_value    =>  null,
          p_instance_pk5_value    =>  null,
          p_grantee_type          => 'USER',
          p_grantee_key           =>  l_grantee_key,
          p_parameter1            =>  p_project_role_id,
          p_parameter2            =>  l_status_level,
          p_parameter3            =>  l_status_code_tbl(i),
          p_parameter4            =>  l_role_status_menu_id_tbl(i),
          p_start_date            =>  sysdate,
          p_end_date              =>  null,
          x_grant_guid            =>  l_grant_guid,
          x_success               =>  l_success,
          x_errorcode             =>  l_error_code
          ) ;

          if l_success <> fnd_api.g_true then
            if l_error_code >0 then
              l_exp_error := 'T';
            else
              l_unexp_error := 'T';
            end if;
          end if;

        END LOOP; -- l_status_code_tbl.FIRST..l_status_code_tbl.LAST

      END IF; -- IF l_status_code_tbl.COUNT > 0 THEN

    END LOOP; -- FOR res in get_resources_on_role LOOP

    if l_exp_error = 'T' then
       l_return_status:=fnd_api.g_ret_sts_error;
    elsif l_unexp_error = 'T' then
       l_return_status:=fnd_api.g_ret_sts_unexp_error;
    else
      l_return_status:=fnd_api.g_ret_sts_success;

    END IF;

  END IF; -- l_return_status = 'S'

  x_return_status:=l_return_status;

  IF l_return_status <> fnd_api.g_ret_sts_success THEN
    FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
  END IF;

EXCEPTION
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_SECURITY_PVT',
        p_procedure_name => 'GRANT_ROLE_BASED_SEC',
        p_error_text     => SQLCODE);
     FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
END grant_role_based_sec;


 -- This API is called when Status Level is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE revoke_status_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

BEGIN

 IF G_project_roles_ins_set_id IS NULL THEN
   G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
 END IF;

 -- delete all but default from fnd_Grants
 DELETE FROM fnd_grants
  WHERE parameter1 = to_char(p_project_role_id)
    AND (parameter2 = 'USER' OR parameter2 = 'SYSTEM')
    AND instance_type = 'SET'
    AND instance_set_id = G_project_roles_ins_set_id;

 x_return_status:=fnd_api.g_ret_sts_success;

EXCEPTION
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_SECURITY_PVT',
        p_procedure_name => 'REVOKE_STATUS_BASED_SEC',
        p_error_text     => SQLCODE);
     x_msg_count := 1;
END revoke_status_based_sec;

 -- This API is called when status/menu under Project Status is changed
 -- in Roles form for existing roles which are in use.
 PROCEDURE update_status_based_sec
  (  p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_debug_mode       in varchar2  default 'N',
     p_project_role_id  IN  number,
     p_status_level     IN pa_project_role_types_b.status_level%TYPE,
     p_new_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_menu_name_tbl    IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_new_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     p_mod_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_mod_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_mod_menu_id_tbl    IN SYSTEM.pa_num_tbl_type := null,
     p_mod_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     p_del_status_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_del_status_type_tbl  IN SYSTEM.pa_varchar2_30_tbl_type := null,
     p_del_role_sts_menu_id_tbl IN SYSTEM.pa_num_tbl_type := null,
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) is

cursor get_resources_on_role is
select distinct ppp.resource_type_id,ppp.resource_source_id, wfr.name grantee_key
  from pa_project_parties ppp,
       wf_roles wfr
 where ppp.project_role_id = p_project_role_id
   and ppp.resource_type_id = 112
   and ppp.resource_source_id = wfr.orig_system_id
   and wfr.orig_system = 'HZ_PARTY'
UNION ALL
select distinct ppp.resource_type_id,ppp.resource_source_id, wfr.name grantee_key
  from pa_project_parties ppp,
       per_all_people_f per,
       wf_roles wfr
 where ppp.project_role_id = p_project_role_id
   and ppp.resource_type_id = 101
   and ppp.resource_source_id = per.person_id
   and per.party_id = wfr.orig_system_id
   and wfr.orig_system = 'HZ_PARTY';


l_grantee_key fnd_grants.grantee_key%TYPE;
l_status_menu_count NUMBER := 0;
l_parameter2 fnd_grants.parameter2%TYPE;
l_opp_param2 fnd_grants.parameter2%TYPE;
l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_grant_guid fnd_grants.grant_guid%TYPE;
l_success varchar2(1);
l_exp_error varchar2(1);
l_unexp_error varchar2(1);
l_error_code number;

BEGIN

  IF G_project_roles_ins_set_id IS NULL THEN
    G_project_roles_ins_set_id := get_instance_set_id(G_project_roles_ins_set_name);
  END IF;

  -- 1. NEW: insert new records into FND_GRANTS
  IF p_new_status_code_tbl IS NOT NULL AND p_new_status_code_tbl.COUNT > 0 THEN

   --dbms_output.put_line('insert new record');

   FOR res in get_resources_on_role LOOP

    l_grantee_key := res.grantee_key;

    FOR i IN p_new_status_code_tbl.FIRST..p_new_status_code_tbl.LAST LOOP

      fnd_grants_pkg.grant_function
        (
        p_api_version           =>  l_api_version, -- Modified the parameter from '1.0' to l_api_version: Bug #3983570
        p_menu_name             =>  p_new_menu_name_tbl(i),
        p_object_name           =>  'PA_PROJECTS',
        p_instance_type         =>  'SET',
        p_instance_set_id       =>  G_project_roles_ins_set_id,
        p_instance_pk1_value    =>  null,
        p_instance_pk2_value    =>  null,
        p_instance_pk3_value    =>  null,
        p_instance_pk4_value    =>  null,
        p_instance_pk5_value    =>  null,
        p_grantee_type          => 'USER',
        p_grantee_key           =>  l_grantee_key,
        p_parameter1            =>  p_project_role_id,
        p_parameter2            =>  p_status_level,
        p_parameter3            =>  p_new_status_code_tbl(i),
        p_parameter4            =>  p_new_role_sts_menu_id_tbl(i),
        p_start_date            =>  sysdate,
        p_end_date              =>  null,
        x_grant_guid            =>  l_grant_guid,
        x_success               =>  l_success,
        x_errorcode             =>  l_error_code
        ) ;

        if l_success <> fnd_api.g_true then
          if l_error_code >0 then
            l_exp_error := 'T';
          else
            l_unexp_error := 'T';
          end if;
        end if;

     END LOOP; -- p_new_status_code_tbl
   END LOOP; -- get_resources_on_role

   if l_exp_error = 'T' then
     l_return_status:=fnd_api.g_ret_sts_error;
   elsif l_unexp_error = 'T' then
     l_return_status:=fnd_api.g_ret_sts_unexp_error;
   else
     l_return_status:=fnd_api.g_ret_sts_success;
   end if;

  END IF; -- p_new_status_code_tbl.COUNT > 0 THEN

  IF l_return_status = fnd_api.g_ret_sts_success THEN

    -- 2. delete obsolete records from FND_GRANTS
    IF p_del_status_code_tbl IS NOT NULL AND p_del_status_code_tbl.COUNT > 0 THEN

      --dbms_output.put_line('delete records');

      FORALL j in p_del_status_code_tbl.FIRST..p_del_status_code_tbl.LAST
      DELETE FROM fnd_grants
       WHERE parameter1 = to_char(p_project_role_id)
         AND (parameter2 = 'USER' OR parameter2 = 'SYSTEM')
         AND parameter3 = p_del_status_code_tbl(j)
         AND parameter4 = p_del_role_sts_menu_id_tbl(j)
         AND instance_type = 'SET'
         AND instance_set_id = G_project_roles_ins_set_id;

    END IF;

    -- 3. update existing records in FND_GRANTS
    IF p_mod_status_code_tbl IS NOT NULL AND p_mod_status_code_tbl.COUNT > 0 THEN

      --dbms_output.put_line('update records');

      FORALL k in p_mod_status_code_tbl.FIRST..p_mod_status_code_tbl.LAST
      UPDATE fnd_grants
         SET parameter2 = p_status_level,
             parameter3 = p_mod_status_code_tbl(k),
             menu_id = p_mod_menu_id_tbl(k)
       WHERE parameter1 = to_char(p_project_role_id)
         AND (parameter2 = 'USER' OR parameter2 = 'SYSTEM')
         AND parameter4 = p_mod_role_sts_menu_id_tbl(k)
         AND instance_type = 'SET'
         AND instance_set_id = G_project_roles_ins_set_id;
    END IF;

    -- 4. if there is no status-menu record for the role,
    --    set the fnd_grants records from DEFAULT to NON_STATUS_BASED
    select count(role_status_menu_id) into l_status_menu_count
      from pa_role_status_menu_map
     where role_id = p_project_role_id
       and rownum=1;

    IF l_status_menu_count = 0 THEN
      l_parameter2 := 'NON_STATUS_BASED';
      l_opp_param2 := 'DEFAULT';
    ELSE
      l_parameter2 := 'DEFAULT';
      l_opp_param2 := 'NON_STATUS_BASED';
    END IF;

    UPDATE fnd_grants
       SET parameter2 = l_parameter2
     WHERE parameter1 = to_char(p_project_role_id)
       AND parameter2 = l_opp_param2
       AND instance_type = 'SET'
       AND instance_set_id = G_project_roles_ins_set_id;

  END IF; -- l_return_status = fnd_api.g_ret_sts_success THEN

  x_return_status := l_return_status;

EXCEPTION
  when others then
     x_return_status:=fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.add_exc_msg
       (p_pkg_name       => 'PA_SECURITY_PVT',
        p_procedure_name => 'UPDATE_STATUS_BASED_SEC',
        p_error_text     => SQLCODE);
     FND_MSG_PUB.Count_And_Get
                    (p_count             =>      x_msg_count ,
                     p_data              =>      x_msg_data
                     );
END update_status_based_sec;

end PA_SECURITY_PVT;

/

  GRANT EXECUTE ON "APPS"."PA_SECURITY_PVT" TO "EBSBI";

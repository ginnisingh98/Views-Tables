--------------------------------------------------------
--  DDL for Package Body UMX_PROXY_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_PROXY_USER_PVT" as
/*$Header: UMXVPRXB.pls 120.2.12010000.12 2017/10/25 07:09:08 avelu ship $*/

  /**
   * Private function
   */

function get_job_title(p_person_id in per_all_people_f.person_id%type) return varchar2 is

 cursor get_title is select job.name
        from per_all_assignments_f passign, per_jobs_vl job
	where passign.person_id = p_person_id
        and   passign.job_id = job.job_id
	and   passign.effective_start_date <= sysdate
	and   nvl(passign.effective_end_date, sysdate+1) > sysdate;

 l_title per_jobs_vl.name%type;
 begin

   open get_title;
   fetch get_title into l_title;
   close get_title;
 return  l_title;
end get_job_title;
/**
   * Please refer to the package specifications for details
   */

function GET_PERSON_ID (p_party_id  in hz_parties.party_id%type) return number IS

begin

return UMX_REGISTRATION_PVT.get_person_id(p_party_id);

END GET_PERSON_ID;

   /**
   * Please refer to the package specifications for details
   */

  function GET_PHONE_NUMBER(p_person_id  in per_all_people_f.person_id%type) return varchar2 IS

l_phone_number per_phones.phone_number%type;
cursor find_phone_number is
 select perph.phone_number
 from   per_phones perph
 where  perph.phone_type = 'W1'
 and    perph.parent_id = p_person_id
 and    perph.parent_table = 'PER_ALL_PEOPLE_F'
 and    perph.date_from <= sysdate
 and    nvl(perph.date_to, sysdate + 1) > sysdate;


begin

open find_phone_number;
fetch find_phone_number into l_phone_number;
close find_phone_number;

return l_phone_number;

END GET_PHONE_NUMBER;


   /**
   * Please refer to the package specifications for details
   */


 procedure GET_EMP_DATA(p_person_id  in per_all_people_f.person_id%type,
                         x_phone_number out NOCOPY PER_PHONES.PHONE_NUMBER%TYPE ,
                         x_job_title out NOCOPY PER_JOBS_VL.NAME%TYPE
                         ) IS

 begin

    x_phone_number := GET_PHONE_NUMBER(p_person_id);
    x_job_title := GET_JOB_TITLE(p_person_id);

 end GET_EMP_DATA;

 PROCEDURE update_proxy_role(
    x_role_name in varchar2,
    x_grantee in varchar2,
    x_end_date in DATE default null)
is
l_start_date Date;
begin
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.update_proxy_role.begin',
                     'RoleName: ' || x_role_name);
       end if;

       select start_date into l_start_date from wf_local_roles where name = x_role_name;
       umx_access_roles_pvt.update_role
                                  (p_role_name       => x_role_name
                                  ,p_orig_system     => 'UMX'
                                  ,p_orig_system_id  => 0
                                  ,p_start_date      => l_start_date
                                  ,p_expiration_date => x_end_date
                                  ,p_display_name    => x_role_name
                                  ,p_owner_tag       => NULL
                                  ,p_description     => 'Proxy Role' );
      if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.update_proxy_role.end',
                     'End');
       end if;
end;


PROCEDURE create_proxy_role(
    X_grant_guid in  varchar2,
    x_grantee in varchar2,
    x_end_date in DATE default null,
    x_role_name out NOCOPY varchar2)
is
l_Is_Role_EndDated number := 0;
l_role_name varchar2(200);

begin
   if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.create_proxy_role.begin',
                     'GrantGuid: ' || X_grant_guid || 'Grantee: ' ||  x_grantee);
   end if;
   l_role_name :=    'UMX|UMX_PROXY_' || X_grant_guid ;
   begin
   select 1 into l_Is_Role_EndDated  from wf_local_roles where name = l_role_name and EXPIRATION_DATE is not null;

   if l_Is_Role_EndDated = 1 then

         update_proxy_role(l_role_name , x_grantee,  null);
   end if;
   exception when NO_DATA_FOUND then

         UMX_ACCESS_ROLES_PVT.insert_role(p_role_name        => l_role_name,
                                      p_orig_system     => 'UMX',
                                      p_orig_system_id  =>  0,
                                      p_start_date      => sysdate,
                                      p_expiration_date => null,
                                      p_display_name    => l_role_name,
                                      p_owner_tag       => null,
                                      p_description     => 'Proxy Role');

   end;
   x_role_name := l_role_name;
   if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.create_proxy_role.end',
                     'End');
   end if;

end;

 procedure create_proxy_setup(
     X_grantor in  varchar2,
    X_grantee in varchar2,
    x_start_date in DATE default sysdate,
    x_end_date in DATE default null,
    x_grant_name in varchar2,
    x_grant_description in varchar2,
    x_is_restricted in varchar2,
   x_role_name out NOCOPY varchar2
)

is
l_GRANT_GUID raw(32767);
l_SUCCESS varchar2(100);
l_ERRORCODE number;
l_proxy_grant_guid raw(32767);
l_grantee_user_id number;
begin

  if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.create_proxy_setup.begin',
                     'Grantor: ' || X_grantor || 'Grantee: ' ||  x_grantee || 'Is Restricted: ' || x_is_restricted );
  end if;
  fnd_grants_pkg.grant_function(
   P_Api_Version  =>     1.0,
    p_menu_name    => 'FND_PROXY_USER_ACCESS',
    p_object_name  =>  'FND_USER',
    P_Instance_Type  =>  'INSTANCE',
		 p_instance_pk1_value => fnd_global.user_id,
    P_Grantee_Key   => X_grantee,
    p_grantee_type => 'USER',
    p_start_date  => x_start_date,
    p_end_date    =>  x_end_date,
    p_program_name  => 'PROXY',
		p_program_tag => 'UMX',
    x_grant_guid  => l_grant_guid,
    x_success    => l_success, /* Boolean */
    X_ERRORCODE  => l_ERRORCODE,
    P_Name        => x_grant_name,
    P_DESCRIPTION    => x_grant_description
		);
   l_proxy_grant_guid := l_grant_guid;

 fnd_grants_pkg.grant_function(
	P_Api_Version => 1.0,
	p_menu_name => 'FND_PROXY_SWITCH_RETURN_PERMS',
	p_object_name => 'GLOBAL',
	P_Instance_Type => 'GLOBAL',
	P_Grantee_Key => X_grantee,
	p_start_date => x_start_date,
	p_end_date => x_end_date,
	p_program_name => 'PROXY',
	p_program_tag => 'UMX',
	x_grant_guid => l_grant_guid,
	x_success => l_success, /* Boolean */
	X_ERRORCODE => l_ERRORCODE,
	P_Name => x_grant_name,
	P_DESCRIPTION => x_grant_description
	);

  UMX_PROXY_NTF_WF.LAUNCH_WORKFLOW(p_proxy_username => x_grantee,
								 p_start_date   => x_start_date,
								 p_end_date => x_end_date,
                 p_notes => x_grant_description );



  if  x_is_restricted = 'TRUE' then
         create_proxy_role(l_proxy_grant_guid, x_grantee, null , x_role_name);
  else
        x_role_name := null;
  end if;


  if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.create_proxy_setup.end',
                     'End' );
  end if;

exception when others then
    if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.create_proxy_setup',
                     'Exception Thrown. Error: ' || SQLERRM);
    end if;
    raise;


end;


PROCEDURE update_proxy_setup(
    x_grant_guid in raw,
    x_grantee in varchar2,
    x_role_name in out NOCOPY varchar2,
    x_start_date in DATE,
    x_end_date in DATE,
    x_is_restricted in varchar2,
    x_grant_name in varchar2,
    x_grant_description in varchar2
)
is
l_SUCCESS varchar2(100);
ui_grant_guid raw(32767);
old_start_date date;
old_end_date date;
begin

  if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.update_proxy_setup.begin',
                     'Grant Guid: ' || x_grant_guid);
  end if;

  -- Fetch the corresponding UI grant for the proxy grant guid that is passed.
  -- This is done by comparing the dates of proxy grant and the UI grant
  select start_date , end_date into old_start_date ,old_end_date from fnd_grants where grant_guid = x_grant_guid;
  SELECT  grant_guid
  INTO    ui_grant_guid
  FROM    fnd_grants
  WHERE   menu_id =
          (
          SELECT  menu_id
          FROM    fnd_menus_vl
          WHERE   menu_name = 'FND_PROXY_SWITCH_RETURN_PERMS'
          )
  AND     trunc (start_date) = trunc (old_start_date)
  AND     nvl (trunc (end_date)
              ,sysdate) = nvl (trunc (old_end_date)
                              ,sysdate)
  AND     grantee_key = x_grantee
  AND     rownum = 1;
  FND_GRANTS_pkg.update_grant(
   p_api_version    => 1.0,
   p_grant_guid     => ui_grant_guid,
   p_start_date     => x_start_date,
   p_end_date       => x_end_date,
   x_success        => l_success
  );
  FND_GRANTS_pkg.update_grant(
   p_api_version    => 1.0,
   p_grant_guid     => x_grant_guid,
   p_start_date     => x_start_date,
   p_end_date       => x_end_date,
   p_name           => x_grant_name,
   p_description    => x_grant_description,
   x_success        => l_success
  );


if x_is_restricted = 'TRUE' then
   if x_role_name is null then

       create_proxy_role(RAWTOHEX(x_grant_guid), x_grantee,  null , x_role_name);
   end if;
else  -- ALL access
   if x_role_name is not null then

      update_proxy_role(x_role_name , x_grantee,  sysdate);
   end if;
end if;

  if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.update_proxy_setup.end',
                     'End' );
  end if;

exception when others then
     if (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) then
      FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                     'fnd.plsql.UMXVPRXB.update_proxy_setupp',
                     'Exception Thrown. Error: ' || SQLERRM);
    end if;
    raise;
end;

 PROCEDURE migrate_wl_proxy
 AS
  GRT_GUID FND_GRANTS.GRANT_GUID % TYPE := '';
  GRT_GUID_SEC FND_GRANTS.GRANT_GUID % TYPE := '';
  GRT_SUCCESS VARCHAR2(30);
  GRT_ERRORCODE NUMBER;

  error_msg varchar2(300) := '';
  error_code varchar2(100) := '';

  -- WorkList Proxy Users
  cursor worklistProxyUser is select fg.*
							 from FND_GRANTS fg, fnd_menus_vl fm, fnd_objects fo, fnd_object_instance_sets fos
							 where  fm.menu_name = 'FND_WF_WORKLIST' and
											fo.obj_name = 'NOTIFICATIONS' and
											fos.instance_set_name = 'WL_PROXY_ACCESS' and
											fg.MENU_ID = fm.menu_id and
											fg.OBJECT_ID = fo.object_id and
											fg.INSTANCE_SET_ID = fos.instance_set_id;

	wf_puser FND_GRANTS % rowtype;
	v_proxyRole VARCHAR2(300) := 'UMX|UMX_PROXY_';

  -- Global proxy user validation code
	cursor isGrantPresent(grantee_key_in varchar, grantor_key_in varchar) is select grant_guid
													from FND_GRANTS fg, fnd_menus_vl fm, fnd_objects fo
													where fm.menu_name = 'FND_PROXY_USER_ACCESS' and
																fo.obj_name = 'FND_USER' and
																fg.MENU_ID = fm.menu_id and
																fg.OBJECT_ID = fo.object_id and
																fg.GRANTEE_TYPE = 'USER' and -- we can skip this criteria
																fg.GRANTEE_KEY = grantee_key_in and-- wf_puser.GRANTEE_KEY
																fg.INSTANCE_PK1_VALUE = grantor_key_in;

	c_grant_id isGrantPresent % rowtype;

	cursor isProxyRolePresent(pxRole varchar) is select 1 from wf_roles where name = pxRole;
	c_IsRolePresent isProxyRolePresent % rowtype;

	isGrtGuid FND_GRANTS.GRANT_GUID % TYPE;
	isPxRolePresent boolean;
	isProxyGrantNotPresent boolean;
	v_WlUserId FND_USER.USER_ID % TYPE;

BEGIN
  open worklistProxyUser;
	FND_GLOBAL.APPS_INITIALIZE(0,20420,1); -- Ask WF team, do we needed it... or call in special way
  loop
    BEGIN
    fetch worklistProxyUser into wf_puser;
		exit when worklistProxyUser%notfound;

		isPxRolePresent := false;
		isProxyGrantNotPresent := true;
		BEGIN
			SELECT USER_ID into v_WlUserId FROM FND_USER WHERE USER_NAME = wf_puser.PARAMETER1;
			EXCEPTION WHEN NO_DATA_FOUND THEN
 						if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,'fnd.sql.WorkListUserMigrationIssue','User Not Found' ||wf_puser.PARAMETER1 );
         				end if;
			CONTINUE;

		END;

			open isGrantPresent(wf_puser.GRANTEE_KEY, v_WlUserId);
			loop
			    fetch isGrantPresent into c_grant_id;
					exit when isGrantPresent%notfound;
					isProxyGrantNotPresent := false;
					open isProxyRolePresent(v_proxyRole||c_grant_id.grant_guid);
					loop
				    fetch isProxyRolePresent into c_IsRolePresent;
						exit when isProxyRolePresent%notfound;
						isPxRolePresent := true;
					end loop;
  				close isProxyRolePresent;
			end loop;
  		close isGrantPresent;

		if isPxRolePresent then

			 continue;
		end if;

-- First Grant: Global Proxy grant for each worklist proxy user

--		SELECT USER_ID into v_WlUserId FROM FND_USER WHERE USER_NAME = wf_puser.PARAMETER1;
  if isProxyGrantNotPresent then
		FND_GRANTS_PKG.GRANT_FUNCTION
      (P_API_VERSION                   =>   1.0
      ,P_MENU_NAME                     =>   'FND_PROXY_USER_ACCESS'
      ,P_OBJECT_NAME                   =>   'FND_USER'
      ,P_INSTANCE_TYPE                 =>   'INSTANCE'
      ,P_INSTANCE_PK1_VALUE            =>   v_WlUserId
      ,P_GRANTEE_TYPE                  =>  'USER'
      ,P_GRANTEE_KEY                   =>  wf_puser.GRANTEE_KEY --GRANTEE_ORIG_SYSTEM_ID
      ,P_START_DATE                    =>  wf_puser.START_DATE
      ,P_END_DATE                      =>  wf_puser.END_DATE
      ,P_PROGRAM_NAME                  =>  'PROXY'
      ,P_PROGRAM_TAG                   =>  'UMX'
      ,x_grant_guid										 => GRT_GUID
	  ,x_success											 => GRT_SUCCESS
	  ,x_errorcode										 => GRT_ERRORCODE
      ,P_NAME                          => 'Grant Proxy Access'
      ,P_DESCRIPTION                   => substr(wf_puser.INSTANCE_PK1_VALUE,1,240)
      );


		-- Second Grant: Global Switch user link grant for Worklist user
		FND_GRANTS_PKG.GRANT_FUNCTION
      (P_API_VERSION                   => 1.0
      ,P_MENU_NAME                     => 'FND_PROXY_SWITCH_RETURN_PERMS'
      ,P_OBJECT_NAME                   => 'GLOBAL' -- in db it will be mapped as -1
      ,P_INSTANCE_TYPE                 => 'GLOBAL'
      ,P_GRANTEE_TYPE                  => 'USER' -- Mode: IN    Mandatory: false  Data Type: VARCHAR2
      ,P_GRANTEE_KEY                   =>  wf_puser.GRANTEE_KEY -- Parameter1 holds the Grantee User Name
      ,P_START_DATE                    =>  wf_puser.START_DATE
      ,P_END_DATE                      =>  wf_puser.END_DATE
      ,P_PROGRAM_NAME                  =>   'PROXY'
      ,P_PROGRAM_TAG                   =>   'UMX'
  	  ,x_grant_guid										 => GRT_GUID_SEC
	  ,x_success											 => GRT_SUCCESS
	  ,x_errorcode										 => GRT_ERRORCODE
      ,P_NAME                          => 'Grant Proxy Access'
      ,P_DESCRIPTION                   => substr(wf_puser.INSTANCE_PK1_VALUE,1,240)
      );


		-- Create Proxy Role with No-Access and assign to worklist user
 		WF_DIRECTORY.CREATEROLE(
		ROLE_NAME                       => v_proxyRole||GRT_GUID  -- As per the naming convention
       ,ROLE_DISPLAY_NAME               => v_proxyRole||GRT_GUID
       ,ORIG_SYSTEM                     => 'UMX'
       ,ORIG_SYSTEM_ID                  => 0
       ,ROLE_DESCRIPTION                => 'Proxy Role generated by User Management, Please do not modify.'
       ,EXPIRATION_DATE                 => wf_puser.END_DATE
       ,START_DATE                      => wf_puser.START_DATE
       ,PARENT_ORIG_SYSTEM              => 'UMX'
       ,PARENT_ORIG_SYSTEM_ID           =>  0
       ,OWNER_TAG                       =>  'FND'
       ,LAST_UPDATE_DATE                =>  sysdate
       ,LAST_UPDATED_BY                 =>  FND_GLOBAL.USER_ID
       ,CREATION_DATE                   =>  sysdate
       ,CREATED_BY                      =>  FND_GLOBAL.USER_ID
       ,LAST_UPDATE_LOGIN               =>  0
       );
    end if;
     exception
	     WHEN OTHERS THEN
         error_code := SQLCODE;
         error_msg := SQLERRM;
         if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,'fnd.sql.WorkListUserMigrationIssue','Exception occurred while migrating:' || wf_puser.grantee_key || '-' || wf_puser.parameter1  || ' Error-' || error_code|| ' : '||error_msg);
         end if;
    end;
  end loop;
  close worklistProxyUser;
	EXCEPTION
     WHEN OTHERS THEN
         error_code := SQLCODE;
         error_msg := SQLERRM;
         if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,'fnd.sql.WorkListUserMigrationIssue','Exception : '||error_code||' : '||error_msg);
         end if;
				 close worklistProxyUser;
         ROLLBACK;
END;

end UMX_PROXY_USER_PVT;

/

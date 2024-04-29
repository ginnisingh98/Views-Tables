--------------------------------------------------------
--  DDL for Package Body UMX_FGA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_FGA_UTILS_PKG" as
    /* $Header: UMXFGAUTILB.pls 120.2.12010000.7 2009/09/09 10:39:36 kkasibha noship $ */

    role_Code varchar2(1000);
    role_Cat  varchar2(1000);
    role_Appl varchar2(1000);
    role_Set_Id varchar2(1000);
    bulk_selection_value varchar2(1);

	procedure endDate_grants(adminRole varchar2) is
	begin
		update fnd_grants set END_DATE = sysdate,
									  LAST_UPDATE_DATE = sysdate,
                                      LAST_UPDATED_BY = 1000002,
                                      LAST_UPDATE_LOGIN = 1000002
		where grantee_key = adminRole and
              object_id in (select object_id from fnd_objects where obj_name='UMX_ACCESS_ROLE');
	end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure convert_All_Grants_to_roleSets is
        cursor adminRoles is select distinct grantee_key
                              from fnd_grants fg,
                                  fnd_objects fo
                                  --,fnd_menus fm
                              where --fg.menu_id = fm.menu_id and
                                  fg.object_id = fo.object_id
                                  --and fm.menu_name = 'UMX_OBJ_ADMIN_ROLE_PERMS'
                                  and fo.obj_name = 'UMX_ACCESS_ROLE'
                                  and fg.start_date <= sysdate
                                  and nvl(fg.end_date, sysdate+1) > sysdate
                                  and GRANTEE_ORIG_SYSTEM in ('UMX','FND_RESP');
    begin
        for adminRole in adminRoles
        loop
            create_roleSet_from_grants(adminRole.grantee_key);
        end loop;
    end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

	procedure copy_grants_to_roleSets(adminRole varchar2, roleSetId number) is
	begin
		insert into UMX_LSA_ROLE_SET_ROLES (role_set_id, role_name) select roleSetId, INSTANCE_PK1_VALUE
										  from fnd_grants fg,
											  fnd_objects fo,
											  fnd_menus fm,
											  wf_all_roles_vl wfr
										  where fg.menu_id = fm.menu_id
											  and fg.object_id = fo.object_id
											  and INSTANCE_PK1_VALUE  =  wfr.name (+)
											  and grantee_key = adminRole
											  and fm.menu_name = 'UMX_OBJ_ADMIN_ROLE_PERMS'
											  and fo.obj_name = 'UMX_ACCESS_ROLE'
                                              and INSTANCE_TYPE = 'INSTANCE'
                                              and fg.start_date <= sysdate
                                              and nvl(fg.end_date, sysdate+1) > sysdate;
	end;


/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    /*
         Case 1: Converting grants containing all roles
                a. Create a new role set criteria if not already present with role set Id as  '0'
                b. Add the roleSet with Id '0' to the adminRole with all the privilages set
                c. no entries will be added to the roleSet_roles table
         Case 2: Converting grants containing a set of roles`
                a. Create a new role set criteria
                b. Add the new roleSet to the adminRole
                c. Add the roles in the grants to the new role set
                d. Add the roleSet with Id '0' to the adminRole with all the privilages set except assign and revoke
        */
	procedure create_roleSet_from_grants(adminRole varchar2) is
		roleSetId UMX_LSA_ROLE_SET_ROLES.role_set_id%type;
        cnt number(6);
        errm varchar2(300) := '';
        errcode varchar2(100) := '';
	begin
        select count(*) into cnt
        from UMX_LSA_ROLE_SET_CRITERIA ulrsc,
             UMX_LSA_ROLE ulr
        where ulr.admin_role = adminRole
            and ulrsc.role_set_id = ulr.role_Set_Id
            and ulrsc.role_name = '*'
            and ulrsc.role_appl = '*'
            and ulrsc.role_cat = '*';
        if(cnt<=0) then
            begin
            --For all roles
              select count(*) into cnt
              from fnd_grants fg,
                  fnd_objects fo
                  --fnd_menus fm,
                  --wf_all_roles_vl wfr
              where
              --fg.menu_id = fm.menu_id and
                  fg.object_id = fo.object_id
                  --and INSTANCE_PK1_VALUE  =  wfr.name (+)
                  and grantee_key = adminRole
                 -- and fm.menu_name = 'UMX_OBJ_ADMIN_ROLE_PERMS'
                  and fo.obj_name = 'UMX_ACCESS_ROLE'
                  and INSTANCE_TYPE = 'GLOBAL';
                if(cnt > 0) then --All Roles. typically the cnt will be 1
                    roleSetId := create_roleSet_criteria(0,'All Roles','**','**','**');
                    assign_roleSet_to_adminRole(adminRole,0);
                else    -- for some roles
                    roleSetId := create_roleSet_criteria(null,'Unspecified Criteria','*','*','*');
                    assign_roleSet_to_adminRole(adminRole,roleSetId);
                    copy_grants_to_roleSets(adminRole,roleSetId);
                    --assign privs for all roles with no assign and revoke perms
                    roleSetId := create_roleSet_criteria(0,'All Roles','**','**','**');
                    assign_roleSet_to_adminRole(adminRole, 0,
                                            canUpdate => 1,
											canManageGrants => 1,
											canAlterHierarchy => 1,
											canAssign => 0,
											canRevoke => 0,
											securityWizard => 1,
                                            PRIV7 => 1,
                                            PRIV8 => 1,
                                            PRIV9 => 1,
                                            PRIV10 => 1,
                                            PRIV11 => 1,
                                            PRIV12 => 1,
                                            PRIV13 => 1,
                                            PRIV14 => 1);
                end if;
                create_global_privileges(adminRole,1);
                endDate_grants(adminRole);
                --commit;
            exception
                when others then
                   errcode := SQLCODE;
                   errm := SQLERRM;
                   if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,'fnd.plsql.UMXFGAUTILB.create_roleSet_from_grants','Exception: '||errcode||' : '||errm);
                   end if;
                   rollback;
            end;
        end if;
	exception
		when others then
           errcode := SQLCODE;
           errm := SQLERRM;
           if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,'fnd.plsql.UMXFGAUTILB.create_roleSet_from_grants','Exception : '||errcode||' : '||errm);
           end if;
	end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure create_global_privileges(adminRole varchar2, canCreate number,
                                        GLOBALPRIV2 number default 1,
                                        GLOBALPRIV3 number default 1,
                                        GLOBALPRIV4 number default 1,
                                        GLOBALPRIV5 number default 1,
                                        GLOBALPRIV6 number default 1,
                                        GLOBALPRIV7 number default 1,
                                        GLOBALPRIV8 number default 1,
                                        GLOBALPRIV9 number default 1) is
        cnt number(2);
    begin
        select count(*) into cnt from UMX_LSA_ROLE_GLOBAL_PRIVS where admin_role = adminRole;
        if(cnt=0) then
            insert into UMX_LSA_ROLE_GLOBAL_PRIVS(admin_role,
                                                can_Create,
                                                GLOBAL_PRIV2 ,
                                                GLOBAL_PRIV3 ,
                                                GLOBAL_PRIV4 ,
                                                GLOBAL_PRIV5 ,
                                                GLOBAL_PRIV6 ,
                                                GLOBAL_PRIV7 ,
                                                GLOBAL_PRIV8 ,
                                                GLOBAL_PRIV9 )
                                         values(adminRole,
                                                canCreate,
                                                GLOBALPRIV2 ,
                                                GLOBALPRIV3 ,
                                                GLOBALPRIV4 ,
                                                GLOBALPRIV5 ,
                                                GLOBALPRIV6 ,
                                                GLOBALPRIV7 ,
                                                GLOBALPRIV8 ,
                                                GLOBALPRIV9 );
        else
            update UMX_LSA_ROLE_GLOBAL_PRIVS set can_Create = canCreate,
                                                GLOBAL_PRIV2 = GLOBALPRIV2,
                                                GLOBAL_PRIV3 = GLOBALPRIV3,
                                                GLOBAL_PRIV4 = GLOBALPRIV4,
                                                GLOBAL_PRIV5 = GLOBALPRIV5,
                                                GLOBAL_PRIV6 = GLOBALPRIV6,
                                                GLOBAL_PRIV7 = GLOBALPRIV7,
                                                GLOBAL_PRIV8 = GLOBALPRIV8,
                                                GLOBAL_PRIV9 = GLOBALPRIV9
            where admin_role = adminRole;
        end if;
    end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure create_assign_roleSet(adminRole varchar2,
                                    roleSetName varchar2 default null,
                                    roleName varchar2 default '%',
                                    roleAapl varchar2 default '',
                                    roleCat varchar2 default '',
                                    canUpdate number default 1,
                                    canManageGrants number default 1,
                                    canAlterHierarchy number default 1,
                                    canAssign number default 1,
                                    canRevoke number default 1,
                                    securityWizard number default 1,
                                    PRIVILEGE7 number default 1,
                                    PRIVILEGE8 number default 1,
                                    PRIVILEGE9 number default 1,
                                    PRIVILEGE10 number default 1,
                                    PRIVILEGE11 number default 1,
                                    PRIVILEGE12 number default 1,
                                    PRIVILEGE13 number default 1,
                                    PRIVILEGE14 number default 1)
    is
        roleSetId UMX_LSA_ROLE_SET_ROLES.role_set_id%type;
    begin
        roleSetId := create_roleSet_criteria(null,roleSetName,roleName,roleAapl,roleCat);
        assign_roleSet_to_adminRole(adminRole,roleSetId,
                                    canUpdate,
                                    canManageGrants,
                                    canAlterHierarchy,
                                    canAssign,
                                    canRevoke,
                                    securityWizard,
                                    PRIVILEGE7,
                                    PRIVILEGE8,
                                    PRIVILEGE9,
                                    PRIVILEGE10,
                                    PRIVILEGE11,
                                    PRIVILEGE12,
                                    PRIVILEGE13,
                                    PRIVILEGE14);
    end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

	function create_roleSet_criteria(roleSetId number default null,
                                     roleSetName varchar2 default null,
                                     roleName varchar2 default '%',
                                     roleAapl varchar2 default null,
                                     roleCat varchar2 default null)
    return number is
		roleSetIdNew UMX_LSA_ROLE_SET_ROLES.role_set_id%type;
        roleSetIdOld UMX_LSA_ROLE_SET_ROLES.role_set_id%type;
	begin
        --dbms_output.put_line('In create_roleSet_criteria : '||to_char(roleSetId));
        if(roleSetId is null) then
            select UMX_LSA_ROLE_SET_CRITERIA_S.nextval into roleSetIdNew from dual;
            --dbms_output.put_line('In if(roleSetId is null) : '||to_char(roleSetIdNew));
        else
            begin
                select role_set_id into roleSetIdOld from UMX_LSA_ROLE_SET_CRITERIA where role_set_id = roleSetId;
                update UMX_LSA_ROLE_SET_CRITERIA set role_set_name = roleSetName,
                                                     role_name = roleName,
                                                     role_appl = roleAapl,
                                                     role_cat = roleCat
                                               where role_set_id = roleSetId;
                --dbms_output.put_line('In if(roleSetId is null) else : '||to_char(roleSetId));
                return roleSetId;
            exception
                when no_data_found then
                    roleSetIdNew := roleSetId;
                    --dbms_output.put_line('In no_data_found : '||to_char(roleSetIdNew));
            end;
        end if;
		insert into UMX_LSA_ROLE_SET_CRITERIA (role_set_id,
                                               role_set_name,
                                               role_name,
                                               role_appl,
                                               role_cat)
                                        values(roleSetIdNew,
                                               roleSetName,
                                               roleName,
                                               roleAapl,
                                               roleCat);
		--dbms_output.put_line('returning : '||to_char(roleSetIdNew));
                return roleSetIdNew;
	end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure assign_roleSet_to_adminRole(adminRole varchar2, roleSetId number,
                                            canUpdate number default 1,
                                            canManageGrants number default 1,
                                            canAlterHierarchy number default 1,
                                            canAssign number default 1,
                                            canRevoke number default 1,
                                            securityWizard number default 1,
                                            PRIV7 number default 1,
                                            PRIV8 number default 1,
                                            PRIV9 number default 1,
                                            PRIV10 number default 1,
                                            PRIV11 number default 1,
                                            PRIV12 number default 1,
                                            PRIV13 number default 1,
                                            PRIV14 number default 1)
    is
        cnt number(10);
	begin
        select count(*) into cnt
        from UMX_LSA_ROLE
        where admin_role = adminRole
        and role_set_id = roleSetId;
        if(cnt=0) then
        		insert into UMX_LSA_ROLE(admin_role, role_set_id,
                                        can_update,
                                        CAN_CREATE_GRANT,
                                        can_alter_hierarchy,
                                        can_assign,
                                        can_revoke,
                                        security_wizard,
                                        PRIVILEGE7,
                                        PRIVILEGE8,
                                        PRIVILEGE9,
                                        PRIVILEGE10,
                                        PRIVILEGE11,
                                        PRIVILEGE12,
                                        PRIVILEGE13,
                                        PRIVILEGE14)
            					values(adminRole, roleSetId,
                                        canUpdate,
                                        canManageGrants,
                                        canAlterHierarchy,
                                        canAssign,
                                        canRevoke,
                                        securityWizard,
                                        PRIV7,
                                        PRIV8,
                                        PRIV9,
                                        PRIV10,
                                        PRIV11,
                                        PRIV12,
                                        PRIV13,
                                        PRIV14);
         else
            update UMX_LSA_ROLE set can_update = canUpdate,
                                    CAN_CREATE_GRANT = canManageGrants,
        							can_alter_hierarchy =   canAlterHierarchy,
        							can_assign = canAssign,
        							can_revoke = canRevoke,
        							security_wizard = securityWizard,
                                    PRIVILEGE7 = PRIV7,
                                    PRIVILEGE8 = PRIV8,
                                    PRIVILEGE9 = PRIV9,
                                    PRIVILEGE10 = PRIV10,
                                    PRIVILEGE11 = PRIV11,
                                    PRIVILEGE12 = PRIV12,
                                    PRIVILEGE13 = PRIV13,
                                    PRIVILEGE14 = PRIV14
                            where admin_role = adminRole and role_Set_Id = roleSetId;
         end if;
	end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure create_all_roles_roleset is
        cnt number(2);
    BEGIN
        select count(*) into cnt
        from UMX_LSA_ROLE_SET_CRITERIA where role_set_id = 0;
    EXCEPTION
        when NO_DATA_FOUND then
        insert into UMX_LSA_ROLE_SET_CRITERIA(role_set_id,
                                               role_set_name,
                                               role_name,
                                               role_appl,
                                               role_cat)
                                        VALUES(0,'All Roles','**','**','**');
    END;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure bulk_add_all(p_role_set_id varchar2) is
    begin
        insert into umx_lsa_role_set_roles (role_set_id,
                                            role_name,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATE_LOGIN)

         select p_role_set_id,
                wlr.name,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id
         from WF_LOCAL_ROLES wlr,
             WF_LOCAL_ROLES_TL wlrt,
             FND_LOOKUP_ASSIGNMENTS cat,
             umx_lsa_role_set_criteria ulrsc
         where cat.OBJ_NAME(+) = 'UMX_ACCESS_ROLE'
             and nvl(cat.LOOKUP_CODE,'%') like ulrsc.role_cat
             and wlr.name = cat.INSTANCE_PK1_VALUE(+)
             and cat.INSTANCE_PK2_VALUE is null
             and cat.INSTANCE_PK3_VALUE is null
             and cat.INSTANCE_PK4_VALUE is null
             and cat.INSTANCE_PK5_VALUE is null
             and wlr.owner_tag like ulrsc.role_Appl
             and ulrsc.role_set_id = p_role_set_id
             and wlr.name like ulrsc.role_name
             and wlr.partition_id in (2,13)
             and wlr.orig_system in ('UMX','FND_RESP')
             and wlr.orig_system_id like '%'
             and wlr.orig_system = wlrt.orig_system (+)
             and wlr.orig_system_id = wlrt.orig_system_id (+)
             and wlr.name = wlrt.name (+)
             and wlr.partition_id = wlrt.partition_id (+)
             and wlrt.language (+) = userenv('LANG')
             and not exists (select role_name from UMX_LSA_ROLE_SET_ROLES
                             where role_set_id = p_role_set_id
                                   and role_name = wlr.name);
    end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure bulk_add_all_for_new(p_role_set_id varchar2, p_role_name varchar2, p_role_appl varchar2, p_role_cat varchar2) is
    begin
        insert into umx_lsa_role_set_roles (role_set_id,
                                            role_name,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            LAST_UPDATED_BY,
                                            LAST_UPDATE_DATE,
                                            LAST_UPDATE_LOGIN)
         select p_role_set_id,
                wlr.name,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id
         from WF_LOCAL_ROLES wlr,
              FND_LOOKUP_ASSIGNMENTS cat
         where wlr.owner_tag like p_role_appl
               and wlr.name like p_role_name
               and wlr.partition_id in (2,13)
               and wlr.orig_system in ('UMX','FND_RESP')
               and wlr.orig_system_id like '%'
               and cat.OBJ_NAME(+) = 'UMX_ACCESS_ROLE'
               and nvl(cat.LOOKUP_CODE,'%') like p_role_cat
               and wlr.name = cat.INSTANCE_PK1_VALUE(+)
               and cat.INSTANCE_PK2_VALUE is null
               and cat.INSTANCE_PK3_VALUE is null
               and cat.INSTANCE_PK4_VALUE is null
               and cat.INSTANCE_PK5_VALUE is null;
    end;

/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure bulk_remove_all(p_role_set_id varchar2) is
    begin
        delete from umx_lsa_role_set_roles where role_set_id = p_role_set_id;
    end;
/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure delete_role_Set(p_role_set_id varchar2,p_admin_role varchar2) is
    begin
        delete from umx_lsa_role_set_roles
        where role_set_id = p_role_set_id;

        if(p_role_set_id <> 0) then
            delete from umx_lsa_role_set_criteria
            where role_set_id = p_role_set_id;
        end if;

        if(p_admin_role is not null) then
            delete from umx_lsa_role
            where role_set_id = p_role_set_id and admin_role = p_admin_role;
        else
            delete from umx_lsa_role
            where role_set_id = p_role_set_id;
        end if;
    end;
/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure set(code in varchar2, value in varchar2) is
    begin
        if(code='ROLE_CODE') then
            role_Code := value;
        elsif(code='ROLE_CAT') then
            role_Cat := value;
        elsif(code='ROLE_APPL') then
            role_Appl := value;
        elsif(code='ROLE_SET_ID') then
            role_Set_Id := value;
        elsif(code='BULK_SELECTION_VALUE') then
            bulk_selection_value := value;
        end if;
    end;
/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    function get(code in varchar2) return varchar2 is
    begin
        if(code='ROLE_CODE') then
            return role_Code;
        elsif(code='ROLE_CAT') then
            return role_Cat;
        elsif(code='ROLE_APPL') then
            return role_Appl;
        elsif(code='ROLE_SET_ID') then
            return role_Set_Id;
        elsif(code='BULK_SELECTION_VALUE') then
            return bulk_selection_value;
        else
            return null;
        end if;
    end;
/*******************************************************************************************************************************/
/*******************************************************************************************************************************/

    procedure clearViewParams is
    begin
        role_Code := '';
        role_Cat := '';
        role_Appl := '';
        role_Set_Id := '';
        bulk_selection_value := '';
    end;
/*******************************************************************************************************************************/
/*******************************************************************************************************************************/
end;

/

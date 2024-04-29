--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ROLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ROLES_PUB" AS
/* $Header: ENGCMRLB.pls 120.1 2005/11/28 02:32:15 sdarbha noship $ */

-------------------------------------------
--   Type           : Private
--   Procedure to get the Default access. Returns default access  as follows
--   Administrator  => Edit and View privileges
--   Reader         => View privilege
--   Discoverer     => None among Edit or View privileges

PROCEDURE Get_Default_Access(p_menu_id IN NUMBER, p_default_access OUT NOCOPY VARCHAR2)
IS
     v_edit_priv NUMBER;
     v_view_priv NUMBER;
BEGIN
     v_edit_priv := 0;
     v_view_priv := 0;

     SELECT count(function_name) into v_edit_priv
     FROM fnd_form_functions
     WHERE function_name='ENG_EDIT_CHANGE' AND
     function_id IN (SELECT function_id FROM fnd_menu_entries WHERE menu_id = p_menu_id);

     SELECT count(function_name) into v_view_priv
     FROM fnd_form_functions
     WHERE function_name='ENG_VIEW_CHANGE' AND
     function_id IN (SELECT function_id FROM fnd_menu_entries WHERE menu_id = p_menu_id);

     --   If the role has Edit privilege then return Administrator
     IF v_edit_priv > 0 OR (v_edit_priv > 0 AND v_view_priv > 0) THEN
          p_default_access := 'Administrator';
     END IF;

     --   If the role has View Privilege then return Reader
     IF v_view_priv > 0 and v_edit_priv = 0 THEN
          p_default_access := 'Reader';
     END IF;

     --   If the role has none then return Discoverer
     IF v_view_priv = 0 and v_edit_priv = 0 THEN
          p_default_access := 'Discoverer';
     END IF;

END Get_Default_Access;
-------------------------------------------
/*
--   Procedure to print a big line which exceeds 255 chars.
--   It breaks up the line and displays.
procedure p( p_string in varchar2 )
is
   l_string long default p_string;
begin
   loop
     exit when l_string is null;
     dbms_output.put_line( substr( l_string, 1, 250 ) );
     l_string := substr( l_string, 251 );
   end loop;
end p;
*/
--------------------------------------------------------



-- API name  : Get_Change_Users
-- Type      : Public
-- Pre-reqs  : None
-- Function  : Gets list of users who has some role on change object.
--             If no role is passed i.e if p_role_name is null
--                 then the API returns list of roles available on the item
--                 with the set of users who bear each role.
--             If some role is mentioned, then the list of user who bear
--                 this role on the item are displayed.
-- IN    :      p_api_version               IN  NUMBER         Required
--                      p_entity_name               IN  VARCHAR2       Required
-- Version: Current Version 1.0
-- Previous Version :  1.0
-- Notes  :

PROCEDURE Get_Change_Users
  (
   p_api_version               IN  NUMBER,
   p_entity_name               IN  VARCHAR2,
   p_pk1_value                 IN  VARCHAR2,
   p_pk2_value                 IN  VARCHAR2,
   p_pk3_value                 IN  VARCHAR2,
   p_pk4_value                 IN  VARCHAR2,
   p_pk5_value                 IN  VARCHAR2,
   p_role_name                 IN  VARCHAR2 DEFAULT NULL,
   x_grantee_names             OUT NOCOPY FND_TABLE_OF_VARCHAR2_120,
   x_grantee_types             OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_role_names                OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_role_display_names        OUT NOCOPY FND_TABLE_OF_VARCHAR2_120,
   x_default_access            OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_return_status             OUT NOCOPY VARCHAR2
  )
  AS

  l_entity_name  varchar2(30);
  l_pk1_value    varchar2(50);
  l_pk2_value    varchar2(50);
  l_pk3_value    varchar2(50);
  l_pk4_value    varchar2(50);
  l_pk5_value    varchar2(50);
  l_role_name    varchar2(100);

  l_inst_set_ids        varchar2(32767);
  l_obj_ids             varchar2(32767);
  query_to_exec         varchar2(32767);
  cursor_select         NUMBER;
  cursor_execute        NUMBER;
  all_roles_count       NUMBER;
  l_change_has_items    BOOLEAN;

  -- Cursor to get the direct roles on the change object
  CURSOR change_users_cur (cp_entity_name  VARCHAR2,
                       cp_pk1_value     VARCHAR2,
                       cp_pk2_value     VARCHAR2,
                       cp_pk3_value     VARCHAR2,
                       cp_pk4_value     VARCHAR2,
                       cp_pk5_value     VARCHAR2,
                       cp_role_name    VARCHAR2)
   IS
        SELECT
             parties.party_name grantee_name,
             grantee_type,
             role_name,
             role_display_name,
             menu_id
        FROM hz_parties parties,
                (
                SELECT DISTINCT
                        GRANTS.grantee_orig_system_id grantee_orig_system_id,
                        DECODE(grants.grantee_key,'GLOBAL','HZ_GLOBAL', SUBSTR(grants.grantee_key,0, INSTR(grants.grantee_key,':',1,1)-1)) grantee_orig_system,
                        GRANTS.grantee_type grantee_type,
                        menus.Menu_name role_name,
                        menus.user_menu_name role_display_name,
                        grants.grantee_key,
                        menus.menu_id menu_id
                FROM fnd_grants GRANTS,
                        fnd_objects OBJECTS,
                        fnd_menus_vl MENUS
                WHERE OBJECTS.object_id = GRANTS.object_id
                        AND OBJECTS.obj_name=cp_entity_name
                        AND GRANTS.instance_type='INSTANCE'
                        AND GRANTS.instance_pk1_value=cp_pk1_value
                        AND
                        ((      grants.instance_pk2_value = cp_pk2_value
                         ) OR (( grants.instance_pk2_value = '*NULL*')
                                  AND ( cp_pk2_value is NULL)
                        ))
                        AND
                        ((      grants.instance_pk3_value = cp_pk3_value
                         ) OR (( grants.instance_pk3_value = '*NULL*')
                                  AND ( cp_pk3_value is NULL)
                        ))
                        AND
                        ((      grants.instance_pk4_value = cp_pk4_value
                         ) OR (( grants.instance_pk4_value = '*NULL*')
                                  AND ( cp_pk4_value is NULL)
                        ))
                        AND
                        ((      grants.instance_pk5_value = cp_pk5_value
                         ) OR (( grants.instance_pk5_value = '*NULL*')
                                  AND ( cp_pk5_value is NULL)
                        ))
                        AND GRANTS.menu_id = MENUS.menu_id
                        AND
                        ((      cp_role_name is null AND menus.menu_name like '%'
                         )      OR ( MENUS.MENU_NAME in (cp_role_name)
                        ))
                        AND GRANTS.start_date <= sysdate
                        AND
                        (
                                GRANTS.end_date is null
                                OR grants.end_date >= SYSDATE
                        )
                ) grants        --      End of First From clause
                WHERE grantee_type in ('USER','GROUP')  --,'COMPANY','GLOBAL')
                        AND grantee_orig_system in ('HZ_PARTY','HZ_GROUP')  --,'HZ_COMPANY', 'HZ_GLOBAL')
                        AND parties.party_id=DECODE(grants.grantee_key,'GLOBAL',-1000, SUBSTR(grants.grantee_key, INSTR(grants.grantee_key,':',1,1)+1));

     CURSOR change_subjects_cur is
         SELECT pk1_value, pk2_value FROM eng_change_subjects where change_id = p_pk1_value;

     CURSOR change_rev_items_cur is
         SELECT revised_item_id, organization_id FROM eng_revised_items WHERE change_id = p_pk1_value; -- p_pk1_value = change_id

   l_grantee_list   GRANTEES_TBL_TYPE;
   l_index               NUMBER;
   l_revised_item_id     NUMBER;
   l_organization_id     NUMBER;
   l_temp_menu_id        NUMBER;
   l_default_access      VARCHAR2(30);

   l_item_id_and_org_id_sub  change_subjects_cur%ROWTYPE;
   l_item_id_and_org_id_rev  change_rev_items_cur%ROWTYPE;


  BEGIN
--dbms_output.enable(1000000);
--dbms_output.put_line('** sameer ** inside ENG_CHANGE_ROLES_PUB.Get_Change_Users ...');

l_revised_item_id := 0;
l_organization_id := 0;
l_index := 0;
l_change_has_items := FALSE;
l_temp_menu_id := 0;
l_default_access := 'Administrator';

     --   check whether there are any items in subjects or revised items
     OPEN change_subjects_cur;
          LOOP
               FETCH change_subjects_cur into l_item_id_and_org_id_sub;
               EXIT WHEN change_subjects_cur%NOTFOUND;
--dbms_output.put_line('** sameer ** change_subjects_cursor returned : ' || l_item_id_and_org_id_sub.pk1_value || ' , '
--                    || l_item_id_and_org_id_sub.pk2_value);

               l_revised_item_id := l_item_id_and_org_id_sub.pk1_value;
               l_organization_id := l_item_id_and_org_id_sub.pk2_value;
          END LOOP;
     CLOSE change_subjects_cur;

     IF l_revised_item_id = 0 OR l_revised_item_id is null then
          OPEN change_rev_items_cur;
               LOOP
                    FETCH change_rev_items_cur into l_item_id_and_org_id_rev;
                    EXIT WHEN change_rev_items_cur%NOTFOUND;
--dbms_output.put_line('** sameer ** change_rev_items_currsor returned : ' || l_item_id_and_org_id_rev.revised_item_id || ' , '
--                         || l_item_id_and_org_id_rev.organization_id);

                    l_revised_item_id := l_item_id_and_org_id_rev.revised_item_id;
                    l_organization_id := l_item_id_and_org_id_rev.organization_id;
               END LOOP;
          CLOSE change_rev_items_cur;
     END IF;

--l_obj_ids := p_pk1_value ;--|| ',' || p_pk2_value;
l_obj_ids := l_revised_item_id || ',' || l_organization_id;

IF l_revised_item_id is not null and l_organization_id is not null THEN
   l_change_has_items := TRUE;   --     there is an item associated with this change at subject or revised item level.
END IF;

--dbms_output.put_line('** sameer ** l_obj_ids after direct sqls .. : ' || l_obj_ids);

    x_return_status:='T';
    l_entity_name:=p_entity_name;
    l_pk1_value:=p_pk1_value;
    l_pk2_value:=p_pk2_value;
    l_pk3_value:=p_pk3_value;
    l_pk4_value:=p_pk4_value;
    l_pk5_value:=p_pk5_value;
    l_role_name:=p_role_name;
    all_roles_count := 0;

--dbms_output.put_line('** sameer ** looping change_users_cur ...');

    --    First, fetch the direct roles on the change object
    FOR rec IN change_users_cur(
                                        l_entity_name,
                                        l_pk1_value,
                                        l_pk2_value,
                                        l_pk3_value,
                                        l_pk4_value,
                                        l_pk5_value,
                                        l_role_name)
     LOOP
--dbms_output.put_line('** sameer ** in loop of  change_users_cur ...' || rec.grantee_name);
       l_grantee_list(l_index).grantee_name:=rec.grantee_name;
       l_grantee_list(l_index).grantee_type:=rec.grantee_type;
       l_grantee_list(l_index).role_name:=rec.role_name;
       l_grantee_list(l_index).role_display_name:=rec.role_display_name;
       l_temp_menu_id := rec.menu_id;

       -- Get the default access for this role
       Get_Default_Access(p_menu_id => l_temp_menu_id,
                          p_default_access => l_default_access
                          );

       l_grantee_list(l_index).default_access := l_default_access;
       l_index:=l_index+1;
    END LOOP;

    x_grantee_names          := FND_TABLE_OF_VARCHAR2_120();
    x_grantee_types          := FND_TABLE_OF_VARCHAR2_30();
    x_role_names             := FND_TABLE_OF_VARCHAR2_30();
    x_role_display_names     := FND_TABLE_OF_VARCHAR2_120();
    x_default_access         := FND_TABLE_OF_VARCHAR2_30();

    IF( l_grantee_list.count>0) THEN
      x_grantee_names.extend(l_grantee_list.count);
      x_grantee_types.extend(l_grantee_list.count);
      x_role_names.extend(l_grantee_list.count);
      x_role_display_names.extend(l_grantee_list.count);
      x_default_access.extend(l_grantee_list.count);

      FOR i in l_grantee_list.first .. l_grantee_list.last LOOP
        all_roles_count := all_roles_count + 1;

        x_grantee_names(all_roles_count):=l_grantee_list(i).grantee_name;
        x_grantee_types(all_roles_count):=l_grantee_list(i).grantee_type;
        x_role_names(all_roles_count):=l_grantee_list(i).role_name;
        x_role_display_names(all_roles_count):=l_grantee_list(i).role_display_name;
        x_default_access(all_roles_count):=l_grantee_list(i).default_access;

      END LOOP;

    END IF;

--dbms_output.put_line('** sameer ** Preparing SQL ot get the inherited Change Roles....');

    -----Get all the Change Management inherited roles including workflow assignees etc.
        query_to_exec :=
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            '(  ' ||
                            'SELECT  ' ||
                                'C.CHANGE_ID,  ' ||
                                'P.ASSIGNEE_ID,  ' ||
                                'C.CREATION_DATE  ' ||
                            'FROM WF_ACTIVITIES WA,  ' ||
                                'WF_ACTIVITY_ATTRIBUTES WAA,  ' ||
                                'ENG_CHANGE_ROUTE_STEPS S,  ' ||
                                'ENG_CHANGE_ROUTE_PEOPLE P,  ' ||
                                'ENG_CHANGE_ROUTES R,  ' ||
                                'ENG_ENGINEERING_CHANGES C  ' ||
                            'WHERE WAA.TEXT_DEFAULT = ''ENG_CHANGE_WF_APPROVERS''  ' ||
                                'AND WAA.NAME = ''DEFAULT_CHANGE_ROLE''  ' ||
                                'AND WAA.ACTIVITY_VERSION = WA.VERSION  ' ||
                                'AND WAA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE  ' ||
                                'AND WAA.ACTIVITY_NAME = WA.NAME  ' ||
                                'AND WA.TYPE = ''PROCESS''  ' ||
                                'AND WA.BEGIN_DATE <= SYSDATE  ' ||
                                'AND  ' ||
                                '( ' ||
                                    'WA.END_DATE >= SYSDATE  ' ||
                                    'OR WA.END_DATE IS NULL ' ||
                                ')  ' ||
                                'AND WA.ITEM_TYPE = S.WF_ITEM_TYPE  ' ||
                                'AND WA.NAME = S.WF_PROCESS_NAME  ' ||
                                'AND P.ASSIGNEE_ID <> -1  ' ||
                                'AND P.STEP_ID = S.STEP_ID  ' ||
                                'AND S.ROUTE_ID = R.ROUTE_ID  ' ||
                                'AND R.CLASSIFICATION_CODE = TO_CHAR(C.STATUS_CODE)  ' ||
                                'AND R.OBJECT_ID1 = C.CHANGE_ID  ' ||
                                'AND R.OBJECT_NAME = ''ENG_CHANGE'' ' ||
                                'AND R.TEMPLATE_FLAG = ''N''  ' ||
                            ')  ' ||
                            'child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.ASSIGNEE_ID  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_APPROVER''  ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            'FND_USER fuser,  ' ||
                            'FND_USER fpuser,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.CREATED_BY = fuser.user_id  ' ||
                            'AND child_table_name.CREATED_BY = fpuser.user_id  ' ||
                            'AND TO_CHAR(fuser.employee_id) = hzei.person_identifier(+)  ' ||
                            'AND fuser.customer_id = hzci.party_id(+)  ' ||
                            'AND fuser.supplier_id = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = hzei.party_id  ' ||
                            'AND hzei.party_type=''PERSON'' ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_CREATOR''  ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.ASSIGNEE_ID  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_ASSIGNEE''  ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''GROUP'' grantee_type,  ' ||
                            'grantee_group.party_name grantee_name,  ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES grantee_group,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = grantee_group.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND grantee_group.party_type = ''GROUP''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_ASSIGNEE''  ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name,  ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.REQUESTOR_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.REQUESTOR_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.REQUESTOR_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.REQUESTOR_ID  ' ||
                            'AND child_table_name.REQUESTOR_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION'' ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REQUESTOR'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''GROUP'' grantee_type,  ' ||
                            'grantee_group.party_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES grantee_group,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.REQUESTOR_ID = grantee_group.party_id(+)  ' ||
                            'AND child_table_name.REQUESTOR_ID IS NOT NULL  ' ||
                            'AND grantee_group.party_type = ''GROUP''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REQUESTOR'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name,  ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            '(  ' ||
                            'SELECT  ' ||
                                'C.CHANGE_ID,  ' ||
                                'P.ASSIGNEE_ID,  ' ||
                                'C.CREATION_DATE  ' ||
                            'FROM WF_ACTIVITIES WA,  ' ||
                                'WF_ACTIVITY_ATTRIBUTES WAA,  ' ||
                                'ENG_CHANGE_ROUTE_STEPS S,  ' ||
                                'ENG_CHANGE_ROUTE_PEOPLE P,  ' ||
                                'ENG_CHANGE_ROUTES R,  ' ||
                                'ENG_ENGINEERING_CHANGES C  ' ||
                            'WHERE WAA.TEXT_DEFAULT = ''ENG_CHANGE_WF_REVIEWERS''  ' ||
                                'AND WAA.NAME = ''DEFAULT_CHANGE_ROLE''  ' ||
                                'AND WAA.ACTIVITY_VERSION = WA.VERSION  ' ||
                                'AND WAA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE  ' ||
                                'AND WAA.ACTIVITY_NAME = WA.NAME  ' ||
                                'AND WA.TYPE = ''PROCESS''  ' ||
                                'AND WA.BEGIN_DATE <= SYSDATE  ' ||
                                'AND  ' ||
                                '( ' ||
                                '    WA.END_DATE >= SYSDATE  ' ||
                                '    OR WA.END_DATE IS NULL ' ||
                                ')  ' ||
                                'AND WA.ITEM_TYPE = S.WF_ITEM_TYPE  ' ||
                                'AND WA.NAME = S.WF_PROCESS_NAME  ' ||
                                'AND P.ASSIGNEE_ID <> -1  ' ||
                                'AND P.STEP_ID = S.STEP_ID  ' ||
                                'AND S.ROUTE_ID = R.ROUTE_ID  ' ||
                                'AND R.CLASSIFICATION_CODE = TO_CHAR(C.STATUS_CODE)  ' ||
                                'AND R.OBJECT_ID1 = C.CHANGE_ID  ' ||
                                'AND R.OBJECT_NAME = ''ENG_CHANGE''  ' ||
                                'AND R.TEMPLATE_FLAG = ''N''  ' ||
                            ')  ' ||
                            'child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.ASSIGNEE_ID  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REVIEWER'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '') grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            'ENG_CHANGE_LINES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.ASSIGNEE_ID  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF'' ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REVIEWER'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''GROUP'' grantee_type,  ' ||
                            'grantee_group.party_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES grantee_group,  ' ||
                            'ENG_CHANGE_LINES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = grantee_group.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND grantee_group.party_type = ''GROUP''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REVIEWER'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''USER'' grantee_type,  ' ||
                            'ltrim(nvl( hzei.party_name,nvl( hzci.party_name,nvl( hzsi.party_name,null))),''* '')  grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES hzei,  ' ||
                            'HZ_PARTIES hzci,  ' ||
                            'HZ_PARTIES hzsi,  ' ||
                            'HZ_RELATIONSHIPS hzr,  ' ||
                            'HZ_PARTIES hzc,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzei.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzci.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID = hzsi.party_id(+)  ' ||
                            'AND hzr.SUBJECT_ID(+) = child_table_name.ASSIGNEE_ID  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND hzei.party_type=''PERSON''  ' ||
                            'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF''  ' ||
                            'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID  ' ||
                            'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION''  ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REVIEWER'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                        'UNION  ' ||
                        'SELECT DISTINCT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''GROUP'' grantee_type,  ' ||
                            'grantee_group.party_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'HZ_PARTIES grantee_group,  ' ||
                            'ENG_ENGINEERING_CHANGES child_table_name  ' ||
                        'WHERE CHANGE_ID = ' || l_pk1_value || ' ' ||
                            'AND child_table_name.ASSIGNEE_ID = grantee_group.party_id(+)  ' ||
                            'AND child_table_name.ASSIGNEE_ID IS NOT NULL  ' ||
                            'AND grantee_group.party_type = ''GROUP'' ' ||
                            'AND granted_menu_data.menu_name = ''ENG_CHANGE_REVIEWER'' ' ||
                            'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  '; /* ||  --   Removed since There will be no roles for
                                                                                     --   COMPANY and ALL_USERS in DOM
                        'UNION  ' ||
                        'SELECT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''COMPANY'' grantee_type,  ' ||
                            'internal_company.company_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM hz_parties grantee_global,  ' ||
                            'fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus profile_menu_data,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'ego_obj_role_mappings mapping,  ' ||
                            'fnd_objects obj,  ' ||
                            'FND_PROFILE_OPTIONS profile,  ' ||
                            'FND_PROFILE_OPTION_VALUES profile_value,  ' ||
                            'EGO_INTERNAL_COMPANY_V internal_company  ' ||
                        'WHERE profile.profile_option_id = profile_value.profile_option_id  ' ||
                            'AND profile.profile_option_name in (''EGO_INTERNAL_USER_DEFAULT_ROLE'', ''ENG_INTERNAL_USER_DEFAULT_ROLE'')  ' ||
                            'AND obj.obj_name = ''EGO_ITEM''  ' ||
                            'AND grantee_global.party_id = -1000  ' ||
                            'AND mapping.parent_object_id = obj.object_id  ' ||
                            'AND profile_menu_data.menu_name = profile_value.profile_option_value  ' ||
                            'AND mapping.parent_role_id = profile_menu_data.menu_id  ' ||
                            'AND granted_menu.menu_id = mapping.child_role_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                            'AND granted_menu_data.menu_id = granted_menu.menu_id  ' ||
                            'AND EXISTS  ' ||
                            '(  ' ||
                            'SELECT  ' ||
                                'pk1_value,  ' ||
                                'pk2_value  ' ||
                            'FROM eng_change_subjects_v  ' ||
                            'WHERE  ' ||
                                '( ' ||
                                '    OBJECT_NAME=''EGO_ITEM''  ' ||
                                '    OR OBJECT_NAME=''EGO_ITEM_REVISION''  ' ||
                                ')  ' ||
                                'AND pk1_value is NOT NULL  ' ||
                                'AND change_id = ' || l_pk1_value || ' ' ||
                            ')  ' ||
                        'UNION  ' ||
                        'SELECT  ' ||
                            'granted_menu_data.menu_name role_name,  ' ||
                            'granted_menu.user_menu_name role_display_name,  ' ||
                            '''COMPANY'' grantee_type,  ' ||
                            'internal_company.company_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                        'FROM hz_parties grantee_global,  ' ||
                            'fnd_menus_tl granted_menu,  ' ||
                            'fnd_menus profile_menu_data,  ' ||
                            'fnd_menus granted_menu_data,  ' ||
                            'fnd_objects obj,  ' ||
                            'FND_PROFILE_OPTIONS profile,  ' ||
                            'FND_PROFILE_OPTION_VALUES profile_value,  ' ||
                            'EGO_INTERNAL_COMPANY_V internal_company  ' ||
                        'WHERE profile.profile_option_id = profile_value.profile_option_id  ' ||
                            'AND profile.profile_option_name in (''EGO_INTERNAL_USER_DEFAULT_ROLE'', ''ENG_INTERNAL_USER_DEFAULT_ROLE'')  ' ||
                            'AND obj.obj_name = ''ENG_CHANGE''  ' ||
                            'AND obj.APPLICATION_ID = profile.APPLICATION_ID  ' ||
                            'AND grantee_global.party_id = -1000  ' ||
                            'AND profile_menu_data.menu_name = profile_value.profile_option_value  ' ||
                            'AND granted_menu.menu_id = profile_menu_data.menu_id  ' ||
                            'AND ' ||
                            '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                            ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                            ')) ' ||
                            'AND granted_menu.language= userenv(''LANG'')  ' ||
                            'AND granted_menu_data.menu_id = granted_menu.menu_id ' ;     */

--dbms_output.put_line('** sameer ** Prepared SQL ot get the inherited Change Roles....');

     IF l_change_has_items = TRUE THEN  --   If there are any items in subjects or Revised items only then get these roles

         -----Get the Instance set Ids for the Item for all 'PERSON's.
         Get_Valid_Instance_Set_Ids
         (
               p_obj_name => 'EGO_ITEM' ,
               p_grantee_type => 'USER' ,
               p_parent_obj_sql => null ,
               p_bind1 => null ,
               p_bind2 => null ,
               p_bind3 => null ,
               p_bind4 => null ,
               p_bind5 => null ,
               p_obj_ids => l_obj_ids ,
               x_inst_set_ids => l_inst_set_ids
         );

--dbms_output.put_line('** sameer ** Instance set Ids for Inherited Persons : ' || l_inst_set_ids);

         IF( length(l_inst_set_ids) > 0) THEN        --      'PERSON's
                     query_to_exec := query_to_exec || ' UNION ' ||
                             'SELECT ' ||
                                 'granted_menu_data.menu_name internal_role_name, ' ||
                                 'granted_menu.user_menu_name role_name, ' ||
                                 'grants.grantee_type grantee_type, ' ||
                                 'hzsi.party_name grantee_name, ' ||
                            'granted_menu_data.menu_id menu_id ' ||
                             'FROM fnd_grants grants, ' ||
                                 'HZ_PARTIES hzsi, ' ||
                                 'HZ_RELATIONSHIPS hzr, ' ||
                                 'HZ_PARTIES hzc, ' ||
                                 'fnd_menus_tl granted_menu, ' ||
                                 'fnd_menus granted_menu_data, ' ||
                                 'ego_obj_role_mappings mapping, ' ||
                                 'fnd_objects obj,' ||
                                 'eng_engineering_changes changes,' ||
                                 'eng_change_subjects subjects,' ||
                                 'eng_revised_items rev_items ' ||
                             'WHERE grants.grantee_type = ''USER'' ' ||
                                 'AND grants.object_id = obj.object_id ' ||
                                 'AND mapping.parent_object_id = grants.object_id ' ||
                                 'AND mapping.parent_role_id = grants.menu_id ' ||
                                 'AND SUBSTR(grants.grantee_key, 1, INSTR(grants.grantee_key, '':'')-1) =''HZ_PARTY'' ' ||
                                 'AND TO_NUMBER(REPLACE(grants.grantee_key,''HZ_PARTY:'','''')) = hzsi.party_id(+) ' ||
                                 'AND hzsi.party_type=''PERSON'' ' ||
                                 'AND hzr.SUBJECT_ID(+) = TO_NUMBER(REPLACE(grants.grantee_key,''HZ_PARTY:'','''')) ' ||
                                 'AND hzr.RELATIONSHIP_CODE(+) = ''EMPLOYEE_OF'' ' ||
                                 'AND hzc.PARTY_ID(+) = hzr.OBJECT_ID ' ||
                                 'AND hzc.PARTY_TYPE(+) = ''ORGANIZATION'' ' ||
                                 'AND NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)' ||
                                 'AND granted_menu.menu_id = mapping.child_role_id ' ||
                                 'AND ' ||
                                 '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                                 ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                                 ')) ' ||
                                 'AND granted_menu.LANGUAGE= USERENV(''LANG'') ' ||
                                 'AND granted_menu.menu_id = granted_menu_data.menu_id ' ||
                                 'AND grants.instance_type = ''SET'' ' ||
                                 'AND ' ||
                                 '( (  obj.obj_name = ''EGO_ITEM'' ' ||
                                 '   AND ( grants.instance_set_id in (' ||  l_inst_set_ids  || ')' ||
                                 '       ) ' ||
                                 ')) ' ||
                                 'AND changes.change_id = ' || l_pk1_value || ' ' ||
                                 'AND (( changes.change_id = subjects.change_id AND subjects.pk1_value IS NOT NULL ) ' ||
                                 '                   OR ( changes.change_id = REV_ITEMS.change_id )) ' ;

         END IF;
         ---------End of Instance set Ids for the Item for all 'PERSON's.

         -----Get the Instance set Ids for the Item for all 'GROUPS's.
         Get_Valid_Instance_Set_Ids
         (
               p_obj_name => 'EGO_ITEM' ,
               p_grantee_type => 'GROUP' ,
               p_parent_obj_sql => null ,
               p_bind1 => null ,
               p_bind2 => null ,
               p_bind3 => null ,
               p_bind4 => null ,
               p_bind5 => null ,
               p_obj_ids => l_obj_ids ,
               x_inst_set_ids => l_inst_set_ids
         );

--dbms_output.put_line('** sameer ** Instance set Ids for Inherited Groups : ' || l_inst_set_ids);

         IF( length(l_inst_set_ids) > 0) THEN        --      'COMPANY's
                     query_to_exec := query_to_exec || ' UNION ' ||
                             'SELECT ' ||
                                 'granted_menu_data.menu_name internal_role_name,  ' ||
                                 'granted_menu.user_menu_name role_name,  ' ||
                                 'grants.grantee_type grantee_type,  ' ||
                                 'grantee_group.party_name grantee_name, ' ||
                                 'granted_menu_data.menu_id menu_id ' ||
                             'FROM fnd_grants grants,  ' ||
                                 'HZ_PARTIES grantee_group, ' ||
                                 'fnd_menus_tl granted_menu,  ' ||
                                 'fnd_menus granted_menu_data,  ' ||
                                 'ego_obj_role_mappings mapping,  ' ||
                                 'fnd_objects obj , ' ||
                                 'eng_engineering_changes changes, ' ||
                                 'eng_change_subjects subjects, ' ||
                                 'eng_revised_ITEMS REV_ITEMS ' ||
                             'WHERE grants.grantee_type = ''GROUP''  ' ||
                                 'AND grants.object_id = obj.object_id  ' ||
                                 'AND mapping.parent_object_id = grants.object_id  ' ||
                                 'AND mapping.parent_role_id = grants.menu_id  ' ||
                                 'AND grantee_group.party_type = ''GROUP'' ' ||
                                 'AND SUBSTR(grants.grantee_key, 1, INSTR(grants.grantee_key, '':'')-1) =''HZ_GROUP''  ' ||
                                 'AND NVL(grants.end_date, SYSDATE+1) >= TRUNC(SYSDATE)  ' ||
                                 'AND TO_NUMBER(REPLACE(grants.grantee_key,''HZ_GROUP:'','''')) = grantee_group.party_id  ' ||
                                 'AND granted_menu.menu_id = mapping.child_role_id  ' ||
                                 'AND ' ||
                                 '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                                 ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                                 ')) ' ||
                                 'AND granted_menu.LANGUAGE= USERENV(''LANG'')  ' ||
                                 'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                                 'AND grants.instance_type = ''SET''  ' ||
                                 'AND  ' ||
                                 '( ( obj.obj_name = ''EGO_ITEM'' AND  ' ||
                                 '         grants.instance_set_id in ( ' ||  l_inst_set_ids  || ' ) ' ||
                                 ') ) ' ||
                                 'AND changes.change_id = ' || l_pk1_value ||  ' ' ||
                                 'AND (( changes.change_id = subjects.change_id AND subjects.pk1_value IS NOT NULL ) ' ||
                                 '                   OR ( changes.change_id = REV_ITEMS.change_id )) ';
         END IF;
         ---------End of Instance set Ids for the Item for all 'GROUP's.

/*
         -----Get the Instance set Ids for the Item for all 'COMPANY's.
         Get_Valid_Instance_Set_Ids
         (
               p_obj_name => 'EGO_ITEM' ,
               p_grantee_type => 'COMPANY' ,
               p_parent_obj_sql => null ,
               p_bind1 => null ,
               p_bind2 => null ,
               p_bind3 => null ,
               p_bind4 => null ,
               p_bind5 => null ,
               p_obj_ids => l_obj_ids ,
               x_inst_set_ids => l_inst_set_ids
         );

--dbms_output.put_line('** sameer ** Instance set Ids for Inherited Companys : ' || l_inst_set_ids);

         IF( length(l_inst_set_ids) > 0) THEN        --      'COMPANY's
                     query_to_exec := query_to_exec || ' UNION ' ||
                             'SELECT  ' ||
                                 'granted_menu_data.menu_name internal_role_name,  ' ||
                                 'granted_menu.user_menu_name role_name,  ' ||
                                 'grants.grantee_type grantee_type, ' ||
                                 'grantee_company.party_name grantee_name, ' ||
                                 'granted_menu_data.menu_id menu_id ' ||
                             'FROM fnd_grants grants,  ' ||
                                 'hz_parties grantee_company,  ' ||
                                 'fnd_menus_tl granted_menu,  ' ||
                                 'fnd_menus granted_menu_data,  ' ||
                                 'ego_obj_role_mappings mapping,  ' ||
                                 'fnd_objects obj, ' ||
                                 'eng_engineering_changes changes, ' ||
                                 'eng_change_subjects subjects, ' ||
                                 'eng_revised_items rev_items ' ||
                             'WHERE grants.grantee_type = ''COMPANY''  ' ||
                                 'AND grants.object_id = obj.object_id  ' ||
                                 'AND grantee_company.party_type = ''ORGANIZATION''  ' ||
                                 'AND mapping.parent_object_id = grants.object_id  ' ||
                                 'AND mapping.parent_role_id = grants.menu_id  ' ||
                                 'AND to_number(replace(grants.grantee_key,''HZ_COMPANY:'','''')) = grantee_company.party_id  ' ||
                                 'AND substr(grants.grantee_key, 1, instr(grants.grantee_key, '':'')-1) =''HZ_COMPANY''  ' ||
                                 'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)  ' ||
                                 'AND granted_menu.menu_id = mapping.child_role_id  ' ||
                                 'AND ' ||
                                 '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                                 ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                                 ')) ' ||
                                 'AND granted_menu.language= userenv(''LANG'')  ' ||
                                 'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                                 'AND grants.instance_type = ''SET'' ' ||
                                 'AND  ' ||
                                 '( ( obj.obj_name = ''EGO_ITEM''  ' ||
                                 '         AND ( grants.instance_set_id in ( ' || l_inst_set_ids  || ' ) )'  ||
                                 ') ) '  ||
                                 'AND changes.change_id =  ' || l_pk1_value || ' ' ||
                                 'AND (( changes.change_id = subjects.change_id AND subjects.pk1_value IS NOT NULL ) ' ||
                                 '                   OR ( changes.change_id = REV_ITEMS.change_id ))';


         END IF;
         ---------End of Instance set Ids for the Item for all 'COMPANY's.
*/

/*
         -----Get the Instance set Ids for the Item for all 'GLOBAL's.
         Get_Valid_Instance_Set_Ids
         (
               p_obj_name => 'EGO_ITEM' ,
               p_grantee_type => 'GLOBAL' ,
               p_parent_obj_sql => null ,
               p_bind1 => null ,
               p_bind2 => null ,
               p_bind3 => null ,
               p_bind4 => null ,
               p_bind5 => null ,
               p_obj_ids => l_obj_ids ,
               x_inst_set_ids => l_inst_set_ids
         );

--dbms_output.put_line('** sameer ** Instance set Ids for Inherited All users : ' || l_inst_set_ids);

         IF( length(l_inst_set_ids) > 0) THEN        --      'GLOBAL's
                     query_to_exec := query_to_exec || ' UNION ' ||
                             'SELECT ' ||
                                 'granted_menu_data.menu_name internal_role_name,  ' ||
                                 'granted_menu.user_menu_name role_name,  ' ||
                                 'grants.grantee_type grantee_type, ' ||
                                 'grantee_global.party_name grantee_name, ' ||
                                 'granted_menu_data.menu_id menu_id ' ||
                             'FROM fnd_grants grants,  ' ||
                                 'hz_parties grantee_global,  ' ||
                                 'fnd_menus_tl granted_menu,  ' ||
                                 'fnd_menus granted_menu_data,  ' ||
                                 'ego_obj_role_mappings mapping,  ' ||
                                 'fnd_objects obj,  ' ||
                                 'eng_engineering_changes changes, ' ||
                                 'eng_change_subjects subjects, ' ||
                                 'eng_revised_items rev_items ' ||
                             'WHERE grants.grantee_type = ''GLOBAL''  ' ||
                                 'AND grants.object_id = obj.object_id  ' ||
                                 'AND mapping.parent_object_id = grants.object_id  ' ||
                                 'AND mapping.parent_role_id = grants.menu_id  ' ||
                                 'AND grantee_global.party_type = ''GLOBAL''  ' ||
                                 'AND grantee_global.party_id = -1000  ' ||
                                 'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)  ' ||
                                 'AND granted_menu.menu_id = mapping.child_role_id  ' ||
                                 'AND ' ||
                                 '((  ''' || p_role_name || ''' is null AND granted_menu_data.menu_name like ''%'' ' ||
                                 ' )      OR ( granted_menu_data.MENU_NAME in ( ''' || p_role_name || ''' ) ' ||
                                 ')) ' ||
                                 'AND granted_menu.language= userenv(''LANG'')  ' ||
                                 'AND granted_menu.menu_id = granted_menu_data.menu_id  ' ||
                                 'AND grants.instance_type = ''SET''  ' ||
                                 'AND  ' ||
                                 '( (  ' ||
                                 '      obj.obj_name = ''EGO_ITEM'' AND  ' ||
                                 '       ( grants.instance_set_id in (' ||  l_inst_set_ids  || ' ) ' ||
                                 '       )  ' ||
                                 ') )  ' ||
                                 'AND changes.change_id =  ' || l_pk1_value || ' ' ||
                                 'AND (( changes.change_id = subjects.change_id AND subjects.pk1_value IS NOT NULL ) ' ||
                                 '                   OR ( changes.change_id = REV_ITEMS.change_id )) ';
         END IF;
         ---------End of Instance set Ids for the Item for all 'GLOBAL's.
*/

     END IF;   --   If there are any items in subjects or Revised items only then get these roles

l_index := 0;
--dbms_output.put_line('** sameer ** trying to execute the dynamic SQL for fetching the Inherited roles ... starting l_index from : ' || l_index);
                cursor_select := DBMS_SQL.OPEN_CURSOR;
--dbms_output.put_line('** sameer ** opened implicit cursor');
--dbms_output.put_line('** sameer ** query is as follows ....');

--dbms_output.put_line(query_to_exec);
--p(query_to_exec);
--utl_file_test_write('/home/sdarbha/Enhancements/Sep12', 'querytolog.txt', query_to_exec );
                DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
--dbms_output.put_line('** sameer ** parsed implicit cursor');

--dbms_output.put_line('** sameer ** defining columns ......');

                 dbms_sql.DEFINE_COLUMN(cursor_select, 1, '', 30);
                 dbms_sql.DEFINE_COLUMN(cursor_select, 2, '', 120);
                 dbms_sql.DEFINE_COLUMN(cursor_select, 3, '', 30);
                 dbms_sql.DEFINE_COLUMN(cursor_select, 4, '', 120);
                 dbms_sql.DEFINE_COLUMN(cursor_select, 5, l_temp_menu_id);

--dbms_output.put_line('** sameer ** defined columns ......');

                cursor_execute := DBMS_SQL.EXECUTE(cursor_select);

                LOOP
                     IF dbms_sql.fetch_rows(cursor_select) > 0 THEN
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 1, l_grantee_list(l_index).role_name);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 2, l_grantee_list(l_index).role_display_name);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 3, l_grantee_list(l_index).grantee_type);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 4, l_grantee_list(l_index).grantee_name);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 5, l_temp_menu_id);

                             Get_Default_Access(p_menu_id => l_temp_menu_id,
                                                p_default_access => l_default_access
                                                );
                             l_grantee_list(l_index).default_access := l_default_access;

                             l_index:=l_index+1;
                     ELSE
                            EXIT;
                     END IF;
                END LOOP;

            IF( l_grantee_list.count>0) THEN
                x_grantee_names.extend(l_grantee_list.count);
                x_grantee_types.extend(l_grantee_list.count);
                x_role_names.extend(l_grantee_list.count);
                x_role_display_names.extend(l_grantee_list.count);
                x_default_access.extend(l_grantee_list.count);
/*
dbms_output.put_line('** sameer ** continuing to add to the return list from .. : ' || l_grantee_list.count  || ' **** ' || l_index);
dbms_output.put_line('** sameer ** all_roles_count .. : ' || all_roles_count  );
dbms_output.put_line('** sameer ** l_grantee_list.first and l_grantee_list.last .. : ' || l_grantee_list.first || ' <> ' || l_grantee_list.last  );
*/
                FOR i in l_grantee_list.first .. l_grantee_list.last LOOP
                        all_roles_count := all_roles_count + 1;

                        x_grantee_names(all_roles_count):=l_grantee_list(i).grantee_name;
                        x_grantee_types(all_roles_count):=l_grantee_list(i).grantee_type;
                        x_role_names(all_roles_count):=l_grantee_list(i).role_name;
                        x_role_display_names(all_roles_count):=l_grantee_list(i).role_display_name;
                        x_default_access(all_roles_count):=l_grantee_list(i).default_access;
                END LOOP;
            END IF;

        DBMS_SQL.CLOSE_CURSOR(cursor_select);

--dbms_output.put_line('** sameer ** completed successfully all inherited and direct roles on change.' );

  END Get_Change_Users;

----------------------------------------------------------------------
 PROCEDURE Get_Valid_Instance_Set_Ids
 (
        p_obj_name IN VARCHAR2,
        p_grantee_type IN VARCHAR2,
        p_parent_obj_sql IN VARCHAR2,
        p_bind1 IN VARCHAR2,
        p_bind2 IN VARCHAR2,
        p_bind3 IN VARCHAR2,
        p_bind4 IN VARCHAR2,
        p_bind5 IN VARCHAR2,
        p_obj_ids IN VARCHAR2,
        x_inst_set_ids OUT NOCOPY VARCHAR2
 )
 IS
 CURSOR inst_set_preds IS
 SELECT DISTINCT
    sets.instance_set_id instance_set_id ,
    sets.instance_set_name instance_set_name,
    sets.predicate predicate
 FROM fnd_grants grants,
    fnd_object_instance_sets sets,
    fnd_objects obj
 WHERE obj.obj_name = p_obj_name
    AND grants.object_id = obj.object_id
    AND grants.instance_type='SET'
    AND grants.parameter1 is null
    AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate)
    AND grants.grantee_type = p_grantee_type
    AND sets.instance_set_id = grants.instance_set_id
 ORDER BY instance_set_name;

 CURSOR obj_meta_data IS
 SELECT
    DATABASE_OBJECT_NAME,
    PK1_COLUMN_NAME,
    PK2_COLUMN_NAME,
    PK3_COLUMN_NAME,
    PK4_COLUMN_NAME,
    PK5_COLUMN_NAME
 FROM fnd_objects
 WHERE OBJ_NAME = p_obj_name;

 obj_meta_data_rec obj_meta_data%ROWTYPE;
 i              NUMBER := 1;
 query_to_exec  VARCHAR2(32767);
 obj_std_pkq    VARCHAR2(32767);
 prim_key_str   VARCHAR2(32767);
 inst_set_ids   VARCHAR2(32767);
 cursor_select  NUMBER;
 cursor_execute NUMBER;
 BEGIN
 OPEN obj_meta_data;
 FETCH obj_meta_data INTO obj_meta_data_rec;
        obj_std_pkq := 'SELECT ' || obj_meta_data_rec.PK1_COLUMN_NAME;
        prim_key_str := obj_meta_data_rec.PK1_COLUMN_NAME;
        IF obj_meta_data_rec.PK2_COLUMN_NAME IS NOT NULL THEN
                obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK2_COLUMN_NAME;
                prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK2_COLUMN_NAME;
        END IF;
        IF obj_meta_data_rec.PK3_COLUMN_NAME IS NOT NULL THEN
                obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK3_COLUMN_NAME;
                prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK3_COLUMN_NAME;
        END IF;
        IF obj_meta_data_rec.PK4_COLUMN_NAME IS NOT NULL THEN
                obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK4_COLUMN_NAME;
                prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK4_COLUMN_NAME;
        END IF;
        IF obj_meta_data_rec.PK5_COLUMN_NAME IS NOT NULL THEN
                obj_std_pkq := obj_std_pkq || ' , ' || obj_meta_data_rec.PK5_COLUMN_NAME;
                prim_key_str := prim_key_str || ' , ' || obj_meta_data_rec.PK5_COLUMN_NAME;
        END IF;
        obj_std_pkq := obj_std_pkq || ' FROM ' || obj_meta_data_rec.DATABASE_OBJECT_NAME;
 CLOSE obj_meta_data;
--dbms_output.put_line('** sameer ** Get_Valid_Instance_Set_Ids ... inst_set_preds_rec for loop staring');

 FOR inst_set_preds_rec IN inst_set_preds
 LOOP
--dbms_output.put_line('** sameer ** ... inst_set_preds_rec inside for loop : =>' || p_obj_ids);
        IF p_obj_ids IS NOT NULL THEN
                query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
                query_to_exec := query_to_exec || ' WHERE ' || inst_set_preds_rec.predicate || ' )';
        ELSIF p_parent_obj_sql IS NOT NULL THEN
                query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
                query_to_exec := query_to_exec || inst_set_preds_rec.predicate || ' AND (';
                query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
        END IF;
--dbms_output.put_line('** sameer ** end if ...>>>>: ');
--p(query_to_exec);
        cursor_select := DBMS_SQL.OPEN_CURSOR;
--dbms_output.put_line('** sameer **  DBMS_SQL.OPEN_CURSOR ');
        DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
--dbms_output.put_line('** sameer ** Get_Valid_Instance_Set_Ids ... parsed  .: ');
        IF p_bind1 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id1', p_bind1);
--dbms_output.put_line('** sameer ** binded id1 ... ');
        END IF;
        IF p_bind2 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id2', p_bind2);
        END IF;
        IF p_bind3 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id3', p_bind3);
        END IF;
        IF p_bind4 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id4', p_bind4);
        END IF;
        IF p_bind5 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id5', p_bind5);
        END IF;

        cursor_execute := DBMS_SQL.EXECUTE(cursor_select);
        IF DBMS_SQL.FETCH_ROWS(cursor_select) > 0 THEN
                IF i = 1 THEN
                        inst_set_ids := to_char(inst_set_preds_rec.instance_set_id);
                        i := 2;
                ELSE
                        inst_set_ids := inst_set_ids || ',' || inst_set_preds_rec.instance_set_id;
                END IF;
        END IF;
        DBMS_SQL.CLOSE_CURSOR(cursor_select);
 END LOOP;
        IF inst_set_ids IS NOT NULL THEN
                x_inst_set_ids := inst_set_ids;  /**** list of valid inst_set_ids ****/
        ELSE
                x_inst_set_ids := '-1';
        END IF;
END Get_Valid_Instance_Set_Ids;
----------------------------------------------------------

END ENG_CHANGE_ROLES_PUB;


/

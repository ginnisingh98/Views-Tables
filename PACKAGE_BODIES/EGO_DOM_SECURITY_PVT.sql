--------------------------------------------------------
--  DDL for Package Body EGO_DOM_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DOM_SECURITY_PVT" AS
/* $Header: EGODMSCB.pls 120.10 2006/10/30 17:40:26 ysireesh noship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to reslove docuemnt security                   |
 | based on data security                                                    |
 +---------------------------------------------------------------------------*/

  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'EGO_DOM_SECURITY_PVT';

  --Private - print_debug_msg
  ---------------------------
  PROCEDURE print_debug_msg
  (
   p_msg      IN VARCHAR2,
   p_debug    BOOLEAN DEFAULT true
  )
  IS
    l_count        NUMBER;
    l_bufsize      NUMBER:=1;
    l_substr       VARCHAR2(1000);
  BEGIN
    IF( NOT p_debug) THEN
        RETURN ;
    END IF;
    IF( length(p_msg) <= 200) THEN
       RETURN;
    END IF;
    WHILE( l_bufsize<=length(p_msg)) LOOP
          l_substr := substr(p_msg,l_bufsize,200);
          l_bufsize := l_bufsize+200;
    END LOOP;
  END print_debug_msg;

  -------------------------------------------------------------------------
  --1. Get Users
  ----------------------------------------------------
  PROCEDURE Get_Users
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
  IS
    -- Start OF comments
    -- API name  : Get Users
    -- Type      : Public
    -- Pre-reqs  : None
    -- Function  : Gets list of users who has some role on business object.
    --             If no role is passed i.e if p_role_name is null
    --             then the API returns list of roles available on the item
    --             with the set of users who bear each role.
    --             If some role is mentioned, then the list of user who bear
    --             this role on the item are displayed.
    -- IN        :      p_api_version               IN  NUMBER         Required
    --                  p_entity_name               IN  VARCHAR2       Required
    --                  p_pk1_value                 IN  VARCHAR2       Required
    --                  p_pk2_value                 IN  VARCHAR2       Required
    --                  p_pk3_value                 IN  VARCHAR2
    --                  p_pk4_value                 IN  VARCHAR2
    --                  p_pk5_value                 IN  VARCHAR2
    --                  p_role_name                 IN  VARCHAR2
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  l_entity_name         VARCHAR2(30);
  l_pk1_value           VARCHAR2(50);
  l_pk2_value           VARCHAR2(50);
  l_pk3_value           VARCHAR2(50) := '';
  l_pk4_value           VARCHAR2(50);
  l_pk5_value           VARCHAR2(50);
  l_obj_ids             VARCHAR2(32767);
  q1             VARCHAR2(32767);
  q2             VARCHAR2(32767);
  l_role_name	        VARCHAR2(50);
  l_role_name_temp	        VARCHAR2(50);
  l_temp_menu_id        NUMBER;
  l_index               NUMBER:=0;
  memcount              NUMBER:=0;

  /*
  CURSOR get_object_id (cp_entity_name  VARCHAR2)
   IS
   SELECT object_id
   FROM
   FND_OBJECTS
   WHERE obj_name = cp_entity_name;
   */


  CURSOR get_explicit_grant_users (cp_entity_name  VARCHAR2,
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
                GRANTS.grantee_key grantee_key,
                menus.Menu_name role_name,
                menus.user_menu_name role_display_name,
                menus.menu_id menu_id
                FROM fnd_grants GRANTS,
                fnd_objects OBJECTS,
                fnd_menus_vl MENUS
                WHERE OBJECTS.object_id = GRANTS.object_id
                AND OBJECTS.obj_name=cp_entity_name
                AND GRANTS.instance_type='INSTANCE'
                AND GRANTS.instance_pk1_value=cp_pk1_value
                AND
                (
                        (
                        grants.instance_pk2_value = cp_pk2_value
                        )
                        OR
                        (
                        (
                                grants.instance_pk2_value = '*NULL*'
                        )
                        AND
                        (
                                cp_pk2_value is NULL
                        )
                        )
                )
                AND
                (
                        (
                        grants.instance_pk3_value = cp_pk3_value
                        )
                        OR
                        (
                        (
                                grants.instance_pk3_value = '*NULL*'
                        )
                        AND
                        (
                                cp_pk3_value is NULL
                        )
                        )
                )
                AND
                (
                        (
                        grants.instance_pk4_value = cp_pk4_value
                        )
                        OR
                        (
                        (
                                grants.instance_pk4_value = '*NULL*'
                        )
                        AND
                        (
                                cp_pk4_value is NULL
                        )
                        )
                )
                AND
                (
                        (
                        grants.instance_pk5_value = cp_pk5_value
                        )
                        OR
                        (
                        (
                                grants.instance_pk5_value = '*NULL*'
                        )
                        AND
                        (
                                cp_pk5_value is NULL
                        )
                        )
                )
                AND GRANTS.menu_id = MENUS.menu_id
                AND
                (
                        (
                        cp_role_name is null
                        AND menus.menu_name like '%'
                        )
                        OR
                        (
                        MENUS.MENU_NAME in (cp_role_name)
                        )
                )
                AND GRANTS.start_date <= sysdate
                AND
                (
                        GRANTS.end_date is null
                        OR grants.end_date >= SYSDATE
                )
                )
                grants
        WHERE grantee_type in ('USER','GROUP') --,'COMPANY','GLOBAL')
                AND grantee_orig_system in ('HZ_PARTY','HZ_GROUP')   --,'HZ_COMPANY', 'HZ_GLOBAL')
                AND parties.party_id=DECODE(grants.grantee_key,'GLOBAL',-1000, SUBSTR(grants.grantee_key, INSTR(grants.grantee_key,':',1,1)+1));
   l_grantee_list	GRANTEES_TBL_TYPE;
   l_inst_set_ids	VARCHAR2(32767);
   l_default_access     VARCHAR2(50);
   i			NUMBER := 1;
   query_to_exec	VARCHAR2(32767);
   cursor_select	NUMBER;
   cursor_execute	NUMBER;
   ret			INTEGER;
   l_object_id		NUMBER;
  BEGIN
    x_return_status:='T';
    l_entity_name:=p_entity_name;
    l_pk1_value:=p_pk1_value;
    l_pk2_value:=p_pk2_value;
    l_pk3_value:='';
    l_pk4_value:=p_pk4_value;
    l_pk5_value:=p_pk5_value;
    l_role_name:=p_role_name;
    l_default_access:='Discoverer';
    l_index:=0;

    IF( p_entity_name ='MTL_SYSTEM_ITEMS' OR p_entity_name ='MTL_ITEM_REVISIONS') THEN
       l_entity_name:='EGO_ITEM';
       l_pk1_value:=p_pk2_value;
       l_pk2_value:=p_pk1_value;
       l_obj_ids := l_pk1_value || ',' || l_pk2_value;
    END IF;

 --OPEN get_object_id;
 --FETCH get_object_id INTO l_object_id;
 --CLOSE get_object_id;

    FOR rec IN get_explicit_grant_users(
                                        l_entity_name,
                                        l_pk1_value,
                                        l_pk2_value,
                                        l_pk3_value,
                                        l_pk4_value,
                                        l_pk5_value,
                                        p_role_name)
     LOOP
       l_grantee_list(l_index).grantee_name:=rec.grantee_name;
       l_grantee_list(l_index).grantee_type:=rec.grantee_type;
       l_grantee_list(l_index).role_name:=rec.role_name;
       l_grantee_list(l_index).role_display_name:=rec.role_display_name;
       l_temp_menu_id := rec.menu_id;
       l_default_access:=Get_Default_Access(p_menu_id => l_temp_menu_id);
       l_grantee_list(l_index).default_access:=l_default_access;

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
        x_grantee_names(memcount+1):=l_grantee_list(i).grantee_name;
        x_grantee_types(memcount+1):=l_grantee_list(i).grantee_type;
        x_role_names(memcount+1):=l_grantee_list(i).role_name;
        x_role_display_names(memcount+1):=l_grantee_list(i).role_display_name;
        x_default_access(memcount+1):=l_grantee_list(i).default_access;
        memcount := memcount + 1;
      END LOOP;
    END IF;

    /*********************************************************************************************/

    GET_VALID_INSTANCE_SET_IDS
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

     IF( length(l_inst_set_ids) > 0) THEN
	 l_role_name_temp := '''' || l_role_name || '''';

         query_to_exec :=
                   'SELECT ' ||
                    'ltrim(grantee_person.party_name,''* '') grantee_name, ' ||
                    ' grantee_type grantee_type, ' ||
                    'granted_menu_data.menu_name role_name, ' ||
                    'granted_menu.user_menu_name role_display_name, ' ||
                    'granted_menu_data.menu_id menu_id, ' ||
		    'grantee_person.party_id party_id, '  ||
                    'grantee_person_company.party_id company_id, ' ||
                    'grantee_person_company.party_name company_name, ' ||
                    'trunc(grants.start_date) start_date , ' ||
                    'trunc(grants.end_date) end_date ' ||
                'FROM fnd_grants grants, ' ||
                    'hz_parties grantee_person, ' ||
                    'hz_parties grantee_person_company, ' ||
                    'hz_relationships grantee_person_company_rel, ' ||
                    'fnd_menus_tl granted_menu, ' ||
                    'fnd_menus granted_menu_data, ' ||
                    'fnd_objects obj ' ||
                'WHERE grants.object_id = obj.object_id ' ||
                    'AND grants.grantee_type = ''USER'' ' ||
                    'AND grantee_person.status = ''A'' ' ||
                    'AND grantee_person.party_type = ''PERSON'' ' ||
                    'AND grantee_person_company_rel.subject_type (+) = ''PERSON'' ' ||
                    'AND grantee_person_company_rel.subject_table_name (+) = ''HZ_PARTIES'' ' ||
                    'AND grantee_person_company_rel.object_table_name (+) = ''HZ_PARTIES'' ' ||
                    'AND grantee_person.party_id (+) = grantee_person_company_rel.subject_id ' ||
                    'AND grantee_person_company_rel.relationship_code(+) = ''EMPLOYEE_OF'' ' ||
                    'AND grantee_person_company_rel.status(+) = ''A'' ' ||
                    'AND grantee_person_company_rel.start_date(+) <= SYSDATE ' ||
                    'AND NVL(grantee_person_company_rel.end_date(+), SYSDATE+1) >= SYSDATE ' ||
                    'AND grantee_person_company.party_id (+) = grantee_person_company_rel.object_id ' ||
                    'AND grantee_person.party_id (+) = grantee_person_company_rel.subject_id ' ||
                    'AND grantee_person_company.status(+) = ''A'' ' ||
                    'AND grantee_person_company_rel.object_type(+) = ''ORGANIZATION'' ' ||
                    'AND grants.grantee_key like ''HZ_PARTY:%'' ' ||
                    'AND to_number(replace(grants.grantee_key,''HZ_PARTY:'','''')) = grantee_person.party_id ' ||
                    'AND substr(grants.grantee_key, 1, instr(grants.grantee_key, '':'')-1) =''HZ_PARTY'' ' ||
                    'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate) ' ||
                    'AND granted_menu.menu_id = grants.menu_id ' ||
                    'AND granted_menu.language= userenv(''LANG'') ' ||
                    'AND granted_menu.menu_id = granted_menu_data.menu_id ' ||
		    'AND ' ||
		    '( ' ||
			'( ' ||
   			     ':1 is null ' ||
			     'AND granted_menu_data.menu_name like ''%'' ' ||
			') ' ||
			'OR ' ||
			'( ' ||
			     'granted_menu_data.MENU_NAME in (:2) ' ||
			') ' ||
		    ') ' ||
                    'AND grants.instance_type=''SET'' ' ||
                    'AND ' ||
                    '( ' ||
                        'obj.obj_name =''EGO_ITEM'' ' ||
                        'AND ' ||
                        '( ' ||
                         '   grants.instance_set_id in ( :3 ) ' ||
                        ') ' ||
                    ') ' ;
      END IF;
    /*********************************************************************************************/

     GET_VALID_INSTANCE_SET_IDS
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
     IF( length(l_inst_set_ids) > 0) THEN

        query_to_exec := query_to_exec || 'UNION ' ||
                'SELECT ' ||
                    'grantee_group.party_name grantee_name, ' ||
                    'grantee_type grantee_type, ' ||
                    'granted_menu_data.menu_name role_name, ' ||
                    'granted_menu.user_menu_name role_display_name, ' ||
                    'granted_menu_data.menu_id menu_id, ' ||
                    'grantee_group.party_id party_id, ' ||
                    '-1 company_id, ' ||
                    'null company_name, ' ||
                    'trunc(grants.start_date) start_date , ' ||
                    'trunc(grants.end_date) end_date ' ||
                'FROM fnd_grants grants, ' ||
                    'hz_parties grantee_group, ' ||
                    'fnd_menus_tl granted_menu, ' ||
                    'fnd_menus granted_menu_data, ' ||
                    'fnd_objects obj ' ||
                'WHERE grants.object_id = obj.object_id ' ||
                    'AND grants.grantee_type = ''GROUP'' ' ||
                    'AND grants.grantee_key like ''HZ_GROUP:%'' ' ||
                    'AND grantee_group.party_type = ''GROUP'' ' ||
                    'AND grantee_group.status = ''A'' ' ||
                    'AND ' ||
                    '( ' ||
                        'grantee_group.party_id = -1000 ' ||
                        'OR EXISTS ' ||
                        '( ' ||
                        'SELECT ' ||
                        '    ''X'' ' ||
                        'FROM fnd_grants f, ' ||
                            'fnd_menus m, ' ||
                            'fnd_objects o ' ||
                        'WHERE f.instance_pk1_value = to_char(grantee_group.party_id) ' ||
                            'AND f.start_date <= SYSDATE ' ||
                            'AND NVL(f.end_date, SYSDATE+1) >= SYSDATE ' ||
                            'AND f.menu_id = m.menu_id ' ||
                            'AND m.menu_name = ''EGO_MANAGE_GROUP'' ' ||
                            'AND f.object_id = o.object_id ' ||
                            'AND o.obj_name = ''EGO_GROUP'' ' ||
                        ') ' ||
                    ') ' ||
                    'AND to_number(replace(grants.grantee_key,''HZ_GROUP:'','''')) = grantee_group.party_id ' ||
                    'AND substr(grants.grantee_key, 1, instr(grants.grantee_key, '':'')-1) =''HZ_GROUP'' ' ||
                    'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate) ' ||
                    'AND granted_menu.menu_id = grants.menu_id ' ||
                    'AND granted_menu.language= userenv(''LANG'') ' ||
                    'AND granted_menu.menu_id = granted_menu_data.menu_id ' ||
		    'AND ' ||
		    '( ' ||
			'( ' ||
   			     ':4 is null ' ||
			     'AND granted_menu_data.menu_name like ''%'' ' ||
			') ' ||
			'OR ' ||
			'( ' ||
			     'granted_menu_data.MENU_NAME in ( :5 ) ' ||
			') ' ||
		    ') ' ||
                    'AND grants.instance_type=''SET'' ' ||
                    'AND ' ||
                    '( ' ||
                        'obj.obj_name =''EGO_ITEM'' ' ||
                        'AND ' ||
                        '( ' ||
                         '   grants.instance_set_id in ( :6 ) ' ||
                        ') ' ||
                    ') ' ;
     END IF;
    /*********************************************************************************************/
     /*
     GET_VALID_INSTANCE_SET_IDS
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
     IF( length(l_inst_set_ids) > 0) THEN
        query_to_exec := query_to_exec || 'UNION ' ||
                'SELECT ' ||
                    'grantee_company.party_name grantee_name, ' ||
                    ' grantee_type grantee_type, ' ||
                    'granted_menu_data.menu_name role_name, ' ||
                    'granted_menu.user_menu_name role_display_name, ' ||
                    'grantee_company.party_id party_id, ' ||
                    'grantee_company.party_id company_id, ' ||
                    'grantee_company.party_name company_name, ' ||
                    'trunc(grants.start_date) start_date , ' ||
                    'trunc(grants.end_date) end_date ' ||
                'FROM fnd_grants grants, ' ||
                    'hz_parties grantee_company, ' ||
                    'fnd_menus_tl granted_menu, ' ||
                    'fnd_menus granted_menu_data, ' ||
                    'fnd_objects obj ' ||
                'WHERE grants.object_id = obj.object_id ' ||
                    'AND grants.grantee_type = ''COMPANY'' ' ||
                    'AND grants.grantee_key like ''HZ_COMPANY:%'' ' ||
                    'AND grantee_company.party_type = ''ORGANIZATION'' ' ||
                    'AND to_number(replace(grants.grantee_key,''HZ_COMPANY:'' , '''')) = grantee_company.party_id ' ||
                    'AND substr(grants.grantee_key, 1, instr(grants.grantee_key, '':'')-1) =''HZ_COMPANY'' ' ||
                    'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate) ' ||
                    'AND granted_menu.menu_id = grants.menu_id ' ||
                    'AND granted_menu.language= userenv(''LANG'') ' ||
                    'AND granted_menu.menu_id = granted_menu_data.menu_id ' ||
                    'AND grants.instance_type=''SET'' ' ||
                 'AND ' ||
                    '( ' ||
                        'obj.obj_name =''EGO_ITEM'' ' ||
                        'AND ' ||
                        '( ' ||
                         '   grants.instance_set_id in ( ' || l_inst_set_ids || ' ) ' ||
                        ') ' ||
                    ') ' ;
     END IF;
     */
    /*********************************************************************************************/
      /*
     GET_VALID_INSTANCE_SET_IDS
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
     IF( length(l_inst_set_ids) > 0) THEN
        query_to_exec := query_to_exec || 'UNION ' ||
                'SELECT ' ||
                    'grantee_global.party_name grantee_name, ' ||
                    ' grantee_type grantee_type, ' ||
                    'granted_menu_data.menu_name role_name, ' ||
                    'granted_menu.user_menu_name role_display_name, ' ||
                    'grantee_global.party_id party_id, ' ||
                    '-1 company_id, ' ||
                    'null company_name, ' ||
                    'trunc(grants.start_date) start_date, ' ||
                    'trunc(grants.end_date) end_date ' ||
                'FROM fnd_grants grants, ' ||
                    'hz_parties grantee_global, ' ||
                    'fnd_menus_tl granted_menu, ' ||
                    'fnd_menus granted_menu_data, ' ||
                    'fnd_objects obj ' ||
                'WHERE grants.object_id = obj.object_id ' ||
                    'AND grants.grantee_type = ''GLOBAL'' ' ||
                    'AND grantee_global.party_id = -1000 ' ||
                    'AND nvl(grants.end_date, sysdate+1) >= trunc(sysdate) ' ||
                    'AND granted_menu.menu_id = grants.menu_id ' ||
                    'AND granted_menu.language= userenv(''LANG'') ' ||
                    'AND granted_menu.menu_id = granted_menu_data.menu_id ' ||
                    'AND grants.instance_type=''SET'' ' ||
                'AND ' ||
                    '( ' ||
                        'obj.obj_name =''EGO_ITEM'' ' ||
                        'AND ' ||
                        '( ' ||
                         '   grants.instance_set_id in ( ' || l_inst_set_ids || ' ) ' ||
                        ') ' ||
                    ') ' ;
     END IF;
     */
    /*********************************************************************************************/

q1 := ' UNION SELECT grantee_person.party_name grantee_name, ' ||
' grantee_type grantee_type, ' ||
' granted_menu.menu_name role_name, ' ||
' granted_menu_tl.user_menu_name role_display_name, ' ||
' granted_menu.menu_id menu_id, ' ||
' grantee_person.PARTY_ID party_id ,  ' ||
' null company_id , ' ||
' '''' COMPANY_NAME ,  ' ||
' trunc(grants.start_date) start_date , ' ||
' trunc(grants.end_date) end_date ' ||
' FROM fnd_grants grants, ' ||
' fnd_menus granted_menu, ' ||
' fnd_objects obj, ' ||
' hz_parties grantee_person, ' ||
' fnd_menus_tl granted_menu_tl ' ||
' WHERE granted_menu.menu_id = grants.menu_id  ' ||
' AND grants.instance_type = ''SET'' AND  grants.instance_pk1_value = ''*NULL*'''  ||
' AND grants.instance_set_id IN ( select instance_set.instance_set_id  ' ||
' from  fnd_object_instance_sets instance_set, mtl_system_items_b item ' ||
' where instance_set.object_id = grants.object_id and ' ||
' (instance_set.instance_set_name = ''EGO_ORG_ITEM_'' || ' ||
' to_char(item.organization_id) or instance_set.instance_set_name = ''EGO_ORG_CAT_ITEM_'' || ' ||
' to_char(item.organization_id) || ''_'' || to_char(item.ITEM_CATALOG_GROUP_ID))  ' ||
' and obj.obj_name = ''EGO_ITEM'' and item.inventory_item_id = ' || l_pk1_value || ' AND item.organization_id = ' || l_pk2_value ||
' AND grants.grantee_type =''USER'' ' ||
' AND grantee_person.party_type = ''PERSON''  ' ||
' AND grantee_person.status = ''A'' ' ||
' AND TO_NUMBER(REPLACE(grants.grantee_key,''HZ_PARTY:'','''')) = grantee_person.party_id ' ||
' AND grantee_key like ''HZ_PARTY:%''  ' ||
' AND (grants.start_date <= SYSDATE AND ( grants.end_date IS NULL OR SYSDATE <= grants.end_date ))  ' ||
' AND grants.object_id = obj.object_id  ' ||
' AND obj.obj_name = ''EGO_ITEM'')  ' ||
' AND granted_menu_tl.menu_id = grants.menu_id ' ||
'AND granted_menu_tl.language= userenv(''LANG'') ' ||
		    'AND ' ||
		    '( ' ||
			'( ' ||
   			     l_role_name_temp || ' is null ' ||
			     'AND granted_menu.menu_name like ''%'' ' ||
			') ' ||
			'OR ' ||
			'( ' ||
			     'granted_menu.MENU_NAME in (  ' || l_role_name_temp  || ' ) ' ||
			') ' ||
		    ') ' ;


q2 := ' UNION SELECT grantee_group.party_name grantee_name, ' ||
' grantee_type grantee_type, ' ||
' granted_menu.menu_name role_name, ' ||
' granted_menu_tl.user_menu_name role_display_name, ' ||
' granted_menu.menu_id menu_id, ' ||
' grantee_group.PARTY_ID party_id ,  ' ||
' null company_id , ' ||
' '''' COMPANY_NAME ,  ' ||
' trunc(grants.start_date) start_date , ' ||
' trunc(grants.end_date) end_date ' ||
' FROM ' ||
' fnd_grants grants , ' ||
' fnd_menus granted_menu, ' ||
' fnd_objects obj        , ' ||
' hz_parties member       , ' ||
' hz_relationships member_group , ' ||
' hz_parties grantee_group, ' ||
' fnd_menus_tl granted_menu_tl ' ||
' WHERE  grants.menu_id = granted_menu.menu_id   ' ||
' AND grants.instance_type= ''SET'' AND grants.instance_pk1_value = ''*NULL*'' AND  ' ||
'  grants.instance_set_id IN ( select instance_set.instance_set_id from   ' ||
'  fnd_object_instance_sets instance_set, mtl_system_items_b item   ' ||
' where instance_set.object_id = grants.object_id and   (instance_set.instance_set_name = ''EGO_ORG_ITEM_'' || to_char(item.organization_id)   ' ||
'  or instance_set.instance_set_name = ''EGO_ORG_CAT_ITEM_'' || to_char(item.organization_id) || ''_'' || to_char(item.ITEM_CATALOG_GROUP_ID))  ' ||
' and   obj.obj_name = ''EGO_ITEM'' AND item.inventory_item_id = ' || l_pk1_value || ' AND  item.organization_id = ' || l_pk2_value ||
' AND grants.grantee_type = ''GROUP''    ' ||
' AND member_group.object_id = grantee_group.party_id  ' ||
' AND member_group.subject_id = member.party_id  ' ||
' AND member.party_type = ''PERSON''   ' ||
' AND member.status = ''A''  ' ||
' AND member_group.subject_type = ''PERSON''  ' ||
' AND member_group.object_type = ''GROUP''  ' ||
' AND member_group.relationship_type = ''MEMBERSHIP''  ' ||
' AND member_group.status = ''A''  ' ||
' AND member_group.start_date <= SYSDATE  ' ||
' AND (member_group.end_date IS NULL OR member_group.end_date >= SYSDATE)  ' ||
' AND TO_NUMBER(REPLACE(grants.grantee_key,''HZ_GROUP:'','''')) = grantee_group.party_id  ' ||
' AND grantee_key like ''HZ_GROUP:%''   ' ||
' AND (grants.start_date <= SYSDATE AND (grants.end_date IS NULL OR SYSDATE <= grants.end_date))  ' ||
' AND grants.object_id = obj.object_id   ' ||
' AND obj.obj_name = ''EGO_ITEM'') ' ||
' AND granted_menu_tl.menu_id = grants.menu_id ' ||
'AND granted_menu_tl.language= userenv(''LANG'') ' ||
		    'AND ' ||
		    '( ' ||
			'( ' ||
   			     l_role_name_temp || ' is null ' ||
			     'AND granted_menu.menu_name like ''%'' ' ||
			') ' ||
			'OR ' ||
			'( ' ||
			     'granted_menu.MENU_NAME in ( ' || l_role_name_temp  || ' ) ' ||
			') ' ||
		    ') ' ;

                cursor_select := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(cursor_select, query_to_exec || q1 || q2, DBMS_SQL.NATIVE);
                l_index := 0;
                dbms_sql.DEFINE_COLUMN(cursor_select, 1, '', 80);
                dbms_sql.DEFINE_COLUMN(cursor_select, 2, '', 30);
                dbms_sql.DEFINE_COLUMN(cursor_select, 3, '', 30);
                dbms_sql.DEFINE_COLUMN(cursor_select, 4, '', 80);
                dbms_sql.DEFINE_COLUMN(cursor_select, 5, l_temp_menu_id);
/*
                dbms_sql.DEFINE_COLUMN(cursor_select, 7, '', 80);
                dbms_sql.DEFINE_COLUMN(cursor_select, 8, '', 30);
                dbms_sql.DEFINE_COLUMN(cursor_select, 9, '', 80);
                dbms_sql.DEFINE_COLUMN(cursor_select, 10, '', 30);
*/

		DBMS_SQL.BIND_VARIABLE(cursor_select, ':1', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':2', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':3', l_inst_set_ids);

		DBMS_SQL.BIND_VARIABLE(cursor_select, ':4', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':5', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':6', l_inst_set_ids);

/*
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':7', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':8', l_role_name_temp);
    DBMS_SQL.BIND_VARIABLE(cursor_select, ':9', l_role_name_temp);
		DBMS_SQL.BIND_VARIABLE(cursor_select, ':10', l_role_name_temp);
*/

                cursor_execute := DBMS_SQL.EXECUTE(cursor_select);

                LOOP
                     IF dbms_sql.fetch_rows(cursor_select) > 0 THEN
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 1, l_grantee_list(l_index).grantee_name);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 2, l_grantee_list(l_index).grantee_type);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 3, l_grantee_list(l_index).role_name);
                             DBMS_SQL.COLUMN_VALUE(cursor_select, 4, l_grantee_list(l_index).role_display_name);
			     DBMS_SQL.COLUMN_VALUE(cursor_select, 5, l_temp_menu_id);

			     l_default_access:=Get_Default_Access(p_menu_id => l_temp_menu_id);
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

                      FOR i in l_grantee_list.first .. l_grantee_list.last LOOP
                        x_grantee_names(memcount+1):=l_grantee_list(i).grantee_name;
                        x_grantee_types(memcount+1):=l_grantee_list(i).grantee_type;
                        x_role_names(memcount+1):=l_grantee_list(i).role_name;
                        x_role_display_names(memcount+1):=l_grantee_list(i).role_display_name;
		        x_default_access(memcount+1):=l_grantee_list(i).default_access;
                        memcount := memcount + 1;
                      END LOOP;
                    END IF;

                DBMS_SQL.CLOSE_CURSOR(cursor_select);

EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
             x_return_status:='F';

      WHEN OTHERS
      THEN
             x_return_status:='F';
END Get_Users;

/*
PROCEDURE GET_VALID_INSTANCE_SET_IDS
(
     p_grantee_type IN VARCHAR2,
     x_inst_set_ids OUT NOCOPY VARCHAR2
)
IS
BEGIN

    EGO_VALID_INSTANCE_SET_GRANTS.GET_VALID_INSTANCE_SETS
    (
          p_obj_name            => 'EGO_ITEM' ,
          p_grantee_type        => p_grantee_type ,
          p_parent_obj_sql      => null ,
          p_bind1               => null ,
          p_bind2               => null ,
          p_bind3               => null ,
          p_bind4               => null ,
          p_bind5               => null ,
          p_obj_ids             => '48819,204' ,
          x_inst_set_ids        => x_inst_set_ids
     );
*/

 PROCEDURE GET_VALID_INSTANCE_SET_IDS
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

 FOR inst_set_preds_rec IN inst_set_preds
 LOOP
        IF p_obj_ids IS NOT NULL THEN
                query_to_exec := 'SELECT 1 from dual WHERE (' || p_obj_ids || ') IN (' || obj_std_pkq;
                query_to_exec := query_to_exec || ' WHERE ' || inst_set_preds_rec.predicate || ' )';
        ELSIF p_parent_obj_sql IS NOT NULL THEN
                query_to_exec := 'SELECT 1 from dual WHERE EXISTS( ' || obj_std_pkq || ' WHERE ';
                query_to_exec := query_to_exec || inst_set_preds_rec.predicate || ' AND (';
                query_to_exec := query_to_exec || prim_key_str || ') IN (' || p_parent_obj_sql || '))';
        END IF;
        cursor_select := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cursor_select, query_to_exec, DBMS_SQL.NATIVE);
        IF p_bind1 IS NOT NULL THEN
                DBMS_SQL.BIND_VARIABLE(cursor_select, ':id1', p_bind1);
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
 END GET_VALID_INSTANCE_SET_IDS;


 FUNCTION Get_Default_Access(p_menu_id IN NUMBER)
 RETURN VARCHAR2
 IS
 l_priv_count  NUMBER;
 BEGIN
 l_priv_count := -1;
     -- Get the default access for the folder.
     -- If the role has  'Add Item People' privilege then it is Administrator,
     -- If the role has 'Add Item Document' privilege then it is Author,
     -- If the role has ' View Item Document ' privilege then it is Reader ,
     -- otherwise give  'Discover' default role on folder.

     SELECT COUNT(function_name)
     INTO l_priv_count
     FROM fnd_form_functions
     WHERE function_name='EGO_ADD_ITEM_PEOPLE' AND
     function_id IN (SELECT function_id FROM fnd_menu_entries WHERE menu_id = p_menu_id);

     IF(l_priv_count > 0) THEN
	RETURN 'Administrator';
     END IF;

     SELECT COUNT(function_name)
     INTO l_priv_count
     FROM fnd_form_functions
     WHERE function_name='EGO_ADD_ITEM_DOCUMENT' AND
     function_id IN (SELECT function_id FROM fnd_menu_entries WHERE menu_id = p_menu_id);

     IF(l_priv_count > 0) THEN
	RETURN 'Author';
     END IF;

     SELECT COUNT(function_name)
     INTO l_priv_count
     FROM fnd_form_functions
     WHERE function_name='EGO_VIEW_ITEM_DOCUMENT_LIST' AND
     function_id IN (SELECT function_id FROM fnd_menu_entries WHERE menu_id = p_menu_id);

     IF(l_priv_count > 0) THEN
	RETURN 'Reader';
     END IF;

     RETURN 'Discoverer';
 END Get_Default_Access;

FUNCTION GET_ATTACHMENT_PRIVILAGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_name IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS
  l_policy_value VARCHAR2(30);
  l_item_catalog_group_id VARCHAR2(30);
  l_lifecycle_id VARCHAR2(30);
  l_current_phase_id VARCHAR2(30);
  l_viewPriv       VARCHAR2(30) DEFAULT NULL;
  l_editPriv       VARCHAR2(30) DEFAULT NULL;
  l_result          VARCHAR2(30);
  l_party_id       VARCHAR2(30);
  l_category_id    VARCHAR2(30);
  BEGIN
  IF FND_GLOBAL.User_Id = -1 THEN
    SELECT PARTY_ID INTO l_party_id FROM EGO_USER_V WHERE user_name = FND_GLOBAL.USER_NAME;
  ELSE
   SELECT PARTY_ID INTO l_party_id FROM EGO_USER_V WHERE user_id = TO_CHAR(FND_GLOBAL.User_Id);
  END IF;

  l_viewPriv := EGO_DATA_SECURITY.CHECK_FUNCTION (
        1.0,
        'EGO_VIEW_ITEM_DOCUMENT_LIST',
        'EGO_ITEM',
        p_pk2_value,
        p_pk1_value,
        NULL,NULL,NULL,
        'HZ_PARTY:'||l_party_id);
  l_editPriv := EGO_DATA_SECURITY.CHECK_FUNCTION (
        1.0,
        'EGO_ADD_ITEM_DOCUMENT',
        'EGO_ITEM',
        p_pk2_value,
        p_pk1_value,
        NULL,NULL,NULL,
        'HZ_PARTY:'||l_party_id);


  SELECT
   Nvl(fad.category_id,fd.category_id)
  INTO
   l_category_id
  FROM
   fnd_attached_documents fad,fnd_documents fd
  WHERE
  (p_attachment_id IS NULL OR fad.attached_Document_id =  p_attachment_id)
  AND (fad.entity_name = p_entity_name)
  AND (fad.pk1_value = p_pk1_value)
  AND (p_pk2_value IS NULL OR fad.pk2_value = p_pk2_value)
  AND (p_pk3_value IS NULL OR fad.pk3_value = p_pk3_value)
  AND (p_pk4_value IS NULL OR fad.pk4_value = p_pk4_value)
  AND (p_pk5_value IS NULL OR fad.pk5_value = p_pk5_value)
  AND fd.document_id = fad.document_id;

    IF (l_editPriv = 'T') THEN
    l_result := 'Update';
    SELECT
      item_catalog_group_id,
      lifecycle_id,
      current_phase_id
    INTO
      l_item_catalog_group_id,
      l_lifecycle_id,
      l_lifecycle_id
    FROM
      mtl_system_items_b
    WHERE
      inventory_item_id = p_pk2_value AND
      organization_id = p_pk1_value;
    ENG_CHANGE_POLICY_PKG.GetChangePolicy
      (   'CATALOG_LIFECYCLE_PHASE'
       ,  'CHANGE_POLICY'
       ,  l_item_catalog_group_id
       ,  l_lifecycle_id
       ,  l_lifecycle_id
       ,  NULL
       ,  NULL
       ,  'EGO_CATALOG_GROUP'
       ,  'ATTACHMENT'
       ,  l_category_id
       ,  l_policy_value
    );
    IF (l_policy_value = 'ALLOWED')
      THEN RETURN('Update');
    END IF; --l_policy_value = 'ALLOWED'
  END IF; --l_editPriv = 'T'
  IF (l_viewPriv = 'T') THEN
    RETURN 'View' ;
  ELSE
    RETURN NULL;
  END IF;
EXCEPTION
  WHEN OTHERS then
  IF (l_viewPriv = 'T') THEN
    RETURN 'View' ;
  ELSE
    RETURN NULL;
    END IF;
  END GET_ATTACHMENT_PRIVILAGES;

END EGO_DOM_SECURITY_PVT;

/

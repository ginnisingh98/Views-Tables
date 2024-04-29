--------------------------------------------------------
--  DDL for Package Body JTM_RS_GROUP_MEMBER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_RS_GROUP_MEMBER_VUHK" AS
  /* $Header: jtmhkgmb.pls 120.1 2005/08/24 02:11:59 saradhak noship $ */

Cursor Get_hook_info(p_processing_type in varchar2, p_api_name in varchar2) is
     Select HOOK_PACKAGE, HOOK_API , EXECUTE_FLAG, PRODUCT_CODE
	 from JTF_HOOKS_DATA
	 Where package_name = 'JTM_RS_GROUP_MEMBERS_PVT' and
	 upper(api_name) = upper(p_api_name) and
	 processing_type = p_processing_type and
         execute_flag = 'Y' and
	 hook_type = 'V';


  /* Vertcal Industry Procedure for pre processing in case of
	create resource group members */

  PROCEDURE  create_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  END create_group_members_pre;


  /* Vertcal Industry Procedure for post processing in case of
	create resource group members */

  PROCEDURE  create_group_members_post
  (P_GROUP_MEMBER_ID      IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
 BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

   FOR Csr1 in Get_hook_info('A', 'CREATE_RESOURCE_GROUP_MEMBERS') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3, :4); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_GROUP_MEMBER_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_GROUP_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_RESOURCE_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_RETURN_STATUS);
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END create_group_members_post;

  /* Vertcal Industry Procedure for pre processing in case of
	update resource group members */

  PROCEDURE  update_group_members_pre
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  END update_group_members_pre;


  /* Vertcal Industry Procedure for post processing in case of
	update resource group members */

  PROCEDURE  update_group_members_post
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  END update_group_members_post;


  /* Vertcal Industry Procedure for pre processing in case of
	delete resource group members */

  PROCEDURE  delete_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;

BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

   FOR Csr1 in Get_hook_info('B', 'DELETE_RESOURCE_GROUP_MEMBERS') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_GROUP_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_RESOURCE_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':3', X_RETURN_STATUS);
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END delete_group_members_pre;


  /* Vertical Industry Procedure for post processing in case of
	delete resource group members */

  PROCEDURE delete_group_members_post
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT NOCOPY VARCHAR2
  ) IS
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
  END delete_group_members_post;

END jtm_rs_group_member_vuhk;

/

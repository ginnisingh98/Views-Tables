--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUP_MEMBER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUP_MEMBER_VUHK" AS
  /* $Header: jtmgmemb.pls 120.2 2005/08/24 02:10:08 saradhak noship $ */


  /* Vertcal Industry Procedure for pre processing in case of
	create resource group members */

  PROCEDURE  create_group_members_pre
  (P_GROUP_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_GROUP_MEMBERS.RESOURCE_ID%TYPE,
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2
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
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2
  ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_GROUP_MEMBERS_POST'', ' ||
           ' ''JTF_RS_GROUP_MEMBER_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.JTF_RS_GROUP_MEMBER_VUHK.CREATE_GROUP_MEMBERS_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_GROUP_MEMBERS_POST'', ' ||
           ' ''JTF_RS_GROUP_MEMBER_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.JTF_RS_GROUP_MEMBER_VUHK.CREATE_GROUP_MEMBERS_POST''); ' ||
         ' end; ';
   exception
       when others then
              null;
   end;

   /* check if JTM is installed */
  l_JTM_enable_prof_value := fnd_profile.VALUE_SPECIFIC(
          Name => 'JTM_MOB_APPS_ENABLED', APPLICATION_ID => 874);

  if (l_JTM_enable_prof_value = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || 'JTM_RS_GROUP_MEMBER_VUHK' || '.' || 'create_group_members_post' ||
            '(:1,:2,:3,:4); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
               EXECUTE IMMEDIATE l_strLogBuffer;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
  end if;

EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       begin
         EXECUTE IMMEDIATE l_strLogBuffer;
       exception
           when others then
              null;
       end;
END create_group_members_post;

  /* Vertcal Industry Procedure for pre processing in case of
	update resource group members */

  PROCEDURE  update_group_members_pre
  (P_GROUP_MEMBER_ID             IN   JTF_RS_GROUP_MEMBERS.GROUP_MEMBER_ID%TYPE,
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2
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
   X_RETURN_STATUS        OUT  NOCOPY VARCHAR2
  ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_GROUP_MEMBERS_PRE'', ' ||
           ' ''JTF_RS_GROUP_MEMBER_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.JTF_RS_GROUP_MEMBER_VUHK.DELETE_GROUP_MEMBERS_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_GROUP_MEMBERS_PRE'', ' ||
           ' ''JTF_RS_GROUP_MEMBER_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.JTF_RS_GROUP_MEMBER_VUHK.DELETE_GROUP_MEMBERS_PRE''); ' ||
         ' end; ';
   exception
       when others then
              null;
   end;
   /* check if JTM is installed */
  l_JTM_enable_prof_value := fnd_profile.VALUE_SPECIFIC(
          Name => 'JTM_MOB_APPS_ENABLED', APPLICATION_ID => 874);

  if (l_JTM_enable_prof_value = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || 'JTM_RS_GROUP_MEMBER_VUHK' || '.' || 'delete_group_members_pre' ||
            '(:1,:2,:3); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_GROUP_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_RESOURCE_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':3', X_RETURN_STATUS);
         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               EXECUTE IMMEDIATE l_strLogBuffer;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
  end if;

EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       begin
          EXECUTE IMMEDIATE l_strLogBuffer;
       exception
           when others then
              null;
       end;
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

END jtf_rs_group_member_vuhk;

/

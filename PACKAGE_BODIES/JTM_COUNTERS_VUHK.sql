--------------------------------------------------------
--  DDL for Package Body JTM_COUNTERS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_COUNTERS_VUHK" AS
/* $Header: jtmhkcnb.pls 120.1 2005/08/24 02:10:26 saradhak noship $*/

Cursor Get_hook_info(p_processing_type in varchar2, p_api_name in varchar2) is
     Select HOOK_PACKAGE, HOOK_API , EXECUTE_FLAG, PRODUCT_CODE
	 from JTF_HOOKS_DATA
	 Where package_name = 'JTM_COUNTERS_PUB' and
	 upper(api_name) = upper(p_api_name) and
	 processing_type = p_processing_type and
         execute_flag = 'Y' and
	 hook_type = 'V';


PROCEDURE CREATE_CTR_GRP_INSTANCE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CREATE_CTR_GRP_INSTANCE') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_source_object_cd);
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_source_object_id);
         DBMS_SQL.bind_variable (l_cursorid, ':9', x_ctr_grp_id );
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


PROCEDURE CREATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CREATE_COUNTER') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_ctr_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE CREATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CREATE_CTR_PROP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', x_ctr_prop_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE INSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'INSTANTIATE_COUNTERS') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_counter_group_id_template );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_source_object_code_instance);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_source_object_id_instance);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_ctr_grp_id_template);
         DBMS_SQL.bind_variable (l_cursorid, ':11', x_ctr_grp_id_instance);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_CTR_GRP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_CTR_GRP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_grp_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_CTR_GRP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_CTR_GRP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_grp_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_COUNTER') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_COUNTER') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               null;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_CTR_PROP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_prop_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE UPDATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT  NOCOPY NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_CTR_PROP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_prop_id );
         DBMS_SQL.bind_variable (l_cursorid, ':8', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':9', p_cascade_upd_to_instances);
         DBMS_SQL.bind_variable (l_cursorid, ':10', x_object_version_number);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE DELETE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_id			 IN   NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'DELETE_COUNTER') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_id );

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE DELETE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2,
    p_ctr_prop_id		 IN   NUMBER
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'DELETE_CTR_PROP') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':5', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Msg_Data);
         DBMS_SQL.bind_variable (l_cursorid, ':7', p_ctr_prop_id );

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE DELETE_COUNTER_INSTANCE_PRE (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT  NOCOPY VARCHAR2,
    x_Msg_Count                  OUT  NOCOPY NUMBER,
    x_Msg_Data                   OUT  NOCOPY VARCHAR2
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'DELETE_COUNTER_INSTANCE') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_SOURCE_OBJECT_ID );
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_SOURCE_OBJECT_CODE );
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Data);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               /* to be integrate with message handler */
               NULL;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
      end if;
   END LOOP;

EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


End JTM_COUNTERS_VUHK;

/

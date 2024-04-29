--------------------------------------------------------
--  DDL for Package Body JTM_CTR_CAPTURE_READING_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_CTR_CAPTURE_READING_VUHK" as
/* $Header: jtmhkcpb.pls 120.1 2005/08/24 02:11:06 saradhak noship $*/
Cursor Get_hook_info(p_processing_type in varchar2, p_api_name in varchar2) is
     Select HOOK_PACKAGE, HOOK_API , EXECUTE_FLAG, PRODUCT_CODE
	 from JTF_HOOKS_DATA
	 Where package_name = 'JTM_CTR_CAPTURE_READING_PUB' and
	 upper(api_name) = upper(p_api_name) and
	 processing_type = p_processing_type and
         execute_flag = 'Y' and
	 hook_type = 'V';


PROCEDURE CAPTURE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Commit                     IN   VARCHAR2     ,
    p_validation_level           IN   NUMBER       ,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
  ) IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CAPTURE_COUNTER_READING') LOOP

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
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Data);

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
END CAPTURE_COUNTER_READING_POST;

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_COUNTER_READING') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':6', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_PRE;

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('B', 'UPDATE_COUNTER_READING') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_PRE;


PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_COUNTER_READING') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':6', p_object_version_number);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_POST;

PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'UPDATE_COUNTER_READING') LOOP

      /* user execute flag */
      l_enable_flag := Csr1.EXECUTE_FLAG;

      /* use profile for checking */
      l_enable_flag := JTM_PROFILE_UTL_PKG.Get_enable_flag_at_resp
              (p_app_short_name => Csr1.PRODUCT_CODE);

      if (l_enable_flag = 'Y') then
         l_cursorid := DBMS_SQL.open_cursor;
         l_strBuffer :=
            ' begin ' || Csr1.HOOK_PACKAGE || '.' || Csr1.HOOK_API ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            '     null; ' ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_POST;

PROCEDURE CAPTURE_CTR_PROP_READING_POST(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2,
     P_Commit                  IN   VARCHAR2,
     p_validation_level        IN   NUMBER,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT NOCOPY  VARCHAR2,
     X_Msg_Count               OUT NOCOPY  NUMBER,
     X_Msg_Data                OUT NOCOPY  VARCHAR2
     )
IS
    l_enable_flag varchar2(20);
    l_cursorid   INTEGER;
    l_strBuffer   VARCHAR2(2000);
    l_execute_status INTEGER;
BEGIN
   X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   FOR Csr1 in Get_hook_info('A', 'CAPTURE_CTR_PROP_READING') LOOP

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
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_COUNTER_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Data);

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
END CAPTURE_CTR_PROP_READING_POST;

END JTM_CTR_CAPTURE_READING_VUHK;

/

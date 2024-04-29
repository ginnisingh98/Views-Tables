--------------------------------------------------------
--  DDL for Package Body CS_CTR_CAPTURE_READING_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CTR_CAPTURE_READING_VUHK" as
/* $Header: jtmcncpb.pls 120.2 2005/08/24 02:08:30 saradhak noship $*/

PROCEDURE CAPTURE_COUNTER_READING_PRE(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_GRP_LOG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_GRP_LOG_Rec,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END CAPTURE_COUNTER_READING_PRE;

PROCEDURE CAPTURE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,
    P_Commit                     IN   VARCHAR2     ,
    p_validation_level           IN   NUMBER       ,
    p_CTR_GRP_LOG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type  ,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  ,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
  ) IS

  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_array_counter NUMBER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_COUNTER_READING_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_COUNTER_READING_POST''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'CAPTURE_COUNTER_READING_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_CTR_GRP_LOG_Rec.counter_grp_log_id);
         DBMS_SQL.bind_variable (l_cursorid, ':6', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Data);

         begin
           l_execute_status := DBMS_SQL.execute (l_cursorid);
         exception
            when others then
               EXECUTE IMMEDIATE l_strLogBuffer;
         end;
         DBMS_SQL.close_cursor (l_cursorid);
  end if;

/*
    IF p_CTR_RDG_Tbl.count > 0 THEN
      l_array_counter := p_CTR_RDG_Tbl.First;
      WHILE p_CTR_RDG_Tbl.EXISTS(l_array_counter) LOOP
    	IF p_CTR_RDG_Tbl(l_array_counter).COUNTER_VALUE_ID <> FND_API.G_MISS_NUM THEN
             l_cursorid := DBMS_SQL.open_cursor;
             l_strBuffer :=
             ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.'
                       || 'CAPTURE_COUNTER_READING_POST' ||
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
                 DBMS_SQL.bind_variable (l_cursorid, ':5',
                       p_CTR_RDG_Tbl(l_array_counter).COUNTER_VALUE_ID);
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
        END IF;
        l_array_counter := p_CTR_RDG_Tbl.NEXT(l_array_counter);
      END LOOP;
    END IF;
*/


EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       begin
         EXECUTE IMMEDIATE l_strLogBuffer;
       exception
           when others then
              null;
       end;
END CAPTURE_COUNTER_READING_POST;

PROCEDURE UPDATE_COUNTER_READING_PRE(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
  )
IS
--NEEDED
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_PRE'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_PRE'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_PRE''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'UPDATE_COUNTER_READING_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_CTR_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_PRE;


PROCEDURE UPDATE_COUNTER_READING_POST(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_CTR_RDG_TBL,
    p_PROP_RDG_Tbl               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Tbl_Type  := CS_CTR_CAPTURE_READING_PUB.G_MISS_PROP_RDG_TBL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
  )
IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_POST''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'UPDATE_COUNTER_READING_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', P_Api_Version_Number);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_CTR_GRP_LOG_ID);
         DBMS_SQL.bind_variable (l_cursorid, ':7', X_Return_Status);
         DBMS_SQL.bind_variable (l_cursorid, ':8', X_Msg_Count);
         DBMS_SQL.bind_variable (l_cursorid, ':9', X_Msg_Data);

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
END UPDATE_COUNTER_READING_POST;

PROCEDURE CAPTURE_COUNTER_READING_PRE (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
   )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END CAPTURE_COUNTER_READING_PRE;

PROCEDURE CAPTURE_COUNTER_READING_POST (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
   )
IS
--NEEDED
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_COUNTER_READING_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_COUNTER_READING_POST''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'CAPTURE_COUNTER_READING_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END CAPTURE_COUNTER_READING_POST;

PROCEDURE UPDATE_COUNTER_READING_PRE (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
   )
IS
--NEEDED
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_PRE'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_PRE'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_PRE''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'UPDATE_COUNTER_READING_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END UPDATE_COUNTER_READING_PRE;

PROCEDURE UPDATE_COUNTER_READING_POST (
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CS_CTR_CAPTURE_READING_PUB.CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
   )
IS
--NEEDED
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.UPDATE_COUNTER_READING_POST''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'UPDATE_COUNTER_READING_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8, :9); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END UPDATE_COUNTER_READING_POST;

PROCEDURE PRE_CAPTURE_CTR_READING_PRE(
     p_api_version_number        IN  NUMBER,
     p_init_msg_list             IN  VARCHAR2,
     P_Commit                    IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     P_CTR_GRP_LOG_Rec           IN  CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type,
     X_COUNTER_GRP_LOG_ID        IN NUMBER,
     X_Return_Status             OUT NOCOPY VARCHAR2,
     X_Msg_Count                 OUT NOCOPY NUMBER,
     X_Msg_Data                  OUT NOCOPY VARCHAR2
    )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END PRE_CAPTURE_CTR_READING_PRE;

PROCEDURE PRE_CAPTURE_CTR_READING_POST(
     p_api_version_number        IN  NUMBER,
     p_init_msg_list             IN  VARCHAR2,
     P_Commit                    IN  VARCHAR2,
     p_validation_level          IN  NUMBER,
     P_CTR_GRP_LOG_Rec           IN  CS_CTR_CAPTURE_READING_PUB.CTR_GRP_LOG_Rec_Type,
     X_COUNTER_GRP_LOG_ID        IN NUMBER,
     X_Return_Status             OUT NOCOPY VARCHAR2,
     X_Msg_Count                 OUT NOCOPY NUMBER,
     X_Msg_Data                  OUT NOCOPY VARCHAR2
    )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END PRE_CAPTURE_CTR_READING_POST;

PROCEDURE CAPTURE_CTR_PROP_READING_PRE(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2,
     P_Commit                  IN   VARCHAR2,
     p_validation_level        IN   NUMBER,
     p_PROP_RDG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT  NOCOPY VARCHAR2,
     X_Msg_Count               OUT  NOCOPY NUMBER,
     X_Msg_Data                OUT  NOCOPY VARCHAR2
     )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END CAPTURE_CTR_PROP_READING_PRE;

PROCEDURE CAPTURE_CTR_PROP_READING_POST(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2,
     P_Commit                  IN   VARCHAR2,
     p_validation_level        IN   NUMBER,
     p_PROP_RDG_Rec            IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT  NOCOPY VARCHAR2,
     X_Msg_Count               OUT  NOCOPY NUMBER,
     X_Msg_Data                OUT  NOCOPY VARCHAR2
     )
IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_CTR_PROP_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_CTR_PROP_READING_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
BEGIN
   X_Return_Status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CAPTURE_CTR_PROP_READING_POST'', ' ||
           ' ''CS_CTR_CAPTURE_READING_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CS_CTR_CAPTURE_READING_VUHK.CAPTURE_CTR_PROP_READING_POST''); ' ||
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
     ' begin ' || 'JTM_CTR_CAPTURE_READING_VUHK' || '.' || 'CAPTURE_CTR_PROP_READING_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END CAPTURE_CTR_PROP_READING_POST;

PROCEDURE POST_CAPTURE_CTR_READING_PRE (
      p_api_version_number      IN   NUMBER,
      p_init_msg_list           IN   VARCHAR2,
      P_Commit                  IN   VARCHAR2,
      p_validation_level        IN   NUMBER,
      p_COUNTER_GRP_LOG_ID      IN   NUMBER,
      p_READING_UPDATED         IN   VARCHAR2,
      X_Return_Status           OUT  NOCOPY VARCHAR2,
      X_Msg_Count               OUT  NOCOPY NUMBER,
      X_Msg_Data                OUT  NOCOPY VARCHAR2
     )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END POST_CAPTURE_CTR_READING_PRE;

PROCEDURE POST_CAPTURE_CTR_READING_POST (
      p_api_version_number      IN   NUMBER,
      p_init_msg_list           IN   VARCHAR2,
      P_Commit                  IN   VARCHAR2,
      p_validation_level        IN   NUMBER,
      p_COUNTER_GRP_LOG_ID      IN   NUMBER,
      p_READING_UPDATED         IN   VARCHAR2,
      X_Return_Status           OUT  NOCOPY VARCHAR2,
      X_Msg_Count               OUT  NOCOPY NUMBER,
      X_Msg_Data                OUT  NOCOPY VARCHAR2
     )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END POST_CAPTURE_CTR_READING_POST;

PROCEDURE UPDATE_CTR_PROP_READING_PRE (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_PROP_RDG_Rec               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END UPDATE_CTR_PROP_READING_PRE;

PROCEDURE UPDATE_CTR_PROP_READING_POST (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_PROP_RDG_Rec               IN   CS_CTR_CAPTURE_READING_PUB.PROP_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
BEGIN
X_Return_Status := FND_API.G_RET_STS_SUCCESS;
END UPDATE_CTR_PROP_READING_POST;

End CS_CTR_CAPTURE_READING_VUHK;

/

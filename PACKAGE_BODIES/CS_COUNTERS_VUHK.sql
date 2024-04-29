--------------------------------------------------------
--  DDL for Package Body CS_COUNTERS_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COUNTERS_VUHK" AS
/* $Header: jtmcntrb.pls 120.2 2005/08/24 02:08:51 saradhak noship $*/
PROCEDURE CREATE_CTR_GRP_TEMPLATE_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    x_ctr_grp_id                 IN  NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE CREATE_CTR_GRP_TEMPLATE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_CTR_GRP_INSTANCE_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_CTR_GRP_INSTANCE_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_source_object_cd           IN   VARCHAR2,
    p_source_object_id           IN   NUMBER,
    x_ctr_grp_id                 IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);

BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_CTR_GRP_INSTANCE_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_CTR_GRP_INSTANCE_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_CTR_GRP_INSTANCE_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_CTR_GRP_INSTANCE_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'CREATE_CTR_GRP_INSTANCE_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE CREATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    x_ctr_id                     IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_COUNTER_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_COUNTER_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_COUNTER_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_COUNTER_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'CREATE_COUNTER_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;
PROCEDURE CREATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    x_ctr_prop_id                IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_CTR_PROP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_CTR_PROP_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_CTR_PROP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.CREATE_CTR_PROP_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'CREATE_CTR_PROP_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;
PROCEDURE CREATE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER,
    p_mapped_counter_id          IN   NUMBER,
    x_ctr_formula_bvar_id        IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER ,
    p_mapped_counter_id          IN   NUMBER,
    x_ctr_formula_bvar_id        IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    x_ctr_der_filter_id          IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    x_ctr_der_filter_id          IN  NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_ctr_association_id         IN  NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE CREATE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_ctr_association_id         IN  NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE AUTOINSTANTIATE_COUNTERS_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_source_object_id_template  IN   NUMBER,
    p_source_object_id_instance  IN   NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE AUTOINSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_source_object_id_template  IN   NUMBER,
    p_source_object_id_instance  IN   NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE INSTANTIATE_COUNTERS_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN   NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE INSTANTIATE_COUNTERS_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_counter_group_id_template  IN   NUMBER,
    p_source_object_code_instance IN  VARCHAR2,
    p_source_object_id_instance   IN  NUMBER,
    x_ctr_grp_id_template        IN  NUMBER,
    x_ctr_grp_id_instance        IN  NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''INSTANTIATE_COUNTERS_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.INSTANTIATE_COUNTERS_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''INSTANTIATE_COUNTERS_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.INSTANTIATE_COUNTERS_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'INSTANTIATE_COUNTERS_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE UPDATE_CTR_GRP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_GRP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_GRP_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_GRP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_GRP_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_CTR_GRP_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
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
END;

PROCEDURE UPDATE_CTR_GRP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_grp_id                 IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_rec                IN   CS_COUNTERS_PUB.CtrGrp_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_GRP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_GRP_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_GRP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_GRP_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_CTR_GRP_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
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
END;

PROCEDURE UPDATE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_COUNTER_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_COUNTER_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_COUNTER_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE UPDATE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_rec                    IN   CS_COUNTERS_PUB.Ctr_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_COUNTER_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_COUNTER_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_COUNTER_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_COUNTER_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE UPDATE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_PROP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_PROP_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_PROP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_PROP_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_CTR_PROP_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE UPDATE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_prop_rec               IN   CS_COUNTERS_PUB.Ctr_Prop_Rec_Type,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_PROP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_PROP_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_CTR_PROP_POST'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.UPDATE_CTR_PROP_POST''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'UPDATE_CTR_PROP_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE UPDATE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER,
    p_mapped_counter_id          IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE UPDATE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_bind_var_name              IN   VARCHAR2,
    p_mapped_item_id             IN   NUMBER,
    p_mapped_counter_id          IN   NUMBER,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER,
    p_reading_type               IN   VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE UPDATE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE UPDATE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_seq_no                     IN   NUMBER,
    p_counter_id                 IN   NUMBER,
    p_left_paren                 IN   VARCHAR2,
    p_ctr_prop_id                IN   NUMBER,
    p_rel_op                     IN   VARCHAR2,
    p_right_val                  IN   VARCHAR2,
    p_right_paren                IN   VARCHAR2,
    p_log_op                     IN   VARCHAR2,
    p_cascade_upd_to_instances   IN   VARCHAR2,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE UPDATE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_association_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE UPDATE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_association_id         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    p_ctr_grp_id                 IN   NUMBER,
    p_source_object_id           IN   NUMBER,
    x_object_version_number      OUT NOCOPY NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_COUNTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_id			 IN   NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_COUNTER_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_COUNTER_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_COUNTER_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_COUNTER_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'DELETE_COUNTER_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE DELETE_COUNTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_id                     IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

PROCEDURE DELETE_CTR_PROP_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_id		 IN   NUMBER
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_CTR_PROP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_CTR_PROP_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_CTR_PROP_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_CTR_PROP_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'DELETE_CTR_PROP_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE DELETE_CTR_PROP_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_prop_id                IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_FORMULA_REF_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_FORMULA_REF_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_formula_bvar_id        IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_GRPOP_FILTER_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_GRPOP_FILTER_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_der_filter_id          IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_CTR_ASSOCIATION_PRE(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_association_id	 IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_CTR_ASSOCIATION_POST(
    P_Api_Version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    p_ctr_association_id         IN   NUMBER
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
PROCEDURE DELETE_COUNTER_INSTANCE_PRE (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT NOCOPY VARCHAR2,
    x_Msg_Count                  OUT NOCOPY NUMBER,
    x_Msg_Data                   OUT NOCOPY VARCHAR2
    ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000);
BEGIN
  l_strLogBuffer := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_COUNTER_INSTANCE_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_COUNTER_INSTANCE_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''DELETE_COUNTER_INSTANCE_PRE'', ' ||
           ' ''CS_COUNTERS_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''jtm:CS_COUNTERS_VUHK.DELETE_COUNTER_INSTANCE_PRE''); ' ||
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
     ' begin ' || 'JTM_COUNTERS_VUHK' || '.' || 'DELETE_COUNTER_INSTANCE_PREE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
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
END;

PROCEDURE DELETE_COUNTER_INSTANCE_POST (
    p_api_version                IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_SOURCE_OBJECT_ID           IN   NUMBER,
    p_SOURCE_OBJECT_CODE         IN   VARCHAR2,
    x_Return_status              OUT NOCOPY VARCHAR2,
    x_Msg_Count                  OUT NOCOPY NUMBER,
    x_Msg_Data                   OUT NOCOPY VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

End CS_COUNTERS_VUHK;

/

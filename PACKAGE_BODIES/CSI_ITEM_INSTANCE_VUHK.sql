--------------------------------------------------------
--  DDL for Package Body CSI_ITEM_INSTANCE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ITEM_INSTANCE_VUHK" AS
/* $Header: jtmitemb.pls 120.2 2005/08/24 02:15:22 saradhak noship $ */

PROCEDURE create_item_instance_pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY  VARCHAR2
 )
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

PROCEDURE create_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_ITEM_INSTANCE_POST'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.CREATE_ITEM_INSTANCE_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''CREATE_ITEM_INSTANCE_POST'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.CREATE_ITEM_INSTANCE_POST''); ' ||
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
     ' begin ' || 'JTM_ITEM_INSTANCE_VUHK' || '.' || 'CREATE_ITEM_INSTANCE_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
              ' when others then ' ||
              l_strLogBuffer ||
            ' end;  ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_instance_rec.instance_id);
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

PROCEDURE update_item_instance_pre
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT    NOCOPY csi_datastructures_pub.id_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000) :=
        ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_ITEM_INSTANCE_PRE'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.UPDATE_ITEM_INSTANCE_PRE''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_ITEM_INSTANCE_PRE'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.UPDATE_ITEM_INSTANCE_PRE''); ' ||
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
     ' begin ' || 'JTM_ITEM_INSTANCE_VUHK' || '.' || 'UPDATE_ITEM_INSTANCE_PRE' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
     ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_instance_rec.INSTANCE_ID);
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

PROCEDURE update_item_instance_post
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false
    ,p_validation_level      IN     NUMBER   := fnd_api.g_valid_level_full
    ,p_instance_rec          IN     csi_datastructures_pub.instance_rec
    ,p_ext_attrib_values_tbl IN     csi_datastructures_pub.extend_attrib_values_tbl
    ,p_party_tbl             IN     csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN     csi_datastructures_pub.party_account_tbl
    ,p_pricing_attrib_tbl    IN     csi_datastructures_pub.pricing_attribs_tbl
    ,p_org_assignments_tbl   IN     csi_datastructures_pub.organization_units_tbl
    ,p_asset_assignment_tbl  IN     csi_datastructures_pub.instance_asset_tbl
    ,p_txn_rec               IN     csi_datastructures_pub.transaction_rec
    ,x_instance_id_lst       OUT    NOCOPY csi_datastructures_pub.id_tbl
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY  NUMBER
    ,x_msg_data              OUT    NOCOPY  VARCHAR2
 ) IS
  l_JTM_enable_prof_value varchar2(255);
  l_cursorid   INTEGER;
  l_execute_status INTEGER;
  l_strBuffer   VARCHAR2(2000);
  l_strLogBuffer VARCHAR2(2000)
          := ' begin ' ||
        ' JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_ITEM_INSTANCE_POST'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''Error:'' || SQLERRM ' || ',' ||
           ' 1,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.UPDATE_ITEM_INSTANCE_POST''); ' ||
        ' exception ' ||
            ' when others then null;' ||
        ' end; ';

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin
         EXECUTE IMMEDIATE
         ' begin JTM_MESSAGE_LOG_PKG.log_msg(' ||
           ' ''UPDATE_ITEM_INSTANCE_POST'', ' ||
           ' ''CSI_ITEM_INSTANCE_VUHK'', ' ||
           ' ''The procedure is called.'', ' ||
           ' 4,' ||
           ' ''JTM.CSI_ITEM_INSTANCE_VUHK.UPDATE_ITEM_INSTANCE_POST''); ' ||
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
     ' begin ' || 'JTM_ITEM_INSTANCE_VUHK' || '.' || 'UPDATE_ITEM_INSTANCE_POST' ||
            '(:1,:2,:3,:4,:5,:6,:7,:8); ' ||
            ' exception ' ||
            '   when others then ' ||
            l_strLogBuffer ||
            ' end; ';
         DBMS_SQL.parse (l_cursorid, l_strBuffer, DBMS_SQL.v7);
         DBMS_SQL.bind_variable (l_cursorid, ':1', p_api_version);
         DBMS_SQL.bind_variable (l_cursorid, ':2', P_Init_Msg_List);
         DBMS_SQL.bind_variable (l_cursorid, ':3', P_Commit);
         DBMS_SQL.bind_variable (l_cursorid, ':4', p_validation_level);
         DBMS_SQL.bind_variable (l_cursorid, ':5', p_instance_rec.INSTANCE_ID);
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

PROCEDURE expire_item_instance_pre
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN      csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT     NOCOPY csi_datastructures_pub.id_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
 )
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

PROCEDURE expire_item_instance_post
 (
      p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2 := fnd_api.g_false
     ,p_init_msg_list       IN      VARCHAR2 := fnd_api.g_false
     ,p_validation_level    IN      NUMBER   := fnd_api.g_valid_level_full
     ,p_instance_rec        IN      csi_datastructures_pub.instance_rec
     ,p_expire_children     IN      VARCHAR2 := fnd_api.g_false
     ,p_txn_rec             IN      csi_datastructures_pub.transaction_rec
     ,x_instance_id_lst     OUT     NOCOPY  csi_datastructures_pub.id_tbl
     ,x_return_status       OUT     NOCOPY VARCHAR2
     ,x_msg_count           OUT     NOCOPY NUMBER
     ,x_msg_data            OUT     NOCOPY VARCHAR2
 )
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
END;

END CSI_ITEM_INSTANCE_VUHK;

/

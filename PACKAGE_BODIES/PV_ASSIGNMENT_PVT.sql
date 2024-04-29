--------------------------------------------------------
--  DDL for Package Body PV_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ASSIGNMENT_PVT" as
/* $Header: pvasgnpb.pls 120.9 2006/12/06 20:49:18 dhii noship $ */
-- Start of Comments

-- Package name     : PV_ASSIGNMENT_PVT
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ASSIGNMENT_PVT ';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvasgnpb.pls';


-- ----------------------------------------------------------------------------------
-- ORA-00054: resource busy and acquire with NOWAIT specified
-- ----------------------------------------------------------------------------------
g_e_resource_busy EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_resource_busy, -54);


-- -----------------------------------------------------------------------------------
-- ======================== Private Procedure Declaration ============================
-- -----------------------------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
);


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);



-- -----------------------------------------------------------------------------------
-- ============================= Procedure Body ======================================
-- -----------------------------------------------------------------------------------

PROCEDURE Create_Oppty_Routing_Log_Row
(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_oppty_routing_log_rec  IN   oppty_routing_log_rec_type,
    X_Return_Status          OUT  NOCOPY VARCHAR2,
    X_Msg_Count              OUT  NOCOPY NUMBER,
    X_Msg_Data               OUT  NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Create_Oppty_Routing_Log_Row';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   CURSOR C2 IS SELECT PV_OPPTY_ROUTING_LOGS_S.nextval FROM sys.dual;

   CURSOR get_org_id ( pc_user_id NUMBER)
   IS
   SELECT business_group_id
     FROM per_all_people_f a
        , fnd_user b
    WHERE b.user_id = pc_user_id
    AND   b.employee_id = a.person_id;

    l_routing_log_id       NUMBER;
    l_business_unit_id     NUMBER;



BEGIN
      -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN C2;
   FETCH C2 INTO l_routing_log_id;
   CLOSE C2;

   IF P_oppty_routing_log_rec.vendor_user_id IS NOT NULL THEN

      OPEN  get_org_id(P_oppty_routing_log_rec.vendor_user_id);
      FETCH get_org_id INTO l_business_unit_id;
      CLOSE get_org_id;

   END IF;

   INSERT INTO pv_oppty_routing_logs
   (
       OPPTY_ROUTING_LOG_ID
     , EVENT
     , LEAD_ID
     , LEAD_WORKFLOW_ID
     , ROUTING_TYPE
     , LATEST_ROUTING_FLAG
     , BYPASS_CM_FLAG
     , LEAD_ASSIGNMENT_ID
     , EVENT_DATE
     , VENDOR_USER_ID
     , PT_CONTACT_USER_ID
     , USER_RESPONSE
     , REASON_CODE
     , USER_TYPE
     , VENDOR_BUSINESS_UNIT_ID
   )
   VALUES
   (
       l_routing_log_id
     , P_oppty_routing_log_rec.event
     , P_oppty_routing_log_rec.lead_id
     , P_oppty_routing_log_rec.lead_workflow_id
     , P_oppty_routing_log_rec.routing_type
     , P_oppty_routing_log_rec.latest_routing_flag
     , P_oppty_routing_log_rec.bypass_cm_flag
     , P_oppty_routing_log_rec.lead_assignment_id
     , P_oppty_routing_log_rec.event_date
     , P_oppty_routing_log_rec.vendor_user_id
     , P_oppty_routing_log_rec.pt_contact_user_id
     , P_oppty_routing_log_rec.user_response
     , P_oppty_routing_log_rec.reason_code
     , P_oppty_routing_log_rec.user_type
     , l_business_unit_id
   );
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Create_Oppty_Routing_Log_Row;

PROCEDURE Create_assignment_log_row(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_assignment_log_rec     IN   assignment_log_rec_type,
    X_assignment_id          OUT  NOCOPY NUMBER,
    X_Return_Status          OUT  NOCOPY VARCHAR2,
    X_Msg_Count              OUT  NOCOPY NUMBER,
    X_Msg_Data               OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Create_assignment_log_row';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   CURSOR C2 IS SELECT PV_ASSIGNMENT_LOGS_S.nextval FROM sys.dual;
   l_assignment_log_id number;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   OPEN C2;
   FETCH C2 INTO l_assignment_log_id;
   CLOSE C2;

   INSERT into pv_assignment_logs (
      ASSIGNMENT_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      LEAD_ASSIGNMENT_ID,
      PARTNER_ID,
      ASSIGN_SEQUENCE,
      CM_ID,
      LEAD_ID,
      DURATION,
      FROM_LEAD_STATUS,
      TO_LEAD_STATUS,
      STATUS,
      STATUS_DATE,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      WF_PT_USER,
      WF_CM_USER,
      WORKFLOW_ID,
      ERROR_TXT,
      TRANS_TYPE,
      STATUS_CHANGE_COMMENTS
   ) values (
      l_assignment_log_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      1,
      p_assignment_log_rec.LEAD_ASSIGNMENT_ID,
      p_assignment_log_rec.PARTNER_ID,
      p_assignment_log_rec.ASSIGN_SEQUENCE,
      p_assignment_log_rec.CM_ID,
      p_assignment_log_rec.LEAD_ID,
      p_assignment_log_rec.DURATION,
      p_assignment_log_rec.FROM_LEAD_STATUS,
      p_assignment_log_rec.TO_LEAD_STATUS,
      p_assignment_log_rec.STATUS,
      p_assignment_log_rec.STATUS_DATE,
      p_assignment_log_rec.WF_ITEM_TYPE,
      p_assignment_log_rec.WF_ITEM_KEY,
      p_assignment_log_rec.WF_PT_USER,
      p_assignment_log_rec.WF_CM_USER,
      p_assignment_log_rec.WORKFLOW_ID,
      p_assignment_log_rec.ERROR_TXT,
      p_assignment_log_rec.TRANS_TYPE,
      p_assignment_log_rec.STATUS_CHANGE_COMMENTS
   );

   x_assignment_id := l_assignment_log_id;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

End Create_assignment_log_row;



PROCEDURE update_party_response(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_rowid                  IN   ROWID,
    p_lead_assignment_id     IN   NUMBER,
    p_party_resource_id      IN   NUMBER,
    p_response               IN   VARCHAR2,
    p_reason_code            IN   VARCHAR2,
    p_rank                   IN   NUMBER,
    X_Return_Status          OUT  NOCOPY VARCHAR2,
    X_Msg_Count              OUT  NOCOPY NUMBER,
    X_Msg_Data               OUT  NOCOPY VARCHAR2
    )

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'update_party_response';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_lead_assignment_id    number;
   l_party_resource_id     number;
   l_response              varchar2(30);

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;


   update pv_party_notifications
   set resource_response   = p_response,
       response_date       = sysdate,
       object_version_number = object_version_number + 1,
       last_update_date    = sysdate,
       last_updated_by     = FND_GLOBAL.user_id,
       last_update_login   = FND_GLOBAL.login_id
   where  rowid   = p_rowid
   returning lead_assignment_id, resource_id
   into l_lead_assignment_id, l_party_resource_id;

   IF (SQL%NOTFOUND) THEN
       fnd_message.SET_NAME('PV', 'Cannot find row to update');
       fnd_msg_pub.ADD;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (l_lead_assignment_id <> p_lead_assignment_id or
       l_party_resource_id  <> p_party_resource_id )
   then
       fnd_message.SET_NAME('PV', 'Updated wrong row');
       fnd_msg_pub.ADD;

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_response in (pv_assignment_pub.g_la_status_cm_added, pv_assignment_pub.g_la_status_cm_add_app_for_pt) then
      l_response := pv_assignment_pub.g_la_status_cm_approved;
   else
      l_response := p_response;
   end if;

   UpdateAssignment (
      p_api_version_number  => 1.0
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_action             => pv_assignment_pub.g_asgn_action_status_update
      ,p_lead_assignment_id => p_lead_assignment_id
      ,p_status_date        => sysdate
      ,p_status             => l_response
      ,p_reason_code        => p_reason_code
      ,p_rank               => p_rank
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,x_return_status      => x_return_status);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

End update_party_response;


PROCEDURE bulk_set_party_notify_id(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_itemtype               IN   VARCHAR2,
    p_itemkey                IN   VARCHAR2,
    p_notify_type            IN   VARCHAR2,
    X_Return_Status          OUT  NOCOPY VARCHAR2,
    X_Msg_Count              OUT  NOCOPY NUMBER,
    X_Msg_Data               OUT  NOCOPY VARCHAR2
    )

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'bulk_set_party_notify_id';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_partner_id          number;
   l_size                number;
   l_notify_id_tbl       pv_assignment_pub.g_number_table_type;
   l_party_notify_id_tbl pv_assignment_pub.g_number_table_type;

   cursor lc_get_notified (pc_itemtype       varchar2,
                           pc_itemkey        varchar2,
                           pc_partner_id     number,
                           pc_notify_type    varchar2) is
select c.notification_id,
          b.party_notification_id
   from   pv_party_notifications b,
          wf_item_activity_statuses d,
          wf_notifications c,
	  fnd_user usr
   where  b.wf_item_type        = pc_itemtype
   and    b.wf_item_key         = pc_itemkey
   and    b.notification_type   = pc_notify_type
   and    d.item_type           = b.wf_item_type
   and    d.item_key            = b.wf_item_key
   and    d.assigned_user       = 'PV' || pc_notify_type || pc_itemkey || '+' || pc_partner_id
   and    b.user_id             = usr.user_id
   and    usr.user_name         = c.original_recipient
   and    c.context             = pc_itemtype || ':' || pc_itemkey || ':' || d.process_activity;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_partner_id := nvl(wf_engine.GetItemAttrNumber(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => pv_workflow_pub.g_wf_attr_partner_id), 0);

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Get notify id for partner_id: ' || l_partner_id);
      fnd_msg_pub.Add;
   END IF;

   open lc_get_notified (pc_itemtype   => p_itemtype,
                       pc_itemkey      => p_itemkey,
                       pc_partner_id   => l_partner_id,
                       pc_notify_type  => p_notify_type);
   l_size := 0;
   l_notify_id_tbl        := pv_assignment_pub.g_number_table_type();
   l_party_notify_id_tbl  := pv_assignment_pub.g_number_table_type();

   loop

      l_notify_id_tbl.extend;
      l_party_notify_id_tbl.extend;
      l_size := l_size + 1;

      fetch lc_get_notified into l_notify_id_tbl(l_size), l_party_notify_id_tbl(l_size);
      exit when lc_get_notified%notfound;

   end loop;
   close lc_get_notified;
   l_notify_id_tbl.trim;
   l_party_notify_id_tbl.trim;

   if l_party_notify_id_tbl.count > 0 then

   forall j in 1 .. l_party_notify_id_tbl.count
      update pv_party_notifications
      set notification_id   = l_notify_id_tbl(j),
          object_version_number = object_version_number + 1,
          last_update_date  = sysdate,
          last_updated_by   = FND_GLOBAL.user_id,
          last_update_login = FND_GLOBAL.login_id
      where party_notification_id = l_party_notify_id_tbl(j);

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

End bulk_set_party_notify_id;


procedure UpdateAssignment (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_action              IN  VARCHAR2
   ,p_lead_assignment_id  IN  number
   ,p_status_date         IN  DATE
   ,p_status              IN  VARCHAR2
   ,p_reason_code         IN  VARCHAR2
   ,p_rank                IN  NUMBER
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
   ,x_return_status       OUT NOCOPY VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'UpdateAssignment';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_rowid                  rowid;
   l_assignment_log_id      number;
   l_assignment_rec         pv_assign_util_pvt.ASSIGNMENT_REC_TYPE;

   l_object_version_number  NUMBER;
   l_partner_id             NUMBER;
   l_lead_id                NUMBER;
   l_assign_sequence        NUMBER;
   l_status_date            DATE;
   l_status                 VARCHAR2(40);
   l_reason_code            VARCHAR2(30);
   l_routing_status         VARCHAR2(30);
   l_wf_item_type           VARCHAR2(40);
   l_wf_item_key            VARCHAR2(40);
   l_lead_workflow_id       NUMBER;
   l_routing_type           VARCHAR2(40);
   l_latest_routing_flag    VARCHAR2(10);
   l_bypass_cm_flag         VARCHAR2(10);
   l_user_category          VARCHAR2(40);
   l_notification_type      VARCHAR2(40);

   l_partner_access_code          varchar2(30);
   l_related_party_access_code    varchar2(30);
   l_org_to_vend_party_id   NUMBER := NULL;
   l_oppty_routing_log_rec  oppty_routing_log_rec_type;


   CURSOR lc_get_assign_row (pc_lead_assignment_id number) IS
     SELECT
         a.rowid,
         a.object_version_number,
         a.partner_id,
         a.assign_sequence,
         a.lead_id,
         a.status,
         a.reason_code ,
         a.status_date,
         a.wf_item_type,
         a.wf_item_key,
         a.partner_access_code,
         a.related_party_access_code,
         b.routing_status,
         b.lead_workflow_id,
         b.routing_type,
         b.latest_routing_flag,
         b.bypass_cm_ok_flag
      FROM  pv_lead_assignments a, pv_lead_workflows b
      WHERE a.lead_assignment_id = pc_lead_assignment_id
      AND   a.wf_item_type       = b.wf_item_type
      AND   a.wf_item_key        = b.wf_item_key;

  CURSOR lc_get_notify_type ( pc_wf_item_type VARCHAR2
                           ,  pc_wf_item_key VARCHAR2 )
  IS
    SELECT notification_type
    FROM   pv_party_notifications a
    WHERE a.wf_item_key  = pc_wf_item_key
    AND   a.wf_item_type = pc_wf_item_type
    AND   a.user_id = fnd_global.user_id
    AND   a.notification_type=  pv_assignment_pub.g_notify_type_matched_to;

    /*SELECT notification_type
    FROM   pv_party_notifications a, pv_assignment_logs c
    WHERE  a.user_id      = c.created_by
    AND    a.wf_item_key  = c.wf_item_key
    AND    a.wf_item_key  = pc_wf_item_key
    AND    a.wf_item_type = pc_wf_item_type;
    */

  CURSOR lc_get_vad_assign (pc_lead_assignment_id number) IS
  select pv_assign.lead_assignment_id
  from   hz_relationships         EMP_TO_ORG,
         hz_relationships         ORG_TO_VEND,
         hz_organization_profiles HZOP,
         pv_lead_assignments      PV_ASSIGN,
       	 pv_lead_workflows        PV_LEAD_WF,
	 jtf_rs_resource_extns    LEAD_SOURCE,
	 pv_enty_attr_values 	  PEAV
  where  PV_ASSIGN.lead_assignment_id   = pc_lead_assignment_id
  and    PV_ASSIGN.wf_item_type   	= PV_LEAD_WF.wf_item_type
  and	 PV_ASSIGN.wf_item_key	 	= PV_LEAD_WF.wf_item_key
  and    PV_LEAD_WF.created_by		= LEAD_SOURCE.user_id
  and    EMP_TO_ORG.party_id            = LEAD_SOURCE.source_id
  and    EMP_TO_ORG.subject_table_name  = 'HZ_PARTIES'
  and    EMP_TO_ORG.object_table_name   = 'HZ_PARTIES'
  and    EMP_TO_ORG.directional_flag    = 'F'
  and    EMP_TO_ORG.status              in ('A', 'I')
  and    EMP_TO_ORG.relationship_code   = 'EMPLOYEE_OF'
  and    EMP_TO_ORG.relationship_type   = 'EMPLOYMENT'
  and    EMP_TO_ORG.object_id           = ORG_TO_VEND.subject_id
  and    ORG_TO_VEND.subject_table_name = 'HZ_PARTIES'
  and    ORG_TO_VEND.object_table_name  = 'HZ_PARTIES'
  and    ORG_TO_VEND.status             in ('A', 'I')
  and    ORG_TO_VEND.relationship_type  = 'PARTNER'
  and    ORG_TO_VEND.object_id          = HZOP.party_id
  and    HZOP.internal_flag             = 'Y'
  and    HZOP.effective_end_date       is null
  and    ORG_TO_VEND.party_id 	        = PV_ASSIGN.related_party_id
  and 	 PEAV.entity_id(+) 	        = ORG_TO_VEND.party_id
  and    PEAV.entity(+) 	        = 'PARTNER'
  and    PEAV.attribute_id(+) 		= 3
  and    PEAV.attr_value		= 'VAD';

  CURSOR lc_get_user_type (pc_user_id NUMBER) IS
   SELECT extn.category
   FROM   fnd_user fuser,
          jtf_rs_resource_extns extn
   WHERE  fuser.user_id = pc_user_id
   AND    fuser.user_id   = extn.user_id;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. ID: ' || p_lead_assignment_id || ' Action: ' || p_action);
      fnd_msg_pub.Add;

      if p_action = pv_assignment_pub.g_asgn_action_status_update then

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Name('PV', 'Status: ' || p_status);
         fnd_msg_pub.Add;

      end if;

   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   -- validate p_action modes

   if p_action is NULL or
      p_action not in (pv_assignment_pub.g_asgn_action_status_update,
                       pv_assignment_pub.g_asgn_action_move_to_log) then

      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT', 'Invalid action mode:' || nvl(p_action, 'NULL') );
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   OPEN lc_get_assign_row(pc_lead_assignment_id => p_lead_assignment_id);

   FETCH lc_get_assign_row INTO
      l_rowid,
      l_object_version_number,
      l_partner_id,
      l_assign_sequence,
      l_lead_id,
      l_status,
      l_reason_code ,
      l_status_date,
      l_wf_item_type,
      l_wf_item_key,
      l_partner_access_code,
      l_related_party_access_code,
      l_routing_status,
      l_lead_workflow_id,
      l_routing_type,
      l_latest_routing_flag,
      l_bypass_cm_flag;
   CLOSE lc_get_assign_row;

   IF (l_rowid is NULL) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT', 'Cannot find row');
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if p_action = pv_assignment_pub.g_asgn_action_status_update then

      if l_routing_status in (pv_assignment_pub.g_r_status_active, pv_assignment_pub.g_r_status_offered) then

         -- we are not doing this for matched status here because partners/related_party_id access do not
         -- change until all CMs have approved/rejected or timedout
         -- that's why we are doing it in set_offered_attributes API

         if p_status in ( pv_assignment_pub.g_la_status_pt_rejected,
                          pv_assignment_pub.g_la_status_pt_timeout,
                          pv_assignment_pub.g_la_status_pt_abandoned,
                          pv_assignment_pub.g_la_status_offer_withdrawn,
                          pv_assignment_pub.g_la_status_lost_chance) then

             OPEN lc_get_vad_assign(pc_lead_assignment_id => p_lead_assignment_id);
             FETCH lc_get_vad_assign into l_org_to_vend_party_id;
             CLOSE lc_get_vad_assign;

             IF l_org_to_vend_party_id is NULL THEN
             	l_related_party_access_code := pv_assignment_pub.g_assign_access_none;
             END IF;

             l_partner_access_code       := pv_assignment_pub.g_assign_access_none;

         elsif p_status in ( pv_assignment_pub.g_la_status_pt_approved,
                             pv_assignment_pub.g_la_status_cm_app_for_pt) then

            -- note: status will never be cm_add_app_for_pt because we change it to cm_app_for_pt
            --       and that status is only done during matched mode

            l_partner_access_code       := pv_assignment_pub.g_assign_access_update;
            l_related_party_access_code := pv_assignment_pub.g_assign_access_update;

         end if;

      end if;

      update pv_lead_assignments
      set    status_date                 = p_status_date,
             status                      = p_status,
             reason_code                 = p_reason_code ,
             assign_sequence             = nvl(p_rank, assign_sequence),
             partner_access_code         = l_partner_access_code,
             related_party_access_code   = decode(nvl(related_party_id,-999), -999, null, l_related_party_access_code),
             object_version_number       = object_version_number + 1,
             last_update_date            = sysdate,
             last_updated_by             = FND_GLOBAL.user_id,
             last_update_login           = FND_GLOBAL.login_id
      where  rowid   = l_rowid;

      IF (SQL%NOTFOUND) THEN
         fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.SET_TOKEN('TEXT', 'Cannot find row to update');
         fnd_msg_pub.ADD;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_assignment_rec.lead_id    := l_lead_id;
      l_assignment_rec.partner_id := l_partner_id;
      l_assignment_rec.status     := p_status;

      pv_assign_util_pvt.Log_assignment_status (
       p_api_version_number  => 1.0,
       p_init_msg_list       => FND_API.G_FALSE,
       p_commit              => FND_API.G_FALSE,
       p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
       p_assignment_rec      => l_assignment_rec,
       x_return_status       => x_return_status,
       x_msg_count           => x_msg_count,
       x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
      end if;
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'START:Logging in Opportunity Routing Log ');
        fnd_msg_pub.Add;
      END IF;

--    vansub
--    Start :Rivendell Update
--    Logging Routing Changes
      IF p_status <>   pv_assignment_pub.g_la_status_cm_bypassed THEN

        IF p_status =   pv_assignment_pub.g_la_status_cm_rejected THEN
           l_oppty_routing_log_rec.event                   := 'ASSIGN_REJECT';
        ELSIF p_status IN ( pv_assignment_pub.g_la_status_cm_approved
                          , pv_assignment_pub.g_la_status_cm_app_for_pt
                          , pv_assignment_pub.g_la_status_cm_timeout
                          )
        THEN
           l_oppty_routing_log_rec.event                   := 'ASSIGN_ACCEPT';
        ELSIF  p_status =  pv_assignment_pub.g_la_status_pt_rejected THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_DECLINE';
        ELSIF  p_status =  pv_assignment_pub.g_la_status_pt_timeout THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_RECYCLE';
        ELSIF p_status =   pv_assignment_pub.g_la_status_pt_approved THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_ACCEPT';
        ELSIF p_status =   pv_assignment_pub.g_la_status_pt_abandoned THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_ABANDON';
        ELSIF p_status IN ( pv_assignment_pub.g_la_status_offer_withdrawn
                          , pv_assignment_pub.g_la_status_match_withdrawn )
        THEN
           l_oppty_routing_log_rec.event                   := 'ASSIGN_WITHDRAW';
        ELSIF p_status =  pv_assignment_pub.g_la_status_active_withdrawn THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_WITHDRAW';
        ELSIF p_status =  pv_assignment_pub.g_la_status_lost_chance THEN
           l_oppty_routing_log_rec.event                   := 'OPPTY_TAKEN';
        END IF;
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
           fnd_message.Set_Token('TEXT', 'Status : '||p_status||' Event : '||l_oppty_routing_log_rec.event);
           fnd_msg_pub.Add;
        END IF;
        l_oppty_routing_log_rec.lead_id                 := l_lead_id;
        l_oppty_routing_log_rec.lead_workflow_id        := l_lead_workflow_id;
        l_oppty_routing_log_rec.routing_type            := l_routing_type;
        l_oppty_routing_log_rec.latest_routing_flag     := l_latest_routing_flag;
        l_oppty_routing_log_rec.bypass_cm_flag          := l_bypass_cm_flag;
        l_oppty_routing_log_rec.lead_assignment_id      := p_lead_assignment_id;
        l_oppty_routing_log_rec.event_date              := p_status_date;
        l_oppty_routing_log_rec.user_response           := p_status;

--    Setting Vendor and Partner User ID
        OPEN  lc_get_user_type (FND_GLOBAL.user_id);
        FETCH lc_get_user_type INTO l_user_category;
        CLOSE lc_get_user_type;

        IF  l_user_category = PV_ASSIGNMENT_PUB.g_resource_employee  THEN
            l_oppty_routing_log_rec.vendor_user_id          := FND_GLOBAL.user_id;
            l_oppty_routing_log_rec.pt_contact_user_id      := NULL;
        ELSIF l_user_category = PV_ASSIGNMENT_PUB.g_resource_party THEN
            l_oppty_routing_log_rec.vendor_user_id          := NULL;
            l_oppty_routing_log_rec.pt_contact_user_id      := FND_GLOBAL.user_id;
        END IF;
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
           fnd_message.Set_Token('TEXT', 'Vendor User ID '||l_oppty_routing_log_rec.vendor_user_id);
           fnd_msg_pub.Add;
           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
           fnd_message.Set_Token('TEXT', 'Partner User ID '||l_oppty_routing_log_rec.pt_contact_user_id);
           fnd_msg_pub.Add;
        END IF;--    Setting Vendor and Partner User ID to SYSTEM and user type also to SYSTEM
        IF p_status IN ( pv_assignment_pub.g_la_status_cm_timeout
                       , pv_assignment_pub.g_la_status_pt_timeout
                       , pv_assignment_pub.g_la_status_lost_chance
                       )
        THEN
           l_oppty_routing_log_rec.vendor_user_id          := NULL;
           l_oppty_routing_log_rec.pt_contact_user_id      := NULL;
           l_oppty_routing_log_rec.user_type               := 'SYSTEM';
        ELSIF p_status IN ( pv_assignment_pub.g_la_status_cm_approved
                          , pv_assignment_pub.g_la_status_cm_app_for_pt
                          , pv_assignment_pub.g_la_status_cm_rejected
                          )
        THEN
           l_oppty_routing_log_rec.user_type               := 'CM';
        ELSIF  p_status IN ( pv_assignment_pub.g_la_status_pt_approved
                           , pv_assignment_pub.g_la_status_pt_abandoned
                           , pv_assignment_pub.g_la_status_pt_rejected)
        THEN
           l_oppty_routing_log_rec.user_type               := 'PT';
        ELSIF p_status IN ( pv_assignment_pub.g_la_status_offer_withdrawn
                          , pv_assignment_pub.g_la_status_match_withdrawn
                          , pv_assignment_pub.g_la_status_active_withdrawn)
        THEN

--        When Opportunity is withdrawn by SalesRep the record does not
--        make into pv_party_notifications. Only CM and PT will be in Party Notifications
--        Hence retrieving the Salesrep withdraw from pv_assignment_logs

           OPEN  lc_get_notify_type(l_wf_item_type, l_wf_item_key);
           FETCH lc_get_notify_type INTO l_notification_type;
           CLOSE lc_get_notify_type;

           IF  l_notification_type IS NULL THEN
               l_oppty_routing_log_rec.user_type               := 'SR';
           ELSE
               l_oppty_routing_log_rec.user_type               := 'CM';
           END IF;
        END IF;

        IF  p_status IN ( pv_assignment_pub.g_la_status_pt_rejected
                        , pv_assignment_pub.g_la_status_pt_abandoned )
        THEN
            l_oppty_routing_log_rec.reason_code  := p_reason_code;
        ELSE
            l_oppty_routing_log_rec.reason_code  := NULL;
        END IF;


        pv_assignment_pvt.Create_Oppty_Routing_Log_Row (
           p_api_version_number    => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
           P_oppty_routing_log_rec => l_oppty_routing_log_rec,
           x_return_status         => x_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data);

        IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

--    vansub
--    End :Rivendell Update
--    Logging Routing Changes   elsif p_action = pv_assignment_pub.g_asgn_action_move_to_log then
   elsif p_action = pv_assignment_pub.g_asgn_action_move_to_log then

      delete from pv_lead_assignments where rowid = l_rowid;

      IF (SQL%ROWCOUNT = 0) THEN
         fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.SET_TOKEN('TEXT', 'Cannot find row to delete');
         fnd_msg_pub.ADD;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   end if;

      pv_leadlog_pvt.InsertAssignLogRow (
         X_Rowid                   =>  l_rowid,
         x_assignlog_ID            =>  l_assignment_log_id,
         p_Lead_assignment_ID      =>  p_lead_assignment_ID,
         p_Last_Updated_By         =>  FND_GLOBAL.USER_ID,
         p_Last_Update_Date        =>  SYSDATE,
         p_Last_Update_Login       =>  FND_GLOBAL.LOGIN_ID,
         p_Created_By              =>  FND_GLOBAL.USER_ID,
         p_Creation_Date           =>  SYSDATE,
         p_Object_Version_Number   =>  l_object_version_number,
         p_lead_id                 =>  l_lead_id,
         p_partner_id              =>  l_partner_id,
         p_assign_sequence         =>  l_assign_sequence,
         p_status_date             =>  l_status_date,
         p_status                  =>  l_status,
         p_wf_item_type            =>  l_wf_item_type,
         p_wf_item_key             =>  l_wf_item_key,
         p_trans_type              =>  NULL,
         p_error_txt               =>  NULL,
         p_status_change_comments  =>  NULL,
         p_cm_id                   =>  NULL,
         p_duration                =>  NULL,
         p_wf_pt_user              =>  NULL,
         p_wf_cm_user              =>  NULL,
         x_return_status           =>  x_return_status);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION
   -- -------------------------------------------------------------------------------
   -- pklin
   -- Capture "ORA-00054: resource busy and acquire with NOWAIT specified" error
   -- so that no other user/session can update the row in pv_lead_assignments
   -- when the current session has not completed yet.
   -- -------------------------------------------------------------------------------
   WHEN g_e_resource_busy THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

      RAISE;


   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end UpdateAssignment;


procedure removeRejectedFromAccess (
      p_api_version_number   IN  NUMBER
      ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
      ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
      ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
      ,p_itemtype            IN  VARCHAR2
      ,p_itemkey             IN  VARCHAR2
      ,p_partner_id          IN  VARCHAR2
      ,x_msg_count           OUT NOCOPY NUMBER
      ,x_msg_data            OUT NOCOPY VARCHAR2
      ,x_return_status       OUT NOCOPY VARCHAR2) is



   CURSOR lc_get_routing_status ( pc_itemtype VARCHAR2
                                , pc_itemkey  VARCHAR2 )
   IS
     SELECT routing_status
     FROM   pv_lead_workflows
     WHERE  wf_item_type       = pc_itemtype
       AND  wf_item_key        = pc_itemkey;

   -- lc_get_reject_accesses + lc_get_reject_accesses_pt
   -- will select all cm, partner contact, partner org that are in the assignment table
   -- associated with the opportunity for all cm_rejected/pt_rejected/pt_timeout/lost_chance/
   -- match_withdrawn/offer_withdrawn partners
   -- it will not select anyone/thing not in assignment table (which is perfect)

   cursor lc_get_reject_accesses(pc_itemtype varchar2, pc_itemkey varchar2) is
      select
            a1.lead_id, d.user_name access_user, a2.resource_id
      from
            pv_lead_assignments    a1,
            pv_party_notifications a2,
            jtf_rs_resource_extns  b,
            as_accesses_all        c,
            fnd_user               d
      where
            a1.wf_item_type       = pc_itemtype
      and   a1.wf_item_key        = pc_itemkey
      and   a1.status            in ( pv_assignment_pub.g_la_status_cm_rejected,
                                      pv_assignment_pub.g_la_status_pt_rejected,
                                      pv_assignment_pub.g_la_status_pt_timeout,
                                      pv_assignment_pub.g_la_status_lost_chance,
                                      pv_assignment_pub.g_la_status_match_withdrawn,
                                      pv_assignment_pub.g_la_status_offer_withdrawn)
      and   not exists
            (select 1 from pv_lead_assignments la , pv_party_notifications pn
             where la.wf_item_type = pc_itemtype
             and   la.wf_item_key  = pc_itemkey
             and   la.status       in (pv_assignment_pub.g_la_status_cm_approved,
                                       pv_assignment_pub.g_la_status_pt_approved,
                                       pv_assignment_pub.g_la_status_pt_created,
                                       pv_assignment_pub.g_la_status_cm_app_for_pt,
                                       pv_assignment_pub.g_la_status_cm_timeout)
             and   la.lead_assignment_id = pn.lead_assignment_id
             and   pn.resource_id = a2.resource_id)
      and   a1.lead_assignment_id = a2.lead_assignment_id
      and   a2.resource_id        = b.resource_id
      and   b.user_id             = d.user_id
      and   a2.resource_id        = c.salesforce_id
      and   a1.lead_id            = c.lead_id;


   cursor lc_get_reject_accesses_pt(pc_itemtype varchar2, pc_itemkey varchar2) is
      select
            a.lead_id, 'PARTNER', b.resource_id
      from
            pv_lead_assignments   a,
            jtf_rs_resource_extns b,
            as_accesses_all       c
      where
            a.wf_item_type = pc_itemtype
      and   a.wf_item_key  = pc_itemkey
      and   a.status      in ( pv_assignment_pub.g_la_status_cm_rejected,
                               pv_assignment_pub.g_la_status_pt_rejected,
                               pv_assignment_pub.g_la_status_pt_timeout,
                               pv_assignment_pub.g_la_status_lost_chance,
                               pv_assignment_pub.g_la_status_match_withdrawn,
                               pv_assignment_pub.g_la_status_offer_withdrawn)
      and   a.partner_id   = b.source_id
      and   b.category     = 'PARTNER'
      AND   B.RESOURCE_ID  = C.SALESFORCE_ID
      and   c.lead_id      = a.lead_id;

   -- this will select all cm, partner contact, partner org that are in the assignment table
   -- associated with the active opportunity for all partners when all partners have abandoned
   -- the opportunity


   cursor lc_get_pt_cm_accesses (pc_itemtype varchar2, pc_itemkey varchar2, pc_partner_id number) is
      select
            d.lead_id, 'PARTY', c.resource_id
      from
         pv_lead_assignments la,
         pv_partner_profiles pvpp,
         hz_relationships b,
         jtf_rs_resource_extns c,
         as_accesses_all d
      where
         la.wf_item_type           = pc_itemtype   and
         la.wf_item_key            = pc_itemkey    and
         la.partner_id             = pc_partner_id and
         la.partner_id             = pvpp.partner_id and
         pvpp.status               in ('A', 'I')    and
         pvpp.partner_party_id     = b.object_id   and
         b.subject_table_name      = 'HZ_PARTIES'  and
         b.object_table_name       = 'HZ_PARTIES'  and
         b.directional_flag        = 'F'           and
         b.relationship_code       = 'EMPLOYEE_OF' and
         b.relationship_type       = 'EMPLOYMENT'  and
         b.status                 in ('A', 'I')    and
         b.party_id                = c.source_id   and
         c.category                = pv_assignment_pub.g_resource_party and
         c.resource_id             = d.salesforce_id and
         d.lead_id                 = la.lead_id
      union all
      select
            a1.lead_id, d.user_name access_user, a2.resource_id
      from
            pv_lead_assignments    a1,
            pv_party_notifications a2,
            jtf_rs_resource_extns  b,
            as_accesses_all        c,
            fnd_user               d
      where
            a1.wf_item_type       = pc_itemtype
      and   a1.wf_item_key        = pc_itemkey
      and   a1.partner_id         = pc_partner_id
      and   not exists
            (select 1 from pv_lead_assignments la , pv_party_notifications pn
             where la.wf_item_type = pc_itemtype
             and   la.wf_item_key  = pc_itemkey
             and   la.partner_id  <> a1.partner_id
             and   la.status       in (pv_assignment_pub.g_la_status_cm_approved,
                                       pv_assignment_pub.g_la_status_pt_approved,
                                       pv_assignment_pub.g_la_status_pt_created,
                                       pv_assignment_pub.g_la_status_cm_app_for_pt,
                                       pv_assignment_pub.g_la_status_cm_timeout)
             and   la.lead_assignment_id = pn.lead_assignment_id
             and   pn.resource_id = a2.resource_id)
      and   a1.lead_assignment_id = a2.lead_assignment_id
      and   a2.notification_type  = pv_assignment_pub.g_notify_type_matched_to
      and   a2.resource_id        = b.resource_id
      and   b.user_id             = d.user_id
      and   a2.resource_id        = c.salesforce_id
      and   a1.lead_id            = c.lead_id
      union all
      select
            c.lead_id, 'PARTNER', b.resource_id
      from
            pv_lead_assignments   la,
            jtf_rs_resource_extns b,
            as_accesses_all       c
      where
         la.wf_item_type = pc_itemtype    and
         la.wf_item_key  = pc_itemkey     and
         la.partner_id   = pc_partner_id  and
         la.partner_id   = b.source_id    and
         b.category      = 'PARTNER'      and
         B.RESOURCE_ID   = C.SALESFORCE_ID and
         c.lead_id       = la.lead_id;

   -- this will select all  partner contact, partner org that are in the assignment table
   -- associated with the active opportunity for all partners when cm withdraws an active
   -- opportunity
   CURSOR lc_get_pt_accesses (pc_itemtype varchar2, pc_itemkey varchar2)
   IS
      SELECT
            d.lead_id, 'PARTY', c.resource_id
      FROM
         pv_lead_assignments la,
         pv_partner_profiles pvpp,
         hz_relationships b,
         jtf_rs_resource_extns c,
         as_accesses_all d
      WHERE
          la.wf_item_type           = pc_itemtype
      AND la.wf_item_key            = pc_itemkey
      AND la.partner_id             = pvpp.partner_id
      AND pvpp.status               in ('A', 'I')
      AND pvpp.partner_party_id     = b.object_id
      AND b.subject_table_name      = 'HZ_PARTIES'
      AND b.object_table_name       = 'HZ_PARTIES'
      AND b.directional_flag        = 'F'
      AND b.relationship_code       = 'EMPLOYEE_OF'
      AND b.relationship_type       = 'EMPLOYMENT'
      AND b.status                 in ('A', 'I')
      AND b.party_id                = c.source_id
      AND c.category                = pv_assignment_pub.g_resource_party
      AND c.resource_id             = d.salesforce_id
      AND d.lead_id                 = la.lead_id
      UNION ALL
      SELECT
            c.lead_id, 'PARTNER', b.resource_id
      FROM
            pv_lead_assignments   la,
            jtf_rs_resource_extns b,
            as_accesses_all       c
      WHERE
           la.wf_item_type = pc_itemtype
      AND  la.wf_item_key  = pc_itemkey
      AND  la.partner_id   = b.source_id
      AND  b.category      = 'PARTNER'
      AND  b.resource_id   = c.salesforce_id
      AND  c.lead_id       = la.lead_id;



   l_api_name            CONSTANT VARCHAR2(30) := 'removeRejectedFromAccess';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_party               varchar2(100);
   l_resource_id         number;
   l_access_id           number;
   l_lead_id             number;
   l_access_type         number;
   l_routing_status      VARCHAR2(30);
   l_rm_reject_pt_flag   boolean := false;

begin
   --
   -- Access is removed for the resources in three instances
   -- 1. When CM withdraws a matched/offered opportunity
   -- 2. When CM withdraws an active opportunity
   -- 3. When Partner Abandons the opportunity
   --
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. itemkey = ' || p_itemkey);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   OPEN  lc_get_routing_status ( pc_itemtype => p_itemtype
                               , pc_itemkey  => p_itemkey );
   FETCH lc_get_routing_status INTO l_routing_status;
   CLOSE lc_get_routing_status;

-- Partner Id will have a value only when Partner Abandons the opportunity

   IF  p_partner_id IS NULL THEN
      IF  l_routing_status = pv_assignment_pub.g_r_status_active THEN

         open lc_get_pt_accesses (pc_itemtype => p_itemtype, pc_itemkey => p_itemkey);
      ELSE
        -- this will select all cm, partner contact, partner org that are in the assignment table
        -- associated with the  cm_rejected/pt_rejected/pt_timeout/lost_chance/
        -- match_withdrawn/offer_withdrawn opportunity
         open lc_get_reject_accesses(pc_itemtype => p_itemtype, pc_itemkey => p_itemkey );
         open lc_get_reject_accesses_pt(pc_itemtype => p_itemtype, pc_itemkey => p_itemkey );
         l_rm_reject_pt_flag := true;
      END IF;
   ELSE
   -- this will select all cm, partner contact, partner org that are in the assignment table
   -- associated with the active opportunity for all partners when all partners have abandoned
   -- the opportunity

      open lc_get_pt_cm_accesses (pc_itemtype => p_itemtype, pc_itemkey => p_itemkey, pc_partner_id => p_partner_id);
   END IF;

   LOOP
      IF p_partner_id IS NULL THEN
         IF   l_routing_status = pv_assignment_pub.g_r_status_active THEN
            FETCH lc_get_pt_accesses INTO l_lead_id, l_party, l_resource_id;
            EXIT WHEN lc_get_pt_accesses%NOTFOUND;
         ELSE
            FETCH lc_get_reject_accesses INTO l_lead_id, l_party, l_resource_id;
            EXIT WHEN lc_get_reject_accesses%NOTFOUND;
         END IF;
      ELSE
         FETCH lc_get_pt_cm_accesses INTO l_lead_id, l_party, l_resource_id;
         EXIT WHEN lc_get_pt_cm_accesses%NOTFOUND;
      END IF;

      -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Removing ' || l_party || ' from accesses');
         fnd_msg_pub.Add;
      END IF;

      if l_party = 'PARTNER' then
         l_access_type := pv_assignment_pub.G_PT_ORG_ACCESS;
      else
         l_access_type := pv_assignment_pub.G_PT_ACCESS;
      end if;

      pv_assign_util_pvt.UpdateAccess(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemtype            => p_itemType,
         p_itemkey             => p_itemKey,
         p_current_username    => NULL,     --- obsolete column
         p_lead_id             => l_lead_id,
         p_customer_id         => null,
         p_address_id          => null,
         p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
         p_resource_id         => l_resource_id,
         p_access_type         => l_access_type,
         x_access_id           => l_access_id,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

   end loop;

   if l_rm_reject_pt_flag then

      LOOP
         FETCH lc_get_reject_accesses_pt INTO l_lead_id, l_party, l_resource_id;
         EXIT WHEN lc_get_reject_accesses_pt%NOTFOUND;

         -- Debug Message
         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Removing ' || l_party || ' from accesses');
            fnd_msg_pub.Add;
         END IF;

         pv_assign_util_pvt.UpdateAccess(
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => p_itemType,
            p_itemkey             => p_itemKey,
            p_current_username    => NULL,     --- obsolete column
            p_lead_id             => l_lead_id,
            p_customer_id         => null,
            p_address_id          => null,
            p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
            p_resource_id         => l_resource_id,
            p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
            x_access_id           => l_access_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end loop;
   end if;

   IF p_partner_id IS NULL THEN
      IF   l_routing_status = pv_assignment_pub.g_r_status_active THEN
           close lc_get_pt_accesses;
      ELSE
           close lc_get_reject_accesses;
           close lc_get_reject_accesses_pt;
      END IF;
   ELSE
      CLOSE lc_get_pt_cm_accesses;
   END IF;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end removeRejectedFromAccess;


procedure setTimeout  (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype            IN varchar2
   ,p_itemkey             IN varchar2
   ,p_partner_id          in number
   ,p_timeoutType         in varchar2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'setTimeout';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_query		 varchar2(2000);
   l_timeout_profile	 varchar2(100);
   l_notification_type   varchar2(100);
   l_timeout		 number         := 0;
   l_lead_id		 number ;
   lc_cursor		 pv_assignment_pub.g_ref_cursor_type;
   l_matched_due_date    date;
   l_no_of_wkend         number;
   l_offered_due_date	 date;
   l_GMT_date            date;
   l_due_date		 date;
   l_GMT_time            varchar2(60);
   l_matched_GMT_date    date;
   l_offered_GMT_date    date;
   l_matched_GMT_time    varchar2(30);
   l_offered_GMT_time    varchar2(30);
   l_server_timezone_id  number;
   l_GMT_timezone_id     number;
   l_process_rule_id     number;
   l_timeout_uom         varchar2(100);
   l_rule_timeout        number;
   l_match_timeout       number := 0;
   l_offer_timeout       number := 0;

   CURSOR lc_get_rule_timeout(lc_timeoutType varchar2,
			      lc_process_rule_id number)
   is
   SELECT  decode(lc_timeoutType, pv_assignment_pub.g_matched_timeout,
						decode(cm_timeout_uom_code,'DAYS',(cm_timeout*24),cm_timeout)
			        , pv_assignment_pub.g_offered_timeout,
					decode(partner_timeout_uom_code,'DAYS',(partner_timeout*24),partner_timeout))
   FROM   PV_ENTITY_ROUTINGS
   WHERE  PROCESS_RULE_ID = lc_process_rule_id;




begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. itemkey: ' || p_itemkey || '. Type: ' || p_timeouttype);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;


   if p_timeoutType = pv_assignment_pub.g_matched_timeout then

      l_timeout_profile   := 'PV_DEFAULT_CM_TIMEOUT';

   elsif p_timeoutType = pv_assignment_pub.g_offered_timeout then

      l_timeout_profile    := 'PV_DEFAULT_PT_TIMEOUT';

   else

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.set_token('TEXT', 'Invalid timeout type: ' || p_timeoutType);
      fnd_msg_pub.Add;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;


   l_lead_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                            itemkey  => p_itemkey,
                                            aname    => pv_workflow_pub.g_wf_attr_opportunity_id);

   l_process_rule_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
						    itemkey  => p_itemkey,
						    aname    => pv_workflow_pub.g_wf_attr_process_rule_id);


   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Process Rule ID from set timeout '||l_process_rule_id);
      fnd_msg_pub.Add;
   END IF;


   --l_server_timezone_id :=  fnd_profile.value('AMS_SYSTEM_TIMEZONE_ID');
   l_server_timezone_id :=  fnd_profile.value('SERVER_TIMEZONE_ID');



   select UPGRADE_TZ_ID into l_GMT_timezone_id
   from fnd_timezones_vl
   where timezone_code = 'GMT';

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'GMT Timezone ID '|| l_GMT_timezone_id);
      fnd_msg_pub.Add;
   END IF;

   -- -----------------------------------------------------------------------
   -- This query retrieves CM or partner timeout based on the address' country.
   -- If the address is not provided, it will retrieve the timeout from
   -- a default profile value (PV_DEFAULT_PT_TIMEOUT or PV_DEFAULT_CM_TIMEOUT).
   -- -----------------------------------------------------------------------
   l_query :=
      'select  nvl(max(timeout_period), fnd_profile.value(:bv1))*60  ' ||
      'from    pv_country_timeouts     pr ' ||
      'where   pr.timeout_type         = :1 ' ||
      'and     pr.country_code in ';

   if p_timeoutType = pv_assignment_pub.g_matched_timeout then

      l_query := l_query || ' ( select loc.country from '||
      '                      hz_locations loc, hz_party_sites pty, as_leads_all lead '||
      '                      where pty.location_id = loc.location_id '||
      '                      and pty.party_site_id = lead.address_id '||
      '                      and lead.lead_id = :2 ) ';

   elsif p_timeoutType = pv_assignment_pub.g_offered_timeout then

      l_query := l_query || ' ( select hzl.country from '||
      'hz_locations hzl, hz_party_sites hzps, pv_lead_assignments lead, '||
      'hz_parties partner, hz_relationships hzrl, hz_organization_profiles hzop '||
      'where hzl.location_id   = hzps.location_id '||
      'and   hzps.party_id     = partner.party_id '||
      'and   hzrl.party_id     = lead.partner_id '||
      'and   hzrl.subject_id   = partner.party_id '||
      'and   hzrl.object_id    = hzop.party_id '||
      'and   hzrl.subject_table_name = ''HZ_PARTIES'' '||
      'and   hzrl.object_table_name = ''HZ_PARTIES'' '||
      'and   hzrl.status in (''A'',''I'') '||
      'and   hzop.internal_flag = ''Y'' '||
      'and   hzop.effective_end_date is null '||
      'and   partner.status    = ''A'' '||
      'and   lead.wf_item_type = :2 ' ||
      'and   lead.wf_item_key  = :3  ' ||
      'and   hzps.identifying_address_flag(+) = ''Y'' ';

      if p_partner_id is not null and p_timeoutType = pv_assignment_pub.g_offered_timeout then
         l_query := l_query || ' and lead.partner_id = :4 )';
      else
         l_query := l_query || ')';
      end if;

   end if;


   if  p_timeoutType = pv_assignment_pub.g_matched_timeout then

      if l_process_rule_id is not null then

         open  lc_get_rule_timeout(p_timeoutType, l_process_rule_id);
	 fetch lc_get_rule_timeout into l_rule_timeout;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Timeout type is '||p_timeoutType||'Rule timeout is  '|| l_rule_timeout);
            fnd_msg_pub.Add;
         END IF;

	 IF lc_get_rule_timeout%FOUND and l_rule_timeout is not null THEN
	    l_timeout := l_rule_timeout*60;
         ELSE
	   close lc_get_rule_timeout;

	   open  lc_cursor for l_query using l_timeout_profile, p_timeoutType, l_lead_id;
	   fetch lc_cursor into l_timeout;
           close lc_cursor;
         END IF;

      else

       	   open  lc_cursor for l_query using l_timeout_profile, p_timeoutType, l_lead_id;
	   fetch lc_cursor into l_timeout;
           close lc_cursor;

      end if;

   elsif p_timeoutType = pv_assignment_pub.g_offered_timeout then

      if l_process_rule_id is not null then

         open  lc_get_rule_timeout(p_timeoutType, l_process_rule_id);
	      fetch lc_get_rule_timeout into l_rule_timeout;


         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Rule timeout is from auto matching rule  '|| l_rule_timeout);
            fnd_msg_pub.Add;
         END IF;

	      IF lc_get_rule_timeout%FOUND and l_rule_timeout is not null THEN
	         l_timeout := l_rule_timeout*60;
         ELSE
	          close lc_get_rule_timeout;

           if p_partner_id is not null then
              open  lc_cursor for l_query using l_timeout_profile, p_timeoutType,  p_itemtype, p_itemkey, p_partner_id;
           else
              open  lc_cursor for l_query using l_timeout_profile, p_timeoutType,  p_itemtype, p_itemkey;
           end if;

           fetch lc_cursor into l_timeout;
           close lc_cursor;
         END IF;

      else
           if p_partner_id is not null then
              open  lc_cursor for l_query using l_timeout_profile, p_timeoutType,  p_itemtype, p_itemkey, p_partner_id;
           else
              open  lc_cursor for l_query using l_timeout_profile, p_timeoutType,  p_itemtype, p_itemkey;
           end if;
           fetch lc_cursor into l_timeout;
           close lc_cursor;

      end if;


   end if;

           -- ------------------------------------------------------------------
           -- If l_timeout is NULL, i.e. no address defined for this customer and
           -- no default timeout profile specified, throw an exception.
           -- ------------------------------------------------------------------
           IF (l_timeout IS NULL AND l_timeout_profile = 'PV_DEFAULT_CM_TIMEOUT') THEN
              Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                          p_msg_name     => 'PV_NO_DEFAULT_CM_TIMEOUT',
                          p_token1       => null,
                          p_token1_value => null,
                          p_token2       => null,
                          p_token2_value => null);

              RAISE FND_API.G_EXC_ERROR;

           ELSIF (l_timeout IS NULL AND l_timeout_profile = 'PV_DEFAULT_PT_TIMEOUT') THEN
              Set_Message(p_msg_level    => FND_MSG_PUB.G_MSG_LVL_ERROR,
                          p_msg_name     => 'PV_NO_DEFAULT_PT_TIMEOUT',
                          p_token1       => null,
                          p_token1_value => null,
                          p_token2       => null,
                          p_token2_value => null);

              RAISE FND_API.G_EXC_ERROR;
           END IF;

   -- wf will disable timeout if 0.  Since what we want is to have wf
   -- follow the timeout path immediately, we set it to 1 minute

   if l_timeout = 0 then
      l_timeout := 1;
   end if;

   l_timeout := l_timeout/60/24;

      /* Get timeout date */

   pvx_utility_pvt.add_business_days
   (
     p_no_of_days     => l_timeout,
     x_business_date  => l_due_date
   );

   HZ_TIMEZONE_PUB.get_time(
     p_api_version       => 1.0,
     p_init_msg_list     => p_init_msg_list,
     p_source_tz_id      => l_server_timezone_id ,
     p_dest_tz_id        => l_GMT_timezone_id ,
     p_source_day_time   => l_due_date,
     x_dest_day_time     => l_GMT_date,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data);


   l_GMT_time  := to_char(l_GMT_date,'DD-MON-YYYY HH24:MI')||' '||'GMT';


   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'GMT timeout is  '|| l_GMT_time);
        fnd_msg_pub.Add;
   END IF;


   IF p_timeoutType = pv_assignment_pub.g_matched_timeout THEN

      update pv_lead_workflows set matched_due_date = l_due_date,
             object_version_number = object_version_number + 1
      where wf_item_type = p_itemtype
      and   wf_item_key  = p_itemkey;

      wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => pv_workflow_pub.g_wf_attr_matched_timeout,
                                   avalue   => (l_due_date-sysdate)*60*24);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => pv_workflow_pub.g_wf_attr_matched_timeout_dt,
                                   avalue   => l_GMT_time);


   ELSIF p_timeoutType = pv_assignment_pub.g_offered_timeout THEN

      update pv_lead_workflows set offered_due_date = l_due_date,
             object_version_number = object_version_number + 1
      where wf_item_type = p_itemtype
      and   wf_item_key  = p_itemkey;

      wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
               itemkey  => p_itemkey,
               aname    => pv_workflow_pub.g_wf_attr_offered_timeout,
               avalue   => (l_due_date-sysdate)*60*24);

      wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => pv_workflow_pub.g_wf_attr_offered_timeout_dt,
                                 avalue   => l_GMT_time);

   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'Timeout set to: ' || l_timeout);
      fnd_msg_pub.Add;
   END IF;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end setTimeout;


procedure SetPartnerAttributes  (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemType            in  varchar2
   ,p_itemKey             in  varchar2
   ,p_partner_id          in  NUMBER
   ,p_partner_org         in  varchar2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'SetPartnerAttributes';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_pt_contact_role_name varchar2(50);
   l_assignment_type      varchar2(30);

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Itemkey: ' || p_itemkey || '. Partner id: ' || p_partner_id);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_assignment_type := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                                   itemkey  => p_itemkey,
                                                   aname    => pv_workflow_pub.g_wf_attr_assignment_type);

   -- for joint, we are reusing the same role_name to send email to
   -- both CM_APP_FOR_PT partners and CM_APPROVED partners
   -- Therefore, do it in bypass/require pt approval check API

   if p_partner_id is not null then
      -- in broadcast and joint, partner_id will not be set because of multiple values

      /*****************************************************/
      /*             set the partners organization name    */
      /*****************************************************/

      wf_engine.SetItemAttrText (itemtype => p_itemType,
                  itemkey  => p_itemKey,
                  aname    => pv_workflow_pub.g_wf_attr_partner_org,
                  avalue   => p_partner_org);

      /*****************************************************/
      /*             set the partners id                   */
      /*****************************************************/

      wf_engine.SetItemAttrText (itemtype => p_itemType,
                  itemkey  => p_itemKey,
                  aname    => pv_workflow_pub.g_wf_attr_partner_id,
                  avalue   => p_partner_id);

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end SetPartnerAttributes;


procedure set_offered_attributes (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemType            in  varchar2
   ,p_itemKey             in  varchar2
   ,p_partner_id          IN  number
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'set_offered_attributes';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_customer_id          number;
   l_resource_id          number;
   l_address_id           number;
   l_partner_org          varchar2(80);
   l_username             varchar2(100);
   l_lead_id              number;
   l_temp_number          number;
   l_username_tbl         pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_resource_id_tbl      pv_assignment_pub.g_number_table_type := pv_assignment_pub.g_number_table_type();

   cursor lc_get_pt_org_name (pc_partner_id number) is
   select pt.party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');

   cursor lc_get_all_offered_to (pc_itemtype    varchar2,
                                 pc_itemkey     varchar2,
                                 pc_notify_type varchar2) is
   select usr.user_name, pn.resource_id
   from pv_lead_assignments la,
        pv_party_notifications pn,
	fnd_user usr
   where la.wf_item_type  = pc_itemtype
   and   la.wf_item_key   = pc_itemkey
   and   la.status in ( pv_assignment_pub.g_la_status_cm_approved,
                        pv_assignment_pub.g_la_status_cm_added,
                        pv_assignment_pub.g_la_status_cm_bypassed,
                        pv_assignment_pub.g_la_status_cm_app_for_pt,
                        pv_assignment_pub.g_la_status_cm_timeout)
   and   la.lead_assignment_id = pn.lead_assignment_id
   and   pn.notification_type  = pc_notify_type
   and   usr.user_id           = pn.user_id;

   cursor lc_get_offered_to_for_pt (pc_itemtype    varchar2,
                                    pc_itemkey     varchar2,
                                    pc_partner_id  number,
                                    pc_notify_type varchar2) is
   select usr.user_name, pn.resource_id
   from pv_lead_assignments la,
        pv_party_notifications pn,
	fnd_user usr
   where la.wf_item_type  = pc_itemtype
   and   la.wf_item_key   = pc_itemkey
   and   la.partner_id    = pc_partner_id
   and   la.lead_assignment_id = pn.lead_assignment_id
   and   pn.notification_type  = pc_notify_type
   and   usr.user_id           = pn.user_id ;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_customer_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => pv_workflow_pub.g_wf_attr_customer_id);

   l_address_id  := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => pv_workflow_pub.g_wf_attr_address_id);

   l_lead_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                            itemkey  => p_itemkey,
                                            aname    => pv_workflow_pub.g_wf_attr_opportunity_id);

   if p_partner_id is not null then

      open lc_get_pt_org_name( pc_partner_id  => p_partner_id);
      fetch lc_get_pt_org_name into l_partner_org;

      if lc_get_pt_org_name%notfound then

         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_token('TEXT', 'Cannot find partner for itemkey: ' || p_itemkey || '. Partner id: ' || p_partner_id);
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;

      end if;

      close lc_get_pt_org_name;

   end if;

   SetPartnerAttributes (
      p_api_version_number  => 1.0
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_itemType           => p_itemtype
      ,p_itemKey            => p_itemkey
      ,p_partner_id         => p_partner_id
      ,p_partner_org        => l_partner_org
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,x_return_status      => x_return_status);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_partner_id is null then

      -- in case of broadcast or joint

      open lc_get_all_offered_to (pc_itemtype    => p_itemtype,
                                  pc_itemkey     => p_itemkey,
                                  pc_notify_type => pv_assignment_pub.g_notify_type_offered_to);
      loop

         fetch lc_get_all_offered_to into l_username, l_resource_id;
         exit when lc_get_all_offered_to%notfound;

         l_username_tbl.extend;
         l_resource_id_tbl.extend;
         l_username_tbl(l_username_tbl.last)       := l_username;
         l_resource_id_tbl(l_resource_id_tbl.last) := l_resource_id;

      end loop;
      close lc_get_all_offered_to;

   else
      -- in case of single or serial

      open lc_get_offered_to_for_pt (pc_itemtype => p_itemtype,
                                  pc_itemkey     => p_itemkey,
                                  pc_partner_id  => p_partner_id,
                                  pc_notify_type => pv_assignment_pub.g_notify_type_offered_to);
      loop

         fetch lc_get_offered_to_for_pt into l_username, l_resource_id;
         exit when lc_get_offered_to_for_pt%notfound;

         l_username_tbl.extend;
         l_resource_id_tbl.extend;
         l_username_tbl(l_username_tbl.last)       := l_username;
         l_resource_id_tbl(l_resource_id_tbl.last) := l_resource_id;

      end loop;
      close lc_get_offered_to_for_pt;

   end if;

   for i in 1 .. l_resource_id_tbl.count loop

      pv_assign_util_pvt.UpdateAccess(
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemtype            => p_itemType,
         p_itemkey             => p_itemKey,
         p_current_username    => l_username_tbl(i),
         p_lead_id             => l_lead_id,
         p_customer_id         => l_customer_id,
         p_address_id          => l_address_id,
         p_access_action       => pv_assignment_pub.G_ADD_ACCESS,
         p_resource_id         => l_resource_id_tbl(i),
         p_access_type         => pv_assignment_pub.G_PT_ACCESS,
         x_access_id           => l_temp_number,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

   end loop;

   pv_assignment_pvt.setTimeout  (
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_itemtype            => p_itemType,
      p_itemkey             => p_itemKey,
      p_partner_id          => p_partner_id,
      p_timeoutType         => pv_assignment_pub.g_offered_timeout,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Updating opportunity last offered date for partner ' || nvl(to_char(p_partner_id), '(s)'));
      fnd_msg_pub.Add;
   END IF;

   if p_partner_id is not null then
      -- single and serial

      update pv_partner_profiles
      set oppty_last_offered_date = sysdate,
          object_version_number = object_version_number + 1,
          last_update_date    = sysdate,
          last_updated_by     = FND_GLOBAL.user_id,
          last_update_login   = FND_GLOBAL.login_id
      where partner_id = p_partner_id;

   else
      -- broadcast and joint

      update pv_partner_profiles
      set oppty_last_offered_date = sysdate,
          object_version_number = object_version_number + 1,
          last_update_date    = sysdate,
          last_updated_by     = FND_GLOBAL.user_id,
          last_update_login   = FND_GLOBAL.login_id
      where partner_id in (select partner_id from pv_lead_assignments
                         where wf_item_type = p_itemtype
                         and   wf_item_key  = p_itemkey
                         and   status in
                         ( pv_assignment_pub.g_la_status_cm_approved,
                           pv_assignment_pub.g_la_status_cm_added,
                           pv_assignment_pub.g_la_status_cm_bypassed,
                           pv_assignment_pub.g_la_status_cm_app_for_pt,
                           pv_assignment_pub.g_la_status_cm_timeout
                         ));
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Setting access code for partner ' || nvl(to_char(p_partner_id), '(s)'));
      fnd_msg_pub.Add;
   END IF;

   if p_partner_id is not null then
      -- single and serial

      update pv_lead_assignments
      set    partner_access_code   = decode(status,
                                        pv_assignment_pub.g_la_status_cm_app_for_pt,     pv_assignment_pub.g_assign_access_update,
                                        pv_assignment_pub.g_assign_access_view),
             object_version_number = object_version_number + 1,
             last_update_date      = sysdate,
             last_updated_by       = FND_GLOBAL.user_id,
             last_update_login     = FND_GLOBAL.login_id
      where  wf_item_type          = p_itemtype
      and    wf_item_key           = p_itemkey
      and    partner_id            = p_partner_id;

   else
      -- broadcast and joint

      update pv_lead_assignments
      set    partner_access_code   = decode(status,
                                        pv_assignment_pub.g_la_status_cm_app_for_pt,     pv_assignment_pub.g_assign_access_update,
                                        pv_assignment_pub.g_assign_access_view),
             object_version_number = object_version_number + 1,
             last_update_date      = sysdate,
             last_updated_by       = FND_GLOBAL.user_id,
             last_update_login     = FND_GLOBAL.login_id
      where rowid in (select rowid from pv_lead_assignments
                         where wf_item_type = p_itemtype
                         and   wf_item_key  = p_itemkey
                         and   status in
                         ( pv_assignment_pub.g_la_status_cm_approved,
                           pv_assignment_pub.g_la_status_cm_added,
                           pv_assignment_pub.g_la_status_cm_bypassed,
                           pv_assignment_pub.g_la_status_cm_app_for_pt,
                           pv_assignment_pub.g_la_status_cm_timeout
                         ));
   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

   x_return_status := FND_API.G_RET_STS_ERROR ;
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

WHEN OTHERS THEN

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

end set_offered_attributes;


-- -----------------------------------------------------------------------------------
-- Procedure Update_Routing_Stage
-- -----------------------------------------------------------------------------------
procedure update_routing_stage (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype            IN  varchar2
   ,p_itemkey             IN  varchar2
   ,p_routing_stage       IN  VARCHAR2
   ,p_active_but_open_flag IN  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'update_routing_stage';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_routing_type        varchar2(30);
   l_rowid               ROWID;
   l_lead_id             number;
   l_lead_workflow_id    number;
   l_assignment_log_id   number;
   l_assignment_type     varchar2(30);
   l_prior_routing       varchar2(30);
   l_wf_status           varchar2(30);
   l_entity              varchar2(30);
   l_assignment_log_rec  assignment_log_rec_type;
   l_log_params_tbl      pvx_utility_pvt.log_params_tbl_type;

   cursor lc_get_workflow (pc_itemtype varchar2,
                           pc_itemkey  varchar2) is
   select rowid,
          lead_id,
          lead_workflow_id,
          routing_status,
          routing_type
   from pv_lead_workflows
   where wf_item_type = pc_itemtype
   and   wf_item_key  = pc_itemkey;


   cursor lc_get_offered_pt (pc_workflow_id number) is
   select b.lead_assignment_id,b.partner_id
   from pv_lead_workflows a, pv_lead_assignments b
   where a.lead_workflow_id = pc_workflow_id
   and a.wf_item_type = b.wf_item_type
   and a.wf_item_key = b.wf_item_key
   and b.status in ('CM_APPROVED','CM_TIMEOUT','CM_BYPASSED','CM_APP_FOR_PT');

   -- ADDED  (the not exists condition is needed for joint as there
   -- could be multiple partners accepting at different time
   -- and this api is called each time.  we do not want to log
   -- duplicate logs
   cursor lc_get_active_pt (pc_workflow_id number) is
   select b.lead_assignment_id,b.partner_id
   from pv_lead_workflows a, pv_lead_assignments b
   where a.lead_workflow_id = pc_workflow_id
   and a.wf_item_type = b.wf_item_type
   and a.wf_item_key = b.wf_item_key
   and b.status in ('PT_APPROVED','CM_APP_FOR_PT')
   and not exists (select 1 from pv_assignment_logs aa
   where aa.lead_assignment_id = b.lead_assignment_id
   and aa.to_lead_status = 'ACTIVE');

   cursor lc_get_abandon_pt (pc_workflow_id number) is
   select b.lead_assignment_id,b.partner_id
   from pv_lead_workflows a, pv_lead_assignments b
   where a.lead_workflow_id = pc_workflow_id
   and a.wf_item_type = b.wf_item_type
   and a.wf_item_key = b.wf_item_key
   and b.status in ('PT_ABANDONED')
   and not exists (select 1 from pv_assignment_logs aa
   where aa.lead_assignment_id = b.lead_assignment_id
   and aa.to_lead_status = 'ABANDONED');


begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   if p_routing_stage not in ( pv_assignment_pub.g_r_status_active,
                              pv_assignment_pub.g_r_status_matched,
                              pv_assignment_pub.g_r_status_offered,
                              pv_assignment_pub.g_r_status_recycled,
                              pv_assignment_pub.g_r_status_abandoned,
                              pv_assignment_pub.g_r_status_unassigned,
                              pv_assignment_pub.g_r_status_withdrawn) then

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT', 'Invalid workflow routing stage.  Itemkey: ' || p_itemkey ||
                                 '. Stage: ' || p_routing_stage);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   open lc_get_workflow (pc_itemtype => p_itemtype,
                         pc_itemkey  => p_itemkey);

   fetch lc_get_workflow into l_rowid, l_lead_id, l_lead_workflow_id, l_prior_routing, l_routing_type;
   close lc_get_workflow;


   if l_rowid is null then
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT', 'Cannot find workflow row to update.  Itemkey: ' || p_itemkey);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_routing_stage = pv_assignment_pub.g_r_status_active and p_active_but_open_flag = 'Y' then

      -- only possible in joint selling where we want to set routing_stage to ACTIVE the moment
      -- 1 partner accept

      l_wf_status := pv_assignment_pub.g_wf_status_open;

   elsif p_routing_stage = pv_assignment_pub.g_r_status_active and nvl(p_active_but_open_flag, 'N') = 'N' then

      l_wf_status := pv_assignment_pub.g_wf_status_closed;

   elsif p_routing_stage in ( pv_assignment_pub.g_r_status_unassigned,
                              pv_assignment_pub.g_r_status_recycled,
                              pv_assignment_pub.g_r_status_abandoned,
                              pv_assignment_pub.g_r_status_withdrawn) then

      l_wf_status := pv_assignment_pub.g_wf_status_closed;

   elsif p_routing_stage in ( pv_assignment_pub.g_r_status_matched,
                              pv_assignment_pub.g_r_status_offered) then

      l_wf_status := pv_assignment_pub.g_wf_status_open;

      -- -----------------------------------------------------------------------------
      -- Log Offered status for each partner that have been approved by the CM(s).
      -- -----------------------------------------------------------------------------
      FOR x IN (SELECT lead_number FROM as_leads_all WHERE lead_id = l_lead_id) LOOP
         l_log_params_tbl(1).param_name := 'OPP_NUMBER';
         l_log_params_tbl(1).param_value := x.lead_number;
      END LOOP;

      l_log_params_tbl(2).param_name := 'OPP_ROUTING_STATUS';
      l_log_params_tbl(2).param_value := pv_assignment_pub.g_r_status_offered;

      FOR x IN (
         SELECT a.partner_id, c.party_name
	 FROM   pv_lead_assignments a,
	        pv_partner_profiles b,
		hz_parties c
	 WHERE  a.wf_item_type     = p_itemtype AND
	        a.wf_item_key      = p_itemkey AND
                a.status IN ('CM_APPROVED', 'CM_BYPASSED', 'CM_TIMEOUT') AND
                a.partner_id       = b.partner_id AND
		b.partner_party_id = c.party_id
      )
      LOOP
         l_log_params_tbl(3).param_name := 'PARTNER_NAME';
         l_log_params_tbl(3).param_value := x.party_name;

	 PVX_Utility_PVT.create_history_log(
             p_arc_history_for_entity_code => 'OPPORTUNITY',
	     p_history_for_entity_id       => l_lead_id,
	     p_history_category_code       => 'GENERAL',
	     p_message_code                => 'PV_LG_RTNG_OFFERED',
	     p_partner_id                  => x.partner_id,
	     p_access_level_flag           => 'V',
	     p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
	     p_comments                    => NULL,
	     p_log_params_tbl              => l_log_params_tbl,
	     x_return_status               => x_return_status,
	     x_msg_count                   => x_msg_count,
	     x_msg_data                    => x_msg_data
         );
      END LOOP;

   end if;

   update pv_lead_workflows
   set    routing_status        = p_routing_stage,
          wf_status             = l_wf_status,
          object_version_number = object_version_number + 1,
          last_update_date      = sysdate,
          last_updated_by       = FND_GLOBAL.user_id,
          last_update_login     = FND_GLOBAL.login_id
   where  rowid   = l_rowid returning entity into l_entity;

   l_assignment_log_rec.LEAD_ID                := l_lead_id;
   l_assignment_log_rec.FROM_LEAD_STATUS       := l_prior_routing;
   l_assignment_log_rec.TO_LEAD_STATUS         := p_routing_stage;
   l_assignment_log_rec.WF_ITEM_TYPE           := p_itemtype;
   l_assignment_log_rec.WF_ITEM_KEY            := p_itemkey;
   l_assignment_log_rec.WORKFLOW_ID            := l_lead_workflow_id;

   if p_routing_stage = 'OFFERED' then
      if l_routing_type <> 'SERIAL' then
         -- serial handled in pv_workflow_pub.serial_next_partner
         for lrec in lc_get_offered_pt (pc_workflow_id => l_lead_workflow_id) loop

            l_assignment_log_rec.partner_id := lrec.partner_id;
            l_assignment_log_rec.lead_assignment_id := lrec.lead_assignment_id;

            Create_assignment_log_row (
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_assignment_log_rec  => l_assignment_log_rec,
               x_assignment_id       => l_assignment_log_id,
               x_return_status       => x_return_status,
               x_msg_count           => x_msg_count,
               x_msg_data            => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;
         end loop;
      end if;

   elsif p_routing_stage = 'ACTIVE' then
      for lrec in lc_get_active_pt (pc_workflow_id => l_lead_workflow_id) loop

         l_assignment_log_rec.partner_id := lrec.partner_id;
         l_assignment_log_rec.lead_assignment_id := lrec.lead_assignment_id;

         Create_assignment_log_row (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_assignment_log_rec  => l_assignment_log_rec,
            x_assignment_id       => l_assignment_log_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;
      end loop;

   elsif p_routing_stage = 'ABANDONED' then
      for lrec in lc_get_abandon_pt (pc_workflow_id => l_lead_workflow_id) loop

         l_assignment_log_rec.partner_id := lrec.partner_id;
         l_assignment_log_rec.lead_assignment_id := lrec.lead_assignment_id;

         Create_assignment_log_row (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_assignment_log_rec  => l_assignment_log_rec,
            x_assignment_id       => l_assignment_log_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;
      end loop;
   else
      Create_assignment_log_row (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_assignment_log_rec  => l_assignment_log_rec,
         x_assignment_id       => l_assignment_log_id,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if  l_wf_status = pv_assignment_pub.g_wf_status_closed then

      if p_routing_stage in (pv_assignment_pub.g_r_status_withdrawn,
                             pv_assignment_pub.g_r_status_recycled,
                             pv_assignment_pub.g_r_status_abandoned) then

         l_assignment_type := pv_assignment_pub.g_r_status_unassigned;
      else
         l_assignment_type := null;
      end if;

      if l_entity = 'OPPORTUNITY' then

         update as_leads_all
         set prm_assignment_type  = nvl(l_assignment_type, prm_assignment_type),
             auto_assignment_type = 'TAP'
         where  lead_id = l_lead_id;

      elsif l_entity = 'LEAD' then

         update as_sales_leads
         set prm_assignment_type  = nvl(l_assignment_type, prm_assignment_type),
             auto_assignment_type = 'TAP'
         where  sales_lead_id = l_lead_id;

      end if;

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end update_routing_stage;


procedure StartWorkflow (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             IN  VARCHAR2,
   p_itemType            IN  VARCHAR2,
   p_creating_username   IN  VARCHAR2,
   p_attrib_values_rec   IN  attrib_values_rec_type,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

  l_api_name            CONSTANT VARCHAR2(30) := 'StartWorkflow';
  l_api_version_number  CONSTANT NUMBER       := 1.0;

  l_role_name           varchar2(30);
  l_email_enabled       varchar2(30);
  l_vendor_respond_URL  varchar2(200);
  l_pt_respond_URL      varchar2(200);


begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Itemtype: ' || p_itemtype || '. Itemkey: ' || p_itemkey);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Create Assignment Process
   IF p_attrib_values_rec.process_name = pv_workflow_pub.g_wf_pcs_initiate_assignment  THEN
      wf_engine.CreateProcess ( ItemType => p_itemtype,
                                ItemKey  => p_itemkey,
                                process  => pv_workflow_pub.g_wf_pcs_initiate_assignment);

      wf_engine.SetItemUserKey (itemType => p_itemtype,
                                itemKey  => p_itemkey,
                                userKey  => p_itemkey);

--     Setting Org Type Attribute
       wf_engine.SetItemAttrText  ( itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => pv_workflow_pub.g_wf_attr_organization_type,
                                    avalue   => p_attrib_values_rec.org_type);

--     Setting Partner Id attribute
       wf_engine.SetItemAttrText  ( itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => pv_workflow_pub.g_wf_attr_ext_org_party_id,
                                    avalue   => p_attrib_values_rec.pt_org_party_id);

--     Setting bypass_cm_ok_flag  attribute
       wf_engine.SetItemAttrText  ( itemtype => p_itemtype,
                                    itemkey  => p_itemkey,
                                    aname    => pv_workflow_pub.g_wf_attr_bypass_cm_approval,
                                    avalue   => p_attrib_values_rec.bypass_cm_ok_flag);
 --    Setting  customer_id  attribute
        wf_engine.SetItemAttrNumber ( itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname    => pv_workflow_pub.g_wf_attr_customer_id,
                                      avalue   => p_attrib_values_rec.customer_id);
--     Setting Address Id attribute
        wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                                     itemkey  => p_itemkey,
                                     aname    => pv_workflow_pub.g_wf_attr_address_id,
                                     avalue   => p_attrib_values_rec.address_id);

        l_vendor_respond_url  := fnd_profile.value('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');
        l_pt_respond_url      := fnd_profile.value('PV_WORKFLOW_ISTORE_URL');

 --     Setting CM Respond URL Attribute
         wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                     itemkey  => p_itemKey,
                                     aname    => pv_workflow_pub.g_wf_attr_cm_respond_url,
                                     avalue   => l_vendor_respond_URL);

--      Setting Partner Respond URL Attribute
         wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                     itemkey  => p_itemKey,
                                     aname    => 'PV_PT_RESPOND_URL_ATTR',
                                     avalue   => l_pt_respond_URL);
         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'process rule id in the if of workflow set'|| p_attrib_values_rec.process_rule_id);
            fnd_msg_pub.Add;
          END IF;

--      Setting Process Rule ID Attribute
          wf_engine.SetItemAttrNumber( itemtype => p_itemType,
                                       itemkey  => p_itemKey,
                                       aname    => pv_workflow_pub.g_wf_attr_process_rule_id,
                                       avalue   => p_attrib_values_rec.process_rule_id);


  -- Channel Manager Withdrawing Active Opportunity
  ELSIF p_attrib_values_rec.process_name = pv_workflow_pub.g_wf_pcs_withdraw_fyi THEN
      wf_engine.CreateProcess ( ItemType => p_itemtype,
                                ItemKey  => p_itemkey,
                                process  => pv_workflow_pub.g_wf_pcs_withdraw_fyi);
  END IF;

  wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_opportunity_id,
                               avalue   => p_attrib_values_rec.lead_id);

  wf_engine.SetItemAttrText  ( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_entity_name,
                               avalue   => p_attrib_values_rec.entity_name);

  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
     fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
     fnd_message.Set_Token('TEXT', 'in startworkflow Entity Amount'||p_attrib_values_rec.entity_amount);
     fnd_msg_pub.Add;
  END IF;
  wf_engine.SetItemAttrText( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_entity_amount,
                               avalue   => p_attrib_values_rec.entity_amount);


  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
     fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
     fnd_message.Set_Token('TEXT', 'after the entity amount');
     fnd_msg_pub.Add;
  END IF;

  wf_engine.SetItemAttrText ( itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => pv_workflow_pub.g_wf_attr_opp_number,
                              avalue   => p_attrib_values_rec.lead_number);

  wf_engine.SetItemAttrText  ( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_customer_name,
                               avalue   => p_attrib_values_rec.customer_name);

   wf_engine.SetItemAttrText (itemtype => p_itemType,
                              itemkey  => p_itemKey,
                              aname    => pv_workflow_pub.g_wf_attr_assignment_type,
                              avalue   => p_attrib_values_rec.assignment_type);

   l_email_enabled  := nvl(fnd_profile.value('PV_EMAIL_NOTIFICATION_FLAG'), pv_workflow_pub.g_wf_lkup_yes);

   wf_engine.SetItemAttrText ( itemtype => p_itemType,
                               itemkey  => p_itemKey,
                               aname    => pv_workflow_pub.g_wf_attr_email_enabled,
                               avalue   => l_email_enabled);



  wf_engine.StartProcess(     itemtype => p_itemtype,
                              itemkey  => p_itemkey);


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end StartWorkflow;


procedure validateResponse (
      p_api_version_number   IN  NUMBER
      ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
      ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
      ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
      ,p_response_code       IN  VARCHAR2
      ,p_routing_status      IN  VARCHAR2
      ,p_decision_maker_flag IN  VARCHAR2
      ,p_notify_type         IN  VARCHAR2
      ,x_msg_count           OUT NOCOPY  NUMBER
      ,x_msg_data            OUT NOCOPY  VARCHAR2
      ,x_return_status       OUT NOCOPY  VARCHAR2) is

   cursor lc_code_meaning (pc_lookup_type varchar2,
                           pc_lookup_code varchar2) is
      select meaning
      from pv_lookups
      where lookup_type = pc_lookup_type
      and   lookup_code = pc_lookup_code;

   l_routing_status         varchar2(300);
   l_response_txt           varchar2(500);
   l_routing_status_txt     varchar2(500);

   l_api_name            CONSTANT VARCHAR2(30) := 'validateResponse';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

begin

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   if p_response_code is null then

      fnd_message.SET_NAME('PV',      'PV_INVALID_RESPONSE');
      fnd_message.SET_TOKEN('STATUS', p_response_code);
      fnd_msg_pub.ADD;

      raise FND_API.G_EXC_ERROR;

   end if;

   if p_decision_maker_flag <> 'Y' or p_decision_maker_flag is NULL then

      fnd_message.set_name('PV', 'PV_NOT_DECISION_MAKER');
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

      open lc_code_meaning ( pc_lookup_type => 'PV_ASSIGNMENT_STATUS',
              pc_lookup_code => p_response_code);

      fetch lc_code_meaning into l_response_txt;
      close lc_code_meaning;

      if l_response_txt is null then

         fnd_message.SET_NAME('PV',      'PV_INVALID_RESPONSE');
         fnd_message.SET_TOKEN('STATUS', p_response_code);
         fnd_msg_pub.ADD;

         raise FND_API.G_EXC_ERROR;
      end if;

      if p_routing_status = pv_assignment_pub.g_r_status_matched and
         p_notify_type    = pv_assignment_pub.g_notify_type_matched_to and
         p_response_code in (pv_assignment_pub.g_la_status_cm_approved,
                             pv_assignment_pub.g_la_status_cm_app_for_pt,
                             pv_assignment_pub.g_la_status_cm_rejected,
                             pv_assignment_pub.g_la_status_assigned) then

         -- do not test for below because we are only validating for existing partner
         -- this way we will trap any errors if existing partners were set to the below

         -- pv_assignment_pub.g_la_status_cm_added
         -- pv_assignment_pub.g_la_status_cm_add_app_for_pt,

         null;

      elsif p_routing_status = pv_assignment_pub.g_r_status_offered and
            p_notify_type    = pv_assignment_pub.g_notify_type_offered_to and
            p_response_code in (pv_assignment_pub.g_la_status_pt_approved,
                                pv_assignment_pub.g_la_status_pt_rejected,
                                pv_assignment_pub.g_la_status_cm_app_for_pt) then

         null;

      elsif p_routing_status = pv_assignment_pub.g_r_status_active and
            p_notify_type    = pv_assignment_pub.g_notify_type_offered_to and
            p_response_code in (pv_assignment_pub.g_la_status_pt_approved
			                    , pv_assignment_pub.g_la_status_pt_rejected
								, pv_assignment_pub.g_la_status_cm_app_for_pt) then

         -- in case of joint routing is ACTIVE the moment a single partner accept
         null;

      else
         open lc_code_meaning (pc_lookup_type => 'PV_ROUTING_STAGE',
                               pc_lookup_code => p_routing_status);

         fetch lc_code_meaning into l_routing_status_txt;
         close lc_code_meaning;

         fnd_message.SET_NAME('PV',             'PV_INVALID_LEAD_RESPONSE');
         fnd_message.SET_TOKEN('P_RESPONSE',    l_response_txt);
         fnd_message.SET_TOKEN('P_LEAD_STATUS', l_routing_status_txt);
         fnd_msg_pub.ADD;

         raise FND_API.G_EXC_ERROR;
      end if;


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end validateResponse;


procedure set_current_routing_flag (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             in  varchar2,
   p_entity              IN  VARCHAR2,
   p_entity_id           IN  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'set_current_routing_flag';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   update pv_lead_workflows
   set    latest_routing_flag = decode(wf_item_key, p_itemkey, 'Y', 'N'),
          object_version_number = object_version_number + 1
   where  lead_id = p_entity_id
   and    entity  = p_entity
   and    latest_routing_flag = 'Y';

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end set_current_routing_flag;


PROCEDURE Bulk_cr_party_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_party_notify_rec_tbl   IN   party_notify_rec_tbl_type,
    X_Return_Status          OUT NOCOPY   VARCHAR2,
    X_Msg_Count              OUT NOCOPY   NUMBER,
    X_Msg_Data               OUT NOCOPY   VARCHAR2
    )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Bulk_Cr_party_notification';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_party_notification_id number;
   l_party_notify_id_tbl pv_assignment_pub.g_number_table_type := pv_assignment_pub.g_number_table_type();

   cursor lc_get_ids (pc_count number) is
   select pv_party_notifications_s.nextval
   from fnd_tables where rownum <= pc_count;

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Bulk adding ' || p_party_Notify_rec_tbl.lead_assignment_id.count || ' rows');
      fnd_msg_pub.Add;
   END IF;

   if p_party_Notify_rec_tbl.lead_assignment_id.count > 0 then

      open lc_get_ids(pc_count => p_party_notify_rec_tbl.lead_assignment_id.count);

      loop
         fetch lc_get_ids into l_party_notification_id;
         exit when lc_get_ids%notfound;
         l_party_notify_id_tbl.extend;
         l_party_notify_id_tbl(l_party_notify_id_tbl.last) := l_party_notification_id;
      end loop;

      close lc_get_ids;

      FORALL i in 1 ..  p_party_notify_rec_tbl.lead_assignment_id.count

         INSERT into pv_party_notifications (
            PARTY_NOTIFICATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_LOGIN,
            WF_ITEM_TYPE,
            WF_ITEM_KEY,
            NOTIFICATION_TYPE,
            LEAD_ASSIGNMENT_ID,
            USER_ID,
            --USER_NAME,
            RESOURCE_ID,
            RESOURCE_RESPONSE,
            RESPONSE_DATE,
            DECISION_MAKER_FLAG
         ) values (
            l_party_notify_id_tbl(i),
            sysdate,
            fnd_global.user_id,
            sysdate,
            1,
            fnd_global.user_id,
            fnd_global.conc_login_id,
            p_party_notify_rec_tbl.wf_item_type(i),
            p_party_notify_rec_tbl.wf_item_key(i),
            p_party_notify_rec_tbl.notification_type(i),
            p_party_notify_rec_tbl.lead_assignment_id(i),
            p_party_notify_rec_tbl.user_id(i),
            --p_party_notify_rec_tbl.user_name(i),
            p_party_notify_rec_tbl.resource_id(i),
            p_party_notify_rec_tbl.resource_response(i),
            p_party_notify_rec_tbl.response_date(i),
            p_party_notify_rec_tbl.decision_maker_flag(i)
         );

   end if;
   --
   -- End of API body
   --

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Bulk_cr_party_notification;


PROCEDURE send_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_itemtype               IN   VARCHAR2,
    p_itemkey                IN   VARCHAR2,
    p_activity_id            IN   NUMBER,
    p_route_stage            IN   VARCHAR2,
    p_partner_id             IN   NUMBER,
    X_Return_Status          OUT NOCOPY   VARCHAR2,
    X_Msg_Count              OUT NOCOPY   NUMBER,
    X_Msg_Data               OUT NOCOPY   VARCHAR2
    )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'send_notification';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_count                pls_integer := 0;
   l_notify_profile       varchar2(30);
   l_lead_id              number;
   l_notify_pt_flag       varchar2(1);
   l_notify_cm_flag       varchar2(1);
   l_notify_am_flag       varchar2(1);
   l_notify_ot_flag       varchar2(1);

   l_ignore_pt_flag       varchar2(1); -- if Y, only 1 email is sent regardless of # of partners
   l_notify_enabled_flag  varchar2(1);
   l_email_enabled_flag   varchar2(1);

   l_user_id              number;
   l_resource_id          number;
   l_partner_id           number;
   l_partner_org          varchar2(100);

   l_assignment_type      varchar2(30);
   l_assignment_status    varchar2(30);
   l_username             varchar2(100);
   l_responding_cm        varchar2(100);
   l_reason               varchar2(200);
   l_usertype             varchar2(30);
   l_profile_flag         varchar2(10);

   l_role_list            wf_directory.usertable;
   empty_role_list        wf_directory.usertable;
   l_role_list_index      number :=1;

   l_adhoc_role           varchar2(50);
   l_context              varchar2(30);
   l_msg_name             varchar2(30);
   l_group_notify_id      number;
   l_exit_loop            boolean;
   l_selected_pt_only     boolean;
   l_rank                 number;
   l_assign_sequence      number;

   l_username_tbl      pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_usertype_tbl      pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_assign_status_tbl pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_userid_tbl        pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_resourceid_tbl    pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_partner_id_tbl    pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();

   cursor lc_get_notify_flags (pc_route_stage    varchar2) is
      select
             nvl(b.notify_pt_flag,     'N'),
             nvl(b.notify_cm_flag,     'N'),
             nvl(b.notify_am_flag,     'N'),
             nvl(b.notify_others_flag, 'N'),
             b.enabled_flag
      from pv_status_notifications b
      where
          b.status_type = 'ROUTING'
      and b.status_code = pc_route_stage;

   cursor lc_get_people (pc_notify_am_flag varchar2,
                         pc_notify_cm_flag varchar2,
                         pc_notify_pt_flag varchar2,
                         pc_notify_ot_flag varchar2,
                         pc_ignore_pt_flag varchar2,
                         pc_lead_id        number)
   is
      SELECT  pn.user_id, pn.resource_id, usr.user_name,
              decode(pn.notification_type, 'MATCHED_TO', 'CM', 'PT') user_type,
              decode(pc_ignore_pt_flag, 'Y', 0, pa.partner_id) partner_id, pa.status
      FROM    pv_lead_assignments pa, pv_party_notifications pn, pv_lead_workflows pw, fnd_user usr
      WHERE
            ((pn.notification_type = 'MATCHED_TO' and 'Y' = pc_notify_cm_flag)
             or (pn.notification_type = 'OFFERED_TO' and 'Y' = pc_notify_pt_flag))
      and     pw.lead_id = pc_lead_id
      and     pw.entity  = 'OPPORTUNITY'
      and     pw.latest_routing_flag = 'Y'
      AND     pa.lead_assignment_id = pn.lead_assignment_id
      and     pw.wf_item_type = pa.wf_item_type
      and     pw.wf_item_key = pa.wf_item_key
      AND     pn.user_id = usr.user_id
      AND     sysdate between usr.start_date and nvl(usr.end_date,sysdate)
      union
      SELECT  js.user_id, js.resource_id, fu.user_name,
         decode(pw.created_by - js.user_id,0,'AM','OT') user_type,
      decode(pc_ignore_pt_flag, 'Y', 0, pl.partner_id) partner_id, pl.status
      FROM    as_accesses_all ac, jtf_rs_resource_extns js, fnd_user fu,
              pv_lead_workflows pw, pv_lead_assignments pl
      WHERE   (('Y' = pc_notify_ot_flag and pw.created_by <> js.user_id)
             or ('Y' = pc_notify_am_flag and pw.created_by = js.user_id))
      AND     ac.lead_id = pc_lead_id
      and     ac.lead_id = pw.lead_id
      and     ac.salesforce_id = js.resource_id
      AND     js.user_id = fu.user_id
      and     pw.entity  = 'OPPORTUNITY'
      and     pw.latest_routing_flag = 'Y'
      and     pl.wf_item_type = pw.wf_item_type
      and     pl.wf_item_key = pw.wf_item_key
      and     sysdate between js.start_date_active and nvl(js.end_date_active,sysdate)
      AND     sysdate between fu.start_date and nvl(fu.end_date,sysdate)
      and     not exists
              (select 1
               from pv_lead_assignments pa, pv_party_notifications pv
               where  pa.wf_item_type = pw.wf_item_type
               and    pv.user_id <> pw.created_by
               and    pa.wf_item_key = pw.wf_item_key
               AND    pa.lead_assignment_id = pv.lead_assignment_id
               and    pv.resource_id = ac.salesforce_id)
      order by 5,4;

   cursor lc_get_pt_org_name (pc_partner_id number) is
   select pt.party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');

   cursor lc_get_responding_cm (pc_partner_id number,
                                pc_itemtype   varchar2,
                                pc_itemkey    varchar2,
                                pc_response   varchar2) is
      select c.resource_name
      from pv_lead_assignments       a,
           pv_party_notifications    b,
           jtf_rs_resource_extns_vl  c
      where a.wf_item_type       = pc_itemtype
      and   a.wf_item_key        = pc_itemkey
      and   a.partner_id         = pc_partner_id
      and   a.lead_assignment_id = b.lead_assignment_id
      and   b.resource_response  = pc_response
      and   b.user_id            = c.user_id;

   cursor lc_get_reason (pc_partner_id number,
                         pc_itemtype   varchar2,
                         pc_itemkey    varchar2) is
      select b.meaning
      from   pv_lead_assignments a,
             pv_lookups          b
      where  a.wf_item_type  = pc_itemtype
      and    a.wf_item_key   = pc_itemkey
      and    a.partner_id    = pc_partner_id
      and    a.reason_code   = b.lookup_code
      and    b.lookup_type   = 'PV_REASON_CODES';


BEGIN

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. itemkey = ' || p_itemkey);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_assignment_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                                  itemkey  => p_itemkey,
                                                  aname    => pv_workflow_pub.g_wf_attr_assignment_type);

   l_lead_id := wf_engine.GetItemAttrNumber( itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => pv_workflow_pub.g_wf_attr_opportunity_id);

   l_email_enabled_flag  := nvl(fnd_profile.value('PV_EMAIL_NOTIFICATION_FLAG'), pv_workflow_pub.g_wf_lkup_yes);

   l_rank := wf_engine.GetItemAttrNumber( itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => pv_workflow_pub.g_wf_attr_current_serial_rank);


   if l_email_enabled_flag = 'Y' then

      open lc_get_notify_flags(pc_route_stage => p_route_stage);
      fetch lc_get_notify_flags into l_notify_pt_flag, l_notify_cm_flag,
                                     l_notify_am_flag, l_notify_ot_flag, l_notify_enabled_flag;

      close lc_get_notify_flags;

      if l_notify_enabled_flag is NULL then

         fnd_message.SET_NAME('PV',    'PV_DEBUG_MESSAGE');
         fnd_message.SET_TOKEN('TEXT', 'Cannot find routing stage: ' || p_route_stage || ' in pv_status_notifications');
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Lead id: ' || l_lead_id ||
                                       '. Notification for routing: ' || p_route_stage ||
                                       '. Enabled: ' || l_notify_enabled_flag);
         fnd_msg_pub.Add;
      END IF;

      if l_notify_enabled_flag = 'Y' then

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', ' Notify AM: '    || l_notify_am_flag ||
                                          ' Notify PT: '    || l_notify_pt_flag ||
                                          ' Notify CM: '    || l_notify_cm_flag ||
                                          ' Notify other: ' || l_notify_ot_flag);
            fnd_msg_pub.Add;
         END IF;

         if p_partner_id is not null then
            l_selected_pt_only := true;
         end if;

         if p_route_stage in (pv_assignment_pub.g_r_status_matched, pv_assignment_pub.g_r_status_recycled) then
            l_notify_pt_flag := 'N';
         end if;

         if p_route_stage in (pv_assignment_pub.g_r_status_recycled, pv_assignment_pub.g_r_status_withdrawn) then

            IF  p_route_stage = pv_assignment_pub.g_r_status_withdrawn
	    AND l_assignment_type = pv_workflow_pub.g_wf_lkup_serial THEN
               l_ignore_pt_flag := 'N';
	    ELSE
               l_ignore_pt_flag := 'Y';
            END IF;
         else
            l_ignore_pt_flag := 'N';
         end if;




         open lc_get_people (pc_notify_am_flag => l_notify_am_flag,
                             pc_notify_cm_flag => l_notify_cm_flag,
                             pc_notify_pt_flag => l_notify_pt_flag,
                             pc_notify_ot_flag => l_notify_ot_flag,
                             pc_ignore_pt_flag => l_ignore_pt_flag,
                             pc_lead_id        => l_lead_id
                            );
         loop

            fetch lc_get_people into l_user_id, l_resource_id, l_username, l_usertype, l_partner_id, l_assignment_status;
            exit when lc_get_people%notfound;

            -- bypass usertype based on some combinations.  Eg. if MATCHED, notify pt should be N



            loop

               if l_assignment_status = pv_assignment_pub.g_la_status_cm_rejected and l_usertype = 'PT' then
                  -- p_route_stage is OFFERED, we only want to send email to PTs if not cm_rejected
                  exit;

               elsif l_assignment_status = pv_assignment_pub.g_la_status_match_withdrawn and l_usertype = 'PT' then
                  exit;

               elsif l_assignment_status = pv_assignment_pub.g_la_status_lost_chance and l_usertype = 'PT' and
                     l_assignment_type = pv_workflow_pub.g_wf_lkup_serial then
                  exit;

               elsif l_assignment_type = pv_workflow_pub.g_wf_lkup_serial
	            and p_route_stage = pv_assignment_pub.g_r_status_withdrawn then

                  IF l_partner_id <> p_partner_id
                  OR l_assignment_status = pv_assignment_pub.g_la_status_cm_rejected   THEN
                     exit;
                  END IF;

               elsif  l_assignment_type in (pv_workflow_pub.g_wf_lkup_broadcast,
                                            pv_workflow_pub.g_wf_lkup_joint)
               and    l_assignment_status   in (pv_assignment_pub.g_la_status_cm_rejected,
                                                pv_assignment_pub.g_la_status_pt_rejected,
                                                pv_assignment_pub.g_la_status_lost_chance
                                                 )
               and    p_route_stage =  pv_assignment_pub.g_r_status_withdrawn then

                      exit;

               end if;

               if l_selected_pt_only and l_partner_id <> p_partner_id then
                  exit;
               end if;

               if l_count <> 0 then

                  -- this works together with the l_ignore_pt_flag

                  if l_username   = l_username_tbl(l_count) and
                     l_usertype   = l_usertype_tbl(l_count) and
                     l_partner_id = l_partner_id_tbl(l_count) then

                     exit;

                  end if;

               end if;

               l_profile_flag := nvl(fnd_profile.value_specific(name    => 'PV_' || p_route_stage || '_NOTIFY_FLAG',
                                                                user_id => l_user_id), 'Y');

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'User: ' || l_username || '. Usertype: ' || l_usertype ||
                                                '. Profile notify flag: ' || l_profile_flag || '. partner id: ' || l_partner_id);
                  fnd_msg_pub.Add;
               end if;

               if l_profile_flag = 'Y' then

                  l_count := l_count + 1;

                  l_userid_tbl.extend;
                  l_username_tbl.extend;
                  l_resourceid_tbl.extend;
                  l_usertype_tbl.extend;
                  l_partner_id_tbl.extend;
                  l_assign_status_tbl.extend;

                  l_userid_tbl        (l_count) := l_user_id;
                  l_username_tbl      (l_count) := l_username;
                  l_resourceid_tbl    (l_count) := l_resource_id;
                  l_usertype_tbl      (l_count) := l_usertype;
                  l_partner_id_tbl    (l_count) := l_partner_id;
                  l_assign_status_tbl (l_count) := l_assignment_status;

               end if;
               exit;

            end loop;

         end loop;

         close lc_get_people;

         if l_username_tbl.count > 0 then

            l_usertype          := l_usertype_tbl(1);
            l_partner_id        := l_partner_id_tbl(1);
            l_assignment_status := l_assign_status_tbl(1);

         end if;
        debug('Displaying user name table');
        for userindex in 1 .. l_username_tbl.count  loop
            debug('l_username_tbl(' || userindex || ')::' || l_username_tbl(userindex));
        end loop;

         debug('before outer loop : l_username_tbl.count = ' || l_username_tbl.count );
         l_role_list_index := 1;

         for i in 1 .. l_username_tbl.count  loop

            debug('outer loop : i = ' || i || '::l_username_tbl(i)::' || l_username_tbl(i));
            debug('outer loop : i = ' || i || '::l_usertype_tbl(i)::' || l_usertype_tbl(i));

            if (l_usertype_tbl(i) <> l_usertype) or (i = l_username_tbl.count) or (l_partner_id_tbl(i) <> l_partner_id) then
                debug(' in if (l_usertype_tbl(i) <> l_usertype) or (i = l_username_tbl.count) or (l_partner_id_tbl(i) <> l_partner_id) then' );
               -- when usertype changes or partner changes or at last username
               -- send notification for prior usertype or partner

                  l_exit_loop := true;

                  if (i = l_username_tbl.count and l_partner_id_tbl(i) = l_partner_id and l_usertype_tbl(i) = l_usertype) then
                        debug(' in if (i = l_username_tbl.count and l_partner_id_tbl(i) = l_partner_id and l_usertype_tbl(i) = l_usertype) then ');
                  -- last username belongs to the current partner

                        l_role_list(l_role_list_index) :=  l_username_tbl(i);
                        l_role_list_index := l_role_list_index+1;

                  elsif (i = l_username_tbl.count and l_partner_id_tbl(i) <> l_partner_id) or
                     (i = l_username_tbl.count and l_usertype_tbl(i)   <> l_usertype) then
                    debug('elsif (i = l_username_tbl.count and l_partner_id_tbl(i) <> l_partner_id) or (i = l_username_tbl.count and l_usertype_tbl(i)   <> l_usertype) then ' );
                  -- last username happens to be for a new partner or a new usertype.
                  -- send notification for prior usertype or partner
                  -- loop around and send notification to current partner or usertype

                  l_exit_loop := false;

               end if;

               loop

                debug('innner loop : i = ' || i || '::' || l_username_tbl(i));

                  if p_route_stage = pv_assignment_pub.g_r_status_matched and
                     l_assignment_status = pv_assignment_pub.g_la_status_assigned then

                     l_adhoc_role := 'PV' || p_itemkey || 'MATCH' || l_usertype || '_' || l_partner_id;
                     l_msg_name   := 'PV_MATCH_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_matched and
                        l_assignment_status = pv_assignment_pub.g_la_status_cm_rejected then

                     l_adhoc_role := 'PV' || p_itemkey || 'CMREJECT' || l_usertype || '_' || l_partner_id;
                     l_msg_name   := 'PV_CMREJECT_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_active and
                        l_assignment_status = pv_assignment_pub.g_la_status_lost_chance then

                     -- only for broadcast and serial

                     l_adhoc_role := 'PV' || p_itemkey || 'LOSTCHNCE' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_LOSTCHANCE_' || l_usertype || '_MSG';


                  elsif p_route_stage = pv_assignment_pub.g_r_status_offered and
                        l_assignment_status in (pv_assignment_pub.g_la_status_cm_approved,
                                                pv_assignment_pub.g_la_status_cm_bypassed,
                                                pv_assignment_pub.g_la_status_cm_timeout) then

                     l_adhoc_role := 'PV' || p_itemkey || 'OFFER' || l_usertype || '_' || l_partner_id;
                     l_msg_name   := 'PV_OFFER_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_active and
                        l_assignment_status in (pv_assignment_pub.g_la_status_pt_approved,
                                                 pv_assignment_pub.g_la_status_cm_app_for_pt) then

                     l_adhoc_role := 'PV' || p_itemkey || 'PTAPPRVE' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_PTAPPROVE_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_offered and
                        l_assignment_status = pv_assignment_pub.g_la_status_pt_rejected then

                     l_adhoc_role := 'PV' || p_itemkey || 'PTREJECT' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_PTREJECT_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_offered and
                        l_assignment_status = pv_assignment_pub.g_la_status_pt_timeout then

                     l_adhoc_role := 'PV' || p_itemkey || 'PTTMEOUT' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_PTTIMEOUT_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_offered and
                        l_assignment_status = pv_assignment_pub.g_la_status_lost_chance then

                     -- only for broadcast and serial

                     l_adhoc_role := 'PV' || p_itemkey || 'LOSTCHNCE' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_LOSTCHANCE_' || l_usertype || '_MSG';


                  elsif p_route_stage = pv_assignment_pub.g_r_status_withdrawn and
                        l_assignment_status = pv_assignment_pub.g_la_status_match_withdrawn then

                     l_adhoc_role := 'PV' || p_itemkey || 'MTCHWHDRW' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_MTCHWITHDRAW_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_withdrawn and
                        l_assignment_status = pv_assignment_pub.g_la_status_offer_withdrawn then

                     l_adhoc_role := 'PV' || p_itemkey || 'OFFRWHDRW' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_OFFRWITHDRAW_' || l_usertype || '_MSG';
     -- check
                  elsif p_route_stage = pv_assignment_pub.g_r_status_withdrawn and
                        l_assignment_status = pv_assignment_pub.g_la_status_active_withdrawn then

                     l_adhoc_role := 'PV' || p_itemkey || 'ACTIVEWHDRW' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_ACTIVEWHDRW_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_recycled and
                        l_assignment_status = pv_assignment_pub.g_la_status_cm_rejected then

                     l_adhoc_role := 'PV' || p_itemkey || 'MTCHRYCLE' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_MTCHRECYCLE_' || l_usertype || '_MSG';


                  elsif p_route_stage = pv_assignment_pub.g_r_status_recycled and
                        l_assignment_status in (pv_assignment_pub.g_la_status_pt_rejected,
                                                pv_assignment_pub.g_la_status_pt_timeout) then

                     l_adhoc_role := 'PV' || p_itemkey || 'OFFRRYCLE' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_OFFRRECYCLE_' || l_usertype || '_MSG';

                  elsif p_route_stage = pv_assignment_pub.g_r_status_abandoned and
                        l_assignment_status = pv_assignment_pub.g_la_status_pt_abandoned then

                     l_adhoc_role := 'PV' || p_itemkey || 'PTABNDN' || l_usertype || '_' || l_partner_id;
                     l_msg_name := 'PV_PTABANDON_' || l_usertype || '_MSG';


                  else

                     l_msg_name := null;

                  end if;

                  debug ('l_role_list.count ::' ||l_role_list.count);

                  if l_msg_name is not null then

                     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_token('TEXT', 'Creating role: '||l_adhoc_role||' with members--- ');
                        fnd_msg_pub.Add;
                     END IF;

		              FOR ind in 1 .. l_role_list.count
		              LOOP
			             debug('roleindex:' || ind || '::' || l_role_list(ind) );
                      END LOOP;

                    debug ('after printing role list');

                     -- Bug fix 2981795
                     -- There is a chance under certain conditions that a role being created already exists
                     -- In such cases this call will error out. If this call throws any error just exit out
                     -- of the current loop and continue with creation of the other roles.
                     BEGIN
                         wf_directory.CreateAdHocRole2(role_name         => l_adhoc_role,
                                                      role_display_name => l_adhoc_role,
                                                      role_users        => l_role_list);
                     EXCEPTION
                         WHEN OTHERS THEN
                             IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                                 fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                                 fnd_message.Set_token('TEXT', 'Did not create the role as it already exists');
                                 fnd_msg_pub.Add;
                             END IF;
                         EXIT;
                     END;

		     l_context := p_itemtype || ':' || p_itemkey || ':';

                     if l_partner_org is null and l_ignore_pt_flag = 'N' then

                        open lc_get_pt_org_name ( pc_partner_id => l_partner_id);
                        fetch lc_get_pt_org_name into l_partner_org;
                        close lc_get_pt_org_name;

                        if l_partner_org is null then

                           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                           fnd_message.Set_token('TEXT', 'Cannot find partner id: ' || l_partner_id);
                           fnd_msg_pub.Add;
                           raise FND_API.G_EXC_ERROR;

                        end if;

                        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                                   itemkey  => p_itemKey,
                                                   aname    => pv_workflow_pub.g_wf_attr_partner_org,
                                                   avalue   => l_partner_org);

                        if l_assignment_status = pv_assignment_pub.g_la_status_cm_rejected then

                           open lc_get_responding_cm (pc_itemtype   => p_itemtype,
                                                      pc_itemkey    => p_itemkey,
                                                      pc_partner_id => l_partner_id,
                                                      pc_response   => pv_assignment_pub.g_la_status_cm_rejected);

                           fetch lc_get_responding_cm into l_responding_cm;
                           close lc_get_responding_cm;

                           wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                                      itemkey  => p_itemKey,
                                                      aname    => pv_workflow_pub.g_wf_attr_responding_cm,
                                                      avalue   => l_responding_cm);

                        elsif l_assignment_status = pv_assignment_pub.g_la_status_pt_rejected then

                           open lc_get_reason (pc_itemtype   => p_itemtype,
                                               pc_itemkey    => p_itemkey,
                                               pc_partner_id => l_partner_id);

                           fetch lc_get_reason into l_reason;
                           close lc_get_reason;

                           wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                                      itemkey  => p_itemKey,
                                                      aname    => pv_workflow_pub.g_wf_attr_action_reason,
                                                      avalue   => l_reason);
                        end if;

                     end if;

                   -- for joint assignment, where there is potentially multiple partners that accepted
                   -- we need to set partner_id for the current partner so that if the current notification
                   -- requires this information, it will have it

                    wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'PV_NOTIFY_PT_ID_ATTR',
                               avalue   => l_partner_id);

                    debug('calling wf_notification.sendGroup');
                     l_group_notify_id := wf_notification.sendGroup(
                          role         => l_adhoc_role,
                          msg_type     => 'PVASGNMT',
                          msg_name     => l_msg_name,
                          due_date     => null,
                          callback     => 'wf_engine.cb',
                          context      => l_context,
                          send_comment => NULL,
                          priority     => NULL );

                     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_Token('TEXT', 'Sent notification to role: ' || l_adhoc_role ||
                                       ' using message: ' || l_msg_name || '.  Notify id: ' || l_group_notify_id );
                        fnd_msg_pub.Add;
                     end if;

                  end if;

                  if l_partner_id <> l_partner_id_tbl(i) then
                     l_partner_org := null;
                  end if;

                  l_usertype          := l_usertype_tbl(i);
                  l_partner_id        := l_partner_id_tbl(i);
                  l_assignment_status := l_assign_status_tbl(i);

                  l_role_list := empty_role_list;
                  l_role_list_index := 1;
                  l_role_list(l_role_list_index)      := l_username_tbl(i);
                  l_role_list_index := l_role_list_index + 1;

                  if l_exit_loop then
                     exit;
                  else
                     l_exit_loop := true;
                  end if;

               end loop;

            else
               debug( 'else clause' );
               l_role_list(l_role_list_index) := l_username_tbl(i);
               l_role_list_index := l_role_list_index +1;
            end if;

          end loop;

      end if; -- l_notify_enabled_flag

   else

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Email is diabled at site level');
         fnd_msg_pub.Add;
      end if;

   end if;    --l_email_enabled_flag

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN
      IF sqlcode = -20002 THEN

         fnd_message.Set_Name('PV', 'PV_WF_COMP_ACTY_ERR');
         fnd_msg_pub.Add;

      ELSE

         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end send_notification;

procedure AbandonWorkflow (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_creating_username   IN  VARCHAR2,
   p_attrib_values_rec   IN  attrib_values_rec_type,
   p_partner_org_name    IN  VARCHAR2,
   p_action_reason       IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

  l_api_name            CONSTANT VARCHAR2(30) := 'AbandonWorkflow';
  l_api_version_number  CONSTANT NUMBER       := 1.0;

  l_role_name           varchar2(30);
  l_email_enabled       varchar2(30);
  l_vendor_respond_URL  varchar2(100);
  l_pt_respond_URL      varchar2(100);
  l_itemKey             VARCHAR2(30);
  l_itemType            VARCHAR2(30) := pv_workflow_pub.g_wf_itemtype_pvasgnmt;


begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Itemtype: ' || l_itemtype);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select pv_lead_workflows_s.nextval into l_itemkey from dual;


   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Before Creating the workflow process with Itemtype: ' || l_itemtype);
      fnd_msg_pub.Add;
   END IF;


  wf_engine.CreateProcess ( ItemType => l_itemtype,
                            ItemKey  => l_itemkey,
                            process  => pv_workflow_pub.g_wf_pcs_abandon_fyi);

  wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_opportunity_id,
                               avalue   => p_attrib_values_rec.lead_id);

  wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_entity_name,
                               avalue   => p_attrib_values_rec.entity_name);

  wf_engine.SetItemAttrText( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_entity_amount,
                               avalue   => p_attrib_values_rec.entity_amount);

  wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_ext_org_party_id,
                               avalue   => p_attrib_values_rec.pt_org_party_id);

  wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => pv_workflow_pub.g_wf_attr_opp_number,
                              avalue   => p_attrib_values_rec.lead_number);

  wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_customer_name,
                               avalue   => p_attrib_values_rec.customer_name);

   wf_engine.SetItemAttrText (itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => pv_workflow_pub.g_wf_attr_assignment_type,
                              avalue   => p_attrib_values_rec.assignment_type);

   l_vendor_respond_url  := fnd_profile.value('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');
   l_pt_respond_url      := fnd_profile.value('PV_WORKFLOW_ISTORE_URL');

   wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => pv_workflow_pub.g_wf_attr_cm_respond_url,
                               avalue   => l_vendor_respond_URL);

   wf_engine.SetItemAttrText ( itemtype => l_itemType,
                               itemkey  => l_itemKey,
                               aname    => 'PV_PT_RESPOND_URL_ATTR',
                               avalue   => l_pt_respond_URL);

   wf_engine.SetItemAttrText (itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => pv_workflow_pub.g_wf_attr_action_reason,
                              avalue   => p_action_reason);

   wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => pv_workflow_pub.g_wf_attr_partner_org,
                              avalue   => p_partner_org_name);

   wf_engine.StartProcess(     itemtype => l_itemtype,
                              itemkey  => l_itemkey);


   PV_ASSIGN_UTIL_PVT.checkforErrors ( p_api_version_number   => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,p_commit              => FND_API.G_FALSE
           ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
           ,p_itemtype           => l_itemtype
           ,p_itemkey            => l_itemkey
           ,x_return_status      => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end AbandonWorkflow;


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string       IN VARCHAR2
)
IS

BEGIN
   FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);
   FND_MSG_PUB.Add;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Set_Message;
-- ==============================End of Set_Message==============================

End PV_ASSIGNMENT_PVT;

/

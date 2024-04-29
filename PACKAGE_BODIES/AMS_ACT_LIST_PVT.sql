--------------------------------------------------------
--  DDL for Package Body AMS_ACT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_LIST_PVT" as
/* $Header: amsvalsb.pls 120.10.12010000.2 2008/08/11 08:34:12 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_LIST_PVT
-- Purpose
-- History
-- NOTE    added fix for bug 3817224 on 08/06
-- 19-apr-2005  ndadwal code inclusions for Target Group Locking on ScheduleStatus change.
-- 17-Aug-2005  bmuthukr With R12 changes.
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Act_List_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvalsb.pls';
g_list_header_id  number;
g_count             NUMBER := 1;
g_remote_list	VARCHAR2(1) := 'N';
g_message_table  AMS_LISTGENERATION_PKG.sql_string;
g_message_table_null  AMS_LISTGENERATION_PKG.sql_string;
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE copy_selections
             (p_old_header_id in  number,
              p_new_header_id in number,
              p_list_name   IN varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_query_id OUT NOCOPY NUMBER
               );

PROCEDURE copy_list_queries
             ( p_old_header_id  IN NUMBER,
               p_new_header_id  IN NUMBER,
               p_list_name IN varchar2,
               p_old_query_id  IN NUMBER,
               x_msg_count      OUT NOCOPY number,
               x_msg_data       OUT NOCOPY varchar2,
               x_return_status  IN OUT NOCOPY VARCHAR2,
               x_new_query_id   OUT NOCOPY NUMBER
             );


PROCEDURE copy_query_list_params
          (p_old_query_id in  number,
           p_new_query_id in number,
           x_msg_count      OUT NOCOPY number,
           x_msg_data       OUT NOCOPY varchar2,
           x_return_status  IN OUT NOCOPY VARCHAR2
          );

PROCEDURE  copy_template_instance(
              p_query_templ_id in  number,
              p_old_header_id in  number,
              p_new_header_id in number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_old_templ_inst_id    OUT NOCOPY number,
              x_new_templ_inst_id  OUT NOCOPY number
             );

PROCEDURE  copy_conditions(
              p_old_templ_inst_id in  number,
              p_new_templ_inst_id in  number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
             );

PROCEDURE UPDATE_LIST_STATUS_TO_LOCKED
(
    P_OBJECT_TYPE    IN  VARCHAR2,
    P_OBJ_ID         IN  NUMBER,
    X_MSG_COUNT      OUT NOCOPY NUMBER,
    X_MSG_DATA       OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS  OUT NOCOPY VARCHAR2  );


PROCEDURE validate_segment
( p_cell_id                IN    NUMBER,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
)
is
   l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
   l_init_msg_list     VARCHAR2(2000) := FND_API.G_FALSE;
   l_api_name          CONSTANT VARCHAR2(30) := 'Validate Target Group Segment';
   l_action_rec        AMS_ListAction_PVT.action_rec_type ;
   l_action_id         NUMBER;
   l_cell_list_name    VARCHAR2(200);

   l_found                     VARCHAR2(1) := 'N';
   l_master_type               VARCHAR2(80);
   l_master_type_id            NUMBER;
   l_source_object_name        VARCHAR2(80);
   l_source_object_pk_field    VARCHAR2(80);
   l_from_position             NUMBER;
   l_from_counter              NUMBER;
   l_end_position              NUMBER;
   l_end_counter               NUMBER;
   l_sql_string                VARCHAR2(32767);
   l_return_status             VARCHAR2(1);

   l_count                     NUMBER;
   l_string_copy               VARCHAR2(32767);
   l_sql_string_tbl            AMS_ListGeneration_PKG.sql_string;
   l_length                    NUMBER;


   CURSOR c_get_cell_name IS
   SELECT cell_name
     FROM ams_cells_vl
    WHERE cell_id = p_cell_id;

   l_source_type varchar2(100);
   l_var  varchar2(1);

BEGIN

   OPEN c_get_cell_name ;
   FETCH c_get_cell_name into l_cell_list_name;
   CLOSE c_get_cell_name;


   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message(l_api_name||': validate ');
   END IF;
   AMS_CELL_PVT.get_single_sql(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_id            => p_cell_id,
      x_sql_string         => l_sql_string
   );
   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('get_single_sql status:' || l_return_status);
   END IF;
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('sql_string:' || length(l_sql_string));
   END IF;
   IF l_sql_string IS NULL OR
      l_sql_string = ''
   THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      --l_sql_string := UPPER(l_sql_string);

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('sql_string2:' || length(l_sql_string));
   END IF;
      l_count := 0;
      l_string_copy := l_sql_string;
      l_length := length(l_string_copy);

      LOOP
         l_count := l_count + 1;
         IF l_length < 1999 THEN
            l_sql_string_tbl(l_count) := l_string_copy;
            EXIT;
         ELSE
            l_sql_string_tbl(l_count) := substr(l_string_copy, 1, 2000);
            l_string_copy := substr(l_string_copy, 2000);
         END IF;
         l_length := length(l_string_copy);
      END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('validate string:' || length(l_sql_string));
   END IF;
      l_found := 'N';
      AMS_ListGeneration_PKG.validate_sql_string(
                      p_sql_string    => l_sql_string_tbl ,
                      p_search_string => 'FROM',
                      p_comma_valid   => 'N',
                      x_found         => l_found,
                      x_position      => l_from_position,
                      x_counter       => l_from_counter) ;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('FROM:' || l_found);
   END IF;
      IF l_found = 'N' THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_FROM_NOT_FOUND');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_found := 'N';

      AMS_ListGeneration_PKG.get_master_types (
                    p_sql_string => l_sql_string_tbl,
                    p_start_length => 1,
                    p_start_counter => 1,
                    p_end_length => l_from_position,
                    p_end_counter => l_from_counter,
                    x_master_type_id=> l_master_type_id,
                    x_master_type=> l_master_type,
                    x_found=> l_found,
                    x_source_object_name => l_source_object_name,
                    x_source_object_pk_field  => l_source_object_pk_field);

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('MASTER_TYPE:' || l_found);
   END IF;
      IF nvl(l_found,'N') = 'N'  THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_MASTER_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('sucess full:' );
   END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CELL_CREATE_LIST_ERROR');
      FND_MSG_PUB.Add;
      -- Check if reset of the status is required
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CELL_CREATE_LIST_ERROR');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
      FND_MESSAGE.set_name('AMS', 'AMS_CELL_CREATE_LIST_ERROR');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END validate_segment;

PROCEDURE logger is
--  This procedure was written to replace Autonomous Transactions
--
 l_return_status VARCHAR2(1);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT logger_save;

  FORALL I in g_message_table.first .. g_message_table.last
      INSERT INTO ams_act_logs (
         activity_log_id
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,object_version_number
         ,act_log_used_by_id
         ,arc_act_log_used_by
         ,log_transaction_id
         ,log_message_text
      )
      VALUES (
         ams_act_logs_s.NEXTVAL
         ,SYSDATE
         ,FND_GLOBAL.User_Id
         ,SYSDATE
         ,FND_GLOBAL.User_Id
         ,FND_GLOBAL.Conc_Login_Id
         ,1
         ,g_list_header_id
         ,'LIST'
         ,ams_act_logs_transaction_id_s.NEXTVAL
         ,g_message_table(i)
      ) ;
     commit;
exception
   -- Logger has failed
   when others then
      null;
END logger;



PROCEDURE WRITE_TO_ACT_LOG(p_msg_data in VARCHAR2,
                           p_arc_log_used_by in VARCHAR2 ,
                           p_log_used_by_id in  number,
                           p_level in varchar2 default 'LOW')
                           IS
 --PRAGMA AUTONOMOUS_TRANSACTION;
 l_return_status VARCHAR2(1);

BEGIN

   if nvl(ams_listgeneration_pkg.g_log_level,'HIGH') = 'HIGH' and p_level = 'LOW' then
      return;
   end if;

   ams_listgeneration_pkg.write_to_act_log(p_msg_data,p_arc_log_used_by,p_log_used_by_id,P_level);

   /* ams_listgeneration_pkg.g_message_table(ams_listgeneration_pkg.g_count) := p_msg_data;
   ams_listgeneration_pkg.g_date(ams_listgeneration_pkg.g_count) := sysdate;
   ams_listgeneration_pkg.g_count   := ams_listgeneration_pkg.g_count + 1;
   */

--  g_message_table(g_count) := p_msg_data;
--  g_count   := g_count + 1;
/*
  AMS_UTILITY_PVT.CREATE_LOG(
                             x_return_status    => l_return_status,
                             p_arc_log_used_by  => 'LIST',
                             p_log_used_by_id   => g_list_header_id,
                             p_msg_data         => p_msg_data);
*/
 -- COMMIT;
END WRITE_TO_ACT_LOG;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Act_List(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_act_list_rec          IN   act_list_rec_type  := g_miss_act_list_rec,
    x_act_list_header_id    OUT NOCOPY  NUMBER
     ) IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Act_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_ACT_LIST_HEADER_ID        NUMBER;
   l_dummy                     NUMBER;

    -- Get the smallest order number
    l_min_order number;
    cursor c_min_order is
    SELECT nvl(Min(order_number),-1)
    FROM   ams_act_lists
    WHERE list_used_by_id = p_act_list_rec.list_used_by_id and
          list_used_by = p_act_list_rec.list_used_by and
          list_act_type <> 'TARGET';

    -- Get list action type where order num is the smallest
    Cursor c_min_list_action_type IS
    SELECT list_action_type
    FROM   ams_act_lists
    WHERE list_used_by_id = p_act_list_rec.list_used_by_id and
          list_used_by = p_act_list_rec.list_used_by and
          list_act_type <> 'TARGET' and
  order_number = l_min_order;
    l_action_type varchar2(30);


   CURSOR c_id IS
      SELECT AMS_ACT_LISTS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM AMS_ACT_LISTS
      WHERE ACT_LIST_HEADER_ID = l_id;
    l_act_list_rec          act_list_rec_type  := p_act_list_rec;

   cursor c_check_group (cur_group_code in varchar2) is
   select alg.act_list_group_id
   from ams_act_list_groups  alg,
        ams_act_lists acl
   where alg.arc_act_list_used_by = 'TARGET'
    and  alg.group_code    = cur_group_code
    and  alg.act_list_used_by_id = acl.list_header_id
    and  acl.list_used_by = 'LIST'
    and  acl.list_used_by_id = p_act_list_rec.list_used_by_id
    and  acl.list_act_type = 'TARGET' ;
l_list_group_rec    AMS_List_Group_PVT.list_group_rec_type;
l_act_list_group_id   number;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_Act_List_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- The first action with the smallest order number should be INCLUDE

   open   c_min_order;
   fetch  c_min_order into l_min_order;
   close  c_min_order;

   if (l_min_order <> -1 ) and  (l_min_order < p_act_list_rec.order_number ) then
      OPEN  c_min_list_action_type;
      FETCH c_min_list_action_type INTO l_action_type;
      CLOSE c_min_list_action_type;
   else
      l_action_type := p_act_list_rec.list_action_type;
   end if;
   IF  l_action_type <> FND_API.G_MISS_CHAR
   AND l_action_type IS NOT NULL THEN
      IF(l_action_type <>'INCLUDE')THEN
         IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_FIRST_INCLUDE');
             FND_MSG_PUB.Add;
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
      END IF;   --end if l_action_type <>'INCLUDE'
   END IF;-- end  IF  l_action_type <> FND_API.G_MISS_CHAR


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF l_act_list_rec.ACT_LIST_HEADER_ID IS NULL OR
      l_act_list_rec.ACT_LIST_HEADER_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_ACT_LIST_HEADER_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_ACT_LIST_HEADER_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   END IF;
    x_act_list_header_id    :=  l_act_list_header_id ;
    l_act_list_rec.ACT_LIST_HEADER_ID  := x_act_list_header_id;
-- =========================================================================
-- Validate Environment
-- =========================================================================

  IF FND_GLOBAL.User_Id IS NULL
  THEN
    AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
  THEN
     -- Debug message
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('Private API: Validate_Act_List');
     END IF;
     -- Invoke validation procedures
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_Utility_PVT.debug_message('1)validate act_list  ' || x_return_status );
     END IF;

     Validate_act_list(
        p_api_version_number     => 1.0,
        p_init_msg_list    => FND_API.G_FALSE,
        p_validation_level => p_validation_level,
        p_act_list_rec  =>  l_act_list_rec,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);



    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message('2)validate act list ->' || x_return_status );
    END IF;
  END IF;

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;


   if  l_act_list_rec.list_act_type <> 'TARGET'
       and l_act_list_rec.group_code is not null then
  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message( 'Private API: Call Group code handler');
  END IF;
       l_act_list_group_id := null;
       open c_check_group (l_act_list_rec.group_code ) ;
       fetch c_check_group into l_act_list_group_id ;
       close c_check_group ;
       l_list_group_rec.group_code := l_act_list_rec.group_code ;
       l_list_group_rec.act_list_used_by_id := p_act_list_rec.list_used_by_id;
       l_list_group_rec.arc_act_list_used_by := 'TARGET';
       l_list_group_rec.last_update_date := sysdate;
       l_list_group_rec.last_updated_by := fnd_global.user_id;
       l_list_group_rec.creation_date    := sysdate;
       l_list_group_rec.created_by := fnd_global.user_id;
       if l_act_list_group_id is null  then
           AMS_List_Group_PVT.Create_List_Group(
            p_api_version_number         => 1.0,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            p_list_group_rec             => l_list_group_rec,
            x_act_list_group_id          => l_act_list_group_id
             );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
       end if;
   end if;

  -- Invoke table handler(AMS_ACT_LISTS_PKG.Insert_Row)
  -- Debug Message
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message( 'Private API: Call create table handler');
  END IF;

  AMS_ACT_LISTS_PKG.Insert_Row(
          px_act_list_header_id  => l_act_list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          px_object_version_number  => l_object_version_number,
          p_last_update_login  => FND_GLOBAL.conc_LOGIN_ID,
          p_list_header_id  => l_act_list_rec.list_header_id,
          p_group_code        => l_act_list_rec.group_code     ,
          p_list_used_by_id  => l_act_list_rec.list_used_by_id,
          p_list_used_by  => l_act_list_rec.list_used_by,
          p_list_act_type  => l_act_list_rec.list_act_type,
          p_list_action_type  => l_act_list_rec.list_action_type,
  p_order_number => l_act_list_rec.order_number
          );


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

--
-- End of API body
--
 --Inserted vbhandar 04/21 to copy metrics
  IF (l_act_list_rec.list_act_type = 'LIST') AND
     (l_act_list_rec.list_action_type = 'INCLUDE') THEN

   Ams_Refreshmetric_Pvt. Copy_Seeded_Metric (
   p_api_version                => 1.0,
   p_init_msg_list              => Fnd_Api.G_FALSE,
   p_commit                     => Fnd_Api.G_FALSE,
   x_return_status              => x_return_status,
   x_msg_count                  => x_msg_count,
   x_msg_data                   => x_msg_data,
   p_arc_act_metric_used_by=> 'ALIST',
   p_act_metric_used_by_id => l_act_list_header_id,
   p_act_metric_used_by_type    => null
);
  END IF;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

 --end  vbhandar 04/21 to copy metrics


      -- Standard check for p_commit
 IF FND_API.to_Boolean( p_commit )
 THEN
   COMMIT WORK;
 END IF;


 -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN

 AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'end');
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get
 (p_count          =>   x_msg_count,
 p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Act_List;

PROCEDURE     init_act_list_Rec (
   x_act_list_rec OUT NOCOPY act_list_rec_type)
IS
BEGIN
   x_act_list_rec.act_list_header_id := FND_API.g_miss_num ;
   x_act_list_rec.group_code := FND_API.g_miss_char ;
   x_act_list_rec.last_update_date := FND_API.g_miss_date ;
   x_act_list_rec.last_updated_by := FND_API.g_miss_num ;
   x_act_list_rec.creation_date := FND_API.g_miss_date ;
   x_act_list_rec.created_by := FND_API.g_miss_num ;
   x_act_list_rec.object_version_number := FND_API.g_miss_num ;
   x_act_list_rec.last_update_login := FND_API.g_miss_num ;
   x_act_list_rec.list_header_id := FND_API.g_miss_num ;
   x_act_list_rec.list_used_by_id := FND_API.g_miss_num ;
   x_act_list_rec.list_used_by := FND_API.g_miss_char ;
   x_act_list_rec.list_act_type := FND_API.g_miss_char ;
   x_act_list_rec.list_action_type := FND_API.g_miss_char ;
   x_act_list_rec.order_number := FND_API.g_miss_num ;

END init_act_list_Rec;

PROCEDURE Complete_act_list_Rec (
   p_act_list_rec IN act_list_rec_type,
   x_complete_rec OUT NOCOPY act_list_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_act_lists
      WHERE act_list_header_id = p_act_list_rec.act_list_header_id;
   l_act_list_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_act_list_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_act_list_rec;
   CLOSE c_complete;

   -- act_list_header_id
   IF p_act_list_rec.act_list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.act_list_header_id := l_act_list_rec.act_list_header_id;
   END IF;

   IF p_act_list_rec.group_code = FND_API.g_miss_char THEN
      x_complete_rec.group_code := l_act_list_rec.group_code;
   END IF;

   -- last_update_date
   IF p_act_list_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_act_list_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_act_list_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_act_list_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_act_list_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_act_list_rec.creation_date;
   END IF;

   -- created_by
   IF p_act_list_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_act_list_rec.created_by;
   END IF;

   -- object_version_number
   IF p_act_list_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_act_list_rec.object_version_number;
   END IF;

   -- last_update_login
   IF p_act_list_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_act_list_rec.last_update_login;
   END IF;

   -- list_header_id
   IF p_act_list_rec.list_header_id = FND_API.g_miss_num THEN
      x_complete_rec.list_header_id := l_act_list_rec.list_header_id;
   END IF;

   -- list_used_by_id
   IF p_act_list_rec.list_used_by_id = FND_API.g_miss_num THEN
      x_complete_rec.list_used_by_id := l_act_list_rec.list_used_by_id;
   END IF;

   -- list_used_by
   IF p_act_list_rec.list_used_by = FND_API.g_miss_char THEN
      x_complete_rec.list_used_by := l_act_list_rec.list_used_by;
   END IF;
   -- list_act_type
   IF p_act_list_rec.list_act_type = FND_API.g_miss_char THEN
      x_complete_rec.list_act_type := l_act_list_rec.list_act_type;
   END IF;
   -- list_action_type
   IF p_act_list_rec.list_action_type = FND_API.g_miss_char THEN
      x_complete_rec.list_action_type := l_act_list_rec.list_action_type;
   END IF;
   -- order number
   IF p_act_list_rec.order_number = FND_API.g_miss_num THEN
      x_complete_rec.order_number := l_act_list_rec.order_number;
   END IF;


   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_act_list_Rec;

PROCEDURE Update_Act_List(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_act_list_rec           IN    act_list_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER
    )

 IS
    -- Get the smallest order number
    l_min_order number;
    cursor c_min_order is
    SELECT nvl(Min(order_number),-1)
    FROM   ams_act_lists
    WHERE list_used_by_id = p_act_list_rec.list_used_by_id and
          list_used_by = p_act_list_rec.list_used_by and
          list_act_type <> 'TARGET';

    -- Get list action type where order num is the smallest
    Cursor c_min_list_action_type IS
    SELECT list_action_type
    FROM   ams_act_lists
    WHERE list_used_by_id = p_act_list_rec.list_used_by_id and
          list_used_by = p_act_list_rec.list_used_by and
          list_act_type <> 'TARGET' and
  order_number = l_min_order;
    l_action_type varchar2(30);

CURSOR c_get_act_list(cur_act_list_header_id NUMBER) IS
    SELECT *
    FROM  AMS_ACT_LISTS
   where  act_list_header_id = cur_act_list_header_id ;
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Act_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   cursor c_check_group (cur_group_code in varchar2) is
   select alg.act_list_group_id
   from ams_act_list_groups  alg,
        ams_act_lists acl
   where alg.arc_act_list_used_by = 'TARGET'
    and  alg.group_code    = cur_group_code
    and  p_act_list_rec.list_header_id =  alg.act_list_used_by_id
    and  acl.list_used_by = 'LIST'
    and  acl.list_used_by_id = p_act_list_rec.list_used_by_id
    and  acl.list_act_type = 'TARGET' ;
-- Local Variables
l_object_version_number     NUMBER;
l_ACT_LIST_HEADER_ID    NUMBER;
l_ref_act_list_rec  c_get_Act_List%ROWTYPE ;
l_tar_act_list_rec  AMS_Act_List_PVT.act_list_rec_type := P_act_list_rec;
l_act_list_rec      AMS_Act_List_PVT.act_list_rec_type := P_act_list_rec;
l_rowid  ROWID;
       l_act_list_group_id number;

l_list_group_rec    AMS_List_Group_PVT.list_group_rec_type;
l_action_cnt NUMBER;
BEGIN
 -- Standard Start of API savepoint
 SAVEPOINT UPDATE_Act_List_PVT;
 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

   -- The first action with the smallest order number should be INCLUDE
   open   c_min_order;
   fetch  c_min_order into l_min_order;
   close  c_min_order;

--   if (l_min_order <> -1 ) and  (l_min_order < p_act_list_rec.order_number and l_act_list_header_id <> p_act_list_rec.act_list_header_id ) then
   if (l_min_order <> -1 ) and  (l_min_order < p_act_list_rec.order_number) then

      OPEN  c_min_list_action_type;
      FETCH c_min_list_action_type INTO l_action_type;
      CLOSE c_min_list_action_type;
   else
      l_action_type := p_act_list_rec.list_action_type;
   end if;
   IF  l_action_type <> FND_API.G_MISS_CHAR
   AND l_action_type IS NOT NULL THEN
      IF(l_action_type <>'INCLUDE')THEN
         IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_FIRST_INCLUDE');
             FND_MSG_PUB.Add;
         END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
      END IF;   --end if l_action_type <>'INCLUDE'
   END IF;-- end  IF  l_action_type <> FND_API.G_MISS_CHAR




 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list )
 THEN
         FND_MSG_PUB.initialize;
 END IF;

 -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN

 AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
 END IF;

 -- Initialize API return status to SUCCESS
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN

 AMS_Utility_PVT.debug_message('Private API: - Open Cursor to Select');
 END IF;

 OPEN c_get_Act_List( l_tar_act_list_rec.act_list_header_id);
 FETCH c_get_Act_List INTO l_ref_act_list_rec  ;
 If ( c_get_Act_List%NOTFOUND) THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
      'AMS_API_MISSING_UPDATE_TARGET',
      p_token_name   => 'INFO',
      p_token_value  => 'Act_List') ;
      RAISE FND_API.G_EXC_ERROR;
 END IF;
         -- Debug Message
 IF (AMS_DEBUG_HIGH_ON) THEN

 AMS_Utility_PVT.debug_message('Private API: - Close Cursor');
 END IF;
 CLOSE     c_get_Act_List;


 If (l_tar_act_list_rec.object_version_number is NULL or
     l_tar_act_list_rec.object_version_number = FND_API.G_MISS_NUM ) Then
     AMS_Utility_PVT.Error_Message(p_message_name =>
                                              'AMS_API_VERSION_MISSING',
                                        p_token_name   => 'COLUMN',
                                        p_token_value  => 'Last_Update_Date') ;
     raise FND_API.G_EXC_ERROR;
 End if;
      -- Check Whether record has been changed by someone else
 If (l_tar_act_list_rec.object_version_number <>
            l_ref_act_list_rec.object_version_number) Then
     AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                       p_token_name   => 'INFO',
                                       p_token_value  => 'Act_List') ;
     raise FND_API.G_EXC_ERROR;
 End if;

 -- Complete rec
  Complete_act_list_Rec(
         p_act_list_rec        => p_act_list_rec,
         x_complete_rec        => l_act_list_rec
      );
 IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
 THEN

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message('Private API: Validate_Act_List');

    END IF;

    -- Invoke validation procedures
    Validate_act_list(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_act_list_rec  =>  l_act_list_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
 END IF;

 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
 END IF;



   if  l_act_list_rec.list_act_type <> 'TARGET'
       and l_act_list_rec.group_code is not null then
       l_act_list_group_id := null;
       open c_check_group (l_act_list_rec.group_code ) ;
       fetch c_check_group into l_act_list_group_id ;
       close c_check_group ;
       l_list_group_rec.group_code := l_act_list_rec.group_code ;
       l_list_group_rec.act_list_used_by_id := l_act_list_rec.list_used_by_id;
       l_list_group_rec.arc_act_list_used_by := 'TARGET';
       l_list_group_rec.last_update_date := sysdate;
       l_list_group_rec.last_updated_by := fnd_global.user_id;
       l_list_group_rec.creation_date    := sysdate;
       l_list_group_rec.created_by := fnd_global.user_id;

       if l_act_list_group_id is null  then
           AMS_List_Group_PVT.Create_List_Group(
            p_api_version_number         => 1.0,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => x_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            p_list_group_rec             => l_list_group_rec,
            x_act_list_group_id          => l_act_list_group_id
             );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
       end if;
    end if;

 AMS_ACT_LISTS_PKG.Update_Row(
          p_act_list_header_id  => l_act_list_rec.act_list_header_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_object_version_number  => p_act_list_rec.object_version_number,
          p_last_update_login  => FND_GLOBAL.conc_LOGIN_ID,
          p_list_header_id  => l_act_list_rec.list_header_id,
          p_group_code       => l_act_list_rec.group_code,
          p_list_used_by_id  => l_act_list_rec.list_used_by_id,
          p_list_used_by  => l_act_list_rec.list_used_by,
          p_list_act_type   => l_act_list_rec.list_act_type,
          p_list_action_type   => l_act_list_rec.list_action_type,
  p_order_number => l_act_list_rec.order_number
          );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Act_List;


PROCEDURE Delete_Act_List(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,
    p_act_list_header_id     IN  NUMBER,
    p_object_version_number  IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Act_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

cursor c1 is
select 'x'
from  ams_act_lists  a, ams_campaign_schedules_vl b
where act_list_header_id = p_act_list_header_id
and   a.list_used_by_id = b.schedule_id
and   a.list_used_by = 'CSCH'
and   b.status_code = 'ACTIVE'
union
select 'x'
from  ams_act_lists  a, ams_event_offers_vl b
where p_act_list_header_id = p_act_list_header_id
and   a.list_used_by_id = b.event_offer_id
and   a.list_used_by in('EVEO','EONE')
and   b.system_status_code = 'ACTIVE';
l_char varchar2(1) := 'Y';
 BEGIN
  open c1;
  fetch c1 into  l_char ;
  close c1;
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Act_List_PVT;

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
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message( 'Private API: Calling delete table
                                       handler');
      END IF;

      -- Invoke table handler(AMS_ACT_LISTS_PKG.Delete_Row)
      if l_char =   'x' then
       FND_MESSAGE.set_name('AMS', 'AMS_DELETE_TARGET');
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
      else
         AMS_ACT_LISTS_PKG.Delete_Row(
             p_ACT_LIST_HEADER_ID  => p_ACT_LIST_HEADER_ID);
      end if;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Act_List;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Act_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_act_list_header_id         IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Act_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'||
                                                     l_api_name;
l_ACT_LIST_HEADER_ID                  NUMBER;
CURSOR c_Act_List IS
   SELECT ACT_LIST_HEADER_ID
   FROM AMS_ACT_LISTS
   WHERE ACT_LIST_HEADER_ID = p_ACT_LIST_HEADER_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message(l_full_name||': start');

  END IF;
  OPEN c_Act_List;

  FETCH c_Act_List INTO l_ACT_LIST_HEADER_ID;

  IF (c_Act_List%NOTFOUND) THEN
    CLOSE c_Act_List;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Act_List;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Act_List_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Lock_Act_List;


PROCEDURE check_act_list_uk_items(
    p_act_list_rec               IN   act_list_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

CURSOR c_check_act_list_uniqueness(
    p_list_used_by_id NUMBER,
    p_list_used_by VARCHAR,
    p_list_act_type VARCHAR,
    p_list_header_id NUMBER,
    p_act_list_header_id NUMBER)
IS
   SELECT count(1) FROM ams_act_lists
       WHERE list_used_by_id = p_list_used_by_id
          AND list_used_by = p_list_used_by
          AND LIST_ACT_TYPE =  p_LIST_ACT_TYPE
          AND list_header_id = p_list_header_id
          AND act_list_header_id <> p_act_list_header_id;

l_count NUMBER;
BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_LISTS',
         'ACT_LIST_HEADER_ID = ' || p_act_list_rec.ACT_LIST_HEADER_ID
         ||' AND LIST_ACT_TYPE =  ' ||''''|| p_act_list_rec.LIST_ACT_TYPE||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'AMS_ACT_LISTS',
         'ACT_LIST_HEADER_ID = ' || p_act_list_rec.ACT_LIST_HEADER_ID
         ||' AND LIST_ACT_TYPE =  ' ||''''|| p_act_list_rec.LIST_ACT_TYPE||''''
         ||' AND ACT_LIST_HEADER_ID <> ' || p_act_list_rec.ACT_LIST_HEADER_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name =>
                                       'AMS_ACT_LIST_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
             'ams_act_lists',
                'list_used_by_id = ' || p_act_list_rec.list_used_by_id||
                ' and list_used_by = '||''''||p_act_list_rec.list_used_by||''''
         ||' AND LIST_ACT_TYPE =  ' || ''''||p_act_list_rec.LIST_ACT_TYPE||''''
                ||' and list_header_id = '||p_act_list_rec.list_header_id
                        )  ;
      ELSE
   /* dmvincen BUG 3792776: Too many variables for auto binding.
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
             'ams_act_lists',
                'list_used_by_id = ' || p_act_list_rec.list_used_by_id||
                ' and list_used_by = '||''''||p_act_list_rec.list_used_by||''''
         ||' AND LIST_ACT_TYPE =  ' || ''''||p_act_list_rec.LIST_ACT_TYPE||''''
                ||' and list_header_id = '||p_act_list_rec.list_header_id
         || ' and act_list_header_id <> ' || p_act_list_rec.act_list_header_id
         );
   */
      open c_check_act_list_uniqueness(
           p_act_list_rec.list_used_by_id,
           p_act_list_rec.list_used_by,
           p_act_list_rec.List_act_type,
           p_act_list_rec.list_header_id,
           p_act_list_rec.act_list_Header_id);
         fetch c_check_act_list_uniqueness into l_count;
      close c_checK_act_list_uniqueness;
      IF l_count >= 1 THEN
         l_valid_flag := FND_API.G_FALSE;
      ELSE
         l_valid_flag := FND_API.G_TRUE;
      END IF;
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         AMS_Utility_PVT.Error_Message(p_message_name =>
                                       'AMS_ACT_LIST_USED_DUP');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_act_list_uk_items;

PROCEDURE check_act_list_req_items(
    p_act_list_rec               IN  act_list_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

IF p_validation_mode = JTF_PLSQL_API.g_create THEN

  IF p_act_list_rec.list_header_id = FND_API.g_miss_num OR
     p_act_list_rec.list_header_id IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
                                     'AMS_API_MISSING_FIELD');
               FND_MESSAGE.set_token('MISS_FIELD',
                                      'LIST_HEADER_ID' );
             x_return_status := FND_API.g_ret_sts_error;
            RETURN;
  END IF;


  IF p_act_list_rec.list_used_by_id = FND_API.g_miss_num OR
     p_act_list_rec.list_used_by_id IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
                                     'AMS_USER_PROFILE_MISSING');
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
  END IF;


  IF p_act_list_rec.list_used_by = FND_API.g_miss_char OR
    p_act_list_rec.list_used_by IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
                                     'AMS_API_MISSING_FIELD');
               FND_MESSAGE.set_token('MISS_FIELD',
                                      'LIST_USED_BY' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
  END IF;
  IF p_act_list_rec.list_act_type = FND_API.g_miss_char OR
    p_act_list_rec.list_act_type IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
                                     'AMS_API_MISSING_FIELD');
               FND_MESSAGE.set_token('MISS_FIELD',
                                      'LIST_ACT_TYPE' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
  END IF;


ELSE
/* Update Record */
  IF p_act_list_rec.act_list_header_id IS NULL THEN
      AMS_Utility_PVT.Error_Message(p_message_name =>
                                     'AMS_API_MISSING_FIELD');
               FND_MESSAGE.set_token('MISS_FIELD',
                                      'ACT_LIST_HEADER_ID' );
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
  END IF;

 IF p_act_list_rec.list_header_id IS NULL THEN
    AMS_Utility_PVT.Error_Message(p_message_name =>
                                  'AMS_API_RESOURCE_LOCKED');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
 END IF;


 IF p_act_list_rec.list_used_by_id IS NULL THEN
    AMS_Utility_PVT.Error_Message(p_message_name =>
      'AMS_API_RESOURCE_LOCKED');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
 END IF;


 IF p_act_list_rec.list_used_by IS NULL THEN
    AMS_Utility_PVT.Error_Message(p_message_name =>
          'AMS_API_RESOURCE_LOCKED');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
 END IF;

 IF p_act_list_rec.list_act_type IS NULL THEN
    AMS_Utility_PVT.Error_Message(p_message_name =>
          'AMS_API_RESOURCE_LOCKED');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
 END IF;


END IF;

END check_act_list_req_items;

PROCEDURE check_act_list_FK_items(
    p_act_list_rec IN act_list_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS

 l_table_name varchar2(100);
 l_pk_name    varchar2(100);
 l_list_act_type varchar2(60);

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_act_list_rec.list_used_by <> FND_API.g_miss_char THEN
      AMS_Utility_PVT.get_qual_table_name_and_pk(
      p_sys_qual        => p_act_list_rec.list_used_by,
      x_return_status   => x_return_status,
      x_table_name      => l_table_name,
      x_pk_name         => l_pk_name
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
      END IF;

      IF p_act_list_rec.list_used_by_id <> FND_API.g_miss_num THEN
         IF ( AMS_Utility_PVT.Check_FK_Exists(l_table_name
                                              , l_pk_name
                                              , p_act_list_rec.list_used_by_id)
                                              = FND_API.G_TRUE)
         THEN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

         ELSE
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                       FND_MESSAGE.set_name('AMS', 'AMS_SCHEDULE_ID_MISSING');
                       FND_MSG_PUB.Add;
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;
   IF p_act_list_rec.list_header_id <> FND_API.g_miss_num THEN

     if p_act_list_rec.list_act_type = 'TARGET' or p_act_list_rec.list_act_type = 'EMPLOYEE' then
        l_list_act_type := 'LIST';
     else
        l_list_act_type := p_act_list_rec.list_act_type ;
     end if;
      AMS_Utility_PVT.get_qual_table_name_and_pk(
      p_sys_qual        => l_list_act_type,
      x_return_status   => x_return_status,
      x_table_name      => l_table_name,
      x_pk_name         => l_pk_name
      );

      IF x_return_status <> FND_API.g_ret_sts_success THEN
        RETURN;
      END IF;

      IF ( AMS_Utility_PVT.Check_FK_Exists(l_table_name
                                         , l_pk_name
                                         , p_act_list_rec.list_header_id)
                                           = FND_API.G_TRUE)
      THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;

      ELSE
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ID_MISSING');
            FND_MSG_PUB.Add;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

END check_act_list_FK_items;

PROCEDURE check_act_list_Lookup_items(
    p_act_list_rec IN act_list_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here
   IF p_act_list_rec.list_act_type <> 'TARGET' and p_act_list_rec.list_act_type <> 'EMPLOYEE' then
      IF p_act_list_rec.list_act_type <> FND_API.g_miss_char THEN
         IF AMS_Utility_PVT.check_lookup_exists(
               p_lookup_type => 'AMS_LIST_ACT_TYPE',
               p_lookup_code => p_act_list_rec.list_act_type
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_TYPE_INVALID');
               FND_MESSAGE.set_token('LIST_ACT_TYPE',
                                             p_act_list_rec.list_act_type);
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;

   -- Check list_action_type
   IF p_act_list_rec.list_action_type <> FND_API.g_miss_char THEN
         IF AMS_Utility_PVT.check_lookup_exists(
               p_lookup_type => 'AMS_LIST_SELECT_ACTION',
               p_lookup_code => p_act_list_rec.list_action_type
            ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_LIST_ACT_TYPE_INVALID');
               FND_MESSAGE.set_token('LIST_ACT_TYPE', p_act_list_rec.list_action_type);
               FND_MSG_PUB.add;
            END IF;

            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
END check_act_list_Lookup_items;

PROCEDURE Check_act_list_Items (
    P_act_list_rec     IN    act_list_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success ;
   -- Check Items Uniqueness API calls

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message('validate uk items' );

  END IF;
   check_act_list_uk_items(
      p_act_list_rec => p_act_list_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message('validate req items' );

  END IF;
   check_act_list_req_items(
      p_act_list_rec => p_act_list_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Foreign Keys API calls
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message('validate fk items' );
  END IF;

   check_act_list_FK_items(
      p_act_list_rec => p_act_list_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_Utility_PVT.debug_message('validate lookups items' );

  END IF;
   check_act_list_Lookup_items(
      p_act_list_rec => p_act_list_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message('validate end of check act list');
  END IF;

END Check_act_list_Items;


PROCEDURE Validate_act_list(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_act_list_rec               IN   act_list_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Act_List';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_act_list_rec  AMS_Act_List_PVT.act_list_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Act_List_;



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

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('act_list val->' || p_validation_level );
       END IF;
              Check_act_list_Items(
                 p_act_list_rec        => p_act_list_rec,
                 p_validation_mode   => JTF_PLSQL_API.g_update,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_act_list_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_act_list_rec           =>    l_act_list_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;



  IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('validate act_list  after_act_list_rec' || x_return_status );
  END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Act_List_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Act_List_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Act_List_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Validate_Act_List;


PROCEDURE Validate_act_list_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_act_list_rec               IN    act_list_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('Private API: Validate_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_act_list_Rec;


PROCEDURE create_target_group_list
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by_name      in      VARCHAR2,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  p_list_type              in      VARCHAR2   := 'TARGET' ,
  p_owner_user_id          in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2,
  x_list_header_id         OUT NOCOPY     NUMBER  )  IS
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_act_list_rec      AMS_Act_List_PVT.act_list_rec_type  ;
l_api_name          constant varchar2(30) := 'Create_List';
l_api_version               CONSTANT NUMBER   := 1.0;
l_act_list_header_id    number;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Act_List_PVT';
l_count     number;
cursor c1 is
select count(1)
from  ams_act_lists
where list_used_by = p_list_used_by
and   list_used_by_id = p_list_used_by_id
and   list_act_type = 'TARGET' ;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  /*
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_ListGeneration_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;
*/
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  open c1;
  fetch c1 into  l_count ;
  close c1;
  if l_count =  0 then
     ams_listheader_pvt.init_listheader_rec(l_list_header_rec);
     l_list_header_rec.list_name :=  p_list_used_by_name      ;
     l_list_header_rec.list_type :=  'TARGET';
     l_list_header_rec.owner_user_id :=  p_owner_user_id;
     AMS_ListHeader_PVT.Create_Listheader
     ( p_api_version           => 1.0,
     p_init_msg_list           => p_init_msg_list,
     p_commit                  => p_commit,
     p_validation_level        => p_validation_level ,
     x_return_status           => x_return_status,
     x_msg_count               => x_msg_count,
     x_msg_data                => x_msg_data,
     p_listheader_rec          => l_list_header_rec,
     x_listheader_id           => x_list_header_id
     );

     l_act_list_rec.list_header_id   := x_list_header_id;
     l_act_list_rec.list_used_by     := p_list_used_by;
     l_act_list_rec.list_used_by_id  := p_list_used_by_id;
     l_act_list_rec.list_act_type    := 'TARGET';

     AMS_Act_List_PVT.Create_Act_List(
       p_api_version_number    => p_api_version,
       p_init_msg_list         => p_init_msg_list,
       p_commit                => p_commit,
       p_validation_level      => p_validation_level,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_act_list_rec          => l_act_list_rec  ,
       x_act_list_header_id    => l_act_list_header_id
        ) ;


     if x_return_status <> FND_API.g_ret_sts_success  THEN
        RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
  FND_MESSAGE.Set_Name('AMS', 'AMS_API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ACT_LIST.list_creation: ');
  FND_MSG_PUB.Add;
  END IF;


  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ACT_LIST.list_act_creation: END');
  FND_MSG_PUB.Add;
  END IF; */
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END create_target_group_list;

PROCEDURE Control_Group_Generation(
                  p_list_header_id  IN NUMBER,
                  p_pct_random      IN NUMBER,
                  p_no_random       IN NUMBER,
                  p_total_rows      IN NUMBER,
                  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2) IS
TYPE l_entries_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_list_entries_id    l_entries_table_type ;
l_total_random_rows  NUMBER ;
l_list_entry_count   number;

CURSOR c_list_entries (p_list_header_id IN number ) is
SELECT list_entry_id
  FROM ams_list_entries
 WHERE list_header_id = p_list_header_id
   AND enabled_flag  = 'Y'
ORDER BY randomly_generated_number ;

CURSOR c_get_count (p_list_header_id IN number ) is
SELECT count(1)
  FROM ams_list_entries
 WHERE list_header_id = p_list_header_id
   AND enabled_flag = 'Y';

BEGIN
   write_to_act_log('Executing procedure control group generation in the remote instance.','LIST',p_list_header_id,'LOW');

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   open c_get_count(p_list_header_id);
   fetch c_get_count into l_list_entry_count;
   close c_get_count;

   write_to_act_log(p_pct_random||'% of rows to be generated for control group','LIST',p_list_header_id,'LOW');
   write_to_act_log(l_list_entry_count||' are there in the list for control group generation','LIST',p_list_header_id,'LOW');

   if nvl(p_pct_random,0) <> 0 then
      l_total_random_rows  := FLOOR ((l_list_entry_count * p_pct_random) / 100);
   else
      l_total_random_rows  := p_no_random ;
   end if;

   DBMS_RANDOM.initialize (TO_NUMBER (TO_CHAR (SYSDATE, 'SSSSDD')));

   UPDATE ams_list_entries
      SET randomly_generated_number = DBMS_RANDOM.random
    WHERE list_header_id  = p_list_header_id
      and enabled_flag = 'Y';

   write_to_act_log('Randomly generated number assigned to '||sql%rowcount||' list entries','LIST',p_list_header_id,'LOW');

   DBMS_RANDOM.terminate;

   OPEN c_list_entries (p_list_header_id);
   FETCH c_list_entries BULK COLLECT INTO l_list_entries_id LIMIT l_total_random_rows;
   CLOSE c_list_entries;

   FORALL i in l_list_entries_id.FIRST .. l_list_entries_id.LAST
      UPDATE ams_list_entries
         SET part_of_control_group_flag = 'Y',
             enabled_flag = 'N'
       WHERE list_header_id  = p_list_header_id
         AND list_entry_id   = l_list_entries_id(i);

    write_to_act_log(sql%rowcount||' entries made part of the control group for this target group.', 'LIST', g_list_header_id,'HIGH');
    write_to_act_log('Procedure control_group_generation executed successfully. ','LIST', g_list_header_id,'LOW');

exception
   when others then
      write_to_act_log(p_msg_data => 'Error while executing control_group_generation procedure '||sqlcode||'  '||sqlerrm,
                       p_arc_log_used_by => 'LIST',
                       p_log_used_by_id  => g_list_header_id,
		       p_level=>'HIGH');
      x_msg_count := 1;
      x_msg_data := 'Error during CG generation'||' '|| sqlcode || '-->'||sqlerrm;
      x_return_status  :=  'E'; --  FND_API.G_RET_STS_ERROR ;
END Control_Group_Generation;

PROCEDURE apply_supp(p_list_header_id in NUMBER,
	             p_sql_string in VARCHAR2,
	             p_media_id in NUMBER,
	             p_source_type in VARCHAR2,
		     p_supp_type   in varchar2,
	             x_return_status  out nocopy    varchar2,
                     x_msg_count      out nocopy    number,
                     x_msg_data       out nocopy    varchar2
	             ) IS

l_list_header_id NUMBER;

--to get the set of suppression lists
--associated with the TG's execution channel,
--tied to the same datasource as the TG, and
--the status in AVAILABLE or LOCKED
CURSOR c_get_list(l_source_type VARCHAR2, l_media_id NUMBER) is
SELECT acr.list_header_id
  FROM ams_list_cont_restrictions acr,
       ams_list_headers_all alh
 WHERE acr.list_header_id  =  alh.list_header_id
   AND alh.status_code in ('AVAILABLE','LOCKED')
   AND alh.list_source_type = l_source_type
   AND acr.media_id = l_media_id;

BEGIN
   write_to_act_log( p_msg_data => 'Executing procedure apply_supp',p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');
   OPEN  c_get_list(p_source_type, p_media_id);
   LOOP
      fetch c_get_list into l_list_header_id ;
      exit when c_get_list%notfound;
      if p_supp_type = 'PARTY_ID' then
         if ams_listgeneration_pkg.g_remote_list_gen = 'N' then
            UPDATE ams_list_entries a
               SET a.enabled_flag  = 'N', a.MARKED_AS_SUPPRESSED_FLAG = 'Y'
             WHERE a.list_header_id = p_list_header_id
 	       AND a.enabled_flag = 'Y'
               AND exists (SELECT 'x'
	                     FROM ams_list_entries  b
                            WHERE b.list_header_id = l_list_header_id
                              AND a.party_id = b.party_id
                              AND b.enabled_flag = 'Y');
            write_to_act_log(p_msg_data => sql%rowcount||' entries disabled for party_id based suppression. Suppression list header id is '||l_list_header_id,
	                   p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');
         else
            write_to_act_log(p_msg_data => 'Calling remote api for doing party id based suppression for suppression list'||l_list_header_id,
	                   p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');
            execute immediate
            'begin
               ams_remote_listgen_pkg.apply_suppression'||'@'||ams_listgeneration_pkg.g_database_link||'(:1,:2,:3,:4,:5,:6,:7)'||';'||
            ' end;'
            using p_sql_string,
                  p_list_header_id,
        	  l_list_header_id,
                  'PARTYIDSUPP',
                  out x_msg_count,
                  out x_msg_data,
                  out x_return_status;
         end if;
      elsif p_supp_type = 'DEDUPE' then
         if nvl(ams_listgeneration_pkg.g_remote_list_gen,'N') = 'N' then
            EXECUTE IMMEDIATE p_sql_string using l_list_header_id;
            UPDATE ams_list_entries a SET a.enabled_flag  = 'N', a.MARKED_AS_SUPPRESSED_FLAG = 'Y'
             WHERE a.list_header_id = p_list_header_id
               AND a.enabled_flag = 'Y'
               AND exists (SELECT 'x'
                             FROM ams_list_entries  b
                            WHERE b.list_header_id = l_list_header_id
                              AND b.dedupe_key = a.dedupe_key
                              AND b.enabled_flag = 'Y');
            write_to_act_log(p_msg_data => sql%rowcount||' entries disabled for dedupe rule based suppression. Suppression list header id is '||l_list_header_id,
                             p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');
         else
            write_to_act_log(p_msg_data => 'Calling remote api for doing dedupe rule based suppression for suppression list'||l_list_header_id,
  	                     p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');
            execute immediate
            'begin
               ams_remote_listgen_pkg.apply_suppression'||'@'||ams_listgeneration_pkg.g_database_link||'(:1,:2,:3,:4,:5,:6,:7)'||';'||
            ' end;'
            using p_sql_string,
                  p_list_header_id,
                  l_list_header_id,
                  'DEDUPERULESUPP',
                  out x_msg_count,
                  out x_msg_data,
                  out x_return_status;
         end if;
      end if;

   END LOOP;
   CLOSE c_get_list;
EXCEPTION
   when others then
      write_to_act_log('Error while executing apply_supp procedure','LIST',p_list_header_id,'HIGH');
END apply_supp;

PROCEDURE check_supp(p_list_used_by       varchar2,
	             p_list_used_by_id    number,
	             p_list_header_id     number,
	             x_return_status      out nocopy varchar2,
                     x_msg_count          out nocopy number,
                     x_msg_data           out nocopy varchar2)
		     IS

l_rule_id        NUMBER;
l_media_id       NUMBER;
l_campaign_id    NUMBER;
l_string         VARCHAR2(4000);
i                NUMBER := 0;
l_col_string     VARCHAR2(2000);
l_column         VARCHAR2(60);
l_return_status  VARCHAR2(1);
l_source_type    VARCHAR2(30);
l_chk_pk_map     VARCHAR2(5) := NULL;


--to get the list_rule_id (if any)
--associated with the target group
CURSOR c_get_rule_id is
SELECT am.list_rule_id,
       ac.campaign_id,
       ac.activity_id
  FROM ams_campaign_schedules_b ac,
       ams_list_rule_usages  am,
       ams_list_headers_all al
 WHERE al.list_used_by_id = ac.schedule_id
   AND am.list_header_id(+) = al.list_header_id
   AND ac.schedule_id = p_list_used_by_id
   AND al.list_header_id = p_list_header_id ;

--to get the datasource of the target group
CURSOR c_get_list_data_source is
SELECT list_source_type
  FROM ams_list_headers_all
 WHERE list_header_id = p_list_header_id ;

--to get the columns in ams_list_entries mapped
--to the attributes of the datasource which
--were used to define the de-duplication rule
CURSOR c_rule_field(cur_rule_id number) is
SELECT b.field_column_name
  FROM ams_list_rule_fields a,
       ams_list_src_fields b
 WHERE a.list_rule_id = cur_rule_id
   AND a.LIST_SOURCE_FIELD_ID = b.LIST_SOURCE_FIELD_ID;

--this will check if the Data Source's Uniq. Id is mapped
--to the PARTY_ID column in ams_list_ensties
CURSOR c_check_DS_PK_mapping(l_source_type VARCHAR2) is
SELECT 1
  FROM ams_list_src_fields f,
       ams_list_src_types t
 WHERE t.LIST_SOURCE_TYPE_ID = f.LIST_SOURCE_TYPE_ID
   AND f.FIELD_COLUMN_NAME = 'PARTY_ID'
   AND f.SOURCE_COLUMN_NAME = t.SOURCE_OBJECT_PK_FIELD
   AND t.SOURCE_TYPE_CODE = l_source_type;

BEGIN
   OPEN c_get_rule_id ;
   FETCH c_get_rule_id into l_rule_id, l_campaign_id, l_media_id;
   CLOSE c_get_rule_id ;

   write_to_act_log( p_msg_data => 'Executing procedure check_supp',p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');

   write_to_act_log( p_msg_data => 'list_header_id = '||p_list_header_id||' , list_used_by_id = '||p_list_used_by_id||' , list_used_by = '||p_list_used_by,
	             p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level =>'LOW');

   write_to_act_log( p_msg_data => 'rule_id = '||l_rule_id||' , campaign_id = '||l_campaign_id||' , media_id = '||l_media_id,
	             p_arc_log_used_by => 'LIST',
	             p_log_used_by_id  => p_list_header_id,
	             p_level =>'LOW');

   OPEN c_get_list_data_source ;
   FETCH c_get_list_data_source INTO l_source_type;
   CLOSE c_get_list_data_source ;

   write_to_act_log( p_msg_data => 'Source type =  '||l_source_type ,p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level=>'LOW');

   --Start of Phase I of our Suppression logic ----------------------------------------------------
   --Check if the Data Source's Uniq. Id is mapped to party_id in list entries
   OPEN c_check_DS_PK_mapping(l_source_type) ;
   FETCH c_check_DS_PK_mapping into l_chk_pk_map;
   IF c_check_DS_PK_mapping%notfound THEN
       l_chk_pk_map := null;
   END IF;
   CLOSE c_check_DS_PK_mapping ;

   -- apply PARTY_ID based suppression now
   if (l_chk_pk_map is not null) then
      write_to_act_log( p_msg_data => 'Calling apply_supp procedure to perform party_id based suppression',
                        p_arc_log_used_by => 'LIST',
                        p_log_used_by_id  => p_list_header_id,p_level=>'HIGH');

      --call procedure to update ams_list_entries table
      --matching the entries of the supprssion list(s)
      --using PARTY_ID as the dedupe_key in this case
      apply_supp(p_list_header_id, l_string,l_media_id,l_source_type,'PARTY_ID',x_return_status,x_msg_count,x_msg_data);
      write_to_act_log( p_msg_data => 'Party_id based suppression done.',
                        p_arc_log_used_by => 'LIST',
                        p_log_used_by_id  => p_list_header_id,p_level=>'LOW');

   else
      write_to_act_log( p_msg_data => 'Suppression based on DS Uniq. Id not performed because the column was not mapped to PARTY_ID ',
                        p_arc_log_used_by => 'LIST',
                        p_log_used_by_id  => p_list_header_id,p_level=>'HIGH');
   end if; -- if the DS Uniq. Id is mapped to party_id in list entries

   --dedupe rule based suppression
   if l_rule_id is not null then
      --reset l_string to new value
      l_string := 'update ams_list_entries  set dedupe_key = ';

      open c_rule_field(l_rule_id);
      LOOP
         fetch c_rule_field into l_column;
         exit when c_rule_field%notfound;
         write_to_act_log(p_msg_data => 'Column for DeDupe =  '||l_column,p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level=>'LOW');
         if i = 0 then
            l_string := l_string||l_column;
         else
            l_string := l_string||'||'||'''.'''||'||'||l_column;
         end if;
         i := 1;
      END LOOP;
      close c_rule_field;

      l_string := l_string||'' ;
      l_string := l_string||' where  enabled_flag = '||''''||'Y'||''''||' and list_header_id = :b1 ';
      write_to_act_log(p_msg_data => 'SQL string with DD keys from the selected DD Rule =  '||l_string,p_arc_log_used_by => 'LIST',p_log_used_by_id  => p_list_header_id,p_level=>'LOW');
      if ams_listgeneration_pkg.g_remote_list_gen = 'N' then
         execute immediate l_string using p_list_header_id;
      elsif ams_listgeneration_pkg.g_remote_list_gen = 'Y' then
            execute immediate
            'begin
               ams_remote_listgen_pkg.apply_suppression'||'@'||ams_listgeneration_pkg.g_database_link||'(:1,:2,:3,:4,:5,:6,:7)'||';'||
            ' end;'
            using l_string,
                  p_list_header_id,
                  p_list_header_id,
                  'UPDDEDUPEKEY',
                  out x_msg_count,
                  out x_msg_data,
                  out x_return_status;
         /*execute immediate
         'begin
             ams_remote_listgen_pkg.apply_suppression'||'@'||ams_listgeneration_pkg.g_database_link||'(:1,:2,:3,:4,:5,:6,:7)'||';'||
         ' end;'
         using l_string,
               p_list_header_id,
               null,
               'UPDDEDUPEKEY',
           out x_msg_count,
           out x_msg_data,
           out x_return_status;
	   null;*/
      end if;
      --call procedure to update ams_list_entries table
      --matching the entries of the supprssion list(s)
      --using dedupe_keys from the selected De-Dupe Rule
      apply_supp(p_list_header_id, l_string,l_media_id,l_source_type,'DEDUPE',x_return_status,x_msg_count,x_msg_data);
      --end of Phase II; de-dupe key used from the selected De-dupe rule, if any ---------------------
   end if ; --if l_rule_id is not null
EXCEPTION
   when others then
      write_to_act_log('Error while executing check_supp procedure','LIST',p_list_header_id,'HIGH');
END CHECK_SUPP;

PROCEDURE util_get_source_code(
   p_activity_type IN    VARCHAR2,
   p_activity_id   IN    NUMBER,
   x_return_status OUT NOCOPY   VARCHAR2,
   x_source_code   OUT NOCOPY   VARCHAR2 ,
   x_source_id     OUT NOCOPY   NUMBER
)
IS
BEGIN

   SELECT source_code,source_code_for_id INTO x_source_code,x_source_id
     FROM ams_source_codes
    WHERE arc_source_code_for = UPPER(p_activity_type)
      AND source_code_for_id  = UPPER(p_activity_id)
      and active_flag = 'Y';



   IF SQL%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   ELSE
       x_return_status := FND_API.g_ret_sts_success  ;
   END IF;


EXCEPTION

   WHEN OTHERS THEN
      x_source_code := NULL;
      x_source_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

End;


PROCEDURE get_Source_Code(
   x_return_status     OUT NOCOPY VARCHAR2,
   p_list_used_by      in  varchar2,
   p_list_used_by_id   in  number,
   x_source_code       OUT NOCOPY varchar2
) IS

  Cursor c_camp_source_code(cur_list_used_by_id number) is
   select sc.campaign_id , sc.use_parent_code_flag
   from ams_campaign_schedules_vl sc
   where sc.SCHEDULE_ID    = cur_list_used_by_id  ;

   l_source_code_flag varchar2(1) := 'N' ;
   l_source_id   number;
   l_campaign_id number;
   l_current_code varchar(30);

Begin

  -- Standard Start of API savepoint
  SAVEPOINT Update_ListEntry_Source_Code;

  -- Debug Message
  /* ckapoor
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'Update_Source_Code: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF; */

       IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message('Update_Source_Code:Start');
     END IF;


  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if  p_list_used_by      = 'CSCH' then
     open  c_camp_source_code(p_list_used_by_id );
     fetch c_camp_source_code into
           l_campaign_id , l_source_code_flag ;
     close c_camp_source_code;
  else
     util_get_source_code(
     p_activity_type => p_list_used_by      ,
     p_activity_id   => p_list_used_by_id      ,
     x_return_status => x_return_status,
     x_source_code   => x_source_code,
     x_source_id     => l_source_id);
  end if;

  if l_source_code_flag = 'Y' then
     util_get_source_code(
     p_activity_type => 'CAMP',
     p_activity_id   => l_campaign_id,
     x_return_status => x_return_status,
     x_source_code   => x_source_code,
     x_source_id     => l_source_id);
  else
     util_get_source_code(
     p_activity_type => p_list_used_by      ,
     p_activity_id   => p_list_used_by_id     ,
     x_return_status => x_return_status,
     x_source_code   => x_source_code,
     x_source_id     => l_source_id);
  end if;


  if x_return_status <> FND_API.g_ret_sts_success  THEN
        RAISE FND_API.G_EXC_ERROR;
  end if;
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
     FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
     FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Update_ListEntry_Source_Code', TRUE);
     FND_MSG_PUB.Add;
  END IF;


  /* ckapoor IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('ROW', 'Update_Source_Code: END', TRUE);
     FND_MSG_PUB.Add;
  END IF; */


EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,'get_source_code');
    END IF;
End get_source_code;

PROCEDURE generate_target_group_list_old
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2
  ) is
l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
l_act_list_rec      AMS_ACT_LIST_PVT.act_list_rec_type  ;
l_api_name          constant varchar2(30) := 'gen_target_group_old';
l_api_version               CONSTANT NUMBER   := 1.0;
l_act_list_header_id    number;
G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ACT_LIST_PVT';
l_count     number;
cursor c1 is
select al.list_header_id,
       al.ctrl_random_pct_row_selection,
       al.ctrl_random_nth_row_selection,
       al.generate_control_group_flag, al.generation_type
from  ams_act_lists  acl,ams_list_headers_all al
where acl.list_used_by = p_list_used_by
and   acl.list_used_by_id = p_list_used_by_id
and   acl.list_act_type = 'TARGET'
and   al.list_header_id = acl.list_header_id ;

l_list_header_id    number;
l_ctrl_group_pct    number;
l_ctrl_group_row    number;
l_generate_control_group_flag  varchar2(1);

cursor c2 is
select list_header_id
from  ams_act_lists
where list_used_by = p_list_used_by
and   list_used_by_id = p_list_used_by_id
and   list_act_type <> 'TARGET' ;

l_source_code      varchar2(30);
l_generation_type  varchar2(30);


cursor c_get_act is
select acl.list_act_type,
       acl.list_header_id,
       acl.list_used_by_id, acl.act_list_header_id
from  ams_act_lists  acl
where acl.list_used_by = p_list_used_by
and   acl.list_used_by_id = p_list_used_by_id
and   acl.list_act_type = 'CELL' ;
l_list_act_type_02  varchar2(30);
l_list_header_id_02 number;
l_list_used_by_id_02 number;
l_act_list_header_id_02 number;
l_std_sql varchar2(32767);
l_include_sql varchar2(32767);
l_parameter_list  WF_PARAMETER_LIST_T;
l_new_item_key    VARCHAR2(30);
l_tg_status_code  varchar2(30);
cursor c_tg_status is
select status_code from  ams_list_headers_all
 where list_header_id = l_list_header_id;

/* Bug fix: 3799192. Added by rrajesh on 07/30/04. */
l_tca_field_mapped  varchar2(1);

cursor c_master_ds_tca_mapped(list_head_id IN NUMBER)
IS
select 'Y' from ams_list_src_fields fd, ams_list_headers_all hd, ams_list_src_types ty
where hd.list_header_id = list_head_id
  and hd.LIST_SOURCE_TYPE = ty.source_type_code
  and ty.list_source_type_id = fd.LIST_SOURCE_TYPE_ID
  and fd.tca_column_id is NOT NULL;

/*  Bug fix: 3799192. */

/* added by savio for p1 bug 3817724 */

  cursor c_remote_list(list_head_id in number)
 IS
  select nvl(stypes.remote_flag,'N')
    from ams_list_src_types stypes, ams_list_headers_all list
   where list.list_source_type = stypes.source_type_code
     and list_header_id  =  list_head_id ;

/* added by savio for p1 bug 3817724 */

l_is_manual   varchar2(1) := 'N'; --Added by bmuthukr for bug 3710720


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  g_remote_list           := 'N';

  open c1;
  fetch c1 into  l_list_header_id ,
                 l_ctrl_group_pct ,
                 l_ctrl_group_row ,
                 l_generate_control_group_flag  ,
                 l_generation_type ;
  close c1;
  g_list_header_id := l_list_header_id        ;
  ams_listgeneration_pkg.find_log_level(l_list_header_id);

  write_to_act_log(p_msg_data => 'Executing generate_target_group_list_old procedure for kicking off target group generation',
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => l_list_header_id,
      p_level => 'HIGH');

  --Added by bmuthukr for bug 3710720
  ams_listgeneration_pkg.is_manual(p_list_header_id  => l_list_header_id,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data,
                                   x_is_manual       => l_is_manual);
  if nvl(x_return_status,'S') in ('E','U') then -- resulted in error.
     write_to_act_log('Error in executing is_manual procedure', 'LIST', g_list_header_id,'HIGH');
     write_to_act_log('Error '||x_msg_data , 'LIST', g_list_header_id,'HIGH');
     ams_listgeneration_pkg.logger;
     return;
  end if;

  if nvl(l_is_manual,'N') = 'Y' then
     write_to_act_log('Either list is a manual list, or incl are based on EMP list. Cannot generate','LIST',l_list_header_id,'HIGH');
     ams_listgeneration_pkg.logger;
     return;
  end if;
  --Ends changes.

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  get_Source_Code(
   x_return_status     => x_return_status,
   p_list_used_by      => p_list_used_by      ,
   p_list_used_by_id   => p_list_used_by_id   ,
   x_source_code       => l_source_code  );

  if x_return_status <> FND_API.g_ret_sts_success  THEN
        RAISE FND_API.G_EXC_ERROR;
  end if;


/* ------------------------- added by savio bug 381 7724 ---------------*/

  open c_remote_list(l_list_header_id);
  fetch c_remote_list into g_remote_list;
  close c_remote_list;

write_to_act_log(p_msg_data => 'Remote list? ' ||g_remote_list,
                 p_arc_log_used_by => 'LIST',
                 p_log_used_by_id  => l_list_header_id,
    p_level => 'LOW');




/* ------------------------- end of added by savio bug 381 7724 ---------------*/

  /* Bug fix: 3799192. Added by rrajesh on 07/30/04. If there is no maapping to TCA, update the
  status to FAILED and return */
  write_to_act_log(p_msg_data => 'Checking if datasource fields are mapped to TCA fields. ',
                                                p_arc_log_used_by => 'TARGET',
                                                p_log_used_by_id  => l_list_header_id,
               p_level => 'LOW');
  open  c_master_ds_tca_mapped(l_list_header_id);
  fetch c_master_ds_tca_mapped into l_tca_field_mapped;
  close c_master_ds_tca_mapped;

/* need to check for mandatory tca mapping only for remote target groups */

if g_remote_list = 'Y' then
  if l_tca_field_mapped is NULL THEN
     write_to_act_log(p_msg_data => 'Data Source fields are not mapped with tca fields -- Aborting target group generation process ',
                      p_arc_log_used_by => 'TARGET',
                      p_log_used_by_id  => l_list_header_id,
         p_level => 'HIGH');
     UPDATE ams_list_headers_all
        SET    last_generation_success_flag = 'N',
               status_code                  = 'FAILED',
               user_status_id               = 311,
               status_date                  = sysdate,
               last_update_date             = sysdate,
               main_gen_end_time            = sysdate
        WHERE  list_header_id               = l_list_header_id;
     -- calling logging program
     ams_listgeneration_pkg.logger;
     --
     RETURN;
   end if;
end if ;

  /* End Bug fix: 3799192 */
write_to_act_log(p_msg_data => 'Calling ams_listgeneration_pkg.generate_target_group procedure to generate target group',
                 p_arc_log_used_by => 'TARGET',
                 p_log_used_by_id  => l_list_header_id,
                 p_level => 'LOW');


AMS_LISTGENERATION_PKG.GENERATE_TARGET_GROUP
( p_api_version            => p_api_version,
  p_init_msg_list          => FND_API.G_TRUE,
  p_commit                 => FND_API.G_FALSE,
  p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id         => l_list_header_id,
  x_return_status   => x_return_status,
  x_msg_count       => x_msg_count,
  x_msg_data        => x_msg_data );

  If x_return_status in (FND_API.g_ret_sts_error,FND_API.g_ret_sts_unexp_error) then
     write_to_act_log(p_msg_data => 'Error in generating target group' ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => g_list_header_id,
         p_level => 'HIGH');
  end if;

  IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

  write_to_act_log(p_msg_data => 'Procedure AMS_LISTGENERATION_PKG.GENERATE_TARGET_GROUP executed successfully.' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => g_list_header_id,
      p_level => 'HIGH');


-- Need to move the call to supp and updates for marking party_id duplicates to amsvlgnb.pls starts
/*
  write_to_act_log(p_msg_data => 'Marking duplicates based on dedupe key and party id' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => g_list_header_id,
      p_level => 'HIGH');
     UPDATE ams_list_entries a
        SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
     WHERE a.list_header_id = l_list_header_id
       and a.enabled_flag = 'Y'
       AND a.rowid >  (SELECT min(b.rowid)
                   from ams_list_entries  b
                   where b.list_header_id = l_list_header_id
                     and b.dedupe_key = a.dedupe_key
                     and b.enabled_flag = 'Y'
                   );*/

/*
     UPDATE ams_list_entries a
        SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
     WHERE a.list_header_id = l_list_header_id
       and a.enabled_flag = 'Y'
       AND a.rowid >  (SELECT min(b.rowid)
                   from ams_list_entries  b
                   where b.list_header_id = l_list_header_id
                     and b.party_id = a.party_id
                     and b.enabled_flag = 'Y'
                   );
*/

/*     UPDATE ams_list_entries a
        SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
     WHERE a.list_header_id =l_list_header_id
       and a.enabled_flag = 'Y'
       AND a.rowid >  (SELECT min(b.rowid)
                   from ams_list_entries  b
                   where b.list_header_id = l_list_header_id
                     and b.party_id = a.party_id
                     and b.enabled_flag = 'Y'
                     and b.rank = a.rank
                   );

     UPDATE ams_list_entries a
        SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
     WHERE a.list_header_id = l_list_header_id
       and a.enabled_flag = 'Y'
       -- AND a.rowid >  (SELECT min(b.rowid)
       AND a.rank >  (SELECT min(b.rank)
                   from ams_list_entries  b
                   where b.list_header_id = l_list_header_id
                     and b.party_id = a.party_id
                     and b.enabled_flag = 'Y'
                   );*/
 /* if p_list_used_by = 'CSCH' then
     write_to_act_log(p_msg_data => 'Calling check_supp procedure' ,
                   p_arc_log_used_by => 'LIST',
                   p_log_used_by_id  => g_list_header_id,
      p_level => 'LOW');
     check_supp( p_list_used_by  => p_list_used_by,
                p_list_used_by_id => p_list_used_by_id   ,
                p_list_header_id => l_list_header_id  );

  end if;

     UPDATE ams_list_entries a
        SET a.enabled_flag  = 'N',
            a.marked_as_duplicate_flag = 'Y'
     WHERE a.list_header_id = l_list_header_id
       and a.enabled_flag = 'Y'
       AND a.rowid >  (SELECT min(b.rowid)
                   from ams_list_entries  b
                   where b.list_header_id = l_list_header_id
                     and b.dedupe_key = a.dedupe_key
                     and b.enabled_flag = 'Y'
                   );*/
-- Need to move the call to supp and updates for marking party_id duplicates to amsvlgnb.pls ends

--Call will be made from amsvlgnb.pls directly..Not reqd from here any more.


  /*select count(1)
  into  l_count
  from ams_list_entries
  where list_header_id = l_list_header_id
  and enabled_flag = 'Y';

  if l_generate_control_group_flag   = 'Y' then
     write_to_act_log(p_msg_data => 'Calling Control_Group_Generation. No of active entries = '||l_count ,
                      p_arc_log_used_by => 'LIST',
                      p_log_used_by_id  => g_list_header_id,
         p_level => 'HIGH');
     Control_Group_Generation(
                  l_list_header_id ,
                  l_ctrl_group_pct ,
                  l_ctrl_group_row ,
                  l_count,
                  x_return_status   );
     write_to_act_log(p_msg_data => 'Control group generated.  ' ,
                                                p_arc_log_used_by => 'LIST',
                                                p_log_used_by_id  => g_list_header_id,
                    p_level => 'LOW');
  end if;*/

     UPDATE ams_list_entries set
            source_code = l_source_code    ,
            arc_list_used_by_source = p_list_used_by ,
            source_code_for_id = p_list_used_by_id
     where list_header_id = l_list_header_id ;

   AMS_LISTGENERATION_PKG.Update_List_Dets(l_list_header_id ,x_return_status ) ;
-- --------------------------------------------------------
-- Business Event for Traffic Cop
-----------------------------------------------------------
  open c_tg_status;
  fetch c_tg_status into l_tg_status_code;
  close c_tg_status;
  if l_tg_status_code = 'AVAILABLE' then
   write_to_act_log(p_msg_data => 'Business event for traffic cop starts' ,
                    p_arc_log_used_by => 'LIST',
                    p_log_used_by_id  => g_list_header_id,
       p_level =>'LOW');
    AMS_Utility_PVT.debug_message('Raise Business event for Target Group -- Start');
         -- Raise a business event
         l_new_item_key    := l_list_header_id || TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
         l_parameter_list := WF_PARAMETER_LIST_T();
         AMS_Utility_PVT.debug_message('Raise Business event-- after WF_PARAMETER_LIST_T call');
         wf_event.AddParameterToList(p_name           => 'LIST_HEADER_ID',
                                    p_value           => l_list_header_id,
                                    p_parameterlist   => l_parameter_list);
         AMS_Utility_PVT.debug_message('Raise Business event-- after AddParameterToList call');
         wf_event.AddParameterToList(p_name           => 'PURGE_FLAG',
                                    p_value           => null,
                                    p_parameterlist   => l_parameter_list);
         AMS_Utility_PVT.debug_message('Raise Business event-- after AddParameterToList call');
         AMS_Utility_PVT.debug_message('Raise Business event-- Start');
         WF_EVENT.Raise
            ( p_event_name   =>  'oracle.apps.ams.list.PostTargetGroupEvent',
              p_event_key    =>  l_new_item_key,
              p_parameters   =>  l_parameter_list);
    AMS_Utility_PVT.debug_message('Raise Business event for Target Group -- End');
      /*write_to_act_log(p_msg_data => 'Business event for traffic cop ends' ,
                    p_arc_log_used_by => 'LIST',
                    p_log_used_by_id  => g_list_header_id,
       p_level =>'LOW');*/
   end if;
-- --------------------------------------------------------
  IF (AMS_DEBUG_HIGH_ON) THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', 'AMS_LISTGENERATION_PKG.cerate_list: Start', TRUE);
     FND_MSG_PUB.Add;
  END IF;
write_to_act_log(p_msg_data => 'Target Group available ' ,
                                                p_arc_log_used_by => 'LIST',
                                                p_log_used_by_id  => g_list_header_id,
               p_level=>'HIGH');
ams_listgeneration_pkg.logger;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
  FND_MESSAGE.Set_Name('AMS', 'AMS_API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ACT_LIST.list_creation: ');
  FND_MSG_PUB.Add;
  END IF;

  IF (AMS_DEBUG_HIGH_ON) THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ACT_LIST.list_act_creation: END');
  FND_MSG_PUB.Add;
  END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END generate_target_group_list_old;


PROCEDURE generate_target_group_list
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2
  ) is
cursor c1 is
select al.list_header_id
from  ams_act_lists  acl,ams_list_headers_all al
where acl.list_used_by = p_list_used_by
and   acl.list_used_by_id = p_list_used_by_id
and   acl.list_act_type = 'TARGET'
and   al.list_header_id = acl.list_header_id ;

l_cell_id number;
cursor check_cell is
select acl.list_header_id
from  ams_act_lists  acl
where acl.list_used_by = p_list_used_by
and   acl.list_used_by_id = p_list_used_by_id
and   acl.list_act_type = 'CELL' ;

l_list_header_id    number;
l_api_name          constant varchar2(30) := 'gen_target_group';
l_api_version               CONSTANT NUMBER   := 1.0;

     CURSOR c_status IS
       SELECT status_code
       FROM ams_list_headers_all
       WHERE list_header_id = l_list_header_id ;

     l_status_code varchar2(30);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list IF p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;


  open c1;
  fetch c1 into  l_list_header_id ;
  close c1;

     OPEN c_status ;
     FETCH c_status INTO l_status_code;
     CLOSE c_status ;
     IF l_status_code = 'GENERATING' THEN
          FND_MESSAGE.Set_Name('AMS','AMS_GENERATING');
          FND_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;
     END IF;


  open check_cell;
  loop
  fetch check_cell into  l_cell_id ;
  exit when check_cell%notfound;
    validate_segment
    ( p_cell_id                => l_cell_id,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data
    );
  end loop;
  close check_cell;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  if l_list_header_id is not null then
       AMS_LIST_WF.StartProcess
       ( p_list_header_id        =>      l_list_header_id
         ,workflowprocess        => 'AMSLISTG')  ;
  end if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Perform the database operation

  -- Standard check of p_commit.

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Success Message
  -- MMSG
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
  FND_MESSAGE.Set_Name('AMS', 'AMS_API_SUCCESS');
  FND_MESSAGE.Set_Token('ROW', 'AMS_ACT_LIST.list_creation: ');
  FND_MSG_PUB.Add;
  END IF;

/*
  IF (AMS_DEBUG_HIGH_ON) THEN
  FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
  FND_MESSAGE.Set_Token('TEXT', 'AMS_ACT_LIST.list_act_creation: END');
  FND_MSG_PUB.Add;
  END IF;
  */
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     --FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     --FND_MSG_PUB.Add;
     -- Check if reset of the status is required
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     --FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     --FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

  WHEN OTHERS THEN
     --FND_MESSAGE.set_name('AMS', 'AMS_API_DEBUG_MESSAGE');
     --FND_MESSAGE.Set_Token('TEXT', sqlerrm||' '||sqlcode);
     --FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);


END generate_target_group_list;
PROCEDURE check_char(p_input_string          in  varchar2
                    ,p_comma_valid  in varchar2
                    ,p_valid_string OUT NOCOPY varchar2) IS
BEGIN
   if p_input_string = ' ' then
      p_valid_string :='Y';
   elsif p_input_string = fnd_global.newline then
      p_valid_string :='Y';
   elsif p_input_string = fnd_global.tab then
      p_valid_string :='Y';
   elsif p_input_string = '
' then
      p_valid_string :='Y';
   elsif p_input_string = ',' then
      if p_comma_valid = 'Y' then
         p_valid_string :='Y';
      else
         p_valid_string :='N';
      end if;
   else
      p_valid_string :='N';
   end if;
END;


PROCEDURE validate_sql_string
             (p_sql_string     in AMS_LISTGENERATION_PKG.sql_string
              ,p_search_string in varchar2
              ,p_comma_valid   in varchar2
              ,x_found         OUT NOCOPY varchar2
              ,x_position      OUT NOCOPY number
              ,x_counter       OUT NOCOPY number
              )  IS
l_sql_string_1           varchar2(2000) := ' ';
l_sql_string_2           varchar2(2000) ;
l_concat_string          varchar2(4000) ;
l_valid_string           varchar2(1) := 'N';
l_position               varchar2(200);
BEGIN

  /* Searching of the string is done by concatenating the two strings of
     2000 each   gjoby more expln needed
  */
  x_found    := 'N';
  --l_position := 'AMS_ListGeneration_PKG.Validate_sql_string start';
  l_sql_string_1  := lpad(l_sql_string_1,2000,' ');

  for i in 1 .. p_sql_string.last
  loop

     l_sql_string_2 := p_sql_string(i);
     if p_search_string = 'FROM' then
        l_concat_string := upper(l_sql_string_1) || upper(l_sql_string_2);
     else
        l_concat_string := l_sql_string_1 || l_sql_string_2;
     end if;

     x_position := instrb(l_concat_string ,p_search_string);
     if x_position > 0 then
        loop
             l_valid_string := 'N' ;
             if x_position = 0 then
                exit;
             else
               check_char
                   (p_input_string=>substrb(l_concat_string, x_position -1, 1)
                    ,p_comma_valid =>p_comma_valid
                    ,p_valid_string=> l_valid_string);
               if l_valid_string = 'Y' then
                  check_char
                      (p_input_string=>substrb(l_concat_string,
                                 x_position + length(p_search_string)
                                  , 1)
                       ,p_comma_valid =>p_comma_valid
                       ,p_valid_string=> l_valid_string);
               end if;
             end if;
             if l_valid_string = 'Y' then
                if x_position > 2000 then
                   x_found    := 'Y';
                   x_counter  := i;
                   x_position := x_position - 2000;
                   exit;
                end if;
                if x_position < 2001 then
                   x_found    := 'Y';
                   x_counter  := i -1 ;
                   exit;
                end if;
             end if;
             x_position := instrb(l_concat_string ,
                                  x_position+1,
                                  p_search_string);
        end loop;
        exit;
     end if;
  l_sql_string_1 := l_sql_string_2;
  end loop;
  --l_position := 'AMS_ListGeneration_PKG.Validate_sql_string end';
exception
    when others then
      write_to_act_log('AMS_ListGeneration_PKG.Error' || sqlerrm,null,null );
END;

PROCEDURE get_condition(p_sql_string in AMS_LISTGENERATION_PKG.sql_string ,
                        p_search_string     in varchar2,
                        p_comma_valid   in varchar2,
                        x_position OUT NOCOPY number,
                        x_counter OUT NOCOPY number,
                        x_found    OUT NOCOPY varchar2,
                        x_sql_string OUT NOCOPY AMS_LISTGENERATION_PKG.sql_string) is
l_where_position   number;
l_where_counter   number;
l_counter   number := 0;
l_sql_string      AMS_LISTGENERATION_PKG.sql_string;
begin
  validate_sql_string(p_sql_string => p_sql_string ,
                      p_search_string => p_search_string,
                      p_comma_valid   => 'N',
                      x_found    => x_found,
                      x_position =>x_position,
                      x_counter => x_counter) ;

  if x_counter > 0 then
    for i in x_counter .. p_sql_string.last
    loop
      l_counter := l_counter +1;
      x_sql_string(l_counter) := p_sql_string(i);
      if x_counter = i then
        x_sql_string(l_counter) := lpad(substrb(x_sql_string(l_counter),
                                        x_position),2000);
      end if;
    end loop;
  end if;
end;

PROCEDURE form_sql_statement(p_select_statement in varchar2,
                             p_select_add_statement in varchar2,
                             p_master_type        in varchar2,
                             p_child_types     in AMS_LISTGENERATION_PKG.child_type,
                             p_from_string in AMS_LISTGENERATION_PKG.sql_string ,
                      p_act_list_header_id in number,
                             p_action_used_by_id  in number,
                             x_final_string OUT NOCOPY varchar2
                             ) is
-- child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
l_data_source_types varchar2(2000);
l_field_col_tbl JTF_VARCHAR2_TABLE_100;
l_source_col_tbl JTF_VARCHAR2_TABLE_100;
l_view_tbl JTF_VARCHAR2_TABLE_100;
cursor c_master_source_type is
select source_object_name , source_object_name || '.' || source_object_pk_field
from ams_list_src_types
where source_type_code = p_master_type;
cursor c_child_source_type (l_child_src_type varchar2 )is
select a.source_object_name ,
       a.source_object_name || '.' || b.sub_source_type_pk_column
       ,b.master_source_type_pk_column
from ams_list_src_types  a, ams_list_src_type_assocs b
where a.source_type_code = l_child_src_type
and   b.sub_source_type_id = a.list_source_type_id;
l_count                   number;
l_master_object_name      varchar2(4000);
l_child_object_name       varchar2(4000);
l_master_primary_key      varchar2(1000);
l_child_primary_key       varchar2(32767);
l_from_clause             varchar2(32767);
l_where_clause            varchar2(32767);
l_select_clause           varchar2(32767);
l_insert_clause           varchar2(32767);
l_final_sql               varchar2(32767);
l_insert_sql              varchar2(32767);
l_no_of_chunks            number;
l_master_fkey             Varchar2(1000);
l_dummy_primary_key      varchar2(1000);


l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996
/* batoleti. Bug# 6688996. Added the below cursor */
    CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;


begin
 WRITE_TO_ACT_LOG('form_sql_statement->p_master_type' || p_master_type,'LIST',g_list_header_id);
open  c_master_source_type;
fetch c_master_source_type into l_master_object_name , l_master_primary_key;
close c_master_source_type;
 WRITE_TO_ACT_LOG('form_sql_statement->after master' || l_master_object_name,'LIST',g_list_header_id);

l_from_clause :=  ' FROM ' || l_master_object_name;
l_data_source_types := ' ('|| ''''|| p_master_type ||'''';
l_where_clause := 'where 1 = 1 ';
     WRITE_TO_ACT_LOG('form_sql_statement->before child','LIST',g_list_header_id);

l_count  := p_child_types.count();
if l_count > 0  then
   for i in 1..p_child_types.last
   loop
      l_data_source_types := l_data_source_types || ','|| ''''
                             || p_child_types(i)||'''' ;
      open  c_child_source_type(p_child_types(i));
      fetch c_child_source_type into l_child_object_name , l_child_primary_key
                                     ,l_master_fkey;
      l_dummy_primary_key := '';
      if l_master_fkey is not null then
         l_dummy_primary_key     := l_master_object_name || '.'|| l_master_fkey;
      else
         l_dummy_primary_key      := l_master_primary_key;
      end if;
      l_from_clause := l_from_clause || ','|| l_child_object_name ;
      l_where_clause := l_where_clause || 'and '
                              ||l_dummy_primary_key || ' = '
                        || l_child_primary_key || '(+)';
      close c_child_source_type;
   end loop;
end if;
  WRITE_TO_ACT_LOG('form_sql_statement->after child','LIST',g_list_header_id);
l_data_source_types := l_data_source_types || ') ' ;

 EXECUTE IMMEDIATE
     'BEGIN
      SELECT b.field_column_name ,
               c.source_object_name,
               b.source_column_name
        BULK COLLECT INTO :1 ,:2  ,:3
        FROM ams_list_src_fields b, ams_list_src_types c
        WHERE b.list_source_type_id = c.list_source_type_id
          and b.DE_LIST_SOURCE_TYPE_CODE IN  '|| l_data_source_types ||
          ' AND b.ROWID >= (SELECT MAX(a.ROWID)
                            FROM ams_list_src_fields a
                           WHERE a.field_column_name= b.field_column_name
                    AND  a.DE_LIST_SOURCE_TYPE_CODE IN '
                                 || l_data_source_types || ') ;
      END; '
  USING OUT l_field_col_tbl ,OUT l_view_tbl , OUT l_source_col_tbl ;
  --WRITE_TO_ACT_LOG('imp: p_select_statement' || p_select_statement);
  --WRITE_TO_ACT_LOG('imp: p_select_add_statement' || p_select_add_statement);
  --WRITE_TO_ACT_LOG('imp: select clause ' || l_select_clause);
for i in 1 .. l_field_col_tbl.last
loop
  l_insert_clause  := l_insert_clause || ' ,' || l_field_col_tbl(i) ;
  l_select_clause  := l_select_clause || ' ,' ||
                      l_view_tbl(i) || '.'||l_source_col_tbl(i) ;
  --WRITE_TO_ACT_LOG('imp: select clause'||i||':->' || l_select_clause);
end loop;
--- Change p_select_action_id to 0

   -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(g_list_header_id);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996



  WRITE_TO_ACT_LOG('form_sql_statement:before insert_sql ','LIST',g_list_header_id);
  l_insert_sql := 'insert into ams_list_entries        '||
                   '( LIST_SELECT_ACTION_FROM_NAME,    '||
                   '  LIST_ENTRY_SOURCE_SYSTEM_ID ,    '||
                   '  LIST_ENTRY_SOURCE_SYSTEM_TYPE,   '||
                   ' list_select_action_id ,           '||
                   ' list_header_id,last_update_date,  '||
                   ' last_updated_by,creation_date,created_by,'||
                   'list_entry_id, '||
                   'object_version_number, ' ||
                   'source_code                     , ' ||
                   'source_code_for_id              , ' ||
                   'arc_list_used_by_source         , ' ||
                   'arc_list_select_action_from     , ' ||
                   'pin_code                        , ' ||
                   'view_application_id             , ' ||
                   'manually_entered_flag           , ' ||
                   'marked_as_random_flag           , ' ||
                   'marked_as_duplicate_flag        , ' ||
                   'part_of_control_group_flag      , ' ||
                   'exclude_in_triggered_list_flag  , ' ||
                   'enabled_flag ' ||
                   l_insert_clause || ' ) ' ||

                   'select ' ||
                   l_master_primary_key ||','||
                   l_master_primary_key ||','||
                   ''''||p_master_type||''''||','||
                   0 || ',' ||
                   to_char(g_list_header_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(FND_GLOBAL.login_id )|| ',' ||''''||
                   to_char(sysdate )|| ''''||','||
                   to_char(nvl(l_created_by, FND_GLOBAL.login_id) )|| ',' ||
                   'ams_list_entries_s.nextval'  || ','||
                   1 || ','||
                   ''''||'NONE'                ||''''     || ','||
                   0                           || ','     ||
                   ''''||'NONE'                ||''''     || ','||
                   ''''||'NONE'                ||''''     || ','||
                   'ams_list_entries_s.currval'|| ','||
                   530              || ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'N'  ||''''|| ','||
                   ''''||'Y'  ||''''||
                   l_select_clause ;

  --WRITE_TO_ACT_LOG('form_sql_statement:before final sql ');
     l_final_sql := l_insert_sql || '  ' ||
                  l_from_clause ||  '  '||
                  l_where_clause   || ' and  ' ||
                   l_master_primary_key|| ' in  ( ' ;
     x_final_string := l_final_sql;
  WRITE_TO_ACT_LOG('form_sql_statement:after final sql ','LIST',g_list_header_id);
  WRITE_TO_ACT_LOG('*************************************','LIST',g_list_header_id);
     l_no_of_chunks  := ceil(length(l_final_sql)/2000 );
     for i in 1 ..l_no_of_chunks
     loop
        WRITE_TO_ACT_LOG(substrb(l_final_sql,(2000*i) - 1999,2000),'LIST',g_list_header_id);
     end loop;
  WRITE_TO_ACT_LOG('*************************************','LIST',g_list_header_id);
        WRITE_TO_ACT_LOG('end','LIST',g_list_header_id);
exception
   when others then
     write_to_act_log(sqlerrm,'LIST',g_list_header_id );
end form_sql_statement;

PROCEDURE process_insert_sql
           (p_select_statement in varchar2,
            p_select_add_statement in varchar2,
            p_master_type        in varchar2,
            p_child_types     in AMS_LISTGENERATION_PKG.child_type,
            p_from_string in AMS_LISTGENERATION_PKG.sql_string ,
            p_act_list_header_id in number,
            p_action_used_by_id  in number,
            x_std_sql OUT NOCOPY varchar2 ,
            x_include_sql OUT NOCOPY varchar2
                             ) is
l_final_sql   varchar2(32767);
l_insert_sql varchar2(32767);
l_insert_sql1 varchar2(32767);
l_table_name  varchar2(80) := ' ams_list_tmp_entries ';
BEGIN
  write_to_act_log('process_insert_sql:-->begin<--',null,null);
  l_insert_sql := p_select_statement ;
  write_to_act_log(l_insert_sql,null,null);
  for i in 1 .. p_from_string.last
  loop
    write_to_act_log(p_from_string(i),null,null);
    l_insert_sql  := l_insert_sql || p_from_string(i);
  end loop;
  x_std_sql := l_insert_sql;

     --WRITE_TO_ACT_LOG('form_sql_statement->before');
          form_sql_statement(p_select_statement ,
                             p_select_add_statement ,
                             p_master_type        ,
                             p_child_types     ,
                             p_from_string ,
                      p_act_list_header_id ,
                             p_action_used_by_id  ,
                             l_final_sql
                             ) ;
     --WRITE_TO_ACT_LOG('form_sql_statement->after');
  x_include_sql := l_final_sql;
  --write_to_act_log('process_insert_sql:-->end<--');
exception
   when others then
   write_to_act_log(sqlerrm ,null,null);
END process_insert_sql;

PROCEDURE process_all_sql  (
                  p_action_used_by_id in  number,
                  p_act_list_header_id in number,
                  p_incl_object_id in number,
                  p_sql_string    in AMS_LISTGENERATION_PKG.sql_string,
                  p_primary_key   in  varchar2,
                  p_source_object_name in  varchar2,
                  x_msg_count      OUT NOCOPY number,
                  x_msg_data       OUT NOCOPY varchar2,
                  x_return_status  IN OUT NOCOPY VARCHAR2,
                  x_std_sql OUT NOCOPY varchar2 ,
                  x_include_sql OUT NOCOPY varchar2
                            ) is
l_sql_string         AMS_LISTGENERATION_PKG.sql_string;
--l_sql_string         sql_string;
l_where_string       AMS_LISTGENERATION_PKG.sql_string;
l_from_string       AMS_LISTGENERATION_PKG.sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1) := 'N';
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        AMS_LISTGENERATION_PKG.child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_sql_string_v2           varchar2(4000);
l_no_of_chunks  number;
BEGIN
  /* Validate Sql String will take all the sql statement fragement and
     check if the search string is present. If it is present it will
     return the position of fragement and the counter
  */
  l_sql_string := p_sql_string;
  --write_to_act_log('Process_all_sql: start ');
  --write_to_act_log('Process_all_sql return status: ' || x_return_status);
  l_found  := 'N';
  validate_sql_string(p_sql_string => l_sql_string ,
                      p_search_string => 'FROM',
                      p_comma_valid   => 'N',
                      x_found    => l_found,
                      x_position =>l_from_position,
                      x_counter => l_from_counter) ;

  if l_found = 'N' then
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_FROM_NOT_FOUND');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
     write_to_act_log('Process_all_sql: FROM Position ->'|| l_from_position ||
                                   '<--FROM Counter ->' || l_from_counter ||
                                   '<--FROM Found ->' || l_found,null,null);
  l_found  := 'N';
 AMS_LISTGENERATION_PKG.get_master_types (p_sql_string => l_sql_string,
                    p_start_length => 1,
                    p_start_counter => 1,
                    p_end_length => l_from_position,
                    p_end_counter => l_from_counter,
                    x_master_type_id=> l_master_type_id,
                    x_master_type=> l_master_type,
                    x_found=> l_found,
                    x_source_object_name => l_source_object_name,
                    x_source_object_pk_field  => l_source_object_pk_field);
  if l_found = 'N' then
     FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_MASTER_TYPE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
  --write_to_act_log('Process_all_sql: Master Type->'|| l_master_type ||'<--'  );


     l_found  := 'N';
     AMS_LISTGENERATION_PKG.get_child_types (p_sql_string => l_sql_string,
                      p_start_length => 1,
                      p_start_counter => 1,
                      p_end_length => l_from_position,
                      p_end_counter => l_from_counter,
                      p_master_type_id=> l_master_type_id,
                      x_child_types=> l_child_types,
                      x_found=> l_found);

  --for i in 1 .. l_child_types.last
  --loop
    --write_to_act_log('Process_all_sql: child Type->'|| l_child_types(i) ||'<--'  );
  -- end loop;
  l_found  := 'N';
  get_condition(p_sql_string => l_sql_string ,
                p_search_string => 'FROM',
                p_comma_valid   => 'N',
                x_position =>l_from_position,
                x_counter => l_from_counter,
                x_found    => l_found,
                x_sql_string => l_from_string) ;

     write_to_act_log('l_from_string'||l_from_string.last,null,null);
     for i in 1 .. l_from_string.last
     loop
        l_no_of_chunks  := ceil(length(l_from_string(i))/2000 );
     write_to_act_log('l_sql_string chunks'||l_no_of_chunks,null,null);
        for j in 1 ..l_no_of_chunks
        loop
           WRITE_TO_ACT_LOG(i || 'j'||j,'LIST',g_list_header_id);
           WRITE_TO_ACT_LOG(substrb(l_from_string(i),(2000*j) - 1999,2000),'LIST',g_list_header_id);
        end loop;
     end loop;


  /* FOR SQL STATEMENTS  WHICH ARE NOT FROM THE DERIVING MASTER SOURCE TABLE  */
  if p_primary_key is not null then
     l_source_object_pk_field := p_primary_key;
     l_source_object_name     := p_source_object_name ;
  end if;
  l_select_condition := 'SELECT ' ||l_source_object_name||'.'
                        ||l_source_object_pk_field;
                        --||'||'||''''
                        --||l_master_type||'''';
  l_select_add_condition := ','||l_source_object_name||'.'
                        ||l_source_object_pk_field||','||''''
                        ||l_master_type||'''' ;

   write_to_act_log('Process_all_sql: ***********insert sql ***********',null,null);
   process_insert_sql(p_select_statement       => l_select_condition,
                      p_select_add_statement   => l_select_add_condition,
                      p_master_type            => l_master_type,
                      p_child_types            => l_child_types,
                      p_from_string            => l_from_string  ,
                      p_act_list_header_id => p_act_list_header_id ,
                      p_action_used_by_id      => p_action_used_by_id ,
                      x_std_sql                => x_std_sql,
                      x_include_sql            => x_include_sql
                      );
   write_to_act_log('Process_all_sql: ***********end insert sql->' ,null,null);
   --write_to_act_log('Proc_all__sql -> end' ||x_return_status);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     write_to_act_log('Error: AMS_ListGeneration_PKG.process_all_sql: ',null,null);
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     write_to_act_log('Error: AMS_ListGeneration_PKG.process_all_sql: ',null,null);
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

  WHEN OTHERS THEN
     write_to_act_log('Error: AMS_ListGeneration_PKG.process_all_sql:' ,null,null);
     x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


END process_all_sql;

PROCEDURE process_cell
             (p_action_used_by_id in  number,
              p_act_list_header_id in number,
              p_incl_object_id in number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
               ) is

------------------------------------------------------------------------------
-- Given the sql id from ams_list_select_actions it will retrieve the
-- sql_srtings from ams_discoverer_sql for a particular worksheet_name and
-- workbook_name.
------------------------------------------------------------------------------
l_sql_string         AMS_LISTGENERATION_PKG.sql_string;
l_where_string       AMS_LISTGENERATION_PKG.sql_string;
l_from_string       AMS_LISTGENERATION_PKG.sql_string;
l_counter            NUMBER := 1;
l_from_position      number;
l_from_counter       number;
l_end_position      number;
l_end_counter       number;
l_order_position      number;
l_order_counter       number;
l_group_position      number;
l_group_counter       number;
l_found              varchar2(1);
l_master_type        varchar2(80);
l_master_type_id     number;
l_source_object_name  varchar2(80);
l_source_object_pk_field  varchar2(80);
l_child_types        AMS_LISTGENERATION_PKG.child_type;
l_select_condition    varchar2(2000);
l_select_add_condition    varchar2(2000);
l_msg_data       VARCHAR2(2000);
l_msg_count      number;
l_sql_2          DBMS_SQL.VARCHAR2S;
l_sql_string_final    varchar2(4000);
j number     := 1;
l_no_of_chunks number;
l_final_big_sql VARCHAR2(32767);
l_const_sql VARCHAR2(32767);
BEGIN

    --write_to_act_log('AMS_ListGeneration_PKG.Get Comp sql:');
  ams_cell_pvt.get_comp_sql(
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.g_false,
      p_validation_level  => FND_API.g_valid_level_full,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count ,
      x_msg_data           =>x_msg_data,
      p_cell_id           => p_incl_object_id ,
      p_party_id_only     => FND_API.g_false,
      x_sql_tbl           => l_sql_2
   );
    --write_to_act_log('AMS_ListGeneration_PKG.After Comp sql:');

  l_sql_string_final := '';
  for i in 1 .. l_sql_2.last
  loop
    --write_to_act_log(l_sql_2(i));
      l_sql_string_final := l_sql_string_final || l_sql_2(i);
     if length(l_sql_string_final) > 2000 then
        l_sql_string(j) := substrb(l_sql_string_final,1,2000);
        l_sql_string_final := substrb(l_sql_string_final,2001 ,2000);
        j := j+1;
     end if;
  end loop;
  l_sql_string(j) := substrb(l_sql_string_final,1,2000);
  if length(l_sql_string_final) > 2000 then
    j := j+1;
    l_sql_string(j) := substrb(l_sql_string_final,2001 ,2000);
  end if;

  --write_to_act_log('AMS_ListGeneration_PKG.Process all sql:');
     --write_to_act_log('l_sql_string'||l_sql_string.last);
     for i in 1 .. l_sql_string.last
     loop
        l_no_of_chunks  := ceil(length(l_sql_string(i))/2000 );
     --write_to_act_log('l_sql_string chunks'||l_no_of_chunks);
        for j in 1 ..l_no_of_chunks
        loop
           --WRITE_TO_ACT_LOG(i || 'j'||j);
           --WRITE_TO_ACT_LOG(substrb(l_sql_string(i),(2000*j) - 1999,2000),'LIST',g_list_header_id);
             null;
        end loop;
     end loop;

  process_all_sql(
                  p_action_used_by_id => p_action_used_by_id,
                  p_act_list_header_id => p_act_list_header_id ,
                  p_incl_object_id => p_incl_object_id,
                  p_sql_string    => l_sql_string    ,
               p_primary_key   => null,
                  p_source_object_name => null,
                  x_msg_count      => x_msg_count      ,
                  x_msg_data   => x_msg_data   ,
                  x_return_status   => x_return_status   ,
                  x_std_sql                => x_std_sql,
                  x_include_sql            => x_include_sql
                  );

     l_final_big_sql := x_include_sql || x_std_sql ;
     l_const_sql := ' minus '||
               ' select list_entry_source_system_id ' ||
               ' from ams_list_entries ' ||
               ' where list_header_id  = ' || g_list_header_id   ;
     l_final_big_sql := l_final_big_sql || l_const_sql || ' )';
                  --write_to_act_log('l_final_big_sql',null,null);
     l_no_of_chunks  := ceil(length(l_final_big_sql)/2000 );
     for j in 1 ..l_no_of_chunks
     loop
        --WRITE_TO_ACT_LOG(substrb(l_final_big_sql,(2000*j) - 1999,2000),'LIST',g_list_header_id);
         null;
     end loop;
          --        write_to_act_log('x_include_sql');
     l_no_of_chunks  := ceil(nvl(length(x_include_sql)/2000,0) );
     --             write_to_act_log(l_no_of_chunks,null,null);
     for j in 1 ..l_no_of_chunks
     loop
      null;
    --    WRITE_TO_ACT_LOG(substrb(x_include_sql,(2000*j) - 1999,2000));
    --write_to_act_log('AMS_ListGeneration_PKG.Process_cell:');
     end loop;
    --write_to_act_log('AMS_ListGeneration_PKG.Process_cell:');
  EXECUTE IMMEDIATE l_final_big_sql;

END process_cell ;
--
PROCEDURE copy_target_group
             (p_from_schedule_id in  number,
              p_to_schedule_id in number,
              p_list_used_by   in VARCHAR2 DEFAULT 'CSCH',
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
               ) is
BEGIN

  copy_target_group
             (p_from_schedule_id ,
              p_to_schedule_id ,
              p_list_used_by   ,
      FND_API.G_FALSE,
              x_msg_count ,
              x_msg_data  ,
              x_return_status );

END copy_target_group;

-- created vbhandar 04/20 to distinguish between repeat and copy target group scenarios
PROCEDURE copy_target_group
             (p_from_schedule_id in  number,
              p_to_schedule_id in number,
              p_list_used_by   in VARCHAR2 DEFAULT 'CSCH',
      p_repeat_flag   in VARCHAR2 ,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
               )  is
l_list_type varchar2(30) := 'TARGET';
l_action_id number;
l_exclude_action_rec        ams_listaction_pvt.action_rec_type;
l_api_name          CONSTANT VARCHAR2(30) := 'copy_target_group';

--vbhandar modified 05-13-2004 TO fix bug 3621786 added apply traffic cop to select clause
cursor c_get_target_group is
select b.list_name, b.list_header_id, a.list_used_by, a.list_used_by_id,
       a.list_act_type, a.group_code, a.list_action_type, a.order_number,b.query_template_id,b.purpose_code,b.APPLY_TRAFFIC_COP,
       -- ckapoor R12 copy tg enhancements
       b.CTRL_CONF_LEVEL, b.CTRL_REQ_RESP_RATE, b.CTRL_LIMIT_OF_ERROR, b.STATUS_CODE_OLD, b.CTRL_CONC_JOB_ID, b.CTRL_STATUS_CODE, b.CTRL_GEN_MODE, b.APPLY_SUPPRESSION_FLAG,
       -- end ckapoor R12 copy tg enhancements
       c.schedule_name || ' - ' || c.source_code list_name1
       ,b.main_random_pct_row_selection,b.row_selection_type,b.no_of_rows_max_requested   --rmbhanda bug#4667513
from ams_act_lists  a, ams_list_headers_vl b, ams_campaign_schedules_vl c
where a.list_used_by = p_list_used_by
and a.list_used_by_id = p_from_schedule_id
and a.list_act_type = l_list_type
and a.list_header_id = b.list_header_id
and c.schedule_id = p_from_schedule_id
and c.schedule_id  = a.list_used_by_id ;

cursor c_get_target_group_comp is
select a.list_header_id, a.list_used_by, a.list_used_by_id,
       a.list_act_type, a.group_code, a.list_action_type, a.order_number
from ams_act_lists  a
where a.list_used_by = p_list_used_by
and a.list_used_by_id = p_from_schedule_id
and a.list_act_type <> l_list_type
order by order_number ;

cursor c_get_schedule_details is
select
a.tgrp_exclude_prev_flag
from ams_campaign_schedules_vl a
where a.schedule_id = p_from_schedule_id ;
l_target_group_rec  c_get_target_group%rowtype;

l_listheader_rec        ams_listheader_pvt.list_header_rec_type;
l_tmp_listheader_rec    ams_listheader_pvt.list_header_rec_type;
l_act_list_rec   AMS_ACT_LIST_PVT.act_list_rec_type ;
l_last_order_number number ;
l_exclude_flag varchar2(1);

l_return_status  VARCHAR2(1);
l_msg_count      number;
l_list_header_id number;
l_act_list_header_id number;
l_msg_data       VARCHAR2(2000);
j number := 0;


l_old_list_header_id NUMBER;
l_query_temp_id NUMBER;
l_old_query_id NUMBER;
l_query_id NUMBER;
l_templete_type  VARCHAR2(30);
l_old_templ_inst_id NUMBER;
l_new_templ_inst_id NUMBER;
l_target_group_found BOOLEAN := TRUE ;
l_purpose_code varchar2(120);
l_list_rule_id NUMBER;

cursor c_new_schedule_details is
select c.SCHEDULE_ID,c.SOURCE_CODE,c.SCHEDULE_NAME,c.schedule_name || ' - ' || c.source_code list_name
from ams_campaign_schedules_vl c
where c.schedule_id = p_to_schedule_id;

CURSOR c_get_query_templete_type(p_templete_id IN NUMBER) is
SELECT template_type
FROM ams_query_template_all
WHERE template_id=p_templete_id;

l_sched_rec c_new_schedule_details%rowtype;

CURSOR c_list_size (p_list_header_id IN NUMBER) is
SELECT no_of_rows_active
FROM ams_list_headers_all
WHERE list_header_id = p_list_header_id;

-- ckapoor R12 dedupe rule copy

CURSOR c_dedupe_rule(p_list_header_id IN NUMBER) is
select  list_rule_id from ams_list_rule_usages
where list_header_id = p_list_header_id;
-- ckapoor end R12 dedupe rule copy

l_excluded_list_size NUMBER;

begin
   SAVEPOINT copy_target_group_pvt;

  IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('Private API:AMS_Act_List_PVT.copy_target_group '||p_from_schedule_id||':::::'||p_to_schedule_id);
  END IF;

  open c_get_target_group;
  fetch c_get_target_group into l_target_group_rec  ;
  IF c_get_target_group%NOTFOUND THEN
     l_target_group_found := FALSE ;
  END IF;
  close c_get_target_group;

  IF AMS_DEBUG_HIGH_ON THEN
     IF l_target_group_found then
       AMS_Utility_PVT.debug_message('Private API: copy_target_group target group found');
     ELSE
       AMS_Utility_PVT.debug_message('Private API: copy_target_group target group not found');
     END IF;
  END IF;


  IF l_target_group_found THEN

      OPEN c_new_schedule_details;
      FETCH c_new_schedule_details INTO l_sched_rec;
      CLOSE c_new_schedule_details;

      ams_listheader_pvt.init_listheader_rec(l_tmp_listheader_rec);
      l_tmp_listheader_rec.list_header_id   := l_target_group_rec.list_header_id;
      l_old_list_header_id:=l_target_group_rec.list_header_id;
      l_query_temp_id := l_target_group_rec.query_template_id;
      l_purpose_code := l_target_group_rec.purpose_code;

     --vbhandar modified 05-13-2004 TO fix bug 3621786
      l_tmp_listheader_rec.APPLY_TRAFFIC_COP := l_target_group_rec.APPLY_TRAFFIC_COP;


      ams_listheader_pvt.complete_listheader_rec
                       (p_listheader_rec  =>l_tmp_listheader_rec,
                        x_complete_rec    =>l_listheader_rec);
      l_listheader_rec.list_header_id := fnd_api.g_miss_num;
      l_listheader_rec.list_name := l_sched_rec.list_name; -- Kiran changed to l_sched_rec.list_name
      --l_listheader_rec.list_name := l_listheader_rec.list_name || '_'||
                                        --p_to_schedule_id ;
     -- l_listheader_rec.NO_OF_ROWS_DUPLICATES        := 0;
      --l_listheader_rec.NO_OF_ROWS_MIN_REQUESTED         := 0;
      --l_listheader_rec.NO_OF_ROWS_MAX_REQUESTED             := 0;
       l_listheader_rec.request_id := null;
       l_listheader_rec.status_code:= null;
       l_listheader_rec.status_date:= null;
       l_listheader_rec.repeat_exclude_type:= null;
      -- l_listheader_rec.row_selection_type:= null; rmbhanda bug#4667513
       l_listheader_rec.row_selection_type:= l_target_group_rec.row_selection_type;  --rmbhanda bug#4667513
       l_listheader_rec.dedupe_during_generation_flag:= null;
       l_listheader_rec.last_generation_success_flag:= null;
       l_listheader_rec.forecasted_start_date:= null;
       l_listheader_rec.forecasted_end_date:= null;
       l_listheader_rec.actual_end_date:= null;
       l_listheader_rec.sent_out_date:= null;
       l_listheader_rec.last_dedupe_date:= null;
       l_listheader_rec.last_deduped_by_user_id:= null;
       l_listheader_rec.workflow_item_key:= null;
       l_listheader_rec.no_of_rows_duplicates:= null;
       l_listheader_rec.no_of_rows_min_requested:= null;
       --l_listheader_rec.no_of_rows_max_requested:= null; rmbhanda bug#4667513
       l_listheader_rec.no_of_rows_max_requested:= l_target_group_rec.no_of_rows_max_requested;  --rmbhanda bug#4667513
       l_listheader_rec.main_random_pct_row_selection:=l_target_group_rec.main_random_pct_row_selection; --rmbhanda bug#4667513
       l_listheader_rec.no_of_rows_in_list:= null;
       l_listheader_rec.no_of_rows_in_ctrl_group:= null;
       l_listheader_rec.no_of_rows_active:= null;
       l_listheader_rec.no_of_rows_inactive:= null;
       l_listheader_rec.no_of_rows_manually_entered:= null;
       l_listheader_rec.no_of_rows_do_not_call:= null;
       l_listheader_rec.no_of_rows_do_not_mail:= null;
       l_listheader_rec.no_of_rows_random:= null;
       l_listheader_rec.main_gen_start_time:= null;
       l_listheader_rec.main_gen_end_time:= null;
       l_listheader_rec.archived_by:= null;
       l_listheader_rec.archived_date:= null;
       l_listheader_rec.sent_out_date :=null;
       l_listheader_rec.list_used_by_id :=p_to_schedule_id;
       l_listheader_rec.purpose_code := l_purpose_code;

      --l_listheader_rec.NO_OF_ROWS_DO_NOT_CALL             :=0;
      --l_listheader_rec.NO_OF_ROWS_DO_NOT_MAIL          :=0;
      --l_listheader_rec.NO_OF_ROWS_RANDOM            :=0;
      --vbhandar uncommented 04/02/2004 to fix bug 3550623
      l_listheader_rec.NO_OF_ROWS_PREV_CONTACTED    :=0;

      -- ckapoor R12 copy target group enhancements

      l_listheader_rec.CTRL_CONC_JOB_Id := null;
      l_listheader_rec.ctrl_status_code := 'DRAFT';
      l_listheader_rec.status_code_old := null;


      -- ckapoor R12 copy
       AMS_ListHeader_PVT.Create_Listheader
          ( p_api_version           => 1.0,
            p_init_msg_list         => FND_API.g_false,
            p_commit                => FND_API.g_false,
            p_validation_level      => FND_API.g_valid_level_full,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_listheader_rec        => l_listheader_rec,
            x_listheader_id         => l_list_header_id
            );
           UPDATE ams_list_headers_all SET query_template_id = l_query_temp_id
           WHERE list_header_id = l_list_header_id;
      --for i in 1 .. l_msg_count loop
            --FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                        --FND_API.G_FALSE,
                        --l_msg_data,
                        --l_msg_count);
      --end loop;
       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Private API: copy_target_group, done creating header '||l_list_header_id);
       END IF;

       copy_selections
          ( p_old_header_id => l_old_list_header_id,
            p_new_header_id => l_list_header_id,
            p_list_name => l_listheader_rec.list_name,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            x_return_status         => l_return_status,
            x_query_id                =>l_query_id
         );

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_selections '||FND_API.G_VALID_LEVEL_FULL);
       END IF;


       IF  l_query_temp_id IS NOT NULL THEN

          IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group, l_query_temp_id : '||l_query_temp_id);
          END IF;

          OPEN c_get_query_templete_type(l_query_temp_id);
          FETCH c_get_query_templete_type INTO l_templete_type;
          CLOSE c_get_query_templete_type;

          IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group, template_type'||l_templete_type);
          END IF;

          IF l_templete_type = 'STANDARD' THEN
             copy_template_instance
                ( p_query_templ_id => l_query_temp_id,
                  p_old_header_id => l_old_list_header_id,
                  p_new_header_id => l_list_header_id,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  x_return_status         => l_return_status,
                  x_old_templ_inst_id    => l_old_templ_inst_id,
                  x_new_templ_inst_id    => l_new_templ_inst_id
                );

             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;

             IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_template_instance');
             END IF;

             IF (AMS_DEBUG_HIGH_ON) THEN
                AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_conditions' );
             END IF;

          END IF;

       END IF; --l_query_temp_id IS NOT NULL

       -- ckapoor R12 copy dedupe rule

       -- cursor to retrieve the rule id

          OPEN c_dedupe_rule(l_old_list_header_id);
          FETCH c_dedupe_rule INTO l_list_rule_id;
          CLOSE c_dedupe_rule;

       -- insert a new row in ams_list_rule_usages

       if (l_list_rule_id is not null) then

       insert into ams_list_rule_usages
       	(LIST_RULE_USAGE_ID, LIST_HEADER_ID, LIST_RULE_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
       	CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER, ACTIVE_FROM_DATE,
       	ACTIVE_TO_DATE, PRIORITY, SECURITY_GROUP_ID)
       	values (
       	ams_list_rule_usages_s.nextval,
       	l_list_header_id,
       	l_list_rule_id,
       	sysdate,
       	FND_GLOBAL.User_Id,
       	sysdate,
       	FND_GLOBAL.User_Id,
       	FND_GLOBAL.Conc_Login_Id,
       	1,
       	sysdate,
       	null,
       	null,
       	null

	);

	end if;




       -- end ckapoor R12 copy dedupe rule

       l_act_list_rec.list_header_id   := l_list_header_id;
       l_act_list_rec.list_used_by     := p_list_used_by   ;
       l_act_list_rec.list_used_by_id  := p_to_schedule_id ;
       l_act_list_rec.list_act_type    := 'TARGET';

       AMS_ACT_LIST_PVT.Create_Act_List(
          p_api_version_number    => 1.0,
          p_init_msg_list         => FND_API.g_false,
          p_commit                => FND_API.g_false,
          p_validation_level      => FND_API.g_valid_level_full,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_act_list_rec          => l_act_list_rec  ,
          x_act_list_header_id    => l_act_list_header_id
          ) ;

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;


         IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group, done Create_Act_List For Target Group ');
         END IF;


       for l_target_group_rec  in c_get_target_group_comp
       loop
       IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group, call Create_Act_List For Target Group Components ');
         END IF;
          j := j + 1;
          l_act_list_rec.list_used_by     := l_target_group_rec.list_used_by;
          l_act_list_rec.list_used_by_id  := p_to_schedule_id;
          l_act_list_rec.list_act_type    := l_target_group_rec.list_act_type;
          l_act_list_rec.list_action_type := l_target_group_rec.list_action_type ;
          l_act_list_rec.order_number     := l_target_group_rec.order_number     ;
          l_act_list_rec.group_code       := l_target_group_rec.group_code       ;
  IF l_act_list_rec.list_act_type= 'SQL' AND l_templete_type = 'PARAMETERIZED' THEN
    l_act_list_rec.list_header_id := l_query_id;
  ELSIF l_act_list_rec.list_act_type= 'SQL' AND l_templete_type = 'STANDARD' THEN
    l_act_list_rec.list_header_id := l_query_id;
  ELSE
            l_act_list_rec.list_header_id := l_target_group_rec.list_header_id ;
  END IF;
          l_last_order_number := l_target_group_rec.order_number     ;

          IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('l_query_id ' || l_query_id );
     AMS_Utility_PVT.debug_message('l_templete_type ' || l_templete_type );
             AMS_Utility_PVT.debug_message('l_act_list_rec.list_used_by ' || l_act_list_rec.list_used_by );
     AMS_Utility_PVT.debug_message('l_act_list_rec.list_used_by_id ' || l_act_list_rec.list_used_by_id );
     AMS_Utility_PVT.debug_message('l_act_list_rec.list_act_type ' || l_act_list_rec.list_act_type );
     AMS_Utility_PVT.debug_message('l_act_list_rec.list_action_type ' ||l_act_list_rec.list_action_type );
     AMS_Utility_PVT.debug_message('l_act_list_rec.order_number ' || l_act_list_rec.order_number );
     AMS_Utility_PVT.debug_message('l_act_list_rec.list_header_id ' || l_act_list_rec.list_header_id );
         END IF;

          AMS_ACT_LIST_PVT.Create_Act_List(
             p_api_version_number    => 1.0,
             p_init_msg_list         => FND_API.g_false,
             p_commit                => FND_API.g_false,
             p_validation_level      => FND_API.G_VALID_LEVEL_FULL, --here
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data,
             p_act_list_rec          => l_act_list_rec  ,
             x_act_list_header_id    => l_act_list_header_id
             ) ;

           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

           IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_Utility_PVT.debug_message('Private API: copy_target_group, done second Create_Act_List');
           END IF;

      if j = 1 then
        --bug 4623994
        /*for i in 1 .. l_msg_count loop
              FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                              FND_API.G_FALSE,
                              l_msg_data,
                              l_msg_count);
        end loop;*/
	null;
      end if;
       end loop;
      IF  p_repeat_flag  = FND_API.G_TRUE then

      open c_get_schedule_details;
      fetch c_get_schedule_details into l_exclude_flag  ;
      close c_get_schedule_details ;
      if l_exclude_flag = 'Y' then
    open c_get_target_group;
    fetch c_get_target_group into l_target_group_rec  ;
    close c_get_target_group;
    l_act_list_rec.list_header_id   := l_target_group_rec.list_header_id;
    l_act_list_rec.list_used_by     := l_target_group_rec.list_used_by;
    l_act_list_rec.list_used_by_id  := p_to_schedule_id;
    l_act_list_rec.list_act_type    := 'LIST';
    l_act_list_rec.list_action_type := 'EXCLUDE' ;
    l_act_list_rec.order_number     := l_last_order_number +5    ;
    l_act_list_rec.group_code       := l_target_group_rec.group_code       ;
    AMS_ACT_LIST_PVT.Create_Act_List(
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.g_false,
        p_commit                => FND_API.g_false,
        p_validation_level      => FND_API.g_valid_level_full,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        p_act_list_rec          => l_act_list_rec  ,
        x_act_list_header_id    => l_act_list_header_id
        ) ;
   --bug 4623994
   /*for i in 1 .. l_msg_count loop
         FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
               FND_API.G_FALSE,
               l_msg_data,
               l_msg_count);
   end loop;*/

      AMS_ListAction_PVT.init_action_rec(l_exclude_action_rec);

      --vbhandar added to fix bug 3595605
      OPEN c_list_size(l_act_list_rec.list_header_id);
      FETCH c_list_size INTO l_excluded_list_size;
      CLOSE c_list_size;

      IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message('Private API: copy_target_group, excluded list size '|| l_excluded_list_size);
              END IF;
               --vbhandar added to fix bug 3595605

      l_exclude_action_rec.list_select_action_id          := NULL;
      l_exclude_action_rec.order_number          := l_act_list_rec.order_number;
      l_exclude_action_rec.list_action_type      := l_act_list_rec.list_action_type;
      l_exclude_action_rec.arc_incl_object_from  := 'LIST';
      l_exclude_action_rec.arc_action_used_by    := 'LIST';
      l_exclude_action_rec.action_used_by_id     := l_list_header_id;
      l_exclude_action_rec.rank                  := l_act_list_rec.order_number;
      l_exclude_action_rec.incl_object_id        := l_act_list_rec.list_header_id ;
      l_exclude_action_rec.distribution_pct      := NULL;
      l_exclude_action_rec.no_of_rows_available  := l_excluded_list_size; --NULL; vbhandar added to fix bug 3595605
      l_exclude_action_rec.no_of_rows_requested  := NULL;
      l_exclude_action_rec.no_of_rows_used       := NULL;
      l_exclude_action_rec.description           := NULL;
      l_exclude_action_rec.no_of_rows_targeted  := NULL;

       IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('Private API: copy_target_group, CAlling Create List Action in Copy tG');
       END IF;

      AMS_ListAction_PVT.Create_ListAction
    ( 1.0,
      FND_API.g_false,
      FND_API.g_false ,
      FND_API.G_VALID_LEVEL_FULL, --here
      l_return_status ,
      l_msg_count,
      l_msg_data,
      l_exclude_action_rec,
      l_action_id
   ) ;


       IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('Private API: copy_target_group, l_returnStatus after create list' ||l_return_status);
       END IF;




    IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
     --bug 4623994
     /*for i in 1 .. l_msg_count loop
         FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
               FND_API.G_FALSE,
               l_msg_data,
               l_msg_count);
   end loop;*/
      end if;
END IF; -- p_repeat_flag = Y

       IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group,finished');
       END IF;
--RAISE FND_API.G_EXC_ERROR;
END IF ; -- if l_target_group_found
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO copy_target_group_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO copy_target_group_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO copy_target_group_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END copy_target_group;


PROCEDURE copy_selections
             (p_old_header_id in  number,
              p_new_header_id in number,
              p_list_name   IN varchar2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_query_id     OUT NOCOPY NUMBER
               )  is


CURSOR c_select_actions(p_header_id IN number) IS
SELECT   LIST_SELECT_ACTION_ID
FROM ams_list_select_actions WHERE action_used_by_id=p_header_id;

CURSOR fetch_list_select_actions(p_header_id NUMBER) IS
  SELECT incl_object_id,rank,order_number,description,list_action_type
             ,no_of_rows_requested,no_of_rows_available,no_of_rows_used
     ,distribution_pct,no_of_rows_targeted,incl_object_name,arc_incl_object_from,arc_action_used_by
  FROM ams_list_select_actions
  WHERE action_used_by_id =p_header_id
  order by order_number;

l_return_status  VARCHAR2(1);
l_msg_count      number;
l_action_id number;
l_act_list_header_id number;
l_msg_data       VARCHAR2(2000);
l_api_version         CONSTANT NUMBER        := 1.0;
l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;
l_list_select_action_id NUMBER;
l_listaction_rec        ams_listaction_pvt.action_rec_type;
l_tmp_listaction_rec    ams_listaction_pvt.action_rec_type;
l_action_rec                     AMS_ListAction_PVT.action_rec_type;

l_list_name       VARCHAR (300);
l_new_query_id  NUMBER;
l_old_list_header_id NUMBER;
BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('Private API: copy_selections: Begin');
   END IF;

   OPEN c_select_actions(p_old_header_id);
   FETCH c_select_actions INTO l_list_select_action_id;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('copy_selections old '||p_old_header_id);
      AMS_Utility_PVT.debug_message('copy_selections new '||p_new_header_id);
   END IF;

   FOR l_list_actions_rec IN fetch_list_select_actions(p_old_header_id)
   LOOP

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('********************copy_selections enter loop');
      END IF;

      AMS_ListAction_PVT.init_action_rec(l_action_rec);
      l_action_rec.list_select_action_id          := NULL;
      l_action_rec.order_number          := l_list_actions_rec.order_number;
      l_action_rec.list_action_type      := l_list_actions_rec.list_action_type;
--      l_action_rec.incl_object_name   := l_list_actions_rec.incl_object_name;
      l_action_rec.arc_incl_object_from  := l_list_actions_rec.arc_incl_object_from;
      l_action_rec.no_of_rows_available  := l_list_actions_rec.no_of_rows_available;
      l_action_rec.no_of_rows_requested  := l_list_actions_rec.no_of_rows_requested;
      l_action_rec.no_of_rows_used       := l_list_actions_rec.no_of_rows_used;
      l_action_rec.distribution_pct      := l_list_actions_rec.distribution_pct;
      l_action_rec.description           := l_list_actions_rec.description;
      l_action_rec.arc_action_used_by    := 'LIST';
      l_action_rec.action_used_by_id     := p_new_header_id;
      l_action_rec.no_of_rows_targeted  := l_list_actions_rec.no_of_rows_targeted;
      l_action_rec.rank  := l_list_actions_rec.rank;
      l_action_rec.incl_object_id  := l_list_actions_rec.incl_object_id;

       AMS_Utility_PVT.debug_message('Action Rec Incl Object ID first ' || l_action_rec.incl_object_id);
--start
      IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Private API: copy_target_group, begin copy_list_queries 1');
      END IF;

      IF l_list_actions_rec.arc_incl_object_from = 'SQL' THEN
          l_list_name := p_list_name;
          copy_list_queries
             ( p_old_header_id => l_old_list_header_id,
               p_new_header_id => p_new_header_id,
               p_list_name => l_list_name,
               p_old_query_id  => l_list_actions_rec.incl_object_id,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data,
               x_return_status         => l_return_status,
               x_new_query_id          => l_new_query_id
             );
         IF (AMS_DEBUG_HIGH_ON) THEN
             AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_list_queries 1' || l_new_query_id || ':::');
         END IF;

  AMS_Utility_PVT.debug_message('Action Rec Incl Object ID second ' || l_action_rec.incl_object_id);
         l_action_rec.incl_object_id  := l_new_query_id;
          x_query_id := l_action_rec.incl_object_id;
         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_list_queries 2');
         END IF;


         copy_query_list_params
          ( p_old_query_id => l_list_actions_rec.incl_object_id,
            p_new_query_id => l_new_query_id,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            x_return_status         => l_return_status
          );

         IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_Utility_PVT.debug_message('Private API: copy_target_group, done copy_query_list_params');
         END IF;
      END IF ;
--end


       IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('CAlling Create List Action in Copy Selections');
      END IF;

      AMS_ListAction_PVT.Create_ListAction
         ( l_api_version,
           l_init_msg_list,
           FND_API.g_false ,
           FND_API.G_VALID_LEVEL_FULL, --here
           l_return_status , -------------VBCHANGE--------------------
           l_msg_count,-------------VBCHANGE--------------------
           l_msg_data,-------------VBCHANGE--------------------
           l_action_rec,
           l_action_id
        ) ;

-------------VBCHANGE--------------------
/* FOR i IN 1 .. l_msg_count LOOP
      l_msg_data := FND_MSG_PUB.get(i, FND_API.g_false);
      AMS_Utility_PVT.debug_message('(' || i || ') ' || l_msg_data);
   END LOOP;*/

 IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('Return status from Create_ListAction'||l_return_status);
      END IF;
       IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

-------------VBCHANGE--------------------
      UPDATE ams_list_select_actions SET incl_object_name = l_list_actions_rec.incl_object_name
      WHERE list_select_action_id = l_action_id;
--------------      x_query_id := l_action_rec.incl_object_id;------------VBCHANGE---------
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_selections done creation');
      END IF;


  END LOOP;

END copy_selections;


PROCEDURE copy_list_queries
             ( p_old_header_id  IN NUMBER,
               p_new_header_id  IN NUMBER,
               p_list_name IN varchar2,
               p_old_query_id  IN NUMBER,
               x_msg_count      OUT NOCOPY number,
               x_msg_data       OUT NOCOPY varchar2,
               x_return_status  IN OUT NOCOPY VARCHAR2,
               x_new_query_id   OUT NOCOPY NUMBER
             )  is

CURSOR c_queries(p_query_id IN number) IS
   SELECT   LIST_QUERY_ID
   FROM ams_list_queries_all WHERE list_query_id = p_query_id;

--sql_string column is obsolete bug 4604653
CURSOR fetch_list_queries_all(p_query_id NUMBER) IS
   SELECT list_query_id,name,type,query,primary_key,source_object_name,act_list_query_used_by_id,arc_act_list_query_used_by,seed_flag,parameterized_flag,admin_flag,query_template_id,query_type
   FROM ams_list_queries_vl
   WHERE list_query_id = p_query_id;

/*
CURSOR fetch_long_query_val(p_query_id NUMBER) IS
   SELECT query
   FROM ams_list_queries_all
   WHERE list_query_id = p_query_id;
*/

long_var LONG;
l_queries_rec fetch_list_queries_all%rowtype;
l_api_version         CONSTANT NUMBER        := 1.0;
l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;
l_tmplist_query_rec  AMS_List_Query_PVT.list_query_rec_type;
l_list_query_rec    AMS_List_Query_PVT.list_query_rec_type;

l_return_status  VARCHAR2(1);
l_msg_count      number;
l_action_id number;
l_act_list_header_id number;
l_msg_data       VARCHAR2(2000);
l_old_list_query_id NUMBER;
l_list_query_id NUMBER;

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('copy_list_queries p_old_query_id = ' || p_old_query_id);
   END IF;

   OPEN fetch_list_queries_all(p_old_query_id);
   FETCH fetch_list_queries_all INTO l_queries_rec;

   IF fetch_list_queries_all%NOTFOUND THEN
   null;
   ELSE
      l_list_query_rec.name := p_list_name;
      l_list_query_rec.type := l_queries_rec.type;
      l_list_query_rec.sql_string:= l_queries_rec.query;
      --sql_string goes into query column via table handler pkg

      l_list_query_rec.primary_key :=l_queries_rec.primary_key;
      l_list_query_rec.source_object_name := l_queries_rec.source_object_name;

      l_list_query_rec.arc_act_list_query_used_by := NULL;
      l_list_query_rec.seed_flag :=l_queries_rec.seed_flag;
      l_list_query_rec.act_list_query_used_by_id := p_new_header_id;

      l_list_query_rec.object_version_number :=1;


      AMS_List_Query_PVT.Create_List_Query(
            p_api_version_number  => 1.0,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL, --here
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_list_query_rec      => l_list_query_rec ,
            x_list_query_id       => l_list_query_id
            );
      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_queries...l_list_query_id '||l_list_query_id );
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   /*
     OPEN fetch_long_query_val(p_old_query_id);
      FETCH fetch_long_query_val INTO long_var;
   */
      UPDATE ams_list_queries_all
      SET --query = long_var,
      parameterized_flag = l_queries_rec.parameterized_flag,
      admin_flag = l_queries_rec.admin_flag,
      query_template_id = l_queries_rec.query_template_id,
      query_type = l_queries_rec.query_type,
      seed_flag = l_queries_rec.seed_flag,
      arc_act_list_query_used_by = l_queries_rec.arc_act_list_query_used_by
      WHERE list_query_id = l_list_query_id;

   END IF;
--   CLOSE fetch_list_queries_all;

   x_new_query_id := l_list_query_id;

END copy_list_queries;

PROCEDURE copy_query_list_params
          (p_old_query_id in  number,
   p_new_query_id in number,
           x_msg_count      OUT NOCOPY number,
           x_msg_data       OUT NOCOPY varchar2,
           x_return_status  IN OUT NOCOPY VARCHAR2
          ) is

 CURSOR fetch_list_query_params(p_query_id NUMBER) IS
      SELECT list_query_param_id, list_query_id, parameter_order, parameter_value, last_update_date, last_updated_by, creation_date,
      created_by, last_update_login, object_version_number, attb_lov_id, param_value_2, condition_value, parameter_name, display_name
      FROM AMS_LIST_QUERIES_PARAM_VL
      WHERE list_query_id =p_query_id;

CURSOR c_qlp is
SELECT AMS_LIST_QUERIES_PARAM_s.NEXTVAL FROM dual;


l_api_version         CONSTANT NUMBER        := 1.0;
l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;
l_sql VARCHAR2(5000);
l_list_query_param_id NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count      number;
l_msg_data       VARCHAR2(2000);
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_Utility_PVT.debug_message('copy_query_list_params  '||p_old_query_id||':::'||p_new_query_id);
   END IF;

   FOR l_query_param_rec IN fetch_list_query_params(p_old_query_id)
   LOOP
      OPEN c_qlp;
      FETCH c_qlp INTO l_list_query_param_id;
      CLOSE c_qlp;

      IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_Utility_PVT.debug_message('copy_query_list_params  in loop' || l_list_query_param_id);
      END IF;

      AMS_LIST_QUERIES_PARAM_PKG.INSERT_ROW (
            X_LIST_QUERY_PARAM_ID => l_list_query_param_id,
            X_ATTB_LOV_ID =>l_query_param_rec.attb_lov_id,
            X_PARAM_VALUE_2 => l_query_param_rec.param_value_2,
            X_CONDITION_VALUE => l_query_param_rec.condition_value,
            X_PARAMETER_NAME => l_query_param_rec.parameter_name,
            X_LIST_QUERY_ID =>p_new_query_id,
            X_PARAMETER_ORDER => l_query_param_rec.parameter_order,
            X_PARAMETER_VALUE =>l_query_param_rec.parameter_value,
            X_OBJECT_VERSION_NUMBER => 1,
            X_DISPLAY_NAME => l_query_param_rec.display_name,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => FND_GLOBAL.User_Id,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => FND_GLOBAL.User_Id,
            X_LAST_UPDATE_LOGIN =>FND_GLOBAL.CONC_LOGIN_ID
          );

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_query_list_params  in loop' || l_list_query_param_id);
      END IF;

   END LOOP;
END copy_query_list_params;


PROCEDURE  copy_template_instance(
              p_query_templ_id in  number,
              p_old_header_id in  number,
              p_new_header_id in number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
      x_old_templ_inst_id    OUT NOCOPY number,
     x_new_templ_inst_id  OUT NOCOPY number
     )is
CURSOR c_templInst is
SELECT ams_query_template_instance_s.NEXTVAL FROM dual;

CURSOR fetch_templ_instance(p_header_id NUMBER) IS
      SELECT template_instance_id, admin_indicator_flag, request_id, view_application_id, instance_used_by, instance_used_by_id
      FROM ams_query_template_instance
      where instance_used_by_id = p_header_id;


l_api_version         CONSTANT NUMBER        := 1.0;
l_init_msg_list    VARCHAR2(2000)    := FND_API.G_FALSE;
l_sql VARCHAR2(5000);
l_templ_inst_id NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count      number;
l_msg_data       VARCHAR2(2000);

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('copy_template_instance  '||p_old_header_id||':::'||p_new_header_id);
   END IF;

   FOR l_templ_inst_rec IN fetch_templ_instance(p_old_header_id)
   LOOP

      OPEN c_templInst;
         FETCH c_templInst INTO l_templ_inst_id;
      CLOSE c_templInst;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_template_instance in loop '||l_templ_inst_id);
      END IF;

      x_old_templ_inst_id := l_templ_inst_rec.template_instance_id;
      x_new_templ_inst_id := l_templ_inst_id;

      AMS_QUERY_TEMP_INST_PKG.INSERT_ROW (
              X_TEMPLATE_INSTANCE_ID => l_templ_inst_id,
              X_TEMPLATE_ID => p_query_templ_id,
              X_ADMIN_INDICATOR_FLAG => l_templ_inst_rec.admin_indicator_flag,
              X_OBJECT_VERSION_NUMBER => 1,
              X_REQUEST_ID => NULL,
              X_VIEW_APPLICATION_ID => l_templ_inst_rec.view_application_id,
              X_INSTANCE_USED_BY => 'LIST',
              X_INSTANCE_USED_BY_ID => p_new_header_id ,
              X_CREATION_DATE => SYSDATE ,
              X_CREATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_DATE => SYSDATE ,
              X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
            );

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_template_instance in loop done');
      END IF;

    copy_conditions
               ( p_old_templ_inst_id => x_old_templ_inst_id,
                 p_new_templ_inst_id =>  l_templ_inst_id,
                 x_msg_count             => l_msg_count,
                 x_msg_data              => l_msg_data,
                 x_return_status         => l_return_status
               );

   END LOOP;

END copy_template_instance;

PROCEDURE  copy_conditions(
              p_old_templ_inst_id in  number,
              p_new_templ_inst_id in  number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
     )is
CURSOR c_cond_assoc is
SELECT ams_query_temp_inst_cond_asc_s.NEXTVAL FROM dual;

CURSOR c_cond_value is
SELECT ams_query_condition_value_s.NEXTVAL FROM dual;


CURSOR fetch_condition_assoc(p_templ_inst_id NUMBER) IS
      SELECT assoc_id ,template_instance_id,query_condition_id,condition_sequence,running_total, delta
      FROM ams_query_temp_inst_cond_assoc
      where template_instance_id = p_templ_inst_id;

CURSOR fetch_condition_value(p_assoc_id NUMBER) IS
      SELECT query_cond_value_id,assoc_id,query_cond_disp_struct_id,value,lov_values_included_flag
      FROM ams_query_condition_value
      where assoc_id = p_assoc_id;

l_assoc_id NUMBER;
l_old_assoc_id NUMBER;
l_cond_value_id NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count      number;
l_msg_data       VARCHAR2(2000);

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('copy_conditions '||p_old_templ_inst_id ||'::'||p_new_templ_inst_id);
   END IF;


   FOR l_cond_assoc_rec IN fetch_condition_assoc(p_old_templ_inst_id)
   LOOP

      OPEN c_cond_assoc;
         FETCH c_cond_assoc INTO l_assoc_id;
      CLOSE c_cond_assoc;

      l_old_assoc_id := l_cond_assoc_rec.assoc_id;

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_conditions found assoc'||l_old_assoc_id);
      END IF;

      ams_query_tmp_assoc_pkg.insert_row (
              X_ASSOC_ID => l_assoc_id,
              X_TEMPLATE_INSTANCE_ID=>p_new_templ_inst_id,
              X_QUERY_CONDITION_ID => l_cond_assoc_rec.query_condition_id ,
              X_CONDITION_SEQUENCE => l_cond_assoc_rec.condition_sequence ,
              X_RUNNING_TOTAL => l_cond_assoc_rec.running_total ,
              X_DELTA => l_cond_assoc_rec.delta ,
              X_OBJECT_VERSION_NUMBER =>1,
              X_REQUEST_ID =>NULL,
              X_CREATION_DATE => SYSDATE ,
              X_CREATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_DATE => SYSDATE ,
              X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
            );

      IF (AMS_DEBUG_HIGH_ON) THEN
         AMS_Utility_PVT.debug_message('copy_conditions new  assoc'||l_assoc_id);
      END IF;

         FOR l_cond_value_rec IN fetch_condition_value(l_old_assoc_id)
         LOOP

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message('copy_conditions found cond values for '||l_old_assoc_id);
            END IF;

            OPEN c_cond_value;
              FETCH c_cond_value INTO l_cond_value_id;
            CLOSE c_cond_value;

           AMS_QUERY_CONDITION_VALUE_PKG.INSERT_ROW (
              X_QUERY_COND_VALUE_ID=>l_cond_value_id,
              X_ASSOC_ID => l_assoc_id,
              X_QUERY_COND_DISP_STRUCT_ID => l_cond_value_rec.query_cond_disp_struct_id,
              X_VALUE =>l_cond_value_rec.value,
              X_LOV_VALUES_INCLUDED_FLAG => l_cond_value_rec.lov_values_included_flag,
              X_OBJECT_VERSION_NUMBER =>1,
              X_REQUEST_ID => NULL,
              X_CREATION_DATE => SYSDATE ,
              X_CREATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_DATE => SYSDATE ,
              X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
              X_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
            );

            IF (AMS_DEBUG_HIGH_ON) THEN
               AMS_Utility_PVT.debug_message('copy_conditions new cond values '||l_assoc_id||'::::'||l_cond_value_id);
            END IF;
         END LOOP;
   END LOOP;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_Utility_PVT.debug_message('copy_conditions end ');
   END IF;

END copy_conditions;

------------------------------------------------------------------------------------------------------------------
--------------------------Procedure to INVOKE TARGETGROUP LOCK Begins here----------------------------------------
------------------------------------------------------------------------------------------------------------------

--===============================================================================================
-- Procedure
--   INVOKE_TARGET_GROUP_LOCK
--
-- PURPOSE
--    This api is called to check for the schedules in ACTIVE State(Campaign or Event).
--
-- ALGORITHM
--    1. Get All parameter Types
--
--  Any error in any of the API callouts?
--   => a) Set RETURN STATUS to E
--
-- OPEN ISSUES
--   1. Should we do a explicit exit on Object_type not found.
--
-- HISTORY
--    19-Apr-2005  ndadwal
--===============================================================================================

FUNCTION INVOKE_TARGET_GROUP_LOCK ( p_subscription_guid   IN       RAW,
				    p_event               IN OUT NOCOPY  WF_EVENT_T) RETURN VARCHAR2
 IS

 --Local Variables

   l_obj_id			 NUMBER;
   l_obj_type			VARCHAR2(30);
   l_old_status_code		VARCHAR2(30);
   l_new_status_code		VARCHAR2(30);
   l_related_event_obj_type	VARCHAR2(30);
   l_related_event_id		VARCHAR2(30);
   l_msg_count			NUMBER;
   l_msg_data			VARCHAR2(30);
   l_return_status		VARCHAR2(30);

BEGIN

   -- Fetch all values, coming from the business event
   l_obj_id := p_event.getValueForParameter('OBJECT_ID');
   l_obj_type := p_event.getValueForParameter('OBJECT_TYPE');
   l_old_status_code := p_event.getValueForParameter('OLD_STATUS');
   l_new_status_code := p_event.getValueForParameter('NEW_STATUS');
   l_related_event_obj_type := p_event.getValueForParameter('RELATED_EVENT_OBJECT_TYPE');
   l_related_event_id := p_event.getValueForParameter('RELATED_EVENT_OBJECT_ID');

 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('****FUNCTION: INVOKE_TARGET_GROUP_LOCK start****');
 END IF;
 IF ( l_obj_type = 'CSCH' AND l_new_status_code = 'ACTIVE')
   THEN

		IF ( ( l_related_event_obj_type IS NOT NULL ) AND ( l_related_event_id IS NOT NULL ) )
		THEN

		IF (AMS_DEBUG_HIGH_ON) THEN
			AMS_Utility_PVT.debug_message('For OneOffEvent Active Schedules');
			AMS_Utility_PVT.debug_message('P_OBJECT_TYPE ' || l_related_event_obj_type );
			AMS_Utility_PVT.debug_message('P_OBJ_ID ' || l_related_event_id );
			AMS_Utility_PVT.debug_message('X_MSG_COUNT' || l_msg_count);
			AMS_Utility_PVT.debug_message('X_MSG_DATA' || l_msg_data);
			AMS_Utility_PVT.debug_message('X_RETURN_STATUS' || l_return_status);
		END IF;
		UPDATE_LIST_STATUS_TO_LOCKED(P_OBJECT_TYPE    => l_related_event_obj_type ,
					     P_OBJ_ID         => l_related_event_id,
					     X_MSG_COUNT => l_msg_count,
					     X_MSG_DATA  =>l_msg_data,
					     X_RETURN_STATUS => l_return_status);



		ELSE

		IF (AMS_DEBUG_HIGH_ON) THEN
			AMS_Utility_PVT.debug_message('For Campaign Active Schedules');
			AMS_Utility_PVT.debug_message('P_OBJECT_TYPE ' || l_obj_type );
			AMS_Utility_PVT.debug_message('P_OBJ_ID ' || l_obj_id );
			AMS_Utility_PVT.debug_message('X_MSG_COUNT' || l_msg_count);
			AMS_Utility_PVT.debug_message('X_MSG_DATA' || l_msg_data);
			AMS_Utility_PVT.debug_message('X_RETURN_STATUS' || l_return_status);
		END IF;
		UPDATE_LIST_STATUS_TO_LOCKED(P_OBJECT_TYPE    => l_obj_type ,
					     P_OBJ_ID         => l_obj_id,
					     X_MSG_COUNT => l_msg_count,
					     X_MSG_DATA  =>l_msg_data,
					     X_RETURN_STATUS => l_return_status);


		END IF;

  ELSIF (((l_obj_type = 'EONE') OR (l_obj_type = 'EVEO') ) AND (l_new_status_code = 'ACTIVE'))
  THEN

		IF (AMS_DEBUG_HIGH_ON) THEN
			AMS_Utility_PVT.debug_message('For EONE/EVEO Active Schedules');
			AMS_Utility_PVT.debug_message('P_OBJECT_TYPE ' || l_obj_type );
			AMS_Utility_PVT.debug_message('P_OBJ_ID ' || l_obj_id );
			AMS_Utility_PVT.debug_message('X_MSG_COUNT' || l_msg_count);
			AMS_Utility_PVT.debug_message('X_MSG_DATA' || l_msg_data);
			AMS_Utility_PVT.debug_message('X_RETURN_STATUS' || l_return_status);
		END IF;
		UPDATE_LIST_STATUS_TO_LOCKED(P_OBJECT_TYPE    => l_obj_type ,
					     P_OBJ_ID         => l_obj_id,
					     X_MSG_COUNT => l_msg_count,
					     X_MSG_DATA  =>l_msg_data,
					     X_RETURN_STATUS => l_return_status);


  END IF;


return 'SUCCESS';

EXCEPTION

   WHEN OTHERS THEN

      WF_CORE.CONTEXT('AMS_Act_List_PVT', 'INVOKE_TARGET_GROUP_LOCK', p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');

END INVOKE_TARGET_GROUP_LOCK;


-------------------------------------------------------------------------------------------------
--------------------------Procedure to INVOKE TARGETGROUP LOCK Ends here-------------------------
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
--------------------------Procedure to UPDATE LIST STATUS TO LOCKED Begins here------------------
-------------------------------------------------------------------------------------------------

--===============================================================================================
-- Procedure
--   UPDATE_LIST_STATUS_TO_LOCKED
--
-- PURPOSE
--    This api is called to Lock the Traget Group when the Schedule is in ACTIVE Status
--
-- ALGORITHM
--    a) Take as input type and id e.g. CSCH and schedule id
--    b) It will query AMS_LIST_HEADERS_ALL to check if target group exists for object type and id
--    c) Will do nothing (i.e. will return success) if target group does not exist (since Target Groups are relevant only for certain type of schedules)
--    d) If Target Group is already in LOCKED status do nothing, return;
--    e) If Target Group exists will update the user status id and status code of TG to LOCKED.
--    f) User_Status_Code and User_Status_Id are passed  to make it more generic. So we can change the Target Group status as per the requirement and not only to LOCKED status.
--
--  Any error in any of the API callouts?
--   => a) Set RETURN STATUS to E
--
-- OPEN ISSUES
--   1.
--
-- HISTORY
--    19-Apr-2005  ndadwal
--===============================================================================================
PROCEDURE UPDATE_LIST_STATUS_TO_LOCKED
(
    P_OBJECT_TYPE    IN  VARCHAR2,
    P_OBJ_ID         IN  NUMBER,
    X_MSG_COUNT      OUT NOCOPY NUMBER,
    X_MSG_DATA       OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS  OUT NOCOPY VARCHAR2  )
IS
BEGIN

-- INITIALIZE RETURN STATUS TO SUCCESS
X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_Utility_PVT.debug_message('****FUNCTION: UPDATE_LIST_STATUS_TO_LOCKED start****');

 END IF;

UPDATE AMS_LIST_HEADERS_ALL
SET    STATUS_CODE                  = 'LOCKED',
USER_STATUS_ID                      = (select user_status_id from ams_user_statuses_vl where system_status_type ='AMS_LIST_STATUS' and system_status_code ='LOCKED' and default_flag ='Y' ),
STATUS_DATE                         = SYSDATE,
LAST_UPDATE_DATE                    = SYSDATE
WHERE  LIST_USED_BY_ID              = P_OBJ_ID
AND  ARC_LIST_USED_BY               = P_OBJECT_TYPE
AND  LIST_TYPE                      = 'TARGET';


 IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_Utility_PVT.debug_message('TARGET GROUP LOCKED while executing procedure UPDATE_LIST_STATUS_TO_LOCKED');
 END IF;


EXCEPTION


WHEN FND_API.G_EXC_ERROR THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
	AMS_Utility_PVT.debug_message('Exception while executing procedure UPDATE_LIST_STATUS_TO_LOCKED'||' '||sqlerrm||' '||sqlcode);
     END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
	AMS_Utility_PVT.debug_message('UNEXPECTED_ERROR while executing procedure UPDATE_LIST_STATUS_TO_LOCKED'||'  '||sqlerrm||' '||sqlcode);
     END IF;


WHEN OTHERS THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
	AMS_Utility_PVT.debug_message('Other Error while executing procedure UPDATE_LIST_STATUS_TO_LOCKED'||'  '||sqlerrm||' '||sqlcode);
     END IF;

END UPDATE_LIST_STATUS_TO_LOCKED;

-------------------------------------------------------------------------------------------------
--------------------------Procedure to UPDATE LIST STATUS TO LOCKED Ends here--------------------
-------------------------------------------------------------------------------------------------


END AMS_Act_List_PVT;

/

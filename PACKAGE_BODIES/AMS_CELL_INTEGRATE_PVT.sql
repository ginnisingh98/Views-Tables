--------------------------------------------------------
--  DDL for Package Body AMS_CELL_INTEGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CELL_INTEGRATE_PVT" AS
/* $Header: amsvceib.pls 115.6 2002/11/22 19:26:32 jieli ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_CELL_INTEGRATE_PVT';
---------------------------------------------------------------------
-- PROCEDURE
--    create_segment_list
-- PURPOSE
--    This procedure will create a list header which will include the
--    segment id.
--
-- HISTORY
--    09/06/01  yxliu  Created.
--    04/03/02  yxliu  check if sql is empty before call list generation
--                     API to avoid endless loop
---------------------------------------------------------------------

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_segment_list
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_owner_user_id          IN    NUMBER,
  p_cell_id                IN    NUMBER,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2,
  x_list_header_id         OUT NOCOPY   NUMBER,
  x_list_source_type       OUT NOCOPY   VARCHAR2,
  p_list_name              in    VARCHAR2    --DEFAULT NULL
)
is
   l_list_header_rec   AMS_ListHeader_PVT.list_header_rec_type;
   l_init_msg_list     VARCHAR2(2000) := FND_API.G_FALSE;
   l_api_version       NUMBER         := 1.0;
   l_api_name          CONSTANT VARCHAR2(30) := 'Create_segment_List';
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

   CURSOR c_chk_name IS
   SELECT  'x'
     FROM ams_list_headers_vl
    WHERE list_name = p_list_name;

   CURSOR c_get_cell_name IS
   SELECT cell_name
     FROM ams_cells_vl
    WHERE cell_id = p_cell_id;

   l_source_type varchar2(100);
   l_var  varchar2(1);

BEGIN

   --------------------- get new list name -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name||': get list name');
   END IF;
   OPEN c_get_cell_name ;
   FETCH c_get_cell_name into l_cell_list_name;
   CLOSE c_get_cell_name;

   IF p_list_name IS NOT NULL THEN
      OPEN c_chk_name ;
      FETCH c_chk_name INTO l_var   ;
      CLOSE c_chk_name ;
   ELSE
      l_var := 'x';
   END IF;

   IF l_var IS NOT NULL THEN
      SELECT l_cell_list_name|| ' -:'|| to_char(sysdate,'DD-MON-YY HH:MM:SS')
        INTO l_cell_list_name
        FROM ams_cells_vl
       WHERE cell_id = p_cell_id;
   ELSE
      l_cell_list_name := p_list_name ;
   END IF;

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
   IF (AMS_DEBUG_HIGH_ON) THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW',
                          'AMS_ListGeneration_PKG.create_segemnt_list: Start',
                          TRUE);
      FND_MSG_PUB.Add;
   END IF;

   --------------------- find source type -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_api_name ||': get sql string for cell');
   END IF;
   AMS_CELL_PVT.get_single_sql(
      p_api_version        => p_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      p_cell_id            => p_cell_id,
      x_sql_string         => l_sql_string
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF l_sql_string IS NULL OR
      l_sql_string = ''
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': empty sql string');
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSE
      --l_sql_string := UPPER(l_sql_string);
      --dbms_output.put_line('sql_string: ' || l_sql_string);

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message(l_api_name ||': put sql string into table');

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



      AMS_Utility_PVT.debug_message(l_api_name||': validate sql string');

      END IF;
      l_found := 'N';
      AMS_ListGeneration_PKG.validate_sql_string(
                      p_sql_string    => l_sql_string_tbl ,
                      p_search_string => 'FROM',
                      p_comma_valid   => 'N',
                      x_found         => l_found,
                      x_position      => l_from_position,
                      x_counter       => l_from_counter) ;

      IF l_found = 'N' THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_FROM_NOT_FOUND');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message(l_api_name||': get master type');

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

      IF l_found = 'N' THEN
         FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_MASTER_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': master_type = '||l_master_type);
      END IF;
      --dbms_output.put_line('master_type :' || l_master_type);
      x_list_source_type := l_master_type;

      -------------------- create_listheader -----------------
      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Perform the database operation
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': create_listheader');
      END IF;

      -- ams_listheader_pvt.init_listheader_rec(l_list_header_rec);
      l_list_header_rec.list_name :=  l_cell_list_name  ;
      l_list_header_rec.list_type :=  'STANDARD';
      l_list_header_rec.list_source_type :=  l_master_type;
      l_list_header_rec.owner_user_id :=  p_owner_user_id;

      AMS_ListHeader_PVT.Create_Listheader (
                        p_api_version             => 1.0,
                        p_init_msg_list           => l_init_msg_list,
                        p_commit                  => p_commit,
                        p_validation_level        => p_validation_level ,
                        x_return_status           => x_return_status,
                        x_msg_count               => x_msg_count,
                        x_msg_data                => x_msg_data,
                        p_listheader_rec          => l_list_header_rec,
                        x_listheader_id           => x_list_header_id
                        );

      IF x_return_status <> FND_API.g_ret_sts_success  THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||'listheader_id = '||x_list_header_id);
      END IF;

      -------------------- Create_ListAction ----------------
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_api_name ||': create_listAction');
      END IF;

      l_action_rec.arc_action_used_by := 'LIST';
      l_action_rec.action_used_by_id := x_list_header_id;
      l_action_rec.order_number := 1 ;
      l_action_rec.list_action_type := 'INCLUDE';
      l_action_rec.arc_incl_object_from := 'CELL';
      l_action_rec.incl_object_id := p_cell_id;
      l_action_rec.rank := 1;

      AMS_ListAction_PVT.Create_ListAction
                      ( p_api_version           => 1.0,
                        p_init_msg_list         => l_init_msg_list,
                        p_commit                => p_commit,
                        p_validation_level      => p_validation_level,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_action_rec            => l_action_rec,
                        x_action_id             => l_action_id
                       ) ;
      FND_MESSAGE.set_name('AMS','after list action->'|| l_action_id|| '<-');
      FND_MSG_PUB.Add;

      IF x_return_status <> FND_API.g_ret_sts_success  THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Standard check of p_commit.

      IF FND_API.To_Boolean(p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Success Message
      -- MMSG
      --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      --THEN
      FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
      FND_MESSAGE.Set_Token('ROW', 'AMS_CELL_PVT.create_segment_list: ');
      FND_MSG_PUB.Add;
      --END IF;


      --IF (AMS_DEBUG_HIGH_ON) THEN
      --THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', 'AMS_ListGeneration_PKG.create_segment_list: END');
      FND_MSG_PUB.Add;
      --END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
      FND_MSG_PUB.Add;
      -- Check if reset of the status is required
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);

   WHEN OTHERS THEN
      FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW', sqlerrm||' '||sqlcode);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
END CREATE_Segment_LIST;

END AMS_CEll_INTEGRATE_PVT;

/

--------------------------------------------------------
--  DDL for Package Body AMS_LISTGENERATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTGENERATION_PUB" as
/* $Header: amsplgnb.pls 115.8 2004/04/26 23:56:42 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ListGeneration_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ListGeneration_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsplgnb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Generate_List
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                     IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id             IN     NUMBER   ,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2

) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Generate_List';
	l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_list_header_id               NUMBER  := P_list_header_id;

  BEGIN

   SAVEPOINT Generate_List_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTGENERATION_PKG.Generate_List(
   p_api_version           => p_api_version,
   p_init_msg_list         => FND_API.g_false,
   p_commit                => FND_API.g_false,
   p_validation_level      => FND_API.g_valid_level_full,

   x_return_status         => l_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data,

   p_list_header_id              => l_list_header_id
  );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Generate_List_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Generate_List_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Generate_List_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
  END Generate_List;

PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  )

  IS         l_api_name            CONSTANT VARCHAR2(30)  := 'Generate_List';
	l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures

  BEGIN

   SAVEPOINT create_list_from_query_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTGENERATION_PKG.create_list_from_query(
   p_api_version           => p_api_version,
   p_init_msg_list         => FND_API.g_false,
   p_commit                => FND_API.g_false,
   p_validation_level      => FND_API.g_valid_level_full,

  p_list_name              =>  p_list_name,
  p_list_type              =>  p_list_type,
  p_owner_user_id          =>  p_owner_user_id,
  p_list_header_id          =>  p_list_header_id,
  p_sql_string_tbl         =>  p_sql_string_tbl,
  p_primary_key            =>  p_primary_key,
  p_source_object_name     =>  p_source_object_name,
  p_master_type            =>  p_master_type,
   x_return_status         => l_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data

  );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
  END create_list_from_query;




PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  p_query_param            in    AMS_List_Query_PVT.sql_string_tbl      ,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  )

  IS         l_api_name            CONSTANT VARCHAR2(30)  := 'Generate_List';
	l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures

  BEGIN

   SAVEPOINT create_list_from_query_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTGENERATION_PKG.create_list_from_query(
   p_api_version           => p_api_version,
   p_init_msg_list         => FND_API.g_false,
   p_commit                => FND_API.g_false,
   p_validation_level      => FND_API.g_valid_level_full,

  p_list_name              =>  p_list_name,
  p_list_type              =>  p_list_type,
  p_owner_user_id          =>  p_owner_user_id,
  p_list_header_id          =>  p_list_header_id,
  p_sql_string_tbl         =>  p_sql_string_tbl,
  p_primary_key            =>  p_primary_key,
  p_source_object_name     =>  p_source_object_name,
  p_master_type            =>  p_master_type,
  p_query_param            => p_query_param            ,

   x_return_status         => l_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data

  );


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_list_from_query_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
  END create_list_from_query;





END AMS_ListGeneration_PUB;

/

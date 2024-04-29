--------------------------------------------------------
--  DDL for Package Body AMS_LISTHEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTHEADER_PUB" AS
/* $Header: amsplshb.pls 115.18 2002/11/22 08:54:16 jieli ship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_LISTHEADER_PUB';

-- Start of Comments
--
-- NAME
--   Create_ListHeader
--
-- PURPOSE
--   This procedure creates a list header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_ListHeader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_rec           IN     AMS_LISTHEADER_PVT.list_header_rec_type,
  x_listheader_id            OUT NOCOPY    NUMBER
)  IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_return_status       VARCHAR2(1);
  l_listheader_rec      AMS_LISTHEADER_PVT.list_header_rec_type := p_listheader_rec;

BEGIN

   SAVEPOINT create_listheader_pub;
   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --call private API procedure.
   AMS_LISTHEADER_PVT.Create_ListHeader
   ( p_api_version         => p_api_version,
     p_init_msg_list       => FND_API.G_FALSE,
     p_commit              => FND_API.G_FALSE,
     p_validation_level    => FND_API.g_valid_level_full,
     x_return_status       => l_return_status,
     x_msg_count           => x_msg_count,
     x_msg_data            => x_msg_data,
     p_listheader_rec      => l_listheader_rec,
     x_listheader_id       => x_listheader_id);


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
      ROLLBACK TO create_listheader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_listheader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_listheader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
End Create_ListHeader;




-- Start of Comments
--
-- NAME
--   Update_listheader
--
-- PURPOSE
--   This procedure is to update a List Header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments

PROCEDURE Update_ListHeader
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                 IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  p_listheader_rec         IN     AMS_LISTHEADER_PVT.list_header_rec_type
 ) IS

  l_api_name             CONSTANT VARCHAR2(30)  := 'Update_ListHeader';
  l_api_version          CONSTANT NUMBER        := 1.0;

  -- Status Local Variables
  l_return_status        VARCHAR2(1);  -- Return value from procedures
  l_listheader_rec       AMS_LISTHEADER_PVT.list_header_rec_type := p_listheader_rec;

Begin

  SAVEPOINT update_listheader_pub;
  -- initialize the message list;
  -- won't do it again when calling private API
  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  AMS_LISTHEADER_PVT.Update_ListHeader
  ( p_api_version      =>  p_api_version ,
    p_init_msg_list    =>  FND_API.G_FALSE,
    p_commit           =>  FND_API.G_FALSE,
    p_validation_level =>  FND_API.G_VALID_LEVEL_FULL,
    x_return_status    =>  l_return_status,
    x_msg_count        =>  x_msg_count,
    x_msg_data         =>  x_msg_data,
    p_listheader_rec   =>  l_listheader_rec );


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
      ROLLBACK TO  update_listheader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get
      (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO  update_listheader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO  update_listheader_pub;
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
End Update_ListHeader;

-- Start of Comments
--
-- NAME
--   Delete_listheader
--
-- PURPOSE
--   This procedure deletes a list header record that satisfy caller needs
--
-- NOTES
-- Deletes from The following tables Ams_List_Src_Type_Usages,
--                                   Ams_List_Rule_Usages,
--                                   Ams_List_Entries,
--                                   Ams_List_Select_Actions
--                                   Ams_List_Headers_All.
--
-- HISTORY
--   05/12/1999        tdonohoe            created
-- End of Comments
PROCEDURE Delete_ListHeader
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                 IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  p_listheader_id          IN     number) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Delete_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;

  -- Status Local Variables
  l_return_status                VARCHAR2(1);  -- Return value from procedures
  l_listheader_id                NUMBER   := p_listheader_id;
  l_return_val                   VARCHAR2(1);

BEGIN

  SAVEPOINT delete_listheader_pub;

     -- initialize the message list;
     -- won't do it again when calling private API
     IF FND_API.to_boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
     END IF;

      AMS_LISTHEADER_PVT.Delete_ListHeader
      ( p_api_version       => p_api_version,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit            => FND_API.G_FALSE,
        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data ,
        p_listheader_id     => l_listheader_id);

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
         p_data    => x_msg_data);


EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_listheader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_listheader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_listheader_pub;
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

END delete_listheader;

-- Start of Comments
--
-- NAME
--   Lock_listheader
--
-- PURPOSE
--   This procedure is to lock a list header record that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   05/13/1999        tdonohoe            created
-- End of Comments


PROCEDURE Lock_ListHeader
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_listheader_id            IN     NUMBER,
  p_object_version           IN     NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

  l_return_status                VARCHAR2(1);
  l_listheader_id                NUMBER := p_listheader_id;
  l_object_version               NUMBER := p_object_version;


Begin

   SAVEPOINT lock_listheader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

    AMS_LISTHEADER_PVT.Lock_ListHeader
    ( p_api_version       => p_api_version,
      p_init_msg_list     => FND_API.G_FALSE,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count ,
      x_msg_data          => x_msg_data,
      p_listheader_id     => l_listheader_id ,
      p_object_version    => l_object_version);

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO lock_ListHeader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_ListHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_ListHeader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
End Lock_ListHeader;

-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListHeader
--
-- PURPOSE
--    Validate a List Header Record.
--
-- PARAMETERS
--    p_listheader_rec: the list header record to be validated
--
-- NOTES
--    1. p_listheader_rec_rec should be the complete list header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments


PROCEDURE Validate_ListHeader
( p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level       IN     NUMBER      := FND_API.g_valid_level_full,
  x_return_status          OUT NOCOPY    VARCHAR2,
  x_msg_count              OUT NOCOPY    NUMBER,
  x_msg_data               OUT NOCOPY    VARCHAR2,
  p_listheader_rec         IN     ams_listheader_pvt.list_header_rec_type
)  IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_ListHeader';
  l_api_version         CONSTANT NUMBER        := 1.0;

     -- Status Local Variables
  l_return_status      VARCHAR2(1);  -- Return value from procedures
  l_listheader_rec     ams_listheader_pvt.list_header_rec_type := p_listheader_rec;
  l_listheader_id      number;
BEGIN

  SAVEPOINT validate_listheader_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTHEADER_PVT.Validate_ListHeader
   ( p_api_version        => p_api_version,
        p_init_msg_list      => FND_API.G_FALSE,
        p_validation_level   => FND_API.g_valid_level_full,
        x_return_status      => l_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_listheader_rec     => l_listheader_rec);

   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO validate_listheader_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_listheader_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_listheader_pub;
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

END validate_listheader;

PROCEDURE Copy_List
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_source_listheader_id     IN     NUMBER,
  p_listheader_rec           IN     AMS_LISTHEADER_PVT.list_header_rec_type,
  p_copy_select_actions      IN     VARCHAR2  := 'Y',
  p_copy_list_queries        IN     VARCHAR2  := 'Y',
  p_copy_list_entries        IN     VARCHAR2  := 'Y',

  x_listheader_id            OUT NOCOPY    NUMBER
)IS

  l_api_name            CONSTANT VARCHAR2(30)  := 'Copy_List';
  l_api_version         CONSTANT NUMBER        := 1.0;
  l_return_status       VARCHAR2(1);
  l_listheader_rec      AMS_LISTHEADER_PVT.list_header_rec_type := p_listheader_rec;

BEGIN

   SAVEPOINT copy_list_pub;
   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --call private API procedure.
   AMS_LISTHEADER_PVT.Copy_List
   ( p_api_version         => p_api_version,
     p_init_msg_list       => FND_API.G_FALSE,
     p_commit              => FND_API.G_FALSE,
     p_validation_level    => FND_API.g_valid_level_full,
     x_return_status       => l_return_status,
     x_msg_count           => x_msg_count,
     x_msg_data            => x_msg_data,
     p_source_listheader_id =>p_source_listheader_id,
     p_listheader_rec      => l_listheader_rec,
     p_copy_select_actions =>p_copy_select_actions,
     p_copy_list_queries  =>p_copy_list_queries,
     p_copy_list_entries =>p_copy_list_entries,
     x_listheader_id       => x_listheader_id);


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
      ROLLBACK TO copy_list_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO copy_list_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO copy_list_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
End copy_list;

END ;--package body

/

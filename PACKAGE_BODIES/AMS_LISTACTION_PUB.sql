--------------------------------------------------------
--  DDL for Package Body AMS_LISTACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTACTION_PUB" AS
/* $Header: amsplsab.pls 120.1 2005/06/16 05:04:57 appldev  $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_LISTACTION_PUB';
---------------------------------------------------------------------
-- PROCEDURE
--    Create_ListAction
--
-- PURPOSE
--    Create a new List Select Action.
--
-- PARAMETERS
--    p_action_rec: the new record to be inserted
--    x_action_id: return the campaign_id of the new campaign
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If action_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If action_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     AMS_LISTACTION_PVT.action_rec_type,
  x_action_id                            OUT NOCOPY    NUMBER
) IS

      l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListAction';
      l_api_version         CONSTANT NUMBER        := 1.0;

      l_return_status                VARCHAR2(1);  -- Return value from procedures
      l_action_rec                   AMS_LISTACTION_PVT.action_rec_type := p_action_rec;
      l_action_id                    NUMBER;
Begin


   SAVEPOINT create_listaction_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

    AMS_LISTACTION_PVT.Create_ListAction
    ( p_api_version      => p_api_version,
      p_init_msg_list    => FND_API.G_FALSE,
      p_commit           => FND_API.G_FALSE,
      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
      x_return_status    => l_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,

      p_action_rec       => l_action_rec,
      x_action_id        => l_action_id);


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
      ROLLBACK TO create_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_ListAction_pub;
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

End Create_ListAction;

-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Update_ListAction
--
-- PURPOSE
--    Update a List Action.
--
-- PARAMETERS
--    p_action_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Update_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     AMS_LISTACTION_PVT.action_rec_type
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Update_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_action_rec                   AMS_LISTACTION_PVT.action_rec_type := p_action_rec;

Begin

   SAVEPOINT update_listaction_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTACTION_PVT.Update_ListAction
   ( p_api_version      => p_api_version,
     p_init_msg_list    => FND_API.G_FALSE,
     p_commit           => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     x_return_status    => l_return_status,
     x_msg_count        => x_msg_count,
     x_msg_data         => x_msg_data ,

     p_action_rec       => l_action_rec);

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
      ROLLBACK TO update_listaction_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_listaction_pub;
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


End Update_ListAction;

-- Start of Comments
--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListAction
--
-- PURPOSE
--    Delete a List Action.
--
-- PARAMETERS
--    p_action_id:      the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Delete_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                               IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                           IN     NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Delete_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_action_id                    NUMBER :=p_action_id;

  BEGIN

   SAVEPOINT Delete_ListAction_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   Delete_ListAction
   ( p_api_version      => p_api_version,
     p_init_msg_list    => FND_API.G_FALSE,
     p_commit           => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,

     x_return_status    => l_return_status,
     x_msg_count        => x_msg_count,
     x_msg_data         => x_msg_data,

     p_action_id        => l_action_id);


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
      ROLLBACK TO Delete_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_campaign_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Delete_ListAction_pub;
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
  END Delete_ListAction;


-- Start of Comments
-------------------------------------------------------------------
-- PROCEDURE
--     Lock_ListAction
--
-- PURPOSE
--    Lock a List Action.
--
-- PARAMETERS
--    p_action_id: the action_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
-- End Of Comments
PROCEDURE Lock_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,

  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_id                            IN     NUMBER,
  p_object_version                       IN     NUMBER
) IS


        l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_action_id                    number := p_action_id;
        l_object_version_number        number := p_object_version;

Begin

   SAVEPOINT Lock_ListAction_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTACTION_PVT.Lock_ListAction
   ( p_api_version       => p_api_version,
     p_init_msg_list     => FND_API.G_FALSE,
     p_validation_level  => FND_API.G_VALID_LEVEL_FULL,

     x_return_status     => l_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,

     p_action_id        => l_action_id,
     p_object_version    => l_object_version_number  );

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
      ROLLBACK TO Lock_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Lock_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Lock_ListAction_pub;
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
End Lock_ListAction;

-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListAction
--
-- PURPOSE
--    Validate a List Action.
--
-- PARAMETERS
--    p_action_rec: the list action record to be validated
--
-- NOTES
--    1. p_action_rec should be the complete list action record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
-- End Of Comments
PROCEDURE Validate_ListAction
( p_api_version                          IN     NUMBER,
  p_init_msg_list                        IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level                     IN     NUMBER
                                                            := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                        OUT NOCOPY    VARCHAR2,
  x_msg_count                            OUT NOCOPY    NUMBER,
  x_msg_data                             OUT NOCOPY    VARCHAR2,

  p_action_rec                           IN     AMS_LISTACTION_PVT.action_rec_type
) IS

	    l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_ListAction';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_action_rec                   AMS_LISTACTION_PVT.action_rec_type :=  p_action_rec;

BEGIN

   SAVEPOINT Validate_ListAction_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   Validate_ListAction
   ( p_api_version      => p_api_version,
     p_init_msg_list    => FND_API.G_FALSE,
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     x_return_status    => l_return_status,
     x_msg_count        => x_msg_count,
     x_msg_data         => x_msg_data ,

     p_action_rec       => l_action_rec);

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
      ROLLBACK TO Validate_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Validate_ListAction_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO Validate_ListAction_pub;
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
End Validate_ListAction;

END;--package body

/

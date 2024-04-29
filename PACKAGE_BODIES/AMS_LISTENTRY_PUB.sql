--------------------------------------------------------
--  DDL for Package Body AMS_LISTENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTENTRY_PUB" AS
/* $Header: amsplseb.pls 120.1 2006/01/05 05:25:59 bmuthukr noship $ */


g_pkg_name  CONSTANT VARCHAR2(30):='AMS_ListEntry_PUB';

---------------------------------------------------------------------
-- PROCEDURE
--    create_listentry
--
-- PURPOSE
--    Create a new list entry.
--
-- PARAMETERS
--    p_entry_rec: the new record to be inserted
--    x_entry_id: return the list_entry_id of the new list entry
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If list_entry_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If list_entry_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec          IN  AMS_LISTENTRY_PVT.entry_rec_type,
   x_entry_id           OUT NOCOPY NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListEntry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status               VARCHAR2(1);  -- Return value from procedures
        l_listentry_id               NUMBER;
        l_listentry_rec               AMS_LISTENTRY_PVT.entry_rec_type := p_entry_rec;
Begin

   SAVEPOINT create_listentry_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTENTRY_PVT.create_listentry(
   p_api_version      =>  p_api_version,
   p_init_msg_list    =>  FND_API.g_false,
   p_commit           =>  FND_API.g_false,
   --p_validation_level =>  FND_API.g_valid_level_full,-- bug 4761988
   p_validation_level => p_validation_level,
   x_return_status    =>  l_return_status,
   x_msg_count        =>  x_msg_count,
   x_msg_data         =>  x_msg_data,

   p_entry_rec        =>  l_listentry_rec,
   x_entry_id         =>  l_listentry_id);


   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_entry_id           := l_listentry_id;

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
      ROLLBACK TO create_listentry_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_listentry_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO create_listentry_pub;
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
End  create_listentry;

---------------------------------------------------------------------
-- PROCEDURE
--    update_listentry
--
-- PURPOSE
--    Update a listentry.
--
-- PARAMETERS
--    p_entry_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec          IN  AMS_LISTENTRY_PVT.entry_rec_type
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Update_ListEntry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_listentry_rec                AMS_LISTENTRY_PVT.entry_rec_type := p_entry_rec;


  BEGIN

   SAVEPOINT update_listentry_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTENTRY_PVT.update_listentry
   ( p_api_version      => p_api_version,
     p_init_msg_list    => FND_API.g_false,
     p_commit           => FND_API.g_false,
     p_validation_level => FND_API.g_valid_level_full,
     x_return_status    => l_return_status,
     x_msg_count        => x_msg_count,
     x_msg_data         => x_msg_data,
     p_entry_rec        => l_listentry_rec);


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
      ROLLBACK TO update_listentry_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_listentry_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO update_listentry_pub;
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


  END update_listentry;

  --------------------------------------------------------------------
-- PROCEDURE
--    delete_listentry
--
-- PURPOSE
--    Delete a listentry.
--
-- PARAMETERS
--    p_entry_id: the listentry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_listentry(
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
   p_commit                  IN  VARCHAR2 := FND_API.g_false,
   p_validation_level        IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,

   p_entry_id                IN  NUMBER,
   p_object_version_number   IN  NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Delete_ListEntry';
	l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_entry_id                     NUMBER  := P_ENTRY_ID;
        l_object_version_number        NUMBER  := p_object_version_number;

  BEGIN

   SAVEPOINT delete_listentry_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   AMS_LISTENTRY_PVT.delete_listentry(
   p_api_version           => p_api_version,
   p_init_msg_list         => FND_API.g_false,
   p_commit                => FND_API.g_false,
   p_validation_level      => FND_API.g_valid_level_full,

   x_return_status         => l_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data,

   p_entry_id              => l_entry_id,
   p_object_version_number => l_object_version_number);


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
      ROLLBACK TO delete_listentry_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_listentry_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO delete_listentry_pub;
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
  END delete_listentry;



  -------------------------------------------------------------------
-- PROCEDURE
--    lock_listentry
--
-- PURPOSE
--    Lock a List Entry.
--
-- PARAMETERS
--    p_entry_id: the list_entry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_id           IN  NUMBER,
   p_object_version    IN  NUMBER
) IS

       l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListEntry';
       l_api_version         CONSTANT NUMBER        := 1.0;
       l_return_status       VARCHAR2(1);
       l_entry_id            NUMBER := P_ENTRY_ID;
       l_object_version      NUMBER := P_OBJECT_VERSION;

  BEGIN

   SAVEPOINT lock_listentry_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   lock_listentry
   ( p_api_version       => p_api_version ,
     p_init_msg_list     => FND_API.g_false,
     p_validation_level  => FND_API.g_valid_level_full,

     x_return_status     => l_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,

     p_entry_id          => l_entry_id,
     p_object_version    => l_object_version );


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
      ROLLBACK TO lock_listentry_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO lock_listentry_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO lock_listentry_pub;
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
  END lock_listentry;

  ---------------------------------------------------------------------
-- PROCEDURE
--    validate_listentry
--
-- PURPOSE
--    Validate a listentry record.
--
-- PARAMETERS
--    p_entry_rec: the listentry record to be validated
--
-- NOTES
--    1. p_entry_rec should be the complete list entry  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec         IN  AMS_LISTENTRY_PVT.entry_rec_type
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Entry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_entry_rec                    AMS_LISTENTRY_PVT.entry_rec_type := p_entry_rec;

BEGIN

   SAVEPOINT validate_listentry_pub;

   -- initialize the message list;
   -- won't do it again when calling private API
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


   AMS_LISTENTRY_PVT.validate_listentry
   ( p_api_version       => p_api_version,
     p_init_msg_list     => FND_API.g_false,
     p_validation_level  => FND_API.g_valid_level_full,

     x_return_status     => l_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data,

     p_entry_rec         => l_entry_rec);

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
      ROLLBACK TO validate_listentry_pub;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO validate_listentry_pub;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN
      ROLLBACK TO validate_listentry_pub;
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
END validate_listentry;


---------------------------------------------------------------------
-- PROCEDURE
--    init_entry_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_entry_rec(x_entry_rec OUT NOCOPY  AMS_LISTENTRY_PVT.entry_rec_type)
IS
        l_api_name            CONSTANT VARCHAR2(30)  := 'Init_Entry_Rec';
        l_api_version         CONSTANT NUMBER        := 1.0;
BEGIN


AMS_LISTENTRY_PVT.init_entry_rec(x_entry_rec =>  x_entry_rec);

END init_entry_rec;

END;

/

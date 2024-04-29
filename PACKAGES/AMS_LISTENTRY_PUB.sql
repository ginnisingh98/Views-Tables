--------------------------------------------------------
--  DDL for Package AMS_LISTENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTENTRY_PUB" AUTHID CURRENT_USER AS
/* $Header: amsplses.pls 115.10 2003/01/28 00:01:23 jieli ship $ */
---------------------------------------------------------------------
-- PROCEDURE
--    create_listentry
--
-- PURPOSE
--    Create a new list entry.
--
-- PARAMETERS
--    p_entry_rec: the new record to be inserted
--    x_entry_id: return the list_entry_id of the new campaign
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
);
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
);

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
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2 := FND_API.g_false,
   p_commit                 IN  VARCHAR2 := FND_API.g_false,
   p_validation_level       IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,

   p_entry_id               IN  NUMBER,
   p_object_version_number  IN  NUMBER
);

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
);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_listentry
--
-- PURPOSE
--    Validate a listentry record.
--
-- PARAMETERS
--    p_camp_rec: the listentry record to be validated
--
-- NOTES
--    1. p_entry_rec should be the complete campaign record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec          IN  AMS_LISTENTRY_PVT.entry_rec_type
);



---------------------------------------------------------------------
-- PROCEDURE
--    init_entry_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_entry_rec(
   x_entry_rec         OUT NOCOPY  AMS_LISTENTRY_PVT.entry_rec_type
);


END; -- Package spec

 

/

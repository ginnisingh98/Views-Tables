--------------------------------------------------------
--  DDL for Package AMS_DELIVKITITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVKITITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: amspkits.pls 115.3 2002/11/14 00:21:21 musman noship $ */

---------------------------------------------------------------------
-- PROCEDURE
--    create_DelivKitItem
--
-- PURPOSE
--    Create a Deliverable Kit Item.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the new record to be inserted
--    x_deliv_kit_item_id: return the PK of the created Deliverable Kit Item
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If DelivKitItem_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If DelivKitItem_id is not passed in, generate a unique one from
--       the sequence.
---------------------------------------------------------------------
PROCEDURE create_DelivKitItem(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_rec          IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type,
   x_deliv_kit_item_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_DelivKitItem
--
-- PURPOSE
--    Delete a Deliverable Kit Item.
--
-- PARAMETERS
--    p_deliv_kit_item_id : the DelivKitItem_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--
--------------------------------------------------------------------
PROCEDURE delete_DelivKitItem(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_id          IN  NUMBER,
   p_object_version_number    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_DelivKitItem
--
-- PURPOSE
--    Lock a Deliverable Kit Item.
--
-- PARAMETERS
--    p_deliv_kit_item_id: the DelivKitItem_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_DelivKitItem(
   p_api_version_number      IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_id           IN  NUMBER,
   p_object_version_number    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_DelivKitItem
--
-- PURPOSE
--    Update a Deliverable Kit Item.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_DelivKitItem(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_rec          IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_DelivKitItem
--
-- PURPOSE
--    Validate a Deliverable Kit Item. record.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the DelivKitItem record to be validated
--
-- NOTES
--    1. p_deliv_kit_item_rec should be the complete DelivKitItem record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_DelivKitItem(
   p_api_version_number       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_rec          IN  AMS_DelivKitItem_PVT.deliv_kit_item_rec_type
);


END AMS_DelivKitItem_PUB;

 

/

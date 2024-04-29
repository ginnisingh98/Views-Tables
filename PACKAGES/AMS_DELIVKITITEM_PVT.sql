--------------------------------------------------------
--  DDL for Package AMS_DELIVKITITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVKITITEM_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdkis.pls 115.12 2002/11/14 00:21:34 musman ship $ */

TYPE deliv_kit_item_rec_type IS RECORD
(
  deliverable_kit_item_id	NUMBER,
  last_update_date		DATE,
  last_updated_by		NUMBER,
  creation_date			DATE,
  created_by			NUMBER,
  last_update_login		NUMBER,
  object_version_number		NUMBER,
  deliverable_kit_id		NUMBER,
  deliverable_kit_part_id	NUMBER,
  kit_part_included_from_kit_id	NUMBER,
  quantity			NUMBER,
  attribute_category		VARCHAR2(30),
  attribute1			VARCHAR2(150),
  attribute2			VARCHAR2(150),
  attribute3			VARCHAR2(150),
  attribute4			VARCHAR2(150),
  attribute5			VARCHAR2(150),
  attribute6			VARCHAR2(150),
  attribute7			VARCHAR2(150),
  attribute8			VARCHAR2(150),
  attribute9			VARCHAR2(150),
  attribute10			VARCHAR2(150),
  attribute11			VARCHAR2(150),
  attribute12			VARCHAR2(150),
  attribute13			VARCHAR2(150),
  attribute14			VARCHAR2(150),
  attribute15			VARCHAR2(150)
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_deliv_kit_item
--
-- PURPOSE
--    Create a new deliverable kit item.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the new record to be inserted
--    x_deliv_kit_item_id: return the deliverable_id of the new campaign
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If deliverable_kit_item_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If deliverable_kit_item_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--    7. Create a row in AMS_DELIV_KIT_ITEMS table and an attachmenmt will be inserted
--       to AMS_ACT_ATTACHMENTS table if AMS_DELIV_KIT_ITEMS.kit_part_included_from_kit_id
--       is not null (Open issue 10/12/99 khung)
---------------------------------------------------------------------

PROCEDURE create_deliv_kit_item
(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
  p_commit		IN	VARCHAR2 := FND_API.g_false,
  p_validation_level	IN	NUMBER   := FND_API.g_valid_level_full,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count	 OUT NOCOPY NUMBER,
  x_msg_data	 OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_rec	IN	deliv_kit_item_rec_type,
  x_deliv_kit_item_id OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_deliv_kit_item
--
-- PURPOSE
--    Delete a deliverable kit item.
--
-- PARAMETERS
--    p_deliv_kit_item_id: the deliverable_kit_item_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Delete a row in AMS_DELIV_KIT_ITEMS table and delete an attachmenmt to
--       AMS_ACT_ATTACHMENTS table if AMS_DELIV_KIT_ITEMS.kit_part_included_from_kit_id
--       is not null (Open issue 10/12/99 khung)
--------------------------------------------------------------------

PROCEDURE delete_deliv_kit_item
(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
  p_commit		IN	VARCHAR2 := FND_API.g_false,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count	 OUT NOCOPY NUMBER,
  x_msg_data	 OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_id	IN	NUMBER,
  p_object_version	IN	NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_deliv_kit_item
--
-- PURPOSE
--    Update a deliverable kit item.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------

PROCEDURE update_deliv_kit_item
(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
  p_commit		IN	VARCHAR2 := FND_API.g_false,
  p_validation_level	IN	NUMBER   := FND_API.g_valid_level_full,

  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count	 OUT NOCOPY NUMBER,
  x_msg_data	 OUT NOCOPY VARCHAR2,

  p_deliv_kit_item_rec	IN	deliv_kit_item_rec_type
);

-------------------------------------------------------------------
-- PROCEDURE
--    lock_deliv_kit_item
--
-- PURPOSE
--    Lock a deliverable kit item.
--
-- PARAMETERS
--    p_deliverable_kit_item_id: the deliverable_kit_item_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE lock_deliv_kit_item
(
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,

   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count	 OUT NOCOPY NUMBER,
   x_msg_data	 OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_id	IN	NUMBER,
   p_object_version	IN	NUMBER
);



---------------------------------------------------------------------
-- PROCEDURE
--    validate_deliv_kit_item
--
-- PURPOSE
--    Validate a deliverable kit item record.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the deliverable kit item record to be validated
--
-- NOTES
--    1. p_deliv_kit_item_rec should be the complete deliverable kit item
--       record. There should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------

PROCEDURE validate_deliv_kit_item
(
   p_api_version	IN  NUMBER,
   p_init_msg_list	IN  VARCHAR2  := FND_API.g_false,
   p_validation_level	IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count	 OUT NOCOPY NUMBER,
   x_msg_data	 OUT NOCOPY VARCHAR2,

   p_deliv_kit_item_rec	IN  deliv_kit_item_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_items
--
-- PURPOSE
--    Perform the item level checking including unique keys, required columns,
--    foreign keys, domain constraints.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_deliv_kit_item_items
(
   p_deliv_kit_item_rec	IN	deliv_kit_item_rec_type,
   p_validation_mode	IN	VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_deliv_kit_item_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the record to be validated; may contain
--       attributes as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------

PROCEDURE check_deliv_kit_item_record
(
   p_deliv_kit_item_rec	IN	deliv_kit_item_rec_type,
   p_complete_rec	IN	deliv_kit_item_rec_type := NULL,
   x_return_status OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    init_deliv_kit_item_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------

PROCEDURE init_deliv_kit_ite_rec
(
   x_deliv_kit_item_rec OUT NOCOPY deliv_kit_item_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_deliv_kit_item_rec
--
-- PURPOSE
--    For update_deliv_kit_items, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_deliv_kit_item_rec: the record which may contain attributes
--       as FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_deliv_kit_item_rec
(
   p_deliv_kit_item_rec	IN	deliv_kit_item_rec_type,
   x_complete_rec OUT NOCOPY deliv_kit_item_rec_type
);

END AMS_DelivKitItem_PVT;

 

/

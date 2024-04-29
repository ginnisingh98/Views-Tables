--------------------------------------------------------
--  DDL for Package AMS_ASSOCIATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ASSOCIATIONS_PVT" AUTHID CURRENT_USER AS
/*$Header: amsvasss.pls 115.12 2002/12/02 20:30:46 dbiswas ship $*/

TYPE association_rec_type IS RECORD(
 OBJECT_ASSOCIATION_ID                    NUMBER,
 LAST_UPDATE_DATE                         DATE,
 LAST_UPDATED_BY                          NUMBER,
 CREATION_DATE                            DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATE_LOGIN                        NUMBER,
 OBJECT_VERSION_NUMBER                    NUMBER,
 MASTER_OBJECT_TYPE                       VARCHAR2(30),
 MASTER_OBJECT_ID                         NUMBER,
 USING_OBJECT_TYPE                        VARCHAR2(30),
 USING_OBJECT_ID                          NUMBER,
 PRIMARY_FLAG                             VARCHAR2(1),
 USAGE_TYPE                               VARCHAR2(30),
 QUANTITY_NEEDED                          NUMBER,
 QUANTITY_NEEDED_BY_DATE                  DATE,
 COST_FROZEN_FLAG                         VARCHAR2(1),
 PCT_OF_COST_TO_CHARGE_USED_BY            NUMBER,
 MAX_COST_TO_CHARGE_USED_BY               NUMBER,
 MAX_COST_CURRENCY_CODE                   VARCHAR2(15),
 METRIC_CLASS                             VARCHAR2(30),
 FULFILL_ON_TYPE_CODE					  VARCHAR2(30),
 ATTRIBUTE_CATEGORY                       VARCHAR2(30),
 ATTRIBUTE1                               VARCHAR2(150),
 ATTRIBUTE2                               VARCHAR2(150),
 ATTRIBUTE3                               VARCHAR2(150),
 ATTRIBUTE4                               VARCHAR2(150),
 ATTRIBUTE5                               VARCHAR2(150),
 ATTRIBUTE6                               VARCHAR2(150),
 ATTRIBUTE7                               VARCHAR2(150),
 ATTRIBUTE8                               VARCHAR2(150),
 ATTRIBUTE9                               VARCHAR2(150),
 ATTRIBUTE10                              VARCHAR2(150),
 ATTRIBUTE11                              VARCHAR2(150),
 ATTRIBUTE12                              VARCHAR2(150),
 ATTRIBUTE13                              VARCHAR2(150),
 ATTRIBUTE14                              VARCHAR2(150),
 ATTRIBUTE15                              VARCHAR2(150),
 CONTENT_TYPE                             VARCHAR2(30),
 SEQUENCE_NO                              NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    create_association
--
-- PURPOSE
--    Create a new object association.
--
-- PARAMETERS
--    p_association_rec: the new record to be inserted
--    x_object_association_id: return the object_association_id of the new association
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If object_association_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If object_association_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE create_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_association_rec          IN  association_rec_type,
   x_object_association_id    OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_association
--
-- PURPOSE
--    Delete a association.
--
-- PARAMETERS
--    p_object_association_id: the object_association_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_object_association_id    IN  NUMBER,
   p_object_version    		IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_association
--
-- PURPOSE
--    Lock a association.
--
-- PARAMETERS
--    p_object_association_id: the object_association_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_object_association_id         IN  NUMBER,
   p_object_version    			IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_association
--
-- PURPOSE
--    Update a association.
--
-- PARAMETERS
--    p_association_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_association_rec   IN  association_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_association
--
-- PURPOSE
--    Validate a association record.
--
-- PARAMETERS
--    p_association_rec: the association record to be validated
--
-- NOTES
--    1. p_association_rec should be the complete association record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_association(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_association_rec   IN  association_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_association_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_association_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_association_items(
   p_association_rec        IN  association_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_association_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_association_rec: the record to be validated; attributes
--       as FND_API.g_miss_char/num/date completed
---------------------------------------------------------------------
PROCEDURE check_association_record(
   p_association_rec         IN  association_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    complete_association_rec
--
-- PURPOSE
--    For update_association, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_association_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_association_rec(
   p_association_rec       IN  association_rec_type,
   x_complete_rec   OUT NOCOPY association_rec_type
);

PROCEDURE init_association_rec(
   x_association_rec  OUT NOCOPY  association_rec_type
);

END AMS_Associations_PVT;

 

/

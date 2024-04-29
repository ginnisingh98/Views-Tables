--------------------------------------------------------
--  DDL for Package AMS_LISTSOURCETYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTSOURCETYPE_PVT" AUTHID CURRENT_USER as
/* $Header: amsvlsts.pls 115.10 2003/08/19 09:24:26 kbasavar ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_ListSourceType_PVT
--
-- PURPOSE
--    Private API for Oracle Marketing List Source Types.
--
-- PROCEDURES
--    Create_ListSourceType
--    Delete_ListSourceType
--    Lock_ListSourceType
--    Update_ListSourceType
--    Validate_ListSourceType
--
--    Check_ListSourceType_Items
--    Check_ListSourceType_Record
--
--    Init_ListSourceType_Rec
--    Complete_ListSourceType_Rec
------------------------------------------------------------

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AMS_ListSourceType_PVT';

TYPE ListSourceType_Rec_Type IS RECORD (
   list_source_type_id        NUMBER,
   last_update_date           DATE,
   last_updated_by            NUMBER,
   creation_date              DATE,
   created_by                 NUMBER,
   last_update_login          NUMBER,
   object_version_number      NUMBER,
   list_source_name           VARCHAR2(240),
   list_source_type           VARCHAR2(30),
   source_type_code           VARCHAR2(30),
   source_object_name         VARCHAR2(30),
   master_source_type_flag    VARCHAR2(1),
   source_object_pk_field     VARCHAR2(30),
   enabled_flag               VARCHAR2(1),
   description                VARCHAR2(4000),
   view_application_id        NUMBER,
   java_class_name            VARCHAR2(4000),
   import_type                VARCHAR2(30),
   arc_act_src_used_by        VARCHAR2(30),
   source_category            VARCHAR2(30)
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_ListSourceType
--
-- PURPOSE
--    Create a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--    x_list_source_type_id: the list_source_type_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If list_source_type_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If list_source_type_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   x_list_source_type_id   OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ListSourceType
--
-- PURPOSE
--    Delete a list source type entry.
--
-- PARAMETERS
--    p_list_source_type_id: the list_source_type_id
--    p_object_version: the object_version_number
--
-- ISSUES
--    Currently, we are not allowing people to delete list source type
--    entries.  We may add some business rules for deletion though.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_list_source_type_id     IN  NUMBER,
   p_object_version     IN  NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Lock_ListSourceType
--
-- PURPOSE
--    Lock a list source type entry.
--
-- PARAMETERS
--    p_list_source_type_id: the list_source_type_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_list_source_type_id     IN  NUMBER,
   p_object_version     IN  NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Update_ListSourceType
--
-- PURPOSE
--    Update a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListSourceType
--
-- PURPOSE
--    Validate a list source type entry.
--
-- PARAMETERS
--    p_listsrctype_rec: the record representing AMS_LIST_SRC_TYPES.
--
-- NOTES
--    1. p_listsrctype_rec should be the complete list source type record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_ListSourceType (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_commit             IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_listsrctype_rec    IN  ListSourceType_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSourceType_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_ListSourceType_Items (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListSourceType_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listsrctype_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListSourceType_Record (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   p_complete_rec       IN  ListSourceType_Rec_Type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListSourceType_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_ListSourceType_Rec (
   x_listsrctype_rec         OUT NOCOPY  ListSourceType_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListSourceType_Rec
--
-- PURPOSE
--    For Update_ListSourceType, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_listdr_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_ListSourceType_Rec (
   p_listsrctype_rec    IN  ListSourceType_Rec_Type,
   x_complete_rec       OUT NOCOPY ListSourceType_Rec_Type
);


END AMS_ListSourceType_PVT;

 

/

--------------------------------------------------------
--  DDL for Package AMS_LISTFIELD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTFIELD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvlfds.pls 115.1 2000/02/05 17:49:01 pkm ship    $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_ListField_PVT
--
-- PURPOSE
--    Private API for Oracle Marketing List Fields.
--
-- PROCEDURES
--    Lock_ListField
--    Update_ListField
--    Validate_ListField
--
--    Check_ListField_Items
--    Check_ListField_Record
--
--    Init_ListField_Rec
--    Complete_ListField_Rec
------------------------------------------------------------

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AMS_ListField_PVT';

TYPE List_Field_Rec_Type IS RECORD (
   list_field_id              NUMBER,
   last_update_date           DATE,
   last_updated_by            NUMBER,
   creation_date              DATE,
   created_by                 NUMBER,
   last_update_login          NUMBER,
   object_version_number      NUMBER,
   field_table_name           VARCHAR2(30),
   field_column_name          VARCHAR2(30),
   column_data_type           VARCHAR2(30),
   column_data_length         NUMBER,
   enabled_flag               VARCHAR2(1),
   list_type_field_apply_on   VARCHAR2(30),
   description                VARCHAR2(4000)
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_ListField
--
-- PURPOSE
--    Lock a list field entry.
--
-- PARAMETERS
--    p_listfield_id: the list_field_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_id      IN  NUMBER,
   p_object_version    IN  NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Update_ListField
--
-- PURPOSE
--    Update a list field entry.
--
-- PARAMETERS
--    p_listfield_rec: the record representing AMS_LIST_FIELDS_VL.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_rec     IN  List_Field_Rec_Type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_ListField
--
-- PURPOSE
--    Validate a list field entry.
--
-- PARAMETERS
--    p_listfield_rec: the record representing AMS_LIST_FIELDS_VL.
--
-- NOTES
--    1. p_listfield_rec should be the complete list header record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_ListField (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT VARCHAR2,
   x_msg_count         OUT NUMBER,
   x_msg_data          OUT VARCHAR2,

   p_listfield_rec     IN  List_Field_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListField_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_listfield_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_ListField_Items (
   p_listfield_rec      IN  List_Field_Rec_Type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_ListField_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_listfield_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_ListField_Record (
   p_listfield_rec    IN  List_Field_Rec_Type,
   p_complete_rec     IN  List_Field_Rec_Type := NULL,
   x_return_status    OUT VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_ListField_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_ListField_Rec (
   x_listfield_rec         OUT  List_Field_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_ListField_Rec
--
-- PURPOSE
--    For Update_ListField, some attributes may be passed in as
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
PROCEDURE Complete_ListField_Rec (
   p_listfield_rec      IN  List_Field_Rec_Type,
   x_complete_rec       OUT List_Field_Rec_Type
);


END AMS_ListField_PVT;

 

/

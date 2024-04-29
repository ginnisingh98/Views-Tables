--------------------------------------------------------
--  DDL for Package PVX_MDF_OWNERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_MDF_OWNERS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvmdfs.pls 115.5 2002/01/28 11:24:47 pkm ship     $ */


TYPE mdf_owner_rec_type IS RECORD
(
 MDF_OWNER_ID	                NUMBER,
 COUNTRY			VARCHAR2(100),
 FROM_POSTAL_CODE		VARCHAR2(40),
 TO_POSTAL_CODE			VARCHAR2(40),
 CMM_RESOURCE_ID		NUMBER,
 LAST_UPDATE_DATE               DATE,
 LAST_UPDATED_BY                NUMBER,
 CREATION_DATE                  DATE,
 CREATED_BY                     NUMBER,
 LAST_UPDATE_LOGIN              NUMBER,
 OBJECT_VERSION_NUMBER          NUMBER,
 REQUEST_ID                     NUMBER,
 PROGRAM_APPLICATION_ID         NUMBER,
 PROGRAM_ID                     NUMBER,
 PROGRAM_UPDATE_DATE            DATE
);



---------------------------------------------------------------------
-- PROCEDURE
--    Create_Mdf_Owner
--
-- PURPOSE
--    Create a new mdf owner record
--
-- PARAMETERS
--    p_mdf_owner_rec   : the new record to be inserted
--    x_mdf_owner_id    : return the mdf_owner_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If mdf_owner_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If mdf_owner_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_rec IN  mdf_owner_rec_type
  ,x_mdf_owner_id  OUT NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Mdf_Owner
--
-- PURPOSE
--    Delete a Mdf_Owner_id.
--
-- PARAMETERS
--    p_mdf_owner_id: the mdf_owner_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_id    IN  NUMBER
  ,p_object_version      IN  NUMBER

);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_mdf_owner_id
--
-- PURPOSE
--    Lock a  mdf_owner_id.
--
-- PARAMETERS
--    p_mdf_owner_id:
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Mdf_Owner
--
-- PURPOSE
--    Update a  mdf_owner.
--
-- PARAMETERS
--    p_mdf_owner_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2
  ,p_mdf_owner_rec     IN  mdf_owner_rec_type

);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Mdf_Owner_values
--
-- PURPOSE
--    Validate a Mdf_Owner_id record.
--
-- PARAMETERS
--    p_mdf_owner_rec: the  record to be validated
--
-- NOTES
--    1. p_enty_attr_val_rec should be the complete  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Mdf_Owner(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT VARCHAR2
  ,x_msg_count         OUT NUMBER
  ,x_msg_data          OUT VARCHAR2

  ,p_mdf_owner_rec     IN  mdf_owner_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_mdf_owner_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_mdf_owner_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Mdf_Owner_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT VARCHAR2
  ,p_mdf_owner_rec   IN mdf_owner_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_mdf_owner_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_mdf_owner_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_mdf_owner_rec(
   p_mdf_owner_rec    IN  mdf_owner_rec_type
  ,p_complete_rec     IN  mdf_owner_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_mdf_owner_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_mdf_owner_rec(
   x_mdf_owner_rec   OUT  mdf_owner_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_mdf_owner_rec
--
-- PURPOSE
--    For update, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_mdf_owner_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_mdf_owner_rec(
   p_mdf_owner_rec   IN  mdf_owner_rec_type
  ,x_complete_rec    OUT mdf_owner_rec_type
);


END PVX_mdf_owners_PVT;

 

/

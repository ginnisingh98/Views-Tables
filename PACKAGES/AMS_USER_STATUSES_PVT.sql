--------------------------------------------------------
--  DDL for Package AMS_USER_STATUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_USER_STATUSES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvusts.pls 115.15 2004/03/05 07:06:11 vmodur ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_User_Statuses_PVT
--
-- PURPOSE
--    This package is a Private API for managing User Status information in
--    AMS.  It contains specification for pl/sql records and tables
--
--    AMS_USER_STATUSES_VL:
--    Create_User_Status (see below for specification)
--    Update_User_Status (see below for specification)
--    Delete_User_Status (see below for specification)
--    Lock_User_Status (see below for specification)
--    Validate_User_Status (see below for specification)
--
--    Check_User_Status_Items (see below for specification)
--    Check_User_Status_Record (see below for specification)
--    Init_User_Status_Rec
--    Complete_User_Status_Rec
--
-- NOTES
--
--
-- HISTORY
-- 10-Nov-1999    rvaka      Created.
-----------------------------------------------------------

-------------------------------------
-----          USER STATUSES            -----
-------------------------------------
-- Record for AMS_USER_STATUSES_VL
TYPE User_Status_Rec_Type IS RECORD (
   user_status_id          NUMBER,
   last_update_date        DATE,
   last_updated_by         NUMBER,
   creation_date           DATE,
   created_by              NUMBER,
   last_update_login       NUMBER,
   object_version_number   NUMBER,
   system_status_type      VARCHAR2(240),
   system_status_code      VARCHAR2(30),
   default_flag            VARCHAR2(1),
   enabled_flag            VARCHAR2(1),
   seeded_flag             VARCHAR2(1),
   start_date_active       DATE,
   end_date_active         DATE,
   name                    VARCHAR2(120),
   description             VARCHAR2(4000)
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_User_Status
--
-- PURPOSE
--    Create User Status entry.
--
-- PARAMETERS
--    p_user_status_rec: the record representing AMS_USER_STATUSES_VL view..
--    x_user_status_id: the user_status_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If user_status_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_user_status_rec   IN  User_Status_Rec_Type,
   x_user_status_id    OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_User_Status
--
-- PURPOSE
--    Update an User Status entry.
--
-- PARAMETERS
--    p_user_status_rec: the record representing AMS_USER_STATUSES_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_user_status_rec   IN  User_Status_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_User_Status
--
-- PURPOSE
--    Delete a user_status entry.
--
-- PARAMETERS
--    p_user_status_id: the user_status_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_user_status_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_User_Status
--
-- PURPOSE
--    Lock a user_status entry.
--
-- PARAMETERS
--    p_user_status_id: the user_status
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_user_status_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_User_Status
--
-- PURPOSE
--    Validate a user_status entry.
--
-- PARAMETERS
--    p_user_status_rec: the record representing AMS_USER_STATUSES_VL (without ROW_ID).
--
-- NOTES
--    1. p_user_status_rec should be the complete user_status record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_User_Status (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_user_status_rec         IN  User_Status_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_User_Status_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_user_status_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_User_Status_Items (
   p_user_status_rec       IN  User_Status_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_User_Status_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_user_status_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_User_Status_Record (
   p_user_status_rec        IN  User_Status_Rec_Type,
   p_complete_rec     IN  User_Status_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_User_Status_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_User_Status_Rec (
   x_user_status_rec         OUT NOCOPY  User_Status_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_User_Status_Rec
--
-- PURPOSE
--    For Update_User_Status, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_user_status_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_User_Status_Rec (
   p_user_status_rec      IN  User_Status_Rec_Type,
   x_complete_rec   OUT NOCOPY User_Status_Rec_Type
);


END AMS_User_Statuses_PVT;

 

/

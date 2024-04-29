--------------------------------------------------------
--  DDL for Package AMS_APPROVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPROVERS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvaprs.pls 115.8 2002/12/29 08:42:57 vmodur noship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_APPROVERS_PVT
--
-- PURPOSE
--    This package is a Private API for managing Approvers
--    in AMS.  It contains specification for pl/sql records and tables
--
--    AMS_APPROVERS:
--    Create_approvers (see below for specification)
--    Update_approvers (see below for specification)
--    Delete_approvers (see below for specification)
--    Lock_approvers (see below for specification)
--    Validate_approvers (see below for specification)
--
--    Check_Approvers_Items (see below for specification)
--    Check_Approvers_Record (see below for specification)
--    Init_Approvers_Rec
--    Complete_Approvers_Rec
--
-- NOTES
--
--
-- HISTORY
-- 19-OCT-2000    mukumar      Created.
-- 25-SEP-2002    vmodur      uncommented security_group_id in record type
-----------------------------------------------------------

-------------------------------------
-----          Approvers -----
-------------------------------------
-- Record for AMS_APPROVERS
TYPE Approvers_Rec_Type IS RECORD (
     APPROVER_ID              NUMBER
    , LAST_UPDATE_DATE        DATE
    , LAST_UPDATED_BY         NUMBER
    , CREATION_DATE           DATE
    , CREATED_BY              NUMBER
    , LAST_UPDATE_LOGIN       NUMBER
    , OBJECT_VERSION_NUMBER   NUMBER
    , SECURITY_GROUP_ID       NUMBER
    , AMS_APPROVAL_DETAIL_ID  NUMBER
    , APPROVER_SEQ            NUMBER
    , APPROVER_TYPE           VARCHAR2(30)
    , OBJECT_APPROVER_ID      NUMBER
    , NOTIFICATION_TYPE       VARCHAR2(30)
    , NOTIFICATION_TIMEOUT    NUMBER
    , SEEDED_FLAG             VARCHAR2(1)
    , ACTIVE_FLAG             VARCHAR2(1)
    , START_DATE_ACTIVE       DATE
    , END_DATE_ACTIVE         DATE
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Approvers
--
-- PURPOSE
--    Create Approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVERS.
--    x_approver_id: the approver_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If approver_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec   IN  Approvers_Rec_Type,
   x_approver_id    OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_approvers
--
-- PURPOSE
--    Update an approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVERS
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec   IN  Approvers_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_approvers
--
-- PURPOSE
--    Delete a approvers  entry.
--
-- PARAMETERS
--    p_approver_id: the approver_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approver_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_approvers
--
-- PURPOSE
--    Lock a approvers entry.
--
-- PARAMETERS
--    p_approver_id: the approver_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approver_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_approvers
--
-- PURPOSE
--    Validate a approvers entry.
--
-- PARAMETERS
--    p_approvers_rec: the record representing AMS_APPROVERS
--
-- NOTES
--    1. p_approvers_rec should be the complete approver record.
--       There should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approvers_rec         IN  approvers_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approvers_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_approvers_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_approvers_Items (
   p_approvers_rec       IN  approvers_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approvers_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_approvers_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_approvers_Record (
   p_approvers_rec        IN  approvers_Rec_Type,
   p_complete_rec     IN  approvers_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_approvers_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_approvers_Rec (
   x_approvers_rec         OUT NOCOPY  approvers_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_approvers_Rec
--
-- PURPOSE
--    For Update_approvers, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_approvers_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_approvers_Rec (
   p_approvers_rec      IN  approvers_Rec_Type,
   x_complete_rec   OUT NOCOPY approvers_Rec_Type
);


END AMS_approvers_PVT;

 

/

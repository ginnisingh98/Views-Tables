--------------------------------------------------------
--  DDL for Package AMS_APPROVAL_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_APPROVAL_DETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvapds.pls 115.9 2004/03/05 07:02:52 vmodur ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_APPROVAL_DETAILS_PVT
--
-- PURPOSE
--    This package is a Private API for managing Approval details
--    in AMS.  It contains specification for pl/sql records and tables
--
--    AMS_APPROVAL_DETAILS_VL:
--    Create_Approval_Details (see below for specification)
--    Update_Approval_Details (see below for specification)
--    Delete_Approval_Details (see below for specification)
--    Lock_Approval_Details (see below for specification)
--    Validate_Approval_Details (see below for specification)
--
--    Check_Approval_Details_Items (see below for specification)
--    Check_Approval_Details_Record (see below for specification)
--    Init_Approval_Details_Rec
--    Complete_Approval_Details_Rec
--
-- NOTES
--
--
-- HISTORY
-- 19-OCT-2000    mukumar      Created.
-- 25-SEP-2002    vmodur       uncommented security_group_id in record type
-----------------------------------------------------------

-------------------------------------
-----          Approval Details -----
-------------------------------------
-- Record for AMS_Approval_Details_VL
TYPE Approval_Details_Rec_Type IS RECORD (
    START_DATE_ACTIVE       DATE
   , END_DATE_ACTIVE        DATE
   , APPROVAL_DETAIL_ID     NUMBER
   , LAST_UPDATE_DATE       DATE
   , LAST_UPDATED_BY        NUMBER
   , CREATION_DATE          DATE
   , CREATED_BY             NUMBER
   , LAST_UPDATE_LOGIN      NUMBER
   , OBJECT_VERSION_NUMBER  NUMBER
   , SECURITY_GROUP_ID      NUMBER
   , BUSINESS_GROUP_ID      NUMBER
   , BUSINESS_UNIT_ID       NUMBER
   , ORGANIZATION_ID        NUMBER
   , CUSTOM_SETUP_ID        NUMBER
   , APPROVAL_OBJECT        VARCHAR2(30)
   , APPROVAL_OBJECT_TYPE   VARCHAR2(30)
   , APPROVAL_TYPE          VARCHAR2(30)
   , APPROVAL_PRIORITY      VARCHAR2(30)
   , APPROVAL_LIMIT_TO      NUMBER
   , APPROVAL_LIMIT_FROM    NUMBER
   , SEEDED_FLAG            VARCHAR2(1)
   , ACTIVE_FLAG            VARCHAR2(1)
   , CURRENCY_CODE          VARCHAR2(15)
   , USER_COUNTRY_CODE      VARCHAR2(30)
   , NAME                   VARCHAR2(240)
   , DESCRIPTION            VARCHAR2(4000)
);


 --TYPE t_approval_id_table IS TABLE OF Approval_Details_Rec_Type.approval_detail_id%TYPE
--      INDEX BY BINARY_INTEGER;

   TYPE t_approval_id_table IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Approval_Details
--
-- PURPOSE
--    Create Approval Details entry.
--
-- PARAMETERS
--    p_approval_detail_rec: the record representing AMS_APPROVAL_DETAILS_VL view..
--    x_approval_detail_id: the approval_detail_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If approval_detail_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_details_rec   IN  Approval_Details_Rec_Type,
   x_approval_detail_id    OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_approval_details
--
-- PURPOSE
--    Update an approval details entry.
--
-- PARAMETERS
--    p_approval_details_rec: the record representing AMS_APPROVAL_DETAILS_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_details_rec   IN  Approval_Details_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_approval_details
--
-- PURPOSE
--    Delete a approval details entry.
--
-- PARAMETERS
--    p_approval_detail_id: the approval_detail_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_detail_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_approval_details
--
-- PURPOSE
--    Lock a approval details entry.
--
-- PARAMETERS
--    p_approval_detail_id: the approval_detail
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_detail_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_approval_details
--
-- PURPOSE
--    Validate a approval_details entry.
--
-- PARAMETERS
--    p_approval_details_rec: the record representing AMS_APPROVAL_DETAILS_VL (without ROW_ID).
--
-- NOTES
--    1. p_approval_details_rec should be the complete approval_details record.
--       There should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_approval_details (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_approval_details_rec         IN  approval_details_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approval_details_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_approval_details_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_approval_details_Items (
   p_approval_details_rec       IN  approval_details_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_approval_details_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_approval_details_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_approval_details_Record (
   p_approval_details_rec        IN  approval_details_Rec_Type,
   p_complete_rec     IN  approval_details_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_approval_details_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_approval_details_Rec (
   x_approval_details_rec         OUT NOCOPY  approval_details_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_approval_details_Rec
--
-- PURPOSE
--    For Update_approval_details, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_approval_details_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_approval_details_Rec (
   p_approval_details_rec      IN  approval_details_Rec_Type,
   x_complete_rec   OUT NOCOPY approval_details_Rec_Type
);


END AMS_approval_details_PVT;

 

/

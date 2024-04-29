--------------------------------------------------------
--  DDL for Package AHL_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_APPROVALS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVAPRS.pls 120.0 2005/05/25 23:54:43 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    Ahl_Approvals_Pvt
--
-- PURPOSE
--    This package is a Private API for managing Approval Rules and Approvers information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    Create_Approvals   (see below for specification)
--    Update_Approvals   (see below for specification)
--    Delete_Approvals   (see below for specification)
--    Validate_Approvals (see below for specification)
--
--    Check_Approvals_Items (see below for specification)
--    Check_Approvals_Record (see below for specification)
--    Init_Approvals_Rec (see below for specification)
--    Complete_Approvals_Rec (see below for specification)
--
--    Create_Approvers (see below for specification)
--    Update_Approvers (see below for specification)
--    Delete_Approvers (see below for specification)
--    Validate_Approvers (see below for specification)
--
--    Check_Approvers_Items (see below for specification)
--    Check_Approvers_Record (see below for specification)
--    Init_Approvers_Rec (see below for specification)
--    Complete_Approvers_Rec (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
-- 21-JAN-2002    SHBHANDA      Created.
-----------------------------------------------------------

-------------------------------------
-- Approval Rules Record Type   -----
-------------------------------------
--
TYPE Approval_Rules_Rec_Type IS RECORD (
   APPROVAL_RULE_ID           NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   APPROVAL_OBJECT_CODE       VARCHAR2(30),
   APPROVAL_PRIORITY_CODE     VARCHAR2(30),
   APPROVAL_TYPE_CODE         VARCHAR2(30),
   APPLICATION_USG_CODE	      VARCHAR2(30),
   APPLICATION_USG            VARCHAR2(80),
   OPERATING_UNIT_ID          NUMBER,
   OPERATING_NAME  	      VARCHAR2(240),
   ACTIVE_START_DATE          DATE,
   ACTIVE_END_DATE            DATE,
   STATUS_CODE                VARCHAR2(30),
   SEEDED_FLAG                VARCHAR2(1),
   ATTRIBUTE_CATEGORY         VARCHAR2(30),
   ATTRIBUTE1                 VARCHAR2(150),
   ATTRIBUTE2                 VARCHAR2(150),
   ATTRIBUTE3                 VARCHAR2(150),
   ATTRIBUTE4                 VARCHAR2(150),
   ATTRIBUTE5                 VARCHAR2(150),
   ATTRIBUTE6                 VARCHAR2(150),
   ATTRIBUTE7                 VARCHAR2(150),
   ATTRIBUTE8                 VARCHAR2(150),
   ATTRIBUTE9                 VARCHAR2(150),
   ATTRIBUTE10                VARCHAR2(150),
   ATTRIBUTE11                VARCHAR2(150),
   ATTRIBUTE12                VARCHAR2(150),
   ATTRIBUTE13                VARCHAR2(150),
   ATTRIBUTE14                VARCHAR2(150),
   ATTRIBUTE15                VARCHAR2(150),
   APPROVAL_RULE_NAME         VARCHAR2(360),
   DESCRIPTION                VARCHAR2(2000),
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   lAST_UPDATE_LOGIN          NUMBER,
   OPERATION_FLAG             VARCHAR2(1)
  );

-------------------------------------
----- Approvers Record Type   -------
-------------------------------------

TYPE Approvers_Rec_Type IS RECORD (
   APPROVAL_APPROVER_ID       NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   APPROVAL_RULE_ID           NUMBER,
   APPROVER_TYPE_CODE         VARCHAR2(30),
   APPROVER_SEQUENCE          NUMBER,
   APPROVER_ID                NUMBER,
   APPROVER_NAME              VARCHAR2(100),
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_LOGIN          NUMBER,
   ATTRIBUTE_CATEGORY         VARCHAR2(30),
   ATTRIBUTE1                 VARCHAR2(150),
   ATTRIBUTE2                 VARCHAR2(150),
   ATTRIBUTE3                 VARCHAR2(150),
   ATTRIBUTE4                 VARCHAR2(150),
   ATTRIBUTE5                 VARCHAR2(150),
   ATTRIBUTE6                 VARCHAR2(150),
   ATTRIBUTE7                 VARCHAR2(150),
   ATTRIBUTE8                 VARCHAR2(150),
   ATTRIBUTE9                 VARCHAR2(150),
   ATTRIBUTE10                VARCHAR2(150),
   ATTRIBUTE11                VARCHAR2(150),
   ATTRIBUTE12                VARCHAR2(150),
   ATTRIBUTE13                VARCHAR2(150),
   ATTRIBUTE14                VARCHAR2(150),
   ATTRIBUTE15                VARCHAR2(150),
   OPERATION_FLAG             VARCHAR2(1)
   );

---------------------------------------------------
-- Table Type of Approval Rules Record Type   -----
---------------------------------------------------

Type Approvers_Tbl IS TABLE OF Approvers_Rec_Type
INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Approvals
--
-- PURPOSE
--    Process Approvals entry.
--
-- PARAMETERS
--    p_x_Approval_Rules_Rec: the record representing AHL_Approval_Rules_B and  AHL_Approval_Rules_TL tables
--    p_x_Approvers_Tbl     : the table representing the records of AHL_Approvers tables.
--
-- NOTES
--    1. Procedure helps out to link between JSP page and API package
--    2. On the basis  of operation flag as one field in each record type
--       the further procedure for create/update/delete for Approvals Rules and Approvers.
---------------------------------------------------------------------

PROCEDURE Process_Approvals (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,

   p_x_Approval_Rules_Rec IN  OUT NOCOPY Approval_Rules_Rec_Type,
   p_x_Approvers_Tbl      IN  OUT NOCOPY Approvers_Tbl,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
------------        APPROVAL RULES                      -------------
---------------------------------------------------------------------

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Approval_Rules
--
-- PURPOSE
--    Create Approval Rules entry.
--
-- PARAMETERS
--    p_Approval_rec: the record representing AHL_Approval_Rules_VL view..
--    x_Approval_Rule_Id: the Approval_Rule_Id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Approval_Rules_Id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_miss_char/num/date.
-------------------------------------------------------------------
PROCEDURE Create_Approval_Rules (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_Approval_Rules_Rec   IN  Approval_Rules_Rec_Type,
   x_Approval_Rules_Id    OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Approval_Rules
--
-- PURPOSE
--    Update an Approval_Rules entry.
--
-- PARAMETERS
--    p_Approval_Rules_rec: the record representing AHL_Approval_Rules_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Approval_Rules (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Approval_Rules_rec   IN  Approval_Rules_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Approval_Rules
--
-- PURPOSE
--    Delete a Approval Rules entry.
--
-- PARAMETERS
--    p_Approval_Rules_id: the Approval_Rules_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Approval_Rules (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Approval_Rule_Id  IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Approval Rules
--
-- PURPOSE
--    Validate a Approval Rules entry.
--
-- PARAMETERS
--    p_Approval_rec: the record representing AHL_Approval_Rules_VL (without ROW_ID).
--
-- NOTES
--    1. p_Approval_Rules_rec should be the complete Approval Rules record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_Approval_Rules (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Approval_Rules_rec         IN  Approval_Rules_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Approval_Rules_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_Approval_Rules_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Approval_Rules_Items (
   p_Approval_Rules_rec       IN  Approval_Rules_Rec_Type,
   p_validation_mode IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Approval_Rules_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_Approval_Rules_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Approval_Rules_Record (
   p_Approval_Rules_rec        IN  Approval_Rules_Rec_Type,
   p_complete_rec     IN  Approval_Rules_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Approval_Rules_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
/*PROCEDURE Init_Approval_Rules_Rec (
   x_Approval_Rules_rec         OUT  NOCOPY Approval_Rules_Rec_Type
);
*/
---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Approval_Rules_Rec
--
-- PURPOSE
--    For Update_Approval_Rules, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_Approval_Rules_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Approval_Rules_Rec (
   p_Approval_Rules_rec      IN  Approval_Rules_Rec_Type,
   x_complete_rec            OUT NOCOPY Approval_Rules_Rec_Type
);

---------------------------------------------------------------------
------------        APPROVERS                           -------------
---------------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Approvers
--
-- PURPOSE
--    Create Approvers entry.
--
-- PARAMETERS
--    p_Approvers_rec: the record representing AHL_Approvers_V view..
--    x_Approval_Approver_Id: the Approval_Approver_Id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Approvers_Id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

PROCEDURE Create_Approvers (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_Approvers_Rec        IN  Approvers_Rec_Type,
   x_Approval_Approver_Id  OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Approvers
--
-- PURPOSE
--    Update an Approvers entry.
--

--
-- PARAMETERS
--    p_Approvers_rec: the record representing AHL_Approvers_V (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Approvers_rec     IN  Approvers_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Approvers
--
-- PURPOSE
--    Delete a Approvers entry.
--
-- PARAMETERS
--    p_Approvers_id: the Approvers_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE Delete_Approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
  p_Approval_Approver_Id     IN  NUMBER,
   p_object_version    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Approvers
--
-- PURPOSE
--    Validate a Approvers entry.
--
-- PARAMETERS
--    p_Approvers_rec: the record representing AHL_Approvers_V (without ROW_ID).
--
-- NOTES
--    1. p_Approvers_rec should be the complete Approvers record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, the raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_Approvers (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_Approvers_rec     IN  Approvers_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Check_Approvers_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_Approvers_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Approvers_Items (
   p_validation_mode     IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   p_Approvers_rec       IN  Approvers_Rec_Type,

   x_return_status       OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------

-- PROCEDURE
--    Check_Approvers_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_Approvers_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
--PROCEDURE Check_Approvers_Record (
  -- p_Approvers_rec    IN  Approvers_Rec_Type,
   --p_complete_rec     IN  Approvers_Rec_Type := NULL,

--   x_return_status    OUT NOCOPY VARCHAR2
--);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Approvers_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
/*PROCEDURE Init_Approvers_Rec (
   x_Approvers_rec         OUT  NOCOPY Approvers_Rec_Type
);
*/

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Approvers_Rec
--
-- PURPOSE
--    For Update_Approvers, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_Approvers_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Approvers_Rec (
   p_Approvers_rec  IN  Approvers_Rec_Type,
   x_complete_rec   OUT NOCOPY Approvers_Rec_Type
);

END Ahl_Approvals_Pvt;

 

/

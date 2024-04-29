--------------------------------------------------------
--  DDL for Package AHL_WF_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_WF_MAPPING_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVWFMS.pls 120.0 2005/05/26 01:46:33 appldev noship $ */

-----------------------------------------------------------
-- PACKAGE
--    Ahl_Wf_Mapping_Pvt
--
-- PURPOSE
--    This package is a Private API for managing Workflow Mappping information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--    AHL_Wf_Mapping_V:
--    Create_Wf_Mapping (see below for specification)
--    Update_Wf_Mapping (see below for specification)
--    Delete_Wf_Mapping (see below for specification)
--    Validate_Wf_Mapping (see below for specification)
--
--    Check_Wf_Mapping_Items (see below for specification)
--    Check_Wf_Mapping_Record (see below for specification)
--    Init_Wf_Mapping_Rec
--    Complete_Wf_Mapping_Rec
--
-- NOTES
--
--
-- HISTORY
-- 21-JAN-2002    SHBHANDA      Created.
-----------------------------------------------------------
-------------------------------------
-- Record for AHL_Wf_Mapping_V
TYPE Wf_Mapping_Rec_Type IS RECORD (
   WF_Mapping_ID       NUMBER,
   OBJECT_VERSION_NUMBER      NUMBER,
   CREATION_DATE              DATE,
   CREATED_BY                 NUMBER,
   LAST_UPDATE_DATE           DATE,
   LAST_UPDATED_BY            NUMBER,
   LAST_UPDATE_LOGIN          NUMBER,
   ACTIVE_FLAG                VARCHAR2(1),
   WF_PROCESS_NAME            VARCHAR2(30),
   WF_DISPLAY_NAME            VARCHAR2(80),
   APPROVAL_OBJECT            VARCHAR2(30),
   ITEM_TYPE                  VARCHAR2(8),
			APPLICATION_USG_CODE       VARCHAR2(30),
			APPLICATION_USG            VARCHAR2(80),
   OPERATION_FLAG             VARCHAR2(1)
  );

-- Table for all Records of AHL_Wf_Mapping_V
Type Wf_Mapping_tbl IS TABLE OF Wf_Mapping_Rec_Type
INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Wf_Mapping
--
-- PURPOSE
--    Process Wf_Mapping entry.
--
-- PARAMETERS
--    p_x_Wf_Mapping_tbl: the table of records representing AHL_Wf_Mapping table
--
-- NOTES
--    1. Procedure helps out to link between JSP page and API package
--    2. On the basis  of operation flag as one field in each record type
--       the further procedure for create/update/delete.
---------------------------------------------------------------------

PROCEDURE Process_Wf_Mapping (
   p_api_version          IN  NUMBER    := 1.0,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_x_Wf_Mapping_tbl     IN  OUT NOCOPY Wf_Mapping_tbl,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Wf_Mapping
--
-- PURPOSE
--    Create Wf_Mapping entry.
--
-- PARAMETERS
--    p_Wf_Mapping_rec: the record representing AHL_Wf_Mapping table
--    x_WF_Mapping_ID: the WF_Mapping_ID.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Wf_Mapping_Id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. Please don't pass in any FND_API.g_miss_char/num/date.
---------------------------------------------------------------------

PROCEDURE Create_Wf_Mapping (
   p_api_version          IN  NUMBER	:= 1.0,
   p_init_msg_list        IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit               IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level     IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Wf_Mapping_Rec       IN  Wf_Mapping_Rec_Type,

   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_Wf_Mapping_Id        OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Wf_Mapping
--
-- PURPOSE
--    Update an Wf_Mapping entry.
--
--
-- PARAMETERS
--    p_Wf_Mapping_rec: the record representing AHL_Wf_Mapping_V (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------

PROCEDURE Update_Wf_Mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,
   p_Wf_Mapping_rec    IN  Wf_Mapping_Rec_Type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_wf_mapping
--
-- PURPOSE
--    Delete a wf _mapping entry.
--
-- PARAMETERS
--    p_wf_mapping_id: the wf_mapping_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
-------------------------------------------------------------------
PROCEDURE Delete_Wf_mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Wf_mapping_Id     IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Wf_Mapping
--
-- PURPOSE
--    Validate a Wf_Mapping entry.
--
-- PARAMETERS
--    p_Wf_Mapping_rec: the record representing AHL_Wf_Mapping_V (without ROW_ID).
--
-- NOTES
--    1. p_Wf_Mapping_rec should be the complete Wf_Mapping record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------

PROCEDURE Validate_Wf_Mapping (
   p_api_version       IN  NUMBER    := 1.0,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2  := Fnd_Api.g_false,
   p_validation_level  IN  NUMBER    := Fnd_Api.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Wf_Mapping_rec    IN  Wf_Mapping_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Wf_Mapping_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_Wf_Mapping_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Wf_Mapping_Items (
   p_Wf_Mapping_rec      IN  Wf_Mapping_Rec_Type,
   p_validation_mode     IN  VARCHAR2 := Jtf_Plsql_Api.g_create,

   x_return_status       OUT NOCOPY VARCHAR2
);

-- PROCEDURE
--    Init_Wf_Mapping_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
/*PROCEDURE Init_Wf_Mapping_Rec (
   x_Wf_Mapping_rec         OUT  NOCOPY Wf_Mapping_Rec_Type
);
*/

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Wf_Mapping_Rec
--
-- PURPOSE
--    For Update_Wf_Mapping, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_Wf_Mapping_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Wf_Mapping_Rec (
   p_Wf_Mapping_rec  IN  Wf_Mapping_Rec_Type,

   x_complete_rec   OUT NOCOPY Wf_Mapping_Rec_Type
);

END Ahl_Wf_Mapping_Pvt;

 

/

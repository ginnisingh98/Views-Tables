--------------------------------------------------------
--  DDL for Package PVX_LEAD_PSS_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_LEAD_PSS_LINES_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpsss.pls 115.8 2002/12/11 10:58:43 anubhavk ship $ */

TYPE lead_pss_lines_rec_type IS RECORD
(
 LEAD_PSS_LINE_ID               NUMBER,
 LAST_UPDATE_DATE               DATE,
 LAST_UPDATED_BY                NUMBER,
 CREATION_DATE                  DATE,
 CREATED_BY                     NUMBER,
 LAST_UPDATE_LOGIN              NUMBER,
 OBJECT_VERSION_NUMBER          NUMBER,
 REQUEST_ID                     NUMBER,
 PROGRAM_APPLICATION_ID         NUMBER,
 PROGRAM_ID                     NUMBER,
 PROGRAM_UPDATE_DATE	        DATE,
 OBJECT_NAME 		        VARCHAR2(30),
 ATTR_CODE_ID                   NUMBER,
 LEAD_ID                        NUMBER,
 UOM_CODE                       VARCHAR2(3),
 QUANTITY                       NUMBER,
 AMOUNT                         NUMBER,
 ATTRIBUTE_CATEGORY             VARCHAR2(30),
 ATTRIBUTE1                     VARCHAR2(150),
 ATTRIBUTE2                     VARCHAR2(150),
 ATTRIBUTE3                     VARCHAR2(150),
 ATTRIBUTE4                     VARCHAR2(150),
 ATTRIBUTE5                     VARCHAR2(150),
 ATTRIBUTE6                     VARCHAR2(150),
 ATTRIBUTE7                     VARCHAR2(150),
 ATTRIBUTE8                     VARCHAR2(150),
 ATTRIBUTE9                     VARCHAR2(150),
 ATTRIBUTE10                    VARCHAR2(150),
 ATTRIBUTE11                    VARCHAR2(150),
 ATTRIBUTE12                    VARCHAR2(150),
 ATTRIBUTE13                    VARCHAR2(150),
 ATTRIBUTE14                    VARCHAR2(150),
 ATTRIBUTE15                    VARCHAR2(150),
 OBJECT_ID                      NUMBER,
 PARTNER_ID                     NUMBER
);



---------------------------------------------------------------------
-- PROCEDURE
--    Create_lead_pss_line
--
-- PURPOSE
--    Create a new lead pss line record
--
-- PARAMETERS
--    p_lead_pss_line_rec: the new record to be inserted
--    x_lead_pss_line_id: return the lead_pss_line_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If lead_pss_line_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If lead_pss_line_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_lead_pss_line(
   p_api_version_number IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,x_lead_pss_line_id   OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_lead_pss_line
--
-- PURPOSE
--    Delete a lead_pss_line
--
-- PARAMETERS
--    p_lead_pss_line_id: the lead_pss_line_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_line_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_lead_pss_line
--
-- PURPOSE
--    Lock a lead_pss_line
--
-- PARAMETERS
--    p_lead_pss_line_id:
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_line_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_lead_pss_line
--
-- PURPOSE
--    Update a  lead_pss_line
--
-- PARAMETERS
--    p_lead_pss_lines_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_lead_pss_lines_rec     IN  lead_pss_lines_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_lead_pss_line
--
-- PURPOSE
--    Validate a lead_pss_lines record.
--
-- PARAMETERS
--    p_lead_pss_lines_rec: the  record to be validated
--
-- NOTES
--    1. p_lead_pss_lines_rec should be the complete  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_lead_pss_line(
   p_api_version_number       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_lead_pss_lines_rec   IN  lead_pss_lines_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_lead_pss_line_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_lead_pss_line_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_lead_pss_line_Items(
   p_validation_mode    	IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,p_lead_pss_lines_rec      IN  lead_pss_lines_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_lead_pss_line_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_lead_pss_line_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_lead_pss_line_Record(
   p_lead_pss_lines_rec  IN lead_pss_lines_rec_type
  ,p_complete_rec       IN  lead_pss_lines_rec_type := NULL
  ,p_mode               IN  VARCHAR2 := 'INSERT'
  ,x_return_status      OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_lead_pss_line_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_lead_pss_line_rec(
   x_lead_pss_lines_rec   OUT NOCOPY  lead_pss_lines_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_lead_pss_line_rec
--
-- PURPOSE
--    For update, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_lead_pss_line_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_lead_pss_line_rec(
   p_lead_pss_lines_rec IN  lead_pss_lines_rec_type
  ,x_complete_rec    OUT NOCOPY lead_pss_lines_rec_type
);


END PVX_lead_pss_lines_PVT;

 

/

--------------------------------------------------------
--  DDL for Package JTF_AMV_ATTACHMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_AMV_ATTACHMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpatts.pls 115.9 2002/11/26 22:13:56 stopiwal ship $ */

--
-- PACKAGE
--    JTF_AMV_ATTACHMENT_PUB
--
-- PURPOSE
--    Public API for document attachments.
--    It provide function for creating, deleting, or updating attachments
--    associated to the calling objects.
--
-- PROCEDURES
--
--------------------------------
--    Activity Attachments --
--------------------------------
--    create_act_attachment
--    delete_act_attachment
--    update_act_attachment
--    lock_act_attachment
--    validate_act_attachment
--
--    check_act_attachment_items
--    check_act_attachment_record
--
--    miss_act_attachment_rec
--    complete_act_attachment_rec
--
-- HISTORY
--    10/09/1999   khung@us.oracle.com     created
--    11/23/1999   PWU                     modify to move to jtf.
--    06/20/2000   rmajumda                Modified the record type definition
--                                         act_attachment_rec_type
--------------------------------------------------------------------------
TYPE act_attachment_rec_type IS RECORD
(
  attachment_id                  NUMBER,
  last_update_date               DATE,
  last_updated_by                NUMBER,
  creation_date                  DATE,
  created_by                     NUMBER,
  last_update_login              NUMBER,
  object_version_number          NUMBER,
  owner_user_id                  NUMBER,
  attachment_used_by_id          NUMBER,
  attachment_used_by             VARCHAR2(30),
  version                        VARCHAR2(20),
  enabled_flag                   VARCHAR2(1),
  can_fulfill_electronic_flag    VARCHAR2(1),
  file_id                        NUMBER,
  file_name                      VARCHAR2(240),
  file_extension                 VARCHAR2(20),
  document_id                    NUMBER,
  keywords                       VARCHAR2(240),
  display_width                  NUMBER,
  display_height                 NUMBER,
  display_location               VARCHAR2(2000),
  link_to                        VARCHAR2(2000),
  link_URL                       VARCHAR2(2000),
  send_for_preview_flag          VARCHAR2(1),
  attachment_type                VARCHAR2(30),
  language_code                  VARCHAR2(4),
  application_id                 NUMBER,
  description                    VARCHAR2(2000),
  default_style_sheet            VARCHAR2(240),
  display_url                    VARCHAR2(1024),
  display_rule_id                NUMBER,
  display_program                VARCHAR2(240),
  attribute_category             VARCHAR2(30),
  attribute1                     VARCHAR2(150),
  attribute2                     VARCHAR2(150),
  attribute3                     VARCHAR2(150),
  attribute4                     VARCHAR2(150),
  attribute5                     VARCHAR2(150),
  attribute6                     VARCHAR2(150),
  attribute7                     VARCHAR2(150),
  attribute8                     VARCHAR2(150),
  attribute9                     VARCHAR2(150),
  attribute10                    VARCHAR2(150),
  attribute11                    VARCHAR2(150),
  attribute12                    VARCHAR2(150),
  attribute13                    VARCHAR2(150),
  attribute14                    VARCHAR2(150),
  attribute15                    VARCHAR2(150),
  display_text                   VARCHAR2(2000),
  alternate_text                 VARCHAR2(1000),
  secured_flag                   VARCHAR2(1),
  attachment_sub_type            VARCHAR2(30)
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_act_attachment
--
-- PURPOSE
--    Create a new activity attachment.
--
-- PARAMETERS
--    p_act_attachment_rec: the new record to be inserted
--    x_act_attachment_id: return the activity_attachment_id of the new
--      attachment
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If activity_attachment_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If activity_attachment_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

PROCEDURE create_act_attachment
(
  p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.g_false,
  p_commit               IN   VARCHAR2 := FND_API.g_false,
  p_validation_level     IN   NUMBER   := FND_API.g_valid_level_full,

  x_return_status        OUT NOCOPY   VARCHAR2,
  x_msg_count            OUT NOCOPY   NUMBER,
  x_msg_data             OUT NOCOPY   VARCHAR2,

  p_act_attachment_rec   IN   act_attachment_rec_type,
  x_act_attachment_id    OUT NOCOPY   NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_act_attachment
--
-- PURPOSE
--    Delete an activity attachment.
--
-- PARAMETERS
--    p_act_attachment_id: the activity_attachment_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE delete_act_attachment
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
  p_commit               IN  VARCHAR2 := FND_API.g_false,
  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  p_act_attachment_id    IN  NUMBER,
  p_object_version       IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_act_attachment
--
-- PURPOSE
--    Update an activity attachment.
--
-- PARAMETERS
--    p_act_attachment_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------

PROCEDURE update_act_attachment
(
  p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
  p_commit               IN  VARCHAR2 := FND_API.g_false,
  p_validation_level     IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status        OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,

  p_act_attachment_rec   IN  act_attachment_rec_type
);

-------------------------------------------------------------------
-- PROCEDURE
--    lock_act_attachment
--
-- PURPOSE
--    Lock an activity attachment.
--
-- PARAMETERS
--    p_act_attachment_id: the activity_attachment_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE lock_act_attachment
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,

   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2,

   p_act_attachment_id   IN  NUMBER,
   p_object_version      IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_act_attachment
--
-- PURPOSE
--    Validate an activity attachment record.
--
-- PARAMETERS
--    p_act_attachment_rec: the activity attachment record to be validated
--
-- NOTES
--    1. p_act_attachment_rec should be the complete activity attachment
--       record. There should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------

PROCEDURE validate_act_attachment
(
   p_api_version         IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2  := FND_API.g_false,
   p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2,

   p_act_attachment_rec  IN  act_attachment_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_act_attachment_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------

PROCEDURE check_act_attachment_items
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY  VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_act_attachment_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_act_attachment_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------

PROCEDURE check_act_attachment_record
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   p_complete_rec        IN  act_attachment_rec_type := NULL,
   x_return_status       OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    miss_act_attachment_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------

PROCEDURE miss_act_attachment_rec
(
   x_act_attachment_rec  OUT NOCOPY  act_attachment_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_act_attachment_rec
--
-- PURPOSE
--    For update_act_attachment, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_act_attachment_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_act_attachment_rec
(
   p_act_attachment_rec  IN  act_attachment_rec_type,
   x_complete_rec        OUT NOCOPY  act_attachment_rec_type
);

END jtf_amv_attachment_pub;

 

/

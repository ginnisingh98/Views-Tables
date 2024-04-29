--------------------------------------------------------
--  DDL for Package AMS_ACTPARTNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTPARTNER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvapns.pls 120.0 2005/05/31 14:54:28 appldev noship $ */

TYPE act_partner_rec_type IS RECORD
(
  activity_partner_id           NUMBER,
  last_update_date              DATE,
  last_updated_by               NUMBER,
  creation_date                 DATE,
  created_by                    NUMBER,
  last_update_login             NUMBER,
  object_version_number         NUMBER,
  act_partner_used_by_id        NUMBER,
  arc_act_partner_used_by       VARCHAR2(30),
  partner_id                    NUMBER,
  partner_type                  VARCHAR2(240),
  description                   VARCHAR2(4000),
  attribute_category            VARCHAR2(30),
  primary_flag                  VARCHAR2(1),
  preferred_vad_id              NUMBER,
  partner_party_id              NUMBER,
  partner_address_id            NUMBER,
  primary_contact_id            NUMBER,
  attribute1                    VARCHAR2(150),
  attribute2                    VARCHAR2(150),
  attribute3                    VARCHAR2(150),
  attribute4                    VARCHAR2(150),
  attribute5                    VARCHAR2(150),
  attribute6                    VARCHAR2(150),
  attribute7                    VARCHAR2(150),
  attribute8                    VARCHAR2(150),
  attribute9                    VARCHAR2(150),
  attribute10                   VARCHAR2(150),
  attribute11                   VARCHAR2(150),
  attribute12                   VARCHAR2(150),
  attribute13                   VARCHAR2(150),
  attribute14                   VARCHAR2(150),
  attribute15                   VARCHAR2(150)
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_act_partner
--
-- PURPOSE
--    Create a new partner association.
--
-- PARAMETERS
--    p_act_partner_rec: the new record to be inserted
--    x_act_partner_id: return the activity_partner_id of the new activity partner
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If activity_partner_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If activity_partner_id is not passed in, generate a unique one from
--       the sequence.
--    4. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

PROCEDURE create_act_partner
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,

  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,

  p_act_partner_rec     IN  act_partner_rec_type,
  x_act_partner_id      OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_act_partner
--
-- PURPOSE
--    Update an activity partner.
--
-- PARAMETERS
--    p_act_partner_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------

PROCEDURE update_act_partner
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_validation_level    IN  NUMBER   := FND_API.g_valid_level_full,
  --p_object_version_number IN NUMBER,

  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,

  p_act_partner_rec     IN  act_partner_rec_type
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_act_partner
--
-- PURPOSE
--    Delete an acticity partner.
--
-- PARAMETERS
--    p_act_partner_id: the act_partner_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE delete_act_partner
(
  p_api_version     IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2 := FND_API.g_false,
  p_commit          IN  VARCHAR2 := FND_API.g_false,

  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,

  p_act_partner_id  IN  NUMBER,
  p_object_version  IN  NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    lock_act_partner
--
-- PURPOSE
--    Lock an activity_partner.
--
-- PARAMETERS
--    p_act_partner_id: the act_partner_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------

PROCEDURE lock_act_partner
(
   p_api_version    IN  NUMBER,
   p_init_msg_list  IN  VARCHAR2 := FND_API.g_false,

   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,

   p_act_partner_id IN  NUMBER,
   p_object_version IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    validate_act_partner
--
-- PURPOSE
--    Validate an activity partner record.
--
-- PARAMETERS
--    p_act_partner_rec: the activity partner record to be validated
--
-- NOTES
--    1. p_act_partner_rec should be the complete activity partner record.
--       There should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------

PROCEDURE validate_act_partner
(
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2  := FND_API.g_false,
   p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,

   p_act_partner_rec    IN  act_partner_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_partner_items
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------
PROCEDURE check_act_partner_items
(
   p_act_partner_rec    IN  act_partner_rec_type,
   p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status      OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_act_partner_record
--
-- HISTORY
--    04/24/2000    khung@us    created
---------------------------------------------------------------------

PROCEDURE check_act_partner_record
(
   p_act_partner_rec    IN  act_partner_rec_type,
   p_complete_rec       IN  act_partner_rec_type := NULL,
   x_return_status      OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    init_act_partner_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_act_partner_rec(
   x_act_partner_rec    OUT NOCOPY act_partner_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    complete_act_partner_rec
--
-- PURPOSE
--    For update_act_partner, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_act_partner_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_act_partner_rec
(
   p_act_partner_rec  IN  act_partner_rec_type,
   x_complete_rec     OUT NOCOPY act_partner_rec_type
);

END AMS_ActPartner_PVT;

 

/

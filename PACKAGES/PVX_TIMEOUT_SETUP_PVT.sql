--------------------------------------------------------
--  DDL for Package PVX_TIMEOUT_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_TIMEOUT_SETUP_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvtmos.pls 115.11 2002/12/11 11:13:03 anubhavk ship $ */

TYPE timeout_setup_rec_type IS RECORD
(
 TIMEOUT_ID                    NUMBER,
 LAST_UPDATE_DATE               DATE,
 LAST_UPDATED_BY                NUMBER,
 CREATION_DATE                  DATE,
 CREATED_BY                     NUMBER,
 LAST_UPDATE_LOGIN              NUMBER,
 OBJECT_VERSION_NUMBER          NUMBER,
 TIMEOUT_PERIOD                 NUMBER,
 TIMEOUT_TYPE                   VARCHAR2(30),
 COUNTRY_CODE                   VARCHAR2(15)
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_timeout_setup
--
-- PURPOSE
--    Create a new timeout in admin setup
--
-- PARAMETERS
--    p_timeout_setup_rec: the new record to be inserted
--    x_timeout_setup_id: return the timeout_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If timeout_id is not passed in, generate a unique one from
--       the sequence.
--    3. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_setup_rec IN  timeout_setup_rec_type
  ,x_timeout_setup_id  OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_timeout_setup
--
-- PURPOSE
--    Delete a timeout_setup.
--
-- PARAMETERS
--    p_timeout_id: the timeout_id indicating the row to be deleted
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_id        IN  NUMBER
  ,p_object_version    IN  NUMBER

);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_timeout_setup
--
-- PURPOSE
--    Update a  timeout_setup.
--
-- PARAMETERS
--    p_timeout_setup_rec: the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_timeout_setup_rec IN  timeout_setup_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_timeout_setup
--
-- PURPOSE
--    Validate a timeout_setup record.
--
-- PARAMETERS
--    p_timeout_setup_rec: the  record to be validated
--
-- NOTES
--    1. p_timeout_setup_rec should be the complete  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_timeout_setup(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_timeout_setup_rec   IN  timeout_setup_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_timeout_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_timeout_setup_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_timeout_items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,p_timeout_setup_rec IN  timeout_setup_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_timeout_rec
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_timeout_setup_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_timeout_rec(
   p_timeout_setup_rec IN timeout_setup_rec_type
  ,p_complete_rec     IN  timeout_setup_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_timeout_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_timeout_rec(
   x_timeout_setup_rec   OUT NOCOPY  timeout_setup_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_timeout_rec
--
-- PURPOSE
--    For update, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_timeout_setup_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_timeout_rec(
   p_timeout_setup_rec IN  timeout_setup_rec_type
  ,x_complete_rec    OUT NOCOPY timeout_setup_rec_type
);


END PVX_timeout_setup_PVT;

 

/

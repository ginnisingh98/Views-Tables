--------------------------------------------------------
--  DDL for Package AMS_EVENTHEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTHEADER_PUB" AUTHID CURRENT_USER AS
/* $Header: amspevhs.pls 115.3 2002/11/16 00:42:55 dbiswas ship $ */


---------------------------------------------------------------------
-- PROCEDURE
--    create_EventHeader
--
-- PURPOSE
--    Create a new EventHeader.
--
-- PARAMETERS
--    p_evh_rec: the new record to be inserted
--    x_evh_id: return the EventHeader_id of the new EventHeader
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If EventHeader_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If EventHeader_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE create_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type,
   x_evh_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_EventHeader
--
-- PURPOSE
--    Delete a EventHeader.
--
-- PARAMETERS
--    p_evh_id: the EventHeader_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the EventHeader to be inactive, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_EventHeader
--
-- PURPOSE
--    Lock a EventHeader.
--
-- PARAMETERS
--    p_evh_id: the EventHeader_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_EventHeader
--
-- PURPOSE
--    Update a EventHeader.
--
-- PARAMETERS
--    p_evh_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_EventHeader
--
-- PURPOSE
--    Validate a EventHeader record.
--
-- PARAMETERS
--    p_evh_rec: the EventHeader record to be validated
--
-- NOTES
--    1. p_evh_rec should be the complete EventHeader record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_EventHeader(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evh_rec          IN  AMS_EventHeader_PVT.evh_rec_type
);


END AMS_EventHeader_PUB;

 

/

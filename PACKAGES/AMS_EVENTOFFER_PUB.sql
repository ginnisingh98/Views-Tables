--------------------------------------------------------
--  DDL for Package AMS_EVENTOFFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTOFFER_PUB" AUTHID CURRENT_USER AS
/* $Header: amspevos.pls 115.3 2002/12/02 20:30:39 dbiswas ship $ */


---------------------------------------------------------------------
-- PROCEDURE
--    create_EventOffer
--
-- PURPOSE
--    Create a new EventOffer.
--
-- PARAMETERS
--    p_evo_rec: the new record to be inserted
--    x_evo_id: return the EventOffer_id of the new EventOffer
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If EventOffer_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If EventOffer_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE create_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type,
   x_evo_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_EventOffer
--
-- PURPOSE
--    Delete a EventOffer.
--
-- PARAMETERS
--    p_evo_id: the EventOffer_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the EventOffer to be inactive, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_EventOffer
--
-- PURPOSE
--    Lock a EventOffer.
--
-- PARAMETERS
--    p_evo_id: the EventOffer_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_EventOffer
--
-- PURPOSE
--    Update a EventOffer.
--
-- PARAMETERS
--    p_evo_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_EventOffer
--
-- PURPOSE
--    Validate a EventOffer record.
--
-- PARAMETERS
--    p_evo_rec: the EventOffer record to be validated
--
-- NOTES
--    1. p_evo_rec should be the complete EventOffer record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_EventOffer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_evo_rec          IN  AMS_EventOffer_PVT.evo_rec_type
);


END AMS_EventOffer_PUB;

 

/

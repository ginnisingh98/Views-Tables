--------------------------------------------------------
--  DDL for Package AMS_CHANNEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CHANNEL_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvchas.pls 115.14 2002/11/22 23:38:11 dbiswas ship $ */


TYPE chan_rec_type IS RECORD(
CHANNEL_ID                               NUMBER,
LAST_UPDATE_DATE                         DATE,
LAST_UPDATED_BY                          NUMBER,
CREATION_DATE                            DATE,
CREATED_BY                               NUMBER,
LAST_UPDATE_LOGIN                        NUMBER,
OBJECT_VERSION_NUMBER                    NUMBER,
CHANNEL_TYPE_CODE                        VARCHAR2(30),
ORDER_SEQUENCE                           NUMBER,
MANAGED_BY_PERSON_ID                     NUMBER,
OUTBOUND_FLAG                            VARCHAR2(1),
INBOUND_FLAG                             VARCHAR2(1),
ACTIVE_FROM_DATE                         DATE,
ACTIVE_TO_DATE                           DATE,
RATING                                   VARCHAR2(30),
PREFERRED_VENDOR_ID                      NUMBER,
PARTY_ID				 NUMBER,
ATTRIBUTE_CATEGORY                       VARCHAR2(30),
ATTRIBUTE1                               VARCHAR2(150),
ATTRIBUTE2                               VARCHAR2(150),
ATTRIBUTE3                               VARCHAR2(150),
ATTRIBUTE4                               VARCHAR2(150),
ATTRIBUTE5                               VARCHAR2(150),
ATTRIBUTE6                               VARCHAR2(150),
ATTRIBUTE7                               VARCHAR2(150),
ATTRIBUTE8                               VARCHAR2(150),
ATTRIBUTE9                               VARCHAR2(150),
ATTRIBUTE10                              VARCHAR2(150),
ATTRIBUTE11                              VARCHAR2(150),
ATTRIBUTE12                              VARCHAR2(150),
ATTRIBUTE13                              VARCHAR2(150),
ATTRIBUTE14                              VARCHAR2(150),
ATTRIBUTE15                              VARCHAR2(150),
CHANNEL_NAME                             VARCHAR2(120),
DESCRIPTION                              VARCHAR2(4000),
--rrajesh added on 12/07/00
COUNTRY_ID				 NUMBER
-- removed by Rahul Sharma on 01/18/2001
-- INTERNAL_RESOURCE	                 VARCHAR2(120)
-- end 01/18/2001
--end 12/07/00
);


---------------------------------------------------------------------
-- PROCEDURE
--    create_channel
--
-- PURPOSE
--    Create a new channel.
--
-- PARAMETERS
--    p_chan_rec: the new record to be inserted
--    x_chan_id: return the channel_id of the new channel
--
-- NOTES
--    1. Please don't pass in any FND_API.g_mess_char/num/date.
--    2. object_version_number will be set to 1.
--    3. If channel_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates. If channel_id is not
--       passed in, generate a unique one from the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag. If a flag column is not
--       passed in, default it to 'Y' or 'N'.
---------------------------------------------------------------------
PROCEDURE create_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type,
   x_chan_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_channel
--
-- PURPOSE
--    Set the channel to be inactive so that it won't be available
--    to users.
--
-- PARAMETERS
--    p_chan_id: the channel_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the channel to be inactive, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_channel
--
-- PURPOSE
--    Lock a channel.
--
-- PARAMETERS
--    p_chan_id: the channel_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_channel
--
-- PURPOSE
--    Update a channel.
--
-- PARAMETERS
--    p_chan_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_channel
--
-- PURPOSE
--    Validate a channel record.
--
-- PARAMETERS
--    p_chan_rec: the record to be validated
--
-- NOTES
--    1. p_chan_rec should be the complete channel record wothout
--       any FND_API.g_miss_char/num/date items.
----------------------------------------------------------------------
PROCEDURE validate_channel(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_chan_rec          IN  chan_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_chan_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_chan_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_chan_items(
   p_chan_rec        IN  chan_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);



---------------------------------------------------------------------
-- PROCEDURE
--    init_chan_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_chan_rec(
   x_chan_rec         OUT NOCOPY  chan_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_chan_rec
--
-- PURPOSE
--    For update_channel, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_chan_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--
-- NOTES
--    1. If a valid status_date is provided, use it. If not, set it
--       to be the original value or SYSDATE depending on whether
--       the user_status_id is changed or not.
---------------------------------------------------------------------
PROCEDURE complete_chan_rec(
   p_chan_rec       IN  chan_rec_type,
   x_complete_rec   OUT NOCOPY chan_rec_type
);


---------------------------------------------------------------------
-- FUNCTION
--    get_party_name
-- DESCRIPTION
--    Given a party id, returns the party_name from
--    HZ_PARTIES.
---------------------------------------------------------------------
FUNCTION get_party_name (
   p_party_id IN NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_party_name, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--    get_party_number
-- DESCRIPTION
--    Given a party id, returns the party_number from
--    HZ_PARTIES.
---------------------------------------------------------------------
FUNCTION get_party_number (
   p_party_id IN NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_party_number, WNDS);


---------------------------------------------------------------------
-- FUNCTION
--    get_party_type
-- DESCRIPTION
--    Given a party id, returns the party_type from
--    HZ_PARTIES.
---------------------------------------------------------------------
FUNCTION get_party_type (
   p_party_id IN NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_party_type, WNDS);



---------------------------------------------------------------------
-- FUNCTION
--    get_vendor_name
-- DESCRIPTION
--    Given a party id, returns the vendor_name from
--    po_vendors.
---------------------------------------------------------------------
FUNCTION get_vendor_name (
   p_vendor_id IN NUMBER
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_vendor_name, WNDS);

---------------------------------------------------------------------
-- FUNCTION
--    get_country_name
-- DESCRIPTION
--    Given a country id, returns the country_name from
--    jtf_loc_areas_vl.
---------------------------------------------------------------------
FUNCTION get_country_name (
   p_country_id IN NUMBER
)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(get_country_name, WNDS);

END AMS_CHANNEL_PVT;


 

/

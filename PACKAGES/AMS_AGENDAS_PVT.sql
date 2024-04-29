--------------------------------------------------------
--  DDL for Package AMS_AGENDAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_AGENDAS_PVT" AUTHID CURRENT_USER as
/*$Header: amsvagns.pls 115.4 2003/03/28 23:20:09 soagrawa ship $*/

TYPE agenda_rec_type IS RECORD(
 AGENDA_ID                 NUMBER,
 SETUP_TYPE_ID             NUMBER,
 LAST_UPDATE_DATE          DATE,
 LAST_UPDATED_BY           NUMBER,
 CREATION_DATE             DATE,
 CREATED_BY                NUMBER,
 LAST_UPDATE_LOGIN         NUMBER,
 OBJECT_VERSION_NUMBER     NUMBER,
 APPLICATION_ID            NUMBER,
 ACTIVE_FLAG               VARCHAR2(1),
 DEFAULT_TRACK_FLAG        VARCHAR2(1),
 AGENDA_TYPE               VARCHAR2(30),
 ROOM_ID                   NUMBER ,
 START_DATE_TIME           DATE,
 END_DATE_TIME             DATE,
 COORDINATOR_ID            NUMBER,
 TIMEZONE_ID               NUMBER,
 PARENT_TYPE               VARCHAR2(30),
 PARENT_ID                 NUMBER,
 ATTRIBUTE_CATEGORY        VARCHAR2(30),
 ATTRIBUTE1                VARCHAR2(150),
 ATTRIBUTE2                VARCHAR2(150),
 ATTRIBUTE3                VARCHAR2(150),
 ATTRIBUTE4                VARCHAR2(150),
 ATTRIBUTE5                VARCHAR2(150),
 ATTRIBUTE6                VARCHAR2(150),
 ATTRIBUTE7                VARCHAR2(150),
 ATTRIBUTE8                VARCHAR2(150),
 ATTRIBUTE9                VARCHAR2(150),
 ATTRIBUTE10               VARCHAR2(150),
 ATTRIBUTE11               VARCHAR2(150),
 ATTRIBUTE12               VARCHAR2(150),
 ATTRIBUTE13               VARCHAR2(150),
 ATTRIBUTE14               VARCHAR2(150),
 ATTRIBUTE15               VARCHAR2(150),
 AGENDA_NAME               VARCHAR2(240),
 DESCRIPTION               VARCHAR2(4000)
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_agenda
--
-- PURPOSE
--    Create a new  agenda item (Track/Session) for the event offer.
--
-- PARAMETERS
--    p_agenda_rec: the new record to be inserted
--    x_agenda_id: return the agenda_id of the new agenda
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If agenda_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If agenda_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

PROCEDURE create_agenda(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_agenda_rec        IN  agenda_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   x_agenda_id         OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_agenda
--
-- PURPOSE
--    Delete an agenda.
--
-- PARAMETERS
--    p_agenda_id: the agenda_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_agenda(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   p_agenda_id         IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_agenda
--
-- PURPOSE
--    Lock the agenda.
--
-- PARAMETERS
--    p_agenda_id: the agenda_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_agenda(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   p_agenda_id         IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_agenda
--
-- PURPOSE
--    Update the agenda.
--
-- PARAMETERS
--    p_agenda_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_agenda(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_agenda_rec        IN  agenda_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
   );


---------------------------------------------------------------------
-- PROCEDURE
--    validate_agenda
--
-- PURPOSE
--    Validate the agenda record.
--
-- PARAMETERS
--    p_agenda_rec: the agenda record to be validated
--
-- NOTES
--    1. p_agenda_rec should be the complete agenda record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_agenda(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_agenda_rec        IN  agenda_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_agenda_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_agenda_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE validate_agenda_items(
   p_agenda_rec      IN  agenda_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_agenda_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_agenda_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE validate_agenda_record(
   p_agenda_rec       IN  agenda_rec_type,
   p_complete_rec     IN  agenda_rec_type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_agenda_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_agenda_rec(
   p_agenda_rec         IN   agenda_rec_type,
   x_agenda_rec         OUT NOCOPY  agenda_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_agenda_rec
--
-- PURPOSE
--    For update_agenda, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_agenda_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE complete_agenda_rec(
   p_agenda_rec    IN  agenda_rec_type,
   x_agenda_rec    OUT NOCOPY agenda_rec_type
);


PROCEDURE ADD_LANGUAGE;

END AMS_AGENDAS_PVT;

 

/

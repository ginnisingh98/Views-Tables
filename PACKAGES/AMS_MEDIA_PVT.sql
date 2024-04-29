--------------------------------------------------------
--  DDL for Package AMS_MEDIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MEDIA_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmeds.pls 115.13 2002/12/18 09:26:12 cgoyal ship $ */

-----------------------------------------------------------
-- PACKAGE
--    AMS_Media_PVT
--
-- PURPOSE
--    This package is a Private API for managing Media information in
--    AMS.  It contains specification for pl/sql records and tables
--
--    AMS_MEDIA_VL:
--    Create_Media (see below for specification)
--    Update_Media (see below for specification)
--    Delete_Media (see below for specification)
--    Lock_Media (see below for specification)
--    Validate_Media (see below for specification)
--
--    Check_Media_Items (see below for specification)
--    Check_Media_Record (see below for specification)
--    Init_Media_Rec
--    Complete_Media_Rec
--
--    AMS_MEDIA_CHANNELS:
--    Create_MediaChannel
--    Update_MediaChannel
--    Delete_MediaChannel
--    Lock_MediaChannel
--    Validate_MediaChannel
--
--    Check_MediaChannel_Items
--    Check_MediaChannel_Records
--    Init_MediaChannel_Rec
--    Complete_MediaChannel_Rec
--
-- NOTES
--
--
-- HISTORY
-- 03-Nov-1999    choang      Created.
-- 10-Dec-1999    ptendulk    Modified
-----------------------------------------------------------

-------------------------------------
-----          MEDIA            -----
-------------------------------------
-- Record for AMS_MEDIA_VL
TYPE Media_Rec_Type IS RECORD (
   media_id                NUMBER,
   last_update_date        DATE,
   last_updated_by         NUMBER,
   creation_date           DATE,
   created_by              NUMBER,
   last_update_login       NUMBER,
   object_version_number   NUMBER,
   media_type_code         VARCHAR2(30),
   media_type_name         VARCHAR2(80),
   inbound_flag            VARCHAR2(1),
   enabled_flag            VARCHAR2(1),
   attribute_category      VARCHAR2(30),
   attribute1              VARCHAR2(150),
   attribute2              VARCHAR2(150),
   attribute3              VARCHAR2(150),
   attribute4              VARCHAR2(150),
   attribute5              VARCHAR2(150),
   attribute6              VARCHAR2(150),
   attribute7              VARCHAR2(150),
   attribute8              VARCHAR2(150),
   attribute9              VARCHAR2(150),
   attribute10             VARCHAR2(150),
   attribute11             VARCHAR2(150),
   attribute12             VARCHAR2(150),
   attribute13             VARCHAR2(150),
   attribute14             VARCHAR2(150),
   attribute15             VARCHAR2(150),
   media_name              VARCHAR2(120),
   description             VARCHAR2(4000)
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Media
--
-- PURPOSE
--    Create media entry.
--
-- PARAMETERS
--    p_media_rec: the record representing AMS_MEDIA_VL view..
--    x_media_id: the media_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If media_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If import_list_header_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type,
   x_media_id          OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Media
--
-- PURPOSE
--    Update a media entry.
--
-- PARAMETERS
--    p_media_rec: the record representing AMS_MEDIA_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Media
--
-- PURPOSE
--    Delete a media entry.
--
-- PARAMETERS
--    p_media_id: the media_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Media
--
-- PURPOSE
--    Lock a media entry.
--
-- PARAMETERS
--    p_media_id: the media
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Media
--
-- PURPOSE
--    Validate a media entry.
--
-- PARAMETERS
--    p_media_rec: the record representing AMS_MEDIA_VL (without ROW_ID).
--
-- NOTES
--    1. p_media_rec should be the complete media record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_Media (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_media_rec         IN  Media_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Media_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_media_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Media_Items (
   p_media_rec       IN  Media_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Media_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_media_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Media_Record (
   p_media_rec        IN  Media_Rec_Type,
   p_complete_rec     IN  Media_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Media_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Media_Rec (
   x_media_rec         OUT NOCOPY  Media_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Media_Rec
--
-- PURPOSE
--    For Update_Media, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_media_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Media_Rec (
   p_media_rec      IN  Media_Rec_Type,
   x_complete_rec   OUT NOCOPY Media_Rec_Type
);


-------------------------------------
-------     MEDIA CHANNEL      ------
-------------------------------------
-- Record declaration for AMS_MEDIA_CHANNELS
TYPE MediaChannel_Rec_Type IS RECORD (
   media_channel_id        NUMBER,
   last_update_date        DATE,
   last_updated_by         NUMBER,
   creation_date           DATE,
   created_by              NUMBER,
   last_update_login       NUMBER,
   object_version_number   NUMBER,
   media_id                NUMBER,
   channel_id              NUMBER,
   active_from_date        DATE,
   active_to_date          DATE
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_MediaChannel
--
-- PURPOSE
--    Create media channel entry.
--
-- PARAMETERS
--    p_mediachl_rec: the record representing AMS_MEDIA_CHANNELS view..
--    x_mediachl_id: the media_channel_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If ID is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If import_list_header_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type,
   x_mediachl_id       OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_MediaChannel
--
-- PURPOSE
--    Update a media channel entry.
--
-- PARAMETERS
--    p_mediachl_rec: the record representing AMS_MEDIA_CHANNELS (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Delete_MediaChannel
--
-- PURPOSE
--    Delete a media channel entry.
--
-- PARAMETERS
--    p_mediachl_id: the mediachl_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_id       IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_MediaChannel
--
-- PURPOSE
--    Lock a media channel entry.
--
-- PARAMETERS
--    p_mediachl_id: the media
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_id       IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_MediaChannel
--
-- PURPOSE
--    Validate a media channel entry.
--
-- PARAMETERS
--    p_mediachl_rec: the record representing AMS_MEDIA_CHANNELS (without ROW_ID).
--
-- NOTES
--    1. p_mediachl_rec should be the complete media channel record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_MediaChannel (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_mediachl_rec      IN  MediaChannel_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_MediaChannel_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_mediachl_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Items (
   p_mediachl_rec    IN  MediaChannel_Rec_Type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_MediaChannel_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_mediachl_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_MediaChannel_Record (
   p_mediachl_rec     IN  MediaChannel_Rec_Type,
   p_complete_rec     IN  MediaChannel_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_MediaChannel_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_MediaChannel_Rec (
   x_mediachl_rec         OUT NOCOPY  MediaChannel_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_MediaChannel_Rec
--
-- PURPOSE
--    For Update_MediaChannel, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_mediachl_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_MediaChannel_Rec (
   p_mediachl_rec   IN  MediaChannel_Rec_Type,
   x_complete_rec   OUT NOCOPY MediaChannel_Rec_Type
);


END AMS_Media_PVT;

 

/

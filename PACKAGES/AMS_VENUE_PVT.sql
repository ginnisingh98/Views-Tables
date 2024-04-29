--------------------------------------------------------
--  DDL for Package AMS_VENUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_VENUE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvvnus.pls 120.1 2005/08/12 09:00:34 appldev ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AMS_Venue_PVT
--
-- PURPOSE
--    This package is a Private API for managing Venue information in
--    AMS.  It contains specification for pl/sql records and tables
--
--    AMS_VENUES_VL:
--    Create_Venue (see below for specification)
--    Update_Venue (see below for specification)
--    Delete_Venue (see below for specification)
--    Lock_Venue (see below for specification)
--    Validate_Venue (see below for specification)
--
--    Check_Venue_Items (see below for specification)
--    Check_Venue_Record (see below for specification)
--    Init_Venue_Rec
--    Complete_Venue_Rec
--

-- NOTES
--
--
-- HISTORY
-- 10-Dec-1999    rvaka       Modified
-- 19-APR-2002    dcastlem    TCA integration
-----------------------------------------------------------

-------------------------------------
-----          VENUE            -----
-------------------------------------
-- Record for AMS_VENUE_VL
TYPE Venue_Rec_Type IS RECORD (
   venue_id                NUMBER,
   custom_setup_id         NUMBER,
   last_update_date        DATE,
   last_updated_by         NUMBER,
   creation_date           DATE,
   created_by              NUMBER,
   last_update_login       NUMBER,
   object_version_number   NUMBER,
   venue_type_code         VARCHAR2(30),
   venue_type_name         VARCHAR2(80),
   direct_phone_flag       VARCHAR2(1),
   internal_flag           VARCHAR2(1),
   enabled_flag            VARCHAR2(1),
   rating_code             VARCHAR2(30),
   telecom_code            VARCHAR2(30),
   rating_name             varchar2(80),
   capacity	 		NUMBER,
   area_size		 	NUMBER,
   area_size_uom_code		VARCHAR2(3),
   ceiling_height		NUMBER,
   ceiling_height_uom_code	VARCHAR2(3),
   usage_cost		        NUMBER,
   usage_cost_uom_code	        VARCHAR2(30),
   usage_cost_currency_code	VARCHAR2(15),
   parent_venue_id		NUMBER,
   location_id			NUMBER,
   directions	 		VARCHAR2(4000),
   venue_code			VARCHAR2(30),
   object_type       VARCHAR2(30),
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
   venue_name              VARCHAR2(120),
   party_id                NUMBER,
   description             VARCHAR2(4000),
       ADDRESS1			VARCHAR2(240),
       ADDRESS2			VARCHAR2(240),
       ADDRESS3			VARCHAR2(240),
       ADDRESS4			VARCHAR2(240),
       COUNTRY_CODE		VARCHAR2(80),
       COUNTRY			VARCHAR2(60),
       CITY			VARCHAR2(60),
       POSTAL_CODE		VARCHAR2(60),
       STATE			VARCHAR2(60),
       PROVINCE			VARCHAR2(60),
       COUNTY			VARCHAR2(60),
   salesforce_id           NUMBER,
   sales_group_id          NUMBER,
   person_id               NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Create_Venue
--
-- PURPOSE
--    Create Venue entry.
--
-- PARAMETERS
--    p_venue_rec: the record representing AMS_VENUE_VL view..
--    x_venue_id: the venue_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If venue_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If a flag column is passed in, check if it is 'Y' or 'N'
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'
--    6. Please don't pass in any FND_API.g_miss_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   x_venue_id          OUT NOCOPY NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Create_Room
--
-- PURPOSE
--    Create ROOM entry.
--
-- PARAMETERS
--    p_venue_rec: the record representing AMS_VENUE_VL view..
--    x_venue_id: the venue_id.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If venue_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If a flag column is passed in, check if it is 'Y' or 'N'
--       Raise exception for invalid flag.
--    4. If a flag column is not passed in, default it to 'Y' or 'N'
--    5. Please don't pass in any FND_API.g_miss_char/num/date.
--------------------------------------------------------------------
PROCEDURE Create_Room (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type,
   x_venue_id          OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Update_Venue
--
-- PURPOSE
--    Update a venue entry.
--
-- PARAMETERS
--    p_venue_rec: the record representing AMS_VENUE_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type
);

--------------------------------------------------------------------
-- PROCEDURE
--    Update_Room
--
-- PURPOSE
--    Update a room entry.
--
-- PARAMETERS
--    p_venue_rec: the record representing AMS_VENUE_VL (without the ROW_ID column).
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
--------------------------------------------------------------------
PROCEDURE Update_Room (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_rec         IN  Venue_Rec_Type
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Venue
--
-- PURPOSE
--    Delete a venue entry.
--
-- PARAMETERS
--    p_venue_id: the venue_id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Lock_Venue
--
-- PURPOSE
--    Lock a venue entry.
--
-- PARAMETERS
--    p_venue_id: the venue id
--    p_object_version: the object_version_number
--
-- ISSUES
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_venue_id          IN  NUMBER,
   p_object_version    IN  NUMBER
);

--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Venue
--
-- PURPOSE
--    Validate a Venue entry.
--
-- PARAMETERS
--    p_Venue_rec: the record representing AMS_Venue_VL (without ROW_ID).
--
-- NOTES
--    1. p_Venue_rec should be the complete Venue record. There
--       should not be any FND_API.g_miss_char/num/date in it.
--    2. If FND_API.g_miss_char/num/date is in the record, then raise
--       an exception, as those values are not handled.
--------------------------------------------------------------------
PROCEDURE Validate_Venue (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Venue_rec         IN  Venue_Rec_Type,
   p_object_type       IN  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Venue_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_Venue_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Venue_Items (
   p_Venue_rec       IN  Venue_Rec_Type,
   p_object_type     IN  VARCHAR2,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Venue_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_Venue_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Venue_Record (
   p_Venue_rec        IN  Venue_Rec_Type,
   p_complete_rec     IN  Venue_Rec_Type := NULL,
   x_return_status    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_Venue_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Venue_Rec (
   x_Venue_rec         OUT NOCOPY  Venue_Rec_Type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Venue_Rec
--
-- PURPOSE
--    For Update_Venue, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_Venue_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Venue_Rec (
   p_Venue_rec      IN  Venue_Rec_Type,
   x_complete_rec   OUT NOCOPY Venue_Rec_Type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Location
--
-- PURPOSE
-- Create the location info in HZ_LOCATIONS using call to
-- hz_location_pub.create_location
--
-- PARAMETERS
--    p_Venue_loc_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
-- HZ_PARTY_PUB.G_MISS_CONTENT_SOURCE_TYPE BugFix sikalyan TCAV2 Uptake
---------------------------------------------------------------------
TYPE Location_Rec_Type IS RECORD
(
       LOCATION_ID		NUMBER := FND_API.G_MISS_NUM,
       ADDRESS1			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS2			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS3			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS4			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COUNTRY_CODE		VARCHAR2(80) := FND_API.G_MISS_CHAR,
       COUNTRY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       CITY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       POSTAL_CODE		VARCHAR2(60) := FND_API.G_MISS_CHAR,
       STATE			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PROVINCE			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       COUNTY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       ORIG_SYSTEM_REFERENCE    VARCHAR2(240):=  FND_API.G_MISS_CHAR,
       CONTENT_SOURCE_TYPE     VARCHAR2(30):= HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE

);



END AMS_Venue_PVT;

 

/

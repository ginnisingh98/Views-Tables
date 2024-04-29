--------------------------------------------------------
--  DDL for Package AMS_WEBMARKETING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WEBMARKETING_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwpps.pls 120.1 2005/08/04 21:51:31 appldev noship $ */


 TYPE  web_mp_track_rec_type   IS   RECORD(
		   application_id		 NUMBER ,
                   placement_id        NUMBER ,
		   placement_citem_id   NUMBER ,
  		   placement_mp_id        NUMBER ,
		   content_item_id    NUMBER ,
		   citem_version_id  NUMBER ,
		   display_priority  NUMBER ,
		   publish_flag  VARCHAR2(1) ,
		   activity_id  NUMBER ,
		   max_recommendations  NUMBER ,
		   object_used_by_id  NUMBER ,
		   object_used_by  VARCHAR2(30) ,
		   security_group_id  NUMBER ,
		   object_version_number  NUMBER ,
		   creation_date DATE ,
		   creation_by  NUMBER ,
		   attribute_category  VARCHAR2(30) ,
		   attribute1  VARCHAR2(150) ,
		  attribute2  VARCHAR2(150) ,
		   attribute3  VARCHAR2(150) ,
		  attribute4  VARCHAR2(150) ,
		  attribute5  VARCHAR2(150) ,
		  attribute6  VARCHAR2(150) ,
		  attribute7  VARCHAR2(150) ,
		  attribute8  VARCHAR2(150) ,
		  attribute9  VARCHAR2(150) ,
		  attribute10  VARCHAR2(150) ,
		  attribute11  VARCHAR2(150) ,
		  attribute12  VARCHAR2(150) ,
		  attribute13  VARCHAR2(150) ,
		  attribute14  VARCHAR2(150) ,
		  attribute15  VARCHAR2(150) ,
		  content_type_code  VARCHAR2(100) ,
		  placement_mp_title  VARCHAR2(240) ,
		  last_update_date  DATE ,
		  last_updated_by  NUMBER ,
		  last_update_login  NUMBER
	);


g_miss_web_mp_track_rec          web_mp_track_rec_type;
TYPE  web_mp_track_tbl_type      IS TABLE OF web_mp_track_rec_type INDEX BY BINARY_INTEGER;
g_miss_web_mp_track_tbl         web_mp_track_tbl_type;

-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
-- ========================================================================

	PROCEDURE CREATE_WEB_PLCE_ASSOC (
		 p_api_version_number    IN  NUMBER := 1.0,
		 p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE,
		 p_commit                    IN  VARCHAR2  := FND_API.G_FALSE,
		 p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 p_web_mp_rec             IN  web_mp_track_rec_type := g_miss_web_mp_track_rec,
		 x_placement_mp_id     OUT NOCOPY  NUMBER,
		 x_placement_citem_id_tbl  OUT NOCOPY JTF_NUMBER_TABLE,
		 x_msg_count              OUT NOCOPY  NUMBER,
		 x_msg_data                OUT NOCOPY  VARCHAR2,
		 x_return_status           OUT NOCOPY VARCHAR2
	);



-- ========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     WebMarketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
-- ========================================================================

	PROCEDURE  WEBMARKETING_PLCE_CONTENT_TYPE (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_commit                      IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_placement_mp_id       IN  NUMBER,
	   placement_id           IN NUMBER,
	   x_content_type  OUT  NOCOPY VARCHAR2,
	   x_msg_count           OUT NOCOPY  NUMBER,
	   x_msg_data              OUT NOCOPY  VARCHAR2,
	   x_return_status          OUT NOCOPY VARCHAR2
	);


-- ========================================================================
-- PROCEDURE
--    Integration API Call for WebPlacement Content Status for Approval Process- ->
--     WebMarketing integration call
-- Purpose
--    WebMarketing integration call  for Campaign Activity Approval Process
-- HISTORY
--
-- ========================================================================

	PROCEDURE  WEBMARKETING_CONTENT_STATUS (
	   p_api_version_number    IN  NUMBER := 1.0,
	   p_init_msg_list              IN  VARCHAR2  := FND_API.G_FALSE,
	   p_validation_level            IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_campaign_activity_id       IN  NUMBER,
	   x_msg_count           OUT NOCOPY  NUMBER,
	   x_msg_data              OUT NOCOPY  VARCHAR2,
	   x_return_status          OUT NOCOPY VARCHAR2
	);




END  AMS_WEBMARKETING_PVT;

 

/

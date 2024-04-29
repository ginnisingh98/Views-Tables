--------------------------------------------------------
--  DDL for Package CS_SR_PREFERRED_LANG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_PREFERRED_LANG_PVT" AUTHID CURRENT_USER AS
/* $Header: csvprls.pls 120.0 2006/03/23 11:26:08 spusegao noship $ */


--------------------------------------------------------------------------
-- Start of comments
--  Record Type     : Preferred_Language_Rec_Type
--  Description     : Holds the Preferred Language attributes
--  Fields     :
--
-- End of preferred_language_rec_type comments
--------------------------------------------------------------
TYPE preferred_language_rec_type IS RECORD (
 ROW_ID                                   VARCHAR2(64),
 PREF_LANG_ID                             NUMBER,
 LANGUAGE_CODE                            VARCHAR2(4),
 START_DATE_ACTIVE                        DATE,
 END_DATE_ACTIVE                          DATE,
 OBJECT_VERSION_NUMBER                    NUMBER,
 LAST_UPDATE_DATE                         DATE,
 LAST_UPDATED_BY                          NUMBER,
 CREATION_DATE                            DATE,
 CREATED_BY                               NUMBER,
 LAST_UPDATE_LOGIN                        NUMBER,
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
 ATTRIBUTE_CATEGORY                       VARCHAR2(150),
 INITIALIZE_FLAG                          VARCHAR2(1)
);


--This declaration is for the internal user hooks
user_hooks_rec    preferred_language_rec_type;



PROCEDURE initialize_rec(
  p_preferred_lang_record        IN OUT NOCOPY preferred_language_rec_type
);




--------------------------------------------------------------------------
-- Start of comments
--  API name	: Create_Preferred_Language
--  Type	: Private
--  Function	: Creates language preference rows in CS_SR_PREFERRED_LANG
--  Pre-reqs	: None.
--
--  Standard IN Parameters:
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level		IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters:
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--
--  IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional
--	p_user_id			IN	NUMBER		Required
--		Application user identifier
--        Valid user from fnd_user
--	p_login_id			IN	NUMBER		Optional
--		Identifier of login session
--	p_org_id			IN	NUMBER		Optional
--		Operating unit identifier
--
--      p_preferred_language_rec        IN      preferred_language_rec_type Required
--
-- End of comments
--------------------------------------------------------------------------




PROCEDURE Create_Preferred_Language(
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_preferred_language_rec IN    preferred_language_rec_type
);


--------------------------------------------------------------------------
-- Start of comments
--  API name	: Update_Preferred_Language
--  Type	: Private
--  Function	: Updates a preferred language row in CS_SR_PREFERRED_LANG
--  Pre-reqs	: None.
--  Parameters	:
--  IN		:
--	p_api_version		  	IN	NUMBER		Required
--	p_init_msg_list		  	IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_commit		  	IN	VARCHAR2	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level	  	IN	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--      p_pref_lang_id                  IN      NUMBER          Required
--      p_object_version_number         IN      NUMBER          Required for Web-Apps
--	p_resp_appl_id			IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional
--      p_user_id                       IN      NUMBER          Required
--      p_login_id                      IN      NUMBER          Optional
--	p_last_updated_by		IN	NUMBER		Required
--	p_last_update_login		IN	NUMBER		Optional
--		Default = NULL
--	p_last_update_date		IN	DATE		Required
--      p_preferred_language_rec        IN      preferred_language_rec_type  Required


--  OUT		:
--	x_return_status			OUT	VARCHAR2(1)	Required
--	x_msg_count			OUT	NUMBER		Required
--	x_msg_data			OUT	VARCHAR2(2000)	Required
--
--  Version	: Current version	1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------




PROCEDURE Update_Preferred_Language
  ( p_api_version		    IN	NUMBER,
    p_init_msg_list		    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit			    IN	VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level	            IN	NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		            OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_pref_lang_id                  IN  NUMBER,
    p_object_version_number         IN  NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_user_id                       IN  NUMBER,
    p_login_id                      IN  NUMBER   DEFAULT NULL,
    p_last_updated_by	            IN	NUMBER,
    p_last_update_login	            IN	NUMBER   DEFAULT NULL,
    p_last_update_date	            IN	DATE,
    p_preferred_language_rec        IN  preferred_language_rec_type
    );



-- Lock row procedure
-- This is used to lock a row in the Preferred Language form

PROCEDURE LOCK_ROW(
		    p_PREF_LANG_ID		IN	NUMBER,
		    p_OBJECT_VERSION_NUMBER	IN	NUMBER,
                    p_preferred_language_rec    IN      preferred_language_rec_type
			    );

-- -------------------------------------------------------------------
-- Validate_Desc_Flex
-- -------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
( p_api_name                    IN      VARCHAR2,
  p_application_short_name      IN      VARCHAR2,
  p_desc_flex_name              IN      VARCHAR2,
  p_desc_segment1               IN      VARCHAR2,
  p_desc_segment2               IN      VARCHAR2,
  p_desc_segment3               IN      VARCHAR2,
  p_desc_segment4               IN      VARCHAR2,
  p_desc_segment5               IN      VARCHAR2,
  p_desc_segment6               IN      VARCHAR2,
  p_desc_segment7               IN      VARCHAR2,
  p_desc_segment8               IN      VARCHAR2,
  p_desc_segment9               IN      VARCHAR2,
  p_desc_segment10              IN      VARCHAR2,
  p_desc_segment11              IN      VARCHAR2,
  p_desc_segment12              IN      VARCHAR2,
  p_desc_segment13              IN      VARCHAR2,
  p_desc_segment14              IN      VARCHAR2,
  p_desc_segment15              IN      VARCHAR2,
  p_desc_context                IN      VARCHAR2,
  p_resp_appl_id                IN      NUMBER          := NULL,
  p_resp_id                     IN      NUMBER          := NULL,
  p_return_status               OUT     NOCOPY VARCHAR2
);

END CS_SR_Preferred_Lang_PVT;

 

/

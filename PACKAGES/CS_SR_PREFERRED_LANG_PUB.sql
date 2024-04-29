--------------------------------------------------------
--  DDL for Package CS_SR_PREFERRED_LANG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_PREFERRED_LANG_PUB" AUTHID CURRENT_USER AS
/* $Header: cspprls.pls 115.4 2002/11/30 10:13:44 pkesani noship $ */


PROCEDURE initialize_rec(p_preferred_lang_record    IN OUT
                NOCOPY CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
);


--------------------------------------------------------------------------
-- Start of comments
--  API name	: Create_Preferred_Language
--  Type	: Public
--  Function	: Creates a Preferred Language in the table CS_SR_PREFERRED_LANG
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
--  Service Request IN Parameters:
--	p_resp_appl_id			IN	NUMBER		Optional
--	p_resp_id			IN	NUMBER		Optional
--	p_user_id			IN	NUMBER		Required
--		Application user identifier
--              Valid user from fnd_user

--	p_login_id			IN	NUMBER		Optional
--		Identifier of login session
--
--      p_preferred_language_rec        IN   preferred_language_rec_type Required

--
--  Version	: Initial version	1.0
--
-- End of comments


PROCEDURE Create_Preferred_Language(
    p_api_version            IN    NUMBER,
    p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status          OUT   NOCOPY VARCHAR2,
    x_msg_count              OUT   NOCOPY NUMBER,
    x_msg_data               OUT   NOCOPY VARCHAR2,
    p_resp_appl_id           IN    NUMBER   DEFAULT NULL,
    p_resp_id                IN    NUMBER   DEFAULT NULL,
    p_user_id                IN    NUMBER,
    p_login_id               IN    NUMBER   DEFAULT NULL,
    p_preferred_language_rec IN    CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
);


--------------------------------------------------------------------------
-- Start of comments
--  API name	: Update_Preferred_Language
--  Type	: Public
--  Function	: Updates a preferred language in the table CS_SR_PREFERRED_LANG.
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
--	p_last_updated_by		IN	NUMBER		Required
--      VAlid user from fnd_user

--	p_last_update_login		IN	NUMBER		Optional
--		Default = NULL
--	p_last_update_date		IN	DATE		Required

--      p_service_request_rec           IN      service_request_rec_type  Required


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
    x_return_status		    OUT	NOCOPY VARCHAR2,
    x_msg_count		            OUT	NOCOPY NUMBER,
    x_msg_data			    OUT	NOCOPY VARCHAR2,
    p_pref_lang_id                  IN  NUMBER,
    p_object_version_number         IN  NUMBER,
    p_resp_appl_id		    IN	NUMBER   DEFAULT NULL,
    p_resp_id			    IN	NUMBER   DEFAULT NULL,
    p_user_id                       IN  NUMBER   ,
    p_login_id                      IN  NUMBER   DEFAULT NULL,
    p_last_updated_by	            IN	NUMBER,
    p_last_update_login	            IN	NUMBER   DEFAULT NULL,
    p_last_update_date	            IN	DATE,
    p_preferred_language_rec        IN  CS_SR_Preferred_Lang_PVT.preferred_language_rec_type
    );

END CS_SR_Preferred_Lang_PUB;

 

/

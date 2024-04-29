--------------------------------------------------------
--  DDL for Package ICX_USER_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_USER_PROFILE_PVT" AUTHID CURRENT_USER AS
-- $Header: ICXVUPFS.pls 120.1 2005/10/07 14:34:21 gjimenez noship $

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'ICX_User_Profile_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ICXVUPFB.pls';

-- Start of Comments
--	API name 	: Create_Profile
--	Type		: Private.
--	Function	: Create Web User information in ICX_USER_PROFILES
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:	p_api_version_number	IN NUMBER		Required
--				p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--				p_simulate		IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER		Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_user_id		IN NUMBER		Required
--				p_days_needed_by	IN NUMBER		Optional
--					Default = NULL
--				p_req_default_template	IN VARCHAR2		Optional
--					Default = NULL
--				p_req_override_loc_flag	IN VARCHAR2		Optional
--					Default = NULL
--				p_req_override_req_code	IN VARCHAR2		Optional
--					Default = NULL
--				p_created_by		IN NUMBER		Required
--				p_creation_date		IN DATE			Required
--				p_last_updated_by	IN NUMBER		Required
--				p_last_update_date	IN DATE			Required
--				p_last_update_login	IN NUMBER		Required
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)

--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--	API name 	: Update_Profile
--	Type		: Private.
--	Function	: Update Web User information in ICX_USER_PROFILES
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:	p_api_version_number	IN NUMBER		Required
--				p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--				p_simulate		IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER		Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_user_id		IN NUMBER		Required
--				p_days_needed_by	IN NUMBER		Optional
--					Default = FND_API.G_MISS_NUM
--				p_req_default_template	IN VARCHAR2		Optional
--					Default = FND_API.G_MISS_CHAR
--				p_req_override_loc_flag	IN VARCHAR2		Optional
--					Default = FND_API.G_MISS_CHAR
--				p_req_override_req_code	IN VARCHAR2		Optional
--					Default = FND_API.G_MISS_CHAR
--				p_last_updated_by	IN NUMBER		Required
--					Default = FND_API.G_MISS_NUM
--				p_last_update_date	IN DATE			Required
--					Default = FND_API.G_MISS_DATE
--				p_last_update_login	IN NUMBER		Optional
--					Default = FND_API.G_MISS_NUM
--
--	OUT		:	p_return_status		OUT VARCHAR2
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--	API name 	: Delete_Profile
--	Type		: Private.
--	Function	: Delete Web User information from ICX_USER_PROFILES
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:	p_api_version_number	IN NUMBER		Required
--				p_init_msg_list		IN VARCHAR2 		Optional
--					Default = FND_API.G_FALSE
--				p_simulate		IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2		Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER		Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_user_id		IN NUMBER		Required
--	OUT		:	p_return_status		OUT VARCHAR2
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
-- End Of Comments

PROCEDURE Create_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	nocopy VARCHAR2,
   p_msg_count			OUT	nocopy NUMBER,
   p_msg_data			OUT	nocopy VARCHAR2,
   p_user_id			IN	NUMBER,
   p_days_needed_by		IN	NUMBER   := NULL,
   p_req_default_template	IN	VARCHAR2 := NULL,
   p_req_override_loc_flag	IN	VARCHAR2 := NULL,
   p_req_override_req_code	IN	VARCHAR2 := NULL,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
);


PROCEDURE Update_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	nocopy VARCHAR2,
   p_msg_count			OUT	nocopy NUMBER,
   p_msg_data			OUT	nocopy VARCHAR2,
   p_user_id			IN	NUMBER,
   p_days_needed_by		IN	NUMBER   := FND_API.G_MISS_NUM,
   p_req_default_template	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_req_override_loc_flag	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_req_override_req_code	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
);


PROCEDURE Delete_Profile
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	nocopy VARCHAR2,
   p_msg_count			OUT	nocopy NUMBER,
   p_msg_data			OUT	nocopy VARCHAR2,
   p_user_id			IN	NUMBER
);


END ICX_User_Profile_PVT;

 

/

--------------------------------------------------------
--  DDL for Package ICX_USER_SEC_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_USER_SEC_ATTR_PVT" AUTHID CURRENT_USER AS
-- $Header: ICXVTUSS.pls 120.3 2005/10/26 14:06:46 tshort noship $

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'ICX_User_Sec_Attr_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ICXVTUSB.pls';

-- Start of Comments
--	API name 	: Create_User_Sec_Attr
--	Type		: Private.
--	Function	: Create Securing Attribute Value information in
--			  AK_WEB_USER_SEC_ATTR_VALUES
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:
--	p_api_version_number	IN NUMBER		Required
--	p_init_msg_list		IN VARCHAR2 		Optional
--				Default = FND_API.G_FALSE
--	p_simulate		IN VARCHAR2             Optional
--				Default = FND_API.G_FALSE
--	p_commit	    	IN VARCHAR2		Optional
--				Default = FND_API.G_FALSE
--	p_validation_level	IN NUMBER		Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--	p_web_user_id 		IN NUMBER		Required
--	p_attribute_code	IN VARCHAR2(30)		Required
--	p_attribute_appl_id	IN NUMBER		Required
--	p_varchar2_value	IN VARCHAR2(240)	Required
--	p_date_value		IN DATE			Required
--	p_number_value		IN NUMBER		Required
--	p_created_by		IN NUMBER		Required
--	p_creation_date		IN DATE			Required
--	p_last_updated_by	IN NUMBER		Required
--	p_last_update_date	IN DATE			Required
--	p_last_update_login	IN NUMBER		Required
--
--	OUT		:
--	p_return_status		OUT VARCHAR2(1)
--	p_msg_count		OUT NUMBER
--	p_msg_data		OUT VARCHAR2(2000)
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--
--
--	API name 	: Delete_Resp_Sec_Attr
--	Type		: Private.
--	Function	: Delete Securing Attribute Value information in
--			  AK_WEB_USER_SEC_ATTR_VALUES
--	Pre-reqs	: None.
--	Paramaeters	:
--	IN		:
--	p_api_version_number	IN NUMBER		Required
--	p_init_msg_list		IN VARCHAR2 		Optional
--				Default = FND_API.G_FALSE
--      p_simulate              IN VARCHAR2             Optional
--                              Default = FND_API.G_FALSE
--	p_commit	    	IN VARCHAR2		Optional
--				Default = FND_API.G_FALSE
--	p_validation_level	IN NUMBER		Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--      p_web_user_id           IN NUMBER               Required
--	p_attribute_code	IN VARCHAR2(30)		Required
--	p_attribute_appl_id	IN NUMBER		Required
--      p_varchar2_value        IN VARCHAR2(240)        Required
--      p_date_value            IN DATE                 Required
--      p_number_value          IN NUMBER               Required
--
--	OUT		:
--	p_return_status		OUT VARCHAR2
--	p_msg_count		OUT NUMBER
--	p_msg_data		OUT VARCHAR2
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--
--
--      API name        : Create_Def_User_Sec_Attr
--      Type            : Private.
--      Function        : Create default Securing Attribute Value information
--			  in AK_WEB_USER_SEC_ATTR_VALUES.
--      Pre-reqs        : None.
--      Paramaeters     :
--      IN              :
--      p_api_version_number    IN NUMBER       Required
--      p_init_msg_list         IN VARCHAR2     Optional
--                              Default = FND_API.G_FALSE
--      p_simulate              IN VARCHAR2             Optional
--                              Default = FND_API.G_FALSE
--      p_commit                IN VARCHAR2             Optional
--                              Default = FND_API.G_FALSE
--      p_validation_level      IN NUMBER               Optional
--                              Default = FND_API.G_VALID_LEVEL_FULL
--      p_web_user_id               IN NUMBER               Required
--      p_responsibility_id     IN NUMBER               Required
--      p_created_by            IN NUMBER               Required
--      p_creation_date         IN DATE                 Required
--      p_last_updated_by       IN NUMBER               Required
--      p_last_update_date      IN DATE                 Required
--      p_last_update_login     IN NUMBER               Required
--
--      OUT             :
--      p_return_status         OUT VARCHAR2(1)
--      p_msg_count             OUT NUMBER
--      p_msg_data              OUT VARCHAR2(2000)
--                              .
--      Version : Current version       1.0
--                Initial version       1.0
--
--      Notes           : Note text
--
-- End Of Comments

PROCEDURE Create_User_Sec_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY 	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER,
   p_varchar2_value		IN	VARCHAR2,
   p_date_value			IN	DATE,
   p_number_value		IN	NUMBER,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
);



PROCEDURE Delete_User_Sec_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_web_user_id                IN      NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN	NUMBER,
   p_varchar2_value		IN	VARCHAR2,
   p_date_value                 IN      DATE,
   p_number_value               IN      NUMBER
);

PROCEDURE Create_Def_User_Sec_Attr
(  p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_web_user_id                    IN      NUMBER,
   p_resp_application_id        IN      NUMBER,
   p_responsibility_id          IN      NUMBER,
   p_created_by                 IN      NUMBER,
   p_creation_date              IN      DATE,
   p_last_updated_by            IN      NUMBER,
   p_last_update_date           IN      DATE,
   p_last_update_login          IN      NUMBER,
   p_return_status              OUT NOCOPY     VARCHAR2,
   p_msg_count                  OUT NOCOPY     NUMBER,
   p_msg_data                   OUT NOCOPY     VARCHAR2
);


END ICX_User_Sec_Attr_PVT;

 

/

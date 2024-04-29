--------------------------------------------------------
--  DDL for Package ICX_RESP_EXCL_ATTR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_RESP_EXCL_ATTR_PUB" AUTHID CURRENT_USER AS
/* $Header: ICXPTRES.pls 115.2 99/07/17 03:21:14 porting ship $ */

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'ICX_Resp_Excl_Attr_PUB';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ICXPTREB.pls';

-- Start of Comments
--	API name 	: Create_Resp_Excl_Attr
--	Type		: Public.
--	Function	: Create Web User information in AK_EXCLUDED_ITEMS
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
--				p_responsibility_id	IN NUMBER		Required
--				p_application_id	IN NUMBER		Required
--				p_attribute_code	IN VARCHAR2(30)		Required
--				p_attribute_appl_id	IN NUMBER		Required
--				p_created_by		IN NUMBER		Required
--				p_creation_date		IN DATE			Required
--				p_last_updated_by	IN NUMBER		Required
--					Default = FND_API.G_MISS_NUM
--				p_last_update_date	IN DATE			Required
--					Default = FND_API.G_MISS_DATE
--				p_last_update_login	IN NUMBER		Required
--					Default = NULL
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_msg_entity		OUT VARCHAR2(30)
--				p_msg_entity_index	OUT NUMBER
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
--
--
--
--	API name 	: Delete_Resp_Excl_Attr
--	Type		: Public.
--	Function	: Delete Web User information from AK_EXCLUDED_ITEMS
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
--				p_responsibility_id	IN NUMBER		Required
--				p_application_id	IN NUMBER		Required
--				p_attribute_code	IN VARCHAR2(30)		Required
--				p_attribute_appl_id	IN NUMBER		Required
--
--	OUT		:	p_return_status		OUT VARCHAR2(1)
--				p_msg_count		OUT NUMBER
--				p_msg_data		OUT VARCHAR2(2000)
--				p_msg_entity		OUT VARCHAR2(30)
--				p_msg_entity_index	OUT NUMBER
--				.
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: Note text
--
-- End Of Comments


PROCEDURE Create_Resp_Excl_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	VARCHAR2,
   p_msg_count			OUT	NUMBER,
   p_msg_data			OUT	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_responsibility_id		IN	NUMBER,
   p_application_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN 	NUMBER,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER
);



PROCEDURE Delete_Resp_Excl_Attr
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT	VARCHAR2,
   p_msg_count			OUT	NUMBER,
   p_msg_data			OUT	VARCHAR2,
--   p_msg_entity			OUT	VARCHAR2,
--   p_msg_entity_index		OUT	NUMBER,
   p_responsibility_id		IN	NUMBER,
   p_application_id		IN	NUMBER,
   p_attribute_code		IN	VARCHAR2,
   p_attribute_appl_id		IN 	NUMBER
);


END ICX_Resp_Excl_Attr_PUB;

 

/

--------------------------------------------------------
--  DDL for Package ICX_RELATED_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_RELATED_TEMPLATES_PUB" AUTHID CURRENT_USER AS
/* $Header: ICXPTMPS.pls 115.1 99/07/17 03:21:06 porting ship $ */

-- Start of Comments
-- API name	: Related_Templates
-- Type		: PUBLIC
-- Function	: The Related_Templates API provides procedures to insert
--                and delete template relationships for n-level template
--		  heirarchy definition
--
--
-- Pre-reqs	: None
--
-- Insert_Relation
-- Parameters	:
-- IN		: p_api_version_number  number 	 current version = 1.0
-- 		  p_init_msg_list  	varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE to have api initialize message list
--		  p_simulate		varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE for simulation mode (api will not
--			commit any changes)
--		  p_commit		varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE to have api commit changes
--			p_commit is ignored if p_simulate = FND_API.G_TRUE
--		  p_validation_level	number	 standard api parameter
--			defaults to FND_API.G_VALID_LEVEL_FULL
--		  p_template		varchar2
--			p_template must be provided to the api.  This is the
-- 			parent of the template relationship being inserted
--		  p_related_template
--			p_related_template must be provided to the api.
--			This is the child of the template relationship
--			being inserted
-- 		  p_relationship_type	varchar2
--			this is a required parameter and must be a valid
--			relationship based on the ICX_RELATION lookup type
--		  p_created_by		number
--			this is a required parameter which must correspond
--			to the user who is inserting the template relation
--
-- OUT		: p_return_status	varchar2(1) standard api parameter
--		  	S = api completed successfully,
--			E and U = api errored
--		  p_msg_count		number	    standard api parameter
--			records how many messages were placed on the
-- 			message stack during the api call.  If p_msg_count
--			is 1 then the message is held in p_msg_data,
--			otherwise api caller must use fnd_msg_pub.get to
--			retrieve one message at a time.
--		  p_msg_data		varchar2(240) standard api parameter
--		  	if p_msg_count = 1 then p_msg_data holds the message
--
-- Delete_Relation
-- Parameters	:
-- IN		: p_api_version_number  number 	 current version = 1.0
-- 		  p_init_msg_list  	varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE to have api initialize message list
--		  p_simulate		varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE for simulation mode (api will not
--			commit any changes)
--		  p_commit		varchar2 standard api parameter
--			defaults to FND_API.G_FALSE, set to
--			FND_API.G_TRUE to have api commit changes
--			p_commit is ignored if p_simulate = FND_API.G_TRUE
--		  p_validation_level	number	 standard api parameter
--			defaults to FND_API.G_VALID_LEVEL_FULL
--		  p_template		varchar2
--			p_template must be provided to the api.  This is the
-- 			parent of the template relationship being deleted
--		  p_related_template
--			p_related_template must be provided to the api.
--			This is the child of the template relationship
--			being inserted
--
-- OUT		: p_return_status	varchar2(1) standard api parameter
--		  	S = api completed successfully,
--			E and U = api errored
--		  p_msg_count		number	    standard api parameter
--			records how many messages were placed on the
-- 			message stack during the api call.  If p_msg_count
--			is 1 then the message is held in p_msg_data,
--			otherwise api caller must use fnd_msg_pub.get to
--			retrieve one message at a time.
--		  p_msg_data		varchar2(240) standard api parameter
--		  	if p_msg_count = 1 then p_msg_data holds the message
--
--
-- End Of Comments


--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='ICX_Related_Templates_PUB';


PROCEDURE Insert_Relation
( p_api_version_number 	IN	NUMBER			    		,
  p_init_msg_list	IN  	VARCHAR2 := FND_API.G_FALSE		,
  p_simulate		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
  p_return_status	OUT 	VARCHAR2				,
  p_msg_count		OUT	NUMBER					,
  p_msg_data		OUT 	VARCHAR2	    			,
  p_template		IN	VARCHAR2 DEFAULT NULL			,
  p_related_template	IN	VARCHAR2 DEFAULT NULL			,
  p_relationship_type	IN 	VARCHAR2				,
  p_created_by		IN      NUMBER
);


PROCEDURE Delete_Relation
( p_api_version_number 	IN	NUMBER			    		,
  p_init_msg_list	IN  	VARCHAR2 := FND_API.G_FALSE		,
  p_simulate		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE 		,
  p_validation_level	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
  p_return_status	OUT 	VARCHAR2				,
  p_msg_count		OUT	NUMBER					,
  p_msg_data		OUT 	VARCHAR2				,
  p_template		IN	VARCHAR2 DEFAULT NULL			,
  p_related_template	IN	VARCHAR2 DEFAULT NULL
);


END ICX_Related_Templates_PUB; -- ICX_Related_Templates_PUB

 

/

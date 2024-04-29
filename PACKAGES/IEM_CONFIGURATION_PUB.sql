--------------------------------------------------------
--  DDL for Package IEM_CONFIGURATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CONFIGURATION_PUB" AUTHID CURRENT_USER as
/* $Header: iempcfgs.pls 115.2 2002/12/04 01:22:36 chtang noship $*/
-- Global Variables
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_CONFIGURATION_PUB
-- Purpose          : Public Package. Collect eMail Center Configurations
-- History          : chtang 12/12/01
-- NOTE             :

--	API name 	: 	GetConfiguration
--	Type		: 	Public
--	Function	: This API collects eMail Center configurations
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		 p_api_version_number    IN   NUMBER := 1,
-- 		 p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
--		 p_commit	    IN   VARCHAR2 := FND_API.G_TRUE
--	OUT
--   		ERRBUF		VARCHAR2,
--		ERRRET		VARCHAR2,
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************


PROCEDURE GetConfiguration(ERRBUF		VARCHAR2,
			   ERRRET		VARCHAR2,
			   p_api_version_number    IN   NUMBER := 1,
 		           p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		       	   p_commit	    IN   VARCHAR2 := FND_API.G_TRUE
				 );

END IEM_CONFIGURATION_PUB;

 

/

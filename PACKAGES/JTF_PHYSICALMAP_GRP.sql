--------------------------------------------------------
--  DDL for Package JTF_PHYSICALMAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PHYSICALMAP_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGPSLS.pls 115.5 2004/07/09 18:50:16 applrt ship $ */
-- Declare externally visible types, cursor, exception

/*
TYPE LANGUAGE_CODE_TBL_TYPE IS TABLE OF VARCHAR2(4)
	INDEX BY BINARY_INTEGER;
*/
TYPE LANGUAGE_CODE_TBL_TYPE IS TABLE OF VARCHAR2(4);

TYPE MSITE_LANG_REC_TYPE IS RECORD (
	msite_id					NUMBER,
	lang_count				NUMBER
);

TYPE MSITE_LANG_TBL_TYPE IS TABLE OF MSITE_LANG_REC_TYPE
	INDEX BY BINARY_INTEGER;

TYPE LGL_PHYS_MAP_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE MSITE_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_api_version CONSTANT NUMBER := 1.0;
g_pkg_name CONSTANT VARCHAR2(30) := 'JTF_PhysicalMap_GRP';

-- Declare externally callable subprograms

-- Start of comments
-- API name: 	save_physicalmap
-- Type: 		Private
-- Function:	Save a collection of Physical_Mappings for a physical attachment
--			and one mini-site
-- Pre_reqs:	None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT  VARCHAR2
--             x_msg_count              OUT  NUMBER
--             x_msg_data               OUT  VARCHAR2
--			p_attachment_id		IN	NUMBER		Required
--			p_msite_id			IN	NUMBER		Required
--             p_language_code_tbl      IN   LANGUAGE_CODE_TBL_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_physicalmap (
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
	p_commit				IN	VARCHAR2 := FND_API.g_false,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_attachment_id		IN	NUMBER,
	p_msite_id			IN	NUMBER,
	p_language_code_tbl		IN	LANGUAGE_CODE_TBL_TYPE);


-- Start of comments
-- API name:   save_physicalmap
-- Type:       Private
-- Function:   Save a collection of Physical_Mappings for a physical attachment
--			and multiple mini-sites
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT  VARCHAR2
--             x_msg_count              OUT  NUMBER
--             x_msg_data               OUT  VARCHAR2
--             p_attachment_id          IN   NUMBER         Required
--             p_msite_lang_tbl         IN   MSITE_LANG_TBL_TYPE
--                                                          Required
--             p_language_code_tbl      IN   LANGUAGE_CODE_TBL_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_physicalmap (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_attachment_id          IN   NUMBER,
	p_msite_lang_tbl         IN   MSITE_LANG_TBL_TYPE,
	p_language_code_tbl      IN   LANGUAGE_CODE_TBL_TYPE);


-- Start of comments
-- API name:   delete_physicalmap
-- Type:       Private
-- Function:   Delete a collection of Physical_Mappings
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT  VARCHAR2
--             x_msg_count              OUT  NUMBER
--             x_msg_data               OUT  VARCHAR2
--			p_lgl_phys_map_id_tbl	IN	LGL_PHYS_MAP_ID_TBL_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_physicalmap(
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
	p_commit				IN	VARCHAR2 := FND_API.g_false,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_lgl_phys_map_id_tbl	IN	LGL_PHYS_MAP_ID_TBL_TYPE);


-- Start of comments
-- API name:   delete_attachment
-- Type:       Private
-- Function:	Delete all the Physical_Mappings for the given attachment
-- Pre_reqs:   None
-- Parameters:
-- IN:
--			p_attachment_id		IN	NUMBER		Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_attachment(
	p_attachment_id		IN	NUMBER);


-- Start of comments
-- API name:   delete_deliverable
-- Type:       Private
-- Function:   Delete all the Physical_Mappings for the given deliverable
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_deliverable_id 		IN   NUMBER         Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_deliverable(
	p_deliverable_id		IN	NUMBER);


-- Start of comments
-- API name:   delete_msite
-- Type:       Private
-- Function:   Delete all the Physical_Mappings for the given mini-site
-- Pre_reqs:   None
-- Parameters:
-- IN:
--			p_msite_id			IN	NUMBER		Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_msite(
	p_msite_id			IN	NUMBER);


-- Start of comments
-- API name:   delete_msite_language
-- Type:       Private
-- Function:   Delete all the Physical_Mappings involved the given mini-site
--			and the languages which have been de-supported at the mini-site
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_msite_id               IN	NUMBER         Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_msite_language(
	p_msite_id               IN   NUMBER);


-- Start of comments
-- API name:   delete_attachment_msite
-- Type:       Private
-- Function:   Delete all the Physical_Mappings for the given attachment
--             and mini-sites
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT  VARCHAR2
--             x_msg_count              OUT  NUMBER
--             x_msg_data               OUT  VARCHAR2
--			p_attachment_id		IN	NUMBETR		Required
--			p_msite_id_tbl			IN	MSITE_ID_TBL_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_attachment_msite(
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_attachment_id		IN	NUMBER,
	p_msite_id_tbl           IN   MSITE_ID_TBL_TYPE);


-- Start of comments
-- API name:   delete_dlv_all_all
-- Type:       Private
-- Function:   Delete the all-site and all-language mappings for the given
--			deliverable
-- Pre_reqs:   None
-- Parameters:
-- IN:
--             p_deliverable_id         IN   NUMBETR        Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_dlv_all_all(
	p_deliverable_id         IN   NUMBER);


END JTF_PhysicalMap_GRP;

 

/

--------------------------------------------------------
--  DDL for Package IBE_PHYSICALMAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PHYSICALMAP_GRP" AUTHID CURRENT_USER AS
/* $Header: IBEGPSLS.pls 120.1 2005/07/08 14:28:15 appldev ship $ */
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
g_pkg_name CONSTANT VARCHAR2(30) := 'IBE_PhysicalMap_GRP';

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
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
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
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
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
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2,
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
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
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

-- The following procedures are for OCM integration
PROCEDURE save_physicalmap(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_deliverable_id IN NUMBER,
  p_old_content_key IN VARCHAR2,
  p_new_content_key IN VARCHAR2,
  p_msite_lang_tbl IN MSITE_LANG_TBL_TYPE,
  p_language_code_tbl IN LANGUAGE_CODE_TBL_TYPE);

PROCEDURE delete_physicalmap(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false,
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_deliverable_id IN NUMBER,
  p_content_key IN VARCHAR2);

PROCEDURE replace_content(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.g_false, --modified by YAXU, ewmove DEFAULT
  p_commit IN VARCHAR2 := FND_API.g_false,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  p_old_content_key IN VARCHAR2,
  p_new_content_key IN VARCHAR2);

PROCEDURE LOAD_SEED_ROW(
  P_LGL_PHYS_MAP_ID          IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_MSITE_ID                 IN NUMBER,
  P_LANGUAGE_CODE            IN VARCHAR2,
  P_ATTACHMENT_ID            IN NUMBER,
  P_ITEM_ID                  IN NUMBER,
  P_DEFAULT_LANGUAGE         IN VARCHAR2,
  P_DEFAULT_SITE             IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_CUSTOM_MODE              IN VARCHAR2,
  P_UPLOAD_MODE              IN VARCHAR2);

PROCEDURE LOAD_ROW(
  P_LGL_PHYS_MAP_ID          IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_MSITE_ID                 IN NUMBER,
  P_LANGUAGE_CODE            IN VARCHAR2,
  P_ATTACHMENT_ID            IN NUMBER,
  P_ITEM_ID                  IN NUMBER,
  P_DEFAULT_LANGUAGE         IN VARCHAR2,
  P_DEFAULT_SITE             IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_CUSTOM_MODE              IN VARCHAR2);

END IBE_PhysicalMap_GRP;

 

/

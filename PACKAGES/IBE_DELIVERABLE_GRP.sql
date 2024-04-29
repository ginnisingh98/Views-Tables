--------------------------------------------------------
--  DDL for Package IBE_DELIVERABLE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DELIVERABLE_GRP" AUTHID CURRENT_USER AS
/* $Header: IBEGDLVS.pls 115.4 2003/08/26 19:52:56 abhandar ship $ */
/* Declare externally visible types, cursor, exception */
/*
====================================================================
--             Copyright (c) 1999 Oracle Corporation            --
--                Redwood Shores, California, USA               --
--                     All rights reserved.                     --
------------------------------------------------------------------


-----------------------------------------------------------
-- PACKAGE
--    IBE_Deliverable_GRP
--
-- PROCEDURES
--    save_deliverable
--    delete_deliverable
--	 list_deliverable
--
-- ERROR MESSAGES
--	 IBE_DSP_DLV_ACCNAME_REQ
--	 IBE_DSP_DLV_ACCNAME_EXISTS
--	 IBE_DSP_DLV_NOT_EXISTS
--	 IBE_DSP_DLV_ATH_INVLD
--	 IBE_DSP_QUERY_INVLD
--	 IBE_DSP_AVAIL_INVLD
--
-- HISTORY
--    11/27/99	wxyu	Created
--    05/17/01	G. Zhang	Modified to support DB Media

=============================================================================
*/
TYPE DELIVERABLE_REC_TYPE IS RECORD (
	deliverable_id			NUMBER,
	access_name			VARCHAR2(40),
	display_name			VARCHAR2(240),
	item_type				VARCHAR2(40),
	item_applicable_to		VARCHAR2(40),
	keywords				VARCHAR2(240),
	description			VARCHAR2(2000),
	object_version_number	NUMBER,
	x_action_status		VARCHAR2(1)
);

TYPE DELIVERABLE_TBL_TYPE IS TABLE OF DELIVERABLE_REC_TYPE
	INDEX BY BINARY_INTEGER;

TYPE DLV_ATH_REC_TYPE IS RECORD (
	deliverable_id           NUMBER,
	access_name              VARCHAR2(40),
	display_name             VARCHAR2(240),
	item_type                VARCHAR2(40),
	item_applicable_to       VARCHAR2(40),
	keywords                 VARCHAR2(240),
	description              VARCHAR2(2000),
	object_version_number    NUMBER,
	x_action_status          VARCHAR2(1),
	ath_file_name		 VARCHAR2(240),

	--added by G. Zhang 05/17/01 5:42PM
	ath_file_id		 NUMBER,

	x_ath_action_status      VARCHAR2(1)
);

TYPE DLV_ATH_TBL_TYPE IS TABLE OF DLV_ATH_REC_TYPE
	INDEX BY BINARY_INTEGER;

TYPE DLV_ID_VER_REC_TYPE IS RECORD (
	deliverable_id			NUMBER,
	display_name			VARCHAR2(240),
	object_version_number	NUMBER,
	x_action_status		VARCHAR2(1)
);

TYPE DLV_ID_VER_TBL_TYPE IS TABLE OF DLV_ID_VER_REC_TYPE
	INDEX BY BINARY_INTEGER;

TYPE NUMBER_TABLE IS TABLE OF NUMBER;

TYPE VARCHAR2_TABLE_100 IS TABLE OF VARCHAR2(100);

TYPE VARCHAR2_TABLE_300 IS TABLE OF VARCHAR2(300);

TYPE VARCHAR2_TABLE_2000 IS TABLE OF VARCHAR2(2000);

G_API_VERSION CONSTANT NUMBER := 1.0;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Deliverable_GRP';

/* Declare externally callable subprograms */

PROCEDURE list_deliverable (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_item_type              IN   VARCHAR2,
	p_item_applicable_to     IN   VARCHAR2,
	p_search_type            IN   VARCHAR2,
	p_search_value           IN   VARCHAR2,
	p_start_id               IN   NUMBER,
	p_batch_size             IN   NUMBER,
	x_row_count              OUT NOCOPY  NUMBER,
	x_dlv_id_tbl             OUT NOCOPY  NUMBER_TABLE,
	x_acc_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_100,
	x_dsp_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_300,
	x_item_type_tbl          OUT NOCOPY  VARCHAR2_TABLE_100,
	x_appl_to_tbl            OUT NOCOPY  VARCHAR2_TABLE_100,
	x_keyword_tbl            OUT NOCOPY  VARCHAR2_TABLE_300,
	x_desc_tbl               OUT NOCOPY  VARCHAR2_TABLE_2000,
	x_version_tbl            OUT NOCOPY  NUMBER_TABLE,
	x_file_name_tbl          OUT NOCOPY  VARCHAR2_TABLE_300,

	--added by G. Zhang 05/17/01 5:42PM
	x_file_id_tbl          	 OUT NOCOPY  NUMBER_TABLE);

PROCEDURE list_deliverable (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_category_id		 IN	NUMBER,
	p_item_type              IN   VARCHAR2,
	p_item_applicable_to     IN   VARCHAR2,
	p_search_type            IN   VARCHAR2,
	p_search_value           IN   VARCHAR2,
	p_start_id               IN   NUMBER,
	p_batch_size             IN   NUMBER,
	x_row_count              OUT NOCOPY  NUMBER,
	x_dlv_id_tbl             OUT NOCOPY  NUMBER_TABLE,
	x_acc_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_100,
	x_dsp_name_tbl           OUT NOCOPY  VARCHAR2_TABLE_300,
	x_item_type_tbl          OUT NOCOPY  VARCHAR2_TABLE_100,
	x_appl_to_tbl            OUT NOCOPY  VARCHAR2_TABLE_100,
	x_keyword_tbl            OUT NOCOPY  VARCHAR2_TABLE_300,
	x_desc_tbl               OUT NOCOPY  VARCHAR2_TABLE_2000,
	x_version_tbl            OUT NOCOPY  NUMBER_TABLE,
	x_file_name_tbl          OUT NOCOPY  VARCHAR2_TABLE_300,

	--added by G. Zhang 05/17/01 5:42PM
	x_file_id_tbl          	 OUT NOCOPY  NUMBER_TABLE);

-- Start of comments
-- API name:   save_deliverable
-- Type:       Private
-- Function:   Save a logical deliverable
-- Pre-reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT NOCOPY  VARCHAR2
--             x_msg_count              OUT NOCOPY  NUMBER
--             x_msg_data               OUT NOCOPY  VARCHAR2
--             p_deliverable_rec        IN OUT NOCOPY DELIVERABLE_REC_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_deliverable (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_deliverable_rec        IN OUT NOCOPY DELIVERABLE_REC_TYPE );


-- Start of comments
-- API name:	save_deliverable
-- Type:		Private
-- Function:	Save a collection of logical deliverables
-- Pre-reqs:	None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT NOCOPY  VARCHAR2
--             x_msg_count              OUT NOCOPY  NUMBER
--             x_msg_data               OUT NOCOPY  VARCHAR2
--	       p_deliverable_tbl	IN OUT NOCOPY DELIVERABLE_TBL_TYPE
--												Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_deliverable (
	p_api_version			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
	p_commit		IN	VARCHAR2 := FND_API.g_false,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_deliverable_tbl	IN OUT NOCOPY DELIVERABLE_TBL_TYPE );


-- Start of comments
-- API name:   save_deliverable
-- Type:       Private
-- Function:   Save a logical deliverable with the default attachment
--			for all-site and all-language
-- Pre-reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT NOCOPY  VARCHAR2
--             x_msg_count              OUT NOCOPY  NUMBER
--             x_msg_data               OUT NOCOPY  VARCHAR2
--             p_dlv_ath_rec            IN OUT NOCOPY DLV_ATH_REC_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_deliverable (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_dlv_ath_rec            IN OUT NOCOPY DLV_ATH_REC_TYPE );


-- Start of comments
-- API name:   save_deliverable
-- Type:       Private
-- Function:   Save a collection of logical deliverables with the default
--			attachment for all-site and all-language
-- Pre-reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT NOCOPY  VARCHAR2
--             x_msg_count              OUT NOCOPY  NUMBER
--             x_msg_data               OUT NOCOPY  VARCHAR2
--             p_dlv_ath_tbl        	IN OUT NOCOPY DLV_ATH_TBL_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_deliverable (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT NOCOPY  VARCHAR2,
	x_msg_count              OUT NOCOPY  NUMBER,
	x_msg_data               OUT NOCOPY  VARCHAR2,
	p_dlv_ath_tbl        	IN OUT NOCOPY DLV_ATH_TBL_TYPE );


-- Start of comments
-- API name:	delete_deliverable
-- Type:       Private
-- Function:	Delete a collection of logical deliverable and
--			associations
-- Pre-reqs:   None
-- Parameters:
-- IN:
--             p_api_version            IN   NUMBER         Required
--             p_init_msg_list          IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             p_commit                 IN   VARCHAR2       Optional
--                  Default = FND_API.g_false
--             x_return_status          OUT NOCOPY  VARCHAR2
--             x_msg_count              OUT NOCOPY  NUMBER
--             x_msg_data               OUT NOCOPY  VARCHAR2
--	       p_dlv_id_ver_tbl		IN OUT NOCOPY DLV_ID_VER_TBL_TYPE
--												Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_deliverable(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
	p_commit		IN	VARCHAR2 := FND_API.g_false,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_dlv_id_ver_tbl	IN OUT NOCOPY DLV_ID_VER_TBL_TYPE );



END IBE_Deliverable_GRP;


 

/

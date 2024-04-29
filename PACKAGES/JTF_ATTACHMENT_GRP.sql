--------------------------------------------------------
--  DDL for Package JTF_ATTACHMENT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ATTACHMENT_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGATHS.pls 115.10 2004/07/09 18:49:16 applrt ship $ */
TYPE ATTACHMENT_REC_TYPE IS RECORD (
	attachment_id				NUMBER,
	deliverable_id				NUMBER,
	file_name					VARCHAR2(240),
	object_version_number		NUMBER,
	x_action_status			VARCHAR2(1),

	-- added by G. Zhang
  	attachment_used_by             VARCHAR2(30),
  	enabled_flag                   VARCHAR2(1),
  	can_fulfill_electronic_flag    VARCHAR2(1),
  	file_id                        NUMBER,
  	file_extension                 VARCHAR2(20),
  	keywords                       VARCHAR2(240),
  	display_width                  NUMBER,
  	display_height                 NUMBER,
  	display_location               VARCHAR2(2000),
  	link_to                        VARCHAR2(2000),
  	link_URL                       VARCHAR2(2000),
  	send_for_preview_flag          VARCHAR2(1),
  	attachment_type                VARCHAR2(30),
  	language_code                  VARCHAR2(4),
  	application_id                 NUMBER,
  	description                    VARCHAR2(2000),
  	default_style_sheet            VARCHAR2(240),
  	display_url                    VARCHAR2(1024),
  	display_rule_id                NUMBER,
  	display_program                VARCHAR2(240),
  	attribute_category             VARCHAR2(30),
  	attribute1                     VARCHAR2(150),
  	attribute2                     VARCHAR2(150),
  	attribute3                     VARCHAR2(150),
  	attribute4                     VARCHAR2(150),
  	attribute5                     VARCHAR2(150),
  	attribute6                     VARCHAR2(150),
  	attribute7                     VARCHAR2(150),
  	attribute8                     VARCHAR2(150),
  	attribute9                     VARCHAR2(150),
  	attribute10                    VARCHAR2(150),
  	attribute11                    VARCHAR2(150),
  	attribute12                    VARCHAR2(150),
  	attribute13                    VARCHAR2(150),
  	attribute14                    VARCHAR2(150),
  	attribute15                    VARCHAR2(150),
  	display_text                   VARCHAR2(2000),
  	alternate_text                 VARCHAR2(1000),
  	attachment_sub_type            VARCHAR2(30)
);

TYPE ATTACHMENT_TBL_TYPE IS TABLE OF ATTACHMENT_REC_TYPE
	INDEX BY BINARY_INTEGER;
-- TYPE ATTACHMENT_TBL_TYPE IS TABLE OF ATTACHMENT_REC_TYPE;

TYPE ATH_ID_VER_REC_TYPE IS RECORD (
	attachment_id				NUMBER,
	file_name					VARCHAR2(240),
	object_version_number		NUMBER,
	x_action_status			VARCHAR2(1)
);

TYPE ATH_ID_VER_TBL_TYPE IS TABLE OF ATH_ID_VER_REC_TYPE
	INDEX BY BINARY_INTEGER;

TYPE NUMBER_TABLE IS TABLE OF NUMBER;

TYPE VARCHAR2_TABLE_300 IS TABLE OF VARCHAR2(300);

--added by G. Zhang 04/30/2001 11:18AM
TYPE VARCHAR2_TABLE_20 IS TABLE OF VARCHAR2(20);

G_API_VERSION CONSTANT NUMBER := 1.0;
G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_Attachment_GRP';

PROCEDURE list_attachment (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,

	--added by G. Zhang 04/30/2001 11:18AM
	p_appl_id	IN	NUMBER := 671,

	p_deliverable_id	IN	NUMBER,
	p_start_id               IN   NUMBER,
	p_batch_size             IN   NUMBER,
	x_row_count              OUT  NUMBER,
	x_ath_id_tbl			OUT 	NUMBER_TABLE,
	x_dlv_id_tbl			OUT	NUMBER_TABLE,
	x_file_name_tbl		OUT	VARCHAR2_TABLE_300,

	--added by G. Zhang 04/30/2001 11:18AM
  	x_file_id_tbl		OUT     NUMBER_TABLE,
  	x_file_ext_tbl		OUT	VARCHAR2_TABLE_20,
  	x_dsp_width_tbl		OUT 	NUMBER_TABLE,
  	x_dsp_height_tbl	OUT 	NUMBER_TABLE,

	x_version_tbl			OUT	NUMBER_TABLE );

-- Start of comments
-- API name:   save_attachment
-- Type:       Private
-- Function:   Create a physical attachment
-- Pre-reqs:   None
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
--             p_attachment_rec         IN OUT ATTACHMENT_REC_TYPE
--                                                          Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_attachment (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_attachment_rec         IN OUT ATTACHMENT_REC_TYPE );


-- Start of comments
-- API name:	save_attachment
-- Type:		Private
-- Function:	Create a collection of physical attachments
-- Pre-reqs:	None
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
--			p_attachment_tbl		IN OUT ATTACHMENT_TBL_TYPE
--												Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE save_attachment (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_attachment_tbl         IN OUT ATTACHMENT_TBL_TYPE );


-- Start of comments
-- API name:   delete_attachment
-- Type:       Private
-- Function:   Delete a collection of physical attachments and associated
--			physical_site_language mappings
-- Pre-reqs:   None
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
--             p_ath_id_ver_tbl         IN OUT ATH_ID_VER_TBL_TYPE
--												Required
-- Version:    Current Version 1.0
--             Initial version     1.0
-- Notes:      None
-- End of comments

PROCEDURE delete_attachment (
	p_api_version            IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2 := FND_API.g_false,
	p_commit                 IN   VARCHAR2 := FND_API.g_false,
	x_return_status          OUT  VARCHAR2,
	x_msg_count              OUT  NUMBER,
	x_msg_data               OUT  VARCHAR2,
	p_ath_id_ver_tbl         IN OUT ATH_ID_VER_TBL_TYPE );


END JTF_Attachment_GRP;

 

/

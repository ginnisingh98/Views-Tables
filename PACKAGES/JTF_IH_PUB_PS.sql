--------------------------------------------------------
--  DDL for Package JTF_IH_PUB_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PUB_PS" AUTHID CURRENT_USER AS
/* $Header: JTFIHPSS.pls 115.10 2000/02/29 17:58:37 pkm ship     $ */
-- Start of comments
--  Procedure   : Create_Interaction
--  Type        : Public API
--  Usage       : Creates a customer interaction record in the table
--                JTF_IH_INTERACTIONS and related activity(ies)
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version			IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  Interaction IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--                                                              Application identifier
--                                                              Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--                                                              Responsibility identifier
--                                                              Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--                                                              Corresponds to the column USER_ID in the table
--                                                              FND_USER, and identifies the Oracle
--                                                              Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--                                                              table FND_LOGINS, and identifies the login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_rec               IN interaction_rec_type
--      p_activities                    IN activity_tbl_type
--
--      interaction_rec_type is the structure that captures the interaction and has the following
--      attributes:
--			reference_form			VARCHAR2	Optional
--			follow_up_action		VARCHAR2	Optional
--			duration			NUMBER		Optional
--			end_date_time			DATE		Optional
--			inter_interaction_duration	NUMBER		Optional
--			interaction_id			NUMBER
--			non_productive_time_amount	NUMBER		Optional
--			preview_time_amount		NUMBER		Optional
--			productive_time_amount		NUMBER		Optiona
--			start_date_time			DATE		Optional
--			wrapUp_time_amount		NUMBER		Optional
--			handler_id			NUMBER		Optional
--			script_id			NUMBER		Optional
--			outcome_id			NUMBER		Optional
--			result_id			NUMBER		Optional
--			reason_id			NUMBER		Optional
--			resource_subtype_id		NUMBER		Optional
--			resource_type_id		NUMBER		Optional
--			resource_id			NUMBER		Optional
--			party_id			NUMBER		Optional
--			parent_id			NUMBER		Optional
--			object_id			NUMBER		Optional
--			object_type			VARCHAR2	Optional
--			source_code_id			NUMBER		Optional
--			source_code			VARCHAR2	Optional
--			attribute1			VARCHAR2	Optional(2)
--			attribute2			VARCHAR2	Optional(2)
--			attribute3			VARCHAR2	Optional(2)
--			attribute4			VARCHAR2	Optional(2)
--			attribute5			VARCHAR2	Optional(2)
--			attribute6			VARCHAR2	Optional(2)
--			attribute7			VARCHAR2	Optional(2)
--			attribute8			VARCHAR2	Optional(2)
--			attribute9			VARCHAR2	Optional(2)
--			attribute10			VARCHAR2	Optional(2)
--			attribute11			VARCHAR2	Optional(2)
--			attribute12			VARCHAR2	Optional(2)
--			attribute13			VARCHAR2	Optional(2)
--			attribute14			VARCHAR2	Optional(2)
--			attribute15			VARCHAR2	Optional(2)
--			attribute_category		VARCHAR2	Optional(2)
--
--	activity_rec_type is the structure that captures the activity and has the following attributes:
--
--			duration			NUMBER
--			end_date_time		DATE
--			start_date_time		DATE
--			task_id				NUMBER
--			doc_id				NUMBER
--			doc_ref				VARCHAR2
--			media_id			NUMBER
--			action_item_id		VARCHAR2
--			interaction_id		NUMBER
--			activity_id			NUMBER
--			outcome_id			NUMBER
--			result_id			NUMBER
--			reason_id			NUMBER
--			description			VARCHAR2
--			action_id			VARCHAR2
--			arole				VARCHAR2
--			interaction_action_type		VARCHAR2
--			object_id			NUMBER		Optional
--			object_type			VARCHAR2	Optional
--			source_code_id			NUMBER		Optional
--			source_code			VARCHAR2	Optional
--
--	activity_tbl_type is the pl/sql table that used to bundle the set of activities
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

TYPE interaction_rec_type IS RECORD
(
	interaction_id			NUMBER :=fnd_api.g_miss_num,
	reference_form			VARCHAR2(1000) :=fnd_api.g_miss_char,
	follow_up_action		VARCHAR2(80) :=fnd_api.g_miss_char,
	duration				NUMBER := fnd_api.g_miss_num,
	end_date_time			DATE :=fnd_api.g_miss_date,
	inter_interaction_duration	NUMBER :=fnd_api.g_miss_num,
	non_productive_time_amount	NUMBER :=fnd_api.g_miss_num,
	preview_time_amount		NUMBER :=fnd_api.g_miss_num,
	productive_time_amount	NUMBER :=fnd_api.g_miss_num,
	start_date_time			DATE :=fnd_api.g_miss_date,
	wrapUp_time_amount		NUMBER :=fnd_api.g_miss_num,
	handler_id			NUMBER :=fnd_api.g_miss_num,
	script_id			NUMBER :=fnd_api.g_miss_num,
	outcome_id			NUMBER :=fnd_api.g_miss_num,
	result_id			NUMBER :=fnd_api.g_miss_num,
	reason_id			NUMBER :=fnd_api.g_miss_num,
	resource_id			NUMBER :=fnd_api.g_miss_num,
	party_id			NUMBER :=fnd_api.g_miss_num,
	parent_id			NUMBER :=fnd_api.g_miss_num,
	object_id			NUMBER :=fnd_api.g_miss_num,
	object_type			VARCHAR2(30) :=fnd_api.g_miss_char,
	source_code_id		NUMBER :=fnd_api.g_miss_num,
	source_code			VARCHAR2(30) :=fnd_api.g_miss_char,
	attribute1			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute2			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute3			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute4			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute5			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute6			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute7			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute8			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute9			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute10			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute11			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute12			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute13			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute14			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute15			VARCHAR2(150) :=fnd_api.g_miss_char,
	attribute_category		VARCHAR2(30) :=fnd_api.g_miss_char
);

FUNCTION INIT_INTERACTION_REC RETURN interaction_rec_type;

TYPE activity_rec_type IS RECORD
(
	activity_id			NUMBER := fnd_api.g_miss_num,
	duration			NUMBER :=fnd_api.g_miss_num,
	cust_account_id		NUMBER := fnd_api.g_miss_num,
	cust_org_id			NUMBER := fnd_api.g_miss_num,
	role				VARCHAR2(240) := fnd_api.g_miss_char,
	end_date_time		DATE :=fnd_api.g_miss_date,
	start_date_time		DATE :=fnd_api.g_miss_date,
	task_id				NUMBER :=fnd_api.g_miss_num,
	doc_id				NUMBER :=fnd_api.g_miss_num,
	doc_ref				VARCHAR2(80) :=fnd_api.g_miss_char,
	media_id			NUMBER :=fnd_api.g_miss_num,
	action_item_id			NUMBER :=fnd_api.g_miss_num,
	interaction_id			NUMBER :=fnd_api.g_miss_num,
	outcome_id			NUMBER :=fnd_api.g_miss_num,
	result_id			NUMBER :=fnd_api.g_miss_num,
	reason_id			NUMBER :=fnd_api.g_miss_num,
	description			VARCHAR2(1000) :=fnd_api.g_miss_char,
	action_id			NUMBER :=fnd_api.g_miss_num,
	interaction_action_type		VARCHAR2(240) :=fnd_api.g_miss_char,
	object_id			NUMBER :=fnd_api.g_miss_num,
	object_type			VARCHAR2(30) :=fnd_api.g_miss_char,
	source_code_id			NUMBER :=fnd_api.g_miss_num,
	source_code			VARCHAR2(30) :=fnd_api.g_miss_char
);
TYPE activity_tbl_type IS TABLE OF activity_rec_type INDEX BY BINARY_INTEGER;

FUNCTION INIT_ACTIVITY_REC RETURN activity_rec_type;

PROCEDURE Create_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
	p_activities		IN	activity_tbl_type
);

-- Start of comments
--  Procedure   : Create_MediaItem
--  Type        : Public API
--  Usage       : Creates a media item record in the table
--                JTF_IH_MEDIAITEM
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--		p_media IN media_rec_type
--
--		media_rec_type is the structure that captures a media item and has the following attributes:
--			media_id			NUMBER
--			source_id			NUMBER		Optional
--			direction			VARCHAR2	Optional
--			duration			NUMBER		Optional
--			end_date_time			DATE		Optional
--			interaction_performed		VARCHAR2	Optional
--			start_date_time			DATE		Optional
--			media_data			VARCHAR2	Optional
--			source_item_create_date_time	NUMBER		Optional
--			source_item_id			NUMBER		Optional
--			media_item_type			VARCHAR2
--			media_item_ref			VARCHAR2	Optional
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--
-- End of comments
TYPE media_rec_type IS RECORD
(
	media_id				NUMBER :=fnd_api.g_miss_num,
	source_id				NUMBER :=fnd_api.g_miss_num,
	direction				VARCHAR2(240) :=fnd_api.g_miss_char,
	duration				NUMBER :=fnd_api.g_miss_num,
	end_date_time			DATE :=fnd_api.g_miss_date,
	interaction_performed	VARCHAR2(240) :=fnd_api.g_miss_char,
	start_date_time			DATE :=fnd_api.g_miss_date,
	media_data				VARCHAR2(80) :=fnd_api.g_miss_char,
	source_item_create_date_time	DATE :=fnd_api.g_miss_date,
	source_item_id			NUMBER :=fnd_api.g_miss_num,
	media_item_type			VARCHAR2(80) :=fnd_api.g_miss_char,
	media_item_ref			VARCHAR2(240) :=fnd_api.g_miss_char
);
TYPE media_lc_rec_type IS RECORD
(
	start_date_time			DATE :=fnd_api.g_miss_date,
	type_type				VARCHAR2(80) :=fnd_api.g_miss_char,
	type_id				NUMBER :=fnd_api.g_miss_num,
	duration			NUMBER :=fnd_api.g_miss_num,
	end_date_time			DATE :=fnd_api.g_miss_date,
	milcs_id			NUMBER :=fnd_api.g_miss_num,
	milcs_type_id		NUMBER :=fnd_api.g_miss_num,
	media_id			NUMBER :=fnd_api.g_miss_num,
	handler_id			NUMBER :=fnd_api.g_miss_num,
	resource_id			NUMBER :=fnd_api.g_miss_num
);

TYPE mlcs_tbl_type IS TABLE OF media_lc_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media		IN	media_rec_type,
	p_mlcs		IN	mlcs_tbl_type
);

PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id		IN	NUMBER		DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_media_rec		IN	media_rec_type,
	x_media_id		OUT NUMBER
);

-- Start of comments
--  Procedure   : Create_MediaLifecycle
--  Type        : Public API
--  Usage       : Creates a media lifecycle record in the table
--                JTF_IH_MEDIA_ITEM_LC_SEGS
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--		p_media_lc_rec		IN	media_lc_rec_type
--
--		media_lc_rec_type is the structure that captures a media lifecycle and has the following attributes:
--		start_date_time		DATE
--		type_type				VARCHAR2(80)
--		type_id				NUMBER
--		duration			NUMBER
--		end_date_time		DATE
--		milcs_id			NUMBER
--		milcs_type_id		NUMBER REQUIRED
--		media_id			NUMBER REQUIRED
--		handler_id			NUMBER
--		resource_id			NUMBER
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--
-- End of comments


PROCEDURE Create_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec		IN	media_lc_rec_type
);

-- Start of comments
--  Procedure   : Get_InteractionActivityCount
--  Type        : Public API
--  Usage       : Get the interaction activity count from JTF_IH_ACTIVITY based on the input parameters
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  Customer Interaction IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the
--								table FND_USER, and identifies the Oracle
--								Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--            							Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies
--              						the login session
--              						Default = FND_GLOBAL.LOGIN_ID or NULL
--	p_outcome_id			IN NUMBER		Optional
--	p_result_id			IN NUMBER		Optional
--	p_reason_id			IN NUMBER		Optional
--	p_script_id			IN NUMBER		Optional
--	p_media_id			IN NUMBER		Optional
--	Activity Count OUT Parameters
--	x_activity_count		OUT NUMBER
--              						the number of the activity record that
--								match the search criteria
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)  The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--
-- End of comments

PROCEDURE Get_InteractionActivityCount
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER		DEFAULT NULL,
	p_resp_id			IN	NUMBER		DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER		DEFAULT NULL,
	x_return_status			OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_outcome_id			IN	NUMBER,
	p_result_id			IN	NUMBER,
	p_reason_id			IN	NUMBER,
	p_script_id			IN	NUMBER,
	p_media_id			IN	NUMBER,
	x_activity_count		OUT	NUMBER
);

-- Start of comments
--  Procedure   : Get_InteractionCount
--  Type        : Public API
--  Usage       : Get the interaction count from JTF_IH_INTERACTIONS based on the input parameters
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--								the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the login session
--              						Default = FND_GLOBAL.LOGIN_ID or NULL
--			p_outcome_id	IN	NUMBER          Optional
--			p_result_id	IN	NUMBER          Optional
--			p_reason_id	IN	NUMBER          Optional
--			p_attribute1	IN	VARCHAR2(150)   Optional(2)
--              Customer interaction descriptive flexfield segments 1-15
-- 			p_attribute2	IN	VARCHAR2(150)		Optional(2)
--			p_attribute3	IN	VARCHAR2(150)		Optional(2)
--			p_attribute4	IN	VARCHAR2(150)		Optional(2)
--			p_attribute5	IN	VARCHAR2(150)		Optional(2)
--			p_attribute6	IN	VARCHAR2(150)		Optional(2)
--			p_attribute7	IN	VARCHAR2(150)		Optional(2)
--			p_attribute8	IN	VARCHAR2(150)		Optional(2)
--			p_attribute9	IN	VARCHAR2(150)		Optional(2)
--			p_attribute10	IN	VARCHAR2(150)		Optional(2)
--			p_attribute11	IN	VARCHAR2(150)		Optional(2)
--			p_attribute12	IN	VARCHAR2(150)		Optional(2)
--			p_attribute13	IN	VARCHAR2(150)		Optional(2)
--			p_attribute14	IN	VARCHAR2(150)		Optional(2)
--			p_attribute15	IN	VARCHAR2(150)		Optional(2)
--			p_attribute_category	IN			VARCHAR2(30)		Optional(2)
--              Descriptive flexfield structure defining column
--
--			Interaction Count OUT Parameters
--			x_interaction_count  OUT     NUMBER
--				the number of the interaction record that match the search criteria
--
--		Version	: Initial version	1.0
--
--		Notes	:
--		(1)  The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--		(2) You must pass in segment IDs for none or all descriptive flexfield
--           columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Get_InteractionCount
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER		DEFAULT	NULL,
	p_resp_id			IN	NUMBER		DEFAULT	NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER		DEFAULT	NULL,
	x_return_status			OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_outcome_id			IN	NUMBER,
	p_result_id			IN	NUMBER,
	p_reason_id			IN	NUMBER,
	p_attribute1			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute2			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute3			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute4			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute5			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute6			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute7			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute8			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute9			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute10			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute11			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute12			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute13			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute14			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute15			IN	VARCHAR2	DEFAULT	NULL,
	p_attribute_category		IN	VARCHAR2	DEFAULT	NULL,
	x_interaction_count		OUT	NUMBER
);

-- Start of comments
--  Procedure   : Open_Interaction  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism during the creation of
--                an Interaction.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_rec               IN interaction_rec_type
--
--	 Interaction_Id OUT Parameters
--		x_interaction_id				OUT     NUMBER
--										the id of the new interaction record
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Open_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
	x_interaction_id	OUT	NUMBER
);

-- Start of comments
--  Procedure   : Update_Interaction  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism during the active of
--                an Interaction.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_rec               IN interaction_rec_type
--
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Update_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type
);

-- Start of comments
--  Procedure   : Close_Interaction  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism during the final of
--                an Interaction.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_rec               IN interaction_rec_type
--										used in update interaction record
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type
);

-- Start of comments
--  Procedure   : Add_Activity  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism
--				  during the creation of an activity after some interaction happen.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--		p_activity_rec					IN	activity_rec_type
--
--	 Activity_Id OUT Parameters
--		x_activity_id					OUT     NUMBER
--										the id of the new activity record
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Add_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
	x_activity_id		OUT NUMBER
);

-- Start of comments
--  Procedure   : Update_Activity  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism
--				  during the active of an activity
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--		p_activity_rec					IN	activity_rec_type
--
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Update_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_rec		IN	activity_rec_type
);

-- Start of comments
--  Procedure   : Close_Interaction  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a caching mechanism during the final of
--                an Interaction.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_id	            IN NUMBER
--
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count		OUT	NUMBER,
	x_msg_data		OUT	VARCHAR2,
	p_interaction_id	IN	NUMBER
);

-- Start of comments
--  Procedure   : Update_ActivityDuration  -- created by Jean Zhu 01/11/2000
--  Type        : Public API
--  Usage       : This API servers as the basis for providing a updating mechanism
--				  for the duration and start/end date of an activity
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--              						Default = FND_API.G_FALSE
--
--	Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--   Interaction count IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--
--   Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in
--										the table FND_USER, and identifies the
--              						Oracle Applications user
--              						Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              						Corresponds to the column LOGIN_ID in the
--										table FND_LOGINS, and identifies the login session
--
--                                      Default = FND_GLOBAL.LOGIN_ID or NULL
--		p_activity_id					IN	NUMBER
--		p_start_date_time				IN DATE
--		p_end_date_time					IN DATE
--		p_duration						IN	NUMBER
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--	(2) You must pass in segment IDs for none or all descriptive flexfield
--       columns that might be used in the descriptive flexfield.
--
-- End of comments

PROCEDURE Update_ActivityDuration
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count			OUT	NUMBER,
	x_msg_data			OUT	VARCHAR2,
	p_activity_id		IN	NUMBER,
	p_end_date_time		IN  DATE,
	p_duration			IN	NUMBER
);

-- Start of comments
--  Author	: James Baldo Jr.
--  History	:
--			29 February 2000	Created
--  Procedure   : Open_MediaItem
--  Type        : Public API
--  Usage       : Creates a media item record in the table JTF_IH_MEDIA_ITEMS. The record created
--		  resulting from a successful call to this API will have its Active column marked
--		  'Y'. This state indicates that the record can be updated via the Update_MediaItem
--		  procedure. The procedure call returns the media_id value for the record created.
--
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--	p_media 			IN 	media_rec_type
--
--	x_media_id			OUT	NUMBER
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--              profile values are used as default.
--
-- End of comments

PROCEDURE Open_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type,
	x_media_id	OUT NUMBER
);

-- Start of comments
--  Author	: James Baldo Jr.
--  History	:
--			29 February 2000	Created
--  Procedure   : Update_MediaItem
--  Type        : Public API
--  Usage       : Updates an existing media item record in the table JTF_IH_MEDIA_ITEMS.
--		  Procedure will only update columns with valid values. All input values must
--		  be valid. Procedure will not perform a partial update.
--
--  Pre-conditions	: Media_ID update state Active = 'Y'
--
--  Post-conditions	: Media_ID update state Active = 'Y'
--			: Updated columns changed to valid values
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--	p_media 			IN 	media_rec_type
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--              profile values are used as default.
--
-- End of comments

PROCEDURE Update_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type
);


-- Start of comments
--  Author	: James Baldo Jr.
--  History	:
--			29 February 2000	Created
--  Procedure   : Close_MediaItem
--  Type        : Public API
--  Usage       : Updates an existing media item record in the table JTF_IH_MEDIA_ITEMS.
--		  Procedure will only update columns with valid values. All input values must
--		  be valid. Procedure will not perform a partial update. Will mark the state of the
--		  Media_ID and associated Milcs_ID Active = 'N'. The record set, media item and associated
-- 		  milcs_id(s) are now considered historical records and immutable.
--
--  Pre-conditions	: Media_ID state Active = 'Y'
--			: Milcs_ID (i.e., all media_item_lifecycle_segments associated with Media_ID)
--			  state Active = 'Y'
--
--  Post-conditions	: Media_ID update state Active = 'N'
--			: Updated columns changed to valid values
--			: Milcs_ID(s) update state Active = 'N'
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--	p_media 			IN 	media_rec_type
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--              profile values are used as default.
--
-- End of comments

PROCEDURE Close_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_rec	IN	media_rec_type
);

-- Start of comments
--  Procedure   : Add_MediaLifecycle
--  Type        : Public API
--  Author	: James Baldo Jr.
--  History	:
--			29 February 2000	Created
--  Usage       : Creates a media lifecycle record in the table JTF_IH_MEDIA_ITEM_LC_SEGS,
--		  returns a Milcs_ID, and sets the state of the record Active = 'Y'.
--		  All parameter values passed-in must be valid. The procedure will not create
--		  a record with a partial set of valid values.
--
--
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--	p_media_lc_rec			IN	media_lc_rec_type
--
--	x_milcs_id			OUT	NUMBER
--
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--
-- End of comments


PROCEDURE Add_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type
);

-- Start of comments
--  Procedure   : Update_MediaLifecycle
--  Type        : Public API
--  Author	: James Baldo Jr.
--  History	:
--			29 February 2000	Created
--  Usage       : Update a media lifecycle record in the table JTF_IH_MEDIA_ITEM_LC_SEGS.
--		  All parameter values passed-in must be valid. The procedure will not update
--		  a record with a partial set of valid values.
--
--
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version                   IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2(1)     Optional
--                                                              Default = FND_API.G_FALSE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  MediaItem IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              						Application identifier
--              						Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              						Responsibility identifier
--              						Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              						Corresponds to the column USER_ID in the table
--								FND_USER, and identifies the Oracle
--								Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--								table FND_LOGINS, and identifies the
--              						login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--
--	p_media_lc_rec			IN	media_lc_rec_type
--
--
--
--	Version	: Initial version	1.0
--
--	Notes	:
--	(1)	The application ID, responsibility ID, and user ID determine which
--           profile values are used as default.
--
-- End of comments


PROCEDURE Update_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	VARCHAR2,
	x_msg_count	OUT	NUMBER,
	x_msg_data	OUT	VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type
);


END JTF_IH_PUB_PS;

 

/

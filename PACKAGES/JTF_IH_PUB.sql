--------------------------------------------------------
--  DDL for Package JTF_IH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PUB" AUTHID CURRENT_USER AS
/* $Header: JTFIHPBS.pls 120.4 2006/02/13 06:33:26 nchouras ship $ */
/*#
 * The JTF_IH_PUB package provides a common framework for CRM modules to
 * capture and access all customer interaction data that are associated with
 * customer contacts.
 * All public procedures (APIs) relating to media items, media lifecycles,
 * interactions, and activities are stored in the JTF_IH_PUB package.
 * @rep:scope public
 * @rep:product JTH
 * @rep:displayname Customer Interaction Management
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
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
--			handler_id			NUMBER		Mandatory
--			script_id			NUMBER		Optional
--			outcome_id			NUMBER		Mandatory
--			result_id			NUMBER		Optional
--			reason_id			NUMBER		Optional
--			resource_subtype_id		NUMBER		Optional
--			resource_type_id		NUMBER		Optional
--			resource_id			NUMBER		Mandatory
--			party_id			NUMBER		Mandatory
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
--			touchpoint1_type		VARCHAR2	Optional(3)
--			touchpoint2_type		VARCHAR2	Optional(3)
--
--	activity_rec_type is the structure that captures the activity and has the following attributes:
--
--			duration			NUMBER
--			end_date_time			DATE
--			start_date_time			DATE
--			task_id				NUMBER
--			doc_id				NUMBER
--			doc_ref				VARCHAR2
--			doc_source_object_name		VARCHAR2 	-- Modified by Jim Baldo 20 April 2000 for bugdb 1275539
--			media_id			NUMBER
--			action_item_id			NUMBER
--			interaction_id			NUMBER
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
--	(3) The touchpoint types extends the Interaction History model to include
--	 resource-to-resource touchpoints.
--
-- End of comments

TYPE interaction_rec_type IS RECORD
(
	interaction_id			NUMBER :=fnd_api.g_miss_num,
	reference_form			VARCHAR2(1000) :=fnd_api.g_miss_char,
	follow_up_action		VARCHAR2(80) :=fnd_api.g_miss_char,
	duration			NUMBER := fnd_api.g_miss_num,
	end_date_time			DATE :=fnd_api.g_miss_date,
	inter_interaction_duration	NUMBER :=fnd_api.g_miss_num,
	non_productive_time_amount	NUMBER :=fnd_api.g_miss_num,
	preview_time_amount		NUMBER :=fnd_api.g_miss_num,
	productive_time_amount		NUMBER :=fnd_api.g_miss_num,
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
	source_code_id			NUMBER :=fnd_api.g_miss_num,
	source_code			VARCHAR2(100) :=fnd_api.g_miss_char,
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
	attribute_category		VARCHAR2(30) :=fnd_api.g_miss_char,
	touchpoint1_type		VARCHAR2(30) := 'PARTY',
	touchpoint2_type		VARCHAR2(30) := 'RS_EMPLOYEE',
    -- Bug# 1732336
	method_code			VARCHAR2(30) :=fnd_api.g_miss_char,
    -- Enh# 2940473
    bulk_writer_code    VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_type     VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_id       NUMBER := fnd_api.g_miss_num,
    bulk_interaction_id NUMBER := fnd_api.g_miss_num,
    -- Enh# 1846960
    primary_party_id    NUMBER := fnd_api.g_miss_num,
    contact_rel_party_id    NUMBER := fnd_api.g_miss_num,
    contact_party_id    NUMBER := fnd_api.g_miss_num
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
	doc_ref				VARCHAR2(30) :=fnd_api.g_miss_char,
	doc_source_object_name		VARCHAR2(80) :=fnd_api.g_miss_char,
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
	source_code			VARCHAR2(100) :=fnd_api.g_miss_char,
	script_trans_id			NUMBER :=fnd_api.g_miss_num,
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
	attribute_category		VARCHAR2(30) :=fnd_api.g_miss_char,
-- Removed by IAleshin 06/05/2002
--    ,resource_id         NUMBER := fnd_api.g_miss_num
    -- Enh# 2940473
    bulk_writer_code    VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_type     VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_id       NUMBER := fnd_api.g_miss_num,
    bulk_interaction_id NUMBER := fnd_api.g_miss_num
);
TYPE activity_tbl_type IS TABLE OF activity_rec_type INDEX BY BINARY_INTEGER;

FUNCTION INIT_ACTIVITY_REC RETURN activity_rec_type;

/*#
 * Creates an Interaction and associated Interaction Activities
 * and sets the status of the interaction and activities created
 * to inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR,
 * and FND_API.G_RET_STS_UNEXP_ERROR.If the FND_API.G_RET_STS_SUCCESS
 * value is returned, the API call was successful. If the
 * FND_API.G_RET_STS_ERROR value is returned, a validation or missing
 * data error has occurred. If the FND_API.G_RET_STS_UNEXP_ERROR value
 * is returned, an unexpected error has occurred and the calling program
 * cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_interaction_rec Contains the elements that comprise the
 * interaction record.
 * @param p_activities A table of PL/SQL records of type activity_rec_type.
 * The activities populated in this table will be added to the specified
 * interaction.
 * @rep:scope public
 * @rep:displayname Create Interaction
 */
PROCEDURE Create_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
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
--			media_id			NUMBER		Mandatory
--			source_id			NUMBER		Optional
--			direction			VARCHAR2	Optional
--			duration			NUMBER		Optional
--			end_date_time			DATE		Optional
--			interaction_performed		VARCHAR2	Optional
--			start_date_time			DATE		Optional
--			media_data			VARCHAR2	Optional
--			source_item_create_date_time	NUMBER		Optional
--			source_item_id			NUMBER		Optional
--			media_item_type			VARCHAR2	Mandatory
--			media_item_ref			VARCHAR2	Optional
--			media_abandon_flag		VARCHAR2	Optional
--			media_transferred_flag		VARCHAR2	Optional
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
	end_date_time				DATE :=fnd_api.g_miss_date,
	interaction_performed			VARCHAR2(240) :=fnd_api.g_miss_char,
	start_date_time				DATE :=fnd_api.g_miss_date,
	media_data				VARCHAR2(80) :=fnd_api.g_miss_char,
	source_item_create_date_time		DATE :=fnd_api.g_miss_date,
	source_item_id				NUMBER :=fnd_api.g_miss_num,
	media_item_type				VARCHAR2(80) :=fnd_api.g_miss_char,
	media_item_ref				VARCHAR2(240) :=fnd_api.g_miss_char,
	media_abandon_flag			VARCHAR2(1) :=fnd_api.g_miss_char,
	media_transferred_flag			VARCHAR2(1) :=fnd_api.g_miss_char,
        -- added by IAleshin
        server_group_id             NUMBER  :=fnd_api.g_miss_num,
        dnis                        VARCHAR2(30) :=fnd_api.g_miss_char,
        ani                         VARCHAR2(30) :=fnd_api.g_miss_char,
        classification              VARCHAR2(64) :=fnd_api.g_miss_char,
    -- Enh# 2940473
    bulk_writer_code    VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_type     VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_id       NUMBER := fnd_api.g_miss_num,
    bulk_interaction_id NUMBER := fnd_api.g_miss_num,
    -- Enh# 3022511
    address       VARCHAR2(2000) := fnd_api.g_miss_char
);
TYPE media_lc_rec_type IS RECORD
(
	start_date_time			DATE :=fnd_api.g_miss_date,
	type_type			VARCHAR2(80) :=fnd_api.g_miss_char,
	type_id				NUMBER :=fnd_api.g_miss_num,
	duration			NUMBER :=fnd_api.g_miss_num,
	end_date_time			DATE :=fnd_api.g_miss_date,
	milcs_id			NUMBER :=fnd_api.g_miss_num,
	milcs_type_id			NUMBER :=fnd_api.g_miss_num,
	media_id			NUMBER :=fnd_api.g_miss_num,
	handler_id			NUMBER :=fnd_api.g_miss_num,
	resource_id			NUMBER :=fnd_api.g_miss_num,		-- Added by Jim Baldo 30 November 2000 for bugdb 1501325
	milcs_code			VARCHAR2(80) := fnd_api.g_miss_char,	-- Added by Jim Baldo 30 November 2000 for bugdb 1501325
    -- Enh# 2940473
    bulk_writer_code    VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_type     VARCHAR2(240) := fnd_api.g_miss_char,
    bulk_batch_id       NUMBER := fnd_api.g_miss_num,
    bulk_interaction_id NUMBER := fnd_api.g_miss_num
);

TYPE mlcs_tbl_type IS TABLE OF media_lc_rec_type INDEX BY BINARY_INTEGER;

/*#
 * This procedure creates a media item record in the Media Items table and
 * a media lifecycle record in the Media Lifecycles table, as passed by the
 * calling application. It sets the  status of the Media Item and
 * Media Lifecycles created to inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media A PL/SQL record of type media_rec_type.
 * The media item values specified in this record will be created
 * on the specified media item.
 * @param p_mlcs A PL/SQL record of type media_lc_rec_type.
 * The Media Item Lifecycle Segment values specified in this record
 * will be added to the specified Media Item.
 * @rep:scope internal
 * @rep:displayname Create Media Item
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media		IN	media_rec_type,
	p_mlcs		IN	mlcs_tbl_type
);

/*#
 * Creates a Media Item and sets the Media Item status to
 * indicate that it is inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_rec A PL/SQL record of type media_rec_type. The media item
 * values specified in this record will be created on the specified media
 * item.
 * @param x_media_id This is the record number for the created media
 * item and is automatically generated by sequence JTF_IH_MEDIA_ITEMS_S1.
 * @rep:scope public
 * @rep:displayname Create Media Item
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Create_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id		IN	NUMBER		DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_media_rec		IN	media_rec_type,
	x_media_id		OUT NOCOPY NUMBER
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

/*#
 * This procedure creates a media lifecycle record in the Media Lifecycle
 * table, and sets it to inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_lc_rec This is a composite record that enumerates the
 * elements that comprise a media lifecycle.
 * @rep:scope internal
 * @rep:displayname Create Media Lifecycle
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Create_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
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

/*#
 * This procedure retrieves the interaction activity count from
 * the Activities table based on the criteria passed in the
 * defined parameters.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred.
 * If the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected
 * error has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_outcome_id This is a unique, sequence-generated identifier.
 * @param p_result_id This is a unique identifier that corresponds to
 * a certain result.
 * @param p_reason_id This is a unique identifier that corresponds
 * to a certain reason.
 * @param p_script_id The identifier of the script/survey used
 * during the interaction.
 * @param p_media_id This is a unique, sequence-generated identifier
 * for the media.
 * @param x_activity_count This corresponds to the number of
 * interactions and activities found that match the search criteria.
 * @rep:scope internal
 * @rep:displayname Get Interaction Activity Count
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Get_InteractionActivityCount
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER		DEFAULT NULL,
	p_resp_id			IN	NUMBER		DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER		DEFAULT NULL,
	x_return_status			OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	p_outcome_id			IN	NUMBER,
	p_result_id			IN	NUMBER,
	p_reason_id			IN	NUMBER,
	p_script_id			IN	NUMBER,
	p_media_id			IN	NUMBER,
	x_activity_count		OUT	NOCOPY NUMBER
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

/*#
 * This procedure retrieves the interaction count from table Interactions
 * table, as determined by the criteria passed in the defined parameters.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred.
 * If the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_outcome_id This is a unique, sequence-generated identifier.
 * @param p_result_id This is a unique identifier that corresponds to
 * a certain result.
 * @param p_reason_id This is a unique identifier that corresponds
 * to a certain reason.
 * @param p_attribute1 Customer flex field segment
 * @param p_attribute2 Customer flex field segment
 * @param p_attribute3 Customer flex field segment
 * @param p_attribute4 Customer flex field segment
 * @param p_attribute5 Customer flex field segment
 * @param p_attribute6 Customer flex field segment
 * @param p_attribute7 Customer flex field segment
 * @param p_attribute8 Customer flex field segment
 * @param p_attribute9 Customer flex field segment
 * @param p_attribute10 Customer flex field segment
 * @param p_attribute11 Customer flex field segment
 * @param p_attribute12 Customer flex field segment
 * @param p_attribute13 Customer flex field segment
 * @param p_attribute14 Customer flex field segment
 * @param p_attribute15 Customer flex field segment
 * @param p_attribute_category The attribute category code.
 * @param x_interaction_count The count of the number of
 * interactions matching the specified criteria.
 * @rep:scope internal
 * @rep:displayname Get Interaction Count
 */
PROCEDURE Get_InteractionCount
(
	p_api_version			IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id			IN	NUMBER		DEFAULT	NULL,
	p_resp_id			IN	NUMBER		DEFAULT	NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER		DEFAULT	NULL,
	x_return_status			OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
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
	x_interaction_count		OUT	NOCOPY NUMBER
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

/*#
 * Creates an Interaction and sets the status of the Interaction
 * to active.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred.
 * If the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_interaction_rec Contains the elements that comprise the
 * interaction record.
 * @param x_interaction_id This is the unique, sequence-generated
 * identifier that is sent to the calling application when a generic
 * interaction record is inserted in the Interactions table for updating.
 * @rep:scope public
 * @rep:displayname Open Interaction
 */
PROCEDURE Open_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
	x_interaction_id	OUT	NOCOPY NUMBER
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
/*#
 * Updates an active Interaction.
 * The record remains in an active status.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_interaction_rec Contains the elements that comprise the
 * interaction record.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope public
 * @rep:displayname Update Interaction
 */
PROCEDURE Update_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
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

/*#
 * Updates and then closes an Interaction by setting the
 * Interaction status to indicate that it is inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value is
 * returned, the API call was successful. If the FND_API.G_RET_STS_ERROR value
 * is returned, a validation or missing data error has occurred. If the
 * FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_interaction_rec Contains the elements that comprise the
 * interaction record.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope public
 * @rep:displayname Update and Close Interaction
 */
PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_interaction_rec	IN	interaction_rec_type,
    p_object_version IN NUMBER DEFAULT NULL
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
/*#
 * Creates an Interaction Activity for an Open Interaction.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_activity_rec A PL/SQL record of type activity_rec_type.
 * The activity values specified in this record will be added to
 * the specified Interaction.
 * @param x_activity_id This is the unique, sequence-generated
 * identifier that is sent from the API to the calling application.
 * @rep:scope public
 * @rep:displayname Create Interaction Activity
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Add_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
	x_activity_id		OUT NOCOPY NUMBER
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
/*#
 * Updates an Interaction Activity for an Open Interaction.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred.
 * If the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_activity_rec A PL/SQL record of type activity_rec_type.
 * The activity values specified in this record will be Updated on
 * the specified Activity.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope public
 * @rep:displayname Update Interaction Activity
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Update_Activity
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	p_activity_rec		IN	activity_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL

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

/*#
 * Closes an Interaction by updating the end date and sets the
 * Interaction status to indicate that it is inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_interaction_id This is a unique, sequence-generated identifier
 * for the interaction.
 * @rep:scope public
 * @rep:displayname Close Interaction
 */
PROCEDURE Close_Interaction
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id		IN	NUMBER	DEFAULT NULL,
	p_user_id		IN	NUMBER,
	p_login_id		IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
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

/*#
 * This procedure updates an activity end_date_time and duration fields,
 * as determined by the provided activity identifier with the values
 * supplied by the calling application. The record remains in an active status.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_activity_id This is a unique, sequence-generated identifier
 * that corresponds to a certain activity.
 * @param p_end_date_time This is the time in date format at the end of
 * the transaction.
 * @param p_duration Time difference between the end_date_time and
 * the start_date_time converted to seconds.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope internal
 * @rep:displayname Update Activity Duration
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Update_ActivityDuration
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id			IN	NUMBER	DEFAULT NULL,
	p_user_id			IN	NUMBER,
	p_login_id			IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	p_activity_id		IN	NUMBER,
	p_end_date_time		IN  DATE,
	p_duration			IN	NUMBER,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL

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

/*#
 * Creates a Media Item and sets the Media Item status to active.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return status
 * of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS
 * value is returned, the API call was successful. If the
 * FND_API.G_RET_STS_ERROR value is returned, a validation or missing
 * data error has occurred. If the FND_API.G_RET_STS_UNEXP_ERROR value is
 * returned, an unexpected error has occurred and the calling program
 * cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_rec A PL/SQL record of type media_rec_type. The media item
 * values specified in this record will be created on the specified media item.
 * @param x_media_id This is the record number for the created media
 * item and is automatically generated by sequence JTF_IH_MEDIA_ITEMS_S1.
 * @rep:scope public
 * @rep:displayname Open Media Item
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Open_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media_rec	IN	media_rec_type,
	x_media_id	OUT NOCOPY NUMBER
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

/*#
 * Updates an active Media Item.
 * identifier provided and the values supplied by the calling application.
 * The record remains in an active status.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_rec A PL/SQL record of type media_rec_type. The media item
 * values specified in this record will be updated on the specified media item.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope public
 * @rep:displayname Update Media Item
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Update_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media_rec	IN	media_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL

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

/*#
 * Closes a Media Item by updating the end date and sets the
 * Media Item status to indicate that it is inactive.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_rec A PL/SQL record of type media_rec_type. The media item
 * values specified in this record will be updated on the specified media item.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope public
 * @rep:displayname Close Media Item
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Close_MediaItem
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media_rec	IN	media_rec_type,
    p_object_version IN NUMBER DEFAULT NULL
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

/*#
 * This procedure creates a media lifecycle record in the Media Lifecycle
 * table. It associates the media lifecycle record with a media item that is
 * passed by the calling application. It leaves the record in an active status
 * and returns a sequence generated milcs_id number.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_lc_rec This is a composite record that enumerates the
 * elements that comprise a media lifecycle.
 * @param x_milcs_id This corresponds to the sequence-generated
 * media lifecycle identifier for the created record.
 * @rep:scope internal
 * @rep:displayname Add Media Lifecycle
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Add_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type,
	x_milcs_id	OUT	NOCOPY NUMBER
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
/*#
 * This procedure updates a media lifecycle record based on the media
 * lifecycle identifier and the values supplied by the calling application.
 * The record remains in an active status.
 * @param p_api_version This must match the version number of the API.
 * An unexpected error is returned if the calling program version number
 * is incompatible with the current API version number.
 * @param p_init_msg_list This flag is used to indicate if the message stack
 * should be initialized. The values that are valid for this parameter are:
 * True = FND_API.G_TRUE, False = FND_API.G_FALSE, and
 * Default = FND_API.G_FALSE. When set to 'True',the API makes a call
 * to the fnd_msg_pub.initialize to initialize the message stack. When
 * set to 'False', it is the responsibility of the calling program to
 * initialize the message stack. It is only required that this action be
 * performed once, even when more than one API is called.
 * @param p_commit This flag is used to indicate if changes made to the
 * transaction should be committed on success. The values that are valid
 * for this parameter are: True = FND_API.G_TRUE, False = FND_API.G_FALSE,
 * and Default = FND_API.G_FALSE. When set to 'True', the API commits
 * before returning to the calling program. When set to 'False', it is the
 * responsibility of the calling program to commit the transaction.
 * @param p_resp_appl_id This represents the unique application identifier.
 * @param p_resp_id This is a unique identifier for the responsibility.
 * @param p_user_id This corresponds to the USER_ID column in the FND_USER
 * table and identifies the Oracle Applications user.
 * @param p_login_id Corresponds to the LOGIN_ID column in the FND_LOGINS
 * table and identifies the login session.
 * @param x_return_status This flag is used to indicate the return
 * status of the API. The values that are valid for this parameter are:
 * FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, and
 * FND_API.G_RET_STS_UNEXP_ERROR. If the FND_API.G_RET_STS_SUCCESS value
 * is returned, the API call was successful. If the FND_API.G_RET_STS_ERROR
 * value is returned, a validation or missing data error has occurred. If
 * the FND_API.G_RET_STS_UNEXP_ERROR value is returned, an unexpected error
 * has occurred and the calling program cannot correct the error.
 * @param x_msg_count This represents the count of error messages in the
 * message list.
 * @param x_msg_data Holds the encoded message if x_msg_count is equal to one.
 * @param p_media_lc_rec This is a composite record that enumerates the
 * elements that comprise a media lifecycle.
 * @param p_object_version The version number of the record to be updated.
 * @rep:scope internal
 * @rep:displayname Update Media Lifecycle
 * @rep:category BUSINESS_ENTITY JTH_INTERACTION
 */
PROCEDURE Update_MediaLifecycle
(
	p_api_version	IN	NUMBER,
	p_init_msg_list	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit	IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_resp_appl_id	IN	NUMBER		DEFAULT NULL,
	p_resp_id	IN	NUMBER		DEFAULT NULL,
	p_user_id	IN	NUMBER,
	p_login_id	IN	NUMBER		DEFAULT NULL,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	p_media_lc_rec	IN	media_lc_rec_type,
    -- Bug# 2012159
    p_object_version IN NUMBER DEFAULT NULL
);


END JTF_IH_PUB;

 

/

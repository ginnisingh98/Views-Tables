--------------------------------------------------------
--  DDL for Package JTF_IH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFIHPVS.pls 115.7 2000/01/24 14:58:47 pkm ship     $ */
-- Start of comments
--  Procedure   : Create_Interaction_m
--  Type        : Public API
--  Usage       : Creates a customer interaction record in the table
--                JTF_IH_INTERACTIONS and related activity(ies), media item
--                and related media item life cycle segment
--  Pre-reqs    : None
--
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  Interaction IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--              Application identifier
--              Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--              Responsibility identifier
--              Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional
--              Corresponds to the column USER_ID in the table FND_USER, and
--              identifies the Oracle Applications user
--              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--              Corresponds to the column LOGIN_ID in the table FND_LOGINS,
--              and identifies the login session
--              Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_interaction_rec IN jtf_ih_pub.interaction_rec_type
--      p_activities IN jtf_ih_pub.activity_table_type
--			p_media					IN	jtf_ih_pub.media_rec_type,
--			p_mlcs					IN	jtf_ih_pub.mlcs_table_type
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
PROCEDURE Create_Interaction_m
(
	p_resp_appl_id		IN	NUMBER	DEFAULT NULL,
	p_resp_id					IN	NUMBER	DEFAULT NULL,
	p_user_id					IN	NUMBER,
	p_login_id				IN	NUMBER	DEFAULT NULL,
	x_return_status		OUT	VARCHAR2,
	x_msg_count				OUT	NUMBER,
	x_msg_data				OUT	VARCHAR2,
	p_interaction_rec	IN	jtf_ih_pub.interaction_rec_type,
	p_activities			IN	jtf_ih_pub.activity_tbl_type,
	p_media					IN	jtf_ih_pub.media_rec_type,
	p_mlcs					IN	jtf_ih_pub.mlcs_tbl_type
);
END JTF_IH_PVT;

 

/

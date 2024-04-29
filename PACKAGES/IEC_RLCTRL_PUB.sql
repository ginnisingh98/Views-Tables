--------------------------------------------------------
--  DDL for Package IEC_RLCTRL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_RLCTRL_PUB" AUTHID CURRENT_USER AS
/* $Header: IECRCPBS.pls 115.8 2004/05/18 20:28:08 minwang noship $ */

-- Start of comments
--  Procedure   : MakeListEntriesAvailable
--  Type        : Public API
--  Usage       : Makes list entries with specified do not use reason available by setting
--                the DO_NOT_USE_FLAG to 'N' in both IEC_G_RETURN_ENTRIES and
--                AMS_LIST_ENTRIES.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version			IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)    Required
--                                             FND_API.G_FALSE or FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2(1)    Required
--                                             FND_API.G_FALSE or FND_API.G_TRUE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  Oher IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--                                                              Application identifier
--                                                              Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--                                                              Responsibility identifier
--                                                              Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional(1)
--                                                              Corresponds to the column USER_ID in the table
--                                                              FND_USER, and identifies the Oracle
--                                                              Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--                                                              table FND_LOGINS, and identifies the login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_list_header_id                IN      NUMBER          Required
--      p_dnu_reason_code               IN      NUMBER          Required
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--
-- End of comments


PROCEDURE MakeListEntriesAvailable
(
	p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2,
	p_commit		IN		VARCHAR2,
	p_resp_appl_id		IN		NUMBER	DEFAULT NULL,
	p_resp_id		IN		NUMBER	DEFAULT NULL,
	p_user_id		IN		NUMBER,
	p_login_id		IN		NUMBER	DEFAULT NULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		IN OUT NOCOPY	NUMBER,
	x_msg_data		IN OUT NOCOPY	VARCHAR2,
	p_list_header_id	IN		NUMBER,
	p_dnu_reason_code	IN		NUMBER
);

-- Start of comments
--  Procedure   : MakeListEntriesAvailable
--  Type        : Public API
--  Usage       : Makes list entries for specified list available (regardless of do not use reason)
--                by setting the DO_NOT_USE_FLAG to 'N' in both IEC_G_RETURN_ENTRIES and
--                AMS_LIST_ENTRIES.
--  Pre-reqs    : None
--
--  Standard IN Parameters:
--      p_api_version			IN      NUMBER          Required
--      p_init_msg_list                 IN      VARCHAR2(1)    Required
--                                             FND_API.G_FALSE or FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2(1)    Required
--                                             FND_API.G_FALSE or FND_API.G_TRUE
--
--  Standard OUT Parameters:
--      x_return_status                 OUT     VARCHAR2(1)
--      x_msg_count                     OUT     NUMBER
--      x_msg_data                      OUT     VARCHAR2(2000)
--
--  Oher IN Parameters:
--      p_resp_appl_id                  IN      NUMBER          Optional(1)
--                                                              Application identifier
--                                                              Default = FND_GLOBAL.RESP_APPL_ID or NULL
--      p_resp_id                       IN      NUMBER          Optional(1)
--                                                              Responsibility identifier
--                                                              Default = FND_GLOBAL.RESP_ID or NULL
--      p_user_id                       IN      NUMBER          Optional(1)
--                                                              Corresponds to the column USER_ID in the table
--                                                              FND_USER, and identifies the Oracle
--                                                              Applications user
--                                                              Default = FND_GLOBAL.USER_ID
--      p_login_id                      IN      NUMBER          Optional
--                                                              Corresponds to the column LOGIN_ID in the
--                                                              table FND_LOGINS, and identifies the login session
--                                                              Default = FND_GLOBAL.LOGIN_ID or NULL
--      p_list_header_id                IN      NUMBER          Required
--
--	Version	:	Initial version	1.0
--
--	Notes       :
--	(1)  The application ID, responsibility ID, and user ID determine which
--       profile values are used as default.
--
-- End of comments


PROCEDURE MakeListEntriesAvailable
(
        p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2,
        p_commit                IN              VARCHAR2,
        p_resp_appl_id          IN              NUMBER  DEFAULT NULL,
        p_resp_id               IN              NUMBER  DEFAULT NULL,
        p_user_id               IN              NUMBER,
        p_login_id              IN              NUMBER  DEFAULT NULL,
        x_return_status         IN OUT NOCOPY   VARCHAR2,
        x_msg_count             IN OUT NOCOPY   NUMBER,
        x_msg_data              IN OUT NOCOPY   VARCHAR2,
        p_list_header_id        IN              NUMBER
);


END IEC_RLCTRL_PUB;

 

/

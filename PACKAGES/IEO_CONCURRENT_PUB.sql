--------------------------------------------------------
--  DDL for Package IEO_CONCURRENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_CONCURRENT_PUB" AUTHID CURRENT_USER AS
/* $Header: ieopcons.pls 115.0 2003/10/13 22:00:03 edwang noship $*/


-- Start of comments
--	API name 	: START_PROCESS
--	Type		: Public
--	Function	: Invoke the IEO_CHECK_RESTART_SERVERS every 15 minutes.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_repeat_interval	IN NUMBER	Required
--	OUT		:	ERRBUF	OUT NOCOPY	VARCHAR2
--				RETCODE OUT NOCOPY	VARCHAR2
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: edwang  10-10-03 Created
--
-- End of comments
PROCEDURE START_PROCESS
(

	ERRBUF   OUT NOCOPY     VARCHAR2,
	RETCODE  OUT NOCOPY     VARCHAR2,
    p_repeat_interval IN NUMBER
);



-- Start of comments
--	API name 	: IEO_CHECK_RESTART_SERVERS
--	Type		: Public
--	Function	: Detect abnormal server down and restart it
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--	OUT		:	x_return_status	OUT NOCOPY	VARCHAR2(1)
--				x_msg_count	OUT NOCOPY	NUMBER
--				x_msg_data	OUT NOCOPY	VARCHAR2(2000)
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: edwang  10-10-03 Created
--
-- End of comments
PROCEDURE IEO_CHECK_RESTART_SERVERS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2
);


-- Start of comments
--	API name 	: IEO_PING_AND_RESTART_SERVER
--	Type		: Public
--	Function	: ping server and restart it
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--              p_server_id	IN NUMBER	Required
--	OUT		:	x_return_status	OUT NOCOPY	VARCHAR2(1)
--				x_msg_count	OUT NOCOPY	NUMBER
--				x_msg_data	OUT NOCOPY	VARCHAR2(2000)
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: edwang  10-10-03 Created
--
-- End of comments
PROCEDURE IEO_PING_AND_RESTART_SERVER
(
	ERRBUF                  OUT NOCOPY       VARCHAR2,
 	RETCODE                 OUT NOCOPY       VARCHAR2,
 	SERVER_ID               IN               NUMBER
);

END IEO_CONCURRENT_PUB;

 

/

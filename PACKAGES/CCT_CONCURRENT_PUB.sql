--------------------------------------------------------
--  DDL for Package CCT_CONCURRENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CONCURRENT_PUB" AUTHID CURRENT_USER AS
/* $Header: cctpcons.pls 115.5 2003/07/17 02:31:25 ktlaw noship $*/


-- Start of comments
--	API name 	: START_PROCESS
--	Type		: Public
--	Function	: Invoke the ih_close_mi_process every 15 minutes.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_repeat_interval	IN NUMBER	Required
--	OUT		:	ERRBUF	OUT NOCOPY	VARCHAR2
--				RETCODE OUT NOCOPY	VARCHAR2
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda  APR 19 2002 Created
--
-- End of comments



PROCEDURE START_PROCESS
(

	ERRBUF   OUT NOCOPY     VARCHAR2,
	RETCODE  OUT NOCOPY     VARCHAR2,
    p_close_interval IN NUMBER
);



-- Start of comments
--	API name 	: CLOSE_MEDIA_ITEMS
--	Type		: Public
--	Function	: Close all media items that have been processed
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
-- 				p_root_group_id	IN NUMBER Required
--	OUT		:	x_return_status	OUT NOCOPY	VARCHAR2(1)
--				x_msg_count	OUT NOCOPY	NUMBER
--				x_msg_data	OUT NOCOPY	VARCHAR2(2000)
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda  APR 15 2002 Created
--
-- End of comments


PROCEDURE CLOSE_MEDIA_ITEMS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2                ,
 	RETCODE                 OUT NOCOPY       VARCHAR2
);



-- Start of comments
--	API name 	: TIMEOUT_PROCESS
--	Type		: Public
--	Function	: Invoke the ih_close_mi_process every 15 minutes.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_repeat_interval	IN NUMBER	Required
--	OUT		:	ERRBUF	OUT NOCOPY	VARCHAR2
--				RETCODE OUT NOCOPY	VARCHAR2
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda  APR 19 2002 Created
--
-- End of comments



PROCEDURE TIMEOUT_PROCESS
(
	ERRBUF   OUT NOCOPY     VARCHAR2,
	RETCODE  OUT NOCOPY     VARCHAR2,
    p_timeout_interval IN NUMBER,
    p_check_timeout_interval IN NUMBER
);



-- Start of comments
--	API name 	: TIMEOUT_MEDIA_ITEMS
--	Type		: Public
--	Function	: Close all media items that have been processed
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version	IN NUMBER	Required
--				p_init_msg_list	IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
-- 				p_root_group_id	IN NUMBER Required
--	OUT		:	x_return_status	OUT	VARCHAR2(1)
--				x_msg_count	OUT	NUMBER
--				x_msg_data	OUT	VARCHAR2(2000)
--	Version	: Current version	1.0
--		  Initial version 	1.0
--
--	Notes		: svinamda  APR 15 2002 Created
--
-- End of comments


PROCEDURE TIMEOUT_MEDIA_ITEMS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2 ,
 	RETCODE                 OUT NOCOPY       VARCHAR2 ,
    p_api_version           IN	NUMBER	,
  	p_init_msg_list		IN	VARCHAR2 Default FND_API.G_FALSE	,
	p_commit	    	IN  	VARCHAR2 Default FND_API.G_FALSE,
	p_timeout_in_hrs    IN NUMBER
);

PROCEDURE TIMEOUT_MEDIA_ITEMS_RS
(
	ERRBUF                  OUT NOCOPY       VARCHAR2 ,
 	RETCODE                 OUT NOCOPY       VARCHAR2 ,
	p_timeout_in_hrs    IN NUMBER
);


END CCT_CONCURRENT_PUB;

 

/

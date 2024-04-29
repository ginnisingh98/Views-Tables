--------------------------------------------------------
--  DDL for Package EAM_PM_LAST_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_LAST_SERVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPPLSS.pls 115.1 2003/09/05 11:12:30 adharia noship $ */
-- Start of comments
--	API name 	: EAM_PM_LAST_SERVICE_PUB
--	Type		: Public
--	Function	: insert_pm_last_service, update_pm_last_service
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version           	IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    		IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level		IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				parameter1
--				parameter2
--				.
--				.
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT	VARCHAR2(2000)
--				parameter1
--				parameter2
--				.
--				.
--	Version	: Current version	x.x
--				Changed....
--			  previous version	y.y
--				Changed....
--			  .
--			  .
--			  previous version	2.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--
-- End of comments

TYPE pm_last_service_rec IS RECORD
(
	METER_ID			NUMBER	,
	LAST_SERVICE_READING        	NUMBER	DEFAULT NULL,
	PREV_SERVICE_READING        	NUMBER	DEFAULT NULL,
	WIP_ENTITY_ID               	NUMBER	DEFAULT NULL
);
TYPE pm_last_service_tbl IS TABLE OF pm_last_service_rec INDEX BY BINARY_INTEGER;

PROCEDURE process_pm_last_service
(
	p_api_version       		IN	NUMBER			,
  	p_init_msg_list			IN	VARCHAR2:= FND_API.G_FALSE	,
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE	,
	p_validation_level		IN  	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	x_return_status			OUT NOCOPY VARCHAR2	,
	x_msg_count			OUT NOCOPY NUMBER	,
	x_msg_data	    		OUT NOCOPY VARCHAR2  ,

	p_pm_last_service_tbl           IN       pm_last_service_tbl,
	p_actv_assoc_id                 in       number
);


END;

 

/

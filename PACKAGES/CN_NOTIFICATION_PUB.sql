--------------------------------------------------------
--  DDL for Package CN_NOTIFICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFICATION_PUB" AUTHID CURRENT_USER AS
--$Header: cnpntxs.pls 115.3 2002/11/21 21:04:52 hlchen ship $

-- Start of comments
--	API name 	: Create_Notification
--	Type		: Public
--	Function	: This Public API is used to create a Collection Notification
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        NUMBER    Required
--				p_init_msg_list      VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--				p_commit	           VARCHAR2  Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   NUMBER    Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--
--	OUT		:	x_return_status	VARCHAR2(1)
--				x_msg_count	     NUMBER
--				x_msg_data	     VARCHAR2(2000)
--
--   IN        :    p_line_id         NUMBER        Required
--                  p_source_doc_type VARCHAR2      Required
--                  p_adjusted_flag   VARCHAR2      Optional
--                        Default = 'N'
--                  p_header_id       NUMBER        Optional
--                        Default = FND_API.G_MISS_NUM
--                  p_org_id          NUMBER        Optional
--                        Default = FND_API.G_MISS_NUM
--
--	OUT		:	x_loading_status  VARCHAR2(4000)
--
--	Version	: Current version	1.0
--				12-Apr-00  Dave Maskell
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				12-Apr-00  Dave Maskell
--
--	Notes:
--         If you wish to create a notification for the collection of a
--         new transaction, set P_ADJUSTED_FLAG to 'N' (or omit it).
--         If you wish to create a notification for the collection of an
--         adjusted existing transaction, set P_ADJUSTED_FLAG to 'Y'
--         The only difference between the two is that the value of
--         P_ADJUSTED_FLAG is used to set the value of
--         CN_NOT_TRX_ALL.ADJUSTED_FLAG. During the Collection process,
--         if the Notification line has ADJUSTED_FLAG = 'Y', then as well
--         as collecting the transaction information from the Data Source,
--         the process will look to see if the transaction already exists
--         in OSC and will create a reversing entry for it.
--
--         If P_ORG_ID is passed in (even if the value is NULL),
--         then that value will be used for ORG_ID in the Notification
--         line which is created in CN_NOT_TRX_ALL. If P_ORG_ID is not
--         passed then the procedure will derive the ORG_ID from the user
--         environment in the standard manner. The procedure allows the
--         specification of an ORG_ID so that it can be called from non-user
--         processes, such as triggers, which cannot be org-striped.
--
--         P_LINE_ID must represent a unique identifier for the transaction line
--         which is to be collected from the Data Source
--
--         P_SOURCE_DOC_TYPE must match the value of MAPPING_TYPE (in CN_TABLE_MAPS)
--         for the Data Source from which the transaction is to be collected. The
--         appropriate value can be seen on the OSC Collections screen, as the
--         abbreviated Data Source name, which is displayed to right of the Name itself
--         (e.g. SOURCE_DOC_TYPE for Order Capture is 'OC' and for Receivables is 'AR').
--
-- End of comments

PROCEDURE Create_Notification
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_line_id            IN NUMBER,
    p_source_doc_type    IN VARCHAR2,
    p_adjusted_flag      IN VARCHAR2 := 'N',
    p_header_id          IN NUMBER := NULL,
    p_org_id             IN NUMBER := FND_API.G_MISS_NUM,
    x_loading_status     OUT NOCOPY VARCHAR2
    );

END CN_Notification_PUB;

 

/

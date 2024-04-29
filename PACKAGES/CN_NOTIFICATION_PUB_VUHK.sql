--------------------------------------------------------
--  DDL for Package CN_NOTIFICATION_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOTIFICATION_PUB_VUHK" AUTHID CURRENT_USER AS
/* $Header: cnintxs.pls 120.1 2005/06/13 00:08:20 appldev  $ */

-- Start of Comments
-- API name 	: Create_Notification_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook before creating a new Collections Transaction Notification
-- Desc 	: Called by CN_NOTIFICATION_PUB.Create_Notification
-- Parameters	:
--   Parameters     :
--   IN        :    p_api_version        NUMBER    Required
--                  p_init_msg_list      VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--                  p_commit             VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--                  p_validation_level   NUMBER    Optional
--                       Default = FND_API.G_VALID_LEVEL_FULL
--
--   OUT       :    x_return_status     VARCHAR2(1)
--                  x_msg_count         NUMBER
--                  x_msg_data          VARCHAR2(2000)
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
--   OUT       :    x_loading_status  VARCHAR2(4000)
--
--   Version   : Current version   1.0
--                  04-May-00  Dave Maskell
--               previous version  y.y
--                  Changed....
--               Initial version   1.0
--                  04-May-00  Dave Maskell
--
--   Notes          : Note text
--
-- End of comments

PROCEDURE Create_Notification_Pre
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


-- Start of Comments
-- API name 	: Create_Notification_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook after creating a new Collections Transaction Notification
-- Desc 	: Called by CN_NOTIFICATION_PUB.Create_Notification
-- Parameters	:
--   Parameters     :
--   IN        :    p_api_version        NUMBER    Required
--                  p_init_msg_list      VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--                  p_commit             VARCHAR2  Optional
--                       Default = FND_API.G_FALSE
--                  p_validation_level   NUMBER    Optional
--                       Default = FND_API.G_VALID_LEVEL_FULL
--
--   OUT       :    x_return_status     VARCHAR2(1)
--                  x_msg_count         NUMBER
--                  x_msg_data          VARCHAR2(2000)
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
--   OUT       :    x_loading_status  VARCHAR2(4000)
--
--   Version   : Current version   1.0
--                  04-May-00  Dave Maskell
--               previous version  y.y
--                  Changed....
--               Initial version   1.0
--                  04-May-00  Dave Maskell
--
--   Notes          : Note text
--
-- End of comments

PROCEDURE Create_Notification_Post
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

END CN_NOTIFICATION_PUB_VUHK ;

 

/

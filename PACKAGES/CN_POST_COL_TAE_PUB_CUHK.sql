--------------------------------------------------------
--  DDL for Package CN_POST_COL_TAE_PUB_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_POST_COL_TAE_PUB_CUHK" AUTHID CURRENT_USER AS
--$Header: cncpcols.pls 115.0 2003/09/17 01:01:05 fting noship $

-- Start of Comments
-- API name 	: get_assignments_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook before TAE integration
-- Desc 	: Called by CN_POST_COL_TAE_PUB.get_assignments
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
--   Notes          : Note text
--
-- End of comments

PROCEDURE get_assignments_pre
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2);


-- Start of Comments
-- API name 	: get_assignments_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook after TAE integration
-- Desc 	: Called by CN_POST_COL_TAE_PUB.get_assignments
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

--   Notes          : Note text
--
-- End of comments

PROCEDURE get_assignments_post
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2);

END CN_POST_COL_TAE_PUB_CUHK ;


 

/

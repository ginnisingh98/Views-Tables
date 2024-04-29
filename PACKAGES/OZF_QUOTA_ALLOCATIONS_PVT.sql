--------------------------------------------------------
--  DDL for Package OZF_QUOTA_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QUOTA_ALLOCATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvqals.pls 115.6 2004/06/10 23:41:31 kvattiku noship $ */




PROCEDURE create_quota_alloc_hierarchy(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_alloc_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


PROCEDURE publish_allocation( p_api_version         IN     NUMBER    DEFAULT 1.0
                            , p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full
                            , p_alloc_id            IN     NUMBER
                            , x_return_status       OUT NOCOPY    VARCHAR2
                            , x_msg_count           OUT NOCOPY    NUMBER
                            , x_msg_data            OUT NOCOPY    VARCHAR2
                            );


PROCEDURE cancel_alloc_hfq(
    p_api_version        IN       NUMBER
  , p_init_msg_list      IN       VARCHAR2
  , p_commit             IN       VARCHAR2
  , p_quota_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


---------------------------------------------------------------------
-- FUNCTION
---   is_root_or_leaf
--
-- PURPOSE
--    This function returns is the quota a leaf/Root quota or otherwise.
--    used to render link to Account allocation page
--
-- HISTORY
--    Tue Dec 02 2003:4/56 PM    RSSHARMA  Created.
--
-- PARAMETERS
--      p_quota_id NUMBER
---------------------------------------------------------------------
FUNCTION is_root_or_leaf(p_quota_id IN NUMBER)return VARCHAR2;

FUNCTION get_unallocated_amount(p_quota_id IN NUMBER)return NUMBER;

FUNCTION get_threshold_name(p_threshold_id IN NUMBER )RETURN VARCHAR2;
END OZF_Quota_allocations_Pvt;

 

/

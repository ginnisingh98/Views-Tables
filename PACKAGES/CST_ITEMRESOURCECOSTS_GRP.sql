--------------------------------------------------------
--  DDL for Package CST_ITEMRESOURCECOSTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ITEMRESOURCECOSTS_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTGIRCS.pls 120.0 2005/05/25 05:57:07 appldev noship $ */

LAST_N_PO_RECEIPTS       CONSTANT  NUMBER  := 5;

-------------------------------------------------------------------------------
--      API name        : Get_ItemCost
--      Type            : Group
--      Function        : Returns item cost for the given item ID,
--                        cost type, and organization.
--      Parameters      :
--      IN              :
--        p_api_version       IN NUMBER       Required
--        p_init_msg_list     IN VARCHAR2     Optional
--                         Default = FND_API.G_FALSE
--        p_commit            IN VARCHAR2     Optional
--                         Default = FND_API.G_FALSE
--        p_validation_level  IN NUMBER       Optional
--                         Default = FND_API.G_VALID_LEVEL_FULL
--        p_item_id           IN NUMBER Required
--        p_organization_id   IN NUMBER Required
--        p_cost_source       IN NUMBER Required
--                         1 - Return item cost from valuation cost type.
--                         2 - Return item cost from user-provided cost type.
--                         3 - Return item cost as the list price per unit
--                             from item definition.
--                         4 - Return item cost as average of the
--                             last 5 PO receipts of this item.
--        p_cost_type_id      IN NUMBER Optional
--                         Default = 0
--
--      OUT             :
--        x_return_status         OUT     VARCHAR2(1)
--        x_msg_count             OUT     NUMBER
--        x_msg_data              OUT     VARCHAR2(2000)
--        x_item_cost             OUT     NUMBER
--        x_currency_code         OUT     VARCHAR2(15)
--              - functional currency of p_organizaiton_id
--
--      Version :
--                        Initial version       1.0
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_ItemCost(
        p_api_version           IN     	        NUMBER,
        p_init_msg_list         IN     	        VARCHAR2   := FND_API.G_FALSE,
        p_commit                IN     	        VARCHAR2   := FND_API.G_FALSE,
        p_validation_level      IN     	        NUMBER     := FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
		p_item_id               IN              NUMBER,
		p_organization_id       IN              NUMBER,
        p_cost_source           IN              NUMBER,
        p_cost_type_id          IN              NUMBER     := 0,
		x_item_cost             OUT NOCOPY      NUMBER,
		x_currency_code         OUT NOCOPY      VARCHAR2
);


-------------------------------------------------------------------------------
--      API name        : Get_ResourceRate
--      Type            : Private
--      Function        : Returns resource rate for the given resource,
--                        cost type, and organization.
--      Parameters      :
--      IN              :
--        p_api_version       IN NUMBER       Required
--        p_init_msg_list     IN VARCHAR2     Optional
--                         Default = FND_API.G_FALSE
--        p_commit            IN VARCHAR2     Optional
--                         Default = FND_API.G_FALSE
--        p_validation_level  IN NUMBER       Optional
--                         Default = FND_API.G_VALID_LEVEL_FULL
--        p_resource_id       IN NUMBER Required
--        p_organization_id   IN NUMBER Required
--        p_cost_type_id      IN NUMBER Optional
--                         Default = 0 -> will then default to AvgRates
--
--      OUT             :
--        x_return_status         OUT     VARCHAR2(1)
--        x_msg_count             OUT     NUMBER
--        x_msg_data              OUT     VARCHAR2(2000)
--        x_resource_rate         OUT     NUMBER
--        x_currency_code         OUT     VARCHAR2(15)
--              - functional currency of p_organizaiton_id
--      Version :
--                        Initial version       1.0
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_ResourceRate(
        p_api_version           IN     	        NUMBER,
        p_init_msg_list         IN     	        VARCHAR2   := FND_API.G_FALSE,
        p_commit                IN     	        VARCHAR2   := FND_API.G_FALSE,
        p_validation_level      IN     	        NUMBER     := FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
		p_resource_id           IN              NUMBER,
		p_organization_id       IN              NUMBER,
        p_cost_type_id          IN              NUMBER     := 0,
		x_resource_rate         OUT NOCOPY      NUMBER,
		x_currency_code         OUT NOCOPY      VARCHAR2
);

END CST_ItemResourceCosts_GRP;

 

/

--------------------------------------------------------
--  DDL for Package Body CST_ITEMRESOURCECOSTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ITEMRESOURCECOSTS_GRP" AS
/* $Header: CSTGIRCB.pls 120.3 2006/02/06 13:36:55 vtkamath noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_ItemResourceCosts_GRP';
G_LOG_HEAD CONSTANT VARCHAR2(40) := 'cst.plsql.'||G_PKG_NAME;
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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
--      Version :
--                        Initial version       1.0
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_ItemCost(
        p_api_version           IN     	        NUMBER,
        p_init_msg_list         IN     	        VARCHAR2,
        p_commit                IN     	        VARCHAR2,
        p_validation_level      IN     	        NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
		p_item_id               IN              NUMBER,
		p_organization_id       IN              NUMBER,
        p_cost_source           IN              NUMBER,
        p_cost_type_id          IN              NUMBER,
		x_item_cost             OUT NOCOPY      NUMBER,
        x_currency_code         OUT NOCOPY      VARCHAR2
) IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_ItemCost';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count          NUMBER := 0;
   l_msg_data           VARCHAR2(8000) := '';
   l_stmt_num           NUMBER := 0;
   l_api_message        VARCHAR2(1000);

   l_cost_type_id       NUMBER;

   l_module   CONSTANT VARCHAR2(100) := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_ItemCost_PVT;

      IF l_procLog THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_ItemCost <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check the value passed in p_cost_type_id
   -- If it's 0, then fetch the cost_type_id for the valuation cost type
   l_cost_type_id := p_cost_type_id;
   if (p_cost_source = 1 OR ((p_cost_source = 2) AND (p_cost_type_id = 0))) then
	  l_stmt_num := 10;

      select primary_cost_method
      into l_cost_type_id
      from mtl_parameters
      where organization_id = p_organization_id;
   end if;

   if (p_cost_source = 1 OR p_cost_source = 2) then
      -- return the item cost from cst_item_costs for the provided combination of inputs
      l_stmt_num := 20;

      select item_cost
      into x_item_cost
      from cst_item_costs
      where organization_id = p_organization_id
      and inventory_item_id = p_item_id
      and cost_type_id = l_cost_type_id;

   elsif (p_cost_source = 3) then
      -- return the item cost from the item definition for the provided organization and item
      l_stmt_num := 30;

      select list_price_per_unit
      into x_item_cost
      from mtl_system_items_b
      where organization_id = p_organization_id
      and inventory_item_id = p_item_id;

   elsif (p_cost_source = 4) then
      -- return the item cost as the average PO price of the last N=5 PO receipts
      l_stmt_num := 40;

      select avg(transaction_cost)
      into x_item_cost
      from mtl_material_transactions
      where transaction_id in
      ( select transaction_id
        from
        ( select transaction_id
          from mtl_material_transactions
          where transaction_action_id = 27
          and transaction_source_type_id = 1
          and organization_id = p_organization_id
          and inventory_item_id = p_item_id
          and transaction_quantity > 0
          order by transaction_id desc)
        where rownum <= CST_ItemResourceCosts_GRP.LAST_N_PO_RECEIPTS);

   else
      raise FND_API.g_exc_unexpected_error;
   end if;

   -- Also return the currency_code
   l_stmt_num := 50;
   select currency_code
   into x_currency_code
   from cst_organization_definitions
   where organization_id =  p_organization_id;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF l_procLog THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Get_ItemCost >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_ItemCost_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK TO Get_ItemCost_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN NO_DATA_FOUND THEN
         ROLLBACK TO Get_ItemCost_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         if (l_stmt_num = 20) then
           l_api_message := 'No item cost exists for the provided cost type, organization, and item.';
         elsif (l_stmt_num = 30) then
           l_api_message := 'No list price is defined in the item definition for this item and organization.';
         elsif (l_stmt_num = 40) then
           l_api_message := 'No PO receipts exist for this item and organization.';
         else
           l_api_message := 'Could not determine the currency code for the organization provided.';
         end if;
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Get_ItemCost - '||l_api_message);
         END IF;
         x_msg_count := 1;
         x_msg_data := l_api_message;

      WHEN OTHERS THEN
         ROLLBACK TO Get_ItemCost_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Get_ItemCost '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         x_msg_count := 1;
         x_msg_data := substr(SQLERRM,1,200);

END Get_ItemCost;


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
        p_init_msg_list         IN     	        VARCHAR2,
        p_commit                IN     	        VARCHAR2,
        p_validation_level      IN     	        NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
		p_resource_id           IN              NUMBER,
		p_organization_id       IN              NUMBER,
        p_cost_type_id          IN              NUMBER,
		x_resource_rate         OUT NOCOPY      NUMBER,
        x_currency_code         OUT NOCOPY      VARCHAR2
) IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'Get_ResourceRate';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count          NUMBER := 0;
   l_msg_data           VARCHAR2(8000) := '';
   l_stmt_num           NUMBER := 0;
   l_api_message        VARCHAR2(1000);

   l_cost_type_id       NUMBER;

   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_ResourceRate_PVT;

      IF l_procLog THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.begin'
             ,'Get_ResourceRate <<');
      END IF;

   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_stmt_num := 10;

    l_cost_type_id := p_cost_type_id;

   -- Check the value passed in p_cost_type_id
   -- If it's 0, then fetch the cost_type_id for the AvgRates cost type
   if (p_cost_type_id = 0) then
      select avg_rates_cost_type_id
      into l_cost_type_id
      from mtl_parameters
      where organization_id = p_organization_id;
   end if;

   l_stmt_num := 20;
   -- return the resource rate from cst_resource_costs for this combination of inputs
   select resource_rate
   into x_resource_rate
   from cst_resource_costs
   where organization_id = p_organization_id
   and resource_id = p_resource_id
   and cost_type_id = l_cost_type_id;

   -- Also return the currency_code
   l_stmt_num := 30;
   select currency_code
   into x_currency_code
   from cst_organization_definitions
   where organization_id = p_organization_id;

   --- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

    -- Standard Call to get message count and if count = 1, get message info
       FND_MSG_PUB.Count_And_Get (
           p_count     => x_msg_count,
           p_data      => x_msg_data );

      IF l_procLog THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,G_LOG_HEAD || '.'||l_api_name||'.end'
             ,'Get_ResourceRate >>');
      END IF;

EXCEPTION
      WHEN FND_API.g_exc_error THEN
         ROLLBACK TO Get_ResourceRate_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
      WHEN FND_API.g_exc_unexpected_error THEN

         ROLLBACK TO Get_ResourceRate_PVT;
         x_return_status := FND_API.g_ret_sts_unexp_error ;
         FND_MSG_PUB.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
          );

      WHEN NO_DATA_FOUND THEN
         ROLLBACK TO Get_ResourceRate_PVT;
         x_return_status := FND_API.g_ret_sts_error;
         if (l_stmt_num = 10) then
           l_api_message := 'No AvgRates cost_type is setup in organization parameters, so no default cost type is available.';
         elsif (l_stmt_num = 20) then
           l_api_message := 'No resource rate is defined for the inputs provided.';
         else
           l_api_message := 'Could not determine the currency code for the organization provided.';
         end if;
         IF l_errorLog THEN
            FND_LOG.string(FND_LOG.LEVEL_ERROR,G_LOG_HEAD || '.'||l_api_name||'.'||l_stmt_num
                ,'Get_ResourceRate - '||l_api_message);
         END IF;
         x_msg_count := 1;
         x_msg_data := l_api_message;

      WHEN OTHERS THEN
         ROLLBACK TO Get_ResourceRate_PVT;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

         IF l_unexpLog THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,G_LOG_HEAD || '.'||l_api_name||l_stmt_num
                ,'Get_ResourceRate '||l_stmt_num||' : '||substr(SQLERRM,1,200));
         END IF;

         x_msg_count := 1;
         x_msg_data := substr(SQLERRM,1,200);

END Get_ResourceRate;

END CST_ItemResourceCosts_GRP;

/

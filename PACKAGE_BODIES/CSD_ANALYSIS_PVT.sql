--------------------------------------------------------
--  DDL for Package Body CSD_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_ANALYSIS_PVT" AS
/* $Header: csdvanab.pls 115.0 2002/11/19 22:29:09 swai noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_ANALYSIS_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvanab.pls';
l_debug       NUMBER := fnd_profile.value('CSD_DEBUG_LEVEL');

/*----------------------------------------------------------------*/
/* procedure name: Get_TotalActCharges                            */
/* description   : procedure used to get total actual charges     */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_repair_line_id             Repair Line ID to get act charges */
/* x_charges                    Total MLE charges for repair line */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalActCharges
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_repair_line_id        IN  NUMBER,
   x_charges               OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_TotalActCharges';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_TotalActCharges_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_TotalActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_TotalActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_TotalActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_TotalActCharges;

/*----------------------------------------------------------------*/
/* procedure name: Get_TotalEstCharges                            */
/* description   : procedure used to get total estimated charges  */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_estimate_header_id         Est Header ID to get est charges  */
/* x_charges                    Total MLE charges for repair line */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalEstCharges
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_estimate_header_id    IN  NUMBER,
   x_charges               OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_TotalEstCharges';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_TotalEstCharges_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_TotalEstCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_TotalEstCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_TotalEstCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_TotalEstCharges;

/*----------------------------------------------------------------*/
/* procedure name: Compare_EstChargesAndCosts                     */
/* description   : procedure used to compare estimated charges to */
/*                 estimated costs                                */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_estimate_header_id         Est Header ID to get est charges  */
/* p_charges                    Total MLE charges for estimate    */
/* x_costs                      MLE Costs for estimate            */
/* x_profit                     MLE Profit                        */
/* x_profit_margin              MLE Profit Margin (%)             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Compare_EstChargesAndCosts
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_estimate_header_id    IN  NUMBER,
   p_charges               IN  CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_costs                 OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_profit                OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_profit_margin         OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Compare_EstChargesAndCosts';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Compare_EstChargesAndCosts_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Compare_EstChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Compare_EstChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Compare_EstChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Compare_EstChargesAndCosts;

/*----------------------------------------------------------------*/
/* procedure name: Compare_ActChargesAndCosts                     */
/* description   : procedure used to compare actual charges to    */
/*                 actual costs                                   */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_repair_line_id             Repair Line ID to get act charges */
/* p_charges                    Total MLE charges for actuals     */
/* x_costs                      MLE Costs for estimate            */
/* x_profit                     MLE Profit                        */
/* x_profit_margin              MLE Profit Margin (%)             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Compare_ActChargesAndCosts
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_repair_line_id        IN  NUMBER,
   p_charges               IN  CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_costs                 OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_profit                OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_profit_margin         OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Compare_ActChargesAndCosts';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Compare_ActChargesAndCosts_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Compare_ActChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Compare_ActChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Compare_ActChargesAndCosts_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Compare_ActChargesAndCosts;

/*----------------------------------------------------------------*/
/* procedure name: Compare_ActChargesAndCosts                     */
/* description   : procedure used to compare actual charges to    */
/*                 actual costs                                   */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_repair_line_id             Repair Line ID to get act charges */
/* p_charges                    Total MLE charges for actuals     */
/* x_costs                      MLE Costs for estimate            */
/* x_profit                     MLE Profit                        */
/* x_profit_margin              MLE Profit Margin (%)             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Compare_EstAndActCharges
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_estimate_header_id    IN  NUMBER,
   p_repair_line_id        IN  NUMBER,
   p_act_charges           IN  CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_est_charges           IN  CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_diff                  OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_pct_diff              OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Compare_EstAndActCharges';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Compare_EstAndActCharges_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Compare_EstAndActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Compare_EstAndActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Compare_EstAndActCharges_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Compare_EstAndActCharges;

/*----------------------------------------------------------------*/
/* procedure name: Get_InvItemCostAnalysis                        */
/* description   : procedure used get item cost, extended cost,   */
/*                 profit, and profit margin (%)                  */
/*                 for an inventory item                          */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_inventory_item_id          Inventory Item ID                 */
/* p_quantity                   Quantity of Inventory Items       */
/* p_organization_id            Inventory Organization ID         */
/* p_charge_amt                 Total Charge Amt to compare to    */
/* p_currency_code              Currency of Charge Amt            */
/* x_item_cost                  Item cost of Inv Item             */
/* x_total_cost                 Extended cost of Inv Item         */
/* x_profit                     x_total_cost - p_charge_amt       */
/* x_profit_margin              x_profit*100/x_item_cost          */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_InvItemCostAnalysis
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_inventory_item_id     IN  NUMBER,
   p_quantity              IN  NUMBER,
   p_organization_id       IN  NUMBER,
   p_charge_amt            IN  NUMBER,
   p_currency_code         IN  VARCHAR2,
   x_item_cost             OUT NOCOPY NUMBER,
   x_total_cost            OUT NOCOPY NUMBER,
   x_profit                OUT NOCOPY NUMBER,
   x_profit_margin         OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_InvItemCostAnalysis';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_InvItemCostAnalysis_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_InvItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_InvItemCostAnalysis;

/*----------------------------------------------------------------*/
/* procedure name: Get_ResItemCostAnalysis                        */
/* description   : procedure used get item cost, extended cost,   */
/*                 profit, and profit margin (%)                  */
/*                 for a bom resource                             */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_bom_resource_id            BOM Resource ID                   */
/* p_quantity                   Quantity of resource              */
/* p_organization_id            Inventory Organization ID         */
/* p_charge_amt                 Total Charge Amt to compare to    */
/* p_currency_code              Currency of Charge Amt            */
/* x_item_cost                  Resource rate of BOM resource     */
/* x_total_cost                 Extended cost of Resource         */
/* x_profit                     x_total_cost - p_charge_amt       */
/* x_profit_margin              x_profit*100/x_item_cost          */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_ResItemCostAnalysis
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   p_bom_resource_id       IN  NUMBER,
   p_quantity              IN  NUMBER,
   p_organization_id       IN  NUMBER,
   p_charge_amt            IN  NUMBER,
   p_currency_code         IN  VARCHAR2,
   x_item_cost             OUT NOCOPY NUMBER,
   x_total_cost            OUT NOCOPY NUMBER,
   x_profit                OUT NOCOPY NUMBER,
   x_profit_margin         OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Get_ResItemCostAnalysis';
   l_api_version             CONSTANT NUMBER := 1.0;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_ResItemCostAnalysis_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Get_ResItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_ResItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_ResItemCostAnalysis_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_ResItemCostAnalysis;

END CSD_ANALYSIS_PVT ;

/

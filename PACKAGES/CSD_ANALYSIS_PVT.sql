--------------------------------------------------------
--  DDL for Package CSD_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_ANALYSIS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvanas.pls 115.3 2002/11/08 23:39:15 swai noship $ */


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
);

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
);

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
);

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
);

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
         );

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
);

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
);

END CSD_ANALYSIS_PVT ;

 

/

--------------------------------------------------------
--  DDL for Package CSD_COST_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_COST_ANALYSIS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvanas.pls 115.6 2004/02/06 22:16:27 sangigup noship $ */



 /*----------------------------------------------------------------*/

  /* procedure name: Get_TotalEstCharges                              */

  /* description   : procedure used to get total estimated costs    */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Estimate ID to get est costs      */

  /* p_ro_currency_code           Repair Order Currency Code        */

  /* x_costs                      Total MLE costs for repair line   */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/
  PROCEDURE Get_TotalEstCharges(p_api_version IN NUMBER,
                                p_commit IN VARCHAR2,
                                p_init_msg_list IN VARCHAR2,
                                p_validation_level IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_repair_estimate_id IN NUMBER,
                                p_ro_currency_code IN VARCHAR2,
                                x_charges OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE);
  /*----------------------------------------------------------------*/

/* procedure name: Get_TotalEstCosts                              */

  /* description   : procedure used to get total estimated costs    */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Estimate ID to get est costs      */

  /* p_organization_id            Organization Id                   */

  /* p_ro_currency_code           Repair Order Currency Code        */

  /* x_costs                      Total MLE costs for repair line   */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Get_TotalEstCosts(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                              p_init_msg_list IN VARCHAR2,
                              p_validation_level IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_repair_estimate_id IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_ro_currency_code IN VARCHAR2,
                              x_costs OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE);

  /*----------------------------------------------------------------*/

  /* procedure name: Compare_EstChargesAndCosts                     */

  /* description   : procedure used to compare estimated charges to */

  /*                 estimated costs                                */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_repair_estimate_id         Estimate ID to get est charges    */

  /* p_organization_id           Organization Id                   */

  /* p_ro_currency_code           Repair Order Currency Code       */

  /* x_charges                    Total MLE charges for estimate    */

  /* x_costs                      MLE Costs for estimate            */

  /* x_profit                     MLE Profit                        */

  /* x_profit_margin              MLE Profit Margin (%)             */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Compare_EstChargesAndCosts(p_api_version IN NUMBER,
                                       p_commit IN VARCHAR2,
                                       p_init_msg_list IN VARCHAR2,
                                       p_validation_level IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2,
                                       x_msg_count OUT NOCOPY NUMBER,
                                       x_msg_data OUT NOCOPY VARCHAR2,
                                       p_repair_estimate_id IN NUMBER,
                                       p_organization_id IN NUMBER,
                                       p_ro_currency_code IN VARCHAR2,
                                       x_charges OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_costs OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_profit OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
                                       x_profit_margin OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE);

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

  /*
     PROCEDURE Compare_ActChargesAndCosts
     (
     p_api_version           IN  NUMBER,
     p_commit                IN  VARCHAR2,
     p_init_msg_list         IN  VARCHAR2,
     p_validation_level      IN  NUMBER,
     p_repair_line_id        IN  NUMBER,
     p_charges               IN  CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_costs                 OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_profit                OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_profit_margin         OUT NOCOPY CSD_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2
     );
     */

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

  /*
     PROCEDURE Compare_EstAndActCharges
     (
     p_api_version           IN  NUMBER,
     p_commit                IN  VARCHAR2,
     p_init_msg_list         IN  VARCHAR2,
     p_validation_level      IN  NUMBER,
     p_estimate_header_id    IN  NUMBER,
     p_repair_line_id        IN  NUMBER,
     p_act_charges           IN  CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_est_charges           IN  CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_diff                  OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_pct_diff              OUT NOCOPY CSD_COST_ANALYSIS_UTIL.MLE_TOTALS_REC_TYPE,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2
     );
     */

  /*----------------------------------------------------------------*/

  /* procedure name: Get_InvItemCost                                */

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

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Get_InvItemCost(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                            p_init_msg_list IN VARCHAR2,
                            p_validation_level IN NUMBER,
			    x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data OUT NOCOPY VARCHAR2,
                            p_inventory_item_id IN NUMBER,
                            p_organization_id IN NUMBER,
                            p_charge_date IN DATE,
                            p_currency_code IN VARCHAR2,
			    p_chg_line_uom_code IN VARCHAR2,
                            x_item_cost OUT NOCOPY NUMBER
                           );
/*----------------------------------------------------------------*/

/* procedure name: Get_ResItemCost                                */

/* description   : procedure used get resource item cost          */

/*                 for a bom resource                             */
/* This will eb called to obtain labor item cost. If a resource id is */
/* passed, then resource cost will be returned in x_item_Cost     */
/* If resource_id is not passed then cost is obtained from the labor */
/* inventory item. */

/* This is a new API. During code review it was suggested that    */

/* since it will never be called independently, there is no need  */
/* to use standard input parameters. Hence I am removing them in  */
/* the new API.                                                   */

/* x_return_status              Standard OUT param                */

/* x_msg_count                  Standard OUT param                */

/* x_msg_data                   Standard OUT param                */

/* p_inventory_item_id		Inventory item id                 */
/* p_organization_id            Inventory Organization ID         */

/* p_bom_resource_id            BOM Resource ID                   */
/*p_charge_date			Charge date                       */

/* p_currency_code              Currency of Charge Amt            */

/* x_item_cost                  Resource rate of BOM resource     */


/*                                                                */

/*----------------------------------------------------------------*/


   PROCEDURE Get_ResItemCost
   (
		x_return_status OUT NOCOPY VARCHAR2,
                x_msg_count OUT NOCOPY NUMBER,
                x_msg_data OUT NOCOPY VARCHAR2,
                p_inventory_item_id IN NUMBER,
                p_organization_id IN NUMBER,
		p_bom_resource_id IN NUMBER,
                p_charge_date IN DATE,
                p_currency_code IN VARCHAR2,
		p_chg_line_uom_code IN VARCHAR2,
                x_item_cost OUT NOCOPY NUMBER
   );

END CSD_COST_ANALYSIS_PVT ;

 

/

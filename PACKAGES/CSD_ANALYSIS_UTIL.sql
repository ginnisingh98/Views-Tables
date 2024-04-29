--------------------------------------------------------
--  DDL for Package CSD_ANALYSIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_ANALYSIS_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdvanus.pls 115.3 2002/11/08 23:36:49 swai noship $ */


/*----------------------------------------------------------------*/
/* record name:  MLE_TOTALS_REC_TYPE                            */
/* description:  Record used to hold totals                     */
/*                                                                */
/*----------------------------------------------------------------*/
TYPE MLE_TOTALS_REC_TYPE IS RECORD
(  MATERIALS         NUMBER,
   LABOR             NUMBER,
   EXPENSES          NUMBER,
   MLE_TOTAL         NUMBER,
   CURRENCY_CODE     VARCHAR2(15));


/*----------------------------------------------------------------*/
/* function name: Get_CurrencyCode                                */
/* description  : Gets the currency from GL_SETS_OF_BOOKS for an  */
/*                organization                                    */
/*                                                                */
/* p_organization_id            Organization ID to get currency   */
/*                                                                */
/*----------------------------------------------------------------*/
FUNCTION Get_CurrencyCode (
   p_organization_id   IN   NUMBER
)
RETURN VARCHAR2;

/*----------------------------------------------------------------*/
/* procedure name: Convert_CurrencyAmount                         */
/* description   : Converts an amount from one currency to        */
/*                 another currency                               */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_from_currency              Currency code to convert from     */
/* p_to_currency                Currency code to convert to       */
/* p_eff_date                   Conversion Date                   */
/* p_amount                     Amount to convert                 */
/* p_conv_type                  Conversion type                   */
/* x_conv_amount                Converted amount                  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Convert_CurrencyAmount (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_from_currency         IN     VARCHAR2,
   p_to_currency           IN     VARCHAR2,
   p_eff_date              IN     DATE,
   p_amount                IN     NUMBER,
   p_conv_type             IN     VARCHAR2,
   x_conv_amount           OUT NOCOPY    NUMBER,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
);

/*----------------------------------------------------------------*/
/* procedure name: Get_TotalActCosts                              */
/* description   : Given a repair line id, gets the total MLE     */
/*                 actual costs.                                  */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_repair_line_id             Repair Line ID to get actual costs*/
/* p_currency_code              Currency to convert costs to      */
/* x_costs                      Total MLE costs for repair line   */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalActCosts
(
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_repair_line_id        IN     NUMBER,
   p_currency_code         IN     VARCHAR2,  --currency to convert costs to
   x_costs                 OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
);


/*----------------------------------------------------------------*/
/* procedure name: Get_TotalEstCosts                              */
/* description   : Given an estimate header, gets the total MLE   */
/*                 estimated costs.                               */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_estimate_header_id         Est header ID to get est costs for*/
/* p_currency_code              Currency to convert costs to      */
/* x_costs                      Total MLE costs for repair line   */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_TotalEstCosts (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_estimate_header_id    IN     NUMBER,
   x_costs                 OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
);

/*----------------------------------------------------------------*/
/* procedure name: Compare_MLETotals                              */
/* description   : Compares any two records of                    */
/*                 MLE_total_record_type by amount and percent.   */
/*                 Difference is calculated by basis - compare.   */
/*                 Percent is determined by dividing difference   */
/*                 by the basis. If currencies are different,     */
/*                 Difference will be in currency of compare amts */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_mle_totals_basis           Totals to use as basis            */
/* p_mle_totals_compare         Totals to compare to basis        */
/* x_diff                       Basis - Compare                   */
/* x_pct_diff                   (Basis - Compare)*100/Basis       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Compare_MLETotals (
   p_api_version           IN     NUMBER,
   p_commit                IN     VARCHAR2,
   p_init_msg_list         IN     VARCHAR2,
   p_validation_level      IN     NUMBER,
   p_mle_totals_basis      IN     MLE_TOTALS_REC_TYPE,
   p_mle_totals_compare    IN     MLE_TOTALS_REC_TYPE,
   x_diff                  OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_pct_diff              OUT NOCOPY    MLE_TOTALS_REC_TYPE,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2
);

END CSD_ANALYSIS_UTIL ;

 

/

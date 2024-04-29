--------------------------------------------------------
--  DDL for Package CSD_COST_ANALYSIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_COST_ANALYSIS_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdvanus.pls 115.5 2003/10/29 00:39:56 sangigup noship $ */
/*----------------------------------------------------------------*/
/* record name:  MLE_TOTALS_REC_TYPE                            */
/* description:  Record used to hold totals                     */
/*                                                                */
/*----------------------------------------------------------------*/
  TYPE MLE_TOTALS_REC_TYPE IS RECORD (
    MATERIALS     NUMBER,
    LABOR         NUMBER,
    EXPENSES      NUMBER,
    MLE_TOTAL     NUMBER,
    CURRENCY_CODE VARCHAR2(15)
  );
  /*----------------------------------------------------------------*/
  /* function name: Get_GLCurrencyCode                              */

  /* description  : Gets the currency from GL_SETS_OF_BOOKS for an  */

  /*                organization                                    */

  /*                                                                */

  /* p_organization_id            Organization ID to get currency   */

  /*                                                                */

  /*----------------------------------------------------------------*/

  FUNCTION Get_GLCurrencyCode(p_organization_id IN NUMBER) RETURN VARCHAR2;
  /*----------------------------------------------------------------*/

  /* procedure name: Convert_CurrencyAmount                         */

  /* description   : Converts an amount from one currency to        */

  /*                 another currency                               */

  /*                                                                */

  /* p_api_version                Standard IN param                 */

  /* p_commit                     Standard IN param                 */

  /* p_init_msg_list              Standard IN param                 */

  /* p_validation_level           Standard IN param                 */

  /* p_from_currency              Required Currency code to convert from     */

  /* p_to_currency                Required Currency code to convert to       */

  /* p_eff_date                   Required Conversion Date                   */

  /* p_amount                    Required  Amount to convert                 */

  /* x_conv_amount                Converted amount                  */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Convert_CurrencyAmount(p_api_version IN NUMBER,
                                   p_commit IN VARCHAR2,
                                   p_init_msg_list IN VARCHAR2,
                                   p_validation_level IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2,
                                   p_from_currency IN VARCHAR2,
                                   p_to_currency IN VARCHAR2,
                                   p_eff_date IN DATE,
                                   p_amount                IN     NUMBER,
                                   x_conv_amount OUT NOCOPY NUMBER);




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

  /* p_mle_totals_basis           Required Totals to use as basis            */

  /* p_mle_totals_compare         Required Totals to compare to basis        */

  /* x_diff                       Basis - Compare                   */

  /* x_pct_diff                   (Basis - Compare)*100/Basis       */

  /* x_return_status              Standard OUT param                */

  /* x_msg_count                  Standard OUT param                */

  /* x_msg_data                   Standard OUT param                */

  /*                                                                */

  /*----------------------------------------------------------------*/

  PROCEDURE Compare_MLETotals(p_api_version IN NUMBER, p_commit IN VARCHAR2,
                              p_init_msg_list IN VARCHAR2,
                              p_validation_level IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_mle_totals_basis IN MLE_TOTALS_REC_TYPE,
                              p_mle_totals_compare IN MLE_TOTALS_REC_TYPE,
                              x_diff OUT NOCOPY MLE_TOTALS_REC_TYPE,
                              x_pct_diff OUT NOCOPY MLE_TOTALS_REC_TYPE);
  /*----------------------------------------------------------------*/

  /* function  name: Validate_CostingEnabled        */

  /* description   : Given an organization_id, returns TRUE if the  */

  /*         Organization is costing enabled.       */

  /* p_organization_id  IN    NUMBER            */

  /*                                                                */

  /*----------------------------------------------------------------*/

  FUNCTION Validate_CostingEnabled(p_organization_id IN NUMBER) RETURN BOOLEAN;
END CSD_COST_ANALYSIS_UTIL;


 

/

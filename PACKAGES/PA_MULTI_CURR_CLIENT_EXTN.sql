--------------------------------------------------------
--  DDL for Package PA_MULTI_CURR_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MULTI_CURR_CLIENT_EXTN" AUTHID CURRENT_USER AS
/*  $Header: PAPMCECS.pls 120.5 2006/07/29 11:40:17 skannoji noship $  */
/*#
 * This extension is used to override the default attributes used to convert the transfer price from the transaction
 * currency to the functional currency.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Transfer Price Currency Conversion Override Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-------------------------------------------------------------------------------
  -- Client extension to override Currency Conversion attributes
/**
 * This procedure is used to override the currency conversion attributes when converting transfer price.
 * @param p_project_id The Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Task identifier
 * @rep:paraminfo {@rep:required}
 * @param p_transcation_class The hard coded value "Transfer Price"
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_id Expenditure item identifier
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type_class The type class of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type Expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_category Expenditure category
 * @rep:paraminfo {@rep:required}
 * @param p_from_currency_code Currency to convert from
 * @rep:paraminfo {@rep:required}
 * @param p_to_currency_code Currency to convert to
 * @rep:paraminfo {@rep:required}
 * @param p_conversion_type Default exchange rate type to be used for conversion
 * @rep:paraminfo {@rep:required}
 * @param p_conversion_date Default exchange rate date to be used for conversion
 * @rep:paraminfo {@rep:required}
 * @param x_rate_type Override exchange rate type.If user rate type is being used, pass User
 * @rep:paraminfo {@rep:required}
 * @param x_rate_date Override exchange rate date
 * @rep:paraminfo {@rep:required}
 * @param x_exchange_rate Override exchange rate to be used for rate type of User only
 * @rep:paraminfo {@rep:required}
 * @param x_error_message Error message text
 * @rep:paraminfo {@rep:required}
 * @param X_Status  Status indicating whether an error occurred. The valid values are =0 (Success), <0 OR >0 (Application Error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Override Currency Conversion Attributes
 * @rep:compatibility S
*/
PROCEDURE Override_Curr_Conv_Attributes(
        p_project_id                    IN      Number,
 	p_task_id                       IN      Number,
	p_transaction_class             IN      Varchar2,
        p_expenditure_item_id           IN      Number,
        p_expenditure_type_class        IN      Varchar2,
        p_expenditure_type              IN      Varchar2,
	p_expenditure_category          IN      Varchar2,
	p_from_currency_code            IN      Varchar2,
	p_to_currency_code              IN      Varchar2,
        p_conversion_type               IN      Varchar2,
	p_conversion_date               IN      Date,
        x_rate_type                     OUT      NOCOPY Varchar2,  --File.Sql.39 bug 4440895
	x_rate_date                     OUT      NOCOPY Date, --File.Sql.39 bug 4440895
	x_exchange_rate                 OUT      NOCOPY Number, --File.Sql.39 bug 4440895
        x_error_message                 OUT      NOCOPY Varchar2,  --File.Sql.39 bug 4440895
        x_status                        OUT      NOCOPY Number  --File.Sql.39 bug 4440895
        );

--------------------------------------------------------------------------------

END PA_MULTI_CURR_CLIENT_EXTN ;

 

/

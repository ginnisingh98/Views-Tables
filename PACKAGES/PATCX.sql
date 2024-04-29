--------------------------------------------------------
--  DDL for Package PATCX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PATCX" AUTHID CURRENT_USER AS
/* $Header: PAXTTCXS.pls 120.4 2006/07/29 11:39:50 skannoji noship $ */
/*#
 * Oracle Projects provides a template package that contains a procedure that you can modify to implement
 * transaction control extensions. The name of the package is patcx. The name of the procedure is tc_extension.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Transaction Control Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/


/*#
* Procedure that can be modified to implement transaction control extensions
* @param X_project_id The identifier of the project
* @rep:paraminfo {@rep:required}
* @param X_task_id The identifier of the task
* @rep:paraminfo {@rep:required}
* @param X_expenditure_item_date The date of the expenditure item
* @rep:paraminfo {@rep:required}
* @param X_expenditure_type The type of expenditure
* @rep:paraminfo {@rep:required}
* @param X_non_labor_resource The nonlabor resource; for usage items only
* @rep:paraminfo {@rep:required}
* @param X_incurred_by_person_id The identifier of the person incurring the transaction
* @rep:paraminfo {@rep:required}
* @param X_quantity   The quantity of the transaction
* @rep:paraminfo {@rep:required}
* @param X_denom_currency_code The transaction currency code
* @rep:paraminfo {@rep:required}
* @param X_acct_currency_code The functional currency code
* @rep:paraminfo {@rep:required}
* @param X_denom_raw_cost   The transaction currency raw cost
* @rep:paraminfo {@rep:required}
* @param X_acct_raw_cost    The functional currency raw cost
* @rep:paraminfo {@rep:required}
* @param X_acct_rate_type The functional currency exchange rate type
* @rep:paraminfo {@rep:required}
* @param X_acct_rate_date The functional currency exchange rate date
* @rep:paraminfo {@rep:required}
* @param X_acct_exchange_rate The functional currency exchange rate
* @rep:paraminfo {@rep:required}
* @param X_transferred_from_id The identifier of the original expenditure item for which a new item is interfacing to a new project
* @rep:paraminfo {@rep:required}
* @param X_incurred_by_org_id The organization incurring the transaction
* @rep:paraminfo {@rep:required}
* @param X_nl_resource_org_id The identifier of the non labor resource organization; for usages only
* @rep:paraminfo {@rep:required}
* @param X_transaction_source The transaction source of items imported using Transaction Import
* @rep:paraminfo {@rep:required}
* @param X_calling_module   The module calling the extension
* @rep:paraminfo {@rep:required}
* @param X_vendor_id The identifier for the supplier transaction attribute
* @rep:paraminfo {@rep:required}
* @param X_entered_by_user_id The identifier of the user that entered the transaction
* @rep:paraminfo {@rep:required}
* @param X_attribute_category  Descriptive flexfield category
* @rep:paraminfo {@rep:required}
* @param X_attribute1 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute2 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute3 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute4 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute5 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute6 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute7 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute8 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute9 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute10 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute11 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute12 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute13 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute14 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute15 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_msg_application The application short name for the custom application providing customized messages
* @rep:paraminfo {@rep:required}
* @param X_billable_flag Flag indicating whether or not a transaction is billable or capitalizable
* @rep:paraminfo {@rep:required}
* @param X_msg_type  Message type: W = warning message, E = error message
* @rep:paraminfo {@rep:required}
* @param X_msg_token1 Message tokens used in warning messages
* @rep:paraminfo {@rep:required}
* @param X_msg_token2 Message tokens used in warning messages
* @rep:paraminfo {@rep:required}
* @param X_msg_token3 Message tokens used in warning messages
* @rep:paraminfo {@rep:required}
* @param X_msg_count Total number of messages populated by the API
* @rep:paraminfo {@rep:required}
* @param X_outcome The outcome of the procedure
* @rep:paraminfo {@rep:required}
* @param p_projfunc_currency_code Identifier of the functional currency of the project-owning operating unit
* @rep:paraminfo {@rep:required}
* @param p_projfunc_cost_rate_type Identifier of the exchange rate type used to convert the
* transaction cost amounts to the project functional currency
* @rep:paraminfo {@rep:required}
* @param p_projfunc_cost_rate_date Identifier of the exchange rate date used to convert the
* transaction cost amounts to the project functional currency
* @rep:paraminfo {@rep:required}
* @param p_projfunc_cost_exchg_rate Identifier of the exchange rate used to convert the transaction
* cost amounts to the project functional currency
* @rep:paraminfo {@rep:required}
* @param x_assignment_id Identifier of the Project Resource Management assignment associated with the transaction
* @rep:paraminfo {@rep:required}
* @param p_work_type_id  Identifier of the work type assigned to the transaction
* @rep:paraminfo {@rep:required}
* @param p_sys_link_function Expenditure type class of the transaction
* @rep:paraminfo {@rep:required}
* @param p_po_header_id Purchase order header identifier for imported contingent worker labor transactions
* @rep:paraminfo {@rep:required}
* @param p_po_line_id Purchase order line identifier for imported contingent worker labor transactions
* @rep:paraminfo {@rep:required}
* @param p_person_type Person type identifier
* @rep:paraminfo {@rep:required}
* @param p_po_price_type Purchase order line price type for contingent worker labor transactions
* @rep:paraminfo {@rep:required}
* @param p_document_type The supplier cost document type
* @rep:paraminfo {@rep:required}
* @param p_document_line_type The supplier cost document line type
* @rep:paraminfo {@rep:required}
* @param p_document_dist_type The supplier cost document distribution type
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num1 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num2 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num3 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num4 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num5 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num6 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num7 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num8 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num9 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_num10 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var1 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var2 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var3 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var4 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var5 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var6 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var7 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var8 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var9 For future use
* @rep:paraminfo {@rep:required}
* @param p_pa_ref_var10 For future use
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Transaction Control Extension
* @rep:compatibility S
*/
  PROCEDURE  tc_extension (
              X_project_id               IN NUMBER
            , X_task_id                  IN NUMBER
            , X_expenditure_item_date    IN DATE
            , X_expenditure_type         IN VARCHAR2
            , X_non_labor_resource       IN VARCHAR2
            , X_incurred_by_person_id    IN NUMBER
            , X_quantity                 IN NUMBER   DEFAULT NULL
            , X_denom_currency_code      IN VARCHAR2 DEFAULT NULL
            , X_acct_currency_code       IN VARCHAR2 DEFAULT NULL
            , X_denom_raw_cost           IN NUMBER   DEFAULT NULL
            , X_acct_raw_cost            IN NUMBER   DEFAULT NULL
            , X_acct_rate_type           IN VARCHAR2 DEFAULT NULL
            , X_acct_rate_date           IN DATE     DEFAULT NULL
            , X_acct_exchange_rate       IN NUMBER   DEFAULT NULL
            , X_transferred_from_id      IN NUMBER   DEFAULT NULL
            , X_incurred_by_org_id       IN NUMBER   DEFAULT NULL
            , X_nl_resource_org_id       IN NUMBER   DEFAULT NULL
            , X_transaction_source       IN VARCHAR2 DEFAULT NULL
            , X_calling_module           IN VARCHAR2 DEFAULT NULL
	    , X_vendor_id	         IN NUMBER   DEFAULT NULL
            , X_entered_by_user_id       IN NUMBER   DEFAULT NULL
            , X_attribute_category       IN VARCHAR2 DEFAULT NULL
            , X_attribute1               IN VARCHAR2 DEFAULT NULL
            , X_attribute2               IN VARCHAR2 DEFAULT NULL
            , X_attribute3               IN VARCHAR2 DEFAULT NULL
            , X_attribute4               IN VARCHAR2 DEFAULT NULL
            , X_attribute5               IN VARCHAR2 DEFAULT NULL
            , X_attribute6               IN VARCHAR2 DEFAULT NULL
            , X_attribute7               IN VARCHAR2 DEFAULT NULL
            , X_attribute8               IN VARCHAR2 DEFAULT NULL
            , X_attribute9               IN VARCHAR2 DEFAULT NULL
            , X_attribute10              IN VARCHAR2 DEFAULT NULL
	    , X_attribute11              IN VARCHAR2 DEFAULT NULL
            , X_attribute12              IN VARCHAR2 DEFAULT NULL
            , X_attribute13              IN VARCHAR2 DEFAULT NULL
            , X_attribute14              IN VARCHAR2 DEFAULT NULL
            , X_attribute15              IN VARCHAR2 DEFAULT NULL
            , X_msg_application      IN OUT NOCOPY VARCHAR2
            , X_billable_flag        IN  OUT NOCOPY VARCHAR2
            , X_msg_type                 OUT NOCOPY VARCHAR2
            , X_msg_token1               OUT NOCOPY VARCHAR2
            , X_msg_token2               OUT NOCOPY VARCHAR2
            , X_msg_token3               OUT NOCOPY VARCHAR2
            , X_msg_count                OUT NOCOPY NUMBER
            , X_outcome                  OUT NOCOPY VARCHAR2
            , P_projfunc_currency_code   IN VARCHAR2 default null
            , P_projfunc_cost_rate_type  IN VARCHAR2 default null
            , P_projfunc_cost_rate_date  IN DATE     default null
            , P_projfunc_cost_exchg_rate IN NUMBER   default null
            , X_assignment_id        IN  OUT NOCOPY NUMBER
            , P_work_type_id             IN NUMBER   default null
	    , P_sys_link_function        IN VARCHAR2 default null
            , P_Po_Header_Id             IN NUMBER   default null
	    , P_Po_Line_Id               IN NUMBER   default null
	    , P_Person_Type              IN VARCHAR2 default null
	    , P_Po_Price_Type            IN VARCHAR2 default null
		     , P_Document_Type           IN  VARCHAR2   default null -- Added these for R12
		     , P_Document_Line_Type      IN  VARCHAR2   default null
		     , P_Document_Dist_Type      IN  VARCHAR2   default null
		     , P_pa_ref_num1             IN  NUMBER     default null
		     , P_pa_ref_num2             IN  NUMBER     default null
		     , P_pa_ref_num3             IN  NUMBER     default null
		     , P_pa_ref_num4             IN  NUMBER     default null
		     , P_pa_ref_num5             IN  NUMBER     default null
		     , P_pa_ref_num6             IN  NUMBER     default null
		     , P_pa_ref_num7             IN  NUMBER     default null
		     , P_pa_ref_num8             IN  NUMBER     default null
		     , P_pa_ref_num9             IN  NUMBER     default null
		     , P_pa_ref_num10            IN  NUMBER     default null
		     , P_pa_ref_var1             IN  VARCHAR2   default null
		     , P_pa_ref_var2             IN  VARCHAR2   default null
		     , P_pa_ref_var3             IN  VARCHAR2   default null
		     , P_pa_ref_var4             IN  VARCHAR2   default null
		     , P_pa_ref_var5             IN  VARCHAR2   default null
		     , P_pa_ref_var6             IN  VARCHAR2   default null
		     , P_pa_ref_var7             IN  VARCHAR2   default null
		     , P_pa_ref_var8             IN  VARCHAR2   default null
		     , P_pa_ref_var9             IN  VARCHAR2   default null
		     , P_pa_ref_var10            IN  VARCHAR2   default null)  ;


END  PATCX;

 

/

--------------------------------------------------------
--  DDL for Package PA_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EVENT_PUB" AUTHID DEFINER AS
/* $Header: PAEVAPBS.pls 120.9 2007/02/07 10:41:55 rgandhi noship $ */
/*#
 * This package contains the public APIs, which provide an open interface for the external systems to insert,
 * update, and delete events.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Billing Events
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_BILLING_EVENT
 * @rep:category BUSINESS_ENTITY PA_REVENUE
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/* Global Constants */
PACKAGE_NAME            VARCHAR2(200) :=NULL;
PROCEDURE_NAME          VARCHAR2(200) :=NULL;

g_api_version_number            NUMBER := 1.0;

Type Event_Rec_In_Type is RECORD
(p_pm_event_reference	         VARCHAR2(25)
,P_task_number		         VARCHAR2(25)     Default NULL
,p_event_number		         NUMBER	    	  Default NULL
,P_event_type		         VARCHAR2(30)
,P_agreement_number              VARCHAR2(50)     Default NULL  -- Federal Uptake
,P_agreement_type  		 VARCHAR2(30)     Default NULL  -- Federal Uptake
,P_customer_number   		 VARCHAR2(30)     Default NULL  -- federal Uptake
,P_description		         VARCHAR2(250)    Default NULL
,P_bill_hold_flag	         VARCHAR2(1)      Default NULL
,P_completion_date	         DATE
,P_desc_flex_name	         VARCHAR2(240)    Default NULL
,P_attribute_category	         VARCHAR2(30)     Default NULL
,P_attribute1		         VARCHAR2(150)    Default NULL
,P_attribute2		         VARCHAR2(150)    Default NULL
,P_attribute3	                 VARCHAR2(150)    Default NULL
,P_attribute4		         VARCHAR2(150)    Default NULL
,P_attribute5		         VARCHAR2(150)    Default NULL
,P_attribute6		         VARCHAR2(150)    Default NULL
,P_attribute7		         VARCHAR2(150)    Default NULL
,P_attribute8		         VARCHAR2(150)    Default NULL
,P_attribute9		         VARCHAR2(150)    Default NULL
,P_attribute10		         VARCHAR2(150)    Default NULL
,P_project_number	         VARCHAR2(25)
,P_organization_name	         VARCHAR2(240)
,P_inventory_org_name	         VARCHAR2(240)    Default NULL
,P_inventory_item_id	         NUMBER	          Default NULL
,P_quantity_billed	         NUMBER	          Default NULL
,P_uom_code		         VARCHAR2(3)      Default NULL
,P_unit_price		         NUMBER	     	  Default NULL
,P_reference1		         VARCHAR2(240)    Default NULL
,P_reference2		         VARCHAR2(240)    Default NULL
,P_reference3		         VARCHAR2(240)    Default NULL
,P_reference4		         VARCHAR2(240)    Default NULL
,P_reference5		    	 VARCHAR2(240)    Default NULL
,P_reference6		    	 VARCHAR2(240)    Default NULL
,P_reference7		    	 VARCHAR2(240)    Default NULL
,P_reference8		       	 VARCHAR2(240)    Default NULL
,P_reference9		    	 VARCHAR2(240)    Default NULL
,P_reference10		   	 VARCHAR2(240)    Default NULL
,P_bill_trans_currency_code      VARCHAR2(15)     Default NULL
,P_bill_trans_bill_amount	 NUMBER		  Default NULL
,P_bill_trans_rev_amount	 NUMBER		  Default NULL
,P_project_rate_type		 VARCHAR2(30)     Default NULL
,P_project_rate_date		 DATE		  Default NULL
,P_project_exchange_rate	 NUMBER		  Default NULL
,P_projfunc_rate_type		 VARCHAR2(30)     Default NULL
,P_projfunc_rate_date		 DATE		  Default NULL
,P_projfunc_exchange_rate	 NUMBER		  Default NULL
,P_funding_rate_type		 VARCHAR2(30)     Default NULL
,P_funding_rate_date		 DATE		  Default NULL
,P_funding_exchange_rate	 NUMBER   	  Default NULL
,P_adjusting_revenue_flag	 VARCHAR2(1)      Default NULL
,P_event_id			 NUMBER		  Default NULL
,P_deliverable_id                NUMBER           Default NULL
,P_action_id                     NUMBER           Default NULL
,P_context                       VARCHAR2(1)      Default NULL
,P_record_version_number         NUMBER           Default NULL
);

Type Event_Rec_Out_Type is RECORD
( pm_event_reference	Varchar2(25)
 ,Event_Id		Number(15)
 ,Return_status		Varchar2(1)
 );


TYPE event_in_tbl_type is TABLE of Event_Rec_In_Type
Index by binary_integer;

TYPE event_out_tbl_type is TABLE of Event_Rec_Out_Type
Index by binary_integer;

--If the event data is input in scalar form these will put into these
--global PL/SQL tables before events can be created or updated.
G_event_in_tbl          Event_In_Tbl_Type;
G_event_out_tbl		Event_Out_Tbl_Type;
G_event_tbl_count       NUMBER :=0;

/*#
 * This API creates an event or a set of events.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_event_in_tbl The reference code that uniquely identifies the event input record in Oracle projects
 * @rep:paraminfo {@rep:required}
 * @param p_event_out_tbl The reference code that uniquely identifies the event output record in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Billing Event
 * @rep:compatibility S
*/
PROCEDURE create_event
( p_api_version_number   IN      NUMBER
,p_commit               IN      VARCHAR2
,p_init_msg_list        IN      VARCHAR2
,p_pm_product_code      IN      VARCHAR2
,p_event_in_tbl         IN      Event_In_Tbl_Type
,p_event_out_tbl        OUT     NOCOPY Event_Out_Tbl_Type  --File.Sql.39 bug 4440895
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API updates an event or set of events.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_event_in_tbl The reference code that uniquely identifies the event input record in Oracle projects
 * @rep:paraminfo {@rep:required}
 * @param p_event_out_tbl The reference code that uniquely identifies the event output record in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Billing Event
 * @rep:compatibility S
*/
PROCEDURE UPDATE_EVENT
( p_api_version_number   IN      NUMBER
,p_commit               IN      VARCHAR2
,p_init_msg_list        IN      VARCHAR2
,p_pm_product_code      IN      VARCHAR2
,p_event_in_tbl         IN      Event_In_Tbl_Type
,p_event_out_tbl        OUT     NOCOPY Event_Out_Tbl_Type --File.Sql.39 bug 4440895
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API deletes an event.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_event_reference The reference code that uniquely identifies the event in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_event_id The reference code that uniquely identifies the event in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Billing Event
 * @rep:compatibility S
*/
PROCEDURE DELETE_EVENT
(p_api_version_number   IN      NUMBER
,p_commit               IN      VARCHAR2
,p_init_msg_list        IN      VARCHAR2
,p_pm_product_code      IN      VARCHAR2
,p_pm_event_reference   IN      VARCHAR2
,p_event_id             IN      NUMBER
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API sets the global tables used by the Load Execute Fetch procedures that create a new event or
 * update an existing event.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_EVENT
 * LOAD_EVENT
 * EXECUTE_CREATE_EVENT/EXECUTE_UPDATE_EVENT
 * FETCH_EVENT
 * CLEAR_EVENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Billing Events-Initialize
 * @rep:compatibility S
*/
PROCEDURE INIT_EVENT;

/*#
 * This API loads an event to a PL/SQL record.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_EVENT
 * LOAD_EVENT
 * EXECUTE_CREATE_EVENT/EXECUTE_UPDATE_EVENT
 * FETCH_EVENT
 * CLEAR_EVENT
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_event_reference The reference code that uniquely identifies the event in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_number The number that identifies the task in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_event_number The number that identifies the event
 * @rep:paraminfo {@rep:required}
 * @param p_event_type The event type that classifies the event
 * @rep:paraminfo {@rep:required}
 * @param p_description Description of the event
 * @rep:paraminfo {@rep:required}
 * @param p_bill_hold_flag Flag indicating that the event is held from invoicing
 * @rep:paraminfo {@rep:required}
 * @param p_completion_date The date on which the event is complete and after which the event is processed
 * for revenue accrual and/or invoicing
 * @rep:paraminfo {@rep:required}
 * @param p_desc_flex_name Descriptive flexfield name
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_project_number The project number associated with the event
 * @rep:paraminfo {@rep:required}
 * @param p_organization_name The organization associated with the event
 * @rep:paraminfo {@rep:required}
 * @param p_inventory_org_name The inventory organization associated with the event
 * @rep:paraminfo {@rep:required}
 * @param p_inventory_item_id The inventory item identifier associated with the event
 * @rep:paraminfo {@rep:required}
 * @param p_quantity_billed The quantity billed for the event
 * @rep:paraminfo {@rep:required}
 * @param p_uom_code The unit of measure for the event
 * @rep:paraminfo {@rep:required}
 * @param p_unit_price The unit price for the event
 * @rep:paraminfo {@rep:required}
 * @param p_reference1 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference2 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference3 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference4 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference5 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference6 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference7 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference8 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference9 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_reference10 Reference column
 * @rep:paraminfo {@rep:required}
 * @param p_bill_trans_currency_code Billing transaction currency code
 * @rep:paraminfo {@rep:required}
 * @param p_bill_trans_bill_amount Billing transaction billing amount
 * @rep:paraminfo {@rep:required}
 * @param p_bill_trans_rev_amount Billing transaction revenue amount
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from event currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from event currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from event currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from event currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date Exchange rate date to use for conversion from event currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from event currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_rate_type Exchange rate type to use for conversion from event currency to funding currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_rate_date Exchange rate date to use for conversion from event currency to funding currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_exchange_rate Exchange rate to use for conversion from event currency to funding currency
 * @rep:paraminfo {@rep:required}
 * @param p_adjusting_revenue_flag Flag indicating revenue adjustment
 * @rep:paraminfo {@rep:required}
 * @param p_event_id The reference code that uniquely identifies the event in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Billing Events - Load
 * @rep:compatibility S
*/
PROCEDURE LOAD_EVENT
(p_pm_product_code               IN      VARCHAR2
,P_api_version_number            IN      NUMBER
,P_init_msg_list                 IN      VARCHAR2
,P_pm_event_reference            IN      VARCHAR2
,P_task_number                   IN      VARCHAR2
,P_event_number                  IN      NUMBER
,P_event_type                    IN      VARCHAR2
,P_agreement_number              IN      VARCHAR2   -- Federal Uptake
,P_agreement_type                IN      VARCHAR2   -- Federal Uptake
,P_customer_number               IN      VARCHAR2   -- Federal Uptake
,P_description                   IN      VARCHAR2
,P_bill_hold_flag                IN      VARCHAR2
,P_completion_date               IN      DATE
,P_desc_flex_name                IN      VARCHAR2
,P_attribute_category            IN      VARCHAR2
,P_attribute1                    IN      VARCHAR2
,P_attribute2                    IN      VARCHAR2
,P_attribute3                    IN      VARCHAR2
,P_attribute4                    IN      VARCHAR2
,P_attribute5                    IN      VARCHAR2
,P_attribute6                    IN      VARCHAR2
,P_attribute7                    IN      VARCHAR2
,P_attribute8                    IN      VARCHAR2
,P_attribute9                    IN      VARCHAR2
,P_attribute10                   IN      VARCHAR2
,P_project_number                IN      VARCHAR2
,P_organization_name             IN      VARCHAR2
,P_inventory_org_name            IN      VARCHAR2
,P_inventory_item_id             IN      NUMBER
,P_quantity_billed               IN      NUMBER
,P_uom_code                      IN      VARCHAR2
,P_unit_price                    IN      NUMBER
,P_reference1                    IN      VARCHAR2
,P_reference2                    IN      VARCHAR2
,P_reference3                    IN      VARCHAR2
,P_reference4                    IN      VARCHAR2
,P_reference5                    IN      VARCHAR2
,P_reference6                    IN      VARCHAR2
,P_reference7                    IN      VARCHAR2
,P_reference8                    IN      VARCHAR2
,P_reference9                    IN      VARCHAR2
,P_reference10                   IN      VARCHAR2
,P_bill_trans_currency_code      IN      VARCHAR2
,P_bill_trans_bill_amount        IN      NUMBER
,P_bill_trans_rev_amount         IN      NUMBER
,P_project_rate_type             IN      VARCHAR2
,P_project_rate_date             IN      DATE
,P_project_exchange_rate         IN      NUMBER
,P_projfunc_rate_type            IN      VARCHAR2
,P_projfunc_rate_date            IN      DATE
,P_projfunc_exchange_rate        IN      NUMBER
,P_funding_rate_type             IN      VARCHAR2
,P_funding_rate_date             IN      DATE
,P_funding_exchange_rate         IN      NUMBER
,P_adjusting_revenue_flag        IN      VARCHAR2
,P_event_id                      IN      NUMBER
,P_return_status                 OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API creates an event using the information, which is stored in the global tables during the Load phase.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_EVENT
 * LOAD_EVENT
 * EXECUTE_CREATE_EVENT/EXECUTE_UPDATE_EVENT
 * FETCH_EVENT
 * CLEAR_EVENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_event_id_out The reference code that uniquely identifies the event in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Billing Events - Execute Create
 * @rep:compatibility S
*/
PROCEDURE EXECUTE_CREATE_EVENT
(p_api_version_number   IN      NUMBER
,p_commit               IN      VARCHAR2
,p_init_msg_list        IN      VARCHAR2
,p_pm_product_code      IN      VARCHAR2
,p_event_id_out         OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API updates event data using the information stored in the global tables during the load phase.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_EVENT
 * LOAD_EVENT
 * EXECUTE_CREATE_EVENT/EXECUTE_UPDATE_EVENT
 * FETCH_EVENT
 * CLEAR_EVENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Billing Events-Update
 * @rep:compatibility S
*/
PROCEDURE EXECUTE_UPDATE_EVENT
(p_api_version_number   IN      NUMBER
,p_commit               IN      VARCHAR2
,p_init_msg_list        IN      VARCHAR2
,p_pm_product_code      IN      VARCHAR2
,p_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,p_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API gets the return status during creation of an event and stores the value in a global PL/SQL table.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_event_reference The reference code that uniquely identifies the event in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_event_id_out The reference code that uniquely identifies the event in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Billing Events - Fetch
 * @rep:compatibility S
*/
PROCEDURE FETCH_EVENT
(p_api_version_number           IN              NUMBER
,P_pm_product_code              IN              VARCHAR2
,P_pm_event_reference           IN              VARCHAR2
,P_event_id_out                 OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
,p_return_status                OUT             NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
 * This API clears the global values that were created during initialization.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_EVENT
 * LOAD_EVENT
 * EXECUTE_CREATE_EVENT/EXECUTE_UPDATE_EVENT
 * FETCH_EVENT
 * CLEAR_EVENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Billing Events - Clear
 * @rep:compatibility S
*/
PROCEDURE CLEAR_EVENT;

/*#
 * This API checks whether an event can be deleted.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be commited
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code Identifier of the external project management system from which the project was imported
 * @rep:paraminfo {@rep:required}
 * @param p_pm_event_reference The reference code that uniquely identifies the event in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_event_id The reference code that uniquely identifies the event in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_del_event_ok_flag Boolean flag for deleting an event
 * @rep:paraminfo {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Billing Event Deletion
 * @rep:compatibility S
*/
PROCEDURE CHECK_DELETE_EVENT_OK
(P_api_version_number   IN      NUMBER
,P_commit               IN      VARCHAR2
,P_init_msg_list        IN      VARCHAR2
,P_pm_product_code      IN      VARCHAR2
,P_pm_event_reference   IN      VARCHAR2
,P_event_id             IN      NUMBER
,P_del_event_ok_flag    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
,P_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,P_return_status        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END PA_EVENT_PUB;

/

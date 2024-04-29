--------------------------------------------------------
--  DDL for Package PA_REV_CA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REV_CA" AUTHID CURRENT_USER AS
/*$Header: PAXICOSS.pls 120.5 2006/07/25 06:37:08 lveerubh noship $*/
/*#
 * This extension is used to apply your company's business rules to the
 * cost accrual procedures.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Cost Accrual[Billing] Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:category BUSINESS_ENTITY PA_REVENUE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

-- Package specification for cost accrual billing extension template

-- Specification for main procedure to calculate and generate the cost accrual entries
--

/*#
* This is the main procedure for calculating and generating the cost accrual entries.
* @param X_project_id  The identifier of the project
* @rep:paraminfo {@rep:required}
* @param X_top_task_id The identifier of the top task
* @rep:paraminfo {@rep:required}
* @param X_calling_process Specifies whether the revenue or invoice program is calling the
* billing extension. The valid values are Revenue or Invoice.
* @rep:paraminfo {@rep:required}
* @param X_calling_place Specifies whether the billing extension is called in the revenue
* or invoice program. The valid values are PRE, POST,REG, or ADJ.
* @rep:paraminfo {@rep:required}
* @param X_amount  Amount of the transaction
* @rep:paraminfo {@rep:required}
* @param X_percentage  Cost accrual percentage
* @rep:paraminfo {@rep:required}
* @param X_rev_or_bill_date The accrue through date if called by revenue generation, or the
* bill through date if called by invoice generation.
* @rep:paraminfo {@rep:required}
* @param X_billing_assignment_id The identifier of the billing assignment associated with the transaction
* @rep:paraminfo {@rep:required}
* @param X_billing_extension_id  The identifier of the billing extension that is being processed. Use
* this to select information (such as descriptive flexfield values) from the billing extension definition.
* @rep:paraminfo {@rep:required}
* @param X_request_id   Request identifier
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Cost Accrual Calculation
* @rep:compatibility S
*/
PROCEDURE calc_ca_amt
		(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE DEFAULT NULL,
                     	X_billing_assignment_id    IN     NUMBER DEFAULT NULL,
                     	X_billing_extension_id     IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL
                 )
;

--
-- Specification for procedure that displays the cost accrual columns in PSI
-- Will be invoked from PSI client extension
--
/*#
* This procedure displays the cost accrual columns in Project Status Inquiry.
* @param x_project_id The identifier of the project
* @rep:paraminfo {@rep:required}
* @param x_task_id The identifier of the task
* @rep:paraminfo {@rep:required}
* @param x_resource_list_member_id Identifier of the resource list member
* @rep:paraminfo {@rep:required}
* @param x_cost_budget_type_code Cost budget type code
* @rep:paraminfo {@rep:required}
* @param x_rev_budget_type_code Revenue budget type code
* @rep:paraminfo {@rep:required}
* @param x_status_view  The identifier of the status folder: projects, tasks, or resources
* @rep:paraminfo {@rep:required}
* @param x_pa_install The identifier of the Oracle Projects product installed:
* Oracle Project Billing or Oracle Project Costing. Billing includes all default PSI columns.
* Costing includes all except the actual revenue and revenue budget columns.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_1 The derived columns with alphanumeric values. Each
* column can have up to 255 characters.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_2 The derived columns with alphanumeric values. Each
* column can have up to 255 characters.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_3 The derived columns with alphanumeric values. Each
* column can have up to 255 characters.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_4 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_5 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_6 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_7 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_8 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_9 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_10 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_11 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_12 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_13 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_14 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_15 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_16 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_17 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_18 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_19 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_20 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_21 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_22 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_23 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_24 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_25 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_26 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_27 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_28 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_29 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_30 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_31 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_32 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param x_derived_col_33 The derived columns with numeric values
* @rep:paraminfo {@rep:required}
* @param p_revenue_ptd Percentage for accruing period-to-date revenue
* @rep:paraminfo {@rep:required}
* @param p_revenue_itd Percentage for accruing inception-to-date revenue
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname PSI Cost Accrual
* @rep:compatibility S
*/



PROCEDURE get_psi_cols (
		  	x_project_id			        IN NUMBER
			, x_task_id				IN NUMBER
			, x_resource_list_member_id		IN NUMBER
			, x_cost_budget_type_code		IN VARCHAR2
			, x_rev_budget_type_code		IN VARCHAR2
			, x_status_view				IN VARCHAR2
			, x_pa_install				IN VARCHAR2
			, x_derived_col_1			OUT NOCOPY VARCHAR2
			, x_derived_col_2			OUT NOCOPY VARCHAR2
			, x_derived_col_3			OUT NOCOPY VARCHAR2
			, x_derived_col_4			OUT NOCOPY NUMBER
			, x_derived_col_5			OUT NOCOPY NUMBER
			, x_derived_col_6			OUT NOCOPY NUMBER
			, x_derived_col_7			OUT NOCOPY NUMBER
			, x_derived_col_8			OUT NOCOPY NUMBER
			, x_derived_col_9			OUT NOCOPY NUMBER
			, x_derived_col_10			OUT NOCOPY NUMBER
			, x_derived_col_11			OUT NOCOPY NUMBER
			, x_derived_col_12			OUT NOCOPY NUMBER
			, x_derived_col_13			OUT NOCOPY NUMBER
			, x_derived_col_14			OUT NOCOPY NUMBER
			, x_derived_col_15			OUT NOCOPY NUMBER
			, x_derived_col_16			OUT NOCOPY NUMBER
			, x_derived_col_17			OUT NOCOPY NUMBER
			, x_derived_col_18			OUT NOCOPY NUMBER
			, x_derived_col_19			OUT NOCOPY NUMBER
			, x_derived_col_20			OUT NOCOPY NUMBER
			, x_derived_col_21			OUT NOCOPY NUMBER
			, x_derived_col_22			OUT NOCOPY NUMBER
			, x_derived_col_23			OUT NOCOPY NUMBER
			, x_derived_col_24			OUT NOCOPY NUMBER
			, x_derived_col_25			OUT NOCOPY NUMBER
			, x_derived_col_26			OUT NOCOPY NUMBER
			, x_derived_col_27			OUT NOCOPY NUMBER
			, x_derived_col_28			OUT NOCOPY NUMBER
			, x_derived_col_29			OUT NOCOPY NUMBER
			, x_derived_col_30			OUT NOCOPY NUMBER
			, x_derived_col_31			OUT NOCOPY NUMBER
			, x_derived_col_32			OUT NOCOPY NUMBER
			, x_derived_col_33			OUT NOCOPY NUMBER
			, p_revenue_ptd 			IN NUMBER
			, p_revenue_itd 			IN NUMBER
			);
--
-- Specification for procedure that pre-requisites before project close
-- for cost accrual.
-- Will be invoked from the project status change client extension
--

/*#
* This procedure is called when a user changes the projects status.
* @param x_calling_module Module from which the extension is called
* @rep:paraminfo {@rep:required}
* @param X_project_id  The identifier of the project
* @rep:paraminfo {@rep:required}
* @param X_old_proj_status_code Existing status code for the project
* @rep:paraminfo {@rep:required}
* @param X_new_proj_status_code New status code for the project
* @rep:paraminfo {@rep:required}
* @param X_project_type Project type of the project
* @rep:paraminfo {@rep:required}
* @param X_project_start_date Start date of the project
* @rep:paraminfo {@rep:required}
* @param X_project_end_date End date of the project
* @rep:paraminfo {@rep:required}
* @param X_public_sector_flag Flag indicating the public sector
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
* @param x_pm_product_code The project management product code
* @rep:paraminfo {@rep:required}
* @param x_err_code The error handling code
* @rep:paraminfo {@rep:required}
* @param x_warnings_only_flag Flag indicating if the procedure had only warning messages
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Verify Project Status for Cost Accrual
* @rep:compatibility S
*/


PROCEDURE Verify_Project_Status_CA
            (x_calling_module           IN VARCHAR2
            ,X_project_id               IN NUMBER
            ,X_old_proj_status_code     IN VARCHAR2
            ,X_new_proj_status_code     IN VARCHAR2
            ,X_project_type             IN VARCHAR2
            ,X_project_start_date       IN DATE
            ,X_project_end_date         IN DATE
            ,X_public_sector_flag       IN VARCHAR2
            ,X_attribute_category       IN VARCHAR2
            ,X_attribute1               IN VARCHAR2
            ,X_attribute2               IN VARCHAR2
            ,X_attribute3               IN VARCHAR2
            ,X_attribute4               IN VARCHAR2
            ,X_attribute5               IN VARCHAR2
            ,X_attribute6               IN VARCHAR2
            ,X_attribute7               IN VARCHAR2
            ,X_attribute8               IN VARCHAR2
            ,X_attribute9               IN VARCHAR2
            ,X_attribute10              IN VARCHAR2
            ,x_pm_product_code          IN VARCHAR2
            ,x_err_code               OUT NOCOPY NUMBER
            ,x_warnings_only_flag     OUT NOCOPY VARCHAR2
	   );
--
-- Procedure that checks if project has cost accrual and sets the
-- variables from attribute columns 11-15 of billing extension
--

/*#
* This procedure checks whether a project has cost accrual, and sets the
* variables from attribute columns 11 through 15 of the billing extension.
* @param p_project_id The identifier of the project
* @rep:paraminfo {@rep:required}
* @param x_cost_accrual_flag Flag indicating if the project has cost accrual
* @rep:paraminfo {@rep:required}
* @param x_funding_flag Flag indicating whether the project has funding
* @rep:paraminfo {@rep:required}
* @param x_ca_event_type  Cost accrual event type
* @rep:paraminfo {@rep:required}
* @param x_ca_contra_event_type Cost accrual contra event type
* @rep:paraminfo {@rep:required}
* @param x_ca_wip_event_type Cost accrual WIP event type
* @rep:paraminfo {@rep:required}
* @param x_ca_budget_type Cost accrual budget type
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Check Cost Accrual
* @rep:compatibility S
*/
PROCEDURE   Check_if_Cost_Accrual ( p_project_id   IN NUMBER
                          ,x_cost_accrual_flag     IN OUT NOCOPY VARCHAR2
                          ,x_funding_flag          IN OUT NOCOPY VARCHAR2
                          ,x_ca_event_type         IN OUT NOCOPY VARCHAR2
                          ,x_ca_contra_event_type  IN OUT NOCOPY VARCHAR2
                          ,x_ca_wip_event_type     IN OUT NOCOPY VARCHAR2
                          ,x_ca_budget_type        IN OUT NOCOPY VARCHAR2
                         );

END pa_rev_ca;

/

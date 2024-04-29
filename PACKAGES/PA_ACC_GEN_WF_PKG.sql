--------------------------------------------------------
--  DDL for Package PA_ACC_GEN_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACC_GEN_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXWFACS.pls 120.4.12000000.3 2007/06/15 11:42:48 rmsubram ship $ */

/* Bug# 3182416 :Moved the declaration of g_ variables from body to spec */

g_error_message VARCHAR2(1000) DEFAULT NULL;
g_error_stack   VARCHAR2(500)  DEFAULT NULL;
g_error_stage   VARCHAR2(100)  DEFAULT NULL;

/* Bug 5233487 - Added new variable to store the the encoded error message */
g_encoded_error_message VARCHAR2(2000) := NULL;

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name	: pa_acc_gen_wf_pkg.wf_acc_derive_params
--
-- Type		: Public
--
-- Pre-reqs	: None
--
-- Function	: This procedure is called from the Oracle Payables and Oracle
--		  Purchasing prior to calling Workflow for account generation.
-- 		  The procedure accepts five input parameters and derives
--		  the value of the other parameters which are then available to the
--		  calling program.  The objective is to provide all the parameters
--		  (input and output) as attributes with values in them when workflow
--		  is invoked so that the user does not have to code/call any functions
--		  to retrieve the values of those variables.
--
--
-- Parameters	:
--		p_project_id			IN  NUMBER	Required
--		p_task_id			IN  NUMBER
--		p_expenditure_type		IN  VARCHAR2
--		p_vendor_id 			IN  NUMBER	Required
--		p_expenditure_organization_id	IN  NUMBER
--		p_expenditure_item_date 	IN  DATE
--		x_class_code			OUT VARCHAR2
--		x_direct_flag			OUT VARCHAR2
--		x_expenditure_category		OUT VARCHAR2
--		x_expenditure_org_name		OUT VARCHAR2
--		x_project_number		OUT VARCHAR2
--		x_project_organization_name	OUT VARCHAR2
--		x_project_organization_id	OUT NUMBER
--		x_project_type			OUT VARCHAR2
--		x_public_sector_flag		OUT VARCHAR2
--		x_revenue_category		OUT VARCHAR2
--		x_task_number			OUT VARCHAR2
--		x_task_organization_name	OUT VARCHAR2
--		x_task_organization_id		OUT NUMBER
--		x_task_service_type		OUT VARCHAR2
--		x_top_task_id			OUT NUMBER
--		x_top_task_number		OUT VARCHAR2
--		x_vendor_employee_id		OUT NUMBER
--		x_vendor_employee_number	OUT VARCHAR2
--		x_vendor_type			OUT VARCHAR2
--
-- Version	: Initial version	11.0
--
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE wf_acc_derive_params (
		p_project_id			IN  pa_projects_all.project_id%TYPE,
		p_task_id			IN  pa_tasks.task_id%TYPE,
		p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
		p_vendor_id 			IN  po_vendors.vendor_id%type,
		p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
		p_expenditure_item_date 	IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
		x_class_code			OUT NOCOPY pa_class_codes.class_code%TYPE,
		x_direct_flag			OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
		x_expenditure_category		OUT NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
		x_expenditure_org_name		OUT NOCOPY hr_organization_units.name%TYPE,
		x_project_number		OUT NOCOPY pa_projects_all.segment1%TYPE,
		x_project_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
		x_project_organization_id	OUT NOCOPY hr_organization_units.organization_id %TYPE,
		x_project_type			OUT NOCOPY pa_project_types_all.project_type%TYPE,
		x_public_sector_flag		OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
		x_revenue_category		OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
		x_task_number			OUT NOCOPY pa_tasks.task_number%TYPE,
		x_task_organization_name	OUT NOCOPY hr_organization_units.name%TYPE,
		x_task_organization_id		OUT NOCOPY hr_organization_units.organization_id %TYPE,
		x_task_service_type		OUT NOCOPY pa_tasks.service_type_code%TYPE,
		x_top_task_id			OUT NOCOPY pa_tasks.task_id%TYPE,
		x_top_task_number		OUT NOCOPY pa_tasks.task_number%TYPE,
		x_vendor_employee_id		OUT NOCOPY per_people_f.person_id%TYPE,
		x_vendor_employee_number	OUT NOCOPY per_people_f.employee_number%TYPE,
		x_vendor_type			OUT NOCOPY po_vendors.vendor_type_lookup_code%TYPE);

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.wf_acc_derive_er_params
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Oracle web expenses
--                prior to calling Workflow for account generation.
--                The procedure accepts ten input parameters and derives
--                the value of the other parameters which are then available to the
--                calling program.  The objective is to provide all the parameters
--                (input and output) as attributes with values in them when workflow
--                is invoked so that the user does not have to code/call any functions
--                to retrieve the values of those variables.
--
--
-- Parameters   :
--              p_project_id                    IN  NUMBER      Required
--              p_task_id                       IN  NUMBER
--              p_expenditure_type              IN  VARCHAR2
--              p_vendor_id                     IN  NUMBER      Required
--              p_expenditure_organization_id   IN  NUMBER
--              p_expenditure_item_date         IN  DATE
--              p_calling_module                IN  VARCHAR2
--              p_employee_id                   IN  NUMBER
--              p_employee_ccid                 IN  OUT NUMBER
--              p_expense_type                  IN  VARCHAR2
--              p_expense_cc                    IN  VARCHAR2
--              x_class_code                    OUT VARCHAR2
--              x_direct_flag                   OUT VARCHAR2
--              x_expenditure_category          OUT VARCHAR2
--              x_expenditure_org_name          OUT VARCHAR2
--              x_project_number                OUT VARCHAR2
--              x_project_organization_name     OUT VARCHAR2
--              x_project_organization_id       OUT NUMBER
--              x_project_type                  OUT VARCHAR2
--              x_public_sector_flag            OUT VARCHAR2
--              x_revenue_category              OUT VARCHAR2
--              x_task_number                   OUT VARCHAR2
--              x_task_organization_name        OUT VARCHAR2
--              x_task_organization_id          OUT NUMBER
--              x_task_service_type             OUT VARCHAR2
--              x_top_task_id                   OUT NUMBER
--              x_top_task_number               OUT VARCHAR2
--              x_vendor_employee_number        OUT VARCHAR2
--              x_vendor_type                   OUT VARCHAR2
--
-- Version      : Initial version       11.0
--
-- End of comments
--------------------------------------------------------------------------------
--

 PROCEDURE wf_acc_derive_er_params (
                p_project_id                    IN  pa_projects_all.project_id%TYPE,
                p_task_id                       IN  pa_tasks.task_id%TYPE,
                p_expenditure_type              IN  pa_expenditure_types.expenditure_type%TYPE,
                p_vendor_id                     IN  po_vendors.vendor_id%type,
                p_expenditure_organization_id   IN  hr_organization_units.organization_id%TYPE,
                p_expenditure_item_date         IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
		p_calling_module		IN  VARCHAR2,
		p_employee_id			IN  per_people_f.person_id%TYPE,
		p_employee_ccid			IN  OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
		p_expense_type			IN  ap_expense_report_lines_all.web_parameter_id%TYPE,
		p_expense_cc			IN  ap_expense_report_headers_all.flex_concatenated%TYPE,
                x_class_code                    OUT NOCOPY pa_class_codes.class_code%TYPE,
                x_direct_flag                   OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
                x_expenditure_category          OUT NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
                x_expenditure_org_name          OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_number                OUT NOCOPY pa_projects_all.segment1%TYPE,
                x_project_organization_name     OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_organization_id       OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_project_type                  OUT NOCOPY pa_project_types_all.project_type%TYPE,
                x_public_sector_flag            OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
                x_revenue_category              OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
                x_task_number                   OUT NOCOPY pa_tasks.task_number%TYPE,
                x_task_organization_name        OUT NOCOPY hr_organization_units.name%TYPE,
                x_task_organization_id          OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_task_service_type             OUT NOCOPY pa_tasks.service_type_code%TYPE,
                x_top_task_id                   OUT NOCOPY pa_tasks.task_id%TYPE,
                x_top_task_number               OUT NOCOPY pa_tasks.task_number%TYPE,
                x_employee_number        	OUT NOCOPY per_people_f.employee_number%TYPE,
                x_vendor_type                   OUT NOCOPY po_vendors.vendor_type_lookup_code%TYPE,
                x_person_type                   OUT NOCOPY VARCHAR2 );

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.wf_acc_derive_pa_params
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the procedures wf_acc_derive_
--                params and wf_acc_derive_er_params .
--                The procedure accepts five input parameters and derives
--                the value of the other project related parameters which
--                are then available to the calling program.  The objective is
--       	  to provide all the parameters (input and output) as
--		  attributes with values in them when workflow
--                is invoked so that the user does not have to code/call any
--		  functions to retrieve the values of those variables. This
--		  procedure derives the projects related attributes.
--
--
-- Parameters   :
--              p_project_id                    IN  NUMBER      Required
--              p_task_id                       IN  NUMBER	Required
--              p_expenditure_type              IN  VARCHAR2    Required
--              p_expenditure_organization_id   IN  NUMBER	Required
--              p_expenditure_item_date         IN  DATE	Required
--              x_class_code                    OUT NOCOPY VARCHAR2
--              x_direct_flag                   OUT NOCOPY VARCHAR2
--              x_expenditure_category          OUT NOCOPY VARCHAR2
--              x_expenditure_org_name          OUT NOCOPY VARCHAR2
--              x_project_number                OUT NOCOPY VARCHAR2
--              x_project_organization_name     OUT NOCOPY VARCHAR2
--              x_project_organization_id       OUT NOCOPY NUMBER
--              x_project_type                  OUT NOCOPY VARCHAR2
--              x_public_sector_flag            OUT NOCOPY VARCHAR2
--              x_revenue_category              OUT NOCOPY VARCHAR2
--              x_task_number                   OUT NOCOPY VARCHAR2
--              x_task_organization_name        OUT NOCOPY VARCHAR2
--              x_task_organization_id          OUT NOCOPY NUMBER
--              x_task_service_type             OUT NOCOPY VARCHAR2
--              x_top_task_id                   OUT NOCOPY NUMBER
--              x_top_task_number               OUT NOCOPY VARCHAR2
--
-- Version      : Initial version       11.0
--
-- End of comments
--------------------------------------------------------------------------------
--

 PROCEDURE wf_acc_derive_pa_params (
                p_project_id                    IN  pa_projects_all.project_id%TYPE,
                p_task_id                       IN  pa_tasks.task_id%TYPE,
                p_expenditure_type              IN  pa_expenditure_types.expenditure_type%TYPE,
                p_expenditure_organization_id   IN  hr_organization_units.organization_id%TYPE,
                p_expenditure_item_date         IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
                x_class_code                    OUT NOCOPY pa_class_codes.class_code%TYPE,
                x_direct_flag                   OUT NOCOPY pa_project_types_all.direct_flag%TYPE,
                x_expenditure_category          OUT NOCOPY pa_expenditure_categories.expenditure_category%TYPE,
                x_expenditure_org_name          OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_number                OUT NOCOPY pa_projects_all.segment1%TYPE,
                x_project_organization_name     OUT NOCOPY hr_organization_units.name%TYPE,
                x_project_organization_id       OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_project_type                  OUT NOCOPY pa_project_types_all.project_type%TYPE,
                x_public_sector_flag            OUT NOCOPY pa_projects_all.public_sector_flag%TYPE,
                x_revenue_category              OUT NOCOPY pa_expenditure_types.revenue_category_code%TYPE,
                x_task_number                   OUT NOCOPY pa_tasks.task_number%TYPE,
                x_task_organization_name        OUT NOCOPY hr_organization_units.name%TYPE,
                x_task_organization_id          OUT NOCOPY hr_organization_units.organization_id %TYPE,
                x_task_service_type             OUT NOCOPY pa_tasks.service_type_code%TYPE,
                x_top_task_id                   OUT NOCOPY pa_tasks.task_id%TYPE,
                x_top_task_number               OUT NOCOPY pa_tasks.task_number%TYPE);


--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.Set_Pa_Item_Attr
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API is called from the Oracle Payables and Orcale
-- 		  Web Expenses. It assigns values to all project related
--		  Workflow item attributes so that when workflow account
--		  generator is invoked it has all the project related
--		  attributes to generate the account.
--
-- Parameters   :
--      p_itemtype                      IN  VARCHAR2    Required
--      p_itemkey                       IN  VARCHAR2    Required
--	p_project_id			IN  NUMBER
--	p_task_id			IN  NUMBER
--	p_expenditure_type		IN  VARCHAR2
--	p_expenditure_organization_id	IN  NUMBER
--	p_billable_flag			IN  VARCHAR2
--      p_class_code                  IN VARCHAR2
--      p_direct_flag                 IN VARCHAR2
--      p_expenditure_category        IN VARCHAR2
--      p_expenditure_org_name        IN VARCHAR2
--      p_project_number              IN VARCHAR2
--      p_project_organization_name   IN VARCHAR2
--      p_project_organization_id     IN NUMBER
--      p_project_type                IN VARCHAR2
--      p_public_sector_flag          IN VARCHAR2
--      p_revenue_category            IN VARCHAR2
--      p_task_number                 IN VARCHAR2
--      p_task_organization_name      IN VARCHAR2
--      p_task_organization_id        IN NUMBER
--      p_task_service_type           IN VARCHAR2
--      p_top_task_id                 IN NUMBER
--      p_top_task_number             IN VARCHAR2
-------------------------------------------------------------------------------

  PROCEDURE Set_Pa_Item_Attr(
	p_itemtype 			IN  VARCHAR2,
	p_itemkey			IN  VARCHAR2,
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
        p_expenditure_item_date         IN  DATE,
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
        p_class_code                    IN pa_class_codes.class_code%TYPE,
        p_direct_flag                   IN pa_project_types_all.direct_flag%TYPE,
        p_expenditure_category          IN pa_expenditure_categories.expenditure_category%TYPE,
        p_expenditure_org_name          IN hr_organization_units.name%TYPE,
        p_project_number                IN pa_projects_all.segment1%TYPE,
        p_project_organization_name     IN hr_organization_units.name%TYPE,
        p_project_organization_id       IN hr_organization_units.organization_id %TYPE,
        p_project_type                  IN pa_project_types_all.project_type%TYPE,
        p_public_sector_flag            IN pa_projects_all.public_sector_flag%TYPE,
        p_revenue_category              IN pa_expenditure_types.revenue_category_code%TYPE,
        p_task_number                   IN pa_tasks.task_number%TYPE,
        p_task_organization_name        IN hr_organization_units.name%TYPE,
        p_task_organization_id          IN hr_organization_units.organization_id %TYPE,
        p_task_service_type             IN pa_tasks.service_type_code%TYPE,
        p_top_task_id                   IN pa_tasks.task_id%TYPE,
        p_top_task_number               IN pa_tasks.task_number%TYPE);


----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name	: pa_acc_gen_wf_pkg.ap_inv_generate_account
--
-- Type		: Public
--
-- Pre-reqs	: None
--
-- Function	: This API is called from the AP form for account generation
-- generation for Project related AP invoices. It accepts the raw
-- parameters from the calling form and calls the wf_acc_derive_params
-- procedure to obtain the derive parameters. It sets the attributes
-- of the Workflow item and then invokes Workflow for account
-- generation.
--
-- Parameters	:
--		p_project_id			IN  NUMBER	Required
--		p_task_id			IN  NUMBER	Required
--		p_expenditure_type		IN  VARCHAR2	Required
--		p_vendor_id 			IN  NUMBER	Required
--		p_expenditure_organization_id	IN  NUMBER	Required
--		p_expenditure_item_date 	IN  DATE	Required
--		p_billable_flag			IN  CHAR	Required
--		p_chart_of_accounts_id		IN  NUMBER	Required
--              p_accounting_date               IN  DATE        Required
--		p_attribute_category		IN  VARCHAR2
--		p_attribute1 through
--		p_attribute15 			IN  VARCHAR2
--		p_dist_attribute_category	IN  VARCHAR2
--		p_dist_attribute1 through
--		p_dist_attribute15 		IN  VARCHAR2
--		x_return_ccid			OUT NUMBER
--		x_concat_segs			IN OUT VARCHAR2
--		x_concat_ids			IN OUT VARCHAR2
--		x_concat_descrs			IN OUT VARCHAR2
--		x_error_message			OUT VARCHAR2
--
-- Version	: Initial version	11.0
--
-- End of comments
----------------------------------------------------------------------------------

  FUNCTION ap_inv_generate_account
  (
	p_project_id			IN  pa_projects_all.project_id%TYPE,
	p_task_id			IN  pa_tasks.task_id%TYPE,
	p_expenditure_type		IN  pa_expenditure_types.expenditure_type%TYPE,
	p_vendor_id 			IN  po_vendors.vendor_id%type,
	p_expenditure_organization_id	IN  hr_organization_units.organization_id%TYPE,
	p_expenditure_item_date 	IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
	p_billable_flag			IN  pa_tasks.billable_flag%TYPE,
	p_chart_of_accounts_id		IN  NUMBER,
	p_attribute_category		IN  ap_invoices_all.attribute_category%TYPE,
	p_attribute1			IN  ap_invoices_all.attribute1%TYPE,
	p_attribute2			IN  ap_invoices_all.attribute2%TYPE,
	p_attribute3			IN  ap_invoices_all.attribute3%TYPE,
	p_attribute4			IN  ap_invoices_all.attribute4%TYPE,
	p_attribute5			IN  ap_invoices_all.attribute5%TYPE,
	p_attribute6			IN  ap_invoices_all.attribute6%TYPE,
	p_attribute7			IN  ap_invoices_all.attribute7%TYPE,
	p_attribute8			IN  ap_invoices_all.attribute8%TYPE,
	p_attribute9			IN  ap_invoices_all.attribute9%TYPE,
	p_attribute10			IN  ap_invoices_all.attribute10%TYPE,
	p_attribute11			IN  ap_invoices_all.attribute11%TYPE,
	p_attribute12			IN  ap_invoices_all.attribute12%TYPE,
	p_attribute13			IN  ap_invoices_all.attribute13%TYPE,
	p_attribute14			IN  ap_invoices_all.attribute14%TYPE,
	p_attribute15			IN  ap_invoices_all.attribute15%TYPE,
	p_dist_attribute_category	IN  ap_invoice_distributions_all.attribute_category%TYPE,
	p_dist_attribute1		IN  ap_invoice_distributions_all.attribute1%TYPE,
	p_dist_attribute2		IN  ap_invoice_distributions_all.attribute2%TYPE,
	p_dist_attribute3		IN  ap_invoice_distributions_all.attribute3%TYPE,
	p_dist_attribute4		IN  ap_invoice_distributions_all.attribute4%TYPE,
	p_dist_attribute5		IN  ap_invoice_distributions_all.attribute5%TYPE,
	p_dist_attribute6		IN  ap_invoice_distributions_all.attribute6%TYPE,
	p_dist_attribute7		IN  ap_invoice_distributions_all.attribute7%TYPE,
	p_dist_attribute8		IN  ap_invoice_distributions_all.attribute8%TYPE,
	p_dist_attribute9		IN  ap_invoice_distributions_all.attribute9%TYPE,
	p_dist_attribute10		IN  ap_invoice_distributions_all.attribute10%TYPE,
	p_dist_attribute11		IN  ap_invoice_distributions_all.attribute11%TYPE,
	p_dist_attribute12		IN  ap_invoice_distributions_all.attribute12%TYPE,
	p_dist_attribute13		IN  ap_invoice_distributions_all.attribute13%TYPE,
	p_dist_attribute14		IN  ap_invoice_distributions_all.attribute14%TYPE,
	p_dist_attribute15		IN  ap_invoice_distributions_all.attribute15%TYPE,
/* Adding parameter p_input_ccid for bug2348764 */
	p_input_ccid			IN gl_code_combinations.code_combination_id%TYPE default null,
	x_return_ccid			OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
	x_concat_segs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_ids			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_descrs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_error_message			OUT NOCOPY VARCHAR2,
	X_award_set_id			IN  NUMBER DEFAULT NULL,
/* R12 Changes Start - Added two new parameters Award_Id and Expenditure Item ID */
        p_accounting_date               IN  ap_invoice_distributions_all.accounting_date%TYPE default NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL )
/* R12 Changes End */

      RETURN BOOLEAN;

-- 	X_award_set_id was added as part of OGM Interface.
--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.ap_er_generate_account
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API is called from the web expenses form for account
-- generation for Project related expense reports. It accepts the raw
-- parameters from the calling form and calls the wf_acc_derive_er_params
-- procedure to obtain the derive parameters. It sets the attributes
-- of the Workflow item and then invokes Workflow for account
-- generation.
--
-- Parameters   :
--              p_project_id                    IN  NUMBER      Required
--              p_task_id                       IN  NUMBER      Required
--              p_expenditure_type              IN  VARCHAR2    Required
--              p_vendor_id                     IN  NUMBER
--              p_expenditure_organization_id   IN  NUMBER
--              p_expenditure_item_date         IN  DATE        Required
--              p_billable_flag                 IN  CHAR        Required
--              p_chart_of_accounts_id          IN  NUMBER      Required
--              p_calling_module		IN  VARCHAR2	Required
--              p_employee_id			IN  NUMBER      Required
--              p_employee_ccid			IN  NUMBER
--              p_expense_type			IN  NUMBER
--              p_expense_cc                    IN  VARCHAR2
--              p_attribute_category            IN  VARCHAR2
--              p_attribute1 through
--              p_attribute15                   IN  VARCHAR2
--              p_line_attribute_category       IN  VARCHAR2
--              p_line_attribute1 through
--              p_line_attribute15              IN  VARCHAR2
--              x_return_ccid                   OUT NUMBER
--              x_concat_ids                    OUT VARCHAR2
--              x_concat_descrs                 OUT VARCHAR2
--              x_error_message                 OUT VARCHAR2
--		x_award_set_id					IN  NUMBER 		VERTICAL applications
--											interface.
--
-- Version      : Initial version       11.0
--
-- End of comments
--------------------------------------------------------------------------------
--

  FUNCTION ap_er_generate_account
  (
        p_project_id                    IN  pa_projects_all.project_id%TYPE,
        p_task_id                       IN  pa_tasks.task_id%TYPE,
        p_expenditure_type              IN  pa_expenditure_types.expenditure_type%TYPE,
        p_vendor_id                     IN  po_vendors.vendor_id%type,
        p_expenditure_organization_id   IN  hr_organization_units.organization_id%TYPE,
        p_expenditure_item_date         IN  pa_expenditure_items_all.expenditure_item_date%TYPE,
        p_billable_flag                 IN  pa_tasks.billable_flag%TYPE,
        p_chart_of_accounts_id          IN  NUMBER,
        p_calling_module 		IN  VARCHAR2,
	p_employee_id			IN  per_people_f.person_id%TYPE,
	p_employee_ccid			IN  gl_code_combinations.code_combination_id%TYPE,
	p_expense_type			IN  ap_expense_report_lines_all.web_parameter_id%TYPE,
	p_expense_cc			IN  ap_expense_report_headers_all.flex_concatenated%TYPE,
        p_attribute_category            IN  ap_expense_report_headers_all.attribute_category%TYPE,
        p_attribute1                    IN  ap_expense_report_headers_all.attribute1%TYPE,
        p_attribute2                    IN  ap_expense_report_headers_all.attribute2%TYPE,
        p_attribute3                    IN  ap_expense_report_headers_all.attribute3%TYPE,
        p_attribute4                    IN  ap_expense_report_headers_all.attribute4%TYPE,
        p_attribute5                    IN  ap_expense_report_headers_all.attribute5%TYPE,
        p_attribute6                    IN  ap_expense_report_headers_all.attribute6%TYPE,
        p_attribute7                    IN  ap_expense_report_headers_all.attribute7%TYPE,
        p_attribute8                    IN  ap_expense_report_headers_all.attribute8%TYPE,
        p_attribute9                    IN  ap_expense_report_headers_all.attribute9%TYPE,
        p_attribute10                   IN  ap_expense_report_headers_all.attribute10%TYPE,
        p_attribute11                   IN  ap_expense_report_headers_all.attribute11%TYPE,
        p_attribute12                   IN  ap_expense_report_headers_all.attribute12%TYPE,
        p_attribute13                   IN  ap_expense_report_headers_all.attribute13%TYPE,
        p_attribute14                   IN  ap_expense_report_headers_all.attribute14%TYPE,
        p_attribute15                   IN  ap_expense_report_headers_all.attribute15%TYPE,
        p_line_attribute_category       IN  ap_expense_report_lines_all.attribute_category%TYPE,
        p_line_attribute1               IN  ap_expense_report_lines_all.attribute1%TYPE,
        p_line_attribute2               IN  ap_expense_report_lines_all.attribute2%TYPE,
        p_line_attribute3               IN  ap_expense_report_lines_all.attribute3%TYPE,
        p_line_attribute4               IN  ap_expense_report_lines_all.attribute4%TYPE,
        p_line_attribute5               IN  ap_expense_report_lines_all.attribute5%TYPE,
        p_line_attribute6               IN  ap_expense_report_lines_all.attribute6%TYPE,
        p_line_attribute7               IN  ap_expense_report_lines_all.attribute7%TYPE,
        p_line_attribute8               IN  ap_expense_report_lines_all.attribute8%TYPE,
        p_line_attribute9               IN  ap_expense_report_lines_all.attribute9%TYPE,
        p_line_attribute10              IN  ap_expense_report_lines_all.attribute10%TYPE,
        p_line_attribute11              IN  ap_expense_report_lines_all.attribute11%TYPE,
        p_line_attribute12              IN  ap_expense_report_lines_all.attribute12%TYPE,
        p_line_attribute13              IN  ap_expense_report_lines_all.attribute13%TYPE,
        p_line_attribute14              IN  ap_expense_report_lines_all.attribute14%TYPE,
        p_line_attribute15              IN  ap_expense_report_lines_all.attribute15%TYPE,
	p_input_ccid			IN  gl_code_combinations.code_combination_id%TYPE default null, /* Bug 5378579 */
        x_return_ccid                   OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
        x_concat_segs                   IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
        x_concat_ids                    IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
        x_concat_descrs                 IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
        x_error_message                 OUT NOCOPY VARCHAR2,
/* R12 Changes Start - Added two new parameters Award_Id and Expenditure Item ID */
	X_award_set_id			IN  NUMBER DEFAULT NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL )
/* R12 Changes End */

      RETURN BOOLEAN;


-- X_award_set_id was added as part of OGM_0.0 interface.
----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name	: pa_acc_gen_wf_pkg.ap_inv_upgrade_flex_account
--
-- API Type	: Procedure
--
-- Type		: Public
--
-- Pre-reqs	: None
--
-- Function	: This API is attached to a Workflow function for account
-- generation for Project related AP invoices that calls the BUILD
-- function generated by the FNDFBPLS utility. The FNDFBPLS utility
-- generates a function based on existing FlexBuilder rules for
-- generating an account. This function is invoked from Workflow
-- during account generation and calls the
-- PA_VEND_INV_CHARGE_ACCOUNT.BUILD function. The BUILD function
-- generates the account using the same rules as FlexBuilder
--
-- Parameters	:
--		p_itemtype			IN  VARCHAR2	Required
--		p_itemkey			IN  VARCHAR2	Required
--		p_actid				IN  NUMBER	Required
--		p_funcmode 			IN  VARCHAR2	Required
--		x_result			OUT VARCHAR2
--
-- Version	: Initial version	11.0
--
-- End of comments
----------------------------------------------------------------------------------

  PROCEDURE ap_inv_upgrade_flex_account (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name	: pa_acc_gen_wf_pkg.ap_inv_acc_undefined_rules
--
-- API Type	: Procedure
--
-- Type		: Public
--
-- Pre-reqs	: None
--
-- Function	: This API is attached to a Workflow function for default
-- generation for Project related AP invoices. It is the default that
-- is shipped with the product. If the user does not customize account
-- generation, this function ensures that an appropriate error message
-- is displayed to the user.
--
-- The function is set to always fail. Users should replace this
-- function in Workflow with their own account generation procedure.
--
-- Parameters	:
--		p_itemtype			IN  VARCHAR2	Required
--		p_itemkey			IN  VARCHAR2	Required
--		p_actid				IN  NUMBER	Required
--		p_funcmode 			IN  VARCHAR2	Required
--		x_result			OUT VARCHAR2
--
-- Version	: Initial version	11.0
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE ap_inv_acc_undefined_rules (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2);


--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name	: pa_acc_gen_wf_pkg.pa_seg_lookup_set_value
--
-- API Type	: Procedure
--
-- Type		: Public
--
-- Pre-reqs	: None
--
-- Function	: This API is attached to a Workflow function for account
-- generation for Project related AP invoices. It retrieves the lookup
-- value from the PA_SEGMENT_VALUE_LOOKUP_SETS based on the lookup set
-- type and code set by the user in Workflow The internal name of the
-- corresponding Oracle Workflow function is SEGMENT_LOOKUP_SET.
--
-- Parameters	:
--		p_itemtype			IN  VARCHAR2	Required
--		p_itemkey			IN  VARCHAR2	Required
--		p_actid				IN  NUMBER	Required
--		p_funcmode 			IN  VARCHAR2	Required
--		x_result			OUT VARCHAR2
--
-- Version	: Initial version	11.0
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE pa_seg_lookup_set_value (
		p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.pa_aa_function_transaction
--
-- API Type     : Procedure
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API is attached to a Workflow function for account
-- generation for Project related expense reports. It retrieves the Auto
-- Accounting function transaction code from PA_FUNCTION_TRANSACTIONS table
-- based on the PROJECT_TYPE_CLASS_CODE, PUBLIC_SECTOR_FLAG and BILLABLE_FLAG
-- It stores the retrived function transaction code in Workflow Item attribute
-- TRANSACTION_CODE( Internal name ).  The internal name of the corresponding
-- function in Orcale Workflow is AA_FUNCTION_TRANSACTION_CODE
--
-- Parameters   :
--              p_itemtype                      IN  VARCHAR2    Required
--              p_itemkey                       IN  VARCHAR2    Required
--              p_actid                         IN  NUMBER      Required
--              p_funcmode                      IN  VARCHAR2    Required
--              x_result                        OUT VARCHAR2
--
-- Version      : Initial version       11.0
--
-- End of comments
--------------------------------------------------------------------------------
--
/*
PROCEDURE pa_aa_function_transaction (
                p_itemtype      IN  VARCHAR2,
                p_itemkey       IN  VARCHAR2,
                p_actid         IN  NUMBER,
                p_funcmode      IN  VARCHAR2,
                x_result        OUT NOCOPY VARCHAR2);

*/
--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.show_error
--
-- API Type     : Function
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API should be used for debugging WF Functions.
-- It accepts error_stack, error_stage, error_message and 2 additional
-- arguments, it returns the error message from message dictionary in
-- encoded format. 2 additional arguments can be used for more specific
-- debugging.
--
-- Parameters   :
--              p_error_stack               IN  VARCHAR2    Required
--              p_error_stage               IN  VARCHAR2    Required
--              p_error_message             IN  VARCHAR2    Required
--              p_arg1                      IN  VARCHAR2
--              p_arg2                      IN  VARCHAR2
--
-- Return       : Varchar2 ( returns encoded error message );
--
-- Version      : Initial version       11.0
--
-- End of comments
--------------------------------------------------------------------------------
FUNCTION show_error(
		p_error_stack	IN VARCHAR2,
		p_error_stage	IN VARCHAR2,
		p_error_message IN VARCHAR2,
		p_arg1		IN VARCHAR2 DEFAULT NULL,
		p_arg2		IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.set_error_stack
--
-- API Type     : Procedure
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API should be used for for settting the error stack
-- in the global variable g_error_stack
--
-- Parameters   :
--              p_error_stack_msg           IN  VARCHAR2    Required
--
-- Return       : N/A
--
-- Version      : Initial version       12.0
--
-- End of comments
--------------------------------------------------------------------------------
PROCEDURE set_error_stack(p_error_stack_msg IN VARCHAR2);

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_acc_gen_wf_pkg.set_error_stack
--
-- API Type     : Procedure
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This API should be used for for resettting the error stack
-- in the global variable g_error_stack to its previous value
--
-- Parameters   : None
--
-- Return       : N/A
--
-- Version      : Initial version       12.0
--
-- End of comments
--------------------------------------------------------------------------------
PROCEDURE reset_error_stack;

END pa_acc_gen_wf_pkg;

 

/

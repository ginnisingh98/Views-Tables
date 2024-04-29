--------------------------------------------------------
--  DDL for Package POR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: PORUTILS.pls 120.7.12010000.26 2014/04/25 06:52:52 mzhussai ship $ */

FUNCTION bool_to_varchar(b IN BOOLEAN) RETURN VARCHAR2;

PROCEDURE delete_requisition(p_header_id IN NUMBER);

PROCEDURE purge_requisition(p_header_id IN NUMBER);

PROCEDURE delete_working_copy_req(p_req_number IN VARCHAR2);

FUNCTION get_current_approver(p_req_header_id in number) RETURN NUMBER;

FUNCTION getSitesEnabledFlagForContract(p_header_id in number) RETURN varchar2;

FUNCTION get_cost_center(p_code_combination_id in number) RETURN VARCHAR2;

FUNCTION get_document_number(table_name_p IN VARCHAR2) RETURN NUMBER;

FUNCTION get_global_document_number(table_name_p IN VARCHAR2, org_id_p IN NUMBER)
  RETURN NUMBER;
--Bug 12914933 Added date parameter for get_item_cost
FUNCTION get_item_cost(
  x_item_id		 IN  	NUMBER,
	x_source_organization_id  	 IN  	NUMBER,
	x_unit_of_measure	 IN  	VARCHAR2,
	x_dest_organization_id IN NUMBER DEFAULT null,
	x_date IN DATE DEFAULT NULL)
	 RETURN NUMBER;

FUNCTION interface_start_workflow(
  V_charge_success       IN OUT  NOCOPY VARCHAR2,
  V_budget_success        IN OUT NOCOPY VARCHAR2,
  V_accrual_success      IN OUT  NOCOPY VARCHAR2,
  V_variance_success      IN OUT NOCOPY VARCHAR2,
  x_code_combination_id  IN OUT  NOCOPY NUMBER,
  x_budget_account_id     IN OUT NOCOPY NUMBER,
  x_accrual_account_id   IN OUT  NOCOPY NUMBER,
  x_variance_account_id   IN OUT NOCOPY NUMBER,
  x_charge_account_flex  IN OUT  NOCOPY VARCHAR2,
  x_budget_account_flex   IN OUT NOCOPY VARCHAR2,
  x_accrual_account_flex IN OUT  NOCOPY VARCHAR2,
  x_variance_account_flex IN OUT NOCOPY VARCHAR2,
  x_charge_account_desc  IN OUT  NOCOPY VARCHAR2,
  x_budget_account_desc   IN OUT NOCOPY VARCHAR2,
  x_accrual_account_desc IN OUT  NOCOPY VARCHAR2,
  x_variance_account_desc IN OUT NOCOPY VARCHAR2,
  x_coa_id                       NUMBER,
  x_bom_resource_id              NUMBER,
  x_bom_cost_element_id          NUMBER,
  x_category_id                  NUMBER,
  x_destination_type_code        VARCHAR2,
  x_deliver_to_location_id       NUMBER,
  x_destination_organization_id  NUMBER,
  x_destination_subinventory     VARCHAR2,
  x_expenditure_type             VARCHAR2,
  x_expenditure_organization_id  NUMBER,
  x_expenditure_item_date        DATE,
  x_item_id                      NUMBER,
  x_line_type_id                 NUMBER,
  x_result_billable_flag         VARCHAR2,
  x_preparer_id                  NUMBER,
  x_project_id                   NUMBER,
  x_document_type_code           VARCHAR2,
  x_blanket_po_header_id         NUMBER,
  x_source_type_code             VARCHAR2,
  x_source_organization_id       NUMBER,
  x_source_subinventory          VARCHAR2,
  x_task_id                      NUMBER,
  x_award_set_id                 NUMBER,
  x_deliver_to_person_id         NUMBER,
  x_type_lookup_code             VARCHAR2,
  x_suggested_vendor_id          NUMBER,
  x_suggested_vendor_site_id     NUMBER,
  x_wip_entity_id                NUMBER,
  x_wip_entity_type              VARCHAR2,
  x_wip_line_id                  NUMBER,
  x_wip_repetitive_schedule_id   NUMBER,
  x_wip_operation_seq_num        NUMBER,
  x_wip_resource_seq_num         NUMBER,
  x_po_encumberance_flag         VARCHAR2,
  x_gl_encumbered_date           DATE,
  wf_itemkey             IN OUT  NOCOPY VARCHAR2,
  V_new_combination      IN OUT  NOCOPY VARCHAR2,
  header_att1                    VARCHAR2,
  header_att2                    VARCHAR2,
  header_att3                    VARCHAR2,
  header_att4                    VARCHAR2,
  header_att5                    VARCHAR2,
  header_att6                    VARCHAR2,
  header_att7                    VARCHAR2,
  header_att8                    VARCHAR2,
  header_att9                    VARCHAR2,
  header_att10                   VARCHAR2,
  header_att11                   VARCHAR2,
  header_att12                   VARCHAR2,
  header_att13                   VARCHAR2,
  header_att14                   VARCHAR2,
  header_att15                   VARCHAR2,
  line_att1                      VARCHAR2,
  line_att2                      VARCHAR2,
  line_att3                      VARCHAR2,
  line_att4                      VARCHAR2,
  line_att5                      VARCHAR2,
  line_att6                      VARCHAR2,
  line_att7                      VARCHAR2,
  line_att8                      VARCHAR2,
  line_att9                      VARCHAR2,
  line_att10                     VARCHAR2,
  line_att11                     VARCHAR2,
  line_att12                     VARCHAR2,
  line_att13                     VARCHAR2,
  line_att14                     VARCHAR2,
  line_att15                     VARCHAR2,
  distribution_att1              VARCHAR2,
  distribution_att2              VARCHAR2,
  distribution_att3              VARCHAR2,
  distribution_att4              VARCHAR2,
  distribution_att5              VARCHAR2,
  distribution_att6              VARCHAR2,
  distribution_att7              VARCHAR2,
  distribution_att8              VARCHAR2,
  distribution_att9              VARCHAR2,
  distribution_att10             VARCHAR2,
  distribution_att11             VARCHAR2,
  distribution_att12             VARCHAR2,
  distribution_att13             VARCHAR2,
  distribution_att14             VARCHAR2,
  distribution_att15             VARCHAR2,
  FB_ERROR_MSG           IN  OUT NOCOPY VARCHAR2,
  p_unit_price                   NUMBER,
  p_blanket_po_line_num          NUMBER) RETURN VARCHAR2;

FUNCTION jumpIntoFunction(p_application_id      in number,
                          p_function_code       in varchar2,
                          p_parameter1          in varchar2 default null,
                          p_parameter2          in varchar2 default null,
                          p_parameter3          in varchar2 default null,
                          p_parameter4          in varchar2 default null,
                          p_parameter5          in varchar2 default null,
                          p_parameter6          in varchar2 default null,
                          p_parameter7          in varchar2 default null,
                          p_parameter8          in varchar2 default null,
                          p_parameter9          in varchar2 default null,
                          p_parameter10         in varchar2 default null,
                          p_parameter11		      in varchar2 default null)
                          return varchar2;

PROCEDURE restore_working_copy_req(
  p_origHeaderId IN NUMBER,
  p_tempHeaderId IN NUMBER,
  p_origLineIds IN PO_TBL_NUMBER,
  p_tempLineIds IN PO_TBL_NUMBER,
  p_origDistIds IN PO_TBL_NUMBER,
  p_tempDistIds IN PO_TBL_NUMBER,
  p_origReqSupplierIds IN PO_TBL_NUMBER,
  p_tempReqSupplierIds IN PO_TBL_NUMBER,
  p_origPriceDiffIds IN PO_TBL_NUMBER,
  p_tempPriceDiffIds IN PO_TBL_NUMBER);

FUNCTION submitreq(
  req_Header_Id IN NUMBER,
	req_num IN varchar2,
	preparer_id IN NUMBER,
	note_to_approver IN varchar2,
	approver_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE validate_pjm_project_info (p_deliver_to_org_id IN NUMBER,
                                     p_project_id IN NUMBER,
                                     p_task_id IN NUMBER,
                                     p_need_by_date IN DATE,
                                     p_translated_err OUT NOCOPY VARCHAR2,
                                     p_result OUT NOCOPY VARCHAR2);

FUNCTION validate_ccid(
                X_chartOfAccountsId  IN NUMBER,
		X_ccId               IN NUMBER,
                X_validationDate     IN DATE,
		X_concatSegs         OUT NOCOPY VARCHAR2,
		X_errorMsg           OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION  validate_open_period(
  x_trx_date IN DATE,
	x_sob_id   IN NUMBER,
  x_org_id   IN NUMBER) RETURN NUMBER;

FUNCTION validate_segs(
  X_chartOfAccountsId     IN NUMBER,
		X_concatSegs            IN VARCHAR2,
		X_errorMsg            OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION val_rcv_controls_for_date(
  X_transaction_type      IN VARCHAR2,
  X_auto_transact_code    IN VARCHAR2,
  X_expected_receipt_date IN DATE,
  X_transaction_date      IN DATE,
  X_routing_header_id     IN NUMBER,
  X_po_line_location_id   IN NUMBER,
  X_item_id               IN NUMBER,
  X_vendor_id             IN NUMBER,
  X_to_organization_id    IN NUMBER,
  rcv_date_exception      OUT NOCOPY VARCHAR2) RETURN NUMBER;

/*---------------------------------------------------------------------*
 * This function checks whether a given requisition header id exists   *
 * or not. If exists, return Y otherwise N.                     *
 * Bug # 16705009                                                      *
 *---------------------------------------------------------------------*/
FUNCTION req_header_id_exist(p_req_header_id IN NUMBER) RETURN CHAR;

-- API to check whether the user is associated with a employee or not.
-- Returns true if the user is associated with a employee, else returns false
FUNCTION validate_user(p_user_id in number) RETURN CHAR;

PROCEDURE withdraw_req(p_headerId in NUMBER);

PROCEDURE deactivate_active_req(p_user_id IN NUMBER);

-- API to check transaction flow for centralized procurement
-- checks whether a transaction flow exists between the start OU and end OU
-- wrapper needed since types are defined in INV package and not in the
-- database
PROCEDURE check_transaction_flow(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_start_operating_unit IN NUMBER,
  p_end_operating_unit IN NUMBER,
  p_flow_type IN NUMBER,
  p_organization_id IN NUMBER,
  p_category_id IN NUMBER,
  p_transaction_date IN DATE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2,
  x_header_id OUT NOCOPY NUMBER,
  x_new_accounting_flag OUT NOCOPY VARCHAR2,
  x_transaction_flow_exists OUT NOCOPY VARCHAR2);

--Begin Encumbrance APIs
------------------------

-- API to truncate the PO interface table PO_ENCUMBRANCE_GT
PROCEDURE truncate_po_encumbrance_gt;

-- API to populate the distribution data into POs interface table
-- PO_ENCUMBRANCE_GT
PROCEDURE populate_po_encumbrance_gt(
  p_dist_data IN ICX_ENC_IN_TYPE);

-- API to check if the funds can be reserved on the requisition
PROCEDURE check_reserve(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_dist_data IN ICX_ENC_IN_TYPE,
  p_doc_level IN VARCHAR2,
  p_doc_level_id IN NUMBER,
  p_use_enc_gt_flag IN VARCHAR2,
  p_override_funds IN VARCHAR2,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type);

-- API to check if the funds can be adjusted on the requisition
-- called during approver checkout
-- also called for just the labor and expense lines from assign contractor
-- during approver checkout
PROCEDURE check_adjust(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_dist_data IN ICX_ENC_IN_TYPE,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_override_funds IN VARCHAR2,
  p_use_gl_date IN VARCHAR2,
  p_override_date IN DATE,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type);

-- API to perform reservation of funds on a contractor line
-- this can have just a labor line or both a labor and expense line
-- called from assign contractor
PROCEDURE do_reserve_contractor(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_prevent_partial_flag IN VARCHAR2,
  p_employee_id IN NUMBER,
  p_override_funds IN VARCHAR2,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type);

-- API to perform unreserve of funds on a contractor line
-- this can have just a labor line or both a labor and expense line
-- called from assign contractor
PROCEDURE do_unreserve_contractor(
  p_api_version IN VARCHAR2,
  p_commit IN VARCHAR2 default FND_API.G_FALSE,
  p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
  p_validation_level IN number default FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2,
  p_doc_type IN VARCHAR2,
  p_doc_subtype IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id_tbl IN po_tbl_number,
  p_override_funds IN VARCHAR2,
  p_employee_id IN NUMBER,
  p_use_gl_date IN VARCHAR2,
  p_override_date IN DATE,
  p_report_successes IN VARCHAR2,
  x_po_return_code OUT NOCOPY VARCHAR2,
  x_detailed_results OUT NOCOPY po_fcout_type);

--End Encumbrance APIs
------------------------

PROCEDURE cancel_workflow(p_headerId in  NUMBER);

-- API Name : create_info_template
-- Type : Public
-- Pre-reqs : None
-- Function : Copies the information template data from the old_req_line to the record
--            corresponding new_req_line in the table POR_TEMPLATE_INFO while
--            creating a new req line. This will be called by Core Purchasing
--            This API is provide to Core Purchasing for bug 4716686
-- Parameters : p_old_reqline_id IN NUMBER : Corresponds to the existing requisition line id
--              p_new_reqline_id IN NUMBER : Corresponds to the new requisition line id
--              p_item_id IN NUMBER : Corresponds to the item id of the new requisiton line
--              p_category_id IN NUMBER : Corresponds to the category id of the new req. line
-- Version  : Initial Verion : 1.0

PROCEDURE create_info_template
          (p_api_version    IN NUMBER,
           x_return_status  OUT	NOCOPY VARCHAR2,
           p_commit IN VARCHAR2 default FND_API.G_FALSE,
           p_old_reqline_id IN NUMBER,
           p_new_reqline_id IN NUMBER,
           p_item_id IN NUMBER,
           p_category_id IN NUMBER) ;

-- API Name : update_attachment_to_standard
-- Type : Public
-- Pre-reqs : None
-- Function : Updates the attachments associated with the requisition to standard attachment
-- Parameters : p_req_header_id IN NUMBER : Corresponds to the existing requisition line id

PROCEDURE update_attachment_to_standard(p_req_header_id in  NUMBER);

FUNCTION is_req_encumbered(p_req_header_id in  NUMBER)
  RETURN VARCHAR2;


 FUNCTION round_amount_precision
                          ( p_amount         IN NUMBER
                           , p_currency_code  IN VARCHAR2) RETURN number;

-- bug 9799749 - FP of 9449718
PROCEDURE reset_award(  X_distribution_id      IN NUMBER,
                        X_status        IN OUT NOCOPY varchar2 ) ;

 FUNCTION is_placed_on_po(p_req_header_id IN NUMBER) RETURN VARCHAR2;

 FUNCTION round_currency_amount
                         (P_Amount         IN number
                         ,P_Currency_Code  IN varchar2
                         ) RETURN number;

 PROCEDURE owner_can_approve_AME(p_document_type IN   VARCHAR2
 	                   , p_owner_can_approve OUT NOCOPY VARCHAR2);


-- API Name :get_gbpa_data_for_bulkload
-- Type : Public
-- Pre-reqs : None
-- Function : Deletes MTL_SUPPLY record when a requisition line is deleted
--            from iProcurement.
-- Parameters : p_req_header_id IN NUMBER
--             xUpdate_sourcing_rules_flag IN NUMBER
--             xAuto_sourcing_rules_flag IN NUMBER
-- Fixed Bug:10379671--fix the hard-coding done in START_PDOI_PROCESSING_PLSQL
-- of DataRootElementProcessor with the value from po_headers_all if blanket
--    already exists. Else, set it as 'N'.
--
-- This method is to get the value of the 2 flags used in
-- DataRootElementProcessor
PROCEDURE get_gbpa_data_for_bulkload (pHeaderId IN NUMBER,
 xUpdate_sourcing_rules_flag OUT NOCOPY VARCHAR2,
                                      xAuto_sourcing_flag OUT NOCOPY VARCHAR2);

-- API Name : delete_supply
-- Type : Public
-- Pre-reqs : None
-- Function : Deletes MTL_SUPPLY record when a requisition line is deleted
--            from iProcurement.
-- Parameters : p_req_header_id IN NUMBER
--              p_req_line_id IN NUMBER
PROCEDURE delete_supply(p_req_header_id in  NUMBER,p_req_line_id IN NUMBER);

FUNCTION validateWorkOrder(p_po_distribution_id IN number)    RETURN NUMBER;

--13536267 changes starts
-- API Name : VALIDATE_JOB_RELEASED_DATE
-- Type : Public
-- Pre-reqs : None
-- Function : validate the POR receipt receive date with Job Release date.
-- Parameters : x_trx_date IN DATE
--              x_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  VALIDATE_JOB_RELEASED_DATE(x_trx_date IN DATE, x_dist_id   IN NUMBER)
RETURN NUMBER;
--13536267 changes ends



--14062063 changes starts
-- API Name : val_po_dist_pjt
-- Type : Public
-- Pre-reqs : None
-- Function : validates the PO distribution with Project.
-- Parameters : x_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  val_po_dist_pjt(x_dist_id   IN NUMBER) RETURN NUMBER;

-- API Name : get_po_dist_project
-- Type : Public
-- Pre-reqs : None
-- Function : gets the Project Name for PO distribution.
-- Parameters : p_po_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION get_po_dist_project(p_po_dist_id in number) RETURN VARCHAR2;

-- API Name : val_req_line_pjts
-- Type : Public
-- Pre-reqs : None
-- Function : validates the req line with Project.
-- Parameters : x_line_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  val_req_line_pjts(x_line_id   IN NUMBER)RETURN NUMBER;

-- API Name : get_req_line_invalid_pjts
-- Type : Public
-- Pre-reqs : None
-- Function : gets the comma separated invalid Project Name(s) for REQ Line.
-- Parameters : p_po_dist_id IN NUMBER
-- RETURN     NUMBER
FUNCTION  get_req_line_invalid_pjts(p_req_line_id   IN NUMBER) RETURN VARCHAR2;

--14062063 changes ends


-- 14191762 changes starts
-- API Name : GET_JOB_RELEASED_DATE
-- Type : Public
-- Pre-reqs : None
-- Function : gets the Job Release date against PO distribution.
-- Parameters : x_dist_id IN NUMBER
-- RETURN     DATE
FUNCTION  GET_JOB_RELEASED_DATE( x_dist_id   IN NUMBER)
RETURN DATE;
-- 14191762 changes ends

  -- 15900708 changes starts
/*
API Name : req_imp_act_up_frm_wf
Type : Public
Pre-reqs : None
Function : populates the accounts in req interface table by calling
  workflow api if charge account, charge account segments are empty.
  and updates other accounts if those are empty on req interface
Parameters :
  p_request_id IN NUMBER          : concurrent req no
  p_coa_id IN NUMBER              : chart of accounts id
  p_user_id IN NUMBER             : user id
  p_login_id IN NUMBER            : login id
  p_prog_application_id IN NUMBER : program application id
  p_program_id IN NUMBER          : program id
*/
PROCEDURE req_imp_act_up_frm_wf(
                                 p_request_id IN NUMBER,
                                 p_coa_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_login_id IN NUMBER,
                                 p_prog_application_id IN NUMBER,
                                 p_program_id IN NUMBER
                          );

/*
API Name : req_imp_mul_dst_act_up_frm_wf
Type : Public
Pre-reqs : None
Function : updates the accounts in req distribution interface table by calling
  workflow api if charge account, charge account segments are empty.
  and updates other accounts if those are empty on req interface
Parameters :
  p_request_id IN NUMBER          : concurrent req no
  p_coa_id IN NUMBER              : chart of accounts id
  p_user_id IN NUMBER             : user id
  p_login_id IN NUMBER            : login id
  p_prog_application_id IN NUMBER : program application id
  p_program_id IN NUMBER          : program id
*/
PROCEDURE req_imp_mul_dst_act_up_frm_wf (
                                 p_request_id IN NUMBER,
                                 p_coa_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_login_id IN NUMBER,
                                 p_prog_application_id IN NUMBER,
                                 p_program_id IN NUMBER
                          );

 -- 15900708 changes ends

-- API Name : get_open_quantity
-- Type     : Public
-- Pre-reqs : None
-- Function : Calculate & return open quantity of the given requisition line
-- Remark	: Added for bug 17321511
FUNCTION get_open_quantity(p_req_line_id po_requisition_lines_all.requisition_line_id%type) RETURN NUMBER;

PROCEDURE  convert_from_wild_ext_to_int
(  p_return_status		OUT NOCOPY	VARCHAR2,
   p_Category     		IN	VARCHAR2,
   p_Key1			IN	VARCHAR2 := NULL,
   p_Ext_val1			IN	VARCHAR2,
   p_Int_val			OUT NOCOPY	VARCHAR2
);

END POR_UTIL_PKG;

/

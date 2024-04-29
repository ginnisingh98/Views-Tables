--------------------------------------------------------
--  DDL for Package PA_FUNDS_CONTROL_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUNDS_CONTROL_UTILS2" AUTHID CURRENT_USER as
-- $Header: PAFUTL2S.pls 120.1 2005/08/10 14:18:44 bkattupa noship $

/* declare the global variables */
	g_cwk_implemented_flag  varchar2(100) := Null;
	g_bd_cache_exp_string   varchar2(1000);
        g_bd_cache_proj_id      Number;
        g_bd_cache_task_id      Number;
        g_bd_cache_doc_line_id  Number;
        g_bd_cache_exp_type     Varchar2(150);
        g_bd_cache_Ei_date      Date;
	g_bd_cache_result_code  Varchar2(150);
        g_bd_cache_status_code  Varchar2(150);


FUNCTION is_CWK_PO(p_po_header_id Number
		  ,p_po_line_id   Number
                  ,p_po_dist_id   Number
                  ,p_proj_org_id  Number ) Return varchar2 ;


/* This api will return the resource list member id from the summary record
 * for the given document header and line for contingent worker record
 */
FUNCTION get_CWK_RLMI(p_project_id  IN Number
                     ,p_task_id           IN Number
                     ,p_budget_version_id IN Number
                     ,p_document_header_id IN Number
                     ,p_document_dist_id IN Number
                     ,p_document_line_id IN Number
                     ,p_document_type    IN VARCHAR2
                     ,p_expenditure_type IN VARCHAR2
		     ,p_line_type        IN VARCHAR2
                     ,p_calling_module IN VARCHAR2 ) Return Number ;


/* This Function returns the Baseline Budget version OR Draft budget version
 * based on the calling mode 'DRAFT'/ 'BASELINE'
 */
FUNCTION get_draftORbaseLine_bdgtver(p_project_id     IN Number
                          ,p_ext_bdgt_type IN varchar2
                          ,p_mode          IN varchar2 ) Return Number ;



/* This API will checks the burden components for CWK transactions has been changed, if so return error
 * if the burden componenets are not same as the summary record , later we cannot
 * derive the budget ccid and resource list member id.
 * so mark the trasnaction as Error.
 * This check should be carried only for the Burden display method is different
 * Example: PO is entered for exp 'Airfare' which maps to the following cost codes
 * Cost Base   ind_cost_codes
 * -----------------------------------
 * Expenses     GA
 *              FEE
 *
 * When timecard is entered for expenditure type which maps
 * Labor       GA
 *             FEE
 *             Fringe
 *             Overhead
 * Since we cannot map RLMI for the Fringe and Overhead, later the transactions get rejected
 * so mark the bc_packet and parent_bc_packet records as rejected with reason
 * "Burden cost codes not mapping to summary record expenditure types" - F100
 *
 */
PROCEDURE checkCWKbdCostCodes( p_calling_module varchar2
                         ,p_project_id Number
                        ,p_task_id     Number
                        ,p_doc_line_id Number
                        ,p_exp_type    varchar2
                        ,p_exp_item_date date
                        ,x_return_status  OUT NOCOPY varchar2
                        ,x_result_code    OUT NOCOPY varchar2
                        ,x_status_code    OUT NOCOPY varchar2
                        );
end;

 

/

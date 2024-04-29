--------------------------------------------------------
--  DDL for Package CSP_PARTS_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PARTS_ORDER" AUTHID CURRENT_USER AS
/* $Header: cspvpods.pls 120.0.12010000.6 2011/06/09 15:38:45 htank ship $ */
--
-- Purpose: To create/update/cancel internal parts order for spares
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- phegde      05/01/01 Created Package

TYPE Req_dist_Rec_type IS RECORD
(distribution_id 		po_req_distributions_all.distribution_id%TYPE
,last_update_date		po_req_distributions_all.last_update_date%TYPE
,last_updated_by 		po_req_distributions_all.last_updated_by%TYPE
,requisition_line_id		po_req_distributions_all.requisition_line_id%TYPE
,set_of_books_id		po_req_distributions_all.set_of_books_id%TYPE
,code_combination_id		po_req_distributions_all.code_combination_id%TYPE
,req_line_quantity		po_req_distributions_all.req_line_quantity%TYPE
,last_update_login		po_req_distributions_all.last_update_login%TYPE
,creation_date			po_req_distributions_all.creation_date%TYPE
,created_by			po_req_distributions_all.created_by%TYPE
,encumbered_flag		po_req_distributions_all.encumbered_flag%TYPE
,gl_encumbered_date		po_req_distributions_all.gl_encumbered_date%TYPE
,gl_encumbered_period_name	po_req_distributions_all.gl_encumbered_period_name%TYPE
,gl_cancelled_date		po_req_distributions_all.gl_cancelled_date%TYPE
,failed_funds_lookup_code	po_req_distributions_all.failed_funds_lookup_code%TYPE
,encumbered_amount		po_req_distributions_all.encumbered_amount%TYPE
,budget_account_id		po_req_distributions_all.budget_account_id%TYPE
,accrual_account_id		po_req_distributions_all.accrual_account_id%TYPE
,variance_account_id		po_req_distributions_all.variance_account_id%TYPE
,prevent_encumbrance_flag	po_req_distributions_all.prevent_encumbrance_flag%TYPE
,attribute_category		po_req_distributions_all.attribute_category%TYPE
,attribute1			po_req_distributions_all.attribute1%TYPE
,attribute2			po_req_distributions_all.attribute2%TYPE
,attribute3			po_req_distributions_all.attribute3%TYPE
,attribute4			po_req_distributions_all.attribute4%TYPE
,attribute5			po_req_distributions_all.attribute5%TYPE
,attribute6			po_req_distributions_all.attribute6%TYPE
,attribute7			po_req_distributions_all.attribute7%TYPE
,attribute8			po_req_distributions_all.attribute8%TYPE
,attribute9			po_req_distributions_all.attribute9%TYPE
,attribute10			po_req_distributions_all.attribute10%TYPE
,attribute11			po_req_distributions_all.attribute11%TYPE
,attribute12	 		po_req_distributions_all.attribute12%TYPE
,attribute13	 		po_req_distributions_all.attribute13%TYPE
,attribute14	 		po_req_distributions_all.attribute14%TYPE
,attribute15	 		po_req_distributions_all.attribute15%TYPE
,ussgl_transaction_code		po_req_distributions_all.ussgl_transaction_code%TYPE
,government_context		po_req_distributions_all.government_context%TYPE
,project_id	 		po_req_distributions_all.project_id%TYPE
,task_id	  		po_req_distributions_all.task_id%TYPE
,expenditure_type		po_req_distributions_all.expenditure_type%TYPE
,project_accounting_context	po_req_distributions_all.project_accounting_context%TYPE
,expenditure_organization_id	po_req_distributions_all.expenditure_organization_id%TYPE
,gl_closed_date	 		po_req_distributions_all.gl_closed_date%TYPE
,source_req_distribution_id	po_req_distributions_all.source_req_distribution_id%TYPE
,distribution_num		po_req_distributions_all.distribution_num%TYPE
,project_related_flag		po_req_distributions_all.project_related_flag%TYPE
,expenditure_item_date		po_req_distributions_all.expenditure_item_date%TYPE
,org_id	 	 		po_req_distributions_all.org_id%TYPE
,allocation_type	 	po_req_distributions_all.allocation_type%TYPE
,allocation_value		po_req_distributions_all.allocation_value%TYPE
,award_id	 		po_req_distributions_all.award_id%TYPE
,end_item_unit_number		po_req_distributions_all.end_item_unit_number%TYPE
,recoverable_tax	 	po_req_distributions_all.recoverable_tax%TYPE
,nonrecoverable_tax		po_req_distributions_all.nonrecoverable_tax%TYPE
,recovery_rate	 		po_req_distributions_all.recovery_rate%TYPE
,tax_recovery_override_flag	po_req_distributions_all.tax_recovery_override_flag%TYPE
,oke_contract_line_id		po_req_distributions_all.oke_contract_line_id%TYPE
,oke_contract_deliverable_id	po_req_distributions_all.oke_contract_deliverable_id%TYPE
);

 -- Operations
--G_OPR_INSERT        CONSTANT    VARCHAR2(30) := 'INSERT';
G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
G_OPR_LOCK	        CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_CANCEL        CONSTANT    VARCHAR2(30) := 'CANCEL';

-- Process Types
G_PRC_REQUISITION   CONSTANT    VARCHAR2(30) := 'REQUISITION';
G_PRC_ORDER         CONSTANT    VARCHAR2(30) := 'ORDER';
G_PRC_BOTH          CONSTANT    VARCHAR2(30) := 'BOTH';
--G_OPR_NONE	    CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;

  PROCEDURE process_order(
          p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.Header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,p_process_type            IN VARCHAR2 := 'BOTH'
		 ,p_book_order				IN VARCHAR2 := 'Y'
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        );

  -- This procedure populates the ReqImport interface tables with Parts Requirements from Spares
  -- for creating purchase requisitions when the source type is supplier.
  PROCEDURE process_purchase_req(
          p_api_version             IN NUMBER
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY csp_parts_requirement.header_rec_type
         ,px_line_table             IN OUT NOCOPY csp_parts_requirement.Line_Tbl_type
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        );

  PROCEDURE cancel_order_line(
              p_order_line_id IN NUMBER,
              p_cancel_reason IN varchar2,
              x_return_status OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_msg_data      OUT NOCOPY VARCHAR2);

PROCEDURE book_order (
	p_oe_header_id		IN NUMBER
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE upd_oe_line_ship_method (
	p_oe_line_id		IN NUMBER
    ,p_ship_method      IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
);

PROCEDURE upd_oe_ship_to_add (
	p_req_header_id		IN NUMBER
    ,p_new_hr_loc_id    IN  NUMBER
    ,p_new_add_type     IN  VARCHAR2
    ,p_update_req_header IN VARCHAR2
    ,p_commit           IN   VARCHAR2     := FND_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
);

 PROCEDURE Cancel_Order(
          p_header_rec             IN csp_parts_requirement.header_rec_type
         ,p_line_table             IN csp_parts_requirement.Line_Tbl_type
         ,p_process_Type           IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
         );

 END; -- Package spec

/

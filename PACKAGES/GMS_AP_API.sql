--------------------------------------------------------
--  DDL for Package GMS_AP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AP_API" AUTHID CURRENT_USER AS
/* $Header: gmsapx1s.pls 120.2 2006/05/22 12:20:50 asubrama noship $ */

-- ------------------------------------------------------------------------
-- PROCEDURE GMS_AP_ER_HEADERS_AUT1
-- Parameters : P_invoice_id	Invoice_id for ap_invoice_distributions_all
--	      : p_report_header_id	Ap_expense_report_headers ID.
--	      : p_reject_code 		Rejection identifier
-- ------------------------------------------------------------------------
PROCEDURE GMS_AP_ER_HEADERS_AUT1 ( P_invoice_id		in	NUMBER,
				   p_report_header_id	IN	NUMBER,
				   P_reject_code	IN	varchar2 ) ;

FUNCTION V_CHECK_LINE_AWARD_INFO (
        p_invoice_line_id            	IN      NUMBER 		DEFAULT NULL,
	p_line_amount			IN	NUMBER 		DEFAULT NULL,
	p_base_line_amount		IN	NUMBER 		DEFAULT NULL,
	p_dist_code_concatenated	IN	VARCHAR2 	DEFAULT NULL,
	p_dist_code_combination_id	IN OUT	NOCOPY NUMBER ,
	p_default_po_number		IN	VARCHAR2 	DEFAULT NULL,
	p_po_number			IN	VARCHAR2 	DEFAULT NULL,
	p_po_header_id			IN	NUMBER 		DEFAULT NULL,
	p_distribution_set_id		IN	NUMBER 		DEFAULT NULL,
	p_distribution_set_name		IN	VARCHAR2 	DEFAULT NULL,
	p_set_of_books_id		IN	NUMBER 		DEFAULT NULL,
	p_base_currency_code		IN	VARCHAR2 	DEFAULT NULL,
	p_invoice_currency_code		IN	VARCHAR2 	DEFAULT NULL,
	p_exchange_rate			IN	NUMBER 		DEFAULT NULL,
	p_exchange_rate_type		IN	VARCHAR2 	DEFAULT NULL,
	p_exchange_rate_date		IN	DATE 		DEFAULT NULL,
	p_project_id                    IN	NUMBER 		DEFAULT NULL,
	p_task_id                       IN	NUMBER 		DEFAULT NULL,
	p_expenditure_type              IN	VARCHAR2 	DEFAULT NULL,
	p_expenditure_item_date         IN	DATE 		DEFAULT NULL,
	p_expenditure_organization_id   IN	NUMBER 		DEFAULT NULL,
	p_project_accounting_context    IN	VARCHAR2 	DEFAULT NULL,
	p_pa_addition_flag              IN	VARCHAR2 	DEFAULT NULL,
	p_pa_quantity                   IN	NUMBER 		DEFAULT NULL,
	p_employee_id			IN	NUMBER 		DEFAULT NULL,
	p_vendor_id			IN	NUMBER 		DEFAULT NULL,
	p_chart_of_accounts_id		IN	NUMBER 		DEFAULT NULL,
	p_pa_installed			IN	VARCHAR2 	DEFAULT NULL,
	p_prorate_across_flag		IN	VARCHAR2 DEFAULT NULL,
        p_lines_attribute_category	IN	VARCHAR2 DEFAULT NULL,
        p_lines_attribute1             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute2             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute3             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute4             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute5             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute6             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute7             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute8             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute9             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute10            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute11            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute12            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute13            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute14            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute15            	IN	VARCHAR2 DEFAULT NULL,
        p_attribute_category		IN	VARCHAR2 DEFAULT NULL,
        p_attribute1             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute2             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute3             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute4             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute5             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute6             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute7             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute8             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute9             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute10            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute11            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute12            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute13            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute14            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute15            	IN	VARCHAR2 DEFAULT NULL,
	p_partial_segments_flag		IN 	VARCHAR2 DEFAULT NULL,
	p_default_last_updated_by	IN	NUMBER   DEFAULT NULL,
	p_default_last_update_login	IN	NUMBER   DEFAULT NULL,
	p_calling_sequence		IN	VARCHAR2 DEFAULT NULL,
	p_award_id    		      IN OUT    NOCOPY NUMBER,
        P_EVENT				IN      varchar2 ) return BOOLEAN  ;


PROCEDURE CREATE_AWARD_DISTRIBUTIONS( p_invoice_id	         IN NUMBER,
				      p_distribution_line_number IN NUMBER,
				      p_invoice_distribution_id  IN NUMBER,
				      p_award_id		 IN NUMBER,
				      p_mode		 	 IN VARCHAR2 default 'AP',
				      p_dist_set_id		 IN NUMBER   default NULL,
				      p_dist_set_line_number     IN NUMBER   default NULL
				    ) ;
Procedure GET_DISTRIBUTION_AWARD ( p_invoice_id                IN NUMBER,
                                    p_distribution_line_number IN NUMBER,
                                    p_invoice_distribution_id  IN NUMBER,
                                    p_award_set_id             IN NUMBER,
                                    p_award_id               IN OUT NOCOPY NUMBER   ) ;

FUNCTION GMS_DEBUG_SWITCH( p_debug_flag varchar2 ) return boolean ;

Procedure CREATE_PREPAY_ADL(p_prepay_dist_id  IN NUMBER ,
                            p_invoice_id      IN NUMBER ,
                            p_next_dist_line_num IN NUMBER,
                            p_invoice_distribution_id IN NUMBER );


-- ============================================================================
-- BUG : 2676134 ( APXIIMPT  distribution set with invalid award not validated.
-- ============================================================================
PROCEDURE GET_DIST_SET_AWARD (  p_distribution_set_id		IN NUMBER,
				p_distribution_set_line_number	IN NUMBER,
				p_award_set_id			IN NUMBER,
				p_award_id		   IN OUT  NOCOPY NUMBER ) ;

    -- Start of comments
    -- -----------------
    -- API Name         : verify_create_adl
    -- Type             : public
    -- Pre Reqs         : None
    -- Function         : This is used to create award distribution lines
    --                    using the bulk processing. This provides a
    --                    interface with ap recurring invoice feature.
    -- Logic            : Identify the newly created invoice distribution
    --                    lines and create award distribution lines for
    --                    sponsored project.
    -- Parameters       :
    -- IN               : p_invoice_id   IN     NUMBER
    --                                  The invoice id created and that may
    --                                  have distributions associated with
    --                                  an award.
    --                  : p_calling_sequence IN  varchar2
    --                      calling sequence of the API for the debugging purpose.
    -- Calling API      : AP_RECURRING_INVOICES_PKG.ap_create_recurring_invoices
    --
    -- End of comments
    -- ----------------

PROCEDURE verify_create_adls( p_invoice_id  IN NUMBER,
                              p_calling_sequence IN VARCHAR2 ) ;

PROCEDURE validate_transaction( x_project_id	        IN            NUMBER,
				x_task_id               IN            NUMBER,
				x_award_id              IN            NUMBER,
				x_expenditure_type      IN            varchar2,
				x_expenditure_item_date IN            DATE,
				x_calling_sequence      in            VARCHAR2,
				x_msg_application       in out nocopy VARCHAR2,
				x_msg_type              out nocopy    VARCHAR2,
				X_msg_count             OUT nocopy    NUMBER,
				X_msg_data              OUT nocopy    VARCHAR2 ) ;

FUNCTION GET_DISTRIBUTION_AWARD ( p_award_set_id IN NUMBER ) return NUMBER ;

FUNCTION vert_install RETURN BOOLEAN; /* Added for Bug 5194359 */

END GMS_AP_API;

 

/

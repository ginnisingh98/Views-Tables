--------------------------------------------------------
--  DDL for Package AP_ISP_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ISP_UTILITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: apisputs.pls 120.15.12010000.3 2010/10/25 09:19:37 ppodhiya ship $ */

  PROCEDURE get_doc_sequence(
	      p_invoice_id			        IN	      NUMBER,
          p_sequence_numbering          IN        VARCHAR2,
    	  p_doc_category_code		OUT NOCOPY    VARCHAR,
          p_db_sequence_value           OUT NOCOPY NUMBER,
          p_db_seq_name                 OUT NOCOPY VARCHAR2,
          p_db_sequence_id              OUT NOCOPY NUMBER,
          p_calling_sequence            IN         VARCHAR2);

  PROCEDURE get_payment_terms (
    p_invoice_id	             IN 	       NUMBER,
    p_terms_id                   OUT NOCOPY    NUMBER,
    p_terms_date                 OUT NOCOPY    DATE,
    p_calling_sequence           IN            VARCHAR2);

  PROCEDURE Cancel_Single_Invoice(
               P_invoice_id                 IN  NUMBER,
               P_last_updated_by            IN  NUMBER,
               P_last_update_login          IN  NUMBER,
               P_accounting_date            IN  DATE,
               P_message_name               OUT NOCOPY VARCHAR2,
	           P_Token			    OUT NOCOPY VARCHAR2,
               P_calling_sequence           IN  VARCHAR2);

 /* Bug 5470344 XBuild11 Code cleanup
    This code is not being used
  PROCEDURE Discard_Inv_Line(
               p_invoice_id        IN  ap_invoice_lines.invoice_id%TYPE,
               p_line_number   	   IN  ap_invoice_lines.line_number%TYPE,
               p_calling_mode      IN  VARCHAR2,
               p_inv_cancellable   IN  VARCHAR2 DEFAULT NULL,
               P_last_updated_by   IN  NUMBER,
               P_last_update_login IN  NUMBER,
               P_error_code        OUT NOCOPY VARCHAR2,
               P_token             OUT NOCOPY VARCHAR2,
               P_calling_sequence  IN  VARCHAR2);
  */
 /* Bug 5407726 ISP Code cleanup XBuild9
    This code is not being used
  PROCEDURE invoke_ap_workflow(
               P_item_key          IN  VARCHAR2,
               p_invoice_id        IN  ap_invoices.invoice_id%TYPE,
               p_org_id            IN  ap_invoices.org_id%TYPE,
               P_calling_sequence  IN  VARCHAR2);
  */

  PROCEDURE override_tax(
             P_Invoice_id              IN NUMBER,
             P_Calling_Mode            IN VARCHAR2,
             P_Override_Status         IN VARCHAR2,
             P_Event_Id                IN NUMBER,
             P_All_Error_Messages      IN VARCHAR2,
             P_Error_Code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN VARCHAR2);

  PROCEDURE update_invoice_header(
	  p_invoice_id			IN	      NUMBER,
          p_sequence_numbering          IN            VARCHAR2,
          p_calling_sequence            IN            VARCHAR2);

  -- Bug 5605359
  PROCEDURE update_invoice_header2(
	      p_invoice_id			IN	      NUMBER,
          p_calling_sequence            IN            VARCHAR2);

  Procedure Match_Invoice_Lines(
      P_Invoice_Id                IN NUMBER,
      P_Calling_Sequence          IN VARCHAR2);


 -- 5077334, added party_id
  Procedure get_sec_attr_value (P_user_id           IN NUMBER,
                              P_attr_code           IN VARCHAR2,
                              P_attr_value          OUT NOCOPY NUMBER,
                              P_attr_value1         OUT NOCOPY VARCHAR2,
                              P_party_id            OUT NOCOPY NUMBER,
                              P_Calling_Sequence    IN VARCHAR2);


  --added for 5126689
  --  Used by Negotiation
  PROCEDURE Release_Hold(p_hold_id IN NUMBER);

  --  Used by Negotiation
  PROCEDURE update_po_matching_columns(p_line_location_id   in number,
                                       p_po_distribution_id in number,
                                       p_quantity_change    in number,
                                       p_amount_change      in number,
                                       p_ap_uom             in varchar2,
                                       p_invoice_id         in number,
                                       p_line_number        in number,
                                       p_error_code         out nocopy varchar2,
                                       p_return_status      out nocopy varchar2,
                                       p_calling_sequence   in varchar2);

  /* Bug 5407726 ISP Code cleanup XBuild9
     This code is not being used
  PROCEDURE discard_and_rematch (p_invoice_id  in number,
                                 p_line_number in number,
                                 p_error_code  out nocopy varchar2,
                                 p_token       out nocopy varchar2);

  */
  --Bug 5500186
  PROCEDURE populate_requester(p_first_name    IN VARCHAR2,
                               p_last_name     IN VARCHAR2,
                               p_email_address IN VARCHAR2,
                               p_requester_id  IN OUT NOCOPY NUMBER);
  -- 5659917
  FUNCTION get_po_number_switcher(p_invoice_id    IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_po_number(p_invoice_id             IN NUMBER)
  RETURN VARCHAR2;

  --Bug 5704381
  FUNCTION get_po_header_id(p_invoice_id          IN NUMBER)
  RETURN NUMBER;

  FUNCTION get_po_release(p_invoice_id            IN NUMBER,
                          p_ret_value             IN VARCHAR2)
  RETURN NUMBER;

  --Bug 8865603
  PROCEDURE stop_approval(p_invoice_id NUMBER);

FUNCTION unsubmit_switcher(
	p_wfapproval_status VARCHAR2,
	p_approval_ready_flag VARCHAR2,
	p_cancel_date DATE,
	p_invoice_type VARCHAR2) RETURN VARCHAR2;

  --Bug 8865603

  -- Wrapper API created to invoke pa_acc_gen_wf_pkg.ap_inv_generate_account
  -- from java layer. pa_acc_gen_wf_pkg.ap_inv_generate_account can not be
  -- invoked directly as the PAI returns boolean which is not supported
  -- from java.

  FUNCTION ap_inv_generate_account_wrap
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
	p_input_ccid			IN gl_code_combinations.code_combination_id%TYPE default null,
	x_return_ccid			OUT NOCOPY gl_code_combinations.code_combination_id%TYPE,
	x_concat_segs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_ids			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_concat_descrs			IN OUT NOCOPY VARCHAR2,  -- Bug 5935019
	x_error_message			OUT NOCOPY VARCHAR2,
	X_award_set_id			IN  NUMBER DEFAULT NULL,
        p_accounting_date               IN  ap_invoice_distributions_all.accounting_date%TYPE default NULL,
        p_award_id                      IN  NUMBER DEFAULT NULL,
        p_expenditure_item_id           IN  NUMBER DEFAULT NULL )

      RETURN NUMBER;

END AP_ISP_UTILITIES_PKG;

/

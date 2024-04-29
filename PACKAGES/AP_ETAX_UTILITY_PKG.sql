--------------------------------------------------------
--  DDL for Package AP_ETAX_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ETAX_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: apetxuts.pls 120.15.12010000.5 2010/02/02 12:08:47 anarun ship $ */

/*=============================================================================
 |  FUNCTION - Get_Event_Class_Code()
 |
 |  DESCRIPTION
 |      Public function that will get the event class code required to call
 |      eTax services based on the invoice type
 |
 |  PARAMETERS
 |      P_Invoice_Type_Lookup_Code - Invoice Type
 |      P_Event_Class_Code - event class code
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    08-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/

  FUNCTION Get_Event_Class_Code(
             P_Invoice_Type_Lookup_Code    IN VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Get_Event_Type_Code()
 |
 |  DESCRIPTION
 |      Public function that will get the event type code required to call
 |      eTax services based on the event class code, calling_mode and if
 |      eTax was already called or not.
 |
 |  PARAMETERS
 |      P_Event_Class_Code - Event class code
 |      P_Calling_Mode - Calling mode
 |      P_eTax_Already_called_flag - Is eTax already called?
 |      P_Event_Type_Code - event type code
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    09-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/

  FUNCTION Get_Event_Type_Code(
             P_Event_Class_Code            IN VARCHAR2,
             P_Calling_Mode                IN VARCHAR2,
             P_eTax_Already_called_flag    IN VARCHAR2,
             P_Event_Type_Code             OUT NOCOPY VARCHAR2,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Get_Corrected_Invoice_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Corrected_Invoice_Id - Invoice Id for the corrected line
 |      P_corrected_Line_number - Line number for the corrected line
 |      P_Application_Id - Application Id for the corrected invoice
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the corrected invoice
 |      P_Invoice_Number - Corrected invoice number
 |      P_Invoice_Date - corrected invoice date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    13-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Corrected_Invoice_Info(
             P_Corrected_Invoice_Id        IN NUMBER,
             P_Corrected_Line_Number       IN NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Invoice_Number              OUT NOCOPY VARCHAR2,
             P_Invoice_Date                OUT NOCOPY DATE,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Get_Prepay_Invoice_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Prepay_Invoice_Id - Invoice Id for the applied prepay line
 |      P_Prepay_Line_number - Line number for the applied prepay line
 |      P_Application_Id - Application Id for the applied prepay invoice
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the applied prepay invoice
 |      P_Invoice_Number - Applied Prepayment number
 |      P_Invoice_Date - Applied prepayment invoice date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Prepay_Invoice_Info(
             P_Prepay_Invoice_Id        IN NUMBER,
             P_Prepay_Line_Number       IN NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Invoice_Number              OUT NOCOPY VARCHAR2,
             P_Invoice_Date                OUT NOCOPY DATE,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;


/*=============================================================================
 |  FUNCTION - Get_Receipt_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Rcv_Transaction_Id - Receipt id
 |      P_Application_Id - Application Id for the Receipt (201)
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the receipt
 |      P_Transaction_Date - Transaction date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Receipt_Info(
             P_Rcv_Transaction_Id          IN NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Transaction_Date            OUT NOCOPY DATE,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Get_PO_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Po_line_location_id - PO line location
 |      P_Po_Distribution_id - Po distribution
 |      P_Application_Id - Application Id for the PO document (201)
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the PO doc
 |      P_PO_Quantity - PO quantity
 |      P_Product_Org_Id - Product Org_id
 |      P_Po_Header_Id - po header id
 |      P_Po_Header_Curr_Conv_Rate - Po Header currency conversion rate
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |    20-OCT-2003   SYIDNER        Included po_distribution as a parameter
 |                                 and modify the function to return Po data
 |                                 for the call to the determine_recovery serv
 |
 *============================================================================*/
  FUNCTION Get_PO_Info(
             P_PO_Line_Location_Id         IN OUT NOCOPY NUMBER,
             P_Po_Distribution_Id          IN NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_PO_Quantity                 OUT NOCOPY NUMBER,
             P_Product_Org_Id              OUT NOCOPY NUMBER,
             P_Po_Header_Id                OUT NOCOPY NUMBER,
             P_Po_Header_Curr_Conv_Rate    OUT NOCOPY NUMBER,
             P_Uom_Code                    OUT NOCOPY VARCHAR2,
             P_Dist_Qty                    OUT NOCOPY NUMBER,
             P_Ship_Price                  OUT NOCOPY NUMBER,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Get_Prepay_Awt_Group_Id()
 |
 |  DESCRIPTION
 |      This function return the awt_group_id for a parent prepay item line
 |      based on the prepayment distribution id.
 |
 |  PARAMETERS
 |      P_Prepay_Distribution_id - Distribution Id of the prepayment
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Prepay_Awt_Group_Id(
             P_Prepay_Distribution_id    IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN NUMBER;


/*=============================================================================
 |  FUNCTION - Return_Tax_Lines()
 |
 |  DESCRIPTION
 |      This function handles the return of tax lines.  It includes creation,
 |      update, or delete of existing exclusive tax lines in AP if required.
 |      It also handles the update of the total tax amounts. (Inclusive and
 |      self-assessed.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Tax_Lines(
             P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Return_Tax_Distributions()
 |
 |  DESCRIPTION
 |      This function handles the return of tax distributions.  It includes creation,
 |      update, or delete of existing distributions and TIPV and TERV distributions if
 |      required.
 |      It also handles the creation, update or delete of self-assessed
 |      distributions.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_All_Error_Messages - Should API return 1 error message or allow
 |                             calling point to get them from message stack
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    23-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Tax_Distributions(
             P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
             P_All_Error_Messages        IN VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Return_Tax_Quote()
 |
 |  DESCRIPTION
 |      This function handles the return of tax lines when the calculate service is
 |      ran for quote.  This case is specific for recurring invoices and invoice lines
 |      created through distribution sets.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    03-NOV-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Tax_Quote(
             P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Return_Default_Import()
 |
 |  DESCRIPTION
 |      This function handles the return of default values for tax and trx lines
 |      after running the eTax service that validates and defaults info during the
 |      import program.  This function will modify the pl/sql tables used in the
 |      import program.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_All_Error_Messages - Should API return 1 error message or allow
 |                             calling point to get them from message stack
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |	P_Invoice_Status -Status flag to check if further processing should be done.--Bug6625518
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Default_Import(
             P_Invoice_Header_Rec        IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
             P_Invoice_Lines_Tab         IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.t_lines_table,
             P_All_Error_Messages        IN VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2,
	     P_Invoice_Status		 OUT NOCOPY VARCHAR2) --Bug6625518
	     RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Return_Error_Messages()
 |
 |  DESCRIPTION
 |      This function will handle the return of the error messages from the
 |      eTax services.  The services can return 1 or more error messages or
 |      warnings.  The calling point will indicate the API if it wants the return of
 |      only 1 error messages through the parameter P_All_Error_Messages = N
 |      eventhough the service returns more than one error message.
 |      If the calling point requires all the error messages, it will need to get them
 |      directly from the message stack.
 |
 |  PARAMETERS
 |      P_All_Error_Messages - Y or N.  It indicades if the function will return
 |                             only 1 message or will allow the calling module
 |                             to handle the returning of errors.
 |      P_Msg_Count - Number of error messages the eTax function returns.
 |      P_Msg_Data - In case only 1 error is return the text of the name of the
 |                   message
 |      P_Error_Code - The error code this function will return if
 |                     all_error_messages is N
 |      P_Calling_Sequence - Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    05-NOV-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Error_Messages(
             P_All_Error_Messages        IN VARCHAR2,
             P_Msg_Count                 IN NUMBER,
             P_Msg_Data                  IN VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Is_Tax_Already_Calc_Inv()
 |
 |  DESCRIPTION
 |    This function will return TRUE if any taxable line in the invoice has the
 |    tax_already_calculated_flag equals Y.  It will return FALSE otherwise.
 |
 |  PARAMETERS
 |    P_Invoice_Id - Invoice Id
 |    P_Calling_Sequence - calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    29-DEC-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Is_Tax_Already_Calc_Inv(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

  /*=============================================================================
  |  FUNCTION - Is_Tax_Already_Calc_Inv_char()
  |
  |  DESCRIPTION
  |    This function will return 'Y' if any taxable line in the invoice has the
  |    tax_already_calculated_flag equals Y.  It will return 'N' otherwise.
  |
  |	It is same as the function Is_Tax_Already_Calc_Inv except that it will
  |	 return a VARCHAR value instead of BOOLEAN
  |
  |  PARAMETERS
  |    P_Invoice_Id - Invoice Id
  |    P_Calling_Sequence - calling sequence
  |
  |  MODIFICATION HISTORY
  |    DATE          Author         Action
  |    09-JUL-2004   SMYADAM        Created
  |
  *============================================================================*/
  FUNCTION Is_Tax_Already_Calc_Inv_char(
  	     P_Invoice_Id		IN NUMBER,
	     P_Calling_Sequence		IN VARCHAR2) RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION - Is_Tax_Already_Dist_Inv()
 |
 |  DESCRIPTION
 |    This function will return TRUE if any taxable distribution for the invoice
 |    has the tax_already_distributed_flag equals Y.  It will return FALSE otherwise.
 |
 |  PARAMETERS
 |    P_Invoice_Id - Invoice Id
 |    P_Calling_Sequence - calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    29-DEC-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Is_Tax_Already_Dist_Inv(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Get_Dist_Id_For_Tax_Dist_Id()
 |
 |  DESCRIPTION
 |    This function will return the invoice_distribution_id for an AP TAX (
 |    recoverable, non recoverable or tax variance distribution)
 |    based on the detail_tax_dist_id
 |
 |  PARAMETERS
 |    P_Tax_Dist_Id - Is the id for a Tax distribution in eTax
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    02-APR-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Dist_Id_For_Tax_Dist_Id(
             P_Tax_Dist_Id               IN NUMBER ) RETURN NUMBER;

/*=============================================================================
 |  PROCEDURE - set_tax_security_context()
 |
 |  DESCRIPTION
 |    This procedure will return the tax effective date. The effective date
 |    is used in the list of values for tax drivers and tax related attributes.
 |
 |  PARAMETERS
 |    P_Tax_Dist_Id       - Is the id for a Tax distribution in eTax
 |    P_Org_Id            - Default organization identifier.
 |    P_Legal_Entity_Id   - Legal entity identifier.
 |    P_Transaction_Date  - Document Transaction Date
 |    P_Related_Doc_Date  - Date of the related document.  (Eg: Standard PO)
 |    P_Adjusted_Doc_Date - Date of the adjusted document. (Eg: DM/CM applied to Invoice)
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE set_tax_security_context
				(p_org_id		IN NUMBER,
				 p_legal_entity_id	IN NUMBER,
				 p_transaction_date	IN DATE,
				 p_related_doc_date	IN DATE,
				 p_adjusted_doc_date	IN DATE,
				 p_effective_date	OUT NOCOPY DATE,
				 p_return_status	OUT NOCOPY VARCHAR2,
				 p_msg_count		OUT NOCOPY NUMBER,
				 p_msg_data		OUT NOCOPY VARCHAR2);

/*=============================================================================
 |  FUNCTION - get_tipv()
 |
 |  DESCRIPTION
 |    This function will return the tax invoice price variance.
 *============================================================================*/
  FUNCTION get_tipv ( p_rate_tax_factor		IN NUMBER   ,
		      p_quantity_invoiced	IN NUMBER   ,
		      p_inv_unit_price		IN NUMBER   ,
		      p_ref_doc_unit_price	IN NUMBER   ,
		      p_ref_per_unit_nr_amt	IN NUMBER   ,
		      p_pc_price_diff		IN NUMBER   ,
		      p_corrected_inv_id	IN NUMBER   ,
		      p_line_type		IN VARCHAR2 ,
		      p_line_source		IN VARCHAR2 ,
		      p_inv_currency_code	IN VARCHAR2 ,
		      p_line_match_type		IN VARCHAR2 ) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION get_tipv_base()
 |
 |  DESCRIPTION
 |    This function will return the tax invoice price variance in functional currency.
 *============================================================================*/
  FUNCTION get_tipv_base
		( p_rate_tax_factor		IN NUMBER ,
		  p_quantity_invoiced		IN NUMBER ,
		  p_inv_unit_price		IN NUMBER ,
		  p_ref_doc_unit_price		IN NUMBER ,
		  p_ref_per_trx_nrec_amt	IN NUMBER ,
		  p_price_diff			IN NUMBER ,
		  p_inv_currency_rate		IN NUMBER ,
		  p_ref_doc_curr_rate		IN NUMBER ,
		  p_adj_doc_curr_rate		IN NUMBER ,
		  p_corrected_inv_id		IN NUMBER ,
		  p_line_type			IN VARCHAR2 ,
		  p_line_source			IN VARCHAR2 ,
		  p_inv_currency_code		IN VARCHAR2 ,
		  p_base_currency_code		IN VARCHAR2 ,
		  p_line_match_type		IN VARCHAR2 ) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION get_exchange_rate_variance()
 |
 |  DESCRIPTION
 |    This function will return the tax exchange rate variance.
 *============================================================================*/
  FUNCTION get_terv
		( p_quantity_invoiced		IN NUMBER   ,
		  p_inv_curr_conv_rate		IN NUMBER   ,
		  p_ref_doc_curr_conv_rate	IN NUMBER   ,
		  p_app_doc_curr_conv_rate	IN NUMBER   ,
		  p_adj_doc_curr_conv_rate	IN NUMBER   ,
		  p_per_unit_nrec_amt		IN NUMBER   ,
		  p_ref_doc_per_unit_nrec_amt	IN NUMBER   ,
		  p_corrected_inv_id		IN NUMBER   ,
		  p_line_type			IN VARCHAR2 ,
		  p_line_source			IN VARCHAR2 ,
		  p_base_currency_code		IN VARCHAR2 ) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION get_exchange_rate_variance()
 |
 |  DESCRIPTION
 |    This function will return the total tax variance.
 *============================================================================*/
  FUNCTION get_tv ( p_rate_tax_factor		IN NUMBER   ,
		    p_quantity_invoiced		IN NUMBER   ,
		    p_inv_per_unit_nrec         IN NUMBER   ,
		    p_ref_per_unit_nrec         IN NUMBER   ,
		    p_inv_per_trx_cur_unit_nrec IN NUMBER   ,
		    p_ref_per_trx_cur_unit_nrec	IN NUMBER   ,
		    p_pc_price_diff		IN NUMBER   ,
		    p_corrected_inv_id		IN NUMBER   ,
		    p_line_type			IN VARCHAR2 ,
		    p_line_source		IN VARCHAR2 ,
		    p_inv_currency_code		IN VARCHAR2 ,
		    p_line_match_type		IN VARCHAR2 ,
		    p_unit_price		IN NUMBER   ) RETURN NUMBER;


/*=============================================================================
 |  FUNCTION get_exchange_rate_variance()
 |
 |  DESCRIPTION
 |    This function will return the total tax variance in the functional currency.
 *============================================================================*/
  FUNCTION get_tv_base ( p_rate_tax_factor		IN NUMBER   ,
			 p_quantity_invoiced		IN NUMBER   ,
			 p_inv_per_unit_nrec		IN NUMBER   ,
			 p_ref_per_unit_nrec		IN NUMBER   ,
			 p_inv_per_trx_cur_unit_nrec	IN NUMBER   ,
			 p_ref_per_trx_cur_unit_nrec	IN NUMBER   ,
			 p_inv_curr_rate		IN NUMBER   ,
			 p_ref_doc_curr_rate		IN NUMBER   ,
			 p_pc_price_diff		IN NUMBER   ,
			 p_corrected_inv_id		IN NUMBER   ,
			 p_line_type			IN VARCHAR2 ,
			 p_line_source			IN VARCHAR2 ,
		         p_base_currency_code		IN VARCHAR2 ,
			 p_line_match_type		IN VARCHAR2 ,
			 p_unit_price			IN NUMBER   ) RETURN NUMBER;

/*=============================================================================
 |  PROCEDURE - get_header_tax_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the description of the following tax drivers
 |    stored at the document header.
 |    1. Taxation Country
 |    2. Document Sub Type
 |    3. Related Invoice
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Document_Sub_Type       - Document Sub Type
 |    P_Tax_Related_Invoice_Id  - Related Invoice
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_header_tax_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_document_sub_type           IN         VARCHAR2,
                  p_tax_related_inv_id          IN         NUMBER,
                  p_taxation_country_desc       OUT NOCOPY VARCHAR2,
                  p_document_sub_type_desc      OUT NOCOPY VARCHAR2,
                  p_tax_related_inv_num         OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2);

/*=============================================================================
 |  PROCEDURE - get_taxable_line_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the descriptions of tax drivers on the taxable
 |    line.
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Trx_Bus_Category        - Transaction Business Category
 |    P_Prd_Fisc_Class          - Product Fiscal Classification
 |    P_User_Fisc_Class         - User Defined Fiscal Classification
 |    P_Prim_Int_Use            - Primary Intended Use
 |    P_Product_Type            - Product Type
 |    P_Product_Category        - Product Category
 |    P_Inv_Item_Id             - Inventory Item Identifier
 |    P_Org_Id                  - Organization Identifier
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_taxable_line_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_trx_bus_category            IN         VARCHAR2,
                  p_prd_fisc_class              IN         VARCHAR2,
                  p_user_fisc_class             IN         VARCHAR2,
                  p_prim_int_use                IN         VARCHAR2,
                  p_product_type                IN         VARCHAR2,
                  p_product_category            IN         VARCHAR2,
                  p_inv_item_id                 IN         NUMBER,
                  p_org_id                      IN         NUMBER,
                  p_trx_bus_category_desc       OUT NOCOPY VARCHAR2,
                  p_prd_fisc_class_desc         OUT NOCOPY VARCHAR2,
                  p_user_fisc_class_desc        OUT NOCOPY VARCHAR2,
                  p_prim_int_use_desc           OUT NOCOPY VARCHAR2,
                  p_product_type_desc           OUT NOCOPY VARCHAR2,
                  p_product_category_desc       OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2);

/*=============================================================================
 |  PROCEDURE - get_tax_line_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the descriptions of tax related attributes
 |    on the tax line.
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Tax_Regime_Code         - Tax Regime
 |    P_Tax                     - Tax
 |    P_Tax_Jurisdiction_Code   - Tax Jurisidiction
 |    P_Tax_Status_Code         - Tax Status
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_tax_line_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_tax_regime_code             IN         VARCHAR2,
                  p_tax                         IN         VARCHAR2,
                  p_tax_jurisdiction_code       IN         VARCHAR2,
                  p_tax_status_code             IN         VARCHAR2,
                  p_tax_regime_code_desc        OUT NOCOPY VARCHAR2,
                  p_tax_desc                    OUT NOCOPY VARCHAR2,
                  p_tax_jurisdiction_desc       OUT NOCOPY VARCHAR2,
                  p_tax_status_code_desc        OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2);


/*=============================================================================
 |  PROCEDURE - get_default_tax_det_attribs()
 |
 |  DESCRIPTION
 |    This procedure will return the default tax drivers based on the
 |    organization identifier.
 |
 |  PARAMETERS
 |    P_Org_Id          - Organization Id
 |    P_Legal_Entity_Id - Legal Entity Id
 |    P_Item_Id         - Inventory Item Id
 |    P_Doc_Type        - Document Type
 |    P_Trx_Date        - Transaction Date
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_default_tax_det_attribs
                        (p_org_id               IN NUMBER,
                         p_legal_entity_id      IN NUMBER,
                         p_item_id              IN NUMBER,
                         p_doc_type             IN VARCHAR2,
                         p_trx_date             IN DATE,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         p_country_code         OUT NOCOPY VARCHAR2,
                         p_trx_biz_category     OUT NOCOPY VARCHAR2,
                         p_intended_use         OUT NOCOPY VARCHAR2,
                         p_prod_category        OUT NOCOPY VARCHAR2,
                         p_prod_fisc_class_code OUT NOCOPY VARCHAR2,
                         p_calling_sequence     IN VARCHAR2);



 --ETAX: Invwkb
 /*=============================================================================
 |  FUNCTION - Is_Tax_Dist_Frozen()
 |
 |  DESCRIPTION
 |    This function will return TRUE when the tax distribution is frozen
 |    as per the following rules, else will return FALSE.
 |
 |    When the function returns TRUE, then user should not modify the tax
 |    distribution, and vice versa.
 |
 |  PARAMETERS
 |    P_Invoice_Id  - Is the invoice_id of the tax distribution
 |    P_Tax_Dist_Id - Is the id for a Tax distribution in eTax
 |
 |  USAGE: This function is called from ETAX security functions in APXINWKB.fmb
 |         from the form procedure 'IS_TAX_DIST_FROZEN'.
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    01-JUL-2004   SMYADAM        Created
 |
 *============================================================================*/

 FUNCTION IS_TAX_DIST_FROZEN(P_Invoice_Id IN NUMBER,
			     P_Tax_Dist_Id IN NUMBER,
			     P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN;


 /*=============================================================================
 |  FUNCTION - Is_Tax_Dist_Frozen()
 |
 |  DESCRIPTION
 |    This function will return TRUE when Detail Tax line can be deleted in ETAX,
 |    else will return FALSE.
 |
 |    When the function returns TRUE, then user can delete the TAX line else
 |	should not be allowed to delete the TAX line.
 |
 |  PARAMETERS
 |    P_Invoice_Id  - Is the invoice_id of the of the Invoice which owns this
 |		      detail tax line indirectly through the summary tax line.
 |    P_Detail_Tax_Line_Id - Is the id for a Detail Tax Line in eTax
 |
 |  USAGE: This function is called from ETAX security functions in APXINWKB.fmb
 |         from the form procedure 'IS_TAX_LINE_DELETE_ALLOWED'.
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    04-JUL-2004   SMYADAM        Created
 |
 *============================================================================*/
 FUNCTION IS_TAX_LINE_DELETE_ALLOWED(P_Invoice_Id IN NUMBER,
 				     P_Detail_Tax_Line_Id IN NUMBER,
 				     P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN;

 -- Bug 4887847: Added function Get_Line_Class to populate a new attribute that
 --              is required for tax calculation and reporting purposes.

/*=============================================================================
 |  FUNCTION - Get_Line_Class()
 |
 |  DESCRIPTION
 |    This function will return the line class based on the invoice document type
 |    invoice line type and matching information.
 |
 *============================================================================*/

 FUNCTION Get_Line_Class(
             P_Invoice_Type_Lookup_Code    IN  VARCHAR2,
             P_Inv_Line_Type               IN  VARCHAR2,
             P_Line_Location_Id            IN  NUMBER,
             P_Line_Class                  OUT NOCOPY VARCHAR2,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN  VARCHAR2) RETURN BOOLEAN;

/*=============================================================================
 |  FUNCTION - Get_Converted_Price()
 |
 |  DESCRIPTION
 |    This function will return the unit price in receipts UOM if the Receipt
 |    and Purchase Order UOM are different.
 |
 *============================================================================*/

 FUNCTION Get_Converted_Price(
	    X_Invoice_Distribution_Id IN NUMBER) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION - Get_Max_Dist_Num_Self
 |
 |  DESCRIPTION
 |    This function will return the maximum distribution line number of self
 |    assessed tax distributions.
 |
 *============================================================================*/

 FUNCTION Get_Max_Dist_Num_Self
                        (X_invoice_id  IN NUMBER,
                         X_line_number IN NUMBER) RETURN NUMBER;

 /*=============================================================================
 |  FUNCTION - Is_Tax_Already_Dist_Inv_char()
 |
 |  DESCRIPTION
 |    This function will return 'Y' if any taxable distribution has the
 |    tax_already_calculated_flag equals Y.  It will return 'N' otherwise.
 |
 *============================================================================*/

 FUNCTION Is_Tax_Already_Dist_Inv_Char(
             P_Invoice_Id       IN NUMBER,
             P_Calling_Sequence IN VARCHAR2) RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION - Get_Prepay_Pay_Awt_Group_Id()
 |
 |  DESCRIPTION
 |      This function return the awt_group_id for a parent prepay item line
 |      based on the prepayment distribution id.
 |		Added for bug8345264
 |
 |  PARAMETERS
 |      P_Prepay_Distribution_id - Distribution Id of the prepayment
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    30-MAR-2009   ASANSARI        Created
 |
 *============================================================================*/
  FUNCTION Get_Prepay_Pay_Awt_Group_Id(
             P_Prepay_Distribution_id    IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN NUMBER;

/*=============================================================================
 |  FUNCTION - Is_Inclusive_Flag_Updatable()
 |
 |  DESCRIPTION
 |      This function is called by Ebtax to make the Inclusive Check Box
 |      on Detail Tax Window editable based on return status by this
 |		function.Added for ER 6772098
 |      RETURN TRUE   : Allow To Override Inclusive Checkbox
 |      RETURN FALUSE : Don't Allow To Override Inclusive Checkbox
 |
 |
 |  PARAMETERS
 |      p_invoice_id  - Invoice Id of the Invoice open on workbench
 |      p_line_number - Invoice Line Number of Non Tax Line for which
 |                      Detail Tax line is being overriden
 |                      (Inclusive Check Box)
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    31-JUL-2009   hchaudha        Created
 |
 *============================================================================*/
  FUNCTION is_inclusive_flag_updatable
          (p_invoice_id     IN NUMBER,
           p_line_number      IN NUMBER,
           p_error_code   IN OUT NOCOPY VARCHAR2,
           p_calling_sequence IN VARCHAR2) Return Boolean;

/*=============================================================================
 |  FUNCTION - Is_Incl_Tax_Driver_Updatable()
 |
 |  DESCRIPTION
 |      Called from : AP_ETAX_SERVICES_PKG.Populate_Lines_GT()
 |                    APINLIN.pld
 |                    APXINWKB.fmb
 |      RETURN TRUE   : Allow To Override Tax drivers
 |      RETURN FALUSE : Don't Allow To Override Tax drivers
 |
 |
 |  PARAMETERS
 |      p_invoice_id  - Invoice Id of the Invoice
 |      p_line_number - Invoice Line Number
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Bug      Action
 |    02-Feb-2010   ANARUN  9068689  Created
 |
 ============================================================================*/

FUNCTION Is_Incl_Tax_Driver_Updatable(
         p_invoice_id       IN NUMBER,
         p_line_number      IN NUMBER,
         p_calling_sequence IN VARCHAR2 )
RETURN BOOLEAN ;

END AP_ETAX_UTILITY_PKG;

/

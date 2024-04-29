--------------------------------------------------------
--  DDL for Package IGC_ETAX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_ETAX_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCETXUS.pls 120.2 2008/02/11 06:06:26 dvjoshi noship $ */

-- Global Variables
IGC_APPLICATION_ID      CONSTANT NUMBER       := 8407;
IGC_ENTITY_CODE         CONSTANT VARCHAR2(64) := 'IGC_CC_HEADERS';
IGC_EVENT_CLASS_CODE    CONSTANT VARCHAR2(64) := 'PURCHASE_TRANSACTION_TAX_QUOTE';
IGC_EVENT_TYPE_CODE     CONSTANT VARCHAR2(32) := 'CREATE';
IGC_TAX_EVENT_TYPE_CODE CONSTANT VARCHAR2(32) := 'CREATE';
IGC_TRX_LEVEL_TYPE      CONSTANT VARCHAR2(32) := 'LINE';
IGC_LINE_LEVEL_ACTION   CONSTANT VARCHAR2(32) := 'CREATE';
IGC_LINE_CLASS          CONSTANT VARCHAR2(32) := 'INVOICE';
IGC_TAX_QUOTE_FLAG      CONSTANT VARCHAR2(1)  := 'Y';
G_BATCH_LIMIT           CONSTANT NUMBER       := 1000;

/*=============================================================================
 |  PROCEDURE - set_tax_security_context()
 |
 |  DESCRIPTION
 |    This procedure will return the tax effective date. The effective date
 |    is used in the list of values for tax drivers and tax related attributes.
 |
 |  PARAMETERS
 |      p_org_id                - Operating unit identifier
 |      p_legal_entity_id       - Legal entity identifier.
 |      p_transaction_date      - Transaction Date.
 |      p_related_doc_date      - Date of the related document.
 |      p_adjusted_doc_date     - Date of the adjusted document.
 |
 *============================================================================*/
  PROCEDURE set_tax_security_context
                                (p_org_id               IN NUMBER,
                                 p_legal_entity_id      IN NUMBER,
                                 p_transaction_date     IN DATE,
                                 p_related_doc_date     IN DATE,
                                 p_adjusted_doc_date    IN DATE,
                                 p_effective_date       OUT NOCOPY DATE,
                                 p_return_status        OUT NOCOPY VARCHAR2,
                                 p_msg_count            OUT NOCOPY NUMBER,
                                 p_msg_data             OUT NOCOPY VARCHAR2);

/*=============================================================================
 |  FUNCTION - Populate_Headers_GT()
 |
 |  DESCRIPTION
 |      This function will get additional information required to populate the
 |      ZX_TRANSACTION_HEADERS_GT
 |      This function returns TRUE if the insert to the temp table goes
 |      through successfully.  Otherwise, FALSE.
 |
 |  PARAMETERS
 |      P_CC_Header_Rec - record with cc header information
 |      P_Calling_Mode - calling mode. it is used to
 |      P_Event_Class_Code - Event class code
 |      P_Event_Type_Code - Event type Code
 |      P_error_code - Error code to be returned
 |
 *============================================================================*/
  FUNCTION Populate_Headers_GT(
             P_CC_Header_Rec             IN igc_cc_headers%ROWTYPE,
             P_Calling_Mode              IN VARCHAR2,
             --P_Event_Class_Code          IN VARCHAR2,
             --P_Event_Type_Code           IN VARCHAR2,
             P_Legal_Entity_Id     IN NUMBER,
       P_Error_Code                OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION - Populate_Lines_GT()
 |
 |  DESCRIPTION
 |      This function will get additional information required to populate the
 |      ZX_TRANSACTION_LINES_GT
 |      This function returns TRUE if the population of the temp table goes
 |      through successfully.  Otherwise, FALSE.
 |
 |
 *============================================================================*/
  /* Bug 6719456 - Added new parameter P_Line_Id */
  FUNCTION Populate_Lines_GT(
             P_CC_Header_Rec           IN igc_cc_headers%ROWTYPE,
             P_Line_Id                 IN igc_cc_acct_lines.cc_acct_line_id%type,
             P_Calling_Mode            IN VARCHAR2,
             --P_Event_Class_Code        IN VARCHAR2,
             --P_Line_Number             IN NUMBER DEFAULT NULL,
             P_Error_Code              OUT NOCOPY VARCHAR2,
             P_Calling_Sequence        IN VARCHAR2,
       P_Amount          IN NUMBER) RETURN VARCHAR2;


/*=============================================================================
 |  FUNCTION - Calculate_Tax()
 |
 |  DESCRIPTION
 |      This function will call procedure to populate the
 |      ZX_TRANSACTION_HEADERS_GT,Populate_Lines_GT than E-Btax api calculate_tax
 |      This function returns TRUE call goes
 |      through successfully.  Otherwise, FALSE.
 |
 |  PARAMETERS
 |      P_CC_Header_Rec - record with cc header information
 |      P_Calling_Mode - calling mode. it is used to
 |  P_error_code - Error code to be returned
 |      P_Amt_Type -  Amount type on which tax need to be calculated.
 *============================================================================*/
  Procedure Calculate_Tax(
             P_CC_Header_Rec             IN igc_cc_headers%ROWTYPE,
    P_Calling_Mode              IN VARCHAR2,
    P_Error_Code        OUT NOCOPY VARCHAR2,
    P_Amount                    IN NUMBER,
    P_Tax_Amount        OUT NOCOPY NUMBER,
    P_Line_Id       IN  igc_cc_acct_lines.cc_acct_line_id%type,
    P_Return_Status       OUT NOCOPY  VARCHAR2);
/*=============================================================================
*/
PROCEDURE get_cc_def_tax_classification(
             p_cc_header_id                 IN  zx_lines_det_factors.ref_doc_trx_id%TYPE,
             p_cc_line_id                   IN  zx_lines_det_factors.ref_doc_line_id%TYPE,
             p_cc_trx_level_type            IN  zx_lines_det_factors.ref_doc_trx_level_type%TYPE,
             p_vendor_id                    IN  po_vendors.vendor_id%TYPE,
             p_vendor_site_id               IN  po_vendor_sites.vendor_site_id%TYPE,
             p_code_combination_id          IN  gl_code_combinations.code_combination_id%TYPE,
             p_concatenated_segments        IN  varchar2,
             p_templ_tax_classification_cd  IN  varchar2,
             p_tax_classification_code      IN  OUT NOCOPY varchar2,
             p_allow_tax_code_override_flag     OUT NOCOPY zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE,
             p_tax_user_override_flag   IN  VARCHAR2,
             p_user_tax_name            IN  VARCHAR2,
             p_legal_entity_id              IN  zx_lines.legal_entity_id%TYPE,
             p_calling_sequence             IN  VARCHAR2,
             p_internal_organization_id     IN  NUMBER);

END IGC_ETAX_UTIL_PKG;

/

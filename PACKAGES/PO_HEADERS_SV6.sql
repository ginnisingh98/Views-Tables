--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV6" AUTHID CURRENT_USER AS
/* $Header: POXPIV2S.pls 115.4 2003/06/26 22:17:45 dxie noship $ */

/*==================================================================
  FUNCTION NAME:  val_doc_num_uniqueness()

  DESCRIPTION:    This API is used to validate the uniqueness of the
                  document number for a particular document type.

  PARAMETERS:     x_segment1         IN VARCHAR2,
                  X_rowid            IN VARCHAR2,
                  X_type_lookup_code IN VARCHAR2

  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:      API will returns TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan


=======================================================================*/
 FUNCTION val_doc_num_uniqueness(x_segment1         IN VARCHAR2,
                                 X_rowid            IN VARCHAR2,
                                 X_type_lookup_code IN VARCHAR2)
 RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_header_id_uniqueness()

  DESCRIPTION:    This API is used to validate the uniqueness of
                  po_header_id in po_headers table.

  PARAMETERS:     x_po_header_id       IN NUMBER
                  X_row_id             IN VARCHAR2


  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan


=======================================================================*/
 FUNCTION val_header_id_uniqueness (x_po_header_id  IN NUMBER,
                                    x_rowid         IN VARCHAR2)
 RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_rate_info()

  DESCRIPTION:    This API is used to validate rate_type, rate_date
                  and rate information

  PARAMETERS:     X_base_currency_code   IN  VARCHAR2,
                  X_currency_code        IN  VARCHAR2,
                  X_rate_type_code       IN  VARCHAR2,
                  X_rate_date            IN  DATE,
                  X_rate                 IN  NUMBER,
                  x_error_code           IN OUT VARCHAR2


  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  and error_code otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan
                  Modified      13-MAR-1996     Daisy Yu

=======================================================================*/
FUNCTION val_rate_info(X_base_currency_code   IN  VARCHAR2,
                       X_currency_code        IN  VARCHAR2,
                       X_rate_type_code       IN  varchar2,
                       X_rate_date            IN  DATE,
                       X_rate                 IN  NUMBER,
                       X_error_code           IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_doc_num()

  DESCRIPTION:    This API is used to validate the document number(
                  i.e. to find out if it is a numeric value and also
                  to check if it is greater than zero(only if the option
                  is 'numeric')).

  PARAMETERS:     X_doc_type                   IN VARCHAR2,
                  X_doc_num                    IN VARCHAR2,
                  X_user_defined_num           IN VARCHAR2,
                  X_user_defined_po_num_code   IN VARCHAR2,
                  X_error_code                 IN OUT VARCHAR2


  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan
                  Modified      13-MAR-1996     Daisy Yu

=======================================================================*/
FUNCTION val_doc_num(X_doc_type                   IN VARCHAR2,
                     X_doc_num                    IN VARCHAR2,
                     X_user_defined_num           IN VARCHAR2,
                     X_user_defined_po_num_code   IN VARCHAR2,
                     X_error_code                 IN OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

/*==================================================================
  FUNCTION NAME:  val_lookup_code()

  DESCRIPTION:    This API is used to validate the lookup_code and
                  make sure it is valid and active.

  PARAMETERS:     X_lookup_code     IN VARCHAR2,
                  X_lookup_type     IN VARCHAR2


  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:      API will return TRUE if validation succeeds, FALSE
                  otherwise.

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan
                  Modified      13-MAR-1996     Daisy Yu

=======================================================================*/
 FUNCTION val_lookup_code (X_lookup_code     IN VARCHAR2,
                           X_lookup_type     IN VARCHAR2)
 RETURN BOOLEAN;


/*==================================================================
  PROCEDURE NAME:  validate_po_headers()

  DESCRIPTION:     This API is used to validate all columns in
                   po_headers table during the purchasing Docs
                   open interface Load.

  PARAMETERS:


  DESIGN
  REFERENCES:     832vlapi.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       03-Mar-1996     Rajan Odayar
                  Modified      16-MAR-1996     Daisy Yu
                  Modified      24-APR-1996     Daisy Yu
                  Modified      11-Jun-1996     KKCHAN
                        * added approval_status validation

=======================================================================*/

PROCEDURE  validate_po_headers(
                X_PO_HEADER_ID                   IN NUMBER,
                X_AGENT_ID                       IN NUMBER,
                X_TYPE_LOOKUP_CODE               IN VARCHAR2,
                X_LAST_UPDATE_DATE               IN DATE,
                X_LAST_UPDATED_BY                IN NUMBER,
                X_SEGMENT1                       IN VARCHAR2,
                X_SUMMARY_FLAG                   IN VARCHAR2,
                X_ENABLED_FLAG                   IN VARCHAR2,
                X_SEGMENT2                       IN VARCHAR2,
                X_SEGMENT3                       IN VARCHAR2,
                X_SEGMENT4                       IN VARCHAR2,
                X_SEGMENT5                       IN VARCHAR2,
                X_START_DATE_ACTIVE              IN DATE,
                X_END_DATE_ACTIVE                IN DATE,
                X_LAST_UPDATE_LOGIN              IN NUMBER,
                X_CREATION_DATE                  IN DATE,
                X_CREATED_BY                     IN NUMBER,
                X_VENDOR_ID                      IN NUMBER,
                X_VENDOR_SITE_ID                 IN NUMBER,
                X_VENDOR_CONTACT_ID              IN NUMBER,
                X_SHIP_TO_LOCATION_ID            IN NUMBER,
                X_BILL_TO_LOCATION_ID            IN NUMBER,
                X_TERMS_ID                       IN NUMBER,
                X_SHIP_VIA_LOOKUP_CODE           IN VARCHAR2,
                X_FOB_LOOKUP_CODE                IN VARCHAR2,
                X_FREIGHT_TERMS_LOOKUP_CODE      IN VARCHAR2,
                X_STATUS_LOOKUP_CODE             IN VARCHAR2,
                X_CURRENCY_CODE                  IN VARCHAR2,
                X_RATE_TYPE                      IN VARCHAR2,
                X_RATE_DATE                      IN DATE,
                X_RATE                           IN NUMBER,
                X_FROM_HEADER_ID                 IN NUMBER,
                X_FROM_TYPE_LOOKUP_CODE          IN VARCHAR2,
                X_START_DATE                     IN DATE,
                X_END_DATE                       IN DATE,
                X_BLANKET_TOTAL_AMOUNT           IN NUMBER,
                X_AUTHORIZATION_STATUS           IN VARCHAR2,
                X_REVISION_NUM                   IN NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--              X_REVISED_DATE                   IN VARCHAR2,
                X_REVISED_DATE                   IN DATE,
                X_APPROVED_FLAG                  IN VARCHAR2,
                X_APPROVED_DATE                  IN DATE,
                X_AMOUNT_LIMIT                   IN NUMBER,
                X_MIN_RELEASE_AMOUNT             IN NUMBER,
                X_NOTE_TO_AUTHORIZER             IN VARCHAR2,
                X_NOTE_TO_VENDOR                 IN VARCHAR2,
                X_NOTE_TO_RECEIVER               IN VARCHAR2,
                X_PRINT_COUNT                    IN NUMBER,
                X_PRINTED_DATE                   IN DATE,
                X_VENDOR_ORDER_NUM               IN VARCHAR2,
                X_CONFIRMING_ORDER_FLAG          IN VARCHAR2,
                X_COMMENTS                       IN VARCHAR2,
                X_REPLY_DATE                     IN  DATE,
                X_REPLY_METHOD_LOOKUP_CODE       IN VARCHAR2,
                X_RFQ_CLOSE_DATE                 IN DATE,
                X_QUOTE_TYPE_LOOKUP_CODE         IN VARCHAR2,
                X_QUOTATION_CLASS_CODE           IN VARCHAR2,
                X_QUOTE_WARNING_DELAY            IN NUMBER,
                X_QUOTE_VENDOR_QUOTE_NUM         IN VARCHAR2,
                X_ACCEPTANCE_REQUIRED_FLAG       IN VARCHAR2,
                X_ACCEPTANCE_DUE_DATE            IN DATE,
                X_CLOSED_DATE                    IN DATE,
                X_USER_HOLD_FLAG                 IN VARCHAR2,
                X_APPROVAL_REQUIRED_FLAG         IN VARCHAR2,
                X_CANCEL_FLAG                    IN VARCHAR2,
                X_FIRM_STATUS_LOOKUP_CODE        IN VARCHAR2,
                X_FIRM_DATE                      IN DATE,
                X_FROZEN_FLAG                    IN VARCHAR2,
                X_ATTRIBUTE_CATEGORY             IN VARCHAR2,
                X_ATTRIBUTE1                     IN VARCHAR2,
                X_ATTRIBUTE2                     IN VARCHAR2,
                X_ATTRIBUTE3                     IN VARCHAR2,
                X_ATTRIBUTE4                     IN VARCHAR2,
                X_ATTRIBUTE5                     IN VARCHAR2,
                X_ATTRIBUTE6                     IN VARCHAR2,
                X_ATTRIBUTE7                     IN VARCHAR2,
                X_ATTRIBUTE8                     IN VARCHAR2,
                X_ATTRIBUTE9                     IN VARCHAR2,
                X_ATTRIBUTE10                    IN VARCHAR2,
                X_ATTRIBUTE11                    IN VARCHAR2,
                X_ATTRIBUTE12                    IN VARCHAR2,
                X_ATTRIBUTE13                    IN VARCHAR2,
                X_ATTRIBUTE14                    IN VARCHAR2,
                X_ATTRIBUTE15                    IN VARCHAR2,
                X_CLOSED_CODE                    IN VARCHAR2,
                X_USSGL_TRANSACTION_CODE         IN VARCHAR2,
                X_GOVERNMENT_CONTEXT             IN VARCHAR2,
                X_REQUEST_ID                     IN NUMBER,
                X_PROGRAM_APPLICATION_ID         IN NUMBER,
                X_PROGRAM_ID                     IN NUMBER,
                X_PROGRAM_UPDATE_DATE            IN DATE,
                X_INTERFACE_SOURCE_CODE          IN VARCHAR2,
                X_INTERFACE_HEADER_ID            IN NUMBER,
                X_REFERENCE_NUM                  IN VARCHAR2,
                X_ORG_ID                         IN NUMBER,
                X_QUOTE_WARNING_DELAY_UNIT       IN VARCHAR2,
                X_APPROVAL_STATUS                IN VARCHAR2,
                X_release_num                    IN NUMBER,
                X_po_release_id                  IN NUMBER,
                X_release_date                   IN DATE,
                X_manual_quote_num_type          IN VARCHAR2,
                X_manual_po_num_type             IN VARCHAR2,
                X_amount_agreed                  IN NUMBER,
                X_base_currency_code             IN VARCHAR2,
                X_chart_of_accounts_id           IN NUMBER,
                X_def_inv_org_id                 IN NUMBER,
                X_header_processable_flag        IN OUT NOCOPY VARCHAR2,
                X_action_code                    IN VARCHAR2,
                p_shipping_control               IN VARCHAR2    -- <INBOUND LOGISTICS FPJ>
);


END PO_HEADERS_SV6;

 

/

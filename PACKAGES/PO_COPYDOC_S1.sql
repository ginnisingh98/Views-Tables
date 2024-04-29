--------------------------------------------------------
--  DDL for Package PO_COPYDOC_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COPYDOC_S1" AUTHID CURRENT_USER AS
/* $Header: POXCPO1S.pls 120.1 2005/07/07 04:52:30 sjadhav noship $*/

-- Constants for the x_message_type parameter in po_online_report:
G_ERROR_MESSAGE_TYPE   VARCHAR2(1) := 'E';
G_WARNING_MESSAGE_TYPE VARCHAR2(1) := 'W';

/*  Functionality for PA->RFQ Copy : dreddy
    new parameter copy_price is added */
PROCEDURE copy_document(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype          IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag	    IN	    PO_HEADERS_ALL.global_agreement_flag%TYPE,	-- GA
  x_copy_attachments        IN      BOOLEAN,
  x_copy_price              IN      BOOLEAN,
  x_from_po_header_id       IN      po_headers.po_header_id%TYPE,
  x_to_po_header_id         OUT NOCOPY     po_headers.po_header_id%TYPE,
  x_online_report_id        OUT NOCOPY     po_online_report_text.online_report_id%TYPE,
  x_to_segment1             IN OUT NOCOPY  po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_wip_install_status      IN      VARCHAR2,
  x_return_code             OUT NOCOPY     NUMBER,
  x_copy_terms              IN VARCHAR2, --<CONTERMS FPJ>
  p_api_commit              IN BOOLEAN  DEFAULT TRUE, --<HTML Agreements R12>
  p_from_doc_type           IN VARCHAR2 DEFAULT NULL  --<R12 eTax Integration>
);

PROCEDURE online_report(
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_message           IN      po_online_report_text.text_line%TYPE,
  x_line_num          IN      po_online_report_text.line_num%TYPE,
  x_shipment_num      IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num  IN      po_online_report_text.distribution_num%TYPE,
  x_message_type      IN      VARCHAR2 := G_ERROR_MESSAGE_TYPE -- <PO_PJM_VALIDATION FPI>
);

PROCEDURE copydoc_sql_error(
  x_routine           IN      VARCHAR2,
  x_progress          IN      VARCHAR2,
  x_sqlcode           IN      NUMBER,
  x_online_report_id  IN      po_online_report_text.online_report_id%TYPE,
  x_sequence          IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_line_num          IN      po_online_report_text.line_num%TYPE,
  x_shipment_num      IN      po_online_report_text.shipment_num%TYPE,
  x_distribution_num  IN      po_online_report_text.distribution_num%TYPE
);

PROCEDURE copydoc_debug(
  x_message IN VARCHAR2
);

-- Bug 2744363
/**
* Returns TRUE if the given PO has any drop shipments, FALSE otherwise.
**/
FUNCTION po_is_dropship (
  p_po_header_id PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;



-- <CONFIG_ID FPJ START>

FUNCTION po_has_config_id(
  p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE
) RETURN BOOLEAN;

FUNCTION req_has_config_id(
  p_requisition_header_id IN PO_REQUISITION_HEADERS_ALL.requisition_header_id%TYPE
) RETURN BOOLEAN;

-- <CONFIG_ID FPJ END>
--<HTML Agreements R12 Start>
procedure val_params_and_duplicate_doc( p_po_header_id     IN            NUMBER
                                       ,p_copy_attachment  IN            VARCHAR2
                                       ,p_copy_terms       IN            VARCHAR2
                                       ,x_new_segment1     IN OUT NOCOPY VARCHAR2
                                       ,x_new_po_header_id    OUT NOCOPY NUMBER
                                       ,x_errmsg_code         OUT NOCOPY VARCHAR2
                                       ,x_message_type        OUT NOCOPY VARCHAR2
                                       ,x_text_line           OUT NOCOPY VARCHAR2
                                       ,x_return_status       OUT NOCOPY VARCHAR2
                                       ,x_exception_msg       OUT NOCOPY VARCHAR2);

PROCEDURE ret_and_del_online_report_rec( p_online_report_id  IN         NUMBER
                                        ,x_message_type      OUT NOCOPY VARCHAR2
                                        ,x_message           OUT NOCOPY VARCHAR2);
--<HTML Agreements R12 End>


END po_copydoc_s1;


 

/

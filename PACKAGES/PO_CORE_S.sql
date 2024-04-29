--------------------------------------------------------
--  DDL for Package PO_CORE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CORE_S" AUTHID CURRENT_USER AS
-- $Header: POXCOC1S.pls 120.9.12010000.4 2013/10/03 09:30:27 inagdeo ship $



--------------------------------------------------------------------------------
-- Public exceptions
--------------------------------------------------------------------------------

--- Used instead of simply writing a RETURN statement,
--- as having RETURNs at multiple places in a procedure
--- is poor programming style, making maintenance
--- of common exit code difficult.
--- See /podev/po/internal/standards/logging/logging.xml for more info.
G_EARLY_RETURN_EXC  EXCEPTION;

--- Used in situations where the prereqs for the procedure
--- are not satisfied, or the parameters that have been
--- passed are invalid.
G_INVALID_CALL_EXC  EXCEPTION;




-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------


-- Document types

g_doc_type_REQUISITION           CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'REQUISITION'
   ;
g_doc_type_PO                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'PO'
   ;
g_doc_type_PA                    CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'PA'
   ;
g_doc_type_RELEASE               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'RELEASE'
   ;
-- For is_encumbrance_on:
g_doc_type_ANY                   CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := 'ANY'
   ;


-- Document levels

g_doc_level_HEADER               CONSTANT
   VARCHAR2(30)
   := 'HEADER'
   ;
g_doc_level_LINE                 CONSTANT
   VARCHAR2(30)
   := 'LINE'
   ;
g_doc_level_SHIPMENT             CONSTANT
   VARCHAR2(30)
   := 'SHIPMENT'
   ;
g_doc_level_DISTRIBUTION         CONSTANT
   VARCHAR2(30)
   := 'DISTRIBUTION'
   ;


-- Shipment types

g_ship_type_STANDARD             CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := 'STANDARD'
   ;
g_ship_type_PLANNED              CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := 'PLANNED'
   ;
g_ship_type_SCHEDULED            CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := 'SCHEDULED'
   ;
g_ship_type_BLANKET               CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := 'BLANKET'
   ;
--<Complex Work R12>: added prepayment ship type
g_ship_type_PREPAYMENT           CONSTANT
   VARCHAR2(25)
   := 'PREPAYMENT'
   ;


--<Complex Work R12 START>: added payment types
--Payment types

g_payment_type_MILESTONE         CONSTANT
   VARCHAR2(30)
   := 'MILESTONE'
   ;
g_payment_type_RATE              CONSTANT
   VARCHAR2(30)
   := 'RATE'
   ;
g_payment_type_LUMPSUM           CONSTANT
   VARCHAR2(30)
   := 'LUMPSUM'
   ;
g_payment_type_ADVANCE           CONSTANT
   VARCHAR2(30)
   := 'ADVANCE'
   ;
g_payment_type_DELIVERY          CONSTANT
   VARCHAR2(30)
   := 'DELIVERY'
   ;
--<Complex Work R12 END>


-- Distribution types

g_dist_type_STANDARD             CONSTANT
   VARCHAR2(25)
   := 'STANDARD'
   ;
g_dist_type_PLANNED              CONSTANT
   VARCHAR2(25)
   := 'PLANNED'
   ;
g_dist_type_SCHEDULED            CONSTANT
   VARCHAR2(25)
   := 'SCHEDULED'
   ;
g_dist_type_BLANKET              CONSTANT
   VARCHAR2(25)
   := 'BLANKET'
   ;
g_dist_type_AGREEMENT            CONSTANT
   VARCHAR2(25)
   := 'AGREEMENT'
   ;
--<Complex Work R12>: added prepayment dist type
g_dist_type_PREPAYMENT           CONSTANT
   VARCHAR2(25)
   := 'PREPAYMENT'
   ;

-- closed codes

g_clsd_FINALLY_CLOSED            CONSTANT
   PO_HEADERS_ALL.closed_code%TYPE
   := 'FINALLY CLOSED'
   ;
g_clsd_OPEN                      CONSTANT
   PO_HEADERS_ALL.closed_code%TYPE
   := 'OPEN'
   ;

-- Common parameter values:

g_parameter_YES CONSTANT VARCHAR2(1) := 'Y';
g_parameter_NO  CONSTANT VARCHAR2(1) := 'N';

-----------------------------------------------------------------------------
-- Public procedures
-----------------------------------------------------------------------------


  FUNCTION  get_ussgl_option     RETURN VARCHAR2;

  FUNCTION  get_gl_set_of_bks_id RETURN VARCHAR2;

/* ===========================================================================
  FUNCTION get_conversion_rate (
		x_from_currency		VARCHAR2,
		x_to_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

  DESCRIPTION    : Returns the rate between the two currencies for a
                   given conversion date and conversion type.
  CLIENT/SERVER  : SERVER

  LIBRARY NAME   :

  OWNER          : GKELLNER

  PARAMETERS     :   x_set_of_books_id          Set of Books you are in
                     x_from_currency		From currency
                     x_conversion_date	        Conversion date
                     x_conversion_type	        Conversion type

  RETURN         :   Rate                       The conversion rate between
                                                the two currencies

  NOTES          : We need this cover on top of gl_currency_api.get_rate
                   so that we can handle the gl_currency_api.no_rate and
                   no_data_found exception properly

=========================================================================== */
  FUNCTION get_conversion_rate (
		x_set_of_books_id	NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL) RETURN NUMBER;

--  PRAGMA   RESTRICT_REFERENCES(get_conversion_rate,WNDS,WNPS,RNPS);


  PROCEDURE get_displayed_value (x_lookup_type	IN  VARCHAR2,
				 x_lookup_code 	IN  VARCHAR2,
				 x_disp_value	OUT NOCOPY VARCHAR2,
				 x_description	OUT NOCOPY VARCHAR2,
				 x_validate	IN  BOOLEAN);

  /* Created by Raj Bhakta 10/30/96 */

  PROCEDURE validate_lookup_info(
            p_lookup_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.LookupRecType);

  PROCEDURE get_displayed_value (x_lookup_type       IN  VARCHAR2,
                                 x_lookup_code       IN  VARCHAR2,
			         x_disp_value	     OUT NOCOPY VARCHAR2,
			         x_description       OUT NOCOPY VARCHAR2);


  PROCEDURE get_displayed_value (x_lookup_type       IN  VARCHAR2,
                                 x_lookup_code       IN  VARCHAR2,
			         x_disp_value	     OUT NOCOPY VARCHAR2);


  PROCEDURE get_org_sob (x_org_id    OUT NOCOPY NUMBER,
                         x_org_name  OUT NOCOPY VARCHAR2,
                         x_sob_id    OUT NOCOPY NUMBER) ;

  PROCEDURE get_po_parameters (  x_currency_code                 OUT NOCOPY VARCHAR2,
                                 x_coa_id                        OUT NOCOPY NUMBER,
                                 x_po_encumberance_flag          OUT NOCOPY VARCHAR2,
                                 x_req_encumberance_flag         OUT NOCOPY VARCHAR2,
                                 x_sob_id                        OUT NOCOPY NUMBER,
                                 x_ship_to_location_id           OUT NOCOPY NUMBER,
                                 x_bill_to_location_id           OUT NOCOPY NUMBER,
                                 x_fob_lookup_code               OUT NOCOPY VARCHAR2,
                                 x_freight_terms_lookup_code     OUT NOCOPY VARCHAR2,
                                 x_terms_id                      OUT NOCOPY NUMBER,
                                 x_default_rate_type             OUT NOCOPY VARCHAR2,
                                 x_taxable_flag                  OUT NOCOPY VARCHAR2,
                                 x_receiving_flag                OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_name_flag       OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_auth_flag       OUT NOCOPY VARCHAR2,
                                 x_line_type_id                  OUT NOCOPY NUMBER,
                                 x_manual_po_num_type            OUT NOCOPY VARCHAR2,
                                 x_po_num_code                   OUT NOCOPY VARCHAR2,
                                 x_price_lookup_code             OUT NOCOPY VARCHAR2,
                                 x_invoice_close_tolerance       OUT NOCOPY NUMBER,
                                 x_receive_close_tolerance       OUT NOCOPY NUMBER,
                                 x_security_structure_id         OUT NOCOPY NUMBER,
                                 x_expense_accrual_code          OUT NOCOPY VARCHAR2,
                                 x_inv_org_id                    OUT NOCOPY NUMBER,
                                 x_rev_sort_ordering             OUT NOCOPY NUMBER,
                                 x_min_rel_amount                OUT NOCOPY NUMBER,
                                 x_notify_blanket_flag           OUT NOCOPY VARCHAR2,
                                 x_budgetary_control_flag        OUT NOCOPY VARCHAR2,
                                 x_user_defined_req_num_code     OUT NOCOPY VARCHAR2,
                                 x_rfq_required_flag             OUT NOCOPY VARCHAR2,
                                 x_manual_req_num_type           OUT NOCOPY VARCHAR2,
                                 x_enforce_full_lot_qty          OUT NOCOPY VARCHAR2,
                                 x_disposition_warning_flag      OUT NOCOPY VARCHAR2,
                                 x_reserve_at_completion_flag    OUT NOCOPY VARCHAR2,
                                 x_user_defined_rcpt_num_code    OUT NOCOPY VARCHAR2,
                                 x_manual_rcpt_num_type          OUT NOCOPY VARCHAR2,
			         x_use_positions_flag		 OUT NOCOPY VARCHAR2,
			         x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	         x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	         x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	         x_manual_quote_num_type	 OUT NOCOPY VARCHAR2,
		  	         x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	         x_manual_rfq_num_type		 OUT NOCOPY VARCHAR2,
				 x_ship_via_lookup_code	         OUT NOCOPY VARCHAR2,
				 x_qty_rcv_tolerance		 OUT NOCOPY NUMBER);

  /* Bug 7518967 : ER Default Acceptance Required Check : Overloading the procedure
     get_po_parameters to get the default acceptance_required_flag from the table
     PO_SYSTEM_PARAMETERS_ALL */

  PROCEDURE get_po_parameters (  x_currency_code                 OUT NOCOPY VARCHAR2,
                                 x_coa_id                        OUT NOCOPY NUMBER,
                                 x_po_encumberance_flag          OUT NOCOPY VARCHAR2,
                                 x_req_encumberance_flag         OUT NOCOPY VARCHAR2,
                                 x_sob_id                        OUT NOCOPY NUMBER,
                                 x_ship_to_location_id           OUT NOCOPY NUMBER,
                                 x_bill_to_location_id           OUT NOCOPY NUMBER,
                                 x_fob_lookup_code               OUT NOCOPY VARCHAR2,
                                 x_freight_terms_lookup_code     OUT NOCOPY VARCHAR2,
                                 x_terms_id                      OUT NOCOPY NUMBER,
                                 x_default_rate_type             OUT NOCOPY VARCHAR2,
                                 x_taxable_flag                  OUT NOCOPY VARCHAR2,
                                 x_receiving_flag                OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_name_flag       OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_auth_flag       OUT NOCOPY VARCHAR2,
                                 x_line_type_id                  OUT NOCOPY NUMBER,
                                 x_manual_po_num_type            OUT NOCOPY VARCHAR2,
                                 x_po_num_code                   OUT NOCOPY VARCHAR2,
                                 x_price_lookup_code             OUT NOCOPY VARCHAR2,
                                 x_invoice_close_tolerance       OUT NOCOPY NUMBER,
                                 x_receive_close_tolerance       OUT NOCOPY NUMBER,
                                 x_security_structure_id         OUT NOCOPY NUMBER,
                                 x_expense_accrual_code          OUT NOCOPY VARCHAR2,
                                 x_inv_org_id                    OUT NOCOPY NUMBER,
                                 x_rev_sort_ordering             OUT NOCOPY NUMBER,
                                 x_min_rel_amount                OUT NOCOPY NUMBER,
                                 x_notify_blanket_flag           OUT NOCOPY VARCHAR2,
                                 x_budgetary_control_flag        OUT NOCOPY VARCHAR2,
                                 x_user_defined_req_num_code     OUT NOCOPY VARCHAR2,
                                 x_rfq_required_flag             OUT NOCOPY VARCHAR2,
                                 x_manual_req_num_type           OUT NOCOPY VARCHAR2,
                                 x_enforce_full_lot_qty          OUT NOCOPY VARCHAR2,
                                 x_disposition_warning_flag      OUT NOCOPY VARCHAR2,
                                 x_reserve_at_completion_flag    OUT NOCOPY VARCHAR2,
                                 x_user_defined_rcpt_num_code    OUT NOCOPY VARCHAR2,
                                 x_manual_rcpt_num_type          OUT NOCOPY VARCHAR2,
			         x_use_positions_flag		 OUT NOCOPY VARCHAR2,
			         x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	         x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	         x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	         x_manual_quote_num_type	 OUT NOCOPY VARCHAR2,
		  	         x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	         x_manual_rfq_num_type		 OUT NOCOPY VARCHAR2,
				 x_ship_via_lookup_code	         OUT NOCOPY VARCHAR2,
				 x_qty_rcv_tolerance		 OUT NOCOPY NUMBER,
                                 x_acceptance_required_flag      OUT NOCOPY VARCHAR2);

  -- PDOI Enhancement Bug#17063664 : Added an overloaded procedure to get
  -- group shipments flag

  PROCEDURE get_po_parameters (  x_currency_code                 OUT NOCOPY VARCHAR2,
                                 x_coa_id                        OUT NOCOPY NUMBER,
                                 x_po_encumberance_flag          OUT NOCOPY VARCHAR2,
                                 x_req_encumberance_flag         OUT NOCOPY VARCHAR2,
                                 x_sob_id                        OUT NOCOPY NUMBER,
                                 x_ship_to_location_id           OUT NOCOPY NUMBER,
                                 x_bill_to_location_id           OUT NOCOPY NUMBER,
                                 x_fob_lookup_code               OUT NOCOPY VARCHAR2,
                                 x_freight_terms_lookup_code     OUT NOCOPY VARCHAR2,
                                 x_terms_id                      OUT NOCOPY NUMBER,
                                 x_default_rate_type             OUT NOCOPY VARCHAR2,
                                 x_taxable_flag                  OUT NOCOPY VARCHAR2,
                                 x_receiving_flag                OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_name_flag       OUT NOCOPY VARCHAR2,
                                 x_enforce_buyer_auth_flag       OUT NOCOPY VARCHAR2,
                                 x_line_type_id                  OUT NOCOPY NUMBER,
                                 x_manual_po_num_type            OUT NOCOPY VARCHAR2,
                                 x_po_num_code                   OUT NOCOPY VARCHAR2,
                                 x_price_lookup_code             OUT NOCOPY VARCHAR2,
                                 x_invoice_close_tolerance       OUT NOCOPY NUMBER,
                                 x_receive_close_tolerance       OUT NOCOPY NUMBER,
                                 x_security_structure_id         OUT NOCOPY NUMBER,
                                 x_expense_accrual_code          OUT NOCOPY VARCHAR2,
                                 x_inv_org_id                    OUT NOCOPY NUMBER,
                                 x_rev_sort_ordering             OUT NOCOPY NUMBER,
                                 x_min_rel_amount                OUT NOCOPY NUMBER,
                                 x_notify_blanket_flag           OUT NOCOPY VARCHAR2,
                                 x_budgetary_control_flag        OUT NOCOPY VARCHAR2,
                                 x_user_defined_req_num_code     OUT NOCOPY VARCHAR2,
                                 x_rfq_required_flag             OUT NOCOPY VARCHAR2,
                                 x_manual_req_num_type           OUT NOCOPY VARCHAR2,
                                 x_enforce_full_lot_qty          OUT NOCOPY VARCHAR2,
                                 x_disposition_warning_flag      OUT NOCOPY VARCHAR2,
                                 x_reserve_at_completion_flag    OUT NOCOPY VARCHAR2,
                                 x_user_defined_rcpt_num_code    OUT NOCOPY VARCHAR2,
                                 x_manual_rcpt_num_type          OUT NOCOPY VARCHAR2,
			         x_use_positions_flag		 OUT NOCOPY VARCHAR2,
			         x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	         x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	         x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	         x_manual_quote_num_type	 OUT NOCOPY VARCHAR2,
		  	         x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	         x_manual_rfq_num_type		 OUT NOCOPY VARCHAR2,
				 x_ship_via_lookup_code	         OUT NOCOPY VARCHAR2,
				 x_qty_rcv_tolerance		 OUT NOCOPY NUMBER,
                                 x_acceptance_required_flag      OUT NOCOPY VARCHAR2,
				 x_group_shipments_flag          OUT NOCOPY VARCHAR2);


  PROCEDURE get_item_category_structure ( x_category_set_id OUT NOCOPY NUMBER,
                                          x_structure_id    OUT NOCOPY NUMBER ) ;

  FUNCTION get_product_install_status (x_product_name IN VARCHAR2) RETURN VARCHAR2 ;

  PROCEDURE get_global_values(x_userid        OUT NOCOPY number,
                              x_logonid       OUT NOCOPY number,
                              x_last_upd_date OUT NOCOPY date,
                              x_current_date  OUT NOCOPY date ) ;

  PROCEDURE GET_PERIOD_NAME (x_sob_id   IN NUMBER,
                             x_period  OUT NOCOPY VARCHAR2,
                             x_gl_date OUT NOCOPY DATE );

/*===========================================================================
  FUNCTION NAME:	get_total

  DESCRIPTION:          Calculates the total of an object

  PARAMETERS:

  Parameter	         IN/OUT	Datatype   Description
  -------------          ------ ---------- ----------------------------
  x_object_type		  IN    VARCHAR2   Object Type
                                           'H' - for PO Header
                                           'L' - for PO Line
                                           'B' - for PO Blanket
                                           'P' - for Po Planned
                                           'E' - for Requisition Header
                                           'I' - for Requisition Line
                                           'C' - for Contract
                                           'R' - for Release

  x_object_id    	  IN    NUMBER     Id of the object to be
                                           totalled

  x_base_cur_result	  IN    BOOLEAN    Result in Base Currency

  RETURN VALUE:	   Returns total of the object

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
--IF this function is changed, please investigate the impact on get_archive_total, get_archive_total_for_any_rev as well.--<CONTERMS FPJ>
FUNCTION  GET_TOTAL (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_base_cur_result IN BOOLEAN) RETURN NUMBER;

--pragma restrict_references (get_total, WNDS);

FUNCTION  get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER) RETURN NUMBER;

--pragma restrict_references (get_total, WNDS);

--<CONTERMS FPJ START>
--FUNCTION to get archive total amount when the document is Standard Purchase order
--IF GET_TOTAL is changed, please investigate the impact on this function as well.
--Please check package bosy for more detailed comments
FUNCTION  get_archive_total (p_object_id       IN NUMBER,
                             p_doc_type        IN VARCHAR2,
                             p_doc_subtype     IN VARCHAR2,
                             p_base_cur_result IN VARCHAR2 DEFAULT 'N') RETURN NUMBER;
--<CONTERMS FPJ END>


--<POC FPJ START>

--FUNCTION to get archive total amount for a specified revision when the document is Standard Purchase order
--IF GET_TOTAL/GET_ARCHIVE_TOTAL is changed, please investigate the impact on this function as well.
--Name: GET_ARCHIVE_TOTAL_FOR_ANY_REV
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--   Returns total amount for any specified revision for Standard Purchase order
--Parameters:
--IN:
--  p_object_id
--     PO header id
--  p_object_type
--  'H' for Standard
--  'L' for Standard PO Line
--  'S' for Shipment Line
--  'R' for Release
--  p_doc_type
--     The main doc type for PO. Valid values are 'PO', 'RELEASE'
--  p_doc_subtype
--     The lookup code of the document. Valid values are 'STANDARD', 'BLANKET'
--  p_doc_revision
--     The Revision of the PO header
--  p_base_cur_result
--     Whether result should be returned in base currency or transaction currency
--      Valid Values are
--      'Y'- Return result in Base/Functional Currency for the org
--      'N'- Return result in Transaction currency in po
--       Default 'N'
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------

FUNCTION  get_archive_total_for_any_rev (p_object_id       IN NUMBER,
                             p_object_type     IN VARCHAR2,
                             p_doc_type        IN VARCHAR2,
                             p_doc_subtype     IN VARCHAR2,
                             p_doc_revision    IN NUMBER,
                             p_base_cur_result IN VARCHAR2)
RETURN NUMBER;


--<POC FPJ END>



/*===================================================================================

    FUNCTION:    get_ga_amount_released                <GA FPI>

    DESCRIPTION: Gets the total Amount Released for a particular Global Agreement.
                 That is, sum up the total for all uncancelled Standard PO lines
                 which reference that Global Agreement.

===================================================================================*/
FUNCTION get_ga_amount_released
(
    p_po_header_id             PO_HEADERS_ALL.po_header_id%TYPE,
    p_convert_to_base          BOOLEAN := FALSE
)
RETURN NUMBER;


/*===================================================================================

    FUNCTION:    get_ga_line_amount_released                <GA FPI>

    DESCRIPTION: Gets the total Amount Released for a Global Agreement line.
                 That is, sum up the total for all uncancelled Standard PO lines
                 which reference that Global Agreement line.

===================================================================================*/
PROCEDURE get_ga_line_amount_released
(
    p_po_line_id             IN       PO_LINES_ALL.po_line_id%TYPE,
    p_po_header_id           IN       PO_HEADERS_ALL.po_header_id%TYPE,
    x_quantity_released      OUT NOCOPY      NUMBER,
    x_amount_released        OUT NOCOPY      NUMBER
);

/*===================================================================================

    FUNCTION:    GET_RELEASE_LINE_TOTAL                Bug#3771735

    DESCRIPTION: Function is being added to get the correct cumulative Amount of all
		 shipments of  a  Release which correspond to the same line of a BPA.
		 The function will be used during the PDF generation of a Incomplete
		 Blanket Release.

===================================================================================*/

FUNCTION  GET_RELEASE_LINE_TOTAL
(
	p_line_id      IN PO_LINES_ALL.PO_LINE_ID%TYPE ,
	p_release_id   IN PO_RELEASES_ALL.PO_RELEASE_ID%TYPE
) RETURN NUMBER;


-------------------------------------------
-- Document id helper procedures
-------------------------------------------


PROCEDURE get_document_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_doc_id_tbl                     OUT NOCOPY     po_tbl_number
);


PROCEDURE get_line_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_line_id_tbl                    OUT NOCOPY     po_tbl_number
);


PROCEDURE get_line_location_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_line_location_id_tbl           OUT NOCOPY     po_tbl_number
);


PROCEDURE get_distribution_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_distribution_id_tbl            OUT NOCOPY     po_tbl_number
);

--<Complex Work R12 START>
PROCEDURE get_dist_ids_from_archive(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_doc_revision_num               IN             NUMBER
,  x_distribution_id_tbl            OUT NOCOPY     po_tbl_number
,  x_distribution_rev_num_tbl       OUT NOCOPY     po_tbl_number
);
--<Complex Work R12 END>

FUNCTION is_encumbrance_on(
   p_doc_type                       IN             VARCHAR2
,  p_org_id                         IN             NUMBER
)  RETURN BOOLEAN;


FUNCTION get_translated_text                                  -- <SERVICES FPJ>
(   p_message_name        IN    VARCHAR2
,   p_token1              IN    VARCHAR2 := NULL
,   p_value1              IN    VARCHAR2 := NULL
,   p_token2              IN    VARCHAR2 := NULL
,   p_value2              IN    VARCHAR2 := NULL
,   p_token3              IN    VARCHAR2 := NULL
,   p_value3              IN    VARCHAR2 := NULL
,   p_token4              IN    VARCHAR2 := NULL
,   p_value4              IN    VARCHAR2 := NULL
,   p_token5              IN    VARCHAR2 := NULL
,   p_value5              IN    VARCHAR2 := NULL
) RETURN VARCHAR2;

--<Shared Proc FPJ START>
FUNCTION Check_Doc_Number_Unique(p_Segment1 In VARCHAR2,
                                  p_org_id IN VARCHAR2,
                                  p_Type_lookup_code IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE check_inv_org_in_sob
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    p_sob_id        IN  NUMBER,
    x_in_sob        OUT NOCOPY BOOLEAN
);

PROCEDURE get_inv_org_ou_id
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_ou_id         OUT NOCOPY NUMBER
);

PROCEDURE get_inv_org_sob_id
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_sob_id        OUT NOCOPY NUMBER
);

PROCEDURE get_inv_org_info
(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_inv_org_id            IN  NUMBER,
    x_business_group_id     OUT NOCOPY NUMBER,
    x_set_of_books_id       OUT NOCOPY NUMBER,
    x_chart_of_accounts_id  OUT NOCOPY NUMBER,
    x_operating_unit_id     OUT NOCOPY NUMBER,
    x_legal_entity_id       OUT NOCOPY NUMBER
);

--<Shared Proc FPJ END>

PROCEDURE should_display_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_display_reserved_flag          OUT NOCOPY     VARCHAR2
);

PROCEDURE is_fully_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_fully_reserved_flag            OUT NOCOPY     VARCHAR2
);

PROCEDURE are_any_dists_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_some_dists_reserved_flag       OUT NOCOPY     VARCHAR2
);

PROCEDURE get_reserved_lookup(
   x_displayed_field                  OUT NOCOPY     VARCHAR2
);

-- Bug 3373453 START
PROCEDURE validate_yes_no_param (
  x_return_status   OUT NOCOPY VARCHAR2,
  p_parameter_name  IN VARCHAR2,
  p_parameter_value IN VARCHAR2
);
-- Bug 3373453 END

FUNCTION get_session_gt_nextval
RETURN NUMBER
;

-- <Doc Manager Rewrite 11.5.11 Start>

PROCEDURE get_document_status(
   p_document_id          IN      VARCHAR2
,  p_document_type        IN      VARCHAR2
,  p_document_subtype     IN      VARCHAR2
,  x_return_status        OUT NOCOPY VARCHAR2
,  x_document_status      OUT NOCOPY VARCHAR2
);

PROCEDURE get_default_price(
   p_src_doc_header_id  IN     NUMBER
,  p_src_doc_line_num   IN     NUMBER
,  p_deliver_to_loc_id  IN     NUMBER
,  p_required_currency  IN     VARCHAR2
,  p_required_rate_type IN     VARCHAR2
,  p_quantity           IN     NUMBER
,  p_uom                IN     VARCHAR2
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_return_uom         OUT NOCOPY  VARCHAR2
,  x_base_price         OUT NOCOPY  NUMBER
,  x_currency_price     OUT NOCOPY  NUMBER
,  x_discount           OUT NOCOPY  NUMBER
,  x_currency_code      OUT NOCOPY  VARCHAR2
,  x_rate_type          OUT NOCOPY  VARCHAR2
,  x_rate_date          OUT NOCOPY  DATE
,  x_rate               OUT NOCOPY  NUMBER
);
-- <Doc Manager Rewrite 11.5.11 End>

-- <HTML Orders R12 Start>
FUNCTION flag_to_boolean (
  p_flag_value IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION boolean_to_flag (
  p_boolean_value IN BOOLEAN
) RETURN VARCHAR2;
-- <HTML Orders R12 End>

-- <R12 SLA>
FUNCTION Check_Federal_Instance (
   p_org_id  IN    hr_operating_units.organization_id%type
) RETURN VARCHAR2 ;

--<R12 SHIKYU>
FUNCTION get_outsourced_assembly( p_item_id IN NUMBER,
	                          p_ship_to_org_id IN NUMBER ) RETURN NUMBER;

--<R12 eTax Integration Start>
FUNCTION get_default_legal_entity_id(p_org_id IN NUMBER) RETURN NUMBER;
--<R12 eTax Integration End>

--<HTML Agreements R12 Start>
FUNCTION get_last_update_date_for_doc(p_doc_header_id IN NUMBER) RETURN DATE;
--<HTML Agreements R12 End>

-- <ACHTML R12 START>
FUNCTION is_equal(
  p_attribute_primary NUMBER,
  p_attribute_secondary NUMBER
) RETURN BOOLEAN;
-- <ACHTML R12 END>

-- <ACHTML R12 START>
FUNCTION is_equal(
  p_attribute_primary VARCHAR2,
  p_attribute_secondary VARCHAR2
) RETURN BOOLEAN;
-- <ACHTML R12 END>

-- <ACHTML R12 START>
FUNCTION is_equal_minutes(
  p_attribute_primary DATE,
  p_attribute_secondary DATE
) RETURN BOOLEAN;
-- <ACHTML R12 END>

--Bug 11056822
FUNCTION is_email_valid(
        p_email_address IN VARCHAR2
) RETURN BOOLEAN;


END PO_CORE_S;

/
